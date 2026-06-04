---
paths:
  - "**/agents/**/*.md"
---

# Graceful Degradation

Agent definitions are self-contained and dispatched by skills. When a skill operates in degraded mode (for example, no git), the agents it dispatches may include steps that depend on git history, branch context, or other tools that may be absent. Without this guidance, agents that fail or produce errors when a tool is missing force the orchestrating skill to add defensive guards around every agent dispatch. An agent that checks tool availability inline and skips gracefully self-adapts to degraded environments.

## The Rules

### Rule: Conditionally skip steps that depend on unavailable tools

Without this rule, an agent always attempts tool-dependent steps, receives empty or error output, and either fails or silently produces incomplete analysis. With no indication to the calling skill or user about what was omitted.

For any step that depends on a tool (git, a CLI, an external API), check availability inline before attempting the step. If the tool is not available, skip the step and note the limitation explicitly in the agent's output.

**Pattern:**

> *"If {tool/data} is not available, skip this step and note this limitation."*

**Before (unconditional):**
```markdown
## Recency Analysis

Run `git log --since="30 days ago" --name-only` to identify recently modified files.
Prioritize test coverage for files changed in the last 30 days.
```

When git is absent, the agent receives an error. The analysis is silently incomplete and no explanation appears in output.

**After (conditional skip):**
```markdown
## Recency Analysis

If git is not available, skip recency analysis and note this limitation.

Run `git log --since="30 days ago" --name-only` to identify recently modified files.
Prioritize test coverage for files changed in the last 30 days.
```

**Noting the limitation** means including a line in the agent's output such as:

> *"Note: git was not available. Recency analysis was skipped."*

This helps the calling skill and user understand why certain analysis was omitted without treating it as a failure.

---

## Summary Checklist

1. Check tool availability inline before tool-dependent steps. Do not assume tools are present.
2. Use the pattern *"If X is not available, skip this step and note this limitation."*
3. Include an explicit note in agent output when a step is skipped due to tool absence.

---

Cross-references:

- [Graceful Degradation (skills)](../skill-building-guidance/graceful-degradation.md). Skill-level multi-mode branching that determines what data is available when the agent is dispatched.
