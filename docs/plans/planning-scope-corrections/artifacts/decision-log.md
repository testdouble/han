# Decision Log: Planning Scope Corrections

<!--
This file records every decision settled while specifying Planning Scope Corrections.
Behavioral statements live in [../feature-specification.md](../feature-specification.md).
Findings live in [team-findings.md](team-findings.md); load-bearing mechanics live in
[feature-technical-notes.md](feature-technical-notes.md).

Source issues: testdouble/han #155 (plan-a-feature), #156 and #157 (plan-implementation),
#158 (plan-work-items). Issue #157 is the compiled report and supersedes #156 where the
two overlap; every #156 improvement also appears in #157.
-->

## Trivial decisions

- D4: Unjustifiable work is reported, never re-justified from another item — when a proposed unit cannot be justified
  from the work item in hand, the run reports it as unjustified rather than searching for a different item that
  supports it (considered allowing a supporting item to be cited; rejected because the reported run built a confident
  and wrong history that way). — Referenced in spec: Alternate Flows and States, Edge Cases and Failure Modes.
- D7: Existence is established before packaging — no skill proposes pull-request splits, phasing, or sequencing for a
  unit whose justification is unrecorded (considered leaving the order to the run's judgment; rejected because the
  reported run packaged work it could not justify). — Referenced in spec: Coordinations.
- D14: The specification emits the visual reference table and the inline placements the downstream inventory already
  reads — a table listing each image with the state it shows, and each image placed beside the prose describing that
  state (considered a table only; rejected because the consumer contract names both as its mapping source). —
  Referenced in spec: Coordinations.
- D16: The findings record names evidence classes no reviewer could audit — when decisions rest on material no
  reviewer received, the record says so. — Referenced in spec: Edge Cases and Failure Modes.
- D21: Each recorded finding carries the originating reviewer's own identifier — the identifier the reviewer assigned
  is a field on the finding (considered reconciling the two lists by hand at synthesis; rejected because that is what
  lost a finding in the reported run). — Referenced in spec: Edge Cases and Failure Modes.
- D26: `han-feedback` treats a same-day file as updatable, not closed — when the session continued past an existing
  same-day file, or the operator asks for a compiled report, the file is updated in place and the update is stated. —
  Referenced in spec: Edge Cases and Failure Modes.
- D29: `han-feedback` names a blocked-by-environment publish case — the run says the environment refused rather than
  that the run declined, does not retry the identical command, and hands over a copy-pasteable command. — Referenced
  in spec: Edge Cases and Failure Modes.
- D30: The justification is a structured field, not summary prose — it sits beside the references so the existing rule
  that a work item's summary carries no identifier references stays intact. — Referenced in spec: Coordinations.

## Full decisions

### D1: Scope of the change set

- **Question:** Which skills and plugins does this specification cover?
- **Decision:** The four planning skills (`plan-a-feature`, `plan-implementation`, `plan-a-phased-build`,
  `plan-work-items`), the two `han-feedback` corrections, and one new shared standard in `han-communication` for
  explaining technical work to a reader who will not implement it.
- **Rationale:** The reported runs name all three areas, and the fixes interlock. The escalation register and the
  feedback-skill corrections both govern how a run talks to the operator, so specifying them apart would risk the
  contradictions this specification exists to prevent.
- **Evidence:** User input (scope confirmed directly). Provided: issues #155, #156, #157, #158; #157 names
  `plan-implementation`, `plan-a-feature`, and `plan-a-phased-build` together and adds two `han-feedback` items, and
  #158 names `plan-a-feature`, `plan-implementation`, and `plan-work-items`.
- **Rejected alternatives:**
  - Planning skills only — rejected because the escalation-register fix would then carry its own inline guidance
    rather than sourcing a shared one, which is the duplication this repository's one-canonical-source convention
    exists to prevent.
  - Planning skills plus `han-communication`, deferring the feedback fixes — rejected because the two feedback items
    are small, already specified in the source issue, and cost nothing to carry.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D13, D26, D29
- **Referenced in spec:** Actors and Triggers

### D2: The work item is read and recorded as the scope boundary

- **Question:** What establishes the outer boundary of a planning run?
- **Decision:** Before any context discovery or agent dispatch, the skill identifies the work item this work descends
  from, reads it, and records its stated scope and its stated exclusions word for word in the run's context artifact.
  Where no work item exists, it records that explicitly along with the statement that the operator's request is the
  only boundary.
- **Rationale:** This is the cheapest fix available and it prevents the whole failure chain in the reported runs. One
  read, before any agent runs. Recording the no-work-item case explicitly matters because a run with no external
  boundary is a materially different situation that should be visible rather than assumed.
- **Evidence:** Provided: #157 improvement 1 and its section "The work item is never read, so the specification
  becomes the scope authority"; #156 improvement 1. Codebase: `plan-implementation` Step 1 locates the specification
  and Step 2 discovers implementation context, and neither mentions the originating item; `plan-a-feature` Step 1
  reads the user's argument and Step 2 discovers project context, with the same gap.
- **Rejected alternatives:**
  - Reading the work item only when the operator names one — rejected because the reported run had a work item
    available and never opened it.
  - Treating the upstream specification as the boundary — rejected because that is the failure being corrected.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D3, D4, D5, D6, D8, D9, D11
- **Referenced in spec:** Primary Flow, Alternate Flows and States

### D3: The work-item read does not traverse outward

- **Question:** May a run follow a work item's links, parent epic, or closed sibling items to find justification?
- **Decision:** No. The read is bounded to the item itself. The parent is read only to confirm it exists and note its
  name. A linked, sibling, or closed item is not scope evidence for the current one, and its description is not
  evidence about the current one's platform, status, or intent.
- **Rationale:** Searching outward for justification is what produced the worst error in the reported session. The
  run cited a mobile-only item as justification for web work by reading its description and never checking its
  component field, and read a second item as a deletion of prior work when it was the direction of travel.
- **Evidence:** Provided: #157 improvement 2 and its section "I read unrelated work items and built an inference
  chain from them".
- **Rejected alternatives:**
  - Allowing traversal with a requirement to check the platform or component field first — rejected because it keeps
    the anti-pattern and adds a check the run already skipped once. The simpler version, banning the traversal,
    satisfies the same evidence.
  - Banning all reference to the parent item — rejected because confirming the parent exists is cheap and orients the
    reader without supplying scope.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D4
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### D5: Direction of travel is asked once, alongside the work-item confirmation

- **Question:** How does a run learn whether the code it touches is being deprecated, replaced, or migrated away
  from?
- **Decision:** The skill asks the operator one question about direction of travel in the same turn that confirms the
  work item, and records the answer, including "not known", in the context artifact so later skills inherit it.
- **Rationale:** The answer is not derivable from code and appears in no artifact the skills read, yet it changes
  whether work is merely out of scope or actively wrong. Bundling it with the work-item turn costs no extra round
  trip, which matters given that the same reports fault the runs for spending too many of the operator's turns.
- **Evidence:** User input (bundling confirmed directly). Provided: #157 improvement 6, which records that the run
  did not know the domain object involved was being deprecated.
- **Rejected alternatives:**
  - Asking only when the code carries deprecation markers — rejected because the case that caused the failure left no
    marker the run could find.
  - A dedicated turn of its own — rejected because it adds a round trip to every planning run for a question that
    fits in an existing turn.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

### D6: Every work unit names what it descends from

- **Question:** How does scope creep become visible in the artifact rather than only in review?
- **Decision:** Every work unit and every work item carries a justification field naming the work-item language or the
  design artifact it descends from. A unit that cannot fill it is not written into the plan; it moves to a visible cut
  list with the reason.
- **Rationale:** A required field turns creep into something a reader can see. The cut list preserves the record of
  what was considered and dropped, which a silent omission destroys.
- **Evidence:** User input (strictness confirmed directly). Provided: #157 improvements 3 and 10.
- **Rejected alternatives:**
  - A required field with no cut section — rejected because the cut becomes invisible and the reader loses the record
    of what was considered.
  - An advisory field — rejected because it leaves creep detection to review, which is what failed four times in the
    reported session.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D7, D30
- **Referenced in spec:** Primary Flow, Alternate Flows and States

### D8: The YAGNI sweep gains a scope gate covering inherited commitments

- **Question:** Does the YAGNI sweep cover commitments the plan inherited from an upstream document?
- **Decision:** Yes. The sweep walks every subsystem, integration, and artifact the plan touches, including everything
  inherited, against one question: does the work item ask for this, or exclude it by statement or by silence? An
  inherited commitment no work item supports is deferred or cut, with the citation.
- **Rationale:** The rule's enumerated targets are all things the plan might add, and the sweep walks only what the
  loop produced. Scope arriving pre-committed from an upstream document is never swept, which is exactly the
  inheritance that needed a filter.
- **Evidence:** Provided: #157 section 4 and improvement 4; #156 improvement 2. Codebase: the YAGNI rule's
  anti-pattern list covers abstractions, configuration knobs, observability, runbooks, infrastructure, rollout
  machinery, test scaffolding, schema columns, and indexes, and `plan-implementation`'s operating principles state
  that the plan "inherits the spec's behavioral commitments".
- **Rejected alternatives:**
  - Adding the scope question to the shared YAGNI rule itself — rejected because the rule is vendored across plugins
    and applies to code and coding standards too, where "the work item" has no referent. The gate belongs to the
    planning skills that have a work item.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D9
- **Referenced in spec:** Primary Flow

### D9: An upstream specification is an artifact, not a scope authority

- **Question:** How far may a plan-stage skill disagree with the specification it was given?
- **Decision:** A plan-stage skill may cut a specification commitment the work item excludes, by statement or by
  silence, citing the work item. It may not re-open behavior the work item does cover. The license is narrow and
  scoped to what the work item excludes.
- **Rationale:** Declaring the specification "ground truth" made it unfalsifiable on scope, and left no path to the
  verdict "this is not part of this work". Specifications drift beyond their work item, and the upstream one in the
  reported session did. Scoping the license to exclusions is the strictly simpler version that satisfies the same
  evidence: it fixes the scope failure without inviting wholesale re-litigation of settled behavior.
- **Evidence:** Provided: #157 section 3 and improvement 12; #156 improvement 7. Codebase: `plan-implementation`'s
  operating principle "The feature specification is the ground truth for _what_. Do not re-open behavioral decisions
  the specification already settled."
- **Rejected alternatives:**
  - A general license to challenge any specification claim — rejected because it reopens the settled-behavior debates
    the current principle correctly prevents, and no reported evidence asks for it.
  - Leaving the principle unchanged and relying on the scope gate alone — rejected because the principle would still
    contradict the gate, which is the kind of two-rules-one-situation conflict this change set exists to remove.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D10, D11
- **Referenced in spec:** Alternate Flows and States, Out of Scope

### D10: The mechanic-contradiction protocol gains an out-of-scope verdict

- **Question:** What does a specialist do when it believes a committed mechanic should not exist at all?
- **Decision:** A third verdict sits beside confirm and contradict: out of scope for this work item, resolved by
  citing the work item rather than by escalating to the operator. The same third verdict applies to specification
  decisions, not only to technical notes.
- **Rationale:** The contradiction protocol demands the specialist name the alternative mechanic they recommend, which
  forces someone who thinks the mechanic should not exist to invent a replacement. The protocol assumes the answer is
  a different implementation, never no implementation.
- **Evidence:** Provided: #157 improvement 5; #156 improvement 3. Codebase: `plan-implementation` Step 4 instructs
  specialists to raise disagreement as a contradiction finding that "names the alternative mechanic they recommend".
- **Rejected alternatives:**
  - Letting the specialist raise it as a generic finding — rejected because the aggregation classifies findings by
    text rules, so an unnamed verdict would route back into the escalation path this decision exists to avoid.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States

### D11: A question the work item already answers is never escalated

- **Question:** May a run escalate a question the work item settles?
- **Decision:** No. The existing evidence-first directive that covers the specification extends to the work item, plus
  its inverse: when the work item places the question outside scope, the resolution is to cut the item and record why,
  not to ask the operator to pick an option.
- **Rationale:** The reported run turned a correct finding into a three-option question with a recommendation when the
  evidence collapsed it to one line and no decision. The inverse half is the load-bearing half: without it, an
  out-of-scope finding still reaches the operator as a choice.
- **Evidence:** Provided: #157 improvement 7 and section 2; #156 improvement 4. Codebase: `plan-implementation`
  Step 4 already carries the evidence-first directive for the specification.
- **Rejected alternatives:**
  - Extending only the forward half, so a work-item-answered question is not raised — rejected because it leaves the
    out-of-scope case escalating, which is the case that cost the operator turns.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States

### D12: Escalations are one question at a time, led by plain language

- **Question:** What shape does an escalation take?
- **Decision:** One question per turn by default. Each leads with the consequence in plain language, as a person who
  will not read the code would describe it. Paths, identifiers, and line numbers sit below the question or are left
  out entirely.
- **Rationale:** The current guidance specifies what an escalation must contain and says nothing about register or
  batch size, while explicitly inviting a batch. Following it produced four questions each leading with a file path
  and a line number, which the operator rejected outright. The operator's own correction is a better specification
  than the skill's.
- **Evidence:** Provided: #157 improvement 8 and section 7; #156 improvement 5. Codebase: `plan-implementation`
  Step 6 lists the required contents of an escalation and caps it at "a focused batch".
- **Rejected alternatives:**
  - Keeping the batch and adding a register rule — rejected because the reported failure was the batch as much as the
    register, and the operator asked for one issue at a time by name.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D13
- **Referenced in spec:** Primary Flow, User Interactions

### D13: A shared standard covers explaining technical work to a non-implementer

- **Question:** Where does the guidance live for explaining technical work to a reader who will not implement it?
- **Decision:** A new standard in `han-communication`, sourced by every escalating skill. It bans invented shorthand
  for concepts the reader has not been given, and requires a concrete worked example in place of describing a
  mechanism: a named thing, a real starting value, what the person enters, and the specific wrong result they would
  see.
- **Rationale:** Every planning skill escalates to this reader and none offers guidance for it. `han-communication` is
  the foundational plugin that already owns the readability standard and the writing-voice profile, and every
  prose-producing plugin already depends on it, so the standard reaches every escalating skill with no new dependency.
  The worked example is the one thing that worked after two failures in the reported session.
- **Evidence:** User input (scope confirmed directly). Provided: #157 improvement 9 and section 8. Codebase:
  `han-communication` owns the canonical readability rule and writing-voice profile with no vendored copies, and the
  planning skills already source them by invoking `han-communication:readability-guidance`.
- **Rejected alternatives:**
  - Inline guidance in each escalating skill — rejected because it duplicates the same content across at least four
    skills, against this repository's one-canonical-source convention.
  - A full skill with its own dispatch and agent — rejected under the simpler-version test; the evidence is that
    escalations were written in jargon, not that a separate rewrite pass was missing. Recorded as a deferral.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** User Interactions, Coordinations

### D15: Provided visual material is persisted when it arrives

- **Question:** When and where does visual material the operator supplies get written to disk?
- **Decision:** The skill writes it into a `ui-designs/` folder beside the plan as soon as it arrives, under a
  descriptive name for the state each image depicts. Not at document-write time.
- **Rationale:** The session context is the only copy until this happens, and "later" does not survive a session
  boundary or a compaction. In the reported session the design frames that specified a card's appearance were lost
  entirely: eleven artifacts and roughly 450KB of markdown, and zero image files. The interaction contract survived in
  prose; the visual contract did not.
- **Evidence:** Provided: #158 improvement 1 and its section "Nothing writes pasted images to disk, and the loss is
  silent and total". Codebase: `plan-work-items` requires design references for UI-bearing work items whenever a
  `ui-designs/` folder is present, and no skill in the family creates that folder.
- **Rejected alternatives:**
  - Persisting at document-write time — rejected because the loss window is the whole run, and a compaction inside it
    destroys the material before the write.
  - Recording the material's absence in prose and continuing — rejected because that is what the earlier run did, and
    it produced an artifact that looks like it accounted for the problem.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** D14, D17, D18, D24, D27
- **Referenced in spec:** Primary Flow

### D17: A completeness gate confirms visual material reached disk

- **Question:** What catches an image that was supplied but never persisted?
- **Decision:** Before declaring a specification or plan finished, the skill confirms that any visual material the
  session received exists on disk beside the plan.
- **Rationale:** An unpersisted image is a silent failure today. The gate makes it a loud one while the material is
  still in context and recoverable.
- **Evidence:** Provided: #158 improvement 3.
- **Rejected alternatives:**
  - Relying on the persist-on-arrival rule alone — rejected because the reported failure class is exactly a rule that
    was never executed, and the gate costs one check.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

### D18: Provided visual material reaches every dispatched reviewer

- **Question:** Which reviewers receive the operator's visual material?
- **Decision:** All of them. The paths to the persisted material go into every dispatched reviewer's brief, alongside
  the existing directive that passes the artifact paths, with an instruction to read them.
- **Rationale:** The current briefing instructions name the specification sections each specialist receives and never
  mention visual material, so it was not passed. A design specialist reviewing a design-driven feature was reduced to
  reviewing a paraphrase, and roughly eight decisions citing the designs as evidence could not be audited by anyone.
  The standing instruction belongs beside the existing pass-the-artifact-paths directive rather than inside the
  per-specialist table, because which specialist is most harmed by the omission varies by feature.
- **Evidence:** Provided: #155 improvement 1 and its section "The design reviewer was dispatched without the designs,
  and the skill's briefing instructions are why". Codebase: `plan-a-feature` Step 6 specifies each specialist's brief
  as a set of specification sections plus artifact file paths, with no mention of visual material.
- **Rejected alternatives:**
  - Passing the material only to the design specialist — rejected because the blind spot is wider than one
    specialist, and which reviewer needs it varies by feature.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

### D19: An uninspected input strips blocking severity from the findings that rest on it

- **Question:** What happens to a finding whose author recorded that it could not inspect a relevant input?
- **Decision:** Every finding depending on that input is labeled unverified, and cannot carry build-blocking severity.
  The disclosure travels attached to the finding rather than sitting in a separate assumptions section.
- **Rationale:** The reviewer in the reported session did disclose its blindness, in an assumptions section well below
  a finding it recommended treating as blocking. The disclosure existed and did not travel where it was needed.
- **Evidence:** Provided: #155 improvement 2 and its section "That produced a wrong finding, which I then promoted to
  a blocking open item".
- **Rejected alternatives:**
  - Requiring the reviewer to omit the finding entirely — rejected because the finding may still be real, and
    discarding it loses information the dispatching skill can verify itself.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D20
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D20: Design-dependent findings are checked against the designs before filing

- **Question:** Who verifies a finding that turns on visual material the dispatching skill holds?
- **Decision:** The dispatching skill does, during its finding-resolution pass, before the finding becomes an open
  item.
- **Rationale:** In the reported session all five frames answered the flagged question directly and consistently, and
  the run had them and did not re-read them. One rule in the resolution pass catches this with no agent change at all.
- **Evidence:** Provided: #155 improvement 3.
- **Rejected alternatives:**
  - Relying on the unverified label alone — rejected because an unverified finding still reaches the operator, and
    the check is nearly free when the material is already on disk.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

### D22: Decisions are classified once, after the review round

- **Question:** When is a decision classified as full or trivial?
- **Decision:** Once, after the review round returns.
- **Rationale:** Two of the promotion signals, a driving finding and a linked technical note, cannot exist at draft
  time, so classifying before the round guarantees re-classification. In the reported session three decisions were
  written as trivial bullets, promoted by synthesis, and one was then edited again.
- **Evidence:** Provided: #155 improvement 6 and its section "The trivial-versus-full decision split caused rework".
  Codebase: the decision-log template lists five promotion signals, two of which are the driving finding and the
  linked technical note.
- **Rejected alternatives:**
  - Keeping classification at draft time and accepting the churn — rejected because the churn is guaranteed by
    construction, not occasional.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes

### D23: The two missing-artifact rules are reconciled and split by who can supply the artifact

- **Question:** What does a skill do when an expected artifact is missing?
- **Decision:** One rule, stated in one place, split by who can supply the artifact. For an artifact the operator can
  produce on demand, surface it before drafting and ask once. For an artifact nobody can produce now, note it in the
  report, draft around it, and flag what it blocks. Every other mention references that one statement.
- **Rationale:** Today the skill step and its own linked reference give opposite instructions for the same situation,
  which forces the run to pick. Picking is not something a skill should leave to the run.
- **Evidence:** Provided: #158 improvement 5 and its section "The two missing-artifact rules contradict each other".
  Codebase: `plan-work-items` Step 4 says to note a missing artifact in the report rather than stopping, while its
  linked artifact-inventory reference says to surface it to the user before drafting because dependent work items are
  not draftable.
- **Rejected alternatives:**
  - Deleting one of the two rules — rejected because both describe real and different situations; the defect is that
    neither names which situation it covers.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D25, D27
- **Referenced in spec:** Edge Cases and Failure Modes

### D24: The visual-material convention lives in one han-planning reference

- **Question:** Where is the `ui-designs/` folder convention defined?
- **Decision:** In a new reference file owned by `han-planning`, cited by every planning skill that produces or
  consumes visual material.
- **Rationale:** The convention exists today only inside one consumer's reference file, which is why no producer
  honors it. Producer and consumer reading one source is what stops the two sides from drifting apart again.
- **Evidence:** User input (home confirmed directly). Provided: #158 improvement 7 and its section "The downstream
  mapping mechanism assumes an upstream step that no upstream skill performs". Codebase: the convention appears only
  in `plan-work-items`'s reference-artifact-inventory reference, and `han-planning/references/` currently holds only
  vendored copies of the shared rules.
- **Rejected alternatives:**
  - Canonical in `han-core` and vendored into each plugin — rejected because it puts a planning-only convention in
    the shared foundation and adds a vendored copy to keep byte-identical.
  - Kept inside `plan-a-feature` and linked cross-skill by the others — rejected because it creates a cross-skill
    reference dependency this repository does not otherwise use.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Coordinations

### D25: A single stop is reserved for an input only the operator can supply

- **Question:** How does the autonomy principle handle a missing input the operator could hand over right now?
- **Decision:** A skill stops exactly once when the missing input is something only the operator can supply and its
  absence degrades the deliverable. It names what is missing, names the cost of continuing without it, and offers to
  continue. Everything else stays autonomous.
- **Rationale:** The current principle collapses three different situations: an input nobody can produce, a decision
  with a reasonable default, and an input the operator can supply cheaply right now. Only the third deserves a
  question, and bounding it to one keeps the rule from becoming a general license to pause, which would work against
  the turn-efficiency the same reports ask for.
- **Evidence:** User input (stop rule confirmed directly). Provided: #158 improvement 6 and its section "The autonomy
  principle argues against the correct behavior here". Codebase: `plan-work-items`'s operating principle stops for the
  user only when the skill "genuinely cannot continue without input".
- **Rejected alternatives:**
  - Never stopping and reporting the gap loudly instead — rejected because the reported failure is exactly a run that
    continued and produced work items for a visual card with no visual contract.
  - Stopping whenever any expected artifact is missing — rejected because it reintroduces gating on inputs nobody can
    produce right now.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D27
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### D27: `plan-work-items` separates no visual surface from visual work with no designs

- **Question:** How does the work-item skill treat an absent visual-material folder?
- **Decision:** As two different situations. No visual surface means the design-reference block is omitted. Visual
  work with no material available is a missing artifact, reported as one, with a note that the upstream skill may not
  have persisted it and that the operator can supply it now.
- **Rationale:** The template today treats an absent folder purely as a condition for omitting a block, so the run
  wrote one line about it and moved on. One line of output for a total loss of the visual specification is the wrong
  proportion.
- **Evidence:** Provided: #158 improvement 4 and its section "I under-reacted to my own missing-artifact check".
  Codebase: the work-item template's design-reference block is written as omitted when no `ui-designs/` folder exists.
- **Rejected alternatives:**
  - Treating every absent folder as a missing artifact — rejected because most work items have no visual surface, and
    it would produce a false report on each one.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States

### D28: Output volume scales to the size of the work item

- **Question:** What keeps reviewer output proportionate to the work being planned?
- **Decision:** The work item's size is passed into every reviewer brief as a stated proportionality signal, separate
  from the existing team-size bands. It governs how much a reviewer writes, never how many reviewers are chosen.
- **Rationale:** Report length scales with nothing today. The round cap scales with team size, and nothing scales with
  the size of the thing being built, so a three-sentence ticket that adds one card drew four reports totalling roughly
  three thousand lines. Keeping the signal separate from team sizing avoids trading review coverage for brevity, which
  none of the reports asked for.
- **Evidence:** Provided: #157 improvement 11 and its section 9; #156 improvement 6; #155's section on
  disproportionate output volume. Codebase: `plan-implementation` Step 3 sets team and round caps by size band, and
  no step constrains report length.
- **Rejected alternatives:**
  - Shrinking the team caps — rejected because the reports rate finding signal-to-noise at four out of five and name
    volume, not coverage, as the complaint.
  - A hard line limit per report — rejected because it caps the useful and the padded alike; a stated signal lets the
    reviewer judge.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Out of Scope, Coordinations
