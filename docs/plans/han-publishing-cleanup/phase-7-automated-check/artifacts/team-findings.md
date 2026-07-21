# Team Findings: Turn On the Automated Completeness Check

<!-- Findings from the review team, recorded as F# entries. Major findings carry the full field set; minor edits are
one-line bullets. The F# counter is shared across both sections. -->

## Major findings

### F1: The change-time and release-time verdicts collided on version disagreement

- **Agent:** junior-developer
- **Finding:** The change-time check blocked on any cross-channel version disagreement, while Phase 6's release
  tolerates pre-existing drift and reconciles it, so the same tree state produced opposite verdicts, contradicting
  the phase's central never-disagree promise.
- **Resolution:** The verdict is defined on the proposed tree's end state: a release passes because it moves all four
  surfaces together in one change; a change creating drift is blocked; the release's sync is how flagged drift gets
  fixed. Both moments call the same state the same thing.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Primary Flow

### F2: "One rule" overclaimed a shared implementation across two runtimes

- **Agent:** junior-developer
- **Finding:** The change-time check and the interactive release gate cannot literally be one executable path; the
  spec should own behavioral equivalence, not machinery.
- **Resolution:** The commitment is now verdict equivalence: same tree and same exception record, same verdict, at
  both moments.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Coordinations

### F3: The guard claim was broader than the mechanism, and the outline overclaimed Phase 4

- **Agent:** junior-developer (gap-analyzer's GAP-001 found the same asymmetry)
- **Finding:** "Makes every problem the earlier phases fixed impossible to reintroduce" swept in Phase 2's marks,
  Phase 4's declaration truth, and Phase 5's statements, none of which the check examines; the outline's Connects-to
  said the check guards Phase 4.
- **Resolution:** The claim is narrowed to presence and version agreement, guarding Phases 1, 3, and 6; the
  not-guarded outcomes are named in the Outcome and Out of Scope with the reopening trigger; the outline's Phase 7
  guard list was corrected to drop Phase 4.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Out of Scope (and the parent outline's Phase 7 entry)

### F4: An absolute no-disable rule deadlocked on a false-failing check

- **Agent:** junior-developer
- **Finding:** A check whose own logic false-fails would block every change, including its fix, with no change-time
  escape; the repository wedges.
- **Resolution:** A scoped, recorded repair door: a change fixing the check or its record may land past the failing
  check, with the bypass named visibly, mirroring the release override's loud-and-recorded principle.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States; Edge Cases and Failure Modes

### F5: The four-surfaces-visible-at-change-time assumption was unstated

- **Agent:** junior-developer
- **Finding:** A change-time check can only see the repository tree; whether all four surfaces live in the tree was
  load-bearing and unsaid.
- **Resolution:** Stated as fact with evidence: all four surfaces are files in this repository, which is what makes
  the change-time verdict possible.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

### F6: The demonstration needed on-demand invocation the spec never granted

- **Agent:** junior-developer
- **Finding:** The outline's demo runs the check ad hoc against a throwaway branch; the spec only defined automatic
  and release-time runs.
- **Resolution:** On-demand invocation against any working tree is now a stated trigger.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Actors and Triggers

### F9: "Arrives green" had no observable done-criterion or owner

- **Agent:** junior-developer
- **Finding:** Who runs the first run, what records that it passed, and what "turn on" means were unstated, leaving
  the phase's definition of done as an intention.
- **Resolution:** The turn-on condition is a recorded green run against the real tree, owned by the maintainer;
  until it exists, the check does not block.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers; Outcome

## Minor edits

- F7: OI-1's "fully settled" claim now lists what was settled, including the version verdict F1 defined —
  junior-developer — Open Items
- F8: The orphan-listing row carries Phase 6's honest caveat and its parity evidence — junior-developer — Edge Cases
  and Failure Modes
- F10: Summary placeholders replaced with consulted agents and key adjustments — junior-developer — Summary
