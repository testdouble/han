# CHANGELOG.md rules

`CHANGELOG.md` lives at the repository root. The title line is `# Han Release Notes`. Each version is a top-level section that starts with `## v{parent target}` (newest first, directly under the title), where `parent target` is the version of the parent `han` plugin (the version the git tag tracks).

## Per-plugin structure (from v3.0.0 onward)

Han ships as a parent meta-plugin (`han`) plus child plugins (`han.core`, `han.github`, `han.reporting`, and any future `han.*` extension). Each plugin carries its own version. The changelog mirrors that: every change is attributed to the plugin whose directory it touched, never grouped together across plugins.

A release section is laid out as:

```
## v{parent target}

{one-paragraph plain-language summary of the release. It names the parent's
 new version and lists every changed or new child with its version, for
 example: "han 3.1.0 ships a new GitHub skill (han.github 1.1.0) and a fix to
 the code-review roster (han.core 1.0.1)." han.reporting is unchanged.}

### han v{parent target}

{the suite-level / parent narrative: the restructure itself, repo-root docs,
 marketplace and meta-plugin changes. Use #### topic subsections when there is
 more than one distinct thread.}

### han.core v{version}

{only han.core's changes. #### topic subsections as needed.}

### han.github v{version}

{only han.github's changes.}

### Deferred (YAGNI)

{release-level; only when work was deliberately cut. Optional.}

### Issues closed in this release

- {issue title} (#{issue number}) — opened by [@{opener}](https://github.com/{opener}); fixed in #{PR number} by [@{worker}](https://github.com/{worker}); thanks to [@{contributor}](https://github.com/{contributor})

### Pull requests in this release

- {PR title} (#{number}) — [@{author login}](https://github.com/{author login})

Full changelog: {blob link — see release-notes-format.md}
```

Rules for the per-plugin sub-headings:

- **One `### {plugin name} v{version}` sub-heading per plugin that changed.** The parent (`### han v{parent target}`) always appears, because the parent always bumps. A child appears only when it changed in this release, or when it is newly introduced.
- **A newly introduced child** gets a sub-heading marked as new, for example `### han.reporting v1.0.0 (new)`, describing what the plugin is and what it ships at introduction. Its version is the established baseline and does not increment for the release that introduces it.
- **An unchanged child is omitted entirely.** No empty sub-heading.
- **Topic detail within a plugin uses `####`.** Reserve `###` for plugin sub-headings and the two release-level bookkeeping subsections (`### Deferred (YAGNI)`, `### Pull requests in this release`).
- **Attribute by directory.** A change to a file under `han.github/` belongs in the `### han.github` section. Repo-root changes that live outside any plugin directory (`docs/`, `README.md`, `CONTRIBUTING.md`) are suite-level and belong in the `### han` section.

Releases before `v3.0.0` predate the split and use the older flat layout (descriptive `###` topic subsections directly under `## v{X.Y.Z}`). Leave those historical sections exactly as they are.

## Augment vs. generate

Decide by whether a `## v{parent target}` section already exists:

- **Section exists — augment, do not rewrite.** The curated prose is the source of truth. Leave every existing line of that section untouched. Append a single new bookkeeping subsection (see "Generated bookkeeping subsection" below) as the **last** `###` subsection of that version's section, immediately before the next `## v` heading (or end of file).

- **Section missing — generate it, then append the subsection.** Dispatch one agent to write the narrative section (summary paragraph + per-plugin `### {plugin} v{version}` sub-headings + a release-level `### Deferred (YAGNI)` subsection when applicable) in the register described below. Insert the new `## v{parent target}` section directly under the `# Han Release Notes` title, above the previous newest entry. Then append the generated bookkeeping subsection as its last `###` subsection.

Never delete or reorder existing version sections. Never edit a version section other than `## v{parent target}`.

## Linked mentions

Every `@mention` of a person anywhere in a changelog section — narrative prose, the issues subsection, the pull-requests subsection — is a markdown link to that person's GitHub profile, never flat text:

```
[@{login}](https://github.com/{login})
```

GitHub does not auto-link `@username` in a rendered `CHANGELOG.md` blob, so the explicit link is what makes the mention clickable and unambiguous. (The GitHub release body is different: GitHub auto-links bare `@username` there, so the body keeps the bare form. See [release-notes-format.md](./release-notes-format.md).)

## Generated bookkeeping subsections

Append these subsections at the end of the `## v{parent target}` section, in this order: the issues subsection first (when there are closed issues), then the pull-requests subsection. The `Full changelog:` line closes the last subsection.

### Issues closed in this release

Include this subsection only when one or more issues were closed by the release's PRs (`$issue_list` non-empty). Omit it entirely otherwise. One bullet per closed issue, relating the issue to the fix that resolved it and crediting everyone involved:

```
- {issue title} (#{issue number}) — opened by [@{opener}](https://github.com/{opener}); fixed in #{PR number} by [@{worker}](https://github.com/{worker}), [@{worker}](https://github.com/{worker}); thanks to [@{contributor}](https://github.com/{contributor})
```

- **opened by** — the person who opened the issue (one mention).
- **fixed in** — the PR(s) that closed the issue, and the people who worked on that PR (author, reviewers, and commit/co-authors), each linked. When more than one PR closed the issue, list each `#{number}` with its workers.
- **thanks to** — the people who contributed meaningfully to the issue: those who left a **substantive** comment. Reactions never count (a 👍 is not a comment) and neither do drive-by comments (a bare `+1`, `bump`, `thanks`, `any update?`, an emoji-only reply, or a short acknowledgment that adds no detail). The opener and the PR workers are removed so each person is credited once. Omit the whole `; thanks to ...` clause when that set is empty.

Exclude bot accounts (`is_bot`, plus the `web-flow`, `github-actions`, and `dependabot` logins) from every list.

### Pull requests in this release

One bullet per merged pull request included in this release, newest merge last, in the exact form:

```
- {PR title} (#{number}) — [@{author login}](https://github.com/{author login})
```

The PR list is repo-wide and appears once per release. It is not split per plugin; per-plugin attribution lives in the narrative sub-headings above it.

When no merged pull requests are found between the previous release and `HEAD` (local-only commits, squash history without PR refs), use this heading and body instead:

```
### Commits in this release

- {commit subject} ({short sha})
```

This is the changelog form of the no-PR fallback. The GitHub release body uses a different, single-line form for the same case (see [release-notes-format.md](./release-notes-format.md)). The changelog enumerates each commit; the body summarizes.

Close the last bookkeeping subsection with one final line:

```
Full changelog: {compare-or-blob link — see release-notes-format.md}
```

## Register and voice for a generated narrative section

Match the register of the existing `## v{X.Y.Z}` entries already in `CHANGELOG.md`: neutral, descriptive, technical present tense ("The `/gap-analysis` swarm flips from opt-in to opt-out..."). This is **not** the first-person blog voice; it is the clipped changelog register those entries already use. The two newest existing sections are pasted into the dispatch prompt as the register model — follow them.

Hard constraints from [`docs/writing-voice.md`](../../../../docs/writing-voice.md), applied verbatim to generated changelog prose:

- No em-dash (`—`) anywhere, ever. Use a colon, comma, parentheses, or two sentences.
- `use`, never `leverage` or `utilize`.
- No `just`, no `actually`.
- None of: "It's worth noting", "Importantly", "delve", "foster", "synergy", "underscore", "pivotal", "showcase", "robust" (as a vague positive), "paradigm shift", "game changer", "Let's dive in", "deep dive".
- Name skills, agents, files, and flags specifically (`/tdd`, `han.core/skills/code-review/SKILL.md`), never generically.
- Reference internal paths with backticks. State what changed plainly; do not hedge with "arguably" or "one might say".
- Every `@mention` of a person is a profile link `[@{login}](https://github.com/{login})`, never flat text (see "Linked mentions" above).

The narrative describes what changed and why from the operator's point of view, not a file-by-file diff. Code structure can be summarized; behavior changes (new skills, renamed skills, changed defaults, changed dispatch) must be stated explicitly, under the plugin that owns them.
