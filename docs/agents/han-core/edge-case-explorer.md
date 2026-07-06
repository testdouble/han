# edge-case-explorer

Operator documentation for the `edge-case-explorer` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han-core/agents/edge-case-explorer.md`](../../../han-core/agents/edge-case-explorer.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Systematically discovers edge cases that should be tested. Traces input sources, call chains, and integration boundaries. Catalogs boundary values, type coercion traps, external input messiness, state-dependent failures, and error-propagation gaps.
- **When to dispatch it.** You want a structured edge-case catalog for code, either before writing tests or as part of a broader test-planning pass. Always dispatched by `/test-planning`. Conditionally dispatched by `/code-review` for changes that introduce new entry points or external-data handling, by `/plan-a-feature` as part of the spec-stage team covering Outcome / Primary Flow / Alternate Flows / Edge Cases, by `/plan-implementation` as part of the implementation team, and by `/iterative-plan-review` in team mode.
- **What you get back.** An `edge-case-analysis.md` file with `EC#` items grouped by priority (Critical / High / Medium / Low), each tied to a specific input, code location, current handling state, and the risk if unhandled. Plus a Dropped Edge Cases section.

## Key concepts

- **Focused mode by default.** The agent invests investigation time in edge cases likely to cause crashes, data corruption, or systemic failures. Lower-severity items get noted in passing but not hunted. Request *"exhaustive exploration"* to flip into full-mode discovery across all six dimensions.
- **Six dimensions, used as a menu.** Boundary Values, External Input Messiness, Integration Boundaries, Type Coercion and Format, State Dependencies, Error Propagation. In focused mode, the agent picks dimensions that fit the code. In exhaustive mode, the agent walks all six against every input.
- **Trace inputs to the immediate caller, deeper at boundaries.** Internal function-to-function chains are trusted unless a clear external-data or type-coercion signal appears. Exhaustive mode traces to origin.
- **Code location per finding.** Every `EC#` cites the affected `file:line` and references the input it touches. Untraceable edge cases are dropped.
- **Discovers and catalogs, does not write tests.** Output is a prioritization plan. `test-engineer` or your team writes the tests.
- **`/code-review` adds a failure-mode-target dispatcher directive at Step 3.5.** When dispatched from `/code-review`, the skill appends an instruction that findings must ultimately trace to a failure mode in code on the scoped file list. That holds even when callers outside the file list provide the evidence for that failure mode. The agent's Protocol 1 caller-read still applies; the file-list scope is on the failure-mode target, not the evidence source. This is `/code-review`'s tailoring; the agent's general behavior outside `/code-review` is unchanged.

## When to use it

**Dispatch when:**

- `/test-planning` is running. The skill always dispatches this agent.
- `/code-review` flags changes that introduce new entry points, accept external input, or handle integration responses. The skill conditionally dispatches this agent.
- `/plan-a-feature` is assembling its spec-stage team, covering Outcome / Primary Flow / Alternate Flows / Edge Cases.
- `/plan-implementation` is assembling its implementation team.
- `/iterative-plan-review` is running in team mode.
- You want a structured pass to find what can go wrong with a specific function, endpoint, or integration before writing tests.
- A recently shipped feature is producing unexpected production behavior and you want to systematically catalog the input shapes that could trigger it.

**Do not dispatch for:**

- Overall test coverage planning. Use `test-engineer`. The edge-case explorer focuses on inputs and failure modes; `test-engineer` plans the test pyramid.
- Writing test code.
- Bug root-cause investigation. Use `evidence-based-investigator` or `/investigate`.
- Architectural analysis. Use the architectural analysts.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:edge-case-explorer`. Give it:

1. **A focus area.** Files, a function, an endpoint, or a small module. The narrower the scope, the sharper the edge cases.
2. **Exploration mode, optional.** Default is focused. Request *"exhaustive exploration"* explicitly to flip into full-mode discovery (more items, deeper coverage, higher cost).
3. **An output path, optional.** Default filename is `edge-case-analysis.md`.

Example prompts:

- *"Find edge cases for the new `/api/uploads` endpoint. It accepts multipart form data and writes to S3."*
- *"Exhaustive exploration of `src/parse/csv.ts`. We are about to ship this in production and want everything the parser could choke on."*

## What you get back

- An `edge-case-analysis.md` file on disk with:
  - **Scope.** Files and areas analyzed.
  - **Summary.** Same text returned to the caller.
  - **Input Source Map.** Table of inputs, origins, types, and validation status.
  - **Findings.** `EC#` items grouped by priority. Each includes priority, dimension, input, scenario, code location, current handling, expected behavior, and risk.
  - **Coverage Summary.** Totals, edge cases tested, edge cases handled but untested, edge cases with no handling and no tests, and dimensions that did not apply.
  - **Dropped Edge Cases.** Items explicitly excluded with reasons (often because they are physically impossible or framework-guaranteed).
- An in-channel summary with priority counts and the path to the file.

## How to get the most out of it

- **Pick the mode deliberately.** Focused mode is the default and the right choice for routine planning. Exhaustive mode is appropriate when production risk is high (parsers, security-sensitive endpoints, integrations with untrusted services).
- **Provide the input shape context.** If you know that a particular input is user-supplied vs. internal vs. from a trusted upstream service, say so. The Input Source Map sharpens.
- **Read the Dropped Edge Cases section.** It tells you what the agent considered and rejected. That signal often reveals where the agent was uncertain about the input space.
- **Pair with `test-engineer`.** Edge cases become test recommendations. `/test-planning` runs both in parallel.

## Cost and latency

The agent runs on `sonnet`. Focused mode runs in a couple of minutes for a focused scope. Exhaustive mode takes longer and produces a much larger output (often 2-3x the finding count). Use exhaustive mode deliberately.

## YAGNI

The agent enforces the **Speculative Edge Case** rule. These are YAGNI candidates:

- Edge cases for input shapes no real upstream produces.
- Code paths that don't exist yet.
- Hypothetical adversaries the code does not face.
- Boundary conditions only symmetry would surface (*"we covered the lower bound, so we should cover the upper bound"* when only one bound is reachable).

They move to Dropped Edge Cases with a named *reopen-when* trigger. When many speculative low-bound/high-bound items can be replaced by one durable boundary test that catches the realistic failure modes, the agent recommends the single test.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Sources

The agent's dimensions and vocabulary are grounded in software-testing literature.

### Cem Kaner et al.: Testing Computer Software

The classic taxonomy of boundary-value, equivalence-partition, and error-path testing underpins the agent's six dimensions.

URL: https://www.wiley.com/en-us/Testing+Computer+Software%2C+2nd+Edition-p-9780471358466

### Glenford Myers: The Art of Software Testing

Myers's framing of equivalence partitioning and boundary-value analysis is the citable reference for Dimension 3A.

URL: https://www.wiley.com/en-us/The+Art+of+Software+Testing%2C+3rd+Edition-p-9781118031964

### Joel Spolsky: The Joel Test (and Unicode)

Spolsky's article on Unicode and character encoding mistakes underpins the agent's type-coercion and serialization-round-trip checks.

URL: https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [YAGNI](../../yagni.md). The Speculative Edge Case rule.
- [Agents Index](../README.md). All agents, grouped by role.
- [`test-engineer`](./test-engineer.md). Sibling agent. `/test-planning` runs both in parallel.
- [`/test-planning`](../../skills/han-coding/test-planning.md). Always dispatches this agent.
- [`/code-review`](../../skills/han-coding/code-review.md). Conditionally dispatches this agent.
- [`/plan-a-feature`](../../skills/han-planning/plan-a-feature.md). Dispatches this agent as part of the spec-stage team, covering Outcome / Primary Flow / Alternate Flows / Edge Cases.
- [`/plan-implementation`](../../skills/han-planning/plan-implementation.md). Dispatches this agent as part of the implementation team.
- [`/iterative-plan-review`](../../skills/han-planning/iterative-plan-review.md). Dispatches this agent in team mode.
