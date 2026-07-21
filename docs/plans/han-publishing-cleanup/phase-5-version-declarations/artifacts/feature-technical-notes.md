# Feature Technical Notes: Declare the Plugin Versions That Work Together

## T1: How the first channel resolves version statements

- **Context:** The Outcome and Primary Flow promise enforcement (resolved companions, refused conflicts) and the
  preconditions demand markers-before-statements. All of it rests on the channel's resolution mechanics, which are
  external and not discoverable from this repository.
- **Technical detail:** Claude Code plugin `dependencies` entries accept either bare names or
  `{ "name": ..., "version": <semver range> }` objects, with any Node-semver expression (`^`, `~`, `>=`, exact);
  pre-releases are excluded unless the range opts in (e.g. `^2.0.0-0`). The installer resolves a constraint to the
  highest git tag matching the range, in the tag format `{plugin-name}--v{version}`. No matching tag disables the
  dependent plugin with a `no-matching-tag` error. When multiple installed plugins constrain the same dependency, the
  ranges are intersected; an empty intersection fails with `range-conflict`. Auto-update fetches within the
  constrained range rather than the marketplace's latest. Source: official plugin-dependencies documentation
  (code.claude.com/docs/en/plugin-dependencies), fetched 2026-07-21. This repository currently has only suite-level
  `vX.Y.Z` tags, so per-plugin `{name}--v{version}` tags must be backfilled before any constraint lands.
- **Supports decisions:** D2, D4
- **Driven by findings:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Coordinations
