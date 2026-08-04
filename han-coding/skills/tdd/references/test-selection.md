# Choosing the Next Test: TPP and ZOMBIES

This is the canonical reference for the test-selection heuristics the `/tdd` skill uses when it orders the test list
(Step 2) and picks the next item (Step 3). The loop tells you to write a failing test and make it pass. It does not tell
you which test to write next. The Transformation Priority Premise and ZOMBIES both answer exactly that question, and
they answer it the same way:

> Choose the next test that can be satisfied by the simplest transformation of the code.

The core principle (Robert C. Martin): **as the tests get more specific, the code gets more generic.** You steer that
progression by selecting tests in order of the transformation they demand — simplest first. These are test-selection
heuristics, applied while choosing what to test next. They are never a menu for hacking an implementation to green after
the test is chosen.

## The Transformation Priority Premise (TPP)

Transformations are the counterpart of refactorings: a refactoring changes structure without changing behavior; a
transformation changes behavior by generalizing structure. TPP ranks the transformations a new passing test can force on
the code, from simplest to most complex:

| #   | Transformation               | A test at this rank forces…                          |
| --- | ---------------------------- | ---------------------------------------------------- |
| 1   | `{} → nil`                   | code to exist at all, returning nil/null             |
| 2   | `nil → constant`             | a fixed constant value                               |
| 3   | `constant → constant+`       | a simple constant to become a more complex one       |
| 4   | `constant → scalar`          | a constant to become a variable or argument          |
| 5   | `statement → statements`     | more unconditional statements                        |
| 6   | `unconditional → if`         | the execution path to split with a conditional       |
| 7   | `scalar → array`             | a variable to become an array                        |
| 8   | `array → container`          | an array to become a richer container (list/map/set) |
| 9   | `statement → tail-recursion` | tail recursion                                       |
| 10  | `if → while`                 | a conditional to become a loop                       |
| 11  | `statement → recursion`      | general (non-tail) recursion                         |
| 12  | `expression → function`      | an expression to become a function or algorithm      |
| 13  | `variable → assignment`      | a variable's value to be reassigned or mutated       |
| 14  | `case`                       | a new case or else added to an existing conditional  |

This is the canonical fourteen-transformation list from the original article. Martin notes the ordering is
language-specific (in an imperative language you might rank iteration and assignment above recursion) and that "there
are likely others." He also frames it as a _premise_, not a theorem — an informal ranking, not a law. Treat the ranks as
a strong default and apply design judgment when several simplest-first paths exist.

## Using the ranking to pick the next test

- When several candidate tests remain on the list, **write the one whose passing requires the highest-priority
  (simplest) transformation**. A test that needs only `nil → constant` comes before one that needs `unconditional → if`,
  which comes before one that needs `if → while`.
- If the only test you can think of would force a low-priority transformation (a loop, recursion, a whole algorithm)
  early, that is the signal a **simpler test is missing** — find it, add it to the list, and write it first.
- When two candidates demand the same transformation, the ranking has no opinion. Break the tie toward the smaller input
  or the example the user supplied; either keeps the step small, and the loser stays on the list.
- The maintained test list is what makes this work: TPP selects by _scanning_ the behaviors not yet tested and comparing
  the transformations they would force. This is one more reason the test list is a first-class artifact.

Why select tests this way:

- **Simpler designs.** The code grows by the smallest generalization each cycle: a constant before a scalar, an `if`
  before a `while`.
- **Fewer impasses.** A premature low-priority test can force the implementation into a corner that a simpler ordering
  would have avoided.
- **Small, reversible steps.** Every green is one small transformation away from the last green, which keeps the loop's
  step size honest.

## The decision-point rule

TPP's sharpest use is at a decision point: when more than one transformation could make the current failing test pass,
prefer the one **higher on the list**. Martin demonstrates the stakes with a sort. At "two elements out of order" you
can compare-and-swap (an assignment, near the bottom of the list) or compare and return a new array (no assignment).
Follow the swap and you derive bubble sort; avoid the low-priority assignment and quicksort "almost falls out
inevitably." The same failing test, two transformations, two very different algorithms — the ranking is what tips you
toward the better one.

Bending the ranking is sometimes correct. When a transformation legitimately needs a helper to land (a recursive step
needs a function that takes the tail of a collection, say), taking that step is fine if it is the smallest _real_
increment available. The goal is the next smallest increment, not literal obedience to the table.

A single test may also legitimately force a small cluster of transformations at once — a loop usually brings an
accumulator assignment with it, and a new scalar often arrives inside a new conditional. Compare candidates by the
deepest-ranked transformation in the cluster each would force; the ranking still orders the tests even when no test maps
to exactly one row.

## ZOMBIES: the same idea as a concrete ordering

James Grenning's ZOMBIES mnemonic makes the simplest-first order memorable. **ZOM** (Zero, One, Many) is the core
progression; **BIES** covers what else to select for as you go:

| Letter | Stands for           | Choose a test that…                                                  |
| ------ | -------------------- | -------------------------------------------------------------------- |
| **Z**  | Zero                 | exercises the empty / zero / null case                               |
| **O**  | One                  | exercises exactly one element or occurrence                          |
| **M**  | Many / More          | exercises many — the test that forces the loop or collection         |
| **B**  | Boundary behaviors   | probes limits: first/last, off-by-one, min/max                       |
| **I**  | Interface definition | pins the smallest viable signature the caller needs                  |
| **E**  | Exceptional behavior | drives invalid input and failures at the public boundary             |
| **S**  | Simple               | keeps each scenario, and the step it implies, as simple as it can be |

Pick tests **Z → O → M** for the happy path. The interface (**I**) emerges from the very first test; boundaries and
exceptions (**B**, **E**) fill in once the core generalization exists. Never select a Many test before a One test has
forced the code to handle a single case — Zero → One → Many is exactly TPP's simplest-transformation-first ordering,
made concrete.

Rule of thumb: each test should add **one** small new behavior and demand the **smallest** possible generalization. If
the only remaining test forces a large leap, a smaller test is missing between it and the last green.

## How this composes with the rest of the loop

- **User value picks the behavior; TPP/ZOMBIES picks the test.** Step 2 orders the list outside-in by user value — the
  next _behavior_ is the most important thing the system does not yet do. When driving that behavior expands into
  several candidate tests (the zero case, the one case, the many case, the boundaries), simplest-transformation-first
  governs their order. The two orderings answer different questions and do not compete.
- **This is how you find Beck's "one step test."** Step 3 says to pick an item that teaches you something and that you
  can implement in one cycle. TPP and ZOMBIES are the deterministic way to find that item: the test needing the simplest
  transformation _is_ the one-step test.
- **The gears stay small because the tests were chosen small.** Fake It is `nil → constant`. Triangulate adds the second
  example that forces `constant → scalar`. A test chosen simplest-first bounds how much the green step can require; a
  test chosen too coarse is what forces Obvious Implementation on something that deserved smaller steps.
- **A first-run pass can mean the code has generalized.** When a chosen test passes on its first run, the
  observed-failure gate trips and one diagnosis is "the behavior already exists." In TPP terms the implementation has
  gone generic ahead of the tests — the loop or abstraction already covers this case. Cross the item off per the gate;
  the passing test stays as documentation of the boundary it confirms.

Diagnostic signals, all about test choice:

- _About to write a Many/loop test first?_ You skipped Zero and One. The Zero test needs only `nil → constant`.
- _The only test you can think of forces recursion or a `while`?_ A simpler test is missing; a One-case test usually
  drops the required transformation to `unconditional → if` or `statement → statements`.
- _A test forces a huge implementation leap?_ It is too coarse. Add a smaller test between it and the last green.
- _The implementation came out over-engineered?_ The test selected was too big. Back up and choose a simpler one.
- _The chosen test will not even run cleanly_ (a cascading error rather than a clean assertion failure)? Do not force
  it. Put it back on the list, pick an item that fails cleanly, and return to the deferred item once the code has caught
  up.

## Worked example: `sum(numbers)`

Each row is the next behavior chosen because it needs the simplest remaining transformation:

| Order | Behavior chosen (ZOMBIES)          | Transformation it drives (TPP)                              |
| ----- | ---------------------------------- | ----------------------------------------------------------- |
| 1     | **Z**ero — `sum([]) == 0`          | `nil → constant`: `return 0`, the simplest available        |
| 2     | **O**ne — `sum([5]) == 5`          | `constant → scalar`: read the single element                |
| 3     | **M**any — `sum([5, 3]) == 8`      | `if → while`: the first test that genuinely forces the loop |
| 4     | **B**oundary — `sum([-1, 1]) == 0` | none — confirms the generalization holds                    |
| 5     | **E**xception — `sum(None)` raises | `unconditional → if`: a guard at the public boundary        |

Each row adds exactly one behavior and uses the simplest transformation that keeps the suite green. Row 3 is where Many
forces the generic loop — and not a moment earlier. Row 4 is a confirming test: it passes without a production change,
which is the "behavior already exists" arm of the observed-failure gate doing its job.

## Sources

- Robert C. Martin, "The Transformation Priority Premise" (blog.cleancoder.com, 2013): transformations as the
  counterpart of refactorings, the fourteen-rank list, the language-specificity and premise-not-theorem caveats.
- Robert C. Martin, "Transformation Priority and Sorting" (blog.cleancoder.com, 2013): the decision-point rule and the
  bubble-sort vs quicksort demonstration.
- Robert C. Martin, "The Cycles of TDD" (blog.cleancoder.com, 2014): "as the tests get more specific, the code gets more
  generic."
- James Grenning, "TDD Guided by ZOMBIES" (blog.wingman-sw.com): the Zero, One, Many, Boundaries, Interface, Exceptions,
  Simple mnemonic and ordering.
- Jeff Langr, _Modern C++ Programming with Test-Driven Development_ (Pragmatic Bookshelf): the maintained test list as
  near-essential to TPP, bending the ranking for the smallest real increment, and deferring a test that will not fail
  cleanly.
