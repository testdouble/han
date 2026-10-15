# Scope Boundary: Code Review Types

## Work Item

No work item exists. The operator's request, typed when invoking `/han-planning:plan-a-change`, is the only boundary this
run has.

## Stated Scope

> for the han-coding:code-review skill. i want to be able to specify a review "type", such as "code-review
> work-ticket", where the code review will verify that the implementation actually resolves the work ticket. for this
> type, a work ticket link or reference must be provided. for example, i might call "/han-coding:code-review
> work-ticket docs/tickets/my-ticket.md", or "/hand-coding:code-review work-ticket {work ticket url}". the general goal
> behind this is to replace the current sizing options for code reviews, with a code review "type". there will be a
> default set of code review types, each of which is represented with a reference file in the skill folder, such as
> "references/types/work-ticket.md". these files will contain specific instructions for the review type, including a
> list of custom agents to use during the review. example review types that i currently know of, which would be
> included in the list: "work-ticket", "architecture", "testing", "observability", etc. general instructions for the
> flow of the review would still belong in the code-review skill itself, including adversarial validation, yagni, etc.
> but specifics would be moved away from a sizing to choose custom agents, into the review type reference files, so
> reviews can be parallelized, focused, and valuable by keeping concerns better separated

## Stated Exclusions

None stated.

## Operator-Stated Scope

Confirmed in the Step 1.5 confirmation turn, in answer to whether three adjacent surfaces are in the area:

> include all three of those items. that plan location is fine

The three items are:

1. `han-github/skills/post-code-review-to-pr`, which invokes `/code-review` and passes the operator's arguments through.
2. code-review's reading of the `default-swarm-size` setting in `.han/config.md`. The setting itself stays, because
   other skills read it; whether code-review keeps reading it is in scope.
3. The documentation: code-review's long-form doc and `docs/sizing.md`.

### Added during the run

Given the question of whether configured extra agents join a focused review, the operator answered:

> allow the han config file to specify specific custom agents to be included in specific review types. additionally,
> the config file must be able to specify new review types that can be used - for example, a financial institution may
> want to add a "pii-check" review type, or a healthcare company may want to add a "hipaa-compliance" check. these are
> not review types that will be included in Han, but can be built out by clients using Han

This brings two more surfaces into the area:

4. The `.han/config.md` schema: the canonical `han-core/references/config-rule.md`, its byte-identical vendored copies,
   and `docs/configuration.md`, so the config can declare review types and attach agents to a type.
5. Review types that live outside Han, written by the people who use it. Han ships none of them.

## Direction of Travel

The size options for code review (`small | medium | large | dynamic`) are being replaced by review types. This is the
operator's stated intent: "replace the current sizing options for code reviews, with a code review 'type'".

## Visual Material Received

None received. This skill plans code structure; the visual-material convention does not apply.

## Record Provenance

Established by `plan-a-change` on 2026-10-14. No prior record existed and no conflict was resolved.
Amended on 2026-10-14 with the operator's answer above; it adds to the area and excludes nothing recorded earlier.
