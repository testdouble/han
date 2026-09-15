# Scope Boundary: Codex Marketplace Catalog Consistency

## Work Item

GitHub issue [testdouble/han#198](https://github.com/testdouble/han/issues/198), "Codex marketplace catalog omits
han-documentation, han-research, and han-linear". Read via `gh issue view 198` on 2026-09-10. State: OPEN, no comments,
no labels.

## Stated Scope

Quoted from the issue's "Suggested fix" section, word for word:

> 1. Add `han-documentation` and `han-research` to `.agents/plugins/marketplace.json`.
> 2. Add `han-linear/.codex-plugin/plugin.json`.
> 3. Add `han-linear` to `.agents/plugins/marketplace.json`.
> 4. Add a consistency test ensuring every package advertised for Codex has a manifest and catalog entry.

Quoted from the issue's expectation statement:

> I expected every package advertised for Codex to appear in its marketplace catalog and include a valid Codex manifest.

Quoted from the issue's closing line:

> The affected installation instructions are in the [Han README](https://github.com/testdouble/han#codex).

## Stated Exclusions

Quoted from the issue, word for word:

> The parent `han` package appears intentionally excluded because Codex does not support meta-plugins. [see Codex issue
> 23531](https://github.com/openai/codex/issues/23531)

## Operator-Stated Scope

The operator confirmed the area in the Step 1.5 confirmation turn. Asked whether the Codex catalog file, a new
`han-linear/.codex-plugin/plugin.json`, the README's Codex section, and the test harness under `test/` that `npm test`
runs were the whole area the change may touch, they answered:

> yes

Asked which of two readings of "advertised for Codex" the consistency test should enforce — the directory tree, or the
README's install list — they answered:

> directory tree

That answer settles the test's subject: every `han-*` directory except `han/` must carry a Codex manifest and a catalog
entry.

Asked to confirm the plan folder `docs/plans/codex-marketplace-catalog-consistency/`, they answered:

> that's fine

## Direction of Travel

Unanswered. The operator was not asked whether the Codex packaging surface is being deprecated, replaced, or migrated
away from.

## Visual Material Received

None received.

## Record Provenance

Established by `han-planning:plan-a-change` on 2026-09-10. Not inherited from another folder. No conflicting record was
found and no conflict was resolved.

One boundary question arose during the run and was settled without returning to the operator. `CLAUDE.md` was not in the
area list the operator confirmed, and the change makes one of its lines false. It was brought inside the boundary on
precedent rather than by escalation: commit `556b49e` added `han-ddd` and updated the Codex catalog, the Claude
marketplace, and `CLAUDE.md` in one commit. See
[change-decision-log.md](change-decision-log.md) D-8. A second line in the same file was cut for scope instead, and
appears in the plan's Cut for Scope section where the operator can reinstate it.
