#!/usr/bin/env bats
#
# Sanity check: proves the Bats harness and the CI test job actually run.
# Real script tests sit next to the script they cover (e.g.
# scripts/foo.sh alongside scripts/foo.bats); test/ keeps harness-level
# checks like this one, plus repository-wide structural invariants that
# cover no single script.

@test "sanity: arithmetic works (2 + 2 == 4)" {
  result=$((2 + 2))
  [ "$result" -eq 4 ]
}
