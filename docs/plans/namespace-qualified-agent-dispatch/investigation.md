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
- **Relevance:** Agent files contain no operative dispatch (no agent grants the `Agent`/`Task` tool), so the routing tables are advisory directories the orchestrating skill consumes; the skill performs the qualified dispatch. The agent definitions therefore need no change.

### E7: Local corroboration that `han.core:` is the live form, and a prior partial remediation

- **Source:** `han.feedback/skills/han-feedback/SKILL.md:39`; `git show ea0ec52` (2026-05-29)
- **Finding:** The han-feedback skill already uses `han.core:adversarial-security-analyst` / `han.core:evidence-based-investigator` operatively when describing the dispatch form Claude Code emits, and it watches for slash-command invocations like `/han.core:plan-a-feature`. Commit `ea0ec52` describes "replacing the outdated bare `han:` prefix matching" but only touched the feedback skill and seven agent docs, leaving the rest of the suite in a partially-fixed state.
- **Relevance:** Independent in-repo corroboration of the `han.core:` form (not just the external plugin reference), and evidence that the `han:` prefix was already known to be outdated before this investigation. This fix completes what `ea0ec52` started.

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

#### Documentation invocation examples (all of `docs/agents/*.md`, `docs/agents/README.md`, `docs/concepts.md`, `docs/templates/agent-long-form-template.md`)

- **Change:** Correct every documented `subagent_type: han:{agent-name}` to `han.core:{agent-name}`. This is the full "How to invoke it" set across all 23 agent docs, plus the README's two canonical-form lines, the concepts example, and the agent long-form template placeholder.
- **Evidence:** (E2), (E5), (E7)
- **Standards:** Voice profile.
- **Details:** Scope corrected upward from the single `project-manager.md` site after validation (see V2-doc-scope). 28 occurrences across 26 files.

#### Han skill cross-references and provenance (`plan-implementation`, `iterative-plan-review`, `plan-a-feature`, and three report templates)

- **Change:** Correct `han:{skill-name}` cross-references and `generated_by: "han:{skill-name}"` metadata to the `han.core:` form.
- **Evidence:** (E2), (E7)
- **Standards:** Voice profile.
- **Details:** Same root cause as agents: skills also live in `han.core`, so the live invocation is `/han.core:{skill-name}` (corroborated by `han-feedback/SKILL.md:37`). Scope added after validation (see V4).

#### Skill-building guidance (new `agent-dispatch-namespacing.md` + two contradicting examples)

- **Change:** Add `han.plugin-builder/skills/guidance/references/skill-building-guidance/agent-dispatch-namespacing.md` codifying the `han.core:agent-name` rule, why bare names are unreliable, and why the `han:` meta-plugin prefix resolves to nothing. Cross-link it from `skill-decomposition.md` and `workflow-patterns.md`, and fix the bare-name dispatch examples those two files taught.
- **Evidence:** (E1), (E2)
- **Standards:** Voice profile; the directory self-applies via `paths:` frontmatter (no central index).
- **Details:** `skill-decomposition.md:97` taught `evidence-based-investigator` bare and `workflow-patterns.md:131` taught `content-auditor` bare; both corrected (see V3).

#### Not changed: `han.core/agents/*.md`

- **Change:** None.
- **Evidence:** (E6)
- **Details:** No agent grants the `Agent`/`Task` tool, so no agent definition is an executable dispatch site. The routing tables in `project-manager` and `junior-developer` are advisory directories the orchestrating skill consumes, and the skill performs the qualified dispatch. Qualifying the descriptive prose would add noise without fixing a dispatch.

## Validation Results

A background `adversarial-validator` attacked the root cause, the fix safety, and completeness. It returned seven counter-findings (V1-V7); the substantive ones expanded the fix scope.

### Counter-Evidence Investigated

#### V1: Root-cause provenance — the namespacing rule rested on an external URL with no local corroboration

- **Hypothesis:** The `han.core:` conclusion is grounded only in the external plugin reference, which cannot be verified in-repo.
- **Investigation:** The validator searched the repo for the rule and for any local statement of it. The earlier `han:` hypothesis (a meta-plugin re-exports its dependency's agents) was already refuted against the official plugin reference ("the `name` field is used for namespacing components"; `plugin-dev:agent-creator` is scoped to the defining plugin) and the plugin-dependencies doc (dependencies install as separate plugins). The validator then surfaced in-repo corroboration: `han-feedback/SKILL.md:39` uses `han.core:` operatively, and commit `ea0ec52` calls the bare `han:` prefix "outdated".
- **Result:** Confirmed (root cause holds), with a strengthened evidence chain.
- **Impact:** Added (E7) to record the local corroboration so the conclusion no longer rests on a single external source.

#### V2: Bare-name uniqueness, and documentation fix scope

- **Hypothesis (a):** Bare names are fine because Han's names are unique. **Hypothesis (b):** the fix named only `project-manager.md` for docs, but every agent doc uses `han:`.
- **Investigation:** (a) Uniqueness holds only within `han.core`; resolution spans every installed plugin plus user/project scopes, so generic names can collide. (b) The validator grep found `subagent_type: han:` in all 23 agent docs, `docs/agents/README.md`, `docs/concepts.md`, and the agent template.
- **Result:** (a) Partially refuted — qualified form is strictly safer. (b) Refuted — doc scope was understated.
- **Impact:** Expanded the documentation fix from one file to all 26 (see the documentation-examples change above).

#### V3: New guidance would contradict existing guidance that teaches bare dispatch

- **Hypothesis:** Adding the new guidance doc is sufficient.
- **Investigation:** `skill-decomposition.md:97` and `workflow-patterns.md:131` teach bare-name `Agent` dispatch as copyable examples.
- **Result:** Refuted.
- **Impact:** Corrected both examples to `han.core:` and cross-linked them to the new guidance doc.

#### V4: `han:skill-name` references and `generated_by` are the same bug class, exempted without rationale

- **Hypothesis:** Skill cross-references are out of scope.
- **Investigation:** Skills live in `han.core` too; the live form is `/han.core:{skill-name}` (per `han-feedback/SKILL.md:37`). Four prose cross-references and three `generated_by` provenance fields used `han:`.
- **Result:** Refuted — the exemption was wrong.
- **Impact:** Folded the skill cross-references and `generated_by` fields into the fix (see the skill-cross-references change above).

#### V5: Completeness — are all 23 agents really only in `han.core`?

- **Hypothesis:** Another plugin might define an agent, making `han.core:` wrong for it.
- **Investigation:** The validator confirmed `han.github`, `han.reporting`, and `han.feedback` have no `agents/` directory and declare no custom agents path; all 23 agents are in `han.core/agents/`.
- **Result:** Confirmed.
- **Impact:** None — `han.core:` is correct for every agent.

#### V6: Does the dot in `han.core` break the `namespace:agent-name` colon syntax?

- **Hypothesis:** `han.core:project-manager` might be ambiguous to the resolver.
- **Investigation:** Plugin names with dots are used throughout the marketplace, and `han-feedback` uses the dotted form operatively. A resolver splitting on the first `:` reads `han.core` as the namespace and `project-manager` as the name.
- **Result:** Confirmed valid (low residual risk; see below).
- **Impact:** None.

#### V7: Prior partial remediation (`ea0ec52`) left the suite half-fixed

- **Hypothesis:** The problem is new.
- **Investigation:** Commit `ea0ec52` (2026-05-29) already replaced "outdated bare `han:`" in the feedback skill and seven agent docs but left the rest.
- **Result:** Confirmed — corroborates the root cause and explains the inconsistent starting state.
- **Impact:** Recorded as (E7); this fix completes the remediation across the whole suite.

### Adjustments Made

- **V2:** Documentation fix scope expanded from `docs/agents/project-manager.md` to all 26 doc sites that carried `subagent_type: han:`.
- **V3:** Fixed the two skill-building guidance examples (`skill-decomposition.md`, `workflow-patterns.md`) that taught bare dispatch, and cross-linked them to the new guidance.
- **V4:** Added the `han:skill-name` cross-references (four prose sites) and `generated_by` provenance (three report templates) to the fix.
- **V1/V7:** Added (E7) local corroboration; the root cause itself was unchanged.

### Confidence Assessment

- **Confidence:** High
- **Remaining Risks:** The `han.core:` resolution is grounded in the documented namespacing rule and corroborated in-repo (E7). The dotted namespace (V6) is treated as valid on strong circumstantial evidence but is not separately documented; the residual risk is an undocumented resolver quirk in a specific Claude Code version. Execution risk (a missed site or an over-eager prefix) is mitigated by the boundary-guarded edit and a final repo-wide grep showing no bare standalone agent tokens remain in any dispatching skill.

## Final Summary

- **Root Cause:** Claude Code namespaces a plugin's components under its own `name` (`han.core`) and `dependencies` never re-export them, so bare and `han:`-prefixed references do not reliably resolve (E1, E2, E7).
- **Fix:** Qualify every agent dispatch, documented invocation, Han skill cross-reference, and `generated_by` field to `han.core:`, and add skill-building guidance codifying the rule with its contradicting examples corrected.
- **Why Correct:** The plugin reference states the `name` field namespaces components (`plugin-dev:agent-creator`); the agents and skills live in `han.core` (E1); and the suite already uses `han.core:` operatively in `han-feedback` (E7).
- **Validation Outcome:** Root cause confirmed and corroborated in-repo (V1, V5, V6, V7); the fix scope was expanded three times in response to the validator (docs V2, guidance V3, skill refs V4).
- **Remaining Risks:** An undocumented resolver behavior around dotted namespaces (V6); otherwise mitigated by the final grep.
