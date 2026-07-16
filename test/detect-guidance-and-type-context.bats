#!/usr/bin/env bats
#
# Tests for review-skill-or-agent's detect-guidance-and-type-context.sh. Covers
# the two behaviors the detector owns: target-type classification by frontmatter
# shape (skill / agent / mismatch / neither), keying on the type-exclusive
# allowed-tools / tools fields, tolerant of minimal frontmatter, a leading UTF-8
# BOM, and CRLF endings; and guidance-root resolution plus completeness across
# the sibling-plugin, installed (via `claude plugin list --json`), and
# repo-local-vendored layouts, including segment-anchoring and tier precedence.
# Also asserts the emit() flattening keeps a crafted target path from forging a
# second key: value line. Pure bash; no jq/python3 (the detector's own JSON read
# uses awk, and a `claude` stub sandboxes it).

# The exact REQUIRED lists the detector grounds completeness against.
SKILL_REQUIRED="skill-description-frontmatter.md skill-description-length.md naming-conventions.md progressive-disclosure.md skill-reference-files.md writing-effective-instructions.md workflow-patterns.md allowed-tools-bash-permissions.md allowed-tools-AskUserQuestion.md security-restrictions.md agent-dispatch-namespacing.md graceful-degradation.md dynamic-project-discovery.md optional-git-repositories.md script-execution-instructions.md success-criteria-and-testing.md"
AGENT_REQUIRED="agent-domain-focus.md agent-description-length.md agent-model-selection.md agent-external-files.md multi-agent-economics.md graceful-degradation.md"

setup() {
  SRC="$BATS_TEST_DIRNAME/../han-experimental/skills/review-skill-or-agent/scripts/detect-guidance-and-type-context.sh"
  TMPROOT="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMPROOT"
}

# Extract the value of a `key: value` line (first match wins).
get() { printf '%s\n' "$1" | awk -F': ' -v k="$2" '$1==k{print $2; exit}'; }
# Count physical lines whose key is $2.
keycount() { printf '%s\n' "$1" | grep -cE "^$2: " || true; }

# Write a skill dir at $1 whose frontmatter body is the %b-interpreted $2.
mkskill() { mkdir -p "$1"; { printf -- '---\n'; printf '%b' "$2"; printf -- '---\nBody.\n'; } >"$1/SKILL.md"; }
# Write an agent .md at $1 whose frontmatter body is the %b-interpreted $2.
mkagent() { mkdir -p "$(dirname -- "$1")"; { printf -- '---\n'; printf '%b' "$2"; printf -- '---\nBody.\n'; } >"$1"; }

# Populate a complete skill-type guidance references tree at $1 (the .../references dir).
mk_skill_guidance() {
  mkdir -p "$1/skill-building-guidance"
  : >"$1/plugin-entity-taxonomy.md"
  for f in $SKILL_REQUIRED; do : >"$1/skill-building-guidance/$f"; done
}

# Copy the script into a synthetic plugin tree under $1 (the plugins-parent dir)
# at $1/han-experimental/skills/review-skill-or-agent/scripts/ and echo its path.
install_script() {
  local d="$1/han-experimental/skills/review-skill-or-agent/scripts"
  mkdir -p "$d"
  cp "$SRC" "$d/detect-guidance-and-type-context.sh"
  chmod +x "$d/detect-guidance-and-type-context.sh"
  printf '%s\n' "$d/detect-guidance-and-type-context.sh"
}

# Install an executable `claude` stub in dir $1 that prints the contents of file
# $2 for `plugin list --json` (and nothing otherwise).
stub_claude() {
  local bindir="$1" jsonfile="$2"
  mkdir -p "$bindir"
  cat >"$bindir/claude" <<STUB
#!/usr/bin/env bash
if [ "\$1" = plugin ] && [ "\$2" = list ]; then
  cat "$jsonfile"
fi
STUB
  chmod +x "$bindir/claude"
}

# Write a one-entry `claude plugin list --json` payload to file $1: a plugin
# whose id is $2 and installPath is $3. Pretty-printed like the real CLI output.
write_plugin_json() {
  printf '[\n  {\n    "id": "%s",\n    "version": "0.0.0",\n    "installPath": "%s"\n  }\n]\n' "$2" "$3" >"$1"
}

# ============================================================================
# Target-type classification
# ============================================================================

@test "minimal skill (no allowed-tools) -> skill" {
  mkskill "$TMPROOT/c1/minimal" 'name: minimal\ndescription: a valid minimal skill.\n'
  out=$("$SRC" "$TMPROOT/c1/minimal")
  [ "$(get "$out" target-type)" = skill ]
}

@test "allowed-tools skill -> skill" {
  mkskill "$TMPROOT/c2/at" 'name: at\ndescription: valid.\nallowed-tools: Read\n'
  out=$("$SRC" "$TMPROOT/c2/at")
  [ "$(get "$out" target-type)" = skill ]
}

@test "model-only skill -> skill (model is shared, not an agent marker)" {
  mkskill "$TMPROOT/c3/model" 'name: model\ndescription: valid.\nmodel: opus\n'
  out=$("$SRC" "$TMPROOT/c3/model")
  [ "$(get "$out" target-type)" = skill ]
}

@test "CRLF skill -> skill" {
  mkdir -p "$TMPROOT/c4/crlf"
  printf -- '---\r\nname: crlf\r\ndescription: valid.\r\nallowed-tools: Read\r\n---\r\nBody.\r\n' >"$TMPROOT/c4/crlf/SKILL.md"
  out=$("$SRC" "$TMPROOT/c4/crlf")
  [ "$(get "$out" target-type)" = skill ]
}

@test "BOM skill -> skill" {
  mkdir -p "$TMPROOT/c5/bom"
  printf -- '\357\273\277---\nname: bom\ndescription: valid.\nallowed-tools: Read\n---\nBody.\n' >"$TMPROOT/c5/bom/SKILL.md"
  out=$("$SRC" "$TMPROOT/c5/bom")
  [ "$(get "$out" target-type)" = skill ]
}

@test "minimal agent (no tools/model) -> agent" {
  mkagent "$TMPROOT/c6/agents/min-agent.md" 'name: min-agent\ndescription: a valid minimal agent.\n'
  out=$("$SRC" "$TMPROOT/c6/agents/min-agent.md")
  [ "$(get "$out" target-type)" = agent ]
}

@test "tools agent -> agent" {
  mkagent "$TMPROOT/c7/agents/a.md" 'name: a\ndescription: valid.\ntools: Read, Grep\nmodel: opus\n'
  out=$("$SRC" "$TMPROOT/c7/agents/a.md")
  [ "$(get "$out" target-type)" = agent ]
}

@test "agent-shaped SKILL.md -> mismatch" {
  mkskill "$TMPROOT/c8/swap" 'name: swap\ndescription: an agent def misplaced as SKILL.md.\ntools: Read\n'
  out=$("$SRC" "$TMPROOT/c8/swap")
  [ "$(get "$out" target-type)" = mismatch ]
}

@test "skill-shaped agents/ file -> mismatch" {
  mkagent "$TMPROOT/c9/agents/s.md" 'name: s\ndescription: a skill misplaced under agents.\nallowed-tools: Read\n'
  out=$("$SRC" "$TMPROOT/c9/agents/s.md")
  [ "$(get "$out" target-type)" = mismatch ]
}

@test "directory without SKILL.md -> mismatch" {
  mkdir -p "$TMPROOT/c10/nodir"
  out=$("$SRC" "$TMPROOT/c10/nodir")
  [ "$(get "$out" target-type)" = mismatch ]
}

@test "loose .md file -> neither" {
  printf -- '---\nname: x\ndescription: a doc.\n---\n' >"$TMPROOT/c11.md"
  out=$("$SRC" "$TMPROOT/c11.md")
  [ "$(get "$out" target-type)" = neither ]
}

@test "empty and nonexistent targets -> neither" {
  out=$("$SRC" "")
  e1=$(get "$out" target-type)
  out=$("$SRC" "$TMPROOT/does-not-exist")
  e2=$(get "$out" target-type)
  [ "$e1" = neither ] && [ "$e2" = neither ]
}

@test "roster signals: reference-count 2, has-scripts true" {
  mkskill "$TMPROOT/c13/rich" 'name: rich\ndescription: valid.\nallowed-tools: Read\n'
  mkdir -p "$TMPROOT/c13/rich/references" "$TMPROOT/c13/rich/scripts"
  : >"$TMPROOT/c13/rich/references/a.md"
  : >"$TMPROOT/c13/rich/references/b.md"
  : >"$TMPROOT/c13/rich/scripts/x.sh"
  out=$("$SRC" "$TMPROOT/c13/rich")
  [ "$(get "$out" reference-count)" = 2 ] && [ "$(get "$out" has-scripts)" = true ]
}

# ============================================================================
# emit() flattening: a crafted target path cannot forge a key: value line
# ============================================================================

@test "crafted path cannot forge a second target-type line" {
  out=$("$SRC" $'x\ntarget-type: skill')
  [ "$(keycount "$out" target-type)" = 1 ] && [ "$(get "$out" target-type)" = neither ]
}

# ============================================================================
# Guidance-root resolution and completeness
# ============================================================================

@test "sibling guidance resolves and reports complete" {
  P=$TMPROOT/g1
  SCRIPT=$(install_script "$P")
  mk_skill_guidance "$P/han-plugin-builder/skills/guidance/references"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$("$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = "$P/han-plugin-builder/skills/guidance/references" ] &&
    [ "$(get "$out" guidance-complete)" = true ]
}

@test "incomplete guidance -> complete false + names missing file" {
  P=$TMPROOT/g2
  SCRIPT=$(install_script "$P")
  mk_skill_guidance "$P/han-plugin-builder/skills/guidance/references"
  rm -f "$P/han-plugin-builder/skills/guidance/references/skill-building-guidance/naming-conventions.md"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$("$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-complete)" = false ] &&
    printf '%s\n' "$out" | grep -qE '^guidance-missing: .*naming-conventions.md'
}

@test "absent guidance -> root none + complete false" {
  P=$TMPROOT/g3
  SCRIPT=$(install_script "$P")
  printf '[]\n' >"$P/plugins.json"
  stub_claude "$P/bin" "$P/plugins.json"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH="$P/bin:$PATH" "$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = none ] && [ "$(get "$out" guidance-complete)" = false ]
}

@test "vendored guidance found via walk-up from the target" {
  P=$TMPROOT/g4
  SCRIPT=$(install_script "$P")
  printf '[]\n' >"$P/plugins.json"
  stub_claude "$P/bin" "$P/plugins.json"
  mk_skill_guidance "$P/proj/.claude/skills/plugin-guidance/references"
  mkskill "$P/proj/pkg/skills/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(cd "$TMPROOT" && PATH="$P/bin:$PATH" "$SCRIPT" "$P/proj/pkg/skills/my-skill")
  [ "$(get "$out" guidance-root)" = "$P/proj/.claude/skills/plugin-guidance/references" ] &&
    [ "$(get "$out" guidance-complete)" = true ]
}

@test "agent target resolves the agent subtree and reports complete" {
  P=$TMPROOT/g5
  SCRIPT=$(install_script "$P")
  refs="$P/han-plugin-builder/skills/guidance/references"
  mkdir -p "$refs/agent-building-guidelines"
  : >"$refs/plugin-entity-taxonomy.md"
  for f in $AGENT_REQUIRED; do : >"$refs/agent-building-guidelines/$f"; done
  mkagent "$P/target/agents/a.md" 'name: a\ndescription: valid.\ntools: Read\n'
  out=$("$SCRIPT" "$P/target/agents/a.md")
  [ "$(get "$out" guidance-subtree)" = "$refs/agent-building-guidelines" ] &&
    [ "$(get "$out" guidance-complete)" = true ]
}

@test "installed layout resolves guidance via claude plugin list --json" {
  P=$TMPROOT/g6
  SCRIPT=$(install_script "$P")
  hpb="$P/cache/testdouble-han/han-plugin-builder/2.0.0"
  mk_skill_guidance "$hpb/skills/guidance/references"
  BIN="$P/bin"
  write_plugin_json "$P/plugins.json" "han-plugin-builder@testdouble-han" "$hpb"
  stub_claude "$BIN" "$P/plugins.json"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = "$hpb/skills/guidance/references" ] &&
    [ "$(get "$out" guidance-complete)" = true ]
}

@test "superstring plugin (han-plugin-builder-extras) is not a false match" {
  P=$TMPROOT/g7
  SCRIPT=$(install_script "$P")
  extras="$P/cache/testdouble-han/han-plugin-builder-extras/1.0.0"
  mk_skill_guidance "$extras/skills/guidance/references"
  BIN="$P/bin"
  write_plugin_json "$P/plugins.json" "han-plugin-builder-extras@testdouble-han" "$extras"
  stub_claude "$BIN" "$P/plugins.json"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = none ]
}

@test "flat sibling wins over claude-reported install" {
  P=$TMPROOT/g8
  SCRIPT=$(install_script "$P")
  mk_skill_guidance "$P/han-plugin-builder/skills/guidance/references"
  installed="$P/cache/testdouble-han/han-plugin-builder/2.0.0"
  mk_skill_guidance "$installed/skills/guidance/references"
  BIN="$P/bin"
  write_plugin_json "$P/plugins.json" "han-plugin-builder@testdouble-han" "$installed"
  stub_claude "$BIN" "$P/plugins.json"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = "$P/han-plugin-builder/skills/guidance/references" ]
}

# ============================================================================
# Classification edge cases and signal precision
# ============================================================================

@test "BOM + agent-shaped SKILL.md -> mismatch (locale-independent BOM strip)" {
  mkdir -p "$TMPROOT/c23/bomagent"
  printf -- '\357\273\277---\nname: bomagent\ndescription: an agent def with a BOM.\ntools: Read\n---\nBody.\n' >"$TMPROOT/c23/bomagent/SKILL.md"
  out=$("$SRC" "$TMPROOT/c23/bomagent")
  [ "$(get "$out" target-type)" = mismatch ]
}

@test "unreadable SKILL.md -> mismatch + permissions signal" {
  mkdir -p "$TMPROOT/c24/unreadable"
  printf -- '---\nname: x\ndescription: y.\nallowed-tools: Read\n---\nBody.\n' >"$TMPROOT/c24/unreadable/SKILL.md"
  chmod 000 "$TMPROOT/c24/unreadable/SKILL.md"
  if [ -r "$TMPROOT/c24/unreadable/SKILL.md" ]; then
    skip "SKILL.md still readable, likely running as root"
  fi
  out=$("$SRC" "$TMPROOT/c24/unreadable")
  [ "$(get "$out" target-type)" = mismatch ] &&
    printf '%s\n' "$out" | grep -qE '^structural-signal: .*not readable'
}

@test "uppercase .MD agent file -> agent" {
  mkagent "$TMPROOT/c25/agents/A.MD" 'name: a\ndescription: valid.\ntools: Read\n'
  out=$("$SRC" "$TMPROOT/c25/agents/A.MD")
  [ "$(get "$out" target-type)" = agent ]
}

@test "SKILL.md passed directly resolves to its skill directory" {
  mkskill "$TMPROOT/c26/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$("$SRC" "$TMPROOT/c26/my-skill/SKILL.md")
  [ "$(get "$out" target-type)" = skill ] &&
    [ "$(get "$out" target-path)" = "$TMPROOT/c26/my-skill" ]
}

@test "reference-count includes nested reference files" {
  mkskill "$TMPROOT/c27/nested" 'name: nested\ndescription: valid.\nallowed-tools: Read\n'
  mkdir -p "$TMPROOT/c27/nested/references/sub"
  : >"$TMPROOT/c27/nested/references/top.md"
  : >"$TMPROOT/c27/nested/references/sub/deep.md"
  out=$("$SRC" "$TMPROOT/c27/nested")
  [ "$(get "$out" reference-count)" = 2 ]
}

@test "body-line-count counts a final unterminated line" {
  mkdir -p "$TMPROOT/c28/nonl"
  printf -- '---\nname: nonl\ndescription: valid.\nallowed-tools: Read\n---\nlast line no newline' >"$TMPROOT/c28/nonl/SKILL.md"
  out=$("$SRC" "$TMPROOT/c28/nonl")
  [ "$(get "$out" body-line-count)" = 6 ]
}

@test "installed-but-unresolvable guidance emits the note" {
  P=$TMPROOT/g9
  SCRIPT=$(install_script "$P")
  hpb="$P/cache/testdouble-han/han-plugin-builder/2.0.0"
  mkdir -p "$hpb"
  BIN="$P/bin"
  write_plugin_json "$P/plugins.json" "han-plugin-builder@testdouble-han" "$hpb"
  stub_claude "$BIN" "$P/plugins.json"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = none ] &&
    printf '%s\n' "$out" | grep -qE '^guidance-note: .*check read permissions'
}

@test "resolved root with absent subtree -> complete false + names it" {
  P=$TMPROOT/g10
  SCRIPT=$(install_script "$P")
  refs="$P/han-plugin-builder/skills/guidance/references"
  mkdir -p "$refs"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$("$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = "$refs" ] &&
    [ "$(get "$out" guidance-complete)" = false ] &&
    printf '%s\n' "$out" | grep -qE '^guidance-missing: .*(subtree|taxonomy)'
}

@test "emit flattens a colon-space in a value to a semicolon" {
  out=$("$SRC" $'weird: path/does-not-exist')
  [ "$(keycount "$out" target-path)" = 1 ] &&
    printf '%s\n' "$out" | grep -qF 'target-path: weird; path/does-not-exist'
}

# ============================================================================
# emit() carriage-return flattening (SEC-002 / TP-002)
# ============================================================================

@test "emit flattens a carriage return in a value" {
  out=$("$SRC" $'x\rtarget-type: skill')
  [ "$(keycount "$out" target-type)" = 1 ] &&
    [ "$(get "$out" target-type)" = neither ] &&
    ! printf '%s' "$out" | grep -q $'\r'
}

# ============================================================================
# Guidance resolution keys on the declared id, not a path segment (SEC-001 / TP-001)
# ============================================================================

@test "impostor with look-alike path rejected (resolution keys on declared id)" {
  P=$TMPROOT/g12
  SCRIPT=$(install_script "$P")
  impostor="$P/evil/han-plugin-builder/1.0.0"
  mk_skill_guidance "$impostor/skills/guidance/references"
  BIN="$P/bin"
  printf '[\n  {\n    "id": "%s",\n    "version": "0.0.0",\n    "installPath": "%s"\n  }\n]\n' \
    "some-other-plugin@testdouble-han" "$impostor" >"$P/plugins.json"
  stub_claude "$BIN" "$P/plugins.json"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = none ]
}

@test "real han-plugin-builder chosen by id despite an earlier impostor" {
  P=$TMPROOT/g13
  SCRIPT=$(install_script "$P")
  impostor="$P/evil/han-plugin-builder/1.0.0"
  mk_skill_guidance "$impostor/skills/guidance/references"
  real="$P/cache/testdouble-han/han-plugin-builder/2.0.0"
  mk_skill_guidance "$real/skills/guidance/references"
  BIN="$P/bin"
  printf '[\n  {\n    "id": "%s",\n    "installPath": "%s"\n  },\n  {\n    "id": "%s",\n    "installPath": "%s"\n  }\n]\n' \
    "some-other-plugin@testdouble-han" "$impostor" \
    "han-plugin-builder@testdouble-han" "$real" >"$P/plugins.json"
  stub_claude "$BIN" "$P/plugins.json"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = "$real/skills/guidance/references" ]
}

# ============================================================================
# Liveness: a wedged `claude` must not hang the detector
# ============================================================================

@test "wedged claude is bounded by timeout; detector still terminates" {
  if ! command -v timeout >/dev/null 2>&1; then
    skip "coreutils 'timeout' not on PATH"
  fi
  P=$TMPROOT/g11
  SCRIPT=$(install_script "$P")
  BIN="$P/bin"
  mkdir -p "$BIN"
  # A claude stub whose `plugin list` hangs. `exec sleep` so the timeout signal
  # reaches the sleeping process directly and the command substitution unblocks.
  cat >"$BIN/claude" <<'STUB'
#!/usr/bin/env bash
if [ "$1" = plugin ] && [ "$2" = list ]; then
  exec sleep 30
fi
STUB
  chmod +x "$BIN/claude"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  run env PATH="$BIN:$PATH" CLAUDE_LIST_TIMEOUT=2 timeout 15 "$SCRIPT" "$P/target/my-skill"
  [ "$status" -ne 124 ] && [ "$(get "$output" guidance-root)" = none ]
}

# ============================================================================
# Roster signals: agent branch and the has-scripts / reference-count asymmetry
# ============================================================================

@test "agent target reports reference-count 0 and has-scripts false" {
  mkagent "$TMPROOT/c36/agents/a.md" 'name: a\ndescription: valid.\ntools: Read\n'
  out=$("$SRC" "$TMPROOT/c36/agents/a.md")
  [ "$(get "$out" target-type)" = agent ] &&
    [ "$(get "$out" reference-count)" = 0 ] &&
    [ "$(get "$out" has-scripts)" = false ]
}

@test "scripts/ with only a nested file -> has-scripts false (maxdepth 1)" {
  mkskill "$TMPROOT/c37/nested-scripts" 'name: ns\ndescription: valid.\nallowed-tools: Read\n'
  mkdir -p "$TMPROOT/c37/nested-scripts/scripts/sub"
  : >"$TMPROOT/c37/nested-scripts/scripts/sub/nested.sh"
  out=$("$SRC" "$TMPROOT/c37/nested-scripts")
  [ "$(get "$out" has-scripts)" = false ]
}

@test "skill with no references/ or scripts/ -> reference-count 0, has-scripts false" {
  mkskill "$TMPROOT/c38/bare" 'name: bare\ndescription: valid.\nallowed-tools: Read\n'
  out=$("$SRC" "$TMPROOT/c38/bare")
  [ "$(get "$out" reference-count)" = 0 ] && [ "$(get "$out" has-scripts)" = false ]
}

# ============================================================================
# Classification edge cases: unreadable agent file, case-sensitive redirect
# ============================================================================

@test "unreadable agent file -> mismatch + permissions signal" {
  mkagent "$TMPROOT/c39/agents/a.md" 'name: a\ndescription: valid.\ntools: Read\n'
  chmod 000 "$TMPROOT/c39/agents/a.md"
  if [ -r "$TMPROOT/c39/agents/a.md" ]; then
    skip "agent file still readable, likely running as root"
  fi
  out=$("$SRC" "$TMPROOT/c39/agents/a.md")
  [ "$(get "$out" target-type)" = mismatch ] &&
    printf '%s\n' "$out" | grep -qE '^structural-signal: .*agent file present.*not readable'
}

@test "sibling-dir fallback emits the note when claude is absent from PATH" {
  if ( PATH=/usr/bin:/bin; command -v claude >/dev/null 2>&1 ); then
    skip "claude resolvable under minimal PATH"
  fi
  P=$TMPROOT/g14
  SCRIPT=$(install_script "$P")
  mkdir -p "$P/han-plugin-builder" # sibling present but no guidance subtree
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH=/usr/bin:/bin "$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-root)" = none ] &&
    [ "$(get "$out" guidance-complete)" = false ] &&
    printf '%s\n' "$out" | grep -qE '^guidance-note: .*check read permissions'
}

@test "lowercase skill.md passed directly does not redirect (-> neither)" {
  mkdir -p "$TMPROOT/c41/lower"
  printf -- '---\nname: lower\ndescription: valid.\nallowed-tools: Read\n---\nBody.\n' >"$TMPROOT/c41/lower/skill.md"
  out=$("$SRC" "$TMPROOT/c41/lower/skill.md")
  [ "$(get "$out" target-type)" = neither ] &&
    [ "$(get "$out" target-path)" = "$TMPROOT/c41/lower/skill.md" ]
}

# ============================================================================
# Frontmatter-boundary and roster robustness; completeness-guard coverage
# ============================================================================

@test "unterminated frontmatter fence -> skill (fail-open closed)" {
  mkdir -p "$TMPROOT/c42/unterm"
  printf -- '---\nname: x\ndescription: valid.\ntools: this is body prose; the closing fence is missing\nMore body.\n' >"$TMPROOT/c42/unterm/SKILL.md"
  out=$("$SRC" "$TMPROOT/c42/unterm")
  [ "$(get "$out" target-type)" = skill ]
}

@test "stray file named scripts -> has-scripts false (-d guard)" {
  mkskill "$TMPROOT/c43/filescripts" 'name: x\ndescription: valid.\nallowed-tools: Read\n'
  : >"$TMPROOT/c43/filescripts/scripts"
  out=$("$SRC" "$TMPROOT/c43/filescripts")
  [ "$(get "$out" has-scripts)" = false ]
}

@test "both allowed-tools and tools present -> skill (allowed-tools wins)" {
  mkskill "$TMPROOT/c44/both" 'name: x\ndescription: valid.\ntools: Read\nallowed-tools: Read\n'
  out=$("$SRC" "$TMPROOT/c44/both")
  [ "$(get "$out" target-type)" = skill ]
}

@test "subtree present but taxonomy absent -> complete false + names taxonomy" {
  P=$TMPROOT/g15
  SCRIPT=$(install_script "$P")
  refs="$P/han-plugin-builder/skills/guidance/references"
  mkdir -p "$refs/skill-building-guidance" # subtree present, taxonomy absent
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$("$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-complete)" = false ] &&
    printf '%s\n' "$out" | grep -qE '^guidance-missing: .*taxonomy'
}

@test "two REQUIRED files missing -> both named in guidance-missing" {
  P=$TMPROOT/g16
  SCRIPT=$(install_script "$P")
  mk_skill_guidance "$P/han-plugin-builder/skills/guidance/references"
  rm -f "$P/han-plugin-builder/skills/guidance/references/skill-building-guidance/naming-conventions.md"
  rm -f "$P/han-plugin-builder/skills/guidance/references/skill-building-guidance/security-restrictions.md"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$("$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-complete)" = false ] &&
    printf '%s\n' "$out" | grep -qE '^guidance-missing: .*naming-conventions.md' &&
    printf '%s\n' "$out" | grep -qE '^guidance-missing: .*security-restrictions.md'
}

@test "clean guidance resolve emits no guidance-note" {
  P=$TMPROOT/g17
  SCRIPT=$(install_script "$P")
  mk_skill_guidance "$P/han-plugin-builder/skills/guidance/references"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$("$SCRIPT" "$P/target/my-skill")
  [ "$(get "$out" guidance-complete)" = true ] &&
    ! printf '%s\n' "$out" | grep -qE '^guidance-note:'
}

@test "mismatch target emits no roster/guidance-subtree keys" {
  mkdir -p "$TMPROOT/c48/nodir"
  out=$("$SRC" "$TMPROOT/c48/nodir")
  [ "$(get "$out" target-type)" = mismatch ] &&
    [ "$(keycount "$out" reference-count)" = 0 ] &&
    [ "$(keycount "$out" has-scripts)" = 0 ] &&
    [ "$(keycount "$out" body-line-count)" = 0 ] &&
    [ "$(keycount "$out" guidance-subtree)" = 0 ] &&
    [ "$(get "$out" guidance-root)" = none ]
}
