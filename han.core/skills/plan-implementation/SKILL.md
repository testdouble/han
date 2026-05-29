---
name: "plan-implementation"
description: >
  Builds a feature implementation plan from an existing feature specification (or
  equivalent context) through a project-manager-led team conversation. Use when the
  user wants to plan how to implement, build, deliver, or ship a feature that has
  already been specified — including requests like "plan the implementation of X",
  "how do we build this", "turn this spec into an implementation plan", or "figure
  out how we'd actually ship this". Launches a team of specialist sub-agents sized
  to the feature, always including `project-manager` as coordinator and
  `junior-developer` as generalist stress-tester, and iterates rounds of discussion
  until the project-manager confirms the plan is ready or only user input remains.
  Produces three cross-referenced files in the same folder as the source feature
  specification: feature-implementation-plan.md (the primary plan), implementation-decision-log.md
  (every committed decision with rationale and evidence), and implementation-iteration-history.md
  (round-by-round record of specialists engaged and how questions were resolved).
  Does not specify what the feature should do — use
  plan-a-feature to produce the behavioral specification first. Does not refine or
  stress-test an already-written plan — use iterative-plan-review. Does not
  investigate bugs or failures — use investigate. Does not perform file-level code
  review — use code-review. Does not record architectural decisions — use architectural-decision-record.
  Typically paired with plan-work-items downstream to break the
  plan into work items after it's complete.
arguments: size
argument-hint: "[size: small | medium | large] [feature specification path, optional: additional context]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(git *)
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Operating Principles

- **The feature specification is the ground truth for *what*.** This skill plans *how*. Do not re-open behavioral decisions the specification already settled; flag contradictions as Open Questions for the user.
- **The project-manager is the coordinator, not the author of every section.** It facilitates rounds of discussion among specialists, tracks claims and evidence, and decides when the plan is ready. Specialists own their domains.
- **Always include `junior-developer` on the team.** When decisions lack strong evidence, the junior-developer reframes the issue in plain terms first — that frequently unlocks a resolution without needing the user.
- **Escalate to the user only when evidence and reframing have both failed.** Every escalation surfaces with a full description, the evidence considered, and a recommended answer.
- **Done is when the project-manager says so.** The loop exits when the project-manager reports the plan is ready to commit, or that only user-input items remain. The user is not asked to keep iterating past that point.
- **YAGNI is a first-class operating principle, applied to *implementation* choices.** The implementation plan inherits the spec's behavioral commitments but applies the evidence-based YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md) independently to abstractions, configuration knobs, observability, runbooks, infrastructure, rollout machinery, test scaffolding, schema columns, indexes, and any other implementation artifact the plan recommends. Items that fail the evidence test get demoted to a `## Deferred (YAGNI)` section in `feature-implementation-plan.md` with the reopening trigger named; items where a strictly simpler implementation satisfies the same evidence get the simpler implementation recorded as the decision and the larger version under `Rejected alternatives:`. The Sentry-runbook-on-staging-only-Sentry pattern is the named project precedent — operational machinery shipped before the system that drives it actually produces the data, traffic, or failures it covers is YAGNI by default. Every committed implementation item is ongoing maintenance and a pattern future agents will copy.
- **All sub-agents in this skill run on sonnet.** When launching any Agent tool call in this skill, pass `model: "sonnet"`. The exception is the project-manager synthesis step in Step 8, which may run on its default model (opus) — pass no model override there.
- **Keep the plan at planning altitude.** Name and reference config and code artifacts; do not inline their full contents. Inline only the specific values that are themselves decisions (a flag default, a key name, a threshold). A full file block — a complete plist, a whole config file, a multi-line XML or JSON document — belongs in the file it configures, not in the plan. YAGNI gates whether an item is *included*; this principle gates how *verbose* an included item is.
- **The plan lives in three cross-referenced files.** `feature-implementation-plan.md` is the primary plan and lives at the root of `{folder}/`; `implementation-decision-log.md` records every decision and `implementation-iteration-history.md` records each round of discussion — both companion artifacts live in `{folder}/artifacts/` to keep the planning folder uncluttered. The main plan cites decisions with inline `([D-N](artifacts/implementation-decision-log.md#...))` links for non-obvious claims. The decision log and iteration history cross-link through `Driven by rounds:` / `Decisions produced:` fields (they sit as siblings inside `artifacts/`), and both link back into the plan through `Referenced in plan:` / `Changed in plan:` fields using `../feature-implementation-plan.md`. Any edit to one file requires updating the matching fields in the others.

# Plan an Implementation

## Step 1: Locate the Feature Specification

Read the user's argument and conversation context to identify the source artifact. The expected input is a `feature-specification.md` produced by the `plan-a-feature` skill, but any document describing what the feature should do is acceptable (PRD, design doc, product brief).

Resolve the source path:
- If the user provided a file path, use it.
- Otherwise, search for a recent `feature-specification.md` under `docs/features/`, `docs/plans/`, or other documentation roots discovered via CLAUDE.md or `project-discovery.md`. If multiple candidates exist, ask the user which one.
- If no feature specification exists, tell the user this skill requires one and recommend running `plan-a-feature` first.

Three files will be written. The primary plan lives at the root of `{same-folder-as-source}/`; the two companion artifacts live in `{same-folder-as-source}/artifacts/` (which may already exist if the source spec came from `plan-a-feature` — share the same subfolder rather than creating a second one):

- `{same-folder-as-source}/feature-implementation-plan.md` — the primary plan.
- `{same-folder-as-source}/artifacts/implementation-decision-log.md` — every committed implementation decision with rationale, evidence, and rejected alternatives.
- `{same-folder-as-source}/artifacts/implementation-iteration-history.md` — round-by-round record of specialists engaged, questions raised, and how each was resolved.

Create the `artifacts/` subfolder before writing the companion files if it does not already exist.

The three files cross-reference each other. The main plan cites decisions with inline parenthetical links like `([D-3](artifacts/implementation-decision-log.md#d-3-rollout-strategy))`; the decision log and iteration history cross-link through `Driven by rounds:` / `Decisions produced:` fields (siblings inside `artifacts/`), and both link back into the plan through `Referenced in plan:` / `Changed in plan:` fields via `../feature-implementation-plan.md`.

If any of the three files already exist, ask the user whether to overwrite or append iteration notes before proceeding.

Read the full specification into context. If the specification is a `feature-specification.md` produced by `plan-a-feature`, also read its companion `decision-log.md`, `team-findings.md`, and `feature-technical-notes.md` **if it exists** — these live in `{same-folder-as-source}/artifacts/` (the same subfolder this skill will write to). Fall back to reading them from `{same-folder-as-source}/` directly for spec folders produced before the artifacts layout was introduced. The `feature-technical-notes.md` file is lazily created by `plan-a-feature` — its absence means no load-bearing mechanics were captured at spec time, not that the spec is incomplete. Note the decisions already settled, any open items the spec flagged, the review team findings, and any committed technical mechanics the plan must honor.

**Detect tech-notes presence once, here.** Record whether `feature-technical-notes.md` exists. If it does NOT exist, omit every T#-related sentence from agent briefs (Step 4), the spec-maturity tag set (Step 5), and the synthesis inputs (Step 8) — do not add boilerplate qualifiers like "if it exists" to those briefs. The `T#-contradiction` spec-maturity classification simply does not apply when there are no T# notes, so the spec-maturity gate reduces to the `spec-level` threshold alone.

## Step 2: Discover Implementation Context

Before launching the team, gather the context specialists will need to produce evidence-backed recommendations. Use Glob and Grep to find:

- **CLAUDE.md, AGENTS.md, and `project-discovery.md`** — tech stack, languages, frameworks, build tools, test runners.
- **ADRs** in `docs/adr/` or `docs/architecture/decisions/` — architectural decisions the implementation must respect.
- **Coding standards** in `docs/coding-standards/` or `.github/CODING_STANDARDS.md` — rules the implementation must follow.
- **Code adjacent to the feature's touch points** — existing modules, patterns, integration surfaces the feature will plug into.
- **Existing implementation plans** in the same documentation root — format precedent and level of detail the team expects.
- **Recent activity** — if git is available, run `git log --since="90 days ago" --name-only --pretty=format:""` on the directories the feature will touch to surface churn and recent precedent.

**Write the result to `{same-folder-as-source}/artifacts/.discovery-notes.md`** as a structured summary: tech stack, ADRs found (paths + one-line summary each), coding standards found (paths + one-line summary each), code touch points (paths + one-line summary), recent-activity churn, and explicitly enumerated gaps (what was searched for and not found). Missing standards or ADRs are themselves findings the team should note.

The discovery notes file is the single source of truth for project context across the team. **Specialists in Step 4 are instructed to read `.discovery-notes.md` first and not to re-grep for what has already been found** — they may search further for what their domain specifically needs that the discovery notes do not cover, but they must not duplicate what is already there.

## Step 3: Select the Team

**Default to small.** Start the classification at **small** and only escalate to medium or large when the signals below clearly require it. When a signal is borderline, stay at the smaller band. Use the spec's coordinations, T# count, security/PII surface, integration boundaries, and the user's framing:

- **Small** *(default)* — single subsystem, no cross-service integration, no auth/PII/secrets, no data migration. Team cap: **3** (project-manager + junior-developer + 1 chosen specialist). Round cap: **1.**
- **Medium** — two to three subsystems, optional integration, may touch UX or rollout, may have a small auth surface. Team cap: **4 to 5** (project-manager + junior-developer + 2–3 chosen specialists). Round cap: **2.**
- **Large** — cross-service, security-sensitive, data ownership shifts, multiple new coordinations, or the user explicitly requests full team. Team cap: **6 to 8** (project-manager + junior-developer + 4–6 chosen specialists). Round cap: **3.**

**Size override.** If `$size` is non-empty (the user passed `small`, `medium`, or `large` as the first argument), use that value as the size and skip the signal-based classification above; the team cap and round cap still scale to the chosen size. State the chosen size, the recommended team, and the reason for the size choice to the user in one short message before launching agents (e.g., "Medium: two subsystems, small auth surface" or "Medium: passed via `$size`"). If the user disagrees, accept the override (size, specific specialists, or both) and proceed.

The team **always includes**:

- `project-manager` — coordinator and final synthesizer.
- `junior-developer` — generalist stress-tester and reframer.

Select additional specialists up to the team cap based on what the feature actually touches. Err toward including a specialist rather than discovering a gap late. Unless the user specified a team composition, draw from:

- `user-experience-designer` — any user-facing flow, UI, or interaction model.
- `adversarial-security-analyst` — authentication, authorization, PII, untrusted input, secrets, supply chain.
- `devops-engineer` — deployment, observability, rollout, feature flags, scale, SLO impact, cost.
- `on-call-engineer` — application-source resilience patterns the plan introduces: timeouts and deadline propagation, retry logic with backoff and jitter, idempotency-key wiring, queue and buffer handling, async / blocking-I/O patterns, bulkhead boundaries, correlation-id propagation, kill-switch wiring, observability-of-the-failure-path at the application source line. Hard boundary against `devops-engineer`: infrastructure, IaC, pipelines, and observability platform configuration stay there.
- `structural-analyst` — module boundaries, coupling, where the implementation fits in the system.
- `behavioral-analyst` — runtime behavior, data flow, error propagation, state transitions.
- `concurrency-analyst` — concurrent access, race conditions, async coordination, ordering.
- `software-architect` — intra-codebase architectural recommendations, module/class/interface sketches, SOLID-grounded refactoring paths. Include when the feature is mostly internal to one codebase or one bounded context.
- `system-architect` — cross-service / bounded-context topology, context-map relationships, integration patterns (sync vs. async, saga, ACL, OHS), data ownership across services, failure-domain containment. Include when the feature crosses a service boundary, introduces a new integration, changes a context-map relationship, or shifts data ownership. Include both when the feature does both.
- `risk-analyst` — prioritization of architectural and delivery risks.
- `test-engineer` — observable-behavior test planning and test doubles.
- `edge-case-explorer` — boundary values, input messiness, state-dependent failures.
- `data-engineer` — schema changes, migrations, data movement, analytics implications.

If the user specified which agents to include, honor that. Otherwise, state the proposed team composition to the user briefly before launching — one line per specialist with the reason they were selected — and proceed.

## Step 4: Round 1 — Parallel Specialist Review

Launch every non-`project-manager` specialist in parallel in a single message. Pass `model: "sonnet"` on each Agent tool call. **Use domain-scoped briefs — do not hand every agent the full set of artifacts.** Pass each agent only the spec sections relevant to its domain plus pointers, and instruct it to read further on demand only if its domain needs it. Default mapping:

| Specialist | Spec sections to include in brief |
|---|---|
| `user-experience-designer` | Outcome, Primary Flow, User Interactions, Edge Cases (UX-relevant rows only) |
| `adversarial-security-analyst` | Outcome, Coordinations, Edge Cases, sections touching auth/PII/secrets/supply-chain |
| `devops-engineer` | Outcome, Coordinations, Out of Scope, Open Items |
| `on-call-engineer` | Sections naming outbound calls, retry behavior, queue or buffer handling, async work, error handling on failure paths, schema migrations, idempotency, kill switches, and observability of new code paths |
| `structural-analyst` | Sections naming module boundaries, coupling, dependency direction |
| `behavioral-analyst` | Sections describing runtime behavior, data flow, error propagation, state |
| `concurrency-analyst` | Sections touching concurrent access, race conditions, async coordination |
| `software-architect` / `system-architect` | Architecture / topology / context-map sections |
| `risk-analyst` | Architectural and delivery risks; depends on upstream specialist findings |
| `test-engineer` / `edge-case-explorer` | Outcome, Primary Flow, Alternate Flows, Edge Cases |
| `data-engineer` | Sections touching schema, migration, data movement, analytics |
| `junior-developer` | Outcome + first paragraph of every section (plain-language overview) |

Give each agent:

- The full feature specification path (so it can read further) plus the relevant section excerpts inline in the brief. Also pass the spec's `artifacts/decision-log.md`, `artifacts/team-findings.md`, and `artifacts/feature-technical-notes.md` paths if they exist (fall back to the spec folder root for legacy layouts) — **as paths only, not contents**, so the agent can read on demand.
- The path to `artifacts/.discovery-notes.md` from Step 2, with a directive: **read the discovery notes first; do not re-grep for what is already there. Search further only for what your domain specifically needs that the discovery notes do not cover.**
- A specific question framed for their domain — not "any concerns?" but "what does implementing this feature look like from your domain's vantage point, and what evidence grounds your recommendation?" Include the directive: **read additional spec sections only if your domain needs context not in the excerpts above. Cite what you read.**
- The evidence-first directive on Open Questions: **before raising an Open Question, re-read the relevant feature-specification section; if the spec already answers it, cite the line and do not raise it.** This keeps spec-answered questions out of the loop instead of costing a Step 6 pass to retire.
- A directive to return concrete, evidence-cited recommendations for the implementation plan — not behavioral rework of the spec.
- A directive to apply the YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md) to every recommendation: each abstraction, interface, configuration knob, runbook, observability hook, dashboard, alert, SLO, feature flag, infrastructure component, schema column, index, partition, audit machinery, retention pipeline, or test category recommended must cite evidence per the rule's evidence test (named upstream finding the change resolves, existing code path that breaks, three current concrete uses, measured incident or workload, applicable regulation). Recommendations failing the evidence test are returned as **`Category: YAGNI candidate`** findings with the reopening trigger named. Recommendations whose upstream concern is satisfied by a strictly simpler implementation should propose the simpler implementation. The agents most prone to over-engineering — `software-architect`, `system-architect`, `devops-engineer`, `data-engineer`, `on-call-engineer` — already encode this rule in their definitions; honor it.
- A directive to treat any `T#` entries in `feature-technical-notes.md` as **committed mechanics the plan must honor** — not open questions to re-debate. If the specialist disagrees with a `T#` note, they must raise it as a **"`T#` contradiction" finding** that cites the specific `T#` ID, describes the behavioral conflict, and names the alternative mechanic they recommend. The plan will route such findings through the facilitation loop (Step 5) and, if necessary, reopen the spec-stage decision — a specialist may not silently override a committed `T#`.
- A directive to cite sections by filename and heading when raising findings — e.g., `feature-specification.md#primary-flow`, or a specific `D#` in the spec's `artifacts/decision-log.md`, or `T3` in the spec's `artifacts/feature-technical-notes.md` — so the project-manager can cross-reference them precisely during synthesis.

Collect every agent's verbatim output. If an agent returns "no concerns from my side," that is a valid answer — record it.

## Step 5: Round 1 — Deterministic Aggregation

`project-manager` is **NOT** called per-round in facilitation mode. The mechanical work of consolidating specialist findings into a claim ledger, classifying spec-maturity, and choosing a next-step recommendation is performed deterministically by this skill itself. PM is reserved for two specific calls only: the final synthesis in Step 8, and a single facilitation pass when the spec-maturity gate trips (see below).

Aggregate the verbatim specialist outputs from Step 4 into the round-1 entry of `artifacts/implementation-iteration-history.md` using these rules:

**Build the claim ledger.** Group findings by category (assumption-refuted, overlap, ambiguity, edge-case, security, mechanic-leak, T#-contradiction, YAGNI-candidate). For each finding, mark its state:

- `Evidenced` — the finding cites a file path with line number, an ADR ID, a coding-standard section, or another concrete artifact that resolves the claim.
- `Anecdotal` — the finding asserts but does not cite an artifact.
- `Disputed` — two or more specialists made conflicting claims on the same point.

When two specialists raise the same claim, consolidate into a single ledger row that names every supporting specialist.

**Tag spec-maturity.** Tag every finding as:

- `plan-level` — resolvable inside `plan-implementation` by evidence, reframing, or user input.
- `spec-level` — requires a behavioral decision the spec never committed to (e.g., "the spec doesn't say what happens when two users invite the same email simultaneously"). Cannot be resolved in the plan stage without fabricating behavior.
- `T#-contradiction` — the specialist recommends a mechanic that conflicts with a committed `T#` note. Load-bearing by construction.

Use simple text rules: a finding that names a spec section and says "the spec is silent" / "not specified" / "undefined behavior" is `spec-level`. A finding that names a `T#` ID and proposes a different mechanic is `T#-contradiction`. Everything else is `plan-level`.

**Compute the spec-maturity gate.** The gate trips when either condition holds:

- **≥ 2 `T#`-contradictions raised by ≥ 2 distinct specialists** (on any combination of `T#` notes — need not be the same one), or
- **≥ 5 `spec-level` findings raised by ≥ 3 distinct specialists**.

A single `T#`-contradiction does NOT trip the gate on its own — it routes through the normal Open Questions loop (Step 6) and the user decides. One specialist raising many findings also does not trip the gate — one detailed reviewer is not a spec-immaturity signal.

**Build the Open Questions list.** Any finding that cannot be settled deterministically (claim is `Anecdotal`, two specialists `Disputed`, or the finding is tagged `spec-level` / `T#-contradiction` and was not user-deferred) becomes an `OQ-N` entry. Open Questions are first-class output and feed into Step 6.

**Pick the next-step recommendation deterministically:**

- If the spec-maturity gate tripped → `pause and sharpen the spec`.
- If at least one specialist named a specific other specialist as a needed handoff → `continue iterating` (with the named handoffs).
- If at least one Open Question is `plan-level` and unresolved → `continue iterating` (use Step 6 to resolve via evidence or junior-developer reframing).
- Otherwise → `go to synthesis`.

**Write the round entry** to `artifacts/implementation-iteration-history.md` using [implementation-iteration-history-template.md](references/implementation-iteration-history-template.md). Populate the claim ledger, Open Questions, spec-maturity tags, and next-step recommendation fields directly from this aggregation.

**If the spec-maturity gate tripped**, this skill makes the one and only PM facilitation call in the round: launch `project-manager` in **facilitation mode** (pass `model: "sonnet"`) with the verbatim specialist outputs, the deterministic aggregation, and a directive to confirm or refine the gate-trip assessment and surface anything the deterministic aggregator might have missed before the user is asked to pause spec-stage work. Pass the directive: **do NOT write a facilitation-summary file to disk.** Return the facilitation output verbatim. Append PM's verbatim output to the round entry under a `Project-manager review (gate-trip pass):` field.

Then surface the tripping findings to the user with:

- The list of `spec-level` findings and `T#`-contradictions that tripped the gate, grouped by the spec section they affect.
- A recommendation to run `han:iterative-plan-review` on the source spec (for mechanic-leak cleanup and gap filling) or re-enter `han:plan-a-feature` (for structural gaps where whole sections are missing).
- An explicit **override option**. The user may direct the skill to continue anyway — in which case `plan-implementation` proceeds, and the tripping findings are documented in the round entry, noting the user's override and the reasoning provided.

If the user overrides, the plan ships with the spec accepted as-is; if the user chooses to pause, stop the skill and hand control back to spec-stage work.

## Step 6: Iterative Resolution Loop

Repeat this loop until the deterministic next-step recommendation is `go to synthesis` or `blocked pending user input` and all blocking questions have been escalated.

For each iteration:

1. **Process the deterministic aggregation's Open Questions.** For each question:
   - **First, try evidence.** Re-check the feature specification, codebase, ADRs, coding standards, and already-resolved items from prior rounds. If evidence settles the question, record the resolution in the iteration notes and remove it from the Open Questions list.
   - **If evidence is insufficient, ask `junior-developer` to reframe.** Launch `junior-developer` in conversational mode (pass `model: "sonnet"`) with the question, the specialist input that raised it, and a directive to restate the issue in plain language and surface the clarifying questions a three-to-five-year generalist would ask. The reframing often exposes an unstated assumption or a simpler question the specialists can answer among themselves.
   - **If the reframing resolves it**, record the resolution and move on.
   - **If the reframing does not resolve it**, escalate to the user. Present the question with: the specialist(s) who raised it, the evidence considered, the junior-developer's reframing, a recommended answer with rationale, and the alternatives considered. Capture the user's answer verbatim. Do not ask more than a focused batch of questions at once — enough to unblock the next round, not a firehose.

2. **Re-engage specialists as the aggregation directs.** If a specialist named in their Step 4 output called for another specialist to weigh in, or if a Step 5/6 aggregation flagged a handoff, launch the named specialists (sonnet) in parallel with the new context (use domain-scoped briefs from Step 4), and collect their output.

3. **Re-aggregate deterministically.** Apply the same Step 5 rules to the updated state: the prior round's iteration-history entry, the newly resolved Open Questions, the new specialist input from sub-step 2, and any user answers. Recompute the claim ledger, spec-maturity tags, Open Questions, and next-step recommendation. **Do not call `project-manager` for this** unless the spec-maturity gate trips for the first time in this round (in which case use the same single PM call described in Step 5).

4. **Append a round entry to `artifacts/implementation-iteration-history.md`.** Before deciding whether to loop again, write the round's record using the [implementation-iteration-history-template.md](references/implementation-iteration-history-template.md) format. The entry consolidates the deterministic aggregation into the structured fields: `R#` ID, specialists engaged, new input provided, claim ledger, Open Questions raised, spec-maturity tags, resolution source per question, and the deterministic next-step recommendation. Leave `Decisions produced:` and `Changed in plan:` as `—` for now; both fields are backfilled by the project-manager in Step 8 once decisions are committed and the plan is written.

5. **Decide whether to continue looping (deterministic stop rule).** Exit the loop when ANY of the following holds:
   - The deterministic next-step recommendation is **"go to synthesis."**
   - The deterministic next-step recommendation is **"blocked pending user input"** and all blocking Open Questions have been escalated to the user with recommendations still awaiting answers.
   - The most recent round produced ≤ 2 new findings AND zero major findings (security, T#-contradiction, missing coordination, unhandled failure mode, or any finding tagged `spec-level`).

   Otherwise, continue with another iteration.

The round cap from Step 3 sets the upper bound: small = 1 round, medium = 2 rounds, large = 3 rounds. Never exceed the size cap. If the team is still iterating at the cap, surface the remaining Open Questions to the user with recommendations and a note that the team has reached a facilitation plateau.

## Step 7: Final User Escalation Pass

Before synthesis, ensure every Open Question that cannot be resolved by evidence or junior-developer reframing has been surfaced to the user and answered. Do not guess the user's answers. If any are still pending and the user has indicated they want to defer, record them as open items the plan will ship with.

## Step 7.5: YAGNI Sweep

Before synthesis, walk every committed item the iterative loop has produced and run the YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md). Items in scope: every recommendation captured in `artifacts/implementation-iteration-history.md`'s claim ledgers across all rounds, every Open Question that proposes adding an artifact, and every specialist recommendation that survived the loop without explicit deferral.

For each in-scope item, apply the two gates:

1. **Evidence test.** Does the item cite at least one piece of accepted evidence per the rule (user-described need from the spec, named direct dependency, existing production code path that breaks, applicable regulation, documented incident or measured metric)? If no — the item is a YAGNI candidate.
2. **Simpler-version test.** When evidence applies, is there a strictly simpler implementation (one fewer abstraction, one fewer file, one fewer infrastructure component, one fewer test category, a single concrete implementation instead of an interface, an inline check instead of a helper, etc.) that satisfies the same evidence? If yes — the simpler implementation replaces the larger one.

Apply the named anti-patterns from the rule doc as auto-flags — runbooks for never-fired alerts, observability for non-flowing telemetry, SLOs for absent traffic, single-implementation interfaces, configuration knobs no caller sets, multi-region for unproven workloads, indexes for unrun queries, audit columns nobody reads, tests for code paths that don't exist yet.

For every item the sweep flags, record a YAGNI ledger entry that PM will absorb into synthesis:

- **Item** — what is being demoted or replaced.
- **Failure** — which gate failed, citing the named anti-pattern when applicable.
- **Resolution** — defer with reopening trigger | replace with simpler implementation: {one-line description} | escalate to user if the resolution would change a behavior the spec committed to.
- **Source** — which specialist or round originally proposed the item, plus the corresponding `R#` and claim-ledger entry.

If the sweep produces YAGNI items that would change a behavior the spec committed to, surface them to the user before synthesis with a recommended resolution and the option to override. The user always wins; the rule's job is to make the cost of including the item visible.

The YAGNI ledger is a synthesis input — pass it to PM in Step 8 alongside the round entries and resolutions.

## Step 8: Project Manager Synthesis

Launch `project-manager` in **synthesis mode** — this is the one call in this skill that runs on the project-manager's default model; pass no `model` override. Provide it with:

- The feature specification path (or a note that no source file was provided and what conversational context was used instead), plus the spec's `artifacts/decision-log.md`, `artifacts/team-findings.md`, and `artifacts/feature-technical-notes.md` paths if they exist (falling back to the spec folder root for legacy layouts).
- The full verbatim output from every specialist engaged across all rounds.
- The aggregated round entries from `artifacts/implementation-iteration-history.md` (claim ledger, Open Questions, spec-maturity tags, next-step recommendations). These are the deterministic-aggregation summaries that replaced per-round PM facilitation; PM did not facilitate per round, so there are no separate facilitation summaries to read.
- If the spec-maturity gate tripped at any point, the verbatim PM facilitation output for that single gate-trip pass.
- Every resolution from Step 6 (what evidence, reframing, or user input settled each question).
- The YAGNI ledger from Step 7.5 (items demoted or replaced under the YAGNI rule, plus any user overrides made during the sweep).
- Any remaining open items and the user's disposition on each, including any spec-maturity-gate overrides and the reasoning the user provided.
- The three target output paths: `{same-folder-as-source}/feature-implementation-plan.md`, `{same-folder-as-source}/artifacts/implementation-decision-log.md`, and `{same-folder-as-source}/artifacts/implementation-iteration-history.md` (the latter already populated with round entries from Step 6, awaiting backfill).
- The templates: [feature-implementation-plan-template.md](references/feature-implementation-plan-template.md), [implementation-decision-log-template.md](references/implementation-decision-log-template.md), and [implementation-iteration-history-template.md](references/implementation-iteration-history-template.md).

Ask the project-manager to produce the final synthesis across all three files:

1. **Write `artifacts/implementation-decision-log.md`** — classify each decision as **full** or **trivial** before writing it. Full: has rejected alternatives, evidence beyond the user's framing or the source spec's commitments, was changed across rounds, has dependent decisions, or has recorded dissent. Trivial: settled directly by the user, the source spec, or an obvious convention. Full decisions go under `## Full decisions` with the structured fields (rationale, evidence, rejected alternatives, specialist owner, revisit criterion, dissent, `Driven by rounds:`, `Dependent decisions:`, `Referenced in plan:`). Trivial decisions go under `## Trivial decisions` as a one-line bullet (`D-N: {title} — {outcome}. — Referenced in plan: {sections}.`). The D-N counter is shared across both sections, and every plan inline link still resolves to a D-N whether full or trivial.
2. **Write `feature-implementation-plan.md`** — the primary plan covering Source Specification, Outcome, Context, Team Composition, Implementation Approach, Decomposition and Sequencing, RAID Log, Testing Strategy, Security Posture, Operational Readiness, Definition of Done, Specialist Handoffs, Deferred (YAGNI), Open Items, and Summary. The `Deferred (YAGNI)` section is **lazily created** — write it only if at least one item was deferred under the YAGNI rule (per Step 7.5's ledger and PM's own application of the rule during synthesis); omit it entirely when nothing qualifies. For each deferred item, record: the item, why deferred (which gate failed), the reopening trigger, and the source (specialist or round that proposed it). For every claim that embodies a non-obvious decision, append an inline parenthetical link to the decision, e.g. `([D-3](artifacts/implementation-decision-log.md#d-3-rollout-strategy))`. Link only non-obvious claims. Do not inline rationale or rejected alternatives. Do not repeat round-by-round history.
3. **Backfill `artifacts/implementation-iteration-history.md`** — for each `R#` entry already present from Step 6, populate `Decisions produced:` with the `D#` IDs added or changed that round and `Changed in plan:` with the plan sections updated that round.
4. **Preserve the cross-reference invariants across all three files:**
   - Every `D#` in `artifacts/implementation-decision-log.md` lists its `Driven by rounds:` (`R#` IDs), `Dependent decisions:` (`D#` IDs), and `Referenced in plan:` (plan section headings).
   - Every `R#` in `artifacts/implementation-iteration-history.md` lists its `Decisions produced:` (`D#` IDs) and `Changed in plan:` (plan section headings).
   - Every non-obvious claim in `feature-implementation-plan.md` has its inline `([D-N](artifacts/implementation-decision-log.md#...))` link.
   - When an Open Question was settled by your own re-reading of the spec during this synthesis pass (not in the Step 6 loop), label its `Resolution source:` in `artifacts/implementation-iteration-history.md` as **`PM synthesis (Step 8 evidence)`** — not bare `evidence` — so the audit record distinguishes a loop-stage resolution from a synthesis-stage one.

5. **Audit and correct, do not just populate.** Beyond preserving the structural invariants above, actively reconcile the artifacts against each other and rewrite any inconsistency in place — the same active-correction mandate `plan-a-feature`'s synthesis carries ("any leak the project-manager finds is rewritten in place"). During synthesis, audit and fix:
   - **Every decision-log entry's title matches its body.** A title copied from another decision (a `D-3` carrying `D-1`'s title) is rewritten to describe its own decision.
   - **Every path, filename, or directory referenced in one plan section is consistent with the file layout described in another.** An install-script path that the layout section never places there is reconciled to one layout.
   - **The altitude rule is honored** (see Operating Principles): a full file block inlined in the plan is replaced with a named reference plus only the decision-bearing values. This is a semantic audit on top of the structural-invariant preservation, not a replacement for it; LLM generation is probabilistic, so the audit lowers the odds of a copy-paste title or path mismatch rather than guaranteeing zero.

**The `Source Specification` section of `feature-implementation-plan.md` must be populated.** If a feature specification file was provided, the project-manager must include a relative markdown link to it (typically `[feature-specification.md](feature-specification.md)` since both files live in the same folder). If the spec's `decision-log.md`, `team-findings.md`, and/or `feature-technical-notes.md` also exist (in `artifacts/` for the current layout, or at the folder root for legacy layouts), list them under Source Specification with the correct relative path. The `feature-technical-notes.md` entry is present only when the file exists — its absence is not a gap. If no file was provided and the plan was built from conversational context only, the section must state that explicitly and summarize what context was used.

The project-manager's synthesis is authoritative.

## Step 9: Present the Final Implementation Plan

Summarize for the user:

- All three output file paths: `feature-implementation-plan.md`, `artifacts/implementation-decision-log.md`, `artifacts/implementation-iteration-history.md`.
- The team composition (each specialist and why they were included) — point to `artifacts/implementation-iteration-history.md` for per-round detail.
- The number of iterations the loop ran before convergence — point to `artifacts/implementation-iteration-history.md`.
- The number of decisions settled by evidence, by junior-developer reframing, and by user input — point to `artifacts/implementation-decision-log.md`.
- The number of YAGNI deferrals captured in `feature-implementation-plan.md`'s `## Deferred (YAGNI)` section (omit this line if the section was not written because nothing qualified).
- Any remaining open items and whether they block implementation — in `feature-implementation-plan.md`.
- The project-manager's recommendation (ship as planned, hold for specialist handoff, or blocked pending open item).

Ask whether the user wants to iterate on specific sections or consider the plan ready for implementation.
