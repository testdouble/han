---
paths:
  - "**/skills/**/*.md"
---

# Context Hygiene

Context hygiene is the discipline of keeping a skill's context footprint minimal, well-positioned, and free of stale or irrelevant tokens. Several other guidance docs contain rules that serve this goal — progressive disclosure, frontmatter conciseness, extracting to references/, position-aware ordering, stale-doc audits. This doc explains the mechanisms behind those rules: why they work and what happens when they're violated. It is based on the [Context Hygiene principle](https://jdforsythe.github.io/10-principles/principles/context-hygiene/), adapted for skill-building concerns.

Research on transformer attention shows that every token in context competes for attention weight. Irrelevant tokens don't just waste space — they actively dilute the model's ability to attend to the tokens that matter. Adding a paragraph of boilerplate to a SKILL.md doesn't cost "a few tokens of overhead." It degrades the model's attention on every other instruction in that skill. This is the mechanism behind progressive-disclosure's three-level architecture, frontmatter conciseness in skill-description-frontmatter.md, and extracting domain knowledge to `references/`.

Research on context position shows that information at the beginning and end of the context window receives disproportionate attention weight, while information in the middle receives less — a pattern sometimes called "lost in the middle." Additionally, focused context outperforms accumulated context: performance peaks at roughly 15-40% context window utilization — enough grounding to prevent hallucination, not so much that relevant tokens get buried in noise. These effects are the mechanism behind the recency bias rule in workflow-patterns.md and the "don't bury critical instructions" rule in writing-effective-instructions.md.

## The Rules

### Rule: Every token must earn its place

Before adding content to a SKILL.md, its frontmatter, or its references, ask: does this token improve the skill's output? Content that doesn't improve output — filler prose, redundant explanations, restated context that the model already has — doesn't just take up space. It competes for attention with the tokens that do matter.

This is the unifying principle behind several rules in other docs:
- Frontmatter descriptions must earn every word ([Skill Description Frontmatter](./skill-description-frontmatter.md))
- Domain knowledge belongs in `references/`, loaded only when needed ([Progressive Disclosure](./progressive-disclosure.md))
- Deterministic operations belong in `scripts/`, whose code never enters context ([Progressive Disclosure](./progressive-disclosure.md))
- Rules enforced by linters and formatters should be removed entirely ([Progressive Disclosure](./progressive-disclosure.md))

**Before (tokens that don't earn their place):**
```markdown
## Step 2: Analyze the Code

You are now going to analyze the code changes. This is an important step
because code quality matters and we want to make sure everything is good.
Take your time and be thorough. Look at the changes carefully and consider
all aspects of the code including readability, maintainability, and
correctness. Make sure to check for any issues that might cause problems.

For each file, review the changes and note any findings.
```
Six sentences of filler before the one actionable instruction. Every filler token competes for attention with "For each file, review the changes and note any findings."

**After (every token earns its place):**
```markdown
## Step 2: Analyze the Code

For each changed file:
1. Read the full file for context, not just the diff
2. Check against `references/review-checklist.md`
3. Classify each finding as critical, warning, or suggestion
4. Record the file path and line number for each finding
```

### Rule: Build a self-sufficient region at the point of use

The previous rule cuts redundant tokens. This one keeps the tokens a step needs together. Both protect the model's limited attention.

When a step acts, give it a region that already carries what the step needs — so the model isn't left reconstructing which reference applies where. A single instruction applied to the data in front of it is cheap; the model does that constantly and well. What's costly is a step that makes it hold several references at once and route each to a different, overlapping set of targets — "run the items from [A], but apply [B] to items 2 and 3 and [C] to items 1 and 4." Every extra binding the model has to track and route in one pass is another chance to mis-route. That routing is work you can do for it.

A region is **self-sufficient** when the routing is already resolved: the step names what applies to what, with nothing left for the model to reconstruct. That is stronger than merely moving the references next to the step — it removes the bookkeeping rather than shortening the reach. A step that Reads one `references/checklist.md` and applies it is fine (a **loadable pointer**: one thing, in focus, applied uniformly). A step that hands the model three references and a mapping of which applies where is an **in-head reference** — collapse that mapping before the model sees it.

This is the idea progressive disclosure already runs on: a `references/` file is a self-sufficient region, Read into focus only when a step needs it. Keep the source normalized, and build the region a step acts from at the point of use. See [Resolve variation at the point of use](./writing-effective-instructions.md) for the form this takes when a step drives many similar items.

### Rule: Position critical content at the edges, not the middle

Front-load constraints, prerequisites, and context that shapes the entire skill execution. Back-load checklists, validation criteria, and summary structures. Avoid placing the skill's most important instructions in the middle steps, where they receive the least attention weight.

This extends the within-step recency bias guidance in [Workflow Patterns](./workflow-patterns.md) to the overall SKILL.md structure. The same principle applies at both levels: the model weights the beginning and end more heavily than the middle.

**Before (critical constraint buried in Step 4 of 6):**
```markdown
## Project Context

- Branch: !`git branch --show-current`

## Step 1: Gather Changes
Read the diff between the current branch and the default branch.

## Step 2: Categorize Files
Group changed files by type: source, test, config, docs.

## Step 3: Review Source Files
For each source file, check for issues.

## Step 4: Security Constraint
IMPORTANT: This project handles PII. All findings must be evaluated for
data exposure risk. Flag any change that touches user data fields.

## Step 5: Generate Report
Write the review report.

## Step 6: Summary Checklist
Verify all sections are complete.
```
The security constraint — the single most important instruction — sits in the middle where it gets the least attention.

**After (critical constraint front-loaded):**
```markdown
## Project Context

- Branch: !`git branch --show-current`

## Constraints

This project handles PII. Evaluate every finding for data exposure risk.
Flag any change that touches user data fields.

## Step 1: Gather Changes
Read the diff between the current branch and the default branch.

## Step 2: Categorize Files
Group changed files by type: source, test, config, docs.

## Step 3: Review Source Files
For each source file, check for issues.

## Step 4: Generate Report
Write the review report.

## Step 5: Summary Checklist
Verify all sections are complete.
```
The constraint now appears at the top, in a dedicated section that shapes every subsequent step.

### Rule: Do not restate what the toolchain or platform already provides

Content that duplicates what the model already sees — linter rules, CLAUDE.md project context that the platform auto-loads, MCP tool documentation from tool schemas, or Claude Code's built-in behaviors — wastes attention budget and creates drift risk when the source changes. This extends the "when to remove entirely" guidance in [Progressive Disclosure](./progressive-disclosure.md) beyond linters to include all platform-provided context. See that doc for full examples and rationale.

### Rule: Remember that loaded skill content persists under a compaction budget

Once a skill is invoked, its SKILL.md content stays in context for the rest of the session. When Claude Code auto-compacts, it carries skills forward within a shared budget of roughly 25,000 tokens, re-attaching the most recently invoked skills first and capping each at about 5,000 tokens. A bloated SKILL.md does not just dilute attention while it runs; it crowds the post-compaction budget, and in a session that invoked many skills, the oldest or largest can be dropped entirely. Keeping the body lean (see [Progressive Disclosure](./progressive-disclosure.md)) is what keeps a skill present and intact after compaction. Source: [Claude Code Skills documentation](https://code.claude.com/docs/en/skills).

### Rule: Treat stale context as a bug, not tech debt

Stale tokens are worse than absent tokens. When a reference file describes a convention that was abandoned or a script path that was renamed, the model follows the stale instruction faithfully — producing confidently wrong output. The attention mechanism doesn't distinguish "current" from "outdated." Stale tokens compete for attention on equal footing with current ones, but they point the model in the wrong direction. See [Documentation Maintenance](./documentation-maintenance.md) for the full audit process, triggers, and examples.

## Anti-Patterns

| Anti-pattern | Why it hurts | Where to fix it |
|---|---|---|
| Kitchen sink SKILL.md | Token competition dilutes attention on every instruction | [Progressive Disclosure](./progressive-disclosure.md) |
| Restating toolchain rules | Wastes attention budget; drifts when config changes | [Progressive Disclosure](./progressive-disclosure.md) |
| In-head join (matrix joined against a separate list) | Attention fragments across the blocks the model must join | [Writing Effective Instructions](./writing-effective-instructions.md) |
| Stale references | Model faithfully follows outdated instructions | [Documentation Maintenance](./documentation-maintenance.md) |
| Critical instruction buried in middle steps | Lost-in-the-middle reduces attention weight | [Workflow Patterns](./workflow-patterns.md) |
| Verbose frontmatter descriptions | Token cost paid in every conversation | [Skill Description Frontmatter](./skill-description-frontmatter.md) |

## Summary Checklist

1. Every token in SKILL.md, frontmatter, and references must improve the skill's output — cut filler
2. Front-load constraints and prerequisites; back-load checklists and validation
3. Do not restate rules enforced by linters, formatters, or the platform
4. Treat stale documentation as a functional bug — audit when dependencies change
5. Extract domain knowledge to `references/` to keep the SKILL.md body lean
6. Place the most important instruction or example last within any list (recency bias)
7. Give each step a self-sufficient region to act from — reachable when it runs, with nothing to join from elsewhere

Cross-references:
- [Progressive Disclosure](./progressive-disclosure.md) — The three-level architecture that controls context loading
- [Workflow Patterns](./workflow-patterns.md) — Recency bias and lost-in-the-middle within step design
- [Writing Effective Instructions](./writing-effective-instructions.md) — Conciseness and structure rules for SKILL.md body
- [Multi-Agent Economics](../agent-building-guidelines/multi-agent-economics.md) — Self-contained briefs across the sub-agent boundary
- [Skill Description Frontmatter](./skill-description-frontmatter.md) — Frontmatter token efficiency and trigger accuracy
- [Documentation Maintenance](./documentation-maintenance.md) — Audit process for stale context
