# Decision Log: han-communication Plugin

<!--
This file records every decision settled while specifying the han-communication plugin.
Behavioral statements live in [../feature-specification.md](../feature-specification.md);
this file captures the history, rationale, evidence, and rejected alternatives.
-->

## Decision provenance

Settled by **user input** (the user directed the choice): D1, D2, D3, D4, D5, D11 — 6.
Settled by **evidence** (derived from the codebase, repo docs, or review findings): D6, D7, D8, D9, D10 — 5.
Total: 11. (D3, D4, and D11 are user-directed choices that are also evidence-informed; they are counted as user input because the deciding authority was the user's directive.)

## Trivial decisions

These decisions were settled without contention. Each carries the same cross-reference fields as the full decisions so its spec anchor resolves to a real heading.

### D6: Meta-plugin bundles han-communication

- **Decision:** The `han` meta-plugin adds `han-communication` to its `dependencies`, so installing `han` still delivers the readability capability.
- **Rejected alternative:** Leave it out — rejected because `han` promises the full suite and readability is used across it.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Coordinations

### D8: Marketplace and manifest descriptions follow the move

- **Decision:** The Test Double marketplace manifest gains a `han-communication` entry; the new dependency edges are added to each affected `plugin.json`; and every plugin `description` field that narrates the dependency set (`han`, `han-coding`, `han-atlassian`, and the new `han-communication`), plus its mirror in `marketplace.json`, is updated so no description under-states the graph. Adding the marketplace entry is not the only manifest change.
- **Rejected alternative:** Treat the new marketplace entry as the only manifest change — rejected because several `plugin.json` descriptions narrate dependencies in prose and would then contradict the actual dependency arrays ([F14](review-findings.md#f14-d8-wrongly-claims-the-marketplace-entry-is-the-only-manifest-change)).
- **Linked technical notes:** —
- **Driven by findings:** F14
- **Dependent decisions:** —
- **Referenced in spec:** Coordinations

### D9: Invocation contract updates (namespace and editor rule source)

- **Decision:** Invocation sites move from `han-core:readability-editor` / `han-core:edit-for-readability` to the `han-communication:`-qualified names. One further change: the nine synthesis skills that dispatch the editor today pass it a within-plugin rule path (`../../references/readability-rule.md`), which will not resolve once the vendored copies are gone. So the editor no longer takes a caller-supplied rule path — it reads `han-communication`'s own canonical rule by default (it lives in the same plugin). Callers drop the rule-path argument ([F37](review-findings.md#f37-editor-rule-path-argument-breaks-post-move)).
- **Linked technical notes:** —
- **Driven by findings:** F37
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes

## Full decisions

### D1: Introduce han-communication as a foundational plugin

- **Question:** Should the readability capability move into a new plugin, and where does that plugin sit in the dependency graph?
- **Decision:** Create a new plugin, `han-communication`, that depends on nothing. It becomes the foundational layer beneath `han-core` and every other plugin. It hosts the four moved assets plus a new `readability-guidance` skill (D11).
- **Rationale:** The user asked for a dedicated plugin. Making it depend on nothing lets every other plugin depend on it without risking a cycle, and matches the role it plays — shared communication infrastructure the rest of the suite builds on.
- **Evidence:** user input; the readability-editor agent (`han-core/agents/readability-editor.md`) is self-contained (takes the rule path as a parameter, no other han-core cross-references), and the edit-for-readability skill (`han-core/skills/edit-for-readability/SKILL.md`) dispatches the agent by qualified name and passes a within-plugin rule path, so both move cleanly.
- **Rejected alternatives:**
  - Keep the capability in `han-core` — rejected because the user asked for a separate plugin, and a dedicated plugin gives the standard one unambiguous owner.
  - Make `han-communication` depend on `han-core` — rejected because `han-core` skills consume the readability standard, so that direction would create a cycle (see D2).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D2, D3, D5, D6, D11
- **Referenced in spec:** Outcome, Primary Flow

### D2: Move all four assets together

- **Question:** Which assets move into `han-communication` — just the agent and skill, or their reference documents too?
- **Decision:** Move all four together: the `readability-editor` agent, the `edit-for-readability` skill, the readability rule reference, and the writing-voice profile.
- **Rationale:** The reference documents are interdependent with the capability. The readability rule cites the writing-voice profile, and the readability-editor agent applies the writing-voice blocklist. Splitting them across plugins would force a dependency in both directions.
- **Evidence:** user input; `han-core/references/readability-rule.md` references `writing-voice.md`; `han-core/agents/readability-editor.md` line 40 references the writing-voice profile's blocklist.
- **Rejected alternatives:**
  - Move the agent and skill but leave the writing-voice profile canonical in `han-core` — rejected because the readability rule and the agent both depend on the writing-voice profile, so `han-communication` would then depend on `han-core` while `han-core` depends on `han-communication`: a cycle.
  - Move the agent and skill only, leaving both reference documents in `han-core` — rejected because it drops the "move their reference documents" part of the request and leaves the standard's owner split from the capability that applies it.
- **Implementation constraint:** the move must preserve the `skills/{name}/SKILL.md` + `references/{file}.md` two-level layout inside `han-communication`. The edit-for-readability skill reaches the readability rule through a plain filesystem-relative path (`../../references/...`), not a plugin template variable, so flattening or re-nesting the layout would silently break that reference ([F18](review-findings.md#minor-edits)).
- **Linked technical notes:** —
- **Driven by findings:** F18
- **Dependent decisions:** D3
- **Referenced in spec:** Outcome

### D3: Source the standard cross-plugin, not inline

- **Question:** After the move, how do the skills that currently read the readability rule and writing-voice profile from a copy inside their own plugin obtain the standard?
- **Decision:** Stop vendoring copies into consuming plugins. Each consuming skill sources the standard cross-plugin by invoking `han-communication`'s `readability-guidance` skill, which surfaces the rule and voice profile into the calling skill's own context (see D11 for the mechanism), rather than reading a vendored file. The single canonical copy of each reference document lives only in `han-communication`.
- **Rationale:** The plugin runtime has no supported way for a skill to read a *file* inside a declared dependency plugin — `${CLAUDE_PLUGIN_ROOT}` and relative paths resolve only within the reading plugin. But a skill invoked via the Skill tool runs in the **same context** as its caller, so a guidance skill can read `han-communication`'s own reference files and surface their content into the caller — a cross-plugin *skill* invocation, which the runtime does support and the plan already relies on for the editor. This lets skills keep applying the standard while they draft, sourced cross-plugin, without vendoring.
- **Evidence:** research — same-context skill composition is documented, and `han-plugin-builder/skills/guidance` is an in-repo precedent for a resource-surfacing skill (see [readability-guidance-research.md](readability-guidance-research.md)); the readability rule and writing-voice profile are currently vendored byte-identical into `han-coding/references/`, `han-github/references/`, and `han-reporting/references/` alongside the `han-core/references/` canonical copies (verified byte-identical, no copies elsewhere); the own-plugin-only scoping of file paths is an inference from consistent repo usage plus the absence of any documented cross-plugin file-read mechanism ([F22](review-findings.md#minor-edits)).
- **Rejected alternatives:**
  - Keep vendoring byte-identical copies into each consuming plugin — rejected; it preserves the duplication the move is meant to remove.
  - Reference the canonical copy cross-plugin by file path — rejected because the runtime does not support reading a dependency plugin's files by path.
  - Full delegation to a single editor rewrite, dropping in-voice drafting — the earlier decision, now superseded (see D4/D11): it collapses the suite's staged application model and forces a rewrite pass on skills that never had one.
- **Linked technical notes:** —
- **Driven by findings:** F22
- **Dependent decisions:** D4, D11
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States

### D4: Preserve the staged model (guidance plus editor for synthesis)

- **Question:** Once the standard is sourced cross-plugin (D3), how is it *applied* — as a single rewrite over the finished draft, or in the suite's existing stages?
- **Decision:** Preserve the suite's staged application model. All thirteen consumer skills source the standard through `readability-guidance` and apply it in the same stages as before: the output template, in-voice drafting, and the self-check. The nine synthesis skills additionally dispatch the readability-editor for the adversarial rewrite — exactly as the standard already reserves that pass for synthesis skills — now targeting `han-communication`. The four draft-and-self-check-only skills (issue-triage, architectural-decision-record, runbook, html-summary) run no rewrite, as today.
- **Rationale:** The suite's own standard says the rule is "applied in stages, never as one block," that "loading is not compliance," and that the rewrite is reserved for synthesis skills on a self-evaluation-bias rationale (the editor is adversarial toward the draft). Full delegation — the earlier decision — collapsed those stages into one rewrite only because there was no way to source the drafting-stage standard cross-plugin. D3's guidance skill removes that constraint, so the staged model is kept. This also rehabilitates the hybrid the review had rejected ([F3](team-findings.md#f3-no-middle-path-was-overstated)); its only blocker — sourcing the writing-voice blocklist cross-plugin — is exactly what the guidance skill now solves.
- **Evidence:** research (see [readability-guidance-research.md](readability-guidance-research.md)); `docs/readability.md` documents the four-stage model and the "applied in stages, never as one block" / "loading is not compliance" rules; `CONTRIBUTING.md:73` scopes the rewrite to synthesis skills; the editor's own prompt is adversarial toward the draft; 13/13 consumers draft in-voice + self-check today, 9 also dispatch the editor, 4 run no rewrite.
- **Rejected alternatives:**
  - Full delegation to a single editor rewrite for every consumer — superseded: it contradicts the staged model, adds a forced rewrite (and its cost) to the four non-synthesis skills, and removes in-voice drafting. It was chosen earlier only because cross-plugin sourcing seemed impossible; D3/D11 show it is not.
  - Guidance-only for the synthesis skills too (drop the editor rewrite) — rejected: it removes the adversarial pass the suite deliberately reserves for synthesis output, where a skill critiquing its own fresh draft is weakest.
- **Preservation commitment (editor rewrite):** the staged model narrows this risk sharply — runbook, issue-triage, and ADR no longer go through the editor at all, so the acute "editor reorders a runbook's steps" case is removed. The commitment still binds the editor rewrite wherever a **synthesis** skill's output carries order-significant content: the rewrite touches only surrounding prose, and must not reorder, renumber, split, or merge numbered procedure steps (including steps whose number is in a heading), must keep numeric cross-references consistent, must preserve the order of any list whose sequence is operationally load-bearing even when unnumbered, and must leave non-prose structure — code, commands, markup, diagrams, layout — unchanged. The mechanism (amend the shared rubric or instruct the editor per-dispatch) is deferred to `plan-implementation` ([F12](review-findings.md#f12-the-forced-readability-pass-can-reorder-operationally-sequenced-steps), [F28](review-findings.md#f28-the-preservation-commitment-was-too-narrow)).
- **Linked technical notes:** —
- **Driven by findings:** F1, F2, F3, F12, F28, F33
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States, Out of Scope, Edge Cases and Failure Modes

### D5: Which plugins declare the dependency

- **Question:** Which plugins declare a direct dependency on `han-communication`, and does the plan lean on transitive dependency resolution?
- **Decision:** Every plugin that **hosts** a delegating skill or can **trigger** one by wrapping or bundling another plugin's delegating skill declares a **direct** dependency on `han-communication`. That set is `han-core`, `han-coding`, `han-github`, and `han-reporting` (host delegating skills), the `han` meta-plugin (bundles them), and `han-atlassian` (wraps prose-producing skills from `han-core` and `han-coding`). `han-planning`, `han-linear`, `han-feedback`, and `han-plugin-builder` neither host nor trigger a delegating skill, so they declare nothing. The plan never relies on transitive resolution — a plugin that could reach `han-communication` through a dependency's dependency still declares it directly.
- **Rationale:** The user directed that any plugin relying on `han-communication` declare it directly, so the capability is guaranteed present regardless of whether the plugin loader resolves dependencies transitively. This also removes an internal-consistency wrinkle: with no transitive reliance, `han-planning` is cleanly excluded rather than "excluded unless transitive resolution happens to pull it in."
- **Evidence:** user input (declare directly, no transitive reliance); grep inventory — `han-coding` (architectural-analysis, code-review, investigate, code-overview), `han-core` (research, project-documentation, gap-analysis, issue-triage, architectural-decision-record, runbook), `han-github` (update-pr-description), and `han-reporting` (stakeholder-summary, html-summary) reference the four assets directly; `han-atlassian` wraps prose-producing `han-core`/`han-coding` skills that delegate; `han-planning`, `han-linear`, `han-feedback`, and `han-plugin-builder` reference none and wrap no delegating skill.
- **Rejected alternatives:**
  - Rely on transitive resolution so opt-in plugins reach `han-communication` through `han-core` without naming it — rejected by the user; repo guidance documents only one-level auto-install, so transitive resolution is not a safe assumption, and `han-atlassian` genuinely needs the capability at runtime.
  - Give every plugin a direct dependency — rejected because `han-planning`, `han-linear`, `han-feedback`, and `han-plugin-builder` neither host nor trigger a delegating skill; a direct dependency there would be unearned and misleading.
- **Linked technical notes:** —
- **Driven by findings:** F4
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Edge Cases and Failure Modes, Out of Scope, Coordinations

### D7: Docs, indexes, tooling, and pointers follow the move

- **Question:** What documentation and repo tooling must change when the four assets move?
- **Decision:** The change reaches every surface that names the old home of the four assets or narrates the dependency graph, in five classes:
  1. **Relocated long-form docs.** The agent and skill docs move to `docs/agents/han-communication/` and `docs/skills/han-communication/` (new directories). Their own outbound relative links are rewritten to resolve from the new location — audited exhaustively rather than against a named list, since a single relocating doc links to several siblings (content-auditor, information-architect, adversarial-validator) and at least one cross-plugin target in `han-plugin-builder` guidance ([F17](review-findings.md#minor-edits)).
  2. **Inbound links to those two docs.** Every doc that links to the relocating docs at their `han-core` path is repointed — the inbound links across the agent and skill indexes, `docs/concepts.md`, `docs/readability.md`, and the long-form docs of the consuming skills in `han-coding`, `han-github`, `han-reporting`, and `han-core`.
  3. **Canonical-location pointers and qualified-name strings.** Every pointer to the canonical location of the readability rule or writing-voice profile, and every `han-core:readability-editor` qualified-name string printed in operator docs, updates to `han-communication`. The operator-facing standard hub `docs/readability.md` needs a **partial rewrite**: its vendoring model ("vendored byte-for-byte into every plugin") is abolished and rewritten to the guidance-skill sourcing model. Its staged-application model and its "self-check only" table (issue-triage, runbook, ADR, html-summary) are **preserved** — the revised D4 keeps exactly that staging and that four-skill no-rewrite set, so those parts stay true and must not be rewritten away. **General rule:** any caught file whose content restates the abolished *vendoring* model is rewritten; the *staged-application* model it describes is preserved ([F32](review-findings.md#minor-edits), [F36](review-findings.md#f36-d7-called-the-preserved-staged-model-abolished)).
  4. **Vendoring instructions and tooling that assume vendored copies.** CONTRIBUTING.md's "Wiring the readability standard into a skill" section and CLAUDE.md's "Writing voice" section, "Voice is uniform" convention, and project-map tree comments are **rewritten** (not just repointed) to describe a single canonical copy reached by delegation, with no vendored copies. The CONTRIBUTING/CLAUDE rewrite also states the **standing dependency rule**: any plugin that hosts or triggers a delegating skill declares `han-communication` as a direct dependency, so a future wrapping plugin does not silently break ([F21](review-findings.md#f21-no-standing-convention-protects-future-wrapping-plugins)). CONTRIBUTING.md additionally states the invariant "`han-core` depends on nothing" as a *rule*, which D1 falsifies — that rule is **re-derived**, not just edited (for example, "no plugin except `han-communication` depends on anything outside `han-core` and `han-communication`"), so the logic stays true ([F31](review-findings.md#minor-edits)). This class also covers every repo-maintenance skill, skill-internal template/reference file, and pipeline file that hard-references the rule or profile by path — found by the comprehensive grep below, not a fixed list.
  5. **Dependency-graph narration and plugin enumerations.** Prose that describes which plugins depend on which — including `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `han/README.md`, `docs/concepts.md`, `docs/skills/README.md`, `docs/choosing-a-han-plugin.md`, and the `docs/how-to/` plugin-dependency guides — is updated to include `han-communication` and the new dependency edges; the "which plugin do you need?" guide and the skills index gain `han-communication` entries. Any place that **enumerates the plugins by name** — including `CLAUDE.md`'s project map and its "Indexes stay complete" convention (which lists each plugin's `skills/` directory) — adds `han-communication`, even though such enumerations contain none of the grep-seed patterns ([F38](review-findings.md#minor-edits)). This class is defined by the pattern (prose narrating or enumerating the plugin set), not by the enumerated examples.
- **Method (closes the recurring under-coverage):** Because three successive review passes each found another narration or template file the previous fixed list had missed, classes 3–5 are executed by a **comprehensive grep at implementation time**, not by working the named lists above. The implementer greps the repo for (a) the four asset strings, (b) the `han-core:readability-editor` / `han-core:edit-for-readability` qualified names, (c) any relative or plugin-root path to `readability-rule.md` / `writing-voice.md`, and (d) dependency-narration phrasing (`depends on`, `bundled by`, `pulls in`, `depends on nothing`), then updates every hit except the historical-artifact exclusions below. The named files are non-exhaustive examples that seed the grep, not the scope boundary ([F13](review-findings.md#f13-d7-misses-dependency-graph-narration-in-prose-docs), [F16](review-findings.md#minor-edits), [F17](review-findings.md#minor-edits), [F25](review-findings.md#minor-edits), [F26](review-findings.md#minor-edits), [F27](review-findings.md#minor-edits), [F30](review-findings.md#minor-edits)).
- **Guard:** Historical artifacts are **not** repointed — `CHANGELOG.md` and `docs/research/**` describe point-in-time state and must keep it. A new CHANGELOG entry records the extraction instead.
- **Rationale:** The suite's convention is one canonical long-form doc per skill and per agent, complete indexes, up-to-date cross-references, and a project map that matches disk. A pointer relabel is not enough where a doc teaches the vendoring procedure the move abolishes: left intact, CONTRIBUTING.md would keep instructing contributors to re-vendor a copy, reintroducing the duplication the feature removes.
- **Evidence:** CLAUDE.md documents the canonical-source and index conventions and currently names `han-core/references/` as canonical plus vendored copies in three plugins; long-form docs currently live at `docs/agents/han-core/readability-editor.md` and `docs/skills/han-core/edit-for-readability.md`; the full stale-pointer and tooling inventory is recorded across findings F6–F10 in [team-findings.md](team-findings.md).
- **Rejected alternatives:**
  - Repoint links only, without rewriting the vendoring instructions — rejected because CONTRIBUTING.md and CLAUDE.md would then teach a workflow the architecture no longer supports ([F6](team-findings.md#f6-contributingmd-teaches-vendoring-the-move-abolishes), [F7](team-findings.md#f7-claudemd-asserts-vendored-copies-that-will-be-deleted)).
  - Blanket grep-and-replace across the whole repo — rejected because it would corrupt CHANGELOG and research history.
- **Linked technical notes:** —
- **Driven by findings:** F6, F7, F8, F9, F10, F13, F16, F17, F21, F25, F26, F27, F30, F31, F32
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes

### D10: Codex packaging parity

- **Question:** The suite ships a parallel Codex packaging surface alongside the primary one. How does `han-communication` reach Codex-based installs?
- **Decision:** `han-communication` gets Codex **packaging** parity: a `.codex-plugin/plugin.json` manifest, an entry in the Codex marketplace catalog (`.agents/plugins/marketplace.json`), and a line in the README's Codex install instructions. Because the Codex `plugin.json` manifests carry no `dependencies` field, the plan does not assume Codex resolves dependencies — the README Codex install guidance names `han-communication` explicitly. That naming must appear in **both** Codex install paths: the primary command block and the opt-in-plugin sentence, since `han-atlassian` (the one opt-in plugin that needs the capability) is installed through the opt-in path. "Parity" here means file-and-manifest parity with the existing per-plugin Codex pattern; it does not claim confirmed agent-dispatch behavior on Codex, which is separately unverified ([OI-2](../feature-specification.md#open-items)) and pre-existing.
- **Rationale:** Every non-meta plugin already ships a `.codex-plugin/plugin.json`, and the Codex marketplace and README install section list plugins individually. Omitting `han-communication` there would leave Codex installs of the readability-consuming plugins unable to resolve the delegated capability — the same broken-install state the primary-loader edge case forbids, but reached through a surface the earlier scope never touched.
- **Evidence:** `.codex-plugin/plugin.json` exists for han-atlassian, han-coding, han-core, han-feedback, han-github, han-planning, han-plugin-builder, han-reporting (verified via `find`); `.agents/plugins/marketplace.json` exists; the Codex `plugin.json` schema in-repo carries no `dependencies` key; `README.md`'s Codex section lists per-plugin `codex plugin add` commands.
- **Rejected alternatives:**
  - Assume Codex resolves dependencies like the primary loader — rejected because the Codex manifests declare no dependencies, so there is nothing to resolve; the capability must be installed explicitly.
  - Skip Codex parity — rejected because it leaves Codex installs of six plugins with an unresolvable delegation target ([F15](review-findings.md#f15-the-codex-packaging-surface-is-entirely-unaddressed)).
- **Linked technical notes:** —
- **Driven by findings:** F15, F29
- **Dependent decisions:** —
- **Referenced in spec:** Actors and Triggers, Edge Cases and Failure Modes, Coordinations, Open Items

### D11: Source the standard through a readability-guidance skill

- **Question:** What concrete mechanism sources the standard cross-plugin so consumer skills can draft in voice (D3), without vendoring and without a forced editor rewrite (D4)?
- **Decision:** `han-communication` exposes a new `readability-guidance` skill. A consumer skill invokes it by qualified name at the point it begins producing prose; because a skill invoked via the Skill tool runs in the same context, `readability-guidance` reads `han-communication`'s own canonical `readability-rule.md` and `writing-voice.md` and surfaces them into the calling skill's context. It surfaces the guidance in stages (the drafting-stage audience frame, then the self-check criteria) rather than dumping the full text as one block, matching the suite's "applied in stages, never as one block" rule and the resource-surfacing pattern the `han-plugin-builder:guidance` skill already uses.
- **Rationale:** This is the mechanism that makes D3/D4 possible with existing runtime features. It reuses the one supported cross-plugin composition primitive (qualified-name skill invocation, same as the editor), keeps the single canonical copy in `han-communication`, and restores in-voice drafting that vendoring previously provided.
- **Evidence:** research (see [readability-guidance-research.md](readability-guidance-research.md)) — same-context skill composition is documented in the Claude Code docs; `han-plugin-builder/skills/guidance/SKILL.md:25-57` is a *partial* precedent (a skill that reads its own `references/` and applies them, though invoked directly to answer a standalone question, not mid-workflow to hand control back); cross-plugin skill invocation is supported (e.g. `han-atlassian` invokes core/coding skills by qualified name), but the repo's `skill-composition.md` advises against the data-fetch shape this decision uses (see Known risk).
- **Known risk (repo composition guidance):** `han-plugin-builder/.../skill-composition.md` classifies "call a sub-skill to fetch reference content for the caller to use immediately" as **data-fetch composition** and advises inline duplication instead, citing a forked-sub-skill early-exit failure that instruction tuning does not reliably fix. `readability-guidance` is that shape, so this decision is **conditional on the OI-3 spike**. The mitigating design distinction: the documented failure is for `context: fork` sub-skills that return a value; `readability-guidance` is **inline (no fork)** and surfaces content into the shared context rather than returning it. An in-session prototype of the inline variant resumed 3/3 (weak signal only). If the rigorous spike disproves the failure for the inline variant, `skill-composition.md` is updated to record it as a supported exception; if not, the plan falls back (D4's editor-only full delegation, or vendoring the rule for the four non-synthesis skills).
- **Rejected alternatives:**
  - Have the guidance skill dump the full rule and voice profile in one block — rejected because `docs/readability.md` warns that stacking the standard "as one block" reproduces the failure it exists to dodge; the guidance is surfaced per stage.
  - Use a forked (`context: fork`) guidance sub-skill — rejected because that is exactly the shape `skill-composition.md` documents as unreliable; the skill is inline.
  - Skip the guidance skill and keep full delegation (editor-only) — the fallback if the spike fails, not adopted now (D4).
- **Prototype gate:** the mechanism runs against the repo's composition guidance, so the `plan-implementation` spike must go beyond "content appears in context": a realistic heavy consumer, many runs, induced `api_retry`, and an inline-vs-forked comparison, gating the full rollout ([OI-3](../feature-specification.md#open-items)).
- **Documentation:** as a new skill, `readability-guidance` gets its own long-form doc under `docs/skills/han-communication/` and an entry in the skills index, per the suite's one-doc-per-skill convention; and every consumer skill's drafting section is rewired from "read the vendored rule file" to "invoke `han-communication:readability-guidance`" (this is the D7 documentation-and-tooling scope applied to the new mechanism).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Out of Scope, Open Items
