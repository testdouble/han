# Change Plan: plan-implementation feedback (issue #193)

## Why This Change

The structure of the skill produced all six problems this plan addresses. This is a finding already established: GitHub
issue [testdouble/han#193](https://github.com/testdouble/han/issues/193) is a feedback report on a real
`plan-implementation` run, and its "What didn't work" section names six problems with evidence from that run. Nothing
is broken in the sense of throwing an error.

Four of the six are structural in the same way: a mechanic is defined in one file and the file that must honor it never
reads it back. The other two are a citation that resolves to a unit coarser than the meaning it carries, and a rewrite
agent whose only self-report is produced by the pass that produced the text.

One premise in the work item turned out to be wrong, and it changed the fix. The issue says the orchestrating thread
"does have execution tools." It does not
([C-8](artifacts/current-state-findings.md#c-8-no-participant-in-a-round-holds-a-tool-that-can-measure)). All three
planning skills grant `find`, `git`, `mkdir`, `cp`, and one named config script, with no general shell. The measurement
step this plan adds works inside that grant and records what the grant cannot reach
([D-11](artifacts/change-decision-log.md#d-11-measure-within-the-current-tool-grant-and-record-what-the-grant-cannot-reach)).

## What Changes, In One Paragraph

After this change, four mechanics that a run wrote down and never looked at again each have a named reader, and one of
them has a script. A plan's cross-references are checked before the run calls itself finished. A synthesis that dies
halfway stops the run instead of feeding a missing file to the next step. A specialist citing a past decision names
which half of it they mean. Two specialists disagreeing while pointing at the same decision are treated as one of them
having misread it rather than as a genuine conflict. The readability editor reports what it inserted and stops
claiming that everything survived, and the four skills that dispatch it name any sentence it invented and cannot support. Figures the
input asserts get measured where the granted tools reach them, and get marked unreachable where they do not.

## Current State

The area is markdown instruction files that Claude Code loads at runtime, plus Bash scripts. A `SKILL.md` is the
program, and its `references/*.md` files are libraries it reads on demand. Agent definitions are dispatched
subprocesses with isolated context, and the files written to a plan folder are persistent state. Coupling here means
one file depending on a string, section name, or field name defined in another.

Several artifacts in the area have a writer and no reader. The deferral section and its reopening trigger are written by
four separate producers and read back by nothing; the one downstream consumer counts the entries
([C-1](artifacts/current-state-findings.md#c-1-the-deferral-section-has-four-writers-and-no-reader)). The plan's
acceptance-criteria section exists in one template and is read by no downstream skill
([C-17](artifacts/current-state-findings.md#c-17-definition-of-done-exists-in-one-template-and-is-read-by-nothing)). The
decision log's back-link field holds free-text plan section headings that no check resolves, and the one script that
touches links discards the anchor before testing it
([C-2](artifacts/current-state-findings.md#c-2-referenced-in-plan-names-plan-sections-that-no-check-resolves)).

The structural property under all four is the same: `plan-implementation` was built as a producer, and no step was
built to read its own structured output back.

Where the repository does close that loop, it closes it well. The visual material convention has a producer, a named
consumer, and an executed gate, and the `Unaudited evidence classes` field is written in one step and read in another.

Two more findings compound each other. The synthesis writes the hub file second of three, so the one forward-pointing
field is filled before its target exists
([C-3](artifacts/current-state-findings.md#c-3-the-synthesis-writes-the-hub-file-second-of-three-so-the-one-forward-pointing-field-is-written-before-its-target-exists)),
and nothing in the run detects a synthesis that returned partially or not at all
([C-4](artifacts/current-state-findings.md#c-4-nothing-in-the-run-detects-a-synthesis-that-returned-partially-or-not-at-all)).
The only failure-handling language in the whole skill covers a different agent.

Two in-area defects share one cause. Two skills carry an instruction sentence split across a file boundary, each from a
commit that moved body text into a reference file under a size limit
([C-13](artifacts/current-state-findings.md#c-13-the-synthesis-input-list-is-one-sentence-split-across-a-file-boundary-in-two-skills-from-two-commits)).
The limit is real. `progressive-disclosure.md:53` says to treat 500 lines as the ceiling, and
`plan-implementation/SKILL.md` sits at 483 with `plan-a-feature/SKILL.md` at 476.

## Target State

### The four write-only mechanics each get a named reader

Three of the four readers are people, and the plan says so rather than implying a mechanism. The deferral list is read
by the operator in the closing summary, in the same shape the cut list already uses three bullets above it. The
implementer reads it again at build time, through a seeded acceptance criterion. A downgraded finding carries a
disposition the operator reads. Only the cross-reference field gets a script, because it is the one whose failure is
mechanical: a string either resolves to a heading or it does not.

### The synthesis boundary is guarded on both sides

`synthesis-directives.md` writes the plan first, then the decision log, then the history backfill, so both companions
write backward into a file that exists. The classification of each decision as full or trivial moves to a preamble
sentence ahead of the list. That is what keeps the plan's inline `([D-N](...))` links resolvable when the plan is
written first.

After the synthesizer returns, the caller confirms the plan file exists before proceeding. The caller owns the artifact
set, so the caller owns the assertion that the set exists. `plan-synthesizer` cannot state it, because two of its four
callers write no files at all.

The cross-reference contract is pinned:

```
Usage: check-plan-cross-references.sh <plan.md> <implementation-decision-log.md> <implementation-iteration-history.md>

result: passed | failed | unverified
reason: <plan-unreadable>                                    only when result is unverified
missing-artifact: <plan | decision-log | history>            zero or more, only when failed
missing-plan-section: <id> field=<field> section=<heading>   zero or more, only when failed
missing-decision: <D-N> cited-by=plan line=<n>               zero or more, only when failed

Exit: 0 passed, 1 failed, 2 could not verify.
```

A missing companion file is a failure, not an unverified result. The skill defines exit 2 as "could not verify" and
lets the run finish. Routing a lost decision log there would let a half-written synthesis reach the end of the run
reporting non-blocking
([D-24](artifacts/change-decision-log.md#d-24-make-a-missing-companion-file-a-failure-not-an-unverified-result)).
`unverified` is reserved for a plan the script cannot read at all.

One value needs pinning because the iteration-history template already defines it:
`implementation-iteration-history-template.md:19-22` gives `—` as the correct value for a round that produced no
decisions or changed nothing in the plan. `—` is a filled value. A field counts as unfilled only when it is absent,
blank, or still holds its unreplaced template comment.

The failure line for the defect the reported run hit:

```
result: failed
missing-plan-section: D-4 field=Referenced in plan section=Cut for Scope
```

This matches the output contract and the exit statuses the three existing scripts already share, so an operator who has
read one has read this one.

Plan text stays untrusted. Headings and field values are searched for with `grep -qF --` and never compiled into a
pattern, and fenced-block state is tracked while walking each file.

### A citation names the field, not the entry

The brief's citation directive gains the pinned form:

```
D-4 / Decision:                     the option the upstream run committed to
D-4 / Rejected alternatives: B      an option that run declined; any figure quoted from
                                    this field is attributed to the rejected option
```

A citation naming only `D-4` is read as the `Decision:` field. Alongside it, the aggregation gains one exception. Two
findings citing the same identifier while asserting different figures do not merge, and become one disputed row
carrying both readings.

### The editor reports what it wrote, and stops vouching for the rest

Two changes to the shared agent's returned report, pinned:

```
- **Insertions** — one line per sentence you added, or the single word `none`.
  Insertion: term="round cap" source="The round cap from Step 3 sets the upper bound"

- **Fact-preservation ledger** — name only the facts you could not preserve in the
  rewrite's own wording and kept verbatim instead. Quote each one. Write `none` when
  there were none. Do not assert that the rest survived.
```

The `Insertions` field is additive, so a caller that does not read it is unaffected, which matters because the plugins
version independently.

The four skills that consume this report gain a fourth branch. When `Insertions` names a line, search the draft for the
quoted `source=` span. If it is absent, name the insertion in the summary and in `artifacts/`, and change no text.

The other three branches are rewritten at the same time. Each currently tests for the sentence the narrowed ledger
removes, so leaving them would send every clean run to the branch meaning no usable report came back.

### Measurement happens inside the grant that exists

The discovery notes gain a `Measurements` item, pinned:

```
- Measurements: for each figure the specification asserts that the plan will rest on,
  the figure as asserted, the command run, and the value it returned.
  Measurement: spec says "roughly 40 fixture files" | find test/fixtures -type f | 112
```

Three outcomes, not two. A figure no granted tool reaches is recorded as
`Measurement: {figure} | not reachable with granted tools`. A command that ran and failed is recorded as
`Measurement: {figure} | {command} | command failed: {exit status}` and is treated as an assertion, never as a
measurement. That third form exists because `find` against a path that moved returns empty rather than erroring
visibly. A `0` recorded as measured would reach three specialists in parallel stamped as fact.

The brief names the block as measured input a specialist may rely on without re-deriving, and names both an unreachable
figure and a failed command as assertions the specialist must treat as such.

### The stop says what happened and what to do next

The stop text is pinned, because the stop message is the entire operator-facing output of a halted run:

```
Synthesis did not produce {plan path}.
On disk: {the artifacts that did land, by name}.
To recover: re-run this skill and answer the Step 1 prompt with overwrite. The artifacts above stay
readable in artifacts/ until you do.
```

The wording lives once in `han-planning/references/synthesis-failure-rule.md`, a new file owned by `han-planning`
rather than one of the four vendored copies in that folder. Both skills cite it in one sentence.

## Surface Delta

### S-1: `synthesis-directives.md` write order — Re-scoped

**Target state.** The numbered list writes `feature-implementation-plan.md` first, `artifacts/implementation-decision-log.md`
second, and backfills `artifacts/implementation-iteration-history.md` third. The decision-classification sentence sits in
a preamble ahead of the list rather than inside step 1. That settles every `D-N` identity and its full-or-trivial status
before any file is written.

**Behavior.** Changing. A synthesis that terminates mid-write now loses the decision log rather than the plan. Settled by
the recorded boundary: issue #193 item 4 states this fix in its own words.

**Why.** The plan is the file both companions point into. Written second, it forces the back-link field to be filled
against a guess ([C-3](artifacts/current-state-findings.md#c-3-the-synthesis-writes-the-hub-file-second-of-three-so-the-one-forward-pointing-field-is-written-before-its-target-exists)).

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-write-the-plan-first-in-the-synthesis-order)

### S-2: `## Cut for Scope` in `synthesis-directives.md`'s two section lists — Added

**Target state.** The file's write-order sentence and its lazy-section list each name `Cut for Scope`, positioned
immediately before `Deferred (YAGNI)`, matching where `feature-implementation-plan-template.md:106-116` already places
it.

**Behavior.** Changing. Before the change a run could resolve the disagreement between the two lists and the invariant
by omitting the section. After it, the section is written. The observer is the operator reading the cut list, which
`SKILL.md:471-473` requires be shown because a cut nobody reads is a cut nobody can reverse. Settled by the recorded
boundary: issue #193 item 6 reports the reported run's dangling reference naming this exact section. That is evidence
that at least one run did omit it.

**Why.** The section carrying the cut list was absent from the ordered write instruction that produces the plan
([C-18](artifacts/current-state-findings.md#c-18-cut-for-scope-is-required-by-one-invariant-and-missing-from-the-write-order-in-the-same-file)),
and it is the section the reported run's dangling reference named.

**Decision.** [D-18](artifacts/change-decision-log.md#trivial-decisions)

### S-3: `check-plan-cross-references.sh` — Added

**Target state.** `han-planning/skills/plan-implementation/scripts/check-plan-cross-references.sh` exists, with Bats
tests beside it. It resolves three things. `Referenced in plan:` on every `D-N` and `Changed in plan:` on every `R-N`
both resolve against `^##+ ` headings in the plan. Every inline `([D-N](artifacts/implementation-decision-log.md#...))`
in the plan resolves against declared `D-N` entries in the log. Its argument list, output keys, and exit statuses are
the contract pinned in Target State.

**Behavior.** Changing. A plan whose cross-references do not resolve now produces a named failure. Observer: the
operator. Settled by escalation: asked whether a run should refuse to finish on an unresolved reference, the operator
chose a script gate plus a stop.

**Why.** The invariant is already stated in prose in two places, and prose is what failed
([C-2](artifacts/current-state-findings.md#c-2-referenced-in-plan-names-plan-sections-that-no-check-resolves)).

**Depends on.** S-1.

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-add-an-executed-cross-reference-check-rather-than-restating-the-invariant-in-prose)

### S-4: Step 9 invocation in `plan-implementation/SKILL.md` — Added

**Target state.** Step 9 runs `check-plan-cross-references.sh` beside the two checks already there, in one sentence plus
the command, citing the exit-status paragraph already at `SKILL.md:435-436` rather than restating it.

**Behavior.** Changing. Same observer and same escalation as S-3.

**Why.** A script nothing invokes changes nothing.

**Depends on.** S-3.

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-add-an-executed-cross-reference-check-rather-than-restating-the-invariant-in-prose)

### S-5: The synthesis-landed stop in `plan-implementation` and `plan-a-feature` — Added

**Target state.** Both skills confirm the plan file exists and is non-empty at the close of their synthesis step, using
`find {folder} -maxdepth 1 -name {plan filename} -size +1k`. Absent or below that size means the synthesis did not
produce its primary artifact. The run stops with the pinned message in Target State, names the artifacts that did land,
names the recovery route, and does not run the readability pass. The wording lives once in
`han-planning/references/synthesis-failure-rule.md`, and both skills cite it in one sentence.

**Behavior.** Changing. A run whose synthesis dies mid-write refuses instead of dispatching the readability editor
against a path that is not there, or against a stub. Observer: the operator of either skill. Settled by the escalation
that chose a script gate plus a stop.

**Why.** Nothing in the run detects a partial or absent synthesis
([C-4](artifacts/current-state-findings.md#c-4-nothing-in-the-run-detects-a-synthesis-that-returned-partially-or-not-at-all)),
and writing the paragraph twice is the shape that already drifted across three sibling templates
([C-19](artifacts/current-state-findings.md#c-19-the-three-sibling-decision-logs-have-diverged-on-field-name-id-format-and-classification-timing)).
The size predicate is not decoration. `find` exits 0 whether or not it matches, so an existence test with no size test
puts the verdict in stdout. The skill's stated convention is that the exit status carries the outcome.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-stop-the-run-when-synthesis-produced-no-plan-file),
[D-5](artifacts/change-decision-log.md#d-5-put-the-plan-existence-stop-in-both-file-writing-callers-worded-once),
[D-24](artifacts/change-decision-log.md#d-24-make-a-missing-companion-file-a-failure-not-an-unverified-result)

### S-6: The citation directive in `team-selection.md` — Re-scoped

**Target state.** The existing citation bullet carries the field-level form pinned in Target State. A citation naming
only a decision identifier is read as that decision's committed option.

**Behavior.** Changing. Specialist reports carry field-level citations, visible to anyone reading the iteration history.
Settled by the recorded boundary: issue #193 item 2 states this fix in its own words.

**Why.** The citation unit is one level coarser than the semantic unit, and nothing in the brief path says a rejected
alternative is an option the upstream run declined
([C-5](artifacts/current-state-findings.md#c-5-a-citation-resolves-to-a-whole-decision-entry-one-level-coarser-than-the-field-a-figure-came-from)).

**Decision.** [D-6](artifacts/change-decision-log.md#d-6-pin-citation-to-the-field-not-the-decision-entry)

### S-7: The merge exception in `round-aggregation.md` — Added

**Target state.** The `Disputed` definition carries an exception: two findings citing the same identifier while
asserting different figures do not merge under the substance pass. They become one disputed row carrying both readings
and both originating specialist identifiers.

**Behavior.** Changing. A round that previously produced one merged row can now produce a disputed row that becomes an
open question and reaches the operator. Settled by the recorded boundary: issue #193 item 2 states this fix in its own
words.

**Why.** A genuine disagreement usually cites different evidence, so identical evidence with divergent figures is a
misread signal
([C-6](artifacts/current-state-findings.md#c-6-the-merge-pass-runs-before-the-disputed-test-so-competing-readings-of-one-identifier-can-collapse-into-one-row)).

**Depends on.** S-6.

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-two-findings-citing-one-identifier-with-different-figures-do-not-merge)

### S-8: The merge pointer and the artifact pass in `plan-implementation/SKILL.md` — Re-scoped

**Target state.** The substance pass carries one complete sentence pointing at S-7's exception. The pass that opens
cited material covers material this run holds on disk, naming the cited decision case alongside the visual material it
already covers.

**Behavior.** Changing. Same observer and same settlement as S-7.

**Why.** The exception has to be reachable from the step that performs the merge, and the pass that opens an artifact
already exists for visual material with a stated reason that transfers.

**Depends on.** S-7.

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-two-findings-citing-one-identifier-with-different-figures-do-not-merge)

### S-9: `Insertions` in `readability-editor.md`'s returned report — Added

**Target state.** The agent's report carries an `Insertions` item in the form pinned in Target State. That is one line
per sentence it added, each naming the term and the quoted source span from the pre-edit draft it was written from, or
the single word `none`.

**Behavior.** Changing. Operators of all twenty-one dispatching skills see a longer report. Settled by the recorded
boundary: issue #193 item 5 reports the unreported insertion.

**Why.** The agent has a sanctioned path to write text the draft did not carry, and nothing in its report says it used
it ([C-12](artifacts/current-state-findings.md#c-12-the-editor-has-a-sanctioned-path-to-write-new-text-and-its-recent-self-check-covers-vocabulary-only)).

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-the-editor-reports-what-it-inserted-with-the-source-span-it-drew-from)

### S-10: The fact-preservation ledger in `readability-editor.md` — Re-scoped

**Target state.** The ledger names only facts the editor could not preserve in the rewrite's own wording and kept
verbatim instead, each quoted, or `none`. It asserts nothing about the rest. Step 3 confirms in both directions: no
fact appears in the rewrite that the draft did not carry.

**Behavior.** Changing. The report stops carrying a line saying everything survived. Observer: anyone reading the report
in any of the twenty-one dispatching skills. Settled by escalation: asked whether the editor should stop making the
blanket claim, the operator chose to narrow it.

**Why.** An unfalsifiable positive claim is what carried the false statement in the reported run, and narrowing the form
makes it impossible to write.

**Migration.** A caller that surfaces the ledger keeps working. `edit-for-readability/SKILL.md:129-136` checks whether
the ledger "flags an unresolved tension", and a narrowed ledger still flags exactly those.

**Decision.** [D-9](artifacts/change-decision-log.md#d-9-the-fact-preservation-ledger-stops-asserting-that-everything-survived)

### S-11: The insertion branch in four planning skills — Added

**Target state.** `plan-implementation`, `plan-a-change`, `plan-a-feature`, and `plan-a-phased-build` each carry a
branch for a report whose `Insertions` field names a line. The skill searches the plan for the quoted `source=` span.
If the span is absent, the skill names the insertion in the closing summary and records it in `artifacts/`, alongside
the term and the span the editor claimed. It rewrites nothing.

**Behavior.** Changing. An unsupported insertion is named where it was named nowhere before, in both the summary and
the artifacts. No sentence changes. Observer: the operator of any of the four skills. Settled by two escalations. The
operator chose to include the fourth skill, and then, once the run established there is no pre-edit draft on disk,
chose reporting over automatic reversion.

**Why.** Both report shapes the four skills anticipate are no-ops, and the third branch fires on absence only. A
report that is present and wrong routes to the first shape and stops
([C-11](artifacts/current-state-findings.md#c-11-the-readability-editors-report-is-consumed-as-fact-and-both-anticipated-shapes-are-no-ops)).
The record goes to `artifacts/` as well as the summary, for the reason `SKILL.md:459-461` already gives about a failed
check. The next skill in the chain reads the folder rather than the conversation.

**Depends on.** S-9, S-22.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-widen-the-boundary-to-the-fourth-carrier-of-the-editor-consumption-block),
[D-10](artifacts/change-decision-log.md#d-10-an-unsupported-insertion-is-reported-not-reverted)

### S-12: `Measurements` in the Step 2 discovery-notes schema — Added

**Target state.** The schema enumerated at `plan-implementation/SKILL.md:217-219` carries a `Measurements` item in the
form pinned in Target State. A figure no granted tool reaches is recorded as unreachable rather than omitted.

**Behavior.** Changing. Step 2 runs commands it did not run before, and the discovery notes gain a section. Observer:
the operator, in the discovery notes. Settled by escalation: the operator chose to measure within the current tools.

**Why.** Every input the brief carries is a path, a directive, or an excerpt, so a figure the specification asserts
reaches a specialist as an assertion
([C-9](artifacts/current-state-findings.md#c-9-the-round-brief-has-no-field-a-measured-value-could-occupy)).

**Decision.** [D-11](artifacts/change-decision-log.md#d-11-measure-within-the-current-tool-grant-and-record-what-the-grant-cannot-reach)

### S-13: The discovery-notes directive in `team-selection.md` — Re-scoped

**Target state.** The existing discovery-notes bullet names the `Measurements` block as measured input a specialist may
rely on without re-deriving, and names an unreachable figure as an assertion the specialist must treat as such.

**Behavior.** Changing. Same observer and settlement as S-12.

**Why.** A field nothing points a specialist at is a field they will not use.

**Depends on.** S-12.

**Decision.** [D-11](artifacts/change-decision-log.md#d-11-measure-within-the-current-tool-grant-and-record-what-the-grant-cannot-reach)

### S-14: The disposition on a downgraded finding — Added

**Target state.** After labeling a finding whose input nobody could inspect, the aggregation records exactly one of
`verified: {what settled it}`, `not reachable with granted tools`, or `verification not attempted`. The closing summary
names the disposition rather than the bare label.

**Behavior.** Changing. The summary reports a disposition per downgraded finding. Observer: the operator. Settled by
escalation: the operator chose to record a disposition.

**Why.** The label has no transition out of it, and it attaches to exactly the class of finding that needed a tool
nobody in the run holds
([C-10](artifacts/current-state-findings.md#c-10-the-unverified-label-has-no-transition-out-of-it)).

**Decision.** [D-12](artifacts/change-decision-log.md#d-12-a-downgraded-finding-records-whether-anyone-tried-to-verify-it)

### S-15: The deferral line in the Step 9 summary — Re-scoped

**Target state.** The summary names each deferral in plain language, in the shape the cut list already uses three
bullets above it, rather than reporting a count.

**Behavior.** Changing. A run with several deferrals produces a longer summary. Observer: the operator. Settled by
escalation: the operator chose to name them in the summary as well as adding the acceptance criterion.

**Why.** The section's only in-run consumer counts it
([C-1](artifacts/current-state-findings.md#c-1-the-deferral-section-has-four-writers-and-no-reader)), and the reason the
same file gives for naming cuts transfers: something the operator never reads is something nobody can reverse.

**Decision.** [D-13](artifacts/change-decision-log.md#d-13-the-closing-summary-names-each-deferral-instead-of-counting-them)

### S-16: The seeded acceptance criterion in the plan template — Added

**Target state.** `feature-implementation-plan-template.md`'s `Definition of Done` guidance comment seeds a criterion:
nothing in the deferral section was built, and each entry is still deferred or its reopening trigger fired and the
reopening is recorded.

**Behavior.** Changing. `synthesis-directives.md:43` says the template's guidance comments carry the per-section rules
and the synthesizer writes each section from them. So every plan produced after this change carries a criterion no plan
carried before. Observer: the implementer reading the plan. Settled by the recorded boundary: issue #193 item 3 states
this fix in its own words.

**Why.** The reported run built a deferred flag during implementation and caught it by re-reading the plan. The section
has no automated reader ([C-17](artifacts/current-state-findings.md#c-17-definition-of-done-exists-in-one-template-and-is-read-by-nothing)),
so the reader is the implementer and the plan says so.

**Depends on.** S-15.

**Decision.** [D-14](artifacts/change-decision-log.md#d-14-seed-a-definition-of-done-criterion-and-name-its-only-reader-plainly)

### S-17: The two truncated sentences — Re-scoped

**Target state.** `plan-implementation/SKILL.md`'s synthesis input list states a complete sentence, and
`synthesis-directives.md` opens with its own content rather than an orphaned tail. The same holds for
`plan-a-feature/SKILL.md` and `artifact-invariants.md`.

**Behavior.** Changing. The synthesizer receives an input list that neither file currently states completely. Observer:
the operator, in the synthesized plan's sources section, where a missed input shows as a missing link. Settled by the
recorded boundary: repairing a broken sentence is not a choice between options.

**Why.** Two skills carry the same defect from two commits with the same cause
([C-13](artifacts/current-state-findings.md#c-13-the-synthesis-input-list-is-one-sentence-split-across-a-file-boundary-in-two-skills-from-two-commits)).

**Depends on.** S-4, S-5, S-8, S-12, S-14, S-15.

**Decision.** [D-15](artifacts/change-decision-log.md#d-15-restore-both-truncated-sentences-and-add-a-move-unit-rule-to-the-guidance)

### S-18: The move-unit rule in the authoring guidance — Added

**Target state.** `progressive-disclosure.md`, beside the 500-line ceiling it states, says the unit of a move under that
ceiling is a complete sentence or a complete bullet, never a fragment.

**Behavior.** Preserving. Guidance a future refactor reads; no run behaves differently.

**Why.** Two occurrences from two commits with the same cause is a repeatable failure mode of the layout, and the rule
belongs beside the ceiling that produced it.

**Decision.** [D-15](artifacts/change-decision-log.md#d-15-restore-both-truncated-sentences-and-add-a-move-unit-rule-to-the-guidance)

### S-20: The round cap in the iteration-history template — Removed

**Target state.** The template states no round-cap number. It cites the size band chosen at the team-selection step,
which the skill body and `team-selection.md` own.

**Behavior.** Changing. The template's text is copied into a run's iteration history, so a reader of that artifact sees
a band reference where they saw a number. Observer: the operator reading
`artifacts/implementation-iteration-history.md`. The two files that own the cap are unchanged. Settled by the recorded
boundary: correcting a number that is wrong in every band is not a choice between options.

**Why.** The template's copy says four where its owners say one, two, or three, and it cites the file that contradicts
it ([C-15](artifacts/current-state-findings.md#c-15-the-round-cap-is-stated-as-four-in-the-template-and-as-one-two-or-three-in-the-two-files-that-own-it)).
The same drift has already been fixed once, which is why the copy is removed rather than corrected.

**Decision.** [D-17](artifacts/change-decision-log.md#d-17-remove-the-round-cap-number-from-the-template-rather-than-correcting-it)

### S-21: Ten link labels in five reference files — Renamed

**Target state.** Every affected link's visible label matches its target at `../../../references/`. The form
`plan-a-change/references/team-selection.md` already uses is the target state, and it exists in the repository today.

**Behavior.** Preserving. The targets already resolve; only the visible label changes.

**Why.** A label at `../../references/` resolves to `han-planning/skills/references/`, which does not exist
([C-14](artifacts/current-state-findings.md#c-14-five-reference-files-carry-link-labels-one-directory-shallower-than-their-targets)).

**Decision.** [D-16](artifacts/change-decision-log.md#trivial-decisions)

### S-22: The three existing report branches in four planning skills — Re-scoped

**Target state.** Each of the four skills' editor-consumption blocks carries four branches, and the first three are
rewritten rather than left in place. A ledger naming nothing unpreserved needs nothing further. A ledger naming a fact
kept in the original wording is left alone. An `Insertions` line whose source span is absent is reported, per S-11. Only
a report that could not be read at all routes to the branch that walks the checklist by hand.

**Behavior.** Changing, and it prevents a change. Without it every ordinary run of four skills would take the degraded
path and tell the operator no usable report came back when one did. Observer: the operator of any of the four.

**Why.** All four skills currently state their first branch as "It confirms every claim, quantity, named entity, and
stated condition survives", which is the sentence S-10 removes from the editor
([C-11](artifacts/current-state-findings.md#c-11-the-readability-editors-report-is-consumed-as-fact-and-both-anticipated-shapes-are-no-ops)).
Changing a producer's report while leaving four consumers testing for the removed sentence is the defect this change
exists to fix, reproduced inside the fix.

**Depends on.** S-10.

**Decision.** [D-21](artifacts/change-decision-log.md#d-21-reword-the-three-existing-report-branches-in-all-four-skills)

### S-23: The protected-region list in the editor brief — Re-scoped

**Target state.** The editor brief in the four skills names plan section headings referenced by the companion artifacts
as protected, alongside the code fences, tables, and `D-N` identifiers it already names. The editor leaves those
headings alone.

**Behavior.** Changing. The editor stops improving a heading the decision log references, where it previously would
have. Observer: the operator reading the finished plan's headings.

**Why.** `readability-editor.md:63` permits rewriting a heading's visible text and forbids changing an anchor, and
`Referenced in plan:` holds heading text rather than anchors. The editor runs at Step 8.5 and the check at Step 9.
Without this, the gate fires more often the better the editor does its job, and the failure line points at the decision
log rather than at the pass that caused it.

**Depends on.** S-4.

**Decision.** [D-22](artifacts/change-decision-log.md#d-22-protect-referenced-plan-headings-from-the-readability-editor)

## Behavior Changes

Most entries change something a person can observe. Six were settled by asking you, two of those after the review round
produced evidence that reversed an earlier answer. The rest are settled by the work item, which states the fix in its
own words, or are repairs with no choice of options behind them. Two entries are behavior-preserving: S-18, a line in
the authoring guidance, and S-21, a set of link labels whose targets already resolve.

**A run can now refuse to finish, in three ways.** One stop fires when the synthesis produced no plan file or only a
stub. One fires when a companion file is missing. One fires when a plan's cross-references do not resolve. Each names
the artifacts that did land and the recovery route. Observer: anyone running `plan-implementation`, and for the first
two, `plan-a-feature`. Your decision: script gate plus a stop.

**A mid-run failure now loses a different file, and says so.** With the plan written first, a synthesis that dies
halfway leaves the plan and loses the decision log. In your reported run it was the other way round and the plan had to
be written by hand. The companion-missing case is a failure rather than a non-blocking result. The run stops instead of
finishing and handing the next skill a plan whose decision links dangle.

**More questions can reach you during a round.** Two specialists disagreeing while pointing at the same past decision
now become a disputed row rather than one merged row, and a disputed row can become a question. Settled by the work
item, which proposes exactly this signal.

**The readability editor's report changes shape for every skill that uses it.** It gains a line naming each sentence it
inserted, and it stops claiming that everything else survived. Observer: anyone reading that report in any of
twenty-one skills. Your decision: narrow it.

**Four skills read that report differently.** All three existing branches are rewritten, not only extended, because the
sentence they tested for is the one being removed. A fourth branch names an insertion the editor cannot support, in the
summary and in the artifacts, and changes no text. Your decisions: include the fourth skill, and report rather than
revert.

**The editor stops improving headings the decision log references.** A plan heading named in a companion file is
protected the way the decision identifiers already are, so the new check cannot fire on a rewrite the editor was right
to make.

**Discovery runs commands it did not run before**, records what it could not reach, and records what it ran and failed.
A failed command is treated as an assertion, never as a measurement. Your decision: measure within the current tools
rather than widening the permission grant.

**The closing summary gets longer in three places.** It names each deferral instead of counting them, reports whether
anyone tried to verify a downgraded finding, and names an unsupported insertion when there is one. Your decisions on
the first two.

**The synthesizer receives a complete input list.** Today neither of the two files involved states one. Observer: the
operator, in the finished plan's sources section.

**Two plan sections that a run could previously omit are now written.** `Cut for Scope` enters the write order, and
every plan produced after this change carries a seeded acceptance criterion about deferrals. Observers: the operator
reading the cut list, and the implementer reading the criterion.

## What the Work Item Says Was Working

The boundary record carries six mechanics issue #193 says worked. It also says a change breaking one of them fails the
boundary even if it satisfies a numbered finding. This section walks all six, because it is the question the plan is
worst at asking itself.

**The deterministic aggregation.** Touched by S-7, which adds an exception to the substance pass. The pass order is
preserved and the reason for it is quoted in the decision that settles it
([D-7](artifacts/change-decision-log.md#d-7-two-findings-citing-one-identifier-with-different-figures-do-not-merge)).
The residual risk is that the exception's test is a judgment in a file that calls the aggregation deterministic. It can
only be exercised by running a round with a seeded disagreement.

**The blind-spot directive.** Touched by S-14, which adds a disposition after the label is assigned. The directive
itself is unchanged, and the disposition cannot be reached without the label. The risk worth naming is that
`verification not attempted` becomes a sanctioned outcome standing next to the directive's own line. The decision that
settles it names that as its revisit criterion.

**Domain-scoped briefs.** Touched by S-13, which adds one shared block to every brief. Domain scoping is what the
mechanic names, and it is untouched. Three specialists now share a set of measured figures, which narrows independent
re-derivation on empirical questions and is the point of the change.

**Every YAGNI deferral surviving implementation.** Strengthened by S-15 and S-16, which give the deferral list a reader
during the run and a reader at build time. Nothing weakens it.

**`junior-developer` finding the highest-value structural finding.** Untouched. No entry reaches that agent. It sat on
this plan's own review team, where it produced four blocking findings, including the two that reshaped S-11.

**The scope gate surfacing a cut in the summary.** This is the one at real risk, and not from any single entry. Three
entries lengthen the closing summary, and the cut list works partly because it is the one enumerated thing in it. The
plan accepts that cost with the reasoning recorded in
[D-13](artifacts/change-decision-log.md#d-13-the-closing-summary-names-each-deferral-instead-of-counting-them),
whose revisit criterion is exactly this. `SKILL.md:474` also currently says to keep the deferral line distinct from the
cut list, and S-15 makes the two the same shape. That sentence needs rewording as part of the entry rather than left to
contradict it.

## Change Units

Thirteen units. Each leaves the repository working and `npm test` passing on its own.

### Unit 1: Repair the in-file contradictions and land the move-unit rule

**What it does.** Corrects three places where two files disagree with each other today, and adds the one-line rule that
governs every later unit's moves.

**Delta entries.** S-2, S-18, S-20, S-21.

**Ordering constraint.** Must land before Unit 4, whose worked failure example resolves `Cut for Scope`, the section
S-2 makes reliably present. S-18 leads this unit rather than closing the change. Seven later units move text under a
size ceiling, and the rule governing those moves has to exist before the first of them.

**How you know it worked.** `npm run lint` passes. Every corrected link label resolves to a file that exists. The
iteration-history template no longer states a number the skill body contradicts.

### Unit 2: Reverse the synthesis write order

**What it does.** The plan is written first, so both companion files write backward into a file that exists.

**Delta entries.** S-1.

**Ordering constraint.** Before Unit 3.

**How you know it worked.** A run writes `feature-implementation-plan.md` before
`artifacts/implementation-decision-log.md`.

### Unit 3: Add the cross-reference script, unwired

**What it does.** Adds the script and its Bats tests. Nothing invokes it yet.

**Delta entries.** S-3.

**Ordering constraint.** After Unit 2.

**How you know it worked.** `npm test` runs the new Bats file and it passes. Run by hand against existing folders under
`docs/plans/`, the script produces `result: passed` or a named failure, never a crash. Bats coverage includes a round
whose field holds `—` (passes) and one still holding its template comment (fails), plus a plan carrying a fenced example
that contains a heading-like line.

### Unit 4: Wire the cross-reference check into Step 9

**What it does.** Step 9 runs the script beside the two checks already there.

**Delta entries.** S-4.

**Ordering constraint.** After Units 1 and 3.

**How you know it worked.** A run whose decision log names a section the plan does not have ends with
`missing-plan-section:` and a non-zero exit rather than a clean finish. A run missing a companion file ends with
`missing-artifact:` and exit 1, not exit 2.

### Unit 5: Add the synthesis-landed stop to both callers

**What it does.** Both file-writing callers confirm the plan exists and is non-empty before continuing, with the wording
and the recovery route held in one place.

**Delta entries.** S-5.

**Ordering constraint.** `han-planning/references/synthesis-failure-rule.md` must land before either skill cites it.

**How you know it worked.** A run whose synthesis produced no plan file stops, names which files did land, and names
the recovery route, instead of dispatching the readability editor.

### Unit 6: Pin the citation form and add the merge exception

**What it does.** Specialists cite a decision's field rather than the whole entry, and two of them disagreeing about the
same identifier no longer merge into one row.

**Delta entries.** S-6, S-7, S-8.

**Ordering constraint.** S-6 before S-7.

**How you know it worked.** A round in which two specialists cite one identifier with different figures produces a
disputed row carrying both readings.

### Unit 7: Change the editor's returned report

**What it does.** The shared agent reports its insertions and stops vouching for what it did not change.

**Delta entries.** S-9, S-10.

**Ordering constraint.** Must land with Unit 8, not before it. Landing S-10 alone leaves four skills testing for a
sentence that no longer exists, which routes every clean run to the branch meaning no usable report came back.

**How you know it worked.** An `edit-for-readability` run surfaces a ledger naming only unpreserved facts, or `none`,
and a report carrying an `Insertions` line or `Insertions: none`.

### Unit 8: Rewrite the editor-consumption block in four skills

**What it does.** All four branches, not only the new one. Three are rewritten to match the narrowed ledger; the fourth
reports an unsupported insertion.

**Delta entries.** S-11, S-22.

**Ordering constraint.** Ships with Unit 7 in the same change. Written to key off the presence of the `Insertions`
section, so a skill meeting an older `han-communication` takes no new action rather than failing.

**How you know it worked.** A clean rewrite routes to the first branch and the summary does not say the checklist was
walked by hand. A report naming an insertion whose source span is absent produces a summary line and an artifacts note,
and the plan's text is unchanged.

### Unit 9: Protect referenced headings in the editor brief

**What it does.** The editor leaves plan headings the companion artifacts reference alone.

**Delta entries.** S-23.

**Ordering constraint.** Before Unit 4 makes the cross-reference check blocking, or the check fires on headings the
editor was right to improve.

**How you know it worked.** A plan whose decision log references a generically-named section keeps that heading through
the readability pass.

### Unit 10: Add the measurement step

**What it does.** Discovery measures what the granted tools reach, marks what they do not, and records a failed command
as a failure rather than a number.

**Delta entries.** S-12, S-13.

**Ordering constraint.** S-12 before S-13.

**How you know it worked.** A run's `.discovery-notes.md` carries a `Measurements` block whose lines each name a
command and a returned value, say the figure is unreachable, or say the command failed with its exit status.

### Unit 11: Add the disposition on a downgraded finding

**What it does.** A finding downgraded because nobody could inspect its input records whether anyone then tried.

**Delta entries.** S-14.

**Ordering constraint.** After Unit 10, so `not reachable with granted tools` means the same thing in both places.

**How you know it worked.** The closing summary names a disposition for each downgraded finding rather than the bare
label.

### Unit 12: Give the deferral list its two readers

**What it does.** The summary names each deferral, and the plan template seeds an acceptance criterion the implementer
checks.

**Delta entries.** S-15, S-16.

**Ordering constraint.** None. S-15 also rewords the neighbouring sentence that currently tells the reader to keep the
deferral line distinct from the cut list.

**How you know it worked.** A run with two or more deferrals names each one in the closing summary, and a plan produced
after the change carries the seeded criterion.

### Unit 13: Restore the two truncated sentences

**What it does.** Repairs both split sentences.

**Delta entries.** S-17.

**Ordering constraint.** Last, so the restored tails are counted after every other addition to those two files. Unit 1
already landed the rule that governs the move if either file needs one.

**How you know it worked.** Each file's synthesis step states a complete input list without reading its reference file,
and `wc -l` on both `SKILL.md` files returns under 500.

## Risks

**The line ceiling is the tightest constraint in the plan, and the accounting was wrong once already.**
`plan-implementation/SKILL.md` has 17 lines of headroom and `plan-a-feature/SKILL.md` has 24. Eight units add to one or
both: 4, 5, 6, 8, 9, 10, 11, 12, and 13. An early draft of this plan omitted Units 6 and 8 from that list, which is
how a plan runs out of room partway through without noticing. A rough count puts the additions to
`plan-implementation/SKILL.md` at 23 to 27 lines against 17 available. The overflow is the expected case rather than a
contingency. Detectable early: run `wc -l` after each unit, and put a line estimate on each unit before starting.
Mitigation: Unit 1 lands the move-unit rule first, so every later move is governed. If a move is needed, it gets its own
delta entry rather than being folded into the unit that triggered it.

**Unit 7 and Unit 8 must ship together.** Separating them leaves four skills testing for a sentence the editor no
longer writes. That sends every clean run down the branch meaning no usable report came back, and triggers the stacked
self-review the same file gives a reasoned prohibition against. This is the one ordering constraint in the plan whose
violation is silent and universal rather than occasional.

**Unit 8 spans a plugin version boundary.** The four skills live in `han-planning` and the field they read lives in
`han-communication`, which versions separately. A user can have one updated and not the other. The branch keys off the
presence of the `Insertions` section, so a skill meeting an older editor takes no new action. The reverse skew is not
symmetric: an older `han-planning` meeting a newer `han-communication` gets the narrowed ledger and no rewritten
branches, which is the failure above. Whatever release carries Unit 7 must carry Unit 8, and the version constraint has
to say so.

**Unit 7 changes a report twenty-one skills receive.** Blast radius is the whole suite. Two consumers outside
`han-planning` do more than pass it through, and both were checked. `code-overview` receives it, and
`edit-for-readability` surfaces it and tests whether it flags a tension, which a narrowed ledger still does. Detectable
early: run `edit-for-readability` against any file and confirm the surfaced ledger reads correctly when nothing was
unpreservable.

**The new script reads documents other people wrote.** Same exposure the three existing scripts carry, and the same
mitigation: fixed-string search with `grep -qF --`, no pattern built from file content, fenced-block state tracked while
walking. The script now reads the iteration history as well as the plan, and Step 9 appends a failure note to that same
history file. So the Bats coverage must include the history file and not only the plan.

**Three new stops can halt a run that would previously have finished.** That is the point, but a false stop is worse
than no stop. Detectable early: Unit 3 lands the script unwired, so it can be run by hand against every existing plan
folder under `docs/plans/`. `.pre-commit-config.yaml` excludes those folders from linting, which makes them honest test
input. Include at least one folder whose plan the readability editor has already rewritten.

**Nothing here can be tested mechanically except the script.** Every entry but the new script is a prose edit to an instruction file, and no test in this repository asserts anything about a `SKILL.md` or a template. Every "How you know
it worked" for those units describes a future skill run. The plan does not say who performs those runs or whether a unit
merges before they happen. That is the same manual step whose absence produced findings 3 and 6. `wc -l` is the only
mechanically checkable criterion in eight of the thirteen units.

## Deferred (YAGNI)

**A general shell grant on the planning skills.** Would address the literal wording of issue #193 item 1. No evidence
shows the granted tools fell short in the reported run, and these skills read plan documents other people wrote. A
broad grant is a security-relevant change bought against an unmeasured gain. _Reopen when:_ you supply the reported
run's three decisive questions and at least one is shown unanswerable with `find`, `git`, Glob, and Grep, or
`not reachable with granted tools` appears in two or more runs.

**Reconciling the deferral entry's `Source:` field across its three definitions.** Would address
[C-16](artifacts/current-state-findings.md#c-16-the-deferral-entry-format-has-three-owners-with-three-incompatible-source-definitions).
This was a committed entry in an earlier draft and the review removed it. The argument for the cheap version was cost,
not evidence, and the same test that keeps the canonical file untouched applies to the cheaper edit
([D-19](artifacts/change-decision-log.md#d-19-defer-the-deferral-entry-layout-rather-than-pinning-it-here)).
_Reopen when:_ a single run produces deferral entries in two incompatible forms, or a reader appears that consumes
`Source:` by field.

**An `empty-field:` key on the new script.** No finding records an empty required field reaching a finished plan.
_Reopen when:_ one does.

**A shared decision-log template across the three planning skills.** Would address
[C-19](artifacts/current-state-findings.md#c-19-the-three-sibling-decision-logs-have-diverged-on-field-name-id-format-and-classification-timing).
It would need parameters for field name and classification timing, which is a configuration seam with three consumers
and no forced agreement between them. _Reopen when:_ a downstream skill reads a decision log from more than one of the
three, or the new script is copied to a second skill.

**Copying the cross-reference script to `plan-a-change` and `plan-a-feature`.** `plan-a-feature` writes four artifacts
with a different field set, so the copy would need widening on arrival. _Reopen when:_ either sibling reports a dangling
cross-reference.

**A markdown link-target checker.** Ten occurrences, one known-correct exemplar already in the repository, no second
consumer. _Reopen when:_ the mismatch reappears after this repair.

**A check that the six vendored rule copies stay identical.** All six are identical today. _Reopen when:_ a re-sync
sweep is shown to have missed a copy, or the canonical file changes more than once in a release cycle.

**Widening the synthesis-landed stop into a full artifact-set check.** The stop tests the plan; the script tests the
companions. Folding both into one `check-synthesis-landed.sh` sharing the existing exit contract is the larger version
of the same idea. _Reopen when:_ a partial-write state is found that passes both the size test and the script's keys.

## Cut for Scope

Nothing was cut. The boundary widened twice rather than excluding anything. `plan-a-phased-build` entered for finding 5
([D-1](artifacts/change-decision-log.md#d-1-widen-the-boundary-to-the-fourth-carrier-of-the-editor-consumption-block)),
and the authoring guidance file plus one sibling link label entered for their single entries
([D-23](artifacts/change-decision-log.md#d-23-widen-the-boundary-a-second-time-for-the-guidance-file-and-one-sibling-link)).
Both widenings were put to you and both were your decision.

## Open Items

**Five dispatch points still consume a returned report with no failure branch.** Non-blocking, and deliberately outside
this change. Ranked by cost of a silent loss, the first is the Step 4 parallel specialist fan-out, where a dead agent's
absence is indistinguishable from a clean report with no findings, and which feeds the ledger, the rounds, and the
synthesis. Then the `discussion-facilitator` gate-trip pass, the `junior-developer` reframing, and the
`readability-guidance` invocation that sources the fallback checklist. The fan-out is also the one that endangers a
mechanic the work item says was working. A round that silently lost one of three specialists produces a plan that reads
complete and is missing a domain. What would settle it: one sentence at Step 5 confirming one report per dispatched
specialist, reusing the `Unaudited evidence classes` field the template already carries.

**No unit states a version bump.** Non-blocking for building, blocking for shipping. `docs/semantic-versioning.md`
requires a bump per unmerged branch and calls a change to a skill's output format major. Units 7 and 8 change a report
shape twenty-one skills receive, and they must move together. That makes the constraint between `han-communication` and
`han-planning` a release question. What would settle it: deciding the bump level per plugin and which unit carries it.

**Whether the four editor-consumption blocks should move to a shared file.** Non-blocking. Unit 8 writes the same
rewrite into four files, which is the shape
[C-19](artifacts/current-state-findings.md#c-19-the-three-sibling-decision-logs-have-diverged-on-field-name-id-format-and-classification-timing)
records drifting, and Unit 5 already uses a shared file for its own wording. What would settle it: reading all four
blocks side by side to see whether they are close enough today to share one.

**Whether `plan-a-change` should carry the contract-pinning check.** Non-blocking, and outside this change. The
canonical rule names it a consumer and assigns it no stage duty, and it has no `scripts/` folder. What would settle it:
deciding whether the rule's consumer list or `plan-a-change`'s own stated principle is wrong.

**Who runs the skills end to end before a unit merges, and against what input.** Non-blocking but load-bearing. Almost every entry has no mechanical check, and their acceptance criteria all describe a future run. What would settle it: naming
a folder under `docs/plans/` as the standing rehearsal input, and saying whether a run against it gates the merge.

## Review Findings

Three specialists reviewed the draft in one round: `han-core:risk-analyst`, `han-core:on-call-engineer`, and
`han-core:junior-developer`. The round cap for a medium change is two. One was run, because no finding named a domain
the team did not cover.

Two findings were raised independently by two specialists each and merged: the insertion branch having no pre-edit draft
to revert to, and the readability editor being licensed to rewrite the heading text the new check resolves.

Nine findings changed the plan:

| Finding | What changed |
| ------- | ------------ |
| The narrowed ledger breaks the first branch in all four consuming skills | S-22 added; Units 7 and 8 must ship together |
| The editor may rewrite a referenced heading before the check reads it | S-23 added; Unit 9 added |
| The revert has no pre-edit draft and no pinned matching rule | S-11 became report-only; [D-10](artifacts/change-decision-log.md#d-10-an-unsupported-insertion-is-reported-not-reverted) reversed |
| A missing companion routed to a non-blocking exit status | Contract changed; [D-24](artifacts/change-decision-log.md#d-24-make-a-missing-companion-file-a-failure-not-an-unverified-result) |
| The plan-existence test could pass on a stub | `-size +1k` pinned into S-5 |
| The move-unit rule shipped after seven units that needed it | S-18 moved into Unit 1 |
| The line-budget accounting omitted two units | Risks corrected; per-unit estimates required |
| The deferral layout entry failed the plan's own evidence test | S-19 removed and deferred |
| Two stops and one shared file were unnamed or unpinned | Stop text, recovery route, and file name pinned |

Three findings were closed against the current-state findings rather than acted on, and four were recorded as Open
Items above rather than absorbed.

Every finding in this round carries the same `Unverified` label its author put on it. No transcript, plan folder, or
artifact from the run behind issue #193 exists in this repository, so every judgement about how a specialist behaves
rests on the instruction files as written. None of the nine findings above depends on that gap. Each was verified
against a file in this repository, and the load-bearing ones were verified a second time by me directly.
