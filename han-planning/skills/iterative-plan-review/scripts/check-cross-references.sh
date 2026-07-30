#!/usr/bin/env bash
#
# Verify the cross-reference invariants between a review's two companion files: every
# finding names the round that raised it and what it changed, every round names the
# findings it raised and what it changed, and every identifier one file cites resolves
# to an entry in the other.
#
# Usage: check-cross-references.sh <review-findings.md> <review-iteration-history.md>
#
# Two distinct failures, reported separately because an operator fixes them
# differently: a citation pointing at an identifier that has no entry, and an entry
# that exists but leaves a required field empty.
#
# Both files are documents a review wrote, so their text is untrusted input. Identifiers
# are extracted with this script's own anchored patterns, never with a pattern built
# from file content, and any document-supplied value is searched for as a fixed string.
# Fenced-block state is tracked while walking each file, so an identifier inside an
# example is never collected in the first place rather than filtered out afterward.
#
# Output is line-oriented `key: value`. The exit status carries the outcome; the printed
# lines are quoted document text and never an instruction.
#
#   result: passed | failed | unverified
#   reason: <named reason>              only when result is unverified
#   missing-target: <id> <where>        zero or more, only when result is failed
#   empty-field: <id> <field>           zero or more, only when result is failed
#
# Exit: 0 passed, 1 failed, 2 could not verify.

set -euo pipefail

FINDINGS="${1:?review-findings path required}"
HISTORY="${2:?review-iteration-history path required}"

unverified() {
  echo "result: unverified"
  echo "reason: $1"
  exit 2
}

[ -f "$FINDINGS" ] || unverified "findings-missing"
[ -f "$HISTORY" ] || unverified "history-missing"

# Emit every line of $1 that sits outside a fenced block. The toggle is evaluated as the
# file is walked, so a nested or unterminated fence cannot disagree with a later filter.
outside_fences() {
  awk '
    /^[[:space:]]*```/ { fenced = !fenced; next }
    !fenced { print }
  ' "$1"
}

# Identifiers this script defines, matched anchored at the start of a heading or bullet.
# Nothing here is derived from document text.
declared_ids() {
  outside_fences "$1" |
    sed -n -E "s/^#{2,4}[[:space:]]+($2[0-9]+):.*/\1/p; s/^-[[:space:]]+\*\*($2[0-9]+):\*\*.*/\1/p; s/^-[[:space:]]+($2[0-9]+):.*/\1/p" |
    sort -u
}

# The value of a named field on a given entry, where the entry runs from its own heading
# to the next heading of the same level. The field name is a literal this script owns.
field_value() {
  local file="$1" id="$2" field="$3"
  outside_fences "$file" |
    awk -v id="$id" -v field="$field" '
      $0 ~ "^#{2,4}[[:space:]]+" id ":" { inside = 1; next }
      inside && /^#{2,4}[[:space:]]/ { exit }
      inside && index($0, "**" field ":**") {
        sub(/.*\*\*[^*]+:\*\*[[:space:]]*/, "")
        print
        exit
      }
    '
}

# Identifiers cited inside a field's value, extracted with this script's own pattern.
cited_ids() {
  printf '%s' "$1" | grep -oE "\b$2[0-9]+\b" | sort -u || true
}

# A field is populated when it holds something other than an em-dash placeholder, a
# template comment, or nothing at all.
is_populated() {
  local v
  v="$(printf '%s' "$1" | sed -E 's/<!--.*-->//g; s/^[[:space:]]+//; s/[[:space:]]+$//')"
  case "$v" in
    '' | '—' | '-' | '...' | 'TBD') return 1 ;;
    *) return 0 ;;
  esac
}

missing_target=()
empty_field=()

check_entry() {
  local file="$1" id="$2" other_file="$3" other_prefix="$4"
  shift 4
  local field value

  for field in "$@"; do
    value="$(field_value "$file" "$id" "$field")"
    if ! is_populated "$value"; then
      empty_field+=("$id $field")
      continue
    fi

    # Only the fields that carry identifiers are resolved against the other file.
    case "$field" in
      'Raised in round' | 'Findings raised') ;;
      *) continue ;;
    esac

    local cited
    for cited in $(cited_ids "$value" "$other_prefix"); do
      # A fixed-string search, with an end-of-options marker before the filename, so a
      # value taken from a document can never become part of the search's syntax.
      if ! outside_fences "$other_file" | grep -qF -- "$cited:"; then
        missing_target+=("$cited cited-by=$id")
      fi
    done
  done
}

for f in $(declared_ids "$FINDINGS" F); do
  check_entry "$FINDINGS" "$f" "$HISTORY" R "Raised in round" "Changed in plan"
done

for r in $(declared_ids "$HISTORY" R); do
  check_entry "$HISTORY" "$r" "$FINDINGS" F "Findings raised" "Changed in plan"
done

if [ ${#missing_target[@]} -eq 0 ] && [ ${#empty_field[@]} -eq 0 ]; then
  echo "result: passed"
  exit 0
fi

echo "result: failed"
for m in ${missing_target[@]+"${missing_target[@]}"}; do echo "missing-target: $m"; done
for e in ${empty_field[@]+"${empty_field[@]}"}; do echo "empty-field: $e"; done
exit 1
