# Slice issue format

> Each slice in a `work-items.md` file (and in the per-repo files the skill writes) must follow this format. The publish scripts (`scripts/create-issues.sh`, `scripts/link-blockers.sh`) parse it; the skill's Step 3 validation checks it. Changes here require matching script changes.

The format below is what `/plan-work-items` emits and what the publish pipeline reads. Required fields appear in the order shown. The `**References.**` block is required whenever the slice consumes any external artifact (HTTP endpoint, event payload, design frame, ADR, coding standard) — omit it only when no external artifact applies. Additional `**Bold paragraph.**` context blocks are allowed between required fields when a slice needs them — common ones: `**Note on scope boundary with <other effort>.**` for ticket-boundary clarifications, `**Note on <subsystem> capability.**` for SDK or platform caveats that affect acceptance.

```
## <SYM-N> — <short descriptive name>

**Summary.** One paragraph describing what this slice delivers. Includes a plan reference inline (e.g., `See plan: [D-6](feature-implementation-plan.md#d-6-...)` or `See plan: D-3, D-7, and Work Unit 2`). The plan reference replaces a standalone "Work items addressed" field.

**Description.**
1. Numbered steps describing the full behavior to build.
2. References implementation details by file path where helpful (`db/ent/schema/jot.go`), but does not prescribe implementation code.
3. Duplicates content from the parent plan when clarity requires it.

*(Optional `**Bold paragraph.**` blocks here — e.g., `**Note on scope boundary.**`, `**Note on cross-repo gate.**`.)*

**Screenshots.** *(Required for UI-bearing slices when the plan folder contains a `ui-designs/` subfolder. Each screenshot is embedded inline using a same-target-repo raw URL of the form `https://github.com/<org>/<target-repo>/raw/<branch>/.github/issue-assets/<SYM-N>/<file>.png`. The PNG is copied into the target repo by `scripts/upload-screenshots.sh` before the issue is created. Cross-repo URLs into the planning repo are forbidden — the automated implementation tooling cannot resolve them. Each embed is wrapped in a link to the same URL so readers can open the full-size image in a new tab. One image per bullet, with a short caption naming the depicted state. Omitted when the slice has no UI surface or no `ui-designs/` folder exists.)*

- *<state-or-scenario name>* — `[![<alt text>](https://github.com/<org>/<target-repo>/raw/<branch>/.github/issue-assets/<SYM-N>/<file>.png)](https://github.com/<org>/<target-repo>/raw/<branch>/.github/issue-assets/<SYM-N>/<file>.png)`

**References.**
- **API contract** — `[<file>#<anchor>](<relative-path>)` (e.g., `[feature-implementation-plan.md#external-interfaces](feature-implementation-plan.md#external-interfaces)`). Required when the slice produces or consumes an HTTP endpoint.
- **Event contract** — `[<file>#<event-section>](<relative-path>)`. Required when the slice produces or consumes an event payload.
- **Design (Pencil)** — `<pen-file-path>`, frames `<frameId>` (purpose), `<frameId>` (purpose). Required for UI slices.
- **Spec section** — `[feature-specification.md#<anchor>](feature-specification.md#<anchor>)` for the behavior this slice realizes.
- **ADR / standard / repo doc** — links to architectural decisions, coding standards, or feature docs the implementer must honor.
- Omits any bullet that does not apply. Does not link iteration histories, decision logs, review findings, team findings, facilitation summaries, or any other process artifact.

**Tests.**
- Bullet list of tests required for the behavior above. Names the test type (unit, integration, migration, visual, etc.) and the assertion concretely.

**Acceptance criteria.**
- [ ] Criterion 1
- [ ] Criterion 2

**Depends on.** `<SYM-N>` (within this repo), comma-separated for multiple, or `None.`
```

## Format invariants the scripts depend on

These are the patterns the publish scripts grep for; violating them breaks the pipeline. The skill's Step 3 validation checks each invariant before publishing and proposes evidence-based repairs.

- **Heading line** begins with `## ` followed by `<SYM-N>` (uppercase letters or digits, dash, digits), then ` — ` (em-dash with surrounding spaces), then the title.
- **Heading rewrite.** After issue creation, `scripts/create-issues.sh` rewrites each heading in place to `## <SYM-N> (#NNN) — <title>`. The `(#NNN)` annotation is how `link-blockers.sh` resolves symbolic IDs to GitHub issue numbers, and how `create-issues.sh` knows to skip already-created slices on re-run. Both shapes — with and without `(#NNN)` — are valid input.
- **Slice body** ends at the next `## ` heading or end of file.
- **Screenshot URLs** use the exact path scheme `.github/issue-assets/<SYM-N>/<file>.png`. The upload script extracts this path verbatim from the per-repo file.
- **`Depends on` line** uses the literal bold marker `**Depends on.**`, comma-separates blockers, and ends with `.` (the trailing period is part of the format, not a sentence terminator).
- **Within-repo blockers only.** Every SYM named in a `Depends on` line must resolve to a slice in the same per-repo file. Cross-repo blockers belong in the cross-repo work-order prose at the top of the source `work-items.md`, not as a native `blocked_by` link.
