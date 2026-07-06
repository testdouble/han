# /guidance

Operator documentation for the `/guidance` skill in the opt-in `han-plugin-builder` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-plugin-builder/skills/guidance/SKILL.md`](../../../han-plugin-builder/skills/guidance/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Concepts](../../concepts.md)

## TL;DR

- **What it does.** Serves the authoritative guidance for building Claude Code skills, agents, and plugins. On request, it also vendors the three plugin-building skills (`guidance`, `skill-builder`, `agent-builder`) into the current repository under a `plugin-` prefix, plus a path-scoped rule index so the guidance surfaces automatically while you edit skill and agent files.
- **When to use it.** When you need the rules or best practices for a skill, agent, hook, or plugin. Or when you want a repository to carry the plugin-building skills locally, so anyone using the repo can run them and get the guidance loaded for the file they are editing.
- **What you get back.** In Guidance Mode, the specific guidance applied to your situation with a citation. In Initialization or Update Mode, the three skills vendored into `.claude/skills/` and a rule index at `.claude/rules/plugin-building-guidance.md`, left staged for you to review.

## Key concepts

- **Three modes, chosen by argument.** `/guidance` with no argument runs **Guidance Mode** (serve the relevant doc). `/guidance init` (or `initialize`) runs **Initialization Mode** (vendor the three skills). `/guidance update` (or `refresh`) runs **Update Mode** (refresh an already-vendored copy).
- **Serve, do not dump.** Guidance Mode reads only the one or two documents that apply to what you are building, then applies them and cites the file. It deliberately does not read every guidance document; that would defeat the progressive-disclosure model the guidance itself teaches.
- **Vendors three runnable skills, under a `plugin-` prefix.** Initialization copies `guidance`, `skill-builder`, and `agent-builder` into `.claude/skills/`, renamed to `plugin-guidance`, `plugin-skill-builder`, and `plugin-agent-builder` so they never collide with this plugin's own slash commands if it is also installed. The repo's users run them as `/plugin-guidance`, `/plugin-skill-builder`, and `/plugin-agent-builder`. The vendored `plugin-guidance` skill is guidance-only (no `init`/`update` modes, since vendoring is a plugin-to-repo operation). Its `references/` directory is the single in-repo copy of the guidance documents, and the two builders are rewritten to point at it.
- **Path-scoped rule index.** Initialization also writes a small index at `.claude/rules/plugin-building-guidance.md` whose `paths:` globs bind it to this repo's skill and agent files. Claude Code loads the index when a matching file is touched. The index points to the vendored guidance documents, so only the guidance the current file needs is loaded, not all of it.
- **No dependency after vendoring.** Once `init` has run, the three skills and their guidance live in the repo. Anyone using the repo can run them and get the right guidance surfaced even if the `han-plugin-builder` plugin is never installed.
- **Standalone and opt-in.** The plugin depends on nothing and is not bundled by the `han` meta-plugin. Install it on its own.

## When to use it

**Invoke when:**

- You are designing, reviewing, hardening, or checking a skill, agent, hook, or plugin against the established rules and want the governing guidance.
- You want a repository to carry the plugin-building skills locally (`/guidance init`) so anyone using the repo can run them and the guidance loads automatically while editing skill and agent files.
- You have updated the `han-plugin-builder` plugin and want a repo's vendored copy refreshed to match (`/guidance update`).

**Do not invoke for:**

- **Building a new skill or agent end-to-end from scratch.** Use [`/skill-builder`](./skill-builder.md) or [`/agent-builder`](./agent-builder.md). Those run the interview, write the artifact, and apply this guidance for you.
- **Writing feature code, reviewing application code, or building non-plugin features.** This skill is about authoring plugin components, not shipping product code.

## How to invoke it

Run `/guidance` in Claude Code, optionally with a mode argument.

The skill ships in the opt-in `han-plugin-builder` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han-plugin-builder@han`. See [Choosing a Han plugin](../../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **In Guidance Mode: what you are building or asking about.** The more specific the topic (a description that won't trigger, a model-tier choice, a plugin.json field), the more precisely the skill can pick the governing document.
2. **In Initialization / Update Mode: a repository root to run in.** The skill writes into `.claude/` at the working directory.

Example prompts:

- `/guidance`. *"How long should an agent description be, and what goes in it versus the body?"*
- `/guidance`. *"Is this better as a skill or an agent?"*
- `/guidance init`. *Vendor the guidance, skill-builder, and agent-builder skills into this repo, plus a path-scoped rule index.*
- `/guidance update`. *Refresh the vendored skills after updating the plugin.*

## What you get back

- **Guidance Mode.** The relevant guidance applied to your situation, with the source document cited (for example `skill-building-guidance/skill-description-frontmatter.md`) so you can read it in full.
- **Initialization Mode.** The three plugin-building skills vendored into `.claude/skills/` as `plugin-guidance`, `plugin-skill-builder`, and `plugin-agent-builder`, plus a path-scoped rule index at `.claude/rules/plugin-building-guidance.md`. The skill reports the vendored skills, the total file count, and the `paths:` globs, and leaves the new files staged for you to review (it does not commit).
- **Update Mode.** The same vendoring operation as initialization, run only after confirming the skills are already installed. It replaces every vendored skill in full (each `SKILL.md` and the guidance documents under `plugin-guidance/references/`, dropping any file the plugin has since removed) and regenerates the rule index, again left staged.

## How to get the most out of it

- **Name your topic, not "show me the guidance."** Guidance Mode is a router: it serves the one or two documents that fit. A specific question gets a specific document; a vague one gets a slower search.
- **Run `init` once per repo, `update` after plugin upgrades.** Initialization is the first install; Update is the refresh. Update checks that both the vendored `.claude/skills/plugin-guidance/` directory and the rule index exist before touching anything, and offers to initialize if they do not.
- **Review the staged files before committing.** Neither `init` nor `update` commits. Inspect the rule index's `paths:` globs to confirm they cover where your repo keeps skills and agents.
- **Reach for the builders when you want the work done, not only the rules.** [`/skill-builder`](./skill-builder.md) and [`/agent-builder`](./agent-builder.md) consult this same guidance during an interview and a review pass; use them when you want a finished artifact rather than a citation.

## Cost and latency

No agents are dispatched. Guidance Mode is a couple of `find`/`Read` calls to locate and read the governing document. Initialization and Update Mode run `scripts/init-guidance.sh` once and report its output. Runs complete in well under a minute. The skill is built for tight-loop use while you author.

## Sources

The guidance documents this skill serves are grounded in named, external practice. Each is cited because the guidance draws specific artifacts from it, not as a reading list.

### Anthropic, Agent Skills best practices

The description-writing rules (third person, capability-first), the SKILL.md body line ceiling, and the test-against-the-target-model guidance trace to Anthropic's skill authoring best practices.

URL: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

### Agent Skills specification

The frontmatter field inventory, the `name`-matches-directory rule, and the portability fields trace to the cross-tool Agent Skills standard.

URL: https://agentskills.io/specification

### Claude Code plugin and subagent documentation

The entity taxonomy, the plugin-agent security boundary, and the `model` field semantics trace to the official Claude Code plugin and subagent references.

URL: https://code.claude.com/docs/en/plugins-reference

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [`/skill-builder`](./skill-builder.md). The interview-driven builder for a new skill; consults this guidance during its review pass.
- [`/agent-builder`](./agent-builder.md). The interview-driven builder for a new agent; consults this guidance during its review pass.
- [Choosing a Han plugin](../../choosing-a-han-plugin.md). Why `han-plugin-builder` is installed separately from the bundled suite.
- [Plugin-building guidance](../../../han-plugin-builder/skills/guidance/references/). The documents this skill serves, readable directly.
