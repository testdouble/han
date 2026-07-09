# Decision Log: han-communication Plugin

<!--
This file records every decision settled while specifying the han-communication plugin.
Behavioral statements live in [../feature-specification.md](../feature-specification.md);
this file captures the history, rationale, evidence, and rejected alternatives.
-->

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

### D9: Qualified-name contract changes namespace only

- **Decision:** Invocation sites move from `han-core:readability-editor` / `han-core:edit-for-readability` to the `han-communication:`-qualified names; the invocation contract is otherwise unchanged.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes

## Full decisions

### D1: Introduce han-communication as a foundational plugin

- **Question:** Should the readability capability move into a new plugin, and where does that plugin sit in the dependency graph?
- **Decision:** Create a new plugin, `han-communication`, that depends on nothing. It becomes the foundational layer beneath `han-core` and every other plugin.
- **Rationale:** The user asked for a dedicated plugin. Making it depend on nothing lets every other plugin depend on it without risking a cycle, and matches the role it plays — shared communication infrastructure the rest of the suite builds on.
- **Evidence:** user input; the readability-editor agent (`han-core/agents/readability-editor.md`) is self-contained (takes the rule path as a parameter, no other han-core cross-references), and the edit-for-readability skill (`han-core/skills/edit-for-readability/SKILL.md`) dispatches the agent by qualified name and passes a within-plugin rule path, so both move cleanly.
- **Rejected alternatives:**
  - Keep the capability in `han-core` — rejected because the user asked for a separate plugin, and a dedicated plugin gives the standard one unambiguous owner.
  - Make `han-communication` depend on `han-core` — rejected because `han-core` skills consume the readability standard, so that direction would create a cycle (see D2).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D2, D3, D5, D6
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

### D3: Delegate rather than inline the standard

- **Question:** After the move, how do the skills that currently read the readability rule and writing-voice profile from a copy inside their own plugin use the standard?
- **Decision:** Stop vendoring copies into consuming plugins. Each consuming skill stops reading the reference files inline and instead delegates readability and voice enforcement to `han-communication` by invoking the `edit-for-readability` skill or dispatching the `readability-editor` agent. The single canonical copy of each reference document lives only in `han-communication`.
- **Rationale:** The plugin runtime has no supported way for a skill to read a file inside a declared dependency plugin — `${CLAUDE_PLUGIN_ROOT}` resolves only to the reading plugin's own install directory. With no vendored copy and no cross-plugin path, delegation is the only way a consuming skill can apply a standard owned by another plugin. The user chose delegation over keeping vendored copies.
- **Evidence:** user input; the readability rule and writing-voice profile are currently vendored byte-identical into `han-coding/references/`, `han-github/references/`, and `han-reporting/references/` alongside the `han-core/references/` canonical copies (verified: all four copies of each file are byte-identical, and no copies exist elsewhere). The own-plugin-only scoping of `${CLAUDE_PLUGIN_ROOT}` is an inference: `han-plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md` line 109 defines it as "the plugin install directory" and every use in the repo refers to the reading plugin's own tree, but no guidance file states an explicit cross-plugin-read prohibition — the "no supported cross-plugin file read" claim rests on that consistent usage plus the absence of any documented mechanism ([F22](review-findings.md#minor-edits)).
- **Rejected alternatives:**
  - Keep vendoring byte-identical copies into each consuming plugin (canonical in `han-communication`) — rejected by user choice; it preserves the duplication the move is meant to remove.
  - Reference the canonical copy cross-plugin by path — rejected because the runtime does not support reading a dependency plugin's files by path.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D4
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States

### D4: Full delegation replaces inline drafting and self-check

- **Question:** Removing the vendored reference files breaks three distinct inline uses of the standard — applying it while drafting, running the end-of-run self-check, and (for some skills) dispatching the editor rewrite. How do consuming skills apply the standard after the move?
- **Decision:** Full delegation, uniformly. Every prose-producing consuming skill drops both its drafting-time application of the rule and its inline self-check, and instead delegates a single readability-editor / edit-for-readability rewrite pass over its finished output. Skills that already dispatched the editor retarget it to `han-communication`; skills that only drafted-and-self-checked (issue-triage, architectural-decision-record, runbook, html-summary) gain a rewrite dispatch they did not have before.
- **Rationale:** The user chose full delegation for the strongest single source of truth. The readability rule is applied in three inline stages that all read the reference file: an audience frame that shapes drafting, a discrete self-check after drafting, and — layered on top — the editor rewrite. Once the file is neither vendored nor reachable cross-plugin, none of the file-reading stages can run, so delegation to the editor is the only way to keep applying the standard without reintroducing duplicated criteria.
- **Evidence:** user input; the readability rule (`han-core/references/readability-rule.md`) defines the template / audience-frame / self-check stages; skills apply it while drafting (`research/SKILL.md`, `stakeholder-summary/SKILL.md`, `update-pr-description/SKILL.md`, `code-review/SKILL.md` all say they apply the rule "as they write"); about nine skills also run an inline self-check reading `../../references/readability-rule.md`; four (`issue-triage`, `architectural-decision-record`, `runbook`, `html-summary`) run only the drafting guide and self-check and state "This skill runs no rewrite pass."
- **Rejected alternatives:**
  - A hybrid: skills that already dispatch the editor keep delegating, while skills that only self-checked keep a lightweight self-check written as their own skill-native criteria (no new dispatch). Rejected by the user in favor of a single source of truth — skill-native criteria can drift from the canonical rule, and the writing-voice blocklist check would still have to move to the editor because the blocklist lives in the moved file.
  - The earlier "no middle path" framing that treated a rewrite pass as strictly forced — corrected: a hybrid middle path does exist; full delegation is a conscious choice, not a forced one ([F3](team-findings.md#f3-no-middle-path-was-overstated)).
- **Preservation commitment:** because full delegation forces skills that never had a rewrite pass (runbook, issue-triage, ADR, html-summary) through the editor, the delegated pass must preserve every numbered step's position and identity, not merely its relative order. It must not reorder, renumber, split, or merge procedure steps; must preserve step numbers even when the number is carried in a heading (a runbook's `Resolve` steps are numbered headings, not a markdown list, and the editor's rubric otherwise rewrites heading text); must keep numeric cross-references between steps consistent (a `Step N failed` block); must preserve the order of any list whose sequence is operationally load-bearing even when it is not numbered (a likelihood-ranked cause list the steps branch on, a priority-ranked escalation list); and must leave non-prose structure — code, commands, markup, diagrams, and layout — unchanged. The editor already excludes code fences, diagrams, and rendered markup; extending that guarantee to cover step order, heading-borne numerals, splitting/merging, and cross-reference integrity (by amending the shared rubric or instructing the editor per-dispatch) is a mechanism choice deferred to `plan-implementation` ([F12](review-findings.md#f12-the-forced-readability-pass-can-reorder-operationally-sequenced-steps), [F28](review-findings.md#f28-the-preservation-commitment-was-too-narrow)).
- **Linked technical notes:** —
- **Driven by findings:** F1, F2, F3, F12, F28, F33
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Alternate Flows and States, Out of Scope, Edge Cases and Failure Modes

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
  3. **Canonical-location pointers and qualified-name strings.** Every pointer to the canonical location of the readability rule or writing-voice profile, and every `han-core:readability-editor` qualified-name string printed in operator docs, updates to `han-communication`. The operator-facing standard hub `docs/readability.md` is a **rewrite-depth** case, not a relabel: it restates the now-abolished vendoring model and the pre-delegation staged-application model (including a "self-check only" table for issue-triage, runbook, ADR, and html-summary that D4 falsifies), so it is rewritten to the delegation model. **General rule:** any caught file whose content restates the abolished vendoring or staged-application model is rewritten, not just repointed ([F32](review-findings.md#minor-edits)).
  4. **Vendoring instructions and tooling that assume vendored copies.** CONTRIBUTING.md's "Wiring the readability standard into a skill" section and CLAUDE.md's "Writing voice" section, "Voice is uniform" convention, and project-map tree comments are **rewritten** (not just repointed) to describe a single canonical copy reached by delegation, with no vendored copies. The CONTRIBUTING/CLAUDE rewrite also states the **standing dependency rule**: any plugin that hosts or triggers a delegating skill declares `han-communication` as a direct dependency, so a future wrapping plugin does not silently break ([F21](review-findings.md#f21-no-standing-convention-protects-future-wrapping-plugins)). CONTRIBUTING.md additionally states the invariant "`han-core` depends on nothing" as a *rule*, which D1 falsifies — that rule is **re-derived**, not just edited (for example, "no plugin except `han-communication` depends on anything outside `han-core` and `han-communication`"), so the logic stays true ([F31](review-findings.md#minor-edits)). This class also covers every repo-maintenance skill, skill-internal template/reference file, and pipeline file that hard-references the rule or profile by path — found by the comprehensive grep below, not a fixed list.
  5. **Dependency-graph narration.** Prose that describes which plugins depend on which — including `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `han/README.md`, `docs/concepts.md`, `docs/skills/README.md`, `docs/choosing-a-han-plugin.md`, and the `docs/how-to/` plugin-dependency guides — is updated to include `han-communication` and the new dependency edges; the "which plugin do you need?" guide and the skills index gain `han-communication` entries. This class is defined by the pattern (prose narrating the dependency set), not by the enumerated examples.
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
