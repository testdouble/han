---
name: update-pr-description
description: >
  Generate a PR description from the current branch's changes against a GitHub PR, using the gh CLI. Use when writing,
  drafting, or updating pull request descriptions, PR summaries, or PR bodies. Does not review code or post review
  comments — use code-review for local review or post-code-review-to-pr for posting a review to GitHub.
argument-hint: "[optional context about the PR]"
allowed-tools: Read, Glob, Grep, Agent, Bash(git *), Bash(gh *)
---

## Pre-requisites

- gh CLI: !`which gh 2>/dev/null || echo "not installed"`

**If the gh CLI is not found:**

- Inform the user that it needs to be installed and configured before this skill can be used
- **Immediately stop** execution of this skill, as it cannot be executed

## Project Context

- current branch: !`git branch --show-current 2>/dev/null || echo unknown`
- default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo unknown`
- branch summary: !`git log origin/HEAD..HEAD --oneline 2>/dev/null || echo unknown`
- branch stats: !`git diff origin/HEAD...HEAD --stat 2>/dev/null || echo unknown`
- branch changes: !`git diff origin/HEAD...HEAD 2>/dev/null || echo unknown`

## Step 1: Validate Branch State

Before generating a PR description, verify the branch has content to describe:

1. **If `default branch` is empty or `unknown`** — `origin/HEAD` is not set. Use `AskUserQuestion` to ask the user for
   the default branch name (e.g., `main`, `master`, `develop`). Use that branch as the base for all git commands in
   subsequent steps, and recompute `branch summary`, `branch stats`, and `branch changes` against it — their Project
   Context values may read `unknown` because they were derived from the unset `origin/HEAD`.

2. **If `branch summary` is empty** — there are no commits on this branch relative to the default branch. Inform the
   user and stop.

3. **If `branch stats` is empty** — there are no file changes despite having commits (e.g., empty commits or fully
   reverted changes). Inform the user and stop.

## Step 2: Discover the Repository PR Template

Determine whether the repository defines its own GitHub pull-request template. If it does, the generated description
must conform to that template's structure (Step 4). Do not assume any particular template shape — discover it, read it,
and let its structure drive the output.

Use the `Glob` tool to look in GitHub's supported template locations. GitHub matches the filename case-insensitively;
check both common casings since the working filesystem may be case-sensitive. Search these paths (most templates are
`.md`; `.txt` is also valid):

- Root of the repo: `pull_request_template.md`, `PULL_REQUEST_TEMPLATE.md` (and the `.txt` variants).
- The `.github/` directory: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md` (and `.txt`).
- The `docs/` directory: `docs/pull_request_template.md`, `docs/PULL_REQUEST_TEMPLATE.md` (and `.txt`).
- A multiple-template subdirectory: `.github/PULL_REQUEST_TEMPLATE/*.md`, `docs/PULL_REQUEST_TEMPLATE/*.md`,
  `PULL_REQUEST_TEMPLATE/*.md`.

Then resolve to a single template (or none):

1. **No template file found** — the repository has no PR template. Record "no repository template" and continue. Step 4
   uses the default structure.
2. **Exactly one single-file template found** — `Read` it in full, including HTML comments. Record its path and full
   contents.
3. **A `PULL_REQUEST_TEMPLATE/` directory with multiple templates** — GitHub selects one per PR and the skill cannot
   know which applies. Use `AskUserQuestion` to ask which template to conform to, listing the filenames plus a "None —
   use the default structure" option. `Read` the chosen file in full and record its path and contents. If the user picks
   "None," record "no repository template."

Carry the recorded result (the template path and full contents, or "no repository template") into Step 4. Preserve the
template's HTML comments verbatim in what you carry forward — they often state how the template is meant to be used.

## Step 3: Analyze Changes

Review the branch diff, commits, and relevant source code to understand the PR. Identify the central mechanism — the
primary purpose of the PR. If the PR is about feature flags, migrations, or behavioral changes, those ARE the point, not
a side detail. Classify the change type (new feature, bug fix, refactoring, docs update, config change, etc.) and read
related source files as needed to understand the full scope.

Find the headline behavioral effect — what changes for a user or caller and why — and the central mechanism's key facts
(a flag and its default, a migration's direction, the new vs. old behavior). Do not catalog every config value, phase,
or mode; the diff carries the specifics. The goal is a short description, not an exhaustive one.

While analyzing, count the **significant** changed files from `branch stats`, since that count gates the "What to look
at first" section in Step 4. "Significant" means code files. Documentation and configuration files do not count as
significant by default; one counts only when there is explicit justification for how it changes the behavior of the code
changes in the PR.

## Step 4: Generate the PR Description

Launch a single `han-core:junior-developer` agent to write the PR description directly. Junior-developer's
fresh-reviewer perspective is the asset here: by authoring the description with the eyes of a teammate who lacks full
project context, the result already anticipates what a reviewer needs to see, removing the need for a separate
reviewer-context edit pass.

This skill sources the standard by invoking `han-communication:readability-guidance` and applies it as it writes the PR
description, holding a named audience above the default: the reviewer evaluating the pull request, who will read the
code. Scope that frame per section so the technical specifics a reviewer needs — a flag and its default, a migration's
direction, the new vs. old behavior — are preserved rather than simplified away.

First, compose the **structure directive** based on the Step 2 result. The structure directive is the only part of the
prompt that differs between the two cases; everything else is shared.

- **Option A — no repository template** (Step 2 recorded "no repository template"). The structure directive is:

  > **Structure (required):** Produce the description using this fixed structure and section order: Summary (the bolded
  > TL;DR sentence only) → Behavior changes (its own `##` section, present only when runtime behavior changes; omit for
  > pure refactors and docs-only PRs) → What to look at first (only when the PR has more than ~8-10 files with
  > significant changes; see the threshold rule below). The first line under `## Summary` MUST be the bolded TL;DR
  > sentence, and the Summary section contains nothing else — no bullet list, no file mentions. Include the
  > `## Behavior changes` section only when runtime behavior changes (flag flips, migrations, state-machine edits,
  > config changes, API contract changes); omit it for pure refactors and docs-only PRs.
  >
  > **Length (required):** The whole description is at most 2-5 short paragraphs (the Summary sentence is one of them),
  > and Behavior changes is 1-3 short paragraphs. A small table is fine only when several flags or modes genuinely
  > interact; prefer prose otherwise.
  >
  > **"What to look at first" inclusion rule:** Include "What to look at first" only when the PR has more than ~8-10
  > files with _significant_ changes. "Significant" means code files. Documentation and configuration files do **not**
  > count as significant by default. A docs or config file counts as significant only when there is explicit
  > justification for how that change affects the _behavior_ of the code changes in the PR — and even when a docs/config
  > file is deemed significant, it most likely should **not** be listed in "What to look at first" itself. When the
  > count of significant (code) files is at or below ~8-10, **omit "What to look at first" entirely**, heading included.
  > Only include it when a large code change genuinely needs a reading-order guide.
  >
  > Default template to follow: {paste the contents of [template.md](./references/template.md)}

- **Option B — a repository template was found** (Step 2 recorded a template path and contents). The structure directive
  is:
  > **Structure (required):** Conform to the repository's pull-request template, reproduced below, following the
  > conformance rules exactly. The template's headings and their order are authoritative.
  >
  > Conformance rules: {paste the contents of [template-conformance.md](./references/template-conformance.md)}
  >
  > Repository PR template ({template path from Step 2}): {paste the full contents of the discovered template, including
  > its HTML comments}

Then construct the agent prompt to include all of the following inline (the skill already has this context loaded — pass
the actual values, not references):

- **Branch context** — the values of `current branch`, `default branch`, `branch summary`, `branch stats`, and
  `branch changes` from the Project Context section.
- **Structure directive** — Option A or Option B as composed above.

Use this prompt body (with the context above interpolated):

> "Author the pull-request description for this branch. This task repurposes your fresh-reviewer perspective for writing
> instead of reviewing: the audience is another human teammate reviewing on GitHub without full project context. Your
> job is to give them a behavioral mental model in roughly thirty seconds of scanning, then point them at where the
> interesting decisions live. Lead with plain human language about behavior and feature changes — not file-list
> mechanics. Do not produce a review report, question log, or findings — produce only the final PR description in
> markdown.
>
> Follow the structure directive below for how the description is organized and laid out. Follow the content rules below
> for what goes in it. When the structure directive provides a repository template, the template's structure wins over
> the default section names referenced in the content rules; map the content into the template's sections per the
> conformance rules.
>
> **Content rules across all sections:**
>
> - **Keep it short: the entire description is at most 2-5 short paragraphs** (the Summary sentence counts as one), and
>   Behavior changes is 1-3 short paragraphs. If you are writing more, you are adding detail a reviewer should read from
>   the diff, not the description.
> - Lead the primary summary or description section with a single bolded TL;DR sentence in the form
>   `**This PR <verb> <behavior>, so that <why>.**` — fill it before drafting anything else. Keep the Summary to that
>   one sentence: no bullet list, no file mentions.
> - Lead Behavior changes with the central mechanism (a feature flag, migration, or behavioral change) in plain
>   language: name it and its headline effect — a flag and its default, a migration's direction, the new vs. old
>   behavior. Do not enumerate every config value, phase, or mode; a reviewer reads the diff for specifics.
> - Stay at the altitude of behavior and intent, not implementation. Say what changes for a user or caller and why, not
>   how each file or function does it.
> - Only describe changes unique to the PR branch — never include changes merged from the default branch.
> - Define any internal flag, service, or acronym briefly on first use.
> - "What to look at first" is a 2-4 bullet reading-order guide for a large change, pointing at decisions, tradeoffs, or
>   risks in the order to read them — it is NOT a file list. Include it ONLY when the PR has more than ~8-10 files with
>   significant (code) changes per the inclusion rule in the structure directive; otherwise omit the section, heading
>   included.
> - **Readability:** Apply the shared readability standard sourced via `han-communication:readability-guidance`. Lead
>   each section with its main point, give sections descriptive headings, keep each paragraph to one idea carried by its
>   first sentence, number anything sequential and bullet anything that is not, and reveal detail in layers (progressive
>   disclosure). Do not simplify away a technical fact a reviewer needs, and do not disturb any required PR-template
>   section structure.
>
> **Formatting:** Never nest fenced code blocks inside the PR description — use inline backticks for short references,
> indented 4-space blocks for short snippets, prose descriptions, or small tables instead. Use `##`/`###` headers for
> sections. Do not leave authoring-instruction HTML comments or template placeholder braces in the rendered output.
> Never include any form of 'Generated with Claude Code.'
>
> **Structure directive:** {Option A or Option B from above}
>
> **Branch context:**
>
> - Current branch: {current branch}
> - Default branch: {default branch}
> - Commits: {branch summary}
> - File stats: {branch stats}
> - Diff: {branch changes}
>
> Read additional source files via your Read/Grep tools when the diff alone does not explain the change. Return only the
> final PR description text — no preamble, no review notes."

If the agent returns anything other than a PR description (a review report, question log, etc.), discard it and re-issue
the prompt with an explicit reminder to return only the description text.

Once the draft description exists, dispatch a single `han-communication:readability-editor` agent to audit and rewrite
it against the shared readability standard, operating on **prose regions only** — never inside code fences, table
markup, or any commit, PR, or issue reference identifier. Pass it the draft description text and the named audience: the
reviewer evaluating the pull request, who will read the code; the editor reads han-communication's own canonical rule,
so pass no rule path. Instruct it to preserve every fact — every claim, quantity, named flag or service, and stated
condition or qualifier — with its precision intact, and to leave any required PR-template section structure and its
headings unchanged. Apply its rewrite as the working description.

Then run the standardized readability self-check (the shared standard is in your context from
`han-communication:readability-guidance`) over the description's prose regions only — never inside code fences, diagram
bodies, or commit/PR/issue reference identifiers. Confirm each criterion and fix any failure before finalizing:

1. The opening line states the main point.
2. Each heading names its content and is not a generic label.
3. Each paragraph carries one idea and leads with it.
4. No sentence runs past the soft length flag (about thirty words) without reason.
5. No word from the vocabulary blocklist (the writing-voice profile's 'Avoided words and phrases' and 'AI slop to avoid'
   lists) is present.
6. Every fact is preserved — every claim, quantity, named entity, and stated condition or qualifier survives with its
   precision intact.

Fidelity wins: the standard governs how the content is said, never whether a required technical fact appears.

## Step 5: Verify the PR Description

Before displaying the PR description, read it back and confirm. Use the checklist that matches the Step 2 result.

**Always confirm (both cases):**

1. The primary summary or description section opens with a single bolded TL;DR sentence leading with behavior, and
   contains nothing else — no bullet list, no file mentions.
2. "Behavior changes" carries the behavioral detail. It is present unless the PR is a pure refactor or docs-only change.
3. The whole description is concise — at most 2-5 short paragraphs (the Summary sentence is one), with Behavior changes
   at 1-3. Trim anything that restates the diff or drops to implementation-level detail.
4. "What to look at first" appears only when the PR has more than ~8-10 files with significant (code) changes —
   documentation and configuration files do not count as significant by default. Otherwise it is omitted entirely,
   heading included. When present, it is a 2-4 bullet reading-order guide pointing at decisions or risks, not a file
   list.
5. Valid markdown, no nested fenced code blocks, no leftover authoring-instruction HTML comments or template placeholder
   braces (`{...}`), no "Generated with Claude Code."
6. Only branch-specific changes described.

**When Step 2 recorded "no repository template" (Option A), also confirm:** the sections appear in the fixed order —
Summary → Behavior changes (when applicable) → What to look at first (only when the significant-file threshold is met).

**When Step 2 found a repository template (Option B), also confirm:** unless the template was a replace-scaffold per the
conformance rules, every heading the template defines is present and in the template's original order; "What to look at
first" appears only as an appended section after the template's sections (or filled into an equivalent the template
already had) and only when the significant-file threshold is met, never interleaved out of order; the template's
checklists are reproduced verbatim with only diff-provable boxes checked and no fabricated attestations; the template's
instructional comments and placeholder prompts are stripped from the output.

Fix any issues directly before proceeding to Step 6.

## Step 6: Display and Update PR

1. **Display the PR description** — Show the full result to the user, parsed and formatted for display.

2. **Check for an existing PR** on the current branch by running `gh pr view --json number,url`. If this fails or
   returns nothing, the branch has no PR — the task is complete. Stop.

3. **If a PR exists:** Use `AskUserQuestion` to ask whether to update the PR description on GitHub, with options "Yes,
   update it" and "No, just the markdown is fine". If the user declines, stop. If accepted, update the PR on GitHub by
   running `gh pr edit --body {pr_description_content}` passing the full PR description as the body argument. Report the
   PR URL when done.
