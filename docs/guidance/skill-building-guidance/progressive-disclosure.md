---
paths:
  - "han.core/skills/**/*.md"
  - "han.github/skills/**/*.md"
---

# Progressive Disclosure

Skills use a three-level information architecture that balances context availability with token efficiency. Each level loads only when needed, keeping Claude's context window focused on what matters for the current task.

Understanding this architecture is essential for deciding where content belongs. Process steps go in the SKILL.md body. Domain knowledge — templates, checklists, rate tables, decision matrices — goes in `references/`. Deterministic operations go in `scripts/`. Getting this wrong means either bloating the context window with content Claude doesn't need yet, or hiding critical instructions behind an extra file load.

This architecture matters because SKILL.md content is not passive documentation — it is operational context that directly calibrates the model's output. Every example in a SKILL.md or reference file becomes a demonstration the model pattern-matches against. Every instruction competes for the model's finite attention budget. The three levels are not just an information hierarchy — they are an attention architecture.

## The Rules

### Rule: Skills use three levels of information loading

The three levels control when Claude sees each piece of a skill's content:

**Level 1 — YAML frontmatter (always loaded):**
Loaded into Claude's system prompt for every conversation. Claude reads all skill descriptions to decide which skill to invoke. This level must be concise — every token here is paid in every conversation, whether the skill triggers or not.

```yaml
---
name: "code-review"
description: >
  Run a full code review on the current git branch's changes against the default
  branch. Use when reviewing, auditing, or checking code quality on local changes
  before or after pushing. Does not post to GitHub — use post-code-review-to-pr to post
  review comments to a pull request.
allowed-tools: Read, Grep, Glob, Agent, ExitPlanMode
---
```

**Level 2 — SKILL.md body (loaded on trigger):**
Loaded only when Claude decides the skill is relevant. Contains the process steps, context injection commands, and execution logic.

```markdown
## Project Context

- Current branch: !`git branch --show-current`
- Default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD`

## Step 1: Gather Changes

Read the diff between the current branch and the default branch...
```

**Level 3 — Linked files (loaded on demand):**
Files in `references/` and `scripts/` that Claude loads only when a step explicitly references them. Templates, checklists, style guides, and shell scripts live here.

```
skills/
  code-review/
    SKILL.md              # Level 2: process steps
    references/
      owasp-top10.md      # Level 3: loaded when review step references it
      review-checklist.md  # Level 3: loaded when checklist step references it
    scripts/
      post-review.sh       # Level 3: executed when posting step calls it
```

### Rule: Keep SKILL.md body focused on process steps — extract domain knowledge to references/

The SKILL.md body should contain the skill's execution logic: numbered steps, context injection, decision points, and tool usage instructions. Domain knowledge that the skill consults — templates, checklists, rate tables, formulas, decision matrices — belongs in `references/`.

**When to extract to references/:**
- Templates that define output structure (ADR templates, review templates, PR description templates)
- Checklists that guide evaluation (OWASP checklist, code review checklist, documentation checklist)
- Rate tables, formulas, or scoring matrices (pricing tables, complexity scores, risk assessments)
- Style guides or brand standards (voice guidelines, formatting rules)
- Decision matrices with multiple criteria

**When to keep in SKILL.md:**
- Step-by-step process instructions
- Context injection commands
- Conditional logic ("if X, do Y")
- Tool invocation patterns
- Error handling instructions

**When to remove entirely:**
- Rules already enforced by the toolchain (linters, formatters, CI checks). If a linter catches it, documenting it in SKILL.md wastes attention budget and risks contradiction when the linter config changes. Reserve SKILL.md instructions for judgment calls — decisions that require context, tradeoffs, or domain knowledge that no automated tool checks.

**Before (restating what the toolchain enforces):**
```markdown
## Step 3: Apply Coding Standards

Ensure all code follows these rules:
- Use single quotes for strings
- Indent with 2 spaces
- No trailing semicolons
- Maximum line length 100 characters
- Use `const` over `let` where possible
```
All five rules are enforced by ESLint and Prettier. Documenting them wastes tokens and will drift when the config changes.

**After (focusing on judgment calls):**
```markdown
## Step 3: Apply Coding Standards

The linter and formatter handle syntax conventions. Focus on standards that require judgment:
- Error messages must include enough context for debugging (function name, relevant IDs)
- Public API functions must validate input types at the boundary
- Side effects (network calls, file writes) must be explicit in function names
```

**Before (domain knowledge mixed into SKILL.md):**
```markdown
## Step 3: Calculate Value

Use these rates for estimation:
- Junior engineer: $150/hr
- Senior engineer: $250/hr
- Principal engineer: $350/hr

Apply the complexity multiplier:
| Complexity | Multiplier |
|------------|------------|
| Low        | 1.0x       |
| Medium     | 1.5x       |
| High       | 2.5x       |

Use the formula: (hours × rate) × complexity_multiplier × risk_factor...
```

**After (domain knowledge extracted):**

`references/rate-tables.md`:
```markdown
# Rate Tables and Formulas

## Hourly Rates
- Junior engineer: $150/hr
- Senior engineer: $250/hr
- Principal engineer: $350/hr

## Complexity Multipliers
| Complexity | Multiplier |
|------------|------------|
| Low        | 1.0x       |
| Medium     | 1.5x       |
| High       | 2.5x       |

## Formula
(hours × rate) × complexity_multiplier × risk_factor
```

`SKILL.md`:
```markdown
## Step 3: Calculate Value

Consult `references/rate-tables.md` for hourly rates, complexity multipliers, and the estimation formula. Apply the formula to the gathered data.
```

The SKILL.md step is now focused on *what to do*, while the reference file holds *what to know*.

### Rule: Frontmatter descriptions must earn every word

Level 1 content (frontmatter) is loaded into every conversation. A description that wastes tokens on filler — vague adjectives, redundant phrasing, or information that doesn't improve trigger accuracy — costs tokens across all conversations without benefit.

**Before (verbose, low-signal):**
```yaml
description: >
  A comprehensive and powerful skill that helps users with various aspects
  of code review, providing thorough analysis and detailed feedback on
  code quality and best practices.
```

**After (concise, high-signal):**
```yaml
description: >
  Run a full code review on the current git branch's changes against the default
  branch. Use when reviewing, auditing, or checking code quality on local changes
  before or after pushing. Does not post to GitHub — use post-code-review-to-pr to post
  review comments to a pull request.
```

Every sentence in the "after" version serves a purpose: what it does, when to use it, and what it doesn't do. See [Skill Description Frontmatter](./skill-description-frontmatter.md) for the full description-writing rules.

### Rule: Use scripts/ for deterministic operations

When a step requires deterministic computation — validation, data transformation, JSON construction, API calls with specific parameters — extract it to a shell script rather than relying on Claude to interpret language instructions. Code is deterministic; language interpretation isn't.

**Before (language instruction):**
```markdown
## Step 5: Post Review

Construct a JSON payload with the review body, commit SHA, and event type.
POST it to the GitHub API at the pulls/reviews endpoint. Make sure to
properly escape the review body for JSON.
```

**After (script reference):**
```markdown
## Step 5: Post Review

Run `scripts/post-pr-review.sh {owner/repo} {pr_number} {head_sha} {event_type} /tmp/pr-review-body.md` to post the review to GitHub.
```

The script handles JSON construction, escaping, and API calls — operations where correctness matters more than flexibility.

## Summary Checklist

1. Level 1 (frontmatter) is always loaded — keep descriptions concise and high-signal
2. Level 2 (SKILL.md body) loads on trigger — focus on process steps and execution logic
3. Level 3 (references/ and scripts/) loads on demand — store domain knowledge, templates, and deterministic operations here
4. Extract templates, checklists, rate tables, and decision matrices to `references/`
5. Keep step-by-step process instructions, context injection, and conditional logic in SKILL.md
6. Use `scripts/` for deterministic operations where correctness matters more than flexibility
7. Every token in frontmatter costs context in every conversation — make it count

Cross-references:
- [Skill Reference Files](./skill-reference-files.md) — Placement rules for the `references/` directory
- [Skill Description Frontmatter](./skill-description-frontmatter.md) — Rules for writing effective Level 1 descriptions
- [Context Injection Commands](./context-injection-commands.md) — How to inject runtime data into Level 2 content
- [Context Hygiene](./context-hygiene.md) — The scientific rationale behind the three-level architecture
