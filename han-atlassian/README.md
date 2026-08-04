# han-atlassian

The opt-in Atlassian plugin for the Han suite. It publishes Han artifacts to Confluence and creates work items in Jira
through the Atlassian MCP server, wrapping the core documentation, planning, and coding skills so their output lands in
Atlassian after you review it. Reach for it when your team's docs and tickets live in Confluence and Jira.

**Opt-in.** Installed on its own, not bundled by the `han` meta-plugin. Install it with
`/plugin install han-atlassian@han`. Depends on `han-communication`, `han-core`, `han-documentation`, `han-planning`,
and `han-coding` (its wrapper skills run skills from each), and requires a configured Atlassian MCP server.

## Skills

- [`/markdown-to-confluence`](docs/skills/markdown-to-confluence.md) — Publish one local Markdown file to a
  user-specified Confluence location, creating a new page or updating an existing one; defaults to an unpublished draft.
- [`/project-documentation-to-confluence`](docs/skills/project-documentation-to-confluence.md) — Run
  `/project-documentation` to write feature documentation, show it for review, then publish it to a user-specified
  Confluence location after confirmation.
- [`/investigate-to-confluence`](docs/skills/investigate-to-confluence.md) — Run `/investigate` to root-cause a bug
  (changing no code), show the report for review, then publish it as one Confluence page after confirmation.
- [`/code-overview-to-confluence`](docs/skills/code-overview-to-confluence.md) — Run `/code-overview` to produce a
  progressive-disclosure overview (changing no code), show it for review, then publish it as one Confluence page after
  confirmation.
- [`/plan-a-feature-to-confluence`](docs/skills/plan-a-feature-to-confluence.md) — Run `/plan-a-feature` to build a
  feature specification, show it for review, then publish the spec and its companion artifacts as a Confluence page tree
  after confirmation.
- [`/work-items-to-jira`](docs/skills/work-items-to-jira.md) — Create one Jira ticket per slice from a `/plan-work-items`
  work-items file in a single target project; the Jira sibling of `/work-items-to-issues`.

Its skills dispatch shared agents that live in `han-core` (and, for the readability-editor, in `han-communication`).

## Installation

Add the marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han-atlassian@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)
