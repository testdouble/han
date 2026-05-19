---
name: coding-standard
description: >
  Creates and updates coding standards, conventions, rules, and guidelines for
  the current project. Use when creating new standards from scratch, converting
  existing documents into coding standards, or updating existing standards —
  including evaluating whether a proposed standard belongs in automated tooling
  like linters or formatters instead. Does not create architectural decision
  records — use architectural-decision-record for ADRs. Does not write feature or system
  documentation — use project-documentation for that. Does not research
  open-ended options or prior art that is not destined for a standard — use
  research.
argument-hint: [standard-topic or document-path]
allowed-tools: Read, Write, Edit, Glob, Grep, Agent, Bash(git config *), Bash(whoami), Bash(mkdir *), Bash(find *), Bash(ln *), Bash(test *), Bash(readlink *)
---

## Project Context

- Git user: !`git config user.name` (!`git config user.email`)
- OS username: !`whoami`
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

Apply the evidence-based YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md). A coding standard is worth writing only when the project actually does the thing the standard governs *today* and the standard solves a real, concrete problem the team is currently hitting. Standards about patterns the project doesn't use yet, "for future flexibility", "best practice says we should…", or symmetry with other standards ("we have one for backend, so we should have one for frontend" when the frontend codebase is a single file) are YAGNI candidates. Acceptable evidence the standard is needed *now*:

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

4. **Resolve author information:** If git user or email is empty in the project context above, ask the user for their name and email.

5. **Check existing coding standard format:** If existing coding standards were found via Glob, read one to understand the project's existing format. If it uses a different format than the template at [template.md](references/template.md), ask the user whether to match the existing format or use this skill's template.

6. **Discover the filename hierarchy taxonomy:** Coding standards are organized by a one- or two-level hierarchy encoded in the filename so related standards sort together in a directory listing. Discover the taxonomy that applies to *this* project — never hardcode it.
   - **From existing filenames:** If existing standards were enumerated, parse their filenames to extract the leading hierarchy segments already in use (e.g., `svelte-component-naming.md` → top-level `svelte`; `svelte-stores-state-shape.md` → top-level `svelte`, second-level `stores`). Build a list of top-level prefixes and known second-level prefixes per top-level.
   - **From project context:** Read CLAUDE.md and project-discovery.md (paths from project context above) to identify the project's languages, frameworks, runtimes, and major subsystems. Each of these is a candidate top-level hierarchy (e.g., `svelte`, `rails`, `postgres`, `terraform`, `api`, `worker`).
   - **Carry forward to Step 6:** the discovered top-level prefixes (existing + candidate) and any second-level prefixes already in use under each.

7. **Discover the project's primary file-type globs.** The `paths:` frontmatter in Step 6 needs file globs scoped to the languages and directories the new standard governs. Build the candidate glob set now so Step 6 has it on hand.
   - **From CLAUDE.md and project-discovery.md:** extract every language, file extension, and major source directory the project actually uses (e.g., `**/*.go`, `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.rb`, `app/**/*.rb`, `services/**/*.go`).
   - **From existing standards' `paths:` frontmatter:** if any existing standard already carries `paths:`, collect its globs as candidate glob prefixes — they reflect the project's accepted scoping vocabulary.
   - **Fallback:** if neither source yields globs, glob the project root for the dominant file extensions (`**/*.{ext}` for each extension seen in more than a handful of files) and surface what you found.
   - **Carry forward to Step 6:** the resolved candidate glob set, grouped by language or subsystem.

## Step 4: Gather Context

1. From the arguments and conversation, determine:
   - **Topic**: what the coding standard covers
   - **Scope**: which parts of the system it applies to
   - **Motivation**: why this needs to be a coding standard
2. If any of these are unclear, use `AskUserQuestion` to clarify before writing

### Launch evidence-gathering agents

Skip these agents when the user has already provided full Correct-usage examples and conflicting-pattern evidence. Otherwise, launch both in parallel — one finds what the codebase already does, the other checks what the project has already documented. Include the topic, scope, and docs/coding-standards directories from Step 3.

1. **Launch codebase-explorer agent (implementation patterns)** — prompt: "Explore the codebase for existing implementations related to {topic} across {scope}. Return: concrete file paths and line ranges that illustrate the convention in practice (Correct-usage candidates), file paths that violate or contradict the convention (What-to-avoid candidates), and any places where the convention is applied inconsistently across the codebase. Focus on real files; do not invent examples."

2. **Launch codebase-explorer agent (standards and ADRs)** — prompt: "Explore {docs-directory} and {coding-standards-directory} for existing coding standards, ADRs, or project docs that touch {topic} across {scope}. Return: any standards or ADRs that already cover this topic (in full or in part), cross-references that the new standard will need to link, and any contradictions between existing docs that the new standard will need to resolve or cite."

After both agents complete, merge their findings into a context block with:
- **Correct-usage candidates** (file:line references) for Step 6
- **What-to-avoid candidates** (file:line references) for Step 6
- **Inconsistency notes** — areas where the convention is applied unevenly (these become Rationale material, not examples)
- **Existing-doc cross-references** for Step 7

## Step 5: Convert Source Document (skip if creating new or updating)

When converting an existing document into a coding standard:

1. Read the source document
2. Map sections to coding standard sections using the mapping at [adr-conversion-mapping.md](references/adr-conversion-mapping.md)
4. **If the source document is fully subsumed:** delete it and update references (search `CLAUDE.md`, `AGENTS.md`, and other markdown files)
5. **If the source document retains useful content:** add a link to the new coding standard in the source document and remove migrated sections

## Step 6: Write the Coding Standard

1. Copy the template from [template.md](references/template.md)
2. **File name:** `{top-level}[-{second-level}]-{hyphenated-name}.md` — a one- or two-level hierarchy prefix followed by the standard's specific name. The hierarchy must come from the taxonomy discovered in Step 3.6, never invented or hardcoded.
   - **Top-level (required):** the highest-level grouping the standard belongs to (e.g., `svelte`, `rails`, `postgres`, `api`). Reuse an existing top-level prefix from Step 3.6 when one fits; only introduce a new top-level when no existing prefix applies, and prefer one that matches a language, framework, or subsystem already named in CLAUDE.md or project-discovery.md.
   - **Second-level (optional):** add only when the top-level has — or will plausibly grow — multiple standards that benefit from a sub-grouping (e.g., `svelte-stores-…`, `svelte-components-…`). Reuse an existing second-level prefix from Step 3.6 when one fits. Skip the second level when the standard is the only one (or one of a few) under its top-level.
   - **Hyphenated-name (required):** the specific topic of this standard, hyphenated, distinct from the hierarchy prefix.
   - If the discovered taxonomy offers more than one reasonable placement, ask the user to choose before writing.
3. **Location:** place in the directory determined in Step 3
4. **Fill in metadata:**
   - **Status**: per Step 1 mode (`proposed` for new, `accepted` for converted)
   - **Authors**: from project context; if empty, from Step 3 user input
   - **Applies To**: free-text matching the project's terminology
   - **Date Created / Last Updated**: current date and time
   - **Reviewers**: leave empty
5. **Propose the `paths:` glob list and get user approval.** The `paths:` field in the YAML frontmatter is what makes the standard load-on-demand under [Claude Code path-scoped rules](https://code.claude.com/docs/en/memory). Rules without `paths:` load at every session start and bloat startup context; rules with `paths:` load only when Claude reads a file whose path matches one of the globs (`load_reason: path_glob_match`).
   - **Build the candidate list** from the Applies To text and Scope section of this standard, intersected with the project file-type globs discovered in Step 3.7. Scope a glob no broader than the standard actually governs — if the standard applies only to Svelte stores, prefer `src/**/stores/**/*.ts` over `**/*.ts`.
   - **Surface the proposal to the user** with `AskUserQuestion` (or as a recommendation when running unattended). Quote the Applies To text or scope clause that justifies each glob; mark inferred globs as `(inferred)`. Do not write the file until the user confirms or proposes a substitute.
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

The standard is now consumed by Claude Code as a [path-scoped rule](https://code.claude.com/docs/en/memory) via a symlink under `.claude/rules/coding-standards/`. The canonical file remains in the project's coding-standards documentation directory; the symlink gives Claude a second access path without duplicating content. **Do not add the new standard as an enumerated link in `CLAUDE.md` (or `AGENTS.md`).** Rules are discovered through the `.claude/rules/` surface, not through the memory file, and enumerating them in the memory file is the failure mode this integration replaces.

1. **Create the symlink.**
   - Ensure `.claude/rules/coding-standards/` exists: `mkdir -p .claude/rules/coding-standards`
   - Symlink the canonical standard into it with a **relative** target so the link survives moving the repo:
     ```
     ln -s ../../../{relative-path-to-canonical-file} .claude/rules/coding-standards/{filename}
     ```
     The target path must be relative to the symlink's directory (`.claude/rules/coding-standards/`). For a canonical file at `docs/coding-standards/{filename}.md`, the target is `../../../docs/coding-standards/{filename}.md`. Adjust the `../` depth when the docs directory is nested differently.
   - If the symlink already exists (update mode), verify with `readlink` that it points to the canonical file. If not, remove it and recreate with the correct target.
2. **Ensure the pointer paragraph exists in `CLAUDE.md` (or `AGENTS.md`).** The memory file should mention the rules surface exactly once; the skill never adds an enumerated entry for the new standard.
   - Check whether the memory file already references `.claude/rules/coding-standards/`. If yes, leave it alone.
   - If not, append a short pointer paragraph under a "Coding Standards" heading. Adapt the wording to the project's voice, but keep the four load-bearing facts:
     ```
     Coding standards live in `{docs-directory}` and are also exposed to Claude
     Code as path-scoped rules via symlinks under `.claude/rules/coding-standards/`.
     Each rule carries a `paths:` field in its YAML frontmatter, so Claude only
     loads the standard into context when it reads a file matching the glob.
     Standards do not appear in the available-skills picker. Humans continue to
     browse `{docs-directory}` for the canonical readable form.
     ```
   - Do not touch any pre-existing enumerated coding-standard entries in the memory file. Migrating those out is a separate operation, not this skill's responsibility.
3. Search for related documentation (other coding standards, ADRs, feature docs).
4. Add cross-references in the new coding standard's "Additional Resources" section.
5. Add back-references from related docs where they add value.

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

1. **Launch junior-developer agent in artifact-review mode** — prompt: "Review the coding standard at {draft_path} as a respected junior-to-mid teammate who has never seen it before. Surface: rules that are not testable, rules whose wording is ambiguous, assumptions baked in without context, cases the rule does not clearly cover, and conflicts with any existing coding standards, ADRs, or CLAUDE.md rules in the project. Every finding must cite a specific section or line and either name the assumption challenged or the standard violated. Return a short prioritized list; return an empty list if the standard is ready as-is."

2. **Launch information-architect agent** — prompt: "Audit the coding standard at {draft_path} for findability, orientation, and comprehension. The intended audience is a developer who hits a code-review finding that points at this standard and needs to resolve it fast. Check: does the title make the scope discoverable from a directory listing? Are the Correct-usage and What-to-avoid sections scannable? Is the Rationale placed where a reader who already agrees with the rule can skip it, but a reader who disagrees can find it? Does the Additional Resources section lead the reader to the next useful artifact, or dead-end them? Return a short list of structural edits; return an empty list if the document reads well."

Apply every actionable edit both agents return. For findings that demand a judgment only the author can make (ambiguous scope, disputed rationale), surface them to the user with a recommended resolution; do not silently resolve.

## Step 10: Verification

Read back the coding standard file and confirm:

1. All metadata fields are filled in (no `{placeholder}` values remain)
2. Template structure from [template.md](references/template.md) was followed
3. YAML frontmatter is present at the top of the file with a `paths:` list, every glob is double-quoted, and the frontmatter closes with `---` before the `# {Title}` heading. When updating an existing standard, confirm no pre-existing frontmatter keys were stripped.
4. The symlink at `.claude/rules/coding-standards/{filename}` exists and resolves to the canonical file. Verify with `readlink` and `test -e`.
5. `CLAUDE.md` (or `AGENTS.md`) was **not** given a new enumerated entry for this standard. If a pointer paragraph was added because none existed, confirm it appears exactly once.
6. Code examples reference real files that exist (verify with Glob) — cross-check against the Correct-usage candidates returned in Step 4
7. "What to avoid" examples are distinct from "Correct usage" examples
8. If converting (Step 5): confirm source document was handled (deleted or updated with link)
9. Confirm agent configuration file references are correct
10. Confirm each of the six Adoption-Bias Audit checks (Step 8) has a cited satisfying section in the final draft, or that the failing check produced an applied revision
11. Confirm actionable edits from Step 9 were applied, or that any skipped edits were surfaced to the user
12. If any issues are found, fix them
