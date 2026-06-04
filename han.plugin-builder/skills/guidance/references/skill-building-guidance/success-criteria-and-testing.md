---
paths:
  - "**/skills/**/*.md"
---

# Success Criteria and Testing

How do you know a skill is working? Without defined success criteria, "it seems fine" becomes the bar — and that bar shifts with each conversation. This guide defines three test types that cover whether a skill triggers correctly, executes its workflow, and actually improves outcomes compared to working without it.

Testing rigor should match the skill's audience. A skill used by one person internally has different needs than one deployed across an organization. But every skill benefits from at least running through the triggering tests and a few functional scenarios.

**Test against the model the skill targets.** Anthropic notes that smaller, faster models (Haiku) may need more detailed, explicit instructions than larger ones to follow a skill reliably, while a larger model can fill gaps a terse skill leaves. A skill that passes on Opus can still fail on Haiku. If a skill is meant to run on a faster tier (or to be dispatched into a Haiku subagent), run the triggering and functional tests on that tier, not just on your session's default. See [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices).

## Triggering Tests

**Goal:** Ensure the skill loads when it should and stays silent when it shouldn't.

Triggering tests validate the `description` field. If the skill doesn't trigger on a paraphrased request, the description is missing trigger phrases. If it triggers on an unrelated topic, the description is too broad or missing boundary statements.

### Test cases

Build three categories of test prompts:

| Category | Purpose | Target |
|----------|---------|--------|
| **Obvious triggers** | The most direct way a user would invoke the skill | Should trigger 100% |
| **Paraphrased triggers** | Alternative phrasings, synonyms, indirect requests | Should trigger 90%+ |
| **Unrelated prompts** | Requests the skill should NOT handle | Should NOT trigger |

### Example test suite

For a `code-review` skill:

**Should trigger (obvious):**
- "Review my code"
- "Run a code review"
- "Check the code on this branch"

**Should trigger (paraphrased):**
- "Look over these changes"
- "Audit the diff"
- "What do you think of the code I wrote?"

**Should NOT trigger:**
- "Write a unit test for this function"
- "Help me debug this error"
- "Create a PR description" (should trigger `update-pr-description` instead)

### How to measure

Run 10-20 test prompts that span all three categories. Track how many times the skill loads automatically versus requires explicit invocation (`/skill-name`).

**Passing criteria:** 90%+ of relevant prompts trigger the skill. Zero unrelated prompts trigger it.

### Debugging approach

If triggering tests fail, ask Claude directly: "When would you use the [skill name] skill?" Claude will quote the description back. Compare what Claude says against your test prompts to identify missing trigger phrases or overly broad language.

## Functional Tests

**Goal:** Verify the skill produces correct outputs and handles errors.

Functional tests validate the SKILL.md body — the process steps, tool usage, and error handling. Each use case from the planning phase becomes a functional test.

### Test cases

| Category | What to verify |
|----------|---------------|
| **Valid outputs** | Skill produces the expected result for each use case |
| **Tool calls succeed** | All tool invocations (Read, Grep, Bash, Agent, Skill) execute without errors |
| **Error handling** | Skill responds correctly when prerequisites are missing or steps fail |
| **Edge cases** | Unusual inputs, empty results, very large files, missing files |

### Example functional test

```
Test: Review a branch with no changes
Given: Current branch is identical to the default branch (empty diff)
When: User says "Review my code"
Then:
  - Skill triggers
  - Detects empty diff
  - Informs user there are no changes to review
  - Does NOT produce a review document with fabricated findings
```

```
Test: Review a branch with 50+ changed files
Given: Current branch has changes across 50 files
When: User says "Run a code review"
Then:
  - Skill triggers
  - Reviews all changed files (not just the first few)
  - Groups findings by file
  - Completes within a reasonable number of tool calls
```

### How to measure

Run each use case as a test. For each run, verify:
1. The skill triggered (not a sibling)
2. All steps executed in order
3. Tool calls succeeded
4. Output matches expected structure
5. Error cases are handled gracefully

Run the same request 3-5 times to check for consistency. If results vary significantly across runs, the instructions are ambiguous — tighten them.

## Performance Comparison

**Goal:** Prove the skill improves results versus working without it.

Performance comparison answers the question: "Is this skill worth having?" A skill that triggers correctly and produces valid output still isn't valuable if the user could accomplish the same thing just as easily without it.

### Metrics to compare

Run the same task with and without the skill enabled:

| Metric | Without Skill | With Skill | What It Shows |
|--------|--------------|------------|---------------|
| **Messages exchanged** | Count of back-and-forth | Count of back-and-forth | Skill reduces interaction overhead |
| **Tool calls** | Total tool invocations | Total tool invocations | Skill is more efficient with tools |
| **Tokens consumed** | Total token usage | Total token usage | Skill uses context efficiently |
| **Errors** | Failed tool calls, retries | Failed tool calls, retries | Skill handles errors better |
| **User corrections** | Times user redirected Claude | Times user redirected Claude | Skill follows the right workflow |

### Example comparison

```
Task: Generate a PR description for the current branch

Without skill:
  - 15 back-and-forth messages (user explaining format, sections, what to include)
  - 3 failed gh CLI calls requiring retry
  - 12,000 tokens consumed
  - 2 user corrections ("include the test plan", "use bullet points")

With skill:
  - 2 clarifying questions only
  - 0 failed API calls
  - 6,000 tokens consumed
  - 0 user corrections
```

### Qualitative signals

Beyond the numbers, watch for:
- **Users don't need to prompt about next steps** — the skill drives the workflow
- **Workflows complete without user correction** — steps execute in the right order with the right tools
- **Consistent results across sessions** — a new user gets the same quality as an experienced one

## Summary Checklist

1. Build triggering tests: obvious triggers, paraphrased triggers, and unrelated prompts that should NOT trigger
2. Target 90%+ trigger accuracy on relevant prompts
3. Debug triggering issues by asking Claude "When would you use [skill name]?"
4. Build functional tests from each use case: valid outputs, tool calls, error handling, edge cases
5. Run functional tests 3-5 times to check consistency
6. Compare performance with and without the skill: messages, tool calls, tokens, errors, corrections
7. Match testing rigor to the skill's audience and visibility

Cross-references:
- [Use Case Planning](./use-case-planning.md) — Use cases become the functional test cases
- [Iterative Plugin Development](../iterative-plugin-development.md) — Testing evidence informs when to stop iterating
- [Skill Description Frontmatter](./skill-description-frontmatter.md) — Triggering test failures indicate description problems
