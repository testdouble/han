#!/usr/bin/env bash
# Usage: link-blockers.sh <work-items-file> <target-repo>
#
# Reads the SYM -> #NNN mapping from `## <SYM-N> (#NNN) — ...` headings,
# then walks each slice's `**Depends on.** ...` line and posts a native
# blocked_by relationship per blocker via the GitHub Issue Dependencies
# API (within-repo only).
#
# API contract (GA since 2025-08-21, no preview header required):
#   POST /repos/{owner}/{repo}/issues/{issue_number}/dependencies/blocked_by
#   body: { "issue_id": <blocker's global database id> }
# The body field is the blocker's global `id` (unique across GitHub), not
# its repo-local issue number. GitHub links up to 50 issues per relationship
# type; a slice with more blockers than that fails loudly on the 51st POST
# (set -e), which is acceptable: a work item with 50+ blockers is a planning
# smell to fix upstream, not silently truncate here.
# Docs: https://docs.github.com/en/rest/issues/issue-dependencies
#
# Errors if a blocker SYM has no #NNN mapping in this file — that means
# either the slice wasn't created yet (run create-issues.sh first) or the
# Depends on line references a cross-repo SYM, which is forbidden by the
# skill's rules (cross-repo deps belong in the preamble integration table).

set -euo pipefail

WORK_ITEMS="${1:?work-items file required}"
TARGET_REPO="${2:?target repo (org/name) required}"

[ -f "$WORK_ITEMS" ] || { echo "work-items file not found: $WORK_ITEMS" >&2; exit 1; }

# Portable across bash 3.2 (macOS default) and bash 4+ — no associative arrays.
# Each sym -> num mapping is stored as a flat shell variable named
# SYM_TO_NUM__<sym-with-dashes-as-underscores>.
sym_var() { echo "SYM_TO_NUM__$(echo "$1" | tr '-' '_')"; }
sym_set() { eval "$(sym_var "$1")=\"$2\""; }
sym_get() { eval "echo \"\${$(sym_var "$1"):-}\""; }

SYM_COUNT=0
while IFS= read -r line; do
  sym=$(echo "$line" | sed -E 's/^## ([A-Z][A-Z0-9]*-[0-9]+) \(#[0-9]+\) — .*/\1/')
  num=$(echo "$line" | sed -E 's/^## [A-Z][A-Z0-9]*-[0-9]+ \(#([0-9]+)\) — .*/\1/')
  sym_set "$sym" "$num"
  SYM_COUNT=$((SYM_COUNT + 1))
done < <(grep -E '^## [A-Z][A-Z0-9]*-[0-9]+ \(#[0-9]+\) — ' "$WORK_ITEMS")

if [ "$SYM_COUNT" -eq 0 ]; then
  echo "no created slices found in $WORK_ITEMS — run create-issues.sh first" >&2
  exit 1
fi

current=""
linked=0

while IFS= read -r line; do
  if [[ "$line" =~ ^##[[:space:]]+([A-Z][A-Z0-9]*-[0-9]+) ]]; then
    current="${BASH_REMATCH[1]}"
    continue
  fi

  if [[ "$line" =~ ^\*\*Depends\ on\.\*\*[[:space:]]+(.+)$ ]]; then
    deps="${BASH_REMATCH[1]}"
    deps="${deps//\`/}"           # strip backticks (e.g., `None.` → None.)
    deps="${deps%.}"              # strip trailing period
    deps=$(echo "$deps" | xargs)  # trim

    if [ "$deps" = "None" ] || [ -z "$deps" ]; then
      continue
    fi

    blocked_num=$(sym_get "$current")
    if [ -z "$blocked_num" ]; then
      echo "ERROR: $current has Depends on but no #NNN mapping — was it created?" >&2
      exit 1
    fi

    IFS=',' read -ra blockers <<< "$deps"
    for raw in "${blockers[@]}"; do
      b=$(echo "$raw" | xargs)
      b="${b%.}"
      [ -z "$b" ] && continue

      blocker_num=$(sym_get "$b")
      if [ -z "$blocker_num" ]; then
        echo "ERROR: $current Depends on $b, but $b has no #NNN mapping in this file." >&2
        echo "  Cross-repo dependencies must live in the preamble integration table, not in Depends on." >&2
        echo "  If $b is in this repo, run create-issues.sh first." >&2
        exit 1
      fi

      # `.id` is the blocker's global database id (what the API's issue_id
      # field expects), not `.number`. `-F` sends it as a JSON integer.
      blocker_id=$(gh api "repos/$TARGET_REPO/issues/$blocker_num" --jq .id)
      gh api --method POST \
        "repos/$TARGET_REPO/issues/$blocked_num/dependencies/blocked_by" \
        -F issue_id="$blocker_id" \
        --jq '.issue_dependencies_summary' >/dev/null
      echo "linked: $current(#$blocked_num) blocked_by $b(#$blocker_num)"
      linked=$((linked + 1))
    done
  fi
done < "$WORK_ITEMS"

echo "done — $linked dependency link(s) created"
