# /architectural-decision-record

Operator documentation for the `/architectural-decision-record` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/architectural-decision-record/SKILL.md`](../../../han.core/skills/architectural-decision-record/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Creates, extracts, converts, or updates an ADR (Architectural Decision Record) using the ADR template.
- **When to use it.** An architectural or design choice has been made (or is about to be) and needs to be recorded with rationale, alternatives considered, and consequences.
- **What you get back.** A hierarchically-named ADR under `docs/adr/` with Context, Decision Drivers, Considered Options, Decision, Consequences, and Notes, plus a reference added to `CLAUDE.md`.

## Key concepts

- **Three modes.** Creating new, Converting existing (from a general doc or meeting notes), Updating existing (status change, superseding, adding notes).
- **Decision, not rule.** ADRs record *what was decided and why*, with rejected alternatives. A coding rule goes in a coding standard; a decision goes here.
- **Codebase-grounded.** When creating a new ADR with sparse context, the skill dispatches one or two `codebase-explorer` agents to find the code and docs that motivate the decision.
- **Architectural review before writing.** Unless the skill is running in update-only mode, three agents run in parallel against the proposed decision: an architect (`software-architect` for intra-codebase decisions, `system-architect` for cross-service decisions) to surface structural risks and the strongest case for each rejected alternative; `risk-analyst` to score the chosen option and each alternative on likelihood, severity, blast radius, and reversibility; and `junior-developer` to catch unexplained jargon and unjustified dismissals.
- **Hierarchically-prefixed filenames.** `{top-level}[-{second-level}]-{kebab-case-title}.md`. A one- or two-level hierarchy prefix (for example, `auth-tokens-rotation.md`) discovered at runtime from existing ADRs and project context, so related decisions sort together in a directory listing.
- **Status lifecycle.** `proposed` → `accepted` → `superseded` / `deprecated`. The skill handles status transitions explicitly.

## When to use it

**Invoke when:**

- You are about to commit to an architectural choice (technology, pattern, boundary) and want the rationale and alternatives on record.
- A decision was made in a meeting or thread and you want it captured as an ADR before context fades.
- A document already exists (design doc, RFC, Slack thread summary) that should be promoted to an ADR.
- An existing ADR is being superseded by a new one and you want both records updated cleanly.
- A code review surfaced a decision that was never recorded. Record it now rather than re-litigate it later.

**Do not invoke for:**

- **Enforceable coding rules.** Use [`/coding-standard`](./coding-standard.md). An ADR records the decision; a coding standard encodes the rule it produces.
- **Feature documentation.** Use [`/project-documentation`](./project-documentation.md).
- **Recording an investigation's findings.** Use [`/investigate`](./investigate.md) for bug investigations with evidence and validation.
- **Runbooks for operational scenarios.** Use [`/runbook`](./runbook.md). A runbook captures the procedure for an alert or incident; an ADR records the decision that shaped the system the runbook operates on.

## How to invoke it

Run `/architectural-decision-record` with a topic or an existing document path.

Give it:

1. **The topic or title.** What the decision is about: *"Soft deletes vs hard deletes," "PostgreSQL over MySQL," "Moving to event-driven notifications."*
2. **The decision.** What was chosen and the core reason. Even a thin summary lets the skill start; thicker context reduces question prompts.
3. **Alternatives considered.** The options that lost. An ADR without rejected alternatives is weaker than one that records them.
4. **A source document, optional.** To convert an RFC, design doc, or Slack-thread export into an ADR, pass the path.

Example prompts:

- `/architectural-decision-record`. *"Create an ADR for our decision to use PostgreSQL over MySQL. Main driver was row-level security; alternatives were MySQL with application-level isolation and SQL Server."*
- `/architectural-decision-record docs/soft-deletes.md`. *"Convert `docs/soft-deletes.md` into an ADR."*
- `/architectural-decision-record`. *"Extract an ADR from the caching-strategy discussion in the design doc at `docs/caching.md`. The decision was Redis with a five-minute TTL."*
- `/architectural-decision-record`. *"Mark `docs/adr/jobs-sync-processing.md` as superseded by the new async-jobs ADR we just wrote."*

## What you get back

An ADR in the project's ADR directory, plus integration:

- **`docs/adr/{top-level}[-{second-level}]-{title}.md`.** The ADR itself, following the template at [`references/template.md`](../../../han.core/skills/architectural-decision-record/references/template.md). The hierarchy prefix is discovered from existing ADRs and the project's subsystems, bounded contexts, frameworks, and runtimes so related decisions sort together. Required sections: Context, Decision Drivers, Considered Options, Decision, Consequences, Notes (with a key-files table and cross-references).
- **Status.** `proposed` for new, `accepted` for converted, `deprecated` / `superseded` for updates. Superseding ADRs cross-reference each other.
- **A reference added to `CLAUDE.md` / `AGENTS.md`** in the section most relevant to the decision.
- **Cross-references.** Links to related ADRs, coding standards, feature docs; bidirectional where it adds value.
- **Source-document handling** (conversion mode). Source is deleted if fully subsumed, or linked and trimmed if it retains useful content.

## How to get the most out of it

- **Name the alternatives that lost.** The value of an ADR is not in naming the winner. It is in recording why the others lost. An ADR without rejected alternatives is half an ADR.
- **State the decision drivers.** What forces shaped the choice: cost, compliance, scale, team expertise, existing tooling? These are the pieces a future reader needs to judge whether the decision is still valid.
- **Run `/project-discovery` first.** The skill uses CLAUDE.md's Project Discovery section to find the ADR directory and to ground the codebase-explorer agents.
- **Pair with `/coding-standard`** when the decision implies enforceable rules. The ADR records the decision; the standard encodes the rule and links back to the ADR.
- **Re-run to update status.** When an ADR is superseded, re-run the skill in update mode. It updates the old ADR's status, sets the new one's `Supersedes` metadata, and cross-references both.

## Cost and latency

The skill dispatches one or two `codebase-explorer` agents in create-new mode (Step 3), followed by three parallel review agents (an architect, either `software-architect` or `system-architect`, plus `risk-analyst` and `junior-developer`) that run against the proposed decision unless the ADR is update-only (status change). All agents run on their default models. Typical runs are a few minutes; the architectural review adds a short fan-out.

## In more detail

The skill walks a six-step process:

1. **Determine mode.** Creating new / Converting existing / Updating existing.
2. **Discover project structure.** Find the ADR directory (or create one), enumerate existing ADRs, check format compatibility, and discover the filename hierarchy taxonomy from existing ADRs' filenames plus the project's subsystems, bounded contexts, and technologies.
3. **Gather context.** Topic, decision, alternatives. In create-new mode with sparse context, dispatch one or two `codebase-explorer` agents to gather evidence. Then dispatch `software-architect` or `system-architect`, `risk-analyst`, and `junior-developer` in parallel to stress-test the decision and rejected alternatives (skipped in update-only mode).
4. **Write the ADR.** Conversion-mapping for source documents, hierarchically-prefixed filename (top-level subsystem/context, optional second level), fill the template with concrete content. The Notes section includes a key-files table with Glob-verified paths.
5. **Integration.** `CLAUDE.md` / `AGENTS.md` reference, cross-references in both directions, source-document handling.
6. **Verification.** Metadata filled, sections substantive, cross-references valid, source-document handled.

## YAGNI

An ADR requires a **forcing function today**. A real decision being made now, with consequences. ADRs about decisions that don't have a forcing function (no current code path under decision, no migration in flight, no constraint actively pushing the team toward one option), or that document hypothetical futures, are YAGNI candidates and are not written. Acceptable evidence the ADR is needed now: the team is choosing between options *today*, an existing constraint or contract makes the decision necessary now, a regulatory or compliance rule applies today, or a documented incident or measured metric forces the decision.

When the forcing function isn't there, the candidate ADR moves to a `## Deferred (YAGNI)` entry in the team's open-questions log with the trigger that would justify reopening it. ADRs are durable artifacts; speculative ADRs become load-bearing documents future agents treat as established convention, which is exactly the failure mode YAGNI prevents.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

The companion [evidence rule](../../evidence.md) applies to the citations that justify the chosen option and the rejected alternatives. Name the trust class of each citation (codebase, web, provided); mark single-source web claims that drive the chosen option; when no evidence at any tier supports a claimed trade-off, label it rather than presenting it as a weak preference.

## Sources

The skill's practice is grounded in established architectural-decision-record convention.

### Michael Nygard: Documenting Architecture Decisions

Nygard's 2011 blog post established the modern ADR format: short, Markdown, focused on Context / Decision / Consequences. The skill's template traces to this lineage.

URL: https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions

### Spotify: ADR Process

Spotify's engineering-blog description of their ADR workflow codifies the proposed → accepted → superseded lifecycle and the practice of recording alternatives. The skill's status handling follows this model.

URL: https://engineering.atspotify.com/2020/04/when-should-i-write-an-architecture-decision-record

### ThoughtWorks: Lightweight Architecture Decision Records

ThoughtWorks's Technology Radar has long recommended lightweight ADRs as the default architectural-documentation practice. The skill's bias toward concise, decision-focused records (not prose documents that happen to mention a decision) comes from this tradition.

URL: https://www.thoughtworks.com/radar/techniques/lightweight-architecture-decision-records

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies before committing items. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Evidence](../../evidence.md). The companion rule the skill applies to the ADR's citations: trust classes, the corroboration gate for web sources, and the no-evidence label.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/coding-standard`](./coding-standard.md). For rules that come out of a decision. Link the standard to the ADR.
- [`/architectural-analysis`](./architectural-analysis.md). Often produces decisions worth recording as ADRs.
- [`/project-documentation`](./project-documentation.md). For feature docs that reference the ADR.
- [`codebase-explorer`](../../agents/han.core/codebase-explorer.md). Dispatched in create-new mode for context discovery.
- [`software-architect`](../../agents/han.core/software-architect.md), [`system-architect`](../../agents/han.core/system-architect.md). One of the two reviews the proposed decision; pick by whether the decision is intra-codebase or cross-service.
- [`risk-analyst`](../../agents/han.core/risk-analyst.md). Scores the chosen option and rejected alternatives on likelihood, severity, blast radius, and reversibility.
- [`junior-developer`](../../agents/han.core/junior-developer.md). Catches unexplained jargon and unjustified dismissals before the ADR is written.
- [`SKILL.md` for /architectural-decision-record](../../../han.core/skills/architectural-decision-record/SKILL.md). The internal process definition.
