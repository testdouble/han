#!/usr/bin/env bash
# Resolve the review target's type and the plugin-authoring guidance root, and
# report the guidance's completeness. Emits `key: value` lines the SKILL body
# reads (some are branched on, some carry halt detail). Degrades cleanly (emits
# none/neither, never crashes) so a missing guidance install halts the review
# rather than erroring. The `claude plugin list --json` probes are bounded by a
# `timeout` (when available) so a wedged, sluggish, or auth-blocked CLI degrades
# to the vendored fallback instead of hanging the review.
#
# Usage: detect-guidance-and-type-context.sh <target-path>
set -uo pipefail

TARGET="${1:-}"

# A skill's SKILL.md passed directly (not its directory) resolves to the skill
# directory, so `review-skill-or-agent SomeSkill/SKILL.md` reviews the skill.
if [ -f "$TARGET" ] && [ "$(basename -- "$TARGET")" = SKILL.md ]; then
  TARGET="$(dirname -- "$TARGET")"
fi

# Lowercase the file extension so an uppercase .MD agent file still classifies.
TARGET_EXT="$(printf '%s' "${TARGET##*.}" | tr '[:upper:]' '[:lower:]')"

# Flatten any newline, carriage return, or ": " in the value so a crafted target
# path cannot forge or split a second key: value line (the carriage return is the
# newline's partner: a downstream reader that treats a CR as a line break would
# otherwise see a split line where the defense assumed one clean line).
emit() {
  local v="${2//$'\n'/ }"
  v="${v//$'\r'/ }"
  printf '%s: %s\n' "$1" "${v//: /; }"
}

# --- 1. Resolve the target's structural type ------------------------------
# skill    : a directory with SKILL.md whose frontmatter is not agent-shaped
# agent    : a .md file under an agents/ path whose frontmatter is not skill-shaped
# mismatch : resembles a type by location but carries the other type's frontmatter
# neither  : not a skill or agent
frontmatter_shape() {
  # Reads only the leading --- frontmatter block of $1 (never the body);
  # echoes "skill", "agent", or "unknown". Keys on the type-exclusive fields
  # only: allowed-tools is skill-only, tools is agent-only. model/name/description
  # are shared between skills and agents, so a file carrying only those stays
  # "unknown" and the caller defers to the target's location. Tolerates a leading
  # UTF-8 BOM and CRLF line endings so a Windows-authored artifact is not misread.
  # Echoes "readfail" when $1 is unreadable, so the caller surfaces a permission
  # error instead of silently defaulting to a type. A block that opens with --- but
  # never closes is unparseable: the extractor emits nothing and this echoes
  # "unknown", so a truncated file defers to the target's location instead of the
  # body being scanned for a stray tools:/allowed-tools: line.
  local f="$1" head
  [ -r "$f" ] || { echo readfail; return; }
  # LC_ALL=C keeps awk byte-oriented so the 3-byte UTF-8 BOM literal matches; under
  # a UTF-8 locale substr() counts characters and the strip would silently no-op.
  # Buffer the frontmatter lines and emit them only once the closing --- is seen,
  # so an unterminated block yields no output (see the unknown-on-no-close note above).
  head="$(LC_ALL=C awk '
    NR==1 && substr($0,1,3)=="\357\273\277" { $0=substr($0,4) }
    { sub(/\r$/,"") }
    NR==1 { if ($0!="---") exit; next }
    $0=="---" { closed=1; exit }
    { buf = buf $0 "\n" }
    END { if (closed) printf "%s", buf }
  ' "$f" 2>/dev/null)"
  if printf '%s' "$head" | grep -qE '^allowed-tools:'; then
    echo skill
  elif printf '%s' "$head" | grep -qE '^tools:'; then
    echo agent
  else
    echo unknown
  fi
}

TYPE=neither
SIGNAL="target is neither a skill directory nor an agent file"

if [ -z "$TARGET" ] || [ ! -e "$TARGET" ]; then
  TYPE=neither
  SIGNAL="target path is empty or does not exist"
elif [ -d "$TARGET" ]; then
  if [ -f "$TARGET/SKILL.md" ]; then
    shape="$(frontmatter_shape "$TARGET/SKILL.md")"
    if [ "$shape" = readfail ]; then
      TYPE=mismatch
      SIGNAL="SKILL.md present at $TARGET/SKILL.md but not readable — check permissions"
    elif [ "$shape" = agent ]; then
      TYPE=mismatch
      SIGNAL="directory has SKILL.md but its frontmatter is agent-shaped (tools set, no allowed-tools)"
    else
      TYPE=skill
      SIGNAL="directory with SKILL.md"
    fi
  else
    TYPE=mismatch
    SIGNAL="directory given but no SKILL.md found at $TARGET/SKILL.md"
  fi
elif [ -f "$TARGET" ] && [ "$TARGET_EXT" = md ]; then
  case "$TARGET" in
    */agents/*)
      shape="$(frontmatter_shape "$TARGET")"
      if [ "$shape" = readfail ]; then
        TYPE=mismatch
        SIGNAL="agent file present but not readable — check permissions"
      elif [ "$shape" = skill ]; then
        TYPE=mismatch
        SIGNAL="file under agents/ but its frontmatter is skill-shaped (allowed-tools present)"
      else
        TYPE=agent
        SIGNAL="markdown file under an agents/ path"
      fi
      ;;
    *)
      TYPE=neither
      SIGNAL="markdown file that is neither a SKILL.md in a skill directory nor under an agents/ path"
      ;;
  esac
fi

emit target-path "$TARGET"
emit target-type "$TYPE"
emit structural-signal "$SIGNAL"

# Cheap roster signals for the target: how many reference files it carries, and
# whether it ships supporting scripts. The triage sub-agent (SKILL Step 3), not
# the orchestrator, derives the fuzzier signals (interaction model, control-flow
# complexity) from the body.
if [ "$TYPE" = skill ]; then
  # Count reference .md files at any depth (a nested reference tree must still
  # trip the IA gate).
  rc="$(find "$TARGET/references" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
  # Gate the find on -d so a stray plain file named `scripts` (not a scripts/ dir)
  # cannot report has-scripts true: find given a file path matches the path itself.
  hs=false
  [ -d "$TARGET/scripts" ] && [ -n "$(find "$TARGET/scripts" -maxdepth 1 -type f 2>/dev/null)" ] && hs=true
  # awk END{print NR} counts a final line with no trailing newline; wc -l would undercount it.
  blc="$(awk 'END{print NR}' "$TARGET/SKILL.md" 2>/dev/null)"
  emit reference-count "${rc:-0}"
  emit has-scripts "$hs"
  emit body-line-count "${blc:-0}"
elif [ "$TYPE" = agent ]; then
  blc="$(awk 'END{print NR}' "$TARGET" 2>/dev/null)"
  emit reference-count 0
  emit has-scripts false
  emit body-line-count "${blc:-0}"
fi

# Stop here for targets that carry no type — no guidance to resolve.
if [ "$TYPE" = neither ] || [ "$TYPE" = mismatch ]; then
  emit guidance-root none
  emit guidance-complete false
  exit 0
fi

# Run `claude plugin list --json`, bounded by a timeout when coreutils `timeout`
# is on PATH (it is not on a stock macOS), so a wedged, sluggish, or auth-blocked
# CLI degrades to the vendored fallback instead of hanging the whole review. The
# bound is generous (default 10s, override with CLAUDE_LIST_TIMEOUT) so a slow but
# working CLI is not cut off and made to look absent. Without `timeout`, run the
# CLI directly — the prior behavior.
claude_plugin_list() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "${CLAUDE_LIST_TIMEOUT:-10}" claude plugin list --json 2>/dev/null
  else
    claude plugin list --json 2>/dev/null
  fi
}

# --- 2. Locate the authoring-guidance root --------------------------------
# Resolution order, most authoritative first:
#   (a) a checked-out flat sibling — a dev/monorepo layout where han-plugin-builder
#       sits beside this plugin; the maintainer's working copy wins.
#   (b) the installed han-plugin-builder, located via `claude plugin list --json`.
#       Its install path's base is NOT hardcodable (it varies by install, e.g.
#       ~/.local/state/claude-clc/.../cache/<marketplace>/han-plugin-builder/
#       <version>), so we ask the CLI rather than guess a path. This replaces a
#       relative-path search that silently failed under the real marketplace
#       cache layout. No JSON interpreter is assumed — Claude Code ships as a
#       self-contained native binary, so node/jq/python may all be absent; we
#       parse the pretty-printed output with awk (already a dependency), keying on
#       each entry's declared `id` (han-plugin-builder@…) and taking THAT object's
#       installPath. We never trust a path merely because it contains a
#       han-plugin-builder segment: a look-alike install of an unrelated plugin
#       could carry that segment and hijack the guidance the whole review grades
#       against. The `@` in the id anchor also excludes han-plugin-builder-extras.
#   (c) a repo-local vendored copy (init-guidance.sh), found by walking up from
#       the target — mutable in the working tree, so it ranks last.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"   # skills/<name>/scripts -> plugin root
PLUGINS_PARENT="$(dirname "$PLUGIN_ROOT")"

GUIDANCE_ROOT=none

# (a) sibling plugin, flat layout
if [ -d "$PLUGINS_PARENT/han-plugin-builder/skills/guidance/references" ]; then
  GUIDANCE_ROOT="$PLUGINS_PARENT/han-plugin-builder/skills/guidance/references"
fi

# (b) installed plugin, located via the Claude CLI. Select the installPath of the
# object whose declared id is han-plugin-builder@… (id and installPath may appear
# in either order within an object; flush at the object's closing brace), never a
# path that merely contains the segment, so a look-alike install cannot capture
# the review.
if [ "$GUIDANCE_ROOT" = none ] && command -v claude >/dev/null 2>&1; then
  hpb="$(claude_plugin_list | awk '
    function val(line,   s) { s=line; sub(/^[^:]*:[[:space:]]*"/,"",s); sub(/".*/,"",s); return s }
    /"id"[[:space:]]*:/          { id=val($0) }
    /"installPath"[[:space:]]*:/ { ip=val($0) }
    /}/ { if (id ~ /^han-plugin-builder@/ && ip!="") print ip; id=""; ip="" }
  ' | head -n 1)"
  if [ -n "${hpb:-}" ] && [ -d "$hpb/skills/guidance/references" ]; then
    GUIDANCE_ROOT="$hpb/skills/guidance/references"
  fi
fi

# (c) repo-local vendored copy, found by walking up from the target (not the CWD)
if [ "$GUIDANCE_ROOT" = none ]; then
  d="$TARGET"; [ -f "$TARGET" ] && d="$(dirname "$TARGET")"
  d="$(cd "$d" 2>/dev/null && pwd || true)"
  while [ -n "$d" ] && [ "$d" != / ]; do
    if [ -d "$d/.claude/skills/plugin-guidance/references" ]; then
      GUIDANCE_ROOT="$d/.claude/skills/plugin-guidance/references"
      break
    fi
    d="$(dirname "$d")"
  done
fi

emit guidance-root "$GUIDANCE_ROOT"

if [ "$GUIDANCE_ROOT" = none ]; then
  # Distinguish "present but unresolvable" (e.g. unreadable) from genuinely absent,
  # so the halt sends the operator to permissions rather than a reinstall. Capture
  # the plugin list first, then glob-match the captured string — a pipe in the
  # condition could, under pipefail plus an early-closing reader, misreport a match.
  present=false
  if command -v claude >/dev/null 2>&1; then
    plugins="$(claude_plugin_list || true)"
    case "$plugins" in *'"han-plugin-builder@'*) present=true ;; esac
  fi
  [ "$present" = false ] && [ -d "$PLUGINS_PARENT/han-plugin-builder" ] && present=true
  [ "$present" = true ] && emit guidance-note "han-plugin-builder is present but its guidance/references did not resolve — check read permissions"
  emit guidance-complete false
  exit 0
fi

# --- 3. Completeness of the type-appropriate subtree ----------------------
if [ "$TYPE" = skill ]; then
  SUBTREE="$GUIDANCE_ROOT/skill-building-guidance"
  # Every file the review-checklist and finding-classification bands ground against, so a
  # partial guidance install cannot report complete and leave a check ungrounded.
  REQUIRED=(skill-description-frontmatter.md skill-description-length.md naming-conventions.md progressive-disclosure.md skill-reference-files.md writing-effective-instructions.md workflow-patterns.md allowed-tools-bash-permissions.md allowed-tools-AskUserQuestion.md security-restrictions.md agent-dispatch-namespacing.md graceful-degradation.md dynamic-project-discovery.md optional-git-repositories.md script-execution-instructions.md success-criteria-and-testing.md)
else
  SUBTREE="$GUIDANCE_ROOT/agent-building-guidelines"
  REQUIRED=(agent-domain-focus.md agent-description-length.md agent-model-selection.md agent-external-files.md multi-agent-economics.md graceful-degradation.md)
fi

emit guidance-subtree "$SUBTREE"

if [ ! -d "$SUBTREE" ] || [ ! -f "$GUIDANCE_ROOT/plugin-entity-taxonomy.md" ]; then
  emit guidance-complete false
  emit guidance-missing "type subtree $SUBTREE or plugin-entity-taxonomy.md absent"
  exit 0
fi

MISSING=""
for f in "${REQUIRED[@]}"; do
  [ -f "$SUBTREE/$f" ] || MISSING="$MISSING $f"
done

if [ -n "$MISSING" ]; then
  emit guidance-complete false
  emit guidance-missing "${MISSING# }"
else
  emit guidance-complete true
fi
