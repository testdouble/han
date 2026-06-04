# Plugin-building guidance index

You are reading this file because Claude Code loaded it as a path-scoped
rule: you just read, or are about to edit, a skill or agent file matching
one of the globs in this file's `paths:` frontmatter.

**This file is an index, not the guidance itself.** Each entry below points
to one guidance document with a short description of what it covers and when
it applies. Do **not** read every linked document. Load only the one or two
documents that are directly relevant to what you are doing right now, read
them, apply them, and stop. Loading guidance you do not need bloats the
context window and dilutes the model's attention on the work that matters.
Treat these documents as load-on-demand reference, not as material to pull
in up front.

All links below are relative to the repository root. The guidance documents
live alongside this rule in `.claude/plugin-building-guidance/`.

## Fundamentals

Read this before adding any new entity to a plugin.

- [Entity Taxonomy: Skills, Agents, Hooks](.claude/plugin-building-guidance/plugin-entity-taxonomy.md) — Defines the three behavioral plugin components: skills (deterministic, flowchartable processes), agents (contextual judgment and taste), and hooks (event-triggered automation), plus the decision heuristic for choosing among them. Read this first when adding a new entity, when you are unsure whether a capability should be a skill or an agent, or when a reviewer questions that choice.

## Skills

Guidance for authoring and hardening `SKILL.md` files and their companion folders.

- [Use Case Planning](.claude/plugin-building-guidance/skill-building-guidance/use-case-planning.md) — The pre-development step of defining 2-3 concrete use cases before writing a SKILL.md, which then become the test cases you run after building. Read at the very start of building a new skill, before drafting any frontmatter or steps.
- [Skill Description Frontmatter](.claude/plugin-building-guidance/skill-building-guidance/skill-description-frontmatter.md) — How to write the `description` field Claude uses to decide when to invoke a skill: the four components, trigger-word breadth, and boundary statements. Read when creating a skill, or when a skill triggers too often, too rarely, or collides with a sibling skill.
- [Skill Description Length](.claude/plugin-building-guidance/skill-building-guidance/skill-description-length.md) — The 1024-character target for skill descriptions and the two platform limits behind it. Read when a description is getting long, or when a skill has quietly stopped triggering as well as it used to.
- [Skill Frontmatter Fields](.claude/plugin-building-guidance/skill-building-guidance/skill-frontmatter-fields.md) — An inventory of every SKILL.md frontmatter field Claude Code supports, with one-line semantics for each. Use as the lookup when you need a field beyond the common `name` / `description` / `allowed-tools` / `paths` set.
- [Progressive Disclosure](.claude/plugin-building-guidance/skill-building-guidance/progressive-disclosure.md) — The three-level information architecture (SKILL.md body, `references/`, `scripts/`) that keeps a skill's context focused on what the current step needs. Read when deciding where a piece of content belongs, or when a SKILL.md is growing too large.
- [Writing Effective Instructions](.claude/plugin-building-guidance/skill-building-guidance/writing-effective-instructions.md) — How to write the SKILL.md body so steps are specific, actionable, and reliably followed across sessions. Read when a skill behaves inconsistently, skips steps, or improvises when it should follow a fixed process.
- [Workflow Patterns](.claude/plugin-building-guidance/skill-building-guidance/workflow-patterns.md) — Four structural patterns for organizing the steps inside a single skill, mapped to Anthropic's effective-agent patterns. Read when designing or restructuring a skill's internal workflow.
- [Context Injection Commands](.claude/plugin-building-guidance/skill-building-guidance/context-injection-commands.md) — The `` !`command` `` syntax that runs a shell command at skill load time and injects its output as runtime context. Read when a skill needs dynamic environment data (dates, git state, branch names) available to its steps.
- [Script Execution Instructions](.claude/plugin-building-guidance/skill-building-guidance/script-execution-instructions.md) — How to describe script invocations in SKILL.md as numbered prose with `${CLAUDE_SKILL_DIR}` paths, rather than fenced code blocks. Read when a skill runs shell scripts during its steps.
- [Hardening: Fuzzy vs. Deterministic](.claude/plugin-building-guidance/skill-building-guidance/hardening-fuzzy-vs-deterministic.md) — The framework for classifying each skill step as fuzzy (keep as an LLM instruction) or deterministic (extract to a script). Read when hardening a skill for reliability or deciding what to script.
- [Skill Reference Files](.claude/plugin-building-guidance/skill-building-guidance/skill-reference-files.md) — When and how to extract domain knowledge (templates, checklists, rate tables) into a `references/` subdirectory loaded on demand. Read when a skill carries content that is knowledge rather than process steps.
- [Context Hygiene](.claude/plugin-building-guidance/skill-building-guidance/context-hygiene.md) — The attention-budget mechanism behind progressive disclosure and conciseness rules: why every irrelevant token degrades the model's attention on the rest. Read when justifying why content should be trimmed or moved out of a SKILL.md.
- [allowed-tools: Bash Permissions](.claude/plugin-building-guidance/skill-building-guidance/allowed-tools-bash-permissions.md) — The `Bash(prefix *)` glob syntax for auto-approving shell commands in `allowed-tools`, and the granularity that avoids both permission stalls and over-broad approvals. Read when adding Bash permissions to a skill.
- [allowed-tools: AskUserQuestion](.claude/plugin-building-guidance/skill-building-guidance/allowed-tools-AskUserQuestion.md) — Why `AskUserQuestion` must never appear in a skill's `allowed-tools`: a permission-evaluator bug silently breaks the interactive prompt. Read before listing tools when a skill asks the user questions.
- [Security Restrictions](.claude/plugin-building-guidance/skill-building-guidance/security-restrictions.md) — Frontmatter safety rules (no XML angle brackets, etc.) that prevent injection into the system prompt where skill frontmatter lands. Read when authoring or reviewing any skill frontmatter.
- [Dynamic Project Discovery](.claude/plugin-building-guidance/skill-building-guidance/dynamic-project-discovery.md) — Rules for discovering project structure, the default branch, and tool availability at runtime instead of hardcoding them. Read when a skill must work across arbitrary repositories.
- [Optional Git Repositories](.claude/plugin-building-guidance/skill-building-guidance/optional-git-repositories.md) — Why code-analysis skills should treat git as optional, and the legitimate scenarios that break when git is hard-required. Read when a skill assumes a git repo or a default branch exists.
- [Graceful Degradation (skills)](.claude/plugin-building-guidance/skill-building-guidance/graceful-degradation.md) — How a skill should detect partial context (missing git history, config, or docs) and branch to a named degraded mode that still produces useful output. Read when a skill depends on data that may be absent.
- [Skill Composition](.claude/plugin-building-guidance/skill-building-guidance/skill-composition.md) — Why skills must not call other skills via the Skill tool, and what to do instead. Read when you are tempted to chain skills together.
- [Skill Decomposition](.claude/plugin-building-guidance/skill-building-guidance/skill-decomposition.md) — The single-responsibility rule for skills and how to split a monolithic skill or extract a reusable agent. Read when a skill handles more than one concern or has become hard to follow.
- [Agent Dispatch Namespacing](.claude/plugin-building-guidance/skill-building-guidance/agent-dispatch-namespacing.md) — The rule that a skill must dispatch a sub-agent by the namespace of the plugin that defines it (for example `han.core:agent-name`), never a bare name or the meta-plugin prefix. Read when a skill dispatches agents.
- [Naming Conventions](.claude/plugin-building-guidance/skill-building-guidance/naming-conventions.md) — Naming rules across plugins, skills, and directories, including that the plugin directory must match the `name` in plugin.json and that skill directories must not carry README files. Read when creating or renaming any plugin entity.
- [Success Criteria and Testing](.claude/plugin-building-guidance/skill-building-guidance/success-criteria-and-testing.md) — Three test types (triggering, functional, outcome) for knowing a skill works, plus the rule to test on the model tier the skill targets. Read when validating a skill before shipping it.
- [Documentation Maintenance](.claude/plugin-building-guidance/skill-building-guidance/documentation-maintenance.md) — Why stale SKILL.md or reference content is active poison the model follows faithfully, and how to audit a skill so its docs match reality. Read when changing a skill's behavior or auditing existing skills.
- [Troubleshooting](.claude/plugin-building-guidance/skill-building-guidance/troubleshooting.md) — Common skill-building problems organized by symptom, each with its likely cause and a concrete fix. Read when a skill won't upload, won't trigger, or misbehaves and you want the known-issue catalog.
- [Cowork-Specific Skill Instructions](.claude/plugin-building-guidance/skill-building-guidance/cowork-specific-skill-instructions.md) — Reference for Claude Cowork (Anthropic's agentic system for knowledge workers) and how its environment affects skill authoring. Read only when a skill must work inside Cowork.

## Agents

Guidance for authoring agent `.md` definitions. Agents are self-contained and carry their own model selection.

- [Domain Focus in Agent Definitions](.claude/plugin-building-guidance/agent-building-guidelines/agent-domain-focus.md) — Why agents perform better when targeted at a narrow domain with precise practitioner vocabulary (the 15-year-practitioner test for vocabulary routing). Read when writing or sharpening an agent's persona.
- [External File References in Agent Definitions](.claude/plugin-building-guidance/agent-building-guidelines/agent-external-files.md) — The rule that agent `.md` files must be fully self-contained: no `references/` or `scripts/` folders and no context-injection commands, unlike skills. Read before structuring any agent definition.
- [Choosing the Right Model for Agent Definitions](.claude/plugin-building-guidance/agent-building-guidelines/agent-model-selection.md) — How to choose the `model` frontmatter value (opus / sonnet / haiku) by matching capability to the task, with cost explicitly not a factor. Read when setting or revisiting an agent's model.
- [Multi-Agent Economics](.claude/plugin-building-guidance/agent-building-guidelines/multi-agent-economics.md) — The escalation cascade for deciding whether adding more agents is justified, given that each agent multiplies latency and token cost. Read when a skill is considering dispatching multiple or parallel agents.
- [Graceful Degradation (agents)](.claude/plugin-building-guidance/agent-building-guidelines/graceful-degradation.md) — How a dispatched agent should check tool availability inline and skip gracefully, so the orchestrating skill needs no defensive guards around the dispatch. Read when an agent's steps depend on git or other tools that may be missing.

## Plugin configuration files

Schema references for the JSON manifests that define a plugin and its marketplace.

- [plugin.json Schema Reference](.claude/plugin-building-guidance/claude-marketplace-and-plugin-configuration/plugin-json-options.md) — Full schema for `.claude-plugin/plugin.json`: required fields, metadata, component paths, dependencies, and experimental keys. Read when creating or editing a plugin manifest.
- [marketplace.json Schema Reference](.claude/plugin-building-guidance/claude-marketplace-and-plugin-configuration/marketplace-json-options.md) — Schema for `.claude-plugin/marketplace.json`, the registry Claude Code reads to discover and install plugins. Read when adding a plugin to a marketplace or editing the manifest.
- [monitors.json Schema Reference](.claude/plugin-building-guidance/claude-marketplace-and-plugin-configuration/monitors-json-options.md) — Schema for the experimental monitors configuration (persistent background processes that deliver notifications). Read only when building monitor components.
- [themes.json Schema Reference](.claude/plugin-building-guidance/claude-marketplace-and-plugin-configuration/themes-json-options.md) — Schema for experimental plugin theme files. Read only when shipping a theme with a plugin.

## Plugin development

Process guidance for building and evolving a plugin over its lifetime.

- [Iterative Plugin Development](.claude/plugin-building-guidance/iterative-plugin-development.md) — The iterative process (plan for 3-5 passes, challenge the prior pass's assumptions each round) for evolving skills and agents that rarely work on the first draft. Read when developing or substantially revising any entity.
- [Specialization and Model Selection](.claude/plugin-building-guidance/specialization-and-model-selection.md) — The research-backed rationale for why tighter specialization lets a smaller model at lower effort match a larger one on narrow tasks, without raising the capability ceiling. Read when reasoning about the specialization-versus-model-tier trade-off across skills and agents.

## Templates and examples

Copyable starting points for new plugin files. These are scaffolding, not guidance to read end to end.

- [Plugin README template](.claude/plugin-building-guidance/templates/plugin-readme-template.md) — Starter structure for a plugin's root README. Copy when creating a new plugin's README.
- [plugin.json example](.claude/plugin-building-guidance/templates/plugin-example.json) — Worked example manifest. Copy when scaffolding a plugin.json.
- [marketplace.json example](.claude/plugin-building-guidance/templates/marketplace-example.json) — Worked example marketplace manifest. Copy when scaffolding a marketplace.json.
- [monitors.json example](.claude/plugin-building-guidance/templates/monitors-example.json) — Worked example monitors configuration. Copy when scaffolding a monitors.json.
- [themes.json example](.claude/plugin-building-guidance/templates/themes-example.json) — Worked example theme file. Copy when scaffolding a themes.json.
