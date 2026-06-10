---
name: work-items-to-issues
description: >
  Break a work-items.md file (produced by /plan-work-items) into independently-grabbable GitHub
  issues, one per slice, in each slice's target repo. Use when you want to turn a work-items file
  into GitHub issues, publish work items as issue tickets, or create implementation tickets that
  can be worked on and tracked on GitHub. Does not produce the work-items file itself — use
  plan-work-items to break a plan into work items first. Does not review code or post pull request
  comments — use post-code-review-to-pr for that.
argument-hint: [path to work-items.md] [target repo(s), e.g. org/repo] [--label <name> (optional)] [--assignee <user> (optional)]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh *), Bash(git *), Bash(find *)
---

# Work Items to GitHub Issues

Take an already-broken-down `work-items.md` file (produced by `/plan-work-items`) and publish each slice as a GitHub issue in its target repo.

The breakdown work — drafting slices, assigning symbolic IDs, specifying dependencies, inventorying references — has already been done upstream. This skill's job is to map each slice to its target repo, validate the format, write a per-repo work-items file alongside the source, and run the publish pipeline.

## Rules

- Each slice lives in exactly one repo. Cross-repo coordination is documented in prose at the top of `work-items.md` — never as a native blocker link.
- Native `blocked_by` relationships are **within-repo only**. A cross-repo `Depends on` is a format error to surface for repair.
- Symbolic-ID prefixes: accept whatever the input uses. Both shapes are valid input — single-prefix across repos (e.g., `W-N` for every slice) and per-repo prefixes (e.g., `V2-N` backend, `W-N` frontend, `EV-N` events). The publish scripts accept any uppercase prefix.
- Every slice issue body MUST link the reference artifacts an implementer needs — API/event contracts, design frames, schema docs, runbooks, ADRs, coding standards. Issues that consume an HTTP endpoint or event payload MUST link the contract section that defines it.
- UI slices, when the plan folder has a `ui-designs/` subfolder, MUST embed the relevant screenshots inline using same-target-repo raw URLs. See [references/screenshot-embed-rules.md](./references/screenshot-embed-rules.md).
- NEVER include process artifacts in issue bodies or the work-items preamble. Excluded categories — iteration histories, decision logs, review findings, team findings, facilitation summaries, gap analyses, and anything under an `artifacts/` subfolder of the plan that is not a contract or design reference. Full include/exclude list in [references/reference-artifact-inventory.md](./references/reference-artifact-inventory.md).

## Process

### 1. Locate the work-items file

If the path is not provided, ask for it. The input is a single `work-items.md` produced by `/plan-work-items`. Read it.

If the user named a target repo (or repos), a label, or an assignee, note them for Steps 2 and 6. By default, issues are created with **no label and no assignee** — only apply a label or assignee when the user explicitly asked for one.

### 2. Build the SYM→repo map

Determine which repo each slice belongs to. Use both signals and reconcile them:

- **Primary — cross-repo work order prose.** Most `work-items.md` files include an intro paragraph naming which SYMs ship to which repo (e.g., "W-1 through W-4 ship to `acme-api`. W-5 through W-9 ship to `acme-web`."). Parse this for the mapping.
- **Corroborating — file paths inside each slice.** Each slice's `**Description.**` and `**References.**` blocks reference files in the target repo. Path roots map cleanly: `acme-api/...` → `acme/acme-api`, `acme-web/...` → `acme/acme-web`, `acme-events/...` → `acme/acme-events`. Use this to verify the prose and to assign any slice the prose doesn't cover.

If the prose and the file-path evidence disagree for a slice, surface the conflict to the user before proceeding.

### 3. Validate the format with evidence-based repair

Check the work-items file against the format invariants in [references/issue-template.md](./references/issue-template.md) and [references/work-items-file-format.md](./references/work-items-file-format.md):

- **Heading shape.** Every slice heading matches `## <SYM-N> — <title>` with an em-dash separator (already-published headings annotated as `## <SYM-N> (#NNN) — <title>` are valid too).
- **`Depends on` line.** Literal bold marker `**Depends on.**`, trailing period, `None.` or comma-separated SYMs.
- **Within-repo blockers.** Every SYM named in a `Depends on` line maps to the same target repo as the dependent slice (under the map from Step 2).
- **Screenshot URLs.** When present, match `https://github.com/<org>/<target-repo>/raw/<branch>/.github/issue-assets/<feature-slug>/<SYM-N>/<file>.png` against the target repo's default branch and a real PNG file under `<plan-folder>/ui-designs/`. `<feature-slug>` is the kebab-cased basename of the plan folder.
- **References block.** Present whenever the slice consumes an HTTP endpoint, event payload, design frame, ADR, coding standard, or other named artifact.
- **No process artifacts.** No links to iteration histories, decision logs, review findings, team findings, facilitation summaries, gap analyses, or anything under an `artifacts/` subfolder that is not a contract or design reference.

When a check fails, attempt evidence-based repair. Pull evidence from the source `work-items.md`, the parent plan referenced in its intro, the feature spec in the same folder, sibling files in the plan folder, and the target repo's ADRs / coding standards / docs:

- **Malformed heading** — propose the corrected shape based on the surrounding text. Cite the line number.
- **Missing `Depends on` line** — propose `None.` if no blockers are evident in the slice's prose. Cite the absence.
- **Cross-repo `Depends on`** — propose moving the relationship to the cross-repo work-order prose at the top of the file and replacing the line with `None.` or remaining within-repo SYMs. Cite the SYM→repo map entries that prove the cross-repo split.
- **Missing References bullet for an HTTP-consuming slice** — propose the contract section link by inspecting the parent plan's External Interfaces / API Contracts section. Cite the anchor.
- **Missing References bullet for a UI slice with `ui-designs/` present** — propose the design frame and screenshot files by inspecting the feature spec's Visual Reference table and the spec's inline screenshot embeds. Cite the spec section.
- **Process-artifact link found** — propose removing the link and (if the slice still needs the context the artifact held) restating the decision inline with `See plan: D-N` as the breadcrumb. Cite the include/exclude list.

After validation, report findings in plain language. For each finding, name:

1. **What is wrong** — slice SYM, line reference, the failing invariant.
2. **What the proposed fill is** — the corrected line, new bullet, removed link, etc.
3. **Evidence for the fill** — file path with line number, document section, or named source.

Then give the user three actions:

- **Continue with fills** — apply the proposed repairs to the source `work-items.md` (so the per-repo split files inherit them) and proceed to Step 4.
- **Correct the fills** — user provides the right values; apply those and proceed.
- **Stop** — exit without publishing. User edits the file by hand and re-runs.

If validation passes with no findings, proceed silently to Step 4.

### 4. Show the SYM→repo map for confirmation

Present a table for user review:

| SYM | Title | Target repo |
| --- | --- | --- |
| W-1 | Backend per-list validator generalization | `acme/acme-api` |
| W-2 | … | `acme/acme-api` |
| W-5 | Frontend type widening and drift comparator | `acme/acme-web` |

Wait for confirmation before writing files or creating issues.

### 5. Write per-repo work-items files

For each target repo named in the SYM→repo map, write a `<repo-name>.work-items.md` file in the same folder as the source `work-items.md`. The per-repo file is a filtered view of the source — it is the file the publish scripts consume:

- **Header section.** Copy the source file's title, intro paragraph, and cross-repo work-order prose verbatim. This keeps each per-repo file self-contained for review.
- **Shared reference artifacts.** Copy the source file's "Shared reference artifacts" section, filtered to entries that apply to at least one slice in this repo. When in doubt, include the entry.
- **Slices.** Include only the slices whose SYM maps to this repo, in their original order from the source file.

The source `work-items.md` is not modified by the publish step. The per-repo files are what carry the `(#NNN)` issue-number annotations after publishing.

### 6. Publish each per-repo file to GitHub

For each per-repo file, publish it by running `${CLAUDE_SKILL_DIR}/scripts/publish-work-items.sh <per-repo-work-items-file> <org>/<target-repo> <plan-folder> [--label <name>] [--assignee <user>]`. Pass the per-repo work-items file written in Step 5, the target repo as `<org>/<target-repo>`, and the plan folder that contains the `ui-designs/` subfolder.

Created issues are unassigned and carry no label by default. Append `--label <name>` and/or `--assignee <user>` only when the user asked for a label or assignee (Step 1). Both flags are optional and may be omitted.

The wrapper runs three idempotent scripts in order:

1. **`scripts/upload-screenshots.sh`** — extracts every `.github/issue-assets/<feature-slug>/<SYM-N>/<file>.png` URL from the per-repo file and copies the matching PNG from `<plan-folder>/ui-designs/` into the target repo, verifying each upload. The `<feature-slug>` segment (the kebab-cased plan-folder basename) keeps assets from different features that publish to the same repo from colliding. Upload is adaptive: by default each PNG is written directly to the default branch via the GitHub Contents API, but if that branch is protected and rejects the direct write (HTTP 409), the script falls back to committing the PNGs to an assets branch, opening a pull request, and printing the PR URL. The embedded image URLs always name the default branch, so on the PR path the inline designs render once that assets PR merges — the issues are still created immediately. Overwrites existing files cleanly and, on re-run, reuses the assets branch and open PR — but only a branch it created for this feature (one already carrying the feature's `issue-assets/<feature-slug>/` tree); a same-named branch it does not own is refused rather than committed onto.
2. **`scripts/create-issues.sh`** — creates one GitHub issue per `## <SYM-N>` slice in file order (blocker-first), unassigned and unlabeled by default. When `--label <name>` is passed, it upserts that label on the repo and applies it to every issue; when `--assignee <user>` is passed, it assigns each issue to that user. Captures each returned issue number and rewrites the heading in place to `## <SYM-N> (#NNN) — <title>`. Skips slices already annotated with `(#NNN)` so partial runs resume cleanly.
3. **`scripts/link-blockers.sh`** — reads the SYM↔#NNN mapping from the rewritten headings, walks each `**Depends on.**` line, and POSTs `repos/<repo>/issues/<N>/dependencies/blocked_by` once per blocker. Errors out if a blocker SYM is not present in the same file (cross-repo dependencies are forbidden as native links — they belong in the cross-repo work-order prose).

When `upload-screenshots.sh` reports that it fell back to PR mode (it prints a `NOTE:` with an assets-branch pull request URL), surface that PR URL to the user and tell them the issues' inline designs render only once that assets PR merges. This is a required follow-up action; do not summarize it away.

The format invariants the scripts depend on (heading shape, URL scheme, `Depends on` syntax) are documented in [references/issue-template.md](./references/issue-template.md). Edits to that template require matching script changes.
