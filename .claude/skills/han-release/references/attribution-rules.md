# Release Attribution Rules

This file defines how a release run credits the people behind every closed issue in the range. It is loaded by
`SKILL.md` Step 2.6, which finds the issues each merged PR closed and builds `$issue_list` from them.

Work one merged PR at a time and relate each closed issue to the fix that resolved it.

## Find the closed issues for the PR

Take the issue numbers from
`gh pr view N --json closingIssuesReferences --jq '[.closingIssuesReferences[]?.number]'` (the GitHub-tracked
closing links). As a fallback for older PRs that linked via text, also scan the PR body and commit messages for
GitHub closing keywords: `gh pr view N --json body,commits --jq '[.body, (.commits[].messageBody)] | join("\n")'`
and extract `#<num>` that follow `close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, or
`resolved` (case-insensitive). Union the two sets, dedupe.

## Confirm each is a closed issue

For each candidate number `I`, run
`gh issue view I --json number,title,author,state,comments` (suppress stderr; redirect `2>/dev/null`). Skip the
number if the command fails (it is a PR number, not an issue, or does not exist).

## Gather attribution per issue

Record:

- **opener** — `.author.login`, unless `.author.is_bot` is true.
- **issue contributors** (people who contributed meaningfully) — the people who left a **substantive** comment on
  the issue. A reaction is not a comment (a 👍 or other emoji reaction never appears in `.comments[]`), so
  reaction-only participants are already excluded. Drive-by comments do not count either. Pull each comment with
  its author and body
  (`gh issue view I --json comments --jq '.comments[] | select(.author.is_bot|not) | {login: .author.login, body: .body}'`,
  stderr suppressed), and treat a comment as a drive-by when its trimmed body is emoji-only, or is a brief
  acknowledgment or status ping (for example `+1`, `same`, `me too`, `bump`, `following`, `thanks`,
  `any update(s)?`), or is shorter than roughly 15 words and adds no detail. A person qualifies only when at least
  one of their comments is substantive (not a drive-by). Remove the opener and the PR workers so each person is
  credited once. May be empty.
- **PR workers** — for the closing PR `N`, the union of the PR author, the review authors, and the commit authors:
  `gh pr view N --json author,reviews,commits --jq '[.author.login] + [.reviews[]?.author.login] + [.commits[].authors[].login] | unique'`.
  Drop bot accounts (`is_bot` where available, plus the `web-flow`, `github-actions`, and `dependabot` logins).

## Build `$issue_list`

One entry per closed issue: its number, title, opener, contributors, the closing PR
number(s), and the merged PR workers. If the same issue is closed by more than one PR in the range, record every
closing PR and merge their worker sets. Build the changelog bullets and release-body lines per
[changelog-rules.md](./changelog-rules.md) and
[release-notes-format.md](./release-notes-format.md). If no closed issues are found,
`$issue_list` is empty and the issues subsection/section is omitted everywhere.
