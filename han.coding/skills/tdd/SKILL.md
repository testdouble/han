---
name: tdd
description: >
  Write code through a disciplined, BDD-framed Test-Driven Development loop:
  build a behavior test list, then drive each behavior through
  red-green-refactor with an enforced observed-failure gate. Use when the user
  wants to implement, build, or write code test-first, "do TDD", follow
  "red-green-refactor", drive code from tests, or grow a feature
  behavior-by-behavior with tests leading. This skill writes and changes code;
  it does not produce a test plan document (use test-planning), review or audit
  existing code (use code-review), specify what a feature should do (use
  plan-a-feature), or find the root cause of a bug (use investigate).
argument-hint: "[what to build, a behavior to drive, or a path to a spec/plan]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(git *), Bash(find *), Bash(npm *), Bash(npx *), Bash(pnpm *), Bash(yarn *), Bash(pytest *), Bash(python3 *), Bash(go *), Bash(cargo *), Bash(make *), Bash(bundle *), Bash(rake *)
---

## Project Context

- git installed: !`git --version 2>/dev/null`
- current branch: !`git branch --show-current 2>/dev/null`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Constraints (read before anything else)

This skill writes production and test code in your working tree. It is an
execution skill, not a document generator. These constraints shape every step
and override any instinct to move faster.

- **The observed-failure gate is load-bearing.** No production-code change
  until a test has been run and observed to fail for the intended reason in
  this loop. A test that passes on first run is a stop-and-diagnose signal,
  not progress. This single rule is what separates real TDD from TDD-flavored
  code. The verbatim Three Laws and Canon TDD steps it derives from are in
  [references/tdd-loop.md](./references/tdd-loop.md); pull that reference when a
  step needs the canon or the implementation gears.
- **Two hats.** Never refactor while any test is red. See
  [references/tdd-loop.md](./references/tdd-loop.md) for the canonical statement.
- **One behavior at a time.** Exactly one test list item becomes one runnable
  test per loop. Newly discovered scenarios are written to the list and
  deferred, never implemented in the current loop.
- **BDD framing.** Tests describe observable behavior, named in the project's
  existing test-naming convention, asserting outcomes through the public
  interface — never private state. The behavior-naming and Given/When/Then
  protocol is in [references/bdd-framing.md](./references/bdd-framing.md); pull
  it when Step 2 needs it.
- **You will be tempted to fake this.** The specific ways an agent fakes TDD,
  and the discipline that catches each, are in
  [references/failure-modes.md](./references/failure-modes.md); pull it when a
  loop feels off (a test passes on first run, no red is shown, the
  implementation has outrun the test, refactor is being skipped).
- **YAGNI governs the refactor step and the test list.** Apply the rule in
  [../../references/yagni-rule.md](../../references/yagni-rule.md): remove
  duplication, but do not add abstractions, configuration, or indirection
  without evidence. Speculative structure added "for flexibility" during
  refactor is a YAGNI candidate. Speculative scenarios on the test list are
  deferred with a reopen trigger, never silently added.

# Test-Driven Development

## Step 1: Resolve Project Config and Confirm Scope

**Resolve commands.** Read CLAUDE.md's `## Project Discovery` section for the
test command (under `### Commands and Tests`, not `### Frameworks and
Tooling`), the lint command, the build command, language, and framework. If
absent, fall back to `project-discovery.md`. If still absent, run
`${CLAUDE_SKILL_DIR}/scripts/detect-tdd-context.sh` and parse its output for
git state and manifest-inferred commands. Store the resolved test, lint, and
build commands for use in every later step.

**Resolve standards and decisions.** Resolve the coding-standards directory and
ADR directory the same way: read CLAUDE.md's `## Project Discovery` section;
fall back to `project-discovery.md`; fall back to Glob defaults (`docs/`,
`docs/adr/`, `docs/coding-standards/`, `docs/decisions/`). Also check
`CLAUDE.md` and `AGENTS.md` for inline standards. **Read the standards and
ADRs whose titles, paths, or one-line summaries indicate they govern the area
being built. Cap at five documents; if more than five look relevant, list them
and read only the five with the strongest apparent relevance — defer the rest
until refactor surfaces a need.** These govern the green and refactor steps.
If none exist, state that plainly and plan to infer conventions from the
surrounding code instead.

**Report scope, then proceed (no gate).** This skill runs autonomously after
the initial request: it does not stop for confirmation. State to the user, in a
few lines: the behavior or feature to be built, the resolved test/lint/build
commands, the standards and ADRs found (or that none were), the current branch,
and that the skill will now write code in a red-green-refactor loop. If
`current branch` from Project Context is the repository's default branch
(`main` or `master`), recommend working on a branch, but do not wait for an
answer. This is a report the user reads while the work runs, not a gate.
Continue immediately to Step 2 without waiting for a response.

**The one exception.** If the initial request or the provided context
explicitly states the human wants to review, verify, or approve the plan or
test list before implementation, then this becomes a gate: build the test list
in Step 2, present it together with this scope report, and wait for approval
before starting the Step 3 loop. Absent an explicit request like that, the
skill runs to completion without further human input.

The one input that can still block is a missing test command: if it could not
be resolved from CLAUDE.md, `project-discovery.md`, the discovery script, or
manifest inference, ask the user for it, because TDD is impossible without a
way to run tests. Exhaust inference before asking; this is a hard dependency,
not a discretionary checkpoint.

## Step 2: Build the BDD Test List

Turn the requested feature or behavior into a test list (Kent Beck's "test
list" pattern). Each item is one observable behavior, phrased as a behavior
sentence, not as an implementation note. "Returns the unrounded fee for a
sub-dollar charge" is a list item; "use a BigDecimal" is not. Follow
[references/bdd-framing.md](./references/bdd-framing.md) for how to phrase and
name behaviors, and which test-naming convention to adopt (the project's
existing convention and any discovered coding standard win over a literal
"should" default).

Order the list outside-in by user value: the next item is the most important
thing the system does not yet do. For an item that is **user-observable
behavior at a system boundary**, write the outer acceptance test for it *first*
(it will be red until its inner behaviors exist) and record it as the outer
loop for that item. For internal or utility behavior with no meaningful system
boundary, the outer acceptance test is optional; the inner loop alone is
correct.

Apply YAGNI to the list itself. A scenario earns a place only with evidence it
is needed now (a user-described need, a named dependency, an existing code path
that breaks, a regulation, a real incident). Scenarios that fail the evidence
test go to a deferred list with the trigger that would reopen them. Do not pad
the list for symmetry or completeness.

Report the test list to the user. Unless the verify-plan exception from Step 1
applies, continue to Step 3 immediately without waiting for approval. When that
exception applies, present the test list together with the Step 1 scope report
and wait for approval before entering the loop.

## Step 3: The Red-Green-Refactor Loop

Pick exactly one item from the list. Choose one that teaches you something and
that you are confident you can implement in one cycle (Beck's "one step
test"). Then run these three phases in order. Do not collapse them.

**Read once, don't reread.** Within a single loop iteration, do not reread a
file you have already read in this iteration unless you have edited it. When
`grep` returns a line number, use `Read` with `offset` and `limit` to read
20-40 lines around the target — not the entire file. Rereading whole source
files between Red and Green of the same behavior is overhead, not discipline.

### Red

Write exactly one test for the chosen behavior. Name it for the behavior in the
project's convention. Assert an observable outcome through the public interface
(Given = arrange the state before; When = the one action under test; Then =
assert the observable result). Write no more of the test than is sufficient to
fail; a compilation failure is a failure.

Run the resolved test command directly with Bash. **Paste the failing
assertion plus enough surrounding output (5-10 lines) to confirm the failure
reason** — the assertion text or the missing symbol you expect, not an
unrelated error. If the test passed on its first run, paste only the runner's
summary line and stop to diagnose: the observed-failure gate has tripped.

If the test passes on its first run, the observed-failure gate has tripped.
Stop. Diagnose: the test is not exercising the behavior, or the behavior
already exists. If the behavior already exists, cross the item off and pick the
next one. Do not write production code off an unobserved red.

### Green

Write the minimum production code that makes this one test pass. Use the
smallest gear that works: Obvious Implementation when you are certain, Fake It
(return a constant, generalize later) when you are not, Triangulate (force the
abstraction with a second example) only when you are really unsure. Gears are
described in [references/tdd-loop.md](./references/tdd-loop.md).

While going green, respect the coding standards and ADRs that govern
*correctness and architectural placement*: where this code is allowed to live,
which boundary or client it must go through, which contract it must honor.
Violating an ADR boundary is not a sin you clean up later — it is the wrong
code. Do **not** apply stylistic or structural polish here (naming sweeps,
extraction, formatting passes). That is the refactor hat, and wearing it now
violates "no more code than is sufficient to pass the test."

Run the full test suite with Bash. **Paste the runner's summary line (pass
and fail counts).** Paste full output only if a previously passing test broke
or something unexpected appears. The gate to leave green is: the new test
passes and every previously passing test still passes. If a prior test broke,
you are not green — fix it before refactoring.

### Refactor (non-skippable)

Only with every test green. Neglecting this step is the most common way to
ruin TDD, so it is not optional: either you change something, or you state
explicitly "no duplication, structure, or standards issue this cycle" and move
on.

Eliminate the duplication you just created. Bring the code into full
conformance with the resolved coding standards and ADRs — this is the home for
the stylistic and structural standards you deliberately skipped in green.

Apply YAGNI per [../../references/yagni-rule.md](../../references/yagni-rule.md):
remove duplication, do not add speculative abstraction. Defer speculative
structure with the trigger that would reopen it; never add silently, never
drop silently.

Change no behavior. Re-run the full suite after the refactor. **Paste the
runner's summary line** — paste full output only if something unexpected
appears. The suite must stay green. If a refactor reddened a test, revert it —
a refactor that changes behavior is a defect, not a refactor.

### Close the cycle

Cross the completed item off the list. Append any scenarios you discovered
while implementing (deferred, with their reopen trigger if speculative), but do
not implement them now. If the open list has grown past roughly ten items, do
not stop for input: flag it prominently as a scope warning, keep going, and
record in the final summary that the work exceeded the recommended size and
should be split next time. A runaway list is a scope signal, not a reason to
pause for a human.

Return to the top of Step 3 with the next item. Continue until the list is
empty.

## Step 4: Close the Outer Loop

For any item that had an outer acceptance test (Step 2), run that test now. It
should pass only because its inner behaviors are all implemented with real code
(not mocks). If it is still red, the gap is a missing inner behavior: add the
missing scenario to the test list and return to Step 3. The acceptance test
going green is the signal the user-facing behavior is actually delivered.

## Step 5: Final Verification and Summary

Run the full test suite, then the lint command, then the build command, using
the resolved commands from Step 1. **Paste the summary line from each.** Paste
full output only when one of them fails. If lint or build fails, that is in
scope — fix it (a lint or build break is not a "pre-existing error" to wave
off) and re-run.

Summarize for the user:

- Behaviors implemented, and the state of the test list (done, and any
  deferred items with their reopen triggers).
- Which coding standards and ADRs were applied, and where they shaped the code.
- Any YAGNI deferrals from refactor, each with its reopen trigger.
- A scope warning if the test list exceeded roughly ten open items, with a
  recommendation to split future work.
- The final test, lint, and build status, with output shown, not asserted.
