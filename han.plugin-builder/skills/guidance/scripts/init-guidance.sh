#!/usr/bin/env bash
# Vendor the plugin-building guidance into the current repository and write a
# path-scoped rule index that points at it. Run from the repository root.
#
# Effects (all inside the current working directory):
#   .claude/plugin-building-guidance/   <- full copy of the guidance docs
#   .claude/rules/plugin-building-guidance.md   <- the path-scoped rule index
#
# Re-running refreshes the vendored copy and regenerates the rule index.
set -euo pipefail

# Resolve this skill's own directory so the source guidance and the index body
# are found regardless of where the plugin is installed.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
SRC="$SKILL_DIR/references"
ASSET="$SKILL_DIR/assets/rule-index-body.md"

if [ ! -d "$SRC" ]; then
  echo "error: guidance source not found at $SRC" >&2
  exit 1
fi
if [ ! -f "$ASSET" ]; then
  echo "error: rule index body not found at $ASSET" >&2
  exit 1
fi

DEST=".claude/plugin-building-guidance"
RULE=".claude/rules/plugin-building-guidance.md"

# 1. Vendor the guidance docs into the repo (fresh copy each run).
rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$SRC"/. "$DEST"/
COPIED=$(find "$DEST" -type f | wc -l | tr -d ' ')

# 2. Detect which globs are needed to cover this repo's agent and skill files.
#    Standard layouts put agents under */agents/ and skills under */skills/
#    (including .claude/agents and .claude/skills).
candidates=$(find . -type f -name '*.md' \( -path '*/agents/*' -o -path '*/skills/*' \) 2>/dev/null | grep -v '/\.git/' || true)
paths_block=""
if printf '%s\n' "$candidates" | grep -q '/agents/'; then
  paths_block="${paths_block}  - \"**/agents/**/*.md\"
"
fi
if printf '%s\n' "$candidates" | grep -q '/skills/'; then
  paths_block="${paths_block}  - \"**/skills/**/*.md\"
"
fi
# Fallback: if neither layout was detected, cover both so the rule still works
# as the repo grows.
if [ -z "$paths_block" ]; then
  paths_block="  - \"**/agents/**/*.md\"
  - \"**/skills/**/*.md\"
"
fi

# 3. Write the rule index: generated frontmatter + the static index body.
mkdir -p "$(dirname "$RULE")"
{
  printf -- "---\n"
  printf -- "paths:\n"
  printf -- "%s" "$paths_block"
  printf -- "---\n\n"
  cat "$ASSET"
} > "$RULE"

# 4. Report.
echo "Vendored $COPIED guidance file(s) into $DEST"
echo "Wrote rule index $RULE with paths:"
printf '%s' "$paths_block"
