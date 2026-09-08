---
name: han-release
description: >
  Cut a Han release: update CHANGELOG.md with the changes since the last release, bump and tag every plugin that changed
  as {plugin-name}--v{version} so a version-constrained dependency can resolve, and publish a GitHub release crediting
  every merged pull request and closed issue to the people behind it. Use when releasing, cutting a release, shipping a
  new Han version, publishing release notes, or tagging a version. Always stops for approval before creating any tag,
  because a pushed tag is never moved. Requires the gh CLI, jq, the claude CLI, and a clean git checkout. This is a
  repository-maintenance skill for the Han repo itself, not a general review or PR skill — use code-review for local
  review, post-code-review-to-pr to post a PR review, and update-pr-description for PR bodies.
argument-hint: "[pause before publishing] [draft] [optional release context]"
allowed-tools:
  Read, Edit, Write, Glob, Grep, Agent, Bash(git *), Bash(gh *), Bash(jq *), Bash(which *), Bash(grep *), Bash(sed *),
  Bash(head *), Bash(command claude *)
---

<!--
`AskUserQuestion` is deliberately absent from `allowed-tools`, and must stay absent. Listing it makes Claude Code's
permission evaluator auto-approve the tool through its always-allow path and return empty answers without ever
rendering the prompt, so every gate in this skill would silently pass. See
han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md. The tool still
works unlisted; it prompts once for permission.
-->

## Pre-requisites

- gh CLI: !`which gh 2>/dev/null || echo "not installed"`
- jq: !`which jq 2>/dev/null || echo "not installed"`
- claude CLI: !`which claude 2>/dev/null || echo "not installed"`
- git repo: !`git rev-parse --is-inside-work-tree 2>/dev/null || echo NO`

**If `gh`, `jq`, or `claude` reads `not installed`, or this is not a git repo:** tell the operator which prerequisite is
missing and that it must be installed/configured before `/han-release` can run, then **immediately stop**. The skill
cannot proceed without all four.

The `claude` CLI is what creates the per-plugin tags in Step 10. Every invocation of it in this skill goes through the
shell's `command` builtin (`command claude ...`), never a bare `claude`, because an operator's shell commonly wraps
`claude` in a function or alias that blocks waiting for terminal input. The `which` probe above resolves the same way a
bare call would, so it reports the wrapper's presence rather than the executable's; treat a non-empty result as "the
tool is reachable" and let Step 10's first invocation be what proves it runs.

## Project Context

- repo: !`gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || git config --get remote.origin.url`
- current branch: !`git branch --show-current 2>/dev/null || echo unknown`
- default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || echo unknown`
- working tree: !`git status --porcelain 2>/dev/null || echo NO`
- parent plugin name: !`jq -r .name .claude-plugin/marketplace.json 2>/dev/null`
- plugins (name source version):
  !`jq -r '.plugins[] | "\(.name)\t\(.source)\t\(.version)"' .claude-plugin/marketplace.json 2>/dev/null`
- latest parent tag: !`git fetch --tags --quiet >/dev/null 2>&1; git tag -l 'han--v*' --sort=-v:refname | head -n1`
- latest suite tag: !`git tag -l 'v*.*.*' --sort=-v:refname | head -n1`
- changelog head: !`grep -m1 '^## v' CHANGELOG.md 2>/dev/null`

The two tag probes are separate on purpose. A single pattern covering both namings returns the **wrong** tag: version
sorting compares the whole refname, so `v4.6.0` sorts ahead of `han--v5.0.0` and the old suite tag wins on every release
after the transition. The fetch runs on the first probe only; both read the same refreshed tag list.

`latest parent tag` carries the literal `han--v*` pattern, because a context-injection command is a fixed string and
cannot interpolate `parent plugin name`. If `parent plugin name` is not `han`, redo the lookup in Step 2 with the actual
name before using either value. Skipping that turns a renamed parent into an empty probe, which Step 2 would read as a
first release and silently expand the changelog to the whole repository history.

### Vocabulary used throughout this skill

- **parent** — the meta-plugin whose name equals the marketplace `name` (`parent plugin name` above, normally `han`). It
  has no skills or agents of its own; it exists to install the children via `dependencies`. The parent's own per-plugin
  tag is the one the GitHub release attaches to, so the release tag is `{parent plugin name}--v{parent target}`.
- **children** — every other entry in `marketplace.json.plugins[]` (`han-core`, `han-github`, `han-reporting`, and any
  future `han-*` plugin). Each child has its own version line, bumped independently of the others.
- **baseline** of a plugin — its version at `prev` (the latest release tag). For the parent this is `prev#`. For a child
  it is the version recorded in that child's `plugin.json` at `prev`; if the child did not exist at `prev`, it is a
  **new plugin** (see Step 3).
- **current** of a plugin — the version in its working-tree `plugin.json`.
- **target** of a plugin — the version being released for it. The release tag is
  `{parent plugin name}--v{parent target}`.
- **tag name** of a plugin — `{name}--v{target}`, for example `han--v5.0.0` and `han-core--v3.0.0`. Every plugin gets
  one, and the parent's is what the GitHub release attaches to.
- `prev` is the previous release's tag, resolved in Step 2 from the two tag probes. On the first release it is empty.
- `prev#` is **the part of `prev` after its last `v`**. That rule is correct under both namings, which matters because
  `prev` can be either shape:

  ```
  v4.6.0        -> prev# is 4.6.0
  han--v5.0.0   -> prev# is 5.0.0
  ```

  Do not read `prev#` as "the number without the leading `v`". That older rule returns the whole tag string for a
  per-plugin tag, and `prev#` is the parent's baseline (see 3a in `references/version-plan-rules.md`), so a wrong value here silently corrupts the entire
  version plan rather than failing.

- Each plugin's source directory comes from the `source` field in `marketplace.json` (for example `./han-core`), so its
  `plugin.json` is `{source}/.claude-plugin/plugin.json`. Use `{source}` verbatim in every git command: the
  `./`-prefixed form works both after a `{ref}:` colon (`git show {prev}:{source}/...`) and as a pathspec
  (`git diff ... -- {source}/`). Do not strip the leading `./`.

## Step 1: Parse the invocation and check release safety

1. **Parse `$ARGUMENTS`** for two independent flags, then treat the remaining free text as optional release context that
   informs the changelog narrative:
   - `pause_before_publish` — true if the argument contains "pause", "review", or "confirm before publish"
     (case-insensitive). Default **false**.
   - `draft_release` — true if the argument contains "draft". Default **false**.
   - The leftover text (anything that is not those flag phrases) is `$release_context`, passed into the narrative
     dispatch in Step 5. May be empty.

2. **Working tree must be clean.** If `working tree` from Project Context is non-empty, there are uncommitted or
   untracked changes. Stop and tell the operator to commit or stash them first. Releasing an unknown working state is
   unsafe and a pushed tag is hard to reverse. This is a hard stop, not a pause gate.

3. **Branch note (non-blocking).** If `current branch` is not the `default branch`, do not stop — note in the Step 7
   summary that the release is being cut from `current branch` and the tag will point at that branch's `HEAD`. The
   operator chose autonomous; surface the fact, do not block.

## Step 2: Determine previous version, commit range, and PR list

1. **Resolve `prev` from the two tag probes, in this order:**
   1. `latest parent tag` when it is non-empty. This is the normal case from the second per-plugin release onward.
   2. Otherwise `latest suite tag`. This is the transition release, the one release where the previous tag still carries
      the old `vX.Y.Z` naming. Once a parent tag exists on the remote this arm is unreachable and can be deleted.
   3. Otherwise empty: this is the **first release**. There is no previous tag, the commit range is the full history,
      all compare links are omitted, and every plugin is treated as new (Step 3).

   If `parent plugin name` is not `han`, the `latest parent tag` probe used the wrong literal. Re-run the lookup
   yourself before applying the precedence above:
   `git tag -l '{parent plugin name}--v*' --sort=-v:refname | head -n1`.

   `prev` feeds two different things: the commit range below, **and** the parent's baseline version at 3a in `references/version-plan-rules.md` via
   `prev#`. Parse `prev#` with the after-the-last-`v` rule in the vocabulary block, not by stripping a leading `v`.

2. **Commit range.** With a previous tag: `${prev}..HEAD`. First release: the full history (`HEAD` with no range base).

3. **Nothing to release check.** Run `git log {range} --oneline`. If it is empty, there are no commits since `prev`.
   Stop and tell the operator there is nothing to release.

4. **Collect merged PRs in the range.** Extract PR numbers from both squash subjects and merge commits:

   ```
   git log {range} --pretty=%s%x00%b | grep -oE '#[0-9]+' | tr -d '#' | sort -un
   ```

   For each number `N`, run `gh pr view N --json number,title,author,url,mergedAt,state`. Keep only entries where
   `state` is `MERGED`. Sort the survivors by `mergedAt` ascending (newest merge last). This is `$pr_list`. The PR list
   is repo-wide and appears once per release; it is not split per plugin. Build the PR lines and the changelog bullets
   per [references/release-notes-format.md](./references/release-notes-format.md) and
   [references/changelog-rules.md](./references/changelog-rules.md).

5. **No-PR fallback.** If `$pr_list` is empty (local-only or squash history with no PR refs), record the notable commit
   subjects from `git log {range} --oneline` instead, and use the commits form documented in both reference files.

6. **Collect closed issues and their attribution.** For each merged PR `N` in `$pr_list`, find the issues that PR
   closed and credit everyone involved, following [references/attribution-rules.md](./references/attribution-rules.md).
   That file holds the closing-issue lookup, the substantive-comment test that decides who counts as a contributor, the
   bot-account exclusions, and the shape of each `$issue_list` entry. If no closed issues are found, `$issue_list` is
   empty and the issues subsection/section is omitted everywhere.

## Step 3: Build the per-plugin version plan

Enumerate the plugins from `plugins` in Project Context (one parent, plus each child). For **every** plugin, determine
`baseline`, whether it changed in `{range}`, and its `target`. Classify changes against
[`docs/semantic-versioning.md`](../../../docs/semantic-versioning.md). The governing rules:

- **The parent always bumps on every release.** Even when only one child changed, the parent gets a version bump,
  because every release is a release of the suite.
- **A child bumps only when its own directory changed in `{range}`.** A child with no changes keeps its version.
- **A brand-new plugin is not bumped by the release that introduces it.** Its `plugin.json` version is its established
  baseline. Record the introduction in the changelog, but do not increment. This is the general rule for every future
  `han-*` extension, not a one-time exception for the current children.

Classify each plugin, compute its bump level, and decide its target by following
[references/version-plan-rules.md](./references/version-plan-rules.md). That file holds the baseline lookup for a
parent, an existing child, and a new child (3a); the major, minor, and patch classification for a changed child and for
the parent (3b); and the ahead-path versus compute-path decision that determines which plugins need confirmation below
(3c).

### 3d. Confirm the plan (conditional gate)

`target = parent target` drives the tag `{parent plugin name}--v{parent target}`.

This gate is conditional and often does not fire. It is **not** the gate that approves the tags; that one is Step 9 and
it always fires.

- **If no plugin needs confirmation** (every changed plugin was already ahead, plus the new plugins): the plan is fully
  determined. Do not prompt. Record it for the Step 7 summary and continue.
- **If one or more plugins need confirmation**: present the whole plan in **one** `AskUserQuestion`
  (`header: "Release versions"`). State `prev`, and for every plugin a line of the form
  `{name}: {baseline} → {proposed} ({level}; {evidence})`, marking new plugins as `new at {current} (no bump)`, ahead
  plugins as `already at {current}`, and unchanged children as `unchanged at {current}`. Name the specific skills/agents
  and commits that drove each level. Options: accept the proposed plan (recommended, first); adjust the parent level;
  adjust a child level; enter explicit versions. Apply the operator's answer to the affected plugins. Record the final
  plan as the version decision in the Step 7 summary.

## Step 3.5: Validate every plugin before anything is written

Run this **before** Step 4 writes anything. The working tree is still clean here, and that is the point: a failure at
this step leaves the repository exactly as the run found it, with nothing written and nothing pushed.

Both checks cover **every** plugin in `plugins`, not only the ones being bumped. Version drift in an untouched plugin is
the likeliest way this fails, because Step 4 only writes plugins whose `target` differs from `current` and so never
corrects a plugin nobody changed.

1. **Version agreement.** For each plugin, compare its `plugin.json` version against its `marketplace.json` entry
   selected by name:

   ```
   jq -r .version {source}/.claude-plugin/plugin.json
   jq -r --arg n '{name}' '.plugins[] | select(.name == $n) | .version' .claude-plugin/marketplace.json
   ```

   Any disagreement **stops the run**. Name the plugin and both versions. Do not attempt a repair: the correct value
   depends on which file is wrong, and that is the operator's call.

2. **Tree cleanliness.** `git status --porcelain` must be empty. Step 1.2 already required this, so a non-empty result
   here means something wrote a file since the run started. Stop and say so.

Do **not** implement either check by invoking `command claude plugin tag --dry-run`. That command refuses on a dirty
plugin folder, and after Step 4 every bumped plugin's folder is dirty by construction, so a dry-run sweep placed after
the writes refuses exactly the plugins the release just bumped and cannot tell that refusal apart from real drift. The
two reads above answer the same question and work in either state.

## Step 4: Apply the versions

For **every** plugin whose `target` differs from its `current` (the compute-path plugins from 3c in `references/version-plan-rules.md`, and any plugin
the operator edited at 3d), set both files so they read `target`:

1. Set `{source}/.claude-plugin/plugin.json` `version` to that plugin's `target` (Edit).
2. Sync that plugin's `marketplace.json` entry: set the `version` of the `plugins[]` element whose `name` equals the
   plugin name (Edit). Select by name, not by index.

Skip any plugin whose `target == current` (ahead-path or new plugins — their files are already correct). When the entire
plan is ahead-path/new (no version differs from `current`), this step is a no-op; note it and continue.

**Re-run the version-agreement check from Step 3.5 over every plugin this step wrote.** Each plugin's two files are
edited separately, so this step is the one place in the run that can create a half-applied bump. Skip the cleanliness
check here: the tree is dirty by design now. A disagreement stops the run, and nothing has been committed yet, so the
recovery is discarding the working-tree edits.

## Step 5: Update CHANGELOG.md

Follow [references/changelog-rules.md](./references/changelog-rules.md) exactly, writing the narrative in the voice at
[writing-voice.md](../../../han-communication/references/writing-voice.md). From `v3.0.0` onward, each release
section is a parent `## v{parent target}` heading with one `### {plugin} v{version}` sub-heading per plugin that changed
(the parent always appears; new and changed children appear; unchanged children are omitted), plus the release-level
bookkeeping subsections. Every `@mention` in the changelog (narrative, PR bullets, issue bullets) is a markdown link to
the person's GitHub profile: `[@{login}](https://github.com/{login})`, never flat text.

1. **Does `## v{parent target}` already exist in `CHANGELOG.md`?** Search for the literal heading.

2. **It exists — augment.** Leave every existing line of the narrative untouched. Put the generated bookkeeping
   subsections as the last `###` subsections of the `## v{parent target}` section, before the next `## v` heading, in
   this order: `### Issues closed in this release` (only when `$issue_list` is non-empty), then
   `### Pull requests in this release` (or the commits form from the fallback). Build the issue bullets from
   `$issue_list` and the PR bullets from `$pr_list` (Step 2), and close the final subsection with the `Full changelog:`
   line using the blob link from [references/release-notes-format.md](./references/release-notes-format.md). Use Edit.

   **If a generated bookkeeping subsection is already present under this heading, replace it in place rather than
   appending a second copy.** A re-run reaching this branch is ordinary: the Step 9 tag gate sits after the release
   commit, so declining it and running again later brings the run back to its own changelog section.

3. **It does not exist — generate, then append.** Dispatch **one** `general-purpose` agent to write the narrative
   `## v{parent target}` section. The skill already holds this context — paste the actual values into the prompt, do not
   tell the agent to go read them:

   - The version plan from Step 3: parent `baseline → target`, and for each changed/new child its `name`,
     `baseline → target`, level, and new/changed status.
   - The commit log `git log {range} --oneline` and `git diff {range} --stat`, plus, per changed plugin,
     `git diff {range} --stat -- {source}/` so the agent can attribute each change to its plugin, plus a suite-level
     stat `git diff {range} --stat -- docs/ README.md CONTRIBUTING.md CHANGELOG.md .claude-plugin/` labeled as the
     evidence for the `### han` parent section (repo-root changes outside any plugin directory).
   - `$pr_list` (PR numbers, titles, authors).
   - `$issue_list` (Step 2): each closed issue's number, title, opener, contributors, closing PR(s), and the relevant
     fix, so the narrative can credit the issue opener where it describes that fix.
   - `$release_context` from Step 1 (may be empty).
   - The two newest existing `## v{X.Y.Z}` sections from `CHANGELOG.md` verbatim, as the register model.
   - The "Register and voice" and "Per-plugin structure" constraints from
     [references/changelog-rules.md](./references/changelog-rules.md), pasted in full.

   Prompt the agent to: produce only the markdown for the `## v{parent target}` section — a one-paragraph summary that
   names the parent's new version and lists each changed/new child with its version, then one `### {plugin} v{version}`
   sub-heading per changed or new plugin (parent first), each describing only that plugin's changes (using `####` for
   topic subsections when needed), then a release-level `### Deferred (YAGNI)` subsection only when work was
   deliberately cut; when a change closes a tracked issue, name the fix and credit the issue opener inline as a profile
   link `[@{login}](https://github.com/{login})`; render every `@mention` as a `[@{login}](https://github.com/{login})`
   profile link, never flat text; match the register of the two pasted sections; obey every hard voice constraint;
   attribute every change to the plugin whose directory it touched; never invent changes not present in the commits,
   diff, PR list, or issue list; return only the section markdown with no preamble. If the agent returns anything else,
   discard it and re-issue with an explicit "return only the section markdown" reminder.

   Insert the returned section directly under the `# Han Release Notes` title, above the previous newest entry
   (Edit/Write). Then append the generated bookkeeping subsections to it exactly as in the augment case.

## Step 6: Assemble the release notes body

Build the GitHub release body per [references/release-notes-format.md](./references/release-notes-format.md): the
release's **summary paragraph first** (the one-paragraph overview from the `## v{parent target}` narrative, with no
heading above it), then `## What's Changed` and the PR lines (`* {title} by @{login} in {url}`, newest merge last), then
an `## Issues closed` section built from `$issue_list` (omitted when empty), then every `### {plugin} v{version}`
sub-heading of the narrative **excluding** the `## v{parent target}` heading itself and the generated PR/commits/issues
bookkeeping subsections (the summary paragraph already leads the body, so it is not repeated here), then the
`**Full changelog:**` blob link and the `**Full Changelog:**` compare link (compare line omitted on a first release).
Compute the blob anchor by lowercasing `v{parent target}` and deleting every character that is not `a-z`, `0-9`, or `-`
(`v3.0.0` → `v300`). Write the assembled body to `/tmp/han-release-notes-v{parent target}.md` with the Write tool. Do
not assemble it with shell `echo`/`printf`.

## Step 7: Show the prepared release

Print to the operator, regardless of mode:

- The full version plan: the release tag `{parent plugin name}--v{parent target}`, the parent's `baseline → target` and
  how it was decided (ahead-of-tag → used as-is, or computed-and-confirmed at Step 3), and one line per child
  (`bumped baseline → target`, `unchanged at version`, or `new at version`).
- The branch the tags will point at, plus the non-default-branch note from Step 1.3 if it applies.
- Any non-blocking advisory from Step 3 (under-bump warning on any plugin) and the post-release advisory check: if
  `CLAUDE.md` states a "Current version:" that does not equal the parent `target`, note it as a follow-up the operator
  may want to make (do not edit `CLAUDE.md`; it is out of scope).
- The exact CHANGELOG diff for the `## v{parent target}` section.
- The full assembled release notes body from Step 6.
- The publish mode: published `--latest`, or draft (only if `draft_release`).

**If `pause_before_publish` is true:** use `AskUserQuestion` (`header: "Publish release"`) — options: publish now
(proceed to Step 8), abort (stop, having changed only local files). Do not push or publish until approved.

**If `pause_before_publish` is false (default):** continue to Step 8 without pausing.

This gate is opt-in and covers the whole release. It is separate from the Step 9 tag gate, which always fires and
covers the tags only. When both fire they arrive close together; that is intended, and the distinct `header` values are
what tell them apart.

## Step 8: Commit and push the release commit

The operator's request to tag and publish authorizes the commit and push required to do it.

1. **Commit the release prep.** Stage `CHANGELOG.md`, `.claude-plugin/marketplace.json`, and every
   `{source}/.claude-plugin/plugin.json` that Step 4 changed. Commit with `chore(release): v{parent target}`. The commit
   subject keeps the plain version; it is a message, not a ref. If nothing is staged (augment produced no diff and no
   version changed — unlikely), skip the commit and note it.

2. **Record `{release commit}`.** `git rev-parse HEAD`. Every tag must point here, and Step 9 re-checks it.

3. **Push the commit, before any tag.** `git push origin HEAD`. If this fails, **stop**: no tag has been created, so
   nothing irreversible has happened. Pushing a tag first would transfer the commit to GitHub without putting it on any
   branch, and a tag can never be moved afterwards.

## Step 9: Approve the tags (mandatory gate)

The commit is on GitHub and no tag exists yet. Everything past this point is irreversible.

1. **Compute each plugin's `tag name`** as `{name}--v{target}`, for every plugin in `plugins`, then split them into two
   sets using the Step 3 version plan:
   - **Being tagged this release** — every plugin whose `target` differs from its `baseline` (the parent always, plus
     each bumped child), and every **new** plugin classified at 3a, whose tag has never existed.
   - **Carried forward** — every unchanged child, whose `target` equals its `baseline`. Its tag was created by the
     release that shipped that version and points at that older release commit. This run does not re-tag it.

   A release commonly bumps a handful of plugins and carries the rest forward, so the carried-forward set is routine
   rather than exceptional. Treating it as an error blocks every release after the first.

2. **Classify every tag against the remote** in one call:

   ```
   ${CLAUDE_SKILL_DIR}/scripts/remote-tag-state.sh {release commit} {tag name}...
   ```

   It prints `{tag}\t{state}\t{sha}` per tag. Exit 2 means the remote could not be read: stop, because a run that cannot
   see the remote must not guess. The script reports what the remote holds and nothing more; this step decides what each
   state means, because one of the four means different things for the two sets:

   | State                    | What Step 10 does with it                      |
   | ------------------------ | ---------------------------------------------- |
   | `absent`                 | Create and push it.                            |
   | `remote-at-commit`       | Skip it. Already published at this commit.     |
   | `remote-at-other-commit` | Depends on which set the plugin is in (see 3). |
   | `local-only`             | Push it. This is never a skip.                 |

3. **Read each `remote-at-other-commit` against the set its plugin is in.** A tag pointing somewhere other than
   `{release commit}` is the normal resting state for a carried-forward plugin and an unrecoverable collision for one
   being tagged now, so the two cannot share a rule.
   - **Carried forward:** run `git merge-base --is-ancestor {sha} {release commit}`. When it succeeds, the tag points
     into this release's own history, which is what an already-shipped version looks like. Record it as **already on
     GitHub** and skip it; Step 10 never touches it. When the check fails, the tag sits on a commit this release does
     not descend from, so treat it as the stop below.
   - **Being tagged this release:** stop, always. No ancestor check applies, because the version this run is about to
     publish is already taken.

   **On a stop**, stop before a single tag is created. Name the tag, the commit it points at, and `{release commit}`.
   Say plainly that pushing is **not** the recovery: the push is rejected identically every time, GitHub does not allow
   a published release's tag to be moved or deleted, and this skill never forces one. The way out is a different version
   number, which is free right now and costs a burned version once the walk starts.

4. **Ask for approval** with `AskUserQuestion` (`header: "Tag plugins"`). Show:
   - The tags to create and push, named individually.
   - Separately, the tags already on GitHub that this run leaves untouched, including every carried-forward plugin
     resolved at 3. Say that none of them is moved or deleted.
   - `{release commit}` and the branch it is on, with the Step 1.3 note if it is not the default branch.
   - When `draft_release` is true, that the draft flag holds back the release page only. Every tag is still created and
     pushed, and none of them can be moved afterwards.

   Options: create and push the tags (recommended, first); abort.

5. **This gate always fires.** Unlike Step 3d it has no skip condition, because the tags are permanent whether or not a
   version needed computing.

6. **Treat an empty or unreadable answer as an abort.** Do not read it as approval. `AskUserQuestion` has a known
   failure mode that returns empty answers silently, which is why it is absent from `allowed-tools` (see the note under
   the frontmatter). This is the one gate in this skill where that failure would be unrecoverable.

7. **On abort:** stop. Nothing is tagged and nothing is published. The release commit is already made and pushed, so say
   so, name it, and say that re-running later picks up from there: the changelog section already exists, so the run will
   augment it rather than regenerate it.

8. **Re-read `git rev-parse HEAD` after approval.** If it no longer equals `{release commit}`, **stop**. The tags are
   created against the current checkout, so a commit made while the gate was waiting would tag something that was never
   pushed.

## Step 10: Tag every plugin

Walk `plugins`, taking the entry whose name equals `parent plugin name` **first**, then the rest in listed order. The
parent goes first so the tag the GitHub release attaches to is the one most likely to exist if the walk stops partway.
Order by name, not by position in the file.

For each plugin, act on the outcome Step 9 recorded for it:

- **`remote-at-commit`** — skip. Record it as already on GitHub.
- **Carried forward, resolved at Step 9.3** — skip. Record it as already on GitHub. Its tag belongs to the release that
  shipped that version, and this run leaves it exactly where it is.
- **`local-only`** — `git push origin refs/tags/{tag name}`. Record it as newly pushed.
- **`absent`** — create and push it in one call:

  ```
  command claude plugin tag {source} --push
  ```

  The `command` builtin is required, not stylistic: a bare `claude` runs whatever function or alias the operator's shell
  defines, which commonly blocks waiting for terminal input. The command derives the tag name from the plugin's manifest
  and marketplace entry and re-checks that the two agree, so a disagreement that reached this point surfaces here.

**Never pass `--force`.** It skips both the dirty-tree and tag-exists checks, and this skill does not move tags.

**Reading a failure.** The command exits 1 for both a benign refusal and a real failure, so the exit status alone does
not tell them apart. Match the message:

- `already exists locally` — the tag is on this machine but was not on the remote at Step 9, so a push is what is
  needed. Push it as in the `local-only` case above. Do not re-run the tagging command; it will refuse identically.
- **Any other non-zero exit stops the run.** That includes a push rejection, an uncommitted change under a plugin
  folder, and a version disagreement that Step 3.5 should have caught. A stop here is unexpected rather than routine.

**On a stop mid-walk**, do not publish. Report the full tag state: which tags are on GitHub, which exist only on this
machine, and for each of the latter the literal recovery command `git push origin refs/tags/{tag name}`. Re-running
`/han-release` does **not** retry a failed push, so never offer that as the recovery.

## Step 11: Publish the GitHub release

1. **Re-run the classification** from Step 9 over every plugin's `tag name`, holding each result to the rule for its
   set. Every plugin **being tagged this release** must now read `remote-at-commit`. Every **carried-forward** plugin
   must read either `remote-at-commit` or the same `remote-at-other-commit` sha that passed the ancestor check at Step
   9.3. No plugin in either set may read `absent` or `local-only`.

   If any result fails its rule, **stop** and report as in Step 10. Publishing with a tag missing from GitHub is the
   failure this gate exists to prevent. Demanding that every tag sit on `{release commit}` is not that check: it would
   stop every release that carries an unchanged plugin forward, which is nearly all of them.

2. **Publish**, per [references/release-notes-format.md](./references/release-notes-format.md), using
   `/tmp/han-release-notes-v{parent target}.md` (the filename keeps the plain version; it is a local path, not a ref):

   - **No release exists for the tag** (`gh release view {parent plugin name}--v{parent target}` fails):
     `gh release create {parent plugin name}--v{parent target} --verify-tag --title "v{parent target}" --notes-file /tmp/han-release-notes-v{parent target}.md`
     plus `--latest`, plus `--draft` only when `draft_release` is true (never `--latest` together with `--draft`).

     `--verify-tag` is required. Without it `gh` silently creates a missing tag at the default branch's head, which
     would mint a permanent tag at a commit nobody released. The `--title` keeps the plain `v{parent target}` so the
     releases page reads continuously across the naming change.

   - **A release already exists:** do not create a second one.
     `gh release edit {parent plugin name}--v{parent target} --notes-file /tmp/han-release-notes-v{parent target}.md`.
     Add `--draft=false` only when the operator asked to publish an existing draft (and `draft_release` is not set).
     Report it as updated, not created.

## Step 12: Report

Report concisely:

- The full version plan (parent and each child, and how the parent version was decided).
- `{release commit}`, and whether it is on the default branch.
- **One line per plugin naming its final tag state**: newly pushed, already on GitHub (whether skipped at
  `remote-at-commit` or carried forward from an earlier release), or present only on this machine. Those three are
  different, and "created" plus "skipped" cannot express the third, which is the state a partly-failed release leaves
  behind.
- Any tag still local-only, with its literal `git push origin refs/tags/{tag name}` recovery line.
- The files committed and the commit; the release URL (or draft URL); whether the CHANGELOG section was augmented or
  generated.
- Any advisories from Step 7 (under-bump, `CLAUDE.md` version drift, non-default release branch).

If the operator aborted at Step 7 or Step 9, report exactly what was changed locally, what was pushed, and what was
not.
