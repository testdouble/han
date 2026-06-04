# Research: How could the "ADHD" parallel divergent ideation article inform changes to the Han plugin?

A plain-language analysis of where the techniques described at https://uditakhourii.github.io/adhd/ could benefit Han's skills and agents, and where they would not. Evidence mode: **strict**.

## Summary

The article (A1) advocates three techniques for getting better answers out of LLMs on open-ended design questions: run multiple branches in parallel with **no shared context** between them, route each branch through a different **cognitive frame** to force structural variety, and split generation from criticism into **two phases with incompatible prompts**.

Han already uses two of those three patterns (A11). Generator-critic separation appears in `investigate`, `research`, and `gap-analysis` (A11). Parallel multi-specialist fan-out is the dominant composition shape across every planning, review, and architecture skill (A11). The piece Han uses least is **branch isolation** — most Han skills deliberately share project context (CLAUDE.md, ADRs, coding standards) across the parallel agents to keep their work consistent (A11).

After validation, the analysis does not support a confident recommendation to retrofit the article's specific mechanisms into Han. The article is self-labeled "Preprint v0.1" on its own page (A1), and the author is identified across multiple independent profiles as a CS undergraduate at IIT Patna who has been founding AI startups for four years (A10); no peer-reviewed publication by this author has been surfaced (A1, A10). The article's evaluation is small (six problems) and self-judged (A1). Its most architecturally sound idea — branch isolation — is already used in the one place Han most needs it (the `research` skill's web-facing angle) (A11). Its most distinctive idea — a curated library of 15 cognitive frames (A1) — is directly contradicted by an independent academic finding that *ordinary* personas outperform *curated expert* personas (A5). And the academic source most often cited as corroboration measured its diversity benefit at K=100 parallel samples (A4), not at the K=2-to-5 scale Han dispatches (A11).

**Bottom line: no clear winner.** The principles the article advocates are sound and Han already implements them where they fit (A11). The specific mechanisms the article proposes are not independently validated at Han's scale and would, in most candidate insertion points, conflict with Han's existing architecture in ways the evidence does not say are worth the cost. The recommendation rests on academic prior art that supports general parallel divergent ideation at large K (A3, A4, A8, A9), plus a single-source article whose Han-specific applicability is contested (A1, contradicted by A5, A7).

## Prompt Used

The following prompt was used to generate the report:

> read https://uditakhourii.github.io/adhd/ and look at the Han plugin skills and agents in this project. /research how this article can benefit the Han plugin - how we
  can modify parts of han to work in this manner, what benefit there would be and when, etc. i want a plain language analysis of where this would benefit han, with
  reasoning on why.

The `/research` skill comes from the Han plugin, in this repository.

A second prompt was also used, to cross-reference the source material into the report, after the initial report was written:

> cross-reference the A1 through A11 sources in the research content, so i know where each claim in the content came from. commit and push when you're done 

## Research Results

### What the article argues

The article (A1) names a failure mode it calls "premature convergence": large language models evaluate as they generate, defaulting to the first high-probability answer and polishing it rather than exploring the broader solution space. This diagnosis is independently corroborated from two different empirical directions (A4, A5).

To counter premature convergence, the article proposes three mechanisms:

1. **Branch isolation.** Run N separate LLM calls with no shared history, context, or prior outputs. The article explicitly distinguishes this from Tree-of-Thoughts (A6), which evaluates within a shared tree and allows anchoring. The isolation-prevents-anchoring claim is corroborated for the fixation mechanism by A5; the specific superiority over ToT is the article's claim alone.
2. **Frame-based branching.** Each parallel branch routes through a different cognitive frame from a hand-authored library of 15 (hardware engineer, regulator, biology, logistics, game design, markets, inversion, budget constraints, assumption removal, speedrunner, ant colony, on-call, plus general categories). The goal is "structurally different ideas, not nearby ones" (A1). A5 corroborates persona diversity as a mechanism but with an important contrast: A5 finds *ordinary* personas (random backgrounds) outperform *curated expert* personas. ADHD's 15 frames are curated, which is the opposite design choice.
3. **Generator-critic separation.** The generator prompt forbids evaluation; the critic prompt forbids generation. Strongly corroborated by A3 (Fraunhofer ECIS 2024), A4 (CreativeDC), A8 (persona-matched scaffolding), and A9 (proposer-verifier as foundational test-time-compute pattern).

### What the article evaluates and how reliable that is

The article reports its method winning 5 of 6 engineering problems against a single-shot baseline, on five dimensions (novelty, breadth, trap detection, actionability, builder usefulness), with an LLM-as-judge prompted as a "skeptical staff engineer" (A1). The author acknowledges the limits directly: the judge is the same model family as the generator (familiarity bias); only six problems were tested; all six are engineering-shaped; the deepen pass confounds actionability; the frame library is hand-authored and can fail silently (A1). No independent replication exists. The article is self-labeled "Preprint v0.1 · 2026-05-25" with no journal or conference venue cited (A1). The author is identified across multiple independent profiles as a CS undergraduate at IIT Patna with a four-year startup-founder background, and no peer-reviewed publication has been surfaced (A10). The article should be read as practitioner prior art, not as peer-reviewed research.

The most strongly corroborated piece of the article is the two-phase generator-critic separation, supported by four independent academic sources (A3, A4, A8, A9). The least corroborated piece is the specific 15-frame library and the "deepen" pass on critic-selected survivors — both are single-sourced from A1. The branch isolation mechanism falls between: the diagnosis it addresses (within-session fixation) is corroborated by A5, but the specific claim that isolation outperforms shared-context branching like Tree-of-Thoughts is the article's claim alone.

### What the article says about where it does not apply

The article explicitly excludes lookup questions, bugs with a known root cause, tasks answerable by search, and single-correct-answer problems. It positions itself as a subroutine invoked at high-stakes decision points, not as a general interface. Cost is roughly 5–10× a baseline call (~$0.30, 30–90 seconds), making it incompatible with tight-latency inner loops (A1).

### How Han is already shaped

Han's skills overwhelmingly use parallel fan-out as their composition shape (A11). `plan-a-feature`, `plan-implementation`, `code-review`, `investigate`, `research`, `architectural-analysis`, `gap-analysis`, `test-planning`, and `iterative-plan-review` all dispatch multiple specialist agents in parallel, then synthesize (A11). Generator-critic separation appears explicitly in `investigate` (evidence-based-investigator plus adversarial-validator), `research` (research-analyst plus adversarial-validator), and `gap-analysis` (gap-analyzer plus adversarial-validator) (A11).

Branch isolation is used in one Han skill that anchors the comparison: `research` deliberately withholds codebase contents, repository paths, and operator context from its web-facing `research-analyst` agents (A11) — the explicit motivation in `plugin/skills/research/SKILL.md` is that any directive language inside a fetched page would have nothing in the brief to act on. That is the same anchoring-prevention motivation the article gives (A1), applied at the skill-internal trust-boundary level.

Han's domain specialists (`adversarial-security-analyst`, `devops-engineer`, `user-experience-designer`, `data-engineer`, etc.) are functionally close to what the article calls cognitive frames: each agent generates from a distinct epistemic posture in parallel with no live context shared between agents (A1, A11). The structural difference is that Han's specialists are domain-grounded (they read the artifact under review) (A11) while the article's frames are off-domain reframing tools (a regulator considering a code architecture question) (A1). A5's finding that ordinary personas outperform curated expert personas is in tension with both choices — but it leans against the article's curated-expert framing more strongly than against Han's domain specialists (A5) [single-source].

### What is in tension between the article and Han

Two tensions matter. First, the article treats shared context as the cause of anchoring (A1), while Han treats shared context (CLAUDE.md, ADRs, coding standards) as the source of consistency across specialists (A11). These framings are not symmetric — anchoring is about idea diversity, consistency is about respecting project standards — but they pull in opposite directions on the same lever. Any application of branch isolation inside Han has to specify which context to withhold and which to keep, or it breaks Han's standards-enforcement story.

Second, the article is built around fully automated LLM-to-LLM pipelines (A1). Han's planning skills are human-in-the-loop: `plan-a-feature` interviews the user at every design decision, and `architectural-decision-record` gates on the user for forcing function and alternatives (A11). A7 (CHI 2025, 280 designers) found no statistically significant improvement when using LLMs for problem reframing with human designers, and found LLM use *amplified* the expert-novice gap (A7). The applicability of A7 to Han's human-in-the-loop skills is direct enough that it cannot be set aside as caveat — it is counter-evidence for the article's ideas in exactly the Han contexts that look most appealing.

## Options to Consider

The question is not a binary choice, so the options below capture distinct change postures the operator could take toward Han.

### O1: Adopt nothing; the article's ideas are either already in Han or not validated for Han's shape

- **What it is:** Treat the article (A1) as confirmation that the patterns Han already uses (parallel fan-out, generator-critic separation, web-vs-codebase isolation in `research`) are well-founded (A11). Make no structural changes.
- **Trade-offs:** Costs nothing. Forgoes any potential benefit if Han's outputs *do* exhibit premature convergence symptoms that the existing adversarial review fails to catch (A1's diagnosis; not evidenced for Han per V6). Leaves the article's most novel ideas (curated cognitive frames, deepen pass) untested in Han (A1).
- **Rests on:** (V2) `research` already implements branch isolation (A11); (V3) Han's domain specialists are structurally equivalent to ADHD's frame-based branching (A1, A11); (V6) no Han-specific evidence of premature convergence has been gathered.
- **Evidence status:** corroborated by validation findings against the recommendation

### O2: Narrow application — add branch isolation as an opt-in toggle for `architectural-decision-record` alternative generation only

- **What it is:** During the gather-alternatives sub-step of `architectural-decision-record` (the step before architectural review dispatches) (A11), optionally fan out 3–5 isolated context-light branches that generate alternative decisions (mechanism from A1), then merge into the Alternatives Considered section the existing review agents stress-test (A11). Default off; user opts in for high-stakes decisions.
- **Trade-offs:** Targets a real decision point where the cost (a few extra calls at ADR time) is bounded and where the alternatives-generation step is currently single-pass (A11). Costs roughly 3–5× ADR generation time and call budget when on (A1's cost profile). Tension with Han's standards-consistency model — isolated branches would not see CLAUDE.md/ADRs (A11), which may produce alternatives that violate project conventions and need filtering. Independent corroboration for the specific benefit at K=3–5 is absent (A4's evidence is at K=100).
- **Rests on:** (A3, A4, A8, A9) general support for divergent-generation phase before convergent review; (A1) the specific mechanism, single-source.
- **Evidence status:** principle corroborated; specific Han-scale benefit single-source

### O3: Selective application — add a frame-based dispatch override to `research` for genuinely open-ended "what could we do" questions

- **What it is:** When a user marks a `research` question as ideation-shaped rather than evidence-gathering, allow `research-analyst` angles to be dispatched by cognitive frame (regulator, on-call, inversion, etc.) (A1) rather than by domain (A11). Web-vs-codebase isolation already exists (A11); this adds frame diversity on top.
- **Trade-offs:** Smallest possible change because the isolation half is already present (A11). A5 contradicts the curated-frame design specifically — ordinary personas reportedly outperform curated experts (A5). Han users would have to maintain or accept a frame library (A1's design). No evidence the off-domain frames produce more useful ideation at K=3 than the existing domain `research-analyst` does (A4 evidence is at K=100 only).
- **Rests on:** (A1) the frame library design; (A5) contradicts the curated-expert choice; (A4) corroborates general divergent-convergent separation at K=100 only.
- **Evidence status:** principle partially corroborated; specific design contradicted by A5

### O4: Empirical first — gather Han-specific evidence before adopting anything

- **What it is:** Before changing any skill, examine real outputs from `plan-a-feature` and `architectural-decision-record` runs (A11) to determine whether premature convergence (A1) actually occurs in Han's pipeline at a rate the existing adversarial review (A11) fails to catch. Only then design a targeted intervention.
- **Trade-offs:** Slowest. Requires capturing comparable runs and judging their outputs. Avoids importing a remedy without evidence the disease is present. Honors Han's own YAGNI rule (A11 — every planning skill applies it; an addition without a measured gap fails the test).
- **Rests on:** (V6) the validator's finding that the premature convergence diagnosis is not evidenced for Han's pipeline; Han's own YAGNI rule (A11), applied across every planning skill.
- **Evidence status:** corroborated as a methodology

## Recommendation

- **Recommendation:** No clear winner. The architectural principles in the article (parallel divergent ideation, generator-critic separation, branch isolation at trust boundaries) are well-corroborated by independent academic sources and are already implemented in Han where they fit best. The specific mechanisms the article proposes (a 15-frame curated library, a deepen pass on top survivors) are single-sourced and contradicted in part by A5 on persona quality and by A7 on human-in-the-loop applicability. The most attractive-sounding application points — injecting frame-isolated branches into `plan-a-feature` design decisions or `architectural-decision-record` alternatives — are exactly the human-in-the-loop contexts A7's evidence cautions against, and would multiply Han's already-high agent call volume without a measured Han-specific problem to solve.

  If the operator wants to act anyway, the lowest-regret move is **O4 first, then O2 if O4 surfaces evidence**: capture real `plan-a-feature` and `architectural-decision-record` outputs and check whether they exhibit the convergence symptom the article diagnoses, before retrofitting the article's specific mechanisms. If no symptom is found, **O1** is the right answer. If a symptom is found, **O2's** narrow ADR-alternatives application is the smallest defensible change with the most bounded cost.

  **O3** (frame-based `research`) is *not* recommended: A5 contradicts the curated-frame design, A4 does not corroborate the benefit at Han's dispatch scale, and Han's `research` skill already has the half of the article that has the strongest independent support.

- **Evidence basis:** Corroborated evidence supports the *principles* the article advocates (A3, A4, A5, A8, A9 — generator-critic separation, divergent-convergent phasing, persona diversity as a mechanism in some form). The article's *specific mechanisms* — the 15-frame library, the deepen pass, the claim of superiority over ToT — rest on A1 alone, written by the tool's author, with self-evaluation on six engineering problems and no peer review. The recommendation that Han change nothing structurally today rests on (a) corroborated evidence that Han already implements the well-supported parts; (b) the validation finding (V6) that no Han-specific evidence of premature convergence has been gathered, which renders all proposed changes solutions in search of a problem under Han's own YAGNI rule. The recommendation does not rest on reasoning alone — the validation findings are the load-bearing evidence for declining to recommend specific structural changes.

## Validation

### V1: A1's specific-mechanism claims are single-sourced and the author is the primary beneficiary

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** A1, A2, and A10 share the same author and the same interested party. A3, A4, A5, A8, A9 corroborate the general category (parallel divergent/convergent separation) and not the ADHD-specific mechanism (15-frame library, deepen pass). A4's diversity gain is at K=100, irrelevant to Han's 2-to-5-agent dispatches.
- **Result:** Confirmed
- **Impact:** The recommendation was rewritten to mark the curated 15-frame library and the deepen pass as single-sourced and unvalidated at Han's scale, and to stop describing the article's specific mechanisms as "independently corroborated."

### V2: Han's `research` skill already implements branch isolation — the novelty claim is overstated

- **Strategy:** Challenge the Assumptions
- **Investigation:** `plugin/skills/research/SKILL.md` lines 24 and 100 explicitly withhold codebase contents, repository paths, and operator context from the web-facing angle. That is the same anchoring-prevention motivation the article gives.
- **Result:** Partially Refuted
- **Impact:** The recommendation no longer claims Han uses branch isolation nowhere. O3's framing was rewritten to acknowledge that the isolation half is already present in `research`.

### V3: Han's domain specialists are functionally equivalent to ADHD's curated expert frames, and A5 contradicts the frame-quality claim

- **Strategy:** Challenge the Assumptions
- **Investigation:** `adversarial-security-analyst`, `devops-engineer`, `user-experience-designer`, and `data-engineer` each generate from a distinct epistemic posture with domain-scoped briefs in parallel. A5 finds ordinary personas outperform curated expert personas — the same class as ADHD's frame library.
- **Result:** Partially Refuted
- **Impact:** O3 is downgraded out of the recommended path. The frame-library design choice is now flagged as in tension with A5 in both Han's existing specialists and any proposed retrofit.

### V4: A7 directly contradicts the highest-confidence application points (plan-a-feature, ADR)

- **Strategy:** Challenge the Evidence
- **Investigation:** A7 (CHI 2025, 280 designers) found no statistically significant improvement when using LLMs for problem reframing in human-in-the-loop contexts. `plan-a-feature` and `architectural-decision-record` are explicitly human-in-the-loop skills with user gates at decision points.
- **Result:** Refuted (the original confidence ranking)
- **Impact:** The recommendation no longer presents `plan-a-feature` and `architectural-decision-record` as the most confident application points. They are flagged as carrying the direct A7 caveat. The "apply with caution to research and investigate" framing was inverted: `research` already has branch isolation; the human-in-the-loop planning skills are the ones to be cautious about.

### V5: Cost multiplication is not accounted for, and the proposal violates Han's own YAGNI rule

- **Strategy:** Challenge the Fix
- **Investigation:** A large `iterative-plan-review` runs up to 3 rounds × 5 agents = 15 calls. Adding 5 isolated frame branches per round doubles that. Han's YAGNI rule (referenced across every planning skill) requires a measured gap or named direct dependency before adding parallel work.
- **Result:** Partially Refuted
- **Impact:** O4 (gather Han-specific evidence first) was added as the methodological prerequisite. Any structural change is now gated on a demonstrated Han-specific failure mode, not on the article's general diagnosis.

### V6: The premature convergence diagnosis is not evidenced for Han's pipeline specifically

- **Strategy:** Challenge the Evidence
- **Investigation:** `plan-a-feature` Step 6 dispatches parallel specialists (security, UX, devops, edge-case-explorer, test-engineer) who independently challenge the draft spec from their postures with no shared live context. Step 7 compiles findings and gates resolution on the user. No evidence is cited that this architecture actually exhibits premature convergence in production output.
- **Result:** Refuted (the original assumption that Han needs the article's remedy)
- **Impact:** The recommendation was rewritten into the No-clear-winner form with O4 as the prerequisite step. All proposed structural changes are now described as solutions whose problem has not been demonstrated in Han.

### V7: `architectural-decision-record` already runs parallel multi-posture review of alternatives

- **Strategy:** Challenge the Evidence
- **Investigation:** `plugin/skills/architectural-decision-record/SKILL.md` lines 74–82 dispatch three parallel agents (architect, risk-analyst, junior-developer) against the proposed decision and considered alternatives, each from a distinct posture.
- **Result:** Partially Refuted
- **Impact:** O2 was narrowed to the gather-alternatives sub-step (ADR Step 3, before the review dispatch), the only place the proposed addition would not duplicate work already happening.

### V8: A4's effect sizes are at K=100 and do not translate to Han's dispatch scale

- **Strategy:** Challenge the Evidence
- **Investigation:** A4's 51.5–63.5% novelty improvement and 72% diversity advantage are measured at K=100. Han dispatches 2–5 agents per skill round. No artifact in the registry provides evidence for frame-based diversity benefit at K=2–5.
- **Result:** Refuted (the "independently corroborated" framing for the Han-scale benefit)
- **Impact:** The recommendation explicitly marks the academic effect-size evidence as inapplicable at Han's dispatch scale. The corroboration claim is narrowed to the general principle of divergent-convergent separation, not to a quantitative benefit at K=3–5.

### Adjustments Made

The original draft recommendation positioned the article's ideas as confidently applicable to `plan-a-feature` and `architectural-decision-record`. After validation, the recommendation was rewritten into the No-clear-winner form. The confidence ranking across application points was inverted. The frame-based dispatch idea for `research` (O3) was demoted out of the recommended path due to V2 (already present in part) and V3 (contradicted by A5). An empirical-first option (O4) was added because V5 and V6 found that none of the proposed changes have a measured Han-specific problem to solve.

### Confidence Assessment

- **Confidence:** Low to medium
- **Remaining Risks:**
  - The recommendation rests heavily on validation findings about Han's existing architecture. The validator did not read `han.plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md`, which may contain explicit cost-per-call reasoning that would further constrain or enable the recommendation.
  - A9 (BuildML practitioner blog) is unvetted — practitioner-blog provenance is not validated.
  - No artifact in the registry provides evidence for frame-based diversity benefit at K=2–5, which is the only scale at which Han dispatches. The principle is corroborated; the Han-scale benefit is not.
  - The recommendation declines to act in part because there is no Han-specific evidence of the diagnosed problem. If such evidence does exist and was not surfaced in this research round, the No-clear-winner posture would be wrong.

## Artifacts

### A1: ADHD — Parallel Divergent Ideation for Coding Agents (article)

- **Link / location:** https://uditakhourii.github.io/adhd/
- **Retrieved:** 2026-05-27
- **Trust class:** web — interested party (author is the tool's developer)
- **Summary:** Methodology paper plus tool announcement proposing a two-phase inference-time method: parallel isolated LLM calls under 15 hand-authored cognitive frames (diverge), followed by a separate critic phase that scores and deepens top survivors (focus). Reports a self-judged win against single-shot baseline on six engineering problems. MIT-licensed Node/TypeScript implementation. Explicitly self-labeled "Preprint · v0.1 · 2026-05-25" on the page — no peer-reviewed journal or conference venue is cited; only "Udit Akhouri Raj" is listed as author, with a GitHub link and no institutional affiliation given on the page.
- **Evidence status:** single source for the specific mechanism (15-frame library, deepen pass, isolation-superiority-over-ToT claim); the general principles it advances are corroborated by A3, A4, A5, A8, A9. The "preprint, no peer review" status is verified directly from the page text and corroborated by absence of any peer-reviewed publication search hit (see A10).

### A2: GitHub repository — UditAkhourii/adhd

- **Link / location:** https://github.com/uditakhourii/adhd
- **Retrieved:** 2026-05-27
- **Trust class:** web — interested party (same author as A1)
- **Summary:** Repository for the tool described in A1. Confirms implementation as a Claude Code skill plus npm package. Most recent commit dated 2026-05-25.
- **Evidence status:** corroborates A1's implementation claims; not independent of A1.

### A3: Augmenting Divergent and Convergent Thinking in the Ideation Process (Fischer-Brandies et al., Fraunhofer / ECIS 2024)

- **Link / location:** https://aisel.aisnet.org/ecis2024/track20_adoption/track20_adoption/13/
- **Retrieved:** 2026-05-27
- **Trust class:** web — peer-reviewed conference paper
- **Summary:** Builds an LLM-based agent system explicitly targeting divergent and convergent phases in organizational ideation. Validated through 10 expert interviews. Confirms two-phase generator-critic separation as a viable design pattern in an independent context.
- **Evidence status:** corroborates A1's two-phase claim; independent.

### A4: Divergent-Convergent Thinking in Large Language Models for Creative Problem Generation (CreativeDC, arXiv 2024)

- **Link / location:** https://arxiv.org/html/2512.23601v1
- **Retrieved:** 2026-05-27
- **Trust class:** web — arXiv preprint
- **Summary:** Decouples divergent (unconstrained exploration) from convergent (constraint satisfaction) phases in LLM reasoning. Reports 51.5–63.5% novelty improvement and 72% diversity advantage *at K=100 parallel samples*. Uses persona simulation for perspective diversity.
- **Evidence status:** corroborates A1's two-phase principle; the cited effect sizes are at K=100 and do not translate to Han's K=2–5 dispatch scale.

### A5: Examining and Addressing Barriers to Diversity in LLM-Generated Ideas (arXiv 2025)

- **Link / location:** https://arxiv.org/html/2602.20408
- **Retrieved:** 2026-05-27
- **Trust class:** web — arXiv preprint
- **Summary:** Identifies two failure modes causing LLM idea homogeneity: within-session fixation (autoregressive anchoring) and cross-session knowledge aggregation (mode collapse). Proposes ordinary persona prompting and Chain-of-Thought to address each. Finds combined approach yields LLM diversity exceeding humans by 26%. Reports *ordinary* personas (random backgrounds) outperform *curated expert* personas.
- **Evidence status:** corroborates A1's premature convergence diagnosis; partially *contradicts* A1's curated-expert frame design.

### A6: Tree of Thoughts: Deliberate Problem Solving with Large Language Models (Yao et al., NeurIPS 2023)

- **Link / location:** https://proceedings.neurips.cc/paper_files/paper/2023/file/271db9922b8d1f4dd7aaef84ed5ac703-Paper-Conference.pdf
- **Retrieved:** 2026-05-27
- **Trust class:** web — peer-reviewed NeurIPS paper
- **Summary:** Multi-branch reasoning with shared-context evaluation and backtracking. Outperforms Chain-of-Thought on structured search problems (74% vs 4% on Game of 24). The prior art A1 distinguishes itself from on the isolation mechanism.
- **Evidence status:** independent; the comparison to A1 is A1's framing, not A6's claim.

### A7: No Evidence for LLMs Being Useful in Problem Reframing (CHI 2025)

- **Link / location:** https://arxiv.org/html/2503.01631v1
- **Retrieved:** 2026-05-27
- **Trust class:** web — peer-reviewed CHI 2025
- **Summary:** Controlled study of 280 design professionals found no statistically significant improvement in frame novelty or usefulness when using LLMs for problem reframing, across direct, structured, and free-form integration conditions. LLM use *amplified* the expert-novice gap.
- **Evidence status:** independent; directly contradicts the human-in-the-loop applications of A1's reframing mechanism.

### A8: Scaffolding Creativity — How Divergent and Convergent LLM Personas... (arXiv 2024)

- **Link / location:** https://arxiv.org/pdf/2510.26490
- **Retrieved:** 2026-05-27
- **Trust class:** web — arXiv preprint
- **Summary:** Matching AI persona (divergent vs. convergent) to task phase improves human-AI collaborative creative outcomes vs. single-persona approaches.
- **Evidence status:** corroborates A1's phase-separation claim in a human-AI collaboration context; independent.

### A9: Test-Time Compute Scaling for LLM Agents (BuildML)

- **Link / location:** https://buildml.substack.com/p/test-time-compute-scaling-a-practical
- **Retrieved:** 2026-05-27
- **Trust class:** web — practitioner blog (provenance not validated)
- **Summary:** Practitioner guide establishing the proposer-verifier split as the foundational test-time compute pattern. Recommends difficulty-conditioned strategies.
- **Evidence status:** corroborates A1's architectural pattern; provenance unvetted.

### A10: Udit Akhouri — author background (multi-source)

- **Link / location:**
  - https://www.crunchbase.com/person/udit-raj-akhouri (third-party profile)
  - https://www.linkedin.com/in/udit-akhouri-10160a168/ (self-reported profile)
  - Cross-referenced web search results (2026-05-27) including Crunchbase, LinkedIn, and Product Hunt
- **Retrieved:** 2026-05-27
- **Trust class:** web — mixed (third-party profile + self-reported profile)
- **Summary:** Identifies the author of A1 as a CS undergraduate at IIT Patna (joined June 2023), founder of multiple AI startups over a 4-year period (Sttabot AI, Aentor, Brane Labs, Supervised AI; previously CTO of Bully AI, acquired March 2021). His other technical paper, "Real-time Retrieval Argumentation for Large Language Models," is published on SSRN — another preprint repository, not a peer-reviewed venue. No peer-reviewed publication by this author is surfaced by web search.
- **Evidence status:** Independent confirmation across at least three sources (Crunchbase + LinkedIn + indirect mentions on Product Hunt and project pages) for the "CS undergraduate at IIT Patna" and "startup founder" facts. The "no peer review" status is corroborated by A1's own "Preprint v0.1" self-labeling and by the absence of peer-reviewed hits in search. Background only on the author; not independent of A1 in the sense that all of these sources describe the same person, but the facts about that person are multi-sourced.

### A11: Han plugin skills and agents inventory (codebase-explorer)

- **Link / location:** `plugin/skills/` and `plugin/agents/` in the Han repository at the time of research
- **Retrieved:** n/a (codebase anchor)
- **Trust class:** codebase
- **Summary:** Structured map of 20 skills and 22 agents. Confirms parallel fan-out as Han's dominant composition shape; confirms explicit generator-critic separation in `investigate`, `research`, `gap-analysis`; confirms branch isolation (web-vs-codebase) in `research`; confirms domain specialists (`adversarial-security-analyst`, `devops-engineer`, `user-experience-designer`, `data-engineer`) as functionally equivalent to ADHD-style frame-based branching.
- **Evidence status:** trusted current-state anchor; load-bearing for V2, V3, V6, V7.

## References

- **A1** — ADHD: Parallel Divergent Ideation for Coding Agents. https://uditakhourii.github.io/adhd/ (retrieved 2026-05-27).
- **A2** — UditAkhourii/adhd repository. https://github.com/uditakhourii/adhd (retrieved 2026-05-27).
- **A3** — Fischer-Brandies, Meierhöfer, Protschky. Augmenting Divergent and Convergent Thinking in the Ideation Process: An LLM-Based Agent System. ECIS 2024. https://aisel.aisnet.org/ecis2024/track20_adoption/track20_adoption/13/ (retrieved 2026-05-27).
- **A4** — Divergent-Convergent Thinking in Large Language Models for Creative Problem Generation (CreativeDC). arXiv 2512.23601v1. https://arxiv.org/html/2512.23601v1 (retrieved 2026-05-27).
- **A5** — Examining and Addressing Barriers to Diversity in LLM-Generated Ideas. arXiv 2602.20408. https://arxiv.org/html/2602.20408 (retrieved 2026-05-27).
- **A6** — Yao et al. Tree of Thoughts: Deliberate Problem Solving with Large Language Models. NeurIPS 2023. https://proceedings.neurips.cc/paper_files/paper/2023/file/271db9922b8d1f4dd7aaef84ed5ac703-Paper-Conference.pdf (retrieved 2026-05-27).
- **A7** — No Evidence for LLMs Being Useful in Problem Reframing. CHI 2025. arXiv 2503.01631v1. https://arxiv.org/html/2503.01631v1 (retrieved 2026-05-27).
- **A8** — Scaffolding Creativity: How Divergent and Convergent LLM Personas Scaffold Human-AI Collaboration. arXiv 2510.26490. https://arxiv.org/pdf/2510.26490 (retrieved 2026-05-27).
- **A9** — Test-Time Compute Scaling: A Practical Guide. BuildML. https://buildml.substack.com/p/test-time-compute-scaling-a-practical (retrieved 2026-05-27).
- **A10** — Udit Akhouri profile. Crunchbase. https://www.crunchbase.com/person/udit-raj-akhouri (retrieved 2026-05-27).
- **A11** — Han plugin skills (`plugin/skills/`) and agents (`plugin/agents/`) at the time of research. Codebase anchor.
