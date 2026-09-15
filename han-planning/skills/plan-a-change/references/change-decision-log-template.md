# Change Decision Log: {Change Name}

<!--
This file records every decision committed while planning {Change Name}.
The plan itself lives in [../change-plan.md](../change-plan.md) — this file captures the
question, rationale, evidence, and rejected alternatives behind each decision.
Evidence about the code as it stands today lives in
[current-state-findings.md](current-state-findings.md) as numbered C-N findings.

## Two-tier format: full vs. trivial decisions

Every decision is classified as **full** or **trivial** before it is recorded.

A decision is **full** when any of these signals is present:
- it has at least one rejected alternative;
- the rationale rests on evidence beyond the user's framing (a C-N finding, an
  ADR, a coding standard, a prior decision, or a specialist finding);
- it settles a delta entry classified Changing or Unknown at the
  behavior-preservation gate;
- it has at least one dependent decision (`Dependent decisions:` is non-empty);
- there is recorded dissent.

A decision is **trivial** otherwise — a question whose answer was directly
supplied by the user's framing or an obvious convention with no alternative
worth discussing.

If unsure, treat the decision as full.

Every decision settling a behavior-changing delta entry is full, with no
exception. That is the class of decision a reader most needs the reasoning for.

Cross-referencing invariants:
- `Settles delta entry:` — the S-N entry in ../change-plan.md this decision commits.
- `Dependent decisions:` — D-N IDs of later decisions that rest on this one.
- `Referenced in plan:` — sections of [../change-plan.md](../change-plan.md) that
  cite this decision with an inline parenthetical link.

Any time a full decision is added or edited here, update the matching entry in
../change-plan.md so the two files stay in sync. Trivial decisions still get an
inline ([D-N](...)) link in the plan wherever they are cited, and still populate
`Referenced in plan:` so the link is bidirectional.
-->

## Trivial decisions

<!--
One bullet per trivial decision. Format:

- D-N: {decision title} — {one-sentence outcome}. — Referenced in plan: {sections}.

No Question, Rationale, Evidence, Rejected alternatives, or other fields.
-->

- D-{N}: {decision title} — {one-sentence outcome}. — Referenced in plan: {sections}.

## Full decisions

### D-1: {Short title}

- **Question:** <!-- The structural question this decision answers -->
- **Decision:**
  <!-- What is being committed to. When the decision resolves a contract two or more parts must
  independently agree on (a call signature, a payload shape, a persisted format, an error contract, a
  lifecycle order, a config schema), this field carries the concrete form inline: a signature, a field
  layout, or a worked example. A link to an artifact that already exists concretely also closes it. A
  field-name list, a prose description, or the name of a document to be authored later does not. Full
  rule in [contract-pinning-rule.md](../../../references/contract-pinning-rule.md). -->
- **Rationale:** <!-- Why this choice, given the recorded reason for the change and the evidence -->
- **Evidence:**
  <!-- C-N findings, file paths, ADR IDs, coding standards, specialist findings, or "user input" /
  "junior-developer reframing" -->
- **Behavior impact:**
  <!-- Preserving, Changing, or Unknown, matching the S-N entry's classification. When Changing or
  Unknown: what an observer sees differently, and the user's answer verbatim. -->
- **Rejected alternatives:**
  - Alternative A — rejected because <!-- reason with evidence -->
  - Alternative B — rejected because <!-- reason with evidence -->
- **Revisit criterion:**
  <!-- What would reopen this (e.g., "if a second implementation of this interface appears") -->
- **Dissent (if any):** <!-- Dissenter, cited evidence, disagree-and-commit note -->
- **Settles delta entry:** <!-- S-N IDs from ../change-plan.md, or "—" for a decision that shapes the
  plan without committing one entry -->
- **Dependent decisions:** <!-- D-N IDs of later decisions that rested on this one -->
- **Referenced in plan:** <!-- change-plan.md sections that cite this decision -->

### D-2: {Short title}

- **Question:** ...
- **Decision:** ...
- **Rationale:** ...
- **Evidence:** ...
- **Behavior impact:** ...
- **Rejected alternatives:**
  - ... — rejected because ...
- **Revisit criterion:** ...
- **Dissent (if any):** ...
- **Settles delta entry:** ...
- **Dependent decisions:** ...
- **Referenced in plan:** ...

<!-- Add more full decisions as needed (D-3, D-4, ...). The D-N counter is
shared across the trivial and full sections. -->
