# Sizing

Sizing is one of the two foundational mechanics of the han plugin. Every skill that dispatches a swarm of specialist agents first classifies the work as **small**, **medium**, or **large**. That classification decides how many agents to dispatch, which agents to dispatch, how many rounds to iterate, and how aggressively to calibrate findings. The sizing-aware skills are `/architectural-analysis`, `/code-overview`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation`, and `/research`.

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [YAGNI](./yagni.md) · [All skills](./skills/README.md) · [All agents](./agents/README.md)

## TL;DR

- **Three bands.** Small / medium / large. Each band caps the team or swarm size and the iteration depth.
- **Default is small.** Every sizing-aware skill starts the classification at **small** and only escalates to medium or large when concrete signals clearly require it. When a signal is borderline, the skill stays at the smaller band.
- **Auto-classified.** When you do not pass `$size`, the skill reads concrete signals: file count, subsystems touched, security/data/infra surface, and cross-cutting concerns. It announces the chosen size with a one-line justification before dispatching agents.
- **Always overridable.** Pass the size as the first positional argument when invoking the skill (`/code-review medium`, `/plan-a-feature small "describe the feature"`, and so on). The skill honors the override and still scales the team and round caps to the chosen size.
- **Conservative by design.** Fewer agents producing higher-signal findings is the goal; quantity is not the metric. The skill prefers under-dispatching that you can re-run at a larger size to over-dispatching that drowns you in low-signal findings.

## Why sizing matters

Specialist agents are expensive: in tokens, in latency, and in your attention to reconcile their findings. Without sizing:

- A two-line README fix would dispatch the full security, structural, behavioral, concurrency, data, devops, test, and edge-case roster. You would drown in low-signal findings and burn tokens for nothing.
- A genuinely cross-service change would get the same default roster as a single-file rename. The skill would miss specialists whose domain it touches, and the change would arrive under-reviewed.
- Findings would not calibrate to scope. A `Suggestion` about a hypothetical scaling concern would land alongside a `Critical` about a real exploit, and the team would have to triage the false equivalence themselves.

Sizing fixes all three. It picks a roster proportional to the actual change, calibrates each agent's brief to the size, and tells you up front what was chosen and why.

## The three bands

The exact cutoffs vary per skill (a "medium" code review is not a "medium" feature plan), but the bands carry the same meaning across the plugin:

| Band | Meaning | Typical signals | Team / swarm posture |
|---|---|---|---|
| **Small** | Single subsystem, no cross-cutting concerns, contained surface area. | A handful of files, one module, no auth/PII, no schema or migration, no integration boundary. | Minimum roster: the cheapest specialists that still cover correctness and security. Iteration cap is at its lowest (often a single round). |
| **Medium** | Two or three adjacent subsystems, may touch one cross-cutting concern. | Up to a dozen files, a single API contract, schema migration, new permission check, or new index. | A modest team: required roles plus two to three domain specialists chosen by signal. Iteration cap is moderate. |
| **Large** | Cross-service, security-sensitive, multiple new coordinations, data ownership shifts, or you explicitly requested it. | More than a dozen files, multiple subsystems, architectural changes, security or data implications. | A larger team: required roles plus four to six domain specialists. Iteration cap is at its highest. |

Each sizing-aware skill restates these bands with skill-specific signals and caps; see the **Sizing** section in each skill's long-form doc.

## How auto-classification works

Each sizing-aware skill performs classification before dispatching agents. The skill:

1. Reads the available context. For code, the changed file list and diff. For plans and specs, the document body. For gap analyses, the structured `gap-analyzer` output.
2. Starts the classification at **small**.
3. Maps signals to a band: file count, subsystem count, presence of security/PII/auth/data/integration concerns, cross-cutting surface area.
4. Escalates from small to medium only when at least one medium-band signal is clearly present, and from medium to large only when at least one large-band signal is clearly present. Borderline signals do not escalate.
5. States the chosen band to you in one line with a justification (for example, `Medium: 6 files touched, adds one index and a query for it`).
6. Caps the team or swarm size and the iteration depth based on the band.

## Overriding the size with `$size`

Every sizing-aware skill declares a `$size` positional argument in its frontmatter. The argument is optional. If present, it bypasses the skill's signal-based classification and forces the chosen band. If absent, the skill auto-classifies as above.

Pass the size as the first positional argument when invoking the skill:

```
/code-review medium
/code-review large "focus on the new auth endpoints"
/gap-analysis large
/iterative-plan-review small docs/plans/refactor-cache.md
/plan-a-feature medium "describe the feature here"
/plan-implementation large docs/features/checkout/feature-specification.md
```

Accepted values: `small`, `medium`, `large`. Anything else is treated as part of the trailing context, not as a size, and the skill falls back to auto-classification.

When the size is overridden with `$size`:

- The skill announces the override (`Medium: passed via $size`) instead of an auto-classification justification.
- The team or swarm still scales to the chosen band. Overriding to `large` does not bypass the team cap.
- Specialists are still selected by signal. The size sets the upper bound, but agents whose domain is not touched are still skipped.
- Conversational overrides ("run this as a large review") still work; `$size` and conversational override are equivalent inputs.

## Sizing across skills at a glance

| Skill | What gets sized | Small | Medium | Large |
|---|---|---|---|---|
| [`/architectural-analysis`](./skills/han-coding/architectural-analysis.md) | Signal-selected roster + finding calibration | Single module, no cross-cutting signal (spine + concurrency, 3–4 agents) | One cross-cutting concern (spine + 1–2 specialists, 4–6 agents) | Multi-subsystem or cross-service seam (spine + all signalled specialists + system-architect, 6–9 agents) |
| [`/code-overview`](./skills/han-coding/code-overview.md) | Exploration roster (codebase-explorer only) | Single file, symbol, or small change set (1 explorer) | A directory/module or moderate change set (2–3 explorers) | Multiple subsystems or a large change set (3–5 explorers) |
| [`/code-review`](./skills/han-coding/code-review.md) | Agent roster + finding calibration | 1–3 files, single subsystem | 3–10 files, one cross-cutting concern | More than 10 files, multiple subsystems |
| [`/gap-analysis`](./skills/han-core/gap-analysis.md) | Default-on swarm size | 0–3 gaps, single domain (2–3 agents, no PM) | 4–10 gaps, two or three domains (4–6 agents with PM) | 11+ gaps or cross-cutting domains (6–8 agents with PM) |
| [`/iterative-plan-review`](./skills/han-planning/iterative-plan-review.md) | Lightweight vs team mode + team size + round cap | 2–3 files, single system (lightweight, 1 round) | 3–5 files, one cross-cutting concern (team, 3–4, 2 rounds) | More than 5 files, multiple systems (team, 4–5, 3 rounds) |
| [`/plan-a-feature`](./skills/han-planning/plan-a-feature.md) | Review-team size cap | Single subsystem (team cap 2) | Two to three subsystems (team cap 3–4) | Cross-service or security-sensitive (team cap 4–5) |
| [`/plan-implementation`](./skills/han-planning/plan-implementation.md) | Implementation-team size + round cap | Single subsystem (team cap 3, 1 round) | Two to three subsystems (team cap 4–5, 2 rounds) | Cross-service or security-sensitive (team cap 6–8, 3 rounds) |
| [`/research`](./skills/han-core/research.md) | Research-analyst angle count + reach | One domain, few or no options, narrow reach (2–3 agents) | Two to three domains or several options, codebase-plus-web reach (3–5 agents) | Many options across multiple domains, or full-breadth request (5–8 agents) |

Read each skill's **Sizing** section for the full per-skill rules.

## Design principles

- **Sizing is transparent.** The skill always announces the chosen band before dispatching agents. You can override, and the skill states the override explicitly.
- **Sizing is conservative.** Borderline signals drop to the smaller band. Over-dispatching is more expensive than under-dispatching when you can re-run a skill at a larger size.
- **Sizing is signal-driven.** The bands are defined by what the work touches, not by who asked for the review. The auto-classification is the same for everyone.
- **Sizing scales the team and the brief.** A larger size dispatches more agents *and* tells each agent that more severity bands are in scope and more findings are acceptable. A smaller size narrows both the roster and what each agent escalates.
- **Sizing is overridable, not configurable.** There is no project-level "always run as medium" setting. You opt in to the override on each invocation, when the auto-classification is wrong.

## Related reading

- [Concepts](./concepts.md). The skill / agent split. Sizing is a property of skills that dispatch agent swarms.
- [YAGNI](./yagni.md). The other foundational mechanic. Sizing decides *how much review* an artifact gets; YAGNI decides *what survives* the review.
- [`han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md`](../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md). Why dispatching the right number of agents matters more than dispatching the most agents.
- The **Sizing** section in each sizing-aware skill's long-form doc: [`/architectural-analysis`](./skills/han-coding/architectural-analysis.md), [`/code-overview`](./skills/han-coding/code-overview.md), [`/code-review`](./skills/han-coding/code-review.md), [`/gap-analysis`](./skills/han-core/gap-analysis.md), [`/iterative-plan-review`](./skills/han-planning/iterative-plan-review.md), [`/plan-a-feature`](./skills/han-planning/plan-a-feature.md), [`/plan-implementation`](./skills/han-planning/plan-implementation.md), [`/research`](./skills/han-core/research.md).
