# Research: Would the ADHD parallel divergent ideation model fit any part of Han, with frames, personas, and domain specialists kept structurally distinct?

A re-research of the original question at [adhd-application-to-han.md](./adhd-application-to-han.md), redone after [GitHub issue #17](https://github.com/UditAkhourii/adhd/issues/17) (filed by the ADHD article's author) flagged that the prior round conflated three distinct mechanisms. Also resolves an apparent tension between the persona finding and [han.plugin-builder/skills/guidance/references/specialization-and-model-selection.md](../../han.plugin-builder/skills/guidance/references/specialization-and-model-selection.md). Evidence mode: **strict**.

## Summary

The article advocates three techniques for getting more diverse, less convergent answers out of LLMs: run multiple branches with no shared context, route each branch through a different cognitive frame to force structural variety, and split generation from criticism (A1). The prior research conflated cognitive frames with personas and rejected the curated-frame design partly on that basis. That conflation is wrong: frames (vantage operators forcing structural reframing) are not the same mechanism as personas (identity cues that anchor a model's sampling distribution). The author's GitHub issue distinguishing the two is correct in substance, even though it comes from an interested party (A2).

The conclusion of the prior report still holds, but the reasoning had to be rebuilt. The persona finding that motivated the prior rejection of curated frames does not apply to frames at all; it studied named celebrity personas against heterogeneous-background personas in a generative ideation task (A3). What was thought to be a clean contradiction was a category mistake. The apparent tension with Han's specialization-and-model-selection doc is also not real, because that doc is about narrow-task accuracy, not ideation diversity (A18, A27).

What does the evidence actually support? Branch isolation has independent prior art and is already used in Han where it matters most (A26 confirms). Generator-critic separation is well-supported and is also already in Han, though sequentially rather than in parallel. The specific contribution that ADHD adds — curated off-domain frames as parallel isolated LLM calls for trap detection — has no independent corroboration outside the article itself (A1). One recent academic study found that LLMs, unlike humans, show no statistically significant lift from cross-domain mapping interventions, because their baseline novelty is already higher than humans' (A8). That is partial counter-evidence for the LLM-specific value of vantage-operator forcing, though it tests single-shot cross-domain prompts, not parallel multi-frame setups.

A finding that is new to this round and changes the picture: Han already has three vantage-operator-class agents (adversarial-validator, junior-developer, project-manager) that force epistemic rather than off-domain reframing. The gap ADHD might genuinely fill is off-domain metaphorical reframing specifically (think like an ant colony, a regulator, a speedrunner), which Han does not do.

**Bottom line: no clear winner, for largely the same reason as before but with corrected rationale.** The case for adopting ADHD's specific mechanisms wholesale is weaker than the article suggests and has no independent empirical support at Han's dispatch scale. The case against is also weaker than the prior report claimed, because the persona finding it leaned on does not apply to frames. The most defensible next step is the same: gather Han-specific evidence about whether premature convergence actually occurs in Han's outputs before retrofitting any mechanism. **Solidity: low to medium overall — the conclusion rests on multiple corroborated principles, but the specific Han-bearing recommendation is gated on evidence that has not been gathered yet.**

## Prompt Used

The following prompt was used to generate the report:

> we're going to look at the research in docs/research/adhd-application-to-han.md again. specifically, i need you to distinguish between a persona, domain specialist, and "frame" from the ADHD source article using https://github.com/UditAkhourii/adhd/issues/17 as a source for the distinguishing. from here, i need you to /research the original question of whether the ADHD model in the original source material would be a good fit for any part of Han. this is likely going to be a full rewrite of the report and i would like it saved as a new file named adhd-application-to-han.with-disambiguation.md - the goal is not to find a way to say that this ADHD model would fit well with Han, but to provide a more accurate reference perspective for the research, and to see how that research changes with this perspective. in addition to this, i want you to clarify the current A5 point that was made in this sentence: "Its most distinctive idea — a curated library of 15 cognitive frames (A1) — is directly contradicted by an independent academic finding that *ordinary* personas outperform *curated expert* personas (A5)". from other research i did with you in han.plugin-builder/skills/guidance/references/specialization-and-model-selection.md - but i might be misunderstanding something between these two reports. again, i do not want confirmation bias in this. i want honest research to resolve my questions and see what the results of the research will be with these adjustments and perspectives

The `/research` skill comes from the Han plugin, in this repository.

## Research Results

### Three mechanisms, structurally distinct in the academic literature

The disambiguation issue (A2) names three categories that the prior research treated as one. The new evidence supports the structural distinction, though the formal naming of the third category is weaker than the issue implies.

**Personas** in the LLM literature are identity cues: simulated user attributes injected as system-message context. The mechanism is anchoring the model's sampling distribution in a distinct region of semantic space (A3, A5). The paper the prior report relied on (arXiv 2602.20408) compares heterogeneous-background personas — life-context sketches drawn from the Tencent Personas dataset — against a specific kind of curated persona: named celebrity innovators (Steve Jobs, Elon Musk, Harpreet Rai, Chip Wilson). The paper's stated mechanism is sampling-region diversity (A3). The prior research described this as "celebrity cluster density in the training distribution," which is an inference, not the paper's own stated mechanism. The distinction matters: A3 does not claim domain expertise per se hurts diversity. It claims named celebrities cluster in semantically dense training regions, narrowing the sampling distribution (A3, V3).

**Domain specialists** are role-grounded reviewers with domain-scoped briefs who read an artifact under review. Han's `adversarial-security-analyst`, `devops-engineer`, `user-experience-designer`, and similar agents are this category (A26). The literature treats role-prompting and domain-specialist prompting as adjacent but not always cleanly delineated from persona prompting (A6, A15, A17, A21). For *reviewer-role* tasks specifically, the evidence shows role-based prompting has modest effects: PRISM finds expert personas improve alignment-dependent tasks and damage accuracy-dependent tasks at the weights level via LoRA adapters (A16, A22), though whether this transfers to prompt-only role assignment is not directly established (V9).

**Vantage operators (frames)** force structural re-framing of the problem itself from a deliberately off-domain perspective. The foundational pre-LLM ancestor is De Bono's Six Thinking Hats (1985), which explicitly defines structural thinking modes rather than identities and requires mode isolation to prevent contamination (A4). Cross-domain analogical reasoning is a related strand in the LLM literature (A8, A9). The closest direct LLM implementation is PTFA, which implements De Bono's hats as parallel isolated agents, but is explicitly a pilot study identifying open research challenges in its divergent phase (A7) [V5 caveat].

The taxonomy itself is consistent with the academic literature but its specific articulation in this report rests on a single motivated source (A2, filed by the ADHD article's author). Independent papers don't draw a formal three-way distinction; they implicitly use different mechanisms but rarely contrast all three side by side [single-source taxonomy].

### The prior report's A3 contradiction was misapplied

The prior report claimed A3 ("ordinary personas outperform curated expert personas") directly contradicts ADHD's 15-frame library. Per the disambiguation, this is a category mistake. A3 measures generative ideation diversity using identity-based persona prompts; the "curated expert personas" it tests against are celebrity innovators, not anonymous domain roles and not vantage operators (A3, V3). ADHD frames are off-domain structural-mode operators, not identity prompts. A3's finding doesn't bear on whether off-domain frames help or hurt ideation diversity, because A3 doesn't test off-domain frames.

A3 doesn't directly bear on Han's domain-specialist reviewers either, because A3 measures generative diversity, not reviewer quality. The closest evidence for the reviewer-role question is arXiv 2507.08350 (SIGDIAL 2025), which finds that increasing critic-side diversity improves the feasibility of final proposals in multi-agent research ideation (A15). The validator caught that the prior synthesis had misread the direction of this paper: it is not neutral evidence for Han's existing specialist pattern; it actively supports critic-side diversity as a beneficial mechanism (V1). For Han specifically, what A15 supports is the *diversity* of critics, not the choice to use domain specialists rather than vantage operators in that role.

A separate paper sometimes cited in this space (arXiv 2401.16310, "Security Code Review with LLMs") was claimed in the synthesis to find minimal accuracy impact from role/persona prompting. The validator could not verify this specific claim from the paper's abstract — the abstract addresses CoT, CWE lists, and commit-message prompts, not persona/role prompting as an isolated variable (V2). That claim is treated as unverified in this report.

### The apparent tension with specialization-and-model-selection.md is not a tension

The Han-internal doc (A27) argues that specialized prompts (named heuristics, fixed rubrics, narrow domain framing) shift work from inference-time compute to prompt-time design, letting smaller models match larger ones on narrow tasks. Its cited evidence — Orq.ai on classification, arXiv 2301.12726 on multi-step math reasoning, Amazon Science and arXiv 2510.07772 on task decomposition — measures narrow-task accuracy (A18, A19, A20, A27). None of those sources measure ideation diversity.

A3 measures ideation diversity for divergent thinking. The two address non-overlapping task types with non-overlapping mechanisms: prompt specialization narrows the output distribution to improve accuracy on a defined task; A3's ordinary-persona finding broadens the input sampling distribution to improve diversity for an open-ended task. PRISM (A16) is the bridge sometimes invoked here: expert personas help alignment-dependent tasks, hurt accuracy-dependent tasks. PRISM's mechanism is weights-level LoRA adaptation, not prompt-only role specification (V9), so its transfer to Han's prompt-level specialist agents is not certain.

The validator caught one real tension at a specific insertion point: if Han's curated-expert specialists were repurposed for *alternatives-generation* (a divergent-ideation task), they would be exactly the kind of curated-expert prompting that narrows the sampling distribution. A3's mechanism predicts this would hurt diversity. The tension is local to that hypothetical use, not a general contradiction (V6).

### What evidence supports ADHD's specific mechanisms

**Branch isolation** has the strongest independent support. PTFA (A7) and the practitioner article on Six Hats prompting (A12) independently identify context contamination as a problem in single-thread parallel reasoning and recommend isolation. Han already does this in `research` (A26, lines 24 and 100 of `plugin/skills/research/SKILL.md`), `investigate`, `architectural-analysis`, and `gap-analysis` (A26). The web-vs-codebase isolation in Han's research skill is a strong instance of the same anchoring-prevention motivation.

**Generator-critic separation** is well-corroborated by independent sources at the principle level: CreativeDC tests sequential divergent-then-convergent prompting and reports significant novelty gains (A11), arXiv 2503.12499 implements it as parallel hat-role agents (A7, pilot-study caveated), and the practitioner blog identifies it as standard pattern (A12). Han implements it sequentially in `investigate`, `research`, and `gap-analysis` (A26). It does not implement parallel generation-critique with truly incompatible prompts.

**Vantage operators (curated off-domain frames)** have the thinnest independent LLM-specific support. The strongest pieces are De Bono 1985 (pre-LLM, human framework, A4), PTFA as a pilot implementation (A7, V5 caveat), cross-domain mapping in A8 and A9, and the practitioner article A12. The cross-domain mapping evidence in A8 (March 2026, n=140 humans + 7 LLMs) is mixed: distant source domains predict more original ideas for both humans and LLMs, but LLMs show no statistically significant additional lift from cross-domain mapping compared to their baseline, because LLM baseline novelty already exceeds humans' (A8). This is a partial negative signal for LLM-specific vantage-operator forcing, though it tests single-shot prompts, not parallel multi-frame setups, so its bearing on ADHD's specific parallel-isolated-frames pattern is partial (V4).

A different paper sometimes invoked in this space, arXiv 2503.01631 (CHI 2025), found no evidence LLMs improve problem-framing quality for 280 designers and found LLM use widened the expert-novice gap (A10). This bears specifically on the human-in-the-loop applications.

**The specific ADHD combination** — curated off-domain frames + parallel isolation + generator-critic + trap detection as the outcome — has no independent corroboration. Each component has prior art; the combination has only A1. Tech journalism (A14) reports outside experts say the benchmark claims need more testing. The article's self-evaluation is six engineering problems with same-model LLM-as-judge.

### Han already has vantage-operator-class agents

The validator surfaced a finding the original codebase exploration missed: Han already has three agents that are closer to vantage operators than to domain specialists (A26, V7). `adversarial-validator` operates from a pessimistic-falsification posture with no domain credential. `junior-developer` operates from a generalist-simplification posture and explicitly disavows specialist analysis. `project-manager` operates from an evidence-enforcement and facilitation posture. These are epistemic-stance operators, not domain readers.

What Han doesn't have, that ADHD's frame library specifically provides, is *off-domain metaphorical reframing* (think like an ant colony, a hardware engineer, a regulator) applied to non-matching problems. Whether that specific kind of frame helps in any Han skill is the un-tested question. Han's existing vantage operators handle epistemic posture; ADHD's frames handle metaphorical-domain transposition.

### Where the evidence is thin and what would settle it

The central unanswered question is: does Han's current architecture exhibit premature convergence in production output? Without that evidence, every proposed structural change is a solution for a problem that has not been demonstrated to exist in Han specifically. None of the academic sources measure Han's pipeline. The article's diagnosis (A1) is generic; whether it applies to Han's specific multi-specialist parallel fan-out is unknown.

The second-largest gap is the absence of any peer-reviewed study testing curated structural frames against random perturbation, against domain specialists, against single-shot baseline, at K=2-5, on a problem set of at least 20-30 items, with human or blinded judges. Until that study exists, the specific claim that *curated* frames outperform other diversity interventions is uncorroborated.

## Options to Consider

The four options from the prior report carry forward, with revised evidence bases.

### O1: Adopt nothing; Han already implements the well-corroborated principles

- **What it is:** Treat the article (A1) as confirmation that the patterns Han already uses — parallel fan-out, generator-critic separation, web-vs-codebase isolation in `research`, three vantage-operator-class agents (adversarial-validator, junior-developer, project-manager) — are well-founded. Make no structural changes.
- **Trade-offs:** Costs nothing. Forgoes any potential benefit if Han's outputs *do* exhibit premature convergence symptoms that the existing adversarial review fails to catch (A1's diagnosis; not evidenced for Han). Leaves untested whether off-domain metaphorical frames (the one ADHD-specific contribution Han doesn't replicate) would add anything.
- **Rests on:** (A26) Han already implements branch isolation, generator-critic separation, and three vantage-operator-class agents; (A1) the symptom ADHD targets is not evidenced for Han.
- **Evidence status:** stronger than in the prior report — the validator confirmed Han has more of the ADHD pattern set than was originally credited

### O2: Narrow application — add branch isolation as an opt-in for `architectural-decision-record` alternatives generation

- **What it is:** During the gather-alternatives sub-step of `architectural-decision-record` (the step before architectural review dispatches), optionally fan out 3–5 isolated context-light branches that generate alternative decisions, then merge into the Alternatives Considered section the existing review agents stress-test (A26). Default off; user opts in for high-stakes decisions.
- **Trade-offs:** Targets a real decision point where the cost (a few extra calls at ADR time) is bounded and where the alternatives-generation step is currently single-pass. Costs roughly 3–5× ADR generation time and call budget when on. The validator surfaced a real local tension: if these isolated branches use Han's existing curated-expert specialist agents, A3's mechanism predicts they will narrow the sampling distribution and hurt diversity. The branches need to be either anonymous/generalist or use deliberately off-domain framing for the diversity benefit to materialize (V6). Independent corroboration for the specific benefit at K=3–5 is absent.
- **Rests on:** (A3, A11, A12) general support for divergent-generation phase before convergent review; (A1) the specific mechanism, single-source.
- **Evidence status:** principle corroborated; specific Han-scale benefit single-source; agent-roster choice matters and changes the prediction

### O3: Frame-based dispatch override in `research` for genuinely ideation-shaped questions

- **What it is:** When a user marks a `research` question as ideation-shaped, allow `research-analyst` angles to be dispatched by cognitive frame (regulator, on-call, inversion) (A1) rather than by domain (A26). Web-vs-codebase isolation already exists (A26); this adds frame diversity on top.
- **Trade-offs:** The smallest possible change because the isolation half is already present (A26). The prior report rejected this on A3 grounds; the disambiguation removes that specific rejection, but two other rejections remain: A8 finds LLMs show no statistically significant lift from cross-domain mapping compared to their baseline (a partial negative signal at K=1, A8); A10 found no evidence LLMs help with problem reframing in human-in-the-loop contexts (A10). Han users would have to maintain or accept a frame library (A1's design).
- **Rests on:** (A1) the frame library design; (A4, A7) De Bono and PTFA as prior art for the mechanism class; (A8, A10) partial counter-evidence for LLM-specific benefit.
- **Evidence status:** principle partially corroborated; specific design uncorroborated; partial counter-evidence in the LLM-specific literature

### O4: Empirical first — gather Han-specific evidence before adopting anything

- **What it is:** Before changing any skill, examine real outputs from `plan-a-feature` and `architectural-decision-record` runs to determine whether premature convergence (A1) actually occurs in Han's pipeline at a rate the existing adversarial review fails to catch. Only then design a targeted intervention.
- **Trade-offs:** Slowest. Requires capturing comparable runs and judging their outputs. Avoids importing a remedy without evidence the disease is present. Honors Han's own YAGNI rule (A26 — every planning skill applies it; an addition without a measured gap fails the test).
- **Rests on:** the prior report's validation finding that the premature convergence diagnosis is not evidenced for Han's pipeline; Han's own YAGNI rule (A26), applied across every planning skill.
- **Evidence status:** corroborated as a methodology

## Recommendation

- **Recommendation:** **No clear winner.** The disambiguation corrects the prior report's reasoning in significant ways — frames are not personas, the A3 finding doesn't bear on either ADHD frames or Han's domain specialists in the way the prior report claimed, and there is no real tension between A3 and Han's specialization-and-model-selection doc. But correcting a mistaken negative does not introduce a positive. The case for adopting ADHD's specific mechanisms remains single-sourced and untested at Han's dispatch scale, and one independent LLM-specific finding (A8) is partially negative for the vantage-operator mechanism in LLMs.

  The lowest-regret move is unchanged: **O4 first, then O2 if O4 surfaces evidence**. If a Han-specific premature-convergence symptom is found, the narrowest defensible intervention is branch-isolated alternatives generation in ADR (O2), with the caveat that the isolated branches must use anonymous or generalist prompts rather than Han's existing curated-expert specialists — otherwise A3's mechanism predicts they will narrow rather than broaden the sampling distribution (V6).

  **O1 is more defensible than the prior report credited.** Han already implements branch isolation, generator-critic separation, and three vantage-operator-class agents (adversarial-validator, junior-developer, project-manager). The specific ADHD contribution Han doesn't replicate is off-domain *metaphorical* reframing (think like an ant colony). Whether that specific kind of frame is worth adding is an open question with thin independent evidence.

  **O3 is still not recommended.** The disambiguation removes the A3 contradiction, but A8's LLM-specific partial negative and A10's human-in-the-loop result remain. The principles Han needs most in research — branch isolation and generator-critic separation — are already implemented.

- **Evidence basis:** Corroborated evidence supports the *principles* the article advocates (A3, A5, A7, A11, A12, A18 — generator-critic separation, divergent-convergent phasing, parallel isolation as a recognized pattern). The article's *specific mechanisms* — the 15-frame library, the deepen pass, the claim of superiority over Tree-of-Thoughts — rest on A1 alone, written by the tool's author, with self-evaluation on six engineering problems and no peer review. The disambiguation taxonomy itself (A2) is filed by the same interested party and is plausible but single-source. The recommendation rests on (a) corroborated evidence that Han already implements the well-supported parts; (b) the un-rebutted finding from the prior report that no Han-specific evidence of premature convergence has been gathered; (c) A8's partial LLM-specific negative for vantage-operator forcing. The recommendation does not rest on reasoning alone — the un-corroborated state of the article's specific mechanisms and the un-measured state of Han's actual symptom are the load-bearing facts.

## Validation

### V1: arXiv 2507.08350 (A15) actively supports critic-side diversity, not neutral support for Han's existing pattern

- **Strategy:** Challenge the Evidence
- **Investigation:** The draft synthesis claimed A15 finds domain-specialist personas in critic role improve quality but not diversity. The paper's abstract says the opposite: "specifically increasing critic-side diversity within the ideation-critique-revision loop further boosts the feasibility of the final proposals," and broadly that "enlarging the agent cohort, deepening the interaction depth, and broadening agent persona heterogeneity each enrich the diversity of generated ideas." The synthesis read the direction of the result backwards.
- **Result:** Refuted
- **Impact:** A15 is no longer treated as neutral evidence for Han's existing domain-specialist pattern. It is treated as positive evidence for critic-side diversity as a mechanism. This weakens the case against O3 slightly, but does not flip it, because Han's existing critic-side roster (adversarial-validator + junior-developer + domain specialists where applicable) already provides heterogeneity along epistemic and domain axes; A15 does not specifically argue for vantage-operator critics over domain-specialist critics.

### V2: arXiv 2401.16310 persona-prompting claim cannot be verified from the abstract

- **Strategy:** Challenge the Evidence
- **Investigation:** A claim that persona/role prompting in security code review has minimal accuracy impact was attributed to arXiv 2401.16310. The paper's abstract addresses CoT prompting, CWE-list prompting, and commit-message prompting; it does not list persona/role prompting as an isolated tested variable. The supporting claim is unverified at the abstract level.
- **Result:** Refuted at the abstract level
- **Impact:** The synthesis was tightened to drop the unverified claim. The finding that A3 does not directly contradict Han's domain specialists now rests on the remaining adjacent evidence (A15 as positive for critic-side diversity, A16/PRISM with its weights-level caveat), not on this paper.

### V3: The three-mechanism taxonomy (A2) is filed by the article's author and is not independently corroborated

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The taxonomy distinguishing personas, domain specialists, and vantage operators was introduced via GitHub issue #17, filed by the same author as the article under evaluation. This is an interested party reframing adverse evidence against their own work. No independent academic source draws the three-way distinction as cleanly as the issue does. The "celebrity cluster density in the training distribution" mechanism attributed to A3 is an interpretation, not A3's stated mechanism — the paper says the mechanism is "anchoring generation in distinct regions of the semantic space."
- **Result:** Partially Refuted
- **Impact:** The taxonomy is treated as plausible and consistent with the underlying mechanisms in the literature, but is labeled single-source. The mechanism inference for A3 was corrected from "celebrity cluster density" to A3's own stated framing.

### V4: A8's cross-domain LLM negative result is from K=1 single-shot, not parallel multi-frame

- **Strategy:** Challenge the Evidence
- **Investigation:** A8 (arXiv 2603.19087) measures cross-domain forcing where each participant-product pair gets one source domain. It does not test running multiple frames in parallel and aggregating. The recommendation's framing as "partial negative" is the appropriate strength — it is evidence the LLM-specific lift from cross-domain prompting is smaller than the human-specific lift, but it is not a direct test of ADHD's parallel-multi-frame design.
- **Result:** Partially Refuted (of the strong reading)
- **Impact:** A8 is described as "partial" negative evidence throughout, not as definitive disconfirmation. The structural difference between K=1 cross-domain prompting and K=N parallel-isolated-frame prompting is named explicitly in the synthesis.

### V5: PTFA (A7) is a pilot study identifying open research challenges, not validated corroboration

- **Strategy:** Challenge the Evidence
- **Investigation:** A7's abstract says the pilot study "demonstrates capabilities" and identifies "future open research challenges such as optimizing scheduling and managing behaviors in divergent phase." This is qualitative demonstration, not quantitative corroboration of the mechanism's benefit.
- **Result:** Confirmed
- **Impact:** A7 is labeled with the pilot-study caveat throughout. The positive evidence stack for vantage operators rests primarily on De Bono 1985 (A4, pre-LLM), A15 (positive for critic-side diversity, mechanism not specifically frame-based), and A9 (analogical reasoning, K=1 not multi-frame). The independent LLM-specific empirical support for ADHD's specific mechanism is thinner than the article suggests.

### V6: There is a real local tension at the O2 insertion point if it uses Han's curated specialists

- **Strategy:** Challenge the Assumptions
- **Investigation:** The synthesis claimed no tension between A3 and the specialization-and-model-selection doc. That holds at the task-type level (different phenomena, different mechanisms). But A3's mechanism — curated experts narrow the sampling distribution and hurt diversity — predicts that using Han's existing curated-expert specialist agents for ADR *alternatives generation* (a divergent ideation task) would reproduce the failure mode. The O2 recommendation does not specify the agent roster.
- **Result:** Partially Refuted (of the "no tension" framing)
- **Impact:** O2's recommendation now carries the explicit caveat that the isolated branches must be anonymous, generalist, or deliberately off-domain for the diversity benefit to materialize. Reusing Han's curated specialists in this role would be predicted by A3 to hurt rather than help diversity.

### V7: Han already has three vantage-operator-class agents that the codebase exploration missed

- **Strategy:** Challenge the Assumptions
- **Investigation:** `adversarial-validator`, `junior-developer`, and `project-manager` are not domain specialists. They are epistemic-stance forcing functions — pessimistic-falsification, generalist-simplification, and evidence-enforcement postures respectively. They reframe rather than read-in-domain.
- **Result:** Refuted (the "Han has no vantage operators" framing)
- **Impact:** O1 is strengthened. The gap ADHD specifically fills is off-domain *metaphorical* reframing (think like an ant colony, a regulator) applied to non-matching problems, not epistemic-stance operators generally — Han already has those.

### V8: The new recommendation has the same shape as the prior recommendation — risk of confirmation bias dressed as evidence revision

- **Strategy:** Challenge the Assumptions
- **Investigation:** Both reports end at "no clear winner" with the same option ordering (O4 → O2 if symptom found → O1 if not, O3 not recommended). The new evidence removed a specific negative (A3 contradiction of frames) without adding a specific positive for adoption. Removing a negative does not change the balance toward adoption, only toward neutrality on that specific point.
- **Result:** Confirmed
- **Impact:** The recommendation is explicit that the conclusion is structurally the same as the prior report and that the disambiguation only corrects the rationale at specific points (the misapplied A3 contradiction, the false tension with the specialization doc, the codebase claim that Han has no vantage operators). The conclusion does not shift toward adoption because the evidence for adoption has not improved.

### V9: PRISM (A16) is LoRA-based, not prompt-only, and may not transfer to Han's runtime patterns

- **Strategy:** Challenge the Evidence
- **Investigation:** A16 measures expert-persona effects via gated LoRA adapters (weights-level fine-tuning). Han's specialists are prompt-only system messages at runtime. The "expert personas help alignment, hurt accuracy" finding may not transfer mechanism-for-mechanism to prompt-only role specification.
- **Result:** Partially Refuted (of using PRISM as a clean bridge)
- **Impact:** PRISM is cited with the LoRA caveat. The synthesis no longer treats it as a fully transferable bridge between A3 and the specialization-and-model-selection doc; the case that A3 and the specialization doc address different phenomena rests on the task-type and mechanism difference, not on PRISM transferring cleanly.

### Adjustments Made

The original draft synthesis was rewritten in five places after validation:

1. A15 was recharacterized from "neutral support for Han's existing pattern" to "positive support for critic-side diversity" (V1).
2. The arXiv 2401.16310 persona-prompting claim was dropped as unverified (V2).
3. The three-mechanism taxonomy was labeled single-source from the interested party, and the A3 mechanism description was corrected from inferred "celebrity cluster density" to the paper's own "anchoring in distinct semantic regions" framing (V3).
4. O2's recommendation now carries the explicit caveat about agent-roster choice (V6).
5. O1's evidence basis was strengthened to acknowledge Han's existing vantage-operator-class agents (V7).

The "no clear winner" recommendation survives the validation findings. The conclusion is explicit that it is structurally the same as the prior report and that the new round corrects rationale at specific points rather than shifting the balance.

### Confidence Assessment

- **Confidence:** Low to medium
- **Remaining Risks:**
  - The disambiguation taxonomy itself is single-source from the article's author (A2). No independent academic paper formalizes the three-way distinction as cleanly as the issue does. The mechanisms exist separately in the literature but their formal contrast is asserted by an interested party.
  - The central empirical question — does Han actually exhibit premature convergence in production output? — is still unanswered. Every proposed change is gated on evidence that has not been gathered.
  - The independent empirical support for vantage-operator forcing specifically in LLMs is thinner than the article implies. The strongest pieces (PTFA pilot study, cross-domain mapping at K=1) carry significant caveats.
  - O2's agent-roster choice is the specific implementation question that determines whether the option helps or hurts. The recommendation flags this but does not resolve it.
  - The PRISM bridge for the A3-vs-specialization-doc tension question is partial; the case for "different phenomena" holds without PRISM but the cleanest cross-mechanism support would come from a prompt-only replication that has not been found.
  - This round did not independently verify the more peripheral artifacts from the prior report (Fischer-Brandies ECIS 2024, "Scaffolding Creativity"). Their characterizations carry over from the prior round and were not re-validated here.

## Artifacts

### A1: ADHD — Parallel Divergent Ideation for Coding Agents (article)

- **Link / location:** https://uditakhourii.github.io/adhd/ (also mirrored at https://adhdstack.github.io/)
- **Retrieved:** 2026-05-27
- **Trust class:** web — interested party (author is the tool's developer)
- **Summary:** Self-published "Preprint v0.1" by Udit Akhouri Raj proposing parallel divergent ideation: N isolated LLM calls under structurally different cognitive frames, then a critic phase that scores and deepens top survivors. Frames are explicitly described as "vantage-point operators, not credentials." Reports wins on 5 of 6 engineering problems against single-shot baseline using same-model LLM-as-judge.
- **Evidence status:** single source for the specific mechanism (15-frame library, deepen pass, isolation-superiority-over-ToT claim). The principles it advances are corroborated separately by A3, A4, A7, A8, A9, A11, A12, A15.

### A2: GitHub Issue #17 — distinguishing personas, domain specialists, and frames

- **Link / location:** https://github.com/UditAkhourii/adhd/issues/17
- **Retrieved:** 2026-05-27
- **Trust class:** web — interested party (filed by the article's author)
- **Summary:** Asserts the prior research conflated three structurally distinct mechanisms: personas (A3's identity-based prompts), domain specialists (Han's role-grounded reviewers), and ADHD frames (off-domain vantage operators that reframe the problem itself). Proposes a §2 clarification in the article. The taxonomic claim is plausible and consistent with the academic literature but is not independently formalized as a three-way contrast.
- **Evidence status:** single source (filed by the interested party); the underlying mechanism differences exist separately in the literature

### A3: Examining and Addressing Barriers to Diversity in LLM-Generated Ideas (arXiv 2602.20408)

- **Link / location:** https://arxiv.org/abs/2602.20408 (HTML at https://arxiv.org/html/2602.20408)
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint (De Freitas, Nave, Puntoni)
- **Summary:** Studies fitness-product ideation diversity with GPT-4o, comparing heterogeneous-background personas (Tencent Personas dataset) against named celebrity innovators (Steve Jobs, Elon Musk, Harpreet Rai, Chip Wilson). Reports ordinary personas substantially outperform creative-entrepreneur personas (210 unique combinations vs 164). The paper's stated mechanism is anchoring in distinct semantic-space regions. The paper does not test reviewer-role tasks, does not test off-domain vantage operators, and does not test domain-specialist (non-celebrity) role prompts.
- **Evidence status:** corroborated by A5 (consistent persona-specificity finding); single-source for the specific quantitative claim

### A4: De Bono's Six Thinking Hats (1985)

- **Link / location:** https://en.wikipedia.org/wiki/Six_Thinking_Hats
- **Retrieved:** 2026-05-27
- **Trust class:** web — secondary source summarizing De Bono 1985
- **Summary:** Pre-LLM parallel-thinking framework. Six structural thinking modes (facts, emotions, risks, benefits, creativity, process), explicitly defined as modes any participant can enter, not as identities. Requires mode isolation to prevent cross-contamination. The foundational ancestor of vantage-operator prompting.
- **Evidence status:** corroborated by A7 (independent LLM implementation), A12 (practitioner application)

### A5: Quantifying the Persona Effect in LLM Simulations (arXiv 2402.10811)

- **Link / location:** https://arxiv.org/pdf/2402.10811
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Finds persona variables explain less than 10% of variance in LLM annotation behavior; persona prompting provides modest improvement. Uses identity-based persona definition (demographic characteristics, background attributes). Does not test structural-frame or off-domain vantage prompting.
- **Evidence status:** corroborated by A3 (both use identity-based persona definitions)

### A6: Perspective Transition of Large Language Models / RPT (arXiv 2501.09265)

- **Link / location:** https://arxiv.org/abs/2501.09265
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Proposes Reasoning through Perspective Transition: dynamic selection among direct, expert-role, and third-person perspectives for subjective tasks. The third-person "detached" perspective is closer to a structural mode-shift; the expert-role perspective is closer to domain-specialist prompting. Does not test parallel isolated calls; this is adaptive sequential selection.
- **Evidence status:** single source for the specific RPT mechanism

### A7: PTFA — Parallel Thinking for Facilitated Online Consensus Building (arXiv 2503.12499)

- **Link / location:** https://arxiv.org/abs/2503.12499
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Implements De Bono's Six Thinking Hats as parallel isolated LLM agents. Hats are structural modes, not personas. Explicitly labeled as a pilot study identifying open research challenges ("optimizing scheduling and managing behaviors in divergent phase"). Demonstrates capabilities qualitatively; does not provide quantitative benefit measurement.
- **Evidence status:** corroborated by A4 (underlying framework); single source for the specific LLM implementation; pilot-study caveat

### A8: Serendipity by Design — Cross-domain Mappings and LLM Creativity (arXiv 2603.19087)

- **Link / location:** https://arxiv.org/abs/2603.19087
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint (authors include T. L. Griffiths)
- **Summary:** Tests cross-domain mapping with 140 humans + 7 LLMs generating 700 ideas each. Humans reliably benefit from cross-domain mappings; LLMs show no statistically significant additional benefit because LLM baseline novelty already exceeds humans. Greater semantic distance between source and target domains predicts higher originality for both, when the intervention does produce an effect. K=1 single-shot per participant-product pair; not a test of parallel multi-frame setups.
- **Evidence status:** corroborated by A9 (analogical reasoning literature); partial negative signal for LLM-specific vantage-operator benefit at K=1

### A9: Fluid Transformers and Creative Analogies (arXiv 2302.12832)

- **Link / location:** https://arxiv.org/abs/2302.12832
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** LLM-generated cross-domain analogies received median 4/5 helpfulness ratings and led to observable changes in problem formulations in ~80% of cases. K=1 sequential tool, not parallel multi-frame. Framed as analogical reasoning rather than explicitly as vantage-operator prompting.
- **Evidence status:** corroborated by A8

### A10: No Evidence for LLMs Being Useful in Problem Reframing (arXiv 2503.01631 / CHI 2025)

- **Link / location:** https://arxiv.org/abs/2503.01631
- **Retrieved:** 2026-05-27
- **Trust class:** web — peer-reviewed CHI 2025
- **Summary:** Controlled experiment with 280 design professionals. Finds no evidence LLMs improve quality of problem frames across direct, structured, and free-form integration conditions. LLM use widens the competence gap between experienced and inexperienced designers. Tests human-LLM collaboration on problem reframing, not LLM-to-LLM parallel multi-frame setups.
- **Evidence status:** independent; directly bears on human-in-the-loop applications

### A11: Divergent-Convergent Thinking in LLMs / CreativeDC (arXiv 2512.23601)

- **Link / location:** https://arxiv.org/abs/2512.23601
- **Retrieved:** 2026-05-27
- **Trust class:** web — arXiv preprint
- **Summary:** Two-phase sequential prompting method scaffolding divergent then convergent thinking within a single LLM prompt. Reports 51.5–63.5% novelty improvement at K=100. Does not use frame-based structural distortion or parallel isolated calls. Persona simulation used as a diversity amplifier alongside phase-switching.
- **Evidence status:** corroborated by A3 at the principle of divergent-convergent separation; the K=100 effect sizes do not translate to Han's K=2-5 dispatch scale

### A12: Six Hats LLM Prompting Practitioner Article

- **Link / location:** https://executiveaipartners.com/six-thinking-hats-ai-prompting-strategy/
- **Retrieved:** 2026-05-27
- **Trust class:** web — grey literature / practitioner blog
- **Summary:** Independently identifies the same context-contamination problem A1 targets ("the model carries full context forward") and recommends the same solution (separate isolated conversations per hat) without reference to A1. Independent practitioner convergence on the parallel-isolation mechanism.
- **Evidence status:** corroborated by A4, A7

### A13: Addressing LLM Diversity by Infusing Random Concepts (arXiv 2601.18053)

- **Link / location:** https://arxiv.org/abs/2601.18053
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Prepending random unrelated words to prompts increases token-distribution diversity in LLM outputs at K=100. A degenerate case of off-domain forcing — random noise, not curated structural frames. Measures token-distribution diversity, not semantic novelty.
- **Evidence status:** single source for the specific mechanism

### A14: The New Stack — Claude Code ADHD Coverage

- **Link / location:** https://thenewstack.io/claude-code-adhd/
- **Retrieved:** 2026-05-27
- **Trust class:** web — tech journalism
- **Summary:** Reports "outside experts say its novelty and benchmark claims need more testing." Independent confirmation that third-party experts are skeptical of the benchmark strength. No specific expert quote with detailed technical critique.
- **Evidence status:** independent corroboration of the lack of independent validation

### A15: Multi-Agent LLM Dialogues for Research Ideation (arXiv 2507.08350 / SIGDIAL 2025)

- **Link / location:** https://arxiv.org/abs/2507.08350
- **Retrieved:** 2026-05-27
- **Trust class:** web — peer-reviewed SIGDIAL 2025
- **Summary:** Finds enlarging agent cohort, deepening interaction depth, and broadening persona heterogeneity each enrich generated-idea diversity. Specifically increasing critic-side diversity within the ideation-critique-revision loop further boosts feasibility of final proposals. K=3 critics with two to three refinement turns reported as best overall. Agents are domain-specialist personas, not structural frames. The paper does not isolate frames from domain-diversity.
- **Evidence status:** corroborated by A3 directionally (heterogeneity helps diversity); positive evidence for critic-side diversity as a mechanism

### A16: PRISM — Expert Personas Improve Alignment but Damage Accuracy (arXiv 2603.18507)

- **Link / location:** https://arxiv.org/html/2603.18507v1
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Tests 12 expert personas via bootstrapped gated LoRA adapters (weights-level fine-tuning). Finds expert personas help alignment-dependent tasks (writing quality, safety, format-following) and damage accuracy-dependent tasks (MMLU 68.0% vs 71.6% base). The mechanism is LoRA adaptation, not prompt-only role specification — transfer to prompt-only is not directly established.
- **Evidence status:** corroborated by A22 (journalism summary); transfer to Han's prompt-only patterns uncertain

### A17: PersonaFlow — Expert Personas for Research Ideation (arXiv 2409.12538)

- **Link / location:** https://arxiv.org/html/2409.12538v1
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Uses domain-specialist expert personas (not ordinary/demographic) in research ideation. Finds multi-expert-persona conditions improve user ratings of critique relevance and perceived creativity. Does not test the A3 ordinary-vs-curated comparison.
- **Evidence status:** single source

### A18: Specializing Smaller Language Models towards Multi-Step Reasoning (arXiv 2301.12726)

- **Link / location:** https://arxiv.org/abs/2301.12726
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Demonstrates multi-step math-reasoning capability can be distilled from large models to small models through task specialization. "Specialization" means fine-tuning toward a narrow task. Measures narrow-task accuracy, not ideation diversity. Different phenomenon from A3.
- **Evidence status:** corroborated by A19, A20

### A19: PromptHub — Role-Prompting Empirical Test

- **Link / location:** https://www.prompthub.us/blog/role-prompting-does-adding-personas-to-your-prompts-really-make-a-difference
- **Retrieved:** 2026-05-27
- **Trust class:** web — practitioner blog (not peer-reviewed)
- **Summary:** Tests role/persona prompting on accuracy-based tasks (MMLU, AQuA math). Finds simple persona prompting does not improve accuracy on those tasks; effect size negligible. Tests narrow-task accuracy, not ideation diversity.
- **Evidence status:** partially corroborated by A16 (different mechanism but consistent direction); single source for specific accuracy numbers

### A20: Orq.ai — Prompt Optimization for Smaller Models

- **Link / location:** https://orq.ai/blog/prompt-optimization-to-improve-model-performance
- **Retrieved:** 2026-05-27
- **Trust class:** web — vendor blog (interested party)
- **Summary:** Claims up to 4x performance improvement on trace topic classification from prompt optimization. Tasks measured are narrow-task accuracy. Does not test persona prompting. Different phenomenon from A3.
- **Evidence status:** single source; interested party

### A21: ExpertPrompting (arXiv 2305.14688)

- **Link / location:** https://arxiv.org/html/2305.14688
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Generates detailed task-specific expert personas via in-context learning. Measures answer quality and instruction-following comprehensiveness (Vicuna80 benchmark, coding/writing/reasoning/knowledge). Different evaluation axis from A3. Partially in tension with A16's accuracy-damage finding; tasks and methods differ.
- **Evidence status:** single source for specific preference numbers

### A22: The Register — Expert Persona Accuracy Damage Coverage

- **Link / location:** https://www.theregister.com/2026/03/24/ai_models_persona_prompting/
- **Retrieved:** 2026-05-27
- **Trust class:** web — journalism (secondary)
- **Summary:** Journalistic coverage of PRISM (A16). Corroborates the accuracy-damage finding on knowledge benchmarks.
- **Evidence status:** corroborates A16; not independent

### A23: Security Code Review with LLMs (arXiv 2401.16310)

- **Link / location:** https://arxiv.org/html/2401.16310v3
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Empirical study of LLM prompting strategies for security code review. Abstract addresses CoT, CWE lists, and commit-message prompts. Persona/role prompting as an isolated tested variable is not confirmed from the abstract. The specific claim that role prompting in review tasks has minimal accuracy impact is unverified at the abstract level.
- **Evidence status:** unverified for the persona-prompting claim

### A24: The Spark Effect — Curated Creative-Archetype Personas (arXiv 2510.15568)

- **Link / location:** https://arxiv.org/html/2510.15568
- **Retrieved:** 2026-05-27
- **Trust class:** web — academic preprint
- **Summary:** Tests richly authored creative-archetype personas (philosopher, cyborg artist, sustainability expert — not named celebrities) in divergent ideation. Curated archetypes dramatically outperform no-persona baseline (+4.76 vs +0.62 generic multi-agent). The persona type is different from A3's named celebrities; potential tension with A3 is unresolved because the curated types differ.
- **Evidence status:** single source; potential cross-source tension with A3 unresolved

### A25: HBR / OwnYourAI — Secondary Coverage of A3

- **Link / location:** https://hbr.org/2025/12/research-when-used-correctly-llms-can-unlock-more-creative-ideas (authored by A3's authors); https://ownyourai.com/examining-and-addressing-barriers-to-diversity-in-llm-generated-ideas/
- **Retrieved:** 2026-05-27
- **Trust class:** web — secondary coverage
- **Summary:** HBR piece is by the same authors as A3 (not independent). OwnYourAI is independent paraphrase, not replication.
- **Evidence status:** not independent corroboration

### A26: Han plugin codebase

- **Link / location:** `/Users/mxriverlynn/dev/testdouble/han/plugin/` at the time of research; specifically `plugin/skills/research/SKILL.md:24,100`, `plugin/skills/investigate/SKILL.md:31-46`, `plugin/skills/architectural-analysis/SKILL.md:94-106`, `plugin/skills/gap-analysis/SKILL.md:127-143`, `plugin/agents/adversarial-validator.md`, `plugin/agents/junior-developer.md`, `plugin/agents/project-manager.md`, and 19 other agent definitions in `plugin/agents/`
- **Retrieved:** n/a (codebase anchor)
- **Trust class:** codebase
- **Summary:** Confirms branch isolation in `research` (web-vs-codebase), `investigate` (parallel angles), `architectural-analysis` (parallel specialists), `gap-analysis` (parallel swarm). Confirms generator-critic separation in `research`, `investigate`, `gap-analysis` (sequential). Confirms three vantage-operator-class agents (`adversarial-validator`, `junior-developer`, `project-manager`) that force epistemic-stance reframing without domain credentials. Confirms 19 domain-specialist agents that read artifacts in their domains.
- **Evidence status:** trusted current-state anchor

### A27: Han internal — specialization-and-model-selection.md

- **Link / location:** `han.plugin-builder/skills/guidance/references/specialization-and-model-selection.md` at the time of research
- **Retrieved:** n/a (codebase anchor)
- **Trust class:** codebase
- **Summary:** Han-internal guidance arguing specialized prompts (named heuristics, fixed rubrics, narrow domain framing) shift work from inference-time compute to prompt-time design, letting smaller models match larger ones on narrow tasks. Cites A18, A19, A20, and decomposition literature. Addresses narrow-task accuracy, not ideation diversity. No discussion of ideation, divergent thinking, or parallel exploration.
- **Evidence status:** trusted current-state anchor

### A28: Prior research report — adhd-application-to-han.md

- **Link / location:** `docs/research/adhd-application-to-han.md` in this repository
- **Retrieved:** n/a (provided)
- **Trust class:** provided (operator-supplied — interested-party scrutiny)
- **Summary:** The previous research round that this report rebuilds. Used A1-A11 source registry. Recommended "no clear winner" with O4-then-O2-then-O1 ordering, partly on A5/A3 contradiction grounds.
- **Evidence status:** provided; this report supersedes its specific A3-based reasoning

## References

- **A1** — ADHD: Parallel Divergent Ideation for Coding Agents. https://uditakhourii.github.io/adhd/ (retrieved 2026-05-27).
- **A2** — Issue #17, Distinguish ADHD frames from personas (A5) and from domain specialists (Han-style). https://github.com/UditAkhourii/adhd/issues/17 (retrieved 2026-05-27).
- **A3** — De Freitas, Nave, Puntoni. Examining and Addressing Barriers to Diversity in LLM-Generated Ideas. arXiv 2602.20408. https://arxiv.org/abs/2602.20408 (retrieved 2026-05-27).
- **A4** — Six Thinking Hats (De Bono 1985). https://en.wikipedia.org/wiki/Six_Thinking_Hats (retrieved 2026-05-27).
- **A5** — Quantifying the Persona Effect in LLM Simulations. arXiv 2402.10811. https://arxiv.org/pdf/2402.10811 (retrieved 2026-05-27).
- **A6** — Perspective Transition of Large Language Models. arXiv 2501.09265. https://arxiv.org/abs/2501.09265 (retrieved 2026-05-27).
- **A7** — PTFA: Parallel Thinking for Facilitated Online Consensus Building. arXiv 2503.12499. https://arxiv.org/abs/2503.12499 (retrieved 2026-05-27).
- **A8** — Serendipity by Design: Cross-domain Mappings and LLM Creativity. arXiv 2603.19087. https://arxiv.org/abs/2603.19087 (retrieved 2026-05-27).
- **A9** — Fluid Transformers and Creative Analogies. arXiv 2302.12832. https://arxiv.org/abs/2302.12832 (retrieved 2026-05-27).
- **A10** — No Evidence for LLMs Being Useful in Problem Reframing. CHI 2025. arXiv 2503.01631. https://arxiv.org/abs/2503.01631 (retrieved 2026-05-27).
- **A11** — Divergent-Convergent Thinking in LLMs for Creative Problem Generation. arXiv 2512.23601. https://arxiv.org/abs/2512.23601 (retrieved 2026-05-27).
- **A12** — Six Hats, One Prompt: De Bono's Framework as the Antidote to AI Bias. Executive AI Partners. https://executiveaipartners.com/six-thinking-hats-ai-prompting-strategy/ (retrieved 2026-05-27).
- **A13** — Addressing LLM Diversity by Infusing Random Concepts. arXiv 2601.18053. https://arxiv.org/abs/2601.18053 (retrieved 2026-05-27).
- **A14** — The New Stack — Claude Code ADHD coverage. https://thenewstack.io/claude-code-adhd/ (retrieved 2026-05-27).
- **A15** — Exploring Design of Multi-Agent LLM Dialogues for Research Ideation. SIGDIAL 2025. arXiv 2507.08350. https://arxiv.org/abs/2507.08350 (retrieved 2026-05-27).
- **A16** — PRISM: Expert Personas Improve LLM Alignment but Damage Accuracy. arXiv 2603.18507. https://arxiv.org/html/2603.18507v1 (retrieved 2026-05-27).
- **A17** — PersonaFlow: Boosting Research Ideation with LLM-Simulated Expert Personas. arXiv 2409.12538. https://arxiv.org/html/2409.12538v1 (retrieved 2026-05-27).
- **A18** — Specializing Smaller Language Models towards Multi-Step Reasoning. arXiv 2301.12726. https://arxiv.org/abs/2301.12726 (retrieved 2026-05-27).
- **A19** — Role-Prompting: Does Adding Personas to Your Prompts Really Make a Difference? PromptHub. https://www.prompthub.us/blog/role-prompting-does-adding-personas-to-your-prompts-really-make-a-difference (retrieved 2026-05-27).
- **A20** — Prompt Optimization: How to Make Smaller Models Punch Above Their Weight. Orq.ai. https://orq.ai/blog/prompt-optimization-to-improve-model-performance (retrieved 2026-05-27).
- **A21** — ExpertPrompting: Instructing Large Language Models to be Distinguished Experts. arXiv 2305.14688. https://arxiv.org/html/2305.14688 (retrieved 2026-05-27).
- **A22** — Telling an AI model that it's an expert makes it worse. The Register. https://www.theregister.com/2026/03/24/ai_models_persona_prompting/ (retrieved 2026-05-27).
- **A23** — An Insight into Security Code Review with LLMs. arXiv 2401.16310. https://arxiv.org/html/2401.16310v3 (retrieved 2026-05-27).
- **A24** — The Spark Effect: On Engineering Creative Diversity in Multi-Agent AI Systems. arXiv 2510.15568. https://arxiv.org/html/2510.15568 (retrieved 2026-05-27).
- **A25** — HBR — Research: When Used Correctly, LLMs Can Unlock More Creative Ideas. https://hbr.org/2025/12/research-when-used-correctly-llms-can-unlock-more-creative-ideas; OwnYourAI summary at https://ownyourai.com/examining-and-addressing-barriers-to-diversity-in-llm-generated-ideas/ (retrieved 2026-05-27).
- **A26** — Han plugin codebase. `plugin/skills/` and `plugin/agents/` at the time of research. Codebase anchor.
- **A27** — `han.plugin-builder/skills/guidance/references/specialization-and-model-selection.md` in this repository. Codebase anchor.
- **A28** — Prior research report. `docs/research/adhd-application-to-han.md` in this repository. Provided.
