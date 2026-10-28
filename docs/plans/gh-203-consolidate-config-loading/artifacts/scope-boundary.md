# Scope Boundary: Consolidate config loading (issue #203)

## Work Item

GitHub issue testdouble/han#203, "Consolidate config loading; the inline half of the data-fetch prohibition is
unevidenced", opened by @taminomara. Fetched from the GitHub API at planning time and copied verbatim to
[`../issue-203.md`](../issue-203.md), together with the one comment on it from the maintainer (@mxriverlynn), which
says they "would love to have you digging into this" and that "for long term maintenance, i definitely want a better
solution."

## Stated Scope

The issue's Proposal section, quoted word for word:

> 1. Correct `troubleshooting.md:473` to match the evidence, or attach evidence I did not find.
> 2. Run an OI-3-shaped trial on the values case, with a worst-case arm.
> 3. If it holds, add `load-han-config` to `han-core`, beside `project-discovery`, already the precedent for
>    machine-written, skill-consumed project context.
> 4. Cut each consuming skill's block to one line: "Resolve configuration with `han-core:load-han-config` if you have not
>    already this run." The idempotence hint keeps a chain resolving once.
> 5. Widen property 2 of the exception to match the trial.
>
> Step 1 stands regardless, since the guidance currently contradicts its own spike.

The issue also names the problem it addresses: "A `plan-a-feature` run that invokes `readability-guidance` and then
`explanation-guidance` puts three copies of the config content and three of the instruction into one context window",
and "this is a five-skill problem rather than a 44-skill one."

## Stated Exclusions

Quoted from the issue:

> Under a consolidated loader, #172's config half becomes one line inside `han-config-dir.sh`. Its Pi marketplace
> entries and compat checks are unaffected.

> Nothing here blocks it and the Pi work stands on its own; the note is only that its config half sits on a probe form
> #184 removed, so it needs a rebase regardless.

So the Pi marketplace entries and compat checks of #172 are out of scope. The issue also states "I am not claiming the
values case is proven", so step 3 onward is conditional on the trial in step 2 holding.

## Operator-Stated Scope

The operator's request, quoted: "Read https://github.com/testdouble/han/issues/203 and make a plan". No further scope
was stated.

## Direction of Travel

Unanswered. The run is autonomous and took no confirmation turn. The issue itself implies the answer for the things it
names: the per-skill config block is being replaced by a one-line invocation, and the `troubleshooting.md` wording is
being corrected rather than removed. `han-config-dir.sh` is kept and becomes the single place a lookup changes.

## Visual Material Received

None received

## Record Provenance

Established by `han-planning:plan-implementation` in this run, from the issue text fetched via the GitHub API. No
upstream `plan-a-feature` record existed. The operator's confirmation turn was not taken because the run was
autonomous; the recorded scope is the issue's own text and the operator's one-line request.
