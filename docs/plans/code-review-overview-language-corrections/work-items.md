# Work Items — Understandable and Usable Output from Code Review and Code Overview

These work items break down [feature-specification.md](feature-specification.md), which corrects the reader-facing
output of the `code-review` and `code-overview` skills so a run answers the three questions people currently spend
follow-up turns asking.

Work items are numbered `W-N` for cross-reference only. `Depends on` lines refer to other work items in this file.

## Shared reference artifacts

These artifacts apply to more than one work item below. Each work item's own `**References.**` block points into this
list by name rather than repeating the link.

- [feature-specification.md](feature-specification.md) — the behavior every work item here realizes. Each work item
  names the sections it descends from.
- [artifacts/scope-boundary.md](artifacts/scope-boundary.md) — the recorded boundary this work descends from: the issue,
  its eight quoted improvements, the two constraints on how a change may be made, and the operator's answer that nothing
  in scope is being deprecated.
- [han-core/references/config-rule.md](../../../han-core/references/config-rule.md) — the precedence chain, path
  resolution, and degradation rules a skill honors when it resolves a configured output location. Read by W-2 and W-8.
- [han-communication/references/explanation-rule.md](../../../han-communication/references/explanation-rule.md) — the
  standard for explaining technical work to a reader who will not implement it. Read by W-3, W-4, and W-11.
- [han-communication/references/readability-rule.md](../../../han-communication/references/readability-rule.md) — the
  shared writing standard, including the prose-only rule that exempts diagram bodies. Read by W-1, W-9, and W-13.
- [CLAUDE.md](../../../CLAUDE.md) — the repository's documentation conventions: one canonical source per concept, a
  long-form doc for every skill and agent, and indexes that stay complete.

## W-1 — Extend the shared writing standard to cover coined and borrowed terms

**Summary.** Readers keep asking what a word in a Han document means. The standard today asks a writer to define a term
only when they could not avoid it. It says nothing about outside technology names, named statistical methods, or phrases
a document invents for its own convenience. Those are the words readers got stuck on. This work puts the wider
requirement into the shared standard, where the editor that rewrites finished drafts will enforce it.

**Work to be done.**

- Widen the standard's rule about defining a term, so it covers a term the reader cannot look up rather than a term the
  writer could not avoid.
  - Canonical file: `han-communication/references/readability-rule.md`. The standard has no vendored copies, so this is
    the only edit site for the rule text.
  - The rule declares its self-check enumerated at six criteria and kept small on purpose. Fold the requirement into the
    existing check rather than growing the list, or say in the rule why the list changed.
- Bring the rewriting editor's rubric into line with the widened rule, so the pass that audits a finished draft tests for
  the same thing.
  - Touch point: `han-communication/agents/readability-editor.md`, the rubric criterion covering common words and
    defining an unavoidable term.
- Update the surfaces that restate the standard's wording so none of them contradicts it.
  - Touch points: `docs/readability.md`, and the long-form docs under `han-communication/docs/` that restate the rule or
    the editor's rubric.

**Note on the reach of this work item.** This is the one item in the file that reaches past the two skills. Every skill
that sources the shared standard inherits the requirement, and the editor starts enforcing it on documents nobody here
examined. The specification records that reach as deliberate, because it is what gives the rule an enforcer instead of a
self-check.

**Justification.** Improvement 4 of the issue's quoted "Suggested improvements", recorded in the boundary record:
"Extend the gloss rule to cover coined and external terms."

**References.**

- **Plan decisions**
  - **D10** — the requirement to explain a term the reader cannot look up lives in Han's shared writing standard rather
    than in either skill, so the editor that rewrites finished drafts enforces it.
- **Spec sections** — [Outcome](feature-specification.md#outcome) for the stated reach,
  [A code overview run](feature-specification.md#a-code-overview-run) step 4 for what the requirement covers, and
  [Out of Scope](feature-specification.md#out-of-scope) for the exclusion of auditing the documents that inherit it.
- **Rule file** — `han-communication/references/readability-rule.md`, the canonical standard this work item edits. See
  Shared reference artifacts.
- **Agent definition** — `han-communication/agents/readability-editor.md`, the agent whose rubric enforces the standard
  over a finished draft.
- **Repo doc** — `docs/readability.md`, the operator-facing mirror of the standard. See Shared reference artifacts for
  the documentation convention it follows.

**Acceptance criteria.**

- [ ] The shared writing standard states that a term the reader cannot resolve from the material being described gets a
      half-sentence explanation at first use, and names the three kinds it covers: outside technologies and language
      runtimes, named statistical or numerical methods, and compound nouns a document coins for itself.
- [ ] The standard's own check catches a first use with no explanation, so a draft that fails the requirement is
      corrected before it is presented.
- [ ] The rewriting editor's rubric enforces the same requirement, so a finished draft handed to it gains the missing
      explanations.
- [ ] The requirement applies to prose only. Diagram bodies, code fences, and citation identifiers stay untouched by it.
- [ ] The operator-facing page that mirrors the standard describes the wider requirement and matches what the standard
      says.

**Depends on.** `None.`

## W-2 — Write the review report to a configured location under a name derived from the branch

**Summary.** A code review has nowhere it reliably writes its report. Someone who set an output location in their Han
configuration does not get it honored here. Consecutive runs also collide, because the name never varies with what was
reviewed. This work makes the review write its report to a resolved location under a name derived from the branch or
ticket.

**Work to be done.**

- Resolve the report's destination before the report is written, honoring a configured output location.
  - Touch point: `han-coding/skills/code-review/SKILL.md`. The skill already reads configuration in its Project Context
    block and already picks a directory for its specialists' reports. The report's own destination is the gap.
  - Precedence, relative-path resolution, and what to do with an unusable value are governed by the config rule. Honor
    that file rather than restating its rules in the skill.
- Derive the report file name from the branch or ticket under review, with a fallback for a run that has no
  distinguishing branch.
  - The review already detects its mode and captures a branch name for later steps, so the inputs for the name exist by
    the time the report is written.
- State what happens when the derived name is already taken, and when the destination cannot be written, so the run
  carries both facts into its closing message.
- Describe the destination and naming behavior on the skill's long-form doc.
  - Touch point: `han-coding/docs/skills/code-review.md`.

**Justification.** Improvement 2 of the issue's quoted "Suggested improvements", recorded in the boundary record:
resolve the destination through the config precedence chain, and name the file from the branch or ticket so consecutive
runs stop colliding.

**References.**

- **Plan decisions**
  - **D5** — both skills resolve where their output goes through Han's configuration chain, falling back to today's
    location when nothing is configured.
  - **D6** — the review report is named from the branch or ticket under review, with a named-from-scope fallback and a
    replace-and-say-so rule when the name is already taken.
- **Spec sections** — [A code review run](feature-specification.md#a-code-review-run) steps 1 and 8, and
  [Edge Cases and Failure Modes](feature-specification.md#edge-cases-and-failure-modes) for the rows covering an
  unconfigured default, a configured location inside the repository, an unwritable destination, a run with no
  distinguishing branch, and a name already taken.
- **Rule file** — `han-core/references/config-rule.md`. See Shared reference artifacts.
- **Skill doc** — `han-coding/docs/skills/code-review.md`, the canonical operator-facing description of this skill.

**Acceptance criteria.**

- [ ] The review writes its report to a file, and the location comes from the person's configured output location when
      one is set.
- [ ] With nothing configured, the report lands where the review already puts the reports its specialists produce.
- [ ] The file name is derived from the branch or ticket under review.
- [ ] When the branch does not distinguish the run, the name comes from what was reviewed: the single file, directory,
      or symbol when there is one, and the common parent of the reviewed files when there is not.
- [ ] A report already sitting at the derived name is replaced, and the run records that it replaced one.
- [ ] A destination that cannot be written falls back to the unconfigured default, the run records which destination it
      could not use, and the run finishes rather than stopping.

**Depends on.** `None.`

## W-3 — Close a review with the recommendation and counts instead of the whole report

**Summary.** A code review ends by pasting its whole report into the conversation. The reader scrolls a long document to
reach the one thing they wanted, which is whether the code can be merged. The companion overview skill already gets this
right and says only what the reader needs. This work gives the review a short closing message that leads with the
recommendation and the counts, then points at the file.

**Work to be done.**

- Add a closing step to the review that presents a short message and stops pasting the report into the conversation.
  - Touch point: `han-coding/skills/code-review/SKILL.md`, after the verification step.
  - Source `han-communication:explanation-guidance` before writing the message. Neither of the two skills invokes it
    today.
- Order the message so the recommendation and the counts come before anything about how the run went.
- Cover the clean review, the advisory-only review, the replaced report, and the unwritable destination in the message
  rules.
- Reconcile the verification rule that forbids anything following the review document.
  - Touch point: `han-coding/skills/code-review/references/output-verification.md`, the item requiring the review output
    to be the complete and final response. That rule assumes the report is the conversation response. The report is now
    a file, and the message is what follows it.
- Describe the closing message on the skill's long-form doc.

**Justification.** Improvements 2 and 8 of the issue's quoted "Suggested improvements", recorded in the boundary record:
close with the path, the recommendation, and the count by severity, stop pasting the full review into the conversation,
and lead the closing message with the answer.

**References.**

- **Plan decisions**
  - **D7** — the review's closing message gives the recommendation, the counts by severity, and the path, and separates
    the count a person must act on from the advisory count.
  - **D8** — both skills' closing messages lead with the answer rather than with facts about the run.
- **Spec sections** — [A code review run](feature-specification.md#a-code-review-run) step 10,
  [Edge Cases and Failure Modes](feature-specification.md#edge-cases-and-failure-modes) for the clean-review and
  advisory-only rows, and [User Interactions](feature-specification.md#user-interactions) for what the message affords.
- **Rule file** — `han-communication/references/explanation-rule.md`. See Shared reference artifacts.
- **Skill doc** — `han-coding/docs/skills/code-review.md`.

**Acceptance criteria.**

- [ ] The run ends with a short message, and the full report is not repeated into the conversation.
- [ ] The message leads with the recommendation and the finding counts by severity, then gives the path to the report.
- [ ] Facts about the run itself, such as the size band or how the specialists reconciled, come after the answer or stay
      in the file.
- [ ] A review that found nothing says the code can be approved and gives the path.
- [ ] A review whose only findings are advisory still recommends approval, states that the count a person must act on is
      zero, and names the advisory count separately.
- [ ] The message names a replaced report and a destination that could not be written, when either happened.
- [ ] The skill sources Han's standard for explaining work to a non-implementer before it writes the message.

**Depends on.** `W-2`.

## W-4 — Give every actionable finding a plain-language explanation

**Summary.** A review finding tells an engineer what to change and where. It does not tell anyone whether the problem
can really happen. People read a finding and then ask whether it matters, which costs a follow-up turn every time. This
work adds a plain-language explanation to each finding a reader is expected to act on, written for someone who will not
open the file.

**Work to be done.**

- Add the explanation to the finding block in the review's output template, for the corrective severities and for the
  security block.
  - Touch point: `han-coding/skills/code-review/references/template.md`. Leave the advisory section's format alone.
  - The template's existing rule that a finding's prose lives in exactly one place still holds. The explanation is part
    of that one place.
- State in the skill body that the explanation is drafted for a reader who will not open the file, and source the
  explanation standard before any finding is drafted.
  - Touch point: `han-coding/skills/code-review/SKILL.md`, at the step that generates the review output.
- Carry the reachability reasoning the review already produces into the explanation instead of discarding it.
  - Touch point: the gate in `han-coding/skills/code-review/SKILL.md` that demotes a finding whose rationale signals the
    failure mode is unreachable. That reasoning exists at that moment and is thrown away.
  - Say plainly that this is writing work and never feeds back into severity, because finding discovery and severity are
    outside this work.
- Describe what a finding now carries on the skill's long-form doc.

**Note on what stays untouched.** How findings are discovered, challenged, and dropped does not change here. The
specialists, the pass that challenges every finding against the code, the counter-evidence bar for dropping one, and the
severity bands all stay as they are.

**Justification.** Improvement 1 of the issue's quoted "Suggested improvements", recorded in the boundary record: give
each finding a second prose slot carrying the observable consequence, the preconditions, and an honest likelihood, and
publish the reachability reasoning there instead of discarding it.

**References.**

- **Plan decisions**
  - **D1** — each finding the reader is expected to act on leads with a plain-language explanation answering what goes
    wrong, what has to be true for it to happen, and how likely that is.
  - **D2** — corrective findings carry that explanation and advisory findings do not, because an advisory finding's
    stated reopen trigger already answers it.
  - **D3** — where the review already worked out that a failure mode cannot be reached, it publishes that reasoning
    instead of discarding it, and deriving the answers never changes a finding's severity.
  - **D4** — the review sources Han's standard for explaining work to a non-implementer before it drafts findings.
  - **D15** — security findings carry the explanation and keep the single remediation note their section already ends
    with, rather than gaining a second one.
- **Spec sections** — [A code review run](feature-specification.md#a-code-review-run) steps 3, 4, and 5,
  [A finding may never fire](feature-specification.md#a-finding-may-never-fire),
  [Edge Cases and Failure Modes](feature-specification.md#edge-cases-and-failure-modes) for the row on a finding whose
  likelihood is not in doubt, and [Out of Scope](feature-specification.md#out-of-scope) for what stays untouched.
- **Rule file** — `han-communication/references/explanation-rule.md`. See Shared reference artifacts.
- **Skill doc** — `han-coding/docs/skills/code-review.md`.

**Acceptance criteria.**

- [ ] Every critical, warning, suggestion, and security finding leads with a plain-language explanation answering three
      things: what someone could observe going wrong, what has to be true for it to happen, and how likely that is.
- [ ] The explanation answers all three. Where an answer is not in doubt, it is a clause rather than a sentence.
- [ ] The existing guidance for the engineer who will open the file follows the explanation and keeps its detail.
- [ ] Advisory findings carry no explanation, because their stated reopen trigger already says what it would say.
- [ ] A security finding carries the explanation and keeps the one remediation note its section already ends with. It
      gains no second one.
- [ ] Where the review already worked out that a failure mode cannot be reached, the explanation states that reasoning
      and says the finding is a no-op if the conditions do not hold.
- [ ] Working out a finding's preconditions and likelihood never changes its severity, its identifier, or its position
      in the report.
- [ ] The skill sources Han's standard for explaining work to a non-implementer before it drafts any finding.

**Depends on.** `None.`

## W-5 — Name how each finding gets fixed

**Summary.** After reading a finding, people ask which tool to reach for. The report already knows the answer, because
the shape of the fix follows from the finding. Asking costs a turn every time. This work has each actionable finding
name its own route to a fix.

**Work to be done.**

- Add the fix route to the finding block in the review's output template, beside the explanation.
  - Touch point: `han-coding/skills/code-review/references/template.md`.
- State the three routes in the skill body, along with the rule that naming a route is not starting it.
  - Touch point: `han-coding/skills/code-review/SKILL.md`.
  - The routes are Han's test-first path for a missing behavior, its restructuring path for a design change, and a hand
    edit for a small change. Name each as the reader would reach for it.
- Describe the route on the skill's long-form doc.

**Justification.** Improvement 5 of the issue's quoted "Suggested improvements", recorded in the boundary record: each
finding should name the route to fix it, because the user asks anyway.

**References.**

- **Plan decisions**
  - **D12** — each finding the reader is expected to act on names its fix route: written test-first as a missing
    behavior, restructured as a design change, or edited by hand.
  - **D15** — security findings carry the explanation but no separate fix route, because their section already ends with
    a remediation note.
- **Spec sections** — [A code review run](feature-specification.md#a-code-review-run) step 7, and
  [Coordinations](feature-specification.md#coordinations) for the row stating the route is named, never invoked.
- **Skill doc** — `han-coding/docs/skills/code-review.md`.

**Acceptance criteria.**

- [ ] Every critical, warning, and suggestion finding names how it gets fixed: written test-first as a missing behavior,
      restructured as a design change, or edited by hand.
- [ ] The route is named, never started. The review invokes nothing on the reader's behalf.
- [ ] Security findings carry no separate route, because their section already ends with a remediation note.
- [ ] Advisory findings carry no route, matching their existing treatment.

**Depends on.** `W-4`.

## W-6 — Put the fix route and the may-never-fire cue where a person triages

**Summary.** A person holding thirty findings scans the summary table first and reads the bodies afterwards. Knowing
that a finding may never fire, or that it is a one-line hand edit, sits inside the body where a scanner never reaches
it. So the reader works through findings that never needed their attention. This work brings both cues up to the table
and to each finding's opening line.

**Work to be done.**

- Carry the fix route and the may-never-fire cue into the report's summary table.
  - Touch point: `han-coding/skills/code-review/references/template.md`, the Review Summary table and the note declaring
    a table row an index entry rather than prose. Keep that note true.
- Put the may-never-fire cue on the finding's opening line as well, so a reader who opens the finding meets it first.
- Extend the structural verification that already checks the table lists every finding, so it also checks the new cells.
  - Touch point: `han-coding/skills/code-review/references/output-verification.md`, the item covering table
    completeness.
- Describe what the summary table now carries on the skill's long-form doc.

**Justification.** A necessity of improvements 1 and 5, as the specification adjusts them: the explanation and the route
only remove follow-up turns if a person triaging a long finding list sees them before opening any finding.

**References.**

- **Plan decisions**
  - **D16** — the likelihood cue and the fix route reach the report's summary table and the finding's opening line, not
    only the finding body, so triage happens before the reading.
- **Spec sections** — [A code review run](feature-specification.md#a-code-review-run) steps 6 and 7,
  [A finding may never fire](feature-specification.md#a-finding-may-never-fire),
  [User Interactions](feature-specification.md#user-interactions), and
  [Out of Scope](feature-specification.md#out-of-scope) for the finding identifiers and ordering that do not change.
- **Skill doc** — `han-coding/docs/skills/code-review.md`.

**Acceptance criteria.**

- [ ] Each row in the report's summary table carries the finding's fix route.
- [ ] A finding the review has established may never fire says so in its summary row and on its opening line.
- [ ] The summary table stays an index. It gains cues, not a second copy of each finding's prose.
- [ ] Finding identifiers, severities, and the order findings appear in are unchanged.
- [ ] The report's structural verification confirms the table carries the route and the cue for every finding that
      should have them.

**Depends on.** `W-4`, `W-5`.

## W-7 — Check the review's new required content before presenting it

**Summary.** The review already checks its own output before presenting it. Those checks cover the parts of the report
that existed before this work. The new explanation, the fix route, and the summary cues have nothing confirming they
arrived. This work adds them to the check the review already runs.

**Work to be done.**

- Add the new content checks to the review's existing verification list.
  - Touch point: `han-coding/skills/code-review/references/output-verification.md`. The structural list is where the
    other presence checks live, and the readability self-check beside it stays as it is.
- Keep the fix-before-presenting rule explicit, matching how the file already treats its other failures.
- Describe the check on the skill's long-form doc.

**Justification.** A necessity of improvements 1 and 5. A required piece of finding content with nothing checking for it
is a preference, and the review already runs a verification pass where the check belongs.

**References.**

- **Plan decisions**
  - **D17** — each skill checks that the newly required content is present before it presents, and fixes a failed check
    rather than shipping it.
- **Spec section** — [A code review run](feature-specification.md#a-code-review-run) step 9.
- **Skill doc** — `han-coding/docs/skills/code-review.md`.

**Acceptance criteria.**

- [ ] Before presenting, the review confirms every finding a reader is expected to act on carries the plain-language
      explanation.
- [ ] It confirms every such finding names a fix route, and that security findings carry the explanation without a
      separate route.
- [ ] It confirms each summary row carries the route and, where it applies, the may-never-fire cue.
- [ ] A failed check is corrected before the review is presented, rather than reported as a caveat.
- [ ] The existing checks over identifiers, references, sections, and readability continue to run unchanged.

**Depends on.** `W-4`, `W-5`, `W-6`.

## W-8 — Let the overview write where the person configured it to write

**Summary.** The overview always writes to a temporary location outside the repository. Someone who has told Han where
its output should go does not get that honored. The rule keeping the overview out of the repository was written as a
default and behaves as a prohibition. This work makes the configured location win and keeps the old behavior as the
fallback.

**Work to be done.**

- Resolve the overview's destination against the configured output location before it writes.
  - Touch point: `han-coding/skills/code-overview/SKILL.md`, the step that writes the scratch file. The skill already
    reads configuration in its Project Context block.
  - Precedence, path resolution, and unusable values are governed by the config rule.
- Reword the operating principle that fixes the file outside the repository, so it describes the skill's own default
  rather than forbidding the configured case.
- State the fallback for a resolved destination that cannot be written, so the closing message can name it.
- Update the long-form doc, which tells readers today that the file is always written outside the repository.
  - Touch point: `han-coding/docs/skills/code-overview.md`.

**Justification.** Improvement 2 of the issue's quoted "Suggested improvements", recorded in the boundary record:
resolve the destination through the config precedence chain in both skills, and drop the overview's "outside the
repository" prescription, which overrides it.

**References.**

- **Plan decisions**
  - **D5** — both skills resolve their output location through Han's configuration chain, and with nothing configured
    the overview keeps writing outside the repository.
- **Spec sections** — [A code overview run](feature-specification.md#a-code-overview-run) step 1, and
  [Edge Cases and Failure Modes](feature-specification.md#edge-cases-and-failure-modes) for the rows on an unconfigured
  default, a configured location inside the repository, and an unwritable destination.
- **Rule file** — `han-core/references/config-rule.md`. See Shared reference artifacts.
- **Skill doc** — `han-coding/docs/skills/code-overview.md`.

**Acceptance criteria.**

- [ ] The overview writes its document to the person's configured output location when one is set.
- [ ] With nothing configured, the overview writes outside the repository exactly as it does today.
- [ ] A configured location inside the repository is honored, and the run says nothing about it.
- [ ] A destination that cannot be written falls back to the unconfigured default, and the run names the destination it
      could not use.
- [ ] The skill's commitment not to be committed into the repository reads as a rule about its own default, not about
      what a person configures.

**Depends on.** `None.`

## W-9 — Make the overview's diagrams readable

**Summary.** The overview's diagrams are the one thing people complained about more than once. The pass that rewrites
the document for readability leaves diagram bodies alone, which is right for accuracy and leaves legibility to nobody.
Boxes end up carrying field names and types nobody can read at a glance. This work gives the template a rule about what
belongs in a box and moves the detail to the prose beneath.

**Work to be done.**

- Add the diagram rule to the overview template's shared rules, so both modes inherit it.
  - Touch point: `han-coding/skills/code-overview/references/overview-template.md`. The shared rules already govern
    chart scope labels, so the diagram rule sits beside them.
- State in the skill body that the skill owns diagram legibility, since the readability pass is exempt from diagram
  bodies by design.
  - Touch point: `han-coding/skills/code-overview/SKILL.md`.
- Describe the diagram rule on the skill's long-form doc.

**Justification.** Improvement 3 of the issue's quoted "Suggested improvements", recorded in the boundary record: add a
diagram rule to the overview template so nodes name components and boundaries rather than fields and types, and keep
diagram bodies exempt from the prose rewrite.

**References.**

- **Plan decisions**
  - **D9** — diagram legibility belongs to the overview skill and its template: boxes name components and boundaries,
    technical detail moves to the prose beneath, and the rewrite pass stays out of diagram bodies.
- **Spec sections** — [A code overview run](feature-specification.md#a-code-overview-run) step 3,
  [Edge Cases and Failure Modes](feature-specification.md#edge-cases-and-failure-modes) for the row on a diagram that
  cannot be simplified without losing a step, and [Out of Scope](feature-specification.md#out-of-scope) for the rewrite
  pass keeping its exemption.
- **Rule file** — `han-communication/references/readability-rule.md`, whose prose-only rule exempts diagram bodies. See
  Shared reference artifacts.
- **Skill doc** — `han-coding/docs/skills/code-overview.md`.

**Acceptance criteria.**

- [ ] The overview's template states that diagram boxes name components and boundaries.
- [ ] Fields, types, and technical annotations stay out of the boxes and appear in the prose beneath the diagram.
- [ ] A step the flow needs is never removed to make the diagram simpler. The step stays and its detail moves to the
      prose.
- [ ] The pass that rewrites the document for readability still leaves diagram bodies untouched.

**Depends on.** `None.`

## W-10 — Turn "Where to start" into an ordered path with an example call

**Summary.** The overview lists the right files to open first but not the order to open them in. A reader new to the
code has to guess where to begin. When the target is something other code calls, they also have to work out how to call
it. This work numbers the starting points and adds one example call where it applies.

**Work to be done.**

- Change the code-mode handoff section of the template so the entry points are numbered in reading order, each carrying
  what the reader learns there.
  - Touch point: `han-coding/skills/code-overview/references/overview-template.md`. Only the code mode has a
    "Where to start" section today. The change-explaining mode's handoff section stays as it is and keeps its
    navigational-only boundary.
- Add the rule for one runnable example call on a starting point that is an interface other code calls, judged per entry
  rather than per target.
- Bring the skill body's description of the code-mode section into line with the template.
  - Touch point: `han-coding/skills/code-overview/SKILL.md`, the synthesis step.
- Describe the ordered handoff on the skill's long-form doc.

**Justification.** Improvement 6 of the issue's quoted "Suggested improvements", recorded in the boundary record: number
the entry points in reading order with one line on what the reader learns at each, and include one runnable example call
when the target is an interface.

**References.**

- **Plan decisions**
  - **D13** — the starting points are numbered in reading order with one line each on what the reader learns, and a
    starting point that is an interface other code calls carries one runnable example call.
- **Spec sections** — [A code overview run](feature-specification.md#a-code-overview-run) step 5, and
  [Edge Cases and Failure Modes](feature-specification.md#edge-cases-and-failure-modes) for the row on a target holding
  both an interface and the flow behind it.
- **Skill doc** — `han-coding/docs/skills/code-overview.md`.

**Acceptance criteria.**

- [ ] The starting points are numbered in reading order rather than listed unordered.
- [ ] Each starting point carries one line on what the reader learns there.
- [ ] A starting point that is an interface other code calls carries one runnable example call.
- [ ] Each starting point is judged on its own, so a target holding both an interface and the flow behind it gets the
      example call on the interface only.

**Depends on.** `None.`

## W-11 — End every overview with a paragraph a person can paste

**Summary.** After reading an overview, people paste a plain summary into a pull request or a message to a reviewer. The
document holds no such paragraph, so they write one themselves or ask for it. The closing message the run prints leads
with facts about the run rather than with the answer. This work adds the pasteable paragraph to the document and puts it
at the front of the closing message.

**Work to be done.**

- Add the closing restatement as the last section of the overview document, in both modes.
  - Touch point: `han-coding/skills/code-overview/references/overview-template.md`.
- Reorder the closing message so the restatement leads it and facts about the run follow.
  - Touch point: `han-coding/skills/code-overview/SKILL.md`, the presenting step. The skill's existing rule against
    pasting the whole overview into the conversation stays.
  - Source `han-communication:explanation-guidance` before writing the restatement and the message.
- Have the closing message carry the document's own restatement rather than writing a second version of it.
- Describe the closing section and the message ordering on the skill's long-form doc.

**Justification.** Improvements 5 and 8 of the issue's quoted "Suggested improvements", recorded in the boundary record:
end every overview with three or four sentences a non-author could read aloud, because the reader's next action is
reliably to paste that somewhere, and lead the closing message with the answer.

**References.**

- **Plan decisions**
  - **D11** — the overview closes with three or four sentences a non-author could read aloud, carrying no file paths and
    no type names, and the closing message carries that restatement itself rather than a second version.
  - **D8** — both skills' closing messages lead with the answer rather than with facts about the run.
- **Spec sections** — [A code overview run](feature-specification.md#a-code-overview-run) steps 6 and 8,
  [Edge Cases and Failure Modes](feature-specification.md#edge-cases-and-failure-modes) for the row on a partial
  coverage note, and [User Interactions](feature-specification.md#user-interactions).
- **Rule file** — `han-communication/references/explanation-rule.md`. See Shared reference artifacts.
- **Skill doc** — `han-coding/docs/skills/code-overview.md`.

**Acceptance criteria.**

- [ ] The overview ends with three or four sentences a non-author could read aloud.
- [ ] Those sentences carry no file paths and no type names.
- [ ] The closing message leads with that restatement, followed by any divergence from the change's stated purpose, then
      the path.
- [ ] The closing message carries the document's own restatement rather than a separately written version of it.
- [ ] Facts about the run, such as the mode and size, come after the answer, and a partial-coverage note is named after
      the answer rather than before it.
- [ ] The skill sources Han's standard for explaining work to a non-implementer before it writes the restatement and the
      message.

**Depends on.** `W-8`.

## W-12 — Let the overview say when the code does not support a change's stated reason

**Summary.** When an overview explains a set of changes, it states the reason the change was made. Sometimes the code
shows that reason is already satisfied, or does not support it. The overview knows this and stays silent, which leaves
the reader holding a claim the evidence contradicts. This work lets the overview say so at the point it states the
reason.

**Work to be done.**

- Allow the change-explaining mode's why section to report a stated reason the code does not support, stated as a fact
  about the reason.
  - Touch points: `han-coding/skills/code-overview/SKILL.md`, the synthesis step's ordering for that mode, and the
    matching why section in `han-coding/skills/code-overview/references/overview-template.md`.
- Draw the line between this and the existing inferred-why path, so a reason the code is silent about is not reported as
  a contradiction.
  - The skill already requires the why to be grounded in evidence and marked as inferred when it is not. This addition
    needs the same evidence bar: the overview must have checked and found the contradiction.
- Keep the no-quality-judgment principle intact, and say why this addition does not cross it.
- Describe the behavior on the skill's long-form doc.

**Justification.** Improvement 7 of the issue's quoted "Suggested improvements", recorded in the boundary record: when
the code shows the stated motivation is already satisfied or that the change is not needed for the reason given, say so
in the why section as a fact about the why.

**References.**

- **Plan decisions**
  - **D14** — the overview may report that a change's stated reason is not supported by the code, as a fact about the
    reason rather than as a finding about the code.
- **Spec sections** —
  [The code contradicts the stated reason for a change](feature-specification.md#the-code-contradicts-the-stated-reason-for-a-change),
  and [Out of Scope](feature-specification.md#out-of-scope) for the overview still making no quality judgment.
- **Boundary record** — `artifacts/scope-boundary.md` carries the recorded constraint on this improvement: keep the
  quality boundary. See Shared reference artifacts.
- **Skill doc** — `han-coding/docs/skills/code-overview.md`.

**Acceptance criteria.**

- [ ] When the overview has checked the stated reason against the code and found that the code already satisfies it or
      does not support it, it says so in the section that states the reason.
- [ ] The statement is a fact about the stated reason. The overview raises no finding, assigns no severity, and
      recommends no change.
- [ ] The rest of the overview proceeds as normal.
- [ ] A stated reason the code says nothing about either way keeps its existing treatment: the reason is marked as
      inferred and no discrepancy is claimed.
- [ ] The overview's rule against judging the code's quality still holds and is not weakened by this addition.

**Depends on.** `None.`

## W-13 — Check the overview's new required content before presenting it

**Summary.** The overview checks its own accuracy and readability before presenting. Nothing confirms the new content
arrived. The diagrams, the ordered starting points, the explained terms, and the closing paragraph could all go missing
without anyone noticing until a reader complains. This work extends the check the overview already runs.

**Work to be done.**

- Extend the overview's pre-presentation self-check to cover the newly required content.
  - Touch point: `han-coding/skills/code-overview/SKILL.md`, alongside the readability self-check that runs after the
    rewrite pass.
- Keep the check ordered after the accuracy pass, so it never confirms content that is about to be corrected.
- Describe the check on the skill's long-form doc.

**Justification.** A necessity of improvements 3, 4, 5, and 6. Each adds required content to the overview, and the
overview already runs a self-check before presenting, which is where a presence check belongs.

**References.**

- **Plan decisions**
  - **D17** — each skill checks that the newly required content is present before it presents, and fixes a failed check
    rather than shipping it.
- **Spec section** — [A code overview run](feature-specification.md#a-code-overview-run) step 7.
- **Rule file** — `han-communication/references/readability-rule.md`, whose prose-only rule scopes what the check may
  read. See Shared reference artifacts.
- **Skill doc** — `han-coding/docs/skills/code-overview.md`.

**Acceptance criteria.**

- [ ] Before presenting, the overview checks its diagrams against the legibility rule.
- [ ] It checks that the starting points are in reading order, and that an interface starting point carries its example
      call.
- [ ] It checks that terms a reader cannot look up carry their explanations.
- [ ] It checks that the closing restatement is present and carries no file paths and no type names.
- [ ] A failed check is fixed before the overview is presented.
- [ ] The check covers prose regions and diagram box labels only. Code fences and screenshot markup stay outside it,
      because the shared standard exempts them.

**Depends on.** `W-1`, `W-9`, `W-10`, `W-11`.

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. There is no trigger that reopens an entry
here; the recorded boundary already settled it.

- **Every other Han skill honoring the configured output location, so a person's configured destination is honored
  everywhere rather than in these two skills alone.** The recorded boundary in
  [artifacts/scope-boundary.md](artifacts/scope-boundary.md) names two skills. Only the Atlassian skills consume the
  configured output location today, so the same gap likely exists elsewhere. The work item is a retrospective on code
  review and code overview, and its stated scope covers those two. Carried forward from the specification's
  [Cut for Scope](feature-specification.md#cut-for-scope) section.
- **The same plain-language explanation in the other skills the issue quotes, so their output would answer the same
  question this work answers for these two.** The issue quotes people asking other skills for plain-language summaries
  and offers those quotes as evidence that the gap is shared rather than local. They are corroboration for the finding,
  not items in the stated scope recorded in [artifacts/scope-boundary.md](artifacts/scope-boundary.md), which names
  improvements to code review and code overview only. Carried forward from the specification's
  [Cut for Scope](feature-specification.md#cut-for-scope) section.
- **A sweep over the Han documents already written, adding the explanations the widened writing standard from W-1 now
  asks for.** The specification's [Out of Scope](feature-specification.md#out-of-scope) section rules it out by name:
  every skill sourcing the shared standard gains the rule, and nothing here checks what that does to their output. The
  standard also applies at generation time, so a document already committed is not re-checked by design. W-1 puts the
  rule and its enforcer in place; auditing what already exists is separate work.
