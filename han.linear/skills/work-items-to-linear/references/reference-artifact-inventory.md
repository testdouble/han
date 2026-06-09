# Reference artifact inventory

The breakdown work upstream (`/plan-work-items`) inventories artifacts and embeds them in each slice's `**References.**` block. This skill's job is to **verify** those references are complete and correct before creating Linear issues, and to propose evidence-based fills when they are not.

This file defines what belongs in slice References blocks (the include list), what never belongs (the exclude list), and how validation reasons about both.

## Include (these belong in slice References blocks and/or the source file's Shared reference artifacts)

- **HTTP API contract files** and the specific endpoint sections that slices produce or consume.
- **Event payload contract files** and the specific event sections.
- **Feature specification** (`feature-specification.md`) — sections that define the behavior a slice realizes.
- **Design assets** — design document paths plus specific frame IDs, design-tool URLs, mockup PDFs. Carried into the issue as links. This skill does not upload or embed images into Linear; the design reference is a link the implementer follows.
- **Schema / migration references** when a slice depends on a not-yet-shipped schema.
- **ADRs**, coding standards, and feature documentation that constrain the slice's implementation.
- **Runbook skeletons or observability notes** when a slice's acceptance criteria require them.

## Exclude (these never belong in slice References blocks or the Shared reference artifacts section)

- Iteration histories (`*-iteration-history.md`, `.evidence-roundN.md`, etc.)
- Decision logs (`decision-log.md`, `implementation-decision-log.md`)
- Review findings (`review-findings.md`, `implementation-review-findings.md`)
- Team findings, facilitation summaries, gap analyses, security/UX round notes
- Anything under an `artifacts/` subfolder of the plan **unless** it is a contract or design reference.

These record how the plan was reached, not what the implementer needs to build. Plan-level decisions that survive into a slice are restated inline in the slice description, with `See plan: D-N` as the breadcrumb, never a link to the decision log itself.

If validation finds a process-artifact link in a slice, the proposed repair is to remove the link and, when the context it held is load-bearing, restate the decision inline with `See plan: D-N`.

## Where each artifact should be cited

- When a single artifact applies to **many slices**, it appears once in the source file's **Shared reference artifacts** section. Slices reference it by anchor instead of duplicating.
- When an artifact applies to **a single slice**, it appears inline in that slice's `**References.**` block.

## What validation checks

For each slice:

- If the slice produces or consumes an HTTP endpoint, an **API contract** bullet must be present in `**References.**`.
- If the slice produces or consumes an event payload, an **Event contract** bullet must be present.
- If the slice has a UI surface, a **Design** bullet should be present (a link/path plus frame IDs).
- A **Spec section** bullet should be present whenever the slice realizes a named behavior from the feature spec.
- No process-artifact link is present anywhere in the slice body.

## Missing-artifact handling (evidence-based repair)

When validation finds a missing or excluded artifact:

- **Missing API contract link** — propose the parent plan's External Interfaces / API Contracts section by path and anchor, evidenced by the section's existence.
- **Missing event contract link** — propose the parent plan's events section, evidenced by its existence.
- **Missing Design link** — inspect the feature spec's Visual Reference table and inline design references; propose the design frame IDs and document path, cited by spec section.
- **Process-artifact link found** — propose removal, evidenced by the exclude list above. If load-bearing, propose the `See plan: D-N` breadcrumb restatement.

Every proposed fill cites a concrete source: a file path with line number, a document section, or a named source. Fills without evidence are surfaced as gaps for the operator to resolve, not silently applied.
