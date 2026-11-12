# Scope Boundary: Investigation Types

## Work Item

No work item exists. The operator's request, typed when invoking `/han-planning:plan-a-change`, is the only boundary
this run has.

## Stated Scope

> update the `/investigate` skill so that there are investigation types, similar to what was done for the code review
> skill. the initial set of modes are "bug" and "how it works", and "available options". the current implementation is
> built for investigating bugs. but a lot of the investigation i do is not centered around bugs, but rather
> investigation into how the code works and what options are available for doing work. the specifics of each mode,
> including the output template, need to be split around these types. if no type is specified when calling
> `/investigate`, determine the type automatically via the prompt context. if a type is specified, first validate that
> the specified type is acceptable for the prompt, and suggest an alternative type when needed. once a type is
> determined, run the skill with that specific type

## Stated Exclusions

None stated.

## Operator-Stated Scope

Confirmed in the Step 1.5 confirmation turn, in answer to the proposed area, the `research` overlap, and the plan
location:

> i agree with your split recommendation between research and investigate. this all looks good

The confirmed area:

1. `han-coding/skills/investigate/`: `SKILL.md` (including its `description` and `argument-hint`) and
   `references/template.md`, split per type.
2. The documentation that describes `investigate`: `han-coding/docs/skills/investigate.md`, the `han-coding/README.md`
   scent line, `docs/skills/README.md`, and the workflow and how-to pages that mention it.
3. `han-atlassian/skills/investigate-to-confluence/`, which wraps `investigate` and describes itself as bug-only, plus
   its long-form doc.
4. The `investigate` evals under `evals/investigate/`.
5. The `research` skill's description and docs, reworded to the agreed split: `investigate` answers questions about
   this codebase; `research` covers the open web and prior art.

Plan location confirmed: `docs/plans/investigate-types/`.

### Added during the run

Asked whether to add one line to the `code-overview` and `code-walkthrough` descriptions pointing single "how does X
work" questions to `/investigate`, the operator chose:

> Add the line (Recommended)

This brings one more surface into the area:

6. The `code-overview` and `code-walkthrough` descriptions and their long-form docs, each gaining one boundary
   sentence that sends a single question about how the code behaves to `/investigate`.

## Direction of Travel

The bug-only shape of `investigate` is being replaced by a typed shape whose first type, `bug`, carries today's
behavior. Nothing is deprecated outright. The `research` skill stays, with its boundary against `investigate`
redrawn.

## Visual Material Received

None received. This skill plans code structure; the visual-material convention does not apply.

## Record Provenance

Established by `plan-a-change` on 2026-11-12. No prior record existed and no conflict was resolved.
Amended on 2026-11-12 with the operator's answer above; it adds to the area and excludes nothing recorded earlier.
