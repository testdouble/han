#!/usr/bin/env bash
set -euo pipefail

# Posts a code review to a GitHub PR using the gh CLI.
#
# Usage: post-pr-review.sh <owner/repo> <pr_number> <commit_id> <event> <body_file>
#
#   owner/repo  — e.g. testdouble/han
#   pr_number   — the PR number, e.g. 42
#   commit_id   — the head SHA of the PR
#   event       — REQUEST_CHANGES or COMMENT
#   body_file   — path to a file containing the review body markdown

if [ $# -ne 5 ]; then
  echo "Usage: $0 <owner/repo> <pr_number> <commit_id> <event> <body_file>" >&2
  exit 1
fi

OWNER_REPO="$1"
PR_NUMBER="$2"
COMMIT_ID="$3"
EVENT="$4"
BODY_FILE="$5"

if [ ! -f "$BODY_FILE" ]; then
  echo "Error: body file not found: $BODY_FILE" >&2
  exit 1
fi

# Build a JSON payload using jq --rawfile to read the body directly (bypasses shell expansion)
jq -n \
  --arg commit_id "$COMMIT_ID" \
  --arg event "$EVENT" \
  --rawfile body "$BODY_FILE" \
  '{commit_id: $commit_id, event: $event, body: ($body | rtrimstr("\n"))}' |
  gh api "repos/${OWNER_REPO}/pulls/${PR_NUMBER}/reviews" --method POST --input -
