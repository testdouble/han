# How an Agent Fakes TDD, and the Discipline That Catches It

## Contents

- 1. Writing the test and the production code together
- 2. Never seeing red
- 3. Whole-feature steps
- 4. Skipping the refactor
- 5. Asserting on implementation detail
- 6. Applying standards while going green
- 7. Keeping no test list
- 8. Refactoring into speculative abstraction
- 9. Asserting the bug instead of the fix
- 10. Making a test pass by changing code the ticket does not own
- The one check that catches most of these

An unguided coding agent reliably fakes TDD. The failure is rarely malice — it is the model optimizing for "tests are
green at the end" instead of "the tests drove the code". Each failure mode below has a symptom you can observe and a
gate in the SKILL body that catches it. When you feel the pull toward any of these, that pull is the signal the
discipline exists to resist.

## 1. Writing the test and the production code together

**Symptom.** The test file and the production file are created or edited in the same step, then the suite is run once
and is green on the first run. Red was never observed.

**Why it happens.** It is faster and reads as efficient. The model "knows" the implementation, so writing the failing
test first feels like theater.

**Discipline.** The observed-failure gate. Write only the test. Run it. Paste the real failure output. Only then write
production code. A first-run pass is a hard stop, not a success — diagnose why the test did not fail.

## 2. Never seeing red

**Symptom.** No test run is shown between writing a test and writing the code that satisfies it. The transcript jumps
from "here is the test" to "here is the implementation".

**Why it happens.** Running the suite mid-cycle feels like overhead when the outcome seems obvious.

**Discipline.** Every cycle shows two pasted runner outputs at minimum: the red run (test fails for the intended reason)
and the green run (new test passes, all prior tests still pass). Output is shown, never asserted from memory.

## 3. Whole-feature steps

**Symptom.** One cycle implements the entire feature, then a batch of tests is written to cover it. Or the test list is
converted into many tests at once and then made to pass together.

**Why it happens.** The model can hold the whole feature at once, so decomposing into one-behavior steps feels
artificially slow.

**Discipline.** Exactly one list item becomes exactly one test per loop. No more production code than that one test
requires. Everything else discovered goes on the list, deferred. A long red bar (many failing tests at once) is the
symptom; the cure is the one-step rule.

## 4. Skipping the refactor

**Symptom.** Cycles go red, green, red, green. Duplication and structure debt accumulate. Coding standards are never
applied because the test is already green and the model has moved on.

**Why it happens.** Green feels like done. This is the single most common way TDD is ruined, per Fowler.

**Discipline.** Refactor is a non-skippable named phase. Either you change something (remove duplication, apply the
standards deferred from green, conform to ADRs) or you state explicitly "no duplication, structure, or standards issue
this cycle". Silence is not allowed; "green, moving on" is the failure.

## 5. Asserting on implementation detail

**Symptom.** Tests assert internal state, exact private call sequences, or specific collaborator parameters that are not
the behavior under test. The tests pass review and then break on the next refactor with no behavior change.

**Why it happens.** Mocking everything and asserting calls is mechanical and looks thorough.

**Discipline.** Assert observable behavior through the public interface. Stub queries, mock only genuine required
collaborations. If a refactor that changes no behavior breaks a test, the test was asserting implementation — that is a
test defect, not a code defect.

## 6. Applying standards while going green

**Symptom.** During the green phase the model runs naming sweeps, extracts helpers, and reformats — adding code beyond
what the one test needs.

**Why it happens.** "Write clean code" is a strong prior and fires constantly.

**Discipline.** Green obeys only correctness and architectural-placement constraints (where the code lives, which
boundary it must use, which contract it must honor — violating these is wrong code, not deferrable mess). Stylistic and
structural standards are the refactor hat. Wearing it during green violates "no more code than is sufficient to pass the
test".

## 7. Keeping no test list

**Symptom.** Scenarios are implemented as they occur to the model, or forgotten entirely. Scope drifts. Speculative
cases get built because they came to mind.

**Why it happens.** The model holds context in the conversation instead of in an explicit artifact, so the list feels
redundant.

**Discipline.** The test list is a first-class, visible artifact. Discovered scenarios are appended and deferred, never
implemented in the current loop. Speculative scenarios are deferred with a reopen trigger (YAGNI), not built. The list
draining is the progress signal; the list ballooning past ~10 open items is a scope warning the skill flags and records
in its summary while continuing autonomously, not a reason to keep silently grinding through unbounded scope.

## 8. Refactoring into speculative abstraction

**Symptom.** The refactor step introduces an interface with one implementation, a configuration knob no caller sets, or
a generalization from a single example — all justified as "for future flexibility".

**Why it happens.** Refactor is read as "make it sophisticated" rather than "remove the duplication you just made".

**Discipline.** YAGNI is first-class in refactor. Duplication is a hint, not a command. Abstract only when two or more
concrete examples force it (Rule of Three / Triangulate). Speculative structure is a YAGNI candidate: defer it with the
trigger that would reopen it and tell the user. Refactor removes duplication; it does not add speculation.

## 9. Asserting the bug instead of the fix

**Symptom.** The work is a fix to existing broken behavior, and the test asserts the error the bug raises (or the wrong
value it returns) rather than the desired correct result. It passes on first run because the bug is still present, or it
goes red for a reason other than "correct behavior not produced". Either way the gate looks satisfied, and fixing the
code then breaks the test.

**Why it happens.** The model describes the behavior it observes now. For a bug the observable behavior today _is_ the
error, so "assert the observable outcome" reads as "assert that the error is raised".

**Discipline.** A regression test asserts the _desired correct_ behavior: it fails because the bug is present and passes
once the fix lands. A bug-fix test that is green before the fix is the tell — rewrite it, do not cross the item off. The
boundary: asserting that the code raises is the _right_ test when raising is the specified desired behavior (raise on
invalid input). The failure mode is asserting the error that _is_ the bug being fixed.

## 10. Making a test pass by changing code the ticket does not own

**Symptom.** A list item goes red exactly as designed, and green arrives by editing a shared library, engine, or package
that other applications consume. The observed-failure gate is satisfied, every test is green, and the branch carries a
production change the ticket never authorized. It often compounds: a later test leans on the new behavior for a
deterministic setup, so the out-of-scope change becomes load-bearing for work that could have arranged its own fixture.

**Why it happens.** The item usually arrives carrying authority. A test plan or an analysis agent found something real,
labeled it CRIT, and the label reads as permission. The red is genuine, the fix is small, and the finding is honest, so
every local signal says proceed. Nothing in the moment asks the one question that matters.

**Discipline.** The scope gate. A genuine red proves the behavior is missing, never that this build owns producing it.
Before every production edit, name the file you are about to change and test it against the scope boundary recorded in
Step 1. A severity label ranks a finding's importance and says nothing about whose ticket it belongs to; an item whose
own text names a production change as a prerequisite is that change wearing a test's clothes. Work the resolution
ladder: redesign the test so it does not need the out-of-scope behavior, defer the item as its own ticket, and escalate
only when the requested behavior cannot be delivered without it. A test that needs the change only to make a fixture
deterministic never reaches the second rung.

## The one check that catches most of these

Before every production-code edit, you must be able to point to a specific test that you ran and watched fail for the
intended reason in this loop, and to a scope boundary that contains the file you are about to change. If the first is
missing, you are in one of failure modes 1 through 9: stop and get back to red. If the second is missing, you are in
failure mode 10: stop and work the resolution ladder.
