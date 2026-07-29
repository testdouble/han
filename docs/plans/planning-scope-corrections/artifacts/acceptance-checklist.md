# Acceptance Checklist: Planning Scope Corrections

This is the verification record for the change. The repository has no test runner and no CI job that exercises skill
behavior, so every commitment is checked either by a read-through against a named file or by a manual walkthrough against
an engineered input
([D-12](implementation-decision-log.md#d-12-verification-is-a-committed-acceptance-checklist-plus-manual-walkthroughs)).

Unit 1 wrote the structure and filled the sections it could. Each later unit fills its own section as it lands
([D-21](implementation-decision-log.md#d-21-the-acceptance-checklist-has-a-path-and-an-owning-unit)). A section marked
`Not yet landed` is waiting on its unit, not failing.

The sections are ordered by the risk ranking in the plan's Testing Strategy, highest risk first, rather than by unit
number.

## How to read a check

Each check states what you would look at and what you would see. A check that needs a run to produce it says which run.
Anything that cannot be observed from a file or a run is not a check, and is not listed here.

---

## Risk 1: Visual material reaches every reviewer, including items arriving after dispatch

This is the one commitment with a documented prior failure, and it is silent when broken.

**Status:** Not yet landed. Delivered by units 6 and 7; checked by the engineered walkthrough
([D-14](implementation-decision-log.md#d-14-one-engineered-plan-a-feature-run-carries-the-main-walkthrough)).

- [ ] Every dispatched reviewer's brief carries the paths to the persisted visual material, alongside the existing
      artifact-paths directive, with an instruction to read them. Read-through of `plan-a-feature` and
      `plan-implementation` at their dispatch steps.
- [ ] A third image arriving after the review team is dispatched is persisted, the reachable reviewers are re-briefed,
      and the run records which reviewers never received it. Observed in the engineered walkthrough.
- [ ] A finding from a reviewer that never received the material, and which turns on that material, is recorded as
      unverified. Observed in the engineered walkthrough.

## Risk 2: An uninspected input strips blocking severity from findings resting on it

Also a documented prior failure, and silent by construction. Both halves are checked, because the agent writes the
disclosure and the dispatching skill acts on it.

**Status:** Not yet landed. The agent half is delivered by unit 2 and the skill half by units 6 and 7.

- [ ] Every agent whose output is a claim a dispatching skill weighs carries the disclosure-placement rule line, in one
      named shape, in its `## Rules` list. Read-through covers all twenty-four agent definitions in
      `han-core/agents/`, `han-communication/agents/`, and `han-research/agents/`.
- [ ] The three exclusions are logged with the reason each was excluded: `project-scanner` and `codebase-explorer`
      (discovery output), `readability-editor` (a rewritten artifact).
- [ ] `gap-analyzer` carries the line inside its `## Rules` section rather than after `## Graceful Degradation`, which
      follows `## Rules` in that one file.
- [ ] No agent gained a field and no agent's output format changed. Read-through of the diff.
- [ ] A live dispatch against an input the agent cannot open returns the disclosure in the named shape, run once per
      output-format shape rather than once overall.
- [ ] The dispatching skill recognizes that shape and strips blocking severity from the finding. Read-through of
      `plan-a-feature` and `plan-implementation` at their finding-resolution steps, plus the engineered walkthrough.

## Risk 3: The completeness gate reads the boundary record rather than run memory

An agent naturally reasons over what it remembers, which is the failure mode the gate was redesigned to avoid.

**Status:** Rule landed in unit 1. Skill wiring not yet landed; delivered by units 4 through 7.

- [x] `planning-boundary-rule.md` states that the gate reads the record, names why (a memory-based gate passes
      vacuously after a compaction), and names the partial-loss case it also catches.
- [x] The record's `## Visual Material Received` section is a table with one row per item, so the gate has something to
      iterate.
- [ ] Each of the four planning skills notes each arriving item into the record as it arrives, and runs the gate before
      declaring its artifact finished. Read-through per skill.
- [ ] In `plan-work-items` the gate covers only material that run itself received, never material an earlier skill
      already persisted
      ([D-23](implementation-decision-log.md#d-23-the-completeness-gate-in-plan-work-items-covers-only-what-that-run-received)).

## Risk 4: The scope gate's floor holds

The highest-nuance new rule. A wrong cut looks legitimate because it carries a citation.

**Status:** Rule landed in unit 1. Skill wiring not yet landed; delivered by units 5, 6, and 7.

- [x] `scope-justification-rule.md` states the floor: the gate cuts subsystems, integrations, and artifacts the work
      item never asks for, and does not cut behavior required to deliver what it does ask for.
- [x] The rule carries the calibration line from the source issues: an unmentioned image subsystem is a correct cut;
      validation, focus behavior, error copy, tests, and accessibility on the card the ticket did ask for are not.
- [ ] The gate attaches to each skill's existing YAGNI reasoning, and no skill gained a sweep step it did not have
      ([D-5](implementation-decision-log.md#d-5-the-scope-gate-attaches-to-existing-yagni-points-not-to-a-new-sweep-step)).
      Read-through per skill.
- [ ] A run against a work item with an explicit stated exclusion and an implied-but-unstated necessity cuts the first
      and keeps the second. Observed in the engineered walkthrough.

## Risk 5: A conflicting work item surfaces the conflict

The default disposition is to proceed with whatever was stated most recently.

**Status:** Rule landed in unit 1. Skill wiring not yet landed; delivered by units 4 through 7.

- [x] `planning-boundary-rule.md` states that a skill handed a work item different from the recorded one surfaces the
      conflict in its confirmation turn, asks which governs, and records the resolution in Record Provenance.
- [ ] Each of the four planning skills carries that rule at its confirmation turn. Read-through per skill.

---

## Unit 1: Shared plumbing

**Status:** Landed. Verified by read-through, as no caller exists yet.

- [x] `han-planning/references/planning-boundary-rule.md` exists and opens by stating that `han-planning` owns it and it
      is not a vendored copy.
- [x] `han-planning/references/scope-justification-rule.md` exists and opens with the same statement.
- [x] `han-planning/references/operator-escalation-rule.md` exists and opens with the same statement.
- [x] The ownership preamble is one fixed form, byte-comparable across the three files, so the Definition of Done item is
      checkable.
- [x] The boundary record's name and home are fixed at `artifacts/scope-boundary.md` inside the resolved plan folder,
      not dot-prefixed
      ([D-2](implementation-decision-log.md#d-2-the-boundary-record-is-a-visible-artifact-under-one-filename)).
- [x] The record has named sections: Work Item, Stated Scope, Stated Exclusions, Operator-Stated Scope, Direction of
      Travel, Visual Material Received, Record Provenance.
- [x] "Beside the plan" is resolved: the folder the skill resolves for its own primary deliverable wins, and a
      `plan-work-items` run that inherits a record from another folder names that path in Record Provenance.
- [x] The accepted visual-material file set is enumerated: `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.svg`, `.pdf`.
- [x] A URL is handled separately from a file: recorded as a row with the URL in place of a kept path, never reported as
      kept on disk.
- [x] The three shared strings are fixed once: the folder `ui-designs/`, the table heading `Visual Reference`, and the
      inline embed form `![alt text](ui-designs/card-empty-state.png)`
      ([D-10](implementation-decision-log.md#trivial-decisions)).
- [x] `han-communication/references/explanation-rule.md` exists and opens with a `## What this standard is not` section
      stating the boundary against the readability standard.
- [x] `han-communication/skills/explanation-guidance/SKILL.md` exists as an inline skill mirroring
      `readability-guidance`, with `allowed-tools: Read`.
- [x] The rule carries guidance only and no self-check, and the skill adds no verification step
      ([D-24](implementation-decision-log.md#d-24-the-explanation-standard-carries-guidance-only-and-no-self-check)).
- [x] The boundary is pointed at from three further surfaces: the new skill's frontmatter description with a reciprocal
      clause in `readability-guidance`'s description, the "A different kind of standard" bullet in
      `docs/readability.md`, and the readability-wiring introduction in `CONTRIBUTING.md`.
- [x] The new skill has a long-form doc at `han-communication/docs/skills/explanation-guidance.md`, whose first
      Related-documentation bullet points at the plugin README and then the repository root.
- [x] The new skill has a scent line in `han-communication/README.md` and an alphabetized entry in
      `docs/skills/README.md`.
- [x] Both `han-communication` manifests and the marketplace entry name the new skill's standard.
- [x] `CLAUDE.md`'s `han-planning` references line describes the folder as holding both owned and vendored files.
- [x] `artifacts/scope-boundary.md` is admitted to the work-item inventory in both its Include list and as a stated
      exception on the `artifacts/` Exclude bullet.
- [x] The inventory's PNG-only sentence now cites the accepted file set rather than restating an extension
      ([D-11](implementation-decision-log.md#trivial-decisions)).
- [x] No plugin version changed.

## Unit 2: Agent disclosure placement

**Status:** Not yet landed. See Risk 2 above for this unit's checks; they live there because that is where the risk is
ranked.

## Unit 3: `han-feedback` corrections

**Status:** Not yet landed.

- [ ] A same-day second run updates today's file in place and states the update, rather than skipping.
- [ ] The run skips only when nothing new has happened since the existing file was written.
- [ ] A run in an environment that refuses to publish reports the environment refusing, not the run declining.
- [ ] That run does not retry the identical command.
- [ ] That run hands over a copy-pasteable command.
- [ ] `han-feedback`'s long-form doc matches the behavior the skill now carries.

## Unit 4: `plan-work-items`

**Status:** Not yet landed.

- [ ] The skill reads the boundary record instead of re-asking, and establishes one when it finds none.
- [ ] The confirmation turn fires here only on the absent-record path.
- [ ] Every work item carries a filled justification field, sitting beside the references rather than in the summary.
- [ ] A work item that cannot be justified appears in the cut list with what it would have done and why it was cut.
- [ ] The single stop is present, gathers every qualifying missing input into one question, and names the cost, the
      supply action, and an offer to continue.
- [ ] No visual surface and visual work with no designs are handled as two different situations
      ([D-27 in the specification](decision-log.md#d27-plan-work-items-separates-no-visual-surface-from-visual-work-with-no-designs)).
      Checked by a follow-on run against a plan with no visual surface at all.
- [ ] The missing-artifact rule is reconciled and split by who can supply the artifact, and the three places that must
      agree do agree: the canonical rule in the inventory reference, the step that contradicted it, and the operating
      principle
      ([D-3](implementation-decision-log.md#d-3-the-missing-artifact-rule-stays-local-to-plan-work-items)).
- [ ] The autonomy principle and the one-file statement no longer contradict the skill's own steps
      ([D-7](implementation-decision-log.md#d-7-the-plan-work-items-autonomy-and-one-file-principles-are-edited-not-worked-around)).
- [ ] `Bash(cp *)` is present on `allowed-tools`, and the body states that the copy destination is the resolved plan
      folder's `ui-designs/`.
- [ ] The long-form doc matches the behavior the skill now carries.

## Unit 5: `plan-a-phased-build`

**Status:** Not yet landed.

- [ ] The skill reads and records the boundary, and admits operator-stated shaping context as part of it.
- [ ] The direction-of-travel answer is inherited when already recorded, and asked once when not.
- [ ] Visual material is persisted on arrival, with `Bash(cp *)` present and the destination stated in the body.
- [ ] Every phase carries a filled justification, and unjustifiable candidates land in the cut list.
- [ ] The scope gate attaches at candidate evaluation, with cuts flowing to the deferred-phases list.
- [ ] The single stop is present, and no escalation pass was added to a skill that has none
      ([D-6](implementation-decision-log.md#d-6-the-escalation-register-lands-as-a-register-in-two-skills-only)).
- [ ] The reviewer-scope clause is present, stating that this skill's single fixed-domain reviewer sits outside the
      visual-material brief rule
      ([D-9](implementation-decision-log.md#d-9-the-single-phased-build-reviewer-is-outside-the-visual-material-brief-rule)).
- [ ] Checked by a follow-on run where the operator states scope out loud at invocation.
- [ ] The long-form doc matches the behavior the skill now carries.

## Unit 6: `plan-a-feature`

**Status:** Not yet landed.

- [ ] Every applicability row the specification assigns to this skill is present.
- [ ] The produced specification carries a `Visual Reference` table naming each item and the state it shows, plus inline
      embeds beside the prose describing each state.
- [ ] `## Cut for Scope` sits adjacent to `## Deferred (YAGNI)` in the specification template, and each opens with a line
      saying what it is not
      ([D-8](implementation-decision-log.md#d-8-plan-a-feature-gains-the-cut-list-only-not-a-justification-field)).
- [ ] The skill gained the cut list and no per-unit justification field, because it produces a specification rather than
      work units.
- [ ] Decisions are classified into full or trivial once, after the review round rather than before it.
- [ ] `Bash(cp *)` is present, and the body states the copy destination.
- [ ] The escalation register is present in the escalation step.
- [ ] Checked by the engineered walkthrough.
- [ ] The long-form doc matches the behavior the skill now carries.

## Unit 7: `plan-implementation`

**Status:** Not yet landed.

- [ ] Every applicability row the specification assigns to this skill is present, except the reference table and the
      classification change, which belong to `plan-a-feature`.
- [ ] The scope gate attaches to the existing YAGNI sweep step.
- [ ] `Bash(cp *)` and `Bash(mkdir *)` are both present. This is the only one of the four skills that lacked the
      directory-creating grant.
- [ ] The escalation register is present in the escalation step.
- [ ] The engineered walkthrough's review-behavior findings repeat against this skill.
- [ ] The long-form doc matches the behavior the skill now carries.

## Unit 8: `han-github` screenshot file set

**Status:** Not yet landed.

- [ ] The upload script's asset-selection pattern accepts every type in the accepted file set, not `.png` alone.
- [ ] `screenshot-embed-rules.md`'s source-filename requirement accepts the same set.
- [ ] `issue-template.md`'s embed markdown and stated path scheme accept the same set. This is the one a first pass
      misses: widening the upload without widening the template writes a PNG extension over a file that is not one, so
      the upload succeeds and the image still breaks.
- [ ] Run the upload script against a folder holding one non-PNG item, and confirm the item is selected, uploaded, and
      renders in the issue
      ([D-20](implementation-decision-log.md#d-20-the-github-screenshot-chain-widens-with-the-accepted-file-set)).

## Unit 9: Repository documentation sweep

**Status:** Not yet landed.

- [ ] `CLAUDE.md`'s plugin roster sentence and its two tree comments name the new skill and standard.
- [ ] `CONTRIBUTING.md`'s `han-communication` component list names the new skill.
- [ ] `docs/choosing-a-han-plugin.md` names the new standard in the `han-communication` entry.
- [ ] The skills index lists every skill in every plugin's `skills/` directory, verified by enumeration rather than by a
      count.
- [ ] No surface still describes `han-planning/references/` as vendored copies only.
- [ ] No plugin version changed in this work.
