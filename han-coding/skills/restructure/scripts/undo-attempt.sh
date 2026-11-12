#!/usr/bin/env bash
# Undo a Mikado discovery attempt, or a failed unit, back to the last commit.
#
# Usage: undo-attempt.sh BASE_SHA
#
# BASE_SHA is the commit HEAD pointed at when the attempt started. The undo is
# only safe when nothing was committed since, so the script refuses to touch
# the tree if HEAD has moved. It then restores every tracked file to HEAD and
# removes every untracked, non-ignored file. Ignored files (build output,
# installed packages, caches) are left alone, which is why the caller re-runs
# the full suite afterward.
#
# The caller guarantees the tree was clean, untracked files included, when the
# attempt started, so every untracked file present now was created by the
# attempt. Each removed file is printed as "removed: PATH".
#
# Exit codes: 0 undone and the tree is clean; 1 usage error or not a git
# repository; 2 HEAD moved since BASE_SHA; 3 the tree is still dirty after the
# undo.

set -u

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
  echo "usage: undo-attempt.sh BASE_SHA" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: not inside a git repository" >&2
  exit 1
fi

BASE=$(git rev-parse --verify --quiet "$1^{commit}")
if [ -z "$BASE" ]; then
  echo "error: $1 is not a commit" >&2
  exit 1
fi

HEAD_SHA=$(git rev-parse HEAD)
if [ "$HEAD_SHA" != "$BASE" ]; then
  echo "error: HEAD moved from $BASE to $HEAD_SHA since the attempt started; nothing was undone" >&2
  exit 2
fi

ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT" || exit 1

git ls-files --others --exclude-standard | while IFS= read -r path; do
  echo "removed: $path"
done

git restore --source=HEAD --staged --worktree -- . 2>/dev/null || true
git clean -fdq -- .

if [ -n "$(git status --porcelain)" ]; then
  echo "error: the tree is still dirty after the undo:" >&2
  git status --porcelain >&2
  exit 3
fi

echo "undone: tree matches $BASE"
