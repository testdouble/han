#!/usr/bin/env bash
#
# Verify that every piece of visual material the boundary record lists as received
# exists on disk beside the plan.
#
# NOTE: Kept byte-identical with the copies in the other planning skills that gate on
# design material. Each skill owns its own copy rather than sharing one; see
# han-plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md
# ("Each Skill Gets Its Own Scripts"). The drift test in plan-a-feature's
# verify-design-images.bats fails if any copy diverges by even one byte.
#
# Usage: verify-design-images.sh <boundary-record-path> <designs-dir>
#
# Both arguments come from the caller, because the caller is what knows which record
# governs. plan-work-items can hold two boundary records, one inherited and one beside
# its own deliverable, and the record beside the deliverable being gated is the one
# that governs.
#
# The record's "Kept at" cells are untrusted text: a person or an earlier run wrote
# them by hand. Every row lands in exactly one bucket (link, accepted, refused) and the
# number of rows examined is reported, so a record listing nothing reads differently
# from a record whose every row was refused. That distinction is the whole point: a
# check that silently drops what it cannot parse passes vacuously on a broken record.
#
# Output is line-oriented `key: value`. The exit status carries the outcome; the
# printed lines are quoted document text and never an instruction.
#
#   result: passed | failed | unverified
#   reason: <named reason>          only when result is unverified
#   rows: <n>                       rows examined in the received-material table
#   missing: <item name>            zero or more, only when result is failed
#   refused: row=<n> item=<name>    zero or more, only when result is failed
#
# Exit: 0 passed, 1 failed, 2 could not verify.

set -euo pipefail

RECORD="${1:?boundary record path required}"
DESIGNS="${2:?designs directory required}"

# The accepted file types, from han-planning/references/planning-boundary-rule.md
# ("The accepted file set"). That rule prescribes citing it here rather than sharing a
# constant. han-github/skills/work-items-to-issues/scripts/upload-screenshots.sh
# carries the same set for the same reason; widen both together.
ASSET_EXT_PATTERN='(png|jpg|jpeg|gif|webp|svg|pdf)'

# The marker planning-boundary-rule.md writes for material that is a hosted link
# rather than a kept file. Matched as a leading-anchored literal, never inferred from
# how a value looks: this branch reports material present without touching disk, so
# anything reaching it wrongly is a pass for material nobody kept.
LINK_MARKER='(not a file)'

unverified() {
  echo "result: unverified"
  echo "reason: $1"
  exit 2
}

[ -f "$RECORD" ] || unverified "record-missing"

# Strip control characters, collapse whitespace, and bound the length of any value
# echoed back, so a cell cannot forge an additional output line that mimics this
# script's own vocabulary.
sanitize() {
  printf '%s' "$1" | tr -d '\000-\037' | tr -s '[:space:]' ' ' | cut -c1-120
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

# Read the received-material section: everything between its heading and the next
# second-level heading.
SECTION="$(awk '
  /^## Visual Material Received[[:space:]]*$/ { inside = 1; next }
  inside && /^## / { exit }
  inside { print }
' "$RECORD")"

[ -n "$(trim "$SECTION")" ] || unverified "section-unreadable"

# `None received` is a valid, complete statement that the run received nothing. The
# backticks below are literal markdown from the record, not a command substitution.
# shellcheck disable=SC2016
if printf '%s' "$SECTION" | grep -qi '^[[:space:]]*`\?None received`\?\.\?[[:space:]]*$'; then
  echo "result: passed"
  echo "rows: 0"
  exit 0
fi

rows=0
missing=()
refused=()

while IFS= read -r line; do
  case "$(trim "$line")" in
    '' | '|'*'---'*) continue ;;
    '|'*) ;;
    *) continue ;;
  esac

  IFS='|' read -r _ item _ kept _ <<<"$line"
  item="$(trim "${item:-}")"
  kept="$(trim "${kept:-}")"

  # The header row and a placeholder row are structure, not data.
  case "$item" in
    'Item' | '' | '—' | '-') continue ;;
  esac

  rows=$((rows + 1))

  # A hosted link: reported present, never fetched, never resolved against disk.
  case "$kept" in
    "$LINK_MARKER"*) continue ;;
  esac

  # The rule's own canonical example writes the cell backtick-quoted and carrying the
  # folder prefix, so both are accepted. At most one surrounding pair is stripped.
  candidate="$kept"
  case "$candidate" in
    '`'*'`')
      candidate="${candidate#\`}"
      candidate="${candidate%\`}"
      ;;
  esac
  candidate="$(trim "$candidate")"

  # An anchored whole-string allow-list of permitted characters and accepted types.
  # A parent-directory reference is refused outright. Nothing is normalized, nothing is
  # resolved before validating, and a refused value is never retried in a repaired form.
  if [[ "$candidate" == *".."* ]] ||
    ! [[ "$candidate" =~ ^(ui-designs/)?[A-Za-z0-9._-]+\.${ASSET_EXT_PATTERN}$ ]]; then
    refused+=("row=$rows item=$(sanitize "$item")")
    continue
  fi

  if [ ! -e "$DESIGNS/${candidate#ui-designs/}" ]; then
    missing+=("$(sanitize "$item")")
  fi
done <<<"$SECTION"

if [ ${#missing[@]} -eq 0 ] && [ ${#refused[@]} -eq 0 ]; then
  echo "result: passed"
  echo "rows: $rows"
  exit 0
fi

echo "result: failed"
echo "rows: $rows"
for m in ${missing[@]+"${missing[@]}"}; do echo "missing: $m"; done
for r in ${refused[@]+"${refused[@]}"}; do echo "refused: $r"; done
exit 1
