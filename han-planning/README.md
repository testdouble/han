# han-planning

The planning layer of the Han suite: the skills you reach for before implementation. It specifies what a feature does,
plans how to build it, sequences the build, breaks it into work, and stress-tests plans before you commit, each through
an evidence-based process that dispatches specialist agents to do the judgment-heavy work. Reach for it when you have a
problem to solve and want a durable, reviewed plan before any code is written.

**Bundled.** Installed with the `han` meta-plugin. Depends on `han-communication` and `han-core`.

**Getting started:** the skills chain. Specify with [`/plan-a-feature`](docs/skills/plan-a-feature.md), plan the build
with [`/plan-implementation`](docs/skills/plan-implementation.md), sequence it with
[`/plan-a-phased-build`](docs/skills/plan-a-phased-build.md), and break it into work with
[`/plan-work-items`](docs/skills/plan-work-items.md); stress-test any plan along the way with
[`/iterative-plan-review`](docs/skills/iterative-plan-review.md).

## Skills

- [`/plan-a-feature`](docs/skills/plan-a-feature.md) — Build a feature specification from scratch through an
  evidence-based interview that walks the design tree and dispatches specialist reviewers.
- [`/plan-implementation`](docs/skills/plan-implementation.md) — Turn a feature specification into an implementation
  plan through a project-manager-led team conversation.
- [`/plan-a-phased-build`](docs/skills/plan-a-phased-build.md) — Split a body of context into a numbered sequence of
  vertical-slice build phases, each independently demoable to a real person and each building on the prior.
- [`/plan-work-items`](docs/skills/plan-work-items.md) — Divide a trusted implementation plan into
  independently-grabbable, atomic work items in a single work-items file.
- [`/iterative-plan-review`](docs/skills/iterative-plan-review.md) — Stress-test an already-written plan through
  multiple codebase-grounded review passes.

Its skills dispatch shared agents that live in `han-core` (and, for the readability-editor, in `han-communication`).

## Installation

Add the marketplace to Claude Code, then install the plugin (or install `han` to get it as part of the bundled suite):

```
/plugin marketplace add testdouble/han
/plugin install han-planning@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
