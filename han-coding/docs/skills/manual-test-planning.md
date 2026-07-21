# /manual-test-planning

Operator documentation for the `/manual-test-planning` skill in the han plugin. This document helps you decide _when_
and _how_ to use the skill. For what the skill does internally, read the skill definition at
[`han-coding/skills/manual-test-planning/SKILL.md`](../../skills/manual-test-planning/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [YAGNI](../../../docs/yagni.md)

## TL;DR

- **What it does.** Produces a plain-language manual test plan from the context you supply: an executive summary, a
  high-level list of named tests, and a detail section per test with the steps a person follows by hand and the
  outcomes they should expect.
- **When to use it.** You have a feature, change, branch, plan, or PR and want a document a person can follow to
  verify it by hand, without reading any code.
- **What you get back.** A `manual-test-plan.md` file written in short, plain sentences, free of technical detail,
  with expected outcomes in every test. When nothing in the context can be manually tested, you get that statement
  instead of a document.

## Key concepts

- **Manually testable outcome.** An outcome qualifies only when a person can reach it through the product's own
  surfaces (a screen, a command, a request, a document), the steps can be written without asking them to read or
  change code, and the result is directly observable. Internal refactors and dependency bumps do not qualify.
- **One test per outcome, grouped only on identical steps.** A test verifies a single outcome, or a group of related
  outcomes only when the exact same steps produce every outcome in the group. Different steps means a different test.
- **No manual tests means no document.** When the supplied context has nothing a person can test by hand, the skill
  says so and asks whether there is more context to consider. If there is none, its only output is that statement.
- **Plain language throughout.** The plan is written for the person running the tests, who may not be technical. No
  file paths, function names, code, or framework jargon appear anywhere in the document.
- **Adversarial validation before the file exists.** The `adversarial-validator` agent attacks the draft: it tries to
  disprove that each expected outcome is promised by the context, that the steps as written produce it, and that
  grouped outcomes truly share identical steps. Confirmed findings adjust, split, or remove tests before anything is
  written.

## When to use it

**Invoke when:**

- You finished a feature or a branch and want a hands-on verification walkthrough someone can run before release.
- You have a plan, spec, or PR and want manual QA steps derived from what it promises.
- A non-technical teammate will verify the work and needs a document they can follow on their own.

**Do not invoke for:**

- **Automated test coverage plans.** Use [`/test-planning`](./test-planning.md) for coverage-gap and edge-case test
  plans with file references and test levels.
- **Writing test code.** Use [`/tdd`](./tdd.md) to implement behavior test-first.
- **Reviewing code quality.** Use [`/code-review`](./code-review.md).
- **Stress-testing an existing plan.** Use
  [`/iterative-plan-review`](../../../han-planning/docs/skills/iterative-plan-review.md).

## How to invoke it

Run `/manual-test-planning` in Claude Code.

Give it:

1. **Context to plan from.** Files, a branch, a plan document, a PR, or a description of the feature or change. The
   richer the context, the sharper the tests. Without any context, the skill asks what you want a plan for.
2. **A target path, optional.** The plan defaults to `manual-test-plan.md` in the current directory; name a path to
   put it somewhere else. When the default file already exists, the skill picks a short unique name instead of
   overwriting, keeping `manual-test-plan` in it (for example, `sign-in-manual-test-plan.md`).

Example prompts:

- `/manual-test-planning`. _"Create a manual test plan for the changes on this branch."_
- `/manual-test-planning docs/plans/checkout-flow/feature-specification.md`. Derive the tests from a spec.
- `/manual-test-planning`. _"Plan manual tests for the new sign-in flow we just discussed."_

## What you get back

A `manual-test-plan.md` file with three sections:

- **Summary.** The executive summary: what the plan covers, who can run it, how many tests it contains, and where to
  start.
- **Tests at a Glance.** Every test name with one sentence on what it verifies, in the order to run them.
- **Test Details.** One section per named test: what it verifies, a numbered list of steps to follow by hand, and the
  expected outcome or outcomes the person should observe.

When nothing in the context can be manually tested and you have no more context to add, there is no file; the skill
tells you that in the channel and stops.

## How to get the most out of it

- **Supply the behavior, not the code.** The skill plans from what the work promises a user can do. A spec, a PR
  description, or a plain description of the feature gives it more to work with than a bare file list.
- **Say who will run the tests.** If the tester is non-technical, say so; the wording of steps and outcomes tightens
  around what they can see and do.
- **Pair with `/test-planning`** when you also want automated coverage: this skill covers the by-hand walkthrough,
  that one covers the tests engineers write.

## Cost and latency

The skill runs in the main conversation and dispatches two agents in sequence: `han-core:adversarial-validator`,
which attacks the draft before the file is written, and `han-communication:readability-editor`, which rewrites the
finished document's prose for the person running the tests. Typical runs take a few minutes. It is built for
tight-loop iteration; re-run it when the underlying change grows.

## In more detail

The skill walks a seven-step process:

1. **Gather the context.** Everything supplied to the call: arguments, conversation, referenced files, and (when git
   is available) the diff behind a referenced branch or PR. The git detail informs understanding only and never
   appears in the plan.
2. **Identify what can be manually tested.** List candidate outcomes a person can verify by hand. If the list is
   empty, say so and ask for more context; with none, stop with no document.
3. **Group outcomes into named tests.** One outcome per test, merged only when the exact same steps produce every
   outcome in the group, each with a short plain-language name.
4. **Draft the plan.** Source the shared readability standard via `han-communication:readability-guidance`, then fill
   the template at [`references/template.md`](../../skills/manual-test-planning/references/template.md).
5. **Adversarially validate the plan.** Dispatch `adversarial-validator` against the draft with the context it was
   derived from. It tries to disprove that outcomes are promised by the context, that the steps produce them, that a
   person can follow them without touching code, and that grouped outcomes share identical steps. Confirmed findings
   fix steps, correct or remove outcomes, split grouped tests, or remove tests; if every test falls, the skill returns
   to the nothing-to-test path. Findings that turn on ambiguity in the context go to the user with a recommendation.
6. **Write the file.** Default `manual-test-plan.md`; a user-supplied path wins. When the default file already
   exists, the skill derives a short unique name from the context that keeps `manual-test-plan` in it, rather than
   overwriting. A user-supplied path that already exists is never overwritten without confirmation.
7. **Readability edit and self-check.** Dispatch `readability-editor` against the file for the named audience, then
   run the standardized readability self-check and fix any failure before presenting a short in-channel summary.

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs
  tree.
- [`/test-planning`](./test-planning.md). The automated-coverage sibling: prioritized test plans with file references
  and test levels.
- [`adversarial-validator`](../../../han-core/docs/agents/adversarial-validator.md). Dispatched against the draft to
  disprove invalid tests, steps, and expected outcomes before the file is written.
- [`readability-editor`](../../../han-communication/docs/agents/readability-editor.md). Dispatched once the plan is
  written, to rewrite its prose for the person who will run the tests.
- [`SKILL.md` for /manual-test-planning](../../skills/manual-test-planning/SKILL.md). The internal process definition.
