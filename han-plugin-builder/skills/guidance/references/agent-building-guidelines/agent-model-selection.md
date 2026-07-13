---
paths:
  - "**/agents/**/*.md"
---

# Choosing the Right Model for Agent Definitions

Han agents run across hosts with different model namespaces. Omit the `model` field in portable agent definitions so the host uses the operator's configured model. **Cost is not a factor when an operator chooses that model.** Choose based on what the work demands, not price.

## The `model` Field

The `model` field is host-specific. Claude Code accepts its own aliases and model IDs, while other hosts resolve different names.

**Claude Code values:**

| Value     | Behavior                                          |
|-----------|---------------------------------------------------|
| `opus`    | Most capable model. Deep reasoning and judgment.  |
| `sonnet`  | Balanced capability and speed.                    |
| `haiku`   | Fastest model. Low-latency, lightweight tasks.    |
| `inherit` | Uses the same model as the user's main session.   |

If `model` is omitted, Claude Code defaults to `inherit`. Other hosts apply their own default or configured sub-agent model.

**Portable syntax:**

```yaml
---
name: my-agent
description: "Does a specific thing"
tools: Read, Glob, Grep
---
```

**Claude Code resolution order.** When an agent runs, Claude Code resolves the model from the first source that is set:

1. The `CLAUDE_CODE_SUBAGENT_MODEL` environment variable.
2. The model chosen at dispatch time.
3. The agent definition's `model` frontmatter.
4. The main conversation's model.

Han omits agent-level and dispatch-time model values. This keeps Claude aliases out of non-Claude hosts and leaves model selection with the operator. A host-specific plugin may pin a model only when it does not claim cross-host compatibility.

## Claude Code Model Characteristics

| Model   | Capability | Speed   | Best For                                                                                   |
|---------|------------|---------|--------------------------------------------------------------------------------------------|
| `opus`  | Highest    | Slowest | Complex reasoning, nuanced judgment, multi-dimensional analysis, advanced coding           |
| `sonnet`| High       | Fast    | Code generation, data analysis, agentic tool use, structured workflows                     |
| `haiku` | Moderate   | Fastest | Real-time lookups, high-volume processing, simple pattern matching, quick searches         |

## Operator Decision Criteria

Use these questions when configuring the host's session or sub-agent model. Do not encode the answer in a portable agent definition.

### 1. Should agents match the session model?

Use the host's inheritance or default behavior. This is Han's portable default and lets the operator change models without editing plugin files.

### 2. Does the work require complex reasoning, nuanced judgment, or multi-dimensional analysis?

Choose the strongest model available on the host. Signs include:

- Synthesizing findings across many files and drawing non-obvious conclusions
- Auditing for subtle omissions or inconsistencies
- Exploring large codebases where judgment calls determine search direction
- Making qualitative assessments that require weighing competing factors

### 3. Does the work follow focused procedures?

Choose a balanced general-purpose model. Signs include:

- Following defined protocols or checklists
- Gathering evidence along well-defined paths
- Validating against known criteria
- Executing structured investigation steps

### 4. Does the work consist of simple, high-volume lookups?

Choose the host's fastest capable model. Signs include:

- Quick file searches or pattern matching
- Straightforward Q&A about code
- Simple, repetitive operations at high volume
- Tasks where latency matters more than depth

### Summary Decision Table

| Task characteristic                                    | Host configuration                  |
|--------------------------------------------------------|-------------------------------------|
| Must match the user's session model                    | Inherit or use the host default     |
| Complex reasoning, nuanced judgment, synthesis         | Strongest available model           |
| Focused procedures, structured investigation, checks  | Balanced general-purpose model      |
| Fast lookups, simple patterns, high volume             | Fastest model that meets the demand |

## A Note on Cost

Cost should not influence model selection. The goal is to pick the model that best fits the task's cognitive demands. Optimizing for cost leads to under-powered agents that produce poor results. A false economy that wastes developer time reviewing bad output and re-running tasks.

## Evidence from Agent Archetypes

### Mapping Archetypes to Tiers

These archetypes illustrate the decision criteria. Match the agent you are building to the closest archetype:

| Agent Archetype                                              | Model    | Rationale                                                                                     |
|-------------------------------------------------------------|----------|-----------------------------------------------------------------------------------------------|
| Structure-and-config explorer                               | `haiku`  | Fast lookups across config and structure; speed over depth.                                    |
| Fact extractor / classifier against a fixed list            | `haiku`  | Fact extraction and classification against a list. Pattern matching.                           |
| Open-ended edge-case explorer                               | `sonnet` | Open-ended exploration across several dimensions; qualitative judgment on likelihood and severity. |
| Test planner across many files                              | `sonnet` | Synthesizes findings across many files; weighs value vs brittleness tradeoffs for test planning.|
| Protocol-following investigator                             | `sonnet` | Follows defined investigation protocols; gathers evidence along structured paths.              |
| Rubric-based validator                                      | `sonnet` | Validates against known criteria; executes structured challenge strategies.                    |
| Facilitator synthesizing many specialists                   | `opus`   | Facilitation and synthesis across specialist input; high-judgment.                             |
| Architect synthesizing cross-cutting findings               | `opus`   | Synthesizes structural/behavioral/concurrency findings into SOLID recommendations.             |

The shape: fast lookup and classification agents fit haiku; structured-protocol agents working against fixed rubrics fit sonnet; open-ended synthesis agents weighing competing factors over unbounded input fit opus.

### Claude Code Built-in Agents

| Agent             | Model     | Rationale                                                           |
|-------------------|-----------|---------------------------------------------------------------------|
| Explore           | `haiku`   | Fast, read-only codebase searches. Speed over depth.                |
| Plan              | `inherit` | Research for planning matches user's session model.                 |
| General-purpose   | `inherit` | Generic delegation. User's model choice carries through.            |
| statusline-setup  | `sonnet`  | Focused configuration task with a clear procedure.                  |
| claude-code-guide | `haiku`   | Fast Q&A lookups against Claude Code documentation.                 |

These examples show how a host operator can choose a model: stronger models for synthesis and judgment, balanced models for structured procedures, faster models for lookups, or the session model for generic tasks.

## Summary Checklist

1. Omit `model` from an agent that must run across hosts.
2. Never pass a host-specific model name from a portable skill.
3. Let the operator configure the host's session or sub-agent model.
4. Never choose a model based on cost.

## Cross-References

- [Domain Focus](./agent-domain-focus.md). A well-specialized agent with precise domain vocabulary may perform well with a faster model (sonnet or haiku), because domain-specific terms activate expert knowledge even in smaller models.
- [Specialization and Model Selection](../specialization-and-model-selection.md). Evidence and mechanism behind why tightly-specified agents can run on smaller models without loss of quality, and where that breaks down.

## Sources

- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents). Documents the `model` field, valid values, defaults, and built-in agent configurations.
- [Choosing the Right Model](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model). Model comparison covering capabilities, speed, and selection criteria.
