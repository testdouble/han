# Work item template

Each work item in `work-items.md` uses this template. Required fields appear in the order shown. The `**References.**` block is required whenever the work item consumes any artifact identified in Step 4 of the skill — omit it only when no external artifact applies. Additional `**Bold paragraph.**` context blocks are allowed between required fields when a work item needs them — common ones: `**Note on scope boundary with <other work>.**` for boundary clarifications, `**Note on <subsystem> capability.**` for SDK or platform caveats that affect acceptance.

```
## <W-N> — <short descriptive name>

**Summary.** One paragraph describing what this work item delivers. Include a plan reference inline (e.g., `See plan: [D-6](feature-implementation-plan.md#d-6-...)` or `See plan: D-3, D-7, and Work Unit 2`). The plan reference replaces a standalone "Work items addressed" field — do not add one.

**Description.**
1. Numbered steps describing the full behavior to build.
2. Reference implementation details by file path where helpful (`db/ent/schema/jot.go`), but do not prescribe implementation code.
3. Duplicate content from the parent plan into this description when clarity requires it.

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

**Tests.**
- Bullet list of tests required for the behavior above. Be concrete: name the test type (unit, integration, migration, visual, etc.) and the assertion.

**Acceptance criteria.**
- [ ] Criterion 1
- [ ] Criterion 2

**Depends on.** `<W-N>` (within this file), comma-separated for multiple, or `None.`
```

## Format invariants

- Heading line begins with `## ` followed by `<W-N>` (the prefix letters, a dash, then digits), then ` — ` (em-dash with surrounding spaces), then the title.
- A work item body ends at the next `## ` heading or end of file.
- Design-reference paths are relative to the `work-items.md` file (e.g., `ui-designs/<file>.png` when the screenshots live in the plan folder). Never use an absolute path or a cross-repository URL.
- The `**Depends on.**` line uses the literal bold marker, comma-separates dependencies, and ends with `.` (the trailing period is part of the format, not a sentence terminator).
