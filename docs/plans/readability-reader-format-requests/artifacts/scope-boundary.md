# Scope Boundary: Readability standard honors an explicit reader format request

## Work Item

GitHub issue [testdouble/han#177](https://github.com/testdouble/han/issues/177), "Han Feedback:
han-readability (2026-08-11)", read with the `gh` CLI on 2026-08-19. It is a `han-feedback` report filed
against the `han-communication:han-readability` output style. The report names two files as the place the
finding lands: `han-communication/references/readability-rule.md` and the output style itself.

## Stated Scope

Quoted word for word from the issue's `## Proposal` section:

> 1. **Add a seventh self-check criterion** to `readability-rule.md` and the output style: the draft
>    matches the shape the reader asked for in count, format, and register. State that an explicit
>    reader constraint outranks the other six when they conflict. This requires reopening the "these six
>    criteria are the whole check" line, which is deliberate closure, so it is a real decision and not a
>    typo fix.
> 2. **Scope-note "Fidelity wins"** so it does not outrank an explicit instruction to simplify. A
>    workable form: when the reader asks for fewer facts, a fact moves to a layer they can reach (a
>    later section, a linked document, an offer to expand) or is dropped with the drop named. It stays
>    absolute against silent loss, which is the failure the section was written to prevent.
> 3. **Consider whether criterion 4 needs a simplicity test** beside its length ceiling, since short and
>    simple came apart cleanly here.

The issue's `## Overall` section states the intended landing area word for word:

> The fix is small and lands in two files, but it touches two clauses written as deliberate absolutes, so
> it deserves a decision rather than a quiet edit.

## Stated Exclusions

`None stated.` The issue rules nothing out in words. Its third proposal is framed as "Consider whether",
which makes it a question this run answers rather than a commitment the issue already made.

## Operator-Stated Scope

Quoted from the operator's invocation and mid-run messages:

> /han-planning:plan-a-feature for https://github.com/testdouble/han/issues/177

> commit and push on the current branch, as you go

> open pr in draft mode, targeting v5.4.0-beta as the merge branch

The second and third are delivery instructions for this run rather than scope statements about the
feature.

## Direction of Travel

Nothing named in the issue is being deprecated, replaced, or migrated away from. The operator confirmed
this on 2026-08-19 and noted the issue was already clearly scoped.

## Visual Material Received

`None received.` The run was given no images, mockups, or design links, so no `ui-designs/` folder was
created and this section lists no rows.

## Record Provenance

Established by `han-planning:plan-a-feature` on 2026-08-19. Not inherited from another folder. No
conflicting work item was presented.
