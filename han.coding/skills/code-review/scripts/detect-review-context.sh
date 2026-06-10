#!/usr/bin/env bash
# Detect git availability and review context
# NOTE: Kept in sync with test-planning/scripts/detect-test-context.sh

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

# Check for remote and default branch
if git symbolic-ref --short refs/remotes/origin/HEAD &>/dev/null; then
  DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD)
  echo "default-branch: $DEFAULT"

  CHANGED=$(git diff --name-only "$DEFAULT...HEAD" 2>/dev/null)
  if [ -n "$CHANGED" ]; then
    echo "changed-files-start"
    echo "$CHANGED"
    echo "changed-files-end"
  else
    echo "changed-files: none"
  fi
else
  echo "default-branch: none"
  echo "changed-files: none"
fi
