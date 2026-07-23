---
name: manual-test-planning
description: >
  Produce a plain-language manual test plan from the context supplied to it — an executive summary, a high-level list
  of named tests, and a detail section per test with the steps a person follows by hand and the outcomes they should
  expect. Use when you want to create, draft, generate, or outline a manual test plan, manual QA steps, hands-on
  verification steps, or an acceptance walkthrough for a feature, change, branch, plan, or PR. When nothing in the
  supplied context can be manually tested, it says so and asks for more context instead of producing a document. Does
  not analyze code for automated test coverage gaps — use automated-test-planning. Does not write test code — use tdd. Does not
  review code quality — use code-review. Does not stress-test an existing plan — use iterative-plan-review.
argument-hint: "[optional: files, a branch, a plan, a PR, or a description of what to manually test]"
allowed-tools: Bash(git *), Read, Grep, Glob, Write, Agent
---

## Project Context

- .han/config.md: !`cat .han/config.md 2>/dev/null`

When the `.han/config.md` probe returns content, apply it per the config rule in
[../../references/config-rule.md](../../references/config-rule.md). When it returns nothing, no project config is
present and nothing changes.

## Operating Principles

- **Group outcomes only when the steps are identical.** A test verifies a single outcome, or a group of related
  outcomes only when the exact same steps produce every outcome in the group. If any outcome needs a different or
  additional step, it gets its own test, BECAUSE a person following one step list can only check the outcomes those
  steps actually produce.
- **Every test states its expected outcomes.** A step list without an expected outcome is not a test. Each test's
  detail section ends with the outcome or outcomes the person should observe, so they can tell pass from fail on the
  spot.
- **No manual tests means no document.** When the supplied context contains nothing a person can test by hand, say so
  clearly and ask for more context instead of writing a file. Never invent or pad testable outcomes, BECAUSE a plan
  built on guesses sends the tester chasing outcomes the work never promised.
- **Plain language only.** The plan is written for the person who runs the tests by hand, who may not be technical.
  Short, concise sentences. No file paths, function names, code, or framework jargon anywhere in the document.
  Describe what the person does and sees through the product's own surfaces (screens, commands, pages, messages), not
  how the code works, BECAUSE the reader follows the plan without ever reading the code.

## Step 1: Gather the Context

Collect everything supplied to the skill call: the arguments, the conversation so far, and any files, plans, specs,
diffs, or pull requests referenced. Read referenced files with Read. If a branch, PR, or change set is referenced and
git is available, use `git diff`, `git log`, and `git status` to understand what changed; if git is unavailable or the
directory is not a repository, skip the git commands and work from the rest of the supplied context. The git detail
informs your understanding only — none of it appears in the plan.

If no context was supplied at all, ask the user what they want a manual test plan for, and wait for their answer
before continuing.

## Step 2: Identify What Can Be Manually Tested

From the context, list every candidate outcome a person can verify by hand. An outcome qualifies only when all three
hold:

1. A person can reach it through the product's own surfaces: a screen, a page, a command they can run, a request they
   can send, a document or message they can read.
2. The steps to reach it can be written without asking the person to read or change code.
3. The result is something the person can directly observe and compare against an expectation.

Internal refactors, dependency bumps, code style changes, and behavior only observable in test suites or logs the
person cannot see do not qualify.

**If the list is empty:** tell the user clearly that nothing in the provided context can be manually tested, and ask
whether there is additional context to consider. If they supply more, return to Step 1 with the combined context. If
they say there is none, end the skill with that statement as its only output — do not write a file and do not produce
a document.

## Step 3: Group Outcomes into Named Tests

Turn the outcomes into a list of named tests:

1. Default to one test per outcome.
2. Merge outcomes into one test only when the exact same steps produce every outcome in the group. When in doubt,
   keep them separate.
3. Give each test a short, unique, plain-language name that says what it verifies (for example, "Signing in with a
   wrong password"), not how.
4. Order the tests in the sequence a person would sensibly run them: tests that set up state other tests rely on come
   first, then the most important behaviors, then the rest.

## Step 4: Draft the Plan

Invoke `han-communication:readability-guidance` to source the shared readability standard into your context, then
draft the document using the template at [references/template.md](./references/template.md):

- **Summary** — the executive summary: 2-4 short sentences on what the plan covers, who can run it, how many tests it
  contains, and where to start.
- **Tests at a Glance** — the high-level list: every test name with one sentence on what it verifies.
- **Test Details** — one section per named test: one sentence on what it verifies, a numbered list of steps to follow,
  and the expected outcome or outcomes.

Apply the Operating Principles as you write: short sentences, plain words, no technical detail, expected outcomes in
every detail section.

## Step 5: Adversarially Validate the Plan

Dispatch the `han-core:adversarial-validator` agent (one Agent call) against the draft before writing any file,
BECAUSE a plan that reaches the tester with wrong steps or unpromised outcomes wastes their run and hides real
failures. Embed the full draft in the agent's prompt, along with the scope of the context it was derived from (the
file paths, branch, plan, or description from Step 1), and instruct it to try to disprove, for every test:

1. The expected outcomes are actually promised by the supplied context, not invented or assumed.
2. The steps, followed exactly as written, reach and produce every stated expected outcome.
3. A person can perform every step through the product's own surfaces without reading or changing code.
4. Grouped outcomes are truly produced by the exact same steps, with no outcome needing a different or additional
   step.

Apply every confirmed finding to the draft:

- Fix steps that would not produce their stated outcome.
- Correct or remove expected outcomes the context does not promise.
- Split a grouped test when any of its outcomes needs different steps.
- Remove a test entirely when its outcome cannot be validated against the context.

If every test is removed, return to the empty-list handling in Step 2: state that nothing in the context can be
manually tested and ask for more context. If a finding turns on ambiguity in the context rather than an error in the
draft, surface it to the user with a recommended resolution instead of silently choosing.

## Step 6: Write the File

Write the document to `manual-test-plan.md` in the current working directory, unless the user supplied a different
path — the user's path wins.

If `manual-test-plan.md` already exists, do not overwrite it. Pick a new unique filename derived from the current
context: prefix the default name with one or two short plain-language words naming what the plan covers (for example,
`sign-in-manual-test-plan.md` or `checkout-manual-test-plan.md`). Keep the name short, and always include
`manual-test-plan` in it, BECAUSE the tester finds these documents by that name. Check the new name with Glob before
writing; if it also exists, adjust the prefix (or append a number) until the name is unique.

If the user supplied a path and that file already exists, show the user the path and ask before overwriting, BECAUSE
overwriting discards a document you did not produce in this run.

## Step 7: Readability Edit and Self-Check

Dispatch `han-communication:readability-editor` (one Agent call) to audit and rewrite the plan's prose against the
readability standard. Pass it the file path and the named audience: the person who will run these tests by hand, who
may not be technical. The editor reads han-communication's own canonical rule, so pass no rule path. It must preserve
every fact — every step, expected outcome, and test name must survive with its meaning intact.

Then run the standardized readability self-check (the shared standard is in your context from
`han-communication:readability-guidance`) over the document. Confirm each criterion and fix any failure:

1. The opening line states the main point.
2. Each heading names its content and is not a generic label.
3. Each paragraph carries one idea and leads with it.
4. No sentence runs past the soft length flag (about thirty words) without reason.
5. No word from the vocabulary blocklist (the writing-voice profile's "Avoided words and phrases" and "AI slop to
   avoid" lists) is present.
6. Every test still has its steps and expected outcomes, and no technical detail has crept in.

Finish by presenting a short in-channel summary: the file path, the number of tests, and the test names. Do not
repeat the full document in the channel.
