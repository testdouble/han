---
name: han-release
description: >
  Cut a Han release: update CHANGELOG.md with the changes since the last
  release, bump every plugin that changed, tag the suite version vX.Y.Z, and
  publish a GitHub release whose notes attribute every merged pull request to
  its author, credit every closed issue to the person who opened it, the people
  who contributed to it, and the people who worked on the fix, and link back to
  the full changelog for that version. Han ships as
  a parent meta-plugin (`han`) plus child plugins (`han.core`, `han.github`,
  `han.reporting`, and any future `han.*` extension); the skill versions each
  plugin independently. Use when releasing, cutting a release, shipping a new
  Han version, publishing release notes, or tagging a version. Reads each
  plugin's target version from its plugin.json; when a plugin has not been
  bumped past the latest tag yet, it proposes a semantic-versioning bump and
  confirms the whole plan before continuing. Requires the gh CLI, jq, and a
  clean git checkout. This is a repository-maintenance skill for the Han repo
  itself, not a general review or PR skill — use code-review for local review,
  post-code-review-to-pr to post a PR review, and update-pr-description for PR
  bodies.
argument-hint: "[pause before publishing] [draft] [optional release context]"
allowed-tools: Read, Edit, Write, Glob, Grep, Agent, AskUserQuestion, Bash(git *), Bash(gh *), Bash(jq *), Bash(which *), Bash(grep *), Bash(sed *), Bash(head *)
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
- parent plugin name: !`jq -r .name .claude-plugin/marketplace.json 2>/dev/null`
- plugins (name source version): !`jq -r '.plugins[] | "\(.name)\t\(.source)\t\(.version)"' .claude-plugin/marketplace.json 2>/dev/null`
- latest release tag: !`git fetch --tags --quiet >/dev/null 2>&1; git tag -l 'v*.*.*' --sort=-v:refname | head -n1`
- changelog head: !`grep -m1 '^## v' CHANGELOG.md 2>/dev/null`

### Vocabulary used throughout this skill

- **parent** — the meta-plugin whose name equals the marketplace `name` (`parent plugin name` above, normally `han`). It has no skills or agents of its own; it exists to install the children via `dependencies`. The git tag tracks the parent's version, so the release tag is `v{parent target}`.
- **children** — every other entry in `marketplace.json.plugins[]` (`han.core`, `han.github`, `han.reporting`, and any future `han.*` plugin). Each child has its own version line, bumped independently of the others.
- **baseline** of a plugin — its version at `prev` (the latest release tag). For the parent this is `prev#`. For a child it is the version recorded in that child's `plugin.json` at `prev`; if the child did not exist at `prev`, it is a **new plugin** (see Step 3).
- **current** of a plugin — the version in its working-tree `plugin.json`.
- **target** of a plugin — the version being released for it. The release tag is `v{parent target}`.
- `prev` is the `latest release tag` (for example `v2.7.0`; the number without the leading `v` is `prev#`). On the first release `prev` is empty.
- Each plugin's source directory comes from the `source` field in `marketplace.json` (for example `./han.core`), so its `plugin.json` is `{source}/.claude-plugin/plugin.json`. Use `{source}` verbatim in every git command: the `./`-prefixed form works both after a `{ref}:` colon (`git show {prev}:{source}/...`) and as a pathspec (`git diff ... -- {source}/`). Do not strip the leading `./`.

## Step 1: Parse the invocation and check release safety

1. **Parse `$ARGUMENTS`** for two independent flags, then treat the remaining free text as optional release context that informs the changelog narrative:
   - `pause_before_publish` — true if the argument contains "pause", "review", or "confirm before publish" (case-insensitive). Default **false**.
   - `draft_release` — true if the argument contains "draft". Default **false**.
   - The leftover text (anything that is not those flag phrases) is `$release_context`, passed into the narrative dispatch in Step 5. May be empty.

2. **Working tree must be clean.** If `working tree` from Project Context is non-empty, there are uncommitted or untracked changes. Stop and tell the operator to commit or stash them first. Releasing an unknown working state is unsafe and a pushed tag is hard to reverse. This is a hard stop, not a pause gate.

3. **Branch note (non-blocking).** If `current branch` is not the `default branch`, do not stop — note in the Step 7 summary that the release is being cut from `current branch` and the tag will point at that branch's `HEAD`. The operator chose autonomous; surface the fact, do not block.

## Step 2: Determine previous version, commit range, and PR list

1. **`prev`** is `latest release tag`. If it is empty, this is the **first release**: there is no previous tag, the commit range is the full history, all compare links are omitted, and every plugin is treated as new (Step 3).

2. **Commit range.** With a previous tag: `${prev}..HEAD`. First release: the full history (`HEAD` with no range base).

3. **Nothing to release check.** Run `git log {range} --oneline`. If it is empty, there are no commits since `prev`. Stop and tell the operator there is nothing to release.

4. **Collect merged PRs in the range.** Extract PR numbers from both squash subjects and merge commits:

   ```
   git log {range} --pretty=%s%x00%b | grep -oE '#[0-9]+' | tr -d '#' | sort -un
   ```

   For each number `N`, run `gh pr view N --json number,title,author,url,mergedAt,state`. Keep only entries where `state` is `MERGED`. Sort the survivors by `mergedAt` ascending (newest merge last). This is `$pr_list`. The PR list is repo-wide and appears once per release; it is not split per plugin. Build the PR lines and the changelog bullets per [references/release-notes-format.md](references/release-notes-format.md) and [references/changelog-rules.md](references/changelog-rules.md).

5. **No-PR fallback.** If `$pr_list` is empty (local-only or squash history with no PR refs), record the notable commit subjects from `git log {range} --oneline` instead, and use the commits form documented in both reference files.

6. **Collect closed issues and their attribution.** For each merged PR `N` in `$pr_list`, find the issues that PR closed and credit everyone involved. This relates each closed issue to the fix that resolved it.

   - **Find the closed issues for the PR.** Take the issue numbers from `gh pr view N --json closingIssuesReferences --jq '[.closingIssuesReferences[]?.number]'` (the GitHub-tracked closing links). As a fallback for older PRs that linked via text, also scan the PR body and commit messages for GitHub closing keywords: `gh pr view N --json body,commits --jq '[.body, (.commits[].messageBody)] | join("\n")'` and extract `#<num>` that follow `close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, or `resolved` (case-insensitive). Union the two sets, dedupe.

   - **Confirm each is a closed issue.** For each candidate number `I`, run `gh issue view I --json number,title,author,state,comments` (suppress stderr; redirect `2>/dev/null`). Skip the number if the command fails (it is a PR number, not an issue, or does not exist).

   - **Gather attribution per issue.** Record:
     - **opener** — `.author.login`, unless `.author.is_bot` is true.
     - **issue contributors** (people who contributed meaningfully) — the people who left a **substantive** comment on the issue. A reaction is not a comment (a 👍 or other emoji reaction never appears in `.comments[]`), so reaction-only participants are already excluded. Drive-by comments do not count either. Pull each comment with its author and body (`gh issue view I --json comments --jq '.comments[] | select(.author.is_bot|not) | {login: .author.login, body: .body}'`, stderr suppressed), and treat a comment as a drive-by when its trimmed body is emoji-only, or is a brief acknowledgment or status ping (for example `+1`, `same`, `me too`, `bump`, `following`, `thanks`, `any update(s)?`), or is shorter than roughly 15 words and adds no detail. A person qualifies only when at least one of their comments is substantive (not a drive-by). Remove the opener and the PR workers so each person is credited once. May be empty.
     - **PR workers** — for the closing PR `N`, the union of the PR author, the review authors, and the commit authors: `gh pr view N --json author,reviews,commits --jq '[.author.login] + [.reviews[]?.author.login] + [.commits[].authors[].login] | unique'`. Drop bot accounts (`is_bot` where available, plus the `web-flow`, `github-actions`, and `dependabot` logins).

   - **Build `$issue_list`.** One entry per closed issue: its number, title, opener, contributors, the closing PR number(s), and the merged PR workers. If the same issue is closed by more than one PR in the range, record every closing PR and merge their worker sets. Build the changelog bullets and release-body lines per [references/changelog-rules.md](references/changelog-rules.md) and [references/release-notes-format.md](references/release-notes-format.md). If no closed issues are found, `$issue_list` is empty and the issues subsection/section is omitted everywhere.

## Step 3: Build the per-plugin version plan

Enumerate the plugins from `plugins` in Project Context (one parent, plus each child). For **every** plugin, determine `baseline`, whether it changed in `{range}`, and its `target`. Classify changes against [`docs/semantic-versioning.md`](../../../docs/semantic-versioning.md). The governing rules:

- **The parent always bumps on every release.** Even when only one child changed, the parent gets a version bump, because every release is a release of the suite.
- **A child bumps only when its own directory changed in `{range}`.** A child with no changes keeps its version.
- **A brand-new plugin is not bumped by the release that introduces it.** Its `plugin.json` version is its established baseline. Record the introduction in the changelog, but do not increment. This is the general rule for every future `han.*` extension, not a one-time exception for the current children.

### 3a. Classify each plugin

For each plugin, read `current` from `{source}/.claude-plugin/plugin.json` and compute `baseline`:

- **Child, did not exist at `prev`** (`git cat-file -e {prev}:{source}/.claude-plugin/plugin.json` fails, or this is the first release): **new plugin**. `baseline = current`, `target = current`, **no bump**, mark it `new`. Skip the rest of the classification for this plugin.
- **Child, existed at `prev`**: `baseline = git show {prev}:{source}/.claude-plugin/plugin.json | jq -r .version`.
- **Parent**: `baseline = prev#` (the parent's version is what the tag tracks, regardless of any directory move). On the first release `baseline` is empty and the parent is treated like a new plugin set to its `current` value.

Determine whether the plugin **changed** in `{range}`:

- **Child**: changed when `git diff --name-only {prev}..HEAD -- {source}/` is non-empty.
- **Parent**: always treated as changed (it always bumps). Its change *level* is computed in 3b from the whole release, not just `{parent source}/`.

### 3b. Compute each changed plugin's bump level and target

For a **changed child**, classify the highest-priority change inside `{source}/`:

- **major** — a skill directory under `{source}/skills/` was removed or renamed (renaming breaks `/skill-name`), an agent under `{source}/agents/` was removed or renamed, or a commit indicates a breaking behavior change (`!` in the type, `BREAKING CHANGE`, a review skill that now auto-posts, and so on). Inspect `git diff --name-status {range} -- {source}/` for `D`/`R` on `SKILL.md` or agent paths, and scan commit subjects scoped to that plugin.
- **minor** — a new skill, a new agent, a new `references/` file, or a new optional capability was added inside `{source}/`, with no major change present. Inspect the same diff for added `SKILL.md` / agent files.
- **patch** — only typo, permission, edge-case, or context-injection fixes inside `{source}/`.

For the **parent**, the bump level is the maximum across the whole release:

- a child was **removed** from the suite → **major** (breaking for anyone who installed the meta-plugin).
- any changed child's level is **major** → **major**.
- a **new** child plugin was introduced, or any changed child's level is **minor** → at least **minor** (a new or expanded capability reaches suite installers).
- otherwise (only child patches, or only repo-level/`{parent source}/` doc and config fixes) → **patch**.

Take the highest of those. Repo-root changes that do not live inside any plugin directory (for example `docs/`, `README.md`, `CONTRIBUTING.md`) are suite-level: they count toward the parent's level (normally patch) and never bump a child.

Compute `proposed` from each plugin's `baseline`: major → `(x+1).0.0`, minor → `x.(y+1).0`, patch → `x.y.(z+1)`.

### 3c. Decide each plugin's target (ahead path vs. compute path)

For each changed plugin, compare `current` to `baseline`:

```
highest=$(printf '%s\n%s\n' "{baseline}" "{current}" | sort -V | tail -n1)
```

- **`current` strictly ahead of `baseline`** (`highest` == `current` and `current` != `baseline`): the version was already bumped during development. **`target = current`. No confirmation for this plugin.** Still compute the expected `proposed`, and if `current` is a *lower* level of bump than the changes warrant, add one non-blocking advisory line to the Step 7 summary.
- **`current` equal to or behind `baseline`**: the one-bump-per-branch bump has not been applied for this plugin. `target = proposed`; this plugin **needs confirmation**.

### 3d. Confirm the plan (single mandatory gate)

`target = parent target` drives the tag `v{parent target}`.

- **If no plugin needs confirmation** (every changed plugin was already ahead, plus the new plugins): the plan is fully determined. Do not prompt. Record it for the Step 7 summary and continue.
- **If one or more plugins need confirmation**: present the whole plan in **one** `AskUserQuestion` (`header: "Release versions"`). State `prev`, and for every plugin a line of the form `{name}: {baseline} → {proposed} ({level}; {evidence})`, marking new plugins as `new at {current} (no bump)`, ahead plugins as `already at {current}`, and unchanged children as `unchanged at {current}`. Name the specific skills/agents and commits that drove each level. Options: accept the proposed plan (recommended, first); adjust the parent level; adjust a child level; enter explicit versions. Apply the operator's answer to the affected plugins. Record the final plan as the version decision in the Step 7 summary.

## Step 4: Apply the versions

For **every** plugin whose `target` differs from its `current` (the compute-path plugins from Step 3c, and any plugin the operator edited at 3d), set both files so they read `target`:

1. Set `{source}/.claude-plugin/plugin.json` `version` to that plugin's `target` (Edit).
2. Sync that plugin's `marketplace.json` entry: set the `version` of the `plugins[]` element whose `name` equals the plugin name (Edit). Select by name, not by index.

Skip any plugin whose `target == current` (ahead-path or new plugins — their files are already correct). When the entire plan is ahead-path/new (no version differs from `current`), this step is a no-op; note it and continue.

## Step 5: Update CHANGELOG.md

Follow [references/changelog-rules.md](references/changelog-rules.md) exactly. From `v3.0.0` onward, each release section is a parent `## v{parent target}` heading with one `### {plugin} v{version}` sub-heading per plugin that changed (the parent always appears; new and changed children appear; unchanged children are omitted), plus the release-level bookkeeping subsections. Every `@mention` in the changelog (narrative, PR bullets, issue bullets) is a markdown link to the person's GitHub profile: `[@{login}](https://github.com/{login})`, never flat text.

1. **Does `## v{parent target}` already exist in `CHANGELOG.md`?** Search for the literal heading.

2. **It exists — augment.** Leave every existing line of that section untouched. Append the generated bookkeeping subsections as the last `###` subsections of the `## v{parent target}` section, before the next `## v` heading, in this order: `### Issues closed in this release` (only when `$issue_list` is non-empty), then `### Pull requests in this release` (or the commits form from the fallback). Build the issue bullets from `$issue_list` and the PR bullets from `$pr_list` (Step 2), and close the final subsection with the `Full changelog:` line using the blob link from [references/release-notes-format.md](references/release-notes-format.md). Use Edit.

3. **It does not exist — generate, then append.** Dispatch **one** `general-purpose` agent to write the narrative `## v{parent target}` section. The skill already holds this context — paste the actual values into the prompt, do not tell the agent to go read them:

   - The version plan from Step 3: parent `baseline → target`, and for each changed/new child its `name`, `baseline → target`, level, and new/changed status.
   - The commit log `git log {range} --oneline` and `git diff {range} --stat`, plus, per changed plugin, `git diff {range} --stat -- {source}/` so the agent can attribute each change to its plugin, plus a suite-level stat `git diff {range} --stat -- docs/ README.md CONTRIBUTING.md CHANGELOG.md .claude-plugin/` labeled as the evidence for the `### han` parent section (repo-root changes outside any plugin directory).
   - `$pr_list` (PR numbers, titles, authors).
   - `$issue_list` (Step 2): each closed issue's number, title, opener, contributors, closing PR(s), and the relevant fix, so the narrative can credit the issue opener where it describes that fix.
   - `$release_context` from Step 1 (may be empty).
   - The two newest existing `## v{X.Y.Z}` sections from `CHANGELOG.md` verbatim, as the register model.
   - The "Register and voice" and "Per-plugin structure" constraints from [references/changelog-rules.md](references/changelog-rules.md), pasted in full.

   Prompt the agent to: produce only the markdown for the `## v{parent target}` section — a one-paragraph summary that names the parent's new version and lists each changed/new child with its version, then one `### {plugin} v{version}` sub-heading per changed or new plugin (parent first), each describing only that plugin's changes (using `####` for topic subsections when needed), then a release-level `### Deferred (YAGNI)` subsection only when work was deliberately cut; when a change closes a tracked issue, name the fix and credit the issue opener inline as a profile link `[@{login}](https://github.com/{login})`; render every `@mention` as a `[@{login}](https://github.com/{login})` profile link, never flat text; match the register of the two pasted sections; obey every hard voice constraint; attribute every change to the plugin whose directory it touched; never invent changes not present in the commits, diff, PR list, or issue list; return only the section markdown with no preamble. If the agent returns anything else, discard it and re-issue with an explicit "return only the section markdown" reminder.

   Insert the returned section directly under the `# Han Release Notes` title, above the previous newest entry (Edit/Write). Then append the generated bookkeeping subsections to it exactly as in the augment case.

## Step 6: Assemble the release notes body

Build the GitHub release body per [references/release-notes-format.md](references/release-notes-format.md): the release's **summary paragraph first** (the one-paragraph overview from the `## v{parent target}` narrative, with no heading above it), then `## What's Changed` and the PR lines (`* {title} by @{login} in {url}`, newest merge last), then an `## Issues closed` section built from `$issue_list` (omitted when empty), then every `### {plugin} v{version}` sub-heading of the narrative **excluding** the `## v{parent target}` heading itself and the generated PR/commits/issues bookkeeping subsections (the summary paragraph already leads the body, so it is not repeated here), then the `**Full changelog:**` blob link and the `**Full Changelog:**` compare link (compare line omitted on a first release). Compute the blob anchor by lowercasing `v{parent target}` and deleting every character that is not `a-z`, `0-9`, or `-` (`v3.0.0` → `v300`). Write the assembled body to `/tmp/han-release-notes-v{parent target}.md` with the Write tool. Do not assemble it with shell `echo`/`printf`.

## Step 7: Show the prepared release

Print to the operator, regardless of mode:

- The full version plan: the tag `v{parent target}`, the parent's `baseline → target` and how it was decided (ahead-of-tag → used as-is, or computed-and-confirmed at Step 3), and one line per child (`bumped baseline → target`, `unchanged at version`, or `new at version`).
- The branch the tag will point at, plus the non-default-branch note from Step 1.3 if it applies.
- Any non-blocking advisory from Step 3 (under-bump warning on any plugin) and the post-release advisory check: if `CLAUDE.md` states a "Current version:" that does not equal the parent `target`, note it as a follow-up the operator may want to make (do not edit `CLAUDE.md`; it is out of scope).
- The exact CHANGELOG diff for the `## v{parent target}` section.
- The full assembled release notes body from Step 6.
- The publish mode: published `--latest`, or draft (only if `draft_release`).

**If `pause_before_publish` is true:** use `AskUserQuestion` (`header: "Publish release"`) — options: publish now (proceed to Step 8), abort (stop, having changed only local files). Do not push or publish until approved.

**If `pause_before_publish` is false (default):** continue to Step 8 without pausing.

## Step 8: Commit, tag, and push

The operator's request to tag and publish authorizes the commit and push required to do it.

1. **Commit the release prep.** Stage `CHANGELOG.md`, `.claude-plugin/marketplace.json`, and every `{source}/.claude-plugin/plugin.json` that Step 4 changed. Commit with `chore(release): v{parent target}`. If nothing is staged (augment produced no diff and no version changed — unlikely), skip the commit and note it.

2. **Tag.** If tag `v{parent target}` already exists (`git tag -l v{parent target}` non-empty, or `git ls-remote --tags origin v{parent target}` non-empty), do **not** recreate it; note that the version was already tagged and continue. Otherwise create it annotated at the release commit: `git tag -a v{parent target} -m "v{parent target}"`.

3. **Push.** `git push origin HEAD` then `git push origin v{parent target}`.

## Step 9: Publish the GitHub release

Per [references/release-notes-format.md](references/release-notes-format.md), using `/tmp/han-release-notes-v{parent target}.md`:

- **No release exists for `v{parent target}`** (`gh release view v{parent target}` fails): `gh release create v{parent target} --title "v{parent target}" --notes-file /tmp/han-release-notes-v{parent target}.md` plus `--latest`, plus `--draft` only when `draft_release` is true (never `--latest` together with `--draft`).
- **A release already exists:** do not create a second one. `gh release edit v{parent target} --notes-file /tmp/han-release-notes-v{parent target}.md`. Add `--draft=false` only when the operator asked to publish an existing draft (and `draft_release` is not set). Report it as updated, not created.

## Step 10: Report

Report concisely: the full version plan (parent and each child, and how the parent version was decided); the tag (created or already existed); the files committed and the commit; the release URL (or draft URL); whether the CHANGELOG section was augmented or generated; and any advisories from Step 7 (under-bump, `CLAUDE.md` version drift, non-default release branch). If `pause_before_publish` was true and the operator aborted at Step 7, report exactly what was changed locally and what was not pushed or published.
