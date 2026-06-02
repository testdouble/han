---
name: "gap-analysis"
description: >
  Performs a gap analysis between two artifacts (a current state and a desired
  state) and produces a plain-language, stakeholder-readable report indexed by
  stable gap IDs. Use when the user wants to compare, evaluate, audit, or
  reconcile one artifact against another — including spec-vs-implementation,
  PRD-vs-shipped-feature, design-vs-build, or requirements-vs-code gaps, or any
  "what's missing from X compared to Y" question. Orchestrates the gap-analyzer
  agent for the primary analysis, then runs a validator-and-augmenter swarm by
  default to corroborate, contradict, and enrich the findings across actor
  perspectives; the user may opt out with `no swarm`. Recommends a swarm team
  size (small / medium / large) based on gap count and the domains the gaps
  touch. Does not investigate runtime bugs — use investigate. Does not assess
  module-level architecture — use architectural-analysis. Does not research
  open-ended options with no second artifact to compare against — use research.
arguments: size
argument-hint: "[size: small | medium | large] [current state artifact, desired state artifact, optional: scope and modes]"
allowed-tools: Read, Write, Glob, Grep, Agent, Bash(find *), Bash(git *)
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Operating Principles

- **The `han.core:gap-analyzer` agent owns the primary analysis.** This skill does not classify gaps itself. It calls `han.core:gap-analyzer` once, reads the analyzer's full output file, and synthesizes a stakeholder-readable report from it.
- **Plain language is the default surface.** Sections 1 and 2 of the report never contain file paths, line numbers, function or class names, library mechanics, or language primitives. Technical fidelity is quarantined to Section 3 and only appears when the user has explicitly requested technical details.
- **The swarm runs by default.** A minimum viable swarm ships at every size: `han.core:adversarial-validator` and `han.core:junior-developer` always, plus `han.core:evidence-based-investigator` when the current state is concrete enough to verify against. The user may opt out with `no swarm` to fall back to a lightweight gap-analyzer-only pass.
- **Evidence rule applies to every gap.** Apply the evidence rule from [../../references/evidence-rule.md](../../references/evidence-rule.md) when characterizing the evidence that establishes each gap. Name the trust class of every citation pair (codebase, web, provided); apply the corroboration gate to web-source claims that establish a gap; and label gaps where the desired-state evidence is absent ("the spec is silent on X") as a distinct state, not as a weak gap. The `han.core:evidence-based-investigator` dispatched in the swarm carries codebase findings; the gap analyzer carries the spec-side citations.
- **Artifact-level analysis caveats are surfaced once, not per gap.** Some validator observations apply uniformly to the whole comparison rather than to any one gap — most commonly a provenance concern about the desired-state artifact as a whole (for example, "the desired state is a provided, uncommitted, same-session source," which the evidence rule's `provided` trust class genuinely warrants flagging). Surface such an observation a single time as an artifact-level analysis caveat. Do not repeat it as a per-gap verdict on every gap that rests on that artifact, and do not let it raise or lower any gap's confidence — it bears on the whole report equally, so per-gap weighting would double-count one fact. Provenance concerns specific to a *single* gap's evidence still belong to that gap's verdict.
- **`han.core:junior-developer` runs the actor-perspective sweep.** Gap analysis lives at the feature and behavioral level from a user's or actor's perspective — human end users (and sub-roles like customer, admin, auditor, support agent), API callers, AI agents, integration partners, batch processes, internal services. The han.core:junior-developer's job in the swarm is to check that each gap holds for every actor type the desired state addresses or implies, and to surface gaps the analyzer missed because it only considered one actor type.
- **`han.core:project-manager` coordinates Section 4 synthesis at medium and large only.** When the swarm reaches four or more agents, PM consolidates the swarm's confirmations, contradictions, augmentations, and per-gap confidence values for the skill to render. At small swarm size (two or three agents), the skill consolidates deterministically without PM.
- **Optional sections must not be load-bearing.** A report with only Sections 1 and 2 must stand on its own. Sections 3 and 4 are additive — never required for Sections 1 and 2 to make sense.
- **Purpose-conditioned prioritization is a labeled skill judgment, never the analyzer's.** The `han.core:gap-analyzer` produces a neutral, unprioritized gap list and must stay that way. When the user states *why* they are running the comparison (e.g., "before a redesign pass," "to scope the next sprint"), the skill may add one explicitly-labeled "Where to start" pointer view that names the few gaps most blocking that stated purpose. This is the skill's own synthesis judgment — the same kind it already makes when it clusters gaps into themes and derives confidence — layered on top of the neutral list, never replacing it, and omitted entirely when no purpose was given.
- **Gap IDs are stable for the life of the report.** Map `GAP-NNN` from the `han.core:gap-analyzer` output to `G-NNN` in the report, preserving order. Cross-references in Sections 3 and 4 use the same `G-NNN` IDs.
- **The report template lives at [gap-analysis-report-template.md](references/gap-analysis-report-template.md).** It was designed by the `han.core:information-architect` agent. The skill renders the template by filling placeholders and removing the optional sections that were not requested or generated.

# Run a Gap Analysis

## Step 1: Identify Inputs and Project Context

Read the user's argument and conversation context to identify two artifacts:

- The **current state** — what exists today (e.g., the implementation, the shipped feature, the legacy design).
- The **desired state** — what is expected (e.g., the spec, the PRD, the new design).

Inputs may be file paths, directory paths, URLs, or inline text. If the user named only one artifact and a comparison target is implied (e.g., "compare the auth module to the auth spec"), search the project for the implied second artifact using `Glob` and `Grep` against `docs/`, `specs/`, `requirements/`, or directories surfaced via CLAUDE.md / `project-discovery.md`. If the implied artifact cannot be located, ask the user for the path before proceeding.

State the resolved comparison direction to the user in one line: "Comparing **{current}** against **{desired}**." If the user wants the direction reversed, accept the override.

**Capture the purpose, if one was stated.** Note *why* the user is running this comparison when they said so (e.g., "before a redesign pass," "to scope the next sprint," "to decide whether to ship"). If no purpose is evident, you may offer to capture one in the same one-line confirmation — for example, "If you tell me what this comparison is for, I'll flag which gaps block that goal." Do not block on it: a purpose is optional and only drives the optional "Where to start" view in Step 6. Record the purpose verbatim if given.

Resolve project config: read CLAUDE.md's `## Project Discovery` section if present; fall back to `project-discovery.md`; fall back to the working directory's `docs/` tree. The output report will be written to the project's documentation root if one exists (`docs/`, `documentation/`, or a folder surfaced by project config), otherwise to the current working directory. Default report filename: `gap-analysis-report.md`. If a same-named file already exists, append a short timestamp suffix to avoid overwriting.

## Step 2: Run the `han.core:gap-analyzer` Agent

Launch `han.core:gap-analyzer` with a single Agent tool call. Provide:

- The current state and the desired state (paths, URLs, or inline text exactly as resolved in Step 1), with explicit labeling of which is which.
- Any scope the user provided (specific subsystems, features, sections).
- A directive to write its full analysis to a file alongside the future report (e.g., `{report-dir}/gap-analysis-source.md`) so the skill can read the structured findings and translate them.
- A directive to use unidirectional comparison (current → desired) unless the user explicitly asked for bidirectional analysis.
- A directive to report the **actors and modes it observed** in the desired state — named roles and sub-roles, interactive vs. batch/automated modes, and API / agent / integration surfaces — as a neutral observation in its output. The analyzer already reads the desired state's full surface area while building the correspondence map; this only asks it to surface what it saw. It is an observation, not a prioritization or classification, so it does not touch the analyzer's neutral posture.

Read the observed-actor list from the analyzer's output once it returns; it seeds the `han.core:junior-developer` actor sweep in Step 5.

Wait for the agent's return. The summary it returns names the file path and gap counts by category. Read the full analysis file from disk before proceeding — the per-gap entries (`GAP-001`, `GAP-002`, ...) are in the file, not the returned summary.

## Step 3: Classify Size and Build the Swarm

**Default to small.** Start the classification at **small** and only escalate to medium or large when the signals below clearly require it. When a signal is borderline, stay at the smaller band. Use these signals from the `han.core:gap-analyzer` output:

- **Small** *(default)* — 0–3 total gaps, single domain (e.g., one feature, one module, one document section), no security / data / cross-service / architectural signals in any gap. Swarm: **2–3 agents** (validator + han.core:junior-developer, plus investigator when the current state is concrete).
- **Medium** — 4–10 total gaps, two or three adjacent domains, may touch one cross-cutting concern (a single auth surface, a single integration boundary, a single data-contract change). Swarm: **4–6 agents** (validator + han.core:junior-developer + investigator + 1–2 domain specialists + han.core:project-manager).
- **Large** — 11+ gaps, OR cross-cutting concerns across multiple domains (security + data + architecture, or cross-service integration), OR the user explicitly requested a full swarm. Swarm: **6–8 agents** (validator + han.core:junior-developer + investigator + 2–4 domain specialists + han.core:project-manager).

**Always required, at every size:**

- `han.core:adversarial-validator` — attacks the han.core:gap-analyzer's findings with counter-evidence to surface invalid gaps and produce per-gap confidence verdicts.
- `han.core:junior-developer` — runs the actor-perspective sweep. For every gap, enumerates every actor the desired state addresses or implies (human end users and sub-roles, API callers, AI agents, integration partners, batch processes, internal admins, auditors) and checks whether the gap holds for every actor type. Surfaces gaps the analyzer missed because it only considered one actor type.

**Required when the current state is concrete** (codebase, document on disk, fetchable URL — not inline-text-only comparison):

- `han.core:evidence-based-investigator` — verifies each gap against the actual current state with file-level or document-level evidence. Effectively always required at medium and large; the inline-text-only path is the rare exception.

**Required at medium and large:**

- `han.core:project-manager` — consolidates swarm output into Section 4 of the report during synthesis (Step 5.6). Not called per-round.

Add domain specialists up to the size cap based on what the gaps actually touch. Read the gap entries to decide. Draw from:

- `han.core:adversarial-security-analyst` — gaps touching auth, authorization, PII, secrets, untrusted input, supply chain.
- `han.core:user-experience-designer` — gaps touching user-facing flows, UI, interaction, accessibility.
- `han.core:data-engineer` — gaps touching schemas, migrations, data movement, analytics.
- `han.core:devops-engineer` — gaps touching deployment, observability, rollout, scale, SLO impact, cost.
- `han.core:on-call-engineer` — gaps where the current application source is missing the named code-level resilience patterns the desired state implies: timeouts, retry safety, idempotency, backpressure, kill switches, correlation-id propagation, observability of failure paths. Application source only — defer infrastructure and pipeline gaps to `han.core:devops-engineer`.
- `han.core:system-architect` — gaps crossing service or bounded-context boundaries, integration patterns, data ownership.
- `han.core:software-architect` — gaps inside a single codebase touching module boundaries, abstractions, SOLID concerns.
- `han.core:content-auditor` — gaps where the desired state is documentation and content preservation is in question.
- `han.core:codebase-explorer` — gaps where the current state is unfamiliar code that needs deeper discovery before the validators can act.

State the size, the chosen swarm composition, and the per-specialist justification to the user in a short message — for example:

> **Size: medium.** Detected 7 gaps across the auth surface and the user-profile data contract.
> **Swarm (5 agents):**
> - `han.core:adversarial-validator` — required at every size.
> - `han.core:junior-developer` — required at every size; actor sweep across the auth surface (human users, API callers, internal service callers).
> - `han.core:evidence-based-investigator` — required; verifies the auth-surface gaps against `src/auth/`.
> - `han.core:adversarial-security-analyst` — three gaps touch session-token handling.
> - `han.core:project-manager` — required at medium; consolidates swarm output into Section 4.

**Size override.** If `$size` is non-empty (the user passed `small`, `medium`, or `large` as the first argument), use that value as the size and skip the signal-based classification above; the swarm composition still scales to the chosen size. If the user named specific specialists, honor those. If the user requested a different size in conversation rather than via `$size`, accept the override.

## Step 4: Confirm Swarm and Technical-Detail Modes

Surface both decisions to the user in one combined message:

> **Swarm: running by default with [team above].** Reply `no swarm` to skip the swarm entirely, `lightweight` to drop to the minimum two (validator + han.core:junior-developer), or name specialists to add or remove.
>
> **Technical details: not included by default.** Reply `include technical details` to add Section 3 with file-level fidelity, or `plain language only` to omit it.

If the user already specified either mode in their original request (e.g., "run a gap analysis with technical details" or "skip the swarm"), honor that and skip this confirmation.

Default behavior when the user does not respond or says "proceed": **swarm runs as recommended, plain language only.** Record the chosen modes — they determine which sections appear in the final report.

## Step 5: Run the Swarm (unless opted out)

If the user passed `no swarm`, skip to Step 6.

Launch every selected swarm agent in parallel — a single Agent-tool message with one tool call per agent so they run concurrently — except `han.core:project-manager`, which is held for synthesis after the other agents return (see Step 5.6). Use domain-scoped briefs:

- Pass each agent the path to the `han.core:gap-analyzer`'s full analysis file plus the gap entries relevant to its domain inline. For `han.core:adversarial-validator`, `han.core:evidence-based-investigator`, and `han.core:junior-developer`, pass the entire gap list — they are generalist by design for this use case.
- Pass each agent the resolved current-state and desired-state paths so it can re-read them on demand.
- Frame the question precisely:
  - **Validator** (`han.core:adversarial-validator`) — "For each gap below, attempt to disprove it. Cite counter-evidence. Return a per-gap verdict: `confirmed`, `contradicted`, or `inconclusive`, with reasoning. Apply full provenance scrutiny to the inputs. When a provenance concern applies *uniformly to the desired-state artifact as a whole* (for example, the desired state is a provided, uncommitted, same-session source), return it **once** as a single artifact-level `analysis_caveat` — not as a per-gap verdict repeated across every gap that rests on that artifact. Keep provenance concerns specific to an *individual* gap's evidence inside that gap's verdict."
  - **Investigator** (`han.core:evidence-based-investigator`) — "For each gap below, verify whether the current state actually shows what the analyzer claimed. Cite file paths and line numbers in your reasoning, but return a per-gap verdict: `confirmed`, `contradicted`, or `unverifiable`."
  - **Junior-developer (actor sweep)** — "For every gap in the analyzer's output, run an actor-perspective sweep. Candidate actors the analyzer observed in the desired state: [paste the observed-actor list from Step 2; write `none observed` if the analyzer reported none]. Treat that list as a floor, not a ceiling — expand it with every actor type the desired state addresses or implies: human end users (and sub-roles like customer / admin / auditor / support agent), API callers, AI agents, integration partners, batch processes, internal services. For each gap, check whether it holds for every actor type or only the one the analyzer compared against. Surface as `proposed_new_gap` any case where the analyzer's gap is correct for one actor but a *different* gap exists for another actor that the analyzer missed. Apply Protocol 8 plain-language reframing to each gap from the most-affected actor's vantage point and flag any gap that would not be recognizable as a gap to that actor."
  - **Augmenters** (every domain specialist) — "For each gap that touches your domain, add concrete context the han.core:gap-analyzer may have missed: related risks, secondary effects, or refinements to the gap's framing. Do not introduce new gaps; if you find one, raise it as `proposed_new_gap` with evidence."
- Direct every agent to cite gap IDs as `GAP-NNN` (the analyzer's IDs) so the skill can map them back to `G-NNN` in the report.

Collect every agent's verbatim output. If an agent returned a `proposed_new_gap` with evidence, append it to the analyzer's findings as a new `GAP-NNN` entry before report rendering — do not silently drop it. Mark it in the report with a footnote noting it was surfaced by the swarm and by which agent (`han.core:junior-developer (actor sweep)`, `han.core:adversarial-security-analyst`, etc.).

## Step 5.5: Conditional Second Round

Inspect the first-round swarm output for signals that the analyzer's correspondence map systematically excluded an actor type or behavior class:

- **Trigger A:** the swarm returned **≥ 3 `proposed_new_gap`** entries.
- **Trigger B:** the swarm returned **contradictions on ≥ 20%** of the analyzer's original gaps.

If neither trigger fires, skip to Step 5.6.

A fired trigger is a *proxy* for the same underlying signal — the first pass systematically under-covered an actor type or behavior class. The proposed gaps the swarm already surfaced are a *symptom* of that under-covered class, not the whole of it. So the round's job is to re-scan that class for *additional* gaps and to catch recategorizations and withdrawals — not to re-confirm the gaps the swarm already corroborated.

If a trigger fires, run one additional pass — bounded to one extra round, never more:

1. Re-dispatch `han.core:gap-analyzer` with the new findings and the actor types `han.core:junior-developer` surfaced. Brief: "Your first pass produced N gaps. The validator-augmenter swarm surfaced [new gaps / contradictions], which point to the actor or behavior classes [list] being under-covered in your first pass. **Do not re-confirm gaps the swarm has already corroborated.** Re-scan both artifacts focused on those classes and return only the delta: (a) *additional* new gaps in those classes that neither your first pass nor the swarm has surfaced, (b) gaps that need recategorization, and (c) gaps that should be withdrawn."
2. Read the delta. Merge new gaps into the source file with fresh `GAP-NNN` IDs in append order. Record recategorizations and withdrawals.
3. Do **not** re-run the full swarm. The second round is for the analyzer; the swarm verdicts on existing gaps carry forward.

Record in the in-channel summary that a second round ran and why (which trigger, what changed).

## Step 5.6: Project-Manager Synthesis (medium and large only)

If `han.core:project-manager` is not on the team, skip to Step 6.

Launch `han.core:project-manager` in synthesis mode with:

- The full `han.core:gap-analyzer` source file (including any second-round delta).
- The verbatim output from every other swarm agent.
- The four-section template at [gap-analysis-report-template.md](references/gap-analysis-report-template.md).
- The chosen modes (swarm: yes, technical details: yes/no).

Ask the han.core:project-manager to produce **only Section 4 content** — Confirmations, Contradictions, Augmentations, any artifact-level Analysis caveats the validator returned, and the Confidence summary table — plus per-gap confidence values for the skill to fold into Section 2. Direct PM to keep analysis caveats out of the per-gap confidence values (they apply to the whole report, not to any one gap). PM does not write the report file directly; it returns the consolidated Section 4 content and confidence values to the skill, which renders them into the template in Step 6.

## Step 6: Synthesize the Report

Read [gap-analysis-report-template.md](references/gap-analysis-report-template.md). Render the report by filling placeholders and removing optional sections that do not apply.

**Render rules:**

1. **Map IDs.** For each `GAP-NNN` from the analyzer (and any `proposed_new_gap` from the swarm, plus any second-round delta), produce a corresponding `G-NNN` entry in the report. Preserve order. Do not skip IDs.
2. **Translate to plain language for Sections 1 and 2.** The analyzer's per-gap content is technical (file paths, code identifiers, document headings). For Sections 1 and 2, restate each gap's `Expected`, `Current`, and `Why it matters` fields in plain language a non-technical stakeholder can read. Strip every file path, line number, function name, class name, schema field name, library name, and language primitive. Replace technology terms with capability or behavior descriptions ("the part of the system that authenticates users" rather than `auth/middleware.ts:42`).
3. **Set confidence per gap.** If the swarm ran, derive confidence from swarm verdicts: `High` when ≥ 2 swarm agents confirmed the gap with evidence; `Medium` when one agent confirmed or augmenters added context without contradiction; `Low` when at least one agent contradicted it. If PM was on the team, use the per-gap confidence values PM returned in Step 5.6. If no swarm ran (`no swarm` path), mark every gap `Medium` — confidence rests on the analyzer alone — and state this in the executive summary.
4. **Inline swarm augmentations into Section 2.** For each gap that received augmenter context (added risks, secondary effects, refined framing, actor-perspective notes from han.core:junior-developer), add an `Additional context (swarm):` line to that gap's Section 2 entry in plain language. The same augmentation is preserved verbatim in Section 4's Augmentations list for audit trail. Augmentations enrich understanding; they do not change the gap's category or confidence.
5. **Compose the executive summary's "shape of the gap" bullets** by clustering related gaps thematically. Each bullet is a plain-language theme covering one or more gaps. Do not enumerate every gap here — that is Section 2's job.
6. **Render Section 3 (Technical Details) only if the user opted in.** For each gap, fill `Locations`, `Relevant identifiers`, `Specifics of the divergence`, `Remediation direction`, `Effort signal`, and `Risks / dependencies`. Pull `Locations` and `Relevant identifiers` directly from the analyzer's evidence pairs. The skill itself produces the `Effort signal` only when the analyzer or the swarm provided enough information; otherwise mark it `Unknown` with a one-sentence basis. If a gap is `Implicit` and has no concrete location, omit its Section 3 entry and note it in the section-3 preface as expected.
7. **Render Section 4 (Swarm Findings) by default.** Section 4 is omitted only when the user passed `no swarm`. Group entries into Confirmations, Contradictions, and Augmentations using the swarm agents' verbatim verdicts. Build the Confidence summary table from the per-gap confidence values set in step 3. If PM was on the team, use the consolidated Section 4 content PM returned in Step 5.6.
8. **Render artifact-level analysis caveats once.** Collect every `analysis_caveat` the validator returned (Step 5) into Section 4's **Analysis caveats** subsection, rendered once as a plain reminder that applies to the whole report — explicitly not a gap finding. Do not let any caveat feed the per-gap confidence values set in step 3. If no `analysis_caveat` was returned, omit the subsection. (On the `no swarm` path there is no validator, so there are no analysis caveats.)
9. **Render the "Where to start" view only if a purpose was captured.** If Step 1 recorded a purpose, render the optional **Where to start** block in Section 1 (after the magnitude table): up to five gaps that most block that stated purpose, each as `G-NNN — one-line plain-language reason it blocks {purpose}`, under the explicit label "Where to start (skill judgment for your stated purpose: {purpose})." This is the skill's labeled synthesis judgment from the Operating Principles — it adds no new gaps, changes no categories or confidence, and cites only existing `G-NNN` IDs. If no purpose was captured, omit the block entirely; never invent a purpose to justify it.
10. **Update the optional-section markers in the front matter.** If Section 3 was not rendered, remove `- technical_details` from `sections_included`. If Section 4 was not rendered (because the user passed `no swarm`), remove `- swarm_findings`. Update the "How to Read This Report" frame so it does not promise sections that are not present — replace each promise with a single line stating the section was not included for this report. The "Where to start" block and the "Analysis caveats" subsection are conditional content inside existing sections, not top-level sections, so they do not get their own `sections_included` entries.

Write the rendered report to the path resolved in Step 1.

## Step 7: Present the Report

Tell the user, in a short summary:

- The report path.
- The path to the `han.core:gap-analyzer`'s underlying source file (so they can verify the technical evidence).
- The size class chosen and the modes used (swarm: yes/no with composition; technical details: yes/no).
- The total gap count and the breakdown by category, exactly as it appears in the report's executive summary.
- If a second round ran in Step 5.5, which trigger fired and what changed (new gaps surfaced, recategorizations, withdrawals).
- If a purpose was captured, a one-line note that the report includes a "Where to start" view for that purpose.
- Any open recommendations: a one-line note if the swarm contradicted any gaps (those need adjudication), if any `proposed_new_gap` was surfaced and added, if an artifact-level analysis caveat was raised (e.g., the desired state is an uncommitted same-session source), or if PM flagged anything specific in the Section 4 consolidation.

Ask whether the user wants to add technical details (if Section 3 was omitted) or refine the scope and re-run.
