---
name: "ddd-analysis"
description:
  "Analyzes an existing codebase using strategic Domain-Driven Design to discover bounded contexts, surface
  ubiquitous language and semantic collisions, find places where code boundaries diverge from domain boundaries,
  and produce an evidence-backed domain and context map. Use when the goal is DDD-specific: bounded context
  discovery, ubiquitous language analysis, domain model discovery, or mapping contested ownership and
  responsibility. The entire repository is a valid scope; no module or directory must be named first. Does not
  assess architectural coupling, cohesion, or technical debt — use architectural-analysis. Does not design
  service communication, integration patterns, or deployment topology — use architectural-analysis or
  plan-a-feature. Does not refactor code, diagnose bugs, or review code quality — use refactor, investigate,
  or code-review."
arguments: size
argument-hint: "[size: small | medium | large] [focus area: module or directory to restrict analysis to]"
allowed-tools: Read, Glob, Grep, Agent, Bash(find *)
---

## Project Context

- git installed: !`which git 2>/dev/null || echo "not installed"`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A
read that returns no file is no personal configuration: continue silently. When that file or the
`project .han/config.md` probe supplies content, apply it per
[config-rule.md](../../references/config-rule.md), which governs precedence between the two files, relative-path
resolution, and what to do with a file that reads but cannot be used.

## Operating Principles

Read these before dispatching anything. They constrain every step below.

- **The entire repository is a valid scope.** No focus area is required. If the user names a module or directory,
  restrict the analysis to it; otherwise, scope is the full repository. Do not ask for a focus area when none was
  given.
- **Discovery and context model only. No migration plans.** This skill characterizes what the domain structure is.
  It does not produce recommendations for service splits, migration steps, or refactoring work. When the context
  model surfaces a decision the team wants to act on, the right next step is `han-planning:plan-a-feature` (to
  specify a change) or `han-coding:architectural-analysis` (for a code-level view of a specific module). The
  context model informs those steps; it does not replace them.
- **Analysis surface partitions organize agent work, not context proposals.** The inventory step identifies
  tractable areas for structural and behavioral analysis. These partitions are analytical conveniences — they must
  never be mentioned in any agent brief as context candidates or suggested boundaries.
- **The agents own the judgment; the skill orchestrates.** The skill resolves scope, surveys the surface, classifies
  depth, briefs the agents, collects their output, and renders the report. It does not produce DL#, CAP#, OWN#, S#,
  B#, or BCM# findings itself.
- **Negative results are valuable.** A module with no domain events and only CRUD operations is evidence, not a gap.
  Agents must not fabricate findings to fill sections.
- **Exactly one revision loop.** The skill dispatches bounded-context-modeler, then bounded-context-critic, then
  bounded-context-modeler once more with the critique. The loop is closed after the revision pass. The skill does
  not self-escalate or repeat this cycle.
- **The report template lives at
  [references/ddd-analysis-report-template.md](./references/ddd-analysis-report-template.md).** The skill renders
  that template by synthesizing agent output into each section following the template's placeholder instructions.
  It does not invent a structure inline.
- **The synthesized prose is written for a named reader.** As the skill writes each section, it invokes
  `han-communication:readability-guidance` and applies the shared standard, holding one audience above the
  writing: the engineer or product manager reading the context model and deciding what to do next.

# Run a DDD Analysis

## Step 1: Resolve Scope and Load Project Context

**Bind `$size`.** If the user passed `small`, `medium`, or `large` as the first positional argument, bind `$size`
to it. If `$size` is `none provided` and the project config supplies a `default-swarm-size` value via
`config-rule.md`, adopt that value as `$size` and note the config as the source. If no value is available from
either source, set `$size` to `medium`.

**Resolve the focus area.** Take the remaining argument and conversation context as the focus area. If a focus area
was supplied, confirm it resolves to real files using Glob and Read. If it does not resolve to actual files, stop
and ask the user to clarify before proceeding. If no focus area was supplied, the scope is the entire repository —
do not ask for one.

**Resolve project context.** If `CLAUDE.md` is present (see Project Context), read its `## Project Discovery`
section for language, framework, and convention signals. Fall back to `project-discovery.md` if present. If neither
exists, discovery agents will infer from surrounding code — note this in every agent brief.

**Note git availability.** Read the `git installed` value from Project Context. If it is empty or reads
`not installed`, git is unavailable: note this in the agent briefs and in the report.

**State the driving concern, if any.** If the user named a concern ("I think billing and subscriptions overlap",
"we need to understand where auth ends and identity begins"), capture it. Pass it to each discovery agent as a
directing note — it biases attention without narrowing scope.

## Step 2: Inventory the Analysis Surface

Survey the repository structure within the resolved scope. Use Bash and Glob to identify:

- **Top-level layout**: the first two directory levels of the source tree
  (`find {scope} -maxdepth 2 -type d | head -60`)
- **Entry points**: files named `main.*`, `index.*`, `app.*`, `server.*`, `cli.*`, or `bootstrap.*`
- **Persistence**: directories and files named `model`, `models`, `entity`, `entities`, `schema`, `schemas`,
  `migration`, `migrations`, `repository`, `repositories`
- **APIs and integrations**: directories named `routes`, `controllers`, `handlers`, `api`, `endpoints`,
  `resolvers`, `clients`, `adapters`, `connectors`, `external`, `integrations`
- **Jobs, workers, and events**: directories and files containing `job`, `worker`, `task`, `queue`, `consumer`,
  `subscriber`, `event`, `Event`

Record the inventory as a compact list of paths — this is context for later briefs, not a finding.

**For large repositories:** If the resolved scope is the entire repository and the top-level source tree contains
more than ten distinct application areas by directory, identify 3-5 meaningful partitions based on the directory
structure and names (for example: `billing`, `fulfillment`, `identity`). Include these partitions in the
`han-core:structural-analyst` and `han-core:behavioral-analyst` briefs in Step 4 to keep those analyses
tractable. These partitions are not context candidates and must not be named as such.

## Step 3: Classify Depth

**Depth bands control the calibration directive passed to the discovery agents.** They do not change which agents
are dispatched; this skill always dispatches exactly five discovery agents.

- **Small** — surface scan. For language, capability, and ownership agents: highest-frequency terms, most
  obvious collisions, commands and domain events only, authority mapping and obvious contestation only. For
  structural and behavioral agents: top-level module boundaries and primary entry points only. Appropriate for
  an initial orientation pass or a very large repository.
- **Medium** _(default)_ — full analysis. All dimensions for language, capability, and ownership agents; full
  static structure and behavioral analysis. Appropriate for most repositories.
- **Large** — exhaustive pass. All dimensions for language, capability, and ownership agents with emphasis on
  cross-module collision detection, workflow discovery, and contestation. For structural and behavioral agents:
  full analysis with emphasis on inter-module coupling, cross-module data flow, and integration boundaries.
  Appropriate for large, long-lived repositories or when the team needs a comprehensive model before a major
  architectural decision.

## Step 4: Announce and Dispatch Discovery Agents

**Announce in one line before dispatching:**

> **Scope: {entire repository | focus area path}. Depth: {small | medium | large}.** Dispatching
> `han-ddd:domain-language-analyst`, `han-ddd:business-capability-analyst`,
> `han-ddd:domain-ownership-analyst`, `han-core:structural-analyst`, and `han-core:behavioral-analyst` in
> parallel. Git {available | unavailable}.

State any driving concern the user supplied. Proceed without a blocking confirmation — this analysis is
read-only and re-runnable.

**Dispatch all five agents with concurrent `Agent` calls.** Each agent reads the codebase independently.

Brief for `han-ddd:domain-language-analyst`:

- The resolved scope and the instruction to work across the full scope.
- The inventory summary from Step 2.
- Calibration: small — highest-frequency terms and most obvious collisions only; medium — full vocabulary
  inventory and all six dimensions; large — all six dimensions with emphasis on exhaustive cross-module semantic
  collision detection.
- The resolved project-context conventions, or a note that none were found.
- The driving concern, if any.
- Reminder: language-signal evidence only — no bounded-context proposals, no service-split recommendations.
- Ask the agent to prefix findings `DL1`, `DL2`, … exactly.

Brief for `han-ddd:business-capability-analyst`:

- The resolved scope and the instruction to work across the full scope.
- The inventory summary from Step 2.
- Calibration: small — commands and domain events only; medium — all six dimensions; large — all six dimensions
  with emphasis on cross-module workflow discovery and capability-boundary ambiguity.
- The resolved project-context conventions, or a note that none were found.
- The driving concern, if any.
- Reminder: capability evidence only — no bounded-context proposals, no service-split recommendations.
- Ask the agent to prefix findings `CAP1`, `CAP2`, … exactly.

Brief for `han-ddd:domain-ownership-analyst`:

- The resolved scope and the instruction to work across the full scope.
- The inventory summary from Step 2.
- Calibration: small — authority mapping and most obvious contestation signals only; medium — all six
  dimensions; large — all six dimensions with emphasis on cross-module consistency coupling and exhaustive
  contestation detection.
- The resolved project-context conventions, or a note that none were found.
- The driving concern, if any.
- Reminder: ownership evidence only — no bounded-context proposals, no service-split recommendations.
- Ask the agent to prefix findings `OWN1`, `OWN2`, … exactly.

Brief for `han-core:structural-analyst`:

- The resolved scope. If analysis partitions were identified in Step 2, include them and ask the agent to
  cover each partition in its analysis rather than the full repository tree.
- Calibration: small — top-level module boundaries and primary coupling patterns only; medium — full static
  structure analysis; large — full analysis with emphasis on inter-module coupling and duplication.
- Context that these findings will be used as structural evidence for strategic DDD analysis — no service-split
  or refactoring recommendations.
- Ask the agent to prefix findings `S1`, `S2`, … exactly.

Brief for `han-core:behavioral-analyst`:

- The resolved scope. If analysis partitions were identified in Step 2, include them and ask the agent to
  cover each partition in its analysis.
- Calibration: small — entry points and primary workflows only; medium — full behavioral analysis; large —
  full analysis with emphasis on cross-module data flow, error propagation, and integration boundaries.
- Context that these findings will be used as behavioral evidence for strategic DDD analysis — no refactoring
  recommendations.
- Ask the agent to prefix findings `B1`, `B2`, … exactly.

Wait for all five agents to return before proceeding.

## Step 5: Compile Discovery Findings

Collect the full verbatim output from all five discovery agents. Preserve every DL#, CAP#, OWN#, S#, and B#
item and its prefix exactly. Do not renumber, summarize, or drop items — the verbatim output is what the report
carries and what the modeler cross-references.

If any agent reported "no candidates found" or "no collisions detected" for a dimension, keep that statement
verbatim — it is a valid negative result.

## Step 6: Dispatch Bounded Context Modeler — First Pass

**Dispatch `han-ddd:bounded-context-modeler` with one `Agent` call.** The brief must contain:

- The full verbatim DL# findings and Language Summary from the domain-language-analyst.
- The full verbatim CAP# findings and Capability Summary from the business-capability-analyst.
- The full verbatim OWN# findings and Ownership Summary from the domain-ownership-analyst.
- The full verbatim S# findings from the structural-analyst.
- The full verbatim B# findings from the behavioral-analyst.
- A calibration directive matched to the depth band: small — top 3-5 most strongly-evidenced CURRENT contexts;
  medium — all convergence zones supported by at least two independent evidence types; large — exhaustive,
  include all SPECULATIVE candidates with meaningful evidence from at least two types.
- Reminder: semantic context model only — no refactoring, migration, microservices, or topology recommendations.

Wait for the modeler to return. Capture the BCM# entries and Bounded Context Model Summary as the first-pass model.

## Step 7: Dispatch Bounded Context Critic

**Dispatch `han-ddd:bounded-context-critic` with one `Agent` call.** The brief must contain:

- The full verbatim BCM# entries and Bounded Context Model Summary from Step 6.
- The full verbatim DL# findings and Language Summary from the domain-language-analyst.
- The full verbatim CAP# findings and Capability Summary from the business-capability-analyst.
- The full verbatim OWN# findings and Ownership Summary from the domain-ownership-analyst.
- The full verbatim S# findings from the structural-analyst.
- The full verbatim B# findings from the behavioral-analyst.
- Reminder: evaluation only — no context redesign, no replacement context map, no architectural or refactoring
  recommendations.

Wait for the critic to return. Capture the BCR# entries and Bounded Context Model Critique Summary.

## Step 8: Dispatch Bounded Context Modeler — Revision Pass

**Dispatch `han-ddd:bounded-context-modeler` a second time with one `Agent` call.** This is the final and only
revision pass. The brief must contain:

- The full verbatim BCM# entries and Bounded Context Model Summary from the first pass (Step 6).
- The full verbatim BCR# entries and Bounded Context Model Critique Summary from the critic (Step 7).
- The full verbatim DL#, CAP#, OWN#, S#, and B# evidence from Step 5.
- An explicit instruction: address every criticism the BCR# entries support with discovery evidence; reject every
  criticism that the BCR# entries acknowledge is unsupported or requires domain-expert input to resolve; preserve
  every BCM# entry the critic rated strong or plausible without modification unless the critique identified
  specific counter-evidence.
- Reminder: produce the final context model only — no refactoring, migration, or topology recommendations.

Wait for the modeler to return. This output is the final BCM# model. The revision loop is now closed — do not
dispatch the modeler or critic again.

## Step 9: Render the Report

Read [references/ddd-analysis-report-template.md](./references/ddd-analysis-report-template.md). Render it into the
report draft. Render rules:

1. **Fill the scope, depth, and git-availability header** from Step 1.
2. **Synthesize each section following the template's placeholder instructions.** Most sections require
   synthesis from agent output, not verbatim carry. Derive each section from its designated source: Domain
   Landscape and Business Capabilities from CAP# and OWN# summaries; Ubiquitous Language from DL# findings;
   Current/Latent/Speculative sections from BCM# entries sorted by status; Boundary Problems from BCR# failure
   modes and OWN# contestation findings; Context Map from BCM# relationship fields where evidence exists;
   Context Details by expanding each CURRENT and LATENT BCM# entry's fields verbatim; Rejected or Weak
   Candidates from BCR# weak and reject verdicts; Questions for Domain Experts consolidated and deduplicated
   from BCR# domain-expert questions; Evidence Index as a traceable per-ID-type index of all DL#, CAP#, OWN#,
   S#, and B# findings with file paths and which sections cite them.
3. **Remove template placeholder instructions** — the text in curly braces is guidance to the skill.
   Remove it when filling each section.
4. **Handle empty sections with their fallback text.** Do not omit a section entirely.
5. **Write the Executive Summary last**, after every other section is complete.

**Readability.** Invoke `han-communication:readability-guidance` to surface the shared readability standard into
your context. Apply it to every synthesized section as you write: main point first, descriptive headings, one
idea per paragraph, and progressive disclosure. The finding IDs (BCM#, BCR#, DL#, CAP#, OWN#, S#, B#) and
file-path references are citation identifiers; they survive any rewrite and self-check unchanged.

## Step 10: Rewrite the Report for Readability

Dispatch `han-communication:readability-editor` with one `Agent` call to audit and rewrite the report draft
against the shared readability standard. Pass it the draft report text and the named audience: the engineer or
product manager reading the context model and deciding what to do next; the editor reads han-communication's own
canonical rule, so pass no rule path. It preserves every fact and edits **prose regions only** — never inside
code fences, diagram bodies, or finding-ID and file-path citation identifiers. Scope its rewrite to all
synthesized prose sections — Executive Summary, Domain Landscape, Ubiquitous Language, Business Capabilities,
the overview paragraphs in Current/Latent/Speculative sections, Boundary Problems, Rejected or Weak Candidates,
Questions for Domain Experts, and Evidence Index summaries. Leave Context Details unchanged (it carries BCM#
field values directly) and do not edit within the Context Map Mermaid block. Apply its rewrite.

## Step 11: Run the Readability Self-Check

Run the standardized readability self-check (the shared standard is in your context from the
`readability-guidance` invocation in Step 9) over the report's prose regions only — never inside code fences,
diagram bodies, or finding-ID / file-path citation identifiers. Confirm each criterion and correct any failure
before presenting:

- Main point first
- Descriptive headings
- One idea per paragraph
- Sentence length
- Common words with no blocklisted words; explanation for every unfamiliar term
- Every fact preserved

## Step 12: Present the Report

Present the rendered report directly in the conversation. Close by telling the user, in a short message:
- The scope and depth used, and whether git was available.
- The context model: N CURRENT, N LATENT, N SPECULATIVE contexts; verdict distribution from the critique
  (strong: N, plausible: N, weak: N, reject: N).
- The most consequential domain-expert question from the Questions for Domain Experts section.
- What to run next: `han-planning:plan-a-feature` to specify a change, or `han-coding:architectural-analysis`
  to examine a module's code-level structure. If the resulting contexts suggest cross-service topology or
  integration design, `han-core:system-architect` is the appropriate next agent after the team has confirmed
  which boundaries to invest in.
