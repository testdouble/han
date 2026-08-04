# Team Findings: Cheaper, Faster Planning Runs

Every finding the review team raised for this feature, and how each was resolved. Behavioral outcomes live in
[../feature-specification.md](../feature-specification.md); the decisions findings affected live in
[decision-log.md](decision-log.md).

No `feature-technical-notes.md` exists for this feature. Every mechanic surfaced during the interview was discoverable
from the repository, so no mechanic qualified as a note. Every `Affected tech-notes:` field below reads `—`.

Reviewers: `han-core:junior-developer` (JD), `han-core:edge-case-explorer` (ECE), `han-core:adversarial-security-analyst`
(SEC), `han-core:test-engineer` (TE).

## Coverage note

The run received no visual material, so Pass C had nothing to check and no finding can rest on uninspected design
material. The boundary record's Visual Material Received section reads `None received`.

One evidence class no reviewer could audit: how this version of the host resolves a permission prefix pattern against a
command carrying metacharacters in argument position. It lives in the host runtime, not this repository. `F11` is labeled
unverified on that account and carries no blocking severity. Its behavioral commitment does not depend on the matcher
being weak.

## Major findings

### F1: Three skills convene a review team, not two, and the third is uncovered

- **Raised by:** JD-001, JD-005, JD-011
- **Category:** behavioral commitment
- **Evidence considered:** `plan-a-feature/SKILL.md:360-364` sets team caps of 2, 3 to 4, and 4 to 5, and dispatches
  reviewers in one parallel message. That is a review team. Three skills convene one. The boundary record's Stated Scope
  quotes the source option as "starting with `plan-implementation` ... and `iterative-plan-review` team mode," naming two.
- **Resolution:** Split. The factual error is corrected: the spec now says three skills convene a team. The reduction
  itself stays scoped to the two the boundary names, and `plan-a-feature`'s reduction is cut for scope with the boundary
  citation, so the operator can reinstate it. The Outcome no longer implies every skill gets cheaper.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Actors and Triggers, Cut for Scope

### F2: The repeat-ceiling reduction is in the boundary and appears in no visible list

- **Raised by:** JD-002
- **Category:** scope
- **Evidence considered:** The boundary quotes the source option including "and the sequential round cap." The
  escalation register records the operator choosing "cut the team, leave the repeat ceiling alone" from four named
  candidates, so the decline was deliberate rather than accidental. The scope justification rule requires a declined
  boundary commitment to be visible where the operator can reinstate it.
- **Resolution:** Not re-escalated, because the operator already chose between the named candidates. Made visible instead:
  Out of Scope now carries the declined half with its reason and its D1 citation, and the boundary record's provenance
  notes that the source option was adopted in part.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Affected tech-notes:** —
- **Changed in spec:** Out of Scope

### F3: The claim that the plan stays the same is contradicted by the source research

- **Raised by:** JD-003
- **Category:** behavioral commitment
- **Evidence considered:** The source report's own trade-off text for this option: it "trades review breadth for cost
  directly," "the evidence says nothing about which specific reviewer's findings change a planning outcome in this repo,"
  and "the honest sequencing is to measure a smaller roster against the current one on a real plan before committing to a
  permanent cap." None of the cited artifacts measures output quality against roster size.
- **Resolution:** The Outcome is restated to claim what the evidence supports. It now says the operator gets a plan
  produced by a smaller review team for materially less, and names the trade rather than denying it.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

### F4: A smaller team lowers the effective repeat count through the stop rule

- **Raised by:** JD-004
- **Category:** behavioral commitment, coordination
- **Evidence considered:** The stop rule in both team skills ends the review when the most recent pass produced two or
  fewer new findings and nothing major. It counts new findings, and fewer reviewers produce fewer findings on the same
  plan, so the reduced team trips the threshold sooner.
- **Resolution:** The Outcome's claim that repeat behavior is unchanged is corrected. The ceiling is unchanged; the
  effective count falls, and the spec now says so. D1's rationale is corrected on the same point.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Primary Flow

### F5: Two fixed seats are hidden in the counts, so medium collapses into small

- **Raised by:** JD-006
- **Category:** behavioral commitment
- **Evidence considered:** `plan-implementation/SKILL.md:215-222`. The caps count the coordinator and the generalist, not
  only specialists: small is 3 (coordinator, generalist, 1 specialist), medium 4 to 5 (2 to 3 specialists), large 6 to 8
  (4 to 6 specialists). Medium at 3 leaves 1 specialist, which is exactly small's composition.
- **Resolution:** Escalated. The operator chose the numbers without the fixed seats being named, and the consequence is
  that two bands become identical in composition. The operator chose to count domain experts instead of total seats.
  Synthesis later found the same class of error in the second skill; see `S1` under Synthesis corrections.
- **Resolved by:** user input
- **Affected decisions:** D1
- **Affected tech-notes:** —
- **Changed in spec:** Outcome

### F6: The uncovered-domain warning has no decision and no evidence behind it

- **Raised by:** JD-007, SEC S-6, TE finding 2
- **Category:** YAGNI candidate
- **Evidence considered:** No decision covers it and no escalation asked for it. The simpler version already exists: both
  team skills already announce the chosen team and the reason before dispatching, so the operator already sees the
  composition and can override it.
- **Resolution:** Replaced with the simpler version that satisfies the same concern, per the YAGNI rule's second gate.
  The invented warning is removed; the existing pre-dispatch announcement is cited instead. The residual coverage risk is
  named in the Outcome rather than papered over with a mitigation nobody asked for.
- **Resolved by:** evidence
- **Affected decisions:** D1
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Alternate Flows and States

### F7: The permission decision and the failure flow disagree about whether a prompt happens

- **Raised by:** JD-008
- **Category:** coordination
- **Evidence considered:** D10 commits to declaring the permission rather than prompting mid-run. The failure flow's first
  entry condition was the operator declining a prompt, which that declaration is meant to prevent.
- **Resolution:** The entry condition is narrowed to the states that can actually occur, and the hedge in User
  Interactions is removed.
- **Resolved by:** evidence
- **Affected decisions:** D10
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States, User Interactions

### F8: The checklist both goes away and is walked as a fallback

- **Raised by:** JD-009, TE finding 1
- **Category:** behavioral commitment
- **Evidence considered:** The Outcome said the checklist goes away in three skills; the failure table said the run falls
  back to walking it. Both cannot hold. D9 separately forbids a silent fallback because the operator cannot tell which
  kind of check produced a pass.
- **Resolution:** The checklist text is retained in those three skills and skipped when the editor ran, rather than
  deleted. The fallback is announced in the summary rather than silent.
- **Resolved by:** evidence
- **Affected decisions:** D6, D7, D9
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### F9: The editor never reports a lost fact, so the restore branch fires on a state that cannot occur

- **Raised by:** ECE F4
- **Category:** behavioral commitment, coordination
- **Evidence considered:** The editor's return contract offers two outcomes: confirm every fact is present, or "if any
  fact could not be preserved while satisfying a readability criterion, name it and say you kept the fact." It restores
  the fact itself before returning. It never hands back an unrestored loss.
- **Resolution:** D7's branch is rewritten to the states the editor actually produces. The run reads the ledger and, when
  the ledger names a fact the editor had to keep in original wording, accepts that wording rather than re-editing it. A
  ledger the run cannot interpret is treated as a missing ledger, which triggers the retained checklist.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes, Coordinations

### F10: Values read from a record authored elsewhere reach something that executes, with no stated trust level

- **Raised by:** SEC S-1
- **Category:** security
- **Evidence considered:** The record's cells are free-form markdown. The boundary rule shows two legal shapes in the same
  column and constrains neither to a plain filename. The same rule commits one skill to reading a record inherited from
  another folder and treating it as authoritative, so the reading run is not always the authoring run.
- **Resolution:** The spec now commits to three things: values read from the record and from a plan file are untrusted
  input; the design-image check accepts exactly one shape, a plain relative filename inside the plan's design folder with
  an extension from the accepted set; and any other shape is a named failure rather than a value the check tries to
  resolve. How the shape is enforced belongs to the implementation plan.
- **Resolved by:** evidence
- **Affected decisions:** D4, new D11
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations, Edge Cases and Failure Modes

### F11: The declared permission is not argument safety, and execution is not the new capability

- **Raised by:** SEC S-2
- **Category:** security
- **Evidence considered:** All five planning skills already declare command-prefix permissions, and each already runs a
  file-search command at load time. What is new is not execution but execution taking an argument out of a document. A
  prefix approval constrains the front of a command and says nothing about its arguments.
- **Unverified:** how this version of the host resolves a permission prefix against a command carrying metacharacters in
  argument position could not be inspected, because that matching lives in the host runtime rather than in this
  repository. Carries no blocking severity.
- **Resolution:** D10's rationale is corrected to say the declaration removes an interruption and is never the
  argument-safety story, which F10's input refusal owns independently. The preconditions line now names the permission
  change instead of claiming there are none.
- **Resolved by:** evidence
- **Affected decisions:** D10
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers, User Interactions

### F12: A check needs three named outcomes, and the run's continuation is unstated

- **Raised by:** SEC S-4, ECE F5, TE finding 5
- **Category:** behavioral commitment
- **Evidence considered:** The failure flow covered only a check that never started. Three reviewers independently found
  the missing states: a check that ran and refused its input, a check that started and could not finish, and the question
  of whether the run pauses or completes with the gap named.
- **Resolution:** The spec commits to three outcomes, each named differently in operator-facing output: passed; failed
  with every offending item named; could not verify with the reason named, where the reason distinguishes did-not-start,
  stopped-partway, and input-refused. The run completes and reports rather than pausing, because the operator can act on
  the report afterward.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Affected tech-notes:** —
- **Changed in spec:** Alternate Flows and States, Edge Cases and Failure Modes, User Interactions

### F13: An unverified state reaches the operator's turn but not the artifacts the next skill reads

- **Raised by:** SEC S-5
- **Category:** coordination
- **Evidence considered:** A run may finish with the gap named in its summary. The summary is a turn; the next planning
  skill reads files. Nothing committed the unverified state to a file, so a downstream run would read a folder that looks
  fully verified.
- **Resolution:** A check that did not verify is recorded in the artifacts the next skill reads, not only in the turn the
  operator saw. Added as a coordination.
- **Resolved by:** evidence
- **Affected decisions:** new D12
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations, Edge Cases and Failure Modes

### F14: Mechanics leaking into spec, a file edit filed as a runtime failure mode

- **Raised by:** JD-014, SEC S-7
- **Category:** mechanics leaking into spec
- **Evidence considered:** The failure table carried a row about a skill file stating a repeat count that disagrees with
  its own ceiling. That is not a condition a run meets at run time, and as written it reads as though a run repairs its
  own instructions.
- **Resolution:** The row is removed. D8 stays as an implementation task and keeps its decision record.
- **Resolved by:** evidence
- **Affected decisions:** D8
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F15: Which skills gain each executed check was never stated, and the answer is a different set again

- **Raised by:** JD-011, SEC S-2
- **Category:** behavioral commitment
- **Evidence considered:** The completeness check appears in four skills. The cross-reference invariant check appears in
  three, and the boundary names only `iterative-plan-review`'s. Neither set matches the two that convene teams or the
  three that dispatch an editor.
- **Resolution:** The spec enumerates which skills gain which change, in a table. This also settles whether
  `plan-a-phased-build` is touched, which no earlier draft answered. The two unnamed instances of the cross-reference
  check are cut for scope with the boundary citation, on the same terms as `plan-a-feature`'s team reduction; see `S2`
  under Synthesis corrections for how the count was corrected.
- **Resolved by:** evidence
- **Affected decisions:** D4, D10
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers, Cut for Scope

### F16: The spec named no skill, which is what let the other errors through

- **Raised by:** JD-005
- **Category:** behavioral commitment
- **Evidence considered:** No skill name appeared in the draft. Every commitment addressed an anonymous subset, and the
  reviewer could only resolve which by opening all five skill files and matching numbers.
- **Resolution:** Skills are named throughout. The anonymity was what made "the two skills that convene a review team"
  read as settled when it was wrong, so this finding is the root of F1 and F15.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Actors and Triggers, Primary Flow

### F17: The two-record case is not addressed, so which record the check reads is undefined

- **Raised by:** ECE F2
- **Category:** coordination
- **Evidence considered:** The boundary rule commits `plan-work-items` to reading an inherited record from the input
  plan's folder while writing its own beside its own deliverable. Two records exist and can differ.
- **Resolution:** The check reads the record beside the deliverable it is gating, which is the one the run wrote and the
  one a reader of that deliverable will find. Named as a coordination requirement.
- **Resolved by:** evidence
- **Affected decisions:** new D13
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations

### F18: The cross-reference check has no answer for an entry that resolves but is incomplete

- **Raised by:** ECE F3
- **Category:** behavioral commitment
- **Evidence considered:** The reviewing skill treats an entry with an unpopulated required field as an invariant
  violation, which is a distinct failure class from an identifier pointing at nothing.
- **Resolution:** Both classes are named. An identifier resolving to nothing fails. An entry that resolves with a required
  field empty also fails, and the two are reported differently so the operator knows which to fix.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F19: The hosted-link branch is entered by inspecting untrusted text, and it routes to a pass

- **Raised by:** SEC S-3, JD-010, ECE F1
- **Category:** security, behavioral commitment
- **Evidence considered:** The link branch passes without touching disk, and its entry condition was the shape of an
  untrusted cell. Any value that reads as a link therefore reaches a pass with nothing kept, which is the vacuous pass the
  completeness check exists to catch. A malformed or hand-written record is described by the boundary rule as the most
  likely state a run meets.
- **Resolution:** The branch is entered on the explicit marker the record format already provides, never inferred from a
  cell's shape. A row carrying neither a recognized marker nor a shape-valid filename is a named failure. The commitment
  not to fetch the link is kept verbatim.
- **Resolved by:** evidence
- **Affected decisions:** D4, new D11
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F20: The compaction guarantee covers one check and is silent on the other

- **Raised by:** ECE F6
- **Category:** coordination
- **Evidence considered:** The design-image check was committed to reading the record rather than the run's memory. No
  equivalent statement covered the cross-reference check, though both were converted for the same reason.
- **Resolution:** Both checks read from disk rather than from the run's memory, stated once and applied to both.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations

### F21: The plan document the cross-reference check reads is not listed as a coordination

- **Raised by:** TE finding 3
- **Category:** coordination
- **Evidence considered:** The coordination table carried an inbound row for the boundary record and none for the plan
  document, though the cross-reference check reads one.
- **Resolution:** Added, with the same consistency requirement as the record row.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Coordinations

### F22: What counts as a valid cross-reference target is undefined

- **Raised by:** TE finding 4
- **Category:** behavioral commitment
- **Evidence considered:** The draft said references must point at something real without saying what counts. The two
  edge cases established boundaries without establishing the rule between them.
- **Resolution:** A reference resolves when its identifier has an entry in the companion file it names, or its heading
  exists in the document it names. Stated as an observable outcome rather than as a parsing rule.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

## Minor edits

- **F23:** The Outcome said "the same plan or specification," which does not describe what two of the five skills produce
  — JD-013 — Outcome.
- **F24:** "fenced example" reached for a markup mechanic where "an example block" says the same thing behaviorally — SEC
  S-7 — Edge Cases and Failure Modes.
- **F25:** The Summary read "pending review" while presenting as complete — JD-012 — Summary.

## Synthesis corrections

Two factual errors survived the review round and were found during synthesis, both by re-reading the five skill files
rather than by a reviewer. They are recorded here rather than as review findings, because no reviewer raised them.

### S1: `iterative-plan-review` fills a third seat conditionally, so its derived counts do not shift cleanly

- **Evidence considered:** That skill always includes two agents and conditionally requires a third whenever the plan
  under review makes claims about code. Its total caps are three to four at medium and four to five at large. With the
  third seat filled, the medium band already carries no more than one expert, so setting medium to one expert is not a
  reduction on those runs.
- **Resolution:** D2 now states the seat composition, and the spec's Outcome and `OI-1` say the medium-band reduction
  binds only when the third seat is not filled. This is the same error class the review caught in `plan-implementation` as
  `F5`, in the skill `F5` did not cover.
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Open Items

### S2: The cross-reference invariant check appears in three skills, not one

- **Evidence considered:** `plan-a-feature` and `plan-implementation` each carry an equivalent invariant check over their
  own companion files, alongside the one in `iterative-plan-review` the boundary names by skill and step. `F15` recorded
  the count as one.
- **Resolution:** `F15`'s evidence line is corrected. The two unnamed instances go to the cut list with the boundary
  citation rather than being converted, so the operator can reinstate either. The spec's skill table now reads "cut for
  scope" in those two cells instead of implying the check does not exist there.
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers, Cut for Scope

## Escalation register

| Question asked                                                                                | Answer received                                                  | Where it landed                                                                                                 |
| --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Confirmation turn: boundary restatement plus direction of travel                              | "no, they stay as-is in v5"                                      | `scope-boundary.md`, Direction of Travel                                                                        |
| How far should the reviewer count come down?                                                  | "go with recommendation"                                         | [D1](decision-log.md#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone)                 |
| What should happen to the check that cannot become an executed check?                         | "go with recommendation"                                         | [D4](decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)                                        |
| Medium and small become the same team once the fixed seats are counted; which numbers govern? | "go with recommendation" (count domain experts, not total seats) | [D1](decision-log.md#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone), resolving `F5` |

A third interview question was drafted and withdrawn. It would have asked what guards against losing a fact once the
six-point checklist is removed. The canonical readability rule answered it directly, so it was resolved by evidence at
[D6](decision-log.md#d6-stop-running-the-six-point-check-where-an-editor-already-runs) and
[D7](decision-log.md#d7-read-the-editors-fact-preservation-report-as-the-fidelity-guard) rather than escalated.

Two specialist handoffs the review named were not taken. `behavioral-analyst` was proposed for the stop-rule coupling in
`F4`; the coupling was verifiable from the stop rule's own text, so it was resolved by evidence instead. `devops-engineer`
was proposed for the permission-prompt question in `F7`; D10's own commitment settled it without a second opinion.

## Findings found after this round closed

These were not raised by the spec-stage review team. They are recorded here so the specification's provenance stays
complete, because each one changed the specification after it was presented as finished.

### S3: The permission declaration cannot work, and the specification promised what it buys

- **Found by:** `han-core:software-architect`, during implementation planning, as finding `A4` and ledger entry `R1-C2` in
  [implementation-iteration-history.md](implementation-iteration-history.md).
- **Category:** behavioral commitment, coordination
- **Evidence considered:**
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md:67-75` states
  that permission patterns are prefix matches, that the command as it runs begins with an expanded absolute path the
  pattern does not contain, that "the prefix won't match," and therefore "omit them from `allowed-tools`. Scripts typically
  run once per skill invocation, so a single user approval is acceptable." A survey of the repository found nine skills
  that invoke a script and none declaring its own; `han-reporting/skills/html-summary/SKILL.md` runs one while declaring no
  shell permission at all. `han-core:adversarial-security-analyst` independently reported that no in-repo precedent exists
  for such a declaration, which agrees with the rule while recommending the opposite action; the skill resolved the dispute
  from the repository rather than from either specialist.
- **Resolution:** Escalated, because it contradicted a commitment the specification had already made. The operator chose to
  follow the repository's guidance. `D10` was rewritten and renamed, and the specification's Preconditions, the note under
  the skill table, the User Interactions error-states entry, and the Coordinations permission row were all corrected to say
  the operator approves the check once per run.
- **Resolved by:** user input
- **Affected decisions:** D10
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers, User Interactions, Coordinations
