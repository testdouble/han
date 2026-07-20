# Skills index

Every skill in the Han suite, alphabetized. Each entry is a short scent line and a link to the skill's canonical
long-form doc, which now lives inside the plugin that ships it. For how these skills chain together, see
[Workflows](../workflows.md). To decide which plugin to install, see the [plugin index](../choosing-a-han-plugin.md).

> See also: [Repo root](../../README.md) · [Plugin index](../choosing-a-han-plugin.md) · [Workflows](../workflows.md) ·
> [All agents](../agents/README.md) · [Concepts](../concepts.md) · [Quickstart](../quickstart.md)

## New here?

Start on the [Quickstart](../quickstart.md); it picks the right skill for what you are trying to do right now. If the
skill-and-agent split is fuzzy, read [Concepts](../concepts.md) first.

## Skills

- [`/agent-builder`](../../han-plugin-builder/docs/skills/agent-builder.md) — Build a new agent from scratch through an
  evidence-based interview that walks the design tree decision-by-decision, then review the finished agent file against
  the plugin-building guidance and apply every fix.
- [`/architectural-analysis`](../../han-coding/docs/skills/architectural-analysis.md) — Assess a module's coupling, data
  flow, concurrency, risk, and SOLID alignment through a spine of structural, behavioral, risk, and architecture agents.
- [`/architectural-decision-record`](../../han-core/docs/skills/architectural-decision-record.md) — Create, extract, or
  convert architectural decision records.
- [`/code-overview`](../../han-coding/docs/skills/code-overview.md) — Produce a human-readable, progressive-disclosure
  overview of unfamiliar code or a PR's changes, leading with why the code exists; raises no findings.
- [`/code-overview-to-confluence`](../../han-atlassian/docs/skills/code-overview-to-confluence.md) — Run `/code-overview`
  (changing no code), show it for review, then publish it as one Confluence page after confirmation.
- [`/code-review`](../../han-coding/docs/skills/code-review.md) — Run a comprehensive code review on the current branch
  or specified files, with a size-scaled roster of specialist agents.
- [`/coding-standard`](../../han-coding/docs/skills/coding-standard.md) — Create and update coding standards from
  existing patterns or evidence-based research.
- [`/edit-for-readability`](../../han-communication/docs/skills/edit-for-readability.md) — Rewrite the prose of a target
  you already have against the shared readability standard, preserving every fact.
- [`/gap-analysis`](../../han-core/docs/skills/gap-analysis.md) — Compare two artifacts (current state versus desired
  state) and produce a plain-language, stakeholder-readable report indexed by stable gap IDs.
- [`/guidance`](../../han-plugin-builder/docs/skills/guidance.md) — Serve the authoritative guidance for building skills,
  agents, and plugins, or vendor the plugin-building skills into the current repository (`/guidance init`).
- [`/han-feedback`](../../han-feedback/docs/skills/han-feedback.md) — Capture structured post-session feedback on the Han
  skills and agents you used, and optionally post it as a GitHub issue to testdouble/han.
- [`/html-summary`](../../han-reporting/docs/skills/html-summary.md) — Convert a `stakeholder-summary.md` into a single
  self-contained HTML executive report; produces the file only, does not publish it.
- [`/investigate`](../../han-coding/docs/skills/investigate.md) — Run an evidence-based investigation of a bug, failure,
  or unexpected behavior, with adversarial validation of the proposed fix.
- [`/investigate-to-confluence`](../../han-atlassian/docs/skills/investigate-to-confluence.md) — Run `/investigate`
  (changing no code), show the report for review, then publish it as one Confluence page after confirmation.
- [`/issue-triage`](../../han-core/docs/skills/issue-triage.md) — Classify a vague issue or bug report, identify missing
  information, assess severity and reproducibility, and recommend the right next skill to run.
- [`/iterative-plan-review`](../../han-planning/docs/skills/iterative-plan-review.md) — Stress-test an already-written
  plan through multiple codebase-grounded review passes.
- [`/markdown-to-confluence`](../../han-atlassian/docs/skills/markdown-to-confluence.md) — Publish one local Markdown
  file to a user-specified Confluence location; defaults to an unpublished draft.
- [`/plan-a-feature`](../../han-planning/docs/skills/plan-a-feature.md) — Build a feature specification from scratch
  through an evidence-based interview that walks the design tree and dispatches specialist reviewers.
- [`/plan-a-feature-to-confluence`](../../han-atlassian/docs/skills/plan-a-feature-to-confluence.md) — Run
  `/plan-a-feature`, show it for review, then publish the spec and its companion artifacts as a Confluence page tree.
- [`/plan-a-phased-build`](../../han-planning/docs/skills/plan-a-phased-build.md) — Split a body of context into a
  numbered sequence of vertical-slice build phases, each independently demoable to a real person and each building on
  the prior.
- [`/plan-implementation`](../../han-planning/docs/skills/plan-implementation.md) — Turn a feature specification into an
  implementation plan through a project-manager-led team conversation.
- [`/plan-work-items`](../../han-planning/docs/skills/plan-work-items.md) — Divide a trusted implementation plan into
  independently-grabbable, atomic work items in a single work-items file.
- [`/post-code-review-to-pr`](../../han-github/docs/skills/post-code-review-to-pr.md) — Run `/code-review` against a
  GitHub PR and post the review as comments, after a clarity check on the drafted review body.
- [`/project-discovery`](../../han-core/docs/skills/project-discovery.md) — Scan the repository for languages,
  frameworks, tooling, and structure, and write a concise reference section into AGENTS.md or CLAUDE.md.
- [`/project-documentation`](../../han-core/docs/skills/project-documentation.md) — Create and maintain documentation for
  features, systems, and components.
- [`/project-documentation-to-confluence`](../../han-atlassian/docs/skills/project-documentation-to-confluence.md) — Run
  `/project-documentation`, show it for review, then publish it to a user-specified Confluence location.
- [`/readability-guidance`](../../han-communication/docs/skills/readability-guidance.md) — Surface the shared
  readability standard into a calling skill's own context so it drafts in voice and self-checks against one canonical
  copy.
- [`/refactor`](../../han-coding/docs/skills/refactor.md) — Restructure existing code without changing its behavior
  through a test-gated loop that re-runs the full suite after every small step.
- [`/research`](../../han-core/docs/skills/research.md) — Research an open-ended question across the codebase and the
  open web and end at an adversarially-validated recommendation, without committing the team to any artifact.
- [`/runbook`](../../han-core/docs/skills/runbook.md) — Create or update a runbook for a single operational scenario,
  with a symptom-first template and a YAGNI preflight that requires real evidence before writing.
- [`/skill-builder`](../../han-plugin-builder/docs/skills/skill-builder.md) — Build a new skill from scratch through an
  evidence-based interview that walks the design tree decision-by-decision, then review the finished files against the
  plugin-building guidance and apply every fix.
- [`/stakeholder-summary`](../../han-reporting/docs/skills/stakeholder-summary.md) — Turn a feature specification into a
  plain-language stakeholder summary with Mermaid diagrams, for feedback before implementation.
- [`/tdd`](../../han-coding/docs/skills/tdd.md) — Drive a feature or behavior through a BDD-framed red-green-refactor
  loop with an enforced observed-failure gate; it writes code, not a document.
- [`/test-planning`](../../han-coding/docs/skills/test-planning.md) — Produce a prioritized test plan for a branch or
  directory.
- [`/update-pr-description`](../../han-github/docs/skills/update-pr-description.md) — Generate a PR description from the
  current branch's changes, conforming to the repository's PR template when one exists.
- [`/work-items-to-issues`](../../han-github/docs/skills/work-items-to-issues.md) — Publish each item in a
  `/plan-work-items` work-items file as a GitHub issue in its target repo, with within-repo blockers linked.
- [`/work-items-to-jira`](../../han-atlassian/docs/skills/work-items-to-jira.md) — Create one Jira ticket per slice from
  a `/plan-work-items` work-items file in a single target project.
- [`/work-items-to-linear`](../../han-linear/docs/skills/work-items-to-linear.md) — Create one Linear issue per slice
  from a `/plan-work-items` work-items file in a single target team, resolving the team's real states, labels, Projects,
  and members before creating anything.

## Adding a skill?

See [Contributing](../../CONTRIBUTING.md) for the full process and
[the skill template](../templates/skill-long-form-template.md) for the long-form layout. Add the skill's long-form doc
under its plugin's `docs/skills/`, a scent line to that plugin's README, and one alphabetized entry here, reusing the
long-form doc's summary line as the canonical scent so the three do not drift.
