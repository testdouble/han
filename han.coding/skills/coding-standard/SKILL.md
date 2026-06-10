---
name: coding-standard
description: >
  Creates and updates coding standards, conventions, rules, and guidelines for the current
  project. Use when creating new standards from scratch, converting existing documents into coding
  standards, or updating existing standards. Does not create architectural decision records — use
  architectural-decision-record for ADRs. Does not write feature or system documentation — use
  project-documentation for that. Does not research open-ended options — use research. Does not
  produce runbooks for operational scenarios — use runbook for that.
argument-hint: [standard-topic or document-path]
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(mkdir *), Bash(find *)
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- AGENTS.md: !`find . -maxdepth 1 -name "AGENTS.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- Rules directory: !`find . -maxdepth 4 -type d -path "*/.claude/rules/coding-standards"`

## Step 1: Determine Mode

Determine which mode to operate in based on the user's request:

| Mode | When | Initial Status | Then |
|------|------|----------------|------|
| Creating new | Building a coding standard from scratch | `proposed` | → Step 2 |
| Converting existing | User provides an existing document (ADR, etc.) to convert | `accepted` | → Step 2 |
| Updating existing | Modifying an existing coding standard | — | Read the existing coding standard, → Step 3 |

## Step 2: Evaluate Appropriateness

Coding standard documents are **not a replacement for automated tooling**. Before proceeding, evaluate whether the proposed coding standard falls into one of these categories:

- Conventions that should be enforced by linters or formatters (variable naming, indentation, whitespace, import ordering, bracket placement, line length, semicolons)
- Common language conventions that are well-known or easily discoverable from the language's own documentation and community norms (type declaration style, etc.)

If the proposed coding standard falls into one of these categories:

1. Warn the user that this is typically handled by automated tooling or is a well-known language convention, and that documenting it adds maintenance burden without value. Recommend configuring tooling instead.
2. Ask the user whether they still want to proceed
3. If the user declines, stop — the skill is done

If the proposed coding standard does not fall into these categories, proceed to the YAGNI check below.

### YAGNI check

Apply the evidence-based YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md) alongside the companion evidence rule in [../../references/evidence-rule.md](../../references/evidence-rule.md). A coding standard is worth writing only when the project actually does the thing the standard governs *today* and the standard solves a real, concrete problem the team is currently hitting. Standards about patterns the project doesn't use yet, "for future flexibility", "best practice says we should…", or symmetry with other standards ("we have one for backend, so we should have one for frontend" when the frontend codebase is a single file) are YAGNI candidates. Acceptable evidence the standard is needed *now*:

- The pattern the standard governs is actively used in the codebase today (cite at least three examples), and inconsistency between examples is causing real friction (review churn, bugs, onboarding cost).
- A documented incident or recurring code-review finding the standard would prevent.
- A regulatory or compliance rule the project actually falls under that requires the convention.
- A user-described need ("I keep having to remind people about X").

If no accepted evidence applies, recommend deferring the standard with the trigger that would justify writing it (a third instance of the pattern lands, a real incident occurs, a recurring review finding accumulates). Surface the recommendation to the user with the override option.

## Step 3: Discover Project Structure

1. **Retrieve project config:** Resolve project config: read CLAUDE.md's `## Project Discovery` section for docs and coding-standards directories; fall back to project-discovery.md; fall back to Glob defaults (`docs/`, `docs/coding-standards/`). Continue without any keys that remain unfound.

2. **Determine the coding standards directory:**
   - If a coding standards directory was found, use it
   - If only a docs directory was found, create `{docs-dir}/coding-standards/`
   - If neither was found, create `docs/coding-standards/`

3. **Enumerate existing coding standards:** If a coding standards directory was found, use Glob to enumerate existing `.md` files in that directory.

4. **Check existing coding standard format:** If existing coding standards were found via Glob, read one to understand the project's existing format. If it uses a different format than the template at [template.md](./references/template.md), ask the user whether to match the existing format or use this skill's template.

5. **Discover the filename hierarchy taxonomy:** Coding standards are organized by a one- or two-level hierarchy encoded in the filename so related standards sort together in a directory listing. Discover the taxonomy that applies to *this* project — never hardcode it.
   - **From existing filenames:** If existing standards were enumerated, parse their filenames to extract the leading hierarchy segments already in use (e.g., `svelte-component-naming.md` → top-level `svelte`; `svelte-stores-state-shape.md` → top-level `svelte`, second-level `stores`). Build a list of top-level prefixes and known second-level prefixes per top-level.
   - **From project context:** Read CLAUDE.md and project-discovery.md (paths from project context above) to identify the project's languages, frameworks, runtimes, and major subsystems. Each of these is a candidate top-level hierarchy (e.g., `svelte`, `rails`, `postgres`, `terraform`, `api`, `worker`).
   - **Carry forward to Step 6:** the discovered top-level prefixes (existing + candidate) and any second-level prefixes already in use under each.

6. **Discover the project's primary file-type globs and group them into index-file buckets.** The `paths:` frontmatter in Step 6 needs file globs scoped to the languages and directories the new standard governs. The Step 7 integration then routes the new standard into one or more **per-file-type index files** under `.claude/rules/coding-standards/`, where each index file owns a single file-type bucket (for example, `svelte.md` owns `**/*.svelte`; `typescript.md` owns `**/*.ts` and `**/*.tsx`; `ruby.md` owns `**/*.rb` and `app/**/*.rb`). Build the candidate glob set and its bucket grouping now so Steps 6 and 7 have them on hand.
   - **From CLAUDE.md and project-discovery.md:** extract every language, file extension, and major source directory the project actually uses (e.g., `**/*.go`, `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.rb`, `app/**/*.rb`, `services/**/*.go`).
   - **From existing standards' `paths:` frontmatter:** if any existing standard already carries `paths:`, collect its globs as candidate glob prefixes — they reflect the project's accepted scoping vocabulary.
   - **From existing index files under `.claude/rules/coding-standards/`:** if the rules directory was found in the project context, enumerate the index files already present and read each one's `paths:` frontmatter. Each existing file defines an established bucket; reuse it rather than introducing a parallel bucket for the same file type.
   - **Fallback:** if no source yields globs, glob the project root for the dominant file extensions (`**/*.{ext}` for each extension seen in more than a handful of files) and surface what you found.
   - **Group into buckets:** organize the resolved candidate glob set into file-type buckets, one per index file. Reuse an existing bucket whenever one fits; introduce a new bucket only when no existing index file's `paths:` covers the new glob. Name new buckets after the language, framework, or subsystem they cover (e.g., `svelte`, `typescript`, `ruby`, `sql`) — the bucket name becomes the index file's filename in Step 7.
   - **Carry forward to Steps 6 and 7:** the candidate glob set grouped by bucket, plus the list of existing index files and the globs each one owns.

## Step 4: Gather Context

1. From the arguments and conversation, determine:
   - **Topic**: what the coding standard covers
   - **Scope**: which parts of the system it applies to
   - **Motivation**: why this needs to be a coding standard
2. If any of these are unclear, use `AskUserQuestion` to clarify before writing

### Launch evidence-gathering agents

Skip these agents when the user has already provided full Correct-usage examples and conflicting-pattern evidence. Otherwise, launch both in parallel — one finds what the codebase already does, the other checks what the project has already documented. Include the topic, scope, and docs/coding-standards directories from Step 3.

1. **Launch han.core:codebase-explorer agent (implementation patterns)** — prompt: "Explore the codebase for existing implementations related to {topic} across {scope}. Return: concrete file paths and line ranges that illustrate the convention in practice (Correct-usage candidates), file paths that violate or contradict the convention (What-to-avoid candidates), and any places where the convention is applied inconsistently across the codebase. Focus on real files; do not invent examples."

2. **Launch han.core:codebase-explorer agent (standards and ADRs)** — prompt: "Explore {docs-directory} and {coding-standards-directory} for existing coding standards, ADRs, or project docs that touch {topic} across {scope}. Return: any standards or ADRs that already cover this topic (in full or in part), cross-references that the new standard will need to link, and any contradictions between existing docs that the new standard will need to resolve or cite."

After both agents complete, merge their findings into a context block with:
- **Correct-usage candidates** (file:line references) for Step 6
- **What-to-avoid candidates** (file:line references) for Step 6
- **Inconsistency notes** — areas where the convention is applied unevenly (these become Rationale material, not examples)
- **Existing-doc cross-references** for Step 7

## Step 5: Convert Source Document (skip if creating new or updating)

When converting an existing document into a coding standard:

1. Read the source document
2. Map sections to coding standard sections using the mapping at [adr-conversion-mapping.md](./references/adr-conversion-mapping.md)
4. **If the source document is fully subsumed:** delete it and update references (search `CLAUDE.md`, `AGENTS.md`, and other markdown files)
5. **If the source document retains useful content:** add a link to the new coding standard in the source document and remove migrated sections

## Step 6: Write the Coding Standard

1. Copy the template from [template.md](./references/template.md)
2. **File name:** `{top-level}[-{second-level}]-{hyphenated-name}.md` — a one- or two-level hierarchy prefix followed by the standard's specific name. The hierarchy must come from the taxonomy discovered in Step 3.5, never invented or hardcoded.
   - **Top-level (required):** the highest-level grouping the standard belongs to (e.g., `svelte`, `rails`, `postgres`, `api`). Reuse an existing top-level prefix from Step 3.5 when one fits; only introduce a new top-level when no existing prefix applies, and prefer one that matches a language, framework, or subsystem already named in CLAUDE.md or project-discovery.md.
   - **Second-level (optional):** add only when the top-level has — or will plausibly grow — multiple standards that benefit from a sub-grouping (e.g., `svelte-stores-…`, `svelte-components-…`). Reuse an existing second-level prefix from Step 3.5 when one fits. Skip the second level when the standard is the only one (or one of a few) under its top-level.
   - **Hyphenated-name (required):** the specific topic of this standard, hyphenated, distinct from the hierarchy prefix.
   - If the discovered taxonomy offers more than one reasonable placement, ask the user to choose before writing.
3. **Location:** place in the directory determined in Step 3
4. **Fill in metadata:**
   - **Status**: per Step 1 mode (`proposed` for new, `accepted` for converted)
   - **Applies To**: free-text matching the project's terminology
   - **Date Created / Last Updated**: current date and time
5. **Propose the `paths:` glob list and get user approval.** The `paths:` field in the YAML frontmatter is the canonical declaration of which file globs the standard governs. Step 7 uses each glob to route the new standard into one or more per-file-type **index files** under `.claude/rules/coding-standards/` — the standard itself is never loaded directly as a path-scoped rule. The index files are what Claude Code loads via [Claude Code path-scoped rules](https://code.claude.com/docs/en/memory), and they then point Claude at this standard on demand. Cross-cutting standards whose `paths:` span multiple file-type buckets get listed in each matching index.
   - **Build the candidate list** from the Applies To text and Scope section of this standard, intersected with the project file-type globs discovered in Step 3.6. Scope a glob no broader than the standard actually governs — if the standard applies only to Svelte stores, prefer `src/**/stores/**/*.ts` over `**/*.ts`.
   - **Surface the proposal to the user** with `AskUserQuestion` (or as a recommendation when running unattended). Quote the Applies To text or scope clause that justifies each glob; mark inferred globs as `(inferred)`. Name the index-file bucket(s) each glob will be routed into in Step 7 so the user can see the integration consequence. Do not write the file until the user confirms or proposes a substitute.
   - **YAML rule:** each glob must be double-quoted (characters like `*`, `{`, `[` are YAML-significant and fail to parse unquoted). Globs follow Claude Code's standard glob syntax (`**`, `*`, `?`, `{a,b}`).
6. **Write the YAML frontmatter at the top of the file.** Place a `---` block before the `# {Title}` heading containing at minimum the approved `paths:` list. Example:
   ```
   ---
   paths:
     - "**/*.go"
     - "internal/services/**/*.go"
   ---
   ```
   When updating an existing standard (Step 1 mode = "Updating existing"), preserve every existing frontmatter key — only ADD or REPLACE `paths:`. Never strip `name`, `description`, `type`, or any other key the file already carries.
7. **Fill each template section** with real code examples from the codebase (found in Step 4)
8. **Code fence language identifiers** must match the project's actual languages
9. **For cross-cutting coding standards:** include examples from each system area, label by area not language, set Applies To to list all areas, and propose a `paths:` list that includes one glob per area (e.g., `"app/**/*.rb"` plus `"services/**/*.go"`)
10. **If no real code examples exist yet** (coding standard for a pattern not yet implemented): label examples as "Proposed pattern" and note this in the Introduction

## Step 7: Integration

The standard is consumed by Claude Code through a small set of per-file-type **index files** under `.claude/rules/coding-standards/`. Each index file is itself a [path-scoped rule](https://code.claude.com/docs/en/memory) that carries `paths:` frontmatter for one file type (or a closely-related group), a brief load-on-demand instruction paragraph, and a list of entries pointing to the canonical standards in the project's coding-standards directory. When Claude Code reads a file matching an index file's globs, Claude loads only that small index, then decides which (if any) of the listed standards to open with the Read tool. The full text of a standard is never loaded automatically. This replaces the prior one-symlink-per-standard layout, which forced every standard whose `paths:` matched the current file into context at once. **Do not add the new standard as an enumerated link in `CLAUDE.md` (or `AGENTS.md`).** Rules are discovered through the `.claude/rules/` surface, not through the memory file, and enumerating them in the memory file is the failure mode this integration replaces.

1. **Determine which index file(s) the new standard belongs in.** Using the buckets carried forward from Step 3.6, map each glob in the standard's approved `paths:` to a bucket. The set of matching buckets is the set of index files the standard will be listed in. A standard whose `paths:` spans multiple buckets (a cross-cutting standard, e.g., `"app/**/*.rb"` plus `"services/**/*.go"`) will be listed in each matching index — the canonical standards file is still only ever in one place; only the index entries are repeated.

2. **Ensure `.claude/rules/coding-standards/` exists.** Run `mkdir -p .claude/rules/coding-standards`.

3. **For each matching index file, create or update it.**

   - **If the index file does not exist yet**, copy the template at [index-file-template.md](./references/index-file-template.md) to `.claude/rules/coding-standards/{bucket-name}.md` and fill it in:
     - Replace the placeholder globs in `paths:` with the bucket's globs (each double-quoted; see the YAML rule in Step 6.5).
     - Replace `{File-type}` in the heading with the bucket name (e.g., `Svelte`, `TypeScript`, `Ruby`). Use the capitalization that matches the language/framework's own conventions.
     - Leave the entire instruction paragraph (everything between the heading and the `## Available standards` heading) verbatim. It is what tells Claude to make a relevance decision before opening any standard.
     - Replace the example bullet under `## Available standards` with a single entry for the new standard (see entry format below).

   - **If the index file already exists**, edit it in place:
     - Append a new entry for this standard under `## Available standards`, in alphabetical order by standard title (or by the existing hierarchy already in use in that index).
     - Do not modify the existing `paths:`, the instruction paragraph, or any other entries unless this is update-mode and the change explicitly requires it (see step 5 below).

4. **Entry format.** Each entry under `## Available standards` is a single bullet of the form:

   ```
   - [{Standard title}]({relative-path-to-canonical-file}) — {1-3 sentence description}
   ```

   - **Title:** use the standard's `# {Title}` heading verbatim.
   - **Relative path:** the path to the canonical standard from `.claude/rules/coding-standards/`. For a canonical file at `docs/coding-standards/{filename}.md`, the target is `../../../docs/coding-standards/{filename}.md`. Adjust the `../` depth when the docs directory is nested differently.
   - **Description (1-3 sentences):** name what the standard covers AND when a reader should pull the full file. This is bait for a relevance decision, not a summary of the standard. Examples: *"Naming rules for Svelte components, including file names, exported types, and slot conventions. Read when creating or renaming a component."* / *"Transaction boundaries in repository methods. Read when writing a new repository method or changing the call sites of an existing one."* Vague descriptions (*"covers component conventions"*) cause Claude to either over-load or skip relevant standards.

5. **Update-mode delta handling.** If the skill is in "Updating existing" mode and the standard's `paths:` changed:
   - **Removed buckets.** For each index file that previously listed this standard but whose `paths:` no longer overlaps the standard's `paths:`, remove the standard's entry from that index. Leave the rest of the index untouched.
   - **Added buckets.** For each newly-matching index file, follow step 3 above (create or update) to add the entry.
   - **Same buckets.** If the matching index files did not change but the standard's title or description should change (e.g., the standard's scope shifted), update the entry text in place — title, link, and description — without disturbing surrounding entries.

6. **Ensure the pointer paragraph exists in `CLAUDE.md` (or `AGENTS.md`).** The memory file should mention the rules surface exactly once; the skill never adds an enumerated entry for the new standard.
   - Check whether the memory file already references `.claude/rules/coding-standards/`. If yes, leave it alone.
   - If not, append a short pointer paragraph under a "Coding Standards" heading. Adapt the wording to the project's voice, but keep the load-bearing facts:
     ```
     Coding standards live in `{docs-directory}`. They are exposed to Claude
     Code through a small set of per-file-type index files under
     `.claude/rules/coding-standards/`. Each index file is a path-scoped rule
     that lists the standards relevant to one file type, with a short
     description of each. When Claude reads a file matching an index's
     `paths:` glob, Claude loads only the index and then decides which (if
     any) standards to open. The full text of a standard is never loaded
     automatically. Standards do not appear in the available-skills picker.
     Humans continue to browse `{docs-directory}` for the canonical readable
     form.
     ```
   - Do not touch any pre-existing enumerated coding-standard entries in the memory file. Migrating those out is a separate operation, not this skill's responsibility.

7. Search for related documentation (other coding standards, ADRs, feature docs).
8. Add cross-references in the new coding standard's "Additional Resources" section.
9. Add back-references from related docs where they add value.

## Step 8: Adoption-Bias Audit

Standards with conditional applicability tend to drift toward unconditional application unless the document's structure actively pushes back. Coordinately-listed rationales, buried exception cases, and missing "when not to apply" sections all let the pattern spread on speculation rather than evidence. This audit catches those structural failures before downstream readers and synthesizing agents over-apply the standard.

Walk through the six checks below. For each, cite a specific section, paragraph, or line in the draft that satisfies the check. If you cannot cite one, propose and apply a concrete revision before continuing.

1. **Primary-rationale visibility** — Does the Purpose section lead with one primary rationale, with secondary benefits clearly demoted? If multiple rationales appear, is their relative priority explicit (e.g., `Primary:`, `Secondary:`, `Side effect:`)? **Reject** Purpose sections that list rationales coordinately ("X, Y, Z, and W") without ranking.

2. **Decision tree near the top** — Is there a "When to apply this pattern" section before the prescriptive Coding Standard section, stating preconditions as an explicit decision tree (Q1 → Q2 → outcome) rather than prose? If the standard has any exception case, does the decision tree route to it as a branch, not as a footnote elsewhere?

3. **"When NOT to apply" section, present and substantive** — Is there an explicit section listing cases where the pattern is wrong, with examples? Does at least one case acknowledge the simpler-than-the-pattern alternative (direct import, inline code, no abstraction) as a legitimate choice? **Reject** standards that have only a "When to apply" section — symmetry between the two reduces over-application.

4. **Exceptions surfaced, not buried** — If the standard has any "Exception — X" callout, is it visible in the decision tree at the top (or in front matter / table of contents)? **Reject** standards where an exception case appears for the first time more than two heading levels deep.

5. **Code-example comment audit** — For each code example with an inline comment explaining why the pattern is being applied, does the comment match the standard's stated primary rationale? **Reject** examples where the comment cites a secondary or exception rationale (e.g., "to avoid cycles") when the primary rationale is something else (e.g., testability). Examples reinforce reading habits more than prose.

6. **Verification step for "in doubt" adoptions** — If the pattern is sometimes invoked defensively ("I might need this later"), does the standard provide a concrete command, query, or test the reader can run *now* to verify the trigger condition? Examples: `go list -deps ./...` to verify a cycle exists; a benchmark threshold for performance-motivated patterns; a coverage metric for testability-motivated patterns. **Reject** standards whose adoption trigger is purely "if you think you need it" without an objective check.

**Update-mode delta question** — If updating an existing standard (Step 1 mode = "Updating existing"), additionally answer: *did this update change which rationale is primary?* If yes, re-audit every code example and inline comment to confirm they cite the new primary rationale, not the old one.

A standard that passes all six checks is robust against over-application by downstream readers and synthesizing agents. A standard that fails any of them tends to spread beyond its intended scope — fix the failure before proceeding to Step 9.

## Step 9: Adversarial Review

Before self-verification, dispatch two review agents **in parallel** to stress-test the draft standard. Pass each the path to the draft file.

1. **Launch han.core:junior-developer agent in artifact-review mode** — prompt: "Review the coding standard at {draft_path} as a respected junior-to-mid teammate who has never seen it before. Surface: rules that are not testable, rules whose wording is ambiguous, assumptions baked in without context, cases the rule does not clearly cover, and conflicts with any existing coding standards, ADRs, or CLAUDE.md rules in the project. Every finding must cite a specific section or line and either name the assumption challenged or the standard violated. Return a short prioritized list; return an empty list if the standard is ready as-is."

2. **Launch han.core:information-architect agent** — prompt: "Audit the coding standard at {draft_path} for findability, orientation, and comprehension. The intended audience is a developer who hits a code-review finding that points at this standard and needs to resolve it fast. Check: does the title make the scope discoverable from a directory listing? Are the Correct-usage and What-to-avoid sections scannable? Is the Rationale placed where a reader who already agrees with the rule can skip it, but a reader who disagrees can find it? Does the Additional Resources section lead the reader to the next useful artifact, or dead-end them? Return a short list of structural edits; return an empty list if the document reads well."

Apply every actionable edit both agents return. For findings that demand a judgment only the author can make (ambiguous scope, disputed rationale), surface them to the user with a recommended resolution; do not silently resolve.

## Step 10: Verification

Read back the coding standard file and confirm:

1. All metadata fields are filled in (no `{placeholder}` values remain)
2. Template structure from [template.md](./references/template.md) was followed
3. YAML frontmatter is present at the top of the file with a `paths:` list, every glob is double-quoted, and the frontmatter closes with `---` before the `# {Title}` heading. When updating an existing standard, confirm no pre-existing frontmatter keys were stripped.
4. **Index-file membership.** The standard is listed in every index file under `.claude/rules/coding-standards/` whose `paths:` overlaps the standard's `paths:`, and is **not** listed in any index file whose `paths:` does not overlap. For each index file the standard was added to, confirm: the file's `paths:` frontmatter still parses; every pre-existing entry is still present (none were dropped while editing); the instruction paragraph between the heading and `## Available standards` is unchanged from the template (verbatim); the new entry's relative link resolves to the canonical standard file; the new entry's description is 1-3 sentences and names both what the standard covers and when a reader should pull the full file. In update-mode, additionally confirm the standard's entry was removed from any index file whose `paths:` no longer overlaps.
5. `CLAUDE.md` (or `AGENTS.md`) was **not** given a new enumerated entry for this standard. If a pointer paragraph was added because none existed, confirm it appears exactly once and that its wording describes the per-file-type index-file mechanism (not the prior one-symlink-per-standard mechanism).
6. Code examples reference real files that exist (verify with Glob) — cross-check against the Correct-usage candidates returned in Step 4
7. "What to avoid" examples are distinct from "Correct usage" examples
8. If converting (Step 5): confirm source document was handled (deleted or updated with link)
9. Confirm agent configuration file references are correct
10. Confirm each of the six Adoption-Bias Audit checks (Step 8) has a cited satisfying section in the final draft, or that the failing check produced an applied revision
11. Confirm actionable edits from Step 9 were applied, or that any skipped edits were surfaced to the user
12. If any issues are found, fix them
