# Guidance Currency Review: Skill, Agent, and Plugin Building Standards

Research date: 2026-06-04
Scope: every file under `han.plugin-builder/skills/guidance/references/` (skill-building guidance, agent-building guidelines, the cross-cutting taxonomy and model-selection docs, the marketplace/plugin/monitors/themes configuration reference, the example manifests, and the local-development, iterative-development, semantic-versioning, and plugin-readme docs).

This report checks Han's contributor guidance against the current (June 2026) official Claude Code documentation and a small set of other trusted sources. It anchors on the official docs first, then branches out only where the official docs leave a gap. It exists to drive a guidance update plan; it is a durable research record and is not a source of truth for feature work.

## Method

Two streams ran in parallel: a digest of every guidance file on disk (what each doc currently claims, what it cites, and where it shows staleness signals), and a fresh read of the authoritative sources. Findings below are organized by topic area, each tagged with the source that grounds it. A per-doc currency table at the end maps every guidance file to a verdict. The companion file `guidance-update-plan.md` turns these findings into a plain-language change plan.

A reference is listed only if it actually bears on a guidance decision. The list runs to sixteen sources, which is the bounded set the review converged on.

## Sources

Official Claude Code product documentation (primary anchor, trust class: web):

1. **Skills** — https://code.claude.com/docs/en/skills — the authoritative reference for SKILL.md frontmatter, naming mechanics, the description truncation cap, progressive disclosure, supporting files, and skill lifecycle in Claude Code.
2. **Subagents** — https://code.claude.com/docs/en/sub-agents — authoritative for subagent frontmatter, model resolution order, tool allow/deny semantics, context isolation, and the "subagents cannot spawn subagents" rule.
3. **Agent Teams** — https://code.claude.com/docs/en/agent-teams — experimental agent-teams feature, token-cost characterization, recommended team size.
4. **Plugins Reference** — https://code.claude.com/docs/en/plugins-reference — full `plugin.json` manifest schema, component paths, environment variables, version resolution, and the `experimental.*` placement for monitors and themes.
5. **Create Plugins** — https://code.claude.com/docs/en/plugins — plugin creation tutorial; `commands/` vs `skills/` framing, `--plugin-dir` / `--plugin-url` local testing, `/reload-plugins`.
6. **Plugin Marketplaces** — https://code.claude.com/docs/en/plugin-marketplaces — full `marketplace.json` schema, five source types, strict mode, reserved marketplace names.
7. **Plugin Dependencies** — https://code.claude.com/docs/en/plugin-dependencies — the `dependencies` mechanism, the `{plugin-name}--v{version}` git-tag convention, `claude plugin tag --push`.
8. **Hooks** — https://code.claude.com/docs/en/hooks — current hook event names, configuration format, `hooks/hooks.json` location, frontmatter hooks.

Anthropic platform docs and the cross-tool open standard (trust class: web):

9. **Agent Skills overview** — https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview — `name` max 64 chars, `description` max 1,024 chars, reserved words, three-level disclosure with token targets.
10. **Skill authoring best practices** — https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — gerund-form naming preference, third-person descriptions, reference-depth rule, model-specific testing.
11. **Agent Skills specification** — https://agentskills.io/specification — the cross-tool open standard for SKILL.md; field constraints, `allowed-tools` marked experimental at the standard level, 500-line guidance, `compatibility` max 500 chars.
12. **Best practices for skill creators** — https://agentskills.io/skill-creation/best-practices — extract real domain expertise, calibrate freedom to task fragility, provide defaults not menus.

Anthropic engineering publications (trust class: web):

13. **Building effective agents** — https://www.anthropic.com/engineering/building-effective-agents — simplicity first; workflow patterns (chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer); cost/latency trade-off; human checkpoints.
14. **Writing effective tools for agents** — https://www.anthropic.com/engineering/writing-tools-for-agents — tool/description design as a first-class concern, task consolidation, high-signal returns, the 25,000-token default tool-response cap in Claude Code.

Supporting references (trust class: web):

15. **Semantic Versioning 2.0.0** — https://semver.org — the MAJOR.MINOR.PATCH specification Han's versioning policy layers on.
16. **Towards a Science of Scaling Agent Systems** (Google Research / Google DeepMind / MIT, 2025) — https://research.google/blog/towards-a-science-of-scaling-agent-systems-when-and-why-agent-systems-work/ — the study behind the "~45% capability saturation" threshold and the "39-70% sequential degradation" figures that `multi-agent-economics.md` currently cites only as "DeepMind, 2025" with no link.

Note: `specialization-and-model-selection.md` already carries its own eight-source list (Orq.ai, arXiv 2301.12726, Amazon Science, arXiv 2510.07772, DecomP, Anthropic extended-thinking and chain-of-thought docs, Deepgram). Those were reviewed and found sound and honestly caveated; they are not re-listed here.

## Findings by topic

### 1. Commands are merged into skills — Han's framing is correct, official framing is softer

The Han taxonomy says "Commands have been merged into skills... should no longer be created as separate entities." The official Skills doc (1) confirms this directionally: a `.claude/commands/deploy.md` file and a `skills/deploy/SKILL.md` both produce `/deploy` and work the same way, and `skills/` is the recommended path. The Plugins docs (4, 5) are softer in wording — they call `commands/` a legacy flat-file format and say "use `skills/` for new plugins" without calling it deprecated or removed. **Verdict: Han's taxonomy claim is accurate as a direction-of-travel statement and needs no change in substance.** It could optionally note that `commands/` files still load, to avoid implying they were removed.

### 2. SKILL.md description limits — Han has the right numbers but should name both caps explicitly

Two separate limits exist and Han's `skill-description-length.md` already captures both: the open-standard / platform hard cap of **1,024 characters** on the `description` field (9, 11), and the Claude Code **1,536-character** truncation of the combined description in the skill listing, configurable via `skillListingMaxDescChars` (1). Targeting 1,024 clears both. **Verdict: current and correct.** The `maxSkillDescriptionChars` / `skillListingBudgetFraction` setting names in the official doc are worth a cross-check against the doc's `skillListingMaxDescChars` spelling.

### 3. Skill frontmatter field set — Han documents a subset; Claude Code now supports many more fields

The official Skills doc (1) lists frontmatter fields Han's guidance does not mention: `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`, `user-invocable`, `disallowed-tools`, `model`, `effort`, `context` (with `fork`), `agent`, `hooks`, `paths`, and `shell`. Han's guidance covers `name`, `description`, `allowed-tools`, and `argument-hint` (in passing). The repo already uses `paths:` (see `multi-agent-economics.md` frontmatter) and `context: fork` is referenced in `skill-composition.md` as unreliable. **Verdict: there is no single doc that inventories supported SKILL.md frontmatter fields.** This is the largest coverage gap. A new reference listing the current field set with one-line semantics would close it.

### 4. The `name` field vs directory name — worth one clarifying sentence

The open standard (11) requires `name` to match the parent directory. Claude Code (1) clarifies that the directory name drives the slash command and the frontmatter `name` is the display label, except for a plugin-root `SKILL.md` where `name` sets the command. Han's `naming-conventions.md` says "Skill `name` in frontmatter matches directory name," which is consistent with the standard but does not explain the command-vs-label distinction. **Verdict: accurate, slightly under-explained.**

### 5. Gerund-form naming preference — not currently captured

The Anthropic best-practices doc (10) states a preferred convention: gerund form (`processing-pdfs`, `analyzing-spreadsheets`), with noun and action forms acceptable. Han's `naming-conventions.md` and `cowork-specific-skill-instructions.md` mention gerund naming only in the Cowork context. **Verdict: the gerund preference is a general Anthropic recommendation, not Cowork-specific, and is not reflected in the primary naming doc.**

### 6. Third-person description voice — implied but not stated as a rule

The best-practices doc (10) makes third-person voice an explicit rule ("Processes Excel files," not "I can help"). Han's `skill-description-frontmatter.md` models third person throughout but never states it as a rule. **Verdict: should be made explicit.**

### 7. Progressive disclosure numbers — Han matches the sources

Han's `progressive-disclosure.md` uses ~100 tokens at discovery, under 5k tokens for the body, and the three-level model. Sources (1, 9, 11) confirm ~100 tokens metadata, <5,000 tokens instructions, and the 500-line SKILL.md ceiling. **Verdict: current.** Han does not state the 500-line ceiling explicitly; adding it would align with all five primary sources. The Claude Code-specific compaction budget (25,000 tokens shared / 5,000 per skill, source 1) is not mentioned anywhere in Han's guidance and is a candidate addition for `context-hygiene.md`.

### 8. `allowed-tools` and Bash permissions — current and unusually well-grounded

Han's `allowed-tools-bash-permissions.md` and `allowed-tools-AskUserQuestion.md` are grounded in specific commits and live upstream bug reports (#29547, #9846). The open standard (11) marks `allowed-tools` experimental at the cross-tool level, but Claude Code (1) treats it as stable with the exact `Bash(git add *)` syntax Han documents. **Verdict: current and accurate.** The AskUserQuestion bug doc is time-stamped and should be re-verified against the upstream issue before each release, since it documents a bug that may be fixed.

### 9. Subagent frontmatter — Han documents `model` only; many fields are undocumented

Han's agent guidance (`agent-model-selection.md`, `agent-external-files.md`) covers the `model` field well and correctly states agents are flat self-contained files with no `references/` or `scripts/`. But the official Subagents doc (2) lists many fields Han never mentions: `tools`, `disallowedTools`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `effort`, `isolation`, `color`, `initialPrompt`. Critically, source (2) documents a **security boundary**: `hooks`, `mcpServers`, and `permissionMode` are ignored when an agent is loaded from a plugin — directly relevant to Han, whose agents all ship in `han.core`. **Verdict: agent frontmatter coverage is thin and missing a Han-relevant security note.**

### 10. Subagents cannot spawn subagents — Han states this only for its own agents

The official doc (2) states the general rule: subagents cannot spawn other subagents; use skills or chain from the main conversation. Han's `agent-dispatch-namespacing.md` notes "Han agents do not have the Agent tool, so an agent never dispatches another agent directly," which is the same fact stated as a local implementation detail. **Verdict: correct; could cite the general platform rule rather than presenting it as a Han-specific choice.**

### 11. Model selection — Han's mapping is sound; built-in assignments drifted

Han's `agent-model-selection.md` maps opus/sonnet/haiku/inherit to task types correctly. Its list of built-in Claude Code agents is incomplete and partially stale versus source (2): the current built-ins include `Explore` (Haiku), `Plan` (inherit), `general-purpose` (inherit), `statusline-setup` (Sonnet), and `claude-code-guide` (Haiku). The model-resolution order (env var → per-invocation → frontmatter → main conversation) in source (2) is not documented in Han. **Verdict: core mapping current; built-in list and resolution order need a refresh.**

### 12. Multi-agent economics — the substance is real but the citation is missing

This is the highest-priority finding. `multi-agent-economics.md` presents a precise efficiency table and three specific figures (~70% of tasks handled by one agent, a 45% threshold, 39-70% sequential degradation) attributed to "DeepMind, 2025" with **no link**. The underlying study is real: "Towards a Science of Scaling Agent Systems" (Google Research / Google DeepMind / MIT, 2025; source 16). That study confirms the ~45% capability-saturation threshold and the 39-70% sequential-degradation range, and confirms the diminishing-returns direction (180 experiments, five architectures, three model families; swings from an 81% boost to a 70% drop). What the study does **not** obviously support is the exact efficiency table (1 agent = 1x/1x/1.0; 3 = ~4x/~2x/0.5; 5 = ~7x/~3.1x/0.44). **Verdict: cite source 16 for the 45% and 39-70% claims; verify or relabel the efficiency table as an illustrative model rather than study data; the "5-agent hard cap" is Han's own heuristic and should be flagged as such, noting the official agent-teams recommendation of 3-5 teammates (source 3) corroborates the direction.**

### 13. Agent teams — not mentioned in Han guidance at all

Source (3) documents agent teams as an experimental feature (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`, v2.1.32+) with linear per-teammate token cost and a 3-5 teammate recommendation. Han's `multi-agent-economics.md` discusses "teams" abstractly without referencing this feature. **Verdict: a short note distinguishing Han's parallel `Agent`-tool dispatch (what Han actually does) from the experimental agent-teams feature (what it does not) would prevent confusion.** Han skills dispatch subagents whose results summarize back; they do not use agent teams.

### 14. plugin.json schema — accurate but missing recent fields and the `experimental.*` placement

Han's `plugin-json-options.md` is accurate on the fields it covers but, against source (4), is missing: `displayName` (v2.1.143+), `defaultEnabled` (v2.1.154+), the `CLAUDE_PROJECT_DIR` environment variable, and — most importantly — the fact that `monitors` and `themes` are now preferred under the `experimental.*` key (the bare top-level placement still works but `claude plugin validate` warns). **Verdict: accurate but stale on recent additions; the `experimental.*` placement matters for contributors running `claude plugin validate --strict` in CI.**

### 15. marketplace.json schema — accurate but the reserved-names list is incomplete

Han's `marketplace-json-options.md` lists 8 reserved marketplace names; source (6) lists 12, adding `anthropic-agent-skills`, `claude-for-legal`, `claude-for-financial-services`, and `financial-services-plugins`. It is also missing `displayName` and `defaultEnabled` on plugin entries. **Verdict: accurate on structure, incomplete on the reserved list and recent entry fields.**

### 16. monitors and themes — correct, but should be labelled experimental

Han's `monitors-json-options.md` and `themes-json-options.md` are accurate against source (4). The one gap: source (4) classifies both as `experimental`, and Han's docs do not say so. **Verdict: add the experimental label and the `experimental.*` placement note.**

### 17. Hooks — Han has no dedicated hooks guidance

Han does not author hooks today, so there is no hooks-building guidance, only the taxonomy mention. Source (8) documents the current event set and `hooks/hooks.json` format. **Verdict: no action needed unless Han starts shipping hooks; the taxonomy's hooks description is accurate.**

### 18. Semantic versioning — sound and correctly layered

Han's `semantic-versioning.md` is an internal policy (one-bump-per-branch, suite versioning for parent + children) layered on top of semver.org (15) and consistent with the official version-resolution rules (4). **Verdict: current.** Optional addition: the `{plugin-name}--v{version}` git-tag convention and `claude plugin tag --push` from source (7) are relevant to how Han releases are tagged.

### 19. Local development — matches the official local-marketplace workflow

Han's `local-development.md` matches the official `/plugin marketplace add ./` workflow (6). Sources (4, 5) document two additional approaches Han does not mention: `claude --plugin-dir ./my-plugin` (single-session, no install) and `claude plugin init`. **Verdict: current; the `--plugin-dir` approach is a useful optional addition for quick iteration, and `/reload-plugins` is worth naming.**

### 20. Skill composition / context: fork — Han's caveat stands; the feature is now documented

Han's `skill-composition.md` says forked data-fetch sub-skills cause early exit and should be replaced with inline discovery. Source (1) now documents `context: fork` and the `agent` field as supported features. **Verdict: Han's empirical caveat does not contradict the feature existing; the doc should acknowledge `context: fork` is a documented Claude Code feature while explaining why Han avoids it for data-fetch sub-skills, so the guidance reads as a deliberate choice rather than ignorance of the feature.**

### 21. Engineering-blog best practices not yet reflected

Sources (13, 14) carry guidance Han only partially reflects: "simplicity first, measure before adding agents" (aligns with `multi-agent-economics.md`), human checkpoints before irreversible actions (aligns with `workflow-patterns.md` human gates), and "tool/description design deserves as much attention as the system prompt." The last point reinforces `skill-description-frontmatter.md` and could be cited there. **Verdict: minor; these are corroborating citations Han's docs could add rather than new rules.**

## Per-doc currency table

Verdict key: **Current** (accurate, no change needed) / **Minor** (small addition or citation) / **Update** (stale facts or missing material that matters) / **Source** (substance fine, citations missing).

| Guidance doc | Verdict | Key finding | Source |
|---|---|---|---|
| skill-building-guidance/agent-dispatch-namespacing.md | Current | Han-specific convention; accurate | 2 |
| skill-building-guidance/allowed-tools-AskUserQuestion.md | Minor | Re-verify upstream bug status before release | 1 |
| skill-building-guidance/allowed-tools-bash-permissions.md | Current | Matches Claude Code `Bash()` syntax | 1 |
| skill-building-guidance/context-hygiene.md | Minor | Add the 25k/5k compaction budget | 1 |
| skill-building-guidance/context-injection-commands.md | Current | Accurate, commit-grounded | 1 |
| skill-building-guidance/cowork-specific-skill-instructions.md | Current | Gerund naming should also live in main naming doc | 9,10 |
| skill-building-guidance/documentation-maintenance.md | Current | General discipline; no version claims | — |
| skill-building-guidance/dynamic-project-discovery.md | Current | Accurate | — |
| skill-building-guidance/graceful-degradation.md | Current | Accurate | — |
| skill-building-guidance/hardening-fuzzy-vs-deterministic.md | Current | Accurate | — |
| skill-building-guidance/naming-conventions.md | Update | Add gerund preference + name-vs-directory command distinction | 1,10,11 |
| skill-building-guidance/optional-git-repositories.md | Current | Accurate | — |
| skill-building-guidance/progressive-disclosure.md | Minor | State the 500-line ceiling explicitly | 1,9,11 |
| skill-building-guidance/script-execution-instructions.md | Current | `${CLAUDE_SKILL_DIR}` accurate | 1 |
| skill-building-guidance/security-restrictions.md | Current | XML/reserved-word/1024-char rules match | 9,11 |
| skill-building-guidance/skill-composition.md | Minor | Acknowledge `context: fork` is now documented | 1 |
| skill-building-guidance/skill-decomposition.md | Current | Accurate | — |
| skill-building-guidance/skill-description-frontmatter.md | Minor | State third-person rule; cite tool-design posts | 10,14 |
| skill-building-guidance/skill-description-length.md | Current | Both caps captured; cross-check setting name spelling | 1,9 |
| skill-building-guidance/skill-reference-files.md | Current | Accurate; reference-depth rule could be cited | 10 |
| skill-building-guidance/success-criteria-and-testing.md | Minor | Add model-specific testing note (Haiku needs more) | 10 |
| skill-building-guidance/troubleshooting.md | Current | Accurate; tracks AskUserQuestion bug | 1 |
| skill-building-guidance/use-case-planning.md | Current | Accurate | — |
| skill-building-guidance/workflow-patterns.md | Minor | Cite Anthropic workflow patterns + checkpoints | 13 |
| skill-building-guidance/writing-effective-instructions.md | Current | Accurate | — |
| **NEW: skill-frontmatter-fields.md** | Update | No doc inventories the full current frontmatter field set | 1 |
| agent-building-guidelines/agent-domain-focus.md | Current | Accurate; one source | — |
| agent-building-guidelines/agent-external-files.md | Current | Accurate (agents are flat files) | 2 |
| agent-building-guidelines/agent-model-selection.md | Update | Refresh built-in agent list; add model-resolution order; add plugin-agent security note | 2 |
| agent-building-guidelines/graceful-degradation.md | Current | Accurate | — |
| agent-building-guidelines/multi-agent-economics.md | Source | Add the real study citation; verify/relabel efficiency table; flag 5-cap as Han heuristic; distinguish agent-teams feature | 3,16 |
| plugin-entity-taxonomy.md | Minor | Note `commands/` files still load; refresh "Last Updated" | 1,4,5 |
| specialization-and-model-selection.md | Current | Well-sourced and honestly caveated | (own 8) |
| claude-marketplace-and-plugin-configuration/marketplace-json-options.md | Update | Complete reserved-names list; add `displayName`/`defaultEnabled` | 6 |
| claude-marketplace-and-plugin-configuration/plugin-json-options.md | Update | Add `displayName`/`defaultEnabled`/`CLAUDE_PROJECT_DIR`; `experimental.*` placement | 4 |
| claude-marketplace-and-plugin-configuration/monitors-json-options.md | Minor | Label experimental; note `experimental.monitors` key | 4 |
| claude-marketplace-and-plugin-configuration/themes-json-options.md | Minor | Label experimental; note `experimental.themes` key | 4 |
| iterative-plugin-development.md | Current | Internal process; no version claims | — |
| local-development.md | Minor | Add `--plugin-dir` and `/reload-plugins` as alternatives | 4,5 |
| plugin-readme.md | Current | Internal convention; accurate | — |
| semantic-versioning.md | Minor | Optional: add git-tag convention for dependency versions | 7,15 |
| templates/*.json, plugin-readme-template.md | Update-with-parent | Update example manifests when `displayName`/`defaultEnabled`/`experimental.*` land in the reference docs | 4,6 |

## Summary of what drives change

- **One new doc** is justified: a skill-frontmatter-field inventory (finding 3).
- **Six docs carry stale or missing facts that matter** (Update): naming-conventions, agent-model-selection, marketplace-json-options, plugin-json-options, and the multi-agent-economics citation gap (Source), plus the example manifests that follow the config docs.
- **The rest are Current or need only Minor citations/additions.** Nothing needs deleting. The candidate consolidation is gerund-naming guidance currently split between the Cowork doc and the main naming doc.

The companion `guidance-update-plan.md` sequences these into concrete edits.
