#!/usr/bin/env bats
#
# Tests for check-contract-pinning.sh: the three-outcome contract, the four distinct
# failure classes (a deferral phrase, a tautological Open Item resolution, a referenced
# document that does not exist, and one too small to carry a contract), and the
# fenced-block exclusion that keeps a worked example from tripping the phrase check.

setup() {
  SRC="$BATS_TEST_DIRNAME/check-contract-pinning.sh"
  TMP="$(mktemp -d)"
  PLAN="$TMP/feature-implementation-plan.md"
  mkdir -p "$TMP/refs"
}

teardown() {
  rm -rf "$TMP"
}

# A plan file holding the given body lines under a heading.
plan_with() {
  {
    echo "# Feature Implementation Plan: test"
    echo
    echo "## Implementation Approach"
    echo
    printf '%s\n' "$@"
  } >"$PLAN"
}

# A referenced document large enough to count as real.
real_doc() {
  {
    echo "# $1"
    echo
    head -c 400 </dev/zero | tr '\0' 'x'
    echo
  } >"$TMP/refs/$1.md"
}

get() {
  printf '%s\n' "$1" | awk -F': ' -v k="$2" '$1 == k { print $2; exit }'
}

count() {
  printf '%s\n' "$1" | awk -F': ' -v k="$2" '$1 == k { n++ } END { print n + 0 }'
}

@test "a plan that pins its contract passes" {
  real_doc schema
  plan_with \
    "Each entry is one line, written as the token, a colon, and the work item id." \
    "" \
    '```' \
    "- started: W-1" \
    '```' \
    "" \
    "The field layout lives in [the schema doc](refs/schema.md)." \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 0 ]
  [ "$(get "$output" result)" = "passed" ]
}

@test "a deferral phrase fails and names the line and the phrase" {
  plan_with \
    "The entry grammar is authored during the build." \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 1 ]
  [ "$(get "$output" result)" = "failed" ]
  [ "$(count "$output" deferral-phrase)" -eq 1 ]
  [ "$(get "$output" deferral-phrase)" = "line=5 authored during the build" ]
}

@test "a deferral phrase inside a fenced block is a worked example, not a deferral" {
  plan_with \
    "The entry grammar is fixed:" \
    "" \
    '```' \
    "- started: W-1   # TBD at build" \
    '```' \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 0 ]
  [ "$(get "$output" result)" = "passed" ]
}

@test "an Open Item whose resolution restates the question fails" {
  plan_with \
    "Nothing to see." \
    "" \
    "## Open Items" \
    "" \
    "- **OI-1:** What is the entry line grammar?" \
    "  - **Resolves when:** resolved" \
    "  - **Blocks implementation:** No" \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 1 ]
  [ "$(count "$output" unresolved-open-item)" -eq 1 ]
  [ "$(get "$output" unresolved-open-item)" = "OI-1 field=Resolves-when" ]
}

@test "an Open Item with a falsifiable resolution condition passes" {
  plan_with \
    "Nothing to see." \
    "" \
    "## Open Items" \
    "" \
    "- **OI-1:** Which retention window applies?" \
    "  - **Resolves when:** the ops team confirms the audit retention requirement in writing." \
    "  - **Blocks implementation:** No" \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 0 ]
  [ "$(get "$output" result)" = "passed" ]
}

@test "a referenced document that does not exist is a separate failure from a phrase" {
  plan_with \
    "The grammar lives in [the protocol doc](refs/protocol.md)." \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 1 ]
  [ "$(count "$output" missing-artifact)" -eq 1 ]
  [ "$(get "$output" missing-artifact)" = "refs/protocol.md line=5" ]
  [ "$(count "$output" deferral-phrase)" -eq 0 ]
}

@test "a referenced document too small to carry a contract is reported with its size" {
  printf 'stub\n' >"$TMP/refs/protocol.md"
  plan_with \
    "The grammar lives in [the protocol doc](refs/protocol.md)." \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 1 ]
  [ "$(count "$output" stub-artifact)" -eq 1 ]
  [ "$(get "$output" stub-artifact)" = "refs/protocol.md bytes=5" ]
  [ "$(count "$output" missing-artifact)" -eq 0 ]
}

@test "an external URL and an anchor-only link are not documents to resolve" {
  plan_with \
    "See [the spec](https://example.com/contract.md) and [above](#implementation-approach)." \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 0 ]
  [ "$(get "$output" result)" = "passed" ]
}

@test "a link carrying an anchor resolves against the file, not the fragment" {
  real_doc schema
  plan_with \
    "See [the layout](refs/schema.md#field-layout)." \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 0 ]
  [ "$(get "$output" result)" = "passed" ]
}

@test "a plan folder given explicitly is what relative links resolve against" {
  real_doc schema
  mkdir -p "$TMP/elsewhere"
  plan_with "See [the layout](refs/schema.md)." ""
  mv "$PLAN" "$TMP/elsewhere/plan.md"

  run "$SRC" "$TMP/elsewhere/plan.md" "$TMP"
  [ "$status" -eq 0 ]
  [ "$(get "$output" result)" = "passed" ]

  run "$SRC" "$TMP/elsewhere/plan.md"
  [ "$status" -eq 1 ]
  [ "$(get "$output" missing-artifact)" = "refs/schema.md line=5" ]
}

@test "a missing plan cannot be verified and is not a failure" {
  run "$SRC" "$TMP/absent.md"
  [ "$status" -eq 2 ]
  [ "$(get "$output" result)" = "unverified" ]
  [ "$(get "$output" reason)" = "plan-missing" ]
}

@test "a missing plan folder cannot be verified" {
  plan_with "Nothing to see." ""

  run "$SRC" "$PLAN" "$TMP/absent-folder"
  [ "$status" -eq 2 ]
  [ "$(get "$output" reason)" = "folder-missing" ]
}

@test "every failure class is reported in one run" {
  printf 'stub\n' >"$TMP/refs/stub.md"
  plan_with \
    "The grammar is authored during the build." \
    "" \
    "See [gone](refs/gone.md) and [stub](refs/stub.md)." \
    "" \
    "## Open Items" \
    "" \
    "- **OI-1:** What is the grammar?" \
    "  - **Resolves when:** resolved" \
    ""

  run "$SRC" "$PLAN"
  [ "$status" -eq 1 ]
  [ "$(count "$output" deferral-phrase)" -eq 1 ]
  [ "$(count "$output" unresolved-open-item)" -eq 1 ]
  [ "$(count "$output" missing-artifact)" -eq 1 ]
  [ "$(count "$output" stub-artifact)" -eq 1 ]
}

# The drift assertion. Two skills carry this check because a written authoring rule
# requires each skill to own its scripts. Nothing else stops the copies diverging.
@test "the two per-skill copies are byte-identical" {
  local planning
  planning="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"
  local copies=(
    "$planning/skills/plan-implementation/scripts/check-contract-pinning.sh"
    "$planning/skills/iterative-plan-review/scripts/check-contract-pinning.sh"
  )

  for copy in "${copies[@]}"; do
    [ -f "$copy" ] || {
      echo "missing copy: $copy"
      return 1
    }
    diff "$SRC" "$copy" || {
      echo "copy drifted from the canonical script: $copy"
      return 1
    }
  done
}

# The phrase list is mirrored from the canonical rule. Nothing else stops the two
# disagreeing about what never closes a contract.
@test "every deferral phrase the script owns is named in the canonical rule" {
  local rule
  rule="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)/references/contract-pinning-rule.md"
  [ -f "$rule" ] || {
    echo "missing rule file: $rule"
    return 1
  }

  local phrases
  phrases="$(sed -n '/^DEFERRAL_PHRASES=(/,/^)/p' "$SRC" | sed -n 's/^  "\(.*\)"$/\1/p')"
  [ -n "$phrases" ]

  while IFS= read -r phrase; do
    grep -qiF -- "$phrase" "$rule" || {
      echo "phrase not in the canonical rule: $phrase"
      return 1
    }
  done <<<"$phrases"
}
