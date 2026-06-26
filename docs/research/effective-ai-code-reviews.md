# Research: Are the claims about effective AI code reviews (run as a skill in a local LLM) correct?

This report validates — proving, disproving, or adjusting — a set of claims made in a Slack post about how to make AI code reviews effective when run as a skill in a local LLM instance like Claude Code, with particular attention to the Han `code-review` skill the post references.

**Evidence mode: strict** (evidence required; every load-bearing claim carries a source, and recommendations never rest on reasoning alone). The post author explicitly asked for disconfirming evidence, not confirmation, so each claim below was attacked as hard as it was supported.

## Summary

Your Slack post holds up well. The core thesis — that AI reviews get good only when you feed the model the same context a human author had, give it specific and focused review scopes, filter the output for usefulness, and keep a human owning the result — is supported by peer-reviewed studies and by your own code. Two of your strongest points (context makes reviews better, and AI can't replace human review today) are the best-evidenced claims in the whole post.

Four points need softening or a small correction, none of which break your argument:

1. **"It always finds something to complain about"** is true as a description of *un-tuned* AI review, but it's a tuning-and-framing problem, not a law. Well-scoped reviews can and do come back with nothing. Treat it as "the default behavior you have to design against," not "an unfixable property."
2. **"3 to 4 loops of reviews"** helps you find *more real bugs* with diminishing returns, but looping does not by itself reduce the noise problem — that's a separate lever (specificity + filtering). And one caution that does *not* apply to plain re-review: if your loop has the AI *implement* the fixes and re-review, AI-driven fix cycles can accumulate new problems, so that flavor of loop needs care.
3. **"Custom agent definitions that give a specific perspective"** is right about the outcome (focused beats generic), but the lever proven in the research is the *specific scope and focus* you give each agent, not the persona label by itself — naked "you are a senior engineer" framing doesn't reliably help and can even hurt. Your agents already carry detailed, scoped task definitions, so they're well-built; just don't credit the result to the persona alone.
4. **"My code-review skill uses adversarial validation of the findings"** is defensible but worth stating precisely. Your skill *always* runs adversarial specialist agents (a security analyst whose whole posture is adversarial), and it filters findings through a reachability demotion gate plus a self-consistency check. What it does *not* currently have is a separate agent that attacks the *findings themselves* the way your `investigate` skill does. So "adversarial validation" is accurate for the code; adding a dedicated findings-validator would be a genuine upgrade the research supports, not a correction of an error.

Two caveats are worth adding to the post: feeding more context only helps when it's the *right, relevant* context (bulk-dumping unrelated docs measurably hurts), and a ticket fetched over MCP is untrusted text — its content must be treated as *data, not instructions*. That second point is also a real, currently-unguarded gap in Han's own ticket-and-PR-ingesting skills, which is worth fixing.

This is well-corroborated on the load-bearing claims (peer-reviewed plus your own codebase), with the honest caveat that several precise statistics come from very recent preprints and vendor benchmarks that couldn't be independently re-verified; the *direction* of those is corroborated across multiple independent sources even where a specific number isn't.

- **Confidence:** Medium

## Research Results

The findings are organized by the claims in your post, lettered A–J. Each carries a verdict and the artifacts it rests on.

### A. "If you ask an AI for a review it's always going to find something to complain about" — QUALIFIED

The *direction* is well-supported: un-tuned AI reviewers over-produce low-value comments relative to humans. Independent academic studies of real pull requests find AI agents comment on far more conversations than humans (one study: AI comments on 56.6% of conversations vs 20.8% for humans) while their suggestions are adopted at only 16.6% versus 56.5% for human suggestions, and more than half of unadopted AI suggestions were factually incorrect or superseded (A2). A separate benchmark found automated tools generating 324–1,344 comments where humans wrote 234 on the same PRs (A4). Tool precision across independent benchmarks lands roughly between 17% and 67%, meaning a large share of comments are false positives (A5, A6, A7).

But the absolute word "always" is *not* independently proven. The cleanest counter — that GitHub Copilot returns zero comments in 29% of reviews — comes from GitHub itself, a vendor reporting on its own product (A1); applying the same vendor skepticism you'd apply to any other vendor stat, it shows the *capability* to stay silent rather than proving how often it's exercised. The honest read: un-tuned review *tends* to over-produce, well-tuned review *can* stay silent, and the peer-reviewed evidence establishes the tendency, not the absolute.

One mechanism correction worth knowing: the "must find something" feeling is better explained as a task-framing artifact (the model reads "review" as "produce comments") than as sycophancy. Documented LLM sycophancy runs the *opposite* way — toward agreement and excessive positivity (A14, A15) — so it isn't the driver of compulsive fault-finding.

### B. "Generalized AI code reviews won't fix this; it's a massive problem" — SUPPORTED

Generic, un-scoped review is measurably noisier than targeted review, and scoping is the fix. A practitioner team found 25–40% false positives from a single generic pass and resolved it with a two-pass capture-then-filter design (A10). Cloudflare ran AI review at scale (131k+ runs) by explicitly telling each agent what *not* to flag, deliberately landing around 1.2 findings per review (A9). Security-review experiments found generic prompts produced "unnecessary information" 89% of the time and "vague statements" 57% of the time (A47). So "generalized reviews are the problem" is correct; the resolution is specificity, which is exactly where your points 2a/2b go.

### C. "The 3 to 4 loops of reviews make it less of a problem" — QUALIFIED (and one caveat that does not apply)

Running multiple *independent review passes* over the same code raises bug recall, with sharply diminishing returns after roughly 3–5 passes (A13, and self-aggregation results in the noise literature). So looping to catch more does have support. There is even a pro you didn't claim: later rounds catch bugs *introduced by fixes from earlier rounds* (A13).

Two adjustments. First, looping does not by itself reduce the false-positive/"always complains" problem from Claim A — more passes targeting ever-more-marginal territory can compound nitpick fatigue; noise is controlled by specificity and filtering, not repetition. Second, a caveat that is sometimes misattributed to review loops: the peer-reviewed finding that critical vulnerabilities rise ~37.6% after five iterations is about *AI-generation-and-fix* loops (the model rewrites the code each round), not about re-reviewing static code (A12). It only bears on your practice if your loop has the AI implementing fixes between reviews — in which case re-review of the *changed* code matters, and you should not assume each AI fix is clean.

### D. "The LLM needs the same info you used to write the PR: ticket, goal docs, coding standards/ADRs" — SUPPORTED, with a relevance caveat

This is one of your two best-supported claims. A controlled comparison found giving GPT-4o the problem description improved review correctness by ~22% (68.5% vs ~55%) and cut the rate at which it wrongly flags *correct* code from 24.8% down substantially (A20). Specification-grounded review nearly doubled developer adoption of suggestions (42% vs 22%) in a deployed, peer-reviewed system (A21). A field study found developers open the ticket first every time because they need to know "what is supposed to have been achieved," and additionally wanted ADRs and READMEs (A22).

The caveat to add: it has to be the *right* context. Insufficient or wrong context backfires — one study saw an open model's wrong-answer rate jump from 10.2% to 66.1% when given insufficient context, because partial context inflates false confidence (A29). Long-context degradation ("lost in the middle," A26, A28) and distractor interference (semantically-similar-but-wrong context dropping accuracy ~27%, A30) mean bulk-dumping every loosely-related doc can make a review *worse* than diff-only. Selective, relevant, well-placed context — the single linked ticket, the standards that actually govern the changed module — is the version that wins.

### E. Coding standards / ADRs as review context — SUPPORTED for explicit rules, QUALIFIED for ADRs

For bounded, explicit rules (standards, naming conventions, specific prohibitions), grounding demonstrably stops the model from inventing its own preferences — the standards document becomes "the sole source of truth; the model can suggest but never define" (A10, A21). For ADRs and broader architectural conventions specifically, the direction is plausible and practitioner-desired (A22) but not directly measured — carry it as reasonable, not proven. One real risk: piling on style constraints can erode the model's correctness judgment (the style-vs-accuracy trade-off, A31), so standards-as-context is best kept to rules that matter, not exhaustive style minutiae.

### F. "Giving code review access to a Jira ticket is easy — configure the Atlassian MCP and review the PR against the ticket" — SUPPORTED, with a real security caveat

The mechanism is sound and the products are real. MCP is an open standard (originated by Anthropic, now Linux-Foundation-governed) adopted across OpenAI, Google, and Microsoft, with thousands of community servers (A33, A34, A37). The Atlassian Remote MCP Server is a first-party, GA product connecting Jira and Confluence Cloud to MCP clients, with OAuth respecting existing permissions (A35). So "configure the Atlassian MCP and point the review at the ticket" is operationally accurate.

The caveat that belongs in the post: a fetched ticket is *untrusted third-party text*. A ticket description can carry prompt-injection content aimed at the review agent, so its content must be treated as **data, not instructions** (A36) — the same principle this research skill itself runs on. This is not just a documentation nicety: Han's own `work-items-to-jira` skill and the `$branch_context` PR-description injection in `code-review` Step 1.5 currently substitute fetched third-party content into prompts with no sanitization, delimiting, or data-vs-instruction guard (A79). That's a genuine, currently-unmitigated gap in the implementation a reader would be exposed to, worth a follow-up fix rather than only a caveat.

### G. "Custom agent definitions that give a specific perspective… otherwise you get a generic review that only talks about nit-picky things" — QUALIFIED (right outcome, sharpen the mechanism)

The outcome is well-supported. A multi-role framework with targeted per-role prompts achieved a 2x improvement over standard LLMs and 10x over prior baselines on catching the bugs that matter, in industry-scale review (A46). Question-specific rubrics beat generic evaluation by a wide margin (Spearman 0.763 vs 0.510; A44). Decomposing review into specific criteria correlates with humans at 0.78 vs 0.35 for a single holistic score (A45). Generic-prompt review defaulting to low-value comments is documented across multiple sources (A9, A10, A46, A47).

The sharpening: the *demonstrated* lever is task-scope specificity (what to look for, what to ignore, against what rubric), **not** persona identity. Naked role-identity prompting ("you are a senior security engineer") does not reliably improve accuracy and can *hurt* coding accuracy specifically (A38 — EMNLP 2024 across 162 roles; A39 — coding −0.65 with expert personas; A40 — Wharton, no consistent benefit on objective tasks). Your Han agents combine *both* a persona frame and detailed, scoped task protocols (A76), so they're well-designed — but the result comes from the specificity, and no ablation exists (in the literature or your repo) proving the persona label adds value on top. Keep the "specific perspective" framing; just don't lean on persona identity as the explanation when the proven mechanism is the scope.

### H. "Use documented review standards to define what to consider and which agent to use" — SUPPORTED

Documented rubrics and criteria improve review quality (A44, A45), and routing changes to focused, scoped agents based on documented criteria is consistent with the focused-scope evidence (A46). This aligns with how your skill classifies changes and dispatches conditional agents by file pattern (A75).

### I. "My code-review skill uses adversarial validation of the findings, and includes YAGNI validation" — SPLIT: YAGNI SUPPORTED; "adversarial validation" defensible but worth stating precisely

**YAGNI validation — SUPPORTED.** Verified directly in your code: a two-pass YAGNI procedure (Pass 1 evidence test against `yagni-rule.md` Gate 1; Pass 2 named anti-pattern check) feeds a dedicated `### 🟡 YAGNI` section kept separate from Critical/Warning/Suggestion findings (A77, A75). Filtering findings for usefulness is also the kind of relevance/judgment task that the "LLMs can't self-correct reasoning" limitation explicitly does *not* cover (A48, A49), so it's on solid ground both in your code and in the literature.

**"Adversarial validation of the findings" — accurate for the code, imprecise for the findings.** Here the phrasing matters, and the codebase was checked both ways:

- Your `code-review` skill *always* dispatches `adversarial-security-analyst` (an agent whose entire posture is "assume all code is insecure," with a demonstrated-exploit evidence standard), and your own docs describe the skill as "parallel adversarial specialist review" (A76, A78). Under the natural reading "the review is performed adversarially," the claim is true.
- What the skill does **not** do is run a separate agent that attacks the *findings themselves* after the fact — the way your `investigate` skill dispatches `adversarial-validator`. The post-generation filtering in `code-review` is a fixed-phrase reachability demotion gate (it scans rationale text for eight literal phrases like `theoretical` and `hypothetical` and demotes severity), the security agent's evidence standard, and a self-consistency check (A75). The phrase-match gate is brittle to paraphrase: an agent that writes "this is only a theoretical concern" trips it, but a paraphrase that avoids the exact words slips through.

So: if by "adversarial validation of the findings" you meant the adversarial specialist review, you're correct. If a reader takes it to mean a dedicated critic that re-attacks the finding list, that part isn't there. The research strongly supports *adding* one: a separate, independently-prompted critic outperforms same-context self-critique (the role-addressability effect, +23–93pp; A53), and dedicated critics like CriticGPT cut nitpicks and caught ~85% of inserted bugs versus 25% for humans (A51, A52), while dual-LLM validation lifted filtered success from 11% to 35–53% (A59). That's an enhancement worth making, not an error to walk back.

### J. "No LLM and skill set can replace a human review today; humans always own the output" — SUPPORTED (your strongest claim)

Both the empirical and the normative halves hold. Empirically: two peer-reviewed studies of real PRs find AI suggestions adopted at 16.6% vs 56.5% for humans (A2) and AI-only-reviewed PRs merging at 45.2% vs 68.37% for human-reviewed, with 60.2% of closed AI-only PRs in a 0–30% signal-to-noise band (A3). Developer trust in AI accuracy fell to 29% in the 2025 Stack Overflow survey, with 75% saying they'd ask a human when they don't trust AI output (A68). Security is a documented weakness: Veracode's 2025 analysis found 45% of AI-generated code contains an OWASP Top-10 vulnerability (A69). Amazon, after four AI-related production outages, mandated senior-engineer sign-off for AI-assisted deployments — a real-world enactment of human ownership under pressure (A72).

Normatively: the three major AI-governance frameworks (EU AI Act Article 14, NIST AI RMF, ISO/IEC 42001) converge on requiring human oversight proportionate to risk, and a Stanford Law analysis identifies the accountability gap when no human reviews merged code (A73, A74). The honest counter is vendor-sourced and single: Graphite reports its AI flags drive code changes 55% of the time vs 49% for humans and a sub-3% false-positive rate (A11) — which, if independently confirmed, would show AI exceeding humans on one narrow responsiveness metric, but it conflicts with the academic data and carries no outside corroboration. The "AI replaces review" position rests on near-future projections and vendor claims, not present evidence. Your conservative claim is the safe one.

**A note on evidence quality, applied to all of the above:** several decisive-sounding numbers come from very recent (2026) arXiv preprints that are not yet peer-reviewed (e.g., A2, A3, A39, A53, A66) or from vendor and vendor-adjacent benchmarks (A1, A5, A6, A7, A8, A11, A13, A16, A18, A70, A71). The *load-bearing* conclusions — context helps (A20, A21, peer-reviewed), specificity beats generic (A44, A46, peer-reviewed), persona-alone doesn't help (A38, peer-reviewed), the YAGNI and adversarial-specialist facts (A75–A78, your codebase) — rest on peer-reviewed or directly-verified codebase evidence. Where a precise statistic rests on a single recent preprint, the *direction* is corroborated across multiple independent sources even though the exact figure isn't independently re-verified.

## Options to Consider

The one genuine fork the research surfaced is how to make the "adversarial validation of the findings" claim precisely true for `code-review`. (The rest of the post is validation, not a choice among alternatives.)

### O1: Keep the current design; describe it precisely

- **What it is:** Leave `code-review` as-is — adversarial specialist agents generate findings, then a fixed-phrase reachability gate + security evidence standard + self-consistency check filter them — and describe the claim as "adversarial specialist review plus a reachability/usefulness filter."
- **Trade-offs:** No engineering work; accurate. But the phrase-match gate is brittle to paraphrase (A75), and there's no independent critic re-attacking the findings, so the post's wording stays slightly looser than the implementation.
- **Rests on:** (A75), (A76), (A77), (A78)
- **Evidence status:** corroborated (codebase-verified)

### O2: Add a dedicated independent findings-validator pass

- **What it is:** After findings are generated, dispatch a separately-prompted critic (as `investigate` already does with `adversarial-validator`) that attacks the finding list in fresh context — show it the diff, not just the prior findings, to avoid anchoring.
- **Trade-offs:** Extra compute per review; needs precision/recall tuning so it doesn't over-suppress real findings (the overcorrection risk, A66). But it makes the claim literally true and is the better-evidenced design.
- **Rests on:** (A51), (A52), (A53), (A59); guardrails from (A54), (A55), (A63), (A66)
- **Evidence status:** corroborated (the independent-critic advantage is multiply sourced; the specific lift figures are single-source/preprint-caveated)

### O3: Multi-agent debate over findings

- **What it is:** Several independent agents (ideally different model families) debate each finding before it's surfaced.
- **Trade-offs:** Highest cost; evidence is mixed — multi-agent debate often fails to beat simpler self-consistency and agents can become "overly aggressive" or collapse into agreement (A65, A64). Diversity helps only when the agents genuinely differ.
- **Rests on:** (A64), (A65)
- **Evidence status:** single-source (caveated); weakest of the three

## Recommendation

- **Recommendation:** Publish the post largely as written — it's well-supported — with the four softenings and two caveats in the Summary. For the `code-review` skill specifically, **O2** (add a dedicated independent findings-validator) is the recommended enhancement and the cleanest way to make the "adversarial validation of the findings" wording exact; **O1** (keep as-is, describe precisely) is fully acceptable if you don't want the extra pass. Separately, treat the MCP/ticket prompt-injection gap in Han's ingesting skills (A79) as a real follow-up, not just a caveat.
- **Evidence basis:** The recommendation to publish rests on corroborated evidence: context-helps on peer-reviewed A20/A21/A22; specificity-beats-generic on peer-reviewed A44/A46; persona-alone-doesn't-help on peer-reviewed A38 (with A39/A40); MCP/Atlassian reality on official A33/A35; human-can't-replace/ownership on peer-reviewed A2/A3 plus governance A74 and the Amazon precedent A72; and the YAGNI + adversarial-specialist facts on your directly-verified codebase A75–A78. The O2 enhancement rests on the multiply-sourced independent-critic advantage (A51, A52, A53) with the precise lift figures carried as single-source/preprint caveats. The injection-gap follow-up rests on direct codebase inspection (A79) plus the injection-risk literature (A36). The four softenings (Claims A, C, G, I) each rest on the specific corroborated or codebase-verified findings cited in their sections above; none rests on reasoning alone.

## Validation

The `adversarial-validator` was given the full registry, the per-claim verdicts, the options, and the draft recommendation, and charged to attack the evidence, the framing, the recommendation, and the integrity of the evidence-gathering. It independently re-checked every codebase claim against the actual files. Eight findings returned; three changed verdicts and are folded into the report above.

### V1: Claim I — "adversarial validation" verdict was too harsh

- **Strategy:** Challenge the Evidence
- **Investigation:** Read `code-review/SKILL.md` (full), `docs/skills/han-coding/code-review.md`, and `adversarial-security-analyst.md`. Confirmed `adversarial-validator` is absent from the `code-review` dispatcher but present in `investigate` and `code-overview`. Found the project's own docs describe `code-review` as "parallel adversarial specialist review."
- **Result:** Partially Refuted (the draft's "INACCURATE AS WORDED" was too strong).
- **Impact:** Claim I rewritten from "inaccurate, correct it" to "defensible under the adversarial-specialist reading; precise picture stated; a dedicated findings-validator is an enhancement (O2), not a correction." Recommendation item inverted accordingly.

### V2: Claim I — "regex" gate mischaracterized

- **Strategy:** Challenge the Evidence
- **Investigation:** Read `SKILL.md` Step 7.2 and `review-checklist.md`. The gate scans for eight *literal* phrases (fixed-string substring match), not regular expressions; the YAGNI two-pass procedure and its dedicated section are confirmed.
- **Result:** Partially Refuted.
- **Impact:** Report now calls it a fixed-phrase match and notes its brittleness to paraphrase as a real limitation. YAGNI verdict unchanged (confirmed).

### V3: Claim C — loop-type conflation

- **Strategy:** Challenge the Assumptions
- **Investigation:** The "+37.6% vulnerabilities after 5 iterations" finding (A12) is about AI-generation-and-fix loops, not independent re-review passes; the post's "3–4 loops of reviews" most naturally means re-review.
- **Result:** Refuted (as applied).
- **Impact:** Claim C reframed: the security-degradation caveat is now explicitly scoped to AI-fix loops and presented as adjacent, not as a qualifier on plain re-review; the recall/diminishing-returns point stands.

### V4: Claim A — vendor double standard

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The "29% zero comments" stat falsifying "always" is from GitHub (Copilot's vendor), while Graphite's conflicting favorable stat was discounted as vendor-sourced — inconsistent treatment.
- **Result:** Partially Refuted.
- **Impact:** Claim A downgraded from "partly disproven" to "QUALIFIED"; the GitHub stat now carries the same vendor caveat, and the peer-reviewed evidence is framed as establishing the *tendency*, not the absolute.

### V5: Recent-preprint reliance not sensitivity-tested

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Multiple load-bearing stats trace to 2026 arXiv preprints that can't be independently fetched; the draft asserted robustness rather than demonstrating it.
- **Result:** Confirmed (real risk).
- **Impact:** Added the explicit evidence-quality note distinguishing peer-reviewed/codebase load-bearing conclusions from preprint/vendor precise figures, and lowered overall confidence to Medium.

### V6: Claim G — mechanism claim overstated

- **Strategy:** Challenge the Assumptions
- **Investigation:** Han agents use both persona framing and detailed protocols (A76); no ablation isolates the persona's contribution.
- **Result:** Partially Refuted.
- **Impact:** Claim G softened from "works because of task definitions, not persona" to "outcome supported; proven lever is the scope; your agents already carry it; don't credit persona alone."

### V7: Recommendation #4 direction was wrong

- **Strategy:** Challenge the Recommendation
- **Investigation:** Same evidence as V1 — the codebase and docs support the operator's wording under a natural reading.
- **Result:** Refuted.
- **Impact:** The "correct the claim" instruction was inverted into "state it precisely; optionally add a findings-validator (O2)."

### V8: MCP prompt-injection gap is unmitigated in Han itself

- **Strategy:** Challenge the Fix
- **Investigation:** Read `work-items-to-jira/SKILL.md` and `code-review/SKILL.md` Step 1.5. Third-party ticket/PR content is fetched and substituted into prompts with no injection guard, sanitization, or data-delimiting.
- **Result:** Confirmed.
- **Impact:** Claim F now flags this as a real codebase gap and a follow-up fix, not only a documentation caveat.

### Adjustments Made

The recommendation survived but was modified, per the validator's bottom line. Three verdicts changed (Claim I from "inaccurate" to "defensible/precise"; Claim C's fix-loop caveat re-scoped to AI-fix loops only; Claim A from "partly disproven" to "qualified"), one mechanism claim was softened (Claim G), one recommendation item was inverted (the Claim I "correction" became the O2 enhancement), the post-generation gate was corrected from "regex" to fixed-phrase match with a noted brittleness, the MCP gap was elevated from caveat to follow-up, and an evidence-quality note plus a Medium confidence rating were added to reflect the preprint reliance.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** (1) Several precise statistics rest on very recent, non-peer-reviewed 2026 preprints (A2, A3, A39, A53, A66) and on vendor benchmarks (A1, A5–A8, A11, A13, A16, A18, A70, A71) that couldn't be independently re-verified; their directions are corroborated but exact figures aren't. (2) The persona-vs-scope mechanism (Claim G) is inferred from external studies, not from an ablation of Han's own agents. (3) The ADR-as-context point (Claim E) is reasonable but not directly measured. (4) The MCP injection gap (A79) is a live, unmitigated risk in current Han skills until guarded. (5) Sibling next steps: the injection gap is best handled by `/coding-standard` (a rule for treating fetched content as data) and `/investigate` or `/code-review` on the ingesting skills; the O2 findings-validator is a feature change for `/plan-a-feature`.

## Sources

| ID | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
|---|---|---|---|---|---|---|
| A1 | GitHub: 60M Copilot reviews | https://github.blog/ai-and-ml/github-copilot/60-million-copilot-code-reviews-and-counting/ | 2026-06-26 | web (vendor) | Copilot returns zero comments in 29% of reviews; 5.1 comments avg otherwise | single source (vendor; caveated) |
| A2 | Human-AI Synergy in Agentic Code Review | https://arxiv.org/abs/2603.15911 | 2026-06-26 | web (academic preprint) | AI suggestion adoption 16.6% vs 56.5% human; >50% of unadopted AI suggestions wrong | corroborated by A3, A4 |
| A3 | From Industry Claims to Empirical Reality | https://arxiv.org/abs/2604.03196 | 2026-06-26 | web (academic preprint) | AI-only PR merge 45.2% vs 68.37%; 60% of AI-only PRs in 0–30% signal band | corroborated by A2 |
| A4 | Code Review Agent Benchmark | https://arxiv.org/html/2603.23448 | 2026-06-26 | web (academic preprint) | Tools generate 324–1,344 comments vs 234 human on same PRs; 20–32% pass rate | corroborated by A2 |
| A5 | Entelligence AI Code Review Benchmark 2026 | https://entelligence.ai/code-review-benchmark-2026 | 2026-06-26 | web (vendor) | Tool precision 16.8%–66.7% across 8 tools on 67 bugs | corroborated (direction) by A6, A7 |
| A6 | CodeRabbit tops Martian benchmark | https://www.coderabbit.ai/blog/coderabbit-tops-martian-code-review-benchmark | 2026-06-26 | web (vendor) | ~49% precision / 53% recall across ~300k PRs | corroborated (direction) by A5, A7 |
| A7 | factory.ai: which model reviews best | https://factory.ai/news/code-review-benchmark | 2026-06-26 | web (vendor) | Best models ~60–65% precision; multi-pass cheap models competitive | corroborated (direction) by A5, A6 |
| A8 | Greptile benchmarks | https://www.greptile.com/benchmarks | 2026-06-26 | web (vendor) | Bug catch 6%–82% across tools at defaults; no precision reported | single source (caveated) |
| A9 | Cloudflare: orchestrating AI review at scale | https://blog.cloudflare.com/ai-code-review/ | 2026-06-26 | web (operator case study) | 131k+ runs; ~1.2 findings/review via explicit "what not to flag" | single source (operator) |
| A10 | G-Research: LLM patterns that work | https://www.gresearch.com/news/building-a-code-review-tool-the-llm-patterns-that-actually-work/ | 2026-06-26 | web (practitioner) | 25–40% FP single-pass; two-pass + standards-as-source-of-truth fixes it | corroborated by A9 |
| A11 | Graphite: best AI PR reviewers / metrics | https://graphite.com/guides/best-ai-pull-request-reviewers-2025 | 2026-06-26 | web (vendor) | Claims 55% vs 49% action rate, sub-3% FP; conflicts with academic data | single source (conflicts with A2) |
| A12 | Security degradation in iterative AI codegen (IEEE ISTAS 2025) | https://arxiv.org/html/2506.11022v2 | 2026-06-26 | web (peer-reviewed) | Critical vulns +37.6% after 5 AI-generation-and-fix iterations | single source for figure; applies to fix-loops only |
| A13 | Zylos: multi-model iterative review | https://zylos.ai/research/2026-02-17-multi-model-ai-code-review | 2026-06-26 | web (vendor-adjacent) | Iterative review claims 3–5x more bugs; later rounds catch fix-induced bugs | single source (caveated) |
| A14 | Sycophancy under user rebuttal | https://arxiv.org/html/2509.16533v1 | 2026-06-26 | web (academic) | LLMs cave to casual user pushback up to 84.5%; bias toward agreement | corroborated by A15 |
| A15 | LLM-REVal: can we trust LLM reviewers | https://arxiv.org/html/2510.12367v1 | 2026-06-26 | web (academic) | LLM reviewers inflate own-side scores; modest human correlation r=0.50 | corroborated by A14 |
| A16 | Qodo: State of AI Code Quality 2025 | https://www.qodo.ai/reports/state-of-ai-code-quality/ | 2026-06-26 | web (vendor) | 60–65% say AI misses context; 3.8% confident shipping without human review | single source (caveated) |
| A17 | Atomic Robot: AI review fatigue | https://atomicrobot.com/blog/ai-review-fatigue/ | 2026-06-26 | web (practitioner + primary cites) | Automation complacency: reliable automation → 30% error detection (Parasuraman) | corroborated by cited primaries |
| A18 | diffray: LLM hallucinations in review | https://diffray.ai/blog/llm-hallucinations-code-review/ | 2026-06-26 | web (vendor) | 5–15% FP for standard tools; 19.7% package hallucination; cites Veracode 45% | single source (caveated) |
| A19 | AI-Assisted Code Review as Scaffold | https://arxiv.org/html/2604.23251v1 | 2026-06-26 | web (academic experience report) | 87% students found AI review productive; weak on system-level logic | single source (caveated) |
| A20 | Evaluating LLMs for Code Review | https://arxiv.org/html/2505.20206v1 | 2026-06-26 | web (peer-reviewed) | Problem description improves correctness ~22%; cuts false-flagging of correct code | corroborated by A21, A22 |
| A21 | SGCR: specification-grounded review (ASE 2025) | https://arxiv.org/abs/2512.17540 | 2026-06-26 | web (peer-reviewed) | Spec grounding ~doubled suggestion adoption (42% vs 22%) in deployment | corroborated by A20, A22 |
| A22 | Rethinking Code Review Workflows (WirelessCar) | https://arxiv.org/html/2505.16339v1 | 2026-06-26 | web (academic) | Developers open the ticket first; want ADRs/READMEs; FPs undermine trust | corroborated by A20, A21 |
| A23 | SWR-Bench | https://arxiv.org/html/2509.01494v1 | 2026-06-26 | web (academic) | Full-repo context lets tools assess global impact of changes | corroborated by A22 |
| A24 | LAURA: retrieval-augmented review | https://arxiv.org/pdf/2512.01356 | 2026-06-26 | web (academic preprint) | Context-enriched retrieval improves over unaided LLM review | single source (caveated) |
| A25 | Code Review Benchmarks Survey | https://arxiv.org/html/2602.13377v1 | 2026-06-26 | web (academic) | LLM-era benchmarks dropped requirement-linked review (14 → 1 datasets) | meta-evidence |
| A26 | Lost in the Middle (TACL) | https://direct.mit.edu/tacl/article/doi/10.1162/tacl_a_00638/119630/ | 2026-06-26 | web (peer-reviewed) | U-shaped attention; ~30%+ accuracy drop for mid-context info, 6 model families | corroborated by A27, A28 |
| A27 | Context Rot (Chroma 2025, via Morph) | https://www.morphllm.com/context-rot | 2026-06-26 | web (practitioner) | All 18 frontier models degrade with length; code S/N as low as 2.5% | single source for Chroma (caveated) |
| A28 | RULER long-context degradation (via Morph) | https://www.morphllm.com/lost-in-the-middle-llm | 2026-06-26 | web (practitioner) | GPT-4 −15.4 pts at 128K; some models collapse 30–64 pts | corroborated by A26 |
| A29 | Google Research: sufficient context in RAG | https://research.google/blog/deeper-insights-into-retrieval-augmented-generation-the-role-of-sufficient-context/ | 2026-06-26 | web (Google blog) | Insufficient context raised one model's wrong-answer rate 10.2% → 66.1% | single source for figure (caveated) |
| A30 | RAG noisy-retrieval failure modes | https://medium.com/@hashim200222/why-are-current-rag-systems-bad-f145510cffbd | 2026-06-26 | web (practitioner + arXiv corroboration) | Noisy/distractor context can drop accuracy ~27%; counterfactual worst | direction corroborated |
| A31 | Beyond Coding Style | https://arxiv.org/html/2407.00456v1 | 2026-06-26 | web (peer-reviewed) | Style guidelines slightly help readability but can reduce code accuracy | single source (caveated) |
| A32 | Developer-provided context study | https://arxiv.org/html/2512.18925v1 | 2026-06-26 | web (peer-reviewed) | Devs supply project info/guidelines/conventions; efficacy "remains unvalidated" | caveat (unvalidated efficacy) |
| A33 | MCP official specification | https://modelcontextprotocol.io/specification/2025-11-25 | 2026-06-26 | web (official) | JSON-RPC; Resources/Tools/Prompts; consent + untrusted-tool security section | corroborated by A34 |
| A34 | Model Context Protocol (Wikipedia) | https://en.wikipedia.org/wiki/Model_Context_Protocol | 2026-06-26 | web (encyclopedic) | OpenAI/Google/Microsoft adopted 2025; 8M downloads; donated to Linux Foundation | corroborated by A33 |
| A35 | Atlassian Remote MCP Server | https://www.atlassian.com/platform/remote-mcp-server | 2026-06-26 | web (official, interested) | GA Jira/Confluence Cloud MCP; OAuth; cloud-only; rate-limited | corroborated internally |
| A36 | MCP threat modeling / prompt injection | https://arxiv.org/html/2603.22489v1 | 2026-06-26 | web (academic preprint) | 7.2% of MCP servers vulnerable; tool-poisoning + prompt-injection documented | corroborated by A34 |
| A37 | Linux Foundation: Agentic AI Foundation | https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation | 2026-06-26 | web (official) | MCP donated to AAIF (Anthropic, Block, OpenAI); vendor-neutral governance | corroborates A33, A34 |
| A38 | "A Helpful Assistant Is Not Really Helpful" (EMNLP 2024) | https://arxiv.org/abs/2311.10054 | 2026-06-26 | web (peer-reviewed) | 162 personas, 2,410 Qs: personas don't reliably improve accuracy, can hurt | corroborated by A39, A40 |
| A39 | Expert Personas Improve Alignment, Damage Accuracy (PRISM) | https://arxiv.org/abs/2603.18507 | 2026-06-26 | web (preprint) | Expert personas hurt coding/math (coding −0.65), help writing/safety | corroborated by A38 (single-source figure) |
| A40 | Wharton Prompting Science Report 4 | https://arxiv.org/abs/2512.05858 | 2026-06-26 | web (institutional report) | Expert personas show no consistent benefit on objective MC benchmarks | corroborated by A38 |
| A41 | When Does Persona Prompting Help? | https://arxiv.org/html/2605.29420v1 | 2026-06-26 | web (preprint) | Personas add depth, cut clarity; help advisory, hurt conceptual/tech tasks | single source (caveated) |
| A42 | ExpertPrompting | https://arxiv.org/abs/2305.14688 | 2026-06-26 | web (preprint) | Detailed auto-generated expert framing helps open-ended; simple labels don't | single source (caveated) |
| A43 | DETAIL Matters: prompt specificity | https://arxiv.org/html/2512.02246v1 | 2026-06-26 | web (preprint) | More specific prompts improve reasoning (O3-mini 0.34 → 0.81) | corroborated (direction) by A44 |
| A44 | Rubric Is All You Need (ICER 2025) | https://arxiv.org/html/2503.23989v1 | 2026-06-26 | web (peer-reviewed) | Question-specific rubrics beat generic (Spearman 0.763 vs 0.510) | corroborated by A45, A46 |
| A45 | DeCE: decomposed criteria | https://arxiv.org/html/2509.16093v2 | 2026-06-26 | web (preprint) | Decomposed criteria correlate 0.78 with humans vs 0.35 holistic | corroborated by A44 |
| A46 | Defect-Focused Automated Code Review (ICML 2025) | https://arxiv.org/html/2505.17928v2 | 2026-06-26 | web (peer-reviewed) | Multi-role targeted prompts: 2x over standard LLMs, 10x over baselines on key bugs | corroborated by A44 |
| A47 | Security Code Review with LLMs | https://ar5iv.labs.arxiv.org/html/2401.16310 | 2026-06-26 | web (preprint) | Specific-CWE prompts beat generic and role-based; generic = 89% unnecessary info | corroborated by A46 |
| A48 | LLMs Cannot Self-Correct Reasoning Yet (ICLR 2024) | https://arxiv.org/abs/2310.01798 | 2026-06-26 | web (peer-reviewed) | Intrinsic self-correction fails/degrades on reasoning; OK for style/safety | corroborated by A49, A50 |
| A49 | When Can LLMs Correct Their Own Mistakes (TACL 2024) | https://direct.mit.edu/tacl/article/doi/10.1162/tacl_a_00713/125177/ | 2026-06-26 | web (peer-reviewed) | Self-correction works only with verifiable subtasks, tools, or big fine-tuning | corroborated by A48 |
| A50 | LLMs Cannot Find Reasoning Errors (ACL 2024) | https://arxiv.org/abs/2311.08516 | 2026-06-26 | web (peer-reviewed) | Models fail to locate errors but fix them once located | corroborated by A48 |
| A51 | CriticGPT: LLM critics catch LLM bugs (OpenAI) | https://arxiv.org/abs/2407.00215 | 2026-06-26 | web (industry research) | Separate critic caught ~85% inserted bugs vs 25% human; fewer nitpicks | corroborated by A52 |
| A52 | Shepherd: a critic for LM generation (Meta) | https://arxiv.org/abs/2308.04592 | 2026-06-26 | web (industry research) | 7B dedicated critic matches/beats ChatGPT critiques 53–87% | corroborated by A51 |
| A53 | The Self-Correction Illusion (role-addressability) | https://arxiv.org/html/2606.05976 | 2026-06-26 | web (preprint) | Same error fixed +23–93pp more when presented in external vs own-thought role | single source (caveated) |
| A54 | Self-Preference Bias in LLM-as-Judge | https://arxiv.org/abs/2410.21819 | 2026-06-26 | web (academic) | GPT-4 favors low-perplexity (familiar) outputs regardless of quality | corroborated by A55 |
| A55 | LLM Evaluators Favor Their Own Generations | https://arxiv.org/abs/2404.13076 | 2026-06-26 | web (academic) | GPT-4 recognizes its own output 73.5%; self-recognition causes self-preference | corroborated by A54 |
| A56 | Self-Refine | https://arxiv.org/abs/2303.17651 | 2026-06-26 | web (academic) | Same-LLM critique-refine ~20% avg gain across 7 tasks | contested by A48 |
| A57 | Reflexion (NeurIPS 2023) | https://arxiv.org/abs/2303.11366 | 2026-06-26 | web (peer-reviewed) | 91% pass@1 HumanEval — coding gains driven by external test signal | external-signal-dependent |
| A58 | RealCritic | https://arxiv.org/abs/2501.14492 | 2026-06-26 | web (preprint) | Classical LLMs underperform baseline in self-critique; reasoning models better | corroborated by A48 |
| A59 | Abstain and Validate (dual-LLM) | https://arxiv.org/html/2510.03217 | 2026-06-26 | web (preprint) | Two-stage filter lifts filtered success 11% → 35–53% | single source (caveated) |
| A60 | LLM4FPM: false-positive mitigation | https://arxiv.org/html/2411.03079v2 | 2026-06-26 | web (preprint) | LLM validator + rich context: F1>99% synthetic, >85% FP eliminated real | corroborated by A61 |
| A61 | Reducing FPs in static bug detection (Tencent) | https://arxiv.org/html/2601.18844v1 | 2026-06-26 | web (academic) | Hybrid LLM cuts 94–98% of static-analysis FPs at 93–94% accuracy | corroborated by A60, A62 |
| A62 | Sifting the Noise (SAST FP filtering) | https://arxiv.org/html/2601.22952 | 2026-06-26 | web (academic) | LLM agent filtering cut 92% baseline FP rate to 6.3% best case | corroborated by A61 |
| A63 | Confirmation bias in security code review | https://arxiv.org/pdf/2603.18740 | 2026-06-26 | web (preprint) | Suggestive context makes LLMs "find" aligned vulns that don't exist | single source (caveated) |
| A64 | Agent-as-a-Judge survey | https://arxiv.org/html/2508.02994v1 | 2026-06-26 | web (academic) | Multi-agent judging beats single-judge on some tasks; biases documented | corroborated by A51 |
| A65 | Multi-LLM Debate limits (ICLR 2025 blog) | https://d2jud02ci9yv69.cloudfront.net/2025-04-28-mad-159/blog/mad/ | 2026-06-26 | web (academic blog) | Debate often fails to beat self-consistency; agents "overly aggressive" | corroborated by A49 |
| A66 | Are LLMs Reliable Code Reviewers (overcorrection) | https://arxiv.org/html/2603.00539v1 | 2026-06-26 | web (preprint) | Explanation-required prompting spikes false-negatives 26% → 73% | single source (caveated) |
| A67 | Judging LLM-as-a-Judge (MT-Bench) | https://arxiv.org/abs/2306.05685 | 2026-06-26 | web (academic) | LLM judges agree with humans ~85%; self-enhancement/position/verbosity bias | corroborated by A54 |
| A68 | Stack Overflow 2025 Developer Survey | https://survey.stackoverflow.co/2025/ai/ | 2026-06-26 | web (large independent survey) | Trust in AI accuracy fell to 29%; 75% defer to a human when unsure | corroborated by A16 |
| A69 | OpenSSF: AI software dev security (cites Veracode) | https://openssf.org/blog/2025/12/29/ai-software-development-security-tips-and-the-future-part-1/ | 2026-06-26 | web (foundation) | 45% of AI-generated code has an OWASP Top-10 vuln (Veracode 2025) | corroborated by A18 |
| A70 | Faros AI Engineering Report 2026 | https://www.faros.ai/blog/ai-acceleration-whiplash-takeaways | 2026-06-26 | web (vendor telemetry) | PRs merged without review +31.3%; incidents-to-PR +242.7% at high-AI teams | single source (caveated) |
| A71 | Swarmia: should humans still review code | https://www.swarmia.com/blog/should-humans-still-review-code/ | 2026-06-26 | web (vendor) | AI-coauthored PRs 1.7x more issues; advocates stacked human+AI filters | corroborated (direction) by A70 |
| A72 | Amazon mandates senior approval after outages | https://www.techradar.com/pro/amazon-is-making-even-senior-engineers-get-code-signed-off-following-multiple-recent-outages | 2026-06-26 | web (news, 2 outlets) | After 4 AI-related outages, senior sign-off required for AI-assisted deploys | corroborated across outlets |
| A73 | Stanford Law CodeX: accountability | https://law.stanford.edu/2026/02/08/built-by-agents-tested-by-agents-trusted-by-whom/ | 2026-06-26 | web (academic law) | When no human reviews merged code, the accountability chain breaks | corroborated by A74 |
| A74 | AI governance frameworks compared | https://trustible.ai/post/ai-governance-frameworks-nist-ai-rmf-eu-ai-act-iso-42001-compared/ | 2026-06-26 | web (compliance analysis) | EU AI Act/NIST/ISO 42001 converge on risk-proportionate human oversight | corroborated by A73 |
| A75 | Han `code-review` skill | `han-coding/skills/code-review/SKILL.md` | n/a | codebase (trusted anchor) | Dispatches scoped specialist agents; Step 7.2 fixed-phrase demotion gate; self-consistency check; no `adversarial-validator` | corroborated (verified) |
| A76 | Han agent definitions | `han-core/agents/adversarial-security-analyst.md` (+ siblings) | n/a | codebase (trusted anchor) | Each agent carries a specific adversarial/scoped perspective + protocol | corroborated (verified) |
| A77 | Han YAGNI procedure + rule | `han-coding/skills/code-review/references/review-checklist.md`; `han-coding/references/yagni-rule.md` | n/a | codebase (trusted anchor) | Two-pass YAGNI (evidence test + anti-pattern check); dedicated YAGNI section | corroborated (verified) |
| A78 | Han `code-review` long-form doc | `docs/skills/han-coding/code-review.md` | n/a | codebase (trusted anchor) | Describes skill as "parallel adversarial specialist review" | corroborated (verified) |
| A79 | Han third-party-content ingestion (injection gap) | `han-atlassian/skills/work-items-to-jira/SKILL.md`; `han-coding/skills/code-review/SKILL.md` (Step 1.5 `$branch_context`) | n/a | codebase (trusted anchor) | Fetched ticket/PR content substituted into prompts with no injection guard | corroborated (verified) |

### A75: Han `code-review` skill — recommendation-bearing

- **Link / location:** `han-coding/skills/code-review/SKILL.md`
- **Retrieved:** n/a (codebase)
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Step 3 classifies change size and dispatches scoped specialist agents (always `junior-developer` and `adversarial-security-analyst`, plus conditional analysts by file pattern). Findings are filtered post-generation by a Step 7.2 reachability gate that scans rationale text for eight literal phrases and demotes severity, by the security agent's demonstrated-exploit evidence standard, and by a self-consistency check. No `adversarial-validator` agent is dispatched (that agent is used by `investigate` and `code-overview`). This is the anchor for the Claim I verdict and for the O1/O2 options.
- **Evidence status:** corroborated (independently verified by the validator against the file)

### A20: Evaluating LLMs for Code Review — recommendation-bearing

- **Link / location:** https://arxiv.org/html/2505.20206v1
- **Retrieved:** 2026-06-26
- **Trust class:** web (peer-reviewed)
- **Summary:** Controlled comparison of LLM review with and without a problem description. GPT-4o correctness rose to 68.5% with the description versus ~55% without, and the regression rate (flagging correct code as buggy) reached 24.8% without context and dropped with it. This is the cleanest causal support for Claim D — that giving the reviewer the task context improves intent-level review and cuts false-flagging.
- **Evidence status:** corroborated by A21, A22

### A2: Human-AI Synergy in Agentic Code Review — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2603.15911
- **Retrieved:** 2026-06-26
- **Trust class:** web (academic preprint)
- **Summary:** Analysis of 278,790 inline review conversations across 300 repos: AI suggestions adopted at 16.6% vs 56.5% for humans; over half of unadopted AI suggestions factually incorrect or superseded; AI rarely provides understanding/knowledge-transfer feedback. Load-bearing for Claims A and J. As a recent preprint, the precise figures carry a single-source-style caveat even though corroborated in direction by A3 and A4.
- **Evidence status:** corroborated by A3, A4 (direction); precise figures preprint-caveated

### A38: "A Helpful Assistant Is Not Really Helpful" (EMNLP 2024) — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2311.10054
- **Retrieved:** 2026-06-26
- **Trust class:** web (peer-reviewed)
- **Summary:** Evaluated 162 persona roles across 4 LLM families on 2,410 factual questions; personas in system prompts did not improve accuracy and some reduced it. The peer-reviewed backbone of the Claim G sharpening — that persona identity alone is not the proven lever. Scope is factual QA, which is why the report pairs it with task-specificity evidence (A44, A46) rather than overclaiming.
- **Evidence status:** corroborated by A39, A40

### A44: Rubric Is All You Need (ICER 2025) — recommendation-bearing

- **Link / location:** https://arxiv.org/html/2503.23989v1
- **Retrieved:** 2026-06-26
- **Trust class:** web (peer-reviewed)
- **Summary:** Question-specific rubrics for evaluating code beat question-agnostic prompting by a wide margin (Spearman 0.763 vs 0.510; Cohen's Kappa 0.646 vs 0.156). Peer-reviewed support that *task-scope specificity* — not persona — is the lever behind "focused beats generic" in Claim G.
- **Evidence status:** corroborated by A45, A46

### A46: Defect-Focused Automated Code Review (ICML 2025) — recommendation-bearing

- **Link / location:** https://arxiv.org/html/2505.17928v2
- **Retrieved:** 2026-06-26
- **Trust class:** web (peer-reviewed)
- **Summary:** Industry-scale multi-role framework (Reviewer/Meta-Reviewer/Validator/Translator), each with targeted prompts and a Q1–Q3 nitpick/fake-problem/criticality rubric, achieved 2x improvement over standard LLMs and 10x over prior baselines on key-bug inclusion. Supports Claims B, G, H and the multi-stage filtering idea behind O2.
- **Evidence status:** corroborated by A44

### A51: CriticGPT — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2407.00215
- **Retrieved:** 2026-06-26
- **Trust class:** web (industry research, OpenAI)
- **Summary:** A separately-trained critic model evaluating ChatGPT code caught ~85% of inserted bugs versus 25% for human reviewers, was preferred over human critiques in 63% of error cases, and produced fewer nitpicks and fewer hallucinated problems than baseline self-critique. Primary support for O2 (a dedicated independent findings-validator beats same-context self-critique).
- **Evidence status:** corroborated by A52

### A12: Security degradation in iterative AI codegen (IEEE ISTAS 2025) — recommendation-bearing

- **Link / location:** https://arxiv.org/html/2506.11022v2
- **Retrieved:** 2026-06-26
- **Trust class:** web (peer-reviewed)
- **Summary:** Across 400 samples and 40 rounds, critical vulnerabilities rose 37.6% after five iterations of AI generation-and-fix; authors recommend capping AI-only iterations at 3 before human review. Crucially this is an AI-*fix* loop, not independent re-review — the basis for re-scoping the Claim C caveat (V3).
- **Evidence status:** single source for the figure; scope explicitly limited to AI-fix loops

### A33 / A35: MCP spec + Atlassian MCP server — recommendation-bearing

- **Link / location:** https://modelcontextprotocol.io/specification/2025-11-25 ; https://www.atlassian.com/platform/remote-mcp-server
- **Retrieved:** 2026-06-26
- **Trust class:** web (official; Atlassian is an interested party for its own product)
- **Summary:** MCP is an open JSON-RPC standard exposing Resources/Tools/Prompts with an explicit consent-and-untrusted-tool security model; the Atlassian Remote MCP Server is a GA first-party product connecting Jira/Confluence Cloud over OAuth (cloud-only, rate-limited). Establishes that Claim F's mechanism is real and supported; the security section and A36 ground the injection caveat.
- **Evidence status:** corroborated internally and by A34, A37

### A68: Stack Overflow 2025 Developer Survey — recommendation-bearing

- **Link / location:** https://survey.stackoverflow.co/2025/ai/
- **Retrieved:** 2026-06-26
- **Trust class:** web (large independent survey)
- **Summary:** Developer trust in AI accuracy fell from 40% to 29% year-over-year; 46% distrust AI output; 75% would ask a human when they don't trust an AI answer; usage still rose to 84%. The broadest independent practitioner signal supporting Claim J.
- **Evidence status:** corroborated by A16

### A74: AI governance frameworks compared — recommendation-bearing

- **Link / location:** https://trustible.ai/post/ai-governance-frameworks-nist-ai-rmf-eu-ai-act-iso-42001-compared/
- **Retrieved:** 2026-06-26
- **Trust class:** web (compliance analysis firm)
- **Summary:** EU AI Act Article 14, NIST AI RMF, and ISO/IEC 42001 all require documented human-oversight capability proportionate to risk; none mandate universal human-in-the-loop, all require it scaled to consequence. The normative backbone of Claim J's "humans own the output," alongside the Stanford Law accountability analysis (A73) and the Amazon precedent (A72).
- **Evidence status:** corroborated by A73
