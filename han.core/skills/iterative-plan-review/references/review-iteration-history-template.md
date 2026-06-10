# Review Iteration History: {Plan Name}

<!--
This file records how the review of {Plan Name} evolved across iteration rounds.
Findings raised during each round live in [review-findings.md](review-findings.md),
and the primary plan lives one directory up (this file lives in the plan folder's
`artifacts/` subfolder) — consult the plan's "Review History" section for the link.

Iteration caps (see the iterative-plan-review skill) scale with plan size:
- Small (lightweight mode) caps at 1 iteration.
- Medium (team mode) caps at 2 rounds; large caps at 3 rounds.

A round entry is appended as each iteration closes; `Findings raised:` and
`Changed in plan:` are filled in at write time, not backfilled.

Cross-referencing invariants:
- `Findings raised:` — F# IDs from [review-findings.md](review-findings.md)
  that this round produced. `—` if the round produced no findings
  (e.g., a stability check that confirmed no further changes were needed).
- `Changed in plan:` — sections of the primary plan file that this round
  updated. `—` if the plan did not change this round.
- `Changed in tech-notes:` — T# IDs in
  [feature-technical-notes.md](feature-technical-notes.md) that this round added or
  edited. Applies ONLY in spec-aware mode when the plan under review is a
  `feature-specification.md`. `—` in all other contexts.

Any time a round is added or edited here, update the matching F# entries in
review-findings.md and the inline ([F#](...)) markers in the plan file. In
spec-aware mode, also keep feature-technical-notes.md in sync.
-->

## R1: {Short round title — e.g., "Parallel specialist review" or "Iteration 1 — assumption audit"}

- **Mode:** <!-- lightweight / team -->
- **Spec-aware mode:** <!-- engaged / not engaged. `engaged` only when the plan under review is a feature-specification.md. -->
- **Specialists engaged:** <!-- Team mode: list every agent in this round. Lightweight mode: `self-review` -->
- **New input provided:** <!-- For round 1, typically "initial plan read and project context". For later rounds, summarize what prior-round findings and plan edits were handed back so agents do not re-raise resolved issues. -->
- **What was checked:** <!-- Assumptions audited, overlaps probed, ambiguities surfaced, edge cases explored. Reference the [iteration-checklist.md](./iteration-checklist.md) sections exercised for lightweight mode. -->
- **Questions surfaced to user:** <!-- Ambiguities escalated this round with their recommended answers, or — if nothing was escalated -->
- **Findings raised:** <!-- F# IDs from review-findings.md, or — -->
- **Changed in plan:** <!-- plan sections updated this round, or — -->
- **Changed in tech-notes:** <!-- spec-aware mode only: T# IDs in feature-technical-notes.md added or edited this round, or — -->
- **Stability assessment:** <!-- Structural changes this round (high / medium / low), probability of meaningful improvement next round (above / below 80%), recommendation (continue / stop) — or `n/a` if the mode does not require it -->
- **Next-step recommendation:** <!-- "Continue to round N+1 — re-engage {agent(s)} with {new context}" / "Stop — plan has converged" / "Blocked pending user input on F# findings" -->

## R2: {Short round title}

- **Mode:** ...
- **Spec-aware mode:** ...
- **Specialists engaged:** ...
- **New input provided:** ...
- **What was checked:** ...
- **Questions surfaced to user:** ...
- **Findings raised:** ...
- **Changed in plan:** ...
- **Changed in tech-notes:** ...
- **Stability assessment:** ...
- **Next-step recommendation:** ...

<!-- Add more rounds as needed. Lightweight mode caps at R5; team mode caps at R4. -->
