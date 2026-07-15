#!/usr/bin/env bats
#
# Tests for review-skill-or-agent's detect-git-context.sh: the Layer-1
# git-context contract (git availability, current branch, default branch, and
# the committed-changes-vs-default listing or its `changed-files: none`
# fallback). Mode-B (uncommitted) detection, changed-file->artifact mapping, PR
# resolution, and the candidate list are Layer-2 skill-body logic and are not
# exercised here.

setup() {
  SRC="$BATS_TEST_DIRNAME/../han-experimental/skills/review-skill-or-agent/scripts/detect-git-context.sh"
  TMP="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP"
}

# Extract the value of the first `key: value` line matching $2 from output $1.
get() {
  printf '%s\n' "$1" | awk -F': ' -v k="$2" '$1==k{print $2; exit}'
}

# Initialize a git repo at $1 with a deterministic identity and one base commit.
git_init() {
  git -C "$1" init -q
  git -C "$1" config user.email a@b.c
  git -C "$1" config user.name tester
  git -C "$1" commit -q --allow-empty -m base
}

# Point a fake origin/HEAD at a ref recording the current commit, so the script's
# `git symbolic-ref refs/remotes/origin/HEAD` resolves without a real remote.
set_origin_default() {
  git -C "$1" update-ref "refs/remotes/origin/$2" "$(git -C "$1" rev-parse HEAD)"
  git -C "$1" symbolic-ref refs/remotes/origin/HEAD "refs/remotes/origin/$2"
}

@test "lists committed changes against the default branch when the branch is ahead" {
  git_init "$TMP"
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  echo x >"$TMP/newfile.txt"
  git -C "$TMP" add newfile.txt
  git -C "$TMP" commit -q -m add
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  [ "$(get "$output" git-available)" = true ]
  [ "$(get "$output" default-branch)" = origin/main ]
  [[ "$output" == *"changed-files-start"* ]]
  [[ "$output" == *"newfile.txt"* ]]
  [[ "$output" == *"changed-files-end"* ]]
}

@test "reports git unavailable when git is not on PATH" {
  bash_bin="$(command -v bash)"
  cd "$TMP"
  run env PATH= "$bash_bin" "$SRC"
  [ "$(get "$output" git-available)" = false ]
  [ "$(get "$output" branch)" = none ]
  [ "$(get "$output" default-branch)" = none ]
  [ "$(get "$output" changed-files)" = none ]
}

@test "reports git unavailable when run outside a work tree" {
  cd "$TMP"
  run "$SRC"
  [ "$(get "$output" git-available)" = false ]
}

@test "reports no default branch and no changed files when the repo has no origin/HEAD" {
  git_init "$TMP"
  cd "$TMP"
  run "$SRC"
  [ "$(get "$output" git-available)" = true ]
  [ "$(get "$output" default-branch)" = none ]
  [ "$(get "$output" changed-files)" = none ]
}

@test "reports no changed files when the branch has no committed diff against the default" {
  git_init "$TMP"
  set_origin_default "$TMP" main
  cd "$TMP"
  run "$SRC"
  [ "$(get "$output" git-available)" = true ]
  [ "$(get "$output" default-branch)" = origin/main ]
  [ "$(get "$output" changed-files)" = none ]
}

@test "reports no current branch name in detached HEAD" {
  git_init "$TMP"
  git -C "$TMP" commit -q --allow-empty -m second
  git -C "$TMP" checkout -q --detach HEAD
  cd "$TMP"
  run "$SRC"
  [ "$(get "$output" git-available)" = true ]
  [ "$(get "$output" branch)" = none ]
}
