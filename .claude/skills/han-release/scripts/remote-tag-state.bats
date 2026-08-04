#!/usr/bin/env bats
#
# Tests for remote-tag-state.sh: the four-state contract, the annotated-tag peel that
# the classification depends on, tag-kind independence, argument order, and the
# unreachable-remote error.
#
# The fixture is two real repositories on disk, a bare one standing in for the remote.
# No mock of the tagging command and no marketplace fixture are needed, because this
# script only ever reads git.

setup() {
  SRC="$BATS_TEST_DIRNAME/remote-tag-state.sh"
  TMP="$(mktemp -d)"
  REMOTE="$TMP/remote.git"
  WORK="$TMP/work"

  git init --quiet --bare "$REMOTE"
  git init --quiet "$WORK"

  cd "$WORK" || return 1
  git config user.email "test@example.com"
  git config user.name "Test"
  git config commit.gpgsign false
  git config tag.gpgsign false
  git remote add origin "$REMOTE"

  echo one >file.txt
  git add file.txt
  git commit --quiet --message "first"
  FIRST="$(git rev-parse HEAD)"

  echo two >>file.txt
  git commit --quiet --all --message "second"
  SECOND="$(git rev-parse HEAD)"

  git push --quiet origin HEAD:refs/heads/main
}

teardown() {
  cd / || true
  rm -rf "$TMP"
}

# The state column for tag $2 in output $1.
state_of() {
  printf '%s\n' "$1" | awk -F'\t' -v t="$2" '$1 == t { print $2; exit }'
}

# The sha column for tag $2 in output $1.
sha_of() {
  printf '%s\n' "$1" | awk -F'\t' -v t="$2" '$1 == t { print $3; exit }'
}

@test "a tag on neither the remote nor the machine is absent" {
  run "$SRC" "$SECOND" "never-made--v1.0.0"
  [ "$status" -eq 0 ]
  [ "$(state_of "$output" "never-made--v1.0.0")" = "absent" ]
  [ "$(sha_of "$output" "never-made--v1.0.0")" = "-" ]
}

@test "an annotated tag pushed at the release commit reads remote-at-commit" {
  git tag --annotate "han--v5.0.0" --message "han 5.0.0"
  git push --quiet origin "refs/tags/han--v5.0.0"

  run "$SRC" "$SECOND" "han--v5.0.0"
  [ "$status" -eq 0 ]
  [ "$(state_of "$output" "han--v5.0.0")" = "remote-at-commit" ]
  [ "$(sha_of "$output" "han--v5.0.0")" = "$SECOND" ]
}

# This is the case the whole script exists for. `git ls-remote` reports the tag object
# for an annotated tag, so a classification that skipped the peel would call this
# remote-at-other-commit and stop a release that is perfectly fine.
@test "the annotated tag's reported sha is the commit, not the tag object" {
  git tag --annotate "han--v5.0.0" --message "han 5.0.0"
  git push --quiet origin "refs/tags/han--v5.0.0"

  tag_object="$(git rev-parse "han--v5.0.0")"
  [ "$tag_object" != "$SECOND" ]

  run "$SRC" "$SECOND" "han--v5.0.0"
  [ "$(sha_of "$output" "han--v5.0.0")" = "$SECOND" ]
  [ "$(sha_of "$output" "han--v5.0.0")" != "$tag_object" ]
}

@test "a lightweight tag classifies the same way an annotated one does" {
  git tag "han-core--v3.0.0"
  git push --quiet origin "refs/tags/han-core--v3.0.0"

  run "$SRC" "$SECOND" "han-core--v3.0.0"
  [ "$status" -eq 0 ]
  [ "$(state_of "$output" "han-core--v3.0.0")" = "remote-at-commit" ]
  [ "$(sha_of "$output" "han-core--v3.0.0")" = "$SECOND" ]
}

@test "a tag on the remote at a different commit reads remote-at-other-commit" {
  git tag --annotate "han--v5.0.0" --message "han 5.0.0" "$FIRST"
  git push --quiet origin "refs/tags/han--v5.0.0"

  run "$SRC" "$SECOND" "han--v5.0.0"
  [ "$status" -eq 0 ]
  [ "$(state_of "$output" "han--v5.0.0")" = "remote-at-other-commit" ]
  [ "$(sha_of "$output" "han--v5.0.0")" = "$FIRST" ]
}

@test "a tag created but never pushed reads local-only" {
  git tag --annotate "han-github--v2.3.0" --message "han-github 2.3.0"

  run "$SRC" "$SECOND" "han-github--v2.3.0"
  [ "$status" -eq 0 ]
  [ "$(state_of "$output" "han-github--v2.3.0")" = "local-only" ]
  [ "$(sha_of "$output" "han-github--v2.3.0")" = "$SECOND" ]
}

# The state a re-run after a failed push lands in. The remote copy governs, so the
# stale local tag must not read as local-only and must not be pushed again.
@test "a tag both local and on the remote is classified by the remote" {
  git tag --annotate "han--v5.0.0" --message "han 5.0.0" "$FIRST"
  git push --quiet origin "refs/tags/han--v5.0.0"

  run "$SRC" "$SECOND" "han--v5.0.0"
  [ "$(state_of "$output" "han--v5.0.0")" = "remote-at-other-commit" ]
}

@test "every requested tag is classified, in the order given" {
  git tag --annotate "han--v5.0.0" --message "han 5.0.0"
  git push --quiet origin "refs/tags/han--v5.0.0"
  git tag --annotate "han-core--v3.0.0" --message "han-core 3.0.0"

  run "$SRC" "$SECOND" "han--v5.0.0" "han-core--v3.0.0" "han-linear--v1.1.0"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "$(printf '%s\n' "${lines[0]}" | cut -f1)" = "han--v5.0.0" ]
  [ "$(printf '%s\n' "${lines[1]}" | cut -f1)" = "han-core--v3.0.0" ]
  [ "$(printf '%s\n' "${lines[2]}" | cut -f1)" = "han-linear--v1.1.0" ]
  [ "$(state_of "$output" "han--v5.0.0")" = "remote-at-commit" ]
  [ "$(state_of "$output" "han-core--v3.0.0")" = "local-only" ]
  [ "$(state_of "$output" "han-linear--v1.1.0")" = "absent" ]
}

@test "a tag name that is a prefix of another does not borrow its state" {
  git tag --annotate "han-core--v3.0.0" --message "han-core 3.0.0"
  git push --quiet origin "refs/tags/han-core--v3.0.0"

  run "$SRC" "$SECOND" "han-core--v3.0"
  [ "$status" -eq 0 ]
  [ "$(state_of "$output" "han-core--v3.0")" = "absent" ]
}

@test "an unreachable remote is an error, never a classification" {
  git remote set-url origin "$TMP/does-not-exist.git"

  run "$SRC" "$SECOND" "han--v5.0.0"
  [ "$status" -eq 2 ]
  [[ "$output" == *"could not read tags from remote"* ]]
}

@test "no tag argument is an error" {
  run "$SRC" "$SECOND"
  [ "$status" -eq 2 ]
  [[ "$output" == *"at least one tag name required"* ]]
}

@test "a missing release commit argument is an error" {
  run "$SRC"
  [ "$status" -ne 0 ]
}
