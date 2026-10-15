# Review type: work-ticket

## Purpose

Verify that the change on this branch resolves the named work ticket.

## Roster

- Always: han-core:gap-analyzer
- When relevant: han-core:test-engineer

## Checklist categories

Correctness, Testing

## Severity

default

## Instructions

> This is a work-ticket review. The question is whether the change delivers what the ticket asks. A ticket requirement
> the change does not meet counts as introduced by this change for the calibration directive. Do not raise findings
> unrelated to a ticket requirement unless they are Critical under the directive.

## Report section

```
## Ticket Resolution

**Ticket:** {$ticket_ref} | **Verdict:** {Resolved | Partially resolved | Not resolved | Not verified}

| Ticket requirement | Status | Evidence |
| ------------------ | ------ | -------- |
| {requirement, quoted from the ticket} | {Met | Partial | Not met} | {`file:line`, or the WARN-### that records it} |
```

Rows come from gap-analyzer's Requirement Map, or from Step 4's by-hand sweep in manual-only mode. After Step 7.4, a
row is Not met when a surviving Missing or Divergent finding names it, Partial when a surviving Partial finding names
it, and otherwise keeps the map's status; a row whose gap finding was discarded is Met, with the evidence
"GAP-### discarded at validation". Evidence shows the WARN-### or SUGG-### task ID Step 7 gave a surviving gap.
Verdict: Not verified when there is no Requirement Map and no by-hand sweep, with one line saying why; Not resolved
when any row is Not met; Resolved when every row is Met and the row count equals the map's "Requirements in ticket"
count; Partially resolved otherwise, with the line "{N - rows} of {N} requirements were not checked." when rows are
missing.
