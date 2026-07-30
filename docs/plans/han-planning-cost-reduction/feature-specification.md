# Feature Specification: Cheaper, Faster Planning Runs

A planning run costs less waiting time and less budget. Two of the five planning skills consult fewer domain experts,
each of the five executes one routine check instead of describing it, and three stop proofreading text an editor has
already rewritten.

## Outcome

An operator running a planning skill gets a plan or specification produced by a smaller review team, for materially
less. The saving is real and the trade is real, and this section states both.

**Fewer domain experts, on the runs that convene a team.** Three skills convene a review team: `plan-a-feature`,
`plan-implementation`, and `iterative-plan-review`. The reduction reaches two of them, `plan-implementation` and
`iterative-plan-review`. `plan-a-feature` keeps the team it convenes today and is cut for scope
([D2](artifacts/decision-log.md#d2-scope-the-reduction-to-the-two-skills-the-boundary-names)).

Every team fills some seats before any domain expert is chosen, so the reduction is counted in experts rather than in
total seats ([D1](artifacts/decision-log.md#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone)).
In `plan-implementation`, two seats are filled first. A large run then drops from four-to-six experts to three or four,
a medium run from two-or-three to two, and a small run keeps its one. That makes the total team five or six for large,
four for medium, and three for small.

In `iterative-plan-review`, two seats are filled first, plus a third whenever the plan under review makes claims about
code. A large run drops from two-or-three experts to two, and a medium run drops from one-or-two to one. Where that
third seat is filled, a medium team already carries no more than one expert, so on those runs the reduction binds on the
large band alone. Its smallest size convenes no team at all
([D2](artifacts/decision-log.md#d2-scope-the-reduction-to-the-two-skills-the-boundary-names)).

**What the trade is.** A smaller team covers fewer domains. Nothing in the research measured whether a smaller team
produces a materially different plan. The source report says plainly that this option "trades review breadth for cost
directly."

The operator still sees the chosen team and the reason for it before any expert is dispatched, and can name a different
team. So the existing override is the control on coverage, not a new one
([D1](artifacts/decision-log.md#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone)).

**Reviews will also repeat less often, as a side effect.** The ceiling on repeats is unchanged. The rule that ends a
review early counts how many new findings the last pass produced. Fewer experts produce fewer findings, so the same
plan will often get one repeat where it used to get two. This is a second saving and a second reduction in scrutiny, and
it happens without anyone choosing it per run
([D1](artifacts/decision-log.md#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone)).

**Two checks get executed instead of described, one per skill.** Four skills confirm that the design images the boundary
record lists are on disk. `iterative-plan-review` confirms that the cross-references inside a reviewed plan resolve. No
single run gains both: each skill gains the one check it already carries as prose
([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)).

A check that runs either passes or fails. A check written as prose, by contrast, can be reported as done without being
done. Because these checks take their input from a document, the values they read are treated as untrusted
([D11](artifacts/decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)).

**No more proofreading the proofreader.** `plan-a-feature`, `plan-implementation`, and `plan-a-phased-build` each hand a
finished draft to the readability editor and then walk a six-point checklist over the text the editor produced. That
second pass stops running ([D6](artifacts/decision-log.md#d6-stop-running-the-six-point-check-where-an-editor-already-runs)).
The editor's own fact-preservation report becomes the fidelity guard
([D7](artifacts/decision-log.md#d7-read-the-editors-fact-preservation-report-as-the-fidelity-guard)).

The checklist text stays in place for the case where no editor ran. `plan-work-items` and `iterative-plan-review`
dispatch no editor and keep their checklist unchanged.

## Actors and Triggers

- **Actors**: the operator who runs a planning skill, and the five planning skills themselves. No user of any other
  product is affected.
- **Triggers**: running a planning skill. Which change applies depends on the skill, per the table below.
- **Preconditions**: the operator approves the check once per run, the first time a run reaches it. The skills do not
  declare that permission ahead of time, because a declaration of that shape cannot match the command as it actually runs
  ([D10](artifacts/decision-log.md#d10-do-not-declare-the-script-in-the-permission-frontmatter)). That approval is the one
  precondition an operator should know about. No operator configuration is required, and no existing plan folder needs
  migrating.

### Which skill gets which change

| Skill                   | Fewer domain experts | Executed design-image check | Executed cross-reference check | Six-point check removed  |
| ----------------------- | -------------------- | --------------------------- | ------------------------------ | ------------------------ |
| `plan-a-feature`        | No, cut for scope    | Yes                         | No, cut for scope              | Yes                      |
| `plan-implementation`   | Yes                  | Yes                         | No, cut for scope              | Yes                      |
| `plan-a-phased-build`   | No, convenes no team | Yes                         | No, has no such check          | Yes                      |
| `plan-work-items`       | No, convenes no team | Yes                         | No, has no such check          | No, keeps it (no editor) |
| `iterative-plan-review` | Yes                  | No, has no such check       | Yes                            | No, keeps it (no editor) |

`plan-a-feature` convenes a review team and is deliberately excluded from the reduction
([D2](artifacts/decision-log.md#d2-scope-the-reduction-to-the-two-skills-the-boundary-names)). `plan-a-feature` and
`plan-implementation` both carry a cross-reference check the boundary does not ask to convert
([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)). Both are recorded under Cut for
Scope. Every skill gains exactly one executed check, and each costs the operator one approval the first time a run reaches
it ([D10](artifacts/decision-log.md#d10-do-not-declare-the-script-in-the-permission-frontmatter)).

## Primary Flow

The flow of a single `plan-implementation` run under the changed behavior. Other skills take the subset of steps the
table above assigns them.

1. The run establishes its scope boundary and gathers context, unchanged.
2. The run classifies the work as small, medium, or large, unchanged.
3. The run announces the team it chose and why, unchanged, then dispatches every member in one parallel wave. The team
   carries fewer domain experts than before
   ([D1](artifacts/decision-log.md#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone),
   [D3](artifacts/decision-log.md#d3-preserve-the-single-parallel-first-wave)).
4. The run consolidates what came back, and marks any finding resting on something no expert could inspect, so that
   finding never reaches the operator as a blocker. This step stays described rather than executed
   ([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)).
5. The run decides whether the review repeats, using the unchanged early-stop rule and the unchanged ceiling. With fewer
   experts, the rule will more often end the review after one pass.
6. The run writes its plan and hands the draft to the readability editor.
7. The run reads the editor's fact-preservation report. Where the report names a fact the editor kept in its original
   wording to avoid losing it, the run leaves that wording alone. The run does not walk the six-point checklist over the
   editor's text ([D7](artifacts/decision-log.md#d7-read-the-editors-fact-preservation-report-as-the-fidelity-guard)).
8. The run executes the design-image check, which reads the boundary record beside the deliverable it is gating and
   compares it to disk ([D13](artifacts/decision-log.md#d13-read-the-record-beside-the-deliverable-being-gated)). This is
   the only executed check a `plan-implementation` run carries.
9. The run presents its summary. A check that did not verify is named there and recorded in the artifacts
   ([D12](artifacts/decision-log.md#d12-record-an-unverified-check-in-the-artifacts-not-only-in-the-summary)).

## Alternate Flows and States

### A check does not verify

- **Entry condition:** the check does not start, or it starts and cannot finish, or it runs and refuses a value it was
  given.
- **Sequence:** the run reports which check did not verify and which of those three reasons applies. It does not report
  the check as passed, and it does not fall back to describing the check instead
  ([D9](artifacts/decision-log.md#d9-a-check-reports-one-of-three-outcomes-and-never-assumes-a-pass)). The run completes
  the rest of its work rather than pausing, and records the unverified state in the artifacts as well as the summary
  ([D12](artifacts/decision-log.md#d12-record-an-unverified-check-in-the-artifacts-not-only-in-the-summary)).
- **Exit:** the operator acts on the named reason. A refused value means fixing the record; a check that did not start
  means the permission or the check itself.

### The editor returns no usable report

- **Entry condition:** the editor cannot be reached, returns nothing, or returns a report the run cannot read as either a
  confirmation or a named kept-fact.
- **Sequence:** the run walks the six-point checklist itself, and says in its summary that it did so and why. With no
  usable report, that checklist is the only fidelity guard left
  ([D7](artifacts/decision-log.md#d7-read-the-editors-fact-preservation-report-as-the-fidelity-guard)).
- **Exit:** the run presents its output with the substitution named.

### The operator overrides the size or the team

- **Entry condition:** the operator passes a size, names a team, or a project configuration file sets a default size.
- **Sequence:** the new expert counts apply at whatever size is chosen
  ([D1](artifacts/decision-log.md#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone)). A team the
  operator names wins outright, which is how an operator who wants broader coverage gets it.
- **Exit:** unchanged.

## Edge Cases and Failure Modes

| Condition                                                                                                                                     | Required Behavior                                                                                                                                                                                                                                     |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The record lists design images and none are on disk                                                                                           | The check fails and names every missing item ([D9](artifacts/decision-log.md#d9-a-check-reports-one-of-three-outcomes-and-never-assumes-a-pass)).                                                                                                     |
| The record lists five images and three are on disk                                                                                            | The check fails and names the two missing, rather than passing because some were found ([D9](artifacts/decision-log.md#d9-a-check-reports-one-of-three-outcomes-and-never-assumes-a-pass)).                                                           |
| The record lists an item whose location is not a plain relative name inside the design folder, or whose file type is outside the accepted set | The check refuses the value and names the offending row. It does not attempt to resolve the value, and it does not pass ([D11](artifacts/decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)).                                   |
| The record marks an item as a hosted link rather than a kept file                                                                             | The check treats it as present without trying to fetch it. The link branch is entered only on that recorded marker, never inferred from how a value looks ([D11](artifacts/decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)). |
| A row carries neither a recognized link marker nor a valid location                                                                           | The check refuses the value and names the row ([D11](artifacts/decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)).                                                                                                             |
| The record lists no images at all                                                                                                             | The check passes. An empty list is a valid state ([D9](artifacts/decision-log.md#d9-a-check-reports-one-of-three-outcomes-and-never-assumes-a-pass)).                                                                                                 |
| The record itself is missing, or its received-material section cannot be read as a list                                                       | The check reports that it could not verify, naming the record, rather than passing on an absent list ([D9](artifacts/decision-log.md#d9-a-check-reports-one-of-three-outcomes-and-never-assumes-a-pass)).                                             |
| A cross-reference names an identifier that has no entry in the file it points at                                                              | The check fails and names the reference and where it sits ([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)).                                                                                                       |
| A cross-reference resolves, but the entry it reaches has a required field left empty                                                          | The check fails and reports this as a different failure from a missing target, so the operator knows which to fix ([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)).                                               |
| A cross-reference appears inside an example block                                                                                             | The check ignores it, because example text is not a live reference ([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)).                                                                                              |
| Text taken from a record or a plan appears in a check's result                                                                                | It is reported as text and never interpreted as an instruction ([D11](artifacts/decision-log.md#d11-treat-every-value-read-from-a-document-as-untrusted)).                                                                                            |
| An existing plan folder was written under the old behavior                                                                                    | It is read and extended normally. Nothing here requires rewriting an existing folder.                                                                                                                                                                 |
| A run reaches the reduced expert count and the operator wanted broader coverage                                                               | The operator's named team wins. The count is a default, not a limit on what the operator may ask for ([D1](artifacts/decision-log.md#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone)).                                     |

## User Interactions

- **Affordances:** unchanged. The same skills take the same arguments, and the size and team overrides still work.
- **Feedback:** the line announcing the team names fewer domain experts. A check reports one of three outcomes: passed;
  failed, with every offending item named; or could not verify, with the reason named
  ([D9](artifacts/decision-log.md#d9-a-check-reports-one-of-three-outcomes-and-never-assumes-a-pass)). When the editor's
  report is unusable and the checklist ran instead, the summary says so.
- **Error states:** a check that did not verify is named, along with what went unverified. Declining the approval is one
  of the ways a check does not verify, and it is reported the same way as any other
  ([D10](artifacts/decision-log.md#d10-do-not-declare-the-script-in-the-permission-frontmatter)).

## Coordinations

| Coordinating System                  | Direction | Interaction                                                                               | Ordering / Consistency Requirement                                                                                                                                                                                                          |
| ------------------------------------ | --------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The domain-expert roster             | outbound  | The run dispatches fewer experts, all in one wave.                                        | Every member starts before any result is read, so the wave stays parallel ([D3](artifacts/decision-log.md#d3-preserve-the-single-parallel-first-wave)).                                                                                     |
| The readability editor               | outbound  | The run hands over the draft and reads back a rewrite plus a fact-preservation report.    | The run reads the report before presenting. A report it cannot interpret is treated as absent, which triggers the retained checklist ([D7](artifacts/decision-log.md#d7-read-the-editors-fact-preservation-report-as-the-fidelity-guard)).  |
| The boundary record                  | inbound   | The design-image check reads the record's received-material list and compares it to disk. | The check reads the record beside the deliverable it gates, from disk rather than from the run's memory, so it survives a compaction ([D13](artifacts/decision-log.md#d13-read-the-record-beside-the-deliverable-being-gated)).             |
| The plan under review                | inbound   | The cross-reference check reads the plan and its companion files.                         | Read from disk rather than from the run's memory, on the same terms as the record ([D13](artifacts/decision-log.md#d13-read-the-record-beside-the-deliverable-being-gated)).                                                                |
| The operator's permission surface    | outbound  | The run asks the operator to approve the check the first time it reaches it.              | One approval per run. No skill declares the check ahead of time, and no permission the skills hold is treated as making a value safe to use ([D10](artifacts/decision-log.md#d10-do-not-declare-the-script-in-the-permission-frontmatter)). |
| The next planning skill in the chain | outbound  | A later skill reads this run's artifacts as its input.                                    | A check that did not verify is recorded in the artifacts, so the next run does not read the folder as fully verified ([D12](artifacts/decision-log.md#d12-record-an-unverified-check-in-the-artifacts-not-only-in-the-summary)).            |

## Out of Scope

- **Lowering the ceiling on review repeats.** The source option asked for this alongside the expert reduction, and it was
  declined: the early-stop rule already ends a review as soon as it goes quiet, so the ceiling only binds on reviews that
  are still finding problems. The operator chose this from named alternatives
  ([D1](artifacts/decision-log.md#d1-reduce-the-number-of-domain-experts-and-leave-the-repeat-ceiling-alone)).
- **The question cadence.** Questions still reach the operator one at a time. The research found no evidence for
  batching, and the boundary records this as a thing not to change.
- **Which model each reviewer runs on.** Every reviewer already declares its own model, and the mechanical ones already
  run on the cheapest.
- **The finding-consolidation passes.** Only the middle one was considered for conversion and it stays as it is. Merging
  duplicate findings and checking findings against the designs are unchanged.
- **Any skill outside the five planning skills.** The reviewers and the editor are defined elsewhere and are not edited.
- **Measuring what the change saves.** See Deferred.

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it.

### Reducing the review team in `plan-a-feature`, so a run that writes a specification keeps its current cost

- **Why cut:** the boundary's Stated Scope names two skills for the reduction, quoting the source option as "starting
  with `plan-implementation` ... and `iterative-plan-review` team mode." `plan-a-feature` convenes a review team at the
  same total sizes as `iterative-plan-review` and fills only one seat before choosing experts. So it carries more domain
  experts than either reduced skill will. That is a real saving the boundary does not ask for. If the operator reinstates
  it, a specification run gets cheaper on the same terms as the other two
  ([D2](artifacts/decision-log.md#d2-scope-the-reduction-to-the-two-skills-the-boundary-names)).

### Converting the cross-reference check in `plan-a-feature` and `plan-implementation`, so those two runs keep checking their own cross-references by hand

- **Why cut:** the boundary's Stated Scope names one instance of this check, quoting the source option as "the
  cross-reference verification in `iterative-plan-review` Step 6." Both other skills carry an equivalent check over their
  own companion files. So converting only the named one leaves two hand-run instances of the same check in place, in the
  two skills that produce the artifacts every later skill reads. Reinstating either one extends the same executed check to
  that skill ([D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated)).

### Splitting the three oversized skill files so a run reads less of them

- **Why cut:** the boundary scopes this to "a scoped follow-up that begins with an audit rather than an edit." The
  research also found the repeated content driving the file sizes runs on every pass, so moving it to another file that
  every pass also reads would not reduce what a run consumes.

### Collapsing the wording that repeats across several skills into one shared place

- **Why cut:** the boundary lists this among the options to "treat as low-payoff or unsupported." Validation found only
  two passages genuinely repeat, so the saving is small and the case for it is about avoiding drift rather than cost.

### Tightening the wording throughout the skills to use fewer words

- **Why cut:** the boundary lists this among the options to "treat as low-payoff or unsupported." The one independent
  measurement of this technique found it saves roughly nine percent, because a run spends most of its budget reading files
  and calling tools rather than on the wording of its instructions.

### Moving the judgment reviewers onto a cheaper model

- **Why cut:** the boundary records this as resting on no evidence for the reviewers involved, and records that the
  mechanical ones already run on the cheapest model.

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### Measuring what a planning run costs, before and after

- **Why deferred:** failed the evidence test. Nothing in the research measured a planning run executing, and the boundary
  does not ask for measurement. Building it now would be a second feature carried on the first one's evidence.
- **Reopen when:** someone disputes whether the smaller teams changed the cost or the quality of a plan, and the argument
  cannot be settled without numbers.
- **Source:** the research report's closing note that a before-and-after measurement of one real run is what would settle
  the recommendation.

### Naming an uncovered domain in the run summary

- **Why deferred:** replaced by the strictly simpler version that satisfies the same concern. Both team skills already
  announce the chosen team and the reason before dispatching, so the operator already sees the composition and can
  override it. A separate coverage warning would be new behavior with no evidence behind it.
- **Reopen when:** a run is found to have omitted a domain the operator then had to discover on their own.
- **Source:** `F6`, raised independently by three reviewers.

### A check that catches a false-alarm finding after the fact

- **Why deferred:** failed the evidence test. The one paper supporting it could not be fully verified, and no run has been
  caught shipping this mistake. The boundary asked for described checks to be converted, not for new checks to be added.
- **Reopen when:** a run is caught presenting a finding as a blocker when the finding rested on something no reviewer
  could inspect.
- **Source:** considered and set aside in the turn that settled
  [D4](artifacts/decision-log.md#d4-convert-two-checks-and-leave-the-third-narrated).

## Open Items

- **OI-1:** The expert counts for `iterative-plan-review` were derived from the counts agreed for `plan-implementation`,
  rather than agreed directly. That skill fills two seats before any expert is chosen, plus a third whenever the plan
  under review makes claims about code. So its medium band lands at one expert and its large at two. On a plan that makes
  claims about code, the medium band already carries no more than one expert today, so the reduction changes nothing
  there.
  - **Resolved.** The operator confirmed the derived counts as they stand, at plan stage. The counts in
    [D2](artifacts/decision-log.md#d2-scope-the-reduction-to-the-two-skills-the-boundary-names) are the ones to build,
    with no adjustment.
  - **Blocks implementation:** No, and no longer open.
- **OI-2:** Whether a smaller team produces a materially different plan is unmeasured, and the source research says the
  honest sequencing is to measure before committing to a permanent count.
  - **Deferred until after implementation**, at plan stage. The comparison needs the reduced counts to exist before it
    can be run, so no planning work can close it. The operator will open separate work for the comparison if it turns
    out to be worth running.
  - **Resolves when:** after the change ships, one real plan is run at the old counts and the new counts and the outputs
    compared.
  - **Blocks implementation:** No, and it cannot be worked before implementation. Recorded so the decision is not later
    read as evidence-backed on quality.

## Summary

- **Outcome delivered:** two of the five planning skills consult fewer domain experts, each of the five executes one of
  its routine checks instead of describing it, and three stop proofreading text an editor already rewrote.
- **Primary actors:** the operator running a planning skill.
- **Decisions settled by evidence:** 11. See [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2. See [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** `junior-developer`, `edge-case-explorer`, `adversarial-security-analyst`, `test-engineer`.
  See [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the review found that three skills convene a team rather than two, that the reviewer
  counts hid two fixed seats and collapsed two size bands, that the claim of an unchanged plan contradicted the source
  research, and that values read from a document reach something that executes with no stated trust level. All four
  reshaped the spec. See [artifacts/team-findings.md](artifacts/team-findings.md)
- **Cut for scope:** 6 entries, each reinstatable. See `## Cut for Scope`. Two of them are savings the review surfaced
  inside the change's own subject area.
- **Remaining open items:** 2
