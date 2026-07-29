#!/usr/bin/env bats
#
# Sanity check: proves the Bats harness and the CI test job actually run.
# Real script tests sit next to the script they cover (e.g.
# scripts/foo.sh alongside scripts/foo.bats); test/ keeps only
# harness-level checks like this one.

@test "sanity: arithmetic works (2 + 2 == 4)" {
  result=$((2 + 2))
  [ "$result" -eq 4 ]
}
