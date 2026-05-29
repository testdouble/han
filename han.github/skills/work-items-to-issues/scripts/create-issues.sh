#!/usr/bin/env bash
# Usage: create-issues.sh <work-items-file> <target-repo> [--label <name>] [--assignee <user>]
#
# Walks every `## <SYM-N> — <title>` heading in file order (blocker-first,
# since the work-items file is authored that way) and creates one GitHub
# issue per slice. After each successful creation, rewrites the heading in
# place to `## <SYM-N> (#NNN) — <title>` so link-blockers.sh can resolve
# symbolic IDs to issue numbers.
#
# By default issues are created with no label and no assignee. Pass
# `--label <name>` to upsert that label and apply it to every issue, and/or
# `--assignee <user>` to assign every issue to that user. Both are optional.
#
# Idempotent: slices whose heading already includes `(#NNN)` are skipped.

set -euo pipefail

WORK_ITEMS="${1:?work-items file required}"
TARGET_REPO="${2:?target repo (org/name) required}"
shift 2 || true

LABEL=""
ASSIGNEE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --label)    LABEL="${2:?--label requires a value}";    shift 2 ;;
    --assignee) ASSIGNEE="${2:?--assignee requires a value}"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -f "$WORK_ITEMS" ] || { echo "work-items file not found: $WORK_ITEMS" >&2; exit 1; }

if [ -n "$LABEL" ]; then
  gh label create "$LABEL" --repo "$TARGET_REPO" --force >/dev/null
  echo "label '$LABEL' upserted on $TARGET_REPO"
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Slice heading pattern: `^## <PREFIX>-<NUM>` — captured at file scan time.
# We re-read the file inside the loop (after each rewrite) so the line
# numbers stay valid even though only one line changes per iteration.

while true; do
  # Find the first un-numbered slice heading.
  match=$(grep -nE '^## [A-Z][A-Z0-9]*-[0-9]+ — ' "$WORK_ITEMS" | head -n 1 || true)
  [ -z "$match" ] && break

  start_line=$(echo "$match" | cut -d: -f1)
  heading=$(echo "$match" | cut -d: -f2-)

  # Find the next heading line after start_line (the body terminator).
  next_line=$(awk -v s="$start_line" 'NR>s && /^## / {print NR; exit}' "$WORK_ITEMS")
  if [ -z "$next_line" ]; then
    next_line=$(($(wc -l < "$WORK_ITEMS") + 1))
  fi

  sym=$(echo "$heading" | sed -E 's/^## ([A-Z][A-Z0-9]*-[0-9]+) — .*/\1/')
  title=$(echo "$heading" | sed -E 's/^## //')

  body_file="$tmpdir/$sym.md"
  sed -n "$((start_line + 1)),$((next_line - 1))p" "$WORK_ITEMS" > "$body_file"

  # Optional label/assignee. Empty-array expansion is guarded with the
  # `${arr[@]+...}` idiom so it stays safe under `set -u` on bash 3.2 (macOS).
  extra_args=()
  [ -n "$LABEL" ]    && extra_args+=(--label "$LABEL")
  [ -n "$ASSIGNEE" ] && extra_args+=(--assignee "$ASSIGNEE")

  url=$(gh issue create \
    --repo "$TARGET_REPO" \
    --title "$title" \
    --body-file "$body_file" \
    ${extra_args[@]+"${extra_args[@]}"})

  num=$(echo "$url" | grep -oE '[0-9]+$')
  [ -n "$num" ] || { echo "ERROR: could not parse issue number from: $url" >&2; exit 1; }

  # Rewrite that specific line: `## SYM-N — title` -> `## SYM-N (#NNN) — title`.
  # sed -i.bak works on both BSD and GNU sed; we delete the backup after.
  sed -i.bak "${start_line}s|^## ${sym} — |## ${sym} (#${num}) — |" "$WORK_ITEMS"
  rm -f "$WORK_ITEMS.bak"

  echo "created: $sym -> $url"
done

# Report skipped (already-numbered) slices for transparency.
already=$(grep -cE '^## [A-Z][A-Z0-9]*-[0-9]+ \(#[0-9]+\) — ' "$WORK_ITEMS" || true)
echo "done — $already slice(s) carried existing issue numbers and were skipped"
