---
paths:
  - "**/skills/**/*.md"
  - "**/agents/**/*.md"
---

# Agent Dispatch Namespacing

When a skill dispatches a sub-agent, it must name the agent by the namespace of
the plugin that **defines** the agent. If a plugin named `example-plugin`
defines the agent, every dispatch uses `example-plugin:agent-name`. A bare name
and a meta-plugin prefix that has no agents are both wrong.

## The Rules

### Rule: Dispatch agents by `your-plugin:agent-name`

In every `Agent` tool call, set `subagent_type` to the fully-qualified name:

```
subagent_type: "example-plugin:structural-analyst"
```

The same applies to dispatch-instruction prose inside a skill. Write "Launch
`example-plugin:adversarial-validator`", not "Launch `adversarial-validator`".
The model reads the skill top to bottom and carries whatever name it finds to
the dispatch, so the roster tables, the per-agent prompt lists, and the prose
all use the qualified name. Mixing qualified and bare names in one skill is the
inconsistency that produces a dispatch bug.

### Rule: Never use a meta-plugin prefix for an agent

A meta-plugin is a plugin with no components of its own. Picture a plugin named
`example` that has no agents, skills, or commands; it only declares `example.core`
and `example.github` as dependencies so installing it pulls them in. A dependency
is installed as its own plugin and keeps its own namespace. Depending on
`example.core` does not re-export `example.core`'s agents under `example:`. So
`example:project-manager` resolves to nothing, because the `example` plugin
contains no `project-manager`.

### Rule: Qualify skill cross-references the same way

A skill that tells the reader to run another skill uses the same defining
plugin's namespace. Write `example.core:iterative-plan-review`, not
`example:iterative-plan-review`. Provenance metadata in generated artifacts
follows the same rule: `generated_by: "example.core:gap-analysis"`.

## Why

Claude Code namespaces a plugin's components under that plugin's `name` field.
The plugin reference states it directly: the `name` "is used for namespacing
components", so an agent `agent-creator` in a plugin named `plugin-dev` registers
as `plugin-dev:agent-creator`. If your agents are defined in a plugin whose
`plugin.json` has `"name": "example.core"`, they register as
`example.core:agent-name`.

A bare name resolves only when it is unique across every installed plugin plus
the user and project agent scopes. Generic names like `data-engineer`,
`test-engineer`, or `software-architect` can collide with an agent from another
installed plugin or a user's own `~/.claude/agents`, and the resolver returns
whichever it reaches first. Qualifying the name removes that ambiguity.

## Correct and incorrect

```
# correct
subagent_type: "example.core:risk-analyst"
Launch `example.core:junior-developer` in artifact-review mode.
run `example.core:plan-implementation`

# incorrect
subagent_type: "risk-analyst"             # bare: may resolve to the wrong agent
subagent_type: "example:risk-analyst"     # example has no agents; resolves to nothing
run `example:plan-implementation`         # example has no skills; same failure
```

## Scope note

If your agents do not have the `Agent` tool, an agent never dispatches another
agent directly. This also matches a platform rule: per the [Subagents
documentation](https://code.claude.com/docs/en/sub-agents), subagents cannot
spawn other subagents, so nested delegation must go through skills or be chained
from the main conversation. A routing table inside a coordinator agent can name
the specialists a facilitating skill should bring in; the skill performs the
qualified dispatch. The rule above governs the skills and any documented
invocation example.

Cross-references:
- [Skill Decomposition](./skill-decomposition.md). When a step's judgment belongs in a dispatched agent.
- [Workflow Patterns](./workflow-patterns.md). Common dispatch-and-verify shapes.
- [Entity Taxonomy](../plugin-entity-taxonomy.md). Skills dispatch agents; agents apply judgment.
