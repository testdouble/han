# The TDD Loop: Canon, Laws, and Gears

This is the canonical reference for the red-green-refactor mechanics the `/tdd`
skill enforces. It is the single source for the verbatim rules — the SKILL body
links here rather than restating them.

## Robert C. Martin's Three Laws of TDD

Use this phrasing. It resolves the compile-vs-assertion question and the
one-test-at-a-time question explicitly:

1. You are not allowed to write any production code unless it is to make a
   failing unit test pass.
2. You are not allowed to write any more of a unit test than is sufficient to
   fail; and compilation failures are failures.
3. You are not allowed to write any more production code than is sufficient to
   pass the one failing unit test.

The laws operate second-by-second. You iterate them roughly a dozen times
before a single test is complete. You are never more than a few unwritten lines
from a run, and never more than one change from a green or red bar.

## Canon TDD (Kent Beck)

The reference loop. Deviations should be deliberate, not accidental:

1. Write a list of the test scenarios you want to cover.
2. Turn exactly one item on the list into an actual, concrete, runnable test.
3. Change the code to make the test (and all previous tests) pass, adding items
   to the list as you discover them.
4. Optionally refactor to improve the implementation design.
5. Until the list is empty, go back to step 2.

The test list is a first-class artifact. It starts with every operation you
know you need and the null/degenerate version of each. As you make tests pass,
the implementation implies new tests and refactorings — write them on the list,
do not implement them now. Items left when the session ends are handled
explicitly: continue them next session, or move clearly out-of-scope
refactorings to a "later" list. A test you can think of that might not work is
never moved to "later".

## The mantra

- **Red** — write a small test that does not work, and perhaps does not even
  compile at first.
- **Green** — make the test work quickly, committing whatever sins are
  necessary in the process (duplication, hard-coded values, ugliness).
- **Refactor** — eliminate the duplication created in just getting the test to
  work.

"Committing sins" means duplication and poor structure are tolerated
*temporarily*, to be removed in refactor. It does not mean writing code that
violates an architectural boundary or a correctness contract — that is not a
sin you clean up later, it is the wrong code. This is why the `/tdd` skill
honors correctness and placement standards during green but defers stylistic
and structural conformance to refactor.

## Two hats

Making a test pass and refactoring are different activities done at different
times. "Make it run, then make it right." Mixing refactoring into the
make-it-pass step is the classic two-hats mistake. Refactor only when every
test is green. A structural change while a test is red is not a refactor.

## The observed-failure gate

The single highest-value invariant, derived from Law 1 + Law 2 + Beck's
test-first ordering: no production-code change is permitted unless a test has
been run and observed to fail for the intended reason in this loop. A test that
passes the first time it is ever run was never red — that is a process
violation signal, not a success. Diagnose it: the test does not exercise the
behavior, or the behavior already exists.

## Implementation gears (choosing step size)

TDD is not blind rule-following; it is choosing step size and feedback by
conditions. Three gears, smallest step last:

- **Obvious Implementation (second gear).** You are certain how to implement
  the operation. Type the real code. Guardrail: if you start getting surprised
  by red bars, downshift immediately and take smaller steps.
- **Fake It (small step).** You have a broken test and are not certain. Return
  a constant. Once green, generalize the constant into an expression. The
  duplication between test and code is removed in refactor — this is why Fake
  It does not violate "no unneeded code".
- **Triangulate (smallest step).** You are really unsure of the right
  abstraction. Force it: add a second concrete example with different values so
  one parameter or branch cannot satisfy both, and let the two examples drive
  the generalization. Use only when genuinely unsure; otherwise Obvious
  Implementation or Fake It.

The tougher or less familiar the problem, the smaller the step. Reserve Obvious
Implementation for genuinely simple, certain operations.

## How much to test

Test count is driven by the confidence the code needs, not by a coverage
number. If knowledge of the implementation gives real confidence in the absence
of a test, that test may not be worth writing. Tests that execute code but
assert nothing meaningful are not TDD tests — start each test from the
assertion (Assert First) and derive the expected value independently from the
specification, never by pasting back the program's own output.

## Sources

- Kent Beck, *Test-Driven Development: By Example* (2002): Test List,
  Implementation Strategies (Fake It, Triangulate, Obvious Implementation),
  Assert First, step size and feedback.
- Kent Beck, "Canon TDD" (tidyfirst.substack.com): the five-step loop and the
  named mistakes (two-hats, batch-converting the list, abstracting too soon).
- Robert C. Martin, "The Three Rules of TDD" and "The Cycles of TDD"
  (blog.cleancoder.com): the Three Laws and the nested cycle timescales.
- Martin Fowler, "Test Driven Development" and "Self Testing Code"
  (martinfowler.com): red-green-refactor summary; refactor is the most-skipped
  step; run the whole suite frequently.
