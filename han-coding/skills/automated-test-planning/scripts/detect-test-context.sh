#!/usr/bin/env bash
# Detect git availability and test planning context
# NOTE: Kept in sync with code-review/scripts/detect-review-context.sh

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

# HEAD's own line of work is its first-parent history. Resolve HEAD to a commit
# once so every candidate is measured against the same point even if the ref moves
# mid-run, then record the line's length. A candidate that contains none of these
# commits shares no history with the own line, or touches it only through a merge's
# second parent, and is skipped below.
HEAD_SHA=$(git rev-parse --verify HEAD 2>/dev/null)
OWNLINE_COUNT=$(git rev-list --count --first-parent "$HEAD_SHA" 2>/dev/null)

DEFAULT=none
best_distance=""
seen=" "

# Fold one candidate ref into the running nearest-wins selection. Its distance is
# the count of own-line commits not reachable from the candidate. First-parent
# history is monotone, so the own-line commits a candidate contains form an older
# run at the bottom of the line, and the count above them is the distance to the
# candidate's fork point. Note that "--first-parent" limits only the walk from
# HEAD; the "^$1" exclusion still uses the candidate's full reachability, so a
# commit the candidate reaches through a merge's second parent counts here just as
# the old "merge-base --is-ancestor" probe counted it. This runs one rev-list per
# candidate, not an is-ancestor probe per own-line commit. A ref already seen, or
# one containing no own-line commit (distance equals the full own-line length, so
# nothing was excluded), is skipped.
consider() { # candidate-ref
  case "$seen" in *" $1 "*) return ;; esac
  seen="$seen$1 "
  local distance
  distance=$(git rev-list --count --first-parent "$HEAD_SHA" "^$1" 2>/dev/null)
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
  CHANGED=$(git diff --name-only "$DEFAULT...$HEAD_SHA" 2>/dev/null)
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
