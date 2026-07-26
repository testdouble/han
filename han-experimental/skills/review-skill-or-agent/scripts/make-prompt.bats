#!/usr/bin/env bats
#
# Tests for review-skill-or-agent's make-prompt.sh — the deterministic reviewer/
# validator prompt formatter. Covers allowlisted single-pass @VAR@ expansion
# (literal values, unknown tokens untouched, no re-trigger), @IF:CHANGE@ /
# @IF:BRANCH_CONTEXT@ conditional blocks resolved before expansion, per-reviewer
# and validator file assembly, the key: value stdout manifest, and fail-loud
# non-zero exits. Pure bash crafted fixtures, plus one integration test that
# assembles the full shipped roster from the real templates; no jq/python3.

setup() {
  TMP="$(mktemp -d)"
  SKILL="$TMP/skill"
  DATA="$SKILL/scripts/data/prompts"
  OUT="$TMP/out"
  mkdir -p "$SKILL/scripts" "$DATA/briefs" "$OUT"
  # Run a copy inside a fixture skill so the script derives SKILL_DIR=$SKILL.
  cp "$BATS_TEST_DIRNAME/make-prompt.sh" "$SKILL/scripts/make-prompt.sh"
  chmod +x "$SKILL/scripts/make-prompt.sh"
  SRC="$SKILL/scripts/make-prompt.sh"
  # Baseline templates the always-formatted validator needs; tests override or rm.
  printf 'Validator body.\n' >"$DATA/validator.md"
  printf 'Validator brief.\n' >"$DATA/briefs/adversarial-validator.md"
}

teardown() { rm -rf "$TMP"; }

# Write template $1 (relative to DATA) with %b-interpreted body $2.
tpl() { mkdir -p "$(dirname -- "$DATA/$1")"; printf '%b' "$2" >"$DATA/$1"; }

# Value of the first `key: value` manifest line whose key is $2 (key may contain colons).
get() { printf '%s\n' "$1" | awk -v k="$2" 'index($0, k": ")==1{print substr($0, length(k)+3); exit}'; }

@test "writes the shared prompt file and emits its manifest line" {
  tpl shared.md 'Shared discipline.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /x/skill --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  [ -f "$OUT/shared.md" ]
  [ "$(get "$output" shared-prompt)" = "$OUT/shared.md" ]
}

@test "writes a reviewer file assembling reviewer.md and the brief, and emits its manifest line" {
  tpl shared.md 'Shared.\n'
  tpl reviewer.md 'Reviewer body.\n'
  tpl briefs/conformance-quality.md 'Conformance brief.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /x/skill --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers conformance-quality
  [ "$status" -eq 0 ]
  [ -f "$OUT/conformance-quality.md" ]
  [ "$(get "$output" reviewer:conformance-quality)" = "$OUT/conformance-quality.md" ]
  grep -q 'Reviewer body.' "$OUT/conformance-quality.md"
  grep -q 'Conformance brief.' "$OUT/conformance-quality.md"
}

@test "expands allowlisted @VAR@ tokens with their argument values" {
  tpl shared.md 'Artifact @TARGET@ under @SCOPE@, backstop @BACKSTOP@, guidance @GUIDANCE_ROOT@, skill @SKILL_DIR@.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /repo/skill --scope whole-artifact --branch-context none \
    --guidance-root /g/root --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  grep -qF "Artifact /repo/skill under whole-artifact, backstop none, guidance /g/root, skill $SKILL." "$OUT/shared.md"
}

@test "leaves an unknown @token@ byte-for-byte untouched" {
  tpl shared.md 'Ping @UNKNOWN@ and @brianvh re @TARGET@.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  grep -qF 'Ping @UNKNOWN@ and @brianvh re /t.' "$OUT/shared.md"
}

@test "inserts values literally, unbroken by slashes, ampersands, or backslashes" {
  # --scope is enum-validated, so carry the slash/ampersand value through a free-form
  # variable (--guidance-root); the property under test is literal insertion, not scope.
  tpl shared.md 'At @TARGET@ in @GUIDANCE_ROOT@.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target '/a&b/c\d' --scope whole-artifact --branch-context none \
    --guidance-root 'x/y&z' --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  grep -qF 'At /a&b/c\d in x/y&z.' "$OUT/shared.md"
}

@test "does not re-expand a token that appears inside an inserted value" {
  tpl shared.md 'Got @TARGET@ done.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target 'a@SCOPE@b' --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  grep -qF 'Got a@SCOPE@b done.' "$OUT/shared.md"
}

# Assert $1 is absent from file $2. The negation lives inside the function so the
# call site is a plain command bats errexit still fails on (a bare `! grep` at the
# test level would be exempt from errexit and so vacuous).
absent() { ! grep -qF "$1" "$2"; }

@test "keeps an @IF:CHANGE@ block under change scope and drops it under whole-artifact" {
  tpl shared.md 'Head.\n@IF:CHANGE@\nDiff at @DIFF@.\n@ENDIF@\nTail.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope change --diff /d.diff --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  grep -qF 'Diff at /d.diff.' "$OUT/shared.md"
  grep -qF 'Head.' "$OUT/shared.md"
  grep -qF 'Tail.' "$OUT/shared.md"
  absent '@IF:CHANGE@' "$OUT/shared.md"
  absent '@ENDIF@' "$OUT/shared.md"

  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  absent 'Diff at' "$OUT/shared.md"
  absent '@IF:CHANGE@' "$OUT/shared.md"
  grep -qF 'Head.' "$OUT/shared.md"
  grep -qF 'Tail.' "$OUT/shared.md"
}

@test "keeps an @IF:BRANCH_CONTEXT@ block when branch context is set and drops it when none" {
  tpl shared.md 'A.\n@IF:BRANCH_CONTEXT@\nContext at @BRANCH_CONTEXT@.\n@ENDIF@\nB.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context /bc.md \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  grep -qF 'Context at /bc.md.' "$OUT/shared.md"
  absent '@IF:BRANCH_CONTEXT@' "$OUT/shared.md"

  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  absent 'Context at' "$OUT/shared.md"
  grep -qF 'A.' "$OUT/shared.md"
  grep -qF 'B.' "$OUT/shared.md"
}

@test "keeps an @IF:REPO_CONVENTIONS@ block and expands the colon-separated @REPO_CONVENTIONS@" {
  tpl shared.md 'P.\n@IF:REPO_CONVENTIONS@\nConventions: @REPO_CONVENTIONS@.\n@ENDIF@\nQ.\n'
  # Colon-separated paths, one of which contains a space — the reason the delimiter is `:`, not ` `.
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none \
    --repo-conventions '/r/CLAUDE.md:/r/docs/coding standards/authoring.md' --reviewers ''
  [ "$status" -eq 0 ]
  grep -qF 'Conventions: /r/CLAUDE.md:/r/docs/coding standards/authoring.md.' "$OUT/shared.md"
  absent '@IF:REPO_CONVENTIONS@' "$OUT/shared.md"
  grep -qF 'P.' "$OUT/shared.md"
  grep -qF 'Q.' "$OUT/shared.md"
}

@test "drops the @IF:REPO_CONVENTIONS@ block when repo conventions are none or the flag is omitted" {
  tpl shared.md 'P.\n@IF:REPO_CONVENTIONS@\nConventions: @REPO_CONVENTIONS@.\n@ENDIF@\nQ.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --repo-conventions none --reviewers ''
  [ "$status" -eq 0 ]
  absent 'Conventions:' "$OUT/shared.md"
  absent '@IF:REPO_CONVENTIONS@' "$OUT/shared.md"
  grep -qF 'P.' "$OUT/shared.md"
  grep -qF 'Q.' "$OUT/shared.md"
  # Omitting --repo-conventions defaults to none: the block drops, and no missing-arg error.
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  absent 'Conventions:' "$OUT/shared.md"
}

@test "formats each reviewer in --reviewers order, one file and manifest line each" {
  tpl shared.md 'S.\n'
  tpl reviewer.md 'R.\n'
  tpl briefs/alpha.md 'Alpha.\n'
  tpl briefs/beta.md 'Beta.\n'
  tpl briefs/gamma.md 'Gamma.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers alpha,beta,gamma
  [ "$status" -eq 0 ]
  [ -f "$OUT/alpha.md" ] && [ -f "$OUT/beta.md" ] && [ -f "$OUT/gamma.md" ]
  grep -qF 'Beta.' "$OUT/beta.md"
  order="$(printf '%s\n' "$output" | awk -F': ' '/^reviewer:/{sub(/^reviewer:/,"",$1); printf "%s ", $1}')"
  [ "$order" = "alpha beta gamma " ]
}

@test "always assembles the validator file and emits the validator line" {
  tpl shared.md 'S.\n'
  tpl validator.md 'Validator body @TARGET@.\n'
  tpl briefs/adversarial-validator.md 'Validator brief.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /vt --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  [ -f "$OUT/validator.md" ]
  [ "$(get "$output" validator)" = "$OUT/validator.md" ]
  grep -qF 'Validator body /vt.' "$OUT/validator.md"
  grep -qF 'Validator brief.' "$OUT/validator.md"
}

@test "fails loudly on an unknown reviewer key, writing nothing" {
  tpl shared.md 'S.\n'
  tpl reviewer.md 'R.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers nosuch
  [ "$status" -ne 0 ]
  [[ "$output" == *nosuch* ]]
  [ ! -f "$OUT/nosuch.md" ]
  [ ! -f "$OUT/shared.md" ]
}

@test "fails loudly when a required argument is missing" {
  tpl shared.md 'S.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -ne 0 ]
  [[ "$output" == *target* ]]
  [ ! -f "$OUT/shared.md" ]
}

@test "fails loudly when --scope change is given without --diff" {
  tpl shared.md 'S.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope change --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -ne 0 ]
  [[ "$output" == *diff* ]]
  [ ! -f "$OUT/shared.md" ]
}

@test "fails loudly when a required template is missing (shared, reviewer, or validator)" {
  local args=(--out "$OUT" --data "$DATA" --target /t --scope whole-artifact
    --branch-context none --guidance-root /g --backstop none)
  tpl reviewer.md 'R.\n'
  tpl briefs/x.md 'X.\n'
  tpl validator.md 'V.\n'
  tpl briefs/adversarial-validator.md 'AV.\n'

  run "$SRC" "${args[@]}" --reviewers ''
  [ "$status" -ne 0 ]
  [[ "$output" == *shared* ]]

  tpl shared.md 'S.\n'
  rm "$DATA/reviewer.md"
  run "$SRC" "${args[@]}" --reviewers x
  [ "$status" -ne 0 ]
  [[ "$output" == *reviewer* ]]

  tpl reviewer.md 'R.\n'
  rm "$DATA/validator.md"
  run "$SRC" "${args[@]}" --reviewers ''
  [ "$status" -ne 0 ]
  [[ "$output" == *validator* ]]
}

@test "fails loudly on an unknown argument and prints usage" {
  tpl shared.md 'S.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers '' --bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *bogus* ]]
  [[ "$output" == *Usage* ]]
  [ ! -f "$OUT/shared.md" ]
}

@test "creates the --out directory when it does not yet exist" {
  tpl shared.md 'S.\n'
  run "$SRC" --out "$TMP/fresh/out" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -eq 0 ]
  [ -f "$TMP/fresh/out/shared.md" ]
}

@test "acceptance: realistic run formats reviewers and validator with vars and both conditionals" {
  tpl shared.md 'Discipline: artifact @TARGET@ (@SCOPE@).\n'
  tpl reviewer.md 'Checklist @SKILL_DIR@/references/review-checklist.md, guidance @GUIDANCE_ROOT@.\n@IF:CHANGE@\nDiff: @DIFF@.\n@ENDIF@\n@IF:BRANCH_CONTEXT@\nBranch: @BRANCH_CONTEXT@.\n@ENDIF@\nBackstop @BACKSTOP@.\n'
  tpl validator.md 'Validator over @TARGET@.\n'
  tpl briefs/conformance-quality.md 'CQ brief.\n'
  tpl briefs/edge-case-explorer.md 'ECE brief.\n'
  tpl briefs/adversarial-validator.md 'AV brief.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /repo/skl --scope change --diff /tmp/d.diff --branch-context /tmp/bc.md \
    --guidance-root /gr --backstop seam --reviewers conformance-quality,edge-case-explorer
  [ "$status" -eq 0 ]
  [ "$(get "$output" shared-prompt)" = "$OUT/shared.md" ]
  [ "$(get "$output" reviewer:conformance-quality)" = "$OUT/conformance-quality.md" ]
  [ "$(get "$output" reviewer:edge-case-explorer)" = "$OUT/edge-case-explorer.md" ]
  [ "$(get "$output" validator)" = "$OUT/validator.md" ]
  grep -qF 'artifact /repo/skl (change).' "$OUT/shared.md"
  grep -qF 'CQ brief.' "$OUT/conformance-quality.md"
  grep -qF "Checklist $SKILL/references/review-checklist.md, guidance /gr." "$OUT/conformance-quality.md"
  grep -qF 'Diff: /tmp/d.diff.' "$OUT/conformance-quality.md"
  grep -qF 'Branch: /tmp/bc.md.' "$OUT/conformance-quality.md"
  grep -qF 'Backstop seam.' "$OUT/conformance-quality.md"
  grep -qF 'Validator over /repo/skl.' "$OUT/validator.md"
  grep -qF 'AV brief.' "$OUT/validator.md"
}

@test "aborts and prints no success manifest when a template read fails mid-assembly" {
  tpl shared.md 'Shared.\n'
  # A template that passes the -f existence check but then fails to read (permission
  # change, mid-run delete, transient I/O error): simulate by stubbing cat to fail.
  local bin="$TMP/bin"
  mkdir -p "$bin"
  printf '#!/usr/bin/env bash\nexit 1\n' >"$bin/cat"
  chmod +x "$bin/cat"
  local oldpath="$PATH"
  PATH="$bin:$PATH"
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  PATH="$oldpath"
  [ "$status" -ne 0 ]
  # The orchestrator halts only on a non-zero exit, so a swallowed failure must not
  # print a manifest line claiming the (empty) file was written.
  [[ "$output" != *"shared-prompt:"* ]]
}

@test "aborts on an unterminated @IF block instead of silently dropping content" {
  # A shared template whose @IF:CHANGE@ is never closed. Under whole-artifact scope the
  # resolver would keep=0 to end-of-stream, silently blanking everything after the marker.
  tpl shared.md 'Head.\n@IF:CHANGE@\nInside.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole-artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -ne 0 ]
  [[ "$output" != *"shared-prompt:"* ]]
}

@test "rejects an out-of-enum --scope value, writing nothing" {
  tpl shared.md 'S.\n'
  run "$SRC" --out "$OUT" --data "$DATA" \
    --target /t --scope whole_artifact --branch-context none \
    --guidance-root /g --backstop none --reviewers ''
  [ "$status" -ne 0 ]
  [[ "$output" == *scope* ]]
  [ ! -f "$OUT/shared.md" ]
}

# Integration over the shipped templates (not fixtures): every reviewer key the skill's
# Step 3 roster can select must have a real brief, and the real shared/reviewer/validator
# templates must assemble under change scope with branch context. Runs the script from its
# own location so it resolves the shipped scripts/data/prompts. Guards the roster-to-brief
# contract a fixture run cannot: add a roster key in SKILL.md without a brief and this fails.
@test "integration: the shipped templates assemble the full Step 3 roster and validator" {
  local roster=conformance-quality,bloat-restatement,junior-developer,user-experience-designer,edge-case-explorer,skill-tool-seam,adversarial-security-analyst,content-auditor,dispatch-prompt
  run "$BATS_TEST_DIRNAME/make-prompt.sh" --out "$OUT" \
    --target /repo/skill --scope change --diff /tmp/d.diff --branch-context /tmp/bc.md \
    --guidance-root /gr --backstop seam --repo-conventions '/repo/CLAUDE.md:/repo/docs/coding-standards/skill-authoring.md' \
    --reviewers "$roster"
  [ "$status" -eq 0 ]
  [ -f "$OUT/shared.md" ]
  [ "$(get "$output" validator)" = "$OUT/validator.md" ]
  local key
  for key in ${roster//,/ }; do
    [ -f "$OUT/$key.md" ]
    [ "$(get "$output" "reviewer:$key")" = "$OUT/$key.md" ]
  done
  # Repo conventions are a shared grounding corpus: delivered to every reviewer (via reviewer.md) and the
  # validator (via validator.md), not just the conformance reviewer.
  grep -qF '/repo/docs/coding-standards/skill-authoring.md' "$OUT/conformance-quality.md"
  grep -qF '/repo/docs/coding-standards/skill-authoring.md' "$OUT/bloat-restatement.md"
  grep -qF '/repo/docs/coding-standards/skill-authoring.md' "$OUT/validator.md"
}
