# Refactoring Discipline: the Canon

The rules the `/refactor` skill enforces, with their provenance. Pull this
file when a step needs the full rule, when a run feels off, or when the user
asks why the skill refused to proceed.

## The definition

Refactoring (noun): a change made to the internal structure of software to
make it easier to understand and cheaper to modify without changing its
observable behavior. Refactoring (verb): to restructure software by applying
a series of refactorings without changing its observable behavior. Both are
Fowler's definitions; the formal version (Opdyke, 1992) is that for the same
set of input values, the resulting set of output values is the same before
and after the change.

Two consequences the skill enforces:

- A "refactoring" that changes behavior is a defect, not a refactoring. When
  a planned step cannot be completed without changing behavior, the step
  leaves the skill's scope and is deferred with a note.
- The system stays working the whole time. Fowler's test for real
  refactoring is that the system is never broken for more than a few
  minutes. That is why the suite runs after every step, not at the end.

## The preconditions

1. **A green suite covering the target, before anything changes.** Tests are
   the only practical proof of behavior preservation. The majority
   practitioner position is unambiguous: no tests, no refactoring. Coverage
   percentage is not the bar; the bar is that the target's observable
   behaviors are exercised.
2. **Green to green, step by step.** The suite passes before a step and
   after it. A red suite after a step means the step gets reverted, never
   patched forward. Reverting is cheap precisely because steps are small.
3. **A type checker or linter, where the project has one, runs alongside the
   tests.** Static checks catch a class of unsafe edits (broken call sites,
   type violations) that behavior tests can miss. Tests plus static checks
   are the dual oracle.

## Named refactorings as vocabulary

Each plan item is one named refactoring: extract function, inline function,
rename, move function or field, extract variable, replace conditional with
polymorphism, replace temp with query, and the rest of the catalog at
refactoring.com/catalog. The names matter because a named refactoring has a
bounded, known mechanic, and the evidence on agent-driven refactoring is
blunt: naming the specific refactoring dramatically outperforms open-ended
"improve this code" instructions, which identify few real opportunities and
tend to make structure worse, not better.

The catalog is a vocabulary, not a straitjacket. It is Java-flavored in
origin; apply the intent through the project's language idioms (a React
component extraction, a Python module split, a Go interface narrowing are
all catalog moves wearing local clothes). What is not allowed is an unnamed
mega-step ("restructure the module") that has no bounded mechanic to verify.

## Scope rules

- **The declared target bounds every edit.** Changes spreading beyond the
  initial subject are the line between refactoring and rewriting. Crossing
  it is a stop-and-report, not a judgment call to keep going.
- **Don't refactor code with no reason to change.** The high-value targets
  are code that is both complex and frequently changed. Messy code that
  works, is never read, and is never touched repays nothing. This is the
  YAGNI evidence gate applied to refactoring: each plan item needs a reason
  (a finding, duplication, a documented confusing read, upcoming work here).
- **Aggressive sweeps lose to conservative steps.** The empirical record on
  agent refactoring shows aggressive wide passes resolve some problems while
  introducing more than they fix; tightly scoped conservative passes come
  out net positive. When in doubt, do less.

## The characterization-test protocol (for uncovered targets)

When the target has no meaningful coverage and the user chooses this path
rather than narrowing the target (Feathers' technique for legacy code, where
legacy code is defined as code without tests):

1. Identify the target's public entry points (the seams).
2. For each, write tests that capture what the code actually does now:
   call it with representative and edge inputs, assert the actual observed
   outputs. Run each test, observe it pass, and lock the observed value in.
   Snapshot-style assertions are acceptable here.
3. Do not fix bugs the characterization reveals. The tests pin current
   behavior, bugs included; a behavior change, even a fix, is out of scope.
   Record discovered bugs in the summary for `/issue-triage`.
4. Label these tests as characterization tests in their names or comments,
   and say in the final summary that the safety net is lower-confidence
   than intent-written tests: it proves "unchanged", not "correct", and its
   strength depends on input coverage you chose. Recommend replacing them
   with intent-written tests as the area gets real work.

## Failure modes to catch yourself in

- **Tangling.** Slipping a behavior fix, a feature crumb, or a drive-by bug
  fix into a refactoring step. This is the most common agent failure in the
  field record (over half of observed agent refactorings are tangled into
  unrelated changes). The discipline: record what you spotted, leave it,
  surface it in the summary.
- **Scope drift dressed as momentum.** "While I'm here" is the start of a
  rewrite. The blast radius declared in the plan is the check; the stop rule
  is the enforcement.
- **Patching forward over a red.** A failed step means the mechanic was
  unsafe or coverage was thin. Reverting preserves the green-to-green
  invariant; patching forward abandons it and converts the run into
  unverified rewriting.
- **Refactoring to taste.** Restructuring with no finding, no duplication,
  no standard, and no stated pain behind it. The YAGNI gate exists to catch
  exactly this; aesthetic-only items are deferred.
- **Trusting tests generated from the code being refactored.** A test
  written by reading the implementation and asserting what it does is a
  characterization test and carries that label's lower confidence;
  presenting it as a behavioral spec overstates the net.

## Provenance

The rules above are grounded in the refactoring literature and in the
empirical record on agent-driven refactoring. The full evidence trail, with
sources and validation, is in the Han repository at
`docs/research/refactor-skill-research.md`. Primary anchors: Martin Fowler,
*Refactoring* (definition, catalog, two hats, workflows, scope); William
Opdyke's 1992 thesis (formal behavior preservation); Michael Feathers,
*Working Effectively with Legacy Code* (characterization tests, seams);
Kent Beck ("make the change easy, then make the easy change"); and the
2024-2026 empirical studies of LLM and agent refactoring (named targets over
open-ended prompts, plan-then-execute, incremental verification gates,
conservative over aggressive scope).
