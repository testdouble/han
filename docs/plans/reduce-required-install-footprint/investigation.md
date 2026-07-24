# Investigation: Reducing the Required Skills and Agents Installed with Any Given Han Plugin

This plan cuts one unused plugin dependency and adds one missing one, so each Han plugin installs only what it
needs. Read the Summary, then approve the Planned Fix or push back.

## Summary

- **Root Cause:** Plugin-level dependency edges are the only install-granularity mechanism. One edge is carried with
  zero usage: `han-core` declares `han-communication` and never invokes it (E2). A second edge, `han-github → han-core`,
  turned out to be real, but it sits next to an undeclared `han-coding` dependency the manifest is missing (E15).
- **Fix:** Cut the unused `han-core → han-communication` edge and declare `han-github`'s missing `han-coding`
  dependency, then correct every documentation surface that narrates either graph edge. Leave the shared agent roster,
  the `han-atlassian` edges, and the readability single-copy decision alone.
- **Why Correct:** Independent re-search confirmed zero `han-communication` invocations inside `han-core` and confirmed
  every consumer already declares its own direct edge, so the cut can strand nothing (E2, V5, V6).
- **Validation Outcome:** Validation refuted the draft's second cut. Softening `han-github`'s `han-core` edge rested on
  closure numbers that missed the `/code-review` skill invocation (V1). It also borrowed a degradation precedent that
  does not cover baseline dispatch sites (V2), and it would have dropped the very review pass the skills call their
  asset (V3). That cut was withdrawn and replaced with the missing-dependency repair.
- **Remaining Risks:** The one-level auto-install premise is single-sourced from an internal decision log. The failure
  mode of invoking `/code-review` without `han-coding` installed was not tested live. See the Confidence Assessment.

## Problem Statement

Installing a single Han plugin can pull in more skills and agents than that plugin uses, and in one case fewer than it
needs. `han-core` declares a dependency on `han-communication` that nothing inside `han-core` invokes (E2), so a
standalone `han-core` install carries 2 extra skills and 1 extra agent for nothing.

`han-github` has the opposite problem. It declares `han-core` for one agent, but its central skill also invokes the
`han-coding:code-review` skill, a dependency its manifest never declares. A standalone `han-github` install cannot run
that skill's main step at all (E3, E15).

The question this investigation answers: which changes would meaningfully reduce the number of required skills and
agents installed with any given Han plugin, and which reductions look tempting but should not be made.

The impact falls on operators who install one plugin rather than the `han` meta-plugin: every unused agent definition
still loads its description into session context and appears in the agent roster. Meta-plugin users are unaffected by
the proposed cut, because the meta-plugin declares `han-communication` directly (V6).

## Why the Graph Has an Unused Edge and a Missing One

### Root Cause

Plugin-level dependency edges are the only install-granularity mechanism available, and one edge is carried without any
usage: `han-core → han-communication` has zero invocations (E2). Every other edge is either already minimal, justified
by broad overlapping usage that resists further splitting (E5, E9), or, in `han-github`'s case, understated rather than
overstated (E15).

### How the Extra Edge Survived and the Missing One Surfaced

The suite already took its biggest footprint reduction. The v5.0.0 restructure split the old `han-core` into
`han-core`, `han-documentation`, and `han-research`, and dropped vestigial `han-core` edges from `han-reporting`,
`han-feedback`, and `han-linear` (E9).

That earlier work also set the boundary on going further: the shared specialist roster stays in one plugin because
almost every specialist is dispatched by skills in at least two sibling plugins, so splitting the roster would
duplicate most of it (E5). Three plugins already install with no Han dependencies at all (`han-feedback`, `han-linear`,
`han-plugin-builder`), and `han-reporting` needs only `han-communication` (E1).

One edge survived that earlier pruning pass without justification. No skill or agent in `han-core` invokes any
`han-communication` capability. The decision log that introduced the edge shows it was added for phase sequencing, and
the real consumers, the six prose-producing plugins, were each later given their own direct edge (E2). The earlier
vestigial-edge pass targeted edges pointing *to* `han-core`, not edges *from* it, so this one was never audited (E9).
Independent re-search during validation confirmed the zero-invocation claim. It also confirmed no hook or
codex-manifest dispatch surface exists, and confirmed no plugin reaches `han-communication` only transitively through
`han-core`. The cut can strand nothing (V5, V6).

The draft's second cut did not survive validation. `han-github`'s `han-core` edge looked narrow on paper: two
dispatches of `han-core:junior-developer` (E3). But validation found that `post-code-review-to-pr` also invokes the
`han-coding:code-review` skill as its central step, a dependency `han-github`'s manifest has never declared (E15, V1).
The draft's closure arithmetic never counted that edge, so its headline reduction described an install that could not
run the skill it ships.

The proposed soft-dispatch fallback also borrowed authority it did not have. The degradation convention it cited is
scoped to config-named Extra Agents, not to a skill's baseline dispatch table (V2). And degrading
`post-code-review-to-pr`'s junior-developer pass would post an unreviewed draft to a public PR (V3). The honest repair
runs the other way: declare the `han-coding` edge so the manifest matches what the plugin already requires.

Some tempting cuts should not be made, and each is evidence-backed. `han-atlassian`'s direct edges on `han-core` and
`han-communication` look redundant, because its three wrapped-skill dependencies each pull both in. But the repo's own
decision log records that dependency auto-install is one level deep, so those direct edges are load-bearing for a
standalone `han-atlassian` install (E10).

Vendoring `readability-rule.md` and `writing-voice.md` into consuming plugins would let some `han-communication` edges
go soft. But the suite deliberately decided that standard lives in exactly one canonical copy, and the win is small
because `han-communication`'s whole closure is 2 skills and 1 agent (E11).

The runtime sizing controls (`default-swarm-size`, the sizing bands) govern how many agents a skill dispatches per run,
not how many are installed. They are out of scope here (E13).

## Planned Fix

### Approach

Cut the unused `han-core → han-communication` edge, declare `han-github`'s missing `han-coding` dependency, and update
every documentation surface that narrates either edge. Make no change to the shared agent roster, the `han-atlassian`
edges, or the readability single-copy decision.

The measurable effect: a standalone `han-core` install drops from 2 plugins / 3 skills / 23 agents to 1 plugin / 1
skill / 22 agents (E4).

The `han-github` change moves in the other direction on purpose. Its declared closure grows to match what the plugin
already needs to function, repairing a broken standalone install rather than shrinking a working one (E15).
Meta-plugin installs are unchanged in what they pull in (V6), and no skill's runtime behavior changes.

No plugin version is bumped by this plan; versioning happens at release time through the release skill.

### Changes

#### `han-core/.claude-plugin/plugin.json`

- **Change:** Remove the `"dependencies": ["han-communication"]` entry, returning `han-core` to dependency-free.
- **Evidence:** (E2) zero invocations, independently re-confirmed (V5); (V6) no consumer is stranded; (E9) precedent
  for pruning vestigial edges.
- **Standards:** YAGNI rule (a dependency with no consumer is speculative); evidence rule (the edge has no usage
  citation).
- **Details:** Delete the `dependencies` key. `han-communication` remains installed for every bundled-suite user via the
  meta-plugin's own direct declaration and the six prose-producing plugins' direct edges (E1, V6).

#### `han-github/.claude-plugin/plugin.json`

- **Change:** Add `han-coding` to `dependencies`, giving `["han-communication", "han-core", "han-coding"]`.
- **Evidence:** (E15) `post-code-review-to-pr` invokes the `han-coding:code-review` skill as its central step and the
  manifest never declares the edge (V1).
- **Standards:** evidence rule; the how-to guide's own principle that "the dependency is honest about what it needs"
  (`docs/how-to/extend-han-with-plugin-dependencies.md:185-187`).
- **Details:** `han-coding`'s own dependencies (`han-communication`, `han-core`) are already declared by `han-github`
  directly, so one-level auto-install resolves the whole closure (E10).

#### `han-core/README.md`

- **Change:** Update line 10, "Depends on `han-communication`.", to state the plugin depends on no other Han plugin.
- **Evidence:** (E12).
- **Standards:** one-canonical-source convention (README is canonical for what the plugin does).

#### `han-github/README.md`

- **Change:** Update line 7, "Depends on `han-communication` and `han-core`.", to also name `han-coding`.
- **Evidence:** (E15), (E12).
- **Standards:** one-canonical-source convention.

#### `CLAUDE.md`

- **Change:** Three narration corrections:
  1. The intro paragraph's and repo-layout tree's `han-core` entries drop "depends on `han-communication`".
  2. The composition paragraph at line 163 removes `han-core` from the list of plugins declaring a direct
     `han-communication` dependency.
  3. The `han-github` tree entry, which today reads "depends on han-communication for the readability standard", gains
     the full edge set (`han-communication`, `han-core`, `han-coding`).
- **Evidence:** (E12), (E15).
- **Standards:** one-canonical-source convention; count-free convention (no new hardcoded roster totals).

#### `docs/choosing-a-han-plugin.md`

- **Change:** Update the `han-core` scent line (line 35, "Bundled; depends on `han-communication`.") to dependency-free
  wording, and the `han-github` scent line (line 45) to name `han-coding` alongside `han-core`.
- **Evidence:** (E12), (E15).
- **Standards:** indexes stay complete and accurate.

#### `docs/how-to/extend-han-with-plugin-dependencies.md`

- **Change:** Update the parenthetical at lines 85-87, which states `han-core` "takes one dependency — on the
  foundational `han-communication` plugin… the first dependency `han-core` has ever had", to reflect the dependency-free
  base. The `han-github → han-core` worked-example passages (lines 42, 112, 165-168, 185-187) stay true under the
  rescoped fix and need no change.
- **Evidence:** (E12).
- **Standards:** YAGNI applies to docs.

#### `docs/how-to/provide-feedback.md`

- **Change:** Fix line 90, which claims `han-feedback` "depends on `han-core`, so Claude Code pulls core along". The
  manifest has no `dependencies` key, and the v5.0.0 restructure removed that edge on purpose (E9); this is
  pre-existing drift found during validation (V4).
- **Evidence:** (V4), (E1), (E9).
- **Standards:** one-canonical-source convention.

#### `.claude-plugin/marketplace.json`

- **Change:** Fix the `han-planning` description's narration gap ("Depends on han-core" omits `han-communication`,
  which the manifest declares and the skills invoke). The `han-core` and `han-github` descriptions name no specific
  edges, so they need no dependency wording change.
- **Evidence:** (E14).
- **Standards:** one-canonical-source convention.

### Options Considered and Not Recommended

- **Softening `han-github → han-core` into an optional, degrade-gracefully dispatch.** The draft of this report
  recommended it; validation refuted it three ways. The closure numbers behind it missed the undeclared `han-coding`
  edge, so the promised reduction described a broken install (V1, E15). The degradation convention cited as precedent
  is scoped to config-named Extra Agents, not baseline dispatch sites, so the fallback would be new convention under
  borrowed authority (V2). And degrading `post-code-review-to-pr` would post an unreviewed draft to a public PR,
  discarding what the skill's own text calls "the asset here" (V3).
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
  the Claude manifests change. Validation re-parsed every array with a script and confirmed the transcription (V6).

### E2: `han-core → han-communication` has no invocation anywhere in `han-core`

- **Source:** `han-core/.claude-plugin/plugin.json:5`; negative greps for `han-communication:` and `readability` across
  `han-core/skills/` and `han-core/agents/`; `docs/plans/han-communication-plugin/artifacts/implementation-decision-log.md:32-36`
  (decision D-1); commit `ba2fe8b`
- **Finding:** No file under `han-core/` invokes a `han-communication` skill or the `readability-editor` agent. The
  edge was added in the phased rollout commit `ba2fe8b` before consumers were rewired. D-1's rationale names the six
  prose-producing plugins as the consumers, and each got its own direct edge; D-1 also rejected relying on `han-core`
  as a transitive pass-through. Validation independently re-ran the searches: the only `readability` hits under
  `han-core/` are prose in `han-core/README.md:4,10` and a cross-reference list entry in
  `han-core/docs/agents/junior-developer.md:322`. Neither is an invocation (V5).
- **Relevance:** A declared dependency with zero usage and no pass-through purpose. The strongest cut candidate, and
  the one that survived adversarial validation cleanly.

### E3: `han-github`'s direct agent usage is one `han-core` agent, alongside a skill-level `han-coding` invocation

- **Source:** `han-github/skills/update-pr-description/SKILL.md:96` ("Launch a single han-core:junior-developer agent
  to write the PR description directly."); `han-github/skills/post-code-review-to-pr/SKILL.md:65` ("Launch a single
  han-core:junior-developer agent in artifact-review mode"); negative grep over
  `han-github/skills/work-items-to-issues/SKILL.md`
- **Finding:** Two agent-dispatch sites, both `han-core:junior-developer`; the third skill references no Han dependency
  at all. The draft read this as "one agent justifies the whole `han-core` closure"; validation corrected the frame by
  surfacing the `/code-review` skill invocation recorded as E15.
- **Relevance:** The narrow-looking edge that motivated the withdrawn soft-dispatch idea.

### E4: Install-closure measurements

- **Source:** computed from E1 plus per-plugin counts of `*/skills/*/SKILL.md` and `*/agents/*.md`
- **Finding:**
  ```
  han-core standalone today:    2 plugins, 3 skills, 23 agents
  han-github standalone today:  3 plugins declared, 6 skills, 23 agents
                                (functionally incomplete: post-code-review-to-pr also needs han-coding, E15)
  han-atlassian standalone:     6 plugins, 26 skills, 23 agents
  han (meta):                   28 skills, 24 agents
  after the fix: han-core standalone = 1 plugin, 1 skill, 22 agents
                 han-github declared = 4 plugins, 15 skills, 23 agents (now matching what the skills invoke)
  ```
- **Relevance:** Quantifies the one real reduction and makes the `han-github` correction explicit instead of counting
  an install that could not run its own central skill. Amended after V1.

### E5: The shared roster resists splitting because usage overlaps

- **Source:** `docs/plans/han-core-restructure/investigation.md:27,45`; full dispatch table built from every
  `*/skills/*/SKILL.md`
- **Finding:** Every `han-core` domain specialist is dispatched by skills in at least two sibling plugins. The
  han-coding review rosters (`architectural-analysis`, `code-review`, `automated-test-planning`) are near-identical to
  the han-planning rosters (`plan-implementation`, `iterative-plan-review`, `plan-a-feature`) by design. The
  restructure plan recorded: splitting the roster between han-planning and han-coding would duplicate most of it.
- **Relevance:** Rules out the roster split as a footprint lever; the fix leaves the roster whole. The 21-of-agents /
  17-of-agents dispatch counts are carried from the restructure plan and were not independently recounted in the
  validation pass (see Remaining Risks).

### E6: `project-scanner` is the suite's only single-consumer agent

- **Source:** `han-core/skills/project-discovery/SKILL.md:48,56` (the only two dispatch sites); negative grep for
  `project-scanner` across every other SKILL.md
- **Finding:** One consumer, and it lives in the same plugin as the agent.
- **Relevance:** No relocation win exists; documented so the idea is not re-litigated.

### E7: The degradation convention exists, but only for config-named extra agents

- **Source:** `han-core/references/config-rule.md:54-60,64-65` (section "Extra agents joining the pool"); identical
  phrasing in `han-coding/skills/architectural-analysis/SKILL.md:163-166`,
  `han-planning/skills/iterative-plan-review/SKILL.md:229`, `han-planning/skills/plan-a-feature/SKILL.md:344`,
  `han-planning/skills/plan-implementation/SKILL.md:208`, `han-research/skills/gap-analysis/SKILL.md:189`
- **Finding:**
  ```
  "An entry that does not resolve to a dispatchable agent is skipped with the one-line note naming it."
  "A bad config can never fail a skill run; the worst it can do is be ignored."
  ```
  Every citation site is prefaced by "Extra agents named in the project config's `## Extra Agents` list"; none applies
  the convention to a skill's fixed, always-fired dispatch instructions (V2).
- **Relevance:** The draft cited this as ready-made precedent for softening a baseline dispatch; validation showed that
  reading over-reached, which is one of the three reasons the soft-dispatch option was withdrawn.

### E8: Qualified `plugin:agent` dispatch already supports optional cross-plugin agents

- **Source:** `han-core/references/config-rule.md:25-26,54-60`;
  `docs/plans/namespace-qualified-agent-dispatch/investigation.md:16-20,62-70`
- **Finding:** The Extra Agents pool-join accepts qualified `plugin:agent` names from any installed plugin and degrades
  silently when one does not resolve; every dispatch site suite-wide already uses qualified names.
- **Relevance:** Background on the dispatch mechanism; any future optional-agent-pack design would build on it.

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
- **Relevance:** Counter-evidence that keeps the `han-atlassian` edges in place, and the premise that lets the new
  `han-github` declaration stop at `han-coding` without re-declaring its closure. Trust note: the one-level claim is a
  repo-internal citation of external Claude Code documentation, single-sourced from one decision log. Validation found
  the repo's own how-to paraphrase carries no explicit one-level caveat (V5), and it was not re-verified against the
  external documentation. The fix treats it as true and takes the conservative option, so being wrong could only mean a
  further reduction was missed, not that the plan breaks anything.

### E11: The readability standard is deliberately single-copy, unlike the other shared rules

- **Source:** `han-communication/references/readability-rule.md`, `han-communication/references/writing-voice.md` (the
  only copies; a find across the repo returns no vendored duplicates); vendored `evidence-rule.md`, `yagni-rule.md`,
  and `config-rule.md` copies across the other plugins; `docs/plans/han-communication-plugin/feature-specification.md:1-13,47-51`
- **Finding:** Every other shared rule is vendored byte-identical per plugin; the readability pair is deliberately
  canonical-only, sourced at runtime through `han-communication:readability-guidance`.
- **Relevance:** Vendoring it would reverse a recorded decision for a 2-skill, 1-agent win; the fix leaves it alone.

### E12: The documentation surfaces that narrate the affected edges

- **Source:** `han-core/README.md:10`; `han-github/README.md:7`; `CLAUDE.md` (intro paragraph, repo-layout tree entries
  for `han-core` and `han-github`, and the composition paragraph at line 163 listing `han-core` among the direct
  `han-communication` dependents); `docs/choosing-a-han-plugin.md:35,45`;
  `docs/how-to/extend-han-with-plugin-dependencies.md:85-87`; `docs/how-to/provide-feedback.md:90` (pre-existing drift,
  V4)
- **Finding:** These surfaces state the `han-core → han-communication` edge, understate `han-github`'s edges, or (in
  the provide-feedback case) state an edge that no longer exists at all. The draft's list missed the CLAUDE.md
  composition paragraph and the provide-feedback drift; validation's repo-wide grep surfaced them (V4). Two surfaces
  the draft planned to rework, `docs/concepts.md:238-240` and `docs/how-to/build-a-plugin-that-depends-on-han.md:14`,
  stay true under the rescoped fix and drop out of the change list.
- **Relevance:** The blast radius of the manifest changes; each surface appears in the Changes list. Amended after V4.

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

### E15: `post-code-review-to-pr` invokes the `han-coding:code-review` skill, an edge the manifest never declares

- **Source:** `han-github/skills/post-code-review-to-pr/SKILL.md:40-41` ("Invoke the `/code-review` skill to perform
  the full code review."); `han-coding/skills/code-review/SKILL.md` (the skill's home);
  `han-github/docs/skills/post-code-review-to-pr.md:150` ("The skill this one wraps");
  `han-github/.claude-plugin/plugin.json:5` (no `han-coding` entry)
- **Finding:** The skill's central step (Step 2, "Run Code Review") resolves only when `han-coding` is installed, and
  `han-github` does not declare it. Surfaced by adversarial validation (V1).
- **Relevance:** Invalidated the draft's `han-github` closure arithmetic and its cut; drives the missing-dependency
  repair in the Planned Fix.

## Validation Results

An adversarial validation pass re-ran every search behind the evidence, challenged the fix design, and swept for missed
surfaces. Its findings are numbered V1 to V6. The pass rated the draft plan's confidence Low; the Adjustments Made
section records how the plan changed in response, and the Confidence Assessment reflects the rescoped plan.

### Counter-Evidence Investigated

#### V1: The draft's `han-github` closure numbers ignored an undeclared `han-coding` dependency

- **Hypothesis:** E3's "han-github uses exactly one han-core agent and nothing else outside han-communication/han-core"
  was incomplete.
- **Investigation:** `han-github/skills/post-code-review-to-pr/SKILL.md:40-41` invokes the `/code-review` skill, which
  lives at `han-coding/skills/code-review/SKILL.md`. `han-github/docs/skills/post-code-review-to-pr.md:150` confirms
  the wrap. `han-github/.claude-plugin/plugin.json` declares no `han-coding` edge.
- **Result:** Refuted (the draft's claim did not hold).
- **Impact:** The draft's headline reduction for `han-github` described an install that could not run its central
  skill. The soft-dispatch cut was withdrawn and replaced by declaring the missing `han-coding` edge; E3, E4, and E12
  were amended.

#### V2: The cited degradation precedent does not cover baseline dispatch sites

- **Hypothesis:** The config-rule degradation convention applies to hardcoded SKILL.md dispatch instructions.
- **Investigation:** `han-core/references/config-rule.md:54-60` scopes the rule to the `## Extra Agents` config list;
  all five E7 citation sites are prefaced by "Extra agents named in the project config's `## Extra Agents` list".
- **Result:** Refuted (the draft's precedent claim did not hold).
- **Impact:** The soft-dispatch design would have been new convention presented as reuse. Recorded in E7's amended
  finding and in the withdrawn option's rationale.

#### V3: Degrading the junior-developer pass discards the skills' stated asset

- **Hypothesis:** Making `han-core:junior-developer` optional guts the two `han-github` skills' value.
- **Investigation:** `han-github/skills/update-pr-description/SKILL.md:96-99` names the fresh-reviewer perspective "the
  asset here"; `han-github/skills/post-code-review-to-pr/SKILL.md:64-68` uses the same agent as a pre-post clarity gate
  on a publicly visible PR comment.
- **Result:** Partially Refuted (the draft acknowledged the degrade but never weighed the quality cost, which is
  sharpest where the output posts publicly).
- **Impact:** Second independent reason the soft-dispatch option moved to Options Considered and Not Recommended.

#### V4: The documentation blast radius was undercounted

- **Hypothesis:** E12's surface list was incomplete.
- **Investigation:** Repo-wide grep for dependency narration found `docs/concepts.md:238-240` and
  `docs/how-to/build-a-plugin-that-depends-on-han.md:14` stating the `han-github → han-core` edge. It also found
  `docs/how-to/provide-feedback.md:90` claiming a `han-feedback → han-core` edge that was removed in v5.0.0.
- **Result:** Refuted (the draft's "full blast radius" claim did not hold).
- **Impact:** E12 amended. Under the rescoped fix the two `han-github`-edge surfaces stay true and drop out; the
  provide-feedback drift joins the Changes list as a repair.

#### V5: E2's zero-invocation claim, re-searched independently

- **Hypothesis:** Something in `han-core` (skills, agents, hooks, codex manifests, docs instructing runtime invocation)
  invokes `han-communication`, or some plugin reaches `han-communication` only transitively through `han-core`.
- **Investigation:** Re-ran the greps across `han-core/`. Checked every `.codex-plugin/plugin.json` for `dependencies`.
  Swept for `hooks/` directories and `"hooks"` manifest keys (none exist outside guidance templates). Checked every
  opt-in plugin's skills for `han-communication:`/`han-core:` invocation strings against their declared dependencies
  (only documentation-pattern text found). Also cross-checked E10's one-level auto-install premise: it is
  single-sourced from the decision log, and the repo's own how-to paraphrase of the external docs carries no explicit
  one-level caveat.
- **Result:** Confirmed for E2 (zero invocations holds; no hidden dispatch surface; no transitive reliance).
  Partially Refuted for E10's premise (single-sourced and unverified externally).
- **Impact:** The `han-core → han-communication` cut stands on re-verified evidence. E10 now carries the trust note;
  the unverified premise stays a remaining risk that can only hide a further reduction, not break this plan.

#### V6: No consumer is stranded by the cut, and meta-plugin installs are unchanged

- **Hypothesis:** Some plugin depends on `han-core` without also declaring `han-communication`, or the meta-plugin
  reaches `han-communication` only through `han-core`.
- **Investigation:** Script-parsed every plugin's `dependencies` array; every plugin declaring `han-core` also declares
  `han-communication` directly, and `han/.claude-plugin/plugin.json` declares `han-communication` itself.
- **Result:** Confirmed.
- **Impact:** Supports the cut as scoped; no adjustment needed.

### Adjustments Made

- Withdrew the `han-github` soft-dispatch cut and its SKILL.md fallback changes; moved it to Options Considered and Not
  Recommended (triggered by V1, V2, V3).
- Added the `han-github/.claude-plugin/plugin.json` change declaring `han-coding`, and added E15 (triggered by V1).
- Amended E3's framing, E4's closure numbers, and E7's finding and relevance (triggered by V1, V2).
- Amended E12's surface list, dropped the two surfaces that stay true under the rescope, and added the
  `docs/how-to/provide-feedback.md:90` repair to the Changes list (triggered by V4).
- Added the trust note and single-source caveat to E10 (triggered by V5).
- Rewrote the Root Cause, Approach, and Summary to match the rescoped fix (triggered by V1 through V4).

### Confidence Assessment

- **Confidence:** High for the rescoped plan. The validator rated the draft Low, driven entirely by the `han-github`
  cut (V1 through V4). Every refuted element was withdrawn or repaired, and the surviving cut is the one part the
  validator confirmed cleanly under independent re-search (V5, V6).
- **Remaining Risks:** The one-level auto-install premise (E10) remains single-sourced and externally unverified. If
  it is wrong, a further `han-atlassian` reduction was missed, but nothing in this plan breaks. The live failure mode
  of invoking `/code-review` when `han-coding` is absent (loud error versus silent misresolution) was not tested in a
  sandboxed install; the fix removes the case by declaring the edge, but the behavior is worth one manual test at
  implementation time. E5's dispatch counts (21 and 17) are carried from the restructure plan and were not
  independently recounted.

## Coding Standards Reference

| Standard                                          | Source                                                              | Applies To                                            |
| ------------------------------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------- |
| YAGNI rule: no speculative structure              | `han-core/references/yagni-rule.md` (vendored suite-wide)           | Removing the unused edge; not adding new plugins      |
| Evidence rule: every claim carries a citation     | `han-core/references/evidence-rule.md` (vendored suite-wide)        | Every edge kept, cut, or added is tied to an E-item   |
| Honest dependency declaration                     | `docs/how-to/extend-han-with-plugin-dependencies.md:185-187`        | Declaring `han-github`'s missing `han-coding` edge    |
| One canonical source per concept                  | `CLAUDE.md` Conventions                                             | README, index, and CLAUDE.md narration updates        |
| Count-free convention: no hardcoded entity totals | inferred from repo memory and index conventions in `CLAUDE.md`      | No new roster counts added to plugin docs             |
| No unprompted version bumps                       | repo working convention                                             | plugin.json edits touch `dependencies` only           |
