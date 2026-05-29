---
paths:
  - "han.core/skills/**/*.md"
  - "han.github/skills/**/*.md"
---

# Skill Description Frontmatter

The `description` field in SKILL.md frontmatter is the primary mechanism Claude uses to decide when to invoke a skill. Every installed skill's description is always loaded into Claude's context, where descriptions compete against each other for selection. A thin description means missed triggers — users ask for something the skill handles, but Claude doesn't recognize the match. An overbroad description means false triggers — Claude invokes the wrong skill because descriptions overlap without clear boundaries.

## How Description Matching Works

Three facts shape how descriptions should be written:

1. **Descriptions compete with each other.** When a user makes a request, Claude evaluates all loaded skill descriptions simultaneously. A skill with a vague one-liner loses to a sibling skill that explicitly names the user's intent.

2. **Semantic matching has limits.** Claude can infer related concepts, but common trigger words must appear explicitly. Don't assume Claude will connect "debug" to "investigate" or "PR" to "pull request" without those words appearing in the description. If users commonly phrase their request a certain way, that phrasing should be in the description.

3. **Context window cost is real.** Descriptions are always loaded, so they consume tokens in every conversation. Be thorough but not verbose — every sentence should earn its place by improving trigger accuracy or disambiguation.

## The Rules

### Rule: Every description must cover four components

A complete description answers four questions:

- **What** — What does this skill do?
- **When to use** — What user intents or situations should trigger it?
- **Boundary** — What should NOT trigger it? (When to use a different skill or no skill at all.)
- **Trigger breadth** — What alternative phrasings, synonyms, or related concepts should also match?

Minimum 3 sentences. Typically 3-5 sentences. Skills in crowded spaces (multiple similar skills in the same plugin) may need more to disambiguate.

**Before (1 sentence, `code-review`):**
```yaml
description: Run a full code review on the current git branch's changes
```
Missing when-to-use triggers, no boundary distinguishing it from `post-code-review-to-pr`, no trigger breadth.

**After (3 sentences):**
```yaml
description: >
  Run a full code review on the current git branch's changes against the default
  branch. Use when reviewing, auditing, or checking code quality on local changes
  before or after pushing. Does not post to GitHub — use post-code-review-to-pr to post
  review comments to a pull request.
```

**Before (1 sentence, `update-pr-description`):**
```yaml
description: Generate a PR description from the current branch's changes against a GitHub PR, using the gh CLI
```

**After (4 sentences):**
```yaml
description: >
  Generate a PR description from the current branch's changes against a GitHub
  PR, using the gh CLI. Use when writing, drafting, or updating pull request
  descriptions, PR summaries, or PR bodies. Requires the gh CLI to be installed
  and a PR to already exist for the current branch. Does not review code or post
  review comments — use code-review for local review or post-code-review-to-pr for posting
  a review to GitHub.
```

### Rule: Weave trigger words into prose — never append keyword lists

Include the words users actually type — synonyms, abbreviations, and common phrasings — but weave them into natural sentences that provide semantic context. Never append a bare keyword list. Keyword lists lack context, making it harder for Claude to judge relevance, and they waste tokens without improving accuracy.

**Before (keyword suffix, `writing-style`):**
```yaml
description: Apply Test Double's brand voice and writing standards when drafting, editing, or revising marketing content, thought leadership pieces, and practitioner-led content. Keywords - draft, edit, write, rewrite, summarize, revise, outline.
```

**After (woven prose):**
```yaml
description: >
  Apply Test Double's brand voice and writing standards when drafting, editing,
  revising, rewriting, summarizing, or outlining marketing content, thought
  leadership pieces, and practitioner-led content. Use when writing or polishing
  any content that should follow Test Double's style guide. Does not handle brand
  positioning or messaging framework — use brand-messaging for ICP, positioning,
  and campaign tone.
```

The trigger words ("draft," "edit," "rewrite," "summarize," "outline") are still present but embedded in a sentence that tells Claude what they mean in context.

### Rule: Define boundaries by naming sibling skills or scope limits

When sibling skills exist in the same plugin, name them explicitly in the boundary statement. When no siblings exist, describe the scope limit so Claude knows where the skill stops.

Disambiguation must work in **both directions**. If `code-review` says "use `post-code-review-to-pr` for GitHub posting," then `post-code-review-to-pr` must also say "use `code-review` for local review without GitHub." One-way disambiguation leaves a gap that Claude can fall through.

**Commonly confused skill pairs and their boundary statements:**

| Skill A | Skill B | How to disambiguate |
|---------|---------|---------------------|
| `code-review` | `post-code-review-to-pr` | Local analysis vs. GitHub integration |
| `update-pr-description` | `post-code-review-to-pr` | PR body/summary vs. review comments |
| `project-documentation` | `architectural-decision-record` | Feature/system docs vs. architectural decisions |
| `project-documentation` | `coding-standard` | Feature/system docs vs. coding standards |
| `coding-standard` | `architectural-decision-record` | Enforceable rules vs. decision records |
| `project-discovery` | `project-documentation` | Tech stack scanning vs. feature/system docs |
| `test-planning` | `code-review` | Test coverage plans vs. code quality review |
| `test-planning` | `iterative-plan-review` | Test plans vs. refining work plans |
| `brand-messaging` | `writing-style` | Positioning/ICP/campaigns vs. prose style/voice |

**Before (no boundary, `project-documentation`):**
```yaml
description: >
  Creates and maintains project documentation for features, systems, and
  components. Discovers project structure dynamically to work across any
  technology stack.
```

**After (names siblings):**
```yaml
description: >
  Creates and maintains project documentation for features, systems, and
  components. Discovers project structure dynamically to work across any
  technology stack. Use when documenting how a feature, system, or component
  works. Does not create architectural decision records — use architectural-decision-record for
  ADRs. Does not create or update coding standards — use coding-standard instead.
  Does not generate PR descriptions — use update-pr-description for that.
```

### Rule: Mention external requirements when they affect triggering

If a skill requires external tools (gh CLI, jq), specific preconditions (a PR must already exist), or a particular environment state, mention these in the description. This helps Claude choose between skills with different prerequisites — for example, choosing `code-review` (no dependencies) over `post-code-review-to-pr` (requires gh CLI and an open PR) when the prerequisites aren't met.

**Before:**
```yaml
description: Run a full pull request review for code changed in the current branch's GitHub PR, using the gh CLI, and post it to the GitHub PR
```

**After:**
```yaml
description: >
  Run a full pull request review and post it to the current branch's GitHub PR.
  Requires the gh CLI to be installed and a PR to already exist for the current
  branch. Use when you want review comments posted directly to GitHub. For local
  code review without GitHub, use code-review instead.
```

### Rule: Use negative triggers to prevent over-triggering

When a skill keeps activating for queries it shouldn't handle, add explicit negative trigger language to the description. Tell Claude what the skill does NOT do and which skill to use instead.

**Before (over-triggers on simple data questions):**
```yaml
description: >
  Advanced data analysis for CSV files. Use for statistical modeling,
  regression analysis, and clustering.
```

**After (negative trigger added):**
```yaml
description: >
  Advanced data analysis for CSV files. Use for statistical modeling,
  regression analysis, and clustering. Do NOT use for simple data
  exploration or visualization — use data-viz skill instead.
```

Negative triggers are especially useful when:
- Two skills share overlapping trigger words
- Users frequently confuse two skills
- The skill triggers on a broad category but should only handle a narrow subset

### Debugging: Ask Claude when it would use the skill

When a description isn't triggering correctly — either too rarely or too often — ask Claude directly:

> "When would you use the [skill name] skill?"

Claude will quote the description back and explain its understanding. Compare what Claude says against:
- The prompts that should trigger the skill (are they covered?)
- The prompts that should NOT trigger the skill (are boundaries clear?)

This is faster than trial-and-error with test prompts and reveals exactly what's missing from the description.

## Common Pitfalls

| Anti-pattern | Problem | Fix |
|--------------|---------|-----|
| Single sentence | Missing triggers, no boundary, no breadth | Add all four components (3+ sentences) |
| Keyword suffix (`Keywords - x, y, z`) | No semantic context, wasted tokens | Weave trigger words into prose |
| No boundary statement | False triggers from overlapping skills | Name sibling skills or scope limits |
| One-way disambiguation | Skill A points to B, but B doesn't point to A | Add boundary statements in both directions |
| Assumed inference | Expects Claude to connect "debug" to "investigate" | Include common phrasings explicitly |
| Excessive verbosity (7+ sentences) | Context window bloat, diminishing returns | Tighten to 3-5 sentences; every sentence must earn its place |

## Summary Checklist

1. Description covers **what** the skill does
2. Description covers **when to use** it (user intents and situations)
3. Description covers **boundaries** (when NOT to use it)
4. Description covers **trigger breadth** (synonyms, alternative phrasings)
5. Minimum 3 sentences; typically 3-5
6. Trigger words are woven into prose, not appended as keyword lists
7. Sibling skills are named explicitly in boundary statements
8. Disambiguation works in both directions between skill pairs
9. External requirements (tools, preconditions) are mentioned when they affect skill selection

Cross-references:
- [Naming Conventions](./naming-conventions.md) — Plugin and skill naming rules
- [Skill Decomposition](./skill-decomposition.md) — When to split skills that share trigger space
- [Troubleshooting](./troubleshooting.md) — Fixes for triggering problems (doesn't trigger, triggers too often)
- [Context Hygiene](./context-hygiene.md) — Why every frontmatter token carries a context cost
