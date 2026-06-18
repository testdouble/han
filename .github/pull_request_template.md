<!--
This is the default PR template. Before requesting review, replace this
content with a generated PR description by running the
/update-pr-description skill in Claude Code. See:
https://github.com/testdouble/han/blob/main/docs/skills/update-pr-description.md
-->

## Before requesting review

Work through this checklist before marking the PR ready. Leave it in the PR body while drafting; remove it once `/update-pr-description` has written the final description.

**Do not bump the plugin version and do not edit `CHANGELOG.md` in this PR.** Both are handled by the `/han-release` skill when a release is cut. If your branch contains version or changelog changes, revert them before requesting review.

### Review the changes against project guidance

- [ ] Read [CONTRIBUTING.md](../CONTRIBUTING.md) and confirm the changes follow the rules for the entity being touched (skill, agent, long-form doc, index, template).
- [ ] Walk the [self-review checklist in CONTRIBUTING.md](../CONTRIBUTING.md#reviewing-your-own-changes): frontmatter validity, `allowed-tools` accuracy, context-injection simplicity, template adherence, index placement, link resolution, voice compliance.
- [ ] Confirm the writing follows [`docs/writing-voice.md`](../docs/writing-voice.md). No em-dashes. No banned words ("actually", "just", "leverage", "utilize", "showcase", "robust" as vague positive, "It's worth noting", "Importantly").
- [ ] If a new skill or agent was added or renamed, confirm the [coverage rule](../docs/templates/coverage-rule.md) is satisfied: long-form doc exists at `docs/skills/{name}.md` or `docs/agents/{name}.md`, and the index in `docs/skills/README.md` or `docs/agents/README.md` has a one-sentence scent line.
- [ ] If a skill or agent was added, removed, or renamed, confirm the indexes ([`docs/skills/README.md`](../docs/skills/README.md), [`docs/agents/README.md`](../docs/agents/README.md)), the [CLAUDE.md](../CLAUDE.md) catalog, and [`docs/concepts.md`](../docs/concepts.md) each list every current entity.
- [ ] If the change touches plugin behavior, run the affected skill or agent locally and confirm it still works end-to-end.
- [ ] If the change affects `plugin/.claude-plugin/plugin.json` or `.claude-plugin/marketplace.json`, confirm both are consistent.

### Refresh the documentation

Run `/han-update-documentation` in Claude Code from this branch. The skill scopes its pass to the entities this branch touched, syncing the long-form docs, indexes, and cross-references with the changes on disk so the PR ships with accurate documentation.

### Generate the PR description

When the checklist above passes, run `/update-pr-description` in Claude Code from this branch. The skill reads the branch's committed changes, drafts a description that surfaces the central mechanism and key files, runs a reviewer-context check, and pushes the result to this PR via `gh pr edit`.

If `/update-pr-description` is unavailable, write the description by hand using the same structure: Summary, Key file changes, Test Plan (omit for docs-only branches).
