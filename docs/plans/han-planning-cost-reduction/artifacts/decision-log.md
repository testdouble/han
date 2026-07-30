# Decision Log: Cheaper, Faster Planning Runs

Every decision settled while specifying this feature. Behavioral statements live in
[../feature-specification.md](../feature-specification.md); this file carries the history, rationale, evidence, and
rejected alternatives.

Source research: `docs/research/han-planning-cost-reduction.md`. Its artifact identifiers (`A#`) and option identifiers
(`O#`) are cited below where a decision rests on them.

## Full decisions

### D1: Reduce the review team size and leave the repeat ceiling alone

- **Decision:** The reviewer cap drops one band at every size. In the plan-authoring skill, the large size goes from six
  to eight reviewers down to four to five, the medium size goes from four or five down to three, and the small size stays
  at three. The ceiling on how many times a review may repeat stays at one, two, and three.
- **Rationale:** The team cap costs the operator on every run. The repeat ceiling only costs them on a review that is
  still finding problems, because a deterministic stop rule already ends the review as soon as the most recent pass
  produced two or fewer new findings and nothing major. Cutting the ceiling would therefore take its saving from exactly
  the runs that most need another pass.
- **Evidence:** Codebase. The current caps and the conditional stop rule are stated in the two skills that convene review
  teams; the stop rule is what makes the ceiling an upper bound rather than a count. Research artifacts `A6`, `A7`, `A20`,
  `A13`, `A19`, `A38`. `A20` is the strongest of these: a 14-mode failure taxonomy built from more than 1,600 annotated
  multi-agent traces, finding coordination rather than model capability dominates failure. `A38` is why the team cap is
  the right target and document trimming is not: an independent replication measured prose compression at about 8.5
  percent, because a run's budget goes to file reads, tool calls, and output.
- **Rejected alternatives:**
  - Cut both the team cap and the repeat ceiling. Rejected because the ceiling is already gated by the stop rule, so
    lowering it removes the safety valve without changing the typical run.
  - Cut the team cap harder, to three or four at large. Rejected because one reviewer is always the generalist, so a
    three-reviewer large team leaves at most two domain specialists for work classified as large.
  - Make the team conditional: start with the generalist plus one specialist and add more only when the first pass
    surfaces another domain. Rejected because it converts one parallel wave into two, giving up the wall-clock advantage
    that parallel dispatch is measured to buy (`A12`).
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** D2, D3, D8
- **Settled by:** user input
- **Referenced in spec:** Outcome, Primary Flow

### D2: Apply the reduced caps to both skills that convene a review team, deriving the second skill's numbers

- **Decision:** The reduction applies to the plan-authoring skill and to the plan-reviewing skill. The plan-reviewing
  skill's numbers are derived one band down by the same rule: its medium team goes from three or four reviewers to three,
  and its large team goes from four or five to three or four. Its smallest size already runs no team at all and is
  unchanged.
- **Rationale:** The boundary's quoted scope names both skills. The operator agreed the numbers for the plan-authoring
  skill directly; the second skill's numbers follow from the same principle rather than from a separate agreement, so they
  are recorded as derived and raised as an open item.
- **Evidence:** Boundary record's Stated Scope, quoting the research report's `O1`: "starting with `plan-implementation`
  ... and `iterative-plan-review` team mode." Codebase for the current caps in both skills.
- **Rejected alternatives:** Apply the reduction only to the plan-authoring skill and leave the reviewing skill alone.
  Rejected because the boundary names both, and a reviewing run at large convenes nearly as many reviewers.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Open Items

### D3: Preserve the single parallel first wave

- **Decision:** Every reviewer on the team is still dispatched in one message so they run at the same time. The reduction
  changes how many reviewers there are, never how they are launched.
- **Rationale:** Parallel dispatch is the part of the fan-out that buys wall-clock time. Serializing it to save budget
  would trade the one measured latency benefit for a saving the team cap already delivers.
- **Evidence:** Boundary record's Stated Scope, quoting `O1`: "Keep the parallel first wave, which is the part that buys
  wall-clock time." Research artifact `A12`, which measured up to 90 percent wall-clock reduction from parallel dispatch
  of independent work.
- **Rejected alternatives:** Dispatch reviewers in sequence and stop early once enough findings accumulate. Rejected on
  the evidence above, and because the existing stop rule already provides early termination between passes.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Primary Flow, Coordinations

### D4: Convert two checks and leave the third narrated

- **Decision:** Two checks become checks the run executes: confirming every design image the boundary record lists is on
  disk, and confirming a reviewed plan's cross-references resolve. The check that marks a finding resting on an
  uninspected input stays a prose step, and the reason it cannot convert is recorded so it is not retried.
- **Rationale:** The two converted checks read files that already exist, which is the shape a check can execute. The third
  runs on reviewer output while that output is still in the conversation and before any of it reaches a file, so an
  executed check would have nothing to read. Converting it would require first writing every reviewer's raw output to
  disk, which is a larger change than the boundary asks for.
- **Evidence:** Codebase. The third check's own text places it in the pass that runs on returned reviewer output, before
  findings are recorded. Research artifacts `A36` and `A34` for the benefit of executing rather than narrating a
  deterministic step: `A36` measured up to 20 percent higher task success and about 30 percent fewer steps across 17
  models. Existing convention in the repository for how a skill invokes a check and where its tests live.
- **Rejected alternatives:**
  - Write every reviewer's raw output to a file first, then convert the third check. Rejected as a larger change than the
    boundary asks for, though it would also leave an audit trail of what each reviewer said.
  - Add a check that audits the finished findings file after the fact for a finding still marked as a blocker while
    carrying an uninspected-input note. Rejected under the evidence test and moved to the deferred section; the boundary
    asked for narrated checks to be converted rather than for new checks to be added, and the supporting research artifact
    (`A31`) could not be fully verified.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** D5, D9, D10
- **Settled by:** user input
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### D5: Record why the third check cannot be executed, in the skill itself

- **Decision:** The skills that carry the third check state, at that step, that it runs on returned reviewer output rather
  than on a file, and that this is why it is not executed.
- **Rationale:** Without the note, the next person reading the research report's recommendation alongside the skill sees
  two of three checks converted and reads the third as an oversight. The note costs one sentence and prevents a repeat
  investigation.
- **Evidence:** The research report names all three checks as convertible, and this run found the third is not. That gap
  between a written recommendation and the code is exactly what a reader would try to close.
- **Rejected alternatives:** Leave it undocumented and rely on the decision log. Rejected because a reader of the skill
  file is not necessarily a reader of this folder.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** — (recorded here; the spec states the behavior at
  [D4](#d4-convert-two-checks-and-leave-the-third-narrated))

### D6: Remove the six-point check where an editor already runs

- **Decision:** The six-point readability checklist is removed from the three skills that dispatch the editor. The two
  skills that dispatch no editor keep it.
- **Rationale:** This is not a new policy. The canonical readability rule already says that where a skill ran a
  readability pass of its own, the dedicated editor "replaces it rather than stacking a second pass on top." The three
  skills doing both are outside the rule they cite. The rule also states that the sixth criterion is the only fidelity
  guard "on a skill that runs no separate rewrite pass," which is why the two skills without an editor keep the checklist.
- **Evidence:** The canonical readability rule, quoted above, in the plugin that owns it. Research artifacts `A15` and
  `A16`, which corroborate each other that an ungrounded self-review corrupts a correct answer about as often as it fixes
  a wrong one, with one cited case dropping accuracy from 98 percent to 57 percent.
- **Rejected alternatives:**
  - Keep the checklist everywhere and drop the editor instead. Rejected because the editor is the externally grounded
    check the same evidence says works, and the checklist run by the same model on its own fresh output is the ungrounded
    one.
  - Keep both and reduce the checklist to its fidelity criterion only. Rejected as a partial version of the same
    stacking the canonical rule already forbids, and superseded by
    [D7](#d7-name-the-editors-fact-preservation-report-as-the-fidelity-guard), which covers fidelity without a second
    pass.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** D7
- **Settled by:** evidence
- **Referenced in spec:** Outcome, Primary Flow

### D7: Name the editor's fact-preservation report as the fidelity guard

- **Decision:** Where the checklist is removed, the run reads the editor's fact-preservation report and restores any fact
  the report says was lost before presenting the output. If the editor cannot be reached or returns nothing, the run falls
  back to walking the checklist itself.
- **Rationale:** Fidelity is absolute in the canonical rule, so removing the checklist requires naming what replaces it.
  The editor already produces a fact-preservation report as part of its stated output, so this names an existing artifact
  rather than adding work. One sentence replaces six criteria, which is a net reduction. The fallback covers the one case
  where removing the checklist would otherwise leave nothing.
- **Evidence:** The editor's own definition states it produces a rewritten draft plus a rubric verdict and a
  fact-preservation ledger. The canonical readability rule states that fidelity wins and that every claim, quantity,
  named entity, and stated condition survives with its precision intact.
- **Rejected alternatives:** Trust the editor without reading its report. Rejected because a report nobody reads is the
  same shape as the narrated-check problem this feature exists to fix.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes, Coordinations

### D8: Correct the contradictory repeat count

- **Decision:** The sentence in the plan-reviewing skill that says a review runs two to four repeats is corrected to match
  that skill's own ceiling of two at medium and three at large.
- **Rationale:** [D1](#d1-reduce-the-review-team-size-and-leave-the-repeat-ceiling-alone) commits to leaving the ceilings
  as they are, which cannot be stated truthfully while one sentence in the same skill names a higher number. The
  correction is a necessity of the decision rather than added scope.
- **Evidence:** Codebase. The skill states a two-to-four range in the step that runs the repeats, and states a ceiling of
  two at medium and three at large in the stop rule of that same step.
- **Rejected alternatives:** Leave the contradiction and note it as a finding. Rejected because the run is committing to
  those exact ceilings, so a reader checking the commitment against the skill would find it contradicted.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Edge Cases and Failure Modes

### D9: A check that cannot run is reported, not assumed passed

- **Decision:** When an executed check cannot run, the run names which check failed to start and does not report it as
  passed. It does not silently fall back to walking the check by hand.
- **Rationale:** The whole reason for executing these checks is that a narrated check can be reported as done without
  being done. A silent fallback to narration would reintroduce exactly that failure at the moment it matters most.
- **Evidence:** The existing completeness check states its own purpose as catching partial loss and catching a check that
  passes vacuously. Research artifact `A31` for the general pattern that a narrated step gets reported as followed without
  being followed, carried as a single source that could not be fully verified.
- **Rejected alternatives:** Fall back to the prose check automatically. Rejected because the operator would see a pass
  and have no way to tell which kind of check produced it.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** Alternate Flows and States, User Interactions

### D10: Declare the permission the checks need up front

- **Decision:** Each skill that executes a check declares the permission that check needs, scoped to that check, rather
  than relying on a broad permission or prompting the operator mid-run.
- **Rationale:** The planning skills currently declare narrow, specific permissions rather than a general one, and every
  recent change that added a permission recorded it deliberately. Declaring the new permission scoped to the check keeps
  that pattern and avoids interrupting a run partway through.
- **Evidence:** Codebase. All five planning skills declare narrowly scoped permissions rather than a general execution
  grant, and none of them currently executes any check. Research artifact `A42`.
- **Rejected alternatives:** Grant broad execution permission to the affected skills. Rejected because it widens the
  permission surface far past what the two checks need, and the repository treats a permission change as a reviewed
  decision.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Dependent decisions:** —
- **Settled by:** evidence
- **Referenced in spec:** User Interactions, Coordinations
