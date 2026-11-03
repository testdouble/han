# Han: For the Solo Product Engineer

<img src="images/han-banner.png" alt="Han: your agentic ally for solo product engineers">

Han is a suite of AI skills and agents for _solo_ 😉 product engineers.

## Why use Han?

Han empowers solo and small teams of engineers to be as productive as their larger competitors. It augments your team with AI agents and skills that produce consistent, reliable, and focused expertise.

Han includes specialists in:

- Project Management
- Code Review
- Code Spelunking
- Testing
- Security

Han then summarizes all the skills' findings into artifacts you can trust.

Han's skills are designed to work together. For example:

| Skill                                                                                                                             | Example                                                                                                                                                                                                                                                                                                  |
| --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Planning](https://github.com/testdouble/han/blob/main/docs/how-to/plan-a-feature.md)                                             | `/plan-a-feature export the product inventory as a CSV file. It needs to apply the enabled filters. Write the plan to docs/features/product-export/.` <br><br>Han will generate `feature-specification.md`, `implementation-plan.md`, and/or `work-items.md`, depending on which planning skill you use. |
| [Debugging your code](https://github.com/testdouble/han/blob/main/docs/how-to/triage-and-investigate-a-bug.md)                    | `/investigate The server returns a "503 Status Unavailable" when exporting all the products.`                                                                                                                                                                                                            |
| [Updating a plan](https://github.com/testdouble/han/blob/main/docs/how-to/revise-a-plan.md)                                       | Edit a plan document or ask Claude to do it:<br><br>`update feature_specification.md: Limit the CSV export to 100K rows.`<br><br>Then ask Han to check your plan.<br><br>`/iterative-plan-review feature_specification.md`                                                                               |
| [Understanding your code](https://github.com/testdouble/han/blob/main/docs/how-to/accelerate-understanding-of-unfamiliar-code.md) | If the CSV exporting code is located in `./src/export`:<br><br>`/code-overview ./src/export/`                                                                                                                                                                                                            |
| [Reviewing your code](https://github.com/testdouble/han/blob/main/docs/how-to/run-an-effective-code-review.md)                    | `/code-review`                                                                                                                                                                                                                                                                                           |
| [Researching alternatives](https://github.com/testdouble/han/blob/main/docs/how-to/research-a-decision.md)                        | `/research What are my CSV exporting library options?`                                                                                                                                                                                                                                                   |

Han's skills hand off cleanly via readable documents, supporting complex workflows that move code from idea to deployment.

## Does it work for large teams?

While Han is purpose-built for solo and small teams, it may also work for larger teams. Read [why Han focuses on small teams](./docs/why-solo-and-small-teams.md) to learn more.

## Installation

### Claude Code

In your Terminal:

```sh
# Add the Test Double/Han marketplace
/plugin marketplace add testdouble/han

# Install the plugin
/plugin install han@han
```

Han is a bundle of plugins.

Installing `han@han` fetches the default bundle (`han-communication`, `han-core`, `han-documentation`, `han-research`, `han-planning`, `han-coding`, `han-github`, and `han-reporting`). This is the right choice for most people.

| Plugin              | Description                                                                             |
| ------------------- | --------------------------------------------------------------------------------------- |
| **`han`**           | The default bundle                                                                          | Includes `han-communication`, `han-core`, `han-documentation`, `han-research`, `han-planning`, `han-coding`, `han-github`, and `han-reporting` |
| `han-communication` | Han's readability standard and writing voice                                            |
| `han-core`          | Han's agent roster, agent behavior rules, and skills for project discovery and pairing  |
| `han-documentation` | Skills for generating project docs, architectural decision records (ADRs), and runbooks |
| `han-research`      | A pre-planning agent and associated skills for research, gap analysis, and issue triage |
| `han-planning`      | Skills for planning an implementation                                                   |
| `han-coding`        | Coding skills                                                        |
| `han-github`        | GitHub skills, such as reviewing a pull request                                         |
| `han-reporting`     | Reporting skills, such as generating a stakeholder summary                              |

Han's plugins can be installed solo, e.g., `han-documentation@han` or `han-coding@han`. Each individual plugin includes `han-core`.

```sh
# Install only the Han coding plugin
/plugin install han-coding@han
```

Han includes optional plugins to integrate into services such as Atlassian and Linear.

| Plugin          | Description                                                               |
| --------------- | ------------------------------------------------------------------------- |
| `han-atlassian` | Atlassian skills, such as publishing docs and work items                  |
| `han-linear`    | A Linear skill for publishing work items. _Requires a Linear MCP server._ |

Other optional plugins include:

| Plugin               | Description                                                                                                   |
| -------------------- | ------------------------------------------------------------------------------------------------------------- |
| `han-ddd`            | Domain-driven design (DDD) skills for bounded context discovery, evidence-backed domains, and context mapping |
| `han-plugin-builder` | Skills for building your own skills, agents, and plugins                                                      |
| `han-feedback`       | A skill for capturing feedback on Han skills at the end of a session                                          |

For help choosing the Han plugins that are right for you, see [Choosing a Han Plugin](./docs/choosing-a-han-plugin.md).

### Codex

```sh
# Add Test Double's Han as a Codex marketplace
codex plugin marketplace add testdouble/han
```

Codex does not yet support "plugins of plugins" (aka. meta-plugins) (see openai/codex#23531). Instead, install each Han plugin directly, starting with `han-communication`:

```sh
# Install Han's default plugin bundle
codex plugin add han-communication@han
codex plugin add han-core@han
codex plugin add han-documentation@han
codex plugin add han-research@han
codex plugin add han-planning@han
codex plugin add han-coding@han
codex plugin add han-github@han
codex plugin add han-reporting@han
```

If you customize your Han bundle or install only optional plugins, such as `han-atlassian` or `han-linear`, always include `han-communication`. Han's communication skill sets the readability standard for all other skills' output.

```sh
codex plugin add han-communication@han
codex plugin add han-atlassian@han
```

## Learn More

- [Concepts](./docs/concepts.md). What's the difference between a skill and an agent, and how do they combine? A good starting point.
- [Plugin index](./docs/choosing-a-han-plugin.md). A description of every plugin, their dependencies, and a guide for choosing the right ones for you.
- [Quickstart](./docs/quickstart.md). Recommended skills for some common scenarios.
- [Skills index](./docs/skills/README.md). A description of every skill.
- [Agents index](./docs/agents/README.md). A description of every agent.
- [Workflows](./docs/workflows.md). A map of how the skills connect.
- [Configuration](./docs/configuration.md). How to configure Han via `config.md`. For example: output directory, swarm size, writing voice, and connecting additional agents.
- [Sizing](./docs/sizing.md). How Han decides which and how many agents to use (i.e., the swarm size).
- [YAGNI](./docs/yagni.md). The "You Aren't Gonna Need It" rule used by every planning, review, and architecture skill.
- [Evidence](./docs/evidence.md). Han's evidence standard: what counts, how strong it is, and what to do when it's absent.
- [Readability](./docs/readability.md). Han's output readability standard.
- [Changelog](./CHANGELOG.md). What's new in each version.

### How-To Guides

- [How-to guides](./docs/how-to/README.md). A cookbook of recipes for planning, exploring, researching, and reviewing.
- [Extending Han with new skills](./docs/how-to/extend-han-with-plugin-dependencies.md).
- [Including Han in another plugin](./docs/how-to/build-a-plugin-that-depends-on-han.md).

### Contributing to Han

- [How to provide feedback on Han](./docs/how-to/provide-feedback.md).
- [How to contribute](./CONTRIBUTING.md): adding or editing skills, agents, and/or documentation.
- [How to create a new skill](./docs/how-to/create-a-new-skill.md). Build a new skill from scratch with `/skill-builder`.
- [How to create a new agent](./docs/how-to/create-a-new-agent.md). Build a new agent from scratch with `/agent-builder`.

## Maintenance and Support

**Han has no SLA.**

We will make our best effort to maintain it indefinitely.

Did you find a bug? Report it as a GitHub Issue. We try to respond within two weeks.

Han is an open source product of [Test Double](https://testdouble.com), and maintained by the following people:

- [River Lynn Bailey](https://github.com/mxriverlynn): Creator, and primary maintainer
- [Tamika Nomara](https://github.com/taminomara): Core contributor
- [Aaron Frerichs](https://github.com/afrerich): Core contributor
- [All contributors](https://github.com/testdouble/han/graphs/contributors): Greatly appreciated! 🙏

## LEGAL NOTICES

Copyright 2026 [Test Double, Inc](https://testdouble.com). Distributed under the [MIT license](./LICENSE).
