# {{feature_name}} — Stakeholder Summary

## What problem are we solving?

{{One or two short paragraphs in plain language describing the user-visible problem this feature addresses. No technical detail — frame it from the customer's point of view. End with a short list of the high-level capabilities this feature introduces.}}

- **{{Capability 1}}** — {{one-sentence description in the customer's voice}}
- **{{Capability 2}}** — {{one-sentence description in the customer's voice}}

## What does this open up?

- **{{Outcome 1}}** {{— one sentence on why this matters to the business or to customers}}
- **{{Outcome 2}}** {{— one sentence}}
- **{{Outcome 3}}** {{— one sentence}}
- **{{Outcome 4}}** {{— one sentence on what downstream work this unblocks}}

## What will the user experience look like?

{{One short paragraph describing what the customer sees and does. Stay at the level of screens, badges, and choices — not APIs or data models. May be omitted in rare cases}}

```mermaid
flowchart TD
    A[{{Starting point the user encounters}}] --> B{{"{{Decision the user makes}}"}}
    B -->|{{Option 1}}| C[{{Action / result}}]
    B -->|{{Option 2}}| D[{{Action / result}}]
    C --> E[{{Next step or outcome}}]
    D --> F[{{Next step or outcome}}]
    E --> G[{{Final outcome}}]
    F --> G
```

## How does the data flow today vs. after this change?

**Diagram counts scale with the spec.** The example below shows one "Today" diagram and two "After this change" diagrams because that is the most common shape. Add or remove diagrams in each subsection to match the number of meaningfully distinct paths the spec describes. Single-path subsections do not get padded to two; multi-path subsections do not get collapsed into one.

**Today** — {{one-sentence description of the current state and the pain it causes}}:

```mermaid
flowchart LR
    A[{{Source system}}] -->|{{action}}| B[{{Intermediate}}]
    B --> C[{{Current end state}}]
    U[{{Actor}}] -.->|{{relationship}}| D[{{Other end state}}]
    C -.->|{{problem}}| D
    style C fill:#78350f
    style D fill:#1e3a8a
```

{{If the spec has only one meaningfully distinct current path (the common case), stop here — the one-sentence lead-in above is enough and no prose block goes below this diagram. If the spec has two or more meaningfully distinct current paths, replace this annotation with a 3-5 sentence prose block walking the reader through this path's flow, naming the pain point, and naming what makes this current path distinct from the other current paths. Then add a second "Today" diagram below — with its own one-sentence lead-in and its own 3-5 sentence prose block — for the next current path. Repeat for every current path the spec describes.}}

**After this change — {{path A name}}** ({{one-sentence description}}):

```mermaid
flowchart LR
    A[{{Source}}] -->|{{action}}| B[{{Intermediate}}]
    B --> C[{{State}}]
    U[{{Actor}}] -->|{{action}}| C
    C --> D[{{Resulting state}}]
    style D fill:#14532d
```

{{3-5 sentence prose block walking the reader through path A. If path A is the only "after this change" path in the spec, walk the flow without manufacturing a contrast against absent siblings, then delete the path B example below. If path A is one of two or more "after this change" paths, name the trigger that sends the customer down this path rather than the others, describe what the customer does and what the system does in response, and name the outcome that is unique to path A.}}

**After this change — {{path B name}}** ({{one-sentence description}}):

```mermaid
flowchart LR
    A[{{Source}}] -->|{{action}}| B[{{Intermediate}}]
    B --> C[{{State}}]
    U[{{Actor}}] --> D[{{Other state}}]
    C -->|{{action}}| D
    D --> E[{{Resulting state}}]
    style E fill:#14532d
```

{{3-5 sentence prose block walking the reader through path B. Mirror the contrast against path A — and any further paths — described above. Add more "After this change" diagrams here (path C, path D, etc.) as needed to cover every meaningfully distinct new path in the spec; delete this entire path B section if path A is the only new path.}}

## What is intentionally not in this slice?

- **{{Item 1}}** — {{one sentence on why it is out of scope or where it lives instead}}.
- **{{Item 2}}** — {{one sentence}}.
- **{{Item 3}}** — {{one sentence}}.
- **{{Item 4}}** — {{one sentence}}.

{{One-line catch-all confirmation prompt directed at stakeholders, e.g. *If any of these cuts would block your team, flag it before we kick off.* This line replaces per-item "is this OK?" questions that would otherwise duplicate into the next section.}}

## What we are asking stakeholders

Each item here must present a real trade-off, framing call, or unresolved question — not a yes/no confirmation of something already listed above. If the only thing you would ask is "is the exclusion of X acceptable?", drop it; the closing prompt in the previous section already covers that.

- **{{Trade-off or framing call 1}}.** {{One sentence presenting the named alternatives or the framing the stakeholder must confirm.}}
- **{{Trade-off or framing call 2}}.** {{One sentence.}}
- **{{Trade-off or framing call 3}}.** {{One sentence.}}
