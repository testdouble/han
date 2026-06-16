# Reference artifact inventory

The breakdown work upstream (`/plan-work-items`) is responsible for inventorying artifacts and embedding them in each slice's `**References.**` block. This skill's job is to **verify** those references are complete and correct before publishing, and to propose evidence-based fills when they are not.

This file defines what belongs in slice References blocks (the include list), what never belongs (the exclude list), and how the skill's Step 3 validation reasons about both.

## Include (these belong in slice References blocks and/or the source file's Shared reference artifacts)

- **HTTP API contract files** (e.g., the parent plan's "External Interfaces" or "API Contracts" section) and the specific endpoint sections that slices produce or consume.
- **Event payload contract files** and the specific event sections.
- **Feature specification** (`feature-specification.md`) — sections that define the behavior a slice realizes.
- **Design assets** — Pencil document file paths plus specific frame IDs (when the plan or spec maps frames to UI), screenshot files, Figma URLs, mockup PDFs.
- **Screenshots from `ui-designs/`**, when present. Map each PNG to the slices that realize the behavior it depicts. The feature spec is the mapping source: its Visual Reference table (or equivalent) lists every screenshot, and its inline `![…](ui-designs/…png)` embeds appear next to the prose describing the depicted state — that prose tells you which slice owns the screenshot. A single slice may need multiple screenshots when it implements multiple states; a single screenshot may apply to multiple slices when distinct slices share a screen — in that case the file is copied once into each owning slice's `.github/issue-assets/<feature-slug>/<SYM-N>/` folder by the upload script. The planning-repo location is the *source*; it is never the URL embedded in the issue. See [screenshot-embed-rules.md](./screenshot-embed-rules.md) for the full URL rule.
- **Schema / migration references** in the target repo when a slice depends on a not-yet-shipped schema.
- **ADRs** (`docs/adr/...` in target repos), coding standards, and feature documentation that constrain the slice's implementation.
- **Runbook skeletons or observability notes** when a slice's acceptance criteria require them.

## Exclude (these never belong in slice References blocks or the Shared reference artifacts section)

- Iteration histories (`*-iteration-history.md`, `.evidence-roundN.md`, `.junior-developer-roundN.md`, `.adversarial-roundN.md`, etc.)
- Decision logs (`decision-log.md`, `implementation-decision-log.md`)
- Review findings (`review-findings.md`, `implementation-review-findings.md`)
- Team findings, facilitation summaries, gap analyses, security/UX round notes
- Anything under an `artifacts/` subfolder of the plan **unless** it is a contract or design reference (e.g., a `design-frame-verification.md` may be cited; a `team-findings.md` may not).

These exist to record how the plan was reached, not what the implementer needs to build. Plan-level decisions that survive into a slice are restated inline in the slice description, with `See plan: D-N` as the breadcrumb — never a link to the decision log itself.

If validation finds a process-artifact link in a slice, the proposed repair is to remove the link and (if the context the artifact held is load-bearing) restate the decision inline with `See plan: D-N`.

## Where each artifact should be cited

- When a single artifact applies to **many slices**, it should appear once in the source file's **Shared reference artifacts** section. Slices reference it by anchor instead of duplicating.
- When an artifact applies to **a single slice**, it appears inline in that slice's `**References.**` block.

When the skill writes per-repo files, it copies the Shared reference artifacts section filtered to entries that apply to at least one slice in that repo. When in doubt, the entry is included.

## What Step 3 validation checks

For each slice:

- If the slice produces or consumes an HTTP endpoint (detected from `**Description.**` prose mentioning a route, method, status code, or DTO shape), an **API contract** bullet must be present in `**References.**`.
- If the slice produces or consumes an event payload, an **Event contract** bullet must be present.
- If the slice has a UI surface and the plan folder contains `ui-designs/`, the `**Screenshots.**` block must be present with at least one embed, AND a **Design** bullet should be present in `**References.**`.
- A **Spec section** bullet should be present whenever the slice realizes a named behavior from the feature spec.
- No process-artifact link is present anywhere in the slice body.

## Missing-artifact handling (evidence-based repair)

When validation finds a missing or excluded artifact:

- **Missing API contract link** — propose the parent plan's External Interfaces / API Contracts section by file path and anchor, evidenced by the section's existence at that location.
- **Missing event contract link** — propose the parent plan's events section, evidenced by the section's existence.
- **Missing Design / Screenshots block** — inspect the feature spec's Visual Reference table and inline screenshot embeds; propose the design frame ID(s) and screenshot file(s), cited by spec section.
- **Process-artifact link found** — propose removal, evidenced by the exclude list above. If the link was load-bearing for context, propose the `See plan: D-N` breadcrumb restatement.

Every proposed fill must cite a concrete source — a file path with line number, a document section, or an ADR ID. Fills without evidence are surfaced as gaps for the user to resolve, not silently applied.
