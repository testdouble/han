#!/usr/bin/env bats
#
# check-annotations.sh accounts for every slice heading in a work-items file:
# each one is publishable here, already published here, or surfaced. Nothing
# is silently passed over.
#
# A heading is in scope when it carries a symbolic ID (`## W-1 ...`), whatever
# follows it. Preamble prose headings never match that shape, so they cannot
# cause a false stop.

setup() {
  CHECK="${BATS_TEST_DIRNAME}/../han-github/skills/work-items-to-issues/scripts/check-annotations.sh"
  TMP="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP"
}

# --- clean files pass ---------------------------------------------------------

@test "passes a file whose slices are all unannotated" {
  cat > "$TMP/wi.md" <<'EOF'
# Work Items — Example

## W-1 — First slice
body
## W-2 — Second slice
body
EOF
  run "$CHECK" "$TMP/wi.md"
  [ "$status" -eq 0 ]
}

@test "passes a file whose slices were already published here" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 (#12) — Already published
body
## W-2 — Not yet published
body
EOF
  run "$CHECK" "$TMP/wi.md"
  [ "$status" -eq 0 ]
}

@test "ignores preamble headings that carry no symbolic ID" {
  cat > "$TMP/wi.md" <<'EOF'
# Work Items — Example

Work items are numbered W-N for cross-reference only.

## Shared reference artifacts

- [API contract](./contract.md#envelope)

## W-1 — First slice
body
EOF
  run "$CHECK" "$TMP/wi.md"
  [ "$status" -eq 0 ]
}

# --- foreign annotations are surfaced -----------------------------------------

@test "stops on a heading annotated by another tracker" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 — Fine
body
## W-2 (ACME-142) — Published to another tracker
body
EOF
  run "$CHECK" "$TMP/wi.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"W-2"* ]]
  [[ "$output" == *"ACME-142"* ]]
}

@test "names what the heading appears to be annotated by" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 (ENG-99) — Published to a different tracker
body
EOF
  run "$CHECK" "$TMP/wi.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"ENG-99"* ]]
}

@test "stops on a heading it cannot place even when it looks like nobody else's" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 - Hand-edited with the wrong dash
body
EOF
  run "$CHECK" "$TMP/wi.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"W-1"* ]]
}

@test "names every unrecognized heading, not just the first" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 (ACME-1) — First foreign
body
## W-2 — Fine
body
## W-3 (ENG-2) — Second foreign
body
## W-4 - Wrong dash
body
EOF
  run "$CHECK" "$TMP/wi.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"W-1"* ]]
  [[ "$output" == *"W-3"* ]]
  [[ "$output" == *"W-4"* ]]
}

@test "stops on a file published entirely to another tracker" {
  # The case the whole phase exists for: every heading is foreign-annotated, so
  # there is no recognizable unannotated slice to anchor on. This must surface,
  # not read as a file with nothing in it.
  cat > "$TMP/wi.md" <<'EOF'
# Work Items — Example

## W-1 (ACME-1) — First
body
## W-2 (ACME-2) — Second
body
EOF
  run "$CHECK" "$TMP/wi.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"W-1"* ]]
  [[ "$output" == *"W-2"* ]]
}

# --- every heading is accounted for -------------------------------------------

@test "reports counts that add up to every slice heading in the file" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 — Publishable
body
## W-2 (#7) — Already published here
body
## W-3 (ACME-3) — Foreign
body
EOF
  run "$CHECK" "$TMP/wi.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"1 publishable"* ]]
  [[ "$output" == *"1 already published"* ]]
  [[ "$output" == *"1 unrecognized"* ]]
}

# --- multi-file: nothing publishes anywhere -----------------------------------

@test "checks every file it is given, not just the first" {
  cat > "$TMP/a.md" <<'EOF'
## W-1 — Clean repo file
body
EOF
  cat > "$TMP/b.md" <<'EOF'
## W-2 (ACME-9) — Dirty repo file
body
EOF
  run "$CHECK" "$TMP/a.md" "$TMP/b.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"W-2"* ]]
  [[ "$output" == *"b.md"* ]]
}

@test "passes only when every file it is given is clean" {
  cat > "$TMP/a.md" <<'EOF'
## W-1 — Clean
body
EOF
  cat > "$TMP/b.md" <<'EOF'
## W-2 (#3) — Also clean
body
EOF
  run "$CHECK" "$TMP/a.md" "$TMP/b.md"
  [ "$status" -eq 0 ]
}

# --- input handling -----------------------------------------------------------

@test "fails loudly when a file does not exist" {
  run "$CHECK" "$TMP/nope.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "requires at least one file" {
  run "$CHECK"
  [ "$status" -ne 0 ]
}
