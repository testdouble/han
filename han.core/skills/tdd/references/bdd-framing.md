# BDD Framing for the TDD Loop

BDD is the reason this skill frames every test as a *behavior*. Dan North
started replacing the word "test" with "behaviour" because almost every
misunderstanding of TDD traced back to the word "test" — where to start, what
to test, how much, what to name it, why a failure matters. The framing below is
how `/tdd` answers those questions mechanically.

## Name tests for behavior, in the project's convention

A test name describes an observable behavior of the unit, not a method or an
implementation detail. North's diagnostic: if you cannot phrase the name as a
sentence about what the thing *should do*, the behavior may belong elsewhere.
"should" also keeps the premise challengeable — when a behavior test fails, ask
"should it? really?": is the code wrong, or is the asserted behavior now out of
date?

**Surface syntax follows the project, not a literal "should".** BDD governs the
*focus* (observable behavior), not the spelling. If the project uses
`it("...")`, `test_...`, `describe/it`, xUnit `TestXxx`, Go `TestXxx` with
`t.Run("when ...")`, or a discovered coding standard that mandates a naming
pattern, use that. The discovered convention and any coding standard always win
over the word "should". What does not change: the name states a behavior and an
expected outcome, never an implementation step.

## Given-When-Then maps to Arrange-Act-Assert

A scenario is one test. The three clauses are the three phases of that test:

- **Given** — the state of the world before the behavior. The arrange/setup.
  Typically something that already happened. Commands that establish state.
- **When** — the one event or action under test. The act. Exactly one per
  scenario. If you need an "and" in the When, you probably have two scenarios.
- **Then** — the expected, observable outcome. The assert. It must be on an
  observable output: a return value, a visible effect, a message or record
  that leaves the unit. Never on internal or private state.

Keep scenarios declarative, not imperative. "When the customer requests cash"
is a behavior. "When the user clicks #submit then waits 200ms" is an
implementation procedure that will break on every UI change without the
behavior changing. Declarative scenarios survive refactoring; imperative ones
do not.

## Outside-in: the double loop

BDD-framed TDD is two nested loops:

- **Outer loop** — a failing acceptance test for a user-observable behavior at
  a system boundary, written from the perspective of someone using the system.
  Slow loop (a feature's worth of work). It goes green only when every inner
  behavior is implemented with real code.
- **Inner loop** — ordinary red-green-refactor that makes the acceptance test
  progressively pass.

The procedure for a user-facing item: write the failing acceptance test,
identify the entry point that gets called first, start implementing it, and
when it needs a collaborator, introduce that collaborator as a test double at
the call site. The collaborator's interface is *discovered by what the caller
needs*, not designed up front. When the entry point's test passes, drop down
and make the next mocked collaborator real. The acceptance test passing last,
against real implementations, is the proof no collaborator was forgotten.

Not every list item is user-facing. A pure utility or an internal algorithm has
no meaningful acceptance boundary — the inner loop alone is correct there.
Making the outer loop conditional on whether the behavior is user-observable is
correct scaling, not a shortcut.

## Test doubles: mock commands, stub queries

The five doubles (Meszaros, via Fowler): dummy (passed, never used), fake
(working but shortcut implementation), stub (canned answers to queries), spy
(a stub that records calls), mock (pre-programmed with expectations that form a
specification). Only mocks insist on behavior verification; the rest use state
verification.

The working rule for the loop:

- **Stub a query.** The collaborator only feeds data the unit needs to produce
  its outcome. Assert on the resulting state/output, not on the call.
- **Mock a command / required collaboration.** The interaction *is* the
  behavior under test (the unit must tell a collaborator to do something).
  Assert the interaction.

Default to real objects unless using the real thing is awkward (the classicist
default). Over-mocking couples the test to the implementation: mockist tests
break on refactor even when behavior did not change, because they specify exact
calls and parameters that are not the behavior under test. If a mock is only
there to feed a value, it should have been a stub. If exact call order or
parameters are not the behavior, do not assert on them.

## BDD-flavored failure modes

- **Gherkin/test that describes UI mechanics** ("clicks the button, fills the
  field") instead of behavior. Rewrite functionally: name the intent, not the
  clicks.
- **Asserting internal state** in the Then. Assert observable output only.
- **Imperative scenario** that encodes how instead of what. Make it
  declarative; logic changes should touch step definitions, not scenario text.
- **Testing the mock instead of the behavior** — asserting call mechanics that
  are not the behavior under test, so the test breaks on refactor with no
  behavior change. Demote the mock to a stub, or assert the observable outcome
  instead.
- **Back-filling scenarios from code.** Scenarios come from concrete examples
  of intended behavior, decided before the code, not reverse-engineered from
  what was written.

## Sources

- Dan North, "Introducing BDD" (dannorth.net): behaviour over "test", the
  should-sentence template, "should it? really?", "what's the next most
  important thing the system doesn't do?".
- Martin Fowler, "GivenWhenThen", "Mocks Aren't Stubs", "UnitTest"
  (martinfowler.com): GWT mapped to Arrange-Act-Assert; stub vs mock; classicist
  vs mockist; coupling risk of over-mocking.
- Steve Freeman & Nat Pryce, *Growing Object-Oriented Software, Guided by
  Tests*: the outer/inner double loop, discovering interfaces via mocks at the
  call site, acceptance test green only with real implementations.
- Cucumber Gherkin reference and "Writing better Gherkin": Given/When/Then
  semantics, observable-output rule, declarative over imperative.
