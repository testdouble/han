# test-engineer

Operator documentation for the `test-engineer` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/test-engineer.md`](../../../han.core/agents/test-engineer.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Examines code and plans tests focused on observable behavior (inputs, outputs, collaborator interactions). Recommends test doubles (stubs for queries, mock expectations for commands) for isolation. Produces a prioritized test plan tied to specific entry points.
- **When to dispatch it.** You want a prioritized test plan for new or existing code. Always dispatched by `/test-planning` and included in the default spec-stage roster of `/plan-a-feature`. Conditionally dispatched by `/code-review` when the file list suggests coverage gaps. Conditionally dispatched by `/plan-implementation` for the implementation plan's testing strategy. Available as a specialist in `/iterative-plan-review` spec mode.
- **What you get back.** A `test-plan.md` with `T#` recommendations, each citing an entry point with `file:line`, a test level (unit / integration / end-to-end), test approach (behavior, stubs, input/action, expected output, expected commands), and a brittleness assessment. Plus a Deferred section for tests where brittleness outweighs value.

## Key concepts

- **Behavioral testing is the default, not a preference.** Tests verify observable behavior through inputs/outputs and collaborator interactions, not internal code paths.
- **Command-query separation drives doubles.** Stub queries (dependencies that return values). Mock expectations on commands (collaborators that receive side effects). The agent classifies each interaction explicitly.
- **Entry point per recommendation.** Every test recommendation references a specific function, method, or endpoint with `file:line`. No vague suggestions.
- **Brittleness has a cost.** Tests that break on every refactor and catch bugs rarely are net-negative. The agent defers tests when the brittleness risk outweighs the value.
- **Existing patterns first.** New tests must match the project's existing framework, naming, and helper conventions. If no tests exist, the agent recommends the framework and structure based on the project's language and ecosystem before listing test cases.

## When to use it

**Dispatch when:**

- `/test-planning` is running. The skill always dispatches this agent.
- `/code-review` flags coverage gaps in the changed files. The skill dispatches this agent.
- `/plan-implementation` is producing the implementation plan's testing strategy. The skill dispatches this agent.
- `/plan-a-feature` is running. The agent is included in its default spec-stage roster.
- `/iterative-plan-review` is running in spec mode. The agent is available as a specialist.
- You want a structured test plan for a single module or feature without running a full review.

**Do not dispatch for:**

- Deep edge-case exploration (boundary values, type-coercion traps, state-dependent failures). Use `edge-case-explorer`.
- Architectural testability concerns. Use `/architectural-analysis`.
- Writing test code. The agent produces a plan only.
- Bug investigation. Use `evidence-based-investigator` or `/investigate`.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:test-engineer`. Give it:

1. **A focus area.** Files, a directory, or a feature description. The narrower the scope, the sharper the plan.
2. **Project context, optional.** If the project's test framework and conventions are not obvious from the existing tests, mention them.
3. **An output path, optional.** Default filename is `test-plan.md`.

Example prompts:

- *"Plan tests for `src/billing/invoice.ts`. We just refactored the proration logic and added a credit-application path."*
- *"Audit test coverage in `packages/auth/` and recommend new tests. Focus on the OAuth-state validation we just added."*

## What you get back

- A `test-plan.md` file on disk with:
  - **Scope.** Files and areas analyzed.
  - **Summary.** Same text returned to the caller.
  - **Coverage Assessment.** Qualitative summary of current behavioral coverage.
  - **Findings.** `T#` recommendations ordered by priority. Each includes priority, test level (unit / integration / end-to-end), entry point with `file:line`, gap type (Untested / Partially tested), full test approach (behavior, stubs, input/action, expected output, expected commands), and a brittleness assessment.
  - **Deferred / Skipped Tests.** `S#` entries explaining why brittleness outweighs value.
  - **Coverage Estimate.** Expected behavioral coverage after recommended tests are written.
- An in-channel summary with priority counts and the path to the file.

## How to get the most out of it

- **Provide focus.** The agent's test plans are sharper on a narrow scope. *"The proration refactor"* beats *"the billing module."*
- **Point at the existing tests.** Even one example test file is enough to lock in the project's conventions. The agent prefers to match the existing pattern.
- **Read the Deferred section.** The skipped tests are first-class output. They tell you what brittleness risk the agent saw and avoided.
- **Pair with `edge-case-explorer`** when boundary values and failure modes matter. `/test-planning` runs both in parallel.
- **Re-run after the first wave of tests lands.** The agent is cheap to re-dispatch. Once the high-priority items are tested, the next pass surfaces what remained partially covered.

## Cost and latency

The agent runs on `sonnet`. A focused test-planning pass runs in a few minutes. Cost scales with the size of the existing test suite (the agent reads it to learn conventions).

## YAGNI

The agent enforces the **Speculative Test** rule. Tests for code paths that don't exist yet, hypothetical adversaries the change does not touch, branches that internal callers fully control, or symmetry/completeness coverage (*"we tested create, so we should test delete"* when delete isn't implemented) are YAGNI candidates. They move to Deferred / Skipped Tests with a named *reopen-when* trigger. When many speculative low-level tests can be replaced by one durable behavioral test that catches the same realistic failure modes, the agent recommends the single test.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Sources

The agent's posture is grounded in behavioral testing practice.

### Michael Feathers: Working Effectively with Legacy Code

Feathers's framing of seams and observable behavior underpins the agent's bias toward testing inputs, outputs, and collaborator interactions rather than internal paths.

URL: https://www.oreilly.com/library/view/working-effectively-with/0131177052/

### Kent Beck: Test-Driven Development: By Example

Beck's TDD framing and his distinction between unit and collaborator tests inform the agent's test-level selection.

URL: https://www.pearson.com/en-us/subject-catalog/p/test-driven-development-by-example/P200000009421

### Steve Freeman, Nat Pryce: Growing Object-Oriented Software, Guided by Tests

The London-school testing tradition (test doubles by command-query separation, mock expectations on commands, stubs on queries) is the agent's vocabulary for isolation.

URL: http://www.growing-object-oriented-software.com/

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [YAGNI](../../yagni.md). The Speculative Test rule.
- [Agents Index](../README.md). All agents, grouped by role.
- [`edge-case-explorer`](./edge-case-explorer.md). Sibling agent for boundary values and failure modes. `/test-planning` runs both in parallel.
- [`/test-planning`](../../skills/han.core/test-planning.md). Always dispatches this agent.
- [`/code-review`](../../skills/han.core/code-review.md). Conditionally dispatches this agent.
- [`/plan-implementation`](../../skills/han.core/plan-implementation.md). Dispatches this agent for the implementation plan's testing strategy.
- [`/plan-a-feature`](../../skills/han.core/plan-a-feature.md). Includes this agent in its default spec-stage roster.
- [`/iterative-plan-review`](../../skills/han.core/iterative-plan-review.md). Makes this agent available as a specialist in spec mode.
