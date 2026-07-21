# Feature Specification: Teach the Release Process About All Four Publishing Surfaces

The release process starts from the plugins as they exist in the repository, updates all four publishing surfaces
instead of two, stops with a named report when anything is missing, verifies after publishing that everything really
landed, and knows the all-in-one bundle's absence from the second channel as a permanent, documented exception.

## Outcome

A maintainer cutting a release can no longer ship around a gap without seeing it. The release begins by discovering
every plugin from the repository itself: a plugin is a top-level directory carrying the first channel's manifest, and
the all-in-one bundle is the one plugin whose role is to install the others
([D2](artifacts/decision-log.md#d2-the-repository-is-the-source-of-truth)). Every discovered plugin belongs on all
four surfaces by default; only a durable exception record subtracts a surface, and today exactly one exception exists,
the bundle's absence from the second channel
([D4](artifacts/decision-log.md#d4-the-bundle-exception-lives-in-one-durable-place)).

The four surfaces are the first channel's per-plugin version records and storefront listing, and the second channel's
per-plugin version records and storefront listing
([D3](artifacts/decision-log.md#d3-the-four-surfaces-and-what-current-means)). When a plugin is missing from a surface
it belongs on, the release stops and says exactly what is absent, instead of finishing quietly.

The release also carries the previous phase's hand-off. It produces a per-plugin release marker, the released-version
record the install channel resolves against, for every plugin it releases; per-plugin markers are new behavior, since
today only a suite-level marker exists. And it keeps companion version statements, the declared version ranges plugins
state for each other, current: when a companion's major version bumps, every edge to that companion moves in the same
release ([D5](artifacts/decision-log.md#d5-markers-statements-and-the-publish-boundary)).

Publishing is verified, not assumed: after the release publishes, the process reads every surface, marker, and the
release record back from the shared repository and fails loudly, naming anything that did not land
([D5](artifacts/decision-log.md#d5-markers-statements-and-the-publish-boundary)).

## Actors and Triggers

- **Actors** — The maintainer cutting a release; every user of both channels, who receives what the release
  publishes.
- **Triggers** — The maintainer runs the release process, or runs its rehearsal mode, a new capability that reports
  everything without publishing anything ([D6](artifacts/decision-log.md#d6-rehearsal-mode)).
- **Preconditions** — Phases 1 and 3 are complete, so every plugin is present on the surfaces it belongs on and the
  version records are aligned; the first real run performs ordinary version sync, not gap repair. The bundle
  exception's durable record exists where both this process and the later automated check read it
  ([D4](artifacts/decision-log.md#d4-the-bundle-exception-lives-in-one-durable-place)).

## Primary Flow

1. The maintainer starts a release. The process discovers the set of plugins from the repository itself
   ([D2](artifacts/decision-log.md#d2-the-repository-is-the-source-of-truth)).
2. For each discovered plugin, the process checks its presence on every surface it belongs on, honoring the bundle
   exception ([D3](artifacts/decision-log.md#d3-the-four-surfaces-and-what-current-means))
   ([D4](artifacts/decision-log.md#d4-the-bundle-exception-lives-in-one-durable-place)). If anything is missing, the
   release stops before publishing and reports each absent plugin and surface.
3. The process proposes a version bump per changed plugin and the maintainer confirms the plan, as today. The one
   confirmed target per plugin is what every surface receives; where the two channels' records disagree beforehand,
   the first channel's record is the baseline, because the second channel's records are the ones that froze
   ([D3](artifacts/decision-log.md#d3-the-four-surfaces-and-what-current-means)).
4. When the release moves any version statement or includes a major bump, the maintainer sees and acknowledges the
   rehearsal view of what will change before anything publishes; the preview is opt-out, not opt-in, for exactly the
   releases that can refuse installs ([D6](artifacts/decision-log.md#d6-rehearsal-mode)).
5. The process updates the version records and listings on all four surfaces so both channels state the same released
   version for every plugin.
6. The process publishes in the safe order: per-plugin markers reach the shared repository before, or atomically
   with, any change that moves version statements, because a statement served without its marker disables the
   depending plugin ([D5](artifacts/decision-log.md#d5-markers-statements-and-the-publish-boundary)).
7. After publishing, the process reconciles: it reads all four surfaces, every marker, and the release record back
   from the shared repository and fails loudly with a named report if anything did not land
   ([D5](artifacts/decision-log.md#d5-markers-statements-and-the-publish-boundary)).

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
  the acknowledged preview from the primary flow shows the moves, and the marker-first publish order holds
  ([D5](artifacts/decision-log.md#d5-markers-statements-and-the-publish-boundary)).
- **Exit:** The release ships with statements and markers agreeing everywhere.

### An urgent fix must ship while an unrelated gap is open

- **Entry condition:** A severe problem needs a release now, and the presence check is stopping on a gap unrelated to
  the fix.
- **Sequence:** The maintainer uses a deliberate, single-use override: the release ships, and every deferred gap is
  named in the release's own notes so the bypass is loud and auditable, never silent
  ([D7](artifacts/decision-log.md#d7-a-loud-recorded-hotfix-override)).
- **Exit:** Users get the urgent fix; the named gaps remain visibly open until fixed, and the next ordinary release
  stops on them again.

## Edge Cases and Failure Modes

| Condition                                                                | Required Behavior                                                                                                        |
| -------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| The storefront listing names a plugin that no longer exists in the repository | The check reports the orphan entry and the release stops; kept as a cheap symmetric rail beside the missing-plugin check, without a claimed incident behind it. |
| A plugin is deliberately absent from a surface                              | Only the durable exception record silences the report; an undocumented absence always stops the release.                  |
| The exception record exists but cannot be read                              | The release fails closed and names the record itself as the fault, distinctly from a missing-plugin report, so the maintainer fixes the record instead of chasing a phantom gap. |
| The release is interrupted partway                                          | Re-running is safe because the checks read the shared repository's real state, including markers and the release record, not only the local files; a half-landed publish is detected, reported, and completed. |
| Rehearsal mode                                                              | Reports everything, including the discovered plugin list, the per-surface results, the version plan, and the bundle exception as a known allowance; writes no surface, publishes nothing, pushes nothing, and produces no markers ([D6](artifacts/decision-log.md#d6-rehearsal-mode)). |

## Coordinations

| Coordinating System            | Direction | Interaction                                                          | Ordering / Consistency Requirement                                            |
| ------------------------------ | --------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Both install channels          | outbound  | Receive updated version records and listings on every release        | The presence check passes before anything publishes; both channels end stating the same versions; the post-publish reconciliation confirms it. |
| The automated completeness check (Phase 7) | outbound | Enforces the same rule this process follows                 | Both read the same durable exception record, so they can never disagree about the bundle ([D4](artifacts/decision-log.md#d4-the-bundle-exception-lives-in-one-durable-place)). |
| Version statements and markers (Phase 5)   | inbound  | The baseline this process maintains going forward           | Markers reach the shared repository before or atomically with statement-moving changes ([D5](artifacts/decision-log.md#d5-markers-statements-and-the-publish-boundary)). |

## Out of Scope

- Building the automated completeness check itself. That is Phase 7; this phase gives it a tree that passes and a
  shared exception record.
- Correcting today's stale surfaces. Phases 1 and 3 do that; this phase keeps them correct.
- A general multi-exception record format. Exactly one exception exists; the record holds that single named
  allowance, and the format question reopens if a concrete second exception ever arises
  ([D4](artifacts/decision-log.md#d4-the-bundle-exception-lives-in-one-durable-place)).
- Changing what a release publishes to either channel beyond versions, listings, markers, and statements.

## Open Items

- **OI-1:** Decide where the durable bundle-exception record lives so both the release process and the Phase 7 check
  read the same one. The behavioral requirements are settled here: one record, read by both, fails closed and names
  itself when unreadable, and holds a single named allowance.
  - **Resolves when:** Implementation planning picks the location.
  - **Blocks implementation:** No — it is a placement choice inside a settled behavior.

## Summary

- **Outcome delivered:** Releases start from the repository, cover all four surfaces, stop loudly on gaps, publish in
  the marker-first safe order, verify afterward that everything landed, honor one durable exception, and carry a loud
  override for urgent fixes.
- **Primary actors:** The maintainer cutting releases; users of both channels.
- **Decisions settled by evidence:** 6 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, devops-engineer, gap-analyzer — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the real publish boundary was relocated from the four files, which land together,
  to the markers and release record, which travel separately, driving the marker-first order, the
  shared-state re-run check, and the post-publish reconciliation; rehearsal mode was named as new behavior with a
  defined boundary and an opt-out preview on risky releases; a loud, recorded hotfix override was added; discovery
  and surface membership got behavioral definitions. — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
