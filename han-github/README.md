# han-github

The GitHub layer of the Han suite: the skills that talk to GitHub through the `gh` CLI. It posts a code review to a pull
request, writes a PR description from the branch's changes, and publishes a work-items file as GitHub issues. Reach for
it when you want Han's output to land on GitHub rather than stay local.

**Bundled.** Installed with the `han` meta-plugin. Depends on `han-communication` and `han-core`. Requires the `gh` CLI.

## Skills

- [`/post-code-review-to-pr`](docs/skills/post-code-review-to-pr.md) — Run `/code-review` against a GitHub PR and post
  the review as comments, after a clarity check on the drafted review body.
- [`/update-pr-description`](docs/skills/update-pr-description.md) — Generate a PR description from the current branch's
  changes, conforming to the repository's PR template when one exists.
- [`/work-items-to-issues`](docs/skills/work-items-to-issues.md) — Publish each item in a `/plan-work-items` work-items
  file as a GitHub issue in its target repo, with within-repo blockers linked.

Its skills dispatch shared agents that live in `han-core` (and, for the readability-editor, in `han-communication`).

## Installation

Add the marketplace to Claude Code, then install the plugin (or install `han` to get it as part of the bundled suite):

```
/plugin marketplace add testdouble/han
/plugin install han-github@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
