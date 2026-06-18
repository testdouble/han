# /code-overview

Operator documentation for the `/code-overview` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-coding/skills/code-overview/SKILL.md`](../../../han-coding/skills/code-overview/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Sizing](../../sizing.md)

## TL;DR

- **What it does.** Produces a human-readable, progressive-disclosure overview of unfamiliar code (as it is now) or of a pull request's changes (what they do and why), so you can get up to speed before working on or reviewing it.
- **When to use it.** You have landed in code you do not know, or a PR you are about to review, and you want a fast orientation before you start.
- **What you get back.** A scratch overview file (written outside the repository) with a purpose statement, Mermaid flow charts, the directly-related context, and where to start — at minimal technical depth.
- **Size-aware.** The skill classifies the target as small / medium / large, defaults to small, and scales how many `codebase-explorer` agents it dispatches. Pass the size as the first positional argument to override (`/code-overview medium`). See [Sizing](../../sizing.md).

## Key concepts

- **Two modes.** *Code mode* explains a file, directory, or symbol as it is now. *PR mode* explains a set of changes — what they do, grouped by intent, and how to look at the PR before reviewing it. The skill picks the mode from the target.
- **Understand now, not document for later.** The overview is an ephemeral orientation aid written to a scratch file, never committed into the repository's documentation tree. That is the line against `/project-documentation`.
- **No findings.** The overview raises no quality findings, severities, or recommended changes — even the PR-mode "what to watch" section is navigational, naming where the change is hardest to follow, not whether it is any good. That is the line against `/code-review`.
- **Progressive disclosure.** The most important understanding comes first (what it is and why), then the flow chart, then context, then where to start. A reader who stops early still knows what the target is.
- **Minimal technical detail, scoped per section.** Purpose, flow, and context stay high-level; the where-to-start section is the exception and names concrete entry points so you can actually open the right file.

## When to use it

**Invoke when:**

- You have been handed code you have never seen and need to work on it.
- You are about to review a PR and want to understand what it does and why before you start reading line by line.
- You are ramping onto an unfamiliar module, directory, or symbol and want a map before you dive in.

**Do not invoke for:**

- **Reviewing code quality or finding problems.** Use [`/code-review`](./code-review.md) instead (or [`/post-code-review-to-pr`](../han-github/post-code-review-to-pr.md) to post a review to GitHub).
- **Writing durable feature or system documentation.** Use [`/project-documentation`](../han-core/project-documentation.md) instead.
- **Assessing architecture, coupling, or structural risk.** Use [`/architectural-analysis`](./architectural-analysis.md) instead.
- **Diagnosing a bug or root-causing a failure.** Use [`/investigate`](./investigate.md) instead.

## How to invoke it

Run `/code-overview` in Claude Code.

Give it:

1. **A target (optional).** A file path, a directory, a symbol name, or a pull request reference / URL. With no target, the skill defaults to the current branch's changes in PR mode. A sharp target is a single file, symbol, directory, or PR; a thin one ("explain the backend") forces the skill to ask you to narrow it.
2. **A size (optional).** `small`, `medium`, or `large` as the first positional argument, when you want to override the skill's auto-classification.

Example prompts:

- `/code-overview`. *"Explain what the changes on this branch do before I review them."*
- `/code-overview src/auth/`. *"Help me understand the auth module before I work on it."*
- `/code-overview #82`. *"Walk me through pull request 82 so I know how to review it."*
- `/code-overview large src/billing/`. *"Give me a thorough overview of the billing subsystem."*

## What you get back

A single Markdown overview file written to a scratch location **outside the repository** (for example under your system temp directory). The skill shows you the path; open it where the Mermaid charts render. The file is not committed and is not maintained — it is a point-in-time orientation aid.

The document follows one structure per mode, under a shared grammar. It opens with a title and a short intro paragraph naming what is being examined (not a metadata block), then:

- **Code mode:** *What it does and why* → *Main flow* (a Mermaid chart with a scope label) → *Context and uses* → *Where to start*.
- **PR mode:** *What this change does and why* → *Changes by intent* (grouped by the outcome each group delivers) → *How the change flows* (a Mermaid chart with a scope label) → *What to watch when reviewing* (navigational only).

In PR mode, when the pull request has screenshots, the overview embeds them inline next to the text they illustrate, so you do not have to switch back to the PR to see them.

Before you see it, the draft passes a readability pass: `information-architect` and `junior-developer` review the document for progressive disclosure and clarity, and the skill rewrites it from their recommendations. They review the document, not the code — the overview still raises no findings about the work itself.

When the target is too large to cover fully at the chosen size, the overview adds a coverage note immediately after the header, naming what it did not cover and the next size up, so you know the picture is partial before you study the charts.

## How to get the most out of it

- **Name a sharp target.** A file, a symbol, a directory, or a specific PR gets a focused overview. "The whole app" does not — the skill will ask you to narrow it.
- **Let the default carry the PR case.** With no argument on a feature branch, the skill orients you to exactly the changes you are about to review. You rarely need to name the PR explicitly.
- **Re-run larger when coverage is partial.** If the overview adds a coverage note, re-run at the next size up for a fuller picture rather than guessing at the gaps.
- **Read it before `/code-review`, not instead of it.** The overview tells you how to look at a PR; the review tells you whether the PR is any good. Run code-overview first to orient, then `/code-review` to judge.

## Sizing

The skill is one of the size-aware skills. It classifies the target and scales the exploration roster:

| Size | Typical target | Explorers dispatched |
|---|---|---|
| **Small** *(default)* | A single file, a single symbol, or a small change set | 1 |
| **Medium** | A directory or module, or a moderate change set across one or two subsystems | 2–3 |
| **Large** | Multiple subsystems, or a large change set | 3–5 |

Classification defaults to small and escalates only on a clear signal; a borderline target stays at the smaller band. Pass `small`, `medium`, or `large` as the first positional argument to override. The roster is intentionally lean — `codebase-explorer` agents only — because this is read-only orientation, not the multi-specialist audit that `/code-review` and `/architectural-analysis` run. See [Sizing](../../sizing.md) for the cross-skill model.

## Cost and latency

The skill runs on the default model tier and dispatches a lean roster: one to five `han-core:codebase-explorer` agents in parallel, scaled to size, then a synthesis pass the skill performs itself, then a two-agent readability pass (`information-architect` and `junior-developer`, in parallel) whose recommendations the skill applies. The most expensive single step is the parallel exploration wave at large size. It is built for quick, on-demand orientation, so it is cheap at small size and safe to run often; it is read-only and re-runnable, so there is no approval gate before it works.

## In more detail

The skill orchestrates and synthesizes; the agents only discover. It resolves the target by a fixed precedence — an explicit pull request reference first, then a file or directory path, then a symbol, and finally (with no target) the current branch's changes — so an ambiguous string never silently selects the wrong mode. It classifies size, dispatches `codebase-explorer` agents over the target or the changed files, and then writes the overview itself: the grouping, the charts, and the orientation are the skill's work, not pasted agent output.

PR mode runs on the local branch diff and does not require a remote pull request; a remote PR is needed only when you name one explicitly. The skill degrades gracefully when its tools are missing: code mode against a named target still runs without git, while PR mode and the bare-invocation default tell you they need git to read changes. When a named pull request cannot be reached, the skill offers code mode against a local target instead.

## Sources

The skill's posture is grounded in established practice for progressive disclosure, information scent, and program comprehension. Each source below is cited because the skill draws a specific, named artifact from it.

### Jakob Nielsen: Progressive Disclosure

Nielsen's work on progressive disclosure (Nielsen Norman Group) is the structural principle behind the overview's section order: show the single most important thing first, then let detail unfold beneath it, so a reader who stops early is still oriented correctly. The skill's "what it does and why → flow → context → where to start" ordering is this principle applied to code.

URL: https://www.nngroup.com/articles/progressive-disclosure/

### Peter Pirolli and Stuart Card: Information Foraging Theory

Pirolli and Card's information-foraging work formalized "information scent" — the cues a reader follows to decide where to look next. The skill's content-bearing section headings, the chart scope labels, and the partial-coverage note exist so a reader can forage the overview efficiently and know when the picture is incomplete.

URL: https://www.researchgate.net/publication/200085665_Information_Foraging

### Spinellis and others: Program Comprehension

The program-comprehension literature establishes that developers understand unfamiliar code by building a mental model from entry points, control flow, and call relationships before reading detail. The skill's flow charts and its "where to start" section target exactly that model-building path, at minimal technical depth.

URL: https://www.spinellis.gr/codereading/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/code-review`](./code-review.md). The judgment counterpart: run code-overview to understand a PR, then code-review to evaluate it.
- [`/project-documentation`](../han-core/project-documentation.md). The durable counterpart: code-overview is ephemeral orientation, project-documentation is maintained docs in the repo tree.
- [`/architectural-analysis`](./architectural-analysis.md). Reach for this when you need a structural, coupling, and risk assessment rather than an orientation.
- [`/investigate`](./investigate.md). Reach for this when something is broken and you need a root cause, not an overview.
- [Sizing](../../sizing.md). The cross-skill sizing model. Explains the small / medium / large bands, the default-to-small rule, and the `$size` override.
- [`codebase-explorer`](../../agents/han-core/codebase-explorer.md). The agent this skill dispatches, scaled to size, to discover entry points, context, uses, and flow.
- [`information-architect`](../../agents/han-core/information-architect.md), [`junior-developer`](../../agents/han-core/junior-developer.md). The two agents that review the drafted overview for progressive disclosure and readability before you see it.
- [`SKILL.md` for /code-overview](../../../han-coding/skills/code-overview/SKILL.md). The internal process definition.
