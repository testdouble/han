# Feature Specification: Planning Scope Corrections

Han's planning skills learn to respect the boundary of the work they descend from, to keep the visual material an
operator supplies, and to talk to that operator in plain language one question at a time.

## Outcome

A planning run stays inside the work it was asked to do, and the operator can see that it did.

Four things become true that are not true today.

A planning skill reads the work item the work descends from before it does anything else. It records that item's
stated scope and stated exclusions as the outer boundary of the run.

Every work unit and work item the run produces names what it descends from. Anything that cannot name one moves to a
visible cut list instead of into the plan.

Visual material the operator supplies survives the session as files beside the plan, and every reviewer the run
dispatches receives it.

When the run does need the operator, it asks one question at a time, in language a person who will never open the code
can act on.

The change set spans three plugins, addressed together because their fixes interlock
([D1](artifacts/decision-log.md#d1-scope-of-the-change-set)).

## Actors and Triggers

- **Actors**
  - **The operator.** The engineer who invokes a planning skill, supplies the work item and any design material, and
    approves or redirects what comes back. Every commitment in this specification is measured by what this person
    experiences.
  - **The planning skills.** `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, and `plan-work-items`.
    These are the skills that gain the scope boundary, the visual-material handling, and the escalation register.
  - **The review team.** The specialist agents a planning skill dispatches to review its draft. The rules this
    specification adds to review behavior reach a reviewer only through the brief the dispatching planning skill
    writes, so no skill outside the four changes behavior
    ([D36](artifacts/decision-log.md#d36-each-commitment-names-the-skills-it-applies-to)).
  - **The feedback skill.** `han-feedback`, which gains two corrections to how it handles a same-day file and a blocked
    publish.
  - **The shared communication standard.** The `han-communication` plugin, which gains one standard describing how to
    explain technical work to a reader who will not implement it, plus the inline skill that surfaces it
    ([D13](artifacts/decision-log.md#d13-a-shared-standard-covers-explaining-technical-work-to-a-non-implementer)).

- **Triggers**
  - An operator invokes any of the four planning skills.
  - An operator invokes `han-feedback` in a session that already produced a feedback file today, or in an environment
    that refuses to let the run publish.

- **Preconditions**
  - **An operator is present and answering.** Three commitments here stop and wait: the opening confirmation turn, the
    single stop for a missing operator-suppliable input, and any escalation. A run with no one answering cannot
    complete them.
  - **Supplied visual material is reachable as a file.** When the host has not made a piece of supplied material
    reachable, the run cannot persist it and falls back to the single stop
    ([T1](artifacts/feature-technical-notes.md#t1-supplied-visual-material-is-reachable-on-disk)).

  Every other commitment degrades to a recorded statement when its input is absent, rather than blocking the run.

### Which commitments apply to which skill

The four skills are built differently, so not every commitment lands on every one
([D36](artifacts/decision-log.md#d36-each-commitment-names-the-skills-it-applies-to)).

| Commitment                                    | Applies to                                                                                     |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Read and record the boundary                  | All four                                                                                       |
| Direction-of-travel question                  | All four, asked once by the earliest skill in the chain and inherited afterward                |
| Persist and confirm visual material           | All four                                                                                       |
| Justification field and cut list              | All four                                                                                       |
| Scope gate on the sweep                       | `plan-a-feature`, `plan-implementation`, `plan-a-phased-build` (the three that run a sweep)     |
| Visual material in reviewer briefs            | `plan-a-feature`, `plan-implementation` (the two that dispatch a domain-briefed review team)    |
| Unverified-finding rule and design check      | `plan-a-feature`, `plan-implementation`                                                        |
| Proportionality signal in briefs              | `plan-a-feature`, `plan-implementation`                                                        |
| Escalation register                           | The three with an escalation step, plus `plan-work-items` for its single stop                  |
| Single stop for an operator-suppliable input  | All four                                                                                       |
| Reference table and inline placements         | `plan-a-feature` (the skill that writes the specification the inventory reads)                 |
| Naming unaudited evidence classes             | `plan-a-feature`, `plan-implementation` (the two that keep a findings record)                  |
| Reviewer identifiers on merged findings       | `plan-a-feature`, `plan-implementation`                                                        |
| Classifying decisions once, after the round   | `plan-a-feature` (the skill whose decisions are classified before the round today)             |

Where a skill has no step a commitment attaches to, the commitment does not create one.

## Primary Flow

The flow below describes a planning run under this specification. Steps 1 through 3 are new. The rest describe where
existing behavior changes.

1. The skill identifies the work item this work descends from: a ticket, an issue, a pull request, or a written
   request from the operator. It reads that item and records its stated scope and its stated exclusions word for word,
   in a boundary record beside the plan. Every planning skill uses that same record name
   ([D2](artifacts/decision-log.md#d2-the-work-item-is-read-and-recorded-as-the-scope-boundary),
   [D33](artifacts/decision-log.md#d33-the-boundary-record-has-one-name-and-one-home)).
2. When no work item exists, the skill records that fact explicitly, and records that the operator's request is the
   only boundary the run has. That statement is written down rather than assumed, because a run with no external
   boundary is a materially different situation from a run with one
   ([D2](artifacts/decision-log.md#d2-the-work-item-is-read-and-recorded-as-the-scope-boundary)).
3. The skill opens with a confirmation turn. It restates the recorded boundary in the operator's own terms and names
   any visual material it kept. Then it asks one question about direction of travel: whether the specific things the
   work item named are being deprecated, replaced, or migrated away from. The question names its subjects from the work item the
   skill has already read, so the operator recognizes them rather than recalling them
   ([D5](artifacts/decision-log.md#d5-direction-of-travel-is-asked-once-alongside-the-work-item-confirmation)). This
   turn is a confirmation, not an escalation, and is the one turn that carries more than one ask
   ([D12](artifacts/decision-log.md#d12-escalations-are-one-question-at-a-time-led-by-plain-language)).
4. The skill persists every piece of visual material the operator supplied into a folder beside the plan, identifiable
   by the state each one depicts. This happens when the material arrives, not when the document is written. It also
   notes each item in the boundary record as that item arrives, so what the run received is on disk rather than held
   in memory ([D15](artifacts/decision-log.md#d15-provided-visual-material-is-persisted-when-it-arrives),
   [D17](artifacts/decision-log.md#d17-a-completeness-gate-confirms-visual-material-reached-disk),
   [T1](artifacts/feature-technical-notes.md#t1-supplied-visual-material-is-reachable-on-disk)).
5. The skill discovers its context and drafts its artifact as it does today, with one addition. Every work unit and
   every work item now carries a justification. It names the work-item language it descends from, the design material
   the operator attached, or the asked-for work it is a necessity of
   ([D6](artifacts/decision-log.md#d6-every-work-unit-names-what-it-descends-from),
   [D31](artifacts/decision-log.md#d31-the-scope-gate-cuts-subsystems-never-necessities-of-the-asked-for-work),
   [D32](artifacts/decision-log.md#d32-material-the-operator-attached-is-part-of-the-boundary)).
6. The skill dispatches its review team. Every dispatched reviewer receives the paths to the persisted visual material
   along with its domain brief, and is told to read it
   ([D18](artifacts/decision-log.md#d18-provided-visual-material-reaches-every-dispatched-reviewer)). Each brief also
   carries the size of the work item as a stated proportionality signal
   ([D28](artifacts/decision-log.md#d28-output-volume-scales-to-the-size-of-the-work-item)).
7. The skill resolves the returned findings. Findings are first merged by substance, so the same finding raised twice
   is one record carrying both reviewers' identifiers. A finding that turns on visual material is checked against that
   material before it is filed
   ([D20](artifacts/decision-log.md#d20-design-dependent-findings-are-checked-against-the-designs-before-filing)). A
   finding whose author recorded that it could not inspect an input is recorded as unverified and cannot carry blocking
   severity ([D19](artifacts/decision-log.md#d19-an-uninspected-input-strips-blocking-severity-from-the-findings-that-rest-on-it)).
8. The skill sweeps every commitment the artifact carries against the work item, including commitments inherited from
   an upstream document. The sweep cuts subsystems, integrations, and artifacts the work item never asks for. It does
   not cut behavior required to deliver what the work item does ask for
   ([D8](artifacts/decision-log.md#d8-the-yagni-sweep-gains-a-scope-gate-covering-inherited-commitments),
   [D31](artifacts/decision-log.md#d31-the-scope-gate-cuts-subsystems-never-necessities-of-the-asked-for-work)).
9. When a question survives all of that, the skill escalates it to the operator as one question. It leads with the
   consequence a person who will not read the code would describe, carries named candidate answers, and places
   technical references below the question or leaves them out
   ([D12](artifacts/decision-log.md#d12-escalations-are-one-question-at-a-time-led-by-plain-language)).
10. Before declaring the artifact finished, the skill confirms that every item the boundary record lists as received
    exists on disk beside the plan
    ([D17](artifacts/decision-log.md#d17-a-completeness-gate-confirms-visual-material-reached-disk)).
    It also presents the cut list in the closing summary alongside the artifact paths
    ([D35](artifacts/decision-log.md#d35-the-cut-list-is-visible-reversible-and-distinct-from-a-yagni-deferral)).

## Alternate Flows and States

### The work item cannot be found

- **Entry condition:** The operator named a work item the skill cannot reach, or named none and the conversation does
  not identify one.
- **Sequence:** The skill asks the operator once for the work item or for its scope in their own words, in the same
  confirmation turn that carries the direction-of-travel question. If the operator declines or has none, the skill
  records that the operator's request is the only boundary and continues
  ([D2](artifacts/decision-log.md#d2-the-work-item-is-read-and-recorded-as-the-scope-boundary)).
- **Exit:** The run continues with a recorded boundary, never with an assumed one.

### No boundary record exists from an earlier skill

- **Entry condition:** A skill runs against a plan folder holding no boundary record. That happens when it was invoked
  on its own, when the folder predates this change, or when the earlier skill in the chain never ran.
- **Sequence:** The skill establishes the boundary itself, exactly as the first step describes, and writes the record.
  It does not proceed unbounded, and it does not treat an absent record as a recorded statement that no work item
  exists ([D33](artifacts/decision-log.md#d33-the-boundary-record-has-one-name-and-one-home)).
- **Exit:** A record exists for every later skill in the chain.

### A proposed work unit cannot be justified

- **Entry condition:** A work unit or work item cannot name the work-item language it descends from, the design
  material the operator attached, or the asked-for work it is a necessity of
  ([D6](artifacts/decision-log.md#d6-every-work-unit-names-what-it-descends-from)).
- **Sequence:** The skill records the unit in the cut list. It names what the unit would have done, in the same plain
  language an escalation uses, and the reason it could not be justified. It does not search outward to a linked item,
  a parent epic, or a closed item to find justification, because those are not scope evidence for the item in hand
  ([D3](artifacts/decision-log.md#d3-the-work-item-read-does-not-traverse-outward),
  [D4](artifacts/decision-log.md#trivial-decisions)).
- **Exit:** The unit is absent from the plan and present in the cut list, which the closing summary shows. The
  operator may reinstate any entry, and their direction is itself a valid justification the reinstated unit records
  ([D35](artifacts/decision-log.md#d35-the-cut-list-is-visible-reversible-and-distinct-from-a-yagni-deferral)).

### An upstream document commits to something the work item excludes

- **Entry condition:** A feature specification, technical note, or other upstream artifact commits to a subsystem,
  integration, or artifact the work item never asks for.
- **Sequence:** The skill cuts the commitment and records the work-item citation that supports the cut. It does not
  ask the operator to choose between options, because the work item already settled the question
  ([D9](artifacts/decision-log.md#d9-an-upstream-specification-is-an-artifact-not-a-scope-authority),
  [D11](artifacts/decision-log.md#d11-a-question-the-work-item-already-answers-is-never-escalated)).
- **Exit:** The plan reflects the work item's boundary, and the cut list shows which upstream commitment was cut and
  why.

### A reviewer disagrees with a committed mechanic

- **Entry condition:** A specialist reviewing an implementation plan disagrees with a mechanic the upstream
  specification committed to.
- **Sequence:** The specialist chooses one of three verdicts: confirm the mechanic, contradict it by naming an
  alternative mechanic, or declare it outside the scope of this work item. The third verdict resolves by citing the
  work item, without an escalation to the operator. It is recorded as its own kind of finding. It does not count
  toward the threshold that decides whether the upstream specification is too immature to plan against, because a
  scope cut is not a sign of an immature specification
  ([D10](artifacts/decision-log.md#d10-the-mechanic-contradiction-protocol-gains-an-out-of-scope-verdict)).
- **Exit:** The disagreement resolves inside the run whenever the work item can settle it.

### An input only the operator can supply is missing

- **Entry condition:** Either the plan describes visual work and no visual material exists beside it, or material the
  operator supplied this session could not be kept.
- **Sequence:** The skill stops once. It gathers every missing input of this kind first, so one stop covers them all
  as a single question rather than as several turns. It names what is missing, names in plain language what the
  delivered artifact will be missing without it, names the action that would supply it, and offers to continue. It
  does not treat the absence as a template block to omit
  ([D25](artifacts/decision-log.md#d25-a-single-stop-is-reserved-for-an-input-only-the-operator-can-supply),
  [D27](artifacts/decision-log.md#d27-plan-work-items-separates-no-visual-surface-from-visual-work-with-no-designs)).
- **Exit:** The operator supplies the material, or directs the run to continue with the cost recorded in the
  artifact.

## Edge Cases and Failure Modes

| Condition                                                                             | Required Behavior                                                                                                                                                                                                          |
| ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The work item is silent about a subsystem an upstream document commits to             | Silence is exclusion for a subsystem, integration, or artifact. The commitment is cut with the citation recorded, not escalated as a choice ([D31](artifacts/decision-log.md#d31-the-scope-gate-cuts-subsystems-never-necessities-of-the-asked-for-work)). |
| The work item is silent about a behavior the work it asked for needs to function       | The behavior stays. A short work item does not enumerate its own necessities, and the sweep does not read that silence as exclusion ([D31](artifacts/decision-log.md#d31-the-scope-gate-cuts-subsystems-never-necessities-of-the-asked-for-work)). |
| Attached design material depicts work the work item's text never mentions             | The material justifies the work, because attaching it is part of the act of asking. Material reached by other means, a linked document or a folder from an earlier run, does not ([D32](artifacts/decision-log.md#d32-material-the-operator-attached-is-part-of-the-boundary)). |
| A linked or closed item appears to justify a proposed unit                            | The linked item is not scope evidence ([D3](artifacts/decision-log.md#d3-the-work-item-read-does-not-traverse-outward)). The unit is reported as unjustified ([D4](artifacts/decision-log.md#trivial-decisions)). Its description is not evidence about the current item's platform, status, or intent. |
| A skill is handed a work item different from the one already recorded                  | The skill surfaces the conflict in its confirmation turn and asks which governs. It does not silently overwrite the record or silently trust it ([D33](artifacts/decision-log.md#d33-the-boundary-record-has-one-name-and-one-home)). |
| A reviewer records that it could not inspect an input, then raises a finding that rests on that input | The finding is recorded as unverified and cannot carry blocking severity ([D19](artifacts/decision-log.md#d19-an-uninspected-input-strips-blocking-severity-from-the-findings-that-rest-on-it)). The disclosure travels attached to the finding, not in a separate assumptions list below it. |
| A finding rests on visual material the skill holds                                    | The skill checks the finding against that material before filing it. A finding the material answers directly is closed with the citation rather than promoted to an open item ([D20](artifacts/decision-log.md#d20-design-dependent-findings-are-checked-against-the-designs-before-filing)). |
| Decisions rest on material no reviewer received                                       | The findings record names that evidence class as unaudited ([D16](artifacts/decision-log.md#trivial-decisions)), so the coverage gap is visible rather than silent.                                                          |
| The same finding is raised by two reviewers under different identifiers                | Findings merge by substance before the unverified and design-check rules apply, and the merged record carries every originating identifier ([D21](artifacts/decision-log.md#trivial-decisions)), so the two do not end up in contradictory states. |
| A decision is written before the review round returns                                  | Classification into full or trivial happens once, after the round ([D22](artifacts/decision-log.md#d22-decisions-are-classified-once-after-the-review-round)), because two of its promotion signals cannot exist at draft time. |
| Visual material arrives after the review team is already dispatched                    | The run persists it, then re-briefs the reviewers it can still reach and records which reviewers never received it, so any finding of theirs that turns on it is unverified ([D18](artifacts/decision-log.md#d18-provided-visual-material-reaches-every-dispatched-reviewer)). |
| Supplied visual material could not be kept because it was never reachable as a file    | This is a different situation from having no material at all. The run names which items it could not keep and asks for them through the single stop, while they are still recoverable ([T1](artifacts/feature-technical-notes.md#t1-supplied-visual-material-is-reachable-on-disk)). |
| An expected artifact is missing and nobody can produce it now                          | The skill records it in the report, drafts around it, and flags what it blocks. It does not stop ([D23](artifacts/decision-log.md#d23-the-two-missing-artifact-rules-are-reconciled-and-split-by-who-can-supply-the-artifact)). |
| An expected artifact is missing and the operator could supply it now                   | The skill stops once, names the cost of proceeding, names how to supply it, and offers to proceed ([D25](artifacts/decision-log.md#d25-a-single-stop-is-reserved-for-an-input-only-the-operator-can-supply)). A second missing input of the same kind joins that one stop rather than causing another. |
| The operator answers the work-item confirmation but not the direction-of-travel question | The absence is recorded as unanswered, which is a different state from a recorded "not known" ([D5](artifacts/decision-log.md#d5-direction-of-travel-is-asked-once-alongside-the-work-item-confirmation)). A later skill may ask once; a recorded answer of any kind is never re-asked. |
| An escalation would carry four questions at once                                       | The run asks one, waits, then asks the next, and says how many are pending. It presents more than one in a turn only when the operator asks for that ([D12](artifacts/decision-log.md#d12-escalations-are-one-question-at-a-time-led-by-plain-language)). |
| An explanation would name a concept the operator has never been given                  | A term counts as unintroduced when it appears in neither the work item nor this conversation. The run gives a concrete outcome the operator could observe, described in words from their own domain, in place of describing a mechanism ([D13](artifacts/decision-log.md#d13-a-shared-standard-covers-explaining-technical-work-to-a-non-implementer)). |
| `han-feedback` finds a file for today and the session continued past it                | The file is updated in place and the update is stated ([D26](artifacts/decision-log.md#trivial-decisions)). The run skips only when nothing new has happened.                                                                |
| The environment refuses to let `han-feedback` publish                                  | The run says plainly that the environment refused rather than that the run declined, does not retry the identical command, and hands over a copy-pasteable command ([D29](artifacts/decision-log.md#trivial-decisions)).     |

## User Interactions

- **Affordances.** The operator confirms the recorded boundary and answers the direction-of-travel question in one
  opening turn. They see the cut list in the closing summary, naming what each dropped unit would have done, and they
  can reinstate any of it
  ([D35](artifacts/decision-log.md#d35-the-cut-list-is-visible-reversible-and-distinct-from-a-yagni-deferral)).
  They see a record of any evidence class no reviewer could audit.
- **Feedback.** The opening turn states what was captured: the boundary in the operator's own terms, and each piece of
  visual material kept, by name. Escalations after that arrive one at a time. Each leads with the consequence in plain
  language, carries named candidate answers, and puts technical references below the question or leaves them out
  ([D12](artifacts/decision-log.md#d12-escalations-are-one-question-at-a-time-led-by-plain-language)). Where a
  question needs an explanation, the run gives a concrete observable outcome rather than describing a mechanism
  ([D13](artifacts/decision-log.md#d13-a-shared-standard-covers-explaining-technical-work-to-a-non-implementer)).
- **Error states.** A missing input the operator can supply produces exactly one stop, naming the cost of proceeding
  and the action that would supply it. A missing input nobody can supply produces a recorded gap and no question at
  all. A run that cannot justify a proposed unit reports it in the cut list rather than asking the operator to pick an
  option.

## Coordinations

The four planning skills and the two supporting plugins pass artifacts and conventions between each other. The
contracts below are what keeps this change set consistent rather than four separate fixes that disagree. Each row
states the behavior guaranteed; where a convention has to live somewhere, the decision log records where.

| Coordinating System                                | Direction | Interaction                                                                                                                          | Ordering / Consistency Requirement                                                                                                                     |
| -------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Visual-material producer to visual-material consumer | outbound  | A planning skill writes supplied visual material beside the plan; `plan-work-items` inventories it and maps it to work items.         | Persistence happens when the material arrives. The producer also emits the reference table and the inline placements the consumer already reads ([D14](artifacts/decision-log.md#trivial-decisions)). |
| Visual material to review team                     | outbound  | Persisted material is passed by path in every reviewer's brief.                                                                       | Persistence precedes dispatch, so briefs carry real paths rather than a promise.                                                                       |
| Boundary record to every downstream skill          | inbound   | The recorded scope, exclusions, and direction-of-travel answer travel in a record every planning skill reads and writes by one name.  | Written by the earliest skill in the chain. A later skill that finds no record establishes one instead of proceeding unbounded ([D33](artifacts/decision-log.md#d33-the-boundary-record-has-one-name-and-one-home)). |
| Boundary record to the work-item inventory         | inbound   | `plan-work-items` reads the boundary record rather than re-asking the operator.                                                       | The record is readable by downstream skills, so the process-artifact exclusion that keeps decision logs and findings out of work items admits it.       |
| Folder convention to every planning skill          | inbound   | Producer and consumer agree on where visual material lives and how it is cited.                                                       | One statement they both read, so the convention cannot drift between them ([D24](artifacts/decision-log.md#d24-the-visual-material-convention-lives-in-one-han-planning-reference)). |
| Explanation standard to every escalating skill     | inbound   | Every escalating skill sources the standard for explaining technical work to a reader who will not implement it.                      | Sourced through the same kind of inline surfacing skill the readability standard uses, so one copy serves every plugin ([D13](artifacts/decision-log.md#d13-a-shared-standard-covers-explaining-technical-work-to-a-non-implementer)). |
| Missing-artifact rule to its own skill's steps     | inbound   | One rule states the split by who can supply the artifact; any other mention references it.                                            | Stated once. The contradiction where a step and its own linked reference give opposite instructions is removed ([D23](artifacts/decision-log.md#d23-the-two-missing-artifact-rules-are-reconciled-and-split-by-who-can-supply-the-artifact)). |
| Proportionality signal to team sizing              | outbound  | The work item's size is passed to reviewer briefs as a stated signal about output length.                                             | Separate from the existing size bands. It governs how much a reviewer writes, never how many reviewers are chosen ([D28](artifacts/decision-log.md#d28-output-volume-scales-to-the-size-of-the-work-item)). |
| Justification record to sequencing and packaging   | inbound   | Sequencing, phasing, and pull-request splits read the justification record before they run. The justification is a named field of its own, not a line of summary prose ([D30](artifacts/decision-log.md#trivial-decisions)). | A unit whose justification is unrecorded is not packaged ([D7](artifacts/decision-log.md#trivial-decisions)). Existence is established first. |
| Shaping context to the phased build                | inbound   | Scope the operator states when invoking `plan-a-phased-build` joins the work item in the boundary record.                             | A goal the operator states out loud is a boundary statement, so the skill's deliberate divergence from its source survives ([D34](artifacts/decision-log.md#d34-operator-stated-shaping-context-is-part-of-the-boundary)). |

## Out of Scope

- Changing which specialists a planning skill selects, or the existing small, medium, and large team caps. The
  proportionality signal governs output length only
  ([D28](artifacts/decision-log.md#d28-output-volume-scales-to-the-size-of-the-work-item)).
- Changing the shared specialist agent definitions. The review-behavior rules reach a reviewer only through the
  dispatching planning skill's brief, so no skill outside the four changes behavior
  ([D36](artifacts/decision-log.md#d36-each-commitment-names-the-skills-it-applies-to)).
- Re-opening behavioral decisions an upstream specification settled that the work item does cover. The license this
  specification grants is narrow: it reaches subsystems, integrations, and artifacts the work item never asks for, and
  nothing else ([D9](artifacts/decision-log.md#d9-an-upstream-specification-is-an-artifact-not-a-scope-authority),
  [D31](artifacts/decision-log.md#d31-the-scope-gate-cuts-subsystems-never-necessities-of-the-asked-for-work)).
- Changing the readability standard or the writing-voice profile. The new explanation standard sits beside them and
  governs what a run says to the operator in a turn, where the readability standard governs the shape of a written
  deliverable.
- Changing where planning artifacts are written or what the existing artifacts contain, beyond the fields this
  specification names.

Two obligations fall outside the behavior above, carried by the same change. The long-form documentation for the four
planning skills and `han-feedback` is updated to match the behavior. The repository's own documentation is corrected
wherever the new shared convention leaves it stale
([D24](artifacts/decision-log.md#d24-the-visual-material-convention-lives-in-one-han-planning-reference)).

## How We Will Know It Worked

The Outcome's measure is a run that does not happen, which nothing observes directly. These four criteria stand in for
it, and each one is checkable on a finished artifact.

1. Every run that received visual material finishes with that material on disk beside the plan. The produced
   specification also carries a reference table naming each item and the state it shows.
2. Every work unit and work item in a produced plan either carries a filled justification or appears in the cut list
   with a reason.
3. No finding reaches the operator as build-blocking when its author recorded that it could not inspect the input the
   finding rests on.
4. A boundary record exists beside every plan a planning skill produces, naming either the work item's scope and
   exclusions or the statement that the operator's request was the only boundary.

## Deferred (YAGNI)

### Extending the scope boundary to `iterative-plan-review`

- **Why deferred:** Evidence test. No reported run names this skill. Including it rests on symmetry with the four
  skills that were named, which the YAGNI rule flags as a candidate by default.
- **Reopen when:** A reported run shows `iterative-plan-review` widening a plan past its work item.
- **Source:** Symmetry with the four named planning skills.

### Citing the visual-material convention from `iterative-plan-review`

- **Why deferred:** Evidence test, for the same reason as the scope boundary. Deferring both together keeps the
  skill's treatment consistent rather than leaving it half-covered.
- **Reopen when:** A reported run shows `iterative-plan-review` reviewing a design-driven plan without the designs.
- **Source:** F32, raised while auditing which skills the phrase "every planning skill" reaches.

### A rewrite pass for escalation prose

- **Why deferred:** Simpler-version test. A standard the escalating skills source while drafting satisfies the same
  evidence as a separate reviewing pass with its own agent. The evidence is that escalations were written in jargon,
  not that a review of them was missing. The inline skill that surfaces the standard is the delivery vehicle and is
  in scope; a rewriting agent is not.
- **Reopen when:** Escalations still read as jargon after the shared standard is in place.
- **Source:** The two rejected escalations described in the reported runs.

### Rules for a visual-material folder holding items from an earlier run

- **Why deferred:** Evidence test. No reported run exercises a second run against a folder that already holds
  material, and the reviewer who raised it recorded the same doubt.
- **Reopen when:** A run reads material from an earlier session and a reviewer or implementer acts on the wrong item.
- **Source:** F36.

### Detecting a reviewer that does not disclose its own blind spot

- **Why deferred:** Evidence test. The rule that strips blocking severity fires on the reviewer's own disclosure, and
  the one reported run supplies the only evidence, in which the reviewer did disclose. The design re-check already
  covers that documented failure without depending on the reviewer saying anything, so building for the silent case
  now would be speculation.
- **Reopen when:** A reported run shows a reviewer raising a blocking finding on an input it could not inspect,
  without saying it could not inspect it.
- **Source:** F29, carried as an open item through review and settled here.

### Automated validation that a specification carries its visual reference table

- **Why deferred:** Evidence test. No incident shows the completeness gate being skipped once it exists. The gate
  itself is the cheaper first move.
- **Reopen when:** A run passes the completeness gate and still ships a specification with no reference table.
- **Source:** Considered while specifying the completeness gate.

### A machine-readable boundary record shared across skills

- **Why deferred:** Simpler-version test. A recorded statement under one agreed name satisfies the same evidence as a
  structured format the skills parse.
- **Reopen when:** A downstream skill demonstrably fails to find the recorded boundary in prose.
- **Source:** Considered while specifying the boundary record.

## Open Items

None remain. The three items this specification carried after review were each settled, and the record of where they
went is kept here so a reader can follow them.

- **OI-1, now closed.** The completeness gate read what the run held in memory, so a compacted session left it nothing
  to check. The run now notes each received item in the boundary record as it arrives, and the gate reads that record
  ([D17](artifacts/decision-log.md#d17-a-completeness-gate-confirms-visual-material-reached-disk)). This also catches
  partial loss, where five items were received and three were saved.
- **OI-2, now closed as an accepted limit.** The unverified-finding rule still fires on a reviewer's own disclosure,
  so it stays inert against a reviewer that does not notice its own blind spot. The design re-check covers the one
  failure the reports document, because it does not depend on the reviewer saying anything. The residue moved to
  `## Deferred (YAGNI)` with the trigger that would reopen it
  ([D19](artifacts/decision-log.md#d19-an-uninspected-input-strips-blocking-severity-from-the-findings-that-rest-on-it)).
- **OI-3, now closed.** The proportionality signal named a size band and trusted the reviewer to infer a length. It
  now names a rough target length instead, which is a target and not a cap
  ([D28](artifacts/decision-log.md#d28-output-volume-scales-to-the-size-of-the-work-item)).

## Summary

- **Outcome delivered:** Planning runs respect the boundary of the work they descend from, keep the visual material
  the operator supplies, and escalate one plain-language question at a time.
- **Primary actors:** The operator who invokes a planning skill, the four planning skills, and the review teams they
  dispatch.
- **Decisions settled by evidence:** 26; see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 10; see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** `han-core:junior-developer`, `han-core:gap-analyzer`, `han-core:information-architect`,
  `han-core:edge-case-explorer`, `han-core:user-experience-designer`; see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** The scope gate gained a floor, so a short work item cannot cut the necessities of
  its own request. The boundary record gained a name and a home, so downstream skills can find it. The explanation
  standard gained the inline skill that delivers it. The commitments now name which of the four skills each applies
  to; see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0. The three the review round raised were each settled after synthesis; see
  [artifacts/team-findings.md](artifacts/team-findings.md) for how.
- **Technical notes:** 1; see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
