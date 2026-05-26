---
paths:
  - "plugin/agents/**/*.md"
---

# Agent-building guidelines index

You are reading this file because Claude Code loaded it as a path-scoped
rule — you just read or are about to read a file under `plugin/agents/`.

This file is an **index**, not guidance. Each entry below points to a
canonical agent-building guidance document with a short description of
what it covers and when it applies.

Agent-building guidance lives in `docs/guidance/agent-building-guidelines/`
and is exposed to Claude Code through this single index file. The full
text of any individual guidance doc is loaded only when you decide it
applies and use the Read tool to open it. This keeps context lean and
lets you make a relevance decision before paying the token cost.

**Do not read every linked document.** For the specific task you are
doing right now, scan the descriptions and identify only the documents
that are clearly relevant. Then use the Read tool to open just those
files. If no entry is clearly relevant, do not open any of them.

If you are unsure whether a guidance doc applies, do not open it. The
author of the work can prompt you to load a specific doc if needed.
Loading guidance that does not apply burns context and dilutes attention
on the parts that do.

## Available guidance

- [Domain Focus in Agent Definitions](../../docs/guidance/agent-building-guidelines/agent-domain-focus.md) — Why agents perform better with narrow domain vocabulary (the 15-year-practitioner test) and how to write agent descriptions that route to expert-level training data. Read when authoring or revising an agent's description, role, or trigger vocabulary.
- [External File References in Agent Definitions](../../docs/guidance/agent-building-guidelines/agent-external-files.md) — Why agent `.md` files must be entirely self-contained: no `references/` folder, no `scripts/`, no context-injection commands. Read when tempted to extract content from an agent definition into a companion file.
- [Choosing the Right Model for Agent Definitions](../../docs/guidance/agent-building-guidelines/agent-model-selection.md) — How to match the `model:` frontmatter (opus, sonnet, haiku, inherit) to the agent's task complexity. Cost is not a factor — capability is. Read when creating a new agent or when an agent's quality or speed feels mismatched.
- [Graceful Degradation](../../docs/guidance/agent-building-guidelines/graceful-degradation.md) — How agents should detect missing tools (git, CLIs, external APIs) inline, skip dependent steps, and note the limitation in their output. Read when an agent uses any tool that might be absent in the calling skill's environment.
- [Multi-Agent Economics](../../docs/guidance/agent-building-guidelines/multi-agent-economics.md) — The decision framework for when adding agents is justified versus wasteful, including the escalation cascade from single agent up. Read before adding a new `Agent` dispatch to a skill, or when reviewing whether an existing fleet of agents could be collapsed.
