# Feature Specification: Per-Model Authoring Guidance

A new plugin-building guidance reference that teaches skill and agent authors how Sonnet 5, Opus 4.8, and Fable 5 differ in how they follow instructions, and how those differences should shape the instructions an author writes. It surfaces on demand through the existing guidance skill, and it commits authors to a model-agnostic default so the guidance improves how skills are written without making any skill behave differently at run time.

## Outcome

An author writing or hardening a skill or agent can find guidance that answers "does the model I am targeting change how I should write these instructions, and if so, how?" The guidance gives a clear default (write model-agnostic, which is the fallback for any model), names the few differences big enough to change an authoring decision, and warns about the one difference that can cause an outright failure rather than a stylistic mismatch. An author who applies it writes instructions that suit their target model, or knowingly writes to the safe default when the target is unknown ([D1](artifacts/decision-log.md#d1-a-new-authoring-guidance-reference-distinct-from-tier-selection), [D3](artifacts/decision-log.md#d3-author-time-guidance-that-reaffirms-the-model-agnostic-default)).

## Actors and Triggers

- **Actors** — skill authors and agent authors working in a repository that has the plugin-building guidance available, whether through the installed plugin or a vendored copy. The guidance skill is the intermediary that routes an author to the document.
- **Triggers** — an author consults the plugin-building guidance while designing, writing, reviewing, or hardening a skill or agent, and the question of model-specific behavior is in play.
- **Preconditions** — the plugin-building guidance is present, either through the installed `han-plugin-builder` plugin or a vendored in-repo copy.

## Primary Flow

1. An author consults the plugin-building guidance while working on a skill or agent.
2. The guidance skill matches the author's need to its routing map and points to the per-model authoring reference ([D4](artifacts/decision-log.md#d4-surface-through-the-guidance-routing-map-document-only)).
3. The author reads the reference and meets the default first: write model-agnostic instructions unless there is a specific reason to tune for a known model ([D3](artifacts/decision-log.md#d3-author-time-guidance-that-reaffirms-the-model-agnostic-default)).
4. The author reads the instruction-style difference that most changes authoring: Opus 4.8 and Sonnet 5 follow instructions literally and want each behavior spelled out, while Fable 5 does better with a stated goal than with an enumerated checklist ([D2](artifacts/decision-log.md#d2-focus-the-content-on-the-high-impact-differences)).
5. The author reads the one failure-causing warning: on Fable 5, an instruction telling the model to echo or transcribe its own reasoning into its visible answer can be refused, so authors avoid that instruction pattern where it matters ([D2](artifacts/decision-log.md#d2-focus-the-content-on-the-high-impact-differences)).
6. The author reads the short supporting notes on thinking mode and on effort and subagent eagerness, kept brief because they rarely change an authoring decision on their own ([D2](artifacts/decision-log.md#d2-focus-the-content-on-the-high-impact-differences)).
7. The author applies the guidance to the instructions they are writing, and follows the cross-reference to the tier-selection guidance when the question is which model tier to run rather than how to write for a model ([D5](artifacts/decision-log.md#d5-cross-reference-tier-selection-and-cite-the-research-as-source)).

## Alternate Flows and States

### The author has no known target model

- **Entry condition:** the author does not know which model will run the skill or agent, which is the common case because a skill cannot reliably detect its own model at run time.
- **Sequence:** the guidance directs the author to the model-agnostic default and treats that default as the generalized fallback for any model outside the three named ones.
- **Exit:** the author writes to the default and reads no further per-model tuning.

### The target is a model the guidance does not name

- **Entry condition:** the author is targeting a model other than Sonnet 5, Opus 4.8, or Fable 5.
- **Sequence:** the guidance states that the model-agnostic default is the fallback, and that per-model tuning applies only to the three named models.
- **Exit:** the author writes to the default.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| An author reads the guidance as license to branch skill content on the running model | The guidance states plainly that it is author-time only, that shipped skills stay model-agnostic, and that run-time model detection is out of scope and not reliable ([D3](artifacts/decision-log.md#d3-author-time-guidance-that-reaffirms-the-model-agnostic-default)). |
| Anthropic revises or archives a named model's prompting page after the guidance is written | The guidance carries a visible currency marker (the date it was last checked and the models it was written against) so a reader can judge whether it is still current, and names the source it was drawn from ([D6](artifacts/decision-log.md#d6-carry-a-currency-marker)). |
| An author confuses this guidance with the tier-selection guidance | Each document states its own scope in its opening and cross-references the other, so an author lands on the right one ([D5](artifacts/decision-log.md#d5-cross-reference-tier-selection-and-cite-the-research-as-source)). |

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| The guidance skill's routing map | inbound | The routing map gains an entry that points authors to the new reference | The routing entry and the document ship together, so the map never points at a missing document ([D4](artifacts/decision-log.md#d4-surface-through-the-guidance-routing-map-document-only)) |
| The in-repo vendored copy of the guidance | outbound | Repositories that vendor the guidance pick up the new reference the next time they install or refresh it | The document lives with the other guidance references so it is carried along by the existing install and refresh, with no separate wiring ([D4](artifacts/decision-log.md#d4-surface-through-the-guidance-routing-map-document-only)) |

## Out of Scope

- Run-time model detection or branching of any kind, and per-model skill or agent variants. The research found no reliable way for a skill to learn its own model at run time, and this feature does not attempt one.
- Editing the content of existing skills or agents to tune them per model.
- The opt-in per-model note for the `readability-guidance` skill. That is a separate item from the research and is planned on its own.
- Prompting the author for a target model inside the skill-builder or agent-builder interviews. Authors reach this guidance the same way they reach every other guidance document ([D4](artifacts/decision-log.md#d4-surface-through-the-guidance-routing-map-document-only)). See Deferred (YAGNI).
- Changing how the `model` frontmatter field or model tiers are chosen. That is the tier-selection guidance's job, and this document cross-references it rather than restating it.

## Deferred (YAGNI)

### Prompting for a target model inside the skill-builder and agent-builder interviews

- **Why deferred:** no evidence yet that authors ship model-mismatched instructions often enough to justify adding an interview decision to two more skills. The simpler version, a guidance document surfaced on demand, satisfies the stated need (an author can find and apply per-model guidance).
- **Reopen when:** authors are observed repeatedly shipping instructions that fight their target model, or a decision is made to make the builders model-aware for another reason.
- **Source:** user choice during the interview (scope-boundary question).

### Comprehensive per-model sections mirroring Anthropic's full pages

- **Why deferred:** the lighter axes (verbosity defaults, design and frontend defaults, tokenizer notes) were not shown to change an authoring decision, and mirroring them enlarges the surface to keep current against pages that get revised and archived.
- **Reopen when:** a documented divergence on one of those lighter axes starts causing real authoring mistakes.
- **Source:** user choice during the interview (content-depth question).

## Open Items

- None at draft time. The review team populates this section if it surfaces anything.

## Summary

- **Outcome delivered:** authors get a short, on-demand guidance reference on how the three named models differ in how you should write instructions for them, anchored to a model-agnostic default.
- **Primary actors:** skill authors and agent authors, routed by the plugin-building guidance skill.
- **Decisions settled by evidence:** 4 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0
