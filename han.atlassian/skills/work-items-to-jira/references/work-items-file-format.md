# Work-items file format

> This file describes the format the skill **reads** from `/plan-work-items`. Unlike the GitHub `work-items-to-issues` skill, this skill does **not** write per-repo split files: every slice becomes a Jira ticket in a single target project, so there is one input file and no derived files.

There is one file shape to know:

- **Source `work-items.md`** — one single file emitted by `/plan-work-items`, covering every slice in the plan. The skill reads this file, creates one Jira ticket per slice, and annotates each slice heading in place with the created ticket key.

## Source file shape (input)

The source file lives next to its parent plan (typically in `<feature>/<phase>/work-items.md`) and contains, in order:

### 1. Title

```
# Work Items — <feature or phase name>
```

### 2. Intro paragraph

Links the parent implementation plan and feature spec, and notes that work-item SYMs are for cross-reference only:

> Source: [feature-implementation-plan.md](feature-implementation-plan.md). Spec: [feature-specification.md](feature-specification.md).
>
> Work items are numbered `<SYM>-N` for cross-reference only. `Depends on` lines refer to other work items in this file.

### 3. Cross-repo work order prose *(may be present; informational only for Jira)*

A `/plan-work-items` file that spans more than one code repo includes a paragraph naming which SYMs ship to which repo. **This skill ignores the repo split for placement purposes** — every slice posts into the one Jira project you name, regardless of which repo implements it. The prose is still copied into ticket context where it clarifies cross-repo ordering, but it never changes which project a ticket lands in.

### 4. Shared reference artifacts *(required when any artifact applies to more than one slice)*

A flat list of artifacts more than one slice references — API contract sections, spec sections, schema docs, ADRs, coding standards. Each entry is a relative link plus the anchor or file path an implementer should jump to. These are carried into each ticket's References as links.

### 5. Slices

One slice per `## <SYM-N> — <title>` heading. Slice bodies follow [jira-ticket-template.md](./jira-ticket-template.md). Slices may appear in any order; the skill preserves source order and creates tickets blocker-first as authored.

## Symbolic-ID prefixes

Both shapes are valid input:

- **Single prefix across the plan.** Every slice uses `W-N` (or any single prefix). This is what `/plan-work-items` currently emits.
- **Per-area prefixes.** Different prefixes (e.g., `V2-N` backend, `W-N` frontend, `EV-N` events) are accepted as-is. They have no effect on Jira placement; all slices go to the same project.

The skill reads any `[A-Z][A-Z0-9]*-[0-9]+` heading.

## Heading annotation after creation

After a slice's Jira ticket is created, the skill rewrites that slice's heading in place from:

```
## <SYM-N> — <title>
```

to:

```
## <SYM-N> (<PROJECT-KEY-NNN>) — <title>
```

The `(<PROJECT-KEY-NNN>)` annotation (e.g., `(ACME-142)`) is how the skill resolves symbolic IDs to Jira keys when linking dependencies, and how a re-run knows to skip slices that already have a ticket. Both heading shapes — with and without the key annotation — are valid input, so a partial run resumes cleanly.

## What the dependency step depends on

The `**Depends on.**` line in each slice uses the literal bold marker, comma-separates blocker SYMs, and ends with `.` (or is `None.`). Every SYM named in a `Depends on` line must resolve to another slice in this same file; the skill turns those into Jira dependency relationships after all tickets exist. There is no cross-file or cross-project dependency concept in this skill.
