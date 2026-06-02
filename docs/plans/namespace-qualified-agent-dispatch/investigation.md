# Investigation: Agent swarms must dispatch agents by full `namespace:agent-name`, not bare `agent-name`

The Han swarming and dispatcher skills reference their specialist sub-agents by bare `agent-name`, which is not how Claude Code registers plugin-provided agents; every dispatch must use the defining plugin's namespace, which is `han.core:`.

## Problem Statement

- **Symptoms:** Skills across the suite dispatch sub-agents by bare name (e.g. `subagent_type: "structural-analyst"`, or prose like "Launch `junior-developer`"). The one site that does qualify uses the wrong prefix: `han.core/skills/plan-work-items/SKILL.md:82` dispatches `subagent_type: "han:project-manager"` (the meta-plugin prefix), and `docs/agents/project-manager.md` documents the same `han:project-manager` form.
- **Expected behavior:** Every agent dispatch names the agent under the namespace of the plugin that *defines* it. All 23 agents live in `han.core/agents/`, so every dispatch should read `han.core:agent-name`.
- **Conditions:** Affects any run of a dispatcher skill. Bare names resolve only when the name is unique across every installed plugin and the user/project scopes; the moment another installed plugin (or a user/project agent) shares a generic name like `data-engineer`, `test-engineer`, or `software-architect`, resolution is ambiguous. The `han:`-prefixed site fails outright because the `han` plugin contains no agents at all.
- **Impact:** Unreliable or failing sub-agent dispatch in every swarming skill: `architectural-analysis`, `code-review`, `gap-analysis`, `investigate`, `iterative-plan-review`, `plan-a-feature`, `plan-implementation`, `research`, plus the other dispatchers (`architectural-decision-record`, `coding-standard`, `plan-work-items`, `project-discovery`, `project-documentation`, `plan-a-phased-build`, `test-planning`) and two `han.github` skills.

## Evidence Summary

The full site-by-site enumeration produced 66 findings (E1–E66 in the working notes). They are consolidated here by category; the full list lives in the per-file edits.

### E1: All 23 agents are defined in the `han.core` plugin

- **Source:** `han.core/agents/` (23 `.md` files); `han.core/.claude-plugin/plugin.json`
- **Finding:** `plugin.json` declares `"name": "han.core"`. The agents: `adversarial-security-analyst`, `adversarial-validator`, `behavioral-analyst`, `codebase-explorer`, `concurrency-analyst`, `content-auditor`, `data-engineer`, `devops-engineer`, `edge-case-explorer`, `evidence-based-investigator`, `gap-analyzer`, `information-architect`, `junior-developer`, `on-call-engineer`, `project-manager`, `project-scanner`, `research-analyst`, `risk-analyst`, `software-architect`, `structural-analyst`, `system-architect`, `test-engineer`, `user-experience-designer`.
- **Relevance:** The plugin `name` field determines the namespace for that plugin's components. The defining plugin is `han.core`, so the canonical prefix is `han.core:`.

### E2: The `han` meta-plugin has no agents of its own

- **Source:** `han/.claude-plugin/plugin.json`
- **Finding:** `{"name": "han", "version": "3.0.0", "dependencies": ["han.core", "han.github", "han.reporting"]}` — no `agents/` directory, no components.
- **Relevance:** `han:project-manager` cannot resolve: the `han` plugin contains no `project-manager`. Dependencies install the dependency as a separate plugin; they do not re-export the dependency's components under the parent's namespace.

### E3: Bare-name dispatch across the swarming skills

- **Source:** e.g. `han.core/skills/architectural-analysis/SKILL.md:96`, `han.core/skills/code-review/SKILL.md:126-235`, `han.core/skills/investigate/SKILL.md:37-70`, `han.core/skills/gap-analysis/SKILL.md:60-169`, `han.core/skills/iterative-plan-review/SKILL.md:105-137`, `han.core/skills/plan-a-feature/SKILL.md:178-241`, `han.core/skills/plan-implementation/SKILL.md:93-252`, `han.core/skills/research/SKILL.md:72-120`, `han.core/skills/test-planning/SKILL.md:58-118`, `han.core/skills/architectural-decision-record/SKILL.md:68-82`, `han.core/skills/coding-standard/SKILL.md:103-239`, `han.core/skills/project-discovery/SKILL.md:27-33`, `han.core/skills/project-documentation/SKILL.md:43-100`, `han.core/skills/plan-a-phased-build/SKILL.md:150`, `han.github/skills/post-code-review-to-pr/SKILL.md:52`, `han.github/skills/update-pr-description/SKILL.md:52`
- **Finding:** Every agent dispatch in these files names the agent bare, with no namespace prefix.
- **Relevance:** This is the bug surface; each of these sites needs the `han.core:` prefix.

### E4: The one qualified site uses the wrong prefix (`han:`)

- **Source:** `han.core/skills/plan-work-items/SKILL.md:82`
- **Finding:** `Launch \`project-manager\` (\`subagent_type: "han:project-manager"\`, \`model: "sonnet"\`) with:`
- **Relevance:** This is the only `subagent_type`-with-namespace dispatch in the suite, and it picked the meta-plugin prefix. It is itself a bug (E2), not the standard to copy.

### E5: The agent invocation example in the docs also uses `han:`

- **Source:** `docs/agents/project-manager.md` ("How to invoke it" section)
- **Finding:** "Dispatch via the `Agent` tool with `subagent_type: han:project-manager`."
- **Relevance:** Documentation propagates the wrong prefix; it must be corrected alongside the skills.

### E6: No agent definition file dispatches another agent via an executable call

- **Source:** `han.core/agents/*.md`
- **Finding:** No agent `.md` contains an `Agent` tool call or a `subagent_type` field. `project-manager.md` and `junior-developer.md` carry routing tables that name sibling agents by bare name in prose; the other agents reference siblings only as scope-boundary prose ("defer to `system-architect`").
- **Relevance:** Agent files contain no operative dispatch, but `project-manager` does pull in specialists at runtime, so the sibling names it would dispatch should be qualified for correctness and example-consistency.

## Root Cause Analysis

### Summary

Claude Code namespaces a plugin's components under that plugin's `name` field, and `dependencies` is install-only (it never merges a dependency's namespace into the parent), so a bare or `han:`-prefixed agent reference does not reliably resolve to the agents that actually live in `han.core`.

### Detailed Analysis

The official plugin reference states that the plugin `name` "is used for namespacing components" — the example given is that agent `agent-creator` in plugin `plugin-dev` appears as `plugin-dev:agent-creator`. The agents here are defined in the `han.core` plugin (E1), so Claude Code registers them as `han.core:agent-name`.

Bare names (E3) work only when the name is unique across every installed plugin plus the user and project scopes; with generic names like `data-engineer` or `test-engineer`, a collision resolves to whichever agent the scope search hits first, which may not be Han's. That is the "silently resolves to the wrong agent" failure mode the issue asked about.

The `han:project-manager` form (E4, E5) is worse: the `han` meta-plugin has no components (E2), and `dependencies` only auto-installs `han.core` as a separate plugin — it does not re-export `han.core`'s agents under `han:`. So `han:project-manager` resolves to nothing. The earlier hypothesis that a parent namespace re-exports a dependency's agents was refuted by the plugin reference and the plugin-dependencies doc (see V1).

## Coding Standards Reference

| Standard | Source | Applies To |
|----------|--------|------------|
| Voice profile: no em-dashes, direct second person, plainspoken | `docs/writing-voice.md` | The new skill-building guidance doc and any doc edits |
| One canonical source per concept; indexes stay complete | `CLAUDE.md` Conventions | Skill-building guidance index entry; docs sweep |
| Agent-dispatch namespacing (new) | This investigation | The new guidance doc codifies `han.core:agent-name` as the rule |

## Planned Fix

### Summary

Qualify every agent dispatch and dispatch-facing example across the suite to `han.core:agent-name`, correct the single `han:` site, and add skill-building guidance that codifies the rule so new skills do not regress.

### Changes

#### `han.core/skills/*/SKILL.md` (15 skills) and `han.github/skills/*/SKILL.md` (2 skills)

- **Change:** Replace every bare agent-name dispatch reference (and the `han:project-manager` site) with the `han.core:`-qualified name. Cover roster tables, dispatch-instruction prose, and per-agent prompt headers.
- **Evidence:** (E1), (E3), (E4)
- **Standards:** Voice profile for any prose edits.
- **Details:** Only agent-name references in a dispatch/roster context get the prefix. File paths like `han.core/agents/structural-analyst.md`, skill-name cross-references (`use code-review`), and unrelated backticked text are left untouched.

#### `docs/agents/project-manager.md`

- **Change:** Correct the "How to invoke it" example from `han:project-manager` to `han.core:project-manager`.
- **Evidence:** (E2), (E5)
- **Standards:** Voice profile.
- **Details:** Single-line example fix.

#### `han.core/agents/project-manager.md`, `han.core/agents/junior-developer.md`

- **Change:** Qualify sibling-agent names where the agent describes dispatching them (the routing tables), to `han.core:`.
- **Evidence:** (E6)
- **Standards:** Voice profile.
- **Details:** Prose scope-boundary mentions stay readable; the goal is that any name presented as a dispatch target is qualified.

#### `docs/guidance/skill-building-guidance/` (new file) + index

- **Change:** Add a guidance doc stating that agent dispatch must use the fully-qualified `han.core:agent-name`, why bare names are unreliable, and why the `han:` meta-plugin prefix is wrong. Add an index entry.
- **Evidence:** (E1), (E2)
- **Standards:** Voice profile; "indexes stay complete" convention.
- **Details:** Codifies the rule for future skill authors so the suite does not regress.

## Validation Results

### Counter-Evidence Investigated

#### V1: "The canonical prefix is `han:`, because a meta-plugin re-exports its dependency's agents under the parent namespace."

- **Hypothesis:** Agents defined in `han.core` become available as `han:agent-name` because the `han` meta-plugin depends on `han.core`, making `han:project-manager` (the existing usage) correct.
- **Investigation:** Challenged the claim, which was initially supported only by Han's own (suspect) files. Re-checked against the official plugin reference ("the `name` field is used for namespacing components"; `plugin-dev:agent-creator` is scoped to the defining plugin) and the plugin-dependencies doc (dependencies are resolved and installed as separate plugins; "auto-installed dependencies stay on disk after the plugins that installed them are uninstalled"). Confirmed the `han` plugin.json has zero components (E2).
- **Result:** Refuted.
- **Impact:** The canonical prefix is `han.core:`, not `han:`. The existing `han:project-manager` is itself a bug to fix, not a standard to propagate.

#### V2: "Bare names are fine because Han's agent names happen to be unique."

- **Hypothesis:** Since each name is defined once in `han.core`, bare dispatch always resolves correctly, so no fix is needed.
- **Investigation:** Uniqueness holds only within `han.core`. Resolution scope spans every installed plugin plus user and project agents. Names like `data-engineer`, `test-engineer`, `software-architect`, `junior-developer` are generic enough to collide with agents from other installed plugins or a user's own `~/.claude/agents`.
- **Result:** Partially refuted — bare names may work in a clean install but are not robust, and the qualified form is strictly safer.
- **Impact:** Confirms the fix is worth doing across the whole suite rather than only at the `han:` site.

### Adjustments Made

None to the root cause. The fix scope was confirmed to include the `han:` site (treat as bug, not template) and the documentation example in `docs/agents/project-manager.md`.

### Confidence Assessment

- **Confidence:** High
- **Remaining Risks:** The `han.core:` resolution is grounded in the documented namespacing rule; the strongest residual risk is an undocumented runtime behavior in a specific Claude Code version. The edit is mechanical, so the main execution risk is missing a dispatch site or accidentally prefixing a non-dispatch reference (file path / skill name); a final grep guards against both.

## Final Summary

- **Root Cause:** Claude Code namespaces agents under their defining plugin's `name` (`han.core`) and `dependencies` never re-export them, so bare and `han:`-prefixed dispatches don't reliably resolve (E1, E2).
- **Fix:** Qualify every agent dispatch and dispatch-facing example to `han.core:agent-name`, correct the lone `han:project-manager` site, and add skill-building guidance codifying the rule.
- **Why Correct:** The plugin reference states the `name` field namespaces components (`plugin-dev:agent-creator`), and the agents live in the `han.core` plugin (E1).
- **Validation Outcome:** The `han:` hypothesis was refuted by the official docs (V1); bare-name reliance was shown unsafe (V2).
- **Remaining Risks:** A missed site or an over-eager prefix; mitigated by a final repo-wide grep.
