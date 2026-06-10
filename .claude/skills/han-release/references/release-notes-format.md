# GitHub release notes format

The release notes body is assembled deterministically: the release's summary paragraph leads (no heading), followed by a `## What's Changed` PR list, an `## Issues closed` section, the per-plugin `### {plugin} v{version}` narrative sub-headings, then the full-changelog links. The release is named for the parent `han` plugin's version, so the tag and the body title are both `v{parent target}`.

## Body template

```
{the summary paragraph of the v{parent target} narrative: the one-paragraph
 release overview, with NO heading above it. This leads the body.}

## What's Changed

{one line per merged PR, newest merge last}

## Issues closed

{one line per issue closed by this release's PRs, omitted entirely when none}

{every ### {plugin} v{version} sub-heading (with their #### topic subsections) of
 the ## v{parent target} section, EXCLUDING the generated "### Issues closed in
 this release", "### Pull requests in this release", and "### Commits in this
 release" subsections (those are changelog-only bookkeeping). Do NOT include the
 ## v{parent target} heading itself, and do NOT repeat the summary paragraph
 here: it already leads the body above.}

**Full changelog:** {blob link}
**Full Changelog:** {compare link}
```

The body opens with the release's summary paragraph (no heading), then `## What's Changed` and `## Issues closed`, then the per-plugin `### {plugin} v{version}` sub-headings exactly as they appear under `## v{parent target}` in `CHANGELOG.md`. The summary paragraph appears once, at the top; the `## v{parent target}` heading is not carried into the body, and the summary is not repeated above the sub-headings. The release notes still show which child plugins changed and their new versions. Do not flatten or regroup the sub-headings.

If there is no previous release (this is the first tag), omit the `**Full Changelog:**` compare line and keep only the `**Full changelog:**` blob link.

If no merged PRs were found, replace the PR list with a single line: `* Direct commits since {prev tag}; see the full changelog below.` and still include the narrative and links. This is the release-body form of the no-PR fallback. The `CHANGELOG.md` no-PR fallback is different by design: it lists each commit under a `### Commits in this release` subsection (see [changelog-rules.md](./changelog-rules.md)). The body summarizes; the changelog enumerates.

## PR line format

One bullet per merged pull request, sorted by merge time ascending (newest merge last):

```
* {PR title} by @{author login} in {PR url}
```

This is the same format GitHub's auto-generated notes use and the same format prior Han releases used. Authors are attributed by GitHub login with a leading `@`. The PR list is repo-wide and is not split per plugin.

In the GitHub release body, mentions stay as bare `@login`: GitHub auto-links them to profiles and notifies the people. (In `CHANGELOG.md` the mentions are explicit markdown links, because a rendered blob does not auto-link. See [changelog-rules.md](./changelog-rules.md).)

## Issues closed section

The `## Issues closed` section lists every issue closed by this release's PRs, relating each issue to the fix and crediting the people involved. Omit the section entirely when no issues were closed. One bullet per issue:

```
* {issue title} (#{issue number}) — opened by @{opener}, fixed in #{PR number} by @{worker}, @{worker}; thanks to @{contributor}
```

`{opener}` is the person who opened the issue, `{worker}` are the people who worked on the closing PR (author, reviewers, commit/co-authors), and `{contributor}` are the people who contributed meaningfully to the issue: those who left a substantive comment (reactions and drive-by comments like a bare `+1`, `bump`, `thanks`, or an emoji-only reply do not count), with the opener and PR workers removed and the `; thanks to ...` clause omitted when empty. Exclude bot accounts. Mentions stay bare `@login` here, the same as the PR list.

## Full-changelog links

**Blob link** points at the `CHANGELOG.md` section for this exact version, pinned to the tag:

```
https://github.com/{owner}/{repo}/blob/v{parent target}/CHANGELOG.md#{anchor}
```

Compute `{anchor}` from the heading text `v{parent target}`: lowercase it, then delete every character that is not `a-z`, `0-9`, or `-`. Dots are deleted. Examples: `v3.0.0` → `v300`; `v3.1.0` → `v310`; `v2.10.1` → `v2101`.

**Compare link** is GitHub's standard range link from the previous release tag to this one:

```
https://github.com/{owner}/{repo}/compare/{prev tag}...v{parent target}
```

`{owner}/{repo}` comes from `gh repo view --json nameWithOwner`. `{prev tag}` is the previous released tag (for example `v2.7.0`). Omit the compare link entirely when there is no previous tag.

## Publish vs. draft, and idempotency

- **Publish (default):** `gh release create v{parent target} --title "v{parent target}" --latest --notes-file {file}`.
- **Draft (only when explicitly requested):** add `--draft`. Do not pass `--latest` with `--draft`.
- **Release already exists for the tag:** do not create a second one. Update it in place with `gh release edit v{parent target} --notes-file {file}` (add `--draft=false` only if the operator asked to publish an existing draft). Report that the release was updated rather than created.

Write the assembled body to a temp file with the Write tool and pass it via `--notes-file`. Do not build the body with shell `echo`/`printf`.
