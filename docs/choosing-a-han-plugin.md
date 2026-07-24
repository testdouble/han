# Plugin index: choosing a Han plugin

_This is the plugin index for the Han suite: every plugin with a one-line scent and a link to its README, plus the
install decision in one place. For the per-skill catalog see the [skills index](./skills/README.md); for how the skills
chain together see [Workflows](./workflows.md)._

_Audience: anyone about to install Han. Time to read: about two minutes. Outcome: install the right plugin on the first
try, and know exactly what you got._

> See also: [Repo root](../README.md) · [Skills index](./skills/README.md) · [Agents index](./agents/README.md) ·
> [Workflows](./workflows.md) · [Concepts](./concepts.md) · [Quickstart](./quickstart.md)

> **Short answer.** Install the bundled suite with `/plugin install han@han`. That gives you everything the meta-plugin
> bundles: the communication skills, every agent, the documentation skills, the pre-planning research skills, the
> planning skills, the coding skills, the GitHub skills, and the reporting skills.
>
> Pick a single layer plugin (such as `han-documentation` or `han-coding`) only when you know you want just that slice;
> it brings the `han-core` agent roster along. There is no skills-free way to install a layer without the shared agents,
> because the layer plugins depend on the core plugin and bring it along.
>
> Some plugins sit outside the bundle. Install `han-feedback` separately to send feedback, `han-atlassian` to publish to
> Confluence or Jira, `han-linear` to publish work items to Linear, or `han-plugin-builder` for the guidance on building
> your own skills, agents, and plugins.

The rest of this page lists the plugins, explains the one dependency that surprises people, and helps you pick.

## The plugins

Han ships as a family of plugins in one marketplace. Each entry links to that plugin's README, which owns the full
description of what it does. The `han` meta-plugin is a convenience wrapper that bundles the first eight.

- **[`han-communication`](../han-communication/README.md).** The foundational plugin beneath every other. Owns the
  single canonical readability standard and the skills and agent that apply it. Bundled; depends on nothing.
- **[`han-core`](../han-core/README.md).** The shared foundation: the specialist agent roster the other plugins
  dispatch, the project-discovery skill, and the canonical rule files. Bundled; depends on no other Han plugin.
- **[`han-documentation`](../han-documentation/README.md).** The documentation layer: feature and system docs,
  architectural decision records, and runbooks. Bundled; depends on `han-core`.
- **[`han-research`](../han-research/README.md).** The pre-planning knowledge-work layer: open-ended research, gap
  analysis, and issue triage, plus the research-analyst agent. Bundled; depends on `han-core`.
- **[`han-planning`](../han-planning/README.md).** The planning layer: specifying, planning, sequencing, breaking down,
  and stress-testing work before implementation. Bundled; depends on `han-core`.
- **[`han-coding`](../han-coding/README.md).** The coding layer: writing, reviewing, analyzing, testing, investigating,
  and standardizing code. Bundled; depends on `han-core`.
- **[`han-github`](../han-github/README.md).** The GitHub layer: posting reviews, writing PR descriptions, and
  publishing work items as issues through the `gh` CLI. Bundled; depends on `han-core`.
- **[`han-reporting`](../han-reporting/README.md).** The reporting layer: turning a spec into a plain-language
  stakeholder summary and a shareable HTML report. Bundled; depends on `han-communication`.
- **[`han-feedback`](../han-feedback/README.md).** The opt-in feedback layer: structured post-session feedback on the
  Han skills you ran. Opt-in; depends on no other Han plugin.
- **[`han-atlassian`](../han-atlassian/README.md).** The opt-in Atlassian layer: publishing Han artifacts to Confluence
  and creating work items in Jira. Opt-in; depends on `han-core`, `han-documentation`, `han-planning`, and `han-coding`;
  requires an Atlassian MCP server.
- **[`han-linear`](../han-linear/README.md).** The opt-in Linear layer: creating one Linear issue per work-item slice.
  Opt-in; depends on no other Han plugin; requires a Linear MCP server.
- **[`han-plugin-builder`](../han-plugin-builder/README.md).** The opt-in plugin-building layer: the authoring guidance
  and two interview-driven builders for new skills and agents. Opt-in; depends on nothing.
- **[`han`](../han/README.md).** The meta-plugin with no components of its own. It bundles `han-communication`,
  `han-core`, `han-documentation`, `han-research`, `han-planning`, `han-coding`, `han-github`, and `han-reporting`.
  Installing it is how you ask for the bundled suite in one command. It does not bundle `han-feedback`, `han-atlassian`,
  `han-linear`, or `han-plugin-builder`.

## The one thing that surprises people

`han-documentation` carries only the documentation skills, `han-research` only the pre-planning research skills,
`han-planning` only the planning skills, `han-coding` only the coding skills, and `han-github` only the GitHub skills.
So you might expect installing one to give you that slice of Han with nothing else. None of them work that way.

`han-documentation`, `han-research`, `han-planning`, `han-coding`, and `han-github` all depend on `han-core`, because
their skills dispatch the shared specialist agents that live there. When you install a plugin that declares a
dependency, Claude Code resolves and installs the dependency for you automatically and tells you what it added. So
installing any of them installs `han-core` alongside it, and you get the shared agent roster and project discovery
either way. (`han-reporting` is the exception: it depends only on `han-communication`.)

That means **every layer install comes with the shared agents.** The real choice comes down to:

- **A layer plus the core** (for example `han-documentation` or `han-coding`): that layer's skills, plus the shared
  agent roster and project discovery from `han-core`.
- **The bundled suite** (`han`): every layer at once.

The opt-in plugins (`han-feedback`, `han-atlassian`, `han-linear`, `han-plugin-builder`) sit outside that choice. The
meta-plugin deliberately does not bundle them, so neither `han` nor any layer brings them in; install each on its own.
`han-atlassian` needs a configured Atlassian MCP server and `han-linear` a configured Linear MCP server.

## Which one do you need?

Find the row that matches you and run the command in it. Start with the recommended option unless you have a reason not
to.

| Your situation                                                                                          | Install                                                                              | Command                                  |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------------------------------------- |
| You want everything, or you are not sure yet                                                            | **`han` (start here)**                                                               | `/plugin install han@han`                |
| You want to write code test-first with `/tdd`                                                           | `han` (the bundled suite includes the coding skills)                                 | `/plugin install han@han`                |
| You work with GitHub from Claude Code (review PRs, write PR descriptions, publish work items as issues) | `han` (the bundled suite includes the GitHub skills)                                 | `/plugin install han@han`                |
| You want only the documentation skills (project docs, ADRs, runbooks)                                   | `han-documentation` (brings the `han-core` agents along)                             | `/plugin install han-documentation@han`  |
| You want only the pre-planning research skills (research, gap analysis, issue triage)                   | `han-research` (brings the `han-core` agents along)                                  | `/plugin install han-research@han`       |
| You want only the shared agents and project discovery, with no other skills                             | `han-core`                                                                           | `/plugin install han-core@han`           |
| You installed a single layer and now want the planning skills                                           | `han-planning` (alongside what you already have)                                     | `/plugin install han-planning@han`       |
| You installed a single layer and now want the coding skills                                             | `han-coding` (alongside what you already have)                                       | `/plugin install han-coding@han`         |
| You want to send post-session feedback on Han skills to the maintainers                                 | `han-feedback` (alongside whatever you already have)                                 | `/plugin install han-feedback@han`       |
| You want to publish Han documentation or feature plans to Confluence, or work items to Jira             | `han-atlassian` (alongside whatever you already have; needs an Atlassian MCP server) | `/plugin install han-atlassian@han`      |
| You want to publish Han work items to Linear                                                            | `han-linear` (alongside whatever you already have; needs a Linear MCP server)        | `/plugin install han-linear@han`         |
| You are building your own skills, agents, or plugins and want the authoring guidance                    | `han-plugin-builder` (on its own, or alongside whatever you already have)            | `/plugin install han-plugin-builder@han` |

The bundled `han` suite is the right default for almost everyone. A single layer is the deliberate choice for a reader
who knows they want just that slice of Han plus the shared agents.

## Installing

First add the marketplace, then install the plugin you picked:

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

Swap the second command for `han-core@han` if you chose core only, or name a layer plugin directly with
`han-documentation@han`, `han-research@han`, `han-planning@han`, `han-coding@han`, `han-github@han`,
`han-reporting@han`, `han-feedback@han`, `han-atlassian@han`, `han-linear@han`, or `han-plugin-builder@han`. They all
resolve from the same marketplace.

Adding the marketplace makes the Test Double registry visible to Claude Code so it can resolve the plugin by name; that
is why it comes first. When the install finishes, Claude Code lists what it added, including any dependencies it pulled
in, so you can confirm you got what you expected.

## Starting with core, adding a layer later

Choosing `han-core` or a single layer is not a one-way door. If you start with core only and later decide you want the
GitHub skills, install `han-github` (or `han`) on top of what you already have. Claude Code adds the layer to the core
you already installed, and you have the full suite. You do not need to uninstall or reinstall anything.

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
