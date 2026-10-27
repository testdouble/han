# Investigation: Review loops polish one approach instead of reassessing it

Investigation report. Read the Summary, then approve the Planned Fix or push back. One question is open for you under Problem Statement: which workflow produced the six rounds.

## Summary

- **Root Cause:** No Han loop has a finding kind, a route, or a memory for "the mechanism is the problem". Three gaps combine:
  - `code-review` consolidates finding by finding, with no cross-finding view and no memory across runs (E3, E10, E11).
  - `iterative-plan-review` records every finding as a section edit and reads its own history only to keep IDs unique (E3, E6).
  - Every round brief frames the work as find-and-fix inside the artifact (E4, E12, E19, E23).
- **Fix:** Build a `reassess-approach` skill in `han-planning` that dispatches a critic in a fresh context to produce two or three structurally different alternatives, including "stop", with evidence and a recommendation. `iterative-plan-review` and `plan-implementation` invoke it when they reach their round cap without converging, record its result as an `approach` finding, and hand you the choice.
- **Why Correct:** The structural evidence survived adversarial validation:
  - No category or route exists for an approach finding (E3, E10).
  - The plan-review stop rule reads only the latest round, so a plan accumulating edge cases runs to the cap while patching (E2, V11).
  - `plan-implementation` already names the cap-without-convergence state a "facilitation plateau" and does nothing with it (E14).
  - A fresh-context critic is the one idea in the repo's prior research on this failure that survived that research's own validation (E20).
- **Validation Outcome:** Two validators refuted the "suppression" and "YAGNI tilt" mechanisms (V2, V3, V5, V8, V9), found a missed anchoring channel in `code-review`'s branch context (V6, now E23), and cut the first fix from five loops to two (V14, V15, V17). You then redirected the fix from inline checks to a dedicated skill with a non-convergence trigger (V21).
- **Remaining Risks:** Confidence is Medium. The value of LLM-generated alternatives is unvalidated until the skill's fixture runs, and the reported case was hand-driven, so only the hand-invoked path covers it today. See Confidence Assessment.

## Problem Statement

When a Han review or iteration loop runs, the agent keeps polishing the first solution. It does not step back to ask whether a different tool, a different code shape, or dropping the work would remove a whole class of findings at once. The example you gave: an agent spent six review rounds perfecting a regex-based parser instead of switching to a parser-generator library or asking whether parsing that input was worth doing.

Expected behavior: when a loop reaches its round cap and is still producing findings, it names the approach as the open question, lists the alternatives including "stop", and hands you that choice instead of ending on a note that the team plateaued.

Conditions: the two Han skills that run review rounds, `iterative-plan-review` and `plan-implementation`. Both cap at one to three rounds by size (E2, E14). The `han-coding` skills do not loop in this sense: `tdd` and `refactor` iterate over a list of build steps, and `code-review` is a single pass, so they are out of scope for the automatic trigger. A fix-and-re-review cycle run by hand has no loop to trigger from, which is why the new skill is also invocable directly.

Impact: wasted rounds and tokens, and a shipped solution that carries more edge cases and more code than it needed. The failure is silent. No finding, stop, or summary says "we have now reworked this area N times".

Where the six rounds came from: you told an agent in plain conversation to "fix review findings, then re-review for regressions; iterate until review converges or stalls". No Han loop was driving it, so the automatic trigger below would not have fired. The hand-invoked path of the new skill is the part that applies to that case, and you named it as the first building block for a skill that drives a merge request to completion.

## Root Cause Analysis

### Root Cause

The loops can only say "this finding, this fix". They have no representation for "this mechanism explains these findings", no memory of how often one unit has drawn findings, and no step that runs when either signal appears.

### Why the loops stay on the first approach

The gap is original, not a regression. Git history holds no commit that ever added or removed an approach-questioning instruction (E21). The authoring guidance the loops were built from describes iterative refinement as "fix specific issues, don't regenerate everything" with a pass cap (E19). Every loop follows that shape.

Three mechanisms combine to keep an agent on its first approach:

1. **No representation.** `iterative-plan-review` records a finding under `assumption refuted / overlap / ambiguity / edge case / unhandled failure mode / standards conflict / mechanics leaking into spec`, and its resolution field is "the plan edit applied" (E3). `code-review` routes every fix as `test-first`, `restructure`, or `by hand` (E10). `tdd` mutates its test list by adding, deferring, or crossing off items (E12). A reviewer who sees the parser as the problem has to file it as one more edge case. The question "is this addressing the problem or a symptom?" is asked by `junior-developer` on every dispatch (E18), and in `iterative-plan-review` its answer can reach you through the between-rounds question channel (E24). But it arrives unlabeled, most likely classed as an ambiguity, and nothing prioritizes it over the edge cases filed beside it.

2. **No memory.** `code-review` replaces its prior report and restarts IDs at 001 on every run (E11), so a fix-and-re-review cycle has no accumulator. `iterative-plan-review` persists its findings file across invocations but reads it only to continue ID numbering (E6). The one recurrence detector in the suite is `refactor`'s two-consecutive-reverts stop (E13).

   The effect in `iterative-plan-review` is not quiet early convergence. "Edge case" is a force-up-to-major keyword (E2), so a plan accumulating edge-case findings fails the "zero major findings" test every round. It runs to the cap while patching (V11).

3. **Find-and-fix framing.** Every brief asks for defects in the artifact as it stands: "findings requiring plan changes" with an example that assumes the layout and asks where it conflicts (E4), "Analyze ... for the following files" in `code-review` (E8), and a branch-context summary that passes reviewers "premises the team has already locked in" (E23). None of these forbids an approach finding. `team-selection.md` licenses the validator to attack "the plan's evidence, proposed approach, and assumptions" (E18), and in a branch-diff review the parser stays "introduced by the change" on every re-run (V5). The framing anchors; it does not prohibit. That is why the fix adds a labeled finding and a trigger rather than removing a ban.

Two mechanisms the draft named were checked and dropped. The spec-aware brief's ban on library recommendations (E5) is a deliberate boundary at the spec stage, where a regex-versus-library choice never sits (V3). The YAGNI shape ladder and the evidence rule (E16, E17) do not tilt against a library. The ladder never mentions libraries, and "fewer code paths" can favor one. The corroboration gate applies to web claims only, and rework counts are codebase evidence (V8, V9).

The one skill that compares approaches is `design-an-api`, once, before refinement (E15). No other loop has that step. A prior research report in this repo named this failure "premature convergence", with two independent corroborating sources, and declined to act until Han-specific evidence appeared (E20). Your report is one such data point, from an unidentified workflow.

## Planned Fix

### Approach

Build one skill, `reassess-approach`, that answers "is this still the right approach?" in a fresh context, and have the two review loops invoke it when they hit their round cap without converging.

Design choices, with the evidence behind each:

- **A skill, not an inline check.** The loop that built the artifact is anchored on it (E4, E23). A skill that gathers the artifact, the findings, and the round history, then dispatches a critic with only that material, gets the branch isolation the repo's prior research found best supported (E20). It also has one canonical home, its own eval, and a slash command you can run by hand on a plan or a branch when no loop is involved.
- **Trigger is non-convergence at the cap, nothing softer.** Both loops already carry a deterministic stop rule: converge when the latest round produced two or fewer new findings and zero major findings, and never exceed the size cap (E2, E14). Non-convergence is that rule failing at the cap. It reuses the existing counts, so no new threshold is introduced, and a literal-following model cannot fire it early (V18). The cap, not a separate `n`, is the iteration count; it already scales with size and with project configuration.
- **Skill does the deterministic work, an agent does the judgment.** Per the entity taxonomy, gathering inputs, dispatching, recording, and presenting are a flowchart; proposing structurally different alternatives is judgment. The skill's one judgment call is dispatched, in the same shape `design-an-api` uses for "options before commitment" (E15).
- **The result is a decision for you, not a rewrite.** `iterative-plan-review` may not generate a new plan (E1), and the research's one peer-reviewed source warns that LLM reframes may add little (E20). The skill returns options with evidence and a recommendation. The loop records them as an `approach` finding and presents them through its existing question channel (E24, operator-escalation rule). "Continue as is" is a first-class answer.
- **No new stop boundary.** The trigger fires at the cap, where both runs end today. Under `/pairing` the end of the run is already a stop, so the collaborative flag gains no boundary.

### Changes

#### `han-planning/skills/reassess-approach/SKILL.md` (new)

- **Change:** Add the skill. Build it through `/han-plugin-builder:skill-builder`, which walks entity fit, use cases, name, description, steps, tools, and layout, then reviews the result against the authoring guidance. The design below is the input to that interview, not a substitute for it.
- **Evidence:** E1, E3, E4, E14, E15, E18, E20, E23, E24.
- **Standards:** CLAUDE.md requires `han-plugin-builder` for every new skill; entity taxonomy (skill = flowchart, agent = judgment); model-agnostic instruction style; description frontmatter with the "does not" boundaries; config probe and `han-config-dir.sh` grant copied from an existing skill.
- **Details:**
  1. **Inputs.** Three things: the artifact (a plan file, or a code unit named by path); the loop's findings file when one exists (`artifacts/review-findings.md` or the implementation iteration history); and a one-line statement of why the caller is asking, naming the cap reached and the last round's finding count. When invoked by hand with no findings file, the skill builds the finding list itself with one `han-core:evidence-based-investigator` dispatch over the unit.
  2. **Dispatch.** One agent, in a fresh context, with only the inputs above, the project's coding standards and ADRs, and the YAGNI rule. The brief tells the agent to assume the current approach is the wrong one and to produce two or three structurally different alternatives, each one a thing someone could build. For each alternative it gives the evidence, the owned code paths or plan items it adds or removes, and the class of recorded findings it would make moot. "Stop doing this" and "continue as is" are always named options. The brief ends with one recommendation. The recommended agent is `han-core:software-architect`, which `design-an-api` already dispatches for the same options-before-commitment shape and which carries the YAGNI and simpler-version fields (E15). The `skill-builder` interview confirms or replaces that choice.
  3. **Output.** A short options report in the plan folder (`artifacts/approach-reassessment-R{n}.md`) with the options, evidence, recommendation, and what to run next for each option (`plan-a-change` for a restructure, `plan-a-feature` to re-specify, `refactor` for a behavior-preserving substitution, or nothing). The skill returns its path and the recommendation line to the caller.
  4. **Hand-invoked mode.** When run by a person, present the options as one question with named candidates per the operator-escalation rule and end the turn. The skill changes nothing.
  5. **Readability.** Invoke `han-communication:readability-guidance` before writing the report; dispatch `han-communication:readability-editor` only if the interview finds the report long enough to count as synthesis output.

#### `han-planning/skills/iterative-plan-review/SKILL.md`

- **Change:** Add `approach` as a major category and a non-convergence hand-off at the cap.
- **Evidence:** E2, E3, E6, E24.
- **Standards:** The stop rule stays deterministic; the between-rounds question keeps its existing shape; the collaborative flag adds no boundary.
- **Details:**
  1. Step 4 sub-step 3 (classify): add `approach` to the major list, defined as "a finding that names the plan's mechanism as the open question and carries the alternatives considered".
  2. Stop rule, both modes (lines 247-249 and 352-355): after "Never exceed the size cap", add: when the cap is reached and the most recent round did not satisfy the convergence condition, invoke `han-planning:reassess-approach` with the plan path, `artifacts/review-findings.md`, and the last round's counts. Record its recommendation as an `approach` finding (`F#`, major) with `Alternatives:` filled, `Resolution:` blank, and `Resolved by: user input` pending.
  3. Present it through the existing between-rounds question (lines 364-367) as the run's closing question, with the options as the named candidates and the skill's recommendation as the recommended answer. The run ends there, as it does today at the cap.
  4. Lightweight mode: same hand-off at its one-iteration cap, with the self-review findings as the findings file.

#### `han-planning/skills/iterative-plan-review/references/review-findings-template.md`

- **Change:** Add `approach` to the `Category` comment at line 56 and an `Alternatives:` field to the major-finding entry, with a pointer to the reassessment report.
- **Evidence:** E3.
- **Standards:** Companion-file IDs stay globally unique across sessions.
- **Details:** No new ID series. An approach finding is an `F#` entry with a category, so existing cross-references and `Raised in round:` keep working.

#### `han-planning/skills/plan-implementation/SKILL.md` and `references/round-aggregation.md`

- **Change:** Replace the "facilitation plateau" note with the hand-off, and add an `approach` tag to the ledger.
- **Evidence:** E14.
- **Standards:** Operator-escalation rule (one question, plain-language lead, named candidates, single stop); contract-pinning and `T#` commitments unchanged.
- **Details:**
  1. Lines 375-377: when the team is still iterating at the cap, invoke `han-planning:reassess-approach` with the spec or plan, the implementation iteration history, and the remaining Open Questions. Surface its options alongside the remaining Open Questions as the escalation to the user, with the recommendation.
  2. `round-aggregation.md`: add an `approach` tag beside `spec-level` and `plan-level`, so the result has a ledger row and the synthesizer sees it. The spec-maturity gate thresholds at lines 38-46 do not change.
  3. If the user picks an alternative, the run routes as the options report says (back to `plan-a-feature` or on to `plan-a-change`) rather than into synthesis.

#### `han-planning/docs/skills/reassess-approach.md` (new), `han-planning/README.md`, `docs/skills/README.md`, `CLAUDE.md`, `docs/workflows.md`

- **Change:** Long-form doc from the skill template; scent line in the plugin README; alphabetized index entry; add the skill to the `han-planning` catalog lines in CLAUDE.md and CONTRIBUTING.md; add the hand-off to the planning workflow prose and mermaid diagram.
- **Evidence:** Coverage rule; "one canonical source per concept"; CONTRIBUTING.md "Adding a skill" steps 3 to 7.
- **Standards:** Readability standard; writing voice; the scent line reuses the long-form doc's summary line.
- **Details:** The long-form doc names `/pairing` as the manual way to redirect a loop before the cap (E22), and says plainly that the skill proposes and never rewrites.

#### `han-planning/docs/skills/iterative-plan-review.md`, `han-planning/docs/skills/plan-implementation.md`, `CHANGELOG.md`

- **Change:** A short "When the run reaches its cap without converging" paragraph in each long-form doc, and a CHANGELOG entry under Unreleased.
- **Evidence:** Coverage rule.
- **Standards:** Readability standard.
- **Details:** Each paragraph says what triggers the hand-off, what comes back, and that "continue as is" is a valid answer.

#### `evals/reassess-approach/` (new) and `evals/iterative-plan-review/`

- **Change:** An eval suite for the new skill with one fixture: a plan whose findings file shows three rounds of edge-case findings on one hand-written parsing mechanism. The rubric rewards options that are structurally different, include "stop", and cite the recorded findings each would make moot. Add one `iterative-plan-review` case where the scaffold's findings file is at the cap and the expected behavior is the hand-off.
- **Evidence:** E21 (no eval covers stepping back); V17 (a rubric line without a fixture tests nothing).
- **Standards:** Existing `evals/{skill}/` layout (`prompts`, `rubrics`, `scaffolds`, `tests.json`).
- **Details:** This fixture is the first measurement of whether the critic's alternatives earn their cost (see Remaining Risks).

### Deferred (YAGNI)

Each item was in an earlier draft and was cut. The trigger that reopens each is named.

- **Automatic trigger in `code-review`** (cluster and cross-run recurrence checks, `APPR-###` section, locked-premise clause). `code-review` is a single pass, not a loop, so there is no cap to trigger from. The skill is invocable by hand on a branch. Reopen if a fix-and-re-review cycle is observed often enough to want automation, and start from the cluster-before-demotion design in V14.
- **`tdd` recurrence trigger.** `tdd` iterates over build steps, not review rounds, and a stop would contradict its "runs to completion" contract (V16). Reopen if a `tdd` run is observed growing a test list on one unit without questioning the mechanism; the reopened form records a hand-off suggestion in the run summary.
- **`refactor` planning question ("would one substitution replace the list?").** The catalog already admits substitution (E13). Reopen on an observed run that applies many small steps where one substitute-algorithm step would do.
- **Round-two brief clause in `iterative-plan-review`** ("a finding naming the mechanism behind several resolved findings is not a re-raise"). Validation downgraded the brief to soft anchoring (V2). Reopen if a run shows a reviewer withholding such a finding.
- **A separate `n` for the trigger.** The size cap is the iteration count. Reopen if a project wants to reassess before its cap; the natural home is `.han/config.md`.
- **An automatic hand-off at the small cap** (lightweight `iterative-plan-review`, small `plan-implementation`). One pass cannot tell a plan stuck on its approach from a plan that needed edits, and "edge case" forces findings to major, so the trigger would fire on nearly every small run. Those runs end with a one-line pointer to the skill instead. Reopen as a recurrence trigger, not a cap trigger: the findings file persists between sessions, so a second small run over the same plan could hand off when the file already holds an earlier iteration that also failed to converge. Wait for a real case.
- **Shared `approach-reassessment-rule.md` in `han-core/references/`.** The skill is the canonical home now. Reopen only if a `han-coding` skill needs the definition without invoking the skill.
- **YAGNI rule Gate 2 clarification and evidence-rule edit.** Refuted as causes (V8, V9).
- **Agent edits (`junior-developer`, `adversarial-validator`).** The skill owns the question (V17).
- **Plugin-builder `workflow-patterns.md` technique.** Reopen once the skill has run and the pattern is proven, so the guidance records a technique that exists.
- **Stale cap comment at `review-iteration-history-template.md:67`.** Real drift, unrelated to this bug (V1). Fix separately.

## Evidence Summary

All items are trust class "codebase" unless the item says otherwise. Line numbers were checked against the files on disk during validation. Items marked "not causal" were checked and found not to contribute to the symptom; they stay so the audit trail is complete.

### E1: iterative-plan-review edits in place and may not generate a new plan

- **Source:** `han-planning/skills/iterative-plan-review/SKILL.md:4-8`
- **Finding:**
  ```
  Sharpens and stress-tests an existing plan file through multiple codebase-grounded review passes, editing it in place
  ... Also use it when the user asks to verify, validate, or confirm feasibility of an approach. ... does not generate
  new plans from scratch — use plan-a-feature for a new plan.
  ```
- **Relevance:** The skill is told to confirm feasibility of an approach, yet its only edit mode is in place and replacing the plan is out of scope.

### E2: The plan-review stop rule reads only the latest round, and "edge case" forces a finding to major

- **Source:** `han-planning/skills/iterative-plan-review/SKILL.md:229-230, 247-249, 352-355`
- **Finding:**
  ```
  Deterministic stop rule: stop iterating when the most recent iteration produced ≤ 2 new findings AND zero major
  findings (security, T#-contradiction, missing coordination, unhandled failure mode in a primary flow path). The size cap
  from Step 2 sets the upper bound: small = 1 iteration, medium = 2, large = 3. Never exceed the size cap.
  ```
  Line 229-230: "Force-up to major if the finding text contains keywords like ... "edge case" ... When in doubt, major."
- **Relevance:** Convergence means "the findings went quiet". A plan accumulating edge-case findings never passes "zero major", so it runs to the cap while patching (V11). The caps mean a six-round case spans re-invocations.

### E3: The plan-review finding record has no category or resolution for replacing the approach

- **Source:** `han-planning/skills/iterative-plan-review/references/review-findings-template.md:55-62`; `SKILL.md:319-325`
- **Finding:**
  ```
  - **Category:**
    <!-- assumption refuted / overlap / ambiguity / edge case / unhandled failure mode / standards conflict / mechanics leaking into spec (spec-aware mode only) -->
  ...
  - **Resolution:**
    <!-- What the skill did about it — the plan edit applied, the clarification captured, or why the finding was deferred -->
  ```
  Major findings are those that change "a behavioral commitment, edge-case rule, alternate flow, or failure mode in the plan"; minor are "typo, wording, naming, formatting, citation cleanup".
- **Relevance:** A "replace this mechanism" finding has to be filed as an edge case or refuted assumption, and its resolution is a section edit.

### E4: Round briefs ask for plan changes against the current layout, and round two passes a de-duplication summary

- **Source:** `han-planning/skills/iterative-plan-review/SKILL.md:282-284, 288-292, 295-296`
- **Finding:**
  ```
  Also pass the paths to `artifacts/review-findings.md` and `artifacts/review-iteration-history.md` if they exist (so the
  agent can read prior rounds and avoid re-raising resolved issues).
  ...
  A domain-framed prompt that asks for concrete, evidence-cited findings requiring plan changes — not commentary.
  Frame the question around the agent's role (e.g., for `han-core:structural-analyst`: "where does this plan's
  proposed module layout conflict with existing boundaries ...
  ...
  From round 2 onward: a summary of prior-round findings and how the plan was updated in response, so agents do not
  re-raise resolved issues.
  ```
- **Relevance:** The example question assumes the layout and asks where it conflicts, and the round-two summary is framed as settled. Validation read this as anchoring, not prohibition (V2): nothing forbids an approach finding, but nothing labels or invites one either.

### E5: In spec-aware mode the brief forbids library recommendations (not causal, see V3)

- **Source:** `han-planning/skills/iterative-plan-review/SKILL.md:305-313`
- **Finding:**
  ```
  Do **not** recommend specific libraries, language primitives, protocols, data structures, or file-level code changes
  — those belong to the implementation plan. ... Treat any `T#` entries in `feature-technical-notes.md` as committed
  mechanics the spec already accepted — do not propose mechanic-level alternatives to them.
  ```
- **Relevance:** A regex-versus-library choice is implementation-level and never sits in a behavioral spec, so this deliberate boundary does not touch the symptom. Kept so no one re-proposes loosening it.

### E6: Companion files persist across runs but are read only for ID uniqueness

- **Source:** `han-planning/skills/iterative-plan-review/SKILL.md:137-139`
- **Finding:**
  ```
  If any companion file already exists (prior review of the same plan), read it and append new `F#` / `R#` / `T#` entries
  continuing from the highest existing ID — do not overwrite.
  ```
- **Relevance:** The data to count rework per section exists on disk. No step reads it for that purpose.

### E7: The YAGNI sweep is the only drop-or-replace channel, and it runs per item

- **Source:** `han-planning/skills/iterative-plan-review/SKILL.md:44-48`
- **Finding:**
  ```
  Items that fail the evidence test or have a strictly simpler version available are first-class findings
  (`Category: YAGNI candidate`), not polish. Resolution paths: cite missing evidence and keep, replace with simpler
  version, or move to the plan's `## Deferred (YAGNI)` section
  ```
- **Relevance:** "Replace with simpler version" exists, but it asks each plan item for its evidence. It never asks whether the plan's mechanism is the right one.

### E8: code-review's calibration directive scopes findings to the diff

- **Source:** `han-coding/skills/code-review/references/agent-dispatch.md:59-76, 86-87`; `SKILL.md:112, 152`
- **Finding:**
  ```
  Raise a finding only when **at least one** of these holds:
  1. The change actively introduces or worsens the issue.
  2. The issue is critical irrespective of who introduced it ...
  Do **not** raise:
  - Theoretical concerns the change does not touch.
  - Pre-existing best-practice gaps the change did not make worse.
  ...
  When uncertain about severity, prefer the **lower** severity.
  ```
  Mode A, the review mode with full git context, diffs the branch against the default branch, so code from earlier fix rounds stays in the change.
- **Relevance:** On a branch re-review the parser is still "introduced by the change", so the directive does not block an approach finding (V5). What it does is frame every reviewer toward per-line defects; the missing piece is a cross-finding view, not a wider gate.

### E9: code-review's validator may only demote or drop findings

- **Source:** `han-coding/skills/code-review/references/finding-filters.md:7, 67-76`
- **Finding:**
  ```
  Neither pass is a finding source. Both only demote or drop
  ...
  Treat every finding as wrong until the code proves it right. ... Do not invent new findings — you are validating
  the list, not extending it.
  ```
- **Relevance:** The one adversarial pass in the pipeline can shrink the list and never add "the approach is wrong". The approach check therefore has to sit before it, in consolidation.

### E10: code-review's fix routes and checklist have no approach-level route

- **Source:** `han-coding/skills/code-review/references/template.md:46, 104-105`; `references/review-checklist.md:119-120`
- **Finding:**
  ```
  {test-first \| restructure \| by hand}
  ...
  **Fix:** {test-first (`/tdd`) | restructure (`/refactor`) | by hand}
  ```
  Checklist: "standard library functions over hand-rolled equivalents".
- **Relevance:** `restructure` presumes "the behavior is right and the shape is wrong". The only "hand-rolled" mention is a line-level style check pointing at the standard library.

### E11: code-review carries nothing across runs

- **Source:** `han-coding/skills/code-review/SKILL.md:90, 455-456`
- **Finding:**
  ```
  IDs are sequential within each category, starting at 001.
  ...
  **When a report already exists at that name, replace it** and record that you did
  ```
- **Relevance:** A fix-and-re-review cycle has no memory. The sixth run cannot know it is the sixth.

### E12: tdd's refactor step and list rules have no approach-level move

- **Source:** `han-coding/skills/tdd/SKILL.md:172-175, 230-244, 248-252`
- **Finding:**
  ```
  If every remaining item forces a big leap ... a simpler test is missing: add it to the list and pick it.
  ...
  Eliminate the duplication you just created. ... Apply YAGNI ...: remove duplication, do not add speculative
  abstraction. ... Change no behavior.
  ...
  If the open list has grown past roughly ten items, do not stop for input: flag it prominently as a scope warning,
  keep going
  ```
- **Relevance:** A growing list on one unit is treated as scope, and the only "stuck" heuristic adds a smaller test. `tdd` can run six cycles in one invocation, so if the six rounds were `tdd` cycles this is the loop to fix (see the open question).

### E13: refactor is behavior-preserving with a named catalog and the suite's only recurrence detector

- **Source:** `han-coding/skills/refactor/SKILL.md:42-54, 112, 147-149`; `references/refactoring-discipline.md:33-35`
- **Finding:**
  ```
  Each step is one named refactoring with a bounded mechanic (extract function, rename, move, inline, and so on)
  ...
  or two consecutive plan items have been reverted: stop, report where things stand ..., and let the user re-scope.
  ```
  Catalog: "extract function, inline function, rename, move function or field, extract variable, replace conditional with polymorphism, replace temp with query, and the rest of the catalog at refactoring.com/catalog."
- **Relevance:** Substituting a mechanism for a library preserves behavior and is in the catalog the skill cites, so an accepted approach finding has a route. The two-reverts stop is the suite's only recurrence detector.

### E14: plan-implementation's stop rule and spec-maturity gate

- **Source:** `han-planning/skills/plan-implementation/SKILL.md:320-323, 366-377`; `references/round-aggregation.md:38-46`
- **Finding:**
  ```
  The most recent round produced ≤ 2 new findings AND zero major findings ...
  ... If the team is still iterating at the cap, surface the remaining Open Questions to the user with
  recommendations and a note that the team has reached a facilitation plateau.
  ```
  Gate: "≥ 2 T#-contradictions raised by ≥ 2 distinct specialists" or "≥ 5 spec-level findings raised by ≥ 3 distinct specialists". "One specialist raising many findings also does not trip the gate." The junior-developer "reframe" is "restate the issue in plain language".
- **Relevance:** The only route back to the spec counts distinct specialists, which small teams cannot reach. "Reframe" means restating a question, not the approach. Deferred; no reported case.

### E15: design-an-api compares options once, before refinement

- **Source:** `han-coding/skills/design-an-api/SKILL.md:65-67`
- **Finding:**
  ```
  **Options before commitment.** The architect produces two or three real options with one recommendation, not a single
  design with alternatives invented afterward to justify it. The user picks before three further agent rounds are spent
  refining one.
  ```
- **Relevance:** This is the suite's one structural approach comparison. It is a one-time gate, and no loop revisits it when refinement stalls.

### E16: The YAGNI shape ladder and the refactor carve-out (not causal, see V8)

- **Source:** `han-core/references/yagni-rule.md:46-60, 143-144`
- **Finding:**
  ```
  A simpler version uses fewer files, fewer abstractions, fewer configuration surfaces, fewer code paths, fewer tests,
  fewer phases.
  ...
  An inline check beats a helper beats a middleware beats a framework.
  ...
  Refactor when the existing structure demonstrably impedes the change being made — that's evidence.
  ```
- **Relevance:** The ladder never mentions libraries, and "fewer code paths" can favor a parser library over a regex tangle. The carve-out already admits a replacement once rework is shown. The fix cites this clause rather than editing the rule.

### E17: The evidence rule's "continue with the current approach" clause (not causal, see V9)

- **Source:** `han-core/references/evidence-rule.md:50-52, 58-60`
- **Finding:**
  ```
  When codebase evidence and web evidence disagree, the codebase wins on what the system does today; add "continue with
  the current approach" as a named alternative.
  ```
- **Relevance:** The clause adds an option only when codebase and web evidence disagree, and the corroboration gate applies to web claims only. Rework counts in a findings file are codebase evidence, so no tilt applies.

### E18: The agents ask the "worth doing" question on every dispatch, but no category labels the answer

- **Source:** `han-core/agents/junior-developer.md:120-121, 131`; `han-core/agents/plan-synthesizer.md:119, 127`; `han-planning/agents/discussion-facilitator.md:108, 116`; `han-core/agents/adversarial-validator.md:65`; `han-planning/skills/iterative-plan-review/references/team-selection.md:8-11`
- **Finding:**
  ```
  - Why are we doing this _now_, as opposed to later, never, or differently?
  - What is the underlying problem, and is the artifact addressing the actual problem or a symptom of it?
  - What is the smallest version of this that is still valuable to ship?
  ```
  Team-selection seats `junior-developer` on every team and describes the validator as attacking "the plan's evidence, proposed approach, and assumptions". Plan-synthesizer and discussion-facilitator ask "whether the work is worth doing" once, at goal clarification in `plan-implementation`.
- **Relevance:** The question is asked every round in `iterative-plan-review` and `code-review`. Its answer has no category to land in, so it is filed as an ambiguity or an open question beside the edge cases and carries no priority over them (V10).

### E19: The authoring guidance defines iterative refinement as targeted fixes with a pass cap

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/workflow-patterns.md:140, 152`
- **Finding:**
  ```
  Maximum 3 refinement passes. If issues persist after 3 passes, present the current version with a note about remaining
  issues.
  ...
  - **Targeted refinement** — fix specific issues, don't regenerate everything
  ```
- **Relevance:** This is the pattern every loop was built from. It names no technique for reassessing at the cap.

### E20: Prior research named this failure and declined to act pending Han-specific evidence (trust class: web, via the repo's own report)

- **Source:** `docs/research/adhd-application-to-han.md:33, 92, 144-149, 228-235`
- **Finding:**
  ```
  The article (A1) names a failure mode it calls "premature convergence": large language models evaluate as they
  generate, defaulting to the first high-probability answer and polishing it rather than exploring the broader
  solution space. This diagnosis is independently corroborated from two different empirical directions (A4, A5).
  ```
  V6 of that report: "No evidence is cited that this architecture actually exhibits premature convergence in production output." Its recommendation: gather Han-specific evidence first (O4). A7, a single peer-reviewed study, found "no statistically significant improvement in frame novelty or usefulness when using LLMs for problem reframing" with human designers.
- **Relevance:** The problem diagnosis is corroborated. Your report is one Han-specific data point, from an unidentified workflow. A7 is a risk to this fix, not support for it: it says LLM-generated reframes may add little even when a person decides (V12).

### E21: No approach-questioning instruction ever existed, and no eval covers stepping back

- **Source:** `git log -S` over `han-planning/skills`, `han-coding/skills`, `han-core/agents` for "step back", "different approach", "alternative approach", "reassess", "rethink"; `evals/` grep for "approach|alternative|converge|reframe|step back|redesign"
- **Finding:** Zero commits for every term. The eval grep matched three unrelated rubric lines in `coding-standard`, `gap-analyzer`, and `test-engineer`. There are no evals for `tdd` or `refactor`.
- **Relevance:** The gap is original, not a regression, and a regression in either direction would not be caught. The eval claim rests on a keyword grep, not a full read.

### E22: The designed redirect is the pairing stop, which is off by default

- **Source:** `han-planning/skills/iterative-plan-review/SKILL.md:357-361`; `han-core/skills/pairing/SKILL.md:99-100, 129-139, 177-190`; `CHANGELOG.md:594-595`
- **Finding:**
  ```
  A redirect at such a stop does not consume a round against the cap, BECAUSE a round is a unit of review work and
  a redirect is not. Absent such a request, ...
  ```
  Pairing proposes an approach you can accept, change, or replace, asks first before choices expensive to walk back, and stops after every piece.
- **Relevance:** A person can redirect a loop under `/pairing`, including to a different approach (V7). The default run has no checkpoint. Pairing is the status-quo mitigation and the long-form docs will name it.

### E23: code-review's branch context passes reviewers the premises already locked in

- **Source:** `han-coding/skills/code-review/SKILL.md:171-173`
- **Finding:**
  ```
  **Summarize loaded content into a Branch Context block of at most 200 words** covering: scope of the change, deferred
  items the team named, premises the team has already locked in, focus areas the author called out.
  ```
- **Relevance:** If the locked premise is "use a regex", every reviewer is steered away from questioning it on every run. Found by validation (V6); the fix adds one clause so a locked premise stays subject to the approach check.

### E24: iterative-plan-review already has a between-rounds question channel with named candidates

- **Source:** `han-planning/skills/iterative-plan-review/SKILL.md:336-337, 364-367`
- **Finding:**
  ```
  Between rounds, surface to the user any finding where two agents disagree on substance, or where resolving the finding
  requires a judgment only the plan's author can make. Present each as a contextual question with impact, tradeoffs, and a
  recommended answer.
  ```
- **Relevance:** An approach finding is such a judgment. The fix routes it through this channel rather than adding a new stop register (V13).

## Validation Results

Two `han-core:adversarial-validator` agents ran in parallel, one against the evidence and root cause, one against the planned fix. Their findings are consolidated below.

### Counter-Evidence Investigated

#### V1: Citations are wrong or stale

- **Hypothesis:** Quoted lines do not match the files or omit nearby approach-reassessment text.
- **Investigation:** Both validators re-read `iterative-plan-review/SKILL.md` in full, `team-selection.md`, `tdd/SKILL.md`, `code-review/SKILL.md`, `agent-dispatch.md`, `finding-filters.md`, and `yagni-rule.md`, and spot-checked line numbers against `git log`.
- **Result:** Confirmed. Every quote and line number matched. No approach-reassessment instruction exists in the loop skills. The stale cap comment at `review-iteration-history-template.md:67` is real but unrelated to the bug.
- **Impact:** Supports the "no step for this" claim. The cap-comment fix moved to the deferred list.

#### V2: The round-two brief suppresses approach findings

- **Hypothesis:** "So agents do not re-raise resolved issues" bans a finding that the resolved approach is wrong.
- **Investigation:** `SKILL.md:282-296`; `team-selection.md:10-11`; `adversarial-validator.md:65`.
- **Result:** Partially Refuted. The summary is a de-duplication aid for resolved findings. `team-selection.md` licenses the validator to attack the "proposed approach". The brief anchors through its example question; it does not prohibit.
- **Impact:** "Active suppression" downgraded to framing in the root cause. The round-two clause in the fix stays because it is one sentence and labels the finding kind.

#### V3: The spec-aware library ban explains the parser case

- **Hypothesis:** E5 is causal.
- **Investigation:** `SKILL.md:80-120, 305-313`. Spec-aware mode engages only for a feature specification.
- **Result:** Refuted. A regex-versus-library choice is implementation-level and never sits in a behavioral spec.
- **Impact:** E5 marked not causal. The spec-aware carve-out removed from the fix.

#### V4: The six rounds did not come from a Han loop

- **Hypothesis:** No Han skill runs six review rounds in one invocation, so the workflow is unidentified.
- **Investigation:** Caps at `SKILL.md:162-166` (1, 2, 3); `code-review` has no loop; `tdd` has no cycle cap; `refactor` stops only on red, scope spread, or two reverts.
- **Result:** Partially Refuted. Only `tdd` and `refactor` can iterate six times in one run, and there the iterations are build steps. Six review rounds must be re-runs or a workflow outside Han.
- **Impact:** The Problem Statement now states the assumption (repeated `/code-review` runs) and asks you which workflow it was. The fix is scoped to the two review loops; `tdd` and `refactor` are deferred with triggers.

#### V5: The calibration directive blocks approach findings on re-review

- **Hypothesis:** A mechanism introduced in an earlier run falls outside "the change actively introduces".
- **Investigation:** `agent-dispatch.md:59-76`; `code-review/SKILL.md:112, 152` (Mode A diffs against the default branch).
- **Result:** Refuted for branch reviews. Earlier-round code stays in the diff, so the parser is "introduced" on every run.
- **Impact:** The third calibration trigger removed from the fix. E8's relevance rewritten: the gap is a missing cross-finding view, not a narrow gate.

#### V6: Branch context carries prior-run state

- **Hypothesis:** Step 1.5 already carries the previous review, so E11 overstates.
- **Investigation:** `code-review/SKILL.md:141-176`.
- **Result:** Partially Refuted. Step 1.5 loads the PR body, commits, and plan, not the prior report, so E11 holds. It also passes "premises the team has already locked in" to every agent, an anchoring channel the draft missed.
- **Impact:** Added as E23 and to the root cause. The fix adds one clause to Step 1.5.

#### V7: Pairing already covers this

- **Hypothesis:** `/pairing` provides the redirect, so no change is needed.
- **Investigation:** `pairing/SKILL.md:99-100, 129-139, 177-190`.
- **Result:** Partially Refuted. Pairing lets you replace the approach at any stop, so it is a real mitigation, but it is opt-in and the default run has no checkpoint.
- **Impact:** E22 rewritten. The long-form docs will name pairing as the manual alternative.

#### V8: The YAGNI ladder ranks a library below hand-written code

- **Hypothesis:** E16 is causal.
- **Investigation:** `yagni-rule.md:44-60, 137-146`; grep for "library", "dependency".
- **Result:** Largely Refuted. The ladder never mentions libraries. "Fewer code paths" can favor one, and the refactor carve-out already permits the move once rework is shown.
- **Impact:** The YAGNI and evidence tilt removed from the root cause. The `yagni-rule.md` edit, which would have reached six vendored copies, removed from the fix. The finding cites the existing carve-out instead.

#### V9: The evidence rule defaults to "continue with the current approach"

- **Hypothesis:** E17 is causal.
- **Investigation:** `evidence-rule.md:50-60`.
- **Result:** Refuted. The corroboration gate applies to web claims only, and the clause fires only on a codebase-versus-web disagreement. Rework counts are codebase evidence.
- **Impact:** E17 marked not causal. No evidence-rule change.

#### V10: The "worth doing" question dead-ends

- **Hypothesis:** E18's question is asked once and never reaches a change.
- **Investigation:** `junior-developer.md:118-132` (Protocol 1 runs on every dispatch); `team-selection.md:8-9`; `iterative-plan-review/SKILL.md:315-317, 364-367`.
- **Result:** Partially Refuted. In `iterative-plan-review` the answer can reach you as a contextual question and edit the plan. It arrives unlabeled, most likely as an ambiguity, and nothing prioritizes it.
- **Impact:** E18 rewritten. Added E24 for the existing question channel, which the fix now reuses.

#### V11: The latest-round stop rule causes quiet early convergence

- **Hypothesis:** The count falls when reviewers are told to stay quiet, and the loop stops early on the wrong approach.
- **Investigation:** `SKILL.md:229-230, 247-249, 323-325, 352-355`.
- **Result:** Partially Refuted. "Edge case" is a force-up-to-major keyword, so a plan accumulating edge cases never satisfies "zero major findings". The loop does not stop early; it runs to the cap while patching.
- **Impact:** Mechanism 2 reworded to "no memory", with the run-to-cap failure mode stated. The early-stop condition in the fix stays, because its purpose is to stop spending rounds on a unit whose approach is in question.

#### V12: Prior research supports stop-and-ask

- **Hypothesis:** E20's A7 finding justifies handing the reframe to the person.
- **Investigation:** `docs/research/adhd-application-to-han.md:13, 33, 63, 92, 144-149, 228-235`.
- **Result:** Partially Refuted. The "declined to act" reading is fair, and the diagnosis is corroborated by two independent sources, which the draft understated. A7 tested LLM-generated reframes for human deciders and found no gain, so it does not support the design; it is a risk to it.
- **Impact:** E20 rewritten with the corroboration and the correct trust label. A7 moved to Remaining Risks. The stop-and-ask design now rests on the collaborative-stop rule's "expensive to walk back" test, which that rule marks provisional.

#### V13: The stop's register mixes two rules

- **Hypothesis:** A stop in collaborative-stop order with named candidates mixes the pre-build ask (no candidates) and the operator-escalation rule (named candidates), and `han-coding` does not vendor the escalation rule.
- **Investigation:** `collaborative-stop-rule.md:77-98`; `operator-escalation-rule.md` consumer list.
- **Result:** Refuted as written.
- **Impact:** No new stop. `code-review` carries the alternatives in the report. `iterative-plan-review` uses its existing between-rounds question (E24), whose shape already includes a recommended answer.

#### V14: The code-review cluster trigger fires on the parser case

- **Hypothesis:** "Three or more findings of one category on one unit" fires on run one.
- **Investigation:** `code-review/SKILL.md:90-92, 202-212, 363-373`; `finding-filters.md:10-36`; `agent-dispatch.md:59-76`.
- **Result:** Refuted. Edge-case findings scatter across checklist categories, a parser diff is Small so Warnings and Suggestions are mostly dropped, and the reachability gate demotes hedged findings. A post-demotion, single-category count would miss the case.
- **Impact:** The check now counts raw findings per file across categories, before demotion, as a separate step.

#### V15: Cross-run recurrence is feasible as specified

- **Hypothesis:** The prior report is at the same name and its units can be matched.
- **Investigation:** `code-review/SKILL.md:435-461`.
- **Result:** Partially Refuted. Same branch gives the same name, and the file is replaced. Line numbers drift after fixes, the report holds only post-filter findings, and in Mode C, the review mode with no git available, the report name comes from the file list and changes with it.
- **Impact:** Match on file path only; degrade silently when no prior report exists, the slug differs, or the report does not parse.

#### V16: The tdd trigger fires on every normal run

- **Hypothesis:** "Three or more discovered scenarios on one unit" is a false-positive generator.
- **Investigation:** `tdd/SKILL.md:139-175, 230-252`; the runaway threshold is "roughly ten".
- **Result:** Confirmed. A parser built behavior-by-behavior discovers three scenarios routinely.
- **Impact:** The `tdd` change deferred. A stop there would also contradict the "runs to completion" contract at `tdd/SKILL.md:12-13` and the list of the only two blockers at `:102-108`.

#### V17: The fix is over-scoped under the YAGNI rule

- **Hypothesis:** Most planned changes fail Gate 1 on the report alone.
- **Investigation:** `yagni-rule.md` applied to each change; md5sums of the six vendored `yagni-rule.md` copies (identical); `test/` and `scripts/` searched for a vendored-copy sync check (none exists).
- **Result:** Confirmed. The report evidences review rounds over code. `tdd`, `refactor`, `plan-implementation`, the agent edits, the shared rule file, the YAGNI edit, the guidance edit, and the eval rubric lines have no reported case, and a rubric line without a fixture tests nothing.
- **Impact:** The fix cut to `code-review` and `iterative-plan-review`, with each cut item in Deferred (YAGNI) with its reopen trigger. The shared rule file is deferred to the Rule of Three.

#### V18: Literal-following models will always fire or never fire the trigger

- **Hypothesis:** Three OR-ed triggers with no gate end every run in an approach stop.
- **Investigation:** `per-model-authoring.md:25-31`; `collaborative-stop-rule.md:81-95` (the "a plan that marks every piece has misapplied the test" calibration).
- **Result:** Confirmed.
- **Impact:** Cluster and recurrence now only prompt the check. A finding is emitted only when the check names an alternative that makes the clustered findings moot. A calibration clause says an approach finding is expected on a minority of files, and the run reports when every file flags or none does.

#### V19: The `rethink` route misroutes

- **Hypothesis:** Routing to `/plan-a-change` or `/design-an-api` points at skills whose descriptions exclude a mechanism swap, and a re-run would re-flag the same unit.
- **Investigation:** `plan-a-change/SKILL.md:3-9`; `design-an-api/SKILL.md:65-67`; `scope-justification-rule.md`; `contract-pinning-rule.md`.
- **Result:** Partially Refuted. No mechanical loop, but a misroute.
- **Impact:** The fix-route enum is unchanged. Approach findings carry no route, like YAGNI findings. `finding-content.md` states once that an accepted behavior-preserving substitution goes to `/refactor` and a behavior change to `/tdd`.

#### V20: Convention pieces are missing

- **Hypothesis:** A required convention is left out.
- **Investigation:** CLAUDE.md shared-rule lists; `marketplace.json`; `docs/workflows.md`; `output-verification.md:61-64`; `template.md:33` (ID prefixes).
- **Result:** Partially Refuted. With no shared rule file, the CLAUDE.md and vendoring items fall away. The approach finding needed an ID prefix, a section, and a verification rule.
- **Impact:** `APPR-###` prefix, a `### 🔁 Approach` section mirroring the YAGNI section, and a verification rule mirroring rule 12 added to the fix.

#### V21: Your redirect: a dedicated skill with a non-convergence trigger

- **Hypothesis:** A skill invoked when a loop fails to converge after its cap is a better shape than inline checks in each loop.
- **Investigation:** Your direction after the first plan, checked against the entity taxonomy (`plugin-entity-taxonomy.md`), `design-an-api`'s options step (E15), the `plan-implementation` plateau note (E14), and the prior research's branch-isolation finding (E20). You also noted that `han-coding` skills do not run review loops.
- **Result:** Confirmed. A skill gives the check a fresh context, one canonical home, its own eval, and a hand-invoked path for cycles that happen outside any loop. The cap is an existing deterministic boundary, so the trigger adds no threshold and no stop.
- **Impact:** The fix was rebuilt around `reassess-approach`. The `code-review` changes moved to the deferred list.

### Adjustments Made

- Root cause rewritten from four mechanisms to three; "active suppression" became "find-and-fix framing" (V2, V5) and the YAGNI/evidence tilt was removed (V8, V9).
- E5, E16, E17 marked not causal; E8, E18, E20, E22 rewritten; E23 and E24 added (V3, V5, V6, V7, V10, V12).
- First fix cut from five loops, a shared rule, six vendored YAGNI edits, two agents, guidance, and evals to two loops plus docs (V4, V16, V17).
- Stop design replaced: no new stop register (V13, V19). A named-alternative gate and a calibration clause were added to the inline checks (V18), then superseded.
- Second fix rebuilt around a dedicated `reassess-approach` skill in `han-planning`, triggered at the round cap when the convergence condition fails, invoked by `iterative-plan-review` and `plan-implementation` only, and invocable by hand (V21). The `code-review` cluster and recurrence checks, the `APPR-###` section, and the locked-premise clause moved to Deferred.
- An eval fixture for the new skill added, so the mechanism's value is measured rather than assumed (V17, V18).

### Confidence Assessment

- **Confidence:** Medium.
- **Remaining Risks:**
  - The value of LLM-generated alternatives is unvalidated. A7 in the prior research (E20) found no gain from LLM reframing even with a person deciding. The eval fixture is the first measurement; if the options come back as nearby variants of the current approach, the critic brief or the agent choice needs rework.
  - The six-round case came from a hand-driven fix-and-re-review instruction, not a Han loop, so the automatic trigger never fires for it. Only the hand-invoked path helps until a skill exists that drives a merge request to completion and can call `reassess-approach` at its own stall point.
  - Firing only at the cap means a small plan gets one round before the question is asked, and a large plan gets three rounds of polishing first. That is the trade for a trigger with no new threshold.
  - The recommended agent, `han-core:software-architect`, is an intra-codebase architect. For a plan whose question is "should this exist at all", a generalist may produce better options. The `skill-builder` interview decides; the plan records the recommendation, not the decision.
  - First-answer anchoring is model behavior; a fresh context reduces it and does not remove it.
  - `plan-implementation` routing after an accepted alternative (back to `plan-a-feature` or on to `plan-a-change`) is a hand-off, not an automated step, and the person has to run it.

## Coding Standards Reference

| Standard | Source | Applies To |
| --- | --- | --- |
| Every new skill is built with `han-plugin-builder` (`skill-builder` for a skill) and reviewed against its guidance | `CLAUDE.md`, "Creating skills, agents, or other plugin aspects" | `reassess-approach` SKILL.md |
| Skill = deterministic flowchart; agent = contextual judgment; dispatch flows from skills to agents | `han-plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md` | `reassess-approach` design (gather, dispatch, record, present) |
| Model-agnostic instructions: goal and reasons first, load-bearing constraints explicit, no micro-checklist | `han-plugin-builder/skills/guidance/references/per-model-authoring.md` | all SKILL.md edits |
| Constraints carry their reasoning; conventions are heading, one-line rule, example | `.../skill-building-guidance/writing-effective-instructions.md` | all SKILL.md edits |
| Config probe runs `han-config-dir.sh`; grant copied from an existing skill | `.../skill-building-guidance/context-injection-commands.md`; `CONTRIBUTING.md` "Adding a skill" step 2 | `reassess-approach` frontmatter |
| Every skill gets a long-form doc, a README scent line, and an index entry in the same change | `docs/templates/coverage-rule.md`; `CONTRIBUTING.md` steps 3 to 5 | docs changes |
| One question per turn, plain-language lead, named candidates, single stop | `han-planning/references/operator-escalation-rule.md` | how both loops present the options |
| The collaborative flag adds no new boundary | `han-core/references/collaborative-stop-rule.md` | trigger placement at the existing cap |
| YAGNI: evidence gate and simpler-version gate; deferrals carry a reopen trigger | `han-core/references/yagni-rule.md` | the critic brief and the Deferred list |
| Readability standard applied in stages; editor pass for synthesis output | `han-communication/references/readability-rule.md` | the options report and the docs |
