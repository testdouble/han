---
paths:
  - "**/skills/**/*.md"
---

# Context Injection Commands in Skill Files

Context injection commands use the `` !`command` `` syntax to execute a shell command at skill load time and inject its stdout into the skill as runtime context. The command runs **once when the skill loads**, not during each step. This gives skill steps access to dynamic information about the current environment without hardcoding values.

## Syntax

Format: `` - label: !`command` ``

Multiple commands per line: `` - Git user: !`git config user.name` (!`git config user.email`) ``

Many skills use this pattern: code-review skills, documentation skills, PR-description skills, investigation skills, project-discovery skills, and any skill whose steps need to know the current git state or project layout.

## When to Use

**Use when:** skill steps need runtime information — git state, user identity, project structure, tool availability.

**Don't use when:** the skill is procedural or content-focused and doesn't need environment-specific context. A skill whose steps are pure instructions (a writing-style guide, a content checklist, a procedural walkthrough) has no need for context injection commands because its steps don't depend on runtime environment details.

## Section Placement

Context injection commands belong in one of two sections:

1. **`## Pre-requisites`** — tool availability checks that gate execution. If a required tool is missing, the skill should inform the user and stop immediately.
2. **`## Project Context`** — runtime information used by step logic (git state, file structure, user identity).

Do not duplicate commands across both sections. A tool availability check belongs in Pre-requisites only; repeating the same check in Project Context runs the command twice and adds nothing.

## Command Guidelines

### Rule: Keep commands simple — single commands only

Context injection commands must be simple, single commands. No pipes, redirects, subcommand substitution, or chained operations. These patterns cause repeated execution failures and permission prompts.

The reason is structural. The skill loader does not run context injection commands through a full interactive shell. It matches each command against the `allowed-tools` Bash patterns and runs it as a single auto-approved invocation. Anything that turns one command into a compound expression defeats that match:

- **Subcommand substitution** (`$(...)`) and **chaining** (`cmd1 && cmd2`) produce a command string that no single `Bash()` prefix covers, so the loader cannot auto-approve it and the command stalls or fails.
- **Pipes** (`cmd | sed ...`) have the same problem: the piped stage is a second command the prefix match never sees.
- **Redirects** (`2>/dev/null`) are unnecessary. Empty output is a valid result the step logic can check for, so suppressing errors only hides information.

The fix in every case is the same: replace the compound expression with one flag-driven command that returns the value directly. For example, instead of piping `git symbolic-ref` through `sed` to strip a prefix, use the `--short` flag. Instead of substituting a subshell into an `export`, reference `origin/HEAD` directly.

**Before (compound forms that fail):**
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

A common case is posting structured data to an API. Building a JSON payload inline with a heredoc, then piping it to a CLI, mixes heredocs, pipes, and substitution in one command. None of that survives the context injection match.

**Before (inline in SKILL.md, fails):**
```
some-cli api repos/{owner}/{repo}/reviews --method POST --input - <<'REVIEW_JSON'
{
  "commit_id": "{head_sha}",
  "event": "{event_type}",
  "body": "{review_body}"
}
REVIEW_JSON
```

**After (extracted to shell scripts):**
- A `scripts/gather-metadata.sh` that collects what it needs using the CLI, `jq`, pipes, and subcommands
- A `scripts/post-review.sh` that builds the JSON payload with `jq` and posts it via the CLI

The SKILL.md then references the scripts using `${CLAUDE_SKILL_DIR}` paths:
```
${CLAUDE_SKILL_DIR}/scripts/gather-metadata.sh
${CLAUDE_SKILL_DIR}/scripts/post-review.sh {owner/repo} {id} {head_sha} {event_type} {temp_file_path}
```

See also: [Script Execution Instructions](./script-execution-instructions.md) for the full pattern on how to write script invocation steps in SKILL.md.

Shell scripts can safely use pipes, redirects, subcommands, and complex logic because they run as normal bash processes, not through the skill context injection system.

### Rule: Use `which` to check if a tool is installed

Use `which {command}` as the preferred way to determine if an executable tool is installed. For example:
```
- gh CLI: !`which gh`
- jq: !`which jq`
```

A `` !`gh --version` `` style check also runs, but it has two problems:
1. It returns more output than needed (full version string vs just a path)
2. If the tool is not installed, running `{command} --version` returns a non-zero exit code, which can cause the skill to exit immediately before it has a chance to inform the user

`which` is preferred because:
- It returns the path if found, or empty output if not — no error exit code
- The skill's Pre-requisites gate logic can then check for empty output and stop gracefully with a user-facing message

### Rule: Use `find` instead of `ls` for file detection

Use `find` with specific flags for file and directory detection. Do not use `ls`.

**Before (avoid):**
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

This bites skills that document or analyze other skills. A skill whose SKILL.md contained the literal pattern in a bullet describing the syntax had the loader parse it as an actual command and fail with: `Shell command permission check failed for pattern "!`command`": This command requires approval`.

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

1. **Refer to the label** — "If `default branch` is empty"
2. **Handle empty output** — check for emptiness, then ask the user or skip (for example, "If git user or email is **empty**")
3. **Pre-requisite gates** — if a tool is not found, inform the user and stop immediately

## Relationship to `allowed-tools`

Each Bash command pattern must be a separate `Bash()` entry in the `allowed-tools` frontmatter.

```
# Before (broken: one Bash() with several commands inside):
allowed-tools: Bash(date *, git config *, whoami, ls *, mkdir *)

# After (correct: one Bash() per command prefix):
allowed-tools: Bash(date *), Bash(git config *), Bash(whoami), Bash(mkdir *), Bash(find *)
```

See also: [allowed-tools: AskUserQuestion](./allowed-tools-AskUserQuestion.md) for another `allowed-tools` constraint.

## Command Categories Quick Reference

Examples organized by purpose:

**Git state:**
- `` !`git branch --show-current` `` — current branch
- `` !`git symbolic-ref --short refs/remotes/origin/HEAD` `` — default branch
- `` !`git log origin/HEAD..HEAD --oneline` `` — branch summary
- `` !`git diff origin/HEAD...HEAD --stat` `` — branch stats
- `` !`git diff origin/HEAD...HEAD` `` — branch changes

**Git diffs/logs (via gh CLI):**
- `` !`gh pr diff --name-only` `` — PR changed files

**User identity:**
- `` !`git config user.name` `` — git user name
- `` !`git config user.email` `` — git user email
- `` !`whoami` `` — OS username

**File/directory discovery:**
- `` !`find . -maxdepth 1 -name "CLAUDE.md" -type f` `` — check for a file
- `` !`find . -maxdepth 1 -name "AGENTS.md" -type f` `` — check for a file
- `` !`find . -maxdepth 1 -name "README*" -type f` `` — check for a file
- `` !`find . -maxdepth 3 -name "project-discovery.md" -type f` `` — find a known output file written by another skill
- `` !`find . -maxdepth 4 -type d -path "*/.claude/rules/coding-standards"` `` — check for a path-scoped rules directory

**Tool availability:**
- `` !`which gh` `` — check for the gh CLI
- `` !`which jq` `` — check for jq
- `` !`which git` `` — check for git

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
