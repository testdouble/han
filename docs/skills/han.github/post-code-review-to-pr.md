# /post-code-review-to-pr

Operator documentation for the `/post-code-review-to-pr` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.github/skills/post-code-review-to-pr/SKILL.md`](../../../han.github/skills/post-code-review-to-pr/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md)

## TL;DR

- **What it does.** Runs [`/code-review`](../han.coding/code-review.md) against the current branch's GitHub PR and optionally posts the review to GitHub as a formal review or PR comment.
- **When to use it.** You want the full code review *and* you want it visible to the team on the PR.
- **What you get back.** The full code-review output in-channel, posted to the PR when you confirm, plus an optional fix plan for Critical and Warning findings.

## Key concepts

- **Wraps `/code-review`.** The skill delegates the actual review to `/code-review`, adds a pre-post clarity check from `junior-developer`, then handles the GitHub-posting step.
- **Branch context flows automatically.** Because the wrapped `/code-review` runs Step 1.5 (branch context loading) on the same branch, the PR description fetched via `gh pr view` is summarized into a `$branch_context` block and plumbed to every dispatched agent. Agents avoid re-raising items the PR description has already deferred or resolved. No extra dependency for `/post-code-review-to-pr` users — `gh` is already required to post the review.
- **Self-authored PR handling.** GitHub rejects formal reviews from PR authors, so when the author and the current gh user match, the skill posts as a PR comment rather than a review. When they differ, it posts as a formal review.
- **Review event type chosen from severity.** `REQUEST_CHANGES` when any CRIT or WARN finding exists; `COMMENT` when only SUGG findings exist. Self-authored PRs always post as comments.
- **Optional fix plan.** After the review lands, the skill offers to create an implementation plan for every Critical and Warning item, ordered by severity, with file paths and line numbers.
- **gh and jq required.** Both CLI tools must be installed; the skill stops immediately otherwise.

## When to use it

**Invoke when:**

- You have an open PR and want a full code review posted as PR comments (or a formal review) on GitHub.
- A PR is ready for review and you want `/code-review`'s size-aware roster (`junior-developer` and `adversarial-security-analyst` always, plus `test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, and `devops-engineer` conditionally based on what the changed files touch), plus the manual file-by-file review, with the results visible on GitHub.
- You want the review to drive a fix plan afterward for the Critical and Warning findings.

**Do not invoke for:**

- **Local code review without touching GitHub.** Use [`/code-review`](../han.coding/code-review.md).
- **Updating the PR description.** Use [`/update-pr-description`](./update-pr-description.md).
- **Bug investigation.** Use [`/investigate`](../han.coding/investigate.md).
- **Architectural analysis.** Use [`/architectural-analysis`](../han.coding/architectural-analysis.md).

## How to invoke it

Run `/post-code-review-to-pr` in Claude Code. Optionally pass focus areas.

Give it:

1. **An open PR on the current branch.** The skill verifies with `gh pr view --json number,url` and `gh pr diff --name-only`. If either fails, it stops.
2. **A focus hint, optional.** *"Focus on the security implications of the new auth endpoints."* The hint is forwarded to `/code-review`.
3. **gh and jq installed.** Both are required. Otherwise the skill stops at the pre-requisite check.

Example prompts:

- `/post-code-review-to-pr`. Run a full code review on the current PR.
- `/post-code-review-to-pr`. *"Focus on the security implications of the new auth endpoints."*
- `/post-code-review-to-pr`. *"Review with extra attention to the database migration changes."*

## What you get back

A full review plus GitHub integration:

- **The full `/code-review` output in-channel.** Review Summary table, Review Recommendation, and all findings organized by severity, plus any optional sections (What's Good, Security Vulnerabilities, Remediation) that are present. The code-review skill renders a section only when it has content, so the body builder treats every section other than the table and the recommendation as optional. See the `/code-review` documentation for the detailed shape.
- **An offer to post to GitHub.** `AskUserQuestion` with "Yes, post to GitHub" / "No, just the local review."
- **When accepted.** The skill gathers PR metadata (`owner/repo`, `pr_number`, `head_sha`, author login, current user login), runs a `junior-developer` clarity pass on the draft review body (flagging unclear wording, misaligned severity, accusatory tone, and broken location references), applies the edits, writes the final review body to a temp file, and posts it. Self-authored PRs become comments. PRs you did not author become formal reviews with the event type derived from severity.
- **An offer to create a fix plan.** Only when CRIT or WARN findings exist. An implementation plan listing each finding by task ID, with specific code changes, file paths, and line numbers, ordered by priority.

## How to get the most out of it

- **Install gh and jq before running.** The pre-requisite check is the first stop. Without both installed, the skill cannot proceed.
- **Open the PR before running.** The skill requires an existing PR. If the branch has no PR yet, open one first (with [`/update-pr-description`](./update-pr-description.md) if you want a description too).
- **Run `/project-discovery` first.** The underlying `/code-review` reads the discovery reference for lint/build/test commands, ADR directory, coding-standards directory, and documentation root. Without it, compliance and freshness checks degrade.
- **Trust the severity routing.** The skill picks `REQUEST_CHANGES` when a reviewer could reasonably block on the findings, and `COMMENT` when only suggestions remain. If you disagree with the routing, decline the post offer and post manually with your preferred event type.
- **Accept the fix-plan offer when Critical findings exist.** The plan converts the review into a concrete implementation list, often faster than re-reading the review later.

## Cost and latency

The skill wraps `/code-review`, whose roster scales with the change [size](../../sizing.md). Two agents always run (`junior-developer`, `adversarial-security-analyst`); the rest (`test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, `devops-engineer`) join only when their domain is touched by the diff. Plus the manual review pass and optional compliance/freshness steps. Costs match `/code-review` plus the incremental gh-posting time. Typical runs are a few minutes for the review and a few seconds for the post.

## In more detail

The skill walks a five-step process:

1. **Validate PR state.** Require gh and jq installed; require a PR that exists on the current branch.
2. **Run `/code-review`.** Invoke the skill with any user-provided focus areas. Inherits the size-aware code-review roster (`junior-developer` and `adversarial-security-analyst` always, plus the conditional roster) when the changed files trigger their domain.
3. **Offer to post review to GitHub.** On yes, gather PR metadata and assemble the draft review body.
4. **Pre-post clarity check.** Dispatch a `junior-developer` agent against the drafted review text (not the code) to catch unclear wording, mis-assigned severity, accusatory tone, or missing `file_path:line_number` references. Apply the edits, then post the final body. As PR comment (self-authored) or formal review (otherwise), event type from severity.
5. **Offer to create fix plan.** Only when CRIT or WARN findings exist. Plan lists each item by task ID with specific code changes.

## Sources

### GitHub: Pull Request Reviews

GitHub's own docs on formal reviews vs PR comments, and the event types `APPROVE` / `REQUEST_CHANGES` / `COMMENT`, shape the skill's posting decision. The self-authored-PR carve-out reflects GitHub's rejection of formal reviews from PR authors.

URL: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests

### Google Engineering Practices: Code Reviewer's Guide

Google's reviewer guide emphasizes that reviews should block on defects, not on style already covered by tooling, and that suggestions should be distinct from blockers. The skill's severity-to-event mapping (CRIT/WARN → `REQUEST_CHANGES`, SUGG → `COMMENT`) reflects this.

URL: https://google.github.io/eng-practices/review/reviewer/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/code-review`](../han.coding/code-review.md). The skill this one wraps. Use directly for local review without GitHub posting.
- [`/update-pr-description`](./update-pr-description.md). For writing the PR description.
- [`/investigate`](../han.coding/investigate.md). Next step when a Critical finding hides a bug.
- [`junior-developer`](../../agents/han.core/junior-developer.md). Runs the pre-post clarity check against the drafted review body.
- [`SKILL.md` for /post-code-review-to-pr](../../../han.github/skills/post-code-review-to-pr/SKILL.md). The internal process definition.
