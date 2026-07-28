#!/usr/bin/env bash
# Detect git availability and branch context for review-skill-or-agent target discovery
# NOTE: This detector's base-branch selection is intentionally ahead of the
# code-review/scripts/detect-review-context.sh and test-planning/scripts/detect-test-context.sh
# copies (multi-remote, own-line/first-parent selection). The divergence is
# temporary; a follow-up ports it to those copies. Do not re-sync this file
# backward to match them.

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

# The branch's own line of work (first-parent history), newest first: a candidate
# reachable only through a merge's second parent is not on it.
OWNLINE=$(git rev-list --first-parent HEAD 2>/dev/null)

DEFAULT=none
best_distance=""
seen=" "

# Fold one candidate ref into the running nearest-wins selection. Its distance is
# the number of own-line commits above the newest own-line commit the candidate
# contains; a ref already seen, or one sharing no history with the own line, is
# skipped.
consider() { # candidate-ref
  case "$seen" in *" $1 "*) return ;; esac
  seen="$seen$1 "
  local commit count=0 distance=""
  while IFS= read -r commit; do
    if git merge-base --is-ancestor "$commit" "$1" 2>/dev/null; then
      distance=$count
      break
    fi
    count=$((count + 1))
  done <<<"$OWNLINE"
  [ -n "$distance" ] || return
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
