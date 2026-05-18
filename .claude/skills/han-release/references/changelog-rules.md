# CHANGELOG.md rules

`CHANGELOG.md` lives at the repository root. The title line is `# Han Release Notes`. Each version is a top-level section that starts with `## v{X.Y.Z}` (newest first, directly under the title), opens with a one-paragraph plain-language summary of the release, then groups the detail under descriptive `###` subsections (for example `### Calibration`, `### Context plumbing`, `### Documentation`), and ends with a `### Deferred (YAGNI)` subsection when work was deliberately cut.

## Augment vs. generate

Decide by whether a `## v{target}` section already exists:

- **Section exists — augment, do not rewrite.** The curated prose is the source of truth. Leave every existing line of that section untouched. Append a single new subsection (see "Generated subsection" below) as the **last** `###` subsection of that version's section — after `### Deferred (YAGNI)` if it is present, and immediately before the next `## v` heading (or end of file).

- **Section missing — generate it, then append the subsection.** Dispatch one agent to write the narrative section (summary paragraph + descriptive `###` subsections + a `### Deferred (YAGNI)` subsection when applicable) in the register described below. Insert the new `## v{target}` section directly under the `# Han Release Notes` title, above the previous newest entry. Then append the generated subsection as its last `###` subsection.

Never delete or reorder existing version sections. Never edit a version section other than `## v{target}`.

## Generated subsection

Heading: `### Pull requests in this release`

Body: one bullet per merged pull request included in this release, newest merge last, in the exact form:

```
- {PR title} (#{number}) — @{author login}
```

When no merged pull requests are found between the previous release and `HEAD` (local-only commits, squash history without PR refs), use this heading and body instead:

```
### Commits in this release

- {commit subject} ({short sha})
```

Close the subsection with one final line:

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
- Name skills, agents, files, and flags specifically (`/tdd`, `plugin/skills/code-review/SKILL.md`), never generically.
- Reference internal paths with backticks. State what changed plainly; do not hedge with "arguably" or "one might say".

The narrative describes what changed and why from the operator's point of view, not a file-by-file diff. Code structure can be summarized; behavior changes (new skills, renamed skills, changed defaults, changed dispatch) must be stated explicitly.
