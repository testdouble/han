---
paths:
  - "**/skills/**/*.md"
---

# Skill Reference Files

Skills can include reference documents — templates, checklists, examples, and other supporting content — in a `references/` subdirectory within the skill folder. These files are loaded into the skill's context on demand when a step explicitly references them.

## Why References Exist: Progressive Disclosure

References are the third level of the skill's progressive disclosure architecture. The SKILL.md body (Level 2) contains process steps — *what to do*. References (Level 3) contain domain knowledge — *what to know*. This separation keeps the skill body focused on execution logic while making domain knowledge available on demand.

Extract content to `references/` when it represents domain knowledge rather than process steps:
- **Templates** that define output structure (ADR templates, PR description templates, documentation templates)
- **Checklists** that guide evaluation (OWASP top 10, review checklists, documentation checklists)
- **Rate tables and formulas** used in calculations (pricing tables, complexity scores, risk assessments)
- **Decision matrices** with multiple criteria (scoring rubrics, selection frameworks)
- **Style guides** that define standards (voice guidelines, formatting rules, naming conventions)
- **Canonical examples** that demonstrate conventions the skill enforces (2-3 representative "do this / not this" code samples per convention)

Reference files are not passive lookups — they are demonstration material the model pattern-matches against during execution. Every example in a reference file functions as a few-shot demonstration that calibrates the model's output.

Keep content in SKILL.md when it's a process step: numbered instructions, conditional logic, tool invocations, error handling, and context injection commands.

See [Progressive Disclosure](./progressive-disclosure.md) for the full three-level architecture.

## The Rule

Place all reference files (templates, checklists, guides, etc.) in the `references/` subdirectory of the skill, not at the skill directory root.

**Before (wrong location):**
```
skills/
  code-review/
    SKILL.md
    owasp-top10.md     # Reference file at skill root
    template.md        # Reference file at skill root
```
Files at the skill directory root may not be properly injected as context for the skill.

**After (correct location):**
```
skills/
  code-review/
    SKILL.md
    references/
      owasp-top10.md   # Loaded when referenced by a step
      template.md       # Loaded when referenced by a step
```
Moved into `references/` where the plugin system expects them.

## Directory Structure

The full skill directory layout:

```
skills/
  {skill-name}/
    SKILL.md           # Skill definition (frontmatter + prompt body)
    references/        # Optional: reference documents injected into context
      template.md
      checklist.md
    scripts/           # Optional: shell scripts used by the skill
      post-review.sh
```

- **`references/`** — Documents loaded into the skill's context when a step explicitly references them. Use for templates, checklists, style guides, and other content the skill needs to reference during execution.
- **`scripts/`** — Shell scripts called by the skill's step logic. Use for complex operations that need pipes, redirects, or multi-step logic (see [Context Injection Commands](./context-injection-commands.md#rule-use-shell-scripts-for-complex-operations)).

## The `assets/` Directory

Skills may also include an `assets/` directory for files used in output but not injected as context — templates that are copied to the output location, fonts, icons, or other non-context resources. Unlike `references/`, files in `assets/` are not loaded into Claude's context window.

```
skills/
  {skill-name}/
    SKILL.md
    references/        # Loaded on demand (domain knowledge)
    scripts/           # Executed by skill steps
    assets/            # Used in output, not loaded as context
      report-template.docx
      logo.png
```

Use `assets/` when a skill needs to reference files for output generation rather than for Claude's reasoning. Establishing this convention early prevents conflicting patterns from emerging.

## Skills vs. Agents

Skills support `references/` and `scripts/` directories. Agents do not — agent definitions are self-contained markdown files with all content inlined.

| Entity | `references/` | `scripts/` |
|--------|---------------|------------|
| Skills | Yes | Yes |
| Agents | No | No |

If an agent needs substantial reference content, inline it directly in the agent `.md` file. See [External File References in Agent Definitions](../agent-building-guidelines/agent-external-files.md).

## Summary Checklist

1. Place templates, checklists, and reference content in `references/` within the skill directory
2. Do not place reference files at the skill directory root
3. Use `scripts/` for shell scripts, `references/` for documents
4. Use `assets/` for output files (templates, fonts, icons) not intended as context
5. Extract domain knowledge (templates, checklists, rate tables, decision matrices) to `references/`
6. Keep process steps and execution logic in SKILL.md
7. Agents are self-contained — no `references/` or `scripts/` support

Cross-references:
- [External File References in Agent Definitions](../agent-building-guidelines/agent-external-files.md) — Why agents don't support references
- [Context Injection Commands](./context-injection-commands.md) — How injected context relates to reference files
- [Progressive Disclosure](./progressive-disclosure.md) — The three-level architecture that references are part of
