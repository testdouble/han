# Screenshot embed rules

When the plan folder contains a `ui-designs/` subfolder with screenshot files, every UI-bearing slice MUST embed the relevant screenshots **inline in the issue body** — not as plain links.

## Why cross-repo URLs are forbidden

A naive embed would point at the raw URL inside the planning repo. That fails: the automated implementation tooling (Ralph) runs against the **target code repo** and cannot resolve URLs that point into a different repository. An issue body with cross-repo image URLs renders blank in that environment, and the implementer can't see the design.

Solution: **copy each PNG into the target repo first**, then embed it via a same-repo URL.

## Required URL form

```
https://github.com/<org>/<target-repo>/raw/<branch>/.github/issue-assets/<SYM-N>/<file>.png
```

- `<target-repo>` is the code repo the issue is being created in (e.g., `acme-web`).
- `<branch>` is the target repo's default branch, fetched at upload time via `gh repo view <org>/<repo> --json defaultBranchRef --jq .defaultBranchRef.name` (typically `main`).
- `<SYM-N>` is the slice's symbolic ID (e.g., `W-3`).
- `<file>.png` matches the source filename in `<plan-folder>/ui-designs/<file>.png`.

The `scripts/upload-screenshots.sh` script extracts this path from the work-items file, copies the PNG from the plan folder into the target repo at the corresponding location, and verifies the resulting URL resolves before issue creation.

## Embed format inside the issue body

Wrap each embed in a link to the same URL so readers can open the full-size image in a new tab:

```
- *<state-or-scenario name>* — [![<alt text>](<URL>)](<URL>)
```

One image per bullet, with a short caption naming the depicted state.

## Mapping screenshots to slices

Map screenshots to slices via the feature spec's own embeds: the section in the spec that describes the behavior a slice implements is where the canonical screenshot for that slice is referenced.

## Duplication over sharing

When a screenshot applies to multiple slices, copy it once **per slice** so each `<SYM-N>` folder is self-contained. The upload script handles this automatically — every URL it sees in the work-items file produces an upload, even if the source file is shared.

## What never to do

- Never embed planning-repo raw URLs (or any cross-repo URL) in an issue body.
- Never use a shared `.github/issue-assets/shared/` path. Each slice owns its own folder.
- Never link to a screenshot without embedding the image — implementers should see the design without clicking out.
