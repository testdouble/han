# Current State Findings: Code Review and Research Response to Feedback Issue #194

## Provenance

This run's own discovery round, dispatched at Step 2. Feedback issue #194 is a defect report, not a current-state
findings report: it names four defects and their general principles but carries no file paths, no verbatim skill
content, and no account of the files as they stand. So no extraction path was available and the round ran in full.

Three agents were dispatched in parallel on 2026-09-09, each given the area, the recorded reason, and the path to
`artifacts/scope-boundary.md`:

- `han-core:structural-analyst` — module boundaries, load conditions, duplication, and the shape a new rule would
  have to match. Findings `S-1` through `S-16`.
- `han-core:behavioral-analyst` — the data flow through a run's steps, what happens on an empty-input path, and every
  stated check over a run's own output. Findings `B-1` through `B-10`.
- `han-core:concurrency-analyst` — the parallel fan-out and the merge of what comes back, because defect 4 is a
  merge-coordination failure. Findings `R-1` through `R-7` on `research`, and `CR-1` through `CR-4` on `code-review`.

The area is Markdown instruction files, not a compiled language, so each analyst was briefed on the translation: a
`SKILL.md` is the entry point and main procedure, a `references/` file is a module the procedure loads by instruction,
an `Agent` dispatch is a call into another unit, and the parallel dispatch of several agents whose output merges into
one document is the concurrency.

The Project Context and Gaps sections below come from the run's own sweep, not from the specialists.

## Project Context

- **Stack:** Markdown (skill, agent, and doc content) and Bash (skill `scripts/`, plus the shared repo-root
  `scripts/`). npm manages dev tooling only; there is no application build or dev server. Lint is
  `npm run lint` (`prek run --all-files`: Prettier, ShellCheck, file hygiene). Test is `npm test` (Bats over every
  `*.bats` file outside `node_modules`).
- **Conventions source:** `CLAUDE.md` at the repository root, its `## Project Discovery` section. No
  `project-discovery.md` exists.
- **ADRs found:** one, `docs/adr/0001-project-configurable-default-swarm-size.md`, which records the
  `default-swarm-size` config setting the two skills in this area both read. Nothing in it bears on the four defects.
- **Coding standards found:** none under a `docs/coding-standards/` path. The repository's equivalent is the
  plugin-authoring guidance under `han-plugin-builder/skills/guidance/references/`, which `CLAUDE.md` names as
  mandatory for any change to a skill or agent. Two files in it govern this change directly and are recorded as
  findings below: `skill-building-guidance/progressive-disclosure.md` (C-15) and
  `skill-building-guidance/graceful-degradation.md` (C-13).
- **Recent churn:** heavy and recent across the area. Over the last ninety days, `code-review/SKILL.md` was touched
  in twenty-eight commits and `research/SKILL.md` in thirteen, with `references/template.md`,
  `references/output-verification.md`, and `references/finding-content.md` each touched repeatedly. Two of those
  commits were made to bring the file back under a size ceiling: `ab0476c refactor(code-review): bring the skill body
  under the 500-line ceiling` and `33ed427 fix(han): bring skills back under Anthropic's authoring limits`. The
  `code-review` skill is under active revision, so the plan should expect its line numbers to have moved by build
  time and should name content rather than positions.

## Gaps

What the sweep searched for and did not find:

- **No dedicated coding-standards directory.** Searched `docs/coding-standards/`. The authoring guidance under
  `han-plugin-builder/` fills that role instead, and `CLAUDE.md` says so.
- **No ADR on degraded execution modes, agent availability, or citation verification.** The single ADR covers swarm
  sizing only. So the two rules this change introduces have no prior decision record to align with or supersede, and
  the precedent has to come from the authoring guidance and from sibling skills instead (C-13, C-14).
- **No repository-wide convention for disclosing a coverage gap in a report.** Searched every `SKILL.md` for
  phrasings around absent specialist coverage. One skill has it (C-14). Nothing shared states it, so there is no
  canonical file to cite.
- **No test coverage over skill instruction content.** The Bats suite covers the shell scripts beside it. Nothing
  executes or asserts on a `SKILL.md`'s procedure, so no test pins the behavior this change alters, and no test will
  break if the change is wrong. Verification is reading and running the skills.
- **No runtime evidence of the four defects.** Every finding below rests on the procedure text as written. Nobody in
  this run could observe a live run in an environment that forbids agent dispatch, or a live fan-out whose registries
  collided. The behavioral analyst labeled its own defect-1 finding `Unverified` for exactly this reason. The issue
  itself supplies the runtime evidence: each defect is a run that already happened.

## Findings

### C-1: The only handling of "no agents ran" is a step-skip guard, not a mode

- **Claim:** One sentence in Step 7 is the entire procedure's handling of agent dispatch producing nothing. It names
  which sub-steps to skip and nothing else: no fallback mode, no statement of what coverage is lost, no disclosure
  requirement.
- **Location:** `han-coding/skills/code-review/SKILL.md`, Step 7 ("Collect and Classify Agent Results")
- **Evidence:**

  ```markdown
  Wait for all agents dispatched in Step 3 to complete. Each agent returns a summary with finding counts and a file
  path. **Skip Steps 7.1–7.3 if no agents were dispatched in Step 3; Step 7.4 still runs whenever the review has
  produced at least one corrective finding (manual or agent).**
  ```

- **Raised by:** `han-core:structural-analyst` (S-1) and `han-core:behavioral-analyst` (B-1), independently, in the
  same words
- **Confidence:** Verified. Both agents grepped the full skill body and every reference file for "unavailable",
  "Agent tool", and "no agents" and found no other site.
- **Bears on:** S-1, S-2, S-3, D-1, D-3

### C-2: No downstream surface renders a coverage disclosure

- **Claim:** The report template has no slot for a statement of which specialist coverage ran, and the structural
  verification list has no item requiring one. The template's only always-present elements are the summary table and
  the recommendation, and every other section renders only when it has content. So a zero-agent run and a
  full-roster run produce structurally indistinguishable reports.
- **Location:** `han-coding/skills/code-review/references/template.md`, the `LAZY SECTIONS` comment;
  `han-coding/skills/code-review/references/output-verification.md`, Step 9.1
- **Evidence:**

  ```markdown
  LAZY SECTIONS: render a section ONLY when it has content. Do not emit a heading
  followed by empty-state placeholder text. The Review Summary table and the Review
  Recommendation are always present; every other section below appears only when it has
  at least one item.
  ```

  The one verification item that reads dispatch state guards the opposite failure, findings leaking in from an agent
  that never ran:

  ```markdown
  2. Agent findings from every dispatched agent (testing, edge-case, structural, behavioral, concurrency, data,
     devops, han-core:junior-developer) have valid task IDs continuing from manual review IDs. Findings from agents
     that were not dispatched in Step 3 must not appear.
  ```

- **Raised by:** `han-core:structural-analyst` (S-2) and `han-core:behavioral-analyst` (B-2, B-10)
- **Confidence:** Verified
- **Bears on:** S-4, S-5, S-6, D-2

### C-3: The closing message has four fixed parts and coverage is not one of them

- **Claim:** Step 10 specifies the closing message as four ordered parts. None of them carries the roster or the
  coverage it achieved, so a manual-only run and a full-roster run produce identically shaped messages.
- **Location:** `han-coding/skills/code-review/SKILL.md`, Step 10 ("Present")
- **Evidence:**

  ```markdown
  1. **The recommendation**, in the words the report's own Review Recommendation uses.
  2. **The counts by severity** — critical, warning, suggestion. Name any YAGNI count separately, never folded into
     the total.
  3. **The path** to the report file. Name the report you replaced when Step 8.6 replaced one, and the destination
     you could not use when it fell back.
  4. **The run's own facts, last:** the size band and why, and the validator reconciliation line. Or nothing at all.
  ```

  Part 4 is the natural home: it is already where the run's own conduct is reported, and it already names the size
  band and the validator reconciliation.

- **Raised by:** `han-core:structural-analyst` (S-3) and `han-core:behavioral-analyst` (B-2)
- **Confidence:** Verified
- **Bears on:** S-7, D-2

### C-4: Agent selection reasons only about file-list signals, never about whether dispatch is reachable

- **Claim:** The selection step decides the roster entirely from signals in the changed-file list. Two agents are
  dispatched unconditionally at every size. Nothing in the selection logic asks whether the `Agent` tool is
  available, and the frontmatter lists `Agent` beside every other tool with no guard. So an environment that forbids
  dispatch is invisible to the procedure until a tool call fails, and the guard in C-1 is the only thing that reacts.
- **Location:** `han-coding/skills/code-review/references/agent-dispatch.md`, Step 3.2;
  `han-coding/skills/code-review/SKILL.md`, frontmatter `allowed-tools`
- **Evidence:**

  ```markdown
  **Always dispatch — minimum roster across all sizes:**

  1. `han-core:junior-developer` — generalist clarity and standards check, applicable to any change.
  2. `han-core:adversarial-security-analyst` — security findings have a non-negotiable evidence standard that already
     prevents theoretical reports; the agent stays silent when the standard is not met.
  ```

- **Raised by:** `han-core:structural-analyst` (S-4)
- **Confidence:** Verified
- **Bears on:** S-1, D-1, D-3

### C-5: The manual review is never scoped to substitute for the specialist categories

- **Claim:** The manual checklist is the same fixed set of categories whether the run dispatched every agent or none.
  Nothing conditions its scope or depth on the dispatch outcome. The procedure treats the manual passes and the agent
  results as two independent tributaries that merge at report time, never as a primary path and a fallback.
- **Location:** `han-coding/skills/code-review/SKILL.md`, Step 3 opening and Step 4;
  `han-coding/skills/code-review/references/review-checklist.md`
- **Evidence:** Step 3 states the asymmetry in what the agents are responsible for:

  ```markdown
  Agents analyze source code to identify coverage gaps, edge cases, security vulnerabilities, structural problems,
  ```

  None of those categories has a manual-mode instruction to substitute when the agents are absent. The checklist's
  own coverage of them is generic where the agents are deep: `Testing` asks whether unit and integration tests exist
  and says detailed coverage analysis is done by the testing agent instead.

  ```markdown
  - If no test files exist for the reviewed code, flag as a Warning — detailed coverage analysis is also performed by
    testing agents in Step 7, but complete absence of tests must be caught here
  ```

- **Raised by:** `han-core:behavioral-analyst` (B-3)
- **Confidence:** Verified
- **Bears on:** S-1, D-4

### C-6: The checklist governs source text only, and the procedure actively steers away from built output

- **Claim:** No checklist category instructs reading anything but the code as written, and Step 4 tells the run to
  skip compiled output outright. A change that alters what gets packaged is therefore reviewed against the source
  diff alone, which is the one place the defect does not appear.
- **Location:** `han-coding/skills/code-review/SKILL.md`, Step 4, sub-step 1;
  `han-coding/skills/code-review/references/review-checklist.md`, every category
- **Evidence:**

  ```markdown
  1. **Skip generated files** (lock files, compiled output, vendor directories, auto-generated code) — note them as
     skipped in the review
  ```

  The behavioral analyst grepped the skill and its references for `disassemb`, `compiled`, `packag`, `artifact`,
  `jar`, `bundl`, `shad`, and `vendor`. The only hits were the skip rule above, Step 1.5's unrelated "planning
  artifact", and the security agent's "dependency manifests".

- **Raised by:** `han-core:behavioral-analyst` (B-4) and `han-core:structural-analyst` (S-16)
- **Confidence:** Verified
- **Bears on:** S-8, D-5, D-6

### C-7: The checklist's shape a new category has to match

- **Claim:** The checklist is a list of named categories, each a bullet list of concrete triggers, opened by a
  contents list that names every category in order. Categories that apply only to some changes carry a
  `(when applicable)` suffix on both the contents entry and the heading. That suffix convention is the existing shape
  a conditional new category matches, and `Code Organization` is the nearest semantic neighbour but is a
  file-placement rule rather than an inspection rule.
- **Location:** `han-coding/skills/code-review/references/review-checklist.md`, the contents list and the
  `Data Isolation`, `Database`, and `Architecture Decision Records` headings
- **Evidence:**

  ```markdown
  - Data Isolation (when applicable)
  ...
  - Database (when applicable)
  - Architecture Decision Records (when applicable)
  ```

  And `Code Organization` in full, showing it does not reach built output:

  ```markdown
  **Code Organization**

  - Files placed in the correct package/directory per project structure
  - Related code grouped together, naming follows project conventions
  ```

- **Raised by:** `han-core:structural-analyst` (S-16)
- **Confidence:** Verified
- **Bears on:** S-8, D-5

### C-8: No rule resolves the enclosing member of a cited location, and the check that looks like one tests the file

- **Claim:** The procedure's only instruction about a finding's location is to include it. Nothing states how a
  location is established, and no pass re-reads a cited unit in isolation before severity is final. The verification
  item that appears to cover this confirms the file appears in the reviewed file list, never that the line or symbol
  is the correct enclosing unit for the claim.
- **Location:** `han-coding/skills/code-review/SKILL.md`, Review Constraints;
  `han-coding/skills/code-review/references/output-verification.md`, Step 9.1 items 3 and 6
- **Evidence:** The whole of what the skill says about establishing a location:

  ```markdown
  Include `file_path:line_number` references and code examples for suggested fixes.
  ```

  And the two checks that read like verification of it:

  ```markdown
  3. Agent findings have valid `file_path:line_number` references
  ...
  6. All `file_path:line_number` references point to real files from the file list determined in Step 1
  ```

  Item 3's "valid" means present and well-formed. Item 6 resolves the path against a list. Neither reads the code at
  the cited line.

- **Raised by:** `han-core:behavioral-analyst` (B-5, B-9) and `han-core:structural-analyst` (S-7)
- **Confidence:** Verified
- **Bears on:** S-9, S-10, D-6, D-7

### C-9: The one pass in `code-review` that re-reads the code has four named challenge axes and location is not one

- **Claim:** Step 7.4 dispatches a critic that judges findings against the code rather than against the producing
  agent's rationale, and it is the only pass in the skill that does. Its brief names four things to challenge. None
  of them is whether a finding's cited location is the right enclosing unit, and the brief's own demand for
  counter-evidence at a path and line presumes the finding's location is already right. It also does not run at all
  when the review produced no corrective findings.
- **Location:** `han-coding/skills/code-review/references/finding-filters.md`, Step 7.4
- **Evidence:**

  ```markdown
  > Treat every finding as wrong until the code proves it right. For each finding, return exactly one verdict —
  > **Confirmed**, **Partially Refuted**, or **Refuted** — and for anything other than Confirmed, cite concrete
  > counter-evidence at `file_path:line_number`. Challenge specifically: (a) findings that misread the change's intent or
  > the surrounding code; (b) findings that target pre-existing code this change did not introduce or worsen, unless the
  > issue is critical irrespective of who introduced it; (c) findings whose rationale hedges its own reachability in
  > paraphrase ("unlikely in practice", "would need an unusual sequence", "only under a race we don't see") that the
  > literal-phrase gate did not catch; (d) severity that overstates impact, where the true worst case is "an operator sees
  > an error and retries". Do not invent new findings — you are validating the list, not extending it.
  ```

  The lettered list is an extensible sequence, so a fifth axis has an existing home and an existing form.

- **Raised by:** `han-core:structural-analyst` (S-8) and `han-core:behavioral-analyst` (B-9)
- **Confidence:** Verified
- **Bears on:** S-3, S-10, S-11, D-7

### C-10: `research`'s traceability invariant is resolvability, stated identically in four places

- **Claim:** The invariant is defined as resolution to an entry. Every one of the four sites that states or checks it
  describes the existence of a target, never a match between what the entry says and what the claim it supports
  asserts. A citation that lands on a real but unrelated entry passes at all four.
- **Location:** `han-research/skills/research/SKILL.md`, Operating Principles, Step 6, and Step 8;
  `han-research/skills/research/references/research-report-template.md`, the `Sources` comment
- **Evidence:**

  ```markdown
  The traceability invariant is **resolvability**: every artifact ID
  (`A#`) cited inline must resolve to a registry entry carrying its link, retrieval date, trust class, and evidence
  status.
  ```

  ```markdown
  Every entry gets an ID that Research Results, Options, and the Recommendation cross-reference inline, so every
  conclusion traces to its sources — every `A#` cited inline must resolve to a registry entry.
  ```

  ```markdown
  On top of the fidelity criterion, confirm every cited `A#` still resolves to its registry entry.
  ```

  ```markdown
  Every A# cited inline in Research Results, Options, or the
  Recommendation must RESOLVE to an entry here; that resolvability is the
  traceability invariant.
  ```

- **Raised by:** `han-core:behavioral-analyst` (B-6) and `han-core:structural-analyst` (S-9, S-10)
- **Confidence:** Verified
- **Bears on:** S-12, S-15, S-16, D-8

### C-11: Every parallel analyst mints `A1` independently and the merge renumbers with no mapping

- **Claim:** The output format handed to every dispatched analyst starts its sources registry at `A1`, and the band
  caps put two to eight analysts in a single wave at medium and large. The merge step consolidates them into one
  sequence. No step records an old-to-new mapping, and no step rewrites inline citations through one. The
  orchestrator synthesizes from each analyst's verbatim output, which still carries that analyst's own numbering.
- **Location:** `han-research/agents/research-analyst.md`, the `Output Format` section;
  `han-research/skills/research/SKILL.md`, Step 4 roster caps, Step 6, Step 7
- **Evidence:** The per-analyst format, identical for every instance:

  ```markdown
  ### Sources

  **A1: [short source title]**
  ...
  **A2: [short source title]** ...
  ```

  The merge, in full:

  ```markdown
  Collect the full verbatim output from every agent. Consolidate every information source used that is relevant to
  the results into a single indexed Sources registry (`A1, A2, …`), merging duplicates.
  ```

  And the band caps that guarantee more than one analyst above small:

  ```markdown
  **medium** runs two to three parallel
  `han-research:research-analyst` angles split by domain or option cluster, plus `han-core:codebase-explorer` when relevant,
  then `han-core:adversarial-validator` (3–5 agents); **large** runs a `han-research:research-analyst` per major domain or
  option cluster plus `han-core:codebase-explorer`, then `han-core:adversarial-validator` (5–8 agents).
  ```

  Two facts follow that the plan depends on. The collision is not incidental: at medium and large it is structural,
  because every analyst in the wave restarts at `A1`. And "merging duplicates" is itself a renumbering, so the merge
  cannot preserve any analyst's numbering even in principle.

- **Raised by:** `han-core:behavioral-analyst` (B-7) and `han-core:structural-analyst` (S-11, S-12)
- **Confidence:** Verified
- **Bears on:** S-13, D-9

### C-12: The sources table already carries the one-line summary a semantic check would read

- **Claim:** The registry table has a `Summary (one line)` column holding what each source says that is relevant.
  That is the exact input a check comparing a citation against the claim it supports needs, so such a check requires
  no new field in the template and no new content from any analyst.
- **Location:** `han-research/skills/research/references/research-report-template.md`, the `Sources` table header;
  `han-research/skills/research/SKILL.md`, Step 6
- **Evidence:**

  ```markdown
  | ID  | Source        | Link / location                              | Retrieved           | Trust class               | Summary (one line)         | Evidence status                                                        |
  ```

  Step 6 already requires the content of that cell:

  ```markdown
  a plain-language
  summary of what the source says that is relevant (a one-line cell by default; a full prose summary for the sources the
  recommendation rests on)
  ```

- **Raised by:** the run's own sweep
- **Confidence:** Verified
- **Bears on:** S-12, S-20, D-8

### C-13: The repository already has a named-mode degradation pattern, and `code-review` already uses it

- **Claim:** The authoring guidance carries a rule for exactly the shape defect 1 needs: detect the environment,
  branch to a mode that has a name, and continue producing useful output. `code-review` already applies it to git
  availability, with three named modes the rest of the skill refers to by name. So the fix for defect 1 has a
  precedent inside the file it changes, and its worked example in the guidance is this very skill.
- **Location:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/graceful-degradation.md`;
  `han-coding/skills/code-review/SKILL.md`, Step 1
- **Evidence:** The rule, and its distinction from a hard prerequisite:

  ```markdown
  ### Rule: Detect environment state with a script, then branch to a named mode
  ...
  Define modes explicitly by name so the skill body and review output can reference them clearly
  ```

  ```markdown
  This doc covers _partial context_ — situations where the environment is usable but some data (a git history, project
  config, docs directory) is absent. Graceful degradation means detecting what is available, selecting a named execution
  mode, and continuing to produce useful output.
  ```

  And the skill's own existing use of it:

  ```markdown
  **Mode A: Full git context** — script reports `git-available: true` and `changed-files-start` block has content.
  ...
  **Mode B: Git but no branch changes** — script reports `git-available: true` but `changed-files: none`.
  ...
  **Mode C: No git / no changes found**
  ```

  One difference the plan has to hold: the git modes are detected by a script that probes the environment before the
  work starts. Whether agent dispatch is permitted is not something the existing script can probe.

- **Raised by:** the run's own sweep
- **Confidence:** Verified
- **Bears on:** S-1, D-1, D-3

### C-14: One sibling skill already carries the coverage-disclosure pattern, in both its artifact and its summary

- **Claim:** `plan-implementation` records an evidence class no specialist could audit in its written history and
  names it again in its closing summary, explicitly so the coverage gap is visible rather than silent. It also
  presents that disclosure as non-blocking. That is the same two-place disclosure defect 1 asks for, already stated
  in the repository's own words, so the fix follows a precedent rather than inventing a convention. Nothing shared
  states the pattern, so there is no canonical file to cite: the wording has to be written into `code-review` itself.
- **Location:** `han-planning/skills/plan-implementation/SKILL.md`, the round-aggregation step and the closing
  summary step
- **Evidence:**

  ```markdown
  Record any evidence class no specialist could audit. When decisions rest on material no specialist received, say so in the
  iteration history, so the coverage gap is visible rather than silent.
  ```

  ```markdown
  - Any finding that stayed `Unverified` because a specialist could not inspect its input, each with its disposition, and
    any evidence class no specialist could audit. Neither is presented as build-blocking.
  ```

- **Raised by:** the run's own sweep
- **Confidence:** Verified
- **Bears on:** S-4, S-7, D-2

### C-15: `code-review/SKILL.md` sits five lines under a ceiling the guidance sets and two commits have already enforced

- **Claim:** The authoring guidance sets 500 lines as the ceiling for a `SKILL.md` body and says to treat it as a
  ceiling rather than a target. The file is 495 lines. Two commits in the last ninety days exist only to bring skill
  bodies back under it. So new instruction content cannot land in the body: it goes into a reference file, and the
  body gains at most a pointer.
- **Location:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md`;
  `han-coding/skills/code-review/SKILL.md` (495 lines, measured 2026-09-09)
- **Evidence:**

  ```markdown
  Anthropic and the cross-tool Agent Skills standard both
  recommend keeping the SKILL.md body under **500 lines**; past that, move detail into `references/`. Treat 500 lines as
  the ceiling, not the target.
  ```

  The same file also carries the rule that governs how content moves, and names this repository as the place the
  failure happened:

  ```markdown
  **The unit of a move is a whole sentence or a whole bullet, never a fragment.** A move that cuts mid-sentence leaves the
  SKILL.md stating half an instruction and the reference file opening with the other half, and neither file read alone
  says what the step does. This has happened twice in this repository, both times in a commit made to get a skill back
  under the ceiling.
  ```

  And Level 3's own constraints on where a new reference file can sit:

  ```markdown
  Level 3 is one level, not
  a chain: link every reference file directly from SKILL.md, and open any reference file over roughly 100 lines with a
  contents list, so a partial read still shows what the file holds.
  ```

- **Raised by:** the run's own sweep
- **Confidence:** Verified
- **Bears on:** S-2, S-17, D-11, D-16, D-19

### C-16: The repository's authoritative-home convention exists, and neither new rule has one

- **Claim:** Where a rule has several consumers, this skill names one file as its authoritative home and every other
  site cites it by name instead of restating it. Size-based demotion works that way. Neither of the two rules this
  change introduces has such a home yet, and the sites that would consume each one are already separate files.
- **Location:** `han-coding/skills/code-review/SKILL.md`, Step 3.3 pointer;
  `han-coding/skills/code-review/references/agent-dispatch.md`, Step 3.3
- **Evidence:**

  ```markdown
  **Step 3.3 is the authoritative home for size-based demotion.** Every other site that needs the size-based rule
  references this step by name rather than restating it: the Review Constraints rule for manual findings, the Step 7.2
  demotion gate for agent findings, the rubric in `references/agent-finding-classification.md`, and the YAGNI two-pass
  procedure in `references/review-checklist.md`.
  ```

- **Raised by:** `han-core:structural-analyst` (S-14)
- **Confidence:** Verified
- **Bears on:** S-17, D-11, D-19

### C-17: The vendored rule files are byte-identical, so a fix inside one lands in every copy

- **Claim:** `evidence-rule.md`, `yagni-rule.md`, and `config-rule.md` are identical across the plugins that carry
  them, by the repository's own stated convention rather than by accident. A change to any of them has to be made to
  the canonical copy and re-synced to the rest. This bounds where the fix can go: a rule placed in a vendored file
  becomes a multi-plugin edit.
- **Location:** `han-core/references/`, `han-coding/references/`, `han-research/references/`; `CLAUDE.md`
- **Evidence:** `CLAUDE.md` states the convention:

  ```markdown
  Vendored byte-identical into every skill-carrying plugin's `references/`; edit the canonical copy and re-sync the others.
  ```

  The structural analyst confirmed the three files are in fact identical across the three plugins by diff, so nothing
  has drifted.

- **Raised by:** `han-core:structural-analyst` (S-13)
- **Confidence:** Verified
- **Bears on:** D-11

### C-18: The YAGNI checklist's mode exception lives only in its caller, not in the file named canonical

- **Claim:** Step 4 suspends the YAGNI checklist in the two modes that have no diff. The checklist file the skill
  calls the canonical home for that procedure states it unconditionally. A reader who opens the checklist alone,
  which the "canonical home" framing invites, sees an instruction its caller overrides without any cross-reference
  from inside the checklist.
- **Location:** `han-coding/skills/code-review/SKILL.md`, Step 4 mode scope note;
  `han-coding/skills/code-review/references/review-checklist.md`, the YAGNI section
- **Evidence:**

  ```markdown
  - **Skip the YAGNI checklist entirely in Mode B and Mode C unless the user explicitly requests it in `$focus_areas`.**
  ```

  ```markdown
  Apply YAGNI in two passes for every change in the diff.
  ```

- **Raised by:** `han-core:structural-analyst` (S-6)
- **Confidence:** Verified
- **Bears on:** D-5 (its mode-scope paragraph), D-17 (cut list)

### C-19: A second citation surface sits inside the registry being renumbered

- **Claim:** Each source entry carries an evidence-status field that cross-references other sources by `A#`. It is a
  citation in every respect that matters, written by an analyst against that analyst's own local numbering, and it
  lives inside the registry the merge renumbers rather than in prose a reader would recognize as a citation. No step
  names it when stating the invariant, when merging, or when checking resolution. A fix that rewrites only the inline
  citations in Results, Options, and the Recommendation therefore leaves this surface stale.
- **Location:** `han-research/agents/research-analyst.md`, the `Sources` entry format;
  `han-research/skills/research/references/research-report-template.md`, the table's last column and the `A#` detail
  block
- **Evidence:**

  ```markdown
  - **Evidence status:** corroborated by {A#} | single source — caveated | contradicted by {A#}
  ```

  The same field appears twice in the template, once as the table's last column and once in the recommendation-bearing
  detail block:

  ```markdown
  - **Evidence status:** corroborated by {A#} | single source (caveated) | contradicted by {A#}
  ```

  And Step 6 requires the field on every entry without saying anything about the identifiers inside it:

  ```markdown
  and an evidence status.
  ```

- **Raised by:** `han-core:concurrency-analyst` (R-5)
- **Confidence:** Verified
- **Bears on:** S-13, D-9

### C-20: Two of the three merge collision cases have no stated handling

- **Claim:** The merge addresses one collision case and leaves two unstated. Two analysts citing the same underlying
  source is handled by "merging duplicates". Two analysts using the same identifier for different sources, which is
  the reported defect's precondition, is not named. Nor is an analyst's source being dropped at the merge because it
  is not relevant to the results, which leaves a citation to it with no home at all.
- **Location:** `han-research/skills/research/SKILL.md`, Step 6
- **Evidence:** The whole of the merge's collision handling, and the relevance filter that can drop a source:

  ```markdown
  Consolidate every information source used that is relevant to
  the results into a single indexed Sources registry (`A1, A2, …`), merging duplicates.
  ```

  Note the two jobs that one sentence does: it filters by relevance and it renumbers. Either alone would break a
  carried-over citation.

- **Raised by:** `han-core:concurrency-analyst` (R-6)
- **Confidence:** Verified
- **Bears on:** S-13, D-9, D-10

### C-21: `code-review`'s own fan-out is structurally immune to the same defect

- **Claim:** The parallel specialists in `code-review` cannot produce the collision `research` produces, for two
  independent reasons. Each specialist has its own fixed identifier prefix, so two specialists' local first finding
  can never occupy the same identifier. And the single renumbering into the review's own sequence happens before any
  cross-reference between findings is minted, so no reference is ever written against a pre-merge identifier and then
  carried past the renumbering. This is a negative result and it bounds the change: defect 4's fix belongs in
  `research` and has no counterpart to add here.
- **Location:** `han-coding/skills/code-review/references/agent-finding-classification.md`, the per-agent series
  prefixes; `han-coding/skills/code-review/SKILL.md`, Step 7.3;
  `han-coding/skills/code-review/references/output-verification.md`, Step 9.0;
  `han-coding/skills/code-review/references/finding-filters.md`, Step 7.4
- **Evidence:** The prefixes are distinct per agent, so each numbers locally from 1 without colliding: `T`, `EC`,
  `SEC`, `S`, `B`, `C`, `D`, `DV`, `OCE`. Renumbering into the review's own sequence happens at Step 7.3:

  ```markdown
  Continue task ID numbering sequentially from Steps 4-6
  ```

  Both cross-reference mechanisms run after that. Step 9.0's tension note is written at Step 9, and Step 7.4's
  validator is handed identifiers that are already final:

  ```markdown
  2. **The complete corrective finding list**, with each finding's task ID, current severity,
     `file_path:line_number`, the finding's claim, and the producing agent's rationale **verbatim**.
  ```

- **Raised by:** `han-core:concurrency-analyst` (CR-1, CR-2, CR-4)
- **Confidence:** Verified
- **Bears on:** D-11 (the shared-rule rejection)

### C-22: The junior-developer deduplication instruction names no mechanism

- **Claim:** The classification rubric tells the run not to duplicate a generalist finding another agent already
  raised, and to reference the specialist's classification instead. The generalist runs in the same parallel wave as
  the specialists and in an isolated context, so it cannot know what any specialist concluded; only the orchestrator
  can carry the substitution out at merge time. Nothing states how "the same issue" is determined. The verification
  list checks that the reference exists, never that it points at the right finding, which is the issue's own shared
  shape in a different defect.
- **Location:** `han-coding/skills/code-review/references/agent-finding-classification.md`, the
  junior-developer rule; `han-coding/skills/code-review/references/output-verification.md`, Step 9.1 item 10
- **Evidence:**

  ```markdown
  Do not duplicate a junior-developer finding when another agent has already raised the same issue — prefer the
  specialist's classification and reference it from the JD finding instead
  ```

  ```markdown
  10. Junior-developer findings that overlap with a specialist agent's finding reference the specialist finding instead
      of duplicating it
  ```

- **Raised by:** `han-core:concurrency-analyst` (CR-3)
- **Confidence:** Unverified. The analyst could not inspect a completed run's output to see whether the substitution
  is carried out correctly in practice, so the claim is about the instruction rather than about observed behavior.
- **Bears on:** D-17 (cut list)

## Findings No Agent Could Audit

Two evidence classes nobody in this run could reach.

**A live run with agent dispatch forbidden.** No agent could observe `code-review` executing in an environment that
denies the `Agent` tool, so every claim about what such a run produces rests on reading the procedure. The behavioral
analyst labeled its own finding `Unverified` on this ground. Closing it would take running the skill with dispatch
denied and reading the report it writes. The issue supplies the substitute: it reports that run as something that
already happened, and what it produced.

**A live fan-out whose analyst registries collided.** Likewise, nobody could observe a medium or large `research` run
merging two analysts' registries. C-11 establishes from the procedure that the collision is structural above the
small band, which is stronger than an observation of one run, but it is not the same as watching a citation land on
the wrong entry. The issue reports that too as something that already happened.

**A completed run's output showing how a duplicate generalist finding was reconciled.** C-22 rests on the instruction
alone for the same reason: no run transcript was available. That finding is labeled `Unverified` and is outside the
four defects in any case.

Neither of the first two blocks the plan. Both are cases where the recorded reason carries the runtime evidence the
code cannot.
