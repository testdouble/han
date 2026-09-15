# Current State Findings: {Change Name}

<!--
This file is the single source of truth for what the code does today. Every later
agent in the run reads it first and does not re-grep for what is already here.
The plan cites it with inline ([C-N](artifacts/current-state-findings.md#...)) links
for every claim about the code as it stands.

Findings reach this file by one of two paths, and the Provenance section below
records which:
  1. Extracted from a prior report (architectural-analysis, investigate, a code
     review, an ADR). Preserve each finding's file paths and verbatim code, and
     carry forward any Unverified label the report applied.
  2. Produced by this run's own discovery round (structural-analyst,
     behavioral-analyst, and concurrency-analyst when the area warrants it).

A finding that rests on something nobody could inspect is labeled Unverified and
never carries blocking severity downstream. Keep it: it may be real, and it is
often cheap to verify later.
-->

## Provenance

<!-- Which path produced these findings. For path 1, the report's path and its date.
For path 2, the agents dispatched and the area they were given. Both, when a prior
report covered part of the area and this run's round covered the rest. -->

## Project Context

<!-- From the run's own sweep, not from the specialists. Language, framework, test
runner, and build tooling as resolved from CLAUDE.md's ## Project Discovery section or
project-discovery.md. -->

- **Stack:**
- **Conventions source:** <!-- CLAUDE.md, project-discovery.md, or "none found" -->
- **ADRs found:** <!-- path + one line each, or "none found under docs/adr/" -->
- **Coding standards found:** <!-- path + one line each, or "none found" -->
- **Recent churn:** <!-- from git log over the area's directories, or "git not available" -->

## Gaps

<!-- What was searched for and not found. A missing ADR or an absent coding standard is
itself a finding the plan should note, not a blank to skip. Write "none" only when the
search turned up everything it looked for. -->

## Findings

### C-1: {Short title}

- **Claim:** <!-- One sentence stating what is true of the code today -->
- **Location:** <!-- file path, and the symbol or line range -->
- **Evidence:**
  <!-- Verbatim code, in a fence. Enough to establish the claim and no more. -->
- **Raised by:** <!-- the agent, or the report path and its section -->
- **Confidence:** <!-- Verified (the code was read) or Unverified (name what could not be inspected) -->
- **Bears on:** <!-- the S-N delta entries or D-N decisions this finding grounds. Backfilled as the
  run settles them; "—" until then. -->

### C-2: {Short title}

- **Claim:** ...
- **Location:** ...
- **Evidence:** ...
- **Raised by:** ...
- **Confidence:** ...
- **Bears on:** ...

<!-- Add more findings as needed (C-3, C-4, ...). Merge two agents' wording of one
finding into a single C-N carrying both originating identifiers, rather than recording
it twice. -->

## Findings No Agent Could Audit

<!-- Evidence classes nobody in this run could reach: a runtime the agents cannot execute,
a data shape that only exists in production, a dependency whose source is not vendored.
Name each one and what it would take to close it. When every class was covered, say so in
one sentence. A coverage gap that is visible is a different thing from one that is silent. -->
