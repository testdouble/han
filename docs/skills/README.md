# Skills

All skills in the Han suite, grouped by the plugin that ships them. `han-core` carries enough skills to group by purpose, so it has sub-categories; the other plugins are flat lists. Each entry is a one-sentence scent line plus a link to the canonical long-form doc.

> See also: [Plugin landing page](../../README.md) · [Concepts](../concepts.md) · [Quickstart](../quickstart.md) · [All agents](../agents/README.md) · [Sizing](../sizing.md) · [YAGNI](../yagni.md)

## New here?

Start on the [Quickstart](../quickstart.md). It picks the right skill for what you are trying to do right now. If the skill / agent split is fuzzy, read [Concepts](../concepts.md) first.

## han-core

The base plugin. It carries the research, analysis, documentation, and operations skills, plus every agent those skills dispatch. Grouped by purpose below.

### Triage & research

Skills for triaging an incoming report and researching your options, with evidence to back it.

- **[`/issue-triage`](./han-core/issue-triage.md).** Classify a vague issue or bug report, identify missing information, assess severity and reproducibility, and recommend the right next skill to run.
- **[`/research`](./han-core/research.md).** Research an open-ended question: options, possible solutions, prior art, or how something works. Search the codebase and the open web, and end at an adversarially-validated recommendation without committing the team to any artifact. The question-shaped sibling of `/investigate`; scales with [size](../sizing.md).

### Comparing artifacts

Skills for comparing two artifacts against each other.

- **[`/gap-analysis`](./han-core/gap-analysis.md).** Compare two artifacts (current state vs. desired state, for example spec vs. implementation, or PRD vs. shipped feature) and produce a plain-language, stakeholder-readable report indexed by stable gap IDs. Dispatches `gap-analyzer` for the primary analysis, then runs a validator-and-augmenter swarm by default. That swarm always includes `adversarial-validator` and `junior-developer` (actor-perspective sweep), adds `evidence-based-investigator` when the current state is concrete, and adds domain specialists plus `project-manager` at medium and large sizes. Opt out with `no swarm` for the lightweight pass.

### Discovery & context

Skills that produce context every other skill benefits from.

- **[`/project-discovery`](./han-core/project-discovery.md).** Scan the repository for languages, frameworks, tooling, and structure. Writes a concise reference section into AGENTS.md or CLAUDE.md for other skills.
- **[`/project-documentation`](./han-core/project-documentation.md).** Create and maintain documentation for features, systems, and components.

### Editing & readability

Skills for rewriting an existing deliverable to read plainly.

- **[`/edit-for-readability`](./han-core/edit-for-readability.md).** Rewrite the prose of a target you already have (a file, pasted text, or a draft from the conversation) against the shared readability standard, preserving every fact. Dispatches `readability-editor`; the standalone, on-demand counterpart to the readability pass the synthesis skills run inside their own output.

### Conventions & decisions

Skills for recording how the team works.

- **[`/architectural-decision-record`](./han-core/architectural-decision-record.md).** Create, extract, or convert architectural decision records.

### Operations

Skills for capturing operational knowledge in artifacts the next on-call engineer can use.

- **[`/runbook`](./han-core/runbook.md).** Create or update a runbook for a single operational scenario (alert that has fired, incident, recurring task, known failure mode). Symptom-first template with imperative-voice procedure, expected output per step, escalation conditions, and rollback. Applies a YAGNI preflight that requires real evidence before writing.

## han-planning

The planning layer: the skills for specifying *what* a feature does, planning *how* to build it, sequencing the build, breaking it into work, and stress-testing plans before you commit. Depends on `han-core`; bundled by the `han` meta-plugin.

- **[`/plan-a-feature`](./han-planning/plan-a-feature.md).** Build a feature specification from scratch through an evidence-based interview that walks the design tree and dispatches specialist reviewers.
- **[`/plan-implementation`](./han-planning/plan-implementation.md).** Turn a feature specification into an implementation plan through a project-manager-led team conversation.
- **[`/plan-a-phased-build`](./han-planning/plan-a-phased-build.md).** Split a body of context (gap analysis, PRD, design doc, feature spec, requirements list) into a numbered sequence of vertical-slice build phases, each independently demoable to a real person and each building on the prior. Dispatches `information-architect` against the rendered outline to verify findability, EPPO standalone-ness of phase entries, and progressive comprehension.
- **[`/iterative-plan-review`](./han-planning/iterative-plan-review.md).** Stress-test an already-written plan through multiple codebase-grounded review passes.
- **[`/plan-work-items`](./han-planning/plan-work-items.md).** Divide a trusted implementation plan into independently-grabbable work items in a single work-items file.

## han-coding

The coding layer: the skills you reach for while working in code. Writing it, reviewing it, analyzing it, testing it, investigating it, and standardizing it. Depends on `han-core`; bundled by the `han` meta-plugin.

- **[`/tdd`](./han-coding/tdd.md).** Drive a feature or behavior through a BDD-framed red-green-refactor loop. Builds a behavior test list, enforces an observed-failure gate (no production code until a test has been run and seen to fail), works outside-in for user-facing behavior, and applies the project's coding standards and ADRs in green (correctness) and refactor (full conformance plus YAGNI). It writes code, not a document.
- **[`/refactor`](./han-coding/refactor.md).** Restructure existing code without changing its behavior. Takes a named target (files, a module, a named smell, or the findings of a prior `/code-review` or `/architectural-analysis`), refuses to start without a green suite covering that target, plans a sequence of small named refactorings, re-runs the full suite after every step, and stops hard when changes spread beyond the declared scope. It writes code, not a document; cleanup inside an active TDD cycle belongs to `/tdd`'s refactor step instead.
- **[`/code-review`](./han-coding/code-review.md).** Run a comprehensive code review on the current branch or specified files. Always dispatches `junior-developer` and `adversarial-security-analyst`, and conditionally adds `test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, `devops-engineer`, or `on-call-engineer` when the changed files trigger their domain. Roster scales with [size](../sizing.md).
- **[`/code-overview`](./han-coding/code-overview.md).** Produce a human-readable, progressive-disclosure overview of unfamiliar code (code mode) or a PR's changes (PR mode). It leads with *why* the code exists, meaning the problem it solves or the goal it serves, then flows into what it does, how it works, and where to start. The result goes to a scratch file at minimal technical detail: understand-now orientation, not durable docs and not a quality review. Dispatches `codebase-explorer` scaled with [size](../sizing.md); raises no findings.
- **[`/architectural-analysis`](./han-coding/architectural-analysis.md).** Deep architectural analysis of a module: coupling, data flow, concurrency, risk, and SOLID alignment. Always dispatches the `structural-analyst` / `behavioral-analyst` / `risk-analyst` / `software-architect` spine, and adds `concurrency-analyst`, `adversarial-security-analyst`, `data-engineer`, `devops-engineer`, `on-call-engineer`, `codebase-explorer`, or `system-architect` by signal. Roster scales with [size](../sizing.md).
- **[`/test-planning`](./han-coding/test-planning.md).** Produce a prioritized test plan for a branch or directory. Dispatches `test-engineer` and `edge-case-explorer`, plus `concurrency-analyst` or `adversarial-security-analyst` when the files call for it.
- **[`/investigate`](./han-coding/investigate.md).** Evidence-based investigation of bugs, failures, and unexpected behavior, with adversarial validation of the proposed fix.
- **[`/coding-standard`](./han-coding/coding-standard.md).** Create and update coding standards from existing patterns or evidence-based research.

## han-github

GitHub-facing skills that talk to GitHub through the `gh` CLI. Depends on `han-core`.

- **[`/post-code-review-to-pr`](./han-github/post-code-review-to-pr.md).** Run `/code-review` against a GitHub PR and post the review as comments, after a `junior-developer` clarity check on the drafted review body.
- **[`/update-pr-description`](./han-github/update-pr-description.md).** Generate a PR description from the current branch's changes, conforming to the repository's PR template when one exists.
- **[`/work-items-to-issues`](./han-github/work-items-to-issues.md).** Publish each item in a `/plan-work-items` work-items file as a GitHub issue in its target repo, with within-repo blockers linked, screenshots copied into the repo, and no label or assignee by default.

## han-reporting

Skills for turning the work back into something sharable with non-technical stakeholders. Depends on `han-core`.

- **[`/stakeholder-summary`](./han-reporting/stakeholder-summary.md).** Turn a feature specification into a plain-language stakeholder summary with Mermaid diagrams for user experience and data flow, to get non-technical feedback before implementation kicks off.
- **[`/html-summary`](./han-reporting/html-summary.md).** Convert a `stakeholder-summary.md` (from [`/stakeholder-summary`](./han-reporting/stakeholder-summary.md)) into a single self-contained HTML executive report: bottom line and asks up front, mermaid diagrams inlined, styled with a Test Double-derived palette. Produces the HTML file only; does not publish it.

## han-feedback

The opt-in feedback plugin. It captures observations about the Han suite itself. The `han` meta-plugin does not bundle it; install it on its own with `/plugin install han-feedback@han`. Depends on `han-core`.

- **[`/han-feedback`](./han-feedback/han-feedback.md).** Capture structured post-session feedback on the Han skills and agents you used across the whole `han-*` plugin family, and optionally post it as a GitHub issue to testdouble/han.

## han-atlassian

The opt-in Atlassian plugin. It publishes Han artifacts to Confluence and Jira through the Atlassian MCP server. The `han` meta-plugin does not bundle it; install it on its own with `/plugin install han-atlassian@han`. Requires a configured Atlassian MCP server. Depends on `han-core`, `han-planning`, and `han-coding`, because its wrapper skills run skills from each.

- **[`/markdown-to-confluence`](./han-atlassian/markdown-to-confluence.md).** Publish one local Markdown file to a user-specified Confluence location, creating a new page or updating an existing one. Defaults to an unpublished draft. Requires the user to name the destination (a page URL, or a space plus parent page); it does not search Confluence for the right place. Posts an existing file; it does not generate documentation.
- **[`/project-documentation-to-confluence`](./han-atlassian/project-documentation-to-confluence.md).** Run `/project-documentation` to write feature documentation to a temporary file, show it for review, then publish it to a user-specified Confluence location with `/markdown-to-confluence` after confirmation. Requires the user to name the destination (a page URL, or a space plus parent page); it does not search Confluence for the right place.
- **[`/investigate-to-confluence`](./han-atlassian/investigate-to-confluence.md).** Run `/investigate` to root-cause a bug or unexpected behavior, writing the investigation report to a temporary file (and changing no code), then show it for review. Publish that single report as one page to a user-specified Confluence location with `/markdown-to-confluence` after confirmation. Requires the user to name the destination (a page URL, or a space plus parent page); it does not search Confluence for the right place.
- **[`/code-overview-to-confluence`](./han-atlassian/code-overview-to-confluence.md).** Run `/code-overview` to produce a progressive-disclosure overview of unfamiliar code or a PR's changes, writing it to a scratch file (and changing no code), then show it for review. Publish that single overview as one page to a user-specified Confluence location with `/markdown-to-confluence` after confirmation. Requires the user to name the destination (a page URL, or a space plus parent page); it does not search Confluence for the right place.
- **[`/plan-a-feature-to-confluence`](./han-atlassian/plan-a-feature-to-confluence.md).** Run `/plan-a-feature` to build a feature specification in a temporary folder, show it for review, then publish it to a user-specified Confluence location with `/markdown-to-confluence` after confirmation. The spec becomes a parent page; each companion artifact (decision log, team findings, technical notes) becomes a child page beneath it. Requires the user to name the destination (a page URL, or a space plus parent page); it does not search Confluence for the right place.
- **[`/work-items-to-jira`](./han-atlassian/work-items-to-jira.md).** Create one Jira ticket per slice from a `/plan-work-items` work-items file, in a single target project. Defaults to a Story, unassigned, in the backlog, with the reporter taken from the Atlassian MCP identity; epic parenting, issue type, assignee, and target column are optional overrides. The Jira sibling of `/work-items-to-issues`.

## han-linear

The opt-in Linear plugin. It publishes Han work items to Linear through the Linear MCP server. The `han` meta-plugin does not bundle it; install it on its own with `/plugin install han-linear@han`. Requires a configured Linear MCP server. Depends on `han-core`.

- **[`/work-items-to-linear`](./han-linear/work-items-to-linear.md).** Create one Linear issue per slice from a `/plan-work-items` work-items file, in a single target team. Reads the team's real workflow states, labels, Projects, and members, and resolves every option against them before creating anything. It defaults each issue to the team's initial state, unassigned, and uncategorized, with optional state, labels, assignee, parent (sub-issue), and Project. Links within-file `Depends on` lines as native Linear "blocked by" relations. The Linear sibling of `/work-items-to-jira` and `/work-items-to-issues`.

## han-plugin-builder

The opt-in plugin-building plugin. It carries the authoring guidance for skills, agents, and plugins, plus two interview-driven builders that author a new component from scratch and review it against that guidance. It depends on nothing, and the `han` meta-plugin does not bundle it; install it on its own with `/plugin install han-plugin-builder@han`.

- **[`/guidance`](./han-plugin-builder/guidance.md).** Serve the authoritative guidance for building skills, agents, and plugins, or vendor all three plugin-building skills into the current repository's `.claude/skills/` under a `plugin-` prefix (`plugin-guidance`, `plugin-skill-builder`, `plugin-agent-builder`) plus a path-scoped rule index (`/guidance init`) so the skills run and the guidance surfaces with no dependency on the plugin (`/guidance update` refreshes a vendored copy).
- **[`/skill-builder`](./han-plugin-builder/skill-builder.md).** Build a new skill from scratch through an evidence-based interview that walks the skill's design tree decision-by-decision, then review the finished files against the plugin-building guidance and apply every fix.
- **[`/agent-builder`](./han-plugin-builder/agent-builder.md).** Build a new agent from scratch through an evidence-based interview that walks the agent's design tree decision-by-decision, then review the finished self-contained agent file against the plugin-building guidance and apply every fix.

---

## How dispatch scales: sizing

The sizing-aware skills ([`/architectural-analysis`](./han-coding/architectural-analysis.md), [`/code-overview`](./han-coding/code-overview.md), [`/code-review`](./han-coding/code-review.md), [`/gap-analysis`](./han-core/gap-analysis.md), [`/iterative-plan-review`](./han-planning/iterative-plan-review.md), [`/plan-a-feature`](./han-planning/plan-a-feature.md), [`/plan-implementation`](./han-planning/plan-implementation.md), [`/research`](./han-core/research.md)) classify the work as **small**, **medium**, or **large** before dispatching agents, and scale the team or swarm size to the chosen band. The default is always small. Pass `small`, `medium`, or `large` as the first positional argument to override.

See [Sizing](../sizing.md) for the cross-skill model and per-skill bands. Each sizing-aware skill's long-form doc has its own **Sizing** section with the skill-specific signals and caps.

## What survives a review: YAGNI

Every planning, review, and standards skill in the plugin applies an evidence-based YAGNI rule before committing items to its artifact. Items without acceptable evidence move to a `## Deferred (YAGNI)` section with a named *reopen-when* trigger. Never silently dropped. The rule applies to:

- **Planning.** [`/plan-a-feature`](./han-planning/plan-a-feature.md), [`/plan-implementation`](./han-planning/plan-implementation.md), [`/plan-a-phased-build`](./han-planning/plan-a-phased-build.md), [`/iterative-plan-review`](./han-planning/iterative-plan-review.md).
- **Review and standards.** [`/code-review`](./han-coding/code-review.md) (advisory-only), [`/coding-standard`](./han-coding/coding-standard.md), [`/test-planning`](./han-coding/test-planning.md), [`/architectural-decision-record`](./han-core/architectural-decision-record.md) (forcing-function requirement).
- **Building.** [`/tdd`](./han-coding/tdd.md) (enforcing in the refactor step and the test list), [`/refactor`](./han-coding/refactor.md) (enforcing on the refactoring plan: every item needs evidence the code has a reason to change).

See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.

## How skills compose

Most han skills dispatch agents to do their judgment-heavy work. The [Concepts](../concepts.md) page explains the split. The long-form doc for each skill names the specific agents it dispatches.

A few common compositions:

- **Triage → investigate.** `/issue-triage` → `/investigate`.
- **Triage → research → spec.** `/issue-triage` → `/research` → `/plan-a-feature` (when triage finds a problem-space unknown, research the options first, then specify the chosen one).
- **Create specs → plan implementation → iterate → break into work items.** `/plan-a-feature` → `/plan-implementation` → `/iterative-plan-review` → `/plan-work-items`.
- **Plan implementation → break into work items.** `/plan-implementation` → `/plan-work-items`.
- **Break into work items → publish to GitHub issues.** `/plan-work-items` → `/work-items-to-issues`.
- **Break into work items → publish to Jira.** `/plan-work-items` → `/work-items-to-jira` (opt-in `han-atlassian` plugin; requires the Atlassian MCP server).
- **Discover → document → standardize.** `/project-discovery` → `/project-documentation` → `/coding-standard`.
- **Review locally → post to PR.** `/code-review` → `/post-code-review-to-pr`.
- **Review → execute the refactorings.** `/code-review` or `/architectural-analysis` → `/refactor` (the review's structural findings become the refactoring plan's work orders).
- **Prepare the ground → build.** `/refactor` → `/tdd` (preparatory refactoring makes the change easy, then `/tdd` makes the easy change).
- **Investigate → iterate on the fix.** `/investigate` → `/iterative-plan-review`.
- **Compare → plan the remediation.** `/gap-analysis` → `/plan-implementation` (the gap report's `G-NNN` IDs become work items in the implementation plan).
- **Compare → phase the build → plan implementation per phase.** `/gap-analysis` → `/plan-a-phased-build` → `/plan-implementation` (the gap report orders `G-NNN` IDs into vertical slices, then each phase gets its own implementation plan once greenlit).

## Adding a skill?

See [Contributing](../../CONTRIBUTING.md) for the full process and [the skill template](../templates/skill-long-form-template.md) for the long-form layout.
