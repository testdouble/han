# How To: Build a Plugin That Depends on Han

A walkthrough for standing up a new plugin that depends on `han.core`, adding a skill that builds on Han, and confirming that a clean install pulls Han in alongside it. This is the hands-on companion to [Extend Han with Plugin Dependencies](./extend-han-with-plugin-dependencies.md), which explains the mechanism this guide puts to work.

> See also: [How-to index](./README.md) · [Extend Han with Plugin Dependencies](./extend-han-with-plugin-dependencies.md) · [plugin.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md) · [marketplace.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/marketplace-json-options.md)

`han.github` already does exactly what this guide teaches: it ships GitHub-facing skills and declares `han.core` as a dependency, so installing it pulls core in too. You are about to build the same shape for a plugin of your own. The happy path below builds a plugin that ships inside the Han suite, the way `han.github` does, because that is the proven, in-repo case. When your plugin lives in a marketplace you own instead, the [Variations](#variations) section covers the one extra rule that applies.

## Before you begin

- You have read [Extend Han with Plugin Dependencies](./extend-han-with-plugin-dependencies.md), or you are comfortable with the `dependencies` field and what install and enable do. This guide assumes that model rather than re-explaining it.
- You have a skill (or agent) in mind that builds on Han. The point of depending on `han.core` is to use it: dispatch a core agent, call a core skill as a step, or read a core reference file. If your plugin does not touch Han, it does not need to depend on Han.
- You know where your plugin will ship. The happy path assumes it lives in the Han repository and ships from the Han marketplace. If it ships from a marketplace you own, follow the happy path and then apply the [own-marketplace variation](#your-plugin-ships-from-a-marketplace-you-own).

## What you'll end up with

- A new plugin directory with a `.claude-plugin/plugin.json` that declares `han.core` as a dependency.
- A skill (or agent) under that plugin that builds on a `han.core` skill, agent, or reference.
- A marketplace entry so a reader can install your plugin, and a confirmed clean install that pulls `han.core` in alongside it.

## The happy path

The workflow has four steps, and the order matters: the manifest first, the skill it carries second, the marketplace registration third, and the bundling decision last.

### Step 1: Create the plugin and declare the dependency

Create the plugin directory and its manifest. Name the dependency with a plain string, since core is a sibling in the same marketplace and a plain name is all a same-marketplace dependency needs:

    {
      "name": "han.example",
      "version": "1.0.0",
      "description": "Example extension that builds on han.core.",
      "dependencies": [
        "han.core"
      ]
    }

That single `dependencies` array is the whole mechanism. Installing `han.example` now resolves `han.core`, installs it, and enables it at the same scope.

### Step 2: Add the skill that builds on core

Add the skill (or agent) that does the new work. Put it where Claude Code scans by default, at `han.example/skills/<name>/SKILL.md`. This is the skill that builds on core: it can dispatch a `han.core` agent, call a core skill as a step, or read a core reference file, because installing your plugin guarantees core is present and enabled alongside it.

This is the step where the dependency earns its place. If your skill never reaches into core, the declaration in Step 1 is doing nothing for you, and you should ask whether you needed a dependency at all. The whole reason to depend on `han.core` is so this skill can stand on it.

### Step 3: Register the plugin in the marketplace

Register the plugin so a reader can install it. Add an entry to `.claude-plugin/marketplace.json` with a relative source path, next to the three that are already there:

    { "name": "han.example", "source": "./han.example", "version": "1.0.0" }

A reader installs your plugin with `/plugin install han.example@han`, and Claude Code pulls `han.core` along automatically. The marketplace entry is what makes that install command resolve.

### Step 4: Decide whether to bundle it into the suite

Lastly, decide whether the full `han` suite should carry your plugin. If it should, add its name to the `han` meta-plugin's `dependencies` array. That is the one edit that makes `han.example` part of what `/plugin install han@han` delivers. Leave it out and your plugin is installable on its own but is not bundled into the suite, which is the right choice when it is optional. Most extensions start unbundled and join the suite only once they have earned a place in the default install.

## Confirm it works

You are done when a clean install of your plugin loads both your plugin and the Han plugin it depends on. Check it the way your reader will:

1. From a fresh state, run the install command for your plugin (`/plugin install han.example@han` on the happy path).
2. Read the install output. Claude Code lists what it added, including the dependency it pulled in. Confirm `han.core` is in that list.
3. Run your new skill and confirm the core behavior it builds on is available. If your skill dispatches a `han.core` agent or calls a core skill, exercise that path, not the parts that are yours alone.
4. Disable your plugin and confirm Claude Code enables and disables the dependency along with it, rather than leaving an orphan behind.

If the dependency does not show up in the install output, the most common causes are a misspelled dependency name, a missing marketplace registration, or (on the own-marketplace variation below) a missing `allowCrossMarketplaceDependenciesOn` entry or a marketplace your reader has not added.

## Variations

### Your plugin ships from a marketplace you own

Take this variation when your plugin ships from a marketplace you own, separate from Han's, and you want it to build on `han.core`. Everything from the happy path applies, with one addition: because your plugin and `han.core` now live in different marketplaces, the cross-marketplace rule comes into play, and you have three extra things to get right.

First, declare the dependency as an object that names Han's marketplace, not a plain string. Han's marketplace is named `han`, so:

    {
      "name": "acme-han-extras",
      "version": "1.0.0",
      "description": "Acme's extensions built on han.core.",
      "dependencies": [
        { "name": "han.core", "marketplace": "han" }
      ]
    }

Second, allow the cross-marketplace dependency from your own marketplace. Claude Code refuses to reach into another marketplace unless the marketplace your reader is installing from grants permission. Since your reader installs from your marketplace, the permission goes there: add an `allowCrossMarketplaceDependenciesOn` array to your `marketplace.json` that names Han's marketplace.

    {
      "name": "acme",
      "allowCrossMarketplaceDependenciesOn": ["han"],
      "plugins": [
        { "name": "acme-han-extras", "source": "./acme-han-extras", "version": "1.0.0" }
      ]
    }

Third, tell your reader to add the Han marketplace before installing. Claude Code will not add a marketplace on its own to satisfy a dependency, so a dependency from a marketplace your reader has never added stays unresolved. The install sequence for your reader becomes:

    /plugin marketplace add testdouble/han
    /plugin marketplace add acme/your-marketplace-repo
    /plugin install acme-han-extras@acme

With those three pieces in place, installing your plugin resolves `han.core` from the Han marketplace and installs it alongside your own. A word on scope before you commit to this path: Han is built and maintained for the Han suite's own plugins. Extending it from an outside marketplace works through the standard Claude Code mechanism, but Han does not publish a stability contract for outside dependents, so pin a `version` range on the dependency and re-check it when you upgrade.

### You want to depend on the whole suite, not just core

Depend on `han` instead of `han.core` when your plugin needs the GitHub-facing skills too, not only the core planning and review skills. The declaration is the same shape, with `han` in the `dependencies` array. Be aware that this pulls the entire suite in, so prefer `han.core` when core is all your skill builds on.

## What you should expect

- **The dependency is a load-time guarantee, not a copy.** Installing your plugin installs `han.core`; it does not vendor core's skills into your plugin. Your skill calls into the installed core, so a core update reaches your skill without you republishing.
- **Enabling and disabling move together.** Enabling your plugin enables `han.core` at the same scope, and Claude Code will not let you disable `han.core` while your enabled plugin still depends on it. That is the mechanism protecting your skill from losing the core it stands on.
- **The resolution rules live in the canonical docs.** The full behavior for version resolution, error handling, and pruning is at [code.claude.com/docs/en/plugin-dependencies](https://code.claude.com/docs/en/plugin-dependencies). This guide stays with the parts you need to build a dependent plugin and links out for the rest.

## Where to go next

- [Extend Han with Plugin Dependencies](./extend-han-with-plugin-dependencies.md) is the conceptual guide behind this one, if a step here assumed a mechanism you want spelled out.
- [plugin.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md) is the field-level reference for the manifest you wrote in Step 1, including the [`dependencies`](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md#dependencies) field.
- [marketplace.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/marketplace-json-options.md) covers the marketplace entry from Step 3 and the `allowCrossMarketplaceDependenciesOn` setting from the variation.
- The [skill-building guidance](../../han.plugin-builder/skills/guidance/references/skill-building-guidance/) and [agent-building guidance](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/) cover writing the skill or agent itself, which this guide assumes you can do.

## Related Documentation

- [Plugin landing page](../../README.md). Where the Han suite starts, and where the install commands live.
- [How-to index](./README.md). The rest of the end-to-end guides.
- [Extend Han with Plugin Dependencies](./extend-han-with-plugin-dependencies.md). The conceptual companion that explains the mechanism this guide uses.
- [plugin.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-json-options.md). The full manifest schema, including the `dependencies` field.
- [marketplace.json reference](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/marketplace-json-options.md). The marketplace schema, including cross-marketplace settings.
- [Claude Code: plugin dependencies](https://code.claude.com/docs/en/plugin-dependencies). The canonical reference for resolution, versioning, and cross-marketplace trust.
