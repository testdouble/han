# Implementation Decision Log: Planning Scope Corrections

<!--
This file records every implementation decision committed while planning Planning Scope Corrections.
Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md).
This file captures the question, rationale, evidence, and rejected alternatives for each decision.
Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).

Decisions are classified full or trivial. A decision is full when it carries a rejected
alternative, rests on evidence beyond the specification, changed across a round, has a
dependent decision, or carries recorded dissent. It is trivial otherwise.
-->

## Trivial decisions

- D-10: Reuse the visual-material strings the consumer already reads. The folder name `ui-designs/`, the table heading
  `Visual Reference`, and the inline embed form `![alt text](ui-designs/{name}.png)` are copied from the existing
  consumer rather than coined fresh. Referenced in plan: Implementation Approach (Visual material, producer and
  consumer), Work Units and Sequencing (unit 6), Definition of Done.
- D-11: The accepted file set is stated once and cited by the inventory. `planning-boundary-rule.md` names which file
  types count as visual material, and the inventory's PNG sentence cites that set instead of restating an extension.
  Referenced in plan: Implementation Approach (Visual material, producer and consumer).

## Full decisions

### D-1: Three `han-planning` reference files, grouped by what interlocks

- **Question:** How many new `han-planning` reference files do the shared commitments need, and what does each carry?
- **Decision:** Add three files under `han-planning/references/`, grouped by what interlocks rather than by
  symmetry with the commitment list.
  1. `planning-boundary-rule.md` carries the boundary record (its name, home, contents, the conflict rule,
     direction-of-travel inheritance, and operator-stated shaping context) together with the visual-material convention
     (the `ui-designs/` folder, naming, persist-on-arrival, noting each item into the boundary record, the completeness
     gate, the reference-table heading, and the inline-embed format). Consumers: all four planning skills.
  2. `scope-justification-rule.md` carries the justification field, the cut list, and the scope gate with its floor.
     Consumers: three for the justification field, since `plan-a-feature` produces no work units and takes the cut
     list only ([D-8](#d-8-plan-a-feature-gains-the-cut-list-only-not-a-justification-field)); all four for the cut
     list; three for the scope gate.
  3. `operator-escalation-rule.md` carries one question at a time, the plain-language lead, named candidate answers,
     technical references below the question or omitted, the single stop, and the escalation register. Consumers: all
     four.

  Each file opens by stating that `han-planning` owns it and that it is not a vendored copy.
- **Rationale:** The boundary record and the visual-material convention belong in one file because the completeness gate
  spans them: the run notes visual items into the boundary record as they arrive, and the gate reads that record against
  the folder. The justification field, the cut list, and the scope gate belong in one file because they share a
  destination, since an unjustified unit and a scope-gated commitment both land in the cut list. The escalation rules
  share no consumer-side interlock with either group, so they stand alone. The ownership preamble exists because every
  other file in `han-planning/references/` is a byte-identical vendored copy that a re-sync sweep could silently
  overwrite.
- **Evidence:**
  - Specification D24 mandates a `han-planning`-owned reference for the visual-material convention.
  - Each of the three files has three or four named consumers, which clears the YAGNI evidence bar for extraction.
  - `han-planning/skills/plan-implementation/SKILL.md` is 589 lines and
    `han-planning/skills/plan-a-feature/SKILL.md` is 535 lines, so inlining every shared family compounds an existing
    size problem.
  - `han-planning/references/` today holds `config-rule.md`, `evidence-rule.md`, and `yagni-rule.md`, all vendored.
- **Rejected alternatives:**
  - One combined file (information-architect's position), rejected because the escalation rules and the scope gate
    share no consumer-side interlock with the boundary record, and one file answering for three unrelated concerns
    loses cohesion.
  - Five separate files, one per commitment family (structural-analyst's position), rejected because the boundary
    record and the visual material cannot be stated independently while the completeness gate spans both, and the
    justification field and the cut list share a destination.
- **Specialist owner:** `han-core:information-architect`
- **Revisit criterion:** A fourth commitment family arrives with consumers that overlap none of the three groupings, or
  a re-sync sweep overwrites one of these files despite the ownership preamble.
- **Dissent (if any):** None recorded after the grouping evidence was presented. The round-1 dispute between the
  one-file and five-file positions closed on the interlock argument rather than by splitting the difference.
- **Driven by rounds:** R1
- **Dependent decisions:** D-2, D-3, D-11, D-15, D-16
- **Referenced in plan:** Implementation Approach (Where the shared rules live), Work Units and Sequencing (unit 1),
  Definition of Done, Risks and Assumptions

### D-2: The boundary record is a visible artifact under one filename

- **Question:** What is the boundary record called, and where does it live?
- **Decision:** Every planning skill writes and reads `artifacts/scope-boundary.md` inside the resolved plan folder. The
  name is not dot-prefixed. `plan-work-items/references/reference-artifact-inventory.md` gains this filename in its
  Include list and as a stated exception on its `artifacts/` Exclude bullet.
- **Rationale:** The record is operator-visible content. It is restated in the confirmation turn and read by downstream
  skills, which makes it unlike the internal `.discovery-notes.md`. Placing it in `artifacts/` follows the existing
  companion-artifact convention. The inventory needs the name in both its lists because a reader who scans only the
  Exclude bullet would otherwise conclude that anything under `artifacts/` is excluded.
- **Evidence:**
  - Specification D23 states the record "is admitted by name" to the work-item inventory, which presumes a name that no
    upstream decision supplies.
  - Specification D33 requires one name and one home across the four skills.
  - `han-planning/skills/plan-work-items/references/reference-artifact-inventory.md` already carries an Exclude bullet
    covering "Anything under an `artifacts/` subfolder of the plan **unless** it is a contract or design reference",
    which is the sentence the exception attaches to.
- **Rejected alternatives:**
  - A dot-prefixed `.scope-boundary.md`, rejected because dot-prefixed files in this repository mark internal run
    notes the operator is not expected to read, and this record is read back to the operator in the confirmation turn.
  - The plan folder root rather than `artifacts/`, rejected because the root holds the deliverable, and every
    companion artifact this repository produces already sits in `artifacts/`.
- **Specialist owner:** `han-core:information-architect`
- **Revisit criterion:** A downstream skill demonstrably fails to find the record under this name, which is also the
  specification's own trigger for reopening the machine-readable-format deferral.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-7, D-15
- **Referenced in plan:** Implementation Approach (Where the shared rules live), Work Units and Sequencing (unit 1),
  Definition of Done

### D-3: The missing-artifact rule stays local to `plan-work-items`

- **Question:** Where does the reconciled missing-artifact rule live, given that specification D23 names a home owned by
  one skill while the single-stop rule binds all four?
- **Decision:** The missing-artifact rule stays in
  `han-planning/skills/plan-work-items/references/reference-artifact-inventory.md` and is not cited from the other three
  skills. The general single-stop rule that binds all four lives in `operator-escalation-rule.md` instead
  ([D-1](#d-1-three-han-planning-reference-files-grouped-by-what-interlocks)). Three places in that skill are brought
  into agreement: the canonical rule in the reference, the contradicting step in `SKILL.md:134-137`, and the operating
  principle at `SKILL.md:36-40`.
- **Rationale:** The apparent conflict dissolved on reading both specification decisions in full. D23 scopes the
  reconciliation to `plan-work-items`' own two contradicting statements, one of which says surface before drafting while
  the other says note and continue. D24 separately rejects cross-skill reference links as a dependency this repository
  does not otherwise use. So the local rule and the shared rule are two different rules with two different scopes.
- **Evidence:**
  - `han-planning/skills/plan-work-items/references/reference-artifact-inventory.md`, "Missing-artifact handling",
    instructs the run to surface the gap before drafting work items.
  - `han-planning/skills/plan-work-items/SKILL.md:134-137` instructs the run to note the gap in the breakdown report
    rather than stopping. These are the two contradicting statements D23 names.
  - Specification D24 rejects cross-skill reference links by name.
  - `.discovery-notes.md` carried an earlier line placing this rule in `han-planning/references/`; that line was
    corrected in place during R1.
- **Rejected alternatives:**
  - A fourth shared `han-planning` reference holding the missing-artifact rule, rejected because it would create the
    cross-skill reference dependency D24 rejects, and because only one skill has the contradiction the rule resolves.
  - Leaving both statements in place and letting the run choose, rejected because that is the defect class D23 exists
    to remove.
- **Specialist owner:** `han-core:junior-developer`
- **Revisit criterion:** A second planning skill develops its own missing-artifact contradiction, which would give the
  rule a second consumer and reopen the extraction question.
- **Dissent (if any):** None. The claim was recorded as Disputed in R1 and resolved by reading both specification
  decisions in full rather than by choosing between the two positions.
- **Driven by rounds:** R1
- **Dependent decisions:** D-7
- **Referenced in plan:** Implementation Approach (Where the shared rules live), Work Units and Sequencing (unit 4)

### D-4: The explanation standard ships as a rule file plus an inline surfacing skill

- **Question:** What are the explanation standard and its surfacing skill called, where do they live, and where is the
  boundary against the readability standard stated?
- **Decision:** Add `han-communication/references/explanation-rule.md` as the standard and
  `han-communication/skills/explanation-guidance/SKILL.md` as the inline skill that surfaces it. The naming uses the
  `explanation-` stem to match the specification's own term, the explanation standard. No new plugin dependency edge is
  added.

  The boundary against the readability standard is stated in one canonical place plus three scent pointers: a
  `## What this standard is not` opener in the new rule file, the new skill's frontmatter `description` together with a
  reciprocal clause in `readability-guidance`'s description, the existing "A different kind of standard" bullet in
  `docs/readability.md`, and the readability-wiring introduction in `CONTRIBUTING.md`.
- **Rationale:** Specification D13 names the `readability-rule.md` and `readability-guidance` pairing as the model, so
  the new pair mirrors it exactly rather than inventing a delivery shape. Four different readers hit four different
  surfaces, which is why the boundary needs pointers as well as a canonical statement: the rule file serves the reader
  who opens the standard, the skill descriptions serve the point where skill selection happens,
  `docs/readability.md` serves the operator, and `CONTRIBUTING.md` serves the contributor.
- **Evidence:**
  - `han-communication/skills/readability-guidance/SKILL.md` is the named structural precedent, an inline skill that
    surfaces a rule into the caller's context and produces no deliverable of its own.
  - `han-planning/.claude-plugin/plugin.json` already declares `"dependencies": ["han-communication", "han-core"]`, so
    no edge is needed.
  - `docs/readability.md:15` already carries the "A different kind of standard" bullet, which is the existing sentence
    the boundary attaches to.
  - `CONTRIBUTING.md`, "Wiring the readability standard into a skill", carries the four-step wiring procedure and the
    introduction that states which standard governs what.
  - Specification F25 requires the boundary between the two standards to be stated.
- **Rejected alternatives:**
  - A `plain-language-` or `escalation-` naming stem, rejected because the specification calls the thing the
    explanation standard throughout, and a second name for one concept is the drift this change exists to remove.
  - Placing the standard in `han-planning` beside the other new references, rejected because the specification commits
    it to `han-communication` so one copy serves every plugin, and because a communication standard in a planning plugin
    could not be sourced by a future non-planning caller.
  - Stating the boundary only in the rule file, rejected because skill selection happens against the frontmatter
    description, where a reader never opens the rule file at all.
- **Specialist owner:** `han-core:information-architect`
- **Revisit criterion:** A second plugin needs the standard and cannot reach it, or escalations still read as jargon
  after the standard is in place, which is the specification's own trigger for reopening the rewrite-pass deferral.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-15, D-16
- **Referenced in plan:** Implementation Approach (The explanation standard), Work Units and Sequencing (unit 1),
  Definition of Done

### D-5: The scope gate attaches to existing YAGNI points, not to a new sweep step

- **Question:** Where does the scope gate attach in the two skills that have no sweep step?
- **Decision:** The scope gate attaches to the YAGNI reasoning each skill already performs, and no skill gains a sweep
  step it does not have. In `plan-implementation` it attaches to the existing `## Step 7.5: YAGNI Sweep`. In
  `plan-a-feature` it attaches to finding-resolution path 5a, with cut entries flowing into the Step 8 synthesis. In
  `plan-a-phased-build` it attaches to candidate evaluation in Step 4 and to the deferred-phases list.

  In `plan-a-feature` the gate reduces to a work-item check on the skill's own commitments, because that skill drafts
  from an interview rather than from an upstream artifact.
- **Rationale:** Specification line 82 governs directly: where a skill has no step a commitment attaches to, the
  commitment does not create one. The specification's applicability table calls these "the three that run a sweep",
  which is true of one skill. Attaching to the existing YAGNI reasoning delivers the same behavior without adding a step
  to two skills.
- **Evidence:**
  - `grep -i sweep` returns nothing in `han-planning/skills/plan-a-feature/SKILL.md` or
    `han-planning/skills/plan-a-phased-build/SKILL.md`. Only `plan-implementation` carries a discrete
    `## Step 7.5: YAGNI Sweep`.
  - `han-planning/skills/plan-a-feature/SKILL.md`, finding-resolution path 5a (around line 441), already applies the
    YAGNI rule with three resolution paths and feeds Step 8.
  - `han-planning/skills/plan-a-phased-build/SKILL.md`, `## Step 4: Identify Candidate Vertical Slices and Their
    Dependencies`, already applies the YAGNI evidence test and routes failures to the deferred-phases list.
  - Specification D8's phrase "commitments inherited from an upstream document" has no referent in `plan-a-feature`,
    which has no upstream artifact.
- **Rejected alternatives:**
  - Adding a sweep step to `plan-a-feature` and `plan-a-phased-build` so all three skills match the specification's
    wording, rejected because specification line 82 forbids creating a step for a commitment to attach to, and because
    a second YAGNI pass in a skill that already runs one would give two places to record the same cut.
  - Dropping the scope gate from the two skills, rejected because the applicability table commits it to all three, and
    an existing attach point in each makes the commitment deliverable.
- **Specialist owner:** `han-core:structural-analyst`
- **Revisit criterion:** A skill's YAGNI reasoning is restructured so the named attach point no longer exists.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-12
- **Referenced in plan:** Implementation Approach (Reading the applicability table against the real skill files), Work
  Units and Sequencing (unit 5), Definition of Done

### D-6: The escalation register lands as a register in two skills only

- **Question:** Where does the escalation register attach in the skills that have no escalation step?
- **Decision:** The escalation register lands as a register in `plan-a-feature` and `plan-implementation`. In
  `plan-a-phased-build` and `plan-work-items` it attaches to the single stop only, and neither skill gains an escalation
  pass. The plan states this explicitly so an implementer does not invent one.
- **Rationale:** The applicability table calls these "the three with an escalation step", which is true of two.
  `plan-a-phased-build` has no escalation step at all; its only operator turn is the shaping-context interview. Without
  the explicit statement, an implementer reading the table would add an escalation pass to that skill purely to have
  somewhere to put the register, which is the step specification line 82 forbids.
- **Evidence:**
  - `grep -c -i escalat` returns 0 for `han-planning/skills/plan-a-phased-build/SKILL.md`.
  - That skill's only operator turn is `## Step 3: Interview the User for Shaping Context`.
  - Specification line 82: where a skill has no step a commitment attaches to, the commitment does not create one.
  - The applicability table already scopes the single stop to all four, which gives the register something real to
    attach to in the two skills without an escalation pass.
- **Rejected alternatives:**
  - Adding an escalation pass to `plan-a-phased-build`, rejected under specification line 82, and because the skill's
    shaping interview already gathers what it needs from the operator in one turn.
  - Leaving the register unattached in the two skills, rejected because the single stop is itself an operator turn
    worth recording, and the specification scopes the single stop to all four.
- **Specialist owner:** `han-core:information-architect`
- **Revisit criterion:** `plan-a-phased-build` gains an escalation step for an unrelated reason.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-12, D-14
- **Referenced in plan:** Implementation Approach (Reading the applicability table against the real skill files), Work
  Units and Sequencing (unit 5), Definition of Done

### D-7: The `plan-work-items` autonomy and one-file principles are edited, not worked around

- **Question:** What happens to `plan-work-items`' stated autonomy, and to its claim that it writes exactly one file,
  once the skill gains operator turns and can establish a boundary record?
- **Decision:** Edit the skill's own principles rather than leaving them to contradict its steps. Three statements move:
  the autonomy principle at `SKILL.md:36-40`, the summary sentence at `SKILL.md:30`, and the one-file statement at
  `SKILL.md:107`.

  The completeness gate does not fire in `plan-work-items`. That skill receives no visual material of its own and
  inventories what an upstream skill persisted, so the inventory is what runs there. The one-file statement therefore
  becomes exactly one work-items file, plus a boundary record only when none already exists.
- **Rationale:** A skill whose operating principle forbids what its own step now requires is exactly the defect class
  specification D23 exists to remove, with the choice left to the run. The specification already limits how often the
  new turns fire here, which is what keeps the autonomy edit narrow rather than a reversal: the skill reads the boundary
  record rather than re-asking, and the direction-of-travel question is asked once by the earliest skill and inherited.
  The confirmation turn fires in this skill only on the absent-record path.
- **Evidence:**
  - `han-planning/skills/plan-work-items/SKILL.md:36-40` reads "Run autonomously" and "never gate on approval to
    continue".
  - `han-planning/skills/plan-work-items/SKILL.md:30` reads "It runs autonomously end to end".
  - `han-planning/skills/plan-work-items/SKILL.md:107` reads "The skill writes exactly one file".
  - Specification line 267 has `plan-work-items` read the boundary record rather than re-ask.
  - Specification line 68 makes the direction-of-travel question asked once and inherited.
  - Specification lines 157 to 161 define the absent-record path that establishes the record.
- **Rejected alternatives:**
  - Leaving the principles and relying on the steps to win, rejected because that reproduces the contradiction D23
    removes, and because the principle is stated earlier in the file than the step.
  - Suppressing the new operator turns in this skill to preserve full autonomy, rejected because the specification
    scopes the boundary read, the single stop, and the confirmation turn to all four skills.
- **Specialist owner:** `han-core:information-architect`
- **Revisit criterion:** `plan-work-items` starts receiving visual material directly rather than inventorying what an
  upstream skill persisted, which would give the completeness gate something to check here.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-14, D-15
- **Referenced in plan:** Implementation Approach (Reading the applicability table against the real skill files), Work
  Units and Sequencing (unit 4), Risks and Assumptions

### D-8: `plan-a-feature` gains the cut list only, not a justification field

- **Question:** How do the justification field and the cut list attach to a skill that produces no work units?
- **Decision:** `plan-a-feature` gains a `## Cut for Scope` section in
  `han-planning/skills/plan-a-feature/references/feature-specification-template.md`, placed immediately adjacent to
  `## Deferred (YAGNI)` at line 188. Each of the two sections opens with a one-line statement of what it is not. No
  per-behavior justification field is added to that template.
- **Rationale:** The skill produces a feature specification, not work units, so the per-unit field has nothing to attach
  to. The cut list still applies, because a scope-gated commitment needs a visible destination. The two sections sit
  adjacent because specification D35 requires the cut list to be distinct from a YAGNI deferral, and two same-shaped
  sections placed in different regions of a 236-line template get conflated by a reader who sees only one of them.
- **Evidence:**
  - `han-planning/skills/plan-a-feature/references/feature-specification-template.md` carries no work-unit section and
    no per-unit field.
  - `## Deferred (YAGNI)` sits at line 188 of that template, immediately after `## Out of Scope`.
  - Specification D35 requires the cut list to be visible, reversible, and distinct from a YAGNI deferral.
  - Specification line 82 governs the missing attach point.
- **Rejected alternatives:**
  - Adding a per-behavior justification field to the specification template, rejected because a behavior in a
    specification is not a work unit, and the field would have no consumer downstream.
  - Placing `## Cut for Scope` near the top of the template with the flows, rejected because the closing summary
    presents the cut list alongside the artifact paths, and the two lists a reader must tell apart belong side by side.
- **Specialist owner:** `han-core:information-architect`
- **Revisit criterion:** `plan-a-feature` starts producing work units.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-14
- **Referenced in plan:** Implementation Approach (Reading the applicability table against the real skill files), Work
  Units and Sequencing (unit 6), Definition of Done

### D-9: The single phased-build reviewer is outside the visual-material brief rule

- **Question:** Does `plan-a-phased-build`'s one reviewer receive the persisted visual material, given that the
  specification's Primary Flow says every dispatched reviewer does?
- **Decision:** No. The applicability table governs, and it scopes the reviewer-brief rules to the two skills that
  dispatch a domain-briefed review team. A clause stating this is added where `plan-a-phased-build`'s reviewer step is
  edited, so the next implementer does not read Primary Flow step 6 literally and widen the change.
- **Rationale:** Specification D36 makes the applicability table the governing statement, and the table names
  `plan-a-feature` and `plan-implementation` only. The Primary Flow sentence describes the flow of a skill that
  dispatches a review team. `plan-a-phased-build` does dispatch one fixed-domain reviewer, so the ambiguity is real and
  costs nothing to close in place.
- **Evidence:**
  - Specification line 72 scopes "Visual material in reviewer briefs" to `plan-a-feature` and `plan-implementation`.
  - Specification Primary Flow step 6 says "Every dispatched reviewer receives the paths".
  - `han-planning/skills/plan-a-phased-build/SKILL.md:252`, `## Step 7: Information-Architect Review of the Rendered
    Document`, dispatches exactly one reviewer with a fixed domain.
  - Specification D36 states that each commitment names the skills it applies to.
- **Rejected alternatives:**
  - Briefing the phased-build reviewer with the visual material anyway, rejected because it widens the change past the
    applicability table, and because that reviewer's domain is document structure rather than the depicted behavior.
  - Leaving the ambiguity unaddressed, rejected because the Primary Flow sentence is the one an implementer reads
    first, and silence here produces a quiet widening.
- **Specialist owner:** `han-core:structural-analyst`
- **Revisit criterion:** `plan-a-phased-build` gains a domain-briefed review team rather than a single fixed-domain
  reviewer.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach (Reading the applicability table against the real skill files), Work
  Units and Sequencing (unit 5)

### D-12: Verification is a committed acceptance checklist plus manual walkthroughs

- **Question:** How is each commitment verified in a repository with no test runner?
- **Decision:** Verification is a written acceptance checklist committed alongside the change, plus manual walkthroughs
  run against engineered inputs. No validation script and no lint over produced artifacts or skill files.
- **Rationale:** Reading the diff cannot observe whether a multi-step cross-skill behavior fires, so a walkthrough is
  needed. An unrecorded walkthrough leaves the next editor nothing, and these files move often enough that the next
  editor arrives soon. A script would assert on field presence, which means building the parseable structure the
  specification deliberately chose not to build.
- **Evidence:**
  - `.discovery-notes.md`, "Gaps: searched for and not found": no test runner, no CI job exercising skill behavior, no
    lint over skill files.
  - Ninety-day churn on the five touched skill files runs from five to ten commits each.
  - The specification's own `## Deferred (YAGNI)` defers automated validation of the visual reference table, reasoning
    that the in-run completeness gate is the cheaper first move.
  - The specification separately defers a machine-readable boundary record, because a recorded statement under one
    agreed name satisfies the same evidence.
- **Rejected alternatives:**
  - A grep-based validation script over produced artifacts, rejected because it would require the parseable structure
    the specification's own deferral declined to build, and because no incident shows the in-run gate being skipped.
  - A lint over the skill files asserting each commitment's text is present, rejected because presence of text is not
    evidence the behavior fires, which is the failure this change exists to correct.
  - Reading the diff alone, rejected because a cross-skill behavior is not observable in a diff.
- **Specialist owner:** `han-core:test-engineer`
- **Revisit criterion:** A downstream skill demonstrably fails to find the recorded boundary in prose, a run passes the
  completeness gate and still ships a specification with no reference table, or a commitment is found written into a
  skill file but demonstrably not executed across two or more separate runs.
- **Dissent (if any):** None. `han-core:test-engineer` and `han-core:junior-developer` converged independently.
- **Driven by rounds:** R1
- **Dependent decisions:** D-13, D-14
- **Referenced in plan:** Testing Strategy, Definition of Done, Risks and Assumptions, Deferred (YAGNI)

### D-13: Success criterion 3 is checked with an engineered disclosure scenario

- **Question:** How is the specification's third success criterion checked without passing vacuously?
- **Decision:** The walkthrough that checks criterion 3 positions at least one reviewer so it cannot inspect an input,
  forcing a disclosure. The criterion is never checked against a run where no reviewer disclosed a blind spot.
- **Rationale:** "No finding reaches the operator as build-blocking when its author recorded it could not inspect the
  input" is satisfied trivially by a run in which no reviewer ever disclosed anything. Choosing an input that exercises
  the rule changes no committed behavior; it only makes the check meaningful.
- **Evidence:**
  - Specification success criterion 3, at `feature-specification.md:307-308`.
  - The specification names this exact vacuous-pass shape for a different gate: D17's rationale records that a
    memory-based completeness gate "passes vacuously after a compaction", which is why the gate now reads the boundary
    record.
  - Specification D19 fires the rule on the reviewer's own disclosure, so a run with no disclosure exercises nothing.
- **Rejected alternatives:**
  - Checking criterion 3 against whichever run happens to be available, rejected because the criterion is satisfiable
    without the behavior existing.
  - Building detection for a reviewer that does not disclose its own blind spot, rejected because the specification
    already deferred that under the evidence test, with its own reopening trigger.
- **Specialist owner:** `han-core:test-engineer`
- **Revisit criterion:** A reported run shows a reviewer raising a blocking finding on an input it could not inspect,
  without saying so, which is the specification's own trigger for reopening the silent case.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-14
- **Referenced in plan:** Testing Strategy, Definition of Done

### D-14: One engineered `plan-a-feature` run carries the main walkthrough

- **Question:** Which walkthroughs are run, and what do they have to contain?
- **Decision:** The main walkthrough is a single engineered `plan-a-feature` run, because that is the only skill every
  applicability row touches. Its scenario carries six ingredients:
  - a work item with an explicit stated exclusion and an implied-but-unstated necessity, which exercises the scope
    gate's floor in both directions;
  - two supplied images at session start, one depicting something the ticket text never mentions;
  - a third image added after the review team is dispatched, which exercises the re-brief-and-record path;
  - one reviewer positioned so it cannot inspect an input
    ([D-13](#d-13-success-criterion-3-is-checked-with-an-engineered-disclosure-scenario));
  - two reviewers raising the same finding under different wording, which exercises merge-by-substance ordering.

  Three smaller follow-on checks cover what that run cannot reach: a `plan-work-items` run with no visual surface at
  all, a `plan-a-phased-build` run where the operator states scope out loud at invocation, and the two `han-feedback`
  corrections.
- **Rationale:** One rich run reaches more commitments than several thin ones, and the applicability table says
  `plan-a-feature` is where every row lands. The follow-on checks exist for the three behaviors that skill cannot
  exercise: the no-visual-surface split, operator-stated shaping context, and the feedback corrections.
- **Evidence:**
  - The applicability table at `feature-specification.md:65-80` marks `plan-a-feature` in every row.
  - Specification D27 defines the no-visual-surface split, which only `plan-work-items` performs.
  - Specification D34 makes operator-stated shaping context part of the boundary, which only `plan-a-phased-build`
    receives at invocation.
  - Specification D26 and D29 define the two `han-feedback` corrections, which no planning run touches.
  - The edge-case table commits to the late-arriving-material path, the merge-by-substance ordering, and the scope
    gate's floor in both directions.
- **Rejected alternatives:**
  - One walkthrough per skill, rejected because four thin runs cost more and reach fewer commitments than one
    engineered run plus three targeted checks.
  - A single run intended to cover everything, rejected because three behaviors are structurally out of
    `plan-a-feature`'s reach.
- **Specialist owner:** `han-core:test-engineer`
- **Revisit criterion:** A commitment lands in a skill that the engineered run and the three follow-on checks do not
  reach.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Testing Strategy, Work Units and Sequencing (unit 6), Specialist Handoffs for Implementation

### D-15: The change lands as sequenced units, not one simultaneous rewrite

- **Question:** In what order does this change land, and what makes a skill-by-skill sequence safe?
- **Decision:** Land the change as nine sequenced units, each leaving the repository coherent and each committed and
  pushed as it completes: shared plumbing first, then the agent disclosure placement rule
  ([D-19](#d-19-agent-definitions-carry-the-disclosure-placement-rule)), then the two `han-feedback` corrections, then
  `plan-work-items`, then `plan-a-phased-build`, then `plan-a-feature`, then `plan-implementation`, then the
  `han-github` screenshot file set ([D-20](#d-20-the-github-screenshot-chain-widens-with-the-accepted-file-set)), then
  the repository-root documentation sweep.

  One contract lands whole inside a single unit: the boundary record's shared name
  ([D-2](#d-2-the-boundary-record-is-a-visible-artifact-under-one-filename)), written in unit 1.

  The visual-material producer and consumer pair is deliberately split, consumer first, so the inventory has no updated
  producer between units 4 and 6. What both halves share is the exact heading string, and unit 1 fixes that string
  before either half moves. An earlier draft of this decision claimed the pair had to land together, which its own
  chosen ordering contradicted.
- **Rationale:** What makes a skill-by-skill sequence safe rather than merely convenient is specification D33's own
  fallback. A skill that finds no boundary record establishes one itself rather than proceeding unbounded, so an updated
  skill run against a folder produced by a not-yet-updated sibling still works. The order runs from least coupled to
  most: the shared references have no caller yet, `han-feedback` is fully decoupled, `plan-work-items` is smallest and
  is the canonical home for the missing-artifact rule, and `plan-implementation` is largest and highest risk and
  benefits from the shared references being proven by three prior units. The documentation sweep runs last, once the
  conventions it describes are stable.
- **Evidence:**
  - Ninety-day churn on the touched files: `plan-work-items/SKILL.md` and `plan-implementation/SKILL.md` at ten commits
    each, `plan-a-feature/SKILL.md` at eight, `plan-a-phased-build/SKILL.md` at seven, `han-feedback/SKILL.md` at five.
    A single simultaneous rewrite fights that rate of change.
  - Specification D33 and the "No boundary record exists from an earlier skill" alternate flow supply the fallback that
    makes partial adoption safe.
  - `han-planning/skills/plan-implementation/SKILL.md` is the largest of the four at 589 lines.
  - The user asked for commit-and-push as the work goes, which requires each unit to leave the repository coherent.
- **Rejected alternatives:**
  - One simultaneous rewrite across all four skills, rejected because it fights the repository's actual churn and
    because nothing would be reviewable until everything was done.
  - Landing `plan-a-feature` before `plan-work-items` so the producer precedes the consumer, rejected because the
    inventory's brief window with no updated producer is an expected intermediate state, and `plan-work-items` is the
    canonical home for the missing-artifact rule that the smallest unit can settle first.
  - Deferring the shared references until a skill needs them, rejected because three or four consumers each would then
    inline their own copy first, which is the drift this change removes.
- **Specialist owner:** `han-core:structural-analyst`
- **Revisit criterion:** A unit cannot be landed without breaking a sibling skill's run, which would mean the D33
  fallback is not doing the work claimed here.
- **Dissent (if any):** None. `han-core:structural-analyst` and `han-core:junior-developer` converged.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Opening summary, Work Units and Sequencing

### D-16: The documentation sweep covers a verified fan-out list

- **Question:** Which documentation surfaces does this change make stale, and which were checked and found to need
  nothing?
- **Decision:** The sweep covers a list that was checked file by file rather than assumed.

  Required by the repository's completeness convention, landing with the unit that creates the new skill:
  `han-communication/docs/skills/explanation-guidance.md` written from `docs/templates/skill-long-form-template.md` with
  its first Related-documentation bullet pointing at the plugin README and then the repository root, a scent line in
  `han-communication/README.md`, and an alphabetized entry in `docs/skills/README.md`.

  Stale the moment the skill lands: `han-communication/.claude-plugin/plugin.json` and
  `han-communication/.codex-plugin/plugin.json`, which both name each skill; `.claude-plugin/marketplace.json`, which
  mirrors the description; `CLAUDE.md`, in its plugin roster sentence, two tree comments, and the `han-planning`
  references line at `CLAUDE.md:105`; `CONTRIBUTING.md`, in the `han-communication` component list and the
  standards-boundary sentence; `docs/choosing-a-han-plugin.md`, whose "Owns the single canonical readability standard"
  line becomes incomplete; and `docs/readability.md`'s boundary sentence.

  Verified as needing no edit, so the plan carries no phantom work: `.agents/plugins/marketplace.json`, whose
  `han-communication` entry carries no description field at all, and `docs/readability.md`'s reader-facing skills table.

  Plus the specification's own closing obligation: the four `han-planning/docs/skills/*.md` long-form docs and
  `han-feedback/docs/skills/han-feedback.md`, each landing with its own skill's unit.
- **Rationale:** `CLAUDE.md`'s completeness convention makes the three skill-documentation surfaces non-negotiable. The
  manifests and indexes are stale by inspection rather than by judgment. Naming the two surfaces that need nothing is
  what stops a later reader from re-opening them.

  `CLAUDE.md:105` describes `han-planning/references/` as holding vendored copies only, and specification D24 requires
  correcting it to say the folder now holds both kinds. The mixed folder is not a new pattern: `han-communication/`
  already holds two owned canonical files beside a vendored `config-rule.md`.
- **Evidence:**
  - `CLAUDE.md`, "Indexes stay complete, not counted": every skill gets a long-form doc, a plugin README scent line,
    and a skills-index entry.
  - `han-communication/.claude-plugin/plugin.json` and `han-communication/.codex-plugin/plugin.json` both enumerate the
    plugin's skills by name in their descriptions.
  - `.claude-plugin/marketplace.json`'s `han-communication` entry mirrors that description.
  - `CLAUDE.md:105` reads "Cross-skill reference files vendored for han-planning skills (yagni-rule.md,
    evidence-rule.md)".
  - `han-communication/references/` holds `config-rule.md`, `readability-rule.md`, and `writing-voice.md`, which is the
    mixed-folder precedent verified on disk.
  - `.agents/plugins/marketplace.json`'s `han-communication` entry carries only `name`, `source`, `policy`, and
    `category`.
  - `docs/readability.md`'s reader-facing table lists skills whose deliverable is prose; `readability-guidance`, the
    exact structural precedent for the new skill, is absent from it.
  - Specification `## Out of Scope` closing paragraph commits the long-form docs for the four planning skills and
    `han-feedback`.
- **Rejected alternatives:**
  - Adding the new skill to `docs/readability.md`'s reader-facing table, rejected because that table lists skills whose
    deliverable is prose, and the precedent skill is absent for the same reason. Recorded as a YAGNI deferral.
  - Editing `.agents/plugins/marketplace.json`, rejected because its entry has no description to update.
  - A new ADR recording where cross-skill conventions live, rejected because the in-file ownership preamble plus the
    one-line `CLAUDE.md` correction already close the hazard. Recorded as a YAGNI deferral.
- **Specialist owner:** `han-core:information-architect`
- **Revisit criterion:** A re-sync sweep overwrites a `han-planning`-owned reference file, or a second plugin-owned file
  lands in a folder otherwise holding vendored copies.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach (Documentation fan-out), Work Units and Sequencing (unit 9),
  Definition of Done, Deferred (YAGNI), Specialist Handoffs for Implementation

### D-17: `han-planning` stays filesystem-only with no work-item read tool

- **Question:** Do the four planning skills gain a tool that reads a work item from a tracker?
- **Decision:** No. The four planning skills gain no `Bash(gh *)` grant and no narrowed form of it. `han-planning` stays
  filesystem-only. The boundary read is satisfied by the operator supplying the work item in the confirmation turn the
  run already takes, and by reading the item when it is already reachable as a local file or already present in the
  conversation.

  The plan states the consequence plainly: the recorded boundary is often the operator's own words rather than the work
  item's verbatim text.
- **Rationale:** The degraded path is not a gap. It is already fully specified, and it costs one paste inside a turn the
  run was going to take anyway. Keeping the grant out preserves the plugin's contract as reading and writing files in
  your repository and nothing else, which matters because `han-planning` is bundled by the `han` meta-plugin and the
  grant would land on everyone who installs Han.
- **Evidence:**
  - User input. The user chose this directly when the question was escalated as two separate grants.
  - The specification's "The work item cannot be found" alternate flow at `feature-specification.md:145-153` specifies
    the path fully: ask once, inside the confirmation turn, record the answer, continue with a recorded boundary.
  - The specification anticipates the paraphrase at `feature-specification.md:150-152`, which records the operator's
    scope in their own words.
  - `gh` would only ever help repositories whose work items are GitHub issues. Jira and Linear reach work items through
    the opt-in `han-atlassian` and `han-linear` MCP servers regardless.
  - `allowed-tools` is a permission allowlist, not a dependency declaration, so a granted-but-absent `gh` binary fails
    at runtime rather than degrading cleanly.
  - No `han-core` agent carries `gh`, so the `Agent` grant is not an escape hatch.
- **Rejected alternatives:**
  - A narrowed `Bash(gh issue view *)` grant, rejected by the user in favor of keeping the plugin's contract
    filesystem-only, despite the sub-command scoping precedent at `han-core/agents/project-scanner.md:7`, which carries
    `Bash(git remote *)` and `Bash(git config *)`.
  - A blanket `Bash(gh *)` grant, rejected as an unscoped GitHub grant, including destructive subcommands, on four
    skills the meta-plugin bundles.
- **Specialist owner:** `han-core:junior-developer`
- **Revisit criterion:** Operators report the pasted boundary drifting materially from the work item's actual text, or a
  run cuts something the work item did ask for because the paraphrase lost it.
- **Dissent (if any):** None. R1 recorded the missing read tool as a capability gap; R2's verification reframed it as a
  convenience gap, and the user decided on that framing.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** None
- **Referenced in plan:** Constraints and Boundaries, Implementation Approach (Tool grants), Deferred (YAGNI)

### D-18: The four planning skills gain a copy tool constrained by prompt text

- **Question:** How does a planning skill persist supplied visual material, given that none of the four can copy a file?
- **Decision:** Add `Bash(cp *)` to the `allowed-tools` line of all four planning skills, and state in each skill's own
  body that every copy destination is the resolved plan folder's `ui-designs/`. Add `Bash(mkdir *)` to
  `plan-implementation`, which is the only one of the four that lacks it.

  The plan states plainly that `allowed-tools` scopes by command prefix and not by path, so this is technically an
  unscoped copy grant. The prompt-text constraint is what narrows it, and a reviewer reading the skill can check it.
- **Rationale:** No substitute exists in the current grants, so without this the persistence commitment cannot execute
  at all and every run that receives material falls to the single stop. The user chose to grant the tool and to scope
  persistence in prompt text, so the narrow intent is stated rather than implied by the permission line.
- **Evidence:**
  - User input, on the grant and on the prompt-text constraint.
  - `Write` emits text and cannot reproduce image bytes. `Read` renders an image into context without returning bytes.
    `Glob` and `Bash(find *)` locate a file without moving it. All verified directly in R2.
  - No `han-core` agent carries `cp` or `mkdir`, so the `Agent` grant is not an escape hatch.
  - `han-planning/skills/plan-implementation/SKILL.md:10` carries `Bash(git *)` and no `Bash(mkdir *)`, while the other
    three skills carry `Bash(mkdir *)`.
  - Without the copy, specification D15, D17, D18, and D20 and success criterion 1 cannot execute.
- **Rejected alternatives:**
  - Recording host paths without copying, rejected because the per-session path does not outlive the session, per
    technical note T1, so nothing survives beside the plan. Adopting it would reopen the specification.
  - A narrowed copy grant scoped to a path, rejected because `allowed-tools` has no path scoping to express it.
  - Leaving the grant off and letting every run with material fall to the single stop, rejected because it makes the
    specification's central visual-material commitment unreachable.
- **Specialist owner:** `han-core:junior-developer`
- **Revisit criterion:** A copy destination outside the resolved plan folder is observed in a run, or `allowed-tools`
  gains path scoping.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach (Tool grants), Work Units and Sequencing (units 4, 5, 6, 7), Definition of
  Done, Risks and Assumptions

### D-19: Agent definitions carry the disclosure placement rule

- **Question:** Where is a reviewer told to put a blind-spot disclosure, so the rule that strips blocking severity has
  something to fire on?
- **Decision:** In every agent definition, as one line in the file's existing rules list, stating that a disclosure
  belongs on the finding itself and not only in an assumptions section, in one named shape both consuming skills read.
  The rule applies by a test rather than by a roster: an agent takes the line when its output is a claim a dispatching
  skill weighs, and does not when its output is an inventory of what it found or a rewritten artifact. That resolves to
  twenty-one of the repository's twenty-four agent definitions, excluding `project-scanner` and `codebase-explorer`
  (discovery output) and `readability-editor` (a rewritten artifact), and including `research-analyst` from outside
  `han-core`. An earlier draft of this decision said all twenty-two `han-core` agents take the line, for
  consistency across the roster rather than only the sixteen the two planning skills dispatch. No agent gains a field
  and no output format changes. The rule that strips blocking severity from a finding resting on an uninspected input
  stays in the two dispatching skills' briefs, where specification D19 puts it. This deliberately expands the
  specification's Out of Scope, which leaves the shared agent definitions alone.
- **Rationale:** The reported failure was placement, not disobedience. Specification D19's own rationale records that
  the reviewer did disclose its blindness, in an assumptions section well below a finding it recommended treating as
  blocking, and that "the disclosure existed and did not travel where it was needed." So these agents already produce
  the disclosure reliably, because their definitions ask for it. What no agent is told is where to put it, and
  placement is precisely what an agent definition specifies. A runtime brief asking an agent to relocate something its
  own definition positions elsewhere is the weaker mechanism, and it also has to win that argument again on every
  future model. A rule in the definition does not.
- **Evidence:**
  - Specification `decision-log.md` D19 rationale: the reviewer disclosed, and the disclosure sat in an assumptions
    section below the finding.
  - Six agents already carry a `## Assumptions` section: `data-engineer`, `devops-engineer`, `junior-developer`,
    `information-architect`, `on-call-engineer`, `user-experience-designer`. The section the reported failure used
    already exists, which is why adding another one solves nothing.
  - `han-core/agents/structural-analyst.md` already reports "Skipped dimensions: any dimensions that could not be fully
    assessed and why," which is the same idea in a summary rather than on a finding.
  - Every agent file carries a `## Rules` bullet list. It is the last heading in every file except
    `han-core/agents/gap-analyzer.md`, where `## Rules` at line 241 is followed by `## Graceful Degradation` at line
    258. That one file is handled by name rather than by appending to the end.
  - Nineteen skills across six plugins dispatch `han-core` agents, which is the measured blast radius. It includes
    `iterative-plan-review`, whose own steps this plan lists as out of scope, so the rule reaches a skill the plan does
    not otherwise touch. An earlier draft of this decision recorded twelve skills across seven plugins, which a
    repository-wide check refuted.
  - The repository holds twenty-four agent definitions, not twenty-two: `han-communication/agents/readability-editor.md`
    and `han-research/agents/research-analyst.md` sit outside `han-core`.
  - User input: the expansion was chosen over the brief-only route for consistency and for durability against future
    model changes.
- **Rejected alternatives:**
  - Brief-only delivery, which the specification committed to. Rejected by the user because it leaves the mechanism
    unproven and competing with each agent's own definition, and because a future model change could break it silently.
  - Adding a new per-finding field to each agent's output format. Rejected as the larger version of the same fix: the
    agents already disclose, so a field addition would restructure twenty-one output formats and twenty-one long-form
    docs to buy what a placement line buys.
  - Editing only the sixteen agents the two planning skills dispatch. Rejected because partial coverage of a shared
    roster is its own inconsistency, and the reviewer that goes uncovered is the one nobody remembers to check.
  - Running the thirty-minute experiment first and deciding after. Rejected by the user, who preferred the
    higher-confidence route directly rather than spending a round to justify it.
- **Specialist owner:** `han-core:structural-analyst`
- **Revisit criterion:** An agent's returned finding carries no disclosure despite an input it could not open, or the
  rule line reads as contradictory against an agent whose rules already govern the same ground.
- **Dissent (if any):** None. Note that the plan carries the wider blast radius as risk R5 rather than as a settled
  non-issue.
- **Driven by rounds:** R1, R3
- **Dependent decisions:** None
- **Referenced in plan:** Constraints and Boundaries, Implementation Approach (Where the blind-spot disclosure is
  stated), Work Units and Sequencing (unit 2), Definition of Done, Risks and Assumptions, Open Items, Specialist
  Handoffs for Implementation

### D-20: The GitHub screenshot chain widens with the accepted file set

- **Question:** Widening the accepted visual-material file set past PNG changes a folder a second plugin also reads.
  What happens to that plugin?
- **Decision:** `han-github`'s `work-items-to-issues` widens to the same set, in all three places it is hardcoded: the
  upload script's asset-selection pattern, the embed rules' source-filename requirement, and the issue template's own
  embed markdown and path scheme. One file-set convention
  spans both plugins, with no mismatch to document. It lands as its own work unit, depending only on unit 1 fixing the
  set.
- **Rationale:** `plan-a-feature` persists visual material into a folder, and two separate consumers read that folder:
  `plan-work-items` builds work items from it, and `work-items-to-issues` uploads it into GitHub issues. Widening one
  consumer and not the other converts a silent drop into a broken image, which is worse than the defect being fixed:
  the item reaches the work item and then fails at the last hop, where nobody is looking. The alternative that keeps
  scope smaller leaves two conventions for one folder, which is the drift this whole change set exists to remove.
- **Evidence:**
  - `han-github/skills/work-items-to-issues/scripts/upload-screenshots.sh:47` selects assets with a pattern ending in
    a literal `.png`, so a non-PNG asset is never uploaded.
  - `han-github/skills/work-items-to-issues/references/screenshot-embed-rules.md:27` requires the embedded filename to
    match a `.png` source in the visual-material folder.
  - `han-github/skills/work-items-to-issues/references/issue-template.md` carries the embed markdown an implementer
    copies, and a stated path scheme, both ending in `.png`. A verification round found this third location after the
    decision was first written with two. Widening the upload without widening the template produces an issue body that
    writes a PNG extension over a file that is not one.
  - The plan's own documentation fan-out claimed the surfaces were checked file by file; `han-github` was not in that
    list, and this decision closes the gap the review found.
  - User input: widen `han-github` too, chosen over scoping the widening to the planning consumer.
- **Rejected alternatives:**
  - Scoping the widened set to the planning consumer only and leaving `han-github` on PNG. Rejected by the user because
    it leaves two conventions for one folder and pushes the failure to the last hop.
  - Dropping the widening entirely and keeping PNG everywhere. Rejected because the silent-drop defect stays, which is
    what raised the decision.
- **Specialist owner:** `han-core:structural-analyst`
- **Revisit criterion:** A third consumer of the visual-material folder appears, at which point the accepted set wants
  a single stated home rather than three files agreeing.
- **Dissent (if any):** None. Note this adds an executable shell script to a change set that is otherwise prose, which
  is why the unit carries its own run-the-script verification rather than a read-through.
- **Driven by rounds:** R4
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach (Visual material, producer and consumer), Work Units and Sequencing
  (unit 8), Definition of Done

### D-21: The acceptance checklist has a path and an owning unit

- **Question:** Where does the acceptance checklist live, who writes it, and how is unit 1 verified against a checklist
  that does not exist when unit 1 starts?
- **Decision:** It lives at `docs/plans/planning-scope-corrections/artifacts/acceptance-checklist.md`, one section per
  work unit, ordered by the risk ranking in the Testing Strategy. Unit 1 writes the sections it can fill and stubs the
  rest; each later unit fills its own section as it lands. `han-core:test-engineer` authors the initial structure.
- **Rationale:** The checklist carries three loads: it is the sole mitigation for the coverage risk, the stated
  verification for two units, and a Definition of Done item. An artifact with three loads and no address is a promise.
  The circularity is real and the fix is ordinary: a checklist written incrementally is verifiable at every unit,
  where one written up front is verified against commitments whose attach points do not exist yet.
- **Evidence:**
  - The plan's Definition of Done requires the checklist committed alongside the change.
  - Units 1 and 9 both state their verification as a read-through against it.
  - The risk register names it as the mitigation for the commitments that have no individual success criterion.
  - The precedent for caring about an artifact's exact name is this plan's own boundary-record decision
    ([D-2](#d-2-the-boundary-record-is-a-visible-artifact-under-one-filename)), which spent a full decision on a
    filename because a downstream reader has to find it.
- **Rejected alternatives:**
  - Writing the whole checklist in unit 1. Rejected because ten of the commitments it must cover are defined by units
    4 through 7, so unit 1 would be writing against attach points that do not exist.
  - Writing it last, after every unit lands. Rejected because units 1 and 9 name it as their verification, so it has
    to exist from the first commit.
  - Leaving it unaddressed and letting the implementer choose. Rejected because two units verify against it, and a
    verification target nobody can locate is not a verification.
- **Specialist owner:** `han-core:test-engineer`
- **Revisit criterion:** The checklist and the Definition of Done drift apart, at which point one of the two is
  redundant.
- **Dissent (if any):** None.
- **Driven by rounds:** R4
- **Dependent decisions:** None
- **Referenced in plan:** Testing Strategy, Work Units and Sequencing (unit 1), Definition of Done

### D-22: The target length's effectiveness is not tracked

- **Question:** The proportionality signal ships delivered by brief alone, and nothing proves a reviewer honors it.
  Should the plan carry that as an open question?
- **Decision:** No. The signal ships exactly as specification D28 requires, and nothing measures whether it works. The
  open item is closed as ignored by user decision, the walkthrough no longer checks returned review length, and the
  concern stays visible only as accepted risk R1 with no owner and no mitigation.
- **Rationale:** The user was given the question in plain language and dismissed it. That is a legitimate disposition
  for a risk whose worst case is the status quo: if the target proves inert, reviewer output stays as long as it is
  today, which is what happens if the signal were never added. Nothing degrades and no operator is misled. Carrying it
  as an open item would have cost a walkthrough check and a specialist dispatch to learn something the user has said
  they do not want to know.
- **Evidence:** User input, given directly after the question was presented with its consequence, its failure mode, and
  its designed fallback. Specification D28's rejected alternatives already keep a hard cap on record as the fallback, so
  the reopening path exists whenever anyone wants it, without this plan tracking it.
- **Rejected alternatives:**
  - Keeping the open item and checking length during the walkthrough. Rejected by the user.
  - Dropping the proportionality signal itself. Rejected because specification D28 commits to it and this plan does not
    reopen settled behavior; the user dismissed measuring the signal, not shipping it.
  - Recording it in the deferred section. Rejected because nothing is being deferred: the work ships in full, and only
    the verification of its effect is dropped.
- **Specialist owner:** None. The risk is accepted unowned.
- **Revisit criterion:** Someone reports reviewer output that is disproportionate to the size of the work item, at which
  point specification D28's hard cap is the ready answer.
- **Dissent (if any):** None recorded. Note that `han-core:test-engineer` raised the underlying concern in the build
  rounds and `han-core:junior-developer` raised it again in review; both are answered by accepting the risk rather than
  by refuting them.
- **Driven by rounds:** R1, R3, R4, R6
- **Dependent decisions:** None
- **Referenced in plan:** Constraints and Boundaries, Risks and Assumptions, Open Items, Review History

### D-23: The completeness gate in `plan-work-items` covers only what that run received

- **Question:** `plan-work-items` runs late in the chain and usually receives no visual material of its own. Does its
  completeness gate check only material that run took in, or the whole boundary record including material an earlier
  skill persisted?
- **Decision:** Only material that run itself received. Material an earlier skill persisted is the inventory's business,
  and the inventory already reads that folder and already notices when an item it maps is absent. The shared boundary
  reference records this scope as settled rather than leaving the choice to the run.
- **Rationale:** The decisive argument is what a failure would produce. If material an earlier session saved has gone
  missing, this run cannot recover it, because the session that held the file is over. A broad gate would therefore
  report a problem nobody present can fix, and the plan already has a rule for that case: an artifact nobody can supply
  is recorded and drafted around, never stopped for. The broad reading buys a note and costs a second read of the
  boundary record plus a change to the skill's own statement about how many files it writes.
- **The applicability table stays satisfied:** The specification gives "persist and confirm visual material" to all four
  skills. This decision scopes the gate in one skill rather than removing it, so the commitment is present there.
- **Evidence:**
  - The consumer reference already inventories the folder and maps each item to a work item, so absence is already
    observable there without a second gate.
  - The missing-artifact rule this plan reconciles splits on who can supply the artifact, and cross-session loss falls
    on the nobody-can-supply side ([D-3](#d-3-the-missing-artifact-rule-stays-local-to-plan-work-items)).
  - `plan-work-items` states that it writes exactly one file. The narrow reading leaves that statement needing one
    edit; the broad reading would need a second ([D-7](#d-7-the-plan-work-items-autonomy-and-one-file-principles-are-edited-not-worked-around)).
  - User input: the recommendation was presented with both readings and their costs, and accepted.
- **Rejected alternatives:**
  - Checking the whole boundary record, making this skill a last line of defense before work items ship. Rejected
    because its only outcome on a real failure is a note about material nobody in the session can restore, duplicating
    coverage the inventory already provides.
  - Leaving the scope unstated and letting each run decide. Rejected because that is the defect class this whole change
    set exists to remove: a rule with two readings and the choice left to the run.
- **Specialist owner:** `han-core:information-architect`
- **Revisit criterion:** A run ships work items referencing visual material that went missing between sessions, and the
  inventory did not catch it.
- **Dissent (if any):** None.
- **Driven by rounds:** R4, R6
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach (Where the shared rules live), Risks and Assumptions, Open Items,
  Review History

### D-24: The explanation standard carries guidance only and no self-check

- **Question:** The new explanation standard mirrors the readability pairing. The readability rule ends in a six-item
  self-check that consuming skills run as a discrete step. Does the new rule carry one too?
- **Decision:** No. `explanation-rule.md` carries guidance only, and none of the four planning skills gains a check
  step. The mirroring covers the file pairing and the inline surfacing skill, not the check.
- **Rationale:** The specification already made this call one level up. It considered a rewrite pass for escalation
  prose and deferred it, reasoning that a standard the escalating skills source while drafting satisfies the same
  evidence as a separate reviewing pass, because the evidence was that escalations were written in jargon rather than
  that a review of them was missing. A self-check is a smaller version of that same rejected pass, performed by the
  skill instead of an agent, so the deferral's logic reaches it without a new argument.

  Two further reasons. The artifact is the wrong size for an audit: the readability check earns its keep over a whole
  document, where a reader can lose the thread across many paragraphs, while this standard governs one conversational
  turn. And a check would invent four steps the specification forbids, since its rule is that where a skill has no step
  a commitment attaches to, the commitment does not create one, and none of the four skills has a check step for this.
- **The gap this accepts:** Nothing verifies the standard took effect. That is the same gap the specification accepted
  when it deferred the rewrite pass, and it carries the same reopening trigger, so the two stay consistent rather than
  one being stricter than the other.
- **Evidence:**
  - The specification's own deferred entry for a rewrite pass for escalation prose, with its stated reasoning.
  - `han-communication/references/readability-rule.md` ends in a six-item standardized self-check that consuming skills
    run as a discrete step, which is the machinery this decision declines to copy.
  - The four planning skills already run the readability check over their written deliverables, which is where a
    post-draft audit belongs and already exists. An escalation is a turn rather than a deliverable.
  - User input: the guidance-only version was recommended with its accepted gap stated, and accepted.
- **Rejected alternatives:**
  - Mirroring the readability rule fully, including its self-check. Rejected because it obliges four skills to gain a
    check step, which is both a materially larger edit and four steps the specification's own rule forbids inventing.
  - Leaving the question to unit 1's author. Rejected because the larger version looks like the faithful reading of
    "mirror the readability pairing," so an implementer would plausibly pick it by accident.
- **Specialist owner:** `han-core:information-architect`
- **Revisit criterion:** Escalations still read as jargon after the standard is in place. This is deliberately the same
  trigger the specification attached to its own deferral of the rewrite pass.
- **Dissent (if any):** None.
- **Driven by rounds:** R4, R6
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach (The explanation standard), Open Items, Review History
