# Implementation Decision Log: han-communication Plugin

<!--
This file records every implementation decision committed while planning the
han-communication plugin refactor. Behavioral and implementation statements live in
[../feature-implementation-plan.md](../feature-implementation-plan.md) — this file
captures the question, rationale, evidence, and rejected alternatives for each decision.
Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).

These implementation decisions execute the spec's committed decisions (D1–D11 in
[decision-log.md](decision-log.md)); each notes the spec decision it implements.
-->

## Decision provenance

Settled by **evidence** (specialist findings verified against the working tree, or codebase inventory): D-1, D-2, D-3, D-4, D-6, D-7, D-8 — 7.
Settled by **deferral to release** (committed choice whose effect is to defer, under the standing no-unprompted-bump rule): D-5 — 1.
Trivial (settled by an OQ resolution with no contention): D-9 — 1.
Total: 9 (8 full + 1 trivial).

No decision was settled by user input during implementation planning; the user-directed choices were made at spec stage (D1–D5, D11 in [decision-log.md](decision-log.md)) and are inherited, not re-decided.

## Trivial decisions

- D-9: han-atlassian Codex co-requisite doc fix — the one-line Codex co-requisite documentation gap for `han-atlassian` (it wraps prose-producing skills but its Codex install guidance never names the co-requisite) is corrected while the Phase-5 docs sweep is already editing that region, rather than left as a known gap ([OQ3 resolution, R2](implementation-iteration-history.md#r2-resolution)). — Referenced in plan: Decomposition and Sequencing.

## Full decisions

### D-1: Direct dependency edge list (six declaring plugins)

- **Question:** Exactly which plugin manifests gain a `han-communication` dependency edge, and which are deliberately left untouched?
- **Decision:** Exactly six Claude `plugin.json` manifests add a direct `han-communication` dependency: `han-core` (hosts 6 consumers plus `edit-for-readability`), `han-coding` (4 consumers), `han-github` (1), `han-reporting` (2), the `han` meta-plugin (bundles the consuming plugins), and `han-atlassian` (wraps 3 prose-producing skills: project-documentation-to-confluence, investigate-to-confluence, code-overview-to-confluence). `han-core` gains its **first-ever** `dependencies` key, with value `["han-communication"]`. `han-planning`, `han-linear`, `han-feedback`, and `han-plugin-builder` add nothing. Zero Codex manifests gain a dependency edge (their schema has no `dependencies` field, see D-4).
- **Rationale:** Every plugin that hosts a delegating skill, or triggers one by wrapping or bundling another plugin's delegating skill, must resolve the capability by qualified name without leaning on transitive resolution. Naming the edge set precisely prevents both under-declaration (a wrapping plugin silently missing the capability) and unearned edges on plugins that touch no delegating skill.
- **Evidence:** structural-analyst re-verified the set from scratch against the working tree and it matches spec [D5](decision-log.md#d5-which-plugins-declare-the-dependency) and the discovery inventory exactly (4+1+2+6 consumers = 13; efferent coupling of `han-communication` is 0, so no cycle); `han-core/.claude-plugin/plugin.json` confirmed to carry no `dependencies` key today (verified `deps None`, version 2.2.1); `han-atlassian`'s dependency array has drifted before (commit 05d7562), marking it the highest-verification-priority edit.
- **Rejected alternatives:**
  - Rely on transitive resolution so opt-in plugins reach the capability through `han-core` — rejected; repo guidance documents only one-level auto-install, and spec D5 (user-directed) forbids transitive reliance.
  - Give every plugin a direct edge for symmetry — rejected; `han-planning`, `han-linear`, `han-feedback`, and `han-plugin-builder` host and trigger no delegating skill, so an edge there would be unearned and misleading (YAGNI: symmetry is not evidence).
- **Specialist owner:** structural-analyst
- **Revisit criterion:** A new plugin begins hosting or wrapping a prose-producing skill, or the plugin loader's transitive-resolution behavior is authoritatively confirmed.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1
- **Dependent decisions:** D-2
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points), Decomposition and Sequencing

### D-2: Copy-first, delete-last migration sequencing

- **Question:** In what order are the create, declare, rewire, and delete steps executed so the suite never has a broken build mid-migration?
- **Decision:** Six ordered phases: (1) create and populate `han-communication` plus both manifests and both marketplace entries — purely additive, the suite still runs on the existing vendored copies; (2) declare the six dependency edges and update dependency-narrating descriptions, before any rewire; (3) rewire the 13 consumers, `edit-for-readability`, and 6 secondary template/reference files; (4) delete the 6 vendored copies and the 4 `han-core` originals **last**, gated on a clean pre-delete grep; (5) sweep docs, indexes, and narration and relocate the long-form docs; (6) release (version bumps) only when explicitly directed (D-5). The pre-delete grep is an explicit gate, not a courtesy check.
- **Rationale:** Deleting or `git mv`-ing an original before its consumers are rewired breaks a working skill the moment the file disappears. Making the migration additive-first means every intermediate state is runnable. The grep gate is elevated to a hard precondition because spec D7 itself records that three successive review passes each found another missed reference — the risk of an orphaned pointer is demonstrated, not hypothetical.
- **Evidence:** junior-developer and devops-engineer converged on this ordering; spec [D7](decision-log.md#d7-docs-indexes-tooling-and-pointers-follow-the-move) records the "three review passes each found another missed file" history that justifies the grep gate; the `.discovery-notes.md` inventory confirms 13 consumers plus 6 secondary template files plus 8 asset files in play, so a wrong order has a wide blast radius.
- **Rejected alternatives:**
  - `git mv` the originals first, then fix consumers — rejected; the suite is broken between the move and the last consumer fix.
  - Delete vendored copies in the same change that adds the new plugin — rejected; consumers still read the vendored paths until Phase 3 rewires them.
  - Trust a manual review instead of a grep gate before deletion — rejected; the documented three-pass miss history shows manual review under-covers.
- **Specialist owner:** devops-engineer
- **Revisit criterion:** A phase's per-phase verification (D-8) fails, forcing a re-order or a rollback via `git revert`.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1
- **Dependent decisions:** D-8
- **Referenced in plan:** Decomposition and Sequencing, Operational Readiness

### D-3: Editor invocation contract (rename plus drop rule-path arg)

- **Question:** When the editor dispatch is rewired, what exactly changes at each call site?
- **Decision:** The rename from `han-core:readability-editor` / `han-core:edit-for-readability` to the `han-communication:`-qualified names, and the dropping of the now-unresolvable `../../references/readability-rule.md` rule-path argument, are executed as **one coupled edit** at each site — the 9 synthesis-skill dispatch sites plus `edit-for-readability` itself (10 sites). The editor reads `han-communication`'s own canonical rule by default, so callers pass no rule path. gap-analysis's size-conditional editor skip (no dispatch at small size) is preserved. The 4 draft-and-self-check skills (runbook, issue-triage, ADR, html-summary) gain the `readability-guidance` invocation but **no** editor dispatch.
- **Rationale:** After the vendored copies are gone, a caller-supplied within-plugin rule path resolves to a deleted file, so the argument must drop in the same edit that renames the namespace — splitting them would leave a window where the site names the new agent but still passes a dead path. Preserving gap-analysis's conditional keeps the staged model's cost profile intact; withholding the editor from the 4 non-synthesis skills preserves the standard's reservation of the adversarial rewrite for synthesis output.
- **Evidence:** implements spec [D9](decision-log.md#d9-invocation-contract-updates-namespace-and-editor-rule-source) (driven by F37); `.discovery-notes.md` §3a lists all 9 dispatch sites with exact line numbers and confirms each passes `../../references/readability-rule.md`; §3c confirms `edit-for-readability` dispatches the editor at line 55 and passes the rule path at line 58; §3b confirms the 4 draft-and-self-check skills run no rewrite; junior-developer flagged the rename-and-drop as a single coupled edit.
- **Rejected alternatives:**
  - Keep the rule-path argument and have the editor accept it — rejected; the path resolves to a file deleted in Phase 4, and spec D9 already retired the argument.
  - Rename namespace and drop the argument in two separate passes — rejected; it creates an intermediate broken-dispatch state.
  - Add an editor dispatch to the 4 draft-and-self-check skills for uniformity — rejected; the staged model deliberately reserves the rewrite for synthesis skills ([spec D4](decision-log.md#d4-preserve-the-staged-model-guidance-plus-editor-for-synthesis)).
- **Specialist owner:** junior-developer
- **Revisit criterion:** The editor agent's default rule-source behavior changes, or a consumer's synthesis/non-synthesis classification changes.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing

### D-4: Extend the existing Codex surface (zero Codex dependency or description edits)

- **Question:** Does `han-communication` build a new Codex packaging surface, and what Codex edits does the refactor make?
- **Decision:** The Codex surface already exists; this refactor **extends** it, it does not build it. Deliverables: CREATE `han-communication/.codex-plugin/plugin.json` mirroring `han-core`'s Codex schema (`skills: "./skills/"`, no `dependencies` field, no description narrating dependencies), and ADD a `han-communication` entry to `.agents/plugins/marketplace.json` (`source: {local, path}`, `policy`, `category` — no description, no dependencies). There are **zero** Codex dependency edits (the schema has no `dependencies` field) and **zero** Codex description edits (no Codex manifest narrates dependencies). The refactor does **not** inherit the pre-existing Codex gaps (`han` meta and `han-linear` have no Codex packaging); those are out of scope. The spec Summary's "a whole Codex packaging surface was added" is reworded to "extended" (wording, not a decision reversal).
- **Rationale:** Treating the Codex surface as greenfield would risk re-deriving deliverables that already exist and are already correct in spec D10. Confirming zero dependency and zero description edits removes two classes of edit the earlier framing might have implied.
- **Evidence:** devops-engineer RECON-1 and `.discovery-notes.md` §6 confirm `.agents/plugins/marketplace.json` plus 8 `.codex-plugin/plugin.json` files exist on an independent version track (verified: catalog lists han-core, han-planning, han-coding, han-github, han-reporting, han-feedback, han-atlassian, han-plugin-builder); OQ1 resolved by grepping all 8 Codex descriptions and the catalog — none narrate dependencies ([R2](implementation-iteration-history.md#r2-resolution)); implements spec [D10](decision-log.md#d10-codex-packaging-parity).
- **Rejected alternatives:**
  - Build the Codex surface as if greenfield — rejected; it already exists (RECON-1).
  - Edit Codex descriptions to narrate the new dependency — rejected; no Codex description narrates dependencies, so there is nothing to correct (OQ1, evidence).
  - Fill the pre-existing `han` meta / `han-linear` Codex gaps in this pass — rejected; they predate this feature and are out of its scope.
- **Specialist owner:** devops-engineer
- **Revisit criterion:** The Codex `plugin.json` schema gains a `dependencies` field, or a Codex manifest begins narrating dependencies.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** —
- **Referenced in plan:** Decomposition and Sequencing, Operational Readiness

### D-5: Version bumps listed but deferred to release

- **Question:** Do the six edited plugins get version bumps as part of this refactor, and what is the semver posture?
- **Decision:** No version is bumped as part of this refactor. The plan **lists** the bump candidates and their posture — `han-core` is a **MAJOR**-bump candidate because the `han-core:readability-editor` and `han-core:edit-for-readability` qualified namespaces are removed (a breaking public-name change per D-3/spec D9) — but **applies** none. The actual bump is a `han-release` decision made at release time under explicit direction. The new `han-communication` plugin receives an **initial authoring version** (its first version, on both the Claude and the independent Codex track), which is authoring, not a bump.
- **Rationale:** The standing rule forbids bumping any plugin version unprompted. Recording `han-core` as a MAJOR candidate now preserves the semver reasoning for the release step without pre-committing the bump.
- **Evidence:** standing no-unprompted-bump rule (project memory; `.discovery-notes.md` §8); current versions inventoried (han-core 2.2.1, han-coding 2.5.1, han-github 2.2.1, han-reporting 2.1.1, han 4.5.1, han-atlassian 2.2.0); the removed namespaces are a breaking change per [D-3](#d-3-editor-invocation-contract-rename-plus-drop-rule-path-arg); OQ2 deferred to release in [R2](implementation-iteration-history.md#r2-resolution).
- **Rejected alternatives:**
  - Apply the version bumps in the same change as the rewire — rejected; violates the standing no-unprompted-bump rule.
  - Bump `han-core` MINOR — rejected as the recorded posture; removing a public qualified namespace is a breaking change and warrants a MAJOR candidate flag (the call itself stays with `han-release`).
- **Specialist owner:** devops-engineer (hands off to `han-release` at release time)
- **Revisit criterion:** A user or the `han-release` skill explicitly directs the version bumps.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** —
- **Referenced in plan:** Operational Readiness, Open Items

### D-6: Repo-wide docs and narration sweep by grep (with the "agents live in han-core" exception)

- **Question:** How is the documentation, index, and narration scope executed so no stale pointer or stale dependency narration survives?
- **Decision:** Classes 3–5 of spec D7 (canonical/qualified-name pointers, vendoring instructions and tooling, dependency-graph narration and plugin enumerations) are executed by a **comprehensive grep at implementation time**, not by working a fixed list. The grep seeds are extended beyond spec D7's set to include an **agent-home seed**: CONTRIBUTING.md and CLAUDE.md state "all agents live in han-core" in roughly four places, and `han-communication` is the first plugin to host an agent outside `han-core` — that rule is reframed to name the `han-communication` exception, not just repointed. Indexes stay **count-free** (fix any hardcoded totals; add `han-communication` entries). The `CHANGELOG.md` and `docs/research/**` historical artifacts are **not** repointed; a new CHANGELOG entry records the extraction. The two long-form docs move to `docs/agents/han-communication/` and `docs/skills/han-communication/`, and a new `readability-guidance` long-form doc is added (with one troubleshooting sentence noting the `api_retry` residual risk).
- **Rationale:** Spec D7 already mandates a grep-driven sweep because fixed lists under-covered three times. The `han-communication`-hosts-an-agent fact falsifies a second invariant ("all agents live in han-core") that spec D7's grep seeds catch only once, so the seed set must be widened or the rule stays half-true. Count-free indexes and the historical-artifact guard are existing repo conventions.
- **Evidence:** implements spec [D7](decision-log.md#d7-docs-indexes-tooling-and-pointers-follow-the-move); junior-developer found the "agents live in han-core" rule stated in ~4 places with only 1 caught by spec D7's current seeds; `.discovery-notes.md` §7 inventories the stale-pointer surface (CLAUDE.md, CONTRIBUTING.md, docs/readability.md, both indexes, how-to guides); project memory carries the count-free-index and no-Claude-attribution conventions; spec D7's guard excludes CHANGELOG and docs/research.
- **Rejected alternatives:**
  - Work the named file list from spec D7 rather than a fresh grep — rejected; three prior passes each missed a file, so the list is known-incomplete.
  - Repoint the "agents live in han-core" rule without reframing it to the exception — rejected; a bare repoint would still assert a now-false invariant.
  - Blanket grep-and-replace across the whole repo — rejected; it corrupts CHANGELOG and research history.
- **Specialist owner:** junior-developer (docs), with information-architect available for the index restructure
- **Revisit criterion:** The grep sweep surfaces a narration class not covered by the current seeds (add a seed and re-run).
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Decomposition and Sequencing

### D-7: han-communication module layout

- **Question:** What is the on-disk layout of the new plugin, and does it co-locate the skill and agent?
- **Decision:** `han-communication/` holds: `.claude-plugin/plugin.json` (no `dependencies` key), `.codex-plugin/plugin.json` (Codex schema, no dependencies field), `agents/readability-editor.md`, `skills/readability-guidance/SKILL.md` (new, inline), `skills/edit-for-readability/SKILL.md`, and `references/readability-rule.md` + `references/writing-voice.md` co-located in one `references/` directory. This makes `han-communication` the **first** plugin to co-locate a skill and an agent outside `han-core` — a new plugin category. The two-level `skills/{name}/SKILL.md` + `references/{file}.md` layout is preserved so `edit-for-readability`'s filesystem-relative `../../references/...` path to the rule keeps resolving.
- **Rationale:** The reference documents are interdependent (`readability-rule.md` links `writing-voice.md` by a same-directory relative link), so they must stay co-located. `edit-for-readability` reaches the rule by a plain relative path, not a plugin template variable, so flattening or re-nesting silently breaks that reference. `han-communication` depends on nothing, so its Claude manifest carries no `dependencies` key at all.
- **Evidence:** implements spec [D2](decision-log.md#d2-move-all-four-assets-together); `.discovery-notes.md` §1–2 confirm `readability-rule.md` line 41 links `writing-voice.md` by same-directory relative link and `edit-for-readability` SKILL.md line 58 reaches the rule at `../../references/readability-rule.md`; structural-analyst confirmed efferent coupling 0 and the new-category observation.
- **Rejected alternatives:**
  - Flatten the references into the plugin root or re-nest them under the skill — rejected; it breaks the `../../references/...` relative path and the intra-references link.
  - Split the writing-voice profile into a separate plugin — rejected; the rule and the agent both depend on it, which would force a bidirectional dependency (spec D2).
- **Specialist owner:** structural-analyst
- **Revisit criterion:** A second agent-hosting non-core plugin is introduced, prompting a reusable layout convention.
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1
- **Dependent decisions:** D-1, D-3
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points)

### D-8: Manual verification (static checks plus one light smoke, no CI)

- **Question:** How is the refactor verified with no test runner, linter, or CI in the repo?
- **Decision:** Verification is manual and per-phase: static grep/diff/`jq` checks V1–V13 (sourcing relocated in all 13 consumers; self-check blocks byte-identical pre/post; 9 editor dispatches renamed with the rule-path arg dropped; 4 no-editor skills confirmed; `find readability-rule.md` and `find writing-voice.md` each return exactly 1 after Phase 4 delete; no `han-core:readability-editor` / `han-core:edit-for-readability` names remain outside CHANGELOG and docs/research; the 6 dependency edges present and the 4 excluded plugins absent; both marketplaces carry the entry; doc pointers repointed; CHANGELOG/docs/research untouched), plus one **light** dynamic smoke (V6): 2 real heavy consumers (for example `investigate` or `architectural-analysis`, and `runbook`), 2 runs each, judged from on-disk artifacts, confirming the `readability-guidance` skill ran as a same-context Skill call with no `context: fork`. The 46-trial OI-3 spike is **not** re-run (its risk is retired by [T1](feature-technical-notes.md#t1-same-context-composition-the-guidance-skill-is-inline-not-forked)). One install smoke test and `git revert` per phase cover packaging and rollback.
- **Rationale:** The repo has no build system, test harness, or linter, so validation is inherently static-plus-inspection. The light smoke exists only to confirm the same-context (inline) property in real usage; re-running the full spike would re-pay a cost T1 already retired.
- **Evidence:** test-engineer defined V1–V13 and the V6 smoke; `.discovery-notes.md` §8 confirms no build system, no test harness, no linter, no CI workflow; T1 records the inline property validated across 34/34 same-context runs; the `api_retry` residual risk is accepted as documented (one troubleshooting sentence in the guidance long-form doc), with no fault-injection harness built (see Deferred/YAGNI in the plan).
- **Rejected alternatives:**
  - Re-run the 46-trial spike — rejected; the inline-vs-forked risk is retired by T1, so re-running re-pays a settled cost.
  - Build a CI/lint/manifest-validator as part of this refactor — rejected; no such tooling exists and no incident justifies standing it up now (YAGNI); the manual pre-delete grep gate is the proportionate control.
  - Build an API-layer fault-injection harness to force `api_retry` — rejected; the spike frames it as a future trigger, not a precondition, and the fault cannot be reliably induced (YAGNI).
- **Specialist owner:** test-engineer
- **Revisit criterion:** The suite gains a build/test/CI surface, or an operator observes a consumer early-exiting right after a `readability-guidance` call in real usage (reopens the fault-injection harness).
- **Dissent (if any):** None recorded.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Testing Strategy, Decomposition and Sequencing
