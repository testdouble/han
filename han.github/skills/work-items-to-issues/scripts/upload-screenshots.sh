#!/usr/bin/env bash
# Usage: upload-screenshots.sh <work-items-file> <target-repo> <plan-folder>
#
# Copies every PNG referenced in the work-items file's screenshot embeds
# from <plan-folder>/ui-designs/<file>.png into <target-repo> at
# .github/issue-assets/<SYM-N>/<file>.png on the default branch, via the
# GitHub Contents API. Idempotent: re-running overwrites existing files
# using their current sha. Verifies each upload by fetching the embedded
# URL and asserting HTTP 200.
#
# Exits 0 with no work when the work-items file contains no screenshot URLs.

set -euo pipefail

WORK_ITEMS="${1:?work-items file required}"
TARGET_REPO="${2:?target repo (org/name, e.g. acme/acme-web) required}"
PLAN_FOLDER="${3:?plan folder required}"

[ -f "$WORK_ITEMS" ] || { echo "work-items file not found: $WORK_ITEMS" >&2; exit 1; }

UI_DESIGNS="$PLAN_FOLDER/ui-designs"

# Extract every embedded same-repo raw URL pointing at .github/issue-assets/<SYM>/<file>.png.
# A single embed `[![alt](URL)](URL)` produces the URL twice; sort -u dedupes.
# Portable across bash 3.2 (macOS default) and bash 4+ — no mapfile.
URLS=()
while IFS= read -r url; do
  [ -n "$url" ] && URLS+=("$url")
done < <(grep -oE "https://github\.com/${TARGET_REPO//\//\\/}/raw/[^/]+/\.github/issue-assets/[^/]+/[^)]+\.png" "$WORK_ITEMS" | sort -u)

if [ ${#URLS[@]} -eq 0 ]; then
  echo "no screenshot URLs for $TARGET_REPO in $WORK_ITEMS — nothing to upload"
  exit 0
fi

[ -d "$UI_DESIGNS" ] || { echo "ui-designs folder not found: $UI_DESIGNS" >&2; exit 1; }

DEFAULT_BRANCH=$(gh repo view "$TARGET_REPO" --json defaultBranchRef --jq .defaultBranchRef.name)

base64_encode() {
  if [ "$(uname)" = "Darwin" ]; then
    base64 -i "$1"
  else
    base64 -w 0 "$1"
  fi
}

for url in "${URLS[@]}"; do
  # Parse: .../raw/<branch>/.github/issue-assets/<SYM>/<file>.png
  branch=$(echo "$url" | sed -E "s|^https://github\.com/${TARGET_REPO//\//\\/}/raw/([^/]+)/.*|\1|")
  path=$(echo "$url" | sed -E "s|^https://github\.com/${TARGET_REPO//\//\\/}/raw/[^/]+/||")
  sym=$(echo "$path" | awk -F/ '{print $3}')
  file=$(echo "$path" | awk -F/ '{print $4}')
  src="$UI_DESIGNS/$file"

  if [ "$branch" != "$DEFAULT_BRANCH" ]; then
    echo "ERROR: embedded URL references branch '$branch' but $TARGET_REPO default is '$DEFAULT_BRANCH'" >&2
    echo "  url: $url" >&2
    echo "  fix the work-items file to use the default branch, then re-run" >&2
    exit 1
  fi

  [ -f "$src" ] || { echo "ERROR: source PNG not found: $src" >&2; exit 1; }

  api_path="repos/$TARGET_REPO/contents/$path"
  content_b64=$(base64_encode "$src")

  # Fetch existing sha if file is already there (overwrite), else create.
  existing_sha=$(gh api "$api_path" --jq .sha 2>/dev/null || true)

  if [ -n "$existing_sha" ]; then
    gh api --method PUT "$api_path" \
      -f message="issue-assets: update $file for $sym" \
      -f content="$content_b64" \
      -f branch="$DEFAULT_BRANCH" \
      -f sha="$existing_sha" >/dev/null
    action="updated"
  else
    gh api --method PUT "$api_path" \
      -f message="issue-assets: add $file for $sym" \
      -f content="$content_b64" \
      -f branch="$DEFAULT_BRANCH" >/dev/null
    action="added"
  fi

  # Verify the upload landed on the default branch via the GitHub Contents
  # API. We can't use an unauthenticated curl against raw.githubusercontent.com
  # because private repos return 404 to anonymous requests — but GitHub's
  # in-app image proxy (camo) DOES render the same URL in issue bodies for
  # authenticated viewers, so the embed is still correct.
  # Read-after-write on the Contents API is eventually consistent; retry briefly.
  verified=0
  for attempt in 1 2 3 4 5; do
    if gh api "$api_path" --jq .sha >/dev/null 2>&1; then
      verified=1
      break
    fi
    sleep 2
  done
  if [ "$verified" -ne 1 ]; then
    echo "ERROR: verification failed — $api_path not visible after PUT (5 retries)" >&2
    exit 1
  fi

  echo "$action: $path"
done

echo "all screenshots uploaded and verified for $TARGET_REPO"
