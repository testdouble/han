---
paths:
  - "**/skills/**/*.md"
---

# Workflow Patterns

Skills encode workflows — multi-step processes that Claude executes in a specific order with specific tools. This guide documents four structural patterns that appear across well-built skills. Each pattern solves a different workflow shape, and most real skills combine two or more.

These patterns describe the *internal structure* of a skill's workflow — how to organize steps within a single SKILL.md. For guidance on *when to split a skill* into multiple skills or *how to compose* skills together, see [Skill Decomposition](./skill-decomposition.md).

The four patterns below map onto the agent workflow patterns Anthropic describes in [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) (prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer). That post's overarching advice also applies here: start with the simplest structure that works, and add steps or branches only when the task genuinely needs them.

## Choosing Your Approach: Problem-First vs. Tool-First

Before selecting a pattern, consider which framing fits your skill:

- **Problem-first:** The user describes an outcome ("set up a new project," "review this code"). The skill orchestrates the right tools in the right sequence. Users don't need to know which tools are involved.
- **Tool-first:** The user has tools available (gh CLI, an MCP server) and wants Claude to use them effectively. The skill teaches Claude the optimal workflows and best practices for those tools.

Most skills lean one direction. Problem-first skills tend toward sequential orchestration and iterative refinement. Tool-first skills tend toward context-aware selection and domain-specific intelligence. Knowing your framing helps you choose the right starting pattern.

## Sequential Workflow Orchestration

**Use when:** The skill follows a fixed sequence of steps where each step depends on the previous one's output.

This is the most common pattern. Steps execute in order, each building on the results of the previous step. Validation gates between steps catch failures before they propagate.

### Structure

```markdown
## Step 1: [Gather Context]

[What to do, what tools to use, what to capture]

Validate: [What must be true before proceeding]

## Step 2: [Process/Analyze]

Using the output from Step 1, [what to do next]

Validate: [What must be true before proceeding]

## Step 3: [Generate Output]

[What to produce, what format, where to save]

## Step 4: [Deliver/Integrate]

[How to deliver the result — post to GitHub, write to file, show to user]

If Step 4 fails: [Rollback instructions — what to undo or retry]
```

### Key techniques

- **Explicit step ordering** — number every step, state dependencies clearly
- **Validation gates** — check preconditions at each step before proceeding
- **Rollback instructions** — tell Claude what to do when a later step fails

### Example: `update-pr-description`

```markdown
## Step 1: Verify Prerequisites
Check that gh CLI is installed and a PR exists for the current branch.
If either is missing, inform the user and stop.

## Step 2: Gather Branch Context
Read the diff, commit log, and changed file list.

## Step 3: Analyze Changes
Identify the purpose, scope, and impact of the changes.

## Step 4: Generate Description
Write a structured PR description with summary, changes, and test plan.

## Step 5: Post to GitHub
Run `scripts/post-description.sh` to update the PR body.
If posting fails, show the generated description so the user can post manually.
```

## Iterative Refinement

**Use when:** Output quality improves with review cycles — drafts, reports, documentation.

The skill generates an initial output, evaluates it against quality criteria, then refines. A bounded loop prevents infinite iteration.

### Structure

```markdown
## Step 1: [Initial Draft]

Generate the first version based on [inputs].

## Step 2: [Quality Check]

Evaluate the draft against these criteria:
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]

## Step 3: [Refinement Loop]

For each issue found in the quality check:
1. Identify the specific problem
2. Apply the fix
3. Re-check that specific criterion

Maximum 3 refinement passes. If issues persist after 3 passes, present the current version with a note about remaining issues.

## Step 4: [Finalization]

Apply final formatting and deliver the result.
```

### Key techniques

- **Explicit quality criteria** — define what "good" looks like before the loop
- **Bounded iteration** — set a maximum pass count (2-3) to prevent infinite loops
- **Targeted refinement** — fix specific issues, don't regenerate everything

### Example: `project-documentation`

```markdown
## Step 3: Generate Documentation Draft

Write documentation for the discovered feature using the template from
`references/documentation-template.md`.

## Step 4: Validate Documentation

Use the `Agent` tool with `example-plugin:content-auditor` to verify:
- No fabricated details (only documents what exists in code)
- All public interfaces are covered
- Code examples compile/run

## Step 5: Refine

Address each issue found by the content auditor. Re-validate after fixes.
Maximum 2 refinement passes.
```

## Context-Aware Tool Selection

**Use when:** The skill needs to choose different tools or approaches based on runtime context.

Instead of a fixed sequence, the skill evaluates the current situation and branches to the appropriate approach. Decision trees make the selection criteria explicit.

### Structure

```markdown
## Step 1: [Assess Context]

Determine the current situation:
- [Check condition A]
- [Check condition B]
- [Check condition C]

## Step 2: [Select Approach]

Based on the assessment:
- If [condition A]: [Use approach/tool X]
- If [condition B]: [Use approach/tool Y]
- If [neither]: [Use fallback approach Z]

Explain to the user why this approach was selected.

## Step 3: [Execute Selected Approach]

[Proceed with the chosen approach]
```

### Key techniques

- **Clear decision criteria** — don't let Claude guess; specify what determines the choice
- **Fallback options** — always include a default path when no condition matches
- **Transparency** — tell the user which approach was selected and why

### Example: `investigation`

```markdown
## Step 2: Select Investigation Strategy

Based on the issue description:
- If a specific error message is provided: Start with error trace analysis
- If a behavior regression: Start with git bisect approach
- If a performance issue: Start with profiling approach
- If unclear: Start with broad evidence gathering, then narrow

Inform the user which strategy was selected and why.
```

## Domain-Specific Intelligence

**Use when:** The skill's value comes from embedded expertise — rules, regulations, best practices — not just tool orchestration.

The skill applies domain knowledge before, during, or after tool operations. The domain knowledge lives in `references/` and is consulted at specific steps.

### Structure

```markdown
## Step 1: [Gather Data]

[Collect the raw inputs using tools]

## Step 2: [Apply Domain Rules]

Consult `references/[domain-rules].md` and apply:
- [Rule category 1]: [What to check, what to flag]
- [Rule category 2]: [What to check, what to flag]

Document which rules were applied and their results.

## Step 3: [Decision Based on Rules]

If all rules pass: [Proceed with action]
If any rule fails: [Flag for review, create case, or stop]

## Step 4: [Audit Trail]

Log all rule checks, decisions, and outcomes for review.
```

### Key techniques

- **Embedded expertise** — domain knowledge in `references/`, not in the user's head
- **Validation before action** — apply rules before executing irreversible operations
- **Audit trail** — document what was checked and decided

### Example: `code-review`

```markdown
## Step 3: Apply Review Checklist

Consult `references/review-checklist.md` and evaluate each changed file against:
- Security (OWASP top 10 from `references/owasp-top10.md`)
- Error handling patterns
- Test coverage expectations
- Naming conventions

For each finding, record: file, line, severity, rule, and recommendation.
```

## Combining Patterns

Most skills use more than one pattern. Common combinations:

| Primary Pattern | Combined With | Example |
|----------------|--------------|---------|
| Sequential orchestration | Domain-specific intelligence | `code-review`: sequential steps with checklist-based analysis |
| Sequential orchestration | Iterative refinement | `project-documentation`: sequential discovery with draft-review-refine loop |
| Context-aware selection | Sequential orchestration | `investigation`: select strategy, then execute sequentially |
| Iterative refinement | Domain-specific intelligence | `coding-standard`: draft standard, validate against conventions, refine |

When combining, use one pattern as the primary structure (the step sequence) and embed the other pattern within specific steps.

## Human Gates in Workflow Steps

The Sequential Orchestration pattern includes **validation gates** — automated checks that verify preconditions before proceeding. **Human gates** are different: they pause execution to ask the user for confirmation before an irreversible operation. Both are workflow controls, but they serve different purposes and appear at different points.

### When to place a human gate

This is the skill-level form of the checkpoint guidance in [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents): build a point where the workflow pauses for human review before an irreversible action. Place a human gate before operations that are expensive or impossible to reverse:
- Posting to external systems (GitHub comments, PR reviews, Slack messages)
- Deleting files, branches, or resources
- Writing to production systems or shared infrastructure
- Committing or pushing changes

Do not place human gates before reversible operations (writing a local file, reading code, running tests). Gates on reversible decisions waste the user's attention and train them to approve without reading.

### How to implement

Use `AskUserQuestion` to present a structured summary of what is about to happen, then handle the response:

```markdown
## Step 4: Post Review to GitHub

Before posting, use `AskUserQuestion` to confirm with the user:
- Show the review summary (number of findings by severity)
- Show the target PR (owner/repo#number)
- Ask whether to post, revise, or cancel

If the user cancels: show the generated review so they can use it manually.
If the user asks to revise: return to Step 3 with their feedback.
```

Note: Do not add `AskUserQuestion` to `allowed-tools` — see [AskUserQuestion Bug](./allowed-tools-AskUserQuestion.md) for details.

### How many gates

Target 2-3 human gates per skill at most. Every gate is friction — a circuit breaker at an irreversible decision, not a toll booth at every step. If a gate never gets rejected, it is not at a real decision point and should be removed. If a gate gets rejected more than 20% of the time, the preceding steps are producing unreliable output and need improvement.

**Before (no human gate — silent external action):**
```markdown
## Step 5: Post Review

Run `scripts/post-review.sh {owner/repo} {pr_number}` to post the review.
```

**After (human gate before irreversible action):**
```markdown
## Step 5: Post Review

Present the review summary to the user and ask for confirmation before posting.
If confirmed, run `scripts/post-review.sh {owner/repo} {pr_number}`.
If rejected, display the review content so the user can post or edit manually.
```

## Ordering Within Steps: Recency Bias

Within any step, the model weights the last instruction or example more heavily than earlier ones. When a step contains multiple conventions, criteria, or examples, place the most critical or representative item last.

This applies to:
- The last item in a numbered checklist within a step
- The last example in a set of canonical examples
- The last validation criterion in a quality check

This is an attention effect, not a logical dependency — it works alongside step ordering (which is driven by dependencies between steps). The model also weights the first item in a sequence more heavily than items in the middle (a "lost in the middle" effect). Both the existing guidance to put critical instructions at the top of a step (to avoid mid-paragraph burial) and this guidance to put the most important list item last target the same enemy: the middle position.

**Before (most critical criterion buried in the middle):**
```markdown
## Step 3: Validate Changes

Check each changed file against:
1. Naming conventions match project style
2. No hardcoded secrets or credentials
3. Error messages include debugging context
4. Import order follows project convention
```

**After (most critical criterion placed last):**
```markdown
## Step 3: Validate Changes

Check each changed file against:
1. Naming conventions match project style
2. Import order follows project convention
3. Error messages include debugging context
4. No hardcoded secrets or credentials
```

## Summary Checklist

1. Choose problem-first or tool-first framing to guide pattern selection
2. Use **sequential orchestration** for fixed-order workflows with step dependencies
3. Use **iterative refinement** for output that improves with review cycles
4. Use **context-aware selection** for workflows that branch based on runtime context
5. Use **domain-specific intelligence** for workflows driven by embedded expertise
6. Include validation gates, bounded loops, decision criteria, or audit trails as appropriate
7. Combine patterns by using one as the primary structure and embedding others within steps
8. Within a step, place the most critical instruction or most representative example last (recency bias)

Cross-references:
- [Skill Decomposition](./skill-decomposition.md) — When and how to split workflows across multiple skills
- [Skill Reference Files](./skill-reference-files.md) — Where to store domain knowledge referenced by workflow steps
- [Progressive Disclosure](./progressive-disclosure.md) — How the three-level architecture supports workflow patterns
- [Context Hygiene](./context-hygiene.md) — Why position effects matter for skill structure
- [Agent Dispatch Namespacing](./agent-dispatch-namespacing.md) — Dispatch agents by `plugin-name:agent-name`, never bare
