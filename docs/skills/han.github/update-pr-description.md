# /update-pr-description

Operator documentation for the `/update-pr-description` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.github/skills/update-pr-description/SKILL.md`](../../../han.github/skills/update-pr-description/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md)

## TL;DR

- **What it does.** Generates a PR description from the current branch's changes against a GitHub PR using the `gh` CLI. When the repository defines its own GitHub pull-request template, the description conforms to that template's structure.
- **When to use it.** You have a branch with committed changes and want a thorough PR description that surfaces the central mechanism, key files, and a test plan.
- **What you get back.** A markdown PR description in-channel, optionally pushed to the open PR via `gh pr edit`.

## Key concepts

- **Central mechanism up front.** Feature flags, migrations, and behavioral changes lead the Summary. Code structure is summarized; runtime behavior is not.
- **Repository PR template aware.** Before generating, the skill looks for a GitHub pull-request template (in the repo root, `.github/`, `docs/`, or a `PULL_REQUEST_TEMPLATE/` directory). If it finds one, the description conforms to that template's headings and order instead of the default structure. It reads the template's intent rather than assuming a shape: a template whose comments say "replace this with a description" is treated as a throwaway scaffold and replaced wholesale, while a structural template's sections are filled in and preserved. Checklist boxes are checked only when the diff unambiguously proves them; the rest are left for the author. If multiple templates exist in a `PULL_REQUEST_TEMPLATE/` directory, the skill asks which to use.
- **Junior-developer authors the description.** A `junior-developer` agent writes the PR description directly. Authoring with a fresh-reviewer perspective (a teammate without full project context) means the result already anticipates what a reviewer needs to see, so no separate review pass is required.
- **"How this was tested" is conditional.** If the branch only changes documentation, the section is omitted. If any code or config file changed, it is included.
- **Files of interest is a bulleted list, capped at five.** This section is a bulleted list of at most 5 entries, never a table. Each entry is `` `path` `` followed by a one-phrase reason the file matters for review. Generated files, mechanical refactors, trivial changes, and non-central test helpers are skipped.
- **Branch-specific diff only.** The skill describes changes unique to the feature branch. Never changes pulled in from the default branch.
- **gh CLI required.** Without `gh`, the skill stops immediately and tells you to install it.

## When to use it

**Invoke when:**

- You have a feature branch with committed changes and want a PR description written before opening (or to update an existing PR body).
- The branch includes feature flags, migrations, or multi-mode behavioral changes and you want those surfaced as the mechanism, not buried in a bullet list.
- You want per-environment configuration values or per-mode behavior described concretely.

**Do not invoke for:**

- **Posting a code review to the PR.** Use [`/post-code-review-to-pr`](./post-code-review-to-pr.md).
- **Running a local code review without touching the PR.** Use [`/code-review`](../han.core/code-review.md).
- **Writing the initial feature specification.** Use [`/plan-a-feature`](../han.core/plan-a-feature.md).

## How to invoke it

Run `/update-pr-description` in Claude Code. Optionally pass context for the description.

Give it:

1. **A branch with committed changes.** The skill requires `origin/HEAD` to be set (the default branch) and at least one commit on the feature branch. If `origin/HEAD` is not set, the skill asks for the default-branch name.
2. **A context hint, optional.** *"The central mechanism is a feature flag called `billing_v2_enabled` defaulting to off in production, on in staging."*

Example prompts:

- `/update-pr-description`. Run on a branch with changes to generate a PR description.
- `/update-pr-description`. *"After finishing this feature branch, generate and push the description to GitHub."*
- `/update-pr-description`. *"Focus on how the new retry back-off behaves across the three retry modes."*

## What you get back

A PR description rendered in-channel, optionally pushed to the open PR. When the repository has no PR template, sections appear in this fixed order: Summary, What to look at first, How this was tested (when included), Files of interest, Test scenario changes (when tests were added or edited). When the repository defines a PR template, the description follows that template's headings and order instead, with "What to look at first" and "Files of interest" appended when the template has no home for them.

- **Summary.** Opens with a single bolded TL;DR sentence (`**This PR <verb> <behavior>, so that <why>.**`), followed by 2–4 bullets covering user-visible or runtime behavior, scope, and reviewer-attention pointers. A `### Behavior changes` subsection appears only when runtime behavior changes (flag flips, migrations, state-machine edits, config changes, API contract changes).
- **What to look at first.** A 2–4 bullet attention guide pointing at decisions, tradeoffs, or risks. Not a file list.
- **How this was tested.** Past-tense author-self-check items prefixed with `- ✅` describing scenarios the author already verified. Only present when at least one code or configuration file changed. Omitted for documentation-only branches.
- **Files of interest.** A bulleted list of at most 5 entries, never a table. Each entry is `` `path` `` followed by a one-phrase reason the file matters for review.
- **Test scenario changes.** Behavioral scenarios in plain language. No file paths in this section (test files, when central, appear in Files of interest). Only present when tests were added or edited.
- **An offer to push the description to the open PR.** The skill checks for an existing PR via `gh pr view`. If one exists, it asks before calling `gh pr edit --body`.

## How to get the most out of it

- **Commit the changes first.** The skill reads `git diff origin/HEAD...HEAD`. Uncommitted changes are not included.
- **Surface the central mechanism in a context hint.** Feature flag name, migration phases, state-machine combinations. If you name these in the prompt, the Summary leads with them. Otherwise the skill infers from the diff (usually correctly, but a hint helps).
- **Per-environment values matter.** *"Default off in prod, on in staging, toggle `billing_v2_enabled`"* is a better PR description than *"added feature flag."*
- **Skip for doc-only branches.** The skill handles documentation-only branches correctly (omits the "How this was tested" section) but still writes a Summary. For pure formatting changes, a handwritten one-liner is probably faster.
- **Pair with `/post-code-review-to-pr`.** Description first, review second, both posted to the same PR.

## Cost and latency

The skill reads the git diff, stat, log, and any source files needed to understand the change, then dispatches a single `junior-developer` agent in Step 5 to author the PR description. The agent runs on its default model. Typical runs are around a minute for a typical PR.

## In more detail

The skill walks a seven-step process:

1. **Validate branch state.** Require `origin/HEAD`, require at least one commit, require at least one changed file.
2. **Discover the repository PR template.** Look in the repo root, `.github/`, `docs/`, and any `PULL_REQUEST_TEMPLATE/` directory for a GitHub pull-request template. If exactly one is found, read it in full (including HTML comments). If a `PULL_REQUEST_TEMPLATE/` directory holds several, ask which to conform to. If none exists, the skill uses its default structure.
3. **Analyze changes.** Read the diff, stat, and log. Identify the central mechanism. Classify the change type.
4. **Determine "How this was tested" applicability.** If all changed files are documentation, omit the section. If any are code or config, include it.
5. **Generate the PR description.** Dispatch a `junior-developer` agent with the branch context, the inclusion decision from Step 4, the contents of [`references/formatting-rules.md`](../../../han.github/skills/update-pr-description/references/formatting-rules.md), and a structure directive. With no template, the directive carries [`references/template.md`](../../../han.github/skills/update-pr-description/references/template.md) and the fixed section order. With a template, it carries the discovered template and the conformance rules in [`references/template-conformance.md`](../../../han.github/skills/update-pr-description/references/template-conformance.md). The agent authors the description with a fresh-reviewer perspective, anticipating what a teammate without full project context needs to see. No nested fenced code blocks. No "Generated with Claude Code" trailer.
6. **Verify.** Structure (fixed order, or conformance to the discovered template), file-list caps, valid markdown, branch-specific content only.
7. **Display and update PR.** Show the description. If a PR exists, ask whether to push. On yes, `gh pr edit --body`.

## Sources

### GitHub: Pull Request Description Best Practices

GitHub's own guidance on PR descriptions recommends leading with the why, then the what, then verification steps. The skill's Summary-then-files-then-test-plan order reflects this.

URL: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/creating-and-reviewing-pull-requests/creating-a-pull-request

### Martin Fowler: Feature Toggles

Fowler's feature-toggles article formalizes flags as a rollout and rollback mechanism distinct from configuration. The skill's rule to surface flag gates, defaults, and environment values up front reflects this. A flag is the mechanism, not a side detail.

URL: https://martinfowler.com/articles/feature-toggles.html

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/post-code-review-to-pr`](./post-code-review-to-pr.md). Post a code review to the same PR.
- [`/code-review`](../han.core/code-review.md). Local code review without touching GitHub.
- [`junior-developer`](../../agents/han.core/junior-developer.md). Authors the PR description with a fresh-reviewer perspective.
- [`SKILL.md` for /update-pr-description](../../../han.github/skills/update-pr-description/SKILL.md). The internal process definition.
