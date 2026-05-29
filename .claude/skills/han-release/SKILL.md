---
name: han-release
description: >
  Cut a Han release: update CHANGELOG.md with the changes since the last
  release, tag the version vX.Y.Z, and publish a GitHub release whose notes
  attribute every merged pull request to its author and link back to the full
  changelog for that version. Use when releasing, cutting a release, shipping a
  new Han version, publishing release notes, or tagging a version. Reads the
  target version from plugin.json; when the version has not been bumped past
  the latest tag yet, it proposes a semantic-versioning bump and confirms it
  before continuing. Requires the gh CLI, jq, and a clean git checkout. This is
  a repository-maintenance skill for the Han repo itself, not a general review
  or PR skill — use code-review for local review, post-code-review-to-pr to post a PR
  review, and update-pr-description for PR bodies.
argument-hint: "[pause before publishing] [draft] [optional release context]"
allowed-tools: Read, Edit, Write, Glob, Grep, Agent, AskUserQuestion, Bash(git *), Bash(gh *), Bash(jq *)
---

## Pre-requisites

- gh CLI: !`which gh || echo MISSING`
- jq: !`which jq || echo MISSING`
- git repo: !`git rev-parse --is-inside-work-tree 2>/dev/null || echo NO`

**If `gh` or `jq` is MISSING, or this is not a git repo:** tell the operator which prerequisite is missing and that it must be installed/configured before `/han-release` can run, then **immediately stop**. The skill cannot proceed without all three.

## Project Context

- repo: !`gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || git config --get remote.origin.url`
- current branch: !`git branch --show-current`
- default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || echo unknown`
- working tree: !`git status --porcelain`
- plugin.json version: !`jq -r .version plugin/.claude-plugin/plugin.json 2>/dev/null`
- marketplace.json version: !`jq -r '.plugins[0].version' .claude-plugin/marketplace.json 2>/dev/null`
- latest release tag: !`git fetch --tags --quiet >/dev/null 2>&1; git tag -l 'v*.*.*' --sort=-v:refname | head -n1`
- changelog head: !`grep -m1 '^## v' CHANGELOG.md 2>/dev/null`

Throughout this skill: `P` is the `plugin.json version`, `prev` is the `latest release tag` (for example `v2.3.0`; the version number without the leading `v` is `prev#`), and `target` is the version being released (no `v` prefix; the tag is `v{target}`).

## Step 1: Parse the invocation and check release safety

1. **Parse `$ARGUMENTS`** for two independent flags, then treat the remaining free text as optional release context that informs the changelog narrative:
   - `pause_before_publish` — true if the argument contains "pause", "review", or "confirm before publish" (case-insensitive). Default **false**.
   - `draft_release` — true if the argument contains "draft". Default **false**.
   - The leftover text (anything that is not those flag phrases) is `$release_context`, passed into the narrative dispatch in Step 5. May be empty.

2. **Working tree must be clean.** If `working tree` from Project Context is non-empty, there are uncommitted or untracked changes. Stop and tell the operator to commit or stash them first. Releasing an unknown working state is unsafe and a pushed tag is hard to reverse. This is a hard stop, not a pause gate.

3. **Branch note (non-blocking).** If `current branch` is not the `default branch`, do not stop — note in the Step 7 summary that the release is being cut from `current branch` and the tag will point at that branch's `HEAD`. The operator chose autonomous; surface the fact, do not block.

## Step 2: Determine previous version, commit range, and PR list

1. **`prev`** is `latest release tag`. If it is empty, this is the **first release**: there is no previous tag, the commit range is the full history, and all compare links are omitted.

2. **Commit range.** With a previous tag: `${prev}..HEAD`. First release: the full history (`HEAD` with no range base).

3. **Nothing to release check.** Run `git log {range} --oneline`. If it is empty, there are no commits since `prev`. Stop and tell the operator there is nothing to release.

4. **Collect merged PRs in the range.** Extract PR numbers from both squash subjects and merge commits:

   ```
   git log {range} --pretty=%s%x00%b | grep -oE '#[0-9]+' | tr -d '#' | sort -un
   ```

   For each number `N`, run `gh pr view N --json number,title,author,url,mergedAt,state`. Keep only entries where `state` is `MERGED`. Sort the survivors by `mergedAt` ascending (newest merge last). This is `$pr_list`. Build the PR lines and the changelog bullets per [references/release-notes-format.md](references/release-notes-format.md) and [references/changelog-rules.md](references/changelog-rules.md).

5. **No-PR fallback.** If `$pr_list` is empty (local-only or squash history with no PR refs), record the notable commit subjects from `git log {range} --oneline` instead, and use the commits form documented in both reference files.

## Step 3: Determine the target version

Compare `P` to `prev#` semantically:

```
highest=$(printf '%s\n%s\n' "{prev#}" "{P}" | sort -V | tail -n1)
```

- **`P` is strictly ahead of `prev#`** (`highest` == `P` and `P` != `prev#`): the version was deliberately bumped during development. **`target = P`. No confirmation.** Still compute the expected level (next sub-step) and, if `P` is a *lower* level of bump than the changes warrant (for example a skill was renamed but `P` is only a patch above `prev#`), add one non-blocking advisory line to the Step 7 summary. Do not block.

- **`P` is equal to or behind `prev#`**: the one-bump-per-branch bump has not been applied. **Compute it and confirm it (this is the one mandatory interactive gate).**

  Classify the highest-priority change in `{range}` against [`docs/guidance/semantic-versioning.md`](../../../docs/guidance/semantic-versioning.md):

  - **major** — a skill directory under `plugin/skills/` was removed or renamed (renaming breaks `/skill-name`), or a commit indicates a breaking behavior change (`!` in the type, `BREAKING CHANGE`, a review skill that now auto-posts, etc.). Inspect `git diff --name-status {range} -- plugin/skills/` for `D`/`R` on `SKILL.md` paths, and scan commit subjects.
  - **minor** — a new skill, a new `references/` file, or a new optional capability was added, with no major change present. Inspect the same diff for added `plugin/skills/<name>/SKILL.md`.
  - **patch** — only typo, permission, edge-case, or context-injection fixes.

  Compute `proposed` from `prev#`: major → `(x+1).0.0`, minor → `x.(y+1).0`, patch → `x.y.(z+1)`. Then use `AskUserQuestion` with `header: "Release version"`. State `prev`, the detected level, and the specific evidence (name the renamed/added/removed skills and the commits that drove the classification). Options: accept `proposed` (recommended, first); pick a different level (offer the other two computed versions); enter an explicit `vX.Y.Z`. `target` is the operator's answer. Record this as the version decision in the Step 7 summary.

## Step 4: Apply the version (only when Step 3 computed it)

Skip this entire step when `target == P` (the ahead path — files are already correct).

When Step 3 computed and confirmed `target`:

1. Set `plugin/.claude-plugin/plugin.json` `version` to `target` (Edit).
2. Sync `.claude-plugin/marketplace.json` `plugins[0].version` to `target`. If `scripts/build.sh` exists and is non-empty, run `scripts/build.sh marketplace`; otherwise Edit `.claude-plugin/marketplace.json` directly. Both files must read `target` afterward.

## Step 5: Update CHANGELOG.md

Follow [references/changelog-rules.md](references/changelog-rules.md) exactly.

1. **Does `## v{target}` already exist in `CHANGELOG.md`?** Search for the literal heading.

2. **It exists — augment.** Leave every existing line of that section untouched. Append the generated subsection (`### Pull requests in this release`, or the commits form from the fallback) as the last `###` subsection of the `## v{target}` section, before the next `## v` heading. Build its bullets from `$pr_list` (Step 2) and close it with the `Full changelog:` line using the blob link from [references/release-notes-format.md](references/release-notes-format.md). Use Edit.

3. **It does not exist — generate, then append.** Dispatch **one** `general-purpose` agent to write the narrative `## v{target}` section. The skill already holds this context — paste the actual values into the prompt, do not tell the agent to go read them:

   - The commit log `git log {range} --oneline` and `git diff {range} --stat`.
   - `$pr_list` (PR numbers, titles, authors).
   - `$release_context` from Step 1 (may be empty).
   - The two newest existing `## v{X.Y.Z}` sections from `CHANGELOG.md` verbatim, as the register model.
   - The "Register and voice" constraints from [references/changelog-rules.md](references/changelog-rules.md), pasted in full.

   Prompt the agent to: produce only the markdown for the `## v{target}` section — a one-paragraph summary, descriptive `###` subsections, and a `### Deferred (YAGNI)` subsection only when work was deliberately cut; match the register of the two pasted sections; obey every hard voice constraint; never invent changes not present in the commits, diff, or PR list; return only the section markdown with no preamble. If the agent returns anything else, discard it and re-issue with an explicit "return only the section markdown" reminder.

   Insert the returned section directly under the `# Han Release Notes` title, above the previous newest entry (Edit/Write). Then append the generated subsection to it exactly as in the augment case.

## Step 6: Assemble the release notes body

Build the GitHub release body per [references/release-notes-format.md](references/release-notes-format.md): `## What's Changed`, the PR lines (`* {title} by @{login} in {url}`, newest merge last), the `## v{target}` narrative **excluding** the generated PR/commits bookkeeping subsection, then the `**Full changelog:**` blob link and the `**Full Changelog:**` compare link (compare line omitted on a first release). Compute the blob anchor by lowercasing `v{target}` and deleting every character that is not `a-z`, `0-9`, or `-` (`v2.4.0` → `v240`). Write the assembled body to `/tmp/han-release-notes-v{target}.md` with the Write tool. Do not assemble it with shell `echo`/`printf`.

## Step 7: Show the prepared release

Print to the operator, regardless of mode:

- `target`, the tag `v{target}`, and how it was decided (ahead-of-tag → used as-is, or computed-and-confirmed at Step 3).
- The branch the tag will point at, plus the non-default-branch note from Step 1.3 if it applies.
- Any non-blocking advisory from Step 3 (under-bump warning) and the post-release advisory check: if `CLAUDE.md` states a "Current version:" that does not equal `target`, note it as a follow-up the operator may want to make (do not edit `CLAUDE.md`; it is out of scope).
- The exact CHANGELOG diff for the `## v{target}` section.
- The full assembled release notes body from Step 6.
- The publish mode: published `--latest`, or draft (only if `draft_release`).

**If `pause_before_publish` is true:** use `AskUserQuestion` (`header: "Publish release"`) — options: publish now (proceed to Step 8), abort (stop, having changed only local files). Do not push or publish until approved.

**If `pause_before_publish` is false (default):** continue to Step 8 without pausing.

## Step 8: Commit, tag, and push

The operator's request to tag and publish authorizes the commit and push required to do it.

1. **Commit the release prep.** Stage `CHANGELOG.md`, and `plugin/.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` if Step 4 changed them. Commit with `chore(release): v{target}`. If nothing is staged (augment produced no diff and no version change — unlikely), skip the commit and note it.

2. **Tag.** If tag `v{target}` already exists (`git tag -l v{target}` non-empty, or `git ls-remote --tags origin v{target}` non-empty), do **not** recreate it; note that the version was already tagged and continue. Otherwise create it annotated at the release commit: `git tag -a v{target} -m "v{target}"`.

3. **Push.** `git push origin HEAD` then `git push origin v{target}`.

## Step 9: Publish the GitHub release

Per [references/release-notes-format.md](references/release-notes-format.md), using `/tmp/han-release-notes-v{target}.md`:

- **No release exists for `v{target}`** (`gh release view v{target}` fails): `gh release create v{target} --title "v{target}" --notes-file /tmp/han-release-notes-v{target}.md` plus `--latest`, plus `--draft` only when `draft_release` is true (never `--latest` together with `--draft`).
- **A release already exists:** do not create a second one. `gh release edit v{target} --notes-file /tmp/han-release-notes-v{target}.md`. Report it as updated, not created.

## Step 10: Report

Report concisely: `target` and how it was decided; the tag (created or already existed); the files committed and the commit; the release URL (or draft URL); whether the CHANGELOG section was augmented or generated; and any advisories from Step 7 (under-bump, `CLAUDE.md` version drift, non-default release branch). If `pause_before_publish` was true and the operator aborted at Step 7, report exactly what was changed locally and what was not pushed or published.
