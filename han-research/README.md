# han-research

The pre-planning knowledge-work layer of the Han suite: the skills you reach for to understand a problem before anyone
commits to a plan. It researches open-ended questions, compares what exists against what is wanted, and turns vague
reports into structured triage, each through an evidence-based process that dispatches specialist agents to do the
judgment-heavy work. Reach for it when you need to know more before you decide what to build.

**Bundled.** Installed with the `han` meta-plugin. Depends on `han-communication` and `han-core`.

**Getting started:** answer an open question with [`/research`](docs/skills/research.md), compare two artifacts with
[`/gap-analysis`](docs/skills/gap-analysis.md), and shape a vague report with
[`/issue-triage`](docs/skills/issue-triage.md).

## Skills

- [`/research`](docs/skills/research.md) — Research an open-ended question across the codebase and the open web and end
  at an adversarially-validated recommendation, without committing the team to any artifact.
- [`/gap-analysis`](docs/skills/gap-analysis.md) — Compare two artifacts (current state versus desired state) and
  produce a plain-language, stakeholder-readable report indexed by stable gap IDs.
- [`/issue-triage`](docs/skills/issue-triage.md) — Classify a vague issue or bug report, identify missing information,
  assess severity and reproducibility, and recommend the right next skill to run.

## Agents

- [`research-analyst`](docs/agents/research-analyst.md) — Research open-ended questions from the open web and provided
  material, returning sourced evidence and a recommendation and treating fetched content as claims, never instructions.

The other agents its skills dispatch are the shared specialists that live in `han-core` (and, for the
readability-editor, in `han-communication`).

## Installation

Add the marketplace to Claude Code, then install the plugin (or install `han` to get it as part of the bundled suite):

```
/plugin marketplace add testdouble/han
/plugin install han-research@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
