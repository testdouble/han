---
name: update-pr-description
description: >
  Generate a PR description from the current branch's changes against a GitHub
  PR, using the gh CLI. Use when writing, drafting, or updating pull request
  descriptions, PR summaries, or PR bodies. Requires the gh CLI to be installed
  and a PR to already exist for the current branch. Does not review code or post
  review comments — use code-review for local review or post-code-review-to-pr for posting
  a review to GitHub.
argument-hint: [optional context about the PR]
allowed-tools: Read, Glob, Grep, Agent, Bash(git *), Bash(gh *)
---

## Pre-requisites

- gh CLI: !`which gh`

**If the gh CLI is not found:**
- Inform the user that it needs to be installed and configured before this skill can be used
- **Immediately stop** execution of this skill, as it cannot be executed

## Project Context

- current branch: !`git branch --show-current`
- default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD`
- branch summary: !`git log origin/HEAD..HEAD --oneline`
- branch stats: !`git diff origin/HEAD...HEAD --stat`
- branch changes: !`git diff origin/HEAD...HEAD`

## Step 1: Validate Branch State

Before generating a PR description, verify the branch has content to describe:

1. **If `default branch` is empty** — `origin/HEAD` is not set. Use `AskUserQuestion` to ask the user for the default branch name (e.g., `main`, `master`, `develop`). Use that branch as the base for all git commands in subsequent steps.

2. **If `branch summary` is empty** — there are no commits on this branch relative to the default branch. Inform the user and stop.

3. **If `branch stats` is empty** — there are no file changes despite having commits (e.g., empty commits or fully reverted changes). Inform the user and stop.

## Step 2: Analyze Changes

Review the branch diff, commits, and relevant source code to understand the PR. Identify the central mechanism — the primary purpose of the PR. If the PR is about feature flags, migrations, or behavioral changes, those ARE the point, not a side detail. Classify the change type (new feature, bug fix, refactoring, docs update, config change, etc.) and read related source files as needed to understand the full scope.

When applicable (do not force these into every PR), collect specific details: feature flag gate names/values/interactions, actual config values per environment, before/after behavioral changes, migration phases/rollback/data flow, and state machine combinations.

## Step 3: Determine "How this was tested" Applicability

Inspect the changed files from `branch stats` and classify each by extension. Documentation files: `.md`, `.txt`, `.rst`, `.adoc`, `.rdoc`, `.textile`, `.wiki`, `.org`, `.asciidoc`, `.creole`, `.pod`, `.mediawiki`. Everything else is a code or configuration file. If ALL changed files are documentation → omit the "How this was tested" section. If ANY changed file is code or configuration → include the "How this was tested" section.

## Step 4: Generate the PR Description

Launch a single `junior-developer` agent to write the PR description directly. Junior-developer's fresh-reviewer perspective is the asset here: by authoring the description with the eyes of a teammate who lacks full project context, the result already anticipates what a reviewer needs to see, removing the need for a separate reviewer-context edit pass.

Construct the agent prompt to include all of the following inline (the skill already has this context loaded — pass the actual values, not references):

- **Branch context** — the values of `current branch`, `default branch`, `branch summary`, `branch stats`, and `branch changes` from the Project Context section.
- **"How this was tested" inclusion decision from Step 3** — either "Include the How this was tested section" or "Omit the How this was tested section entirely (documentation-only PR)".
- **Template** — paste the contents of [template.md](references/template.md) into the prompt so the agent does not need to read it.
- **Formatting rules** — paste the contents of [formatting-rules.md](references/formatting-rules.md) into the prompt so the agent does not need to read it.

Use this prompt body (with the context above interpolated):

> "Author the pull-request description for this branch. This task repurposes your fresh-reviewer perspective for writing instead of reviewing: the audience is another human teammate reviewing on GitHub without full project context. Your job is to give them a behavioral mental model in roughly thirty seconds of scanning, then point them at where the interesting decisions live. Lead with plain human language about behavior and feature changes — not file-list mechanics. Do not produce a review report, question log, or findings — produce only the final PR description in markdown.
>
> **Section order (required):** Summary (with `### Behavior changes` subsection when applicable) → What to look at first → How this was tested (only when included per the inclusion decision below) → Files of interest → Test scenario changes (only if tests were added or edited).
>
> **Summary section rules:**
> - The first line under `## Summary` MUST be a single bolded TL;DR sentence in the form `**This PR <verb> <behavior>, so that <why>.**` — fill it before drafting anything else.
> - Follow the TL;DR with 2-4 bullets covering user-visible or runtime behavior, scope, and reviewer-attention pointers. Do not list files in the Summary.
> - Include a `### Behavior changes` subsection only when runtime behavior changes (flag flips, migrations, state-machine edits, config changes, API contract changes). Omit the subsection entirely for pure refactors and docs-only PRs. Use it for plain-language before/after narration; render flag/state interactions as a small table when multiple flags or modes interact.
>
> **Content rules across all sections:**
> - Identify the central mechanism (feature flags, migrations, behavioral changes) from the diff and commits before drafting, and put it in the bolded TL;DR sentence.
> - Include specific configuration values (environment settings, flag combinations, thresholds, defaults) — not "added config for X."
> - Never over-summarize behavioral changes — code structure can be summarized, but runtime behavior cannot. Include per-environment values, migration phases, and flag enabled/disabled behavior.
> - Explain how components work together, not just what each one does.
> - Only describe changes unique to the PR branch — never include changes merged from the default branch.
> - Do not rely on internal flag names, service names, or acronyms without a brief inline definition on first use.
> - "What to look at first" is a 2-4 bullet attention guide pointing at decisions, tradeoffs, or risks — it is NOT a file list. The file list lives in "Files of interest" below.
> - "How this was tested" uses past-tense author-self-check items prefixed with `- ✅` describing scenarios the author already verified. Do not use unchecked `[ ]` boxes. Items must be verifiable from the PR alone.
>
> **Files of interest rules:** This section is a bulleted list of at most 5 entries — never a table, never more than 5. Each entry is `` `path` — one phrase about why this file matters for review ``. Skip generated files, mechanical refactors, trivial changes (imports, typos), and test helpers unless central. Do not add a "+N more files" continuation row — GitHub's Files Changed tab is one click away. Apply the truncation rules from the formatting rules below to paths longer than 50 characters.
>
> **Test scenario changes rules:** Behavioral scenarios only, in plain language. Do not include file paths in this section — test files (when central) appear in "Files of interest."
>
> **Formatting:** Never nest fenced code blocks inside the PR description — use inline backticks for short references, indented 4-space blocks for short snippets, prose descriptions, or small tables instead. Use `##`/`###` headers for sections. Do not leave HTML comments or template placeholder braces in the rendered output. Never include any form of 'Generated with Claude Code.'
>
> **Test Plan inclusion decision (controls the "How this was tested" section):** {value from Step 3 — "Include the How this was tested section" or "Omit the How this was tested section entirely (documentation-only PR)"}
>
> **Branch context:**
> - Current branch: {current branch}
> - Default branch: {default branch}
> - Commits: {branch summary}
> - File stats: {branch stats}
> - Diff:
> {branch changes}
>
> **Template:**
> {contents of references/template.md}
>
> **Formatting rules:**
> {contents of references/formatting-rules.md}
>
> Read additional source files via your Read/Grep tools when the diff alone does not explain the change. Return only the final PR description text — no preamble, no review notes."

If the agent returns anything other than a PR description (a review report, question log, etc.), discard it and re-issue the prompt with an explicit reminder to return only the description text.

## Step 5: Verify the PR Description

Before displaying the PR description, read it back and confirm:

1. The first line under `## Summary` is a single bolded TL;DR sentence leading with behavior. No file lists in the Summary.
2. Sections appear in the required order: Summary (with `### Behavior changes` subsection when applicable) → What to look at first → How this was tested (when included) → Files of interest → Test scenario changes (when included). "How this was tested" inclusion/omission matches Step 3.
3. "Files of interest" is a bulleted list with 5 or fewer entries — never a table, no "+N more files" continuation row. Paths >50 chars are truncated per the formatting rules.
4. "What to look at first" is an attention guide of 2-4 bullets pointing at decisions or risks — not a file list.
5. "How this was tested" items use past-tense `- ✅` markers (not unchecked `[ ]` boxes). "Test scenario changes" contains behavioral scenarios in plain language with no file paths.
6. Valid markdown, no nested fenced code blocks, no leftover HTML comments or template placeholder braces (`{...}`), no "Generated with Claude Code."
7. Only branch-specific changes described.
8. Fix any issues directly before proceeding to Step 6.

## Step 6: Display and Update PR

1. **Display the PR description** — Show the full result to the user, parsed and formatted for display.

2. **Check for an existing PR** on the current branch by running `gh pr view --json number,url`. If this fails or returns nothing, the branch has no PR — the task is complete. Stop.

3. **If a PR exists:** Use `AskUserQuestion` to ask whether to update the PR description on GitHub, with options "Yes, update it" and "No, just the markdown is fine". If the user declines, stop. If accepted, update the PR on GitHub by running `gh pr edit --body {pr_description_content}` passing the full PR description as the body argument. Report the PR URL when done.
