# Review Findings: {Plan Name}

<!--
This file records every finding raised while reviewing {Plan Name}, and how each
was resolved. The primary plan lives one directory up (the plan file sits at the
root of the plan folder; this file lives in that folder's `artifacts/` subfolder) —
consult the plan's "Review History" section for the link. Round-by-round history
lives in [review-iteration-history.md](review-iteration-history.md).

Findings come from two sources depending on the review mode the skill chose:
- **Team mode:** each F# entry names the specialist sub-agent that raised it.
- **Lightweight mode:** each F# entry raised by the skill's own checklist pass
  uses `self-review` as the agent.

## Two-tier format: major vs. minor findings

Every finding is classified as **major** or **minor** before it is recorded.

A finding is **major** when any of these signals is present:
- it changes a behavioral commitment, an edge-case rule, an alternate flow, or a
  failure mode in the plan;
- it touches security, authorization, PII, secrets, or supply-chain;
- it touches a coordination across actors, services, or subsystems;
- it is a `T#-contradiction` (specialist disagrees with a committed `T#` note);
- it is a `mechanics leaking into spec` finding in spec-aware mode.

A finding is **minor** otherwise — typo, wording, naming, formatting, missing
punctuation, citation cleanup, redundant link, broken markdown.

If the agent classifies a finding as minor but the finding text contains any
keyword from the major list (e.g., "auth", "PII", "race", "ordering",
"coordination", "edge case", "T#"), force it back to major. When in doubt, major.

Cross-referencing invariants:
- `Raised in round:` — R# IDs from [review-iteration-history.md](review-iteration-history.md)
  where this finding first appeared. A finding may be re-raised in later rounds
  with stronger evidence; append additional R# IDs in that case.
- `Changed in plan:` — sections of the primary plan file that this finding
  caused to change. `—` if the plan did not change.
- `Changed in tech-notes:` — T# IDs in
  [feature-technical-notes.md](feature-technical-notes.md) that this finding caused
  to be added or edited. Applies ONLY in spec-aware mode and ONLY when
  feature-technical-notes.md exists.

Any time a major finding is added or edited here, update the matching R# entry in
review-iteration-history.md. In spec-aware mode, also keep
feature-technical-notes.md in sync.
-->

## Major findings

### F1: {Finding title}

- **Agent:** <!-- specialist sub-agent name, or `self-review` in lightweight mode -->
- **Category:** <!-- assumption refuted / overlap / ambiguity / edge case / unhandled failure mode / standards conflict / mechanics leaking into spec (spec-aware mode only) -->
- **Finding:** <!-- What was surfaced, with citations to specific codebase paths, file:line, ADR IDs, or coding-standard sections -->
- **Evidence considered:** <!-- Code paths, docs, ADRs, conventions that back the finding -->
- **Resolution:** <!-- What the skill did about it — the plan edit applied, the clarification captured, or why the finding was deferred -->
- **Resolved by:** <!-- evidence / user input / re-reframing / deferred to open item -->
- **Raised in round:** <!-- R# ID(s) from review-iteration-history.md -->
- **Changed in plan:** <!-- plan sections that were updated, or — -->
- **Changed in tech-notes:** <!-- spec-aware mode only and only when feature-technical-notes.md exists: T# IDs added or edited, or — -->

### F2: {Finding title}

- **Agent:** ...
- **Category:** ...
- **Finding:** ...
- **Evidence considered:** ...
- **Resolution:** ...
- **Resolved by:** ...
- **Raised in round:** ...
- **Changed in plan:** ...
- **Changed in tech-notes:** ...

<!-- Add more major findings as needed (F3, F4, ...). Keep IDs globally unique
across major and minor — F# is a single counter. -->

## Minor edits

<!--
One bullet per minor finding. Format:

- F#: {one-line description} — {agent} — {section changed, or —}

Do not add Resolution, Evidence, or Category fields here. The minor format is
intentionally compact. Keep IDs sequential with the major findings above.
-->

- F{N}: {one-line description} — {agent} — {section changed, or —}
