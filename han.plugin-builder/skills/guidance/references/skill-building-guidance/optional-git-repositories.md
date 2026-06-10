---
paths:
  - "**/skills/**/*.md"
---

# Optional Git Repositories

Skills that analyze code should treat git as optional. Hard-requiring git breaks skills in common, legitimate scenarios — and the moments when git is *not* fully set up are often the most valuable times to run an analysis skill.

## Why Git Should Be Optional

**Hard-requiring git breaks valid use cases:**
- Fresh checkouts with no remote configured (`origin/HEAD` does not exist)
- Detached HEAD states (CI environments, `git checkout <sha>`)
- Non-git project directories (scripts, notebooks, local experiments)
- Users who want to analyze specific files without regard to branch history

**Uncommitted changes are the most valuable analysis target.** Code exists locally before it is committed. The user most wants guidance *now*, while they can still act on it easily, not after pushing. A skill that requires committed changes forces the user to commit first — inverting the natural workflow.

**Untracked files are real in-progress work.** New files not yet staged are part of the same logical change. Excluding them produces an incomplete picture of what the user is actually working on.

**Making git optional maximizes when a skill is useful** without forcing users to commit, stage, or push work before they can benefit from it.

## Three Git Execution Modes

Every analysis skill should recognize three distinct execution modes:

| Mode | Condition | Scope source |
|------|-----------|-------------|
| **Mode A: Full git** | git available, remote exists, branch has committed changes | `git diff {default-branch}...HEAD` |
| **Mode B: Uncommitted changes** | git available, but no committed branch diff | `git diff` (unstaged) + `git diff --cached` (staged) + `git status --short` (untracked) |
| **Mode C: No git / no changes** | git missing, not in a repo, or no changes found in any state | User-provided paths, or Glob discovery with confirmation |

### Why Mode B Specifically Matters

Without Mode B, a skill invoked in a git repo with uncommitted work falls through to Mode C and asks the user to confirm scope — even though the changes are fully detectable. This is unnecessary friction that makes the skill feel broken in a common workflow state.

Mode B recovers uncommitted and untracked files automatically. The user gets the same seamless experience as Mode A, just scoped to their local working state rather than their branch history.

## Priority Rule: User-Provided Arguments Always Win

If the user supplies file paths, directories, or a description of what to analyze, use those as scope **regardless of which git mode is active**. The git modes exist to provide automatic scope when the user does not supply it. Never override explicit user input with git-detected scope.

## Detection Architecture

Detection happens in two layers:

**Layer 1 — Detection script** (runs first): Determines whether git is available and whether the current branch has committed changes against the default branch. Emits structured output with `git-available`, `branch`, `default-branch`, and either a `changed-files-start`/`changed-files-end` block or `changed-files: none`. This script only distinguishes Mode A from non-Mode-A; it does not check for uncommitted changes.

**Layer 2 — Skill body** (runs after the script): If the script reports `git-available: true` but `changed-files: none`, the skill body runs `git diff`, `git diff --cached`, and `git status --short` to check for uncommitted or untracked work. If any files are found, that is Mode B. If none are found, fall through to Mode C.

See [`graceful-degradation.md`](./graceful-degradation.md) for the detection script pattern and implementation rules, including a worked example of a detection script in a skill's `scripts/` directory.
