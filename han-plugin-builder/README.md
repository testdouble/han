# han-plugin-builder

The opt-in plugin-building plugin for the Han suite. It carries the authoritative guidance for building Claude Code
skills, agents, and plugins, plus two interview-driven builders that author a new component from scratch and review it
against that guidance. Reach for it when you are building your own skills, agents, or plugins rather than shipping
product features.

**Opt-in.** Installed on its own, not bundled by the `han` meta-plugin. Install it with
`/plugin install han-plugin-builder@han`. Depends on nothing, so it does not pull `han-core` along.

## Skills

- [`/guidance`](docs/skills/guidance.md) — Serve the authoritative guidance for building skills, agents, and plugins, or
  vendor the three plugin-building skills into the current repository under a `plugin-` prefix plus a path-scoped rule
  index (`/guidance init`, refreshed with `/guidance update`).
- [`/skill-builder`](docs/skills/skill-builder.md) — Build a new skill from scratch through an evidence-based interview
  that walks the design tree decision-by-decision, then review the finished files against the guidance and apply every
  fix.
- [`/agent-builder`](docs/skills/agent-builder.md) — Build a new agent from scratch through an evidence-based interview
  that walks the design tree decision-by-decision, then review the finished agent file against the guidance and apply
  every fix.

Its skills author skills and agents; it dispatches no shared agents of its own.

## Installation

Add the marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han-plugin-builder@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
