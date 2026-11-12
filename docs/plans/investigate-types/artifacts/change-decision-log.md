# Change Decision Log: Investigation Types

<!--
This file records every decision committed while planning Investigation Types.
The plan itself lives in [../change-plan.md](../change-plan.md). Evidence about the
code as it stands today lives in [current-state-findings.md](current-state-findings.md)
as numbered C-N findings.
-->

## Trivial decisions

- D-10: allowed-tools — `allowed-tools` adds `Write` (the skill writes a report, C-4), `Skill` (it invokes
  `readability-guidance`; `restructure` is the han-coding precedent), and nothing else. `AskUserQuestion` is called by the fit check but stays out of `allowed-tools`, per
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md`: listing it
  makes the question return empty answers without being shown. Corrected during implementation; the plan first listed it. —
  Referenced in plan: Output location and the stop, S-9.
- D-15: Documentation — the long-form doc, README scent line, skills index, `docs/workflows.md`,
  `docs/how-to/research-a-decision.md`, and the Confluence wrapper's doc describe three types, per CLAUDE.md's "one
  canonical source per concept" and "indexes stay complete". — Referenced in plan: S-15.

## Full decisions

### D-1: One type file per type, read at fixed steps

- **Question:** Where do the per-type specifics live?
- **Decision:** One file per type at `references/types/{token}.md`, plus a `## Investigation Types` table in `SKILL.md`
  that is the only list of tokens. `SKILL.md` reads the type file's sections at fixed steps and names no token outside
  the table.
- **Rationale:** The operator asked for types "similar to what was done for the code review skill", which uses exactly
  this shape. The bug framing touches six steps (C-1), so inline branching would put three variants in each.
- **Evidence:** C-1, C-9, scope-boundary Stated Scope, software-architect A1.
- **Behavior impact:** Preserving for `bug`.
- **Rejected alternatives:**
  - Inline `if type is X` branches in `SKILL.md` — rejected because six steps would each carry three variants (C-1).
  - Three separate skills — rejected because the operator asked for one `/investigate` with types.
- **Revisit criterion:** A type that needs a step the shared flow does not have.
- **Dissent (if any):** none.
- **Settles delta entry:** S-1, S-2, S-4
- **Dependent decisions:** D-2, D-4, D-7, D-11
- **Referenced in plan:** Target State, S-1, S-2, S-4

### D-2: The type-file contract

- **Question:** What sections does a type file carry, and in what form?
- **Decision:** Title `# Investigation type: {token}`, then six `##` sections in order: Detection signals, Dispatch,
  Analysis, Validation brief, Audience, Stop. Value forms are pinned in the plan's contract table, including the
  Dispatch entry grammar
  ``N. `{plugin}:{agent}` ({count}, {when}): "{prompt}"`` with `{question}` as the only placeholder.
- **Rationale:** Each section maps to one bug-framed site in C-1 that differs per type. Purpose stays only in the table
  so there is one copy (UX review Y-2). Every section is required, so no `none` literal is needed (UX review Y-1).
- **Evidence:** C-1, C-6, C-9, software-architect A1, junior-developer JD-004, user-experience-designer Y-1 and Y-2.
- **Behavior impact:** Preserving.
- **Rejected alternatives:**
  - A seventh `## Purpose` section matching the table — rejected as two copies of one string with nothing reading the
    file without the table.
  - A separate dispatch file as code-review has — rejected because every prompt is type-framed, so the file would have
    one reader per entry.
  - An `{angle}` placeholder in the bug Dispatch — rejected; the investigator prompt names the angles and each agent
    takes one, keeping `{question}` the only placeholder.
- **Revisit criterion:** A type with nothing to say in a section, or a reader of a type file that bypasses the table.
- **Dissent (if any):** none.
- **Settles delta entry:** S-1
- **Dependent decisions:** D-11
- **Referenced in plan:** The type-file contract, S-1

### D-3: The argument grammar

- **Question:** How is a type token, a question, and an output path separated in one argument?
- **Decision:**
  ```
  args       := [ type-token ] question [ out-path ]
  type-token := a Token from ## Investigation Types; only the first whitespace-separated token; case-insensitive;
                one trailing ":" is stripped before matching; never inside quotes
  question   := the remaining text, verbatim, as $question
  out-path   := the final token, when it ends in ".md" and does not name a file that already exists; removed from $question
  ```
- **Rationale:** Hyphenated tokens are single words that rarely start a prose question. Treating an existing file as
  the subject means the run never writes over the file being asked about (UX-001), and accepts a bare relative path
  such as `docs/incidents/2026-04-23.md`, which today's long-form doc shows as an output path.
- **Evidence:** C-3, software-architect A3, user-experience-designer UX-001, junior-developer JD-001,
  `han-coding/docs/skills/investigate.md` "How to invoke it".
- **Behavior impact:** Changing. A leading type token and a trailing new `.md` path leave the question. The operator's
  request asks for a specifiable type, so this follows from it.
- **Rejected alternatives:**
  - A prefix rule (`/`, `./`, `../`, `~/`) for out-paths — rejected because it made `./CHANGELOG.md` in a question
    the write target and dropped bare relative paths the docs promise.
  - Spaced tokens such as `how it works` — rejected because matching would need multi-word lookahead and would steal
    the opening words of real questions.
- **Revisit criterion:** Operators passing out-paths that collide with existing files on purpose.
- **Dissent (if any):** none.
- **Settles delta entry:** S-3
- **Dependent decisions:** D-13
- **Referenced in plan:** The argument grammar, S-3

### D-4: Detection, tie-break, and the fit check

- **Question:** How is a type chosen with no token, and when does a named type get challenged?
- **Decision:** The model judges the question against each type's Detection signals. With several matches, the
  earliest table row wins; with none, the last row (`how-it-works`). With a token, the fit check fails only when the
  question clearly meets another type's signals and none of the named type's, and then asks once with the pinned
  `AskUserQuestion` wording. The announcement block is pinned in the plan.
- **Rationale:** The operator asked for automatic detection and for validation that suggests an alternative. A
  reported failure is the strongest signal, so `bug` is first; an options run already includes a current-state
  account, so `available-options` precedes `how-it-works`. Asking only on a clear mismatch keeps the operator's
  explicit choice otherwise. Putting the order in the table keeps tokens out of `SKILL.md` prose (JD-003).
- **Evidence:** C-10, scope-boundary Stated Scope, software-architect A3, user-experience-designer UX-002 to UX-005,
  junior-developer JD-003.
- **Behavior impact:** Changing, as requested: "if no type is specified ... determine the type automatically via the
  prompt context. if a type is specified, first validate that the specified type is acceptable for the prompt, and
  suggest an alternative type when needed." A question meeting no signal now runs as `how-it-works` where today it runs
  as a bug; the announcement says it defaulted.
- **Rejected alternatives:**
  - Defaulting to `bug` when nothing matches — rejected because the bug signals now include "behaves differently from
    what was expected", so a question that still meets none is not describing a failure.
  - Asking whenever detection is uncertain — rejected because the operator asked for detection to be automatic.
  - Stopping with a message on a mismatch instead of asking — rejected because the Confluence wrapper needs the run to
    produce a report.
- **Revisit criterion:** Evals or operators showing misroutes the announcement does not prevent.
- **Dissent (if any):** none.
- **Settles delta entry:** S-2, S-3
- **Dependent decisions:** —
- **Referenced in plan:** What `SKILL.md` owns, Type resolution, S-2, S-3

### D-5: Per-type rosters reuse existing agents

- **Question:** Which agents does each type dispatch?
- **Decision:** `bug` keeps today's roster. `how-it-works` always runs `codebase-explorer` and `behavioral-analyst`.
  `available-options` always runs `codebase-explorer` and `structural-analyst`. Specialists join on relevance. No new
  agent; `research-analyst` joins no type.
- **Rationale:** `evidence-based-investigator` is symptom-first (C-7). `codebase-explorer` is built "for documentation
  or understanding" and `behavioral-analyst` takes a focus area. `structural-analyst` brings the seams that constrain
  options and the git history `codebase-explorer` lacks.
- **Evidence:** C-7, C-15, software-architect A4.
- **Behavior impact:** Preserving for `bug`.
- **Rejected alternatives:**
  - A new codebase-options agent — rejected under YAGNI: one caller, no second named.
  - Briefing `evidence-based-investigator` for all types — rejected because its five fixed protocols start from a
    symptom.
  - Adding `research-analyst` to `available-options` — rejected by the agreed split: the open web belongs to `research`.
- **Revisit criterion:** Trial runs showing a type's roster misses what its question needs.
- **Dissent (if any):** none.
- **Settles delta entry:** S-1
- **Dependent decisions:** —
- **Referenced in plan:** Per-type rosters, S-1

### D-6: Validation maps inputs in the brief; the agent is unchanged

- **Question:** How does `adversarial-validator`, which expects a root cause and a planned fix, validate the new types?
- **Decision:** Each type's Validation brief names what goes in the validator's two named slots and an attack focus.
  Step 4 builds the brief in the form pinned in the plan.
- **Rationale:** The validator has eight calling skills, at least four of which already brief it with inputs that are
  not a fix. Changing its strategies risks all of them for a need the brief meets.
- **Evidence:** C-8, software-architect A5, junior-developer JD-005.
- **Behavior impact:** Preserving for `bug`.
- **Rejected alternatives:**
  - Changing the agent's strategy 2 to be conditional — rejected for the blast radius across its callers.
  - Skipping validation for non-bug types — rejected because it drops adversarial checking where claims are least
    tested.
- **Revisit criterion:** The trial run after Unit 3 showing the validator fabricates or skips on a mapped brief.
- **Dissent (if any):** none.
- **Settles delta entry:** S-4
- **Dependent decisions:** —
- **Referenced in plan:** Validation per type, S-4

### D-7: Per-type report templates with a shared fragment

- **Question:** One whole template per type, or per-type heads plus a shared fragment?
- **Decision:** `references/templates/{token}.md` per type, plus `references/evidence-and-validation.md` holding the
  Evidence Summary and Validation Results layouts, inserted at a one-line marker. Every template's second line names its
  type. The `bug` template keeps today's sections and order.
- **Rationale:** The shared layout is one concept read by one shared step; three copies would be about 210 lines kept
  equal by convention. CLAUDE.md asks for one canonical source per concept.
- **Evidence:** C-5, software-architect A2, test-engineer S-6 heading sequence, user-experience-designer UX-009.
- **Behavior impact:** Changing for `bug` in one line, the type line under the title.
- **Rejected alternatives:**
  - Three whole templates — rejected for the duplication.
  - Whole templates with a Bats byte-equality check — rejected as more lines for the same guarantee.
- **Revisit criterion:** A type whose evidence or validation layout must differ.
- **Dissent (if any):** none.
- **Settles delta entry:** S-5, S-6, S-7
- **Dependent decisions:** D-11
- **Referenced in plan:** Per-type reports, S-5, S-6, S-7

### D-8: Output location keeps the documented contract

- **Question:** Where does a report land when no path is named?
- **Decision:** An out-path wins, then `output-directory`, then the skill proposes
  `{documentation root}/investigations/investigate-{slug}.md` and writes without asking. An existing file gets a
  numeric suffix. The path appears in the announcement.
- **Rationale:** The long-form doc promises "otherwise the skill proposes one and writes the plan there". The how-to
  guides feed the report to `iterative-plan-review` and `plan-a-change`, so it has to be durable. A temp-directory
  default would break those paths. The type stays out of the filename because nothing needs to tell types apart by name
  (JD-007).
- **Evidence:** C-4, `han-coding/docs/skills/investigate.md` "How to invoke it",
  `docs/how-to/triage-and-investigate-a-bug.md` L116, junior-developer JD-007, user-experience-designer UX-001.
- **Behavior impact:** Changing in small ways: `output-directory` is honored, and the unnamed location is stated rather
  than chosen each run. Both follow the documented contract.
- **Rejected alternatives:**
  - `${TMPDIR:-/tmp}` as the default, as `code-overview` does — rejected because investigation reports are durable
    inputs to later skills.
  - `investigate-{token}-{slug}.md` — rejected under YAGNI.
- **Revisit criterion:** An operator asking for reports elsewhere by default.
- **Dissent (if any):** none.
- **Settles delta entry:** S-8
- **Dependent decisions:** —
- **Referenced in plan:** Output location and the stop, S-8

### D-9: The stop per type

- **Question:** How does each type's run end?
- **Decision:** Each type's `## Stop` text is pinned in the plan. `bug` keeps the approve-to-implement offer, worded so
  it says who implements. The other two say no code changed and point at plugin-qualified next skills. A shared line
  built from the table shows how to re-run as another type.
- **Rationale:** The skill runs inline, so an operator's "approve" has the same session build the fix. That correction
  to C-11 keeps a real behavior. The other types have nothing to implement. Plugin-qualified names resolve even when
  the next skill's plugin is installed alone (UX-006).
- **Evidence:** C-11, junior-developer JD-002, user-experience-designer UX-006 to UX-008.
- **Behavior impact:** Changing for `bug` in wording only: "No code was changed." and the re-run line are added.
- **Rejected alternatives:**
  - Dropping approve-to-implement — rejected because operators who reply "approve" today get the fix built.
- **Revisit criterion:** An operator asking bug runs to stop at the report.
- **Dissent (if any):** none.
- **Settles delta entry:** S-8
- **Dependent decisions:** —
- **Referenced in plan:** Current State, Output location and the stop, S-8

### D-11: A Bats test holds the token list together

- **Question:** Is a structural test justified, and what does it assert?
- **Decision:** `scripts/investigation-types.bats` with the six checks pinned in the plan.
- **Rationale:** The token list must agree across five surfaces held only by convention (C-9), and the evals have no
  runner in the repo, so Bats is the one check that can fail at each unit.
- **Evidence:** C-9, C-13, test-engineer V-1 and V-2, junior-developer JD-009.
- **Behavior impact:** Changing (docs and tests only).
- **Rejected alternatives:**
  - Checking every Dispatch agent exists as a file — deferred under YAGNI; no incident.
  - Pinning the bug Stop text in the test — rejected; the Stop format check covers drift that matters.
- **Revisit criterion:** A drift the six checks miss reaching a release.
- **Dissent (if any):** none.
- **Settles delta entry:** S-13
- **Dependent decisions:** —
- **Referenced in plan:** The guarding test, S-13

### D-12: The research and explanation boundaries

- **Question:** How do `investigate`, `research`, `code-overview`, and `code-walkthrough` divide questions?
- **Decision:** `investigate` answers a question about this codebase. `research` covers the open web and prior art.
  `code-overview` writes an orientation to a whole target, and `code-walkthrough` paces a person through code. Each
  description says so, and all four change in one commit.
- **Rationale:** Today the descriptions claim each other's territory (C-2, C-14).
- **Evidence:** C-2, C-14, user input in the confirmation turn ("i agree with your split recommendation between research
  and investigate"), user input during the run ("Add the line (Recommended)").
- **Behavior impact:** Changing, as the operator agreed.
- **Rejected alternatives:**
  - Stating the boundary from `investigate`'s side only — rejected by the operator.
- **Revisit criterion:** Routing evals showing a prompt landing in the wrong skill.
- **Dissent (if any):** none.
- **Settles delta entry:** S-9, S-10, S-11
- **Dependent decisions:** —
- **Referenced in plan:** S-9, S-10, S-11

### D-13: The Confluence wrapper

- **Question:** What does `investigate-to-confluence` change?
- **Decision:** Accept all three types; forward a leading type token first and the `/tmp/investigate-{slug}.md` path
  last; describe the report as "a single report whose sections follow the investigation type"; keep "stop after
  producing the report".
- **Rationale:** The wrapper restates today's sections and rejects non-bug requests (C-12). The new grammar reads its
  path as an out-path.
- **Evidence:** C-12, D-3, software-architect A9.
- **Behavior impact:** Changing, as agreed in the confirmation turn.
- **Rejected alternatives:**
  - Leaving the wrapper bug-only — rejected by the confirmed area, item 3.
- **Revisit criterion:** none.
- **Dissent (if any):** none.
- **Settles delta entry:** S-12
- **Dependent decisions:** —
- **Referenced in plan:** S-12

### D-14: Eval coverage

- **Question:** Which evals does the change add?
- **Decision:** The assertions pinned in S-14, a new `ruby-shop` scaffold, and `han-research` added to `plugins`.
- **Rationale:** No eval covers a non-bug type or the research boundary (C-13). The existing scaffold has two obvious
  defects that would pull a how-it-works run toward a bug report.
- **Evidence:** C-13, test-engineer S-13 review.
- **Behavior impact:** Changing (docs and tests only).
- **Rejected alternatives:**
  - Reusing `ruby-project` — rejected for its defects and lack of options material.
  - A fit-check eval — deferred until the runner's `AskUserQuestion` handling is known.
- **Revisit criterion:** A runner that handles `AskUserQuestion`.
- **Dissent (if any):** none.
- **Settles delta entry:** S-14
- **Dependent decisions:** —
- **Referenced in plan:** S-14
