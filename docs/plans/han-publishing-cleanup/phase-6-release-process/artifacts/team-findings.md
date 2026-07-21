# Team Findings: Teach the Release Process About All Four Publishing Surfaces

<!-- Findings from the review team, recorded as F# entries. Major findings carry the full field set; minor edits are
one-line bullets. The F# counter is shared across both sections. -->

## Major findings

### F1: Rehearsal mode was presented as existing behavior and left undefined at its boundary

- **Agent:** junior-developer
- **Finding:** The release skill has no dry run today; even its draft path commits, tags, and publishes a draft
  release. The spec introduced rehearsal as a plain trigger with no decision behind it and no statement of what it
  skips.
- **Resolution:** Rehearsal is now decision D6: named as new behavior, with a defined boundary (no surface writes, no
  pushes, no publication, no markers; the version plan still shown).
- **Resolved by:** evidence
- **Affected decisions:** D6 (added)
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers; Primary Flow; Edge Cases and Failure Modes

### F2: "Discovers every plugin" had no behavioral definition of a plugin

- **Agent:** junior-developer
- **Finding:** Without a discriminator, disk discovery is not deterministically implementable; the repo root also
  holds non-plugin directories.
- **Resolution:** A plugin is a top-level directory carrying the first channel's manifest; the bundle is the one
  plugin whose role is to install the others. Recorded in D2.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Primary Flow

### F3: The surface-membership default was circular

- **Agent:** junior-developer
- **Finding:** The spec said only where a plugin does not belong; the default rule and the bundle's identity were
  never stated.
- **Resolution:** Every discovered plugin belongs on all four surfaces by default; only the durable exception record
  subtracts one; the bundle is named. Recorded in D4.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

### F4: The version-bump proposal step and drift baseline were missing

- **Agent:** junior-developer
- **Finding:** The skill's core interaction, proposing bumps and gating on one confirmation, was absent, and the spec
  never said which channel's record feeds the bump when the two disagree.
- **Resolution:** The proposal-and-confirm step is retained explicitly; one confirmed target per plugin feeds every
  surface; the first channel's record is the baseline because the second channel's records are the frozen ones.
  Recorded in D3.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F5: Marker and statement were load-bearing but undefined here

- **Agent:** junior-developer
- **Finding:** A reader of this spec alone could not tell what a marker or a statement is, or that per-plugin markers
  are new relative to today's suite-only marker.
- **Resolution:** One-line in-spec definitions added in the Outcome, with the newness stated.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

### F6: The exception record's future-flexibility clause was YAGNI

- **Agent:** junior-developer
- **Finding:** Designing a general multi-exception format for a record with exactly one exception is flexibility
  without evidence.
- **Resolution:** The record holds a single named allowance; the general-format question reopens if a concrete second
  exception arises. Recorded in D4 and Out of Scope.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Out of Scope; Open Items

### F7: The orphan-entry check had no incident behind it

- **Agent:** junior-developer
- **Finding:** The documented failure is a missing plugin; the orphan-listing case is its unevidenced symmetric
  opposite (`Category: YAGNI candidate`).
- **Resolution:** Kept, because it rides the same per-surface comparison at no extra cost, and now honestly labeled
  in the edge table as a symmetric rail without a claimed incident.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F8: The marker-versus-statement publish order was unspecified and today's order is unsafe

- **Agent:** devops-engineer
- **Finding:** The four surface files land together in one change, but markers travel separately, and the skill today
  pushes the change before its markers; on a major bump that order can refuse every install of the bundle.
- **Resolution:** The ordering invariant is a primary-flow step: markers reach the shared repository before, or
  atomically with, any statement-moving change. Recorded in D5.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow; Coordinations

### F9: The re-run safety claim could not see the states that actually break

- **Agent:** devops-engineer
- **Finding:** A file-state re-run check passes cleanly over a half-landed marker push or missing release record,
  leaving dependents disabled indefinitely while reporting clean.
- **Resolution:** Re-run checks read the shared repository's real state, including markers and the release record;
  the edge row now says exactly that.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F10: Nothing verified that a publish actually landed

- **Agent:** devops-engineer
- **Finding:** The process had a pre-publish gate but no post-publish confirmation; a transient failure between acts
  leaves a split-brain release invisible until a user reports it.
- **Resolution:** A post-publish reconciliation step reads everything back from the shared repository and fails
  loudly with a named report. Recorded in D5.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Primary Flow

### F11: The exception record's unreadable state was undefined

- **Agent:** devops-engineer
- **Finding:** A malformed record could either block releases with a misleading gap report or silence real gaps,
  depending on parser charity.
- **Resolution:** Unreadable fails closed and names the record itself as the fault, distinct from a gap report.
  Recorded in D4 with a matching edge row.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F12: The default path published with no human checkpoint on risky releases

- **Agent:** devops-engineer
- **Finding:** Rehearsal was opt-in and the skill's pause gate defaults off, so a release that moves statements or
  majors a companion could publish with no preview, and recovery takes a release cycle.
- **Resolution:** The preview is opt-out for exactly those releases: the maintainer sees and acknowledges the
  rehearsal view before anything publishes. Recorded in D6.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F13: The gap-stop had no incident door

- **Agent:** devops-engineer
- **Finding:** With no override, an unrelated open gap blocks an urgent fix, pressuring someone to disable the whole
  gate: the exact failure the source analysis warns about.
- **Resolution:** A deliberate, single-use, loud override ships the release with every deferred gap named in the
  release notes. Recorded as D7 with an alternate flow.
- **Resolved by:** evidence
- **Affected decisions:** D7 (added)
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States

### F14: The bundle-exception precondition is settled in requirement, open in placement

- **Agent:** gap-analyzer (GAP-001)
- **Finding:** The outline's precondition asks to confirm the durable record before starting; the spec settles every
  behavioral requirement but defers the record's location to implementation planning.
- **Resolution:** Recorded as the deliberate split it is: OI-1 carries the placement choice, and the requirement
  (one record, read by both, fails closed, single allowance) is fixed here.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Open Items

## Minor edits

- F15: The precondition now says presence-complete and version-aligned rather than the blanket "already correct", so
  the first run reads as ordinary sync, not gap repair — junior-developer — Actors and Triggers
- F16: Summary placeholders replaced with consulted agents and key adjustments — junior-developer — Summary
