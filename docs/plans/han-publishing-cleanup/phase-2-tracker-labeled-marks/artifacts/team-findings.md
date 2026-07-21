# Team Findings: Label Every Tracker's Marks and Close the Silent Gap

<!-- Findings from the review team, recorded as F# entries. Major findings carry the full field set; minor edits are
one-line bullets. The F# counter is shared across both sections. -->

## Major findings

### F1: The single-shared-file model did not hold for the GitHub publisher

- **Agent:** junior-developer
- **Finding:** The draft treated one shared file as every publisher's mark carrier, but the GitHub publisher's publish
  step does not modify the source file; it marks derived per-repo copies. The classification story rested on a
  shared-carrier assumption true for only two of three publishers.
- **Resolution:** The user chose to unify: the GitHub publisher will also write its labeled marks into the shared
  file, which becomes the complete record for all three trackers. Recorded as D6.
- **Resolved by:** user input
- **Affected decisions:** D6 (added), D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Primary Flow; Coordinations

### F2: Foreign marks — pause for a decision, or hard stop

- **Agent:** junior-developer (with edge-case-explorer's stop-scope contradiction)
- **Finding:** The draft was ambiguous between a partial run and the GitHub publisher's current whole-run hard stop,
  and its alternate flow and edge table used conflicting stop language.
- **Resolution:** The user chose pause-and-ask: classify everything, present the full picture once with raw mark
  texts, and take one answer before creating anything. Recorded as D7; flow and edge table made consistent.
- **Resolved by:** user input
- **Affected decisions:** D7 (added), D3
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow; Alternate Flows and States; Edge Cases and Failure Modes

### F3: The "own old-format mark" branch was unreachable for two publishers

- **Agent:** junior-developer (with edge-case-explorer's foreign-unambiguous question)
- **Finding:** The two trackers with shape-identical old marks can never classify an old mark as their own, so the
  five-way taxonomy was asymmetric without saying so; and it was undefined whether a publisher may upgrade another
  tracker's unambiguous old mark.
- **Resolution:** The asymmetry is stated in the migration flow, and any publisher may upgrade an unambiguous old mark
  regardless of owner, since naming a certain owner is not guessing; without this, a team that left a tracker would
  carry old marks forever.
- **Resolved by:** evidence
- **Affected decisions:** D3, D4
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States

### F4: The marking-failure stop was framed as preserved but exists only in one publisher

- **Agent:** junior-developer (gap-analyzer flagged the same flow as unevidenced)
- **Finding:** Stop-on-marking-failure is written down only in the Linear publisher; for the GitHub and Jira
  publishers it is a new commitment, not a preserved one, and it had no decision entry.
- **Resolution:** Reworded as a required behavior generalizing the Linear publisher's rule; recorded as trivial
  decision D8.
- **Resolved by:** evidence
- **Affected decisions:** D8 (added)
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States

### F5: The silent vanish was asserted as fact while OI-1 calls it unverified

- **Agent:** junior-developer
- **Finding:** The outcome asserted items vanish silently; the GitHub publisher's written instructions already mandate
  stop-and-report, and the pre-start trial is what settles reality. If the trial shows the stop works, the phase
  shrinks to labeling, the unified record, and migration.
- **Resolution:** OI-1 now says exactly that; the outcome describes the target behavior without asserting today's
  failure mode.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Open Items

### F6: Migration is the default first encounter, not an edge case

- **Agent:** junior-developer (F8), gap-analyzer (GAP-002)
- **Finding:** Every file published before this phase carries old-format marks, so migration is the expected path for
  all existing files; and the outline's second precondition (confirm no old-format user files would be stranded) was
  missing from the spec.
- **Resolution:** The migration flow is reframed as the expected first encounter; the stranded-files check is now a
  precondition and OI-2, resolved by accepting ask-first as the safe default for files that cannot be counted.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers; Alternate Flows and States; Open Items

### F7: Key text can collide with tracker names and near-miss labels can loop

- **Agent:** edge-case-explorer
- **Finding:** Tracker keys are user-chosen, so an old mark's key can read as a tracker's name or another tracker's
  key, risking misclassification and a consented duplicate; and a hand-typed near-miss label would be reported forever
  with no path out under a strict never-repair rule.
- **Resolution:** Colliding or two-ways-readable text is treated as ambiguous and held for the ask; near-miss
  annotations get a proposed manual correction in the report, never an automatic repair.
- **Resolved by:** evidence
- **Affected decisions:** D3, D4
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States; Edge Cases and Failure Modes

### F8: Mark loss by hand-edit or merge silently produces duplicates

- **Agent:** edge-case-explorer
- **Finding:** The mark is the only record of publication; a mark lost to a hand edit or merge resolution makes the
  slice look unpublished, and the next run duplicates it with no signal.
- **Resolution:** Named as an accepted limitation of a file-carried record, in Out of Scope, rather than left
  implicit.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Out of Scope

### F9: Diverged copies published concurrently produce undetectable orphans

- **Agent:** edge-case-explorer
- **Finding:** Two people publishing diverged copies of the same file and merging afterward leaves one tracker's
  created items orphaned, with nothing in the file to detect them.
- **Resolution:** Named as an accepted limitation in Out of Scope.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Out of Scope

### F10: Cross-tracker dependencies had no defined linking behavior

- **Agent:** edge-case-explorer
- **Finding:** When a slice's blocker was published to a different tracker, the linking pass had no stated behavior:
  a crash or a silently dropped relation, depending on publisher.
- **Resolution:** The linking pass skips that one relation and reports it; it never fails the run and never drops the
  relation silently. Recorded as trivial decision D9.
- **Resolved by:** evidence
- **Affected decisions:** D9 (added)
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F11: Stale marks pointing at deleted tracker items keep slices skipped forever

- **Agent:** edge-case-explorer
- **Finding:** Classification trusts a mark's presence without checking the item still exists, so a deleted tracker
  item leaves its slice permanently unpublished with no signal outside the one publisher's link-pass check.
- **Resolution:** Named as an accepted limitation in Out of Scope; classification-time liveness checks are not added.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Out of Scope

### F12: The migration behavior diverges from the outline's blanket wording

- **Agent:** gap-analyzer (GAP-001)
- **Finding:** The outline says three times, unqualified, that old files "get an upgrade path that stops and asks";
  the spec upgrades unambiguous marks without asking, so the outline's demo step cannot be shown on a file carrying
  only unambiguous old marks.
- **Resolution:** The divergence is deliberate and now recorded inside D4's rejected alternatives: upgrading a mark
  whose owner is certain is not guessing, which is what the outline's wording protects against.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States

## Minor edits

- F13: The shared file was listed as an actor; removed, it is a coordinating system — junior-developer — Actors and
  Triggers
- F14: Summary placeholders replaced with the consulted agents and key adjustments — junior-developer — Summary
