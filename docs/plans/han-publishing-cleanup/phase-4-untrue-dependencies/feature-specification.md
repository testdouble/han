# Feature Specification: Remove the Untrue Dependency Declarations

The Reporting, Feedback, and Linear plugins stop declaring a dependency on the Core plugin none of them uses, and
every documentation surface that repeats those claims is corrected in the same change, so the dependency record can be
trusted again.

## Outcome

Installing the Reporting, Feedback, or Linear plugin no longer pulls in the Core plugin, and all three keep working
exactly as before. The source analysis named two decorative declarations; review of this phase found a third, the
Linear plugin's, by the same evidence test, and the team chose to remove it in the same pass
([D2](artifacts/decision-log.md#d2-what-is-removed-and-what-stays)). Every surface that states a removed dependency
changes together with the declaration: front-door pages, the repository map, the contributor guide, the concepts and
versioning docs, the dependency how-to guide, the plugin index, and the marketplace listing descriptions
([D3](artifacts/decision-log.md#d3-declarations-and-documentation-change-together)). The wider payoff is trust: with
the decorative claims gone, the remaining declarations answer "what breaks if I change this?" honestly.

## Actors and Triggers

- **Actors** — People installing the Reporting, Feedback, or Linear plugin; maintainers who rely on the dependency
  record when changing plugins.
- **Triggers** — The maintainer removes the three declarations and corrects the documentation in one change.
- **Preconditions** — Re-confirm none of the three plugins reaches the Core plugin through any path the analysis did
  not cover: no skill content, no dispatched agent, no shared reference sourced from it
  ([D2](artifacts/decision-log.md#d2-what-is-removed-and-what-stays)). The Feedback plugin's mentions of the Core
  plugin's name are naming-convention text inside captured feedback, not invocations, and stay as they are.

## Primary Flow

1. The maintainer re-verifies the evidence for each of the three plugins: the Reporting plugin's skills source their
   writing standard from the Communication plugin and reference the Core plugin nowhere; the Feedback plugin invokes
   no other plugin at all; the Linear plugin's skill dispatches no agents and references no other plugin, as its own
   long-form documentation states ([D2](artifacts/decision-log.md#d2-what-is-removed-and-what-stays)).
2. The three declarations are deleted. The Reporting plugin keeps its Communication dependency; the Feedback and
   Linear plugins are left depending on nothing, a supported state with two shipped precedents among the existing
   plugins ([D2](artifacts/decision-log.md#d2-what-is-removed-and-what-stays)).
3. Every documentation surface that repeats a removed claim is corrected in the same change. This includes the second
   untrue claim on the Reporting and Feedback front-door pages, which say their skills dispatch the Core plugin's
   shared reviewers when they do not, and the grouped sentences in the repository map and guides that must be edited
   so plugins keeping the dependency stay correctly described
   ([D3](artifacts/decision-log.md#d3-declarations-and-documentation-change-together)).
4. The Linear plugin's front-door page is reconciled with what its skill content really does, closing the open item
   handed off from the Phase 1 spec, and now paired with its declaration's removal so no new docs-versus-declaration
   contradiction is created ([D4](artifacts/decision-log.md#d4-linear-page-reconciliation)).
5. Completion is verified by searching the documentation for the Core plugin's name and reviewing every hit: each is
   either a true statement about a plugin that keeps the dependency, or the Feedback plugin's naming-convention
   examples, which are excluded on purpose
   ([D3](artifacts/decision-log.md#d3-declarations-and-documentation-change-together)).
6. On a clean machine, installing the Reporting plugin brings the Communication plugin and not the Core plugin, and a
   Reporting skill runs end to end, including its writing pass. The same check passes for the Feedback and Linear
   plugins, which now install alone.

## Alternate Flows and States

### A user already has the plugins installed

- **Entry condition:** Someone installed the Reporting, Feedback, or Linear plugin before this change and has the
  Core plugin alongside it.
- **Sequence:** Nothing changes at runtime for them; the Core plugin simply stops being required and can be removed
  if it is not otherwise wanted.
- **Exit:** Their setup keeps working with no action needed.

## Edge Cases and Failure Modes

| Condition                                                                    | Required Behavior                                                                                                       |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| The pre-start check finds a real path from any of the three to the Core plugin | The removal stops for that plugin and the finding goes back to the team; a true dependency is never deleted.             |
| A documentation surface still claims a removed dependency after the change     | The change is not complete; the search-and-review step in the primary flow is the acceptance check.                      |
| A grouped sentence covers both removed and kept dependencies                   | The sentence is edited so the plugins that keep the dependency stay correctly described; a half-edited grouping is a failure. |
| The second channel's manifests                                                | Nothing to change there: they declare no dependencies at all, on any plugin.                                             |

## Coordinations

| Coordinating System       | Direction | Interaction                                                        | Ordering / Consistency Requirement                                            |
| ------------------------- | --------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| First install channel     | outbound  | Reads each plugin's declarations to resolve installs               | After the change, installing any of the three no longer pulls the Core plugin. |
| Documentation surfaces    | outbound  | Eight documentation files describe the dependencies today          | They change in the same commit as the declarations, never separately.          |
| The phased-build outline  | outbound  | Records this phase's scope                                         | The outline gains a note that a third removal was added on review evidence.    |

## Out of Scope

- The versions each plugin states for its remaining dependencies. That is the next phase
  ([Phase 5 of the outline](../build-phase-outline.md#phase-5)), which adds version statements on top of the truthful
  declarations this phase leaves behind.
- Every other plugin's declarations. The source analysis verified the rest of the graph as true, and this phase's
  review found no further decorative claim beyond the Linear plugin's.
- Changing any skill's behavior in the three plugins.

## Open Items

- **OI-1:** None remain. The Phase 1 spec's open item about the Linear plugin's front-door page resolves inside this
  phase's step 4.
  - **Resolves when:** Already scheduled within this phase.
  - **Blocks implementation:** No.

## Summary

- **Outcome delivered:** The three decorative dependency claims are gone, the documentation agrees on every surface,
  and all three plugins install and run without the Core plugin.
- **Primary actors:** People installing the three plugins; maintainers relying on the dependency record.
- **Decisions settled by evidence:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 1 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, content-auditor — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the Linear plugin's declaration joined the removal by user decision after the same
  evidence test flagged it; the documentation surface list grew from seven claimed surfaces to the audited twenty-one
  across eight files; the completion check became a specified search-and-review step. — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0
