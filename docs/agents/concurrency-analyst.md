# concurrency-analyst

Operator documentation for the `concurrency-analyst` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`plugin/agents/concurrency-analyst.md`](../../plugin/agents/concurrency-analyst.md).

> See also: [Plugin landing page](../../README.md) · [All agents](./README.md) · [All skills](../skills/README.md)

## TL;DR

- **What it does.** Analyzes concurrency and async patterns in a specified codebase focus area: race conditions, shared resource contention, deadlock potential, lock ordering, and async error handling. Produces numbered concurrency findings with file paths and verbatim code.
- **When to dispatch it.** A focus area uses threads, async, parallel execution, or shared mutable state. Always dispatched by `/architectural-analysis`. Conditionally dispatched by `/code-review`, `/test-planning`, and `/investigate` when the symptom matches a concurrency bug.
- **What you get back.** Numbered `C#` findings, each tied to a concurrency dimension (Race Conditions / Resource Contention / Deadlock / Async Errors / Synchronization), file paths, verbatim code, and a concrete failure-scenario description. Or an explicit *"no concurrency patterns found"* report when none apply.

## Key concepts

- **Initial detection first.** The agent checks whether the focus area uses concurrency patterns at all (async/await, threads, goroutines, channels, locks, atomics, parallel execution). If none are present, it reports that and stops. No fabricated findings.
- **Five dimensions when patterns are present.** Race Conditions, Shared Resource Contention, Deadlock Potential, Async Error Handling, Lock Ordering and Synchronization.
- **Failure scenarios are concrete.** Every finding describes the sequence of operations that produces the failure: which interleaving, which check-then-act, which lock-ordering inversion. *"Could race"* is not enough.
- **Async vs threaded matters.** The agent distinguishes single-threaded async (JavaScript event loop, single-process async) from multi-threaded concurrency. A race condition claim on single-threaded async code without shared mutable state between microtasks is an anti-pattern.
- **Discovers findings, does not synthesize.** Recommendations belong to `software-architect`. Risk assessment belongs to `risk-analyst`. Bug investigation belongs to `evidence-based-investigator`.

## When to use it

**Dispatch when:**

- `/architectural-analysis` is running. The agent is one of the three parallel analysts the skill always dispatches.
- `/code-review` flags files that touch threads, async, or shared state.
- `/test-planning` needs negative tests for race conditions or lock-ordering inversions.
- `/investigate` matches the symptom to intermittent / race / timeout bugs. The skill dispatches this agent alongside the investigators.
- You suspect a deadlock or race in a module but cannot point at the specific interleaving.
- You are about to introduce parallelism (worker pool, fan-out, async queue) and want a baseline pass.

**Do not dispatch for:**

- Static structure or coupling. Use `structural-analyst`.
- Sequential data flow or error propagation. Use `behavioral-analyst`.
- Specific bug root cause. Use `evidence-based-investigator` or `/investigate`.
- Risk prioritization. Use `risk-analyst`.
- Architectural recommendations. Use `software-architect`.
- Cross-service distributed coordination (sagas, idempotency at the wire, distributed locks). Use `system-architect`.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han:concurrency-analyst`. Give it a focus area (module, directory, or set of files). The agent first detects whether concurrency patterns exist; if they do, it runs the five-dimension analysis.

Example prompts:

- *"Audit `src/jobs/` for concurrency hazards. The retry queue handler uses goroutines and a shared cache."*
- *"Examine `packages/realtime/` for race conditions and deadlock potential. We're seeing intermittent connection-pool exhaustion in production."*

## What you get back

- Either an explicit *"no concurrency patterns found"* report with a list of what was searched, or:
- Numbered `C#` findings, each with: dimension (Race Conditions / Resource Contention / Deadlock / Async Errors / Synchronization), relevant file paths, verbatim code in fenced blocks, and a concrete failure-scenario description.
- A **Concurrency Summary** with the focus area analyzed, the concurrency model in use, the 2-3 key concerns, any well-handled areas, and any dimensions that were not applicable.

## How to get the most out of it

- **Name the suspected pattern.** *"Race around the retry queue"* or *"deadlock potential in the connection pool"* focuses the agent while keeping all five dimensions in scope.
- **Provide reproduction context.** If the symptom is intermittent, mention the conditions (load, timing, specific operations). The failure-scenario descriptions get sharper.
- **Pair with `behavioral-analyst`** when error propagation is also in question. Async error handling crosses both agents' dimensions.
- **Pair with `system-architect`** when the concurrency concern crosses a service boundary (distributed locks, saga coordination, idempotency at the wire).
- **Trust the "no concurrency patterns" report.** When the agent says there are none, it lists what it searched for. That is a valid result, not a missed analysis.

## Cost and latency

The agent runs on `sonnet`. A focused-scope analysis runs in a couple of minutes. The agent stops early when no concurrency patterns are found, which is the cheapest possible run.

## Sources

The agent's vocabulary and dimensions are grounded in established concurrency-analysis practice.

### Doug Lea: Concurrent Programming in Java

Lea's taxonomy of shared-state concurrency hazards (races, deadlocks, starvation, live-lock, priority inversion) is the canonical reference for the agent's Race Conditions and Deadlock Potential dimensions.

URL: https://gee.cs.oswego.edu/dl/cpj/

### Maurice Herlihy, Nir Shavit: The Art of Multiprocessor Programming

The formal treatment of memory ordering, lock-free algorithms, and compare-and-swap semantics underpins the agent's Synchronization findings.

URL: https://shop.elsevier.com/books/the-art-of-multiprocessor-programming/herlihy/978-0-12-415950-1

### Rob Pike: Concurrency is not Parallelism

Pike's distinction informs the agent's check on whether the focus area uses true parallelism or single-threaded concurrency, and frames the async-vs-threaded anti-pattern.

URL: https://go.dev/talks/2012/waza.slide

## Related documentation

- [Plugin landing page](../../README.md). The front door.
- [Agents Index](./README.md). All 23 agents, grouped by role.
- [`structural-analyst`](./structural-analyst.md). Sibling analyst for static structure.
- [`behavioral-analyst`](./behavioral-analyst.md). Sibling analyst for runtime behavior.
- [`risk-analyst`](./risk-analyst.md). Consumes this agent's findings.
- [`software-architect`](./software-architect.md). Synthesizes findings into recommendations.
- [`system-architect`](./system-architect.md). Sibling for cross-service distributed coordination concerns.
- [`/architectural-analysis`](../skills/architectural-analysis.md). Always dispatches this agent.
- [`/code-review`](../skills/code-review.md), [`/test-planning`](../skills/test-planning.md), [`/investigate`](../skills/investigate.md). Conditionally dispatch this agent based on file signals.
