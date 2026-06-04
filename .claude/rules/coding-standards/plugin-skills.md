---
paths:
  - "plugin/skills/**/*.md"
  - "plugin/skills/**/scripts/**"
---

# Plugin skills coding standards index

You are reading this file because Claude Code loaded it as a path-scoped
rule — you just read or are about to read a file matching one of the
globs in this file's `paths:` frontmatter.

This file is an **index**, not a standard. Each entry below points to a
canonical coding standard with a short description of what it covers and
when it applies.

Coding standards for this project live in their canonical documentation
directory (usually `docs/coding-standards/`) and are exposed to Claude
Code through per-file-type index files under
`.claude/rules/coding-standards/`. The full text of a standard is loaded
only when you decide it applies and use the Read tool to open it. This
keeps context lean and lets you make a relevance decision before paying
the token cost.

**Do not read every linked standard.** For the specific task you are
doing right now, scan the descriptions and identify only the standards
that are clearly relevant. Then use the Read tool to open just those
files. If no entry is clearly relevant, do not open any of them.

If you are unsure whether a standard applies, do not open it. The
author of the work can prompt you to load a specific standard if needed.
Loading standards that do not apply burns context and dilutes attention
on the ones that do.

## Available standards

- [`AskUserQuestion` in Skill `allowed-tools`](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md) — Why `AskUserQuestion` must never appear in a skill's `allowed-tools` frontmatter. Read when adding or editing the `allowed-tools` line in a SKILL.md.
- [Bash Permission Patterns in `allowed-tools`](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-bash-permissions.md) — Syntax and granularity rules for `Bash(...)` entries in `allowed-tools`. Read when adding, removing, or scoping bash commands in a SKILL.md.
- [Claude Cowork — Complete Reference](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/cowork-specific-skill-instructions.md) — Reference for skills targeted at the Claude Cowork desktop product (not developer workflows). Read only when authoring a skill that ships for Cowork users.
- [Context Hygiene](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/context-hygiene.md) — The attention-budget reasoning behind progressive disclosure, frontmatter conciseness, and reference extraction. Read when deciding whether content earns its place in a SKILL.md or should move to `references/`.
- [Context Injection Commands in Skill Files](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md) — Using `` !`command` `` syntax to inject runtime context at skill load time. Read when adding or debugging a `## Project Context` block or any inline shell command in a skill.
- [Documentation Maintenance](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/documentation-maintenance.md) — Auditing skills so their instructions don't silently rot when the underlying tooling, agents, or repository conventions change. Read when editing a skill that hasn't been touched in a while, or when downstream code has changed shape.
- [Dynamic Project Discovery](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/dynamic-project-discovery.md) — Rules for discovering branches, tool availability, and project structure at runtime instead of hardcoding. Read when a skill needs to know the default branch, project layout, or which CLIs are installed.
- [Graceful Degradation](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/graceful-degradation.md) — Detecting partial environments (missing git history, absent project config) and selecting a named execution mode rather than hard-failing. Read when a skill must still produce useful output in incomplete environments.
- [Hardening: Fuzzy vs. Deterministic Steps](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/hardening-fuzzy-vs-deterministic.md) — Decision framework for classifying steps as fuzzy reasoning (stay in SKILL.md) or deterministic operations (extract to scripts). Read when a SKILL.md has steps that could become flaky or when deciding to add a script.
- [Naming Conventions](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/naming-conventions.md) — Rules for naming plugins, skills, directories, and the `name` field so users can discover and recognize skills. Read when creating a new skill, renaming an existing one, or changing a plugin directory.
- [Optional Git Repositories](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/optional-git-repositories.md) — Why analysis skills should treat git as optional and how to detect git state safely. Read when a skill uses any `git` command or assumes a repository, remote, or branch exists.
- [Progressive Disclosure](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md) — The three-level architecture (frontmatter, SKILL.md body, `references/`) and rules for what belongs in each level. Read when deciding where new content goes in a skill, or when a SKILL.md is growing too large.
- [Script Execution Instructions in SKILL.md](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md) — How to describe script invocations as numbered prose instructions, not fenced code blocks, with explicit `${CLAUDE_SKILL_DIR}` paths. Read when a skill calls a shell script from its steps.
- [Security Restrictions](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/security-restrictions.md) — Frontmatter restrictions that prevent prompt injection and silent failures, including no XML angle brackets in YAML. Read when editing any field in a skill's YAML frontmatter.
- [Skill Composition](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/skill-composition.md) — The rule against sub-skill calls (skills invoking other skills via the Skill tool) and what to do instead. Read before reaching for a sub-skill call.
- [Skill Decomposition](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/skill-decomposition.md) — Single-responsibility rules for skills and how to split a skill that has grown to do too much. Read when a skill's description starts to list multiple unrelated outcomes.
- [Skill Description Frontmatter](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-frontmatter.md) — How the `description` field competes for selection across all loaded skills and how to write descriptions that trigger correctly without false positives. Read when writing or revising a `description:` line.
- [Skill Reference Files](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/skill-reference-files.md) — How `references/` files work as the third level of progressive disclosure and what content belongs there versus in SKILL.md. Read when extracting templates, checklists, or domain knowledge out of a SKILL.md.
- [Success Criteria and Testing](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/success-criteria-and-testing.md) — The three test types (triggering, functional, comparative) and how to validate a skill works. Read after building a skill, or when a skill is producing inconsistent results.
- [Troubleshooting](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/troubleshooting.md) — Common symptoms encountered when building or using skills, organized by failure mode, with the likely cause and fix. Read when a skill won't upload, won't trigger, hangs on a permission prompt, or behaves unexpectedly.
- [Use Case Planning](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/use-case-planning.md) — The pre-development step of defining 2-3 concrete use cases before writing a SKILL.md. Read when starting a new skill from scratch.
- [Workflow Patterns](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/workflow-patterns.md) — The four structural patterns that appear across well-built skills and how to compose them within a single SKILL.md. Read when designing or refactoring the step structure of a skill.
- [Writing Effective Instructions](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/writing-effective-instructions.md) — Rules for writing the SKILL.md body so Claude follows the workflow reliably: specificity, recency, structure, action verbs. Read when the SKILL.md body is being authored or when steps are producing inconsistent results.
