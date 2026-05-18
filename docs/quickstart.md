# Quickstart

New to the han plugin? Pick the path that matches what you are trying to do right now. Each path is a short sequence (a few skills) that compose into a useful result. You can follow one path end to end, or jump off at any step.

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [Skills](./skills/README.md) · [Agents](./agents/README.md) · [Sizing](./sizing.md) · [YAGNI](./yagni.md)

## Which path are you on?

- **[Plan a new feature](#path-a--plan-a-new-feature).** You have an idea for a feature and need to figure out what it should do, how to build it, and then build it test-first.
- **[Investigate a bug or failure](#path-b--investigate-a-bug-or-failure).** Something is broken or behaving oddly and you need a root cause.
- **[Review code or architecture](#path-c--review-code-or-architecture).** You want a second set of eyes on a branch, a PR, or an existing module.
- **[Set up a project for everything else](#path-d--set-up-a-project-for-everything-else).** You want to document your project, formalize standards, and give every other skill richer context.

Not sure which? Start with the [Concepts](./concepts.md) page, then come back.

---

## Path A: Plan a new feature

You have a feature idea and want a specification grounded in evidence, then a plan for how to build it.

1. **[`/plan-a-feature`](./skills/plan-a-feature.md).** Run a relentless, evidence-based interview that walks the design tree, dispatches specialist reviewers, and produces `feature-specification.md` plus a decision log and team findings.
2. **[`/plan-a-phased-build`](./skills/plan-a-phased-build.md)** *(optional).* When the feature is large enough to ship in slices rather than all at once, split the spec into a numbered sequence of vertical-slice phases, each independently demoable to a real person.
3. **[`/plan-implementation`](./skills/plan-implementation.md).** Turn the specification (or a single phase from the phased build) into an implementation plan through a project-manager-led team conversation.
4. **[`/iterative-plan-review`](./skills/iterative-plan-review.md)** *(optional).* Stress-test either plan through multiple codebase-grounded review passes before committing to it.
5. **[`/plan-work-items`](./skills/plan-work-items.md)** *(optional).* Divide an implementation plan into individual, independently-grabbable work items.
6. **[`/tdd`](./skills/tdd.md)** *(when you build it).* Implement the plan test-first through a BDD-framed red-green-refactor loop. The specification becomes the behavior test list; the skill enforces an observed-failure gate and applies your coding standards and ADRs in green and refactor.

**You are done when:** you have a `feature-specification.md` and a `feature-implementation-plan.md` in the same folder, each with a cross-referenced decision log and review findings. If the feature was large enough to phase, you also have a `build-phase-outline.md` that orders the work into demoable vertical slices. When you build it, the code lands behavior by behavior through `/tdd`, with tests leading.

---

## Path B: Investigate a bug or failure

Something is broken. You want a root cause, not a guess.

1. **[`/issue-triage`](./skills/issue-triage.md)** *(as needed).* If the report is vague or incomplete, classify the issue, identify missing information, and capture the next step before you investigate.
2. **[`/investigate`](./skills/investigate.md).** Evidence-based investigation: file paths, line numbers, git history, test coverage. Produces an investigation report with the root cause and a proposed fix that an `adversarial-validator` has already tried to falsify.
3. **[`/iterative-plan-review`](./skills/iterative-plan-review.md)** *(optional).* If the investigation produced a fix plan you do not trust, iterate on it before writing code.

**You are done when:** you have a report that names the root cause with file-level evidence, and a fix plan that has survived adversarial review.

---

## Path C: Review code or architecture

You want feedback on something that is already written.

Start with the scope that matches:

- **A branch or a few files** → **[`/code-review`](./skills/code-review.md).** Always dispatches `junior-developer` and `adversarial-security-analyst`. Conditionally adds `test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, or `devops-engineer` when the changed files trigger their domain. The roster scales with the [size](./sizing.md), defaulting to small. Runs quality checks and produces a review with findings classified by severity.
- **An open GitHub PR** → **[`/gh-pr-review`](./skills/gh-pr-review.md).** Everything `/code-review` does, plus a `junior-developer` clarity check against the drafted review body, plus posts the review as comments on the PR.
- **A whole module or subsystem** → **[`/architectural-analysis`](./skills/architectural-analysis.md).** Always dispatches a spine of `structural-analyst`, `behavioral-analyst`, `risk-analyst`, and `software-architect` to examine coupling, data flow, risk, and SOLID alignment. Conditionally adds `concurrency-analyst`, `adversarial-security-analyst`, `data-engineer`, `devops-engineer`, `codebase-explorer`, or `system-architect` when the focus area's signals call for them. The roster scales with the [size](./sizing.md), defaulting to small. For cross-service topology when `system-architect` is not auto-included, dispatch it separately.
- **Tests you want to *plan*, not review** → **[`/test-planning`](./skills/test-planning.md).** Dispatches `test-engineer` and `edge-case-explorer`, plus `concurrency-analyst` or `adversarial-security-analyst` when the files call for it. Produces a prioritized test plan.
- **An implementation against a spec, PRD, or design doc** → **[`/gap-analysis`](./skills/gap-analysis.md).** Compares two artifacts (current state vs. desired state) and produces a plain-language, stakeholder-readable report indexed by stable `G-NNN` gap IDs. Dispatches `gap-analyzer` for the primary analysis, then runs a validator-and-augmenter swarm by default — including `junior-developer`'s actor-perspective sweep across human users, API callers, AI agents, and other actor types. Opt out with `no swarm` for the lightweight pass.
- **A gap report or PRD that needs to be ordered into a phased build** → **[`/plan-a-phased-build`](./skills/plan-a-phased-build.md).** Splits the source artifact into a numbered sequence of vertical-slice build phases. Each phase is a thin end-to-end deliverable demoable to a real person, and each one builds on the prior. Dispatches `information-architect` against the rendered outline.

**You are done when:** you have a review artifact you trust, with findings tied to specific files, lines, and severity levels.

---

## Path D: Set up a project for everything else

Every other path works better when the plugin has rich context about your project. If you have ten minutes before you need the real skill, spend it here.

1. **[`/project-discovery`](./skills/project-discovery.md).** Scans the repository and writes a static reference (languages, frameworks, build tools, documentation structure). Other skills consume this automatically.
2. **[`/project-documentation`](./skills/project-documentation.md)** *(as needed).* Document features, systems, and components. `/code-review` and `/architectural-decision-record` read these docs as context.
3. **[`/coding-standard`](./skills/coding-standard.md)** *(as needed).* Formalize coding conventions, either from existing patterns or from research. `/code-review` checks these automatically.
4. **[`/architectural-decision-record`](./skills/architectural-decision-record.md)** *(as needed).* Record architectural decisions.

**You are done when:** you have a `project-discovery.md` at the project root and the docs and standards you need to give other skills useful context.

---

## Combining paths

You can reference multiple skills in one prompt and Claude runs them in sequence, feeding each one's output into the next. A few that work:

- *"Investigate why webhook deliveries are failing intermittently, then create a plan to fix it and iterate on it."* → [`/investigate`](./skills/investigate.md) → [`/iterative-plan-review`](./skills/iterative-plan-review.md).
- *"Scan this repo, document the auth system, and create a coding standard for how we handle tokens."* → [`/project-discovery`](./skills/project-discovery.md) → [`/project-documentation`](./skills/project-documentation.md) → [`/coding-standard`](./skills/coding-standard.md).
- *"Review my branch, then create an ADR for any architectural decisions in the diff."* → [`/code-review`](./skills/code-review.md) → [`/architectural-decision-record`](./skills/architectural-decision-record.md).
- *"Plan the retry feature, then plan the implementation, then create a test plan for it."* → [`/plan-a-feature`](./skills/plan-a-feature.md) → [`/plan-implementation`](./skills/plan-implementation.md) → [`/test-planning`](./skills/test-planning.md).
- *"Spec the discount engine, then build it test-first."* → [`/plan-a-feature`](./skills/plan-a-feature.md) → [`/tdd`](./skills/tdd.md) → [`/code-review`](./skills/code-review.md).
- *"Compare the auth implementation to the auth spec, then plan how to close the gaps, finishing with splitting that work up into task-sized units."* → [`/gap-analysis`](./skills/gap-analysis.md) → [`/plan-implementation`](./skills/plan-implementation.md) → [`/plan-work-items`](./skills/plan-work-items.md).
- *"Compare the share v1 implementation to the share v2 spec, split the gaps into a phased rollout, then plan implementation for the first phase, finally laying out individual tasks based on that plan."* → [`/gap-analysis`](./skills/gap-analysis.md) → [`/plan-a-phased-build`](./skills/plan-a-phased-build.md) → [`/plan-implementation`](./skills/plan-implementation.md) → [`/plan-work-items`](./skills/plan-work-items.md).

## A note on sizing

Six skills (`/architectural-analysis`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation`) classify the work as **small**, **medium**, or **large** before dispatching agents, default to small, and scale the team and iteration depth to the chosen band. Pass the size as the first positional argument to override (`/code-review medium`, `/plan-a-feature large "describe the feature"`). See [Sizing](./sizing.md) for the full model.

## A note on YAGNI

Every planning, review, and standards skill applies an evidence-based YAGNI rule before committing items to its artifact. Items without acceptable evidence move to a `## Deferred (YAGNI)` section with a named *reopen-when* trigger. Never silently dropped. If a skill says "deferred (YAGNI)," see [YAGNI](./yagni.md) for the two gates, the acceptable-evidence list, and the override process.

## Where to go next

- Pick a skill from the [Skills Index](./skills/README.md).
- Skim the [Agents Index](./agents/README.md) to understand the specialists the skills dispatch.
- Read [Concepts](./concepts.md) if the skill/agent split is still fuzzy.
- Read [Sizing](./sizing.md) to understand how the swarming skills decide how many agents to dispatch.
- Read [YAGNI](./yagni.md) to understand what survives a review and what gets deferred.
