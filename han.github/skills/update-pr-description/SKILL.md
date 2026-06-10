---
name: update-pr-description
description: >
  Generate a PR description from the current branch's changes against a GitHub PR, using the gh
  CLI. Use when writing, drafting, or updating pull request descriptions, PR summaries, or PR
  bodies. Does not review code or post review comments — use code-review for local review or
  post-code-review-to-pr for posting a review to GitHub.
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

## Step 2: Discover the Repository PR Template

Determine whether the repository defines its own GitHub pull-request template. If it does, the generated description must conform to that template's structure (Step 5). Do not assume any particular template shape — discover it, read it, and let its structure drive the output.

Use the `Glob` tool to look in GitHub's supported template locations. GitHub matches the filename case-insensitively; check both common casings since the working filesystem may be case-sensitive. Search these paths (most templates are `.md`; `.txt` is also valid):

- Root of the repo: `pull_request_template.md`, `PULL_REQUEST_TEMPLATE.md` (and the `.txt` variants).
- The `.github/` directory: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md` (and `.txt`).
- The `docs/` directory: `docs/pull_request_template.md`, `docs/PULL_REQUEST_TEMPLATE.md` (and `.txt`).
- A multiple-template subdirectory: `.github/PULL_REQUEST_TEMPLATE/*.md`, `docs/PULL_REQUEST_TEMPLATE/*.md`, `PULL_REQUEST_TEMPLATE/*.md`.

Then resolve to a single template (or none):

1. **No template file found** — the repository has no PR template. Record "no repository template" and continue. Step 5 uses the default structure.
2. **Exactly one single-file template found** — `Read` it in full, including HTML comments. Record its path and full contents.
3. **A `PULL_REQUEST_TEMPLATE/` directory with multiple templates** — GitHub selects one per PR and the skill cannot know which applies. Use `AskUserQuestion` to ask which template to conform to, listing the filenames plus a "None — use the default structure" option. `Read` the chosen file in full and record its path and contents. If the user picks "None," record "no repository template."

Carry the recorded result (the template path and full contents, or "no repository template") into Step 5. Preserve the template's HTML comments verbatim in what you carry forward — they often state how the template is meant to be used.

## Step 3: Analyze Changes

Review the branch diff, commits, and relevant source code to understand the PR. Identify the central mechanism — the primary purpose of the PR. If the PR is about feature flags, migrations, or behavioral changes, those ARE the point, not a side detail. Classify the change type (new feature, bug fix, refactoring, docs update, config change, etc.) and read related source files as needed to understand the full scope.

When applicable (do not force these into every PR), collect specific details: feature flag gate names/values/interactions, actual config values per environment, before/after behavioral changes, migration phases/rollback/data flow, and state machine combinations.

## Step 4: Determine "How this was tested" Applicability

Inspect the changed files from `branch stats` and classify each by extension. Documentation files: `.md`, `.txt`, `.rst`, `.adoc`, `.rdoc`, `.textile`, `.wiki`, `.org`, `.asciidoc`, `.creole`, `.pod`, `.mediawiki`. Everything else is a code or configuration file. If ALL changed files are documentation → omit the "How this was tested" section. If ANY changed file is code or configuration → include the "How this was tested" section.

## Step 5: Generate the PR Description

Launch a single `han.core:junior-developer` agent to write the PR description directly. Junior-developer's fresh-reviewer perspective is the asset here: by authoring the description with the eyes of a teammate who lacks full project context, the result already anticipates what a reviewer needs to see, removing the need for a separate reviewer-context edit pass.

First, compose the **structure directive** based on the Step 2 result. The structure directive is the only part of the prompt that differs between the two cases; everything else is shared.

- **Option A — no repository template** (Step 2 recorded "no repository template"). The structure directive is:
  > **Structure (required):** Produce the description using this fixed structure and section order: Summary (with a `### Behavior changes` subsection only when runtime behavior changes) → What to look at first → How this was tested (only when included per the inclusion decision) → Files of interest → Test scenario changes (only if tests were added or edited). The first line under `## Summary` MUST be the bolded TL;DR sentence, before anything else is drafted. Include the `### Behavior changes` subsection only when runtime behavior changes (flag flips, migrations, state-machine edits, config changes, API contract changes); omit it for pure refactors and docs-only PRs; render interacting flags or modes as a small table.
  >
  > Default template to follow:
  > {paste the contents of [template.md](./references/template.md)}

- **Option B — a repository template was found** (Step 2 recorded a template path and contents). The structure directive is:
  > **Structure (required):** Conform to the repository's pull-request template, reproduced below, following the conformance rules exactly. The template's headings and their order are authoritative.
  >
  > Conformance rules:
  > {paste the contents of [template-conformance.md](./references/template-conformance.md)}
  >
  > Repository PR template ({template path from Step 2}):
  > {paste the full contents of the discovered template, including its HTML comments}

Then construct the agent prompt to include all of the following inline (the skill already has this context loaded — pass the actual values, not references):

- **Branch context** — the values of `current branch`, `default branch`, `branch summary`, `branch stats`, and `branch changes` from the Project Context section.
- **"How this was tested" inclusion decision from Step 4** — either "Include the How this was tested section" or "Omit the How this was tested section entirely (documentation-only PR)".
- **Structure directive** — Option A or Option B as composed above.
- **Formatting rules** — paste the contents of [formatting-rules.md](./references/formatting-rules.md) into the prompt so the agent does not need to read it.

Use this prompt body (with the context above interpolated):

> "Author the pull-request description for this branch. This task repurposes your fresh-reviewer perspective for writing instead of reviewing: the audience is another human teammate reviewing on GitHub without full project context. Your job is to give them a behavioral mental model in roughly thirty seconds of scanning, then point them at where the interesting decisions live. Lead with plain human language about behavior and feature changes — not file-list mechanics. Do not produce a review report, question log, or findings — produce only the final PR description in markdown.
>
> Follow the structure directive below for how the description is organized and laid out. Follow the content rules below for what goes in it. When the structure directive provides a repository template, the template's structure wins over the default section names referenced in the content rules; map the content into the template's sections per the conformance rules.
>
> **Content rules across all sections:**
> - Lead the primary summary or description section with a single bolded TL;DR sentence in the form `**This PR <verb> <behavior>, so that <why>.**` — fill it before drafting anything else.
> - Follow the TL;DR with 2-4 bullets covering user-visible or runtime behavior, scope, and reviewer-attention pointers. Do not list files in the summary.
> - Identify the central mechanism (feature flags, migrations, behavioral changes) from the diff and commits before drafting, and put it in the bolded TL;DR sentence.
> - Include specific configuration values (environment settings, flag combinations, thresholds, defaults) — not "added config for X."
> - Never over-summarize behavioral changes — code structure can be summarized, but runtime behavior cannot. Include per-environment values, migration phases, and flag enabled/disabled behavior.
> - Explain how components work together, not just what each one does.
> - Only describe changes unique to the PR branch — never include changes merged from the default branch.
> - Do not rely on internal flag names, service names, or acronyms without a brief inline definition on first use.
> - "What to look at first" is a 2-4 bullet attention guide pointing at decisions, tradeoffs, or risks — it is NOT a file list. The file list lives in "Files of interest."
> - "How this was tested" uses past-tense author-self-check items prefixed with `- ✅` describing scenarios the author already verified. Do not use unchecked `[ ]` boxes for these. Items must be verifiable from the PR alone.
>
> **Files of interest rules:** This section is a bulleted list of at most 5 entries — never a table, never more than 5. Each entry is `` `path` — one phrase about why this file matters for review ``. Skip generated files, mechanical refactors, trivial changes (imports, typos), and test helpers unless central. Do not add a "+N more files" continuation row — GitHub's Files Changed tab is one click away. Apply the truncation rules from the formatting rules below to paths longer than 50 characters.
>
> **Test scenario changes rules:** Behavioral scenarios only, in plain language. Do not include file paths in this section — test files (when central) appear in "Files of interest."
>
> **Formatting:** Never nest fenced code blocks inside the PR description — use inline backticks for short references, indented 4-space blocks for short snippets, prose descriptions, or small tables instead. Use `##`/`###` headers for sections. Do not leave authoring-instruction HTML comments or template placeholder braces in the rendered output. Never include any form of 'Generated with Claude Code.'
>
> **Test Plan inclusion decision (controls the "How this was tested" section):** {value from Step 4 — "Include the How this was tested section" or "Omit the How this was tested section entirely (documentation-only PR)"}
>
> **Structure directive:** {Option A or Option B from above}
>
> **Branch context:**
> - Current branch: {current branch}
> - Default branch: {default branch}
> - Commits: {branch summary}
> - File stats: {branch stats}
> - Diff:
> {branch changes}
>
> **Formatting rules:**
> {contents of references/formatting-rules.md}
>
> Read additional source files via your Read/Grep tools when the diff alone does not explain the change. Return only the final PR description text — no preamble, no review notes."

If the agent returns anything other than a PR description (a review report, question log, etc.), discard it and re-issue the prompt with an explicit reminder to return only the description text.

## Step 6: Verify the PR Description

Before displaying the PR description, read it back and confirm. Use the checklist that matches the Step 2 result.

**Always confirm (both cases):**

1. The primary summary or description section opens with a single bolded TL;DR sentence leading with behavior. No file lists in that section.
2. "Files of interest" (wherever it lands) is a bulleted list with 5 or fewer entries — never a table, no "+N more files" continuation row. Paths >50 chars are truncated per the formatting rules.
3. "What to look at first" is an attention guide of 2-4 bullets pointing at decisions or risks — not a file list.
4. "How this was tested" inclusion/omission matches Step 4. When included, its items use past-tense `- ✅` markers. "Test scenario changes" contains behavioral scenarios in plain language with no file paths.
5. Valid markdown, no nested fenced code blocks, no leftover authoring-instruction HTML comments or template placeholder braces (`{...}`), no "Generated with Claude Code."
6. Only branch-specific changes described.

**When Step 2 recorded "no repository template" (Option A), also confirm:** the sections appear in the fixed order — Summary (with `### Behavior changes` subsection when applicable) → What to look at first → How this was tested (when included) → Files of interest → Test scenario changes (when included).

**When Step 2 found a repository template (Option B), also confirm:** unless the template was a replace-scaffold per the conformance rules, every heading the template defines is present and in the template's original order; "What to look at first" and "Files of interest" appear only as appended sections after the template's sections (or filled into an equivalent the template already had), never interleaved out of order; the template's checklists are reproduced verbatim with only diff-provable boxes checked and no fabricated attestations; the template's instructional comments and placeholder prompts are stripped from the output.

Fix any issues directly before proceeding to Step 7.

## Step 7: Display and Update PR

1. **Display the PR description** — Show the full result to the user, parsed and formatted for display.

2. **Check for an existing PR** on the current branch by running `gh pr view --json number,url`. If this fails or returns nothing, the branch has no PR — the task is complete. Stop.

3. **If a PR exists:** Use `AskUserQuestion` to ask whether to update the PR description on GitHub, with options "Yes, update it" and "No, just the markdown is fine". If the user declines, stop. If accepted, update the PR on GitHub by running `gh pr edit --body {pr_description_content}` passing the full PR description as the body argument. Report the PR URL when done.
