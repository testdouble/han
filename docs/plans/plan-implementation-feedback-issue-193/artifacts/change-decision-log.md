# Change Decision Log: plan-implementation feedback (issue #193)

<!--
This file records every decision committed while planning the response to issue #193.
The plan itself lives in [../change-plan.md](../change-plan.md) — this file captures the
question, rationale, evidence, and rejected alternatives behind each decision.
Evidence about the code as it stands today lives in
[current-state-findings.md](current-state-findings.md) as numbered C-N findings.
-->

## Trivial decisions

- D-16: Correct ten link labels — every `[../../references/X.md](../../../references/X.md)` in the five affected files gets its label corrected to match its target, matching the form `plan-a-change/references/team-selection.md` already uses. — Referenced in plan: Surface Delta, Change Units.
- D-18: Add `Cut for Scope` to both section lists — `synthesis-directives.md`'s write order and its lazy-section list each gain the section its own invariant 5 already requires, positioned immediately before `Deferred (YAGNI)` as the plan template already places it. — Referenced in plan: Surface Delta, Change Units.

## Full decisions

### D-1: Widen the boundary to the fourth carrier of the editor consumption block

- **Question:** `plan-a-phased-build` carries the same readability-editor consumption block as the three skills in scope, and was in none of the files the operator confirmed at the opening turn. Does the fix reach it?
- **Decision:** Yes. `han-planning/skills/plan-a-phased-build/` enters scope for finding 5 only, and for nothing else. Its Step at `SKILL.md:383-395` receives the same fourth branch as the other three.
- **Rationale:** The four skills carrying the block are the complete set among the twenty-one that dispatch the editor, so fixing three of four leaves one skill able to ship an invented sentence while its siblings catch it. The divergence would be invisible: the four blocks are near-identical today, so a reader would reasonably assume they still behave alike.
- **Evidence:** C-11. Verified myself: `grep -rln "two shapes" --include="SKILL.md"` returns exactly `plan-implementation`, `plan-a-change`, `plan-a-feature`, and `plan-a-phased-build`, while `grep -rln "readability-editor" --include="SKILL.md"` returns twenty-one files across eight plugins. `system-architect` SA3 independently established the same split.
- **Behavior impact:** Changing. An operator running `plan-a-phased-build` can now see a sentence reverted to its pre-edit wording. The operator's answer: include it.
- **Rejected alternatives:**
  - Leave it out and record the divergence — rejected because the operator chose to include it, and because a knowingly divergent fourth copy is the shape C-19 already documents drifting across three decision-log templates.
  - Include it and sweep the other seventeen dispatchers first — rejected because the sweep already ran and returned exactly four carriers, so the sweep would confirm what is established rather than find anything.
- **Revisit criterion:** A fifth skill adopts the consumption block, or the block moves to a shared `han-planning/references/` file.
- **Settles delta entry:** S-11
- **Dependent decisions:** D-10
- **Referenced in plan:** Why This Change, Behavior Changes, Surface Delta

### D-2: Write the plan first in the synthesis order

- **Question:** The synthesis writes three cross-referenced files. Which order leaves the fewest references pointing at something that does not exist?
- **Decision:** Reorder the numbered list in `synthesis-directives.md:27-57` to plan, then decision log, then iteration-history backfill. The decision-classification sentence (`classify each decision as full or trivial before writing it`) moves up to a preamble sentence ahead of the list, so every `D-N` identity and its full-or-trivial status is settled before either file is written.
- **Rationale:** `feature-implementation-plan.md` is the hub both companions point into. Written second, it forces `Referenced in plan:` to be filled against a guess about sections that do not exist yet. Written first, both companions write backward into a file that exists. Hoisting the classification is what keeps the plan's inline `([D-N](...))` links resolvable when the plan is written before the log.
- **Evidence:** C-3. Issue #193 item 4 proposes exactly this: "A synthesis step that writes three cross-referenced files might be more robust if it wrote the primary plan first, since that is the artifact the other two point into." `system-architect` SA1 established that the write order lives entirely in `han-planning` and that `plan-synthesizer` carries no ordering instruction, so no shared-agent edit is needed.
- **Behavior impact:** Changing. An operator whose synthesis terminates mid-run now loses the decision log rather than the plan. In the reported run the plan was the artifact that had to be written by hand. Settled by the recorded boundary: issue #193 states this fix in its own words, so it was not escalated.
- **Rejected alternatives:**
  - Teach `plan-synthesizer` the write order as a built-in — rejected because two of its four callers write no files at all (`plan-work-items/SKILL.md:231`, `han-research`'s `gap-analysis/SKILL.md:309`), so a built-in artifact set would break customers outside this issue's scope.
  - Add a revisit pass that backfills `Referenced in plan:` after the plan is written — rejected because it keeps the wrong order and adds a step, where the reorder removes the problem. The simpler structure satisfies the same evidence.
- **Revisit criterion:** A fourth file joins the artifact set, or a companion file gains a reference the plan must point at rather than the reverse.
- **Settles delta entry:** S-1
- **Dependent decisions:** D-3, D-5
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units

### D-3: Add an executed cross-reference check rather than restating the invariant in prose

- **Question:** The invariant that `Referenced in plan:` names real plan sections is stated in prose in two places and is what failed. What enforces it?
- **Decision:** A new `han-planning/skills/plan-implementation/scripts/check-plan-cross-references.sh`, with Bats tests beside it, invoked at Step 9 beside the two checks already there. Contract pinned:

  ```
  Usage: check-plan-cross-references.sh <plan.md> <implementation-decision-log.md> <implementation-iteration-history.md>

  result: passed | failed | unverified
  reason: <plan-missing | decision-log-missing | history-missing | plan-unreadable>
                                                               only when result is unverified
  missing-plan-section: <id> field=<field> section=<heading>   zero or more, only when failed
  missing-decision: <D-N> cited-by=plan line=<n>               zero or more, only when failed
  empty-field: <id> <field>                                    zero or more, only when failed

  Exit: 0 passed, 1 failed, 2 could not verify.
  ```

  A worked failure line, which is the reported run's own defect:

  ```
  result: failed
  missing-plan-section: D-4 field=Referenced in plan section=Cut for Scope
  ```

  Three fields are resolved: `Referenced in plan:` on every `D-N` and `Changed in plan:` on every `R-N`, both against `^##+ ` headings in the plan; and every `([D-N](artifacts/implementation-decision-log.md#...))` in the plan against declared `D-N` entries in the log. Heading comparison is on visible text after case-folding and trimming.

- **Rationale:** The prose invariant already exists at `synthesis-directives.md:59-60` and in the decision-log template, and the reported run had both. A rule that is already written and still failed is not fixed by writing it a third time. The repository has three working examples of the alternative, and they share one output contract and one input-safety stance to copy.
- **Evidence:** C-2 for the unchecked field; C-19's second bullet for why prose has no check behind it in this repository. C-P3 in the project context records the three script precedents. Operator input: asked whether a run should refuse to finish when cross-references do not resolve, the answer was "Script gate plus a stop".
- **Behavior impact:** Changing. A run whose plan is missing a section its decision log names now ends with a named failure instead of finishing clean. Observer: the operator running `plan-implementation`.
- **Rejected alternatives:**
  - A fifth output key on `check-contract-pinning.sh` — rejected because that script's stated job is a shared contract left for the build to invent, a dangling section name has a different fix and a different operator response, and folding them grows one Bats file to cover two concerns.
  - A prose invariant only, with no script — rejected on the evidence above: the prose invariant is what failed.
  - Reusing `iterative-plan-review/scripts/check-cross-references.sh` unchanged — rejected because it resolves `D-N`-style identifiers between two companion files and does not resolve a section heading named inside a field. Its helpers (`outside_fences`, `declared_ids`, `field_value`, `is_populated`) transfer, and the new script copies them rather than the whole script.
- **Revisit criterion:** A second skill needs the same check, at which point the field-name differences C-19 records (`Referenced in plan:` versus `Referenced in spec:`, `D-N` versus `D#`) become a real contract and get unified first.
- **Settles delta entry:** S-3, S-4
- **Dependent decisions:** D-4
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units, Risks

### D-4: Stop the run when synthesis produced no plan file

- **Question:** Nothing detects a synthesis that returned partially or not at all. Where does detection go, and what does it do?
- **Decision:** At the close of Step 8 in `plan-implementation/SKILL.md`, confirm the plan file exists before proceeding, using `find {same-folder-as-source} -maxdepth 1 -name feature-implementation-plan.md`. Absent means the synthesis did not produce its primary artifact: stop, report which of the three files did land, and do not run Step 8.5. `Bash(find *)` is already granted, so no permission change.
- **Rationale:** Step 8.5 currently dispatches the readability editor against a path that may not exist, and the closing summary reports on a plan nobody confirmed was written. The reported run recovered only because a person noticed by hand. Step 1's overwrite prompt is not a recovery path: it cannot tell a complete prior run from a half-written one.
- **Evidence:** C-4. Issue #193 item 4 records the failure occurring in a real run. `system-architect` SA2 established that detection belongs in the caller because the caller owns the artifact set and `han-core` does not know what that set is.
- **Behavior impact:** Changing. A run whose synthesis dies mid-write now refuses at Step 8 with a named missing artifact, where it previously flowed into the readability pass. Observer: the operator. The operator chose "Script gate plus a stop" over a gate with no stop.
- **Rejected alternatives:**
  - A completion manifest in `plan-synthesizer`'s returned report — rejected because it is a shared-surface change reaching four callers to serve two, it needs a new dispatch-time field to be meaningful for the two that write no files, and an older `han-core` returning no manifest would leave an updated `han-planning` with a check that never fires. Caller-side detection works against every version of `han-core`.
  - A resume path that re-dispatches the synthesizer — rejected because nothing distinguishes a complete prior run from a half-written one, so a re-dispatch cannot know what to redo.
- **Revisit criterion:** A third file-writing caller of `plan-synthesizer` appears, or caller-side detection is shown to miss a partial write it should have caught.
- **Settles delta entry:** S-5
- **Dependent decisions:** D-5
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units, Risks

### D-5: Put the plan-existence stop in both file-writing callers, worded once

- **Question:** `plan-a-feature` also dispatches `plan-synthesizer` to write files. Does the D-4 stop go there too, and how is the wording kept from drifting?
- **Decision:** Yes, both `plan-implementation` and `plan-a-feature` get the stop. The wording lives once, in a new short section of an existing `han-planning/references/` file rather than as two independently-worded paragraphs, and each skill cites it in one sentence.
- **Rationale:** Both skills have the same failure and the same artifact ownership. Writing the paragraph twice is the exact shape C-19 documents drifting across three sibling templates, and the line ceiling makes two full paragraphs expensive: `plan-implementation/SKILL.md` is at 483 lines and `plan-a-feature/SKILL.md` at 476, against a stated ceiling of 500.
- **Evidence:** C-4 for the failure; C-19 for the drift precedent; C-P2 and the verified `wc -l` for the line budget. `progressive-disclosure.md:53`: "Treat 500 lines as the ceiling, not the target." `system-architect` SA2 raised the drift exposure and named this mitigation.
- **Behavior impact:** Changing. An operator running `plan-a-feature` sees the same new refusal as one running `plan-implementation`. This follows from D-4, which the operator settled; the extension to the second caller is settled by the recorded boundary, which includes `plan-a-feature`.
- **Rejected alternatives:**
  - `plan-implementation` only — rejected because `plan-a-feature` has the identical failure and is inside the recorded boundary, so leaving it produces a divergence with no reason behind it.
  - Two independently-worded paragraphs — rejected on the C-19 drift evidence and the line budget.
- **Revisit criterion:** The two skills' artifact sets diverge enough that one sentence cannot cover both.
- **Settles delta entry:** S-5
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta, Change Units, Risks

### D-6: Pin citation to the field, not the decision entry

- **Question:** A specialist cites a decision by its `D-N` identifier, which resolves to an entry carrying both the committed option and the declined ones. How is the committed half made unmistakable?
- **Decision:** Extend the existing citation directive at `team-selection.md:161-164` with the pinned form:

  ```
  D-4 / Decision:                     the option the upstream run committed to
  D-4 / Rejected alternatives: B      an option that run declined; any figure quoted from
                                      this field is attributed to the rejected option
  ```

  A citation naming only `D-4` is read as the `Decision:` field.

- **Rationale:** The citation unit is one level coarser than the semantic unit. Nothing in the brief path tells a specialist that `Rejected alternatives:` holds options the upstream run declined, and the distinction is stated once in the whole skill and only on the write side. Extending the existing bullet keeps the responsibility where it already lives.
- **Evidence:** C-5. Issue #193 item 2 states this suggestion in its own words: "state in the brief that figures quoted from a `Rejected alternatives` block must be attributed to the rejected option."
- **Behavior impact:** Changing. Specialist reports carry field-level citations, observable to anyone reading `implementation-iteration-history.md`. Settled by the recorded boundary: the work item states the fix.
- **Rejected alternatives:**
  - Passing the decision log's contents inline rather than as a path — rejected because `team-selection.md:102-104` passes it as a path on purpose, so the agent reads on demand, and inlining it would enlarge every brief to fix a labeling problem.
  - Restructuring the decision-log template so rejected alternatives live in a separate section with their own identifiers — rejected as a larger structure satisfying the same evidence, and it would have to be done three times across the diverged sibling templates C-19 records.
- **Revisit criterion:** A specialist misreads a field-level citation, which would mean the labeling is not the binding constraint.
- **Settles delta entry:** S-6
- **Dependent decisions:** D-7
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units

### D-7: Two findings citing one identifier with different figures do not merge

- **Question:** Pass A merges by substance before `Disputed` is assigned, so competing readings of one decision can collapse into a single well-supported-looking row. What separates a misread from a genuine disagreement?
- **Decision:** Add a merge exception at the `Disputed` definition in `round-aggregation.md:12`. Two findings citing the same identifier while asserting different figures do not merge under Pass A. They become one `Disputed` row carrying both readings and both originating specialist identifiers. `SKILL.md` Pass A gains one complete sentence pointing at that exception.
- **Rationale:** A genuine disagreement usually cites different evidence, so identical evidence with divergent figures is a misread signal rather than a conflict. Merging first is correct for the reason `SKILL.md:256-258` gives, and this is an exception inside Pass A rather than a reordering of the passes.
- **Evidence:** C-6. Issue #193 item 2 states this suggestion in its own words: "treat two specialists disputing a point while citing the same identifier as a signal that one has misread it, since a genuine disagreement usually cites different evidence." The issue's "What worked well" section names the deterministic aggregation as a mechanic that worked, which is why the pass order is preserved.
- **Behavior impact:** Changing. A round that previously produced one merged row now produces a `Disputed` row, which becomes an Open Question and can reach the operator as a question. Observer: the operator, in the Step 6 escalation queue. Settled by the recorded boundary.
- **Rejected alternatives:**
  - Reorder the passes so `Disputed` is assigned before the merge — rejected because `SKILL.md:256-258` states why merging runs first and the issue names that ordering as working. The exception keeps the order and its reason.
  - An executed check over the merge — rejected for the reason the skill already gives about Pass B at `SKILL.md:270-272`: specialist output is still in conversation and not on disk, so a script would have nothing to read.
- **Revisit criterion:** A merged row is found to have absorbed a genuine disagreement that cited different evidence, meaning the identifier test is too narrow.
- **Settles delta entry:** S-7, S-8
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units

### D-8: The editor reports what it inserted, with the source span it drew from

- **Question:** The editor may insert an explanation for a term the reader cannot look up, and nothing in its report says it did. How does an insertion become visible?
- **Decision:** Add a fourth item to `## What you return` in `han-communication/agents/readability-editor.md`. Pinned:

  ```
  - **Insertions** — one line per sentence you added, or the single word `none`.
    Insertion: term="round cap" source="The round cap from Step 3 sets the upper bound"
  ```

  The `source=` value is a quoted span from the pre-edit draft the explanation was written from.

- **Rationale:** Criterion 5 already requires the explanation be written from what the draft says, so the field records a constraint the agent already carries rather than adding one. The field is additive, so a caller that does not read it is unaffected, which matters because the plugins version independently.
- **Evidence:** C-12. Issue #193 item 5 reports the insertion. `system-architect` SA4 established the additive-only constraint: a caller at an older version meeting a newer `han-communication` gets one section it was never told to read, and all four planning skills route an unrecognized shape to the branch that walks the full self-check, which is strictly more conservative rather than a failure.
- **Behavior impact:** Changing. Operators of all twenty-one dispatching skills see a longer editor report. Only the four planning skills act on it, and only once D-10 lands.
- **Rejected alternatives:**
  - Remove criterion 5's insertion sanction outright — rejected because it reaches all twenty-one callers and removes a capability nothing in the findings says is unwanted. C-12's complaint is that the insertion is unreported, not that it is unwelcome.
  - Report insertions only to planning skills — rejected because the agent cannot know which caller it serves without a new dispatch-time flag, which is a larger cross-plugin contract than one always-on report section.
  - A second agent auditing the editor's output — rejected as a dispatch per run, and it is the stacked-review pattern the canonical readability rule bars.
- **Revisit criterion:** A caller is found parsing the report positionally, which an added section would break.
- **Settles delta entry:** S-9
- **Dependent decisions:** D-9, D-10
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units

### D-9: The fact-preservation ledger stops asserting that everything survived

- **Question:** The ledger made a blanket positive claim and named a figure the source never held. Does the ledger's shape change?
- **Decision:** Narrow it in `readability-editor.md`. Pinned:

  ```
  - **Fact-preservation ledger** — name only the facts you could not preserve in the
    rewrite's own wording and kept verbatim instead. Quote each one. Write `none` when
    there were none. Do not assert that the rest survived.
  ```

  Step 3 gains a companion clause: confirm in both directions, that no fact appears in the rewrite that the draft did not carry.

- **Rationale:** An unfalsifiable positive claim becomes impossible to write. This closes the false-preservation half of finding 5 by construction rather than by adding a checker, at zero runtime cost.
- **Evidence:** C-12. Verified myself that the two skills outside `han-planning` which do more than receive the ledger both keep working under the narrowed form: `code-overview`'s ledger references are almost entirely its own separate context ledger, with one line concerning the editor's; `edit-for-readability/SKILL.md:129-136` surfaces the ledger and checks whether it "flags an unresolved tension", which a narrowed ledger still does. Operator input: asked whether the editor should stop making the blanket claim, the answer was "Narrow it".
- **Behavior impact:** Changing. The editor's report gets shorter and stops carrying a line that says everything survived. Observer: anyone reading the report in any of the twenty-one dispatching skills.
- **Rejected alternatives:**
  - Add `Insertions` and leave the ledger — rejected by the operator. It fixes the invented-sentence half and leaves the false-claim half open.
  - Narrow it in `han-planning` only — not available. The ledger's shape is defined in the agent's own file in `han-communication`; there is no per-caller version.
- **Revisit criterion:** A caller is found to depend on the positive assertion for something other than surfacing it.
- **Settles delta entry:** S-10
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units, Risks

### D-10: An unsupported insertion is reported, not reverted

- **Question:** When the editor names an inserted sentence whose claimed source span is not in the draft, what happens to that sentence?
- **Decision:** The four planning skills name it in the closing summary and record it in `artifacts/`, and leave the text alone. No write to the plan on this path.
- **Rationale:** The whole detection gain survives, and the plan makes no write on a failure path. Reverting is not executable as specified: there is no pre-edit draft to revert to, and on an ordinary run the search would fail for reasons that have nothing to do with an unsupported insertion.
- **Evidence:** C-11 for the missing branch; C-12 for the insertion path. Three independent review findings, each verified against the files:
  - The editor rewrites the plan in place (`readability-editor.md:142`, "Rewrite the prose in place"; `plan-implementation/SKILL.md:403`, "Apply its rewrite to the plan file") and the skill reads the report afterward, so the only draft on disk when the check runs is the post-edit one.
  - The `source=` span is quoted from the pre-edit draft. Where the editor also rewrote the sentence the gloss was drawn from, that span is gone by construction. That is the common case, not an edge case, because rewriting prose is the agent's job.
  - `.prettierrc.json` sets `printWidth: 120` with `proseWrap: preserve`, so a span longer than roughly a dozen words straddles a newline in the file and arrives in the report as one line. A literal search misses, and the miss rate rises with span length.
  - An inserted sentence has no original wording to restore; its prior state is absence. "Revert to its original wording" was not an executable instruction.
- **Behavior impact:** Changing. An unsupported insertion is named in the summary and in the artifacts where it was named nowhere before. No sentence is rewritten. Observer: the operator running any of the four skills.
- **Rejected alternatives:**
  - Revert automatically — the operator's first answer, revisited once the evidence above was established and reversed by the operator on that evidence. It would have removed correct sentences on ordinary runs, with the record of the removal living only in the closing summary.
  - Snapshot the plan file before the editor runs, then revert against the snapshot — rejected. It costs a step and lines in four skills against a ceiling with 17 lines of headroom, `plan-a-change` lacks the `Bash(cp *)` grant the other three hold (C-8), and it would still need a pinned matching rule for whitespace and fence boundaries.
- **Revisit criterion:** A reported insertion is confirmed unsupported in a real run and the operator declines to remove it by hand, or the `Insertions` field reports a false claim twice.
- **Settles delta entry:** S-11
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units

### D-11: Measure within the current tool grant, and record what the grant cannot reach

- **Question:** Issue #193 item 1 asks for a measurement step on the premise that the orchestrator holds execution tools. It does not. What does the measurement step do instead?
- **Decision:** Add a `Measurements` item to the Step 2 discovery-notes schema in `plan-implementation/SKILL.md:217-219`. Pinned:

  ```
  - Measurements: for each figure the specification asserts that the plan will rest on,
    the figure as asserted, the command run, and the value it returned.
    Measurement: spec says "roughly 40 fixture files" | find test/fixtures -type f | 112
  ```

  A figure no granted tool reaches is recorded as `Measurement: {figure} | not reachable with granted tools`. `team-selection.md`'s discovery-notes bullet is extended so the brief names the block as measured input a specialist may rely on without re-deriving, and names an unreachable figure as an assertion the specialist must treat as such. The permission grant is not widened.

- **Rationale:** The measurement gap is real and the fix is worth making, but the work item's premise about the orchestrator's tools is wrong. `find`, `git log`, Glob and Grep reach a large class of the figures a plan rests on. Recording what they cannot reach makes the remaining gap visible instead of silent, which is the property the issue actually wanted.
- **Evidence:** C-8 for the grant, verified myself by reading all three `allowed-tools` blocks: none carries `wc`, `jq`, a test runner, or a build. C-9 for the missing brief field. C-10 for the label with no exit. Operator input: asked how the measurement step should work, the answer was "Measure within the current tools".
- **Behavior impact:** Changing. Step 2 now runs commands it did not run before, and `.discovery-notes.md` gains a section. Observer: the operator, in the discovery notes.
- **Rejected alternatives:**
  - Widen `allowed-tools` to general `Bash` — rejected by the operator, and on evidence. C-8 establishes the grant is narrow; nothing establishes that the granted tools fell short in the reported run. These skills read plan documents other people wrote, so a broad grant is a security-relevant change to buy an unmeasured increment. Deferred with a trigger.
  - Skip the measurement step — rejected. A figure the specification asserts keeps reaching specialists as an assertion, which issue #193 item 1 names as the root of a wrong plan decision.
- **Revisit criterion:** The operator supplies the reported run's three decisive questions and at least one is shown unanswerable with the current grant, or `not reachable with granted tools` appears in two or more runs.
- **Settles delta entry:** S-12, S-13
- **Dependent decisions:** D-12
- **Referenced in plan:** Why This Change, Target State, Surface Delta, Behavior Changes, Change Units, Deferred (YAGNI)

### D-12: A downgraded finding records whether anyone tried to verify it

- **Question:** Pass B labels a finding `Unverified` when a specialist could not inspect its input, invites the orchestrator to verify it, and requires nothing. The label is then reported as terminal. What closes the loop?
- **Decision:** After labeling, Pass B records a disposition on the ledger row, exactly one of `verified: {what settled it}`, `not reachable with granted tools`, or `verification not attempted`. The Step 9 report line at `SKILL.md:476-477` names the disposition rather than the bare label.
- **Rationale:** Read together with D-11, the label attaches to exactly the class of finding that needed a tool nobody in the run holds. A real blocking finding downgraded for that reason currently keeps the downgrade through synthesis and into the summary, with nothing recording that no one looked.
- **Evidence:** C-10. Operator input: asked whether the run should record whether anyone tried, the answer was "Record a disposition".
- **Behavior impact:** Changing. The closing summary reports a disposition per downgraded finding instead of a bare label. Observer: the operator.
- **Rejected alternatives:**
  - Require verification before the label sticks — rejected because some inputs are genuinely unreachable, so a requirement would either be unsatisfiable or would be satisfied by a token attempt.
  - Leave it as is — rejected by the operator. This is not a finding issue #193 raised, and skipping it would keep the change smaller, but a real blocking finding can reach the operator looking non-blocking.
- **Revisit criterion:** `verification not attempted` becomes the dominant disposition, meaning the disposition records the gap without closing it.
- **Settles delta entry:** S-14
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units

### D-13: The closing summary names each deferral instead of counting them

- **Question:** The deferral section has four writers and one consumer, which counts entries. Who reads a deferral during the run?
- **Decision:** Replace the count at `plan-implementation/SKILL.md:474-475` with a naming, matching the cut-list treatment three bullets above it in the same file.
- **Rationale:** The reason stated for the cut list transfers verbatim: something the user never reads is something nobody can reverse. The cut-list precedent is in the same file, so the shape is already established and needs no argument of its own.
- **Evidence:** C-1 for the writer-with-no-reader; `SKILL.md:471-473` for the cut-list precedent and its stated reason. Operator input: asked whether the summary should name each deferral, the answer was "Name them in the summary too".
- **Behavior impact:** Changing. A run with several deferrals produces a visibly longer summary. Observer: the operator.
- **Rejected alternatives:**
  - Only the Definition of Done line, as issue #193 item 3 proposes — rejected by the operator. Taken alone it gives the deferral list one reader at build time and none during the run.
  - Make `plan-work-items` read the deferral section — rejected on evidence. `plan-work-items/SKILL.md:117` explicitly bars process artifacts from work-item bodies, so this would require reversing a stated rule to serve one finding.
- **Revisit criterion:** Summaries grow long enough that naming deferrals crowds out the behavior changes, which the same summary must show.
- **Settles delta entry:** S-15
- **Dependent decisions:** D-14
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units

### D-14: Seed a Definition of Done criterion, and name its only reader plainly

- **Question:** Issue #193 item 3 proposes a Definition of Done line asserting nothing deferred was built. That section has no reader either. Is the line still worth adding?
- **Decision:** Yes. Add a seeded criterion to the `Definition of Done` guidance comment in `feature-implementation-plan-template.md:61-66`. Pinned:

  ```
  - [ ] Nothing in `## Deferred (YAGNI)` was built. Each entry is still deferred, or its
        `Reopen when:` trigger fired and the reopening is recorded.
  ```

  Its reader is the implementer at build time, outside this repository's skill chain, and the plan says so plainly rather than implying a mechanism.

- **Rationale:** In the reported run the deferred flag was built during implementation and caught by re-reading the plan. The criterion puts that check where the building happens. C-17 establishes the section has no automated reader, so the honest framing is that this is a human check, not a gate.
- **Evidence:** C-1 and C-17. Issue #193 item 3 states the fix in its own words: "A single line in the Definition of Done asserting that nothing in the deferred section was built would have caught it without a re-read."
- **Behavior impact:** Preserving. This changes a template's guidance comment. No step in any run behaves differently; the plan's reader sees one more seeded criterion.
- **Rejected alternatives:**
  - An executed check answering "was a deferred item implemented" — rejected because nothing on disk records what was built, so no script in this repository can answer it.
  - Skip it because the section has no automated reader — rejected. The reader is a person, and the reported run shows a person catching exactly this by hand.
- **Revisit criterion:** The criterion is found unticked or ticked without checking across several plans, meaning a seeded line is not enough.
- **Settles delta entry:** S-16
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Change Units

### D-15: Restore both truncated sentences and add a move-unit rule to the guidance

- **Question:** Two skills carry an instruction sentence split across a file boundary, from two different commits, both of which moved body text into a reference file under the line ceiling. What stops the third occurrence?
- **Decision:** Restore the complete input-list sentence to `plan-implementation/SKILL.md:391-394` and delete the orphaned tail from `synthesis-directives.md:6-7`. Make the same repair in `plan-a-feature/SKILL.md:395-403` and `artifact-invariants.md:38-39`. Then add one line to `han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md:53`, beside the ceiling it states: the unit of a move under the 500-line recommendation is a complete sentence or a complete bullet, never a fragment.
- **Rationale:** Two occurrences from two commits with the same cause is a repeatable failure mode of the layout, not two typos. The rule belongs beside the ceiling that produced it, because that is the text a future refactor reads.
- **Evidence:** C-13. Verified myself with `git log -S`: the `plan-implementation` break entered in `61708bb`, "refactor(plan-implementation): bring the skill body under the 500-line ceiling"; the `plan-a-feature` break entered in `0e9f38c`. Both commits moved SKILL.md body text into a reference file under a size constraint.
- **Behavior impact:** Changing. The synthesizer currently receives an input list neither file states completely, and after the repair it receives a complete one. Observer: the operator, in the synthesized plan's `Sources and Plan Records` section, where a missed input shows as a missing link. Settled by the recorded boundary: this is a defect inside the named area, and repairing a broken sentence is not a choice between options.
- **Rejected alternatives:**
  - Repair the two sentences and skip the guidance line — rejected because the cause recurs and the two repairs do nothing about it.
  - A script checking for sentences split across file boundaries — rejected as infrastructure ahead of a form nobody has specified. A sentence's end is not mechanically decidable in markdown prose without a parser this repository does not have.
- **Revisit criterion:** A third truncation appears after the guidance line lands.
- **Settles delta entry:** S-17, S-18
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta, Behavior Changes, Change Units, Risks

### D-17: Remove the round-cap number from the template rather than correcting it

- **Question:** The iteration-history template states a four-round cap twice and cites the skill's Step 6 as its source. Step 6 and `team-selection.md` both state a size-banded cap of one, two, or three. Correct the number or remove it?
- **Decision:** Remove it. `implementation-iteration-history-template.md:13-16,63` cites the band instead: `The iteration loop is capped by the size band chosen at Step 3.`
- **Rationale:** The template carries a copy of a value two other files own. Correcting the copy leaves the copy. This exact drift has already recurred once, which is evidence that correcting it does not hold.
- **Evidence:** C-15, verified myself across all three files. C-15 records a prior commit, "fix the stale round range", showing the drift already recurred.
- **Behavior impact:** Preserving. The template stops carrying a number a run could copy into a round entry. No step behaves differently; the two files that own the cap are unchanged.
- **Rejected alternatives:**
  - Correct four to the banded values — rejected because it reproduces the copy that drifted, and the same drift has already been fixed once.
- **Revisit criterion:** The banded cap becomes a single number again, at which point one owner could carry it.
- **Settles delta entry:** S-20
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta, Change Units

### D-19: Defer the deferral entry layout rather than pinning it here

- **Question:** Three files define the deferral entry's `Source:` field differently. Is the conflict resolved in this change?
- **Decision:** No. Neither `yagni-rule.md` nor `synthesis-directives.md` is edited for this. The divergence moves to `## Deferred (YAGNI)` with a reopening trigger.
- **Rationale:** My first answer pinned the layout in `synthesis-directives.md` on the ground that it is one edit against six re-syncs. Review found that argument to be about cost rather than evidence, and it is right: this decision's own rejected-alternative reasoning for leaving the canonical file alone was "C-16 establishes divergence, not consequence," and that reasoning applies just as well to the cheaper edit. `yagni-rule.md`'s own bar is evidence of need, not cheapness. Applying my own stated test consistently means deferring both halves.
- **Evidence:** C-16, with its attribution corrected: `CLAUDE.md:97` names `han-core/references/` as canonical and `CLAUDE.md:120` lists `yagni-rule.md` among `han-planning/references/`'s vendored files. All six copies are byte-identical, verified with `md5 -q`. C-1 establishes the section has no reader that would notice the disagreement. `han-core:junior-developer` raised this as a YAGNI candidate; `han-core:system-architect` reached the same conclusion independently for the canonical half.
- **Behavior impact:** Preserving. Nothing changes.
- **Rejected alternatives:**
  - Pin the layout in `synthesis-directives.md` — rejected on the reasoning above. It was my first answer and the evidence test defeats it.
  - Edit the canonical `yagni-rule.md` and re-sync six copies — rejected on the same test, at higher cost.
- **Revisit criterion:** A single run produces deferral entries in two incompatible `Source:` forms, or a reader appears that consumes `Source:` by field rather than reading it as prose.
- **Settles delta entry:** —
- **Dependent decisions:** —
- **Referenced in plan:** Deferred (YAGNI)

### D-20: Do not unify the three sibling decision-log templates

- **Question:** Three near-parallel decision-log templates have diverged on field name, identifier format, and classification timing. Are they unified?
- **Decision:** No. They stay as they are, and the divergence is recorded with a reopening trigger.
- **Rationale:** The three templates live in skills that never read each other's output, so the coupling cost is maintenance rather than runtime. Two of the five differences are reasoned rather than drift: `plan-a-feature` writes a specification, so `Referenced in spec:` is correct for it, and its deferred-classification rule states a reason the other two never answer, that two promotion signals do not exist at draft time. A shared owner would need parameters for field name and classification timing, which is a configuration seam with three consumers and no forced agreement between them.
- **Evidence:** C-19. No in-repository reader crosses between the three logs.
- **Behavior impact:** Preserving. Nothing changes.
- **Rejected alternatives:**
  - A shared decision-log template owned by `han-planning` — rejected as a single-implementation abstraction with a configuration seam, which is the signature YAGNI failure of this skill's own domain.
- **Revisit criterion:** A downstream skill reads a decision log from more than one of the three, or `check-plan-cross-references.sh` is copied to a second skill. At that point the field name and the `D#`/`D-N` split become a real contract and get unified first.
- **Settles delta entry:** —
- **Dependent decisions:** —
- **Referenced in plan:** Deferred (YAGNI)

### D-21: Reword the three existing report branches in all four skills

- **Question:** All four consuming skills test for the exact sentence [D-9](#d-9-the-fact-preservation-ledger-stops-asserting-that-everything-survived) removes from the editor. What happens to those branches?
- **Decision:** All four skills' editor-consumption blocks are rewritten, not merely extended. The branches become: the ledger names nothing unpreserved, so nothing further is needed; the ledger names a fact kept in the original wording, which you leave alone; `Insertions` names a line whose source span is absent, which you report; and no usable report came back, which is the only branch that walks the checklist.
- **Rationale:** Changing a producer's report shape while leaving four consumers testing for the removed sentence is the defect this whole change exists to fix, reproduced inside the fix. Adding a fourth branch was not enough: the first three had to change with it.
- **Evidence:** `han-core:risk-analyst` raised this as the round's one critical finding, and I verified it directly. All four skills state branch 1 as "It confirms every claim, quantity, named entity, and stated condition survives": `plan-implementation/SKILL.md:412`, `plan-a-feature/SKILL.md:419-420`, `plan-a-change/SKILL.md:333-334`, `plan-a-phased-build/SKILL.md:398`. A narrowed ledger reading `none` matches neither that nor branch 2, so it falls to the branch meaning no usable report came back, which instructs the skill to walk the full checklist. That branch would then fire on the most common outcome, a clean rewrite, and would trigger the stacked same-model self-review `SKILL.md:406-409` gives a reasoned prohibition against.
- **Behavior impact:** Changing, and it prevents a change. Without this, every ordinary run of four skills would take the degraded path and tell the operator no usable report came back when one did. Observer: the operator of any of the four.
- **Rejected alternatives:**
  - Add the fourth branch and leave the first three — the plan's first form. Rejected on the evidence above.
  - Keep the ledger's positive assertion so branch 1 still matches — rejected because it reinstates the unfalsifiable claim [D-9](#d-9-the-fact-preservation-ledger-stops-asserting-that-everything-survived) exists to remove.
- **Revisit criterion:** A fifth skill adopts the block, or the editor's report shape changes again.
- **Settles delta entry:** S-22
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units, Risks

### D-22: Protect referenced plan headings from the readability editor

- **Question:** The editor may rewrite a heading's visible text, and the new cross-reference check resolves `Referenced in plan:` against heading text. The editor runs first. How is the collision avoided?
- **Decision:** The editor brief in the four skills gains one sentence: plan section headings the companion artifacts reference are protected the same way the `D-N` citation identifiers already are. The brief sentence at `SKILL.md:402-404` already names a protected list and is extended rather than duplicated.
- **Rationale:** Without this the gate fires more often the better the editor does its stated job, and the failure line points at the decision log rather than at the pass that caused it. Protecting the heading is cheaper than teaching the check to tolerate a rewrite, and it does not touch the shared agent.
- **Evidence:** `han-core:on-call-engineer` and `han-core:risk-analyst` raised this independently, and I verified it. `readability-editor.md:63`: "You may rewrite a heading's visible text to be descriptive, but never change an anchor another part of the document links to." Its protected list at lines 54-61 covers code fences, diagram bodies, rendered markup, citation identifiers, and heading anchor targets, and does not cover heading visible text. `readability-editor.md:84` names a generic heading as an anti-pattern the agent exists to fix, so rewriting one is expected behavior. Step 8.5 precedes Step 9.
- **Behavior impact:** Changing. The editor leaves referenced headings alone where it would previously have improved them. Observer: the operator reading the finished plan's headings.
- **Rejected alternatives:**
  - Pin `Referenced in plan:` to the anchor rather than the visible heading — correct by construction, since the editor never changes an anchor, but it changes a field's contract in two templates and every existing plan folder written under the old form. Larger structure, same evidence.
  - Run the check before the readability pass as well as after — rejected as two invocations to avoid one collision, and it does not stop the rewrite from breaking the link afterward.
  - Add a caller-declared protected-strings parameter to the editor — rejected as a new cross-plugin contract serving one caller family.
- **Revisit criterion:** A second caller needs cross-document string protection, at which point the parameter becomes worth its contract.
- **Settles delta entry:** S-23
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units, Risks

### D-23: Widen the boundary a second time, for the guidance file and one sibling link

- **Question:** Two entries reach files outside the recorded boundary: the authoring guidance in `han-plugin-builder`, and one link label in `iterative-plan-review`. Are they in this change?
- **Decision:** Both are in. `han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md` and `han-planning/skills/iterative-plan-review/references/team-selection.md` enter scope for their single entries only.
- **Rationale:** The guidance line is what stops the truncation defect recurring, and it belongs beside the ceiling that produced it. The link label is one of ten occurrences of one mistake and splitting it would leave nine fixed and one not.
- **Evidence:** `han-core:junior-developer` established that neither file appears in the boundary record and that the record documents one widening. Verified: the ten label occurrences span five files, one of which is in `iterative-plan-review`. Operator input: asked whether to include both or split them, the answer was include both.
- **Behavior impact:** Preserving for both. Guidance text a future author reads, and a visible link label whose target already resolves.
- **Rejected alternatives:**
  - Include the link fix and split the guidance edit — rejected by the operator. It would ship the truncation repair without the rule that prevents the next one.
  - Split both — rejected by the operator, for the same reason.
- **Revisit criterion:** —
- **Settles delta entry:** S-18, S-21
- **Dependent decisions:** —
- **Referenced in plan:** Why This Change, Surface Delta, Change Units

### D-24: Make a missing companion file a failure, not an unverified result

- **Question:** With the plan written first, a synthesis that dies partway leaves the plan and loses a companion. The pinned contract routed a missing companion to `unverified`, which the skill defines as non-blocking. Is that right?
- **Decision:** No. `decision-log-missing` and `history-missing` become `result: failed`, exit 1. `unverified` is reserved for `plan-unreadable`. The plan-existence stop also gains a non-emptiness test, `-size +1k`, and the run's stop text is pinned rather than left to the build.
- **Rationale:** The write order reversal improves which artifact survives a mid-run death and does nothing for detection unless the checks move with it. Without this, the new partial-write state passes the stop, passes the readability pass, and reports non-blocking at Step 9, so the run finishes and hands the next skill a plan whose every inline decision link dangles. That is the reported incident with the halves swapped, and it would be silent.
- **Evidence:** `han-core:on-call-engineer`, which walked the three termination states the new order creates. `SKILL.md:435-441` defines exit 2 as "could not verify" with "The run still finishes the rest of its work." `find` exits 0 whether or not it matches, so an existence test with no size predicate puts the verdict in stdout, in a skill whose stated convention four lines from the wiring point is that the exit status carries the outcome.
- **Behavior impact:** Changing. A run that lost a companion file now stops instead of finishing and reporting non-blocking. Observer: the operator. This follows from the escalation that chose a script gate plus a stop; it makes that answer effective rather than adding a new decision.
- **Rejected alternatives:**
  - Leave the companions as `unverified` — rejected on the evidence above. It is the state the plan's own reordering creates.
  - Widen the stop to a full artifact-set check now — a larger version satisfying the same evidence. Kept as the next iteration and named in Open Items, because the contract change and the size predicate close the silent path at one line each.
- **Revisit criterion:** A partial-write state is found that passes both the size test and the three contract keys.
- **Settles delta entry:** S-3, S-5
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes, Change Units, Risks
