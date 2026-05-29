# han

`han` is the meta-plugin for the Han suite. It has no skills or agents of its own. Installing it pulls in the whole suite through its dependencies: [`han.core`](../han.core) (the planning, investigation, review, and documentation skills, plus every agent) and [`han.github`](../han.github) (the GitHub-facing skills). Install this one when you want all of Han in a single step.

For the full description of what Han does and how to use it, start at the [plugin landing page](../README.md).

## Which plugin should you install?

`han` is one of three options. If you want only part of the suite, or you want to understand the `han.core` / `han.github` split before installing, read [Choosing a Han plugin](../docs/choosing-a-han-plugin.md).

## Extending Han

If you want to build on Han or ship something similar that depends on it, read the two extension guides:

- [Extend Han with plugin dependencies](../docs/how-to/extend-han-with-plugin-dependencies.md). How Han uses plugin dependencies to compose its own suite.
- [Build a plugin that depends on Han](../docs/how-to/build-a-plugin-that-depends-on-han.md). How to declare Han as a dependency of your own plugin.
