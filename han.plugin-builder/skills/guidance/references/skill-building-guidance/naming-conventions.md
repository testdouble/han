---
paths:
  - "**/skills/**/*.md"
---

# Naming Conventions

Consistent naming across plugins, skills, and directories helps users discover and understand what a skill does from its name alone.

## The Rules

### Rule: Plugin directory name must match the `name` field in `plugin.json`

The directory containing the plugin must match the `name` field in its `.claude-plugin/plugin.json`.

**Before (mismatched):**
```
research-and-development/
  .claude-plugin/
    plugin.json    # { "name": "example-plugin", ... }
```
The directory was `research-and-development/` but the plugin name was `example-plugin`.

**After (matched):**
```
example-plugin/
  .claude-plugin/
    plugin.json    # { "name": "example-plugin", ... }
```
Rename the directory to match the plugin name.

### Rule: Skill directory names should indicate external dependencies

If a skill requires an external tool or service (GitHub CLI, Slack, Jira, etc.), prefix the skill directory name with the tool name so users can predict the dependency from the name alone.

**Before (generic):**
```
skills/
  pr-review/       # Requires gh CLI — not obvious from name
  pr-description/  # Requires gh CLI — not obvious from name
```

**After (dependency-prefixed):**
```
skills/
  gh-pr-review/       # Clearly requires gh CLI
  update-pr-description/  # Clearly requires gh CLI
```
Rename to clarify the GitHub dependency.

### Rule: Avoid skill names that imply the wrong artifact type

Without this rule, skill names using implementation verbs create expectations about what kind of artifact the skill produces. When the actual output differs, users avoid the skill (thinking it does something they don't want) and Claude may generate the wrong output type.

Consider a skill named `write-tests`. That name implies the skill produces runnable test code, when it actually produces a test plan document. Renaming it to `test-planning` names the process/activity rather than an implementation action, so users and Claude both predict the right output type.

**Before (`write-tests` — implies executable test code):**
```
skills/
  write-tests/      # Users wanting test analysis may avoid it; Claude may generate code instead of plans
```

**After (`test-planning` — names the process unambiguously):**
```
skills/
  test-planning/    # Names the activity; the artifact (a test plan) is implied without suggesting runnable code
```

Prefer gerund process names (`test-planning`, `iterative-plan-review`) over implementation verbs (`write-tests`, `generate-docs`) when the skill produces analysis, plans, or documentation rather than runnable artifacts. This matches Anthropic's general naming recommendation: gerund form (`processing-pdfs`, `analyzing-spreadsheets`) is the preferred convention, with noun phrases (`pdf-processing`) and action forms (`process-pdfs`) acceptable alternatives. Avoid vague names like `helper`, `utils`, `tools`, or `data`. See [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices).

**Heuristic:** "If someone reads only this directory name, could they mistake what type of artifact the skill produces?"

### Rule: Skill `name` in frontmatter matches the directory name

The `name` field in the SKILL.md frontmatter must match the skill's directory name.

```
skills/
  post-code-review-to-pr/
    SKILL.md       # name: "post-code-review-to-pr"
```

This ensures the skill is invoked with the same name the user sees in the file system.

In Claude Code the **directory name is what produces the slash command**, and the frontmatter `name` is the display label shown in skill listings. The one exception is a plugin-root `SKILL.md` (a skill defined at the plugin root rather than under `skills/{name}/`), where `name` does set the command because there is no directory to derive it from. Keeping the two equal, as this rule requires, means the distinction never bites. The open standard also requires `name` to match the parent directory: lowercase letters, numbers, and hyphens, max 64 characters, no reserved words (`claude`, `anthropic`).

### Rule: No README.md inside skill folders

Do not include a `README.md` inside a skill directory. All skill documentation belongs in `SKILL.md` (for instructions and process steps) or `references/` (for domain knowledge, templates, and checklists). A `README.md` in the skill folder creates ambiguity about where documentation lives and is not loaded by the plugin system.

**Before (wrong):**
```
skills/
  code-review/
    SKILL.md
    README.md        # Not loaded by plugin system, creates confusion
    references/
      checklist.md
```

**After (correct):**
```
skills/
  code-review/
    SKILL.md           # All skill documentation here
    references/
      checklist.md     # Domain knowledge here
```

Note: Repository-level README files (at the repo root or plugin root) are fine — this rule applies only to skill directories. When distributing via GitHub, use a repo-level README for human visitors.

### Rule: SKILL.md is case-sensitive

The skill definition file must be named exactly `SKILL.md` — uppercase `SKILL`, lowercase `.md`. No variations are accepted. The plugin system will not recognize other casings.

**Rejected names:**
```
skill.md       # Wrong: lowercase "skill"
SKILL.MD       # Wrong: uppercase ".MD"
Skill.md       # Wrong: mixed case
skill.MD       # Wrong: both wrong
```

**Accepted:**
```
SKILL.md       # Exactly this, nothing else
```

## Summary Checklist

1. Plugin directory name matches `name` in `plugin.json`
2. Skill directory names indicate external tool dependencies (e.g., `gh-` prefix for GitHub CLI)
3. Skill `name` in SKILL.md frontmatter matches the directory name
4. No `README.md` inside skill folders — use `SKILL.md` and `references/` instead
5. Skill definition file must be exactly `SKILL.md` (case-sensitive)
6. Avoid skill names using implementation verbs that imply the wrong output type — prefer gerund process names for analysis/planning skills (e.g., `test-planning` not `write-tests`)

