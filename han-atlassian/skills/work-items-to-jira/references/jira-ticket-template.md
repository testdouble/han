# Slice ticket format

> Each slice in a `work-items.md` file must follow this format. The skill's validation step (Process Step 4) checks it, and the create step (Step 6) maps each field onto a Jira ticket. This is the same slice format `/plan-work-items` emits; the mapping to Jira fields is documented below.

The format below is what `/plan-work-items` emits. Required fields appear in the order shown. The `**References.**` block is required whenever the slice consumes any external artifact (HTTP endpoint, event payload, design frame, ADR, coding standard) — omit it only when no external artifact applies. Additional `**Bold paragraph.**` context blocks are allowed between required fields when a slice needs them.

```
## <SYM-N> — <short descriptive name>

**Summary.** One paragraph describing what this slice delivers. Includes a plan reference inline (e.g., `See plan: [D-6](feature-implementation-plan.md#d-6-...)`).

**Description.**
1. Numbered steps describing the full behavior to build.
2. References implementation details by file path where helpful (`db/ent/schema/jot.go`), but does not prescribe implementation code.
3. Duplicates content from the parent plan when clarity requires it.

*(Optional `**Bold paragraph.**` blocks here — e.g., `**Note on scope boundary.**`.)*

**References.**
- **API contract** — `[<file>#<anchor>](<relative-path>)`. Required when the slice produces or consumes an HTTP endpoint.
- **Event contract** — `[<file>#<event-section>](<relative-path>)`. Required when the slice produces or consumes an event payload.
- **Design** — design document file path plus frame IDs (purpose). Required for UI slices. Carried as a link/reference in the description; this skill does not upload or embed images into Jira (see "Design and screenshots" below).
- **Spec section** — `[feature-specification.md#<anchor>](feature-specification.md#<anchor>)` for the behavior this slice realizes.
- **ADR / standard / repo doc** — links to architectural decisions, coding standards, or feature docs the implementer must honor.
- Omits any bullet that does not apply. Does not link iteration histories, decision logs, review findings, team findings, facilitation summaries, or any other process artifact.

**Tests.**
- Bullet list of tests required for the behavior above. Names the test type (unit, integration, migration, visual, etc.) and the assertion concretely.

**Acceptance criteria.**
- [ ] Criterion 1
- [ ] Criterion 2

**Depends on.** `<SYM-N>` (within this file), comma-separated for multiple, or `None.`
```

## Mapping a slice onto a Jira ticket

When the skill creates a ticket for a slice, it maps the slice fields like this:

- **Summary (Jira) ← slice title.** The text after `— ` in the `## <SYM-N> — <title>` heading becomes the Jira ticket summary. The `<SYM-N>` symbolic ID is not part of the summary; it is preserved only in the source work-items file's heading annotation.
- **Description (Jira) ← the entire slice body.** Everything below the heading — Summary, Description, optional notes, References, Tests, Acceptance criteria — is rendered into the ticket description. Pass it as Markdown; if the configured Jira create tool requires Atlassian Document Format (ADF), convert it. Confirm the expected format against the tool's input schema at call time.
- **Issue type ← the resolved type.** Defaults to `Story` at the project top level or under an epic. When the work items are nested under a story (`--parent <story-key>`), each item is a subtask and the default becomes the project's subtask issue type. The user may override per run with `--type`; the chosen type must exist in the project's issue-type metadata and sit at the correct hierarchy level for the parent — a subtask type under a story, a standard (non-subtask) type otherwise.
- **Parent ← an epic or a story (optional).** `--parent <KEY>` parents every created item. Name an epic and each item is a standard issue (Story by default) under the epic; name a story (any standard issue) and each item is a subtask under the story. Set the new ticket's `parent` field to the resolved key. Modern projects use `parent` for both relationships, and a subtask requires it; some company-managed projects use a legacy "Epic Link" field for epic membership — surface this if `parent` is rejected. You cannot parent under a subtask. `--epic <KEY>` is a deprecated alias for `--parent`.
- **Assignee ← none by default.** Do not set an assignee unless the user explicitly provides one.
- **Reporter ← the Atlassian MCP identity.** The skill never sets reporter; Jira records the authenticated MCP user as the reporter automatically.
- **Status / column ← Backlog by default.** Created tickets stay in the project's initial status (Backlog / To Do). When the user names a different column, transition the ticket to the matching status after creation.

## Dependencies (`**Depends on.**`)

After every slice's ticket exists and the SYM→Jira-key map is known, the skill resolves each `Depends on` line:

- It links the dependency natively when the configured Atlassian MCP exposes an issue-link capability (an "is blocked by" / "Blocks" relationship between the dependent ticket and its blocker).
- It always records the resolved relationship in the dependent ticket so it survives regardless of native-link support: the `Depends on` line in the description is rewritten from symbolic IDs to the blockers' Jira keys (linked).

Every SYM in a `Depends on` line must resolve to another slice in the same file. A `Depends on` that names an unknown SYM is a format error to surface for repair, not a silent skip.

## Design and screenshots

The GitHub version of this skill uploaded PNGs into the target code repo and embedded same-repo raw URLs in the issue body. That mechanism is GitHub-specific and is **not** part of this skill. For UI-bearing slices, the design reference (document path, frame IDs, and any design-tool URL) is carried as a link in the ticket's References. This skill does not upload attachments to or embed images in Jira tickets. If a slice's design must be visible inside the ticket, add the attachment in Jira by hand after the ticket is created.
