# Feature Implementation Plan: Planning Scope Corrections

This plan teaches Han's four planning skills to stay inside the work item they descend from, to keep the visual
material an operator supplies, and to ask the operator one plain-language question at a time.

The work ships as markdown prompt text and manifests across three plugins, landing as seven sequenced units that are
committed and pushed as each one completes
([D-15](artifacts/implementation-decision-log.md#d-15-the-change-lands-as-sequenced-units-not-one-simultaneous-rewrite)).
The one thing to know first: the shared conventions land before any skill uses them, and every skill that runs against
a plan folder without a boundary record establishes one itself. That fallback is what makes a partly-adopted repository
safe.

## Outcome

When this plan is executed, a planning run records the boundary of the work it descends from before it does anything
else. It keeps every piece of visual material the operator supplied as a file beside the plan, and it shows the
operator a visible list of what it cut and why. Questions to the operator arrive one at a time, led by a consequence a
person who will never open the code can act on.

The change serves two readers. The operator running a planning skill gets a run that stays inside the ticket and can
show that it did. The implementer maintaining these skills gets three shared convention files and one shared
communication standard, each stated in one place instead of restated in four.

## User Stories

- **US-1:** As an operator, I want the planning run to record the work item's stated scope and exclusions before it
  drafts anything, so the plan I get back is bounded by the work I asked for.
- **US-2:** As an operator, I want every work unit to name what it descends from, and anything that cannot to appear in
  a visible cut list, so I can see and reverse what the run dropped.
- **US-3:** As an operator, I want the visual material I supply to survive the session as files beside the plan and to
  reach every reviewer the run dispatches, so a design-driven plan is reviewed against the designs.
- **US-4:** As an operator, I want questions one at a time in plain language, led by the consequence rather than the
  mechanism, so I can answer without reading the code.
- **US-5:** As an operator, I want a boundary record beside every plan under one name, so a later skill in the chain
  reads it instead of asking me again.
- **US-6:** As an operator, I want `han-feedback` to update today's file in place and to say plainly when the
  environment refused a publish, so I am not told the run declined when it was blocked.
- **US-7:** As the implementer maintaining these skills, I want each shared convention stated once in a named,
  clearly-owned file, so four skills cannot drift apart on the same rule.

## Constraints and Boundaries

- **Driving constraint:** Reported runs show planning skills widening past their work item, losing supplied design
  material, and escalating in jargon. The feature specification is settled with no open items, so the corrections are
  ready to build.
- **Out of scope:**
  - The shared specialist agent definitions. Review-behavior rules reach a reviewer only through the dispatching
    skill's brief.
  - `iterative-plan-review`, which the specification deferred by name.
  - Which specialists a skill selects, and the existing team size caps.
  - Any plugin version bump. Versioning is a separate release decision, owned by the release skill, and nothing in this
    plan changes a version.
  - Any tool grant that reads a work item from a tracker
    ([D-17](artifacts/implementation-decision-log.md#d-17-han-planning-stays-filesystem-only-with-no-work-item-read-tool)).
- **Watch after ship:** Whether reviewer briefs reliably produce the per-finding disclosure the unverified-finding rule
  depends on. That is the one commitment whose delivery mechanism is unproven, and it is carried as R1 below.

## Implementation Approach

The work is prompt text. There is no runtime, no traffic, and no production surface, so the shape of the
implementation is about where each rule is stated and which skill reads it, not about how code executes.

Three groups of change land. A shared communication standard joins `han-communication`. Three shared convention files
join `han-planning`. Each of the four planning skills then wires itself to those conventions at the steps it already
has, and `han-feedback` takes two unrelated corrections.

### Where the shared rules live

Three new reference files join `han-planning/references/`, grouped by what interlocks rather than one per
commitment ([D-1](artifacts/implementation-decision-log.md#d-1-three-han-planning-reference-files-grouped-by-what-interlocks)).

- The boundary record and the visual-material convention share a file, because the completeness gate spans them: the
  run notes each arriving visual item into the boundary record, and the gate reads that record against the folder on
  disk.
  - `han-planning/references/planning-boundary-rule.md`
- The justification field, the cut list, and the scope gate share a file, because they share a destination. An
  unjustified unit and a scope-gated commitment both land in the cut list.
  - `han-planning/references/scope-justification-rule.md`
- The escalation rules stand alone: one question at a time, a plain-language lead, named candidate answers, technical
  references below the question or omitted, the single stop, and the escalation register.
  - `han-planning/references/operator-escalation-rule.md`

Each of the three opens by stating that `han-planning` owns it and that it is not a vendored copy. That preamble
matters because every other file in that folder today is a byte-identical vendored copy, and a re-sync sweep could
otherwise overwrite an owned file silently.

The boundary record itself is an operator-visible artifact under one name in the resolved plan folder
([D-2](artifacts/implementation-decision-log.md#d-2-the-boundary-record-is-a-visible-artifact-under-one-filename)). The
work-item inventory has to admit it in two places, its Include list and as a stated exception on its `artifacts/`
Exclude bullet, so a reader scanning only the Exclude side does not conclude it is excluded.

- `artifacts/scope-boundary.md`
- `han-planning/skills/plan-work-items/references/reference-artifact-inventory.md`

One rule that looks shared is not. The missing-artifact rule stays inside `plan-work-items`, because the two statements
it reconciles are that skill's own, and the specification separately rejects cross-skill reference links
([D-3](artifacts/implementation-decision-log.md#d-3-the-missing-artifact-rule-stays-local-to-plan-work-items)). The
general single-stop rule that binds all four skills lives in the escalation file instead.

Three places in `plan-work-items` have to agree with each other afterward: the canonical rule in its reference, the
contradicting step at `SKILL.md:133-137`, and the operating principle at `SKILL.md:36-40`.

One question that `planning-boundary-rule.md` has to answer outright is what "beside the plan" means when
`plan-work-items` is invoked on its own and its output folder differs from any input plan's folder. State which folder
wins.

### The explanation standard

The new standard describes how to explain technical work to a reader who will not implement it. It ships as a rule file
plus an inline skill that surfaces it, mirroring the readability pairing the specification names as the model
([D-4](artifacts/implementation-decision-log.md#d-4-the-explanation-standard-ships-as-a-rule-file-plus-an-inline-surfacing-skill)).

No new plugin dependency edge is needed, because `han-planning` already depends on `han-communication`.

- `han-communication/references/explanation-rule.md`
- `han-communication/skills/explanation-guidance/SKILL.md`

The boundary against the readability standard is stated once and pointed at three times, because four different readers
arrive through four different surfaces. The canonical statement is a `## What this standard is not` opener in the rule
file. The three pointers each serve a different surface: the new skill's frontmatter description, with a reciprocal
clause in `readability-guidance`'s description, where skill selection happens; the existing "A different kind of
standard" bullet in `docs/readability.md`, the operator's surface; and the readability-wiring introduction in
`CONTRIBUTING.md`, the contributor's surface.

The new skill does not probe `.han/config.md` and does not resolve a writing voice. See
[Deferred (YAGNI)](#deferred-yagni) for why, and for what would reopen it.

### Reading the applicability table against the real skill files

Four rows of the specification's applicability table do not survive contact with the code. None of these reopens the
specification. Specification line 82 governs every one of them: where a skill has no step a commitment attaches to, the
commitment does not create one.

- The scope gate attaches to the YAGNI reasoning each skill already performs, and no skill gains a sweep step
  ([D-5](artifacts/implementation-decision-log.md#d-5-the-scope-gate-attaches-to-existing-yagni-points-not-to-a-new-sweep-step)).
  Only `plan-implementation` has a discrete sweep. In `plan-a-feature` the attach point is finding-resolution path 5a,
  and cut entries flow into its Step 8 synthesis. In `plan-a-phased-build` it is candidate evaluation in Step 4 and the
  deferred-phases list. In `plan-a-feature` the gate reduces to a work-item check on the skill's own commitments,
  because that skill drafts from an interview rather than from an upstream artifact.
- The escalation register lands as a register in `plan-a-feature` and `plan-implementation` only
  ([D-6](artifacts/implementation-decision-log.md#d-6-the-escalation-register-lands-as-a-register-in-two-skills-only)).
  `plan-a-phased-build` has no escalation step at all. There and in `plan-work-items`, the register attaches to the
  single stop. Say this out loud in the work, or an implementer will invent an escalation pass in `plan-a-phased-build`
  simply to have somewhere to put the register.
- `plan-work-items`' own principles get edited rather than worked around
  ([D-7](artifacts/implementation-decision-log.md#d-7-the-plan-work-items-autonomy-and-one-file-principles-are-edited-not-worked-around)).
  Its autonomy principle and its one-file statement now stand beside new operator turns, and a principle contradicting
  its own step is the defect class this change exists to remove. The specification limits the damage: this skill reads
  the boundary record rather than re-asking, and the confirmation turn fires here only on the absent-record path.
  - `han-planning/skills/plan-work-items/SKILL.md:30`, `:36-40`, and `:107`
- `plan-a-feature` gains the cut list and no per-unit justification field, because it produces a specification rather
  than work units
  ([D-8](artifacts/implementation-decision-log.md#d-8-plan-a-feature-gains-the-cut-list-only-not-a-justification-field)).
  The new `## Cut for Scope` section sits immediately adjacent to `## Deferred (YAGNI)` in the specification template,
  and each of the two opens with a one-line statement of what it is not, so the two same-shaped lists are not
  conflated.
  - `han-planning/skills/plan-a-feature/references/feature-specification-template.md`, at the `## Deferred (YAGNI)`
    heading

One more scoping clause belongs in `plan-a-phased-build`. Its single fixed-domain reviewer is outside the
visual-material brief rule, because the applicability table scopes that rule to the two skills that dispatch a
domain-briefed review team
([D-9](artifacts/implementation-decision-log.md#d-9-the-single-phased-build-reviewer-is-outside-the-visual-material-brief-rule)).
Add the clause where that reviewer step is edited, so the next implementer does not read Primary Flow step 6 literally
and quietly widen the change.

### Visual material, producer and consumer

The producer and the consumer already share three strings, and the implementation reuses them exactly rather than
coining new ones ([D-10](artifacts/implementation-decision-log.md#trivial-decisions)). The consumer greps for the table
heading, so writing anything else silently breaks the handoff that specification D14 commits to.

- Folder: `ui-designs/`
- Producer's table heading: `Visual Reference`
- Inline embed form: `![alt text](ui-designs/{name}.png)`

The consumer's PNG-only sentence changes to cite the accepted file set rather than restate an extension
([D-11](artifacts/implementation-decision-log.md#trivial-decisions)). Today a JPG or a mockup PDF persisted into that
folder is dropped silently, while the specification says "visual material" throughout and separately names mockup PDFs
and Figma URLs. `planning-boundary-rule.md` states the accepted set once, and the inventory's sentence points at it.

### Tool grants

Two grant questions were escalated to the user separately, because they have different risk profiles.

The four planning skills gain no work-item read tool, and `han-planning` stays filesystem-only
([D-17](artifacts/implementation-decision-log.md#d-17-han-planning-stays-filesystem-only-with-no-work-item-read-tool)).
The boundary read is satisfied by the operator supplying the work item in the confirmation turn the run already takes,
and by reading it when it is already a local file or already in the conversation. State the consequence in the skills
plainly: the recorded boundary is often the operator's own words rather than the work item's verbatim text. The
specification anticipates exactly this.

The four planning skills do gain a copy tool, narrowed by prompt text rather than by the permission line
([D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)).
Each skill's body states that every copy destination is the resolved plan folder's `ui-designs/`. `allowed-tools`
scopes by command prefix and not by path, so this is technically an unscoped copy grant. The prompt-text constraint is
what narrows it, and a reviewer reading the skill can check it.

`plan-implementation` also needs the directory-creating grant. It is the only one of the four skills to lack it.

- `Bash(cp *)` on all four skills' `allowed-tools`
- `Bash(mkdir *)` on `plan-implementation`, whose `allowed-tools` line carries `Bash(git *)` instead

### Documentation fan-out

The documentation surfaces were checked file by file rather than assumed, and two of them were verified as needing
nothing ([D-16](artifacts/implementation-decision-log.md#d-16-the-documentation-sweep-covers-a-verified-fan-out-list)).

The new skill's own documentation is non-negotiable under the repository's completeness convention, and it lands with
the unit that creates the skill. That documentation is a long-form doc written from the skill template with its first
Related-documentation bullet pointing at the plugin README and then the repository root, a scent line in the plugin
README, and an alphabetized entry in the skills index.

Stale the moment the skill lands: both `han-communication` manifests, the marketplace manifest that mirrors their
description, `CLAUDE.md` in its plugin roster sentence and two tree comments, `CONTRIBUTING.md` in its
`han-communication` component list and standards-boundary sentence, `docs/choosing-a-han-plugin.md`, and
`docs/readability.md`'s boundary sentence.

One correction the specification asks for by name: `CLAUDE.md:105` describes `han-planning/references/` as holding
vendored copies only, and it now holds both kinds. The mixed folder is not a new pattern; `han-communication/references/`
already holds two owned canonical files beside a vendored `config-rule.md`.

Each skill's own long-form doc travels with its skill's unit rather than waiting for the sweep, so every unit leaves
the repository coherent.

## Work Units and Sequencing

Each unit is committed and pushed as it completes. What makes this skill-by-skill sequence safe rather than merely
convenient is the specification's own fallback: a skill that finds no boundary record establishes one itself, so an
updated skill run against a folder produced by a not-yet-updated sibling still works
([D-15](artifacts/implementation-decision-log.md#d-15-the-change-lands-as-sequenced-units-not-one-simultaneous-rewrite)).

Two contracts must land whole inside a single unit rather than split across units: the visual-material producer and
consumer pair, and the boundary record's shared name.

| #   | Work Unit                            | Story           | Delivers                                                                                                                                                                                                             | Depends On | Verification                                                                                       |
| --- | ------------------------------------ | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------- |
| 1   | Shared plumbing                      | US-4, US-5, US-7 | The explanation standard and its inline surfacing skill, the three `han-planning` reference files, the boundary record's name and its admission to the inventory, plus the new skill's own docs, manifests, and index entry ([D-1](artifacts/implementation-decision-log.md#d-1-three-han-planning-reference-files-grouped-by-what-interlocks), [D-2](artifacts/implementation-decision-log.md#d-2-the-boundary-record-is-a-visible-artifact-under-one-filename), [D-4](artifacts/implementation-decision-log.md#d-4-the-explanation-standard-ships-as-a-rule-file-plus-an-inline-surfacing-skill)) | None       | Read-through against the acceptance checklist. No caller exists yet, which is an expected state.    |
| 2   | `han-feedback` corrections           | US-6            | Today's feedback file updates in place with the update stated, and a refused publish is reported as the environment refusing rather than the run declining, with a copy-pasteable command handed over                 | None       | Two follow-on checks: a same-day second run, and a run in an environment that refuses to publish.   |
| 3   | `plan-work-items`                    | US-1, US-2, US-5 | Boundary read and record, visual-material inventory, justification field, single stop, the no-visual-surface split, the reconciled missing-artifact rule, and the corrected autonomy and one-file principles ([D-3](artifacts/implementation-decision-log.md#d-3-the-missing-artifact-rule-stays-local-to-plan-work-items), [D-7](artifacts/implementation-decision-log.md#d-7-the-plan-work-items-autonomy-and-one-file-principles-are-edited-not-worked-around)) | 1          | Follow-on check: a run against a plan with no visual surface at all.                                |
| 4   | `plan-a-phased-build`                | US-1, US-2, US-4 | Boundary read with operator-stated shaping context, direction-of-travel inheritance, visual material, justification, the scope gate at candidate evaluation, the single stop with its register, and the reviewer-scope clause ([D-5](artifacts/implementation-decision-log.md#d-5-the-scope-gate-attaches-to-existing-yagni-points-not-to-a-new-sweep-step), [D-6](artifacts/implementation-decision-log.md#d-6-the-escalation-register-lands-as-a-register-in-two-skills-only), [D-9](artifacts/implementation-decision-log.md#d-9-the-single-phased-build-reviewer-is-outside-the-visual-material-brief-rule)) | 1          | Follow-on check: a run where the operator states scope out loud at invocation.                      |
| 5   | `plan-a-feature`                     | US-1, US-2, US-3, US-4 | Every applicability row, including the visual reference table and inline placements the inventory reads, the cut list without a per-unit justification field, and classification of decisions once after the review round ([D-8](artifacts/implementation-decision-log.md#d-8-plan-a-feature-gains-the-cut-list-only-not-a-justification-field), [D-10](artifacts/implementation-decision-log.md#trivial-decisions)) | 1, 3       | The engineered walkthrough ([D-14](artifacts/implementation-decision-log.md#d-14-one-engineered-plan-a-feature-run-carries-the-main-walkthrough)). |
| 6   | `plan-implementation`                | US-1, US-2, US-3, US-4 | Every applicability row except the reference table and the classification change, the scope gate on its existing sweep, and the directory-creating grant it uniquely lacks ([D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)) | 1, 3, 4, 5 | The engineered walkthrough's review-behavior findings, repeated against this skill.                 |
| 7   | Repository documentation sweep       | US-7            | The cross-plugin surfaces the new convention and the new skill leave stale, and the correction to the `han-planning` references line ([D-16](artifacts/implementation-decision-log.md#d-16-the-documentation-sweep-covers-a-verified-fan-out-list)) | 1 - 6      | Read-through against the acceptance checklist's documentation section.                              |

Two intermediate states are expected rather than defects. After unit 1, the three new reference files have no caller
yet, which is not a dangling link. After unit 3 and before unit 5, the inventory briefly has no updated producer to
consume from.

## Definition of Done

- [ ] Every run that received visual material finishes with that material on disk beside the plan, and the produced
      specification carries a `Visual Reference` table naming each item and the state it shows
      ([D-10](artifacts/implementation-decision-log.md#trivial-decisions),
      [D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)).
- [ ] Every work unit and work item in a produced plan either carries a filled justification or appears in the cut list
      with a reason.
- [ ] No finding reaches the operator as build-blocking when its author recorded it could not inspect the input, checked
      against a run engineered to produce such a disclosure
      ([D-13](artifacts/implementation-decision-log.md#d-13-success-criterion-3-is-checked-with-an-engineered-disclosure-scenario)).
- [ ] A boundary record exists beside every plan a planning skill produces, under one name, naming either the work
      item's scope and exclusions or the statement that the operator's request was the only boundary
      ([D-2](artifacts/implementation-decision-log.md#d-2-the-boundary-record-is-a-visible-artifact-under-one-filename)).
- [ ] The three `han-planning` reference files each open with the statement that `han-planning` owns them and that they
      are not vendored copies
      ([D-1](artifacts/implementation-decision-log.md#d-1-three-han-planning-reference-files-grouped-by-what-interlocks)).
- [ ] No skill gained a sweep step or an escalation step it did not have
      ([D-5](artifacts/implementation-decision-log.md#d-5-the-scope-gate-attaches-to-existing-yagni-points-not-to-a-new-sweep-step),
      [D-6](artifacts/implementation-decision-log.md#d-6-the-escalation-register-lands-as-a-register-in-two-skills-only)).
- [ ] `plan-work-items` carries no statement that contradicts its own steps about autonomy or about how many files it
      writes
      ([D-7](artifacts/implementation-decision-log.md#d-7-the-plan-work-items-autonomy-and-one-file-principles-are-edited-not-worked-around)).
- [ ] The specification template carries `## Cut for Scope` adjacent to `## Deferred (YAGNI)`, each opening with a line
      saying what it is not
      ([D-8](artifacts/implementation-decision-log.md#d-8-plan-a-feature-gains-the-cut-list-only-not-a-justification-field)).
- [ ] The explanation standard and its surfacing skill exist, and the boundary against the readability standard is
      stated in the rule file and pointed at from the two skill descriptions, `docs/readability.md`, and
      `CONTRIBUTING.md`
      ([D-4](artifacts/implementation-decision-log.md#d-4-the-explanation-standard-ships-as-a-rule-file-plus-an-inline-surfacing-skill)).
- [ ] The new skill has a long-form doc, a plugin README scent line, and a skills-index entry, and every manifest that
      names the plugin's skills names it
      ([D-16](artifacts/implementation-decision-log.md#d-16-the-documentation-sweep-covers-a-verified-fan-out-list)).
- [ ] `CLAUDE.md`'s `han-planning` references line describes the folder as holding both owned and vendored files.
- [ ] The acceptance checklist is written and committed alongside the change, covering every commitment including the
      ten with no stated success criterion
      ([D-12](artifacts/implementation-decision-log.md#d-12-verification-is-a-committed-acceptance-checklist-plus-manual-walkthroughs)).
- [ ] No plugin version changed in this work.

## Testing Strategy

This repository has no test runner and no CI job that exercises skill behavior. Verification is a written acceptance
checklist committed alongside the change, plus manual walkthroughs run against engineered inputs
([D-12](artifacts/implementation-decision-log.md#d-12-verification-is-a-committed-acceptance-checklist-plus-manual-walkthroughs)).
Reading the diff cannot observe whether a multi-step cross-skill behavior fires, and an unrecorded walkthrough leaves
the next editor nothing.

- **Observable behaviors to test, in priority order.** The checklist is ordered by risk, highest first.
  1. Visual material reaches every reviewer, including items that arrive after dispatch. This is the one commitment
     with a documented prior failure, and it is silent when broken.
  2. An uninspected input strips blocking severity from the findings resting on it. Also a documented prior failure,
     and silent by construction.
  3. The completeness gate reads the boundary record rather than run memory. An agent naturally reasons over what it
     remembers, which is the failure mode the gate was redesigned to avoid.
  4. The scope gate's floor holds. This is the highest-nuance new rule, and a wrong cut looks legitimate because it
     carries a citation.
  5. A skill handed a work item that conflicts with the recorded one surfaces the conflict. The default disposition is
     to proceed with whatever was stated most recently.
- **Edge cases requiring coverage.** The main walkthrough is one engineered `plan-a-feature` run, because that is the
  only skill every applicability row touches
  ([D-14](artifacts/implementation-decision-log.md#d-14-one-engineered-plan-a-feature-run-carries-the-main-walkthrough)).
  It carries a work item with an explicit stated exclusion and an implied-but-unstated necessity. Two images arrive at
  session start, and one of them depicts something the ticket text never mentions. A third image arrives after the
  review team is dispatched. One reviewer is positioned so it cannot inspect an input. Two reviewers raise the same
  finding under different wording. Three follow-on checks cover what that run cannot reach: a `plan-work-items` run
  with no visual surface at all, a `plan-a-phased-build` run where the operator states scope out loud at invocation,
  and the two `han-feedback` corrections.
- **Test doubles posture and levels:** None apply. There is no code under test and no dependency to stub. The
  substitute for a test double is the engineered input that forces a behavior to fire, above all the reviewer
  positioned so it cannot inspect an input
  ([D-13](artifacts/implementation-decision-log.md#d-13-success-criterion-3-is-checked-with-an-engineered-disclosure-scenario)).

## Risks and Assumptions

### Risks

| ID  | Risk                                                                                                                                                                                          | Impact                                                                                                                                        | Mitigation                                                                                                                                                                                                                                                                       | Owner                          |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| R1  | A reviewer brief may not reliably add a required per-finding field to an agent whose definition owns its own output format. Specification D19 needs an "input I could not inspect" disclosure on each finding, and D28 needs a rough target length. The agent definitions prescribe their output structure in detail, and the specification's Out of Scope forbids changing them. | Two review-behavior commitments in units 5 and 6 could ship as text that never takes effect.                                                    | Run a thirty-minute experiment before those units land: add the disclosure field to one brief by hand, dispatch one agent, and check whether the returned finding carries it. If it does not, the trigger is that the specification's Out of Scope boundary needs revisiting. Specification D28's own rejected alternatives already keep a hard cap on record as the fallback if a named target proves inert. | `han-core:test-engineer`       |
| R2  | `Bash(cp *)` is an unscoped grant narrowed only by prompt text, because `allowed-tools` scopes by command prefix and not by path ([D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)). | A run could copy to a destination outside the resolved plan folder.                                                                            | Each skill's body states that every copy destination is the plan folder's `ui-designs/`, which a reviewer reading the skill can check.                                                                                                                                            | `han-core:junior-developer`    |
| R3  | Ten of the roughly fifteen commitments have no stated success criterion. The specification's `## How We Will Know It Worked` covers four.                                                       | A commitment could ship as text and never be observed to fire.                                                                                 | The acceptance checklist names what you would see in the produced artifact folder for each remaining commitment ([D-12](artifacts/implementation-decision-log.md#d-12-verification-is-a-committed-acceptance-checklist-plus-manual-walkthroughs)). This adds prose to a section that already exists, not machinery. | `han-core:test-engineer`       |
| R4  | "Beside the plan" is underdefined for `plan-work-items` when it is invoked standalone, because its output folder may differ from any input plan's folder.                                       | The boundary record and the visual-material folder could land in two different places across one chain.                                        | Resolve it in `planning-boundary-rule.md` by stating which folder wins ([D-1](artifacts/implementation-decision-log.md#d-1-three-han-planning-reference-files-grouped-by-what-interlocks)).                                                                                        | `han-core:information-architect` |

### Assumptions

| ID  | Assumption                                                                                                                                                                     | What Changes If Wrong                                                                                                              | Status        |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| A1  | Technical note T1's mechanic holds. The host does not cache a pasted image as a file, which is the fallback branch T1 already names, and the copy branch stays correct for material the operator already holds as a file. | Nothing. This was verified: `~/.claude/paste-cache/` holds only `.txt`, so a genuinely pasted image does not land on disk as a file. | Verified      |
| A2  | A dispatched agent can open a persisted PNG by path when its brief supplies one.                                                                                                | If it cannot, the visual-material-to-reviewer commitment ships inert and R1's experiment widens to cover it.                        | Runtime-only  |
| A3  | In `plan-work-items` the completeness gate covers only material that run itself received, not material an upstream skill already persisted, which the inventory reads instead. The specification's applicability table gives "Persist and confirm visual material" to all four skills, so the gate is not absent there; it is scoped to what that run took in. | If the gate is meant to re-confirm upstream-persisted material too, the skill gains a second read of the boundary record, and its one-file statement changes accordingly ([D-7](artifacts/implementation-decision-log.md#d-7-the-plan-work-items-autonomy-and-one-file-principles-are-edited-not-worked-around)). | Open          |

Every `han-core` agent carries `Read`, which makes A2 likely, but no run has confirmed it end to end.

## Deferred (YAGNI)

### A `.han/config.md` probe and writing-voice resolution on the new surfacing skill

- **Why deferred:** Evidence test. Specification D13 scopes the new standard to content shape, meaning no unintroduced
  terms and a concrete observable outcome, not to voice or vocabulary. Wiring the probe would be symmetry with a
  sibling skill, which the YAGNI rule auto-flags. The consequence is that the skill is a two-step read of one file and
  `docs/configuration.md` needs no edit.
- **Reopen when:** A project configures a writing voice and its escalation turns still read in Han's voice.
- **Source:** R1, `han-core:information-architect`.

### An entry for the new skill in the reader-facing skills table

- **Why deferred:** Evidence test. `docs/readability.md`'s table lists skills whose deliverable is prose, and
  `readability-guidance`, the exact structural precedent, is absent from it for the same reason. Recorded as a rejected
  alternative on
  [D-16](artifacts/implementation-decision-log.md#d-16-the-documentation-sweep-covers-a-verified-fan-out-list).
- **Reopen when:** The surfacing skill gains a deliverable of its own.
- **Source:** R1, `han-core:information-architect`.

### A new ADR recording where cross-skill conventions live

- **Why deferred:** Evidence test. The hazard is already closed by the in-file ownership preamble plus the one-line
  `CLAUDE.md` correction. Recorded as a rejected alternative on
  [D-16](artifacts/implementation-decision-log.md#d-16-the-documentation-sweep-covers-a-verified-fan-out-list).
- **Reopen when:** A second plugin-owned file lands in a vendored folder, or a re-sync sweep deletes one.
- **Source:** R1, `han-core:information-architect`.

### Updates to the workflows and concepts documents

- **Why deferred:** Evidence test. `docs/workflows.md` maps which skills chain together, not which artifacts pass
  between them, and `docs/concepts.md`'s `han-communication` mentions are agent- and dependency-scoped.
- **Reopen when:** An operator reports running `plan-work-items` standalone and not knowing a boundary record was
  expected.
- **Source:** R1, `han-core:information-architect`.

### A validation script or lint over produced artifacts or skill files

- **Why deferred:** Evidence test, and it generalizes the specification's own two deferrals. Recorded as rejected
  alternatives on
  [D-12](artifacts/implementation-decision-log.md#d-12-verification-is-a-committed-acceptance-checklist-plus-manual-walkthroughs).
- **Reopen when:** A downstream skill demonstrably fails to find the recorded boundary in prose, or a run passes the
  completeness gate and still ships a specification with no reference table, or a commitment is found written into a
  skill file but demonstrably not executed across two or more separate runs.
- **Source:** R1, `han-core:test-engineer` and `han-core:junior-developer`.

### A per-commitment tracking matrix maintained after the change ships

- **Why deferred:** Evidence test. No evidence exists that anyone would read it.
- **Reopen when:** A second correction pass has to re-audit which commitments landed.
- **Source:** R1, `han-core:junior-developer`.

### Extracting the two-consumer review-behavior families into shared reference files

- **Why deferred:** Simpler-version test. Specification D36 supplies the counter-evidence directly: the review rules
  live in the brief each dispatching skill writes, which is what contains the blast radius to the four named skills.
  The two consuming skills also already carry structurally different brief tables and finding taxonomies, so one
  generic paragraph would have to serve two skill-specific pipelines. Inline text in each skill replaces the
  extraction. The families are visual material in reviewer briefs, the unverified-finding rule and design check, the
  proportionality signal, reviewer identifiers on merged findings, and naming unaudited evidence classes.
- **Reopen when:** A third skill needs one of these families, or the two pipelines converge on one brief shape.
- **Source:** R1, `han-core:structural-analyst`.

### A shared reference for the visual reference table and for classify-once

- **Why deferred:** Simpler-version test, and the single-implementation-interface anti-pattern by name. Each has
  exactly one consumer, `plan-a-feature`, so both stay inline. Classify-once is a step-ordering change inside that
  skill rather than a text-sharing question: its decision classification happens before the review round today, and
  specification D22 requires it to move after.
- **Reopen when:** A second skill writes a visual reference table, or a second skill classifies decisions in two
  passes.
- **Source:** R1, `han-core:structural-analyst`.

### A work-item read tool for the four planning skills

- **Why deferred:** Evidence test as applied by the user's decision. The degraded path is already specified and costs
  one paste inside a turn the run already takes
  ([D-17](artifacts/implementation-decision-log.md#d-17-han-planning-stays-filesystem-only-with-no-work-item-read-tool)).
- **Reopen when:** Operators report the pasted boundary drifting materially from the work item's actual text, or a run
  cuts something the work item did ask for because the paraphrase lost it.
- **Source:** R2, user decision, reframed by `han-core:junior-developer`.

## Open Items

- **OI-1:** Can a reviewer brief add a required per-finding field to an agent whose definition specifies its own output
  format?
  - **Resolves when:** The thirty-minute experiment in R1 runs: one brief carries the disclosure field by hand, one
    agent is dispatched, and the returned finding either carries the field or does not.
  - **Blocks implementation:** No. Units 1 through 4 are unaffected. It blocks only the two review-behavior
    commitments inside units 5 and 6, and a negative result routes to revisiting the specification's Out of Scope
    boundary rather than to a redesign here.

- **OI-2:** In `plan-work-items`, does the completeness gate cover only the material that run received, or also
  material an upstream skill already persisted? Carried as A3 above.
  - **Resolves when:** Unit 1 states the answer in `planning-boundary-rule.md`, alongside the "beside the plan" answer
    R4 needs from the same file.
  - **Blocks implementation:** No. It scopes one paragraph inside unit 1 and one sentence inside unit 3. Either answer
    leaves the specification's applicability table satisfied.

## Specialist Handoffs for Implementation

- **`han-core:test-engineer`.** Dispatch before unit 5 begins, to run the reviewer-brief experiment behind R1 and
  OI-1, and again to author the acceptance checklist; needs the feature specification's D19 and D28, one existing
  reviewer brief from `plan-a-feature`, and one `han-core` agent definition.
- **`han-core:information-architect`.** Dispatch at unit 7, for the repository-root documentation sweep; needs the
  verified fan-out list in
  [D-16](artifacts/implementation-decision-log.md#d-16-the-documentation-sweep-covers-a-verified-fan-out-list) and the
  new skill as it landed in unit 1.
- **`han-core:junior-developer`.** Dispatch after unit 5, to run the engineered walkthrough as a naive operator; needs
  the walkthrough scenario in
  [D-14](artifacts/implementation-decision-log.md#d-14-one-engineered-plan-a-feature-run-carries-the-main-walkthrough)
  and the acceptance checklist.

## Sources and Plan Records

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Specification companions:** [decision log](artifacts/decision-log.md),
  [team findings](artifacts/team-findings.md), [technical notes](artifacts/feature-technical-notes.md)
- **Specification decisions inherited and respected:** D1, D2, D3, D5, D6, D8, D9, D12, D13, D14, D15, D17, D18, D19,
  D20, D22, D23, D24, D25, D27, D28, D31, D32, D33, D34, D35, D36, and technical note T1. The specification's own open
  items are all closed, so none carries forward.
- **Project context gathered before planning:** [artifacts/.discovery-notes.md](artifacts/.discovery-notes.md)
- **Decision rationale and rejected alternatives:**
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Team composition and round-by-round history:**
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)

## Recommendation

Ship as planned, in the sequence above. Run the reviewer-brief experiment before unit 5 begins, since OI-1 gates two
commitments rather than the plan itself. OI-2 resolves inside unit 1 and blocks nothing.
