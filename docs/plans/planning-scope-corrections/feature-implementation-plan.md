# Feature Implementation Plan: Planning Scope Corrections

This plan teaches Han's four planning skills to stay inside the work item they descend from, to keep the visual
material an operator supplies, and to ask the operator one plain-language question at a time.

The work ships as markdown prompt text, one shell script, and manifests across five plugins, landing as nine sequenced
units that are committed and pushed as each one completes
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

One rule deliberately breaks that pattern. The disclosure-placement rule is copied into twenty-one agent definitions
rather than stated once, because it has to live where each agent's own output format is specified
([D-19](artifacts/implementation-decision-log.md#d-19-agent-definitions-carry-the-disclosure-placement-rule)). That is
an accepted exception to this plan's own centralizing argument, not an oversight.

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
- **US-8:** As an operator, I want a reviewer's admission that it could not read something to arrive attached to the
  finding that rests on it, so a finding I cannot trust never reaches me looking build-blocking.

## Constraints and Boundaries

- **Driving constraint:** Reported runs show planning skills widening past their work item, losing supplied design
  material, and escalating in jargon. The feature specification is settled with no open items, so the corrections are
  ready to build.
- **Deliberate scope expansion:** The specification's Out of Scope leaves the shared specialist agent definitions
  alone. This plan changes them anyway, by one line each, to state where a blind-spot disclosure belongs
  ([D-19](artifacts/implementation-decision-log.md#d-19-agent-definitions-carry-the-disclosure-placement-rule)). The
  rest of that boundary holds: no agent gains a field, changes an output format, or takes on a review rule.
- **Out of scope:**
  - Every other review-behavior rule, which still reaches a reviewer only through the dispatching skill's brief.
  - `iterative-plan-review`'s own steps, which the specification deferred by name. Note the one way this plan does
    reach it: that skill dispatches shared agents, so the disclosure-placement rule changes what its reviewers return.
    Its own behavior is untouched, and the distinction is stated here because the earlier phrasing of this bullet was
    simply false once the rule moved into the shared roster
    ([D-19](artifacts/implementation-decision-log.md#d-19-agent-definitions-carry-the-disclosure-placement-rule)).
  - Which specialists a skill selects, and the existing team size caps.
  - Any plugin version bump. Versioning is a separate release decision, owned by the release skill, and nothing in this
    plan changes a version.
  - Any tool grant that reads a work item from a tracker
    ([D-17](artifacts/implementation-decision-log.md#d-17-han-planning-stays-filesystem-only-with-no-work-item-read-tool)).
- **Watch after ship:** Nothing. The one candidate, whether a reviewer honors the target length its brief names, was
  dismissed by the user
  ([D-22](artifacts/implementation-decision-log.md#d-22-the-target-lengths-effectiveness-is-not-tracked)). The signal
  still ships; its effectiveness is not measured.

## Implementation Approach

The work is prompt text. There is no runtime, no traffic, and no production surface, so the shape of the
implementation is about where each rule is stated and which skill reads it, not about how code executes.

Five groups of change land. A shared communication standard joins `han-communication`. Three shared convention files
join `han-planning`. One rule line joins the shared agent roster. Each of the four planning skills then wires itself to
those conventions at the steps it already has. Finally `han-feedback` takes two unrelated corrections, and
`han-github`'s screenshot chain widens to match the file set `han-planning` now accepts.

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
contradicting step at `SKILL.md:134-137`, and the operating principle at `SKILL.md:36-40`.

The file also records one scoping decision rather than leaving it to the run: in `plan-work-items`, the completeness
gate covers only material that run itself received, never material an earlier skill already persisted
([D-23](artifacts/implementation-decision-log.md#d-23-the-completeness-gate-in-plan-work-items-covers-only-what-that-run-received)).
The inventory is what reads the folder there.

Four further things `planning-boundary-rule.md` has to settle outright, because the plan leaves each of them open and
unit 1 cannot be built without them.

- **What "beside the plan" means** when `plan-work-items` is invoked on its own and its output folder differs from any
  input plan's folder. State which folder wins.
- **The boundary record's shape.** The name is fixed, but four mechanics read it back: the confirmation turn restates
  it, the completeness gate iterates the items it lists as received, `plan-work-items` reads it instead of re-asking,
  and the conflict rule compares an incoming work item against it. A freeform record leaves the gate with nothing to
  iterate, which is the memory-based failure the specification's own OI-1 closed. Give it named sections.
- **The accepted visual-material file set, enumerated.** The plan names raster images, mockup PDFs, and Figma URLs
  across three sentences without fixing the list. Note that a Figma URL is not a file and cannot be copied, so the
  rule states how a URL is recorded separately from how a file is persisted.
- **The ownership preamble's wording.** No precedent exists to copy: `han-communication`'s two owned files carry no
  such preamble today. Fix one form so all three files match and the Definition of Done item is checkable.

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

The rule carries guidance only. It has no self-check, so none of the four planning skills gains a check step
([D-24](artifacts/implementation-decision-log.md#d-24-the-explanation-standard-carries-guidance-only-and-no-self-check)).
That is where the mirroring of the readability pairing stops: the readability rule ends in a six-item check because it
governs a whole written document, and this standard governs one conversational turn.

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
coining new ones ([D-10](artifacts/implementation-decision-log.md#trivial-decisions)). The consumer names the table
heading as its mapping source, so writing a different heading breaks the handoff that specification D14 commits to.

- Folder: `ui-designs/`
- Producer's table heading: `Visual Reference`
- Inline embed form: an image embed whose path sits under `ui-designs/`

The consumer's reference writes the last two as ellipsis placeholders rather than as literal examples, and it hedges
the heading with "or equivalent." Replace both with one concrete form when that file is edited, so the producer has an
exact target instead of a pattern to infer.

The consumer's PNG-only sentence changes to cite the accepted file set rather than restate an extension
([D-11](artifacts/implementation-decision-log.md#trivial-decisions)). Today a JPG or a mockup PDF persisted into that
folder is dropped silently, while the specification says "visual material" throughout and separately names mockup PDFs
and Figma URLs. `planning-boundary-rule.md` states the accepted set once, and the inventory's sentence points at it.

Widening that set reaches a second plugin, which the first pass missed
([D-20](artifacts/implementation-decision-log.md#d-20-the-github-screenshot-chain-widens-with-the-accepted-file-set)).
`han-github`'s `work-items-to-issues` reads the same `ui-designs/` folder and is hardcoded to PNG in two places: its
upload script selects assets with a `.png` pattern, and its embed rules require a `.png` source filename. Left alone,
a JPG that now flows into a work item is skipped by the upload and renders as a broken image in the issue. Both places
widen to the same set.

- `han-github/skills/work-items-to-issues/scripts/upload-screenshots.sh`, at its asset-selection pattern
- `han-github/skills/work-items-to-issues/references/screenshot-embed-rules.md`, at its source-filename requirement
- `han-github/skills/work-items-to-issues/references/issue-template.md`, at the embed markdown an implementer copies
  and at its stated path scheme

The third of those is the one a first pass misses. Widening the upload without widening the template produces an issue
body that still writes a PNG extension over a file that is not one, so the upload succeeds and the image still breaks.

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

### Where the blind-spot disclosure is stated

Twenty-one agent definitions gain one line telling them to put a blind-spot disclosure on the finding itself, not only
in an assumptions section
([D-19](artifacts/implementation-decision-log.md#d-19-agent-definitions-carry-the-disclosure-placement-rule)). This
expands the specification's scope deliberately, because its Out of Scope leaves the shared agent definitions alone.

The reason the expansion is worth it: the reported failure was placement, not disobedience. The reviewer in that
session did disclose its blindness. It put the disclosure in an assumptions section, well below a finding it
recommended treating as blocking. Six agents already carry such a section, and `structural-analyst` already reports
dimensions it could not assess. So these agents already have somewhere to put a disclosure, and none is told to put it
where the reader of the finding will see it.

A rule stated in the agent's own definition also survives a model change better than a runtime instruction competing
with that definition, which is the durability argument for accepting the wider surface.

#### Which agents take the rule

The test is what the agent returns, not which plugin holds it. An agent takes the rule when its output is a claim a
dispatching skill weighs: a finding, a verdict, an assessment, or a recommendation. An agent does not take the rule
when its output is an inventory of what it found, or a rewritten artifact, because neither has a finding for a
disclosure to attach to.

That resolves to twenty-one of the repository's twenty-four agent definitions. Applying the test is part of unit 2's
work rather than a list to copy, and the three known exclusions are named so the boundary is not re-litigated.

- Excluded, discovery output: `han-core/agents/project-scanner.md`, `han-core/agents/codebase-explorer.md`
- Excluded, rewritten artifact: `han-communication/agents/readability-editor.md`
- Included from outside `han-core`: `han-research/agents/research-analyst.md`

Three consequences follow, and each belongs in the work.

- **The disclosure and its consequence live in different places.** The agent supplies the disclosure. The dispatching
  skill still applies the rule that strips blocking severity from findings resting on an uninspected input, and that
  rule stays in the two skills' briefs where the specification puts it.
- **The change reaches every skill that dispatches these agents**, not only the four planning skills. That is nineteen
  skills across six plugins, and it is accepted rather than incidental. A finding that rests on something unread is
  worth flagging in a code review or a gap analysis too.
- **No output format changes.** The rule is a placement correction added to each agent's existing rules list, so no
  agent gains a field and the long-form docs need at most a sentence.

#### The seam between the agent and the skill needs a stated shape

The agent writes the disclosure and the dispatching skill acts on it, so the two need to agree on what "on the finding"
looks like. The plan's first pass asserted no format change without saying what the consuming skill looks for, which
left the seam undefined across agents whose output formats already differ: ten carry a findings section with per-finding
fields, and the rest use numbered items.

Fix it by naming one form in the rule line itself, so every agent writes the same shape and both consuming skills read
the same shape. Naming the form is what keeps "no format change" and "the skill can reliably detect it" from
contradicting each other.

#### The insert point is uniform except once

Every included agent carries a `## Rules` bullet list, and the rule line joins it. One file breaks the pattern and has
to be handled by name rather than by an append: in `han-core/agents/gap-analyzer.md`, `## Rules` is followed by a
`## Graceful Degradation` section, so it is not the last heading. An implementer appending to the end of that file
lands the rule outside any rules list.

- `han-core/agents/*.md` and `han-research/agents/research-analyst.md`, in each file's `## Rules` section
- `han-core/docs/agents/*.md` and `han-research/docs/agents/research-analyst.md`, in "What you get back", only where
  the sentence is needed

The proportionality signal does not move with it. A rough target length is per-dispatch context rather than a stable
property of an agent, so it stays in the brief and remains the one unproven delivery mechanism in this plan.

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

One contract lands whole inside a single unit: the boundary record's shared name, written in unit 1 and read by every
skill unit afterward.

The visual-material producer and consumer pair is deliberately split instead, consumer first. `plan-work-items` reads
the table in unit 4 and `plan-a-feature` writes it in unit 6, so the inventory has no updated producer between them.
That gap is safe for the same reason the rest of the sequence is: a skill that finds nothing to read establishes or
degrades rather than failing. What both halves do share is the exact heading string, and unit 1 fixes that string
before either half moves.

| #   | Work Unit                            | Story           | Delivers                                                                                                                                                                                                             | Depends On | Verification                                                                                       |
| --- | ------------------------------------ | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------- |
| 1   | Shared plumbing                      | US-4, US-5, US-7 | The acceptance checklist's first sections, the explanation standard and its inline surfacing skill, the three `han-planning` reference files with the four questions they settle, the boundary record's name and its admission to the inventory, the exact heading and embed strings, the new skill's own docs and manifests and index entry, and the `CLAUDE.md` references-line correction this unit makes necessary ([D-1](artifacts/implementation-decision-log.md#d-1-three-han-planning-reference-files-grouped-by-what-interlocks), [D-2](artifacts/implementation-decision-log.md#d-2-the-boundary-record-is-a-visible-artifact-under-one-filename), [D-4](artifacts/implementation-decision-log.md#d-4-the-explanation-standard-ships-as-a-rule-file-plus-an-inline-surfacing-skill), [D-21](artifacts/implementation-decision-log.md#d-21-the-acceptance-checklist-has-a-path-and-an-owning-unit)) | None       | Read-through against the checklist sections this unit writes. No caller exists yet, which is expected. |
| 2   | Agent disclosure placement           | US-8            | One rule line, in one named shape, in the twenty-one agent definitions that return findings, plus the long-form doc sentences that need it, handling `gap-analyzer` by name rather than by append ([D-19](artifacts/implementation-decision-log.md#d-19-agent-definitions-carry-the-disclosure-placement-rule)) | None       | Dispatch one agent per output-format shape against an input it cannot open, and confirm the disclosure rides on the finding in the named shape. |
| 3   | `han-feedback` corrections           | US-6            | Today's feedback file updates in place with the update stated, and a refused publish is reported as the environment refusing rather than the run declining, with a copy-pasteable command handed over                 | None       | Two follow-on checks: a same-day second run, and a run in an environment that refuses to publish.   |
| 4   | `plan-work-items`                    | US-1, US-2, US-5 | Boundary read and record, visual-material inventory, justification field, single stop, the no-visual-surface split, the reconciled missing-artifact rule, the corrected autonomy and one-file principles, and this skill's copy grant ([D-3](artifacts/implementation-decision-log.md#d-3-the-missing-artifact-rule-stays-local-to-plan-work-items), [D-7](artifacts/implementation-decision-log.md#d-7-the-plan-work-items-autonomy-and-one-file-principles-are-edited-not-worked-around), [D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)) | 1          | Follow-on check: a run against a plan with no visual surface at all.                                |
| 5   | `plan-a-phased-build`                | US-1, US-2, US-4 | Boundary read with operator-stated shaping context, direction-of-travel inheritance, visual material with this skill's copy grant, justification, the scope gate at candidate evaluation, the single stop with no escalation pass added, and the reviewer-scope clause ([D-5](artifacts/implementation-decision-log.md#d-5-the-scope-gate-attaches-to-existing-yagni-points-not-to-a-new-sweep-step), [D-6](artifacts/implementation-decision-log.md#d-6-the-escalation-register-lands-as-a-register-in-two-skills-only), [D-9](artifacts/implementation-decision-log.md#d-9-the-single-phased-build-reviewer-is-outside-the-visual-material-brief-rule), [D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)) | 1          | Follow-on check: a run where the operator states scope out loud at invocation.                      |
| 6   | `plan-a-feature`                     | US-1, US-2, US-3, US-4 | Every applicability row, including the visual reference table and inline placements the inventory reads, the cut list without a per-unit justification field, classification of decisions once after the review round, and this skill's copy grant ([D-8](artifacts/implementation-decision-log.md#d-8-plan-a-feature-gains-the-cut-list-only-not-a-justification-field), [D-10](artifacts/implementation-decision-log.md#trivial-decisions), [D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)) | 1, 4       | The engineered walkthrough ([D-14](artifacts/implementation-decision-log.md#d-14-one-engineered-plan-a-feature-run-carries-the-main-walkthrough)). |
| 7   | `plan-implementation`                | US-1, US-2, US-3, US-4 | Every applicability row except the reference table and the classification change, the scope gate on its existing sweep, and both grants it needs, the copy tool and the directory-creating one it uniquely lacks ([D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)) | 1, 4, 5, 6 | The engineered walkthrough's review-behavior findings, repeated against this skill.                 |
| 8   | `han-github` screenshot file set     | US-3            | The upload script's asset pattern and the embed rules widen to the file set unit 1 fixed, so material that is not a PNG survives into a GitHub issue ([D-20](artifacts/implementation-decision-log.md#d-20-the-github-screenshot-chain-widens-with-the-accepted-file-set)) | 1          | Run the upload script against a folder holding one non-PNG item and confirm it is selected and rendered. |
| 9   | Repository documentation sweep       | US-7            | The remaining cross-plugin surfaces the new convention and the new skill leave stale ([D-16](artifacts/implementation-decision-log.md#d-16-the-documentation-sweep-covers-a-verified-fan-out-list)) | 1, 2, 4, 5, 6, 7, 8 | Read-through against the acceptance checklist's documentation section.                              |

Two intermediate states are expected rather than defects. After unit 1, the three new reference files have no caller
yet, which is not a dangling link. After unit 4 and before unit 6, the inventory briefly has no updated producer to
consume from.

Unit 2 is a third case worth naming, because it is not the same kind. Its rule takes effect for every dispatching skill
in the repository the moment it lands, even though no unit lists it as a dependency. The dependency column tracks what
a unit needs in order to be built; it cannot express a shared file that every skill reads at dispatch time. Unit 2
delivers an observable change on its own, and it delivers operator-visible value only once units 6 and 7 add the rule
that acts on the disclosure.

## Definition of Done

The first item is the per-unit gate that closes the coverage gap R3 names. The rest are the outcomes worth checking
individually.

- [ ] Every unit's Delivers cell landed in full, checked unit by unit against the table above. This one line is what
      keeps the commitments with no individual criterion below from shipping as text nobody observed
      ([D-12](artifacts/implementation-decision-log.md#d-12-verification-is-a-committed-acceptance-checklist-plus-manual-walkthroughs)).

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
- [ ] Every agent that returns findings states where a blind-spot disclosure belongs, in one named shape, and no agent
      gained a field or changed an output format. The read-through covered all twenty-four definitions and logged the
      three exclusions and the `gap-analyzer` exception
      ([D-19](artifacts/implementation-decision-log.md#d-19-agent-definitions-carry-the-disclosure-placement-rule)).
- [ ] A live dispatch against an unopenable input returned the disclosure in the named shape, run once per
      output-format shape rather than once overall.
- [ ] Each of the four planning skills escalates one question at a time, leading with the consequence, carrying named
      candidate answers, and keeping technical references below the question, with the register present in the two
      skills that have an escalation step
      ([D-6](artifacts/implementation-decision-log.md#d-6-the-escalation-register-lands-as-a-register-in-two-skills-only)).
- [ ] `han-feedback` updates today's file in place and states the update, and reports a refused publish as the
      environment refusing rather than the run declining, with a copy-pasteable command handed over.
- [ ] A non-PNG item in the visual-material folder survives the `han-github` upload and renders in the issue
      ([D-20](artifacts/implementation-decision-log.md#d-20-the-github-screenshot-chain-widens-with-the-accepted-file-set)).
- [ ] The four `han-planning` long-form skill docs and `han-feedback`'s long-form doc match the behavior their skills
      now carry, each having travelled with its own unit.
- [ ] `Bash(cp *)` is present on all four planning skills, and each skill's body states that the copy destination is
      the resolved plan folder's visual-material folder
      ([D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)).
- [ ] No plugin version changed in this work.

## Testing Strategy

This repository has no test runner and no CI job that exercises skill behavior. Verification is a written acceptance
checklist committed alongside the change, plus manual walkthroughs run against engineered inputs
([D-12](artifacts/implementation-decision-log.md#d-12-verification-is-a-committed-acceptance-checklist-plus-manual-walkthroughs)).
Reading the diff cannot observe whether a multi-step cross-skill behavior fires, and an unrecorded walkthrough leaves
the next editor nothing.

The checklist is a real deliverable with an address, not a promise
([D-21](artifacts/implementation-decision-log.md#d-21-the-acceptance-checklist-has-a-path-and-an-owning-unit)). It
lives beside the plan's other artifacts, one section per work unit, ordered by the risk ranking below. Unit 1 writes
the sections it can fill and stubs the rest, and each later unit fills its own section as it lands. Writing it that way
is what stops unit 1 from being verified against a file that does not exist yet.

- `docs/plans/planning-scope-corrections/artifacts/acceptance-checklist.md`

- **Observable behaviors to test, in priority order.** The checklist is ordered by risk, highest first.
  1. Visual material reaches every reviewer, including items that arrive after dispatch. This is the one commitment
     with a documented prior failure, and it is silent when broken.
  2. An uninspected input strips blocking severity from the findings resting on it. Also a documented prior failure,
     and silent by construction. Check both halves: the agent writes the disclosure in the named shape, and the
     dispatching skill recognizes that shape and acts on it.
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
  finding under different wording. Five follow-on checks cover what that run cannot reach: a `plan-work-items` run with
  no visual surface at all, a `plan-a-phased-build` run where the operator states scope out loud at invocation, the two
  `han-feedback` corrections, one dispatch per agent output-format shape against an unopenable input, and one
  `han-github` upload of a folder holding a non-PNG item.
- **Test doubles posture and levels:** None apply. There is no code under test and no dependency to stub. The
  substitute for a test double is the engineered input that forces a behavior to fire, above all the reviewer
  positioned so it cannot inspect an input
  ([D-13](artifacts/implementation-decision-log.md#d-13-success-criterion-3-is-checked-with-an-engineered-disclosure-scenario)).

## Risks and Assumptions

### Risks

| ID  | Risk                                                                                                                                                                                          | Impact                                                                                                                                        | Mitigation                                                                                                                                                                                                                                                                       | Owner                          |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| R1  | The proportionality signal is still delivered by brief alone. Specification D28 needs a rough target length in each reviewer's brief, and a length is per-dispatch context rather than a stable property of an agent, so it cannot move to the agent definition the way the disclosure did ([D-19](artifacts/implementation-decision-log.md#d-19-agent-definitions-carry-the-disclosure-placement-rule)). The agent definitions prescribe their own section lists in detail, and a returned review may not fit inside a named target. | One commitment in units 6 and 7 could ship as text that never takes effect. Reviewer output stays as long as it is today. | None. Accepted untracked by user decision ([D-22](artifacts/implementation-decision-log.md#d-22-the-target-lengths-effectiveness-is-not-tracked)). The signal ships as specified and nothing measures whether it works. Specification D28 already records a hard cap as the fallback, so the reopening path exists whenever someone wants it. | Accepted, unowned            |
| R2  | `Bash(cp *)` is an unscoped grant narrowed only by prompt text, because `allowed-tools` scopes by command prefix and not by path ([D-18](artifacts/implementation-decision-log.md#d-18-the-four-planning-skills-gain-a-copy-tool-constrained-by-prompt-text)). | A run could copy to a destination outside the resolved plan folder.                                                                            | Each skill's body states that every copy destination is the plan folder's `ui-designs/`, which a reviewer reading the skill can check.                                                                                                                                            | `han-core:junior-developer`    |
| R3  | Ten of the roughly fifteen commitments have no stated success criterion. The specification's `## How We Will Know It Worked` covers four.                                                       | A commitment could ship as text and never be observed to fire.                                                                                 | The acceptance checklist names what you would see in the produced artifact folder for each remaining commitment ([D-12](artifacts/implementation-decision-log.md#d-12-verification-is-a-committed-acceptance-checklist-plus-manual-walkthroughs)). This adds prose to a section that already exists, not machinery. | `han-core:test-engineer`       |
| R4  | "Beside the plan" is underdefined for `plan-work-items` when it is invoked standalone, because its output folder may differ from any input plan's folder.                                       | The boundary record and the visual-material folder could land in two different places across one chain.                                        | Resolve it in `planning-boundary-rule.md` by stating which folder wins, alongside the other three questions that file settles ([D-1](artifacts/implementation-decision-log.md#d-1-three-han-planning-reference-files-grouped-by-what-interlocks)).                                 | `han-core:information-architect` |
| R5  | The disclosure placement rule reaches nineteen skills across six plugins, because it lands in the shared agent roster rather than in two briefs. That includes `iterative-plan-review`, whose own steps this plan lists as out of scope. | A rule written for planning review changes what every dispatching skill in Han gets back, including one the plan does not otherwise touch.       | Accepted deliberately, and the reason it is safe is that the rule adds no field and changes no output format. It relocates a disclosure those agents already produce. Unit 2 lands on its own so the change can be observed before any planning skill depends on it, and the Out of Scope bullet now states the reach rather than denying it. | `han-core:structural-analyst`  |
| R6  | The rule is copied into twenty-one files rather than stated once, which is the drift pattern this plan otherwise exists to prevent.                                                             | Twenty-one copies of one line can diverge over time, and a future editor has no single source to correct.                                       | Accepted as the cost of the durability the placement rule buys, and bounded by the line being a single sentence in a fixed shape. Unit 2's read-through is what catches divergence, and the Outcome section states the exception so no reader mistakes it for an oversight.                             | `han-core:structural-analyst`  |

### Assumptions

| ID  | Assumption                                                                                                                                                                     | What Changes If Wrong                                                                                                              | Status        |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| A1  | Technical note T1's mechanic holds. The host does not cache a pasted image as a file, which is the fallback branch T1 already names, and the copy branch stays correct for material the operator already holds as a file. | Nothing. This was verified: `~/.claude/paste-cache/` holds only `.txt`, so a genuinely pasted image does not land on disk as a file. | Verified      |
| A2  | A dispatched agent can open a persisted image by path when its brief supplies one.                                                                                              | If it cannot, the visual-material-to-reviewer commitment ships inert, and the engineered walkthrough is where that shows up.        | Runtime-only  |
Assumption A3 was retired. It held the completeness gate's scope in `plan-work-items` as an open question, which is now
a settled decision
([D-23](artifacts/implementation-decision-log.md#d-23-the-completeness-gate-in-plan-work-items-covers-only-what-that-run-received)).
The ID is left recorded here rather than reused, so references to it in the review artifacts still resolve.

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

- **OI-1, closed as ignored by user decision.** Whether a reviewer honors the rough target length its brief names is
  not tracked ([D-22](artifacts/implementation-decision-log.md#d-22-the-target-lengths-effectiveness-is-not-tracked)).
  The signal still ships as specification D28 requires. Nothing measures its effect, and the walkthrough no longer
  checks the returned length. It stays visible here as the accepted risk R1 rather than as a question awaiting an
  answer.

- **OI-2, closed by user decision.** In `plan-work-items` the completeness gate covers only material that run itself
  received
  ([D-23](artifacts/implementation-decision-log.md#d-23-the-completeness-gate-in-plan-work-items-covers-only-what-that-run-received)).
  The specification's applicability table stays satisfied, because the gate is present in that skill and scoped rather
  than absent from it. Unit 1 records the scope as settled instead of asking the question.

- **OI-3, closed by user decision.** `explanation-rule.md` carries guidance only and no self-check, so no planning skill
  gains a check step
  ([D-24](artifacts/implementation-decision-log.md#d-24-the-explanation-standard-carries-guidance-only-and-no-self-check)).
  The gap this accepts is that nothing verifies the standard took effect, which is the same gap the specification
  accepted when it deferred a rewrite pass for escalation prose, under the same reopening trigger.

None remain. All three items this plan carried after review were closed by user decision, and the record of where each
went is kept above so a reader can follow them.

## Specialist Handoffs for Implementation

- **`han-core:test-engineer`.** Dispatch at unit 1 to author the acceptance checklist's structure and the sections that
  unit can fill; needs the risk ranking in the Testing Strategy and the work-unit table.
- **`han-core:structural-analyst`.** Dispatch at unit 2, to apply the findings-returning test across all twenty-four
  agent definitions, confirm the one rule line reads consistently against each output-format shape, and log the
  exclusions and the `gap-analyzer` insert-point exception; needs
  [D-19](artifacts/implementation-decision-log.md#d-19-agent-definitions-carry-the-disclosure-placement-rule) and the
  agent roster.
- **`han-core:information-architect`.** Dispatch at unit 9, for the repository-root documentation sweep; needs the
  verified fan-out list in
  [D-16](artifacts/implementation-decision-log.md#d-16-the-documentation-sweep-covers-a-verified-fan-out-list) and the
  new skill as it landed in unit 1.
- **`han-core:junior-developer`.** Dispatch after unit 6, to run the engineered walkthrough as a naive operator; needs
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

## Review History

- **Review mode:** team.
- **Rounds completed:** 3 (R4, R5, R6). See
  [artifacts/review-iteration-history.md](artifacts/review-iteration-history.md). Round IDs continue from the plan's own
  build history, so they stay unique across both records.
- **Team composition:**
  - `han-core:junior-developer`, required: generalist stress-test of a plan amended by hand.
  - `han-core:adversarial-validator`, required: the scope-expanding amendment was the freshest and least-tested
    reasoning in the plan.
  - `han-core:evidence-based-investigator`, conditionally mandatory and clearly triggered: the plan carries file paths
    with line references throughout.
  - `han-core:structural-analyst`, because the reference-file decomposition and the shared-roster change are the plan's
    coupling decisions.
- **Findings raised:** 26. See [artifacts/review-findings.md](artifacts/review-findings.md). Twenty resolved by
  evidence, two by user input, one deferred to an open item, and three minor edits applied directly.
- **Assumptions challenged:** Three claims the plan presented as measured were refuted by direct check: the
  blast-radius count, the uniformity of the insert point, and the size of the agent roster. A fourth, that agents
  already disclose reliably, was softened to what one reported incident supports.
- **Consolidations made:** None. The review found no redundant work unit or duplicated rule; its findings were
  bookkeeping, scope, and two real gaps in coverage.
- **Ambiguities resolved:** The rule's scope moved from a count to a test. The seam between the agent and the consuming
  skill gained a stated shape. The acceptance checklist gained a path and an owning unit. The four questions the shared
  boundary reference has to settle were named rather than left implicit.
- **Open items remaining:** 0. All three closed by user decision after the review converged: OI-1 as ignored
  ([D-22](artifacts/implementation-decision-log.md#d-22-the-target-lengths-effectiveness-is-not-tracked)), OI-2 by
  scoping the gate
  ([D-23](artifacts/implementation-decision-log.md#d-23-the-completeness-gate-in-plan-work-items-covers-only-what-that-run-received)),
  and OI-3 by taking the guidance-only version of the new standard
  ([D-24](artifacts/implementation-decision-log.md#d-24-the-explanation-standard-carries-guidance-only-and-no-self-check)).

## Recommendation

Ship as planned, in the sequence above. No open item blocks the start. The one thing unit 1 has to settle before it can
be written is the set of four questions `planning-boundary-rule.md` owns: which folder wins for "beside the plan", the
boundary record's sections, the enumerated file set, and the ownership preamble's wording.
