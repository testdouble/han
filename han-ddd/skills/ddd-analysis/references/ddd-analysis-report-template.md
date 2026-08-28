# Domain-Driven Design Analysis

**Scope:** {scope} · **Depth:** {small | medium | large} · **Git:** {available | unavailable}

_This report characterizes domain boundaries observed in the code. Technical boundaries — services, directories,
schemas, team structures — are evidence, not proof. Confidence levels reflect the evidence available; missing
domain knowledge lowers confidence rather than being invented. Bounded context names are domain model
recommendations, not microservice or deployment recommendations._

---

## Executive Summary

{4-6 sentences synthesized by the skill after all other sections are complete:
(1) The domain shape: how many CURRENT, LATENT, and SPECULATIVE contexts were found and the overall verdict
distribution from the critique.
(2) The most confident boundary: which context has the strongest convergent evidence and why.
(3) The most significant boundary problem or contested area. Do not assert that it can or should be fixed.
(4) The key question a domain expert should answer before the team acts on any boundary.
Write for a reader deciding what to do next. Do not name agents, tool calls, or finding identifiers. Do not
assert named DDD strategic relationship types (Shared Kernel, Customer/Supplier, Partnership, Conformist,
Open Host Service, Published Language) from code-only evidence. Do not prescribe corrections, recommend
extraction or refactoring, or state that implementation can proceed without further analysis.}

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
ownership cohere AND the responsibilities form a coherent model through shared lifecycle, related business
rules or invariants, a shared consistency boundary, or evidence that they evolve as one domain concern),
and note the BCR# verdict.
If none exist, write: "No contexts reached CURRENT status. No proposed context had both vocabulary coherence
and ownership coherence supported by the discovery evidence."}

---

## Latent Bounded Contexts

{One paragraph per BCM# entry with LATENT status. For each: bold the context name, state what domain concern
it handles, explain why it is LATENT (capabilities cohere but ownership or vocabulary is dispersed), note
what domain-level evidence would establish it as CURRENT, and note the BCR# verdict.
If none, write: "No latent contexts were identified."}

---

## Speculative Context Hypotheses

{One paragraph per BCM# entry with SPECULATIVE status. For each: bold the context name, state the evidence
that suggests it, and state the domain-expert question that would confirm or refute it. Note explicitly that
the team should not act on these before expert input.

Speculative candidates are hypotheses, not established contexts. Verify that no CURRENT or LATENT context in
the Current Bounded Contexts, Latent Bounded Contexts, or Context Details sections references any of these BCM#
entries as an established provider, consumer, or relationship partner. If an accepted context interacts with the
concern underlying a speculative candidate, that section must name the underlying observed concern — the shared
data, shared events, or domain interaction — not the speculative BCM# entry.

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
Do not assert that a problem can or should be fixed. Do not prescribe the correction or recommend extraction,
refactoring, or migration.
If none, write: "No significant boundary problems were identified within the analysis scope."}

---

## Context Map

{If evidence supports relationships between two or more CURRENT or LATENT contexts, produce a Mermaid
flowchart. Use `flowchart LR`.

Label each edge with a factual observation describing what the relationship actually does: "supplies evaluated
prescriptions", "consumes update events". Assign a named DDD strategic relationship type only when the
repository contains explicit strategic or organizational evidence — not merely a code dependency, facade, event
emitter, API endpoint, or shared schema. When integration exists but the type cannot be established from
repository evidence, label the edge: `DDD strategic relationship: unclassified`.

DC# nodes may appear as visually subordinate nodes inside or adjacent to their host context using a distinct
style (e.g., dashed border in Mermaid: `DC1([Concern Name]):::concern`). DC# nodes must not look like bounded
contexts — do not give them the same node shape as BCM# entries.

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
- **Consumes**: information it reads from other contexts without owning, with source context where known; do
  not reference SPECULATIVE BCM# entries as established sources — name the underlying observed concern instead
- **Does not own**: concepts that appear nearby but belong elsewhere, named explicitly; do not reference
  SPECULATIVE BCM# entries by identifier
- **Relationships**: other contexts it relates to — state the factual observation first ("supplies X",
  "consumes Y events"), then the technical mechanism if known ("via event bus", "via API"), then
  `DDD strategic relationship: unclassified` unless the repository contains explicit strategic or organizational
  evidence supporting a named type. Do not reference SPECULATIVE BCM# entries as established relationship
  partners; name the underlying observed concern instead.
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

## Domain Concerns

{From DC# entries in the bounded-context-modeler output. Omit this section entirely if no DC# entries were
produced.

For each DC# entry:
**Concern name** (host context: {BCM# name or "unclear"}): one sentence on what domain responsibility this
concern handles and why it is worth naming.
Key rules or vocabulary: the most distinctive terms or rules from the DC# entry.
Why not a bounded context: the legitimacy-gate criterion it does not meet, in one sentence.

Do not format DC# entries to look like bounded contexts. They are named subdivisions within a broader context,
not independent domain models.}

---

## Integration Boundaries

{From IBN# entries in the bounded-context-modeler output. For each:
**Name** (type: External system interface | Event stream | Adapter | Sync mechanism | Technical mechanism):
one sentence on what this integration component does and why the evidence establishes it as an integration
mechanism rather than a bounded context.
What would elevate it: the specific semantic evidence — distinct domain vocabulary, domain behavior, or
independent ownership authority — that would justify reclassifying it as a SPECULATIVE bounded context
candidate.
If none, write: "No integration boundaries were identified separately from bounded context candidates."}

---

## Questions for Domain Experts

{Consolidated and deduplicated domain-expert questions from BCR# entries, ordered with the most
consequential first. For each question:

- The question itself: what domain uncertainty needs resolving.
- The competing interpretations: what the evidence supports on each side.
- The bounded-context conclusion: what changes in the model if the answer goes each way.
- (Affects: the proposed context or boundary problem this answer would most change.)
  Questions and conditional branches must describe domain interpretation only. Must not prescribe: authority
  designations, write-authority changes, arbitration rules, extraction, consolidation, renaming, migration,
  module or service creation, or any other implementation action. Conditional branches must take the form
  "if X is true, the evidence is best interpreted as [domain interpretation]" — not "if X, then
  [implementation consequence]". Must not suggest what DDD relationship type should be assigned. Must not
  suggest what status a candidate should have.
  If none, write: "No domain-expert questions remain open. All candidates were classifiable from code
  evidence alone."}

---

## Evidence / Analysis Artifacts

{List the artifact files for this analysis run. For each artifact, one line:
**{filename}** (`{absolute path}`): {finding type — count produced}

Organize into two groups:

### Discovery Artifacts

### Synthesis Artifacts

The finding identifier citations (DL#, CAP#, OWN#, S#, B#, BCM#, BCR#) throughout this report trace to the
discovery and synthesis artifacts listed here. Read the artifacts directly to follow any citation back to its
repository evidence. The rendered report file (`ddd-analysis.md`) and any visual artifacts in `visuals/`
are derived views of the canonical model — they do not carry additional evidence identifiers.}
