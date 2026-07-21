# Team Findings: Declare the Plugin Versions That Work Together

<!-- Findings from the review team, recorded as F# entries. Major findings carry the full field set; minor edits are
one-line bullets. The F# counter is shared across both sections. -->

## Major findings

### F1: Enforcement does not reach pre-existing installations until the depending plugin upgrades

- **Agent:** junior-developer
- **Finding:** Statements ship inside the depending plugin's own manifest, so a person who updates only a companion
  while keeping a pre-statement copy of the depending plugin gets no protection: the exact mismatch the phase exists
  to catch.
- **Resolution:** The reach limit is stated in the Outcome, an edge-case row covers the companion-updated case, and
  the shipping release recommends a full-suite update.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome; Edge Cases and Failure Modes

### F2: A single backfilled marker collapses each range to one resolvable version

- **Agent:** junior-developer
- **Finding:** With one marker per companion, every "at-or-above" range resolves only to that single current version;
  older versions the range nominally allows have no marker.
- **Resolution:** Stated plainly in the alternate flow: ranges are effectively single-valued until markers accumulate
  from Phase 6 onward. No extra historical markers are backfilled.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States

### F3: The entire payoff rested on one uncorroborated external source

- **Agent:** junior-developer (and devops-engineer, who rated the missing verification gate the most load-bearing
  fix)
- **Finding:** Every enforcing behavior traced to a single documentation fetch; the outline's own precondition
  (confirm the channel enforces) was treated as settled without a trial.
- **Resolution:** A live clean-machine verification trial is now a gate in the primary flow before any statement
  reaches installers; OI-2 records that a failed trial pauses the phase. T1 carries the single-source flag.
- **Resolved by:** evidence
- **Affected decisions:** D5 (added)
- **Affected tech-notes:** T1
- **Changed in spec:** Primary Flow; Open Items

### F4: The bundle's six statements and range intersection need atomic co-movement on major bumps

- **Agent:** junior-developer (and devops-engineer on pre-ship intersection checking)
- **Finding:** A future companion major bump must move every edge to that companion, including the bundle's, in one
  release, or the intersection goes empty and the bundle refuses to install; and nothing required proving the
  authored ranges admit a common solution before ship.
- **Resolution:** The major-bump edge row names the bundle's co-movement; a pre-ship common-solution check per stage
  is part of D5.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes; Primary Flow

### F6: Markers narrowed to companion plugins only

- **Agent:** junior-developer
- **Finding:** Backfilling a marker for every plugin included plugins no statement resolves against
  (`Category: YAGNI candidate`); the strictly simpler companion-only set satisfies the same evidence.
- **Resolution:** The backfill covers only the depended-upon plugins; Phase 6 produces markers for all plugins going
  forward. Recorded in D4 and Out of Scope.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow; Out of Scope

### F7: "Current released version" pinned to the latest published suite release

- **Agent:** junior-developer (and devops-engineer on marker commit provenance)
- **Finding:** On the working branch, manifest versions can be ahead of the last published release; an undefined
  baseline could mark unreleased numbers, and a marker on the wrong content would serve wrong code under a released
  name.
- **Resolution:** The baseline is defined as the per-plugin versions of the newest suite release the marketplace
  serves, and each marker points at the content that shipped under that release.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers; Primary Flow

### F8: No recovery story for a bad statement

- **Agent:** junior-developer (and devops-engineer on rollback latency)
- **Finding:** A mis-authored statement was not hot-fixable: corrections need a new release plus a fresh marker, and
  auto-update confined to the bad range can pin users below later fixes.
- **Resolution:** A dedicated alternate flow states the rollback (revert the manifests; markers stay), the correction
  path and its latency, and the wide-start posture that makes the latency survivable.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States

### F9: The pre-release baseline hazard on the alpha line

- **Agent:** devops-engineer (junior-developer had flagged the opt-in clause as YAGNI; the alpha-line context
  reversed that)
- **Finding:** If a companion's baseline version is a pre-release, a plain same-major statement excludes the very
  marker it points at, disabling every dependent even when everything else is done correctly.
- **Resolution:** The precondition and an edge-case row require statements to opt into the pre-release form whenever
  the baseline is one; the opt-in clause is retained as load-bearing, reversing the earlier YAGNI call.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers; Edge Cases and Failure Modes

### F10: Markers travel separately from merged changes

- **Agent:** devops-engineer
- **Finding:** The spec guarded only authoring order and called statement-before-marker unreachable; the real hazard
  is the reverse partial state, statements merged while tags were never pushed, which disables every dependent at
  once.
- **Resolution:** Marker presence on the shared repository is a confirmed gate before any stage ships, a post-ship
  check confirms every referenced marker resolves, and the edge table names this as the primary failure mode.
- **Resolved by:** evidence
- **Affected decisions:** D4, D5
- **Affected tech-notes:** T1
- **Changed in spec:** Primary Flow; Edge Cases and Failure Modes

### F11: The big-bang landing was replaced with staged rollout

- **Agent:** devops-engineer
- **Finding:** "Statements land as one change across the suite" converted the bundle from no-markers-required to
  six-markers-required atomically, with no canary and no incremental signal.
- **Resolution:** D5 stages the rollout: one low-traffic edge, then single edges, the bundle last; the one-change
  approach is a recorded rejected alternative.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow; Coordinations

### F12: The Phase 5-to-6 gap had no marker production

- **Agent:** devops-engineer
- **Finding:** A release landing between the phases would produce no new markers, silently pinning users to the
  backfilled versions or disabling dependents on a major bump: reproducing the frozen-version harm Phase 3 removes.
- **Resolution:** A named gap plan is a precondition: either Phase 6's mechanism is in place first, or a manual
  marker step is part of every release in the window, with a matching edge-case row.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers; Edge Cases and Failure Modes; Out of Scope

### F13: The channel-unqualified outline wording is deliberately narrowed

- **Agent:** gap-analyzer (GAP-001)
- **Finding:** The outline says "every plugin states" without a channel qualifier; the spec restricts statements to
  the first channel.
- **Resolution:** The narrowing is stated in the Outcome and recorded in D3 as deliberate: the second channel has no
  mechanism to read a statement.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

### F14: The outline's "visible but unenforced" fallback is deliberately closed

- **Agent:** gap-analyzer (GAP-002)
- **Finding:** The outline's precondition left open statements starting as visible information on a non-enforcing
  channel; the spec rejects that outright.
- **Resolution:** D3 records the closure and the replacement: if the verification trial disproves enforcement, the
  phase pauses and the question returns to the team rather than shipping decoration. OI-2 carries it.
- **Resolved by:** evidence
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Open Items

## Minor edits

- F5: OI-1's edge list corrected: Planning depends on Communication and Core, not Core alone — junior-developer —
  Open Items
- F15: Summary placeholders replaced with consulted agents and key adjustments — junior-developer — Summary