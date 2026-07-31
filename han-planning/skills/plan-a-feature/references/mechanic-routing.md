# Routing Implementation Mechanics

Where a surfaced implementation mechanic goes. Step 4 applies this while settling a
decision, and Step 7 applies the same three-way classification to any mechanic a review finding surfaces.

When settling a decision surfaces an implementation mechanic (a specific library, language primitive, data shape,
protocol detail, concurrency choice, or file-level pattern), classify the mechanic BEFORE writing the spec sentence and
route it to the correct home:

1. **Does the mechanic change what the user or system observably experiences** — ordering, durability, delivery
   guarantees, consistency, visibility timing, error-visibility? If yes, settle the behavioral consequence in the spec
   and capture the enabling mechanic as a `T#` candidate (see capture discipline below). The spec sentence must state
   the behavioral consequence on its own; the `T#` link only supplies the mechanic. A reader who does not click through
   to the note must still get the behavior right.
2. **Is the mechanic already discoverable in the code repo** — an existing pattern, an in-use library, a documented
   convention? If yes, settle the question behaviorally in the spec, cite the evidence source under the D#'s `Evidence:`
   field, and do NOT create a `T#` note. `plan-implementation` will find the code.
3. **Otherwise the question is pure implementation.** Do not settle it here. Do not put it in the spec, tech-notes, or
   Open Items. `plan-implementation` owns it.
