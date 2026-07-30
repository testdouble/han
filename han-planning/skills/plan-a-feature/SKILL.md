---
name: "plan-a-feature"
description: >
  Builds a feature specification from scratch through a relentless, evidence-based interview that walks the design tree
  decision-by-decision, resolving dependencies as it goes. Use when the user wants to plan, design, scope, specify, or
  flesh out a new feature, capability, or system behavior before implementation. Produces a feature specification
  focused on system behaviors, not implementation detail. Does not refine or stress-test an existing plan — use
  iterative-plan-review. Does not document already-built features — use project-documentation. Does not research
  open-ended options before there is a feature to specify — use research.
arguments: size
argument-hint: "[size: small | medium | large | dynamic] [feature description, optional: output folder path]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(mkdir *), Bash(cp *)
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

When the `.han/config.md` probe returns content, apply it per the config rule in
[../../references/config-rule.md](../../references/config-rule.md). When it returns nothing, no project config is
present and nothing changes.

## Operating Principles

- **Interview relentlessly, but explore first.** If a question can be answered by reading the codebase, project docs,
  coding standards, ADRs, or existing feature specs — or by querying a read-only tool already available to this session
  that authoritatively answers it (for example a connected schema or data-source tool) — explore instead of asking. Only
  surface questions that genuinely require the user's judgment. The connected-tool path is gated on availability, not on
  a fresh judgment: use it only when such a read-only tool is actually permitted to this skill; if none is available,
  ask the user as today (see Step 4).
- **Walk the design tree.** Decisions have dependencies. Resolve foundational decisions first (what the feature does,
  who uses it, what outcome it produces). Then descend into dependent decisions (flow, states, edge cases, coordination
  points). Never ask a dependent question before its parent is settled.
- **Recommend, then ask.** For every question surfaced to the user, provide a recommended answer with rationale grounded
  in evidence (code, docs, conventions, or stated goals). The user can accept, redirect, or provide a nuanced response.
- **Behavior, not implementation, in the spec.** The specification captures WHAT the feature does, for WHOM, and WHY —
  at a level a reader who has never opened the codebase can understand. Language primitives, file/line references,
  function or class names, library mechanics, implementation patterns, and internal env/flag names DO NOT appear in
  `feature-specification.md`. Product-level subsystem names ("events processing system", "backend service"), user-facing
  UI vocabulary (popover, modal, toast), URL paths, behavioral verbs, and user-observable states DO. Technology brand
  names generalize one level up (NATS → "events processing system"; PostgreSQL → "database"; Redis → "cache"). This rule
  is language-agnostic — it applies equally to Go, Rails, Node, Python, Swift, Kotlin, and frontend JavaScript code. Any
  examples given in references or templates are illustrative, not an exhaustive deny-list.
- **Load-bearing mechanics go in `feature-technical-notes.md`, not the spec.** When a mechanic is load-bearing for a
  behavior — meaning the behavioral commitment in the spec is only correct because of that mechanic (ordering,
  durability, consistency, visibility timing) — the behavioral consequence goes in the spec sentence, and the mechanic
  goes in a `T#` note linked inline from that sentence. The tech-notes file is LAZILY created — it exists only when at
  least one load-bearing mechanic qualified. Mechanics that are discoverable from the code repo (an existing pattern, an
  in-use library, a documented convention) do NOT belong in the tech-notes file either — `plan-implementation` will find
  them from the code. Mechanics that do not affect observable behavior are pure implementation and belong in the
  implementation plan, not here.
- **YAGNI is a first-class operating principle.** Apply the evidence-based YAGNI rule defined in
  [../../references/yagni-rule.md](../../references/yagni-rule.md). Every behavior, alternate flow, edge case,
  coordination, open item, or other commitment in `feature-specification.md` must cite at least one piece of evidence
  per the rule's evidence test (user-described need, named direct dependency, existing production code path that breaks,
  applicable regulation, documented incident or measured metric). When evidence justifies the item, apply the
  simpler-version test — replace with the strictly simpler version that satisfies the same evidence. Items that fail the
  evidence test get demoted to a `## Deferred (YAGNI)` section in the spec with the trigger that would justify
  reopening, never silently dropped and never silently kept. Every spec section is ongoing maintenance and a pattern
  future agents will copy.
- **The run stays inside the boundary it descends from.** Before the interview begins, the skill records the work item's
  stated scope and exclusions, per
  [../../references/planning-boundary-rule.md](../../references/planning-boundary-rule.md). Every commitment the spec
  carries is then checked against that boundary, and anything the boundary excludes lands in a visible cut list rather
  than in the spec. See [../../references/scope-justification-rule.md](../../references/scope-justification-rule.md).
- **Visual material the user supplies is kept, and reaches every reviewer.** Persist it beside the spec as it arrives,
  never at document-write time, and pass its paths in every dispatched reviewer's brief. The session context is the only
  copy until it reaches disk, and a compaction inside the run destroys it. The boundary rule owns the convention.
- **Questions to the user arrive one at a time, led by the consequence.** An escalation carries one question, opens with
  what a person who will not read the code would describe, gives named candidate answers, and puts paths and identifiers
  below the question or leaves them out. Per
  [../../references/operator-escalation-rule.md](../../references/operator-escalation-rule.md). The opening confirmation
  turn is the one exception, and the one turn that carries more than one ask.
- **Evidence quality is a companion operating principle.** Apply the evidence rule from
  [../../references/evidence-rule.md](../../references/evidence-rule.md) alongside YAGNI. YAGNI gates inclusion (is
  there any evidence?); the evidence rule characterizes the quality of the evidence each spec commitment rests on. Name
  the trust class of cited sources (codebase, web, provided); mark single-source web claims that drive a commitment;
  label commitments with no evidence at any tier as a distinct deferred state rather than weak evidence. The
  proximity-to-origin principle is a heuristic, not a strict tier list.

# Plan a Feature

## Step 1: Capture the Feature Request and Output Location

Read the user's argument and conversation context to extract the feature being planned. If the request is too thin to
start (e.g., just "plan a feature"), ask the user for a one-to-two-sentence description of what the feature does and
what outcome it produces — nothing else yet.

Resolve the output location:

- If the user specified a folder path, use it.
- Otherwise, propose a folder name of **3 to 5 words** in kebab-case (e.g., `docs/features/user-invite-flow/`,
  `docs/plans/bulk-export-jobs/`). Prefer placing it under an existing documentation root discovered via CLAUDE.md's
  `## Project Discovery` section, `project-discovery.md`, or Glob fallbacks (`docs/features/`, `docs/plans/`, `docs/`).
- Confirm the folder name with the user before creating files. If the folder does not exist, create it.

Up to four files will be written. The primary spec lives at the root of `{folder}/`; the companion artifacts live in
`{folder}/artifacts/` to keep the planning folder uncluttered:

- `{folder}/feature-specification.md` — the primary behavioral spec. Always written.
- `{folder}/artifacts/decision-log.md` — the full decision history with rationale, evidence, and rejected alternatives.
  Always written.
- `{folder}/artifacts/team-findings.md` — review-team findings and how each was resolved. Always written.
- `{folder}/artifacts/feature-technical-notes.md` — load-bearing mechanics that were captured because they were needed
  to correctly specify a behavior. **Lazily created** — written only if at least one `T#` qualifies during the interview
  (Step 4) or finding resolution (Step 7). If no `T#` qualifies, the file is never created and the spec contains no `T#`
  links.
- `{folder}/artifacts/scope-boundary.md` — the boundary record. Always written, by Step 1.5.

One more folder appears when the user supplies visual material:

- `{folder}/ui-designs/` — the visual material itself, one file per item, named for the state it depicts.

Create the `artifacts/` subfolder before writing the companion files if it does not already exist.

The files cross-reference each other. The main spec cites decisions with inline parenthetical links like
`([D4](artifacts/decision-log.md#d4-invite-expiration-window))` and cites technical notes (when the file exists) with
inline parenthetical links like `([T3](artifacts/feature-technical-notes.md#t3-ack-ordering))`. The decision log,
findings log, and tech-notes file (all siblings inside `artifacts/`) cross-link through `Driven by findings:` /
`Linked technical notes:` / `Affected decisions:` / `Affected tech-notes:` / `Supports decisions:` fields, and all
reference back into the spec with `../feature-specification.md` paths.

## Step 1.5: Read and Record the Scope Boundary

Read [../../references/planning-boundary-rule.md](../../references/planning-boundary-rule.md) for the record's name, its
sections, and the accepted visual-material file set. Establish the boundary before you discover anything or ask anything.

**A record already exists** at `{folder}/artifacts/scope-boundary.md`. Read it and use it. Do not re-ask anything it
answers, including the direction-of-travel question: a recorded answer of any kind is never re-asked.

**No record exists.** Identify the work item this feature descends from, which is a ticket, an issue, a pull request, or a
written request the user typed, and read it. Record its stated scope and its stated exclusions word for word. When no work
item exists, record that explicitly along with the statement that the user's request is the only boundary this run has,
because a run with no external boundary is a materially different situation from a run with one.

The read does not traverse outward. A linked item, a sibling, or a closed item is not scope evidence for the item in hand.

Then take one confirmation turn before Step 2 begins. It restates the recorded boundary in the user's own terms, names any
visual material you kept, and asks the direction-of-travel question with its subjects named from the work item you have
already read: are the specific things it named being deprecated, replaced, or migrated away from? This turn is a
confirmation rather than an escalation, and the one turn that carries more than one ask.

There is no tool here that reads a tracker, so what you record is often the user's own words rather than the work item's
verbatim text. That is expected. Record which it was.

When the user hands you a work item that conflicts with the recorded one, surface the conflict in the confirmation turn
and ask which governs. Do not silently overwrite the record and do not silently trust it.

Persist every piece of visual material the user supplies into `{folder}/ui-designs/` as it arrives, named for the state
each one depicts, and note each item into the record's Visual Material Received section as you keep it. Copy destinations
are always the resolved output folder's `ui-designs/`. When the host never made an item reachable as a file, name which
items you could not keep and ask for them through the single stop, while they are still recoverable.

Source the explanation standard by invoking `han-communication:explanation-guidance` before you write the confirmation
turn, and again before any escalation or stop later in the run.

## Step 2: Discover Before Asking

Before asking the user anything beyond the initial framing, explore the codebase and project documentation to gather
context that will answer as many design-tree questions as possible. Use Glob and Grep to find:

- CLAUDE.md, AGENTS.md, and any `project-discovery.md` — tech stack, constraints, conventions.
- ADRs in `docs/adr/` or `docs/architecture/decisions/` — prior architectural decisions the feature must respect.
- Coding standards in `docs/coding-standards/` or `.github/CODING_STANDARDS.md` — rules the feature's design must align
  with.
- Existing feature specifications or PRDs — tone, structure, level of detail the team expects.
- Code adjacent to what the feature touches — current behaviors, patterns, integration points.

If a read-only tool that authoritatively answers a design-tree question is already available to this session (for
example a connected schema or data-source tool), and it is permitted to this skill, you may query it here read-only to
resolve that question the same way the filesystem sources above are used. If no such tool is available, rely on the
filesystem sources and surface the question per Step 4. Never write or change state through such a tool.

Record what was found (file paths) and what was not found. Missing standards are themselves findings that inform the
feature spec.

## Step 3: Build the Design Tree

Enumerate the decisions the feature needs in dependency order. A decision is a **question whose answer shapes
behavior**. Group them into tiers:

1. **Foundational** — What is the feature? Who uses it? What outcome does it produce? What triggers it? What does "done"
   look like?
2. **Behavioral** — What are the primary and alternate flows? What states does the feature move through? What
   coordinations between actors, services, or subsystems are involved?
3. **Boundary** — What edge cases, failure modes, and rollback behaviors must be specified? What is explicitly out of
   scope? What does the system do when inputs are malformed, missing, or adversarial?
4. **Interaction** — If there is a user interface or API surface, what is the interaction model? What affordances,
   feedback, and error states must exist?

Do not pre-populate the tree with implementation detail. Keep each node as a behavioral question with a candidate
answer.

## Step 4: Interview Loop — One Branch at a Time

For each decision in dependency order:

1. **Try to resolve it from evidence.** Re-check the codebase, docs, standards, ADRs, and already-settled decisions. If
   a read-only tool that authoritatively answers the question is available to this session (a connected schema,
   data-source, or similar read-only tool) and permitted to this skill, query it before surfacing the question — the
   same answerable-from-a-source discipline already applied to static sources, extended to connected ones. Gate it on
   availability, not judgment: if such a tool is available, use it; if none is available (including because it is not
   permitted to this skill), ask the user as today. Keep it read-only — no writes, no state changes. If the answer is
   clear from evidence, record it in the spec with the evidence citation and move on — do not ask.
2. **If evidence is insufficient, draft a recommended answer.** Ground the recommendation in whatever evidence is
   available (prior decisions, conventions, stated goals, user's framing). State the recommendation, the rationale, and
   the alternatives considered.
3. **Apply the YAGNI evidence test before surfacing.** A decision that exists only for "completeness", "for future
   flexibility", "we might want to", "best practice", or symmetry with another feature is a YAGNI candidate per
   [../../references/yagni-rule.md](../../references/yagni-rule.md). When no accepted evidence (user-described need,
   named direct dependency, existing code path, applicable regulation, documented incident/metric) supports the
   decision, the recommended answer is "defer this to the spec's `## Deferred (YAGNI)` section with the reopening
   trigger named" — surfaced to the user with rationale like any other recommendation. When evidence does support the
   decision, apply the simpler-version test: is there a strictly simpler behavior that satisfies the same evidence? If
   yes, recommend the simpler behavior.
4. **Surface to the user only if the decision genuinely needs their judgment.** Present the recommendation, rationale,
   and alternatives. Allow the user to accept, amend, or redirect. Capture their answer verbatim in the spec.
5. **Descend.** Once a decision is settled, evaluate whether any dependent decisions are now resolvable from evidence
   (they often are). Repeat.

Keep the interview moving — do not stall on questions the evidence can answer. Do not batch every question upfront; ask
as the tree unfolds, because later answers often resolve earlier uncertainties.

### Routing implementation-level details

When settling a decision surfaces an implementation mechanic (a specific library, language primitive, data shape,
protocol detail, concurrency choice, or file-level pattern), classify the mechanic BEFORE writing the spec sentence and
route it to the correct home:

1. **Does the mechanic change what the user or system observably experiences** — ordering, durability, delivery
   guarantees, consistency, visibility timing, error-visibility? If yes, settle the behavioral consequence in the spec
   and capture the enabling mechanic as a `T#` candidate (see capture discipline below). The spec sentence must state
   the behavioral consequence on its own; the `T#` link only supplies the mechanic. A reader who does not click through
   to the note must still get the behavior right.
2. **Is the mechanic already discoverable in the code repo** — an existing pattern, an in-use library, a documented
   convention? If yes, settle the question behaviorally in the spec, cite the evidence source under the D#'s `Evidence:`
   field, and do NOT create a `T#` note. `plan-implementation` will find the code.
3. **Otherwise the question is pure implementation.** Do not settle it here. Do not put it in the spec, tech-notes, or
   Open Items. `plan-implementation` owns it.

### T-note capture discipline (in-message accumulator)

The `feature-technical-notes.md` file is not written during Step 4 — it is flushed during Step 5 (or first written
during Step 7 if finding resolution produces the first qualifying note). During the interview, track candidates
in-message by stating them plainly as they are identified:

> **T-note candidate captured — T(pending #N): {short title}. Supports D{n}; section {spec section}; mechanic: {one-line
> summary}.**

This makes the accumulator visible in the conversation history and gives the user a chance to redirect ("that's
discoverable from code" / "not load-bearing") before the note is written. If the user redirects, drop the candidate from
further consideration.

Candidates that later become irrelevant (e.g., a review specialist in Step 6 proves the mechanic is discoverable from
code) do not reach disk — Step 5 re-validates every candidate against the routing rules before writing.

## Step 5: Draft the Initial Feature Specification

Before drafting, invoke `han-communication:readability-guidance` to source the shared readability standard into your
context, then apply it as you write the prose sections, holding the named audience: the stakeholder or reviewer who reads
the spec for approval. The frame governs how a fact is said, never whether a required fact appears — keep the behavioral
precision the spec depends on.

Write the files. The primary spec goes at the root of `{folder}/`; the companion artifacts go in `{folder}/artifacts/`
(create that subfolder if it does not already exist):

1. **`{folder}/feature-specification.md`** — use
   [feature-specification-template.md](./references/feature-specification-template.md). This is the primary behavioral
   spec covering:
   - **Outcome** — what successful use of the feature produces, stated in behavioral terms.
   - **Actors and triggers** — who or what invokes the feature, and under what conditions.
   - **Primary flow** — the happy path as a sequence of system behaviors and coordinations.
   - **Alternate flows and states** — branches, retries, escalations, waiting states.
   - **Edge cases and failure modes** — what happens when things go wrong.
   - **User interactions** — if applicable, affordances and feedback the user experiences.
   - **Coordinations** — inbound and outbound interactions with other subsystems.
   - **Out of scope** — what the feature deliberately does not do.
   - **Visual Reference** — when the run received visual material, a table under the exact heading `Visual Reference`
     listing each item and the state it shows, plus an inline embed of each item beside the prose describing that state.
     `plan-work-items` reads this table and those placements as its mapping source, so the heading text and the embed
     paths are a contract rather than a formatting choice. **Omit only when the run received no visual material.**
   - **Cut for Scope** — commitments the recorded boundary excludes, cut by the scope gate. Each entry names what it would
     have done in plain language and the boundary citation that supports the cut. It sits immediately before
     `## Deferred (YAGNI)`, and each of the two opens with one line saying what it is not, because they are the same shape
     and easily conflated. A cut carries no reopening trigger; a deferral does. **Lazily created — omit when nothing was
     cut.**
   - **Deferred (YAGNI)** — items considered but deferred under
     [../../references/yagni-rule.md](../../references/yagni-rule.md). For each: the item, why it was deferred (which
     gate failed — evidence test or simpler-version test), and the reopening trigger that would justify revisiting.
     **Lazily created — write this section only if at least one item was deferred. Omit the section entirely when
     nothing qualifies.**
   - **Open items** — questions flagged for follow-up (populated later by the han-core:project-manager).
   - **Summary** — outcome, actors, decision counts, sub-agents, key adjustments, and (only if tech-notes were captured)
     the `T#` count.

   For every behavior that embodies a non-obvious decision, append an inline parenthetical link to the decision in
   `artifacts/decision-log.md`, e.g. `([D4](artifacts/decision-log.md#d4-invite-expiration-window))`. Link only
   non-obvious behaviors — not every sentence. "Non-obvious" means a reader would reasonably ask "why this and not
   something else?"

   For every spec sentence whose correct behavior relies on a captured `T#` note, append an inline parenthetical link to
   the note, e.g. `([T3](artifacts/feature-technical-notes.md#t3-ack-ordering))`. Link only sentences where the mechanic
   changes observable behavior — never as a gratuitous "see also" link.

   **Apply the spec-content rule from the operating principles to every sentence before writing it.** If a draft
   sentence names a language primitive, file/line, function or class, library mechanic, implementation pattern, or
   internal flag, rewrite it behaviorally before it reaches disk. Route the implementation detail to the appropriate
   home per Step 4's routing rules.

2. **`{folder}/artifacts/decision-log.md`** — use [decision-log-template.md](./references/decision-log-template.md).
   **Do not classify decisions as full or trivial yet.** Write every decision with the full structured fields, under
   `## Full decisions`, and classify the whole set once in Step 8 after the review round returns. Two of the promotion
   signals, a driving finding and a linked technical note, cannot exist at draft time, so classifying now guarantees
   re-classification later. The D# counter is assigned here and stays stable through classification, so every spec inline
   link keeps resolving. The `Driven by findings:` field is `—` in this draft; it is populated in Step 7 when review
   findings reshape decisions.

3. **`{folder}/artifacts/team-findings.md`** — use [team-findings-template.md](./references/team-findings-template.md).
   Write the header block; leave the findings list empty. `F#` entries are added in Step 7 after the review team
   returns.

4. **`{folder}/artifacts/feature-technical-notes.md`** — use
   [feature-technical-notes-template.md](./references/feature-technical-notes-template.md). **This file is LAZILY
   created — write it only if at least one captured `T#` candidate qualifies.**

   Flush the in-message accumulator from Step 4:
   - Review every T-note candidate captured during the interview.
   - Re-validate each against the routing rules: load-bearing (affects observable behavior), not discoverable in the
     code repo.
   - Drop candidates the user redirected or that no longer qualify after later evidence.
   - Assign `T1..Tn` in the order captured (not the order validated).
   - Write one entry per qualifying candidate with `Title`, `Context`, `Technical detail`, `Supports decisions:` (D#
     IDs), `Driven by findings:` (`—` during initial draft), and `Referenced in spec:` (spec section headings).
   - For every D# whose behavior a T# supports, populate the D#'s `Linked technical notes:` field with the T# IDs.
   - Add inline `([T#](artifacts/feature-technical-notes.md#t#-slug))` links to the spec sentences each note supports.

   **If zero candidates qualify, do not create this file.** The artifacts folder does not gain an empty or stub file.
   Every reference to `feature-technical-notes.md` in the other artifacts should be absent in this case.

Technical details (specific files, libraries, data shapes) appear **only** under `Evidence:` in
`artifacts/decision-log.md` or in `Technical detail:` entries in `artifacts/feature-technical-notes.md` — never as
behavioral statements in `feature-specification.md`.

## Step 5.5: Classify Feature Size

Before dispatching the review team, classify the feature. **Default to small.** Start the classification at **small**
and only escalate to medium or large when the signals below clearly require it. When a signal is borderline, stay at the
smaller band. Use the signals already in the draft spec:

- **Small** _(default)_ — single subsystem, no cross-service integration, no auth/PII surface, no data migration,
  behavioral surface fits in one tab/page or one API call.
- **Medium** — two to three subsystems, optional integration, may touch UX or rollout, may have a small auth surface.
- **Large** — cross-service, security-sensitive, data ownership shifts, multiple new coordinations, or the user
  explicitly requests full team review.

This size drives the team-size cap in Step 6:

| Size   | Team cap                                            | Rationale                                                      |
| ------ | --------------------------------------------------- | -------------------------------------------------------------- |
| Small  | 2 (han-core:junior-developer + 1 chosen specialist) | Limited surface area; one domain specialist is usually enough. |
| Medium | 3 to 4                                              | Typical default; the historical cap.                           |
| Large  | 4 to 5                                              | Reserved for plans where missed coverage is expensive.         |

**Size override.** If `$size` is non-empty (the user passed `small`, `medium`, `large`, or `dynamic` as the first
argument), use it: a band value is the size and skips the signal-based classification above, while `dynamic` forces the
signal-based classification even when the project config sets a default band. If `$size` is empty and the project
config supplies a band via `default-swarm-size` (per the config rule in
[../../references/config-rule.md](../../references/config-rule.md)), use that band and skip the signal-based
classification. The team cap still scales to the chosen size. State the chosen size, the recommended specialists, and
the reason for the size choice to the user in one short message before launching agents (e.g., "Medium: two subsystems,
small auth surface", "Medium: passed via `$size`", or "Medium: from `.han/config.md` `default-swarm-size`"). If the
user disagrees, accept their override (size, specific specialists, or both) and proceed.

## Step 6: Dispatch the Review Team

Choose sub-agents to review the draft spec in parallel based on the size cap from Step 5.5 and what the feature actually
touches. **Always include `han-core:junior-developer`** to surface hidden inconsistencies, muddied scope, and
assumptions. Select the remaining specialists from this list, matching domain to feature:

- `han-core:user-experience-designer` — any user-facing flow, UI, or interaction model.
- `han-core:adversarial-security-analyst` — authentication, authorization, PII, untrusted input, secrets — at the
  behavioral attack-surface level (deep exploit-path work moves to `plan-implementation`).
- `han-core:devops-engineer` — rollout, feature flags, observability, SLO behavior, operational affordances.
- `han-core:on-call-engineer` — resilience commitments the spec must make to keep the on-call rotation healthy:
  idempotency on retried operations, timeout and deadline behavior, graceful-degradation paths when a dependency is
  down, kill-switch availability on risky new code paths, named failure-mode coverage. Spec-level only — file-and-line
  resilience review belongs to `plan-implementation`.
- `han-core:edge-case-explorer` — boundary values, input messiness, state-dependent failures.
- `han-core:test-engineer` — what observable behaviors the spec commits the system to making testable (test-double and
  collaborator-boundary framing is deferred to `plan-implementation`).
- `han-core:gap-analyzer` — if a PRD or reference spec exists, compare the draft against it.
- `han-core:risk-analyst` — prioritization of risks if the feature has significant blast radius.

Extra agents named in the project config's `## Extra Agents` list join this review-team pool and compete under the same
domain-to-feature matching and size cap, per
[../../references/config-rule.md](../../references/config-rule.md): select one only when the feature touches its
stated specialty, count it against the size cap, brief it with the spec sections relevant to its domain, and skip an
entry that does not resolve to a dispatchable agent with a one-line note.

**Mechanic-focused specialists — `han-core:structural-analyst`, `han-core:behavioral-analyst`,
`han-core:concurrency-analyst`, `han-core:software-architect`, and `han-core:system-architect` — are intentionally
excluded from the default spec-stage roster.** The analysts target module boundaries, runtime data flow, and concurrency
primitives; the architects synthesize those findings into intra-codebase or cross-service topology recommendations. All
of it is `plan-implementation`'s domain under the rule in the operating principles. Include one only if the user
explicitly asks for it, and when doing so warn the user that the specialist may surface implementation-level findings
the spec will not absorb — such findings get deferred to `plan-implementation` rather than edited into the spec.

**Use domain-scoped briefs — do not hand every agent the full set of artifacts.** Pass each agent only the spec sections
relevant to its domain plus pointers, and instruct it to read the rest on demand only if its domain needs it. Default
mapping:

| Specialist                              | Spec sections to include in brief                                                                                                                         |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `han-core:user-experience-designer`     | Outcome, Primary Flow, User Interactions, Edge Cases (UX-relevant rows only)                                                                              |
| `han-core:adversarial-security-analyst` | Outcome, Coordinations, Edge Cases, any sections touching auth/PII/secrets                                                                                |
| `han-core:devops-engineer`              | Outcome, Coordinations, Out of Scope, Open Items                                                                                                          |
| `han-core:on-call-engineer`             | Outcome, Primary Flow, Alternate Flows, Edge Cases, Coordinations (sections touching idempotency, retries, timeouts, kill switches, graceful degradation) |
| `han-core:edge-case-explorer`           | Outcome, Primary Flow, Alternate Flows, Edge Cases                                                                                                        |
| `han-core:test-engineer`                | Outcome, Primary Flow, Alternate Flows, Edge Cases                                                                                                        |
| `han-core:gap-analyzer`                 | Source PRD or reference spec + the draft spec under review                                                                                                |
| `han-core:risk-analyst`                 | Outcome, Coordinations, Edge Cases (risk-relevant rows only)                                                                                              |
| `han-core:junior-developer`             | Outcome + the first paragraph of every section (plain-language overview)                                                                                  |

Always pass the file paths to all artifacts (`{folder}/feature-specification.md`, `{folder}/artifacts/decision-log.md`,
`{folder}/artifacts/team-findings.md`, `{folder}/artifacts/scope-boundary.md`, plus
`{folder}/artifacts/feature-technical-notes.md` if it exists) so the agent
can read further on its own. Always pass the list of decisions already made (D# titles only — not the full entries) and
a specific question framed for the agent's domain. Include the directive: **read additional sections only if your domain
needs context not in the excerpts above. Cite what you read.**

**Pass the visual material to every reviewer, not only the design specialist.** Alongside the artifact paths, give every
dispatched agent the path to each item in `{folder}/ui-designs/` and the state each one shows, and tell it to read them.
Which reviewer is most harmed by the omission varies by feature, so the material goes to all of them rather than to the
one that seems most likely to need it. A design specialist reviewing a design-driven feature without the designs is
reviewing a paraphrase.

**When visual material arrives after dispatch**, persist it, re-brief the reviewers you can still reach, and record which
reviewers never received it. Any finding of theirs that turns on that material is unverified in Step 7.

**Every spec-stage specialist receives this narrowed brief, in addition to the domain-specific question:**

> Review the spec at the behavioral level only. Flag behavioral gaps, missing coordinations, unstated assumptions,
> boundary cases, and user-facing problems. Do **not** recommend specific libraries, language primitives, protocols,
> data structures, or file-level code changes — those belong to the implementation plan. If you find a section that
> leaks implementation mechanics (language primitives, function names, library mechanics, file/line references), raise
> it as a **"mechanics leaking into spec"** finding regardless of your primary domain.
>
> Apply the YAGNI rule per [../../references/yagni-rule.md](../../references/yagni-rule.md). For every behavior,
> alternate flow, edge case, coordination, or open item the spec commits to, ask: what evidence supports including it
> now (user-described need, named direct dependency, existing code path that breaks, applicable regulation, documented
> incident/metric)? If no accepted evidence applies, raise it as a **`Category: YAGNI candidate`** finding. Apply the
> named anti-patterns from the rule doc as auto-flags — "for future flexibility", symmetry/completeness, "when we
> scale", speculative observability, runbooks for never-fired alerts, etc. When evidence does justify an item but a
> strictly simpler version would satisfy the same evidence, recommend the simpler version.
>
> Scope your report to the size of the work being specified. This feature descends from the work item recorded in
> `artifacts/scope-boundary.md`; read it. A report closer to {target} lines than {ten times target} is the right shape
> here. That is a target rather than a cap: if you have more worth saying, say it, but do not pad to fill a section list.
>
> Where a finding of yours rests on an input you could not inspect, say so on the finding itself, in the form your own
> definition specifies. A disclosure in an assumptions section below the finding does not travel with it, and this skill
> reads each finding where it stands.

Fill in `{target}` with a rough line count matched to the work item's size rather than a size word the reviewer has to
interpret. For a one-card ticket, name a report closer to 150 lines than 750. The signal governs how much each reviewer
writes and never how many reviewers you choose; the team cap in Step 5.5 owns that and is unaffected.

Tell each agent to cite sections by filename and heading when raising findings — e.g.,
`feature-specification.md#primary-flow`, `D4` in `artifacts/decision-log.md`, or `T3` in
`artifacts/feature-technical-notes.md` — so findings can be cross-referenced precisely. Launch all selected agents in a
single message so they run in parallel.

## Step 7: Resolve Findings with Evidence Before Surfacing to User

After all review agents return, compile their findings. **Do not dump raw findings on the user.**

Three passes run before the per-finding work below, in this order. The order matters: merging first is what stops one
finding from ending up unverified under one reviewer's identifier and blocking under another's.

**Pass A: merge by substance.** Two reviewers often raise the same finding in different words. Merge those into one
record, and carry every originating reviewer's own identifier on it (for example `UX-3, JD-7`). Do not reconcile the
lists by hand later; that is what loses a finding.

**Pass B: strip blocking severity from findings resting on an uninspected input.** A reviewer that could not inspect
something says so on the finding itself, in the form its definition specifies (look for the `Unverified:` line). Every
finding carrying such a disclosure, and every finding depending on that same input, is labeled unverified and **cannot
carry build-blocking severity**. Keep the finding: it may still be real, and you can often verify it yourself. What it
cannot do is reach the user looking like a blocker on the strength of something nobody read. Findings from a reviewer that
never received visual material, per Step 6, are treated the same way when they turn on that material.

**Pass C: check design-dependent findings against the designs.** For any finding that turns on visual material this run
holds, open the material and check the finding against it before filing. A finding the material answers directly is closed
with the citation rather than promoted to an open item. This is nearly free once the files are on disk, and it is the pass
that catches the reported failure where all five frames answered the flagged question and nobody re-read them.

Record any evidence class no reviewer could audit. When decisions rest on material no reviewer received, say so in
`artifacts/team-findings.md`, so the coverage gap is visible rather than silent.

Then, for each finding:

1. **Classify the finding as major or minor** before recording. A finding is **major** when it changes a behavioral
   commitment, edge-case rule, alternate flow, or failure mode in the spec; touches
   security/auth/PII/secrets/supply-chain; touches a coordination across actors, services, or subsystems; surfaces a
   load-bearing mechanic (`T#` candidate); or is a "mechanics leaking into spec" finding. A finding is **minor**
   otherwise — wording, typo, naming, formatting, citation cleanup. If the finding text contains any major-list keyword
   ("auth", "PII", "race", "ordering", "coordination", "edge case", "T#"), force it to major. When in doubt, major.

2. **Record it in `artifacts/team-findings.md`** using the
   [team-findings-template.md](./references/team-findings-template.md) format. Carry every originating reviewer's own
   identifier on the record, and carry the unverified label from Pass B where it applies. Major findings go under
   `## Major findings` with the full structured fields. Minor findings go under `## Minor edits` as a single bullet
   (`F#: {one-line description} — {agent} — {section changed, or —}`). The F# counter is shared across both classes.
3. **Attempt evidence-based resolution first.** Re-check the codebase, docs, standards, and settled decisions. If the
   finding is resolvable without the user's judgment, update the affected files and record the resolution in the `F#`
   entry (`Resolved by: evidence`). Route any implementation mechanic surfaced by a finding through the same
   classification the interview loop uses (Step 4, "Routing implementation-level details"):
   - **Load-bearing mechanic** → capture as a new `T#` note in `artifacts/feature-technical-notes.md` (creating the file
     lazily if this is the first qualifying note), link it from the affected spec section, and populate the `T#`'s
     `Driven by findings:` field.
   - **Discoverable from code repo** → cite evidence on the relevant `D#` entry; do not write a `T#`.
   - **Pure implementation** → do not edit the spec, decision log, or tech-notes; surface as a
     `plan-implementation`-stage input noted in the F# resolution.
4. **Keep all files in sync (major findings only — minor findings only update `Changed in spec:` if a section actually
   changed).** For every major F# resolved:
   - Populate `Affected decisions:` on the `F#` entry with the `D#` IDs that were added or changed in
     `artifacts/decision-log.md`.
   - Populate `Affected tech-notes:` on the `F#` entry with the `T#` IDs that were added or edited in
     `artifacts/feature-technical-notes.md` (or `—` if none).
   - Populate `Changed in spec:` on the `F#` entry with the `feature-specification.md` sections that were updated.
   - On each affected `D#` entry in `artifacts/decision-log.md`, add this finding's ID to `Driven by findings:` and add
     any new `T#` IDs to `Linked technical notes:`.
   - On each affected `T#` entry in `artifacts/feature-technical-notes.md`, add this finding's ID to
     `Driven by findings:` and list affected spec sections under `Referenced in spec:`.
   - If a new decision was introduced, add an inline `([D#](artifacts/decision-log.md#...))` reference in the relevant
     section of `feature-specification.md` and list that section under the decision's `Referenced in spec:` field. Apply
     the same pattern for any new `T#` references.
5. **"Mechanics leaking into spec" findings** — findings in this class usually resolve by rewriting the offending spec
   sentence behaviorally and either extracting the mechanic to a `T#` note (if load-bearing) or removing it entirely (if
   pure implementation or discoverable from code). Do not escalate these to the user unless the rewrite would change the
   feature's meaning.

5a. **`YAGNI candidate` findings** — apply the YAGNI rule per
[../../references/yagni-rule.md](../../references/yagni-rule.md). For each finding, three resolution paths exist: (a)
cite the missing evidence (per the rule's evidence test) and keep the spec item — record the citation in the relevant
`D#`'s `Evidence:` field and close the finding; (b) replace with the strictly simpler version that satisfies the same
evidence — update the spec sentence and the related `D#`, list the larger version under that `D#`'s
`Rejected alternatives:` with the reason "simpler version satisfies the same evidence"; (c) demote to the spec's
`## Deferred (YAGNI)` section with the reopening trigger named, removing the inline behavior from the affected sections.
Surface YAGNI deferrals to the user in the escalation pass so the user can override consciously, but do not require
user input when evidence resolves the finding directly.

5b. **The scope gate runs in this same pass.** Per
[../../references/scope-justification-rule.md](../../references/scope-justification-rule.md), check the spec's own
commitments against the recorded boundary in `artifacts/scope-boundary.md`. This gate attaches here, to the YAGNI
reasoning path 5a already performs; no sweep step is added to this skill. Because this skill drafts from an interview
rather than from an upstream artifact, the gate reduces to a work-item check on the commitments this run authored, and
there are no inherited commitments to sweep.

Ask of each commitment: does the recorded boundary ask for this, or exclude it by statement or by silence?

- A commitment the boundary never asks for is cut, with the citation, and lands in the spec's `## Cut for Scope` section.
  It is not a YAGNI deferral and gets no reopening trigger; the boundary already settled it. Route the entry to the cut
  list and nowhere else, so a reader never meets the same item in both sections.
- A recorded deprecation in the boundary record's Direction of Travel section is treated the same way a stated exclusion
  is treated.
- **The floor holds.** Cut subsystems, integrations, and artifacts the boundary never asks for. Never cut behavior
  required to deliver what the boundary does ask for. A short work item does not enumerate its own necessities, and that
  silence is not exclusion. Validation, focus behavior, error copy, tests, and accessibility on a card the ticket did ask
  for are not cuts.
- A scope question the boundary answers is never escalated. Cut it and record why, rather than asking the user to choose
  between options their own work item already decided between.

Cut entries flow into Step 8's synthesis alongside everything else.

6. **Escalate only what genuinely needs the user, one question at a time.** For findings that remain open, draft a
   recommended answer with rationale and alternatives, the same way Step 4 surfaces questions. Then present them per
   [../../references/operator-escalation-rule.md](../../references/operator-escalation-rule.md): one question per turn,
   waiting for the answer before asking the next, leading with the consequence a person who will not read the code would
   describe, carrying named candidate answers, and keeping paths, identifiers, and line numbers below the question or out
   of it. State how many questions are pending on the first one. Present more than one in a turn only when the user asks
   for that.

   Source the explanation standard by invoking `han-communication:explanation-guidance` before writing the first one.

   Grouping findings by the decision they affect stays: it is the order you work through them in, not a licence to put
   four of them in one turn.

   A finding labeled unverified in Pass B never leads an escalation as a blocker. Say what could not be inspected as part
   of the question.

7. **Capture the user's answers** in the relevant `D#` entry in `artifacts/decision-log.md`, finish populating the `F#`
   entry (`Resolved by: user input`), update any dependent decisions or tech-notes, and keep all files' cross-refs in
   sync.

8. **Keep an escalation register.** Record every question you escalated, the answer that came back, and where that answer
   landed in the artifacts. The register goes in `artifacts/team-findings.md` alongside the findings it came from.

## Step 8: Project Manager Synthesis

Launch the `han-core:project-manager` agent in **synthesis mode**. Provide it with:

- All output file paths: `{folder}/feature-specification.md`, `{folder}/artifacts/decision-log.md`,
  `{folder}/artifacts/team-findings.md`, `{folder}/artifacts/scope-boundary.md`, and
  `{folder}/artifacts/feature-technical-notes.md` if it exists.
- The full verbatim output from every review agent in Step 6.
- The resolutions made in Step 7 (which findings were resolved by evidence, which by the user, and what changed in each
  file), including everything the scope gate cut and the reason for each cut.

Ask the han-core:project-manager to reconcile the specialist input against the files and apply any remaining corrections
directly. It must:

- **Classify every decision as full or trivial, once, now.** This is the only classification pass; Step 5 deliberately
  wrote every decision in full form and deferred the split to here, because two of the promotion signals (a driving
  finding, a linked technical note) do not exist until the review round returns. Full: has a rejected alternative a
  reasonable engineer would plausibly have chosen (not an obvious or strawman one), evidence beyond the user's framing,
  driven-by-findings, linked tech-notes, or dependent decisions. Trivial: settled directly by the user's framing or an
  obvious convention with no alternative worth discussing. Full decisions stay under `## Full decisions` with the
  structured fields. Trivial decisions move to `## Trivial decisions` as a one-line bullet, with an optional single-clause
  parenthetical when an obvious alternative was discarded
  (`D#: {title} — {outcome} (considered {alternative}; rejected because {one clause}). — Referenced in spec: {sections}.`);
  see [decision-log-template.md](./references/decision-log-template.md) for the exact format and the "if unsure, treat as
  full" backstop. D# numbers do not change during classification, so every spec inline link keeps resolving.
- Record or update decisions in `artifacts/decision-log.md` with full rationale, evidence, and rejected alternatives.
- Record or update findings in `artifacts/team-findings.md` with resolutions.
- Record or update technical notes in `artifacts/feature-technical-notes.md` — creating the file lazily if it does not
  yet exist and at least one `T#` qualifies under synthesis, or leaving it absent if no qualifying mechanic was
  captured.
- Preserve the cross-reference invariants across all files:
  - Every `D#` in `artifacts/decision-log.md` lists its driving `F#` IDs (`Driven by findings:`), its supporting `T#`
    IDs (`Linked technical notes:`), dependent decisions, and the spec sections that reference it
    (`Referenced in spec:`).
  - Every `F#` in `artifacts/team-findings.md` lists its affected `D#` IDs (`Affected decisions:`), affected `T#` IDs
    (`Affected tech-notes:`), and the spec sections it changed (`Changed in spec:`).
  - Every `T#` in `artifacts/feature-technical-notes.md` lists its supporting `D#` IDs (`Supports decisions:`), driving
    `F#` IDs (`Driven by findings:`), and the spec sections that reference it (`Referenced in spec:`).
  - Every non-obvious behavior in `feature-specification.md` has its inline `([D#](artifacts/decision-log.md#...))`
    link. Every sentence whose correct behavior depends on a captured mechanic has its inline
    `([T#](artifacts/feature-technical-notes.md#...))` link.
  - The spec itself continues to obey the operating-principles rule — no language primitives, file/line references,
    function/class names, library mechanics, implementation patterns, or internal flag names in behavioral sentences.
    Any leak the han-core:project-manager finds is rewritten in place during synthesis.
  - The `## Cut for Scope` section carries every scope-gate cut with what it would have done and the boundary citation,
    and no entry appears in both that section and `## Deferred (YAGNI)`.
  - The `Visual Reference` table lists every item the boundary record records as received, under that exact heading, with
    an inline embed beside the prose describing each state.

The han-core:project-manager owns the final synthesis — its output is authoritative.

## Step 8.5: Readability Pass

Once the han-core:project-manager synthesis in Step 8 is complete and the spec is final, dispatch
`han-communication:readability-editor` (one Agent call) to audit and rewrite the spec's prose against the readability
standard. Pass the editor the file path `{folder}/feature-specification.md` and the named audience: the stakeholder or
reviewer who reads the spec for approval; the editor reads han-communication's own canonical rule, so pass no rule path.
It must preserve every fact and operate on prose regions only — never inside code fences, tables, or the D#/T#/F#
citation identifiers, which must survive unchanged so they still resolve. Apply its rewrite to the spec file.

Then run the standardized readability self-check (the shared standard is in your context from
`han-communication:readability-guidance`) over the spec's prose regions only — never inside code fences, tables, or the
D#/T#/F# citation identifiers. Confirm each criterion and fix any failure before presenting:

1. The opening line states the main point.
2. Each heading names its content and is not a generic label.
3. Each paragraph carries one idea and leads with it.
4. No sentence runs past the soft length flag (about thirty words) without reason.
5. No word from the vocabulary blocklist (the writing-voice profile's "Avoided words and phrases" and "AI slop to avoid"
   lists) is present.
6. Every fact is preserved — every claim, quantity, named entity, and stated condition or qualifier survives with its
   precision intact.

Fidelity wins: the standard governs how the content is said, never whether a required fact appears.

## Step 9: Present the Final Specification

Summarize for the user:

Before you summarize, run the completeness gate: every item the boundary record lists as received exists on disk in
`{folder}/ui-designs/`. Read the record rather than your memory of the run, because a compaction leaves the memory empty
and the gate would pass vacuously. This also catches partial loss, where five items arrived and three were saved.

- Output file paths: `{folder}/feature-specification.md`, `{folder}/artifacts/decision-log.md`,
  `{folder}/artifacts/team-findings.md`, `{folder}/artifacts/scope-boundary.md`. Include
  `{folder}/artifacts/feature-technical-notes.md` in the list **only if** it was created, and `{folder}/ui-designs/` only
  if visual material was kept.
- The number of decisions settled by evidence vs. by user input (point to `artifacts/decision-log.md`).
- **The cut list**, when anything was cut for scope: what each entry would have done, in plain language, and why. Say that
  the user can reinstate any of it, and that their saying so is itself a valid justification the reinstated item records.
  Show this in the message rather than only pointing at the section, because a cut the user never reads is a cut nobody
  can reverse.
- The number of YAGNI deferrals captured in `feature-specification.md`'s `## Deferred (YAGNI)` section (omit this line
  if the section was not written because nothing qualified). Keep it distinct from the cut list above.
- The number of technical notes captured (point to `artifacts/feature-technical-notes.md`) — omit this line if the file
  was not created.
- The sub-agents consulted and the key adjustments each drove (point to `artifacts/team-findings.md`).
- Any finding that stayed unverified because a reviewer could not inspect its input, and any evidence class no reviewer
  could audit. Neither is presented as build-blocking.
- Any remaining open items the han-core:project-manager flagged for follow-up (in `feature-specification.md`).

Ask whether the user wants to iterate on specific sections or consider the specification ready for implementation
planning.

**Note for existing specs that predate this rule or need cleanup:** this skill authors new specifications from scratch.
To clean an existing `feature-specification.md` against the current spec-content rule (for example, to extract
implementation mechanics into a new `feature-technical-notes.md`), run `han-planning:iterative-plan-review` on the
existing spec file. Its spec-aware mode applies the same rule and roster used here.
