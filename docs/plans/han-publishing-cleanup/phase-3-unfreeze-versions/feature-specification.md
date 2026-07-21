# Feature Specification: Unfreeze the Second Channel's Version Numbers

Every plugin's stated version on the second install channel is corrected to match the version released on the first
channel, so people installing from the second channel start being offered updates again.

## Outcome

A person running an older copy of any Han plugin from the second channel checks for updates and is offered one, where
today none is ever offered. That payoff rests on the second channel offering an update when the version it serves is
newer than the installed one; the demonstration in [OI-1](#open-items) is what confirms it
([T1](artifacts/feature-technical-notes.md#t1-how-the-second-channel-offers-updates)). The correction itself sets each
plugin's second-channel version to the version last released on the first channel
([D2](artifacts/decision-log.md#d2-align-to-the-first-channels-versions)). After the correction the two numbers match
for every plugin; keeping them matched on future releases belongs to the release-process phase, not this one. The
cleanup's later automated completeness check cannot land green while these numbers are stale, so this phase is one of
its prerequisites.

## Actors and Triggers

- **Actors** — People with Han plugins installed from the second channel; the maintainer applying the correction.
- **Triggers** — The maintainer corrects the stated versions once; users' channel tooling then compares versions
  whenever it checks for updates.
- **Preconditions** — The target version for each plugin is the version of its last published release, as the first
  channel records it; nothing is guessed
  ([D2](artifacts/decision-log.md#d2-align-to-the-first-channels-versions)). Before starting, confirm no
  second-channel version is ahead of its first-channel counterpart. The corrections reach users when the working
  branch merges to the default branch, which the second channel serves
  ([T1](artifacts/feature-technical-notes.md#t1-how-the-second-channel-offers-updates)).

## Primary Flow

1. The maintainer reads each plugin's released version from the first channel.
2. For every plugin whose second-channel version lags, the second-channel version is set to the released version.
   Plugins already matching are left untouched.
3. The change ships with the working branch's merge to the default branch.
4. A person with a genuinely older installed copy, older in content and not only in number, checks for updates on the
   second channel and is offered the released version.
5. They accept, and the installed version matches the version released on the first channel. The demonstration
   confirms an observable content difference after accepting, not only a higher number, because a version number on
   this channel does not by itself prove fresh content
   ([T1](artifacts/feature-technical-notes.md#t1-how-the-second-channel-offers-updates)).

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
| The release process        | none yet  | Hands off: the aligned state is the baseline the release-process phase maintains | This phase does nothing with the release process; the hand-off lands in Phase 6. |

## Out of Scope

- Automating version updates on future releases. That is the release-process phase
  ([Phase 6 of the outline](../build-phase-outline.md#phase-6)); this phase is the one-time correction it builds on.
- The Linear plugin's listing (Phase 1) and the all-in-one bundle, which the second channel does not carry.
- Changing how either channel decides that an update is available.

## Open Items

- **OI-1:** Confirm the second channel offers an update purely by comparing the served version against the installed
  one, with no other freshness signal, and that accepting an update re-reads the plugin's content rather than serving
  something cached by version.
  - **Resolves when:** A real update is offered and accepted during this phase's demonstration, with a confirmed
    content difference.
  - **Blocks implementation:** No for the correction itself, which is right regardless. Yes for signing off the
    user-visible payoff this phase promises; the demonstration is that sign-off.

## Summary

- **Outcome delivered:** Second-channel versions match the first channel's released versions, and update offers
  resume.
- **Primary actors:** Second-channel users; the maintainer applying the one-time correction.
- **Decisions settled by evidence:** 1 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, gap-analyzer — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the update-offer payoff is now explicitly gated on the OI-1 demonstration; the
  demo requires a content difference, not only a higher number; the source of truth is pinned to the last published
  release; the Phase 7 dependency is restored. — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
- **Technical notes:** 1 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
