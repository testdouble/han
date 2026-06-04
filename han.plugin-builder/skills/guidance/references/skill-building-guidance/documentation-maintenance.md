---
paths:
  - "**/skills/**/*.md"
---

# Documentation Maintenance

A skill that worked last month can silently degrade if its SKILL.md or references describe things that have changed. The model follows stale instructions faithfully — stale documentation is active poison, not passive neglect.

A team once spent three days debugging ESLint violations where an agent consistently used `Array<T>` instead of the enforced `T[]`. The root cause was a buried markdown file that said "Prefer `Array<T>` for readability." The agent read and faithfully followed the stale instruction. The symptom looked like a model failure, but it was a documentation failure.

This guide covers when and how to audit skills so their documentation matches reality.

## The Rules

### Rule: Treat doc-code contradictions as functional bugs

When SKILL.md references a file path that no longer exists, a tool flag that was renamed, or a convention that was abandoned, the model follows the stale instruction. The symptom is structurally correct but factually wrong output — it looks like a model failure but is actually a documentation failure. Triage these with the same severity as a broken shell script.

**Before (stale script reference):**
```markdown
## Step 5: Post Review

Run `scripts/post-review.sh {owner/repo} {pr_number}` to post the review.
```
The script was renamed to `scripts/submit-review.sh` two months ago. The model tries to run the old name, fails, and either halts or invents a workaround.

**After (updated reference):**
```markdown
## Step 5: Post Review

Run `scripts/submit-review.sh {owner/repo} {pr_number}` to post the review.
```

**Before (stale convention in references/):**

`references/coding-conventions.md`:
```markdown
## Date Handling

Use Moment.js for all date parsing and formatting:
- `moment(dateString).format('YYYY-MM-DD')`
- `moment().add(7, 'days')`
```
The project migrated to date-fns six months ago. The model reads this reference and generates Moment.js code.

**After (updated reference):**

`references/coding-conventions.md`:
```markdown
## Date Handling

Use date-fns for all date parsing and formatting:
- `format(parseISO(dateString), 'yyyy-MM-dd')`
- `addDays(new Date(), 7)`
```

### Rule: Audit SKILL.md when its dependencies change

The following changes should trigger a review of any skill that depends on them:

- A referenced script (`scripts/`) was modified or renamed
- A referenced file (`references/`) was updated
- An external tool the skill calls (gh CLI, jq, etc.) released a breaking change
- Project conventions the skill enforces were updated
- The skill's functional tests start failing intermittently — this is often a signal that reality has drifted from what the skill describes

This is a manual discipline. The triggers above tell you *when* to look. When a trigger fires, read the SKILL.md and its references end-to-end, checking every file path, tool flag, and convention reference against the current state.

### Rule: Audit references/ against source truth

For each reference file, identify what it describes: a codebase convention, an external standard, a tool's API, a style guide. When that source changes, the reference must be updated or it becomes a poisoned few-shot example the model will faithfully reproduce.

Questions to ask during an audit:
- Does the reference describe the current state of the codebase, or a past state?
- Do code examples in the reference use the same libraries, patterns, and APIs the project currently uses?
- Are file paths in the reference still valid?
- Are tool flags and CLI options still supported by the current tool version?

### Rule: Version documentation with the code it describes

When a PR changes a script in `scripts/`, renames a reference file, or updates a convention that a skill enforces, the corresponding SKILL.md or reference update belongs in the same commit. This prevents a drift window where code has changed but documentation has not yet caught up — exactly the gap that causes the failures described in the rules above.

This is the proactive complement to the reactive audit triggers. Audits catch drift after it happens; co-versioning prevents it from happening.

**Before (code and docs updated separately):**
```
commit a1b2c3: Rename scripts/post-review.sh → scripts/submit-review.sh
commit d4e5f6: (three days later) Update SKILL.md to reference submit-review.sh
```
For three days, the skill references a script that doesn't exist.

**After (code and docs updated together):**
```
commit a1b2c3: Rename scripts/post-review.sh → scripts/submit-review.sh
              Update SKILL.md to reference submit-review.sh
```
No drift window. The documentation is never wrong.

## Summary Checklist

1. Treat doc-code contradictions as functional bugs — triage with the same severity as broken scripts
2. Audit SKILL.md when referenced scripts, reference files, external tools, or project conventions change
3. Audit `references/` against the current state of what they describe
4. Version documentation changes in the same commit as the code changes they describe
5. When a skill's functional tests fail intermittently, check for stale documentation before debugging the skill logic

Cross-references:
- [Troubleshooting](./troubleshooting.md) — Cause 4 under "Instructions Not Followed" covers stale documentation as a symptom
- [Skill Reference Files](./skill-reference-files.md) — Placement and purpose of reference documents
- [Success Criteria and Testing](./success-criteria-and-testing.md) — Functional tests that can surface documentation drift
- [Context Hygiene](./context-hygiene.md) — Why stale tokens actively degrade model performance
