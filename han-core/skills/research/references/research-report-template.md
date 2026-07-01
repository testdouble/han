# Research: {Question Title}

<!-- One-sentence statement of the open-ended question being researched. -->
<!-- State the evidence mode used: strict (default) or exploratory (operator opted in). -->

<!--
READABILITY. This report is written to the shared readability standard the skill
loads (`../../references/readability-rule.md`), applied to prose regions only
(never inside code fences, diagram bodies, or the `A#`/`V#` citation identifiers,
which survive unchanged so they still resolve). Structural rules the standard
enforces here: main point first, descriptive headings, one idea per paragraph
with its first sentence carrying it, numbered lists for steps and bullets for
non-sequential items, and progressive disclosure. See the rule; do not restate it.
-->

## Summary

<!--
PLAIN LANGUAGE. AT THE VERY TOP. NO jargon, no file paths, no URLs, no IDs.
A reader who stops here has the answer: what the research found and what is
recommended, in a few sentences. Close with one phrase on how solid it is
(for example: "well-corroborated", "rests on a single source", "reasoned, not
evidenced — exploratory mode"), then the formal confidence rating on its own
labeled line so a reader who stops here sees it. The supporting risk reasoning
stays in Validation. This is the only section a non-technical reader needs.
-->

- **Confidence:** High / Medium / Low

## Research Results

<!--
The relevant findings, in plain prose, with MINIMAL technical detail. Every
claim cross-references the artifact(s) it rests on by ID, e.g. "(A1)", "(A2, A5)".
When a claim is not corroborated, mark it inline: "[single-source]" or, in
exploratory mode only, "[reasoning]". Surface source-vs-source and
codebase-vs-web conflicts here rather than resolving them silently.
-->

## Options to Consider

<!--
Present ONLY when the question implies discrete alternatives. Omit this entire
section for "how does X work" questions. Stable indexed IDs (O1, O2, …).
Steelman each option before weighing it.
-->

### O1: {option name}

- **What it is:** {one or two plain sentences}
- **Trade-offs:** {costs, risks, constraints}
- **Rests on:** {artifact IDs, e.g. (A1), (A4)}
- **Evidence status:** corroborated | single-source (caveated) | reasoning (exploratory mode only)

### O2: {option name}

- **What it is:** ...
- **Trade-offs:** ...
- **Rests on:** ...
- **Evidence status:** ...

<!-- Add more options as needed. -->

## Recommendation

- **Recommendation:** {the recommended option — reference its O# when options exist — or "No clear winner: {deciding criteria or missing information}"}
- **Evidence basis:** {explicitly state what the recommendation rests on: which parts are corroborated evidence (cite A#), which rest on a single source (cite A#), and — exploratory mode only — which rest on unevidenced reasoning. In strict mode the recommendation never rests on reasoning alone; if only reasoning is available, this is "No clear winner" with what evidence would settle it.}

## Validation

<!-- adversarial-validator findings: V1, V2, … -->

### V1: {hypothesis challenged}

- **Strategy:** Challenge the Evidence | Challenge the Options Framing | Challenge the Recommendation | Challenge the Evidence-Gathering Integrity
- **Investigation:** {what was checked}
- **Result:** Confirmed / Refuted / Partially Refuted
- **Impact:** {what changed, or why this supports the recommendation}

### V2: {hypothesis challenged}

- ...

<!-- Add more validation findings as needed. -->

### Adjustments Made

<!-- CONDITIONAL: include only if validation changed the results, options, or
recommendation. If the recommendation did not survive, state that it was
rewritten into the "No clear winner" form. -->

### Confidence Assessment

- **Confidence:** High / Medium / Low
- **Remaining Risks:** {single sources relied on, staleness, uncovered scope, and — exploratory mode — how much the recommendation leans on reasoning}

## Sources

<!--
AT THE VERY BOTTOM. An indexed registry of EVERY information source used that
is relevant to the results. ALWAYS present, even for a minimal run — never
omitted. Every A# cited inline in Research Results, Options, or the
Recommendation must RESOLVE to an entry here; that resolvability is the
traceability invariant. The Summary stays ID-free.

Render the registry as a COMPACT TABLE by default — one row per source with its
ID, title/source, link or location, retrieval date (web only), trust class,
one-line summary, and evidence status. Reserve a full prose summary (the "A#
detail" blocks below) for the sources the RECOMMENDATION rests on; every other
source stays a single table row. Entry depth scales with the band; the section
itself is always present.
-->

| ID | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
|---|---|---|---|---|---|---|
| A1 | {short title} | {URL / `repo/path.ext:line` / `provided: …`} | {YYYY-MM-DD or n/a} | codebase / web / provided | {one line on what it says} | corroborated by {A#} / single source (caveated) / contradicted by {A#} |
| A2 | … | … | … | … | … | … |

<!-- Full prose detail ONLY for sources the recommendation rests on. Every other
source stays in the table above. Number in the order discovered. -->

### A1: {short title of the source} — recommendation-bearing

- **Link / location:** {full URL — or `repo/path.ext:line` — or `provided: {reference}`}
- **Retrieved:** {YYYY-MM-DD for web sources; "n/a" for codebase or provided material}
- **Trust class:** codebase (trusted current-state anchor) | web (outside the trust boundary) | provided (operator-supplied — interested-party scrutiny)
- **Summary:** {one short paragraph: what this source says that is relevant to the results}
- **Evidence status:** corroborated by {A#} | single source (caveated) | contradicted by {A#}
