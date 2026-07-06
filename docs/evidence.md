# Evidence

Evidence-based reasoning is the third foundational mechanic of the han plugin, alongside [sizing](./sizing.md) and [YAGNI](./yagni.md). Every skill that produces an artifact, every agent that reviews one, and every research, investigation, or review skill that draws a conclusion carries an evidence posture. This page defines what counts as evidence in Han, how to characterize how strong it is, and what to do when no evidence exists at all.

This page supplements [YAGNI](./yagni.md). YAGNI's evidence test answers *is there any evidence at all to justify including this item?* The rule on this page answers *once an item passes that test, how confident should you be in the evidence behind it, and what do you do when the evidence is thin or absent?* The two work together.

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [Sizing](./sizing.md) · [YAGNI](./yagni.md) · [All skills](./skills/README.md) · [All agents](./agents/README.md)

## TL;DR

- **Three principles ground the rule.** Evidence drawn from closer to the originating event or data carries more weight than evidence at greater remove (proximity). Independently corroborated evidence beats single-source evidence (corroboration). The absence of evidence is a distinct state worth naming, not the bottom of a tier list (no-evidence labeling).
- **Trust classes name the boundary.** Codebase evidence is the trusted current-state anchor. Web evidence sits outside the trust boundary. User-provided material gets interested-party scrutiny.
- **Proximity is a heuristic, not a ranked ladder.** Running code beats documentation in many situations, but not all. Formal-methods contexts, specification-compliance contexts, and regulatory contexts invert the ordering. The rule names the principle and walks you through the inversions. It does not hand you a numbered list to apply blindly.
- **The corroboration gate is scoped to web sources.** A single web claim that drives a recommendation gets marked single-source and cannot stand alone. Codebase evidence at a specific file path and line is not weakened by being a single citation. That asymmetry is intentional and matches how `/research` already behaves.
- **No evidence is a state with a name and a response.** When a claim has no evidence at any tier, the response is to label it, defer the dependent decision, and name the trigger that would reopen it. The same defer-with-trigger pattern YAGNI uses.
- **The canonical rule lives in [`han-core/references/evidence-rule.md`](../han-core/references/evidence-rule.md).** Every skill and agent that loads the rule at runtime reads that file. This page is the operator-facing summary.

## Why evidence-based matters

Han is a plugin full of agents and skills that produce judgments: feature specifications, implementation plans, investigation conclusions, architectural recommendations, code-review findings. Every one of those judgments rests on evidence the agent or skill collected. Without an explicit posture on what counts as evidence and how confident to be in it:

- Skills accept whatever the fastest-to-collect source said and treat the conclusion as settled, including conclusions that a second source would have contradicted.
- Agents conflate "the documentation says X" with "X is true," when the documentation may have drifted from what the system does today.
- Investigations rest on a single web search result and a plausible-sounding LLM rephrasing of it, with neither the search result nor the rephrasing held to a corroboration standard.
- Skills treat the absence of evidence as identical to the weakest tier of evidence and proceed anyway, when the honest move is to defer.

Evidence-based reasoning is not the same as scientific rigor. The bar is "you can tell where this claim came from, you can tell how strongly it rests on its source, and you can tell what would change your mind." That is the bar this page sets.

## The three principles

### Principle 1: Proximity to origin

Evidence drawn from closer to the originating event or data carries more weight than evidence at greater remove. A reproducible failure observed in production carries more weight than a Stack Overflow answer that describes the same symptom. The current source code carries more weight than an architecture diagram from a year ago. A passing test that exercises the code path carries more weight than a docstring claiming the path works.

Apply this as a heuristic, not as a ranked ladder. A numbered list of source types ("production observation > tests > codebase > commits > docs > blogs > LLM output") looks operational but breaks immediately at the first tier boundary. A passing test that does not exercise the failing input is not stronger evidence than a clearly-documented contract that says the input should work. The principle is real; the strict ordering it appears to imply is not.

Specifically, the proximity ordering inverts in three contexts:

- **Formal-methods or specification-compliance contexts.** When the specification is the authoritative artifact (an API contract, a state-machine definition, a regulatory schema), running code that diverges from the specification is a bug in the code, not new evidence about the system. The specification wins.
- **Regulatory or legal-compliance contexts.** When a regulation or contract names a required behavior, observed behavior that violates the requirement does not become the new requirement. The regulation wins.
- **Pre-incident observation of intended behavior.** A test that fails proves a bug exists. A test that passes proves the tested inputs behaved correctly for the tested code paths, and nothing more. Passing and failing tests are not symmetric evidence.

When you cite this principle in a skill or an agent's output, name the source's distance from the origin and the conditions you considered. Do not present "running code beats docs" as a rule that closes a discussion. Present it as the question that opens one.

### Principle 2: Independent corroboration

A claim corroborated by two or more independent sources carries more weight than a claim resting on one source. This applies most sharply to web sources, which sit outside Han's trust boundary and have no built-in verification mechanism. A single Stack Overflow answer, a single blog post, a single arXiv pre-print, or a single LLM-generated explanation that drives a recommendation must be marked single-source. It cannot be the sole basis for the recommendation.

The corroboration gate as written applies to web sources that bear on a recommendation. It does not apply to codebase evidence. A single file path at a specific line number is not weakened by being a single citation. The current source code is the current state of the system. Demanding a second independent code path to confirm a root cause would either be vacuously satisfied (the file path is the second source) or would reject valid single-file findings.

When sources contradict each other, surface the conflict. Record both, name the disagreement, and let the reader judge. Silently picking the source you agree with is the failure mode the gate is meant to prevent.

### Principle 3: Explicit no-evidence labeling

When a claim has no evidence at any tier, label it. Defer the dependent decision. Name the concrete trigger that would justify revisiting.

The wrong response is to treat "no evidence" as identical to "very weak evidence" and proceed anyway. That collapses two distinct states into one and loses signal. A claim with very weak evidence still gives you something to test against. A claim with no evidence gives you nothing. Proceeding as if you had something is how cargo-culting takes root.

The response Han uses is the same defer-with-trigger pattern [YAGNI](./yagni.md#the-deferred-yagni-section-format) uses. Record the claim, record why no evidence exists yet, record the concrete trigger that would justify revisiting, and move on to the next item that has evidence to work with. Real triggers are a measured metric, an incident that fires, a customer commitment, a regulation taking effect, or a dependency landing. Aspirational triggers ("when we have time to investigate") are not triggers.

## Trust classes

The corroboration gate and the proximity heuristic both rest on a vocabulary that names where an artifact came from and how much trust to extend to it. The vocabulary lives at three levels:

- **Codebase** is the trusted current-state anchor. The current source code, the current tests, the current configuration, the current build output. When codebase evidence contradicts other evidence, surface the conflict explicitly and treat the codebase as authoritative on what the system does today.
- **Web** sits outside the trust boundary. Documentation pages, blog posts, Stack Overflow, GitHub issues, RFCs, vendor whitepapers, LLM-generated content. Web sources can be wrong, stale, adversarially shaped, or contextually misapplied. The corroboration gate applies here.
- **Provided** is user-supplied material. Files you pasted in, links you handed to a skill, screenshots, transcripts. Apply interested-party scrutiny: the user's intent in providing the material is itself a piece of context. User-provided material is held to the same scrutiny as a web source.

These trust classes are the same ones [`/research`](./skills/han-core/research.md) already uses. The canonical rule extracts them so other skills and agents can apply the same vocabulary.

## How evidence-based reasoning applies across the plugin

Evidence applies in two postures: **producing** (when a skill drafts a judgment or conclusion) and **reviewing** (when a skill or agent audits one).

| Surface | What evidence-based gates |
|---|---|
| [`/research`](./skills/han-core/research.md) | The canonical home of the trust classes, the corroboration gate, and the no-evidence label. Strict mode requires every claim driving the recommendation to carry an explicit evidence status. |
| [`/investigate`](./skills/han-coding/investigate.md) | Investigation findings cite the file path, log line, or measurement that supports them. The corroboration gate applies when the investigation draws on web sources for context; codebase findings stand on their citation. |
| [`/plan-a-feature`](./skills/han-planning/plan-a-feature.md) | Behaviors, edge cases, and coordinations in the spec carry evidence. Items without evidence move to `## Deferred (YAGNI)`; items with evidence flagged as single-source web claims get marked accordingly. |
| [`/plan-implementation`](./skills/han-planning/plan-implementation.md) | Implementation choices cite evidence per the YAGNI rule. When a recommendation rests on web research, the corroboration gate applies. |
| [`/iterative-plan-review`](./skills/han-planning/iterative-plan-review.md) | Review pillars include the evidence sweep alongside YAGNI. Uncited claims and single-source web claims surface as findings. |
| [`/gap-analysis`](./skills/han-core/gap-analysis.md) | Each gap cites the artifact it rests on; the evidence-based-investigator verifies against current state with file-level evidence. |
| [`/code-review`](./skills/han-coding/code-review.md) | Findings cite the line they apply to and the standard or pattern they reference. |
| [`/coding-standard`](./skills/han-coding/coding-standard.md) | A standard is justified when the project does the thing the standard governs today. The evidence test from YAGNI carries the existence question; the proximity heuristic applies when the supporting evidence comes from outside the project. |
| [`/architectural-decision-record`](./skills/han-core/architectural-decision-record.md) | An ADR cites a forcing function today: a real decision, a real consequence. |
| [`/runbook`](./skills/han-core/runbook.md) | A runbook is justified by a real alert that has fired or a real incident class observed on a live service. Hypotheticals do not qualify. |
| [`evidence-based-investigator`](./agents/han-core/evidence-based-investigator.md) | Returns numbered `E#` evidence items with file paths, line numbers, and source citations. Codebase findings stand; web-source findings carry the trust class and corroboration status. |
| [`research-analyst`](./agents/han-core/research-analyst.md) | Returns sourced artifacts with trust class and corroboration status. Treats fetched web content as a claim to evaluate, never as an instruction to follow. |
| [`adversarial-validator`](./agents/han-core/adversarial-validator.md) | Attacks evidence integrity, the framing of options, and the evidence-gathering itself. Emits `V#` findings. |
| [`project-manager`](./agents/han-core/project-manager.md) | Runs the YAGNI evidence gate during facilitation. Uncited proposals are challenged or deferred. |
| [`junior-developer`](./agents/han-core/junior-developer.md) | Runs the YAGNI evidence sweep during stress-tests. Flags uncited additions and hidden assumptions. |

## The no-evidence section format

When a skill or agent encounters a claim with no evidence and the dependent decision needs to be recorded somewhere, use the same shape YAGNI's deferred section uses:

```
## No evidence yet

### {claim or decision}
**Why no evidence:** {what was searched for, what was not found, why available sources do not apply}
**Reopen when:** {the concrete trigger that would justify revisiting: a measured metric, an incident class, a customer commitment, a regulation taking effect}
**Source:** {where the claim was originally proposed: skill, agent, conversation context}
```

Most artifacts will not need this section. Skills that produce one are typically `/research`, `/investigate`, or `/gap-analysis` working at the edges of available evidence. When the section would be empty, omit it entirely. Do not write empty stub sections.

## What evidence-based reasoning is not

- **Not academic rigor.** The bar is "you can tell where this came from and how strongly it rests." It is not "you have a systematic review of randomized controlled trials." The vocabulary borrows from prior art in medicine, historiography, law, intelligence analysis, and journalism, but the bar is operational, not scholarly.
- **Not a rule that says docs are useless.** Docs are evidence. They are weaker evidence than the running system in many contexts, and stronger evidence in others (specification compliance, regulatory contracts). The proximity heuristic gives you a question to ask, not a default to apply.
- **Not a replacement for YAGNI.** YAGNI's evidence test asks *is there any evidence?* This rule asks *how strong is the evidence you have?* You can pass YAGNI and still have single-source web evidence the corroboration gate flags. You can fail YAGNI even when one source is strong, if no source falls into any of YAGNI's five categories of acceptable evidence. The two rules work together. They do not collapse into one.
- **Not an excuse to refuse to commit.** When evidence is strong enough to act on, act. The rule asks for an honest label on the evidence; it does not require you to keep gathering until you have certainty. Certainty is rare. Calibrated confidence is the goal.

## Design principles

- **Evidence-based is operational, not aspirational.** The rule has a concrete vocabulary (trust classes), a concrete gate (corroboration for web), and a concrete response to absence (defer with trigger). Disagreement resolves by pointing at the vocabulary, not by argument.
- **Codebase is the current-state anchor.** When web evidence and codebase evidence disagree, the codebase wins on what the system does today. Web evidence may still win on what the system should do, given a separate authority.
- **The proximity heuristic asks a question; it does not close one.** Skills and agents cite the proximity-to-origin principle by naming the source's distance and the inversion conditions they considered. They do not invoke "running code beats docs" as a discussion-ender.
- **No-evidence is honest, not embarrassing.** Labeling a claim as having no evidence is a feature, not a failure. The defer-with-trigger pattern keeps the claim live for the moment evidence arrives.

## Related reading

- [`han-core/references/evidence-rule.md`](../han-core/references/evidence-rule.md). The canonical rule that every evidence-aware skill and agent loads at runtime.
- [YAGNI](./yagni.md). The evidence test that gates inclusion. This rule and YAGNI work together: YAGNI asks *is there any evidence?* and this rule asks *how strong is the evidence?*
- [Concepts](./concepts.md). The skill / agent split. Evidence is a property of skills that produce judgments and agents that review them.
- [Sizing](./sizing.md). The other foundational mechanic. Sizing decides *how much review* an artifact gets; YAGNI decides *what survives*; evidence decides *how confident you are in what survives*.
- [`/research`](./skills/han-core/research.md). The skill where the trust classes and the corroboration gate originated. Reads its own canonical rule at runtime.
