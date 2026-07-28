#!/usr/bin/env bats
#
# Tests for review-skill-or-agent's build-target-diff.sh: the change-scope helper
# that builds a target-scoped full delta (merge-base-to-working-tree, including
# untracked files) and reports `diff-empty`. Encodes the CRIT-001 fix — the delta
# is scoped to the target and captures uncommitted edits even when the branch
# carries unrelated committed changes elsewhere.

setup() {
  SRC="$BATS_TEST_DIRNAME/build-target-diff.sh"
  TMP="$(mktemp -d)"
  OUT="$TMP/diff.txt"
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
# default-branch argument resolves without a real remote.
set_origin_default() {
  git -C "$1" update-ref "refs/remotes/origin/$2" "$(git -C "$1" rev-parse HEAD)"
  git -C "$1" symbolic-ref refs/remotes/origin/HEAD "refs/remotes/origin/$2"
}

@test "exits 2 when required arguments are missing" {
  run "$SRC" skills/tgt
  [ "$status" -eq 2 ]
}

@test "exits 2 when run outside a git work tree" {
  cd "$TMP"
  run "$SRC" skills/tgt origin/main "$OUT"
  [ "$status" -eq 2 ]
}

@test "reports diff-empty when only files outside the target changed" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  echo x >"$TMP/unrelated.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m other
  cd "$TMP"
  run "$SRC" skills/tgt origin/main "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = true ]
}

@test "captures a committed change to the target against the default branch" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  echo changed >>"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" commit -qam edit
  cd "$TMP"
  run "$SRC" skills/tgt origin/main "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q changed "$OUT"
}

@test "captures an uncommitted target edit even when the branch's committed changes are unrelated" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt" "$TMP/other"
  echo base >"$TMP/skills/tgt/SKILL.md"
  echo o >"$TMP/other/f.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  # Unrelated committed change on the branch, outside the target:
  echo more >>"$TMP/other/f.txt"
  git -C "$TMP" commit -qam unrelated
  # The target's own edit is only uncommitted:
  echo pending >>"$TMP/skills/tgt/SKILL.md"
  cd "$TMP"
  run "$SRC" skills/tgt origin/main "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q pending "$OUT"
  ! grep -q 'other/f.txt' "$OUT"
}

@test "includes an untracked new file under the target" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  mkdir -p "$TMP/skills/tgt/references"
  echo newref >"$TMP/skills/tgt/references/new.md"
  cd "$TMP"
  run "$SRC" skills/tgt origin/main "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q newref "$OUT"
}

@test "resolves the default branch from origin/HEAD when the argument is none" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  echo committed >>"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" commit -qam edit
  cd "$TMP"
  run "$SRC" skills/tgt none "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q committed "$OUT"
}

@test "falls back to the working tree vs HEAD when no default branch is resolvable" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  echo pending >>"$TMP/skills/tgt/SKILL.md"
  cd "$TMP"
  run "$SRC" skills/tgt none "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q pending "$OUT"
}

@test "captures a staged file under the target in a zero-commit repo (unborn HEAD)" {
  git -C "$TMP" init -q
  git -C "$TMP" config user.email a@b.c
  git -C "$TMP" config user.name tester
  mkdir -p "$TMP/skills/tgt"
  echo stagedcontent >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add skills/tgt/SKILL.md
  cd "$TMP"
  run "$SRC" skills/tgt none "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q stagedcontent "$OUT"
}

@test "includes an untracked file under the target whose name is non-ASCII" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  printf 'cafecontent\n' >"$TMP/skills/tgt/café.md"
  cd "$TMP"
  run "$SRC" skills/tgt origin/main "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q cafecontent "$OUT"
}

@test "handles an untracked target path that starts with a dash" {
  git_init "$TMP"
  echo base >"$TMP/placeholder"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  printf 'dashcontent\n' >"$TMP/-dashfile.md"
  cd "$TMP"
  run "$SRC" ./-dashfile.md origin/main "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q dashcontent "$OUT"
}

@test "creates the out-file's parent directory when it does not exist" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  echo pending >>"$TMP/skills/tgt/SKILL.md"
  cd "$TMP"
  run "$SRC" skills/tgt origin/main "$TMP/missing-dir/diff.txt"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q pending "$TMP/missing-dir/diff.txt"
}

@test "scopes correctly when invoked from a subdirectory of the repo" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt" "$TMP/sub"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  echo pending >>"$TMP/skills/tgt/SKILL.md"
  cd "$TMP/sub"
  run "$SRC" skills/tgt origin/main "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q pending "$OUT"
}

@test "excludes an untracked file outside the target" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt" "$TMP/other"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  printf 'intargetuntracked\n' >"$TMP/skills/tgt/newref.md"
  printf 'outsidecontent\n' >"$TMP/other/untracked.txt"
  cd "$TMP"
  run "$SRC" skills/tgt origin/main "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q intargetuntracked "$OUT"
  ! grep -q outsidecontent "$OUT"
}

@test "diffs against the merge-base, not the advanced default-branch tip" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  FORK=$(git -C "$TMP" rev-parse HEAD)
  git -C "$TMP" checkout -q -b feature
  echo featureedit >>"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" commit -qam feat
  # Advance origin/main past the fork point with its own under-target commit:
  git -C "$TMP" checkout -q -b upstream "$FORK"
  echo upstreamonly >>"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" commit -qam upstream
  git -C "$TMP" update-ref refs/remotes/origin/main "$(git -C "$TMP" rev-parse HEAD)"
  git -C "$TMP" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
  git -C "$TMP" checkout -q feature
  cd "$TMP"
  run "$SRC" skills/tgt origin/main "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q featureedit "$OUT"
  ! grep -q upstreamonly "$OUT"
}

@test "honors the passed default branch over a different origin/HEAD" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  FORK=$(git -C "$TMP" rev-parse HEAD)
  git -C "$TMP" checkout -q -b feature
  echo featureedit >>"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" commit -qam feat
  TIP=$(git -C "$TMP" rev-parse HEAD)
  # Passed default sits at the fork point; origin/HEAD sits at the feature tip
  # (which, if wrongly used, would make the delta empty).
  git -C "$TMP" update-ref refs/remotes/origin/release "$FORK"
  git -C "$TMP" update-ref refs/remotes/origin/main "$TIP"
  git -C "$TMP" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
  cd "$TMP"
  run "$SRC" skills/tgt origin/release "$OUT"
  [ "$status" -eq 0 ]
  [ "$(get "$output" diff-empty)" = false ]
  grep -q featureedit "$OUT"
}

@test "exits non-zero when the tracked diff command fails instead of reporting empty" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  set_origin_default "$TMP" main
  cd "$TMP"
  # A target path outside the work tree makes `git diff -- <path>` fatal; the
  # script must surface that, not swallow it into a false diff-empty: true.
  run "$SRC" /nonexistent/outside/path origin/main "$OUT"
  [ "$status" -ne 0 ]
  [ "$(get "$output" diff-empty)" != true ]
}

@test "exits non-zero when merge-base with a known default branch is unavailable" {
  git_init "$TMP"
  mkdir -p "$TMP/skills/tgt"
  echo base >"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m seed
  ORIG=$(git -C "$TMP" branch --show-current)
  # An unrelated (orphan) history shares no merge-base with HEAD — the same
  # condition a shallow clone produces when the fork point is beyond the graft.
  git -C "$TMP" checkout -q --orphan unrelated
  git -C "$TMP" commit -q --allow-empty -m orphan
  git -C "$TMP" update-ref refs/remotes/origin/weird "$(git -C "$TMP" rev-parse HEAD)"
  git -C "$TMP" checkout -q "$ORIG"
  echo committedchange >>"$TMP/skills/tgt/SKILL.md"
  git -C "$TMP" commit -qam more
  cd "$TMP"
  run "$SRC" skills/tgt origin/weird "$OUT"
  [ "$status" -ne 0 ]
  [ "$(get "$output" diff-empty)" != true ]
}
