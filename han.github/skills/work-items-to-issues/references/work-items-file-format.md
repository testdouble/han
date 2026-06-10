# Work-items file format

> This file describes the format the skill **reads** from `/plan-work-items`, and the format the skill **writes** when splitting per-repo. The publish scripts parse the per-repo files. Changes to the slice-body format require updating `scripts/create-issues.sh` and `scripts/link-blockers.sh`.

There are two file shapes to know:

- **Source `work-items.md`** — one single file emitted by `/plan-work-items`, covering every repo touched by the plan. The skill reads this.
- **Per-repo `<repo-name>.work-items.md`** — filtered views the skill writes alongside the source. One file per affected repo. The publish scripts read these.

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

### 3. Cross-repo work order prose *(required when the plan touches more than one repo)*

A single paragraph (not a table) naming which SYMs ship to which repo and noting any cross-repo deploy ordering or merge gates. Example:

> **Cross-repo work order.** W-1 through W-4 ship to `acme-api` (backend). W-5 through W-9 ship to `acme-web` (frontend). The frontend page-integration items (W-7, W-8) must not be merged until the backend changes (W-1..W-4) are live in production. Per project rule, no cross-repo issue links — the gate is recorded in prose here, not by a ticket reference.

This paragraph is the primary signal the skill uses to build the SYM→repo map. File paths inside each slice corroborate it.

### 4. Shared reference artifacts *(required when any artifact applies to more than one slice)*

A flat list (not per-repo) of artifacts more than one slice references — API contract sections, spec sections, ent schemas, shared stylesheets, ADRs, coding standards. Entries that apply to one repo only stay here too; the section is organized by artifact, not by repo. Each entry is a relative link plus the anchor or file path an implementer should jump to.

### 5. Slices

One slice per `## <SYM-N> — <title>` heading. Slice bodies follow [issue-template.md](./issue-template.md). Slices may appear in any order — the skill does not reorder them when writing per-repo files; it preserves source order.

## Symbolic-ID prefixes

Both shapes are valid input:

- **Single prefix across repos.** Every slice uses `W-N` (or any single prefix) regardless of target repo. The SYM→repo map carries the repo assignment separately. This is what `/plan-work-items` currently emits.
- **Per-repo prefixes.** Different prefixes signal target repo at-a-glance — e.g., `V2-N` backend, `W-N` frontend, `EV-N` events.

The publish scripts accept any `[A-Z][A-Z0-9]*-[0-9]+` heading; the skill prose just reads what is there.

## Per-repo file shape (output, written by the skill)

For each repo named in the SYM→repo map, the skill writes `<repo-name>.work-items.md` alongside the source. Each per-repo file is a filtered view of the source, retaining enough context to stand alone:

1. **Title** — copy from source.
2. **Intro paragraph** — copy from source verbatim.
3. **Cross-repo work order prose** — copy from source verbatim so the reader knows the relationship to other repos.
4. **Shared reference artifacts** — copy from source, filtered to entries that apply to at least one slice in this file. When in doubt, include the entry.
5. **Slices** — only the slices whose SYM maps to this repo, in source order.

The per-repo file is what the publish scripts consume. The source `work-items.md` is not modified by the publish step. After publishing, the per-repo file's slice headings carry `(#NNN)` annotations from `scripts/create-issues.sh`; the source file does not.

## What the publish scripts depend on

The slice-body invariants are documented in [issue-template.md](./issue-template.md). The per-repo file's preamble (title, intro, cross-repo prose, shared references) is for the human reviewer — the scripts ignore everything before the first `## <SYM-N>` heading.
