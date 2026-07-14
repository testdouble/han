#!/usr/bin/env bats
#
# Sanity check: proves the Bats harness and the CI test job actually run.
# Real script tests land as their own test/*.bats files.

@test "sanity: arithmetic works (2 + 2 == 4)" {
  result=$((2 + 2))
  [ "$result" -eq 4 ]
}
