#!/usr/bin/env bats
#
# Guards the Codex packaging surface. A package Codex can install needs
# two files that nothing derives from the other: a .codex-plugin/plugin.json
# in its own directory, and an entry in .agents/plugins/marketplace.json.
# Commit 2c09799 added two plugins and updated only the Claude marketplace,
# so both stayed uninstallable until issue #198 reported it.
#
# The directory tree is the authority: every han-* directory needs both.
# The han-* glob excludes the han/ meta-plugin structurally, because han/
# does not match it and Codex does not support meta-plugins.
#
# Portability, since this runs on macOS locally and ubuntu-latest in CI.
# The older shell is the local one, so CI will not catch a bash 4+ feature:
# keep to bash 3.2 (no mapfile, no declare -A, no ${x^^}, no globstar).
# Grep one named file, never -r: BSD grep follows symlinks during a
# recursive search and GNU grep does not, and this repo has thirteen
# root-escaping symlinks at han-*/scripts/han-config-dir.sh.
#
# The catalog greps match Prettier's byte formatting: one space after each
# colon, one key per line. .pre-commit-config.yaml gives Prettier ownership
# of JSON and runs it first, so that shape is stable. Reformatting the
# catalog by hand would break these matches.

REPO_ROOT="${BATS_TEST_DIRNAME}/.."
CATALOG='.agents/plugins/marketplace.json'

# Every Codex package, one per line.
codex_packages() {
  cd "$REPO_ROOT" || return 1
  for dir in han-*/; do printf '%s\n' "${dir%/}"; done
}

@test "at least one han-* package is found" {
  run codex_packages
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "every han-* package carries a Codex manifest" {
  cd "$REPO_ROOT" || return 1
  failed=0
  for pkg in $(codex_packages); do
    [ -f "${pkg}/.codex-plugin/plugin.json" ] || {
      printf '%s\n' "codex manifest missing: ${pkg}/.codex-plugin/plugin.json (copy han-ddd/.codex-plugin/plugin.json and edit the package-specific fields)"
      failed=1
    }
  done
  [ "$failed" -eq 0 ]
}

@test "every han-* package has a catalog entry naming it and pointing at it" {
  cd "$REPO_ROOT" || return 1
  failed=0
  for pkg in $(codex_packages); do
    grep -A3 -- "\"name\": \"${pkg}\"" "$CATALOG" | grep -qF -- "\"path\": \"./${pkg}\"" || {
      printf '%s\n' "catalog entry missing: add \"name\": \"${pkg}\" with \"path\": \"./${pkg}\" to ${CATALOG}"
      failed=1
    }
  done
  [ "$failed" -eq 0 ]
}
