---
name: guidance
description: >
  Authoritative guidance for building Claude Code skills, agents, and plugins,
  plus an init step that installs that guidance into the current repository.
  Use when building, authoring, designing, reviewing, or hardening a skill,
  agent, hook, or plugin — including questions about SKILL.md frontmatter,
  skill descriptions, progressive disclosure, allowed-tools, agent model
  selection, plugin.json or marketplace.json, semantic versioning, or whether
  a capability should be a skill or an agent. Run with `init` or `initialize`
  to vendor the full guidance set into `.claude/plugin-building-guidance/` and
  write a path-scoped rule index at `.claude/rules/plugin-building-guidance.md`,
  so the right guidance surfaces automatically while editing skill and agent
  files without this plugin staying installed. Does not write feature code,
  review application code, or build non-plugin features.
allowed-tools: Read, Glob, Grep, Bash(find *)
---

This skill has two modes. Pick the mode from how it was invoked, then follow
only that mode's steps.

- If the invocation argument is `init` or `initialize` (any case), run
  **Initialization Mode**.
- Otherwise, run **Guidance Mode**.

## Guidance Mode

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

## Initialization Mode

Install the guidance into the current repository so contributors get the right
guidance surfaced automatically while editing skill and agent files, with no
dependency on this plugin remaining installed.

1. Run `${CLAUDE_SKILL_DIR}/scripts/init-guidance.sh` from the repository root.
   The script vendors a full copy of the guidance documents into
   `.claude/plugin-building-guidance/`, detects which globs cover this repo's
   agent and skill files, and writes the path-scoped rule index at
   `.claude/rules/plugin-building-guidance.md`. Capture its output.
2. Report to the user what was written: the number of vendored guidance files,
   the rule index path, and the `paths:` globs the script chose. Explain that
   the rule index is an index only — Claude Code loads it when a matching skill
   or agent file is touched, and it points to the vendored documents so only
   the guidance needed for the current file is loaded, not all of it.
3. Do not commit. Leave the new files staged for the user to review.
