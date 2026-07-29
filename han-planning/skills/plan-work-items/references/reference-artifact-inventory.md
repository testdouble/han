# Reference artifact inventory

Before drafting work items, list every artifact an implementer of those work items will need to reach for. Pull from the
same folder as the plan and from the plan's links.

## Include (link these from work items and/or the preamble)

- **HTTP API contract files** (e.g., `api-contracts.md`) and the specific endpoint sections that work items in this
  breakdown produce or consume.
- **Event payload contract files** and the specific event sections.
- **Feature specification** (`feature-specification.md`) — sections that define behavior the work item must realize.
- **Design assets** — Pencil document file paths plus specific frame IDs (when the plan or a sibling doc maps frames to
  UI), screenshot files, Figma URLs, mockup PDFs.
- **Visual material from `ui-designs/`**, when present. Inventory every file in that folder whose type is in the accepted
  visual-material set named in [`planning-boundary-rule.md`](../../../references/planning-boundary-rule.md), and map each
  one to the work items that realize the behavior it depicts. Use the feature spec as the mapping source: the spec's
  `Visual Reference` table lists every item, and the spec's inline `![alt text](ui-designs/card-empty-state.png)` embeds
  appear next to the prose that describes the depicted state — that prose tells you which work item owns the item. A
  single work item may need several items when it implements several states; a single item may apply to several work
  items when distinct work items share a screen. Reference each one by a relative path from `work-items.md` to the file
  (see [work-item-template.md](./work-item-template.md)). A Figma or other hosted URL the boundary record lists is cited
  by URL, since there is no file to reference.
- **The boundary record** (`artifacts/scope-boundary.md`), when present. This is the one file under `artifacts/` that
  work items read. It carries the recorded scope, the stated exclusions, the operator's direction-of-travel answer, and
  the visual material the run received, which is why a downstream skill reads it instead of asking the operator again.
- **Schema/migration references** in the codebase when a work item depends on a not-yet-shipped schema.
- **ADRs**, coding standards, and feature documentation that constrain the work item's implementation.
- **Runbook skeletons or observability notes** only when a work item's acceptance criteria require them.

## Exclude (these never belong in work items)

- Iteration histories (`*-iteration-history.md`, `.evidence-roundN.md`, `.junior-developer-roundN.md`,
  `.adversarial-roundN.md`, etc.)
- Decision logs (`decision-log.md`, `implementation-decision-log.md`)
- Review findings (`review-findings.md`, `implementation-review-findings.md`)
- Team findings, facilitation summaries, gap analyses, security/UX round notes
- Anything under an `artifacts/` subfolder of the plan **unless** it is a contract or design reference, or the boundary
  record `artifacts/scope-boundary.md`, which is admitted by name (e.g., a `design-frame-verification.md` may be cited
  and `scope-boundary.md` may be cited; a `team-findings.md` may not).

These exist to record how the plan was reached, not what the implementer needs to build. Plan-level decisions that
survive into the work item are restated in plain language in the work item body, and cited in the work item's
`**References.**` block as the decision ID plus a one-sentence description of what it is — never an inline ID-only
breadcrumb, and never a link to the decision log itself.

## Where to cite each artifact

- When a single artifact applies to **many work items**, cite it once in the work-items file's **Shared reference
  artifacts** preamble and let work items reference the section by anchor.
- When an artifact applies to a **single work item**, cite it inline in that work item's `**References.**` block.

## Missing-artifact handling

This is the canonical rule for a missing artifact. The skill's own Step 4 points here rather than restating it, so there
is one instruction rather than two that disagree.

One rule, split by **who can supply the artifact**. The test: does the input exist outside the codebase, and can the user
hand it over right now?

**The user can supply it now.** Design frames the run never persisted, a contract only they have, a document on their
machine. Surface it **before drafting work items**, as part of the single stop described in
[`operator-escalation-rule.md`](../../../references/operator-escalation-rule.md). Gather every input of this kind into
that one stop rather than stopping twice: name what is missing, name in plain language what the work items will be
missing without it, name the action that would supply it, and offer to continue anyway. Work items that consume an
undefined contract are not draftable, so say which ones are blocked.

**Nobody can produce it now.** An endpoint that has not been designed, a schema that does not exist yet. Note it in the
breakdown report and keep going: draft the work items that do not depend on it, and flag the ones it blocks as not
draftable until the artifact exists. Do not stop. Stop only when no work items are draftable at all without it.

The distinction is the whole rule. Stopping for an artifact nobody can produce gates the run on something no answer can
unblock, and continuing past an artifact the user is holding produces work items with a hole in them that nobody
noticed.
