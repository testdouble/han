# /coding-standard

Operator documentation for the `/coding-standard` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/coding-standard/SKILL.md`](../../../han.core/skills/coding-standard/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Creates and updates coding standards for the current project. From scratch, by converting an existing document, or by updating an existing standard.
- **When to use it.** You want to formalize a convention the team already follows, or establish a new one grounded in codebase evidence, with real code examples from the codebase.
- **What you get back.** A hierarchically-named coding-standard document under `docs/coding-standards/` with metadata, `paths:` YAML frontmatter, Correct-usage examples, and What-to-avoid examples, plus an entry in one or more per-file-type index files under `.claude/rules/coding-standards/` so Claude Code loads only a small index when a matching file is read and then pulls the full standard only if it decides the standard applies.

## Key concepts

- **Three modes.** Creating new, Converting existing (for example, an ADR into a standard), Updating existing.
- **Linter-first check.** Before writing anything, the skill asks: should this be a linter or formatter rule instead? Style conventions that tooling can enforce become tooling configuration, not standards documents.
- **Evidence from the codebase via parallel explorers.** Two `codebase-explorer` agents run in parallel. One finds implementation patterns (Correct-usage and What-to-avoid candidates with file:line references); the other finds existing standards and ADRs the new one should link or resolve. Correct-usage examples are drawn from real files. If the pattern is not yet implemented, examples are labeled "Proposed pattern."
- **Adversarial review before verification.** A `junior-developer` agent stress-tests the draft for ambiguous rules, hidden assumptions, and conflicts with existing standards. An `information-architect` agent audits the draft for findability, scannability, and whether the Rationale is placed where the right reader will find it.
- **Hierarchically-prefixed filenames.** `{top-level}[-{second-level}]-{hyphenated-name}.md`. A one- or two-level hierarchy prefix (for example, `svelte-stores-state-shape.md`) discovered at runtime from existing standards and project context, so related standards sort together in a directory listing.
- **Path-scoped rules via per-file-type index files.** Each new standard carries `paths:` YAML frontmatter declaring the file globs it governs. The skill routes the standard into one or more per-file-type index files under `.claude/rules/coding-standards/` (for example, `svelte.md`, `typescript.md`, `ruby.md`). The index files are themselves path-scoped rules: when Claude Code reads a file matching an index's globs, it loads only that small index — a short load-on-demand instruction plus a list of standards relevant to that file type, each with a 1-3 sentence description of what it covers and when to pull it. Claude then opens the full text of a standard only if it decides the standard applies. Standards do not appear in the available-skills picker — the rules surface is separate.
- **`/code-review` reads these automatically.** Once landed, the standards are consulted during every `/code-review`. Violations surface as findings.

## When to use it

**Invoke when:**

- The team already follows a convention informally and you want it written down so newcomers find it without asking.
- A code review keeps surfacing the same kind of finding, and the fix is to record the rule once and point to it.
- An ADR has subsections that are really coding rules. Convert them so the standard is authoritative and the ADR stays focused on its decision.
- A new standard needs research-backed rationale (testing boundaries, error handling, transaction patterns). The skill grounds the standard in evidence from the codebase and surfaces Correct and Avoid examples.

**Do not invoke for:**

- **Architectural decisions.** Use [`/architectural-decision-record`](./architectural-decision-record.md) to record a decision. A coding standard encodes a rule; an ADR records a choice and its alternatives.
- **Feature documentation.** Use [`/project-documentation`](./project-documentation.md) for describing how a system works.
- **Style rules that a linter or formatter can enforce.** Configure the tool. Do not write a standard that duplicates it.
- **Open-ended research not destined for a standard.** Use [`/research`](./research.md) to survey options and prior art when the output you want is a recommendation, not an enforceable rule.
- **Runbooks for operational scenarios.** Use [`/runbook`](./runbook.md). A runbook captures the procedure for an alert or incident; a coding standard encodes a rule the code itself must follow.

## How to invoke it

Run `/coding-standard` with a topic or an existing document path.

Give it:

1. **The topic.** *"Error handling in Go services," "transaction boundaries in our repositories," "test-double usage for collaborator seams."*
2. **A source document, optional.** If you want to convert an existing document (for example, an ADR) into a standard, pass the path.
3. **A motivation, optional.** Why this should be a standard: a recurring review finding, a new architectural pattern, a compliance requirement.

Example prompts:

- `/coding-standard`. *"Create a coding standard for error handling based on what we already do in this codebase."*
- `/coding-standard`. *"Create a standard for when to use unit tests vs integration tests, with examples drawn from this codebase."*
- `/coding-standard docs/adr/data-soft-deletes.md`. *"Convert the soft-deletes ADR into a coding standard."*
- `/coding-standard`. *"Update the existing API naming conventions standard. The new one is under `/v2`."*

## What you get back

A coding-standard document in the project's coding-standards directory, plus integration:

- **`docs/coding-standards/{top-level}[-{second-level}]-{name}.md`.** The standard itself, following the template at [`references/template.md`](../../../han.core/skills/coding-standard/references/template.md). The hierarchy prefix is discovered from existing standards and the project's languages, frameworks, and subsystems so related standards sort together. The file opens with a YAML frontmatter block carrying the approved `paths:` globs, followed by metadata (Status, Applies To, Date Created, Last Updated), an Introduction, the Standard (rules in testable form), Correct-usage examples from real code, What-to-avoid examples, Rationale, and Additional Resources.
- **One or more entries in per-file-type index files under `.claude/rules/coding-standards/`.** The skill maps the standard's approved `paths:` globs to existing index files (or creates a new one when no bucket fits) and adds the new standard as a single-bullet entry: the standard's title, a relative link back to the canonical doc, and a 1-3 sentence description of what the standard covers and when a reader should pull the full file. A cross-cutting standard whose `paths:` spans multiple file types is listed in each matching index; the canonical file remains in one place. The skill never adds the standard as an enumerated entry in `CLAUDE.md` (or `AGENTS.md`); it adds a one-time pointer paragraph to the memory file only if the file does not already reference `.claude/rules/coding-standards/`.
- **Cross-references.** Links to related standards, ADRs, and feature docs, added bidirectionally.
- **Source-document handling** (conversion mode). If the source is fully subsumed, it is deleted and references updated. If it retains useful content, a link to the new standard is added.

## Why the canonical doc lives in `docs/` and an index entry lives in `.claude/rules/`

Plain-language version of the design choice, for anyone who reads a new standard and wonders how Claude actually finds it.

**One canonical file. A small index points to it.** The actual standard is a single readable document under your project's coding-standards directory (usually `docs/coding-standards/`). That is the only copy. The files under `.claude/rules/coding-standards/` are small index files — one per file type (for example, `typescript.md`, `ruby.md`, `svelte.md`) — each carrying a `paths:` glob, a short load-on-demand instruction, and a list of bullet entries that link back to the canonical standards. The canonical standard itself is never copied; only its title, link, and a short description appear in the index.

**Why not just store the standards inside `.claude/rules/`?** Because `.claude/` is a directory most teams treat as tool configuration, not human-readable documentation. Standards are documents people open in pull request reviews, link from onboarding pages, and read on GitHub. They belong in `docs/`. The index files let Claude Code find them through its rules surface without dragging the source-of-truth out of the docs tree.

**Why a per-file-type index instead of one rule file per standard?** The prior layout — one symlink under `.claude/rules/coding-standards/` per standard, each pointing to a full standards file with its own `paths:` frontmatter — meant every standard whose globs matched the current file was loaded into context the moment Claude opened that file. On a project with dozens of standards, a single `Read` on a `.ts` file could pull tens of thousands of tokens of standards material into context, all at once, with no chance for Claude to evaluate relevance first. After auto-compact, the same files would re-load on the next `Read` and the cycle would repeat.

The per-file-type index files invert that. Each index file is small: a `paths:` block, a brief load-on-demand instruction, and a list of entries with 1-3 sentence descriptions. When Claude opens a file that matches the index, only the small index loads. Claude then reads the descriptions, decides which (if any) standards are actually relevant to the work at hand, and uses the `Read` tool to open only those. Standards that do not apply stay on disk.

**Why not enumerate standards in `CLAUDE.md`?** Claude Code's path-scoped rules (see [Claude Code memory](https://code.claude.com/docs/en/memory)) load a rule only when a file matching its `paths:` glob is read. A `typescript.md` index will not load when you are editing a Ruby file — so file types unrelated to the current work do not bloat session startup. An enumerated link in `CLAUDE.md` loads on every session whether the standard is relevant or not. The index-file model keeps context small and load-on-demand at two layers: file-type filtering at the rules layer, per-standard filtering at the relevance-decision layer.

**What the skill does and does not touch in `CLAUDE.md`/`AGENTS.md`.** It will add a short pointer paragraph once, only if the memory file does not already mention `.claude/rules/coding-standards/`. The pointer wording describes the per-file-type index mechanism. It never adds an enumerated link for the new standard. Pre-existing enumerated entries from earlier versions of this skill are left alone — migrating them out is a separate one-time operation, not the skill's job.

## How to get the most out of it

- **Run `/project-discovery` first.** The skill reads CLAUDE.md's Project Discovery section to find the coding-standards directory, the language, and the documentation root. Without discovery, it falls back to Glob defaults.
- **Ground the rule in the codebase.** A standard that points at actual files in the repo is authoritative; one with invented examples is not. Before dispatching, think about which existing files best illustrate Correct usage.
- **Write the rule as testable.** *"Wrap errors with `%w` at every service boundary"* is testable. *"Handle errors appropriately"* is not. If you cannot write a clear enforcement check, the rule is not ready to be a standard yet.
- **Pair with `/architectural-decision-record` when the standard embeds a choice.** If the rule reflects a decision among alternatives, record the decision as an ADR and link the standard to it.
- **Re-run to update.** Standards drift as the codebase evolves. When a new pattern lands, re-run `/coding-standard` in update mode.

## Cost and latency

The skill dispatches two `codebase-explorer` agents in parallel during Step 4 (evidence gathering) and two review agents in parallel during Step 9 (`junior-developer` + `information-architect`). All four run on their default models. Cost scales with codebase size and how many documents the explorers have to read. Typical runs are a few minutes.

## In more detail

The skill walks a ten-step process:

1. **Determine mode.** Creating new / Converting existing / Updating existing.
2. **Evaluate appropriateness.** Should this be tooling instead? If yes, warn and ask.
3. **Discover project structure.** Find the coding-standards directory (or create one), enumerate existing standards, check format compatibility, discover the filename hierarchy taxonomy from existing standards' filenames plus the project's languages, frameworks, and subsystems, and capture the project's primary file-type globs for the `paths:` proposal in Step 6.
4. **Gather context.** Topic, scope, motivation. Dispatch two `codebase-explorer` agents in parallel for implementation patterns and existing standards/ADRs.
5. **Convert source document** (conversion mode only). Map sections using the ADR-conversion-mapping reference; handle the source file (delete if fully subsumed, link if partial).
6. **Write the coding standard.** Hierarchically-prefixed filename (top-level subsystem/framework, optional second level), fill the template with real code examples and actual project language identifiers. Propose a `paths:` glob list scoped to what the standard governs, get user approval, and write it as YAML frontmatter at the top of the file.
7. **Integration.** Determine which per-file-type index files under `.claude/rules/coding-standards/` the standard belongs in (based on the buckets discovered in Step 3.7); for each, create from the [index-file template](../../../han.core/skills/coding-standard/references/index-file-template.md) or update in place to add a bullet entry with the standard's title, a relative link to the canonical doc, and a 1-3 sentence description of what it covers and when to pull it; ensure the memory file's pointer paragraph exists (added once if missing, never enumerating individual standards); add cross-references in both directions. In update-mode, the skill deltas the standard's entry across index files when its `paths:` changed: removed from buckets that no longer match, added to buckets that newly match, description updated in place when scope shifted.
8. **Adoption-bias audit.** Six structural checks against over-application: primary-rationale visibility, a decision tree near the top, a substantive *When NOT to Apply* section, surfaced (not buried) exceptions, code-example comments that match the primary rationale, and a verification step for defensive adoptions.
9. **Adversarial review.** Dispatch `junior-developer` for ambiguity and assumption checks and `information-architect` for findability and structure. Apply actionable edits.
10. **Verification.** Re-read the file, confirm metadata, template structure, `paths:` frontmatter, index-file membership across every matching bucket (with the entry's link resolving back to the canonical doc and the description in the 1-3 sentence shape that names both coverage and when-to-pull), real file paths in examples, distinct Correct-vs-Avoid examples, that no enumerated entry was added to the memory file, and that Step 8 and Step 9 edits were applied.

## YAGNI

A coding standard is justified only when the project does the thing the standard governs **today** and the standard solves a real, concrete problem the team is currently hitting. Standards about patterns the project doesn't use yet, *for future flexibility*, *best practice says we should…*, or symmetry with other standards (*"we have one for backend, so we should have one for frontend"* when the frontend codebase is a single file) are YAGNI candidates. Acceptable evidence the standard is needed now: the pattern is used in the codebase today (cite at least three examples) and inconsistency between examples is causing real friction (review churn, bugs, onboarding cost), or a documented incident or recurring code-review finding the standard would prevent. Standards that fail the evidence test are deferred with a named *reopen-when* trigger, not committed to the project.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

The companion [evidence rule](../../evidence.md) applies to the citations that support the standard: name the trust class of each cited example (codebase, web, provided); apply the corroboration gate when the supporting evidence comes from outside the project; label claims with no evidence at any tier rather than presenting them as weak preferences.

## Sources

The skill's practice is grounded in established engineering conventions and documentation norms.

### Google Engineering Practices: Coding Standards and Code Review

Google's publicly documented engineering-practices series separates automated tooling (linters, formatters) from narrative standards (when to prefer a pattern, what tradeoffs to consider). The skill's linter-first check reflects this separation directly. Tooling handles what tooling can, standards handle what tooling cannot.

URL: https://google.github.io/eng-practices/

### Amazon: Working Backwards (Written Docs Over Presentations)

Amazon's long-form-doc culture (written standards and decisions as the unit of record, not slides) informs the skill's insistence on complete, self-contained standards that a reader can pick up cold. Every standard answers the rule, the rationale, the examples, and the scope without forcing the reader back into a meeting transcript.

URL: https://www.aboutamazon.com/news/workplace/what-is-a-six-page-narrative

### O'Reilly: The Google SRE Book (Postmortems and Conventions)

The SRE Book's treatment of postmortem and incident-review conventions (named, discoverable, reviewable documents) shaped the skill's bias toward hierarchically-named filenames that group related standards together and a reviewable metadata block.

URL: https://sre.google/sre-book/

### Claude Code Memory: Path-Scoped Rules

Anthropic's Claude Code memory documentation defines the `.claude/rules/` surface and the `paths:` YAML frontmatter that scopes a rule to file globs (`load_reason: path_glob_match`). The skill's integration step applies this model at two layers: a per-file-type index file under `.claude/rules/coding-standards/` is loaded only when Claude reads a file matching its globs, and the full text of each canonical standard in the project's `docs/coding-standards/` is loaded only when Claude decides the standard applies and opens it with the Read tool.

URL: https://code.claude.com/docs/en/memory

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies before committing items. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Evidence](../../evidence.md). The companion rule the skill applies to the standard's supporting evidence: trust classes, the corroboration gate for web sources, and the no-evidence label.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/architectural-decision-record`](./architectural-decision-record.md). For decisions rather than rules. Link the standard to the ADR when the rule embeds a choice.
- [`/project-documentation`](./project-documentation.md). For system and feature documentation that is not a rule.
- [`/code-review`](./code-review.md). Reads standards during every review. Violations become findings.
- [`codebase-explorer`](../../agents/han.core/codebase-explorer.md), [`junior-developer`](../../agents/han.core/junior-developer.md), [`information-architect`](../../agents/han.core/information-architect.md). The agents this skill dispatches during evidence gathering and adversarial review.
- [`SKILL.md` for /coding-standard](../../../han.core/skills/coding-standard/SKILL.md). The internal process definition.
