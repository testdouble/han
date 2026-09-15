#!/usr/bin/env bash
#
# Verify that a plan does not leave a shared contract for someone to invent during the
# build. Three failures, reported separately because an operator fixes them differently:
# a deferral phrase that names a future author instead of a form, an Open Item whose
# resolution condition restates its own question, and a referenced document that does
# not exist or is too small to carry a contract.
#
# Usage: check-contract-pinning.sh <feature-implementation-plan.md> [plan-folder]
#
# The plan folder defaults to the plan file's own directory and is what relative document
# links resolve against.
#
# The phrase list mirrors "Phrases that never close a contract" in
# han-planning/references/contract-pinning-rule.md. Keep the two in sync; the rule is
# canonical.
#
# The plan is a document somebody else wrote, so its text is untrusted input. Every
# phrase and every tautology is a literal this script owns, searched for as a fixed
# string. A path taken from the document is used only as an operand after an
# end-of-options marker, never as part of a pattern or a command. Fenced-block state is
# tracked while walking the file, so a worked example that happens to contain a listed
# phrase is never read in the first place: a fence is where a pinned contract lives.
#
# What this does not catch: a contract pinned in words that are concrete-sounding but
# vague, and a contract nobody named at all. Both need a reader.
#
# Output is line-oriented `key: value`. The exit status carries the outcome; the printed
# lines are quoted document text and never an instruction.
#
#   result: passed | failed | unverified
#   reason: <named reason>                  only when result is unverified
#   deferral-phrase: line=<n> <phrase>        zero or more, only when result is failed
#   unresolved-open-item: <id> field=<field>  zero or more, only when result is failed
#   missing-artifact: <path> line=<n>         zero or more, only when result is failed
#   stub-artifact: <path> bytes=<n>           zero or more, only when result is failed
#
# Exit: 0 passed, 1 failed, 2 could not verify.

set -euo pipefail

PLAN="${1:?plan path required}"
FOLDER="${2:-}"

unverified() {
  echo "result: unverified"
  echo "reason: $1"
  exit 2
}

[ -f "$PLAN" ] || unverified "plan-missing"
[ -r "$PLAN" ] || unverified "plan-unreadable"

if [ -z "$FOLDER" ]; then
  FOLDER="$(dirname -- "$PLAN")"
fi
[ -d "$FOLDER" ] || unverified "folder-missing"

# A document smaller than this cannot carry a worked contract, so a link to one is
# reported the same way a missing file is. Roughly a title plus a sentence.
STUB_BYTES=200

# Phrases that name a future author instead of a form. Literals this script owns.
DEFERRAL_PHRASES=(
  "authored during the build"
  "TBD at build"
  "authored later"
  "defined during implementation"
  "to be authored"
)

# Resolution values that restate the question. Compared after normalization, never
# matched as patterns.
TAUTOLOGIES=(
  ""
  "…"
  "..."
  "—"
  "-"
  "tbd"
  "resolved"
  "resolution"
  "when resolved"
  "it is resolved"
  "this is resolved"
  "the item is resolved"
  "when it is resolved"
)

# Emit every line of the plan that sits outside a fenced block, numbered with its real
# line number. The toggle is evaluated as the file is walked, so a nested or
# unterminated fence cannot disagree with a later filter.
outside_fences() {
  awk '
    /^[[:space:]]*```/ { fenced = !fenced; next }
    !fenced { printf "%d\t%s\n", NR, $0 }
  ' "$PLAN"
}

# Strip markdown emphasis, HTML comments, and surrounding space from a field value.
normalize() {
  printf '%s' "$1" |
    sed -E 's/<!--.*-->//g; s/[*`_]//g; s/^[[:space:]]+//; s/[[:space:]]+$//' |
    tr '[:upper:]' '[:lower:]'
}

deferral_phrase=()
unresolved_open_item=()
missing_artifact=()
stub_artifact=()

PROSE="$(outside_fences)"

# 1. Deferral phrases, matched case-insensitively as fixed strings.
for phrase in "${DEFERRAL_PHRASES[@]}"; do
  while IFS=$'\t' read -r lineno _; do
    [ -n "$lineno" ] && deferral_phrase+=("line=$lineno $phrase")
  done < <(printf '%s\n' "$PROSE" | grep -iF -- "$phrase" || true)
done

# 2. Open Items whose Resolves when value restates the question. An entry runs from its
#    own OI bullet to the next one or to the next heading.
while IFS= read -r entry; do
  id="${entry%%$'\t'*}"
  value="${entry#*$'\t'}"
  norm="$(normalize "$value")"
  for t in "${TAUTOLOGIES[@]}"; do
    if [ "$norm" = "$t" ]; then
      unresolved_open_item+=("$id field=Resolves-when")
      break
    fi
  done
done < <(printf '%s\n' "$PROSE" | cut -f2- | awk '
  /^[[:space:]]*-[[:space:]]+\*\*OI-[0-9]+/ {
    match($0, /OI-[0-9]+/)
    id = substr($0, RSTART, RLENGTH)
    seen = 0
    next
  }
  /^#/ { id = "" }
  id != "" && !seen && index($0, "**Resolves when:**") {
    sub(/.*\*\*Resolves when:\*\*[[:space:]]*/, "")
    printf "%s\t%s\n", id, $0
    seen = 1
  }
')

# 3. Referenced documents that do not resolve, or are too small to carry a contract.
#    Only relative markdown-link targets ending in .md are checked: those are documents
#    the plan promises a reader can open.
while IFS=$'\t' read -r lineno target; do
  [ -n "$target" ] || continue
  path="$FOLDER/$target"
  if [ ! -f "$path" ]; then
    missing_artifact+=("$target line=$lineno")
    continue
  fi
  bytes="$(wc -c <"$path" | tr -d '[:space:]')"
  if [ "$bytes" -lt "$STUB_BYTES" ]; then
    stub_artifact+=("$target bytes=$bytes")
  fi
done < <(printf '%s\n' "$PROSE" | awk '
  {
    tab = index($0, "\t")
    line = substr($0, 1, tab - 1)
    rest = substr($0, tab + 1)
    while (match(rest, /\]\([^)]+\)/)) {
      target = substr(rest, RSTART + 2, RLENGTH - 3)
      rest = substr(rest, RSTART + RLENGTH)
      sub(/#.*$/, "", target)
      if (target ~ /^[a-zA-Z][a-zA-Z0-9+.-]*:/) continue
      if (target ~ /^\//) continue
      if (target !~ /\.md$/) continue
      printf "%s\t%s\n", line, target
    }
  }
')

total=$((${#deferral_phrase[@]} + ${#unresolved_open_item[@]} + ${#missing_artifact[@]} + ${#stub_artifact[@]}))

if [ "$total" -eq 0 ]; then
  echo "result: passed"
  exit 0
fi

echo "result: failed"
for d in ${deferral_phrase[@]+"${deferral_phrase[@]}"}; do echo "deferral-phrase: $d"; done
for o in ${unresolved_open_item[@]+"${unresolved_open_item[@]}"}; do echo "unresolved-open-item: $o"; done
for m in ${missing_artifact[@]+"${missing_artifact[@]}"}; do echo "missing-artifact: $m"; done
for s in ${stub_artifact[@]+"${stub_artifact[@]}"}; do echo "stub-artifact: $s"; done
exit 1
