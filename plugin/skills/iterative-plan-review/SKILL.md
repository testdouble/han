---
name: "iterative-plan-review"
description: >
  Sharpens and stress-tests an existing plan file through multiple codebase-grounded
  review passes, editing it in place and recording every finding and iteration in
  cross-referenced companion files. Use this skill whenever the user wants to
  iterate on, refine, tighten, or improve a plan — including terse commands like
  "iterate", "refine it", or "iterate for correctness" where a plan is present in
  context. Also use it when the user asks to verify, validate, or confirm
  feasibility of an approach (e.g., "can you verify this will work", "check this
  for correctness", "is this sound") — the defining signal is that the user wants
  critical evaluation of a proposed approach, not execution of it. Produces two
  companion files in an artifacts/ subfolder next to the plan: review-findings.md
  (every finding raised and how it was resolved) and review-iteration-history.md
  (round-by-round record of specialists engaged and plan changes applied). Do NOT use for implementing plan
  steps, generating new plans from scratch, writing test plans, code review, or
  bug investigation.
  Can be paired with plan-work-items downstream to break the plan
  into work items after the plan has been refined.
arguments: size
argument-hint: "[size: small | medium | large] [context or path to plan file]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(find *)
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Review Approach

- Read the full plan before challenging — an assumption that looks wrong in isolation may make sense in context.
- Ground challenges in codebase evidence: "The API handler at `src/api/handler.go:47` returns XML, not JSON" is actionable; "This assumes the API returns JSON" is not.
- Check overlap against existing code, not just the plan — the most valuable overlap findings are external utilities or patterns the codebase already has.
- Ask practical ambiguity questions — "Should this handle concurrent access?" is only useful if there's evidence concurrent access actually happens.
- **YAGNI is a first-class review pillar.** Apply the evidence-based YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md) to every plan item the review touches — every behavior, plan step, abstraction, configuration knob, runbook, observability hook, infrastructure component, test category, ADR clause, or coding-standard line. Items that fail the evidence test or have a strictly simpler version available are first-class findings (`Category: YAGNI candidate`), not polish. Resolution paths: cite missing evidence and keep, replace with simpler version, or move to the plan's `## Deferred (YAGNI)` section with the reopening trigger named. YAGNI candidates are surfaced visibly to the user — never silently dropped, never silently kept. Every plan item is ongoing maintenance and a pattern future agents will copy.
- **The review lives in three cross-referenced files.** The plan file is the primary artifact edited in place and stays at the root of `{plan-dir}/`; `review-findings.md` records every finding and how it was resolved, and `review-iteration-history.md` records each iteration or round — both companion artifacts live in `{plan-dir}/artifacts/` to keep the plan folder uncluttered. The plan gets a standardized `## Review History` section at the bottom pointing to the companion files. Inline `(F#)` markers are NOT added to plan sentences — forward traceability lives in the findings file's `Changed in plan:` field. (Inline `([T#](...))` markers in spec-aware mode remain — they tag load-bearing mechanic-driven spec sentences and are not finding markers.) The findings and iteration files (siblings inside `artifacts/`) cross-link through `Raised in round:` / `Findings raised:` fields and both record `Changed in plan:` sections. Any edit to one file requires updating the matching fields in the others.

# Iterative Plan Review

## Step 1: Locate the Plan and Set Up Companion Files

Find the plan file from the user's argument. If no path was provided, use `Glob` to find `~/.claude/plans/*.md` — Glob returns files sorted by modification time, so the first result is the most recent plan. Read the full plan file and understand its structure, scope, and current state before proceeding.

Resolve project config: read CLAUDE.md's `## Project Discovery` section for language, framework, docs, ADR, and coding-standards directories; fall back to project-discovery.md; fall back to Glob defaults (`docs/`, `docs/adr/`, `docs/coding-standards/`). This context informs assumption evaluation and overlap checks in later steps.

### Spec-aware mode detection

After reading the plan file, determine whether it is a `feature-specification.md` produced by (or compatible with) `han:plan-a-feature`. Engage **spec-aware mode** when either signal holds:

- **Primary signal** — the plan's filename is exactly `feature-specification.md`.
- **Fallback signal** — the file contains the canonical top-level headings of a feature spec: `## Outcome`, `## Actors and Triggers`, `## Primary Flow`, and `## Coordinations` (at least three of these four).

When spec-aware mode engages, state one line to the user:

> **Detected feature specification; applying spec-stage rules to this review. Say "general mode" to override if this file is not a behavioral spec.**

This confirmation lets the user correct a misclassification (e.g., the file was renamed, or is a document that happens to share headings but isn't a spec). If the user overrides, drop spec-aware mode for the rest of the session.

When spec-aware mode is engaged, detect whether `{plan-dir}/artifacts/feature-technical-notes.md` already exists. If it does NOT exist, the file is treated as absent for the duration of this review unless a load-bearing finding causes it to be created lazily. **When the file is absent, omit every T#-related sentence from agent briefs, the spec-maturity tag set, and the round entry's `Changed in tech-notes:` field — do not add boilerplate qualifiers like "if it exists."** When the file is present (or once it has been created lazily), restore the T# instructions for the agents from that point forward.

When spec-aware mode is engaged, the following apply across later steps:

- **Content rule** — the spec must obey `plan-a-feature`'s operating-principles rule: no language primitives, file/line references, function/class names, library mechanics, implementation patterns, or internal flag names in behavioral sentences. Any finding that surfaces a mechanic in the spec is routed per the rule.
- **Mechanic routing** — a finding that requires a mechanic to explain a behavior is classified as:
  - **Load-bearing** (affects observable behavior) → extract the mechanic to a new `T#` entry in `{plan-dir}/artifacts/feature-technical-notes.md` (creating the file lazily if this is the first qualifying note). Restate the spec sentence behaviorally and add an inline `([T#](artifacts/feature-technical-notes.md#...))` link. Record the write in the F# entry's `Changed in tech-notes:` field.
  - **Discoverable from code repo** → restate the spec sentence behaviorally and cite the evidence source on the related `D#` entry in `{plan-dir}/artifacts/decision-log.md` (if the spec has a decision log). Do not write a `T#`.
  - **Pure implementation** → remove from the spec entirely. Record as an F# with `Resolved by: deferred to open item`, noting that the mechanic belongs to `plan-implementation`.
- **`"mechanics leaking into spec"` finding class** — specialists (and self-review) tag any behavioral sentence that leaks implementation mechanics as `Category: mechanics leaking into spec`. Resolution of this class rewrites the offending sentence behaviorally and, when needed, extracts the mechanic per the routing above.

Determine the companion file paths. They live in the `artifacts/` subfolder of the plan's directory (create the subfolder when the first companion file is written):

- `{plan-dir}/artifacts/review-findings.md`
- `{plan-dir}/artifacts/review-iteration-history.md`
- `{plan-dir}/artifacts/feature-technical-notes.md` — **spec-aware mode only, and lazily created.** Written only when the review produces at least one load-bearing `T#`. Follow the cross-reference invariants in [feature-technical-notes-template.md](../plan-a-feature/references/feature-technical-notes-template.md) as applied by `plan-a-feature`.

For legacy reviews produced before the artifacts layout was introduced, the companion files may exist at `{plan-dir}/review-findings.md` and `{plan-dir}/review-iteration-history.md`. When those legacy paths are found, continue appending to them at their existing location rather than migrating — keep the cross-references stable and note the legacy path in the plan's Review History section.

If any companion file already exists (prior review of the same plan), read it and append new `F#` / `R#` / `T#` entries continuing from the highest existing ID — do not overwrite. Numbering must be globally unique across all review sessions of the same plan so cross-references remain stable.

If the companion files do not exist, defer creation until the first iteration or round actually produces content. Do not write empty stub files. When the first companion file is written, create the `artifacts/` subfolder if it does not already exist.

## Step 2: Choose Review Mode and Size

**Default to small.** Start the classification at **small** and only escalate to medium or large when the signals below clearly require it. When a signal is borderline, stay at the smaller band. Use these signals:

- **Small** *(default)* — 2–3 files affected, single system, no cross-cutting concerns. Defaults to **lightweight mode** (no team review). Iteration cap: **1 round.**
- **Medium** — 3–5 files, one or two adjacent systems, may touch a single cross-cutting concern (e.g., one API contract or one new permission check). Defaults to **team mode** with a 3–4 agent team. Round cap: **2.**
- **Large** — more than 5 files, multiple systems, architectural changes, security or data implications, or the user explicitly requests full agent review. Defaults to **team mode** with a 4–5 agent team. Round cap: **3.**

The size determines:

| Size | Mode | Team cap | Round cap |
|---|---|---|---|
| Small | lightweight | n/a (self-review only) | 1 |
| Medium | team | 3–4 | 2 |
| Large | team | 4–5 | 3 |

**Size override.** If `$size` is non-empty (the user passed `small`, `medium`, or `large` as the first argument), use that value as the size and skip the signal-based classification above. State the chosen size and mode to the user in one line with the justification (e.g., "Medium: 4 files, one auth surface" or "Medium: passed via `$size`"). If the user asked for team review on a plan that would otherwise be small, honor the request and treat it as medium-or-larger. If the user explicitly names a size in conversation, accept the override.

In **lightweight mode**, skip Step 3 and run the checklist-based iteration loop in Step 4 alone. In **team mode**, proceed to Step 3 to assemble a team and Step 5 to run team iterations.

## Step 3: Select the Team (team mode only)

**Always include these two** — they are the minimum roster and cannot be omitted:

- `junior-developer` — reframes the plan in plain terms and surfaces hidden assumptions, unstated prerequisites, and standards conflicts a generalist would notice.
- `adversarial-validator` — attacks the plan's evidence, proposed approach, and assumptions with counter-evidence, edge cases, and falsification attempts.

**`evidence-based-investigator` is conditionally mandatory** — include it whenever the plan contains codebase claims to verify, and exclude it otherwise. The plan contains codebase claims if any of the following is true:

- the plan body contains a file path matching common source extensions (e.g., `.ts`, `.tsx`, `.js`, `.jsx`, `.svelte`, `.go`, `.rb`, `.py`, `.rs`, `.java`, `.kt`, `.swift`, `.cs`, `.php`);
- the plan references `src/`, `app/`, `lib/`, `internal/`, `pkg/`, or another source directory by path;
- the plan contains a line-number reference like `:NNN` or `lines NN–NN`;
- the plan names a function, class, or method in backticks alongside a file path or directory.

Run a quick `grep` over the plan to detect these signals before finalizing the team. If any single match is found, include `evidence-based-investigator`. When in doubt, include it.

When `evidence-based-investigator` is not included, state to the user in one line: "evidence-based-investigator is not required because the plan has no codebase claims to verify." If the user explicitly names the agent, honor the request regardless of the heuristic.

**Select additional specialists up to the size cap from Step 2** (medium: 3–4 total team, large: 4–5 total team) based on what the plan actually touches. Fewer is better — only add an agent if their absence would meaningfully weaken the review. Draw from:

- `user-experience-designer` — user-facing flows, UI, interaction models, accessibility.
- `adversarial-security-analyst` — authentication, authorization, PII, untrusted input, secrets, supply chain.
- `devops-engineer` — deployment, observability, rollout, feature flags, scale, SLO impact, cost.
- `structural-analyst` — module boundaries, coupling, dependency direction, duplication.
- `behavioral-analyst` — runtime behavior, data flow, error propagation, state transitions.
- `concurrency-analyst` — concurrent access, race conditions, async coordination, ordering.
- `software-architect` — intra-codebase architectural fit, module/class/interface sketches, SOLID-grounded refactoring paths.
- `system-architect` — cross-service / bounded-context topology, context-map relationships, integration patterns, data ownership, failure-domain containment.
- `risk-analyst` — prioritization of architectural and delivery risks.
- `test-engineer` — observable-behavior test planning, test doubles.
- `edge-case-explorer` — boundary values, input messiness, state-dependent failures.
- `data-engineer` — schema changes, migrations, data movement, analytics implications.
- `gap-analyzer` — spec-vs-implementation gap checks when a source spec exists.
- `content-auditor` — documentation-preservation review when docs are being updated.
- `codebase-explorer` — feature discovery when the plan touches unfamiliar code regions.

**Selection rules**:

- Honor any agents the user named explicitly.
- Justify each additional specialist in one line — what in the plan requires them.
- `risk-analyst`, `software-architect`, and `system-architect` consume upstream findings; only include them when at least one of `structural-analyst`, `behavioral-analyst`, or `concurrency-analyst` is also on the team.
- If `user-experience-designer`, `adversarial-security-analyst`, or `data-engineer` is relevant, include them over nice-to-haves — the risks they surface rarely surface elsewhere.

**Spec-aware mode roster rules** (apply only when spec-aware mode was engaged in Step 1):

- Do NOT include `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `software-architect`, `system-architect`, or `data-engineer` in the default roster. These specialists are named after mechanic-level analysis that belongs in `plan-implementation`, not in a behavioral spec review.
- If the user explicitly names one of the excluded specialists, honor the request — but issue a one-line warning that the specialist may surface implementation-level findings the spec will not absorb. Such findings get deferred to `plan-implementation` rather than edited into the spec.
- The required agents are `junior-developer` and `adversarial-validator`; `evidence-based-investigator` is conditionally mandatory by the codebase-claims heuristic above. All three are generalist and evidence-oriented and serve the spec-review use case without modification.
- Remaining available specialists in spec mode: `user-experience-designer`, `adversarial-security-analyst`, `devops-engineer`, `edge-case-explorer`, `test-engineer`, `gap-analyzer`, `risk-analyst` (no structural/behavioral/concurrency upstream dependency), `content-auditor`, `codebase-explorer`.

Present the proposed team to the user briefly — the required agents (and whether `evidence-based-investigator` was included or skipped, with the reason) plus the chosen specialists, each with a one-line justification — and proceed. If the user corrects the composition, adjust and continue.

## Step 4: Lightweight Iteration Loop (lightweight mode only)

Each iteration follows the checklist at [iteration-checklist.md](references/iteration-checklist.md). Complete every section of the checklist before moving to the next iteration. If an iteration reveals changes are needed, make them to the plan file using `Edit`.

For each iteration: identify and classify assumptions as primary or secondary, and evaluate them against the codebase by reading code, checking existing patterns, or verifying against project documentation. Assumptions may be about user behavior, system behavior, scope boundaries, or ordering. If an assumption is refuted, the plan must change in this iteration to address it.

Check for internal overlap (redundant steps within the plan) and external overlap (patterns, utilities, or infrastructure that already exist in the codebase — use `Grep` and `Glob` to search). If overlap exceeds 80%, propose consolidation. If overlap is intentional, document why in the plan.

Surface any ambiguity as contextual questions that state the impact, describe the tradeoffs, and allow nuanced follow-up.

**Self-review also runs the YAGNI sweep on every iteration.** Walk every plan item and apply the rule from [../../references/yagni-rule.md](../../references/yagni-rule.md): does the item cite accepted evidence (user-described need, named direct dependency, existing code path that breaks, applicable regulation, documented incident/metric)? When evidence applies, is there a strictly simpler version that satisfies the same evidence? Items that fail are raised as `Category: YAGNI candidate` findings with one of three resolution paths: cite missing evidence and keep, replace with simpler version (update the plan in-place and record the rationale), or move to the plan's `## Deferred (YAGNI)` section with the reopening trigger named. Apply the named anti-patterns as auto-flags — runbooks for never-fired alerts, observability for non-flowing telemetry, single-implementation interfaces, configuration knobs no caller sets, "for future flexibility", symmetry/completeness, etc.

**When spec-aware mode is engaged**, self-review also scans the plan for behavioral sentences that leak implementation mechanics. For each such sentence, raise a `Category: mechanics leaking into spec` finding and route the mechanic per the spec-aware rules in Step 1 (load-bearing → new `T#`; discoverable from code → cite evidence; pure implementation → defer to `plan-implementation`). The lightweight loop handles the extraction in-line — self-review is not a specialist, and there is no mandatory agent consultation for these findings.

**Record the iteration's findings and round entry before closing the iteration:**

1. **Classify each finding as major or minor before recording.** Major: changes a behavioral commitment, edge-case rule, alternate flow, or failure mode in the plan; touches security/auth/PII/secrets/supply-chain; touches a coordination across actors, services, or subsystems; is a `T#-contradiction`; or is a "mechanics leaking into spec" finding. Minor: typo, wording, naming, formatting, citation cleanup. Force-up to major if the finding text contains keywords like "auth", "PII", "race", "ordering", "coordination", "edge case", "T#". When in doubt, major.

   For each refuted assumption, overlap finding, ambiguity, or edge case that required attention, append an `F#` entry to `{plan-dir}/artifacts/review-findings.md` using the [review-findings-template.md](references/review-findings-template.md) format (create the `artifacts/` subfolder if it does not already exist; if a legacy `{plan-dir}/review-findings.md` from a prior session is in use, append there instead). Major findings go under `## Major findings` with the full structured fields (Agent: `self-review`, Category, Finding, Evidence considered, Resolution, Resolved by, Raised in round, Changed in plan, Changed in tech-notes). Minor findings go under `## Minor edits` as a single bullet (`F#: {one-line description} — self-review — {section changed, or —}`). The F# counter is shared across both classes.
2. Append an `R#` entry to `{plan-dir}/artifacts/review-iteration-history.md` using the [review-iteration-history-template.md](references/review-iteration-history-template.md) format (or the legacy `{plan-dir}/review-iteration-history.md` if the prior session used that path). Set `Mode:` to `lightweight`, `Specialists engaged:` to `self-review`, list the `F#` IDs produced this iteration under `Findings raised:`, fill `Changed in plan:` with the plan sections edited, and record the stability assessment and next-step recommendation.

**Deterministic stop rule:** stop iterating when the most recent iteration produced ≤ 2 new findings AND zero major findings (security, T#-contradiction, missing coordination, unhandled failure mode in a primary flow path). The size cap from Step 2 sets the upper bound: small = 1 iteration, medium = 2, large = 3. Never exceed the size cap.

Skip to Step 6.

## Step 5: Team Iteration Rounds (team mode only)

Run 2 to 4 rounds. Each round:

1. **Parallel team review with domain-scoped briefs.** Launch every team agent in a single message so they run concurrently. Use domain-scoped briefs — do not hand every agent the full plan and every companion file. Pass each agent only the plan sections relevant to its domain plus pointers, and instruct it to read further on demand only if its domain needs it. Default mapping:

   | Specialist | Plan sections to include in brief |
   |---|---|
   | `user-experience-designer` | Sections touching user-facing flow, UI, interaction, accessibility |
   | `adversarial-security-analyst` | Sections touching auth, authorization, PII, secrets, supply chain |
   | `devops-engineer` | Sections touching deployment, observability, rollout, feature flags, scale, SLO impact, cost |
   | `structural-analyst` | Sections naming module boundaries, coupling, dependency direction |
   | `behavioral-analyst` | Sections describing runtime behavior, data flow, error propagation, state |
   | `concurrency-analyst` | Sections touching concurrent access, race conditions, async coordination |
   | `software-architect` / `system-architect` | Architecture / topology / context-map sections |
   | `risk-analyst` | Architectural and delivery risks; depends on upstream specialist findings |
   | `test-engineer` / `edge-case-explorer` | Sections describing observable behavior, boundary cases, failure modes |
   | `data-engineer` | Sections touching schema, migration, data movement, analytics |
   | `gap-analyzer` | Source PRD/spec + the plan under review |
   | `content-auditor` | Documentation sections being updated |
   | `codebase-explorer` | Sections touching unfamiliar code regions |
   | `junior-developer` / `evidence-based-investigator` / `adversarial-validator` | Full plan (these agents are generalist by design) |

   Give each agent:
   - The full plan file path (so it can read further) plus the relevant section excerpts inline in the brief. Also pass the paths to `artifacts/review-findings.md` and `artifacts/review-iteration-history.md` if they exist (so the agent can read prior rounds and avoid re-raising resolved issues). In spec-aware mode, also pass `artifacts/feature-technical-notes.md` if it exists. For legacy reviews the companion files may sit at the plan folder's root — pass whichever paths actually exist.
   - The project context from Step 1 (CLAUDE.md, project-discovery, coding standards, ADRs that were located).
   - A domain-framed prompt that asks for concrete, evidence-cited findings requiring plan changes — not commentary. Frame the question around the agent's role (e.g., for `structural-analyst`: "where does this plan's proposed module layout conflict with existing boundaries, and what evidence in the codebase supports your critique?"). Include the directive: **read additional sections of the plan only if your domain needs context not in the excerpts above. Cite what you read.**
   - A directive to cite sections by plan heading when raising findings so the skill can record `Changed in plan:` precisely.
   - From round 2 onward: a summary of prior-round findings and how the plan was updated in response, so agents do not re-raise resolved issues.
   - **Every agent also receives the YAGNI brief**: Apply the YAGNI rule per [../../references/yagni-rule.md](../../references/yagni-rule.md). For every plan item in your domain, ask: what evidence supports including it now (user-described need, named direct dependency, existing code path that breaks, applicable regulation, documented incident/metric)? When no accepted evidence applies, raise a `Category: YAGNI candidate` finding. When evidence applies but a strictly simpler version satisfies the same evidence, recommend the simpler version. Apply the named anti-patterns as auto-flags. YAGNI findings are first-class — surface them with a recommended resolution (cite evidence and keep, replace with simpler version, or defer with reopening trigger), never silently drop them.
   - **In spec-aware mode, every agent also receives this narrowed brief**:

     > Review the spec at the behavioral level only. Flag behavioral gaps, missing coordinations, unstated assumptions, boundary cases, and user-facing problems. Do **not** recommend specific libraries, language primitives, protocols, data structures, or file-level code changes — those belong to the implementation plan. If you find a section that leaks implementation mechanics (language primitives, function names, library mechanics, file/line references), raise it as a `Category: mechanics leaking into spec` finding regardless of your primary domain. Treat any `T#` entries in `feature-technical-notes.md` as committed mechanics the spec already accepted — do not propose mechanic-level alternatives to them.

2. **Consolidate findings.** Collect verbatim output from every agent. Group findings into: assumptions refuted (with counter-evidence), overlap with existing code or utilities, ambiguities needing resolution, and unhandled edge cases or failure modes.

3. **Classify and record findings.** For each finding from a specialist, classify it as major or minor before recording. Major: changes a behavioral commitment, edge-case rule, alternate flow, or failure mode in the plan; touches security/auth/PII/secrets/supply-chain; touches a coordination across actors, services, or subsystems; is a `T#-contradiction`; or is a "mechanics leaking into spec" finding. Minor: typo, wording, naming, formatting, citation cleanup. Force-up to major if the finding text contains keywords like "auth", "PII", "race", "ordering", "coordination", "edge case", "T#". When in doubt, major.

   Append the entry to `{plan-dir}/artifacts/review-findings.md` (create the `artifacts/` subfolder if it does not already exist; append to the legacy root-level path if the prior session used it). Major findings go under `## Major findings` with full structured fields (Agent: the specialist's name, Category, Finding, Evidence considered, Raised in round). Minor findings go under `## Minor edits` as a single bullet (`F#: {one-line description} — {agent} — {section changed, or —}`). For major findings, leave `Resolution:`, `Resolved by:`, and `Changed in plan:` blank until the next sub-step. The F# counter is shared across both classes.

4. **Update the plan.** Apply changes to the plan file using `Edit`. For each change:
   - Back-fill the triggering `F#` entry's `Resolution:`, `Resolved by:`, and `Changed in plan:` fields.
   - Resolve conflicts between agents by preferring the finding with stronger codebase evidence; surface genuine disagreements to the user rather than picking silently.
   - **In spec-aware mode**, route mechanic-related resolutions per the rules in Step 1: load-bearing mechanics become new `T#` entries in `artifacts/feature-technical-notes.md` (creating the file lazily on the first qualifying note); the triggering `F#` entry's `Changed in tech-notes:` field records the `T#` IDs added. Add the inline `([T#](artifacts/feature-technical-notes.md#...))` reference to the spec sentence whose behavior the mechanic supports, and populate the new `T#`'s `Referenced in spec:` and `Driven by findings:` fields.

5. **Append a round entry to `{plan-dir}/artifacts/review-iteration-history.md`** (or the legacy `{plan-dir}/review-iteration-history.md` if the prior session used that path). Use the [review-iteration-history-template.md](references/review-iteration-history-template.md) format. Set `Mode:` to `team`, record whether spec-aware mode was engaged under `Spec-aware mode:`, list every specialist that returned output under `Specialists engaged:`, record the `F#` IDs produced under `Findings raised:`, list the plan sections modified under `Changed in plan:`, record any `T#` IDs added or edited under `Changed in tech-notes:` (spec-aware mode only), and capture the next-step recommendation.

6. **Decide whether to continue (deterministic stop rule).** Stop running rounds when the most recent round produced ≤ 2 new findings AND zero major findings (security, T#-contradiction, missing coordination, unhandled failure mode in a primary flow path). The size cap from Step 2 sets the upper bound: medium = 2 rounds, large = 3 rounds. Never exceed the size cap.

Between rounds, surface to the user any finding where two agents disagree on substance, or where resolving the finding requires a judgment only the plan's author can make. Present each as a contextual question with impact, tradeoffs, and a recommended answer. Record the question on the corresponding `F#` entry and, if the user answers before the next round, update `Resolution:` / `Resolved by:` and the relevant plan section.

## Step 6: Update the Plan's Review History Section

Add or update a `## Review History` section at the bottom of the plan file. This section is the only standardized change the skill makes to the plan's own structure. It records where the companion files live and summarizes the review:

- **Review mode:** lightweight or team.
- **Spec-aware mode:** engaged / not engaged (only include this line when spec-aware mode was engaged).
- **Iterations or rounds completed:** N — see [artifacts/review-iteration-history.md](artifacts/review-iteration-history.md).
- **Team composition** (team mode only): list each specialist with a one-line justification — see [artifacts/review-iteration-history.md](artifacts/review-iteration-history.md) for per-round detail.
- **Findings raised:** N — see [artifacts/review-findings.md](artifacts/review-findings.md). Break down by `Resolved by:` source (evidence / user input / deferred) if helpful.
- **YAGNI candidates:** N — items raised as `Category: YAGNI candidate` per [../../references/yagni-rule.md](../../references/yagni-rule.md). Break down by resolution: kept with cited evidence / replaced with simpler version / deferred to the plan's `## Deferred (YAGNI)` section. Omit the line entirely when zero YAGNI findings were raised.
- **Assumptions challenged across all passes:** one-line summary — full entries in [artifacts/review-findings.md](artifacts/review-findings.md).
- **Consolidations made:** one-line summary — full entries in [artifacts/review-findings.md](artifacts/review-findings.md).
- **Ambiguities resolved, and how:** one-line summary — full entries in [artifacts/review-findings.md](artifacts/review-findings.md).
- **Technical notes added/edited:** N — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md). Include this line **only** when spec-aware mode was engaged and at least one `T#` was written.

Use the legacy root-level paths (`review-findings.md`, `review-iteration-history.md`) if the companion files live at the plan folder's root rather than in `artifacts/`.
- **Open items remaining:** N — list each with whether it blocks implementation, pointing to the corresponding `F#` entry.

If a prior review already populated this section, append new iteration/round counts and findings rather than overwriting.

**Preserve the cross-reference invariants across all files:**

- Every `F#` in `artifacts/review-findings.md` has its `Raised in round:` (`R#` IDs) and `Changed in plan:` (plan section headings) populated. In spec-aware mode, `Changed in tech-notes:` (`T#` IDs) is also populated where applicable.
- Every `R#` in `artifacts/review-iteration-history.md` has its `Findings raised:` (`F#` IDs) and `Changed in plan:` (plan section headings) populated. In spec-aware mode, `Spec-aware mode:` and `Changed in tech-notes:` are also populated.
- In spec-aware mode, every spec sentence whose behavior depends on a newly captured mechanic has its inline `([T#](artifacts/feature-technical-notes.md#...))` marker. Inline `(F#)` markers are intentionally not added to plan sentences — `Changed in plan:` on each F# is the forward link.
- In spec-aware mode, every `T#` in `artifacts/feature-technical-notes.md` has `Supports decisions:`, `Driven by findings:`, and `Referenced in spec:` populated.

## Step 7: User Review

Present the final refined plan to the user. Summarize:

- The plan file path.
- The two companion file paths (`artifacts/review-findings.md`, `artifacts/review-iteration-history.md`) — or their legacy root-level paths for older reviews.
- The review mode, team composition (if applicable), and the number of iterations or rounds.
- The number of findings resolved by evidence vs. user input vs. deferred — point to `artifacts/review-findings.md`.
- Any remaining open items and whether they block implementation — also in `artifacts/review-findings.md`.

Ask whether the user wants further revisions on specific sections or considers the plan ready.
