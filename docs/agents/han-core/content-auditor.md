# content-auditor

Operator documentation for the `content-auditor` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han-core/agents/content-auditor.md`](../../../han-core/agents/content-auditor.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md)

## TL;DR

- **What it does.** Audits an updated documentation set against the original source content to ensure no important facts were lost. Classifies each fact as Present / Correctly Removed / Missing. Validates removals against the codebase. Identifies content that must be restored.
- **When to dispatch it.** A document was rewritten, migrated, or consolidated and you need to verify nothing was silently dropped. Dispatched by `/project-documentation` when updating an existing doc, by `/gap-analysis` as a swarm specialist when the desired state is documentation, and by `/iterative-plan-review` team mode when the plan under review is documentation.
- **What you get back.** Numbered `A#` audit items, each with the fact, its source, the classification, and evidence. Evidence might be where the fact appears in the new doc, what codebase check confirmed a removal, or why the fact must be restored. It also includes an Audit Summary with counts.

## Key concepts

- **Default posture: content was lost until proven otherwise.** The agent treats every silent omission as a potential loss until classified explicitly.
- **Three classifications.** Present (fact appears, possibly reworded, with semantic equivalence verified), Correctly Removed (fact no longer applies and the codebase confirms it), Missing (fact is still true but absent from the new doc).
- **Removals must be validated.** *"Correctly Removed"* is provisional until the agent checks the codebase. If the referenced file, function, behavior, configuration, or type still exists, the classification flips to Missing.
- **Semantic equivalence has a high bar.** *"The service retries 3 times"* and *"The service has retry logic"* are not equivalent if the retry count matters. Generic restatements that lose specifics are silent loss.
- **Preservation, not creation.** The agent suggests restorations from the source. It does not propose new content.

## When to use it

**Dispatch when:**

- `/project-documentation` is updating an existing doc or migrating content from CLAUDE.md or ad-hoc files. The skill always dispatches this agent in update mode.
- A team has rewritten a long-form doc and wants confirmation that the new version preserves all the load-bearing facts from the old version.
- A consolidation effort moved content from many small files into one larger doc and you want to audit the consolidation for silent loss.
- A doc has been translated or restructured and you want a pre-merge check before the old version is deleted.
- `/gap-analysis` is running and the desired state is documentation. The skill dispatches this agent as a swarm specialist to audit for silently dropped content.
- `/iterative-plan-review` is in team mode and the plan under review is documentation. The skill dispatches this agent to verify the documentation preserves its load-bearing facts.

**Do not dispatch for:**

- Two-artifact comparison where both artifacts are independent (spec vs. implementation, PRD vs. shipped feature). Use `gap-analyzer` and `/gap-analysis`. The content-auditor validates a single before-and-after; the gap-analyzer compares two distinct artifacts.
- IA review of the doc's structure or findability. Use `information-architect`.
- Fact-checking against the codebase as the source of truth (rather than a prior version of the doc). Use `evidence-based-investigator`.
- Drafting documentation. Use `/project-documentation`.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:content-auditor`. Give it:

1. **The path to the new/updated document.**
2. **A list of all source content.** The original doc, relevant CLAUDE.md sections, any other files content was migrated from. The agent needs to see every place a fact could have lived.

Example prompts:

- *"Audit `docs/payments.md` against the original `docs/old-payments.md` and the `## Payments` section that was deleted from CLAUDE.md. Verify no facts were silently dropped."*
- *"The team consolidated five small files in `docs/legacy-billing/` into one new `docs/billing.md`. Audit the new file against all five sources."*

## What you get back

- Numbered `A#` audit items, each with: the fact, its source location (file path plus location within the document), classification, and evidence.
- An **Audit Summary** with counts: facts checked, Present, Correctly Removed, Missing.
- A **Missing Content** section for each Missing item: the fact to restore, the section it belongs in, and suggested wording that fits the new document's style.

## How to get the most out of it

- **Provide every source.** If content was migrated from multiple files, list them all. A fact that lived in only one source and never made it into the new doc is exactly the case the agent catches.
- **Run it before deleting the old version.** The agent's value is highest before the source is gone. If the source has already been deleted, the audit cannot run.
- **Read the Missing section first.** Every entry is a fact the agent thinks should be restored. Each suggestion includes wording that fits the new doc's style.
- **Trust the strict semantic-equivalence bar.** When the agent flags a fact as Missing because the new doc has a generic restatement, the agent is usually right. Specifics matter.

## Cost and latency

The agent runs on `haiku` (cheap, fast). A focused audit runs in under a minute. Cost scales with the size of the source content.

## Sources

The agent's posture is grounded in editorial-rigor practice.

### Bonnie Birdsall: Content Preservation in Documentation Migrations

Documentation-migration practice (Stripe, Atlassian, Confluence) treats silent fact-loss as the primary failure mode of any rewrite. The agent's three-classification scheme is the engineering-applied version of this discipline.

URL: https://www.writethedocs.org/conf/talks/

### IEEE 1063: Standard for Software User Documentation

IEEE 1063 establishes that user documentation must preserve facts about behavior, constraints, and configuration through revisions. The agent's fact extraction follows this taxonomy directly.

URL: https://standards.ieee.org/ieee/1063/2554/

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [Agents Index](../README.md). All agents, grouped by role.
- [`gap-analyzer`](./gap-analyzer.md). Sibling agent for comparing two distinct artifacts (spec vs. implementation).
- [`information-architect`](./information-architect.md). Sibling agent for IA structure of the new doc.
- [`/project-documentation`](../../skills/han-core/project-documentation.md). Always dispatches this agent in update mode.
- [`/gap-analysis`](../../skills/han-core/gap-analysis.md). Dispatches this agent as a swarm specialist when the desired state is documentation.
- [`/iterative-plan-review`](../../skills/han-planning/iterative-plan-review.md). Dispatches this agent in team mode when the plan under review is documentation.
