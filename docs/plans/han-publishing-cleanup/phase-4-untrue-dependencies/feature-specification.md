# Feature Specification: Remove the Two Untrue Dependency Declarations

The Reporting and Feedback plugins stop declaring a dependency on the Core plugin they never use, and every
documentation surface that repeats those claims is corrected in the same change, so the dependency record can be
trusted again.

## Outcome

Installing the Reporting plugin or the Feedback plugin no longer pulls in the Core plugin, and both plugins keep
working exactly as before. Every surface that states the dependency changes together: the declaration itself and the
documentation that repeats it, so no page still claims a dependency the system does not have
([D3](artifacts/decision-log.md#d3-declarations-and-documentation-change-together)). The wider payoff is trust: with
the two decorative claims gone, the remaining declarations answer "what breaks if I change this?" honestly.

## Actors and Triggers

- **Actors** — People installing the Reporting or Feedback plugin; maintainers who rely on the dependency record when
  changing plugins.
- **Triggers** — The maintainer removes the two declarations and corrects the documentation in one change.
- **Preconditions** — Re-confirm neither plugin reaches the Core plugin through any path the analysis did not cover:
  no skill content, no dispatched agent, no shared reference sourced from it
  ([D2](artifacts/decision-log.md#d2-what-is-removed-and-what-stays)). The Feedback plugin's mentions of the Core
  plugin's name are naming-convention text inside captured feedback, not invocations, and stay as they are.

## Primary Flow

1. The maintainer re-verifies the evidence: the Reporting plugin's skills source their writing standard from the
   Communication plugin and reference the Core plugin nowhere; the Feedback plugin invokes no other plugin at all
   ([D2](artifacts/decision-log.md#d2-what-is-removed-and-what-stays)).
2. The two declarations are deleted. The Reporting plugin keeps its Communication dependency; the Feedback plugin is
   left depending on nothing.
3. The documentation surfaces that repeat the claims are corrected in the same change: each plugin's front-door page,
   the repository map, and the plugin index
   ([D3](artifacts/decision-log.md#d3-declarations-and-documentation-change-together)).
4. The Linear plugin's front-door page, which overstates its skills' reliance on other plugins, is reconciled with
   what its skill content really does, closing the open item handed off from the Phase 1 spec
   ([D4](artifacts/decision-log.md#d4-linear-page-reconciliation)).
5. On a clean machine, installing the Reporting plugin brings the Communication plugin and not the Core plugin, and a
   Reporting skill runs end to end, including its writing pass. The same check passes for the Feedback plugin, which
   now installs alone.

## Alternate Flows and States

### A user already has both plugins installed

- **Entry condition:** Someone installed the Reporting or Feedback plugin before this change and has the Core plugin
  alongside it.
- **Sequence:** Nothing changes at runtime for them; the Core plugin simply stops being required and can be removed if
  it is not otherwise wanted.
- **Exit:** Their setup keeps working with no action needed.

## Edge Cases and Failure Modes

| Condition                                                                  | Required Behavior                                                                                                       |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| The pre-start check finds a real path from either plugin to the Core plugin | The removal stops for that plugin and the finding goes back to the team; a true dependency is never deleted.             |
| A documentation surface still claims the removed dependency after the change | The change is not complete; every claiming surface is corrected in the same change, verified by searching for the claim. |
| The second channel's manifests                                              | Nothing to change there: they declare no dependencies at all, on any plugin.                                             |

## Coordinations

| Coordinating System       | Direction | Interaction                                                        | Ordering / Consistency Requirement                                            |
| ------------------------- | --------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| First install channel     | outbound  | Reads each plugin's declarations to resolve installs               | After the change, installing Reporting or Feedback no longer pulls the Core plugin. |
| Documentation surfaces    | outbound  | Front-door pages, repository map, and plugin index describe dependencies | They change in the same commit as the declarations, never separately.          |

## Out of Scope

- The versions each plugin states for its remaining dependencies. That is the next phase
  ([Phase 5 of the outline](../build-phase-outline.md#phase-5)), which adds version statements on top of the truthful
  declarations this phase leaves behind.
- Every other plugin's declarations. The source analysis verified the rest of the graph as true; only these two claims
  are decorative.
- Changing any skill's behavior in either plugin.

## Open Items

- **OI-1:** None remain. The Phase 1 spec's open item about the Linear plugin's front-door page resolves inside this
  phase's step 4.
  - **Resolves when:** Already scheduled within this phase.
  - **Blocks implementation:** No.

## Summary

- **Outcome delivered:** The two decorative dependency claims are gone, the documentation agrees everywhere, and both
  plugins install and run without the Core plugin.
- **Primary actors:** People installing the two plugins; maintainers relying on the dependency record.
- **Decisions settled by evidence:** 3 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 0 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0
