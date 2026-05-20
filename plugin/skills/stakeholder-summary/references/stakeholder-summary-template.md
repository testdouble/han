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

**After this change — {{path A name}}** ({{one-sentence description}}):

```mermaid
flowchart LR
    A[{{Source}}] -->|{{action}}| B[{{Intermediate}}]
    B --> C[{{State}}]
    U[{{Actor}}] -->|{{action}}| C
    C --> D[{{Resulting state}}]
    style D fill:#14532d
```

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

## What is intentionally not in this slice?

- **{{Item 1}}** — {{one sentence on why it is out of scope or where it lives instead}}.
- **{{Item 2}}** — {{one sentence}}.
- **{{Item 3}}** — {{one sentence}}.
- **{{Item 4}}** — {{one sentence}}.

## What we are asking stakeholders

- {{Open question 1 — phrased so a non-technical stakeholder can answer it}}
- {{Open question 2}}
- {{Open question 3}}
