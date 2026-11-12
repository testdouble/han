#!/usr/bin/env bats
#
# Tests for code-review's shipped review types: the agreements that hold the
# `## Review Types` table in SKILL.md, the argument-hint here and in
# han-github's post-code-review-to-pr, the type files under
# references/types/, the roster table in references/agent-dispatch.md, and the
# bolded categories in references/review-checklist.md together. Each of these
# agreements spans files and holds only by convention, so it is checked here.

setup() {
  SKILL_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SKILL="$SKILL_DIR/SKILL.md"
  DISPATCH="$SKILL_DIR/references/agent-dispatch.md"
  CHECKLIST="$SKILL_DIR/references/review-checklist.md"
  TYPES_DIR="$SKILL_DIR/references/types"
  PR_SKILL="$SKILL_DIR/../../../han-github/skills/post-code-review-to-pr/SKILL.md"
}

# Print the body of the `## Review Types` section of SKILL.md, up to the next `## ` heading.
review_types_section() {
  awk '/^## Review Types$/{on=1; next} on && /^## /{exit} on' "$SKILL"
}

# Print each shipped token from the `## Review Types` table, one per line.
table_tokens() {
  review_types_section | awk -F'|' '/^\| `[a-z0-9-]+`/{gsub(/[ `]/, "", $2); print $2}'
}

# Print the argument-hint value from a SKILL.md's frontmatter, joined onto one line.
argument_hint() { # skill-file
  awk '/^---$/{n++; next} n==1' "$1" |
    awk '/^argument-hint:/{on=1; sub(/^argument-hint:[ ]*/, ""); print; next} on && /^  /{print; next} {on=0}' |
    tr '\n' ' '
}

# Print the value of a type file's single-line section, such as `## Checklist categories`.
section_value() { # type-file heading
  awk -v h="## $2" '$0==h{on=1; next} on && /^## /{exit} on && NF{print; exit}' "$1"
}

# Print every agent named on a type file's `- Always:` and `- When relevant:` lines, one per line.
roster_agents() { # type-file
  awk '/^## Roster$/{on=1; next} on && /^## /{exit} on' "$1" |
    sed -n -e 's/^- Always: //p' -e 's/^- When relevant: //p' |
    tr ',' '\n' | sed -e 's/^ *//' -e 's/ *$//' | grep -v '^none$' | grep -v '^$'
}

# Print the default set's tokens from the `Default (no type token):` line, one per line.
default_set() {
  review_types_section | sed -n 's/^Default (no type token): //p' | tr ',' '\n' | sed -e 's/^ *//' -e 's/ *$//'
}

@test "every shipped type file has a table row and a token in both argument-hints, and every row names an existing file" {
  hint="$(argument_hint "$SKILL")"
  pr_hint="$(argument_hint "$PR_SKILL")"
  for f in "$TYPES_DIR"/*.md; do
    token="$(basename "$f" .md)"
    run grep -E "^\| \`$token\` +\| \[references/types/$token\.md\]\(\./references/types/$token\.md\)" <(review_types_section)
    [ "$status" -eq 0 ] || { echo "no ## Review Types row for $token"; return 1; }
    [[ "$hint" == *"$token"* ]] || { echo "code-review argument-hint lacks $token"; return 1; }
    [[ "$pr_hint" == *"$token"* ]] || { echo "post-code-review-to-pr argument-hint lacks $token"; return 1; }
  done
  while read -r token; do
    [ -f "$TYPES_DIR/$token.md" ] || { echo "table row $token names no file"; return 1; }
  done < <(table_tokens)
}

@test "every shipped type file has its title and the six sections in order, outside any fenced block" {
  expected=$'## Purpose\n## Roster\n## Checklist categories\n## Severity\n## Instructions\n## Report section'
  for f in "$TYPES_DIR"/*.md; do
    token="$(basename "$f" .md)"
    [ "$(head -n 1 "$f")" = "# Review type: $token" ] || { echo "$f: bad title"; return 1; }
    actual="$(awk '/^```/{fence=!fence; next} !fence && /^## /' "$f")"
    [ "$actual" = "$expected" ] || { echo "$f: sections are"; echo "$actual"; return 1; }
  done
}

@test "every agent in a shipped roster has a roster-table row and a numbered prompt" {
  for f in "$TYPES_DIR"/*.md; do
    while read -r agent; do
      run grep -E "^\| \`$agent\` +\|" "$DISPATCH"
      [ "$status" -eq 0 ] || { echo "$f: $agent has no roster-table row"; return 1; }
      run grep -E "^ ?[0-9]+\. \`$agent\`" "$DISPATCH"
      [ "$status" -eq 0 ] || { echo "$f: $agent has no numbered prompt"; return 1; }
    done < <(roster_agents "$f")
  done
}

@test "the default set's checklist categories cover every bolded checklist category" {
  union="$(
    while read -r token; do
      section_value "$TYPES_DIR/$token.md" "Checklist categories" | tr ',' '\n'
    done < <(default_set) | sed -e 's/^ *//' -e 's/ *$//' | grep -v '^none$' | sort -u
  )"
  checklist="$(sed -nE 's/^\*\*([^*]+)\*\*( \(when applicable\))?$/\1/p' "$CHECKLIST" | sort -u)"
  [ "$(printf '%s\n' "$checklist" | wc -l)" -eq 13 ] || { echo "expected 13 checklist categories"; return 1; }
  [ "$union" = "$checklist" ] || {
    echo "default set union:"; echo "$union"; echo "checklist:"; echo "$checklist"; return 1
  }
}
