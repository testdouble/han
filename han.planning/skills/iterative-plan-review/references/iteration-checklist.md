# Iteration Checklist

Use this checklist for each iteration pass. Every section must be filled in before proceeding to the next iteration.

## Assumptions

Identify all assumptions the plan makes, classified as primary or secondary:

- **Primary assumptions** stand on their own — they are not derived from or dependent on other assumptions in the plan. These are foundational: if a primary assumption is refuted, any secondary assumptions that depend on it are also invalidated.
- **Secondary assumptions** depend on one or more primary assumptions. They inherit risk — even if a secondary assumption appears sound in isolation, it collapses if the primary assumption it rests on is refuted.

Evaluate primary assumptions first. When a primary assumption is refuted, mark all dependent secondary assumptions as invalidated without spending time evaluating them independently.

For each primary and secondary assumption identified:

| Field | Content |
|-------|---------|
| **Assumption** | What the plan assumes |
| **Classification** | Primary or Secondary |
| **Depends On** | Which primary assumption(s) this depends on (secondary only; "—" for primary) |
| **Source in Plan** | Which section or step encodes this assumption |
| **Evaluation** | Verified, Refuted, Uncertain, or Invalidated (secondary whose primary was refuted) |
| **Evidence** | Code, docs, or patterns that support the evaluation |
| **Action if Refuted** | What changes in the plan if this assumption doesn't hold |

## Overlap Check

| Type | Finding |
|------|---------|
| **Internal Overlap** | Redundant or duplicate steps within the plan itself |
| **External Overlap** | Steps that duplicate existing codebase patterns, utilities, or prior work |
| **Consolidation Proposed** | Merge, extract, or confirm intentional duplication with rationale |

## Changes Made This Iteration

For each change:

| Field | Content |
|-------|---------|
| **Change** | What was modified in the plan file |
| **Trigger** | Which assumption evaluation, overlap finding, or ambiguity resolution prompted this change |

## Ambiguity Surfaced

For each ambiguity:

| Field | Content |
|-------|---------|
| **Question** | The contextual question for the user |
| **Impact** | What changes depending on the answer |
| **Tradeoffs** | Why there isn't an obvious right answer |
| **Follow-up Room** | How the user can provide nuanced answers beyond a binary choice |

## Stability Assessment

| Field | Content |
|-------|---------|
| **Structural Changes This Iteration** | High / Medium / Low |
| **Probability of Meaningful Improvement** | Above or below 80% |
| **Recommendation** | Continue iterating or stop |
