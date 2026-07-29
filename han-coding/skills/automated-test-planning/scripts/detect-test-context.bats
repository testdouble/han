#!/usr/bin/env bats
#
# Tests for automated-test-planning's detect-test-context.sh: the git-context contract
# (git availability, current branch, base-branch selection across remotes and
# well-known trunk/integration names by the branch's own line of work, and the
# committed-changes-vs-base listing or its `changed-files: none` fallback). Kept
# in sync with the code-review and review-skill-or-agent copies of this
# detector's tests.

setup() {
  SRC="$BATS_TEST_DIRNAME/detect-test-context.sh"
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

# Point <remote>/<branch> at <sha> and make it that remote's declared default HEAD.
set_remote_head() { # repo remote branch sha
  git -C "$1" update-ref "refs/remotes/$2/$3" "$4"
  git -C "$1" symbolic-ref "refs/remotes/$2/HEAD" "refs/remotes/$2/$3"
}

# Point <remote>/<branch> at <sha> as a plain remote-tracking branch (no HEAD).
set_remote_tracking() { # repo remote branch sha
  git -C "$1" update-ref "refs/remotes/$2/$3" "$4"
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

@test "reports no default branch and no changed files when no candidate branch exists" {
  git_init "$TMP"
  git -C "$TMP" branch -m scratch # no remote, and no well-known-named branch
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

@test "reports a fresher other-remote default over a stale origin default" {
  git_init "$TMP"                  # C0 on the init default branch (main)
  set_origin_default "$TMP" main   # origin/main is stale, pinned at C0
  echo up >"$TMP/upstream-only.txt" # upstream advances past C0
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m U1
  set_remote_head "$TMP" upstream main "$(git -C "$TMP" rev-parse HEAD)"
  git -C "$TMP" checkout -q -b feature # cut from upstream/main's tip
  echo f >"$TMP/feature.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m F1
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  [ "$(get "$output" default-branch)" = upstream/main ]
  [[ "$output" == *"feature.txt"* ]]
  [[ "$output" != *"upstream-only.txt"* ]]
}

@test "reports a remote integration branch the current branch was cut from" {
  git_init "$TMP"                  # C0 on main
  set_origin_default "$TMP" main   # origin/main is the declared default, at C0
  git -C "$TMP" checkout -q -b devwork
  echo d >"$TMP/dev.txt"           # develop advances past C0
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m D1
  set_remote_tracking "$TMP" origin develop "$(git -C "$TMP" rev-parse HEAD)"
  git -C "$TMP" checkout -q -b feature # cut from develop's tip
  echo f >"$TMP/feature.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m F1
  git -C "$TMP" branch -D devwork   # leave only origin/develop + origin/main
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  [ "$(get "$output" default-branch)" = origin/develop ]
  [[ "$output" == *"feature.txt"* ]]
}

@test "reports a local trunk the current branch was cut from" {
  git_init "$TMP"                  # C0 on main
  set_origin_default "$TMP" main   # a remote default that must lose to the nearer local trunk
  git -C "$TMP" checkout -q -b develop
  echo d >"$TMP/dev.txt"           # local develop advances past C0
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m D1
  git -C "$TMP" checkout -q -b feature # cut from local develop
  echo f >"$TMP/feature.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m F1
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  [ "$(get "$output" default-branch)" = develop ]
  [[ "$output" == *"feature.txt"* ]]
}

@test "does not let a merged-in candidate win over the branch's own base" {
  git_init "$TMP"                  # C0 on the initial branch
  base=$(git -C "$TMP" rev-parse HEAD)
  set_origin_default "$TMP" main   # origin/main declared default at C0
  git -C "$TMP" checkout -q -b develop
  echo helper >"$TMP/helper.txt"   # develop advances past C0
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m D1
  git -C "$TMP" checkout -q -b feature "$base" # cut from C0, not develop
  echo f >"$TMP/feature.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m F1
  git -C "$TMP" merge -q --no-ff develop -m "merge develop" # absorb develop
  echo more >>"$TMP/feature.txt"
  git -C "$TMP" commit -qam F2
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  # The branch came from main; develop was only merged in. Plain merge-base
  # would wrongly pick develop (its tip is a nearer ancestor).
  [ "$(get "$output" default-branch)" = origin/main ]
  # The delta against main still includes develop's absorbed changes.
  [[ "$output" == *"feature.txt"* ]]
  [[ "$output" == *"helper.txt"* ]]
}

@test "excludes an unrelated candidate without aborting and still resolves a valid base" {
  git_init "$TMP"                  # C0 on main
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q -b feature
  echo f >"$TMP/feature.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m F1
  # A declared-default candidate on an orphan history that shares nothing with HEAD:
  git -C "$TMP" checkout -q --orphan alien
  git -C "$TMP" commit -q --allow-empty -m orphan
  set_remote_head "$TMP" other main "$(git -C "$TMP" rev-parse HEAD)"
  git -C "$TMP" checkout -q feature
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  [ "$(get "$output" default-branch)" = origin/main ]
  [[ "$output" == *"feature.txt"* ]]
}

@test "reports none when the only candidate shares no history with HEAD" {
  git_init "$TMP"                  # C0 on main
  set_origin_default "$TMP" main
  git -C "$TMP" checkout -q --orphan feature # feature shares no history with main
  git -C "$TMP" commit -q --allow-empty -m orphan
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  [ "$(get "$output" default-branch)" = none ]
  [ "$(get "$output" changed-files)" = none ]
}

@test "reports none on an unborn HEAD without failing" {
  git -C "$TMP" init -q
  git -C "$TMP" config user.email a@b.c
  git -C "$TMP" config user.name tester
  cd "$TMP" # a fresh repo with no commit yet
  run "$SRC"
  [ "$status" -eq 0 ]
  [ "$(get "$output" git-available)" = true ]
  [ "$(get "$output" default-branch)" = none ]
  [ "$(get "$output" changed-files)" = none ]
}

@test "resolves an equal-distance tie to the same base across runs" {
  git_init "$TMP"                                                # C0
  set_remote_head "$TMP" origin main "$(git -C "$TMP" rev-parse HEAD)"
  set_remote_head "$TMP" upstream main "$(git -C "$TMP" rev-parse HEAD)" # tied fork commit
  git -C "$TMP" checkout -q -b feature
  echo f >"$TMP/feature.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m F1
  cd "$TMP"
  run "$SRC"
  first=$(get "$output" default-branch)
  run "$SRC"
  second=$(get "$output" default-branch)
  [ "$status" -eq 0 ]
  [ -n "$first" ] && [ "$first" = "$second" ]                    # stable across runs
  [ "$first" = origin/main ] || [ "$first" = upstream/main ]     # one of the tied candidates
}

@test "resolves a base from HEAD in a detached checkout" {
  git_init "$TMP"                  # C0
  set_origin_default "$TMP" main
  echo x >"$TMP/extra.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m C1
  git -C "$TMP" checkout -q --detach HEAD
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  [ "$(get "$output" branch)" = none ]
  [ "$(get "$output" default-branch)" != none ]
}

@test "prefers a declared default over a well-known-name candidate at an equal-distance tie" {
  git_init "$TMP"                # C0 on main
  set_origin_default "$TMP" main # origin/main (declared default) at C0
  git -C "$TMP" branch develop   # local develop at C0: a name-guessed candidate at the same distance
  git -C "$TMP" checkout -q -b feature
  echo f >"$TMP/feature.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m F1
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  # origin/main and local develop sit at the same own-line distance; the declared
  # default is enumerated first and must win the tie over the name-guessed branch.
  [ "$(get "$output" default-branch)" = origin/main ]
}

@test "recognizes a candidate that reaches the own line only via its own second parent" {
  git_init "$TMP"                          # R0 on the initial branch
  git -C "$TMP" checkout -q -b spine
  echo x >"$TMP/x.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m X             # X: an own-line commit
  xsha=$(git -C "$TMP" rev-parse HEAD)
  echo h >"$TMP/head.txt"
  git -C "$TMP" add -A
  git -C "$TMP" commit -q -m HEADc         # own line: R0 -> X -> HEADc
  git -C "$TMP" checkout -q --orphan zline # a candidate on a second root
  git -C "$TMP" rm -rfq .
  git -C "$TMP" commit -q --allow-empty -m Z1
  git -C "$TMP" merge -q --no-ff --allow-unrelated-histories "$xsha" -m "absorb X as a second parent"
  set_remote_head "$TMP" origin cand "$(git -C "$TMP" rev-parse HEAD)"
  git -C "$TMP" checkout -q spine
  cd "$TMP"
  run "$SRC"
  [ "$status" -eq 0 ]
  # cand reaches own-line commit X only through the merge's second parent. Full
  # reachability exclusion (correct) counts X as contained and selects cand at the
  # nearer fork; a first-parent-limited exclusion would treat cand as unrelated and
  # fall back to the initial branch at the older fork.
  [ "$(get "$output" default-branch)" = origin/cand ]
}
