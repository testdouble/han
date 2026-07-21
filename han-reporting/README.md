# han-reporting

The reporting layer of the Han suite: the skills that turn the work back into something you can share with non-technical
stakeholders. It converts a feature specification into a plain-language stakeholder summary with diagrams, then into a
single self-contained HTML executive report. Reach for it when you need buy-in or feedback from people who will not read
the spec.

**Bundled.** Installed with the `han` meta-plugin. Depends on `han-communication` and `han-core`.

**Getting started:** the skills chain. Run [`/stakeholder-summary`](docs/skills/stakeholder-summary.md) to produce the
summary, then [`/html-summary`](docs/skills/html-summary.md) to turn that summary into a shareable HTML report.

## Skills

- [`/stakeholder-summary`](docs/skills/stakeholder-summary.md) — Turn a feature specification into a plain-language
  stakeholder summary with Mermaid diagrams for user experience and data flow, for feedback before implementation.
- [`/html-summary`](docs/skills/html-summary.md) — Convert a `stakeholder-summary.md` into a single self-contained HTML
  executive report with the bottom line and asks up front; produces the file only, does not publish it.

Its skills dispatch shared agents that live in `han-core` (and, for the readability-editor, in `han-communication`).

## Installation

Add the marketplace to Claude Code, then install the plugin (or install `han` to get it as part of the bundled suite):

```
/plugin marketplace add testdouble/han
/plugin install han-reporting@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
