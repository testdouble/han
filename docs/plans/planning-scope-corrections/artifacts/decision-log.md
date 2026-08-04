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

Each bullet below records the decision, the alternative considered where there was one, and the same four
cross-reference fields the full decisions carry.

- **D4: Unjustifiable work is reported, never re-justified from another item.** When a proposed unit cannot be
  justified from the work item in hand, the run reports it as unjustified rather than searching for a different item
  that supports it. Considered allowing a supporting item to be cited; rejected because the reported run built a
  confident and wrong history that way. Driven by findings: none. Linked technical notes: none. Dependent decisions:
  none. Referenced in spec: Alternate Flows and States, Edge Cases and Failure Modes.
- **D7: Existence is established before packaging.** No skill proposes pull-request splits, phasing, or sequencing for
  a unit whose justification is unrecorded. Considered leaving the order to the run's judgment; rejected because the
  reported run packaged work it could not justify. Driven by findings: none. Linked technical notes: none. Dependent
  decisions: none. Referenced in spec: Coordinations.
- **D14: The specification emits the visual reference table and the inline placements the downstream inventory already
  reads.** A table listing each image with the state it shows, and each image placed beside the prose describing that
  state. Considered a table only; rejected because the consumer contract names both as its mapping source. Driven by
  findings: none. Linked technical notes: none. Dependent decisions: none. Referenced in spec: Actors and Triggers, Coordinations.
- **D16: The findings record names evidence classes no reviewer could audit.** When decisions rest on material no
  reviewer received, the record says so. Driven by findings: none. Linked technical notes: none. Dependent decisions:
  none. Referenced in spec: Actors and Triggers, Edge Cases and Failure Modes.
- **D21: Each recorded finding carries the originating reviewer's own identifier.** The identifier the reviewer
  assigned is a field on the finding, and a finding raised by two reviewers merges into one record carrying both
  identifiers. Considered reconciling the two lists by hand at synthesis; rejected because that is what lost a finding
  in the reported run. Driven by findings: F16. Linked technical notes: none. Dependent decisions: none. Referenced in
  spec: Actors and Triggers, Edge Cases and Failure Modes.
- **D26: `han-feedback` treats a same-day file as updatable, not closed.** When the session continued past an existing
  same-day file, or the operator asks for a compiled report, the file is updated in place and the update is stated.
  Driven by findings: none. Linked technical notes: none. Dependent decisions: none. Referenced in spec: Edge Cases
  and Failure Modes.
- **D29: `han-feedback` names a blocked-by-environment publish case.** The run says the environment refused rather
  than that the run declined, does not retry the identical command, and hands over a copy-pasteable command. Driven by
  findings: none. Linked technical notes: none. Dependent decisions: none. Referenced in spec: Edge Cases and Failure
  Modes.
- **D30: The justification is a structured field, not summary prose.** It sits beside the references so the existing
  rule that a work item's summary carries no identifier references stays intact. Driven by findings: none. Linked
  technical notes: none. Dependent decisions: none. Referenced in spec: Coordinations.

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
  - Planning skills only. Rejected because the escalation-register fix would then carry its own inline guidance
    rather than sourcing a shared one, which is the duplication this repository's one-canonical-source convention
    exists to prevent.
  - Planning skills plus `han-communication`, deferring the feedback fixes. Rejected because the two feedback items
    are small, already specified in the source issue, and cost nothing to carry.
- **Linked technical notes:** None
- **Driven by findings:** None
- **Dependent decisions:** D13, D26, D29
- **Referenced in spec:** Outcome

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
  - Reading the work item only when the operator names one. Rejected because the reported run had a work item
    available and never opened it.
  - Treating the upstream specification as the boundary. Rejected because that is the failure being corrected.
- **Linked technical notes:** None
- **Driven by findings:** F4, F5
- **Dependent decisions:** D3, D4, D5, D6, D8, D9, D11, D33, D34
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
  - Allowing traversal with a requirement to check the platform or component field first. Rejected because it keeps
    the anti-pattern and adds a check the run already skipped once. The simpler version, banning the traversal,
    satisfies the same evidence.
  - Banning all reference to the parent item. Rejected because confirming the parent exists is cheap and orients the
    reader without supplying scope.
- **Linked technical notes:** None
- **Driven by findings:** None
- **Dependent decisions:** D4
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### D5: Direction of travel is asked once, alongside the work-item confirmation

- **Question:** How does a run learn whether the code it touches is being deprecated, replaced, or migrated away
  from?
- **Decision:** The skill asks the operator one question about direction of travel in the opening confirmation turn,
  naming its subjects from the work item it has already read rather than asking in the abstract, and records the
  answer in the boundary record so later skills inherit it. A recorded deprecation is treated by the scope sweep the
  same way a stated exclusion is treated. An unanswered question is recorded as unanswered, which is a different state
  from a recorded "not known".
- **Rationale:** The answer is not derivable from code and appears in no artifact the skills read, yet it changes
  whether work is merely out of scope or actively wrong. Bundling it with the work-item turn costs no extra round
  trip, which matters given that the same reports fault the runs for spending too many of the operator's turns. Naming
  the subjects converts a recall task with no cue into a recognition task, which is what makes the question
  answerable. Wiring the answer to the sweep is what makes the turn worth spending: without it the run collects an
  input it never uses.
- **Evidence:** User input (bundling confirmed directly). Provided: #157 improvement 6 and section 5, which records
  that the run did not know the domain object involved was being deprecated and that this made the work "actively
  wrong rather than merely out of scope".
- **Rejected alternatives:**
  - Asking only when the code carries deprecation markers. Rejected because the case that caused the failure left no
    marker the run could find.
  - A dedicated turn of its own. Rejected because it adds a round trip to every planning run for a question that
    fits in an existing turn.
  - Deferring the question entirely, on the grounds that D3 and D4 already stop the outward search that made the
    deprecation matter. Rejected because the deprecation makes the work wrong on its own, not only when the run has
    wandered. Once wired to the sweep the question passes the evidence test rather than recording an unused input.
- **Linked technical notes:** None
- **Driven by findings:** F9, F17, F30
- **Dependent decisions:** D31
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D6: Every work unit names what it descends from

- **Question:** How does scope creep become visible in the artifact rather than only in review?
- **Decision:** Every work unit and every work item carries a justification field naming one of three things: the
  work-item language it descends from, the design material the operator attached, or the asked-for work it is a
  necessity of. A unit that cannot fill it is not written into the plan; it moves to a visible cut list with the
  reason.
- **Rationale:** A required field turns creep into something a reader can see. The cut list preserves the record of
  what was considered and dropped, which a silent omission destroys. What counts as a valid descent is settled by two
  companion decisions: the scope gate's floor, which keeps necessities of the asked-for work from failing the field,
  and the attached-material rule, which says which design artifacts qualify.
- **Evidence:** User input (strictness confirmed directly). Provided: #157 improvements 3 and 10.
- **Rejected alternatives:**
  - A required field with no cut section. Rejected because the cut becomes invisible and the reader loses the record
    of what was considered.
  - An advisory field. Rejected because it leaves creep detection to review, which is what failed four times in the
    reported session.
- **Linked technical notes:** None
- **Driven by findings:** F1, F2, F10
- **Dependent decisions:** D7, D30, D31, D32, D35
- **Referenced in spec:** Primary Flow, Alternate Flows and States

### D8: The YAGNI sweep gains a scope gate covering inherited commitments

- **Question:** Does the YAGNI sweep cover commitments the plan inherited from an upstream document?
- **Decision:** Yes. The sweep walks every subsystem, integration, and artifact the plan touches, including everything
  inherited, against one question: does the work item ask for this, or exclude it by statement or by silence? An
  inherited commitment no work item supports is cut, with the citation, and recorded in the cut list. What silence can
  cut is bounded by D31: the sweep never cuts behavior required to deliver what the work item does ask for.
- **Rationale:** The rule's enumerated targets are all things the plan might add, and the sweep walks only what the
  loop produced. Scope arriving pre-committed from an upstream document is never swept, which is exactly the
  inheritance that needed a filter.
- **Evidence:** Provided: #157 section 4 and improvement 4; #156 improvement 2. Codebase: the YAGNI rule's
  anti-pattern list covers abstractions, configuration knobs, observability, runbooks, infrastructure, rollout
  machinery, test scaffolding, schema columns, and indexes, and `plan-implementation`'s operating principles state
  that the plan "inherits the spec's behavioral commitments".
- **Rejected alternatives:**
  - Adding the scope question to the shared YAGNI rule itself. Rejected because the rule is vendored across plugins
    and applies to code and coding standards too, where "the work item" has no referent. The gate belongs to the
    planning skills that have a work item.
- **Linked technical notes:** None
- **Driven by findings:** F1
- **Dependent decisions:** D9, D31
- **Referenced in spec:** Primary Flow

### D9: An upstream specification is an artifact, not a scope authority

- **Question:** How far may a plan-stage skill disagree with the specification it was given?
- **Decision:** A plan-stage skill may cut a specification commitment for a subsystem, integration, or artifact the
  work item never asks for, citing the work item. It may not re-open behavior the work item covers, and it may not cut
  behavior required to deliver what the work item does ask for. The license reaches unrequested subsystems and
  nothing else.
- **Rationale:** Declaring the specification "ground truth" made it unfalsifiable on scope, and left no path to the
  verdict "this is not part of this work". Specifications drift beyond their work item, and the upstream one in the
  reported session did. Scoping the license to exclusions is the strictly simpler version that satisfies the same
  evidence: it fixes the scope failure without inviting wholesale re-litigation of settled behavior.
- **Evidence:** Provided: #157 section 3 and improvement 12; #156 improvement 7. Codebase: `plan-implementation`'s
  operating principle "The feature specification is the ground truth for _what_. Do not re-open behavioral decisions
  the specification already settled."
- **Rejected alternatives:**
  - A general license to challenge any specification claim. Rejected because it reopens the settled-behavior debates
    the current principle correctly prevents, and no reported evidence asks for it.
  - Leaving the principle unchanged and relying on the scope gate alone. Rejected because the principle would still
    contradict the gate, which is the kind of two-rules-one-situation conflict this change set exists to remove.
- **Linked technical notes:** None
- **Driven by findings:** F1
- **Dependent decisions:** D10, D11, D31
- **Referenced in spec:** Alternate Flows and States, Out of Scope

### D10: The mechanic-contradiction protocol gains an out-of-scope verdict

- **Question:** What does a specialist do when it believes a committed mechanic should not exist at all?
- **Decision:** A third verdict sits beside confirm and contradict: out of scope for this work item, resolved by
  citing the work item rather than by escalating to the operator. The same third verdict applies to specification
  decisions, not only to technical notes. The verdict is recorded as its own finding kind and does not count toward
  the threshold that decides whether the upstream specification is too immature to plan against.
- **Why it needs its own kind:** The existing classification detects a mechanic contradiction by whether the
  specialist named an alternative mechanic. An out-of-scope verdict names none, so without its own kind it falls
  through to the general path and reaches the operator as an escalation, which is what this decision exists to
  prevent. Excluding it from the immaturity threshold follows from what that threshold measures: a specification that
  committed to work outside its ticket is drifted, not immature, and pausing spec-stage work is the wrong remedy.
- **Rationale:** The contradiction protocol demands the specialist name the alternative mechanic they recommend, which
  forces someone who thinks the mechanic should not exist to invent a replacement. The protocol assumes the answer is
  a different implementation, never no implementation.
- **Evidence:** Provided: #157 improvement 5; #156 improvement 3. Codebase: `plan-implementation` Step 4 instructs
  specialists to raise disagreement as a contradiction finding that "names the alternative mechanic they recommend".
- **Rejected alternatives:**
  - Letting the specialist raise it as a generic finding. Rejected because the aggregation classifies findings by
    text rules, so an unnamed verdict would route back into the escalation path this decision exists to avoid.
- **Linked technical notes:** None
- **Driven by findings:** F7
- **Dependent decisions:** None
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
  - Extending only the forward half, so a work-item-answered question is not raised. Rejected because it leaves the
    out-of-scope case escalating, which is the case that cost the operator turns.
- **Linked technical notes:** None
- **Driven by findings:** None
- **Dependent decisions:** None
- **Referenced in spec:** Alternate Flows and States

### D12: Escalations are one question at a time, led by plain language

- **Question:** What shape does an escalation take?
- **Decision:** The rule governs escalations, meaning questions that survive evidence and reframing and need the
  operator's judgment. One question per turn, each leading with the consequence in plain language as a person who will
  not read the code would describe it, each carrying named candidate answers, with paths, identifiers, and line
  numbers below the question or left out. The run states how many questions are pending on the first one, and presents
  more than one in a turn only when the operator asks for that. The opening confirmation turn is not an escalation and
  is the one turn that carries more than one ask.
- **Rationale:** The current guidance specifies what an escalation must contain and says nothing about register or
  batch size, while explicitly inviting a batch. Following it produced four questions each leading with a file path
  and a line number, which the operator rejected outright. The operator's own correction is a better specification
  than the skill's, and it has four clauses, not three: one issue at a time, plain language, no technical detail, and
  with options. Scoping the rule to escalations is what lets the opening confirmation turn carry two asks without
  contradicting it, and what leaves the existing habit of grouping findings by the decision they affect intact as an
  ordering rather than a batch.
- **Evidence:** Provided: #157 improvement 8 and section 7, whose verbatim operator instruction is "show me one issue
  at a time in plain language summary, no technical details, with options"; #156 improvement 5. Codebase:
  `plan-implementation` Step 6 lists the required contents of an escalation and caps it at "a focused batch";
  `plan-a-feature` Step 7 presents findings "together, organized by the decision they affect"; `plan-a-phased-build`
  Steps 5 and 7 batch open items into one presentation.
- **Rejected alternatives:**
  - Keeping the batch and adding a register rule. Rejected because the reported failure was the batch as much as the
    register, and the operator asked for one issue at a time by name.
  - Applying the rule to every operator-facing turn. Rejected because it would forbid the opening confirmation turn
    this specification also commits to, and would replace two skills' deliberate grouped presentations with nothing
    better.
  - Dropping the pending count. Rejected on balance, but it is the weakest half of this decision: no reported run
    complains about not knowing the queue depth, and the evidence is inferential from the turn-efficiency scores.
- **Linked technical notes:** None
- **Driven by findings:** F6, F26
- **Dependent decisions:** D13
- **Referenced in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes

### D13: A shared standard covers explaining technical work to a non-implementer

- **Question:** Where does the guidance live for explaining technical work to a reader who will not implement it?
- **Decision:** A new standard in `han-communication`, delivered by a small inline skill that surfaces it into the
  calling skill's context and hands control straight back, the same shape as the existing `readability-guidance`
  skill. Every escalating skill invokes it at escalation time. The standard bans invented shorthand for concepts the
  reader has not been given, and requires a concrete outcome the operator could observe, described in words from their
  own domain, in place of describing a mechanism. For a question shaped like data entry, that outcome takes the
  four-part form the reported session landed on: a named thing, a real starting value, what the person enters, and the
  specific wrong result they would see. A term counts as unintroduced when it appears in neither the work item nor the
  conversation.
- **Boundary against the readability standard:** The readability standard governs the shape of a written deliverable.
  This standard governs what a run says to the operator in a turn. Its scope is every skill that escalates, so it
  needs no enumerated registry of its own.
- **Rationale:** Every planning skill escalates to this reader and none offers guidance for it. `han-communication` is
  the foundational plugin that already owns the readability standard and the writing-voice profile, and every
  prose-producing plugin already depends on it. The delivery vehicle matters as much as the home: a skill can source a
  reference from its own plugin, and there is no sanctioned way for a `han-planning` skill to read a file inside
  `han-communication` by path, so a bare reference file would have no route to its callers. Stating the general
  property behind the four-part example is what keeps the rule biting on questions with no data entry and no wrong
  result, which most planning escalations are. Anchoring the unintroduced test to the work item and the conversation
  replaces a judgment about the operator's mind with a check against what the run holds.
- **Evidence:** User input (scope and delivery vehicle both confirmed directly). Provided: #157 improvement 9 and
  section 8, whose failures were "the two flow-side changes" and "the wizard fixes", and whose recovery was a concrete
  worked example. Codebase: `han-communication` owns the canonical readability rule and writing-voice profile with no
  vendored copies; all five `han-planning` skills source the readability standard by invoking
  `han-communication:readability-guidance`, which reads the rule from its own plugin root.
- **Rejected alternatives:**
  - Inline guidance in each escalating skill. Rejected because it duplicates the same content across at least four
    skills, against this repository's one-canonical-source convention.
  - Extending `readability-guidance` to surface both standards. Rejected because it loads escalation guidance at
    drafting time, when only drafting guidance is wanted, and because it changes a skill this specification otherwise
    leaves alone.
  - A skill that reviews and rewrites escalation prose, with its own agent. Rejected under the simpler-version test.
    Recorded as a deferral; the surfacing skill is the vehicle, not that.
- **Linked technical notes:** None
- **Driven by findings:** F3, F25, F27
- **Dependent decisions:** None
- **Referenced in spec:** Actors and Triggers, User Interactions, Coordinations, Edge Cases and Failure Modes

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
  - Persisting at document-write time. Rejected because the loss window is the whole run, and a compaction inside it
    destroys the material before the write.
  - Recording the material's absence in prose and continuing. Rejected because that is what the earlier run did, and
    it produced an artifact that looks like it accounted for the problem.
- **Linked technical notes:** T1
- **Driven by findings:** None
- **Dependent decisions:** D14, D17, D18, D24, D27
- **Referenced in spec:** Primary Flow

### D17: A completeness gate confirms visual material reached disk

- **Question:** What catches an image that was supplied but never persisted?
- **Decision:** The run notes each piece of visual material in the boundary record as that item arrives. Before
  declaring a specification or plan finished, the skill confirms that every item the record lists exists on disk
  beside the plan.
- **Why the record rather than the run's memory:** The gate's input has to survive a compaction, because compaction is
  the loss mode the technical note names. A gate reading the run's own memory of what it received passes vacuously
  after a compaction, since the run no longer remembers receiving anything. Reading a record written when each item
  arrived closes that, and it catches partial loss as well: five items received against three on disk is a failure the
  memory-based gate could never see.
- **Rationale:** An unpersisted image is a silent failure today. The gate makes it a loud one while the material is
  still in context and recoverable.
- **Evidence:** Provided: #158 improvement 3.
- **Rejected alternatives:**
  - Relying on the persist-on-arrival rule alone. Rejected because the reported failure class is exactly a rule that
    was never executed, and the gate costs one check.
  - Accepting the narrower claim and stating plainly that the gate misses compaction loss. Rejected because the record
    already exists and adding a line to it as each item arrives costs nothing, so documenting the gap was more
    expensive than closing it.
  - Asking the operator at the end of every run whether they supplied any material. Rejected because it spends a turn
    on every run, including the many with no visual material at all, against reports that already rate turn efficiency
    poorly.
- **Linked technical notes:** T1
- **Driven by findings:** F28, F37
- **Dependent decisions:** None
- **Referenced in spec:** Primary Flow, Open Items

### D18: Provided visual material reaches every dispatched reviewer

- **Question:** Which reviewers receive the operator's visual material?
- **Decision:** All of them. The paths to the persisted material go into every dispatched reviewer's brief, alongside
  the existing directive that passes the artifact paths, with an instruction to read them. The rule lives in the
  briefs of the two skills that dispatch a domain-briefed review team, not in the shared agent definitions. When
  material arrives after dispatch, the run persists it, re-briefs the reviewers it can still reach, and records which
  reviewers never received it so their design-dependent findings are unverified.
- **Rationale:** The current briefing instructions name the specification sections each specialist receives and never
  mention visual material, so it was not passed. A design specialist reviewing a design-driven feature was reduced to
  reviewing a paraphrase, and roughly eight decisions citing the designs as evidence could not be audited by anyone.
  The standing instruction belongs beside the existing pass-the-artifact-paths directive rather than inside the
  per-specialist table, because which specialist is most harmed by the omission varies by feature.
- **Evidence:** Provided: #155 improvement 1 and its section "The design reviewer was dispatched without the designs,
  and the skill's briefing instructions are why". Codebase: `plan-a-feature` Step 6 specifies each specialist's brief
  as a set of specification sections plus artifact file paths, with no mention of visual material;
  `plan-implementation` Step 4 carries a structurally identical briefing table with the same gap.
- **Rejected alternatives:**
  - Passing the material only to the design specialist. Rejected because the blind spot is wider than one
    specialist, and which reviewer needs it varies by feature.
  - Putting the rule in the shared agent definitions. Rejected because it would change every skill in the suite,
    including one this specification defers.
- **Linked technical notes:** T1
- **Driven by findings:** F8, F15, F34
- **Dependent decisions:** None
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D19: An uninspected input strips blocking severity from the findings that rest on it

- **Question:** What happens to a finding whose author recorded that it could not inspect a relevant input?
- **Decision:** Every finding depending on that input is labeled unverified, and cannot carry build-blocking severity.
  The disclosure travels attached to the finding rather than sitting in a separate assumptions section. The rule lives
  in the two dispatching skills' briefs, not in the shared agent definitions. Findings merge by substance before the
  rule applies, so the same finding raised twice cannot end up unverified under one identifier and blocking under
  another.
- **Assumption this rests on:** The reviewer notices and discloses its own blindness. The rule is inert against a
  reviewer that does not, and one reported run supplies the only evidence, in which the reviewer did disclose. This is
  an accepted limit rather than a gap to close now: the design re-check covers the one documented failure without
  depending on the reviewer saying anything, so building detection for the silent case would be speculation. The
  residue is carried in the deferred section with the trigger that would reopen it.
- **Rationale:** The reviewer in the reported session did disclose its blindness, in an assumptions section well below
  a finding it recommended treating as blocking. The disclosure existed and did not travel where it was needed.
- **Evidence:** Provided: #155 improvement 2 and its section "That produced a wrong finding, which I then promoted to
  a blocking open item".
- **Rejected alternatives:**
  - Requiring the reviewer to omit the finding entirely. Rejected because the finding may still be real, and
    discarding it loses information the dispatching skill can verify itself.
  - Relying on D18 and D20 alone, on the grounds that material reaching every reviewer plus the dispatching skill's
    own check already covers the reported scenario. Rejected because both address findings that rest on material the
    run holds, and this rule covers any input a reviewer could not inspect, including ones the run never had.
  - Putting the rule in the shared agent definitions. Rejected for the same blast-radius reason as D18.
- **Linked technical notes:** None
- **Driven by findings:** F8, F16, F29, F35, F38
- **Dependent decisions:** D20
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes, Open Items

### D20: Design-dependent findings are checked against the designs before filing

- **Question:** Who verifies a finding that turns on visual material the dispatching skill holds?
- **Decision:** The dispatching skill does, during its finding-resolution pass, before the finding becomes an open
  item.
- **Rationale:** In the reported session all five frames answered the flagged question directly and consistently, and
  the run had them and did not re-read them. One rule in the resolution pass catches this with no agent change at all.
- **Evidence:** Provided: #155 improvement 3.
- **Rejected alternatives:**
  - Relying on the unverified label alone. Rejected because an unverified finding still reaches the operator, and
    the check is nearly free when the material is already on disk.
- **Linked technical notes:** T1
- **Driven by findings:** None
- **Dependent decisions:** None
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

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
  - Keeping classification at draft time and accepting the churn. Rejected because the churn is guaranteed by
    construction, not occasional.
- **Linked technical notes:** None
- **Driven by findings:** F18
- **Dependent decisions:** None
- **Referenced in spec:** Actors and Triggers, Edge Cases and Failure Modes

### D23: The two missing-artifact rules are reconciled and split by who can supply the artifact

- **Question:** What does a skill do when an expected artifact is missing?
- **Decision:** One rule, split by who can supply the artifact. For an artifact the operator can produce on demand,
  surface it before drafting and ask once. For an artifact nobody can produce now, note it in the report, draft around
  it, and flag what it blocks. The canonical statement lives in the reference that already carries the work-item
  skill's missing-artifact handling, since both contradicting statements are that skill's; the skill's own step and
  the operating principle the single-stop rule edits both point at it rather than restating it. The classification
  test is whether the input exists outside the codebase and the operator can hand it over now.
- **The boundary record is readable downstream:** The same reference excludes process artifacts from work items. The
  boundary record is admitted by name, because a downstream skill that cannot read it either re-asks the operator or
  drafts unbounded.
- **Rationale:** Today the skill step and its own linked reference give opposite instructions for the same situation,
  which forces the run to pick. Picking is not something a skill should leave to the run.
- **Evidence:** Provided: #158 improvement 5 and its section "The two missing-artifact rules contradict each other".
  Codebase: `plan-work-items` Step 4 says to note a missing artifact in the report rather than stopping, while its
  linked artifact-inventory reference says to surface it to the user before drafting because dependent work items are
  not draftable.
- **Rejected alternatives:**
  - Deleting one of the two rules. Rejected because both describe real and different situations; the defect is that
    neither names which situation it covers.
  - Leaving the canonical home unnamed. Rejected because it reproduces one layer up the defect this decision
    corrects: two candidate homes, no rule, and the choice left to the run.
- **Linked technical notes:** None
- **Driven by findings:** F12, F23, F24
- **Dependent decisions:** D25, D27, D33
- **Referenced in spec:** Coordinations, Edge Cases and Failure Modes

### D24: The visual-material convention lives in one han-planning reference

- **Question:** Where is the `ui-designs/` folder convention defined?
- **Decision:** In a new reference file owned by `han-planning`, cited by the four planning skills this specification
  covers. The file opens by stating that it is owned by `han-planning` and is not a vendored copy of a shared rule,
  and the repository map's description of that folder is corrected to say it now holds both kinds.
- **Rationale:** The convention exists today only inside one consumer's reference file, which is why no producer
  honors it. Producer and consumer reading one source is what stops the two sides from drifting apart again. The
  ownership statement is what keeps the file safe: every other file in that folder is a byte-identical copy a
  contributor may overwrite from its canonical twin, and a re-sync sweep would silently delete an unmarked owned file.
- **Evidence:** User input (home confirmed directly). Provided: #158 improvement 7 and its section "The downstream
  mapping mechanism assumes an upstream step that no upstream skill performs". Codebase: the convention appears only
  in `plan-work-items`'s reference-artifact-inventory reference, and `han-planning/references/` currently holds only
  vendored copies of the shared rules.
- **Rejected alternatives:**
  - Canonical in `han-core` and vendored into each plugin. Rejected because it puts a planning-only convention in
    the shared foundation and adds a vendored copy to keep byte-identical.
  - Kept inside `plan-a-feature` and linked cross-skill by the others. Rejected because it creates a cross-skill
    reference dependency this repository does not otherwise use.
  - Placing it without stating its ownership. Rejected because the folder's documented contract is vendored copies
    only, and an unmarked exception is a silent trap for the next contributor who re-syncs.
- **Linked technical notes:** None
- **Driven by findings:** F22, F31
- **Dependent decisions:** None
- **Referenced in spec:** Coordinations, Out of Scope

### D25: A single stop is reserved for an input only the operator can supply

- **Question:** How does the autonomy principle handle a missing input the operator could hand over right now?
- **Decision:** A skill stops exactly once when a missing input is something only the operator can supply and its
  absence degrades the deliverable. The test is whether the input exists outside the codebase and the operator can
  hand it over now. The run gathers every missing input meeting that test and covers them in the one stop, so a second
  such input joins the stop rather than causing another. The stop is an escalation put as a single question, which is
  what keeps it inside the one-question-per-turn rule, and the plain-language rules govern it: it names what is
  missing, names in plain language what the delivered artifact will be missing without it, names
  the action that would supply it, and offers to continue. Everything else stays autonomous.
- **Rationale:** The current principle collapses three different situations: an input nobody can produce, a decision
  with a reasonable default, and an input the operator can supply cheaply right now. Only the third deserves a
  question, and bounding it to one keeps the rule from becoming a general license to pause, which would work against
  the turn-efficiency the same reports ask for.
- **Evidence:** User input (stop rule confirmed directly). Provided: #158 improvement 6 and its section "The autonomy
  principle argues against the correct behavior here". Codebase: `plan-work-items`'s operating principle stops for the
  user only when the skill "genuinely cannot continue without input".
- **Rejected alternatives:**
  - Never stopping and reporting the gap loudly instead. Rejected because the reported failure is exactly a run that
    continued and produced work items for a visual card with no visual contract.
  - Stopping whenever any expected artifact is missing. Rejected because it reintroduces gating on inputs nobody can
    produce right now.
  - Naming the cost without naming the supply action. Rejected because it offers a choice where one branch has no
    stated move, and the reported run's one-line under-reaction is what the rule exists to prevent.
  - Leaving the stop outside the plain-language rules. Rejected because "the work items will lack design references"
    satisfies an unbound "names the cost" and tells the operator nothing they can weigh.
- **Linked technical notes:** T1
- **Driven by findings:** F11, F12, F13
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
  - Treating every absent folder as a missing artifact. Rejected because most work items have no visual surface, and
    it would produce a false report on each one.
- **Linked technical notes:** None
- **Driven by findings:** None
- **Dependent decisions:** None
- **Referenced in spec:** Alternate Flows and States

### D28: Output volume scales to the size of the work item

- **Question:** What keeps reviewer output proportionate to the work being planned?
- **Decision:** Each reviewer brief carries a rough target length matched to the size of the work item, not a size
  word the reviewer has to interpret. For a one-card ticket the brief names a report closer to 150 lines than 750. The
  target is a target and not a cap, so a reviewer with more worth saying still says it. The signal reaches a reviewer
  through the brief the dispatching skill writes, and governs how much a reviewer writes, never how many reviewers are
  chosen.
- **Why a number rather than an adjective:** A size band leaves the reviewer to infer a length, and nothing
  establishes that the inference lands. The reported runs supply the relevant precedent from a different surface: the
  same session's escalations failed twice while framed abstractly and succeeded once given concrete values. A rough
  target applies that lesson without becoming the hard cap rejected below, which stays on record as the fallback.
- **Rationale:** Report length scales with nothing today. The round cap scales with team size, and nothing scales with
  the size of the thing being built, so a three-sentence ticket that adds one card drew four reports totalling roughly
  three thousand lines. Keeping the signal separate from team sizing avoids trading review coverage for brevity, which
  none of the reports asked for.
- **Evidence:** Provided: #157 improvement 11 and its section 9; #156 improvement 6; #155's section on
  disproportionate output volume. Codebase: `plan-implementation` Step 3 sets team and round caps by size band, and
  no step constrains report length.
- **Rejected alternatives:**
  - Shrinking the team caps. Rejected because the reports rate finding signal-to-noise at four out of five and name
    volume, not coverage, as the complaint.
  - A hard line limit per report. Rejected because it caps the useful and the padded alike, where a target lets the
    reviewer judge. Kept on record as the fallback if even a named target proves inert.
  - Naming only the size band and trusting the reviewer to infer a length. Rejected because nothing establishes the
    inference lands, and the same session's escalations show abstract framing failing where concrete values worked.
  - Deferring the whole signal until the scope corrections land, on the grounds that cutting out-of-scope work shrinks
    what there is to report on. Rejected because it leaves the most-reported symptom unaddressed in the first release.
- **Linked technical notes:** None
- **Driven by findings:** F8, F35, F39
- **Dependent decisions:** None
- **Referenced in spec:** Primary Flow, Coordinations, Out of Scope, Open Items

### D31: The scope gate cuts subsystems, never necessities of the asked-for work

- **Question:** Where does "silence is exclusion" stop cutting?
- **Decision:** The sweep cuts subsystems, integrations, and artifacts the work item never asks for. It does not cut
  behavior required to deliver what the work item does ask for. A short work item does not enumerate its own
  necessities, and the sweep does not read that silence as exclusion.
- **Rationale:** Without a floor, the rule that stops over-reach has no bound on under-reach, and the failure it
  creates is quieter than the one it fixes. A three-sentence ticket is silent about validation, focus behavior, error
  copy, tests, and accessibility, so a literal reading cuts all of them. An over-scoped plan gets caught by the
  operator asking why images are being planned; an over-cut plan ships a card with no error handling and nobody
  notices until implementation. The source issues calibrate the line directly: the image subsystem the ticket never
  mentioned is the correct cut, and the validation and focus behavior on the card the ticket did ask for are the
  correct non-cuts.
- **Evidence:** User input (floor confirmed directly). Provided: #157 section 2, where the cut commitment is an image
  subsystem, against #156's record that the same run's specialists correctly surfaced focus behavior, error
  association, and announcement behavior for the card the ticket did ask for.
- **Rejected alternatives:**
  - Cutting anything not named and relying on the cut list to catch mistakes. Rejected because it produces a long
    cut list on every terse ticket, and real work is lost when the list gets skimmed.
  - Sweeping only commitments inherited from an upstream document. Rejected because a run can author out-of-scope
    work itself, which is one of the reported failures.
- **Linked technical notes:** None
- **Driven by findings:** F1
- **Dependent decisions:** D32
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes, Out of Scope

### D32: Material the operator attached is part of the boundary

- **Question:** When attached design material depicts work the work item's text never mentions, does the material
  justify the work or does silence cut it?
- **Decision:** Material the operator attached alongside the request sets scope the same way the work item's text
  does, because attaching it is part of the act of asking. Material reached by other means, a linked document or a
  folder from an earlier run, does not.
- **Rationale:** A design-driven feature would otherwise lose work the operator clearly intended, and the operator
  would have to restate every frame in prose. The distinction by how the material arrived is what keeps this from
  reopening the door D3 closed: an artifact the run went looking for is not scope evidence, and an artifact the
  operator handed over is.
- **Evidence:** User input (precedence confirmed directly). Provided: #158, which establishes that the visual material
  was the primary specification of the card's appearance; #155, whose decisions cite the designs as evidence.
- **Rejected alternatives:**
  - Ticket text always wins. Rejected because it discards the visual contract the reported failure was about.
  - Writing the unit but flagging it as design-justified. Rejected because nearly every unit in a design-driven
    feature would carry the flag, which makes the flag meaningless.
- **Linked technical notes:** None
- **Driven by findings:** F2
- **Dependent decisions:** None
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D33: The boundary record has one name and one home

- **Question:** Where is the recorded boundary written, and what does a skill do when it finds none?
- **Decision:** Every planning skill writes and reads a boundary record beside the plan under one agreed name. A skill
  that finds no record establishes the boundary itself rather than proceeding unbounded, and an absent record is never
  read as a recorded statement that no work item exists. A skill handed a work item different from the one recorded
  surfaces the conflict in its confirmation turn and asks which governs.
- **Rationale:** Only one of the four skills writes a named context artifact today, and one writes no context artifact
  at all, so an unnamed location gives the downstream contract nothing to look for and gives each skill license to
  invent its own. The absent-record case is the most likely runtime state, since a skill is routinely invoked on a
  plan folder written before this change or by hand, and without a rule the whole change set silently does nothing on
  that path. The two states must stay distinct because the second step deliberately makes "no work item exists" a
  recorded finding.
- **Evidence:** Provided: #157 improvement 1, which requires the boundary be recorded where downstream work reads it.
  Codebase: `plan-implementation` writes a discovery-notes file; `plan-a-feature` and `plan-a-phased-build` record
  discovery findings with no file named; `plan-work-items` writes exactly one output file and has no context artifact.
- **Rejected alternatives:**
  - Letting each skill record the boundary in whatever artifact it already writes. Rejected because the downstream
    contract then has no name to look for, and four different locations is the drift the record exists to stop.
  - Treating an absent record as equivalent to "no work item exists". Rejected because it converts the most common
    runtime state into a silent no-op.
- **Linked technical notes:** None
- **Driven by findings:** F4, F14, F24
- **Dependent decisions:** None
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes, Coordinations

### D34: Operator-stated shaping context is part of the boundary

- **Question:** How does the work-item boundary apply to a skill whose source is a folder of documents or inline
  context, and which deliberately invites the operator to state goals that diverge from that source?
- **Decision:** The boundary is the work item plus whatever the operator said about scope when invoking the skill,
  recorded together. A goal the operator states out loud is a boundary statement.
- **Rationale:** `plan-a-phased-build` treats divergence from its source as a feature, not a defect, and phasing a
  roadmap where the operator wants something the source lacks is its normal case. A stated goal is a user-described
  need, which passes the evidence test on its own, so admitting it costs nothing and preserves a deliberate part of
  the skill.
- **Evidence:** User input (treatment confirmed directly). Codebase: `plan-a-phased-build` Step 1 accepts a folder of
  related documents or inline context, and Step 3 captures shaping context that explicitly may diverge from the
  source. Provided: #157, which names this skill among the three the fixes target.
- **Rejected alternatives:**
  - Requiring divergence to trace to a work item. Rejected because it breaks the skill's deliberate design for the
    sake of uniformity across four skills that are not uniform.
  - Exempting the skill from the boundary. Rejected because it leaves one of the named skills unfixed, and phased
    builds feed the others.
- **Linked technical notes:** None
- **Driven by findings:** F5
- **Dependent decisions:** None
- **Referenced in spec:** Coordinations

### D35: The cut list is visible, reversible, and distinct from a YAGNI deferral

- **Question:** Where does the operator see the cut list, what does each entry say, and can they overturn a cut?
- **Decision:** The cut list appears in the run's closing summary alongside the artifact paths. Each entry names what
  the unit would have done, in the same plain language an escalation uses, plus the reason it was cut. The operator
  may reinstate any entry, and their direction is itself a valid justification the reinstated unit records. The cut
  list holds work the work item excludes; the existing deferral section holds work no evidence supports yet, with a
  reopening trigger. An entry belongs to one or the other, never both.
- **Rationale:** The change set closes the escalation path for scope questions on purpose, which removes the channel
  every reported correction travelled: the operator saw a proposal and objected. If the cut list lives only
  in a written artifact the operator has no reason to open, the correction loop depends on them reading it, and the
  new failure direction goes undetected. A negative reason tells the operator nothing about consequence, which is what
  they need to catch a wrong cut. The reinstatement rule carries through the shared rule that the user always wins,
  which this change set would otherwise contradict.
- **Evidence:** Provided: #157, where all four scope corrections came from the operator objecting to a visible
  proposal; #158 section 4, where a one-line report of a total loss was the wrong proportion. Codebase: the shared
  YAGNI rule's escalation clause states that the user may direct an item to be kept against the rule, and fixes the
  deferral section's format and its reopening-trigger field.
- **Rejected alternatives:**
  - Recording cuts in the artifact only. Rejected because it makes detection depend on the operator reading a file
    the run gives them no reason to open.
  - Folding the cut list into the existing deferral section. Rejected because the two answer different questions and
    a deferral's reopening trigger has no meaning for work the work item excludes outright.
  - A negative reason alone. Rejected because it is the reason the run cut, not the consequence the operator needs.
- **Linked technical notes:** None
- **Driven by findings:** F10, F21
- **Dependent decisions:** None
- **Referenced in spec:** Primary Flow, Alternate Flows and States, User Interactions

### D36: Each commitment names the skills it applies to

- **Question:** Do all four planning skills gain every commitment?
- **Decision:** No. Each commitment names which of the four it applies to, and where a skill has no step a commitment
  attaches to, the commitment does not create one. The review-behavior rules live in the brief each dispatching skill
  writes rather than in the shared agent definitions, so they reach only the skills this specification names.
- **Rationale:** The four skills differ materially in the steps this change touches, so a single flow described as one
  run reads as either a large change or a no-op for two of them, and both readings are defensible from the same text.
  Naming the applicability is what makes the change set implementable without a second round of guessing. Keeping the
  review rules in the briefs contains the blast radius to the four named skills, which is what lets this
  specification defer `iterative-plan-review` honestly.
- **Evidence:** User input (rule location confirmed directly). Codebase: `plan-work-items` dispatches one agent rather
  than a domain-briefed review team, runs no sweep step, and has no escalation step; `plan-a-phased-build` runs a
  single review pass over the rendered document rather than a team of domain briefs, and has no escalation loop;
  `plan-a-feature` and `plan-implementation` have all four. The shared agent roster is dispatched by `han-coding`,
  `han-research`, and `iterative-plan-review` as well as by these skills.
- **Rejected alternatives:**
  - Putting the review rules in the shared agent definitions. Rejected because it changes every skill in the suite,
    contradicting this specification's own deferral, and is a far larger change than the issues asked for.
  - Splitting the two review rules across both homes. Rejected because two mechanisms for one class of rule is
    harder to explain than the containment is worth.
  - Describing one uniform run. Rejected because it leaves an implementer to decide which of two very different
    change sets was meant.
- **Linked technical notes:** None
- **Driven by findings:** F18, F8
- **Dependent decisions:** None
- **Referenced in spec:** Actors and Triggers, Out of Scope
