---
paths:
  - "**/skills/**/*.md"
---

# Dynamic Project Discovery

Skills run in whatever repository the user invokes them from. They must discover the project's structure, branch names, and tool availability dynamically rather than hardcoding assumptions.

## The Rules

### Rule: Never hardcode branch names

Use `origin/HEAD` or `git symbolic-ref --short refs/remotes/origin/HEAD` to discover the default branch. Do not hardcode `main`, `master`, `develop`, or any other branch name.

**Before (broken on non-`main` repos):**
```
git log main..HEAD --oneline
git diff main...HEAD
```
Hardcoded `main` breaks immediately on repos whose default is `develop`, `master`, or any other branch name.

**After (dynamic):**
```
git log origin/HEAD..HEAD --oneline
git diff origin/HEAD...HEAD
```
Using `origin/HEAD` works regardless of the default branch name.

For context injection commands, use:
```
- default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD`
```
This injects the actual default branch name at skill load time.

### Rule: Use `which` (guarded) for tool availability, not `--version`

Check tool availability with `which {command} 2>/dev/null || echo "not installed"` in the Pre-requisites section.

**Before (problematic):**
```
- gh CLI: !`gh --version`
```

**After (correct):**
```
- gh CLI: !`which gh 2>/dev/null || echo "not installed"`
```
A missing tool makes `which` (or `--version`) exit non-zero and print to stderr, which can abort the skill. `2>/dev/null` drops the stderr and `|| echo "not installed"` forces a clean exit plus a sentinel the Pre-requisites logic checks.

### Rule: Discover project structure dynamically

Use `find` to detect directories, files, and language indicators. Do not assume paths like `src/`, `docs/`, or `lib/` exist.

**Examples of dynamic discovery:**
```
- doc directories: !`find . -maxdepth 1 -type d \( -name "docs" -o -name "documentation" -o -name "doc" \)`
- has Makefile: !`find . -maxdepth 1 -name "Makefile" -type f`
- language indicators: !`find . -maxdepth 1 \( -type f \( -name "*.go" -o -name "package.json" -o -name "Cargo.toml" \) -o -type d \( -name "go" -o -name "src" \) \)`
```

These patterns detect what exists without assuming it does. Empty output means the file or directory isn't present, and the skill's step logic can handle that gracefully.

### Rule: Handle missing tools gracefully in Pre-requisites

When a required external tool is missing, the skill should inform the user and stop — not crash with an unhandled error.

**Pattern:**
```markdown
## Pre-requisites

- gh CLI: !`which gh 2>/dev/null || echo "not installed"`
- jq: !`which jq 2>/dev/null || echo "not installed"`

If any of the above read `not installed` (or are empty), inform the user which tool is missing and stop.
```

The Pre-requisites section runs before any substantive steps. If a required tool isn't found, the skill tells the user what to install rather than failing partway through execution.

## Summary Checklist

1. Never hardcode branch names — use `origin/HEAD` or `git symbolic-ref --short refs/remotes/origin/HEAD`
2. Use `which {command} 2>/dev/null || echo "not installed"` for tool availability checks, not `{command} --version`
3. Discover project structure with `find` — don't assume paths exist
4. Gate execution on Pre-requisites and handle empty output gracefully

Cross-reference: [Context Injection Commands](./context-injection-commands.md) for command syntax rules and the `find` vs `ls` guidance.
