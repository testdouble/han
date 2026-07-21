# Feature Specification: Turn On the Automated Completeness Check

An automated check asks one question on every proposed change and every release: does every plugin appear everywhere
it should, at the right version? It lands only after the tree already passes it, so it arrives green, stays green, and
makes every problem the earlier phases fixed impossible to reintroduce quietly.

## Outcome

A plugin can no longer land invisible on a publishing surface by default. On every proposed change, the check runs
automatically and blocks the change when any plugin is missing from a surface it belongs on or the two channels
disagree about a plugin's version, naming each missing plugin and surface in its failure report
([D2](artifacts/decision-log.md#d2-one-rule-two-enforcement-moments)). On every release, the same rule runs again as
the release process's own gate, so the two can never disagree
([D2](artifacts/decision-log.md#d2-one-rule-two-enforcement-moments)).

The check knows the all-in-one bundle's absence from the second channel permanently, by reading the same durable
exception record the release process reads, and never flags it
([D3](artifacts/decision-log.md#d3-shared-rule-shared-exception-record)). The order of arrival is not negotiable: the
check turns on only after the earlier phases leave a tree that passes it, because a check that lands red gets disabled
and then protects nothing ([D4](artifacts/decision-log.md#d4-green-first-arrival)).

## Actors and Triggers

- **Actors** — Anyone proposing a change to the repository; the maintainer cutting releases; the future contributor
  who adds a plugin and is caught before it lands half-published.
- **Triggers** — Automatically on every proposed change; as a gate inside every release run
  ([D2](artifacts/decision-log.md#d2-one-rule-two-enforcement-moments)).
- **Preconditions** — Phases 1, 3, and 6 are complete: the Linear plugin is listed, the version records agree, and
  the release process maintains all four surfaces. The check's first run against the real tree passes before it is
  allowed to block anything ([D4](artifacts/decision-log.md#d4-green-first-arrival)). The durable exception record
  exists and is readable ([D3](artifacts/decision-log.md#d3-shared-rule-shared-exception-record)).

## Primary Flow

1. Someone proposes a change. The check runs with the repository's other automatic checks, discovers every plugin the
   same way the release process does, and compares each against every surface it belongs on
   ([D2](artifacts/decision-log.md#d2-one-rule-two-enforcement-moments)).
2. When everything is present and the channels agree on versions, the check passes quietly and the change proceeds.
3. When anything is missing or mismatched, the check fails and its report names each missing plugin, the surface it
   is missing from, and each version disagreement, so the fix needs no investigation.
4. The bundle's absence from the second channel is read from the exception record and never reported
   ([D3](artifacts/decision-log.md#d3-shared-rule-shared-exception-record)).
5. At release time, the same rule runs as the release process's presence gate, and the release's own override path is
   the only sanctioned way past it ([D2](artifacts/decision-log.md#d2-one-rule-two-enforcement-moments)).

## Alternate Flows and States

### A new plugin is added without being published everywhere

- **Entry condition:** A proposed change adds a plugin directory but does not list it on every surface it belongs on.
- **Sequence:** The check fails the change, naming the new plugin and each surface it is missing from. The
  contributor adds the listings, or a deliberate durable exception, and the check passes.
- **Exit:** The failure that created the Linear gap is caught at the moment it is introduced, not twenty releases
  later.

### The check itself misfires

- **Entry condition:** The check reports a gap that a person judges wrong, or the exception record cannot be read.
- **Sequence:** An unreadable exception record fails closed and names the record itself as the fault, mirroring the
  release process's rule. A disputed report is resolved by fixing either the tree or the exception record; the check
  is not disabled, because a disabled check protects nothing
  ([D4](artifacts/decision-log.md#d4-green-first-arrival)).
- **Exit:** The check stays on, and the record or the tree ends the dispute.

## Edge Cases and Failure Modes

| Condition                                                          | Required Behavior                                                                                                        |
| -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| The check's very first run against the real tree fails               | The check does not begin blocking; the failure goes back to the earlier phases' owners, because arriving red is the disable-me failure mode. |
| A change deletes a plugin directory but leaves its listings          | The check fails naming the orphan entries, the mirror of the missing-plugin case.                                          |
| The exception record is edited in a proposed change                  | The check evaluates the change with the edited record, so adding or removing an exception is itself a reviewed, visible change. |
| An urgent release must ship past a failing check                     | Only the release process's loud, recorded override applies; the change-time check has no silent bypass.                    |

## Coordinations

| Coordinating System     | Direction | Interaction                                                       | Ordering / Consistency Requirement                                              |
| ----------------------- | --------- | ----------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| The release process (Phase 6) | both | Shares the discovery rule, the surface list, and the exception record | One rule, two enforcement moments; they can never disagree ([D2](artifacts/decision-log.md#d2-one-rule-two-enforcement-moments)) ([D3](artifacts/decision-log.md#d3-shared-rule-shared-exception-record)). |
| The repository's automatic change checks | outbound | The completeness check joins them and blocks failing changes | It begins blocking only after its first green run against the real tree ([D4](artifacts/decision-log.md#d4-green-first-arrival)). |

## Out of Scope

- Checking companion version statements and release markers on every proposed change. The release process's
  post-publish reconciliation owns marker and statement verification; this check owns presence and version agreement
  across the four surfaces. Reopen if a statement-marker mismatch ever escapes the release reconciliation.
- Repairing gaps automatically. The check names problems; people fix them.
- Any new publishing surface. Four surfaces and one exception are what exist.

## Open Items

- **OI-1:** None. The check's behavioral surface is fully settled by the earlier phases' outcomes; its enforcement
  point among the repository's existing automatic checks is an implementation choice.
  - **Resolves when:** Not applicable.
  - **Blocks implementation:** No.

## Summary

- **Outcome delivered:** Every proposed change and every release is gated on complete, version-agreed publishing
  across all four surfaces, with one permanent, shared exception, and the check arrives only when it can arrive
  green.
- **Primary actors:** Contributors proposing changes; the maintainer releasing; future plugin authors.
- **Decisions settled by evidence:** 3 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0
