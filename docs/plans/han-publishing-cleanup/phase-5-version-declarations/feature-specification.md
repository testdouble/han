# Feature Specification: Declare the Plugin Versions That Work Together

Every plugin that depends on another states which versions of that companion it works with, the first install channel
enforces the statements at install and update time, and a mismatched pair can no longer be assembled silently.

## Outcome

Each dependency a plugin declares carries a version statement: the companion works when its version is in the same
major line at or above the stated release ([D2](artifacts/decision-log.md#d2-same-major-version-statements)). The
first install channel enforces the statements: installs and updates resolve companions within the stated range, and a
combination that cannot be satisfied is refused with a named error instead of assembled silently
([T1](artifacts/feature-technical-notes.md#t1-how-the-first-channel-resolves-version-statements)). The second channel
resolves no dependencies at all, so it neither reads nor enforces the statements; that is a named limitation, not a
gap in this phase ([D3](artifacts/decision-log.md#d3-first-channel-only)).

Enforcement only works if the channel can find each companion version by its release marker. Today releases are marked
at the suite level only, so this phase includes a one-time backfill of per-plugin release markers, and the
release-process phase keeps producing them from then on
([D4](artifacts/decision-log.md#d4-per-plugin-release-markers)).

## Actors and Triggers

- **Actors** — People installing or updating Han plugins from the first channel; maintainers declaring the
  statements.
- **Triggers** — The maintainer adds a version statement to every declared dependency and backfills the per-plugin
  release markers; the channel then enforces on every install and update.
- **Preconditions** — Phase 4 is complete, so every remaining declaration is true. The per-plugin release markers
  exist in the form the channel resolves before any statement lands; a statement without its markers would disable
  the depending plugin at install ([T1](artifacts/feature-technical-notes.md#t1-how-the-first-channel-resolves-version-statements))
  ([D4](artifacts/decision-log.md#d4-per-plugin-release-markers)).

## Primary Flow

1. The maintainer backfills a release marker for each plugin at its current released version, in the form the first
   channel resolves ([D4](artifacts/decision-log.md#d4-per-plugin-release-markers)).
2. Every declared dependency across the suite gains a version statement: same major line, at or above the version the
   depending plugin was verified against ([D2](artifacts/decision-log.md#d2-same-major-version-statements)). The
   plugins that depend on nothing get no statements.
3. On a clean machine, installing a plugin resolves each companion to the newest version satisfying the statement,
   and the assembled set works together.
4. Updating a companion respects every installed plugin's statement: the channel offers versions within the allowed
   range, and a version outside every range is not offered as a silent upgrade.
5. When two installed plugins state ranges for the same companion that cannot both be satisfied, the channel refuses
   the combination with a named error, and the person resolves it deliberately
   ([T1](artifacts/feature-technical-notes.md#t1-how-the-first-channel-resolves-version-statements)).

## Alternate Flows and States

### A person runs a companion older than a plugin's statement allows

- **Entry condition:** A plugin is installed while its companion sits below the stated range, for example a
  months-old copy never updated.
- **Sequence:** The channel resolves the companion up into the stated range as part of the install, or refuses with a
  named error if it cannot; the mismatch is surfaced instead of silently accepted.
- **Exit:** The person ends with a compatible pair or an explicit error naming what to update. Today, nothing
  anywhere notices or complains; that silence is what this phase ends.

### The second channel

- **Entry condition:** A person installs plugins from the second channel, which resolves no dependencies.
- **Sequence:** Nothing changes there. Companion guidance for that channel remains the documented install
  instructions, unchanged by this phase ([D3](artifacts/decision-log.md#d3-first-channel-only)).
- **Exit:** Second-channel behavior is exactly as before.

## Edge Cases and Failure Modes

| Condition                                                                  | Required Behavior                                                                                                        |
| --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| A version statement lands before its companion's release markers exist      | The depending plugin would be disabled at install with a named error; the backfill-first ordering in the primary flow exists to make this unreachable. |
| A future release bumps a companion's major version                          | Existing statements exclude the new major on purpose; the releasing maintainer updates depending plugins' statements as part of that release. |
| A person already runs a combination outside the new statements              | Nothing breaks retroactively; the statements apply at the next install or update, which is when the mismatch is surfaced. |
| The pre-release form of a version                                           | Excluded from every stated range unless a statement opts in deliberately.                                                  |

## Coordinations

| Coordinating System      | Direction | Interaction                                                            | Ordering / Consistency Requirement                                                  |
| ------------------------ | --------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| First install channel    | outbound  | Reads statements, resolves companions by release marker, enforces ranges | Markers exist before statements; statements land as one change across the suite ([T1](artifacts/feature-technical-notes.md#t1-how-the-first-channel-resolves-version-statements)). |
| The release process      | outbound  | Hands off: produces per-plugin release markers on every future release  | The one-time backfill is this phase's; ongoing production is Phase 6's
  ([Phase 6 of the outline](../build-phase-outline.md#phase-6)).                     |
| Second install channel   | none      | Resolves no dependencies; unaffected                                   | Named limitation, documented, nothing to change.                                     |

## Out of Scope

- Teaching the release process to produce the markers and update statements on future releases. That is Phase 6; this
  phase hands it a working baseline.
- Any statement on the second channel, which has no dependency mechanism to read one.
- Changing which dependencies exist. Phase 4 settled the edges; this phase only adds version statements to them.

## Open Items

- **OI-1:** Confirm the exact set of dependency edges receiving statements matches the post-Phase-4 graph: the Core
  plugin's edge to Communication; Planning's to Core; Coding's and GitHub's to Communication and Core; Reporting's to
  Communication; Atlassian's four; and the all-in-one bundle's six.
  - **Resolves when:** Phase 4 merges and the edge list is read from the tree, not from this spec.
  - **Blocks implementation:** No — it fixes the work list, not the behavior.

## Summary

- **Outcome delivered:** Every true dependency carries an enforced version statement, mismatches surface as named
  errors or resolved upgrades, and per-plugin release markers exist for the channel to resolve.
- **Primary actors:** People installing or updating from the first channel; the maintainer.
- **Decisions settled by evidence:** 3 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 (the phase itself was commissioned by the user's OQ-2 decision in the
  outline) — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
- **Technical notes:** 1 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
