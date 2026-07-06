# /html-summary

Operator documentation for the `/html-summary` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-reporting/skills/html-summary/SKILL.md`](../../../han-reporting/skills/html-summary/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Converts a stakeholder summary markdown file into a single self-contained HTML executive report.
- **When to use it.** You have a `stakeholder-summary.md` and want an HTML version that reads top-down for executives, with rendered diagrams.
- **What you get back.** One `.html` file next to the source markdown: self-contained, offline-safe, with the mermaid diagrams inlined.

## Key concepts

- **Executive ordering.** The HTML restructures the source so the bottom line and the stakeholder asks come first, before the problem statement or any supporting detail. Executives read top-down and stop early, so the decision-relevant content leads.
- **Single self-contained file.** All CSS is inlined, the mermaid library is vendored into the file, and there are no remote fonts, scripts, or images. The report renders correctly offline and travels as one file.
- **Markdown in, HTML out.** The skill never edits the source markdown. It produces an HTML sibling and stops: no commit, no push, no publish. Sharing the file is your call.
- **Test Double-derived palette, no brand mark.** The report uses a fixed palette derived from Test Double's brand colors (white page, purple primary accent, green for positive outcomes, orange for the asks). The `<h1>` is the summary subject; the subtitle is the literal string `Han: Stakeholder Summary`. No logo.

## When to use it

**Invoke when:**

- A `stakeholder-summary.md` (or equivalent executive/business summary markdown) exists and you want an HTML rendering of it.
- You want the summary's mermaid diagrams rendered as diagrams rather than fenced code blocks.
- You want a single file you can open in a browser or hand to someone, with no build step and no network dependency.

**Do not invoke for:**

- **Writing the summary itself.** Use [`/stakeholder-summary`](./stakeholder-summary.md) to produce the markdown this skill consumes.
- **Specifying the feature.** Use [`/plan-a-feature`](../han-planning/plan-a-feature.md) instead.
- **Generating a PR description or other GitHub artifact.** Use [`/update-pr-description`](../han-github/update-pr-description.md).

## How to invoke it

Run `/html-summary` in Claude Code.

Give it:

1. **The source markdown file.** Usually a `stakeholder-summary.md` in a planning folder. The HTML lands next to it, same basename with a `.html` extension. If you do not name a file, the skill asks. It does not guess.

Example prompts:

- `/html-summary docs/features/share/stakeholder-summary.md`
- `/html-summary` *(then name the file when asked)*

## What you get back

One file: the source path with `.md` replaced by `.html`, written in the same directory. For example, `filters-and-saved-views/stakeholder-summary.md` produces `filters-and-saved-views/stakeholder-summary.html`.

The HTML is structured in fixed executive order:

1. **Header.** The summary subject as the `<h1>` title, with `Han: Stakeholder Summary` as the subtitle. No brand mark.
2. **Bottom line card.** Purple accent strip; one-sentence lead plus 4–8 outcome bullets.
3. **Stakeholder asks card.** Orange accent strip; numbered decisions the team needs from stakeholders. Omitted entirely if the source has no asks.
4. **Problem statement.**
5. **What this opens up.**
6. **User experience walkthrough.** A numbered list plus a rendered mermaid `flowchart`.
7. **Data flow, today vs. after.** `today` and `after` cards stacked one per row, each with a rendered mermaid diagram.
8. **Intentionally not in scope.**

Sections the source markdown does not cover are omitted rather than padded. The mermaid library is inlined into the file so the diagrams render with no network access.

## How to get the most out of it

- **Write the summary first.** The HTML derives entirely from the markdown: the cleaner the summary, the cleaner the report. Pair with [`/stakeholder-summary`](./stakeholder-summary.md) before this.
- **Keep the asks sharp in the source.** The asks card leads the report. If the source markdown's open questions end in a clear `Confirm ...?`, they map straight into the report's numbered asks.
- **Re-run after the summary changes.** The skill is a single-pass converter built for tight-loop iteration. Edit the markdown, re-run, and the HTML regenerates.
- **Open the file to share it.** The output is a plain file on disk. Open it in a browser, attach it, or move it wherever you share. The skill does not publish it for you.

## Cost and latency

Single-pass authoring with no sub-agent dispatch. It reads the source markdown and the skill's references, then writes the HTML once. It self-checks the HTML against the layout and writing-convention rules. It also runs the shared readability standard's self-check over the prose, the fidelity guard since the skill runs no separate rewrite pass. Finally, it runs `scripts/inline-mermaid.sh` to vendor the mermaid bundle into the file. The most expensive step is producing the HTML body; the inline step is a fast local script. Built for tight-loop iteration: re-run it after the source summary changes.

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [`/stakeholder-summary`](./stakeholder-summary.md). Produces the `stakeholder-summary.md` markdown this skill converts to HTML.
- [`/plan-a-feature`](../han-planning/plan-a-feature.md). Produces the feature specification that `/stakeholder-summary` summarizes upstream of this skill.
- [`/update-pr-description`](../han-github/update-pr-description.md). The `han-github` skill for PR bodies rather than executive summaries.
