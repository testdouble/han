---
paths:
  - "**/agents/**/*.md"
---

# External File References in Agent Definitions

Agent definitions are self-contained markdown files. Unlike skills, agents do not support external file references. No `references/` folders, no `scripts/` folders, and no context injection commands. All content must be inlined directly in the agent `.md` file.

## The Rule

Agent `.md` files must be entirely self-contained. Do not create subdirectories, companion folders, or use `` !`command` `` syntax in agent definitions.

## Why: Structural Evidence

Four independent pieces of evidence confirm this limitation:

### 1. Directory structure: flat vs. nested

Agents live as flat files in a shared directory:

```
agents/
  generator-agent.md
  evaluator-agent.md
```

Skills each get their own directory with room for sibling folders:

```
skills/
  {skill-name}/
    SKILL.md
    references/        # Optional: reference documents
    scripts/           # Optional: shell scripts
```

There is no per-agent subdirectory to house companion files.

### 2. Plugin structure in CLAUDE.md

The documented plugin structure shows `references/` and `scripts/` only under skills:

```
{plugin-name}/
  agents/
    {agent-name}.md          # Agent definition (frontmatter + prompt body)
  skills/
    {skill-name}/
      SKILL.md               # Skill definition (frontmatter + prompt body)
      references/            # Optional: reference documents injected into context
      scripts/               # Optional: shell scripts used by the skill
```

No equivalent optional folders appear under `agents/`.

### 3. Entity taxonomy

The [Entity Taxonomy](../plugin-entity-taxonomy.md) defines skills as the "Process Engine" that "can have companion reference folders." The agent definition ("Thinking Layer") makes no mention of companion folders or external file support.

### 4. Context injection docs

The [Context Injection Commands](../skill-building-guidance/context-injection-commands.md) documentation describes `` !`command` `` syntax exclusively for SKILL.md files. Agent definitions are not mentioned as supporting this syntax.

## Comparison: Skills vs. Agents

| Capability | Skills | Agents |
|------------|--------|--------|
| `references/` folder | Yes | No |
| `scripts/` folder | Yes | No |
| Context injection (`` !`command` ``) | Yes | No |
| Frontmatter: `allowed-tools` | Yes | No (uses `tools`) |
| Frontmatter: `argument-hint` | Yes | No |
| Frontmatter: `model` | No | Yes |
| Directory structure | Own subdirectory (`skills/{name}/`) | Flat file (`agents/{name}.md`) |

## Agent Frontmatter Fields

Many agents set only `name`, `description`, `tools`, and `model`, but the [Subagents documentation](https://code.claude.com/docs/en/sub-agents) supports more. Only `name` and `description` are required. The others, briefly:

| Field | What it does |
|---|---|
| `tools` | Allowlist of tools the agent may use. Inherits all tools if omitted. |
| `disallowedTools` | Denylist applied on top of `tools`. A tool in both is removed. |
| `model` | Model alias, full model ID, or `inherit`. See [Model Selection](./agent-model-selection.md). |
| `permissionMode` | Permission posture (`default`, `acceptEdits`, `plan`, and so on). |
| `maxTurns` | Cap on agentic turns before the agent stops. |
| `skills` | Skills to preload at startup (full content injected). |
| `mcpServers` | MCP servers available to the agent. |
| `hooks` | Lifecycle hooks scoped to the agent. |
| `memory` | `user`, `project`, or `local` to enable cross-session persistent memory. |
| `background` | `true` to always run the agent as a background task. |
| `effort` | `low`/`medium`/`high`/`xhigh`/`max` effort override. |
| `isolation` | `worktree` to run the agent in a temporary git worktree. |
| `color` | Display color for the agent in the UI. |
| `initialPrompt` | First user turn auto-submitted when the agent runs as a main session via `--agent`. |

### Plugin agents ignore three of these (security boundary)

When an agent is loaded **from a plugin** (which is how every plugin agent ships), Claude Code ignores its `hooks`, `mcpServers`, and `permissionMode` frontmatter. This is a documented security boundary, not a bug: a plugin cannot silently grant itself hooks, MCP access, or a looser permission mode on the operator's machine. Do not rely on any of these three fields in a plugin agent definition; they will be dropped. Source: [Subagents documentation](https://code.claude.com/docs/en/sub-agents).

### Subagents cannot spawn subagents

This is a platform rule: a subagent cannot dispatch another subagent. Nested delegation must go through skills or be chained from the main conversation. Reflect this by not giving your agents the `Agent` tool (see [Agent Dispatch Namespacing](../skill-building-guidance/agent-dispatch-namespacing.md)).

## The Pattern in Practice

Well-built agents are fully self-contained with all content inlined. For example:

- An investigation agent defines its investigation protocols entirely inline (search for direct evidence, trace code paths, check git history, examine test coverage, map dependencies). No external references.
- An exploration agent defines its exploration strategy, universal checklist, and feature-type-specific checklists entirely inline. No external references.

A well-built agent does not reference external files or scripts, and does not use context injection commands.

## What to Do Instead

When building agents that need substantial reference content:

1. **Inline the content.** Write protocols, strategies, and reference material directly in the agent `.md` file.
2. **Keep agents focused.** Agents should orchestrate and make judgment calls. If an agent needs complex procedural steps or reference data, that work likely belongs in a skill.
3. **Delegate to skills.** Agents can dispatch skills for operations that need `references/`, `scripts/`, or context injection. This follows the composition rule: *"agents orchestrate, skills execute."*

## Summary Checklist

1. Agent `.md` files are self-contained. No companion folders or subdirectories.
2. Do not use `` !`command` `` context injection syntax in agent definitions.
3. Do not create `references/` or `scripts/` folders under `agents/`.
4. Inline all protocols, strategies, and reference material directly in the agent file.
5. Delegate complex file-dependent operations to skills.

## Cross-References

- [Entity Taxonomy](../plugin-entity-taxonomy.md). Defines agents as the "Thinking Layer" with no mention of companion folders.
- [Context Injection Commands](../skill-building-guidance/context-injection-commands.md). Documents `` !`command` `` syntax for SKILL.md files only.
