# Work-items file format

> This file describes the format the skill **reads** from `/plan-work-items`. Like the Jira `work-items-to-jira` skill, this skill does **not** write per-repo split files: every slice becomes a Linear issue in a single target team, so there is one input file and no derived files.

There is one file shape to know:

- **Source `work-items.md`** — one file emitted by `/plan-work-items`, covering every slice in the plan. The skill reads it, creates one Linear issue per slice, and annotates each slice heading in place with the created issue's identifier.

## Source file shape (input)

The source file lives next to its parent plan (typically `<feature>/<phase>/work-items.md`) and contains, in order:

### 1. Title

```
# Work Items — <feature or phase name>
```

### 2. Intro paragraph

Links the parent implementation plan and feature spec, and notes that work-item SYMs are for cross-reference only.

### 3. Cross-repo work order prose *(may be present; informational only)*

A file spanning more than one code repo may name which SYMs ship to which repo. **This skill ignores the repo split for placement** — every slice posts into the one Linear team you name. The prose is carried into issue context where it clarifies ordering, but it never changes which team an issue lands in.

### 4. Shared reference artifacts *(required when an artifact applies to more than one slice)*

A flat list of artifacts more than one slice references — API contract sections, spec sections, schema docs, ADRs, coding standards. Each entry is a relative link plus the anchor or path an implementer jumps to. These are carried into each issue's references as links.

### 5. Slices

One slice per `## <SYM-N> — <title>` heading. Slice bodies follow [linear-issue-template.md](linear-issue-template.md). Slices may appear in any order; the skill preserves source order. Creation order does not affect correctness, because dependency relations are made in a separate pass once every issue exists.

## Symbolic-ID prefixes

Both shapes are valid input:

- **Single prefix across the plan.** Every slice uses `W-N` (or any single prefix). This is what `/plan-work-items` currently emits.
- **Per-area prefixes.** Different prefixes (`V2-N` backend, `W-N` frontend, `EV-N` events) are accepted as-is.

They have no effect on team placement. The skill reads any `[A-Z][A-Z0-9]*-[0-9]+` heading.

## Heading annotation after creation

After a slice's Linear issue is created, the skill rewrites that slice's heading in place from:

```
## <SYM-N> — <title>
```

to:

```
## <SYM-N> (<LINEAR-ID>) — <title>
```

The `(<LINEAR-ID>)` annotation (for example `(ENG-142)`) is the team-prefixed identifier Linear returns. It is how the skill resolves symbolic IDs to Linear issues when linking dependencies, and how a re-run knows to skip slices that already have an issue. A heading is treated as already published **if and only if** it matches the annotated form; any other form is unannotated and eligible for creation. Both shapes are valid input, so a partial run resumes cleanly. The annotation is written by a single edit of the heading line immediately after a successful create, so the file is never left in a partially-written state.

## What the dependency step depends on

The `**Depends on.**` line in each slice uses the literal bold marker, comma-separates blocker SYMs, and ends with `.` (or is `None.`). Every SYM named in a `Depends on` line must resolve to another slice in this same file; the skill turns those into native Linear "blocked by" relations after all issues exist. There is no cross-file or cross-team dependency concept in this skill.

Two `Depends on` shapes are **format errors**, surfaced for repair before any issue is created, never published:

- **Self-block** — a slice that names its own SYM in `Depends on`.
- **Dependency cycle** — a set of slices whose `Depends on` lines form a loop (A depends on B, B depends on A, and longer cycles).
