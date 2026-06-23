# /plan-a-feature

Operator documentation for the `/plan-a-feature` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-planning/skills/plan-a-feature/SKILL.md`](../../../han-planning/skills/plan-a-feature/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Builds a feature specification through an evidence-based interview, then dispatches specialist reviewers to stress-test the draft.
- **When to use it.** You have a feature idea and need a canonical spec for *what* the feature does before planning *how* to build it.
- **What you get back.** Three to four cross-referenced files: `feature-specification.md`, `artifacts/decision-log.md`, `artifacts/team-findings.md`, and `artifacts/feature-technical-notes.md` (lazily created only when the interview captures load-bearing mechanics).
- **Size-aware.** The skill classifies the feature as small / medium / large, defaults to small, and caps the review-team size proportional to scope. Pass the size as the first positional argument to override (`/plan-a-feature large "describe the feature"`). See [Sizing](#sizing).

## Key concepts

- **Explore before asking.** The skill reads the codebase, ADRs, and coding standards before surfacing a question — and, when a read-only tool that authoritatively answers a question is already available to the session (for example a connected schema or data-source tool), it queries that too. Your judgment is reserved for decisions that genuinely need it.
- **Behavioral specification.** The spec describes outcomes, flows, states, and coordinations. Not libraries, file paths, or data shapes. Technical detail is admissible only as evidence for a behavioral decision.
- **Decision tree walking.** Foundational decisions (what, who, outcome, trigger) settle before behavioral ones (flows, states); behavioral before boundary (edge cases); boundary before interaction (UI/API surface).
- **Specialist review round.** Three to five sub-agents stress-test the draft in parallel. `junior-developer` is always in the mix. `project-manager` reconciles their findings.
- **Cross-referenced artifacts.** Every non-obvious behavior in the spec carries an inline `([D#](...))` marker linking to the decision that drove it. Every `F#` finding links to the `D#` it touched and the spec section it changed.

## When to use it

**Invoke when:**

- You want to plan, design, scope, specify, or flesh out a new feature, capability, or system behavior *before* implementation. *"Help me plan X," "spec out this feature," "design the Y flow," "let's figure out what it should do."*
- A feature idea is at the pre-implementation stage and the team needs a canonical specification of *what* the feature does before deciding *how* to build it.
- A PRD or product brief has landed but the team needs a behavior-level specification (flows, states, edge cases, coordinations) grounded in the actual codebase before implementation planning can begin.
- The team wants an evidence-driven interview rather than a free-form design session. The skill explores the codebase, ADRs, coding standards, and existing specs for every decision and only surfaces genuinely user-judgment questions.
- Multiple ambiguous branches exist in the design space and the team wants a decision tree walked deliberately, parent-decision-first, so dependent decisions aren't asked before their parents are settled.
- The team wants a durable decision history: each decision, the answer, the evidence or user input that settled it, and rejected alternatives. Kept alongside the spec (in a companion `artifacts/decision-log.md`) so future readers can trace *why* the spec says what it says without cluttering the behavioral narrative.

**Do not invoke for:**

- **Refining or stress-testing an existing plan.** Use `/iterative-plan-review` when a plan has already been drafted and the team wants multiple review passes challenging assumptions and identifying overlap.
- **Turning a completed specification into an implementation plan.** Use `/plan-implementation` after this skill produces `feature-specification.md`.
- **Investigating a bug or failure.** Use `/investigate` for evidence-based root-cause work.
- **Analyzing existing architecture.** Use `/architectural-analysis` for assessing coupling, cohesion, data flow, concurrency, and SOLID alignment of an already-built module.
- **Documenting an already-built feature.** Use `/project-documentation` when the feature exists and needs documentation.
- **Contributing a new skill, agent, or documentation file to a plugin.** Follow the repository's `CONTRIBUTING.md` checklist. This skill is sized for software features grounded in a codebase; a plugin contribution is a conventions-driven file addition, and routing it through the full specification protocol produces more scaffolding than the change warrants. (Documentation with genuine behavioral complexity, like a multi-surface guide, is still a fit.)
- **Recording an architectural decision.** Use `/architectural-decision-record` when the team has made a decision that needs to be captured as an ADR.
- **File-level code review.** Use `/code-review` for correctness, style, and maintainability review of committed or pending code.
- **Researching options before there is a feature to spec.** Use [`/research`](../han-core/research.md) to weigh options and prior art; bring the recommendation back here to specify it.

## How to invoke it

Run `/plan-a-feature` directly in Claude Code. Pair it with a description of the feature in the same message, or let the skill ask you for one if you haven't given enough.

Give it:

1. **A feature description.** One to two sentences on what the feature does and what outcome it produces. Even a thin description works (the skill asks for more if it genuinely cannot start), but a crisper description collapses whole classes of early questions.
2. **An output folder, optional.** If you already know where the spec should live (for example, `docs/features/user-invite-flow/`), state it. Otherwise, the skill proposes a three-to-five-word kebab-case folder name under an existing documentation root (discovered via CLAUDE.md, `project-discovery.md`, or Glob fallbacks) and confirms with you before creating files.
3. **Any context the skill should respect.** Point it at a PRD, a product brief, a linked issue, a meeting transcript, or a prior conversation. The skill reads the codebase, ADRs, and coding standards automatically, but upstream product context typically lives outside the repo.

Example prompts that work well:

- `/plan-a-feature`. *"Help me plan a bulk CSV export feature for the admin dashboard. Admins should be able to request an export of any list view, get an email when it's ready, and download the file."*
- `/plan-a-feature docs/features/`. *"Design the webhook retry feature and drop the spec in docs/features/. We want retries to back off, surface to the sender, and surface a delivery log in the admin UI."*
- `/plan-a-feature`. *"Spec out the user-invite flow for our workspace product. Here's the PRD: [link]. Walk the decision tree with me."*
- `/plan-a-feature`. *"I have a rough idea for a 'draft review' state in our approval workflow but I don't know the edge cases. Interview me."*

Thin prompts (*"plan a feature"*) still work. The skill asks for the one-to-two-sentence description before proceeding. A crisper initial prompt reduces the interview length significantly.

## What you get back

Up to four cross-referenced files on disk in the same folder, plus an in-channel summary:

- A **`feature-specification.md`** file at `{folder}/feature-specification.md`. The primary behavioral spec, structured as: Outcome, Actors and Triggers, Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes, User Interactions, Coordinations, Out of Scope, a `Deferred (YAGNI)` section (written only when at least one item was deferred), Open Items, and a Summary with counts. Non-obvious behaviors carry inline parenthetical markers (for example, `([D4](artifacts/decision-log.md#d4-invite-expiration-window))`) linking to the decision that drove them. Technical details (libraries, data shapes, specific file paths) do not appear here. They appear only as *Evidence* under the corresponding decision in the decision log, or as a `T#` technical note when the mechanic is load-bearing for the spec.
- An **`artifacts/decision-log.md`** file at `{folder}/artifacts/decision-log.md`. One `D#` entry per decision the interview settled, with the question, the behavioral decision, the rationale, the evidence or user input that settled it, the rejected alternatives with reasons, the dependent decisions that rested on it (`Dependent decisions:`), the review findings that reshaped it (`Driven by findings:`), and the spec sections that cite it (`Referenced in spec:`). Future readers can trace *why* the spec says what it says, and reopen a decision cleanly if the evidence changes.
- An **`artifacts/team-findings.md`** file at `{folder}/artifacts/team-findings.md`. One `F#` entry per finding the review team raised, recording which specialist raised it (`Agent:`), the finding text, the evidence considered, the resolution and what resolved it (`Resolved by:` evidence / user input / project-manager), the decisions it touched (`Affected decisions:`), and the spec sections it changed (`Changed in spec:`).
- An optional **`artifacts/feature-technical-notes.md`** file at `{folder}/artifacts/feature-technical-notes.md`. **Lazily created**, written only when at least one load-bearing mechanic surfaces during the interview or review that the spec needs in order to describe a behavior correctly. Each entry is a `T#` note linked from the spec via `([T#](artifacts/feature-technical-notes.md#t#-slug))` and back to the decisions it supports (`Supports decisions:`) and the findings that drove it (`Driven by findings:`). If no `T#` qualifies, the file is never created and the spec contains no `T#` links.
- An **open items list** inside the spec. Questions or concerns the project-manager flagged that could not be resolved during specification, each with what would resolve it and whether it blocks implementation.
- A **summary** returned in-channel. All file paths (including `feature-technical-notes.md` only when it was created), the number of decisions settled by evidence vs. by user input, the sub-agents consulted, key adjustments each drove, and any remaining open items the project-manager flagged for follow-up.

The files interlock through shared IDs. Every `D#` lists its `F#` drivers and its referencing spec sections. Every `F#` lists its `D#` impacts and the spec sections it changed. When `T#` technical notes exist, they cross-link to their supporting decisions and back to the spec sections that cite them. Every non-obvious behavior in the spec carries its inline `([D#](...))` or `([T#](...))` marker. Any edit to one file is expected to update the matching fields in the others so the cross-references stay consistent.

Every decision is traceable to a specific citation (codebase path, ADR, coding standard, or *"user input"*). Every rejected alternative is recorded with the reason it was rejected. The spec is not "done" while a blocking open item remains. The skill surfaces it rather than inventing an answer.

## How to get the most out of it

- **State the feature and the outcome up front.** The single biggest lever. One to two sentences on what the feature does and what successful use produces collapses whole classes of early-interview questions.
- **Let the skill explore before asking.** The skill is designed to read the codebase, ADRs, coding standards, and existing specs before surfacing a question. If you start answering questions before the skill has explored, the spec fills up with user judgment where codebase evidence could have settled the decision instead.
- **Point it at upstream product context.** A PRD, product brief, linked issue, meeting transcript, or previous spec sharpens every decision in the tree. The skill doesn't invent product intent. It needs something to ground it.
- **Let the decision tree descend.** The skill walks foundational decisions first (what, who, outcome, trigger, done), then behavioral (flows, states, coordinations), then boundary (edge cases, failure, out of scope), then interaction (UI / API surface). Jumping ahead (*"but what about error state X?"*) before the parent decision is settled usually produces an answer that has to be rewritten later.
- **Use the recommendations.** Every question surfaced to you comes with a recommended answer grounded in evidence. Accepting or redirecting a recommendation is much faster than answering from a blank page.
- **Treat the decision log as a durable artifact.** `artifacts/decision-log.md` exists so future readers (and future planning sessions) can trace why the spec says what it says. When a decision is later reopened (because evidence changed), the log tells you exactly what the original rationale was, which findings reshaped it, and which spec sections depend on it. Do not edit the spec's inline `([D#](...))` markers without updating the matching entry in the decision log.
- **Expect a review round.** Once the draft is written, three to five sub-agents review it in parallel. The skill does not present their raw findings to you. It first tries evidence-based resolution, and only escalates the findings that genuinely need user judgment, organized by the decision they affect. Trust that loop rather than asking for the raw agent output.
- **Pair with `/plan-implementation` next.** This skill produces *what*. The `/plan-implementation` skill turns that into *how*: decomposition, sequencing, RAID log, testing strategy, operational readiness, rollback. Running the two in sequence is the intended flow. For the full end-to-end planning workflow from rough idea to individual work items, see [How to plan a feature, end to end](../../how-to/plan-a-feature.md).
- **Re-run when the spec must change.** If the outcome materially shifts (new constraint, new stakeholder, new evidence from production), re-run the skill with the new context and let it walk the tree again. The existing spec, decision log, and team findings all become inputs to the new run. Prior `D#` / `F#` IDs carry forward so cross-references remain stable.

## Sizing

Size determines the review-team cap when the skill dispatches sub-agents to stress-test the draft spec. The skill defaults to small and only escalates when concrete signals require it.

| Size | Surface | Typical signals | Team cap |
|---|---|---|---|
| **Small** *(default)* | Single subsystem | No cross-service integration, no auth/PII surface, no data migration; behavioral surface fits in one tab/page or one API call. | 2 (junior-developer + 1 chosen specialist) |
| **Medium** | Two to three subsystems | Optional integration; may touch UX or rollout; may have a small auth surface. | 3–4 |
| **Large** | Cross-service or security-sensitive | Data ownership shifts, multiple new coordinations, or you explicitly request full team review. | 4–5 |

How the size is chosen:

- **Default to small.** Unless the draft spec touches multiple subsystems or cross-cutting concerns, the skill stays at small and dispatches a minimal review team.
- **`junior-developer` always included.** The generalist stress-tester is part of the team at every size. Size sets the cap on additional specialists chosen by signal.
- **Mechanic-focused specialists are excluded by default.** Structural, behavioral, concurrency, and architecture specialists are not part of the default spec-stage roster. Those concerns belong to `/plan-implementation`. Include one only if you explicitly ask for it.

How to override the size:

- Pass `small`, `medium`, or `large` as the first positional argument: `/plan-a-feature medium "describe the feature"`, `/plan-a-feature large docs/features/ "design the webhook retry feature"`.
- When the size is overridden via `$size`, the skill announces the override (`Medium: passed via $size`) and uses the chosen band for the team cap.
- Conversational overrides (*"treat this as a large spec, it touches auth"*) still work and are equivalent.

For the cross-skill sizing model and design principles, see [Sizing](../../sizing.md).

## Cost and latency

The skill orchestrates a multi-step interview plus a parallel sub-agent review round plus a project-manager synthesis pass. The skill passes no model override; each dispatched sub-agent runs on its own frontmatter tier (so `project-manager`, `junior-developer`, and the other synthesis-heavy agents run on `opus`, while the structured-protocol specialists run on `sonnet`). The interview itself is inexpensive (a model loop with codebase reads), but the sub-agent review round fans out to three to five agents in parallel, each doing its own protocol-driven pass over the draft spec. The synthesis pass on `project-manager` is the most expensive single step. For a medium-complexity feature, expect one interview loop, one parallel review round, and one synthesis pass: roughly equivalent to dispatching five to six sub-agents plus the interview loop itself. The skill is designed for new-feature planning cadence (daily to weekly), not for tight-loop iteration over the same spec. Use `/iterative-plan-review` for that.

## In more detail

The skill's default posture is to *explore before asking*: if a question can be answered by reading the codebase, project docs, coding standards, ADRs, or existing feature specs, the skill resolves it without troubling you. That source set extends to a read-only tool already available to the session — a connected schema or data-source tool, say — when one is permitted to the skill; it queries that source the same way it reads the filesystem ones, strictly read-only. The path is gated on the tool actually being available: if none is, the skill falls back to asking you, exactly as before. When a question genuinely requires user judgment, the skill surfaces it with a recommended answer, rationale grounded in evidence, and alternatives considered. You accept, amend, or redirect.

The specification the skill produces is deliberately behavioral: outcomes, actors, triggers, flows, states, coordinations, edge cases, and user interactions. Technical artifacts (file paths, libraries, data shapes) are admissible only as **evidence** for behavioral decisions, never as the decision itself.

Once a draft is in place, the skill dispatches three to five specialist sub-agents in parallel to stress-test the spec (always including `junior-developer` as generalist stress-tester), then runs `project-manager` in synthesis mode to reconcile their input and apply corrections. The output is three cross-referenced files: `feature-specification.md` at the folder root (the canonical behavioral artifact that `/plan-implementation` turns into an implementation plan), plus `artifacts/decision-log.md` and `artifacts/team-findings.md` in a sibling `artifacts/` subfolder so the primary spec stays focused on behavior while decision history and review findings sit alongside it, cross-referenced by `D#` / `F#` ID.

## YAGNI

Every behavior, edge case, alternate flow, and coordination committed to the spec must cite at least one piece of acceptable evidence: a user-described need in the source artifact, a named direct dependency, an existing production code path that breaks without it, a regulatory rule that applies today, or a documented incident or measured metric. Behaviors that are interesting but unjustified land in a `## Deferred (YAGNI)` section in the spec with a named *reopen-when* trigger. They are recorded, not silently dropped. The `junior-developer` and `project-manager` agents both apply YAGNI protocols (Evidence Sweep and Evidence Gate, respectively) during the review round, so uncited behaviors that survived the interview get challenged before the spec hardens.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.

The companion [evidence rule](../../evidence.md) characterizes the quality of the evidence each surviving spec commitment rests on: name the trust class of cited sources (codebase, web, provided); mark single-source web claims that drive a commitment; label commitments with no evidence at any tier as a distinct deferred state rather than weak evidence. YAGNI gates inclusion; the evidence rule names how strong the cited evidence is.

## Sources

The skill's posture and protocols draw on established practice in behavior-driven specification, evidence-based interview, and decision-tree walking. Each source below is cited because the skill draws specific, named artifacts from it. Not as a reading list, but as the provenance of the stance the skill takes.

### Dan North: Behavior-Driven Development

Dan North's BDD framing reoriented specification work around *behaviors*: what the system does, from whose perspective, under what conditions, rather than internal structure. The skill's insistence that specifications describe *outcomes, flows, states, and coordinations* and treat implementation detail as evidence-for-decisions rather than decisions-themselves is taken directly from this tradition. BDD's "given / when / then" structure is visible in the spec's Primary Flow, Alternate Flows, and Edge Cases sections.

URL: https://dannorth.net/introducing-bdd/

### Gojko Adzic: Specification by Example

Adzic's *Specification by Example* formalizes the practice of grounding specifications in concrete, testable examples drawn from real user scenarios rather than abstract requirements. The skill's Edge Cases and Failure Modes table and its decision-log evidence citations reflect this discipline: every behavioral statement must be traceable to an example, a prior decision, or a piece of codebase evidence, never to a vague *"we should probably."*

URL: https://gojko.net/books/specification-by-example/

### Eric Evans: Domain-Driven Design (Ubiquitous Language)

The DDD practice of building a ubiquitous language (the team's shared vocabulary for the domain) informs the skill's requirement that specifications reference actors, subsystems, and coordinations *by name*, not by file path or class name. When the spec says *"the invitation service notifies the workspace owner,"* the skill expects the team to have agreed that those names describe meaningful domain concepts, independent of whether the current implementation happens to live in `InvitationService.ts`.

URL: https://www.domainlanguage.com/ddd/

### Alberto Brandolini: Event Storming

Brandolini's Event Storming technique sketches out domain behavior as a chronological flow of domain events, commands, and actors on a wall full of sticky notes (*what happens, who triggers it, what produces it*) before anything is implemented. The skill's Design Tree protocol walks a similar shape: foundational decisions (actor, outcome, trigger), then behavioral (flows, states, coordinations), then boundary (edge cases, out of scope). The decision tree is Event Storming flattened into a linear, evidence-checked interview.

URL: https://www.eventstorming.com/

### Toyota Production System: The Five Whys

Root-cause analysis via repeated "why" questioning, popularized at Toyota and adopted widely in software and design practice. The skill's interview loop applies a softer version: for every candidate answer, the skill checks the evidence (codebase, docs, ADR) and asks whether the answer resolves the question or masks a deeper one that needs to be surfaced. Questions that survive only because they were repeated, rather than proven, go into Open Items rather than into the spec body.

URL: https://www.toyota-industries.com/company/history/toyoda_precepts/

### Dave Farley: Continuous Delivery (Behavior vs. Implementation)

Farley's *Continuous Delivery* and follow-on work on modern software engineering draw a sharp line between specifying *behavior* (observable, testable, stable across rewrites) and specifying *implementation* (ephemeral, refactor-friendly, subject to change). The skill encodes this as a rule: technical details are admissible in the spec only as evidence for behavioral decisions, never as the decision itself. A spec that says *"use Redis for this"* has overshot into implementation. A spec that says *"the system remembers the last N requests from each actor for five minutes"* has stated a behavior, and Redis becomes one implementation option among several.

URL: https://continuousdelivery.com/

### Decision Trees in Product and Engineering Design

Decision-tree walking (resolving foundational decisions before dependent ones, parent-before-child) is a longstanding practice across product management, decision science, and systems engineering. The skill's Step 3 (Build the Design Tree) and Step 4 (Interview Loop, One Branch at a Time) enforce this sequencing so the interview does not ask about edge-case error messages before the primary flow is agreed. A decision asked out of order has to be rewritten once its parent lands.

URLs: https://hbr.org/1964/07/decision-trees-for-decision-making and https://www.productplan.com/glossary/decision-tree/

### RAID and Decisions Log

The RAID log (Risks, Assumptions, Issues, Decisions) and the Agile-era decision log are the standard project-management artifacts for recording the *what* and the *why* of a decision so a future reader can reopen it cleanly if evidence changes. The skill's Decisions Log and Open Items sections encode these directly into the spec: every decision records rationale, evidence, rejected alternatives, and dependent decisions; every open item names what would resolve it and whether it blocks implementation.

URLs: https://asana.com/resources/raid-log and https://projectmanagementcompass.substack.com/p/building-decision-logs-that-protect

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies before committing items. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Evidence](../../evidence.md). The companion rule that characterizes how strong each surviving commitment's evidence is. Trust classes, the corroboration gate, and the no-evidence label.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [Sizing](../../sizing.md). The cross-skill sizing model. Explains the small / medium / large bands, the default-to-small rule, and the `$size` override.
- [`/research`](../han-core/research.md). The upstream step when you had options to weigh before specifying. `/research` recommends an option among trade-offs; bring that recommendation here to turn it into a behavioral spec. The pairing is bidirectional: `/research` closes by pointing here.
- [`/plan-implementation`](./plan-implementation.md). The next step after this skill. Takes the `feature-specification.md` produced here and turns it into a feature-implementation-plan through an iterative, project-manager-led team conversation.
- [`/stakeholder-summary`](../han-reporting/stakeholder-summary.md). The optional sibling for non-technical feedback. Takes the `feature-specification.md` produced here and turns it into a plain-language stakeholder summary with Mermaid diagrams, for sharing with leadership, product, or customer-facing reviewers before implementation kicks off.
- [`/iterative-plan-review`](./iterative-plan-review.md). The complement for plans that already exist. Use this when an implementation plan or spec has been drafted and needs multiple review passes to challenge assumptions and refine.
- [`project-manager`](../../agents/han-core/project-manager.md). The agent the skill dispatches for the final synthesis pass that reconciles sub-agent review output into the authoritative specification.
- [`junior-developer`](../../agents/han-core/junior-developer.md). The generalist stress-tester the skill always includes in the sub-agent review round. Surfaces hidden assumptions, muddied scope, and uncited claims before the spec hardens.
- [`user-experience-designer`](../../agents/han-core/user-experience-designer.md), [`adversarial-security-analyst`](../../agents/han-core/adversarial-security-analyst.md), [`devops-engineer`](../../agents/han-core/devops-engineer.md), [`on-call-engineer`](../../agents/han-core/on-call-engineer.md), [`edge-case-explorer`](../../agents/han-core/edge-case-explorer.md), [`test-engineer`](../../agents/han-core/test-engineer.md), [`gap-analyzer`](../../agents/han-core/gap-analyzer.md), [`risk-analyst`](../../agents/han-core/risk-analyst.md). The signal-selected specialists the skill dispatches in the spec-review round when the spec touches their domain. `on-call-engineer` is engaged for resilience commitments the spec must make (idempotency on retried operations, timeout and deadline behavior, graceful-degradation paths, kill-switch availability, named failure-mode coverage).
- [skill-decomposition.md](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-decomposition.md). Why this skill owns the "build the spec" slice and hands off to sibling skills for implementation planning, iteration, and review instead of doing everything itself.
