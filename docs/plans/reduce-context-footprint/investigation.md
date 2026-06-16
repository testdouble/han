# Investigation: Reduce always-loaded context footprint of Han agent and skill descriptions (#51)

Han's agent and skill `description:` frontmatter is loaded into the system prompt every session for routing, and the largest agent descriptions have accumulated body-grade vocabulary that can move to the on-demand body without touching a single routing signal.

## Problem Statement

- **Symptoms:** Running `/context` with `han-core` installed shows Custom agents ≈ 6.1k tokens and Skills ≈ 7.1k tokens, of which han-core alone is ~5.4k agent + ~3.76k skill ≈ 9.2k tokens (~4.6% of a 200k window), spent every session before any prompt is sent. A handful of agents dominate: `on-call-engineer`, `junior-developer`, and `project-manager` are each over 2,500 characters.
- **Expected behavior:** The always-loaded footprint should carry only what Claude Code needs to *route* (decide which skill/agent to invoke). Everything else — domain vocabulary, methodology name-drops, internal process detail, artifact filenames — should live in the body, which loads only when the entity is invoked.
- **Conditions:** Always. The `description:` frontmatter of every installed skill and agent is loaded into the system prompt for every conversation, whether or not the entity is used.
- **Impact:** Every Han user pays this token cost continuously. Beyond budget, oversized descriptions degrade routing for *every other* skill, because every token competes for attention weight (per the project's own context-hygiene guidance, E15). Reducing the footprint without losing routing signal is a pure win.

## Evidence Summary

### E1: on-call-engineer is the largest description in the suite at 2,939 chars (~735 tokens)

- **Source:** `han-core/agents/on-call-engineer.md:3`
- **Finding:** Two spans carry no routing signal. (1) A 17-item anti-pattern checklist (~619 chars) listing "missing or incomplete timeouts ... kill-switch absence on risky paths, and observability-driven-development gaps" — this exact list reappears in the body's `## Anti-Patterns` section. (2) A 749-char "Vocabulary:" paragraph naming Nygard / Brooker / SRE / Majors / Cook / Westrum with full parenthetical term expansions — this reappears verbatim in the body's `## Domain Vocabulary`. The `Use when ... 'what wakes someone up at 3am'` trigger and the sibling-named `Does not` tail are load-bearing.
- **Relevance:** ~1,370 chars / ~343 tokens are removable by moving the duplicated enumerations to the body (where they already exist) and condensing the `Does not` tail's per-entry prose from ~30 words to ~8 while keeping every routed-to agent name. Nothing about "missing backpressure vs. blocking I/O" changes which agent a caller selects.

### E2: junior-developer at 2,686 chars (~672 tokens) — the most bloated `Does not` tail in the suite

- **Source:** `han-core/agents/junior-developer.md:3`
- **Finding:** An 863-char `Does not perform specialist analysis:` tail names 13 sibling agents, each wrapped in routing-irrelevant domain prose (e.g. "intra-codebase architectural SOLID / coupling / cohesion review to structural-analyst / behavioral-analyst / concurrency-analyst / risk-analyst / software-architect"). A ~619-char two-mode elaboration restates behavior that lives fully in the body at lines 12-16.
- **Relevance:** ~840 chars / ~210 tokens removable. The load-bearing unit of each redirect is the *agent name*; the prose describing what each sibling does is redundant — a caller who doesn't know what `devops-engineer` covers will look it up, not read it here.

### E3: project-manager at 2,591 chars (~648 tokens) — exhaustive 17-agent roster embedded in frontmatter

- **Source:** `han-core/agents/project-manager.md:3`
- **Finding:** A ~360-char parenthetical lists all 17 specialist sibling agents by name inside "Pulls additional specialist sibling agents (...) into a discussion." A ~400-char two-mode parenthetical elaboration restates body content (lines 13-16).
- **Relevance:** ~760 chars / ~190 tokens removable. "Pulls specialist sibling agents in when their expertise is needed" routes identically without enumerating all 17; the roster adds zero signal to a caller deciding whether to invoke `project-manager`.

### E4: The mid-size architecture/specialist agents carry methodology name-drops that duplicate the body

- **Source:** `han-core/agents/system-architect.md:3` (1,745 chars), `data-engineer.md:3` (1,611), `information-architect.md:3` (1,444), `software-architect.md:3` (1,397), `devops-engineer.md:3` (1,169), `user-experience-designer.md:3` (1,010)
- **Finding:** The "Audits ... against [methodology lists]" pattern is the densest token sink after E1-E3. `information-architect` carries ~548 chars of IA author/methodology name-drops (Rosenfeld & Morville, Dan Brown, LATCH, Mark Baker, JoAnn Hackos/DITA, ...); `data-engineer` ~290 chars (Codd, Kimball/Inmon/Data Vault, CQRS, ACID/BASE/CAP, GDPR/HIPAA/SOC2/PCI); `user-experience-designer` ~180 chars of author-year citations (Mace 1997, Norman, Saffer, Cooper, Fitts/Hick). Each list reappears in that agent's body `## Domain Vocabulary`. The `Does not` tails on all six are already at the right ~10-15-words-per-entry density and are load-bearing.
- **Relevance:** ~870 chars / ~218 tokens removable across these six by moving the methodology enumerations to the body, keeping only the concise named-framework signals that carry routing weight (e.g. keep "Nielsen's 10 heuristics, WCAG 2.2, dark-pattern detection"; drop the parenthetical citations).

### E5: The remaining 14 han-core agents are already lean; the analyst/explorer agents need no change

- **Source:** all 14 remaining files in `han-core/agents/`
- **Finding:** `concurrency-analyst` (722 chars), `behavioral-analyst` (686), `edge-case-explorer` (679), `gap-analyzer` (647), `risk-analyst` (638), `test-engineer` (606), `structural-analyst` (574), `research-analyst` (558), `adversarial-security-analyst` (553), `content-auditor` (319), `codebase-explorer` (288), `evidence-based-investigator` (245), `project-scanner` (243), `adversarial-validator` (224). None carry vocabulary enumerations; their `Does not` tails are 3-5 items at 10-15 words each.
- **Relevance:** This group is the proof that lean routing works: `structural-analyst`/`behavioral-analyst`/`risk-analyst` route just as precisely with ~60-word `Does not` tails as `on-call-engineer` does with ~150 words. Combined realistic trim is only ~200 chars; leave them essentially alone.

### E6: Agent totals — ~5,894 tokens, with ~1,111 tokens (~47%) removable while preserving every routing signal

- **Source:** measured character counts across all 23 `han-core/agents/*.md`
- **Finding:** Total agent description text = 23,574 chars / ~5,894 tokens. The top 9 agents hold 16,592 chars / ~4,148 tokens. Conservative per-agent trim preserving every `Use when` sentence, every sibling agent name in every `Does not` tail, and every output contract: on-call-engineer ~343 tok, junior-developer ~210, project-manager ~190, information-architect ~108, data-engineer ~90, user-experience-designer ~45, system-architect ~25, software-architect ~25, devops-engineer ~25, remaining 14 combined ~50 = **~1,111 tokens (~4,440 chars)**.
- **Relevance:** This is a ~47% cut to the always-loaded *agent* budget achievable purely by relocating body-grade content and tightening prose — no routing trigger, sibling redirect, or output contract is touched.

### E7: Skill descriptions total ~5,329 tokens across 28 skills; ~1,795 tokens (~34%) trimmable

- **Source:** all 28 `SKILL.md` files across the six plugins. Per-plugin: han-core 14,507 chars (~3,628 tok, 18 skills), han-atlassian 2,573 (~643, 3), han-github 1,521 (~381, 3), han-reporting 1,079 (~270, 2), han-plugin-builder 881 (~220, 1), han-feedback 754 (~188, 1). Grand total 21,315 chars / ~5,329 tokens.
- **Finding:** The trimmable patterns are consistent: (1) parenthetical example/quote lists restating the trigger ("including 'plan the implementation of X', 'how do we build this'..."); (2) MOVABLE-to-body internal-process and artifact-filename sentences ("Produces three cross-referenced files beside the source spec: feature-implementation-plan.md, ..."); (3) restatements that paraphrase the opening sentence; (4) prerequisite/default-mode sentences that belong in the body ("Requires the gh CLI ...", "Defaults to saving an unpublished draft ..."); (5) a few low-value `Does not` clauses routing to distant, never-confused siblings (ADR↔runbook, work-items-to-issues↔code-review). Biggest individual skills: plan-implementation (1,011), iterative-plan-review (969), plan-a-phased-build (995), gap-analysis (984), plan-a-feature (998), research (979).
- **Relevance:** ~7,181 chars / ~1,795 tokens removable (~34%) while preserving every load-bearing trigger and near-sibling boundary. Four skills (project-discovery, stakeholder-summary, plan-work-items, post-code-review-to-pr) are already lean and need no change.

### E8: The guidance already codifies a 1024-char budget for skills — and all 28 skills already comply

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-length.md:14-31`
- **Finding:** "**Write every skill `description` to fit within 1024 characters.** ... When a skill is uploaded to claude.ai or used in cowork, the `description` field has a **hard limit of 1024 characters**. Exceed it and the upload is truncated or rejected outright." The file is path-scoped to `**/skills/**/*.md`.
- **Relevance:** The skill budget already exists and every skill is under it. So skill trimming is an *optimization within budget*, not a compliance fix. The budget concept is proven and ready to be mirrored for agents.

### E9: The agent-building guidance has NO length budget — and actively tells authors there is none

- **Source:** `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md:22-23, 36-46`
- **Finding:** "The frontmatter `description` field ... is triggering metadata ... and is **not subject to the 50-token budget**." And: "This description is well over 50 tokens, and that is fine." There is no character ceiling stated anywhere in the five agent-building-guidelines files. The skill-only `skill-description-length.md` and `progressive-disclosure.md` both carry `**/skills/**/*.md` path scope and never activate on agent files.
- **Relevance:** This is the root-cause gap. The agent guidance correctly distinguishes the description from the 50-token *Role Identity* budget, but then leaves agent descriptions with no ceiling at all — so authors of the large agents had nothing telling them the description is always-loaded and must stay lean. The progressive-disclosure rule ("every token here is paid in every conversation") and the context-hygiene anti-pattern table both exist but are scoped to skills only.

### E10: The priority cutting ladder already defines the safe trim order

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-length.md:74-81`
- **Finding:** "1. Hedges, filler, and restated capability (cut first) ... zero trigger value lost. 2. Boundary clauses against skills no one would confuse this with. ... 3. Boundary clauses against near siblings (cut last, and reluctantly) ... the *lowest-priority thing to cut yet the highest-cost to lose*. 4. What the skill does and its primary when-to-use triggers (never cut)."
- **Relevance:** This ladder is the operating procedure for the entire trim. It maps cleanly onto the agent findings: vocabulary/methodology enumerations and restated capability are tier 1; distant-sibling `Does not` clauses (ADR↔runbook) are tier 2; near-sibling redirects (every architect/analyst pair) are tier 3 and must be preserved or only tightened, never deleted.

### E11: Disambiguation must be bidirectional — trimming one side without the other breaks routing

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-frontmatter.md:96-97`
- **Finding:** "Disambiguation must work in **both directions**. If `code-review` says 'use `post-code-review-to-pr` for GitHub posting,' then `post-code-review-to-pr` must also say 'use `code-review` for local review without GitHub.' One-way disambiguation leaves a gap that Claude can fall through."
- **Relevance:** This is the hardest constraint on the trim. Any `Does not X — use Y` clause proposed for deletion must be checked against Y's reverse clause; if Y points back, deleting only one side opens a routing gap. This makes per-entity trimming unsafe in isolation and forces a paired review.

### E12: The four mandatory description components are all load-bearing

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-frontmatter.md:22-29`
- **Finding:** "A complete description answers four questions: **What** ... **When to use** ... **Boundary** (What should NOT trigger it?) ... **Trigger breadth** ... Minimum 3 sentences. Typically 3-5 sentences." The Boundary component *is* the `Does not X — use Y` clause.
- **Relevance:** Sets the floor. No description may be trimmed below all four components. Boundary clauses are a required component, not decoration — confirming E10's tier-3 caution.

### E13: The over-budget agents were authored before the length guidance existed

- **Source:** git history — the large agents date to May 11-28 2026; `skill-description-length.md` was added 2026-06-02
- **Finding:** Nine agents exceed the 1024-char skill limit (on-call-engineer 2,939, junior-developer 2,686, project-manager 2,591, system-architect 1,745, data-engineer 1,611, information-architect 1,444, software-architect 1,397, devops-engineer 1,169, gap-analyzer 1,029); average agent description 1,042 chars.
- **Relevance:** This is not authors ignoring guidance — the guidance did not exist for agents when these were written, and still doesn't. Confirms E9: the fix must add the missing guidance, not just trim once.

### E14: The duplicated content already lives in the agent bodies (movement is safe)

- **Source:** body sections of `on-call-engineer.md` (`## Anti-Patterns`, `## Domain Vocabulary`), `data-engineer.md`, `information-architect.md`, `user-experience-designer.md` (`## Domain Vocabulary` equivalents)
- **Finding:** The anti-pattern checklist and vocabulary paragraphs flagged in E1 and E4 already appear, verbatim or near-verbatim, in each agent's body.
- **Relevance:** "Move to body" is, for the densest spans, actually "delete from frontmatter" — the body copy already exists, so the agent loses no operating capability when invoked. This makes the highest-yield cuts also the lowest-risk.

### E15: The context-hygiene guidance names verbose frontmatter as an attention-degradation anti-pattern

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-hygiene.md:8-10, 130`
- **Finding:** "Research on transformer attention shows that every token in context competes for attention weight. Irrelevant tokens don't just waste space — they actively dilute the model's ability to attend to the tokens that matter." The anti-pattern table lists "Verbose frontmatter descriptions | Token cost paid in every conversation."
- **Relevance:** The benefit of trimming is not only budget. Oversized descriptions actively hurt routing accuracy for *every* skill/agent by diluting attention — so this work plausibly *improves* routing rather than risking it, which directly answers the issue's "without hurting routing quality" concern.

## Root Cause Analysis

### Summary

The large agent (and several skill) descriptions carry body-grade content — domain-vocabulary enumerations, methodology name-drops, internal process detail, artifact filenames, and over-elaborated sibling-redirect prose — in their always-loaded frontmatter, because the agent-building guidance never set a description-length budget and explicitly told authors agent descriptions have no ceiling (E9, E13); the routing-relevant signal is a small fraction of the text and the rest is duplicated in the on-demand body (E14).

### Detailed Analysis

The always-loaded footprint is the sum of every `description:` field (E6, E7). Claude Code uses these to route, so the routing-relevant content is: the opening "what it does" sentence, the `Use when` trigger, the boundary (`Does not X — use Y`) clauses naming sibling entities, and the output contract (E12). Everything else is body-grade.

The biggest offenders accumulated three kinds of body-grade content in frontmatter: (1) methodology/vocabulary enumerations that already live verbatim in the agent body (E1, E4, E14) — these are the single densest token sink and carry zero routing weight, because no caller selects `on-call-engineer` over a sibling on the strength of "Brooker/AWS Builders' Library resilience math (243× retry amplification...)"; (2) over-elaborated `Does not` tails where the load-bearing unit is the agent *name* but each redirect drags ~30 words of sibling-domain prose (E2, E3) — proven unnecessary because the lean analyst agents route just as precisely with ~12-word redirects (E5); (3) internal process / artifact-filename sentences in skills (E7) that describe what happens *after* invocation, not whether to invoke.

This accumulated because the guidance that would have prevented it is scoped to skills only (E9): `skill-description-length.md` (the 1024-char budget and the priority cutting ladder, E8, E10), `progressive-disclosure.md` (every-token-paid-every-conversation), and `context-hygiene.md` (E15) all carry `**/skills/**/*.md` path scope, and `agent-domain-focus.md` is silent on any description ceiling — it exempts the description from the 50-token Role Identity budget and gives no upper-bound signal in its place (validation softened this from "actively permissive" to "silent"). The large agents predate even the skill guidance (E13). So the root cause is a guidance gap (no agent description budget) that allowed body-grade content to settle in always-loaded frontmatter.

The fix is therefore two-part: (1) trim the existing descriptions following the established cutting ladder (E10), moving duplicated vocabulary to the body (E14) and tightening redirect prose while preserving every routing component (E12) and every bidirectional boundary pair (E11); (2) close the guidance gap so agent descriptions get the same budget discipline skills already have (E9), preventing regression.

## Coding Standards Reference

| Standard | Source | Applies To |
|----------|--------|------------|
| 1024-char description budget; priority cutting ladder (filler → distant-sibling boundary → near-sibling boundary → never cut what/triggers) | `han-plugin-builder/.../skill-building-guidance/skill-description-length.md` | The operating procedure for every description trim; the budget to mirror for agents |
| Four mandatory components (what / when-to-use / boundary / trigger-breadth); min 3 sentences | `han-plugin-builder/.../skill-building-guidance/skill-description-frontmatter.md:22-29` | The floor — no description trimmed below all four components |
| Bidirectional disambiguation | `han-plugin-builder/.../skill-building-guidance/skill-description-frontmatter.md:96-97` | Every `Does not X — use Y` deletion must be checked against Y's reverse clause |
| Progressive disclosure: frontmatter always loaded, body on-demand | `han-plugin-builder/.../skill-building-guidance/progressive-disclosure.md` | Justifies moving vocabulary/process detail from description to body |
| Writing voice (no em-dashes in new prose, direct second person, no hype) | `docs/writing-voice.md` | Any rewritten description text and new guidance prose |
| Every skill/agent has a long-form doc; indexes stay complete | `CLAUDE.md` Conventions | If any description wording change affects `docs/skills/` or `docs/agents/` scent lines, update them in lockstep (run `/han-update-documentation`) |

## Planned Fix

### Summary

Trim the always-loaded `description:` text on the heavy agents and skills by relocating body-grade content (already-duplicated vocabulary, internal process, artifact filenames) to the body and tightening sibling-redirect prose — preserving every routing trigger, boundary clause, and output contract — then add an agent description-length budget to the authoring guidance so the gain does not regress.

### Changes

This is a documentation/metadata change set. No application code. Group the work into three tranches so it can land incrementally and be verified at each step.

#### Tranche A — `han-core/agents/{on-call-engineer,junior-developer,project-manager}.md` (highest yield)

- **Change:** Rewrite the `description:` frontmatter of the three largest agents. Remove the duplicated anti-pattern checklist and "Vocabulary:" paragraph from `on-call-engineer` (already in its body, E14); collapse `junior-developer`'s 13-agent `Does not` tail and `project-manager`'s 17-agent roster + two-mode parentheticals to the agent names plus a short clause each; keep every `Use when` sentence, every sibling agent name, and every output contract.
- **Evidence:** E1, E2, E3, E10, E14
- **Standards:** Priority cutting ladder; four mandatory components; bidirectional disambiguation; progressive disclosure; writing voice
- **Details:** Target each of the three under ~1024 chars (the mirrored budget). Expected reclaim ~600 tokens (revised down from ~743 per validation V7). Required preservations surfaced by validation: keep "metastable failure" as a retained term in on-call-engineer (V3 — uniquely owned, no fallback route); keep the exact phrase "hard boundary at the application source line" in on-call-engineer's devops-engineer redirect (V5); keep a short operating-mode signal in junior-developer such as "sounding board / asks clarifying questions" (V4 — the only thing separating it from project-manager). Compress on-call-engineer redirects *selectively*, not uniformly: the security and risk redirects shrink to ~8 words, but the devops-engineer and data-engineer redirects carry real disambiguation load and need more (V7). Preserve all 16 sibling names in junior-developer's tail (V9) and the "full specialist roster" signal in project-manager (do not reduce to bare "specialist agents," which loses the contrast with plan-implementation's constrained dispatch). Before deleting any vocabulary span, confirm it exists in the body; the author attributions (e.g. "(Norman)", "(Cooper)") are description-unique (V8) but droppable because the concept term survives in the body. **Scope addition (V5):** add a reverse pointer in `devops-engineer` → `on-call-engineer` for code-level resilience — the boundary is one-way today and the trim should repair it, not preserve the gap.

#### Tranche B — `han-core/agents/{information-architect,data-engineer,user-experience-designer,system-architect,software-architect,devops-engineer}.md` (methodology name-drops)

- **Change:** Drop author attributions and redundant terms from each `description:`, keeping the concise named-framework signals AND any domain term that is the *only* always-loaded anchor for a real request class; leave the already-tight `Does not` tails untouched.
- **Evidence:** E4, E5, E10, E14
- **Standards:** Same as Tranche A
- **Details:** Expected reclaim ~270 tokens (revised down from ~318 per validation V2). Keep, e.g., "Nielsen's 10 heuristics, WCAG 2.2, dark-pattern detection"; drop "(Mace 1997)", "(Saffer: trigger/rules/feedback/loops)", "(Fitts, Hick)" etc. **Required preservation (V2):** keep "event sourcing and CQRS" in data-engineer — it is a primary routing trigger with no fallback in any other agent's description, not a body-grade name-drop. Before deleting any term, grep all 23 agent descriptions to confirm it is not the sole always-loaded anchor for that vocabulary (the V2/V3 check generalized). Confirm each removed list exists in that agent's body `## Domain Vocabulary`; note the concept survives even where the author attribution does not (V8). Leave the 14 lean agents (E5) alone except trivial tightening.

#### Tranche C — heavy `SKILL.md` descriptions

- **Change:** Trim the largest skill descriptions (plan-implementation, iterative-plan-review, plan-a-phased-build, gap-analysis, plan-a-feature, research, code-review, and the others flagged in E7) by removing parenthetical example lists, restatements, prerequisite/default-mode sentences, internal-process and artifact-filename sentences (move artifact details to the body), and the one verified distant-sibling `Does not` clause (ADR↔runbook). Preserve every primary trigger and every near-sibling boundary.
- **Evidence:** E7, E8, E10, E11, E12
- **Standards:** Same as Tranche A; all skills already under 1024 chars so this is optimization within budget
- **Details:** Expected reclaim ~1,700 tokens. Apply the cutting ladder strictly: tier-1 filler/restatement and the single verified tier-2 distant-sibling boundary (ADR↔runbook) only; tighten (do not delete) near-sibling boundaries. **Correction (V6):** do NOT cut a "work-items-to-issues↔code-review" clause — it does not exist; work-items-to-issues actually points to `post-code-review-to-pr` (a near-sibling) and that clause stays. **Pre-cut check (V7):** before trimming example lists in the near-sibling clusters — the planning cluster (plan-a-feature / plan-implementation / plan-a-phased-build / plan-work-items / iterative-plan-review) and the analysis cluster (architectural-analysis / code-review / investigate / research) — confirm the example phrases are not the primary disambiguation between two siblings; where a boundary clause names a behavior but not the sibling agent, add the agent name (e.g. iterative-plan-review's "generating new plans from scratch — use plan-a-feature"). Check bidirectionality (E11) before dropping any boundary clause. Leave the four already-lean skills (project-discovery, stakeholder-summary, plan-work-items, post-code-review-to-pr) unchanged.

#### Tranche D — close the guidance gap (prevents regression)

- **Change:** Add an agent description-length budget to the authoring guidance. Either add a new `agent-building-guidelines/agent-description-length.md` (path-scoped `**/agents/**/*.md`) or extend `agent-domain-focus.md`, stating a character budget for agent descriptions, that the description is always-loaded routing metadata (not the place for domain vocabulary), and that vocabulary/methodology belongs in the body. Reuse the existing priority cutting ladder by reference. Update the `agent-domain-focus.md` lines that currently say agent descriptions have "no budget" so they point to the new budget instead.
- **Evidence:** E9, E13, E15
- **Standards:** Mirror `skill-description-length.md`; writing voice; keep the guidance index/cross-references complete (CLAUDE.md)
- **Details:** This is the part that makes the trim durable. Without it, new agents repeat the pattern. Decide the agent budget number during planning — a higher ceiling than 1024 may be defensible for agents (they legitimately need more boundary clauses), but it must exist. Update any guidance index that lists the agent-building-guidelines files.

## Validation Results

Two independent `adversarial-validator` agents challenged the evidence, the fix, and the assumptions. The direction held, but they forced material corrections: the token savings were overstated by ~15-20%, several specific phrases turned out to be load-bearing routing anchors (not body-grade), and two deletion targets were misidentified. All corrections are folded into the Planned Fix above and itemized below.

### Counter-Evidence Investigated

#### V1: Agent descriptions are genuinely always-loaded (the agent half targets a real cost)

- **Hypothesis:** The whole agent tranche assumes agent `description:` frontmatter is loaded into the system prompt every session like skills. If agents load only on dispatch, Tranches A-B reduce nothing.
- **Investigation:** Validator flagged that no harness parameter (`agentListingMaxDescChars`) is documented for agents, unlike skills. Checked against the issue's own evidence: the `/context` breakdown shows `Custom agents: 6.1k tokens (3.1%)` measured immediately on session start, before any prompt.
- **Result:** Confirmed. The `/context` measurement is direct empirical proof that agent descriptions are loaded every session. The absence of a *documented* parameter is a guidance gap, not counter-evidence.
- **Impact:** None on direction. Strengthens Tranche D (the guidance should document the agent always-loaded cost, which is currently undocumented).

#### V2: "event sourcing and CQRS" in data-engineer is a load-bearing trigger with no fallback route

- **Hypothesis:** E4 classes the data-engineer methodology list as body-grade name-drops, safe to remove.
- **Investigation:** Searched every agent description for "event sourcing"/"CQRS". Only `data-engineer.md:3` carries them in always-loaded text; `system-architect` mentions CQRS only in its body. A user request like "audit this event-store / projection design for CQRS problems" has no other description-level anchor, and `data-engineer`'s `Use when` trigger (schema/migration/pipeline/data-access) does not contain that vocabulary.
- **Result:** Refuted (for this span). "event sourcing and CQRS" is a primary routing signal, not a name-drop.
- **Impact:** Tranche B must retain "event sourcing and CQRS" (and any other domain term that is the *only* always-loaded anchor for a real request class). Reframes Tranche B from "delete the methodology list" to "drop author attributions and redundant terms, keep terms that are a unique routing anchor."

#### V3: "metastable failure" is uniquely owned by on-call-engineer

- **Hypothesis:** E1 classes the entire "Vocabulary:" paragraph as body-grade, safe to remove wholesale.
- **Investigation:** "metastable failure" appears in no other agent description and is explicitly flagged in-text as "the lead new vocabulary not covered by other agents." A "check this for metastable failure" request has no fallback.
- **Result:** Partially Refuted. The bulk of the paragraph is safely removable, but the single term "metastable failure" (~20 chars) must stay.
- **Impact:** Tranche A keeps "metastable failure" as a retained term while deleting the rest of the vocabulary parenthetical.

#### V4: junior-developer / project-manager operating-mode prose does disambiguation work

- **Hypothesis:** E2 classes junior-developer's two-mode elaboration as pure restatement of body content, safe to remove.
- **Investigation:** junior-developer and project-manager both "stress-test plans" and overlap heavily. The distinguishing signal is operating mode: junior-developer = "sounding board / asks clarifying questions / reframes in simpler terms"; project-manager = "facilitates / round-robin / produces a committed plan." project-manager's description does NOT contain the sounding-board language, so deleting it from junior-developer removes the only thing separating the pair for a request like "stress-test this plan for me."
- **Result:** Partially Refuted. The verbose elaboration can shrink, but a short form of "sounding board / asks clarifying questions" must survive.
- **Impact:** Tranche A preserves a one-clause operating-mode signal in junior-developer rather than deleting the whole span.

#### V5: The on-call-engineer ↔ devops-engineer boundary is already unidirectional, and the "application source line" phrase is load-bearing

- **Hypothesis:** Plan said to "confirm devops-engineer still points back to on-call-engineer" before trimming.
- **Investigation:** `devops-engineer.md:3` contains no reference to `on-call-engineer` at all — the reverse clause does not exist today. Both agents claim observability territory (on-call at the source-instrumentation line, devops at the alert/dashboard level); the only text disambiguating them is on-call-engineer's "there is a hard boundary at the application source line."
- **Result:** Refuted (the precondition the plan assumed). Bidirectionality is already broken; this is a pre-existing gap, not a trim-induced one.
- **Impact:** Two changes. (1) Tranche A must preserve the exact phrase "hard boundary at the application source line" when condensing on-call-engineer's devops-engineer redirect (so the trim does not widen the gap). (2) Tranche A scope grows by one optional change: add a reverse pointer in devops-engineer to on-call-engineer for code-level resilience. Per E11 this is the correct repair; it is a small addition the original plan did not account for.

#### V6: The "work-items-to-issues ↔ code-review" distant-sibling deletion target is a misidentification

- **Hypothesis:** Tranche C listed "work-items-to-issues↔code-review" as a distant-sibling boundary safe to cut.
- **Investigation:** `work-items-to-issues/SKILL.md:11` actually reads "Does not review code or post pull request comments — use **post-code-review-to-pr** for that." It points to `post-code-review-to-pr` (a genuine near-sibling), not to `code-review`. The named pair does not exist.
- **Result:** Refuted. Acting on the plan literally would delete a valid near-sibling boundary.
- **Impact:** Tranche C drops this deletion target entirely. The work-items-to-issues → post-code-review-to-pr clause is preserved. The ADR↔runbook distant-sibling cut stands (verified: no plausible request confuses the two).

#### V7: E5's "lean analysts prove lean routing works" is a partial false analogy

- **Hypothesis:** E5 used structural/behavioral-analyst leanness to justify cutting on-call-engineer's redirect prose to ~8 words per entry.
- **Investigation:** The analyst agents are lean because their neighbors are orthogonal (static structure vs. runtime behavior vs. risk). on-call-engineer overlaps substantively with devops-engineer (observability), data-engineer (migration/data-integrity), and concurrency-analyst (blocking I/O), so several of its redirects carry real disambiguation load that ~8 words cannot hold.
- **Result:** Partially Refuted. The security and risk redirects compress fine; the devops-engineer and data-engineer redirects need more than 8 words.
- **Impact:** Revise on-call-engineer's realistic saving down from ~343 to ~200-250 tokens. Per-redirect compression is selective, not uniform.

#### V8: Some methodology citations are not verbatim-duplicated in the body

- **Hypothesis:** E14 claimed every flagged vocabulary span "reappears in that agent's body `## Domain Vocabulary`."
- **Investigation:** In `user-experience-designer.md`, the author attributions `(Norman)` and `(Cooper)` appear only in the frontmatter; the body carries the concepts ("affordance and signifier clarity", "goal-directed design") without attribution. `information-architect.md` carries "Hackos" (abbreviated) in the body, not "JoAnn Hackos".
- **Result:** Partially Refuted. The *concepts* survive in the body; the author *attributions* are description-unique.
- **Impact:** Low. The justification shifts from "delete, it's duplicated" to "drop the author attribution, the routing-relevant concept term survives in the body." Still safe — author surnames are not how users phrase requests. No change to which spans are cut, only to the stated rationale.

#### V9: junior-developer's redirect tail names 16 agents, not 13

- **Hypothesis:** E2 measured the tail at 13 agents / 863 chars.
- **Investigation:** Enumerated the tail: 16 agents, ~917 chars.
- **Result:** Refuted (the count). Core argument (over-elaborated tail) stands.
- **Impact:** When rewriting, preserve all 16 sibling names. Does not change the approach.

#### V10: Token measurements and the chars/4 heuristic are accurate

- **Hypothesis:** The ~5,894 agent / ~5,329 skill / ~9.2k han-core baselines could be inflated.
- **Investigation:** Independent re-extraction (after fixing a YAML escaped-quote parsing artifact) reproduced 23,574 agent chars and 14,507 han-core skill chars exactly; chars/4 was within 1 token of an exact tokenizer count.
- **Result:** Confirmed. Baselines are sound; headline percentages may vary ±5-10% by tokenizer.
- **Impact:** None. Treat the targets as planning figures, not contract numbers.

#### V11: No automated guard; long-form docs are a soft consumer

- **Hypothesis:** Some consumer other than routing reads these descriptions verbatim.
- **Investigation:** No tests, no `.github/workflows/`, no `marketplace.json` description assertions. `docs/agents/*.md` long-form docs mirror the same *vocabulary* (not verbatim frontmatter), maintained by `/han-update-documentation`.
- **Result:** Confirmed (no hard consumer; one soft, doc-mirror dependency).
- **Impact:** Keep the Coding Standards row requiring a `/han-update-documentation` pass after edits. No CI will catch a routing regression, so PR review is the only gate — argues for landing the tranches incrementally.

### Adjustments Made

- **Tranche A** (on-call-engineer, junior-developer, project-manager): preserve "hard boundary at the application source line" (V5) and "metastable failure" (V3); keep a short operating-mode signal in junior-developer (V4); compress on-call-engineer redirects selectively, not uniformly (V7); add an optional reverse pointer in devops-engineer → on-call-engineer (V5). Revised reclaim ~600 tokens (down from ~743).
- **Tranche B** (mid-size agents): reframed from "delete methodology lists" to "drop author attributions and redundant terms, keep unique routing anchors"; explicitly retain "event sourcing and CQRS" in data-engineer (V2). Revised reclaim ~270 tokens (down from ~318).
- **Tranche C** (skills): removed the misidentified work-items-to-issues↔code-review deletion (V6); added naming `plan-a-feature` in iterative-plan-review's boundary clause (V7's plan-cluster check); flagged that the architectural-analysis / code-review / investigate / research near-sibling cluster must be re-checked before cutting their example lists. Reclaim ~1,700 tokens (essentially unchanged).
- **Root cause E9 wording:** softened from "actively tells authors there is none" to "is silent on a ceiling and exempts the description from the 50-token Role Identity budget, giving no upper-bound signal" (V-finding on agent-domain-focus.md). Does not change the fix.
- **Net revised target:** ~2,570 tokens removable across all tranches (down from the original ~2,906), roughly evenly split agents/skills, with every routing trigger, every sibling name, and the specific anchors above preserved.

### Confidence Assessment

- **Confidence:** Medium-High. The direction (body-grade content sits in always-loaded frontmatter; relocate it and add the missing agent budget) is confirmed by direct file reads, an independently reproduced measurement (V10), and the issue's own `/context` evidence (V1). Confidence is not High only because routing quality cannot be measured mechanically — there is no test that proves a trimmed description still routes correctly (V11), so each tranche needs human review, and a few near-sibling clusters (V7, and the skill cluster flagged in Tranche C) still need a pre-cut pass.
- **Remaining Risks:**
  1. **No mechanical routing regression test (V11).** PR review is the only gate. Mitigation: land tranches incrementally; smallest-blast-radius first.
  2. **Unique-anchor terms could be missed (V2, V3).** Other single-owner vocabulary may exist beyond the two found. Mitigation: before deleting any term, grep all descriptions to confirm it is not the sole always-loaded anchor for a real request class.
  3. **Pre-existing one-way boundaries (V5).** devops↔on-call is broken today; others may be too. The trim should repair, not preserve, these — but that widens scope. Mitigation: treat reverse-pointer repairs as in-scope, small additions.
  4. **Doc mirror drift (V11).** Run `/han-update-documentation` in the same change set.
  5. **Headline percentages are approximate (V10).** Use the budgets as targets, not contractual numbers.

## Final Summary

- **Root Cause:** The large agent (and several skill) descriptions carry body-grade content — domain-vocabulary enumerations, methodology name-drops, internal process detail, artifact filenames, and over-elaborated sibling-redirect prose — in their always-loaded frontmatter, because the agent-building guidance never set a description-length budget and the routing-relevant signal is a small fraction of the text, most of it duplicated in the on-demand body (E1-E4, E9, E13, E14).
- **Fix:** Relocate the body-grade spans to the body and tighten redirect prose across three agent/skill tranches, preserving every routing trigger, sibling name, output contract, and the specific unique-anchor phrases validation surfaced; then add an agent description-length budget to the authoring guidance so the gain does not regress (Tranches A-D).
- **Why Correct:** The cut content is provably non-routing — the lean analyst agents route just as precisely without it (E5), the densest spans already exist in the bodies (E14), and the priority cutting ladder the suite already codifies (E10) maps directly onto the findings; the always-loaded cost is real and measured (E6, E7, and the issue's `/context` output, V1).
- **Validation Outcome:** Direction confirmed and baselines reproduced exactly (V10, V1), but validation corrected the savings down ~15-20%, preserved four load-bearing phrases first classed as body-grade (V2-V5), and removed one misidentified deletion target (V6); revised realistic reclaim is ~2,570 tokens.
- **Remaining Risks:** No mechanical routing test exists (V11), so each tranche needs human review and a pre-cut unique-anchor grep (risks 1-2 above); pre-existing one-way boundaries should be repaired in-scope (risk 3).

## Implementation Results

All four tranches were implemented and pushed on branch `investigate-context-footprint-51`, one commit each.

| Tranche | Scope | Reclaimed |
|---------|-------|-----------|
| A | on-call-engineer (2939→1591), junior-developer (2686→1963), project-manager (2591→1986 chars) | ~669 tokens |
| B | information-architect, data-engineer, user-experience-designer, system-architect trimmed; devops-engineer gained the on-call-engineer reverse pointer (V5); software-architect unchanged | ~86 tokens (net of the boundary repair) |
| C | 23 skill descriptions trimmed via the cutting ladder; 5 already-lean skills untouched | ~1,489 tokens |
| D | new `agent-description-length.md` budget doc; `agent-domain-focus.md`, rule index, and CLAUDE.md wired to it | guidance only |

**Measured total: ~8,975 chars / ~2,243 tokens removed from the always-loaded description footprint across all agents and skills (19% reduction), main vs. HEAD.** Slightly under the ~2,570 estimate because Tranche B's safe cuts were smaller than projected (the mid-size agents were more load-bearing, as validation predicted) and the devops→on-call boundary repair intentionally added tokens.

Preservations verified after implementation: "metastable failure" and "event sourcing and CQRS" retained as unique anchors; "hard boundary at the application source line" kept; all 16 junior-developer / 17 project-manager sibling names kept; work-items-to-issues→post-code-review-to-pr boundary kept; only the ADR↔runbook distant-sibling boundary removed; all 28 SKILL.md frontmatters parse and every folded skill-name reference survives YAML folding. No long-form doc was broken: the docs describe behavior and methodology (unchanged), and every term moved out of an agent description still lives in that agent's body.
