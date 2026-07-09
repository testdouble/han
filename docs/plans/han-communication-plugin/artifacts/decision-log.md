# Decision Log: han-communication Plugin

<!--
This file records every decision settled while specifying the han-communication plugin.
Behavioral statements live in [../feature-specification.md](../feature-specification.md);
this file captures the history, rationale, evidence, and rejected alternatives.
-->

## Trivial decisions

- D6: Meta-plugin bundles han-communication — the `han` meta-plugin adds `han-communication` to its `dependencies` so installing `han` still delivers the readability capability (considered leaving it out; rejected because `han` promises the full suite and readability is used across it). — Referenced in spec: Outcome, Coordinations.
- D8: Marketplace lists han-communication — the Test Double marketplace manifest gains a `han-communication` entry (considered omitting it; rejected because a plugin other plugins depend on must be resolvable from the marketplace). — Referenced in spec: Coordinations.
- D9: Qualified-name contract changes namespace only — invocation sites move from `han-core:readability-editor` / `han-core:edit-for-readability` to the `han-communication:`-qualified names; the invocation contract is otherwise unchanged. — Referenced in spec: Edge Cases and Failure Modes.

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

### D4: Self-check skills gain a delegated pass

- **Question:** What happens to skills that apply the standard inline today as a drafting guide and an end-of-run self-check, with deliberately no rewrite pass?
- **Decision:** These skills — issue-triage, architectural-decision-record, runbook, and html-summary — delegate to `han-communication`'s readability capability, which performs an actual rewrite pass. They gain a readability-editor / edit-for-readability dispatch they did not have before.
- **Rationale:** This is forced by D3. Once the reference files are neither vendored nor reachable cross-plugin, an inline self-check that reads the rule is impossible, so the only way to keep applying the standard is to delegate — and delegation runs a rewrite. There is no middle path that keeps "no vendoring."
- **Evidence:** `han-core/skills/issue-triage/SKILL.md`, `han-core/skills/architectural-decision-record/SKILL.md`, `han-core/skills/runbook/SKILL.md`, and `han-reporting/skills/html-summary/SKILL.md` each read `../../references/readability-rule.md` for an inline self-check and state "This skill runs no rewrite pass."
- **Rejected alternatives:**
  - Keep a lightweight inline self-check for these four skills — rejected because it requires a vendored copy of the rule inside each plugin, which contradicts D3.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### D5: Which plugins declare the dependency

- **Question:** Which plugins declare a direct dependency on `han-communication`?
- **Decision:** `han-core`, `han-coding`, `han-github`, and `han-reporting` declare a direct dependency, plus the `han` meta-plugin. `han-planning` does not. The opt-in plugins `han-atlassian`, `han-linear`, and `han-feedback` receive it transitively through their existing dependency on `han-core`.
- **Rationale:** Only plugins whose skills actually consume the readability capability or reference documents need the dependency. An inventory of every reference to the four assets shows exactly these four plugins touch them; `han-planning` touches none.
- **Evidence:** grep inventory — `han-coding` (architectural-analysis, code-review, investigate, code-overview), `han-core` (research, project-documentation, gap-analysis, issue-triage, architectural-decision-record, runbook), `han-github` (update-pr-description), and `han-reporting` (stakeholder-summary, html-summary) reference the readability-editor agent, the edit-for-readability skill, the readability rule, or the writing-voice profile; `han-planning`, `han-atlassian`, `han-linear`, `han-feedback`, and `han-plugin-builder` reference none of them.
- **Rejected alternatives:**
  - Give every plugin a direct dependency — rejected because `han-planning` and the opt-in plugins do not consume the capability directly; a direct dependency there would be unearned and misleading.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Edge Cases and Failure Modes, Out of Scope, Coordinations

### D7: Docs, indexes, and pointers follow the move

- **Question:** What documentation must change when the four assets move?
- **Decision:** The long-form docs for the agent and skill move to `docs/agents/han-communication/` and `docs/skills/han-communication/`; the agent and skill indexes, the CLAUDE.md project map, CONTRIBUTING.md, and every top-level pointer to the canonical location of the readability rule and writing-voice profile update to name `han-communication` as the owner.
- **Rationale:** The suite's convention is one canonical long-form doc per skill and per agent, with complete indexes and up-to-date cross-references. Moving the assets without moving and repointing their docs would leave the indexes and the project map describing a location that no longer holds the canonical copies.
- **Evidence:** CLAUDE.md documents the canonical-source and index conventions and currently names `han-core/references/` as the canonical home of the readability rule and writing-voice profile; long-form docs currently live at `docs/agents/han-core/readability-editor.md` and `docs/skills/han-core/edit-for-readability.md`.
- **Rejected alternatives:**
  - Leave the docs under `han-core` and only update the plugin files — rejected because it breaks the one-canonical-doc-per-plugin convention and leaves the indexes and project map pointing at the wrong owner.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes
