# /update-pr-description

Operator documentation for the `/update-pr-description` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-github/skills/update-pr-description/SKILL.md`](../../../han-github/skills/update-pr-description/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md)

## TL;DR

- **What it does.** Generates a PR description from the current branch's changes against a GitHub PR using the `gh` CLI. When the repository defines its own GitHub pull-request template, the description conforms to that template's structure.
- **When to use it.** You have a branch with committed changes and want a short, focused PR description (a few short paragraphs) that surfaces the central behavioral change, with a reading-order guide for large changes.
- **What you get back.** A markdown PR description in-channel, optionally pushed to the open PR via `gh pr edit`.

## Key concepts

- **Short by design.** The whole description is at most 2-5 short paragraphs, with the behavioral detail in 1-3 of them. It stays at the altitude of behavior and intent and lets the diff carry the specifics, rather than restating config values, phases, or modes in prose.
- **Central mechanism up front.** Feature flags, migrations, and behavioral changes lead the Summary. Behavior is named with its headline effect (a flag and its default, a migration's direction), not enumerated value by value.
- **Repository PR template aware.** Before generating, the skill looks for a GitHub pull-request template (in the repo root, `.github/`, `docs/`, or a `PULL_REQUEST_TEMPLATE/` directory). If it finds one, the description conforms to that template's headings and order instead of the default structure. It reads the template's intent rather than assuming a shape. A template whose comments say "replace this with a description" is treated as a throwaway scaffold and replaced wholesale. A structural template's sections, by contrast, are filled in and preserved. Checklist boxes are checked only when the diff unambiguously proves them; the rest are left for the author. If multiple templates exist in a `PULL_REQUEST_TEMPLATE/` directory, the skill asks which to use.
- **Junior-developer authors the description.** A `junior-developer` agent writes the PR description directly. Authoring with a fresh-reviewer perspective (a teammate without full project context) means the result already anticipates what a reviewer needs to see, so no separate review pass is required.
- **Lean output, no GitHub-duplicating sections.** The description is a one-sentence Summary, a short Behavior changes section, and a conditional "What to look at first." It deliberately drops a test-results list, a files-of-interest list, and a test-scenario list. GitHub's Checks and Files Changed tabs already render those one click away.
- **"What to look at first" is conditional on size.** It appears only when the PR has more than ~8-10 files with significant changes. "Significant" means code files; documentation and configuration files do not count by default, and even when one is judged significant it usually does not belong in the list.
- **Branch-specific diff only.** The skill describes changes unique to the feature branch. Never changes pulled in from the default branch.
- **gh CLI required.** Without `gh`, the skill stops immediately and tells you to install it.

## When to use it

**Invoke when:**

- You have a feature branch with committed changes and want a PR description written before opening (or to update an existing PR body).
- The branch includes feature flags, migrations, or multi-mode behavioral changes and you want those surfaced as the mechanism, not buried in a bullet list.
- You want per-environment configuration values or per-mode behavior described concretely.

**Do not invoke for:**

- **Posting a code review to the PR.** Use [`/post-code-review-to-pr`](./post-code-review-to-pr.md).
- **Running a local code review without touching the PR.** Use [`/code-review`](../han-coding/code-review.md).
- **Writing the initial feature specification.** Use [`/plan-a-feature`](../han-planning/plan-a-feature.md).

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

A PR description rendered in-channel, optionally pushed to the open PR. When the repository has no PR template, sections appear in this fixed order: Summary, Behavior changes (when runtime behavior changes), What to look at first (only for large code changes). When the repository defines a PR template, the description follows that template's headings and order instead. "What to look at first" is appended when the template has no home for it and the PR is large enough to warrant it.

- **Summary.** A single bolded TL;DR sentence (`**This PR <verb> <behavior>, so that <why>.**`) and nothing else: no bullet list, no file mentions.
- **Behavior changes.** The load-bearing section, kept to 1-3 short paragraphs, gives a plain-language before/after of what the PR changes at runtime. It leads with the central mechanism (flag flips, migrations, state-machine edits, config or API-contract changes) and its headline effect. A small table appears only when several flags or modes genuinely interact. Omitted for pure refactors and docs-only PRs.
- **What to look at first.** A 2–4 bullet reading-order guide pointing at decisions, tradeoffs, or risks, not a file list. Present only when the PR has more than ~8-10 files with significant (code) changes; documentation and configuration files do not count as significant by default.
- **An offer to push the description to the open PR.** The skill checks for an existing PR via `gh pr view`. If one exists, it asks before calling `gh pr edit --body`.

## How to get the most out of it

- **Commit the changes first.** The skill reads `git diff origin/HEAD...HEAD`. Uncommitted changes are not included.
- **Surface the central mechanism in a context hint.** Feature flag name, migration phases, state-machine combinations. If you name these in the prompt, the Summary leads with them. Otherwise the skill infers from the diff (usually correctly, but a hint helps).
- **Per-environment values matter.** *"Default off in prod, on in staging, toggle `billing_v2_enabled`"* is a better PR description than *"added feature flag."*
- **Skip for doc-only branches.** The skill handles documentation-only branches correctly (the Summary sentence stands alone, with no Behavior changes section) but still writes a description. For pure formatting changes, a handwritten one-liner is probably faster.
- **Pair with `/post-code-review-to-pr`.** Description first, review second, both posted to the same PR.

## Cost and latency

The skill reads the git diff, stat, log, and any source files needed to understand the change. It then dispatches a single `junior-developer` agent in Step 4 to author the PR description, and a single `han-core:readability-editor` agent to rewrite it against the readability standard. Both agents run on their default models. Typical runs are around a minute for a typical PR.

## In more detail

The skill walks a six-step process:

1. **Validate branch state.** Require `origin/HEAD`, require at least one commit, require at least one changed file.
2. **Discover the repository PR template.** Look in the repo root, `.github/`, `docs/`, and any `PULL_REQUEST_TEMPLATE/` directory for a GitHub pull-request template. If exactly one is found, read it in full (including HTML comments). If a `PULL_REQUEST_TEMPLATE/` directory holds several, ask which to conform to. If none exists, the skill uses its default structure.
3. **Analyze changes.** Read the diff, stat, and log. Identify the central mechanism. Classify the change type. Count the significant (code) files, since that count gates "What to look at first."
4. **Generate the PR description.** Dispatch a `junior-developer` agent with the branch context and a structure directive. With no template, the directive carries [`references/template.md`](../../../han-github/skills/update-pr-description/references/template.md) and the fixed section order. With a template, it carries the discovered template and the conformance rules in [`references/template-conformance.md`](../../../han-github/skills/update-pr-description/references/template-conformance.md). The agent authors the description with a fresh-reviewer perspective, anticipating what a teammate without full project context needs to see. Once the draft exists, a `readability-editor` agent rewrites it against the shared readability standard for the reviewer who will read the code, preserving every fact and reference identifier. A standardized readability self-check then confirms the result before finalizing. No nested fenced code blocks. No "Generated with Claude Code" trailer.
5. **Verify.** Structure (fixed order, or conformance to the discovered template), the conditional "What to look at first" threshold, valid markdown, branch-specific content only.
6. **Display and update PR.** Show the description. If a PR exists, ask whether to push. On yes, `gh pr edit --body`.

## Sources

### GitHub: Pull Request Description Best Practices

GitHub's own guidance on PR descriptions recommends leading with the why, then the what. The skill's lead-with-the-why-then-the-behavior order reflects this, and leaves verification and the file list to GitHub's native Checks and Files Changed tabs.

URL: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/creating-and-reviewing-pull-requests/creating-a-pull-request

### Martin Fowler: Feature Toggles

Fowler's feature-toggles article formalizes flags as a rollout and rollback mechanism distinct from configuration. The skill's rule to surface flag gates, defaults, and environment values up front reflects this. A flag is the mechanism, not a side detail.

URL: https://martinfowler.com/articles/feature-toggles.html

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/post-code-review-to-pr`](./post-code-review-to-pr.md). Post a code review to the same PR.
- [`/code-review`](../han-coding/code-review.md). Local code review without touching GitHub.
- [`junior-developer`](../../agents/han-core/junior-developer.md). Authors the PR description with a fresh-reviewer perspective.
- [`readability-editor`](../../agents/han-core/readability-editor.md). Rewrites the drafted description against the shared readability standard for the reviewer who will read the code, preserving every fact and reference identifier.
- [`SKILL.md` for /update-pr-description](../../../han-github/skills/update-pr-description/SKILL.md). The internal process definition.
