# Feature Specification: Unfreeze the Second Channel's Version Numbers

Every plugin's stated version on the second install channel is corrected to match the version released on the first
channel, so people installing from the second channel start being offered updates again.

## Outcome

A person running an older copy of any Han plugin from the second channel checks for updates and is offered one, where
today none is ever offered. The correction sets each plugin's second-channel version to the same version released on
the first channel, one version per plugin across both channels
([D2](artifacts/decision-log.md#d2-align-to-the-first-channels-versions)). The second channel offers an update when
the version it serves is newer than the installed one, so the correction is what restarts update offers
([T1](artifacts/feature-technical-notes.md#t1-how-the-second-channel-offers-updates)). Keeping the numbers moving on
future releases belongs to the release-process phase, not this one.

## Actors and Triggers

- **Actors** — People with Han plugins installed from the second channel; the maintainer applying the correction.
- **Triggers** — The maintainer corrects the stated versions once; users' channel tooling then compares versions
  whenever it checks for updates.
- **Preconditions** — The target version for each plugin is read from the first channel's released versions, not
  guessed ([D2](artifacts/decision-log.md#d2-align-to-the-first-channels-versions)). The corrections reach users when
  the working branch merges to the default branch, which the second channel serves
  ([T1](artifacts/feature-technical-notes.md#t1-how-the-second-channel-offers-updates)).

## Primary Flow

1. The maintainer reads each plugin's released version from the first channel.
2. For every plugin whose second-channel version lags, the second-channel version is set to the released version.
   Plugins already matching are left untouched.
3. The change ships with the working branch's merge to the default branch.
4. A person with an older installed copy checks for updates on the second channel and is offered the released
   version.
5. They accept, and the installed version now matches the version released on the first channel.

## Alternate Flows and States

### A plugin's two versions already match

- **Entry condition:** A plugin's second-channel version already equals the first channel's released version.
- **Sequence:** No change is made for that plugin, and no update is offered to users already current.
- **Exit:** The plugin is simply confirmed aligned.

## Edge Cases and Failure Modes

| Condition                                                                | Required Behavior                                                                                                        |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| A second-channel version is found ahead of the first channel's version   | The correction stops for that plugin and the discrepancy is raised to the maintainer; a version is never moved backward without a person deciding. |
| A user checks for updates before the correction reaches the default branch | They are still offered nothing; the outcome is promised from the merge onward ([T1](artifacts/feature-technical-notes.md#t1-how-the-second-channel-offers-updates)). |
| A user is on the corrected version already                               | No update is offered; the check is quiet.                                                                                 |

## Coordinations

| Coordinating System        | Direction | Interaction                                                       | Ordering / Consistency Requirement                                          |
| -------------------------- | --------- | ----------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| First install channel      | inbound   | Supplies each plugin's released version as the source of truth    | The correction copies from it, never invents versions ([D2](artifacts/decision-log.md#d2-align-to-the-first-channels-versions)). |
| Second install channel     | outbound  | Serves the corrected versions and offers updates by comparison    | Corrections are user-visible only after the merge to the default branch ([T1](artifacts/feature-technical-notes.md#t1-how-the-second-channel-offers-updates)). |
| The release process        | outbound  | Inherits the aligned state so future releases keep both channels moving | Ongoing upkeep is the release-process phase's job, building on this one. |

## Out of Scope

- Automating version updates on future releases. That is the release-process phase
  ([Phase 6 of the outline](../build-phase-outline.md#phase-6)); this phase is the one-time correction it builds on.
- The Linear plugin's listing (Phase 1) and the all-in-one bundle, which the second channel does not carry.
- Changing how either channel decides that an update is available.

## Open Items

- **OI-1:** Confirm the second channel offers an update purely by comparing the served version against the installed
  one, with no other freshness signal involved.
  - **Resolves when:** A real update is offered and accepted during this phase's demonstration.
  - **Blocks implementation:** No — the correction is right regardless; this verifies the user-visible payoff.

## Summary

- **Outcome delivered:** Second-channel versions match the first channel's released versions, and update offers
  resume.
- **Primary actors:** Second-channel users; the maintainer applying the one-time correction.
- **Decisions settled by evidence:** 1 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
- **Technical notes:** 1 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
