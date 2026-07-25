#!/usr/bin/env bash
# Format the per-reviewer and validator prompt files for one review run and print
# a `key: value` manifest of their paths. Reads templates from data/prompts
# (shared.md, reviewer.md, validator.md, briefs/<key>.md), resolves the
# @IF:CHANGE@ / @IF:BRANCH_CONTEXT@ blocks, and expands an allowlist of @VAR@
# tokens literally in a single pass so an untrusted value cannot break or
# re-trigger substitution. The orchestrator inlines shared.md and dispatches each
# reviewer with its own file path; unknown @token@ text is left untouched.
# Run with a bad argument to print the usage.
set -euo pipefail

# The skill directory, derived from this script's own location (scripts/..).
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat >&2 <<'EOF'
Usage: make-prompt.sh --out DIR [--data DIR] --target PATH
         --scope whole-artifact|change [--diff PATH] --branch-context PATH|none
         --guidance-root DIR --backstop seam|none --reviewers k1,k2,...
EOF
}

die() { printf 'make-prompt: %s\n' "$1" >&2; exit 2; }

OUT="" DATA="" TARGET="" SCOPE="" DIFF="" BRANCH_CONTEXT="" GUIDANCE_ROOT="" BACKSTOP="" REVIEWERS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --out) OUT="$2"; shift 2 ;;
    --data) DATA="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --scope) SCOPE="$2"; shift 2 ;;
    --diff) DIFF="$2"; shift 2 ;;
    --branch-context) BRANCH_CONTEXT="$2"; shift 2 ;;
    --guidance-root) GUIDANCE_ROOT="$2"; shift 2 ;;
    --backstop) BACKSTOP="$2"; shift 2 ;;
    --reviewers) REVIEWERS="$2"; shift 2 ;;
    *) printf 'make-prompt: unknown argument: %s\n' "$1" >&2; usage; exit 2 ;;
  esac
done

# Keep or drop @IF:CHANGE@ / @IF:BRANCH_CONTEXT@ blocks (own-line markers,
# non-nested) by the two 1/0 flags, stripping the marker lines either way. Runs
# before expansion so a dropped block's tokens are never expanded. Exits non-zero
# on a block left unterminated at end of input, so a malformed template fails
# loudly rather than silently truncating the rest of the stream. Reads stdin.
resolve_conditionals() {
  awk -v change="$1" -v bc="$2" '
    BEGIN { keep = 1; open = 0 }
    $0 == "@IF:CHANGE@"         { keep = (change + 0); open = 1; next }
    $0 == "@IF:BRANCH_CONTEXT@" { keep = (bc + 0); open = 1; next }
    $0 == "@ENDIF@"             { keep = 1; open = 0; next }
    keep != 0 { print }
    END { if (open) { print "make-prompt: unterminated @IF@ block in template" > "/dev/stderr"; exit 1 } }'
}

# Replace each allowlisted @VAR@ with its value, read from the environment so the
# value is never re-interpreted as regex or backslash escapes. One left-to-right
# pass over the input: an inserted value is never rescanned, so a value that
# itself contains @TARGET@ cannot re-trigger. Any @token@ not on the allowlist is
# emitted byte-for-byte. Reads stdin, writes stdout.
expand() {
  TARGET="$TARGET" SCOPE="$SCOPE" DIFF="$DIFF" BRANCH_CONTEXT="$BRANCH_CONTEXT" \
    GUIDANCE_ROOT="$GUIDANCE_ROOT" BACKSTOP="$BACKSTOP" SKILL_DIR="$SKILL_DIR" \
    awk '
    BEGIN {
      split("TARGET SCOPE DIFF BRANCH_CONTEXT GUIDANCE_ROOT BACKSTOP SKILL_DIR", a, " ")
      for (i in a) allow[a[i]] = 1
    }
    {
      s = $0; out = ""
      while ((p = index(s, "@")) > 0) {
        out = out substr(s, 1, p - 1)
        rest = substr(s, p + 1)
        q = index(rest, "@")
        if (q > 0) {
          name = substr(rest, 1, q - 1)
          if (name in allow) { out = out ENVIRON[name]; s = substr(rest, q + 1) }
          else { out = out "@"; s = rest }
        } else { out = out "@" rest; s = "" }
      }
      print out s
    }'
}

DATA="${DATA:-$SKILL_DIR/scripts/data/prompts}"

for req in OUT:--out TARGET:--target SCOPE:--scope BRANCH_CONTEXT:--branch-context \
  GUIDANCE_ROOT:--guidance-root BACKSTOP:--backstop; do
  name="${req%%:*}"
  [ -n "${!name}" ] || die "missing required argument: ${req##*:}"
done

case "$SCOPE" in whole-artifact | change) ;; *) die "invalid --scope: $SCOPE (want whole-artifact or change)" ;; esac
[ "$SCOPE" != change ] || [ -n "$DIFF" ] || die "--scope change requires --diff"
[ -f "$DATA/shared.md" ] || die "missing template: shared.md"

IFS=',' read -r -a keys <<<"$REVIEWERS"
have_reviewers=0
for key in "${keys[@]}"; do
  [ -n "$key" ] || continue
  have_reviewers=1
  [ -f "$DATA/briefs/$key.md" ] || die "unknown reviewer key: $key"
done
[ "$have_reviewers" -eq 0 ] || [ -f "$DATA/reviewer.md" ] || die "missing template: reviewer.md"

[ -f "$DATA/validator.md" ] || die "missing template: validator.md"
[ -f "$DATA/briefs/adversarial-validator.md" ] || die "missing template: briefs/adversarial-validator.md"

mkdir -p -- "$OUT" || die "cannot create --out directory: $OUT"

CHANGE=0; [ "$SCOPE" = change ] && CHANGE=1
BC=0; [ "$BRANCH_CONTEXT" != none ] && BC=1

# Concatenate the given template files, resolve their conditional blocks, expand
# their variables, and print the result.
assemble() { cat -- "$@" | resolve_conditionals "$CHANGE" "$BC" | expand; }

assemble "$DATA/shared.md" >"$OUT/shared.md"
printf 'shared-prompt: %s\n' "$OUT/shared.md"

for key in "${keys[@]}"; do
  [ -n "$key" ] || continue
  assemble "$DATA/reviewer.md" "$DATA/briefs/$key.md" >"$OUT/$key.md"
  printf 'reviewer:%s: %s\n' "$key" "$OUT/$key.md"
done

assemble "$DATA/validator.md" "$DATA/briefs/adversarial-validator.md" >"$OUT/validator.md"
printf 'validator: %s\n' "$OUT/validator.md"
