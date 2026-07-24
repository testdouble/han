# Team Findings: Project-Configured Default Swarm Size

This file records every finding raised by the review team and how each was resolved. Behavioral outcomes live in
[../feature-specification.md](../feature-specification.md); decisions the findings affected live in
[decision-log.md](decision-log.md). No feature-technical-notes.md exists — no load-bearing mechanic qualified.

Review team: han-core:edge-case-explorer (F1–F4), han-core:junior-developer (F5–F13). Size: small (team cap 2).

## Major findings

### F1: An unrecognized size argument would silently bypass the configured band

- **Agent:** edge-case-explorer
- **Finding:** the sizing guide says an unrecognized size argument (a typo like `mediun`) is treated as trailing
  context and the skill "falls back to auto-classification" — which, with the config inserted into the chain, would
  skip the configured band entirely. The spec did not say which rule wins, and the sizing guide's override section was
  missing from the doc surfaces in D9.
- **Resolution:** an unrecognized size argument supplies no explicit value, so the chain continues to the config.
  Added to the "Explicit size beats the config" flow and the edge-case table; D3 records the rule and the superseded
  sizing-guide wording; D9 adds the sizing guide's override section to the surfaces that change.
- **Resolved by:** evidence
- **Affected decisions:** D3, D9
- **Changed in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### F2: Wrapper skills that conditionally forward a size were unaddressed

- **Agent:** edge-case-explorer
- **Finding:** shipped wrapper skills (for example the Confluence wrappers) forward the size argument only when the
  user passed one; the spec was silent on how the wrapped skill resolves the config and which channel counts as
  explicit input.
- **Resolution:** added a Coordinations row: the wrapper runs the wrapped skill in the same working directory, the
  wrapped skill resolves the config itself, a forwarded size is explicit input and wins, and no forwarded size means
  the config applies. D3 records the rule.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Changed in spec:** Actors and Triggers, Coordinations

### F3: The higher-severity direction — configured `small` on risky work — was implicit

- **Agent:** edge-case-explorer
- **Finding:** the edge-case table covered `large` on trivially small work (a token-cost concern) but not `small`
  forced onto cross-service or security-sensitive work (an under-review concern with materially different severity).
- **Resolution:** added the mirrored edge-case row: the configured `small` is honored with no escalation, the
  announcement keeps the narrowed depth visible, and a per-run override is the correction. D4 now states the force
  applies in both directions.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Changed in spec:** Edge Cases and Failure Modes, Out of Scope

### F4: Whitespace-padded values were unspecified

- **Agent:** edge-case-explorer
- **Finding:** D8 covered case-insensitivity but not hand-editing artifacts like `" medium "`; unclear whether they
  match or degrade with a note.
- **Resolution:** values are trimmed before case-insensitive matching; folded into D8 and the edge-case table row.
- **Resolved by:** evidence
- **Affected decisions:** D8
- **Changed in spec:** Edge Cases and Failure Modes

### F6: Reversing a documented foundational principle warranted an ADR decision

- **Agent:** junior-developer
- **Finding:** the sizing guide states "Sizing is overridable, not configurable"; this feature reverses it, and the
  suite has an ADR mechanism for exactly this kind of reversal, but the spec handled it as a prose edit only.
- **Resolution:** the user chose to record an ADR alongside the sizing-guide revision; captured in D9 and the
  Coordinations row.
- **Resolved by:** user input
- **Affected decisions:** D9
- **Changed in spec:** Coordinations

### F7: No per-run escape back to auto-classification

- **Agent:** junior-developer
- **Finding:** with a band configured, the size argument (three accepted values) could not express "auto-classify
  this run," so every exception would cost a config-file edit.
- **Resolution:** the user chose to accept `dynamic` as an explicit per-run size meaning "auto-classify this run,"
  winning over the configured band for that run. New decision D10; new alternate flow.
- **Resolved by:** user input
- **Affected decisions:** D10
- **Changed in spec:** Outcome, Alternate Flows and States, Edge Cases and Failure Modes

### F8: The `dynamic` config value had no behavioral distinction from omission (YAGNI candidate)

- **Agent:** junior-developer
- **Finding:** `dynamic` in the config was behaviorally identical to leaving the line out — a fourth value to
  document and degrade around, with no job.
- **Resolution:** closed by F7's resolution: `dynamic` now has a per-run override role (D10), and its config-side
  equivalence to absence stays recorded in D5.
- **Resolved by:** user input
- **Affected decisions:** D10, D5
- **Changed in spec:** Outcome, Alternate Flows and States

### F9: The "all eight resolve identically" guarantee rested on an unstated assumption

- **Agent:** junior-developer
- **Finding:** all eight skills carry the config probe, but reading the file and resolving a new scalar into a band
  are different steps; nothing stated where the uniformity comes from.
- **Resolution:** the uniformity comes from defining the setting once in the shared interpretation contract that
  every skill applies, rather than eight independent rules; stated in the Coordinations row and D9.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Changed in spec:** Coordinations

### F13: One global band scales cost across eight differently-scoped skills

- **Agent:** junior-developer
- **Finding:** `large` means different work per skill, and one config line raises agent cost on every sizing-aware
  run; the operator-facing docs said nothing about the aggregate cost.
- **Resolution:** the configuration guide's example gains a note that one configured band applies to all eight
  sizing-aware skills and scales their agent cost together; captured in D9 and User Interactions.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Changed in spec:** User Interactions, Coordinations

## Minor edits

- F5: The motivating need was never stated in the spec — junior-developer — Outcome (added the operator-described
  need; recorded in D1).
- F10: Primary Flow implied the intervening chain sources could supply a size — junior-developer — Primary Flow
  (now states they define no swarm size; recorded in D3).
- F11: No testable definition of done — junior-developer — Open Items (added OI-1: extend the manual test plan across
  the eight skills, following the prior config feature's precedent).
- F12: Summary claimed 0 open items while review was pending — junior-developer — Summary (counts and consulted
  agents now reflect the completed review).
