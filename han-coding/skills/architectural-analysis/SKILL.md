---
name: "architectural-analysis"
description: "Performs deep architectural analysis of a specified module, directory, or feature area by examining structural coupling, data flow, concurrency patterns, risk, and SOLID alignment. Use when the user wants to assess, evaluate, or review the architecture, design quality, dependency structure, coupling, cohesion, or technical debt of an existing part of the codebase. Not for investigating specific bugs, runtime errors, or failures — use investigate. Not for test planning — use test-planning. Not for file-level code review — use code-review. Not for researching open-ended options, prior art, or how something works — use research. Not for writing documentation or architectural decision records."
arguments: size
argument-hint: "[size: small | medium | large] [focus area: module, directory, or feature to analyze]"
allowed-tools: Read, Glob, Grep, Agent, Bash(find *)
---

## Project Context

- git installed: !`which git`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Operating Principles

Read these before dispatching anything. They constrain every step below.

- **A focus area is required.** This skill analyzes a specific module, directory, or feature. "Analyze the whole codebase" is not a valid input. If no focus area resolves to real files, stop and ask the user to name one.
- **The agents own the judgment; the skill orchestrates.** The skill validates the focus area, classifies size, selects the roster, fans agents out and in, and renders the report. It does not produce findings itself.
- **The discovery roster is signal-selected; the synthesis spine always runs.** `han-core:structural-analyst`, `han-core:behavioral-analyst`, `han-core:risk-analyst`, and `han-core:software-architect` run at every size BECAUSE structure, runtime behavior, risk-of-inaction, and SOLID synthesis are the irreducible core of an architectural read. Every other specialist is added only when the focus area's signals warrant it and the size band allows it, BECAUSE dispatching an agent whose domain the code does not touch burns tokens and dilutes the report with low-signal findings.
- **Default to small.** Start classification at small and escalate only when a higher-band signal is clearly present. Borderline signals stay at the smaller band. Under-dispatching is recoverable by re-running at a larger size; over-dispatching is not.
- **Recommendations, not refactors.** The skill never modifies code. `han-core:software-architect` (and `han-core:system-architect` when dispatched) produce pseudocode sketches for proposed boundaries. Implementation is a separate, later step.
- **Negative results are valuable.** When a dimension is genuinely clean (no concurrency in a pure-functional module, sound boundaries), the report says so. Agents must not fabricate findings to fill a section.
- **Single pass, no iteration round.** This skill is a fan-out / fan-in, not an iterative loop. If a band proves too small, the user re-runs at a larger size — the skill does not self-escalate mid-run.
- **System-altitude work is deferred by default.** `han-core:software-architect` defers cross-service / bounded-context / trust-boundary findings rather than absorbing them. `han-core:system-architect` is added to the roster only at large size and only when a boundary-crossing seam is actually present. When it is not dispatched, those deferrals are surfaced in the report so the user can dispatch `han-core:system-architect` separately.
- **The report template lives at [references/architectural-analysis-report-template.md](./references/architectural-analysis-report-template.md).** The skill renders that template by filling placeholders and removing the sections whose agent was not dispatched. It does not invent a structure inline.
- **The synthesized report is written for a named reader.** As the skill writes the final report's synthesized prose, it loads and applies [`../../references/readability-rule.md`](../../references/readability-rule.md), holding one audience above the writing: the engineer weighing the module's design and deciding whether to change it. Scope that frame per section so the technical specifics that reader needs — file paths, finding IDs, exact conditions, pseudocode — are preserved, never simplified away.

# Run an Architectural Analysis

## Step 1: Validate the Focus Area and Resolve Project Context

**Bind `$size`.** If the user passed `small`, `medium`, or `large` as the first positional argument, bind `$size` to it. Anything else is part of the focus-area context, not a size; bind `$size` to the literal `none provided`.

**Resolve the focus area.** Take the remaining argument and conversation context as the focus area. Confirm it resolves to real files using `Glob` and `Read`. Identify the boundary: which files and directories the focus area includes, and one layer of neighbors in each direction (what it imports, what imports it). If the focus area does not resolve to actual files, stop and ask the user to clarify it before going further. If no focus area was supplied at all, ask the user to name one — do not proceed against the whole codebase.

**Resolve project context.** If `CLAUDE.md` is present (see Project Context), read its `## Project Discovery` section for conventions. Fall back to `project-discovery.md` if present. These resolve language, framework, and convention questions so the agents infer less. If neither exists, the agents fall back to surrounding-code inference — note this in the agent briefs.

**Note git availability.** Read the `git installed` value from Project Context. If it is empty, git is unavailable: the analysts will skip churn- and recency-based reasoning and the report must state this. If it is non-empty, the analysts may use git history for churn and likelihood evidence.

**State the driving concern, if any.** If the user named a concern ("I suspect a race in the retry queue", "we want to split this module"), capture it. It biases every agent's attention without narrowing scope. Pass it into every brief.

## Step 2: Detect Signals and Classify Size

Run targeted `Grep` and `Glob` over the focus area to detect which domains the code actually touches. These signals drive both the size band and the roster:

- **Concurrency signal:** `async`/`await`, Promises, threads, goroutines, workers, channels, mutexes/locks, semaphores, queues, `Promise.all`, `WaitGroup`, thread pools, atomic types.
- **Security signal:** authentication, authorization, sessions, tokens, passwords, secrets, crypto calls, PII fields, deserialization of untrusted input, SQL/command construction from input.
- **Data signal:** schema or migration files, ORM models/repositories, hand-written SQL, query builders, data-pipeline or stream/event-contract code, document-store access.
- **DevOps signal:** Dockerfiles, IaC (Terraform, CloudFormation, k8s manifests), CI/CD pipeline definitions, observability/metrics/tracing wiring, retry/timeout/scaling configuration.
- **System-seam signal:** the focus area crosses a deployable unit or bounded-context boundary — RPC/HTTP clients to sibling services, message brokers, shared databases across services, cross-context model imports, contested data ownership.
- **Unfamiliar-area signal:** the focus area is large or its internal structure is not legible from a first read, so the discovery analysts would benefit from a map first.

**Classify the size.** Default to small. Escalate only when a band's signal is clearly present; when a signal is borderline, stay at the smaller band.

- **Small** *(default)* — a single module or directory, contained surface, no cross-cutting concerns: no security signal, no data signal, no DevOps signal, no system-seam signal. The concurrency signal may be present or absent.
- **Medium** — two or three adjacent subsystems, OR exactly one cross-cutting concern present (one of: security, data, or DevOps signal — a single auth surface, a single data-contract, a single operational surface).
- **Large** — more than roughly a dozen files across multiple subsystems, OR two or more cross-cutting concerns present together, OR a system-seam signal is present, OR `$size` is `large`.

**Apply the size override.** If `$size` is not `none provided`, use it as the band and skip the signal-based classification above — but still select specialists by signal (a `large` override does not dispatch agents whose domain the code never touches). A conversational override ("run this large") is equivalent to `$size`.

## Step 3: Build the Roster and Announce It

**Synthesis spine — dispatched at every size:**

- `han-core:structural-analyst` — static structure: module boundaries, coupling, dependency direction, abstractions, duplication. Emits `S#` findings.
- `han-core:behavioral-analyst` — runtime behavior: data flow, error propagation, state management, integration boundaries. Emits `B#` findings.
- `han-core:risk-analyst` — scores the `S`/`B`/`C` findings for risk of inaction (likelihood, severity, blast radius, reversibility). Emits `R#` items. Runs after the discovery wave.
- `han-core:software-architect` — synthesizes all upstream findings into intra-codebase recommendations grounded in cohesion, coupling, and SOLID, with pseudocode sketches. Emits `A#` items. Runs last.

**Signal-selected discovery specialists — added when the signal is present and the band allows:**

| Specialist | Add when | Min band |
|---|---|---|
| `han-core:concurrency-analyst` (`C#`) | Concurrency signal present | Small |
| `han-core:adversarial-security-analyst` (`SEC-###`) | Security signal present | Medium |
| `han-core:data-engineer` | Data signal present | Medium |
| `han-core:devops-engineer` (`DOR-###`) | DevOps signal present | Medium |
| `han-core:on-call-engineer` (`OCE-###`) | On-call resilience signal present: application source in the focus area has outbound calls, retry logic, queue/buffer handling, async/await code, error-handling on a production path, fan-out loops, idempotency surfaces, or new production code paths whose failure would page someone | Medium |
| `han-core:codebase-explorer` | Unfamiliar-area signal present | Large |
| `han-core:system-architect` (`SA#`) | System-seam signal present | Large |

Roster caps by band: **small** runs the spine plus `han-core:concurrency-analyst` only (3–4 agents); **medium** adds one or two of `{han-core:adversarial-security-analyst, han-core:data-engineer, han-core:devops-engineer, han-core:on-call-engineer}` by signal (4–6 agents); **large** adds the remaining signalled specialists, `han-core:codebase-explorer` if the area is unfamiliar, and `han-core:system-architect` if a system-seam signal is present (6–9 agents). If more than the cap's worth of specialists are signalled, keep the band's count and prefer the specialists covering the strongest signals; note the omitted domains in the executive summary so the user can re-run larger. When both `han-core:devops-engineer` and `han-core:on-call-engineer` are signalled, prefer `han-core:on-call-engineer` if the focus area is application source and `han-core:devops-engineer` if it is infrastructure or pipelines; include both at large size only.

`han-core:system-architect` is the only specialist that changes `han-core:software-architect`'s behavior: when `han-core:system-architect` is on the roster, `han-core:software-architect` still defers boundary-crossing findings but the report carries `han-core:system-architect`'s recommendations for them instead of only listing them as deferred.

**Announce the decision in one line before dispatching**, with per-specialist justification — for example:

> **Size: medium.** Focus area `src/auth/` spans the session and token subsystems; one security signal detected (token handling).
> **Roster (5):** `han-core:structural-analyst`, `han-core:behavioral-analyst` (spine), `han-core:concurrency-analyst` (async token refresh detected), `han-core:adversarial-security-analyst` (token + session handling), then `han-core:risk-analyst` and `han-core:software-architect`.

State git availability in the same message if git is absent ("git unavailable — churn and recency evidence will be skipped"). Proceed without a blocking confirmation; this analysis is read-only and re-runnable, so a gate here would gate a reversible operation. If the user objects to the roster, honor the adjustment.

## Step 4: Dispatch the Discovery Wave in Parallel

Launch every discovery agent on the roster in a single message with one `Agent` call per agent so they run concurrently: `han-core:structural-analyst`, `han-core:behavioral-analyst`, and whichever of `han-core:concurrency-analyst`, `han-core:adversarial-security-analyst`, `han-core:data-engineer`, `han-core:devops-engineer`, `han-core:on-call-engineer`, `han-core:codebase-explorer` are on the roster. Do **not** launch `han-core:risk-analyst`, `han-core:software-architect`, or `han-core:system-architect` here — they are the synthesis layer (Steps 6 and 7).

Each brief must contain:

- The resolved focus area and its boundary (the file/directory list from Step 1), plus the instruction to trace one layer outward.
- The driving concern from Step 1, if any.
- The resolved project-context conventions, or a note that none were found and surrounding-code inference applies.
- Git availability, so the agent knows whether churn/recency evidence is in scope.
- A **calibration directive scaled to the band**: at **small**, escalate only the clearest high-impact findings and let lower-confidence observations default down; at **medium**, surface high- and medium-impact findings; at **large**, surface the full finding set. This scales the brief to the size the same way the roster does.
- For `han-core:adversarial-security-analyst`, `han-core:data-engineer`, `han-core:devops-engineer`, and `han-core:on-call-engineer`: scope the brief to the focus area and direct findings at architectural concerns within it (its domain's structural and behavioral risk), not a general audit of the whole repository. For `han-core:on-call-engineer`, the brief must restrict findings to application source files only — infrastructure, pipelines, and IaC are out of scope.

Wait for the entire wave to return before proceeding.

## Step 5: Compile the Discovery Findings

Collect the full verbatim output from every discovery agent. Preserve every numbered item and its prefix exactly: `S#` (structural), `B#` (behavioral), `C#` (concurrency), `SEC-###` (security), `DOR-###` (devops), and `han-core:data-engineer`'s own finding IDs. Do not renumber, summarize, or drop items — the verbatim output is what the report carries and what the synthesis layer cross-references.

If `han-core:concurrency-analyst` reported "no concurrency patterns found", keep that statement verbatim — it is a valid negative result, not a missing section.

## Step 6: Dispatch the Risk Analyst

Launch `han-core:risk-analyst` with one `Agent` call. Pass it the full verbatim `S#`, `B#`, and `C#` findings (its documented input contract). Do not pass it the security, data, or devops findings — those specialists already carry their own severity and impact framing, and `han-core:risk-analyst`'s rubric is built for the structural/behavioral/concurrency findings that lack inherent severity. The agent emits `R#` items cross-referencing the upstream `S`/`B`/`C` findings with likelihood, severity, blast radius, and reversibility. Wait for it to return.

## Step 7: Dispatch the Synthesis Architects

Launch the synthesis layer with one `Agent` call per architect, in a single message when both are on the roster:

- `han-core:software-architect` — always. Pass it the full verbatim discovery output (`S`/`B`/`C` plus any `SEC-###`, `DOR-###`, and `han-core:data-engineer` findings) AND the `han-core:risk-analyst` `R#` items. It produces `A#` intra-codebase recommendations with pseudocode sketches, each cross-referencing upstream findings and naming the SOLID/cohesion/coupling concern. It defers boundary-crossing findings rather than absorbing them.
- `han-core:system-architect` — only when it is on the roster (large size, system-seam signal). Pass it the same verbatim discovery output and `R#` items, plus the `DOR-###` and `han-core:data-engineer` findings explicitly (its documented optional inputs). It produces `SA#` cross-service / bounded-context recommendations and a context-map sketch.

Wait for the synthesis layer to return.

## Step 8: Render the Report

Read [references/architectural-analysis-report-template.md](./references/architectural-analysis-report-template.md). Render it into the report draft; you present it after the readability pass in Step 11. Render rules:

1. **Fill the front matter and "How to Read" frame.** Set the focus area, the chosen size with its one-line justification, the dispatched roster, and git availability.
2. **Carry agent output verbatim.** Each analysis section is the corresponding agent's full output, unedited. The skill writes only the Executive Summary and the section prefaces.
3. **Remove sections for agents that were not dispatched.** Drop the section, remove its line from `sections_included` in the front matter, and replace its promise in the "How to Read" frame with a single line stating it was not part of this run (the same way `gap-analysis` handles optional sections). A small run with no concurrency signal has no Concurrency section; a run with no security signal has no Security section.
4. **Handle the concurrency negative result.** If `han-core:concurrency-analyst` ran but found nothing, keep the section and carry its "no concurrency patterns found" statement — this is a reported result, not an omission.
5. **Resolve system-altitude content.** If `han-core:system-architect` was dispatched, render its `SA#` recommendations in the System-Architecture Recommendations section. If it was not, omit that section and instead render `han-core:software-architect`'s deferred boundary-crossing findings under "System-level concerns deferred", with the one-line note that the user can dispatch `han-core:system-architect` separately for recommendations at that altitude.
6. **Write the Executive Summary last**, after every other section is filled: the focus area and size, the 3–5 most critical findings across all dispatched dimensions, the highest-impact recommendations, and an explicit note on any dimension that was clean or any signalled domain omitted by the band cap.

**Readability.** As you write the report's synthesized prose — the Executive Summary, the "How to Read" frame, and the section prefaces — apply [`../../references/readability-rule.md`](../../references/readability-rule.md): main point first, descriptive headings, one idea per paragraph with the first sentence carrying it, numbered lists for steps and bullets for non-sequential items, and progressive disclosure. Finding IDs and `file:line` references are citation identifiers; they survive any rewrite and self-check unchanged.

## Step 9: Rewrite the Report for Readability

Dispatch `han-core:readability-editor` with one `Agent` call to audit and rewrite the report draft against the readability rule. Pass it the draft report text, the rule path [`../../references/readability-rule.md`](../../references/readability-rule.md), and the named audience: the engineer weighing the module's design and deciding whether to change it. It preserves every fact and edits **prose regions only** — never inside code fences, pseudocode sketches, Mermaid or other diagram bodies, or finding-ID and `file:line` citation identifiers. Scope its rewrite to the report's synthesized prose (the Executive Summary, the "How to Read" frame, and the section prefaces); leave every analysis section's verbatim agent output unchanged. Apply its rewrite. This pass does not touch the discovery, risk, or architect agent spine (Steps 4–7).

## Step 10: Run the Readability Self-Check

Run the standardized readability self-check from [`../../references/readability-rule.md`](../../references/readability-rule.md) over the report's prose regions only — never inside code fences, pseudocode sketches, diagram bodies, or finding-ID / `file:line` citation identifiers. Confirm each criterion and fix any failure before presenting:

1. The opening line states the main point.
2. Each heading names its content and is not a generic label.
3. Each paragraph carries one idea and leads with it.
4. No sentence runs past the soft length flag (about thirty words) without reason.
5. No word from the vocabulary blocklist (the writing-voice profile's "Avoided words and phrases" and "AI slop to avoid" lists) is present.
6. Every fact is preserved — every claim, quantity, named entity, and stated condition or qualifier survives with its precision intact.

Fidelity wins: the standard governs how the content is said, never whether a required technical fact appears.

## Step 11: Present the Report

Present the rendered report directly in the conversation. Close by telling the user, in a short message: the size class and roster used (and why), git availability, the count of findings by dimension, and any open items — boundary-crossing concerns deferred to `han-core:system-architect`, or signalled domains the band cap omitted that would justify a re-run at a larger size.
