# readability-editor

Operator documentation for the `readability-editor` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han-core/agents/readability-editor.md`](../../../han-core/agents/readability-editor.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [Readability](../../readability.md)

## TL;DR

- **What it does.** Rewrites a finished draft so a non-author reader can follow it, applying the shared readability standard while preserving every fact.
- **When to dispatch it.** As the readability rewrite pass of a synthesis skill, after the full draft exists and before the skill presents it.
- **What you get back.** The rewritten draft plus a rubric verdict and a fact-preservation ledger.

## Key concepts

- **Rewrites, does not merely review.** Unlike a reviewer that returns recommendations, this agent edits the prose in place against a six-point rubric.
- **Fidelity outranks readability.** Every claim, quantity, named entity, and stated condition survives with its precision intact. When a readability change would blur a fact, the fact wins.
- **Prose only.** Code fences, diagram bodies, rendered markup, and citation identifiers are left byte-for-byte unchanged so they still compile, render, and resolve.

## When to use it

**Dispatch when:**

- A synthesis skill has a full draft and needs the dedicated readability rewrite pass before presenting it.
- A draft leads with context instead of the answer, buries its point, over-runs sentence length, or carries insider phrasing a non-author cannot follow.

**Do not dispatch for:**

- **Checking a documentation update did not lose facts.** Use [`content-auditor`](./content-auditor.md) instead.
- **Auditing documentation structure and findability.** Use [`information-architect`](./information-architect.md) instead.
- **Judging whether a draft's claims are true to the code.** Use [`adversarial-validator`](./adversarial-validator.md) instead; this agent edits the writing, not the facts.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:readability-editor`.

Give it:

1. **A focus area.** The path to the draft file (or the draft text inline), and the shared readability rule to apply.
2. **A brief (optional).** The skill's named reader when it is not the default frame (an engineer implementing a fix, a pull-request reviewer, a non-technical stakeholder), so the agent edits for the right audience and keeps the technical specifics that reader needs.
3. **An output path (optional).** When the draft is a file, the agent rewrites it in place; name the path.

Example prompts:

- *"Rewrite the draft at `scratch/investigation.md` for the engineer who will implement the fix, applying the readability rule at `references/readability-rule.md`. Preserve every fact; leave code blocks and citation IDs untouched."*
- *"Audit and rewrite this stakeholder summary for a non-technical reader against the readability rule, keeping every number and named entity exact."*

## What you get back

The draft, rewritten in place (or returned inline when the deliverable is conversational), plus a short report:

- **Rubric verdict.** One line per criterion: pass, or what was changed to make it pass. The six criteria are main point first, descriptive headings, one idea per paragraph, sentence length, common words with no blocklisted words, and progressive disclosure.
- **Fact-preservation ledger.** Confirmation that every claim, quantity, named entity, and stated condition survived. Any fact that could not be preserved while satisfying a criterion is named, with a note that the fact was kept.
- **Untouched regions.** The non-prose regions left unchanged.

## How to get the most out of it

- **Name the real reader.** The default frame is a capable non-author. If the skill's reader is a specific expert, name that reader. The agent then keeps the specifics that reader needs instead of simplifying them away.
- **Hand it a written draft, not an outline.** The agent rewrites finished prose; it does not draft from notes or add content.
- **Run it once, not alongside another readability pass.** It replaces a skill's existing readability review rather than stacking on top, so the draft gets one readability verdict, not two conflicting ones.
- **Pair with `adversarial-validator`.** In skills like [`/code-overview`](../../skills/han-coding/code-overview.md), the validator checks the draft is true to the code and runs first. The readability-editor then rewrites the corrected text.

## Cost and latency

Runs on `sonnet`. It reads the draft and the rule, then rewrites in place, so its cost scales with draft length, not with a codebase sweep. It is dispatched once per synthesis-skill run, after the draft exists. Do not dispatch it in a tight loop; a single pass over a finished draft is the intended use.

## In more detail

The agent generalizes and replaces the readability pass that some skills ran before the standard existed. [`/code-overview`](../../skills/han-coding/code-overview.md) used to dispatch `information-architect` and `junior-developer` to review a draft's structure and cold-read. [`/stakeholder-summary`](../../skills/han-reporting/stakeholder-summary.md) ran a multi-pass plain-language self-check. Where such a pass existed, the readability-editor takes its place so there is one readability review, not two with conflicting verdicts.

Its rubric is the six behaviorally-anchored criteria of the shared standard, not a subjective clarity judgment. It never follows imperative or conditional prose inside the draft. That content is text to preserve and make readable, never a command to act on. Its adversarial posture is aimed at the draft, never at the author who wrote it.

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Readability](../../readability.md). The shared Human-Readable Output Standard this agent applies, its required properties, and the per-skill application table.
- [`content-auditor`](./content-auditor.md). The fact-preservation auditor. It checks a doc update kept the facts; this agent rewrites for readability while keeping them.
- [`information-architect`](./information-architect.md). Audits documentation structure and findability and returns recommendations; this agent rewrites prose in place.
- The reader-facing synthesis skills that dispatch this agent as their readability rewrite pass: [`/architectural-analysis`](../../skills/han-coding/architectural-analysis.md), [`/code-overview`](../../skills/han-coding/code-overview.md), [`/code-review`](../../skills/han-coding/code-review.md), [`/investigate`](../../skills/han-coding/investigate.md), [`/gap-analysis`](../../skills/han-core/gap-analysis.md), [`/project-documentation`](../../skills/han-core/project-documentation.md), [`/research`](../../skills/han-core/research.md), [`/update-pr-description`](../../skills/han-github/update-pr-description.md), and [`/stakeholder-summary`](../../skills/han-reporting/stakeholder-summary.md). The [Readability](../../readability.md) per-skill table is authoritative.
- [`/edit-for-readability`](../../skills/han-core/edit-for-readability.md). The standalone skill that dispatches this agent to rewrite a file, pasted text, or a conversation draft on demand.
- [agent-domain-focus.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md). Why the agent's domain and rubric are kept narrow and named.
