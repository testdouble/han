#!/usr/bin/env python3
"""Lightweight Pi compatibility checks for Han.

Checks:
1) Pi marketplace includes the required Han plugin subset for Pi support.
2) Every SKILL.md that declares a "personal config directory" probe uses the cross-host fallback:
   ${AGENT_CONFIG_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}
"""

from __future__ import annotations

import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
CLAUDE_MARKETPLACE = ROOT / ".claude-plugin" / "marketplace.json"
PI_MARKETPLACE = ROOT / ".agents" / "plugins" / "marketplace.json"
SKILL_PROBE_FALLBACK = "${AGENT_CONFIG_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"


def check_marketplace_required_subset() -> list[str]:
    errors: list[str] = []
    claude = json.loads(CLAUDE_MARKETPLACE.read_text())
    pi = json.loads(PI_MARKETPLACE.read_text())

    claude_names = {plugin["name"] for plugin in claude["plugins"]}
    pi_names = {plugin["name"] for plugin in pi["plugins"]}

    # Keep this explicit and small: the plugins we currently commit to exposing in Pi.
    required_for_pi = {
        "han",
        "han-communication",
        "han-core",
        "han-documentation",
        "han-research",
        "han-planning",
        "han-coding",
        "han-github",
        "han-reporting",
        "han-feedback",
        "han-atlassian",
        "han-linear",
        "han-plugin-builder",
    }

    # Guard against stale required names.
    unknown_required = sorted(required_for_pi - claude_names)
    if unknown_required:
        errors.append("Required Pi plugin set includes names missing from Claude marketplace:")
        errors.extend(f"  - {name}" for name in unknown_required)

    missing_in_pi = sorted(required_for_pi - pi_names)
    if missing_in_pi:
        errors.append("Pi marketplace missing required Han plugins:")
        errors.extend(f"  - {name}" for name in missing_in_pi)

    return errors


def check_skill_probe_fallback() -> list[str]:
    errors: list[str] = []
    missing: list[str] = []

    for skill in ROOT.rglob("SKILL.md"):
        text = skill.read_text()
        if "personal config directory:" in text and SKILL_PROBE_FALLBACK not in text:
            missing.append(str(skill.relative_to(ROOT)))

    if missing:
        errors.append("Missing HAN/CLAUDE config fallback probe in SKILL.md files:")
        errors.extend(f"  - {path}" for path in sorted(missing))

    return errors


def main() -> int:
    errors: list[str] = []
    errors.extend(check_marketplace_required_subset())
    errors.extend(check_skill_probe_fallback())

    if errors:
        print("Pi compatibility check failed:\n")
        print("\n".join(errors))
        return 1

    print("Pi compatibility check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
