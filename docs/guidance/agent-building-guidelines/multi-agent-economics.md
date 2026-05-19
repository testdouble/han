---
paths:
  - "plugin/agents/**/*.md"
---

# Multi-Agent Economics

When a skill dispatches agents via the `Agent` tool, each agent adds latency and token cost. This doc provides the decision framework for when adding agents is justified and when it's wasteful.

This doc is about **whether to add more agents**. For choosing which model tier (opus/sonnet/haiku) a given agent should use, see [Model Selection](./agent-model-selection.md). That decision is about matching capability to task complexity, and cost is not a factor there. Here, cost is a factor: multiplying agents multiplies token spend, and each additional agent must clear a quality bar to justify that spend.

## The Escalation Cascade

Start with the simplest architecture that could work. Advance only when measured quality justifies moving up.

### Level 0: Single Agent

A single well-prompted agent with access to the right tools handles roughly 70% of tasks. Before designing a multi-agent system, verify that one agent with good instructions, domain vocabulary, and tool access cannot achieve acceptable quality.

**When this is enough:** The task is coherent (one domain, one perspective), the output is straightforward to evaluate, and the quality bar can be met by improving instructions rather than adding reviewers.

### Level 1: Worker + Specialist Reviewer

Add a second agent when a single agent cannot reliably self-validate. The worker generates output. The reviewer evaluates it from a different perspective. This is motivated by [self-evaluation bias](./agent-domain-focus.md): agents cannot reliably evaluate their own work because generator biases replicate in evaluation.

**When to escalate here:** The single agent's output consistently fails a specific quality dimension (security, accessibility, domain accuracy) that requires specialist knowledge the worker agent doesn't activate.

### Level 2: Agent Team (3-5 Agents)

Add a team only when the review problem is genuinely multi-dimensional. The output needs evaluation from multiple independent specialist perspectives that cannot be combined into one reviewer without diluting each domain's vocabulary activation.

**When to escalate here:** The worker + reviewer pattern produces good results on one dimension but misses others, and combining review domains into one agent degrades each (the generalist trap described in [Domain Focus](./agent-domain-focus.md)).

**Hard cap:** Teams should not exceed 5 agents. Beyond this, coordination costs consistently exceed production benefits.

## The 45% Threshold

Before adding another agent, ask: does the current architecture achieve more than 45% of optimal quality on the dimension you're trying to improve? If yes, improve the existing agent's instructions, vocabulary, or tool access first. Adding an agent is justified only when a single agent has been optimized and still falls short.

Multi-agent teams only outperform single agents when:

- Tasks decompose into **independent subtasks** with clear interfaces.
- Each subtask activates a **distinct domain** that benefits from separate vocabulary routing.
- The coordination overhead is **less than** the quality improvement.

Sequential reasoning tasks (where each step depends on the previous step's full context) can degrade 39-70% in multi-agent setups because handoffs lose context.

## Scaling Reality

Research on multi-agent scaling (DeepMind, 2025) shows diminishing returns:

| Team Size | Token Cost | Output Quality | Efficiency |
|---|---|---|---|
| 1 agent | 1x | 1x (baseline) | 1.0 |
| 3 agents | ~4x | ~2x | 0.5 |
| 5 agents | ~7x | ~3.1x | 0.44 |
| 7+ agents | ~12x+ | Often less than 4-agent | < 0.3 |

Each additional agent must produce a measurable quality improvement to justify its cost. The efficiency ratio (quality gained / tokens spent) drops with every agent added. Team effectiveness plateaus around 4 agents. Beyond this, coordination costs actively harm output.

## Practical Implications for Skills

When designing a skill that dispatches agents:

1. **Start at Level 0.** Build and test with a single agent first. Measure quality.
2. **Add a reviewer only for a measured gap.** If the single agent misses security issues 60% of the time, add a security reviewer. Don't add reviewers speculatively.
3. **Use parallel dispatch for independent perspectives.** When multiple agents evaluate the same artifact from different angles, dispatch them in parallel (multiple `Agent` tool calls in one message) to avoid sequential latency.
4. **Avoid sequential chains longer than 3 agents.** Each handoff loses context. If you need more than 3 sequential steps, consider whether intermediate results can be written to files (artifact-based handoffs) rather than passed through agent context.
5. **Match team composition to the task.** Not every invocation needs every agent. If a skill dispatches a security reviewer, accessibility reviewer, and performance reviewer, but the current change only affects API endpoints, skip the accessibility reviewer for that run.

## Summary Checklist

1. Start with one well-prompted agent. It handles most tasks.
2. Add a reviewer only when a single agent consistently fails a specific quality dimension.
3. Escalate to a team only when review is genuinely multi-dimensional.
4. Cap teams at 5 agents. Beyond this, coordination costs exceed benefits.
5. Apply the 45% threshold: optimize existing agents before adding new ones.
6. Dispatch independent agents in parallel. Avoid long sequential chains.

Cross-references:

- [Model Selection](./agent-model-selection.md). Choosing which model tier for a given agent (separate from whether to add agents).
- [Domain Focus](./agent-domain-focus.md). Vocabulary routing, self-evaluation bias, and the generalist trap.
- [Skill Decomposition](../skill-building-guidance/skill-decomposition.md). When to split skills vs. when to add agents within a skill.
