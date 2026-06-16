# Iterative Plugin Development

Plugin development (skills, agents, and hooks) almost never produces solid, consistently working entities on the first try. LLM-driven plugins interact with model behavior unpredictably: assumptions encoded in a first draft only surface as problems on re-examination. This guide codifies an iterative development process that challenges assumptions, eliminates duplication, and surfaces ambiguity early.

## The Rules

### Rule: Plan for 3-5 iterations, never expect a single pass

Every plugin development effort should plan for 3-5 iterations. First drafts encode assumptions about LLM behavior, user intent, and entity boundaries that only become visible through re-examination.

A single-pass approach leads to skills that work in the author's head but fail in practice: prompts that are too vague, agent definitions that duplicate skill logic, or reference files that never get used. Each iteration is an opportunity to catch these problems before they compound.

**Example:** A code-review skill went through multiple iterations. The first draft bundled review logic with the step that posted results to a pull request. The second iteration identified this as two concerns and split them into separate skills. A later iteration extracted inline agent definitions into standalone files. Each pass caught problems the previous one encoded as assumptions.

### Rule: Challenge assumptions from previous iterations

Each iteration must explicitly list 2-3 assumptions from the previous iteration and evaluate whether they still hold. Without this step, iterations become cosmetic polish rather than genuine improvement.

Ask at each iteration:

- **What did the previous iteration assume about user behavior?** Does the skill assume users will provide arguments in a specific format? Will they actually?
- **What did it assume about LLM behavior?** Does the prompt assume the model will follow a 10-step process reliably? Will it skip steps or combine them?
- **What did it assume about entity boundaries?** Is this really one skill, or did the previous iteration bundle two concerns together?

Document the assumptions and their evaluation directly in the iteration notes. If an assumption doesn't hold, the iteration must address it, not defer it.

### Rule: Identify overlap and consolidation at each iteration

At each iteration, compare the current entity against sibling entities in the same plugin. When 80% or more overlap or duplication exists between entities, propose consolidation rather than maintaining separate definitions. The 80% threshold distinguishes genuine duplication from entities that share a common foundation but serve different purposes. Below 80%, the differences usually justify separate entities.

Overlap manifests as:

- Two skills with nearly identical prompts differing only in a final integration step.
- An agent definition that duplicates logic already in a skill.
- Reference files shared across multiple skills with only minor variations.

When overlap is found, decide: merge the entities, extract the shared logic into a reusable component, or confirm the duplication is intentional and document why.

### Rule: Write to expected files at each iteration

No discussion-only iterations. Every iteration must update the files (SKILL.md, agent definitions, plugin.json, reference files) to reflect current decisions. Writing forces precision that discussion alone does not.

A "thinking iteration" that only produces notes or plans defers decisions and creates drift between intent and implementation. If an iteration changes a decision, the files must change too.

This applies even to early iterations where the content feels rough. A concrete SKILL.md with known problems is more useful than a perfect plan that hasn't been written down.

**Example:** When developing a documentation skill, iteration 1 wrote a SKILL.md with inline agent instructions. Iteration 2 extracted those agents to standalone files and updated both the agent `.md` files and the SKILL.md to reference them via the `Agent` tool. If iteration 2 had only discussed the extraction without writing files, iteration 3 would have started from stale content.

### Rule: Surface ambiguity as contextual questions

When an iteration reveals ambiguity (unclear scope, multiple valid approaches, unknown user preferences) surface it as a question to the user. But questions must provide enough context for the user to answer meaningfully.

**Good question (contextual):**

> *"This skill currently dispatches both an investigator agent and a validator agent. Should these run sequentially (investigator first, then validator challenges findings) or in parallel? Sequential is more thorough but slower; parallel is faster but the validator might challenge incomplete findings."*

**Bad question (context-free):**

> *"Should the agents run sequentially or in parallel?"*

Every question must:

1. **State the impact.** What changes depending on the answer.
2. **Describe the tradeoffs.** Why there isn't an obvious right answer.
3. **Allow conversational follow-up.** Don't force a binary choice when the real answer might be *"it depends on X."*

## Testing Methodology

Each iteration should include lightweight testing to validate changes. Three test types apply at different stages of iteration:

1. **Triggering tests.** Does the skill activate on relevant prompts and stay silent on unrelated ones? Run 10-20 test prompts after each description change. Target: 90%+ trigger accuracy on relevant prompts, zero false triggers.

2. **Functional tests.** Does the skill produce correct outputs for each use case? Run each use case scenario after structural changes to steps, tool usage, or error handling. Check for consistency by running the same request 3-5 times.

3. **Performance comparison.** Does the skill improve outcomes versus working without it? Compare messages exchanged, tool calls, tokens consumed, and user corrections with and without the skill. Run this comparison after iteration 3 when the structure is stable.

Early iterations (1-2) focus on triggering and basic functional tests. Later iterations (3-5) add performance comparison as the skill stabilizes. Don't defer all testing to the end. Each iteration should validate its changes.

For comprehensive testing guidance, see [Success Criteria and Testing](./skill-building-guidance/success-criteria-and-testing.md).

## When to Stop Iterating

- **Minimum: 3 iterations.** The first two iterations almost always reveal structural problems. The third confirms the structure is stable.
- **Maximum: 5 iterations.** Beyond five, diminishing returns set in. If the entity isn't converging, the problem is likely scope or decomposition, not iteration count.
- **After iteration 3:** Continue only if there is at least an 80% chance the next iteration will produce a meaningful structural improvement or resolve newly surfaced ambiguity. Cosmetic improvements (rewording, reformatting) do not count.
- **Testing evidence:** Use test results to inform stop decisions. If triggering tests pass at 90%+, functional tests cover all use cases consistently, and performance comparison shows measurable improvement, the skill is ready to ship.

## Summary Checklist

1. Plan for 3-5 iterations. Never ship the first draft of a plugin entity.
2. At each iteration, list and evaluate 2-3 assumptions from the previous iteration.
3. At each iteration, check for 80%+ overlap with sibling entities and propose consolidation.
4. At each iteration, write updates to actual files. No discussion-only iterations.
5. At each iteration, run triggering and functional tests to validate changes.
6. Surface ambiguity as contextual questions with impact, tradeoffs, and room for follow-up.
7. After iteration 3, run performance comparison to confirm the skill improves outcomes.
8. Stop after 3 iterations if the structure is stable and tests pass. Never exceed 5.

Cross-references:

- [Skill Decomposition](./skill-building-guidance/skill-decomposition.md). When iteration reveals a skill doing too much, decompose it.
- [Entity Taxonomy](./plugin-entity-taxonomy.md). Use the decision heuristic to validate entity type at each iteration.
- [Skill Description Frontmatter](./skill-building-guidance/skill-description-frontmatter.md). Descriptions should be refined across iterations, not written once.
- [Success Criteria and Testing](./skill-building-guidance/success-criteria-and-testing.md). Comprehensive testing methodology for skills.
