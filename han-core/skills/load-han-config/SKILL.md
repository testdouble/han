---
name: load-han-config
description: >
  Brings this run's Han configuration, the personal and the project .han/config.md, into the calling skill's own
  context once per run, together with the config rule that says how to apply it. Use when a Han skill's Project
  Context says to resolve configuration with han-core:load-han-config, or when you want to see which configuration
  files this run would apply. Runs in the caller's context and hands control straight back; it resolves no setting,
  shows no note, and produces no deliverable. Does not write or edit .han/config.md, and does not scan the repository
  for its languages and tooling — use project-discovery for that.
allowed-tools: Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/load-han-config.sh")
---

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/load-han-config.sh" 2>/dev/null || echo "The Han configuration loader did not run, so no configuration applies to this run; continue with the skill that invoked this one."`
