# Team Findings: Unfreeze the Second Channel's Version Numbers

<!-- Findings from the review team, recorded as F# entries. Major findings carry the full field set; minor edits are
one-line bullets. The F# counter is shared across both sections. -->

## Major findings

### F1: The update-offer outcome rested on an unverified external assumption

- **Agent:** junior-developer
- **Finding:** The outcome promised update offers as a certainty while T1 concedes the channel's freshness rule is
  external and unverified, and OI-1 was still open. The reviewer also verified from the repository that the channel
  serves plugin content and version from the same directory on the default branch, so a bump plus merge should
  deliver real content, with content-caching by version as the one residual unknown.
- **Resolution:** The outcome now names the OI-1 demonstration as what confirms the payoff, and OI-1 gained the
  cache question and a split blocking answer: the correction is unblocked, the payoff sign-off is the demonstration.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** T1
- **Changed in spec:** Outcome; Open Items

### F2: An "older copy" was undefined because version numbers are decoupled from content

- **Agent:** junior-developer
- **Finding:** Content is served fresh from the branch, so a copy can hold an old number with current content; a demo
  from such a machine would show only the number ticking up.
- **Resolution:** The demonstration now requires a copy that is older in content, and confirms an observable content
  difference after accepting, not only a higher number.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F3: The source of truth was ambiguous between "released" and "current manifest value"

- **Agent:** junior-developer
- **Finding:** "The first channel's released versions" could mean the last published release or whatever the working
  branch's manifest says mid-release; the two can differ.
- **Resolution:** Pinned to the version of the last published release as the first channel records it; today those
  equal the first-channel manifest values on the branch.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers

### F4: "One version per plugin across both channels" read as an ongoing guarantee

- **Agent:** junior-developer
- **Finding:** The alignment is a point-in-time snapshot; future releases re-drift until the release-process phase.
- **Resolution:** Reworded: after the correction the numbers match; keeping them matched is the release-process
  phase's job.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

### F5: The ahead-of-first-channel guard covers a condition no plugin meets today

- **Agent:** junior-developer
- **Finding:** No second-channel version is currently ahead, so the stop-and-raise rule guards a hypothetical
  (`Category: YAGNI candidate`).
- **Resolution:** Kept deliberately as a cheap safety rail for a one-time human action, consistent with the plan's
  ask-over-guess rule, and mirrored as a pre-start check in the preconditions so it is confirmed rather than assumed.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers; Edge Cases and Failure Modes

### F6: The release-process coordination row overreached into Phase 6

- **Agent:** junior-developer
- **Finding:** The row framed this phase as doing something with the release process; that behavior is Phase 6's.
- **Resolution:** Reframed as a hand-off note: the aligned state is the baseline Phase 6 maintains.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations

### F7: The Phase 7 dependency was missing

- **Agent:** gap-analyzer (GAP-001)
- **Finding:** The outline states the automated completeness check cannot land green while these numbers are stale;
  the spec never mentioned it.
- **Resolution:** The outcome now names this phase as a prerequisite of the cleanup's later automated completeness
  check.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

## Minor edits

- F8: Summary placeholders replaced with consulted agents and key adjustments — junior-developer — Summary
