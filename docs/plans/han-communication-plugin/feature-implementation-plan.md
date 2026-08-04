# Feature Implementation Plan: han-communication Plugin

<!-- Extract the readability capability and its shared writing standard into a new foundational plugin, han-communication, and rewire the suite to source the standard cross-plugin. Posture: additive-first, delete-last migration across six phases, verified by static checks plus one light smoke, released only when explicitly directed. -->

## Source Specification

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Specification decision log:** [artifacts/decision-log.md](artifacts/decision-log.md)
- **Specification technical notes:** [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
- **Specification team findings:** [artifacts/team-findings.md](artifacts/team-findings.md)
- **Specification decisions this plan inherits:** D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11
- **Specification open items this plan must respect or resolve:** OI-2 (Codex agent-dispatch unverified; non-blocking), OI-3 (resolved by the spike; captured as T1)

## Outcome

When this plan is executed, the repo has a new foundational plugin, `han-communication`, that depends on nothing and owns one canonical copy each of `readability-rule.md` and `writing-voice.md`, the `readability-editor` agent, the `edit-for-readability` skill, and a new inline `readability-guidance` skill. The three vendored reference copies in `han-coding`, `han-github`, and `han-reporting`, and the four `han-core` originals, are gone — `find` returns exactly one copy of each reference file. All 13 consumer skills source the standard by invoking `han-communication:readability-guidance`; the 9 synthesis skills additionally dispatch `han-communication:readability-editor` with no rule-path argument; the 4 draft-and-self-check skills run no rewrite. Six plugin manifests declare the new dependency edge (`han-core` for the first time), both marketplaces list the plugin, and every stale doc pointer and dependency narration is updated. No version is bumped.

## Context

- **Driving constraint:** A user-directed refactor to give the suite's readability standard one unambiguous owner and remove the byte-identical vendored duplication (spec [D1](artifacts/decision-log.md#d1-introduce-han-communication-as-a-foundational-plugin), [D3](artifacts/decision-log.md#d3-source-the-standard-cross-plugin-not-inline)). The load-bearing mechanism risk (same-context sourcing) was retired by the OI-3 spike before planning began ([T1](artifacts/feature-technical-notes.md#t1-same-context-composition-the-guidance-skill-is-inline-not-forked)), so the gate is clear.
- **Stakeholders:** Operators running prose-producing Han skills (output must meet the same standard, applied in the same stages, after the move); contributors maintaining the suite (one canonical copy to edit, no re-vendoring); the primary plugin loader (resolves the six new direct edges); Codex-based operators (install the plugin explicitly since Codex resolves no dependencies).
- **Future-state concern:** `han-communication` is the first plugin to co-locate a skill and an agent outside `han-core`, and `han-core` takes its first-ever dependency — both invert previously-stated invariants, so the docs sweep must reframe those rules rather than leave them half-true ([D-6](artifacts/implementation-decision-log.md#d-6-repo-wide-docs-and-narration-sweep-by-grep-with-the-agents-live-in-han-core-exception)). The residual `api_retry` early-exit risk is reduced by inference, not measured; it is watched via a documented troubleshooting note, not new machinery.
- **Out-of-scope boundary:** No change to the content of the readability rule, the writing-voice profile, the editor's rewrite behavior, or the staged application model (spec Out of Scope). No dependency for `han-planning`, `han-linear`, `han-feedback`, or `han-plugin-builder`. No version bumps applied. No CI/lint/fault-injection tooling built (see Deferred).

## Team Composition and Participation

| Specialist | Status | Key Input |
|------------|--------|-----------|
| `project-manager` | Coordinator | Facilitated R1–R2 and synthesized this plan. |
| `junior-developer` | Active | Riskiest-ordering (delete-last, grep gate); the "agents live in han-core" exception; coupled rename-and-drop edit; count-free indexes. |
| `structural-analyst` | Active | Verified the six-plugin edge list from scratch; the module layout and new-plugin-category observation; efferent coupling 0, no cycle. |
| `devops-engineer` | Active | RECON-1 (Codex surface already exists, extend not build); the six safe-sequencing phases; PR grouping; rollback via `git revert`. |
| `test-engineer` | Active | V1–V13 static checks plus the light V6 smoke; do-not-re-run the spike; accept the `api_retry` residual risk as documented. |

## Implementation Approach

The refactor is content-and-manifest surgery on a Markdown-plus-JSON plugin suite with no build system. The shape is: stand up the new plugin additively, declare the dependency edges, rewire the consumers, delete the originals last behind a grep gate, then sweep docs. Nothing runs at runtime that this plan introduces beyond the existing skill-invocation and agent-dispatch primitives.

### Architecture and Integration Points

`han-communication` is a new foundational layer beneath every other plugin, depending on nothing (efferent coupling 0, so no cycle) ([D-1](artifacts/implementation-decision-log.md#d-1-direct-dependency-edge-list-six-declaring-plugins), [D-7](artifacts/implementation-decision-log.md#d-7-han-communication-module-layout)). Its layout co-locates the `readability-editor` agent, the `edit-for-readability` and new `readability-guidance` skills, and both reference files in one `references/` directory, preserving the `skills/{name}/SKILL.md` + `../../references/{file}.md` two-level path that `edit-for-readability` depends on ([D-7](artifacts/implementation-decision-log.md#d-7-han-communication-module-layout)). Six Claude manifests gain the dependency edge — `han-core`, `han-coding`, `han-github`, `han-reporting`, the `han` meta-plugin, and `han-atlassian` — with `han-core` receiving its first-ever `dependencies` key, value `["han-communication"]` ([D-1](artifacts/implementation-decision-log.md#d-1-direct-dependency-edge-list-six-declaring-plugins)). The Codex surface already exists and is **extended**, not built: a new `.codex-plugin/plugin.json` and a `.agents/plugins/marketplace.json` entry, with zero Codex dependency or description edits ([D-4](artifacts/implementation-decision-log.md#d-4-extend-the-existing-codex-surface-zero-codex-dependency-or-description-edits)).

### Runtime Behavior

The new `readability-guidance` skill is **inline** — it must not set `context: fork` — so the standard it surfaces persists in the caller's context and the caller resumes its own workflow ([T1](artifacts/feature-technical-notes.md#t1-same-context-composition-the-guidance-skill-is-inline-not-forked)). Each of the 13 consumers invokes it by qualified name at the drafting point. The 9 synthesis skills additionally dispatch `han-communication:readability-editor` as one coupled edit that renames the namespace and drops the now-dead `../../references/readability-rule.md` argument; the editor reads its own co-located canonical rule ([D-3](artifacts/implementation-decision-log.md#d-3-editor-invocation-contract-rename-plus-drop-rule-path-arg)). gap-analysis's size-conditional editor skip is preserved; the 4 draft-and-self-check skills gain the guidance invocation but no editor dispatch ([D-3](artifacts/implementation-decision-log.md#d-3-editor-invocation-contract-rename-plus-drop-rule-path-arg)).

## Decomposition and Sequencing

Six ordered phases; every phase before Phase 4 is additive, so the suite stays runnable throughout ([D-2](artifacts/implementation-decision-log.md#d-2-copy-first-delete-last-migration-sequencing)). Suggested PR grouping: Phases 1–2 as one PR, Phases 3–4 as a second, Phase 5 as a third; Phase 6 is release.

| # | Work Unit | Delivers | Depends On | Verification |
|---|-----------|----------|------------|--------------|
| 1 | Create and populate `han-communication` | The plugin dir, both manifests, both marketplace entries; suite still runs on old copies | — | `jq` both manifests; `find` shows new files; suite still resolves old vendored copies ([D-8](artifacts/implementation-decision-log.md#d-8-manual-verification-static-checks-plus-one-light-smoke-no-ci)) |
| 2 | Declare dependency edges and narration | 6 dependency edges; updated dependency-narrating descriptions | 1 | `jq` each `dependencies` array; grep descriptions ([D-1](artifacts/implementation-decision-log.md#d-1-direct-dependency-edge-list-six-declaring-plugins)) |
| 3 | Rewire consumers | 13 consumers source guidance; 9 dispatches renamed and arg dropped; 6 secondary template files updated | 2 | V1–V5, V7–V13 grep/diff ([D-3](artifacts/implementation-decision-log.md#d-3-editor-invocation-contract-rename-plus-drop-rule-path-arg), [D-8](artifacts/implementation-decision-log.md#d-8-manual-verification-static-checks-plus-one-light-smoke-no-ci)) |
| 4 | Delete originals (last) | 6 vendored copies and 4 `han-core` originals removed | 3 + clean grep gate | `find` each reference == 1; no old qualified names outside CHANGELOG/research ([D-2](artifacts/implementation-decision-log.md#d-2-copy-first-delete-last-migration-sequencing)) |
| 5 | Docs, indexes, narration sweep | Long-form docs moved; new guidance doc; grep-driven pointer/narration fixes; CHANGELOG entry | 4 | Doc pointers repointed; CHANGELOG/research untouched; V6 light smoke ([D-6](artifacts/implementation-decision-log.md#d-6-repo-wide-docs-and-narration-sweep-by-grep-with-the-agents-live-in-han-core-exception)) |
| 6 | Release (deferred) | Version bumps applied under explicit direction | 5 | `han-release` process ([D-5](artifacts/implementation-decision-log.md#d-5-version-bumps-listed-but-deferred-to-release)) |

**Phase 1 — create and populate (additive).** CREATE `han-communication/.claude-plugin/plugin.json` (no `dependencies` key, initial authoring version), `han-communication/.codex-plugin/plugin.json` (mirror `han-core`'s Codex schema, `skills: "./skills/"`, no dependencies/description narration), `agents/readability-editor.md`, `skills/edit-for-readability/SKILL.md`, `skills/readability-guidance/SKILL.md` (new, **inline** per T1), and `references/readability-rule.md` + `references/writing-voice.md` (co-located canonical). ADD the `han-communication` entry to `.claude-plugin/marketplace.json` and to `.agents/plugins/marketplace.json` (`source: {local, path}`, `policy`, `category`; no description, no dependencies) ([D-4](artifacts/implementation-decision-log.md#d-4-extend-the-existing-codex-surface-zero-codex-dependency-or-description-edits), [D-7](artifacts/implementation-decision-log.md#d-7-han-communication-module-layout)).

**Phase 2 — declare edges and narration (before any rewire).** EDIT the `dependencies` array in the 6 Claude `plugin.json` files, adding `"han-communication"` (`han-core` gains the key for the first time) ([D-1](artifacts/implementation-decision-log.md#d-1-direct-dependency-edge-list-six-declaring-plugins)). Update the dependency-narrating `description` fields for `han`, `han-coding`, and `han-atlassian` in **both** `plugin.json` and the `marketplace.json` mirror, plus the new `han-communication` entry; do **not** touch `han-github` or `han-reporting` descriptions (they carry no dependency narration). Zero Codex edits in this phase ([D-4](artifacts/implementation-decision-log.md#d-4-extend-the-existing-codex-surface-zero-codex-dependency-or-description-edits)).

**Phase 3 — rewire consumers.** At the 9 synthesis dispatch sites plus `edit-for-readability` (10 sites), rename `han-core:readability-editor` → `han-communication:readability-editor` and drop the rule-path argument as one coupled edit ([D-3](artifacts/implementation-decision-log.md#d-3-editor-invocation-contract-rename-plus-drop-rule-path-arg)). Add the `han-communication:readability-guidance` invocation to all 13 consumers at the drafting point; the 4 draft-and-self-check skills (runbook, issue-triage, ADR, html-summary) gain guidance but no editor dispatch; gap-analysis's size-conditional skip survives. Update the 6 secondary template/reference files that hardcode the rule path (one at a 3-level depth). Rename any `han-core:edit-for-readability` reference to the `han-communication:` namespace.

**Phase 4 — delete originals last (grep-gated).** Run the pre-delete grep gate (asset strings, both qualified names, any relative or plugin-root path to `readability-rule.md`/`writing-voice.md`); it must come back clean outside the CHANGELOG/research exclusions. Only then DELETE the 6 vendored copies (`han-coding`, `han-github`, `han-reporting` × 2 files) and the 4 `han-core` originals (agent, `edit-for-readability` skill dir, 2 reference files) ([D-2](artifacts/implementation-decision-log.md#d-2-copy-first-delete-last-migration-sequencing)).

**Phase 5 — docs, indexes, narration sweep.** Move `docs/agents/han-core/readability-editor.md` → `docs/agents/han-communication/` and `docs/skills/han-core/edit-for-readability.md` → `docs/skills/han-communication/`, rewriting their outbound links. Add a `readability-guidance` long-form doc under `docs/skills/han-communication/` with one troubleshooting sentence on the `api_retry` residual risk. Execute the comprehensive grep sweep for classes 3–5 of spec D7, extended with the agent-home seed, reframing "all agents live in han-core" to name the `han-communication` exception ([D-6](artifacts/implementation-decision-log.md#d-6-repo-wide-docs-and-narration-sweep-by-grep-with-the-agents-live-in-han-core-exception)). Keep indexes count-free and add `han-communication` entries. Fix the `han-atlassian` Codex co-requisite doc gap while editing that region ([D-9](artifacts/implementation-decision-log.md#trivial-decisions)). Add a new CHANGELOG entry; leave CHANGELOG and `docs/research/**` history otherwise untouched.

**Phase 6 — release (deferred).** Version bumps are listed, not applied, with `han-core` a MAJOR candidate; applied only under explicit direction via `han-release` ([D-5](artifacts/implementation-decision-log.md#d-5-version-bumps-listed-but-deferred-to-release)).

## RAID Log

### Risks

| ID | Risk | Likelihood | Severity | Blast Radius | Reversibility | Owner | Mitigation |
|----|------|------------|----------|--------------|---------------|-------|------------|
| R1 | A consumer reference or dependency array is missed, leaving an orphaned pointer or under-declared edge (the commit 05d7562 drift class) | Medium | Medium | One skill or one install path breaks silently | High (`git revert` per phase) | junior-developer | Grep-driven sweep ([D-6](artifacts/implementation-decision-log.md#d-6-repo-wide-docs-and-narration-sweep-by-grep-with-the-agents-live-in-han-core-exception)) and the hard pre-delete grep gate ([D-2](artifacts/implementation-decision-log.md#d-2-copy-first-delete-last-migration-sequencing)); `han-atlassian` treated as highest-verification-priority edit |
| R2 | No CI/linter exists to catch a malformed manifest or a dropped rule-path arg | Medium | Low | Affected manifest or dispatch site | High | test-engineer | Per-phase static `jq`/grep/diff checks V1–V13 plus one install smoke ([D-8](artifacts/implementation-decision-log.md#d-8-manual-verification-static-checks-plus-one-light-smoke-no-ci)) |
| R3 | The `api_retry` early-exit path could not be induced in the spike; residual risk is reduced by inference, not measured | Low | Medium | A consumer could early-exit right after a guidance call | Medium | test-engineer | Accept as documented (troubleshooting sentence in the guidance long-form doc); fallbacks (editor-only delegation, or vendoring for the 4 non-synthesis skills) remain the documented safety net |

### Assumptions

| ID | Assumption | What Changes If Wrong | Verifier | Status |
|----|------------|-----------------------|----------|--------|
| A1 | The inline (non-forked) same-context sourcing holds in real usage as it did across the spike's 34/34 runs | If it early-exits, a consumer abandons remaining steps; fall back to editor-only or vendoring | test-engineer via V6 smoke | Reduced by inference (T1); `api_retry` unmeasured |
| A2 | The primary loader resolves the 6 direct edges (no transitive reliance needed) | If not, the plan already avoids transitive reliance, so direct edges cover it | structural-analyst | Held under spec review; direct-edge design removes the dependence |

### Dependencies

| ID | Dependency | Owner | Status |
|----|------------|-------|--------|
| Dep1 | Whether a Codex-based agent can dispatch the editor **agent** (spec OI-2) | contributor, independent of this feature | Open, non-blocking — guidance and skill invocations do not depend on it, and synthesis skills' editor dispatch predates this move |
| Dep2 | `han-release` applies the deferred version bumps at release time | devops-engineer / `han-release` | Deferred to release ([D-5](artifacts/implementation-decision-log.md#d-5-version-bumps-listed-but-deferred-to-release)) |

## Testing Strategy

Verification is manual; the repo has no build system, test harness, linter, or CI ([D-8](artifacts/implementation-decision-log.md#d-8-manual-verification-static-checks-plus-one-light-smoke-no-ci)).

- **Observable behaviors to test:** all 13 consumers source the standard via `han-communication:readability-guidance` (V1–V13); the 9 editor dispatches are renamed with the rule-path arg dropped and the 4 draft-and-self-check skills dispatch no editor; the self-check blocks are byte-identical pre/post; after Phase 4, `find readability-rule.md` and `find writing-voice.md` each return exactly 1; no `han-core:readability-editor` / `han-core:edit-for-readability` name survives outside CHANGELOG and docs/research; the 6 dependency edges are present and the 4 excluded plugins absent; both marketplaces carry the entry.
- **Test doubles posture:** not applicable — static content checks (`grep`, `diff`, `jq`, `find`), not executable-code tests.
- **Edge cases requiring coverage:** the 3-level-depth secondary template path in html-summary; gap-analysis's size-conditional editor skip; the historical-artifact guard (CHANGELOG/research must stay unchanged).
- **Test levels:** static per-phase checks (V1–V13) as the primary layer; one light dynamic smoke (V6) — 2 real heavy consumers (for example `investigate` or `architectural-analysis`, and `runbook`), 2 runs each, judged from on-disk artifacts, confirming the guidance skill ran same-context with no `context: fork`. The 46-trial spike is not re-run (risk retired by [T1](artifacts/feature-technical-notes.md#t1-same-context-composition-the-guidance-skill-is-inline-not-forked)).

## Operational Readiness

This is a static Markdown-plus-JSON packaging change with no runtime service, telemetry, or scaling surface, so observability, SLO, and alerting machinery are deliberately absent (see Deferred). What matters operationally is packaging, install, and rollback ([D-2](artifacts/implementation-decision-log.md#d-2-copy-first-delete-last-migration-sequencing), [D-4](artifacts/implementation-decision-log.md#d-4-extend-the-existing-codex-surface-zero-codex-dependency-or-description-edits)).

- **Packaging:** two surfaces stay in parity — Claude (`.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json`) and Codex (`.codex-plugin/plugin.json` + `.agents/plugins/marketplace.json`). Codex resolves no dependencies, so install guidance names `han-communication` explicitly in both the primary and opt-in Codex paths.
- **Install smoke:** one install of a consuming plugin confirms the new edge resolves the capability.
- **Rollback:** `git revert` per phase; because Phases 1–3 are additive, reverting any of them restores a runnable state, and Phase 4 (the only destructive phase) reverts by restoring the deleted files.
- **Release:** version bumps deferred; `han-core` flagged as a MAJOR candidate (removed public namespaces), applied only under explicit direction ([D-5](artifacts/implementation-decision-log.md#d-5-version-bumps-listed-but-deferred-to-release)).

## Definition of Done

- [ ] `han-communication` exists with both manifests, both marketplace entries, the agent, both existing skills, the new inline `readability-guidance` skill, and both co-located reference files ([D-7](artifacts/implementation-decision-log.md#d-7-han-communication-module-layout)).
- [ ] Exactly the 6 plugins declare the `han-communication` edge; the 4 excluded plugins do not; `han-core` carries its first `dependencies` key ([D-1](artifacts/implementation-decision-log.md#d-1-direct-dependency-edge-list-six-declaring-plugins)).
- [ ] All 13 consumers source the standard via `readability-guidance`; the 9 synthesis dispatches are renamed with the rule-path arg dropped; the 4 draft-and-self-check skills dispatch no editor; gap-analysis's conditional skip survives ([D-3](artifacts/implementation-decision-log.md#d-3-editor-invocation-contract-rename-plus-drop-rule-path-arg)).
- [ ] `find` returns exactly one copy of each reference file; no old qualified name survives outside CHANGELOG/research ([D-2](artifacts/implementation-decision-log.md#d-2-copy-first-delete-last-migration-sequencing)).
- [ ] Docs, indexes, and narration are swept grep-first; the "agents live in han-core" rule names the `han-communication` exception; indexes stay count-free; long-form docs moved and the guidance doc added ([D-6](artifacts/implementation-decision-log.md#d-6-repo-wide-docs-and-narration-sweep-by-grep-with-the-agents-live-in-han-core-exception)).
- [ ] V1–V13 static checks pass and the V6 light smoke confirms same-context sourcing ([D-8](artifacts/implementation-decision-log.md#d-8-manual-verification-static-checks-plus-one-light-smoke-no-ci)).
- [ ] No version bumped; `han-core` recorded as a MAJOR candidate for the release step ([D-5](artifacts/implementation-decision-log.md#d-5-version-bumps-listed-but-deferred-to-release)).

## Specialist Handoffs for Implementation

- **`structural-analyst`** — dispatch if the dependency edge set or the module layout needs re-verification during Phase 1–2; needs the current `plugin.json` inventory.
- **`junior-developer`** — dispatch to run the Phase-5 grep sweep and the agent-home reframe; needs the grep seed list (asset strings, both qualified names, rule paths, dependency-narration phrasing, agent-home phrasing).
- **`test-engineer`** — dispatch to run the per-phase V1–V13 checks and the V6 smoke; needs the on-disk artifacts from two heavy-consumer runs.
- **`han-release`** — dispatch only at Phase 6 under explicit direction; needs the bump-candidate list with `han-core` flagged MAJOR.

## Deferred (YAGNI)

### API-layer fault-injection harness for `api_retry`
- **Why deferred:** Evidence-test failure — the spike frames `api_retry` as a future trigger, not a precondition, and the fault is an infrastructure-level event no sub-agent harness can reliably induce. Building a harness for a fault that cannot be triggered is speculative.
- **Reopen when:** An operator observes a consumer skill early-exiting right after a `readability-guidance` call in real usage.
- **Source:** R1, test-engineer.

### CI / lint / manifest-validator tooling
- **Why deferred:** Evidence-test failure — no such tooling exists in the repo and no incident justifies standing it up as part of this refactor. The manual pre-delete grep gate is the proportionate control for the missed-reference and under-declared-dependency drift class.
- **Reopen when:** The missed-call-site / under-declared-dependency drift (the commit 05d7562 class) recurs.
- **Source:** R1, junior-developer + structural-analyst + devops-engineer.

### Observability / SLO / rollout / alerting machinery
- **Why deferred:** Named anti-pattern — SLOs, alerts, and dashboards for a static Markdown-plus-JSON suite with no runtime or telemetry (the Sentry-on-staging precedent). There is no signal flowing that such machinery could act on.
- **Reopen when:** The suite gains a runtime service or telemetry surface.
- **Source:** R1, devops-engineer + test-engineer.

## Open Items

- **OI-2 (inherited from spec):** Whether a Codex-based agent can dispatch the readability-editor **agent** is unverified.
  - **Resolves when:** A contributor verifies Codex agent-dispatch, independent of this feature.
  - **Blocks implementation:** No — the guidance and skill invocations do not depend on it, and synthesis skills' editor dispatch predates this move.
- **OQ2 (semver, deferred to release):** `han-core` is a MAJOR-bump candidate (removed public namespaces); the bump is a `han-release` decision.
  - **Resolves when:** A user or `han-release` explicitly directs the bumps.
  - **Blocks implementation:** No — the refactor lands unversioned under the standing no-unprompted-bump rule ([D-5](artifacts/implementation-decision-log.md#d-5-version-bumps-listed-but-deferred-to-release)).

## Summary

- **Outcome delivered:** One foundational `han-communication` plugin owns the readability capability and the single canonical writing standard; 13 consumers source it cross-plugin through an inline `readability-guidance` skill, with no duplicated copies and no version bumped.
- **Team size:** 5 specialists — see [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Rounds of facilitation:** 2 — see [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Decisions committed:** 9 (8 full + 1 trivial) — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by evidence:** 7 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by junior-developer reframing:** 0 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by user input:** 0 (user-directed choices were made at spec stage and inherited) — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions deferred to release:** 1 (D-5, version bumps) — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Rejected alternatives recorded:** 21 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Open items remaining:** 2 (OI-2, OQ2) — both non-blocking
- **Recommendation:** Ship as planned.
