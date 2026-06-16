---
paths:
  - "**/skills/**/*.md"
  - "**/skills/**/scripts/**"
---

# Graceful Degradation

**Differentiation from `dynamic-project-discovery.md`:** That doc covers hard prerequisites — tools or capabilities the skill cannot function without at all; when they're missing, the skill stops with a message to the user. This doc covers *partial context* — situations where the environment is usable but some data (a git history, project config, docs directory) is absent. Graceful degradation means detecting what is available, selecting a named execution mode, and continuing to produce useful output.

## The Rules

### Rule: Detect environment state with a script, then branch to a named mode

Without this rule, skills that assume git is always present hard-fail when invoked on new codebases, local files, or non-git directories. The user sees an error exit instead of a useful result.

Use a shell script to detect git availability and environment state. The script emits structured `key: value` pairs and exits 0 in all code paths. The skill reads the output and routes to a named mode based on what is available.

**Detection script requirements:**

- Must exit 0 in all cases — not just the success path
- Use `command -v git` to check for git availability, not `git --version`
- Emit structured key-value output that the skill can parse

**Named mode pattern:**

Define modes explicitly by name so the skill body and review output can reference them clearly:

- **Mode A: Full context** — all expected tools and data are available; use the richest analysis path
- **Mode B: Partial context** — the tool is available but the expected data state is absent (e.g., git is installed but no branch changes exist); adapt scope accordingly
- **Mode C: Minimal context** — the tool is absent or no structured data is available; fall back to user-specified or discovered inputs

**Before (broken outside git):**
```markdown
## Step 1: Identify Changes

Run `git diff origin/HEAD...HEAD` to get the list of changed files.
```
This fails with an error if the skill is invoked outside a git repository, stopping the workflow entirely.

**After (mode-branching):**
```markdown
## Step 1: Identify Changes

Run `${CLAUDE_SKILL_DIR}/scripts/detect-review-context.sh` to detect the git environment. Use the output to determine the review mode.

**Mode A: Full git context** — script reports `git-available: true` and changed files list has content.
- Use the changed files list as review scope; run `git diff {default-branch}...HEAD` for the full diff.

**Mode B: Git but no branch changes** — script reports `git-available: true` but `changed-files: none`.
- Check unstaged and staged changes; use those files as review scope.

**Mode C: No git / no changes found**
- Use user-provided file paths or discover source files with Glob.
```
The detection script (`detect-review-context.sh` here) lives in the skill's `scripts/` directory; the SKILL.md body reads its structured output and routes to the named mode.

---

### Rule: Apply conventional defaults for directory keys when config is absent

When a skill needs project config (docs directory, ADR directory, etc.), it reads CLAUDE.md's `## Project Discovery` section and falls back to project-discovery.md. For directory keys not found in either source, check conventional defaults with Glob — but only use the default if the directory actually exists.

**Conventional defaults (use only if directory exists):**

- docs directory -> `docs/`
- ADR directory -> `docs/adr/`
- coding standards directory -> `docs/coding-standards/`

**Keys with no sensible default (skip if absent):**

- test command, lint command, build command
- language, framework
- non-standard paths

Skills discover config inline (context injection + Read) rather than calling a data-fetch sub-skill. This avoids the early-exit failure mode documented in `writing-effective-instructions.md`.

---

## Summary Checklist

1. Use a shell script for environment detection — not inline shell commands in the skill body
2. Detection script exits 0 in all code paths (git not installed, not in a work tree, normal operation)
3. Name execution modes explicitly (Mode A, Mode B, Mode C) and route to them by name
4. Apply conventional defaults for well-known directory keys when the directory exists on disk
5. Skip keys with no sensible conventional default (commands, language, framework) when absent

---

Cross-references:
- [Dynamic Project Discovery](./dynamic-project-discovery.md) — Hard prerequisites: detect tool absence and stop with a message
- [Skill Composition](./skill-composition.md) — `context: fork` for data-fetch sub-skills
- [Script Execution Instructions](./script-execution-instructions.md) — How to invoke detection scripts from SKILL.md
- [Graceful Degradation (agents)](../agent-building-guidelines/graceful-degradation.md) — Agent-side skip patterns when tools are unavailable
