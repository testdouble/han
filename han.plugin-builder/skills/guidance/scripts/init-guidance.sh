#!/usr/bin/env bash
# Vendor the plugin-building skills into the current repository so they run with
# no dependency on the han.plugin-builder plugin, and write a path-scoped rule
# index that surfaces the guidance while editing skill and agent files. Run from
# the repository root.
#
# Effects (all inside the current working directory):
#   .claude/skills/guidance/        <- guidance-only skill + its references/ (the
#                                      single vendored copy of the guidance docs)
#   .claude/skills/skill-builder/   <- the skill-builder skill, guidance paths
#                                      rewritten to the vendored location
#   .claude/skills/agent-builder/   <- the agent-builder skill, same rewrite
#   .claude/rules/plugin-building-guidance.md   <- the path-scoped rule index
#
# Re-running refreshes every vendored skill and regenerates the rule index; this
# is what the skill's update mode invokes to refresh an existing install.
set -euo pipefail

# Resolve this skill's own directory so the source skills, references, and assets
# are found regardless of where the plugin is installed.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUIDANCE_DIR="$(dirname "$SCRIPT_DIR")"
PLUGIN_SKILLS_DIR="$(dirname "$GUIDANCE_DIR")"
SRC_REFERENCES="$GUIDANCE_DIR/references"
PORTABLE_SKILL="$GUIDANCE_DIR/assets/guidance-portable-SKILL.md"
RULE_BODY="$GUIDANCE_DIR/assets/rule-index-body.md"

for required in "$SRC_REFERENCES" "$PORTABLE_SKILL" "$RULE_BODY"; do
  if [ ! -e "$required" ]; then
    echo "error: required source not found at $required" >&2
    exit 1
  fi
done

SKILLS_DEST=".claude/skills"
RULE=".claude/rules/plugin-building-guidance.md"

# The vendored builder skills can no longer resolve ${CLAUDE_PLUGIN_ROOT} (it is
# only set when the plugin is installed), so their guidance paths are rewritten
# to point at the vendored guidance skill, repo-root-relative.
OLD_PATH='${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/'
NEW_PATH='.claude/skills/guidance/references/'

# 1. Vendor the guidance skill: the guidance-only SKILL.md plus its references/,
#    which is the single in-repo copy of the guidance documents everything else
#    points at.
rm -rf "$SKILLS_DEST/guidance"
mkdir -p "$SKILLS_DEST/guidance"
cp "$PORTABLE_SKILL" "$SKILLS_DEST/guidance/SKILL.md"
cp -R "$SRC_REFERENCES" "$SKILLS_DEST/guidance/references"

# 2. Vendor each builder skill, rewriting the guidance path in its SKILL.md.
for builder in skill-builder agent-builder; do
  src="$PLUGIN_SKILLS_DIR/$builder"
  if [ ! -d "$src" ]; then
    echo "error: builder skill source not found at $src" >&2
    exit 1
  fi
  rm -rf "$SKILLS_DEST/$builder"
  mkdir -p "$SKILLS_DEST/$builder"
  cp -R "$src"/. "$SKILLS_DEST/$builder"/
  tmp="$(mktemp)"
  sed "s|${OLD_PATH}|${NEW_PATH}|g" "$SKILLS_DEST/$builder/SKILL.md" > "$tmp"
  mv "$tmp" "$SKILLS_DEST/$builder/SKILL.md"
done

COPIED=$(find "$SKILLS_DEST/guidance" "$SKILLS_DEST/skill-builder" "$SKILLS_DEST/agent-builder" -type f | wc -l | tr -d ' ')

# 3. Cover both the agent and skill layouts. Standard repos put agents under
#    */agents/ and skills under */skills/ (including .claude/agents and
#    .claude/skills). Both globs are emitted unconditionally so the rule fires
#    whether the contributor is editing a skill or an agent, including new ones
#    the repo does not have yet — the builder skills exist to create both.
paths_block="  - \"**/agents/**/*.md\"
  - \"**/skills/**/*.md\"
"

# 4. Write the rule index: generated frontmatter + the static index body.
mkdir -p "$(dirname "$RULE")"
{
  printf -- "---\n"
  printf -- "paths:\n"
  printf -- "%s" "$paths_block"
  printf -- "---\n\n"
  cat "$RULE_BODY"
} > "$RULE"

# 5. Report.
echo "Vendored 3 skill(s) (guidance, skill-builder, agent-builder) into $SKILLS_DEST"
echo "Copied $COPIED file(s) total"
echo "Wrote rule index $RULE with paths:"
printf '%s' "$paths_block"
