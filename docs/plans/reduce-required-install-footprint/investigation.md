# Investigation: Reducing the Required Skills and Agents Installed with Any Given Han Plugin

Investigation report. Read the Summary, then approve the Planned Fix or push back.

## Problem Statement

Installing a single Han plugin can pull in far more skills and agents than that plugin ever uses. The clearest case is
`han-github`: installing it alone pulls in `han-communication` and `han-core`, a closure of 3 plugins, 6 skills, and 23
agents, when its own skills dispatch exactly one `han-core` agent (E3, E4). `han-core` itself declares a dependency on
`han-communication` that nothing inside `han-core` invokes (E2).

The question this investigation answers: which changes would meaningfully reduce the number of required skills and
agents installed with any given Han plugin, and which reductions look tempting but should not be made.

The impact falls on operators who install one plugin rather than the `han` meta-plugin. Every unused agent definition
still loads its description into session context and appears in the agent roster. Users of the meta-plugin are
unaffected by the two proposed cuts, because the meta-plugin installs every bundled plugin anyway.

## Root Cause Analysis

### Root Cause

Plugin-level dependency edges are the only install-granularity mechanism available, and two remaining edges are not
justified by usage: `han-core` depends on `han-communication` with zero invocations (E2), and `han-github` depends on
`han-core` for a single agent out of twenty-two (E3). Every other edge is either already minimal or justified by broad,
overlapping usage that resists further splitting (E5, E9).

### Detailed Analysis

The suite already took its biggest footprint reduction. The v5.0.0 restructure split the old `han-core` into
`han-core`, `han-documentation`, and `han-research`, and dropped vestigial `han-core` edges from `han-reporting`,
`han-feedback`, and `han-linear` (E9). That work also established the boundary condition on going further: the shared
specialist roster stays in one plugin because almost every specialist is dispatched by skills in at least two sibling
plugins, so splitting the roster would duplicate most of it (E5). Three plugins already install with no Han
dependencies at all (`han-feedback`, `han-linear`, `han-plugin-builder`), and `han-reporting` needs only
`han-communication` (E1).

What remains are two edges the earlier pruning pass did not catch. First, `han-core → han-communication`: no skill or
agent in `han-core` invokes any `han-communication` capability, and the decision log that introduced the edge shows it
was added for phase sequencing, with the real consumers (the six prose-producing plugins) each given their own direct
edge afterward (E2). The earlier vestigial-edge pass targeted edges pointing *to* `han-core`, not edges *from* it, so
this one survived (E9). Second, `han-github → han-core`: two of `han-github`'s three skills dispatch
`han-core:junior-developer`, and nothing else in the plugin touches `han-core` (E3). The suite already carries the
mechanism that makes this edge droppable: the config rule's degradation convention, where an agent name that does not
resolve to a dispatchable agent is skipped with a one-line note instead of failing the run (E7), and qualified
`plugin:agent` dispatch works whenever the hosting plugin happens to be installed (E8).

The tempting cuts that should not be made are equally evidence-backed. `han-atlassian`'s direct edges on `han-core` and
`han-communication` look redundant, because its three wrapped-skill dependencies each pull both in, but the repo's own
decision log records that dependency auto-install is one level deep, so those direct edges are load-bearing for a
standalone `han-atlassian` install (E10). Vendoring `readability-rule.md` and `writing-voice.md` into consuming plugins
would let some `han-communication` edges go soft, but the suite deliberately decided that standard lives in exactly one
canonical copy, and the win is small because `han-communication`'s whole closure is 2 skills and 1 agent (E11). The
runtime sizing controls (`default-swarm-size`, the sizing bands) govern how many agents a skill dispatches per run, not
how many are installed, so they are out of scope here (E13).

## Planned Fix

### Approach

Cut the unused `han-core → han-communication` edge, and convert `han-github`'s hard `han-core` edge into a soft,
degrade-gracefully dispatch of `han-core:junior-developer`, updating every documentation surface that narrates either
edge; make no change to the shared agent roster, the `han-atlassian` edges, or the readability single-copy decision.

The measurable effect: a standalone `han-github` install drops from 3 plugins / 6 skills / 23 agents to 2 plugins / 5
skills / 1 agent, and a standalone `han-core` install drops from 2 plugins / 3 skills / 23 agents to 1 plugin / 1 skill
/ 22 agents (E4). Meta-plugin installs are byte-for-byte unchanged in what they pull in, and `han-github`'s two
dispatching skills behave exactly as today whenever `han-core` is present.

No plugin version is bumped by this plan; versioning happens at release time through the release skill.

### Changes

#### `han-core/.claude-plugin/plugin.json`

- **Change:** Remove the `"dependencies": ["han-communication"]` entry, returning `han-core` to dependency-free.
- **Evidence:** (E2) zero invocations; (E9) precedent for pruning vestigial edges.
- **Standards:** YAGNI rule (a dependency with no consumer is speculative); evidence rule (the edge has no usage
  citation).
- **Details:** Delete the `dependencies` key. `han-communication` remains installed for every bundled-suite user via the
  meta-plugin and via the six prose-producing plugins' own direct edges (E1).

#### `han-github/skills/update-pr-description/SKILL.md`

- **Change:** Make the `han-core:junior-developer` dispatch degrade gracefully when the agent is not installed.
- **Evidence:** (E3) the dispatch site at line 96; (E7) the suite's existing skip-with-a-note degradation phrasing.
- **Standards:** config-rule degradation convention ("An entry that does not resolve to a dispatchable agent is
  skipped with the one-line note naming it").
- **Details:** After the existing "Launch a single han-core:junior-developer agent" instruction, add the fallback:
  when `han-core:junior-developer` does not resolve to a dispatchable agent, write the PR description directly in this
  skill's own context following the same instructions, and note in one line that the agent was unavailable. Dispatch
  remains the primary path.

#### `han-github/skills/post-code-review-to-pr/SKILL.md`

- **Change:** Same soft-dispatch fallback for the `han-core:junior-developer` launch at line 65.
- **Evidence:** (E3), (E7).
- **Standards:** config-rule degradation convention.
- **Details:** Mirror the update-pr-description fallback wording so the two sites stay consistent.

#### `han-github/.claude-plugin/plugin.json`

- **Change:** Drop `han-core` from `dependencies`, leaving `["han-communication"]`.
- **Evidence:** (E3) single-agent usage; (E4) closure cost of 1 extra plugin, 1 skill, 22 unused agents.
- **Standards:** YAGNI rule; evidence rule.
- **Details:** Apply only together with the two SKILL.md fallbacks above, never alone, so a standalone install without
  `han-core` degrades instead of breaking.

#### `han-core/README.md`

- **Change:** Update line 10, "Depends on `han-communication`.", to state the plugin depends on no other Han plugin.
- **Evidence:** (E12) doc surfaces that narrate the edge.
- **Standards:** one-canonical-source convention (README is canonical for what the plugin does).

#### `han-github/README.md`

- **Change:** Update line 7 to "Depends on `han-communication`. Works best with `han-core` installed; without it, the
  junior-developer review pass degrades to inline drafting." (wording to match the SKILL.md fallback).
- **Evidence:** (E3), (E12).
- **Standards:** one-canonical-source convention.

#### `CLAUDE.md`

- **Change:** Update the dependency narration: the repo-layout tree line for `han-github` already reads "depends on
  han-communication for the readability standard" and stays; the long composition paragraph and the `han-core` tree
  entry gain the corrected edges (han-core depends on nothing; han-github depends on han-communication, with han-core
  optional).
- **Evidence:** (E12).
- **Standards:** one-canonical-source convention; count-free convention (no new hardcoded roster totals).

#### `docs/choosing-a-han-plugin.md`

- **Change:** Update the `han-core` scent line (line 35, "depends on `han-communication`") and the `han-github` scent
  line (line 45, "depends on `han-core`"), plus the composition paragraph at lines 68-72 that lists `han-github` among
  the plugins depending on `han-core`.
- **Evidence:** (E12).
- **Standards:** indexes stay complete and accurate.

#### `docs/how-to/extend-han-with-plugin-dependencies.md`

- **Change:** Rework the passages that use the real `han-github → han-core` edge as the worked example ("`han-github`
  declares `han-core` because it genuinely cannot" at lines 185-187, the topology recaps at lines 42, 112, and
  165-168) and the parenthetical at lines 85-87 stating `han-core` takes one dependency on `han-communication`. The
  simplified example can keep its shape; the sentences that claim the real suite carries these edges change to match
  the new graph, and the soft-dependency fallback becomes a teaching point of its own.
- **Evidence:** (E10), (E12).
- **Standards:** YAGNI applies to docs.

#### `.claude-plugin/marketplace.json`

- **Change:** Fix the `han-planning` description's narration gap ("Depends on han-core" omits `han-communication`,
  which the manifest declares and the skills invoke). The `han-core` and `han-github` descriptions name neither cut
  edge, so they need no dependency wording change.
- **Evidence:** (E14).
- **Standards:** one-canonical-source convention.

### Options Considered and Not Recommended

- **Splitting the `han-core` agent roster by consuming plugin.** Rejected by prior art with measurement: han-planning
  dispatches 21 of the agents and han-coding 17, so a split duplicates most of the roster (E5).
- **Cutting `han-atlassian`'s direct `han-core` and `han-communication` edges.** The edges are structurally redundant
  given its other three dependencies, but auto-install is documented as one level deep, so they are load-bearing for a
  standalone install (E10). Keep them.
- **Vendoring the readability standard to soften `han-communication` edges.** Contradicts the deliberate
  single-canonical-copy decision, and the whole `han-communication` closure is 2 skills and 1 agent, so the win is too
  small to justify reversing a recorded decision (E11).
- **Relocating `project-scanner`.** It is the suite's only single-consumer agent, but its one consumer is `han-core`'s
  own `project-discovery` skill, so it already lives with its consumer and no install win exists (E6).

## Evidence Summary

All items carry the trust-class label "codebase" except where noted.

### E1: The declared dependency graph, verbatim

- **Source:** `han-core/.claude-plugin/plugin.json:5`, `han-documentation/.claude-plugin/plugin.json:5`,
  `han-research/.claude-plugin/plugin.json:5`, `han-planning/.claude-plugin/plugin.json:5`,
  `han-coding/.claude-plugin/plugin.json:5`, `han-github/.claude-plugin/plugin.json:5`,
  `han-reporting/.claude-plugin/plugin.json:5`, `han-atlassian/.claude-plugin/plugin.json:5`,
  `han/.claude-plugin/plugin.json:5-13`
- **Finding:**
  ```
  han-core:          ["han-communication"]
  han-documentation: ["han-communication", "han-core"]
  han-research:      ["han-communication", "han-core"]
  han-planning:      ["han-communication", "han-core"]
  han-coding:        ["han-communication", "han-core"]
  han-github:        ["han-communication", "han-core"]
  han-reporting:     ["han-communication"]
  han-atlassian:     ["han-communication", "han-core", "han-documentation", "han-planning", "han-coding"]
  han-communication, han-feedback, han-linear, han-plugin-builder: no dependencies key
  ```
- **Relevance:** The baseline graph the fix edits. The `.codex-plugin` manifests carry no `dependencies` field, so only
  the Claude manifests change.

### E2: `han-core → han-communication` has no invocation anywhere in `han-core`

- **Source:** `han-core/.claude-plugin/plugin.json:5`; negative greps for `han-communication:` and `readability` across
  `han-core/skills/` and `han-core/agents/`; `docs/plans/han-communication-plugin/artifacts/implementation-decision-log.md:32-36`
  (decision D-1); commit `ba2fe8b`
- **Finding:** No file under `han-core/` invokes a `han-communication` skill or the `readability-editor` agent. The
  edge was added in the phased rollout commit `ba2fe8b` before consumers were rewired; D-1's rationale names the six
  prose-producing plugins as the consumers, and each got its own direct edge, while D-1 also rejected relying on
  `han-core` as a transitive pass-through.
- **Relevance:** A declared dependency with zero usage and no pass-through purpose. The strongest cut candidate.

### E3: `han-github` uses exactly one `han-core` agent

- **Source:** `han-github/skills/update-pr-description/SKILL.md:96` ("Launch a single han-core:junior-developer agent
  to write the PR description directly."); `han-github/skills/post-code-review-to-pr/SKILL.md:65` ("Launch a single
  han-core:junior-developer agent in artifact-review mode"); negative grep over
  `han-github/skills/work-items-to-issues/SKILL.md`
- **Finding:** Two dispatch sites, both `han-core:junior-developer`; the third skill references no Han dependency at
  all.
- **Relevance:** The narrow edge: one agent out of twenty-two justifies the whole `han-core` closure for `han-github`.

### E4: Install-closure measurements

- **Source:** computed from E1 plus per-plugin counts of `*/skills/*/SKILL.md` and `*/agents/*.md`
- **Finding:**
  ```
  han-github standalone today:  3 plugins, 6 skills, 23 agents (uses 1 agent + 2 readability entry points)
  han-core standalone today:    2 plugins, 3 skills, 23 agents
  han-atlassian standalone:     6 plugins, 26 skills, 23 agents
  han (meta):                   28 skills, 24 agents
  after the fix: han-github standalone = 2 plugins, 5 skills, 1 agent; han-core standalone = 1 plugin, 1 skill, 22 agents
  ```
- **Relevance:** Quantifies "meaningfully": the two cuts remove 22 unused agent installs from each affected standalone
  install.

### E5: The shared roster resists splitting because usage overlaps

- **Source:** `docs/plans/han-core-restructure/investigation.md:27,45`; full dispatch table built from every
  `*/skills/*/SKILL.md`
- **Finding:** Every `han-core` domain specialist is dispatched by skills in at least two sibling plugins; the
  han-coding review rosters (`architectural-analysis`, `code-review`, `automated-test-planning`) are near-identical to
  the han-planning rosters (`plan-implementation`, `iterative-plan-review`, `plan-a-feature`) by design. The
  restructure plan recorded: splitting the roster between han-planning and han-coding would duplicate most of it.
- **Relevance:** Rules out the roster split as a footprint lever; the fix leaves the roster whole.

### E6: `project-scanner` is the suite's only single-consumer agent

- **Source:** `han-core/skills/project-discovery/SKILL.md:48,56` (the only two dispatch sites); negative grep for
  `project-scanner` across every other SKILL.md
- **Finding:** One consumer, and it lives in the same plugin as the agent.
- **Relevance:** No relocation win exists; documented so the idea is not re-litigated.

### E7: Graceful degradation is an existing suite-wide convention

- **Source:** `han-core/references/config-rule.md:59-60,64-65`; identical phrasing in
  `han-coding/skills/architectural-analysis/SKILL.md:166`, `han-planning/skills/iterative-plan-review/SKILL.md:229`,
  `han-planning/skills/plan-a-feature/SKILL.md:344`, `han-planning/skills/plan-implementation/SKILL.md:208`,
  `han-research/skills/gap-analysis/SKILL.md:189`
- **Finding:**
  ```
  "An entry that does not resolve to a dispatchable agent is skipped with the one-line note naming it."
  "A bad config can never fail a skill run; the worst it can do is be ignored."
  ```
- **Relevance:** The mechanical precedent the `han-github` soft dispatch reuses; no new infrastructure is needed.

### E8: Qualified `plugin:agent` dispatch already supports optional cross-plugin agents

- **Source:** `han-core/references/config-rule.md:25-26,54-60`;
  `docs/plans/namespace-qualified-agent-dispatch/investigation.md:16-20,62-70`
- **Finding:** The Extra Agents pool-join accepts qualified `plugin:agent` names from any installed plugin and degrades
  silently when one does not resolve; every dispatch site suite-wide already uses qualified names.
- **Relevance:** Confirms `han-core:junior-developer` resolves whenever `han-core` is installed, regardless of whether
  `han-github` declares the dependency.

### E9: Precedent: this audit was run once before and pruned three edges

- **Source:** commit `28ebf41` ("han-reporting, han-feedback, and han-linear drop their vestigial han-core
  dependencies"); `docs/plans/han-core-restructure/investigation.md:45-52`
- **Finding:** The v5.0.0 restructure removed unjustified edges pointing to `han-core`. Edges from `han-core` were not
  in that pass's scope.
- **Relevance:** Establishes both the precedent for pruning and why E2's edge survived it.

### E10: Auto-install is one level deep, so `han-atlassian`'s direct edges are load-bearing

- **Source:** `docs/plans/han-communication-plugin/artifacts/implementation-decision-log.md:36` ("repo guidance
  documents only one-level auto-install"); negative grep showing `han-atlassian` skills never invoke `han-core:` or
  `han-communication:` directly
- **Finding:** `han-atlassian` reaches both plugins only transitively through its wrapped skills, but with one-level
  auto-install the direct declarations are what guarantee they are present on a standalone install.
- **Relevance:** Counter-evidence that keeps the `han-atlassian` edges in place. Trust note: the one-level-auto-install
  claim is a repo-internal citation of external Claude Code documentation and was not independently re-verified against
  that documentation during this investigation; the fix treats it as true and takes the conservative option (keep the
  edges), so being wrong could only mean a further reduction was missed, not that the plan breaks anything.

### E11: The readability standard is deliberately single-copy, unlike the other shared rules

- **Source:** `han-communication/references/readability-rule.md`, `han-communication/references/writing-voice.md` (the
  only copies; a find across the repo returns no vendored duplicates); vendored `evidence-rule.md`, `yagni-rule.md`,
  and `config-rule.md` copies across the other plugins; `docs/plans/han-communication-plugin/feature-specification.md:1-13,47-51`
- **Finding:** Every other shared rule is vendored byte-identical per plugin; the readability pair is deliberately
  canonical-only, sourced at runtime through `han-communication:readability-guidance`.
- **Relevance:** Vendoring it would reverse a recorded decision for a 2-skill, 1-agent win; the fix leaves it alone.

### E12: The documentation surfaces that narrate the two edges

- **Source:** `han-core/README.md:10`; `han-github/README.md:7`; `CLAUDE.md` (repo-layout tree and composition
  paragraph); `docs/choosing-a-han-plugin.md:35,45,68-72`;
  `docs/how-to/extend-han-with-plugin-dependencies.md:42,85-87,112,165-168,185-187`
- **Finding:** Six surfaces state one or both edges; the how-to doc uses `han-github → han-core` as its worked example
  and states "`han-github` declares `han-core` because it genuinely cannot" produce a review without the agent.
- **Relevance:** The full blast radius of the manifest changes; each surface appears in the Changes list.

### E13: Sizing controls govern per-run dispatch, not install footprint

- **Source:** `docs/sizing.md:14-15,52,110-115`; `han-core/references/config-rule.md:15-24` (`default-swarm-size`)
- **Finding:** The size bands and `default-swarm-size` cap how many agents a skill dispatches per invocation; nothing
  in them affects which agents must be installed.
- **Relevance:** Scope boundary: runtime sizing is a different axis and is not touched by this plan.

### E14: Marketplace narration gap for `han-planning`

- **Source:** `.claude-plugin/marketplace.json` (`han-planning` description: "Depends on han-core; bundled by the han
  meta-plugin."), versus `han-planning/.claude-plugin/plugin.json:5` declaring both edges
- **Finding:** The description omits `han-communication`, which the manifest declares and the skills invoke.
- **Relevance:** A drift found during the audit; fixed alongside the other narration updates.

## Coding Standards Reference

| Standard                                          | Source                                                              | Applies To                                            |
| ------------------------------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------- |
| YAGNI rule: no speculative structure              | `han-core/references/yagni-rule.md` (vendored suite-wide)           | Removing the unused edge; not adding new plugins      |
| Evidence rule: every claim carries a citation     | `han-core/references/evidence-rule.md` (vendored suite-wide)        | Every edge kept or cut is tied to an E-item           |
| Degradation convention: skip unresolvable agents  | `han-core/references/config-rule.md:59-60`                          | The `han-github` soft-dispatch fallback wording       |
| One canonical source per concept                  | `CLAUDE.md` Conventions                                             | README, index, and CLAUDE.md narration updates        |
| Count-free convention: no hardcoded entity totals | inferred from repo memory and index conventions in `CLAUDE.md`      | No new roster counts added to plugin docs             |
| No unprompted version bumps                       | repo working convention                                             | plugin.json edits touch `dependencies` only           |
