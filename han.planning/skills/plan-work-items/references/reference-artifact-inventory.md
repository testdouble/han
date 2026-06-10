# Reference artifact inventory

Before drafting work items, list every artifact an implementer of those work items will need to reach for. Pull from the same folder as the plan and from the plan's links.

## Include (link these from work items and/or the preamble)

- **HTTP API contract files** (e.g., `api-contracts.md`) and the specific endpoint sections that work items in this breakdown produce or consume.
- **Event payload contract files** and the specific event sections.
- **Feature specification** (`feature-specification.md`) — sections that define behavior the work item must realize.
- **Design assets** — Pencil document file paths plus specific frame IDs (when the plan or a sibling doc maps frames to UI), screenshot files, Figma URLs, mockup PDFs.
- **Screenshots from `ui-designs/`**, when present. Inventory every PNG in that folder and map each one to the work items that realize the behavior it depicts. Use the feature spec as the mapping source: the spec's "Visual Reference" table (or equivalent) lists every screenshot, and the spec's inline `![…](ui-designs/…png)` embeds appear next to the prose that describes the depicted state — that prose tells you which work item owns the screenshot. A single work item may need multiple screenshots when it implements multiple states; a single screenshot may apply to multiple work items when distinct work items share a screen. Reference each screenshot by a relative path from `work-items.md` to the file (see [work-item-template.md](./work-item-template.md)).
- **Schema/migration references** in the codebase when a work item depends on a not-yet-shipped schema.
- **ADRs**, coding standards, and feature documentation that constrain the work item's implementation.
- **Runbook skeletons or observability notes** only when a work item's acceptance criteria require them.

## Exclude (these never belong in work items)

- Iteration histories (`*-iteration-history.md`, `.evidence-roundN.md`, `.junior-developer-roundN.md`, `.adversarial-roundN.md`, etc.)
- Decision logs (`decision-log.md`, `implementation-decision-log.md`)
- Review findings (`review-findings.md`, `implementation-review-findings.md`)
- Team findings, facilitation summaries, gap analyses, security/UX round notes
- Anything under an `artifacts/` subfolder of the plan **unless** it is a contract or design reference (e.g., a `design-frame-verification.md` may be cited; a `team-findings.md` may not).

These exist to record how the plan was reached, not what the implementer needs to build. Plan-level decisions that survive into the work item are restated inline in the work item description, with `See plan: D-N` as the breadcrumb — never a link to the decision log itself.

## Where to cite each artifact

- When a single artifact applies to **many work items**, cite it once in the work-items file's **Shared reference artifacts** preamble and let work items reference the section by anchor.
- When an artifact applies to a **single work item**, cite it inline in that work item's `**References.**` block.

## Missing-artifact handling

If an expected artifact is missing — for example, the plan touches an HTTP boundary but no contract file exists — surface it to the user **before drafting work items**. Work items that consume an undefined contract are not draftable.
