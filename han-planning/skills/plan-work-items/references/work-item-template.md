# Work item template

Each work item in `work-items.md` uses this template. The template is built for a reader first, using progressive
disclosure: the summary says why the work is needed and what is being done, the work-to-be-done list says what the
implementer will do, the acceptance criteria at the bottom say how anyone knows it is done, and everything in between
exists to support a criterion. The criteria are drafted immediately after the summary — before any detail — even though
they render at the bottom, so the detail is forced to serve them. Required fields appear in the order shown. The
`**References.**` block is required whenever the work item consumes any artifact identified in Step 4 of the skill or
restates a plan decision — omit it only when neither applies. Additional `**Bold paragraph.**` context blocks are
allowed between the work-to-be-done list and the reference blocks when a work item needs them — common ones:
`**Note on scope boundary with <other work>.**` for boundary clarifications, `**Note on <subsystem> capability.**` for
SDK or platform caveats that affect acceptance.

```
## <W-N> — <short descriptive name>

**Summary.** Three to five very short, plain-language sentences. State the context for why this work is needed, then what work is being done. No technical detail: no file paths, no type names, no tool commands. No IDs or reference lists — plan references belong in the References block, each with a one-sentence description. A reader who stops here knows the goal and nothing they must decode.

**Work to be done.**
- A bullet point list of the actual work to do, in plain language with no technical detail. Each bullet is one to two short sentences.
  - When technical detail is needed, put it in a nested bullet under the plain-language bullet it belongs to: the file path, the contract, the constraint, the boundary to respect.
  - Nested detail gives the implementer a starting point and stops short of prescribing line-level changes or implementation code. Work items are often implemented long after they are written, so a prescribed edit list goes stale and misleads; intention and criteria stay valid, and the implementer reads the current code at build time.
- Every bullet supports an acceptance criterion below — work that supports no criterion is cut.

*(Insert additional `**Bold paragraph.**` blocks here when needed — e.g., `**Note on scope boundary.**`.)*

**Design references.** *(Required for UI-bearing work items when the plan folder contains a `ui-designs/` subfolder. Reference each relevant screenshot by a relative path from the `work-items.md` file to the screenshot — e.g., `ui-designs/<file>.png` when the file lives alongside the plan. Embed the image inline and wrap it in a link to the same relative path so a reader can open the full-size image. One image per bullet, with a short caption naming the depicted state. Omit the entire block when the work item has no UI surface or no `ui-designs/` folder exists.)*

- *<state-or-scenario name>* — `[![<alt text>](ui-designs/<file>.png)](ui-designs/<file>.png)`

**References.**
- **Plan decisions** — every plan decision or work unit this item satisfies, one bullet each: the ID as a link (e.g., `[D-6](feature-implementation-plan.md#d-6-...)`) followed by one short plain sentence saying what that decision or work unit actually is. Never a bare ID list — a reader must not need the plan open to know what the ID means. This block replaces any inline `See plan: ...` reference and any standalone "Work items addressed" field — do not add either.
- **API contract** — `[<file>#<anchor>](<relative-path>)` (e.g., `[api-contracts.md#post-v1-parent_kind-id-comments-create](api-contracts.md#post-v1parent_kindidcomments--create)`). Required when the work item produces or consumes an HTTP endpoint.
- **Event contract** — `[<file>#<event-section>](<relative-path>)`. Required when the work item produces or consumes an event payload.
- **Design (Pencil)** — `<pen-file-path>`, frames `<frameId>` (purpose), `<frameId>` (purpose). Required for UI work items.
- **Spec section** — `[feature-specification.md#<anchor>](feature-specification.md#<anchor>)` for the behavior this work item realizes.
- **ADR / standard / repo doc** — link any architectural decision, coding standard, or feature doc the implementer must honor.
- Omit any bullet that does not apply. Do not link iteration histories, decision logs, review findings, team findings, facilitation summaries, or any other process artifact.

**Acceptance criteria.**
- [ ] Each criterion is an observable, verifiable outcome of this work item's own behavior: a behavior that occurs, a state that exists, a check that passes. A person can mark it done without interpreting intent.
- [ ] When the behavior needs automated test coverage, one criterion names that coverage in plain terms (e.g., "Automated tests cover the rejection path and the happy path").

**Depends on.** `<W-N>` (within this file), comma-separated for multiple, or `None.`
```

## What is never an acceptance criterion

- **Standard operating procedure.** Committing, pushing, opening a PR, passing CI, getting review — baseline software
  practice that applies to every change. Stating it adds noise and implies other items are exempt. Never include it.
- **Unexplained prohibitions.** Negative constraints like "no new test files are added" or "do not touch X" send
  implementers down bad paths. Include a prohibition only when there is an explicit, validated reason for it, and state
  that reason with the criterion (e.g., "No new migration is added, because the schema change shipped in W-2 and a
  second migration would conflict"). A prohibition with no stated reason is cut.

## Format invariants

- Heading line begins with `## ` followed by `<W-N>` (the prefix letters, a dash, then digits), then `—` (em-dash with
  surrounding spaces), then the title.
- A work item body ends at the next `## ` heading or end of file.
- `**Summary.**` comes first; `**Acceptance criteria.**` renders at the bottom, immediately before `**Depends on.**`.
  Every block between them supports a criterion; there is no separate `**Tests.**` block — test expectations live
  inside the acceptance criteria.
- Plan references live only in the `**References.**` block, each ID paired with a one-sentence description. The summary
  and work-to-be-done bullets never carry an ID-only reference such as `See plan: D-1, D-5`.
- Design-reference paths are relative to the `work-items.md` file (e.g., `ui-designs/<file>.png` when the screenshots
  live in the plan folder). Never use an absolute path or a cross-repository URL.
- The `**Depends on.**` line uses the literal bold marker, comma-separates dependencies, and ends with `.` (the trailing
  period is part of the format, not a sentence terminator).
