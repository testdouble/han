# structural-analyst

Operator documentation for the `structural-analyst` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/structural-analyst.md`](../../../han.core/agents/structural-analyst.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md)

## TL;DR

- **What it does.** Analyzes the static structure of a specified codebase focus area: module boundaries, coupling, dependency direction, abstractions, and duplication. Produces numbered structural findings with file paths and verbatim code.
- **When to dispatch it.** You want a principled static-structure pass on a module or focus area, independent of runtime behavior or risk assessment. Always dispatched by `/architectural-analysis`. Conditionally dispatched by `/code-review`, and by `/iterative-plan-review` and `/plan-implementation` when the plan or review covers module boundaries, coupling, or dependency direction. Available to `/plan-a-feature` as an opt-in specialist, included on request.
- **What you get back.** Numbered `S#` findings, each tied to a structural dimension (Boundaries / Coupling / Dependency Direction / Abstraction / Duplication), file paths, verbatim code, and an impact statement.

## Key concepts

- **Static, not runtime.** The agent reads code as written. Data flow, error propagation, and concurrency are out of scope and deferred to `behavioral-analyst` and `concurrency-analyst`.
- **Five dimensions, all required.** Module Boundaries and Cohesion, Coupling Analysis, Dependency Direction, Abstraction Assessment, Duplication and Pattern Candidates. Skipping a dimension makes the analysis incomplete.
- **Coupling has texture.** The agent distinguishes afferent (who depends on this?) from efferent (what does this depend on?), and stable-dependency from volatile-dependency, rather than counting imports as a single number.
- **Negative results are valuable.** When a dimension surfaces no issues, the agent says so explicitly. *"Well-structured"* is a finding too.
- **Discovers findings, does not synthesize.** Recommendations belong to `software-architect`. Risk assessment belongs to `risk-analyst`.
- **`/code-review` adds a default-SUGG dispatcher directive at Step 3.5.** When dispatched from `/code-review`, the skill appends an instruction to default the severity of every finding to SUGG and escalate to WARN or CRIT only when the change actively introduces or worsens the issue. This is `/code-review`'s tailoring; the agent's general behavior outside `/code-review` is unchanged. Other callers (such as `/architectural-analysis`) receive the agent's default skeptical posture.

## When to use it

**Dispatch when:**

- `/architectural-analysis` is running. The agent is one of the three parallel analysts the skill always dispatches.
- `/code-review` flags structural concerns in the file list (new module boundaries, large refactors, suspicious import patterns).
- You suspect a coupling or cohesion problem in a module but cannot point at the specific finding. The agent surfaces them concretely.
- A pre-refactor baseline is needed before splitting or restructuring a module.

**Do not dispatch for:**

- Runtime behavior, data flow, error propagation. Use `behavioral-analyst`.
- Concurrency hazards. Use `concurrency-analyst`.
- Risk prioritization. Use `risk-analyst` (which consumes this agent's findings).
- Architectural recommendations or refactoring plans. Use `software-architect`.
- Cross-service topology. Use `system-architect`.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:structural-analyst`. Give it a focus area (module, directory, or set of files). The agent examines the focus area plus one layer outward in each direction (what depends on it, what it depends on).

Example prompts:

- *"Analyze the static structure of `src/billing/`. Focus on module boundaries and coupling. Use git churn to identify volatile dependencies if available."*
- *"Examine `packages/notifications/` for cohesion and abstraction quality. We are about to split this package into two."*

## What you get back

- Numbered `S#` findings, each with: dimension (Boundaries / Coupling / Dependency Direction / Abstraction / Duplication), relevant file paths, verbatim code in fenced blocks, and an impact statement.
- A **Structural Summary** with the focus area analyzed, the 2-3 key concerns, any well-structured areas, and any dimensions that could not be fully assessed (for example, when git is unavailable for churn analysis).

## How to get the most out of it

- **Scope narrowly.** A single module produces sharp findings. A broad scope flattens into generic concerns.
- **Run with git available.** The agent uses `git log --since="90 days ago"` to identify high-churn modules. Without git, churn-based findings drop and the agent says so explicitly.
- **Pair with `behavioral-analyst` and `concurrency-analyst`.** The three analysts together cover static structure, runtime behavior, and concurrency. `/architectural-analysis` dispatches all three.
- **Feed findings into `risk-analyst`.** The agent's findings are the upstream input for risk prioritization.

## Cost and latency

The agent runs on `sonnet`. A focused-scope analysis runs in a couple of minutes. Built for per-module cadence, not tight-loop iteration.

## Sources

The agent's vocabulary and dimensions are grounded in established structural-analysis practice.

### Robert C. Martin: Stability Metrics

Martin's afferent / efferent coupling and Instability Index frame the agent's coupling analysis.

URL: https://blog.cleancoder.com/uncle-bob/2018/11/27/Comments-by-Tests.html

### Eric Evans: Domain-Driven Design

Evans's bounded-context and aggregate framings inform the agent's module-boundary findings inside a single codebase.

URL: https://www.domainlanguage.com/ddd/

### Martin Fowler: Refactoring Catalog

Fowler's catalog (Extract Class, Move Method, Inline Class) names the structural moves the agent surfaces.

URL: https://martinfowler.com/books/refactoring.html

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [Agents Index](../README.md). All agents, grouped by role.
- [`behavioral-analyst`](./behavioral-analyst.md). Sibling analyst for runtime behavior.
- [`concurrency-analyst`](./concurrency-analyst.md). Sibling analyst for concurrency hazards.
- [`risk-analyst`](./risk-analyst.md). Consumes this agent's findings for risk prioritization.
- [`software-architect`](./software-architect.md). Synthesizes findings into intra-codebase recommendations.
- [`/architectural-analysis`](../../skills/han.coding/architectural-analysis.md). Always dispatches this agent.
- [`/code-review`](../../skills/han.coding/code-review.md). Conditionally dispatches this agent when the change touches module boundaries.
- [`/plan-a-feature`](../../skills/han.core/plan-a-feature.md). Dispatches this agent as an opt-in specialist, included on request.
- [`/iterative-plan-review`](../../skills/han.core/iterative-plan-review.md). Conditionally dispatches this agent when the review covers module boundaries, coupling, or dependency direction.
- [`/plan-implementation`](../../skills/han.core/plan-implementation.md). Conditionally dispatches this agent when the plan covers module boundaries, coupling, or dependency direction.
