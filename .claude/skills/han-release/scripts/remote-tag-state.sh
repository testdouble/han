#!/usr/bin/env bash
#
# Classify each of a release's expected tags against what the remote actually holds.
#
# The plugin tagging command never consults the remote, so a release that walks every
# plugin has no way to tell three states apart on its own: a tag already published, a
# tag that was created locally and never pushed, and a tag somebody else already took
# at a different commit. Those three need different behavior, and one of them is
# unrecoverable, so this reads the remote once and says which is which.
#
# Usage: remote-tag-state.sh <release-commit-sha> <tag>...
#
# THE PEEL IS THE POINT. `git ls-remote --tags` reports the *tag object* SHA for an
# annotated tag, not the commit it points at, and `claude plugin tag` creates annotated
# tags. Comparing the unpeeled value against a commit therefore reports "different
# commit" for every tag ever created this way. Git publishes the commit alongside, in a
# second `refs/tags/<name>^{}` line, so the peeled line wins wherever it exists.
#
# Output is line-oriented and tab-separated, one row per requested tag, in the order the
# tags were given:
#
#   <tag>\t<state>\t<sha>
#
#   absent                  neither on the remote nor local; create and push it
#   remote-at-commit        on the remote at the release commit; skip it
#   remote-at-other-commit  on the remote at a different commit; the CALLER decides what
#                           that means, because this script cannot see the version plan.
#                           An unchanged plugin keeps its version and so keeps the tag an
#                           earlier release gave it, which is the normal resting state; a
#                           tag being created right now is a collision and unrecoverable.
#   local-only              on this machine only; push it, never treat it as a skip
#
# The sha column carries the commit the tag resolves to, or `-` when the tag is absent.
#
# Exit: 0 every requested tag classified, 2 could not reach the remote. A tag in any
# state is still a successful classification, so the caller reads the rows rather than
# the exit status to decide what to do. Only an unreadable remote is an error here,
# because a run that cannot see the remote must not guess.

set -euo pipefail

RELEASE_COMMIT="${1:?release commit sha required}"
shift || true

if [ "$#" -eq 0 ]; then
  echo "error: at least one tag name required" >&2
  exit 2
fi

REMOTE="${HAN_RELEASE_REMOTE:-origin}"

# One network round trip for every tag, rather than one per tag. `--tags` restricts the
# listing to refs/tags/, and the output carries both the tag-object line and the peeled
# `^{}` line for an annotated tag.
if ! remote_listing="$(git ls-remote --tags "$REMOTE" 2>/dev/null)"; then
  echo "error: could not read tags from remote '$REMOTE'" >&2
  exit 2
fi

# Resolve one tag name against the remote listing. Prefers the peeled line, so an
# annotated tag reports the commit and a lightweight tag reports its only line.
# Prints nothing when the remote does not carry the tag.
remote_sha_for() {
  local tag="$1" peeled plain
  peeled="$(printf '%s\n' "$remote_listing" | awk -v ref="refs/tags/$tag^{}" '$2 == ref { print $1; exit }')"
  if [ -n "$peeled" ]; then
    printf '%s' "$peeled"
    return 0
  fi
  plain="$(printf '%s\n' "$remote_listing" | awk -v ref="refs/tags/$tag" '$2 == ref { print $1; exit }')"
  printf '%s' "$plain"
}

for tag in "$@"; do
  remote_sha="$(remote_sha_for "$tag")"

  if [ -n "$remote_sha" ]; then
    if [ "$remote_sha" = "$RELEASE_COMMIT" ]; then
      printf '%s\t%s\t%s\n' "$tag" "remote-at-commit" "$remote_sha"
    else
      printf '%s\t%s\t%s\n' "$tag" "remote-at-other-commit" "$remote_sha"
    fi
    continue
  fi

  # Not on the remote. `git rev-list -n1` peels a local annotated tag the same way the
  # `^{}` line does for a remote one, so both halves of the comparison mean the commit.
  if local_sha="$(git rev-list -n1 "$tag" 2>/dev/null)" && [ -n "$local_sha" ]; then
    printf '%s\t%s\t%s\n' "$tag" "local-only" "$local_sha"
  else
    printf '%s\t%s\t%s\n' "$tag" "absent" "-"
  fi
done
