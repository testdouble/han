# /ddd-analysis

Operator documentation for the `/ddd-analysis` skill in the han-ddd plugin. This document helps you decide _when_
and _how_ to use the skill. For what the skill does internally, read the skill definition at
[`han-ddd/skills/ddd-analysis/SKILL.md`](../../skills/ddd-analysis/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md)

## TL;DR

- **What it does.** Reads a codebase through a DDD lens and produces an evidence-backed domain and context map
  distinguishing current bounded contexts from latent ones and speculative hypotheses, with a critic pass to
  evaluate each proposed context against the discovery evidence.
- **When to use it.** When you want to understand where domain boundaries sit in an existing codebase before
  deciding what to change.
- **What you get back.** A structured domain and context map report organized by context confidence tier, with
  boundary problems, a context relationship diagram, detailed context entries, and a traceable evidence index.

## Key concepts

- **Bounded context.** A part of the codebase where a particular domain model applies and its vocabulary is
  consistent. The skill discovers candidates from code evidence; it does not create bounded contexts.
- **Three confidence tiers.** Every proposed bounded context is classified as CURRENT (vocabulary and ownership
  both cohere today), LATENT (capabilities cohere but ownership or vocabulary is dispersed), or SPECULATIVE
  (evidence is meaningful but requires domain-expert validation before acting).
- **Critic evaluation.** After the bounded-context-modeler produces a first-pass model, the bounded-context-critic
  evaluates each proposal against all discovery evidence and returns a verdict (strong, plausible, weak, or
  reject). The modeler then revises based on criticism the evidence supports.
- **Discovery, not prescription.** The skill tells you what the domain shape is. It does not recommend service
  splits, migrations, or refactors. Those belong to the steps that follow.
- **Whole-repository scope.** The skill can analyze an entire codebase, not just a named module. This is the
  primary entry point for a DDD orientation pass on an unfamiliar system.

## When to use it

**Invoke when:**

- You want to understand the domain structure of a codebase before a major architectural decision.
- The team suspects certain boundaries exist but has never mapped them explicitly.
- You are onboarding onto a new system and want to understand its domain shape before reading the code in detail.
- A previous architectural conversation mentioned "bounded contexts" or "DDD" and you want to know what the code
  actually says.
- You want to find places where domain concepts cross what should be context seams.

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

1. **A size (optional, default: medium).** Pass `small`, `medium`, or `large` as the first word to control
   analysis depth. Small surfaces the highest-frequency terms, the most obvious signals, and the top
   well-evidenced contexts. Medium runs all evidence dimensions for all five discovery agents. Large runs all
   dimensions with emphasis on exhaustive cross-module collision detection, cross-module data flow, and
   comprehensive SPECULATIVE candidates.
2. **A focus area (optional, default: entire repository).** Name a module, directory, or feature area to restrict
   the analysis. When you omit it, the skill analyzes the full repository.
3. **A driving concern (optional).** Tell the skill what you suspect or want to understand. It biases every
   discovery agent's attention without narrowing scope.

Example invocations:

- `/ddd-analysis` — _"Analyze the whole repository and produce a domain map."_
- `/ddd-analysis large` — _"Comprehensive domain map with exhaustive cross-module analysis."_
- `/ddd-analysis src/billing` — _"Focus on the billing module — I think it spans two domain concerns."_
- `/ddd-analysis medium` — _"I think our auth and identity contexts overlap. Map the whole repo at standard depth."_

## What you get back

A domain map report in your conversation with these named sections:

- **Executive Summary.** The domain shape — count of CURRENT, LATENT, and SPECULATIVE contexts and the overall
  critic verdict distribution — with the most confident boundary, the most significant boundary problem, and the
  key question a domain expert must answer before the team acts.
- **Domain Landscape.** 2-4 sentences synthesizing the major business responsibilities the system performs,
  derived from capability and ownership evidence.
- **Ubiquitous Language.** Significant domain terms from the DL# findings, each with a one-line definition or,
  for semantic collisions, a note on the different meanings and the areas where each applies.
- **Business Capabilities.** Cohesive business behaviors from the CAP# findings, each named as a verb phrase
  with a one-line description of what it does and for whom.
- **Current Bounded Contexts.** Contexts where vocabulary and ownership cohere in the evidence today.
- **Latent Bounded Contexts.** Domain concerns where capabilities cohere but ownership or vocabulary is dispersed
  across technical structures. Each entry names what single change would move it toward CURRENT.
- **Speculative Context Hypotheses.** Hypotheses with meaningful evidence that a domain expert must validate
  before the team acts. Each entry states the confirming or refuting question.
- **Boundary Problems.** Detected failure modes from the critic evaluation, contested ownerships, and semantic
  collisions that span candidate boundaries.
- **Context Map.** A Mermaid flowchart showing CURRENT and LATENT context relationships with named DDD
  relationship types where the evidence supports them.
- **Context Details.** One subsection per CURRENT or LATENT context with its purpose, responsibilities,
  vocabulary, ownership, relationships, evidence, and confidence rating.
- **Rejected or Weak Context Candidates.** Contexts the critic rated weak or reject, with the primary failure
  mode and what would change the verdict.
- **Domain Concerns.** Named responsibilities that live inside a broader context without meeting the bar for a
  bounded context of their own, each with its host context and the legitimacy criterion it does not meet. The
  section is absent when the model produced no such entries.
- **Integration Boundaries.** Components identified as integration points, external system interfaces, or
  technical mechanisms rather than bounded contexts — with what semantic evidence would be needed to reclassify
  them as candidates.
- **Questions for Domain Experts.** Consolidated domain-expert questions from the critic, ordered by
  consequence, explaining what domain uncertainty needs resolving and how the answer affects boundary
  interpretation. No implementation prescriptions.
- **Evidence / Analysis Artifacts.** The paths to every artifact file produced by the run — five discovery
  artifacts (domain language, business capabilities, domain ownership, structural, behavioral) and three
  synthesis artifacts (initial context model, final context model, and the rendered report). The finding
  identifier citations throughout the report trace back to these files.
- **Analysis Visuals.** The path to the `visuals/` directory and the list of visual artifact types generated
  by the `domain-visualizer` agent. If visual generation fails, this line notes the failure; the DDD model
  and report are unaffected.

## How to get the most out of it

- **Read the Questions for Domain Experts first.** These are the questions the team needs a domain expert to
  answer before the map can stabilize. Block out time with the right people before deciding what to act on.
- **Treat CURRENT contexts as the anchor.** They are the parts of the system that already have working boundary
  alignment. Build on them rather than reorganizing them.
- **LATENT contexts are not action items.** A latent bounded context tells you the domain concern exists; it
  does not tell you to create a new service. The decision about whether to align the structure belongs to the
  team.
- **Pass a driving concern.** The more specific your hypothesis ("I think order fulfillment and order billing
  share too many entities"), the more precisely the discovery agents will investigate the signals you care about.
- **Pair with `/architectural-analysis` next.** After the domain map identifies a specific module you want to
  understand at the code level, run `/architectural-analysis` on that module to get coupling, SOLID, and
  structural findings that inform a refactor or boundary alignment decision.

## Cost and latency

Five discovery agents (`domain-language-analyst`, `business-capability-analyst`, `domain-ownership-analyst`,
`han-core:structural-analyst`, `han-core:behavioral-analyst`) run in parallel on Sonnet. After they complete,
`bounded-context-modeler` (Opus) produces a first-pass context model, then `bounded-context-critic` (Opus)
evaluates each proposal, then `bounded-context-modeler` (Opus) runs a single revision pass. The
`han-communication:readability-editor` (Sonnet) runs after the report is rendered. After the report passes its
final integrity check, `domain-visualizer` (Sonnet) produces the visual artifacts.

The parallel discovery phase is the most time-intensive step on large repositories. Total wall-clock time scales
with repository size and analysis depth.

## Sources

The skill's vocabulary and classification approach are grounded in Eric Evans's Domain-Driven Design and the
follow-on strategic-patterns literature.

### Evans, Eric. _Domain-Driven Design: Tackling Complexity in the Heart of Software._ Addison-Wesley, 2003.

The foundational source for bounded contexts, ubiquitous language, context maps, and the strategic patterns
(shared kernel, anti-corruption layer, open host service, published language, customer-supplier, conformist,
separate ways).
URL: (book; no public URL)

### Vernon, Vaughn. _Implementing Domain-Driven Design._ Addison-Wesley, 2013.

Expands the strategic patterns with worked examples of context mapping, aggregate design, and the four integration
relationship types.
URL: (book; no public URL)

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`bounded-context-modeler`](../agents/bounded-context-modeler.md). The synthesis agent this skill dispatches
  twice — first pass and revision pass.
- [`bounded-context-critic`](../agents/bounded-context-critic.md). The evaluation agent dispatched between the
  two modeler passes.
- [`domain-language-analyst`](../agents/domain-language-analyst.md). The discovery agent that surfaces language
  signals.
- [`business-capability-analyst`](../agents/business-capability-analyst.md). The discovery agent that surfaces
  behavioral capabilities.
- [`domain-ownership-analyst`](../agents/domain-ownership-analyst.md). The discovery agent that surfaces
  ownership evidence.
- [`/architectural-analysis`](../../../han-coding/docs/skills/architectural-analysis.md). The right next step when
  you want code-level coupling and SOLID findings for a module the domain map identified.
- [`domain-visualizer`](../agents/domain-visualizer.md). The agent this skill dispatches last to produce
  evidence-backed visual artifacts from the completed analysis.
- [`/plan-a-feature`](../../../han-planning/docs/skills/plan-a-feature.md). The right next step when the domain
  map identifies a boundary you want to align or introduce.
