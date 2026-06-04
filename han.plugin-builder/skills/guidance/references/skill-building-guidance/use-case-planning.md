---
paths:
  - "**/skills/**/*.md"
---

# Use Case Planning

Before writing a SKILL.md, define 2-3 concrete use cases the skill should handle. Use cases ground the skill in real user workflows rather than abstract capabilities, and they become the test cases you run after building.

Skipping this step leads to skills that sound good in their description but fail in practice — trigger phrases that don't match how users actually ask, missing tool permissions, or domain knowledge gaps that only surface during execution. Spending 10 minutes defining use cases before writing saves iterations later.

This guide covers *pre-development* planning — what happens before iteration 1. For the iterative development process that follows, see [Iterative Plugin Development](../iterative-plugin-development.md).

## The Rules

### Rule: Define 2-3 concrete use cases before building

Each use case should represent a distinct way a user would invoke the skill. Two use cases is the minimum to avoid building a one-trick skill. Three is usually enough to cover the primary workflows without over-engineering.

**Before (no use cases — jumping straight to SKILL.md):**
```yaml
---
name: "project-documentation"
description: "Creates project documentation"
---

## Step 1: Find the project structure
## Step 2: Write documentation
```
This skill was built without thinking about *who* would use it or *how*. The description is vague, the steps are generic, and there's no way to test whether it works.

**After (use cases defined first):**

Use Case 1: Document an existing feature
- **Trigger:** "Document how the authentication system works"
- **Steps:** Discover project structure, trace the feature through code, write documentation
- **Tools:** Read, Grep, Glob, Agent (a codebase-exploration agent)
- **Domain knowledge:** Documentation templates, section structure conventions

Use Case 2: Update outdated documentation
- **Trigger:** "Update the API docs — the endpoints changed last sprint"
- **Steps:** Find existing docs, compare against current code, update with changes
- **Tools:** Read, Grep, Glob, Agent (a content-audit agent)
- **Domain knowledge:** How to identify stale sections, change detection patterns

Use Case 3: Create documentation for a new component
- **Trigger:** "Write docs for the new payment service"
- **Steps:** Scan component structure, identify public interfaces, generate documentation
- **Tools:** Read, Grep, Glob, Agent (a codebase-exploration agent)
- **Domain knowledge:** Component documentation template, API documentation conventions

### Rule: Each use case answers four questions

Every use case must answer these four questions. Missing any one creates a gap that surfaces during development or testing.

| Question | What It Reveals |
|----------|----------------|
| **What does the user want to accomplish?** | The trigger phrases for the description |
| **What multi-step workflow does this require?** | The numbered steps in SKILL.md |
| **What tools are needed?** | The `allowed-tools` frontmatter |
| **What domain knowledge should be embedded?** | The `references/` content |

**Before (incomplete use case):**
```
Use Case: Code review
Trigger: "Review my code"
```
This tells you nothing about the workflow, tools, or knowledge needed.

**After (complete use case):**
```
Use Case: Review current branch for quality issues
Trigger: "Review my code" / "Check this branch" / "Run a code review"
Workflow:
  1. Get current branch and default branch
  2. Read the diff between them
  3. Analyze changes against review checklist
  4. Generate structured findings with severity ratings
Tools: Read, Grep, Glob, Agent (for parallel file analysis)
Domain knowledge: OWASP top 10, code review checklist, severity rating scale
```

Now you know the description needs trigger phrases like "review," "check," and "code review." You know `allowed-tools` needs `Read, Grep, Glob, Agent`. You know `references/` needs a review checklist and OWASP guide.

### Rule: Use cases become your test cases

Each use case is a test case you can run after building the skill. The trigger phrase tests whether the skill activates. The workflow tests whether the steps execute correctly. The expected result tests whether the output meets quality standards.

**Use case as test case:**

```
Test: Document an existing feature
Given: A repository with an authentication system
When: User says "Document how the authentication system works"
Then:
  - Skill triggers (not a sibling like a coding-standard or ADR skill)
  - The codebase-exploration agent discovers auth-related files
  - Output follows documentation template from references/
  - All public interfaces are documented
  - No fabricated details (only documents what exists in code)
```

If a use case can't be turned into a testable scenario, it's too vague. Rewrite it with specific triggers, steps, and expected results.

## Use Case Template

Use this template when planning a new skill. Fill in one copy per use case.

```
Use Case: [Short descriptive name]
Trigger: "[What the user says]" / "[Alternative phrasing]" / "[Another variant]"
Workflow:
  1. [First step — what happens]
  2. [Second step — what happens]
  3. [Continue as needed]
Expected Result: [What the user gets when the skill succeeds]
Tools: [Which tools the skill needs — Read, Grep, Bash, Agent, Skill, etc.]
Domain Knowledge: [Templates, checklists, rules the skill needs to reference]
```

**Filled example:**

```
Use Case: Generate PR description from branch changes
Trigger: "Write a PR description" / "Generate PR summary" / "Draft the PR body"
Workflow:
  1. Check gh CLI is installed and a PR exists for the current branch
  2. Gather branch diff, commit log, and changed file list
  3. Analyze changes to identify the purpose and scope
  4. Generate structured PR description with summary, changes, and test plan
Expected Result: PR description posted to GitHub via gh CLI
Tools: Bash(gh *), Bash(git *), Read, Grep, Glob
Domain Knowledge: PR description template (summary, changes, test plan sections)
```

## Summary Checklist

1. Define 2-3 concrete use cases before writing SKILL.md
2. Each use case answers: what to accomplish, what workflow, what tools, what domain knowledge
3. Include realistic trigger phrases — these feed the `description` field
4. Include expected results — these become your acceptance criteria
5. Convert each use case into a testable scenario after building
6. Use cases end where iteration 1 begins — hand off to the iterative development process

Cross-references:
- [Success Criteria and Testing](./success-criteria-and-testing.md) — How to turn use cases into structured test suites
- [Iterative Plugin Development](../iterative-plugin-development.md) — The development process that follows use case planning
- [Skill Description Frontmatter](./skill-description-frontmatter.md) — Use case trigger phrases inform the description field
