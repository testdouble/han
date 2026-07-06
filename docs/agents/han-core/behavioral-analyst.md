# behavioral-analyst

Operator documentation for the `behavioral-analyst` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han-core/agents/behavioral-analyst.md`](../../../han-core/agents/behavioral-analyst.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md)

## TL;DR

- **What it does.** Analyzes the runtime behavior of a specified codebase focus area: data flow, error propagation, state management, and integration boundaries. Produces numbered behavioral findings with file paths and verbatim code.
- **When to dispatch it.** You want a principled runtime-behavior pass on a module or focus area, independent of static structure or concurrency. Always dispatched by `/architectural-analysis`. Conditionally dispatched by `/code-review`. Dispatched by `/investigate` when the symptom matches a data-flow or error-propagation bug. Dispatched by `/plan-implementation` by signal when plan sections describe runtime behavior, data flow, error propagation, or state. Conditionally dispatched by `/iterative-plan-review` when the review covers runtime behavior, data flow, error propagation, or state. Dispatched by `/plan-a-feature` by signal when the feature specification touches runtime behavior, data flow, error propagation, or state.
- **What you get back.** Numbered `B#` findings, each tied to a behavioral dimension (Data Flow / Error Propagation / State Management / Integration Boundaries), file paths, verbatim code, and an impact statement.

## Key concepts

- **Runtime, not static.** The agent traces what the code does when it runs. Static structure (imports, file organization, coupling) is deferred to `structural-analyst`. Concurrency hazards are deferred to `concurrency-analyst`.
- **Four dimensions, all required.** Data Flow, Error Propagation, State Management, Integration Boundaries. Skipping a dimension makes the analysis incomplete.
- **Error paths are not optional.** The agent walks try/catch blocks, error returns, and failure paths explicitly. Happy-path-only analysis is an anti-pattern.
- **Implicit state counts.** Closures, module-level singletons, memoization caches, and thread-local state are flagged alongside explicit variables and databases.
- **Discovers findings, does not synthesize.** Recommendations belong to `software-architect`. Risk assessment belongs to `risk-analyst`. Bug investigation belongs to `evidence-based-investigator`.
- **`/code-review` adds a default-SUGG dispatcher directive at Step 3.5.** When dispatched from `/code-review`, the skill appends an instruction to default the severity of every finding to SUGG. It escalates to WARN or CRIT only when the change actively introduces or worsens the issue. This is `/code-review`'s tailoring; the agent's general behavior outside `/code-review` is unchanged. Other callers (`/architectural-analysis`, `/investigate`) receive the agent's default skeptical posture.

## When to use it

**Dispatch when:**

- `/architectural-analysis` is running. The agent is one of the three parallel analysts the skill always dispatches.
- `/code-review` flags data-flow or error-handling concerns in the file list.
- `/investigate` matches the symptom to a data-flow or error-propagation bug. The skill dispatches this agent alongside the investigators.
- You suspect an error is being swallowed silently somewhere in a module and want a structured pass to find it.
- You are about to refactor a state-heavy module and want a behavioral baseline first.

**Do not dispatch for:**

- Static structure, coupling, module boundaries. Use `structural-analyst`.
- Concurrency hazards. Use `concurrency-analyst`.
- Specific bug root cause. Use `evidence-based-investigator` or `/investigate`.
- Risk prioritization. Use `risk-analyst` (which consumes this agent's findings).
- Architectural recommendations. Use `software-architect`.
- Cross-service or bounded-context changes. Use `system-architect`.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:behavioral-analyst`. Give it a focus area (module, directory, or set of files). The agent traces runtime behavior plus one layer outward in each direction.

Example prompts:

- *"Trace data flow and error propagation through `src/orders/`. We've seen recent reports of orders silently failing to update inventory."*
- *"Examine `packages/payments/` for state management and integration boundaries. The team suspects implicit state is causing test flakiness."*

## What you get back

- Numbered `B#` findings, each with: dimension (Data Flow / Error Propagation / State Management / Integration Boundaries), relevant file paths, verbatim code in fenced blocks, and an impact statement.
- A **Behavioral Summary** with the focus area analyzed, the 2-3 key concerns, any well-handled areas, and any dimensions that could not be fully assessed.

## How to get the most out of it

- **Name the suspected concern.** *"Error propagation around the retry queue"* or *"state management in the session handler"* focuses the agent's attention while keeping all four dimensions in scope.
- **Provide entry points.** If you know where user input or external events enter the module, name them. The data-flow trace starts there.
- **Pair with `structural-analyst` and `concurrency-analyst`.** The three analysts together cover the full architectural picture. `/architectural-analysis` dispatches all three.
- **Read the negative results.** The agent reports areas where behavior is sound. That signal helps prioritize the remaining concerns.

## Cost and latency

The agent runs on `sonnet`. A focused-scope analysis runs in a couple of minutes. Built for per-module cadence.

## Sources

The agent's vocabulary and dimensions are grounded in established behavioral-analysis practice.

### Gregor Hohpe: Enterprise Integration Patterns

Hohpe and Woolf's pattern catalog frames the agent's integration-boundary findings (Message Channel, Translator, Endpoint, Dead Letter, Circuit Breaker).

URL: https://www.enterpriseintegrationpatterns.com/

### Michael Nygard: Release It!

Nygard's stability patterns (circuit breaker, bulkhead, timeout, fail-fast) underpin the agent's analysis of failure handling at integration boundaries.

URL: https://pragprog.com/titles/mnee2/release-it-second-edition/

### Martin Fowler: Two Hard Things (caching, naming, off-by-one)

Fowler's catalog of subtle behavioral pitfalls informs the agent's State Management and Error Propagation dimensions.

URL: https://martinfowler.com/bliki/TwoHardThings.html

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [Agents Index](../README.md). All agents, grouped by role.
- [`structural-analyst`](./structural-analyst.md). Sibling analyst for static structure.
- [`concurrency-analyst`](./concurrency-analyst.md). Sibling analyst for concurrency hazards.
- [`risk-analyst`](./risk-analyst.md). Consumes this agent's findings.
- [`software-architect`](./software-architect.md). Synthesizes findings into recommendations.
- [`/architectural-analysis`](../../skills/han-coding/architectural-analysis.md). Always dispatches this agent.
- [`/investigate`](../../skills/han-coding/investigate.md). Dispatches this agent for data-flow and error-propagation bugs.
- [`/code-review`](../../skills/han-coding/code-review.md). Conditionally dispatches this agent.
- [`/plan-implementation`](../../skills/han-planning/plan-implementation.md). Dispatches this agent by signal when plan sections describe runtime behavior, data flow, error propagation, or state.
- [`/iterative-plan-review`](../../skills/han-planning/iterative-plan-review.md). Conditionally dispatches this agent when the review covers runtime behavior, data flow, error propagation, or state.
- [`/plan-a-feature`](../../skills/han-planning/plan-a-feature.md). Dispatches this agent by signal when the feature specification touches runtime behavior, data flow, error propagation, or state.
