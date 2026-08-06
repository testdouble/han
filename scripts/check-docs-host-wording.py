#!/usr/bin/env python3
"""Advisory guard against accidental Claude-only phrasing in core Han docs.

Scope is intentionally narrow and excludes historical artifacts:
- checks only selected user-facing docs
- does not scan docs/plans/** or docs/research/**

This is not a blanket ban on mentioning Claude Code. It flags phrasing that
presents Claude Code as the only host in generic guidance.

Advisory mode: findings are reported, but this script exits 0.
"""

from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

TARGET_FILES = [
    "README.md",
    "docs/concepts.md",
    "docs/quickstart.md",
    "docs/configuration.md",
    "docs/skills/README.md",
    "docs/agents/README.md",
    "docs/workflows.md",
    "docs/templates/skill-long-form-template.md",
    "docs/why-solo-and-small-teams.md",
]

# Patterns that usually indicate accidental host lock-in for generic guidance.
BANNED_PATTERNS = [
    re.compile(r"\bRun `/.+` in Claude Code\b"),
    re.compile(r"\bin your Claude Code configuration directory\b"),
    re.compile(r"\bfrom Claude Code\b"),
]

# Allowed mentions where Claude-specific wording is intentional.
ALLOW_SUBSTRINGS = [
    "### Claude Code",
    "Claude Code Skills reference",
    "Claude Code Subagents reference",
    "for example Claude Code or Pi",
    "Claude Code and Claude Cowork",
    "Any MCP-compatible AI client (Claude Code, Cursor, GitHub Copilot,",
]


def main() -> int:
    violations: list[str] = []

    for rel in TARGET_FILES:
        path = ROOT / rel
        if not path.exists():
            continue

        for line_no, line in enumerate(path.read_text().splitlines(), start=1):
            if "Claude Code" not in line:
                continue
            if any(allowed in line for allowed in ALLOW_SUBSTRINGS):
                continue

            for pattern in BANNED_PATTERNS:
                if pattern.search(line):
                    violations.append(f"{rel}:{line_no}: {line.strip()}")
                    break

    if violations:
        print("Docs host-wording advisory: found Claude-only phrasing in core docs:\n")
        print("\n".join(violations))
        print(
            "\nUse host-neutral wording (for example, 'coding-agent host') unless the line is intentionally host-specific."
        )
        print("\nContinuing in advisory mode (exit 0).")
        return 0

    print("Docs host-wording check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
