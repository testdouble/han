# Team Findings: {Feature Name}

<!--
This file records every finding raised by the review team for {Feature Name}, and how
each was resolved. Behavioral outcomes live in [../feature-specification.md](../feature-specification.md);
decisions the findings affected live in [decision-log.md](decision-log.md); any
load-bearing mechanics captured live in [feature-technical-notes.md](feature-technical-notes.md)
(lazily created — present only when at least one mechanic was worth capturing).

## Two-tier format: major vs. minor findings

Every finding is classified as **major** or **minor** before it is recorded.

A finding is **major** when any of these signals is present:
- it changes a behavioral commitment, an edge-case rule, an alternate flow, or a
  failure mode in the spec;
- it touches security, authorization, PII, secrets, or supply-chain;
- it touches a coordination across actors, services, or subsystems;
- it surfaces a load-bearing mechanic (`T#` candidate) the spec was relying on
  implicitly;
- it is a `mechanics leaking into spec` finding.

A finding is **minor** otherwise — typo, wording, naming, formatting, missing
punctuation, citation cleanup, redundant link, broken markdown.

If the agent classifies a finding as minor but the finding text contains any
keyword from the major list (e.g., "auth", "PII", "race", "ordering",
"coordination", "edge case", "T#"), force it back to major. When in doubt, major.

Cross-referencing invariants:
- `Affected decisions:` — D# IDs from [decision-log.md](decision-log.md) that this
  finding caused to be added or changed. `—` if the finding was resolved without
  touching a decision.
- `Affected tech-notes:` — T# IDs from [feature-technical-notes.md](feature-technical-notes.md)
  that this finding caused to be added or edited. `—` if the finding did not touch
  any mechanic note, or if feature-technical-notes.md does not exist.
- `Changed in spec:` — sections of [../feature-specification.md](../feature-specification.md)
  that this finding caused to change. `—` if nothing in the spec changed.

Any time a major finding is added or edited here, update the matching entries in
decision-log.md, feature-technical-notes.md (when present), and
../feature-specification.md so all files stay in sync.
-->

## Major findings

### F1: {Finding title}

- **Agent:** <!-- e.g., junior-developer, adversarial-security-analyst -->
- **Finding:** ...
- **Resolution:** ...
- **Resolved by:** evidence / user input / project-manager synthesis
- **Affected decisions:** <!-- D# IDs from decision-log.md, or — -->
- **Affected tech-notes:** <!-- T# IDs from feature-technical-notes.md, or — (omit when the file does not exist) -->
- **Changed in spec:** <!-- feature-specification.md sections, or — -->

### F2: {Finding title}

- **Agent:** ...
- **Finding:** ...
- **Resolution:** ...
- **Resolved by:** ...
- **Affected decisions:** ...
- **Affected tech-notes:** ...
- **Changed in spec:** ...

<!-- Add more major findings as needed (F3, F4, ...). Keep IDs globally unique
across major and minor — F# is a single counter. -->

## Minor edits

<!--
One bullet per minor finding. Format:

- F#: {one-line description} — {agent} — {section changed, or —}

Do not add Resolution or other fields here. Keep IDs sequential with the major
findings above.
-->

- F{N}: {one-line description} — {agent} — {section changed, or —}
