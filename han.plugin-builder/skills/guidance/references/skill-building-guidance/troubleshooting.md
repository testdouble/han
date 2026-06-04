---
paths:
  - "**/skills/**/*.md"
---

# Troubleshooting

This guide covers common problems encountered when building and using skills, organized by symptom. Each section describes the symptom, explains the likely cause, and provides a concrete fix.

For historical context on how specific issues were discovered and resolved, see the failure evidence tables in [Context Injection Commands](./context-injection-commands.md).

## Skill Won't Upload

### File not recognized

**Symptom:** "Could not find SKILL.md in uploaded folder" or skill doesn't appear after upload.

**Cause:** The file is not named exactly `SKILL.md` (case-sensitive).

**Fix:**
```bash
# Check the actual filename in the skill directory
find . -maxdepth 1 -name "SKILL*" -o -name "skill*"

# Must be exactly:
SKILL.md

# These are all wrong:
skill.md
SKILL.MD
Skill.md
```

See [Naming Conventions](./naming-conventions.md) for the full naming rules.

### Invalid frontmatter

**Symptom:** "Invalid frontmatter" error during upload.

**Cause:** YAML formatting issue — missing delimiters, unclosed quotes, or invalid syntax.

**Before (broken):**
```yaml
name: my-skill
description: Does things
```
Missing `---` delimiters.

```yaml
---
name: my-skill
description: "Does things
---
```
Unclosed quote on description.

**After (correct):**
```yaml
---
name: my-skill
description: "Does things"
---
```

### Invalid skill name

**Symptom:** "Invalid skill name" error during upload.

**Cause:** Name contains spaces, capitals, or reserved prefixes.

**Before (rejected):**
```yaml
name: My Cool Skill       # Spaces and capitals
name: claude-helper        # Reserved prefix "claude"
name: anthropic-tools      # Reserved prefix "anthropic"
```

**After (accepted):**
```yaml
name: my-cool-skill        # kebab-case, no reserved prefixes
```

See [Security Restrictions](./security-restrictions.md) for reserved name rules.

## Skill Doesn't Trigger

**Symptom:** Skill never loads automatically — users must invoke it explicitly with `/skill-name`.

**Cause:** The `description` field is too generic, missing trigger phrases, or missing the "when to use" component.

**Before (too generic):**
```yaml
description: "Helps with projects."
```

**After (specific triggers):**
```yaml
description: >
  Creates and maintains project documentation for features, systems, and
  components. Use when documenting how a feature, system, or component
  works. Does not create architectural decision records — use architectural-decision-record
  for ADRs.
```

**Debugging approach:** Ask Claude: "When would you use the [skill name] skill?" Claude will quote the description back. Compare what it says against the prompts that should trigger the skill. If Claude can't explain when to use it, the description needs more detail.

**Checklist:**
- Does the description include trigger phrases users actually say?
- Does it mention relevant file types or tools if applicable?
- Does it cover at least 3 sentences (what, when-to-use, boundary)?

See [Skill Description Frontmatter](./skill-description-frontmatter.md) for the full description-writing rules.

## Skill Triggers Too Often

**Symptom:** Skill loads for unrelated queries — users see it activate when they didn't intend it.

**Cause:** Description is too broad or lacks boundary statements distinguishing it from sibling skills.

### Fix 1: Add negative triggers

Tell Claude explicitly what the skill does NOT handle.

**Before:**
```yaml
description: >
  Advanced data analysis for CSV files. Use for statistical modeling,
  regression analysis, and clustering.
```

**After:**
```yaml
description: >
  Advanced data analysis for CSV files. Use for statistical modeling,
  regression analysis, and clustering. Do NOT use for simple data
  exploration or visualization — use data-viz skill instead.
```

### Fix 2: Narrow the scope

**Before:**
```yaml
description: "Processes documents"
```

**After:**
```yaml
description: >
  Processes PDF legal documents for contract review. Use when reviewing,
  analyzing, or extracting clauses from legal PDFs. Does not handle
  general document creation — use project-documentation for that.
```

### Fix 3: Add bidirectional boundary statements

If skill A mentions skill B in its boundary, skill B must also mention skill A.

```yaml
# code-review description:
description: >
  ...Does not post to GitHub — use post-code-review-to-pr to post review comments
  to a pull request.

# post-code-review-to-pr description:
description: >
  ...For local code review without posting to GitHub, use code-review instead.
```

See [Skill Description Frontmatter](./skill-description-frontmatter.md) for boundary statement patterns.

## Instructions Not Followed

**Symptom:** Skill loads but Claude doesn't follow the instructions — skips steps, improvises, or produces inconsistent results.

### Cause 1: Instructions too verbose

Long, repetitive prose causes Claude to lose focus. Key instructions drown in filler.

**Fix:** Use numbered lists and bullet points. Cut filler words. Say it once.

**Before:**
```markdown
You should carefully look through all of the code changes that have been made
and try to find any issues or problems that might exist. It's really important
to be thorough and make sure you don't miss anything.
```

**After:**
```markdown
For each changed file:
1. Check for security issues (see `references/owasp-top10.md`)
2. Check for performance problems
3. Verify adherence to project style guidelines
```

### Cause 2: Critical instructions buried

Important rules appear mid-paragraph deep in the SKILL.md. Claude may not weight them appropriately.

**Fix:** Put critical instructions at the top of the step or in a dedicated section.

**Before:**
```markdown
## Step 5: Post Review

Generate the review body, format it nicely, make sure it's well-organized,
and by the way — NEVER post a review to your own PR, use a comment instead.
Then call the posting script.
```

**After:**
```markdown
## Step 5: Post Review

**CRITICAL:** If the PR author matches the current git user, use
`scripts/post-pr-comment.sh` instead of `scripts/post-pr-review.sh`.
GitHub does not allow reviewing your own PR.

Generate the review body, then run the appropriate script.
```

### Cause 3: Ambiguous language

**Fix:** Replace vague instructions with specific, testable criteria.

**Before:**
```markdown
Make sure to validate things properly.
```

**After:**
```markdown
Before calling create_project, verify:
- Project name is non-empty
- At least one team member assigned
- Start date is not in the past
```

### Cause 4: Stale documentation

**Symptom:** Skill produces structurally correct but factually wrong output — references non-existent files, uses old API patterns, follows deprecated conventions.

**Cause:** The SKILL.md or its `references/` describe files, paths, tool flags, or conventions that have changed since the skill was written. The model reads these faithfully and follows the outdated instructions. This looks like a model failure but is actually a documentation failure.

**Fix:** Audit SKILL.md and `references/` against the current state of what they describe. Treat doc-code contradictions as functional bugs — they actively poison output rather than passively going unnoticed.

**Before (stale reference):**
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

See [Documentation Maintenance](./documentation-maintenance.md) for when and how to audit skills for staleness.

### Advanced: Use scripts for critical validation

For validations where correctness is essential, use a script rather than language instructions. Code is deterministic; language interpretation varies.

```markdown
Run `scripts/validate-output.sh {output_file}` to verify the output.
```

See [Writing Effective Instructions](./writing-effective-instructions.md) for detailed guidance.

## Allowed-Tools Issues

### Repeated permission prompts

**Symptom:** Claude keeps asking the user for permission to run tools that the skill should have access to.

**Cause:** The tool is not listed in `allowed-tools`, or Bash commands are not properly scoped.

**Fix:** Add each tool to `allowed-tools`. For Bash commands, each prefix needs its own `Bash()` entry.

**Before (broken):**
```yaml
allowed-tools: Bash(git *, find *, which *)
```

**After (correct):**
```yaml
allowed-tools: Bash(git *), Bash(find *), Bash(which *)
```

See [Bash Permission Patterns](./allowed-tools-bash-permissions.md) for the full rules.

### AskUserQuestion silently fails

**Symptom:** The skill tries to ask the user a question but the prompt never appears. The skill hangs or skips the step.

**Cause:** `AskUserQuestion` is listed in `allowed-tools`. An upstream Claude Code bug (#29547) causes interactive prompts to silently fail when this tool is auto-approved.

**Fix:** Remove `AskUserQuestion` from `allowed-tools`. The tool works correctly when the user is prompted for permission each time.

**Before (broken):**
```yaml
allowed-tools: Read, Grep, Glob, AskUserQuestion
```

**After (correct):**
```yaml
allowed-tools: Read, Grep, Glob
```

See [AskUserQuestion Bug](./allowed-tools-AskUserQuestion.md) for details.

## Context Injection Syntax in Prose Triggers Execution

**Symptom:** Skill fails on load with `Shell command permission check failed for pattern "!`command`": This command requires approval` — but the SKILL.md has no actual context injection commands.

**Cause:** The SKILL.md body text contains the literal bang-backtick pattern as documentation or an example (e.g., describing what context injection commands look like). The skill loader scans the raw SKILL.md text for the pattern and does not respect markdown escaping — double backticks, inline code spans, and fenced code blocks are all parsed.

**Fix:** Replace the literal pattern with a description that does not trigger the parser.

**Before (broken — loader tries to execute `command`):**
```markdown
- A context injection command (`` !`command` `` syntax)
```

**After (correct):**
```markdown
- A context injection command (bang-backtick syntax for runtime context)
```

**Note:** Files in `references/` are not parsed by the loader, so they can safely contain the literal pattern.

See [Context Injection Commands](./context-injection-commands.md) for the full rule.

## Sub-Skill Output Lost

**Symptom:** A skill calls another skill via the Skill tool. The sub-skill runs
and produces output on screen, but the calling skill never picks up the results.

### Cause 1: Data-fetch sub-skill running inline

Data-fetch sub-skills (those that return small, structured values) are unreliable
when running inline. The inline model has no structured return mechanism —
Claude must manually context-switch back to the parent workflow.

**Fix:** Add `context: fork` to the sub-skill's frontmatter. The subagent runs
in isolation and results are returned as a discrete tool response.

### Cause 2: Sub-skill launches interactive workflow

If an inline sub-skill asks the user questions or calls other skills, the parent
workflow is derailed.

**Fix:** Simplify the sub-skill to output values and stop. No interactive questions,
no fallback skill calls.

See [Skill Composition](./skill-composition.md) for the complete pattern.

## Summary Checklist

1. **Won't upload:** Check `SKILL.md` naming (case-sensitive), YAML delimiters, and reserved name prefixes
2. **Doesn't trigger:** Add specific trigger phrases, "when to use" context, and boundary statements to description
3. **Triggers too often:** Add negative triggers, narrow scope, ensure bidirectional boundary statements
4. **Instructions not followed:** Shorten verbose prose, surface critical instructions, replace ambiguous language, use scripts for validation
5. **Permission prompts:** Add tools to `allowed-tools`; use separate `Bash()` entries per command prefix
6. **AskUserQuestion fails:** Remove it from `allowed-tools` — the bug causes silent failures when auto-approved
7. **Context injection in prose:** Never use the literal bang-backtick pattern in SKILL.md body text — the loader parses raw text and tries to execute it
8. **Sub-skill output lost:** Add `context: fork` to data-fetch sub-skills; remove interactive workflows from forked skills

Cross-references:
- [Naming Conventions](./naming-conventions.md) — Skill naming rules
- [Security Restrictions](./security-restrictions.md) — Reserved names and frontmatter restrictions
- [Skill Description Frontmatter](./skill-description-frontmatter.md) — Description-writing rules for trigger accuracy
- [Writing Effective Instructions](./writing-effective-instructions.md) — How to write instructions Claude follows consistently
- [Bash Permission Patterns](./allowed-tools-bash-permissions.md) — Bash tool permission scoping
- [AskUserQuestion Bug](./allowed-tools-AskUserQuestion.md) — The silent failure bug
- [Context Injection Commands](./context-injection-commands.md) — Historical failure evidence for command patterns
