# Team Findings: Planning Scope Corrections

<!--
Every finding the review team raised for Planning Scope Corrections, and how each was
resolved. Behavioral outcomes live in [../feature-specification.md](../feature-specification.md);
decisions live in [decision-log.md](decision-log.md); load-bearing mechanics live in
[feature-technical-notes.md](feature-technical-notes.md).

Findings are classified major or minor before they are recorded. Major: changes a
behavioral commitment, edge-case rule, alternate flow, or failure mode; touches a
coordination across actors or subsystems; surfaces a load-bearing mechanic; or is a
"mechanics leaking into spec" finding. Minor otherwise. When in doubt, major.

Each entry records the identifier its originating reviewer assigned, so coverage can be
reconciled mechanically. Where several reviewers raised the same substance, the entry
carries every originating identifier and counts once.
-->

## Review team and coverage

| Reviewer                                | Brief                                                                    | Findings returned |
| --------------------------------------- | ------------------------------------------------------------------------ | ----------------- |
| `han-core:junior-developer`             | Plain-language overview, hidden assumptions, rules that fight at runtime | JD-001 to JD-018  |
| `han-core:gap-analyzer`                 | The draft against all 34 suggested improvements in the four source issues | GAP-001 to GAP-003 |
| `han-core:information-architect`        | Findability and one-canonical-source structure of the rules created      | IA-001 to IA-010  |
| `han-core:edge-case-explorer`           | Boundary conditions at the seams where the new rules meet each other     | EC1 to EC9        |
| `han-core:user-experience-designer`     | The operator-facing interaction model                                    | UX-001 to UX-010  |

**Evidence classes no reviewer could audit:** none. Every decision in this specification rests on the four source
issues, which every reviewer received, or on the repository, which every reviewer could read. The gap analysis
resolved a sample of the issue citations against the issue text and all resolved.

**Coverage result from the gap analysis:** all 34 suggested improvements across the four issues are covered by a
decision or a technical note. Zero dropped, zero silently weakened.

## Major findings

### F1: "Silence is exclusion" has no floor

- **Agent:** junior-developer (JD-001, JD-002), edge-case-explorer (EC3)
- **Finding:** A three-sentence work item is silent about validation, focus behavior, error copy, tests, and
  accessibility. Applied literally, the scope gate cuts all of them. The rule that stops over-reach had no bound on
  under-reach, and the resulting failure is quieter than the one it fixes.
- **Resolution:** The sweep cuts subsystems, integrations, and artifacts the work item never asks for, and does not
  cut behavior required to deliver what it does ask for. The source issues calibrate the line: the image subsystem is
  the correct cut, the card's own error and focus behavior are the correct non-cuts.
- **Resolved by:** user input
- **Affected decisions:** D31 (new), D6, D8, D9
- **Affected tech-notes:** None
- **Changed in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes, Out of Scope

### F2: Design material and work-item text had no stated precedence

- **Agent:** edge-case-explorer (EC7), junior-developer (JD-008)
- **Finding:** A work unit could pass the justification field by citing a design artifact and fail the scope gate for
  lacking ticket-text support, with no rule saying which wins. Designs routinely show adjacent surfaces and future
  states, so a design is an upstream artifact with the same standing as the specification that let the image
  subsystem in.
- **Resolution:** Material the operator attached alongside the request is part of the boundary. Material reached by
  other means is not, which keeps the door D3 closed.
- **Resolved by:** user input
- **Affected decisions:** D32 (new), D6
- **Affected tech-notes:** None
- **Changed in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### F3: The explanation standard had no delivery vehicle

- **Agent:** information-architect (IA-002), junior-developer (JD-014)
- **Finding:** The draft said the standard would be sourced the way the readability standard is sourced. That
  mechanism is an inline skill reading a rule from its own plugin root. No pattern exists for a `han-planning` skill
  to read a file inside `han-communication` by path, and the draft deferred building a skill, so four skills were
  committed to sourcing something unreachable.
- **Resolution:** A small inline surfacing skill in `han-communication`, the same shape as `readability-guidance`. The
  deferral is narrowed to what it always meant: a skill that reviews and rewrites escalation prose.
- **Resolved by:** user input
- **Affected decisions:** D13
- **Affected tech-notes:** None
- **Changed in spec:** Actors and Triggers, Coordinations, Deferred (YAGNI)

### F4: "The run's context artifact" named no file for three of the four skills

- **Agent:** information-architect (IA-005), junior-developer (JD-004), edge-case-explorer (EC1)
- **Finding:** Only one skill writes a named context artifact. One writes none at all. The downstream inheritance
  contract had no filename to look for, and a skill invoked on a folder with no record had no defined behavior, which
  is the most likely runtime state.
- **Resolution:** One agreed name for a boundary record beside the plan. A skill that finds no record establishes the
  boundary itself. An absent record is never read as a recorded statement that no work item exists.
- **Resolved by:** evidence
- **Affected decisions:** D33 (new), D2
- **Affected tech-notes:** None
- **Changed in spec:** Primary Flow, Alternate Flows and States, Coordinations

### F5: The phased-build skill's multi-document source and divergence mechanism were unreconciled

- **Agent:** gap-analyzer (GAP-001)
- **Finding:** `plan-a-phased-build` takes a folder of documents or inline context and deliberately invites goals that
  diverge from its source. The boundary rule was applied to it citing only the other two skills' steps as evidence,
  leaving unclear whether the divergence mechanism survived.
- **Resolution:** The operator's stated shaping context joins the work item in the boundary record. A goal stated out
  loud is a user-described need and passes the evidence test on its own.
- **Resolved by:** user input
- **Affected decisions:** D34 (new), D2
- **Affected tech-notes:** None
- **Changed in spec:** Coordinations

### F6: The one-question rule collided with two skills' batch designs and with the draft's own opening turn

- **Agent:** gap-analyzer (GAP-002), user-experience-designer (UX-001, UX-003), junior-developer (JD-007)
- **Finding:** The rule was drawn from one skill's failure and applied to all four. Two of them batch open items by
  design. The draft's own confirmation turn carried two asks, contradicting the rule beside it. The batching exception
  was stated twice as a default with no condition naming who may set it aside.
- **Resolution:** The rule governs escalations only. The opening confirmation turn is not an escalation and is the one
  turn carrying more than one ask. The run states how many questions are pending and presents more than one only when
  the operator asks. Grouping findings by the decision they affect survives as an ordering.
- **Resolved by:** evidence
- **Affected decisions:** D12
- **Affected tech-notes:** None
- **Changed in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes

### F7: The out-of-scope verdict was not wired into the existing classification

- **Agent:** gap-analyzer (GAP-003)
- **Finding:** `plan-implementation` detects a mechanic contradiction by whether the specialist named an alternative
  mechanic. An out-of-scope verdict names none, so it would fall through to the general path and reach the operator as
  an escalation, which is what the verdict exists to prevent. Nothing said whether it counted toward the threshold
  that pauses spec-stage work.
- **Resolution:** The verdict is its own finding kind and is excluded from that threshold, because a specification
  that committed to work outside its ticket is drifted rather than immature.
- **Resolved by:** evidence
- **Affected decisions:** D10
- **Affected tech-notes:** None
- **Changed in spec:** Alternate Flows and States

### F8: The review-behavior rules had no stated home, so the blast radius was undefined

- **Agent:** junior-developer (JD-003)
- **Finding:** The unverified-finding rule and the proportionality signal are properties of agent output. In the
  shared agent definitions they change every skill in the suite, including one this specification defers. In the
  skills' briefs they are only as strong as each brief. The draft read the same either way.
- **Resolution:** Both live in the brief the dispatching planning skill writes. No skill outside the four changes
  behavior.
- **Resolved by:** user input
- **Affected decisions:** D36 (new), D18, D19, D28
- **Affected tech-notes:** None
- **Changed in spec:** Actors and Triggers, Out of Scope

### F9: Direction of travel cost a turn and drove no behavior

- **Agent:** user-experience-designer (UX-004), junior-developer (JD-012)
- **Finding:** The question was asked before the run had named anything the work touches, which is recall with no cue,
  and the predictable answer is the "not known" the draft explicitly permitted. Nothing in the flow changed if the
  operator answered yes. As written it failed the simpler-version test.
- **Resolution:** The question names its subjects from the work item the skill has already read, and a recorded
  deprecation is treated by the scope sweep the same way a stated exclusion is treated. Wired to a consequence, it
  passes the evidence test.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** None
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F10: The cut list removed the operator's only detection channel

- **Agent:** junior-developer (JD-005), user-experience-designer (UX-007)
- **Finding:** All four reported corrections came from the operator seeing a proposal and objecting. Closing the
  escalation path for scope questions removes that channel, and the draft never said where or when the operator sees
  the cut list, gave only a negative reason per entry, and never carried through the shared rule that the user always
  wins.
- **Resolution:** The cut list appears in the closing summary. Each entry names what the unit would have done in plain
  language. The operator may reinstate any entry, and their direction is itself a valid justification.
- **Resolved by:** evidence
- **Affected decisions:** D35 (new), D6
- **Affected tech-notes:** None
- **Changed in spec:** Primary Flow, Alternate Flows and States, User Interactions

### F11: The unreachable-material case had no operator-facing flow

- **Agent:** edge-case-explorer (EC5), user-experience-designer (UX-009)
- **Finding:** The technical note names a structurally different failure from a not-yet-persisted image: the host gave
  the run no file to copy. The draft's only loss row described a recoverable case, so a run could retry a copy that
  cannot succeed. "You gave me these and I could not keep them" is also a different message from "I have no designs".
- **Resolution:** Its own edge-case row and its own entry condition on the single stop, naming which items could not
  be kept while they are still recoverable.
- **Resolved by:** evidence
- **Affected decisions:** D25
- **Affected tech-notes:** T1
- **Changed in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### F12: The single stop had no classification test and no rule for a second missing input

- **Agent:** edge-case-explorer (EC4)
- **Finding:** The draft named three categories of missing input and gave no test for sorting one into them, and did
  not say whether a second distinct operator-suppliable gap earns its own stop or is silently defaulted.
- **Resolution:** The test is whether the input exists outside the codebase and the operator can hand it over now. The
  run gathers every input meeting the test and covers them in one stop.
- **Resolved by:** evidence
- **Affected decisions:** D25, D23
- **Affected tech-notes:** None
- **Changed in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### F13: The single stop named a cost but no supply action, and was bound to no register

- **Agent:** user-experience-designer (UX-005)
- **Finding:** The operator was offered a choice where one branch had no stated move. "Names the cost" was bound to no
  standard, so a run could satisfy it with a category name, which is the one-line under-reaction the source issue
  identifies as the failure.
- **Resolution:** The stop is an escalation, so the plain-language rules govern it, and it names the action that would
  supply the input.
- **Resolved by:** evidence
- **Affected decisions:** D25
- **Affected tech-notes:** None
- **Changed in spec:** Alternate Flows and States, User Interactions

### F14: A work item conflicting with the recorded boundary had no rule

- **Agent:** edge-case-explorer (EC2)
- **Finding:** A folder reused for a follow-up ticket, or a copy-paste error, leaves a recorded boundary that
  disagrees with the item the skill was handed. Silently trusting a stale record is the same failure class the change
  set exists to close.
- **Resolution:** The skill surfaces the conflict in its confirmation turn and asks which governs.
- **Resolved by:** evidence
- **Affected decisions:** D33
- **Affected tech-notes:** None
- **Changed in spec:** Edge Cases and Failure Modes

### F15: Material arriving after reviewer dispatch had no rule

- **Agent:** edge-case-explorer (EC6, first half)
- **Finding:** Persistence happens when material arrives, which the draft allows at any point including after
  dispatch. Reviewers already running would never see it, and the dispatching skill would end up judging their
  design-dependent findings against material they could not weigh.
- **Resolution:** The run persists it, re-briefs the reviewers it can still reach, and records which never received
  it so their design-dependent findings are unverified.
- **Resolved by:** evidence
- **Affected decisions:** D18
- **Affected tech-notes:** None
- **Changed in spec:** Edge Cases and Failure Modes

### F16: A duplicate finding could end up in two contradictory states

- **Agent:** edge-case-explorer (EC8)
- **Finding:** The same substance raised by two reviewers, one disclosing it could not inspect the material and one
  not, would have one instance closed by the design check and the other left open under its own identifier.
- **Resolution:** Findings merge by substance before the unverified and design-check rules apply, and the merged
  record carries every originating identifier.
- **Resolved by:** evidence
- **Affected decisions:** D19, D21
- **Affected tech-notes:** None
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F17: An unanswered direction-of-travel question was indistinguishable from a recorded "not known"

- **Agent:** edge-case-explorer (EC9)
- **Finding:** A partial response or a session boundary leaves no record, while downstream skills are told to read the
  record rather than re-ask. Defaulting an unanswered question to "safe" is the same failure recurring by omission.
- **Resolution:** Unanswered is recorded as unanswered, a distinct state. A later skill may ask once; a recorded
  answer of any kind is never re-asked.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Affected tech-notes:** None
- **Changed in spec:** Edge Cases and Failure Modes

### F18: The four skills differ materially in the steps the flow changes

- **Agent:** junior-developer (JD-015)
- **Finding:** One skill has no review team, no sweep, and no escalation step; another runs a single review pass
  rather than domain briefs. A reader could not tell whether "the skill dispatches its review team" was a new
  obligation or a no-op, and the two readings are very different change sets.
- **Resolution:** An applicability table naming which of the four each commitment reaches, and a rule that a
  commitment does not create a step where none exists. The table was extended during synthesis to cover the reference
  table, unaudited evidence classes, reviewer identifiers, and decision classification, which the first pass left out.
- **Resolved by:** evidence
- **Affected decisions:** D36 (new), D14, D16, D21, D22
- **Affected tech-notes:** None
- **Changed in spec:** Actors and Triggers

### F19: No definition of done

- **Agent:** junior-developer (JD-017)
- **Finding:** The Outcome's measure was "the run that does not happen", a counterfactual with no observable test, and
  the draft carried no acceptance criteria, so an implementer and the author could disagree on whether it shipped.
- **Resolution:** Four observable criteria drawn from the source issues, each checkable on a finished artifact.
- **Resolved by:** evidence
- **Affected decisions:** None
- **Affected tech-notes:** None
- **Changed in spec:** How We Will Know It Worked (new section), Outcome

### F20: The Preconditions statement contradicted three committed stops

- **Agent:** junior-developer (JD-006)
- **Finding:** The draft claimed nothing blocks the run, while committing to a confirmation turn on every run, a
  single stop, and a technical-note fallback that stops.
- **Resolution:** The two real preconditions are stated: an operator present and answering, and supplied material
  reachable as a file.
- **Resolved by:** evidence
- **Affected decisions:** None
- **Affected tech-notes:** T1
- **Changed in spec:** Actors and Triggers

### F21: Dropped work had three destinations and no routing rule

- **Agent:** junior-developer (JD-009)
- **Finding:** The cut list, the deferral section, and "cut or deferred" in the sweep step, with nothing saying which
  receives what or whether a cut needs a reopening trigger.
- **Resolution:** The cut list holds work the work item excludes; the deferral section holds work no evidence supports
  yet, with a trigger. An entry belongs to one, never both.
- **Resolved by:** evidence
- **Affected decisions:** D35 (new)
- **Affected tech-notes:** None
- **Changed in spec:** Alternate Flows and States, Deferred (YAGNI)

### F22: The target reference folder is documented as holding vendored copies only

- **Agent:** information-architect (IA-001), junior-developer (JD-018)
- **Finding:** Every file in `han-planning/references/` today is a byte-identical copy a contributor may overwrite
  from its canonical twin. Placing an owned file there unmarked means a re-sync sweep deletes a convention four skills
  depend on, silently.
- **Resolution:** The file states its own ownership, and the repository map's description of the folder is corrected
  when it lands.
- **Resolved by:** evidence
- **Affected decisions:** D24
- **Affected tech-notes:** None
- **Changed in spec:** Out of Scope

### F23: The reconciled missing-artifact rule named no canonical home

- **Agent:** information-architect (IA-004)
- **Finding:** The draft committed to stating the rule in one place and referencing it from elsewhere, and named
  neither place, while three decisions edited three different surfaces about the same situation. It reproduced the
  defect it was correcting, one layer up.
- **Resolution:** The canonical statement lives in the reference that already carries the work-item skill's
  missing-artifact handling, since both contradicting statements are that skill's. The step and the operating
  principle point at it.
- **Resolved by:** evidence
- **Affected decisions:** D23
- **Affected tech-notes:** None
- **Changed in spec:** Coordinations

### F24: The boundary record was excluded by the consumer's own inventory rule

- **Agent:** information-architect (IA-006)
- **Finding:** The work-item skill's inventory excludes anything under an artifacts subfolder that is not a contract
  or design reference. The one existing context artifact is such a file, so the consumer would skip the record and
  either re-ask or draft unbounded, exactly the producer-consumer mismatch one source issue reported.
- **Resolution:** The boundary record is admitted by name.
- **Resolved by:** evidence
- **Affected decisions:** D23, D33 (new)
- **Affected tech-notes:** None
- **Changed in spec:** Coordinations

### F25: The two communication standards had overlapping scope and no stated boundary

- **Agent:** information-architect (IA-003)
- **Finding:** The readability standard already frames its aim around a reader who lacks the author's context and
  already instructs naming a non-technical stakeholder as the reader. A second standard with an undrawn boundary does
  not obviously fix what the first failed to prevent.
- **Resolution:** The readability standard governs the shape of a written deliverable; the new standard governs what a
  run says to the operator in a turn. Its scope is every skill that escalates, so it needs no registry of its own.
- **Resolved by:** evidence
- **Affected decisions:** D13
- **Affected tech-notes:** None
- **Changed in spec:** Out of Scope

### F26: The escalation shape dropped the operator's own fourth clause

- **Agent:** user-experience-designer (UX-002)
- **Finding:** The operator's verbatim instruction had four clauses and the draft carried three, dropping "with
  options". The draft's only mention of options was prohibitive, carrying a correct rule against option questions the
  work item already settles into a general reluctance to offer candidates.
- **Resolution:** A question that survives to escalation carries named candidate answers alongside the plain-language
  lead.
- **Resolved by:** evidence
- **Affected decisions:** D12
- **Affected tech-notes:** None
- **Changed in spec:** User Interactions

### F28: The completeness gate can pass without catching the loss it targets

- **Agent:** junior-developer (JD-010)
- **Finding:** The gate reads what the run recorded receiving. A session compacted before that record exists leaves
  nothing to check and the gate passes, yet compaction is the loss mode the technical note names.
- **Resolution:** The narrower claim is stated rather than left to be discovered, and the residue is recorded as an
  open item.
- **Resolved by:** evidence
- **Affected decisions:** D17
- **Affected tech-notes:** T1
- **Changed in spec:** Open Items

### F29: The unverified-finding rule rests on voluntary self-disclosure

- **Agent:** junior-developer (JD-011)
- **Finding:** The rule fires only when a reviewer records that it could not inspect something. It is inert against a
  reviewer that does not notice its own blindness, and one reported run supplies the only evidence, in which the
  reviewer did disclose.
- **Resolution:** The assumption is recorded on the decision and carried as an open item, rather than left implicit.
- **Resolved by:** evidence
- **Affected decisions:** D19
- **Affected tech-notes:** None
- **Changed in spec:** Open Items

## Minor edits

Each bullet records the finding, the reviewer who raised it, the resolution, and the same three cross-reference fields
the major findings carry.

- **F27:** The worked-example template only fits questions shaped like data entry, so it stops biting on the many
  planning escalations with no entry and no wrong result. Raised by user-experience-designer (UX-006). Resolved by
  stating the general property behind the four-part form and anchoring the unintroduced-term test to the work item and
  the conversation. Affected decisions: D13. Affected tech-notes: none. Changed in spec: Edge Cases and Failure Modes.
- **F30:** Success is silent throughout, so the operator's only evidence that material was kept and a boundary
  recorded is the absence of an error. Raised by user-experience-designer (UX-008). Resolved by one line in the
  opening turn stating what was captured, held to a line because the same reports rate output volume 2/5. Affected
  decisions: D5. Affected tech-notes: none. Changed in spec: Primary Flow, User Interactions.
- **F31:** Coordinations rows carried file-layout and reference-ownership mechanics rather than behavior. Raised by
  junior-developer (JD-016), user-experience-designer (UX-010), information-architect (IA-009). Resolved by restating
  each row as the behavior it guarantees and leaving placement in the decision log. Affected decisions: D24. Affected
  tech-notes: none. Changed in spec: Coordinations, Primary Flow.
- **F32:** "Every planning skill" reaches five skills while the defined actor term names four, leaving unclear whether
  `iterative-plan-review` cites the visual-material convention. Raised by information-architect (IA-007). Resolved by
  using the defined term and deferring that skill's citation alongside its scope boundary. Affected decisions: none.
  Affected tech-notes: none. Changed in spec: Deferred (YAGNI).
- **F33:** The change set's documentation obligations were unacknowledged, and the repository's own documentation goes
  stale when the new shared convention lands. Raised by information-architect (IA-008). Resolved by stating both
  obligations. Affected decisions: none. Affected tech-notes: none. Changed in spec: Out of Scope.
- **F34:** The visual-material decision cited only one skill's briefing table as evidence, though the other
  dispatching skill carries a structurally identical one with the same gap. Raised by gap-analyzer (closing note).
  Resolved by citing both. Affected decisions: D18. Affected tech-notes: none. Changed in spec: no spec change.
- **F35:** Two committed items carry evidence for the problem and not for the chosen mechanism: that a stated
  proportionality signal changes reviewer output length, and that the unverified rule adds coverage beyond material
  reaching reviewers plus the dispatching skill's own check. Raised by junior-developer (JD-013). Resolved by citing
  why each is retained, naming the fallback, and recording the residue as open items. Affected decisions: D19, D28.
  Affected tech-notes: none. Changed in spec: Open Items.
- **F36:** A visual-material folder holding items from an earlier run has no overwrite, append, or collision rule.
  Raised by edge-case-explorer (EC6, second half, with the reviewer's own doubt about its evidence). Resolved by
  deferring under the evidence test. Affected decisions: none. Affected tech-notes: none. Changed in spec: Deferred
  (YAGNI).

## Open-item settlements

The three open items the review round left were settled by the author after synthesis, presented one at a time in the
plain-language register this specification commits to. Each carries the finding it descends from.

### F37: The completeness gate read memory rather than a record

- **Agent:** author, settling the open item raised by junior-developer (JD-010) and recorded as F28
- **Finding:** The gate checked what the run held in memory. A session compacted before that memory was written down
  left the gate nothing to check, so it reported all clear on a run whose material was already lost. Compaction is the
  loss mode the technical note names, so the gate missed the case it was built for.
- **Resolution:** The run notes each item in the boundary record as that item arrives, and the gate reads the record.
  The record is already written early and kept on disk, so this costs no new artifact. It also catches partial loss,
  where more items were received than saved.
- **Resolved by:** user input
- **Affected decisions:** D17
- **Affected tech-notes:** T1
- **Changed in spec:** Primary Flow, Open Items

### F38: The unverified-finding rule waits for a confession

- **Agent:** author, settling the open item raised by junior-developer (JD-011) and recorded as F29
- **Finding:** The rule strips blocking severity from a finding whose author said it could not inspect the input. A
  reviewer that never opens the designs and never notices it skipped them says nothing, so the rule never fires and
  the finding keeps full severity.
- **Resolution:** Accepted as a limit rather than closed. The design re-check covers the one documented failure
  without depending on the reviewer saying anything, and no reported run shows the silent case, so building detection
  for it now would be speculation. Moved to the deferred section with the trigger that would reopen it.
- **Resolved by:** user input
- **Affected decisions:** D19
- **Affected tech-notes:** None
- **Changed in spec:** Deferred (YAGNI), Open Items

### F39: The proportionality signal named a size, not a length

- **Agent:** author, settling the open item raised by junior-developer (JD-013) and recorded as F35
- **Finding:** The brief named a size band and left the reviewer to infer a length. Nothing establishes that the
  inference lands, and the two levers that would certainly work were both rejected for good reasons, so the
  commitment rested on hope.
- **Resolution:** The brief names a rough target length matched to the work item, as a target and not a cap. This
  applies the lesson the same reported session records on a different surface, where abstract framing failed twice and
  concrete values worked. The hard limit stays on record as the fallback.
- **Resolved by:** user input
- **Affected decisions:** D28
- **Affected tech-notes:** None
- **Changed in spec:** Primary Flow, Open Items

## Findings recorded and closed without a change

- **IA-010:** The technical note is correctly scoped, confining host paths and read-tool mechanics to the note while
  the specification references rather than restates them. Recorded so the check is not silently skipped.
- **EC6 dropped cases:** A name collision between two images depicting the same state, and an operator revising a
  direction-of-travel answer mid-run. The reviewer dropped both for lack of evidence in the source issues, and that
  judgment is accepted.
