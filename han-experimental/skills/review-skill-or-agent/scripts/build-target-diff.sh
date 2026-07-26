#!/usr/bin/env bash
# Build the review target's own change delta for review-skill-or-agent (change scope).
# Writes the target-scoped unified diff to <out-file> and prints `diff-empty: true|false`.
# The delta runs from the merge-base with the default branch — the passed argument, or the
# repo's own origin/HEAD, or HEAD when neither resolves — to the working tree, scoped to
# <target-path>, so it captures the committed-since-base, staged, unstaged, and untracked
# (non-ignored) files under the target and nothing outside it. The skill binds $diff to
# <out-file> and halts on `diff-empty: true`. Exits non-zero on bad arguments, a non-git
# work tree, an unwritable output directory, or a diff/merge-base git cannot compute
# (a shallow clone, unrelated histories, or a target outside this work tree) — never a
# silent empty diff.
# Usage: build-target-diff.sh <target-path> <default-branch|none> <out-file>
set -u

TARGET="${1:-}"
DEFAULT="${2:-}"
OUT="${3:-}"

if [ -z "$TARGET" ] || [ -z "$OUT" ]; then
  echo "build-target-diff: usage: build-target-diff.sh <target-path> <default-branch|none> <out-file>" >&2
  exit 2
fi

if ! command -v git &>/dev/null || ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "build-target-diff: not a git work tree" >&2
  exit 2
fi

mkdir -p "$(dirname "$OUT")" 2>/dev/null || {
  echo "build-target-diff: cannot create output directory for $OUT" >&2
  exit 2
}

# Absolutize $OUT (its dir now exists), then run from the repo root so a
# repo-root-relative <target-path> resolves correctly regardless of the caller's cwd.
OUT="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"
cd "$(git rev-parse --show-toplevel)" || exit 2

# Diff base: the merge-base with the default branch (the passed one, else the
# repo's own origin/HEAD), or HEAD when no default branch is resolvable at all
# (then the delta is the working tree vs HEAD).
BASE=""
DEFAULT_KNOWN=false
if [ -n "$DEFAULT" ] && [ "$DEFAULT" != none ]; then
  DEFAULT_KNOWN=true
  BASE="$(git merge-base "$DEFAULT" HEAD 2>/dev/null || true)"
fi
if [ -z "$BASE" ]; then
  DEF="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [ -n "$DEF" ]; then
    DEFAULT_KNOWN=true
    BASE="$(git merge-base "$DEF" HEAD 2>/dev/null || true)"
  fi
fi
# A default branch resolved but no merge-base could be computed — commonly a
# shallow clone whose graft hides the fork point, or unrelated histories. Fail
# loudly rather than diffing against HEAD, which would hide committed changes.
if [ -z "$BASE" ] && [ "$DEFAULT_KNOWN" = true ]; then
  echo "build-target-diff: cannot compute a merge-base with the default branch (shallow clone?)" >&2
  exit 3
fi
if [ -z "$BASE" ]; then
  # No default branch at all: HEAD when it exists (delta = working tree vs HEAD),
  # the empty tree when HEAD is unborn so a first-commit-pending repo still diffs.
  if git rev-parse --verify -q HEAD >/dev/null; then
    BASE=HEAD
  else
    BASE="$(git hash-object -t tree /dev/null)"
  fi
fi

# Tracked delta (committed-since-base + staged + unstaged), scoped to the target.
# A git-diff failure (e.g. the target is outside this work tree) is a real error,
# never a silent empty diff.
if ! git diff "$BASE" -- "$TARGET" >"$OUT" 2>/dev/null; then
  echo "build-target-diff: git diff failed for target '$TARGET' (is it inside this work tree?)" >&2
  exit 3
fi

# Untracked, non-ignored files under the target, rendered as added-file diffs.
git ls-files -z --others --exclude-standard -- "$TARGET" | while IFS= read -r -d '' f; do
  [ -n "$f" ] && git diff --no-index -- /dev/null "$f" >>"$OUT" 2>/dev/null
done

if [ -s "$OUT" ]; then
  echo "diff-empty: false"
else
  echo "diff-empty: true"
fi
