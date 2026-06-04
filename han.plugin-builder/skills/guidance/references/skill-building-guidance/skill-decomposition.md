---
paths:
  - "**/skills/**/*.md"
---

# Skill Decomposition

A skill should do one thing well. When a skill handles too many responsibilities, it becomes fragile, hard to debug, and difficult for the LLM to follow consistently. Split monolithic skills into focused units and extract reusable agent definitions.

## The Rules

### Rule: Single responsibility, one skill, one concern

A skill should address a single concern. If a skill does both analysis and integration, or both gathering and posting, it's doing too much.

**Before (monolithic):**
Picture a `pr-review` skill that performs the full code review AND posts it to GitHub. Two fundamentally different concerns:

- **Analysis.** Reading code, applying a checklist, generating findings.
- **Integration.** Calling the GitHub API, handling JSON encoding, managing auth.

Bundling them means a bug in the GitHub posting logic requires debugging the entire review skill, and the code review logic can't be reused without GitHub.

**After (decomposed):**
Split into two skills:

- A review skill. The review itself (analysis only, no GitHub dependency).
- A GitHub-integration skill that runs the review skill, then posts results.

The review logic is now reusable. GitHub bugs are isolated to the integration skill.

### Rule: When to split a skill

Split when:

- The skill has **independent concerns** (analysis vs. integration, gathering vs. posting).
- **A bug in one part** requires debugging unrelated parts.
- **One part is reusable** without the other (for example, code review without GitHub).
- The skill prompt is **so long** the LLM struggles to follow it consistently.

Keep together when:

- The steps are sequential and tightly coupled.
- Splitting would create skills that can't function independently.
- The skill is short and focused even with multiple steps.

### Rule: Extract large inline agent definitions

If a skill contains large blocks of agent instructions inline in the SKILL.md, extract them into standalone agent files under `agents/`.

**Before (inline agents):**
Picture an investigation skill that contains full agent definitions for an investigator agent and a validator agent inline in SKILL.md. Hundreds of lines of protocols mixed with the skill's own steps.

**After (extracted):**
Extract the agents into standalone agent files:

- `agents/evidence-based-investigator.md`
- `agents/adversarial-validator.md`

The skill now references these agents via the `Agent` tool rather than duplicating their definitions inline. The same move applies when a documentation skill carries explorer and content-audit logic inline: extract each into its own file under `agents/`.

## Composition Patterns

### Skills calling skills

Use the `Skill` tool to compose skills. The calling skill orchestrates while the called skill executes its single responsibility.

Two composition patterns exist with different requirements:

- **Orchestration.** Delegating a self-contained task (for example, a PR-posting skill running a review skill). Works inline.
- **Data-fetch.** Retrieving specific values for immediate use. Prefer inline discovery (context injection + Read) over forked sub-skill calls to avoid early-exit failures. See `writing-effective-instructions.md` for details.

See [Skill Composition](./skill-composition.md) for the full pattern.

```markdown
## Step 3: Run Code Review

Use the `Skill` tool to run the code-review skill on the current branch.
```

Add `Skill` to the calling skill's `allowed-tools`:

```yaml
allowed-tools: Bash(gh *), Read, Grep, Glob, Skill, ExitPlanMode
```

### Skills referencing agents

Use the `Agent` tool to dispatch extracted agent definitions for specialized subtasks.

```markdown
## Step 2: Investigate

Use the `Agent` tool with `example-plugin:evidence-based-investigator` to gather evidence.
```

Add `Agent` to the skill's `allowed-tools`:

```yaml
allowed-tools: Read, Grep, Glob, Agent, EnterPlanMode, ExitPlanMode
```

## Summary Checklist

1. One skill, one concern. Split skills with independent responsibilities.
2. Extract large inline agent definitions to `agents/` files.
3. Use the `Skill` tool to compose skills together.
4. Use the `Agent` tool to dispatch extracted agent definitions.
5. Only split when the parts can function independently.

Cross-references:

- [External File References in Agent Definitions](../agent-building-guidelines/agent-external-files.md). Agent file structure constraints.
- [Skill Composition](./skill-composition.md). Orchestration vs data-fetch composition patterns.
- [Agent Dispatch Namespacing](./agent-dispatch-namespacing.md). Name a dispatched agent `your-plugin:agent-name`.
