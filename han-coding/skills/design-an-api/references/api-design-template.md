# API Design Document Template

The `design-an-api` skill renders this template into `{folder}/api-design.md`. Fill every section that has content and
omit the ones that do not, keeping the remaining sections in the order below. Never emit a heading with placeholder or
"N/A" content.

Replace every `{placeholder}` with the resolved value. Text in _italics_ under a heading describes what the section
holds and is not written into the rendered document.

---

```yaml
---
goal: "{the stated goal, quoted}"
goal_source: "{ticket reference, issue URL, file path, or 'described in conversation'}"
interface: "{what is being designed, and where it lives}"
size: "{small | medium | large}"
size_reason: "{one line: which signals put it in this band}"
roster: "{the dispatched agents, comma-separated}"
starting_point: "{working tree | merge base with {branch}}"
git_available: "{yes | no}"
---
```

# API Design: {interface}

## Summary

_Two or three sentences stating the contract, then one line each for: the option chosen and what it was chosen over,
the decisions the user made at each gate that ran, the validation outcome, and any signalled domain the band cap
omitted. Written last, after every other section is filled._

## The Goal This Serves

_The stated goal, quoted verbatim, with its source. Every justification in this document cites back to this section._

## The Designed Contract

_The contract itself, in three parts:_

### Surface

_The signatures, parameters, fields, and types, in a code fence. Pseudocode is fine; this is a design, not an
implementation._

### Invariants

_The rules a caller can rely on and cannot violate: precedence between sources of a value, what persists and what does
not, lifecycle and ordering guarantees, and idempotency where the contract states one._

### Failure Behavior

_What the contract does with invalid, missing, malformed, or hostile input, and what a caller observes when an
underlying operation fails._

## Why Each Element Is Here

_One row per named element of the contract. The justification names the part of the goal the element descends from, or
the asked-for behavior it is a necessity of. An empty justification is a rendering bug._

| Element  | What it does | Justification                                                          |
| -------- | ------------ | ---------------------------------------------------------------------- |
| `{name}` | {behavior}   | {goal language it descends from, or the behavior it is a necessity of} |

## Options Considered

_Each option the architect produced, with its surface sketch and the reason it was chosen or rejected. The chosen
option is named first and marked as chosen._

### {Option name} — chosen

_What it does differently, and the reasoning that selected it._

### {Option name} — rejected

_What it does differently, and why it was rejected._

## Questions Resolved

_Every question from the question round, numbered, each with its answer and the source of the answer: the goal, a
context-brief finding (F#), or the user's decision at a gate._

| #   | Question   | Answer   | Source                      |
| --- | ---------- | -------- | --------------------------- |
| Q1  | {question} | {answer} | {goal / F# / user decision} |

## Validation Findings

_Every finding from the adversarial validation round, numbered V1, V2, V3, …, each marked accepted or rejected. An
accepted finding records what changed in the design. A rejected finding records why it does not hold, with its
citation. A validation round that found nothing records what it checked and why that supports the design._

| #   | Finding   | Disposition           | What changed or why it does not hold      |
| --- | --------- | --------------------- | ----------------------------------------- |
| V1  | {finding} | {accepted / rejected} | {change, or the citation that rejects it} |

## Cut List

_Everything this interface could plausibly carry that the goal does not ask for. Each entry names what it would have
done, in the same plain language the closing summary uses, and why it was cut. Rendered even when short. The reader can
reinstate any entry; their direction becomes its justification._

- **{What it would have done}** — cut because {reason, with the citation that supports the cut}.

## Open Risks

_What the validation round left standing, what the design depends on but could not verify, and any signalled domain the
band cap omitted. Each entry names the condition that would make it matter._

## Evidence

_A pointer to `context-brief.md` for the numbered findings this design was built on, plus any finding this document
cites directly._

## Next Step

_This document is the input to a `tdd` run that implements the contract._
