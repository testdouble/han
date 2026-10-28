#!/usr/bin/env bash
# Loads this run's Han configuration for han-core:load-han-config, whose one
# probe runs this script when the skill loads. Resolves the project and the
# personal .han/config.md, prints whichever exist together with the config rule
# that says how to apply them, or says that neither was found and names the
# paths it tried. Never exits non-zero: a missing file is a normal state.
#
# SC2016 is disabled file-wide: the backticks in the printf formats are Markdown
# code spans in the printed text, not expansions.
# shellcheck disable=SC2016
set -u

personal_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
personal="$personal_dir/.han/config.md"
project="$PWD/.han/config.md"

script_dir="$(dirname "$0")"
rule="$script_dir/../references/config-rule.md"

same_file=""
if [ -f "$project" ] && [ -f "$personal" ] && [ "$project" -ef "$personal" ]; then
  same_file="yes"
fi

printf '# Load Han Configuration\n\n'

if [ ! -f "$project" ] && [ ! -f "$personal" ]; then
  printf 'When this skill loaded, no Han configuration was found:\n\n'
  printf -- '- Project `.han/config.md`: not found at %s\n' "$project"
  printf -- '- Personal `.han/config.md`: not found at %s\n\n' "$personal"
  printf 'Behave as if no configuration exists, with no note about it, and continue with the skill that invoked this one.\n'
  exit 0
fi

printf 'Loaded when this skill started. These files replace any copy loaded earlier in this context.\n\n'
if [ -f "$project" ]; then
  printf -- '- Project `.han/config.md`: found at %s\n' "$project"
else
  printf -- '- Project `.han/config.md`: not found at %s\n' "$project"
fi
if [ -n "$same_file" ]; then
  printf -- '- Personal `.han/config.md`: the same file (the run is inside the personal config directory %s), read once as the project file\n' "$personal_dir"
elif [ -f "$personal" ]; then
  printf -- '- Personal `.han/config.md`: found at %s (personal config directory %s)\n' "$personal" "$personal_dir"
else
  printf -- '- Personal `.han/config.md`: not found at %s\n' "$personal"
fi

# Each injected file sits between BEGIN and END markers that name it, so its
# own headings are never mistaken for part of this skill.
# One blank line sits before every heading and marker. Command substitution
# drops a file's trailing newlines, so the spacing does not depend on them.
if [ -f "$project" ]; then
  printf '\n## Project config\n\n===== BEGIN project config =====\n%s\n\n===== END project config =====\n' "$(cat "$project")"
fi
if [ -f "$personal" ] && [ -z "$same_file" ]; then
  printf '\n## Personal config\n\n===== BEGIN personal config =====\n%s\n\n===== END personal config =====\n' "$(cat "$personal")"
fi

printf '\n## How to apply them: the config rule\n\n'
if [ -f "$rule" ]; then
  printf '%s\n' "$(cat "$rule")"
else
  printf 'The config rule (references/config-rule.md) could not be read beside this script; apply the project file over the personal file setting by setting, resolve a relative path against the folder holding the file that declared it, and ignore anything unusable with a one-line note.\n'
fi
printf '\nApply the files above per the rule at the point your workflow uses a setting, say nothing about the configuration itself, and continue with the skill that invoked this one.\n'
