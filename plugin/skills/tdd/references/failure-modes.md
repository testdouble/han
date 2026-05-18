# How an Agent Fakes TDD, and the Discipline That Catches It

An unguided coding agent reliably fakes TDD. The failure is rarely malice — it
is the model optimizing for "tests are green at the end" instead of "the tests
drove the code". Each failure mode below has a symptom you can observe and a
gate in the SKILL body that catches it. When you feel the pull toward any of
these, that pull is the signal the discipline exists to resist.

## 1. Writing the test and the production code together

**Symptom.** The test file and the production file are created or edited in the
same step, then the suite is run once and is green on the first run. Red was
never observed.

**Why it happens.** It is faster and reads as efficient. The model "knows" the
implementation, so writing the failing test first feels like theater.

**Discipline.** The observed-failure gate. Write only the test. Run it. Paste
the real failure output. Only then write production code. A first-run pass is a
hard stop, not a success — diagnose why the test did not fail.

## 2. Never seeing red

**Symptom.** No test run is shown between writing a test and writing the code
that satisfies it. The transcript jumps from "here is the test" to "here is the
implementation".

**Why it happens.** Running the suite mid-cycle feels like overhead when the
outcome seems obvious.

**Discipline.** Every cycle shows two pasted runner outputs at minimum: the red
run (test fails for the intended reason) and the green run (new test passes,
all prior tests still pass). Output is shown, never asserted from memory.

## 3. Whole-feature steps

**Symptom.** One cycle implements the entire feature, then a batch of tests is
written to cover it. Or the test list is converted into many tests at once and
then made to pass together.

**Why it happens.** The model can hold the whole feature at once, so
decomposing into one-behavior steps feels artificially slow.

**Discipline.** Exactly one list item becomes exactly one test per loop. No
more production code than that one test requires. Everything else discovered
goes on the list, deferred. A long red bar (many failing tests at once) is the
symptom; the cure is the one-step rule.

## 4. Skipping the refactor

**Symptom.** Cycles go red, green, red, green. Duplication and structure debt
accumulate. Coding standards are never applied because the test is already
green and the model has moved on.

**Why it happens.** Green feels like done. This is the single most common way
TDD is ruined, per Fowler.

**Discipline.** Refactor is a non-skippable named phase. Either you change
something (remove duplication, apply the standards deferred from green, conform
to ADRs) or you state explicitly "no duplication, structure, or standards issue
this cycle". Silence is not allowed; "green, moving on" is the failure.

## 5. Asserting on implementation detail

**Symptom.** Tests assert internal state, exact private call sequences, or
specific collaborator parameters that are not the behavior under test. The
tests pass review and then break on the next refactor with no behavior change.

**Why it happens.** Mocking everything and asserting calls is mechanical and
looks thorough.

**Discipline.** Assert observable behavior through the public interface. Stub
queries, mock only genuine required collaborations. If a refactor that changes
no behavior breaks a test, the test was asserting implementation — that is a
test defect, not a code defect.

## 6. Applying standards while going green

**Symptom.** During the green phase the model runs naming sweeps, extracts
helpers, and reformats — adding code beyond what the one test needs.

**Why it happens.** "Write clean code" is a strong prior and fires constantly.

**Discipline.** Green obeys only correctness and architectural-placement
constraints (where the code lives, which boundary it must use, which contract
it must honor — violating these is wrong code, not deferrable mess). Stylistic
and structural standards are the refactor hat. Wearing it during green violates
"no more code than is sufficient to pass the test".

## 7. Keeping no test list

**Symptom.** Scenarios are implemented as they occur to the model, or forgotten
entirely. Scope drifts. Speculative cases get built because they came to mind.

**Why it happens.** The model holds context in the conversation instead of in
an explicit artifact, so the list feels redundant.

**Discipline.** The test list is a first-class, visible artifact. Discovered
scenarios are appended and deferred, never implemented in the current loop.
Speculative scenarios are deferred with a reopen trigger (YAGNI), not built.
The list draining is the progress signal; the list ballooning past ~10 open
items is a scope warning the skill flags and records in its summary while
continuing autonomously, not a reason to keep silently grinding through
unbounded scope.

## 8. Refactoring into speculative abstraction

**Symptom.** The refactor step introduces an interface with one implementation,
a configuration knob no caller sets, or a generalization from a single example
— all justified as "for future flexibility".

**Why it happens.** Refactor is read as "make it sophisticated" rather than
"remove the duplication you just made".

**Discipline.** YAGNI is first-class in refactor. Duplication is a hint, not a
command. Abstract only when two or more concrete examples force it (Rule of
Three / Triangulate). Speculative structure is a YAGNI candidate: defer it with
the trigger that would reopen it and tell the user. Refactor removes
duplication; it does not add speculation.

## The one check that catches most of these

Before every production-code edit, you must be able to point to a specific test
that you ran and watched fail for the intended reason in this loop. If you
cannot, you are in one of the failure modes above. Stop and get back to red.
