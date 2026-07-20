# Feature Implementation Plan: Readability Standard in the Planning and Coding Skills

Wire Han's shared readability standard into seven prose-authoring skills, add a direct `han-communication` dependency to
`han-planning`, and clarify the standard's own reader-facing scope text. Every edit is Markdown or JSON instruction
text; no compiled code. Posture: incremental, sequenced commits, verified by a grep/jq acceptance checklist plus one
smoke run.

## Source Specification

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Specification decision log:** [artifacts/decision-log.md](artifacts/decision-log.md)
- **Specification team findings:** [artifacts/team-findings.md](artifacts/team-findings.md)
- **Specification decisions this plan inherits:** D1, D2, D3, D4, D5, D6, D7, D8, D9
- **Specification open items this plan must respect or resolve:** None (spec Open Items: 0)

## Outcome

Seven skills that author reader-facing prose but skip the shared readability standard today will source it while they
draft and hold their output to it before presenting. In `han-planning`: `plan-a-feature`, `plan-implementation`,
`plan-a-phased-build`, `plan-work-items`, and `iterative-plan-review`. In `han-coding`: `coding-standard` and
`test-planning`. `han-planning`'s manifest gains a direct `han-communication` dependency. The canonical
`readability-rule.md` scope text and the `readability-guidance` skill both gain a clarified reader-facing scope test, so
the standard no longer reads as excluding the artifact types these skills produce.

## Context

- **Driving constraint:** The standard's own scope text (`readability-rule.md` lines 20-23) currently reads as excluding
  the seven artifact types, so the integrations and the standard are textually inconsistent until the D9 clarification
  lands. Reconciling them removes the invitation for a future contributor to strip the integration
  ([D-1](artifacts/implementation-decision-log.md#d-1-edit-sequencing)).
- **Stakeholders:** The engineer running each skill (gets in-voice, self-checked output); the downstream reader of each
  deliverable (a spec, plan, phased build, work items, coding standard, or test plan they can follow); the suite
  maintainer (one canonical standard, no vendored drift).
- **Future-state concern:** Insertion points are named by step number in the discovery notes, and step numbers are
  fragile. Each skill's live numbering must be re-checked at edit time so a snippet does not land at the wrong step
  (RAID A1).
- **Out-of-scope boundary:** No change to what the standard requires (criteria, voice, fidelity rule); only the D9 scope
  text is clarified. No long-form doc updates under `docs/skills/*` — the repo's `han-update-documentation` skill
  handles those after these edits land. No version bump and no CHANGELOG edit. No edits to the publishing or work-items
  wrappers (their gaps close upstream, spec D8).

## Team Composition and Participation

| Specialist                   | Status      | Key Input                                                                                                    |
| ---------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------ |
| `han-core:project-manager`   | Coordinator | Facilitated R1 and synthesized this plan.                                                                     |
| `han-core:junior-developer`  | Active      | Sequencing (D9 first, D4 early), two-frozen-snippet drift control, Guidance-Mode routing, prerequisite audit. |
| `han-core:test-engineer`     | Active      | Deterministic grep/jq acceptance checklist (T1-T17) plus one smoke run; YAGNI deferrals S1, S2.               |

## Implementation Approach

All edits are instruction text. Two canonical snippets are frozen and reused verbatim across the seven skills, varying
only the D5 named reader and the excluded citation-ID tokens per skill
([D-2](artifacts/implementation-decision-log.md#d-2-two-frozen-canonical-snippets-for-drift-control)). Authoring routes
through han-plugin-builder Guidance Mode — consulting the guidance docs, not running the interview builders or
`guidance init` ([D-3](artifacts/implementation-decision-log.md#d-3-author-via-han-plugin-builder-guidance-mode-not-the-builders-or-guidance-init)).

### The two frozen snippets

- **FULL** (five skills): a guidance-source line early in the workflow, then after the final content exists a single
  `han-communication:readability-editor` dispatch passing the named reader and no rule path (the editor reads its own
  canonical rule), then the six-point self-check before presenting. Sourced from
  `han-coding/skills/investigate/SKILL.md` Step 5.
- **LIGHTWEIGHT** (two skills): the same guidance-source line plus the six-point self-check, explicitly no editor
  dispatch. Guidance line matches `han-core/skills/issue-triage/SKILL.md:30`.

The six self-check criteria mirror `readability-rule.md`'s canonical six, including the fact-fidelity criterion "every
fact preserved," which is the only fact-preservation guard the two lightweight skills carry (spec D2).

### Per-skill insertion points

FULL pattern (guidance early + editor after final content + self-check before present):

| Skill                | Guidance at        | Final content        | Editor + self-check      | Named reader (D5)                        | Prose-region exclusions                 |
| -------------------- | ------------------ | -------------------- | ------------------------ | ---------------------------------------- | --------------------------------------- |
| `plan-a-feature`     | Step 5 (Draft)     | Step 8 PM synthesis  | new pass before Step 9   | stakeholder/reviewer of the spec         | D#/T#/F# IDs, tables, code fences        |
| `plan-implementation`| Step 2 / pre-Step 8| Step 8 PM synthesis  | before Step 9 (Present)  | the engineer who will build              | D-N citation identifiers                 |
| `plan-a-phased-build`| Step 6 (Draft)     | Step 8 (Apply IA)    | after Step 8, before Step 9 | per-run audience collected in Step 3  | (audience is per-run, not hardcoded)     |
| `coding-standard`    | Step 6 (Write)     | after Step 9 review  | at/after Step 10, before present | the engineer who must follow the standard | frontmatter untouched; update mode scopes to edited region |
| `test-planning`      | Step 4 (Generate)  | Step 4               | Step 5 (Review), before present | the engineer who will implement the tests | TP-NNN IDs                          |

LIGHTWEIGHT pattern (guidance + self-check only, no editor):

| Skill                  | Guidance at | Self-check at                          | Named reader (D5)                  | Prose-region exclusions            |
| ---------------------- | ----------- | -------------------------------------- | ---------------------------------- | ---------------------------------- |
| `plan-work-items`      | step 5      | before step 7 (Print) / step 8 (Write) | the engineer who grabs a work item | W-N IDs and structured fields      |
| `iterative-plan-review`| early       | once at Step 6/7 on the converged plan | the reader of the plan it refines  | regions this run authored/changed only |

`iterative-plan-review`'s self-check is inserted once, after both review loops converge — not inside both Step 4 and
Step 5 (spec D5; test T13). `coding-standard`'s self-check is mode-conditional: create/convert mode covers newly
authored content, update mode covers the edited region (test T12).

### Non-skill edits

- `han-planning/.claude-plugin/plugin.json` — `dependencies` `["han-core"]` → `["han-communication", "han-core"]`,
  matching `han-coding`'s order; version stays `2.0.4`; no meta-plugin or marketplace change
  ([D-5](artifacts/implementation-decision-log.md#d-5-pluginjson-dependency-order-and-no-version-bump)).
- `han-communication/references/readability-rule.md` lines 20-23 — clarify the "who reads reader-facing output" scope so
  a human-read plan-of-record is distinguished from a pure pipeline artifact (spec D9).
- `han-communication/skills/readability-guidance/SKILL.md` — add a brief restatement of the clarified scope test; this
  is new text, since the skill carries none today
  ([D-6](artifacts/implementation-decision-log.md#d-6-the-readability-guidance-scope-restatement-is-new-text)).

Prerequisites confirmed and unchanged: all seven skills already grant the `Agent` tool the editor pass needs (no
tool-grant change); `readability-guidance` is invoked from instruction text with no `Skill` grant; the `han` meta-plugin
and marketplace need no change.

## Decomposition and Sequencing

Incremental, commit-and-push-as-you-go. The D9 clarification and the D4 dependency land before the skill edits that rely
on them ([D-1](artifacts/implementation-decision-log.md#d-1-edit-sequencing)).

| #   | Work Unit                                       | Delivers                                                             | Depends On | Verification                                              |
| --- | ----------------------------------------------- | ------------------------------------------------------------------- | ---------- | -------------------------------------------------------- |
| a   | D9 scope clarification                          | `readability-rule.md` lines 20-23 clarified + `readability-guidance` restatement | —          | T8, T9 (both surfaces agree; guidance diff non-empty)    |
| b   | D4 dependency add                               | `han-planning/plugin.json` deps `["han-communication","han-core"]`, version `2.0.4` | —          | T1, T2 (`jq` on deps and version)                        |
| c   | Five full-pattern skills                        | FULL snippet inserted per the per-skill table                       | a, b       | T3, T4, T5, T7, T10, T11, T12, T14                       |
| d   | Two lightweight skills                          | LIGHTWEIGHT snippet inserted per the per-skill table                | a, b       | T3, T4, T6, T10, T11, T13, T14                           |
| e   | Verification                                    | grep/jq checklist run + one smoke run + T17 no-change confirmation  | c, d       | full checklist below                                     |

The five and two skill edits are order-independent among themselves (independent files).

## RAID Log

### Assumptions

| ID  | Assumption                                                                                      | What Changes If Wrong                              | Verifier                                            | Status |
| --- | ---------------------------------------------------------------------------------------------- | -------------------------------------------------- | --------------------------------------------------- | ------ |
| A1  | The step numbers named in the per-skill insertion table still match each skill's live numbering. | A snippet lands at the wrong step in the workflow. | Per-skill manual check of live numbering at edit time. | Open   |

## Testing Strategy

No behavior test harness exists; verification is a deterministic grep/jq acceptance checklist plus one smoke run
([D-4](artifacts/implementation-decision-log.md#d-4-verification-is-a-grepjq-acceptance-checklist-plus-one-smoke-run)).
`plugin.json` gets free JSON validation from the existing prek/Prettier lint; Markdown stays deliberately unlinted.

Acceptance checklist:

- **T1/T2 — plugin.json:** stays valid JSON; `jq -e '.dependencies==["han-communication","han-core"] and
  .version=="2.0.4"'` on `han-planning/.claude-plugin/plugin.json` passes.
- **T3 — guidance line:** present and positioned before the drafting step in all seven skills.
- **T4 — self-check:** the six-criteria self-check present in all seven; criteria match `readability-rule.md`'s
  canonical six, including "every fact preserved."
- **T5 — editor position (full):** editor dispatch present in the five full skills, positioned
  final-content-step < editor < present-step (line-number check).
- **T6 — editor absent (lightweight):** `grep -c` for the editor dispatch returns 0 in `plan-work-items` and
  `iterative-plan-review`.
- **T7 — editor dispatch shape:** names the reader, passes no rule path, single `Agent` call.
- **T8/T9 — scope-text agreement:** `readability-rule.md` scope text and the `readability-guidance` restatement agree;
  the `readability-guidance` diff is non-empty.
- **T10 — named reader:** each skill names its D5 reader; `plan-a-phased-build` uses the per-run audience from Step 3,
  not a hardcoded frame.
- **T11 — prose-region exclusions:** each skill names its own ID scheme (`plan-implementation` D-N; `plan-work-items`
  W-N; `test-planning` TP-NNN; `plan-a-feature` D#/T#/F#).
- **T12 — coding-standard:** frontmatter untouched; self-check mode-conditional (create/convert covers new content,
  update covers the edited region).
- **T13 — iterative-plan-review:** self-check inserted once after both loops converge, not inside both Step 4 and
  Step 5.
- **T14 — tool grants:** no `allowed-tools` change on any of the seven.
- **T15 — smoke run:** one representative full-pattern skill and one lightweight skill run cleanly.
- **T17 — unchanged manifests:** `han` meta-plugin `plugin.json` and marketplace `.json` unchanged.

## Definition of Done

- [ ] `han-planning/plugin.json` deps are `["han-communication","han-core"]` and version is `2.0.4` — T1, T2, D-5.
- [ ] All seven skills source `readability-guidance` before drafting and carry the six-point self-check — T3, T4, D-2.
- [ ] The five full skills dispatch one `readability-editor` between final content and present, with named reader and no
      rule path — T5, T7, D-2.
- [ ] `plan-work-items` and `iterative-plan-review` carry no editor dispatch — T6, D-2.
- [ ] Each skill names its D5 reader and its own ID-scheme exclusions; `coding-standard` frontmatter untouched and
      self-check mode-conditional; `iterative-plan-review` self-check inserted once — T10, T11, T12, T13.
- [ ] `readability-rule.md` scope text and the `readability-guidance` restatement agree and are non-empty — T8, T9, D-6.
- [ ] No `allowed-tools` change on any skill; `han` meta-plugin and marketplace unchanged — T14, T17.
- [ ] One full-pattern and one lightweight skill smoke-run cleanly — T15, D-4.
- [ ] Per-skill live step numbering re-checked before each insertion — A1.

## Specialist Handoffs for Implementation

- **`han-core:project-manager`** — executes the sequenced work units (a-e) and the edits; owns D-1, D-2, D-3, D-5, D-6.
- **`han-core:test-engineer`** — dispatch at work unit (e); runs the grep/jq acceptance checklist and the single smoke
  run; owns D-4.
- **han-plugin-builder guidance docs** — consult in Guidance Mode before editing: `skill-composition.md`,
  `agent-dispatch-namespacing.md`, `writing-effective-instructions.md`, and `claude-marketplace-and-plugin-configuration/`
  for the `plugin.json` edit (D-3). Not the `skill-builder`/`agent-builder` interviews and not `guidance init`.

## Deferred (YAGNI)

### All-seven end-to-end dry runs (S1)

- **Why deferred:** Simpler-version test — one smoke run (one full + one lightweight skill) plus the grep/jq checklist
  gives the same confidence as dry-running all seven, at lower cost. The Sentry-runbook precedent does not apply; there
  is no operational machinery here.
- **Reopen when:** The grep checklist plus one smoke run misses a class of defect that only a per-skill run would catch.
- **Source:** R1, test-engineer.

### Prose-lint tool (S2)

- **Why deferred:** Evidence test — no measured need or incident forces building a single-use lint tool; grep over the
  frozen snippets covers the consistency invariant.
- **Reopen when:** Manual grep proves repeatedly insufficient across multiple future integrations.
- **Source:** R1, test-engineer.

### Running the builder skills or `guidance init` instead of a guidance consult

- **Why deferred:** Simpler-version test — a Guidance-Mode doc consult satisfies the CLAUDE.md authoring mandate for
  edits to existing skills; the interview builders build from scratch and `guidance init` vendors skills, neither of
  which this work needs (D-3).
- **Reopen when:** An edit turns out to require authoring a new skill or agent rather than editing an existing one.
- **Source:** R1, junior-developer.

## Open Items

None block implementation. OQ-1 (atomic vs. incremental) was resolved by user directive to commit and push as you go,
sequenced so D9 and D4 land first ([D-1](artifacts/implementation-decision-log.md#d-1-edit-sequencing)). The downstream
`han-update-documentation` pass over the seven skills' long-form docs is deliberately out of scope (spec Out of Scope)
and runs after these edits land.

## Summary

- **Outcome delivered:** Seven prose-authoring skills source and apply the shared readability standard before
  presenting, `han-planning` declares `han-communication` directly, and the standard's scope text is clarified in both
  the canonical rule and the guidance skill.
- **Team size:** 3 specialists — see
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Rounds of facilitation:** 1 — see
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Decisions committed:** 6 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by evidence:** 5 — see
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by junior-developer reframing:** 0 — see
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by user input:** 1 (D-1 sequencing posture) — see
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Rejected alternatives recorded:** 14 — see
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Open items remaining:** 0
- **Recommendation:** Ship as planned.
