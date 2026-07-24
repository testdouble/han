# Investigation: Reducing the han-core footprint for dependent plugins

Investigation report. Read the Summary, then approve the Planned Restructure or push back.

## Summary

- **Root Cause:** han-core plays two unrelated roles at once. It is the shared agent roster the suite dispatches (21 of 23 agents used by han-planning, 17 by han-coding), and it is also the home of seven skills that almost nothing else invokes (E1, E2, E8). Because plugin dependencies are whole-plugin only (E13), every dependent installs both roles. Three plugins even declare the dependency without using anything from it at all (E4, E5, E6).
- **Fix:** Keep han-core as the shared agent roster plus project-discovery. Move the three documentation skills to a new han-documentation plugin, and move the three knowledge skills (research, gap-analysis, issue-triage) to a new han-research plugin. Drop the vestigial han-core dependencies from han-reporting, han-feedback, and han-linear.
- **Why Correct:** The usage map shows the agent roster is genuinely shared (E1, E2, E3), while six of the seven skills have zero cross-plugin Skill-tool consumers (E8). Splitting along the agents-versus-skills line moves only leaves, and breaks no call sites except one, which the plan updates (E7).
- **Validation Outcome:** Validation confirmed the split lines and the vestigial-dependency claims, and corrected one early finding: gap-analyzer stays in han-core (V1). It also widened the blast radius with three concrete gaps: about 19 relative agent-doc links that would break in the moved long-form docs (V2), the `.codex-plugin/plugin.json` manifests in nine plugins (V3), and a CLAUDE.md conventions sentence that pins agents to two plugins (V4).
- **Remaining Risks:** See Confidence Assessment. The main open item is whether marketplace dependency resolution treats a new plugin name cleanly on upgrade for users who already have han installed.

## Problem Statement

Installing anything that depends on han-core currently pulls in all of han-core: 23 agents, 7 skills, and its reference files. The user wants a clean dependency structure with a smaller installed footprint for han-core dependents. The pain is sharpest at the edges: han-github depends on the whole plugin to use one agent (E3), and han-reporting, han-feedback, and han-linear depend on it while using nothing from it (E4, E5, E6).

There is no per-agent or per-skill dependency mechanism. The only lever available is how entities are grouped into plugins (E13).

## Root Cause Analysis

### Root Cause

han-core bundles two things together: the suite-wide shared agent roster, and seven mostly-leaf skills. The whole-plugin dependency model forces every dependent to install both. Three dependents declare the dependency with no usage behind it at all.

### The usage evidence behind the split

The agent roster is the part of han-core the suite genuinely shares. han-planning dispatches 21 of the 23 agents across its five skills (E1), and han-coding dispatches 17 across its nine (E2). The union of the two covers every agent except research-analyst and project-scanner, which are dispatched only by han-core's own research and project-discovery skills (E10). Splitting the roster between han-planning and han-coding would duplicate most of it, so the roster must stay in one shared plugin.

The skills are a different story. Of han-core's seven skills, only project-documentation has a confirmed external Skill-tool consumer: han-atlassian's project-documentation-to-confluence wrapper (E7). The other six (architectural-decision-record, gap-analysis, issue-triage, project-discovery, research, runbook) have zero cross-plugin invocations; outside references are boundary disclaimers ("does not do X, use Y") or doc links (E8).

project-discovery is load-bearing in a different way. 13 skills across han-planning, han-coding, and han-reporting probe for the project-discovery.md file it writes, but they probe the user's repository by filename, not the plugin's path. The skill's plugin home does not affect them (E9).

The vestigial dependencies compound the footprint problem. han-reporting's skills contain no han-core reference of any kind, and its README's claim that its skills dispatch shared han-core agents is not backed by any dispatch site (E4). han-feedback's han-core mentions are examples inside its own skill about parsing transcript names, not dispatches (E5). han-linear has no han-core reference in its skill or references files (E6). Each of these installs 23 agents and 7 skills for nothing.

han-github sits in between: its two skills dispatch exactly one han-core agent, junior-developer (E3). junior-developer is dispatched from four plugins (E1, E2, E3, plus han-core's own skills), so it belongs in the shared roster. han-github's dependency is legitimate, but it is satisfied by a much smaller han-core.

## Planned Restructure

### Approach

Split han-core along the agents-versus-skills line. Keep the shared roster, plus project-discovery and its scanner, in han-core. Move the documentation skills to a new han-documentation plugin and the knowledge skills to a new han-research plugin, then delete the three vestigial dependencies.

### Target shape

- **han-core** (after): 22 agents (all current agents except research-analyst, which moves with the research skill), the project-discovery skill, the project-scanner agent, and the canonical evidence-rule.md and yagni-rule.md. han-core stays the single shared roster because 20 of the remaining agents are dispatched from at least two plugins, including gap-analyzer, content-auditor, and user-experience-designer (E1, V1).
- **han-documentation** (new): project-documentation, architectural-decision-record, runbook. Depends on han-communication and han-core (project-documentation dispatches codebase-explorer, content-auditor, and information-architect; architectural-decision-record dispatches codebase-explorer, software-architect, system-architect, risk-analyst, and junior-developer; runbook dispatches no agents) (E11). Bundled by the han meta-plugin.
- **han-research** (new): research, gap-analysis, issue-triage, plus the research-analyst agent, whose only dispatch site is the research skill (E10). Depends on han-communication and han-core (research also dispatches codebase-explorer and adversarial-validator; gap-analysis dispatches gap-analyzer, evidence-based-investigator, junior-developer, and project-manager; issue-triage dispatches no agents) (E11). Bundled by the han meta-plugin.
- **han-reporting, han-feedback, han-linear**: drop the han-core dependency (E4, E5, E6). han-reporting and han-linear keep or gain han-communication only as their skills require. han-feedback's skill produces reader-facing output, so check whether it should pick up han-communication when han-core is removed.
- **han-atlassian**: replace its direct han-core skill use by depending on han-documentation for project-documentation (E7); its agent needs remain transitive through han-planning and han-coding.
- **han-github, han-planning, han-coding**: dependency lists unchanged; their installed footprint shrinks by the six moved skills.

An alternative that avoids one new plugin: fold research, gap-analysis, and issue-triage into han-planning instead of creating han-research. All three are pre-planning knowledge work, and han-planning already dispatches gap-analyzer. The trade-off is that han-planning's scope statement ("planning before implementation") stretches, and han-coding-only users lose the issue-triage handoff that the refactor skill recommends. The two-new-plugins shape keeps each plugin's scent line honest, which is why it is the recommendation.

### Changes

#### `han-reporting/.claude-plugin/plugin.json`, `han-feedback/.claude-plugin/plugin.json`, `han-linear/.claude-plugin/plugin.json`

- **Change:** Remove `han-core` from each `dependencies` array.
- **Evidence:** (E4), (E5), (E6): zero functional usage in all three.
- **Details:** Also correct `han-reporting/README.md:20`, which claims its skills dispatch shared han-core agents; no dispatch site exists. Update the matching boilerplate lines in han-feedback and han-linear READMEs and the marketplace description prose (E14). Decide whether han-feedback gains `han-communication`.

#### `han-documentation/` (new plugin)

- **Change:** Create the plugin (README, `.claude-plugin/plugin.json` with `dependencies: ["han-communication", "han-core"]`, `skills/`, `docs/skills/`) and move `project-documentation`, `architectural-decision-record`, and `runbook` from `han-core/skills/`, with their long-form docs from `han-core/docs/skills/`.
- **Evidence:** (E8), (E11): three documentation-shaped skills, no external Skill-tool consumers except project-documentation's one wrapper, agent needs covered by depending on han-core.
- **Details:** Vendor `evidence-rule.md` and `yagni-rule.md` into `han-documentation/references/` following the existing han-planning and han-coding pattern (E12), and update the moved skills' relative reference links. Rewrite every `../agents/{name}.md` link in the moved long-form docs to the cross-plugin form `../../../han-core/docs/agents/{name}.md`, the pattern han-core's own agent docs already use for han-coding skills (V2: 3 such links in project-documentation.md, 5 in architectural-decision-record.md, 5 in runbook.md). Create a `.codex-plugin/plugin.json` alongside the `.claude-plugin` one, matching the nine existing plugins (V3). Add the plugin to the `han` meta-plugin `dependencies` and to `.claude-plugin/marketplace.json`.

#### `han-research/` (new plugin)

- **Change:** Create the plugin (`dependencies: ["han-communication", "han-core"]`) and move `research`, `gap-analysis`, and `issue-triage` from `han-core/skills/`, plus `research-analyst.md` from `han-core/agents/` and their long-form docs.
- **Evidence:** (E8), (E10), (E11): three leaf skills; research-analyst has a single dispatch site inside the research skill.
- **Details:** gap-analyzer, project-manager, evidence-based-investigator, junior-developer, codebase-explorer, and adversarial-validator stay in han-core (all are dispatched from other plugins, V1). Rewrite the moved docs' relative agent links to the cross-plugin form (V2: 6 links in gap-analysis.md, 2 in research.md that point at staying agents; research.md's research-analyst link moves with the doc). Vendor the two rule files as above, create the `.codex-plugin/plugin.json` (V3), and bundle in the `han` meta-plugin and marketplace.json.

#### `han-atlassian/.claude-plugin/plugin.json` and `han-atlassian/skills/project-documentation-to-confluence/SKILL.md`

- **Change:** Add `han-documentation` to dependencies; update the Skill invocation at `SKILL.md:50` from `han-core:project-documentation` to `han-documentation:project-documentation`; drop the direct `han-core` dependency if the resolver treats transitive dependencies as installed (han-planning and han-coding both pull han-core).
- **Evidence:** (E7): this is the only cross-plugin Skill-tool call site into han-core.
- **Details:** Also update the skill's other `han-core:project-documentation` prose references and the plugin README and marketplace description.

#### `han-core/.claude-plugin/plugin.json`, `han-core/README.md`

- **Change:** Rewrite the description to name the plugin's post-split role: the shared specialist-agent roster, project discovery, and the canonical rule files. Remove the moved skills and research-analyst from the README's lists. Rewrite `han-core/.codex-plugin/plugin.json` as well: its `longDescription`, `keywords` (which include "documentation"), and `defaultPrompt` entries name the moving skills project-documentation and gap-analysis (V3).
- **Evidence:** (E1), (E2), (E9), (E10), (V3).
- **Details:** project-discovery stays because its project-scanner agent is single-consumer and its output file serves 13 skills across three plugins, making it suite bootstrap rather than a topical skill (E9, E10). Do not bump any version numbers as part of this plan.

#### Repo-wide documentation surfaces

- **Change:** Update every surface that hardcodes the current layout: `CLAUDE.md` (repository layout tree and prose), `docs/skills/README.md` and `docs/agents/README.md` link paths, `docs/choosing-a-han-plugin.md`, `docs/workflows.md`, and the affected plugin READMEs.
- **Evidence:** (E14), (V3), (V4).
- **Details:** Follow the existing convention: long-form docs move with their skill into the owning plugin's `docs/`, indexes stay complete, and scent lines link to the new homes. Explicitly rewrite the CLAUDE.md Conventions sentence "same for agents in `han-core/agents/` and `han-communication/agents/`" to admit han-research as a third agent-owning plugin (V4); a generic layout-tree update would miss it. Boundary disclaimers in other skills ("use research", "use project-documentation") name skills without a plugin prefix and keep working because no two plugins share a skill name (verified: a duplicate-name scan across every plugin's `skills/` directory returned none, V5).

## Evidence Summary

### E1: han-planning dispatches 21 of han-core's 23 agents

- **Source:** `han-planning/skills/plan-a-feature/SKILL.md:317-353`, `han-planning/skills/plan-implementation/SKILL.md:167-217`, `han-planning/skills/iterative-plan-review/SKILL.md:168-334`, `han-planning/skills/plan-a-phased-build/SKILL.md:249`, `han-planning/skills/plan-work-items/SKILL.md:141`
- **Finding:** Roster tables plus generic team-launch steps (for example `plan-implementation/SKILL.md:200`, "Launch every non-`han-core:project-manager` specialist in parallel") dispatch every agent except research-analyst and project-scanner.
- **Relevance:** han-planning needs nearly the whole roster; the roster cannot be split away from it.

### E2: han-coding dispatches 17 of the agents across its nine skills

- **Source:** `han-coding/skills/architectural-analysis/SKILL.md:122-244`, `han-coding/skills/investigate/SKILL.md:48-111`, `han-coding/skills/code-review/SKILL.md:359-404,590`, `han-coding/skills/automated-test-planning/SKILL.md:85-224`, `han-coding/skills/code-overview/SKILL.md:163,241`, `han-coding/skills/coding-standard/SKILL.md:138-389`, `han-coding/skills/manual-test-planning/SKILL.md:89`
- **Finding:** Union: codebase-explorer, junior-developer, information-architect, structural-analyst, behavioral-analyst, risk-analyst, software-architect, concurrency-analyst, adversarial-security-analyst, data-engineer, devops-engineer, on-call-engineer, system-architect, evidence-based-investigator, adversarial-validator, test-engineer, edge-case-explorer. Absent versus han-planning's set: project-manager, user-experience-designer, gap-analyzer, content-auditor.
- **Relevance:** Confirms the roster is shared infrastructure for both big dependents.

### E3: han-github's entire functional han-core surface is one agent

- **Source:** `han-github/skills/update-pr-description/SKILL.md:91`, `han-github/skills/post-code-review-to-pr/SKILL.md:60`
- **Finding:** Both call sites launch a single `han-core:junior-developer`; no other han-core reference exists in the plugin outside README/docs prose and plugin.json.
- **Relevance:** han-github's dependency is legitimate but is satisfied by a much smaller han-core.

### E4: han-reporting uses nothing from han-core

- **Source:** `grep -rn "han-core" han-reporting/`; matches only `han-reporting/README.md:8,20` and `han-reporting/.claude-plugin/plugin.json:5`
- **Finding:** Neither `stakeholder-summary` nor `html-summary` contains any han-core agent dispatch, skill invocation, or reference read. The README line "Its skills dispatch shared agents that live in `han-core`" has no dispatch site behind it.
- **Relevance:** The dependency is vestigial and the README claim is wrong.

### E5: han-feedback's han-core mentions are parsing examples, not dispatches

- **Source:** `han-feedback/skills/han-feedback/SKILL.md:20,40,46,75,124,161`
- **Finding:** All six matches illustrate how to strip the `han-core:` namespace prefix when reporting which Han components a session used (for example, "the agent `han-core:risk-analyst` becomes `risk-analyst`").
- **Relevance:** The dependency is vestigial.

### E6: han-linear uses nothing from han-core

- **Source:** `grep -rn "han-core" han-linear/`; matches only README, doc-link, and plugin.json lines
- **Finding:** `work-items-to-linear/SKILL.md` and its three references files contain zero han-core occurrences.
- **Relevance:** The dependency is vestigial.

### E7: han-atlassian's only direct han-core call is one Skill-tool invocation

- **Source:** `han-atlassian/skills/project-documentation-to-confluence/SKILL.md:50`
- **Finding:**
  ```
  Invoke the `han-core:project-documentation` skill with the **Skill** tool, **forwarding all provided context** verbatim
  ```
- **Relevance:** The single cross-plugin Skill-tool call into han-core; the one call site the restructure must update. han-atlassian's agent needs are transitive through han-planning and han-coding.

### E8: Six of han-core's seven skills have zero cross-plugin invocations

- **Source:** Repo-wide grep for Skill-tool chains into `architectural-decision-record`, `gap-analysis`, `issue-triage`, `project-discovery`, `research`, `runbook`; zero matches. External mentions are boundary disclaimers (for example `han-coding/skills/coding-standard/SKILL.md:6-8`) or doc links
- **Finding:** Only `project-documentation` has an external consumer (E7). `issue-triage` is additionally named as a soft handoff target in `han-coding/skills/refactor/SKILL.md:149`.
- **Relevance:** The skills are leaves in the invocation graph; moving them breaks no call sites beyond E7.

### E9: project-discovery's output is consumed by filename probe, not plugin path

- **Source:** Frontmatter probes in 13 SKILL.md files plus 2 scripts, for example `han-coding/skills/tdd/SKILL.md:23` and `han-reporting/skills/stakeholder-summary/SKILL.md:16`, all shaped as `` !`find . -maxdepth 3 -name "project-discovery.md" -type f` ``
- **Finding:** 13 skills across han-planning, han-coding, and han-reporting read the `project-discovery.md` file the skill writes into the user's repository; none invoke the skill itself.
- **Relevance:** The skill's plugin home is functionally free to choose; it stays in han-core on suite-bootstrap grounds.

### E10: Two agents are single-consumer

- **Source:** `han-core/skills/research/SKILL.md:141-177` (research-analyst), `han-core/skills/project-discovery/SKILL.md:43,51` (project-scanner); repo-wide grep found no other dispatch sites for either
- **Finding:** research-analyst is dispatched only by the research skill; project-scanner only by project-discovery.
- **Relevance:** Each can move (or stay) with its one consumer without touching the shared roster.

### E11: Per-skill agent needs vary from zero to heavy

- **Source:** `han-core/skills/issue-triage/SKILL.md:10` (allowed-tools without Agent), `han-core/skills/runbook/SKILL.md:11-12` (same), `han-core/skills/architectural-decision-record/SKILL.md:98-129`, `han-core/skills/research/SKILL.md:141-231`, `han-core/skills/gap-analysis/SKILL.md:100-290`, `han-core/skills/project-documentation/SKILL.md:53-162`
- **Finding:** issue-triage and runbook dispatch no agents. architectural-decision-record needs five (codebase-explorer, software-architect, system-architect, risk-analyst, junior-developer). research needs three (research-analyst, codebase-explorer, adversarial-validator). project-documentation needs three (codebase-explorer, content-auditor, information-architect). gap-analysis is heaviest: gap-analyzer, evidence-based-investigator, junior-developer, project-manager, plus a 2-8 agent swarm from a roster.
- **Relevance:** Sets the dependency lists for the new plugins; all needed agents except research-analyst remain in han-core.

### E12: Rule files are vendored, never read cross-plugin

- **Source:** `diff` of `han-core/references/{evidence-rule,yagni-rule}.md` against the han-planning and han-coding copies returned empty; repo-wide grep for `han-core/references` in consuming plugins returned zero matches
- **Finding:** han-planning and han-coding carry byte-identical vendored copies and link them with relative paths; only han-core's own skills and agents read the canonical copies.
- **Relevance:** New plugins follow the same vendoring pattern; no cross-plugin file-path coupling exists to break.

### E13: Dependencies are whole-plugin only

- **Source:** `dependencies` arrays in each plugin's `.claude-plugin/plugin.json`; `.claude-plugin/marketplace.json:9-70`
- **Finding:** There is no per-agent or per-skill dependency mechanism; a plugin depends on all of han-core or none of it. The marketplace manifest carries no independent dependency data, only description prose.
- **Relevance:** Regrouping entities into plugins is the only available footprint lever.

### E14: Many surfaces hardcode the current layout

- **Source:** `CLAUDE.md` (repository layout tree), `docs/agents/README.md:4-30`, `docs/skills/README.md:4-20`, `docs/choosing-a-han-plugin.md`, `docs/workflows.md:39-110`, plugin README boilerplate (for example `han-reporting/README.md:20`), marketplace description prose
- **Finding:** Every index link and scent line points at the current plugin path for each skill and agent.
- **Relevance:** Defines the documentation blast radius of the restructure.

## Validation Results

### Counter-Evidence Investigated

#### V1: gap-analyzer looked single-consumer but is not

- **Hypothesis:** The agent-usage investigator flagged gap-analyzer as possibly dispatched only by han-core's gap-analysis skill, which would let it move to han-research with that skill.
- **Investigation:** Read `han-planning/skills/iterative-plan-review/SKILL.md:210,239,331` and `han-planning/skills/plan-a-feature/SKILL.md:328,351` against each skill's generic team-launch step (`iterative-plan-review/SKILL.md:313`, plan-a-feature Step 4).
- **Result:** Refuted (the single-consumer hypothesis). Both han-planning skills carry gap-analyzer in their dispatch tables and launch it through their roster mechanism when a source spec exists. The dispatch is conditional (only when a source PRD or spec exists), unlike unconditional agents such as junior-developer, but a conditional dispatch from another plugin still pins the agent to the shared roster.
- **Impact:** gap-analyzer stays in han-core; only research-analyst moves with its skill.

#### V2: The moved skills' long-form docs carry relative links into agents that stay behind

- **Hypothesis:** The only path coupling in the moved skills is the two vendored rule files (E12).
- **Investigation:** The validator grepped `](../agents/` across the six moving long-form docs: `han-core/docs/skills/project-documentation.md:190-192` (3 links), `architectural-decision-record.md:202-209` (5), `runbook.md:182-252` (5), `research.md:222-228` (3, one of which points at research-analyst and moves with it), `gap-analysis.md:94-465` (6).
- **Result:** Refuted. About 19 links would break after the move; every one targets an agent the plan keeps in han-core.
- **Impact:** Both new-plugin change entries now include rewriting these links to the cross-plugin form (`../../../han-core/docs/agents/{name}.md`) that han-core's own agent docs already use when pointing into other plugins.

#### V3: The `.codex-plugin/plugin.json` manifests were missing from the blast radius

- **Hypothesis:** E14's list of layout-hardcoding surfaces is exhaustive.
- **Investigation:** The validator found `.codex-plugin/plugin.json` in nine of the ten plugins (all but han-linear). han-core's copy names moving skills directly: its `keywords` include "documentation" and its `defaultPrompt` entries reference project-documentation and gap-analysis.
- **Result:** Refuted. The plan had not covered these manifests.
- **Impact:** The change set now creates `.codex-plugin/plugin.json` for both new plugins and rewrites han-core's.

#### V4: A CLAUDE.md conventions sentence pins agents to two plugins

- **Hypothesis:** A generic "update CLAUDE.md" pass would cover everything the move invalidates.
- **Investigation:** CLAUDE.md's Conventions section states agents live in `han-core/agents/` and `han-communication/agents/`. Moving research-analyst to han-research makes that sentence false, and it reads as an invariant a future session would trust.
- **Result:** Partially Refuted. The plan's broad CLAUDE.md bucket could cover it, but only if the specific sentence is named.
- **Impact:** The documentation change entry now names that sentence as a required edit.

#### V5: Bare skill names in boundary disclaimers stay unambiguous

- **Hypothesis:** Moving skills between plugins could create a duplicate skill name, breaking the bare-name "use X" disclaimers other skills carry.
- **Investigation:** A duplicate-name scan across every plugin's `skills/` directories returned no duplicates.
- **Result:** Confirmed. No collision exists today and the plan introduces none, since it moves skills without renaming them.
- **Impact:** None; the check moved from asserted to verified.

#### V6: The vestigial-dependency and single-consumer claims survived direct counter-checks

- **Hypothesis:** han-reporting's `Agent` tool grant hides a han-core dispatch, or research-analyst and project-scanner have a second dispatch site somewhere in the repo.
- **Investigation:** The validator read `han-reporting/skills/stakeholder-summary/SKILL.md:10,159,163` (the only dispatch is `han-communication:readability-editor`) and grepped both agent names across every `.md` file in the repo, finding only their known dispatch sites, doc mentions, and CHANGELOG history.
- **Result:** Confirmed. E4, E5, E6, and E10 stand.
- **Impact:** Supports removing the three vestigial dependencies and moving research-analyst.

### Adjustments Made

- Added the relative agent-doc link rewrites to both new-plugin change entries (triggered by V2).
- Added `.codex-plugin/plugin.json` creation for the new plugins and a rewrite of han-core's to the change set (triggered by V3).
- Named the CLAUDE.md Conventions sentence about agent-owning plugins as an explicit required edit (triggered by V4).
- Ran the skill-name duplicate scan and recorded its clean result, converting an open verification into evidence (triggered by V5).
- Noted in V1 that gap-analyzer's han-planning dispatches are conditional on a source spec existing, so a future finer-grained footprint pass has the distinction on record.

### Confidence Assessment

- **Confidence:** High for the usage map, the vestigial-dependency removals, and the agents-versus-skills split line; Medium for the two-new-plugins grouping, which is a judgment call between clean scent lines and plugin-count growth.
- **Remaining Risks:**
  - How the marketplace and plugin resolver handle upgrades for users who already have `han` installed when two new bundled plugins appear. This was not tested here; static repo inspection cannot exercise the resolver.
  - Whether han-feedback should gain a han-communication dependency when han-core is removed.
  - Whether any external user documentation or muscle memory depends on `han-core:research` and friends as namespaced slash commands. The bare `/research` form keeps working, but the namespaced form changes to `han-research:research`.
