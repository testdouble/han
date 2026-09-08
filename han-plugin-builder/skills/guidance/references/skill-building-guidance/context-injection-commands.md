---
paths:
  - "**/skills/**/*.md"
---

# Context Injection Commands in Skill Files

## Contents

- Syntax
- When to Use
- Section Placement
- Command Guidelines
- What NOT to Use in Context Injection
- Referencing Injected Context in Steps
- Relationship to `allowed-tools`
- Command Categories Quick Reference
- Summary Checklist

Context injection commands use the `` !`command` `` syntax to execute a shell command at skill load time and inject its
stdout into the skill as runtime context. The command runs **once when the skill loads**, not during each step. This
gives skill steps access to dynamic information about the current environment without hardcoding values.

## Syntax

Format: `` - label: !`command` ``

Multiple commands per line: ``- Git user: !`git config user.name` (!`git config user.email`)``

Many skills use this pattern: code-review skills, documentation skills, PR-description skills, investigation skills,
project-discovery skills, and any skill whose steps need to know the current git state or project layout.

## When to Use

**Use when:** skill steps need runtime information — git state, user identity, project structure, tool availability.

**Don't use when:** the skill is procedural or content-focused and doesn't need environment-specific context. A skill
whose steps are pure instructions (a writing-style guide, a content checklist, a procedural walkthrough) has no need for
context injection commands because its steps don't depend on runtime environment details.

## Section Placement

Context injection commands belong in one of two sections:

1. **`## Pre-requisites`** — tool availability checks that gate execution. If a required tool is missing, the skill
   should inform the user and stop immediately.
2. **`## Project Context`** — runtime information used by step logic (git state, file structure, user identity).

Do not duplicate commands across both sections. A tool availability check belongs in Pre-requisites only; repeating the
same check in Project Context runs the command twice and adds nothing.

## Command Guidelines

### Rule: Keep every command an auto-approvable read-only form

Context injection runs at skill load, and it never prompts. If a command is not auto-approvable, the loader hard-rejects
it and stops loading the skill. You see the error for the first failing command only; every command after it is masked,
so one bad command takes the whole skill down. There is no prompt to fall back on, so keeping commands simple is not a
style preference here. It is what keeps the skill loadable.

A command auto-approves only when every command in it, and every stage of a pipe or part of a chain, is one of:

1. A built-in **read-only** command in an allowed form. The loader ships a fixed allowlist that already covers most
   inspection tools, including `cat`, `ls`, `head`, `tail`, `wc`, `grep`, `find` (without the dangerous predicates
   below), `which`, `echo`, `date`, and the read-only `git` and `gh` subcommands such as `git status`, `git log`,
   `git diff`, `git rev-parse`, and `git config --get`. Commands on this list need no `allowed-tools` entry.
2. Matched by an explicit `Bash()` rule in the skill's `allowed-tools`.

Read the allowlist as a claim about the command, not about its arguments. A probe using an allowlisted command has
still been refused in the field over what it was pointed at, with an error naming a permission classifier this guidance
does not describe. Treat the two rules above as necessary rather than sufficient, and pair them with the path rule
below.

Pipes and `&&` / `;` / `||` chains are not forbidden. The loader splits them and checks each part against the two rules
above, so `git log --oneline | head` and `git rev-parse HEAD && git branch --show-current` load fine because every part
is an allowlisted read-only form. What breaks a skill is a part that is neither allowlisted nor declared, or one of the
constructs the classifier refuses outright.

**Four constructs are refused every time, and declaring a `Bash()` rule does not rescue them:**

- **Command substitution** `$(...)` injects the error `Contains command_substitution`.
- **Process substitution** `<(...)` or `>(...)` injects `Contains process_substitution`.
- **Subshells** `( ... )` and **background** `&`, reported as "not a simple read-only command".
- **Dangerous sub-forms of otherwise-safe tools**: `find` with `-exec`, `-execdir`, `-delete`, `-ok`, or `-fprint*`;
  `sed` with in-place editing; and similar. These stay blocked even when a matching prefix rule such as `Bash(find *)`
  is present. The danger check overrides the grant, so a broad `Bash(find *)` cannot re-enable `find -exec`.

Even though a pipe of read-only commands loads, prefer one flag-driven command when it exists. Not because pipes fail,
but because every extra stage is one more part that has to stay on the allowlist, and one part that slips off aborts the
whole skill load with an error that names only that part. A flag on the primary command usually replaces the pipe
outright. Instead of piping `git symbolic-ref` through `sed` to strip a prefix, use the `--short` flag.

**Prefer (one allowlisted command, nothing to slip off):**

```
!`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo unknown`
!`find . -maxdepth 3 -name "project-discovery.md" -type f`
!`find . -maxdepth 1 -name "Makefile" -type f`
```

**Avoid:**

```
!`export DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | cut -d '/' -f4-) && echo $DEFAULT_BRANCH`
!`test -f Makefile && echo "yes" || echo "no"`
```

The first line is refused outright because of the `$(...)`. The second loads, but a single `find` with `-name` returns
the same answer with nothing to slip off the allowlist.

**Keep each injected value small.** Injected output is inserted once at load and stays in context for the whole skill
run, so a large blob is a standing cost that can bury the signal. Bound it at the source rather than after the fact:
prefer a command that returns only what the step needs, such as `git log -n 10 --oneline` over piping a full log into
`head`, `git diff --stat` or `--name-only` over a full diff, and `find` with `-maxdepth` and `-name` over listing a
whole tree. A native limit cuts at a meaningful boundary and stays a single command.

`| head -N` is a last resort, not a ban. It loads, because `head` is allowlisted, so when a command has no native limit
and you only need a capped preview, `cmd | head -20` is fine. Two cautions. Never `| head` a result the step logic then
checks for completeness, because it can drop the very line you were looking for; use a bounded query or gather it in a
step instead. And if you are capping a flood, that is usually a sign the data should be gathered in a step during the
run, not injected at load.

One compound form is not only allowed but recommended: the trailing `2>/dev/null || echo <sentinel>` guard. It is a `||`
chain, and it loads because both parts qualify. The sentinel side is a bare `echo`, which is allowlisted, and the
primary side is an allowlisted read-only command or one your `allowed-tools` declares. Use it on any command that exits
non-zero when its subject is absent, so the command exits 0 and injects a value the step logic can check.
`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo unknown` keeps its guard because `origin/HEAD`
may be unset.

One edge is worth knowing. The read-only `git config` form on the allowlist is `git config --get`, so write
`git config --get user.name`, not the bare `git config user.name`. The bare form is accepted as a lone command but not
as a part of a `&&` / `;` / `||` chain, where it then needs an explicit `Bash(git config *)` rule. Using `--get` keeps
the guarded form self-sufficient: `git config --get user.name || echo unset` loads on the allowlist alone.

This reflects the loader's current behavior. The exact allowlist can shift between Claude Code versions, so when a
command is not clearly a plain read-only form, prefer the simplest single-command version or move the logic into a
script (next rule).

### Rule: Keep every probe reading inside the project working directory

A probe reads files in the directory the skill runs from. When a step needs the content of a file somewhere else, gather
it during the run with the Read tool instead.

The reason is the no-prompt, no-fallback behavior from the rule above. A probe stakes the whole skill on a permission
decision it cannot recover from, and a read reaching outside the project into a home directory, a configuration
directory, or anywhere holding credentials is the read most likely to draw a refusal. A Read-tool call during the run
carries no such risk to the skill: the step handles a read that returns nothing and carries on.

Han shipped this mistake once. Forty skills read an optional personal config through a probe pointed at the Claude Code
configuration directory, and the refusal that followed took whole skills down before they did any work:

```
Error: Shell command permission check failed for pattern
"!`cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.han/config.md" 2>/dev/null || echo ""`":
Permission for this action was denied by the Claude Code auto mode classifier.
Reason: Blocked by classifier.
```

Resolving a path in a probe stays fine, because `echo` opens no file. Reading through it does not.

**Prefer (probe resolves the location, a step reads the file):**

```
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
```

That line reads an environment variable inside a script rather than in the probe text, which is the only measured way
to reach one. See "Rule: Reach an environment variable through a script, not through probe text" below.

**Avoid (probe reads outside the project):**

```
!`cat "$HOME/.someconfig" 2>/dev/null || echo ""`
!`cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.han/config.md" 2>/dev/null || echo ""`
```

### Rule: Reach an environment variable through a script, not through probe text

The loader inspects the probe's text before anything runs. A variable named there is refused, and the refusal is
narrower than the error message suggests. These results are measured on Claude Code `2.1.234`, each form written into a
scratch skill and invoked from a fresh session:

| Probe form                                         | Result |
| -------------------------------------------------- | ------ |
| `echo hello`                                       | loads  |
| `echo "$HOME"`                                     | loads  |
| `echo "$HOME/.claude"`                             | loads  |
| `echo ~/.claude`                                   | loads  |
| `echo "${HOME}"`                                   | aborts |
| `echo "${HOME:-/tmp}"`                             | aborts |
| `echo "$CLAUDE_CONFIG_DIR"`                        | aborts |
| `echo "$FOOBAR_NOT_REAL"`                          | aborts |
| `echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`       | aborts |
| `printenv HOME`                                    | aborts |
| `printenv CLAUDE_CONFIG_DIR \|\| echo "~/.claude"` | aborts |

Three rules explain every row. A bare `$HOME` is permitted. Brace syntax is refused even for `$HOME`, so the form
matters as much as the name. Every variable other than `HOME` is refused, including one that does not exist, so the
loader is not resolving values and reacting to them.

An `allowed-tools` grant does not help here. The refusal happens on the text, before any permission question is asked.

To reach a variable, put it in a script and run the script from the probe:

```
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
```

```yaml
allowed-tools: Read, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
```

Four things make that work, and leaving any of them out aborts the skill:

1. **Grant the exact command.** A script probe is refused without a grant, even with no variable anywhere in it. This
   is the second route to auto-approval described in the first rule on this page, and it is the one a script needs.
2. **Use the braced `${CLAUDE_PLUGIN_ROOT}`.** It is a harness substitution, replaced before the permission check runs,
   so the check never sees a variable reference. The unbraced `$CLAUDE_PLUGIN_ROOT` is not substituted and is refused.
3. **Stay inside a plugin.** Both spellings abort in a skill under `.claude/skills/`, where nothing defines the
   substitution. Verify a script probe as an installed plugin, never as a local skill.
4. **Guard the command.** A missing or failing script aborts the skill exactly as a refused probe does. The
   `2>/dev/null || echo <fallback>` tail degrades instead. The grant needs to name only the `bash ...` half, because the
   `echo` half is separately auto-approvable.

Keep the script itself trivial and read-only. A probe cannot prompt, so anything the script does that could fail takes
the skill down with it.

### Rule: Use shell scripts for complex operations

When a task requires command substitution, process substitution, heredocs, JSON construction, or multi-step logic,
extract it into a shell script and call the script from skill steps (not from context injection).

A common case is posting structured data to an API. Building a JSON payload inline with a heredoc, then piping it to a
CLI, mixes a heredoc and command substitution into one command. The heredoc and the substitution are both refused at
load, so none of it runs. Put it in a script instead.

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

See also: [Script Execution Instructions](./script-execution-instructions.md) for the full pattern on how to write
script invocation steps in SKILL.md.

Shell scripts can safely use pipes, redirects, subcommands, and complex logic because they run as normal bash processes,
not through the skill context injection system.

### Rule: Use `which` (guarded) to check if a tool is installed

Use `which {command} 2>/dev/null || echo "not installed"` to check whether a tool is installed:

```
- gh CLI: !`which gh 2>/dev/null || echo "not installed"`
- jq: !`which jq 2>/dev/null || echo "not installed"`
```

When the tool is missing, `which` exits non-zero and may print to stderr — either can abort the skill or dirty the
injected value. `2>/dev/null` drops the stderr and `|| echo "not installed"` forces a clean exit plus a sentinel the
Pre-requisites gate checks. Prefer this over `{command} --version`, which fails the same way. The same guard fits any
command that fails when its subject is absent — e.g.
`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo unknown` when `origin/HEAD` may be unset.

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

The skill loader scans the **raw text** of the SKILL.md body for context injection patterns. Markdown escaping — double
backticks, inline code spans, fenced code blocks — does **not** prevent parsing. If the literal pattern appears anywhere
in the SKILL.md body, even as a documentation example or description, the loader will extract it and attempt to execute
the command inside.

This bites skills that document or analyze other skills. A skill whose SKILL.md contained the literal pattern in a
bullet describing the syntax had the loader parse it as an actual command and fail with:
`Shell command permission check failed for pattern "!`command`": This command requires approval`.

**When you need to reference context injection syntax in a SKILL.md body** (e.g., when a skill analyzes other skills),
describe the concept without the literal pattern:

**Before (broken — loader executes `command`):**

```markdown
- A context injection command (`` !`command` `` syntax)
```

**After (correct — describes the concept safely):**

```markdown
- A context injection command (bang-backtick syntax for runtime context)
```

**Reference files are safe.** Files in `references/` are not parsed by the skill loader, so they can contain the literal
pattern for documentation purposes.

## What NOT to Use in Context Injection

| Pattern                                          | Example                                                 | What happens                                                                                                                                                   |
| ------------------------------------------------ | ------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Command substitution                             | `$(command)`                                            | Refused every time (`Contains command_substitution`), even when declared                                                                                       |
| Process substitution                             | `<(command)`, `>(command)`                              | Refused every time (`Contains process_substitution`), even when declared                                                                                       |
| Subshell or background                           | `( cmd )`, `cmd &`                                      | Refused as "not a simple read-only command"                                                                                                                    |
| Dangerous tool flags                             | `find ... -exec`, `find ... -delete`, `sed -i`          | Refused even with a matching `Bash()` prefix rule                                                                                                              |
| An environment variable named in probe text      | `echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`            | Refused (`Contains expansion`) for every variable except a bare `$HOME`, and refused for `$HOME` itself in brace form. No `allowed-tools` grant changes this   |
| `printenv` anywhere in a probe                   | `printenv HOME`                                         | Refused whatever variable it names, so it is not a way around the rule above                                                                                   |
| A script probe with no matching grant            | `bash ./scripts/thing.sh`                               | Aborts the skill load even with no variable in the command. Grant the exact command in `allowed-tools`                                                         |
| An unguarded script probe                        | `bash "${CLAUDE_PLUGIN_ROOT}/scripts/thing.sh"`         | Aborts the skill if the script is missing or exits non-zero. Append `2>/dev/null \|\| echo <fallback>`                                                         |
| A stage that is neither allowlisted nor declared | `command \| custom-bin`                                 | Aborts the whole skill load; the error names only the offending stage                                                                                          |
| Large injected output                            | full `git diff`, unbounded `git log`, whole-tree `find` | Bound at the source (`-n`, `--stat`, `--name-only`, `-maxdepth`); a big value persists in context for the whole run. `\| head -N` is a last resort, not broken |
| A read reaching outside the project              | `cat "$HOME/.config/thing"`                             | Stakes the skill load on a permission decision with no fallback; resolve the path in a probe and read the file with the Read tool during the run               |
| `ls` for detection                               | `ls filename`                                           | Use `find` instead; `ls` fails on missing files                                                                                                                |
| Heredocs                                         | `<<'EOF' ... EOF`                                       | Extract to shell scripts                                                                                                                                       |
| Literal bang-backtick syntax in prose            | Showing the pattern as an example                       | Loader parses raw text; use "bang-backtick syntax" instead                                                                                                     |

## Referencing Injected Context in Steps

1. **Refer to the label** — "If `default branch` is empty"
2. **Handle empty output** — check for emptiness, then ask the user or skip (for example, "If git user or email is
   **empty**")
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

**Git state** (each exits non-zero outside a repo or with `origin/HEAD` unset, so each is guarded):

- `` !`git branch --show-current 2>/dev/null || echo unknown` `` — current branch
- `` !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo unknown` `` — default branch
- `` !`git log origin/HEAD..HEAD --oneline 2>/dev/null || echo unknown` `` — branch summary
- `` !`git diff origin/HEAD...HEAD --stat 2>/dev/null || echo unknown` `` — branch stats
- `` !`git diff origin/HEAD...HEAD 2>/dev/null || echo unknown` `` — branch changes

**Git diffs/logs (via gh CLI):**

- `` !`gh pr diff --name-only 2>/dev/null || echo "no pr"` `` — PR changed files (fails when no PR exists)

**User identity:**

- `` !`git config --get user.name || echo unset` `` — git user name (exits 1 when identity is unset)
- `` !`git config --get user.email || echo unset` `` — git user email
- `` !`whoami` `` — OS username

**File/directory discovery:**

- `` !`find . -maxdepth 1 -name "CLAUDE.md" -type f` `` — check for a file
- `` !`find . -maxdepth 1 -name "AGENTS.md" -type f` `` — check for a file
- `` !`find . -maxdepth 1 -name "README*" -type f` `` — check for a file
- `` !`find . -maxdepth 3 -name "project-discovery.md" -type f` `` — find a known output file written by another skill
- `` !`find . -maxdepth 4 -type d -path "*/.claude/rules/coding-standards"` `` — check for a path-scoped rules directory

**Tool availability:**

- `` !`which gh 2>/dev/null || echo "not installed"` `` — check for the gh CLI
- `` !`which jq 2>/dev/null || echo "not installed"` `` — check for jq
- `` !`which git 2>/dev/null || echo "not installed"` `` — check for git

## Summary Checklist

1. Use `` !`command` `` in `## Pre-requisites` or `## Project Context`
2. Every command, and every pipe stage or chain part, must be an allowlisted read-only form or explicitly declared in
   `allowed-tools`; a part that is neither aborts the whole skill load. Never use command substitution `$(...)`, process
   substitution `<(...)`, subshells, or `&`, which are refused even when declared. Pipes and `&&` / `;` / `||` chains
   are fine when every part qualifies, but prefer one flag-driven command; the trailing `2>/dev/null || echo <sentinel>`
   guard is the recommended compound (items 3-4)
3. Use `which {command} 2>/dev/null || echo "not installed"` for tool availability checks
4. Guard any read that exits non-zero when its subject is absent (`git symbolic-ref … origin/HEAD`,
   `git log/diff origin/HEAD…`, `gh pr diff`, `git config user.name/email`) with a trailing
   `2>/dev/null || echo <sentinel>`, and gate its consumer on that sentinel
5. Keep every probe reading inside the project working directory; resolve an outside path with `echo` and read the file
   with the Read tool during the run
6. Use `find` for file/directory detection, not `ls`
7. Extract complex operations into shell scripts
8. Handle empty output in step logic; keep injected values small by bounding at the source (`git log -n`, `--stat`,
   `find -maxdepth`), and never trim a result you then check for completeness
9. Do not duplicate commands across sections
10. Use separate `Bash()` entries in `allowed-tools`
11. Never use the literal bang-backtick pattern in SKILL.md prose — the loader parses raw text regardless of markdown
    escaping
