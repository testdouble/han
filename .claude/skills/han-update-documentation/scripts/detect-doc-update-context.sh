#!/usr/bin/env bash
# Detect mode and scope for /han-update-documentation.
#
# Emits structured key: value pairs on stdout and always exits 0 so the
# skill can branch on the output without crashing on missing git state.
#
# Output keys:
#   mode             one of: branch | sweep | error
#   reason           (only when mode=error) explanation for the operator
#   branch           current branch name, or "none"
#   default-branch   resolved default branch name (no remote prefix), or "none"
#   skill-roots-start / skill-roots-end
#                    wrap a newline-separated list of discovered skill roots
#                    (every han-*/skills directory except the plugin-builder's,
#                    whose guidance skill is authoring guidance, not a documented
#                    product skill). Discovered dynamically so a newly added
#                    plugin needs no edit to this skill.
#   agent-root       the single directory that holds agents (han-core/agents),
#                    or "none" if not found
#   changed-files-start / changed-files-end
#                    (only when mode=branch and there are changes) wrap a
#                    newline-separated list of files changed against the
#                    default branch
#   changed-files: none
#                    (only when mode=branch and no files changed)

if ! command -v git &>/dev/null; then
  echo "mode: error"
  echo "reason: git is not installed"
  exit 0
fi

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "mode: error"
  echo "reason: not inside a git work tree"
  exit 0
fi

ROOT=$(git rev-parse --show-toplevel)

BRANCH=$(git branch --show-current)
echo "branch: ${BRANCH:-none}"

if ! git symbolic-ref --short refs/remotes/origin/HEAD &>/dev/null; then
  echo "default-branch: none"
  echo "mode: error"
  echo "reason: origin/HEAD is not configured; cannot determine the default branch"
  exit 0
fi

DEFAULT_FULL=$(git symbolic-ref --short refs/remotes/origin/HEAD)
DEFAULT="${DEFAULT_FULL#origin/}"
echo "default-branch: $DEFAULT"

# Discover the documented skill roots and the agent root dynamically, so adding
# a new product plugin needs no edit here. A skill root is any han-*/skills
# directory; the plugin-builder's guidance skill is authoring guidance audited
# under the guidance-docs branch, not a docs/skills/ product skill, so exclude it.
echo "skill-roots-start"
( cd "$ROOT" && find . -maxdepth 2 -type d -name skills -path './han-*/skills' \
    ! -path './han-plugin-builder/skills' 2>/dev/null | sed 's|^\./||' | sort )
echo "skill-roots-end"

AGENT_ROOT=$( cd "$ROOT" && find . -maxdepth 2 -type d -name agents -path './han-*/agents' \
    2>/dev/null | sed 's|^\./||' | sort | head -1 )
echo "agent-root: ${AGENT_ROOT:-none}"

# Sweep mode when on the default branch (or detached HEAD that resolves to it).
if [ -z "$BRANCH" ] || [ "$BRANCH" = "$DEFAULT" ]; then
  echo "mode: sweep"
  exit 0
fi

echo "mode: branch"
CHANGED=$(git diff --name-only "$DEFAULT_FULL...HEAD")
if [ -n "$CHANGED" ]; then
  echo "changed-files-start"
  echo "$CHANGED"
  echo "changed-files-end"
else
  echo "changed-files: none"
fi
