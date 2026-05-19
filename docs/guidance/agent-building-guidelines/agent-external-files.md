---
paths:
  - "plugin/agents/**/*.md"
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
  evidence-based-investigator.md
  adversarial-validator.md
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

## Existing Agents as Evidence

Agents in the han plugin demonstrate this pattern. Each is fully self-contained with all content inlined. For example:

- **evidence-based-investigator.md.** Defines 5 investigation protocols entirely inline (Search for Direct Evidence, Trace Code Paths, Check Git History, Examine Test Coverage, Map Dependencies). No external references.
- **codebase-explorer.md.** Defines exploration strategy, universal checklist, and feature-type-specific checklists entirely inline. No external references.

No agent references external files, scripts, or uses context injection commands.

## What to Do Instead

When building agents that need substantial reference content:

1. **Inline the content.** Write protocols, strategies, and reference material directly in the agent `.md` file. Both existing agents demonstrate this pattern effectively.
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
