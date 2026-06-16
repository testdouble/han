# Screenshot embed rules

When the plan folder contains a `ui-designs/` subfolder with screenshot files, every UI-bearing slice MUST embed the relevant screenshots **inline in the issue body** — not as plain links.

## Why cross-repo URLs are forbidden

A naive embed would point at the raw URL inside the planning repo. That fails: the automated implementation tooling (Ralph) runs against the **target code repo** and cannot resolve URLs that point into a different repository. An issue body with cross-repo image URLs renders blank in that environment, and the implementer can't see the design.

Solution: **copy each PNG into the target repo first**, then embed it via a same-repo URL.

## Required URL form

```
https://github.com/<org>/<target-repo>/raw/<branch>/.github/issue-assets/<feature-slug>/<SYM-N>/<file>.png
```

- `<target-repo>` is the code repo the issue is being created in (e.g., `acme-web`).
- `<branch>` is the target repo's default branch, fetched at upload time via `gh repo view <org>/<repo> --json defaultBranchRef --jq .defaultBranchRef.name` (typically `main`).
- `<feature-slug>` is the kebab-cased basename of the plan folder (e.g., a plan folder `notification-preferences/` yields `notification-preferences`). It namespaces this feature's assets so they never collide with another feature's. See "Why the path is feature-scoped" below.
- `<SYM-N>` is the slice's symbolic ID (e.g., `W-3`).
- `<file>.png` matches the source filename in `<plan-folder>/ui-designs/<file>.png`.

The `scripts/upload-screenshots.sh` script extracts this path from the work-items file, copies the PNG from the plan folder into the target repo at the corresponding location, and verifies the resulting URL resolves before issue creation.

## Why the path is feature-scoped

Symbolic IDs restart at `<PREFIX>-1` for every feature, so a flat `.github/issue-assets/<SYM-N>/` namespace commingles unrelated features that publish to the same repo: a second feature's `W-4` assets would land in the same folder as the first feature's `W-4`, with a real overwrite risk if they share a filename. The `<feature-slug>` segment gives each feature its own subtree. Derive the slug from the plan folder name (its kebab-cased basename) so it is stable and reproducible — `upload-screenshots.sh` reads the slug straight back out of the embedded URL, so the slug written into the URL is the one that must match.

## How assets reach the default branch

The embedded URL always points at the target repo's **default branch**, because that is where the asset lives once published. How the PNG gets there depends on the repo:

- **Unprotected default branch** — `upload-screenshots.sh` writes each PNG directly to the default branch via the GitHub Contents API. Fully autonomous, no human step.
- **Protected default branch** — a direct write is rejected (HTTP 409, "changes must be made through a pull request"). The script falls back automatically: it commits every PNG to an assets branch (`issue-assets/<feature-slug>`), opens a pull request, and prints the PR URL. The issues are still created immediately; their inline images render once that assets PR merges. The embedded URL does not change — it still names the default branch.

The fallback never runs local git and never touches your current branch — every branch, commit, and PR operation is a server-side GitHub API call against the target code repo. The assets branch is created fresh from the default branch's tip, or reused on a re-run **only when it already carries this feature's `issue-assets/<feature-slug>/` tree**. A branch of that name that the skill did not create is refused, never committed onto, so no unrelated work is ever modified.

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
