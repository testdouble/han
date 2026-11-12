#!/usr/bin/env bats
#
# Tests for investigate's shipped investigation types: the agreements that hold
# the `## Investigation Types` table in SKILL.md, the argument-hint and
# description, the type files under references/types/, the templates under
# references/templates/, and the shared evidence-and-validation fragment
# together. Each agreement spans files and holds only by convention, so it is
# checked here.

setup() {
  SKILL_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  REPO_ROOT="$(cd "$SKILL_DIR/../../.." && pwd)"
  SKILL="$SKILL_DIR/SKILL.md"
  TYPES_DIR="$SKILL_DIR/references/types"
  TEMPLATES_DIR="$SKILL_DIR/references/templates"
  FRAGMENT="$SKILL_DIR/references/evidence-and-validation.md"
  MARKER='<!-- shared: evidence-and-validation.md -->'
}

# Print the body of the `## Investigation Types` section of SKILL.md, up to the next `## ` or `# ` heading.
types_section() {
  awk '/^## Investigation Types$/{on=1; next} on && /^#{1,2} /{exit} on' "$SKILL"
}

# Print each token from the `## Investigation Types` table, one per line, in row order.
table_tokens() {
  types_section | awk -F'|' '/^\| `[a-z0-9-]+`/{gsub(/[ `]/, "", $2); print $2}'
}

# Print the value of a frontmatter key from SKILL.md, joined onto one line (handles folded blocks).
frontmatter_value() { # key
  awk '/^---$/{n++; next} n==1' "$SKILL" |
    awk -v k="$1" '$0 ~ "^"k":"{on=1; sub("^"k":[ ]*>?[ ]*", ""); print; next} on && /^  /{print; next} {on=0}' |
    tr '\n' ' '
}

# Print each backticked token in a string, one per line.
backticked() { # text
  # shellcheck disable=SC2016 # the backticks are literal Markdown, not command substitution
  printf '%s\n' "$1" | grep -oE '`[a-z0-9-]+`' | tr -d '`'
}

# Print the `## ` headings of a file outside fenced blocks, one per line.
headings() { # file
  awk '/^```/{fence=!fence; next} !fence && /^## /' "$1"
}

# Print the body of one `## ` section of a file, outside fenced blocks.
section_body() { # file heading
  awk -v h="## $2" '/^```/{fence=!fence} !fence && $0==h{on=1; next} on && !fence && /^## /{exit} on' "$1"
}

sorted_basenames() { # dir
  for f in "$1"/*.md; do basename "$f" .md; done | sort
}

@test "type files, table rows, templates, and argument-hint tokens are the same set, and the description names each" {
  types="$(sorted_basenames "$TYPES_DIR")"
  rows="$(table_tokens | sort)"
  templates="$(sorted_basenames "$TEMPLATES_DIR")"
  hint="$(backticked "$(frontmatter_value argument-hint)" | sort -u)"
  [ "$types" = "$rows" ] || { echo "type files: $types"; echo "table rows: $rows"; return 1; }
  [ "$types" = "$templates" ] || { echo "type files: $types"; echo "templates: $templates"; return 1; }
  [ "$types" = "$hint" ] || { echo "type files: $types"; echo "argument-hint tokens: $hint"; return 1; }
  description="$(frontmatter_value description)"
  while read -r token; do
    run grep -E "^\| \`$token\` +\| \[references/types/$token\.md\]\(\./references/types/$token\.md\) +\|" <(types_section)
    [ "$status" -eq 0 ] || { echo "no well-formed table row for $token"; return 1; }
    [[ "$description" == *"\`$token\`"* ]] || { echo "description lacks \`$token\`"; return 1; }
  done <<<"$types"
}

@test "every type file follows the type-file contract" {
  expected=$'## Detection signals\n## Dispatch\n## Analysis\n## Validation brief\n## Audience\n## Stop'
  for f in "$TYPES_DIR"/*.md; do
    token="$(basename "$f" .md)"
    [ "$(head -n 1 "$f")" = "# Investigation type: $token" ] || { echo "$f: bad title"; return 1; }
    [ "$(headings "$f")" = "$expected" ] || { echo "$f: sections are"; headings "$f"; return 1; }

    section_body "$f" "Detection signals" | grep -qE '^- .+' || { echo "$f: no detection signal"; return 1; }

    entries="$(section_body "$f" "Dispatch" | grep -E '^[0-9]+\. ')"
    [ -n "$entries" ] || { echo "$f: no dispatch entry"; return 1; }
    while read -r entry; do
      [[ "$entry" =~ ^[0-9]+\.\ \`[a-z0-9-]+:[a-z0-9-]+\`\ \([0-9]+\+?,\ (always|when\ .+)\):\ \".+\"$ ]] ||
        { echo "$f: malformed dispatch entry: $entry"; return 1; }
      placeholders="$(printf '%s\n' "$entry" | grep -oE '\{[a-z_]+\}' | sort -u)"
      [ "$placeholders" = "{question}" ] || { echo "$f: dispatch placeholders are $placeholders"; return 1; }
    done <<<"$entries"

    # shellcheck disable=SC2016 # the backticks are literal Markdown, not command substitution
    while read -r named; do
      [ -z "$named" ] && continue
      grep -qxF "## $named" "$TEMPLATES_DIR/$token.md" ||
        { echo "$f: Analysis names \`$named\`, which templates/$token.md has no heading for"; return 1; }
    done < <(section_body "$f" "Analysis" | grep -E '^[0-9]+\. ' | grep -oE '^[0-9]+\. [^`]*`[^`]+`' | sed -E 's/.*`([^`]+)`$/\1/')

    brief="$(section_body "$f" "Validation brief" | grep -E '^- ')"
    [ "$(printf '%s\n' "$brief" | wc -l | tr -d ' ')" -eq 3 ] || { echo "$f: brief needs exactly three bullets"; return 1; }
    [ "$(printf '%s\n' "$brief" | sed -E 's/^(- [A-Za-z ]+: ).*/\1/')" = $'- Root cause analysis: \n- Planned fix: \n- Attack focus: ' ] ||
      { echo "$f: brief bullets are"; echo "$brief"; return 1; }

    stop="$(section_body "$f" "Stop" | grep -E '^> ')"
    [ "$(printf '%s\n' "$stop" | grep -c '^> ')" -eq 1 ] || { echo "$f: Stop needs exactly one blockquote line"; return 1; }
    [ "$(printf '%s\n' "$stop" | grep -oE '\{[a-z_]+\}' | sort -u)" = "{path}" ] ||
      { echo "$f: Stop placeholders must be exactly {path}"; return 1; }
  done
}

@test "every template carries the shared fragment marker once and names its type on its second non-blank line" {
  [ -f "$FRAGMENT" ] || { echo "missing $FRAGMENT"; return 1; }
  [ "$(headings "$FRAGMENT")" = $'## Evidence Summary\n## Validation Results' ] ||
    { echo "fragment sections are"; headings "$FRAGMENT"; return 1; }
  for f in "$TEMPLATES_DIR"/*.md; do
    token="$(basename "$f" .md)"
    [ "$(grep -cxF "$MARKER" "$f")" -eq 1 ] || { echo "$f: needs exactly one shared-fragment marker"; return 1; }
    second="$(grep -v '^$' "$f" | sed -n 2p)"
    [[ "$second" == "**Investigation type:** $token: "* ]] || { echo "$f: second line is $second"; return 1; }
  done
}

@test "the bug report keeps today's section order" {
  actual="$(awk -v m="$MARKER" -v frag="$FRAGMENT" '
    /^```/{fence=!fence; next}
    !fence && $0==m { while ((getline line < frag) > 0) if (line ~ /^## /) print line; next }
    !fence && /^## /' "$TEMPLATES_DIR/bug.md")"
  expected=$'## Summary\n## Problem Statement\n## Root Cause Analysis\n## Planned Fix\n## Evidence Summary\n## Validation Results\n## Coding Standards Reference'
  [ "$actual" = "$expected" ] || { echo "bug report sections are"; echo "$actual"; return 1; }
}

@test "the extraction from the single bug template is complete" {
  [ ! -e "$SKILL_DIR/references/template.md" ] || { echo "references/template.md still exists"; return 1; }
  run grep -rlF --exclude='*.bats' 'investigate/references/template.md' "$REPO_ROOT/han-coding" "$REPO_ROOT/han-atlassian"
  [ "$status" -ne 0 ] || { echo "files still link to template.md:"; echo "$output"; return 1; }
  ! grep -qF '](./references/template.md)' "$SKILL" || { echo "SKILL.md still links to template.md"; return 1; }
  ! grep -q '{symptom}' "$SKILL" || { echo "SKILL.md still carries {symptom}"; return 1; }
  for section in "Detection signals" "Dispatch" "Analysis" "Validation brief" "Audience" "Stop"; do
    grep -qF "\`## $section\`" "$SKILL" || { echo "SKILL.md never names \`## $section\`"; return 1; }
  done
}

@test "research does not claim questions about how something works" {
  research="$REPO_ROOT/han-research/skills/research/SKILL.md"
  description="$(awk '/^---$/{n++; next} n==1' "$research" | awk '/^description:/{on=1; next} on && /^  /{print; next} {on=0}' | tr '\n' ' ')"
  [[ "$description" != *"how something works"* ]] || { echo "research's description still claims how something works"; return 1; }
}
