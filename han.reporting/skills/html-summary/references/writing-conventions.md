# Writing Conventions for HTML Summaries

The HTML report is read by executives who decide on the basis of facts and trade-offs, not enthusiasm. The voice is plain, declarative, and unembellished. These conventions are enforced everywhere user-visible text appears — the header, TL;DR card, asks card, body sections, flow-diagram nodes, and image captions.

## Hard rule — no superlatives

Do not use superlatives in any user-visible HTML output. A superlative is any word that ranks the thing being described as extreme along some dimension, or that praises the thing being described as a substitute for stating what it does.

### Banned words and phrases

This list is non-exhaustive. The same logic applies to synonyms.

**Ranking superlatives** — drop them or replace with a concrete claim.

- best, worst, most, least, fewest, biggest, smallest, fastest, slowest, cheapest, simplest, easiest, hardest, greatest, finest, leading, top, world-class, industry-leading, premier

**Hyperbolic adjectives** — drop them.

- incredible, amazing, fantastic, phenomenal, outstanding, remarkable, exceptional, extraordinary, unparalleled, unmatched, unrivaled, unique (when used as praise), revolutionary, game-changing, transformative, breakthrough, cutting-edge, state-of-the-art, next-generation, next-gen

**Marketing softeners** — drop them.

- seamless, effortless, frictionless, delightful, magical, beautifully, elegantly, intuitively, simply, just (as in "just click"), powerful, robust, rich, comprehensive, complete, holistic, end-to-end

**Absolutist hedges** — drop unless literally true and verifiable in the source.

- always, never, every, no one, everyone, nothing, anything, all (when used as a sweeping claim)

### Allowed exceptions

- **Quantified claims** that are present in the source. "The three biggest lists in the app" is allowed only because the source defines that scope explicitly — `biggest` is acting as a bounded selector, not a vague flourish.
- **Absolute facts that are literally true.** "No user sees another user's views" is allowed because it states a system invariant, not a marketing claim.
- **Domain nouns the source uses verbatim.** If the source markdown calls something "the primary surface," keep that wording. Do not rewrite source nouns.

When in doubt: if removing the word does not change the factual content, remove it.

## Rewrites — bad → good

| Avoid | Use instead |
|-------|-------------|
| Users get the best filtering experience. | Users narrow the list to rows that match a value they pick. |
| The most powerful saved-views surface in the product. | A reusable saved-views surface — future lists can plug into it. |
| Seamlessly carry filters from list to map. | The map opens with the same filters as the list. |
| Incredibly fast path to the rows that matter. | A direct path to the rows that matter — no scrolling or paging. |
| Always preserves the user's intent. | The web address captures the active filters. |
| A revolutionary new way to filter lists. | A consistent filter pattern across the three lists. |
| Effortless, delightful, intuitive interaction. | One click on a pill to pick a value; the list narrows immediately. |
| Best-in-class executive reporting. | A digest of the source document, structured for top-down reading. |

## Tone signals

- Lead with what the user or system does. Verbs over adjectives.
- Compare against the source's plain language. If the source uses understated wording, the HTML uses the same.
- Prefer concrete nouns over abstract ones — "the orders list" not "the affected surface."
- If a claim sounds like a benefit, restate it as a behavior. "Filters now persist" is better than "Filters now stay where you put them, beautifully."

## Where this rule does not apply

- **Source quotations.** If the source markdown uses a superlative inside a direct quotation (rare), preserve it verbatim — do not edit quoted material.
- **CSS variable names.** Identifiers like `--rule-strong` are technical artifacts, not user-visible text.
- **Code comments inside the `<style>` block.** These are not user-visible.

## Verification

Before publishing, scan the produced HTML for the banned words above. If any appear in user-visible text (anywhere between `<body>` and `</body>` that is not inside a `<style>` block), rewrite the sentence before running the publish script.
