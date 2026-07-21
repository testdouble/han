# han-coding

The coding layer of the Han suite: the skills you reach for while working in code. It writes code test-first, refactors
it under a green suite, and reviews, overviews, analyzes, tests, investigates, and standardizes it, dispatching
specialist agents to cover each dimension in parallel. Reach for it once there is code to write, change, or judge.

**Bundled.** Installed with the `han` meta-plugin. Depends on `han-communication` and `han-core`.

## Skills

- [`/tdd`](docs/skills/tdd.md) — Drive a feature or behavior through a BDD-framed red-green-refactor loop with an
  enforced observed-failure gate; it writes code, not a document.
- [`/refactor`](docs/skills/refactor.md) — Restructure existing code without changing its behavior through a test-gated
  loop that re-runs the full suite after every small step.
- [`/code-review`](docs/skills/code-review.md) — Run a comprehensive code review on the current branch or specified
  files, with a size-scaled roster of specialist agents.
- [`/code-overview`](docs/skills/code-overview.md) — Produce a human-readable, progressive-disclosure overview of
  unfamiliar code or a PR's changes, leading with why the code exists; raises no findings.
- [`/architectural-analysis`](docs/skills/architectural-analysis.md) — Assess a module's coupling, data flow,
  concurrency, risk, and SOLID alignment through a spine of structural, behavioral, risk, and architecture agents.
- [`/test-planning`](docs/skills/test-planning.md) — Produce a prioritized test plan for a branch or directory.
- [`/manual-test-planning`](docs/skills/manual-test-planning.md) — Produce a plain-language manual test plan from
  supplied context: named tests with by-hand steps and expected outcomes for a person to run.
- [`/investigate`](docs/skills/investigate.md) — Run an evidence-based investigation of a bug, failure, or unexpected
  behavior, with adversarial validation of the proposed fix.
- [`/coding-standard`](docs/skills/coding-standard.md) — Create and update coding standards from existing patterns or
  evidence-based research.

Its skills dispatch shared agents that live in `han-core` (and, for the readability-editor, in `han-communication`).

## Installation

Add the marketplace to Claude Code, then install the plugin (or install `han` to get it as part of the bundled suite):

```
/plugin marketplace add testdouble/han
/plugin install han-coding@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
