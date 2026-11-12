# Investigation type: how-it-works

## Detection signals

- the question asks how something in this codebase works, behaves, or is handled
- the question asks what happens when, where something is decided, or what calls what
- the question asks to trace, explain, or map a flow, a lifecycle, or a data path
- nothing is reported as broken, and no change is being weighed

## Dispatch

Start from the entry points the question names, or the ones the codebase exposes for it, and follow the code forward.
Explain what the code does today; do not judge it or propose changes.

1. `han-core:codebase-explorer` (1, always): "Explore how this codebase handles the following, to answer it accurately: {question}. Find the entry points, the core logic, the data models, the configuration, and the tests that exercise it. Return numbered findings keyed to file paths and line numbers, with the verbatim code that establishes each."
2. `han-core:behavioral-analyst` (1, always): "Your focus area is the code that answers this question: {question}. Trace the runtime behavior from its entry points: data flow, state changes, error propagation, and integration boundaries. Describe what happens rather than what could go wrong. Return numbered findings keyed to file paths and line numbers."
3. `han-core:structural-analyst` (1, when the question involves how the code is organized, which modules depend on which, or how the area came to be shaped this way): "Your focus area is the code that answers this question: {question}. Map the modules involved, their boundaries, their dependency direction, and the recent history that shaped them. Return numbered findings keyed to file paths and line numbers."
4. `han-core:concurrency-analyst` (1, when the question involves async work, background jobs, queues, ordering, locking, or concurrent access): "Explain the concurrency and async behavior of the code that answers this question: {question}. Cover what runs concurrently, what orders it, and what guards shared state. Return numbered findings keyed to file paths and line numbers."
5. `han-core:data-engineer` (1, when the question involves what is stored, how it is queried, or how the schema shapes the behavior): "Explain the schema, queries, and data-access code that answer this question: {question}. Return numbered findings keyed to file paths, line numbers, and schema or migration references."

## Analysis

1. Write `Question`: what was asked, restated plainly, and what the answer covers and leaves out.
2. Write `Answer`: one sentence that answers the question, then a numbered walkthrough of the flow in execution order,
   each step citing the evidence items that establish it (E1, E2, ...). Name the entry points the walkthrough starts
   from, and say where the evidence runs out rather than filling a gap with a guess.
3. Write `Key Components`: a table with the columns Component, File, and Role, one row for each part the walkthrough
   depends on.

## Validation brief

- Root cause analysis: the Answer and its numbered flow walkthrough
- Planned fix: the Answer's coverage claim, meaning the entry points and paths it presents as complete
- Attack focus: find a caller, path, input, or configuration the explanation misses or gets wrong

## Audience

The engineer who will work in this code next and needs an accurate mental model of it, with identifiers and file:line
citations preserved.

## Stop

> Report written to {path}. No code was changed. Reply with corrections to revise the report. To change this code next, run /han-planning:plan-a-change with this report; to build new behavior on it, run /han-planning:plan-a-feature.
