# Feature Specification: Per-Model Authoring Guidance

A new plugin-building guidance reference that teaches skill and agent authors how Sonnet 5, Opus 4.8, and Fable 5 differ in how they follow instructions, and how those differences should shape the instructions an author writes. It surfaces on demand through the existing guidance skill, and it commits authors to a model-agnostic default so the guidance improves how skills are written without making any skill behave differently at run time.

## Outcome

An author writing or hardening a skill or agent can find guidance that answers "does the model I am targeting change how I should write these instructions, and if so, how?" The guidance gives a clear default (write model-agnostic, which is the fallback for any model), names the few differences big enough to change an authoring decision, and warns about the one difference that can cause an outright failure rather than a stylistic mismatch. An author who applies it writes instructions that suit their target model, or knowingly writes to the safe default when the target is unknown ([D1](artifacts/decision-log.md#d1-a-new-authoring-guidance-reference-distinct-from-tier-selection), [D3](artifacts/decision-log.md#d3-author-time-guidance-that-reaffirms-the-model-agnostic-default)).

The work is done when the reference exists and states the model-agnostic default and its concrete unknown-target form, the opposite-direction instruction-style difference, and the Fable 5 refusal warning with its recognition test; the guidance routing map resolves an author's "how do I write for this model" question to it; and the tier-selection doc carries the reverse cross-reference so neither door orphans a reader.

## Actors and Triggers

- **Actors** — skill authors and agent authors working in a repository that has the plugin-building guidance available, whether through the installed plugin or a vendored copy. The guidance skill is the intermediary that routes an author to the document.
- **Triggers** — an author consults the plugin-building guidance while designing, writing, reviewing, or hardening a skill or agent, and the question of model-specific behavior is in play.
- **Preconditions** — the plugin-building guidance is present, either through the installed `han-plugin-builder` plugin or a vendored in-repo copy.

## Primary Flow

1. An author consults the plugin-building guidance while working on a skill or agent.
2. The guidance skill routes the author's question "how should I write instructions for this model" to the per-model authoring reference through a routing-map entry worded to distinguish that task from "which model tier to run" ([D4](artifacts/decision-log.md#d4-surface-through-the-guidance-routing-map-document-only), [D9](artifacts/decision-log.md#d9-give-the-routing-entry-its-own-bullet-with-task-distinguishing-scent)).
3. The author reads the reference and meets the default first: write model-agnostic instructions unless there is a specific reason to tune for a known model. The document states what that default concretely means when the target is unknown, which is the common case: lead with the goal and the reasons behind it, state the load-bearing constraints and scope explicitly, and avoid exhaustive step-by-step micro-checklists ([D3](artifacts/decision-log.md#d3-author-time-guidance-that-reaffirms-the-model-agnostic-default), [D11](artifacts/decision-log.md#d11-the-concrete-unknown-target-default)).
4. The author reads the instruction-style difference that most changes authoring: Opus 4.8 and Sonnet 5 follow instructions literally and want each behavior spelled out, while Fable 5 does better with a stated goal than with an enumerated checklist ([D2](artifacts/decision-log.md#d2-focus-the-content-on-the-high-impact-differences)).
5. The author reads the one failure-causing warning: on Fable 5, an instruction telling the model to reproduce or transcribe its own internal thinking into its visible deliverable can be refused. The warning carries a recognition test that separates this pattern from asking for a normally-written explanation of a decision, so the author can tell when it applies ([D2](artifacts/decision-log.md#d2-focus-the-content-on-the-high-impact-differences), [D12](artifacts/decision-log.md#d12-a-concrete-test-for-the-refusal-pattern)).
6. The author reads the short supporting notes, each tied to the authoring choice it changes: the thinking-mode note says not to write "think step by step" or thinking-toggle instructions for a model whose thinking is always on, and the effort note says to rely on the effort setting rather than "think harder" prompt hacks ([D2](artifacts/decision-log.md#d2-focus-the-content-on-the-high-impact-differences)).
7. The author applies the guidance to the instructions they are writing, and follows the cross-reference to the tier-selection guidance when the question is which model tier to run rather than how to write for a model ([D5](artifacts/decision-log.md#d5-cross-reference-tier-selection-and-cite-the-research-as-source)).

## Alternate Flows and States

### The author has no known target model

- **Entry condition:** the author does not know which model will run the skill or agent. This is the common case because the operator chooses the model when they run it, and can switch it mid-session, so the author cannot count on a specific target at writing time ([D11](artifacts/decision-log.md#d11-the-concrete-unknown-target-default)).
- **Sequence:** the guidance directs the author to the concrete model-agnostic default (lead with the goal and reasons, state load-bearing constraints and scope explicitly, avoid exhaustive micro-checklists) and treats that default as the generalized fallback for any model outside the three named ones.
- **Exit:** the author writes to the default and reads no further per-model tuning.

### The target is a model the guidance does not name

- **Entry condition:** the author is targeting a model other than Sonnet 5, Opus 4.8, or Fable 5.
- **Sequence:** the guidance states that the model-agnostic default is the fallback, and that per-model tuning applies only to the three named models.
- **Exit:** the author writes to the default.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| An author reads the guidance as license to branch skill content on the running model | The guidance states plainly that it is author-time only, that shipped skills stay model-agnostic, and that run-time model detection is out of scope and not reliable ([D3](artifacts/decision-log.md#d3-author-time-guidance-that-reaffirms-the-model-agnostic-default)). |
| Anthropic revises or archives a named model's prompting page after the guidance is written | The guidance carries a visible currency marker (when it was written and the model versions it was written against) so a reader can judge whether it is still current, names the source it was drawn from so a reader knows what to re-verify against, and discloses that the Fable 5 refusal warning rests on single-vendor, single-source evidence ([D6](artifacts/decision-log.md#d6-carry-a-currency-marker)). |
| An author confuses this guidance with the tier-selection guidance | Each document states its own scope in its opening and cross-references the other in both directions, so an author who lands on either one is pointed to the right one ([D5](artifacts/decision-log.md#d5-cross-reference-tier-selection-and-cite-the-research-as-source), [D10](artifacts/decision-log.md#d10-the-tier-selection-doc-is-a-coordinating-artifact)). |

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| The guidance skill's routing map | inbound | The routing map gains its own entry that routes the "how do I write for this model" author question to the new reference, worded to distinguish it from the tier question | The routing entry and the document ship together, so the map never points at a missing document ([D4](artifacts/decision-log.md#d4-surface-through-the-guidance-routing-map-document-only), [D9](artifacts/decision-log.md#d9-give-the-routing-entry-its-own-bullet-with-task-distinguishing-scent)) |
| The tier-selection guidance | inbound | It gains a reverse cross-reference to the new document and a one-line scope disambiguator | It ships in lockstep with the new document so a reader who enters through the tier doc has a path onward and neither door orphans a reader ([D10](artifacts/decision-log.md#d10-the-tier-selection-doc-is-a-coordinating-artifact)) |
| Repositories that vendor the guidance | outbound | They receive the new reference through the normal refresh of the vendored guidance | The new reference is a guidance reference like the others, so the existing refresh carries it; a repo's routing entry never points at a document it did not receive ([D4](artifacts/decision-log.md#d4-surface-through-the-guidance-routing-map-document-only)) |

## Out of Scope

- Run-time model detection or branching of any kind, and per-model skill or agent variants. The research found no reliable way for a skill to learn its own model at run time, and this feature does not attempt one.
- Editing the content of existing skills or agents to tune them per model.
- The opt-in per-model note for the `readability-guidance` skill. The research lists it as a separate item (its item 3), and this planning was scoped to the author-guidance item only, so it is not planned yet and is tracked out of scope here rather than dropped.
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

- **OI-1:** Whether any existing Han skill or agent already uses the reasoning-echo instruction pattern the new guidance warns against. Checked during review across all prose-producing plugins and found zero matches, so the suite will not contradict its own new guidance.
  - **Resolves when:** resolved. A grep across the plugins returned no hits ([F12](artifacts/team-findings.md)).
  - **Blocks implementation:** No.

## Summary

- **Outcome delivered:** authors get a short, on-demand guidance reference on how the three named models differ in how you should write instructions for them, anchored to a concrete model-agnostic default.
- **Primary actors:** skill authors and agent authors, routed by the plugin-building guidance skill.
- **Decisions settled by evidence:** 10 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** `han-core:junior-developer`, `han-core:information-architect` — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** committed the routing-map entry to task-distinguishing wording, tracked the tier doc's reverse cross-reference as a ship-together coordination, defined the concrete unknown-target default, and added a recognition test and single-source disclosure to the refusal warning — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0
