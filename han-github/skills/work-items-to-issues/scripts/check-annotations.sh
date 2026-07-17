#!/usr/bin/env bash
# Usage: check-annotations.sh <work-items-file>...
#
# Accounts for every slice heading in every file given: each one is publishable
# here, already published here, or unrecognized. Exits non-zero naming every
# unrecognized heading at once, so a run can stop before creating anything
# anywhere.
#
# A heading is in scope when it carries a symbolic ID (`## W-1 ...`), whatever
# follows it. That admits headings annotated by another tracker and headings a
# hand edit left malformed, and it never matches preamble prose like
# `## Shared reference artifacts`, which carries no symbolic ID.
#
# Takes every per-repo file at once because a file published to another tracker
# is usually annotated across all of its repos: checking one repo at a time
# would create issues in the clean repos before reaching the annotated one.

set -euo pipefail

[ $# -gt 0 ] || {
  echo "usage: check-annotations.sh <work-items-file>..." >&2
  exit 2
}

# Symbolic ID: any uppercase prefix plus a number, per the documented format.
sym='[A-Z][A-Z0-9]*-[0-9]+'

publishable=0
already=0
unrecognized=0
findings=()

for work_items in "$@"; do
  [ -f "$work_items" ] || {
    echo "ERROR: work-items file not found: $work_items" >&2
    exit 2
  }

  lineno=0
  while IFS= read -r line || [ -n "$line" ]; do
    lineno=$((lineno + 1))

    # In scope only if the heading carries a symbolic ID.
    [[ "$line" =~ ^##[[:space:]]+($sym)([[:space:]]|$) ]] || continue
    id="${BASH_REMATCH[1]}"

    if [[ "$line" =~ ^##[[:space:]]+${sym}[[:space:]]+—[[:space:]] ]]; then
      publishable=$((publishable + 1))
    elif [[ "$line" =~ ^##[[:space:]]+${sym}[[:space:]]+\(#[0-9]+\)[[:space:]]+—[[:space:]] ]]; then
      already=$((already + 1))
    else
      unrecognized=$((unrecognized + 1))
      if [[ "$line" =~ \(([^\)]+)\) ]]; then
        findings+=("$work_items:$lineno: $id is annotated by ${BASH_REMATCH[1]} — already published to another tracker?")
      else
        findings+=("$work_items:$lineno: $id heading shape not recognized")
      fi
    fi
  done < "$work_items"
done

total=$((publishable + already + unrecognized))
echo "examined $total slice heading(s): $publishable publishable, $already already published here, $unrecognized unrecognized"

if [ "$unrecognized" -gt 0 ]; then
  {
    echo
    echo "ERROR: $unrecognized slice heading(s) could not be placed. Nothing has been created."
    for finding in "${findings[@]}"; do
      echo "  $finding"
    done
    echo
    echo "Publishing a file that another tracker already published would duplicate that work."
    echo "Resolve each heading above, then re-run."
  } >&2
  exit 1
fi
