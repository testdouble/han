# Executive Layout Principles for HTML Summaries

These principles override the order of the source markdown. The HTML report is for executive readers — they read top-down and stop early. The most decision-relevant content must appear first, every time.

## Reading order — required

1. **Header** — the summary subject as the `<h1>` primary title (with the highlighted feature name), and `Han: Stakeholder Summary` as the subtitle beneath it. No brand mark or logo.
2. **Bottom line** (TL;DR) card — yellow accent.
3. **Stakeholder asks** card — orange accent. Skip entirely if the source has no asks.
4. **Problem statement**.
5. **What this opens up** (outcomes).
6. **User experience walkthrough**.
7. **Today vs. after** data flow.
8. **Intentionally not in scope**.

Sections 4–8 may be reordered modestly if the source's narrative demands it, but the header, bottom line, and asks card must always be in that order at the top.

## What hoists to the top

### The bottom line card

The bottom line is one short, declarative sentence that names:

- The change being made.
- The user-facing improvement.
- The product surface(s) affected.

Followed by 4–8 outcome bullets in a two-column list.

If the source markdown has an explicit "what problem are we solving" paragraph and a "what does this open up" bullet list, the bottom line lead is a one-sentence synthesis of those two pieces. The outcome bullets come from the "what does this open up" list (or the equivalent benefits section).

If neither exists in the source, derive the bottom line from the opening paragraph of the markdown. Flag the derivation in your reporting back to the user so they can review the framing.

### The stakeholder asks card

The asks card surfaces every decision the source markdown asks of stakeholders. Map source content as follows:

- Source section titled "What we are asking stakeholders" or similar → asks card.
- Source paragraphs ending in `Confirm ...?` → each becomes an ask.
- Source sentences phrased as "should we ... ?" addressed to stakeholders → each becomes an ask.

Each ask has:

- A **numbered badge** (orange circle, white digit).
- A **short title** (4–10 words) summarizing the decision.
- A **one-paragraph question** explaining the trade-off in plain language, ending with a bolded `**Confirm ...?**` clause.

Order the asks in the same order they appear in the source. If the source numbers them, preserve those numbers.

If the source has no asks section and no `Confirm ...?` phrases, omit the asks card entirely. Do not invent decisions.

## What stays in supporting detail

- Long-form problem statements.
- Discussion of trade-offs that are not asks.
- Process or governance notes.
- Lists of out-of-scope items (these go in their own section at the end, not in the asks card).

## Diagram rendering rules

Source markdown may contain mermaid `flowchart` blocks. The HTML output preserves them verbatim inside `<pre class="mermaid">` blocks, and the inlined mermaid.js bundle renders them to SVG at view time. The flow chart should keep the source's branching, decision diamonds, and subgraphs — do not flatten them.

For each mermaid block in the source:

1. Copy the block content into a `<pre class="mermaid">` element in the HTML.
2. Normalize `style` directives to the report palette using the translation table in `references/report-style.md` (Mermaid theming section). The common substitutions:
   - `fill:#14532d` (or any deep green) → `fill:#eefbe0,stroke:#2f6b00,color:#2f6b00`.
   - `fill:#78350f` (or any rust/brown) → `fill:#ffe2d6,stroke:#b03000,color:#b03000`.
3. Add a `style` directive for the entry / user-action node so it picks up the purple accent: `fill:#ece6fe,stroke:#4d0aed,color:#4d0aed`. If the source already styles the entry node, replace it.
4. If the source mermaid uses a flow direction (`flowchart LR`, `flowchart TD`), preserve it. The bundled theme renders both well.

Do not strip decision diamonds (`X{label?}`), subgraphs (`subgraph ... end`), or labeled edges (`A -->|label| B`). These are the parts of the source diagram that carry the most decision-relevant information.

## Mermaid containers — required

Every `<pre class="mermaid">` block in the HTML report must sit inside a `.card` container — a white-paper background with the standard border and radius — so the diagram reads as a discrete artifact against the cream page.

- In the **data-flow** section, each diagram is already inside its own `.card today` or `.card after` (these add a colored top stripe).
- In the **user experience walkthrough** section, the diagram that follows the numbered walk list must be wrapped in a bare `.card` (no `today`/`after` modifier — just the white container).
- Any future section that includes a mermaid diagram must wrap it the same way.

Do not place a mermaid block directly inside `<section>` against the cream page background. The diagram gets lost in the page and the lack of a container breaks the visual rhythm of the report.

## Data-flow section layout

Render the data-flow cards **one per row**, stacked vertically. Each card spans the full width of the page's content wrap (the wrap's max-width stays at 1080px; the cards just stop sharing a row).

Do not place two data-flow cards side-by-side in a two-column grid. Mermaid diagrams need the horizontal room to keep labels legible, and the side-by-side layout cramps the today-state and after-state diagrams against each other.

Required structure — no `.grid-2` wrapper around the today/after cards:

```html
<section>
  <h2>Data flow &mdash; today vs. after this change</h2>

  <div class="card today">
    <h4><span class="chip bad">Today</span></h4>
    <p>One-paragraph summary of the today state.</p>
    <pre class="mermaid">...</pre>
  </div>

  <div class="card after">
    <h4><span class="chip good">After &mdash; the everyday path</span></h4>
    <p>One-paragraph summary of the after state.</p>
    <pre class="mermaid">...</pre>
  </div>

  <div class="card after">
    <h4><span class="chip good">After &mdash; save the current filters as a named tab</span></h4>
    ...
  </div>
</section>
```

Other sections (such as a two-column "outcomes vs. risks" callout) may still use `.grid-2` if and only if their contents are short and do not include mermaid diagrams.

## Section omission

If a source section is missing, omit the corresponding HTML section. Acceptable omissions:

- No asks → skip the asks card.
- No UX walkthrough → skip the walkthrough section.
- No today-vs-after diagrams → skip the data-flow section.
- No "out of scope" list → skip that section.

Do not pad. An executive report with fewer sections is better than one with invented filler.

## Length discipline

- Title: under 60 characters.
- Subtitle: one sentence, under 200 characters.
- Bottom line lead: one sentence, under 250 characters.
- Outcome bullets: 4–8 bullets, each under 120 characters.
- Asks: 0–6 asks, each question paragraph under 350 characters.
- Walkthrough steps: 3–7 steps, each under 200 characters.

If a source paragraph exceeds these limits, tighten the wording for the HTML — do not split into more bullets just to fit. The HTML is a digest, not a copy.

## Voice and framing

- Preserve the source's voice and word choices. Do not corporate-ize plain language.
- Lead with the user-facing framing, never the implementation framing — same rule as the source markdown.
- Use the source's domain nouns verbatim (for example, "orders list," "pill strip," "saved view"). Do not paraphrase them.
- Em-dashes via `&mdash;` for offset clauses, matching the template.

## What to never do

- Never invent asks the source did not raise.
- Never reorder asks to put the easiest one first; preserve source order.
- Never strip the source's caveats (the "If any of these cuts would block your team, flag it before kickoff" sentence, or equivalents).
- Never add a "next steps" section unless the source has one. The HTML is a digest of the source, not a project plan.
