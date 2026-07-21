# Quickstart

Pick the path below that matches what you are trying to do right now. Each path is a short sequence, a few skills, that
combine into a useful result. You can follow one path end to end, or jump off at any step.

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [How-to guides](./how-to/README.md) ·
> [Skills](./skills/README.md) · [Agents](./agents/README.md) · [Sizing](./sizing.md) · [YAGNI](./yagni.md)

> **Have not installed Han yet?** Read [Choosing a Han plugin](./choosing-a-han-plugin.md) first to pick between the
> full suite and core only, then come back here.

The [how-to guides](./how-to/README.md) cover planning, bug triage, and research workflows in depth, with specific
prompts, what to do between steps, and what to expect at each one. Read one when you want the full end-to-end recipe for
a path. The quickstart points you at the right path; the how-to walks you through it.

## Which path are you on?

- **[Plan a new feature](#path-a--plan-a-new-feature).** You have an idea for a feature and need to figure out what it
  should do, how to build it, and then build it test-first.
- **[Investigate a bug or failure](#path-b--investigate-a-bug-or-failure).** Something is broken or behaving oddly and
  you need a root cause.
- **[Research your options](#path-e--research-your-options-before-you-commit).** Nothing is broken; you have a question
  and want the options, prior art, and a recommendation before you commit.
- **[Review code or architecture](#path-c--review-code-or-architecture).** You want a second set of eyes on a branch, a
  PR, or an existing module.
- **[Set up a project for everything else](#path-d--set-up-a-project-for-everything-else).** You want to document your
  project, formalize standards, and give every other skill richer context.

Not sure which? Start with the [Concepts](./concepts.md) page, then come back.

---

## Path A: Plan a new feature

You have a feature idea and want a specification grounded in evidence, then a plan for how to build it.

The full walkthrough, with prompts, decision points, and what to expect at each step, lives in
**[How to plan a feature, end to end](./how-to/plan-a-feature.md)**. The skills in the loop, in order:

[`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md) →
[`/stakeholder-summary`](../han-reporting/docs/skills/stakeholder-summary.md) _(optional)_ →
[`/plan-a-phased-build`](../han-planning/docs/skills/plan-a-phased-build.md) _(optional)_ →
[`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md) →
[`/iterative-plan-review`](../han-planning/docs/skills/iterative-plan-review.md) _(optional)_ →
[`/plan-work-items`](../han-planning/docs/skills/plan-work-items.md) _(optional)_ → [`/tdd`](../han-coding/docs/skills/tdd.md)
_(when you build it)_.

**You are done when:** you have a `feature-specification.md` and a `feature-implementation-plan.md` in the same folder,
each with a cross-referenced decision log and review findings. If the feature was large enough to phase, you also have a
`build-phase-outline.md` that orders the work into demoable vertical slices. When you build it, the code lands behavior
by behavior through `/tdd`, with tests leading.

---

## Path B: Investigate a bug or failure

Something is broken. You want a root cause, not a guess.

The full walkthrough, including how to bring in production logs and when to triage instead of investigating right away,
lives in **[How to triage and investigate a bug](./how-to/triage-and-investigate-a-bug.md)**. The skills in the loop:

[`/issue-triage`](../han-core/docs/skills/issue-triage.md) _(as needed)_ →
[`/investigate`](../han-coding/docs/skills/investigate.md) →
[`/iterative-plan-review`](../han-planning/docs/skills/iterative-plan-review.md) _(optional)_.

**You are done when:** you have a report that names the root cause with file-level evidence, and a fix plan that has
survived adversarial review.

---

## Path C: Review code or architecture

You want feedback on something that is already written.

Start with the scope that matches:

- **A branch or a few files** → **[`/code-review`](../han-coding/docs/skills/code-review.md).** Always dispatches
  `junior-developer` and `adversarial-security-analyst`. Conditionally adds `test-engineer`, `edge-case-explorer`,
  `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, or `devops-engineer` when the
  changed files trigger their domain. The roster scales with the [size](./sizing.md), defaulting to small. Runs quality
  checks and produces a review with findings classified by severity.
- **An open GitHub PR** → **[`/post-code-review-to-pr`](../han-github/docs/skills/post-code-review-to-pr.md).** Everything
  `/code-review` does, plus a `junior-developer` clarity check against the drafted review body, plus posts the review as
  comments on the PR.
- **A whole module or subsystem** → **[`/architectural-analysis`](../han-coding/docs/skills/architectural-analysis.md).**
  Always dispatches a spine of `structural-analyst`, `behavioral-analyst`, `risk-analyst`, and `software-architect` to
  examine coupling, data flow, risk, and SOLID alignment. Conditionally adds `concurrency-analyst`,
  `adversarial-security-analyst`, `data-engineer`, `devops-engineer`, `codebase-explorer`, or `system-architect` when
  the focus area's signals call for them. The roster scales with the [size](./sizing.md), defaulting to small. For
  cross-service topology when `system-architect` is not auto-included, dispatch it separately.
- **Tests you want to _plan_, not review** → **[`/automated-test-planning`](../han-coding/docs/skills/automated-test-planning.md).** Dispatches
  `test-engineer` and `edge-case-explorer`, plus `concurrency-analyst` or `adversarial-security-analyst` when the files
  call for it. Produces a prioritized test plan.
- **A test plan a person runs by hand** →
  **[`/manual-test-planning`](../han-coding/docs/skills/manual-test-planning.md).** Produces a plain-language plan of
  named tests with by-hand steps and expected outcomes, adversarially validated against the supplied context by
  `adversarial-validator` before the file is written.
- **An implementation against a spec, PRD, or design doc** → **[`/gap-analysis`](../han-core/docs/skills/gap-analysis.md).**
  Compares two artifacts (current state vs. desired state) and produces a plain-language, stakeholder-readable report
  indexed by stable `G-NNN` gap IDs. Dispatches `gap-analyzer` for the primary analysis, then runs a
  validator-and-augmenter swarm by default, including `junior-developer`'s actor-perspective sweep across human users,
  API callers, AI agents, and other actor types. Opt out with `no swarm` for the lightweight pass.
- **A gap report or PRD that needs to be ordered into a phased build** →
  **[`/plan-a-phased-build`](../han-planning/docs/skills/plan-a-phased-build.md).** Splits the source artifact into a numbered
  sequence of vertical-slice build phases. Each phase is a thin end-to-end deliverable demoable to a real person, and
  each one builds on the prior. Dispatches `information-architect` against the rendered outline.

**You are done when:** you have a review artifact you trust, with findings tied to specific files, lines, and severity
levels.

---

## Path D: Set up a project for everything else

Every other path works better when the plugin has rich context about your project. If you have ten minutes before you
need the real skill, spend it here.

1. **[`/project-discovery`](../han-core/docs/skills/project-discovery.md).** Scans the repository and writes a concise
   `## Project Discovery` section into your AGENTS.md or CLAUDE.md (languages, frameworks, build commands, where things
   live). Other skills consume this automatically.
2. **[`/project-documentation`](../han-core/docs/skills/project-documentation.md)** _(as needed)._ Document features, systems,
   and components. `/code-review` and `/architectural-decision-record` read these docs as context.
3. **[`/coding-standard`](../han-coding/docs/skills/coding-standard.md)** _(as needed)._ Formalize coding conventions, either
   from existing patterns or from research. `/code-review` checks these automatically.
4. **[`/architectural-decision-record`](../han-core/docs/skills/architectural-decision-record.md)** _(as needed)._ Record
   architectural decisions.

**You are done when:** you have a `## Project Discovery` section in your AGENTS.md or CLAUDE.md and the docs and
standards you need to give other skills useful context.

---

## Path E: Research your options before you commit

You have a question, not a bug and not yet a feature. You want the options, the prior art, and a recommendation you can
trust before you pick a direction.

The full walkthrough, including how to capture the recommendation as an ADR so the team has a single canonical record,
lives in **[How to research a decision and capture it](./how-to/research-a-decision.md)**. The skills in the loop:

[`/research`](../han-core/docs/skills/research.md) →
[`/architectural-decision-record`](../han-core/docs/skills/architectural-decision-record.md) →
[`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md) _(optional next step)_.

**You are done when:** you have a research report whose recommendation survived an adversarial pass, with every claim
tied to a source you can check yourself, and the decision captured as an ADR. If the request was really a bug, a spec, a
standard, an artifact comparison, or an architecture assessment, `/research` routes you to the skill that owns it
instead.

---

## Combining paths

You can reference multiple skills in one prompt and Claude runs them in sequence, feeding each one's output into the
next. A few that work:

- _"Investigate why webhook deliveries are failing intermittently, then create a plan to fix it and iterate on it."_ →
  [`/investigate`](../han-coding/docs/skills/investigate.md) →
  [`/iterative-plan-review`](../han-planning/docs/skills/iterative-plan-review.md).
- _"Scan this repo, document the auth system, and create a coding standard for how we handle tokens."_ →
  [`/project-discovery`](../han-core/docs/skills/project-discovery.md) →
  [`/project-documentation`](../han-core/docs/skills/project-documentation.md) →
  [`/coding-standard`](../han-coding/docs/skills/coding-standard.md).
- _"Review my branch, then create an ADR for any architectural decisions in the diff."_ →
  [`/code-review`](../han-coding/docs/skills/code-review.md) →
  [`/architectural-decision-record`](../han-core/docs/skills/architectural-decision-record.md).
- _"Plan the retry feature, then plan the implementation, then create a test plan for it."_ →
  [`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md) →
  [`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md) →
  [`/automated-test-planning`](../han-coding/docs/skills/automated-test-planning.md).
- _"Spec the new onboarding flow, then write a stakeholder summary I can share with leadership before we build it."_ →
  [`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md) →
  [`/stakeholder-summary`](../han-reporting/docs/skills/stakeholder-summary.md) →
  [`/html-summary`](../han-reporting/docs/skills/html-summary.md) _(optional, for a self-contained HTML version to hand off)_.
- _"Spec the discount engine, then build it test-first."_ → [`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md)
  → [`/tdd`](../han-coding/docs/skills/tdd.md) → [`/code-review`](../han-coding/docs/skills/code-review.md).
- _"Research our options for background jobs, then spec the one you recommend."_ →
  [`/research`](../han-core/docs/skills/research.md) → [`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md).
- _"Compare the auth implementation to the auth spec, then plan how to close the gaps, finishing with splitting that
  work up into task-sized units."_ → [`/gap-analysis`](../han-core/docs/skills/gap-analysis.md) →
  [`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md) →
  [`/plan-work-items`](../han-planning/docs/skills/plan-work-items.md).
- _"Compare the share v1 implementation to the share v2 spec, split the gaps into a phased rollout, then plan
  implementation for the first phase, finally laying out individual tasks based on that plan."_ →
  [`/gap-analysis`](../han-core/docs/skills/gap-analysis.md) →
  [`/plan-a-phased-build`](../han-planning/docs/skills/plan-a-phased-build.md) →
  [`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md) →
  [`/plan-work-items`](../han-planning/docs/skills/plan-work-items.md).

## A note on sizing

The sizing-aware skills (`/architectural-analysis`, `/code-overview`, `/code-review`, `/gap-analysis`,
`/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation`, `/research`) classify the work as **small**,
**medium**, or **large** before dispatching agents. They default to small, and scale the team and iteration depth to the
chosen band. Pass the size as the first positional argument to override (`/code-review medium`,
`/plan-a-feature large "describe the feature"`). See [Sizing](./sizing.md) for the full model.

## A note on YAGNI

Every planning, review, and standards skill applies an evidence-based YAGNI rule before committing items to its
artifact. Items without acceptable evidence move to a `## Deferred (YAGNI)` section with a named _reopen-when_ trigger.
Never silently dropped. If a skill says "deferred (YAGNI)," see [YAGNI](./yagni.md) for the two gates, the
acceptable-evidence list, and the override process.

## Where to go next

- Pick a skill from the [Skills Index](./skills/README.md).
- Follow a how-to guide from the [How-to index](./how-to/README.md) when you want the full end-to-end recipe for one of
  the paths above.
- Skim the [Agents Index](./agents/README.md) to understand the specialists the skills dispatch.
- Read [Concepts](./concepts.md) if the skill/agent split is still fuzzy.
- Read [Sizing](./sizing.md) to understand how the swarming skills decide how many agents to dispatch.
- Read [YAGNI](./yagni.md) to understand what survives a review and what gets deferred.
