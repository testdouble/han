# /coding-standard

Operator documentation for the `/coding-standard` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`plugin/skills/coding-standard/SKILL.md`](../../plugin/skills/coding-standard/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** Creates and updates coding standards for the current project. From scratch, by converting an existing document, or by updating an existing standard.
- **When to use it.** You want to formalize a convention the team already follows, or to research and establish a new one, with real code examples from the codebase.
- **What you get back.** A hierarchically-named coding-standard document under `docs/coding-standards/` with metadata, Correct-usage examples, What-to-avoid examples, and a reference added to `CLAUDE.md`.

## Key concepts

- **Three modes.** Creating new, Converting existing (for example, an ADR into a standard), Updating existing.
- **Linter-first check.** Before writing anything, the skill asks: should this be a linter or formatter rule instead? Style conventions that tooling can enforce become tooling configuration, not standards documents.
- **Evidence from the codebase via parallel explorers.** Two `codebase-explorer` agents run in parallel. One finds implementation patterns (Correct-usage and What-to-avoid candidates with file:line references); the other finds existing standards and ADRs the new one should link or resolve. Correct-usage examples are drawn from real files. If the pattern is not yet implemented, examples are labeled "Proposed pattern."
- **Adversarial review before verification.** A `junior-developer` agent stress-tests the draft for ambiguous rules, hidden assumptions, and conflicts with existing standards. An `information-architect` agent audits the draft for findability, scannability, and whether the Rationale is placed where the right reader will find it.
- **Hierarchically-prefixed filenames.** `{top-level}[-{second-level}]-{hyphenated-name}.md`. A one- or two-level hierarchy prefix (for example, `svelte-stores-state-shape.md`) discovered at runtime from existing standards and project context, so related standards sort together in a directory listing.
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

## How to invoke it

Run `/coding-standard` with a topic or an existing document path.

Give it:

1. **The topic.** *"Error handling in Go services," "transaction boundaries in our repositories," "test-double usage for collaborator seams."*
2. **A source document, optional.** If you want to convert an existing document (for example, an ADR) into a standard, pass the path.
3. **A motivation, optional.** Why this should be a standard: a recurring review finding, a new architectural pattern, a compliance requirement.

Example prompts:

- `/coding-standard`. *"Create a coding standard for error handling based on what we already do in this codebase."*
- `/coding-standard`. *"Research unit tests vs integration tests and create a standard for when to use which, with examples relevant to this project."*
- `/coding-standard docs/adr/data-soft-deletes.md`. *"Convert the soft-deletes ADR into a coding standard."*
- `/coding-standard`. *"Update the existing API naming conventions standard. The new one is under `/v2`."*

## What you get back

A coding-standard document in the project's coding-standards directory, plus integration:

- **`docs/coding-standards/{top-level}[-{second-level}]-{name}.md`.** The standard itself, following the template at [`references/template.md`](../../plugin/skills/coding-standard/references/template.md). The hierarchy prefix is discovered from existing standards and the project's languages, frameworks, and subsystems so related standards sort together. Includes metadata (Status, Authors, Applies To, Date Created, Last Updated, Reviewers), an Introduction, the Standard (rules in testable form), Correct-usage examples from real code, What-to-avoid examples, Rationale, and Additional Resources.
- **A reference added to `CLAUDE.md`** under the coding-standards section, following the project's existing pattern so every downstream skill finds it.
- **Cross-references.** Links to related standards, ADRs, and feature docs, added bidirectionally.
- **Source-document handling** (conversion mode). If the source is fully subsumed, it is deleted and references updated. If it retains useful content, a link to the new standard is added.

## How to get the most out of it

- **Run `/project-discovery` first.** The skill reads CLAUDE.md's Project Discovery section to find the coding-standards directory, the language, and the documentation root. Without discovery, it falls back to Glob defaults.
- **Ground the rule in the codebase.** A standard that points at actual files in the repo is authoritative; one with invented examples is not. Before dispatching, think about which existing files best illustrate Correct usage.
- **Write the rule as testable.** *"Wrap errors with `%w` at every service boundary"* is testable. *"Handle errors appropriately"* is not. If you cannot write a clear enforcement check, the rule is not ready to be a standard yet.
- **Pair with `/architectural-decision-record` when the standard embeds a choice.** If the rule reflects a decision among alternatives, record the decision as an ADR and link the standard to it.
- **Re-run to update.** Standards drift as the codebase evolves. When a new pattern lands, re-run `/coding-standard` in update mode.

## Cost and latency

The skill dispatches two `codebase-explorer` agents in parallel during Step 4 (evidence gathering) and two review agents in parallel during Step 8 (`junior-developer` + `information-architect`). All four run on their default models. Cost scales with codebase size and how many documents the explorers have to read. Typical runs are a few minutes.

## In more detail

The skill walks a nine-step process:

1. **Determine mode.** Creating new / Converting existing / Updating existing.
2. **Evaluate appropriateness.** Should this be tooling instead? If yes, warn and ask.
3. **Discover project structure.** Find the coding-standards directory (or create one), enumerate existing standards, check format compatibility, resolve author info, and discover the filename hierarchy taxonomy from existing standards' filenames plus the project's languages, frameworks, and subsystems.
4. **Gather context.** Topic, scope, motivation. Dispatch two `codebase-explorer` agents in parallel for implementation patterns and existing standards/ADRs.
5. **Convert source document** (conversion mode only). Map sections using the ADR-conversion-mapping reference; handle the source file (delete if fully subsumed, link if partial).
6. **Write the coding standard.** Hierarchically-prefixed filename (top-level subsystem/framework, optional second level), fill the template with real code examples and actual project language identifiers.
7. **Integration.** Add `CLAUDE.md` reference; add cross-references in both directions.
8. **Adversarial review.** Dispatch `junior-developer` for ambiguity and assumption checks and `information-architect` for findability and structure. Apply actionable edits.
9. **Verification.** Re-read the file, confirm metadata, template structure, real file paths, distinct Correct-vs-Avoid examples, and that Step 8 edits were applied.

## YAGNI

A coding standard is justified only when the project does the thing the standard governs **today** and the standard solves a real, concrete problem the team is currently hitting. Standards about patterns the project doesn't use yet, *for future flexibility*, *best practice says we should…*, or symmetry with other standards (*"we have one for backend, so we should have one for frontend"* when the frontend codebase is a single file) are YAGNI candidates. Acceptable evidence the standard is needed now: the pattern is used in the codebase today (cite at least three examples) and inconsistency between examples is causing real friction (review churn, bugs, onboarding cost), or a documented incident or recurring code-review finding the standard would prevent. Standards that fail the evidence test are deferred with a named *reopen-when* trigger, not committed to the project.

See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

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

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies before committing items. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Skills Index](./README.md). All 18 skills, grouped by purpose.
- [`/architectural-decision-record`](./architectural-decision-record.md). For decisions rather than rules. Link the standard to the ADR when the rule embeds a choice.
- [`/project-documentation`](./project-documentation.md). For system and feature documentation that is not a rule.
- [`/code-review`](./code-review.md). Reads standards during every review. Violations become findings.
- [`codebase-explorer`](../agents/codebase-explorer.md), [`junior-developer`](../agents/junior-developer.md), [`information-architect`](../agents/information-architect.md). The agents this skill dispatches during evidence gathering and adversarial review.
- [`SKILL.md` for /coding-standard](../../plugin/skills/coding-standard/SKILL.md). The internal process definition.
