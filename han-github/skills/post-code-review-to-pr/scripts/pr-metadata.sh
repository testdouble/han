#!/usr/bin/env bash
set -euo pipefail

# Gathers PR metadata needed for posting a review.
#
# Usage: pr-metadata.sh
#
# Outputs JSON with: owner_repo, pr_number, head_sha, pr_author_login, current_user_login

PR_JSON=$(gh pr view --json number,headRefOid,author)
OWNER_REPO=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name')

PR_NUMBER=$(echo "$PR_JSON" | jq -r '.number')
HEAD_SHA=$(echo "$PR_JSON" | jq -r '.headRefOid')
PR_AUTHOR_LOGIN=$(echo "$PR_JSON" | jq -r '.author.login')
CURRENT_USER_LOGIN=$(gh api user --jq '.login')

jq -n \
  --arg owner_repo "$OWNER_REPO" \
  --arg pr_number "$PR_NUMBER" \
  --arg head_sha "$HEAD_SHA" \
  --arg pr_author_login "$PR_AUTHOR_LOGIN" \
  --arg current_user_login "$CURRENT_USER_LOGIN" \
  '{owner_repo: $owner_repo, pr_number: $pr_number, head_sha: $head_sha, pr_author_login: $pr_author_login, current_user_login: $current_user_login}'
