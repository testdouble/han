# Domain-Driven Design Analysis

**Scope:** {scope} · **Depth:** {small | medium | large} · **Git:** {available | unavailable}

*This report characterizes domain boundaries observed in the code. Technical boundaries — services, directories,
schemas, team structures — are evidence, not proof. Confidence levels reflect the evidence available; missing
domain knowledge lowers confidence rather than being invented. Bounded context names are domain model
recommendations, not microservice or deployment recommendations.*

---

## Executive Summary

{4-6 sentences synthesized by the skill after all other sections are complete:
(1) The domain shape: how many CURRENT, LATENT, and SPECULATIVE contexts were found and the overall verdict
distribution from the critique.
(2) The most confident boundary: which context has the strongest convergent evidence and why.
(3) The most significant boundary problem or contested area.
(4) The key question a domain expert should answer before the team acts on any boundary.
Write for a reader deciding what to do next. Do not name agents, tool calls, or finding identifiers.}

---

## Domain Landscape

{2-4 sentences synthesizing the major business responsibilities this system performs.
Derive from the CAP# Capability Summary and OWN# Ownership Summary. Name responsibility clusters at a high
level — not as bounded context candidates, but as observable business concerns the system serves
("this system manages invoicing and subscription billing," "the core workflow is order fulfillment").
If the landscape is mixed or unclear, say so plainly. Do not assert boundaries the evidence does not support.}

---

## Ubiquitous Language

{A list of significant domain terms from the DL# findings. For each term:
  **Term**: one-line definition, or — for semantic collisions — a note on the different meanings and the
  areas of the codebase where each applies.
Focus on terms that appear frequently, carry domain intent, or collide semantically across candidate contexts.
If no significant domain terminology was identified, write: "No significant domain terminology was identified.
The codebase uses primarily technical naming with limited business vocabulary."}

---

## Business Capabilities

{A list of cohesive business behaviors from the CAP# findings, each as a verb phrase:
  **Capability name**: one-line description of what the behavior does and for whom.
Group related capabilities where the groupings are clear from the evidence. Where a capability cluster
suggests a domain boundary but ownership is unclear, note this.
If only CRUD operations were found, write: "No cohesive business behaviors were identified. The code
surfaces primarily create, read, update, and delete operations without distinct domain processes or workflows."}

---

## Current Bounded Contexts

{One paragraph per BCM# entry with CURRENT status from the final model. For each: bold the context name,
state what domain concern it handles, explain why the evidence classifies it as CURRENT (vocabulary and
ownership cohere), and note the BCR# verdict.
If none exist, write: "No contexts reached CURRENT status. No proposed context had both vocabulary coherence
and ownership coherence supported by the discovery evidence."}

---

## Latent Bounded Contexts

{One paragraph per BCM# entry with LATENT status. For each: bold the context name, state what domain concern
it handles, explain why it is LATENT (capabilities cohere but ownership or vocabulary is dispersed), note
what single development change would move it toward CURRENT, and note the BCR# verdict.
If none, write: "No latent contexts were identified."}

---

## Speculative Context Hypotheses

{One paragraph per BCM# entry with SPECULATIVE status. For each: bold the context name, state the evidence
that suggests it, and state the domain-expert question that would confirm or refute it. Note explicitly that
the team should not act on these before expert input.
If none, write: "No speculative hypotheses were identified. All candidates were classifiable from code
evidence alone."}

---

## Boundary Problems

{A list of domain model problems from the discovery evidence. Sources: BCR# failure modes detected in weak
or reject verdicts; OWN# contestation findings; DL# semantic collisions that span candidate boundaries.
For each problem:
  **Problem**: one-line description.
  — Evidence: specific DL#, CAP#, OWN#, S#, or B# findings that show this.
  — Impact: how this affects confidence in nearby proposed contexts.
Group by type where multiple problems share a type (contested ownership, semantic collision, leaked
responsibility).
If none, write: "No significant boundary problems were identified within the analysis scope."}

---

## Context Map

{If evidence supports relationships between two or more CURRENT or LATENT contexts, produce a Mermaid
flowchart. Use `flowchart LR`. Label each edge with the DDD relationship type (customer-supplier, shared
kernel, anti-corruption layer, conformist, open host service, published language, partnership) only where
BCM# relationship fields cite supporting evidence. Use "relationship unclear" when integration exists but
the type is ambiguous.

Do not fabricate relationships to make the diagram complete.

If fewer than two contexts have evidenced relationships, write: "Insufficient relationship evidence for a
context map. The contexts identified appear independent, or their integration patterns are not yet visible
in the code."}

---

## Context Details

{One subsection per CURRENT or LATENT context, using the heading: ### {Context Name}

For each context, present these fields from the final BCM# entry:
  - **Purpose**: what domain concern this context handles and for whom
  - **Responsibilities**: the specific things this context must do
  - **Vocabulary**: the terms constituting its ubiquitous language
  - **Owns**: the domain concepts and rules held authoritatively
  - **Consumes**: information it reads from other contexts without owning, with source context where known
  - **Does not own**: concepts that appear nearby but belong elsewhere, named explicitly
  - **Relationships**: other contexts it relates to with named DDD relationship types where evidence supports them
  - **Evidence**: the DL#, CAP#, OWN#, S#, and B# items that support this entry
  - **Confidence**: High | Medium | Low, with one sentence on what makes the evidence strong or weak

If no CURRENT or LATENT contexts exist, write: "No current or latent contexts were identified. See
Speculative Context Hypotheses for the closest candidates."}

---

## Rejected or Weak Context Candidates

{From BCR# entries with weak or reject verdicts. For each:
  **Candidate name** (verdict: weak | reject): one sentence on the primary failure mode detected.
  What would change this: one sentence on the evidence or domain-expert input that would raise confidence.
If none, write: "No candidates were rated weak or reject. All proposed contexts received strong or
plausible verdicts."}

---

## Questions for Domain Experts

{Consolidated and deduplicated domain-expert questions from BCR# entries, ordered with the most
consequential first. For each question:
  - The question, phrased so it can be asked in a meeting with a domain expert.
  - (Affects: the proposed context or boundary problem this answer would most change.)
If none, write: "No domain-expert questions remain open. All candidates were classifiable from code
evidence alone."}

---

## Evidence Index

{A traceable index of every discovery finding. For each finding, one line:
  **{ID}**: what the finding shows — primary file path(s) — cited in: {section(s) where cited}

Organize into five subsections:

### Language Signals (DL#)

### Business Capabilities (CAP#)

### Domain Ownership (OWN#)

### Structural (S#)

### Behavioral (B#)

Keep entries brief. This index is a cross-reference between the report and the codebase, not an analysis.
Every Evidence field in Context Details should trace to items here.}
