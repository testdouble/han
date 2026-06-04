---
paths:
  - "han.core/skills/**/*.md"
  - "han.github/skills/**/*.md"
  - "han.reporting/skills/**/*.md"
  - "han.feedback/skills/**/*.md"
  - "han.core/agents/**/*.md"
---

# Agent Dispatch Namespacing

When a skill dispatches a sub-agent, it must name the agent by the namespace of
the plugin that **defines** the agent. Every Han agent lives in the `han.core`
plugin, so every dispatch uses `han.core:agent-name`. A bare name and the `han:`
meta-plugin prefix are both wrong.

## The Rules

### Rule: Dispatch agents by `han.core:agent-name`

In every `Agent` tool call, set `subagent_type` to the fully-qualified name:

```
subagent_type: "han.core:structural-analyst"
```

The same applies to dispatch-instruction prose inside a skill. Write "Launch
`han.core:adversarial-validator`", not "Launch `adversarial-validator`". The
model reads the skill top to bottom and carries whatever name it finds to the
dispatch, so the roster tables, the per-agent prompt lists, and the prose all
use the qualified name. Mixing qualified and bare names in one skill is the
inconsistency that caused the original bug.

### Rule: Never use the `han:` meta-plugin prefix for an agent

`han` is a meta-plugin. It has no agents, skills, or commands of its own; it
only declares `han.core`, `han.github`, and `han.reporting` as dependencies so
installing it pulls them in. A dependency is installed as its own plugin and
keeps its own namespace. Depending on `han.core` does not re-export
`han.core`'s agents under `han:`. So `han:project-manager` resolves to nothing,
because the `han` plugin contains no `project-manager`.

### Rule: Qualify Han skill cross-references the same way

A skill that tells the reader to run another Han skill uses the same defining
plugin's namespace. Write `han.core:iterative-plan-review`, not
`han:iterative-plan-review`. Provenance metadata in generated artifacts follows
the same rule: `generated_by: "han.core:gap-analysis"`.

## Why

Claude Code namespaces a plugin's components under that plugin's `name` field.
The plugin reference states it directly: the `name` "is used for namespacing
components", so an agent `agent-creator` in a plugin named `plugin-dev` registers
as `plugin-dev:agent-creator`. Han's agents are defined in the `han.core` plugin
(`han.core/.claude-plugin/plugin.json` has `"name": "han.core"`), so they
register as `han.core:agent-name`.

A bare name resolves only when it is unique across every installed plugin plus
the user and project agent scopes. Generic names like `data-engineer`,
`test-engineer`, or `software-architect` can collide with an agent from another
installed plugin or a user's own `~/.claude/agents`, and the resolver returns
whichever it reaches first. Qualifying the name removes that ambiguity.

## Correct and incorrect

```
# correct
subagent_type: "han.core:risk-analyst"
Launch `han.core:junior-developer` in artifact-review mode.
run `han.core:plan-implementation`

# incorrect
subagent_type: "risk-analyst"          # bare: may resolve to the wrong agent
subagent_type: "han:risk-analyst"      # han has no agents; resolves to nothing
run `han:plan-implementation`          # han has no skills; same failure
```

## Scope note

Han agents do not have the `Agent` tool, so an agent never dispatches another
agent directly. This also matches a platform rule: per the [Subagents
documentation](https://code.claude.com/docs/en/sub-agents), subagents cannot
spawn other subagents, so nested delegation must go through skills or be chained
from the main conversation. The routing tables inside `project-manager` and
`junior-developer` name the specialists a facilitating skill should bring in;
the skill performs the qualified dispatch. The rule above governs the skills
and any documented invocation example.

Cross-references:
- [Skill Decomposition](./skill-decomposition.md). When a step's judgment belongs in a dispatched agent.
- [Workflow Patterns](./workflow-patterns.md). Common dispatch-and-verify shapes.
- [Entity Taxonomy](../plugin-entity-taxonomy.md). Skills dispatch agents; agents apply judgment.
