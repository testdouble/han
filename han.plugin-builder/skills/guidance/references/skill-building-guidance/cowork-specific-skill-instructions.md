---
paths:
  - "**/skills/**/*.md"
---

# Claude Cowork — Complete Reference

## What is Cowork?

Claude Cowork is Anthropic's agentic AI system for knowledge workers (not developers), available as a research preview in the Claude Desktop app (Mac/Windows) and claude.ai. Unlike Claude Chat (one prompt → one response), Cowork autonomously plans and executes multi-step tasks on your local machine.

**Target users:** Researchers, analysts, operations, legal, finance — anyone doing time-consuming document/data/file work.

**Requirements:** Paid plan (Pro, Max, Team, Enterprise), Claude Desktop app or claude.ai, code execution enabled.

---

## What Cowork Can Do

- Direct local file access (read/write without manual uploads)
- Multi-step autonomous task execution
- Parallel subtask coordination
- Create formatted spreadsheets (with formulas), PowerPoint presentations, Word documents, PDFs
- File organization (rename, sort, deduplicate)
- Research synthesis across multiple sources
- Data extraction from unstructured documents
- Scheduled/recurring automation tasks

---

## Cowork vs. Claude Code: Extension Model

| Feature        | Claude Code                          | Claude.ai / Cowork   |
| -------------- | ------------------------------------ | -------------------- |
| Plugins        | Yes (`.claude-plugin/`, marketplace) | **No**               |
| Skills         | Yes (filesystem directories)         | **Yes** (ZIP upload) |
| Agents         | Yes (part of plugins)                | No                   |
| Hooks          | Yes (part of plugins)                | No                   |
| Slash commands | Yes (part of plugins/skills)         | No                   |

**Cowork only supports Skills** — not the full Claude Code plugin system.

---

## Skills in Cowork

Skills are the only extension mechanism. Cowork ships with four pre-built Skills:

- **PowerPoint (pptx)** — create/edit presentations
- **Excel (xlsx)** — create spreadsheets, analyze data, generate charts
- **Word (docx)** — create/edit/format documents
- **PDF (pdf)** — generate formatted PDF documents and reports

Custom Skills are uploaded as **ZIP files** via **Settings > Features**. Available on Pro, Max, Team, and Enterprise plans.

**Sharing:** Custom Skills are per-user only. Each team member must upload separately. No org-wide or admin-managed distribution on claude.ai.

---

## Skill File Format

Every Skill requires a `SKILL.md` file with YAML frontmatter:

````yaml
---
name: processing-pdfs
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## Quick start

Use pdfplumber for text extraction:

```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
````

For form filling, see [FORMS.md](FORMS.md).

```

### Frontmatter field rules

**`name`**
- Max 64 characters
- Lowercase letters, numbers, and hyphens only
- No XML tags
- Cannot contain reserved words: `anthropic`, `claude`

**`description`**
- Non-empty, max 1024 characters
- No XML tags
- Must be written in **third person** ("Processes Excel files" — not "I can help you")
- Must describe both **what** the skill does and **when** to use it
- Claude uses this to auto-select the right skill from potentially 100+ installed

---

## Skill Directory Structure

```

your-skill/
├── SKILL.md # Required: frontmatter + instructions
├── FORMS.md # Optional: referenced as-needed
├── reference/
│ ├── finance.md # Optional: domain-specific reference
│ └── sales.md
└── scripts/
├── process.py # Optional: utility scripts (executed, not read)
└── validate.py

````

ZIP the skill folder itself (not a wrapper folder) for upload to Cowork.

---

## How Skills Load (Progressive Disclosure)

Skills use a 3-level loading model to minimize context usage:

| Level | When Loaded | Token Cost | Content |
|---|---|---|---|
| **1: Metadata** | Always (at startup) | ~100 tokens/skill | `name` + `description` from frontmatter |
| **2: Instructions** | When skill is triggered | Under 5k tokens | SKILL.md body |
| **3: Resources/code** | As needed | Effectively unlimited | Bundled files, scripts |

Claude reads `SKILL.md` via bash only when your request matches the description. Additional files (FORMS.md, reference/*.md) are read only when SKILL.md references them. Scripts are **executed** — their code never enters the context window, only their output does.

---

## Cowork Runtime Environment

- **Network access:** Varies by user/admin settings (full, partial, or none)
- **Package installation:** Can install from npm and PyPI, and pull from GitHub repos
- Scripts run in a VM with filesystem access and bash

This is more permissive than the Claude API (which has no network access) but less predictable than Claude Code (which has full network access like any local program).

---

## Authoring Best Practices

### Descriptions
- Be specific; include key trigger terms
- Third person only
- Include both what it does and when to use it

**Good:**
```yaml
description: Analyzes Excel spreadsheets, creates pivot tables, generates charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
````

**Bad:**

```yaml
description: Helps with documents
```

### Conciseness

- Keep `SKILL.md` body under **500 lines**
- Don't explain things Claude already knows
- Put detail in separate referenced files

### Progressive disclosure patterns

**Pattern 1 — High-level guide with references:**

```markdown
## Advanced features

**Form filling**: See [FORMS.md](FORMS.md)
**API reference**: See [REFERENCE.md](REFERENCE.md)
```

**Pattern 2 — Domain-specific organization:**

```
bigquery-skill/
├── SKILL.md (overview + navigation)
└── reference/
    ├── finance.md
    ├── sales.md
    └── product.md
```

**Pattern 3 — Conditional details:**

```markdown
For tracked changes: See [REDLINING.md](REDLINING.md)
For OOXML details: See [OOXML.md](OOXML.md)
```

Keep all references **one level deep** from SKILL.md. Avoid nested references (SKILL.md → A.md → B.md) — Claude may only partially read nested files.

### Degrees of freedom

- **High freedom** (text instructions): when multiple approaches are valid
- **Medium freedom** (pseudocode/parameterized scripts): when a preferred pattern exists
- **Low freedom** (exact scripts, specific commands): for fragile/critical operations like DB migrations

### Workflows

Break complex tasks into numbered steps. For multi-step operations, provide a checklist Claude can track:

```markdown
## Form filling workflow

Copy this checklist:

- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form
- [ ] Step 5: Verify output
```

### Scripts

- Pre-made scripts are more reliable than asking Claude to generate code on the fly
- Script code never enters context — only output does
- Be explicit: "Run `analyze_form.py`" (execute) vs "See `analyze_form.py` for the algorithm" (read)
- Handle errors in scripts explicitly; don't punt errors to Claude
- Always use forward slashes in paths (no Windows-style backslashes)
- List required packages explicitly in instructions

### Naming conventions

Use gerund form (verb + -ing):

- `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`
- Avoid: `helper`, `utils`, `tools`, `documents`

This gerund preference is the general Anthropic convention, not Cowork-specific. [Naming Conventions](./naming-conventions.md) is the canonical doc for skill and plugin naming; it covers the same gerund rule plus directory-name, dependency-prefix, and case-sensitivity rules.

---

## Checklist Before Uploading a Skill

**Core quality**

- [ ] Description is specific, third-person, includes what + when
- [ ] SKILL.md body under 500 lines
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] File references are one level deep from SKILL.md
- [ ] Workflows have clear numbered steps

**Code and scripts**

- [ ] Scripts handle errors explicitly (don't punt to Claude)
- [ ] Required packages listed and verified available
- [ ] No Windows-style paths (all forward slashes)
- [ ] Validation/feedback loops for critical operations

**Testing**

- [ ] Tested with real usage scenarios
- [ ] Tested with multiple Claude model tiers if applicable

---

## Resources

- Product page: `anthropic.com/product/claude-cowork`
- Skills overview: `platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`
- Skills best practices: `platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices`
- Skills cookbook: `platform.claude.com/cookbook/skills-notebooks-01-skills-introduction`
- Free intro course: Anthropic Academy — "Introduction to Claude Cowork"
- Open-source Skills repo: `github.com/anthropics/skills`
