# /work-items-to-issues

Operator documentation for the `/work-items-to-issues` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.github/skills/work-items-to-issues/SKILL.md`](../../han.github/skills/work-items-to-issues/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** Takes a `work-items.md` file produced by [`/plan-work-items`](./plan-work-items.md), maps each work item to its target repo, validates the format, and publishes one GitHub issue per work item.
- **When to use it.** You have a trusted work-items file and you want each item tracked as a GitHub issue an implementer can grab.
- **What you get back.** One GitHub issue per work item in its target repo, within-repo `blocked_by` links, and a per-repo work-items file alongside the source that records the issue numbers.

## Key concepts

- **Item-to-repo map.** Each work item lives in exactly one repo. The skill builds the map from the cross-repo work-order prose at the top of the file, corroborated by the file paths inside each item, and shows you the map for confirmation before it writes or creates anything.
- **Within-repo blockers only.** A native `blocked_by` link is always within a single repo. Cross-repo coordination (deploy ordering, merge gates) lives in prose at the top of the file, never as a native blocker link. A cross-repo `Depends on` is a format error the skill surfaces for repair.
- **Per-repo work-items file.** For each target repo, the skill writes a `<repo-name>.work-items.md` next to the source. It is a filtered view of the source carrying only that repo's items, and it is the file the publish scripts read. The source file is never modified by publishing.
- **Reference artifacts, not process artifacts.** Every issue body links the artifacts an implementer needs (API and event contracts, design frames, schema docs, ADRs, coding standards) and never the process artifacts that record how the plan was reached (iteration histories, decision logs, review findings). The full include and exclude lists live in [the reference artifact inventory](../../han.github/skills/work-items-to-issues/references/reference-artifact-inventory.md).
- **Screenshots copied into the target repo.** When the plan folder has a `ui-designs/` subfolder, UI items embed their screenshots inline. The skill copies each PNG into the target repo first, then embeds a same-repo raw URL, because the automated implementation tooling cannot resolve a URL that points into a different repository. See [the screenshot embed rules](../../han.github/skills/work-items-to-issues/references/screenshot-embed-rules.md).
- **Evidence-based repair.** When a format check fails, the skill proposes a fix backed by a concrete source (a file path with line number, a plan section, an ADR ID) and lets you continue with the fills, correct them, or stop. Fills without evidence are surfaced as gaps, not applied silently.
- **Idempotent publish.** The publish pipeline resumes cleanly after a partial failure. Items already annotated with their issue number are skipped, and screenshot uploads overwrite in place.
- **No label, no assignee by default.** Issues are created unlabeled and unassigned. You can pass an optional `--label` and `--assignee` when you want them.

## When to use it

**Invoke when:**

- You have a `work-items.md` file from `/plan-work-items` and you want each item published as a GitHub issue in its repo.
- The work spans more than one repo and you need each item created in the right one, with within-repo blockers linked and cross-repo ordering preserved in prose.
- You want the issue bodies to carry the contract, design, and standards links an implementer needs, with the process artifacts left out.

**Do not invoke for:**

- **Producing the work-items file.** Use [`/plan-work-items`](./plan-work-items.md) to break a trusted plan into work items first. This skill publishes that file; it does not create it.
- **Reviewing code or posting PR comments.** Use [`/post-code-review-to-pr`](./post-code-review-to-pr.md) to post a review to a pull request, or [`/code-review`](./code-review.md) for a local review.
- **Writing a PR description.** Use [`/update-pr-description`](./update-pr-description.md).
- **Writing the code for an item.** Use [`/tdd`](./tdd.md) to implement a work item test-first.

## How to invoke it

Run `/work-items-to-issues` in Claude Code. It requires the `gh` CLI to be installed and authenticated.

Give it:

1. **The `work-items.md` path.** The single file produced by `/plan-work-items`. If you do not provide it, the skill asks.
2. **The target repo or repos, optional.** The skill derives the item-to-repo map from the file's cross-repo work-order prose and corroborates it against the file paths in each item. Naming the repo (as `org/repo`) removes ambiguity when the prose is thin.
3. **A label, optional.** Pass `--label <name>` to upsert that label and apply it to every issue. The default is no label.
4. **An assignee, optional.** Pass `--assignee <user>` to assign every issue to that user. The default is no assignee.

Example prompts:

- `/work-items-to-issues docs/features/my-feature/work-items.md`. Publishes each item to the repo the file's prose names, unlabeled and unassigned.
- `/work-items-to-issues docs/features/my-feature/work-items.md org/repo`. Names the target repo explicitly for a single-repo file.
- `/work-items-to-issues docs/features/my-feature/work-items.md --label backlog --assignee my-handle`. Applies a label and assigns every created issue.

## What you get back

Files on disk plus issues on GitHub:

- **A per-repo `<repo-name>.work-items.md`** next to the source, one per target repo. It copies the source title, intro, and cross-repo work-order prose, the shared reference artifacts that apply to that repo, and only that repo's items in source order. After publishing, its item headings carry a `(#NNN)` annotation that records the created issue number. The source file is left untouched.
- **One GitHub issue per work item** in its target repo, created in dependency order (blockers first). Each issue body follows [the slice issue format](../../han.github/skills/work-items-to-issues/references/issue-template.md): summary with an inline plan reference, description, screenshots when the item has a UI surface, references, tests, and acceptance criteria.
- **Within-repo `blocked_by` links** posted for every `Depends on` line, resolved through the recorded issue numbers.
- **Screenshots** copied into each target repo under `.github/issue-assets/<item>/` and embedded inline in the issue bodies, when a `ui-designs/` folder is present.

## How to get the most out of it

- **Install and authenticate `gh` first.** The skill and its publish scripts drive GitHub through the `gh` CLI. Without it, the skill cannot create issues.
- **Run [`/plan-work-items`](./plan-work-items.md) upstream.** This skill publishes a work-items file; it does not produce one. A sharp, dependency-ordered breakdown makes the publish step clean.
- **Write the cross-repo work order as prose in the source file.** The intro paragraph that names which items ship to which repo is the primary signal for the item-to-repo map. The clearer it is, the less the skill has to infer.
- **Review the map before you confirm.** The skill pauses and shows you the item-to-repo table before it writes or creates anything. This is the moment to catch a misrouted item.
- **Let the evidence-based repair run.** When a format check fails, the skill proposes a fix with its source. Continue with the fills when they look right, correct them when they do not, or stop and edit the file by hand.
- **Re-run after a partial failure.** The pipeline is idempotent. Items already created are skipped and uploads overwrite in place, so a re-run resumes where it stopped.

## YAGNI (when applicable)

YAGNI does not gate this skill's output. The work-items file is an already-committed decomposition, and this skill publishes it without adding new behavioral commitments or speculative infrastructure. The closest thing to a gate here is the reference-artifact rule: issue bodies carry the contracts, designs, and standards an implementer needs and leave out the process artifacts that only record how the plan was reached. That is content hygiene, not YAGNI.

If the plan behind the work items has not been through a YAGNI sweep, run [`/iterative-plan-review`](./iterative-plan-review.md) on the plan before you break it into work items. See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

## Cost and latency

The skill dispatches no agents. All of its work runs in-process: reading the file, building and confirming the item-to-repo map, validating the format with evidence-based repair, writing the per-repo files, and running the publish pipeline. The cost is the GitHub API traffic the publish scripts generate (one issue creation per item, one screenshot upload per embed, one dependency link per blocker). The most time-consuming step is publishing a large multi-repo file. The skill is built for a once-per-breakdown cadence, and its idempotent pipeline means a re-run after an interruption only does the work that remains.

## In more detail

The skill walks a six-step process:

1. **Locate the work-items file.** Read the single `work-items.md` from `/plan-work-items`. Note any target repo, label, or assignee you named.
2. **Build the item-to-repo map.** Read the cross-repo work-order prose for the primary mapping, then corroborate it against the file paths inside each item. When the two disagree for an item, the skill surfaces the conflict before proceeding.
3. **Validate the format with evidence-based repair.** Check the file against the format invariants the publish scripts depend on (heading shape, `Depends on` syntax, within-repo blockers, screenshot URL scheme, references present, no process artifacts). When a check fails, propose a fix backed by a concrete source and give you three actions: continue with the fills, correct them, or stop.
4. **Show the item-to-repo map for confirmation.** Present the table and wait. Nothing is written or created until you confirm.
5. **Write the per-repo work-items files.** For each target repo, write a filtered `<repo-name>.work-items.md` next to the source. This is the file the publish scripts read.
6. **Publish each per-repo file.** Run the publish pipeline, which runs three idempotent scripts in order: upload the screenshots into the target repo, create one issue per item (annotating each heading with its `(#NNN)`), then post the within-repo `blocked_by` links.

The publish pipeline is three scripts behind one wrapper. `upload-screenshots.sh` copies each referenced PNG from the plan folder into the target repo and verifies it. `create-issues.sh` creates one issue per item in file order, captures the returned number, and rewrites the heading in place so the next script can resolve symbolic IDs to issue numbers; it applies a label and an assignee only when you pass them. `link-blockers.sh` reads the recorded numbers and posts a native `blocked_by` relationship per blocker, erroring out if a `Depends on` line names an item that is not in the same repo, because a cross-repo dependency belongs in the work-order prose, not in a native link.

## Sources

The skill drives the GitHub REST API through the `gh` CLI. Each source below is cited because the skill draws a specific, named operation from it.

### GitHub REST API: Issues

Issue creation and the per-issue fields the skill writes (title, body, label, assignee) come from the Issues API, reached through `gh issue create`. The skill's one-issue-per-item model and the label and assignee options map directly to it.

URL: https://docs.github.com/en/rest/issues

### GitHub REST API: Repository contents

The screenshot upload step writes each PNG into the target repo through the repository Contents API, fetching the existing file sha to overwrite cleanly when one is already there.

URL: https://docs.github.com/en/rest/repos/contents

### GitHub REST API: Issue dependencies

The within-repo `blocked_by` links come from the issue-dependencies API. `link-blockers.sh` posts `POST /repos/{owner}/{repo}/issues/{issue_number}/dependencies/blocked_by` with the blocking issue's global `issue_id` (its database `id`, not its repo-local number). The feature reached general availability on 2025-08-21, needs no preview header, and links up to 50 issues per relationship type.

URL: https://docs.github.com/en/rest/issues/issue-dependencies

GA announcement: https://github.blog/changelog/2025-08-21-dependencies-on-issues/

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](./README.md). All skills, grouped by purpose.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule. This skill does not gate on it; enforcement belongs upstream.
- [`/plan-work-items`](./plan-work-items.md). Pair upstream to produce the work-items file this skill publishes.
- [`/post-code-review-to-pr`](./post-code-review-to-pr.md). The sibling GitHub skill for posting a code review to a pull request.
- [`/update-pr-description`](./update-pr-description.md). The sibling GitHub skill for writing a PR description.
- [Slice issue format](../../han.github/skills/work-items-to-issues/references/issue-template.md). The per-issue body format and the invariants the publish scripts parse.
- [Work-items file format](../../han.github/skills/work-items-to-issues/references/work-items-file-format.md). The source-file and per-repo-file shapes the skill reads and writes.
- [Screenshot embed rules](../../han.github/skills/work-items-to-issues/references/screenshot-embed-rules.md). Why screenshots are copied into the target repo and how they are embedded.
- [Reference artifact inventory](../../han.github/skills/work-items-to-issues/references/reference-artifact-inventory.md). The include list, exclude list, and the artifacts that never belong in an issue body.
- [`SKILL.md` for /work-items-to-issues](../../han.github/skills/work-items-to-issues/SKILL.md). The internal process definition.
