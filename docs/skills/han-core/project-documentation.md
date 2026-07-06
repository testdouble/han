# /project-documentation

Operator documentation for the `/project-documentation` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-core/skills/project-documentation/SKILL.md`](../../../han-core/skills/project-documentation/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md)

## TL;DR

- **What it does.** Creates and maintains project documentation for features, systems, and components; discovers project structure dynamically to work across stacks.
- **When to use it.** You want a feature, system, or component documented, or you want to update an existing doc to match what the code does now.
- **What you get back.** A new or updated `docs/{feature-name}.md` following the project's template conventions, with real code examples, cross-references, and a reference added to `CLAUDE.md`.

## Key concepts

- **Guard check.** If the topic is really an architectural decision, the skill suggests [`/architectural-decision-record`](./architectural-decision-record.md) instead. If it is a convention, it suggests [`/coding-standard`](../han-coding/coding-standard.md). Only real feature or system documentation proceeds.
- **Codebase exploration in parallel.** Two or three `codebase-explorer` agents run in parallel (entry points and core logic, data models and config, tests and existing docs) and merge into a unified numbered discovery summary (D1, D2, D3…).
- **Real code, real paths.** Examples come from actual source files. Paths are absolute from the repo root.
- **Content audit when updating.** When updating a doc or migrating content from elsewhere, the skill dispatches `content-auditor` to classify every fact as Present / Correctly Removed / Missing, then restores missing facts.
- **Information-architecture review before verification.** An `information-architect` agent audits the written doc for findability, scannability, and whether the section order matches the likely reading path. Applied edits tighten the doc before it ships.
- **Bidirectional cross-references.** If the new doc references another doc, the other doc gets a reference back where it adds value.

## When to use it

**Invoke when:**

- A feature or subsystem exists in the codebase but is not yet documented.
- A doc has gone stale after a refactor, rename, or behavioral change. The skill re-explores the code and updates accordingly.
- Content needs to migrate out of CLAUDE.md or out of a pile of ad-hoc files into a proper feature doc. The content-audit step ensures nothing gets lost.
- A new feature has landed and you want its doc written before memory fades.

**Do not invoke for:**

- **Technology stack discovery.** Use [`/project-discovery`](./project-discovery.md) to detect languages, frameworks, and tooling.
- **Architectural decisions.** Use [`/architectural-decision-record`](./architectural-decision-record.md).
- **Coding conventions.** Use [`/coding-standard`](../han-coding/coding-standard.md).
- **PR descriptions.** Use [`/update-pr-description`](../han-github/update-pr-description.md).
- **Runbooks for operational scenarios.** Use [`/runbook`](./runbook.md). A runbook captures what to do when an alert fires or a known failure mode occurs; project documentation describes how the feature or system works.
- **An ephemeral, understand-now overview of code or a PR.** Use [`/code-overview`](../han-coding/code-overview.md). It produces a throwaway orientation aid in a scratch file, not durable docs in the repo tree.
- **Rewriting existing prose for readability.** Use [`/edit-for-readability`](./edit-for-readability.md). It rewrites a target you already have against the readability standard; this skill writes and maintains the documentation itself.

## How to invoke it

Run `/project-documentation` with a feature name or document path.

Give it:

1. **The feature or system to document.** *"The authentication system," "event-driven notification flow," "the webhook retry mechanism."*
2. **A file path, optional.** If updating, point at the existing doc. If creating, the skill derives the filename from the feature name in kebab-case.
3. **Known entry points, optional.** If you already know where the feature lives in the code, mention it. The skill's explorer agents find it anyway, but starting hints speed the pass.

Example prompts:

- `/project-documentation`. *"Document the authentication system."*
- `/project-documentation`. *"Update the payments documentation to reflect the new Stripe integration."*
- `/project-documentation`. *"Create documentation for the event-driven notification system. Entry point is `src/notifications/dispatcher.ts`."*
- `/project-documentation docs/webhooks.md`. *"Update this doc. The retry logic changed."*

## What you get back

A feature doc under the project's documentation root plus integration:

- **`docs/{feature-name}.md`.** The feature doc, following the template at [`references/template.md`](../../../han-core/skills/project-documentation/references/template.md). The doc leads with behavior: a plain-language Summary, an Architecture diagram, a How It Works overview, and Primary Flows that narrate the main paths step by step. Diagrams (Architecture, any Primary Flow, and the Component Hierarchy) are rendered as Mermaid, not ASCII. Reference detail (data model, core types, constants, implementation notes, API endpoints, components) sits below under a `## Technical Reference` region for the reader who needs it. Template sections marked CONDITIONAL are omitted when they do not apply.
- **Behavioral overview first.** A reader who only needs to understand what the feature does and how it behaves can stop after Primary Flows and never read the Technical Reference.
- **Absolute file paths** from the repo root.
- **Reference code as pointers and short snippets.** Technical Reference points to the file and function and shows a short snippet only where the source is non-obvious. It does not reproduce long (10-30 line) source blocks; it links to the source instead.
- **Language-specific code fences** matching the project's actual language.
- **`CLAUDE.md` / `AGENTS.md` reference.** A line added in the section most relevant to the feature.
- **Bidirectional cross-references** to related docs.
- **Content audit summary** (when updating). Facts checked, facts present, facts correctly removed, facts missing (and restored).

## How to get the most out of it

- **Run `/project-discovery` first.** The skill uses the discovery reference to find the docs directory and to align code-fence languages with the project's stack.
- **Name entry points if you know them.** The explorer agents find them anyway, but seed paths make the exploration faster.
- **Let the content audit run.** When updating a doc, the audit catches facts the new version silently dropped. Facts that should have been removed need a codebase justification; the agent flags ones that look like accidental drops.
- **Skim the merged discovery summary.** The skill produces a unified D1/D2/D3 list from parallel explorers. If the list misses a file you know is relevant, say so. That is faster than letting the doc miss it.
- **Pair with `/architectural-decision-record`** if the documentation surfaces a decision that was never recorded.
- **Pair with `/coding-standard`** if the documentation surfaces a pattern that should become a rule.

## Cost and latency

The skill dispatches two to three `codebase-explorer` agents in parallel (Step 2), one `content-auditor` agent in update mode (Step 6), one `information-architect` agent before verification (Step 7), and one `readability-editor` agent to rewrite the settled doc (Step 8). All run on their default models. For a medium-size feature, expect a few minutes total. The skill is built for per-feature cadence. Avoid tight-loop iteration on the same doc without changes.

## In more detail

The skill walks a ten-step process:

1. **Evaluate and gather context.** Guard check for ADR/coding-standard topics, resolve the docs directory, derive the target filename, flag whether the content audit will run.
2. **Explore the codebase.** Two to three `codebase-explorer` agents in parallel; merge into a unified D1/D2/D3 discovery summary.
3. **Write the documentation.** Follow the template, leading with behavior (Summary, How It Works, Primary Flows) before the Technical Reference; absolute paths; reference code as pointers and short snippets; language-specific fences; conditional sections omitted; update mode preserves existing structure and flags provisional removals.
4. **Update agent configuration files.** Add the `CLAUDE.md` / `AGENTS.md` reference in the right section with the project's existing pattern.
5. **Cross-reference.** Grep for the feature name across existing docs; add bidirectional references.
6. **Content audit** (when updating). Dispatch `content-auditor`; restore facts classified Missing.
7. **Information-architecture review.** Dispatch `information-architect` against the written doc; apply findability, scannability, and ordering edits.
8. **Readability rewrite.** Dispatch `readability-editor` to rewrite the settled doc against the shared readability standard for a technically-literate reader, preserving every fact and leaving code fences and diagram bodies untouched.
9. **Readability self-check.** Run the standardized readability self-check over the doc's prose regions and correct any failure.
10. **Verification.** Template followed, no placeholders, paths valid, cross-references valid, IA and readability edits applied.

## Sources

The skill's practice is grounded in established technical-documentation convention.

### Stripe: Engineering Documentation Best Practices

Stripe's public-facing writing about the engineering-docs discipline (every reader should land with enough orientation to act, examples must be real and runnable, docs are peer-reviewed) shapes the skill's bias toward concrete examples and bidirectional cross-referencing.

URL: https://stripe.com/blog/writing-documentation

### Write the Docs Community: Technical Writing Handbook

The Write the Docs community's catalog of conventions (topic-based authoring, progressive disclosure, minimalism) shaped the skill's CONDITIONAL-sections pattern and the preference for concrete paths over prose generalities.

URL: https://www.writethedocs.org/guide/

### JoAnn Hackos: Information Development

Hackos's work on topic-based authoring and DITA concept/task/reference distinctions underlies the template's structure. The Summary and How It Works sections are concept, Primary Flows are task-like, and the Technical Reference region (data model, core types, constants, API endpoints) is reference.

URL: https://en.wikipedia.org/wiki/Darwin_Information_Typing_Architecture

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/project-discovery`](./project-discovery.md). Run first. The documentation skill reads the discovery reference to find the docs directory and stack language.
- [`/architectural-decision-record`](./architectural-decision-record.md). Use for decisions rather than system documentation.
- [`/coding-standard`](../han-coding/coding-standard.md). Use for rules rather than descriptions.
- [`/code-overview`](../han-coding/code-overview.md). The ephemeral counterpart: an understand-now overview written to a scratch file, where this skill produces durable docs in the repo tree.
- [`codebase-explorer`](../../agents/han-core/codebase-explorer.md). Dispatched in parallel for code discovery.
- [`content-auditor`](../../agents/han-core/content-auditor.md). Dispatched in update mode to ensure no facts are lost.
- [`information-architect`](../../agents/han-core/information-architect.md). Dispatched before verification to audit findability, scannability, and section ordering.
- [`readability-editor`](../../agents/han-core/readability-editor.md). Dispatched after the IA review to rewrite the settled doc against the shared readability standard, preserving every fact.
- [`SKILL.md` for /project-documentation](../../../han-core/skills/project-documentation/SKILL.md). The internal process definition.
