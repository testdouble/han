# Artifact Invariants

The cross-reference invariants every artifact in the plan folder holds, and the one decision-classification pass.
Step 8's synthesis preserves these; it does not restate them.

- **Classify every decision as full or trivial, once, now.** This is the only classification pass; Step 5 deliberately
  wrote every decision in full form and deferred the split to here, because two of the promotion signals (a driving
  finding, a linked technical note) do not exist until the review round returns. Full: has a rejected alternative a
  reasonable engineer would plausibly have chosen (not an obvious or strawman one), evidence beyond the user's framing,
  driven-by-findings, linked tech-notes, or dependent decisions. Trivial: settled directly by the user's framing or an
  obvious convention with no alternative worth discussing. Full decisions stay under `## Full decisions` with the
  structured fields. Trivial decisions move to `## Trivial decisions` as a one-line bullet, with an optional single-clause
  parenthetical when an obvious alternative was discarded
  (`D#: {title} — {outcome} (considered {alternative}; rejected because {one clause}). — Referenced in spec: {sections}.`);
  see [decision-log-template.md](./decision-log-template.md) for the exact format and the "if unsure, treat as
  full" backstop. D# numbers do not change during classification, so every spec inline link keeps resolving.
- Record or update decisions in `artifacts/decision-log.md` with full rationale, evidence, and rejected alternatives.
- Record or update findings in `artifacts/team-findings.md` with resolutions.
- Record or update technical notes in `artifacts/feature-technical-notes.md` — creating the file lazily if it does not
  yet exist and at least one `T#` qualifies under synthesis, or leaving it absent if no qualifying mechanic was
  captured.
- Preserve the cross-reference invariants across all files:
  - Every `D#` in `artifacts/decision-log.md` lists its driving `F#` IDs (`Driven by findings:`), its supporting `T#`
    IDs (`Linked technical notes:`), dependent decisions, and the spec sections that reference it
    (`Referenced in spec:`).
  - Every `F#` in `artifacts/team-findings.md` lists its affected `D#` IDs (`Affected decisions:`), affected `T#` IDs
    (`Affected tech-notes:`), and the spec sections it changed (`Changed in spec:`).
  - Every `T#` in `artifacts/feature-technical-notes.md` lists its supporting `D#` IDs (`Supports decisions:`), driving
    `F#` IDs (`Driven by findings:`), and the spec sections that reference it (`Referenced in spec:`).
  - Every non-obvious behavior in `feature-specification.md` has its inline `([D#](artifacts/decision-log.md#...))`
    link. Every sentence whose correct behavior depends on a captured mechanic has its inline
    `([T#](artifacts/feature-technical-notes.md#...))` link.
  - The spec itself continues to obey the operating-principles rule — no language primitives, file/line references,
    function/class names, library mechanics, implementation patterns, or internal flag names in behavioral sentences.
    Any leak the han-core:plan-synthesizer finds is rewritten in place during synthesis.
  - The `## Cut for Scope` section carries every scope-gate cut with what it would have done and the boundary citation,
    and no entry appears in both that section and `## Deferred (YAGNI)`.
  - The `Visual Reference` table lists every item the boundary record records as received, under that exact heading, with
    an inline embed beside the prose describing each state.
