# han-feedback

The opt-in feedback plugin for the Han suite. It captures structured observations about the Han skills and agents you
just used, so the maintainers hear what worked and what did not. Reach for it at the end of a session when you want to
report back on how the suite is working for you.

**Opt-in.** Installed on its own, not bundled by the `han` meta-plugin. Install it with
`/plugin install han-feedback@han`. Depends on no other Han plugin.

## Skills

- [`/han-feedback`](docs/skills/han-feedback.md) — Capture structured post-session feedback on the Han skills and agents
  you used across the whole `han-*` plugin family, and optionally post it as a GitHub issue to testdouble/han.

## Installation

Add the marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han-feedback@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
