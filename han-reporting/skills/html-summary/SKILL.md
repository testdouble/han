---
name: html-summary
description: >
  Convert a stakeholder summary markdown file into a single self-contained HTML executive report — bottom line and
  decision asks up front, supporting detail later — styled with a Test Double-derived palette and self-contained mermaid
  diagrams. Use when the user wants to turn a stakeholder summary, executive summary, or business summary into an HTML
  report, generate an HTML version of a summary doc, or produce a shareable HTML file from a summary markdown. Produces
  an HTML sibling file only; does not publish anything.
argument-hint: "[path to stakeholder-summary.md]"
allowed-tools: Read, Write
---

# HTML Summary

Convert a stakeholder summary markdown file into a single self-contained HTML report tailored for executive readers —
bottom line and decision asks up front, supporting detail later — styled with a Test Double-derived palette. The skill
produces one HTML file next to the source markdown and stops there.

## Inputs

- **Source markdown file** — usually a `stakeholder-summary.md` inside a planning folder. If the user does not name one,
  ask. Do not guess.

## Output

- **HTML sibling file** — written next to the source markdown, same basename, `.html` extension. Example:
  `filters-and-saved-views/stakeholder-summary.md` → `filters-and-saved-views/stakeholder-summary.html`. This is the
  only artifact the skill produces.

## Hard rules

- **Single file, no external network resources.** No `<link rel="stylesheet">`, no `<script src=...>` pointing at a CDN,
  no remote font loading, no remote images. Inlined JavaScript libraries (such as mermaid.js) are allowed and expected —
  they keep the file self-contained.
- **Inline all CSS** in a `<style>` block in `<head>`. The file must render correctly offline.
- **Do not modify the source markdown.** This skill is one-way: markdown in, HTML out.
- **Do not commit, push, or publish.** The skill writes the HTML file to disk and reports its path. Sharing the file is
  the user's call, outside this skill.
- **Executive ordering is non-negotiable.** Bottom line (TL;DR) and the stakeholder asks appear before any other
  content, in that order. Restructure if the source markdown puts them later. See `references/layout-principles.md`.
- **Use the report palette only.** Colors, typography, spacing, and component patterns come from
  `references/report-style.md`. Do not invent new accent colors.
- **Header: subject as the title, fixed subtitle, no brand mark.** The `<h1>` is the summary subject (the feature name).
  The `.subtitle` beneath it is the literal string `Han: Stakeholder Summary` on every report. The header carries no
  logo or brand mark.
- **No superlatives in user-visible text.** Banned word lists and rewrite patterns live in
  `references/writing-conventions.md`. Verify before finishing.
- **Apply the shared readability standard to prose.** Source the standard by invoking
  `han-communication:readability-guidance` and apply it to the prose content this skill writes or transfers, holding the
  named audience — the non-technical stakeholder. The report's visual layout stays governed by
  `references/layout-principles.md` and `references/report-style.md`.
- **Preserve the source's plain-language framing.** Do not rewrite content to be more technical or more abstract. Keep
  the source's wording where it works; tighten only when restructuring for the executive layout.

## Process

### 1. Locate the source markdown

If the source path is not in the conversation, ask for it. Resolve to an absolute path and confirm it exists. The output
HTML path is the source path with `.md` replaced by `.html`.

### 2. Read the source end-to-end

Read the entire markdown file. Identify which of these sections (or equivalents) are present, in any order:

- The bottom line / executive summary / TL;DR (sometimes implicit — derive from the opening paragraph)
- The stakeholder asks / open decisions (sometimes titled "What we are asking stakeholders" or similar)
- The problem statement
- What the change opens up / outcomes
- User experience walkthrough
- Today-vs-after data flow comparisons (sometimes with mermaid diagrams)
- What is intentionally not in scope

Section titles in the source may not match these names exactly — map by content, not heading text.

### 3. Load the references

Read all references before producing HTML:

- [references/report-style.md](./references/report-style.md) — palette, typography, mermaid theming, component patterns,
  accessibility notes.
- [references/layout-principles.md](./references/layout-principles.md) — executive ordering, what hoists to the top,
  full-width data-flow rule, mermaid diagram preservation rules.
- [references/writing-conventions.md](./references/writing-conventions.md) — banned words (no superlatives), rewrite
  patterns, tone signals.
- [references/html-template.html](./references/html-template.html) — the canonical reference HTML. Use its structure,
  class names, and CSS verbatim. Adapt content; do not invent new styles.

### 4. Produce the HTML

Write the HTML file to the output path. Required structure, in order:

1. **Header** — `<h1>` set to the summary subject (the feature name) with the most evocative noun phrase wrapped in
   `<span class="highlight">`; `.subtitle` set to the literal string `Han: Stakeholder Summary`. No brand mark.
2. **Bottom line card** — purple accent strip; one-sentence lead in larger type; 4–8 outcome bullets in a two-column
   list.
3. **Stakeholder asks card** — orange accent strip; numbered list of decisions the team needs from stakeholders. Each
   ask has a short title and a one-paragraph question ending with `**Confirm ...?**`. If the source has no asks section,
   omit this card entirely — do not invent decisions.
4. **Problem statement section**.
5. **What this opens up section** — outcome bullets.
6. **User experience walkthrough section** — numbered `walk` list.
7. **Data flow section** — `today` and `after` cards stacked **one per row**, each card spanning the page wrap's content
   width. Do not place data-flow cards side-by-side in a `.grid-2` wrapper. Each card contains a `<pre class="mermaid">`
   block with the source's mermaid syntax preserved (branching, decision diamonds, labeled edges). Normalize `style`
   directives to the report palette per `references/report-style.md`.
8. **Intentionally not in scope section** — `out-of-scope` list.

**Readability of the prose.** Invoke `han-communication:readability-guidance` to surface the shared readability standard
into your context; the text in these sections follows that standard — do not duplicate its text, apply it. Lead with the
main point (bottom line up front, which the executive ordering already enforces), give each heading a descriptive name
rather than a generic label, keep one idea per paragraph with the first sentence carrying it, number sequential steps
and bullet non-sequential items, and reveal detail in layers. This governs the prose only; the visual layout stays
governed by the layout conventions above.

The template includes a mermaid bundle placeholder near the end of `<body>`:

```html
<script id="mermaid-bundle">
  <!-- MERMAID_BUNDLE_INLINE_HERE -->
</script>
<script>
  mermaid.initialize({ ... });
</script>
```

Leave the placeholder string `<!-- MERMAID_BUNDLE_INLINE_HERE -->` exactly as written. The inliner script in Step 6
replaces it with the vendored mermaid.min.js bundle. The mermaid initialization block (with the report palette theme
variables) is also part of the template — paste it verbatim.

Section omission rules:

- Omit any section the source markdown does not address. Do not invent content to fill a section.
- The bottom line card is the only required section other than the header — if the source has no explicit TL;DR, derive
  one from the opening paragraph and clearly mark it as such in your work notes.

Markup rules:

- Use the entity `&mdash;` not `—` for em-dashes in HTML body content (the template does this consistently).
- Use the entity `&rarr;` for arrows in flow diagrams.
- Apply class names verbatim from the template — `tldr`, `ask-block`, `ask`, `walk`, `flow`, `node`, `node.good`,
  `node.bad`, `node.start`, `out-of-scope`, `chip`, `chip.good`, `chip.bad`.
- Wrap the feature-name portion of the `<h1>` in `<span class="highlight">` for the green background.

### 5. Verify the HTML

Open the file you just wrote and confirm:

- The `<style>` block exists in `<head>` and contains the `:root` palette variables from `references/report-style.md`.
- There are no `<link>`, `<script src=...>`, or external `url(...)` references in `<head>` or `<body>`.
- The `<h1>` is the summary subject and the `.subtitle` reads `Han: Stakeholder Summary`.
- Every section that exists in the source markdown has a corresponding section in the HTML.
- The bottom-line card and asks card (if present) appear before any other content section.
- No banned superlatives appear in user-visible text (see `references/writing-conventions.md`).

Then run the standardized readability self-check (the shared standard is in your context from
`han-communication:readability-guidance`) over the report's PROSE content only — never inside HTML tags, attributes,
class names, mermaid/diagram bodies, or code. The visual layout stays governed by the existing layout conventions. This
skill runs no rewrite pass, so this self-check is the fidelity guard on the prose; criterion 6 is not optional. Confirm
each criterion and fix any failure before finalizing:

1. The opening line/prose states the main point (bottom line up front).
2. Each heading names its content and is not a generic label.
3. Each paragraph carries one idea and leads with it.
4. No sentence runs past the soft length flag (about thirty words) without reason.
5. No word from the vocabulary blocklist (the shared writing-voice profile's "Avoided words and phrases" and "AI slop to
   avoid" lists, plus this skill's supplementary domain terms in `references/writing-conventions.md`) is present.
6. Every fact is preserved — every claim, quantity, named entity, and stated condition or qualifier survives with its
   precision intact.

Fidelity wins: the standard governs how the content is said, never whether a required fact appears.

If any check fails, fix it before Step 6.

### 6. Inline the mermaid bundle

Make the file self-contained by inlining the vendored mermaid bundle in place of the placeholder:

```
${CLAUDE_SKILL_DIR}/scripts/inline-mermaid.sh <path-to-html-file>
```

The script is idempotent: it replaces the `<!-- MERMAID_BUNDLE_INLINE_HERE -->` placeholder with the contents of
`assets/mermaid.min.js`. If the report has no diagrams (no placeholder), it leaves the file untouched and exits cleanly.
If the script exits non-zero, surface the error to the user; do not retry blindly — read the error.

### 7. Report

Tell the user:

- The output file path.
- That the diagrams were inlined (or that the report had no diagrams to inline).

If you had to derive the bottom line because the source had no explicit TL;DR, mention that so the user can review the
framing.
