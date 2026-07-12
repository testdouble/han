#!/usr/bin/env bash
# Ephemeral crafted-fixture checks for detect-guidance-and-type-context.sh.
# Usage: detect-guidance-and-type-context.test.sh <path-to-detect-guidance-and-type-context.sh>
#
# Covers the two behaviors the detector owns: target-type classification by
# frontmatter shape (skill / agent / mismatch / neither), keying on the
# type-exclusive allowed-tools / tools fields, tolerant of minimal frontmatter,
# a leading UTF-8 BOM, and CRLF endings; and guidance-root resolution plus
# completeness across the sibling-plugin, installed (via `claude plugin list
# --json`), and repo-local-vendored layouts, including segment-anchoring and
# tier precedence. Also asserts the emit() flattening keeps a crafted target
# path from forging a second key: value line. Pure bash; no jq/python3 (the
# detector's own JSON read uses awk, and a `claude` stub sandboxes it).
set -u

# Resolve the script under test to an absolute path once. Classification is
# location-independent and runs $SRC directly; guidance resolution keys off the
# script's own location (BASH_SOURCE), so those checks copy $SRC into synthetic
# skills/<name>/scripts/ trees to exercise the fallback layouts.
SRC=$(cd "$(dirname -- "$1")" && pwd)/$(basename -- "$1")

PASS=0; FAIL=0
TMPROOT=$(mktemp -d)
trap 'rm -rf "$TMPROOT"' EXIT

ok()   { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

# Extract the value of a `key: value` line (first match wins).
get() { printf '%s\n' "$1" | awk -F': ' -v k="$2" '$1==k{print $2; exit}'; }
# Count physical lines whose key is $2.
keycount() { printf '%s\n' "$1" | grep -cE "^$2: " || true; }

# Write a skill dir at $1 whose frontmatter body is the %b-interpreted $2.
mkskill() { mkdir -p "$1"; { printf -- '---\n'; printf '%b' "$2"; printf -- '---\nBody.\n'; } > "$1/SKILL.md"; }
# Write an agent .md at $1 whose frontmatter body is the %b-interpreted $2.
mkagent() { mkdir -p "$(dirname -- "$1")"; { printf -- '---\n'; printf '%b' "$2"; printf -- '---\nBody.\n'; } > "$1"; }

# The exact REQUIRED lists the detector grounds completeness against.
SKILL_REQUIRED="skill-description-frontmatter.md skill-description-length.md naming-conventions.md progressive-disclosure.md skill-reference-files.md writing-effective-instructions.md workflow-patterns.md allowed-tools-bash-permissions.md allowed-tools-AskUserQuestion.md security-restrictions.md agent-dispatch-namespacing.md graceful-degradation.md dynamic-project-discovery.md optional-git-repositories.md script-execution-instructions.md success-criteria-and-testing.md"
AGENT_REQUIRED="agent-domain-focus.md agent-description-length.md agent-model-selection.md agent-external-files.md multi-agent-economics.md graceful-degradation.md"

# Populate a complete skill-type guidance references tree at $1 (the .../references dir).
mk_skill_guidance() {
  mkdir -p "$1/skill-building-guidance"
  : > "$1/plugin-entity-taxonomy.md"
  for f in $SKILL_REQUIRED; do : > "$1/skill-building-guidance/$f"; done
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
# $2 for `plugin list --json` (and nothing otherwise). Prepend "$1" to PATH when
# running the detector so its `claude plugin list --json` probe is sandboxed away
# from the real environment (where a real han-plugin-builder may be installed).
stub_claude() {
  local bindir="$1" jsonfile="$2"
  mkdir -p "$bindir"
  cat > "$bindir/claude" <<STUB
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
  printf '[\n  {\n    "id": "%s",\n    "version": "0.0.0",\n    "installPath": "%s"\n  }\n]\n' "$2" "$3" > "$1"
}

# ============================================================================
# Target-type classification
# ============================================================================

# 1. Minimal skill: name+description only, no allowed-tools (optional) -> skill.
mkskill "$TMPROOT/c1/minimal" 'name: minimal\ndescription: a valid minimal skill.\n'
out=$("$SRC" "$TMPROOT/c1/minimal")
[ "$(get "$out" target-type)" = skill ] \
  && ok "minimal skill (no allowed-tools) -> skill" \
  || fail "minimal skill (no allowed-tools) -> skill (got: $(get "$out" target-type))"

# 2. Skill declaring allowed-tools -> skill.
mkskill "$TMPROOT/c2/at" 'name: at\ndescription: valid.\nallowed-tools: Read\n'
out=$("$SRC" "$TMPROOT/c2/at")
[ "$(get "$out" target-type)" = skill ] \
  && ok "allowed-tools skill -> skill" \
  || fail "allowed-tools skill -> skill (got: $(get "$out" target-type))"

# 3. Skill declaring only model (a field shared with agents) -> skill, not mismatch.
mkskill "$TMPROOT/c3/model" 'name: model\ndescription: valid.\nmodel: opus\n'
out=$("$SRC" "$TMPROOT/c3/model")
[ "$(get "$out" target-type)" = skill ] \
  && ok "model-only skill -> skill (model is shared, not an agent marker)" \
  || fail "model-only skill -> skill (got: $(get "$out" target-type))"

# 4. CRLF-encoded skill (Windows / core.autocrlf) -> skill.
mkdir -p "$TMPROOT/c4/crlf"
printf -- '---\r\nname: crlf\r\ndescription: valid.\r\nallowed-tools: Read\r\n---\r\nBody.\r\n' > "$TMPROOT/c4/crlf/SKILL.md"
out=$("$SRC" "$TMPROOT/c4/crlf")
[ "$(get "$out" target-type)" = skill ] \
  && ok "CRLF skill -> skill" \
  || fail "CRLF skill -> skill (got: $(get "$out" target-type))"

# 5. UTF-8 BOM + skill -> skill.
mkdir -p "$TMPROOT/c5/bom"
printf -- '\357\273\277---\nname: bom\ndescription: valid.\nallowed-tools: Read\n---\nBody.\n' > "$TMPROOT/c5/bom/SKILL.md"
out=$("$SRC" "$TMPROOT/c5/bom")
[ "$(get "$out" target-type)" = skill ] \
  && ok "BOM skill -> skill" \
  || fail "BOM skill -> skill (got: $(get "$out" target-type))"

# 6. Minimal agent under agents/: name+description only -> agent.
mkagent "$TMPROOT/c6/agents/min-agent.md" 'name: min-agent\ndescription: a valid minimal agent.\n'
out=$("$SRC" "$TMPROOT/c6/agents/min-agent.md")
[ "$(get "$out" target-type)" = agent ] \
  && ok "minimal agent (no tools/model) -> agent" \
  || fail "minimal agent (no tools/model) -> agent (got: $(get "$out" target-type))"

# 7. Agent declaring tools -> agent.
mkagent "$TMPROOT/c7/agents/a.md" 'name: a\ndescription: valid.\ntools: Read, Grep\nmodel: opus\n'
out=$("$SRC" "$TMPROOT/c7/agents/a.md")
[ "$(get "$out" target-type)" = agent ] \
  && ok "tools agent -> agent" \
  || fail "tools agent -> agent (got: $(get "$out" target-type))"

# 8. Swapped: agent-shaped frontmatter (tools:) in a SKILL.md -> mismatch.
mkskill "$TMPROOT/c8/swap" 'name: swap\ndescription: an agent def misplaced as SKILL.md.\ntools: Read\n'
out=$("$SRC" "$TMPROOT/c8/swap")
[ "$(get "$out" target-type)" = mismatch ] \
  && ok "agent-shaped SKILL.md -> mismatch" \
  || fail "agent-shaped SKILL.md -> mismatch (got: $(get "$out" target-type))"

# 9. Swapped: skill-shaped frontmatter (allowed-tools:) under agents/ -> mismatch.
mkagent "$TMPROOT/c9/agents/s.md" 'name: s\ndescription: a skill misplaced under agents.\nallowed-tools: Read\n'
out=$("$SRC" "$TMPROOT/c9/agents/s.md")
[ "$(get "$out" target-type)" = mismatch ] \
  && ok "skill-shaped agents/ file -> mismatch" \
  || fail "skill-shaped agents/ file -> mismatch (got: $(get "$out" target-type))"

# 10. Directory without SKILL.md -> mismatch.
mkdir -p "$TMPROOT/c10/nodir"
out=$("$SRC" "$TMPROOT/c10/nodir")
[ "$(get "$out" target-type)" = mismatch ] \
  && ok "directory without SKILL.md -> mismatch" \
  || fail "directory without SKILL.md -> mismatch (got: $(get "$out" target-type))"

# 11. A .md file that is neither a SKILL.md nor under agents/ -> neither.
printf -- '---\nname: x\ndescription: a doc.\n---\n' > "$TMPROOT/c11.md"
out=$("$SRC" "$TMPROOT/c11.md")
[ "$(get "$out" target-type)" = neither ] \
  && ok "loose .md file -> neither" \
  || fail "loose .md file -> neither (got: $(get "$out" target-type))"

# 12. Empty and nonexistent targets -> neither.
out=$("$SRC" "")
e1=$(get "$out" target-type)
out=$("$SRC" "$TMPROOT/does-not-exist")
e2=$(get "$out" target-type)
{ [ "$e1" = neither ] && [ "$e2" = neither ]; } \
  && ok "empty and nonexistent targets -> neither" \
  || fail "empty and nonexistent targets -> neither (empty: $e1, missing: $e2)"

# 13. Roster signals for a skill: reference-count and has-scripts.
mkskill "$TMPROOT/c13/rich" 'name: rich\ndescription: valid.\nallowed-tools: Read\n'
mkdir -p "$TMPROOT/c13/rich/references" "$TMPROOT/c13/rich/scripts"
: > "$TMPROOT/c13/rich/references/a.md"; : > "$TMPROOT/c13/rich/references/b.md"
: > "$TMPROOT/c13/rich/scripts/x.sh"
out=$("$SRC" "$TMPROOT/c13/rich")
{ [ "$(get "$out" reference-count)" = 2 ] && [ "$(get "$out" has-scripts)" = true ]; } \
  && ok "roster signals: reference-count 2, has-scripts true" \
  || fail "roster signals (ref-count: $(get "$out" reference-count), has-scripts: $(get "$out" has-scripts))"

# ============================================================================
# emit() flattening: a crafted target path cannot forge a key: value line
# ============================================================================

# 14. A target path carrying a newline + a fake key must not add a second
# target-type line; the sole authoritative one still reads neither.
out=$("$SRC" $'x\ntarget-type: skill')
{ [ "$(keycount "$out" target-type)" = 1 ] && [ "$(get "$out" target-type)" = neither ]; } \
  && ok "crafted path cannot forge a second target-type line" \
  || fail "crafted path cannot forge a second target-type line (count: $(keycount "$out" target-type), value: $(get "$out" target-type))"

# ============================================================================
# Guidance-root resolution and completeness
# ============================================================================

# 15. Sibling han-plugin-builder, flat layout, complete tree -> resolves + complete.
P=$TMPROOT/g1
SCRIPT=$(install_script "$P")
mk_skill_guidance "$P/han-plugin-builder/skills/guidance/references"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$("$SCRIPT" "$P/target/my-skill")
{ [ "$(get "$out" guidance-root)" = "$P/han-plugin-builder/skills/guidance/references" ] \
  && [ "$(get "$out" guidance-complete)" = true ]; } \
  && ok "sibling guidance resolves and reports complete" \
  || fail "sibling guidance resolves and reports complete (root: $(get "$out" guidance-root), complete: $(get "$out" guidance-complete))"

# 16. Sibling present but one REQUIRED file missing -> complete false + names it.
P=$TMPROOT/g2
SCRIPT=$(install_script "$P")
mk_skill_guidance "$P/han-plugin-builder/skills/guidance/references"
rm -f "$P/han-plugin-builder/skills/guidance/references/skill-building-guidance/naming-conventions.md"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$("$SCRIPT" "$P/target/my-skill")
{ [ "$(get "$out" guidance-complete)" = false ] \
  && printf '%s\n' "$out" | grep -qE '^guidance-missing: .*naming-conventions.md'; } \
  && ok "incomplete guidance -> complete false + names missing file" \
  || fail "incomplete guidance -> complete false + names missing file (complete: $(get "$out" guidance-complete), missing: $(get "$out" guidance-missing))"

# 17. No guidance anywhere, nothing installed -> guidance-root none, complete false.
P=$TMPROOT/g3
SCRIPT=$(install_script "$P")
printf '[]\n' > "$P/plugins.json"; stub_claude "$P/bin" "$P/plugins.json"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$(PATH="$P/bin:$PATH" "$SCRIPT" "$P/target/my-skill")
{ [ "$(get "$out" guidance-root)" = none ] && [ "$(get "$out" guidance-complete)" = false ]; } \
  && ok "absent guidance -> root none + complete false" \
  || fail "absent guidance -> root none + complete false (root: $(get "$out" guidance-root), complete: $(get "$out" guidance-complete))"

# 18. Repo-local vendored copy found by walking up from the target (not the CWD),
# with nothing installed via claude so resolution falls through to the vendored copy.
P=$TMPROOT/g4
SCRIPT=$(install_script "$P")
printf '[]\n' > "$P/plugins.json"; stub_claude "$P/bin" "$P/plugins.json"
mk_skill_guidance "$P/proj/.claude/skills/plugin-guidance/references"
mkskill "$P/proj/pkg/skills/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$(cd "$TMPROOT" && PATH="$P/bin:$PATH" "$SCRIPT" "$P/proj/pkg/skills/my-skill")
{ [ "$(get "$out" guidance-root)" = "$P/proj/.claude/skills/plugin-guidance/references" ] \
  && [ "$(get "$out" guidance-complete)" = true ]; } \
  && ok "vendored guidance found via walk-up from the target" \
  || fail "vendored guidance found via walk-up from the target (root: $(get "$out" guidance-root))"

# 19. Agent target grounds against the agent-building-guidelines subtree.
P=$TMPROOT/g5
SCRIPT=$(install_script "$P")
refs="$P/han-plugin-builder/skills/guidance/references"
mkdir -p "$refs/agent-building-guidelines"
: > "$refs/plugin-entity-taxonomy.md"
for f in $AGENT_REQUIRED; do : > "$refs/agent-building-guidelines/$f"; done
mkagent "$P/target/agents/a.md" 'name: a\ndescription: valid.\ntools: Read\n'
out=$("$SCRIPT" "$P/target/agents/a.md")
{ [ "$(get "$out" guidance-subtree)" = "$refs/agent-building-guidelines" ] \
  && [ "$(get "$out" guidance-complete)" = true ]; } \
  && ok "agent target resolves the agent subtree and reports complete" \
  || fail "agent target resolves the agent subtree and reports complete (subtree: $(get "$out" guidance-subtree), complete: $(get "$out" guidance-complete))"

# 20. Installed marketplace-cache layout: han-plugin-builder is NOT a flat
# sibling; its guidance is located via `claude plugin list --json`.installPath.
# This is the layout the old relative-path search silently failed under.
P=$TMPROOT/g6
SCRIPT=$(install_script "$P")
hpb="$P/cache/testdouble-han/han-plugin-builder/2.0.0"
mk_skill_guidance "$hpb/skills/guidance/references"
BIN="$P/bin"
write_plugin_json "$P/plugins.json" "han-plugin-builder@testdouble-han" "$hpb"
stub_claude "$BIN" "$P/plugins.json"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
{ [ "$(get "$out" guidance-root)" = "$hpb/skills/guidance/references" ] \
  && [ "$(get "$out" guidance-complete)" = true ]; } \
  && ok "installed layout resolves guidance via claude plugin list --json" \
  || fail "installed layout resolves guidance via claude plugin list (root: $(get "$out" guidance-root), complete: $(get "$out" guidance-complete))"

# 21. A superstring plugin (han-plugin-builder-extras) is NOT mistaken for
# han-plugin-builder: with only extras installed, resolution falls through to
# none rather than pointing at the wrong plugin's guidance.
P=$TMPROOT/g7
SCRIPT=$(install_script "$P")
extras="$P/cache/testdouble-han/han-plugin-builder-extras/1.0.0"
mk_skill_guidance "$extras/skills/guidance/references"
BIN="$P/bin"
write_plugin_json "$P/plugins.json" "han-plugin-builder-extras@testdouble-han" "$extras"
stub_claude "$BIN" "$P/plugins.json"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
[ "$(get "$out" guidance-root)" = none ] \
  && ok "superstring plugin (han-plugin-builder-extras) is not a false match" \
  || fail "superstring plugin wrongly matched (root: $(get "$out" guidance-root))"

# 22. Precedence: a checked-out flat sibling wins over an installed copy the CLI
# reports, so a maintainer editing the repo reads the repo's guidance, not a
# possibly-stale installed one.
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
[ "$(get "$out" guidance-root)" = "$P/han-plugin-builder/skills/guidance/references" ] \
  && ok "flat sibling wins over claude-reported install" \
  || fail "precedence: expected sibling, got $(get "$out" guidance-root)"

# ============================================================================
# Classification edge cases and signal precision
# ============================================================================

# 23. BOM + agent-shaped frontmatter in a SKILL.md -> mismatch. Distinguishes a
# working (locale-independent) BOM strip from the directory default masking it:
# without the strip the frontmatter is unreadable and the dir default (skill) wins.
mkdir -p "$TMPROOT/c23/bomagent"
printf -- '\357\273\277---\nname: bomagent\ndescription: an agent def with a BOM.\ntools: Read\n---\nBody.\n' > "$TMPROOT/c23/bomagent/SKILL.md"
out=$("$SRC" "$TMPROOT/c23/bomagent")
[ "$(get "$out" target-type)" = mismatch ] \
  && ok "BOM + agent-shaped SKILL.md -> mismatch (locale-independent BOM strip)" \
  || fail "BOM + agent-shaped SKILL.md -> mismatch (got: $(get "$out" target-type))"

# 24. Unreadable SKILL.md -> mismatch with a permissions signal, not a silent
# skill default. Skipped where chmod 000 stays readable (e.g. running as root).
mkdir -p "$TMPROOT/c24/unreadable"
printf -- '---\nname: x\ndescription: y.\nallowed-tools: Read\n---\nBody.\n' > "$TMPROOT/c24/unreadable/SKILL.md"
chmod 000 "$TMPROOT/c24/unreadable/SKILL.md"
if [ -r "$TMPROOT/c24/unreadable/SKILL.md" ]; then
  echo "SKIP: unreadable SKILL.md test (file still readable, likely running as root)"
else
  out=$("$SRC" "$TMPROOT/c24/unreadable")
  { [ "$(get "$out" target-type)" = mismatch ] \
    && printf '%s\n' "$out" | grep -qE '^structural-signal: .*not readable'; } \
    && ok "unreadable SKILL.md -> mismatch + permissions signal" \
    || fail "unreadable SKILL.md -> mismatch + permissions signal (type: $(get "$out" target-type), signal: $(get "$out" structural-signal))"
fi
chmod 644 "$TMPROOT/c24/unreadable/SKILL.md" 2>/dev/null || true

# 25. Uppercase .MD extension under agents/ still classifies as agent.
mkagent "$TMPROOT/c25/agents/A.MD" 'name: a\ndescription: valid.\ntools: Read\n'
out=$("$SRC" "$TMPROOT/c25/agents/A.MD")
[ "$(get "$out" target-type)" = agent ] \
  && ok "uppercase .MD agent file -> agent" \
  || fail "uppercase .MD agent file -> agent (got: $(get "$out" target-type))"

# 26. A SKILL.md passed directly (not its directory) resolves to the skill dir.
mkskill "$TMPROOT/c26/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$("$SRC" "$TMPROOT/c26/my-skill/SKILL.md")
{ [ "$(get "$out" target-type)" = skill ] \
  && [ "$(get "$out" target-path)" = "$TMPROOT/c26/my-skill" ]; } \
  && ok "SKILL.md passed directly resolves to its skill directory" \
  || fail "SKILL.md passed directly -> skill dir (type: $(get "$out" target-type), path: $(get "$out" target-path))"

# 27. reference-count includes reference .md files nested in subdirectories.
mkskill "$TMPROOT/c27/nested" 'name: nested\ndescription: valid.\nallowed-tools: Read\n'
mkdir -p "$TMPROOT/c27/nested/references/sub"
: > "$TMPROOT/c27/nested/references/top.md"
: > "$TMPROOT/c27/nested/references/sub/deep.md"
out=$("$SRC" "$TMPROOT/c27/nested")
[ "$(get "$out" reference-count)" = 2 ] \
  && ok "reference-count includes nested reference files" \
  || fail "reference-count includes nested reference files (got: $(get "$out" reference-count))"

# 28. body-line-count counts a final line with no trailing newline (6 real lines).
mkdir -p "$TMPROOT/c28/nonl"
printf -- '---\nname: nonl\ndescription: valid.\nallowed-tools: Read\n---\nlast line no newline' > "$TMPROOT/c28/nonl/SKILL.md"
out=$("$SRC" "$TMPROOT/c28/nonl")
[ "$(get "$out" body-line-count)" = 6 ] \
  && ok "body-line-count counts a final unterminated line" \
  || fail "body-line-count counts a final unterminated line (got: $(get "$out" body-line-count))"

# 29. han-plugin-builder installed but its guidance/references subtree absent ->
# guidance-root none AND the present-but-unresolvable note (exercises SUGG-007's
# capture-then-test path in the note branch).
P=$TMPROOT/g9
SCRIPT=$(install_script "$P")
hpb="$P/cache/testdouble-han/han-plugin-builder/2.0.0"
mkdir -p "$hpb"
BIN="$P/bin"
write_plugin_json "$P/plugins.json" "han-plugin-builder@testdouble-han" "$hpb"
stub_claude "$BIN" "$P/plugins.json"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
{ [ "$(get "$out" guidance-root)" = none ] \
  && printf '%s\n' "$out" | grep -qE '^guidance-note: .*check read permissions'; } \
  && ok "installed-but-unresolvable guidance emits the note" \
  || fail "installed-but-unresolvable guidance emits the note (root: $(get "$out" guidance-root), notes: $(printf '%s\n' "$out" | grep -c '^guidance-note:'))"

# 30. Guidance root resolves but the type subtree / taxonomy is absent ->
# complete false + guidance-missing names it (distinct from one REQUIRED file gone).
P=$TMPROOT/g10
SCRIPT=$(install_script "$P")
refs="$P/han-plugin-builder/skills/guidance/references"
mkdir -p "$refs"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$("$SCRIPT" "$P/target/my-skill")
{ [ "$(get "$out" guidance-root)" = "$refs" ] \
  && [ "$(get "$out" guidance-complete)" = false ] \
  && printf '%s\n' "$out" | grep -qE '^guidance-missing: .*(subtree|taxonomy)'; } \
  && ok "resolved root with absent subtree -> complete false + names it" \
  || fail "resolved root with absent subtree (root: $(get "$out" guidance-root), complete: $(get "$out" guidance-complete), missing: $(get "$out" guidance-missing))"

# 31. emit() flattens a ": " in a value to "; " so a crafted target path cannot
# forge a second key: value line.
out=$("$SRC" $'weird: path/does-not-exist')
{ [ "$(keycount "$out" target-path)" = 1 ] \
  && printf '%s\n' "$out" | grep -qF 'target-path: weird; path/does-not-exist'; } \
  && ok "emit flattens a colon-space in a value to a semicolon" \
  || fail "emit flattens a colon-space in a value ($(printf '%s\n' "$out" | grep '^target-path:'))"

# ============================================================================
# emit() carriage-return flattening (SEC-002 / TP-002)
# ============================================================================

# 32. emit() flattens a carriage return in a value — the missing member of the
# newline / ": " set — so a crafted target path cannot split a key: value line for
# a downstream reader that treats a carriage return as a line break.
out=$("$SRC" $'x\rtarget-type: skill')
{ [ "$(keycount "$out" target-type)" = 1 ] \
  && [ "$(get "$out" target-type)" = neither ] \
  && ! printf '%s' "$out" | grep -q $'\r'; } \
  && ok "emit flattens a carriage return in a value" \
  || fail "emit flattens a carriage return (count: $(keycount "$out" target-type), value: $(get "$out" target-type))"

# ============================================================================
# Guidance resolution keys on the declared id, not a path segment (SEC-001 / TP-001)
# ============================================================================

# 33. An unrelated plugin cached under a look-alike /han-plugin-builder/ path must
# NOT be selected when no entry's declared id is actually han-plugin-builder@… —
# resolution keys on the id field, not on the path carrying the segment.
P=$TMPROOT/g12
SCRIPT=$(install_script "$P")
impostor="$P/evil/han-plugin-builder/1.0.0"
mk_skill_guidance "$impostor/skills/guidance/references"
BIN="$P/bin"
printf '[\n  {\n    "id": "%s",\n    "version": "0.0.0",\n    "installPath": "%s"\n  }\n]\n' \
  "some-other-plugin@testdouble-han" "$impostor" > "$P/plugins.json"
stub_claude "$BIN" "$P/plugins.json"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
[ "$(get "$out" guidance-root)" = none ] \
  && ok "impostor with look-alike path rejected (resolution keys on declared id)" \
  || fail "impostor with look-alike path wrongly selected (root: $(get "$out" guidance-root))"

# 34. With the real han-plugin-builder listed AFTER an impostor whose path also
# carries the segment, the real one is still chosen — selection keys on id, not on
# list position or a path-segment match.
P=$TMPROOT/g13
SCRIPT=$(install_script "$P")
impostor="$P/evil/han-plugin-builder/1.0.0"
mk_skill_guidance "$impostor/skills/guidance/references"
real="$P/cache/testdouble-han/han-plugin-builder/2.0.0"
mk_skill_guidance "$real/skills/guidance/references"
BIN="$P/bin"
printf '[\n  {\n    "id": "%s",\n    "installPath": "%s"\n  },\n  {\n    "id": "%s",\n    "installPath": "%s"\n  }\n]\n' \
  "some-other-plugin@testdouble-han" "$impostor" \
  "han-plugin-builder@testdouble-han" "$real" > "$P/plugins.json"
stub_claude "$BIN" "$P/plugins.json"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$(PATH="$BIN:$PATH" "$SCRIPT" "$P/target/my-skill")
[ "$(get "$out" guidance-root)" = "$real/skills/guidance/references" ] \
  && ok "real han-plugin-builder chosen by id despite an earlier impostor" \
  || fail "id-keyed selection failed (root: $(get "$out" guidance-root))"

# ============================================================================
# Liveness: a wedged `claude` must not hang the detector
# ============================================================================

# 35. A `claude` whose `plugin list` never returns must not hang the detector:
# the CLI probe is bounded by a timeout, so resolution falls through to the
# vendored/none tier and the script still terminates and emits guidance-root.
# CLAUDE_LIST_TIMEOUT is set small so the test is fast; an outer `timeout` proves
# the detector returned on its own rather than being reaped. Skipped where the
# coreutils `timeout` command is absent (e.g. a stock macOS without gnu-coreutils),
# since the detector then runs the CLI unbounded by design and there is nothing to
# assert.
if command -v timeout >/dev/null 2>&1; then
  P=$TMPROOT/g11
  SCRIPT=$(install_script "$P")
  BIN="$P/bin"; mkdir -p "$BIN"
  # A claude stub whose `plugin list` hangs. `exec sleep` so the timeout signal
  # reaches the sleeping process directly and the command substitution unblocks
  # (a forked child would outlive the killed shell and hold the pipe open).
  cat > "$BIN/claude" <<'STUB'
#!/usr/bin/env bash
if [ "$1" = plugin ] && [ "$2" = list ]; then
  exec sleep 30
fi
STUB
  chmod +x "$BIN/claude"
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH="$BIN:$PATH" CLAUDE_LIST_TIMEOUT=2 timeout 15 "$SCRIPT" "$P/target/my-skill")
  rc=$?
  { [ "$rc" -ne 124 ] && [ "$(get "$out" guidance-root)" = none ]; } \
    && ok "wedged claude is bounded by timeout; detector still terminates" \
    || fail "wedged claude bounded by timeout (rc: $rc, root: $(get "$out" guidance-root))"
else
  echo "SKIP: claude-hang timeout test (coreutils 'timeout' not on PATH)"
fi

# ============================================================================
# Roster signals: agent branch and the has-scripts / reference-count asymmetry
# ============================================================================

# 36. An agent-typed target always reports reference-count 0 and has-scripts false
# (agents carry no reference tree or scripts dir in this detector's model) — the
# values the caller reads to skip the reference-tree and script-seam reviewers.
mkagent "$TMPROOT/c36/agents/a.md" 'name: a\ndescription: valid.\ntools: Read\n'
out=$("$SRC" "$TMPROOT/c36/agents/a.md")
{ [ "$(get "$out" target-type)" = agent ] \
  && [ "$(get "$out" reference-count)" = 0 ] \
  && [ "$(get "$out" has-scripts)" = false ]; } \
  && ok "agent target reports reference-count 0 and has-scripts false" \
  || fail "agent roster signals (type: $(get "$out" target-type), ref: $(get "$out" reference-count), scripts: $(get "$out" has-scripts))"

# 37. has-scripts uses `find scripts -maxdepth 1`, so a scripts/ dir containing
# ONLY a nested file (no top-level file) reports has-scripts false — deliberately
# asymmetric with reference-count, which counts reference files at any depth.
mkskill "$TMPROOT/c37/nested-scripts" 'name: ns\ndescription: valid.\nallowed-tools: Read\n'
mkdir -p "$TMPROOT/c37/nested-scripts/scripts/sub"
: > "$TMPROOT/c37/nested-scripts/scripts/sub/nested.sh"
out=$("$SRC" "$TMPROOT/c37/nested-scripts")
[ "$(get "$out" has-scripts)" = false ] \
  && ok "scripts/ with only a nested file -> has-scripts false (maxdepth 1)" \
  || fail "nested-only scripts -> has-scripts false (got: $(get "$out" has-scripts))"

# 38. A skill with no references/ and no scripts/ at all reports reference-count 0
# and has-scripts false (find on a missing path is suppressed; ${rc:-0} guards the
# empty result). Also covers reference-count 0 with no references/ directory.
mkskill "$TMPROOT/c38/bare" 'name: bare\ndescription: valid.\nallowed-tools: Read\n'
out=$("$SRC" "$TMPROOT/c38/bare")
{ [ "$(get "$out" reference-count)" = 0 ] && [ "$(get "$out" has-scripts)" = false ]; } \
  && ok "skill with no references/ or scripts/ -> reference-count 0, has-scripts false" \
  || fail "bare skill roster (ref: $(get "$out" reference-count), scripts: $(get "$out" has-scripts))"

# ============================================================================
# Classification edge cases: unreadable agent file, case-sensitive redirect
# ============================================================================

# 39. An unreadable agent .md under agents/ classifies as mismatch with a
# permissions signal (the readfail guard in the */agents/* branch, distinct from
# the directory-SKILL.md readfail path case 24 covers). Skipped where chmod 000
# stays readable (e.g. running as root).
mkagent "$TMPROOT/c39/agents/a.md" 'name: a\ndescription: valid.\ntools: Read\n'
chmod 000 "$TMPROOT/c39/agents/a.md"
if [ -r "$TMPROOT/c39/agents/a.md" ]; then
  echo "SKIP: unreadable agent file test (file still readable, likely running as root)"
else
  out=$("$SRC" "$TMPROOT/c39/agents/a.md")
  { [ "$(get "$out" target-type)" = mismatch ] \
    && printf '%s\n' "$out" | grep -qE '^structural-signal: .*agent file present.*not readable'; } \
    && ok "unreadable agent file -> mismatch + permissions signal" \
    || fail "unreadable agent file -> mismatch + permissions signal (type: $(get "$out" target-type), signal: $(get "$out" structural-signal))"
fi
chmod 644 "$TMPROOT/c39/agents/a.md" 2>/dev/null || true

# 40. When `claude` is absent from PATH entirely, the present-but-unresolvable
# detection falls through to the sibling-directory existence check: a
# han-plugin-builder/ sibling that exists but lacks skills/guidance/references
# still emits the "check read permissions" note. Distinct from case 29, which
# reaches the note via the `claude plugin list --json` route. Skipped if `claude`
# is resolvable under the minimal PATH (then the CLI route, not the fallback, runs).
if ( PATH=/usr/bin:/bin; command -v claude >/dev/null 2>&1 ); then
  echo "SKIP: sibling-dir fallback test (claude resolvable under minimal PATH)"
else
  P=$TMPROOT/g14
  SCRIPT=$(install_script "$P")
  mkdir -p "$P/han-plugin-builder"   # sibling present but no guidance subtree
  mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
  out=$(PATH=/usr/bin:/bin "$SCRIPT" "$P/target/my-skill")
  { [ "$(get "$out" guidance-root)" = none ] \
    && [ "$(get "$out" guidance-complete)" = false ] \
    && printf '%s\n' "$out" | grep -qE '^guidance-note: .*check read permissions'; } \
    && ok "sibling-dir fallback emits the note when claude is absent from PATH" \
    || fail "sibling-dir fallback note (root: $(get "$out" guidance-root), notes: $(printf '%s\n' "$out" | grep -c '^guidance-note:'))"
fi

# 41. The redirect-to-directory logic matches the basename against SKILL.md
# case-sensitively (unlike the extension check, which is lowercased). A lowercase
# skill.md passed directly does NOT redirect to its directory; being outside any
# agents/ path it resolves to neither.
mkdir -p "$TMPROOT/c41/lower"
printf -- '---\nname: lower\ndescription: valid.\nallowed-tools: Read\n---\nBody.\n' > "$TMPROOT/c41/lower/skill.md"
out=$("$SRC" "$TMPROOT/c41/lower/skill.md")
{ [ "$(get "$out" target-type)" = neither ] \
  && [ "$(get "$out" target-path)" = "$TMPROOT/c41/lower/skill.md" ]; } \
  && ok "lowercase skill.md passed directly does not redirect (-> neither)" \
  || fail "lowercase skill.md -> neither (type: $(get "$out" target-type), path: $(get "$out" target-path))"

# ============================================================================
# Frontmatter-boundary and roster robustness; completeness-guard coverage
# ============================================================================

# 42. An unterminated frontmatter block (opening --- with no closing ---) no
# longer fails open: the extractor emits nothing, frontmatter_shape returns
# unknown, and a skill directory defers to its location (-> skill) instead of
# scanning the body for the stray column-0 tools: line below the missing fence.
mkdir -p "$TMPROOT/c42/unterm"
printf -- '---\nname: x\ndescription: valid.\ntools: this is body prose; the closing fence is missing\nMore body.\n' > "$TMPROOT/c42/unterm/SKILL.md"
out=$("$SRC" "$TMPROOT/c42/unterm")
[ "$(get "$out" target-type)" = skill ] \
  && ok "unterminated frontmatter fence -> skill (fail-open closed)" \
  || fail "unterminated frontmatter fence -> skill (got: $(get "$out" target-type))"

# 43. A stray plain file named `scripts` (not a scripts/ directory) reports
# has-scripts false: the -d guard stops `find <file>` from matching the path
# itself. Regression guard for the missing-guard bug.
mkskill "$TMPROOT/c43/filescripts" 'name: x\ndescription: valid.\nallowed-tools: Read\n'
: > "$TMPROOT/c43/filescripts/scripts"
out=$("$SRC" "$TMPROOT/c43/filescripts")
[ "$(get "$out" has-scripts)" = false ] \
  && ok "stray file named scripts -> has-scripts false (-d guard)" \
  || fail "stray file named scripts -> has-scripts false (got: $(get "$out" has-scripts))"

# 44. Both allowed-tools and tools present in one frontmatter block -> skill: the
# allowed-tools check is evaluated first, so a skill carrying a stray tools: key
# is not demoted to mismatch, regardless of key order (tools listed first here).
mkskill "$TMPROOT/c44/both" 'name: x\ndescription: valid.\ntools: Read\nallowed-tools: Read\n'
out=$("$SRC" "$TMPROOT/c44/both")
[ "$(get "$out" target-type)" = skill ] \
  && ok "both allowed-tools and tools present -> skill (allowed-tools wins)" \
  || fail "both allowed-tools and tools present -> skill (got: $(get "$out" target-type))"

# 45. Guidance root resolves and the type subtree directory EXISTS, but
# plugin-entity-taxonomy.md at the root is absent -> complete false naming the
# taxonomy. Isolates the -f taxonomy half of the line-244 || guard (case 30
# covers the -d subtree half).
P=$TMPROOT/g15
SCRIPT=$(install_script "$P")
refs="$P/han-plugin-builder/skills/guidance/references"
mkdir -p "$refs/skill-building-guidance"          # subtree present, taxonomy absent
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$("$SCRIPT" "$P/target/my-skill")
{ [ "$(get "$out" guidance-complete)" = false ] \
  && printf '%s\n' "$out" | grep -qE '^guidance-missing: .*taxonomy'; } \
  && ok "subtree present but taxonomy absent -> complete false + names taxonomy" \
  || fail "taxonomy-absent half of the guard (complete: $(get "$out" guidance-complete), missing: $(get "$out" guidance-missing))"

# 46. Two REQUIRED files missing at once -> guidance-missing names BOTH: the
# accumulation loop appends rather than overwrites (a single-file test like case
# 16 cannot catch an overwrite-instead-of-append regression).
P=$TMPROOT/g16
SCRIPT=$(install_script "$P")
mk_skill_guidance "$P/han-plugin-builder/skills/guidance/references"
rm -f "$P/han-plugin-builder/skills/guidance/references/skill-building-guidance/naming-conventions.md"
rm -f "$P/han-plugin-builder/skills/guidance/references/skill-building-guidance/security-restrictions.md"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$("$SCRIPT" "$P/target/my-skill")
{ [ "$(get "$out" guidance-complete)" = false ] \
  && printf '%s\n' "$out" | grep -qE '^guidance-missing: .*naming-conventions.md' \
  && printf '%s\n' "$out" | grep -qE '^guidance-missing: .*security-restrictions.md'; } \
  && ok "two REQUIRED files missing -> both named in guidance-missing" \
  || fail "two REQUIRED missing -> both named (missing: $(get "$out" guidance-missing))"

# 47. guidance-note is NOT emitted when guidance resolves cleanly: the note is
# reserved for the present-but-unresolvable diagnosis, so a clean run must not
# emit it (a spurious note would send an operator chasing permissions).
P=$TMPROOT/g17
SCRIPT=$(install_script "$P")
mk_skill_guidance "$P/han-plugin-builder/skills/guidance/references"
mkskill "$P/target/my-skill" 'name: my-skill\ndescription: valid.\nallowed-tools: Read\n'
out=$("$SCRIPT" "$P/target/my-skill")
{ [ "$(get "$out" guidance-complete)" = true ] \
  && ! printf '%s\n' "$out" | grep -qE '^guidance-note:'; } \
  && ok "clean guidance resolve emits no guidance-note" \
  || fail "clean resolve should emit no guidance-note (notes: $(printf '%s\n' "$out" | grep -c '^guidance-note:'))"

# 48. A mismatch target emits guidance-root/guidance-complete (per the SKILL
# contract) but NOT the skill/agent-only roster keys or guidance-subtree: a
# leaked roster key on a typeless target is a contract break for the orchestrator.
mkdir -p "$TMPROOT/c48/nodir"
out=$("$SRC" "$TMPROOT/c48/nodir")
{ [ "$(get "$out" target-type)" = mismatch ] \
  && [ "$(keycount "$out" reference-count)" = 0 ] \
  && [ "$(keycount "$out" has-scripts)" = 0 ] \
  && [ "$(keycount "$out" body-line-count)" = 0 ] \
  && [ "$(keycount "$out" guidance-subtree)" = 0 ] \
  && [ "$(get "$out" guidance-root)" = none ]; } \
  && ok "mismatch target emits no roster/guidance-subtree keys" \
  || fail "mismatch target leaks roster/subtree keys (ref: $(keycount "$out" reference-count), subtree: $(keycount "$out" guidance-subtree))"

echo "----"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
