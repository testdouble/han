# /ddd-analysis

Operator documentation for the `/ddd-analysis` skill in the han-ddd plugin. This document helps you decide _when_
and _how_ to use the skill. For what the skill does internally, read the skill definition at
[`han-ddd/skills/ddd-analysis/SKILL.md`](../../skills/ddd-analysis/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md)

## TL;DR

- **What it does.** Reads a codebase through a DDD lens and produces an evidence-backed domain and context map that
  distinguishes strongly expressed boundaries from latent ones, speculative hypotheses, and contested ownerships.
- **When to use it.** When you want to understand where domain boundaries sit in an existing codebase before deciding
  what to change.
- **What you get back.** A structured domain map in your conversation, organized into five evidence tiers: strongly
  expressed bounded contexts, latent bounded contexts, speculative hypotheses, boundary leaks, and unanswered domain
  questions.

## Key concepts

- **Bounded context.** A part of the codebase where a particular domain model applies and its vocabulary is
  consistent. The skill discovers candidates from code evidence; it does not create bounded contexts.
- **Evidence tier.** Every bounded context candidate is classified at one of four confidence levels — strongly
  expressed, latent, speculative, or contested — based on what the code actually shows, not on what a good design
  would imply.
- **Discovery, not prescription.** The skill tells you what the domain shape is. It does not recommend how to
  change it. Service splits, migrations, and refactors belong to the steps that follow.
- **Whole-repository scope.** The skill can analyze an entire codebase, not just a named module. This is the
  primary entry point for a DDD orientation pass on an unfamiliar system.

## When to use it

**Invoke when:**

- You want to understand the domain structure of a codebase before a major architectural decision.
- The team suspects certain boundaries exist but has never mapped them explicitly.
- You are onboarding onto a new system and want to understand its domain shape before reading the code in detail.
- A previous architectural conversation mentioned "bounded contexts" or "DDD" and you want to know what the code
  actually says.
- You want to find boundary leaks — domain concepts that cross what should be context seams.

**Do not invoke for:**

- **Code-level quality review.** Use [`/code-review`](../../../han-coding/docs/skills/code-review.md) instead.
- **Module coupling, SOLID alignment, or dependency analysis.** Use
  [`/architectural-analysis`](../../../han-coding/docs/skills/architectural-analysis.md) instead.
- **Designing a new context boundary or service split.** Use
  [`/plan-a-feature`](../../../han-planning/docs/skills/plan-a-feature.md) to specify the change after the domain
  map identifies the boundary.
- **Investigating a specific bug or failure.** Use [`/investigate`](../../../han-coding/docs/skills/investigate.md)
  instead.

## How to invoke it

Run `/ddd-analysis` in Claude Code. No arguments are required.

Give it:

1. **A size (optional, default: medium).** Pass `small`, `medium`, or `large` as the first word to control analysis
   depth. Small does a naming and structure scan only. Medium runs all seven evidence dimensions. Large runs all
   dimensions with an explicit emphasis on git history and team signals, and returns the full candidate set.
2. **A focus area (optional, default: entire repository).** Name a module, directory, or feature area to restrict
   the analysis. When you omit it, the skill analyzes the full repository.
3. **A driving concern (optional).** Tell the skill what you suspect or want to understand. It biases the
   bounded-context-analyst's attention without narrowing its scope.

Example invocations:

- `/ddd-analysis` — _"Analyze the whole repository and produce a domain map."_
- `/ddd-analysis large` — _"Comprehensive domain map with git history and team signals."_
- `/ddd-analysis src/billing` — _"Focus on the billing module — I think it spans two domain concerns."_
- `/ddd-analysis medium` — _"I think our auth and identity contexts overlap. Map the whole repo at standard depth."_

## What you get back

A domain map report in your conversation with five named sections:

- **Strongly Expressed Bounded Contexts (SE#).** Contexts where the technical structure already confirms the domain
  boundary. Each entry names the context, its core domain concepts, and its integration signals.
- **Latent Bounded Contexts (LT#).** Domain concerns present in the vocabulary but without aligned technical
  boundaries. Each entry names what is missing and what technical change would make it strongly expressed.
- **Speculative Context Hypotheses (SP#).** Hypotheses that need a domain expert to confirm or refute. Each entry
  frames the hypothesis and the exact question a domain expert would need to answer.
- **Boundary Leaks and Contested Ownership (BL#).** Domain concepts or data entities that cross or span what should
  be context seams. Each entry names the contexts involved and the contested concept.
- **Unanswered Domain Questions (DQ#).** Questions the code cannot answer. Each entry states the question and which
  map items depend on the answer.

The report also carries a plain-text domain map sketch, the full BC# discovery findings from the
`bounded-context-analyst`, and an appendix with the analysis scope and evidence gaps.

## How to get the most out of it

- **Read the DQ# items first.** They are the questions the team needs a domain expert to answer before the map can
  stabilize. Block out time with the right people before deciding what to act on.
- **Treat SE# items as the anchor.** Strongly expressed contexts are the parts of the system that already have
  working boundary alignment. Build on them rather than reorganizing them.
- **LT# items are not action items.** A latent bounded context tells you the domain concern exists; it does not tell
  you to create a new service. The decision about whether to align the structure belongs to the team.
- **Pass a driving concern.** The more specific your hypothesis ("I think order fulfillment and order billing share
  too many entities"), the more precisely the bounded-context-analyst will investigate the signals you care about.
- **Pair with `/architectural-analysis` next.** After the domain map identifies a specific module you want to
  understand at the code level, run `/architectural-analysis` on that module to get coupling, SOLID, and structural
  findings that inform a refactor or boundary alignment decision.
- **Use `large` on long-lived monoliths.** A large codebase with years of team history benefits from git-signal
  analysis: which modules always change together, which author clusters correspond to domain clusters.

## Cost and latency

Two agents run sequentially: `han-ddd:bounded-context-analyst` (Sonnet) followed by
`han-ddd:domain-map-synthesizer` (Opus). The `han-communication:readability-editor` agent (Sonnet) runs after
synthesis. The bounded-context-analyst is the most time-intensive step on large repositories, because it reads
across the full scope.

Typical wall-clock time by depth:

- **Small:** bounded-context-analyst reads primarily directory structure and naming. Faster, shallower.
- **Medium:** all seven evidence dimensions. Standard.
- **Large:** all seven dimensions with git history queries. Slowest; recommended for comprehensive pre-decision maps.

## Sources

The skill's vocabulary and classification approach are grounded in Eric Evans's Domain-Driven Design and the
follow-on strategic-patterns literature.

### Evans, Eric. _Domain-Driven Design: Tackling Complexity in the Heart of Software._ Addison-Wesley, 2003.

The foundational source for bounded contexts, ubiquitous language, context maps, and the strategic patterns (shared
kernel, anti-corruption layer, open host service, published language, customer-supplier, conformist, separate ways).
URL: (book; no public URL)

### Vernon, Vaughn. _Implementing Domain-Driven Design._ Addison-Wesley, 2013.

Expands the strategic patterns with worked examples of context mapping, aggregate design, and the four integration
relationship types. The bounded-context-analyst's classification tiers are influenced by Vernon's treatment of
context-map discovery.
URL: (book; no public URL)

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`bounded-context-analyst`](../agents/bounded-context-analyst.md). The discovery agent this skill dispatches.
- [`domain-map-synthesizer`](../agents/domain-map-synthesizer.md). The synthesis agent this skill dispatches.
- [`/architectural-analysis`](../../../han-coding/docs/skills/architectural-analysis.md). The right next step when
  you want code-level coupling and SOLID findings for a module the domain map identified.
- [`/plan-a-feature`](../../../han-planning/docs/skills/plan-a-feature.md). The right next step when the domain map
  identifies a boundary you want to align or introduce.
