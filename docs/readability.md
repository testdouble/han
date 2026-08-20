# Readability

Readability is the output-quality standard of the han plugin. Every reader-facing skill applies one shared readability
rule while it writes. That keeps every deliverable consistent: each one leads with the main point, uses plain language,
and reveals detail in layers, instead of each skill restating the rule on its own.

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [YAGNI](./yagni.md) ·
> [Evidence](./evidence.md) · [All skills](./skills/README.md) · [All agents](./agents/README.md)

## TL;DR

- **One shared rule, applied as skills write.** Reader-facing skills source the readability standard by invoking
  `han-communication:readability-guidance`, which surfaces the rule into the calling skill's own context as it writes.
  Output stays consistent because the rule lives in one place, not because each skill restates it.
- **A different kind of standard.** Sizing, YAGNI, and evidence are near-universal decision mechanics. Readability is an
  output standard scoped to the skills whose deliverable is prose a non-author reads. It is its own category, not a
  fourth universal mechanic. It also has a sibling: the
  [explanation standard](../han-communication/references/explanation-rule.md) governs what a run says to a person in a
  turn, where readability governs the shape of a written deliverable. A skill that drafts a document and also stops to
  ask a question sources both, at different moments.
- **Applied in stages, never as one block.** The rule's structural rules shape each skill's output template; its
  testable criteria run as a discrete self-check after the draft exists. Stacking it all as one instruction would
  reproduce the failure it exists to dodge.
- **Synthesis skills rewrite; the rest self-check.** A skill with a synthesis or editor step dispatches the
  [`readability-editor`](../han-communication/docs/agents/readability-editor.md) to rewrite the draft, preserving every fact.
  Every in-scope skill runs the standardized self-check.
- **Fidelity wins, unless the reader asked for less.** Every claim, quantity, named entity, and stated condition
  survives with its precision intact. A reader who asked for less can lose a fact, unless losing it would change
  what they do next.
- **Session-wide is opt-in.** Selecting the `Han Readability` output style holds the standard across every turn, not
  only inside a reader-facing skill. It reaches the main conversation, never a dispatched subagent.
- **The canonical rule lives in
  [`han-communication/references/readability-rule.md`](../han-communication/references/readability-rule.md).** Every
  reader-facing skill sources it cross-plugin by invoking `han-communication:readability-guidance`. This page is the
  operator-facing summary.

## Why readability matters

A skill's output is only useful if the person who did not do the work can find, understand, and use it. An investigation
can bury its root cause under three paragraphs of context. A stakeholder summary can open with methodology instead of
the decision. A code overview's headings can all read "Analysis." Each of these makes the reader redo the author's work.
Without a shared standard:

- Each skill re-derives its own plain-language guidance, and the output reads differently from one skill to the next.
- The main point lands wherever the drafting happened to leave it, not at the top.
- Dense, technical deliverables get either unreadable or, worse, simplified until a load-bearing fact is lost.

The standard fixes the first two by naming the output properties once and applying them everywhere. It guards against
the third by making fidelity outrank every readability move the reader did not ask for.

## What the standard requires

The rule names the output properties, and they shape each skill's template so the draft is born with them:

- **Main point first.** The opening line states the main point. A reader who stops after one sentence still gets the
  answer.
- **One idea per paragraph.** Each paragraph carries one idea, and its first sentence carries the weight.
- **Descriptive headings.** Each heading names its content ("Why the request times out"), not a generic label
  ("Analysis").
- **Short, active sentences.** Roughly fifteen to twenty words on average, active by default. The self-check flags any
  sentence past about thirty words as a candidate to split. That is a review trigger, not a hard cap.
- **Common words, and a half-sentence explanation for a term the reader cannot look up.** Prefer the common word over
  the technical synonym. Where a term cannot be replaced, explain it in half a sentence at first use. Three kinds always
  need it, because the reader has nowhere to resolve them from the material the document describes: outside
  technologies and language runtimes, named statistical or numerical methods, and compound nouns the document coins for
  its own convenience. The coined ones matter most, since a reader can search for the other two and find an answer.
- **No blocklisted words.** The existing writing-voice blocklist is reused for word-level rules.
- **Numbered lists for steps, bullets for the rest.**
- **Progressive disclosure.** Reveal the core first and detail in layers.
- **Technical detail follows the prose.** Separate it by default. The readable sentences say what happens, and the
  implementation and technical references (symbol names, file paths, flags, exact code) come after them, in a code fence
  or a trailing line the prose has already explained. Inline is the exception, for the one reference a sentence is
  genuinely about.

The applied set is kept deliberately tight. Structural rules that fit only a minority of deliverables are left out on
purpose. That keeps the set small enough to apply without the compliance decay that comes from stacking instructions.

## How the standard is applied

Each skill sources the standard by invoking `han-communication:readability-guidance` at its drafting point (the
guidance skill surfaces the rule and writing-voice profile into the skill's own context), then applies it in stages, one
at a time:

1. **Template.** The skill's output template carries the structural rules, so the draft is structured from the start.
2. **Audience frame.** While drafting, the skill writes for a capable reader who did not do the work and lacks the
   author's context. Five engineer-facing skills name a more specific reader instead (see the table below).
3. **Rewrite pass (synthesis skills only).** A skill with a synthesis or editor step dispatches the
   [`readability-editor`](../han-communication/docs/agents/readability-editor.md) to audit and rewrite the draft against the
   rule, preserving every fact.
4. **Self-check.** A discrete pass over the prose regions evaluates behaviorally-anchored yes/no criteria: main
   point first, descriptive headings, one idea per paragraph, sentence length, common words with no blocklisted word
   and an explanation for every term the reader cannot look up, technical detail separated from the sentences, every
   fact preserved, and the shape the reader asked for in count, format, and register. Anything it fails is corrected before the deliverable is presented. The last
   criterion wins a real collision with the others, except where a dropped fact would change what the reader does
   next, or where a skill requires a section.

The self-check and any rewrite operate on **prose regions only**. Code fences, diagram bodies, rendered markup, and
inline citation identifiers are neither evaluated nor altered, so they still compile, render, and resolve.

## Applying the standard to a whole session

The path above covers a skill's deliverable. To hold the standard across every turn instead, including the conversation
around a skill and the work no skill covers, select one of the two output styles `han-communication` ships. Choose it
under **Output style** in `/config`. It takes effect on your next session or after `/clear`, because Claude Code reads
the output style once at session start.

[`Han Readability`](../han-communication/output-styles/han-readability.md) distills the rule's audience frame, output
properties, fidelity guard, and self-check together with the writing-voice blocklist. Pick it when the session's output
is prose someone reads cold.

[`Han Concise`](../han-communication/output-styles/han-concise.md) carries the same properties and departs from the rule
twice. A turn drops preamble and recap and spends no sentence that carries neither a fact nor a needed transition. And in place of `Fidelity wins`, it assumes
you want less than the source carries, so supporting detail rolls up into the statement it supports rather than waiting
for you to ask; a roll-up has to be true of everything it covers, and three things stay at full precision: a fact whose
loss would change what you do next, a number you will act on, and a stated condition that bounds when a claim holds.
Pick it for a working session you read in the terminal.

Both departures belong to the style, so they reach the conversation and not Han's skills.

Neither style changes how work is done. Both keep Claude Code's built-in software engineering instructions.

Both styles share the same three limits:

- **It does not reach subagents.** A subagent runs its own system prompt, so the style leaves Han's dispatched
  specialists unchanged. The skills stay the mechanism that brings the standard to agent output.
- **It carries the built-in voice only.** A static system prompt cannot run the `.han/config.md` probe, so a configured
  `writing-voice` profile does not override it the way it overrides `readability-guidance`.
- **It is a derived copy.** The canonical rule and voice profile stay authoritative. When you edit either one, check
  whether the styles need the same change.

## Scope: which skills are reader-facing

A skill is in scope when its primary deliverable is human-facing prose that a non-author reads end to end. A structured
specification, plan, phased build, work-item list, coding standard, or test plan also counts when a human reads it end
to end, whether to approve it, follow it, or grab work from it. A structured artifact consumed only by downstream skills
as machine input, with no human reading it end to end, is out of scope, and so is code output. The table below lists the
skills that meet that test today.

| Skill                                                                                                 | Reader                                                                                    | Rewrite pass                                                              |
| ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| [`/research`](../han-research/docs/skills/research.md)                                                | Default frame                                                                             | Synthesis: dispatches `readability-editor`                                |
| [`/gap-analysis`](../han-research/docs/skills/gap-analysis.md)                                        | Default frame                                                                             | Synthesis (at consolidated report sizes): dispatches `readability-editor` |
| [`/project-documentation`](../han-documentation/docs/skills/project-documentation.md)                 | A technically-literate reader who needs to understand the feature before reading its code | Synthesis: dispatches `readability-editor`                                |
| [`/issue-triage`](../han-research/docs/skills/issue-triage.md)                                        | Default frame                                                                             | Self-check only                                                           |
| [`/runbook`](../han-documentation/docs/skills/runbook.md)                                             | Default frame                                                                             | Self-check only                                                           |
| [`/architectural-decision-record`](../han-documentation/docs/skills/architectural-decision-record.md) | Default frame                                                                             | Self-check only                                                           |
| [`/code-overview`](../han-coding/docs/skills/code-overview.md)                                        | Default frame                                                                             | Synthesis: dispatches `readability-editor`                                |
| [`/investigate`](../han-coding/docs/skills/investigate.md)                                            | The engineer who will implement the fix and may be paged on the bug                       | Synthesis: dispatches `readability-editor`                                |
| [`/code-review`](../han-coding/docs/skills/code-review.md)                                            | The author and reviewers of the change under review                                       | Synthesis: dispatches `readability-editor`                                |
| [`/architectural-analysis`](../han-coding/docs/skills/architectural-analysis.md)                      | The engineer weighing the module's design                                                 | Synthesis: dispatches `readability-editor`                                |
| [`/stakeholder-summary`](../han-reporting/docs/skills/stakeholder-summary.md)                         | The non-technical stakeholder                                                             | Synthesis: dispatches `readability-editor`                                |
| [`/html-summary`](../han-reporting/docs/skills/html-summary.md)                                       | The non-technical stakeholder                                                             | Self-check only (prose content; visual layout keeps its own conventions)  |
| [`/update-pr-description`](../han-github/docs/skills/update-pr-description.md)                        | The reviewer evaluating the pull request, who will read the code                          | Synthesis: dispatches `readability-editor`                                |
| [`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md)                                    | The stakeholder or reviewer who reads the spec                                            | Synthesis: dispatches `readability-editor`                                |
| [`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md)                          | The engineer who will build the feature                                                   | Synthesis: dispatches `readability-editor`                                |
| [`/plan-a-phased-build`](../han-planning/docs/skills/plan-a-phased-build.md)                          | The reader of the phased build (mixed engineering / product by default)                   | Synthesis: dispatches `readability-editor`                                |
| [`/plan-work-items`](../han-planning/docs/skills/plan-work-items.md)                                  | The engineer who grabs a work item and implements it                                      | Self-check only                                                           |
| [`/iterative-plan-review`](../han-planning/docs/skills/iterative-plan-review.md)                      | The reader of the plan the review refines                                                 | Self-check only                                                           |
| [`/coding-standard`](../han-coding/docs/skills/coding-standard.md)                                    | The engineer who must follow the standard                                                 | Synthesis: dispatches `readability-editor`                                |
| [`/automated-test-planning`](../han-coding/docs/skills/automated-test-planning.md)                    | The engineer who will implement the tests                                                 | Synthesis: dispatches `readability-editor`                                |
| [`/manual-test-planning`](../han-coding/docs/skills/manual-test-planning.md)                          | The person who runs the tests by hand, who may not be technical                           | Synthesis: dispatches `readability-editor`                                |

This list is authoritative. A contributor adding a new skill applies the inclusion test above and, if it passes, wires
the standard in (see [Contributing](../CONTRIBUTING.md#wiring-the-readability-standard-into-a-skill)).

## Fidelity: the fact-preservation guard

The standard governs _how_ content is said, and drops a required fact only when the reader asked for less and losing it
would not change what they do next. When reading more simply would drop or blur a fact, fidelity wins. Every claim,
quantity, named entity, and stated condition survives with its precision intact. Flattening "exceeded 340ms in three of
ten windows" to "was sometimes slow," or "only when X and Y both hold" to "generally," is a fidelity failure, not a
simplification.

On a synthesis skill, the `readability-editor` preserves every fact as it rewrites. On a non-synthesis skill that runs
no rewrite pass, the self-check's fact-preservation criterion is the only fidelity guard the output has, so it is not
optional.

## What readability is not

- **Not a comprehension score.** The standard commits to observable properties of the text and a concrete self-check,
  not to a promise about a reader's comprehension or a readability-formula target. Formulas are weak comprehension
  proxies that reward gaming; they are not the measure the standard optimizes.
- **Not CI or prose linting.** Most reader-facing output is ephemeral conversational or scratch text with no build
  surface to lint. The standard applies at generation time, not as a pipeline gate.
- **Not a rewrite of the operator-documentation voice.** The existing writing-voice profile continues to govern operator
  docs. This standard reuses its blocklist but does not rewrite it.
- **Not a guarantee a committed file stays conformant.** The in-scope skills that write a committed file (for example
  [`/project-documentation`](../han-documentation/docs/skills/project-documentation.md) and
  [`/coding-standard`](../han-coding/docs/skills/coding-standard.md)) are covered at generation time. A later manual edit is
  not re-checked automatically. Run
  [`/edit-for-readability`](../han-communication/docs/skills/edit-for-readability.md) to re-apply the standard to an edited
  file on demand.

## Design principles

- **One source of truth.** The rule lives in one canonical file in the foundational `han-communication` plugin; no
  plugin vendors a copy. Every consuming skill sources it cross-plugin by invoking
  `han-communication:readability-guidance`, so a contributor changes the rule in one place.
- **Applied in stages, not stacked.** The template, the audience frame, the rewrite pass, and the self-check each carry
  part of the rule, so no single step stacks enough instructions to decay.
- **Fidelity outranks readability, unless the reader asked for less.** A required fact is never dropped to read more
  simply. When the reader asked for less, a fact may go, unless losing it would change what they do next.
- **Loading is not compliance.** Loading the rule does not make output readable. The template, the audience frame, the
  rewrite pass, and the self-check are what make it take effect.

## Related reading

- [`han-communication/references/readability-rule.md`](../han-communication/references/readability-rule.md). The
  canonical rule every reader-facing skill sources via `han-communication:readability-guidance`.
- [`/readability-guidance`](../han-communication/docs/skills/readability-guidance.md). The skill that surfaces the standard
  into a calling skill's context for in-voice drafting and self-check.
- [`readability-editor`](../han-communication/docs/agents/readability-editor.md). The agent the synthesis skills dispatch for
  the rewrite pass.
- [`/edit-for-readability`](../han-communication/docs/skills/edit-for-readability.md). The standalone skill that applies this
  standard on demand to a file, pasted text, or a conversation draft.
- [`Han Readability`](../han-communication/docs/output-styles/han-readability.md). The output style that holds the
  standard across a whole session, and the boundaries it does not reach.
- [Concepts](./concepts.md). The skill / agent split, and where readability sits among the plugin's mechanics.
- [YAGNI](./yagni.md) and [Evidence](./evidence.md). The other shared rules, summarized the same way (they remain
  vendored per-plugin; readability is now sourced cross-plugin from `han-communication`).
- [Contributing](../CONTRIBUTING.md). The wiring procedure a contributor follows to bring a new skill under the
  standard.
- [Writing voice](../han-communication/references/writing-voice.md). The voice profile whose blocklist the standard
  reuses for word-level rules.
