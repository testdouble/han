#!/usr/bin/env bash
# Usage: upload-screenshots.sh <work-items-file> <target-repo> <plan-folder>
#
# Copies every PNG referenced in the work-items file's screenshot embeds from
# <plan-folder>/ui-designs/<file>.png into <target-repo> at
# .github/issue-assets/<feature-slug>/<SYM-N>/<file>.png. The <feature-slug>
# segment keeps assets from different features that publish to the same repo
# from colliding — every feature restarts its work-item numbering at <PREFIX>-1,
# so a flat <SYM-N> namespace would commingle (and risk overwriting) a prior
# feature's screenshots. The slug is read verbatim from the embedded URL, which
# the work-items file authored as the kebab-cased basename of the plan folder
# (see references/screenshot-embed-rules.md).
#
# The upload mechanism is adaptive:
#   * By default each PNG is written directly to the repo's default branch via
#     the GitHub Contents API. This is fast and fully autonomous — the common
#     case for an unprotected repo.
#   * If the default branch is protected and rejects the direct write (HTTP 409,
#     "changes must be made through a pull request"), the script falls back to
#     committing every PNG to an assets branch and opening a pull request, then
#     prints the PR URL. The embedded image URLs always point at the default
#     branch, so the inline designs render once that PR merges.
#
# Idempotent in both modes: re-running overwrites existing blobs using their
# current sha, reuses an existing assets branch and its open PR, and never
# duplicates work.
#
# Exits 0 with no work when the work-items file contains no screenshot URLs.

set -euo pipefail

WORK_ITEMS="${1:?work-items file required}"
TARGET_REPO="${2:?target repo (org/name, e.g. acme/acme-web) required}"
PLAN_FOLDER="${3:?plan folder required}"

[ -f "$WORK_ITEMS" ] || { echo "work-items file not found: $WORK_ITEMS" >&2; exit 1; }

UI_DESIGNS="$PLAN_FOLDER/ui-designs"

# Extract every embedded same-repo raw URL pointing at
# .github/issue-assets/<feature-slug>/<SYM>/<file>.png.
# A single embed `[![alt](URL)](URL)` produces the URL twice; sort -u dedupes.
# Portable across bash 3.2 (macOS default) and bash 4+ — no mapfile.
URLS=()
while IFS= read -r url; do
  [ -n "$url" ] && URLS+=("$url")
done < <(grep -oE "https://github\.com/${TARGET_REPO//\//\\/}/raw/[^/]+/\.github/issue-assets/[^/]+/[^/]+/[^)]+\.png" "$WORK_ITEMS" | sort -u)

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

# Parse each URL into parallel arrays (bash 3.2 has no associative arrays we can
# rely on). Path shape: .github/issue-assets/<feature-slug>/<SYM>/<file>.png
# field positions under awk -F/ are: $1=.github $2=issue-assets $3=slug
# $4=sym $5=file.
PATHS=(); SYMS=(); FILES=(); SRCS=()
FEATURE_SLUG=""
for url in "${URLS[@]}"; do
  branch=$(echo "$url" | sed -E "s|^https://github\.com/${TARGET_REPO//\//\\/}/raw/([^/]+)/.*|\1|")
  path=$(echo "$url" | sed -E "s|^https://github\.com/${TARGET_REPO//\//\\/}/raw/[^/]+/||")
  slug=$(echo "$path" | awk -F/ '{print $3}')
  sym=$(echo "$path"  | awk -F/ '{print $4}')
  file=$(echo "$path" | awk -F/ '{print $5}')
  src="$UI_DESIGNS/$file"

  if [ "$branch" != "$DEFAULT_BRANCH" ]; then
    echo "ERROR: embedded URL references branch '$branch' but $TARGET_REPO default is '$DEFAULT_BRANCH'" >&2
    echo "  url: $url" >&2
    echo "  fix the work-items file to use the default branch, then re-run" >&2
    exit 1
  fi

  [ -f "$src" ] || { echo "ERROR: source PNG not found: $src" >&2; exit 1; }

  PATHS+=("$path"); SYMS+=("$sym"); FILES+=("$file"); SRCS+=("$src")
  FEATURE_SLUG="$slug"
done

# Write one PNG to <branch> at its Contents API path. Creates or overwrites,
# fetching the current sha on that branch first so the PUT is idempotent.
# Prints "added"/"updated" on stdout; gh errors flow to stderr. Returns the
# PUT's exit status so the caller can distinguish a branch-protection rejection
# from success. The `|| return $?` after each PUT is load-bearing: the trailing
# echo would otherwise become the function's last command and mask a failed
# PUT with status 0 — and because the probe calls put_file inside an `if`
# condition, `set -e` is suppressed in this body and will not catch it either.
put_file() {
  local branch="$1" api_path="$2" src="$3" sym="$4" file="$5"
  local content_b64 existing_sha
  content_b64=$(base64_encode "$src")
  # Gate on gh's exit status, not on the captured output. On a 404 (file not
  # yet present) gh prints the error body to stdout and does not apply --jq, so
  # capturing with `|| true` would leave the JSON error in existing_sha and
  # wrongly take the update path. The `|| existing_sha=""` resets it to empty
  # when the GET fails, so a missing file is correctly treated as an add.
  existing_sha=$(gh api "$api_path?ref=$branch" --jq .sha 2>/dev/null) || existing_sha=""
  if [ -n "$existing_sha" ]; then
    gh api --method PUT "$api_path" \
      -f message="issue-assets: update $file for $sym" \
      -f content="$content_b64" \
      -f branch="$branch" \
      -f sha="$existing_sha" >/dev/null || return $?
    echo updated
  else
    gh api --method PUT "$api_path" \
      -f message="issue-assets: add $file for $sym" \
      -f content="$content_b64" \
      -f branch="$branch" >/dev/null || return $?
    echo added
  fi
}

# Verify a path is visible on <branch> via the Contents API. Read-after-write is
# eventually consistent, so retry briefly. We verify against the branch we wrote
# to (the default branch in direct mode, the assets branch in PR mode) rather
# than the public raw URL, because a private repo returns 404 to anonymous raw
# requests — but GitHub's in-app image proxy still renders the embed for
# authenticated viewers, so the issue body is correct.
verify_on() {
  local branch="$1" api_path="$2"
  for _ in 1 2 3 4 5; do
    if gh api "$api_path?ref=$branch" --jq .sha >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}

upload_all_to() {
  local branch="$1" i action api_path
  for i in "${!PATHS[@]}"; do
    api_path="repos/$TARGET_REPO/contents/${PATHS[$i]}"
    action=$(put_file "$branch" "$api_path" "${SRCS[$i]}" "${SYMS[$i]}" "${FILES[$i]}")
    if ! verify_on "$branch" "$api_path"; then
      echo "ERROR: verification failed — ${PATHS[$i]} not visible on '$branch' after PUT (5 retries)" >&2
      exit 1
    fi
    echo "$action: ${PATHS[$i]}  (branch: $branch)"
  done
}

# Decide the mode by probing the direct write of the first asset. A success
# means the default branch accepts direct commits (unprotected) and we continue
# in direct mode with the rest. A branch-protection rejection switches the whole
# run to PR mode; nothing was written by a rejected PUT, so there is no partial
# state to undo. Any other failure is a genuine error and we surface it.
FIRST_API="repos/$TARGET_REPO/contents/${PATHS[0]}"
if PROBE_OUT=$(put_file "$DEFAULT_BRANCH" "$FIRST_API" "${SRCS[0]}" "${SYMS[0]}" "${FILES[0]}" 2>&1); then
  # Direct mode: first asset is already uploaded. Verify it, then do the rest.
  if ! verify_on "$DEFAULT_BRANCH" "$FIRST_API"; then
    echo "ERROR: verification failed — ${PATHS[0]} not visible on '$DEFAULT_BRANCH' after PUT (5 retries)" >&2
    exit 1
  fi
  echo "$PROBE_OUT: ${PATHS[0]}  (branch: $DEFAULT_BRANCH)"
  for i in "${!PATHS[@]}"; do
    [ "$i" -eq 0 ] && continue
    api_path="repos/$TARGET_REPO/contents/${PATHS[$i]}"
    action=$(put_file "$DEFAULT_BRANCH" "$api_path" "${SRCS[$i]}" "${SYMS[$i]}" "${FILES[$i]}")
    if ! verify_on "$DEFAULT_BRANCH" "$api_path"; then
      echo "ERROR: verification failed — ${PATHS[$i]} not visible on '$DEFAULT_BRANCH' after PUT (5 retries)" >&2
      exit 1
    fi
    echo "$action: ${PATHS[$i]}  (branch: $DEFAULT_BRANCH)"
  done
  echo "all screenshots uploaded and verified for $TARGET_REPO"
  exit 0
fi

# The direct probe failed. Only a branch-protection rejection is recoverable;
# anything else is a real error.
if ! echo "$PROBE_OUT" | grep -qiE 'pull request|protected branch|required status check|HTTP 409'; then
  echo "ERROR: failed to upload ${PATHS[0]} to $TARGET_REPO" >&2
  echo "$PROBE_OUT" >&2
  exit 1
fi

# PR mode. Commit every asset to a deterministic assets branch and open — or
# reuse — a pull request into the default branch.
#
# The branch name is derived from the feature slug, so it is possible (if
# unlikely) for a branch of that exact name to already exist for an unrelated
# reason. Guard against ever adding commits to a branch this skill did not
# create: a pre-existing branch is adopted only when it already carries this
# feature's .github/issue-assets/<slug>/ tree — the signature of our own prior
# run (including one that was interrupted before opening the PR). A same-named
# branch without that tree is refused, so no foreign work is ever touched.
ASSETS_BRANCH="issue-assets/$FEATURE_SLUG"
echo "default branch '$DEFAULT_BRANCH' is protected — falling back to a pull request on '$ASSETS_BRANCH'"

if gh api "repos/$TARGET_REPO/git/ref/heads/$ASSETS_BRANCH" >/dev/null 2>&1; then
  if gh api "repos/$TARGET_REPO/contents/.github/issue-assets/$FEATURE_SLUG?ref=$ASSETS_BRANCH" >/dev/null 2>&1; then
    echo "reusing existing assets branch: $ASSETS_BRANCH"
  else
    echo "ERROR: branch '$ASSETS_BRANCH' already exists in $TARGET_REPO but carries no" >&2
    echo "  '.github/issue-assets/$FEATURE_SLUG/' tree, so this skill did not create it" >&2
    echo "  for this feature. Refusing to commit onto a branch it does not own." >&2
    echo "  Inspect that branch: if it is safe to discard (e.g. an interrupted prior" >&2
    echo "  run that uploaded nothing), delete it and re-run; otherwise rename the" >&2
    echo "  plan folder so the assets branch gets a distinct name." >&2
    exit 1
  fi
else
  base_sha=$(gh api "repos/$TARGET_REPO/git/ref/heads/$DEFAULT_BRANCH" --jq .object.sha)
  gh api --method POST "repos/$TARGET_REPO/git/refs" \
    -f ref="refs/heads/$ASSETS_BRANCH" \
    -f sha="$base_sha" >/dev/null
  echo "created assets branch: $ASSETS_BRANCH"
fi

upload_all_to "$ASSETS_BRANCH"

PR_URL=$(gh pr list --repo "$TARGET_REPO" --head "$ASSETS_BRANCH" --state open --json url --jq '.[0].url // empty')
if [ -z "$PR_URL" ]; then
  PR_URL=$(gh pr create --repo "$TARGET_REPO" \
    --head "$ASSETS_BRANCH" \
    --base "$DEFAULT_BRANCH" \
    --title "issue-assets: design screenshots for $FEATURE_SLUG" \
    --body "Adds issue design screenshots under \`.github/issue-assets/$FEATURE_SLUG/\`. Inline images in the related issues render once this merges.")
fi

echo
echo "NOTE: $TARGET_REPO's default branch is protected, so design assets were"
echo "      committed to branch '$ASSETS_BRANCH' and a pull request was opened:"
echo "        $PR_URL"
echo "      The issues are created now; their inline design images will render"
echo "      once this assets PR merges."
