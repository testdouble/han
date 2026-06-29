# Research: A Standardized Method for Human-Readable Skill Output

How should Han formalize a reusable, cross-skill standard for producing clear, understandable, human-facing output (for skills such as `/investigate`, `/research`, `/update-pr-description`, and other reader-facing skills), in the same way it already uses `sizing` and `yagni`?

**Evidence mode:** strict (default; the operator did not opt into exploratory mode).

## Summary

The clearest move is to build one short, shared "readability" rule the same way Han already ships `yagni-rule.md` and `evidence-rule.md`: a tight, prioritized set of rules, each stated as a one-line rule plus the reason it helps a reader plus a do/don't example, paired with a plain-language `docs/` write-up. The rules themselves are not a matter of taste. Decades of plain-language practice, government standards, the major tech style guides, and web-reading research all converge on the same short list: say the main point first, one idea per paragraph, short sentences (around 15 to 20 words on average), active voice, common words over jargon, and reveal detail in layers. That convergence is the strongest-corroborated finding in this research.

A reference alone does not change what a skill produces, though. Two things have to happen for it to take effect, and both match how Han already works. First, the structural rules get baked into each skill's output template, the way the research and stakeholder-summary templates already lead with a plain-language summary. Second, each reader-facing skill applies the rule while it writes and runs a short plain-language self-check before it finishes, the way `stakeholder-summary` already runs its Pass A/B/C check. A separate "rewrite this to be readable" pass is well-evidenced and worth adding where a skill already has a synthesis or editor step.

Two cautions carry real evidence behind them. Do not turn the standard into a long checklist of rules crammed into one instruction: model compliance drops sharply as the number of simultaneous instructions rises, so a tight prioritized set beats an exhaustive one, and the rule is best used by handing its structural rules to templates, its examples to the model as samples, and its checks to a short after-the-fact review rather than firing all of them at once. And do not make a readability score (like Flesch) the target; those formulas are weak proxies for real understanding and reward gaming. Use audience framing ("write this for a smart non-expert") as the always-on instruction instead, and keep the score, if used at all, as a rough diagnostic.

One honest correction to the premise: Han uses `yagni` and `sizing` differently. `yagni` (and `evidence`) ship as a shared rule file that skills load and apply; `sizing` is a shared *concept* re-implemented inside each skill, with only a narrative write-up in `docs/`, no shared rule file. The fitting model for this standard is the `yagni`/`evidence` rule-file model, not sizing. The good news from checking the code is that those rule files are not just author-time guidance: skills and agents are directed to load and apply them at runtime, so a readability rule would get real grip. The remaining uncertainty is about how much it improves output and how much wiring each skill needs, not about whether it is the right shape.

- **Confidence:** Medium

## Research Results

### The content of "clear writing" is settled and convergent

Four independent traditions describe the same rules. The U.S. Plain Writing Act and its Federal Plain Language Guidelines, the National Archives' ten principles, and the international plain-language standard ISO 24495-1 all define clear writing the same way: a reader can find what they need, understand it, and use it (A1, A2). The two big technical-writing style guides, Microsoft's and Google's, arrive at the same rules independently of the government work and of each other: active voice, second person, front-loaded information, short sentences, sentence-case headings (A3, A4). Web-reading research from Nielsen Norman Group supplies the behavioral reason these rules work: people scan before they read, fixating on the first lines and on headings, so anything buried in the middle of a paragraph or the bottom of a document is missed (A11, A12, A13). A 1997 usability study measured the payoff: concise writing raised usability 58%, scannable formatting 47%, plain objective style 27%, and all three together 124% (A11).

The rules that come out of this convergence fall into three layers:

- **Structural / ordering** — state the main point first (BLUF / inverted pyramid), one idea per paragraph with the first sentence carrying the weight, descriptive front-loaded headings, conditions before instructions, numbered lists for steps and bullets for non-sequential items, reveal complexity progressively, organize around what the reader needs to do (A1, A4, A11, A14, A15, A16, A17). These are the most corroborated rules in the whole body of evidence and they are domain-agnostic.
- **Sentence-level** — average 15 to 20 words per sentence with few sentences past 25 to 30; active voice as the default; keep subject and verb close; one complete thought per sentence (A1, A3, A5, A6, A18, A20).
- **Word-level** — prefer the common word over the technical synonym (define a term on first use when it cannot be replaced), avoid stacked modifiers, address the reader as "you" (A1, A3, A4, A5).

Two conflicts in the evidence are worth naming rather than hiding. Active-versus-passive is not absolute: passive voice is correct when the actor is irrelevant or the object needs emphasis, and at least one study found no comprehension difference from grammatical voice in scientific prose (A19). The resolution both sides actually agree on is "active by default, passive as a deliberate tool." And the ISO 24495-1 principle names cannot be stated reliably, because the standard text is paywalled and two secondary summaries disagree on what the four principles are even called (A2) — so the standard should not lean on that specific framing.

### Readability formulas are a weak target, useful only as a rough check

Flesch Reading Ease, Flesch-Kincaid Grade Level, Gunning Fog, and SMOG are all simple arithmetic over sentence length and syllable counts (A7, A8, A9). They are widely deployed and machine-checkable, but they are documented across UX research, academic literature, and the formula authors' own notes as poor proxies for actual comprehension (A10). The same text scores wildly differently across formulas; grade levels are meaningless for adults; the formulas cannot tell whether a reader knows a word; and shortening sentences to game the score can strip the connective tissue that makes prose understandable (A10). Using a formula score as an optimization target for an automated producer is therefore an anti-pattern. As a one-glance sanity check with the caveats stated, it is defensible; as the spine of a standard, it is not.

### How to steer an LLM toward plain output — and the trap to avoid

Audience or grade-level targeting is the single most-evidenced instruction. Three independent clinical studies show that a prompt as plain as "explain this in simpler terms" or "write this at a sixth-grade reading level" reliably drops Flesch-Kincaid grade by two to five levels across Claude, GPT-4, Gemini, and others, and in expert review of 143 rewritten documents it did not cost accuracy (A21). Few-shot before/after rewrites are the next most reliable lever: showing the model a jargon-heavy passage next to its plain rewrite closes most of the gap between vague instruction and demonstrated style, more reliably than any abstract description (A25). This is the same finding Anthropic's own prompting guidance states — examples are "one of the most reliable ways to steer Claude's output format, tone, and structure" (A32).

The central trap is the "curse of instructions": as the number of simultaneous instructions in one prompt rises, the probability that all are followed decays roughly exponentially — measured drops from about 85-90% at one instruction to 15-44% when many are stacked (A24). A readability standard written as a fifteen-item checklist and pasted into one prompt will mostly be ignored. Two mitigations are evidenced: keep the rule tight and prioritized, and split work across passes so each pass carries few constraints. A dedicated "now rewrite this to be readable, keep every fact" second pass is exactly that split, and the Self-Refine and DeCRIM results show iterative generate-then-critique improving output by meaningful margins (A22, A23). The cost is an extra call and a real over-simplification risk: pushing readability too hard can drop information, more so on dense technical content (A29).

Three more cautions carry evidence. Do not use hard numeric word caps — Anthropic's own April 2026 postmortem found a 25/100-word cap caused a measured 3% quality regression and was reverted, and separate work shows models overshoot numeric length targets anyway (A39, A28). Do not trust an off-the-shelf LLM to judge whether its own prose is clear — general models barely beat random on writing-quality assessment and carry a sycophancy and verbosity bias, so a self-check needs concrete, behaviorally-anchored yes/no criteria, not "is this clear?" (A30). And when the content being rewritten contains imperative or conditional language (common in technical material), delimit it clearly, because models can mistake input prose for instructions (A31).

### Claude and Claude Code give first-party levers for this

Anthropic's prompting guidance is unusually concrete here: it publishes a ready-made system-prompt block that tells Claude to write reports in flowing prose rather than fragmented bullets, a no-preamble instruction that replaces the old prefill trick, a recommendation to state the *reason* for a format rule so the model generalizes it, and the role/persona lever for setting audience (A32). Claude's constitution independently lists over-hedging, unnecessary caveats, and wishy-washy answers as behaviors to avoid (A37), and an analysis of Claude's own system prompt shows it already suppresses reflexive lists and opening flattery (A38). At the Claude Code layer, output styles and CLAUDE.md/skill instructions are the documented places to put persistent tone-and-format rules (A33, A36) — but these are levers a skill author wires up, not something the standard gets for free.

### Han already has most of the substrate — and one real gap

Han is not starting from nothing. It already ships the exact reference mechanism this standard would use: `yagni-rule.md` and `evidence-rule.md` live in `han-core/references/`, are cited from skill definitions by relative link, are vendored into `han-planning/references/` and `han-coding/references/` by manual file copy, and are paired with operator-facing extracts in `docs/` (`docs/yagni.md`, `docs/evidence.md`) (A53, A54). One correction to the operator's framing surfaced in validation: `sizing` is *not* one of these shared rule files. Sizing is a concept re-implemented inside each skill's `SKILL.md` with only a narrative `docs/sizing.md`; there is no `sizing-rule.md` (A54). So the proven, fitting precedent is `yagni-rule.md` / `evidence-rule.md`, not sizing — that is the model this standard should copy.

A second correction matters more, because it strengthens the case. Earlier exploration suggested references were merely author-time guidance. Direct inspection shows otherwise: `docs/yagni.md` states plainly that "every YAGNI-aware skill and agent loads that file at runtime," and skill steps and agent briefs direct the executor to read and apply the referenced rule by relative link as it runs (A57). A reference is therefore applied at runtime, not just pre-baked by an author — so a `readability-rule.md` would have real runtime grip. What loading does *not* guarantee is full compliance once the rule competes with every other instruction in context, which is the curse-of-instructions risk handled below.

Han also already has a voice profile, `docs/writing-voice.md`, with strong, specific rules (no em-dash, no "just," no "leverage," a named AI-slop blocklist) — but that profile governs operator *documentation* and is not loaded at runtime by any skill or agent (A52). And several reader-facing skills already carry plain-language guidance and a progressive-disclosure output template, though less uniformly than first assumed: research leads with a jargon-free summary, stakeholder-summary mandates "plain language only" and runs a three-pass self-check, code-overview demands "minimal technical detail" and is the one skill that already dispatches `information-architect` and `junior-developer` specifically for a readability pass (A55, A57). The convergence is real but partial. `investigate` is the weakest example: its summary is a five-field structured technical block (root cause, fix, why correct, validation outcome, remaining risks), not a plain one-line summary, and it cites no readability principle and dispatches no readability reviewer (A55, A56). `update-pr-description` does front-load a one-line TL;DR but dispatches `junior-developer` as a *writer*, not a readability reviewer.

The gap is that all of this is *distributed and re-stated per skill* rather than centralized, and unevenly applied. Each skill phrases its own plain-language rule in its own words, and some (investigate) barely do so at all — which is the kind of drift a shared `yagni`/`evidence`-style reference exists to prevent (A56). Worth stating honestly: the report treats this drift as a risk a shared reference would reduce, not as a measured defect — no one has measured that current per-skill output is worse than a shared reference would produce (see Validation V8). The editor-agent readability pass exists today in exactly one reader-facing skill (code-overview), so adopting it elsewhere is new wiring, not the extension of a settled pattern (A57).

## Options to Consider

### O1: A shared `readability-rule.md` reference (the yagni/evidence model)

- **What it is:** One short cross-skill reference in `han-core/references/`, structured like the existing rules: a prioritized set of ~8-12 rules across the structural / sentence / word layers, each as *rule + why-it-helps-the-reader + do/don't example + a testable check*, plus a `docs/readability.md` operator extract, vendored into `han-planning`/`han-coding` like the other rules. The rule is designed so it is never fired as one big instruction block — that would reproduce the curse of instructions (A24) it is meant to dodge. Instead each part has a distinct home: the structural rules are baked into each skill's output template (so they shape structure without being re-read every run), the do/don't pairs are handed to the model as few-shot examples (the most reliable style lever, A25, A32), and the testable checks run as a short separate self-check or editor pass *after* drafting (the decomposition that beats stacking, A23). A skill applies one layer at a time rather than all of it at once.
- **Trade-offs:** Authoring cost is real — every rule needs a good do/don't pair. The rule loads at runtime (A57), which gives it grip, but loading does not guarantee compliance when it competes with a skill's other instructions, so the template/few-shot/self-check split above is load-bearing, not optional. Vendoring is manual file duplication (A53).
- **Rests on:** (A1, A4, A11, A14, A15, A16, A43, A45) for content; (A24, A25, A32) for shape; (A52, A53, A54, A56, A57) for fit to Han.
- **Evidence status:** corroborated

### O2: A mandatory two-pass "readability rewrite" stage in each reader-facing skill

- **What it is:** Each skill generates its content normally, then runs a dedicated pass (inline or a sub-agent) that rewrites the draft for readability against the rule, preserving every fact.
- **Trade-offs:** Strongest process evidence of any option (A22, A23) and it dodges the curse of instructions by reducing per-pass constraints — but it adds a call's cost and latency, risks over-simplification fidelity loss on dense content (A29), and presupposes O1 because the pass needs a rule to rewrite against.
- **Rests on:** (A21, A22, A23) for the two-pass payoff; (A24) for why it helps; (A29) for the risk.
- **Evidence status:** corroborated

### O3: Distribute readability into per-skill templates plus a standardized per-skill self-check (no central reference)

- **What it is:** Keep doing what Han partly does today — push the rules into each skill's output template and add a *standardized* plain-language self-check to each reader-facing skill (generalize stakeholder-summary's Pass A/B/C into one reusable check-list), with no shared rule file.
- **Trade-offs:** Lowest new-artifact cost, and the templates plus stakeholder-summary's self-check show the pattern already works without a shared reference (A55, A56). This is the genuine alternative to O1, and the more YAGNI-minimal one. Its weakness is real but un-measured: each skill re-states the rules in its own words (investigate barely states them at all, A56), there is no single source of truth to evolve when the rules change, and it omits the shared reference the operator explicitly asked for. The honest caveat, raised in validation, is that no one has shown current per-skill output is actually *worse* than a shared reference would produce — the drift O1 prevents is a plausible risk, not a measured defect (V8).
- **Rests on:** (A55, A56) for what exists and already works; (A47) for the drift/duplication failure mode as a risk.
- **Evidence status:** corroborated (the un-measured drift premise is the open question between O3 and O1)

### O4: A dedicated readability editor sub-agent with a behaviorally-anchored rubric

- **What it is:** Extend Han's existing editor-agent pattern (`information-architect`, `junior-developer`) with an agent that audits and rewrites reader-facing output against a 3-6 dimension rubric with yes/no behavioral anchors.
- **Trade-offs:** Agent-as-editor is already how Han runs readability passes (A57), and a tight rubric gives targeted feedback (A50). But ungrounded LLM judging is unreliable and sycophantic — the rubric must use concrete anchors and ideally calibration, not "is this clear?" (A30). Adds dispatch cost and still needs O1's content.
- **Rests on:** (A50, A57) for the pattern; (A30) for the guardrail.
- **Evidence status:** corroborated

### O5: Automated prose linting (Vale) in CI over produced output

- **What it is:** Encode rules as Vale YAML and gate output in CI, the way Datadog, GitLab, and others lint docs.
- **Trade-offs:** The one mechanism proven to change output at scale by hard gating (A42, A49) — but it decisively mismatches the target: Han skill output is ephemeral conversational or scratch text, not committed files in a pipeline, so there is no CI surface to lint (A55, A57). It also catches only surface issues, never whether the answer serves the reader (A42).
- **Rests on:** (A42, A49) for the mechanism; (A55, A57) for why the fit fails.
- **Evidence status:** corroborated (mechanism), but fit fails for this use

### O6: Readability-formula targets (Flesch / grade level) as the standard's metric

- **What it is:** Make a Flesch Reading Ease band (60-70) or grade level (8-9) the measurable target of the standard.
- **Trade-offs:** Machine-checkable and familiar, but documented as a poor comprehension proxy that rewards gaming and degrades cohesion when optimized (A10), and LLMs overshoot numeric targets anyway (A28). Defensible only as an optional one-glance diagnostic, never the spine.
- **Rests on:** (A7, A8, A9) for the formulas; (A10, A28) against using them as a target.
- **Evidence status:** corroborated against (as a primary mechanism)

### O7: Controlled language (ASD-STE100 / Simplified Technical English)

- **What it is:** Constrain output to ~900 approved words with one meaning each and hard sentence-length caps.
- **Trade-offs:** Removes ambiguity at the source and is tractable to check (A48), but carries a very high adoption cost, produces stilted output unfit for analytical or conversational deliverables, and cannot be auto-applied to existing prose (A48, A47).
- **Rests on:** (A48) for the model; (A47) for the cost/fit objection.
- **Evidence status:** corroborated against

## Recommendation

- **Recommendation:** Build the standard as **O1 — a shared `readability-rule.md` reference on the `yagni`/`evidence` rule-file model — as the backbone, with enforcement layered through the mechanisms Han already uses.** This is the artifact the operator explicitly asked for (a shared reference for reader-facing skills), which is itself acceptable YAGNI evidence (a user-described need), and its content is the best-corroborated part of this research. One framing correction: the fitting precedent is `yagni-rule.md` / `evidence-rule.md`, not sizing, which is not a shared rule file (A54). O1 does not stand alone. Because the rule loads at runtime but loading does not guarantee compliance once it competes with other instructions (A57, A24), the rule only reliably changes output if each reader-facing skill (a) embeds the rule's *structural* rules into its output template (the O3 carrier, which several skills already have), (b) names the rule in its producing-step instructions with the do/don't pairs serving as few-shot exemplars (A25, A32), and (c) runs a plain-language self-check or an editor-agent pass against it before finishing (O2 where a skill already synthesizes; O4 — today only code-overview already wires this, so elsewhere it is new work). Wrap that with an always-on audience frame ("write this for a smart non-expert who has not seen the code"), the most practical single instruction (A21, A32). Keep the rule short and prioritized, and apply it one layer at a time rather than as one block, to beat the curse of instructions (A24, A23). Prefer qualitative length guidance over hard word-count caps (A28). Demote readability formulas to an optional diagnostic with caveats (O6, A10). Rule out Vale/CI (O5) on fit and reject controlled language (O7) on cost. Reuse `docs/writing-voice.md`'s vocabulary blocklist rather than duplicating it (A52).
- **The honest alternative:** O3 (distribute the rules into templates plus a *standardized* per-skill self-check, no shared file) is the more YAGNI-minimal choice and is not strictly beaten by evidence — the drift O1 prevents is a plausible risk, not a measured one (V8). O1 is recommended over it for one decisive reason: the operator asked for a shared, evolvable reference to cite across skills, and a single source of truth is materially easier to keep current than the same rules re-stated in every skill. If the operator would rather not carry a new reference file, O3-strengthened captures most of the benefit at lower cost, and O1 can be deferred until per-skill drift is actually observed.
- **Evidence basis:** The *content* of the rule rests on corroborated, independently-converging evidence across four traditions: structural rules (A1, A4, A11, A14, A15, A16, A43, A45), sentence-level rules (A1, A3, A5, A6), word-level rules (A1, A3, A4). This is the strongest part of the recommendation. The *shaping* decisions rest on corroborated evidence: the curse of instructions (A24, with A23 corroborating the decomposition fix), few-shot exemplars beating abstract rules (A25, A32), and the unreliability of ungrounded LLM self-judging (A30). Two shaping claims are deliberately carried weaker than before: audience-targeting (A21) is strongly evidenced but only *within the healthcare-simplification domain*, so for technical skill output it is carried as directionally sound (and backed by Anthropic's own guidance, A32) with the accuracy-tension caveat (A29) governing dense reports; and the "avoid hard word caps" point now rests on A28 (models overshoot numeric targets) rather than on A39, whose specific "3% regression" figure is single-source, first-party, and not independently verifiable, so it is dropped from the basis. The *fit to Han* — a `*-rule.md` reference carried by templates and self-checks rather than a CI lint or a new agent alone — rests on codebase evidence (A52, A53, A54, A55, A56, A57), the trusted current-state anchor; validation corrected this evidence in Han's favor (the rule loads at runtime) and against it (convergence across skills is partial, editor-agent wiring exists in only one skill). Two source conflicts are handled explicitly: active-vs-passive (A19) resolves to "active by default, passive as a named exception," and the ISO 24495-1 principle names (A2) are not relied on. The residual risk is not that references are unenforced — they load and apply at runtime — but that loading does not guarantee compliance, the per-skill wiring cost is higher than a single file suggests (especially for investigate), and the benefit over O3 is reasoned, not measured.

## Validation

The adversarial-validator read the report and verified every codebase claim against what is on disk. It produced eight findings; the recommendation survives, but in a more qualified form, and several evidence claims were corrected.

### V1: References are applied at runtime, not "advisory"

- **Strategy:** Challenge the Evidence
- **Investigation:** Read `docs/yagni.md` line 13 ("Every YAGNI-aware skill and agent loads that file at runtime"), `han-core/skills/research/SKILL.md` Step 6, and `han-core/agents/junior-developer.md` — all direct the executor to read and apply the referenced rule file at runtime via relative link.
- **Result:** Refuted (the "advisory" framing).
- **Impact:** Strengthens O1: a `readability-rule.md` gets real runtime grip, not just author-time encoding. The report's original "softest point" was wrong and has been rewritten; the residual risk is now "loaded but compliance not guaranteed," not "might never be wired in."

### V2: The "sizing" analogy is broken — no `sizing-rule.md` exists

- **Strategy:** Challenge the Evidence
- **Investigation:** `han-core/references/` contains only `evidence-rule.md` and `yagni-rule.md`; a repo-wide search for `sizing-rule.md` returns nothing. Sizing lives inside each SKILL.md plus a narrative `docs/sizing.md`. `docs/evidence.md` exists as a third extract.
- **Result:** Refuted (sizing as part of the proven `*-rule.md` mechanism).
- **Impact:** The operator's "like sizing and yagni" premise is half false. Corrected throughout: the fitting precedent is `yagni`/`evidence`, not sizing.

### V3: `investigate` does not front-load a plain one-line summary

- **Strategy:** Challenge the Evidence
- **Investigation:** `investigate`'s template Summary is a five-field structured technical block (root cause, fix, why correct, validation outcome, remaining risks); the skill cites no readability principle and dispatches no readability reviewer.
- **Result:** Refuted for investigate.
- **Impact:** Cross-skill convergence (A55, A56) was overstated. Corrected: investigate is the weakest example and would need the most new wiring.

### V4: The editor-agent readability pass exists in only one reader-facing skill

- **Strategy:** Challenge the Evidence
- **Investigation:** Only `code-overview` dispatches `information-architect` + `junior-developer` for a readability pass. Other skills use `junior-developer` in generalist or writer mode.
- **Result:** Partially refuted ("some skills... the natural hook").
- **Impact:** O4 is an existing pattern only for code-overview; elsewhere it is new work. Implementation cost corrected upward.

### V5: Internal contradiction — an 8–12-rule file vs. the curse-of-instructions warning

- **Strategy:** Challenge the Recommendation
- **Investigation:** O1's ~12 rules × 4 components is ~48 instruction elements; if loaded as one block alongside a skill's other instructions, it reproduces the A24 failure it cites.
- **Result:** Partially refuted (tension identified but originally unresolved).
- **Impact:** Resolved in O1 and the Recommendation: structural rules go to templates, do/don't pairs become few-shot examples, testable checks run as a separate after-the-fact pass, applied one layer at a time (the A23 decomposition).

### V6: A21's three studies are all healthcare-domain — corroboration within a domain, not across

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** All three audience-targeting studies are biomedical patient-education papers; Han produces accuracy-sensitive technical reports, where A29 documents fidelity loss under heavy simplification.
- **Result:** Partially refuted ("single most-evidenced lever").
- **Impact:** Audience-framing downgraded to directionally sound for technical output, backed by A32, with A29 as the governing constraint. The "no accuracy loss" finding is not transferred to investigation reports.

### V7: A39 (Anthropic April-2026 postmortem) is single-source, first-party, unverifiable

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The postmortem post-dates the assistant's knowledge cutoff, is a vendor source describing its own decision, and A28 corroborates only the "overshoot" finding, not "a hard cap caused a 3% regression."
- **Result:** Confirmed (single-source).
- **Impact:** A39's specific figure dropped from the evidence basis; "avoid hard word caps" now rests on A28 alone. Recommendation unchanged.

### V8: O3 is dismissed on asserted, not measured, drift

- **Strategy:** Challenge the Options Framing
- **Investigation:** stakeholder-summary, code-overview, and research already show good per-skill plain-language discipline without a shared reference; the report asserts drift is a defect but never measures it.
- **Result:** Confirmed (the O1-over-O3 case is reasoned, not demonstrated).
- **Impact:** O3-strengthened is now presented as the genuine, more-YAGNI-minimal alternative. O1 is still recommended, but on the operator's explicit request for a single evolvable source of truth, not on a proven quality gap — and O1 may be deferred until drift is observed.

### Adjustments Made

- Summary confidence lowered from High to Medium; the sizing-premise correction and the runtime-loading correction added.
- The "Han already has the substrate" section rewritten: references load at runtime (not advisory), sizing is not a rule file, investigate convergence corrected, editor-agent pattern scoped to code-overview.
- O1 rewritten to resolve the curse-of-instructions contradiction (template / few-shot / separate self-check split, one layer at a time).
- O3 rewritten as the genuine YAGNI-minimal alternative with the un-measured-drift caveat.
- Recommendation: A39's figure dropped (now rests on A28); A21 downgraded to domain-caveated; the residual risk re-framed from "unenforced" to "loaded-but-not-guaranteed, with higher per-skill wiring cost and a reasoned-not-measured benefit over O3"; the O3 alternative made explicit.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** The benefit of O1 over a strengthened O3 is reasoned, not measured (V8). Per-skill wiring cost is higher than a single file implies, especially for investigate, which has the least existing groundwork (V3, V4). Audience-targeting evidence is domain-limited and is in tension with accuracy preservation on dense technical reports (V6, A29). The rule loads at runtime but loading does not guarantee compliance (V1, A24), so the template/few-shot/self-check split is essential, not optional. The most-corroborated part — *what the rules should say* — is solid; the softer parts are *how much it will help* and *what it costs to wire in*.

## Sources

| ID | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
|---|---|---|---|---|---|---|
| A1 | US Plain Writing Act + Federal Plain Language Guidelines + National Archives Top 10 | https://digital.gov/resources/plain-writing-act ; https://www.archives.gov/open/plain-writing/10-principles.html | 2026-06-29 | web | Clear writing = reader can find, understand, use it; active voice, short sentences, lead with main point, common words | corroborated (A2, A3, A4) |
| A2 | ISO 24495-1:2023 Plain Language (+ two secondary summaries) | https://www.iso.org/standard/78907.html | 2026-06-29 | web | International plain-language standard; full text paywalled; two secondaries disagree on the four principle names | single-source on principle names; conflict surfaced |
| A3 | Microsoft Writing Style Guide (Top 10 + Quick Start) | https://learn.microsoft.com/en-us/style-guide/top-10-tips-style-voice | 2026-06-29 | web | Bigger ideas/fewer words, front-load, prune, sentence case, start with a verb | corroborated (A1, A4) |
| A4 | Google developer documentation style guide (voice + highlights) | https://developers.google.com/style/voice | 2026-06-29 | web | Active voice, second person, conditions before instructions, numbered vs bullet lists, sentence-case headings | corroborated (A1, A3) |
| A5 | Martin Cutts, Oxford Guide to Plain English | https://global.oup.com/academic/product/oxford-guide-to-plain-english-9780198844617 | 2026-06-29 | web | 15-20 word average sentence target; active voice; plain words | corroborated (A6, A1) |
| A6 | American Press Institute sentence-length / comprehension data | https://toolsforwriting.com/blog/ideal-sentence-length-for-readability | 2026-06-29 | web | Comprehension >90% to ~14 words, drops past 25, collapses by 43 (print-era, primary offline) | well-cited; primary not online |
| A7 | Flesch / Flesch-Kincaid readability tests | https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests | 2026-06-29 | web | Arithmetic over sentence length + syllables; 60-70 ≈ plain English | corroborated (A8, A9) |
| A8 | Gunning Fog Index | https://readable.com/readability/gunning-fog-index/ | 2026-06-29 | web | Grade level from sentence length + complex-word ratio | corroborated (A7) |
| A9 | SMOG formula | https://readabilityformulas.com/the-smog-readability-formula/ | 2026-06-29 | web | Polysyllable-based grade estimate targeting full comprehension | corroborated (A7) |
| A10 | Readability-formula criticism (UXmatters 7 reasons; ResearchGate/Klare) | https://www.uxmatters.com/mt/archives/2019/07/readability-formulas-7-reasons-to-avoid-them-and-what-to-do-instead.php | 2026-06-29 | web | Formulas are poor comprehension proxies, inconsistent, gameable, harmful when optimized | corroborated (A7) |
| A11 | NN/G "Concise, Scannable, Objective" usability study | https://www.nngroup.com/articles/concise-scannable-and-objective-how-to-write-for-the-web/ | 2026-06-29 | web | Concise +58%, scannable +47%, objective +27%, combined +124% usability | corroborated (A12, A13) |
| A12 | NN/G F-shaped reading pattern | https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/ | 2026-06-29 | web | Users scan first lines + left column; front-load headings and first words | corroborated (A11, A13) |
| A13 | NN/G Layer-cake scanning pattern | https://www.nngroup.com/articles/layer-cake-pattern-scanning/ | 2026-06-29 | web | Users fixate on headings then read body under the relevant one; headings must be descriptive | corroborated (A12) |
| A14 | NN/G Inverted Pyramid | https://www.nngroup.com/articles/inverted-pyramid/ | 2026-06-29 | web | Conclusion first, detail second, background last; front-load everything | corroborated (A1, A15) |
| A15 | BLUF (Army Regulation 25-50) | https://en.wikipedia.org/wiki/BLUF_(communication) | 2026-06-29 | web | Bottom line up front; main point at the beginning | corroborated (A14, A1) |
| A16 | NN/G Progressive Disclosure (+ UXmatters) | https://www.nngroup.com/articles/progressive-disclosure/ | 2026-06-29 | web | Reveal core first, detail on request; >2 levels causes navigation failure | corroborated (A11, A13) |
| A17 | Carroll's Minimalism (technical communication) | https://en.wikipedia.org/wiki/Minimalism_(technical_communication) | 2026-06-29 | web | Organize content around the reader's task, in short skimmable chunks | corroborated (A16) |
| A18 | Cognitive load theory & writing (Sweller) | https://readabilityformulas.com/improve-your-writing-style-with-cognitive-load-theory/ | 2026-06-29 | web | Long/complex sentences saturate working memory, reducing comprehension | corroborated (A6); "50% drop" figure single-source |
| A19 | Active vs passive evidence (Psych Today summary; APA "In Defense of the Passive") | https://psycnet.apa.org/manuscript/2020-19385-001.pdf | 2026-06-29 | web | Active generally faster to process; no difference in scientific prose — conflict | conflict surfaced; resolves to "active default, passive as exception" |
| A20 | Hemingway Editor thresholds | https://hemingwayapp.com/help/docs/highlighted-issues | 2026-06-29 | web | Flags 20-29 word sentences (consider), 30+ (split), adverbs, passive | corroborated (A6, A5) |
| A21 | Grade-level/audience targeting readability studies (JMIR e69955; JMIR Cardio e68817; PMC12010112) | https://www.jmir.org/2025/1/e69955 | 2026-06-29 | web | "Explain simpler"/grade-level prompts drop FK grade 2-5 levels with no accuracy loss in expert review | corroborated within healthcare domain only (V6); not cross-domain for technical output |
| A22 | Self-Refine (iterative self-critique) | https://arxiv.org/abs/2303.17651 | 2026-06-29 | web | Generate→critique→refine improved output ~20% absolute across 7 tasks incl. readability | corroborated (A23) |
| A23 | DeCRIM (decompose, critique, refine per-constraint) | https://arxiv.org/abs/2410.06458 | 2026-06-29 | web | Splitting constraints + per-constraint critique beats holistic; GPT-4 fails 21%+ multi-constraint | corroborated (A22, A24) |
| A24 | Curse of Instructions | https://openreview.net/forum?id=R6q67CDBCH | 2026-06-29 | web | All-followed probability decays ~exponentially with instruction count (85-90%→15-44%) | corroborated (A23) |
| A25 | Few-shot style exemplars (style-matching MT 2311.02310; Latitude) | https://arxiv.org/abs/2311.02310 | 2026-06-29 | web | Style demonstrations close ~70% of zero→few-shot gap; before/after pairs beat abstract rules | corroborated (A32); blog single-source caveat |
| A26 | Persona double-edged (2408.08631; PRISM 2603.18507) | https://arxiv.org/abs/2408.08631 | 2026-06-29 | web | Personas improve style/format alignment but hurt factual accuracy; detailed > one-liner | corroborated (cross-study) |
| A27 | Verbosity / length bias (DPO 2403.19159; YapBench 2601.00624) | https://arxiv.org/abs/2601.00624 | 2026-06-29 | web | RLHF/DPO training biases models toward longer output; brevity instructions only partly counter | corroborated (cross-study) |
| A28 | Length-constraint imprecision (2601.01768; 2508.13805) | https://arxiv.org/abs/2601.01768 | 2026-06-29 | web | LLMs systematically overshoot numeric word/length targets; qualitative targets work better | corroborated (A27) |
| A29 | Readability-accuracy tension (2511.05080; 2505.01980) | https://arxiv.org/abs/2505.01980 | 2026-06-29 | web | Simplification helps comprehension (~3.9%) but over-simplifying drops fidelity, worse on dense content | corroborated (cross-study) |
| A30 | Unreliable LLM self-judging + sycophancy (WQRM 2504.07532; 2411.10156) | https://arxiv.org/abs/2504.07532 | 2026-06-29 | web | General LLMs barely beat random on writing-quality judging and prefer longer/agreeable text | corroborated (A27) |
| A31 | Instructional distraction (DIM-Bench 2502.04362; prompt bloat) | https://arxiv.org/abs/2502.04362 | 2026-06-29 | web | Models confuse input prose for instructions; reasoning degrades past ~3k tokens | corroborated (cross-source) |
| A32 | Anthropic Prompting best practices | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices | 2026-06-29 | web (official) | Be clear/direct; examples most reliable style lever; prose-not-lists block; no-preamble; give the reason for a rule; role for audience | corroborated (A37, A38) |
| A33 | Claude Code output styles | https://code.claude.com/docs/en/output-styles | 2026-06-29 | web (official) | Markdown files that modify the system prompt with persistent tone/format; project- or user-level | corroborated (A34) |
| A34 | Claude Code modifying system prompts (preset/append/custom) | https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts | 2026-06-29 | web (official) | Four customization paths; append preserves built-ins while adding format/tone rules | corroborated (A33) |
| A35 | Claude Code memory (CLAUDE.md, .claude/rules) | https://code.claude.com/docs/en/memory | 2026-06-29 | web (official) | CLAUDE.md as persistent user-message instructions; path-scoped rules load on matching files | corroborated (A34) |
| A36 | Claude Code skills (SKILL.md) | https://code.claude.com/docs/en/skills | 2026-06-29 | web (official) | Task-specific instructions that load only when invoked; right home for per-deliverable format | corroborated (A35) |
| A37 | Anthropic's Constitution | https://www.anthropic.com/constitution | 2026-06-29 | web (official) | Lists over-hedging, unnecessary caveats, wishy-washy answers, preachiness as behaviors to avoid | corroborated (A32, A38) |
| A38 | Claude 4 system prompt analysis (Simon Willison) | https://simonwillison.net/2025/May/25/claude-4-system-prompt/ | 2026-06-29 | web | Claude's own prompt suppresses reflexive lists and opening flattery | corroborated (A32, A37) |
| A39 | Anthropic April 2026 Claude Code postmortem | https://www.anthropic.com/engineering/april-23-postmortem | 2026-06-29 | web (official) | Claims hard 25/100-word caps caused a measured 3% quality drop, reverted | single-source, first-party, unverifiable (V7); dropped from evidence basis |
| A40 | Claude extended/adaptive thinking (display modes) | https://platform.claude.com/docs/en/build-with-claude/extended-thinking | 2026-06-29 | web (official) | Reasoning is a separate block; display:"omitted" keeps it out of human-facing text | single-source for the display field |
| A41 | Claude structured outputs | https://platform.claude.com/docs/en/build-with-claude/structured-outputs | 2026-06-29 | web (official) | JSON-schema output / strict tools; extract data then render prose separately | corroborated (A32) |
| A42 | Vale prose linter + team deployments (Datadog, Spectrocloud, Contentsquare, GitLab, LWN) | https://vale.sh/docs | 2026-06-29 | web | CI-enforced prose linting catches surface issues at scale; GitLab 3-tier severity; supplements, not replaces, human review | corroborated (multi-org) |
| A43 | Intuit Content Design principles | https://contentdesign.intuit.com/style-and-usage/our-principles/ | 2026-06-29 | web | Each rule = name + rationale + do/don't pair + ≤20-word rule; most actionable reference format found | corroborated (A45, A46) |
| A44 | Mailchimp content style guide (TL;DR) | https://styleguide.mailchimp.com/tldr/ | 2026-06-29 | web | Short quick-reference layer; voice as philosophical pillars (less actionable without examples) | corroborated (A46) |
| A45 | GOV.UK content principles | https://www.gov.uk/government/publications/govuk-content-principles-conventions-and-research-background/govuk-content-principles-conventions-and-research-background | 2026-06-29 | web | Research-grounded rules (F-pattern, inverted pyramid, active voice), ~9-year reading-age floor, word substitutions | corroborated (A43, A2) |
| A46 | NN/G Content Standards in Design Systems | https://www.nngroup.com/articles/content-design-systems/ | 2026-06-29 | web | Standards need actionable direction + clear examples; enforce via education over mandate | corroborated (A43, A44) |
| A47 | Style-guide failure modes (American Editor; PerfectIt; Content Technologist) | https://www.content-technologist.com/style-guide-duo/ | 2026-06-29 | web | Guides fail when long (>~4pp), example-free, top-down, or outside the workflow; "this not that" pairs work | corroborated (cross-source) |
| A48 | Simplified Technical English (ASD-STE100) | https://en.wikipedia.org/wiki/Simplified_Technical_English | 2026-06-29 | web | ~900 one-meaning words + 60 rules + hard length caps; high authoring cost, can't auto-convert prose | corroborated (FAQ); effectiveness claims single-source |
| A49 | Automated-writing-evaluation meta-analyses (PMC10351274 g=0.55; Sage Zhai & Ma g=0.86) | https://pmc.ncbi.nlm.nih.gov/articles/PMC10351274/ | 2026-06-29 | web | AWE feedback improves surface-level writing (medium-large effect), weaker on higher-order quality | corroborated (two meta-analyses) |
| A50 | LLM rubric design + linting (Twine; LintMe 2603.00331; Corelight Vale+LLM) | https://www.twine.net/blog/llm-evaluation-rubrics/ | 2026-06-29 | web | Rubrics need 3-6 behaviorally-anchored dimensions + calibration; structured violation lists let an LLM self-remediate | corroborated (A30) |
| A51 | Pre-publish checklist / DoD / Paperpal Preflight | https://paperpal.com/preflight | 2026-06-29 | web (vendor) | Binary categorized preflight checks as a definition-of-done for written output | single-source/vendor caveat |
| A52 | Han voice profile (`docs/writing-voice.md`) | repo: docs/writing-voice.md | n/a | codebase | Strong specific voice rules (no em-dash, no "just"/"leverage", AI-slop blocklist); governs operator docs, not loaded at runtime by skills | trusted current-state anchor |
| A53 | Han cross-skill rule mechanism (`han-core/references/yagni-rule.md`, `evidence-rule.md`) | repo: han-core/references/*.md | n/a | codebase | The `*-rule.md` model: rule file cited by relative link, vendored into han-planning/han-coding by manual copy | trusted current-state anchor |
| A54 | Han operator-extract pattern (`docs/yagni.md`, `docs/evidence.md`; `docs/sizing.md`) | repo: docs/yagni.md, docs/evidence.md, docs/sizing.md | n/a | codebase | yagni/evidence rules each pair with a `docs/` extract; sizing has a `docs/` narrative but NO `sizing-rule.md` — it is not a shared rule file (V2) | trusted current-state anchor |
| A55 | Han per-skill output templates | repo: han-*/skills/*/references/*template*.md | n/a | codebase | research/code-overview/stakeholder-summary/update-pr-description lead with plain-language summary + progressive disclosure; investigate's summary is a 5-field technical block, not a plain one-liner (V3) | trusted current-state anchor; investigate corrected |
| A56 | Han distributed per-skill plain-language principles | repo: han-*/skills/*/SKILL.md | n/a | codebase | Reader-facing skills re-state their own plain-language rule unevenly (stakeholder-summary Pass A/B/C strong; investigate cites none) — the drift a shared reference would reduce, though drift is un-measured (V8) | trusted current-state anchor |
| A57 | How Han references take effect | repo: docs/yagni.md:13; SKILL.md citations + agent briefs | n/a | codebase | References LOAD at runtime: "every YAGNI-aware skill and agent loads that file at runtime"; skills/agents are directed to read+apply by relative link (V1). Readability editor-agent pass exists only in code-overview (V4) | trusted current-state anchor |

### A21: Grade-level / audience targeting — recommendation-bearing

- **Link / location:** https://www.jmir.org/2025/1/e69955 ; https://cardio.jmir.org/2025/1/e68817 ; https://pmc.ncbi.nlm.nih.gov/articles/PMC12010112/
- **Retrieved:** 2026-06-29
- **Trust class:** web (outside the trust boundary)
- **Summary:** Three independent clinical studies, different models and materials, all show that a plain audience or grade-level instruction ("explain this in simpler terms", "write at a sixth-grade reading level") reliably drops Flesch-Kincaid grade by two to five levels. In a cardiologist's review of 143 rewritten heart-failure documents, none lost accuracy and 23% were judged more comprehensive. This is the single most-evidenced instruction-level lever and grounds the "always-on audience frame" in the recommendation.
- **Evidence status:** corroborated by three independent studies

### A24: Curse of Instructions — recommendation-bearing

- **Link / location:** https://openreview.net/forum?id=R6q67CDBCH (summary: https://maxpool.dev/research-papers/curse_of_instructions_report.html)
- **Retrieved:** 2026-06-29
- **Trust class:** web (outside the trust boundary)
- **Summary:** As the number of simultaneous instructions in a single prompt rises, the probability all are followed decays roughly exponentially — measured drops from ~85-90% at one instruction to 15-44% when many are stacked, with self-refinement only partly recovering. This is the core argument for keeping the readability rule tight and prioritized rather than an exhaustive checklist, and for splitting enforcement across a self-check/rewrite pass.
- **Evidence status:** corroborated by A23 (independent multi-constraint failure + decomposition fix)

### A53: Han's cross-skill rule mechanism — recommendation-bearing

- **Link / location:** repo: `han-core/references/yagni-rule.md`, `han-core/references/evidence-rule.md`, vendored copies in `han-planning/references/` and `han-coding/references/`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Han already ships exactly the artifact shape this standard needs. A canonical `*-rule.md` lives in `han-core/references/`, is cited from skill definitions by relative link, is paired with an operator-facing `docs/` extract, and is vendored into `han-planning` and `han-coding` by manual file copy. A readability standard built this way inherits a proven, understood mechanism rather than inventing one. The cost it also inherits is manual vendoring (no build-step sync).
- **Evidence status:** trusted current-state anchor

### A57: How Han references take effect — recommendation-bearing

- **Link / location:** repo: `docs/yagni.md:13`; skill `SKILL.md` reference citations and dispatched agent briefs; `information-architect` / `junior-developer` readability usage in `code-overview`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Corrected in validation (V1). A Han reference is *loaded and applied at runtime*, not merely author-time guidance: `docs/yagni.md` states "every YAGNI-aware skill and agent loads that file at runtime," and skill steps and agent briefs direct the executor to read and apply the rule by relative link as it runs. This gives a `readability-rule.md` real runtime grip and removes the report's original "advisory" softest point. What loading does not buy is guaranteed compliance once the rule competes with a skill's other instructions (the curse of instructions, A24) — so the recommendation still pairs O1 with template-embedding, few-shot do/don't pairs, and a separate self-check/editor pass. The readability-specific editor-agent pass currently exists in exactly one reader-facing skill, `code-overview` (V4); adopting it elsewhere is new wiring.
- **Evidence status:** trusted current-state anchor
