---
paths:
  - "**/skills/**/*.md"
---

# `AskUserQuestion` in Skill `allowed-tools`

The `allowed-tools` frontmatter in a SKILL.md file defines which tools are auto-approved without user permission prompts when the skill is active. Due to a bug in Claude Code's permission evaluator, `AskUserQuestion` must not be listed in `allowed-tools` — doing so silently breaks the tool's interactive prompt.

## The Rule

Do not add `AskUserQuestion` to the `allowed-tools` frontmatter in any skill file.

**Before (broken):**
```
allowed-tools: Bash(gh *), Bash(git *), Read, Grep, Glob, AskUserQuestion
```

**After (correct):**
```
allowed-tools: Bash(gh *), Bash(git *), Read, Grep, Glob, EnterPlanMode, Skill
```

## Why It Fails

`allowed-tools` is an auto-approve list, not an allowlist. Tools not listed can still be called — they just require a one-time user permission prompt. When `AskUserQuestion` is in `allowed-tools`, the permission evaluator (`Xv9`) has an early return path that auto-approves the tool without rendering the interactive prompt UI:

```
Step 1: Check alwaysAllowRules (includes skill allowed-tools)
  └─ AskUserQuestion matches → RETURN { behavior: "allow", answers: {} }
  └─ Steps 4-5 (requiresUserInteraction check) NEVER REACHED
```

The tool returns immediately with empty answers. The user never sees the question. Both AskUserQuestion calls return `"User has answered your questions: ."` with empty answers.

This also affects skills that delegate via the `Skill` tool — the parent skill's `alwaysAllowRules` persist and stack. If a parent skill has `AskUserQuestion` in its `allowed-tools`, every child skill's AskUserQuestion calls will also silently fail.

**Upstream bug reports:**
- GitHub Issue #29547 — "AskUserQuestion silently returns empty answers when called inside plugin skills" (closed March 2, 2026; fix noted as "upcoming release" but still reproducing as of March 4)
- GitHub Issue #9846 — same symptom in an earlier version (v2.0.22). Fixed in v2.0.28 by adding a `requiresUserInteraction()` guard, but that guard only covers the non-allowed-tools path — the `alwaysAllowRules` early return bypasses it entirely.

## Which Skills This Affects

Any skill that calls `AskUserQuestion` to ask the user something interactively. If such a skill lists `AskUserQuestion` in `allowed-tools`, the prompt silently returns empty answers. Audit every skill that asks the user a question and confirm `AskUserQuestion` is absent from its `allowed-tools` line.

## What Happens Without It

Removing `AskUserQuestion` from `allowed-tools` does not break it. `AskUserQuestion` still works — the user just sees a one-time permission prompt ("Allow AskUserQuestion?") before the actual question is displayed. The interactive prompt then renders correctly and the user can respond.

Once Anthropic ships the upstream fix (#29547), `AskUserQuestion` can optionally be re-added to `allowed-tools` for cleaner UX (auto-approved permission with the interactive prompt still shown).

## Related Tools

`EnterPlanMode` and other mode-toggle tools do NOT have this issue. They don't use `requiresUserInteraction()` and don't require interactive user input — they are mode toggles called by the agent. No GitHub issues exist for `EnterPlanMode` + `allowed-tools`.

## Summary Checklist

1. Never add `AskUserQuestion` to `allowed-tools` frontmatter
2. If found in an existing skill, remove it
3. `AskUserQuestion` will still work — it just won't be auto-approved
4. This is a workaround for Claude Code bug #29547; revisit when the fix ships

Cross-reference: [Context Injection Commands](./context-injection-commands.md) for related `allowed-tools` formatting guidance (separate `Bash()` entries).
