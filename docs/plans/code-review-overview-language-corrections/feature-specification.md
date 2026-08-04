# Feature Specification: Understandable and Usable Output from Code Review and Code Overview

The code review and code overview skills already produce accurate reports. This change makes those reports answer the
three questions people ask afterwards, so the answers arrive in the report instead of costing a follow-up turn each.

## Outcome

Someone runs a code review or a code overview and gets everything they need from the run itself.

Three questions account for the most-repeated follow-up turns people spend on these two skills today: where the file
was written, what a finding means for someone who will not open the code, and whether the problem a finding describes
can really happen. After this change:

- Every finding the reader is expected to act on answers three questions: what goes wrong, what has to be true for it
  to happen, and how likely that is. It answers them in language a person who will not open the file can act on
  ([D1](artifacts/decision-log.md#d1-who-the-second-explanation-on-a-finding-is-written-for)).
- A finding the review believes may never fire says so on its opening line and in the table a person scans, not only
  inside its body ([D16](artifacts/decision-log.md#d16-the-likelihood-and-the-fix-route-reach-the-surface-a-person-scans)).
- Both skills write their output where the person configured it to go, and both say where that was
  ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)).
- Both closing messages lead with the answer rather than with facts about the run
  ([D8](artifacts/decision-log.md#d8-what-leads-the-closing-message-in-both-skills)).
- An overview's diagrams are legible, and its invented and borrowed terms are explained. Its starting points are in
  reading order, and it ends with a paragraph a person can paste somewhere else.

One part of this reaches further than the two skills. The requirement to explain a term the reader cannot look up goes
into the writing standard every Han document is written against. As a result, documents this work item never examined
gain the rule too, and the editor that rewrites finished drafts starts enforcing it there
([D10](artifacts/decision-log.md#d10-where-the-extended-gloss-rule-lives)). That reach was chosen deliberately, because
it is what gives the rule an enforcer rather than a self-check.

Nothing about the accuracy of either skill changes. The pass that challenges every finding against the code, the rule
that a finding is only dropped with counter-evidence, the severity bands, the order findings appear in, the finding
identifiers people work as a queue, and the rule that keeps clean reviews short all stay exactly as they are.

**Two words this specification uses that a reader of a report never sees.** A **finding the reader is expected to act
on** is what the report calls a critical, warning, suggestion, or security finding. An **advisory finding** is one the
report already states will not be corrected unless someone asks. Both skills use the report's own vocabulary; this
distinction exists here only so the rules below can be stated once
([D2](artifacts/decision-log.md#d2-which-findings-carry-the-second-explanation)).

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
   implement it ([D4](artifacts/decision-log.md#trivial-decisions)).
4. Each finding the reader is expected to act on leads with a plain-language explanation. It answers three questions:
   what goes wrong that someone could observe, what has to be true for it to happen, and how likely that is
   ([D1](artifacts/decision-log.md#d1-who-the-second-explanation-on-a-finding-is-written-for)). The explanation answers
   all three; where an answer is not in doubt, it is a clause rather than a sentence. The existing register — what to
   do, where, and why, for the person who will open the file — follows it. Security findings carry the explanation and
   keep the remediation note their section already ends with, rather than gaining a second one
   ([D15](artifacts/decision-log.md#d15-security-findings-carry-the-plain-language-explanation-but-not-a-separate-fix-route)).
   Advisory findings carry neither, because their stated reopen trigger already answers what the explanation would say
   ([D2](artifacts/decision-log.md#d2-which-findings-carry-the-second-explanation)).
5. Where the review has already worked out that a failure mode cannot be reached, and used that to lower the finding's
   severity, the explanation states that reasoning instead of discarding it. Where it has no such reasoning, the
   answers are derived from the evidence the finding already carries. Deriving them never changes the finding's
   severity ([D3](artifacts/decision-log.md#d3-publishing-the-reachability-reasoning-instead-of-discarding-it)).
6. Where the review has established that a finding may never fire, that fact appears on the finding's opening line and
   in its row in the report's summary table. That way, a person triaging thirty findings sees it before reading any of
   them ([D16](artifacts/decision-log.md#d16-the-likelihood-and-the-fix-route-reach-the-surface-a-person-scans)).
7. Each finding the reader is expected to act on names how it gets fixed: written test-first as a missing behavior,
   restructured as a design change, or edited by hand
   ([D12](artifacts/decision-log.md#d12-each-finding-names-how-it-gets-fixed)). That route also appears in the finding's
   summary row ([D16](artifacts/decision-log.md#d16-the-likelihood-and-the-fix-route-reach-the-surface-a-person-scans)).
8. The report is written to a filename derived from the branch or ticket under review
   ([D6](artifacts/decision-log.md#d6-how-the-review-report-file-is-named)).
9. Before presenting, the review checks its own output. It confirms that every finding the reader is expected to act on
   carries the explanation and a fix route, and that the summary rows carry the route and any may-never-fire cue. A
   failed check is fixed before presenting ([D17](artifacts/decision-log.md#d17-each-skill-checks-that-the-new-required-content-is-present-before-it-presents)).
10. The run closes with a short message that leads with the recommendation and the finding counts, then gives the path
    ([D7](artifacts/decision-log.md#d7-what-the-review-says-when-it-finishes),
    [D8](artifacts/decision-log.md#d8-what-leads-the-closing-message-in-both-skills)). The report itself is not repeated
    into the conversation.

### A code overview run

1. The overview resolves where its document will be written, honoring a configured output location when one exists and
   staying outside the repository when none does
   ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)).
2. The overview runs unchanged through exploration and synthesis, leading with why the code or change exists.
3. Every diagram names components and boundaries in its boxes. Fields, types, and technical annotations stay out of the
   boxes and go into the prose beneath the diagram
   ([D9](artifacts/decision-log.md#d9-who-owns-diagram-legibility)).
4. Any term the reader cannot resolve from the code being described gets a half-sentence explanation the first time it
   appears. This covers outside technologies and language runtimes, named statistical or numerical methods, and
   compound nouns the document coins for its own convenience
   ([D10](artifacts/decision-log.md#d10-where-the-extended-gloss-rule-lives)).
5. The starting points are numbered in reading order, each with one line on what the reader learns there. Any starting
   point that is an interface other code calls carries one runnable example call
   ([D13](artifacts/decision-log.md#d13-what-where-to-start-gives-the-reader)).
6. The overview closes with three or four sentences a non-author could read aloud, carrying no file paths and no type
   names ([D11](artifacts/decision-log.md#d11-the-overviews-closing-restatement)).
7. Before presenting, the overview checks its own output. It checks the diagrams against the legibility rule, the
   starting points for their order, the terms a reader cannot look up for their explanations, and the closing
   restatement for its presence and for file paths or type names that should not be in it. A failed check is fixed
   before presenting
   ([D17](artifacts/decision-log.md#d17-each-skill-checks-that-the-new-required-content-is-present-before-it-presents)).
8. The run closes with a short message carrying the closing restatement itself, plus any divergence from the change's
   stated purpose, then the path ([D8](artifacts/decision-log.md#d8-what-leads-the-closing-message-in-both-skills),
   [D11](artifacts/decision-log.md#d11-the-overviews-closing-restatement)).

## Alternate Flows and States

### The code contradicts the stated reason for a change

- **Entry condition:** An overview is explaining a set of changes. The overview has checked the stated motivation
  against the code and found that the code already satisfies it, or does not support it.
- **Sequence:** The overview says so in the section that states the reason, as a fact about that reason
  ([D14](artifacts/decision-log.md#d14-the-overview-may-report-that-a-changes-stated-reason-is-not-supported)). It
  raises no finding, assigns no severity, and recommends no change.
- **Exit:** The rest of the overview proceeds as normal. The reader gets the discrepancy at the point where the claim it
  qualifies is made.
- **Not this flow:** A stated reason the code says nothing about either way. That is the overview's existing case for a
  reason it cannot recover, and it stays there: the reason is marked as inferred and no discrepancy is claimed. Saying
  the code contradicts a reason is a claim the overview must have checked and found true
  ([D14](artifacts/decision-log.md#d14-the-overview-may-report-that-a-changes-stated-reason-is-not-supported)).

### A finding may never fire

- **Entry condition:** A finding survives to the report, but the conditions required for its failure mode may never hold
  in practice.
- **Sequence:** The finding's opening line and its summary row both say so. The explanation names the conditions and
  states that the finding is a no-op if they do not hold
  ([D3](artifacts/decision-log.md#d3-publishing-the-reachability-reasoning-instead-of-discarding-it),
  [D16](artifacts/decision-log.md#d16-the-likelihood-and-the-fix-route-reach-the-surface-a-person-scans)).
- **Exit:** The finding stays in the report at its assigned severity and in its existing position. Nothing is dropped or
  reordered on this basis; the reader is told what the review already knows, in the place they will see it first.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| No output location is configured | Each skill writes where it writes today: the review beside the reports its specialists already produce, the overview outside the repository ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)). |
| A configured output location sits inside the repository | The run honors it and says nothing about it. The person who configured it chose that; the overview's commitment not to be committed governs its own default, not what a person configures ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)). |
| The resolved destination cannot be written | The run writes to the unconfigured default instead and says so in its closing message, naming the destination it could not use. The run is not abandoned: everything it produced is finished by then ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)). |
| A review runs against the default branch, or against a scope with no branch at all | The report is named from what was reviewed: the single file, directory, or symbol when there is one, and the common parent of the reviewed files when there is not. A branch name that does not distinguish the run is not used ([D6](artifacts/decision-log.md#d6-how-the-review-report-file-is-named)). |
| A report already exists at the derived name | The run replaces it and names the replaced report in its closing message ([D6](artifacts/decision-log.md#d6-how-the-review-report-file-is-named)). |
| A review finds nothing at all | The closing message says the code can be approved and gives the path. No explanations are written, because there are no findings. |
| A review's only findings are advisory | The recommendation is still that the code can be approved, because advisory findings never block a merge. The message says the count a person must act on is zero and names the advisory count separately. That way nobody is told "no findings" about a report whose body lists items ([D7](artifacts/decision-log.md#d7-what-the-review-says-when-it-finishes)). |
| A finding's failure mode is reachable and its likelihood is not in doubt | The explanation still appears and still answers all three questions, answering the two that are not in doubt in a clause each ([D1](artifacts/decision-log.md#d1-who-the-second-explanation-on-a-finding-is-written-for)). |
| An overview's diagram cannot be simplified without losing a step the flow needs | The step stays and the detail about it moves to the prose beneath. Legibility never removes a step from the flow ([D9](artifacts/decision-log.md#d9-who-owns-diagram-legibility)). |
| An overview target contains both an interface and the flow behind it | Each starting point is judged on its own. The interface carries an example call; the flow entry points do not ([D13](artifacts/decision-log.md#d13-what-where-to-start-gives-the-reader)). |
| An overview covers only part of its target | The coverage note stays where it is and is named in the closing message after the answer, not before it ([D8](artifacts/decision-log.md#d8-what-leads-the-closing-message-in-both-skills)). |

## User Interactions

- **Affordances:** The review's closing message gives the recommendation, the counts, and the path
  ([D7](artifacts/decision-log.md#d7-what-the-review-says-when-it-finishes)). Its summary table carries the fix route
  and any may-never-fire cue beside each finding's brief description, so triage happens before reading ([D16](artifacts/decision-log.md#d16-the-likelihood-and-the-fix-route-reach-the-surface-a-person-scans)). The
  overview's closing message carries the document's own closing restatement, so a person can paste from the terminal
  without opening the file ([D11](artifacts/decision-log.md#d11-the-overviews-closing-restatement)).
- **Feedback:** Each finding a reader is expected to act on tells them whether to care, in terms they can weigh, and
  names the route to fixing it ([D12](artifacts/decision-log.md#d12-each-finding-names-how-it-gets-fixed)).
- **Error states:** One. A resolved destination that cannot be written falls back to the unconfigured default, and the
  closing message says so ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)).

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| Han's configuration | inbound | Supplies the output location both skills resolve against | Read before either skill writes its deliverable ([D5](artifacts/decision-log.md#d5-where-the-report-and-the-overview-are-written)) |
| Han's standard for explaining work to a non-implementer | inbound | Supplies the register for the finding explanations, the overview's closing restatement, and both closing messages | Sourced before that content is drafted, not after ([D4](artifacts/decision-log.md#trivial-decisions)) |
| Han's shared writing standard | inbound and outbound | Gains the extended requirement to explain a term the reader cannot look up | Every skill that sources the standard inherits the requirement, and the agent that rewrites finished drafts enforces it ([D10](artifacts/decision-log.md#d10-where-the-extended-gloss-rule-lives)) |
| The skills a finding points to as its fix route | outbound | Named by each finding a reader is expected to act on, as the way to address it | The route is named, never invoked ([D12](artifacts/decision-log.md#d12-each-finding-names-how-it-gets-fixed)) |

## Out of Scope

- **Any change to how findings are discovered, challenged, or dropped.** The specialists, the adversarial pass, the
  counter-evidence bar for dropping a finding, and the severity bands all stay as they are. Working out a finding's
  preconditions and likelihood in order to explain it is writing work, and it never feeds back into that finding's
  severity ([D3](artifacts/decision-log.md#d3-publishing-the-reachability-reasoning-instead-of-discarding-it)).
- **Any change to the finding identifiers or the order findings appear in.** People work them as a queue across
  sessions; both stay ([D16](artifacts/decision-log.md#d16-the-likelihood-and-the-fix-route-reach-the-surface-a-person-scans)).
- **Auditing the documents that inherit the extended gloss rule.** Every skill sourcing the shared writing standard gains
  the rule, and nothing here checks what that does to their output
  ([D10](artifacts/decision-log.md#d10-where-the-extended-gloss-rule-lives)).
- **Letting the overview judge the code's quality.** Reporting that the code contradicts a change's stated reason is a
  fact about the reason, not a finding about the code
  ([D14](artifacts/decision-log.md#d14-the-overview-may-report-that-a-changes-stated-reason-is-not-supported)).
- **Letting the rewrite pass edit diagram bodies.** The exemption stays; the check moves to the skill
  ([D9](artifacts/decision-log.md#d9-who-owns-diagram-legibility)).

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it.

### Every other Han skill honoring the configured output location

- **What it would have done:** Extended the destination resolution in this feature to every Han skill that writes a
  deliverable, rather than to the two named here.
- **Why cut:** The recorded boundary in [scope-boundary.md](artifacts/scope-boundary.md) names two skills. Only the
  Atlassian skills consume the configured output location today, so the same gap likely exists elsewhere. But the work
  item is a retrospective on code review and code overview, and its stated scope covers those two.

### Fixing the same plain-language gap in the skills the work item quotes as corroboration

- **What it would have done:** Applied the same plain-language requirement to the other skills the work item quotes,
  rather than to the two named here.
- **Why cut:** The work item quotes people asking for plain-language summaries from other skills, and offers those
  quotes as evidence that the gap is shared rather than local. They are corroboration for the finding, not items in the
  stated scope recorded in [scope-boundary.md](artifacts/scope-boundary.md). That scope names improvements to code
  review and code overview only.

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### A countable threshold for diagram legibility

- **Why deferred:** Evidence-test failure. Both complaints in the corpus were about what the boxes contained, not about
  how many there were or how long the labels ran. Both were fixed by taking the technical detail out. A counted limit
  on box labels or box count is a rule nobody asked for, and a diagram can satisfy a count while still being
  unreadable.
- **Reopen when:** A diagram that satisfies the stated rule still draws a legibility complaint.
- **Source:** Considered while settling
  [D9](artifacts/decision-log.md#d9-who-owns-diagram-legibility); the work item's improvement 3 suggests checking
  "node-label length and count".

### Distinguishing two runs writing to the same destination at the same time

- **Why deferred:** Evidence-test failure. Nothing in the corpus reports two runs racing to one destination, and the
  corpus is one person's runs over four weeks. The collision the work item does report is sequential, and the naming
  change plus the replace-and-say-so rule cover it.
- **Reopen when:** Two runs are reported to have overwritten each other's output within one session, or the skills are
  adopted by a team sharing one checkout.
- **Source:** Review finding [F20](artifacts/team-findings.md#f20-concurrent-runs-writing-to-one-destination), raised
  by `han-core:edge-case-explorer`, which flagged it for awareness rather than recommending new behavior.

### Counting conditional findings in the review's closing message

- **Why deferred:** Simpler-version test. The likelihood cue reaching the summary table
  ([D16](artifacts/decision-log.md#d16-the-likelihood-and-the-fix-route-reach-the-surface-a-person-scans)) already puts
  the fact where a person triages. Adding a count of it to the closing message as well is a second signal for the same
  fact, before anyone has seen whether the first one is enough.
- **Reopen when:** Someone acts on a finding the report had already marked as possibly never firing.
- **Source:** Review finding
  [F21](artifacts/team-findings.md#f21-counting-conditional-findings-in-the-reviews-closing-message), raised by
  `han-core:user-experience-designer`, which recommended deferring it on the same grounds.

## Open Items

- **OI-1:** Whether the added length per finding is worth the follow-up turns it removes has not been measured. The work
  item's own length score is attributed to the review pasting itself into the conversation and to bookkeeping-led
  closing messages, both of which this feature fixes. The trade was accepted on that basis, not on evidence about
  finding bodies ([D1](artifacts/decision-log.md#d1-who-the-second-explanation-on-a-finding-is-written-for)).
  - **Resolves when:** A report with a substantial finding list has been produced under these rules and read.
  - **Blocks implementation:** No — the simpler-version bound on the explanation and the summary-row cues are the
    hedges, and both are specified.

## Summary

- **Outcome delivered:** A code review or code overview run answers the three questions people currently spend
  follow-up turns asking, inside the run that produced it.
- **Primary actors:** The person who invokes either skill, and the reviewer or teammate they hand the output to.
- **Decisions settled by evidence:** 16 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 1 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** `han-core:junior-developer`, `han-core:user-experience-designer`,
  `han-core:edge-case-explorer` — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** The likelihood cue and the fix route now reach the summary table rather than only
  the finding body. This is the comparative problem the originating complaint about visual weight describes. The
  explanation is bounded to what is in doubt rather than three fixed slots. And security findings, advisory-only
  reviews, unwritable destinations, replaced reports, and mixed interface-and-flow targets all gained stated behavior
  — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
