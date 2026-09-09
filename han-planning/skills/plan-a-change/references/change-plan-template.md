# Change Plan Template

## Contents

- How to use this template
- The template

Copy the template below whole into `{folder}/change-plan.md` and fill it. Remove a section only when the rule beside its
heading says it may be removed. A section with nothing in it says so in words rather than being left out, because an
absent section and an empty one are different states.

The audience is the engineer who will make the change. Name types, modules, files, and methods freely; that precision is
what the plan is for. Do not inline whole file bodies or prescribe line-level edits.

## The template

```markdown
# Change Plan: {change name}

## Why This Change

The recorded reason, in plain language, in two to four sentences. Name which of the six reason classes it is and cite
the source: a report path, an ADR, a ticket, or the user's own words. A reader who stops here knows what prompted the
work.

## What Changes, In One Paragraph

The target state in plain language, before any element names. What is the code answerable for after this change that it
was not arranged to be answerable for before? A reader who stops here can describe the shape of the result.

## Current State

What the code does today, at the altitude a reader needs to follow the delta. Cite the numbered findings that establish
each claim: `([C-3](artifacts/current-state-findings.md#c-3-session-owns-four-responsibilities))`. Do not restate the
findings file; summarize it and link.

Name the specific structural property the change addresses, and the evidence for it.

## Target State

The structure that exists after the change. Lead with plain language, then the element names.

For each part of the target structure, name what it is answerable for and what it is not. Where two parts must agree on
a contract — a call signature, a payload shape, an error contract, a lifecycle order — pin it here in concrete form: a
signature, a field layout, or a worked example. A contract named but not pinned is a contract invented during the build.

## Surface Delta

Every element the change removes, adds, moves, renames, or re-scopes, one entry each. Each entry carries `Target state`,
`Behavior`, `Why`, and `Decision`; `Depends on` and `Migration` appear when they apply. A `Target state` is written so
it would still be correct and complete if every other entry were deleted.

Order entries so an entry's dependencies appear before it.

### S-1: `{element}` — {Removed | Added | Moved | Renamed | Re-scoped}

**Target state.** {What is true after the change, stated so it would be correct if every other entry were deleted.}

**Behavior.** {Preserving | Changing | Unknown}. {What makes that true. A Changing or Unknown entry names the escalation
that settled it.}

**Why.** {The reason this entry is part of the change.}

**Depends on.** {Entry IDs, or omit the line.}

**Migration.** {What a caller outside the area writes instead, or omit the line.}

**Decision.** {[D-N](artifacts/change-decision-log.md#...)}

## Behavior Changes

Every delta entry classified `Changing` or `Unknown`, gathered in one place, in plain language a person who will not
read the code can follow. For each: what an observer sees differently, who that observer is, and the user's decision.

When every entry is behavior-preserving, say so in one sentence. That is a finding, not an empty section.

## Change Units

The sequence of units the change is carried out in. Each unit leaves the codebase working and tests passing on its own.
A unit that only compiles once a later unit lands is not a unit: merge it into the one it depends on, or split the
dependency out first.

### Unit 1: {name}

**What it does.** {Plain language first.}

**Delta entries.** {S-N references.}

**Ordering constraint.** {What must land before this, and why. Omit when the unit has none.}

**How you know it worked.** {The observable check: a test that passes, a behavior that is unchanged, a dependency edge
that no longer exists.}

## Risks

What could go wrong in carrying this out, and what makes each one detectable early. Name the blast radius of each unit
that has a non-trivial one. Omit this section only when the change is confined to one file with no external callers.

## Deferred (YAGNI)

Parts the target state proposed that failed the evidence test, each with the trigger that would reopen it. Omit the
section when nothing qualified.

## Cut for Scope

Entries the recorded boundary excluded, each with the citation from `artifacts/scope-boundary.md` and a plain-language
statement of what it would have done. The user can reinstate any of these, and their saying so is itself a valid
justification the reinstated entry records. Omit the section when nothing was cut.

## Open Items

Questions the run could not settle, each marked as blocking or non-blocking, with what would settle it. A non-blocking
item is still an unanswered question the builder inherits. Omit the section when there are none.

## Review Findings

The specialists engaged, and the findings that changed the plan. Findings labeled `Unverified` are marked as such and
are never presented as blocking. Point at `artifacts/change-decision-log.md` for the decisions each one produced rather
than restating them.
```
