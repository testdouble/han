# Work-items file format

The skill writes exactly one file, named `work-items.md`, in the folder resolved in Step 2 of the skill (the plan's folder, the context's location, or a confirmed best-guess folder). There is never more than one work-items file and the file is never split by repository.

## Title and intro

```
# Work Items — <feature-or-effort-name>
```

Followed by one intro paragraph linking the parent plan (or naming the source context when there is no plan file) and noting:

> Work items are numbered `W-N` for cross-reference only. `Depends on` lines refer to other work items in this file.

Link the parent plan once here. Do not relink it inside every work item.

## Shared reference artifacts preamble (only when an artifact applies to more than one work item)

When a single artifact (an API response envelope, an event payload shape, a shared-stylesheet notice, a design-frame-to-component mapping, an ADR pointer) applies to more than one work item in this file, cite it once in a **Shared reference artifacts** section immediately after the intro. Each entry is a relative link plus the anchor an implementer should jump to.

The preamble stays in the work-items file and is **not** duplicated into each work item body. Each work item body still carries its own `**References.**` block — a work item reference can point into a shared-artifacts entry by anchor when the artifact is shared, but the bullets in the work item itself are what the implementer reads.

Omit the preamble entirely when no artifact applies to more than one work item.

## Work items

Every work item uses the template at [work-item-template.md](./work-item-template.md). Work items appear in dependency order: a work item never appears before a work item it depends on.
