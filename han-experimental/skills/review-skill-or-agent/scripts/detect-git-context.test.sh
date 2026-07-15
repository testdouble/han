#!/usr/bin/env bash
# Ephemeral crafted-fixture checks for detect-git-context.sh.
# Usage: detect-git-context.test.sh <path-to-detect-git-context.sh>
#
# Covers the Layer-1 git-context contract the script owns: git availability,
# current branch, default branch, and the committed-changes-vs-default listing
# (Mode A) or its `changed-files: none` fallback. Uncommitted (Mode B) detection,
# changed-file->artifact mapping, PR resolution, and the candidate list are
# Layer-2 skill-body logic and are NOT exercised here. Pure bash; no jq/python.
set -u

# Resolve the script under test to an absolute path once.
SRC=$(cd "$(dirname -- "$1")" && pwd)/$(basename -- "$1")

PASS=0; FAIL=0
TMPROOT=$(mktemp -d)
trap 'rm -rf "$TMPROOT"' EXIT

ok()   { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

# Extract the value of the first `key: value` line matching $2.
get() { printf '%s\n' "$1" | awk -F': ' -v k="$2" '$1==k{print $2; exit}'; }
# True when the output $1 contains a physical line exactly equal to $2.
has_line() { printf '%s\n' "$1" | grep -qxF "$2"; }

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

# --- Behavior 1: lists committed changes against the default branch when ahead ---
d="$TMPROOT/ahead"; mkdir -p "$d"
git_init "$d"
set_origin_default "$d" main
git -C "$d" checkout -q -b feature
echo x > "$d/newfile.txt"
git -C "$d" add newfile.txt
git -C "$d" commit -q -m add
out=$(cd "$d" && "$SRC")
{ [ "$(get "$out" git-available)" = true ] \
  && [ "$(get "$out" default-branch)" = origin/main ] \
  && has_line "$out" "changed-files-start" \
  && has_line "$out" "newfile.txt" \
  && has_line "$out" "changed-files-end"; } \
  && ok "lists committed changes against the default branch when the branch is ahead" \
  || fail "committed-changes listing wrong (got: $(printf '%s' "$out" | tr '\n' '|'))"

# --- Behavior 2: reports git unavailable when git is not on PATH ---
BASH_BIN=$(command -v bash)
mkdir -p "$TMPROOT/empty"
out=$(cd "$TMPROOT/ahead" && PATH= "$BASH_BIN" "$SRC")
{ [ "$(get "$out" git-available)" = false ] \
  && [ "$(get "$out" branch)" = none ] \
  && [ "$(get "$out" default-branch)" = none ] \
  && [ "$(get "$out" changed-files)" = none ]; } \
  && ok "reports git unavailable when git is not on PATH" \
  || fail "git-not-on-PATH wrong (got: $(printf '%s' "$out" | tr '\n' '|'))"

# --- Behavior 3: reports git unavailable when run outside a work tree ---
d="$TMPROOT/notrepo"; mkdir -p "$d"
out=$(cd "$d" && "$SRC")
[ "$(get "$out" git-available)" = false ] \
  && ok "reports git unavailable when run outside a work tree" \
  || fail "outside-work-tree wrong (got: $(printf '%s' "$out" | tr '\n' '|'))"

# --- Behavior 4: no default branch and no changed files when repo has no origin/HEAD ---
d="$TMPROOT/noremote"; mkdir -p "$d"
git_init "$d"
out=$(cd "$d" && "$SRC")
{ [ "$(get "$out" git-available)" = true ] \
  && [ "$(get "$out" default-branch)" = none ] \
  && [ "$(get "$out" changed-files)" = none ]; } \
  && ok "reports no default branch and no changed files when the repo has no origin/HEAD" \
  || fail "no-origin-HEAD wrong (got: $(printf '%s' "$out" | tr '\n' '|'))"

# --- Behavior 5: no changed files when the branch has no committed diff against the default ---
d="$TMPROOT/nodiff"; mkdir -p "$d"
git_init "$d"
set_origin_default "$d" main
out=$(cd "$d" && "$SRC")
{ [ "$(get "$out" git-available)" = true ] \
  && [ "$(get "$out" default-branch)" = origin/main ] \
  && [ "$(get "$out" changed-files)" = none ]; } \
  && ok "reports no changed files when the branch has no committed diff against the default" \
  || fail "no-committed-diff wrong (got: $(printf '%s' "$out" | tr '\n' '|'))"

# --- Behavior 6: no current branch name in detached HEAD ---
d="$TMPROOT/detached"; mkdir -p "$d"
git_init "$d"
git -C "$d" commit -q --allow-empty -m second
git -C "$d" checkout -q --detach HEAD
out=$(cd "$d" && "$SRC")
{ [ "$(get "$out" git-available)" = true ] \
  && [ "$(get "$out" branch)" = none ]; } \
  && ok "reports no current branch name in detached HEAD" \
  || fail "detached-HEAD wrong (got: $(printf '%s' "$out" | tr '\n' '|'))"

echo "----"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
