---
paths:
  - "{glob-1}"
  - "{glob-2}"
---

# {Title}

- **Status:** {proposed | accepted | deprecated}
- **Date Created:** {YYYY-MM-DD HH:mm}
- **Last Updated:** {YYYY-MM-DD HH:mm}
- **Authors:**
  - {name} ({username}, {email})
- **Reviewers:**
  - {name} ({username}, {email})
- **Applies To:**
  - {which part(s) of the system this standard covers}

## Introduction

{Brief description of what this coding standard covers.}

### Purpose

{One **primary** rationale for this standard, stated first and clearly demoted from any secondary benefits. Use explicit labels when more than one rationale matters:}

- **Primary:** {the main reason this standard exists}
- **Secondary:** {benefit that follows from applying the standard but isn't why it exists}
- **Side effect:** {incidental consequence — not a reason to adopt}

{Avoid coordinately listing rationales ("X, Y, Z, and W") without ranking. Downstream readers latch onto whichever reason sounds most concrete and apply the standard for that reason, even when it doesn't hold.}

### Scope

{What language, framework, or area of the codebase this applies to.}

## When to Apply

{Decision tree the reader walks before adopting this pattern. Each question has a concrete, verifiable answer — not a judgment call.}

1. **{Precondition question 1}** — {how to check, e.g., a command to run, a property to inspect}
   - If yes → continue
   - If no → see "When NOT to Apply"
2. **{Precondition question 2}** — {how to check}
   - If yes → apply this standard
   - If no → see "When NOT to Apply" or the named exception below

**Exception — {name}:** {if this standard has an exception case where it should be applied for a different reason than the primary, surface it here as a branch in the decision tree, not buried in a later section}

**Verification step:** {a concrete command, query, or test the reader can run *now* to confirm the trigger condition holds — e.g., `go list -deps ./...` to verify a cycle exists, a benchmark threshold for a performance-motivated pattern, a coverage metric for a testability-motivated pattern}

## When NOT to Apply

{Cases where this pattern is the wrong choice. At least one case must acknowledge the simpler-than-the-pattern alternative (direct import, inline code, no abstraction) as a legitimate choice. Symmetry with "When to Apply" reduces over-application.}

- **{Case 1}** — {brief description and the simpler alternative that is correct here}
- **{Case 2}** — {brief description and the simpler alternative that is correct here}

## Background

{Context for the guidelines: what problems they solve, why these conventions were chosen over alternatives, and any known trade-offs or caveats.}

## Coding Standard

{Each guideline is a sub-section with the structure shown below. Include as many sub-sections as needed.}

### {Guideline Name}

{Description of the guideline and when it applies.}

**Correct usage:**

```{language}
// Inline comment, if any, must cite the PRIMARY rationale from
// the Purpose section — not a secondary benefit or exception case.
// Examples reinforce reading habits more than prose does.
// example of the correct pattern
```

**What to avoid:**

```{language}
// example of the anti-pattern
```

**Project references:**
- `path/to/implementation` — {brief note on what this file demonstrates}

### {Cross-Cutting Guideline Name}

{Description of the guideline that spans multiple parts of the system.}

**{Project Type A}:**

```{language}
// example from project type A
```

**{Project Type B}:**

```{language}
// example from project type B
```

**What to avoid:**
...

**Project references:**
- `path/to/implementation-a` — {brief note}
- `path/to/implementation-b` — {brief note}

## Additional Resources

### Project Documentation

- {Links to ADRs, other coding standards, feature docs within the project}

### External Resources

- {Links to framework docs, library docs, or other external references}
