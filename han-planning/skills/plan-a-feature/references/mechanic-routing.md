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

One exception to rule 3, and only one. When the mechanic is a contract two or more components must independently agree
on — a file or wire format, a persisted schema, an API or event payload, a module or CLI signature, a config schema, an
error or exit contract, an identity convention — record it as an Open Item naming what is delegated and to which stage.
Still do not settle it: an Open Item is a delegation, not a behavioral commitment, so the spec stays behavior-only.

The exception exists because rule 3's silence and rule 3's correctness are separable. The mechanic genuinely does not
belong in the spec, and a contract that leaves this stage unrecorded reaches `plan-implementation` as nothing at all,
which is how a shared format ends up invented mid-build. Recording it costs one Open Item and gives the next stage an
item it must close. See [contract-pinning-rule.md](../../../references/contract-pinning-rule.md).
