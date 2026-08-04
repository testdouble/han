# Implementation Iteration History: {Feature Name}

<!--
This file records how the implementation plan for {Feature Name} evolved across
discussion rounds. Committed decisions live in [implementation-decision-log.md](implementation-decision-log.md)
and the primary plan lives in [../feature-implementation-plan.md](../feature-implementation-plan.md).

This file ALSO consolidates the per-round aggregation output —
no separate `implementation-facilitation-round-{N}.md` files are written. The
claim ledger, Open Questions, and spec-maturity tags from each round live as
fields on that round's entry below.

The iteration loop is capped at four rounds (see the plan-implementation skill's
Step 6). A round entry is appended at the end of each iteration with `Decisions
produced:` and `Changed in plan:` backfilled during the plan-synthesizer's
synthesis step.

Cross-referencing invariants:
- `Decisions produced:` — D# IDs from [implementation-decision-log.md](implementation-decision-log.md)
  that this round added or changed. `—` if the round produced no new or changed decisions.
- `Changed in plan:` — sections of [../feature-implementation-plan.md](../feature-implementation-plan.md)
  that this round updated. `—` if nothing in the plan changed.

Any time a round is added or edited here, update the matching entries in
implementation-decision-log.md and ../feature-implementation-plan.md so the three
files stay in sync.
-->

## R1: {Short round title — e.g., "Parallel specialist review"}

- **Specialists engaged:**
  <!-- e.g., test-engineer, adversarial-security-analyst, devops-engineer, on-call-engineer, junior-developer -->
- **New input provided:**
  <!-- For re-engagement rounds: what new context, resolved questions, or user answers were handed back to the specialists. For R1, typically "initial feature specification and discovery notes." -->
- **Claim ledger:**
  <!-- Each row is one claim with its state: Evidenced (citation that resolves), Anecdotal (no citation), Disputed (specialists disagree), or Unverified (rests on an input its author could not inspect, so it cannot be build-blocking). A claim raised by two specialists is one row carrying every originating identifier. Note on any row that turns on visual material whether it was checked against that material. Use a compact table or bullet list. -->
- **Open Questions raised:**
  <!-- OQ-N items the specialists or the round aggregation surfaced this round. Reference the decisions they ultimately became (D# IDs) if known at write time; otherwise leave the linkage to be filled during synthesis. -->
- **Spec-maturity tags:**
  <!-- Counts and IDs by tag: plan-level (resolvable in plan stage), spec-level (requires spec-stage decision), T#-contradiction (specialist disagrees with a committed T# note). Note whether the spec-maturity gate tripped. -->
- **Resolution source:**
  <!-- For each Open Question: "evidence" (found in the Step 6 loop) / "junior-developer reframing" / "user input" / "deferred to next round" / "synthesis (Step 8 evidence)" (the plan-synthesizer settled it by re-reading the spec during synthesis, not in the loop — keep this distinct from loop-stage "evidence" so the audit trail is honest) -->
- **Decisions produced:** <!-- D# IDs added or changed this round, or — -->
- **Changed in plan:** <!-- feature-implementation-plan.md sections updated this round, or — -->
- **Next-step recommendation:**
  <!-- "Continue facilitation — re-engage X with new context" / "Go to synthesis" / "Blocked pending user input on OQ-N" / "Pause and sharpen the spec" -->

## R2: {Short round title}

- **Specialists engaged:** ...
- **New input provided:** ...
- **Claim ledger:** ...
- **Open Questions raised:** ...
- **Spec-maturity tags:** ...
- **Resolution source:** ...
- **Decisions produced:** ...
- **Changed in plan:** ...
- **Next-step recommendation:** ...

<!-- Add more rounds as needed (R3, R4). The iteration loop caps at four rounds. -->

## Unaudited evidence classes

<!-- Present only when decisions rest on material no specialist received. One bullet per class, naming the material and the
     decisions that rest on it, so the coverage gap is visible rather than silent. Omit the section when every evidence
     class reached a specialist. -->

- {the material}, supporting {D-N IDs}. No specialist received it, because {reason}.

## Escalation register

<!-- Present only when the run escalated a question to the user. One entry per question, in the order asked, across every
     round. Escalations go out one per turn, so this is also the record of how many turns the run spent and on what.

     Omit the section entirely when nothing was escalated. -->

### E1: {the question as it was asked, in plain language}

- **Round:** {R# the question came from}
- **Answer:** {what the user said}
- **Landed in:** {the D-N entry or plan section the answer changed}
