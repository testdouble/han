# Feature Implementation Plan: Per-Model Authoring Guidance

A new markdown guidance reference in the `han-plugin-builder` guidance skill that teaches skill and agent authors how Sonnet 5, Opus 4.8, and Fable 5 differ in how you write instructions for them, anchored to a model-agnostic default. It ships as one atomic commit of five documentation edits, wires into the two curated navigation surfaces plus the reverse cross-reference, and changes no run-time behavior.

## Source Specification

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Specification decision log:** [artifacts/decision-log.md](artifacts/decision-log.md)
- **Specification team findings:** [artifacts/team-findings.md](artifacts/team-findings.md)
- **Specification decisions this plan inherits:** D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12
- **Specification open items this plan must respect or resolve:** OI-1 (resolved at spec stage; see Open Items)

## Outcome

When this plan is executed, a new reference file `per-model-authoring.md` exists in `han-plugin-builder/skills/guidance/references/`, and an author consulting the plugin-building guidance while writing or hardening a skill or agent can be routed to it by the "how do I write instructions for this model" question. Both routing maps (the plugin's own `SKILL.md` and the vendored portable copy) and the vendored rule index carry a task-distinguishing entry, and the tier-selection doc carries the reverse cross-reference, so neither door orphans a reader. No shipped skill or agent behaves differently at run time.

## Context

- **Driving constraint:** The source research ([docs/research/model-specific-guidance-for-skills.md](../../research/model-specific-guidance-for-skills.md), recommendation O3) found that the three models genuinely diverge in how they follow instructions, that a skill cannot reliably detect its own model at run time, and that the sound place to act on the differences is when an author writes a skill. This feature is the author-time half of that recommendation.
- **Stakeholders:** skill authors and agent authors (who need to find and apply the guidance), and maintainers of the vendored guidance in downstream repos (who need the reference to arrive wired into every navigation surface, not orphaned).
- **Future-state concern:** the per-model behavioral claims rest largely on Anthropic's own prompting pages, which are pinned snapshots that get revised and archived, and the Fable 5 refusal warning is single-vendor, single-source. The document carries a currency marker and a single-source disclosure so a reader can judge staleness; there is no automated re-check and none is warranted for a static document ([D-6](artifacts/implementation-decision-log.md#d-6-the-reference-documents-own-structure-and-content-commitments)).
- **Out-of-scope boundary:** no run-time model detection or branching, no per-model skill or agent variants, no edits to existing skills or agents to tune them per model, no changes to the skill-builder or agent-builder interviews, and no `readability-guidance` per-model note. These are carried out of scope by the spec (Out of Scope and Deferred (YAGNI) sections) and are not reopened here.

## Team Composition and Participation

| Specialist               | Status      | Key Input                                                                                                                                                       |
| ------------------------ | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `project-manager`        | Coordinator | Facilitated R1 and synthesized this plan.                                                                                                                        |
| `junior-developer`       | Active      | Found the second (portable) routing map and the third (rule-index) navigation surface the spec did not name; confirmed the citation-path vendoring trap (C1, C2, C3, C5). |
| `information-architect`  | Active      | Fixed the routing-bullet placement and task-distinguishing wording, the rule-index entry, top-level placement, and the filename scent (Q1-Q3, C3, C4).           |

## Implementation Approach

This is a documentation feature. "Implementation" means authoring one markdown reference and wiring it into the guidance skill's navigation surfaces. There is no build, test runner, migration, or run-time surface (discovery notes: Han runs prettier/shellcheck/whitespace hooks only, and markdown prettier was disabled in commit a90cb09).

The work is a single atomic commit of five edits ([D-1](artifacts/implementation-decision-log.md#d-1-ship-all-five-edits-as-one-atomic-commit)). Shipping them together is the only sequencing constraint, because a vendored refresh between commits would copy the reference to disk (`scripts/init-guidance.sh:74`) while the curated indexes still had no scent to it.

### Architecture and Integration Points

The feature touches five files, all under `han-plugin-builder/skills/guidance/`:

1. **New reference file — `references/per-model-authoring.md`.** Top-level `references/`, alongside `specialization-and-model-selection.md` and `iterative-plugin-development.md`, named for task scent ([D-4](artifacts/implementation-decision-log.md#d-4-top-level-references-placement-and-filename)). It follows the format precedent of those two docs (H1 title, prose, H2 sections, a Cross-References section, and a Sources section) and the `han-plugin-builder` reference-file guidance (`skill-building-guidance/skill-reference-files.md`). Its content commitments are in [D-6](artifacts/implementation-decision-log.md#d-6-the-reference-documents-own-structure-and-content-commitments); its source-citation form (external Anthropic URLs plus the named research report, no repo-relative path) is in [D-5](artifacts/implementation-decision-log.md#d-5-source-citation-form--external-urls-plus-named-report-no-fragile-repo-relative-path).

2. **Plugin routing map — `SKILL.md`.** A new standalone bullet inserted after the model bullet at lines 36-37 and before the Templates bullet at line 38, so the two model-reasoning entries sit adjacent. The existing "specialization-versus-model-tier reasoning" bullet is not reworded ([D-2](artifacts/implementation-decision-log.md#d-2-add-the-routing-bullet-to-both-routing-maps-plugin-and-portable-copy)). Proposed bullet wording (label wording is a decision, so the text is inlined; the target path is not further prescribed here):

   > Writing the instructions for a target model (how Sonnet 5, Opus 4.8, and Fable 5 differ in following instructions, and how that changes what you write) → `${CLAUDE_SKILL_DIR}/references/per-model-authoring.md`.

3. **Portable routing map — `assets/guidance-portable-SKILL.md`.** The same bullet, inserted after the mirroring model bullet at lines 25-26 and before the Templates bullet at line 27. This is the copy `scripts/init-guidance.sh` actually vendors into other repos (`:31`, `:73`); the plugin's own `SKILL.md` is never vendored, so both maps must carry the bullet or vendored repos get the reference with no scent ([D-2](artifacts/implementation-decision-log.md#d-2-add-the-routing-bullet-to-both-routing-maps-plugin-and-portable-copy)).

4. **Vendored rule index body — `assets/rule-index-body.md`.** A third bullet under the `## Plugin development` section (after the Specialization and Model Selection entry at lines 161-164), matching the `[Title](path) — what it covers + when to read it` pattern with an inline scope disambiguator against the tier doc. This curated file regenerates the vendored `.claude/rules` index; a reference not listed here is copied to disk but orphaned in that index ([D-3](artifacts/implementation-decision-log.md#d-3-add-and-task-distinguish-the-rule-index-body-entry)).

5. **Reverse cross-reference — `references/specialization-and-model-selection.md`.** A link to the new doc plus a one-line scope disambiguator added to its Cross-References section (lines 85-95), so a reader entering through the higher-scent tier doc has a path onward ([D-1](artifacts/implementation-decision-log.md#d-1-ship-all-five-edits-as-one-atomic-commit); spec D10).

The reference file body is auto-vendored by the wholesale `references/` copy (`scripts/init-guidance.sh:74`), so it needs no per-file wiring beyond existing in the directory; the two curated index files and the reverse link are the hand-edited surfaces.

## Decomposition and Sequencing

All five edits ship in one atomic commit ([D-1](artifacts/implementation-decision-log.md#d-1-ship-all-five-edits-as-one-atomic-commit)). They are listed separately for verification, not for separate delivery.

| #   | Work Unit                                                             | Delivers                                                              | Depends On | Verification                                                                                 |
| --- | -------------------------------------------------------------------- | -------------------------------------------------------------------- | ---------- | -------------------------------------------------------------------------------------------- |
| 1   | Author `references/per-model-authoring.md`                           | The reference with all D-6 content and the D-5 citation form         | —          | Doc states the default, its unknown-target form, the instruction split, and the refusal warning with recognition test + single-source disclosure; forward link and currency marker present |
| 2   | Add task-distinguishing bullet to `SKILL.md`                         | Plugin routing map resolves the "write for this model" question       | 1          | Bullet sits between lines 37 and 38; points at `per-model-authoring.md`                       |
| 3   | Add the same bullet to `assets/guidance-portable-SKILL.md`           | Vendored routing map carries the same scent                           | 1          | Bullet sits between lines 26 and 27; matches unit 2 wording                                   |
| 4   | Add entry to `assets/rule-index-body.md` `## Plugin development`     | Vendored rule index lists the doc with a scope disambiguator          | 1          | Entry sits after the Specialization and Model Selection bullet; disambiguator present         |
| 5   | Add reverse link to `specialization-and-model-selection.md`          | Bidirectional cross-reference; neither door orphans a reader          | 1          | Cross-References section links `per-model-authoring.md` with a one-line scope note            |

## Testing Strategy

No automated test harness or CI check exists for guidance reference files (discovery notes: Han runs prettier/shellcheck/whitespace hooks only, and markdown prettier is disabled). Verification is structural and is the Definition of Done checklist below.

- **Observable behaviors to verify:** all five edits present in one commit; both routing maps and the rule index carry a task-distinguishing entry; the forward and reverse cross-references resolve in both directions.
- **Optional confirmation:** run `init-guidance.sh` (or `update` mode) in a scratch checkout and confirm the regenerated `.claude/rules/plugin-building-guidance.md` lists `per-model-authoring.md` under Plugin development and that `references/per-model-authoring.md` is present in the vendored copy.
- **Test levels:** structural review only; no unit, integration, or end-to-end layers apply to a documentation reference.

## Definition of Done

- [ ] `references/per-model-authoring.md` exists at top-level `references/` and states its own author-time-only scope ([D-4](artifacts/implementation-decision-log.md#d-4-top-level-references-placement-and-filename), [D-6](artifacts/implementation-decision-log.md#d-6-the-reference-documents-own-structure-and-content-commitments)).
- [ ] The document states the model-agnostic default and its concrete unknown-target form (goal and reasons first, load-bearing constraints and scope explicit, no exhaustive micro-checklists) ([D-6](artifacts/implementation-decision-log.md#d-6-the-reference-documents-own-structure-and-content-commitments)).
- [ ] The document states the opposite-direction instruction-style split across Opus 4.8 / Sonnet 5 and Fable 5 ([D-6](artifacts/implementation-decision-log.md#d-6-the-reference-documents-own-structure-and-content-commitments)).
- [ ] The document carries the Fable 5 reasoning-echo refusal warning, its recognition test (reproducing internal thinking into the deliverable, distinct from a normal explanation), and its single-source disclosure ([D-6](artifacts/implementation-decision-log.md#d-6-the-reference-documents-own-structure-and-content-commitments)).
- [ ] The document carries a visible currency marker naming the three models and the write date, and cites its source as external Anthropic URLs plus the named research report with no repo-relative path ([D-5](artifacts/implementation-decision-log.md#d-5-source-citation-form--external-urls-plus-named-report-no-fragile-repo-relative-path), [D-6](artifacts/implementation-decision-log.md#d-6-the-reference-documents-own-structure-and-content-commitments)).
- [ ] Both `SKILL.md` and `assets/guidance-portable-SKILL.md` carry an identically worded task-distinguishing routing bullet pointing at the new doc ([D-2](artifacts/implementation-decision-log.md#d-2-add-the-routing-bullet-to-both-routing-maps-plugin-and-portable-copy)).
- [ ] `assets/rule-index-body.md` carries a task-distinguishing entry under `## Plugin development` ([D-3](artifacts/implementation-decision-log.md#d-3-add-and-task-distinguish-the-rule-index-body-entry)).
- [ ] `specialization-and-model-selection.md` carries the reverse cross-reference and a one-line scope disambiguator ([D-1](artifacts/implementation-decision-log.md#d-1-ship-all-five-edits-as-one-atomic-commit)).
- [ ] All five edits land in one atomic commit ([D-1](artifacts/implementation-decision-log.md#d-1-ship-all-five-edits-as-one-atomic-commit)).

## Specialist Handoffs for Implementation

- **`han-communication:readability-editor`** — dispatch after the reference draft is complete and before commit; needs the drafted `per-model-authoring.md` and the routing/rule-index/reverse-link edits. The document follows the Han writing-voice profile like every other guidance reference (spec D8), and the author applies `han-plugin-builder` reference-file guidance (`skill-building-guidance/skill-reference-files.md`) while drafting.

## Open Items

- **OI-1:** Whether any existing Han skill or agent already uses the reasoning-echo instruction pattern the new guidance warns against.
  - **Resolves when:** resolved at spec stage. A grep across all prose-producing plugins returned zero matches (team findings F12), so the suite will not contradict its own new guidance.
  - **Blocks implementation:** No.

## Summary

- **Outcome delivered:** a new, findable, on-demand guidance reference teaching authors how the three named models differ in how you write instructions for them, wired into every navigation surface with no run-time change.
- **Team size:** 2 specialists (plus `project-manager` coordinator) — see [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Rounds of facilitation:** 1 — see [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Decisions committed:** 6 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by evidence:** 6 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by junior-developer reframing:** 0 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by user input:** 0 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Rejected alternatives recorded:** 9 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Open items remaining:** 0
- **Recommendation:** Ship as planned.
