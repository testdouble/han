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
allowed-tools: Read, Glob, Grep, Agent, Write, Bash(find *), Bash(date *), Bash(mkdir *), Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- git installed: !`which git 2>/dev/null || echo "not installed"`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
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

**Resolve the run folder.** Determine where this run's artifacts will land before dispatching any agent:

1. **Configured `output-directory`**: When the config read above supplied an `output-directory`, resolve it per
   [config-rule.md](../../references/config-rule.md) (relative path resolves against the file that declared it;
   `~/` expands to home; full path is used as-is). Write the run folder beneath that resolved base.
2. **No configured value**: Write outside the repository — use `${TMPDIR:-/tmp}` as the base. This keeps an
   unconfigured analysis out of version control, matching the same principle that governs `code-overview`.

Run `date +%Y%m%d-%H%M%S` via Bash to obtain a timestamp suffix. Name the run folder `ddd-analysis-{timestamp}`
inside the resolved base. If that directory already exists, check for `-2`, `-3` suffixes until the name is free.
Run `mkdir -p {run_folder}/discovery {run_folder}/synthesis` to create the full directory tree. Set `$run_folder`
to the absolute resolved path — this value threads through every subsequent step.

If the resolved base cannot be written (permission error, path does not exist), fall back to
`${TMPDIR:-/tmp}/ddd-analysis-{timestamp}` and record the failed path so Step 12 can name it.

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
- Artifact path: write complete findings to `$run_folder/discovery/domain-language.md` and return only the path
  written, the total DL# count, and a two-sentence summary of the highest-value signals.

Brief for `han-ddd:business-capability-analyst`:

- The resolved scope and the instruction to work across the full scope.
- The inventory summary from Step 2.
- Calibration: small — commands and domain events only; medium — all six dimensions; large — all six dimensions
  with emphasis on cross-module workflow discovery and capability-boundary ambiguity.
- The resolved project-context conventions, or a note that none were found.
- The driving concern, if any.
- Reminder: capability evidence only — no bounded-context proposals, no service-split recommendations.
- Ask the agent to prefix findings `CAP1`, `CAP2`, … exactly.
- Artifact path: write complete findings to `$run_folder/discovery/business-capabilities.md` and return only the
  path written, the total CAP# count, and a two-sentence summary of the strongest behavioral signals.

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
- Artifact path: write complete findings to `$run_folder/discovery/domain-ownership.md` and return only the path
  written, the total OWN# count, and a two-sentence summary of the most significant authority signals.

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

## Step 5: Persist Discovery Artifacts

The three han-ddd discovery agents have written their own artifacts and returned the paths. Use the Read tool to
confirm each reported path exists. If an artifact is absent, note the shortfall — the skill continues without it,
but Step 12 must name the missing file.

The han-core agents do not write their own artifacts. Write their verbatim returned output now:

- Write the structural-analyst's complete verbatim output to `$run_folder/discovery/structural.md` using the
  Write tool. Preserve every S# finding and its prefix exactly, including any "no findings" statements.
- Write the behavioral-analyst's complete verbatim output to `$run_folder/discovery/behavioral.md` using the
  Write tool. Preserve every B# finding and its prefix exactly, including any "no findings" statements.

The five discovery artifacts are now stable at:

- `$run_folder/discovery/domain-language.md`
- `$run_folder/discovery/business-capabilities.md`
- `$run_folder/discovery/domain-ownership.md`
- `$run_folder/discovery/structural.md`
- `$run_folder/discovery/behavioral.md`

Do not carry their contents transiently in context. All downstream stages read from these paths directly.

## Step 6: Dispatch Bounded Context Modeler — First Pass

**Dispatch `han-ddd:bounded-context-modeler` with one `Agent` call.** The brief must contain:

- The five discovery artifact paths from Step 5. Instruct the agent to read each file with the Read tool before
  synthesizing — do not paste their contents into the brief.
- A calibration directive matched to the depth band: small — top 3-5 most strongly-evidenced CURRENT contexts;
  medium — all convergence zones supported by at least two independent evidence types; large — exhaustive,
  include all SPECULATIVE candidates with meaningful evidence from at least two types.
- Reminder: semantic context model only — no refactoring, migration, microservices, or topology recommendations.
- Synthesis artifact path: write complete output (all BCM# entries, IBN# entries, and the Bounded Context Model
  Summary) to `$run_folder/synthesis/context-model-initial.md` and return only the path written, the BCM# count
  by status, and the Bounded Context Model Summary.

Wait for the modeler to return. Capture the reported path as `$context_model_initial`. Use Read to verify the file
was written. This is the first-pass model.

## Step 7: Dispatch Bounded Context Critic

**Dispatch `han-ddd:bounded-context-critic` with one `Agent` call.** The brief must contain:

- The path `$context_model_initial`. Instruct the agent to read this file with the Read tool before evaluating.
- The five discovery artifact paths from Step 5. Instruct the agent to read each with the Read tool when
  verifying specific claims against evidence — do not paste their contents into the brief.
- Reminder: evaluation only — no context redesign, no replacement context map, no architectural or refactoring
  recommendations.
- Synthesis artifact path: write complete output (all BCR# entries and the Bounded Context Model Critique Summary)
  to `$run_folder/synthesis/critique.md` and return only the path written, the BCR# count with verdict
  distribution, and the Bounded Context Model Critique Summary.

Wait for the critic to return. Capture the reported path as `$critique`. Use Read to verify the file was written.

## Step 8: Dispatch Bounded Context Modeler — Revision Pass

**Dispatch `han-ddd:bounded-context-modeler` a second time with one `Agent` call.** This is the final and only
revision pass. The brief must contain:

- The path `$context_model_initial`. Instruct the agent to read this file with the Read tool.
- The path `$critique`. Instruct the agent to read this file with the Read tool.
- The five discovery artifact paths from Step 5. Instruct the agent to read any file it needs to verify
  synthesis claims — do not paste their contents into the brief.
- An explicit instruction: address every criticism the BCR# entries support with discovery evidence; reject every
  criticism that the BCR# entries acknowledge is unsupported or requires domain-expert input to resolve; preserve
  every BCM# entry the critic rated strong or plausible without modification unless the critique identified
  specific counter-evidence.
- Reminder: produce the final context model only — no refactoring, migration, or topology recommendations.
- Synthesis artifact path: write complete revised output (all BCM# entries, IBN# entries, and the Bounded Context
  Model Summary) to `$run_folder/synthesis/context-model-final.md` and return only the path written and a brief
  revision summary (what changed from the first pass and why).

Wait for the modeler to return. Capture the reported path as `$context_model_final`. Use Read to verify the file
was written. The revision loop is now closed — do not dispatch the modeler or critic again.

## Step 8.5: Validate Identifier Cross-References

Before rendering the report, run a deterministic cross-reference check on the final context model. This step uses
Read and Grep only — no new agent is dispatched.

1. Read `$context_model_final`. Extract every evidence identifier cited in BCM# entries and DC# entries — all
   DL#, CAP#, OWN#, S#, and B# references appearing in Evidence fields.
2. For each extracted identifier, use Grep to verify it appears in the corresponding discovery artifact:
   - DL# → `$run_folder/discovery/domain-language.md`
   - CAP# → `$run_folder/discovery/business-capabilities.md`
   - OWN# → `$run_folder/discovery/domain-ownership.md`
   - S# → `$run_folder/discovery/structural.md`
   - B# → `$run_folder/discovery/behavioral.md`
3. Also verify that no CURRENT or LATENT BCM# entry's Owns, Consumes, Does not own, Responsibilities, or
   Relationships field references a SPECULATIVE BCM# entry by its BCM# identifier as an established participant
   (SPECULATIVE isolation rule). Code-level observations about areas whose bounded-context status is speculative
   must be described factually without using the SPECULATIVE BCM# identifier.
4. Verify that DC# entries are not listed under any CURRENT, LATENT, or SPECULATIVE section — DC# must not
   carry a BCM# status.
5. Evaluate results. Identifier-integrity errors (step 2) and SPECULATIVE isolation violations (step 3) are
   hard failures: if any are found, do not proceed to Step 9. Preserve all artifacts written to this point.
   Report validation failure, naming each error type and count. Do not report "Analysis complete." Do not emit
   successful next steps. Stop. DC# misclassification errors (step 4) are recorded but do not halt the run;
   include them in the Step 12 closing message if none of the hard failures stopped the run.

## Step 9: Render the Report

Read `$context_model_final` to load the final BCM# model before rendering. Read
[references/ddd-analysis-report-template.md](./references/ddd-analysis-report-template.md). Render it into the
report draft. Render rules:

1. **Fill the scope, depth, and git-availability header** from Step 1.
2. **Synthesize each section following the template's placeholder instructions.** Most sections require
   synthesis from agent output, not verbatim carry. Derive each section from its designated source: Domain
   Landscape and Business Capabilities from CAP# and OWN# summaries (read from the discovery artifacts);
   Ubiquitous Language from DL# findings (read from the discovery artifact); Current/Latent/Speculative sections
   from BCM# entries in `$context_model_final` sorted by status; Boundary Problems from BCR# failure modes in
   `$critique` and OWN# contestation findings; Context Map from BCM# relationship fields where evidence exists;
   Context Details by expanding each CURRENT and LATENT BCM# entry's fields verbatim from `$context_model_final`;
   Rejected or Weak Candidates from BCR# weak and reject verdicts; Questions for Domain Experts consolidated and
   deduplicated from BCR# domain-expert questions.
3. **Evidence / Analysis Artifacts**: list the artifact files — five discovery and three synthesis (initial
   context model, final context model, and the rendered report written to
   `$run_folder/synthesis/ddd-analysis.md`; omit the intermediate critique from this section). For each:
   filename, absolute path, and finding type with count from the agents' return summaries.
4. **Remove template placeholder instructions** — the text in curly braces is guidance to the skill.
   Remove it when filling each section.
5. **Handle empty sections with their fallback text.** Do not omit a section entirely.
6. **Write the Executive Summary last**, after every other section is complete.

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
Questions for Domain Experts, and Evidence / Analysis Artifacts. Leave Context Details unchanged (it carries BCM#
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

## Step 11.5: Validate Post-Render Registry Completeness

After the readability rewrite and self-check, verify that the rendered report contains every entry from the
canonical final model. This step uses Read and Grep only — no new agent is dispatched.

1. Read `$context_model_final`. Extract the canonical registry:
   - Every BCM# identifier, its canonical name, and its status (CURRENT, LATENT, or SPECULATIVE).
   - Every DC# identifier and its canonical name.
   - Every IBN# identifier and its canonical name.
2. For each entry in the canonical registry, verify that the rendered report contains it in the correct section:
   - CURRENT BCM# entries: must each appear exactly once in the "Current Bounded Contexts" section with the
     identifier visible.
   - LATENT BCM# entries: must each appear exactly once in the "Latent Bounded Contexts" section with the
     identifier visible.
   - SPECULATIVE BCM# entries: must each appear exactly once in the "Speculative Context Hypotheses" section
     with the identifier visible.
   - DC# entries: must each appear exactly once in the "Domain Concerns" section with the identifier visible.
     If the canonical model produced no DC# entries, the Domain Concerns section must be absent.
   - IBN# entries: must each appear exactly once in the "Integration Boundaries" section with the identifier
     visible. If the canonical model produced no IBN# entries, the section's fallback text must appear instead
     of fabricated entries.
3. If any entry is missing from the correct section, or appears with the wrong identifier, this is a
   post-render integrity failure. Re-render every affected section by reading the BCM#, DC#, or IBN# entry
   directly from `$context_model_final` and replacing the defective section text before presenting. This is a
   hard gate: do not present the report until set equality holds.
4. If all entries are present and correctly placed, proceed to Step 12 with no changes.

Unlike the soft gate in Step 8.5, this check must block presentation until resolved. An entry dropped during
readability editing is a correctness failure, not a style issue.

## Step 12: Write Report to Disk and Run Domain Visualizer

**Write the rendered report to disk.** Use the Write tool to write the complete rendered report to
`$run_folder/synthesis/ddd-analysis.md`. This persists the reader-facing report as a stable artifact and
provides the domain visualizer with the consolidated Questions for Domain Experts section.

**Create the visuals directory.** Run `mkdir -p $run_folder/visuals` via Bash.

**Dispatch `han-ddd:domain-visualizer` with one `Agent` call.** The brief must contain:

- All eight artifact paths (instruct the agent to read each with the Read tool before producing any visual):
  - `$run_folder/synthesis/ddd-analysis.md` — the rendered report
  - `$context_model_final` — the canonical context model
  - `$critique` — the BCR# evaluations and domain-expert questions
  - `$run_folder/discovery/domain-language.md`
  - `$run_folder/discovery/business-capabilities.md`
  - `$run_folder/discovery/domain-ownership.md`
  - `$run_folder/discovery/structural.md`
  - `$run_folder/discovery/behavioral.md`
- Output path: write all visual artifacts to `$run_folder/visuals/`.
- Reminder: presentation only — no discovery, no classification, no model changes, no target architecture,
  no directive language prescribing structural or implementation changes.

Wait for the visualizer to return. On success, capture:

- `$visual_paths`: the list of generated artifact paths
- `$visual_types`: the list of generated visual types
- `$visual_skips`: any visuals that were skipped and the reason

**Failure handling.** If the visualizer fails or returns an error, record the failure message as
`$visual_failure`. Do not invalidate the DDD model or the rendered report. Proceed to Step 13 either way.
Visual-generation failure must never affect the underlying DDD model's validity.

## Step 13: Present the Report

Present the rendered report directly in the conversation. Close by telling the user, in a short message:

- The scope and depth used, and whether git was available.
- The context model: N CURRENT, N LATENT, N SPECULATIVE contexts; verdict distribution from the critique
  (strong: N, plausible: N, weak: N, reject: N).
- The analysis artifact directory: `$run_folder` (or the fallback path if the configured destination failed,
  naming which path failed and which fallback was used instead).
- Any identifier cross-reference errors found in Step 8.5 (omit this line if none were found).
- Any missing discovery artifacts from Step 5 (omit this line if all five were present).
- The most consequential domain-expert question from the Questions for Domain Experts section.
- Analysis Visuals: when visual generation succeeded, list the visual types generated and the
  `$run_folder/visuals/` path. When generation failed, note the failure and that the DDD model is unaffected.
- What to run next: `han-coding:architectural-analysis` to examine a named module's code-level structure, or
  a narrower `/ddd-analysis` restricted to a single focus area. If the team has gathered domain-expert input
  on the open questions above and wants to specify next steps for a confirmed boundary,
  `han-planning:plan-a-feature` starts that conversation. If the contexts raise cross-service or integration
  questions, `han-core:system-architect` provides a topology read after the team has confirmed which boundaries
  are real. Do not assert that any boundary violation can or should be fixed, prescribe a correction, or
  recommend extraction, refactoring, or migration in this closing message.
