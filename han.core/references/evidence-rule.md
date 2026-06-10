# Evidence Rule (Evidence-Based)

This rule defines what evidence means in Han, how to characterize how strong it is, and what to do when no evidence exists at all. The rule supplements [`yagni-rule.md`](./yagni-rule.md). YAGNI's categories answer *is there any evidence to include this item?* This rule answers *once an item passes that test, how confident should you be in the evidence, and what is the response when no evidence is available?*

The vocabulary and the corroboration gate here originated in `/research`; this file is the canonical extraction so other skills and agents can apply the same primitives.

## Trust classes

Every artifact a skill or agent cites carries one of three trust classes:

- **Codebase** is the trusted current-state anchor. The current source code, current tests, current configuration, current build output. When codebase evidence contradicts other evidence, treat the codebase as authoritative on what the system does today.
- **Web** sits outside the trust boundary. Documentation, blog posts, Stack Overflow, GitHub issues, RFCs, vendor whitepapers, LLM-generated content. Web sources can be wrong, stale, adversarially shaped, or contextually misapplied.
- **Provided** is operator-supplied material. Files pasted in, links handed to a skill, screenshots, transcripts. Apply interested-party scrutiny; hold to the same standard as web sources.

## The three principles

### Principle 1: Proximity to origin (heuristic, not ranked tier list)

Evidence drawn from closer to the originating event or data carries more weight than evidence at greater remove. Apply this as a heuristic, not as a ranked tier list. A numbered ordering of source types looks operational but breaks at the first tier boundary.

The principle inverts in three contexts: formal-methods or specification-compliance contexts (the specification is the authoritative artifact); regulatory or contractual contexts (the regulation wins); and pre-incident observation of intended behavior (a passing test proves only that tested inputs behaved correctly for tested code paths; passing and failing tests are not symmetric evidence). See [`docs/evidence.md#principle-1-proximity-to-origin`](../../docs/evidence.md#principle-1-proximity-to-origin) for the inversion conditions.

### Principle 2: Independent corroboration (web-source scope)

A claim corroborated by two or more independent sources carries more weight than a claim resting on one. Applied as a gate to web sources:

**A web claim that bears on a recommendation and has no independent corroboration is marked single-source and cannot be the sole basis for the recommendation.**

The gate does not apply to codebase evidence. A single file path at a specific line number is not weakened by being a single citation; the current source code is the current state of the system. Extending the gate to codebase evidence is deferred work, opened only when a specific failure forces the adaptation.

When sources contradict each other, surface the conflict. Record both, name the disagreement, and let the reader judge. When codebase evidence and web evidence disagree, the codebase wins on what the system does today; add "continue with the current approach" as a named alternative.

### Principle 3: Explicit no-evidence labeling

When a claim has no evidence at any tier, label it. Defer the dependent decision. Name the concrete trigger that would justify revisiting.

Do not collapse "no evidence" into "very weak evidence." They are different states. The response pattern is the same one [YAGNI](./yagni-rule.md) uses for deferred items: a labeled defer with a concrete reopen trigger (a measured metric, an incident class, a customer commitment, a regulation taking effect, a dependency landing). Aspirational triggers do not qualify.

## How to apply the rule

### When producing a judgment (research, investigation, plan, review)

For every claim that drives a conclusion:

1. Name the trust class (codebase, web, provided).
2. For web claims that bear on the recommendation, apply the corroboration gate. Single-source web claims get marked and cannot stand alone.
3. For codebase claims, cite the file path and line number; the single-source caveat does not apply.
4. For claims with no evidence at any tier, label the claim, defer the dependent decision, and record the reopen trigger.

### When reviewing a judgment (review skills, review agents)

For every committed claim in the artifact:

1. Check that the trust class is named or inferable.
2. Check that single-source web claims are marked and do not stand alone as the basis for a recommendation.
3. Check that no-evidence claims are labeled and deferred with a trigger, not silently treated as weak evidence.
4. Surface contradictions between sources rather than picking the agreeable one.

### When the rule and YAGNI both apply

Apply YAGNI Gate 1 first. If the item fails the YAGNI evidence test (none of YAGNI's five categories of acceptable evidence apply), defer the item per YAGNI regardless of any quality consideration this rule would raise. If the item passes YAGNI Gate 1, then characterize the quality of the evidence using this rule: name the trust class, apply the corroboration gate to web claims, and label no-evidence states.

YAGNI gates inclusion. This rule characterizes quality once inclusion is justified. The two rules do not collapse into one.

## Escalation

Claims that fail the corroboration gate and cannot be corroborated are **never silently accepted**. They surface to the user with the single-source label so the choice to act on them is conscious. The user always wins; they may direct a single-source web claim to be acted on against the gate, and the override is recorded with rationale so the choice stays visible.

## What this rule is not

- **Not a replacement for YAGNI's evidence test.** YAGNI's five categories of acceptable evidence remain the gate for inclusion. This rule applies after YAGNI passes.
- **Not a ranked tier list.** The proximity-to-origin principle is a heuristic. A numbered ordering ("production > tests > codebase > docs > blogs") will produce inconsistent results across skill invocations.
- **Not a codebase-evidence corroboration gate.** The gate applies to web sources only. Single-file codebase findings stand on their citation.
- **Not a bar for academic rigor.** The bar is operational. "You can tell where this came from and how strongly it rests" is the standard.
