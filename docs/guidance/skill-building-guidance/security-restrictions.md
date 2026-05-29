---
paths:
  - "han.core/skills/**/*.md"
  - "han.github/skills/**/*.md"
---

# Security Restrictions

Skill frontmatter appears in Claude's system prompt. This privileged position means malicious or malformed frontmatter could inject instructions into the system prompt, bypass skill boundaries, or cause silent failures. These restrictions prevent those risks.

## The Rules

### Rule: No XML angle brackets in frontmatter

Do not use `<` or `>` characters anywhere in YAML frontmatter fields. Frontmatter is injected into Claude's system prompt, where XML tags have special meaning. Angle brackets in frontmatter could be interpreted as system prompt directives, creating an injection vector.

**Before (dangerous):**
```yaml
---
name: "data-processor"
description: "Processes <xml> data files and converts them to <json> format"
---
```

**After (safe):**
```yaml
---
name: "data-processor"
description: "Processes XML data files and converts them to JSON format"
---
```

This restriction applies to all frontmatter fields — `name`, `description`, `argument-hint`, `allowed-tools`, and any custom metadata. The SKILL.md body (below the closing `---`) is not affected by this restriction.

### Rule: No "claude" or "anthropic" in skill names

The prefixes "claude" and "anthropic" are reserved. Skills with these terms in their `name` field will be rejected during upload.

**Before (rejected):**
```yaml
---
name: "claude-helper"
description: "Helps with Claude-related tasks"
---
```

```yaml
---
name: "anthropic-tools"
description: "Tools for working with Anthropic APIs"
---
```

**After (accepted):**
```yaml
---
name: "ai-helper"
description: "Helps with Claude-related tasks"
---
```

This applies to the `name` field only. The `description` field may reference Claude or Anthropic when describing what the skill does.

### Rule: Description field max 1024 characters

The `description` field has a hard limit of 1024 characters. Descriptions beyond this limit will be truncated or cause upload failures.

This limit reinforces the progressive disclosure principle — descriptions should be concise triggers, not documentation. Detailed instructions belong in the SKILL.md body (Level 2) or `references/` (Level 3).

**Before (too long — 1,100+ characters):**
```yaml
description: >
  Run a full code review on the current git branch's changes against the default
  branch. Use when reviewing, auditing, or checking code quality on local changes
  before or after pushing. Does not post to GitHub — use post-code-review-to-pr to post
  review comments to a pull request. This skill analyzes all changed files,
  applies the OWASP top 10 security checklist, checks for common code smells,
  evaluates test coverage, reviews documentation changes, verifies naming
  conventions, checks for dependency updates, validates error handling patterns,
  reviews logging practices, and ensures backward compatibility. It produces a
  structured review document with severity ratings, specific line references,
  and actionable recommendations for each finding. The review covers both the
  diff itself and the broader context of changed files to catch issues that
  only appear when considering the full file. Additional capabilities include
  performance analysis, accessibility checking, and internationalization review.
```

**After (under 1024 characters):**
```yaml
description: >
  Run a full code review on the current git branch's changes against the default
  branch. Use when reviewing, auditing, or checking code quality on local changes
  before or after pushing. Does not post to GitHub — use post-code-review-to-pr to post
  review comments to a pull request.
```

Move the detailed capability list to the SKILL.md body where it guides execution rather than competing for system prompt space.

### Rule: Safe YAML parsing only

Frontmatter is parsed with safe YAML parsing. Features like custom tags, anchors with aliases across documents, or executable directives are not supported. Stick to standard YAML types: strings, numbers, booleans, lists, and objects.

**Before (unsafe YAML features):**
```yaml
---
name: "my-skill"
description: !!python/object:__main__.inject "malicious"
custom_field: !include /etc/passwd
---
```

**After (standard YAML):**
```yaml
---
name: "my-skill"
description: "Processes data files for analysis"
metadata:
  author: "Team Name"
  version: "1.0.0"
---
```

Custom metadata fields are allowed — `metadata`, `license`, `compatibility` — as long as they use standard YAML types.

## Summary Checklist

1. No `<` or `>` characters in any frontmatter field — XML injection risk
2. No "claude" or "anthropic" in the `name` field — reserved prefixes
3. Keep `description` under 1024 characters — move details to SKILL.md body
4. Use only standard YAML types — no custom tags, executable directives, or unsafe parsing features
5. The SKILL.md body is not subject to frontmatter security restrictions

Cross-references:
- [Skill Description Frontmatter](./skill-description-frontmatter.md) — How to write effective descriptions within the 1024-character limit
- [Naming Conventions](./naming-conventions.md) — Additional naming rules for skills and plugins
