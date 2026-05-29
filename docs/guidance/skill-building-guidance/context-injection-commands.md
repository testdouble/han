---
paths:
  - "han.core/skills/**/*.md"
  - "han.github/skills/**/*.md"
---

# Context Injection Commands in Skill Files

Context injection commands use the `` !`command` `` syntax to execute a shell command at skill load time and inject its stdout into the skill as runtime context. The command runs **once when the skill loads**, not during each step. This gives skill steps access to dynamic information about the current environment without hardcoding values.

## Syntax

Format: `` - label: !`command` ``

Multiple commands per line: `` - Git user: !`git config user.name` (!`git config user.email`) ``

Several Han plugin skills use this pattern, including `code-review`, `architectural-decision-record`, `coding-standard`, `update-pr-description`, `post-code-review-to-pr`, `investigate`, `iterative-plan-review`, `project-discovery`, `project-documentation`, and `test-planning`.

## When to Use

**Use when:** skill steps need runtime information — git state, user identity, project structure, tool availability.

**Don't use when:** the skill is procedural or content-focused and doesn't need environment-specific context. Skills like `investigation`, `brand-messaging`, `writing-style`, and `business-todd-value-coach` have no context injection commands because their steps don't depend on runtime environment details.

## Section Placement

Context injection commands belong in one of two sections:

1. **`## Pre-requisites`** — tool availability checks that gate execution. If a required tool is missing, the skill should inform the user and stop immediately.
2. **`## Project Context`** — runtime information used by step logic (git state, file structure, user identity).

Do not duplicate commands across both sections. Commit `dcf36e7` removed a duplicate gh CLI availability check from `update-pr-description` that appeared in both Pre-requisites and Project Context.

## Command Guidelines

### Rule: Keep commands simple — single commands only

Context injection commands must be simple, single commands. No pipes, redirects, subcommand substitution, or chained operations. These patterns caused repeated execution failures and permissions issues.

**Evidence of failures from commit history:**

| Commit | Message | What Failed |
|--------|---------|-------------|
| `f043634` | "determine default branch dynamically" | Introduced `` !`export DEFAULT_BRANCH=$(git symbolic-ref ...) && echo $DEFAULT_BRANCH` `` with subcommand substitution + chaining |
| `09a44aa` | "hopefully fixing the permissions issue while using default branch" | Removed the above, replaced with `origin/HEAD` refs — the subcommand/pipe approach never worked |
| `a11a481` | reworked gh-pr-review | Had `` !`git symbolic-ref ... \| sed 's@^refs/remotes/@@'` `` with pipe to sed |
| `48b1d30` | "working on task execution fixes to avoid permissions issues" | Replaced piped sed with `--short` flag |
| `917f8c4` | "another round of attempted fixes. i don't trust claude, anymore" | Removed remaining `2>/dev/null` redirects, split combined `Bash()` entries |
| `2ade936` | "yet again, claude is broken and can't even follow it's own documentation or standards" | Replaced `ls` commands with `find` |

**Before (all removed due to failures):**
```
!`export DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | cut -d '/' -f4-) && echo $DEFAULT_BRANCH`
!`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/@@'`
!`git config user.name 2>/dev/null || echo "UNKNOWN"`
!`find . -maxdepth 3 ... 2>/dev/null | head -10`
!`test -f Makefile && echo "yes" || echo "no"`
```

**After (current, working):**
```
!`git symbolic-ref --short refs/remotes/origin/HEAD`
!`git config user.name`
!`find . -maxdepth 3 ...`
!`find . -maxdepth 1 -name "Makefile" -type f`
```

### Rule: Use shell scripts for complex operations

When a task requires pipes, redirects, subcommand substitution, JSON construction, or multi-step logic, extract it into a shell script and call the script from skill steps (not from context injection).

**Evidence:** Commit `c50fd4e` ("extracting script files from skill.md") replaced inline heredoc/pipe commands in `gh-pr-review/SKILL.md` with two shell scripts.

**Before (inline in SKILL.md, caused failures):**
```
gh api repos/{owner}/{repo}/pulls/{number}/reviews --method POST --input - <<'REVIEW_JSON'
{
  "commit_id": "{head_sha}",
  "event": "{event_type}",
  "body": "{review_body}"
}
REVIEW_JSON
```

**After (extracted to shell scripts):**
- `scripts/pr-metadata.sh` — gathers PR metadata using `gh`, `jq`, pipes, and subcommands
- `scripts/post-pr-review.sh` — builds JSON payload with `jq` and posts via `gh api` with pipe
- `scripts/post-pr-comment.sh` — posts review as a PR comment via `gh pr comment` (for self-authored PRs)

The SKILL.md now references the scripts using `${CLAUDE_SKILL_DIR}` paths:
```
${CLAUDE_SKILL_DIR}/scripts/pr-metadata.sh
${CLAUDE_SKILL_DIR}/scripts/post-pr-review.sh {owner/repo} {pr_number} {head_sha} {event_type} {temp_file_path}
```

See also: [Script Execution Instructions](./script-execution-instructions.md) for the full pattern on how to write script invocation steps in SKILL.md.

Shell scripts can safely use pipes, redirects, subcommands, and complex logic because they run as normal bash processes, not through the skill context injection system.

### Rule: Use `which` to check if a tool is installed

Use `which {command}` as the preferred way to determine if an executable tool is installed.

**Evidence:** The current working `post-code-review-to-pr/SKILL.md` uses:
```
- gh CLI: !`which gh`
- jq: !`which jq`
```

`update-pr-description/SKILL.md` previously used `` !`gh --version` `` which also worked but had two problems:
1. It returns more output than needed (full version string vs just a path)
2. If the tool is not installed, running `{command} --version` returns a non-zero exit code, which can cause the skill to exit immediately before it has a chance to inform the user

`which` is preferred because:
- It returns the path if found, or empty output if not — no error exit code
- The skill's Pre-requisites gate logic can then check for empty output and stop gracefully with a user-facing message

### Rule: Use `find` instead of `ls` for file detection

Use `find` with specific flags for file and directory detection. Do not use `ls`.

**Evidence:** Commit `2ade936` replaced all `ls` commands with `find`.

**Before (replaced):**
```
- has Makefile: !`ls Makefile`
- has package.json: !`ls package.json`
- doc directories: !`ls -d docs/ documentation/ doc/`
- CLAUDE.md exists: !`ls CLAUDE.md`
- Project language indicators: !`ls *.go go/ src/ package.json ...`
```

**After (current, working):**
```
- has Makefile: !`find . -maxdepth 1 -name "Makefile" -type f`
- has package.json: !`find . -maxdepth 1 -name "package.json" -type f`
- doc directories: !`find . -maxdepth 1 -type d \( -name "docs" -o -name "documentation" -o -name "doc" \)`
- CLAUDE.md exists: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- Project language indicators: !`find . -maxdepth 1 \( -type f \( -name "*.go" -o -name "package.json" ... \) -o -type d \( -name "go" -o -name "src" \) \)`
```

`find` is more reliable because:
- It doesn't fail with exit code 2 when files don't exist (unlike `ls`)
- `-maxdepth` controls search scope explicitly
- `-type f` and `-type d` distinguish files from directories
- `-name` with `-o` handles multiple patterns cleanly

### Rule: Never use the literal bang-backtick syntax in SKILL.md prose

The skill loader scans the **raw text** of the SKILL.md body for context injection patterns. Markdown escaping — double backticks, inline code spans, fenced code blocks — does **not** prevent parsing. If the literal pattern appears anywhere in the SKILL.md body, even as a documentation example or description, the loader will extract it and attempt to execute the command inside.

**Evidence:** The `script-extraction` skill's SKILL.md contained the literal pattern in a bullet point describing operation types to inventory. The loader parsed it as an actual command and failed with: `Shell command permission check failed for pattern "!`command`": This command requires approval`.

**When you need to reference context injection syntax in a SKILL.md body** (e.g., when a skill analyzes other skills), describe the concept without the literal pattern:

**Before (broken — loader executes `command`):**
```markdown
- A context injection command (`` !`command` `` syntax)
```

**After (correct — describes the concept safely):**
```markdown
- A context injection command (bang-backtick syntax for runtime context)
```

**Reference files are safe.** Files in `references/` are not parsed by the skill loader, so they can contain the literal pattern for documentation purposes.

## What NOT to Use in Context Injection

| Pattern | Example | Why It Fails |
|---------|---------|--------------|
| Pipes | `command \| sed ...` | Permissions/execution failures |
| Redirects | `command 2>/dev/null` | Unnecessary; empty output is valid |
| Subcommand substitution | `$(command)` | Permissions/execution failures |
| Chained commands | `cmd1 && cmd2` | Permissions/execution failures |
| Fallback defaults | `command \|\| echo "X"` | Use empty checks in step logic instead |
| Output limiting | `command \| head -N` | Let full output inject |
| `ls` for detection | `ls filename` | Use `find` instead; `ls` fails on missing files |
| Heredocs | `<<'EOF' ... EOF` | Extract to shell scripts |
| Complex inline logic | `test -f X && echo Y \|\| echo N` | Use `find` for detection instead |
| Literal syntax in prose | Showing the bang-backtick pattern as an example | Loader parses raw text; use "bang-backtick syntax" instead |

## Referencing Injected Context in Steps

1. **Refer to the label** — "If `default branch` is empty" (see `update-pr-description/SKILL.md` Step 1)
2. **Handle empty output** — check for emptiness, ask user or skip (see `architectural-decision-record/SKILL.md` Step 2: "If git user or email is **empty**")
3. **Pre-requisite gates** — if tool not found, inform user and stop immediately (see `post-code-review-to-pr/SKILL.md` Pre-requisites)

## Relationship to `allowed-tools`

Each Bash command pattern must be a separate `Bash()` entry in the `allowed-tools` frontmatter.

**Evidence from commit `917f8c4`:**

```
# Before (broken):
allowed-tools: Bash(date *, git config *, whoami, ls *, mkdir *)

# After (correct):
allowed-tools: Bash(date *), Bash(git config *), Bash(whoami), Bash(mkdir *), Bash(find *)
```

See also: [allowed-tools: AskUserQuestion](./allowed-tools-AskUserQuestion.md) for another `allowed-tools` constraint.

## Command Categories Quick Reference

Real examples organized by purpose, with source file references:

**Git state:**
- `` !`git branch --show-current` `` — current branch (`update-pr-description`, `post-code-review-to-pr`)
- `` !`git symbolic-ref --short refs/remotes/origin/HEAD` `` — default branch (`update-pr-description`, `post-code-review-to-pr`)
- `` !`git log origin/HEAD..HEAD --oneline` `` — branch summary (`update-pr-description`)
- `` !`git diff origin/HEAD...HEAD --stat` `` — branch stats (`update-pr-description`)
- `` !`git diff origin/HEAD...HEAD` `` — branch changes (`update-pr-description`)

**Git diffs/logs (via gh CLI):**
- `` !`gh pr diff --name-only` `` — PR changed files (`post-code-review-to-pr`)

**User identity:**
- `` !`git config user.name` `` — git user name (`architectural-decision-record`, `coding-standard`, `project-documentation`)
- `` !`git config user.email` `` — git user email (`architectural-decision-record`, `coding-standard`, `project-documentation`)
- `` !`whoami` `` — OS username (`architectural-decision-record`, `coding-standard`, `project-documentation`)

**File/directory discovery:**
- `` !`find . -maxdepth 1 -name "CLAUDE.md" -type f` `` — check for file (`code-review`, `coding-standard`, `architectural-decision-record`, `investigate`, `iterative-plan-review`, `project-discovery`, `project-documentation`, `test-planning`)
- `` !`find . -maxdepth 1 -name "AGENTS.md" -type f` `` — check for file (`coding-standard`, `project-discovery`)
- `` !`find . -maxdepth 1 -name "README*" -type f` `` — check for file (`project-discovery`)
- `` !`find . -maxdepth 3 -name "project-discovery.md" -type f` `` — find discovery output (`code-review`, `coding-standard`, `architectural-decision-record`, `investigate`, `iterative-plan-review`, `project-documentation`, `test-planning`)
- `` !`find . -maxdepth 4 -type d -path "*/.claude/rules/coding-standards"` `` — check for path-scoped rules directory (`coding-standard`)

**Tool availability:**
- `` !`which gh` `` — check for gh CLI (`update-pr-description`, `post-code-review-to-pr`)
- `` !`which jq` `` — check for jq (`post-code-review-to-pr`)
- `` !`which git` `` — check for git (`code-review`)

## Summary Checklist

1. Use `` !`command` `` in `## Pre-requisites` or `## Project Context`
2. Single commands only — no pipes, redirects, subcommands, or chaining
3. Use `which {command}` for tool availability checks
4. Use `find` for file/directory detection, not `ls`
5. Extract complex operations into shell scripts
6. Handle empty output in step logic — do not use `2>/dev/null`, `|| echo`, or `| head`
7. Do not duplicate commands across sections
8. Use separate `Bash()` entries in `allowed-tools`
9. Never use the literal bang-backtick pattern in SKILL.md prose — the loader parses raw text regardless of markdown escaping
