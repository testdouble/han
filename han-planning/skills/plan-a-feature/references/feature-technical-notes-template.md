# Feature Technical Notes: {Feature Name}

<!--
This file captures implementation mechanics that are load-bearing for the
behavioral specification of {Feature Name} — where naming a specific mechanic
was the only way to correctly specify a feature-level behavior, and the
mechanic is NOT discoverable from the code repo alone. Behavioral statements
live in [../feature-specification.md](../feature-specification.md); this file
is a secondary reference artifact consumed by plan-implementation and by
readers who ask "why this mechanic and not another?"

This file only exists when at least one T# entry qualifies. If the interview
and review-team rounds produced no load-bearing mechanics that needed to be
named, this file was not created.

WHAT BELONGS HERE
- Mechanics whose choice changes observable behavior — delivery ordering,
  durability, consistency, visibility timing, error propagation boundaries.
- Constraints imposed by an external protocol, library, or subsystem that
  the spec's behavior must respect.
- Context that a reader (or plan-implementation specialist) could not
  reconstruct from the current code repo alone.

WHAT DOES NOT BELONG HERE
- Mechanics already visible in the code repo — those are discoverable.
  Point plan-implementation at the code; do not duplicate it here.
- Mechanics that do not affect observable behavior — those are pure
  implementation choices and belong in the implementation plan.
- Library names, framework choices, or language primitives used purely
  because they are already in the stack — those are discoverable from the
  project's existing configuration.

Cross-referencing invariants:
- `Supports decisions:` — D# IDs from [decision-log.md](decision-log.md) whose
  behavioral commitment is enabled by this mechanic. `—` if the note is pure
  context (e.g., "this is how the existing protocol works") with no decision
  driving it.
- `Driven by findings:` — F# IDs from [team-findings.md](team-findings.md)
  that caused this note to be added. `—` if the note was captured during
  the initial interview (Step 4) and not later reshaped by a review finding.
- `Referenced in spec:` — sections of
  [../feature-specification.md](../feature-specification.md) that cite this
  note with an inline `([T#](artifacts/feature-technical-notes.md#...))` link.

Any time a T# is added or edited here, update the matching `Linked technical
notes:` field on the related D# entries in decision-log.md, the
`Affected tech-notes:` field on the related F# entries in team-findings.md,
and the inline `([T#](...))` links in ../feature-specification.md so all
four files stay in sync.
-->

## T1: {Short mechanic title}

- **Context:** <!-- One or two sentences naming the spec section and the behavioral question whose correct specification required this note. -->
- **Technical detail:** <!-- The actual mechanic being captured — enough that a plan-implementation specialist can honor it, no more. -->
- **Supports decisions:** <!-- D# IDs from decision-log.md, or — -->
- **Driven by findings:** <!-- F# IDs from team-findings.md, or — -->
- **Referenced in spec:** <!-- feature-specification.md section headings that cite this note -->

## T2: {Short mechanic title}

- **Context:** ...
- **Technical detail:** ...
- **Supports decisions:** ...
- **Driven by findings:** ...
- **Referenced in spec:** ...

<!-- Add more notes as needed (T3, T4, ...). Number in the order the notes were captured. -->
