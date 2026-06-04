---
paths:
  - "**/skills/**/*.md"
---

# Hardening: Fuzzy vs. Deterministic Steps

Other guidance docs tell you to extract deterministic operations to scripts ([Progressive Disclosure](./progressive-disclosure.md), [Writing Effective Instructions](./writing-effective-instructions.md)). This doc provides the decision framework for recognizing which steps are candidates and classifying them correctly.

The core insight: LLMs excel at fuzzy reasoning (summarization, classification, judgment calls) but introduce unnecessary unreliability when used for mechanical operations that have one correct answer. Separating these concerns — keeping fuzzy steps as SKILL.md instructions and extracting deterministic steps to scripts — makes skills more reliable without reducing their capabilities.

## The Fuzzy-Deterministic Spectrum

Every step in a skill falls somewhere on this spectrum:

### Fuzzy Steps

Require judgment, context, creativity, or interpretation. The "right answer" depends on circumstances and there are multiple acceptable outputs.

**Examples:** Analyzing code for quality issues, summarizing findings, choosing an investigation strategy, classifying severity, writing documentation prose.

**Where they belong:** SKILL.md instructions. These are what the LLM is good at.

### Deterministic Steps

Have one correct output for a given input. Can be validated mechanically. Correctness matters more than flexibility.

**Examples:** Constructing JSON payloads, making API calls with specific parameters, validating file formats, running git commands with exact flags, escaping strings, computing checksums.

**Where they belong:** Shell scripts in `scripts/`. See [Script Execution Instructions](./script-execution-instructions.md) for the invocation pattern.

### Hybrid Steps

Require judgment to decide *what* to do, then mechanical execution to *do it*. Split these into two sub-steps: the fuzzy decision stays in SKILL.md, the mechanical execution moves to a script.

**Example:** A code review skill that decides which findings to include (fuzzy) and then constructs a structured JSON review payload (deterministic). The decision stays in SKILL.md; the JSON construction moves to a script.

## Recognition Signals

These patterns in SKILL.md instructions suggest a step should be hardened:

- **Precise prose for mechanical work** — You're writing careful, exact language instructions for something that has an unambiguous correct output. If the instruction reads like pseudocode, it should probably be actual code.
- **"Make sure to" and "Don't forget to"** — These phrases in the context of a mechanical operation signal that the operation is error-prone when done via language instructions. Scripts don't forget.
- **String manipulation instructions** — Escaping, formatting, encoding, templating. These are classic sources of intermittent failures when left to language interpretation.
- **API call construction** — Specific endpoints, headers, authentication patterns, request body formats. One wrong field and the call fails.
- **File format requirements** — YAML frontmatter construction, JSON schema compliance, CSV formatting. Format correctness is binary, not fuzzy.

## The Hardening Process

1. **Identify** a step that matches the recognition signals above
2. **Classify** it as deterministic or hybrid using the spectrum
3. **Write the script** — extract the mechanical logic into a shell script in `scripts/`
4. **Update SKILL.md** — replace the prose instructions with a script invocation step (see [Script Execution Instructions](./script-execution-instructions.md) for the correct pattern)
5. **Test** — verify the script produces the same output that Claude was generating via language instructions, consistently

## When NOT to Harden

- **The workflow is still in flux** — don't build production scripts for steps that may change next iteration. Harden after the workflow stabilizes.
- **The step genuinely requires judgment** — summarization, analysis, classification, and creative work should stay as SKILL.md instructions even if you wish they were more consistent.
- **The step runs once and is trivial** — a single `git branch --show-current` call doesn't need a wrapper script. Use context injection (`` !`command` ``) for simple runtime data.

## Summary Checklist

1. Classify every step as fuzzy, deterministic, or hybrid
2. Keep fuzzy steps as SKILL.md instructions
3. Extract deterministic steps to `scripts/`
4. Split hybrid steps: fuzzy decision in SKILL.md, mechanical execution in script
5. Watch for recognition signals: precise prose for mechanical work, "make sure to" phrases, string manipulation, API construction, format requirements
6. Don't harden prematurely — wait for the workflow to stabilize

Cross-references:
- [Script Execution Instructions](./script-execution-instructions.md) — How to invoke scripts from SKILL.md
- [Progressive Disclosure](./progressive-disclosure.md) — Where scripts live in the three-level architecture (Rule: Use scripts/ for deterministic operations)
- [Writing Effective Instructions](./writing-effective-instructions.md) — Rule: Use scripts for deterministic validation
