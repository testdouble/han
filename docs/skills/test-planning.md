# /test-planning

Operator documentation for the `/test-planning` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`plugin/skills/test-planning/SKILL.md`](../../plugin/skills/test-planning/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** Produces a standalone test plan by analyzing code for coverage gaps and edge cases. Dispatches `test-engineer` and `edge-case-explorer` in parallel and adds `concurrency-analyst` or `adversarial-security-analyst` when the files touch those concerns, then merges all findings.
- **When to use it.** You want a prioritized test plan for a branch, a directory, or specific files, without running a full code review.
- **What you get back.** A unified test plan with up to 40 items tagged CRIT / HIGH / MED / LOW, each with `file:line` references, test approach, code paths, and risk assessment.

## Key concepts

- **Two always-on agents plus two conditional.** `test-engineer` analyzes coverage gaps (observable behaviors, inputs, outputs, collaborator interactions). `edge-case-explorer` discovers boundary values, type coercion traps, state-dependent failures, and error propagation gaps. `concurrency-analyst` joins when the files touch threads/async/shared state, to surface race and lock-ordering tests. `adversarial-security-analyst` joins when the files touch auth, input handling, isolation, crypto, uploads, or SQL/ORM, to surface negative security tests. Security items land as CRIT and are exempt from the 40-item cap.
- **Four-tier priority scheme.** CRIT (security, data integrity, auth), HIGH (business logic, error handling), MED, LOW. Classification comes from both agents' rankings mapped into a unified scheme.
- **Unified IDs with cross-reference.** `TP-001`, `TP-002`, … with the original agent ID recorded (for example, *"TP-001 (from T3)"*).
- **Three review modes.** Mode A (full git context, branch vs default), Mode B (uncommitted/staged changes), Mode C (no git, glob-discovered files).
- **Plan, not test code.** The skill does not write tests. It produces a plan describing what to test, how, and at what level.

## When to use it

**Invoke when:**

- You want a prioritized test plan for a branch, a directory, or specific files, independent of a full code review.
- You finished an implementation plan and want a test plan scoped to what you are about to build.
- A code review flagged coverage gaps and you want those gaps expanded into a concrete list of tests to write.
- You want the edge-case dimension covered specifically (boundary values, type coercion, error propagation) rather than only the coverage dimension.

**Do not invoke for:**

- **Full code review.** Use [`/code-review`](./code-review.md) for correctness, testing, and compliance.
- **Iterating on an existing test plan.** Use [`/iterative-plan-review`](./iterative-plan-review.md) for multi-pass refinement of a written plan.
- **Writing test code.** This skill produces a plan only. Write the tests separately.
- **Architectural testability analysis.** Use [`/architectural-analysis`](./architectural-analysis.md) for structural testability concerns.

## How to invoke it

Run `/test-planning` in Claude Code. Optionally pass a scope or a focus description.

Give it:

1. **Scope.** File paths, directories, or a description of what should be tested. Without arguments, the skill uses the current branch's changed files (Mode A/B) or Glob-discovers source files (Mode C).
2. **A focus description, optional.** *"Plan tests for the payment processing refactor I just finished."* The description reaches both agents and sharpens their analysis.

Example prompts:

- `/test-planning`. Create a test plan for the current branch's changes.
- `/test-planning src/auth/`. Create a test plan scoped to the auth directory.
- `/test-planning`. *"Plan tests for the payment processing refactor I just finished."*
- `/test-planning src/billing/invoice.ts src/billing/tax.ts`. Focus on two specific files.

## What you get back

A structured test plan in-channel:

- **Scope.** Scope type, file count, branch, language, test framework, file list.
- **Test Plan.** Up to 40 items, grouped by priority tier (CRIT, HIGH, MED, LOW). Each item has a unified ID (TP-NNN), the original agent cross-reference, a clear description of what to test, test approach, code paths, file:line references, and risk assessment.
- **Deferred Tests.** Items `test-engineer` excluded because brittleness risk outweighed value, with reasons.
- **Dropped Edge Cases.** Items `edge-case-explorer` intentionally excluded, with reasons.
- **Coverage Summary.** Counts by priority tier and a qualitative assessment of overall coverage.

If more than 40 items exist, the skill notes how many were omitted and recommends a re-run after the highest-priority items land.

## How to get the most out of it

- **Scope narrowly.** A tightly scoped run produces sharper items than a broad sweep. For a medium branch, scoping to specific files or subdirectories pays off.
- **Run `/project-discovery` first.** The skill uses the discovery reference for test command, language, and test framework. Without it, framework detection falls back to inference.
- **Ask for exhaustive exploration if the risk is high.** Mention *"exhaustive edge-case exploration"* in your prompt and the `edge-case-explorer` agent shifts from focused to exhaustive mode. More items, deeper coverage, higher cost.
- **Pair with `/code-review`** when you want coverage gaps *and* correctness findings. `/code-review` dispatches the same two agents plus `adversarial-security-analyst`, classified into the review output.
- **Re-run after fixes.** Once high-priority items are addressed, re-run for the next batch.

## Cost and latency

The skill dispatches two always-on agents (`test-engineer`, `edge-case-explorer`) plus up to two conditional agents (`concurrency-analyst`, `adversarial-security-analyst`) in parallel, all on their default models. Typical runs are a few minutes. The 40-item cap keeps non-security output bounded; security items are uncapped, and dropped items are surfaced explicitly so nothing is quietly omitted.

## In more detail

The skill walks a four-step process:

1. **Determine scope.** Resolve project config; detect git mode (A/B/C) via `detect-test-context.sh`; build a file list.
2. **Dispatch testing agents.** Launch `test-engineer` and `edge-case-explorer` always. Add `concurrency-analyst` when the file list touches async or shared state. Add `adversarial-security-analyst` when it touches auth, input handling, isolation, crypto, uploads, or SQL/ORM. All run in parallel in the background. The skill waits for every dispatched agent.
3. **Merge and prioritize.** Classify findings into the four-tier priority scheme (security items auto-CRIT). Assign unified IDs. Interleave by priority. Cap non-security items at 40.
4. **Generate output.** Fill the template at [`references/template.md`](../../plugin/skills/test-planning/references/template.md) with scope, test plan, deferred, dropped, and coverage summary.

## YAGNI

A YAGNI sweep runs over the proposed test plan before it is committed. Tests for code paths that don't exist yet, hypothetical adversaries the change doesn't touch, branches that internal callers fully control, or coverage of all enum values when only one is reachable are YAGNI candidates and move to the plan's `## Deferred (YAGNI)` section. The Speculative Test rule (enforced by `test-engineer`) and the Speculative Edge Case rule (enforced by `edge-case-explorer`) catch the most common shapes: symmetry-driven coverage, defensive tests at trusted internal boundaries, and tests that exist only because *best practice says you should test that*.

See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.

## Sources

The skill's practice is grounded in established testing-strategy and risk-based testing literature.

### Michael Feathers: Working Effectively with Legacy Code

Feathers's work on seams and observable behavior underlies the `test-engineer` agent's orientation toward inputs, outputs, and collaborator interactions rather than internal code paths.

URL: https://www.oreilly.com/library/view/working-effectively-with/0131177052/

### Kent Beck: Test-Driven Development: By Example

Beck's work on test-driven design and the boundary between unit and collaborator tests grounds the skill's four-tier priority scheme. Critical-path behavior is tested first, error handling second, edge cases next, cosmetics last.

URL: https://www.pearson.com/en-us/subject-catalog/p/test-driven-development-by-example/P200000009421

### Cem Kaner et al.: Testing Computer Software

The classic taxonomy of boundary-value, equivalence-partition, and error-path testing underlies the `edge-case-explorer` agent's category rubric.

URL: https://www.wiley.com/en-us/Testing+Computer+Software%2C+2nd+Edition-p-9780471358466

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies before committing items. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Skills Index](./README.md). All 18 skills, grouped by purpose.
- [`/code-review`](./code-review.md). Dispatches the same agents plus `adversarial-security-analyst`. Use when you want correctness findings too.
- [`/architectural-analysis`](./architectural-analysis.md). For structural testability concerns.
- [`/iterative-plan-review`](./iterative-plan-review.md). Use to stress-test an already-written test plan.
- [`test-engineer`](../agents/test-engineer.md), [`edge-case-explorer`](../agents/edge-case-explorer.md). Always dispatched.
- [`concurrency-analyst`](../agents/concurrency-analyst.md). Dispatched when the file list touches async, threads, or shared state.
- [`adversarial-security-analyst`](../agents/adversarial-security-analyst.md). Dispatched when the file list touches auth, input handling, isolation, crypto, uploads, or SQL/ORM.
- [`SKILL.md` for /test-planning](../../plugin/skills/test-planning/SKILL.md). The internal process definition.
