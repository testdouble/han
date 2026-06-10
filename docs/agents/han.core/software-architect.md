# software-architect

Operator documentation for the `software-architect` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/software-architect.md`](../../../han.core/agents/software-architect.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Adversarially synthesizes intra-codebase analysis (structural, behavioral, concurrency, risk findings) into recommended software-architecture changes aligned with SOLID, high cohesion, and loose coupling. Assumes the current module structure is wrong (too coupled, too scattered, missing an abstraction at an infrastructure seam, or over-abstracted with interfaces that have one implementation) until evidence says otherwise.
- **When to dispatch it.** After the three architectural analysts plus `risk-analyst` have produced findings for a focus area that lives inside a single codebase or bounded context, and you want synthesis into recommended changes with pseudocode sketches. Always dispatched by `/architectural-analysis` (it runs on the synthesis spine at every size). Conditionally dispatched by `/architectural-decision-record`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, and `/plan-implementation` when the work touches intra-codebase module boundaries or abstractions.
- **What you get back.** Numbered `A#` recommendations, each cross-referencing the upstream findings it addresses, the SOLID or cohesion/coupling principle it grounds, the recommended change with pseudocode, and the risk if deferred.

## Key concepts

- **Software altitude, not system altitude.** The agent operates at the level of modules, classes, functions, and interfaces inside a codebase. Concerns that cross a service boundary, a bounded-context seam, or a trust boundary are deferred to [`system-architect`](./system-architect.md).
- **SOLID as the citable principle.** Every recommendation grounds in a named principle (SRP, OCP, LSP, ISP, DIP, high cohesion, loose coupling, or a tactical DDD pattern) and explains how the cited upstream finding violates it.
- **Pseudocode sketches, not production code.** The agent shows interface shapes, module-boundary outlines, and signature examples. Implementation is a separate step.
- **Verification against the codebase.** Before a recommendation is produced, the agent checks the codebase with Read and Grep. Proposed module splits do not orphan existing callers. Proposed interfaces are compatible with the current public surface.
- **Not every finding needs a recommendation.** If the risk is low and the code is functional, the agent says so. Over-engineering is itself an architectural risk.

## When to use it

**Dispatch when:**

- `/architectural-analysis` has produced `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, and `risk-analyst` findings, and you need synthesis into recommended changes. The skill dispatches this agent as its final step. You usually do not dispatch it directly in this flow.
- You are drafting an implementation plan (via `/plan-implementation`) for a feature mostly internal to one codebase or one bounded context, and you want software-architecture recommendations included in the plan.
- You already have upstream findings from a manual architectural pass and want synthesis without re-running the analysts.
- A recurring refactoring debate would benefit from a principle-grounded recommendation rather than a style argument.

**Do not dispatch for:**

- **Cross-service / bounded-context topology.** Use [`system-architect`](./system-architect.md). Context-map relationships, integration patterns, data ownership across services, failure-domain containment.
- **Discovering findings.** Use [`structural-analyst`](./structural-analyst.md), [`behavioral-analyst`](./behavioral-analyst.md), or [`concurrency-analyst`](./concurrency-analyst.md). This agent synthesizes. It does not discover.
- **Risk prioritization.** Use [`risk-analyst`](./risk-analyst.md). This agent consumes risk assessments. It does not produce them.
- **File-level code review.** Use [`/code-review`](../../skills/han.coding/code-review.md). This agent does not grade individual files for correctness, style, or test coverage.
- **Production readiness.** Use [`devops-engineer`](./devops-engineer.md). Deployment, observability, rollout, and SLO concerns live there.
- **Schema, index, or query design.** Use [`data-engineer`](./data-engineer.md).
- **Exploit-path analysis.** Use [`adversarial-security-analyst`](./adversarial-security-analyst.md).

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:software-architect`. Normally this happens as the final step of `/architectural-analysis`. You rarely invoke it directly.

If you do invoke it directly, give it:

1. **The full verbatim output of upstream analysts.** At minimum, `structural-analyst` findings (`S#`), `behavioral-analyst` findings (`B#`), `concurrency-analyst` findings (`C#`), and `risk-analyst` assessments (`R#`). Without these inputs the agent has nothing to synthesize.
2. **The focus area.** Which module, directory, or bounded context the upstream findings describe. This shapes where the agent looks when verifying recommendations against the code.
3. **Optional framing.** If a specific concern motivated the analysis (*"we want to split this module before the auth rewrite"*), say so. The framing biases which recommendations get prioritized in the summary.

Example prompts:

- *"The upstream analysts have produced findings for `src/billing/`. Read them and produce software-architecture recommendations."* (include the full verbatim upstream output inline)
- *"We have structural and behavioral findings from a manual pass on the notification service. Synthesize them into SOLID-grounded recommendations with pseudocode."*

## What you get back

- **Numbered `A#` recommendations**, ordered by impact. Each item includes:
  - **Addresses.** Cross-references to upstream `S#`, `B#`, `C#`, `R#` findings.
  - **Principle.** Which SOLID principle or cohesion/coupling concern is cited.
  - **Current state.** Short description of the problem.
  - **Recommended change.** What to change and how, with pseudocode sketches where they clarify intent.
  - **Rationale.** Why this change improves the architecture, tied to the principle.
  - **Risk if deferred.** What happens if the recommendation is not implemented.
- **Software Architecture Recommendations Summary.** Count of findings addressed, key themes (2–3), highest-impact recommendations, and any findings explicitly deferred to `system-architect` (concerns that cross a service or bounded-context seam).

Every recommendation traces back to specific upstream finding IDs. If an upstream finding has no recommendation, the summary either lists it as low-risk-and-intentionally-unaddressed or as a system-level deferral.

## How to get the most out of it

- **Feed it complete upstream output.** Abbreviated summaries of analyst findings degrade synthesis. Pass the verbatim `S#`/`B#`/`C#`/`R#` blocks.
- **Scope the focus area narrowly.** The agent verifies recommendations by reading code. A narrower focus area means sharper verification and more actionable pseudocode.
- **Pair with [`system-architect`](./system-architect.md)** when findings span a service boundary or bounded-context seam. This agent's summary explicitly lists such deferrals. Dispatching `system-architect` with the same upstream input gets you the recommendations at the other altitude.
- **Do not re-run to "double-check."** Re-dispatching with the same input produces the same recommendations with higher cost. If you disagree with the output, challenge it with [`adversarial-validator`](./adversarial-validator.md) instead.
- **Use the `A#` IDs downstream.** The IDs are stable within a run and cite cleanly in ADRs, PR descriptions, and plan documents.

## Cost and latency

The agent runs on `opus` and reads the codebase to verify recommendations. A synthesis pass for a medium-size focus area typically finishes in a few minutes. The agent is designed for infrequent, high-signal runs (a refactor planning check-in, a pre-rewrite baseline, an implementation-plan input). It is not a tight-loop tool.

## In more detail

The agent's recommendation process:

1. Read all upstream findings and risk assessments.
2. Identify clusters of related findings that point to the same intra-codebase architectural issue.
3. For each cluster, design a recommendation that addresses the root structural cause.
4. Verify the recommendation against the codebase. Confirm existing callers, importers, and public surfaces are compatible with the proposed change.
5. Produce pseudocode sketches.
6. For any finding that crosses a service or bounded-context seam, note it as a system-level deferral rather than producing a software-level recommendation. The Summary lists deferrals explicitly so the downstream reader knows where to dispatch `system-architect`.

The agent refuses to:

- Recommend an abstraction for code with one implementation and no churn.
- Recommend a module split without checking callers.
- Produce pseudocode in a language the project does not use.
- Cite SOLID without explaining the violation.
- Absorb a system-level concern into a software-level recommendation.

## YAGNI

Architectural recommendations from this agent must cite the change-history, coupling, or cohesion evidence that justifies them. Single-implementation interfaces, abstract base classes introduced before three concrete uses exist (the Rule of Three), and *"future flexibility"* abstractions are YAGNI candidates and are not recommended. When the upstream `structural-analyst` / `behavioral-analyst` / `concurrency-analyst` findings genuinely require a new abstraction, the agent prefers the strictly simpler version that satisfies the same finding: a single function over a class, a class over a class hierarchy, one concrete implementation over an interface with one implementation. Recommendations that cannot pass the evidence test are deferred with a named *reopen-when* trigger (typically a second or third concrete use case, a measured coupling cost, or a documented incident).

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Sources

The agent's principles and vocabulary are grounded in established software-architecture practice. Each source below is cited because the agent draws specific, named artifacts from it.

### Robert C. Martin: *Clean Architecture: A Craftsman's Guide to Software Structure and Design* (2017)

Martin's articulation of the SOLID principles and the dependency rule of Clean Architecture is the primary citable framework for the agent's recommendations. SRP, OCP, LSP, ISP, and DIP are the five named principles the agent grounds individual recommendations in.

URL: https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/

### Alistair Cockburn: *Hexagonal Architecture / Ports and Adapters* (2005)

Cockburn's ports-and-adapters pattern is the canonical separation between domain logic and I/O, framework, and infrastructure concerns. The agent recommends a port introduction when a finding shows business logic depending directly on infrastructure. But only for "the outside" that lives inside the codebase. When the outside is another team's service, the recommendation is deferred to `system-architect`.

URL: https://alistair.cockburn.us/hexagonal-architecture/

### Eric Evans: *Domain-Driven Design: Tackling Complexity in the Heart of Software* (2003)

Evans's tactical DDD patterns (aggregate, entity, value object, repository, domain service) are the agent's vocabulary for structuring a domain model inside a bounded context. Strategic DDD (bounded-context identification, context maps, integration relationships) belongs to `system-architect`.

URL: https://www.domainlanguage.com/ddd/

### Martin Fowler: *Refactoring: Improving the Design of Existing Code* (2018, 2nd ed.)

Fowler's catalog of refactorings (Extract Class, Extract Interface, Move Method, Introduce Parameter Object) gives the agent precise names for the structural changes it recommends. The agent names the refactoring in the recommendation rather than describing it generically.

URL: https://martinfowler.com/books/refactoring.html

### Gamma, Helm, Johnson, Vlissides: *Design Patterns: Elements of Reusable Object-Oriented Software* (1994)

The Gang of Four's pattern catalog is the agent's vocabulary when a finding matches a known structural remedy: Strategy for an OCP violation, Adapter for an interface-translation concern, Facade for a too-exposed subsystem. The agent cites the pattern by name.

URL: https://www.oreilly.com/library/view/design-patterns-elements/0201633612/

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this agent applies. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [`system-architect`](./system-architect.md). The sibling agent for concerns that cross a service or bounded-context seam.
- [`structural-analyst`](./structural-analyst.md), [`behavioral-analyst`](./behavioral-analyst.md), [`concurrency-analyst`](./concurrency-analyst.md). The three parallel analysts whose findings this agent synthesizes.
- [`risk-analyst`](./risk-analyst.md). The agent that prioritizes analyst findings. Its assessments are part of this agent's input.
- [`/architectural-analysis`](../../skills/han.coding/architectural-analysis.md). The skill that dispatches this agent as its final synthesis step.
- [`/plan-implementation`](../../skills/han.core/plan-implementation.md). The skill that includes this agent in its roster for feature implementation planning.
- [agent-domain-focus.md](../../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md). Why the agent uses precise domain vocabulary and named anti-patterns.
- [agent-model-selection.md](../../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier.
