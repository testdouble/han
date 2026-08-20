---
paths:
  - "**/skills/**/*.md"
---

# Skill Reference Files

## Contents

- Why References Exist: Progressive Disclosure
- The Rule
- Keep Reference Links One Level Deep from SKILL.md
- Give a Reference File Over 100 Lines a Table of Contents
- Directory Structure
- The `assets/` Directory
- Skills vs. Agents
- Summary Checklist

Skills can include reference documents — templates, checklists, examples, and other supporting content — in a
`references/` subdirectory within the skill folder. These files are loaded into the skill's context on demand when a
step explicitly references them.

## Why References Exist: Progressive Disclosure

References are the third level of the skill's progressive disclosure architecture. The SKILL.md body (Level 2) contains
process steps — _what to do_. References (Level 3) contain domain knowledge — _what to know_. This separation keeps the
skill body focused on execution logic while making domain knowledge available on demand.

Extract content to `references/` when it represents domain knowledge rather than process steps:

- **Templates** that define output structure (ADR templates, PR description templates, documentation templates)
- **Checklists** that guide evaluation (OWASP top 10, review checklists, documentation checklists)
- **Rate tables and formulas** used in calculations (pricing tables, complexity scores, risk assessments)
- **Decision matrices** with multiple criteria (scoring rubrics, selection frameworks)
- **Style guides** that define standards (voice guidelines, formatting rules, naming conventions)
- **Canonical examples** that demonstrate conventions the skill enforces (2-3 representative "do this / not this" code
  samples per convention)

Reference files are not passive lookups — they are demonstration material the model pattern-matches against during
execution. Every example in a reference file functions as a few-shot demonstration that calibrates the model's output.

Keep content in SKILL.md when it's a process step: numbered instructions, conditional logic, tool invocations, error
handling, and context injection commands.

See [Progressive Disclosure](./progressive-disclosure.md) for the full three-level architecture.

## The Rule

Place all reference files (templates, checklists, guides, etc.) in the `references/` subdirectory of the skill, not at
the skill directory root.

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

## Keep Reference Links One Level Deep from SKILL.md

Every reference file a run needs must be linked directly from SKILL.md. When Claude reaches a file through another
reference file — SKILL.md, then `evidence-rule.md`, then `yagni-rule.md` — it may preview that third file with a partial
read such as `head -100` rather than reading it whole, and the run proceeds on part of the content.

**Before (two hops to the content):**

```markdown
<!-- SKILL.md -->

Apply the evidence standard in [references/evidence-rule.md](./references/evidence-rule.md).

<!-- references/evidence-rule.md -->

This rule supplements [yagni-rule.md](./yagni-rule.md).
```

`yagni-rule.md` is reachable only through `evidence-rule.md`, so the run may get part of it.

**After (both files linked from SKILL.md):**

```markdown
<!-- SKILL.md -->

Apply the inclusion gate in [references/yagni-rule.md](./references/yagni-rule.md) and the evidence standard in
[references/evidence-rule.md](./references/evidence-rule.md).
```

The rule is about reachability, not about forbidding links between reference files. Once both files are linked from
SKILL.md, a cross-link from one to the other is a navigation aid rather than the only path. What the rule forbids is a
file reachable **only** through another reference file.

A reference file must also stay inside its own plugin. A link that climbs out of the plugin directory (`../../docs/`)
resolves in the source repository and breaks for everyone who installs the plugin, because only the plugin directory
ships. Name the external document in prose, or link it by its public URL.

## Give a Reference File Over 100 Lines a Table of Contents

A reference file longer than roughly 100 lines opens with a `## Contents` list of its own section headings. Claude often
previews a long file with a partial read, and a contents list at the top means even a partial read shows the full scope
of what the file holds, so nothing further down goes unnoticed.

```markdown
# API Reference

## Contents

- Authentication and setup
- Core methods
- Error handling patterns

## Authentication and setup

...
```

List the headings that name the file's real sections, and stop there. Usually those are the `##` headings. When a file
puts its sections one level down under a single `##` wrapper — a `## The Rules` holding ten `### Rule: ...` headings —
list the inner ones instead, because a two-entry contents list tells a reader nothing. A list that mirrors every
sub-heading of an already well-sectioned file costs more than the partial read it protects against.

**The exception: output templates.** A reference file that is a skeleton copied whole into a produced document — an ADR
template, a report template, a specification template — gets no contents list, because the list would be copied into
every document the template produces. Keep those files free of a table of contents no matter how long they run, and
have the SKILL.md step that loads one say it is copied whole so the run reads all of it.

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

- **`references/`** — Documents loaded into the skill's context when a step explicitly references them. Use for
  templates, checklists, style guides, and other content the skill needs to reference during execution.
- **`scripts/`** — Shell scripts called by the skill's step logic. Use for complex operations that need pipes,
  redirects, or multi-step logic (see
  [Context Injection Commands](./context-injection-commands.md#rule-use-shell-scripts-for-complex-operations)).

## The `assets/` Directory

Skills may also include an `assets/` directory for files used in output but not injected as context — templates that are
copied to the output location, fonts, icons, or other non-context resources. Unlike `references/`, files in `assets/`
are not loaded into Claude's context window.

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

Use `assets/` when a skill needs to reference files for output generation rather than for Claude's reasoning.
Establishing this convention early prevents conflicting patterns from emerging.

## Skills vs. Agents

Skills support `references/` and `scripts/` directories. Agents do not — agent definitions are self-contained markdown
files with all content inlined.

| Entity | `references/` | `scripts/` |
| ------ | ------------- | ---------- |
| Skills | Yes           | Yes        |
| Agents | No            | No         |

If an agent needs substantial reference content, inline it directly in the agent `.md` file. See
[External File References in Agent Definitions](../agent-building-guidelines/agent-external-files.md).

## Summary Checklist

1. Place templates, checklists, and reference content in `references/` within the skill directory
2. Do not place reference files at the skill directory root
3. Use `scripts/` for shell scripts, `references/` for documents
4. Use `assets/` for output files (templates, fonts, icons) not intended as context
5. Extract domain knowledge (templates, checklists, rate tables, decision matrices) to `references/`
6. Keep process steps and execution logic in SKILL.md
7. Link every reference file a run needs directly from SKILL.md, so no file is reachable only through another one
8. Keep every reference link inside the plugin directory — a link that climbs out of it breaks once the plugin is installed
9. Open a reference file over roughly 100 lines with a `## Contents` list of its `##` headings, unless it is a template copied whole into output
10. Agents are self-contained — no `references/` or `scripts/` support

Cross-references:

- [External File References in Agent Definitions](../agent-building-guidelines/agent-external-files.md) — Why agents
  don't support references
- [Context Injection Commands](./context-injection-commands.md) — How injected context relates to reference files
- [Progressive Disclosure](./progressive-disclosure.md) — The three-level architecture that references are part of
- [Skill Decomposition](./skill-decomposition.md) — What to do when a reference file grows past what one file should hold
