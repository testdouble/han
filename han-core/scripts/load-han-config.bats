#!/usr/bin/env bats
#
# Guards the config-loading contract. One skill, han-core:load-han-config,
# is a single load-time probe that runs the load-han-config.sh beside this file. The
# script resolves both .han/config.md files and prints them with the config
# rule, or says that neither was found. Every other shipped skill carries one
# line that invokes the loader and pre-approves the Skill tool, except
# explanation-guidance, which uses no setting and carries nothing.
#
# Keep to bash 3.2 (no mapfile, no declare -A): this runs on macOS locally.
#
# SC2016 is disabled file-wide: every single-quoted string here is literal
# SKILL.md text matched byte for byte, so nothing inside it may expand.
# shellcheck disable=SC2016

REPO_ROOT="${BATS_TEST_DIRNAME}/../.."
SCRIPT="${BATS_TEST_DIRNAME}/load-han-config.sh"
LOADER='han-core/skills/load-han-config/SKILL.md'
NO_CONFIG='han-communication/skills/explanation-guidance/SKILL.md'
LINE='Resolve configuration with `han-core:load-han-config` if you have not already this run.'
GRANT='Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/load-han-config.sh")'
PROBE='!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/load-han-config.sh" 2>/dev/null || echo'
READ_SENTENCE='As your first action, use the Read tool on `.han/config.md`'

setup() {
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/project" "$TMP/personal/.han"
}

teardown() {
  rm -rf "$TMP"
}

shipped_skills() {
  cd "$REPO_ROOT" || return 1
  for f in han-*/skills/*/SKILL.md; do printf '%s\n' "$f"; done
}

line_carriers() {
  shipped_skills | grep -v -x -e "$LOADER" -e "$NO_CONFIG"
}

# --- the script ---

@test "the loader script is a regular executable file in han-core" {
  [ -x "$SCRIPT" ]
  [ ! -L "$SCRIPT" ]
}

@test "with neither file it says so and names both paths it tried" {
  cd "$TMP/project"
  run env CLAUDE_CONFIG_DIR="$TMP/personal" bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no Han configuration was found"* ]]
  [[ "$output" == *"$TMP/project/.han/config.md"* ]]
  [[ "$output" == *"$TMP/personal/.han/config.md"* ]]
  [[ "$output" != *"### Schema"* ]]
}

@test "with a project file it prints the file and the config rule" {
  cd "$TMP/project"
  mkdir -p .han && printf -- '---\noutput-directory: docs/out\n---\n' > .han/config.md
  run env CLAUDE_CONFIG_DIR="$TMP/personal" bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"# Load Han Configuration"* ]]
  [[ "$output" == *"output-directory: docs/out"* ]]
  [[ "$output" == *"## How to apply them: the config rule"* ]]
  [[ "$output" == *"### Schema"* ]]
  [[ "$output" == *"Personal \`.han/config.md\`: not found at $TMP/personal/.han/config.md"* ]]
  [[ "$output" == *"## Project config"* ]]
  [[ "$output" == *"===== BEGIN project config ====="* ]]
  [[ "$output" == *"===== END project config ====="* ]]
  [[ "$output" != *"## Personal config"* ]]
  [[ "$output" != *$'\n\n\n'* ]]
  [[ "$output" == *$'\n\n## Project config\n\n===== BEGIN project config =====\n---'* ]]
  [[ "$output" == *$'---\n\n===== END project config =====\n\n## How to apply them: the config rule\n\n### Schema'* ]]
}

@test "with a personal file it honors CLAUDE_CONFIG_DIR and prints the file" {
  cd "$TMP/project"
  printf -- '---\ndefault-swarm-size: large\n---\n' > "$TMP/personal/.han/config.md"
  run env CLAUDE_CONFIG_DIR="$TMP/personal" bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"default-swarm-size: large"* ]]
  [[ "$output" == *"Project \`.han/config.md\`: not found at $TMP/project/.han/config.md"* ]]
  [[ "$output" == *"### Schema"* ]]
  [[ "$output" == *"## Personal config"* ]]
  [[ "$output" == *"===== BEGIN personal config ====="* ]]
  [[ "$output" == *"===== END personal config ====="* ]]
  [[ "$output" != *"## Project config"* ]]
}

@test "with the variable unset it falls back to the home directory" {
  cd "$TMP/project"
  mkdir -p "$TMP/home/.claude/.han" && printf -- '---\nwriting-voice: voice.md\n---\n' > "$TMP/home/.claude/.han/config.md"
  run env -u CLAUDE_CONFIG_DIR HOME="$TMP/home" bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"writing-voice: voice.md"* ]]
  [[ "$output" == *"$TMP/home/.claude/.han/config.md"* ]]
}

@test "with both files it prints the project file before the personal file" {
  cd "$TMP/project"
  mkdir -p .han && printf -- '---\noutput-directory: docs/out\n---\n' > .han/config.md
  printf -- '---\ndefault-swarm-size: large\n---\n' > "$TMP/personal/.han/config.md"
  run env CLAUDE_CONFIG_DIR="$TMP/personal" bash "$SCRIPT"
  [ "$status" -eq 0 ]
  project_at="${output%%default-swarm-size: large*}"
  [[ "$project_at" == *"output-directory: docs/out"* ]]
  [[ "$output" != *$'\n\n\n'* ]]
  [[ "$output" == *$'===== END project config =====\n\n## Personal config\n\n===== BEGIN personal config =====\n'* ]]
}

@test "when both lookups name the same file it prints it once, as the project file" {
  mkdir -p "$TMP/personal/.han" && printf -- '---\noutput-directory: docs/out\n---\n' > "$TMP/personal/.han/config.md"
  cd "$TMP/personal"
  run env CLAUDE_CONFIG_DIR="$TMP/personal" bash "$SCRIPT"
  [ "$status" -eq 0 ]
  count="$(printf '%s\n' "$output" | grep -c 'output-directory: docs/out')"
  [ "$count" -eq 1 ]
  [[ "$output" == *"same file"* ]]
}

@test "the config rule starts at its Schema section and nests under the loader's heading" {
  cd "$REPO_ROOT" || return 1
  first="$(grep -m1 -E '^#' han-core/references/config-rule.md)"
  [ "$first" = "### Schema" ]
  if grep -qE '^## ' han-core/references/config-rule.md; then
    echo "config-rule.md must use ### headings so they sit under the loader's ## heading"
    return 1
  fi
}

# --- the skills ---

@test "the loader is one probe that runs the script, with the matching grant, and never forks" {
  cd "$REPO_ROOT" || return 1
  grep -qF -- "$PROBE" "$LOADER"
  grep -qF -- "$GRANT" "$LOADER"
  if grep -qE '^context:' "$LOADER"; then
    echo "the loader must never set context: fork"
    return 1
  fi
  if grep -qF -- "$READ_SENTENCE" "$LOADER"; then
    echo "the loader no longer carries a Read step"
    return 1
  fi
}

@test "every other shipped skill carries the loader line exactly once" {
  cd "$REPO_ROOT" || return 1
  for skill in $(line_carriers); do
    count="$(grep -cF -- "$LINE" "$skill")"
    [ "$count" -eq 1 ] || {
      echo "expected the loader line once, found $count in: $skill"
      return 1
    }
  done
}

@test "every shipped skill that carries the loader line pre-approves the Skill tool" {
  cd "$REPO_ROOT" || return 1
  for skill in $(line_carriers); do
    awk '/^---$/ { c++; next } c == 1' "$skill" | grep -qE '(^|[[:space:],])Skill([[:space:],]|$)' || {
      echo "allowed-tools does not list Skill, so the loader call may prompt in: $skill"
      return 1
    }
  done
}

@test "no shipped skill but the loader carries a config probe, a resolver grant, or the old Read instruction" {
  cd "$REPO_ROOT" || return 1
  for skill in $(shipped_skills | grep -v -x "$LOADER"); do
    for piece in "load-han-config.sh" "han-config-dir.sh" '- project .han/config.md: !`' "$READ_SENTENCE"; do
      if grep -qF -- "$piece" "$skill"; then
        echo "old config piece still present in: $skill"
        return 1
      fi
    done
  done
}

@test "explanation-guidance carries neither the loader line nor a config piece" {
  cd "$REPO_ROOT" || return 1
  if grep -qF -- "$LINE" "$NO_CONFIG"; then
    echo "explanation-guidance uses no setting and must carry no config piece"
    return 1
  fi
}

@test "no other plugin carries a copy of the loader script" {
  cd "$REPO_ROOT" || return 1
  for dir in han-*/; do
    pkg="${dir%/}"
    [ "$pkg" = "han-core" ] && continue
    [ ! -e "${pkg}/scripts/load-han-config.sh" ] || {
      echo "stray loader script: ${pkg}/scripts/load-han-config.sh"
      return 1
    }
  done
}

@test "every plugin whose skills carry the loader line depends on han-core" {
  cd "$REPO_ROOT" || return 1
  for skill in $(line_carriers); do
    pkg="${skill%%/*}"
    [ "$pkg" = "han-core" ] && continue
    grep -qF -- '"han-core"' "${pkg}/.claude-plugin/plugin.json" || {
      echo "${pkg}/.claude-plugin/plugin.json does not declare han-core, but $skill invokes the loader"
      return 1
    }
  done
}
