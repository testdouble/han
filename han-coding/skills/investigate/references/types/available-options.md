# Investigation type: available-options

## Detection signals

- the question asks what the options are, or what ways there are, for doing a piece of work in this codebase
- the question asks how a change could be made, where it would fit, or what it would take
- the question asks whether to take one approach or another, or which approach fits the existing code best
- a change is being weighed, and nothing is reported as broken

## Dispatch

Establish where the work would land and what constrains it before any option is named. Report what the code supports
today; the run itself enumerates and compares the options.

1. `han-core:codebase-explorer` (1, always): "Explore the code a change for the following would touch: {question}. Find the entry points, the core logic, the data models, the configuration, the tests, and any existing pattern that already solves a similar problem and could serve as precedent. Return numbered findings keyed to file paths and line numbers, with the verbatim code that establishes each."
2. `han-core:structural-analyst` (1, always): "Your focus area is the code a change for the following would touch: {question}. Map the module boundaries, the dependency direction, the abstractions and extension points, and any duplication, so the ways the change could fit are visible. Return numbered findings keyed to file paths and line numbers."
3. `han-core:behavioral-analyst` (1, when the change would alter runtime flow, state, error handling, or an integration boundary): "Your focus area is the code a change for the following would touch: {question}. Trace the runtime behavior the change would have to preserve or alter: data flow, state, error propagation, and integration boundaries. Return numbered findings keyed to file paths and line numbers."
4. `han-core:data-engineer` (1, when the change would touch a schema, a migration, a query, or stored data): "Describe the schema, queries, migrations, and data-access code a change for the following would touch: {question}. Name the constraints they put on how the change can be made. Return numbered findings keyed to file paths, line numbers, and schema or migration references."
5. `han-core:concurrency-analyst` (1, when the change would touch async work, background jobs, queues, ordering, locking, or shared state): "Describe the concurrency and async behavior of the code a change for the following would touch: {question}. Name the constraints it puts on how the change can be made. Return numbered findings keyed to file paths and line numbers."

## Analysis

1. Write `Goal and Constraints`: the work to be done, restated plainly, and the constraints the evidence shows any
   option must meet, each citing evidence items (E1, E2, ...).
2. Write `Current State`: what the code does today in the area the work would land, citing evidence items.
3. Resolve the coding standards that govern the area, then write `Coding Standards Reference`: for each standard,
   convention, ADR, or pattern inferred from surrounding code, what it is, where it was found, and which options it
   bears on.
4. Write `Options`: two or more genuinely different ways to do the work in this codebase, one `### Option N: {name}`
   block each, with How it works, Change surface (the files and types it touches), Fits existing patterns (citing
   evidence), and Costs and risks. Include an option only when the evidence shows the codebase can support it.
5. Write `Comparison`: a table of the options against the constraints from step 1.
6. Write `Recommendation`: the option that best meets the constraints, why, and what would change the call.

## Validation brief

- Root cause analysis: the Current State and the Goal and Constraints sections
- Planned fix: the recommended option and its change surface
- Attack focus: break the recommendation, and test whether a rejected option was dismissed on a false premise

## Audience

The engineer choosing an approach before planning it, with identifiers and file:line citations preserved.

## Stop

> Report written to {path}. No code was changed. Reply with corrections to revise the report. To plan the recommended option, run /han-planning:plan-a-change (restructuring existing code) or /han-planning:plan-a-feature (new behavior) with this report; to weigh prior art beyond this codebase, run /han-research:research.
