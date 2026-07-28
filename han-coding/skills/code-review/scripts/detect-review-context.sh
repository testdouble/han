#!/usr/bin/env bash
# Detect git availability and review context
# NOTE: Kept in sync with automated-test-planning/scripts/detect-test-context.sh

# Check if git is installed
if ! command -v git &>/dev/null; then
  echo "git-available: false"
  echo "branch: none"
  echo "default-branch: none"
  echo "changed-files: none"
  exit 0
fi

# Check if inside a git work tree
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "git-available: false"
  echo "branch: none"
  echo "default-branch: none"
  echo "changed-files: none"
  exit 0
fi

echo "git-available: true"
BRANCH=$(git branch --show-current)
echo "branch: ${BRANCH:-none}"

# Select the base branch to diff against: the candidate whose fork point is
# nearest the current commit, measured along the branch's own line of work so a
# candidate the branch merely merged in cannot win on absorbed commits.

# The length of the branch's own line of work (first-parent history). A candidate
# that contains none of these commits is reachable only through a merge's second
# parent, or shares no history, and is skipped.
OWNLINE_COUNT=$(git rev-list --count --first-parent HEAD 2>/dev/null)

DEFAULT=none
best_distance=""
seen=" "

# Fold one candidate ref into the running nearest-wins selection. Its distance is
# the count of own-line commits not reachable from the candidate, which equals
# the number sitting above the newest own-line commit it contains. That is one
# rev-list per candidate, rather than an is-ancestor probe per own-line commit. A
# ref already seen, or one containing no own-line commit (distance equals the full
# own-line length, so nothing was excluded), is skipped.
consider() { # candidate-ref
  case "$seen" in *" $1 "*) return ;; esac
  seen="$seen$1 "
  local distance
  distance=$(git rev-list --count --first-parent HEAD "^$1" 2>/dev/null)
  { [ -n "$distance" ] && [ -n "$OWNLINE_COUNT" ] && [ "$distance" -lt "$OWNLINE_COUNT" ]; } || return
  if [ -z "$best_distance" ] || [ "$distance" -lt "$best_distance" ]; then
    best_distance=$distance
    DEFAULT=$1
  fi
}

# Candidate pool, enumerated declared-defaults-first so that under the
# nearest-wins rule a declared default beats a name-guessed candidate at an
# equal-distance tie. First, every remote's declared default branch (HEAD).
while IFS= read -r headref; do
  ref=$(git symbolic-ref --short "$headref" 2>/dev/null) || continue
  consider "$ref"
done < <(git for-each-ref --sort=refname --format='%(refname)' refs/remotes/ 2>/dev/null | grep -E '/HEAD$')

# Then well-known trunk/integration names as local branches, then as each
# remote's tracking branch.
for n in main master trunk mainline next develop devel development default dev; do
  git show-ref --verify -q "refs/heads/$n" && consider "$n"
  while IFS= read -r ref; do
    [ -n "$ref" ] && consider "$ref"
  done < <(git for-each-ref --sort=refname --format='%(refname:short)' "refs/remotes/*/$n" 2>/dev/null)
done

echo "default-branch: $DEFAULT"

if [ "$DEFAULT" != none ]; then
  CHANGED=$(git diff --name-only "$DEFAULT...HEAD" 2>/dev/null)
  if [ -n "$CHANGED" ]; then
    echo "changed-files-start"
    echo "$CHANGED"
    echo "changed-files-end"
  else
    echo "changed-files: none"
  fi
else
  echo "changed-files: none"
fi
