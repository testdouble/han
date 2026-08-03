# Feature Specification: Understandable and Usable Output from Code Review and Code Overview

The code review and code overview skills already produce accurate reports. This change makes those reports answer the
three questions people ask afterwards, so the answers arrive in the report instead of costing a follow-up turn each.

## Outcome

Someone runs a code review or a code overview and gets everything they need from the run itself.

Three questions account for nearly every follow-up turn people spend on these two skills today: where the file was
written, what a finding actually means for someone who will not open the code, and whether the problem a finding
describes can really happen. After this change:

- Every corrective finding says what goes wrong, what has to be true for it to happen, and how likely that is, in
  language a person who will not open the file can act on ([D1](artifacts/decision-log.md#d1-who-the-second-explanation-on-a-finding-is-written-for)).
- Both skills write their output where the person configured it to go, and both say where that was
  ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)).
- Both closing messages lead with the answer rather than with facts about the run
  ([D8](artifacts/decision-log.md#d8-what-leads-the-closing-message-in-both-skills)).
- An overview's diagrams are legible, its invented and borrowed terms are explained, its starting points are in reading
  order, and it ends with a paragraph a person can paste somewhere else.

Nothing about the accuracy of either skill changes. The pass that challenges every finding against the code, the rule
that a finding is only dropped with counter-evidence, the finding identifiers people work as a queue, and the rule that
keeps clean reviews short all stay exactly as they are.

## Actors and Triggers

- **Actors** — the person who invokes a code review or a code overview, and the people they hand the output to: a
  reviewer, a pull request audience, a teammate who did not do the work.
- **Triggers** — a code review run, or a code overview run in either of its modes: explaining code as it is now, or
  explaining a set of changes.
- **Preconditions** — none beyond what each skill already requires. Where a person has configured an output location,
  that configuration is available to the run.

## Primary Flow

### A code review run

1. The review resolves where its report will be written, honoring a configured output location when one exists and
   falling back to the location it uses today when none does
   ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)).
2. The review runs unchanged: it classifies the change, dispatches its specialists, works its checklist, and challenges
   the resulting findings against the code.
3. Before drafting any finding, the review sources Han's standard for explaining technical work to someone who will not
   implement it ([D4](artifacts/decision-log.md#d4-both-skills-source-the-explanation-standard-before-they-write-for-a-non-implementer)).
4. Each corrective finding is written with two registers. The first is what exists today: what to do, where, and why,
   for the person who will open the file. The second is new and required: the observable consequence, the conditions
   that must all hold for it to occur, and an honest likelihood
   ([D1](artifacts/decision-log.md#d1-who-the-second-explanation-on-a-finding-is-written-for)). Advisory findings carry
   only the first, because their stated reopen trigger already answers what the second would say
   ([D2](artifacts/decision-log.md#d2-which-findings-carry-the-second-explanation)).
5. Where the review has already worked out that a failure mode cannot be reached, and used that to lower the finding's
   severity, that reasoning is what the second register states rather than being discarded
   ([D3](artifacts/decision-log.md#d3-publishing-the-reachability-reasoning-instead-of-discarding-it)).
6. Each corrective finding names how it gets fixed: written test-first as a missing behavior, restructured as a design
   change, or edited by hand ([D12](artifacts/decision-log.md#d12-each-finding-names-how-it-gets-fixed)).
7. The report is written to a filename derived from the branch or ticket under review
   ([D6](artifacts/decision-log.md#d6-how-the-review-report-file-is-named)).
8. The run closes with a short message that leads with the recommendation and the finding counts by severity, then gives
   the path ([D7](artifacts/decision-log.md#d7-what-the-review-says-when-it-finishes),
   [D8](artifacts/decision-log.md#d8-what-leads-the-closing-message-in-both-skills)). The report itself is not repeated
   into the conversation.

### A code overview run

1. The overview resolves where its document will be written, honoring a configured output location when one exists and
   staying outside the repository when none does
   ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)).
2. The overview runs unchanged through exploration and synthesis, leading with why the code or change exists.
3. Every diagram names components and boundaries in its boxes. Fields, types, and technical annotations stay out of the
   boxes and go into the prose beneath the diagram. The overview checks its own diagrams against this before presenting
   ([D9](artifacts/decision-log.md#d9-who-owns-diagram-legibility)).
4. Any term the reader cannot resolve from the code being described gets a half-sentence explanation the first time it
   appears. This covers outside technologies and language runtimes, named statistical or numerical methods, and
   compound nouns the document coins for its own convenience
   ([D10](artifacts/decision-log.md#d10-where-the-extended-gloss-rule-lives)).
5. The starting points are numbered in reading order, each with one line on what the reader learns there. When the
   target is an interface other code calls, the section also carries one runnable example call
   ([D13](artifacts/decision-log.md#d13-what-where-to-start-gives-the-reader)).
6. The overview closes with three or four sentences a non-author could read aloud, carrying no file paths and no type
   names ([D11](artifacts/decision-log.md#d11-the-overviews-closing-restatement)).
7. The run closes with a short message that leads with why the code or change exists and any divergence from its stated
   purpose, then gives the path ([D8](artifacts/decision-log.md#d8-what-leads-the-closing-message-in-both-skills)).

## Alternate Flows and States

### The stated reason for a change is not supported by the code

- **Entry condition:** An overview is explaining a set of changes, and the code shows the stated motivation is already
  satisfied, or does not support the reason given.
- **Sequence:** The overview says so in the section that states the reason, as a fact about that reason
  ([D14](artifacts/decision-log.md#d14-the-overview-may-report-that-a-changes-stated-reason-is-not-supported)). It
  raises no finding, assigns no severity, and recommends no change.
- **Exit:** The rest of the overview proceeds as normal. The reader gets the discrepancy at the point where the claim it
  qualifies is made.

### A finding may be a no-op

- **Entry condition:** A review finding survives to the report, but the conditions required for its failure mode may
  never hold in practice.
- **Sequence:** The finding's second register says so plainly, naming the conditions and stating that the finding is a
  no-op if they do not hold
  ([D3](artifacts/decision-log.md#d3-publishing-the-reachability-reasoning-instead-of-discarding-it)).
- **Exit:** The finding stays in the report at its assigned severity. Nothing is dropped on this basis; the reader is
  told what the review already knows.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| No output location is configured | Each skill writes where it writes today: the review beside the reports its specialists already produce, the overview outside the repository ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)). |
| A configured output location points outside the working directory | The run honors it without comment. The person who configured it chose that. |
| A review runs with no branch and no ticket to name the file from | The report is named from the target that was reviewed ([D6](artifacts/decision-log.md#d6-how-the-review-report-file-is-named)). |
| A review finds nothing | The closing message says the code can be approved and gives the path. No finding registers are written, because there are no findings. |
| A finding's failure mode is reachable and its likelihood is not in doubt | The second register still appears, saying so directly. It is required on every corrective finding, not only on uncertain ones ([D1](artifacts/decision-log.md#d1-who-the-second-explanation-on-a-finding-is-written-for)). |
| An overview's diagram cannot be simplified without losing a step the flow needs | The step stays and the detail about it moves to the prose beneath. Legibility never removes a step from the flow ([D9](artifacts/decision-log.md#d9-who-owns-diagram-legibility)). |
| An overview target is a flow rather than an interface | No example call is produced. The numbered starting points stand alone ([D13](artifacts/decision-log.md#d13-what-where-to-start-gives-the-reader)). |
| An overview covers only part of its target | The coverage note stays where it is and is named in the closing message after the answer, not before it ([D8](artifacts/decision-log.md#d8-what-leads-the-closing-message-in-both-skills)). |

## User Interactions

- **Affordances:** The review's closing message gives the recommendation, the counts by severity, and the path. The
  overview's closing message gives why the code or change exists, any divergence from its stated purpose, and the path.
  The overview document itself ends with a paragraph written to be lifted out and pasted into a pull request description
  or a comment ([D11](artifacts/decision-log.md#d11-the-overviews-closing-restatement)).
- **Feedback:** Each corrective finding tells the reader whether to care, in terms they can weigh, and names the route
  to fixing it ([D12](artifacts/decision-log.md#d12-each-finding-names-how-it-gets-fixed)).
- **Error states:** None new. Neither skill gains a failure mode; both gain content and a destination.

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| Han's configuration | inbound | Supplies the output location both skills resolve against | Read before either skill writes its deliverable ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)) |
| Han's standard for explaining work to a non-implementer | inbound | Supplies the register for the finding explanations, the overview's closing restatement, and both closing messages | Sourced before that content is drafted, not after ([D4](artifacts/decision-log.md#d4-both-skills-source-the-explanation-standard-before-they-write-for-a-non-implementer)) |
| Han's shared writing standard | inbound and outbound | Gains the extended requirement to explain a term the reader cannot look up | Every skill that sources the standard inherits the requirement, and the agent that rewrites finished drafts enforces it ([D10](artifacts/decision-log.md#d10-where-the-extended-gloss-rule-lives)) |
| The skills a finding points to as its fix route | outbound | Named by each corrective finding as the way to address it | The route is named, never invoked ([D12](artifacts/decision-log.md#d12-each-finding-names-how-it-gets-fixed)) |

## Out of Scope

- **Any change to how findings are discovered, challenged, or dropped.** The specialists, the adversarial pass, the
  counter-evidence bar for dropping a finding, and the severity bands all stay as they are. This change is about what
  the output says, not what it finds.
- **Any change to the finding identifiers.** People work them as a queue across sessions; the scheme stays.
- **Letting the overview judge the code's quality.** Reporting that a change's stated reason is unsupported is a fact
  about the reason, not a finding about the code
  ([D14](artifacts/decision-log.md#d14-the-overview-may-report-that-a-changes-stated-reason-is-not-supported)).
- **Letting the rewrite pass edit diagram bodies.** The exemption stays; the check moves to the skill
  ([D9](artifacts/decision-log.md#d9-who-owns-diagram-legibility)).

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it.

### Every other Han skill honoring the configured output location

- **Why cut:** The recorded boundary names two skills. Only three skills in the whole suite consume the configured
  output location today, so the same gap almost certainly exists elsewhere, but the work item is a retrospective on code
  review and code overview and its stated scope covers those two.

### Fixing the same plain-language gap in the skills the work item quotes as corroboration

- **Why cut:** The work item quotes people asking for plain-language summaries from three other skills, and offers those
  quotes as evidence that the gap is shared rather than local. They are corroboration for the finding, not items in the
  stated scope, which names improvements to code review and code overview only.

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### A countable threshold for diagram legibility

- **Why deferred:** Evidence-test failure. Both complaints in the corpus were about what the boxes contained, not about
  how many there were or how long the labels ran, and both were fixed by taking the technical detail out. A counted
  limit on box labels or box count is a rule nobody asked for, and a diagram can satisfy a count while still being
  unreadable.
- **Reopen when:** A diagram that satisfies the stated rule still draws a legibility complaint.
- **Source:** Considered while settling
  [D9](artifacts/decision-log.md#d9-who-owns-diagram-legibility); the work item's improvement 3 suggests checking "node-label length and count".

## Summary

- **Outcome delivered:** A code review or code overview run answers the three questions people currently spend
  follow-up turns asking, inside the run that produced it.
- **Primary actors:** The person who invokes either skill, and the reviewer or teammate they hand the output to.
- **Decisions settled by evidence:** 13 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 1 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** to be completed after review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** to be completed after review — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0
