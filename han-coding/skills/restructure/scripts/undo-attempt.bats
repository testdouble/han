#!/usr/bin/env bats
#
# Tests for undo-attempt.sh: the undo restructure runs after every Mikado
# discovery attempt and after a failed unit. Each test builds a throwaway git
# repository under BATS_TEST_TMPDIR, so nothing touches this checkout.

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/undo-attempt.sh"
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO"
  cd "$REPO" || return 1
  git init -q
  git config user.email "test@example.com"
  git config user.name "Test"
  git config commit.gpgsign false
  printf 'build/\n' >.gitignore
  printf 'original\n' >tracked.txt
  mkdir -p nested
  printf 'original\n' >nested/module.txt
  git add -A
  git commit -qm "base"
  BASE=$(git rev-parse HEAD)
}

@test "restores edited tracked files to the base commit" {
  printf 'changed\n' >tracked.txt
  run bash "$SCRIPT" "$BASE"
  [ "$status" -eq 0 ]
  [ "$(cat tracked.txt)" = "original" ]
}

@test "restores a staged move back to its original path" {
  mkdir -p moved
  git mv nested/module.txt moved/module.txt
  run bash "$SCRIPT" "$BASE"
  [ "$status" -eq 0 ]
  [ -f nested/module.txt ]
  [ ! -e moved/module.txt ]
}

@test "removes files the attempt created and reports each one" {
  mkdir -p newdir
  printf 'new\n' >newdir/created.txt
  run bash "$SCRIPT" "$BASE"
  [ "$status" -eq 0 ]
  [ ! -e newdir/created.txt ]
  [[ "$output" == *"removed: newdir/created.txt"* ]]
}

@test "leaves ignored files in place" {
  mkdir -p build
  printf 'artifact\n' >build/output.txt
  printf 'changed\n' >tracked.txt
  run bash "$SCRIPT" "$BASE"
  [ "$status" -eq 0 ]
  [ -f build/output.txt ]
}

@test "leaves the tree clean" {
  printf 'changed\n' >tracked.txt
  printf 'new\n' >created.txt
  run bash "$SCRIPT" "$BASE"
  [ "$status" -eq 0 ]
  [ -z "$(git status --porcelain)" ]
}

@test "works when run from a subdirectory" {
  printf 'changed\n' >tracked.txt
  printf 'new\n' >nested/created.txt
  run bash -c 'cd nested && bash "$1" "$2"' _ "$SCRIPT" "$BASE"
  [ "$status" -eq 0 ]
  [ "$(cat tracked.txt)" = "original" ]
  [ ! -e nested/created.txt ]
}

@test "refuses and changes nothing when HEAD has moved" {
  printf 'committed\n' >tracked.txt
  git commit -qam "moved on"
  printf 'pending\n' >tracked.txt
  run bash "$SCRIPT" "$BASE"
  [ "$status" -eq 2 ]
  [ "$(cat tracked.txt)" = "pending" ]
}

@test "fails with a usage error when no commit is given" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
}

@test "fails when the argument is not a commit" {
  run bash "$SCRIPT" not-a-commit
  [ "$status" -eq 1 ]
}

@test "fails outside a git repository" {
  mkdir -p "$BATS_TEST_TMPDIR/plain"
  cd "$BATS_TEST_TMPDIR/plain"
  run bash "$SCRIPT" "$BASE"
  [ "$status" -eq 1 ]
}
