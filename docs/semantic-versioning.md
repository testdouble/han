# Semantic Versioning for Plugins

Plugin versions in `plugin.json` follow [semantic versioning](https://semver.org/). Claude Code and other agents rely on the `version` field (kept in sync with the plugin's entry in `marketplace.json`) to detect that updates are available. Incorrect or stale versions mean agents won't know a plugin has changed, and users won't receive updates.

## Major Version (X.0.0): Breaking Changes

Bump the major version when the update would break existing users' expectations or workflows.

Examples:

- Skill rewrites that fundamentally change behavior or output format.
- Removing a skill from a plugin.
- Renaming a skill (breaks existing `/skill-name` invocations).
- Major behavior changes that would surprise existing users (for example, a review skill that now auto-posts instead of showing a draft).

## Minor Version (x.Y.0): Backwards-Compatible Additions

Bump the minor version when adding new functionality that doesn't change existing behavior.

Examples:

- Adding a new skill to a plugin (new file, no existing files changed).
- Adding a new `references/` file to an existing skill.
- Adding new optional capabilities to an existing skill without changing existing behavior.

## Patch Version (x.y.Z): Bug Fixes

Bump the patch version for fixes that don't change behavior from the user's perspective.

Examples:

- Fixing a typo in a skill description or prompt.
- Fixing a broken context injection command.
- Adjusting `allowed-tools` to fix permission issues.
- Updating a script to handle an edge case.

## One Bump Per Branch

**The rule:** a plugin's version bumps **exactly once per unmerged branch**. Additional changes on the same branch do not add further bumps, unless a later change escalates to a higher semver octet. In which case the bump is **recalculated from the branch's baseline**, not stacked on top of the previous bump.

The priority order is **major > minor > patch**. The baseline is whatever version of the plugin is on `main` at the point the branch diverged (or, for a branch that renames or resets a plugin, the reset version established on the branch. See "Plugin rename or reset" below).

### How to apply the rule

1. **First change on the branch:** bump the version for that change (patch, minor, or major) from the baseline.
2. **Subsequent same-or-lower-priority changes:** leave the version alone. The existing bump already covers them.
3. **Subsequent higher-priority change:** re-bump **from the baseline**, using the new level. Reset lower segments as semver requires (a minor bump resets patch to 0; a major bump resets both minor and patch to 0). Do not stack.

### Examples

Assume `main` is at **v1.0.0** in every example below.

**Example 1: Multiple same-priority changes**

| Step | Change | Version | Why |
|------|--------|---------|-----|
| 1 | Fix a typo (patch) | **v1.0.1** | First change on the branch. Patch bump from baseline. |
| 2 | Fix another typo (patch) | **v1.0.1** | Same priority as step 1. No additional bump. |
| 3 | Fix a third typo (patch) | **v1.0.1** | Still the one patch bump. No additional bump. |

**Example 2: Escalation through priorities**

| Step | Change | Version | Why |
|------|--------|---------|-----|
| 1 | Fix a typo (patch) | **v1.0.1** | Patch bump from baseline. |
| 2 | Fix another typo (patch) | **v1.0.1** | Same priority. No additional bump. |
| 3 | Add a new skill (minor) | **v1.1.0** | Higher priority. Re-bump from baseline as minor, absorbs the patch. |
| 4 | Add another new skill (minor) | **v1.1.0** | Same priority as step 3. No additional bump. |
| 5 | Remove an existing skill (major) | **v2.0.0** | Higher priority. Re-bump from baseline as major, absorbs minor and patch. |

The final version merged to `main` is **v2.0.0**, not v2.1.1 or v1.1.1.

### Plugin rename or reset

If a branch renames a plugin, splits one plugin into two, or otherwise resets a plugin's version baseline to a new value (for example, setting a renamed plugin to **v1.0.0** as the start of its new identity), the reset **is** the branch's one bump. It carries the effective weight of a major change. Subsequent changes on the same branch (new skills, bug fixes, removals) do not bump further, because no change can escalate higher than the reset.

For example, if a branch renames `foo` to `bar` and sets `bar`'s version to **v1.0.0**, then adding a new skill to `bar` on the same branch does **not** bump to v1.1.0. The version stays at **v1.0.0**. The rename/reset already covers the branch's change set.

After bumping (or not bumping), sync the current `plugin.json` version to that plugin's entry in `marketplace.json`.

## Suite Versioning: Parent and Child Plugins

Han ships as a suite: a parent meta-plugin (`han`) plus child plugins (`han.core`, `han.github`, `han.reporting`, `han.feedback`, and any future `han.*` extension). The parent has no skills or agents of its own; it installs its **bundled** children (`han.core`, `han.github`, `han.reporting`) through its `dependencies`. Not every child is bundled: `han.feedback` ships in the same marketplace and depends on `han.core`, but the parent deliberately does not depend on it, so it is opt-in and installed on its own. Each plugin carries its own independent version line, and the git tag for a release tracks the **parent** version (the release `vX.Y.Z` is the parent `han` version).

Three rules govern how a release versions the suite:

1. **The parent always bumps on every release.** Every release is a release of the suite, so the parent `han` version increments even when only a single child changed. The parent's bump level is the highest level across the whole release: if any bundled child has a major change (or a bundled child was removed from the parent's `dependencies`), the parent is major; if a bundled child has a minor change or a brand-new bundled child plugin is introduced, the parent is at least minor; otherwise (only child patches or repo-level doc and config fixes) the parent is patch. A change reaches the parent because anyone who installed the meta-plugin receives that child. An opt-in child the parent does not depend on (such as `han.feedback`) does not by itself force a parent minor or major bump, because installing `han` never delivers it; its own changes still bump its own version line, and the release that introduces it still bumps the parent at least patch like any other release.

2. **A child bumps only when its own directory changed.** Apply the major/minor/patch rules above to the changes inside that child's own directory (`han.core/`, `han.github/`, and so on). A child with no changes in a release keeps its version. Children version independently of each other: `han.github` going to `2.0.0` says nothing about `han.core`, which stays wherever its own changes put it.

3. **A brand-new plugin is not bumped by the release that introduces it.** When a new `han.*` plugin first appears, the version in its `plugin.json` is its established baseline (normally `1.0.0`). It does not increment as part of the release that adds it; the introduction itself is the baseline, the same way a rename or reset (above) is its own branch's one bump. This is the general rule for every future extension, so the numbering for each new plugin starts consistently.

Repo-root changes that do not live inside any plugin directory (`docs/`, `README.md`, `CONTRIBUTING.md`) are suite-level: they count toward the parent's bump level (normally patch) and never bump a child.

### Example: a release that touches one child

`main` is at parent `han` v3.0.0, `han.core` v1.0.0, `han.github` v1.0.0, `han.reporting` v1.0.0, `han.feedback` v1.0.0. A branch adds one new skill to `han.github` and fixes a typo in a `han.core` prompt.

| Plugin | Change | New version | Why |
|--------|--------|-------------|-----|
| `han.github` | New skill (minor) | **v1.1.0** | Minor bump from its own baseline. |
| `han.core` | Typo fix (patch) | **v1.0.1** | Patch bump from its own baseline. |
| `han.reporting` | None | **v1.0.0** | Unchanged, no bump. |
| `han.feedback` | None | **v1.0.0** | Unchanged, no bump. |
| `han` (parent) | Suite release | **v3.1.0** | Always bumps; highest child level is minor, so the parent is minor. |

The release is tagged `v3.1.0` (the parent version). The changelog records each changed plugin under its own sub-heading with its new version.

### A note on per-plugin tags and version constraints

Claude Code resolves a *version-constrained* dependency (a `dependencies` entry that pins a semver range, like `{ "name": "han.core", "version": "~2.1.0" }`) using per-plugin git tags named `{plugin-name}--v{version}`, for example `han.core--v2.1.0`. The `claude plugin tag --push` command creates these. Han does **not** need them today: every dependency in `han`'s and `han.feedback`'s `plugin.json` is a bare string with no version range, so dependencies float to whatever the marketplace serves and the single suite tag `vX.Y.Z` is sufficient. If a future `han.*` plugin ever pins a dependency to a version range, the matching `{plugin-name}--v{version}` tags become required for resolution. See the [Plugin Dependencies docs](https://code.claude.com/docs/en/plugin-dependencies).

## Summary Checklist

1. **One version bump per branch.** The first change bumps the version from the baseline on `main` (or from a reset baseline established on the branch).
2. **Subsequent same-or-lower-priority changes do not bump.** The existing bump already covers them.
3. **Higher-priority changes re-bump from the baseline.** Do not stack bumps. A minor change followed by a major change ends at **v2.0.0**, not v2.1.0 or v2.1.1.
4. **Major:** breaking changes, removals, renames, behavior surprises.
5. **Minor:** new skills, new files, new optional capabilities.
6. **Patch:** typo fixes, permission fixes, edge case handling.
7. **Plugin rename or reset** is itself the branch's one bump. No further bumps on that branch.
8. **Suite rule:** the parent `han` plugin always bumps on every release (at the highest level across the release); a child bumps only when its own directory changed; a brand-new plugin keeps its baseline version for the release that introduces it.
9. Sync each bumped plugin's version to its `marketplace.json` entry after bumping.
10. When in doubt, bump minor. It signals "something new" without implying breakage.

Cross-reference: [Context Injection Commands](../han.plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md) | [allowed-tools: AskUserQuestion](../han.plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md)
