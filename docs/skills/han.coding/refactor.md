# /refactor

Operator documentation for the `/refactor` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.coding/skills/refactor/SKILL.md`](../../../han.coding/skills/refactor/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Restructures existing code without changing its behavior, through a test-gated loop: a named target, a green suite before any edit, a planned sequence of small named refactorings, and the full suite re-run after every step.
- **When to use it.** You have existing code that needs restructuring (a review finding, duplication, a module that fights every change) and you want it done with behavior-preservation discipline instead of a one-shot rewrite.
- **What you get back.** Restructured code in your tree, plus a summary naming each refactoring applied, the evidence it rested on, what was deferred and why, and the final test, lint, and build output.

## Key concepts

- **Execution skill.** Like [`/tdd`](./tdd.md), this skill modifies your source tree rather than producing a document. It is the second of the two execution skills in `han.coding`.
- **Behavior preservation is the definition.** A refactoring changes structure, never observable behavior. A step that turns out to require a behavior change is deferred, not absorbed; a step that reddens the suite is reverted, not patched forward.
- **Tests are the license.** The skill refuses to start until the full suite is green and the target's behavior is covered. An uncovered target gets a choice: narrow the scope, or write characterization tests first (explicitly labeled as a lower-confidence net).
- **Named targets, never "clean this up".** The skill requires a named target: files, a module, a named smell, or the findings of a prior review. Open-ended cleanup requests get asked to name one, because both the refactoring literature and the empirical record on coding agents show open-ended runs identify few real opportunities and tend to make structure worse.
- **The declared scope is a contract.** Each planned step declares its blast radius. A step that spreads beyond it triggers a stop-and-report, because spreading edits are how a refactoring silently becomes a rewrite.

## When to use it

**Invoke when:**

- A [`/code-review`](../han.core/code-review.md) or [`/architectural-analysis`](../han.core/architectural-analysis.md) run produced refactoring recommendations you want executed.
- A named area of existing code needs restructuring: duplication to remove, a function to break up, a module whose coupling fights every change you make near it.
- You are about to build in a messy area and want preparatory refactoring first ("make the change easy, then make the easy change"), before driving the feature with `/tdd`.

**Do not invoke for:**

- **Cleanup inside an active TDD cycle.** The refactor step of [`/tdd`](./tdd.md) owns that; this skill refuses to run alongside a red-green loop in flight.
- **Finding out what to refactor.** Use [`/code-review`](../han.core/code-review.md) or [`/architectural-analysis`](../han.core/architectural-analysis.md) to produce the findings; this skill executes them.
- **Fixing a bug.** A fix changes behavior, which this skill never does. Use [`/investigate`](../han.core/investigate.md) and then drive the fix in with [`/tdd`](./tdd.md).
- **Building new behavior.** Use [`/tdd`](./tdd.md).

## How to invoke it

Run `/refactor` in Claude Code.

Give it:

1. **A named target.** Files or directories, a named smell in a named place ("the duplicated validation in `lib/billing/`"), or a path to a review report whose refactoring findings you want applied. A sharp target names both the place and the reason. The skill will not accept "clean up the codebase"; it asks for a target instead.
2. **Optionally, the source findings.** When you pass a `/code-review` or `/architectural-analysis` report, the skill extracts the refactoring-shaped findings and traces each applied change back to its finding ID in the summary.
3. **Nothing about the test framework.** The skill resolves test, lint, build, and type-check commands from your project the same way `/tdd` does.

The skill runs autonomously after your initial request: it reports the plan and proceeds. It stops and waits only when (a) the target has no test coverage (you choose: narrow the target or write characterization tests first), (b) the suite is red before it starts, (c) the request was open-ended with no named target, or (d) you explicitly asked to approve the plan first. Stop rules during the run (scope spread, a step that requires a behavior change, two consecutive reverted steps) end with a report of where things stand; everything already applied is green and stands.

Example prompts:

- `/refactor`. *"Apply the structural findings from docs/reviews/code-review-billing.md."*
- `/refactor`. *"Extract the duplicated retry logic in `lib/http/` into one place."*
- `/refactor`. *"I'm about to add multi-currency support to `PriceCalculator`; do the preparatory refactoring so that change is easy."*

## What you get back

Restructured code in your working tree, not a report. Specifically:

- **A refactoring plan**, shown before the first edit: numbered items, each one named refactoring with the evidence behind it and the files it should touch.
- **One verified step at a time.** Each step shows the runner's summary line after the change. Red steps are reverted and either retried smaller or deferred with what was learned.
- **A final summary**: each refactoring applied (named, with its evidence and finding IDs where a report was the source), YAGNI deferrals with reopen triggers, items deferred because they required behavior changes, anything spotted but deliberately left alone (bugs, out-of-scope smells, fodder for `/issue-triage`), the standards and ADRs the code now conforms to, and the final test, lint, and build output shown rather than asserted.

## How to get the most out of it

- **Feed it review findings.** The strongest input is a `/code-review` or `/architectural-analysis` report: the evidence gate is already satisfied, the targets are already named, and the summary traces back to finding IDs.
- **Run it before a feature, not after a deadline.** Preparatory refactoring tied to upcoming work is the most economically justified workflow in the refactoring literature. "We'll clean it up someday" sessions are where scope creep lives.
- **Keep targets small and run it often.** The empirical record favors conservative, tightly scoped passes over aggressive sweeps. Several small runs beat one big one.
- **Take the coverage stop seriously.** When the skill says the target is uncovered, that is the load-bearing safety check, not friction. Characterization tests prove "unchanged", not "correct"; narrowing the target is often the better choice.
- **Commit as you go.** Ask for commits and you get one refactor-only commit per green step or logical group, which keeps the diff reviewable and the feature work separable.
- **Pair with `/tdd` next.** Preparatory refactoring done, drive the actual behavior change in with [`/tdd`](./tdd.md).

## YAGNI

`/refactor` applies the YAGNI evidence gate to its own plan. Every planned refactoring needs evidence the code has a reason to change: a review finding, named duplication, a standard or ADR it brings the code into conformance with, a documented confusing read, or upcoming work in that area. Restructuring to taste, speculative abstraction, configuration knobs nobody sets, and indirection "for flexibility" are the named anti-patterns; items without evidence are deferred with a reopen trigger, never silently dropped and never silently applied. The rule is enforcing (defer by default), and the deferrals appear in the final summary. See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the deferral format.

## Cost and latency

`/refactor` runs on the main agent and dispatches no sub-agents; it is not a sizing-aware skill. The cost is the verification loop: the full test suite (plus type check where one exists) runs once up front and once after every step, so total cost is roughly plan length multiplied by suite runtime. The most expensive single factor is your suite's runtime. This is a tight-loop skill built for small, frequent runs; keeping the target narrow is the main cost lever.

## In more detail

The skill fills a specific gap in the suite. [`/code-review`](../han.core/code-review.md) and [`/architectural-analysis`](../han.core/architectural-analysis.md) recommend refactorings but never modify code; the refactor step of [`/tdd`](./tdd.md) modifies code but is deliberately scoped to what the current red-green cycle touched. Nothing executed a refactoring recommendation against existing code with safety discipline. This skill is that executor, which is why it deliberately does no analysis of its own: it consumes findings (or a user-named target) rather than dispatching analyst agents to discover them.

The workflow shape (named target, plan before edit, small steps, verification after each, hard stop rules) is not style preference. It tracks the strongest converging evidence in both literatures: practitioner consensus from Fowler, Feathers, and Beck on behavior preservation, test gates, and scope control, and the 2024-2026 empirical studies of coding agents showing that named targets dramatically outperform open-ended prompts, that incremental verification loops are the most reliable correctness improver, and that conservative scope beats aggressive sweeps. The research behind the design, including the adversarial validation of it, is recorded in [docs/research/refactor-skill-research.md](../../research/refactor-skill-research.md).

The honest limitations, in the same spirit as `/tdd`'s. The green-suite-first gate is enforced by discipline and shown evidence (pasted runner output, stop rules), not by a mechanism that can physically prevent an edit; if you watch one thing, watch that the suite output before the first edit is real and green. The refactor-only-commit guardrail is established human practice whose effectiveness as an agent instruction is not independently validated, which is exactly why the skill pairs it with per-step verification rather than relying on it. And a passing suite proves the behaviors your tests exercise are unchanged, not that all behavior is; coverage of the target is the gate precisely because the guarantee is only as wide as the net.

## Sources

The skill's protocols and vocabulary are grounded in the refactoring literature and the empirical record on agent-driven refactoring. Each source is cited because the skill draws a specific, named artifact from it. The full evidence trail with validation is in [docs/research/refactor-skill-research.md](../../research/refactor-skill-research.md).

### Martin Fowler, *Refactoring: Improving the Design of Existing Code*, 2nd ed. 2018; refactoring.com; bliki

The definition of refactoring, the catalog of named refactorings the plan vocabulary comes from, the two-hats rule, the workflows (preparatory, comprehension, litter-pickup), and the never-broken-for-more-than-minutes test.

URL: https://refactoring.com/catalog/

### William Opdyke, *Refactoring Object-Oriented Frameworks*, 1992

The formal behavior-preservation definition (same inputs, same outputs, before and after) and the idea that each refactoring has preconditions that make it safe.

URL: https://www.laputan.org/pub/papers/opdyke-thesis.pdf

### Michael Feathers, *Working Effectively with Legacy Code*, 2004

Legacy code defined as code without tests, characterization tests as the way to pin current behavior before changing structure, and seams as the places to test from. The skill's uncovered-target protocol is this, with its lower confidence stated out loud.

URL: https://understandlegacycode.com/blog/key-points-of-working-effectively-with-legacy-code/

### Kent Beck, "make the change easy, then make the easy change"

The preparatory-refactoring framing the skill recommends as its highest-value trigger, cited via Fowler.

URL: https://martinfowler.com/articles/preparatory-refactoring-example.html

### Empirical studies of LLM and agent refactoring, 2024-2026

Named refactoring targets over open-ended prompts (arXiv 2411.04444), the field record of agent refactoring tangling and low-level bias (arXiv 2511.04824), incremental compile-and-test feedback as the most reliable correctness improver (arXiv 2511.03153, 2510.26480), and conservative scope beating aggressive sweeps (arXiv 2605.07001). These drove the named-target requirement, the per-step verification, and the stop rules.

URL: https://arxiv.org/abs/2411.04444

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [YAGNI](../../yagni.md). The evidence gate every planned refactoring passes, with the named anti-patterns and the deferral format.
- [`/tdd`](./tdd.md). The sibling execution skill. Its refactor step owns cleanup inside a red-green cycle; this skill owns restructuring outside one. Preparatory refactoring here, then drive the behavior change there.
- [`/code-review`](../han.core/code-review.md) and [`/architectural-analysis`](../han.core/architectural-analysis.md). Where the strongest input comes from: their findings are this skill's work orders.
- [`/investigate`](../han.core/investigate.md). For when the "refactoring" you want is actually a bug to diagnose and fix.
- [Research: refactor skill design](../../research/refactor-skill-research.md). The evidence-based, adversarially validated research behind this skill's design.
- [Skill building guidance](../../../han.plugin-builder/skills/guidance/references/skill-building-guidance/). The progressive disclosure, description frontmatter, and bash-permission rules this skill follows.
