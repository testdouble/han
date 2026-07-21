# Feature Specification: Teach the Release Process About All Four Publishing Surfaces

The release process starts from the plugins as they exist in the repository, updates all four publishing surfaces
instead of two, stops with a named report when anything is missing, and knows the all-in-one bundle's absence from the
second channel as a permanent, documented exception.

## Outcome

A maintainer cutting a release can no longer ship around a gap without seeing it. The release begins by discovering
every plugin from the repository itself, rather than trusting a listing file that can go stale
([D2](artifacts/decision-log.md#d2-the-repository-is-the-source-of-truth)). It updates all four surfaces: the first
channel's per-plugin version records and its storefront listing, and the second channel's per-plugin version records
and its storefront listing ([D3](artifacts/decision-log.md#d3-the-four-surfaces-and-what-current-means)). When a
plugin is missing from a surface it belongs on, the release stops and says exactly what is absent, instead of
finishing quietly ([D2](artifacts/decision-log.md#d2-the-repository-is-the-source-of-truth)). The one deliberate
exception, the all-in-one bundle that the second channel cannot carry, is recorded durably in a single place and never
reported as a gap ([D4](artifacts/decision-log.md#d4-the-bundle-exception-lives-in-one-durable-place)).

The release also carries the previous phase's hand-off: it produces a per-plugin release marker for every released
plugin and keeps companion version statements current, including moving every edge to a companion in the same release
when that companion's major version bumps ([D5](artifacts/decision-log.md#d5-markers-and-statements-on-every-release)).

## Actors and Triggers

- **Actors** — The maintainer cutting a release; every user of both channels, who receives what the release publishes.
- **Triggers** — The maintainer runs the release process, or runs it in rehearsal mode to see what it would do without
  publishing anything.
- **Preconditions** — Phases 1 and 3 are complete, so the process inherits surfaces that are already correct rather
  than alarming on day one. The bundle exception's durable record exists where both this process and the later
  automated check read it ([D4](artifacts/decision-log.md#d4-the-bundle-exception-lives-in-one-durable-place)).

## Primary Flow

1. The maintainer starts a release. The process discovers the set of plugins from the repository itself
   ([D2](artifacts/decision-log.md#d2-the-repository-is-the-source-of-truth)).
2. For each discovered plugin, the process checks its presence on every surface it belongs on, honoring the bundle
   exception ([D3](artifacts/decision-log.md#d3-the-four-surfaces-and-what-current-means))
   ([D4](artifacts/decision-log.md#d4-the-bundle-exception-lives-in-one-durable-place)).
3. If anything is missing, the release stops before publishing and reports each absent plugin and the surface it is
   absent from. The maintainer fixes the gap and re-runs.
4. The process updates the version records and listings on all four surfaces so both channels state the same released
   version for every plugin ([D3](artifacts/decision-log.md#d3-the-four-surfaces-and-what-current-means)).
5. The process produces a per-plugin release marker for every plugin being released and updates companion version
   statements where the release requires it
   ([D5](artifacts/decision-log.md#d5-markers-and-statements-on-every-release)).
6. In rehearsal mode, the same run reports everything it would do, including the discovered plugin list, the
   per-surface check results, and the bundle exception as a known allowance, without publishing anything.

## Alternate Flows and States

### A new plugin exists in the repository but nowhere else

- **Entry condition:** A plugin directory was added since the last release and no surface lists it yet.
- **Sequence:** Discovery finds it, the per-surface check reports it missing from every surface it belongs on, and
  the release stops with that report. Nothing ships until the plugin is listed everywhere or deliberately excluded
  with a durable record like the bundle's.
- **Exit:** The failure that created the Linear gap, a new plugin landing invisible by default, can no longer happen
  silently.

### A companion's major version bumps in this release

- **Entry condition:** The release includes a breaking change to a plugin that others depend on.
- **Sequence:** The process updates every depending plugin's version statement to the new line in the same release,
  so the stated ranges never go unsatisfiable ([D5](artifacts/decision-log.md#d5-markers-and-statements-on-every-release)).
- **Exit:** The release ships with statements and markers agreeing.

## Edge Cases and Failure Modes

| Condition                                                                | Required Behavior                                                                                                        |
| -------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| The storefront listing names a plugin that no longer exists in the repository | The check reports the orphan entry; the release stops until it is removed or the plugin restored.                        |
| A plugin is deliberately absent from a surface                              | Only a durable exception record, like the bundle's, silences the report; an undocumented absence always stops the release. |
| The release is interrupted partway                                          | Re-running is safe: the per-surface check reruns from the repository state, and already-updated surfaces read as current. |
| Rehearsal mode                                                              | Reports everything, publishes nothing, and exits without changing any surface.                                            |

## Coordinations

| Coordinating System            | Direction | Interaction                                                          | Ordering / Consistency Requirement                                            |
| ------------------------------ | --------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Both install channels          | outbound  | Receive updated version records and listings on every release        | The presence check passes before anything publishes; both channels end stating the same versions. |
| The automated completeness check (Phase 7) | outbound | Enforces the same rule this process follows                 | Both read the same durable exception record, so they can never disagree about the bundle ([D4](artifacts/decision-log.md#d4-the-bundle-exception-lives-in-one-durable-place)). |
| Version statements and markers (Phase 5)   | inbound  | The baseline this process maintains going forward           | Every release produces markers; statements move with major bumps ([D5](artifacts/decision-log.md#d5-markers-and-statements-on-every-release)). |

## Out of Scope

- Building the automated completeness check itself. That is Phase 7; this phase gives it a tree that passes and a
  shared exception record.
- Correcting today's stale surfaces. Phases 1 and 3 do that; this phase keeps them correct.
- Changing what a release publishes to either channel beyond versions, listings, markers, and statements.

## Open Items

- **OI-1:** Decide where the durable bundle-exception record lives so both the release process and the Phase 7 check
  read the same one, and confirm the format can name future deliberate exceptions if any arise.
  - **Resolves when:** Implementation planning picks the location; the behavioral requirement, one record read by
    both, is settled here.
  - **Blocks implementation:** No — it is a placement choice inside a settled behavior.

## Summary

- **Outcome delivered:** Releases start from the repository, cover all four surfaces, stop loudly on gaps, honor one
  durable exception, and maintain the markers and statements the earlier phases introduced.
- **Primary actors:** The maintainer cutting releases; users of both channels.
- **Decisions settled by evidence:** 4 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
