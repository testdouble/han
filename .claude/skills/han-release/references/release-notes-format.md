# GitHub release notes format

The release notes body is assembled deterministically. It mirrors the format already used by published Han releases (see `gh release view v2.3.0`): a `## What's Changed` PR list, the release's changelog narrative, then the full-changelog links.

## Body template

```
## What's Changed

{one line per merged PR, newest merge last}

{the changelog narrative for v{target}: the summary paragraph and every
 ### subsection of the ## v{target} section, EXCLUDING the generated
 "### Pull requests in this release" / "### Commits in this release"
 subsection — that subsection is changelog-only bookkeeping}

**Full changelog:** {blob link}
**Full Changelog:** {compare link}
```

If there is no previous release (this is the first tag), omit the `**Full Changelog:**` compare line and keep only the `**Full changelog:**` blob link.

If no merged PRs were found, replace the PR list with a single line: `* Direct commits since {prev tag}; see the full changelog below.` and still include the narrative and links.

## PR line format

One bullet per merged pull request, sorted by merge time ascending (newest merge last):

```
* {PR title} by @{author login} in {PR url}
```

This is the same format GitHub's auto-generated notes use and the same format prior Han releases used. Authors are attributed by GitHub login with a leading `@`.

## Full-changelog links

**Blob link** points at the `CHANGELOG.md` section for this exact version, pinned to the tag:

```
https://github.com/{owner}/{repo}/blob/v{target}/CHANGELOG.md#{anchor}
```

Compute `{anchor}` from the heading text `v{target}`: lowercase it, then delete every character that is not `a-z`, `0-9`, or `-`. Dots are deleted. Examples: `v2.4.0` → `v240`; `v3.0.0` → `v300`; `v2.10.1` → `v2101`.

**Compare link** is GitHub's standard range link from the previous release tag to this one:

```
https://github.com/{owner}/{repo}/compare/{prev tag}...v{target}
```

`{owner}/{repo}` comes from `gh repo view --json nameWithOwner`. `{prev tag}` is the previous released tag (for example `v2.3.0`). Omit the compare link entirely when there is no previous tag.

## Publish vs. draft, and idempotency

- **Publish (default):** `gh release create v{target} --title "v{target}" --latest --notes-file {file}`.
- **Draft (only when explicitly requested):** add `--draft`. Do not pass `--latest` with `--draft`.
- **Release already exists for the tag:** do not create a second one. Update it in place with `gh release edit v{target} --notes-file {file}` (add `--draft=false` only if the operator asked to publish an existing draft). Report that the release was updated rather than created.

Write the assembled body to a temp file with the Write tool and pass it via `--notes-file`. Do not build the body with shell `echo`/`printf`.
