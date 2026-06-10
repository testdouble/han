---
name: "plan-a-feature"
description: >
  Builds a feature specification from scratch through a relentless, evidence-based interview that
  walks the design tree decision-by-decision, resolving dependencies as it goes. Use when the user
  wants to plan, design, scope, specify, or flesh out a new feature, capability, or system
  behavior before implementation. Produces a feature specification focused on system behaviors,
  not implementation detail. Does not refine or stress-test an existing plan — use
  iterative-plan-review. Does not document already-built features — use project-documentation.
  Does not research open-ended options before there is a feature to specify — use research.
arguments: size
argument-hint: "[size: small | medium | large] [feature description, optional: output folder path]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(mkdir *)
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Operating Principles

- **Interview relentlessly, but explore first.** If a question can be answered by reading the codebase, project docs, coding standards, ADRs, or existing feature specs — or by querying a read-only tool already available to this session that authoritatively answers it (for example a connected schema or data-source tool) — explore instead of asking. Only surface questions that genuinely require the user's judgment. The connected-tool path is gated on availability, not on a fresh judgment: use it only when such a read-only tool is actually permitted to this skill; if none is available, ask the user as today (see Step 4).
- **Walk the design tree.** Decisions have dependencies. Resolve foundational decisions first (what the feature does, who uses it, what outcome it produces). Then descend into dependent decisions (flow, states, edge cases, coordination points). Never ask a dependent question before its parent is settled.
- **Recommend, then ask.** For every question surfaced to the user, provide a recommended answer with rationale grounded in evidence (code, docs, conventions, or stated goals). The user can accept, redirect, or provide a nuanced response.
- **Behavior, not implementation, in the spec.** The specification captures WHAT the feature does, for WHOM, and WHY — at a level a reader who has never opened the codebase can understand. Language primitives, file/line references, function or class names, library mechanics, implementation patterns, and internal env/flag names DO NOT appear in `feature-specification.md`. Product-level subsystem names ("events processing system", "backend service"), user-facing UI vocabulary (popover, modal, toast), URL paths, behavioral verbs, and user-observable states DO. Technology brand names generalize one level up (NATS → "events processing system"; PostgreSQL → "database"; Redis → "cache"). This rule is language-agnostic — it applies equally to Go, Rails, Node, Python, Swift, Kotlin, and frontend JavaScript code. Any examples given in references or templates are illustrative, not an exhaustive deny-list.
- **Load-bearing mechanics go in `feature-technical-notes.md`, not the spec.** When a mechanic is load-bearing for a behavior — meaning the behavioral commitment in the spec is only correct because of that mechanic (ordering, durability, consistency, visibility timing) — the behavioral consequence goes in the spec sentence, and the mechanic goes in a `T#` note linked inline from that sentence. The tech-notes file is LAZILY created — it exists only when at least one load-bearing mechanic qualified. Mechanics that are discoverable from the code repo (an existing pattern, an in-use library, a documented convention) do NOT belong in the tech-notes file either — `plan-implementation` will find them from the code. Mechanics that do not affect observable behavior are pure implementation and belong in the implementation plan, not here.
- **YAGNI is a first-class operating principle.** Apply the evidence-based YAGNI rule defined in [../../references/yagni-rule.md](../../references/yagni-rule.md). Every behavior, alternate flow, edge case, coordination, open item, or other commitment in `feature-specification.md` must cite at least one piece of evidence per the rule's evidence test (user-described need, named direct dependency, existing production code path that breaks, applicable regulation, documented incident or measured metric). When evidence justifies the item, apply the simpler-version test — replace with the strictly simpler version that satisfies the same evidence. Items that fail the evidence test get demoted to a `## Deferred (YAGNI)` section in the spec with the trigger that would justify reopening, never silently dropped and never silently kept. Every spec section is ongoing maintenance and a pattern future agents will copy.
- **Evidence quality is a companion operating principle.** Apply the evidence rule from [../../references/evidence-rule.md](../../references/evidence-rule.md) alongside YAGNI. YAGNI gates inclusion (is there any evidence?); the evidence rule characterizes the quality of the evidence each spec commitment rests on. Name the trust class of cited sources (codebase, web, provided); mark single-source web claims that drive a commitment; label commitments with no evidence at any tier as a distinct deferred state rather than weak evidence. The proximity-to-origin principle is a heuristic, not a strict tier list.
- **All sub-agents in this skill run on sonnet.** When launching any Agent tool call in this skill, pass `model: "sonnet"`.

# Plan a Feature

## Step 1: Capture the Feature Request and Output Location

Read the user's argument and conversation context to extract the feature being planned. If the request is too thin to start (e.g., just "plan a feature"), ask the user for a one-to-two-sentence description of what the feature does and what outcome it produces — nothing else yet.

Resolve the output location:
- If the user specified a folder path, use it.
- Otherwise, propose a folder name of **3 to 5 words** in kebab-case (e.g., `docs/features/user-invite-flow/`, `docs/plans/bulk-export-jobs/`). Prefer placing it under an existing documentation root discovered via CLAUDE.md's `## Project Discovery` section, `project-discovery.md`, or Glob fallbacks (`docs/features/`, `docs/plans/`, `docs/`).
- Confirm the folder name with the user before creating files. If the folder does not exist, create it.

Up to four files will be written. The primary spec lives at the root of `{folder}/`; the companion artifacts live in `{folder}/artifacts/` to keep the planning folder uncluttered:

- `{folder}/feature-specification.md` — the primary behavioral spec. Always written.
- `{folder}/artifacts/decision-log.md` — the full decision history with rationale, evidence, and rejected alternatives. Always written.
- `{folder}/artifacts/team-findings.md` — review-team findings and how each was resolved. Always written.
- `{folder}/artifacts/feature-technical-notes.md` — load-bearing mechanics that were captured because they were needed to correctly specify a behavior. **Lazily created** — written only if at least one `T#` qualifies during the interview (Step 4) or finding resolution (Step 7). If no `T#` qualifies, the file is never created and the spec contains no `T#` links.

Create the `artifacts/` subfolder before writing the companion files if it does not already exist.

The files cross-reference each other. The main spec cites decisions with inline parenthetical links like `([D4](artifacts/decision-log.md#d4-invite-expiration-window))` and cites technical notes (when the file exists) with inline parenthetical links like `([T3](artifacts/feature-technical-notes.md#t3-ack-ordering))`. The decision log, findings log, and tech-notes file (all siblings inside `artifacts/`) cross-link through `Driven by findings:` / `Linked technical notes:` / `Affected decisions:` / `Affected tech-notes:` / `Supports decisions:` fields, and all reference back into the spec with `../feature-specification.md` paths.

## Step 2: Discover Before Asking

Before asking the user anything beyond the initial framing, explore the codebase and project documentation to gather context that will answer as many design-tree questions as possible. Use Glob and Grep to find:

- CLAUDE.md, AGENTS.md, and any `project-discovery.md` — tech stack, constraints, conventions.
- ADRs in `docs/adr/` or `docs/architecture/decisions/` — prior architectural decisions the feature must respect.
- Coding standards in `docs/coding-standards/` or `.github/CODING_STANDARDS.md` — rules the feature's design must align with.
- Existing feature specifications or PRDs — tone, structure, level of detail the team expects.
- Code adjacent to what the feature touches — current behaviors, patterns, integration points.

If a read-only tool that authoritatively answers a design-tree question is already available to this session (for example a connected schema or data-source tool), and it is permitted to this skill, you may query it here read-only to resolve that question the same way the filesystem sources above are used. If no such tool is available, rely on the filesystem sources and surface the question per Step 4. Never write or change state through such a tool.

Record what was found (file paths) and what was not found. Missing standards are themselves findings that inform the feature spec.

## Step 3: Build the Design Tree

Enumerate the decisions the feature needs in dependency order. A decision is a **question whose answer shapes behavior**. Group them into tiers:

1. **Foundational** — What is the feature? Who uses it? What outcome does it produce? What triggers it? What does "done" look like?
2. **Behavioral** — What are the primary and alternate flows? What states does the feature move through? What coordinations between actors, services, or subsystems are involved?
3. **Boundary** — What edge cases, failure modes, and rollback behaviors must be specified? What is explicitly out of scope? What does the system do when inputs are malformed, missing, or adversarial?
4. **Interaction** — If there is a user interface or API surface, what is the interaction model? What affordances, feedback, and error states must exist?

Do not pre-populate the tree with implementation detail. Keep each node as a behavioral question with a candidate answer.

## Step 4: Interview Loop — One Branch at a Time

For each decision in dependency order:

1. **Try to resolve it from evidence.** Re-check the codebase, docs, standards, ADRs, and already-settled decisions. If a read-only tool that authoritatively answers the question is available to this session (a connected schema, data-source, or similar read-only tool) and permitted to this skill, query it before surfacing the question — the same answerable-from-a-source discipline already applied to static sources, extended to connected ones. Gate it on availability, not judgment: if such a tool is available, use it; if none is available (including because it is not permitted to this skill), ask the user as today. Keep it read-only — no writes, no state changes. If the answer is clear from evidence, record it in the spec with the evidence citation and move on — do not ask.
2. **If evidence is insufficient, draft a recommended answer.** Ground the recommendation in whatever evidence is available (prior decisions, conventions, stated goals, user's framing). State the recommendation, the rationale, and the alternatives considered.
3. **Apply the YAGNI evidence test before surfacing.** A decision that exists only for "completeness", "for future flexibility", "we might want to", "best practice", or symmetry with another feature is a YAGNI candidate per [../../references/yagni-rule.md](../../references/yagni-rule.md). When no accepted evidence (user-described need, named direct dependency, existing code path, applicable regulation, documented incident/metric) supports the decision, the recommended answer is "defer this to the spec's `## Deferred (YAGNI)` section with the reopening trigger named" — surfaced to the user with rationale like any other recommendation. When evidence does support the decision, apply the simpler-version test: is there a strictly simpler behavior that satisfies the same evidence? If yes, recommend the simpler behavior.
4. **Surface to the user only if the decision genuinely needs their judgment.** Present the recommendation, rationale, and alternatives. Allow the user to accept, amend, or redirect. Capture their answer verbatim in the spec.
5. **Descend.** Once a decision is settled, evaluate whether any dependent decisions are now resolvable from evidence (they often are). Repeat.

Keep the interview moving — do not stall on questions the evidence can answer. Do not batch every question upfront; ask as the tree unfolds, because later answers often resolve earlier uncertainties.

### Routing implementation-level details

When settling a decision surfaces an implementation mechanic (a specific library, language primitive, data shape, protocol detail, concurrency choice, or file-level pattern), classify the mechanic BEFORE writing the spec sentence and route it to the correct home:

1. **Does the mechanic change what the user or system observably experiences** — ordering, durability, delivery guarantees, consistency, visibility timing, error-visibility? If yes, settle the behavioral consequence in the spec and capture the enabling mechanic as a `T#` candidate (see capture discipline below). The spec sentence must state the behavioral consequence on its own; the `T#` link only supplies the mechanic. A reader who does not click through to the note must still get the behavior right.
2. **Is the mechanic already discoverable in the code repo** — an existing pattern, an in-use library, a documented convention? If yes, settle the question behaviorally in the spec, cite the evidence source under the D#'s `Evidence:` field, and do NOT create a `T#` note. `plan-implementation` will find the code.
3. **Otherwise the question is pure implementation.** Do not settle it here. Do not put it in the spec, tech-notes, or Open Items. `plan-implementation` owns it.

### T-note capture discipline (in-message accumulator)

The `feature-technical-notes.md` file is not written during Step 4 — it is flushed during Step 5 (or first written during Step 7 if finding resolution produces the first qualifying note). During the interview, track candidates in-message by stating them plainly as they are identified:

> **T-note candidate captured — T(pending #N): {short title}. Supports D{n}; section {spec section}; mechanic: {one-line summary}.**

This makes the accumulator visible in the conversation history and gives the user a chance to redirect ("that's discoverable from code" / "not load-bearing") before the note is written. If the user redirects, drop the candidate from further consideration.

Candidates that later become irrelevant (e.g., a review specialist in Step 6 proves the mechanic is discoverable from code) do not reach disk — Step 5 re-validates every candidate against the routing rules before writing.

## Step 5: Draft the Initial Feature Specification

Write the files. The primary spec goes at the root of `{folder}/`; the companion artifacts go in `{folder}/artifacts/` (create that subfolder if it does not already exist):

1. **`{folder}/feature-specification.md`** — use [feature-specification-template.md](./references/feature-specification-template.md). This is the primary behavioral spec covering:
   - **Outcome** — what successful use of the feature produces, stated in behavioral terms.
   - **Actors and triggers** — who or what invokes the feature, and under what conditions.
   - **Primary flow** — the happy path as a sequence of system behaviors and coordinations.
   - **Alternate flows and states** — branches, retries, escalations, waiting states.
   - **Edge cases and failure modes** — what happens when things go wrong.
   - **User interactions** — if applicable, affordances and feedback the user experiences.
   - **Coordinations** — inbound and outbound interactions with other subsystems.
   - **Out of scope** — what the feature deliberately does not do.
   - **Deferred (YAGNI)** — items considered but deferred under [../../references/yagni-rule.md](../../references/yagni-rule.md). For each: the item, why it was deferred (which gate failed — evidence test or simpler-version test), and the reopening trigger that would justify revisiting. **Lazily created — write this section only if at least one item was deferred. Omit the section entirely when nothing qualifies.**
   - **Open items** — questions flagged for follow-up (populated later by the han.core:project-manager).
   - **Summary** — outcome, actors, decision counts, sub-agents, key adjustments, and (only if tech-notes were captured) the `T#` count.

   For every behavior that embodies a non-obvious decision, append an inline parenthetical link to the decision in `artifacts/decision-log.md`, e.g. `([D4](artifacts/decision-log.md#d4-invite-expiration-window))`. Link only non-obvious behaviors — not every sentence. "Non-obvious" means a reader would reasonably ask "why this and not something else?"

   For every spec sentence whose correct behavior relies on a captured `T#` note, append an inline parenthetical link to the note, e.g. `([T3](artifacts/feature-technical-notes.md#t3-ack-ordering))`. Link only sentences where the mechanic changes observable behavior — never as a gratuitous "see also" link.

   **Apply the spec-content rule from the operating principles to every sentence before writing it.** If a draft sentence names a language primitive, file/line, function or class, library mechanic, implementation pattern, or internal flag, rewrite it behaviorally before it reaches disk. Route the implementation detail to the appropriate home per Step 4's routing rules.

2. **`{folder}/artifacts/decision-log.md`** — use [decision-log-template.md](./references/decision-log-template.md). Classify each decision as **full** or **trivial** before writing it. Full: has a rejected alternative a reasonable engineer would plausibly have chosen (not an obvious or strawman one), evidence beyond the user's framing, driven-by-findings, linked tech-notes, or dependent decisions. Trivial: settled directly by the user's framing or an obvious convention with no alternative worth discussing. Full decisions go under `## Full decisions` with the structured fields. Trivial decisions go under `## Trivial decisions` as a one-line bullet, with an optional single-clause parenthetical when an obvious alternative was discarded (`D#: {title} — {outcome} (considered {alternative}; rejected because {one clause}). — Referenced in spec: {sections}.`); see the template for the exact format and the "if unsure, treat as full" backstop. The D# counter is shared across both sections, and every spec inline link still resolves to a D# whether full or trivial. The `Driven by findings:` field on full decisions is `—` in the initial draft; it is populated in Step 7 when review findings reshape decisions.

3. **`{folder}/artifacts/team-findings.md`** — use [team-findings-template.md](./references/team-findings-template.md). Write the header block; leave the findings list empty. `F#` entries are added in Step 7 after the review team returns.

4. **`{folder}/artifacts/feature-technical-notes.md`** — use [feature-technical-notes-template.md](./references/feature-technical-notes-template.md). **This file is LAZILY created — write it only if at least one captured `T#` candidate qualifies.**

   Flush the in-message accumulator from Step 4:
   - Review every T-note candidate captured during the interview.
   - Re-validate each against the routing rules: load-bearing (affects observable behavior), not discoverable in the code repo.
   - Drop candidates the user redirected or that no longer qualify after later evidence.
   - Assign `T1..Tn` in the order captured (not the order validated).
   - Write one entry per qualifying candidate with `Title`, `Context`, `Technical detail`, `Supports decisions:` (D# IDs), `Driven by findings:` (`—` during initial draft), and `Referenced in spec:` (spec section headings).
   - For every D# whose behavior a T# supports, populate the D#'s `Linked technical notes:` field with the T# IDs.
   - Add inline `([T#](artifacts/feature-technical-notes.md#t#-slug))` links to the spec sentences each note supports.

   **If zero candidates qualify, do not create this file.** The artifacts folder does not gain an empty or stub file. Every reference to `feature-technical-notes.md` in the other artifacts should be absent in this case.

Technical details (specific files, libraries, data shapes) appear **only** under `Evidence:` in `artifacts/decision-log.md` or in `Technical detail:` entries in `artifacts/feature-technical-notes.md` — never as behavioral statements in `feature-specification.md`.

## Step 5.5: Classify Feature Size

Before dispatching the review team, classify the feature. **Default to small.** Start the classification at **small** and only escalate to medium or large when the signals below clearly require it. When a signal is borderline, stay at the smaller band. Use the signals already in the draft spec:

- **Small** *(default)* — single subsystem, no cross-service integration, no auth/PII surface, no data migration, behavioral surface fits in one tab/page or one API call.
- **Medium** — two to three subsystems, optional integration, may touch UX or rollout, may have a small auth surface.
- **Large** — cross-service, security-sensitive, data ownership shifts, multiple new coordinations, or the user explicitly requests full team review.

This size drives the team-size cap in Step 6:

| Size | Team cap | Rationale |
|---|---|---|
| Small | 2 (han.core:junior-developer + 1 chosen specialist) | Limited surface area; one domain specialist is usually enough. |
| Medium | 3 to 4 | Typical default; the historical cap. |
| Large | 4 to 5 | Reserved for plans where missed coverage is expensive. |

**Size override.** If `$size` is non-empty (the user passed `small`, `medium`, or `large` as the first argument), use that value as the size and skip the signal-based classification above; the team cap still scales to the chosen size. State the chosen size, the recommended specialists, and the reason for the size choice to the user in one short message before launching agents (e.g., "Medium: two subsystems, small auth surface" or "Medium: passed via `$size`"). If the user disagrees, accept their override (size, specific specialists, or both) and proceed.

## Step 6: Dispatch the Review Team

Choose sub-agents to review the draft spec in parallel based on the size cap from Step 5.5 and what the feature actually touches. **Always include `han.core:junior-developer`** to surface hidden inconsistencies, muddied scope, and assumptions. Select the remaining specialists from this list, matching domain to feature:

- `han.core:user-experience-designer` — any user-facing flow, UI, or interaction model.
- `han.core:adversarial-security-analyst` — authentication, authorization, PII, untrusted input, secrets — at the behavioral attack-surface level (deep exploit-path work moves to `plan-implementation`).
- `han.core:devops-engineer` — rollout, feature flags, observability, SLO behavior, operational affordances.
- `han.core:on-call-engineer` — resilience commitments the spec must make to keep the on-call rotation healthy: idempotency on retried operations, timeout and deadline behavior, graceful-degradation paths when a dependency is down, kill-switch availability on risky new code paths, named failure-mode coverage. Spec-level only — file-and-line resilience review belongs to `plan-implementation`.
- `han.core:edge-case-explorer` — boundary values, input messiness, state-dependent failures.
- `han.core:test-engineer` — what observable behaviors the spec commits the system to making testable (test-double and collaborator-boundary framing is deferred to `plan-implementation`).
- `han.core:gap-analyzer` — if a PRD or reference spec exists, compare the draft against it.
- `han.core:risk-analyst` — prioritization of risks if the feature has significant blast radius.

**Mechanic-focused specialists — `han.core:structural-analyst`, `han.core:behavioral-analyst`, `han.core:concurrency-analyst`, `han.core:software-architect`, and `han.core:system-architect` — are intentionally excluded from the default spec-stage roster.** The analysts target module boundaries, runtime data flow, and concurrency primitives; the architects synthesize those findings into intra-codebase or cross-service topology recommendations. All of it is `plan-implementation`'s domain under the rule in the operating principles. Include one only if the user explicitly asks for it, and when doing so warn the user that the specialist may surface implementation-level findings the spec will not absorb — such findings get deferred to `plan-implementation` rather than edited into the spec.

**When launching each agent, pass `model: "sonnet"` to the Agent tool. Use domain-scoped briefs — do not hand every agent the full set of artifacts.** Pass each agent only the spec sections relevant to its domain plus pointers, and instruct it to read the rest on demand only if its domain needs it. Default mapping:

| Specialist | Spec sections to include in brief |
|---|---|
| `han.core:user-experience-designer` | Outcome, Primary Flow, User Interactions, Edge Cases (UX-relevant rows only) |
| `han.core:adversarial-security-analyst` | Outcome, Coordinations, Edge Cases, any sections touching auth/PII/secrets |
| `han.core:devops-engineer` | Outcome, Coordinations, Out of Scope, Open Items |
| `han.core:on-call-engineer` | Outcome, Primary Flow, Alternate Flows, Edge Cases, Coordinations (sections touching idempotency, retries, timeouts, kill switches, graceful degradation) |
| `han.core:edge-case-explorer` | Outcome, Primary Flow, Alternate Flows, Edge Cases |
| `han.core:test-engineer` | Outcome, Primary Flow, Alternate Flows, Edge Cases |
| `han.core:gap-analyzer` | Source PRD or reference spec + the draft spec under review |
| `han.core:risk-analyst` | Outcome, Coordinations, Edge Cases (risk-relevant rows only) |
| `han.core:junior-developer` | Outcome + the first paragraph of every section (plain-language overview) |

Always pass the file paths to all artifacts (`{folder}/feature-specification.md`, `{folder}/artifacts/decision-log.md`, `{folder}/artifacts/team-findings.md`, plus `{folder}/artifacts/feature-technical-notes.md` if it exists) so the agent can read further on its own. Always pass the list of decisions already made (D# titles only — not the full entries) and a specific question framed for the agent's domain. Include the directive: **read additional sections only if your domain needs context not in the excerpts above. Cite what you read.**

**Every spec-stage specialist receives this narrowed brief, in addition to the domain-specific question:**

> Review the spec at the behavioral level only. Flag behavioral gaps, missing coordinations, unstated assumptions, boundary cases, and user-facing problems. Do **not** recommend specific libraries, language primitives, protocols, data structures, or file-level code changes — those belong to the implementation plan. If you find a section that leaks implementation mechanics (language primitives, function names, library mechanics, file/line references), raise it as a **"mechanics leaking into spec"** finding regardless of your primary domain.
>
> Apply the YAGNI rule per [../../references/yagni-rule.md](../../references/yagni-rule.md). For every behavior, alternate flow, edge case, coordination, or open item the spec commits to, ask: what evidence supports including it now (user-described need, named direct dependency, existing code path that breaks, applicable regulation, documented incident/metric)? If no accepted evidence applies, raise it as a **`Category: YAGNI candidate`** finding. Apply the named anti-patterns from the rule doc as auto-flags — "for future flexibility", symmetry/completeness, "when we scale", speculative observability, runbooks for never-fired alerts, etc. When evidence does justify an item but a strictly simpler version would satisfy the same evidence, recommend the simpler version.

Tell each agent to cite sections by filename and heading when raising findings — e.g., `feature-specification.md#primary-flow`, `D4` in `artifacts/decision-log.md`, or `T3` in `artifacts/feature-technical-notes.md` — so findings can be cross-referenced precisely. Launch all selected agents in a single message so they run in parallel.

## Step 7: Resolve Findings with Evidence Before Surfacing to User

After all review agents return, compile their findings. **Do not dump raw findings on the user.** For each finding:

1. **Classify the finding as major or minor** before recording. A finding is **major** when it changes a behavioral commitment, edge-case rule, alternate flow, or failure mode in the spec; touches security/auth/PII/secrets/supply-chain; touches a coordination across actors, services, or subsystems; surfaces a load-bearing mechanic (`T#` candidate); or is a "mechanics leaking into spec" finding. A finding is **minor** otherwise — wording, typo, naming, formatting, citation cleanup. If the finding text contains any major-list keyword ("auth", "PII", "race", "ordering", "coordination", "edge case", "T#"), force it to major. When in doubt, major.

2. **Record it in `artifacts/team-findings.md`** using the [team-findings-template.md](./references/team-findings-template.md) format. Major findings go under `## Major findings` with the full structured fields. Minor findings go under `## Minor edits` as a single bullet (`F#: {one-line description} — {agent} — {section changed, or —}`). The F# counter is shared across both classes.
3. **Attempt evidence-based resolution first.** Re-check the codebase, docs, standards, and settled decisions. If the finding is resolvable without the user's judgment, update the affected files and record the resolution in the `F#` entry (`Resolved by: evidence`). Route any implementation mechanic surfaced by a finding through the same classification the interview loop uses (Step 4, "Routing implementation-level details"):
   - **Load-bearing mechanic** → capture as a new `T#` note in `artifacts/feature-technical-notes.md` (creating the file lazily if this is the first qualifying note), link it from the affected spec section, and populate the `T#`'s `Driven by findings:` field.
   - **Discoverable from code repo** → cite evidence on the relevant `D#` entry; do not write a `T#`.
   - **Pure implementation** → do not edit the spec, decision log, or tech-notes; surface as a `plan-implementation`-stage input noted in the F# resolution.
4. **Keep all files in sync (major findings only — minor findings only update `Changed in spec:` if a section actually changed).** For every major F# resolved:
   - Populate `Affected decisions:` on the `F#` entry with the `D#` IDs that were added or changed in `artifacts/decision-log.md`.
   - Populate `Affected tech-notes:` on the `F#` entry with the `T#` IDs that were added or edited in `artifacts/feature-technical-notes.md` (or `—` if none).
   - Populate `Changed in spec:` on the `F#` entry with the `feature-specification.md` sections that were updated.
   - On each affected `D#` entry in `artifacts/decision-log.md`, add this finding's ID to `Driven by findings:` and add any new `T#` IDs to `Linked technical notes:`.
   - On each affected `T#` entry in `artifacts/feature-technical-notes.md`, add this finding's ID to `Driven by findings:` and list affected spec sections under `Referenced in spec:`.
   - If a new decision was introduced, add an inline `([D#](artifacts/decision-log.md#...))` reference in the relevant section of `feature-specification.md` and list that section under the decision's `Referenced in spec:` field. Apply the same pattern for any new `T#` references.
5. **"Mechanics leaking into spec" findings** — findings in this class usually resolve by rewriting the offending spec sentence behaviorally and either extracting the mechanic to a `T#` note (if load-bearing) or removing it entirely (if pure implementation or discoverable from code). Do not escalate these to the user unless the rewrite would change the feature's meaning.

5a. **`YAGNI candidate` findings** — apply the YAGNI rule per [../../references/yagni-rule.md](../../references/yagni-rule.md). For each finding, three resolution paths exist: (a) cite the missing evidence (per the rule's evidence test) and keep the spec item — record the citation in the relevant `D#`'s `Evidence:` field and close the finding; (b) replace with the strictly simpler version that satisfies the same evidence — update the spec sentence and the related `D#`, list the larger version under that `D#`'s `Rejected alternatives:` with the reason "simpler version satisfies the same evidence"; (c) demote to the spec's `## Deferred (YAGNI)` section with the reopening trigger named, removing the inline behavior from the affected sections. Surface YAGNI deferrals to the user in Step 7's escalation pass so the user can override consciously, but do not require user input when evidence resolves the finding directly.
6. **Escalate only what genuinely needs the user.** For findings that remain open, draft a recommended answer with rationale and alternatives, the same way Step 4 surfaces questions. Present them to the user together, organized by the decision they affect — not by which agent raised them.
7. **Capture the user's answers** in the relevant `D#` entry in `artifacts/decision-log.md`, finish populating the `F#` entry (`Resolved by: user input`), update any dependent decisions or tech-notes, and keep all files' cross-refs in sync.

## Step 8: Project Manager Synthesis

Launch the `han.core:project-manager` agent in **synthesis mode** (pass `model: "sonnet"`). Provide it with:

- All output file paths: `{folder}/feature-specification.md`, `{folder}/artifacts/decision-log.md`, `{folder}/artifacts/team-findings.md`, and `{folder}/artifacts/feature-technical-notes.md` if it exists.
- The full verbatim output from every review agent in Step 6.
- The resolutions made in Step 7 (which findings were resolved by evidence, which by the user, and what changed in each file).

Ask the han.core:project-manager to reconcile the specialist input against the files and apply any remaining corrections directly. It must:

- Record or update decisions in `artifacts/decision-log.md` with full rationale, evidence, and rejected alternatives.
- Record or update findings in `artifacts/team-findings.md` with resolutions.
- Record or update technical notes in `artifacts/feature-technical-notes.md` — creating the file lazily if it does not yet exist and at least one `T#` qualifies under synthesis, or leaving it absent if no qualifying mechanic was captured.
- Preserve the cross-reference invariants across all files:
  - Every `D#` in `artifacts/decision-log.md` lists its driving `F#` IDs (`Driven by findings:`), its supporting `T#` IDs (`Linked technical notes:`), dependent decisions, and the spec sections that reference it (`Referenced in spec:`).
  - Every `F#` in `artifacts/team-findings.md` lists its affected `D#` IDs (`Affected decisions:`), affected `T#` IDs (`Affected tech-notes:`), and the spec sections it changed (`Changed in spec:`).
  - Every `T#` in `artifacts/feature-technical-notes.md` lists its supporting `D#` IDs (`Supports decisions:`), driving `F#` IDs (`Driven by findings:`), and the spec sections that reference it (`Referenced in spec:`).
  - Every non-obvious behavior in `feature-specification.md` has its inline `([D#](artifacts/decision-log.md#...))` link. Every sentence whose correct behavior depends on a captured mechanic has its inline `([T#](artifacts/feature-technical-notes.md#...))` link.
  - The spec itself continues to obey the operating-principles rule — no language primitives, file/line references, function/class names, library mechanics, implementation patterns, or internal flag names in behavioral sentences. Any leak the han.core:project-manager finds is rewritten in place during synthesis.

The han.core:project-manager owns the final synthesis — its output is authoritative.

## Step 9: Present the Final Specification

Summarize for the user:
- Output file paths: `{folder}/feature-specification.md`, `{folder}/artifacts/decision-log.md`, `{folder}/artifacts/team-findings.md`. Include `{folder}/artifacts/feature-technical-notes.md` in the list **only if** it was created.
- The number of decisions settled by evidence vs. by user input (point to `artifacts/decision-log.md`).
- The number of YAGNI deferrals captured in `feature-specification.md`'s `## Deferred (YAGNI)` section (omit this line if the section was not written because nothing qualified).
- The number of technical notes captured (point to `artifacts/feature-technical-notes.md`) — omit this line if the file was not created.
- The sub-agents consulted and the key adjustments each drove (point to `artifacts/team-findings.md`).
- Any remaining open items the han.core:project-manager flagged for follow-up (in `feature-specification.md`).

Ask whether the user wants to iterate on specific sections or consider the specification ready for implementation planning.

**Note for existing specs that predate this rule or need cleanup:** this skill authors new specifications from scratch. To clean an existing `feature-specification.md` against the current spec-content rule (for example, to extract implementation mechanics into a new `feature-technical-notes.md`), run `han.core:iterative-plan-review` on the existing spec file. Its spec-aware mode applies the same rule and roster used here.
