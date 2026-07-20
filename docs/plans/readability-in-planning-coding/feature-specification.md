# Feature Specification: Readability Standard in the Planning and Coding Skills

Wire Han's shared readability standard into the seven skills that author user-facing prose but currently skip it, so
each skill's deliverable is drafted in voice and checked against the standard before it reaches the user.

## Outcome

Each of the seven target skills sources the shared readability standard while it drafts and holds its output to that
standard before presenting it. Concretely, when an engineer runs one of these skills:

- The skill sources `han-communication:readability-guidance` into its context before it writes its deliverable, and
  drafts in the shared voice ([D1](artifacts/decision-log.md#d1-canonical-integration-pattern)).
- After the draft exists, the skill runs the standardized six-point readability self-check over the deliverable's prose
  regions and fixes every failure before presenting.
- The five synthesis skills additionally dispatch the `han-communication:readability-editor` agent for one adversarial
  rewrite pass before the self-check, matching the rule that reserves that pass for synthesis output
  ([D2](artifacts/decision-log.md#d2-synthesis-rule-split)).
- Every fact, every cross-reference identifier, and every citation survives the readability work unchanged
  ([D3](artifacts/decision-log.md#d3-prose-regions-and-fidelity)).

The seven skills are `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, `plan-work-items`, and
`iterative-plan-review` (in `han-planning`), plus `coding-standard` and `test-planning` (in `han-coding`).

## Actors and Triggers

- **Actors** — the engineer who runs one of the seven skills, and the downstream reader of that skill's deliverable
  (a stakeholder reading a spec or phased build, an implementer reading a plan or work items, an engineer following a
  coding standard or a test plan).
- **Triggers** — the engineer invokes one of the seven skills through its slash command or by name.
- **Preconditions** — the foundational `han-communication` plugin is installed, so `han-communication:readability-guidance`
  and the `han-communication:readability-editor` agent resolve. Every target plugin already declares a dependency chain
  that reaches `han-communication`, and every target skill already grants the `Agent` tool the editor pass needs
  ([D4](artifacts/decision-log.md#d4-no-tooling-or-dependency-changes)).

## Primary Flow

This flow describes what each target skill does once the readability steps are in place. The steps slot into each
skill's existing workflow at the points named in the Coordinations section.

1. Early in its workflow, before drafting the deliverable, the skill sources the shared readability standard by
   invoking `han-communication:readability-guidance`. The standard is now in the skill's context.
2. The skill drafts its deliverable into its own template, building the structural rules in as it writes (main point
   first, descriptive headings, one idea per paragraph, technical detail after the prose).
3. For the five synthesis skills only: once the full draft exists, the skill dispatches one
   `han-communication:readability-editor` agent to audit and rewrite the deliverable's prose regions against the
   standard, then applies the returned rewrite ([D2](artifacts/decision-log.md#d2-synthesis-rule-split)).
4. The skill runs the standardized six-point readability self-check over the deliverable's prose regions, confirms each
   criterion, and fixes any failure before presenting.
5. The skill presents its deliverable to the user, unchanged in every fact from what the workflow produced.

## Alternate Flows and States

### Lightweight skills skip the editor pass

- **Entry condition:** the running skill is `plan-work-items` or `iterative-plan-review`.
- **Sequence:** the skill sources the standard (step 1), drafts (step 2), then runs the self-check (step 4) directly.
  It does not dispatch the readability-editor agent.
- **Exit:** the deliverable is presented, having passed the self-check but no separate rewrite pass. The self-check's
  fidelity criterion is the only fact-preservation guard these skills carry, so it is mandatory
  ([D2](artifacts/decision-log.md#d2-synthesis-rule-split)).

### A skill writes companion artifact files alongside its primary deliverable

- **Entry condition:** the skill produces companion files (for example `plan-a-feature`'s decision log, team findings,
  and technical notes; `iterative-plan-review`'s findings and iteration files).
- **Sequence:** the readability work targets the prose the skill authors for the user to read. Each skill names which
  regions its readability pass covers, so structured cross-reference machinery is left alone
  ([D5](artifacts/decision-log.md#d5-per-skill-scope-and-audience)).
- **Exit:** the primary deliverable reads to the standard; the companion files keep their cross-reference integrity.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| The deliverable contains code fences, tables, diagram bodies, or citation identifiers (file:line, D#/T#/F# links). | The readability work operates on prose regions only and leaves those regions byte-for-byte unchanged. |
| The readability-editor agent's rewrite would drop or alter a fact, a quantity, a named entity, or a stated qualifier. | The rewrite is rejected on that point; the fact is preserved with its precision intact. Fidelity wins over voice. |
| A skill already runs a synthesis pass that owns final content (for example `plan-a-feature`'s project-manager synthesis). | The readability pass runs after that synthesis produces the final content, so it never fights an authoritative later step ([D6](artifacts/decision-log.md#d6-ordering-after-final-synthesis)). |
| `iterative-plan-review` runs multiple review iterations over one plan. | The readability self-check runs once, on the converged plan before it is presented, not on every intermediate iteration ([D5](artifacts/decision-log.md#d5-per-skill-scope-and-audience)). |

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| `han-communication:readability-guidance` skill | outbound | Each target skill invokes it to source the standard into context. | Must run before the target skill drafts its deliverable. |
| `han-communication:readability-editor` agent | outbound | The five synthesis skills dispatch it for one adversarial rewrite pass. | Must run after the full draft exists and after any final synthesis step, and before the self-check. |
| The readability standard's own definition (`readability-rule.md`, `writing-voice.md`) | inbound | Sourced transitively through the guidance skill; never vendored or copied into the target skills. | The target skills reference the single canonical copy, so a change to the standard reaches all seven with no edit to them ([D7](artifacts/decision-log.md#d7-single-canonical-source)). |

## Out of Scope

- Changing the readability standard itself, the `readability-guidance` skill, or the `readability-editor` agent. This
  feature only makes the seven skills consume the existing standard.
- Adding readability integration to skills that already have it, that do not author user-facing prose (`tdd`,
  `refactor`), or that inherit their prose from an upstream skill (the Confluence, Jira, GitHub, and Linear publishing
  wrappers; the work-items publishers). Those inherited gaps close when their upstream source skill is integrated
  ([D8](artifacts/decision-log.md#d8-seven-skill-scope)).
- The long-form documentation updates for the seven skills. Documentation maintenance is handled by the repo's own
  documentation skill after these edits land.

## Open Items

- **OI-1:** Populated by the review team and project-manager synthesis in later steps.
  - **Resolves when:** review is complete.
  - **Blocks implementation:** No.

## Summary

- **Outcome delivered:** Seven prose-authoring skills source and apply the shared readability standard before
  presenting their deliverables.
- **Primary actors:** The engineer running each skill and the downstream reader of its output.
- **Decisions settled by evidence:** 7 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 1 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** pending — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
