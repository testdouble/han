# Plugin index: choosing a Han plugin

_This is the plugin index for the Han suite: every plugin with a one-line scent and a link to its README, plus the
install decision in one place. For the per-skill catalog see the [skills index](./skills/README.md); for how the skills
chain together see [Workflows](./workflows.md)._

_Audience: anyone about to install Han. Time to read: about two minutes. Outcome: install the right plugin on the first
try, and know exactly what you got._

> See also: [Repo root](../README.md) · [Skills index](./skills/README.md) · [Agents index](./agents/README.md) ·
> [Workflows](./workflows.md) · [Concepts](./concepts.md) · [Quickstart](./quickstart.md)

> **Short answer.** Install the bundled suite with `/plugin install han@han`. That gives you everything the meta-plugin
> bundles: the communication, research, analysis, and documentation skills, every agent, the planning skills, the coding
> skills, the GitHub skills, and the reporting skills.
>
> Pick `han-core` instead only when you know you do not want the planning, coding, GitHub, or reporting skills. There is
> no planning-only, coding-only, GitHub-only, or reporting-only option, because those plugins depend on the core plugin
> and bring it along.
>
> Some plugins sit outside the bundle. Install `han-feedback` separately to send feedback, `han-atlassian` to publish to
> Confluence or Jira, `han-linear` to publish work items to Linear, or `han-plugin-builder` for the guidance on building
> your own skills, agents, and plugins.

The rest of this page lists the plugins, explains the one dependency that surprises people, and helps you pick.

## The plugins

Han ships as a family of plugins in one marketplace. Each entry links to that plugin's README, which owns the full
description of what it does. The `han` meta-plugin is a convenience wrapper that bundles the first six.

- **[`han-communication`](../han-communication/README.md).** The foundational plugin beneath every other. Owns the
  single canonical readability standard and the skills and agent that apply it. Bundled; depends on nothing.
- **[`han-core`](../han-core/README.md).** The heart of the suite: the research, analysis, documentation, and operations
  skills, plus every specialist agent the rest of the suite dispatches. Bundled; depends on `han-communication`.
- **[`han-planning`](../han-planning/README.md).** The planning layer: specifying, planning, sequencing, breaking down,
  and stress-testing work before implementation. Bundled; depends on `han-core`.
- **[`han-coding`](../han-coding/README.md).** The coding layer: writing, reviewing, analyzing, testing, investigating,
  and standardizing code. Bundled; depends on `han-core`.
- **[`han-github`](../han-github/README.md).** The GitHub layer: posting reviews, writing PR descriptions, and
  publishing work items as issues through the `gh` CLI. Bundled; depends on `han-core`.
- **[`han-reporting`](../han-reporting/README.md).** The reporting layer: turning a spec into a plain-language
  stakeholder summary and a shareable HTML report. Bundled; depends on `han-core`.
- **[`han-feedback`](../han-feedback/README.md).** The opt-in feedback layer: structured post-session feedback on the
  Han skills you ran. Opt-in; depends on `han-core`.
- **[`han-atlassian`](../han-atlassian/README.md).** The opt-in Atlassian layer: publishing Han artifacts to Confluence
  and creating work items in Jira. Opt-in; depends on `han-core`, `han-planning`, and `han-coding`; requires an
  Atlassian MCP server.
- **[`han-linear`](../han-linear/README.md).** The opt-in Linear layer: creating one Linear issue per work-item slice.
  Opt-in; depends on `han-core`; requires a Linear MCP server.
- **[`han-plugin-builder`](../han-plugin-builder/README.md).** The opt-in plugin-building layer: the authoring guidance
  and two interview-driven builders for new skills and agents. Opt-in; depends on nothing.
- **[`han`](../han/README.md).** The meta-plugin with no components of its own. It bundles `han-communication`,
  `han-core`, `han-planning`, `han-coding`, `han-github`, and `han-reporting`. Installing it is how you ask for the
  bundled suite in one command. It does not bundle `han-feedback`, `han-atlassian`, `han-linear`, or
  `han-plugin-builder`.

## The one thing that surprises people

`han-planning` carries only the planning skills, `han-coding` only the coding skills, `han-github` only the GitHub
skills, and `han-reporting` only the reporting skills. So you might expect installing one to give you that slice of Han
on its own. None of them work that way.

`han-planning`, `han-coding`, `han-github`, and `han-reporting` all depend on `han-core`. When you install a plugin that
declares a dependency, Claude Code resolves and installs the dependency for you automatically and tells you what it
added. So installing any of them installs `han-core` alongside it. You end up with the full set of core skills and
agents either way.

That means **there is no planning-only, coding-only, GitHub-only, or reporting-only install.** The real choice comes
down to:

- **Core only** (`han-core`): the research, analysis, and documentation skills, plus every agent. No planning, coding,
  GitHub, or reporting skills.
- **The bundled suite** (`han`): all of the above, plus the planning, coding, GitHub, and reporting skills.

The opt-in plugins (`han-feedback`, `han-atlassian`, `han-linear`, `han-plugin-builder`) sit outside that choice. The
meta-plugin deliberately does not bundle them, so neither `han` nor `han-core` brings them in; install each on its own.
`han-atlassian` needs a configured Atlassian MCP server and `han-linear` a configured Linear MCP server.

## Which one do you need?

Find the row that matches you and run the command in it. Start with the recommended option unless you have a reason not
to.

| Your situation                                                                                          | Install                                                                              | Command                                  |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------------------------------------- |
| You want everything, or you are not sure yet                                                            | **`han` (start here)**                                                               | `/plugin install han@han`                |
| You want to write code test-first with `/tdd`                                                           | `han` (the bundled suite includes the coding skills)                                 | `/plugin install han@han`                |
| You work with GitHub from Claude Code (review PRs, write PR descriptions, publish work items as issues) | `han` (the bundled suite includes the GitHub skills)                                 | `/plugin install han@han`                |
| You do not need the planning, coding, GitHub, or reporting skills and want a leaner install             | `han-core`                                                                           | `/plugin install han-core@han`           |
| You installed core only and now want the planning skills                                                | `han-planning` (alongside the core you already have)                                 | `/plugin install han-planning@han`       |
| You installed core only and now want the coding skills                                                  | `han-coding` (alongside the core you already have)                                   | `/plugin install han-coding@han`         |
| You want to send post-session feedback on Han skills to the maintainers                                 | `han-feedback` (alongside whatever you already have)                                 | `/plugin install han-feedback@han`       |
| You want to publish Han documentation or feature plans to Confluence, or work items to Jira             | `han-atlassian` (alongside whatever you already have; needs an Atlassian MCP server) | `/plugin install han-atlassian@han`      |
| You want to publish Han work items to Linear                                                            | `han-linear` (alongside whatever you already have; needs a Linear MCP server)        | `/plugin install han-linear@han`         |
| You are building your own skills, agents, or plugins and want the authoring guidance                    | `han-plugin-builder` (on its own, or alongside whatever you already have)            | `/plugin install han-plugin-builder@han` |

The bundled `han` suite is the right default for almost everyone. Core-only is the deliberate choice for a reader who
knows they do not want the planning, coding, GitHub, or reporting skills.

## Installing

First add the marketplace, then install the plugin you picked:

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

Swap the second command for `han-core@han` if you chose core only, or name a layer plugin directly with
`han-planning@han`, `han-coding@han`, `han-github@han`, `han-reporting@han`, `han-feedback@han`, `han-atlassian@han`,
`han-linear@han`, or `han-plugin-builder@han`. They all resolve from the same marketplace.

Adding the marketplace makes the Test Double registry visible to Claude Code so it can resolve the plugin by name; that
is why it comes first. When the install finishes, Claude Code lists what it added, including any dependencies it pulled
in, so you can confirm you got what you expected.

## Starting with core, adding a layer later

Choosing `han-core` is not a one-way door. If you start with core only and later decide you want the GitHub skills,
install `han-github` (or `han`) on top of what you already have. Claude Code adds the layer to the core you already
installed, and you have the full suite. You do not need to uninstall or reinstall anything.

## Related documentation

- [Repo root](../README.md). Where everyone starts, and where the install commands live.
- [Skills index](./skills/README.md). Every skill, with a scent line and a link to its long-form doc.
- [Agents index](./agents/README.md). Every agent the skills dispatch.
- [Workflows](./workflows.md). How the skills chain together across plugins.
- [Concepts](./concepts.md). The skill-and-agent model that runs through the whole suite.
- [Quickstart](./quickstart.md). Five paths for five common situations, once you have installed.
- [How to provide feedback on Han](./how-to/provide-feedback.md). What to do once `han-feedback` is installed.
- [Why solo and small teams?](./why-solo-and-small-teams.md). The honest fit answer if you are still deciding whether
  Han is for you.
