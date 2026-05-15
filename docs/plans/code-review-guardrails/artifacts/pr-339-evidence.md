# Evidence: PR #339 (gearjot-v2-web, Task Detail General Information section)

Source bundle: `tmp/gearjot-v2-web-pr-339/` (May 13, 2026).

PR #339 raised 1 CRIT and 3 WARN findings. The CRIT finding was correct and led to the only user-visible fix. Two of the three WARN findings (WARN-002 and WARN-003) prescribed contradictory remedies for the same category of issue: WARN-002 said add an italic-class assertion, WARN-003 said drop a Tailwind-utility-class assertion. The user resolved the contradiction by removing both assertions, which the bundle's README labels "the most instructive single moment".

Findings are keyed E1...E17 and grouped by symptom.

---

## Symptom 1: Goes too deep / off the rails

### E1: WARN-001 flagged a stale data-testid not introduced by this branch
Source: `pr-339-review.md:71`
> While editing, correct the unrelated stale `data-testid="gear-subtitle"` reference on line 52 to `task-subtitle` (real code at `+page.svelte:250` uses `task-subtitle`; not introduced by this branch but adjacent).

The review explicitly labels the issue "not introduced by this branch but adjacent". This is the textbook signature of going beyond the change surface.

### E2: Decision log post-hoc accepts the out-of-scope flag as a drive-by
Source: `02-conversation-and-decision-log.md:207`
> Removing the stale `gear-subtitle` reference is a small drive-by improvement of the kind the project's documentation guidelines encourage when already editing a file.

The log accepts the drive-by but does not change the fact that the review surfaced a finding outside its declared scope.

### E3: Review's own scope statement names 2 files; WARN-001 reaches a third
Source: `pr-339-review.md:10-11`
> Scope: 2 files (`src/routes/tasks/[id]/+page.svelte`, `src/routes/tasks/[id]/page.test.ts`). Adds a "General Information" section.

The reviewer declared scope, then immediately raised a finding against `docs/project-documentation/tasks-detail-page.md`. The skill correctly identifies the scope and then ignores it.

### E4: Review missed an in-scope token bug; the user found it in their own pass
Source: `02-conversation-and-decision-log.md:241-247`
> While reviewing the file end-to-end, Aaron noticed an unrelated bug on the same `+page.svelte`: the "Share unavailable" warning banner used `text-warning-foreground` (resolves to `#ffffff`), rendering white text on a tinted cream background.

The same root cause pattern as CRIT-001 (a `-foreground` token misinterpreted) was visible in the same file in the same diff. The review spent attention on out-of-scope documentation lines and missed an in-scope, identical-pattern bug. Going deep in the wrong direction starves attention from in-scope work.

---

## Symptom 2: YAGNI under-applies

### E5: YAGNI section reports zero findings despite a planned, explicit YAGNI rejection
Source: `pr-339-review.md:106-110`
> None identified. The three new data points (Description, ID, UUID) all map to existing fields on `TaskItem` already used elsewhere; the empty-state guard handles a real product state; no speculative abstractions were introduced.

### E6: The plan explicitly logged a YAGNI rejection the review did not surface
Source: `artifacts/planning/implementation-decision-log.md:84-100`
> D-5: No `<LabeledRow>` component extraction
> Decision: No. Render both rows inline in `+page.svelte` using the existing labeled-row pattern.
> Rationale: No `<LabeledRow>` component exists in the codebase today. Inline duplication of the labeled-row pattern is the established practice... Per the YAGNI rule, an abstraction needs three concrete uses or cited evidence.

The plan made a conscious YAGNI call with reopen criteria. The review did not validate this call against the implementation, did not surface it, and did not check whether the implementation honored the decision. YAGNI ran without reading the plan.

### E7: Feature overview confirms the deliberate non-abstraction
Source: `01-feature-overview.md:46`
> The team explicitly decided not to extract a reusable "labeled row" component, because no third use case justified the abstraction yet.

### E8: WARN-002 contradicts YAGNI by recommending added implementation-coupled assertions
Source: `pr-339-review.md:73-83`
> Add to T6 (and T5 for symmetry):
> ```ts
> expect(body.className).toMatch(/italic/);
> ```

The recommendation pins a test to a Tailwind utility class. WARN-003 in the same review correctly identifies this exact pattern as implementation coupling. WARN-002 should have been YAGNI's job: flag the speculative-coupling itself, not recommend more of it.

---

## Symptom 3: Severity inflation

### E9: WARN-001 (doc not updated) treated as Warning despite the doc not being a file of interest
Source: `pr-339-description.md:47-48`
> Files of interest
> - `src/routes/tasks/[id]/+page.svelte`
> - `src/routes/tasks/[id]/page.test.ts`

The author scoped attention to two files. The docs file was not among them. A missing documentation update at this size is a Suggestion at most.

### E10: WARN-002 and WARN-003 are co-equal Warnings but prescribe opposite remedies
Source: `pr-339-review.md:73-96`
> WARN-002: T6 (whitespace-only body) doesn't assert italic class, unlike T4. Recommendation: Add `expect(body.className).toMatch(/italic/);`.
> WARN-003: T2 `className` assertion is implementation-coupled. Recommendation: Drop the `className` line; keep the `textContent` assertion.

Two co-equal Warnings, one prescribing addition and one prescribing removal of the same pattern.

### E11: Decision log names the contradiction as a reviewer failure to self-check
Source: `02-conversation-and-decision-log.md:194-196`
> WARN-002 and WARN-003 are subtly contradictory. WARN-003 says "don't couple tests to Tailwind utility classes." WARN-002 says "add a `className.toMatch(/italic/)` assertion to T6." Both can't be right, and the reviewer didn't flag the inconsistency.

### E12: User resolved WARN-002 by doing the opposite of what it recommended
Source: `pr-339-resolutions.md:25-29`
> Resolved by removing the italic assertion from T4 rather than adding parallel assertions to T5/T6.
> Reasoning: Asserting on the `italic` class is the same category of implementation coupling flagged in WARN-003.

A Warning that is resolved by doing the opposite of its own recommendation is not a Warning. It was at most a Suggestion needing human adjudication.

### E13: README confirms this is the bundle's most instructive single moment
Source: `tmp/gearjot-v2-web-pr-339/README.md:46`
> Most instructive single moment: Aaron resolved the contradiction between WARN-002 and WARN-003 by removing an assertion rather than adding one: a self-consistency call the code-review skill could have made on its own.

---

## Symptom 4: Context not forwarded to sub-agents

### E14: Review acknowledges no human-supplied focus areas
Source: `pr-339-review.md:1-13`

The review's scope statement contains no "Context provided by user", no focus-area acknowledgment, and no reference to the PR description's "What to look at first" section.

### E15: PR description named three specific concerns; none surfaced in the review
Source: `pr-339-description.md:31-33`
> - The conditional logic for the description (`typeof task.body === 'string' && task.body.trim()`): this follows the project's non-empty string check standard; worth confirming the empty-state copy ("No description provided.") matches product expectations.
> - DOM ordering: the new `<section>` sits above the existing `<dl>` and the two share a `border-t` divider: scan the diff to confirm the visual separation reads correctly at the boundary.
> - The `uuid` field is now surfaced in read-only UI for the first time; the Tasks Detail Page project doc notes `uuid` is used for share links, so confirm this exposure is intentional for this page.

None of these three concerns are addressed in the review's findings.

### E16: Edge-case agent surfaced a UUID concern but not the human's UUID concern
Source: `pr-339-review.md:114-118`
> EC1 (edge-case-explorer, Low): `task.uuid` has no runtime null guard. Typed as non-nullable `string` in `TaskItem`; no realistic production path produces a missing UUID. Per small-change calibration, Low findings not directly introduced by this change are omitted.

The agent found a UUID null-guard concern (unrelated to the human's framing) and the skill correctly omitted it under calibration. But the human's actual question (is surfacing UUID intentional for this page?) was never addressed because it never reached the agents.

### E17: DOM ordering concern from the PR description was never reviewed
Source: cross-reference of `pr-339-description.md:32` and `pr-339-review.md:27-31`

The PR description asks reviewers to "scan the diff to confirm the visual separation reads correctly at the boundary". The review summary contains four findings; none address visual separation or DOM ordering at the new section boundary. The human's focus area did not reach the sub-agents responsible for those domains (structural-analyst, behavioral-analyst, user-experience-designer if dispatched).
