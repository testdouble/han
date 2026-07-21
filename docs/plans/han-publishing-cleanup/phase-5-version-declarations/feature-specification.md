# Feature Specification: Declare the Plugin Versions That Work Together

Every plugin that depends on another states which versions of that companion it works with, the first install channel
enforces the statements at install and update time, and the rollout is staged and verified so the statements can never
disable installs on their way in.

## Outcome

Each dependency a plugin declares carries a version statement: the companion works when its version is in the same
major line at or above the stated release ([D2](artifacts/decision-log.md#d2-same-major-version-statements)). The
first install channel enforces the statements. Installs and updates resolve companions within the stated range, and a
combination that cannot be satisfied is refused with a named error instead of assembled silently
([T1](artifacts/feature-technical-notes.md#t1-how-the-first-channel-resolves-version-statements)).

Enforcement reaches an existing installation only after the depending plugin itself upgrades to a statement-carrying
version. Someone who updates only a companion, while keeping a pre-statement copy of the plugin that depends on it,
gets no protection yet; the release that ships this phase says so and recommends a full-suite update
([D2](artifacts/decision-log.md#d2-same-major-version-statements)).

The second channel resolves no dependencies at all, so it neither reads nor enforces the statements. That is a named
limitation, and it deliberately narrows the outline's channel-unqualified wording
([D3](artifacts/decision-log.md#d3-first-channel-only)).

Enforcement only works if the channel can find each companion version by its release marker. Releases are marked at
the suite level only today, so this phase backfills per-plugin release markers for the companion plugins, each
pointing at the exact content that shipped as that released version
([D4](artifacts/decision-log.md#d4-per-plugin-release-markers)). The rollout is staged, gated by a live verification
trial, and reversible ([D5](artifacts/decision-log.md#d5-staged-verified-reversible-rollout)).

## Actors and Triggers

- **Actors** — People installing or updating Han plugins from the first channel; maintainers declaring the statements
  and running the rollout.
- **Triggers** — The maintainer backfills markers, verifies resolution live, then lands statements in stages; the
  channel enforces on every subsequent install and update.
- **Preconditions** — Phase 4 is complete, so every remaining declaration is true. The baseline for every marker and
  statement is the set of per-plugin versions in the latest published suite release, not the working branch's
  in-flight numbers ([D4](artifacts/decision-log.md#d4-per-plugin-release-markers)). When a companion's baseline is a
  pre-release form, its statements deliberately opt into that form, because a plain same-major range excludes
  pre-releases and would strand the marker it points at
  ([D2](artifacts/decision-log.md#d2-same-major-version-statements)). Marker production for future releases must be
  covered before statements reach installers: either the release-process phase's mechanism is in place, or a manual
  marker step is a named part of every release in the gap
  ([D5](artifacts/decision-log.md#d5-staged-verified-reversible-rollout)).

## Primary Flow

1. The maintainer backfills one release marker per companion plugin, at its latest published release, pointing at the
   content that shipped under that release; the markers are confirmed present on the shared repository before
   anything else proceeds, because markers travel separately from merged changes and a statement served without its
   marker disables the depending plugin
   ([D4](artifacts/decision-log.md#d4-per-plugin-release-markers))
   ([T1](artifacts/feature-technical-notes.md#t1-how-the-first-channel-resolves-version-statements)).
2. A live verification trial runs before any statement reaches general installers: on a clean machine, one
   statement-bearing edge is installed from the channel against the pushed markers, confirming a compatible companion
   resolves, an unsatisfiable statement produces the channel's named missing-marker error, and an out-of-range
   companion is refused. The trial is what corroborates the channel's externally-documented behavior
   ([D5](artifacts/decision-log.md#d5-staged-verified-reversible-rollout)).
3. Statements then land in stages: one low-traffic edge first, verified end to end, then the remaining single edges,
   and the all-in-one bundle's six statements last, because a single bad marker among six would break the suite's
   most-installed path ([D5](artifacts/decision-log.md#d5-staged-verified-reversible-rollout)).
4. Before each stage ships, the authored ranges are checked to admit a common solution for every supported install
   combination, so a refused combination can only come from a user mixing outside versions, never from the suite's
   own statements ([D5](artifacts/decision-log.md#d5-staged-verified-reversible-rollout)).
5. From then on, installing a plugin resolves each companion to the newest marked version satisfying the statement,
   updates are offered within the allowed range, and an unsatisfiable combination is refused with a named error the
   person resolves deliberately
   ([T1](artifacts/feature-technical-notes.md#t1-how-the-first-channel-resolves-version-statements)).

## Alternate Flows and States

### A person runs a companion older than a plugin's statement allows

- **Entry condition:** A statement-carrying plugin is installed while its companion sits below the stated range.
- **Sequence:** The channel resolves the companion up into the stated range as part of the install, or refuses with a
  named error if it cannot; the mismatch is surfaced instead of silently accepted. Until more release markers
  accumulate, each range resolves to a single marked version in practice, since the backfill marks only the latest
  published release ([D4](artifacts/decision-log.md#d4-per-plugin-release-markers)).
- **Exit:** The person ends with a compatible pair or an explicit error naming what to update.

### A statement turns out wrong after people have resolved it

- **Entry condition:** A shipped statement is too strict, names the wrong line, or otherwise misfires.
- **Sequence:** The statements are file content, so the rollback is reverting them; the backfilled markers are
  additive and safe to leave. For people who already resolved the bad statement, the correction arrives as a new
  release of the depending plugin, which itself needs a fresh marker; recovery latency is a release cycle, which is
  why statements start deliberately wide and tighten only after the verification trial proves the mechanics
  ([D5](artifacts/decision-log.md#d5-staged-verified-reversible-rollout)).
- **Exit:** New installs stop seeing the bad statement immediately; already-resolved installations pick up the
  correction at their next update.

### The second channel

- **Entry condition:** A person installs plugins from the second channel, which resolves no dependencies.
- **Sequence:** Nothing changes there. Companion guidance for that channel remains the documented install
  instructions, unchanged by this phase ([D3](artifacts/decision-log.md#d3-first-channel-only)).
- **Exit:** Second-channel behavior is exactly as before.

## Edge Cases and Failure Modes

| Condition                                                                     | Required Behavior                                                                                                        |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| Statements are served while their markers are missing from the shared repository | This is the primary failure mode, not an unreachable one: the marker-confirmation gate in the flow blocks the stage, and a post-ship check confirms every referenced marker resolves. |
| A release happens after this phase ships but before the release process produces markers | The named gap plan applies: a manual marker step is part of every release in the window, so dependents are neither pinned to stale versions nor disabled. |
| A companion updates while the depending plugin still runs a pre-statement version | No enforcement fires yet; protection begins when the depending plugin upgrades. The shipping release says so.             |
| A future release bumps a companion's major version                              | Every edge to that companion, including the all-in-one bundle's, moves in the same release, or the intersection goes empty and the bundle refuses to install. |
| A companion's baseline version is a pre-release form                            | Its statements opt into the pre-release form deliberately; a plain range would exclude the only marker that exists.        |
| A person already runs a combination outside the new statements                  | Nothing breaks retroactively; the statements apply when the depending plugin next installs or updates.                    |

## Coordinations

| Coordinating System      | Direction | Interaction                                                              | Ordering / Consistency Requirement                                                  |
| ------------------------ | --------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| First install channel    | outbound  | Reads statements, resolves companions by release marker, enforces ranges | Markers confirmed on the shared repository before any statement stage ships ([T1](artifacts/feature-technical-notes.md#t1-how-the-first-channel-resolves-version-statements)). |
| The release process      | outbound  | Hands off: produces per-plugin release markers on every future release   | The backfill and the gap plan are this phase's; ongoing production is Phase 6's ([Phase 6 of the outline](../build-phase-outline.md#phase-6)). |
| Second install channel   | none      | Resolves no dependencies; unaffected                                     | Named limitation, documented, nothing to change.                                     |

## Out of Scope

- Teaching the release process to produce the markers and update statements on future releases. That is Phase 6; this
  phase hands it a working baseline and covers the gap with a named manual step.
- Any statement on the second channel, which has no dependency mechanism to read one.
- Changing which dependencies exist. Phase 4 settled the edges; this phase only adds version statements to them.
- Release markers for plugins no statement resolves against. Only companions need markers for this phase; Phase 6
  produces markers for every plugin going forward ([D4](artifacts/decision-log.md#d4-per-plugin-release-markers)).

## Open Items

- **OI-1:** Confirm the exact set of dependency edges receiving statements by reading the post-Phase-4 tree. The
  expected list: Core to Communication; Planning to Communication and Core; Coding to Communication and Core; GitHub
  to Communication and Core; Reporting to Communication; Atlassian's four; and the all-in-one bundle's six.
  - **Resolves when:** Phase 4 merges and the edge list is read from the tree, not from this spec.
  - **Blocks implementation:** No — it fixes the work list, not the behavior.
- **OI-2:** The verification trial doubles as the unresolved outline precondition: whether the channel enforces
  statements as its documentation describes. If the trial disproves the documented enforcement, the phase pauses and
  the question returns to the team; unenforced statements do not ship as decoration.
  - **Resolves when:** The trial in the primary flow runs.
  - **Blocks implementation:** Yes for landing statements; no for the marker backfill, which is additive and safe.

## Summary

- **Outcome delivered:** Every true dependency carries an enforced version statement, mismatches surface as named
  errors or resolved upgrades, markers exist for the channel to resolve, and the rollout is staged, verified live,
  and reversible.
- **Primary actors:** People installing or updating from the first channel; the maintainer running the rollout.
- **Decisions settled by evidence:** 4 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 (the phase itself was commissioned by the user's OQ-2 decision in the
  outline) — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, devops-engineer, gap-analyzer — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the rollout became staged, live-verified, and reversible after review showed a
  suite-wide install break was one forgotten step away; the pre-release baseline hazard on the current alpha line was
  named and handled; the enforcement-reach limit for existing installations was made explicit; markers narrowed to
  companion plugins only. — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 2
- **Technical notes:** 1 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
