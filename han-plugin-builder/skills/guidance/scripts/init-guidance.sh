#!/usr/bin/env bash
# Vendor the plugin-building skills into the current repository so they run with
# no dependency on the han-plugin-builder plugin, and write a path-scoped rule
# index that surfaces the guidance while editing skill and agent files. Run from
# the repository root.
#
# The vendored skills are renamed with a "plugin-" prefix so they never collide
# with this plugin's own slash commands if the plugin is also installed.
#
# Effects (all inside the current working directory):
#   .claude/skills/plugin-guidance/        <- guidance-only skill + its
#                                             references/ (the single vendored
#                                             copy of the guidance docs)
#   .claude/skills/plugin-skill-builder/   <- the skill-builder skill, names and
#                                             guidance paths rewritten
#   .claude/skills/plugin-agent-builder/   <- the agent-builder skill, same
#   .claude/rules/plugin-building-guidance.md   <- the path-scoped rule index
#
# Re-running refreshes every vendored skill and regenerates the rule index; this
# is what the skill's update mode invokes to refresh an existing install. The
# rewrites are idempotent because each run starts from a fresh copy of the
# bare-named plugin source.
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

# Rewrite a vendored SKILL.md in place to the "plugin-" prefixed, no-dependency
# form. The literals "skill-builder" / "agent-builder" are safe to replace
# wholesale: they do not collide with the "skill-building-guidance" /
# "agent-building-guidelines" directory names, which diverge at "building". The
# guidance command reference ("use guidance.") and the guidance docs path
# (${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/, only set when the plugin is
# installed) are retargeted at the renamed, vendored guidance skill.
rewrite_skill() {
  file="$1"
  tmp="$(mktemp)"
  # shellcheck disable=SC2016  # ${CLAUDE_PLUGIN_ROOT} is matched literally, not expanded.
  sed \
    -e 's|${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/|.claude/skills/plugin-guidance/references/|g' \
    -e 's|^name: guidance$|name: plugin-guidance|' \
    -e 's|skill-builder|plugin-skill-builder|g' \
    -e 's|agent-builder|plugin-agent-builder|g' \
    -e 's|use guidance\.|use plugin-guidance.|g' \
    "$file" > "$tmp"
  mv "$tmp" "$file"
}

# 1. Vendor the guidance skill: the guidance-only SKILL.md plus its references/,
#    which is the single in-repo copy of the guidance documents everything else
#    points at.
rm -rf "$SKILLS_DEST/plugin-guidance"
mkdir -p "$SKILLS_DEST/plugin-guidance"
cp "$PORTABLE_SKILL" "$SKILLS_DEST/plugin-guidance/SKILL.md"
cp -R "$SRC_REFERENCES" "$SKILLS_DEST/plugin-guidance/references"
rewrite_skill "$SKILLS_DEST/plugin-guidance/SKILL.md"

# 2. Vendor each builder skill under its prefixed name, rewriting names, the
#    cross-references between the skills, and the guidance path in its SKILL.md.
for builder in skill-builder agent-builder; do
  src="$PLUGIN_SKILLS_DIR/$builder"
  if [ ! -d "$src" ]; then
    echo "error: builder skill source not found at $src" >&2
    exit 1
  fi
  dest="$SKILLS_DEST/plugin-$builder"
  rm -rf "$dest"
  mkdir -p "$dest"
  cp -R "$src"/. "$dest"/
  rewrite_skill "$dest/SKILL.md"
done

COPIED=$(find "$SKILLS_DEST/plugin-guidance" "$SKILLS_DEST/plugin-skill-builder" "$SKILLS_DEST/plugin-agent-builder" -type f | wc -l | tr -d ' ')

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
echo "Vendored 3 skill(s) (plugin-guidance, plugin-skill-builder, plugin-agent-builder) into $SKILLS_DEST"
echo "Copied $COPIED file(s) total"
echo "Wrote rule index $RULE with paths:"
printf '%s' "$paths_block"
