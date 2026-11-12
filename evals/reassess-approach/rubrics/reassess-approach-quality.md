## Rubric: reassess-approach on the ruby-ingest-parser scaffold

### Presence — things the run must produce

- The run writes one report file named `approach-reassessment-{n}.md` under `plans/ingest-parser/artifacts/` and names its path in the reply
- The report opens with a Recommendation section that picks exactly one option and gives a reason a person who has not read the plan could follow
- The report restates what the current approach commits to (a hand-written regex line parser in `lib/ingest/parser.rb` driven by the plan's section 2) and lists the findings it has absorbed by ID (F1 through F9)
- The report carries at least one alternative that is structurally different from the current approach: a parser-generator or grammar-based library, a different code shape such as a tokenizer plus a small state machine, or a smaller slice that parses only the record types the plan's section 1 requires
- The report carries a "Stop doing this" option and a "Continue as is" option, each with the same fields as the other options
- The reply hands the decision to the user as one question, led by the consequence of staying on the current approach, with the options as named candidates and the recommendation marked, and ends the turn

### Specificity — the report must be concrete

- Every option names the recorded findings it would make moot and the ones it leaves open, using the F# IDs from `review-findings.md`
- Every option states what it adds and removes in owned code paths or plan items (for example, removing the escape-handling branches in `lib/ingest/parser.rb` or adding a gem dependency)
- Evidence cites specific scaffold paths (`lib/ingest/parser.rb`, `plans/ingest-parser/plan.md`, `plans/ingest-parser/artifacts/review-findings.md`) or finding IDs rather than generic claims
- Each option names what to run next if chosen (`plan-a-change`, `plan-a-feature`, `refactor`, `tdd`, or nothing)

### Depth — the options must be real alternatives

- At least one alternative would make the clustered edge-case findings (F2, F4, F5, F7, F8) moot together, and the report says why
- The recommendation weighs the alternatives against the recorded findings rather than against taste or best practice
- Options that were considered and set aside appear under Deferred (YAGNI) with a reopening trigger

### Absence — the run must not do these things

- The run does not edit `plans/ingest-parser/plan.md`, `review-findings.md`, or any file under `lib/`
- The run does not implement any option, start `/refactor` or `/tdd`, or re-run a review round
- The run does not present options that differ from the current approach only in parameters, naming, or ordering as if they were structurally different
- The run does not hallucinate files, findings, or review rounds that do not exist in the scaffold
- The run does not dispatch more than one critic agent, apart from a single relaunch when the first return lacks a structurally different alternative or a standing option
