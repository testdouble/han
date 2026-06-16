# Slice issue format

> Each slice in a `work-items.md` file follows this format. The skill's validation step checks it, and the create step maps each field onto a Linear issue. This is the same slice format `/plan-work-items` emits; the mapping to Linear fields is documented below.

The format is what `/plan-work-items` emits. Required fields appear in the order shown. The `**References.**` block is required whenever the slice consumes any external artifact (HTTP endpoint, event payload, design frame, ADR, coding standard). Additional `**Bold paragraph.**` context blocks are allowed between required fields.

```
## <SYM-N> — <short descriptive name>

**Summary.** One paragraph describing what this slice delivers. Includes a plan reference inline (e.g., `See plan: D-6`).

**Description.**
1. Numbered steps describing the full behavior to build.
2. References implementation details by file path where helpful, but does not prescribe implementation code.

**References.**
- **API contract** — `[<file>#<anchor>](<relative-path>)`. Required when the slice produces or consumes an HTTP endpoint.
- **Event contract** — `[<file>#<event-section>](<relative-path>)`. Required when the slice produces or consumes an event payload.
- **Design** — design document path plus frame IDs. Carried as a link in the issue description; this skill does not upload or embed images into Linear (see "Design and images" below).
- **Spec section** — `[feature-specification.md#<anchor>](feature-specification.md#<anchor>)` for the behavior this slice realizes.
- **ADR / standard / repo doc** — links the implementer must honor.

**Tests.**
- Bullet list of tests required for the behavior. Names the test type and the assertion concretely.

**Acceptance criteria.**
- [ ] Criterion 1
- [ ] Criterion 2

**Depends on.** `<SYM-N>` (within this file), comma-separated for multiple, or `None.`
```

## Mapping a slice onto a Linear issue

When the skill creates an issue for a slice, it maps the slice fields like this:

- **Title (Linear) <- slice title.** The text after `— ` in the `## <SYM-N> — <title>` heading becomes the issue title. The `<SYM-N>` symbolic ID is not part of the title; it is preserved only in the source work-items file's heading annotation.
- **Description (Linear) <- the entire slice body.** Everything below the heading (Summary, Description, optional notes, References, Tests, Acceptance criteria) is rendered into the issue description and passed as **Markdown with no format conversion** (Linear accepts Markdown directly).
- **Team <- the required target team.** Every slice posts into the one team you name. The skill resolves the team against the workspace before any create.
- **Workflow state <- the team's initial state by default.** The skill defaults to the team's own default/initial state and applies a `--state` override only when given, resolved against the team's real workflow states.
- **Labels <- discovery.** The skill never assumes a label exists. When categorization is not specified up front, it presents the team's real labels and lets the operator choose, or proceed without one. Linear has no issue-type concept, so the skill never asks for or sets one.
- **Parent issue <- optional sub-issue nesting.** A named parent issue (resolved against the target team) nests each created issue as a sub-issue.
- **Project <- optional grouping.** A named Linear Project (resolved at workspace scope, confirming the target team participates) groups the created issues.
- **Assignee <- none by default.** Set only when the operator names one, resolved against the team's members.
- **Creator <- the Linear MCP identity.** The skill never sets the creator; Linear records the authenticated user automatically.

## Dependencies (`**Depends on.**`)

After every slice's issue exists and the SYM-to-identifier map is known, the skill resolves each `Depends on` line by creating a **native Linear "blocked by" relation** from the dependent issue to each blocker. Linear relations are reliably native, so no description rewrite is needed. Relations are append-only and de-duplicated, so a re-run does not create duplicates. Every SYM in a `Depends on` line must resolve to another slice in the same file; an unknown SYM is a format error to surface for repair, not a silent skip.

## Design and images

This skill does not upload attachments to or embed images in Linear issues. For UI-bearing slices, the design reference (document path, frame IDs, any design-tool URL) is carried as a link in the issue's references. If a slice's design must be visible inside the issue, add the attachment in Linear by hand after the issue is created.
