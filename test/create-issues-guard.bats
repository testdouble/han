#!/usr/bin/env bats
#
# create-issues.sh examines the whole file before creating the first issue.
# A heading it cannot place stops the run before anything reaches the tracker,
# so an annotation late in the file is never preceded by issues already created.
#
# `gh` is stubbed on PATH: these tests assert what the script would send, and
# must never reach the network.

setup() {
  SCRIPT="${BATS_TEST_DIRNAME}/../han-github/skills/work-items-to-issues/scripts/create-issues.sh"
  TMP="$(mktemp -d)"
  GH_LOG="$TMP/gh-calls.log"
  export GH_LOG

  # Stub gh: log every invocation, and answer `issue create` with a plausible URL.
  mkdir -p "$TMP/bin"
  cat > "$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
echo "$*" >> "$GH_LOG"
if [ "${1:-}" = "issue" ] && [ "${2:-}" = "create" ]; then
  echo "https://github.com/acme/repo/issues/501"
fi
EOF
  chmod +x "$TMP/bin/gh"
  PATH="$TMP/bin:$PATH"
  export PATH
  : > "$GH_LOG"
}

teardown() {
  rm -rf "$TMP"
}

gh_call_count() {
  if [ -s "$GH_LOG" ]; then wc -l < "$GH_LOG" | tr -d ' '; else echo 0; fi
}

@test "creates nothing when a heading is annotated by another tracker" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 — Would publish fine
body
## W-2 (ACME-142) — Published to another tracker
body
EOF
  run "$SCRIPT" "$TMP/wi.md" acme/repo
  [ "$status" -ne 0 ]
  [ "$(gh_call_count)" -eq 0 ]
}

@test "the file is left untouched when the run stops" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 — Would publish fine
body
## W-2 (ACME-142) — Foreign
body
EOF
  before="$(cat "$TMP/wi.md")"
  run "$SCRIPT" "$TMP/wi.md" acme/repo
  [ "$status" -ne 0 ]
  [ "$(cat "$TMP/wi.md")" = "$before" ]
}

@test "a foreign annotation last in the file still stops the first item being created" {
  # The ordering the guard exists for: without examine-first, W-1 and W-2 would
  # already be issues by the time the publisher reached W-3.
  cat > "$TMP/wi.md" <<'EOF'
## W-1 — First
body
## W-2 — Second
body
## W-3 (ENG-7) — Foreign, last in the file
body
EOF
  run "$SCRIPT" "$TMP/wi.md" acme/repo
  [ "$status" -ne 0 ]
  [ "$(gh_call_count)" -eq 0 ]
}

@test "names the offending heading when it stops" {
  cat > "$TMP/wi.md" <<'EOF'
## W-9 (ACME-3) — Foreign
body
EOF
  run "$SCRIPT" "$TMP/wi.md" acme/repo
  [ "$status" -ne 0 ]
  [[ "$output" == *"W-9"* ]]
  [[ "$output" == *"ACME-3"* ]]
}

@test "still publishes a clean file" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 — A clean slice
body
EOF
  run "$SCRIPT" "$TMP/wi.md" acme/repo
  [ "$status" -eq 0 ]
  grep -q "issue create" "$GH_LOG"
  grep -q '^## W-1 (#501) — A clean slice$' "$TMP/wi.md"
}

@test "still skips a file already published here without creating anything" {
  cat > "$TMP/wi.md" <<'EOF'
## W-1 (#12) — Already published here
body
EOF
  run "$SCRIPT" "$TMP/wi.md" acme/repo
  [ "$status" -eq 0 ]
  run grep -c "issue create" "$GH_LOG"
  [ "$output" -eq 0 ]
}

@test "does not stop on preamble headings that carry no symbolic ID" {
  cat > "$TMP/wi.md" <<'EOF'
# Work Items — Example

## Shared reference artifacts

- [contract](./c.md)

## W-1 — A clean slice
body
EOF
  run "$SCRIPT" "$TMP/wi.md" acme/repo
  [ "$status" -eq 0 ]
  grep -q "issue create" "$GH_LOG"
}
