#!/usr/bin/env bash
set -euo pipefail

# Posts a code review as a regular PR comment using the gh CLI.
# Use this instead of post-pr-review.sh when the current user is the PR author,
# since GitHub's API rejects formal PR reviews from the PR author.
#
# Usage: post-pr-comment.sh <pr_number> <body_file>
#
#   pr_number  — the PR number, e.g. 42
#   body_file  — path to a file containing the review body markdown

if [ $# -ne 2 ]; then
  echo "Usage: $0 <pr_number> <body_file>" >&2
  exit 1
fi

PR_NUMBER="$1"
BODY_FILE="$2"

if [ ! -f "$BODY_FILE" ]; then
  echo "Error: body file not found: $BODY_FILE" >&2
  exit 1
fi

gh pr comment "$PR_NUMBER" --body-file "$BODY_FILE"
