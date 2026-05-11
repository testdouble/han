# Choosing the Right Model for Agent Definitions

Agents support a `model` frontmatter field that skills do not. Choosing the right model is about matching capability and speed to the task the agent performs. **Cost is not a factor in model selection for our agents.** Choose based on what the task demands, not price.

## The `model` Field

The `model` field in agent frontmatter controls which AI model the agent uses.

**Valid values:**

| Value     | Behavior                                          |
|-----------|---------------------------------------------------|
| `opus`    | Most capable model. Deep reasoning and judgment.  |
| `sonnet`  | Balanced capability and speed.                    |
| `haiku`   | Fastest model. Low-latency, lightweight tasks.    |
| `inherit` | Uses the same model as the user's main session.   |

**Default behavior:** If `model` is omitted, the agent defaults to `inherit`.

**Syntax example:**

```yaml
---
name: my-agent
description: "Does a specific thing"
tools: Read, Glob, Grep
model: sonnet
---
```

## Model Characteristics

| Model   | Capability | Speed   | Best For                                                                                   |
|---------|------------|---------|--------------------------------------------------------------------------------------------|
| `opus`  | Highest    | Slowest | Complex reasoning, nuanced judgment, multi-dimensional analysis, advanced coding           |
| `sonnet`| High       | Fast    | Code generation, data analysis, agentic tool use, structured workflows                     |
| `haiku` | Moderate   | Fastest | Real-time lookups, high-volume processing, simple pattern matching, quick searches         |

## Decision Criteria

Walk through these questions in order to select the right model for an agent:

### 1. Does the agent need to match the user's session model?

Use `inherit` (or omit the field). This is rare. Only appropriate when the agent's task is generic enough that the user's own model choice should carry through. Most agents have a specific cognitive profile that warrants an explicit model.

### 2. Does the agent require complex reasoning, nuanced judgment, or multi-dimensional analysis?

Use `opus`. Signs that an agent needs opus:

- Synthesizing findings across many files and drawing non-obvious conclusions
- Auditing for subtle omissions or inconsistencies
- Exploring large codebases where judgment calls determine search direction
- Making qualitative assessments that require weighing competing factors

### 3. Does the agent perform focused, targeted work with clear procedures?

Use `sonnet`. Signs that an agent fits sonnet:

- Following defined protocols or checklists
- Gathering evidence along well-defined paths
- Validating against known criteria
- Executing structured investigation steps

### 4. Does the agent perform simple, fast lookups or high-volume processing?

Use `haiku`. Signs that an agent fits haiku:

- Quick file searches or pattern matching
- Straightforward Q&A about code
- Simple, repetitive operations at high volume
- Tasks where latency matters more than depth

### Summary Decision Table

| Task Characteristic                                       | Model    |
|-----------------------------------------------------------|----------|
| Must match user's session model                           | `inherit`|
| Complex reasoning, nuanced judgment, synthesis            | `opus`   |
| Focused procedures, structured investigation, checklists  | `sonnet` |
| Fast lookups, simple patterns, high volume                | `haiku`  |

## A Note on Cost

Cost should not influence model selection for our agents. The goal is to pick the model that best fits the task's cognitive demands. Optimizing for cost leads to under-powered agents that produce poor results. A false economy that wastes developer time reviewing bad output and re-running tasks.

## Evidence from Existing Agents

### Han Plugin Agents

Examples from the han plugin illustrate the decision criteria:

| Agent                        | Model    | Rationale                                                                                     |
|------------------------------|----------|-----------------------------------------------------------------------------------------------|
| `codebase-explorer`          | `haiku`  | Fast lookups across config and structure; speed over depth.                                    |
| `content-auditor`            | `haiku`  | Fact extraction and classification against a list. Pattern matching.                           |
| `edge-case-explorer`         | `sonnet` | Open-ended exploration across six dimensions; qualitative judgment on likelihood and severity. |
| `test-engineer`              | `sonnet` | Synthesizes findings across many files; weighs value vs brittleness tradeoffs for test planning.|
| `evidence-based-investigator`| `sonnet` | Follows defined investigation protocols; gathers evidence along structured paths.              |
| `adversarial-validator`      | `sonnet` | Validates against known criteria; executes structured challenge strategies.                    |
| `project-manager`            | `opus`   | Facilitation and synthesis across specialist input; high-judgment.                             |
| `software-architect`         | `opus`   | Synthesizes structural/behavioral/concurrency findings into SOLID recommendations.             |

### Claude Code Built-in Agents

| Agent             | Model     | Rationale                                                           |
|-------------------|-----------|---------------------------------------------------------------------|
| Explore           | `haiku`   | Fast, read-only codebase searches. Speed over depth.                |
| Plan              | `inherit` | Research for planning matches user's session model.                 |
| General-purpose   | `inherit` | Generic delegation. User's model choice carries through.            |

These examples reinforce the decision criteria: opus for synthesis and judgment, sonnet for structured procedures, haiku for fast lookups, inherit for generic tasks.

## Summary Checklist

1. Always set `model` explicitly. Do not rely on the `inherit` default unless `inherit` is the intentional choice.
2. Follow the decision criteria flow: inherit → opus → sonnet → haiku.
3. Never choose a model based on cost.
4. When unsure, prefer `sonnet` as the default. It balances capability and speed well.

## Cross-References

- [Domain Focus](agent-domain-focus.md). A well-specialized agent with precise domain vocabulary may perform well with a faster model (sonnet or haiku), because domain-specific terms activate expert knowledge even in smaller models.
- [Specialization and Model Selection](../specialization-and-model-selection.md). Evidence and mechanism behind why tightly-specified agents can run on smaller models without loss of quality, and where that breaks down.

## Sources

- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents). Documents the `model` field, valid values, defaults, and built-in agent configurations.
- [Choosing the Right Model](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model). Model comparison covering capabilities, speed, and selection criteria.
