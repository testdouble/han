---
paths:
  - "**/skills/**/*.md"
---

# Bash Permission Patterns in `allowed-tools`

The `allowed-tools` frontmatter in a SKILL.md file declares which Bash commands are auto-approved without user permission prompts. Bash permissions use a glob pattern syntax: `Bash(command prefix *)`. Getting the syntax or granularity wrong causes skills to either stall on permission prompts or silently auto-approve unintended commands.

## Syntax Rules

### Rule: Each command prefix gets its own `Bash()` entry

Every distinct command prefix must be a separate `Bash()` declaration, comma-separated in the `allowed-tools` line.

**Correct:**
```yaml
allowed-tools: Bash(date *), Bash(git config *), Bash(whoami), Bash(mkdir *), Bash(find *)
```

**Wrong — colon-separated syntax (doesn't exist):**
```yaml
allowed-tools: Bash(gh:*), Bash(git:*)
```
Colon-separated syntax is invented and matches nothing. Use a space before the wildcard.

**Wrong — multiple commands in one `Bash()` declaration:**
```yaml
allowed-tools: Bash(date *, git config *, whoami, ls *, mkdir *, find *)
```
The glob matcher treats the entire contents as a single pattern. Individual commands after the first won't match correctly.

**Fixed:**
```yaml
allowed-tools: Bash(date *), Bash(git config *), Bash(whoami), Bash(mkdir *), Bash(find *)
```
Each command prefix gets its own `Bash()` entry.

## Granularity Rules

### Rule: Match the prefix to what the skill actually uses

Use the narrowest prefix that covers the skill's actual Bash usage. Overly broad patterns auto-approve commands the skill doesn't need; overly narrow patterns cause permission prompt interruptions.

**Narrower is better when practical:**
```yaml
# If the skill only uses git branch and git diff:
allowed-tools: Bash(git branch *), Bash(git diff *)
```
Narrower prefixes prevent auto-approving commands the skill doesn't need (like `git push` or `git reset --hard`).

However, skills that use many git subcommands across their steps (branch, diff, log, config, symbolic-ref, and so on) may use `Bash(git *)` to avoid an unwieldy list of narrow prefixes. A review skill or a PR-description skill that touches most of git is a typical case. The tradeoff is acceptable when the skill's workflow genuinely requires broad git access.

**Too narrow / missing:**
```yaml
allowed-tools: Bash(gh *), Bash(git *)
```
A skill that also uses `find` for file discovery will stall on permission prompts when it tries to run `find`, because no listed prefix covers it.

### Rule: Remove permissions for commands the skill doesn't use

If a skill doesn't actually call a command, don't include it in `allowed-tools`. A stale `Bash(ls *)` entry left over from an earlier draft, for instance, grants approval the skill never needs and should be removed.

### Rule: Prefer `find` over `ls` — and match `allowed-tools` accordingly

Skills should use `find` for file/directory detection (see [Context Injection Commands](./context-injection-commands.md#rule-use-find-instead-of-ls-for-file-detection)). If a skill uses `find` in context injection or step logic, include `Bash(find *)` in `allowed-tools` — not `Bash(ls *)`.

## Common Patterns

Common `allowed-tools` patterns:

| Pattern | What it covers |
|---------|---------------|
| `Bash(git branch *)` | Branch listing |
| `Bash(git diff *)` | Diff operations |
| `Bash(git log *)` | Log queries |
| `Bash(git config *)` | Config reads |
| `Bash(gh *)` | All GitHub CLI operations |
| `Bash(find *)` | File/directory discovery |
| `Bash(jq *)` | JSON processing |
| `Bash(which *)` | Tool availability checks |
| `Bash(whoami)` | OS username (no wildcard needed — exact command) |

## Summary Checklist

1. Each command prefix gets its own `Bash()` entry — never combine multiple commands in one declaration
2. No colon syntax (`Bash(gh:*)`) — use space: `Bash(gh *)`
3. Use the narrowest prefix that covers actual usage
4. Remove `Bash()` entries for commands the skill doesn't use
5. Use `Bash(find *)` not `Bash(ls *)` — skills should use `find` for file detection

Cross-reference: [Context Injection Commands](./context-injection-commands.md) for the relationship between context injection commands and `allowed-tools` entries.
