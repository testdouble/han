#!/usr/bin/env bats
#
# Sanity check: proves the Bats harness and the CI test job actually run.
# Script tests sit next to the scripts they cover, as `*.bats` files in the
# script's own directory; this test/ dir is for harness-level checks like this.

@test "sanity: arithmetic works (2 + 2 == 4)" {
  result=$((2 + 2))
  [ "$result" -eq 4 ]
}
