# Feature Technical Notes: Publish the Linear Plugin to the Second Channel

## T1: Second channel serves the default branch

- **Context:** The Outcome section promises the fix reaches users at merge time, not when the listing change was
  authored. That timing is only correct because of how the second channel resolves the marketplace.
- **Technical detail:** The Codex channel registers this repository itself as the marketplace
  (`codex plugin marketplace add testdouble/han`) and reads the listing from the repository's default branch. A listing
  entry that exists only on a working branch is invisible to every user until that branch merges to `main`. This is
  external channel behavior, not discoverable from the repo's own code.
- **Supports decisions:** D2
- **Driven by findings:** —
- **Referenced in spec:** Outcome; Edge Cases and Failure Modes; Coordinations
