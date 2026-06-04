# How To: Extend Han with Plugin Dependencies

A walkthrough of how one Claude Code plugin builds on another through dependencies, using Han's own plugins as the worked example. By the end you understand how `han.github`, `han.reporting`, and `han.feedback` extend `han.core`, why the `han` meta-plugin exists, why it bundles `han.core`, `han.github`, and `han.reporting` but deliberately leaves `han.feedback` opt-in, and what install and enable actually do when a plugin names the plugins it needs.

> See also: [How-to index](./README.md) · [Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md) · [plugin.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md) · [Choosing a Han plugin](../choosing-a-han-plugin.md)

Claude Code plugins were not always able to build on each other. For a while, the only way to ship a related set of skills was to put them all in one plugin and hope nobody wanted a smaller slice. Plugin dependencies changed that: a plugin can name the plugins it needs, and Claude Code installs and enables them for you when your plugin goes in. That is the mechanism Han itself uses to split into a family of plugins, and it is the same mechanism you use to extend Han from a plugin of your own.

This guide is the conceptual half of that story. It walks how the dependency mechanism works and how Han already uses it, so you have a working model in your head before you build anything. When you are ready to stand up a plugin of your own that depends on Han, [Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md) is the hands-on next step.

## Before you begin

- You want to understand how Han composes, either because you are about to extend it or because you are reading its plugins and want to know why they are split the way they are.
- You have looked at the [plugin.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md) or are comfortable opening one. This guide names the `dependencies` field repeatedly; the reference is where the full field shape lives.
- You do not need to write any code to read this guide. The worked example is Han's own manifests, which already ship in this repository.

## What you'll end up with

- A working model of the `dependencies` field: what an entry looks like, what install does with it, and what enabling and disabling do across a dependency chain.
- The ability to read Han's plugin topology and explain why `han.github`, `han.reporting`, and `han.feedback` depend on `han.core`, why the `han` meta-plugin depends on `han.core`, `han.github`, and `han.reporting`, and why it leaves `han.feedback` out.
- Enough grounding to follow [Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md) without backtracking.

## How a dependency works

You declare dependencies in a `dependencies` array in your plugin's `.claude-plugin/plugin.json`. Each entry is either a plain plugin name or an object that pins a version and, when the dependency lives in another marketplace, names that marketplace:

    "dependencies": [
      "han.core",
      { "name": "some-plugin", "version": "~2.1.0" }
    ]

A plain name floats to whatever version the marketplace currently provides. An object with a `version` field constrains the resolution to a semver range. The [plugin.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md#dependencies) covers the field shape, and the canonical Claude Code documentation at [code.claude.com/docs/en/plugin-dependencies](https://code.claude.com/docs/en/plugin-dependencies) is the source of truth for how resolution, versioning, and cross-marketplace trust behave. The behavior that matters for extending Han is short:

- **Install pulls dependencies in.** When someone installs your plugin, Claude Code resolves each dependency, installs it, and tells you what it added. Your reader runs one install command and gets your plugin plus everything it depends on.
- **Enabling is transitive.** Enabling your plugin enables its dependencies at the same scope. Disabling is the reverse: Claude Code refuses to disable a plugin while another enabled plugin still depends on it, and it prints the command to disable them together.
- **Versions resolve against tags.** A pinned `version` range resolves against the marketplace's published versions, and when more than one plugin constrains the same dependency the ranges are intersected and the highest satisfying version wins. When the ranges cannot be satisfied together, the install fails with a range conflict rather than guessing.
- **Cross-marketplace dependencies need permission.** A dependency in a different marketplace from your plugin is refused unless the marketplace your reader is installing from explicitly allows that other marketplace. This is the one rule that separates a suite-internal extension from an outside one, so hold on to it.

## How Han uses it

Han is its own worked example. It ships as a family of plugins in one marketplace, wired together with exactly the `dependencies` array above.

`han.core` is the base layer. It carries the planning, investigation, review, and documentation skills, plus every agent those skills dispatch, and it depends on nothing:

    {
      "name": "han.core",
      "version": "1.0.0"
    }

`han.github` is a layer on top of core. It adds the GitHub-facing skills (`post-code-review-to-pr`, `update-pr-description`, `work-items-to-issues`), and several of them build directly on core skills. The `post-code-review-to-pr` skill, for example, runs core's `/code-review` and then posts the result to a pull request. Because it cannot do its job without core, it declares core as a dependency:

    {
      "name": "han.github",
      "version": "1.0.0",
      "dependencies": [
        "han.core"
      ]
    }

`han.reporting` is a second layer on top of core, built the same way. It adds the reporting skills (`stakeholder-summary`, which turns a feature specification into a plain-language summary, and `html-summary`, which renders that summary as a single self-contained HTML report), and it declares core as a dependency for the same reason `han.github` does:

    {
      "name": "han.reporting",
      "version": "1.0.0",
      "dependencies": [
        "han.core"
      ]
    }

`han.feedback` is a third layer on top of core, and it is built exactly like the other two. It adds the `han-feedback` skill (which captures post-session feedback on Han skill runs), and it declares core as a dependency for the same reason:

    {
      "name": "han.feedback",
      "version": "1.0.0",
      "dependencies": [
        "han.core"
      ]
    }

`han` is a meta-plugin. It has no skills or agents of its own. Its entire job is to pull in `han.core`, `han.github`, and `han.reporting` so that one install command gives you the bundled suite. Notice what is *not* in its `dependencies` array: `han.feedback`. The feedback plugin depends on core like every other layer, but the meta-plugin deliberately leaves it out, so installing `han` does not pull it in. That is the point worth holding on to: depending on `han.core` and being bundled by the meta-plugin are two independent decisions.

    {
      "name": "han",
      "version": "3.0.0",
      "dependencies": [
        "han.core",
        "han.github",
        "han.reporting"
      ]
    }

The plugins are all listed in one `marketplace.json`, each with a relative `source` path:

    {
      "name": "han",
      "plugins": [
        { "name": "han",           "source": "./han",           "version": "3.0.0" },
        { "name": "han.core",      "source": "./han.core",      "version": "1.0.0" },
        { "name": "han.github",    "source": "./han.github",    "version": "1.0.0" },
        { "name": "han.reporting", "source": "./han.reporting", "version": "1.0.0" },
        { "name": "han.feedback",  "source": "./han.feedback",  "version": "1.0.0" }
      ]
    }

Notice the topology that falls out of this: `han` depends on `han.core`, `han.github`, and `han.reporting`; `han.github`, `han.reporting`, and `han.feedback` all depend on `han.core`; `han.core` depends on nothing. The graph is acyclic, with `han.core` at the bottom. `han.feedback` sits in the graph as a leaf that nothing else points to: it depends on core, but the meta-plugin does not depend on it, which is what makes it opt-in. That is the shape you copy when you extend Han. Where you copy it to, and whether the meta-plugin bundles it, are the only things that change, and that is the subject of the next guide.

## Why it's built this way

The split is not decoration. It buys three things, and naming them tells you when to reach for the same pattern.

First, **a reader can take a smaller slice.** Someone who never touches GitHub can install `han.core` on its own and get the planning, investigation, and review skills without the PR-facing ones. Bundling everything into a single plugin would have taken that choice away. Dependencies let the pieces ship separately and still compose.

Second, **the dependency is honest about what it needs.** `han.github` declares `han.core` because it genuinely cannot run without it. The `post-code-review-to-pr` skill runs core's `/code-review` as a step before it posts anything. Declaring the dependency means installing `han.github` guarantees core is present and enabled alongside it, so the skill never reaches for a `han.core` agent that is not there. The declaration is documentation and a load-time guarantee at the same time.

Third, **the meta-plugin gives one install command for the bundled suite, and bundling is a choice.** `han` carries no components. Its only job is to depend on `han.core`, `han.github`, and `han.reporting` so that `/plugin install han@han` delivers them in one step. A plugin with no components and nothing but a `dependencies` array is a pattern worth naming, because it is how you bundle a set of plugins under a single install. But it bundles only what its `dependencies` array names: `han.feedback` is a working plugin that depends on core and ships in the same marketplace, yet the meta-plugin leaves it out so it stays opt-in. The lesson for your own extension is that you decide, separately from whether your plugin depends on core, whether the meta-plugin should bundle it. The canonical docs describe what install does with dependencies but do not name this zero-component meta-plugin shape on its own, so treat it as observed practice that Han relies on rather than a documented construct, and check the [canonical docs](https://code.claude.com/docs/en/plugin-dependencies) if install behavior ever surprises you.

Put together, the three properties are the reason to extend Han through a dependency rather than by copying its skills into your own plugin: you get a smaller install surface, a load-time guarantee that the core is present, and the option to bundle your extension into the suite later (or leave it opt-in, the way `han.feedback` is).

## What you should expect

- **The resolution details live in the canonical docs, not in Han.** Han's in-repo [plugin.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md#dependencies) confirms the `dependencies` field and its syntax, but the full rules for version resolution, enable and disable behavior, pruning, and error handling are documented at [code.claude.com/docs/en/plugin-dependencies](https://code.claude.com/docs/en/plugin-dependencies). When a behavior here and a behavior there ever seem to disagree, the canonical docs win.
- **The versions in this guide are the versions on disk.** `han.core`, `han.github`, `han.reporting`, and `han.feedback` are at 1.0.0 and `han` is at 3.0.0 as written. If you are reading the manifests and the numbers differ, the manifests are right; this guide is describing the shape, not pinning the numbers.
- **The meta-plugin shape is observed, not specified.** A zero-component plugin works because of what install does with dependencies, not because the docs name it as a construct. Han relies on it in production, so it is safe to copy, but read the canonical docs if install ever does something you did not expect.

## Where to go next

- [Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md) is the hands-on next step: stand up a new plugin that depends on `han.core`, add a skill on top, and confirm both load.
- [plugin.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md) is the field-level reference for everything in a manifest, including the [`dependencies`](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md#dependencies) field used throughout this guide.
- [Choosing a Han plugin](../choosing-a-han-plugin.md) is the end-user view of the same plugin split, for deciding which one to install rather than how to build on it.

## Related Documentation

- [Plugin landing page](../../README.md). Where the Han suite starts, and where the install commands live.
- [How-to index](./README.md). The rest of the end-to-end guides.
- [Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md). The hands-on companion to this conceptual guide.
- [plugin.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md). The full manifest schema, including the `dependencies` field.
- [marketplace.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/marketplace-json-options.md). The marketplace schema, including cross-marketplace settings.
- [Choosing a Han plugin](../choosing-a-han-plugin.md). The end-user view of the same plugin split.
- [Claude Code: plugin dependencies](https://code.claude.com/docs/en/plugin-dependencies). The canonical reference for resolution, versioning, and cross-marketplace trust.
