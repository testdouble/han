# Implementation Decision Log: {Feature Name}

<!--
This file records every implementation decision committed while planning {Feature Name}.
Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md) —
this file captures the question, rationale, evidence, and rejected alternatives for each decision.
Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).

## Two-tier format: full vs. trivial decisions

Every decision is classified as **full** or **trivial** before it is recorded.

A decision is **full** when any of these signals is present:
- it has at least one rejected alternative;
- the rationale rests on evidence beyond the user's framing (codebase pattern,
  ADR, coding standard, prior decision, or specialist finding);
- it was driven by, or later changed by, a discussion round (`Driven by rounds:`
  cites more than R1's initial sweep);
- it has at least one dependent decision (`Dependent decisions:` is non-empty);
- there is recorded dissent.

A decision is **trivial** otherwise — a question whose answer was directly
supplied by the user's framing, the source spec's commitments, or an obvious
convention with no alternative worth discussing.

If unsure, treat the decision as full.

Cross-referencing invariants:
- `Driven by rounds:` — R# IDs from [implementation-iteration-history.md](implementation-iteration-history.md)
  that added or changed this decision.
- `Dependent decisions:` — D# IDs of later decisions that rest on this one.
- `Referenced in plan:` — sections of [../feature-implementation-plan.md](../feature-implementation-plan.md)
  that cite this decision with an inline parenthetical link.

Any time a full decision is added or edited in this file, update the matching
entries in implementation-iteration-history.md and ../feature-implementation-plan.md
so the three files stay in sync. Trivial decisions still get an inline
`([D-N](...))` link in the plan wherever they are cited, and still populate
`Referenced in plan:` so the link is bidirectional.
-->

## Trivial decisions

<!--
One bullet per trivial decision. Format:

- D-N: {decision title} — {one-sentence outcome}. — Referenced in plan: {sections}.

No Question, Rationale, Evidence, Rejected alternatives, Specialist owner, or
other fields. Keep the plan link populated so a reader can navigate from plan →
decision log and find the outcome.
-->

- D-{N}: {decision title} — {one-sentence outcome}. — Referenced in plan: {sections}.

## Full decisions

### D-1: {Short title}

- **Question:** <!-- The implementation question this decision answers -->
- **Decision:** <!-- What is being committed to, in outcome terms where possible -->
- **Rationale:** <!-- Why this choice given outcome, constraints, and evidence -->
- **Evidence:** <!-- File paths, ADR IDs, coding standards, metrics, specialist findings, or "user input" / "junior-developer reframing" -->
- **Rejected alternatives:**
  - Alternative A — rejected because <!-- reason with evidence -->
  - Alternative B — rejected because <!-- reason with evidence -->
- **Specialist owner:** <!-- Who owns the decision going forward -->
- **Revisit criterion:** <!-- What would cause the team to reopen (e.g., "if p99 above 150ms under production shape") -->
- **Dissent (if any):** <!-- Dissenter, cited evidence, disagree-and-commit note -->
- **Driven by rounds:** <!-- R# IDs from implementation-iteration-history.md -->
- **Dependent decisions:** <!-- D# IDs of later decisions that rested on this one -->
- **Referenced in plan:** <!-- feature-implementation-plan.md sections that cite this decision -->

### D-2: {Short title}

- **Question:** ...
- **Decision:** ...
- **Rationale:** ...
- **Evidence:** ...
- **Rejected alternatives:**
  - ... — rejected because ...
- **Specialist owner:** ...
- **Revisit criterion:** ...
- **Dissent (if any):** ...
- **Driven by rounds:** ...
- **Dependent decisions:** ...
- **Referenced in plan:** ...

<!-- Add more full decisions as needed (D-3, D-4, ...). The D-N counter is
shared across trivial and full sections. -->
