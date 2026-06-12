---
name: guidance
description: >
  Authoritative guidance for building Claude Code skills, agents, and plugins, plus init and
  update steps that install and refresh that guidance in the current repository. Use when you
  need the rules or best practices for a skill, agent, hook, or plugin — designing, reviewing,
  hardening, or checking one against the guidance. Run with `init` to vendor the guidance into
  the current repository as a path-scoped rule index, or `update` to refresh an already-vendored
  copy and its rule index. Does not run an interview to build a new skill or agent from scratch —
  use skill-builder or agent-builder. Does not write feature code, review application code, or
  build non-plugin features.
allowed-tools: Read, Glob, Grep, Bash(find *)
---

This skill has three modes. Pick the mode from how it was invoked, then follow
only that mode's steps.

- If the invocation argument is `init` or `initialize` (any case), run
  **Initialization Mode**.
- If the invocation argument is `update` or `refresh` (any case), run
  **Update Mode**.
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

## Update Mode

Refresh the vendored guidance and its rule index in a repository that already
has them, so contributors get the current guidance after this plugin has been
updated. Updating is the same vendoring operation as Initialization Mode — it
replaces the vendored copy and regenerates the rule index — but it first
confirms the guidance is actually installed before touching anything.

1. Check whether the guidance is already installed at the expected location.
   Run `find .claude -maxdepth 2 \( -name plugin-building-guidance -o -name plugin-building-guidance.md \)`
   from the repository root. The guidance is installed only when both the
   `.claude/plugin-building-guidance` directory and the
   `.claude/rules/plugin-building-guidance.md` rule index turn up.
2. If the guidance is **not** installed (the `find` turns up neither, or only
   one of the two), do not update. Tell the user the guidance is not installed
   at the expected location (`.claude/plugin-building-guidance/` and
   `.claude/rules/plugin-building-guidance.md`) and ask whether they want to
   install it now. If they confirm, switch to **Initialization Mode** and run
   its steps. If they decline, stop without writing anything.
3. If the guidance **is** installed, run
   `${CLAUDE_SKILL_DIR}/scripts/init-guidance.sh` from the repository root. The
   script replaces the vendored guidance under `.claude/plugin-building-guidance/`
   with a fresh copy and regenerates the rule index at
   `.claude/rules/plugin-building-guidance.md`, re-detecting the `paths:` globs
   for the current repo. Capture its output.
4. Report to the user what was refreshed: the number of vendored guidance files,
   the rule index path, and the `paths:` globs the script chose.
5. Do not commit. Leave the changes staged for the user to review.
