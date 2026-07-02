---
name: project-documentation
description: >
  Creates and maintains project documentation for features, systems, and components. Use when
  documenting how a feature, system, or component works — including writing, updating, or
  organizing docs. Does not scan or detect the project's technology stack — use project-discovery
  for repository analysis and config detection. Does not create architectural decision records —
  use architectural-decision-record for ADRs. Does not create or update coding standards — use
  coding-standard instead. Does not generate PR descriptions — use update-pr-description for that.
  Does not produce runbooks for operational scenarios — use runbook for that. Does not rewrite
  existing prose for readability — use edit-for-readability for that. Does not produce an
  ephemeral, understand-now overview of code or a PR — use code-overview for that.
argument-hint: "[feature-name or document-path]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(date *), Bash(mkdir *), Bash(find *)
---

## Project Context

- CLAUDE.md exists: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

# Project Documentation

**Readability.** As you write the documentation, load and apply the readability rule at [`../../references/readability-rule.md`](../../references/readability-rule.md). The output is a committed file, so the standard applies at generation time. Hold a named audience above the default: a technically-literate reader who needs to understand the feature's behavior before reading or modifying its code. Scope that frame per section so the technical specifics the reader needs are not simplified away.

## Step 1: Evaluate and Gather Context

**Guard check:** If the request is about an **architectural decision**, suggest `architectural-decision-record` instead. If it's about a **coding convention**, suggest `coding-standard` instead. Proceed only after confirming this is project documentation.

**Docs directory:** Resolve project config: read CLAUDE.md's `## Project Discovery` section for docs directory and language; fall back to project-discovery.md; fall back to Glob default (`docs/`). Use the found docs directory with Glob to enumerate existing `.md` files. If no docs directory was found, create `docs/`. The found language informs code fence language identifiers in Step 3.

**Resolve target files:** Derive the filename in kebab-case: `docs/{feature-name}.md`. Use Glob to check if the file already exists (`docs/{feature-name}*.md`). If it exists, use `AskUserQuestion` to ask: update the existing document, or create with a different name? If not, it will be created.

**Topic context:** Use the arguments and conversation context to understand the topic and scope. If unclear, use `AskUserQuestion` to clarify.

**Flag content audit need:** Determine whether the Content Audit (Step 6) will be needed. It is needed when updating an existing doc, migrating content from CLAUDE.md, or restructuring content from any other source. It is not needed only when creating documentation for a feature with no prior documentation of any kind.

## Step 2: Explore the Codebase

Launch 2-3 `han-core:codebase-explorer` agents in parallel with the feature name, scope, and any known file paths. Include the docs directory from Step 1 so agents can discover existing documentation. Each agent should explore from a different angle (e.g., entry points and core logic; data models and configuration; tests and existing docs).

After all agents complete, merge their findings into a unified **discovery summary** — a numbered list (D1, D2, D3, ...) that combines all items, deduplicates files found by multiple agents, and resolves any conflicting findings.

## Step 3: Write the Documentation

Use the template at [template.md](./references/template.md) as the structural guide. The template's HTML comments explain when to include each section and what to cover.

**Readability.** Draft into the template so the structure carries the rule at [`../../references/readability-rule.md`](../../references/readability-rule.md): main point first, descriptive headings, one idea per paragraph with the first sentence carrying it, numbered lists for steps and bullets for non-sequential items, and progressive disclosure that reveals the core before the detail.

**File location:** `docs/{feature-name}.md` (in the directory determined in Step 1)

**Writing rules:**

Lead with behavior. These rules make the doc an overview first and a reference second:
1. **Lead with behavior.** Write the Summary, How It Works, and Primary Flows in plain language before any reference section. Describe what the feature does and what happens when it runs, in functional terms. Name files and types only where it aids understanding.
2. **Summary is prose plus bullets.** Open the Summary with a 2-4 sentence plain-language paragraph for a reader who has not seen the code, then the scannable bullets. The paragraph carries no code, type names, or paths.
3. **Primary Flows narrate the main paths.** Cover the 1-3 flows that matter, not every branch. Name the actor or trigger, give numbered plain-language steps (what happens and why, not which function is called), state the outcome, and narrate the main failure path.
4. **Reference is supporting detail.** Place schema, core types, constants, implementation notes, API bodies, and component listings under the `## Technical Reference` region, below the behavioral spine. Treat them as lookup material, not the document's main body.

Apply to every section:
5. **Absolute file paths** from repo root (e.g., `src/services/auth.ts`, not `./auth.ts`).
6. **Prefer pointers over long code.** In Technical Reference, point to the file and function and include a short illustrative snippet only where the source is non-obvious. Do not reproduce long (10-30 line) source blocks; link to the source instead.
7. **Code fence language identifiers** must match the project's actual languages (from Step 1).
8. **Document constants and magic numbers** with their actual values in the Constants table.
9. **Skip CONDITIONAL sections** from the template that don't apply. Don't include empty sections.
10. **One plain-language description** in the title area summarizing what the feature does.
11. **Separate backend and frontend content.** Use `### Backend` / `### Frontend` sub-headings for cross-cutting features; skip sub-headings for single-layer features.
12. **Diagrams are Mermaid, not ASCII.** Render the Architecture diagram, any Primary Flow diagram, and the Component Hierarchy as Mermaid in a ```` ```mermaid ```` fence — `flowchart` for structure and trees, `sequenceDiagram` for actor-to-system exchanges. Label nodes with parts a reader recognizes and label edges with what passes between them. Keep each diagram to the parts that matter; a reader should grasp the shape at a glance.

**Updating existing documents:** Read the entire existing document first and note all content sources (existing doc, content migrated from CLAUDE.md or other files, any other inputs). Preserve the existing structure; don't reorganize unless requested. Identify sections needing changes based on Step 2 exploration. Add new sections where the template suggests them. If the existing doc has no plain-language behavioral layer (no Summary, How It Works, or Primary Flows), add those sections at the top so the updated doc leads with behavior. Flag removals as provisional for the Content Audit (Step 6). Update code examples to match current source and update cross-references in both directions.

**Metadata:** Fill in **Last Updated** (current date/time).

## Step 4: Update Agent Configuration Files

1. Read the agent configuration file (`CLAUDE.md`, `AGENTS.md`, or equivalent) to understand its existing structure and patterns
2. Add a reference following the existing pattern, e.g.: `- See [/docs/{feature-name}.md](/docs/{feature-name}.md) for {brief description}.`
3. Place it in the section most relevant to the feature, following the file's existing organization

## Step 5: Cross-Reference

1. Grep the feature name across all documentation files found in the project
2. Add cross-references in the new doc's **Related Documentation** section
3. Add a reference back from related docs to the new doc where it adds value
4. Ensure bidirectional linking — if doc A references doc B, doc B should reference doc A

## Step 6: Content Audit

**Check the flag set in Step 1.** If the Content Audit is not needed, skip to Step 7.

Identify every source of pre-existing content that fed into this task (previous doc version, CLAUDE.md content replaced with summary links, content migrated from other files). Re-read each source's original content from before your changes. Launch a `han-core:content-auditor` agent with the path to the new/updated document and the list of all source content (file paths and descriptions). The agent classifies each fact as Present, Correctly Removed, or Missing.

For each item classified as **Missing**, add the content back to the appropriate section, adapting wording to fit the new document's style while preserving factual content. Use the agent's suggested wording and placement as guidance.

Present the audit summary to the user: number of facts checked, number present, number correctly removed, and number missing (and restored).

## Step 7: Information-Architecture Review

Dispatch an `han-core:information-architect` agent against the written/updated doc before final verification. Pass it the document path, the docs directory root, and the intended audience (a developer or technically-literate stakeholder who needs to understand the feature's behavior before reading its code, and who may later modify it).

Prompt: "Audit the feature doc at {doc_path} for findability, orientation, and comprehension. The intended audience is a developer or technically-literate stakeholder who needs to understand the feature's behavior before reading its code, and who may later modify it. Check: (1) Does a plain-language Summary and a How It Works and Primary Flows narration appear before any code, schema, or type reference? If the behavioral content is missing or sits below the reference detail, that is a finding. (2) Does the heading list let a scanning reader see where the functional overview ends and the deep `## Technical Reference` begins? (3) Is the Summary a short prose paragraph plus bullets, oriented at the right audience, and does the title + one-sentence description match what a reader scanning `{docs_directory}` would expect to find here? (4) Are Configuration and Error Handling scannable and placed ahead of the raw reference detail? (5) Does the Related Documentation section lead the reader to the next useful artifact, or dead-end them? Return a list of structural edits. Do not return an empty list unless the document leads with behavior and defers code reference."

Apply every actionable edit the agent returns. For findings that require a judgment only the author can make (scope, audience ambiguity), surface them to the user with a recommended resolution; do not silently resolve.

## Step 8: Readability Rewrite

Dispatch the `han-core:readability-editor` agent in a single `Agent` call to audit and rewrite the settled doc against the readability rule, preserving every fact. Pass it the document path, the rule path (`../../references/readability-rule.md`), and the named audience: a technically-literate reader who needs to understand the feature's behavior before reading or modifying its code. The agent rewrites **prose regions only** — never inside code fences, diagram bodies (for example the body of a Mermaid chart), or rendered markup. Apply its rewrite to the document.

## Step 9: Readability Self-Check

Run the standardized readability self-check from `../../references/readability-rule.md` over the document's prose regions only — never inside code fences, diagram bodies, or rendered markup. Confirm each criterion and fix any failure before finalizing:

1. The opening line states the main point.
2. Each heading names its content and is not a generic label.
3. Each paragraph carries one idea and leads with it.
4. No sentence runs past the soft length flag (about thirty words) without reason.
5. No word from the vocabulary blocklist (the writing-voice profile's "Avoided words and phrases" and "AI slop to avoid" lists) is present.
6. Every fact is preserved — every claim, quantity, named entity, and stated condition or qualifier survives with its precision intact.

Fidelity wins: the standard governs how the content is said, never whether a required fact appears. The standard applies at generation time; a later manual edit of the committed file is not re-checked.

## Step 10: Verification

1. **Documentation file:** Follows template structure and leads with behavior (Summary, How It Works, Primary Flows appear before the `## Technical Reference` region), no `{placeholder}` values remain, absolute file paths, reference code is short snippets or file pointers rather than long source blocks, no empty CONDITIONAL sections, Mermaid diagrams are syntactically valid (open with ```` ```mermaid ````, declare a diagram type, and parse)
2. **Agent config file:** Reference correctly formatted, link path valid, placed in right section
3. **Cross-references:** Links point to real files, related docs link back to new doc
4. **IA review applied:** Step 7 edits were applied, or any skipped edits were surfaced to the user
