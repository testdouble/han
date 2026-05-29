---
name: project-documentation
description: >
  Creates and maintains project documentation for features, systems, and
  components. Discovers project structure dynamically to work across any
  technology stack. Use when documenting how a feature, system, or component
  works — including writing, updating, or organizing docs. Does not scan or
  detect the project's technology stack — use project-discovery for repository
  analysis and config detection. Does not create architectural decision records
  — use architectural-decision-record for ADRs. Does not create or
  update coding standards — use coding-standard instead. Does not generate PR
  descriptions — use update-pr-description for that. Does not produce runbooks
  for operational scenarios — use runbook for that.
argument-hint: [feature-name or document-path]
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(date *), Bash(git config *), Bash(whoami), Bash(mkdir *), Bash(find *)
---

## Project Context

- Git user: !`git config user.name` (!`git config user.email`)
- OS username: !`whoami`
- CLAUDE.md exists: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

# Project Documentation

## Step 1: Evaluate and Gather Context

**Guard check:** If the request is about an **architectural decision**, suggest `architectural-decision-record` instead. If it's about a **coding convention**, suggest `coding-standard` instead. Proceed only after confirming this is project documentation.

**Docs directory:** Resolve project config: read CLAUDE.md's `## Project Discovery` section for docs directory and language; fall back to project-discovery.md; fall back to Glob default (`docs/`). Use the found docs directory with Glob to enumerate existing `.md` files. If no docs directory was found, create `docs/`. The found language informs code fence language identifiers in Step 3.

**Resolve target files:** Derive the filename in kebab-case: `docs/{feature-name}.md`. Use Glob to check if the file already exists (`docs/{feature-name}*.md`). If it exists, use `AskUserQuestion` to ask: update the existing document, or create with a different name? If not, it will be created.

**Author info:** If git user or email is empty in the project context above, ask the user for their name and email.

**Topic context:** Use the arguments and conversation context to understand the topic and scope. If unclear, use `AskUserQuestion` to clarify.

**Flag content audit need:** Determine whether the Content Audit (Step 6) will be needed. It is needed when updating an existing doc, migrating content from CLAUDE.md, or restructuring content from any other source. It is not needed only when creating documentation for a feature with no prior documentation of any kind.

## Step 2: Explore the Codebase

Launch 2-3 `codebase-explorer` agents in parallel with the feature name, scope, and any known file paths. Include the docs directory from Step 1 so agents can discover existing documentation. Each agent should explore from a different angle (e.g., entry points and core logic; data models and configuration; tests and existing docs).

After all agents complete, merge their findings into a unified **discovery summary** — a numbered list (D1, D2, D3, ...) that combines all items, deduplicates files found by multiple agents, and resolves any conflicting findings.

## Step 3: Write the Documentation

Use the template at [template.md](references/template.md) as the structural guide. The template's HTML comments explain when to include each section and what to cover.

**File location:** `docs/{feature-name}.md` (in the directory determined in Step 1)

**Writing rules:**
1. **Absolute file paths** from repo root (e.g., `src/services/auth.ts`, not `./auth.ts`)
2. **Concrete code examples** — 10-30 lines, annotated, copied or adapted from actual source code
3. **Code fence language identifiers** must match the project's actual languages (from Step 1)
4. **Document constants and magic numbers** with their actual values
5. **Skip CONDITIONAL sections** from the template that don't apply — don't include empty sections
6. **One-sentence description** in the title area summarizing what the feature does
7. **Separate backend and frontend content** — use `### Backend` / `### Frontend` sub-headings for cross-cutting features; skip sub-headings for single-layer features

**Updating existing documents:** Read the entire existing document first and note all content sources (existing doc, content migrated from CLAUDE.md or other files, any other inputs). Preserve the existing structure — don't reorganize unless requested. Identify sections needing changes based on Step 2 exploration. Add new sections where the template suggests them. Flag removals as provisional for the Content Audit (Step 6). Update code examples to match current source and update cross-references in both directions.

**Metadata:** Fill in **Last Updated** (current date/time) and **Authors** (from project context or Step 1 user input).

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

Identify every source of pre-existing content that fed into this task (previous doc version, CLAUDE.md content replaced with summary links, content migrated from other files). Re-read each source's original content from before your changes. Launch a `content-auditor` agent with the path to the new/updated document and the list of all source content (file paths and descriptions). The agent classifies each fact as Present, Correctly Removed, or Missing.

For each item classified as **Missing**, add the content back to the appropriate section, adapting wording to fit the new document's style while preserving factual content. Use the agent's suggested wording and placement as guidance.

Present the audit summary to the user: number of facts checked, number present, number correctly removed, and number missing (and restored).

## Step 7: Information-Architecture Review

Dispatch an `information-architect` agent against the written/updated doc before final verification. Pass it the document path, the docs directory root, and the intended audience (a developer who needs to understand or change this feature).

Prompt: "Audit the feature doc at {doc_path} for findability, orientation, and comprehension. The intended audience is a developer who needs to understand or change this feature. Check: does the title + one-sentence description match what a reader scanning `{docs_directory}` would expect to find here? Is the Overview oriented at the right audience, and does it lead the reader to the next section they need? Are Behavior, Configuration, and Error Handling scannable and in the right order for the likely reading path? Does the Related Documentation section lead the reader to the next useful artifact, or dead-end them? Return a short list of structural edits; return an empty list if the document reads well."

Apply every actionable edit the agent returns. For findings that require a judgment only the author can make (scope, audience ambiguity), surface them to the user with a recommended resolution; do not silently resolve.

## Step 8: Verification

1. **Documentation file:** Follows template structure, no `{placeholder}` values remain, absolute file paths, concrete code examples, no empty CONDITIONAL sections, ASCII diagrams render correctly
2. **Agent config file:** Reference correctly formatted, link path valid, placed in right section
3. **Cross-references:** Links point to real files, related docs link back to new doc
4. **IA review applied:** Step 7 edits were applied, or any skipped edits were surfaced to the user
