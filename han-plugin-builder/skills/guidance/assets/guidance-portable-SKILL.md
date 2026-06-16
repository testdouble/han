---
name: guidance
description: >
  Authoritative guidance for building Claude Code skills, agents, and plugins, vendored into this
  repository. Use when you need the rules or best practices for a skill, agent, hook, or plugin —
  designing, reviewing, hardening, or checking one against the guidance. Does not run an interview
  to build a new skill or agent from scratch — use skill-builder or agent-builder. Does not write
  feature code, review application code, or build non-plugin features.
allowed-tools: Read, Glob, Grep, Bash(find *)
---

Serve the relevant guidance for what the user is building. Do not read every
guidance document — that defeats the purpose. Find the one or two that apply,
read them, and apply them.

The guidance documents live in this skill's own `references/` directory. Use
this map to choose, then read only the specific file(s) you need:

- Deciding whether something should be a skill, agent, or hook →
  `${CLAUDE_SKILL_DIR}/references/plugin-entity-taxonomy.md`.
- Authoring or hardening a skill (descriptions, frontmatter, progressive
  disclosure, allowed-tools, scripts, composition, testing, troubleshooting) →
  the files under `${CLAUDE_SKILL_DIR}/references/skill-building-guidance/`.
- Authoring an agent (domain focus, self-containment, model selection,
  multi-agent economics, graceful degradation) → the files under
  `${CLAUDE_SKILL_DIR}/references/agent-building-guidelines/`.
- Plugin or marketplace configuration files (plugin.json, marketplace.json,
  monitors.json, themes.json) → the files under
  `${CLAUDE_SKILL_DIR}/references/claude-marketplace-and-plugin-configuration/`.
- Versioning, README structure, local development, the iterative development
  process, and specialization-versus-model-tier reasoning → the top-level
  files in `${CLAUDE_SKILL_DIR}/references/`.
- Copyable starter files → `${CLAUDE_SKILL_DIR}/references/templates/`.

Steps:

1. Identify what the user is building or asking about.
2. List the relevant subdirectory under `${CLAUDE_SKILL_DIR}/references/` to
   see the available documents, using the map above.
3. Read only the document(s) that directly apply.
4. Apply the guidance to the user's situation. Cite the document you used so
   the user can read it in full if they want.
