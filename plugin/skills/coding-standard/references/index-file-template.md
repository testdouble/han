---
paths:
  - "{glob-1}"
  - "{glob-2}"
---

# {File-type} coding standards index

You are reading this file because Claude Code loaded it as a path-scoped
rule — you just read or are about to read a file matching one of the
globs in this file's `paths:` frontmatter.

This file is an **index**, not a standard. Each entry below points to a
canonical coding standard with a short description of what it covers and
when it applies.

Coding standards for this project live in their canonical documentation
directory (usually `docs/coding-standards/`) and are exposed to Claude
Code through per-file-type index files under
`.claude/rules/coding-standards/`. The full text of a standard is loaded
only when you decide it applies and use the Read tool to open it. This
keeps context lean and lets you make a relevance decision before paying
the token cost.

**Do not read every linked standard.** For the specific task you are
doing right now, scan the descriptions and identify only the standards
that are clearly relevant. Then use the Read tool to open just those
files. If no entry is clearly relevant, do not open any of them.

If you are unsure whether a standard applies, do not open it. The
author of the work can prompt you to load a specific standard if needed.
Loading standards that do not apply burns context and dilutes attention
on the ones that do.

## Available standards

- [{Standard title}]({relative/path/to/standard.md}) — {1-3 sentence
  description of what this standard covers and when a reader should
  pull the full file.}
