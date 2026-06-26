# Research: Should Han adopt a `/personas`-style skill like `zvoque/claude-personas`, given Han's large roster of agent definitions?

This report researches how the `zvoque/claude-personas` project works and what it does, whether persona-based prompting is supported by research evidence, and whether Han would benefit from a similar `/personas` skill given its 23 specialist agents. Evidence mode: **strict** (evidence required; every claim labeled).

## Summary

The `claude-personas` plugin lets you put Claude into a named "persona mode" (for example "contrarian" or "senior") and keeps that mode active across a whole session by re-injecting the persona's instructions on every turn through a Claude Code hook. Its goal is to stop Claude from drifting back to its default voice. The idea is reasonable and the underlying mechanism is a real, documented Claude Code capability, but the specific project is eleven days old, has six stars, and has no independent validation that it works as described.

On the bigger question — should Han build something like this — the answer is **no, not as a copy of this tool, and not as a new skill right now**. Han already does the thing that actually carries the value. Its 23 agents are already strong, durable personas (an "on-call engineer with 20+ years," a "junior developer with 3–5 years," a "seasoned project manager"), and skills like `code-review`, `architectural-analysis`, and `plan-implementation` already convene them as parallel expert panels and synthesize the result. The research helps point the way: on objective, factual tasks, assigning a persona/role label does **not** reliably improve accuracy and often hurts it, and the gains real multi-agent setups show come from task decomposition, scoped briefs, and output coverage — exactly what Han already gets from domain-scoped specialist dispatch, not from the persona label itself. Two honest caveats keep this at medium rather than high confidence: most of that evidence tests factual recall, while Han's agents do *judgment* work (review, analysis), where the evidence is thinner and a diverse panel is, if anything, weakly favorable; and Han genuinely lacks one thing the tool offers — a persistent persona for the top-level working session — which the evidence neither supports nor rules out, so the right call there is "wait for a real need" (YAGNI), not "proven worthless." The one other gap (convening an ad-hoc panel on an arbitrary artifact on demand) is small and overlaps existing skills; if pursued, it should be scoped as task-specific dispatch, not a "persona costume."

- **Confidence:** Medium

## Research Results

### What `claude-personas` is and how it works

`zvoque/claude-personas` is a Claude Code plugin that adds a `/personas` command. You activate a named persona (it ships "contrarian" and "senior"), and the plugin keeps Claude in that persona for the rest of the session (A1). The problem it targets is context drift: Claude tends to re-negotiate its tone and priorities each turn unless told otherwise (A1). That underlying need is real and independently attested — there is a closed feature request on the official Claude Code tracker asking for exactly this kind of switchable, persistent session profile (A7).

Mechanically, the plugin installs three JavaScript hook scripts plus persona files stored as Markdown at `~/.claude/personas/<name>.md` and a state file at `~/.claude/.personas-active` (A1). The core trick is per-turn re-injection: a `personas-tracker.js` hook on the `UserPromptSubmit` event reads the active persona and emits its instructions as `additionalContext` every turn, so Claude receives the persona fresh each exchange rather than relying on conversation memory (A1). This mechanism is sound — the `UserPromptSubmit` hook and its `additionalContext` return are documented Claude Code capabilities (A3) — but the specific implementation could not be independently inspected (direct file fetches 404'd) and is therefore single-source on the author's README (A1). A persona is just YAML frontmatter (`name`, `description`) plus a prose instruction body; a `/personas team` mode is described as convening multiple personas to debate and synthesize, though the synthesis mechanism is not detailed [single-source] (A1).

The project is very early: created 2026-06-15, six stars, one fork, zero open issues, and no third-party writeups or independent confirmation it works as claimed (A2). At least four other "Claude persona" projects exist with different designs — file-import via `@path` memory (A4), subprocess isolation per persona (A5), skill-bundling personas (A6), and large frameworks like SuperClaude with behavioral modes (A8) — so the pattern has prior art, but none builds on zvoque's work.

### What the evidence says about persona/role prompting

On **objective, factual tasks** the evidence is strong and consistent: **persona/role labels do not reliably improve accuracy, and frequently hurt it.** The largest controlled study (9 models, 162 personas, 2,410 questions) found personas in system prompts produce no consistent benefit, with most personas having no or negative impact (A10). A 2026 study (PRISM) found expert personas help generative/alignment tasks but damage accuracy-dependent tasks — MMLU dropped from 71.6% to 68.0% under a full expert persona (A12) — though note this result was produced with weights-level LoRA adaptation, **not** prompt-level system messages, so its transfer to prompt-only persona use (what Han and a `/personas` skill actually do) is not directly established [transfer-gap] (A12, A28). A "double-edged sword" study found role-playing degraded performance on 7 of 12 reasoning datasets (A11), and a controlled 4-condition study found aggregate effects vanishingly small (Cohen's d < 0.12), with role prompts trading clarity for stylistic markers of expertise [single-source, recent preprint] (A13). An oracle that picks the perfect persona per question helps, but no automated selection beats random (A10). These four studies converge directionally; they are not four methodologically-independent measurements, and most of them test factual recall rather than the judgment/review tasks Han's agents perform — a transfer gap the report does not paper over.

Where multi-agent setups genuinely help, the benefit traces to **decomposition and output coverage, not the role label.** Self-consistency — same model, same prompt, sampled multiple times and majority-voted — produces large, well-replicated reasoning gains (+17.9% GSM8K) with no personas at all (A15). Multi-agent debate showed early gains (A14) but did not hold up under broader evaluation: it underperformed plain chain-of-thought on MMLU by 7+ points in one systematic study (A18), "does not reliably outperform self-consistency and ensembling" (A17), and suffers documented failure modes — problem drift over rounds (A21) and the fact that models cannot reliably self-correct without external feedback (A20). The exception where diverse panels do help cleanly is **judgment/evaluation tasks** (safety review, adversarial defense), where adding diverse agents strengthens the verdict (A22 and the OpenReview "test-time scaling" finding). No published study directly ablates "role label only" vs. "task scoping only" on the same benchmark — that specific comparison is a gap — but every positive result is explainable by decomposition/coverage rather than the label (A11, A12, A14, A15).

### What Han already has

Han already implements the evidence-backed version of this. It ships 23 specialist agents, each a strong, durable persona embedded in the agent definition itself — "adversarial on-call engineer with 20+ years of being woken at 3am," "junior developer with three to five years," "seasoned, facilitative project manager," "adversarial security analyst" (A24). Crucially, these are not bare costume labels: each carries domain vocabulary, anti-patterns, protocols, and an output contract, and skills pass each agent a **domain-scoped brief** (only the files relevant to its domain) — i.e., task decomposition, the thing the evidence credits (A24, A25).

Han also already convenes expert panels. `code-review` and `architectural-analysis` select a roster by signal and dispatch several specialists **in parallel** — `code-review` can fan out up to ten — then reconcile findings (A25). `plan-implementation` runs a multi-specialist panel: parallel review rounds with domain-scoped briefs, mid-loop reframing via `junior-developer`, and a final synthesis by `project-manager` in its last step (A27). Note that `plan-implementation` deliberately does **not** run `project-manager` in round-robin facilitation mode per round — that facilitation capability exists on the `project-manager` agent itself (A26) and is structurally the same idea as zvoque's "team debate," but the skill reserves PM for the final deterministic synthesis. Han's maintainers have also already researched the adjacent personas-vs-specialists question (in the context of ADHD divergent-ideation frames) and reached an inconclusive verdict, explicitly distinguishing *personas* (identity cues that anchor sampling) from *domain specialists* (role-grounded reviewers with scoped briefs) and noting Han uses the latter — though that prior research did not directly evaluate a persistent top-level session persona (A28). The things Han does **not** have are a user-facing way to convene an ad-hoc named panel on an arbitrary artifact on demand, and a way to put the top-level Claude into a persistent persona for a working session (A24–A27). No evidence in this report tests whether that second capability would help an agentic orchestrator; it is an unfilled gap, not a proven-worthless one.

## Options to Consider

### O1: Port `zvoque/claude-personas` (persistent per-turn persona mode) into Han

- **What it is:** Add a Han skill that puts the top-level Claude into a named persona and re-injects it each turn via a `UserPromptSubmit` hook, mirroring the tool. This targets the *interactive top-level agent* — a capability genuinely orthogonal to Han's subagent dispatch, which Han has no equivalent for.
- **Trade-offs:** Two separate objections that should not be conflated. **(1) The reference implementation** is 11 days old, six stars, unvalidated, and uninspectable (A1, A2) — a sound reason not to *port this specific tool*. **(2) The concept** (a persistent top-level persona for a working session) is not ruled out by the cited evidence: A10–A13 test persona labels on factual-recall accuracy, not session consistency for an agentic orchestrator, so they do not speak to this use case. The honest status is no applicable evidence either way — which makes this a YAGNI deferral (wait for a felt need), not an evidence-based rejection. Adds per-turn token overhead and a hook dependency.
- **Rests on:** (A1, A2, A3); evidence against the concept itself is absent, not present.
- **Evidence status:** single-source on the tool (caveated); concept is unevidenced (defer on YAGNI)

### O2: Build a Han-native user-facing "expert panel on demand" skill

- **What it is:** A skill where the user names which specialists to convene on an arbitrary artifact (a file, a doc, an idea) and Han dispatches that ad-hoc panel and synthesizes — the one capability Han lacks today.
- **Trade-offs:** Fills a real gap (on-demand, user-chosen panel on any artifact). But it overlaps heavily with `code-review`, `architectural-analysis`, and `plan-implementation`, which already convene signal-selected panels (A25, A27); the marginal value is "user picks the roster on arbitrary input." If built, the evidence says the value is in the scoped briefs and synthesis, not in framing it as "personas" (A14, A15, A22). Real but modest YAGNI risk.
- **Rests on:** (A15, A22, A24, A25, A27)
- **Evidence status:** corroborated

### O3: Do nothing new — rely on Han's existing specialist dispatch and panels

- **What it is:** Treat the durable, evidence-backed value of "personas" as already delivered by Han's 23 scoped specialist agents and its parallel panel + synthesis skills.
- **Trade-offs:** Leaves the small ad-hoc-panel gap unfilled and offers no persistent top-level persona mode. But it keeps Han aligned with what the evidence actually rewards (decomposition, scoped briefs, panel-for-judgment, deterministic synthesis) and avoids adding an unproven, redundant mechanism (A24, A25, A26, A27, A28).
- **Rests on:** (A24, A25, A26, A27, A28, A15)
- **Evidence status:** corroborated

## Recommendation

- **Recommendation:** **O3 — do not adopt a `claude-personas`-style skill right now; Han already captures the decomposition value that real multi-agent setups deliver, through scoped specialist dispatch and panel synthesis.** Do not port zvoque's tool (O1) for two distinct reasons: the *implementation* is immature and uninspectable (A1, A2), and the *concept* it adds — a persistent top-level session persona — has no applicable evidence in either direction, so it is a YAGNI deferral until a real need surfaces, not something the evidence rules out. O2 (an on-demand, user-chosen panel on an arbitrary artifact) is the one capability Han lacks that the evidence weakly favors for judgment tasks (A22), but it overlaps existing panel skills (A25, A27) and, if pursued, should be scoped and synthesized as task-specific dispatch, never framed as a persona costume (A15, A22). Take O2 to `/plan-a-feature` only if the ad-hoc-panel gap is felt in practice.
- **Evidence basis:** The "no, not now" rests on a mix the report labels honestly. **Corroborated by codebase evidence:** Han already implements scoped specialist dispatch and parallel panels (A24, A25, A27), and its agents are durable scoped specialists, not bare persona labels (A24, A28). **Corroborated by web evidence:** persona/role labels do not improve factual-task accuracy (A10, A11; A12 with a LoRA-vs-prompt transfer caveat; A13 a single recent preprint), and the multi-agent gains that exist trace to decomposition/coverage — well-replicated for self-consistency (A15), limited and unreliable for debate (A17, A18, A20, A21). **Single-source:** the reference tool's mechanism (A1), corroborated as platform-plausible (A3); its immaturity from repo metadata (A2). **What the recommendation does _not_ rest on:** any claim that a persistent top-level persona is proven useless — that capability is unevidenced, and the recommendation defers it on YAGNI grounds rather than claiming evidence against it. No part rests on unevidenced reasoning presented as fact.

## Validation

An adversarial-validator pass attacked the evidence, the options framing, the recommendation, and the evidence-gathering integrity. The recommendation survived, but several claims were corrected and confidence was lowered from High to Medium.

### V1: A12 (PRISM) mechanism mischaracterized

- **Strategy:** Challenge the Evidence
- **Investigation:** Cross-checked A12 against Han's own prior research (A28), which cites the same paper and records that PRISM uses bootstrapped gated LoRA adapters (weights-level fine-tuning), not prompt-level personas, and explicitly caveats that transfer to prompt-only is not established.
- **Result:** Refuted (as originally stated). The draft claimed the MMLU drop happens "because the persona prefix activates instruction-following" — a prompt-level mechanism A12 does not test.
- **Impact:** A12 now carries an explicit LoRA-vs-prompt transfer caveat in Research Results and the source table. The "four independent studies" framing was relabeled as directional convergence.

### V2: Persona evidence tests factual recall; Han's agents do judgment tasks

- **Strategy:** Challenge the Assumptions
- **Investigation:** A10–A13 test MMLU/reasoning accuracy. Han's `code-review`, `architectural-analysis`, and `plan-implementation` are judgment/evaluation tasks, where the one relevant finding (A22, diverse judging panels help) is weakly *favorable* to diverse agents.
- **Result:** Partially Refuted. The transfer gap was acknowledged in the draft but treated as neutral when the only applicable evidence leans slightly the other way.
- **Impact:** Research Results, Summary, and Recommendation now state the evidence is decisive for factual tasks and thinner for Han's judgment tasks. Confidence lowered to Medium.

### V3: "4–7 specialists" understates the actual dispatch cap

- **Strategy:** Challenge the Evidence
- **Investigation:** `han-coding/skills/code-review/SKILL.md` defines 2 always-on plus 8 conditional specialists — a maximum of 10 — with no stated cap of 7.
- **Result:** Partially Refuted. The parallel-dispatch claim is accurate; the specific number was not in the code.
- **Impact:** A25 and Research Results now say "several … up to ten."

### V4: A27 line citation wrong; PM does not facilitate per round in plan-implementation

- **Strategy:** Challenge the Evidence
- **Investigation:** `han-planning/skills/plan-implementation/SKILL.md` puts PM synthesis in Step 8 (~line 242) and JD reframing in Step 6 (~line 195), outside the cited 72–134 range; line 139 explicitly states PM is NOT called per round in facilitation mode.
- **Result:** Refuted for the PM-facilitation implication. The draft conflated the PM agent's round-robin capability with how plan-implementation actually uses it.
- **Impact:** Research Results and A26/A27 corrected: plan-implementation reserves PM for final synthesis; round-robin facilitation is an agent capability the skill does not invoke per round.

### V5: A28 covers the adjacent ADHD-frames question, not this exact one

- **Strategy:** Challenge the Evidence
- **Investigation:** A28's research question is about ADHD divergent-ideation frames; it distinguishes personas from domain specialists (directly relevant) but never evaluates a persistent top-level session persona.
- **Result:** Partially Refuted.
- **Impact:** "Already researched this exact question" softened to "the adjacent personas-vs-specialists question," with a note that the top-level-persona dimension was not covered.

### V6 / V7: Dismissal of a persistent top-level persona was assertion dressed as evidence

- **Strategy:** Challenge the Recommendation
- **Investigation:** The draft rejected O1's concept partly via A10–A13, which do not test orchestrator-level session persistence, and partly via tool immaturity (A1, A2) — conflating implementation maturity with concept merit. The mechanism is platform-real (A3) and the user need is independently attested (A7).
- **Result:** Confirmed gap.
- **Impact:** O1 and the Recommendation were rewritten to separate the two objections cleanly: don't port *this tool* (immaturity), and defer the *concept* on YAGNI grounds (no applicable evidence) rather than claiming evidence rules it out.

### V8: A13 is a single recent preprint, not independent corroboration

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** A13 (a May 2026 preprint) is absent from A28's adjacent literature review, cannot be independently verified from this codebase, and its "corroborated by A10, A12" label reflects directional consistency, not methodological independence. The load-bearing anchors (A10, EMNLP 2024; A15, ICLR 2023; A14, ICML 2023) are well-established and verifiable.
- **Result:** Partially Refuted.
- **Impact:** A13 flagged single-source/recent-preprint in Research Results and the table; the evidence cluster relabeled as directional convergence. The recommendation does not depend on A13.

### Adjustments Made

The recommendation (O3) survived but was reframed: from "the evidence rules out persona prompting" to "Han already captures the decomposition value; the persona-label evidence is decisive only for factual tasks; the persistent-top-level-persona gap is real but unevidenced and deferred on YAGNI." The A12 mechanism caveat, the A13 single-source flag, the judgment-vs-factual transfer gap, and three codebase citation corrections (A25 count, A26/A27 PM role, A28 scope) were applied throughout. Confidence was lowered from High to Medium.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** (1) A12's LoRA-vs-prompt transfer is unresolved; (2) A13 is a single unverifiable recent preprint; (3) no study directly tests whether a top-level session persona helps agentic judgment tasks — that gap is deferred on YAGNI, not closed; (4) the persona-prompting evidence base is strongest for factual recall, which is not Han's agents' primary task. None of these flips the recommendation, but together they cap confidence at Medium.

## Sources

| ID | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
|---|---|---|---|---|---|---|
| A1 | zvoque/claude-personas repo (README) | https://github.com/zvoque/claude-personas | 2026-06-26 | web | The tool: `/personas` command, per-turn hook re-injection, persona schema, ships "contrarian"/"senior" | single source (caveated); mechanism corroborated by A3 |
| A2 | zvoque/claude-personas GitHub API metadata | https://api.github.com/repos/zvoque/claude-personas | 2026-06-26 | web | Created 2026-06-15, 6 stars, 1 fork, 0 open issues — very early, no engagement | corroborated by A1 |
| A3 | Claude Code hooks reference | https://code.claude.com/docs/en/hooks | 2026-06-26 | web | `UserPromptSubmit` fires each turn and can inject `additionalContext`; mechanism is real | corroborated by independent tutorials |
| A4 | jasonhanna/claude-personas | https://github.com/jasonhanna/claude-personas | 2026-06-26 | web | Alternative: `@path` memory-import personas, structured sections, no per-turn hook | single source (caveated) |
| A5 | takechanman1228/claude-persona | https://github.com/takechanman1228/claude-persona | 2026-06-26 | web | Alternative: subprocess-per-persona isolation for panel research | single source (caveated) |
| A6 | alirezarezvani/claude-skills Personas | https://github.com/alirezarezvani/claude-skills/wiki/Personas-Overview | 2026-06-26 | web | Alternative: personas bundle skills + subcommands; cross-platform | single source (caveated) |
| A7 | claude-code issue #53458 (Persona Profiles request) | https://github.com/anthropics/claude-code/issues/53458 | 2026-06-26 | web | Filed request for switchable persistent session profiles — confirms the user need | single source (caveated) |
| A8 | SuperClaude_Framework | https://github.com/SuperClaude-Org/SuperClaude_Framework | 2026-06-26 | web | Large comparable: 20 agents, behavioral modes via command selection | single source (caveated) |
| A10 | "A Helpful Assistant Is Not Really Helpful" (EMNLP 2024) | https://arxiv.org/abs/2311.10054 | 2026-06-26 | web | 9 models, 162 personas: personas give no consistent accuracy benefit; most no/negative | corroborated by A11, A12, A13 |
| A11 | "Persona is a Double-Edged Sword" | https://arxiv.org/abs/2408.08631 | 2026-06-26 | web | Role-playing degraded 7/12 reasoning datasets; ensemble of framings helps, not the label | corroborated by A10, A12 |
| A12 | "Expert Personas… Damage Accuracy" (PRISM, 2026) | https://arxiv.org/abs/2603.18507 | 2026-06-26 | web | Personas help alignment tasks, hurt accuracy (MMLU 71.6%→68.0%) — but via **LoRA fine-tuning, not prompts**; prompt-only transfer not established | directionally consistent with A10; transfer-gap caveat per A28 |
| A13 | "When Does Persona Prompting Actually Help?" | https://arxiv.org/html/2605.29420v1 | 2026-06-26 | web | Aggregate effects tiny (d<0.12); role trades clarity for expertise markers | single source, recent preprint; directionally consistent with A10 |
| A14 | Multiagent Debate (Du et al., ICML 2023) | https://arxiv.org/abs/2305.14325 | 2026-06-26 | web | Debate improved arithmetic/GSM8K; agents shared prompts, no personas | contradicted in scope by A17, A18 |
| A15 | Self-Consistency (Wang et al., ICLR 2023) | https://arxiv.org/abs/2203.11171 | 2026-06-26 | web | Sample+majority-vote, same prompt, no personas: +17.9% GSM8K — decomposition/coverage wins | corroborated by A16 |
| A16 | Mixture-of-Agents (ICLR 2025) | https://arxiv.org/abs/2406.04692 | 2026-06-26 | web | Layered multi-model aggregation beats GPT-4o on AlpacaEval; cost high; judge-scored | single source (caveated; judge bias per A22) |
| A17 | "Should We Be Going MAD?" (ICML 2024) | https://proceedings.mlr.press/v235/smit24a.html | 2026-06-26 | web | MAD does not reliably beat self-consistency/ensembling; config-sensitive | corroborated by A18 |
| A18 | MAD Performance/Scaling (ICLR Blogpost 2025) | https://iclr-blogposts.github.io/2025/blog/mad/ | 2026-06-26 | web | MAD underperformed CoT on MMLU (74.7% vs 82.1%); more agents ≠ better | corroborated by A17 |
| A20 | "LLMs Cannot Self-Correct Reasoning Yet" (ICLR 2024) | https://arxiv.org/abs/2310.01798 | 2026-06-26 | web | Self-critique without external feedback degrades accuracy | corroborated by A18 |
| A21 | "Stay Focused: Problem Drift in MAD" (EACL 2026) | https://arxiv.org/abs/2502.19559 | 2026-06-26 | web | Debates drift off-problem over rounds (35% lack of progress) | single source (caveated) |
| A22 | "Can You Trust LLM Judgments?" | https://arxiv.org/abs/2412.12509 | 2026-06-26 | web | LLM judges have position/length/self bias; diverse panels mitigate — panels help judgment | corroborated directionally |
| A23 | "More Agents Is All You Need" | https://arxiv.org/abs/2402.05120 | 2026-06-26 | web | Sampling+voting scales with agent count but saturates; coverage, not capability | corroborated by A15 |
| A24 | Han agent roster + definitions | han-core/agents/*.md (23 files) | n/a | codebase | 23 specialist agents, each a durable persona with domain vocab, anti-patterns, scoped output | corroborated by A28 |
| A25 | Parallel specialist dispatch | han-coding/skills/code-review/SKILL.md:125–243 (2 always-on + 8 conditional = up to 10); architectural-analysis/SKILL.md:62–107 | n/a | codebase | Skills select roster by signal, dispatch several specialists (up to ten) in parallel with domain-scoped briefs | corroborated by A27 |
| A26 | Project-manager facilitation capability | han-core/agents/project-manager.md | n/a | codebase | PM agent *has* round-robin facilitation + synthesis modes; whether a skill uses facilitation per round is the skill's choice | corroborated by A27 |
| A27 | plan-implementation panel | han-planning/skills/plan-implementation/SKILL.md (Step 4 ~72–134 parallel rounds; Step 6 ~195 JD reframing; Step 8 ~242 PM synthesis; line 139: PM NOT facilitated per round) | n/a | codebase | Multi-specialist panel: parallel review rounds, JD reframing, PM reserved for final synthesis | corroborated by A25 |
| A28 | Han prior persona research | docs/research/adhd-application-to-han.with-disambiguation.md | n/a | codebase | ADHD-frames research; distinguishes personas vs. domain specialists (relevant); did NOT evaluate top-level session persona; verdict inconclusive | directionally consistent with A10, A12 |
| A29 | Skill authoring conventions | CONTRIBUTING.md:46–56; han-plugin-builder/skills/guidance/references/ | n/a | codebase | New skills: SKILL.md structure, scoped Bash perms, mandatory long-form doc | n/a (procedural) |

### A1: zvoque/claude-personas (README) — recommendation-bearing

- **Link / location:** https://github.com/zvoque/claude-personas
- **Retrieved:** 2026-06-26
- **Trust class:** web (the project's own documentation/marketing)
- **Summary:** Describes the `/personas` command set (solo, parallel, team debate, new), the per-turn `UserPromptSubmit` hook re-injection (`personas-tracker.js`), the persona file schema (YAML `name`/`description` + prose body) at `~/.claude/personas/<name>.md`, the `~/.claude/.personas-active` state file, and the two shipped archetypes ("contrarian", "senior"). All benefit claims are the author's own; the implementation files could not be independently inspected.
- **Evidence status:** single source (caveated); the hook mechanism is corroborated by A3.

### A10: "A Helpful Assistant Is Not Really Helpful" (EMNLP 2024) — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2311.10054
- **Retrieved:** 2026-06-26
- **Trust class:** web (peer-reviewed, ACL Findings)
- **Summary:** Across 9 instruction-tuned models, 162 personas, and 2,410 MMLU questions, adding a persona to the system prompt did not improve accuracy versus no persona; most personas had no or negative impact, and no automated method for picking the best persona beat random selection. The single largest, most direct test of the "you are an expert X" pattern.
- **Evidence status:** corroborated by A11, A12, A13.

### A15: Self-Consistency (Wang et al., ICLR 2023) — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2203.11171
- **Retrieved:** 2026-06-26
- **Trust class:** web (peer-reviewed, ICLR 2023)
- **Summary:** Sampling multiple reasoning paths from one model with one prompt and majority-voting yields large, widely-replicated reasoning gains (+17.9% GSM8K) with no personas and no debate. Anchors the conclusion that the benefit of "multiple agents" comes from output-space coverage and decomposition rather than from role labels.
- **Evidence status:** corroborated by A16, A23.

### A24: Han agent roster and definitions — recommendation-bearing

- **Link / location:** han-core/agents/*.md (23 files)
- **Retrieved:** n/a (codebase)
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Han ships 23 specialist agents, each a strong durable persona established in the agent definition itself ("on-call engineer with 20+ years," "junior developer with 3–5 years," "seasoned project manager," "adversarial security analyst"), each carrying domain vocabulary, anti-patterns, protocols, and an output contract. Skills hand each agent a domain-scoped brief, so Han already performs the task-decomposition the evidence credits — distinct from a bare persona label.
- **Evidence status:** corroborated by A28 (Han's prior persona research) and consistent with A15's decomposition finding.

### A25: Parallel specialist dispatch in Han skills — recommendation-bearing

- **Link / location:** han-coding/skills/code-review/SKILL.md:125–243; han-coding/skills/architectural-analysis/SKILL.md:62–107
- **Retrieved:** n/a (codebase)
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** `code-review` and `architectural-analysis` classify size, detect domain signals, select a roster, and dispatch several specialists in parallel (code-review defines 2 always-on plus 8 conditional agents, up to ten) with domain-scoped file lists, then reconcile findings. This is already an "expert panel on demand" scoped to a task — the durable form of what `/personas team` gestures at.
- **Evidence status:** corroborated by A27 (plan-implementation panel) and A26 (PM facilitation).
