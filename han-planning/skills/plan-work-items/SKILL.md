---
name: "plan-work-items"
description: >
  Break a trusted implementation plan (or other provided context) into
  independently-grabbable, atomic work items, written to a single
  work-items.md file. Use when the user wants to convert a plan into work
  items, create implementation tickets or tasks, divide a plan into work
  units, or break the plan down into grabbable pieces. Do not use when there
  is no implementation plan yet or the plan is not yet trusted — use
  plan-implementation to produce the plan or iterative-plan-review to harden
  it first. Does not sequence work into demoable delivery phases — use
  plan-a-phased-build for that. Does not write code — use tdd to implement a
  work item.
argument-hint: "[implementation plan path or feature name, optional; output folder, optional]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(mkdir *)
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- feature-implementation-plan.md: !`find . -maxdepth 5 -name "feature-implementation-plan.md" -type f`

# Plan Work Items

Break an implementation plan into vertical slices (tracer bullets) and write them as work items to a single `work-items.md` file.

This skill mostly coordinates: locating the plan or context, resolving where the file goes, printing the breakdown, writing the work-items file. It runs autonomously end to end. Step 5 is where the judgement comes into play, in dividing up the plan.

## Operating Principles

- **Run autonomously.** After the initial request, run end to end without pausing for human confirmation. When a decision has a reasonable default (where the file goes, how the plan divides), make it, state it, and proceed. Print the work item breakdown for visibility, but never gate on approval to continue. Stop for the user only when the skill genuinely cannot continue without input — there is no plan or context to work from at all.
- **One file, no repository awareness.** This skill produces exactly one `work-items.md`. It does not split work by repository, count repositories, or reason about cross-repository integration. The breakdown is driven only by the plan or context it is given.
- **Save incrementally — never lose work.** Write the work-items file as soon as the title and intro are drafted, then append each work item as it is finalized. Do not buffer the whole document in conversation memory and write it at the end.

## Rules

- Do NOT modify, annotate, or comment on the source implementation plan or context. It is read-only input.
- Each work item is a **vertical slice**: a narrow but complete path through the relevant layers (schema, API, UI, tests) that is demoable or verifiable on its own. Not a layer, not a stub.
- Every work item body MUST link the reference artifacts an implementer needs: API/event contracts, design frames, schema docs, runbooks, ADRs, coding standards. A work item that consumes an HTTP endpoint or event payload MUST link the contract section that defines it.
- UI work items, when the plan folder has a `ui-designs/` subfolder, MUST reference the relevant design screenshots by a relative path from the work-items file to the screenshot. See [references/work-item-template.md](./references/work-item-template.md).
- `Depends on` lists other work items **in this same file** that must complete first, or `None`.
- NEVER include process artifacts in work item bodies or the preamble. Excluded categories: iteration histories, decision logs, review findings, team findings, facilitation summaries, gap analyses, and anything under an `artifacts/` subfolder of the plan that is not a contract or design reference. Restate plan-level decisions inline in the work item with `See plan: D-N` as the breadcrumb. Full include/exclude list in [references/reference-artifact-inventory.md](./references/reference-artifact-inventory.md).

## Process

### 1. Locate the implementation plan or context

The breakdown is built from an implementation plan when one exists, or from whatever context the user provided when one does not.

- If the user provided a file path, read it. If a feature name was given, look for `docs/features/<feature-name>/feature-implementation-plan.md` (or the equivalent under the project's documentation root).
- If nothing was provided, check for existing plans (the injected `feature-implementation-plan.md` results above help here). If there is exactly one, use it. If there are multiple, use the most recently updated one. If there are none, use whatever plan-like context the user supplied inline in the conversation.
- If the plan references other files (a feature specification, a contract file, an ADR), read those too. The plan content is the union of all these sources.
- If there is still no usable plan or context, ask the user — in one short message — for the implementation plan file path or the context to break down. Do not proceed without it.

### 2. Resolve the output location

The skill writes exactly one file: `{folder}/work-items.md`.

Resolve `{folder}` in this order:

1. If the user specified an output folder, use it.
2. If the plan is a file, default to the same folder as the plan file.
3. If there is no plan file but the provided context points at a folder or document location, write next to that.
4. Otherwise, make a best educated guess based on the provided context: choose a folder of **2 to 4 words** in kebab-case, placed under an existing documentation root surfaced via CLAUDE.md, `project-discovery.md`, or a Glob fallback (`docs/features/<feature>/`, `docs/plans/`, `docs/`). State the chosen folder in one short line and proceed; do not wait for confirmation.

If `work-items.md` already exists in the chosen folder, do not silently overwrite it and do not stop to ask: write to a timestamp-suffixed name (e.g., `work-items-2026-05-18.md`) and state which file was written. The existing file is preserved.

### 3. Explore the codebase when needed

If the plan references existing code or boundaries that aren't in your context, explore the affected code. Skip exploration if the plan is self-contained and the boundaries are already clear.

### 4. Inventory reference artifacts

Before drafting work items, list every artifact an implementer of those work items will need. See [references/reference-artifact-inventory.md](./references/reference-artifact-inventory.md) for the include list, exclude list, and screenshot-to-work-item mapping rules.

If an expected artifact is missing (for example, the plan touches an HTTP boundary but no contract file exists), note it in the breakdown report rather than stopping: draft the work items that do not depend on it, and flag the work items it blocks as not draftable until the artifact exists. Stop only if no work items are draftable without the missing artifact.

### 5. Draft the work items

Launch `han-core:project-manager` (`subagent_type: "han-core:project-manager"`) with:

- The full plan or context content from Step 1.
- The artifact inventory from Step 4.
- The Rules section of this skill verbatim.
- A directive to draft vertical slices: each work item is a narrow but complete path through the appropriate layers (schema, API, UI, tests), demoable or verifiable on its own. Classify each work item as **HITL** (requires human interaction: an architectural decision, a design review) or **AFK** (can be implemented and merged without a sync). Prefer AFK over HITL. Prefer many thin work items over few thick ones.
- A directive to return the proposed breakdown as a numbered list. Do not write any files.

Return the han-core:project-manager's output verbatim. Proceed to Step 6.

### 6. Assign symbolic IDs and titles

Give each work item a stable symbolic ID: the prefix `W` plus a sequential number within this file (`W-1`, `W-2`, …). These IDs are for cross-referencing work items within the file and citing them in tickets, threads, and follow-up work. They are stable for the life of the file.

If the user asked for a different prefix (for example, a short feature-derived prefix so IDs stay distinct across multiple features' work-items files), use theirs. Otherwise default to `W`.

Work item title format: `<W-N> — <short descriptive name>` (em-dash separator).

### 7. Print the breakdown

Print a numbered list for visibility. For each work item show:

- **Title**: `<W-N> — <short descriptive name>`
- **Type**: HITL or AFK
- **Depends on**: other work items in this file that must complete first, or `None`
- **Plan reference**: the decisions or work units from the parent plan this work item satisfies (e.g., `D-3, D-7, Work Unit 2`)
- **Reference artifacts**: contract sections, design frame IDs, ADRs, and other references from Step 4
- **Design references**: when `ui-designs/` exists and the work item is UI-bearing, the screenshot filenames that will be referenced

This report is for visibility, not approval. Do not wait for the user's confirmation — proceed directly to Step 8 and write the file.

### 8. Write the work-items file

Write one `work-items.md` in the folder resolved in Step 2. The file layout (title line, intro, optional shared-artifacts preamble) is specified in [references/work-items-file-format.md](./references/work-items-file-format.md). Each work item uses the template in [references/work-item-template.md](./references/work-item-template.md).

Write incrementally per the operating principle: write the title and intro first, then append each work item as it is finalized. Save after each.

When the file is complete, give the user a short in-channel summary: the file path, the count of work items by type (HITL / AFK), and the next concrete action (typically "review the breakdown, then start the first AFK work item").
