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

### D8: Marketplace lists han-communication

- **Decision:** The Test Double marketplace manifest gains a `han-communication` entry.
- **Rejected alternative:** Omit it — rejected because a plugin other plugins depend on must be resolvable from the marketplace.
- **Linked technical notes:** —
- **Driven by findings:** —
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
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D3
- **Referenced in spec:** Outcome

### D3: Delegate rather than inline the standard

- **Question:** After the move, how do the skills that currently read the readability rule and writing-voice profile from a copy inside their own plugin use the standard?
- **Decision:** Stop vendoring copies into consuming plugins. Each consuming skill stops reading the reference files inline and instead delegates readability and voice enforcement to `han-communication` by invoking the `edit-for-readability` skill or dispatching the `readability-editor` agent. The single canonical copy of each reference document lives only in `han-communication`.
- **Rationale:** The plugin runtime has no supported way for a skill to read a file inside a declared dependency plugin — `${CLAUDE_PLUGIN_ROOT}` resolves only to the reading plugin's own install directory. With no vendored copy and no cross-plugin path, delegation is the only way a consuming skill can apply a standard owned by another plugin. The user chose delegation over keeping vendored copies.
- **Evidence:** user input; `han-plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md` line 109 documents `${CLAUDE_PLUGIN_ROOT}` as the plugin's own install directory only; the readability rule and writing-voice profile are currently vendored byte-identical into `han-coding/references/`, `han-github/references/`, and `han-reporting/references/` alongside the `han-core/references/` canonical copies.
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
- **Linked technical notes:** —
- **Driven by findings:** F1, F2, F3
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Alternate Flows and States, Out of Scope

### D5: Which plugins declare the dependency

- **Question:** Which plugins declare a direct dependency on `han-communication`?
- **Decision:** `han-core`, `han-coding`, `han-github`, and `han-reporting` declare a direct dependency, plus the `han` meta-plugin. `han-planning` does not. The opt-in plugins `han-atlassian`, `han-linear`, and `han-feedback` receive it transitively through their existing dependency on `han-core`.
- **Rationale:** Only plugins whose skills actually consume the readability capability or reference documents need the dependency. An inventory of every reference to the four assets shows exactly these four plugins touch them; `han-planning` touches none.
- **Evidence:** grep inventory — `han-coding` (architectural-analysis, code-review, investigate, code-overview), `han-core` (research, project-documentation, gap-analysis, issue-triage, architectural-decision-record, runbook), `han-github` (update-pr-description), and `han-reporting` (stakeholder-summary, html-summary) reference the readability-editor agent, the edit-for-readability skill, the readability rule, or the writing-voice profile; `han-planning`, `han-atlassian`, `han-linear`, `han-feedback`, and `han-plugin-builder` reference none of them.
- **Rejected alternatives:**
  - Give every plugin a direct dependency — rejected because `han-planning` and the opt-in plugins do not consume the capability directly; a direct dependency there would be unearned and misleading.
- **Caveat on opt-in plugins:** `han-atlassian` wraps prose-producing skills (project-documentation, investigate, code-overview), so it genuinely needs the capability resolvable at runtime. It receives `han-communication` transitively through `han-core` only if the plugin loader resolves dependencies transitively — unconfirmed ([OI-1](../feature-specification.md#open-items)). If transitive resolution is not guaranteed, each opt-in plugin that wraps a prose skill declares `han-communication` directly. The fallback is cheap, so this does not block the decision ([F4](team-findings.md#f4-transitive-resolution-asserted-as-fact-while-unverified)).
- **Linked technical notes:** —
- **Driven by findings:** F4
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Edge Cases and Failure Modes, Out of Scope, Coordinations

### D7: Docs, indexes, tooling, and pointers follow the move

- **Question:** What documentation and repo tooling must change when the four assets move?
- **Decision:** The change reaches every surface that names the old home of the four assets, in four classes:
  1. **Relocated long-form docs.** The agent and skill docs move to `docs/agents/han-communication/` and `docs/skills/han-communication/` (new directories). Their own outbound relative links (to sibling agent docs like content-auditor and information-architect, and the mutual agent↔skill links) are rewritten to resolve from the new location.
  2. **Inbound links to those two docs.** Every doc that links to the relocating docs at their `han-core` path is repointed — roughly 17 inbound links across the agent and skill indexes, `docs/concepts.md`, `docs/readability.md`, and the long-form docs of the consuming skills in `han-coding`, `han-github`, `han-reporting`, and `han-core`.
  3. **Canonical-location pointers and qualified-name strings.** Every pointer to the canonical location of the readability rule or writing-voice profile, and every `han-core:readability-editor` qualified-name string printed in operator docs (~9 docs), updates to `han-communication`.
  4. **Vendoring instructions and tooling that assume vendored copies.** CONTRIBUTING.md's "Wiring the readability standard into a skill" section and CLAUDE.md's "Writing voice" section, "Voice is uniform" convention, and project-map tree comments are **rewritten** (not just repointed) to describe a single canonical copy reached by delegation, with no vendored copies. The repo-maintenance skills that hard-reference the writing-voice profile by path (`.claude/skills/han-release/references/changelog-rules.md`, `.claude/skills/han-update-documentation`), the five skill-internal template files that hardcode the rule's relative path, and `.github/pull_request_template.md` are updated to the new home or the delegation model.
- **Guard:** Historical artifacts are **not** repointed — `CHANGELOG.md` and `docs/research/**` describe point-in-time state and must keep it. A new CHANGELOG entry records the extraction instead.
- **Rationale:** The suite's convention is one canonical long-form doc per skill and per agent, complete indexes, up-to-date cross-references, and a project map that matches disk. A pointer relabel is not enough where a doc teaches the vendoring procedure the move abolishes: left intact, CONTRIBUTING.md would keep instructing contributors to re-vendor a copy, reintroducing the duplication the feature removes.
- **Evidence:** CLAUDE.md documents the canonical-source and index conventions and currently names `han-core/references/` as canonical plus vendored copies in three plugins; long-form docs currently live at `docs/agents/han-core/readability-editor.md` and `docs/skills/han-core/edit-for-readability.md`; the full stale-pointer and tooling inventory is recorded across findings F6–F10 in [team-findings.md](team-findings.md).
- **Rejected alternatives:**
  - Repoint links only, without rewriting the vendoring instructions — rejected because CONTRIBUTING.md and CLAUDE.md would then teach a workflow the architecture no longer supports ([F6](team-findings.md#f6-contributingmd-teaches-vendoring-the-move-abolishes), [F7](team-findings.md#f7-claudemd-asserts-vendored-copies-that-will-be-deleted)).
  - Blanket grep-and-replace across the whole repo — rejected because it would corrupt CHANGELOG and research history.
- **Linked technical notes:** —
- **Driven by findings:** F6, F7, F8, F9, F10
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes
