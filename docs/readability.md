# Readability

Readability is the output-quality standard of the han plugin. Every reader-facing skill applies one shared readability rule while it writes, so its human-facing deliverable leads with the main point, uses plain language, reveals detail in layers, and reads consistently across skills instead of being restated skill by skill.

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [YAGNI](./yagni.md) · [Evidence](./evidence.md) · [All skills](./skills/README.md) · [All agents](./agents/README.md)

## TL;DR

- **One shared rule, applied as skills write.** Reader-facing skills load and apply the readability rule at runtime, the same way they use the shared YAGNI and evidence rules. Output stays consistent because the rule lives in one place, not because each skill restates it.
- **A different kind of standard.** Sizing, YAGNI, and evidence are near-universal decision mechanics. Readability is an output standard scoped to the skills whose deliverable is prose a non-author reads. It is its own category, not a fourth universal mechanic.
- **Applied in stages, never as one block.** The rule's structural rules shape each skill's output template; its testable criteria run as a discrete self-check after the draft exists. Stacking it all as one instruction would reproduce the failure it exists to dodge.
- **Synthesis skills rewrite; the rest self-check.** A skill with a synthesis or editor step dispatches the [`readability-editor`](./agents/han-core/readability-editor.md) to rewrite the draft, preserving every fact. Every in-scope skill runs the standardized self-check.
- **Fidelity wins.** No required fact is dropped to read more simply. Every claim, quantity, named entity, and stated condition survives with its precision intact.
- **The canonical rule lives in [`han-core/references/readability-rule.md`](../han-core/references/readability-rule.md).** Every reader-facing skill loads that file at runtime. This page is the operator-facing summary.

## Why readability matters

A skill's output is only useful if the person who did not do the work can find, understand, and use it. An investigation that buries its root cause under three paragraphs of context, a stakeholder summary that opens with methodology instead of the decision, or a code overview whose headings all read "Analysis" makes the reader do the author's work over again. Without a shared standard:

- Each skill re-derives its own plain-language guidance, and the output reads differently from one skill to the next.
- The main point lands wherever the drafting happened to leave it, not at the top.
- Dense, technical deliverables get either unreadable or, worse, simplified until a load-bearing fact is lost.

The standard fixes the first two by naming the output properties once and applying them everywhere. It guards against the third by making fidelity outrank every readability move.

## What the standard requires

The rule names the output properties, and they shape each skill's template so the draft is born with them:

- **Main point first.** The opening line states the main point. A reader who stops after one sentence still gets the answer.
- **One idea per paragraph.** Each paragraph carries one idea, and its first sentence carries the weight.
- **Descriptive headings.** Each heading names its content ("Why the request times out"), not a generic label ("Analysis").
- **Short, active sentences.** Roughly fifteen to twenty words on average, active by default. The self-check flags any sentence past about thirty words as a candidate to split. That is a review trigger, not a hard cap.
- **Common words.** Prefer the common word over the technical synonym; define a term on first use when it cannot be replaced.
- **No blocklisted words.** The existing writing-voice blocklist is reused for word-level rules.
- **Numbered lists for steps, bullets for the rest.**
- **Progressive disclosure.** Reveal the core first and detail in layers.
- **Technical detail follows the prose.** Keep implementation and technical references (symbol names, file paths, flags, exact code) out of the readable paragraphs where you can. Where a reference has to appear inline, keep it as small as the sentence needs. Otherwise the detail comes after the prose that describes it, in code fences the prose has already explained.

The applied set is kept deliberately tight. Structural rules that fit only a minority of deliverables are left out on purpose, so the set stays small enough to apply without the compliance decay that comes from stacking instructions.

## How the standard is applied

Each skill applies the rule in stages, one at a time:

1. **Template.** The skill's output template carries the structural rules, so the draft is structured from the start.
2. **Audience frame.** While drafting, the skill writes for a capable reader who did not do the work and lacks the author's context. Five engineer-facing skills name a more specific reader instead (see the table below).
3. **Rewrite pass (synthesis skills only).** A skill with a synthesis or editor step dispatches the [`readability-editor`](./agents/han-core/readability-editor.md) to audit and rewrite the draft against the rule, preserving every fact.
4. **Self-check.** A discrete pass over the prose regions evaluates six behaviorally-anchored yes/no criteria: main point first, descriptive headings, one idea per paragraph, sentence length, no blocklisted word, and every fact preserved. Anything it fails is corrected before the deliverable is presented.

The self-check and any rewrite operate on **prose regions only**. Code fences, diagram bodies, rendered markup, and inline citation identifiers are neither evaluated nor altered, so they still compile, render, and resolve.

## Scope: which skills are reader-facing

A skill is in scope when its primary deliverable is human-facing prose that a non-author reads end to end; the table below enumerates the skills that meet that test today. Skills whose primary output is code, or a governed structured artifact (a specification, plan, work-item, or coding standard), are out of scope.

| Skill | Reader | Rewrite pass |
|---|---|---|
| [`/research`](./skills/han-core/research.md) | Default frame | Synthesis: dispatches `readability-editor` |
| [`/gap-analysis`](./skills/han-core/gap-analysis.md) | Default frame | Synthesis (at consolidated report sizes): dispatches `readability-editor` |
| [`/project-documentation`](./skills/han-core/project-documentation.md) | A technically-literate reader who needs to understand the feature before reading its code | Synthesis: dispatches `readability-editor` |
| [`/issue-triage`](./skills/han-core/issue-triage.md) | Default frame | Self-check only |
| [`/runbook`](./skills/han-core/runbook.md) | Default frame | Self-check only |
| [`/architectural-decision-record`](./skills/han-core/architectural-decision-record.md) | Default frame | Self-check only |
| [`/code-overview`](./skills/han-coding/code-overview.md) | Default frame | Synthesis: dispatches `readability-editor` |
| [`/investigate`](./skills/han-coding/investigate.md) | The engineer who will implement the fix and may be paged on the bug | Synthesis: dispatches `readability-editor` |
| [`/code-review`](./skills/han-coding/code-review.md) | The author and reviewers of the change under review | Synthesis: dispatches `readability-editor` |
| [`/architectural-analysis`](./skills/han-coding/architectural-analysis.md) | The engineer weighing the module's design | Synthesis: dispatches `readability-editor` |
| [`/stakeholder-summary`](./skills/han-reporting/stakeholder-summary.md) | The non-technical stakeholder | Synthesis: dispatches `readability-editor` |
| [`/html-summary`](./skills/han-reporting/html-summary.md) | The non-technical stakeholder | Self-check only (prose content; visual layout keeps its own conventions) |
| [`/update-pr-description`](./skills/han-github/update-pr-description.md) | The reviewer evaluating the pull request, who will read the code | Synthesis: dispatches `readability-editor` |

The enumerated list is authoritative. A contributor adding a new skill applies the inclusion test above and, if it passes, wires the standard in (see [Contributing](../CONTRIBUTING.md#wiring-the-readability-standard-into-a-skill)).

## Fidelity: the fact-preservation guard

The standard governs *how* content is said, never whether a required fact appears. When reading more simply would drop or blur a fact, fidelity wins. Every claim, quantity, named entity, and stated condition survives with its precision intact. Flattening "exceeded 340ms in three of ten windows" to "was sometimes slow," or "only when X and Y both hold" to "generally," is a fidelity failure, not a simplification.

On a synthesis skill, the `readability-editor` preserves every fact as it rewrites. On a non-synthesis skill that runs no rewrite pass, the self-check's fact-preservation criterion is the only fidelity guard the output has, so it is not optional.

## What readability is not

- **Not a comprehension score.** The standard commits to observable properties of the text and a concrete self-check, not to a promise about a reader's comprehension or a readability-formula target. Formulas are weak comprehension proxies that reward gaming; they are not the measure the standard optimizes.
- **Not CI or prose linting.** Most reader-facing output is ephemeral conversational or scratch text with no build surface to lint. The standard applies at generation time, not as a pipeline gate.
- **Not a rewrite of the operator-documentation voice.** The existing writing-voice profile continues to govern operator docs. This standard reuses its blocklist but does not rewrite it.
- **Not a guarantee a committed file stays conformant.** The one in-scope skill that writes a committed file ([`/project-documentation`](./skills/han-core/project-documentation.md)) is covered at generation time. A later manual edit is not re-checked automatically. Run [`/edit-for-readability`](./skills/han-core/edit-for-readability.md) to re-apply the standard to an edited file on demand.

## Design principles

- **One source of truth.** The rule lives in one canonical file and is vendored byte-for-byte into every plugin that ships an in-scope skill. A contributor changes the rule in one place.
- **Applied in stages, not stacked.** The template, the audience frame, the rewrite pass, and the self-check each carry part of the rule, so no single step stacks enough instructions to decay.
- **Fidelity outranks readability.** The one rule the standard never bends: a required fact is never dropped to read more simply.
- **Loading is not compliance.** Loading the rule does not make output readable. The template, the audience frame, the rewrite pass, and the self-check are what make it take effect.

## Related reading

- [`han-core/references/readability-rule.md`](../han-core/references/readability-rule.md). The canonical rule every reader-facing skill loads at runtime.
- [`readability-editor`](./agents/han-core/readability-editor.md). The agent the synthesis skills dispatch for the rewrite pass.
- [`/edit-for-readability`](./skills/han-core/edit-for-readability.md). The standalone skill that applies this standard on demand to a file, pasted text, or a conversation draft.
- [Concepts](./concepts.md). The skill / agent split, and where readability sits among the plugin's mechanics.
- [YAGNI](./yagni.md) and [Evidence](./evidence.md). The other shared rules, vendored and summarized the same way.
- [Contributing](../CONTRIBUTING.md). The wiring procedure a contributor follows to bring a new skill under the standard.
- [Writing voice](../han-core/references/writing-voice.md). The voice profile whose blocklist the standard reuses for word-level rules.
