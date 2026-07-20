# Decision Log: Plugin-Centric Documentation Reorganization

This file records every decision settled while specifying the plugin-centric documentation reorganization. Behavioral
statements live in [../feature-specification.md](../feature-specification.md); this file captures the history, rationale,
evidence, and rejected alternatives for each decision.

## Trivial decisions

- D2: Every plugin gets a README front door — each plugin directory carries a `README.md` describing that plugin and
  listing its components. — Referenced in spec: Outcome, Primary Flow.
- D7: Mermaid flow diagrams are in scope — the workflows page shows composition scenarios as flow diagrams where a chain
  warrants one (considered omitting diagrams; rejected because the user asked to include them). — Referenced in spec:
  Primary Flow, Coordinations, Deferred (YAGNI).
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
  subfolder, because they are the only plugins that own agents. These docs ship inside the installed plugin, the same way
  the plugin README already does; they are for human readers and are not loaded by the plugin system. The move trades the
  single `docs/skills/` tree for proximity to each plugin, and the indexes become the cross-plugin entry point.
- **Rationale:** The doc sits next to the plugin it documents, which is the "close to the plugin" outcome the issue
  asks for. It matches how the plugin README already lives in the plugin directory. Keeping the `skills/` and `agents/`
  split inside the plugin folder avoids mixing `han-core`'s many skill and agent docs in one flat directory.
- **Evidence:** user input; the existing plugin-README convention that a plugin's `README.md` lives in the plugin root
  for human readers and is not loaded by the plugin system (`docs/plugin-readme.md:3-11`).
- **Rejected alternatives:**
  - Keep the docs under the repository-root `docs/` folder — rejected because the issue and the user decided the docs
    move out to sit close to their plugins.
  - Flat per-plugin `docs/{name}.md` with no skills/agents split — rejected because `han-core` would then mix seven
    skill docs and twenty-three agent docs in one directory.
- **Linked technical notes:** —
- **Driven by findings:** F13
- **Dependent decisions:** D3, D5, D9, D14, D16
- **Referenced in spec:** Outcome, Primary Flow, Out of Scope

### D3: Per-plugin README is the canonical plugin front door

- **Question:** How deep should each per-plugin README be, so it does not duplicate the long-form docs and so the plugin
  itself has one canonical description?
- **Decision:** Each README is a light front door and the single canonical source for what its plugin does, how, and why:
  a short what/how/why, then a scent-line list of its skills and agents, each linking to that component's long-form doc.
  The README does not carry the per-skill paragraph, files line, and example-prompt blocks that would restate the
  long-form doc. The other surfaces that name a plugin's purpose (the root README table, the plugin index) carry a scent
  line and a link, not a second description.
- **Rationale:** The long-form doc stays canonical for each skill or agent, and the README stays canonical for the
  plugin. A light README gives the reader orientation and a path into the canonical docs without a second copy of the
  same content to maintain.
- **Evidence:** user input; the "one canonical source per concept" convention in `CLAUDE.md`.
- **Rejected alternatives:**
  - Carry the full Skills Reference blocks from the plugin-README template (paragraph, files line, example prompts per
    skill) — rejected because it duplicates the canonical long-form doc content across two files, the exact concern the
    issue raised.
- **Linked technical notes:** —
- **Driven by findings:** F1, F6
- **Dependent decisions:** D4, D18
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D4: The choosing doc becomes the plugin index

- **Question:** What becomes the plugin index the issue asks for, mirroring the skills and agents indexes?
- **Decision:** The existing `docs/choosing-a-han-plugin.md` becomes the plugin index and keeps its install-decision
  role. It lists every plugin with a one-line scent and a link to that plugin's README, and walks the install decision in
  one place. It does not restate each plugin's full purpose or deep-link every skill; the plugin README owns the purpose
  and the skills index owns the per-skill scent. The root README and both indexes label this doc as the plugin index so
  the three-index mental model resolves. No new `docs/plugins/README.md` is created.
- **Rationale:** The choosing doc already catalogs the plugins and helps the reader pick one to install. Folding the
  index role into it keeps one plugin-level doc rather than splitting a catalog from a decision guide that would repeat
  the plugin list. Slimming its per-plugin descriptions to scent-and-link keeps the plugin README canonical and avoids
  re-creating, at the plugin tier, the duplication the reorganization removes at the skill tier.
- **Evidence:** user input; the existing `docs/choosing-a-han-plugin.md:31-111`, which today enumerates every plugin and
  deep-links every skill.
- **Rejected alternatives:**
  - A new `docs/plugins/README.md` mirroring the skills and agents index files — rejected because it would duplicate the
    plugin list the choosing doc already carries.
  - Keep the choosing doc's full per-plugin descriptions and per-skill deep-links — rejected because that re-creates the
    duplication the reorganization exists to remove, now at the plugin tier.
- **Linked technical notes:** —
- **Driven by findings:** F6, F11
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D5: Indexes shrink to alphabetized link lists

- **Question:** Do the skills index and agents index stay, and what do they become?
- **Decision:** Both indexes stay as files but shrink to alphabetized lists. Each entry is a short scent line — a
  sentence, or two where a second is needed to tell near-neighbors apart — linking to the canonical long-form doc at its
  new in-plugin location. The current by-purpose grouping leaves the aggregate indexes; the browse-by-task reader is
  served by the quickstart and by the per-plugin grouping the READMEs keep (`han-core` by D12). Each index points across
  to the workflows page for how the skills chain together.
- **Rationale:** The issue asks the indexes to stay but drop their current size and complexity, becoming an alphabetized
  listing that links into each document. An alphabetized catalog is simple to scan and simple to keep complete. Allowing
  a second sentence where it disambiguates keeps the scent strong enough to choose between similar skills, and keeping a
  cross-link to workflows preserves the "how skills compose" path the index used to carry in place.
- **Evidence:** issue #115 (expected behavior: indexes "shrink to an alphabetized listing that links into each relevant
  document"); user input; the current `docs/skills/README.md` by-purpose grouping and multi-sentence entries.
- **Rejected alternatives:**
  - Keep the current grouped, section-rich indexes — rejected because the issue wants them slimmer and the per-plugin
    READMEs now carry the plugin-local grouping.
  - Flatten to a hard one-sentence scent with no cross-links — rejected because it strips the detail that disambiguates
    near-neighbor skills and drops the reader's path to the composition scenarios.
- **Linked technical notes:** —
- **Driven by findings:** F8, F15
- **Dependent decisions:** D6
- **Referenced in spec:** Outcome, Primary Flow

### D6: Composition scenarios and diagrams move to a workflows doc

- **Question:** When the indexes shrink, where do their cross-cutting sections go — the "how skills compose" scenarios,
  the sizing summary, and the YAGNI summary — plus the new flow diagrams, and how does the new page stay distinct from
  the pages that already describe skill chains?
- **Decision:** A new `docs/workflows.md` carries the composition scenarios and the flow diagrams. It shows a flow
  diagram wherever a chain is branching enough that a picture beats the prose, not one per scenario. The sizing and YAGNI
  summaries drop from the indexes and rely on the existing `docs/sizing.md` and `docs/yagni.md`. The workflows page
  states its own distinct job — the map of which skills chain together — and how it differs from the quickstart
  (do-this-now paths), the how-to guides (step-by-step walkthroughs), and the concepts page (the skill-and-agent model),
  and those four pages cross-link. The root README, both indexes, and the plugin index link to the workflows page.
- **Rationale:** Composition scenarios span several plugins (a plan-then-build-then-review chain crosses three), so a
  single cross-cutting home reads better than fragments spread across per-plugin READMEs. Diagrams earn their place on the
  branching chains, not the linear ones. Sizing and YAGNI already have dedicated canonical docs, so the index summaries
  were redundant. Naming the page's distinct job and giving it inbound links keeps a reader from guessing among four
  near-synonymous surfaces and keeps the page reachable.
- **Evidence:** user input; the existing `docs/sizing.md`, `docs/yagni.md`, `docs/quickstart.md`, `docs/how-to/`, and
  `docs/concepts.md`; the current "How skills compose" section in `docs/skills/README.md:274-301`.
- **Rejected alternatives:**
  - Fold the scenarios and diagrams into `docs/concepts.md` — rejected to keep concepts purely the skill-and-agent
    model rather than a workflow catalog.
  - Push composition guidance into each plugin's README — rejected because it fragments cross-plugin flows across
    several files.
  - Commit to one diagram per composition scenario — rejected under YAGNI; the simpler version diagrams only the
    branching chains and relocates the rest as text.
- **Linked technical notes:** T1
- **Driven by findings:** F8, F9
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Coordinations

### D8: Plugins without agents note shared-agent dispatch

- **Question:** What does a plugin README list for a plugin that ships no agents of its own?
- **Decision:** A plugin that owns no agents (every plugin except `han-core` and `han-communication`) omits an
  owned-agents section from its README and instead notes that its skills dispatch shared agents, which live in `han-core`
  and, for the readability-editor, in `han-communication`.
- **Rationale:** Listing shared agents as if the plugin owned them would misstate ownership and duplicate the agents
  index. A short note that the skills dispatch shared agents tells the reader what happens without claiming ownership, and
  naming both owning plugins keeps the note factually complete.
- **Evidence:** the existing plugin-README rule to include only entity sections the plugin has (`docs/plugin-readme.md`);
  `CLAUDE.md`, which records that `han-core` owns every agent except the readability-editor; the readability-editor
  definition at `han-communication/agents/readability-editor.md`.
- **Rejected alternatives:**
  - List the dispatched agents in each plugin's README — rejected because it duplicates the agents index and misstates
    which plugin owns the agents.
  - Note only that skills dispatch `han-core` agents — rejected because it omits the readability-editor, which the
    coding and core skills dispatch and which lives in `han-communication`.
- **Linked technical notes:** —
- **Driven by findings:** F4
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States

### D9: Layout descriptions, standards, and tooling updated

- **Question:** Which reader-facing guidance and tooling has to change when the docs move, and what is the consistency
  requirement?
- **Decision:** Every reader-facing description of the documentation layout and every path reference to the old doc
  locations is updated to the new in-plugin locations. The scope is the full active blast radius, not a partial list: a
  repository-wide scan of files referencing the old `docs/skills/` and `docs/agents/` paths (excluding the frozen
  `docs/plans/` and `docs/research/` archives) returns on the order of thirty-seven files, including the repository-root
  `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `han/README.md`, every `docs/how-to/` guide, several standalone `docs/`
  pages, the coverage rule, the skill and agent long-form templates, both indexes, the plugin index, and the
  documentation-maintenance tooling's `SKILL.md`, `audit-checklist.md`, and `scope-mapping.md`. The plugin-README
  standard and its template are reconciled separately under D18.
- **Rationale:** A move that leaves the layout descriptions and audit tooling pointing at the old paths produces broken
  links and a documentation audit that checks files that no longer exist. The initial draft's evidence list named only a
  subset; the real scope is the full scan, and it must be regenerated at implementation time so no referencing file is
  missed.
- **Evidence:** the full blast-radius scan of active files referencing `docs/skills/` and `docs/agents/` (about
  thirty-seven files once the `docs/plans/` and `docs/research/` archives are excluded), which is materially larger than
  the initial draft's list.
- **Rejected alternatives:**
  - Update only the indexes and the files in the initial partial list — rejected because the scan proved the referencing
    set is roughly four times larger, and the stale descriptions would contradict the new structure the moment it lands.
- **Linked technical notes:** —
- **Driven by findings:** F2, F5
- **Dependent decisions:** D16
- **Referenced in spec:** Edge Cases and Failure Modes, Coordinations

### D13: Plugin README states bundled-vs-opt-in and dependencies

- **Question:** How does each plugin README frame whether the meta-plugin bundles it or it is opt-in, and its
  dependencies?
- **Decision:** Each plugin README states whether the `han` meta-plugin bundles it (`han-communication`, `han-core`,
  `han-planning`, `han-coding`, `han-github`, `han-reporting`) or it is opt-in (`han-feedback`, `han-atlassian`,
  `han-linear`, `han-plugin-builder`), and names its dependencies. Opt-in plugins that need an MCP server say so.
- **Rationale:** The issue's Missing Information asks how opt-in plugins are framed versus bundled ones inside a plugin's
  own README. A reader on a single plugin README needs to know whether installing the meta-plugin already brought this
  plugin in or whether they install it on its own.
- **Evidence:** issue #115 (Missing Information #4); the existing bundled-vs-opt-in framing in
  `docs/choosing-a-han-plugin.md` and the plugin table in the repository-root `README.md`.
- **Rejected alternatives:**
  - Leave bundled-vs-opt-in status to the plugin index only — rejected because a reader who lands directly on a plugin
    README (a deep link or a folder browse) would not learn it.
- **Linked technical notes:** —
- **Driven by findings:** F7
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow

### D14: In-plugin docs link up to their plugin README

- **Question:** After the docs move next to their plugin, where does a long-form doc's "links up" navigation point, and
  how does a reader move laterally?
- **Decision:** A long-form doc's first link points up to its own plugin's README, which now sits beside it, and on to
  the repository root. Plugin READMEs carry minimal lateral navigation: up to the plugin index and root, and across to
  the workflows page.
- **Rationale:** Once the doc sits inside its plugin, the plugin README is its natural parent, and a reader deep in a
  skill doc who wants "what else is in this plugin" should reach the plugin README in one hop rather than only the far
  root. Lateral links keep a reader on a plugin README from dead-ending when they want the cross-plugin catalog or the
  composition view.
- **Evidence:** the current "every long-form doc links up ... first bullet ... points back to the README at the repo
  root" convention in `CLAUDE.md`, which after D1 skips the now-adjacent plugin README.
- **Rejected alternatives:**
  - Keep the root-README-only "links up" convention unchanged — rejected because it skips the natural parent now sitting
    beside the doc.
- **Linked technical notes:** —
- **Driven by findings:** F10
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

### D15: The long-form summary line is the canonical scent

- **Question:** A skill's one-line scent now lives in the long-form doc, the plugin README, and the aggregate index. How
  do the three stay in sync?
- **Decision:** The long-form doc's own summary line is the canonical scent. The plugin README and the aggregate index
  reuse it rather than writing their own, so the three do not drift.
- **Rationale:** Three hand-maintained copies of the same scent drift apart over time and erode trust in the indexes.
  Naming one canonical scent and reusing it is a behavioral rule that keeps them aligned without tooling.
- **Evidence:** the three-touch contributor flow the spec's "A contributor adds a new skill" alternate flow describes.
- **Rejected alternatives:**
  - Let each surface write its own scent — rejected because it invites drift, the failure the reorganization is trying
    to remove.
- **Linked technical notes:** —
- **Driven by findings:** F16
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States

### D16: Link integrity is the acceptance gate

- **Question:** What proves the move did not break navigation?
- **Decision:** The reorganization is complete only when a repository-wide internal-link check passes with zero
  unresolved links. The check covers both links pointing at moved docs and the relative links inside moved docs, which
  are recomputed for their new depth.
- **Rationale:** Broken links are the reorganization's only real failure mode, so "every link resolves" needs an explicit
  exit gate rather than a hope. Relative links inside the moved docs break just as readily as links pointing at them,
  because the docs change tree location rather than being renamed in place.
- **Evidence:** the "every long-form doc links up" and cross-reference conventions in `CLAUDE.md`; the review finding
  that relative links inside moved docs were unaccounted for.
- **Rejected alternatives:**
  - Treat link fixing as a find-and-replace of each doc's own path — rejected because it misses every outbound relative
    link inside the roughly seventy moved files.
- **Linked technical notes:** —
- **Driven by findings:** F3, F14
- **Dependent decisions:** —
- **Referenced in spec:** Actors and Triggers (Preconditions), Edge Cases and Failure Modes

### D17: The meta-plugin README omits skills and agents sections

- **Question:** What README shape does the `han` meta-plugin get, given it ships zero skills and zero agents?
- **Decision:** The `han` meta-plugin's README describes what installing the meta-plugin brings in, names the plugins it
  bundles, and points to the plugin index and the workflows page. It carries neither a skills section nor an agents
  section. The existing stale `han/README.md`, which describes the old `han-core` / `han-github` split, is rewritten to
  the current suite.
- **Rationale:** D2 and D3 assume a skills section every README carries, which the meta-plugin cannot, because it owns no
  components. Its README's job is to explain the bundle and route the reader onward.
- **Evidence:** `han/plugin.json`, which is dependencies-only with no skills or agents; the current `han/README.md`,
  which still describes only `han-core` and `han-github`.
- **Rejected alternatives:**
  - Give the meta-plugin an empty or placeholder skills section — rejected because it lists nothing and misleads the
    reader about what the plugin ships.
- **Linked technical notes:** —
- **Driven by findings:** F5
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States

### D18: The plugin-README standard and template move to the light model

- **Question:** The plugin-README standard and its template mandate the heavy Skills Reference blocks that D3 rejects.
  What happens to them?
- **Decision:** The plugin-README standard (`docs/plugin-readme.md`) and the plugin-README template
  (`han-plugin-builder/skills/guidance/references/templates/plugin-readme-template.md`) are reconciled to the light
  front-door model. The rules and template that mandate a per-skill paragraph, a files line, and example prompts are
  rewritten so a contributor authoring a new README produces the scent-and-link shape D3 defines.
- **Rationale:** The standard and the spec must not tell contributors opposite things. If the standard still mandates the
  heavy Skills Reference, every future README re-creates the duplication the reorganization removes. The standard has to
  move to the light model for the convention to hold.
- **Evidence:** `docs/plugin-readme.md:107-146` (the Skills Reference rule and the "use the template" rule);
  `han-plugin-builder/skills/guidance/references/templates/plugin-readme-template.md:98-125` (the mandated Skills
  Reference blocks); D3.
- **Rejected alternatives:**
  - Leave the standard and template as they are — rejected because contributors following the on-disk standard would
    keep producing heavy READMEs that violate D3.
  - Let the light and heavy models coexist — rejected because two contradictory README shapes reintroduce the drift the
    reorganization removes.
- **Linked technical notes:** —
- **Driven by findings:** F1
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes
