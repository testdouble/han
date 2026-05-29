# Choosing a Han Plugin

*Audience: anyone about to install Han. Time to read: about two minutes. Outcome: install the right plugin on the first try, and know exactly what you got.*

> See also: [Plugin landing page](../README.md) · [Concepts](./concepts.md) · [Quickstart](./quickstart.md)

> **Short answer.** Install the full suite with `/plugin install han@han`. That gives you everything: the planning, investigation, review, and documentation skills, every agent, the GitHub skills, and the reporting skills. Pick `han.core` instead only when you know you do not want the GitHub or reporting skills. There is no GitHub-only or reporting-only option, because both of those plugins depend on the core plugin and bring it along.

The rest of this page explains the four plugins, the one dependency that surprises people, and how to pick.

## The four plugins

Han ships as four plugins in one marketplace. `han.core`, `han.github`, and `han.reporting` carry components; `han` is a convenience wrapper.

- **`han.core`.** The heart of the suite. It carries the planning, investigation, review, and documentation skills, plus every agent the skills dispatch. If you install only this, you have the full set of specialists and almost every skill. See the [Skills Index](./skills/README.md) for the complete list.
- **`han.github`.** The GitHub layer. It adds the skills that talk to GitHub through the `gh` CLI: [`post-code-review-to-pr`](./skills/post-code-review-to-pr.md), which posts a code review as comments on a pull request; [`update-pr-description`](./skills/update-pr-description.md), which writes a PR description from the branch's changes; and [`work-items-to-issues`](./skills/work-items-to-issues.md), which publishes a work-items file as GitHub issues. This plugin depends on `han.core`.
- **`han.reporting`.** The reporting layer. It adds [`stakeholder-summary`](./skills/stakeholder-summary.md), which turns a feature specification into a plain-language stakeholder summary (also called an executive or business summary) with diagrams, for sharing with non-technical stakeholders before implementation kicks off; and [`html-summary`](./skills/html-summary.md), which converts that summary into a single self-contained HTML executive report. This plugin depends on `han.core`.
- **`han`.** A meta-plugin with no components of its own. It exists to pull in the other three. Installing it is how you ask for the whole suite in one command.

## The one thing that surprises people

`han.github` carries only the GitHub skills, so you might expect installing it to give you a GitHub-only slice of Han. It does not. The same is true of `han.reporting`.

Both `han.github` and `han.reporting` depend on `han.core`. When you install a plugin that declares a dependency, Claude Code resolves and installs the dependency for you automatically and tells you what it added. So installing `han.github` installs `han.core` alongside it, and installing `han.reporting` does the same. You end up with the full set of core skills and agents either way.

That means **there is no GitHub-only or reporting-only install.** The real choice comes down to:

- **Core only** (`han.core`): the planning, investigation, review, and documentation skills, plus every agent. No GitHub or reporting skills.
- **The full suite** (`han`): all of the above, plus the GitHub and reporting skills.

Install `han` when you want the full suite: the `han` meta-plugin exists for exactly this, to mean "the whole Han suite" in one command, so it is the clearest way to ask for everything. The difference is also what shows up in your installed plugin list: installing `han` lists `han` and pulls its dependencies along.

## Which one do you need?

Find the row that matches you and run the command in it. Start with the recommended option unless you have a reason not to.

| Your situation | Install | Command |
|----------------|---------|---------|
| You want everything, or you are not sure yet | **`han` (start here)** | `/plugin install han@han` |
| You work with GitHub from Claude Code (review PRs, write PR descriptions, publish work items as issues) | `han` (the full suite includes the GitHub skills) | `/plugin install han@han` |
| You do not need the GitHub or reporting skills and want a leaner install | `han.core` | `/plugin install han.core@han` |

The full `han` suite is the right default for almost everyone. Core-only is the deliberate choice for a reader who knows they do not want the GitHub or reporting skills, for example because they do not work with GitHub from Claude Code.

## Installing

First add the marketplace, then install the plugin you picked:

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

Swap the second command for `han.core@han` if you chose core only, or name a layer plugin directly with `han.github@han` or `han.reporting@han`. All four resolve from the same marketplace.

Adding the marketplace makes the Test Double registry visible to Claude Code so it can resolve the plugin by name; that is why it comes first. When the install finishes, Claude Code lists what it added, including any dependencies it pulled in, so you can confirm you got what you expected.

## Starting with core, adding GitHub later

Choosing `han.core` is not a one-way door. If you start with core only and later decide you want the GitHub skills, install `han.github` (or `han`) on top of what you already have. Claude Code adds the GitHub layer to the core you already installed, and you have the full suite. You do not need to uninstall or reinstall anything.

## Related Documentation

- [Plugin landing page](../README.md). Where everyone starts, and where the install commands live.
- [Concepts](./concepts.md). The skill-and-agent model that runs through the whole suite.
- [Quickstart](./quickstart.md). Five paths for five common situations, once you have installed.
- [Skills Index](./skills/README.md). Every skill, grouped by purpose.
- [Why solo and small teams?](./why-solo-and-small-teams.md). The honest fit answer if you are still deciding whether Han is for you.
