# codebase-explorer

Operator documentation for the `codebase-explorer` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han-core/agents/codebase-explorer.md`](../../../han-core/agents/codebase-explorer.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md)

## TL;DR

- **What it does.** Thoroughly discovers implementation details for a specific feature or system: entry points, core logic, data models, configuration, tests, and feature-type-specific artifacts.
- **When to dispatch it.** A feature, subsystem, or capability needs structured codebase discovery. Often dispatched two or three in parallel from a different angle each. Always dispatched by `/project-documentation`. Dispatched by `/coding-standard` for pattern discovery and by `/architectural-decision-record` for context gathering. Also dispatched by `/research` on codebase-bearing questions. Dispatched by `/architectural-analysis` for a large or unfamiliar focus area. Dispatched by `/code-overview` to discover entry points, context, uses, and flow for an understand-now overview. Dispatched by `/gap-analysis` to map an unfamiliar current state. Dispatched by `/iterative-plan-review` for unfamiliar code regions.
- **What you get back.** Numbered `D#` discovery items, each with category (Entry point / Core logic / Data model / Config / Test / Docs / Feature-specific), a file path with line number, a brief verbatim snippet of key definitions, and connections to other files.

## Key concepts

- **Adapt the search.** Single-pattern glob runs are anti-pattern. The agent tries multiple patterns, follows imports, and reads files to build a connected picture rather than a flat list.
- **Feature-type-specific checklists.** API services, event-driven systems, data layers, UI features, external integrations, and infrastructure each have their own extra checklist beyond the universal one (entry points, core logic, data model, config, tests, docs).
- **Connections, not islands.** Every discovery item names which other files it connects to (imports, callers, dependents). The result is a graph, not a directory listing.
- **Negative results count.** When a pattern was tried and found nothing, the agent reports that. Often more useful than a positive result, because it tells you what the codebase does not have.
- **Discovers, does not document.** The agent's output is the raw material for `/project-documentation` or `/coding-standard`. It does not write the doc itself.

## When to use it

**Dispatch when:**

- `/project-documentation` is running. The skill always dispatches two or three of these agents in parallel from different angles.
- `/coding-standard` is gathering evidence for the standard. The skill dispatches two of these in parallel: one for implementation patterns, one for existing standards and ADRs.
- `/architectural-decision-record` is creating a new ADR with sparse context. The skill dispatches one or two of these to gather supporting evidence.
- `/research` is answering a codebase-bearing question and needs structured discovery of the relevant implementation.
- `/architectural-analysis` is analyzing a large or unfamiliar focus area and needs a discovery pass before the structural analysts run.
- `/code-overview` is building an understand-now overview of unfamiliar code or a PR's changes. The skill dispatches one to five of these, scaled to size, to discover entry points, context, uses, and flow.
- `/gap-analysis` is mapping an unfamiliar current state before comparing it against the desired state.
- `/iterative-plan-review` is reviewing a plan that touches unfamiliar code regions and needs them discovered first.
- You want a structured discovery pass on a feature before writing or refactoring it.

**Do not dispatch for:**

- Bug investigation. Use `evidence-based-investigator`, which is focused on symptoms-to-cause tracing.
- Architectural analysis (coupling, behavior, concurrency). Use the architectural analysts.
- Stack and tooling detection. Use `project-scanner`.
- Writing documentation. The agent discovers; `/project-documentation` writes.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:codebase-explorer`. Give it:

1. **Feature name.** What you're exploring.
2. **Feature type.** API, event-driven, data layer, UI, integration, infrastructure, or cross-cutting.
3. **Layers.** Backend, frontend, both, or infrastructure.
4. **Focus area.** Your specific angle (*"entry points and core logic"*, *"data models and schemas"*, *"existing tests and patterns"*). This is how multiple explorers in parallel avoid stepping on each other.
5. **Known file paths, optional.** Starting points if you have them.

Example prompts:

- *"Explore the auth system. Feature type: cross-cutting. Layers: both. Focus area: entry points and core logic. Known starting points: `src/auth/middleware.ts`."*
- *"Discover the notification feature. Feature type: event-driven. Focus area: publishers, subscribers, and message-queue configuration."*

## What you get back

- Numbered `D#` discovery items, each with: category, file path with line number, a brief verbatim snippet for key definitions, and a `Connections` field listing related files.
- An **Exploration Summary** with total files discovered, areas well-covered vs. areas where searches found nothing, and suggested follow-up searches.

## How to get the most out of it

- **Dispatch multiple in parallel.** Different focus areas surface different parts of the codebase. `/project-documentation` runs two or three at once.
- **Name the focus area precisely.** Two parallel agents with the same focus area do duplicate work. Split by angle: one for entry points, one for data, one for tests.
- **Provide starting points.** Even one known file path massively accelerates the search.
- **Read the negative results.** *"Tried `**/*notification*`, `**/*alert*`, and `**/*email*` patterns, found no event subscribers"* is real signal. It usually means the feature uses unfamiliar naming.

## Cost and latency

The agent runs on `haiku` (cheap, fast). A focused exploration runs in under a minute. Cost scales with the number of parallel dispatches.

## Sources

The agent's exploration discipline is grounded in practical codebase-archaeology technique.

### Michael Feathers: Working Effectively with Legacy Code

Feathers's framing of seams and characterization tests informs the agent's bias toward following imports and reading code rather than guessing from filenames.

URL: https://www.oreilly.com/library/view/working-effectively-with/0131177052/

### Adam Tornhill: Software Design X-Rays

Tornhill's work on hotspot analysis and software-design archaeology underpins the agent's use of git history and module-connection tracing.

URL: https://pragprog.com/titles/atevol/software-design-x-rays/

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [Agents Index](../README.md). All agents, grouped by role.
- [`evidence-based-investigator`](./evidence-based-investigator.md). Sibling for bug-focused investigation.
- [`project-scanner`](./project-scanner.md). Sibling for stack and tooling detection.
- [`/project-documentation`](../../skills/han-core/project-documentation.md). Always dispatches this agent.
- [`/coding-standard`](../../skills/han-coding/coding-standard.md). Dispatches this agent for pattern discovery.
- [`/architectural-decision-record`](../../skills/han-core/architectural-decision-record.md). Dispatches this agent in create-new mode.
- [`/research`](../../skills/han-core/research.md). Dispatches this agent on codebase-bearing questions.
- [`/architectural-analysis`](../../skills/han-coding/architectural-analysis.md). Dispatches this agent for a large or unfamiliar focus area.
- [`/code-overview`](../../skills/han-coding/code-overview.md). Dispatches this agent, scaled to size, to discover entry points, context, uses, and flow for an understand-now overview.
- [`/gap-analysis`](../../skills/han-core/gap-analysis.md). Dispatches this agent to map an unfamiliar current state.
- [`/iterative-plan-review`](../../skills/han-planning/iterative-plan-review.md). Dispatches this agent for unfamiliar code regions.
