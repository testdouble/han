# /tdd

Operator documentation for the `/tdd` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/tdd/SKILL.md`](../../han.core/skills/tdd/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** Drives writing code through a disciplined, BDD-framed red-green-refactor loop, one behavior at a time, with a gate that refuses production code until a test has been run and seen to fail.
- **When to use it.** You want a feature or behavior implemented test-first, the right way, instead of code with tests bolted on after.
- **What you get back.** Working, tested code in your tree, grown behavior by behavior, with the test list, the standards applied, and the verification output shown at the end.

## Key concepts

- **Execution skill.** Every other han skill produces a markdown document. This one modifies your source tree. It writes the tests and the production code. That is the point, and it is why the skill reports scope and recommends a branch before it starts, so a watching human can see what it will do.
- **The observed-failure gate.** No production code changes unless a test has been run and watched to fail for the intended reason in that loop. A test that passes the first time it runs means red was never seen, which is a process violation, not a success.
- **Two hats.** Making a test pass and improving structure are different jobs done at different times. The skill never refactors while a test is red. Make it run, then make it right.
- **BDD framing.** Tests describe observable behavior, named in your project's existing convention, asserting outcomes through the public interface, never private state. For user-facing behavior the skill works outside-in: a failing acceptance test on the outside, red-green-refactor on the inside.
- **Standards split across green and refactor.** Going green obeys only the standards that govern correctness and where code is allowed to live (an ADR boundary you cross is wrong code, not deferrable mess). Full stylistic and structural conformance, plus YAGNI, happen in refactor.

## When to use it

**Invoke when:**

- You have a feature, behavior, or function to build and you want it driven test-first through a correct red-green-refactor cycle.
- You want to grow code behavior by behavior with the tests leading, not write code and add tests afterward.
- You are working from a specification or plan and want the implementation built with TDD discipline rather than in one pass.

**Do not invoke for:**

- **Producing a test plan without writing code.** Use [`/test-planning`](./test-planning.md) instead. It analyzes coverage gaps and prioritizes what to test; it does not implement.
- **Reviewing or auditing code that already exists.** Use [`/code-review`](./code-review.md) instead.
- **Deciding what a feature should do.** Use [`/plan-a-feature`](./plan-a-feature.md) to specify behavior first, then bring the spec here.
- **Finding the root cause of a bug.** Use [`/investigate`](./investigate.md). Once you have a fix in mind, you can drive it back in through `/tdd`.

## How to invoke it

Run `/tdd` in Claude Code.

Give it:

1. **What to build.** A behavior, a feature, or a path to a specification or plan. A sharp version names the observable behavior ("the fee calculator rounds half-up to the cent"); a thin version ("build the fee thing") still works because Step 2 turns it into a behavior list you review before any code is written.
2. **Any context to respect.** A `feature-specification.md`, a linked issue, or a plan. The skill reads it as the source of behaviors for the test list.
3. **Nothing about the test framework.** The skill resolves the test, lint, and build commands from your project itself (see *What you get back*). You do not need to pass them.

The skill runs autonomously after your initial request. Before the loop it reports scope (the behavior to build, the resolved test, lint, and build commands, the standards and ADRs it found, the current branch, a branch recommendation if you are on the default branch), then proceeds without waiting. That report is informational, not a gate. The one exception: if your request or the provided context explicitly says you want to review, verify, or approve the plan or test list before implementation, the skill builds the test list, presents it with the scope report, and waits for your approval before writing any code. The only input that can otherwise block it is a test command it cannot resolve or infer, because there is no way to run tests without one.

Example prompts:

- `/tdd`. *"Implement the discount engine from docs/specs/discount/feature-specification.md test-first."*
- `/tdd`. *"Drive a new `parseDuration` function red-green-refactor: it should accept `1h30m` style strings and reject garbage."*

## What you get back

Code in your working tree, not a report. Specifically:

- **A test list**, shown to you before the loop starts and updated as behaviors are completed and as new scenarios are discovered (discovered scenarios are deferred, never built mid-loop).
- **Tests and production code**, grown one behavior per cycle. Each cycle shows you the real test-runner output for red (the test failing for the intended reason) and green (the new test passing, all prior tests still passing).
- **A final summary**: behaviors implemented, the state of the test list including any deferred items with their reopen triggers, which coding standards and ADRs were applied and where, any YAGNI deferrals from refactor, and the final test, lint, and build status with output shown rather than asserted.

The skill resolves your test, lint, and build commands from CLAUDE.md's `## Project Discovery` section, falling back to `project-discovery.md`, falling back to a one-time discovery script that infers them from your manifest files (package.json, pyproject.toml, go.mod, Cargo.toml, Gemfile, mix.exs, pom.xml, gradle, .csproj, or a Makefile test target). Commands the script infers are treated as best-effort suggestions, surfaced in the scope report so you can correct them if you are watching, not trusted blindly. If none of those resolve the test command, the skill asks you for it before the loop starts, because the loop cannot run without it. That is the only input that can block an otherwise autonomous run.

## How to get the most out of it

- **Bring a specification when you have one.** `/tdd` builds a better test list from a `feature-specification.md` than from a one-line prompt, because the behaviors and edge cases are already named. Run [`/plan-a-feature`](./plan-a-feature.md) first for anything non-trivial.
- **Have your standards and ADRs discoverable.** The green and refactor steps apply your coding standards and architectural decisions. If they live in `docs/coding-standards/` or `docs/adr/`, or are recorded by [`/coding-standard`](./coding-standard.md) and [`/architectural-decision-record`](./architectural-decision-record.md), the skill finds and applies them. If they do not exist, it infers conventions from surrounding code, which is weaker.
- **Let the list be the scope signal.** If the open test list grows past about ten items, the skill flags a scope warning and keeps going, then recommends splitting the work in its final summary. Take that warning seriously: a ballooning list usually means the feature wanted to be planned, not grown in one sitting.
- **Read the red output.** The skill pastes real runner output for every red. Glancing at it is how you catch a test that fails for the wrong reason before it drives wrong code.
- **Pair with `/code-review` next.** TDD produces self-testing code; it does not replace a second set of eyes. Run [`/code-review`](./code-review.md) on the branch when the list is empty.

## YAGNI

`/tdd` produces two things YAGNI gates: the test list and the code that comes out of refactor.

- **The test list.** A scenario earns a place only with evidence it is needed now (a user-described need, a named dependency, an existing code path that breaks, an applicable regulation, a real incident). Scenarios that fail the evidence test, or that exist for symmetry or completeness, are deferred with the trigger that would reopen them, not padded onto the list.
- **The refactor step.** Removing duplication is the job. Adding an interface with one implementation, a configuration knob no caller sets, or a generalization from a single example is not. "Duplication is a hint, not a command": the skill abstracts only when two or more concrete examples force it, which is the Rule of Three and also Beck's Triangulate. Speculative structure introduced for future flexibility is a YAGNI candidate, deferred with a named reopen trigger and surfaced to you, never silently added and never silently dropped.

The rule is enforcing in refactor (speculative structure is deferred by default), and the deferrals appear in the final summary. See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.

## Cost and latency

`/tdd` runs on the main agent. It dispatches no sub-agents and is not a sizing-aware skill, so there is no fan-out cost. The cost is the loop itself: a multi-turn, tight iteration where each behavior is three phases (red, green, refactor) and each phase runs your test command. The most expensive single factor is the number of test list items multiplied by your suite's runtime, since the full suite runs at green and after every refactor. This is a tight-loop skill built to run while you build, not an infrequent high-signal report. Keeping the test list scoped (the skill flags lists past ~10 items) is the main lever on total cost.

## In more detail

The skill is structurally modeled on two existing skills. The loop and its stop condition follow [`/iterative-plan-review`](./iterative-plan-review.md): front-loaded constraints, a deterministic per-cycle process, a bounded list. The project and command discovery follows [`/test-planning`](./test-planning.md): resolve from CLAUDE.md's `## Project Discovery`, fall back to `project-discovery.md`, fall back to a one-time script.

One design decision is worth knowing. Classic TDD says green should "commit whatever sins are necessary" and clean up in refactor. Taken literally, that would mean ignoring coding standards while going green. The skill splits the difference: standards that govern *correctness and architectural placement* (which boundary code must go through, where it is allowed to live, which contract it honors) are obeyed in green, because violating an ADR boundary is not a temporary sin you tidy later, it is the wrong code. Stylistic and structural standards, the kind you genuinely can defer, are the refactor hat. This keeps the green step minimal (the Three Laws still hold) while making sure the code that survives the cycle respects the project's architecture.

The hardest honest limitation: the observed-failure gate is enforced by discipline and shown evidence (pasted runner output, the first-run-pass stop rule, strict step sequencing), not by a mechanism that can physically prevent a premature write. No skill in the plugin model can enforce a "you must have observed X before doing Y" constraint with certainty. The skill makes the failure visible and diagnosable instead, which is the strongest available guarantee. If you watch one thing while it runs, watch that the red output is real and fails for the reason intended.

## Sources

The skill's protocols and vocabulary are grounded in the primary TDD and BDD literature. Each source is cited because the skill draws a specific, named artifact from it.

### Kent Beck, *Test-Driven Development: By Example*, 2002; and "Canon TDD", 2023

The test list pattern, the red-green-refactor mantra, the two-hats rule, and the implementation gears (Fake It, Triangulate, Obvious Implementation) come from here. The skill's loop is the Canon TDD five-step loop.

URL: https://tidyfirst.substack.com/p/canon-tdd

### Robert C. Martin, "The Three Rules of TDD" and "The Cycles of TDD"

The verbatim Three Laws the observed-failure gate is built on, including "compilation failures are failures" and "the one failing unit test".

URL: https://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html

### Martin Fowler, "Test Driven Development", "Mocks Aren't Stubs", "GivenWhenThen"

The refactor-is-the-most-skipped-step warning, the classicist default for test doubles, the stub-query / mock-command rule, and Given-When-Then mapped onto Arrange-Act-Assert.

URL: https://martinfowler.com/articles/mocksArentStubs.html

### Dan North, "Introducing BDD"

Behavior over "test", the should-sentence framing, and the "should it? really?" failure triage.

URL: https://dannorth.net/introducing-bdd/

### Steve Freeman & Nat Pryce, *Growing Object-Oriented Software, Guided by Tests*

The outside-in double loop: an outer acceptance test, an inner red-green-refactor loop, collaborator interfaces discovered via mocks at the call site, acceptance test green only with real implementations.

URL: https://growing-object-oriented-software.com/

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](./README.md). All skills, grouped by purpose.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule the refactor step and test list apply. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [`/test-planning`](./test-planning.md). Plan what to test without writing code. Use it before `/tdd` to enumerate behaviors, or instead of it when you want analysis rather than implementation.
- [`/plan-a-feature`](./plan-a-feature.md). Specify behavior first; the spec becomes the test list `/tdd` builds from.
- [`/code-review`](./code-review.md). Run it on the branch once the list is empty. TDD produces self-testing code; it does not replace review.
- [`/coding-standard`](./coding-standard.md) and [`/architectural-decision-record`](./architectural-decision-record.md). The standards and ADRs `/tdd` applies in green and refactor come from here.
- [Skill building guidance](../../han.plugin-builder/skills/guidance/references/skill-building-guidance/). The progressive disclosure, description frontmatter, and bash-permission rules this skill follows.
