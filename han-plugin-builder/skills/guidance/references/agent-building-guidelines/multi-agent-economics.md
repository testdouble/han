---
paths:
  - "**/agents/**/*.md"
---

# Multi-Agent Economics

When a skill dispatches agents via the `Agent` tool, each agent adds latency and token cost. This doc provides the decision framework for when adding agents is justified and when it's wasteful.

This doc is about **whether to add more agents**. For choosing which model tier (opus/sonnet/haiku) a given agent should use, see [Model Selection](./agent-model-selection.md). That decision is about matching capability to task complexity, and cost is not a factor there. Here, cost is a factor: multiplying agents multiplies token spend, and each additional agent must clear a quality bar to justify that spend.

**What "multi-agent" means here.** A skill can dispatch sub-agents in parallel through the `Agent` tool, and each agent's result is summarized back into the dispatching skill's context. This is *not* the experimental Claude Code [agent-teams](https://code.claude.com/docs/en/agent-teams) feature, in which each teammate is a separate Claude session with its own context window and teammates talk to each other. Agent teams cost significantly more (token usage scales linearly per teammate) and are gated behind `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`. The economics below apply to parallel sub-agent dispatch; agent teams cost strictly more for the same head count.

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

**Hard cap (practical heuristic):** Cap teams at about 5 agents. Beyond this, coordination costs consistently exceed production benefits. This is a practical operating limit, not a platform rule, but it sits in the same range as the official agent-teams guidance, which recommends 3-5 teammates ([Agent Teams](https://code.claude.com/docs/en/agent-teams)).

## The 45% Threshold

Before adding another agent, ask: does the current architecture achieve more than 45% of optimal quality on the dimension you're trying to improve? If yes, improve the existing agent's instructions, vocabulary, or tool access first. Adding an agent is justified only when a single agent has been optimized and still falls short.

This threshold tracks a finding from *Towards a Science of Scaling Agent Systems* (Google Research, Google DeepMind, and MIT, 2025): when a single agent already solves a task at roughly 45% accuracy, adding agents yields diminishing or negative returns. See [Sources](#sources).

Multi-agent teams only outperform single agents when:

- Tasks decompose into **independent subtasks** with clear interfaces.
- Each subtask activates a **distinct domain** that benefits from separate vocabulary routing.
- The coordination overhead is **less than** the quality improvement.

Sequential reasoning tasks (where each step depends on the previous step's full context) can degrade sharply in multi-agent setups because handoffs lose context. The same 2025 study reports 39-70% performance degradation for multi-agent variants on strict sequential-reasoning tasks: each handoff is a lossy compression of state, transferring explicit message content but losing the tacit understanding built up during reasoning. See [Sources](#sources).

## Scaling Reality

Multi-agent scaling shows diminishing returns. The 2025 study ran 180 controlled experiments across five architectures and three model families (GPT, Gemini, Claude) and found performance swinging from an 81% boost to a 70% drop depending on the task: parallelizable work benefits from more agents, sequential work degrades. The consistent shape is that the efficiency ratio (quality gained per token spent) falls as agents are added.

The table below is an **illustrative model of that shape**, not data lifted from the study. Use it to reason about the trade-off, not as measured constants:

| Team Size | Token Cost | Output Quality | Efficiency |
|---|---|---|---|
| 1 agent | 1x | 1x (baseline) | 1.0 |
| 3 agents | ~4x | ~2x | 0.5 |
| 5 agents | ~7x | ~3.1x | 0.44 |
| 7+ agents | ~12x+ | Often less than 4-agent | < 0.3 |

Each additional agent must produce a measurable quality improvement to justify its cost. The efficiency ratio drops with every agent added. Team effectiveness plateaus around 4 agents. Beyond this, coordination costs actively harm output.

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

## Sources

- [Towards a Science of Scaling Agent Systems (Google Research / Google DeepMind / MIT, 2025)](https://research.google/blog/towards-a-science-of-scaling-agent-systems-when-and-why-agent-systems-work/). Source for the ~45% capability-saturation threshold, the 39-70% sequential-reasoning degradation range, and the diminishing-returns direction (180 experiments, five architectures, three model families).
- [Building effective agents (Anthropic)](https://www.anthropic.com/engineering/building-effective-agents). "Agentic systems often trade latency and cost for better task performance"; start simple and add agent complexity only when measurement justifies it.
- [Agent Teams (Claude Code docs)](https://code.claude.com/docs/en/agent-teams). The experimental multi-session feature distinct from parallel `Agent`-tool dispatch; token cost scales linearly per teammate; recommends 3-5 teammates.

Cross-references:

- [Model Selection](./agent-model-selection.md). Choosing which model tier for a given agent (separate from whether to add agents).
- [Domain Focus](./agent-domain-focus.md). Vocabulary routing, self-evaluation bias, and the generalist trap.
- [Skill Decomposition](../skill-building-guidance/skill-decomposition.md). When to split skills vs. when to add agents within a skill.
