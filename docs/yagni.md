# YAGNI

YAGNI (*You Aren't Gonna Need It*) is the second foundational mechanic of the han plugin. Every skill that produces an artifact, and every agent that reviews one, applies an evidence-based YAGNI rule before committing items: feature behaviors, plan steps, code recommendations, ADRs, coding standards, runbooks, observability hooks, alerts, indexes, tests, abstractions, configuration knobs, build phases. Items survive when evidence justifies them. Items without evidence get deferred (recorded for later, not silently dropped).

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [Sizing](./sizing.md) · [All skills](./skills/README.md) · [All agents](./agents/README.md)

## TL;DR

- **Evidence-based, not absolute.** Items survive when at least one acceptable piece of evidence justifies them. There is no "always include" or "always omit" rule.
- **Two gates.** Gate 1 asks *is this needed now?* (the evidence test). Gate 2 asks *is there a strictly simpler version that satisfies the same evidence?* (the simpler-version test).
- **Default is defer.** When no evidence applies, items move to a `## Deferred (YAGNI)` section in the artifact with a named *reopen-when* trigger. They are never silently dropped.
- **You always win.** Skills and agents make the cost of inclusion visible; you can direct an item to be kept against the rule. The point is conscious choice, not bureaucratic exclusion.
- **The canonical rule lives in [`han.core/references/yagni-rule.md`](../han.core/references/yagni-rule.md).** Every YAGNI-aware skill and agent loads that file at runtime. This page is the operator-facing summary.
- **See also [`docs/evidence.md`](./evidence.md).** YAGNI's evidence test answers *is there any evidence at all to justify including this item?* The companion evidence rule answers *once an item passes that test, how strong is the evidence and what do you do when no evidence exists?* The two rules work together.

## Why YAGNI matters

Every line of code, every section of a spec, every runbook, every abstraction, every configuration knob, every observability hook is ongoing maintenance cost. It is also a pattern future agents will treat as load-bearing and copy. Without YAGNI:

- Plans accrete defensive code, framework-shaped abstractions, and "for future flexibility" branches that the team has to maintain forever and that future skills will treat as established convention.
- Reviewers approve symmetry-driven additions ("we have create, so we should have delete") and best-practice imports ("the standard is…") without ever asking *does this project have the problem this solves?*
- Operational machinery (runbooks, alerts, SLOs, dashboards) gets built for telemetry that isn't reaching the destination yet, traffic the system doesn't yet receive, or failure modes that have never occurred.
- ADRs land for decisions that don't have a forcing function today; coding standards land for patterns the project doesn't use yet.

YAGNI doesn't reject planning ahead. It requires that planning ahead carry evidence (a regulatory deadline, a customer commitment, a dependency that requires lead time). It rejects *speculation*.

## The two gates

### Gate 1: the evidence test

Any committed item must cite **at least one** piece of acceptable evidence:

1. **A user-described need.** A PRD, feature spec, ticket, conversation, or stakeholder commitment.
2. **A named direct dependency.** Another in-scope item literally cannot work without it (the dependent must itself pass the evidence test).
3. **An existing production code path or contract that will break without it.** Cite the file, function, or external consumer.
4. **A regulatory or compliance rule that demonstrably applies today.** Cite the specific regulation. "Compliance might require…" is not evidence.
5. **A documented incident, real production alert that has fired, real customer report, or measured metric.** Hypotheticals don't qualify; alerts that have fired do.

If none apply, the item is **YAGNI**. Defer it.

### Gate 2: the simpler-version test

When evidence justifies an item, ask: *is there a strictly simpler version that satisfies the same evidence?*

- A single function beats a class. A class beats a class hierarchy. A class hierarchy beats a framework.
- One concrete implementation beats an interface with one implementation.
- A literal value beats a configurable value beats a configurable value with a default.
- An inline check beats a helper beats a middleware beats a framework.
- One end-to-end test beats one end-to-end test plus three integration tests plus twelve unit tests, when the end-to-end test catches every realistic failure mode.

If a simpler version satisfies the same evidence, the simpler version replaces the larger one. The larger version is YAGNI until the simpler one demonstrably falls short.

## Named anti-patterns (auto-flag as YAGNI candidates)

The full list lives in [`yagni-rule.md`](../han.core/references/yagni-rule.md). Highlights:

- "We might need…" / "for future flexibility" / "in case we want to…"
- "When we scale" / "at scale" / "for performance" without measured pressure.
- "Best practice says…" applied to best practices that don't solve a problem this project has.
- Symmetry / completeness. "We have create, so we should have delete."
- Single-implementation interfaces / abstract base classes (the Rule of Three).
- Speculative configuration knobs, env vars, feature flags wrapping a single code path.
- Defensive code at trusted internal boundaries.
- Speculative observability: instrumentation for telemetry that isn't reaching the destination yet, or failure modes that have never occurred.
- Runbooks for alerts that have never fired.
- SLOs / error budgets for traffic the system doesn't yet receive.
- Multi-region / HA infrastructure for a workload that hasn't proven single-region pressure.
- Indexes for queries that don't run, audit columns nobody reads, denormalization for read patterns that don't exist.
- Tests for code paths that don't exist yet.
- ADRs for decisions that don't have a forcing function today.
- Coding standards for patterns the project doesn't use yet.
- Build phases whose only justification is "completeness of the roadmap."

Anti-patterns from this list force a YAGNI finding regardless of severity rules.

## How YAGNI applies across the plugin

YAGNI applies in two postures: **producing** (when a skill drafts an artifact) and **reviewing** (when a skill or agent audits one).

| Surface | What YAGNI gates |
|---|---|
| [`/plan-a-feature`](./skills/han.core/plan-a-feature.md) | Every behavior, edge case, alternate flow, and coordination in the spec. Speculative behaviors land in a `## Deferred (YAGNI)` section. |
| [`/plan-implementation`](./skills/han.core/plan-implementation.md) | Every plan step, abstraction, infrastructure addition, observability hook, and rollout step. A YAGNI sweep runs before the plan is committed. |
| [`/plan-a-phased-build`](./skills/han.core/plan-a-phased-build.md) | Every phase. Phases whose only justification is "completeness of the roadmap" get deferred or merged into a smaller adjacent phase. |
| [`/iterative-plan-review`](./skills/han.core/iterative-plan-review.md) | A YAGNI review pillar runs alongside correctness, completeness, and risk. Every uncited item raises a `Category: YAGNI candidate` finding. |
| [`/code-review`](./skills/han.core/code-review.md) | YAGNI is **advisory-only** and runs as a two-pass procedure (Pass 1 evidence test against Gate 1; Pass 2 named anti-pattern match). Each finding records the failing evidence type, the matched anti-pattern, and the simpler form considered. Findings surface speculative additions but do not block a clean review on their own; the reviewer's posture is "make the cost of inclusion visible," not "reject the change." Skipped in Mode B (uncommitted changes) and Mode C (no git) unless explicitly requested via the focus-areas argument, since no diff exists to distinguish introduced code from pre-existing code. |
| [`/coding-standard`](./skills/han.core/coding-standard.md) | A standard is justified only when the project does the thing the standard governs *today* and the standard solves a real, concrete problem the team is currently hitting. |
| [`/test-planning`](./skills/han.core/test-planning.md) | A YAGNI sweep removes speculative tests: for code paths that don't exist, hypothetical adversaries, or branches the change doesn't touch. |
| [`/architectural-decision-record`](./skills/han.core/architectural-decision-record.md) | An ADR requires a **forcing function** today: a real decision being made now, with consequences. ADRs about decisions that don't have a forcing function are YAGNI. |
| [`/tdd`](./skills/han.coding/tdd.md) | Enforcing in the refactor step and the test list. A scenario joins the test list only with evidence; speculative scenarios are deferred with a reopen trigger. Refactor removes duplication but defers speculative abstraction (the Rule of Three). Correctness-and-placement standards still apply in green. |
| [`project-manager`](./agents/han.core/project-manager.md) | The YAGNI Evidence Gate protocol. Every committed proposal in a facilitated discussion must cite evidence; uncited proposals are challenged or deferred. |
| [`junior-developer`](./agents/han.core/junior-developer.md) | The YAGNI Evidence Sweep protocol. Flags hidden assumptions and uncited additions during stress-testing. |
| [`software-architect`](./agents/han.core/software-architect.md) | Architectural recommendations cite the change-history or coupling evidence that justifies the recommendation. Speculative abstractions are deferred. |
| [`system-architect`](./agents/han.core/system-architect.md) | Cross-service topology changes cite the seam-crossing evidence (data ownership conflict, failure-domain leak, integration shape) that justifies them. |
| [`test-engineer`](./agents/han.core/test-engineer.md) | The Speculative Test rule. Tests for code paths that don't exist, hypothetical adversaries, or unreachable branches are flagged. |
| [`edge-case-explorer`](./agents/han.core/edge-case-explorer.md) | The Speculative Edge Case rule. Edge cases for code paths that don't exist or for inputs that internal callers fully control are flagged. |
| [`data-engineer`](./agents/han.core/data-engineer.md) | The Speculative Data Machinery rule. Indexes for queries that don't run, audit columns nobody reads, denormalization for read patterns that don't exist. |
| [`devops-engineer`](./agents/han.core/devops-engineer.md) | The Premature Operational Machinery rule. Runbooks for alerts that have never fired, SLOs for traffic that doesn't yet exist, multi-region infrastructure for unproven single-region workloads. |
| [`on-call-engineer`](./agents/han.core/on-call-engineer.md) | The Premature Operability Machinery rule, applied at the application source line. Circuit breakers, bulkheads, idempotency tables, kill switches, dead-letter queues, and custom error types are deferred when no evidence shows the system needs them now (named upstream finding, existing code path that breaks, three current uses, measured incident, applicable regulation). |

## The Deferred (YAGNI) section format

Every artifact that may produce YAGNI deferrals adds a section with this structure:

```
## Deferred (YAGNI)

### {item name}
**Why deferred:** {which gate failed, evidence test or simpler-version test, with the specific reason}
**Reopen when:** {the concrete trigger that would justify revisiting: a metric, an incident class, a customer commitment, a dependency landing, a regulation taking effect}
**Source:** {where the item was originally proposed: review finding ID, agent name, conversation context}
```

When no items are deferred, the section is omitted entirely. Don't write empty stub sections.

## What YAGNI is not

- **Not "never plan ahead."** Plan ahead when planning ahead is the evidence: a regulatory deadline, a customer commitment, a dependency that requires lead time. The evidence test welcomes that.
- **Not "skip security / data integrity / correctness."** Critical-path correctness work passes the evidence test trivially. YAGNI applies to *speculative* security hardening, not to addressing actual exploit paths or actual data corruption.
- **Not "never refactor."** Refactor when the existing structure demonstrably impedes the change being made. That is evidence. Refactor for "cleanliness" alone is YAGNI.
- **Not an excuse to skip user-described requirements.** If you said you want it, that *is* evidence. The rule challenges what skills and agents add on top of what you asked for.

## Design principles

- **YAGNI is evidence-based, not opinion-based.** The rule has a concrete list of acceptable evidence. Disagreement is resolved by pointing to a piece of that evidence, not by argument.
- **YAGNI surfaces, never silences.** Deferred items are recorded with their reopen-trigger. They come back when the trigger fires.
- **YAGNI scales with maturity.** A project with no production traffic defers operational machinery aggressively; a system with measured traffic and real incidents passes the evidence test for that machinery trivially. The same rule produces different answers as the project grows.
- **YAGNI is your tool, not a gatekeeper.** Skills and agents apply the rule; you can override on any single item. The override is recorded with rationale so the choice stays visible.

## Related reading

- [`han.core/references/yagni-rule.md`](../han.core/references/yagni-rule.md). The canonical rule that every YAGNI-aware skill and agent loads at runtime.
- [Concepts](./concepts.md). The skill / agent split. YAGNI is a property of skills that produce artifacts and agents that review them.
- [Sizing](./sizing.md). The other foundational mechanic. Sizing decides *how much review* an artifact gets; YAGNI decides *what survives* the review.
- The skill long-form docs and agent long-form docs cited in the table above each name where they apply YAGNI in their own protocol.
