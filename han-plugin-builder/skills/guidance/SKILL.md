---
name: guidance
description: >
  Authoritative guidance for building Claude Code skills, agents, and plugins, plus init and
  update steps that install and refresh the plugin-building skills in the current repository. Use
  when you need the rules or best practices for a skill, agent, hook, or plugin — designing,
  reviewing, hardening, or checking one against the guidance. Run with `init` to vendor the
  guidance, skill-builder, and agent-builder skills into the current repository (so they run with
  no dependency on this plugin) plus a path-scoped rule index, or `update` to refresh an
  already-vendored copy. Does not run an interview to build a new skill or agent from scratch —
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

Install the plugin-building skills into the current repository so anyone using
the repo can run them and consult the guidance, with no dependency on this
plugin remaining installed.

1. Run `${CLAUDE_SKILL_DIR}/scripts/init-guidance.sh` from the repository root.
   The script vendors three skills into `.claude/skills/` under a `plugin-`
   prefix so they never collide with this plugin's own slash commands: a
   guidance-only `plugin-guidance` skill (whose `references/` directory is the
   single in-repo copy of the guidance documents), `plugin-skill-builder`, and
   `plugin-agent-builder` (with their names, cross-references, and guidance paths
   rewritten to that vendored copy). It then writes the path-scoped rule index at
   `.claude/rules/plugin-building-guidance.md`. Capture its output.
2. Report to the user what was written: the three vendored skills, the total
   file count, the rule index path, and the `paths:` globs. Explain that the
   three skills are now available directly in the repo (`/plugin-guidance`,
   `/plugin-skill-builder`, `/plugin-agent-builder`) and that the rule index is
   an index only — Claude Code loads it when a matching skill or agent file is
   touched, and it points to the vendored guidance so only the documents the
   current file needs are loaded, not all of them.
3. Do not commit. Leave the new files staged for the user to review.

## Update Mode

Refresh the vendored skills and their rule index in a repository that already
has them, so contributors get the current skills and guidance after this plugin
has been updated. Updating is the same vendoring operation as Initialization
Mode — it replaces every vendored skill in full (each `SKILL.md` and the
guidance documents under `plugin-guidance/references/`, removing any files that
the plugin source has since dropped) and regenerates the rule index — but it
first confirms the skills are actually installed before touching anything.

1. Check whether the skills are already installed at the expected location.
   Run `find .claude -maxdepth 3 \( -path '*/skills/plugin-guidance' -o -name plugin-building-guidance.md \)`
   from the repository root. The skills are installed only when both the
   `.claude/skills/plugin-guidance` directory and the
   `.claude/rules/plugin-building-guidance.md` rule index turn up.
2. If the skills are **not** installed (the `find` turns up neither, or only
   one of the two), do not update. Tell the user the skills are not installed
   at the expected location (`.claude/skills/plugin-guidance/` and
   `.claude/rules/plugin-building-guidance.md`) and ask whether they want to
   install them now. If they confirm, switch to **Initialization Mode** and run
   its steps. If they decline, stop without writing anything.
3. If the skills **are** installed, run
   `${CLAUDE_SKILL_DIR}/scripts/init-guidance.sh` from the repository root. The
   script removes each vendored skill directory and re-copies it fresh from the
   plugin source, so every `SKILL.md` and every guidance document under
   `plugin-guidance/references/` is replaced with the current version (and any
   file the plugin has since removed is dropped), then regenerates the rule
   index at `.claude/rules/plugin-building-guidance.md`. Capture its output.
4. Report to the user what was refreshed: the three vendored skills, the total
   file count, the rule index path, and the `paths:` globs.
5. Do not commit. Leave the changes staged for the user to review.
