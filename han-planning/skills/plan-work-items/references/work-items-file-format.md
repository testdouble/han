# Work-items file format

The breakdown is one file, named `work-items.md`, in the folder resolved in Step 2 of the skill (the plan's folder, the
context's location, or a confirmed best-guess folder). There is never more than one work-items file and the file is never
split by repository. The boundary record at `artifacts/scope-boundary.md` and any visual material in `ui-designs/` sit
beside it as companion artifacts.

## Title and intro

```
# Work Items — <feature-or-effort-name>
```

Followed by one intro paragraph linking the parent plan (or naming the source context when there is no plan file) and
noting:

> Work items are numbered `W-N` for cross-reference only. `Depends on` lines refer to other work items in this file.

Link the parent plan once here. Do not relink it inside every work item.

## Shared reference artifacts preamble (only when an artifact applies to more than one work item)

When a single artifact (an API response envelope, an event payload shape, a shared-stylesheet notice, a
design-frame-to-component mapping, an ADR pointer) applies to more than one work item in this file, cite it once in a
**Shared reference artifacts** section immediately after the intro. Each entry is a relative link plus the anchor an
implementer should jump to.

The preamble stays in the work-items file and is **not** duplicated into each work item body. Each work item body still
carries its own `**References.**` block — a work item reference can point into a shared-artifacts entry by anchor when
the artifact is shared, but the bullets in the work item itself are what the implementer reads.

Omit the preamble entirely when no artifact applies to more than one work item.

## Work items

Every work item uses the template at [work-item-template.md](./work-item-template.md). Work items appear in dependency
order: a work item never appears before a work item it depends on.

## Cut for scope (only when something was cut)

When a candidate work item could not name what it descends from, it appears here rather than above. This section comes
last, after the work items, under the heading `## Cut for Scope`.

Open the section with one line saying what it is not:

> This is work the work item excludes, not work deferred for lack of evidence. There is no trigger that reopens an entry
> here; the recorded boundary already settled it.

Then one bullet per cut entry, each naming two things:

```
- **<what it would have done, in plain language>.** <Why it was cut, with the citation that supports the cut.>
```

Name the consequence rather than only the mechanism. "The card cannot carry a picture" is something the user can weigh;
"out of scope" is not, and weighing it is why the section exists.

Omit the section entirely when nothing was cut. Every entry also appears in the closing summary the skill prints, because
a cut the user never sees is a cut nobody can reverse. Any entry the user reinstates records their direction as its
justification.
