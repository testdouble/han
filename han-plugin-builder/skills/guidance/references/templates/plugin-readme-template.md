# {Plugin Name} Plugin

{One paragraph: what this plugin does, how it does it, and why a reader would reach for it. Keep it to a paragraph. The
per-skill detail lives in each skill's long-form doc under `docs/skills/`, not here.}

{Bundled-vs-opt-in and dependencies. Pick one shape:}

**Bundled.** Installed with the `han` meta-plugin. Depends on `{dependency}`{, `{dependency}`}.

<!-- or -->

**Opt-in.** Installed on its own, not bundled by the `han` meta-plugin. Depends on `{dependency}`{ and requires a
configured {MCP server} MCP server}.

<!-- Optional: one short ordered line only when skills build on each other's output
     (one skill writes a reference file a later skill consumes). Skip it for
     independent-skill plugins. -->

**Getting started:** run [`/first-skill`](docs/skills/first-skill.md) to {produce X}, then
[`/second-skill`](docs/skills/second-skill.md) to {consume it}.

## Skills

<!-- One scent line per skill. Reuse the long-form doc's own canonical summary line;
     do not write a fresh one. No per-skill paragraph, files line, or example prompts. -->

- [`/skill-name`](docs/skills/skill-name.md) — {canonical summary line from the long-form doc}
- [`/another-skill`](docs/skills/another-skill.md) — {canonical summary line from the long-form doc}

<!-- Owned agents: include this section ONLY for han-core and han-communication.
     Every other plugin omits it and uses the shared-agent-dispatch note below instead. -->

## Agents

- [`agent-name`](docs/agents/agent-name.md) — {canonical summary line from the long-form doc}

<!-- Shared-agent-dispatch note: for every plugin that owns no agents (all except
     han-core and han-communication), use this line in place of an Agents section. -->

Its skills dispatch shared agents that live in `han-core` (and, for the readability-editor, in `han-communication`).

## Installation

Add your marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add your-org/your-marketplace
/plugin install {plugin-name}@your-marketplace
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
