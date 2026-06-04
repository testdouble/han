# Entity Taxonomy: Skills, Agents, Hooks

Status: accepted

Authors:
- Brian Hughes (@brianvh)
- River Bailey (@mxriverlynn)

Last Updated: 2026-06-04

References:
- [Claude Code Plugin Reference](https://code.claude.com/docs/en/plugins-reference)
- [Skills](https://code.claude.com/docs/en/skills)
- [Subagents](https://code.claude.com/docs/en/sub-agents)
- [Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Hooks](https://code.claude.com/docs/en/hooks)
- [MCP](https://code.claude.com/docs/en/mcp)

## Commands: Routing Layer (Deprecated)

Commands have been merged into skills in Claude Code. They should no longer be created as separate entities. Skills now handle both the entry point and the process execution. This section is retained for historical context only.

For accuracy: the official docs treat a `commands/` directory of flat `.md` files as a still-supported legacy format (a `commands/deploy.md` and a `skills/deploy/SKILL.md` both produce `/deploy`), and they recommend `skills/` for new plugins rather than calling `commands/` removed. The practical takeaway is unchanged — build skills, not commands — but existing `commands/` files do still load.

## Skills: Process Engine

Deterministic, repeatable processes with consistency and expertise. Can have companion reference folders and external files for support and detail, and scripts to execute. No personality, taste, or adaptive judgment. Just disciplined execution.

Test: *"Can I flowchart every path?"* → Skill.

## Agents: Thinking Layer

Human-analog actors with contextual judgment, taste, and discernment. Orchestrate skills, maintain working memory across workflows, make decisions or escalate to the human.

Test: *"Does this require reasoning about context?"* → Agent.

## Hooks: Event Layer

Automatic triggers on system events. No user invocation. Complement skills (explicit) with implicit triggers.

## Composition Rules

- Skills execute deterministic processes. They may invoke other skills for fixed sub-steps, or dispatch agents for research and validation.
- Agents apply contextual judgment. They orchestrate skills, make decisions, and can dispatch other agents for parallel independent workstreams.
- Hooks trigger skills or agents reactively on system events.
- The key distinction: skills follow a fixed flowchart (even when invoking other components); agents decide what to do based on context.

## Decision Heuristic

1. Deterministic, flowchartable, repeatable process? → **Skill**
2. Contextual judgment, taste and opinion, coordination, multi-step decisions? → **Agent**
3. Fires automatically on an event? → **Hook**
4. Multiple of the above? → Build separately, compose.

## Scope

This taxonomy covers behavioral plugin components (skills, agents, hooks). Infrastructure components like MCP servers and LSP servers are also valid plugin components. See the official Claude Code plugin docs for details.
