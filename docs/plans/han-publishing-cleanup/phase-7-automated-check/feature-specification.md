# Feature Specification: Turn On the Automated Completeness Check

An automated check asks one question on every proposed change and every release: does every plugin appear everywhere
it should, at agreed versions? It lands only after the tree already passes it, so it arrives green, stays green, and
keeps the publishing repairs of Phases 1, 3, and 6 from regressing quietly.

## Outcome

A plugin can no longer land invisible on a publishing surface by default. On every proposed change, the check runs
automatically and blocks the change when any plugin is missing from a surface it belongs on, or when the proposed
tree's two channels disagree about a plugin's version. Its failure report names each missing plugin, the surface it
is missing from, and each version disagreement ([D2](artifacts/decision-log.md#d2-one-verdict-two-enforcement-moments)).

The check's guarantee is verdict equivalence, not a shared machine: given the same tree and the same exception record,
the change-time check and the release-time gate return the same verdict. All four surfaces are files in this
repository, which is what makes the change-time verdict possible at all
([D2](artifacts/decision-log.md#d2-one-verdict-two-enforcement-moments)). The check can also be run on demand against
any working tree, which is how its demonstration works.

The check guards presence and version agreement: the outcomes of Phases 1, 3, and 6. It does not examine ticket-file
marks (Phase 2), the truth of dependency declarations (Phase 4), or companion version statements and release markers
(Phase 5); the release process's own reconciliation owns markers and statements
([D2](artifacts/decision-log.md#d2-one-verdict-two-enforcement-moments)).

The check knows the all-in-one bundle's absence from the second channel permanently, by reading the same durable
exception record the release process reads, and never flags it
([D3](artifacts/decision-log.md#d3-shared-exception-record)). The order of arrival is not negotiable: the check turns
on only after a recorded green run against the real tree, because a check that lands red gets disabled and then
protects nothing ([D4](artifacts/decision-log.md#d4-green-first-arrival-and-the-repair-door)).

## Actors and Triggers

- **Actors** — Anyone proposing a change to the repository; the maintainer cutting releases; the future contributor
  who adds a plugin and is caught before it lands half-published.
- **Triggers** — Automatically on every proposed change; as the release process's presence gate; on demand against
  any working tree ([D2](artifacts/decision-log.md#d2-one-verdict-two-enforcement-moments)).
- **Preconditions** — Phases 1, 3, and 6 are complete: the Linear plugin is listed, the version records agree, and
  the release process maintains all four surfaces. The turn-on condition is observable: a recorded green run against
  the real tree, owned by the maintainer; until it exists, the check does not block
  ([D4](artifacts/decision-log.md#d4-green-first-arrival-and-the-repair-door)). The durable exception record exists
  and is readable ([D3](artifacts/decision-log.md#d3-shared-exception-record)).

## Primary Flow

1. Someone proposes a change. The check runs with the repository's other automatic checks, discovers every plugin
   from the proposed tree the same way the release process discovers them, and evaluates the proposed tree's
   end state: every plugin present on every surface it belongs on, and both channels stating the same version
   ([D2](artifacts/decision-log.md#d2-one-verdict-two-enforcement-moments)).
2. When everything is present and agreed, the check passes quietly and the change proceeds. A release-preparation
   change passes the same way, because a release moves all four surfaces together in one change; a change that moves
   one surface and not its partners is exactly what the check exists to block
   ([D2](artifacts/decision-log.md#d2-one-verdict-two-enforcement-moments)).
3. When anything is missing or mismatched, the check fails and its report names each missing plugin, the surface it
   is missing from, and each version disagreement, so the fix needs no investigation.
4. The bundle's absence from the second channel is read from the exception record and never reported
   ([D3](artifacts/decision-log.md#d3-shared-exception-record)).
5. At release time, the same verdict gates the release, and the release's loud, recorded override is the only
   sanctioned way past it ([D2](artifacts/decision-log.md#d2-one-verdict-two-enforcement-moments)).

## Alternate Flows and States

### A new plugin is added without being published everywhere

- **Entry condition:** A proposed change adds a plugin directory but does not list it on every surface it belongs on.
- **Sequence:** The check fails the change, naming the new plugin and each surface it is missing from. The
  contributor adds the listings, or a deliberate durable exception, and the check passes.
- **Exit:** The failure that created the Linear gap is caught at the moment it is introduced, not twenty releases
  later.

### The check itself is wrong

- **Entry condition:** The check false-fails because its own logic is broken, so it would block every change,
  including the change that fixes it.
- **Sequence:** A scoped, recorded repair door exists: a change whose purpose is fixing the check or its exception
  record may land past the failing check, with the bypass named visibly in that change, mirroring the release
  override's loud-and-recorded principle. The check is never simply disabled
  ([D4](artifacts/decision-log.md#d4-green-first-arrival-and-the-repair-door)).
- **Exit:** The fixed check resumes blocking; the bypass remains auditable.

### A disputed report

- **Entry condition:** The check reports a gap a person judges wrong, or the exception record cannot be read.
- **Sequence:** An unreadable exception record fails closed and names the record itself as the fault, mirroring the
  release process's rule. A disputed report is resolved by fixing the tree, the record, or, through the repair door,
  the check ([D4](artifacts/decision-log.md#d4-green-first-arrival-and-the-repair-door)).
- **Exit:** The check stays on, and the fix ends the dispute.

## Edge Cases and Failure Modes

| Condition                                                          | Required Behavior                                                                                                        |
| -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| The check's very first run against the real tree fails               | The check does not begin blocking; the failure goes back to the earlier phases' owners, because arriving red is the disable-me failure mode. |
| A change deletes a plugin directory but leaves its listings          | The check fails naming the orphan entries; kept for verdict parity with the release process's symmetric rail, which itself carries no claimed incident. |
| The exception record is edited in a proposed change                  | The check evaluates the change with the edited record, so adding or removing an exception is itself a reviewed, visible change. |
| An urgent release must ship past a failing check                     | Only the release process's loud, recorded override applies; the change-time check's only bypass is the scoped repair door for fixing the check itself. |

## Coordinations

| Coordinating System     | Direction | Interaction                                                       | Ordering / Consistency Requirement                                              |
| ----------------------- | --------- | ----------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| The release process (Phase 6) | both | Shares the discovery rule, the surface list, and the exception record | Verdict equivalence: same tree and record, same verdict, at both moments ([D2](artifacts/decision-log.md#d2-one-verdict-two-enforcement-moments)) ([D3](artifacts/decision-log.md#d3-shared-exception-record)). |
| The repository's automatic change checks | outbound | The completeness check joins them and blocks failing changes | It begins blocking only after the recorded green run against the real tree ([D4](artifacts/decision-log.md#d4-green-first-arrival-and-the-repair-door)). |

## Out of Scope

- Guarding what the check does not examine: ticket-file marks (Phase 2), the truth of dependency declarations
  (Phase 4), and companion version statements and release markers (Phase 5). The release process's post-publish
  reconciliation owns markers and statements. Reopen if a statement-marker mismatch ever escapes that
  reconciliation ([D2](artifacts/decision-log.md#d2-one-verdict-two-enforcement-moments)).
- Repairing gaps automatically. The check names problems; people fix them.
- Any new publishing surface. Four surfaces and one exception are what exist.

## Open Items

- **OI-1:** None. The version-agreement verdict, the enforcement moments, the exception record, the turn-on
  condition, and the repair door are all settled here; the check's placement among the repository's existing
  automatic checks is an implementation choice.
  - **Resolves when:** Not applicable.
  - **Blocks implementation:** No.

## Summary

- **Outcome delivered:** Every proposed change and every release is gated on complete, version-agreed publishing
  across all four surfaces, with one permanent shared exception, a recorded green arrival, and a scoped repair door
  instead of an off switch.
- **Primary actors:** Contributors proposing changes; the maintainer releasing; future plugin authors.
- **Decisions settled by evidence:** 3 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, gap-analyzer — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** "one rule" became verdict equivalence with the release gate; the version verdict
  was reconciled with how releases move surfaces together; the guard claim was narrowed to Phases 1, 3, and 6, and
  the outline's Phase 4 guard claim was corrected; a repair door replaced the unbreakable no-disable deadlock; the
  turn-on condition became an observable recorded green run. — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0
