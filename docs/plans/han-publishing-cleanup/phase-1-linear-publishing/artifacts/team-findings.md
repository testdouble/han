# Team Findings: Publish the Linear Plugin to the Second Channel

<!-- Findings from the review team, recorded as F# entries. Major findings carry the full field set; minor edits are
one-line bullets. The F# counter is shared across both sections. -->

## Major findings

### F1: The plugin's own README contradicts the standalone claim

- **Agent:** junior-developer
- **Finding:** The spec's Outcome promised "the documented instructions all agree" and Primary Flow step 5 claims the
  plugin works standalone, but `han-linear/README.md` (lines 8 and 16) says the plugin depends on `han-core` and that
  its skills dispatch shared agents from `han-core` and `han-communication`. The skill's own content
  (`han-linear/skills/work-items-to-linear/SKILL.md`) dispatches no agent and references neither plugin, so the README
  appears stale and the spec's evidence (a grep of `skills/` only) was narrower than the claim it supported.
- **Resolution:** The Outcome's agreement claim was narrowed to the second channel's setup instructions, which are
  accurate. The README discrepancy became Open Item OI-2, routed toward the cleanup's dependency-truth work (Phase 4
  of the outline), and D3's evidence field now records both sides of the contradiction.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Primary Flow; Open Items

### F2: The first-time-publication precondition was silently dropped

- **Agent:** junior-developer (also gap-analyzer, GAP-001)
- **Finding:** The parent outline's Phase 1 preconditions require confirming the second channel accepts a first-time
  publication of a never-before-listed plugin, not only updates. The draft spec assumed install-by-name resolves once
  the entry exists and never named this as a distinct check.
- **Resolution:** The precondition is now explicit in Actors and Triggers, the maintainer-verification install is
  specified to start from an already-registered marketplace in which the plugin was previously absent (proving
  first-time resolution and answering OI-1 in the same run), and a new edge-case row covers the channel refusing a
  first-time listing.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers; Maintainer verification before ship; Edge Cases and Failure Modes

### F3: Edge-case row restated untouched existing behavior (YAGNI)

- **Agent:** junior-developer
- **Finding:** The row about running the skill without a configured Linear connection described pre-existing behavior
  this feature does not touch. Completeness anti-pattern.
- **Resolution:** Row removed; replaced by a single Out of Scope bullet stating the plugin's runtime behavior is
  untouched.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes; Out of Scope

### F4: Bundle edge-case row duplicated Out of Scope (YAGNI)

- **Agent:** junior-developer
- **Finding:** The all-in-one bundle limitation appeared both as an edge-case row and an Out of Scope bullet, and it
  belongs to the release-process phase, not the Linear listing.
- **Resolution:** Edge-case row removed; the single Out of Scope mention remains.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F5: "Operates at the current released version" had no observable signal

- **Agent:** junior-developer
- **Finding:** Running the skill surfaces no version, so the runtime half of the version claim could not be observed.
- **Resolution:** The version check is restated as the observable comparison it is: the installed manifest's stated
  version equals the first channel's released version. Recorded as trivial decision D4.
- **Resolved by:** evidence
- **Affected decisions:** D4 (added)
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Primary Flow; Maintainer verification before ship

### F6: Sibling-matching was the wrong correctness standard

- **Agent:** junior-developer
- **Finding:** "Matches its sibling entries field for field" risks copying a known defect, since the outline's Phase 3
  exists precisely because sibling entries carry stale data.
- **Resolution:** The criterion is rephrased: the entry conforms to the channel's required entry shape, with sibling
  similarity demoted to a sanity check.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Maintainer verification before ship

### F7: The pre-registration alternate flow rested on an unevidenced population (YAGNI)

- **Agent:** junior-developer
- **Finding:** No documented evidence exists of users who registered the marketplace before the fix; verification
  effort committed to that scenario was speculative on its own.
- **Resolution:** Simpler version kept: the maintainer's single end-to-end run starts from an already-registered
  marketplace, so the scenario is covered at zero extra cost and OI-1 resolves in the same run.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States; Open Items

### F8: The Phase 7 dependency was downgraded to an exclusion

- **Agent:** gap-analyzer (GAP-002)
- **Finding:** The outline states the automated completeness check cannot land green while this plugin is missing from
  the channel; the draft spec listed the check only as out-of-scope work, losing the blocking relationship.
- **Resolution:** The Outcome now states that the cleanup's later automated completeness check can only land green once
  this listing entry is in place.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

### F9: The version-parity commitment lacked a decision entry

- **Agent:** gap-analyzer
- **Finding:** The spec committed to version parity between channels with no corresponding decision-log entry, leaving
  the commitment lower-confidence than its siblings.
- **Resolution:** Added trivial decision D4 and linked it from every spec sentence that carries the commitment.
- **Resolved by:** evidence
- **Affected decisions:** D4 (added)
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes

## Minor edits
