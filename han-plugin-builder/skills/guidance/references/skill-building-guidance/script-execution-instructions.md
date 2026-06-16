---
paths:
  - "**/skills/**/*.md"
  - "**/skills/**/scripts/**"
---

# Script Execution Instructions in SKILL.md

When a skill needs to run shell scripts during its steps, the SKILL.md body must describe the invocation as numbered prose instructions — not fenced code blocks.

## The Correct Pattern

Use numbered prose steps with `${CLAUDE_SKILL_DIR}` paths and explicit action verbs:

```markdown
1. Generate a unique temp file path by running `${CLAUDE_SKILL_DIR}/scripts/create-review-tempfile.sh`. Capture the output — it is the temp file path.
2. Write the content to the temp file path using the Write tool. Do not use Bash for this step.
3. Post the review by running `${CLAUDE_SKILL_DIR}/scripts/post-pr-review.sh {owner/repo} {pr_number} {head_sha} {event_type} {temp_file_path}`.
```

Each step has three elements:

1. **Action verb** — "Generate", "Write", "Post", "Run" — tells Claude what to do
2. **`${CLAUDE_SKILL_DIR}` path** — resolves to the skill's directory at runtime
3. **Explanation of inputs/outputs** — what to capture, where values come from

## Why Fenced Code Blocks Are Wrong

Fenced code blocks with comments as pseudocode are ambiguous:

```markdown
<!-- BAD — do not do this -->
    ```
    # generate a unique temp file path
    scripts/create-review-tempfile.sh

    # write content to the temp file
    # use the Write tool, not Bash

    # post the review
    scripts/post-pr-review.sh {args}
    ```
```

Problems:

- **Ambiguous intent** — Claude may treat a fenced code block as display code (show to user) rather than executable instructions (run these commands). Prose with action verbs is unambiguous.
- **Bare relative paths** — `scripts/create-review-tempfile.sh` is relative to the skill directory, but Claude runs commands from the user's CWD. The path won't resolve.
- **No action verbs** — Comments like `# generate a temp file` describe what should happen but don't instruct Claude to do it. Prose like "Generate a temp file by running..." is a direct instruction.

## How `${CLAUDE_SKILL_DIR}` Works

Claude Code expands `${CLAUDE_SKILL_DIR}` to the absolute path of the skill's directory at runtime. This means `${CLAUDE_SKILL_DIR}/scripts/my-script.sh` resolves to something like `/Users/name/.claude/plugins/your-marketplace/your-plugin/skills/post-code-review-to-pr/scripts/my-script.sh`.

Use `${CLAUDE_SKILL_DIR}` for all script paths in the SKILL.md body. Never use bare relative paths like `scripts/my-script.sh`.

## Why Scripts Should Not Be in `allowed-tools`

`Bash()` patterns in the `allowed-tools` frontmatter are **prefix-based matches**. The pattern `Bash(scripts/create-review-tempfile.sh)` matches commands that start with `scripts/create-review-tempfile.sh` — but at runtime, the actual command starts with the expanded `${CLAUDE_SKILL_DIR}` absolute path (e.g., `/Users/name/.claude/plugins/.../scripts/create-review-tempfile.sh`). The prefix won't match.

Since script commands can't be reliably auto-approved, omit them from `allowed-tools`. Scripts typically run once per skill invocation, so a single user approval is acceptable.

## Each Skill Gets Its Own Scripts

Skills must be self-contained. If two skills use the same script, each skill gets its own copy in its own `scripts/` directory. Do not reference scripts from another skill's directory — this creates a hidden dependency that breaks if the other skill is modified or removed.

## Summary

| Rule | Details |
|------|---------|
| Format | Numbered prose steps with action verbs |
| Paths | Always use `${CLAUDE_SKILL_DIR}/scripts/...` |
| Code blocks | Never use fenced code blocks for script execution steps |
| `allowed-tools` | Do not list scripts — prefix matching can't resolve `${CLAUDE_SKILL_DIR}` paths |
| Self-contained | Each skill owns its own scripts; no cross-skill references |
