# Scope Boundary: GitHub issue #200 documentation consistency

## Work Item

GitHub issue [testdouble/han#200](https://github.com/testdouble/han/issues/200), read in full via
`gh issue view 200 --repo testdouble/han` on 2026-09-10. State: OPEN. No labels. No comments. Title:

> Docs: quickstart omits /design-an-api from the sizing-aware list, and two pages contradict han-reporting's dependency

## Stated Scope

The issue carries three suggested fixes, quoted word for word.

Item 1, on the sizing-aware list:

> **Suggested fix:** add `/design-an-api` to the `docs/quickstart.md:196` list, keeping the alphabetical order it
> already uses. That is the whole change.

Item 2, on the `han-reporting` dependency:

> **Suggested fix:** in `choosing-a-han-plugin.md`, scope the bold claim to the layers it is true of ("every layer
> install except `han-reporting` comes with the shared agents"). In `concepts.md`, drop `reporting-only` from the list
> and say what `han-reporting` alone actually gives you.

Item 3, filed by the reporter under "Minor, while I am here":

> `README.md:5` embeds the banner with no `alt` attribute:
>
> ```html
> <img src="images/han-banner.png">
> ```
>
> Worth a short description for screen readers and for anyone whose images do not load.

The issue also states the anchor convention it expects a fixer to use:

> Line numbers are from `main` as of the copy I read; the quoted text is the reliable anchor if they have drifted.

## Stated Exclusions

`None stated.` The issue rules nothing out. It scopes item 1 with "That is the whole change", which bounds that item's
suggested fix rather than the run.

## Operator-Stated Scope

The operator invoked the skill with:

> for https://github.com/testdouble/han/issues/200

In the Step 1.5 confirmation turn the operator was offered two boundaries and approved the wider one with "looks good":

> - **Issue scope only.** Fix the four pages. The next sizing-aware skill someone adds goes missing from the quickstart
>   again.
> - **Issue scope plus the checklist.** Same four pages, plus `CONTRIBUTING.md` step 6 gains the quickstart. One extra
>   line, and the drift stops recurring.

The recorded boundary is therefore the second: the four pages the issue names, plus the contributor checklist step in
`CONTRIBUTING.md` that governs the sizing-aware list.

The operator also approved, in the same turn:

- The output folder `docs/plans/gh-200-docs-consistency/`.
- Running the change at the **small** band.
- The correction that the quickstart's sizing-aware list is missing four skills rather than the one the issue reports.

## In-Scope Files

- `docs/quickstart.md` — the sizing-aware skill list.
- `docs/concepts.md` — the sizing-aware skill list, and the `han-reporting` install claim.
- `docs/choosing-a-han-plugin.md` — the bold shared-agents claim.
- `README.md` — the banner `alt` attribute.
- `CONTRIBUTING.md` — the checklist step that governs which pages carry the sizing-aware list.

`docs/sizing.md` is in scope to read as the canonical source. It is correct as it stands and is not expected to change.

## Direction of Travel

`Unanswered.` The operator was not asked whether any of these pages are being deprecated, replaced, or migrated away
from, and did not volunteer it. Nothing in the run suggests they are.

## Visual Material Received

`None received.`

## Record Provenance

Established by `han-planning:plan-a-change` on 2026-09-10, during the Step 1.5 boundary read. Not inherited from a
prior record: no `scope-boundary.md` existed in this folder or in any source report, and this run created the folder.
No conflicting work item was supplied, so no conflict was resolved.
