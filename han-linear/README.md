# han-linear

The opt-in Linear plugin for the Han suite. It publishes Han work items to Linear through the Linear MCP server,
resolving the team's real states, labels, Projects, and members before it creates anything. Reach for it when your plan
has been broken into work items and you track that work in Linear.

**Opt-in.** Installed on its own, not bundled by the `han` meta-plugin. Install it with
`/plugin install han-linear@han`. Depends on no other Han plugin and requires a configured Linear MCP server.

## Skills

- [`/work-items-to-linear`](docs/skills/work-items-to-linear.md) — Create one Linear issue per slice from a
  `/plan-work-items` work-items file in a single target team, resolving the team's real workflow states, labels,
  Projects, and members, and linking within-file dependencies as native "blocked by" relations.

## Installation

Add the marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han-linear@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
