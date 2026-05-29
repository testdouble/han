#!/usr/bin/env bash
#
# inline-mermaid.sh
#
# Replace the mermaid-bundle placeholder in an HTML file with the vendored
# mermaid.min.js bundle inlined as a <script> tag.
#
# Usage:
#   inline-mermaid.sh <path-to-html-file>
#
# Behavior:
#   - Looks for the literal placeholder string `<!-- MERMAID_BUNDLE_INLINE_HERE -->`
#     in the HTML file.
#   - If found, replaces it with the raw vendored mermaid bundle contents. The
#     template already wraps the placeholder in `<script id="mermaid-bundle">...
#     </script>`; this script does not add its own script tags.
#   - If not found, exits 0 without modifying the file (idempotent — already inlined,
#     or this report has no diagrams).
#   - The vendored bundle lives at assets/mermaid.min.js next to this script's
#     parent directory.
#
# Exit codes:
#   0 — success (file modified or no placeholder found)
#   1 — bad usage or input
#   2 — vendored mermaid bundle missing

set -euo pipefail

log() { printf '%s\n' "$*" >&2; }
die() {
  local msg="$1"
  local code="${2:-1}"
  log "error: $msg"
  exit "$code"
}

if [ "$#" -ne 1 ]; then
  die "usage: $(basename "$0") <path-to-html-file>" 1
fi

input="$1"
[ -f "$input" ] || die "file not found: $input" 1

script_dir="$(cd "$(dirname "$0")" && pwd)"
bundle="$script_dir/../assets/mermaid.min.js"
[ -f "$bundle" ] || die "vendored mermaid bundle missing: $bundle" 2

placeholder="<!-- MERMAID_BUNDLE_INLINE_HERE -->"

if ! grep -qF "$placeholder" "$input"; then
  log "no mermaid placeholder in $input — nothing to inline"
  exit 0
fi

tmp="$(mktemp -t html-summary.XXXXXX)"
trap 'rm -f "$tmp"' EXIT

# Use awk to do the replacement. The bundle is read fresh on each placeholder
# encounter so multiple placeholders (rare) would all be filled.
awk -v bundle="$bundle" -v marker="$placeholder" '
  index($0, marker) {
    before = substr($0, 1, index($0, marker) - 1)
    after  = substr($0, index($0, marker) + length(marker))
    printf "%s\n", before
    while ((getline line < bundle) > 0) print line
    close(bundle)
    printf "%s\n", after
    next
  }
  { print }
' "$input" > "$tmp"

mv "$tmp" "$input"
trap - EXIT

log "inlined mermaid bundle ($(wc -c < "$bundle") bytes) into $input"
