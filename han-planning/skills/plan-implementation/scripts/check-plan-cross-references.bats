#!/usr/bin/env bats
#
# Tests for check-plan-cross-references.sh: the three-outcome contract, the two failure
# classes (a companion field naming a plan section that is not there, and a plan citing a
# decision the log does not declare), the em-dash sentinel the iteration-history template
# defines as a filled value, and the fenced-block exclusion.

setup() {
  SRC="$BATS_TEST_DIRNAME/check-plan-cross-references.sh"
  TMP="$(mktemp -d)"
  PLAN="$TMP/feature-implementation-plan.md"
  LOG="$TMP/implementation-decision-log.md"
  HISTORY="$TMP/implementation-iteration-history.md"
}

teardown() {
  rm -rf "$TMP"
}

plan_with() {
  {
    echo "# Feature Implementation Plan: test"
    echo
    printf '%s\n' "$@"
  } >"$PLAN"
}

log_with() {
  {
    echo "# Implementation Decision Log: test"
    echo
    echo "## Full decisions"
    echo
    printf '%s\n' "$@"
  } >"$LOG"
}

history_with() {
  {
    echo "# Implementation Iteration History: test"
    echo
    printf '%s\n' "$@"
  } >"$HISTORY"
}

# A complete, consistent trio.
valid_trio() {
  plan_with \
    "## Outcome" \
    "" \
    "The thing works ([D-1]($(basename "$LOG")#d-1-rollout))." \
    "" \
    "## Work Units and Sequencing" \
    "" \
    "One unit."
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Decision:** Ship it." \
    "- **Referenced in plan:** Outcome, Work Units and Sequencing"
  history_with \
    "## R1: Parallel specialist review" \
    "" \
    "- **Decisions produced:** D-1" \
    "- **Changed in plan:** Outcome"
}

@test "a consistent trio passes" {
  valid_trio
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
  [[ "$output" == *"result: passed"* ]]
}

@test "a Referenced in plan section that is not a plan heading fails" {
  valid_trio
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Decision:** Ship it." \
    "- **Referenced in plan:** Outcome, Cut for Scope"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 1 ]
  [[ "$output" == *"result: failed"* ]]
  [[ "$output" == *"missing-plan-section: D-1 field=Referenced in plan section=cut for scope"* ]]
}

@test "a Changed in plan section that is not a plan heading fails" {
  valid_trio
  history_with \
    "## R1: Parallel specialist review" \
    "" \
    "- **Decisions produced:** D-1" \
    "- **Changed in plan:** Testing Strategy"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing-plan-section: R1 field=Changed in plan section=testing strategy"* ]]
}

@test "a plan citing a decision the log does not declare fails" {
  valid_trio
  plan_with \
    "## Outcome" \
    "" \
    "The thing works ([D-4](implementation-decision-log.md#d-4-missing))."
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing-decision: D-4 cited-by=plan"* ]]
}

@test "an em-dash is a filled value, not an empty field" {
  valid_trio
  history_with \
    "## R1: Parallel specialist review" \
    "" \
    "- **Decisions produced:** —" \
    "- **Changed in plan:** —"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
  [[ "$output" == *"result: passed"* ]]
}

@test "an unreplaced template comment is not a section name" {
  valid_trio
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Decision:** Ship it." \
    "- **Referenced in plan:** <!-- plan sections that cite this decision -->"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "a heading inside a fenced example is not a plan heading" {
  plan_with \
    "## Outcome" \
    "" \
    '```markdown' \
    "## Cut for Scope" \
    '```' \
    "" \
    "Real content."
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Referenced in plan:** Cut for Scope"
  history_with "## R1: Parallel specialist review" "" "- **Changed in plan:** Outcome"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing-plan-section: D-1 field=Referenced in plan section=cut for scope"* ]]
}

@test "a citation inside a fenced example is not a plan citation" {
  valid_trio
  plan_with \
    "## Outcome" \
    "" \
    '```markdown' \
    "Cite it as ([D-9](implementation-decision-log.md#d-9-example))." \
    '```' \
    "" \
    "## Work Units and Sequencing"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "a missing decision log is a failure, not an unverified result" {
  valid_trio
  rm "$LOG"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 1 ]
  [[ "$output" == *"result: failed"* ]]
  [[ "$output" == *"missing-artifact: decision-log"* ]]
}

@test "a missing iteration history is a failure" {
  valid_trio
  rm "$HISTORY"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing-artifact: history"* ]]
}

@test "a missing plan is a failure naming the plan" {
  valid_trio
  rm "$PLAN"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing-artifact: plan"* ]]
}

@test "an unreadable plan is unverified" {
  valid_trio
  chmod 000 "$PLAN"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  chmod 644 "$PLAN"
  [ "$status" -eq 2 ]
  [[ "$output" == *"result: unverified"* ]]
  [[ "$output" == *"reason: plan-unreadable"* ]]
}

@test "a trivial one-line decision bullet is a declared decision" {
  plan_with "## Outcome" "" "Works ([D-2](implementation-decision-log.md#d-2-naming))."
  {
    echo "# Implementation Decision Log: test"
    echo
    echo "## Trivial decisions"
    echo
    echo "- D-2: Naming — call it that. — Referenced in plan: Outcome."
  } >"$LOG"
  history_with "## R1: Parallel specialist review" "" "- **Changed in plan:** Outcome"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "heading comparison ignores case and surrounding whitespace" {
  valid_trio
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Referenced in plan:**   OUTCOME  ,  work units and sequencing  "
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "a semicolon separates section names, like a comma" {
  valid_trio
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Referenced in plan:** Outcome; Work Units and Sequencing"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "a trailing parenthetical qualifier is not part of the heading" {
  valid_trio
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Referenced in plan:** Outcome (the second paragraph), Work Units and Sequencing"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "a field value wrapped across lines is read whole" {
  valid_trio
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Referenced in plan:** Outcome, Work Units and" \
    "  Sequencing"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "a wrapped field value still reports a section that is not there" {
  valid_trio
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Referenced in plan:** Outcome, Testing" \
    "  Strategy"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 1 ]
  [[ "$output" == *"section=testing strategy"* ]]
}

@test "D1 in the plan resolves to D-1 in the log" {
  plan_with "## Outcome" "" "Works ([D1](implementation-decision-log.md#d-1-rollout))."
  log_with "### D-1: Rollout" "" "- **Referenced in plan:** Outcome"
  history_with "## R1: Review" "" "- **Changed in plan:** Outcome"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "the next bullet ends a field value" {
  valid_trio
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Referenced in plan:** Outcome" \
    "- **Dependent decisions:** Testing Strategy"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "a parenthetical that is part of the heading resolves" {
  plan_with "## Outcome" "" "Text." "" "## Deferred (YAGNI)" "" "Nothing."
  log_with "### D-1: Rollout" "" "- **Referenced in plan:** Outcome, Deferred (YAGNI)"
  history_with "## R1: Review" "" "- **Changed in plan:** Outcome"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "a separator inside a parenthetical does not split the name" {
  plan_with "## Outcome" "" "Text." "" "## Implementation Approach" "" "Text."
  log_with \
    "### D-1: Rollout" \
    "" \
    "- **Referenced in plan:** Implementation Approach (architecture, external interfaces), Outcome"
  history_with "## R1: Review" "" "- **Changed in plan:** Outcome"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 0 ]
}

@test "a qualified name whose base heading is absent still fails" {
  valid_trio
  log_with "### D-1: Rollout" "" "- **Referenced in plan:** Testing Strategy (the unit table)"
  run bash "$SRC" "$PLAN" "$LOG" "$HISTORY"
  [ "$status" -eq 1 ]
  [[ "$output" == *"section=testing strategy (the unit table)"* ]]
}
