---
name: post-code-review-to-pr
description: >
  Run a full pull request review and post review comments directly to the current
  branch's GitHub PR. Requires the gh CLI to be installed and a PR to already
  exist for the current branch. Use when you want review feedback posted to
  GitHub as PR comments. For local code review without posting to GitHub, use
  code-review instead. Does not write or update PR descriptions — use
  update-pr-description for that.
argument-hint: [optional context about the PR or areas to focus on]
allowed-tools: Bash(jq *), Bash(gh *), Bash(git *), Bash(make *), Bash(npm *), Read, Grep, Glob, Skill, Agent
---

When running a PR code review, follow the process outlined here.

## Pre-requisites

- gh CLI: !`which gh`
- jq: !`which jq`

If `gh` is not found, inform the user it must be installed and configured; if `jq` is not found, inform the user it must be installed. In either case, immediately stop.

## Project Context

- current branch: !`git branch --show-current`
- default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD`
- changed files: !`gh pr diff --name-only`

## Step 1: Validate PR State

If `changed files` is empty or `gh pr view --json number,url` fails, inform the user no reviewable PR exists for the current branch and stop.

## Step 2: Run Code Review

Invoke the `/code-review` skill to perform the full code review. Pass along any user-provided focus areas or context from the original arguments. After /code-review completes, proceed immediately to Step 3 — do not stop here.

## Step 3: Offer to Post Review to GitHub

Ask the user whether they'd like to post the review to the PR on GitHub using `AskUserQuestion` with options "Yes, post the review to GitHub" and "No, just the local review". If the user declines, proceed to Step 5.

If the user accepts:

1. Gather PR metadata by running `${CLAUDE_SKILL_DIR}/scripts/pr-metadata.sh`, which outputs JSON with `owner_repo`, `pr_number`, `head_sha`, `pr_author_login`, and `current_user_login`.
2. Build the review body from: Review Summary table, Review Recommendation, What's Good section, and all findings organized by severity.
3. Continue to Step 4 — do **not** post yet.

## Step 4: Pre-Post Clarity Check

Because the review body will be publicly visible on the PR, run a clarity pass on the draft before posting.

1. Write the draft review body to a temporary file (e.g., `/tmp/post-code-review-to-pr-draft.md`) using the Write tool.
2. Launch a single `han.core:junior-developer` agent in artifact-review mode with the prompt: "You are reviewing the text of a code review that is about to be posted publicly on a GitHub pull request. The review is at {draft_path}. Do not re-review the code — review the review. Flag findings whose wording is unclear, severity is mis-assigned (CRIT used where WARN would be accurate, or vice versa), language is accusatory or blaming rather than evidence-based, or `file_path:line_number` references are missing or invalid. Return a short list of specific edits with before/after text; return an empty list if the review reads well as-is."
3. Apply every actionable edit the agent returns. If the agent raises a severity-assignment issue, adjust the finding's task ID and the Review Summary table to match.
4. Generate a unique temp file path by running `${CLAUDE_SKILL_DIR}/scripts/create-review-tempfile.sh`. Write the final, edited review body to that path using the Write tool (not Bash).
5. **Post based on authorship:** If `pr_author_login` matches `current_user_login` (self-authored PR), post as a PR comment (GitHub rejects formal reviews from PR authors) by running `${CLAUDE_SKILL_DIR}/scripts/post-pr-comment.sh {pr_number} {temp_file_path}`. If they differ, determine event type (`REQUEST_CHANGES` if any CRIT or WARN findings exist, `COMMENT` if only SUGG) and post as a formal review by running `${CLAUDE_SKILL_DIR}/scripts/post-pr-review.sh {owner/repo} {pr_number} {head_sha} {event_type} {temp_file_path}`.
6. On success, report the PR URL. On failure, report the error.

## Step 5: Offer to Create Fix Plan (Only If Issues Found)

If any Critical or Warning issues were identified, ask the user using `AskUserQuestion` — "Would you like me to create a plan to fix the identified issues?" with options "Yes, create a fix plan" and "No, just the review". If yes, enter plan mode and create a detailed implementation plan listing each Critical and Warning item by task ID, with specific code changes, file paths, and line numbers, ordered by priority (Critical first). If no Critical or Warning issues were found, the review is complete — suggestions alone do not warrant a fix plan.
