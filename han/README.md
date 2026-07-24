# han

`han` is the meta-plugin for the Han suite. It ships no skills and no agents of its own. It exists to pull in the
bundled suite in a single step through its dependencies, so installing `han` is how you ask for everything the suite
bundles at once.

**Bundled suite.** Installing `han` brings in `han-communication`, `han-core`, `han-documentation`, `han-research`,
`han-planning`, `han-coding`, `han-github`, and `han-reporting` through its dependencies. It does not bundle the opt-in
plugins (`han-feedback`, `han-atlassian`, `han-linear`, and `han-plugin-builder`); install each of those on its own.

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

## Where to go next

- [Plugin index](../docs/choosing-a-han-plugin.md). Every plugin, what it does, and which one to install.
- [Workflows](../docs/workflows.md). How the skills across the bundled plugins chain together.
- [Repo root](../README.md). The Han suite landing page and the full description of what Han does.

## Extending Han

If you want to build on Han or ship something that depends on it, read the two extension guides:

- [Extend Han with plugin dependencies](../docs/how-to/extend-han-with-plugin-dependencies.md). How Han uses plugin
  dependencies to compose its own suite.
- [Build a plugin that depends on Han](../docs/how-to/build-a-plugin-that-depends-on-han.md). How to declare Han as a
  dependency of your own plugin.
