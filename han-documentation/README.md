# han-documentation

The documentation layer of the Han suite: the skills you reach for to write down what the team built and decided. It
documents features and systems, records architectural decisions, and captures operational procedures, each through an
evidence-based process that refuses to write speculative docs. Reach for it when something real exists that the team
needs written down.

**Bundled.** Installed with the `han` meta-plugin. Depends on `han-communication` and `han-core`.

**Getting started:** document a feature or system with [`/project-documentation`](docs/skills/project-documentation.md),
record a decision with [`/architectural-decision-record`](docs/skills/architectural-decision-record.md), and capture an
operational procedure with [`/runbook`](docs/skills/runbook.md).

## Skills

- [`/project-documentation`](docs/skills/project-documentation.md) — Create and maintain documentation for features,
  systems, and components.
- [`/architectural-decision-record`](docs/skills/architectural-decision-record.md) — Create, extract, or convert
  architectural decision records.
- [`/runbook`](docs/skills/runbook.md) — Create or update a runbook for a single operational scenario, with a
  symptom-first template and a YAGNI preflight that requires real evidence before writing.

Its skills dispatch shared agents that live in `han-core` (and, for the readability-editor, in `han-communication`).

## Installation

Add the marketplace to Claude Code, then install the plugin (or install `han` to get it as part of the bundled suite):

```
/plugin marketplace add testdouble/han
/plugin install han-documentation@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
