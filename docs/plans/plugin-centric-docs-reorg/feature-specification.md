# Feature Specification: Plugin-Centric Documentation Reorganization

Reorganize the Han documentation so a reader navigates plugin-first: every plugin carries its own README front door and
its own skill and agent long-form docs, the catalog indexes shrink to alphabetized link lists, and a single canonical
source per concept survives the move.

## Outcome

A reader who opens the Han repository can start at any plugin folder and understand that plugin on its own: what it does,
how, and why, whether it is bundled or opt-in, and a scent-line list of its skills and agents that links into the full
docs ([D13](artifacts/decision-log.md#d13-plugin-readme-states-bundled-vs-opt-in-and-dependencies)). Those long-form docs
now live inside the plugin they describe
([D1](artifacts/decision-log.md#d1-long-form-docs-move-into-each-plugin-directory)), next to that plugin's README, rather
than gathered in the repository-root `docs/` folder.

The reader who wants a cross-plugin catalog still gets one. The skills index and the agents index stay where they are but
shrink to alphabetized lists, each entry a short scent line linking to the canonical long-form doc
([D5](artifacts/decision-log.md#d5-indexes-shrink-to-alphabetized-link-lists)). A reader choosing what to install reads
one plugin catalog that doubles as the plugin index and walks the install decision
([D4](artifacts/decision-log.md#d4-the-choosing-doc-becomes-the-plugin-index)). A reader who wants to see how the skills
chain together reads a workflows page whose flow diagrams render directly on GitHub
([D6](artifacts/decision-log.md#d6-composition-scenarios-and-diagrams-move-to-a-workflows-doc)).

Every concept keeps exactly one canonical home. The long-form doc stays the single source of truth for a skill or agent,
and the plugin README stays the single source of truth for what its plugin does; the other surfaces point to those homes
rather than restating them ([D3](artifacts/decision-log.md#d3-per-plugin-readme-is-the-canonical-plugin-front-door)). The
reorganization moves and slims files; it does not change what any skill or agent does.

## Actors and Triggers

- **Actors**
  - **A reader browsing the repository on GitHub** — someone evaluating Han, onboarding, or looking up how a skill
    behaves.
  - **A contributor** adding or editing a skill, an agent, or a plugin, who must know where the new doc goes, which
    README shape to follow, and which indexes to update.
  - **An AI coding agent** (for example Claude via `CLAUDE.md`) that reads the layout description and the indexes to
    route work and answer questions about the suite.
- **Triggers** — a reader opens the repository root, opens a plugin folder, follows a link from an index, or opens the
  workflows page. A contributor adds a new skill, agent, or plugin and reaches for the coverage rule and the
  plugin-README standard.
- **Preconditions** — the reorganization has landed: long-form docs relocated into their plugins, per-plugin READMEs
  written, indexes slimmed, the choosing doc turned into the plugin index, the workflows page created, and every layout
  description, authoring standard, and cross-reference updated to match. A repository-wide internal-link check passes
  with zero unresolved links ([D16](artifacts/decision-log.md#d16-link-integrity-is-the-acceptance-gate)).

## Primary Flow

1. The reader lands on the repository-root `README.md`. It names what Han is, lists the plugins, and points to the
   plugin index, the skills index, the agents index, and the workflows page.
2. The reader opens a plugin folder (for example `han-coding/`) and reads its `README.md`. The README states what that
   plugin does, how, and why, whether the meta-plugin bundles it or it is opt-in, and its dependencies
   ([D13](artifacts/decision-log.md#d13-plugin-readme-states-bundled-vs-opt-in-and-dependencies)). It then lists each of
   the plugin's skills, and its agents when it owns any, as short scent lines
   ([D3](artifacts/decision-log.md#d3-per-plugin-readme-is-the-canonical-plugin-front-door)).
3. Each scent line links to that skill's or agent's long-form doc, which now lives in the same plugin folder under
   `docs/skills/{name}.md` or `docs/agents/{name}.md`
   ([D1](artifacts/decision-log.md#d1-long-form-docs-move-into-each-plugin-directory)).
4. The reader follows a scent line and reads the long-form doc. It remains the one canonical source for when to use the
   skill or agent, what it returns, and how to get the most out of it. Its first link points up to its own plugin's
   README, which sits beside it, and on to the repository root
   ([D14](artifacts/decision-log.md#d14-in-plugin-docs-link-up-to-their-plugin-readme)).
5. A reader who wants the cross-plugin catalog opens the skills index (`docs/skills/README.md`) or the agents index
   (`docs/agents/README.md`) instead. Each is an alphabetized list whose entries link to every long-form doc across all
   plugins, and each points across to the workflows page for how those skills chain together
   ([D5](artifacts/decision-log.md#d5-indexes-shrink-to-alphabetized-link-lists)).
6. A reader deciding what to install reads the plugin index (`docs/choosing-a-han-plugin.md`). It lists every plugin
   with a one-line scent and a link to that plugin's README, and walks the install decision in one place. It does not
   restate each plugin's full purpose or deep-link every skill; the plugin README owns the plugin's purpose and the
   skills index owns the per-skill scent
   ([D4](artifacts/decision-log.md#d4-the-choosing-doc-becomes-the-plugin-index)).
7. A reader who wants to see how the skills compose opens the workflows page (`docs/workflows.md`). It describes the
   common composition scenarios, with a flow diagram wherever a chain is branching enough that a picture beats the prose,
   and GitHub renders those diagrams inline with no build step
   ([D6](artifacts/decision-log.md#d6-composition-scenarios-and-diagrams-move-to-a-workflows-doc),
   [T1](artifacts/feature-technical-notes.md#t1-github-renders-mermaid-fenced-blocks-natively)). The workflows page is
   the map of which skills chain together, distinct from the quickstart's do-this-now paths, the how-to guides'
   step-by-step walkthroughs, and the concepts page's skill-and-agent model
   ([D6](artifacts/decision-log.md#d6-composition-scenarios-and-diagrams-move-to-a-workflows-doc)).

## Alternate Flows and States

### A contributor adds a new skill

- **Entry condition:** a contributor adds a new skill to a plugin.
- **Sequence:** they write the skill's `SKILL.md` in the plugin, add the long-form doc at that plugin's
  `docs/skills/{name}.md`, add a scent line to the plugin's README, and add one alphabetized entry to the skills index.
  The README and index scent lines reuse the long-form doc's own summary line so the three do not drift
  ([D15](artifacts/decision-log.md#d15-the-long-form-summary-line-is-the-canonical-scent)).
- **Exit:** the skill has one canonical long-form doc in its plugin, one README scent line, and one index entry, all in
  the same change.

### A contributor adds a new agent

- **Entry condition:** a contributor adds a new agent, which today means an agent in `han-core` or `han-communication`.
- **Sequence:** they write the agent definition, add the long-form doc at that plugin's `docs/agents/{name}.md`, add a
  scent line to that plugin's README, and add one alphabetized entry to the agents index.
- **Exit:** the agent has one canonical long-form doc in its plugin, one README scent line, and one index entry.

### A plugin owns no agents of its own

- **Entry condition:** a reader opens the README of a plugin that ships no agents, which is every plugin except
  `han-core` and `han-communication`.
- **Sequence:** the README omits an owned-agents section and instead notes that the plugin's skills dispatch shared
  agents, which live in `han-core` and, for the readability-editor, in `han-communication`
  ([D8](artifacts/decision-log.md#d8-plugins-without-agents-note-shared-agent-dispatch)).
- **Exit:** the reader understands the plugin dispatches shared agents without being told the plugin owns them.

### A reader opens the meta-plugin's README

- **Entry condition:** a reader opens `han/README.md`, the meta-plugin that ships no skills and no agents of its own.
- **Sequence:** its README describes what installing the meta-plugin brings in, names the plugins it bundles, and points
  to the plugin index and the workflows page. It carries neither a skills section nor an agents section, because it owns
  neither ([D17](artifacts/decision-log.md#d17-the-meta-plugin-readme-omits-skills-and-agents-sections)).
- **Exit:** the reader understands the meta-plugin is a bundle, not a component set, and knows where to go next.

## Edge Cases and Failure Modes

| Condition                                                                                           | Required Behavior                                                                                                                                                                                                            |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| An internal link still points at an old `docs/skills/{plugin}/` or `docs/agents/{plugin}/` location  | The link is updated to the doc's new in-plugin location so it resolves. No active cross-reference is left pointing at a moved file ([D16](artifacts/decision-log.md#d16-link-integrity-is-the-acceptance-gate)).             |
| A moved long-form doc carries relative links of its own (to references, sibling docs, or the root)   | Every relative link inside the moved doc is recomputed for its new depth so it still resolves, not only the links pointing at the doc ([D16](artifacts/decision-log.md#d16-link-integrity-is-the-acceptance-gate)).          |
| A per-plugin README restates content the long-form doc already owns                                  | The README carries only the scent line and the link; the restated detail is removed so the long-form doc stays the single canonical source ([D3](artifacts/decision-log.md#d3-per-plugin-readme-is-the-canonical-plugin-front-door)). |
| The plugin index restates a plugin's full purpose or deep-links its skills                           | The index carries a one-line scent and a link to the plugin README; the restated purpose and per-skill links are removed so the README and the skills index stay canonical ([D4](artifacts/decision-log.md#d4-the-choosing-doc-becomes-the-plugin-index)). |
| A layout description or authoring standard names the old doc locations or mandates the heavy README   | The description is corrected to the new locations, and the plugin-README standard and its template are reconciled to the light front door, wherever they appear ([D9](artifacts/decision-log.md#d9-layout-descriptions-standards-and-tooling-updated), [D18](artifacts/decision-log.md#d18-the-plugin-readme-standard-and-template-move-to-the-light-model)). |
| A reader opens a historical plan or research archive that references an old doc path                 | The archive is left unchanged as a point-in-time record; its stale path is not rewritten ([D10](artifacts/decision-log.md#d10-historical-archives-left-unchanged)).                                                          |
| The documentation-maintenance tooling still audits the old paths                                     | The tooling's path references and scope mapping are updated to the new locations so a documentation audit checks the right files ([D9](artifacts/decision-log.md#d9-layout-descriptions-standards-and-tooling-updated)).      |

## Coordinations

| Coordinating System                                                                          | Direction | Interaction                                                       | Ordering / Consistency Requirement                                                                                          |
| -------------------------------------------------------------------------------------------- | --------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Repository-root `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, and `han/README.md`             | outbound  | Describe the documentation layout and where docs live            | Their layout descriptions must match the on-disk locations after the move; the stale `han/README.md` is rewritten          |
| Skills index, agents index, and plugin index                                                 | outbound  | Link into the relocated long-form docs and per-plugin READMEs    | Every link must resolve to a file that exists at its new location; each labels the choosing doc as the plugin index         |
| The workflows page                                                                           | inbound   | Reached from the root README, both indexes, and the plugin index | Each of those surfaces links to the workflows page so it is not reachable from the root README alone                        |
| Long-form doc coverage rule, the skill and agent templates, and the plugin-README standard    | outbound  | State where a new long-form doc goes and what a README contains   | Their stated paths point to the in-plugin locations and their README content model matches the light front door            |
| The documentation-maintenance tooling                                                        | outbound  | Audits that every skill and agent has a current long-form doc     | Its path references and scope mapping target the new locations                                                             |
| GitHub Markdown rendering                                                                     | inbound   | Renders the workflows page's flow diagrams for the reader        | The reader sees each diagram on GitHub with no build step ([T1](artifacts/feature-technical-notes.md#t1-github-renders-mermaid-fenced-blocks-natively)) |

## Out of Scope

- **A rendered documentation site.** Building and publishing the docs through a site generator (for example mkdocs,
  sphinx, or readthedocs) is deferred, not part of this reorganization. See Deferred (YAGNI).
- **Rewriting historical archives.** The plan and research archives under `docs/plans/` and `docs/research/` are
  point-in-time records and keep their original paths
  ([D10](artifacts/decision-log.md#d10-historical-archives-left-unchanged)).
- **Changing skill or agent behavior.** This is a documentation move and slim-down. No `SKILL.md` body, agent
  definition, or skill behavior changes ([D11](artifacts/decision-log.md#d11-docs-only-no-behavior-changes)).
- **A single-directory view of all long-form docs.** Moving docs into ten plugin folders trades the old single
  `docs/skills/` tree for proximity to each plugin. The skills and agents indexes are the sanctioned cross-plugin entry
  after the move ([D1](artifacts/decision-log.md#d1-long-form-docs-move-into-each-plugin-directory)).

## Deferred (YAGNI)

### Rendered documentation site (mkdocs / sphinx / readthedocs)

- **Why deferred:** simpler-version test. GitHub already renders the reorganized Markdown and the workflows page's flow
  diagrams with no build step ([T1](artifacts/feature-technical-notes.md#t1-github-renders-mermaid-fenced-blocks-natively)),
  which satisfies the findability and orientation goal at far lower cost than a published site. The plugin-centric
  reorganization has to land and prove navigable before a site is worth its tooling and publishing pipeline.
- **Reopen when:** the reorganized Markdown proves insufficient for navigation, or the maintainers commit to a branded
  documentation site.
- **Source:** issue #115 comment thread (contributor proposal to render via mkdocs/sphinx and publish on
  readthedocs/pages; maintainer interested but not committed) and conversation.

## Open Items

- **OI-1:** Whether `han-core`'s README keeps grouping its skills by purpose (as the current skills index does) or lists
  them flat like the other plugins.
  - **Resolves when:** the `han-core` README is drafted and the by-purpose grouping is judged against a flat list for
    that plugin's skill count. Recommendation recorded in
    [D12](artifacts/decision-log.md#d12-han-core-readme-keeps-by-purpose-grouping).
  - **Blocks implementation:** No — a default is recorded; the README author can confirm it.

## Summary

- **Outcome delivered:** A reader navigates Han documentation plugin-first, with per-plugin READMEs and in-plugin
  long-form docs, slimmed alphabetized indexes, one plugin index that doubles as the install guide, and a workflows page
  whose diagrams render on GitHub.
- **Primary actors:** Readers browsing the repository, contributors, and AI coding agents.
- **Decisions settled by evidence:** 9 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 9 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** information-architect, junior-developer, gap-analyzer — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** widened the change scope to the full active blast radius plus relative-link
  recomputation and a link-integrity gate; declared the plugin README canonical for plugin purpose and slimmed the
  catalog to a plugin index; brought the plugin-README standard and the meta-plugin README into scope; corrected the
  shared-agent dispatch note — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
- **Technical notes:** 1 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
