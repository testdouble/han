# Investigation type: bug

## Detection signals

- something fails, errors, crashes, hangs, or times out
- something returns a wrong result, or behaves differently from what was expected
- something stopped working, or regressed after a change
- an error message, stack trace, log line, or failing test is quoted
- the operator asks to debug, troubleshoot, diagnose, or find a root cause

## Dispatch

Trace backward from the symptom: don't guess, follow the code. Launch the investigators and every applicable specialist
in one message. Specialist analysts find root causes generalists miss.

1. `han-core:evidence-based-investigator` (2+, always): "Investigate this from one angle only, the one you are assigned (the error path, the data flow, or the recent changes): {question}. Trace backward from the symptom with concrete evidence: file paths, line numbers, code snippets, error messages, git history, and test coverage. Return numbered findings keyed to file paths and line numbers."
2. `han-core:concurrency-analyst` (1, when the question involves intermittent failures, race conditions, deadlocks, ordering issues, stale reads after writes, timeouts, dropped messages, or anything that only reproduces under load or concurrent users): "Investigate the concurrency and async behavior of the code paths implicated by this symptom: {question}. Focus on race conditions, lock ordering, shared-resource contention, async error handling, and missing cancellation/timeout handling. Return numbered findings keyed to file paths and line numbers."
3. `han-core:behavioral-analyst` (1, when the question involves data transformed wrong, values lost between modules, errors swallowed, state mutated unexpectedly, or integration boundaries passing bad data): "Trace the data flow for the code paths implicated by this symptom: {question}. Focus on data transformation across module boundaries, error propagation and loss, state mutation, and integration-boundary assumptions. Return numbered findings keyed to file paths and line numbers."
4. `han-core:data-engineer` (1, when the question involves wrong data in the database, slow queries, N+1, lock contention, migration failures, unbounded scans, lost data, broken referential integrity, or isolation-level surprises): "Investigate the schema, queries, migrations, and data-access code implicated by this symptom: {question}. Focus on the specific data-engineering principles violated and the concrete data-level impact. Return numbered findings keyed to file paths, line numbers, and schema or migration references."

## Analysis

1. Write `Problem Statement`: the symptoms, the expected behavior, the conditions under which it occurs, and the impact.
2. Write `Root Cause Analysis`: a one-to-three sentence summary of the root cause under Root Cause, then a detailed
   analysis under Detailed Analysis that traces the causal chain from root cause to symptom and references evidence
   items by number (e.g., "The handler passes an unvalidated ID (E1) to the service layer, which assumes non-nil (E3)").
3. Resolve the coding standards that govern the fix, then write `Coding Standards Reference`: for each standard,
   convention, ADR, or pattern inferred from surrounding code, what it is, where it was found (file path, ADR number, or
   "inferred from surrounding code"), and which files or changes it governs.
4. Design a fix that **directly addresses the root cause**: fix the underlying problem, not symptoms. Write
   `Planned Fix`: a one-sentence approach, then for each file that changes, its full path from the repo root, what will
   be modified, added, or removed, which evidence items (E1, E2, ...) justify the change, which coding standards apply,
   and implementation specifics (new function signatures, changed logic, updated tests).

## Validation brief

- Root cause analysis: the Root Cause Analysis section
- Planned fix: the Planned Fix section, with every file change
- Attack focus: break the fix, and the causal chain from root cause to symptom

## Audience

The engineer who will implement the fix and may be paged on the bug.

## Stop

> Report written to {path}. No code was changed. Reply "approve" to have this session implement the Planned Fix, or reply with corrections to revise the report.
