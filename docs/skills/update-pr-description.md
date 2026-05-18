# /update-pr-description

Operator documentation for the `/update-pr-description` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`plugin/skills/update-pr-description/SKILL.md`](../../plugin/skills/update-pr-description/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md)

## TL;DR

- **What it does.** Generates a PR description from the current branch's changes against a GitHub PR using the `gh` CLI.
- **When to use it.** You have a branch with committed changes and want a thorough PR description that surfaces the central mechanism, key files, and a test plan.
- **What you get back.** A markdown PR description in-channel, optionally pushed to the open PR via `gh pr edit`.

## Key concepts

- **Central mechanism up front.** Feature flags, migrations, and behavioral changes lead the Summary. Code structure is summarized; runtime behavior is not.
- **Reviewer context check before posting.** A `junior-developer` agent reads the drafted description as a reviewer without full project context, flagging buried mechanisms, undefined acronyms, missing per-environment values, and unverifiable Test Plan items before the description goes live.
- **Test Plan is conditional.** If the branch only changes documentation, the Test Plan section is omitted. If any code or config file changed, it is included.
- **Ten-file cap per table.** Key file changes and Test Files Changed tables are each capped at ten entries. Overflow becomes a "+N more files (see full diff)" row.
- **Branch-specific diff only.** The skill describes changes unique to the feature branch. Never changes pulled in from the default branch.
- **gh CLI required.** Without `gh`, the skill stops immediately and tells you to install it.

## When to use it

**Invoke when:**

- You have a feature branch with committed changes and want a PR description written before opening (or to update an existing PR body).
- The branch includes feature flags, migrations, or multi-mode behavioral changes and you want those surfaced as the mechanism, not buried in a bullet list.
- You want per-environment configuration values or per-mode behavior described concretely.

**Do not invoke for:**

- **Posting a code review to the PR.** Use [`/gh-pr-review`](./gh-pr-review.md).
- **Running a local code review without touching the PR.** Use [`/code-review`](./code-review.md).
- **Writing the initial feature specification.** Use [`/plan-a-feature`](./plan-a-feature.md).

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

A PR description rendered in-channel, optionally pushed to the open PR:

- **Summary.** Leads with the central mechanism, followed by supporting context.
- **Key file changes.** Table of up to ten files, each with a one-line description of what changed.
- **Key test scenario changes.** Table of up to ten test files (only present when tests were added or edited).
- **Test Plan.** Checkbox list of verification steps (only present when at least one code or configuration file changed; omitted for documentation-only branches).
- **An offer to push the description to the open PR.** The skill checks for an existing PR via `gh pr view`. If one exists, it asks before calling `gh pr edit --body`.

## How to get the most out of it

- **Commit the changes first.** The skill reads `git diff origin/HEAD...HEAD`. Uncommitted changes are not included.
- **Surface the central mechanism in a context hint.** Feature flag name, migration phases, state-machine combinations. If you name these in the prompt, the Summary leads with them. Otherwise the skill infers from the diff (usually correctly, but a hint helps).
- **Per-environment values matter.** *"Default off in prod, on in staging, toggle `billing_v2_enabled`"* is a better PR description than *"added feature flag."*
- **Skip for doc-only branches.** The skill handles documentation-only branches correctly (omits Test Plan) but still writes a Summary. For pure formatting changes, a handwritten one-liner is probably faster.
- **Pair with `/gh-pr-review`.** Description first, review second, both posted to the same PR.

## Cost and latency

The skill reads the git diff, stat, log, and any source files needed to understand the change, then dispatches a single `junior-developer` agent for the reviewer context check in Step 6. The agent runs on its default model. Typical runs are around a minute for a typical PR.

## In more detail

The skill walks a seven-step process:

1. **Validate branch state.** Require `origin/HEAD`, require at least one commit, require at least one changed file.
2. **Analyze changes.** Read the diff, stat, and log. Identify the central mechanism. Classify the change type.
3. **Determine Test Plan applicability.** If all changed files are documentation, omit the Test Plan. If any are code or config, include it.
4. **Generate the PR description.** Follow the template at [`references/template.md`](../../plugin/skills/update-pr-description/references/template.md). Apply file-path truncation from [`references/formatting-rules.md`](../../plugin/skills/update-pr-description/references/formatting-rules.md). No nested fenced code blocks. No "Generated with Claude Code" trailer.
5. **Verify.** Section order, file-table caps, valid markdown, branch-specific content only.
6. **Reviewer context check.** Dispatch a `junior-developer` agent to read the description as a reviewer without full project context. Apply edits for undefined acronyms, buried mechanisms, missing per-environment values, and unverifiable Test Plan items.
7. **Display and update PR.** Show the description. If a PR exists, ask whether to push. On yes, `gh pr edit --body`.

## Sources

### GitHub: Pull Request Description Best Practices

GitHub's own guidance on PR descriptions recommends leading with the why, then the what, then verification steps. The skill's Summary-then-files-then-test-plan order reflects this.

URL: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/creating-and-reviewing-pull-requests/creating-a-pull-request

### Martin Fowler: Feature Toggles

Fowler's feature-toggles article formalizes flags as a rollout and rollback mechanism distinct from configuration. The skill's rule to surface flag gates, defaults, and environment values up front reflects this. A flag is the mechanism, not a side detail.

URL: https://martinfowler.com/articles/feature-toggles.html

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](./README.md). All 18 skills, grouped by purpose.
- [`/gh-pr-review`](./gh-pr-review.md). Post a code review to the same PR.
- [`/code-review`](./code-review.md). Local code review without touching GitHub.
- [`junior-developer`](../agents/junior-developer.md). Runs the reviewer context check against the drafted description.
- [`SKILL.md` for /update-pr-description](../../plugin/skills/update-pr-description/SKILL.md). The internal process definition.
