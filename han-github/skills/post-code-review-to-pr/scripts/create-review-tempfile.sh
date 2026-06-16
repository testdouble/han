#!/bin/bash
temp_file=$(mktemp "${TMPDIR:-/tmp/}pr-review-body-XXXXXXXX")
mv "$temp_file" "${temp_file}.md"
temp_file="${temp_file}.md"
echo "$temp_file"
