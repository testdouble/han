# Project-Local Configuration

A project that uses Han can carry one optional file, `.han/config.md`, to adjust how Han skills behave in that project.
The file controls two things: where skills write their markdown deliverables, and which extra agents dispatching skills
consider. Every Han skill reads the file on every run, so the overrides take effect without depending on the model
remembering to look. A project without the file sees no change of any kind.

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [Quickstart](./quickstart.md) ·
> [All skills](./skills/README.md) · [All agents](./agents/README.md)

## TL;DR

- **You write the file; Han cannot.** Han cannot ship or seed a project-level config from the plugin side. You create
  `.han/config.md` by hand in a `.han/` folder at your project root, and it travels through version control like any
  other file. The annotated example below is the canonical source to author from.
- **Two overrides ship.** `output-directory` sets one base directory for every skill's markdown deliverables.
  `## Extra Agents` names project-defined or third-party agents that Han's dispatching skills consider alongside their
  built-in rosters.
- **A bad config can never fail a skill run.** The worst it can do is be ignored, with a one-line note naming what was
  ignored. A missing or empty file changes nothing and says nothing.
- **The interpretation contract lives in
  [`han-core/references/config-rule.md`](../han-core/references/config-rule.md).** Every skill applies that one rule
  file (vendored byte-identical into each plugin), so one config file resolves identically across the whole suite.
  This page is the operator-facing guide.

## The file, annotated

Create `.han/config.md` in the directory you run Han skills from. This is the one canonical example; both settings are
optional, and everything unrecognized is ignored.

```markdown
---
# Base directory for Han's markdown deliverables, relative to this project's
# root. Each skill keeps its own folder and file structure beneath it, and
# creates the directory on first write. Must stay inside the project: absolute
# paths and paths escaping upward are refused.
output-directory: docs/han
---

## Extra Agents

One agent per line. Qualified `plugin:agent` form or bare name, matched
case-insensitively against the agents available in the session.

- my-plugin:payments-domain-expert
- accessibility-reviewer
```

## What each override does

### `output-directory`

Skills that write markdown deliverables (plans, reports, documentation) write them under this base directory instead of
their default locations, keeping their own folder structure beneath it. A skill that writes nothing ignores the setting
silently. The value must be a relative path that stays inside the project; an absolute path or a `..` escape is
refused with a one-line note, and the skill falls back to its default location.

### `## Extra Agents`

Skills that select among candidate agents (for example [`/code-review`](../han-coding/docs/skills/code-review.md),
[`/research`](../han-research/docs/skills/research.md), or
[`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md)) add these agents to their candidate pool.
The extras compete under the same signal-based selection and the same size caps as the skill's own roster — a selected
extra agent can take a slot a default specialist would otherwise have filled, and that displacement is intended. An
entry that duplicates an agent already in the pool has no effect. An entry that does not resolve to a dispatchable
agent (a misspelling, a skill name) is skipped with a one-line note. The override selects among agents that already
exist in the session; it does not define new agents.

## Precedence

Each single-value setting resolves through a fixed chain; the first source that supplies a value wins:

1. Explicit input — what you tell the skill directly, or an explicit path a wrapper skill passes.
2. `.han/config.md`.
3. The CLAUDE.md `## Project Discovery` section.
4. The project-discovery file.
5. The skill's built-in defaults.

So the config file beats CLAUDE.md, silently. The extra-agents list adds rather than replaces: agents you name
explicitly are always considered, and the config's entries join them as candidates.

## Where the file is discovered

Skills look for `.han/config.md` only in the directory they run from — the same place they already look for CLAUDE.md
and the project-discovery file. In a monorepo, each package can carry its own config; running a skill from a directory
without one behaves as if the file were absent, even when another directory in the repo has one.

## When something is wrong

A configuration problem degrades to defaults; it never blocks or fails the run. You hear about a problem under one
rule: a one-line note appears only when content that attempts a recognized override cannot be used — malformed
frontmatter, an unrecognized setting name, a blank value, an out-of-bounds `output-directory`, or an unresolvable agent
name. Content the suite has no use for (plain prose in the file) is passed over silently, and when everything applies
cleanly the skills say nothing about the config at all.

## Keeping the file visible

Because the config silently outranks CLAUDE.md, [`/project-discovery`](../han-core/docs/skills/project-discovery.md)
keeps it visible: when `.han/config.md` exists it offers to add a one-line pointer to it in your CLAUDE.md, and when
the file is gone but a pointer remains it offers to remove the stale line. Both only with your consent.

Keep the file small. Its whole content is read on every skill run, so everything in it costs context on every run.

## Related reading

- [`han-core/references/config-rule.md`](../han-core/references/config-rule.md). The canonical interpretation contract
  every skill applies.
- [Concepts](./concepts.md). How skills, agents, sizing, and the other cross-suite mechanics fit together.
- [Quickstart](./quickstart.md). Which skill to start with, including project setup in Path D.
- [`/project-discovery`](../han-core/docs/skills/project-discovery.md). The skill that keeps the CLAUDE.md pointer to
  this file honest.
