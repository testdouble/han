#!/usr/bin/env bash
# Prints the Claude Code configuration directory for this run.
set -euo pipefail
printf '%s\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
