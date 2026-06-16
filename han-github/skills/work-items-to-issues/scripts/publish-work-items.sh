#!/usr/bin/env bash
# Usage: publish-work-items.sh <work-items-file> <target-repo> <plan-folder> [--label <name>] [--assignee <user>]
#
# Runs the three publish steps in order:
#   1. upload-screenshots.sh — copies UI screenshots into the target repo
#   2. create-issues.sh      — creates one issue per slice, annotates the
#                              work-items file with the resulting #NNN
#   3. link-blockers.sh      — posts native blocked_by links per Depends on
#
# Issues are created with no label and no assignee by default. Optional
# `--label <name>` and `--assignee <user>` flags are forwarded to
# create-issues.sh, which applies them to every issue.
#
# Each step is idempotent. Re-running after a partial failure resumes
# without duplicating completed work.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

WORK_ITEMS="${1:?work-items file required}"
TARGET_REPO="${2:?target repo (org/name) required}"
PLAN_FOLDER="${3:?plan folder required}"
shift 3 || true
# Remaining args (optional --label/--assignee) pass through to create-issues.sh.

"$DIR/upload-screenshots.sh" "$WORK_ITEMS" "$TARGET_REPO" "$PLAN_FOLDER"
"$DIR/create-issues.sh" "$WORK_ITEMS" "$TARGET_REPO" "$@"
"$DIR/link-blockers.sh" "$WORK_ITEMS" "$TARGET_REPO"
