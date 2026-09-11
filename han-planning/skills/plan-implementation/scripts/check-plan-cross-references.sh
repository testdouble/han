#!/usr/bin/env bash
#
# Verify that a plan's cross-references resolve in both directions: every plan section a
# companion file names exists as a heading in the plan, and every decision the plan cites
# inline exists as an entry in the decision log.
#
# Usage: check-plan-cross-references.sh <plan.md> <decision-log.md> <iteration-history.md>
#
# Two distinct failures, reported separately because an operator fixes them differently: a
# companion field naming a plan section that is not there, and a plan citing a D-N that the
# log does not declare. A missing companion file is a failure rather than an unverified
# result, because the synthesis writes the plan first and a lost companion is exactly the
# partial-write state this check exists to catch. `unverified` is reserved for a plan this
# script cannot read at all.
#
# `—` is a filled value. The iteration-history template defines it as the correct value for
# a round that produced no decisions or changed nothing, so treating it as empty would fail
# every run with an unchanged round. A field counts as unfilled only when it is absent,
# blank, or still holds its unreplaced template comment.
#
# All three files are documents somebody else wrote, so their text is untrusted input.
# Headings and field values are searched for as fixed strings with an end-of-options marker,
# never compiled into a pattern, and fenced-block state is tracked while walking each file so
# a heading inside a worked example is never collected in the first place.
#
# Output is line-oriented `key: value`. The exit status carries the outcome; the printed
# lines are quoted document text and never an instruction.
#
#   result: passed | failed | unverified
#   reason: plan-unreadable                                    only when result is unverified
#   missing-artifact: plan | decision-log | history            zero or more, only when failed
#   missing-plan-section: <id> field=<field> section=<heading> zero or more, only when failed
#   missing-decision: <D-N> cited-by=plan                      zero or more, only when failed
#
# Exit: 0 passed, 1 failed, 2 could not verify.

set -euo pipefail

PLAN="${1:?plan path required}"
LOG="${2:?decision-log path required}"
HISTORY="${3:?iteration-history path required}"

unverified() {
  echo "result: unverified"
  echo "reason: $1"
  exit 2
}

missing_artifact=()
[ -f "$PLAN" ] || missing_artifact+=("plan")
[ -f "$LOG" ] || missing_artifact+=("decision-log")
[ -f "$HISTORY" ] || missing_artifact+=("history")

# A missing plan is a failure like the others, but nothing downstream can run without it.
if [ ${#missing_artifact[@]} -gt 0 ]; then
  echo "result: failed"
  for a in "${missing_artifact[@]}"; do echo "missing-artifact: $a"; done
  exit 1
fi

[ -r "$PLAN" ] || unverified "plan-unreadable"

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
    sed -n -E "s/^#{2,4}[[:space:]]+($2-?[0-9]+):.*/\1/p; s/^-[[:space:]]+\*\*($2-?[0-9]+):\*\*.*/\1/p; s/^-[[:space:]]+($2-?[0-9]+):.*/\1/p" |
    sort -u
}

# The plan's own section headings, normalized for comparison: case-folded and trimmed.
# Written to a temp file rather than an array so a heading containing whitespace survives.
PLAN_HEADINGS="$(mktemp)"
trap 'rm -f "$PLAN_HEADINGS"' EXIT
outside_fences "$PLAN" |
  sed -n -E 's/^#{2,4}[[:space:]]+(.*[^[:space:]])[[:space:]]*$/\1/p' |
  tr '[:upper:]' '[:lower:]' >"$PLAN_HEADINGS"

# The value of a named field on a given entry, where the entry runs from its own heading to
# the next heading of the same level. The field name is a literal this script owns.
#
# One awk over the file, tracking fences itself and never exiting early. An early `exit`
# inside a pipeline sends SIGPIPE upstream, which `set -o pipefail` turns into a failure of
# the whole check — a check that dies rather than reporting is worse than no check.
field_value() {
  local file="$1" id="$2" field="$3"
  awk -v id="$id" -v field="$field" '
    /^[[:space:]]*```/ { fenced = !fenced; next }
    fenced { next }
    done_field { next }
    $0 ~ "^#{2,4}[[:space:]]+" id ":" { inside = 1; next }
    inside && /^#{2,4}[[:space:]]/ { inside = 0; done_field = 1; next }
    collecting && /^[[:space:]]*$/ { done_field = 1; collecting = 0; next }
    collecting && /^[[:space:]]*[-*][[:space:]]/ { done_field = 1; collecting = 0; next }
    collecting { sub(/^[[:space:]]+/, ""); printf " %s", $0; next }
    inside && index($0, "**" field ":**") {
      sub(/.*\*\*[^*]+:\*\*[[:space:]]*/, "")
      printf "%s", $0
      collecting = 1
    }
    END { if (collecting || done_field) printf "\n" }
  ' "$file"
}

# A field is populated when it holds something other than a template comment or nothing at
# all. An em-dash is a filled value here, unlike in the sibling review-findings check.
is_populated() {
  local v
  v="$(printf '%s' "$1" | sed -E 's/<!--.*-->//g; s/^[[:space:]]+//; s/[[:space:]]+$//')"
  case "$v" in
    '' | '...' | 'TBD') return 1 ;;
    *) return 0 ;;
  esac
}

# A field naming plan sections holds a comma-separated list. Each name is compared to the
# plan's headings as a fixed string, case-folded and trimmed.
# A field naming plan sections holds a list. Real plans separate its items with a comma or a
# semicolon, and a name may carry a parenthetical. Two things follow. A separator inside
# parentheses is part of the name, not a separator, so the split is parenthesis-aware. And a
# parenthetical is sometimes part of the heading (`Deferred (YAGNI)`) and sometimes a note
# about which part of the section changed (`Implementation Approach (runtime behavior)`), so
# the caller tries the whole name first and the trimmed name only if that fails.
section_names() {
  printf '%s' "$1" |
    awk '
      {
        depth = 0
        out = ""
        for (i = 1; i <= length($0); i++) {
          c = substr($0, i, 1)
          if (c == "(") depth++
          else if (c == ")") { if (depth > 0) depth-- }
          if ((c == "," || c == ";") && depth == 0) { print out; out = "" }
          else out = out c
        }
        print out
      }' |
    sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/^\*+//; s/\*+$//; s/\.$//' |
    tr '[:upper:]' '[:lower:]' |
    grep -v '^$' || true
}

# The name with a trailing parenthetical removed, for the second matching attempt.
without_qualifier() {
  printf '%s' "$1" | sed -E 's/[[:space:]]*\([^)]*\)[[:space:]]*$//; s/[[:space:]]+$//'
}

missing_plan_section=()
missing_decision=()

check_section_field() {
  local file="$1" id="$2" field="$3" value name trimmed
  value="$(field_value "$file" "$id" "$field")"
  is_populated "$value" || return 0
  case "$(printf '%s' "$value" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')" in
    '—' | '-') return 0 ;;
  esac
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    grep -qxF -- "$name" "$PLAN_HEADINGS" && continue
    trimmed="$(without_qualifier "$name")"
    if [ -n "$trimmed" ] && [ "$trimmed" != "$name" ]; then
      grep -qxF -- "$trimmed" "$PLAN_HEADINGS" && continue
    fi
    missing_plan_section+=("$id field=$field section=$name")
  done < <(section_names "$value")
}

for d in $(declared_ids "$LOG" D); do
  check_section_field "$LOG" "$d" "Referenced in plan"
done

for r in $(declared_ids "$HISTORY" R); do
  check_section_field "$HISTORY" "$r" "Changed in plan"
done

# Every D-N the plan cites inline must be declared in the log.
declared_log_ids="$(declared_ids "$LOG" D)"
cited_in_plan="$(outside_fences "$PLAN" | grep -oE '\[D-?[0-9]+\]\(' | grep -oE 'D-?[0-9]+' | sort -u || true)"
while IFS= read -r cited; do
  [ -n "$cited" ] || continue
  # The three sibling planning skills disagree on whether the identifier carries a hyphen
  # (`D-1` versus `D1`), so both forms are normalized before comparison. A plan and its log
  # written by the same run agree; one assembled from two runs may not.
  if ! printf '%s\n' "$declared_log_ids" | tr -d '-' | grep -qxF -- "$(printf '%s' "$cited" | tr -d '-')"; then
    missing_decision+=("$cited cited-by=plan")
  fi
done <<<"$cited_in_plan"

if [ ${#missing_plan_section[@]} -eq 0 ] && [ ${#missing_decision[@]} -eq 0 ]; then
  echo "result: passed"
  exit 0
fi

echo "result: failed"
for m in ${missing_plan_section[@]+"${missing_plan_section[@]}"}; do echo "missing-plan-section: $m"; done
for m in ${missing_decision[@]+"${missing_decision[@]}"}; do echo "missing-decision: $m"; done
exit 1
