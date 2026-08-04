# Scope Boundary: Per-Plugin Release Tags

## Work Item

GitHub issue [testdouble/han#162](https://github.com/testdouble/han/issues/162), "Use `claude plugin tag --push` to tag
new releases", opened by [@taminomara](https://github.com/taminomara). Read via `gh issue view 162 --repo testdouble/han`
on 2026-08-04. The issue has no comments. Its body text is quoted verbatim below.

## Stated Scope

> Just learned that Claude can resolve specific plugin versions by git tags if they follow specific pattern:
> `{name}--v{version}`. Let's switch to this tagging schema since v5?
>
> More info: https://code.claude.com/docs/en/plugin-dependencies#tag-plugin-releases-for-version-resolution

The issue title states the mechanism: "Use `claude plugin tag --push` to tag new releases".

## Stated Exclusions

`None stated`.

## Operator-Stated Scope

> for https://github.com/testdouble/han/issues/162 - specifically updating the `/han-release` skill in this repository

This narrows the work item to the `/han-release` skill (`.claude/skills/han-release/`) and what that skill must do
differently. Changes to other repository surfaces are in scope only where the skill's behavior depends on them.

## Direction of Travel

**Answered.** The single suite-wide `vX.Y.Z` tag is being **replaced**, not kept alongside the per-plugin tags. The
operator's words:

> go with the second option - replace vX.Y.Z with han--vX.Y.Z

The `vX.Y.Z` naming is therefore deprecated for new releases. Per
[`scope-justification-rule.md`](../../../../han-planning/references/scope-justification-rule.md), a recorded deprecation
is treated the same way a stated exclusion is treated: no commitment in this plan may preserve, extend, or dual-write the
`vX.Y.Z` scheme for a new release.

Tags `v2.1.0` through `v4.6.0` already exist in the repository and are addressed by published GitHub releases. The
deprecation governs what new releases create; it does not direct the removal of existing tags.

## Visual Material Received

`None received`.

## Record Provenance

Established by `han-planning:plan-a-feature` on 2026-08-04. Not inherited from another folder. No conflicting record was
found.
