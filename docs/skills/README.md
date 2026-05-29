# Skills

All skills in the han plugin, grouped by purpose. Each entry is a one-sentence scent line plus a link to the canonical long-form doc.

> See also: [Plugin landing page](../../README.md) · [Concepts](../concepts.md) · [Quickstart](../quickstart.md) · [All agents](../agents/README.md) · [Sizing](../sizing.md) · [YAGNI](../yagni.md)

## New here?

Start on the [Quickstart](../quickstart.md). It picks the right skill for what you are trying to do right now. If the skill / agent split is fuzzy, read [Concepts](../concepts.md) first.

## Planning

Skills for specifying *what* a feature does, planning *how* to build it, and stress-testing plans before you commit.

- **[`/plan-a-feature`](./plan-a-feature.md).** Build a feature specification from scratch through an evidence-based interview that walks the design tree and dispatches specialist reviewers.
- **[`/plan-implementation`](./plan-implementation.md).** Turn a feature specification into an implementation plan through a project-manager-led team conversation.
- **[`/plan-a-phased-build`](./plan-a-phased-build.md).** Split a body of context (gap analysis, PRD, design doc, feature spec, requirements list) into a numbered sequence of vertical-slice build phases, each independently demoable to a real person and each building on the prior. Dispatches `information-architect` against the rendered outline to verify findability, EPPO standalone-ness of phase entries, and progressive comprehension.
- **[`/iterative-plan-review`](./iterative-plan-review.md).** Stress-test an already-written plan through multiple codebase-grounded review passes.
- **[`/plan-work-items`](./plan-work-items.md).** Divide a trusted implementation plan into independently-grabbable work items in a single work-items file.
- **[`/stakeholder-summary`](./stakeholder-summary.md).** Turn a feature specification into a plain-language stakeholder summary with Mermaid diagrams for user experience and data flow — for getting non-technical feedback before implementation kicks off.


## Building

Write the code itself, test-first, through a disciplined loop.

- **[`/tdd`](./tdd.md).** Drive a feature or behavior through a BDD-framed red-green-refactor loop. Builds a behavior test list, enforces an observed-failure gate (no production code until a test has been run and seen to fail), works outside-in for user-facing behavior, and applies the project's coding standards and ADRs in green (correctness) and refactor (full conformance plus YAGNI). The plugin's only execution skill: it writes code, not a document.

## Investigation & research

Skills for finding out *why* something is broken or *what* your options are, with evidence to back it.

- **[`/issue-triage`](./issue-triage.md).** Classify a vague issue or bug report, identify missing information, assess severity and reproducibility, and recommend the right next skill to run.
- **[`/investigate`](./investigate.md).** Evidence-based investigation of bugs, failures, and unexpected behavior, with adversarial validation of the proposed fix.
- **[`/research`](./research.md).** Research an open-ended question — options, possible solutions, prior art, or how something works — across the codebase and the open web, ending at an adversarially-validated recommendation without committing the team to any artifact. The question-shaped sibling of `/investigate`; scales with [size](../sizing.md).

## Review & analysis

Skills for getting a second set of eyes on code that already exists.

- **[`/code-review`](./code-review.md).** Run a comprehensive code review on the current branch or specified files. Always dispatches `junior-developer` and `adversarial-security-analyst`, and conditionally adds `test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, or `devops-engineer` when the changed files trigger their domain. Roster scales with [size](../sizing.md).
- **[`/post-code-review-to-pr`](./post-code-review-to-pr.md).** Run `/code-review` against a GitHub PR and post the review as comments, after a `junior-developer` clarity check on the drafted review body.
- **[`/architectural-analysis`](./architectural-analysis.md).** Deep architectural analysis of a module: coupling, data flow, concurrency, risk, and SOLID alignment. Always dispatches the `structural-analyst` / `behavioral-analyst` / `risk-analyst` / `software-architect` spine, and adds `concurrency-analyst`, `adversarial-security-analyst`, `data-engineer`, `devops-engineer`, `codebase-explorer`, or `system-architect` by signal. Roster scales with [size](../sizing.md).
- **[`/gap-analysis`](./gap-analysis.md).** Compare two artifacts (current state vs. desired state, for example spec vs. implementation, or PRD vs. shipped feature) and produce a plain-language, stakeholder-readable report indexed by stable gap IDs. Dispatches `gap-analyzer` for the primary analysis, then runs a validator-and-augmenter swarm by default — `adversarial-validator` and `junior-developer` (actor-perspective sweep) always, plus `evidence-based-investigator` when the current state is concrete, plus domain specialists and `project-manager` at medium and large. Opt out with `no swarm` for the lightweight pass.
- **[`/test-planning`](./test-planning.md).** Produce a prioritized test plan for a branch or directory. Dispatches `test-engineer` and `edge-case-explorer`, plus `concurrency-analyst` or `adversarial-security-analyst` when the files call for it.

## Discovery & context

Skills that produce context every other skill benefits from.

- **[`/project-discovery`](./project-discovery.md).** Scan the repository for languages, frameworks, tooling, and structure. Writes a static reference for other skills.
- **[`/project-documentation`](./project-documentation.md).** Create and maintain documentation for features, systems, and components.

## Conventions & decisions

Skills for recording how the team works.

- **[`/coding-standard`](./coding-standard.md).** Create and update coding standards from existing patterns or evidence-based research.
- **[`/architectural-decision-record`](./architectural-decision-record.md).** Create, extract, or convert architectural decision records.

## Reporting

Skills for turning the work back into something sharable.

- **[`/html-summary`](./html-summary.md).** Convert a `stakeholder-summary.md` (from [`/stakeholder-summary`](./stakeholder-summary.md)) into a single self-contained HTML executive report — bottom line and asks up front, mermaid diagrams inlined, styled with a Test Double-derived palette. Produces the HTML file only; does not publish it.
- **[`/update-pr-description`](./update-pr-description.md).** Generate a PR description from the current branch's changes.
- **[`/work-items-to-issues`](./work-items-to-issues.md).** Publish each item in a `/plan-work-items` work-items file as a GitHub issue in its target repo, with within-repo blockers linked, screenshots copied into the repo, and no label or assignee by default.

## Operations

Skills for capturing operational knowledge in artifacts the next on-call engineer can use.

- **[`/runbook`](./runbook.md).** Create or update a runbook for a single operational scenario (alert that has fired, incident, recurring task, known failure mode). Symptom-first template with imperative-voice procedure, expected output per step, escalation conditions, and rollback. Applies a YAGNI preflight that requires real evidence before writing.

---

## How dispatch scales: sizing

The sizing-aware skills ([`/architectural-analysis`](./architectural-analysis.md), [`/code-review`](./code-review.md), [`/gap-analysis`](./gap-analysis.md), [`/iterative-plan-review`](./iterative-plan-review.md), [`/plan-a-feature`](./plan-a-feature.md), [`/plan-implementation`](./plan-implementation.md), [`/research`](./research.md)) classify the work as **small**, **medium**, or **large** before dispatching agents, and scale the team or swarm size to the chosen band. The default is always small. Pass `small`, `medium`, or `large` as the first positional argument to override.

See [Sizing](../sizing.md) for the cross-skill model and per-skill bands. Each sizing-aware skill's long-form doc has its own **Sizing** section with the skill-specific signals and caps.

## What survives a review: YAGNI

Every planning, review, and standards skill in the plugin applies an evidence-based YAGNI rule before committing items to its artifact. Items without acceptable evidence move to a `## Deferred (YAGNI)` section with a named *reopen-when* trigger. Never silently dropped. The rule applies to:

- **Planning.** [`/plan-a-feature`](./plan-a-feature.md), [`/plan-implementation`](./plan-implementation.md), [`/plan-a-phased-build`](./plan-a-phased-build.md), [`/iterative-plan-review`](./iterative-plan-review.md).
- **Review and standards.** [`/code-review`](./code-review.md) (advisory-only), [`/coding-standard`](./coding-standard.md), [`/test-planning`](./test-planning.md), [`/architectural-decision-record`](./architectural-decision-record.md) (forcing-function requirement).
- **Building.** [`/tdd`](./tdd.md) (enforcing in the refactor step and the test list).

See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.

## How skills compose

Most han skills dispatch agents to do their judgment-heavy work. The [Concepts](../concepts.md) page explains the split. The long-form doc for each skill names the specific agents it dispatches.

A few common compositions:

- **Triage → investigate.** `/issue-triage` → `/investigate`.
- **Triage → research → spec.** `/issue-triage` → `/research` → `/plan-a-feature` (when triage finds a problem-space unknown, research the options first, then specify the chosen one).
- **Create specs → plan implementation → iterate → break into work items.** `/plan-a-feature` → `/plan-implementation` → `/iterative-plan-review` → `/plan-work-items`.
- **Plan implementation → break into work items.** `/plan-implementation` → `/plan-work-items`.
- **Break into work items → publish to GitHub issues.** `/plan-work-items` → `/work-items-to-issues`.
- **Discover → document → standardize.** `/project-discovery` → `/project-documentation` → `/coding-standard`.
- **Review locally → post to PR.** `/code-review` → `/post-code-review-to-pr`.
- **Investigate → iterate on the fix.** `/investigate` → `/iterative-plan-review`.
- **Compare → plan the remediation.** `/gap-analysis` → `/plan-implementation` (the gap report's `G-NNN` IDs become work items in the implementation plan).
- **Compare → phase the build → plan implementation per phase.** `/gap-analysis` → `/plan-a-phased-build` → `/plan-implementation` (the gap report orders `G-NNN` IDs into vertical slices, then each phase gets its own implementation plan once greenlit).

## Adding a skill?

See [Contributing](../../CONTRIBUTING.md) for the full process and [the skill template](../templates/skill-long-form-template.md) for the long-form layout.
