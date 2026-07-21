# Work item template

Each work item in `work-items.md` uses this template. The template is built for a reader first, using progressive
disclosure: the summary says what the work item delivers and why, the acceptance criteria say how anyone knows it is
done, and everything below them exists to support a criterion. Required fields appear in the order shown. The
`**References.**` block is required whenever the work item consumes any artifact identified in Step 4 of the skill —
omit it only when no external artifact applies. Additional `**Bold paragraph.**` context blocks are allowed between the
supporting detail and the reference blocks when a work item needs them — common ones:
`**Note on scope boundary with <other work>.**` for boundary clarifications, `**Note on <subsystem> capability.**` for
SDK or platform caveats that affect acceptance.

```
## <W-N> — <short descriptive name>

**Summary.** One short paragraph, in plain language, stating what this work item delivers and why it matters. A reader who stops here still knows the goal. Include a plan reference inline (e.g., `See plan: [D-6](feature-implementation-plan.md#d-6-...)` or `See plan: D-3, D-7, and Work Unit 2`). The plan reference replaces a standalone "Work items addressed" field — do not add one.

**Acceptance criteria.**
- [ ] Each criterion is an observable, verifiable outcome: a behavior that occurs, a state that exists, a check that passes. A person can mark it done without interpreting intent.
- [ ] When the behavior needs automated test coverage, one criterion names that coverage in plain terms (e.g., "Automated tests cover the rejection path and the happy path").

**Supporting detail.** Short paragraphs or bullets, each written in support of a named acceptance criterion — detail that supports no criterion is cut. Describe the intention and goals of the work, not the edits: give the implementer a starting point (a file path, a contract, a boundary to respect) and stop short of prescribing line-level changes or implementation code. Work items are often implemented long after they are written, so a prescribed edit list goes stale and misleads; intention and criteria stay valid, and the implementer reads the current code at build time. Duplicate content from the parent plan here when clarity requires it.

*(Insert additional `**Bold paragraph.**` blocks here when needed — e.g., `**Note on scope boundary.**`.)*

**Design references.** *(Required for UI-bearing work items when the plan folder contains a `ui-designs/` subfolder. Reference each relevant screenshot by a relative path from the `work-items.md` file to the screenshot — e.g., `ui-designs/<file>.png` when the file lives alongside the plan. Embed the image inline and wrap it in a link to the same relative path so a reader can open the full-size image. One image per bullet, with a short caption naming the depicted state. Omit the entire block when the work item has no UI surface or no `ui-designs/` folder exists.)*

- *<state-or-scenario name>* — `[![<alt text>](ui-designs/<file>.png)](ui-designs/<file>.png)`

**References.**
- **API contract** — `[<file>#<anchor>](<relative-path>)` (e.g., `[api-contracts.md#post-v1-parent_kind-id-comments-create](api-contracts.md#post-v1parent_kindidcomments--create)`). Required when the work item produces or consumes an HTTP endpoint.
- **Event contract** — `[<file>#<event-section>](<relative-path>)`. Required when the work item produces or consumes an event payload.
- **Design (Pencil)** — `<pen-file-path>`, frames `<frameId>` (purpose), `<frameId>` (purpose). Required for UI work items.
- **Spec section** — `[feature-specification.md#<anchor>](feature-specification.md#<anchor>)` for the behavior this work item realizes.
- **ADR / standard / repo doc** — link any architectural decision, coding standard, or feature doc the implementer must honor.
- Omit any bullet that does not apply. Do not link iteration histories, decision logs, review findings, team findings, facilitation summaries, or any other process artifact.

**Depends on.** `<W-N>` (within this file), comma-separated for multiple, or `None.`
```

## Format invariants

- Heading line begins with `## ` followed by `<W-N>` (the prefix letters, a dash, then digits), then `—` (em-dash with
  surrounding spaces), then the title.
- A work item body ends at the next `## ` heading or end of file.
- `**Summary.**` comes first and `**Acceptance criteria.**` second. Every block after the criteria supports a criterion;
  there is no separate `**Tests.**` block — test expectations live inside the acceptance criteria.
- Design-reference paths are relative to the `work-items.md` file (e.g., `ui-designs/<file>.png` when the screenshots
  live in the plan folder). Never use an absolute path or a cross-repository URL.
- The `**Depends on.**` line uses the literal bold marker, comma-separates dependencies, and ends with `.` (the trailing
  period is part of the format, not a sentence terminator).
