---
name: "investigate"
description: >
  Evidence-based investigation of issues, bugs, API calls, integrations, and other aspects of
  software development that need a deep dive to find the root cause and solutions. Use when you
  need to debug, troubleshoot, diagnose, or figure out why something is broken. Does not review
  code for quality or style — use code-review for auditing changes or post-code-review-to-pr for
  posting review feedback to GitHub. Does not assess architectural health or structural risk — use
  architectural-analysis for architectural concerns. Does not research open-ended options, prior
  art, or how something works when nothing is broken — use research for that. Does not capture
  feedback on Han's own skills — use han-feedback for that.
allowed-tools: Read, Glob, Grep, Agent
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Investigation Approach

- Trace backward from symptoms — don't guess, follow the code.
- Launch parallel `han.core:evidence-based-investigator` agents for different angles simultaneously — one for the error path, one for the data flow, one for recent changes.
- Add one or more specialist analysts **in parallel with** the investigators when the bug type calls for it (concurrency, data flow across boundaries, database or query behavior). Specialist analysts find root causes generalists miss.
- The `han.core:adversarial-validator` agent handles all three validation strategies (challenge evidence, challenge fix, challenge assumptions) internally.
- Apply the evidence rule from [../../references/evidence-rule.md](../../references/evidence-rule.md) to every finding. Codebase findings (file path, line number, log line, test output) carry the trust-class label "codebase" and stand on their citation. Web-source context (RFCs, vendor docs, Stack Overflow, blog posts) carries the trust-class label "web" and is subject to the corroboration gate when it drives the proposed fix. When the investigation hits a point where no evidence at any tier resolves a question, label the no-evidence state rather than guessing.

# Investigate

## Step 1: Research and Investigation

### Always dispatch

Launch at least 2 `han.core:evidence-based-investigator` agents in parallel, each investigating from a different angle — for example, one tracing the error path and another following the data flow.

### Conditional specialist dispatch

Classify the bug from the user's symptom description before launching. Skip any specialist that does not apply. Dispatch every applicable specialist in parallel with the `han.core:evidence-based-investigator` agents in the same message.

1. **Launch han.core:concurrency-analyst** — when the symptom involves intermittent failures, race conditions, deadlocks, ordering issues, stale reads after writes, timeouts, dropped messages, or anything that only reproduces under load or concurrent users. Prompt: "Investigate the concurrency and async behavior of the code paths implicated by this symptom: {symptom}. Focus on race conditions, lock ordering, shared-resource contention, async error handling, and missing cancellation/timeout handling. Return numbered findings keyed to file paths and line numbers."

2. **Launch han.core:behavioral-analyst** — when the symptom involves data transformed wrong, values lost between modules, errors swallowed, state mutated unexpectedly, or integration boundaries passing bad data. Prompt: "Trace the data flow for the code paths implicated by this symptom: {symptom}. Focus on data transformation across module boundaries, error propagation and loss, state mutation, and integration-boundary assumptions. Return numbered findings keyed to file paths and line numbers."

3. **Launch han.core:data-engineer** — when the symptom involves wrong data in the database, slow queries, N+1, lock contention, migration failures, unbounded scans, lost data, broken referential integrity, or isolation-level surprises. Prompt: "Investigate the schema, queries, migrations, and data-access code implicated by this symptom: {symptom}. Focus on the specific data-engineering principles violated and the concrete data-level impact. Return numbered findings keyed to file paths, line numbers, and schema or migration references."

After all agents complete (investigators and specialists), compile an **evidence summary** — a numbered list of concrete findings (E1, E2, E3, ...) that will feed into the root cause analysis. Specialist findings go into the same E-series list, tagged with the specialist's domain (e.g., `E3 (concurrency)`).

## Step 2: Document Root Cause

Write to the plan file using the template at [template.md](./references/template.md). Fill in these sections:

1. **Problem Statement** — document the symptoms, expected behavior, conditions under which it occurs, and impact.
2. **Evidence Summary** — consolidate evidence from all agents into a unified numbered list (E1, E2, E3, ...); merge duplicates and resolve conflicting findings while preserving each item's output structure.
3. **Root Cause Analysis** — write a one-to-three sentence summary of the root cause, then a detailed analysis referencing evidence items by number (e.g., "The handler passes an unvalidated ID (E1) to the service layer, which assumes non-nil (E3)").

## Step 3: Plan the Fix

Resolve project config: read CLAUDE.md's `## Project Discovery` section for docs, ADR, and coding-standards directories; fall back to project-discovery.md; fall back to Glob defaults (`docs/`, `docs/adr/`, `docs/coding-standards/`). Search found directories for relevant standards, ADRs, and docs. Also check `CLAUDE.md`, `AGENTS.md`, and linter/formatter configs for coding standards. If none found, infer conventions from surrounding code.

Design a fix that **directly addresses the root cause** from Step 2 — fix the underlying problem, not symptoms. Then fill in the remaining sections of [template.md](./references/template.md) in the plan file:

1. **Coding Standards Reference** — for each applicable standard, document what the standard is, where it was found (file path, ADR number, or "inferred from surrounding code"), and which files or changes it governs. If none were found, note that explicitly and document inferred patterns.
2. **Planned Fix** — write a one-sentence summary, then for each file that needs to change: full path from repo root, what will be modified/added/removed, which evidence items (E1, E2, ...) justify the change, which coding standards apply, and implementation specifics (new function signatures, changed logic, updated tests).

## Step 4: Validation (CRITICAL)

Launch `han.core:adversarial-validator` agents and pass them the complete evidence summary (all E1-EN items with full code snippets), the root cause analysis, and the planned fix with all file changes. Do not summarize — the validator needs verbatim detail to challenge effectively. Their job is adversarial — they must actively try to disprove the findings and break the fix.

When counter-evidence is found, document it as a validation finding (V1, V2, ...), investigate whether it changes the root cause analysis, adjust the plan (evidence, root cause, and fix sections) as needed, and fill in the **Adjustments Made** section listing what changed and which validation finding triggered each change. When counter-evidence is not found, document what was checked and why it supports the original findings, recording it as a validation finding confirming the analysis.

After all validation is complete, incorporate the `han.core:adversarial-validator` agents' Confidence Assessment and Remaining Risks into the plan.

## Step 5: Final Summary and User Review

Add the final summary to the plan file with one sentence each for: root cause (what caused the problem), fix (what the planned changes will do), why correct (reference the strongest evidence), validation outcome (what validation confirmed or changed), and remaining risks (reference the Confidence Assessment).

Present the plan file to the user for approval. The user can approve the plan (triggering implementation) or provide feedback for revisions.

