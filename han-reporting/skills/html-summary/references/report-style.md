# Style Reference for HTML Summaries

The default palette, typography, and component patterns for executive HTML reports. The colors derive from the Test Double brand palette (testdouble.com): a white page, deep purple as the primary accent, signature green for positive outcomes, and action orange for the stakeholder asks. Use these values verbatim. Do not introduce new accent colors or borrow from other palettes.

## CSS variables — paste verbatim into `:root`

```css
:root {
  /* Neutrals — page chrome */
  --bg: #ffffff;            /* page background — white */
  --surface: #f4f2ed;       /* subtle off-white secondary surface (chips, node fills) */
  --paper: #ffffff;         /* card surfaces */
  --ink: #131413;           /* primary text */
  --ink-soft: #4f4f4f;      /* secondary text */
  --ink-muted: #758696;     /* tertiary text */
  --rule: #e6e6e6;          /* subtle borders */
  --rule-strong: #c5c5c5;   /* card borders */

  /* Test Double purple — primary accent: TL;DR strip, highlight, entry nodes */
  --purple: #4d0aed;
  --purple-soft: #ece6fe;   /* purple tint for highlight backgrounds */
  --purple-light: #a580f9;

  /* Test Double green — positive / after-change outcomes */
  --green: #75fe04;         /* signature lime — background fill only */
  --green-deep: #2f6b00;    /* readable green for text/strokes on light */
  --green-soft: #eefbe0;    /* after-change node background */

  /* Test Double orange — stakeholder-ask accent + ask number badges */
  --orange: #d63c00;
  --orange-soft: #ffe2d6;
  --orange-deep: #b03000;

  /* Today-state / problem nodes (orange family) */
  --rust-bad: #b03000;
  --rust-soft: #ffe2d6;
}
```

The base brand colors (`--purple #4d0aed`, `--green #75fe04`, `--orange #d63c00`) come straight from Test Double's brand palette. The soft tints and the readable `--green-deep` text shade are derived from those bases so the report clears contrast on a white page.

## Color role mapping

| Role | Variable | Notes |
|------|----------|-------|
| Page background | `--bg` | White. |
| Card surface | `--paper` | All major content cards. |
| Card border | `--rule-strong` | Stronger than `--rule` so cards visibly group against the white page. |
| Heading text | `--ink` | Near-black, not pure black. |
| Body text | `--ink` | Same as headings; rely on weight/size for hierarchy. |
| Secondary text | `--ink-soft` | Captions, subtitles, ask-questions, out-of-scope reasons. |
| Section label | `--ink-soft` | Uppercase, letter-spaced, small (`section > h2`). |
| Header subtitle | `--ink-soft` | The "Han: Stakeholder Summary" line under the h1. |
| TL;DR accent strip | `--purple` | 8px-wide bar inside the card on the left edge. |
| Title highlight word | `--green` | `<span class="highlight">` around the feature name in `<h1>`; bright lime behind dark text. |
| Asks accent strip | `--orange` | 8px-wide bar inside the asks card on the left edge. |
| Asks section label | `--orange-deep` | Readable orange for the asks card `<h2>`. |
| Ask number badge | `--orange` | Filled circle with white digit. |
| Walk-step number badge | `--purple` | Filled circle with white digit. |
| "After change" nodes | `--green-deep` on `--green-soft` | Positive outcomes in flow diagrams. |
| "Today / problem" nodes | `--rust-bad` on `--rust-soft` | Pain points in flow diagrams. |
| "Entry point" nodes | `--purple` on `--purple-soft` | Start of any flow — user action. |

## Typography

```css
font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
```

- **Do not load Inter from a web font service.** The system stack falls back gracefully and keeps the file offline-safe.
- Base size: `16px`, line-height `1.55`.
- `h1`: 34px, weight 700, letter-spacing `-0.02em`.
- Section labels (`section > h2`): 12px uppercase, letter-spacing `0.16em`, weight 700, color `--ink-soft`.
- `h3`: 18px, weight 600, letter-spacing `-0.01em`.
- TL;DR lead paragraph: 20px, weight 500.
- Body and lists: 16px.
- Card subtitles inside flow cards: 14px, color `--ink-soft`.

## Shape and spacing

- Card border radius: `15px`.
- Nested element radius (asks, walk steps, out-of-scope items, nodes): `10px`.
- Chip / pill radius: `99px`.
- Standard card padding: `26px 28px` for hero cards (TL;DR, asks), `20px 22px` for content cards.
- Page wrap max-width: `1080px`, padding `48px 28px 96px` desktop, `32px 18px 64px` mobile.

## Mermaid theming

The skill renders data-flow diagrams using mermaid.js, inlined into the HTML by `scripts/inline-mermaid.sh`. The mermaid initialization block at the bottom of `<body>` MUST configure the report palette via theme variables. Paste this verbatim:

```html
<script>
  mermaid.initialize({
    startOnLoad: true,
    theme: 'base',
    themeVariables: {
      fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif',
      fontSize: '14px',
      background: '#ffffff',
      primaryColor: '#f4f2ed',
      primaryTextColor: '#131413',
      primaryBorderColor: '#c5c5c5',
      secondaryColor: '#ece6fe',
      secondaryTextColor: '#131413',
      secondaryBorderColor: '#4d0aed',
      tertiaryColor: '#ffe2d6',
      tertiaryTextColor: '#131413',
      tertiaryBorderColor: '#d63c00',
      lineColor: '#4f4f4f',
      textColor: '#131413',
      mainBkg: '#f4f2ed',
      nodeBorder: '#c5c5c5',
      clusterBkg: '#ffffff',
      clusterBorder: '#c5c5c5',
      titleColor: '#131413',
      edgeLabelBackground: '#ffffff'
    },
    flowchart: {
      htmlLabels: true,
      curve: 'basis',
      padding: 18
    }
  });
</script>
```

### Mermaid diagram color directives

When a source mermaid block uses `style X fill:...` directives, normalize the fill colors to the report palette before inlining. Translation table:

| Source intent | Source hex (common) | Report replacement (fill / stroke / color) |
|---|---|---|
| After-change positive outcome (green) | `#14532d`, `#22543d`, `#166534` | `fill:#eefbe0,stroke:#2f6b00,color:#2f6b00` |
| Today-state pain point (rust / brown) | `#78350f`, `#7c2d12`, `#92400e` | `fill:#ffe2d6,stroke:#b03000,color:#b03000` |
| Entry / user-action node (purple) | (often unstyled in source) | `fill:#ece6fe,stroke:#4d0aed,color:#4d0aed` |

Mermaid `style` directive syntax: `style NODE_ID fill:#hex,stroke:#hex,color:#hex`. Apply colors via `style` directives, not by editing the bundled mermaid theme.

### Mermaid block CSS

The `<pre class="mermaid">` block needs a small amount of supporting CSS:

```css
.mermaid {
  background: transparent;
  border: 0;
  margin: 8px 0;
  padding: 0;
  font-family: inherit;
  text-align: center;
  overflow-x: auto;
}
.mermaid svg {
  max-width: 100%;
  height: auto;
}
```

## Component patterns

### Header (no brand mark)

The report header carries no logo or brand mark. The `<h1>` is the summary subject (the feature name) and is the primary title. The `.subtitle` directly beneath it is the literal string `Han: Stakeholder Summary` on every report:

```html
<header class="top">
  <h1>Filters and <span class="highlight">Saved Views</span></h1>
  <div class="subtitle">Han: Stakeholder Summary</div>
</header>
```

The subject's one-sentence framing lives in the TL;DR card's lead, not the header.

### Title with highlighted feature name

```html
<h1>Filters and <span class="highlight">Saved Views</span></h1>
```

The `.highlight` span wraps the feature name (or its most evocative noun phrase) and applies the green background.

### Accent strip cards

TL;DR and asks cards use a left-edge accent strip via a `::before` pseudo-element. The card body sits in a normal `padding`; the strip is 8px wide and full height. Do not move this strip to a `border-left` — the strip looks cleaner inside the rounded corner. The TL;DR strip is purple; the asks strip is orange.

### Flow diagrams

Use `<pre class="mermaid">` blocks containing valid mermaid flowchart syntax. The inlined mermaid bundle parses and renders these to SVG at view time. Preserve branching, decision diamonds, and subgraphs from the source — do not flatten them.

```html
<pre class="mermaid">
flowchart LR
  U([User]) --> L[Opens a list]
  L --> C{Want to narrow?}
  C -->|Yes| F[Clicks Filters]
  C -->|No| D[Reads what is shown]
  F --> P[Pill strip opens]
  P --> V[Picks a value]
  V --> R[List narrows]
  R --> Z[Web address captures the filters]
  style U fill:#ece6fe,stroke:#4d0aed,color:#4d0aed
  style R fill:#eefbe0,stroke:#2f6b00,color:#2f6b00
  style Z fill:#eefbe0,stroke:#2f6b00,color:#2f6b00
</pre>
```

Normalize source `style` directives to the report palette using the translation table above. Apply `style` directives to user-action / entry nodes (purple), after-change outcomes (green), and today-state pain points (rust).

### Chips

```html
<span class="chip good">After</span>
<span class="chip bad">Today</span>
<span class="chip">Neutral</span>
```

Used in card headers to label the before/after state. Uppercase, weight 600, letter-spacing `0.02em`.

## Accessibility

- All text colors against their backgrounds clear WCAG AA at 16px:
  - `--ink` on `--bg`, `--paper`, `--green-soft`, `--rust-soft`, `--green` — pass.
  - `--ink-soft` on `--bg`, `--paper` — pass.
  - `--green-deep` on `--green-soft`, `--rust-bad` on `--rust-soft` — pass.
  - white on `--purple`, white on `--orange` — pass (badge digits and strip text).
- Do not use `--green` as a text color on white — it fails contrast. The bright lime is a background fill only; use `--green-deep` for green text.
- Do not use `--purple-light` as a text color on white — it fails contrast. Use `--purple` for purple text.
- Flow diagram arrows use `&rarr;` and remain meaningful when CSS is disabled.
- The `@media print` rule in the template removes shadows and keeps content legible on paper.

## What not to do

- Do not introduce dark mode. The report is light-mode on a white page.
- Do not introduce a second highlight color alongside the three accents. Green is the "look here" highlight on the title; purple is the primary structural accent; orange is reserved for the asks card and the ask number badges.
- Do not embed remote fonts, scripts, or images. The file must work offline.
- Do not invent emoji or icon sets. The report uses no icons — text and color do the work.
- Do not add a logo or brand mark to the header. The report is intentionally unbranded.
