# Feature Specification: Planning Scope Corrections

Han's planning skills learn to respect the boundary of the work they descend from, to keep the visual material an
operator supplies, and to talk to that operator in plain language one question at a time.

## Outcome

A planning run stays inside the work it was asked to do, and the operator can see that it did.

Four things become true that are not true today. A planning skill reads the work item the work descends from before it
does anything else, and records that item's stated scope and stated exclusions as the outer boundary of the run. Every
work unit and work item the run produces names what it descends from, and anything that cannot name one moves to a
visible cut list instead of into the plan. Visual material the operator supplies survives the session as files beside
the plan, and every reviewer the run dispatches receives it. When the run does need the operator, it asks one question
at a time, in language a person who will never open the code can act on.

The measure of success is the run that does not happen: a three-sentence ticket no longer produces a plan spanning
subsystems the ticket never mentioned, and the operator no longer has to correct the same class of error four separate
times.

## Actors and Triggers

The change set spans three plugins, addressed together because their fixes interlock
([D1](artifacts/decision-log.md#d1-scope-of-the-change-set)).

- **Actors**
  - **The operator.** The engineer who invokes a planning skill, supplies the work item and any design material, and
    approves or redirects what comes back. Every commitment in this specification is measured by what this person
    experiences.
  - **The planning skills.** `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, and `plan-work-items`.
    These are the skills that gain the scope boundary, the visual-material handling, and the escalation register.
  - **The review team.** The specialist agents a planning skill dispatches to review its draft. These gain the
    unverified-finding rule and receive the operator's visual material.
  - **The feedback skill.** `han-feedback`, which gains two corrections to how it handles a same-day file and a blocked
    publish.
  - **The shared communication standard.** The `han-communication` plugin, which gains one new standard describing how
    to explain technical work to a reader who will not implement it.

- **Triggers**
  - An operator invokes any of the four planning skills.
  - An operator invokes `han-feedback` in a session that already produced a feedback file today, or in an environment
    that refuses to let the run publish.

- **Preconditions**
  - None beyond what each skill requires today. Every commitment here degrades to a recorded statement when its input
    is absent, rather than blocking the run.

## Primary Flow

The flow below describes a planning run under this specification. Steps 1 through 3 are new. The rest describe where
existing behavior changes.

1. The skill identifies the work item this work descends from: a ticket, an issue, a pull request, or a written
   request from the operator. It reads that item and records its stated scope and its stated exclusions word for word
   in the run's context artifact
   ([D2](artifacts/decision-log.md#d2-the-work-item-is-read-and-recorded-as-the-scope-boundary)).
2. When no work item exists, the skill records that fact explicitly, and records that the operator's request is the
   only boundary the run has. That statement is written down rather than assumed, because a run with no external
   boundary is a materially different situation from a run with one
   ([D2](artifacts/decision-log.md#d2-the-work-item-is-read-and-recorded-as-the-scope-boundary)).
3. In the same turn that confirms the work item, the skill asks the operator one question about direction of travel:
   whether anything this work touches is being deprecated, replaced, or migrated away from. The answer, including "not
   known", is recorded in the context artifact so later skills inherit it instead of asking again
   ([D5](artifacts/decision-log.md#d5-direction-of-travel-is-asked-once-alongside-the-work-item-confirmation)).
4. The skill persists every piece of visual material the operator supplied into a `ui-designs/` folder beside the plan,
   under a descriptive name for the state each one depicts. This happens when the material arrives, not when the
   document is written ([D15](artifacts/decision-log.md#d15-provided-visual-material-is-persisted-when-it-arrives),
   [T1](artifacts/feature-technical-notes.md#t1-supplied-visual-material-is-reachable-on-disk)).
5. The skill discovers its context and drafts its artifact as it does today, with one addition: every work unit and
   every work item carries a justification naming the work-item language or the design artifact it descends from
   ([D6](artifacts/decision-log.md#d6-every-work-unit-names-what-it-descends-from)).
6. The skill dispatches its review team. Every dispatched reviewer receives the paths to the persisted visual material
   along with its domain brief, and is told to read it
   ([D18](artifacts/decision-log.md#d18-provided-visual-material-reaches-every-dispatched-reviewer)). Each brief also
   carries the size of the work item as a stated proportionality signal
   ([D28](artifacts/decision-log.md#d28-output-volume-scales-to-the-size-of-the-work-item)).
7. The skill resolves the returned findings. A finding that turns on visual material is checked against that material
   before it is filed ([D20](artifacts/decision-log.md#d20-design-dependent-findings-are-checked-against-the-designs-before-filing)).
   A finding whose author recorded that it could not inspect an input is recorded as unverified and cannot carry
   blocking severity ([D19](artifacts/decision-log.md#d19-an-uninspected-input-strips-blocking-severity-from-the-findings-that-rest-on-it)).
8. The skill sweeps every commitment the artifact carries against the work item, including commitments inherited from
   an upstream document. A commitment no work item supports is cut or deferred, with the citation recorded
   ([D8](artifacts/decision-log.md#d8-the-yagni-sweep-gains-a-scope-gate-covering-inherited-commitments)).
9. When a question survives all of that, the skill escalates it to the operator: one question, leading with the
   consequence a person who will not read the code would describe, with technical references placed below the question
   or left out ([D12](artifacts/decision-log.md#d12-escalations-are-one-question-at-a-time-led-by-plain-language)).
10. Before declaring the artifact finished, the skill confirms that any visual material the session received exists on
    disk beside the plan ([D17](artifacts/decision-log.md#d17-a-completeness-gate-confirms-visual-material-reached-disk)).

## Alternate Flows and States

### The work item cannot be found

- **Entry condition:** The operator named a work item the skill cannot reach, or named none and the conversation does
  not identify one.
- **Sequence:** The skill asks the operator once for the work item or for its scope in their own words. If the
  operator declines or has none, the skill records that the operator's request is the only boundary and continues.
- **Exit:** The run continues with a recorded boundary, never with an assumed one.

### A proposed work unit cannot be justified

- **Entry condition:** A work unit or work item cannot name the work-item language or design artifact it descends
  from.
- **Sequence:** The skill records the unit in a visible cut list with the reason it could not be justified. It does
  not search outward to a linked item, a parent epic, or a closed item to find justification, because those are not
  scope evidence for the item in hand
  ([D3](artifacts/decision-log.md#d3-the-work-item-read-does-not-traverse-outward)).
- **Exit:** The unit is absent from the plan and present in the cut list. The operator can see what was considered and
  dropped ([D6](artifacts/decision-log.md#d6-every-work-unit-names-what-it-descends-from)).

### An upstream document commits to something the work item excludes

- **Entry condition:** A feature specification, technical note, or other upstream artifact commits to work the work
  item excludes, by statement or by silence.
- **Sequence:** The skill cuts the commitment and records the work-item citation that supports the cut. It does not
  ask the operator to choose between options, because the work item already settled the question
  ([D9](artifacts/decision-log.md#d9-an-upstream-specification-is-an-artifact-not-a-scope-authority),
  [D11](artifacts/decision-log.md#d11-a-question-the-work-item-already-answers-is-never-escalated)).
- **Exit:** The plan reflects the work item's boundary, and the record shows which upstream commitment was cut and
  why.

### A reviewer disagrees with a committed mechanic

- **Entry condition:** A specialist reviewing an implementation plan disagrees with a mechanic the upstream
  specification committed to.
- **Sequence:** The specialist chooses one of three verdicts: confirm the mechanic, contradict it by naming an
  alternative mechanic, or declare it outside the scope of this work item. The third verdict resolves by citing the
  work item, without an escalation to the operator
  ([D10](artifacts/decision-log.md#d10-the-mechanic-contradiction-protocol-gains-an-out-of-scope-verdict)).
- **Exit:** The disagreement resolves inside the run whenever the work item can settle it.

### Visual material is missing and only the operator can supply it

- **Entry condition:** The plan describes visual work, and no visual material exists beside it.
- **Sequence:** The skill stops once. It names what is missing, names the cost of continuing without it, and offers
  to continue. It does not treat the absence as a template block to omit
  ([D25](artifacts/decision-log.md#d25-a-single-stop-is-reserved-for-an-input-only-the-operator-can-supply),
  [D27](artifacts/decision-log.md#d27-plan-work-items-separates-no-visual-surface-from-visual-work-with-no-designs)).
- **Exit:** The operator supplies the material, or directs the run to continue with the cost recorded in the
  artifact.

## Edge Cases and Failure Modes

| Condition                                                                             | Required Behavior                                                                                                                                                                                                          |
| ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The work item exists but says nothing about a subsystem the upstream document commits to | Silence is exclusion. The commitment is cut or deferred with the citation recorded, not escalated as a choice.                                                                                                              |
| A linked or closed item appears to justify a proposed unit                            | The linked item is not scope evidence. The unit is reported as unjustified ([D4](artifacts/decision-log.md#trivial-decisions)). Its description is not evidence about the current item's platform, status, or intent.       |
| A reviewer records that it could not inspect an input, then raises a finding that rests on that input | The finding is recorded as unverified and cannot carry blocking severity ([D19](artifacts/decision-log.md#d19-an-uninspected-input-strips-blocking-severity-from-the-findings-that-rest-on-it)). The disclosure travels attached to the finding, not in a separate assumptions list below it. |
| A finding rests on visual material the skill holds                                    | The skill checks the finding against that material before filing it. A finding the material answers directly is closed with the citation rather than promoted to an open item.                                              |
| Decisions rest on material no reviewer received                                       | The findings record names that evidence class as unaudited ([D16](artifacts/decision-log.md#trivial-decisions)), so the coverage gap is visible rather than silent.                                                          |
| The same reviewer finding appears in two reviewers' output                             | Each recorded finding carries the originating reviewer's own identifier ([D21](artifacts/decision-log.md#trivial-decisions)), so reconciling the two lists is mechanical and a dropped finding surfaces immediately.          |
| A decision is written before the review round returns                                  | Classification into full or trivial happens once, after the round ([D22](artifacts/decision-log.md#d22-decisions-are-classified-once-after-the-review-round)), because two of its promotion signals cannot exist at draft time. |
| An expected artifact is missing and nobody can produce it now                          | The skill records it in the report, drafts around it, and flags what it blocks. It does not stop ([D23](artifacts/decision-log.md#d23-the-two-missing-artifact-rules-are-reconciled-and-split-by-who-can-supply-the-artifact)). |
| An expected artifact is missing and the operator could supply it now                   | The skill stops once, names the cost of proceeding, and offers to proceed ([D25](artifacts/decision-log.md#d25-a-single-stop-is-reserved-for-an-input-only-the-operator-can-supply)). It does not stop a second time for the same input. |
| The session supplied visual material that never reached disk                           | The completeness gate fails loudly while the material is still recoverable, rather than allowing a silent total loss.                                                                                                        |
| An escalation would carry four questions at once                                       | The run asks one, waits, then asks the next. A batch is not the default.                                                                                                                                                     |
| An explanation would name a concept the operator has never been given                  | The run gives a concrete worked example instead: a named thing, a real starting value, what the person enters, and the specific wrong result they would see. Invented shorthand for an unintroduced concept is not permitted. |
| `han-feedback` finds a file for today and the session continued past it                | The file is updated in place and the update is stated ([D26](artifacts/decision-log.md#trivial-decisions)). The run skips only when nothing new has happened.                                                                |
| The environment refuses to let `han-feedback` publish                                  | The run says plainly that the environment refused rather than that the run declined, does not retry the identical command, and hands over a copy-pasteable command ([D29](artifacts/decision-log.md#trivial-decisions)).     |

## User Interactions

- **Affordances.** The operator confirms the work item and answers the direction-of-travel question in one turn at the
  start of a run. They see a cut list naming what was considered and dropped, and a visible record of any evidence
  class no reviewer could audit.
- **Feedback.** Escalations arrive one at a time. Each leads with the consequence in plain language, as a person who
  will not read the code would describe it. Technical references sit below the question or are left out entirely
  ([D12](artifacts/decision-log.md#d12-escalations-are-one-question-at-a-time-led-by-plain-language)). Where a
  question needs an explanation, the run gives a concrete worked example rather than describing a mechanism
  ([D13](artifacts/decision-log.md#d13-a-shared-standard-covers-explaining-technical-work-to-a-non-implementer)).
- **Error states.** A missing input the operator can supply produces exactly one question naming the cost of
  proceeding without it. A missing input nobody can supply produces a recorded gap and no question at all. A run that
  cannot justify a proposed unit reports it as unjustified rather than asking the operator to pick an option.

## Coordinations

The four planning skills and the two supporting plugins pass artifacts and conventions between each other. The
contracts below are what keeps this change set consistent rather than four separate fixes that disagree.

| Coordinating System                                | Direction | Interaction                                                                                                                          | Ordering / Consistency Requirement                                                                                                                     |
| -------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Visual-material producer to visual-material consumer | outbound  | A planning skill writes supplied visual material beside the plan; `plan-work-items` inventories it and maps it to work items.         | Persistence happens when the material arrives. The producer also emits the visual reference table and the inline placements the consumer already reads ([D14](artifacts/decision-log.md#trivial-decisions)). |
| Visual material to review team                     | outbound  | Persisted material is passed by path in every reviewer's brief.                                                                       | Persistence precedes dispatch, so briefs carry real paths rather than a promise.                                                                       |
| Work item to every downstream skill                | inbound   | The recorded scope, exclusions, and direction-of-travel answer travel in the context artifact.                                        | Recorded once at the start of the earliest skill in the chain. Later skills read the record rather than re-asking the operator.                         |
| Folder convention to every planning skill          | inbound   | One `han-planning` reference defines where visual material lives and how it is cited.                                                 | Producer and consumer read the same reference, so the convention cannot drift between them ([D24](artifacts/decision-log.md#d24-the-visual-material-convention-lives-in-one-han-planning-reference)). |
| Explanation standard to every escalating skill     | inbound   | `han-communication` owns the standard for explaining technical work to a reader who will not implement it.                            | Sourced at escalation time, the same way the readability standard is sourced at drafting time. One canonical copy, no vendored duplicates.              |
| Missing-artifact rule to its own skill's steps     | inbound   | One rule states the split by who can supply the artifact; any other mention references it.                                            | Stated in one place. The contradiction where a step and its own linked reference give opposite instructions is removed.                                 |
| Proportionality signal to team sizing              | outbound  | The work item's size is passed to reviewer briefs as a stated signal about output length.                                             | Separate from the existing size bands. It governs how much a reviewer writes, never how many reviewers are chosen.                                     |
| Justification field to work-item format            | inbound   | The justification is a structured field beside the references, not summary prose ([D30](artifacts/decision-log.md#trivial-decisions)). | The existing rule that a work item's summary carries no identifier references stays intact.                                                            |
| Justification record to sequencing and packaging   | inbound   | Sequencing, phasing, and pull-request splits read the justification record before they run.                                           | A unit whose justification is unrecorded is not packaged ([D7](artifacts/decision-log.md#trivial-decisions)). Existence is established first.           |

## Out of Scope

- Changing which specialists a planning skill selects, or the existing small, medium, and large team caps. The
  proportionality signal governs output length only.
- Re-opening behavioral decisions an upstream specification settled that the work item does cover. The license this
  specification grants is narrow and scoped to what the work item excludes
  ([D9](artifacts/decision-log.md#d9-an-upstream-specification-is-an-artifact-not-a-scope-authority)).
- Changing how any specialist agent performs its own domain analysis. The changes to review behavior are changes to
  how findings are labeled and briefed, not to how they are found.
- Any change to the readability standard or the writing-voice profile. The new explanation standard sits beside them.
- Changing where planning artifacts are written or what the existing artifacts contain, beyond the fields this
  specification names.

## Deferred (YAGNI)

### Extending the scope boundary to `iterative-plan-review`

- **Why deferred:** Evidence test. No reported run names this skill. Including it rests on symmetry with the four
  skills that were named, which the YAGNI rule flags as a candidate by default.
- **Reopen when:** A reported run shows `iterative-plan-review` widening a plan past its work item.
- **Source:** Symmetry with the four named planning skills.

### Making the non-implementer explanation standard a full skill

- **Why deferred:** Simpler-version test. A reference the escalating skills source satisfies the same evidence as a
  skill with its own dispatch and its own agent. The evidence is that escalations were written in jargon, not that a
  separate pass was missing.
- **Reopen when:** Escalations still read as jargon after the shared reference is in place, or a caller needs a
  rewrite pass rather than a drafting standard.
- **Source:** The two rejected escalations described in the reported runs.

### Automated validation that a specification carries its visual reference table

- **Why deferred:** Evidence test. No incident shows the completeness gate being skipped once it exists. The gate
  itself is the cheaper first move.
- **Reopen when:** A run passes the completeness gate and still ships a specification with no visual reference table.
- **Source:** Considered while specifying the completeness gate.

### A machine-readable scope-boundary record shared across skills

- **Why deferred:** Simpler-version test. A recorded statement in the existing context artifact satisfies the same
  evidence as a structured format the skills parse.
- **Reopen when:** A downstream skill demonstrably fails to find the recorded boundary in prose.
- **Source:** Considered while specifying the work-item record.

## Open Items

<!-- Populated during review-team resolution and project-manager synthesis. -->

## Summary

- **Outcome delivered:** Planning runs respect the boundary of the work they descend from, keep the visual material
  the operator supplies, and escalate one plain-language question at a time.
- **Primary actors:** The operator who invokes a planning skill, the four planning skills, and the review teams they
  dispatch.
- **Decisions settled by evidence:** N — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** N — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** pending — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** pending — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** pending
- **Technical notes:** 1 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
