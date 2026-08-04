# Decision Log: Cheaper, Faster Planning Runs

Every decision settled while specifying this feature. Behavioral statements live in
[../feature-specification.md](../feature-specification.md); this file carries the history, rationale, evidence, and
rejected alternatives.

Source research: `docs/research/han-planning-cost-reduction.md`. Its artifact identifiers (`A#`) are cited where a
decision rests on them. Findings from the review round live in [team-findings.md](team-findings.md).

Every decision was classified full or trivial once, after the review round returned. Thirteen decisions were settled:
eleven by evidence and two by user input (`D1` and `D4`). The trivial entry, `D5`, was settled by evidence and carries no
`Settled by:` field, because the trivial format has none. No `feature-technical-notes.md` exists for this feature, so
every `Linked technical notes:` field reads `—` and no `T#` is cited anywhere.

## Trivial decisions

- D5: Record why the third check cannot be executed, in the skill itself — the skills carrying that check state, at that
  step, that it runs on returned reviewer output rather than on a file, and that this is why it is not executed
  (considered leaving it undocumented and relying on this log; rejected because a reader of the skill file is not
  necessarily a reader of this folder). — Referenced in spec: — (the behavior it annotates is stated at
  [D4](#d4-convert-two-checks-and-leave-the-third-narrated)).

## Full decisions

### D1: Reduce the number of domain experts and leave the repeat ceiling alone

- **Decision:** The reduction is counted in domain experts, not in total team seats. In `plan-implementation`, a large run
  goes from four-to-six experts to three or four, a medium run from two-or-three to two, and a small run keeps its one,
  making total teams five or six, four, and three. The ceiling on how many times a review may repeat is unchanged.
- **Rationale:** The expert count costs the operator on every run. The repeat ceiling only costs them on a review that is
  still finding problems, because an early-stop rule already ends the review once the most recent pass produced two or
  fewer new findings and nothing major. Counting experts rather than seats keeps the three size bands distinct; counting
  seats collapsed medium into small, because two seats on every `plan-implementation` team are filled before any expert is
  chosen.
- **Evidence:** Codebase. The current caps state their own composition as a coordinator, a generalist, and N chosen
  specialists, which is how the seat-versus-expert distinction was found. The early-stop rule is stated in both team
  skills. Research artifacts `A6`, `A7`, `A20`, `A13`, `A19`, `A38`. `A20` is the strongest: a 14-mode failure taxonomy
  built from more than 1,600 annotated multi-agent traces, finding coordination rather than model capability dominates
  failure. `A38` is why the expert count is the right target and document trimming is not: an independent replication
  measured prose compression at about 8.5 percent, because a run's budget goes to file reads, tool calls, and output.
- **What this decision does not rest on:** any measurement that a smaller team produces an equivalent plan. The source
  report states this option "trades review breadth for cost directly" and that "the honest sequencing is to measure a
  smaller roster against the current one on a real plan before committing to a permanent cap." The reduction is adopted
  with that trade named in the spec and recorded as `OI-2`, not with the trade denied.
- **Second-order effect, accepted:** the early-stop rule counts new findings, so fewer experts will more often end a
  review after one pass. The ceiling is unchanged but the effective number of repeats falls. This was not intended when
  the ceiling was left alone, and it partly undercuts the rationale for leaving it alone, so the spec states it as a
  second saving and a second reduction in scrutiny rather than presenting repeat behavior as untouched.
- **Rejected alternatives:**
  - Cut both the expert count and the repeat ceiling. Rejected because the ceiling is already gated by the early-stop
    rule, so lowering it takes its saving from exactly the runs that most need another pass. This is half of what the
    source option asked for, so the decline is recorded in the spec's Out of Scope section where the operator can see it.
  - Count total seats rather than experts, as first proposed and first agreed. Rejected once the fixed seats were found:
    medium at three seats leaves one expert, which is exactly small's composition, so one of the size bands would stop
    meaning anything.
  - Cut only the large band. Rejected as giving up most of the saving on the size most runs land in.
  - Make the team conditional: start with the generalist plus one expert and add more only when the first pass surfaces
    another domain. Rejected because it converts one parallel wave into two, giving up the wall-clock advantage parallel
    dispatch is measured to buy (`A12`).
- **Driven by findings:** F3, F4, F5, F6
- **Linked technical notes:** —
- **Dependent decisions:** D2, D3
- **Settled by:** user input
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes, Out of Scope

### D2: Scope the reduction to the two skills the boundary names

- **Decision:** The expert reduction applies to `plan-implementation` and `iterative-plan-review`. In
  `iterative-plan-review` the numbers are derived one band down: its medium goes from one-or-two experts to one and its
  large from two-or-three to two. That skill fills two seats before any expert is chosen, plus a third whenever the plan
  under review makes claims about code, so the resulting total teams are three and four without that third seat and four
  and five with it, all inside the existing total caps. Its smallest size convenes no team. `plan-a-feature` also convenes
  a review team and is cut for scope rather than reduced.
- **Rationale:** The boundary's Stated Scope names two skills. `plan-a-feature`'s team is a real saving the boundary does
  not ask for, so the scope gate cuts it rather than the run asking the operator to re-decide something the boundary
  settled. The derived numbers for `iterative-plan-review` follow the same principle rather than a separate agreement,
  because that skill has different fixed seats, so they are recorded as derived and raised as `OI-1`. The conditional
  third seat is why the derivation is not a clean one-band shift: on a plan that makes claims about code, the medium band
  already carries no more than one expert, so the reduction changes nothing at medium on those runs and binds on the large
  band alone. The spec states that rather than implying a saving at both bands.
- **Evidence:** Boundary record's Stated Scope, quoting the source option: "starting with `plan-implementation` ... and
  `iterative-plan-review` team mode." Codebase for the current caps in all three team-convening skills, including
  `plan-a-feature`'s, which the first draft of this spec missed entirely. Codebase for the seat composition of each team:
  `plan-implementation` fills two seats first, `iterative-plan-review` fills two plus a conditionally required third, and
  `plan-a-feature` fills one. The conditional seat was found during synthesis, after the review round closed.
- **Rejected alternatives:**
  - Include `plan-a-feature` on the reading that "starting with" implies a non-exhaustive list. Rejected because the scope
    gate cuts what the boundary does not ask for, and the cut list is where the operator reinstates it. Applying a
    reduction to a third skill on an inference would be the over-scoping the gate exists to catch.
  - Apply the reduction only to `plan-implementation`. Rejected because the boundary names both, and a reviewing run at
    large convenes a comparable team.
  - Express `iterative-plan-review`'s reduction in total team seats, matching how that skill states its own caps today.
    Rejected for the same reason `D1` rejected seat counting, and because the conditionally required third seat makes a
    seat count mean two different compositions depending on the plan under review.
- **Driven by findings:** F1, F16
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Outcome, Actors and Triggers, Cut for Scope, Open Items

### D3: Preserve the single parallel first wave

- **Decision:** Every member of the team is still dispatched in one message so they run at the same time. The reduction
  changes how many there are, never how they are launched.
- **Rationale:** Parallel dispatch is the part of the fan-out that buys wall-clock time. Serializing it to save budget
  would trade the one measured latency benefit for a saving the expert count already delivers.
- **Evidence:** Boundary record's Stated Scope, quoting the source option: "Keep the parallel first wave, which is the part
  that buys wall-clock time." Research artifact `A12`, which measured up to 90 percent wall-clock reduction from parallel
  dispatch of independent work.
- **Rejected alternatives:** Dispatch in sequence and stop early once enough findings accumulate. Rejected on the evidence
  above, and because the early-stop rule already provides early termination between passes.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Primary Flow, Coordinations

### D4: Convert two checks and leave the third narrated

- **Decision:** Two checks become checks the run executes: confirming every design image the boundary record lists is on
  disk, in the four skills that carry that check, and confirming a reviewed plan's cross-references resolve, in the one
  skill the boundary names. No skill gains both. The check that marks a finding resting on an uninspected input stays a
  described step, and the reason it cannot convert is recorded in the skills that carry it. The equivalent
  cross-reference check in `plan-a-feature` and `plan-implementation` is cut for scope rather than converted.
- **Rationale:** The two converted checks read files that already exist, which is the shape a check can execute. The third
  runs on reviewer output while that output is still in the conversation and before any of it reaches a file, so an
  executed check would have nothing to read. Converting it would require first writing every reviewer's raw output to
  disk, a larger change than the boundary asks for. The boundary names the cross-reference check by skill and step, so the
  two equivalent instances elsewhere go to the cut list where the operator can reinstate them, on the same terms as
  `plan-a-feature`'s team reduction.
- **Evidence:** Codebase. The third check's own text places it in the pass that runs on returned reviewer output, before
  findings are recorded. The design-image check appears in four skills and not in `iterative-plan-review`; the
  cross-reference invariant check appears in three skills, of which the boundary names one. Research artifacts `A36` and
  `A34` for the benefit of executing rather than describing a deterministic step: `A36` measured up to 20 percent higher
  task success and about 30 percent fewer steps across 17 models. Existing convention in the repository for how a skill
  invokes a check and where its tests live.
- **Rejected alternatives:**
  - Write every reviewer's raw output to a file first, then convert the third check. Rejected as a larger change than the
    boundary asks for, though it would also leave an audit trail of what each reviewer said.
  - Add a check that audits the finished findings file after the fact. Rejected under the evidence test and moved to the
    deferred section; the boundary asked for described checks to be converted rather than for new checks to be added, and
    the supporting research artifact (`A31`) could not be fully verified.
  - Convert all three instances of the cross-reference check at once, on the reading that the same check should behave the
    same way everywhere. Rejected because the boundary names one instance by skill and step, and the scope gate cuts what
    the boundary does not ask for. Recorded in the cut list so the inconsistency is visible rather than silent.
- **Driven by findings:** F10, F15, F18, F19, F20, F21, F22
- **Linked technical notes:** —
- **Dependent decisions:** D5, D9, D10, D11, D12, D13
- **Settled by:** user input
- **Referenced in spec:** Outcome, Actors and Triggers, Primary Flow, Edge Cases and Failure Modes, Cut for Scope, Deferred (YAGNI)

### D6: Stop running the six-point check where an editor already runs

- **Decision:** `plan-a-feature`, `plan-implementation`, and `plan-a-phased-build` stop running the six-point checklist
  over text the editor produced. The checklist text stays in those skills for the case where no usable editor report came
  back. `plan-work-items` and `iterative-plan-review` dispatch no editor and keep their checklist unchanged.
- **Rationale:** This is not a new policy. The canonical readability rule already says that where a skill ran a
  readability pass of its own, the dedicated editor "replaces it rather than stacking a second pass on top." The three
  skills doing both are outside the rule they cite. The rule also states the sixth criterion is the only fidelity guard
  "on a skill that runs no separate rewrite pass," which is why the two skills without an editor keep the checklist. The
  text is retained rather than deleted because the editor can fail, and a checklist that was deleted cannot be fallen back
  to.
- **Evidence:** The canonical readability rule, quoted above. Research artifacts `A15` and `A16`, which corroborate each
  other that an ungrounded self-review corrupts a correct answer about as often as it fixes a wrong one, with one cited
  case dropping accuracy from 98 percent to 57 percent.
- **Rejected alternatives:**
  - Keep the checklist everywhere and drop the editor. Rejected because the editor is the externally grounded check the
    same evidence says works, and a checklist run by the same model over its own fresh output is the ungrounded one.
  - Delete the checklist text outright in the three skills. Rejected because the editor-failure path then has no guard,
    which the first draft of this spec asserted and contradicted in the same document.
- **Driven by findings:** F8
- **Linked technical notes:** —
- **Dependent decisions:** D7
- **Settled by:** evidence
- **Referenced in spec:** Outcome

### D7: Read the editor's fact-preservation report as the fidelity guard

- **Decision:** The run reads the editor's fact-preservation report. Where the report names a fact the editor kept in its
  original wording to satisfy fidelity, the run leaves that wording alone rather than re-editing it. A report the run
  cannot read as either a confirmation or a named kept-fact is treated as absent, which triggers the retained checklist,
  and the substitution is named in the summary.
- **Rationale:** Fidelity is absolute in the canonical rule, so removing the second pass requires naming what replaces it.
  The editor already produces the report as part of its stated output, so this names an existing artifact rather than
  adding work. One sentence replaces six criteria, a net reduction.
- **Evidence:** The editor's own return contract offers exactly two outcomes: confirm every claim, quantity, named entity,
  and stated condition is present in the rewrite, or "if any fact could not be preserved while satisfying a readability
  criterion, name it and say you kept the fact." It restores the fact itself before returning, so it never hands back an
  unrestored loss. The canonical readability rule states that fidelity wins.
- **Rejected alternatives:**
  - Have the run restore a fact the report says was lost. Rejected because the editor's contract produces no such state;
    the first draft of this spec branched on a report the editor cannot return.
  - Trust the editor without reading the report. Rejected because a report nobody reads is the same shape as the
    described-check problem this feature exists to fix.
- **Driven by findings:** F8, F9
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States, Coordinations

### D8: Correct the contradictory repeat count

- **Decision:** The sentence in `iterative-plan-review` saying a review runs two to four repeats is corrected to match
  that skill's own ceiling of two at medium and three at large. This is an implementation task, not a runtime behavior.
- **Rationale:** [D1](#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone) commits to leaving the
  ceilings as they are, which cannot be stated truthfully while one sentence in the same skill names a higher number. The
  correction is a necessity of the decision rather than added scope.
- **Evidence:** Codebase. The skill states a two-to-four range in the step that runs the repeats, and a ceiling of two at
  medium and three at large in the early-stop rule of that same step.
- **Rejected alternatives:** Carry it as a row in the spec's failure-mode table, as the first draft did. Rejected because a
  stale sentence in an instruction file is not a condition a run meets at run time, and stating it that way reads as
  though a run repairs its own instructions.
- **Driven by findings:** F14
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** — (carried as an implementation task)

### D9: A check reports one of three outcomes and never assumes a pass

- **Decision:** A check reports exactly one of: passed; failed, with every offending item named; or could not verify, with
  the reason named. The reason distinguishes a check that did not start, one that started and could not finish, and one
  that ran and refused a value. The run does not fall back to describing the check, and it completes the rest of its work
  rather than pausing.
- **Rationale:** The whole reason for executing these checks is that a described check can be reported as done without
  being done, so a silent fallback to description would reintroduce that failure where it matters most. Three outcomes are
  needed because each leads the operator to a different action, and a two-state pass-or-fail would file a refused value
  under the same heading as a missing check. The run completes rather than pausing because the operator can act on the
  report afterward, and a paused run costs them a turn to release.
- **Evidence:** The existing completeness check states its own purpose as catching partial loss and catching a check that
  passes vacuously. Research artifact `A31` for the general pattern that a described step gets reported as followed
  without being followed, carried as a single source that could not be fully verified.
- **Rejected alternatives:** Fall back to the described check automatically. Rejected because the operator would see a pass
  with no way to tell which kind of check produced it.
- **Driven by findings:** F8, F12
- **Linked technical notes:** —
- **Dependent decisions:** D12
- **Settled by:** evidence
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes, User Interactions

### D10: Do not declare the script in the permission frontmatter

- **Decision:** No skill declares its check in the permission frontmatter. The operator approves the check once per run,
  the first time a run reaches it. No permission any skill holds is treated as making a value safe to use.
- **Rationale:** A declaration of that shape cannot do what an earlier version of this decision claimed. Permission
  patterns match the front of a command, and the command as it runs begins with an expanded absolute path the declaration
  does not contain, so the pattern never matches. The repository's own authoring guidance reaches that conclusion and
  states the remedy: omit the script and accept a single approval, because a script runs about once per skill invocation.
  Every skill in the repository that runs a script already does exactly that. The second half of this decision survives
  unchanged: a permission says nothing about the arguments that follow it, so
  [D11](#d11-treat-every-value-read-from-a-document-as-untrusted) owns input safety, and nothing here does.
- **Evidence:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md`,
  lines 67 to 75, which states that the patterns are prefix matches, that the runtime command starts with the expanded
  absolute skill-directory path, that "the prefix won't match," and therefore "omit them from `allowed-tools`. Scripts
  typically run once per skill invocation, so a single user approval is acceptable." A survey of the repository found nine
  skills that invoke a script and none declaring its own script; one runs a script while declaring no shell permission at
  all. Research artifact `A42` for the current narrow declarations, which stay as they are.
- **Corrected at plan stage.** An earlier version of this decision committed to five declarations and claimed they would
  prevent a mid-run interruption. `han-core:software-architect` found the guidance above during implementation planning,
  and the operator chose to follow it. The specification's Preconditions, User Interactions, and Coordinations entries were
  corrected with it. The behavioral commitment never at issue, and unchanged, is that broad execution permission is not
  granted.
- **Rejected alternatives:**
  - Grant broad execution permission. Rejected because it widens the surface far past what the checks need. The security
    review was specific that a wildcard on script names auto-approves arbitrary shell for the rest of a run, in skills that
    also hold write access.
  - Declare it anyway and verify against the host afterward. Rejected by the operator in favor of following the written
    guidance, which reasons about this exact case. Declaring anyway would make these the only skills in the repository
    doing something the repository's own rule says does not work, and would risk leaving five inert lines behind.
- **Driven by findings:** F7, F11, F15, and `R1-C2` in
  [implementation-iteration-history.md](implementation-iteration-history.md)
- **Linked technical notes:** —
- **Dependent decisions:** D11
- **Settled by:** evidence
- **Referenced in spec:** Actors and Triggers, User Interactions, Coordinations

### D11: Treat every value read from a document as untrusted

- **Decision:** Values read out of the boundary record and out of a plan under review are untrusted input. The design-image
  check accepts exactly one shape: a plain relative name inside the plan's design folder, with a file type from the
  accepted set the boundary rule already defines. Any other shape is a named failure rather than a value the check tries to
  resolve. The hosted-link branch is entered only on the explicit marker the record format provides, never inferred from
  how a value looks. Text taken from a record or a plan and repeated in a result is reported as text and never interpreted
  as an instruction.
- **Rationale:** The record's cells are free-form, the boundary rule shows two legal shapes in the same column and
  constrains neither to a filename, and one skill is committed to reading a record inherited from another folder and
  treating it as authoritative. So the reading run is not always the authoring run, and the values reach something that
  executes. Entering the link branch by inspecting a cell's shape is the worse half: that branch passes without touching
  disk, so any value that reads as a link produces a pass for material nobody kept, which is the vacuous pass the check
  exists to catch.
- **Evidence:** The boundary rule's own record format, showing both a quoted relative path and a `(not a file)` URL in the
  same column, and its statement that a record predating the convention or written by hand is the most likely state a run
  meets. Its accepted-file-set section supplies the allowed file types. Its instruction not to fetch a supplied link is
  kept unchanged.
- **Rejected alternatives:** Rely on the scoped permission declaration to confine what a check can do with a value.
  Rejected per [D10](#d10-do-not-declare-the-script-in-the-permission-frontmatter): a
  command-prefix approval constrains the command, not its arguments.
- **Driven by findings:** F10, F19
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Outcome, Edge Cases and Failure Modes

### D12: Record an unverified check in the artifacts, not only in the summary

- **Decision:** A check that did not verify is recorded in the artifacts the next planning skill reads, as well as named in
  the summary the operator sees.
- **Rationale:** The summary is a turn and the artifacts are files. The planning skills chain, so the next run reads the
  folder rather than the conversation. Without this, a later run reads a specification folder that looks fully verified
  when a check never ran.
- **Evidence:** The boundary rule names four separate mechanics that read the record back, and the planning chain is
  documented as skills consuming each other's artifacts. `plan-work-items` in particular is committed to reading a record
  written by an earlier skill.
- **Rejected alternatives:** Name it in the summary only, as the first draft did. Rejected because the operator's turn does
  not survive into the next run.
- **Driven by findings:** F13
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Coordinations

### D13: Read the record beside the deliverable being gated

- **Decision:** When two boundary records exist, the check reads the one beside the deliverable it is gating, which is the
  record the run wrote rather than the one it inherited. Both checks read from disk rather than from the run's memory.
- **Rationale:** One skill can read an inherited record from an input plan's folder while writing its own beside its own
  deliverable, so two records exist and can differ. The check gates a specific deliverable, so the record a reader of that
  deliverable would find is the one that governs. Reading from disk rather than memory is what makes the check survive a
  compaction, which the existing check already states as its own reason for reading the record.
- **Evidence:** The boundary rule's section on what "beside the plan" resolves to, which commits the skill to reading from
  one folder and writing to the other and to naming the inherited path in the record's provenance. The existing check's
  own statement that reading what the run remembers passes vacuously after a compaction.
- **Rejected alternatives:** Read the inherited record. Rejected because the deliverable being gated is the one the run
  produced, and its own record is what a later reader will find beside it.
- **Driven by findings:** F17, F20
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Primary Flow, Coordinations
