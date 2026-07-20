# Decision Log: Plugin-Centric Documentation Reorganization

This file records every decision settled while specifying the plugin-centric documentation reorganization. Behavioral
statements live in [../feature-specification.md](../feature-specification.md); this file captures the history, rationale,
evidence, and rejected alternatives for each decision.

## Trivial decisions

- D2: Every plugin gets a README front door — each plugin directory carries a `README.md` describing that plugin and
  listing its components. — Referenced in spec: Outcome, Primary Flow.
- D7: Mermaid flow diagrams are in scope — the workflows page shows composition scenarios as flow diagrams (considered
  omitting diagrams; rejected because the user asked to include them). — Referenced in spec: Primary Flow, Coordinations,
  Deferred (YAGNI).
- D10: Historical archives are left unchanged — the plan and research archives under `docs/plans/` and `docs/research/`
  keep their original paths (considered rewriting their stale doc links; rejected because they are point-in-time
  records). — Referenced in spec: Edge Cases and Failure Modes, Out of Scope.
- D11: The reorganization is docs-only — no `SKILL.md` body, agent definition, or skill behavior changes (considered
  folding in small skill fixes; rejected because it would widen an already-broad move). — Referenced in spec: Out of
  Scope.
- D12: `han-core`'s README keeps grouping its skills by purpose — matching the current skills index (considered a flat
  list like the other plugins; rejected because `han-core` ships enough skills to warrant grouping). — Referenced in
  spec: Open Items.

## Full decisions

### D1: Long-form docs move into each plugin directory

- **Question:** Where do the relocated skill and agent long-form docs live once they leave the repository-root `docs/`
  folder?
- **Decision:** Each long-form doc lives inside the plugin it describes, at `{plugin}/docs/skills/{name}.md` for skills
  and `{plugin}/docs/agents/{name}.md` for agents. Only `han-core` and `han-communication` gain a `docs/agents/`
  subfolder, because they are the only plugins that own agents.
- **Rationale:** The doc sits next to the plugin it documents, which is the "close to the plugin" outcome the issue
  asks for. It matches how the plugin README already lives in the plugin directory. Keeping the `skills/` and `agents/`
  split inside the plugin folder avoids mixing `han-core`'s many skill and agent docs in one flat directory.
- **Evidence:** user input; the existing plugin-README convention that a plugin's `README.md` lives in the plugin root
  for human readers and is not loaded by the plugin system (`docs/plugin-readme.md`).
- **Rejected alternatives:**
  - Keep the docs under the repository-root `docs/` folder — rejected because the issue and the user decided the docs
    move out to sit close to their plugins.
  - Flat per-plugin `docs/{name}.md` with no skills/agents split — rejected because `han-core` would then mix seven
    skill docs and twenty-three agent docs in one directory.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D3, D5, D9
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States

### D3: Per-plugin README is a light front door

- **Question:** How deep should each per-plugin README be, so it does not duplicate the long-form docs and break the
  "one canonical source per concept" convention?
- **Decision:** Each README is a light front door: what the plugin does, how, and why, followed by a scent-line list of
  its skills and agents, each linking to that component's long-form doc. The README does not carry the per-skill
  paragraph, files line, and example-prompt blocks that would restate the long-form doc.
- **Rationale:** The long-form doc stays the single canonical source. A light README gives the reader orientation and a
  path into the canonical doc without a second copy of the same content to maintain.
- **Evidence:** user input; the "one canonical source per concept" convention in `CLAUDE.md`.
- **Rejected alternatives:**
  - Carry the full Skills Reference blocks from the plugin-README template (paragraph, files line, example prompts per
    skill) — rejected because it duplicates the canonical long-form doc content across two files, the exact concern the
    issue raised.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D4: Plugin index folds into the choosing doc

- **Question:** What becomes the plugin index the issue asks for, mirroring the skills and agents indexes?
- **Decision:** The existing `docs/choosing-a-han-plugin.md` becomes the plugin catalog and keeps its install-decision
  role. It lists every plugin with a link to that plugin's README and walks the install decision in one place. No new
  `docs/plugins/README.md` is created.
- **Rationale:** The choosing doc already catalogs the plugins and helps the reader pick one to install. Folding the
  index role into it keeps one plugin-level doc rather than splitting a catalog from a decision guide that would repeat
  most of the same plugin list.
- **Evidence:** user input; the existing `docs/choosing-a-han-plugin.md`, which already enumerates every plugin and its
  install command.
- **Rejected alternatives:**
  - A new `docs/plugins/README.md` mirroring the skills and agents index files — rejected because it would duplicate
    the plugin list the choosing doc already carries.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow

### D5: Indexes shrink to alphabetized link lists

- **Question:** Do the skills index and agents index stay, and what do they become?
- **Decision:** Both indexes stay as files but shrink to alphabetized lists. Each entry is a one-sentence scent line
  linking to the canonical long-form doc at its new in-plugin location. The current by-purpose grouping and the
  cross-cutting narrative sections leave the indexes.
- **Rationale:** The issue asks the indexes to stay but drop their current size and complexity, becoming an alphabetized
  listing that links into each document. An alphabetized catalog is simple to scan and simple to keep complete.
- **Evidence:** issue #115 (expected behavior: indexes "shrink to an alphabetized listing that links into each relevant
  document"); user input.
- **Rejected alternatives:**
  - Keep the current grouped, section-rich indexes — rejected because the issue wants them slimmer and the per-plugin
    READMEs now carry the plugin-local grouping.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D6
- **Referenced in spec:** Outcome, Primary Flow

### D6: Composition scenarios and diagrams move to a workflows doc

- **Question:** When the indexes shrink, where do their cross-cutting sections go — the "how skills compose" scenarios,
  the sizing summary, and the YAGNI summary — plus the new flow diagrams?
- **Decision:** A new `docs/workflows.md` carries the composition scenarios and the flow diagrams. The sizing and YAGNI
  summaries drop from the indexes and rely on the existing `docs/sizing.md` and `docs/yagni.md`, which already cover
  them in full.
- **Rationale:** Composition scenarios span several plugins (a plan-then-build-then-review chain crosses three), so a
  single cross-cutting home reads better than fragments spread across per-plugin READMEs. The workflows page is the
  natural home for the flow diagrams that illustrate those chains. Sizing and YAGNI already have dedicated canonical
  docs, so the index summaries were redundant.
- **Evidence:** user input; the existing `docs/sizing.md` and `docs/yagni.md`; the current "How skills compose" section
  in `docs/skills/README.md`.
- **Rejected alternatives:**
  - Fold the scenarios and diagrams into `docs/concepts.md` — rejected to keep concepts purely the skill-and-agent
    model rather than a workflow catalog.
  - Push composition guidance into each plugin's README — rejected because it fragments cross-plugin flows across
    several files.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Coordinations

### D8: Plugins without agents omit the owned-agents section

- **Question:** What does a plugin README list for a plugin that ships no agents of its own?
- **Decision:** A plugin that owns no agents (every plugin except `han-core` and `han-communication`) omits an
  owned-agents section from its README and instead notes that its skills dispatch agents that live in `han-core`.
- **Rationale:** Listing shared agents as if the plugin owned them would misstate ownership and duplicate the agents
  index. A short note that the skills dispatch `han-core` agents tells the reader what happens without claiming
  ownership.
- **Evidence:** the existing plugin-README rule to include only entity sections the plugin has (`docs/plugin-readme.md`);
  `CLAUDE.md`, which records that `han-core` owns every agent except the readability-editor.
- **Rejected alternatives:**
  - List the dispatched `han-core` agents in each plugin's README — rejected because it duplicates the agents index and
    misstates which plugin owns the agents.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States

### D9: Layout descriptions and tooling updated to new paths

- **Question:** Which reader-facing guidance and tooling has to change when the docs move, and what is the consistency
  requirement?
- **Decision:** Every reader-facing description of the documentation layout and every path reference to the old doc
  locations is updated to the new in-plugin locations. This covers the repository-root `README.md`, `CLAUDE.md`,
  `CONTRIBUTING.md`, the coverage rule, the skill and agent long-form templates, the skills and agents indexes, the
  plugin catalog, and the documentation-maintenance tooling.
- **Rationale:** A move that leaves the layout descriptions and audit tooling pointing at the old paths produces broken
  links and a documentation audit that checks files that no longer exist. The descriptions must match the on-disk
  locations for the reorganization to be coherent.
- **Evidence:** the blast-radius scan of active files referencing `docs/skills/` and `docs/agents/` (the two indexes,
  `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `docs/how-to/README.md`, `docs/templates/coverage-rule.md`, the PR
  template, and the `han-update-documentation` maintenance skill).
- **Rejected alternatives:**
  - Update only the indexes and leave the layout descriptions for a follow-up — rejected because the stale descriptions
    would contradict the new structure the moment it lands.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes, Coordinations
