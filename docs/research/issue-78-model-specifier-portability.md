# Research: A solution for the cross-host model-specifier problem (issue #78)

The open-ended question: what is the best way to resolve the cross-host model-specifier compatibility problem in Han, where four planning skills instruct sub-agent dispatch to pass `model: "sonnet"` (a Claude-specific tier name) which fails when the suite runs under OpenAI Codex?

Evidence mode: **strict** (default — no opt-out was requested).

## Summary

Han's four planning skills carry a blanket rule — "all sub-agents in this skill run on sonnet" — that tells the dispatcher to pass a Claude-specific model name on every sub-agent call. Under Codex, which has its own separate model names, that Claude name is not valid, which is what the reporter hit. The clear fix is to **remove those skill-level model instructions** rather than try to translate them per host. Removing them is simpler than any "generalize it" scheme, and it has a second benefit that turns the obvious objection on its head: those overrides were quietly forcing several agents *down* to sonnet even though the project had deliberately promoted three of them to the stronger opus tier a month ago. So removing the overrides restores the intended behavior instead of regressing it.

One thing the research could not settle from documentation alone: whether removing the skill instructions *fully* fixes Codex, or whether the per-agent model setting baked into each agent file is a second, separate thing Codex also trips over. The reporter's own description points at the skill-level model name as the failure, but the only way to be certain the fix is complete is to run a planning skill under Codex once the overrides are gone. The recommendation is solid on direction; its completeness is the open part.

- **Confidence:** Medium

## Research Results

**The failure is a Claude-specific model name crossing a host boundary.** Four planning skills — `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, `plan-work-items` — carry an operating-principle line, "All sub-agents in this skill run on sonnet," and repeat `pass model: "sonnet"` at each dispatch step, eleven active instances in total (A1, A2, A3, A4). The remaining 30 of Han's 34 skills carry no model directive at all (A5). On Claude Code, `sonnet` is a valid tier alias; under Codex the model namespace is entirely separate (`gpt-5.x` family) and Claude aliases appear nowhere in Codex's documentation (A11, A12, A15). The reporter of issue #78 observed exactly this: errors that "Codex could not use the `sonnet` model" while running Han skills, and the maintainer confirmed the cause — "i completely forgot i had models set in those" (A6, provided).

**Omitting the model field is the documented neutral state on both hosts.** On Claude Code, omitting `model` is equivalent to `inherit`: the sub-agent runs on the parent session's model (A7, A9, codebase guidance A18). Codex's documentation says the same for its own agents — omitted optional fields inherit from the parent session (A11). When Codex's Claude-import tooling encounters a Claude model reference it cannot map, it *drops* the reference and falls back to the Codex default (A13) — the same end state as omission. The caveat: that "drop and inherit" behavior is documented for Codex's *migration/import* path, not confirmed for *live* sub-agent dispatch [single-source], so "omit fixes Codex" is well-supported in direction but not independently confirmed for the live path.

**Removing the overrides restores a deliberate design decision, it does not regress cost.** A skill-level `model: "sonnet"` override supersedes each agent's own frontmatter tier (A18 resolution order; A8 inventory). Han's 23 agents are tiered on purpose — 10 opus, 10 sonnet, 3 haiku (A8) — and on 2026-05-18 the project explicitly promoted `junior-developer`, `information-architect`, and `user-experience-designer` from sonnet to opus because they "perform synthesis over unbounded input," aligning them with the guidance and their own docs (A10, codebase commit). The blanket sonnet overrides in the planning skills silently undo that promotion every time those agents are dispatched there. So the apparent objection to removal — "it raises cost by letting opus agents run on opus" — is backwards: the overrides are the regression against documented intent, and removing them realigns the skills with the tiers the project chose (A8, A10).

**The hard-coded model value is also less reliable than it looks, even on Claude Code.** Two open Claude Code issues document the model field being honored inconsistently: agent frontmatter `model:` silently ignored (A16), and the Agent-tool `model` parameter returning 404 for aliases in some versions (A17, closed "not planned"). The dependable lever for global model control is the `CLAUDE_CODE_SUBAGENT_MODEL` environment variable, which sits above everything else in precedence — but it is Claude Code-specific (A18, A19). This weakens any argument for keeping the hard-coded value for cost-control reasons.

**The agent-frontmatter surface is a separate, less-certain question.** The skill-level overrides are the surface the reporter hit, but each agent file *also* carries a `model:` line. Whether that frontmatter is a second thing Codex trips over is unresolved. Web evidence says the cross-vendor Agent Skills standard defines no `model` field and that spec-compliant runtimes silently ignore unknown frontmatter keys (A20, A21) — which would make agent frontmatter harmless on Codex — but that "silently ignored" claim is a single web assertion not corroborated by the codebase [single-source]. Codebase evidence cuts the same way structurally: `han-core/.codex-plugin/plugin.json` exposes only `"skills"` and `capabilities: ["Skills"]`, with no agents path (A22), suggesting Codex may not register Han's agent files as Claude Code does. The two readings conflict on *why* but agree that agent frontmatter is not the surface the reporter hit. The honest position: agent frontmatter is not the demonstrated failure, and whether it needs the same treatment is an untested follow-on.

## Options to Consider

### O1: Remove the skill-level model overrides (omit; let each agent's tier govern)

- **What it is:** Delete the "all sub-agents run on sonnet" operating-principle line and every `pass model: "sonnet"` dispatch instruction from the four planning skills. Pass no model on Agent calls; each dispatched agent then runs on its own frontmatter tier (Claude Code) or the host default (Codex). 4 files, 11 instances (A1, A2, A3, A4).
- **Trade-offs:** No Claude-specific model name is ever sent across a host boundary, so the Codex failure surface the reporter hit is removed. As a side effect it harmonizes the `plan-a-feature` / `plan-implementation` PM-synthesis inconsistency (A1 forces sonnet; A2 already exempts it) and restores the deliberate opus promotion (A10). On Claude Code the planning skills will cost more than today because opus-tier agents return to opus — but that is the documented intended tier, not a new regression. Does not, on its own, prove the *agent-frontmatter* surface is clean on Codex (see Research Results).
- **Rests on:** (A1, A2, A3, A4, A5, A6, A8, A10, A18); host-omit semantics (A7, A9, A11, A13).
- **Evidence status:** corroborated (codebase + provided + web), with the live-dispatch Codex behavior carried as a single-source caveat (A13).

### O2: Replace the overrides with `model: inherit`

- **What it is:** Swap each `model: "sonnet"` for an explicit `model: "inherit"` in the same eleven places.
- **Trade-offs:** Functionally identical to O1 on Claude Code (A7, A9). But `inherit` is itself a Claude Code-specific token, not a Codex model identifier (A11, A12) — so it carries the same class of risk across the host boundary as `sonnet` did, just with a different string, and Codex is not documented to recognize it. No benefit over O1 and strictly more cross-host risk.
- **Rests on:** (A7, A9, A11, A12).
- **Evidence status:** corroborated that `inherit` equals omission on Claude Code; single-source on whether Codex tolerates the literal `inherit` [single-source].

### O3: Keep the overrides; accept Codex incompatibility

- **What it is:** Change nothing; treat Han as Claude Code-first and Codex as unsupported for the planning skills.
- **Trade-offs:** Planning skills stay broken under Codex (A6). Also leaves the overrides contradicting the documented opus promotion (A10) and the `plan-a-feature` / `plan-implementation` inconsistency (A1, A2) in place. Defensible only if Codex support is explicitly out of scope — which the suite's existing Codex-compatibility work on plugin naming (A23) suggests it is not.
- **Rests on:** (A6, A10, A23).
- **Evidence status:** corroborated.

### O4: Also neutralize the 23 agent-frontmatter models

- **What it is:** On top of O1, remove or set to `inherit` the `model:` line in all 23 `han-core/agents/*.md` files.
- **Trade-offs:** Closes the agent-frontmatter surface *if* it turns out Codex reads those files and rejects Claude model names — the uncertainty V4/V7 flagged. But it discards the entire deliberate per-agent tiering (A8, A10) across the whole suite, not just the planning skills, and contradicts the current authoring guidance ("always set model explicitly," A18). Larger blast radius (23 files + guidance rewrite) for a surface that is not the demonstrated failure and may be silently ignored on Codex anyway (A20, A21, A22). Premature without a Codex live test.
- **Rests on:** (A8, A10, A18, A20, A21, A22).
- **Evidence status:** single-source on the premise that justifies it (agent frontmatter actively breaks Codex) [single-source].

### O5: Generalize — a host-detection / abstract-tier mapping layer

- **What it is:** Keep tier intent (cheap/mid/frontier) abstractly and map it to a per-host concrete model at dispatch (the "generalize it" path from the issue).
- **Trade-offs:** There is no cross-vendor standard for declaring a model tier portably; the abstraction would be bespoke to Han (A20, A24). Adds a maintenance burden and a new failure mode for a problem that omission solves for free. Classic YAGNI: it buys per-host cost-tuning that no current requirement asks for, and the field is unreliable even on the native host (A16, A17).
- **Rests on:** (A20, A24, A16, A17).
- **Evidence status:** corroborated that no portable tier standard exists; the value of building one is unevidenced.

## Recommendation

- **Recommendation:** **O1 — remove the skill-level model overrides from the four planning skills.** This directly removes the Claude-specific model name that crosses into Codex (the surface the reporter hit), it is strictly simpler than the "generalize it" alternative (O5), and it realigns the skills with two existing decisions they currently contradict: the deliberate opus promotion of three synthesis agents (A10) and the PM-synthesis handling that `plan-implementation` already gets right (A2) but `plan-a-feature` does not (A1). Prefer omission over `model: "inherit"` (O2), because `inherit` is itself a Claude-specific token that carries the same cross-host risk. Pair the change with a one-line guidance clarification that skill-level dispatch is out of scope for the "always set model explicitly" agent rule (A18), so a future contributor does not reintroduce the overrides. Treat the **agent-frontmatter surface (O4) as a conditional follow-on, not part of this fix**: leave the 23 agent files' tiers intact and verify by running one planning skill under Codex after O1 — if dispatch still fails on a model identifier, escalate to O4; if it succeeds, the per-agent tiering is preserved and nothing further is needed.
- **Evidence basis:** The direction rests on corroborated evidence across all three trust classes: codebase (the overrides exist, supersede agent tiers, and contradict commit `aee41877` — A1–A5, A8, A10, A18), provided (the reporter's firsthand Codex observation and the maintainer's confirmation — A6), and web (omitting `model` inherits the session model on both Claude Code and Codex — A7, A9, A11). Two parts are explicitly *not* fully corroborated and are carried as caveats rather than load-bearing claims: that omission fixes Codex on the *live dispatch* path (documented only for Codex's migration tooling — A13 [single-source]), and that agent frontmatter is harmless on Codex (a single web assertion, A20/A21, with conflicting structural codebase evidence A22). Because those two gaps bear on *completeness* and not on *direction*, the recommendation stands but ships with the Codex live-run verification as its closing step. In strict mode this is a genuine recommendation, not a forced one: it does not rest on reasoning alone.

## Validation

### V1: The "documented exception" is not uniform across the four skills

- **Strategy:** Challenge the Evidence
- **Investigation:** Read `plan-a-feature/SKILL.md:234` and `plan-implementation/SKILL.md:243`.
- **Result:** Partially Refuted (of the original framing). `plan-implementation:243` deliberately runs PM synthesis on the agent's default (opus) with no override; `plan-a-feature:234` forces PM synthesis to `sonnet`. The two skills are inconsistent, which the initial evidence summary did not flag.
- **Impact:** Strengthens O1 — removal resolves the inconsistency as a side effect. Folded into Research Results and O1's trade-offs.

### V2: The cost framing is inverted — overrides contradict a deliberate opus promotion

- **Strategy:** Challenge the Evidence
- **Investigation:** Cross-referenced the 10 opus-tier agents against the planning rosters; read git commit `aee41877` (2026-05-18). Verified directly against git.
- **Result:** Confirmed. `junior-developer`, `information-architect`, and `user-experience-designer` were intentionally promoted to opus for synthesis-over-unbounded-input; the planning skills' blanket sonnet overrides silently nullify that promotion.
- **Impact:** The draft's "removal is a cost regression" framing was wrong and was rewritten. Removal *restores* documented intent (A10). This is now the headline reframe in the Summary and O1.

### V3: "Omit == inherit on Codex" is single-sourced via the migration tool

- **Strategy:** Challenge the Evidence
- **Investigation:** Checked whether any source documents Codex's *live* dispatch handling of an omitted/aliased model, versus the migration/import path.
- **Result:** Confirmed as a gap. The "drop and use default" behavior (A13) is documented for Codex's Claude-import tooling, not live plugin dispatch.
- **Impact:** Confidence on "omitting fixes Codex" lowered from known to expected; the recommendation now ships with a Codex live-run verification step rather than asserting completeness.

### V4: The actual Codex root cause (model vs. agent-registration) is unconfirmed

- **Strategy:** Challenge the Recommendation
- **Investigation:** Read `han-core/.codex-plugin/plugin.json` and the Codex marketplace manifest. Verified no agents path is declared.
- **Result:** Partially Refuted (of the "O1 is sufficient" assumption). Codex uses its own TOML agent format and `han-core` exposes only skills (A22), so it is possible the Codex failure involves agent registration, not just the model string. However, the reporter's firsthand observation (A6) specifically names the model as the failure, which keeps O1 as the evidenced primary fix.
- **Impact:** O4 is retained as a conditional follow-on and the recommendation's closing step is to verify under Codex. Reflected in Research Results and O1/O4.

### V5: The "always set model explicitly" guidance does not actually forbid O1

- **Strategy:** Challenge the Assumptions
- **Investigation:** Read `agent-model-selection.md` frontmatter scope (`**/agents/**/*.md`) and lines 134–135.
- **Result:** Partially Refuted. The rule scopes to agent definition files, not skill dispatch bodies — so O1 does not violate it.
- **Impact:** Added a recommendation to clarify the scope in guidance so the overrides are not reintroduced by a contributor following the rule.

### V6: O1 is "restore designed tiering," not "abandon model governance"

- **Strategy:** Challenge the Options Framing
- **Investigation:** Mapped each planning skill's dispatched agents to their frontmatter tiers.
- **Result:** Confirmed. The blanket override downgrades every dispatched agent regardless of its designed tier; removing it returns each agent to the tier the project chose.
- **Impact:** O1 reframed as restoring delegation to designed tiers, not as loss of control.

### V7: The "frontmatter is silently ignored on Codex" claim is single-source and load-bearing

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Searched the repo for corroboration of the agentskills.io "unknown keys ignored" / "35 platforms" claims.
- **Result:** Confirmed. The silent-ignore claim is a single web assertion (A20, A21) not corroborated in-repo; the "~35 platforms" figure is uncorroborated and is discarded.
- **Impact:** The "leave agent frontmatter alone, it's safe on Codex" sub-claim is now labeled single-source, and O4 is kept open as a conditional follow-on rather than confidently dismissed.

### Adjustments Made

The recommendation's *direction* (O1) survived validation and was strengthened (V1, V2, V5, V6). Three changes were made: (1) the cost framing was inverted from "regression" to "restores documented intent" (V2); (2) the claim that O1 fully fixes Codex was downgraded to expected-pending-verification, and a Codex live-run step was added to the recommendation (V3, V4); (3) the agent-frontmatter sub-claim was relabeled single-source and O4 retained as a conditional follow-on (V7). The recommendation was not rewritten into "no clear winner": the framed question (remove vs. generalize vs. keep) has a clearly evidenced winner; only the fix's *completeness* carries residual uncertainty, which is recorded as a remaining risk.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:**
  - **Untested completeness on Codex.** No source or test confirms that removing the skill overrides *fully* restores Codex execution; the agent-frontmatter surface and Codex agent-registration are unverified. The named verification: run one planning skill under Codex after O1 and observe whether dispatch succeeds (escalate to O4 if it still fails on a model identifier).
  - **Live-dispatch vs. migration behavior.** Codex "omit → inherit" is documented for the import tool (A13), not live dispatch — a single-source web caveat.
  - **Single-source web claims.** The "frontmatter keys silently ignored on non-Claude hosts" claim (A20, A21) is uncorroborated by the codebase; structural codebase evidence (A22) agrees only that agent frontmatter is not the demonstrated failure, not on the mechanism.
  - **Reintroduction risk.** Without a guidance clarification (V5), a contributor following "always set model explicitly" could re-add overrides to new planning skills.

## Sources

| ID | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
|---|---|---|---|---|---|---|
| A1 | plan-a-feature skill overrides | `han-planning/skills/plan-a-feature/SKILL.md:30,184,234` | n/a | codebase | Blanket "all sub-agents run on sonnet" + forces PM synthesis to sonnet | corroborated by A2,A3,A4 |
| A2 | plan-implementation skill overrides | `han-planning/skills/plan-implementation/SKILL.md:27,108,178,196,243` | n/a | codebase | Blanket sonnet rule; line 243 exempts PM synthesis (runs default opus) | corroborated by A1,A3,A4 |
| A3 | plan-a-phased-build skill overrides | `han-planning/skills/plan-a-phased-build/SKILL.md:31,144` | n/a | codebase | Blanket sonnet rule + IA review forced to sonnet | corroborated by A1,A2,A4 |
| A4 | plan-work-items skill overrides | `han-planning/skills/plan-work-items/SKILL.md:35,82` | n/a | codebase | Blanket sonnet rule + PM draft forced to sonnet | corroborated by A1,A2,A3 |
| A5 | Skill inventory | `han-*/skills/**/SKILL.md` | n/a | codebase | Only 4 of 34 skills carry a model directive; all 4 are planning skills | corroborated by A1–A4 |
| A6 | Issue #78 (reporter + maintainer) | `provided: github.com/testdouble/han/issues/78` | 2026-06-17 | provided | Reporter observed Codex could not use the `sonnet` model; maintainer confirmed "i had models set in those" | single source (provided, interested-party) |
| A7 | Claude Code subagents docs | https://code.claude.com/docs/en/sub-agents | 2026-06-17 | web | `model` accepts sonnet/opus/haiku/fable/full-id/inherit; omitting defaults to inherit | corroborated by A9 |
| A8 | Agent frontmatter inventory | `han-core/agents/*.md` | n/a | codebase | 23 agents tiered: 10 opus, 10 sonnet, 3 haiku | corroborated by A10 |
| A9 | Claude Code Agent SDK subagents | https://code.claude.com/docs/en/agent-sdk/subagents | 2026-06-17 | web | `model` defaults to main model if omitted; aliases or full id | corroborated by A7 |
| A10 | Opus-promotion commit | `git aee41877` (2026-05-18) | n/a | codebase | Deliberately promoted junior-developer, information-architect, user-experience-designer to opus | corroborated by A8 |
| A11 | Codex subagents docs | https://developers.openai.com/codex/subagents | 2026-06-17 | web | Codex agents are TOML; omitted optional fields inherit from parent session; model values are gpt-5.x | corroborated by A12,A15 |
| A12 | Codex models docs | https://developers.openai.com/codex/models | 2026-06-17 | web | Codex model namespace is gpt-5.x; no Claude aliases | corroborated by A11 |
| A13 | Codex Claude-import behavior | https://codex.danielvaughan.com/2026/05/13/codex-cli-agent-migration-system-import-claude-code-sessions-skills-config/ | 2026-06-17 | web | Codex migration drops Claude model references, keeps Codex default | single source (caveated) |
| A14 | Codex custom agent TOML | https://codex.danielvaughan.com/2026/04/27/codex-cli-custom-agent-definitions-toml-specialised-subagents/ | 2026-06-17 | web | Codex agent definitions use TOML with OpenAI model ids | corroborated by A11 |
| A15 | GitHub changelog (Claude+Codex models) | https://github.blog/changelog/2026-04-14-model-selection-for-claude-and-codex-agents-on-github-com/ | 2026-06-17 | web | Claude and Codex model namespaces are entirely distinct, no aliasing | corroborated by A11,A12 |
| A16 | Issue #44385 frontmatter model ignored | https://github.com/anthropics/claude-code/issues/44385 | 2026-06-17 | web | Agent frontmatter `model:` silently ignored in some versions | corroborated by A17 |
| A17 | Issue #18873 Agent-tool model 404 | https://github.com/anthropics/claude-code/issues/18873 | 2026-06-17 | web | Agent-tool `model` param returned 404 for aliases in 2.1.12+, closed "not planned" | corroborated by A16 |
| A18 | agent-model-selection guidance | `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md` | n/a | codebase | "Always set model explicitly"; resolution order env→dispatch→frontmatter→inherit; scope `**/agents/**/*.md` | corroborated by A7,A9 |
| A19 | Claude Code model-config | https://code.claude.com/docs/en/model-config | 2026-06-17 | web | `CLAUDE_CODE_SUBAGENT_MODEL` highest precedence; aliases are Anthropic-specific | corroborated by A18 |
| A20 | Agent Skills standard spec | https://agentskills.io/specification | 2026-06-17 | web | Standard defines no `model` field; runtimes ignore unrecognized keys | single source (caveated) |
| A21 | SKILL.md frontmatter reference | https://www.agentpatterns.ai/tool-engineering/skill-frontmatter-reference/ | 2026-06-17 | web | `model` is a Claude Code extension; non-CC runtimes ignore it | single source (caveated) |
| A22 | han-core Codex plugin manifest | `han-core/.codex-plugin/plugin.json` | n/a | codebase | Declares only `"skills"` and `capabilities: ["Skills"]`; no agents path | single source (codebase, structural) |
| A23 | plugin-naming (Codex compat) | `han-plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-naming.md` | n/a | codebase | Codex compatibility already a project concern (dot-in-name fix) | single source (codebase) |
| A24 | Cross-host portability framing | https://zylos.ai/research/2026-04-05-ai-agent-ecosystem-fragmentation-platform-lock-in-portability | 2026-06-17 | web | No cross-vendor model-tier standard; abstraction layers add cost | single source (caveated) |

### A6: Issue #78 — reporter observation and maintainer confirmation — recommendation-bearing

- **Link / location:** `provided: github.com/testdouble/han/issues/78` (feedback body + comment by maintainer mxriverlynn)
- **Retrieved:** 2026-06-17
- **Trust class:** provided (operator-supplied — interested-party scrutiny)
- **Summary:** The feedback reports that some Han skills instruct Codex to launch sub-agents with `model: "sonnet"`, which fails in Codex because `sonnet` is a Claude-specific tier/name rather than a Codex-supported identifier, and that the failure appears before useful work begins. The maintainer confirms the root cause: "i completely forgot i had models set in those," and proposes either generalizing or removing the specifier. This is the firsthand evidence that the *skill-level model name* is the failure surface, which anchors O1 as the primary fix.
- **Evidence status:** single source (provided); the symptom is corroborated mechanically by A11/A12/A15 (Codex namespace excludes Claude aliases).

### A10: Opus-promotion commit `aee41877` — recommendation-bearing

- **Link / location:** `git aee41877` ("Align junior-developer, information-architect, user-experience-designer to opus", 2026-05-18)
- **Retrieved:** n/a (codebase)
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The project deliberately promoted three synthesis-over-unbounded-input agents from sonnet to opus to match the guidance and their long-form docs, noting it "is a real behavior and cost change whenever any of these three agents is dispatched." The planning skills' blanket sonnet overrides silently undo this whenever those agents are dispatched inside them. This is the codebase evidence that inverts the cost objection: removing the overrides restores the intended tier rather than regressing it.
- **Evidence status:** corroborated by A8 (frontmatter inventory) and A18 (guidance).

### A7: Claude Code subagents documentation — recommendation-bearing

- **Link / location:** https://code.claude.com/docs/en/sub-agents
- **Retrieved:** 2026-06-17
- **Trust class:** web (outside the trust boundary)
- **Summary:** The authoritative Claude Code reference states the `model` field is optional and defaults to `inherit` (the parent session's model) when omitted, and lists the accepted alias/full-id/inherit values. This establishes that omitting the override on Claude Code is a defined, safe state equivalent to inherit — the half of the cross-host claim that is fully corroborated (A9). The Codex half (A11) is parallel but its live-dispatch behavior carries the A13 single-source caveat.
- **Evidence status:** corroborated by A9.
