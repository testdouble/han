# Feature Specification: Readability Standard in the Planning and Coding Skills

Wire Han's shared readability standard into the seven skills that author reader-facing prose but currently skip it, and
clarify the standard's own scope text so those seven deliverables are recognized as reader-facing, so each skill's
output is drafted in voice and checked against the standard before it reaches the user.

## Outcome

Each of the seven target skills sources the shared readability standard while it drafts and holds its output to that
standard before presenting it. The standard's scope text is also clarified so a reader cannot mistake these deliverables
for the machine-only pipeline artifacts the standard excludes
([D9](artifacts/decision-log.md#d9-reader-facing-scope-reconciliation)).

Concretely, when an engineer runs one of these skills:

- The skill sources `han-communication:readability-guidance` into its context before it writes its deliverable, and
  drafts skill-authored prose in the shared voice ([D1](artifacts/decision-log.md#d1-canonical-integration-pattern)).
- After the deliverable's final content exists, the skill runs the standardized six-point readability self-check over
  the prose it authored or changed this run, holding the skill's named reader, and fixes every failure before
  presenting ([D5](artifacts/decision-log.md#d5-per-skill-scope-and-named-audience)).
- The five prose-document skills additionally dispatch the `han-communication:readability-editor` agent for one
  adversarial rewrite pass before the self-check
  ([D2](artifacts/decision-log.md#d2-prose-document-vs-structured-artifact-split-for-the-editor-pass)).
- Every fact, every cross-reference identifier, and every citation survives the readability work unchanged
  ([D3](artifacts/decision-log.md#d3-prose-regions-only-scope-and-fact-fidelity)).

The seven skills are `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, `plan-work-items`, and
`iterative-plan-review` (in `han-planning`), plus `coding-standard` and `test-planning` (in `han-coding`).

## Actors and Triggers

- **Actors** — the engineer who runs one of the seven skills, and the downstream reader of that skill's deliverable
  (a stakeholder reading a spec or phased build, an implementer reading a plan or work items, an engineer following a
  coding standard or a test plan).
- **Triggers** — the engineer invokes one of the seven skills through its slash command or by name.
- **Preconditions** — the foundational `han-communication` plugin resolves for every target skill, so
  `han-communication:readability-guidance` and the `han-communication:readability-editor` agent are reachable. The
  `han-coding` plugin already declares `han-communication` directly; the `han-planning` plugin gains a direct
  `han-communication` dependency as part of this work, because it currently reaches the plugin only transitively through
  `han-core` and Han's convention requires every prose-producing plugin to depend on `han-communication` directly
  ([D4](artifacts/decision-log.md#d4-han-planning-gains-a-direct-han-communication-dependency)). Every target skill already grants the
  `Agent` tool the editor pass needs, so no tool grants change.

## Primary Flow

This flow describes what each target skill does once the readability steps are in place. The steps slot into each
skill's existing workflow at the points named in the Coordinations section.

1. Early in its workflow, before drafting the deliverable, the skill sources the shared readability standard by
   invoking `han-communication:readability-guidance`. The standard is now in the skill's context, and the skill drafts
   its own prose in voice.
2. The skill produces its deliverable's final content through its existing workflow, including any review or synthesis
   step it already runs. When a dispatched agent authors the final content, the readability pass in the next steps is
   what carries voice into that content, since the standard lives in the skill's context rather than the agent's
   ([D6](artifacts/decision-log.md#d6-readability-pass-runs-after-the-final-content-exists)).
3. For the five prose-document skills only: once the final content exists, the skill dispatches one
   `han-communication:readability-editor` agent to audit and rewrite the deliverable's prose regions against the
   standard, passing the skill's named reader and no rule path (the editor reads its own canonical rule), then applies
   the returned rewrite ([D2](artifacts/decision-log.md#d2-prose-document-vs-structured-artifact-split-for-the-editor-pass)).
4. The skill runs the standardized six-point readability self-check over the prose regions it authored or changed this
   run, holding the skill's named reader, confirms each criterion, and fixes any failure before presenting
   ([D5](artifacts/decision-log.md#d5-per-skill-scope-and-named-audience)).
5. The skill presents its deliverable to the user, unchanged in every fact from what the workflow produced.

## Alternate Flows and States

### Structured-artifact skills skip the editor pass

- **Entry condition:** the running skill is `plan-work-items` or `iterative-plan-review`.
- **Sequence:** the skill sources the standard (step 1), produces its content (step 2), then runs the self-check
  (step 4) directly. It does not dispatch the readability-editor agent.
- **Exit:** the deliverable is presented, having passed the self-check but no separate rewrite pass. The self-check's
  fidelity criterion is the only fact-preservation guard these skills carry, so it is mandatory
  ([D2](artifacts/decision-log.md#d2-prose-document-vs-structured-artifact-split-for-the-editor-pass)).

### An in-place skill edits an existing document

- **Entry condition:** the skill changes an existing document rather than authoring one from scratch
  (`iterative-plan-review` refining a plan across iterations; `coding-standard` in its update mode).
- **Sequence:** the readability pass covers the prose regions this run authored or changed, not pre-existing prose the
  skill left untouched. The self-check runs once, on the converged document before it is presented, over those changed
  regions ([D5](artifacts/decision-log.md#d5-per-skill-scope-and-named-audience)).
- **Exit:** the changed prose reads to the standard; prose the run never touched is not re-edited, and cross-reference
  integrity is preserved.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| The deliverable contains code fences, tables, diagram bodies, frontmatter, or citation identifiers (file:line, D#/T#/F# links, work-item IDs). | The readability work operates on prose regions only and leaves those regions unchanged. |
| The readability-editor agent's rewrite would drop or alter a fact, a quantity, a named entity, or a stated qualifier. | The rewrite is rejected on that point; the fact is preserved with its precision intact. Fidelity wins over voice. |
| A dispatched agent (for example a project-manager synthesis) authors the deliverable's final content. | The standard reaches that content through the after-the-fact pass, not through the authoring agent: the editor pass for the five prose-document skills, the self-check for the two structured-artifact skills ([D6](artifacts/decision-log.md#d6-readability-pass-runs-after-the-final-content-exists)). |
| A skill already runs a synthesis, review, or IA step near the end of its workflow (`plan-a-feature`'s project-manager synthesis; the review steps in `plan-a-phased-build`, `coding-standard`, and `test-planning`). | The readability pass runs after that step produces the final content, so it never fights an authoritative later step ([D6](artifacts/decision-log.md#d6-readability-pass-runs-after-the-final-content-exists)). |
| `plan-a-phased-build` has already asked the user which audience the outline targets (engineering, mixed, or customer-facing). | The readability pass holds that per-run audience, rather than a fixed frame ([D5](artifacts/decision-log.md#d5-per-skill-scope-and-named-audience)). |

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| `han-communication:readability-guidance` skill | outbound | Each target skill invokes it to source the standard into context. | Must run before the target skill drafts its deliverable. |
| `han-communication:readability-editor` agent | outbound | The five prose-document skills dispatch it for one adversarial rewrite pass, passing the named reader and no rule path. | Must run after the final content exists and after any final synthesis or review step, and before the self-check. |
| The readability standard's scope text (`readability-rule.md`) | inbound and updated | The seven skills reference the single canonical standard rather than vendoring it. This work also clarifies the standard's "who reads reader-facing output" scope text so Han's plans-of-record are recognized as reader-facing ([D9](artifacts/decision-log.md#d9-reader-facing-scope-reconciliation)). | A change to the standard reaches all seven skills with no edit to them, because they reference the one canonical copy ([D7](artifacts/decision-log.md#d7-reference-the-single-canonical-standard-never-vendor-it)). |

## Out of Scope

- Changing what the readability standard *requires* (the self-check criteria, the voice profile, the fidelity rule).
  The only edit to the standard is the narrow scope-text clarification in D9; the rules the standard enforces are
  untouched.
- Adding readability integration to skills that already have it, that do not author prose (`tdd`, `refactor`), or that
  only republish or transform prose an upstream source produced. This includes the publishing wrappers (Confluence,
  Jira, GitHub, Linear) and the work-items publishers, whose gaps close when their upstream source skill is integrated,
  and `markdown-to-confluence`, which republishes user-provided prose verbatim and authors none of its own. This list
  is illustrative, not the full enumeration; the full 38-skill classification is recorded under
  [D8](artifacts/decision-log.md#d8-scope-is-exactly-these-seven-skills).
- The long-form documentation updates for the seven skills. Documentation maintenance is handled by the repo's own
  documentation skill after these edits land.

## Open Items

- **OI-1:** Whether the D9 scope-text clarification should also be reflected in the `readability-guidance` skill's own
  in-context summary of who is reader-facing, or only in the canonical `readability-rule.md`.
  - **Resolves when:** implementation confirms whether the guidance skill restates the scope test verbatim or points to
    the rule.
  - **Blocks implementation:** No.

## Summary

- **Outcome delivered:** Seven prose-authoring skills source and apply the shared readability standard before
  presenting their deliverables, and the standard's scope text is clarified to recognize those deliverables as
  reader-facing.
- **Primary actors:** The engineer running each skill and the downstream reader of its output.
- **Decisions settled by evidence:** 7 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** han-core:junior-developer, han-core:gap-analyzer — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** Added a direct `han-communication` dependency for `han-planning`, reframed the
  full/lightweight split around deliverable type rather than "synthesis pass", and reconciled the feature against the
  standard's own reader-facing scope text — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
