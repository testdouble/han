---
name: refactor
description: >
  Restructure existing code without changing its behavior, through a
  test-gated refactoring loop: a named target, a green suite over that target
  before any edit, a planned sequence of small named refactorings, and the
  full suite re-run after every step. Use when the user wants to refactor,
  restructure, clean up, simplify, or improve the design of existing code, or
  to apply refactoring recommendations from a code-review or
  architectural-analysis report. This skill changes code; it does not review
  code (use code-review), assess architecture (use architectural-analysis),
  or build new behavior test-first (use tdd). Do not use it on code inside an
  active tdd loop; the refactor step of tdd owns that cleanup.
argument-hint: "[file, module, named smell, or a path to review findings]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git *), Bash(find *), Bash(npm *), Bash(npx *), Bash(pnpm *), Bash(yarn *), Bash(pytest *), Bash(python3 *), Bash(go *), Bash(cargo *), Bash(make *), Bash(bundle *), Bash(rake *)
---

## Project Context

- git installed: !`git --version 2>/dev/null`
- current branch: !`git branch --show-current 2>/dev/null`
- working tree: !`git status --porcelain 2>/dev/null | head -5`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Constraints (read before anything else)

This skill restructures existing production and test code in your working
tree. It is an execution skill, not a document generator. These constraints
shape every step and override any instinct to move faster. The canon they
derive from, with provenance, is in
[references/refactoring-discipline.md](./references/refactoring-discipline.md);
pull that reference when a step needs the full rule or a step feels off.

- **Behavior preservation is the definition.** A refactoring changes internal
  structure without changing observable behavior. A change that alters
  behavior is not a refactoring done badly; it is not a refactoring at all.
  When a planned step turns out to require a behavior change, it leaves this
  skill's scope: defer it with a note naming the behavior change it needs.
- **Tests are the license to refactor.** No edit until the full suite has
  been run, observed green, and the target's behavior is covered. If coverage
  of the target cannot be established, stop and offer the characterization
  path in the reference; never refactor blind.
- **Small named steps, green to green.** Each step is one named refactoring
  with a bounded mechanic (extract function, rename, move, inline, and so
  on), and the suite runs after every step. A red suite after a step means
  revert the step, not patch forward.
- **The declared scope is a contract.** The target named in Step 1 bounds
  every edit. When a step starts pulling in files outside that scope, stop,
  report the spread, and let the user re-scope. Spreading edits are how a
  refactoring silently becomes a rewrite.
- **Never alongside an active tdd loop.** If the working tree shows a
  red-green cycle in flight (failing tests, a half-implemented behavior), do
  not run: the refactor step of `/tdd` owns cleanup inside the loop, and
  restructuring while a test is red violates the two-hats rule both skills
  share.
- **Refactor-only changes.** No behavior fixes, no features, no drive-by bug
  fixes, even when you spot one. Record what you found and leave it. If the
  user asks for commits, each commit contains refactoring only.
- **YAGNI governs the plan.** Apply
  [../../references/yagni-rule.md](../../references/yagni-rule.md): every
  refactoring in the plan needs evidence the code has a reason to change (a
  review finding, named duplication, a confusing read documented by the user,
  upcoming work in that area). Removing duplication is the job; adding
  speculative abstraction, configuration, or indirection is not. Defer
  evidence-free items with a reopen trigger.

# Refactor

## Step 1: Bind the Target and Resolve Project Config

**Bind the target.** Resolve the request to a named target: specific files or
directories, a named code smell in a named place, or the refactoring findings
in a provided document (a `/code-review` report, an `/architectural-analysis`
report, or equivalent). When a findings document is given, extract only the
refactoring-shaped findings (structural suggestions, duplication, naming,
coupling) and record each finding's ID so the summary can trace back to it.
If the request is open-ended ("clean up the codebase", "improve quality")
with no named target, ask the user for one before doing anything: open-ended
refactoring runs are the documented failure mode this skill exists to avoid,
and a wrong guess here burns the whole run.

**Resolve commands.** Read CLAUDE.md's `## Project Discovery` section for the
test command (under `### Commands and Tests`), the lint command, the build
command, language, and framework. If absent, fall back to
`project-discovery.md`. If still absent, run
`${CLAUDE_SKILL_DIR}/scripts/detect-refactor-context.sh` and parse its
output for git state and manifest-inferred commands. A missing test command is
a hard blocker: exhaust inference, then ask the user, because this skill
cannot run without a way to verify behavior. Also note any type-check command
the project has; where one exists it runs alongside the tests as a second
behavior-preservation check.

**Resolve standards and decisions.** Resolve the coding-standards directory
and ADR directory the same way: CLAUDE.md's `## Project Discovery` section,
then `project-discovery.md`, then Glob defaults (`docs/`, `docs/adr/`,
`docs/coding-standards/`, `docs/decisions/`). Also check `CLAUDE.md` and
`AGENTS.md` for inline standards. Read the standards and ADRs whose titles,
paths, or one-line summaries indicate they govern the target area; cap at
five documents. The target's restructured form must conform to these. If none
exist, state that plainly and infer conventions from the surrounding code.

## Step 2: Establish the Safety Net

**Check the tree.** If `working tree` in Project Context shows failing
mid-cycle work or the user describes an in-flight tdd loop on this code,
stop and say why (the never-alongside-tdd constraint). Uncommitted but
complete work is fine; recommend committing it first so refactoring diffs
stay clean, then proceed.

**Run the full suite.** Run the resolved test command with Bash. **Paste the
runner's summary line.** If anything is red, stop: a red suite is not a
license to refactor. Report the failures and recommend fixing them first
(via `/investigate` or `/tdd`), or re-scoping the target away from the
broken area.

**Establish coverage of the target.** Confirm the target's observable
behavior is exercised by the suite: find the tests that drive the target
(Glob and Grep for the target's public symbols in test files), and run them
scoped if the runner supports it. State plainly which behaviors are covered
and which are not. If the target has no meaningful coverage, stop and offer
two ways forward, and wait for the user's choice: narrow the target to the
covered part, or write characterization tests first using the protocol in
[references/refactoring-discipline.md](./references/refactoring-discipline.md).
Characterization tests pin current observed behavior (including current
bugs) and are a lower-confidence net than intent-written tests; say so in
the report.

## Step 3: Plan the Sequence Before Editing

Plan the whole run before the first edit. Produce a numbered refactoring
plan where each item is:

- **One named refactoring** (the vocabulary is in the reference; use the
  project's language idioms, not Java mechanics), applied to a named place.
- **The evidence for it.** The finding ID, the duplicated code, the standard
  or ADR it brings the code into conformance with, or the user's stated pain.
  Items without evidence are deferred per the YAGNI constraint, with a
  reopen trigger, never silently dropped.
- **Its expected blast radius.** The files the step should touch. This is
  what the scope stop-rule in Step 4 checks against.

Order the plan so each step leaves the code releasable: small, independent
steps first, dependent steps after the steps they need. Report the plan to
the user, then continue immediately; this is a report, not a gate. The one
exception: if the request explicitly asks to review or approve the plan
first, wait for approval.

## Step 4: Execute, One Named Refactoring at a Time

Take the plan items in order. For each:

1. **Make the one change.** Apply the single named refactoring, touching
   only the files in its declared blast radius. Stay in the refactoring hat:
   no behavior fixes, no extras spotted along the way (record them for the
   summary instead).
2. **Run the full suite** (and the type-check command where one was
   resolved). **Paste the runner's summary line.** Paste full output only
   when something fails or looks unexpected.
3. **Green: cross the item off** and move to the next.
4. **Red: revert this step.** When git is available and the tree was clean
   at start, `git checkout`/`git restore` the touched files. When git is
   absent, or the tree was already dirty at start, undo the edits directly
   instead, so reverting this step does not discard the user's other work.
   Do not patch forward over a red suite; a failed step means the mechanic
   was unsafe or the coverage was thinner than it looked. Diagnose, then
   either retry with a smaller step or defer the item with what you learned.
5. **Stop rules.** If the step needed files outside its declared blast
   radius, or the only way to make it work changes observable behavior, or
   two consecutive plan items have been reverted: stop, report where things
   stand (everything already applied is green and stands), and let the user
   re-scope.

If the user asked for commits, commit after each green step or each logical
group of green steps, message naming the refactoring applied, refactoring
only.

## Step 5: Final Verification and Summary

Run the full test suite, the lint command, and the build command from Step 1.
**Paste the summary line from each.** If lint or build fails on code this
skill touched, fix it and re-run; that is in scope.

Summarize for the user:

- Each refactoring applied, named, with the evidence it rested on (finding
  IDs from the source report where one was used) and the files it touched.
- Deferred items: the YAGNI deferrals with reopen triggers, any items
  deferred because they required behavior changes, and any stop-rule exits.
- Anything spotted but deliberately left alone (bugs, smells outside scope),
  so it can feed `/issue-triage` or the next `/code-review`.
- Which coding standards and ADRs the restructured code now conforms to.
- Final test, lint, and build status, with output shown, not asserted.
- If characterization tests were written, say so and recommend replacing
  them with intent-written tests over time.
