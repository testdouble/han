# Feature Implementation Plan: Code-Review Skill Guardrails

This plan implements the four-symptom calibration fix to the `/code-review` skill. The implementation posture is **a single feature branch landing the changes in three sequenced commits (one per atomic pair)**, validated against three real PR bundles and shipped as a minor version bump.

## Source Specification

- **Feature specification:** [investigation.md](investigation.md). The investigation document acts as the source specification for this branch. It commits S1 through S13 with file locations and the C# causes each solution addresses.
- **Specification decision log:** none. No prior `plan-a-feature` decision log exists for this work; the investigation captures its own adversarial-validation findings (V1 through V9) inside the same document.
- **Specification team findings:** none. No prior `plan-a-feature` team-findings file exists.
- **Specification decisions this plan inherits:** S1 through S13 from `investigation.md` (recorded as trivial decisions D-19, D-20, D-21 in the [decision log](artifacts/implementation-decision-log.md) and as work units in Decomposition and Sequencing below).
- **Specification open items this plan must respect or resolve:** none. The investigation's "What the investigation does not cover" section names three deferred topics (test plan, cross-project validation, implementation sequence). All three are resolved in this plan: the test plan lives in Testing Strategy, cross-project validation is captured as test TP-17, and the implementation sequence is captured in Decomposition and Sequencing.

## Outcome

When this plan is executed, `/code-review` no longer requires a second-pass reclassification run to produce calibrated output. The first pass produces ≤ 4 warnings on PR 299 (matching the second-pass result), 1 warning and 1 YAGNI question on PR 307, and 1 critical plus at most 1 warning on PR 339, with internal detection of the WARN-002/WARN-003 contradiction. User-provided focus areas and branch-level context (PR description, planning artifacts, commit messages) reach every sub-agent. `plugin/.claude-plugin/plugin.json` reports version 2.3.0 and `CHANGELOG.md` records the calibration changes.

## Context

- **Driving constraint:** the user has been running a manual second-pass reclassification on every `/code-review` invocation, with explicit mode flags ("WARN-justified, SUGG suppressed per reviewer instruction"), because the first-pass default behavior produces severity inflation. The workaround is dated, documented, and unsustainable; the fix needs to land at the skill level ([D-1](artifacts/implementation-decision-log.md#d-1-step-33-is-the-authoritative-home-for-size-based-demotion)).
- **Stakeholders:**
  - The single primary user who invokes `/code-review` and the derivative `/gh-pr-review` skill. Success looks like the first pass producing the calibrated output the second pass currently produces.
  - Future operators of any project that adopts the `han` plugin. Success looks like the calibration rules holding across projects, not just the one project that supplied the three PR bundles (validated by TP-17).
  - Maintainers of the four agents that dispatch from skills other than `/code-review` (gap-analysis, plan-implementation, plan-a-feature, investigate). Success looks like the agent definitions remaining unchanged, with `/code-review`'s tailoring carried in its own dispatcher prompts ([D-4](artifacts/implementation-decision-log.md#d-4-s3-and-s4-ship-as-step-35-dispatcher-directives-not-as-edits-to-the-four-agent-definition-files)).
- **Future-state concern:** the merged Step 7.2 reachability phrase-match gate ([D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate)) depends on agents continuing to use the listed phrases in their finding rationale. If agent prompts evolve to suppress these phrases, the gate stops firing. Watch for this drift in post-ship validation runs.
- **Out-of-scope boundary:**
  - No edits to the four affected agent definition files. The agents remain general-purpose for callers other than `/code-review` ([D-4](artifacts/implementation-decision-log.md#d-4-s3-and-s4-ship-as-step-35-dispatcher-directives-not-as-edits-to-the-four-agent-definition-files)).
  - No automated test harness. The test plan is manual and uses the three existing PR bundles as fixtures (see Testing Strategy and the Deferred section).
  - No cross-file semantic contradiction detection in S8; only overlapping line ranges in a single file are checked ([D-12](artifacts/implementation-decision-log.md#d-12-s8-runs-an-extraction-pass-before-pair-comparison-scoped-to-overlapping-line-ranges-only)).
  - No structured "directly introduced" field added to agent output formats; phrase-matching is the implementation ([D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate)).
  - No S12 mode flag for default SUGG suppression; the rubric and Step 7 gate subsume it ([D-16](artifacts/implementation-decision-log.md#d-16-defer-s12-default-suppression-for-small-changes-as-yagni)).

## Team Composition and Participation

| Specialist | Status | Key Input |
|------------|--------|-----------|
| `project-manager` | Coordinator | Facilitated R1 with four specialists in parallel; resolved eight Open Questions via evidence, reframing, and reasonable-call defaults; synthesized this plan. |
| `software-architect` | Active | SA-1 through SA-6: established Step 3.3 as the authoritative home (D-1), specified Step 7 sub-step structure (D-2), scoped S3/S4 as dispatcher directives (D-4), defined atomic shipping pairs (D-5), and flagged S12 as YAGNI candidate (D-16). |
| `behavioral-analyst` | Active | BA-1 through BA-9: defined named bindings (D-14), specified S6 fail-open warning (D-9) and planning-directory lookup (D-10), supplied the reachability phrase list for the merged Step 7.2 gate (D-3), and defined the S8 extraction pass (D-12). |
| `test-engineer` | Active | TP-1 through TP-21: produced the P0/P1/P2 manual test catalog (covered in Testing Strategy); deferred automated harness, per-agent unit tests, and Mode C standalone tests as YAGNI. |
| `junior-developer` | Reframer | JD-001 through JD-015: surfaced docs-mirror scope (D-7), version-bump scope (D-6), the `allowed-tools` frontmatter gap (D-8), the three-location S7 rewrite (D-11), the narrower S4 wording for `edge-case-explorer` (D-18), the em-dash strip policy (D-17), the architectural-file-read requirement in S9 (D-13), and the reframing that resolved OQ-3 and OQ-7. |
| `adversarial-validator` | Stood down | Investigation already includes V1 through V9 adversarial findings; no further validation pass needed at plan stage. |
| `devops-engineer` | Not engaged | Plugin is markdown-only; no observability, SLO, or rollout surface ([Operational Readiness](#operational-readiness) is thin). |
| `adversarial-security-analyst` | Not engaged | No auth, PII, IO, or supply-chain surface in markdown skill edits. |
| `user-experience-designer` | Not engaged | No user-facing UX surface; the skill is a CLI-invoked plugin. |

Full round-by-round detail lives in [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md).

## Implementation Approach

### Architecture and Integration Points

The plugin is markdown-only, distributed via the Test Double marketplace, with no runtime or build step. "Implementation" means edits to Markdown skill bodies, reference files, and operator docs. Eight plugin files and five operator docs are touched.

**Plugin surface:**
- `plugin/skills/code-review/SKILL.md`, primary skill body. Receives edits at: frontmatter `allowed-tools` (add `Bash(gh *)`, [D-8](artifacts/implementation-decision-log.md#d-8-add-bashgh--to-skillmd-allowed-tools-frontmatter)); Review Constraints line 24 (rewrite to size-aware per S13); Step 1 (record `$focus_areas` binding, [D-14](artifacts/implementation-decision-log.md#d-14-focus_areas-and-branch_context-are-explicit-named-bindings-populated-by-steps-1-and-15)); Step 1.5 (new, S6 with [D-9](artifacts/implementation-decision-log.md#d-9-s6-fail-open-behavior-prints-a-visible-warning-when-no-pr-or-branch-context-loads) fail-open and [D-10](artifacts/implementation-decision-log.md#d-10-s6-planning-directory-lookup-uses-a-structured-claudemd-key-with-glob-fallback) planning lookup); Step 3.1 (size detection, the authoritative `{size}` write per [D-15](artifacts/implementation-decision-log.md#d-15-size-value-is-read-from-step-31-all-five-consumer-sites-reference-step-31-explicitly)); Step 3.3 (calibration directive becomes the authoritative home per [D-1](artifacts/implementation-decision-log.md#d-1-step-33-is-the-authoritative-home-for-size-based-demotion); also receives the rewritten YAGNI two-pass procedure per [D-11](artifacts/implementation-decision-log.md#d-11-s7-updates-three-yagni-bearing-locations-in-skillmd-not-two)); Step 3.5 (add `$focus_areas` and `$branch_context` blocks per S5, plus the dispatcher directives for S3 and S4 per [D-4](artifacts/implementation-decision-log.md#d-4-s3-and-s4-ship-as-step-35-dispatcher-directives-not-as-edits-to-the-four-agent-definition-files) and [D-18](artifacts/implementation-decision-log.md#d-18-s4s-constraint-is-narrower-for-edge-case-explorer-than-for-junior-developer)); Step 4 (Mode B/C scope note per S11); Step 5 (premise-verification per [D-13](artifacts/implementation-decision-log.md#d-13-s9-requires-reading-at-least-one-architectural-file-before-raising-a-violates-standard-x-finding)); Step 7 (three-sub-step rewrite per [D-2](artifacts/implementation-decision-log.md#d-2-step-7-takes-a-numbered-sub-step-structure-71-read-72-merged-demote-73-rubric) with merged 7.2 gate per [D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate)); Step 9 (S8 self-consistency check with extraction pass per [D-12](artifacts/implementation-decision-log.md#d-12-s8-runs-an-extraction-pass-before-pair-comparison-scoped-to-overlapping-line-ranges-only)).
- `plugin/skills/code-review/references/agent-finding-classification.md`, rubric. Receives the size-aware rewrite per S1 / [D-19](artifacts/implementation-decision-log.md#trivial-decisions) across seven sections that currently read "Most findings land here."
- `plugin/skills/code-review/references/review-checklist.md`, receives the two-pass YAGNI rewrite per S7 / [D-11](artifacts/implementation-decision-log.md#d-11-s7-updates-three-yagni-bearing-locations-in-skillmd-not-two).
- `plugin/.claude-plugin/plugin.json`, version bump from 2.2.0 to 2.3.0 per [D-6](artifacts/implementation-decision-log.md#d-6-version-bump-is-minor-220--230).
- `CHANGELOG.md`, new `## 2.3.0` entry per [D-6](artifacts/implementation-decision-log.md#d-6-version-bump-is-minor-220--230).

**Docs surface** (per [D-7](artifacts/implementation-decision-log.md#d-7-long-form-docs-mirror-updates-are-in-scope)):
- `docs/skills/code-review.md`, full mirror of the skill behavior changes.
- `docs/agents/structural-analyst.md`, `docs/agents/behavioral-analyst.md`, `docs/agents/junior-developer.md`, `docs/agents/edge-case-explorer.md`, one-paragraph note each, explaining that `/code-review` now tailors dispatch via Step 3.5 directives; the agent's default behavior outside `/code-review` is unchanged.

**Files explicitly not touched:**
- `plugin/agents/structural-analyst.md`, `plugin/agents/behavioral-analyst.md`, `plugin/agents/junior-developer.md`, `plugin/agents/edge-case-explorer.md`, agent definitions remain as-is per [D-4](artifacts/implementation-decision-log.md#d-4-s3-and-s4-ship-as-step-35-dispatcher-directives-not-as-edits-to-the-four-agent-definition-files).
- `plugin/skills/code-review/references/template.md`, no change required.
- The `/gh-pr-review` skill, depends transitively on `/code-review` output and inherits the behavior change.

### Data Model and Persistence

Not applicable. The plugin is markdown-only with no persistent data and no schema.

### Runtime Behavior

The new control flow inside `/code-review`:

1. **Step 1: Detect review context.** Reads invocation arguments; binds `$focus_areas` from the user's free-form argument string (defaults to `none provided` when empty, [D-14](artifacts/implementation-decision-log.md#d-14-focus_areas-and-branch_context-are-explicit-named-bindings-populated-by-steps-1-and-15)).
2. **Step 1.5: Load branch context.** New. Attempts to load PR description (via `gh pr view`, requiring [D-8](artifacts/implementation-decision-log.md#d-8-add-bashgh--to-skillmd-allowed-tools-frontmatter)), local `pr-body` file, commit messages since the default branch, and an implementation plan from the planning directory (looked up via the structured CLAUDE.md key with Glob fallback, [D-10](artifacts/implementation-decision-log.md#d-10-s6-planning-directory-lookup-uses-a-structured-claudemd-key-with-glob-fallback)). Summarizes loaded content into a Branch Context block of at most 200 words and binds it to `$branch_context`. When nothing loads, prints the visible warning per [D-9](artifacts/implementation-decision-log.md#d-9-s6-fail-open-behavior-prints-a-visible-warning-when-no-pr-or-branch-context-loads) and binds `$branch_context` to `none provided`.
3. **Step 3.1: Detect change size.** Existing step; this is the authoritative write point for `{size}` per [D-15](artifacts/implementation-decision-log.md#d-15-size-value-is-read-from-step-31-all-five-consumer-sites-reference-step-31-explicitly). Every later consumer references Step 3.1 by name.
4. **Step 3.3: Calibration directive.** Rewritten as the authoritative home for size-based demotion per [D-1](artifacts/implementation-decision-log.md#d-1-step-33-is-the-authoritative-home-for-size-based-demotion). Contains: the size-based demotion rules (Small omits Suggestions, Medium demotes non-directly-introduced findings, Large keeps the rubric); the merged reachability phrase list referenced by Step 7.2; the two-pass YAGNI procedure (evidence test, then anti-pattern check) referenced by `review-checklist.md` per [D-11](artifacts/implementation-decision-log.md#d-11-s7-updates-three-yagni-bearing-locations-in-skillmd-not-two).
5. **Step 3.5: Dispatch agents.** Every agent prompt template gains two named blocks: `**Focus areas from the user.** $focus_areas.` and `**PR / branch context.** $branch_context.` Per [D-4](artifacts/implementation-decision-log.md#d-4-s3-and-s4-ship-as-step-35-dispatcher-directives-not-as-edits-to-the-four-agent-definition-files), the dispatch prompts for `structural-analyst` and `behavioral-analyst` add a default-severity-to-SUGG calibration line (S3 form); the dispatch prompts for `junior-developer` and `edge-case-explorer` add the file-list scoping line, with the narrower wording for `edge-case-explorer` per [D-18](artifacts/implementation-decision-log.md#d-18-s4s-constraint-is-narrower-for-edge-case-explorer-than-for-junior-developer).
6. **Step 4: Manual file-by-file review.** Receives the Mode B / Mode C scope note per S11.
7. **Step 5: Documentation compliance.** Before raising any "violates standard X" finding, reads at least one architectural file demonstrating the standard's premise per [D-13](artifacts/implementation-decision-log.md#d-13-s9-requires-reading-at-least-one-architectural-file-before-raising-a-violates-standard-x-finding). When the file read does not confirm the premise, logs "premise not verified; finding omitted" and proceeds.
8. **Step 7: Classify agent output.** Restructured into three numbered sub-steps per [D-2](artifacts/implementation-decision-log.md#d-2-step-7-takes-a-numbered-sub-step-structure-71-read-72-merged-demote-73-rubric):
    - 7.1 Read agent output files.
    - 7.2 Apply the merged reachability-phrase-match demotion gate. For each finding, scan the rationale text for any of the documented phrases (`theoretical`, `hypothetical`, `defense-in-depth`, `effectively impossible`, `in case the upstream`, `could happen`, `should never happen`, `edge case that does not occur`). Demote one severity on match; omit when SUGG would demote ([D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate)).
    - 7.3 Apply the size-aware rubric from `agent-finding-classification.md` ([D-19](artifacts/implementation-decision-log.md#trivial-decisions) / S1), reading `{size}` from Step 3.1.
9. **Step 9: Verification.** Adds the S8 self-consistency check per [D-12](artifacts/implementation-decision-log.md#d-12-s8-runs-an-extraction-pass-before-pair-comparison-scoped-to-overlapping-line-ranges-only): extraction pass produces `{task-id, file-path, line-range, recommended-action-summary}` tuples, then a comparison pass flags overlapping-line-range pairs with contradictory recommended actions, demoting both and adding `Tension with {other-task-id}:` notes.

### External Interfaces

Not applicable. The plugin has no APIs, events, queues, or third-party integrations beyond the existing `gh` CLI dependency added by S6 ([D-8](artifacts/implementation-decision-log.md#d-8-add-bashgh--to-skillmd-allowed-tools-frontmatter)). The `gh` dependency is a tool grant in the skill frontmatter, not a network or service integration.

## Decomposition and Sequencing

Work units are grouped into the three atomic pairs from [D-5](artifacts/implementation-decision-log.md#d-5-atomic-shipping-pairs-and-sequencing), then additive guardrails, then docs and version bump. Each unit ships as one commit. The pair groupings are load-bearing: shipping a pair half is a known regression.

| # | Work Unit | Delivers | Depends On | Verification |
|---|-----------|----------|------------|--------------|
| 1 | **Pair A: calibrate severity baseline.** Rewrite `agent-finding-classification.md` per S1 ([D-19](artifacts/implementation-decision-log.md#trivial-decisions)) and SKILL.md line 24 per S13. Establish Step 3.3 as authoritative home ([D-1](artifacts/implementation-decision-log.md#d-1-step-33-is-the-authoritative-home-for-size-based-demotion)). Add the `{size}` cross-reference to Step 3.1 ([D-15](artifacts/implementation-decision-log.md#d-15-size-value-is-read-from-step-31-all-five-consumer-sites-reference-step-31-explicitly)). | Size-aware rubric for agent findings; size-aware Review Constraints rule for manual findings. | none | TP-3 (PR 307 1 WARN + 1 YAGNI on rerun); TP-7 (S1 size-aware rubric); TP-21 (caps and template preservation). |
| 2 | **Pair B: merged demotion gate.** Restructure Step 7 into 7.1/7.2/7.3 sub-steps ([D-2](artifacts/implementation-decision-log.md#d-2-step-7-takes-a-numbered-sub-step-structure-71-read-72-merged-demote-73-rubric)). Insert the merged S2+S10 reachability phrase-match gate at 7.2 ([D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate)). | First-pass severity output matches second-pass output for PR 299. | Pair A (rubric must be size-aware before Step 7.3 calls it). | TP-1 (PR 299 ≤ 4 WARN on rerun); TP-8 (no double-demotion between 7.2 and 7.3); TP-15 (reachability demotion fires on phrase list). |
| 3 | **Pair C: context plumbing and dispatcher directives.** Add `$focus_areas` and `$branch_context` named bindings ([D-14](artifacts/implementation-decision-log.md#d-14-focus_areas-and-branch_context-are-explicit-named-bindings-populated-by-steps-1-and-15)). Add Step 1.5 with the S6 loader ([D-9](artifacts/implementation-decision-log.md#d-9-s6-fail-open-behavior-prints-a-visible-warning-when-no-pr-or-branch-context-loads), [D-10](artifacts/implementation-decision-log.md#d-10-s6-planning-directory-lookup-uses-a-structured-claudemd-key-with-glob-fallback)). Add `Bash(gh *)` to `allowed-tools` ([D-8](artifacts/implementation-decision-log.md#d-8-add-bashgh--to-skillmd-allowed-tools-frontmatter)). Add the focus-area and branch-context blocks to every Step 3.5 prompt template ([D-20](artifacts/implementation-decision-log.md#trivial-decisions) / S5). Add the dispatcher directives for S3 (default SUGG for structural/behavioral) and S4 (file-list scoping with [D-18](artifacts/implementation-decision-log.md#d-18-s4s-constraint-is-narrower-for-edge-case-explorer-than-for-junior-developer) narrower wording for edge-case-explorer) per [D-4](artifacts/implementation-decision-log.md#d-4-s3-and-s4-ship-as-step-35-dispatcher-directives-not-as-edits-to-the-four-agent-definition-files). | User-provided focus areas and branch-level context reach every sub-agent; `structural-analyst` and `behavioral-analyst` default to SUGG output; `junior-developer` and `edge-case-explorer` constrain findings to the scoped file list. | Pair A (S3 has no observable effect until S1's rubric is size-aware per BA-7). | TP-2 (PR 299 Sentry deferred item not re-raised); TP-5 (focus areas in agent prompts); TP-6 (branch context block populates); TP-11 (S3 default SUGG); TP-12 (S4 file-list scope). |
| 4 | **S7 two-pass YAGNI.** Rewrite the YAGNI section in `review-checklist.md`, Step 3.3 calibration directive, and SKILL.md Review Constraints section (lines 29–41) per [D-11](artifacts/implementation-decision-log.md#d-11-s7-updates-three-yagni-bearing-locations-in-skillmd-not-two). | YAGNI runs evidence test first, then anti-pattern check, at all three sites. | Pair A (Review Constraints rewrite must align with the size-aware rule landed in Pair A). | TP-13 (S7 two-pass YAGNI); TP-20 (YAGNI verbatim opening preserved). |
| 5 | **S8 self-consistency check.** Add the S9-step extraction pass and the overlapping-line-range comparison pass per [D-12](artifacts/implementation-decision-log.md#d-12-s8-runs-an-extraction-pass-before-pair-comparison-scoped-to-overlapping-line-ranges-only). | Internal detection of contradictory same-file findings. | Pair B (the demotion gate must fire first; otherwise S8 sees pre-demotion severities). | TP-4 (PR 339 1 CRIT + contradiction detected); TP-14 (S8 tension notes emitted). |
| 6 | **S9 premise verification.** Add the architectural-file-read requirement to Step 5 per [D-13](artifacts/implementation-decision-log.md#d-13-s9-requires-reading-at-least-one-architectural-file-before-raising-a-violates-standard-x-finding). | Standards-compliance findings only raised when an architectural file confirms the standard's premise. | none | TP-9 (S9 premise verification). |
| 7 | **S11 Mode B/C scope note.** Add the Mode B / Mode C scope-limitation note to Step 4 per [D-21](artifacts/implementation-decision-log.md#trivial-decisions). | YAGNI skipped in Mode B and Mode C unless requested. | none | TP-16 (Mode B/C YAGNI skip). |
| 8 | **Docs sync.** Update `docs/skills/code-review.md` and the four `docs/agents/*.md` files per [D-7](artifacts/implementation-decision-log.md#d-7-long-form-docs-mirror-updates-are-in-scope). Apply the em-dash strip policy per [D-17](artifacts/implementation-decision-log.md#d-17-em-dash-strip-policy-on-verbatim-copy-from-the-investigation). | Operator-facing docs match shipped plugin behavior. | Pairs A, B, C, plus units 4 through 7 (the docs describe the final behavior). | Visual review against the final SKILL.md and against `docs/writing-voice.md`. |
| 9 | **Version bump and CHANGELOG.** Bump `plugin/.claude-plugin/plugin.json` from 2.2.0 to 2.3.0 ([D-6](artifacts/implementation-decision-log.md#d-6-version-bump-is-minor-220--230)). Add `## 2.3.0` entry to `CHANGELOG.md` summarizing the four calibration changes, docs sync, and deferred items. | Released artifact under 2.3.0. | All previous units. | Spot-check the CHANGELOG entry matches the actual edits. |

## RAID Log

### Risks

| ID | Risk | Likelihood | Severity | Blast Radius | Reversibility | Owner | Mitigation |
|----|------|------------|----------|--------------|---------------|-------|------------|
| R1 | The phrase-match gate at Step 7.2 ([D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate)) misses real reachability cases that a structured "directly introduced" field would have caught. | Medium | Medium | `/code-review` and `/gh-pr-review` outputs. | Reversible by widening the phrase list or adding the structured field. | `behavioral-analyst` | Post-ship validation on PR 299, 307, 339; reopen-trigger documented in [D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate). |
| R2 | Calibration mechanisms validated only on one project (gearjot-v2-web). Cross-project failure modes possible. | Medium | Medium | All users of `/code-review`. | Reversible by adjusting Step 3.3 rules. | `project-manager` | TP-17 (cross-project validation on a different project's PR) is a P2 test that gates a confidence upgrade, not the initial ship. |
| R3 | `Bash(gh *)` not present in some user environments. S6's loader fails to retrieve PR descriptions. | High | Low | Mode A users without `gh` installed. | Already mitigated by D-9's fail-open warning. | `behavioral-analyst` | [D-9](artifacts/implementation-decision-log.md#d-9-s6-fail-open-behavior-prints-a-visible-warning-when-no-pr-or-branch-context-loads) prints visible warning and proceeds. |
| R4 | Agents stop using the phrases in the Step 7.2 list as their prompts evolve. The gate stops firing without anyone noticing. | Low | Medium | Severity inflation regresses silently. | Reversible by re-tuning the phrase list. | `behavioral-analyst` | Captured as the Future-state concern in Context; post-ship validation rounds should spot-check the phrase distribution in agent output. |

### Assumptions

| ID | Assumption | What Changes If Wrong | Verifier | Status |
|----|------------|-----------------------|----------|--------|
| A1 | The reachability phrase list ([D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate)) covers the PR 299, 307, 339 demotion targets. | Some demotion targets remain at WARN on rerun. | TP-1, TP-3, TP-4 acceptance runs. | Unverified pending unit-2 completion. |
| A2 | The structured CLAUDE.md key `plans:` or `planning:` under `## Project Discovery` ([D-10](artifacts/implementation-decision-log.md#d-10-s6-planning-directory-lookup-uses-a-structured-claudemd-key-with-glob-fallback)) is a convention this repo and at least one other project will adopt. | Glob fallback carries more weight than expected. | Cross-project validation (TP-17). | Unverified. |
| A3 | The five docs mirror updates are within the scope of one commit's-worth of writing time, after the plugin edits land. | Unit 8 takes longer than budgeted. | Spot-check after unit 7 completes. | Unverified. |
| A4 | The PR bundles in `tmp/gearjot-v2-web-pr-{299,307,339}/` remain accessible during validation runs and are not modified between units. | Tests run against shifted ground truth. | Visual check before each rerun. | Verified at synthesis. |

### Issues

| ID | Issue | Owner | Next Step |
|----|-------|-------|-----------|
| (none open at synthesis) | n/a | n/a | n/a |

### Dependencies

| ID | Dependency | Owner | Status |
|----|------------|-------|--------|
| Dep1 | `gh` CLI installed in user environment for S6's PR-description load. | User environment. | Optional dependency mitigated by [D-9](artifacts/implementation-decision-log.md#d-9-s6-fail-open-behavior-prints-a-visible-warning-when-no-pr-or-branch-context-loads) fail-open. |
| Dep2 | The three `tmp/gearjot-v2-web-pr-*/` fixture directories. | This branch. | Present in working directory; used for TP-1 through TP-4 acceptance tests. |
| Dep3 | `docs/writing-voice.md` voice rule for the em-dash strip policy. | Repo-wide. | Already canonical. |

## Testing Strategy

All tests are manual. The fixtures are the existing PR bundles under `tmp/gearjot-v2-web-pr-{299,307,339}/`; no new fixture files are created. The automated test harness, per-agent unit tests, and Mode C standalone tests are deferred as YAGNI (see Deferred section).

- **Observable behaviors to test:**
  - Severity inflation eliminated on the three PR bundles.
  - Focus areas and branch-level context reach every sub-agent prompt.
  - Step 7.2 reachability gate fires on the documented phrases.
  - S8 self-consistency check detects same-file overlapping-line-range contradictions.
  - S9 premise verification suppresses standards-compliance findings when the architectural-file read does not confirm the premise.
  - Mode B and Mode C skip YAGNI unless explicitly requested.
- **Test doubles posture:** none. All tests run the live `/code-review` skill against real PR bundles.
- **Edge cases requiring coverage:** the WARN-002/WARN-003 contradiction class (TP-4); the SEC-finding cross-reference preservation across the new gates (TP-18); data-isolation regression where focus areas from one invocation leak to another (TP-19); template structure preservation (TP-21).

**P0 acceptance tests (5):**
- TP-1: rerun `/code-review` against PR 299; assert ≤ 4 WARN findings.
- TP-2: rerun against PR 299; assert the Sentry-deferred PII item from the PR description's Deferred section is not re-raised.
- TP-3: rerun against PR 307; assert 1 WARN + 1 YAGNI finding.
- TP-4: rerun against PR 339; assert 1 CRIT + at most 1 WARN, and assert the WARN-002/WARN-003 contradiction is internally detected with `Tension with ...:` notes.
- TP-18: rerun against PR 299; assert the SEC-finding cross-reference structure is preserved through the new gates.

**P1 behavior tests (12):**
- TP-5 through TP-15: focus areas appear in prompts; branch context block populates; S1 size-aware rubric fires; S2/S10 merged gate produces no double-demotion; S3 default SUGG observed; S4 file-list scope observed (including the narrower [D-18](artifacts/implementation-decision-log.md#d-18-s4s-constraint-is-narrower-for-edge-case-explorer-than-for-junior-developer) wording for edge-case-explorer); S7 two-pass YAGNI; S8 tension notes emitted; S9 premise verification logs "premise not verified; finding omitted" when applicable; S10 reachability demotion on phrase list; one reserved.
- TP-19: data-isolation regression, two consecutive invocations with different `$focus_areas` produce non-overlapping focus-area content in their respective agent prompts.
- TP-20: the YAGNI verbatim opening preserved across the three-location rewrite.
- TP-21: template structure (caps, agent dispatch format, output schema) preserved.

**P2 tests (2):**
- TP-16: Mode B / Mode C YAGNI skip behavior.
- TP-17: cross-project validation, run the calibrated skill against a PR from a project other than gearjot-v2-web; document any divergence from the three PR bundles' behavior.

**Test levels:** integration (the skill is the unit under test). No unit-level tests of individual rubric sections, individual agent prompts, or Step 7 sub-steps as isolated functions; these are exercised by the integration runs.

## Security Posture

No applicable security surface. The implementation is markdown edits to a Claude Code plugin with no auth, no PII flow, no IO sinks, and no supply-chain change beyond the existing in-repo references. The only new tool grant is `Bash(gh *)` ([D-8](artifacts/implementation-decision-log.md#d-8-add-bashgh--to-skillmd-allowed-tools-frontmatter)), which is a narrowly scoped delegation to a CLI the user already has installed for their workflow.

## Operational Readiness

The plugin is markdown-only with no runtime, no observability surface, no SLO touchpoints, and no traditional rollout / rollback. Operational readiness is thin and limited to release mechanics:

- **Observability:** not applicable. No metrics, logs, or traces; the skill's "observability" is the rendered output of each `/code-review` run, validated by the manual tests above.
- **SLO impact:** not applicable. No SLOs exist for the plugin.
- **Feature flag:** not applicable. The behavior change is shipped directly; the user has been compensating with mode flags for the unwanted prior behavior, and the fix removes the need for the workaround.
- **Rollout:** ship the changes in the nine work-unit sequence above on a feature branch, validate against the three PR bundles, merge to `main`, bump version, update CHANGELOG.
- **Rollback:** revert the merge commit. The plugin has no migration to unwind.
- **Cost and scale:** not applicable. The new Step 1.5 makes at most one `gh pr view` call and one Glob, both of which are sub-second operations.
- **Transitive dependency callout:** the derivative `/gh-pr-review` skill inherits the behavior change. No edits to that skill are required; it consumes `/code-review`'s output through the same interface.

## Definition of Done

- [ ] TP-1 passes: `/code-review` against PR 299 produces ≤ 4 WARN findings on rerun.
- [ ] TP-2 passes: PR 299's Sentry-deferred PII item is not re-raised.
- [ ] TP-3 passes: PR 307 produces 1 WARN + 1 YAGNI finding.
- [ ] TP-4 passes: PR 339 produces 1 CRIT + at most 1 WARN, with the WARN-002/WARN-003 contradiction internally detected via the S8 tension notes ([D-12](artifacts/implementation-decision-log.md#d-12-s8-runs-an-extraction-pass-before-pair-comparison-scoped-to-overlapping-line-ranges-only)).
- [ ] TP-18 passes: SEC-finding cross-reference structure preserved through the new gates.
- [ ] Step 3.3 is the single authoritative home for size-based demotion; line 24, Step 7.2, the rubric, and the YAGNI two-pass procedure all reference Step 3.3 by name ([D-1](artifacts/implementation-decision-log.md#d-1-step-33-is-the-authoritative-home-for-size-based-demotion)).
- [ ] Step 7 is structured as 7.1 / 7.2 / 7.3 sub-steps with the merged demotion gate at 7.2 ([D-2](artifacts/implementation-decision-log.md#d-2-step-7-takes-a-numbered-sub-step-structure-71-read-72-merged-demote-73-rubric), [D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate)).
- [ ] `Bash(gh *)` added to SKILL.md frontmatter `allowed-tools` ([D-8](artifacts/implementation-decision-log.md#d-8-add-bashgh--to-skillmd-allowed-tools-frontmatter)).
- [ ] `$focus_areas` and `$branch_context` named bindings present and referenced by every Step 3.5 agent prompt template ([D-14](artifacts/implementation-decision-log.md#d-14-focus_areas-and-branch_context-are-explicit-named-bindings-populated-by-steps-1-and-15)).
- [ ] Step 1.5 fail-open warning fires when no PR or branch context loads ([D-9](artifacts/implementation-decision-log.md#d-9-s6-fail-open-behavior-prints-a-visible-warning-when-no-pr-or-branch-context-loads)).
- [ ] All four agent definition files (`plugin/agents/{structural-analyst, behavioral-analyst, junior-developer, edge-case-explorer}.md`) are unmodified ([D-4](artifacts/implementation-decision-log.md#d-4-s3-and-s4-ship-as-step-35-dispatcher-directives-not-as-edits-to-the-four-agent-definition-files)).
- [ ] Five long-form docs updated: `docs/skills/code-review.md` and the four `docs/agents/*.md` files ([D-7](artifacts/implementation-decision-log.md#d-7-long-form-docs-mirror-updates-are-in-scope)).
- [ ] No em-dashes appear in any shipped file under `plugin/` or `docs/` for this branch ([D-17](artifacts/implementation-decision-log.md#d-17-em-dash-strip-policy-on-verbatim-copy-from-the-investigation)).
- [ ] `plugin/.claude-plugin/plugin.json` reports version 2.3.0 ([D-6](artifacts/implementation-decision-log.md#d-6-version-bump-is-minor-220--230)).
- [ ] `CHANGELOG.md` has a `## 2.3.0` entry summarizing the four calibration changes, docs sync, and deferred items.
- [ ] The deferred S12 mode flag is not present in SKILL.md ([D-16](artifacts/implementation-decision-log.md#d-16-defer-s12-default-suppression-for-small-changes-as-yagni)).

## Specialist Handoffs for Implementation

- **`behavioral-analyst`**, dispatch during Pair B implementation when the Step 7.2 phrase-match gate is being written; needs the phrase list from [D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate) and the agent output samples from `tmp/gearjot-v2-web-pr-299/` to spot-check phrase coverage. Also dispatch during Pair C for the S6 loader implementation; needs the four-source order (gh, pr-body, commit messages, planning doc) and the [D-10](artifacts/implementation-decision-log.md#d-10-s6-planning-directory-lookup-uses-a-structured-claudemd-key-with-glob-fallback) lookup format.
- **`software-architect`**, dispatch during Pair A to confirm the Step 3.3 authoritative-home rewrite holds against every consumer site (rubric, line 24, Step 7.2, Step 3.5, YAGNI two-pass); needs [D-1](artifacts/implementation-decision-log.md#d-1-step-33-is-the-authoritative-home-for-size-based-demotion) and the list of five consumer references.
- **`test-engineer`**, dispatch after each unit completes to run the corresponding TP-# tests; needs the test catalog from Testing Strategy.
- **`junior-developer`**, dispatch during the docs sync (unit 8) to apply the [D-17](artifacts/implementation-decision-log.md#d-17-em-dash-strip-policy-on-verbatim-copy-from-the-investigation) em-dash strip policy and to confirm the [D-18](artifacts/implementation-decision-log.md#d-18-s4s-constraint-is-narrower-for-edge-case-explorer-than-for-junior-developer) narrower wording in the Step 3.5 dispatcher directive for `edge-case-explorer`.

## Deferred (YAGNI)

Items considered during planning but deferred under the YAGNI rule ([../../../plugin/references/yagni-rule.md](../../../plugin/references/yagni-rule.md)).

### S12 default-suppression mode flag for small changes
- **Why deferred:** Gate 2 simpler-version test. S1 + S2-merged-with-S10 + S13 satisfy the same evidence (the PR 299 E17 workaround "WARN-justified, SUGG suppressed per reviewer instruction") because the size-aware rubric already omits Suggestions on Small changes and demotes warnings on reachability phrases.
- **Reopen when:** post-ship validation against PR 299 still produces severity inflation requiring a SUGG-suppress mode flag.
- **Source:** R1, SA-6 / BA-9 / JD-006 consensus; recorded under [D-16](artifacts/implementation-decision-log.md#d-16-defer-s12-default-suppression-for-small-changes-as-yagni).

### Structured "directly introduced" field in agent output format
- **Why deferred:** Gate 1 evidence test. No documented incident demands a structured field; phrase-matching on the reachability list is the simpler version that handles the PR 299 demotion targets.
- **Reopen when:** post-ship validation shows the reachability phrase-match misses real cases that a structured field would have caught.
- **Source:** R1, JD-005 (recorded as the rejected alternative in [D-3](artifacts/implementation-decision-log.md#d-3-merge-s2-and-s10-into-a-single-step-72-reachability-phrase-match-gate)).

### Cross-file semantic contradiction detection in S8
- **Why deferred:** Gate 1 evidence test. No documented incident beyond PR 339's WARN-002/WARN-003 case, which is the overlapping-line-range class already covered by [D-12](artifacts/implementation-decision-log.md#d-12-s8-runs-an-extraction-pass-before-pair-comparison-scoped-to-overlapping-line-ranges-only).
- **Reopen when:** a real review surfaces a contradictory finding pair the line-range detector misses.
- **Source:** R1, JD-015 (recorded as the rejected alternative in [D-12](artifacts/implementation-decision-log.md#d-12-s8-runs-an-extraction-pass-before-pair-comparison-scoped-to-overlapping-line-ranges-only)).

### Automated test harness
- **Why deferred:** Gate 1 evidence test. No measured frequency of regression justifies automation infrastructure; the three manual fixture bundles are sufficient.
- **Reopen when:** the solutions run more than three times per month against new PRs and manual verification becomes a documented bottleneck.
- **Source:** R1, test-engineer YAGNI section.

### Per-agent unit tests
- **Why deferred:** Gate 1 evidence test. The PR-bundle acceptance tests (TP-1, TP-3, TP-4) exercise the full pipeline including each dispatched agent.
- **Reopen when:** a specific agent produces a regression on a new PR that the acceptance tests did not catch.
- **Source:** R1, test-engineer YAGNI section.

### Mode C standalone behavioral tests
- **Why deferred:** Gate 1 evidence test. Mode C is not represented in the three PR bundles; Mode A is the primary user path.
- **Reopen when:** a user files a Mode C regression.
- **Source:** R1, test-engineer YAGNI section.

### Global edits to the four agent definition files (the investigation's original S3/S4 form)
- **Why deferred:** Gate 2 simpler-version test. Skill-level dispatch directives in Step 3.5 satisfy the same evidence with smaller blast radius; agent definitions remain general-purpose for callers outside `/code-review`.
- **Reopen when:** a cross-project validation run (TP-17) or a user report shows a non-`/code-review` skill exhibits the same calibration failure.
- **Source:** R1, SA-4 / JD-007 / JD-014 consensus; recorded as the rejected alternative in [D-4](artifacts/implementation-decision-log.md#d-4-s3-and-s4-ship-as-step-35-dispatcher-directives-not-as-edits-to-the-four-agent-definition-files).

## Open Items

- **OI-1:** Cross-project validation (TP-17) has not been performed at plan stage. The calibration mechanisms are validated only against gearjot-v2-web PR bundles.
  - **Resolves when:** TP-17 runs against a PR from a different project and the output is recorded.
  - **Blocks implementation:** No. TP-17 is a P2 confidence test; the P0 acceptance tests (TP-1 through TP-4, TP-18) gate ship.

## Summary

- **Outcome delivered:** `/code-review` produces calibrated first-pass output matching the user's manual second-pass workaround on PR 299, PR 307, and PR 339, with focus areas and branch context plumbed to every sub-agent and internal detection of contradictory same-file findings.
- **Team size:** 4 specialists plus the project-manager, see [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md).
- **Rounds of facilitation:** 1, see [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md).
- **Decisions committed:** 21, see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md).
- **Decisions settled by evidence:** 13, see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md).
- **Decisions settled by junior-developer reframing:** 2, see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md).
- **Decisions settled by user input:** 2, see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md).
- **Rejected alternatives recorded:** 27, see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md).
- **Open items remaining:** 1 (TP-17 cross-project validation, non-blocking).
- **Recommendation:** Ship as planned.
