# Choosing a Han Plugin

*Audience: anyone about to install Han. Time to read: about two minutes. Outcome: install the right plugin on the first try, and know exactly what you got.*

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [Quickstart](./quickstart.md)

> **Short answer.** Install the bundled suite with `/plugin install han@han`. That gives you everything the meta-plugin bundles: the planning, investigation, review, and documentation skills, every agent, the GitHub skills, and the reporting skills. Pick `han.core` instead only when you know you do not want the GitHub or reporting skills. There is no GitHub-only or reporting-only option, because both of those plugins depend on the core plugin and bring it along. Some plugins sit outside the bundle: install `han.feedback` separately if you want to send feedback, `han.atlassian` separately if you want to publish documentation to Confluence or work items to Jira, `han.linear` separately if you want to publish work items to Linear, and `han.plugin-builder` separately if you want the guidance for building your own skills, agents, and plugins.

The rest of this page explains the plugins, the one dependency that surprises people, and how to pick.

## The plugins

Han ships as a family of plugins in one marketplace. `han.core`, `han.github`, `han.reporting`, `han.feedback`, `han.atlassian`, `han.linear`, and `han.plugin-builder` carry components; `han` is a convenience wrapper that bundles `han.core`, `han.github`, and `han.reporting`.

- **`han.core`.** The heart of the suite. It carries the planning, investigation, review, and documentation skills, plus every agent the skills dispatch. If you install only this, you have the full set of specialists and almost every skill. See the [Skills Index](./skills/README.md) for the complete list.
- **`han.github`.** The GitHub layer. It adds the skills that talk to GitHub through the `gh` CLI: [`post-code-review-to-pr`](./skills/post-code-review-to-pr.md), which posts a code review as comments on a pull request; [`update-pr-description`](./skills/update-pr-description.md), which writes a PR description from the branch's changes; and [`work-items-to-issues`](./skills/work-items-to-issues.md), which publishes a work-items file as GitHub issues. This plugin depends on `han.core`.
- **`han.reporting`.** The reporting layer. It adds [`stakeholder-summary`](./skills/stakeholder-summary.md), which turns a feature specification into a plain-language stakeholder summary (also called an executive or business summary) with diagrams, for sharing with non-technical stakeholders before implementation kicks off; and [`html-summary`](./skills/html-summary.md), which converts that summary into a single self-contained HTML executive report. This plugin depends on `han.core`.
- **`han.feedback`.** The feedback layer. It adds [`han-feedback`](./skills/han-feedback.md), which captures structured post-session feedback on the Han skills you ran and optionally posts it as a GitHub issue to testdouble/han. This plugin depends on `han.core`, but it is **opt-in**: the `han` meta-plugin does not pull it in, so you install it on its own.
- **`han.atlassian`.** The Atlassian layer. It adds [`markdown-to-confluence`](./skills/markdown-to-confluence.md), which publishes a local Markdown file to a Confluence location you specify; [`project-documentation-to-confluence`](./skills/project-documentation-to-confluence.md), which runs the core documentation skill and then publishes the result there; and [`work-items-to-jira`](./skills/work-items-to-jira.md), which creates one Jira ticket per slice from a work-items file. All work through the Atlassian MCP server. This plugin depends on `han.core`, but it is **opt-in**: the `han` meta-plugin does not pull it in, so you install it on its own. It also requires a configured Atlassian MCP server.
- **`han.linear`.** The Linear layer. It adds [`work-items-to-linear`](./skills/work-items-to-linear.md), which creates one Linear issue per slice from a work-items file in a single target team, resolving the team's real states, labels, Projects, and members before creating anything and linking within-file dependencies as native Linear "blocked by" relations. It works through the Linear MCP server. This plugin depends on `han.core`, but it is **opt-in**: the `han` meta-plugin does not pull it in, so you install it on its own. It also requires a configured Linear MCP server.
- **`han.plugin-builder`.** The plugin-building layer. It carries the `guidance` skill: the authoring guidance for building Claude Code skills, agents, and plugins, which you can ask directly or vendor into a repo as a path-scoped rule set. It is for people building plugins rather than shipping product features, so it is **opt-in** and depends on nothing: the `han` meta-plugin does not pull it in, and it does not bring `han.core` along.
- **`han`.** A meta-plugin with no components of its own. It exists to pull in `han.core`, `han.github`, and `han.reporting`. Installing it is how you ask for the bundled suite in one command. It does not bundle `han.feedback`, `han.atlassian`, `han.linear`, or `han.plugin-builder`.

## The one thing that surprises people

`han.github` carries only the GitHub skills, so you might expect installing it to give you a GitHub-only slice of Han. It does not. The same is true of `han.reporting`.

Both `han.github` and `han.reporting` depend on `han.core`. When you install a plugin that declares a dependency, Claude Code resolves and installs the dependency for you automatically and tells you what it added. So installing `han.github` installs `han.core` alongside it, and installing `han.reporting` does the same. You end up with the full set of core skills and agents either way.

That means **there is no GitHub-only or reporting-only install.** The real choice comes down to:

- **Core only** (`han.core`): the planning, investigation, review, and documentation skills, plus every agent. No GitHub or reporting skills.
- **The bundled suite** (`han`): all of the above, plus the GitHub and reporting skills.

Install `han` when you want the bundled suite: the `han` meta-plugin exists for exactly this, to mean "the bundled Han suite" in one command, so it is the clearest way to ask for everything it carries. The difference is also what shows up in your installed plugin list: installing `han` lists `han` and pulls its dependencies along.

`han.feedback` and `han.atlassian` sit outside that choice. Both are opt-in by design: the meta-plugin deliberately does not bundle them, so neither `han` nor `han.core` brings them in. Install `han.feedback` on its own with `/plugin install han.feedback@han` when you want to send post-session feedback to the maintainers. Install `han.atlassian` on its own with `/plugin install han.atlassian@han` when you want to publish documentation to Confluence or work items to Jira; it also needs a configured Atlassian MCP server. Both pull `han.core` along the same way the other layers do. `han.linear` works the same way: install it on its own with `/plugin install han.linear@han` when you want to publish work items to Linear. It needs a configured Linear MCP server and pulls `han.core` along.

## Which one do you need?

Find the row that matches you and run the command in it. Start with the recommended option unless you have a reason not to.

| Your situation | Install | Command |
|----------------|---------|---------|
| You want everything, or you are not sure yet | **`han` (start here)** | `/plugin install han@han` |
| You work with GitHub from Claude Code (review PRs, write PR descriptions, publish work items as issues) | `han` (the bundled suite includes the GitHub skills) | `/plugin install han@han` |
| You do not need the GitHub or reporting skills and want a leaner install | `han.core` | `/plugin install han.core@han` |
| You want to send post-session feedback on Han skills to the maintainers | `han.feedback` (alongside whatever you already have) | `/plugin install han.feedback@han` |
| You want to publish Han documentation to Confluence or work items to Jira | `han.atlassian` (alongside whatever you already have; needs an Atlassian MCP server) | `/plugin install han.atlassian@han` |
| You want to publish Han work items to Linear | `han.linear` (alongside whatever you already have; needs a Linear MCP server) | `/plugin install han.linear@han` |
| You are building your own skills, agents, or plugins and want the authoring guidance | `han.plugin-builder` (on its own, or alongside whatever you already have) | `/plugin install han.plugin-builder@han` |

The bundled `han` suite is the right default for almost everyone. Core-only is the deliberate choice for a reader who knows they do not want the GitHub or reporting skills, for example because they do not work with GitHub from Claude Code. `han.feedback` is an extra you add on top of either when you want to report back on how the skills are working for you. `han.atlassian` is an extra you add when you want documentation published to Confluence or work items published to Jira, and it needs an Atlassian MCP server configured.

## Installing

First add the marketplace, then install the plugin you picked:

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

Swap the second command for `han.core@han` if you chose core only, or name a layer plugin directly with `han.github@han`, `han.reporting@han`, `han.feedback@han`, `han.atlassian@han`, `han.linear@han`, or `han.plugin-builder@han`. They all resolve from the same marketplace.

Adding the marketplace makes the Test Double registry visible to Claude Code so it can resolve the plugin by name; that is why it comes first. When the install finishes, Claude Code lists what it added, including any dependencies it pulled in, so you can confirm you got what you expected.

## Starting with core, adding GitHub later

Choosing `han.core` is not a one-way door. If you start with core only and later decide you want the GitHub skills, install `han.github` (or `han`) on top of what you already have. Claude Code adds the GitHub layer to the core you already installed, and you have the full suite. You do not need to uninstall or reinstall anything.

## Related Documentation

- [Plugin landing page](../README.md). Where everyone starts, and where the install commands live.
- [Concepts](./concepts.md). The skill-and-agent model that runs through the whole suite.
- [Quickstart](./quickstart.md). Five paths for five common situations, once you have installed.
- [Skills Index](./skills/README.md). Every skill, grouped by purpose.
- [How to provide feedback on Han](./how-to/provide-feedback.md). What to do once `han.feedback` is installed, and how to shape an idea into an issue with `/issue-triage`.
- [Why solo and small teams?](./why-solo-and-small-teams.md). The honest fit answer if you are still deciding whether Han is for you.
