#!/usr/bin/env bats
#
# Guards the config-directory probe. The command that resolves the personal
# config directory appears twice in every skill that uses it: once in the
# allowed-tools grant and once in the probe. A grant that stops matching its
# probe aborts the skill silently, so these checks keep the two in step and
# keep the script they name reachable from each plugin.

REPO_ROOT="${BATS_TEST_DIRNAME}/.."
SCRIPT_REL='scripts/han-config-dir.sh'
# The grant and probe are literal SKILL.md text, matched byte for byte, so the
# single quotes are deliberate: nothing inside them may expand here.
# shellcheck disable=SC2016
GRANT='Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")'
# shellcheck disable=SC2016
PROBE='- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`'

# Every SKILL.md that carries the probe, one per line.
probe_skills() {
  cd "$REPO_ROOT" || return 1
  grep -rlF -- "${SCRIPT_REL}\" 2>/dev/null" ./*/skills/*/SKILL.md
}

@test "the shared resolver script exists and is executable" {
  [ -x "${REPO_ROOT}/${SCRIPT_REL}" ]
}

@test "the resolver honors CLAUDE_CONFIG_DIR when it is set" {
  run env CLAUDE_CONFIG_DIR=/tmp/probe-fixture bash "${REPO_ROOT}/${SCRIPT_REL}"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/probe-fixture" ]
}

@test "the resolver falls back to the home directory when the variable is unset" {
  run env -u CLAUDE_CONFIG_DIR HOME=/tmp/probe-home bash "${REPO_ROOT}/${SCRIPT_REL}"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/probe-home/.claude" ]
}

@test "at least one skill carries the probe" {
  run probe_skills
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "every skill carrying the probe uses the exact guarded form" {
  cd "$REPO_ROOT" || return 1
  for skill in $(probe_skills); do
    grep -qF -- "$PROBE" "$skill" || {
      echo "probe line does not match the canonical form in: $skill"
      return 1
    }
  done
}

@test "every skill carrying the probe grants the same command" {
  cd "$REPO_ROOT" || return 1
  for skill in $(probe_skills); do
    grep -qF -- "$GRANT" "$skill" || {
      echo "allowed-tools is missing the matching grant in: $skill"
      return 1
    }
  done
}

@test "every plugin holding such a skill can reach the resolver script" {
  cd "$REPO_ROOT" || return 1
  for skill in $(probe_skills); do
    plugin="${skill#./}"
    plugin="${plugin%%/*}"
    [ -f "${plugin}/${SCRIPT_REL}" ] || {
      echo "missing or unresolvable ${plugin}/${SCRIPT_REL} for: $skill"
      return 1
    }
  done
}
