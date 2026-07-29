# Acceptance Checklist: Planning Scope Corrections

This is the verification record for the change. The repository has no test runner and no CI job that exercises skill
behavior, so every commitment is checked either by a read-through against a named file or by a manual walkthrough against
an engineered input
([D-12](implementation-decision-log.md#d-12-verification-is-a-committed-acceptance-checklist-plus-manual-walkthroughs)).

Unit 1 wrote the structure and filled the sections it could. Each later unit filled its own section as it landed
([D-21](implementation-decision-log.md#d-21-the-acceptance-checklist-has-a-path-and-an-owning-unit)).

All nine units have landed. Every check that can be closed by reading a file is closed. What remains is the set of checks
that need a live run to produce, listed together below so they are not mistaken for oversights.

## What still needs a live run

These cannot be closed by read-through. Each names the run that would close it.

- The engineered `plan-a-feature` walkthrough
  ([D-14](implementation-decision-log.md#d-14-one-engineered-plan-a-feature-run-carries-the-main-walkthrough)), which
  covers Risk 1 end to end, the scope gate's floor, and the merge and unverified passes.
- The same walkthrough's review-behavior findings repeated against `plan-implementation`.
- One dispatch per agent output-format shape against an input the agent cannot open, confirming the disclosure rides on
  the finding in the named shape.
- A `plan-work-items` run against a plan with no visual surface at all.
- A `plan-a-phased-build` run where the user states scope out loud at invocation.
- Two `han-feedback` runs: a same-day second run, and a run in an environment that refuses to publish.
- One `han-github` upload against a real target repo holding a non-PNG item.

The read-through checks below stand on their own: they confirm the rules are written where the skills will read them. The
runs above are what confirm the rules fire.

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

**Status:** Agent half landed in unit 2. Skill half not yet landed; delivered by units 6 and 7.

- [x] Every agent whose output is a claim a dispatching skill weighs carries the disclosure-placement rule line, in one
      named shape, in its `## Rules` list. The read-through covered all twenty-four agent definitions in
      `han-core/agents/`, `han-communication/agents/`, and `han-research/agents/`, and the test resolved to twenty-one.
- [x] The named shape is one line appended to the finding, reading
      `Unverified: could not inspect {the input}, because {the reason}.` One form serves both output shapes in the
      roster: the ten agents with per-finding fielded blocks and the rest with numbered items.
- [x] The three exclusions are logged with the reason each was excluded: `project-scanner` and `codebase-explorer`
      (discovery output, so there is no claim for a disclosure to attach to), `readability-editor` (a rewritten
      artifact).
- [x] `gap-analyzer` carries the line inside its `## Rules` section rather than after `## Graceful Degradation`, which
      is the one file where `## Rules` is not the last heading. Verified by reading lines 241 through 268 of that file.
- [x] No agent gained a field and no agent's output format changed. The diff over the three agent directories is 105
      insertions and zero deletions across 21 files.
- [x] The long-form docs gained the sentence only where it was needed: the six agents whose docs describe an assumptions
      section (`data-engineer`, `devops-engineer`, `junior-developer`, `information-architect`, `on-call-engineer`,
      `user-experience-designer`) and `structural-analyst`, whose doc describes a skipped-dimensions note. A reader of
      any of those seven could otherwise conclude that a blind spot belongs there.
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

**Status:** Landed, except the live-dispatch check. See Risk 2 above for this unit's checks; they live there because that
is where the risk is ranked.

The live dispatch is the one check this unit cannot close by read-through. It needs a real run per output-format shape
against an input the agent cannot open, and it is listed under Risk 2 rather than here.

## Unit 3: `han-feedback` corrections

**Status:** Landed by read-through. The two follow-on runs remain.

- [x] The operating principle now reads "One file per day, updated in place" and states that an existing file is
      updatable rather than closed.
- [x] Step 3 branches on whether anything new has happened, updates in place on the "something new" path, and names the
      skip path as the narrow one.
- [x] Step 4 keeps the existing filename when updating, so the path already reported to the user still resolves.
- [x] Step 7 edits in place, preserves every recorded point, and states the update by naming the file and what was added.
- [x] Step 10 carries an environment-refused case: it says the environment refused rather than that the run declined,
      does not retry the identical command, and hands over the filled-in command.
- [x] `han-feedback`'s long-form doc matches the behavior the skill now carries, in its feedback-file bullet, its
      GitHub-issue output bullet, and a new "run it again later in the same day" tip.
- [ ] Follow-on run: a same-day second run updates today's file in place and states the update.
- [ ] Follow-on run: a run in an environment that refuses to publish reports the environment refusing, does not retry,
      and hands over the command.

## Unit 4: `plan-work-items`

**Status:** Landed by read-through. One follow-on run remains.

- [x] A new Step 0 reads `artifacts/scope-boundary.md` when it exists and establishes one when it does not.
- [x] The confirmation turn fires only on the absent-record path, and a recorded direction-of-travel answer is never
      re-asked.
- [x] The conflict rule is present: a work item conflicting with the record surfaces the conflict rather than
      overwriting or silently trusting it.
- [x] Every work item carries a `**Justification.**` field of its own, placed immediately before `**References.**`, and
      the format invariants say so. It is required on every item.
- [x] A candidate that cannot be justified goes in `## Cut for Scope`, which names what it would have done in plain
      language and why, opens with a line distinguishing it from the deferral section, and is printed in the closing
      summary so the user can reverse it.
- [x] The single stop is named in the operating principles as one of exactly two exceptions to autonomy, and the
      missing-artifact rule routes qualifying inputs into it.
- [x] No visual surface and visual work with no designs are handled as two different situations, stated as a rule
      ([D-27 in the specification](decision-log.md#d27-plan-work-items-separates-no-visual-surface-from-visual-work-with-no-designs)).
- [x] The missing-artifact rule is reconciled and split by who can supply the artifact, and the three places agree: the
      canonical rule now lives in the inventory reference's "Missing-artifact handling", Step 4 points at it rather than
      restating it, and the operating principle names the stop as an exception instead of forbidding it
      ([D-3](implementation-decision-log.md#d-3-the-missing-artifact-rule-stays-local-to-plan-work-items)).
- [x] The autonomy principle and the one-file statement no longer contradict the skill's own steps. Autonomy names its
      two exceptions; the one-file statement scopes itself to the breakdown and names the companion artifacts
      ([D-7](implementation-decision-log.md#d-7-the-plan-work-items-autonomy-and-one-file-principles-are-edited-not-worked-around)).
- [x] The lead paragraph at the top of the skill matches, describing the run as autonomous apart from those two turns.
- [x] `Bash(cp *)` is present on `allowed-tools`, and Step 0 states that copy destinations are always the resolved output
      folder's `ui-designs/`.
- [x] The completeness gate runs before the file is declared finished, and covers only material this run received
      ([D-23](implementation-decision-log.md#d-23-the-completeness-gate-in-plan-work-items-covers-only-what-that-run-received)).
- [x] `han-communication:explanation-guidance` is sourced before the confirmation turn and before the single stop.
- [x] The drafting agent receives the boundary record and the justification-and-cutting directive, including the floor.
- [x] The long-form doc matches the behavior the skill now carries.
- [ ] Follow-on run: a run against a plan with no visual surface at all omits the design-reference block and reports no
      missing artifact.

## Unit 5: `plan-a-phased-build`

**Status:** Landed by read-through. One follow-on run remains.

- [x] A new Step 1.5 reads and records the boundary, before the Step 3 interview begins.
- [x] Operator-stated shaping context goes into the record's Operator-Stated Scope section, treated as a boundary
      statement rather than a divergence to justify, and the Step 3 divergences join it as they are captured
      ([D-34 in the specification](decision-log.md#d34-operator-stated-shaping-context-is-part-of-the-boundary)).
- [x] The direction-of-travel answer is inherited when already recorded and asked once when not, with its subjects named
      from the work item.
- [x] The conflict rule is present.
- [x] Visual material is persisted on arrival, `Bash(cp *)` is on `allowed-tools`, and Step 1.5 states that copy
      destinations are always the resolved output folder's `ui-designs/`.
- [x] The completeness gate runs before the finished outline is presented.
- [x] Every phase carries a `**Justification.**` line of its own in the outline template, on both the Phase 1 and the
      Phase N block, so it is not a clause of the sequencing rationale.
- [x] The scope gate attaches as step 6 of the existing candidate evaluation in Step 4, with cuts flowing to the
      deferred-phases list. No sweep step was added
      ([D-5](implementation-decision-log.md#d-5-the-scope-gate-attaches-to-existing-yagni-points-not-to-a-new-sweep-step)).
- [x] The floor is stated at the attach point, along with the rule that an upstream artifact is not a scope authority.
- [x] The template distinguishes a scope cut from a YAGNI deferral in the Phase Kinds glossary and in the deferred-phase
      block, and says a scope cut carries no reopening trigger.
- [x] The single stop is present as an operating principle, and no escalation pass was added. The principle says so
      outright: questions that need a decision land in Open Questions, where they already belong
      ([D-6](implementation-decision-log.md#d-6-the-escalation-register-lands-as-a-register-in-two-skills-only)).
- [x] The escalation register attaches to the single stop in the closing summary rather than standing on its own.
- [x] The reviewer-scope clause is present at Step 7, stating that this skill's single fixed-domain reviewer sits outside
      the visual-material brief rule, and telling the next implementer not to widen the step to a review team
      ([D-9](implementation-decision-log.md#d-9-the-single-phased-build-reviewer-is-outside-the-visual-material-brief-rule)).
- [x] `han-communication:explanation-guidance` is sourced before the confirmation turn and before the single stop.
- [x] The long-form doc matches the behavior the skill now carries.
- [ ] Follow-on run: a run where the user states scope out loud at invocation records that scope in the boundary record
      and phases inside it.

## Unit 6: `plan-a-feature`

**Status:** Landed by read-through. The engineered walkthrough remains.

- [x] A new Step 1.5 reads and records the boundary before Step 2 discovery and the Step 4 interview, with the
      confirmation turn, the conflict rule, the no-outward-traversal rule, and the note that a recorded boundary is often
      the user's own words rather than the work item's verbatim text.
- [x] The specification template carries a `### Visual Reference` table under that exact heading, with the state each item
      shows and a hosted URL handled in place of a path, plus the instruction to embed each item beside the prose
      describing its state and the reason why (the downstream inventory maps by that prose).
- [x] `## Cut for Scope` sits immediately before `## Deferred (YAGNI)` in the template, and each opens with one line
      saying what it is not
      ([D-8](implementation-decision-log.md#d-8-plan-a-feature-gains-the-cut-list-only-not-a-justification-field)).
- [x] The skill gained the cut list and no per-unit justification field, because it produces a specification rather than
      work units. No `Justification` field was added to the specification template.
- [x] Decisions are classified once, in Step 8 synthesis, after the review round. Step 5 writes every decision in full
      form and says why it defers the split; the decision-log template says the same, and records that D# numbers do not
      change during classification so inline links keep resolving.
- [x] The scope gate attaches at finding-resolution path 5b, beside the existing YAGNI path 5a, with cut entries flowing
      into Step 8 synthesis. No sweep step was added, and the gate reduces to a work-item check on the skill's own
      commitments because there is no upstream artifact
      ([D-5](implementation-decision-log.md#d-5-the-scope-gate-attaches-to-existing-yagni-points-not-to-a-new-sweep-step)).
- [x] The floor is stated at the attach point, with the calibration line.
- [x] Step 6 passes the visual material to every dispatched reviewer with the state each item shows, and handles material
      arriving after dispatch by re-briefing the reachable reviewers and recording which never got it.
- [x] Step 6's shared brief carries the proportionality signal as a rough target line count rather than a size word, and
      states that it governs how much each reviewer writes and never how many reviewers are chosen.
- [x] Step 6's shared brief tells each reviewer to put a blind-spot disclosure on the finding itself.
- [x] Step 7 runs three passes before per-finding work, in order: merge by substance carrying every reviewer's identifier,
      strip blocking severity from findings resting on an uninspected input, then check design-dependent findings against
      the designs. The order is stated along with why merging comes first.
- [x] Unaudited evidence classes are recorded when decisions rest on material no reviewer received.
- [x] Escalations go one question per turn, leading with the consequence, carrying named candidate answers, with technical
      references below the question, and stating how many are pending. Grouping by decision survives as an ordering rather
      than a batch.
- [x] The escalation register is present, recorded in `artifacts/team-findings.md` with the question, the answer, and where
      the answer landed.
- [x] The team-findings template carries the reviewer-identifiers field, the conditional `Unverified:` field, the
      design-check field, the unaudited-evidence section, and the escalation register.
- [x] The completeness gate runs at Step 9 before the summary, reading the record rather than run memory.
- [x] `Bash(cp *)` is present, and Step 1.5 states the copy destination.
- [x] The closing summary shows the cut list in the message rather than only pointing at the section, says it can be
      reinstated, and keeps it distinct from the YAGNI deferral count.
- [x] `han-communication:explanation-guidance` is sourced before the confirmation turn and before the first escalation.
- [x] The long-form doc matches the behavior the skill now carries.
- [ ] The engineered walkthrough
      ([D-14](implementation-decision-log.md#d-14-one-engineered-plan-a-feature-run-carries-the-main-walkthrough)): a work
      item with a stated exclusion and an implied necessity, two images at session start (one depicting something the
      ticket never mentions), a third arriving after dispatch, one reviewer positioned so it cannot inspect an input, and
      two reviewers raising the same finding under different wording.

## Unit 7: `plan-implementation`

**Status:** Landed by read-through. The repeated walkthrough findings remain.

- [x] Every applicability row the specification assigns to this skill is present. The reference table and the
      classification change are absent, correctly: both belong to `plan-a-feature`.
- [x] A new Step 1.5 reads and records the boundary before Step 2 discovery, with the confirmation turn, the conflict rule,
      and the no-outward-traversal rule. It also states that material the upstream specification's `Visual Reference` table
      already persisted is not this run's to re-copy.
- [x] The ground-truth operating principle now carves out scope: the specification stays authoritative for behavior and is
      no longer a scope authority, with the license scoped to unrequested subsystems and nothing else.
- [x] The scope gate attaches to the existing `## Step 7.5: YAGNI Sweep` as a third gate. This is the one skill of the four
      with a discrete sweep step to attach to
      ([D-5](implementation-decision-log.md#d-5-the-scope-gate-attaches-to-existing-yagni-points-not-to-a-new-sweep-step)).
- [x] The scope gate's in-scope set is explicitly wider than the YAGNI gates': it walks everything inherited from the
      specification, not only what the loop produced, and the asymmetry is stated rather than left to be noticed.
- [x] The floor is stated at the attach point, with the calibration line.
- [x] The mechanic-contradiction protocol gains the out-of-scope verdict as a third kind, with the reason it needs its own
      kind (the protocol detects disagreement by whether an alternative was named), and it does not count toward the
      spec-maturity threshold.
- [x] Step 4 passes visual material to every dispatched specialist with the state each item shows, plus the boundary
      record's path.
- [x] Step 4 carries the proportionality signal as a rough target line count, stated as a target not a cap, governing
      output length and never team size.
- [x] Step 4 tells each specialist to put a blind-spot disclosure on the finding itself.
- [x] Step 5 runs the three passes in order before building the claim ledger, and the ledger gains an `Unverified` state.
- [x] Escalations in Step 6 and Step 7 go one question per turn with the consequence leading, technical detail below, and a
      pending count. Step 7 states there is no end-of-run batch.
- [x] The escalation register is present, recorded in `artifacts/implementation-iteration-history.md`.
- [x] The single stop is present at Step 7 for an input only the user can supply.
- [x] The plan template carries a `Justification` column on the work-unit table, a `## Cut for Scope` section immediately
      before `## Deferred (YAGNI)` with each opening on what it is not, and a `Recorded boundary` bullet in Constraints.
- [x] The synthesis audit checks that every `Justification` cell is filled and that no entry appears in both the cut list
      and the deferral list.
- [x] The completeness gate runs at Step 9 before the summary, reading the record rather than run memory.
- [x] `Bash(cp *)` and `Bash(mkdir *)` are both present. This was the only one of the four skills lacking the
      directory-creating grant, which it needs because it may create `artifacts/` and `ui-designs/`.
- [x] The closing summary shows the cut list in the message, keeps it distinct from the deferral count, and names any
      finding that stayed unverified.
- [x] `han-communication:explanation-guidance` is sourced before the confirmation turn and before the first escalation.
- [x] The long-form doc matches the behavior the skill now carries.
- [ ] The engineered walkthrough's review-behavior findings, repeated against this skill: visual material reaching every
      specialist, a specialist positioned so it cannot inspect an input, and two specialists raising the same finding under
      different wording.

## Unit 8: `han-github` screenshot file set

**Status:** Landed, with the selection half verified by running the pattern. The upload-and-render half needs a real
target repo and remains.

- [x] The upload script's asset-selection pattern accepts every type in the accepted file set, held in one
      `ASSET_EXT_PATTERN` variable so the set has a single place in the script.
- [x] `shellcheck` passes on the modified script.
- [x] `screenshot-embed-rules.md` accepts the same set, names the three places that must agree, and says outright why the
      third matters: widening the upload without the template writes a `.png` extension over a file that is not one, so
      the upload succeeds and the image still breaks.
- [x] `issue-template.md`'s embed markdown and stated path scheme accept the same set, and both say never to rewrite a
      source file's extension, since the upload resolves the source by the filename in the URL.
- [x] The `.pdf` case is handled rather than glossed: GitHub does not render a PDF inline, so it is linked rather than
      embedded as an image. Stated in both the embed rules and the template.
- [x] `SKILL.md` and the long-form doc match.
- [x] Verified by running the widened pattern against a work-items file holding a `.jpg`, a `.png`, and a `.pdf` embed: it
      selected all three, where the old `.png`-only pattern selected one and dropped the other two silently. That silent
      drop is the defect this unit fixes.
- [ ] Remaining: run the full script against a real target repo with one non-PNG item, and confirm it uploads and renders
      in the issue
      ([D-20](implementation-decision-log.md#d-20-the-github-screenshot-chain-widens-with-the-accepted-file-set)). This
      needs a live repo and `gh` credentials, so it cannot be closed by read-through.

## Unit 9: Repository documentation sweep

**Status:** Landed.

- [x] `CLAUDE.md`'s plugin roster sentence names the explanation standard and the new skill.
- [x] Both `CLAUDE.md` tree comments for `han-communication` name the new skill and the new reference file.
- [x] `CLAUDE.md`'s foundational-layer paragraph names the explanation standard alongside the readability standard.
- [x] `CLAUDE.md`'s "When to use which doc" section gains an entry for `explanation-rule.md` and a new subsection for the
      three `han-planning`-owned convention files, closing with the statement that all three are owned rather than
      vendored.
- [x] `CONTRIBUTING.md`'s `han-communication` component list names both guidance skills and both standards, and its
      "a component goes here only when" test widens from readability to communication.
- [x] `docs/choosing-a-han-plugin.md` names the explanation standard in the `han-communication` entry.
- [x] The skills index lists every skill in every plugin's `skills/` directory, verified by enumerating the directories
      against the index rather than by a count. Same enumeration confirmed every skill has a long-form doc in its plugin's
      `docs/skills/` and a scent line in its plugin's `README.md`.
- [x] No surface outside `docs/plans/` and `docs/research/` describes `han-planning/references/` as vendored copies only.
      The two `docs/research/` mentions are left alone: that report is a dated historical record of what was true when it
      was written, not a live description of the folder.
- [x] No plugin version changed in this work, verified by diffing every `plugin.json` and the marketplace manifest across
      the range of commits this work produced.
