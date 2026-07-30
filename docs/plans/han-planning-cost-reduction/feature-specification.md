# Feature Specification: Cheaper, Faster Planning Runs

A planning run costs less waiting time and less budget, because it consults fewer reviewers, executes three routine
checks instead of performing them by hand, and stops proofreading text that an editor has already rewritten.

## Outcome

An operator who runs any of the five planning skills gets the same plan or specification for less. Three things change
what a run does.

A run that convenes a review team convenes a smaller one. At the largest size, a run that used to send out six to eight
reviewers sends out four to five, and the medium size drops from four or five reviewers to three
([D1](artifacts/decision-log.md#d1-reduce-the-review-team-size-and-leave-the-repeat-ceiling-alone)). The first wave still
goes out to every reviewer at once, so nothing gets slower. How many times a review can repeat does not change, because a
repeat only happens when the previous pass found real problems.

Two checks a run currently walks through in prose become checks it runs. The run confirms that the design images the
operator handed over are on disk, and confirms that the cross-references inside a reviewed plan point at something real
([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)). A check that runs either passes or
fails; a check written as prose can be reported as done without being done.

A run stops proofreading its own output twice. Three of the five skills currently hand the finished draft to an editor
and then walk a six-point checklist over the text the editor produced. The checklist goes away in those three, and the
editor's own fact-preservation report becomes the guard that no fact was lost
([D6](artifacts/decision-log.md#d6-remove-the-six-point-check-where-an-editor-already-runs),
[D7](artifacts/decision-log.md#d7-name-the-editors-fact-preservation-report-as-the-fidelity-guard)). The two skills that
have no editor keep their checklist.

## Actors and Triggers

- **Actors** — the operator who runs a planning skill, and the planning skills themselves, which are the surface that
  changes. No end user of any other product is affected.
- **Triggers** — running any of the five planning skills. The reviewer-count change applies only to the two skills that
  convene a review team. The check changes apply to the skills that carry the affected checks. The proofreading change
  applies to the three skills that dispatch an editor.
- **Preconditions** — none beyond having the planning skills installed. No operator configuration is required, and no
  existing plan folder needs migrating.

## Primary Flow

This is the flow of a single planning run under the changed behavior.

1. The run establishes its scope boundary and interviews the operator, unchanged.
2. The run classifies the work as small, medium, or large, unchanged.
3. The run convenes a review team sized to the new, smaller caps, and dispatches every reviewer in one parallel wave
   ([D1](artifacts/decision-log.md#d1-reduce-the-review-team-size-and-leave-the-repeat-ceiling-alone),
   [D3](artifacts/decision-log.md#d3-preserve-the-single-parallel-first-wave)).
4. The run consolidates what came back, and marks any finding that rests on something no reviewer could look at, so that
   finding never reaches the operator as a blocker. This step stays a prose step
   ([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)).
5. The run decides whether the review repeats, using the existing rule that ends the review as soon as it stops finding
   things. The ceiling on repeats is unchanged.
6. The run writes its plan or specification and hands the draft to the editor.
7. The run reads the editor's report. If the report says a fact was lost, the run restores it before going further
   ([D7](artifacts/decision-log.md#d7-name-the-editors-fact-preservation-report-as-the-fidelity-guard)). The run does not
   walk the six-point checklist over the editor's text.
8. The run executes the check that confirms every design image the boundary record lists is on disk
   ([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)).
9. The run presents its summary, unchanged.

For a run that reviews an existing plan rather than authoring one, step 7 is replaced by executing the check that
confirms the plan's cross-references resolve, and that skill keeps its six-point checklist because it has no editor.

## Alternate Flows and States

### A check cannot run

- **Entry condition:** the operator declines the permission the check needs, or the check itself is missing or fails to
  start.
- **Sequence:** the run reports that the check could not run and names which one. It does not report the check as passed,
  and it does not silently fall back to walking the check by hand
  ([D9](artifacts/decision-log.md#d9-a-check-that-cannot-run-is-reported-not-assumed-passed)).
- **Exit:** the operator decides whether to grant the permission and retry, or to accept the run's output with the gap
  named in the summary.

### A review team is smaller than the work needs

- **Entry condition:** the run reaches its new, smaller reviewer cap while a domain the work touches has no reviewer
  covering it.
- **Sequence:** the run names the uncovered domain in its summary rather than silently omitting it, so the operator can
  re-run at a larger size or name the missing reviewer directly. The existing override that lets the operator specify the
  team is unchanged.
- **Exit:** the operator accepts the coverage or re-runs with an explicit team.

### The operator overrides the size

- **Entry condition:** the operator passes a size, or a project configuration file sets a default size.
- **Sequence:** the new caps apply at whatever size is chosen. Overriding the size still selects a band; it does not
  restore the old reviewer counts.
- **Exit:** unchanged.

## Edge Cases and Failure Modes

| Condition                                                                                  | Required Behavior                                                                                                                                              |
| ------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The boundary record lists design images and none are on disk                                | The executed check fails and names every missing item. The run does not present its output as complete.                                                          |
| The boundary record lists five images and three are on disk                                 | The executed check fails and names the two that are missing, rather than passing because some were found.                                                        |
| The boundary record lists a hosted link rather than a file                                   | The check treats the link as present without trying to fetch it, because a link is not a file the run can keep.                                                  |
| The boundary record lists no images at all                                                   | The check passes without complaint. An empty list is a valid state.                                                                                              |
| A reviewed plan contains a cross-reference pointing at an identifier that does not exist      | The executed check fails and names the reference and where it sits.                                                                                             |
| A cross-reference sits inside a code block or a fenced example                                | The check ignores it, because example text is not a live reference.                                                                                             |
| The editor's report says a fact was lost                                                     | The run restores the fact before presenting, and says in the summary that it did.                                                                               |
| The editor cannot be reached or returns nothing                                               | The run falls back to walking the six-point checklist itself, because with no editor the checklist is the only fidelity guard left.                              |
| A run reaches the reduced cap and the operator disagrees                                      | The operator's named team wins. The cap is a default, not a limit on what the operator can ask for.                                                             |
| An existing plan folder was written under the old behavior                                    | It is read and extended normally. Nothing about the change requires rewriting an existing folder.                                                               |
| A skill file states a repeat count that disagrees with its own ceiling                        | The stated count is corrected to match the ceiling, so the two do not contradict each other ([D8](artifacts/decision-log.md#d8-correct-the-contradictory-repeat-count)). |

## User Interactions

The operator's experience of a planning run changes in four visible ways.

- **Affordances:** unchanged. The operator runs the same skills with the same arguments, and the same size override and
  team override still work.
- **Feedback:** the line that announces the team before dispatch names fewer reviewers. When a check runs, its result
  appears as a pass or a named failure rather than as prose describing what was checked. When a review team leaves a
  domain uncovered, the summary says so.
- **Error states:** a check that cannot run is reported by name, and the run says what was not verified. A permission
  prompt may appear the first time a run executes a check, unless the skill has already declared that permission
  ([D10](artifacts/decision-log.md#d10-declare-the-permission-the-checks-need-up-front)).

## Coordinations

| Coordinating System                | Direction | Interaction                                                                                        | Ordering / Consistency Requirement                                                                                       |
| ---------------------------------- | --------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| The specialist reviewer roster      | outbound  | The run dispatches a smaller set of reviewers, all in one wave.                                     | Every reviewer in the wave starts before any result is read, so the wave stays parallel.                                   |
| The readability editor              | outbound  | The run hands over the finished draft and reads back a rewrite plus a fact-preservation report.      | The run reads the report before presenting. A lost fact is restored before the operator sees the output.                   |
| The boundary record                 | inbound   | The executed check reads the record's list of received design material and compares it to disk.      | The check reads the record rather than what the run remembers, so it still works after the run's context is compacted.     |
| The operator's permission surface   | outbound  | The skill declares the permission its checks need.                                                  | Declared before the run reaches the check, so the operator is not interrupted mid-run.                                    |

## Out of Scope

- **The question cadence.** Questions still reach the operator one at a time. The report found no evidence for batching
  them, and the boundary records this explicitly as a thing not to change.
- **Which model each reviewer runs on.** Every reviewer already declares its own model, and the mechanical ones already
  run on the cheapest one.
- **The three finding-consolidation passes themselves.** Only the middle one was considered for conversion, and it stays
  as it is. Nothing about merging duplicate findings or checking findings against the designs changes.
- **Any skill outside the five planning skills.** The reviewers and the editor are defined elsewhere and are not edited
  by this work.
- **Measuring what the change saves.** See the deferred section.

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it.

### Splitting the three oversized skill files so a run reads less of them

- **Why cut:** the boundary scopes this to "a scoped follow-up that begins with an audit rather than an edit." The
  research also found that the repeated content driving the file sizes runs on every pass, so moving it to another file
  that every pass also reads would not reduce what a run consumes.

### Collapsing the wording that repeats across several skills into one shared place

- **Why cut:** the boundary lists this among the options to "treat as low-payoff or unsupported." Validation found only
  two passages genuinely repeat, so the saving is small and the case for it is about avoiding drift rather than cost.

### Tightening the wording throughout the skills to use fewer words

- **Why cut:** the boundary lists this among the options to "treat as low-payoff or unsupported." The one independent
  measurement of this technique found it saves roughly nine percent, because a run spends most of its budget reading
  files and calling tools rather than on the wording of its instructions.

### Moving the judgment reviewers onto a cheaper model

- **Why cut:** the boundary records this as resting on no evidence for the reviewers involved, and records that the
  mechanical ones already run on the cheapest model.

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### Measuring what a planning run costs, before and after

- **Why deferred:** failed the evidence test. Nothing in the research measured a planning run actually executing, and the
  boundary does not ask for measurement. Building it now would be a second feature carried on the first one's evidence.
- **Reopen when:** someone disputes whether the smaller review teams changed the cost or the quality of a plan, and the
  argument cannot be settled without numbers.
- **Source:** the research report's own closing note that a before-and-after measurement of one real run is what would
  settle the recommendation.

### A check that catches a false-alarm finding after the fact

- **Why deferred:** failed the evidence test. The one paper supporting it could not be fully verified, and no run has
  been caught shipping this mistake. The boundary asked for narrated checks to be converted, not for new checks to be
  added.
- **Reopen when:** a run is caught presenting a finding as a blocker when the finding rested on something no reviewer
  could look at.
- **Source:** considered and set aside during the interview, in the same turn that settled
  [D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated).

## Open Items

- **OI-1:** The reduced reviewer counts for the plan-reviewing skill were derived from the counts agreed for the
  plan-authoring skill, rather than agreed directly.
  - **Resolves when:** the operator confirms the derived counts, or names different ones.
  - **Blocks implementation:** No — the derived counts are stated in the decision record and can be adjusted before or
    during implementation.

## Summary

- **Outcome delivered:** a planning run consults fewer reviewers, runs two of its routine checks instead of describing
  them, and stops proofreading text an editor already rewrote.
- **Primary actors:** the operator running a planning skill.
- **Decisions settled by evidence:** 8 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
