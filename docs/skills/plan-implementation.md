# /plan-implementation

Operator documentation for the `/plan-implementation` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/plan-implementation/SKILL.md`](../../han.core/skills/plan-implementation/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** Turns a feature specification into an implementation plan through an iterative, project-manager-led team conversation.
- **When to use it.** You have a `feature-specification.md` (or equivalent design doc) and need a plan for *how* to build it.
- **What you get back.** Three cross-referenced files: `feature-implementation-plan.md`, `artifacts/implementation-decision-log.md`, `artifacts/implementation-iteration-history.md`.
- **Size-aware.** The skill classifies the feature as small / medium / large, defaults to small, and caps both the team size and the iteration round count proportional to scope. Pass the size as the first positional argument to override (`/plan-implementation large path/to/spec.md`). See [Sizing](#sizing).

## Key concepts

- **Facilitated loop.** Rounds of parallel specialist review plus project-manager reconciliation, capped by size: 1 round for small, 2 for medium, 3 for large. The loop converges when the PM declares the plan is ready or when only user input remains.
- **Team sized to the feature.** Always includes `project-manager` and `junior-developer`. Other specialists are chosen by what the feature touches: DevOps for rollout, data-engineer for schema, UX for interactions, security for threat surface, `software-architect` for intra-codebase design, `system-architect` for cross-service topology.
- **Junior-developer reframing.** When a decision lacks evidence, the skill asks `junior-developer` to restate the question in plain language before escalating. Often a reframing exposes an unstated assumption and the specialists resolve it among themselves.
- **Final synthesis by PM.** `project-manager` runs on `opus` for the final pass, producing the authoritative plan. Specialists run on `sonnet` during the iteration loop. The synthesis is an audit-and-correct pass, not just a write-and-populate one: the PM reconciles the artifacts against each other and rewrites inconsistencies in place — a decision-log title copied from another entry, a path one section assumes that another section's layout never places there.
- **Planning altitude.** The plan names and references config and code artifacts; it does not inline their full contents. Only decision-bearing values (a flag default, a key name, a threshold) appear inline. A full file block belongs in the file it configures, not in the plan.
- **Cross-referenced artifacts.** Every non-obvious claim carries `([D-N](...))` linking to the decision that drove it. Every `R#` round links to the decisions it produced and the sections it changed.

## When to use it

**Invoke when:**

- A feature specification exists and the team needs to plan how to implement, build, deliver, or ship it. *"Plan the implementation of X," "how do we build this," "turn this spec into an implementation plan," "figure out how we'd actually ship this."*
- The `/plan-a-feature` skill has produced a `feature-specification.md` and the natural next step is turning *what* into *how*: decomposition, sequencing, testing, rollout, rollback.
- A PRD or design doc has landed without a specification-grade artifact, but the team still wants a full implementation plan and is willing to let the skill treat the document as the stand-in for a spec.
- The team wants an implementation plan produced by a multi-specialist team conversation (UX, security, DevOps, architecture, testing, and so on) rather than by a single engineer writing it up alone.
- A feature's implementation touches multiple specialist domains (auth, data migration, production rollout, UX changes) and the team wants those domains represented in the plan with evidence-backed recommendations rather than handwaved in a sentence each.
- The team wants the facilitation loop to converge on its own. The project-manager decides when the plan is ready, not you. Only genuine user-judgment questions surface.

**Do not invoke for:**

- **Specifying what a feature should do.** Use `/plan-a-feature` to produce the behavioral specification first. This skill assumes the *what* is settled and plans the *how*.
- **Refining or stress-testing an already-written implementation plan.** Use `/iterative-plan-review` when the implementation plan exists and needs multiple review passes challenging assumptions and identifying overlap.
- **Investigating a bug or failure.** Use `/investigate` for evidence-based root-cause work.
- **Analyzing existing architecture.** Use `/architectural-analysis` for assessing coupling, cohesion, data flow, concurrency, and SOLID alignment of an already-built module.
- **Recording an architectural decision that has already been made.** Use `/architectural-decision-record` when the decision is settled and needs to be captured as an ADR.
- **File-level code review.** Use `/code-review` for correctness, style, and maintainability review of committed or pending code.
- **Documenting an already-built feature.** Use `/project-documentation` when the feature exists and the team wants documentation.

## How to invoke it

Run `/plan-implementation` directly in Claude Code. Point it at the source specification in the same message, or let the skill locate a recent `feature-specification.md` under documentation roots discovered from CLAUDE.md.

Give it:

1. **The source specification.** A path to a `feature-specification.md` file is the preferred input. If no path is given, the skill searches documentation roots (`docs/features/`, `docs/plans/`, plus anything the project-discovery reference names) and asks which spec to use if multiple candidates exist. If no spec exists, the skill tells you to run `/plan-a-feature` first.
2. **Any additional implementation context, optional.** A deadline, a compliance constraint, a named incident the plan must address, a strategic bet driving the feature: any of this sharpens the facilitation. The skill reads the codebase, ADRs, and coding standards automatically.
3. **Team composition, optional.** If you already know which specialists should be in the room (*"include devops-engineer and data-engineer"*), say so. The skill always includes `project-manager` and `junior-developer`. Other specialists are chosen to match what the feature touches unless you override.

Example prompts that work well:

- `/plan-implementation docs/features/bulk-export/feature-specification.md`. *"Turn the bulk-export spec into an implementation plan. Include `data-engineer` because we're adding export snapshots to the database."*
- `/plan-implementation`. *"Plan the implementation for the webhook retry feature we just specced. The spec is in `docs/features/webhook-retry/feature-specification.md`. We have a customer commitment to ship by end of next sprint."*
- `/plan-implementation`. *"How would we build the user-invite flow? The spec is one folder up from here. Use the team you think is right."*
- `/plan-implementation docs/features/draft-review/feature-specification.md`. *"Plan the implementation. This touches auth and storage, so include `adversarial-security-analyst` and `data-engineer`."*

Thin prompts (*"plan the implementation"*) still work. The skill searches for a recent spec and confirms before proceeding. But pointing at the spec path directly is faster.

## What you get back

Three cross-referenced files in the same folder as the source specification, plus an in-channel summary:

- A **`feature-implementation-plan.md`** file at `{same-folder-as-source}/feature-implementation-plan.md`. The primary plan. Non-obvious claims carry inline markers (for example, `([D-3](artifacts/implementation-decision-log.md#d-3-rollout-strategy))`) linking back to the decision that drove them. Sections include:
  - A **Source Specification** section. A markdown link back to the `feature-specification.md`, plus links to the spec's `artifacts/decision-log.md` and `artifacts/team-findings.md` if those exist (legacy spec folders may have them at the folder root instead; the project-manager records whichever path is correct). If the plan was built from conversational context only, the section states that explicitly and summarizes what context was used.
  - A **team composition and participation record.** Every specialist the skill engaged, whether they contributed actively or stood down with "no concerns," and a one-line summary of each specialist's input with citation.
  - An **implementation approach** section covering architecture and integration points, data model and persistence, runtime behavior, and external interfaces. Technical details are welcome here (this is the *how* document), all grounded in evidence from the codebase, ADRs, and coding standards.
  - A **decomposition and sequencing** table. The plan broken into work units sized to ship, each with what it delivers, what it depends on, and how it is verified.
  - A **RAID log.** Risks (with likelihood, severity, blast radius, reversibility, owner, mitigation), Assumptions (with what-changes-if-wrong), Issues (with owner and next step), and Dependencies (with owner and status).
  - A **testing strategy** grounded in the `test-engineer`'s observable-behavior recommendations (and `edge-case-explorer`'s findings if engaged). Covers test levels, test-doubles posture, and the edge cases requiring coverage.
  - A **security posture** section (when `adversarial-security-analyst` contributed) with the concrete threat vectors addressed and the mitigations the plan commits to.
  - An **operational readiness** section (when `devops-engineer` contributed) covering observability signals, SLO touchpoints, feature-flag strategy, rollout and rollback steps, cost posture, and compliance controls.
  - A **definition of done.** Testable, unambiguous, agreed across specialists.
  - A **specialist handoffs for implementation** list. Which sibling agents should be re-engaged during implementation, when, and with what input.
  - A **remaining open items** list. Questions the project-manager could not resolve through evidence, junior-developer reframing, or user input. Each one names what would resolve it and whether it blocks implementation.
- An **`artifacts/implementation-decision-log.md`** file at `{same-folder-as-source}/artifacts/implementation-decision-log.md`. One `D-N` entry per decision committed during the loop. Each entry records the choice, rationale, evidence, rejected alternatives with reasons, the specialist owner, a revisit criterion, any recorded dissent under disagree-and-commit, the `R#` rounds that drove it (`Driven by rounds:`), the later decisions that rest on it (`Dependent decisions:`), and the plan sections that cite it (`Referenced in plan:`). This is where rationale, rejected alternatives, and full decision history live. The primary plan references them by ID.
- An **`artifacts/implementation-iteration-history.md`** file at `{same-folder-as-source}/artifacts/implementation-iteration-history.md`. One `R#` entry per facilitation round. Each entry records the specialists engaged, the new input provided that round, the questions raised, the resolution source for each (`evidence` found in the loop / `junior-developer reframing` / `user input` / `PM synthesis (Step 8 evidence)` when the PM settled it by re-reading the spec during synthesis rather than in the loop), the project-manager's next-step recommendation, the decisions the round produced (`Decisions produced:`, backfilled during synthesis), and the plan sections the round changed (`Changed in plan:`, also backfilled). This captures how the plan evolved across rounds without bloating the primary plan file.
- A **summary** returned in-channel. All three file paths, team composition, number of iterations the loop ran before convergence, decisions settled by evidence vs. junior-developer reframing vs. user input, remaining open items and whether they block implementation, and the project-manager's recommendation (ship as planned, hold for specialist handoff, or blocked pending open item).

The three files interlock through shared IDs. Every `D-N` lists the `R#` rounds that drove it and the plan sections that cite it. Every `R#` lists the `D-N` decisions it produced and the plan sections it changed. Every non-obvious claim in the plan carries its inline `([D-N](...))` marker. The project-manager preserves these structural invariants during synthesis so cross-references stay consistent, and on top of that runs a semantic audit: it checks that each decision-log title matches its body, that a path named in one section matches the file layout described in another, and that the plan stays at altitude (no full file blocks inlined), rewriting any mismatch in place.

Every decision in the plan is traceable to a specific citation (evidence) or a specific question (when evidence is missing). Open items are first-class output. The plan does not synthesize cleanly while a blocking open item remains. The skill surfaces it rather than inventing an answer.

## How to get the most out of it

- **Run `/plan-a-feature` first.** The skill expects a behavioral specification as input. A specification produced by `/plan-a-feature` comes with a companion `artifacts/decision-log.md` and `artifacts/team-findings.md` (legacy layouts may have these at the spec folder root instead; the skill detects and handles both), plus Open Items inside the spec. All of that feeds the implementation-planning team's grounding and dramatically reduces the iteration count.
- **Point the skill at a path.** A concrete path to `feature-specification.md` is faster than letting the skill search and confirm. Use the path form in the command: `/plan-implementation docs/features/{name}/feature-specification.md`.
- **Name the team if you know it.** If you already know the feature touches UX, security, and data, say so. The skill always includes `project-manager` and `junior-developer`. Saying *"include these specialists"* lets the skill scope the round-robin tightly from the first iteration.
- **Provide the driving constraint.** Why now: deadline, incident, customer commitment, compliance window? The skill's facilitation is sharper when the project-manager can ground the "driving constraint" section in something concrete rather than inferring from code alone.
- **Trust the loop.** The skill caps iteration by size (1 round small, 2 medium, 3 large) to prevent runaway cycles. Each round is a full facilitation pass: specialists re-engaged as needed, project-manager reconciling, junior-developer reframing open questions. Let the loop run rather than jumping in mid-flight to answer questions that evidence or reframing would have resolved.
- **Answer the escalations succinctly.** When the skill escalates a question, it does so with the specialist(s) who raised it, the evidence considered, junior-developer's reframing, a recommended answer, and the alternatives. Accept or amend the recommendation. Don't re-litigate from scratch. Batched focused escalations are the intended interaction. Not a firehose of raw specialist output.
- **Treat open items as work.** Any item remaining at the end of the loop is either a user-judgment call still awaiting an answer or a genuine blocker the team needs to resolve before implementation. The plan records what would resolve each, so follow-up is concrete.
- **Use the specialist-handoffs-for-implementation list.** The plan names exactly which sibling agents should be re-engaged during implementation, when, and with what input. This is the reader's guide for who gets pulled back in at each stage. Use it instead of re-deriving the specialist fan-out during implementation.
- **Pair with `/iterative-plan-review` if the plan needs further stress-testing.** This skill produces the committable plan. It does not iterate on its own output three times. If you want multi-pass refinement after the plan lands, chain `/iterative-plan-review` next.
- **Re-run after the spec changes.** If the feature specification is updated (new decision, new constraint, new stakeholder), re-run the skill with the updated spec. The existing plan, decision log, and iteration history all become inputs to the new run. Prior `D-N` / `R#` IDs carry forward so cross-references remain stable.

## Sizing

Size determines both the team cap (how many specialists join the project-manager-led conversation) and the round cap (how many iterations the loop runs). The skill defaults to small and only escalates when concrete signals require it.

| Size | Surface | Typical signals | Team cap | Round cap |
|---|---|---|---|---|
| **Small** *(default)* | Single subsystem | No cross-service integration, no auth/PII/secrets, no data migration. | 3 (project-manager + junior-developer + 1 chosen specialist) | 1 |
| **Medium** | Two to three subsystems | Optional integration; may touch UX or rollout; may have a small auth surface. | 4–5 (project-manager + junior-developer + 2–3 chosen specialists) | 2 |
| **Large** | Cross-service or security-sensitive | Data ownership shifts, multiple new coordinations, or you explicitly request full team. | 6–8 (project-manager + junior-developer + 4–6 chosen specialists) | 3 |

How the size is chosen:

- **Default to small.** Unless the spec's coordinations, T# notes, security/PII surface, integration boundaries, or your framing push it higher, the skill stays at small.
- **`project-manager` and `junior-developer` always included.** Both are part of the team at every size. Size sets the cap on additional specialists chosen by what the feature touches.
- **Round cap is the upper bound, not a target.** The loop exits when `project-manager` reports the plan is ready or only user-input items remain. The round cap prevents runaway cycles.

How to override the size:

- Pass `small`, `medium`, or `large` as the first positional argument: `/plan-implementation medium docs/features/checkout/feature-specification.md`.
- When the size is overridden via `$size`, the skill announces the override (`Medium: passed via $size`) and uses the chosen band for both the team cap and the round cap.
- Conversational overrides (*"treat this as a large implementation, the rollout is sensitive"*) still work and are equivalent.

For the cross-skill sizing model and design principles, see [Sizing](../sizing.md).

## Cost and latency

The skill orchestrates a multi-round team conversation, where each round fans out to three to seven specialist sub-agents (plus `junior-developer` and `project-manager`) in parallel, collects their verbatim output, runs `project-manager` in facilitation mode to reconcile, and decides whether to loop again. All sub-agents the skill dispatches in the iteration loop run on `sonnet` (the skill pins this explicitly). The exception is the final synthesis pass, which runs `project-manager` on its default model (`opus`). This is the most expensive single step, but also the step that produces the authoritative plan. For a medium-complexity feature, expect two iterations before the project-manager declares the plan ready, which means roughly ten to twenty `sonnet` sub-agent dispatches plus the `opus` synthesis. The size-based round cap (1 for small, 2 for medium, 3 for large) prevents runaway cycles. The skill is designed for new-feature planning cadence (once per feature, occasionally re-run after spec changes), not for tight-loop iteration. Use `/iterative-plan-review` for that.

## In more detail

The skill's input is the ground truth for *what* the feature does (a `feature-specification.md` produced by `/plan-a-feature`, or an equivalent PRD, design doc, or product brief) and its output is three cross-referenced files written to the same folder, covering *how* to build it. The skill's defining behavior is the loop: it assembles a team of specialist sub-agents sized to what the feature touches, always including `project-manager` as coordinator and `junior-developer` as generalist stress-tester, and runs rounds of facilitated discussion until the project-manager confirms the plan is ready to commit or only user input remains.

When a decision lacks strong evidence, the skill does not immediately escalate to you. It first asks `junior-developer` to reframe the issue in plain language, because that reframing frequently exposes an unstated assumption or a simpler question the specialists can answer among themselves. Only when evidence and reframing both fail does the skill surface the question to you, with the evidence considered, the reframing, a recommended answer, and the alternatives.

The `project-manager` owns the final synthesis pass and writes the authoritative plan. The primary artifact (`feature-implementation-plan.md` at the folder root) covers decomposition, sequencing, RAID log, testing strategy, security posture, operational readiness, definition of done, specialist handoffs, and open items, with a Source Specification link back to the upstream *what* document. Decision history and round-by-round iteration history live in `artifacts/implementation-decision-log.md` and `artifacts/implementation-iteration-history.md` alongside, cross-referenced by `D-N` / `R#` ID, so the primary plan stays focused on the implementation narrative while rationale, rejected alternatives, and discussion history stay one hop away.

## YAGNI

A YAGNI sweep runs before the implementation plan is committed. Every plan step, abstraction, infrastructure addition, observability hook, configuration knob, and rollout step must cite acceptable evidence that it is needed *now*. Speculative work moves to a `## Deferred (YAGNI)` section in the plan with a named *reopen-when* trigger. The team agents that participate in the iterative discussion (`project-manager`, `junior-developer`, `software-architect`, `system-architect`, `data-engineer`, `devops-engineer`, `test-engineer`, `edge-case-explorer`) each enforce their own slice of the rule: premature operational machinery, speculative data machinery, single-implementation interfaces, defensive code at trusted internal boundaries, observability for telemetry that isn't reaching the destination yet, and so on.

See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.

## Sources

The skill's posture and protocols draw on established practice in facilitative project management, iterative planning, and multi-specialist coordination. Each source below is cited because the skill draws specific, named artifacts from it.

### PMI: The Facilitative Project Manager

The Project Management Institute's guidance on facilitative project management frames the project manager as process expert whose job is to enable effective decision-making by the group, not to make decisions alone. The skill's entire architecture is built on this: the project-manager sub-agent owns coordination and final synthesis, but the specialists own their domains. The skill's iteration loop (dispatch specialists, facilitate, reconcile, iterate) is facilitative PM applied to an AI-agent team.

URL: https://www.pmi.org/learning/library/the-facilitative-project-manager-6970

### Round-Robin Facilitation

Round-robin is a facilitation technique in which every relevant participant speaks in turn, deliberately, so quieter voices are heard before the loudest voice takes the room. The skill's Step 4 (Round 1: Parallel Specialist Review) implements round-robin across the specialist sibling agents: every specialist is asked the specific question their domain answers, in parallel, before facilitation reconciles their input. *"No concerns from my side"* is captured as a valid, recorded answer so participation is never silently assumed.

URLs: https://www.mindtools.com/a81qk8y/round-robin-brainstorming/ and https://goodgroupdecisions.com/round-robin/

### RAID Log

The RAID log (Risks, Assumptions, Issues, Decisions) is the standard project-management artifact for tracking, continuously, the four items a plan cannot survive without. The skill's output plan encodes a full RAID log carried forward from facilitation: risks with likelihood/severity/blast-radius/reversibility/owner/mitigation, assumptions with what-changes-if-wrong, issues with owner/next-step, and decisions (separately recorded) with rationale/rejected-alternatives/evidence.

URLs: https://asana.com/resources/raid-log and https://www.smartsheet.com/content/raid-logs

### Hunt and Thomas: The Pragmatic Programmer (Rubber-Duck Debugging)

Andy Hunt and Dave Thomas's "rubber duck" practice (explaining a problem out loud in plain language to surface the gaps in your own reasoning) is the basis for the skill's junior-developer-reframing step. When a decision lacks strong evidence, the skill asks `junior-developer` to restate the issue in plain language before escalating to you. The reframing often exposes the unstated assumption or the simpler question the specialists can answer among themselves. The rubber duck applied to multi-agent specialist facilitation is the resolution step that turns "escalate to user" into "resolve inside the team."

URL: https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/

### Amazon: Have Backbone; Disagree and Commit

Jeff Bezos's *"Have Backbone; Disagree and Commit"* is the canonical articulation of the principle that teammates may disagree with a decision, but once the evidence has been weighed and every relevant voice has been heard, the team commits to executing it. And the dissent, with its cited evidence, is recorded so the decision can be revisited later if evidence changes. The skill's synthesis output records dissent under disagree-and-commit so the plan can reopen cleanly if evidence changes.

URLs: https://en.wikipedia.org/wiki/Disagree_and_commit and https://www.amazon.jobs/content/en/our-workplace/leadership-principles

### Acceptance Criteria and Definition of Done

Acceptance criteria and Definition of Done are the standard project-management artifacts for making "done" testable rather than subjective. The skill's output plan requires a testable definition of done, unambiguous acceptance criteria, and a rollback plan. Vague done-criteria are flagged as open items that block synthesis. The project-manager will not declare the plan ready if "done" is still subjective.

URLs: https://www.atlassian.com/work-management/project-management/acceptance-criteria and https://www.projectmanager.com/blog/acceptance-criteria-project-management

### Danilo Sato: Expand-and-Contract (Parallel Change)

The expand-and-contract pattern (expand the schema / interface / contract, migrate consumers, backfill, flip, contract) is the default recommendation the skill's `devops-engineer` and `data-engineer` sub-agents produce when the feature touches data migration or interface change. The skill's output plan encodes this into the Decomposition and Sequencing table when applicable, because big-bang changes co-deployed with dependent code violate every rollback constraint.

URL: https://martinfowler.com/bliki/ParallelChange.html

### Martin Fowler: Feature Toggles

Fowler's feature-toggles article formalizes flags as a rollout and rollback mechanism distinct from configuration and permissioning. The skill's output plan records feature-flag strategy in the Operational Readiness section when `devops-engineer` contributes (name, default, widening criteria, rollback criterion) so the flag is treated as a reversible ship vehicle rather than a permanent configuration.

URL: https://martinfowler.com/articles/feature-toggles.html

### Iterative and Incremental Development

The skill's loop (rounds of specialist review plus facilitation until convergence, capped by size: 1 round for small, 2 for medium, 3 for large) draws on the broader iterative-and-incremental tradition documented by Craig Larman and Victor Basili and embedded in every modern Agile framework. Iteration gives specialists the chance to update their input as new information lands from other specialists. The cap prevents runaway cycles when facilitation has plateaued.

URL: https://ieeexplore.ieee.org/document/1204375

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies before committing items. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Skills Index](./README.md). All skills, grouped by purpose.
- [Sizing](../sizing.md). The cross-skill sizing model. Explains the small / medium / large bands, the default-to-small rule, and the `$size` override.
- [`/plan-a-feature`](./plan-a-feature.md). The prior step. Produces the `feature-specification.md` this skill consumes. Running the two in sequence is the intended flow: *what* first, *how* second.
- [`/stakeholder-summary`](./stakeholder-summary.md). The optional intermediate step. Turns the `feature-specification.md` into a plain-language summary for non-technical stakeholders before this skill runs, so the implementation plan starts from a shape stakeholders have already greenlit.
- [`/iterative-plan-review`](./iterative-plan-review.md). The complement for stress-testing the plan after it lands. This skill produces the committable plan. `/iterative-plan-review` iterates on it.
- [`project-manager`](../agents/project-manager.md). The agent the skill uses as coordinator for every facilitation round and as the author of the final synthesized plan. This document covers the PM's operating modes in depth.
- [`junior-developer`](../agents/junior-developer.md). The generalist stress-tester the skill always includes. When a decision lacks strong evidence, the skill asks this agent to reframe the issue in plain language before escalating to you.
- [`devops-engineer`](../agents/devops-engineer.md). Typically engaged when the feature touches deployment, observability, rollout, feature flags, scale, SLO impact, or cost.
- [`on-call-engineer`](../agents/on-call-engineer.md). Typically engaged when the plan introduces application-source resilience patterns: timeouts and deadline propagation, retry logic with backoff and jitter, idempotency-key wiring, queue and buffer handling, async / blocking-I/O patterns, bulkhead boundaries, correlation-id propagation, kill-switch wiring. Hard boundary against `devops-engineer`: this agent reads application source only.
- [`data-engineer`](../agents/data-engineer.md). Typically engaged when the feature touches schema changes, migrations, data movement, or analytics implications.
- [`user-experience-designer`](../agents/user-experience-designer.md). Typically engaged when the feature has a user-facing surface, UI, or interaction model.
- [`software-architect`](../agents/software-architect.md). Engaged when the feature is mostly internal to one codebase or bounded context and the plan benefits from intra-codebase module, class, and interface recommendations.
- [`system-architect`](../agents/system-architect.md). Engaged when the feature crosses a service boundary, introduces a new integration, changes a context-map relationship, or shifts data ownership. Both architects are engaged when the feature has both dimensions.
- [multi-agent-economics.md](../guidance/agent-building-guidelines/multi-agent-economics.md). Why this skill uses a team of specialists coordinated by a PM rather than a single large agent trying to cover every domain.
- [skill-decomposition.md](../guidance/skill-building-guidance/skill-decomposition.md). Why this skill owns the "build the implementation plan" slice and hands off to sibling skills.
