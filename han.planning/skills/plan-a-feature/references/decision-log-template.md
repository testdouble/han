# Decision Log: {Feature Name}

<!--
This file records every decision settled while specifying {Feature Name}. Behavioral
statements live in [../feature-specification.md](../feature-specification.md) — this file
captures the history, rationale, evidence, and rejected alternatives for each decision.

## Two-tier format: full vs. trivial decisions

Every decision is classified as **full** or **trivial** before it is recorded.

A decision is **full** when any of these signals is present:
- it has at least one rejected alternative **a reasonable engineer would plausibly have chosen** (an obvious or strawman alternative does not by itself make a decision full);
- the rationale rests on evidence beyond the user's framing (codebase pattern,
  ADR, coding standard, prior decision, or an external standard like WCAG);
- it was driven by, or later changed by, a review finding (`Driven by findings:`
  is non-empty);
- it has a load-bearing technical mechanic (`Linked technical notes:` is
  non-empty);
- it has at least one dependent decision (`Dependent decisions:` is non-empty).

A decision is **trivial** otherwise — a question whose answer was directly
supplied by the user's request, or where the answer is the only reasonable one
given an obvious convention with no alternative worth discussing.

If unsure, treat the decision as full. A future reader is better served by an
unnecessary block of rationale than by a missing one. The first signal above is
deliberately a weight judgment, not a presence check — an obvious alternative
does not promote a decision to full — so this "if unsure, treat as full" default
is its backstop against drift across runs.

Cross-referencing invariants:
- `Linked technical notes:` — T# IDs from [feature-technical-notes.md](feature-technical-notes.md)
  that capture load-bearing mechanics this decision's behavioral commitment relies on.
  `—` if the decision's behavior does not depend on any named mechanic.
  The feature-technical-notes.md file is lazily created; if it does not exist in this
  artifacts folder, no decision should cite a T# ID.
- `Driven by findings:` — F# IDs from [team-findings.md](team-findings.md) that caused
  this decision to be added or changed. `—` if the decision was settled during the
  initial interview (Step 4) and not later reshaped by a review finding.
- `Dependent decisions:` — D# IDs of later decisions that rested on this one.
- `Referenced in spec:` — sections of [../feature-specification.md](../feature-specification.md)
  that cite this decision with an inline parenthetical link.

Any time a full decision is added or edited in this file, update the matching
entries in team-findings.md, feature-technical-notes.md (when present), and
../feature-specification.md so all files stay in sync. Trivial decisions still
get an inline `([D#](...))` link in the spec wherever they are cited, and still
populate `Referenced in spec:` so the link is bidirectional.
-->

## Trivial decisions

<!--
One bullet per trivial decision. Format:

- D#: {decision title} — {one-sentence outcome} (considered {alternative}; rejected because {one clause}). — Referenced in spec: {sections}.

The parenthetical is OPTIONAL: write it only when an obvious alternative was
discarded that did not earn full treatment. Keep it to a single bracketed
clause, never more than one sentence, so trivial entries do not balloon. When no
alternative was discarded, omit the parenthetical entirely:

- D#: {decision title} — {one-sentence outcome}. — Referenced in spec: {sections}.

No Question, Rationale, Evidence, Rejected alternatives, or other fields. Keep
the spec link populated so a reader can navigate from spec → decision log and
find the outcome.
-->

- D{N}: {decision title} — {one-sentence outcome} (considered {alternative}; rejected because {one clause}). — Referenced in spec: {sections}.

## Full decisions

### D1: {Decision title}

- **Question:** ...
- **Decision:** ... <!-- Behavioral statement -->
- **Rationale:** ...
- **Evidence:** <!-- Codebase paths, ADR numbers, coding standards, or "user input" -->
- **Rejected alternatives:**
  - ... — rejected because ...
- **Linked technical notes:** <!-- T# IDs from feature-technical-notes.md whose mechanic enables this decision's behavior, or — -->
- **Driven by findings:** <!-- F# IDs from team-findings.md, or — -->
- **Dependent decisions:** <!-- D# IDs of later decisions that rested on this one -->
- **Referenced in spec:** <!-- feature-specification.md sections that cite this decision -->

### D2: {Decision title}

- **Question:** ...
- **Decision:** ...
- **Rationale:** ...
- **Evidence:** ...
- **Rejected alternatives:**
  - ... — rejected because ...
- **Linked technical notes:** ...
- **Driven by findings:** ...
- **Dependent decisions:** ...
- **Referenced in spec:** ...

<!-- Add more full decisions as needed (D3, D4, ...). The D# counter is shared
across trivial and full sections. -->
