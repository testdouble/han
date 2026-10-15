#!/usr/bin/env bats
#
# Guards the agent-role contract in han-planning/references/agent-roles.md.
# An agent in any plugin claims a han-planning role with one sentence in its
# description, and a planning skill fills the role from whichever installed
# agent claims it. Nothing at runtime notices a claim for a role that does not
# exist: the agent is never selected, and the role is skipped as if the plugin
# were not installed. These checks catch that drift in the repo instead.
#
# Portability: keep to bash 3.2, and grep one named file at a time, never -r
# (see test/codex-packaging.bats for why).

REPO_ROOT="${BATS_TEST_DIRNAME}/.."
ROLES='han-planning/references/agent-roles.md'

# Every role defined in the roles file, one per line.
defined_roles() {
  cd "$REPO_ROOT" || return 1
  sed -n 's/^### `\([a-z0-9-]*\)`$/\1/p' "$ROLES"
}

# Every "file role" pair claimed by an agent description, one per line.
claimed_roles() {
  cd "$REPO_ROOT" || return 1
  for f in han-*/agents/*.md; do
    sed -n 's/.*Fills the han-planning `\([a-z0-9-]*\)` role\..*/\1/p' "$f" |
      while read -r role; do printf '%s %s\n' "$f" "$role"; done
  done
}

@test "the roles file defines at least one role" {
  run defined_roles
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "every role an agent claims is defined in the roles file" {
  roles="$(defined_roles)"
  missing=''
  while read -r file role; do
    [ -z "$file" ] && continue
    printf '%s\n' "$roles" | grep -qx "$role" || missing="${missing}${file} claims undefined role '${role}'"$'\n'
  done <<EOF
$(claimed_roles)
EOF
  [ -z "$missing" ] || { printf '%s' "$missing"; return 1; }
}

@test "every defined role is claimed by at least one agent in the repo" {
  claimed="$(claimed_roles)"
  missing=''
  for role in $(defined_roles); do
    printf '%s\n' "$claimed" | grep -q " ${role}\$" || missing="${missing}no agent claims role '${role}'"$'\n'
  done
  [ -z "$missing" ] || { printf '%s' "$missing"; return 1; }
}
