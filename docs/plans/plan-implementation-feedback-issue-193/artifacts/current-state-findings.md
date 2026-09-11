# Current State Findings: plan-implementation feedback (issue #193)

## Provenance

This run's own discovery round. No prior findings report existed: issue #193 is a feedback report naming outcomes, not
a code findings report, and it carries no file paths or verbatim excerpts.

Two specialists were dispatched in parallel against the area recorded in `scope-boundary.md`:

- `han-core:structural-analyst` — module boundaries, coupling, dependency direction, duplication, abstractions.
  Returned findings `S-1` through `S-17`.
- `han-core:behavioral-analyst` — data flow, error propagation, state, integration boundaries at runtime. Returned
  findings `B-1` through `B-14`.

`han-core:concurrency-analyst` was not dispatched. The area is markdown instruction files and Bash scripts with no
concurrent access, no async coordination, and no shared mutable state. The one thing in the area that resembles
concurrency is the parallel specialist dispatch inside a round, and that is a dispatch pattern in prose rather than
code an analyst could inspect.

Both specialists carried the same `Unverified` label on their whole report: neither could inspect the run behind issue
#193, because no transcript, plan folder, decision log, or editor report from it exists in this repository. Every
finding below rests on the files as written. That label is carried forward per finding.

Each `C-N` below merges the two specialists' wording where they raised one finding, and names both originating
identifiers. Where I verified a claim myself with the orchestrator's own tools, the `Confidence` line says so and names
the command.

## Project Context

- **Stack:** Markdown (skill, agent, template, and reference content) and Bash (skill `scripts/`, plus the shared
  repo-root `scripts/`). No application build and no dev server.
- **Conventions source:** `CLAUDE.md` at the repository root, whose `## Project Discovery` section carries the stack,
  the commands, and the repository layout. `project-discovery.md` does not exist; the probe returned nothing.
- **ADRs found:** `docs/adr/0001-project-configurable-default-swarm-size.md`, which settles how a project configures a
  default swarm size. It is the only ADR in the repository.
- **Coding standards found:** None under `docs/`. `CLAUDE.md` names
  `han-plugin-builder/skills/guidance/references/` as the authority for all skill, agent, and plugin authoring, and
  routes new work through the `skill-builder`, `agent-builder`, and `guidance` skills.
- **Recent churn:** `git log --since="90 days ago" --name-only` over the area. `plan-implementation/SKILL.md` leads
  with 28 commits, then `plan-a-feature/SKILL.md` with 22 and `readability-editor.md` with 10. The reference files
  those two skills delegate to move rarely: `synthesis-directives.md` twice, `round-aggregation.md` and
  `implementation-decision-log-template.md` three times each. `plan-a-change/SKILL.md` has one commit, the one that
  created it.
- **Commands:** `npm run lint` runs `prek run --all-files` (Prettier, ShellCheck, file hygiene). `npm test` runs Bats
  over every `*.bats` file outside `node_modules`.

## Gaps

- **No coding standard file under `docs/`.** Searched `docs/` and the repository root. The authoring rules live inside
  `han-plugin-builder`, which is an opt-in plugin rather than a repo-root standard, so there is no file to check a
  change against outside that plugin.
- **No ADR governing any mechanic in this area.** Searched `docs/adr/`. Nothing records a decision about decision-log
  structure, deferral lifetime, synthesis write order, citation granularity, or the readability editor. Every
  structural choice in the area was made in the skill files themselves and is unrecorded elsewhere.
- **No prior plan folder for issue #193.** Searched `docs/plans/` and `docs/research/`. The nearest precedent is
  `docs/plans/test-planning-feedback-issue-148/`, which holds a single `feedback-investigation.md` and no plan.
- **No test harness covering skill or template content.** The eight `*.bats` files in the repository all test shell
  scripts: `han-config-dir`, `check-contract-pinning`, `check-cross-references`, `verify-design-images`,
  `detect-test-context`, `detect-review-context`, `remote-tag-state`, and `test/sanity.bats`. Nothing asserts anything
  about a `SKILL.md` or a template's structure, so a claim about a markdown file has no automated check behind it
  today.
- **No run transcript for issue #193.** Searched the repository. This is the gap both specialists named, and it is the
  reason every finding here is grounded in the files rather than in the reported run.

## Findings

### C-1: The deferral section has four writers and no reader

- **Claim:** `## Deferred (YAGNI)` and its `Reopen when:` trigger are written during planning and read back by nothing
  in any later phase of any skill. The only downstream consumer counts the entries.
- **Location:** `han-planning/references/yagni-rule.md:99,121-132` (the canonical definition);
  `han-planning/skills/plan-implementation/SKILL.md:64,378,474`;
  `han-planning/skills/plan-implementation/references/yagni-scope-sweep.md:36`;
  `han-core/agents/plan-synthesizer.md:287,398`; `han-planning/skills/plan-work-items/SKILL.md`;
  `han-coding/skills/tdd/SKILL.md`.
- **Evidence:**

  The canonical format, from `yagni-rule.md`:

  ```markdown
  ## Deferred (YAGNI)

  ### {item name}

  **Why deferred:** {which gate failed — evidence test or simpler-version test, with the specific reason}
  **Reopen when:** {the concrete trigger that would justify revisiting — a metric, an incident class, a customer commitment, a dependency landing, a regulation taking effect}
  ```

  The only consumer inside `plan-implementation`, at `SKILL.md:474`:

  ```markdown
  - The number of YAGNI deferrals captured in `feature-implementation-plan.md`'s `## Deferred (YAGNI)` section (omit this
    line if the section was not written because nothing qualified). Keep it distinct from the cut list above.
  ```

  `plan-work-items` reads one plan section by name at Step 4, and it is a different one:

  ```markdown
  **Read the plan's `## Open Items` section as part of this inventory, including the items marked
  `Blocks implementation: No`.**
  ```

  The same skill bars the artifacts folder outright at `SKILL.md:117`:

  ```markdown
  NEVER include process artifacts in work item bodies or the preamble. Excluded categories: iteration histories,
  decision logs, review findings...
  ```

- **Raised by:** `structural-analyst` S-1, `behavioral-analyst` B-7.
- **Confidence:** Verified. I confirmed the writer/reader split myself with a repo-wide grep for
  `Deferred (YAGNI)` excluding `node_modules` and `docs/plans/`: every hit outside the vendored `yagni-rule.md` copies
  and the docs is a writer, a template, or the one count at `SKILL.md:474`.
- **Bears on:** S-15, S-16. [D-13](change-decision-log.md#d-13-the-closing-summary-names-each-deferral-instead-of-counting-them), [D-14](change-decision-log.md#d-14-seed-a-definition-of-done-criterion-and-name-its-only-reader-plainly)

### C-2: `Referenced in plan:` names plan sections that no check resolves

- **Claim:** The decision log's back-link field holds free-text plan section headings. Nothing in the run verifies that
  a named section exists in the plan, and the one script that touches links strips the anchor before testing it.
- **Location:** `han-planning/skills/plan-implementation/references/implementation-decision-log-template.md:32-33,80,95`;
  `han-planning/skills/plan-implementation/references/synthesis-directives.md:59-60`;
  `han-planning/skills/plan-implementation/scripts/check-contract-pinning.sh`.
- **Evidence:**

  The field's contract:

  ```markdown
  - `Referenced in plan:` — sections of [../feature-implementation-plan.md](../feature-implementation-plan.md)
    that cite this decision with an inline parenthetical link.
  ```

  The invariant that restates it, with no check behind it:

  ```markdown
  Every `D#` in `artifacts/implementation-decision-log.md` lists its `Driven by rounds:` (`R#` IDs),
  `Dependent decisions:` (`D#` IDs), and `Referenced in plan:` (plan section headings).
  ```

  `check-contract-pinning.sh` discards the anchor before testing a link target:

  ```awk
  sub(/#.*$/, "", target)
  ```

  Its declared output covers four failures, and a dangling section name is none of them:

  ```
  #   deferral-phrase: line=<n> <phrase>        zero or more, only when result is failed
  #   unresolved-open-item: <id> field=<field>  zero or more, only when result is failed
  #   missing-artifact: <path> line=<n>         zero or more, only when result is failed
  #   stub-artifact: <path> bytes=<n>           zero or more, only when result is failed
  ```

- **Raised by:** `structural-analyst` S-2, `behavioral-analyst` B-12.
- **Confidence:** Verified. I read `check-contract-pinning.sh`'s header and confirmed its four output keys, and grepped
  every occurrence of `Referenced in plan` in the repository.
- **Bears on:** S-3, S-4. [D-3](change-decision-log.md#d-3-add-an-executed-cross-reference-check-rather-than-restating-the-invariant-in-prose)

### C-3: The synthesis writes the hub file second of three, so the one forward-pointing field is written before its target exists

- **Claim:** `feature-implementation-plan.md` is the file both companions point into, and the write order writes it
  after the decision log. The decision log's `Referenced in plan:` field is therefore filled while the plan does not
  yet exist, and no later step revisits it.
- **Location:** `han-planning/skills/plan-implementation/references/synthesis-directives.md:27-62`;
  `han-core/agents/plan-synthesizer.md:325-335`.
- **Evidence:**

  ```markdown
  1. **Write `artifacts/implementation-decision-log.md`** — classify each decision as **full** or **trivial** before
     writing it.
  2. **Write `feature-implementation-plan.md`** — the primary plan, following the template's progressive-disclosure
     order:
  3. **Backfill `artifacts/implementation-iteration-history.md`** — for each `R#` entry already present from Step 6,
     populate `Decisions produced:` with the `D#` IDs added or changed that round and `Changed in plan:` with the plan
     sections updated that round.
  ```

  Steps 2 and 3 write backward into files that already exist. Step 1 is the only one that names sections of a file
  that does not. The agent itself carries no ordering instruction and names none of the four cross-reference fields it
  is asked to hold; its own output contract is a single file, `Default filename: synthesized-plan.md`.

- **Raised by:** `structural-analyst` S-3, `behavioral-analyst` B-8, `behavioral-analyst` B-12.
- **Confidence:** Verified against the two files.
- **Bears on:** S-1. [D-2](change-decision-log.md#d-2-write-the-plan-first-in-the-synthesis-order)

### C-4: Nothing in the run detects a synthesis that returned partially or not at all

- **Claim:** The skill has no instruction covering a `plan-synthesizer` that terminates, returns nothing, or returns
  part of its work. No step between the dispatch and the closing summary tests whether the plan file exists.
- **Location:** `han-planning/skills/plan-implementation/SKILL.md:381-394` (Step 8), `SKILL.md:444-458` (Step 9's two
  executed checks), `SKILL.md` Step 1's overwrite prompt.
- **Evidence:**

  The only failure-handling language in the whole skill covers a different agent, the readability editor:

  ```markdown
  **When no usable report comes back** — the editor could not be reached, returned nothing, or returned something you
  cannot read as either of those two shapes
  ```

  Step 9's two executed checks read the plan and the boundary record; neither tests for the plan's absence as a
  distinct outcome. The only recovery path is Step 1's prompt on a later run:

  ```markdown
  If any of the three files already exist, ask the user whether to overwrite or append iteration notes
  ```

  That prompt cannot tell a complete prior run from a half-written one.

- **Raised by:** `behavioral-analyst` B-8.
- **Confidence:** Verified. Grepped the skill and the agent for failure-branch language; the two hits are both in Step
  8.5 and both concern the readability editor.
- **Bears on:** S-5. [D-4](change-decision-log.md#d-4-stop-the-run-when-synthesis-produced-no-plan-file), [D-5](change-decision-log.md#d-5-put-the-plan-existence-stop-in-both-file-writing-callers-worded-once), [D-24](change-decision-log.md#d-24-make-a-missing-companion-file-a-failure-not-an-unverified-result)

### C-5: A citation resolves to a whole decision entry, one level coarser than the field a figure came from

- **Claim:** Specialists are directed to cite a decision by its `D#` identifier. That identifier resolves to an entry
  carrying `Decision:` and `Rejected alternatives:` as sibling bullets, and nothing in the brief, the templates, or
  the aggregation states that a rejected alternative is an option the upstream run declined.
- **Location:** `han-planning/skills/plan-implementation/references/team-selection.md:101-104,161-164`;
  `han-planning/skills/plan-implementation/references/implementation-decision-log-template.md:60-73`;
  `han-planning/skills/plan-implementation/SKILL.md:149-155`.
- **Evidence:**

  The brief hands the log over unread, as a path:

  ```markdown
  Also pass the spec's `artifacts/decision-log.md`, `artifacts/team-findings.md`, and
  `artifacts/feature-technical-notes.md` paths if they exist (fall back to the spec folder root for legacy layouts) —
  **as paths only, not contents**, so the agent can read on demand.
  ```

  And directs citation at entry granularity:

  ```markdown
  - A directive to cite sections by filename and heading when raising findings — e.g.,
    `feature-specification.md#primary-flow`, or a specific `D#` in the spec's `artifacts/decision-log.md`, or `T3` in the
    spec's `artifacts/feature-technical-notes.md` — so the han-core:plan-synthesizer can cross-reference them precisely
    during synthesis.
  ```

  Step 1's only framing of the log is a note to read it:

  ```markdown
  Note the decisions already settled, any open items the spec flagged, the review team findings, and any committed
  technical mechanics the plan must honor.
  ```

  The chosen-over-rejected distinction is stated once in the skill, and only on the write side, at `SKILL.md:65-67`:

  ```markdown
  items where a strictly simpler implementation satisfies the same evidence get the simpler implementation recorded as
  the decision and the larger version under `Rejected alternatives:`
  ```

- **Raised by:** `structural-analyst` S-7, `behavioral-analyst` B-3.
- **Confidence:** Verified against the files. `Unverified` on one point both specialists named: whether a specialist in
  the reported run actually cited a rejected alternative as a commitment cannot be confirmed from this repository,
  because the transcript is not here. The structural gap that would allow it is confirmed.
- **Bears on:** S-6. [D-6](change-decision-log.md#d-6-pin-citation-to-the-field-not-the-decision-entry)

### C-6: The merge pass runs before the disputed test, so competing readings of one identifier can collapse into one row

- **Claim:** Pass A merges findings by substance first, by explicit instruction. Three specialists citing one `D-N`
  with two different figures are, by substance, one finding about that `D-N`, so the merge can absorb the disagreement
  before the ledger state that forces settlement is ever assigned.
- **Location:** `han-planning/skills/plan-implementation/SKILL.md:256-260`;
  `han-planning/skills/plan-implementation/references/round-aggregation.md:6-17,56-59`.
- **Evidence:**

  ```markdown
  Three passes run first, in this order. The order matters: merging before the other two is what stops one finding from
  ending up unverified under one specialist's identifier and blocking under another's.

  **Pass A: merge by substance.** Two specialists often raise the same finding in different words. Merge those into one
  record carrying every originating specialist's own identifier (for example `SEC-2, OCE-5`).
  ```

  `Disputed` is defined only as two or more specialists making conflicting claims on the same point, and the
  consolidation rule gives no test separating "same claim, different figure" from "same claim". The `Evidenced` state
  is satisfied by the shape of a citation rather than its content:

  ```markdown
  - `Evidenced` — the finding cites a file path with line number, an ADR ID, a coding-standard section, or another
    concrete artifact that resolves the claim.
  ```

- **Raised by:** `behavioral-analyst` B-3, `behavioral-analyst` B-4.
- **Confidence:** Verified against the files. The failure is silent when it occurs: a merged row looks well-supported
  because it carries three specialist identifiers.
- **Bears on:** S-7, S-8. [D-7](change-decision-log.md#d-7-two-findings-citing-one-identifier-with-different-figures-do-not-merge)

### C-7: The only step that opens a citation and checks it runs after the round has already spent the dispute

- **Claim:** Citation verification exists exactly once in the chain, inside the synthesizer dispatched at Step 8. By
  then the round entry is on disk, the Open Question is closed, and any user escalation has already happened.
- **Location:** `han-core/agents/plan-synthesizer.md:172-179`;
  `han-planning/skills/plan-implementation/references/synthesis-directives.md:10-12`.
- **Evidence:**

  ```markdown
  For each claim, verify the citation actually resolves and supports the claim (a URL that 404s, a file that doesn't
  contain the line cited, or a metric from an unrelated system is not evidence).
  ```

  The synthesizer receives the aggregated round entries alongside the verbatim specialist output, so a merged or
  mis-attributed ledger row arrives as a settled record rather than as a claim to test.

  The skill does contain the pattern this is missing, applied to visual material at `SKILL.md:275`: `open the material
  and check the finding against it`. There is no equivalent pass for a cited `D#`.

- **Raised by:** `behavioral-analyst` B-6.
- **Confidence:** Verified against the files.
- **Bears on:** S-7, S-8. [D-7](change-decision-log.md#d-7-two-findings-citing-one-identifier-with-different-figures-do-not-merge)

### C-8: No participant in a round holds a tool that can measure

- **Claim:** Every round specialist holds read-only tools. The orchestrator is broader but still cannot run an
  arbitrary command, so the issue's premise that "the orchestrating thread does have execution tools" is only
  partly true: it holds `find`, `git`, `mkdir`, `cp`, and one named script, and holds no general execution.
- **Location:** `han-core/agents/*.md` frontmatter; `han-planning/skills/plan-implementation/SKILL.md:12-14`;
  `han-planning/skills/plan-a-change/SKILL.md:12-14`; `han-planning/skills/plan-a-feature/SKILL.md:12-14`.
- **Evidence:**

  Representative specialist grants, verbatim from frontmatter:

  ```
  han-core/agents/behavioral-analyst.md:11:tools: Read, Glob, Grep, Bash(git *), Bash(find *)
  han-core/agents/concurrency-analyst.md:10:tools: Read, Glob, Grep, Bash(find *)
  han-core/agents/system-architect.md:11:tools: Read, Glob, Grep, Bash(find *)
  han-core/agents/plan-synthesizer.md:11:tools: Read, Glob, Grep, Bash(git *), Bash(find *), Write
  ```

  The three planning orchestrators, and they do not agree with each other:

  ```yaml
  # plan-implementation
  allowed-tools:
    Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(git *), Bash(mkdir *), Bash(cp *),
    Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")

  # plan-a-change            (no Bash(cp *))
  allowed-tools:
    Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(git *), Bash(mkdir *),
    Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")

  # plan-a-feature           (no Bash(git *))
  allowed-tools:
    Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(mkdir *), Bash(cp *),
    Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
  ```

  No `wc`, no `jq`, no test runner, no build, in any of the three.

- **Raised by:** `behavioral-analyst` B-1, `behavioral-analyst` B-2, and my own verification.
- **Confidence:** Verified. I read all three `allowed-tools` blocks directly. This finding contradicts a premise stated
  in the work item, so it is the one finding here that changes what a fix for the issue's first item can be.
- **Bears on:** S-12, S-13. [D-11](change-decision-log.md#d-11-measure-within-the-current-tool-grant-and-record-what-the-grant-cannot-reach), and the deferred shell-grant entry

### C-9: The round brief has no field a measured value could occupy

- **Claim:** Every input `team-selection.md` lists for a brief is a path, a directive, or a spec excerpt. The one
  orchestrator-produced input is the Step 2 discovery notes, whose schema is a search inventory rather than a set of
  measurements. No step between Step 2 and Step 4 runs anything whose output becomes a brief field.
- **Location:** `han-planning/skills/plan-implementation/SKILL.md:201-225` (Step 2), `SKILL.md:236-243` (Step 4);
  `han-planning/skills/plan-implementation/references/team-selection.md:99-164`.
- **Evidence:**

  The discovery notes schema, fixed at Step 2:

  ```markdown
  **Write the result to `{same-folder-as-source}/artifacts/.discovery-notes.md`** as a structured summary: tech stack,
  ADRs found (paths + one-line summary each), coding standards found (paths + one-line summary each), code touch points
  (paths + one-line summary), recent-activity churn, and explicitly enumerated gaps (what was searched for and not found).
  ```

  Nothing in the skill instructs anyone to check a figure the input specification asserts before passing it on. A
  number in the spec enters the brief as an assertion and reaches the specialist as an assertion.

- **Raised by:** `behavioral-analyst` B-1.
- **Confidence:** Verified against the files.
- **Bears on:** S-12, S-13. [D-11](change-decision-log.md#d-11-measure-within-the-current-tool-grant-and-record-what-the-grant-cannot-reach)

### C-10: The `Unverified` label has no transition out of it

- **Claim:** Pass B assigns `Unverified` to a finding resting on an uninspected input and invites the orchestrator to
  verify it without requiring anything. No later step re-runs the pass, no field records whether verification was
  attempted, and Step 9 reports the label forward as terminal.
- **Location:** `han-planning/skills/plan-implementation/SKILL.md:262-272,476-477`.
- **Evidence:**

  ```markdown
  Keep the finding: it may be real, and you can often verify it yourself. What
  it cannot do is reach the user looking like a blocker on the strength of something nobody read.
  ```

  "you can often verify it yourself" is permission, not a step. Step 9 then reports the label as a settled outcome:

  ```markdown
  Any finding that stayed `Unverified` because a specialist could not inspect its input, and any evidence class no
  specialist could audit.
  ```

- **Raised by:** `behavioral-analyst` B-13.
- **Confidence:** Verified against the file. Read together with C-8, the label attaches to exactly the class of finding
  that needed a tool nobody in the run holds.
- **Bears on:** S-14. [D-12](change-decision-log.md#d-12-a-downgraded-finding-records-whether-anyone-tried-to-verify-it)

### C-11: The readability editor's report is consumed as fact, and both anticipated shapes are no-ops

- **Claim:** The rewrite is applied to the file before the report is read, the dispatching skill is explicitly
  forbidden from checking the editor's output, and both report shapes it anticipates require no action. A report that
  is present, well-formed, and wrong routes to the first shape and stops there.
- **Location:** `han-planning/skills/plan-implementation/SKILL.md:396-424` (Step 8.5);
  `han-planning/skills/plan-a-change/SKILL.md` Step 9.5; `han-planning/skills/plan-a-feature/SKILL.md` Step 8.5.
- **Evidence:**

  ```markdown
  The editor's report has two shapes, and neither is a loss you have to repair:

  - It confirms every claim, quantity, named entity, and stated condition survives. Nothing further is needed.
  - It names a fact it kept in the original wording to satisfy fidelity. Leave that wording alone rather than re-editing
    it.
  ```

  The third branch fires on absence only: `the editor could not be reached, returned nothing, or returned something you
  cannot read as either of those two shapes`. And the dispatcher is told not to look:

  ```markdown
  **Do not walk the self-check over the text the editor produced.**
  ```

  All three planning skills carry the same three branches with the same gap.

- **Raised by:** `behavioral-analyst` B-10.
- **Confidence:** Verified against the three skill files.
- **Bears on:** S-11, S-22. [D-1](change-decision-log.md#d-1-widen-the-boundary-to-the-fourth-carrier-of-the-editor-consumption-block), [D-10](change-decision-log.md#d-10-an-unsupported-insertion-is-reported-not-reverted), [D-21](change-decision-log.md#d-21-reword-the-three-existing-report-branches-in-all-four-skills)

### C-12: The editor has a sanctioned path to write new text, and its recent self-check covers vocabulary only

- **Claim:** Criterion 5 authorizes the editor to insert an explanation for a term the reader cannot look up. The
  bound on that insertion is a judgment the editor grades itself on. The step added by commit `6327462` checks a
  blocklist and em-dash positions, not whether an inserted sentence asserts something the draft never carried, and the
  fact-preservation ledger is produced by the same pass that produced the text.
- **Location:** `han-communication/agents/readability-editor.md:117-125,144-155,174-176`.
- **Evidence:**

  The sanctioned addition path:

  ```markdown
  Keep domain terms the reader genuinely needs, and give each one a half-sentence explanation at first use when the
  reader cannot look it up: an outside technology or language runtime, a named statistical or numerical method, or a
  compound noun the draft coined for its own convenience. ... Write the explanation from what the draft already says;
  adding one is making the draft's own term readable, not adding a fact.
  ```

  The step commit `6327462` added, which says in its own text what it covers:

  ```markdown
  4. Then re-read every sentence you rewrote or inserted, and check it against criterion 5's vocabulary blocklist and the
     voice profile's em-dash positions. Correct anything you introduced. This is a lookup against a fixed list, not a
     judgment about whether your rewrite reads well
  ```

  Step 3, the only fidelity step, checks one direction only: that source facts survived, never that no new ones
  appeared.

- **Raised by:** `behavioral-analyst` B-11.
- **Confidence:** Verified. I read commit `6327462` in full and the current agent file. The commit closes the
  fresh-voice-violation path and leaves both paths issue #193 reported open.
- **Bears on:** S-9, S-10. [D-8](change-decision-log.md#d-8-the-editor-reports-what-it-inserted-with-the-source-span-it-drew-from), [D-9](change-decision-log.md#d-9-the-fact-preservation-ledger-stops-asserting-that-everything-survived)

### C-13: The synthesis input list is one sentence split across a file boundary, in two skills, from two commits

- **Claim:** Step 8's input list in `plan-implementation/SKILL.md` ends mid-sentence, and the reference file it
  delegates to opens mid-sentence with the missing tail. `plan-a-feature/SKILL.md` carries the identical defect from a
  different commit. Neither file, read alone, states a complete input list.
- **Location:** `han-planning/skills/plan-implementation/SKILL.md:388-394` and
  `han-planning/skills/plan-implementation/references/synthesis-directives.md:1-10`;
  `han-planning/skills/plan-a-feature/SKILL.md:395-403` and
  `han-planning/skills/plan-a-feature/references/artifact-invariants.md:38-39`.
- **Evidence:**

  `plan-implementation/SKILL.md`, verbatim:

  ```markdown
  - The feature specification path (or a note that no source file was provided and what conversational context was used
    Ask the han-core:plan-synthesizer to reconcile the specialist input against the files and apply any remaining
    corrections directly.
  ```

  `synthesis-directives.md`, its first content line after the header:

  ```markdown
  Step 8 hands these to the agent; it does not restate them.

  instead), plus the spec's `artifacts/decision-log.md`, `artifacts/team-findings.md`, and
  `artifacts/feature-technical-notes.md` paths if they exist (falling back to the spec folder root for legacy layouts).
  ```

  `plan-a-feature/SKILL.md`, with the orphaned tail of `artifact-invariants.md:38-39`:

  ```markdown
  - Preserve the cross-reference invariants across all files, and classify every decision as full or trivial in
    this one pass. Both are specified in [artifact-invariants.md](./references/artifact-invariants.md); read it
    before synthesizing.
    an inline embed beside the prose describing each state.
  ```

- **Raised by:** `structural-analyst` S-4, `structural-analyst` S-5, `behavioral-analyst` B-9.
- **Confidence:** Verified. I read both passages directly and dated each with `git log -S`. The
  `plan-implementation` break entered in `61708bb`, "refactor(plan-implementation): bring the skill body under the
  500-line ceiling". The `plan-a-feature` break entered in `0e9f38c`, "feat(plan-a-feature): bound the run, keep the
  designs, ask one question at a time". Both commits moved SKILL.md body text into a reference file under a size
  constraint.
- **Bears on:** S-17, S-18. [D-15](change-decision-log.md#d-15-restore-both-truncated-sentences-and-add-a-move-unit-rule-to-the-guidance), [D-23](change-decision-log.md#d-23-widen-the-boundary-a-second-time-for-the-guidance-file-and-one-sibling-link)

### C-14: Five reference files carry link labels one directory shallower than their targets

- **Claim:** Reference files link to the shared rules with a visible label at `../../references/` and a target at
  `../../../references/`. The target is correct from a `skills/{name}/references/` file; the label is the depth
  correct from `SKILL.md`, and resolves to a directory that does not exist.
- **Location:** `han-planning/skills/plan-implementation/references/team-selection.md:32,73,134`;
  `han-planning/skills/plan-implementation/references/yagni-scope-sweep.md:7,27`;
  `han-planning/skills/plan-a-feature/references/finding-resolution.md:54,64`;
  `han-planning/skills/plan-a-feature/references/feature-specification-template.md:221,251`;
  `han-planning/skills/iterative-plan-review/references/team-selection.md:59`.
- **Evidence:**

  ```markdown
  - A directive to apply the YAGNI rule from [../../references/yagni-rule.md](../../../references/yagni-rule.md) to every
  ```

  `han-planning/skills/references/` does not exist. `plan-a-change`'s own `team-selection.md:` writes the same link
  with label and target agreeing, so the correct form is already present in the repository.

- **Raised by:** `structural-analyst` S-15.
- **Confidence:** Verified. I reproduced the full list myself with a grep for the label-target mismatch pattern across
  `han-planning/skills/`; ten occurrences across the five files above.
- **Bears on:** S-21. [D-16](change-decision-log.md#trivial-decisions), [D-23](change-decision-log.md#d-23-widen-the-boundary-a-second-time-for-the-guidance-file-and-one-sibling-link)

### C-15: The round cap is stated as four in the template and as one, two, or three in the two files that own it

- **Claim:** `implementation-iteration-history-template.md` states a four-round cap twice and cites the skill's Step 6
  as its source. Step 6 and `team-selection.md` both state a size-banded cap of one, two, or three.
- **Location:** `han-planning/skills/plan-implementation/references/implementation-iteration-history-template.md:13-16,63`;
  `han-planning/skills/plan-implementation/SKILL.md:352`;
  `han-planning/skills/plan-implementation/references/team-selection.md:22,24,26`.
- **Evidence:**

  The template, which points at the file that contradicts it:

  ```markdown
  The iteration loop is capped at four rounds (see the plan-implementation skill's
  Step 6).
  ```

  ```markdown
  <!-- Add more rounds as needed (R3, R4). The iteration loop caps at four rounds. -->
  ```

  Step 6:

  ```markdown
  The round cap from Step 3 sets the upper bound: small = 1 round, medium = 2 rounds, large = 3 rounds. Never exceed the
  ```

  `team-selection.md` agrees with Step 6: `Round cap: **1.**`, `Round cap: **2.**`, `Round cap: **3.**`.

- **Raised by:** `structural-analyst` S-10.
- **Confidence:** Verified. I grepped all three files myself and confirmed the three statements. A prior commit subject
  in the repository, "feat(han-planning): count review teams in specialists and fix the stale round range", shows this
  drift has already recurred once.
- **Bears on:** S-20. [D-17](change-decision-log.md#d-17-remove-the-round-cap-number-from-the-template-rather-than-correcting-it)

### C-16: The deferral entry format has three owners with three incompatible `Source:` definitions

- **Claim:** The canonical rule, the synthesizer agent, and the plan template each define the deferral entry's fields.
  All three use the same three field names and define `Source:` differently, and two of the three are active in a
  single `plan-implementation` run.
- **Location:** `han-core/references/yagni-rule.md:121-132` (the canonical copy);
  `han-core/agents/plan-synthesizer.md:398-405`;
  `han-planning/skills/plan-implementation/references/feature-implementation-plan-template.md:123-134`.
- **Evidence:**

  The canonical rule declares itself the owner, with `Source: {where the item was originally proposed — review finding
  ID, agent name, conversation context}`. The synthesizer carries its own:

  ```markdown
  - **Source:** {which specialist or discussion thread proposed the item, plus the larger version's rejected-alternative entry on the related D-N decision}
  ```

  The plan template carries a third:

  ```markdown
  - **Why deferred:** {gate failure; named anti-pattern when applicable}
  - **Reopen when:** {concrete trigger}
  - **Source:** {R#, specialist name}
  ```

  Only the synthesizer's version requires a back-link to a rejected-alternative entry.

- **Raised by:** `structural-analyst` S-8, with an attribution corrected by `system-architect` SA5.
- **Confidence:** Verified, with one correction. `structural-analyst` cited
  `han-planning/references/yagni-rule.md` as the canonical definition. It is a vendored copy.
  `CLAUDE.md:97` names `han-core/references/` as holding the canonical copies, and `CLAUDE.md:120` lists
  `yagni-rule.md` among `han-planning/references/`'s vendored files rather than its owned ones. I confirmed all six
  copies are byte-identical: `md5 -q han-{coding,core,ddd,documentation,planning,research}/references/yagni-rule.md`
  returns `1975652f7fb99aeee82b19bc3da5475b` six times.

  The correction matters beyond bookkeeping. Two of the three competing definitions ship inside `han-core` and version
  together, so only the third crosses a plugin boundary. And a specialist reading these files carefully still
  attributed ownership to the wrong copy, which is a finding in its own right: six byte-identical files carry no
  in-file marker saying which one is the owner.
- **Bears on:** No delta entry. Deferred, per [D-19](change-decision-log.md#d-19-defer-the-deferral-entry-layout-rather-than-pinning-it-here)

### C-17: `Definition of Done` exists in one template and is read by nothing

- **Claim:** The plan's acceptance criteria section is defined in `plan-implementation`'s plan template, named once in
  the write order, and read by no downstream skill. Neither sibling plan template has an equivalent section.
- **Location:** `han-planning/skills/plan-implementation/references/feature-implementation-plan-template.md:61-66`;
  `han-planning/skills/plan-implementation/references/synthesis-directives.md:39`;
  `han-planning/skills/plan-a-change/references/change-plan-template.md`;
  `han-planning/skills/plan-a-feature/references/feature-specification-template.md`.
- **Evidence:**

  ```markdown
  ## Definition of Done

  <!-- Testable and unambiguous. Cite the decisions a criterion satisfies. -->

  - [ ] <!-- Behavior X is observable when action Y occurs -->
  - [ ] <!-- Tests cover ([D-1](artifacts/implementation-decision-log.md#d-1-...)) -->
  ```

  `plan-work-items` and `plan-a-phased-build` never mention it. `plan-synthesizer` has a differently-named section of
  its own, `## Scope, Definition of Done, Smallest Viable Slice`, belonging to the single-file `synthesized-plan.md`
  template this skill does not use.

- **Raised by:** `structural-analyst` S-9.
- **Confidence:** Verified. I confirmed with a repo-wide grep that `## Definition of Done` as a plan-document section
  appears in exactly one template. This finding is load-bearing for issue #193's third item, which proposes the fix
  live in the Definition of Done: the section exists in one of the three skills in scope, and nothing reads it there.
- **Bears on:** S-16. [D-14](change-decision-log.md#d-14-seed-a-definition-of-done-criterion-and-name-its-only-reader-plainly)

### C-18: `## Cut for Scope` is required by one invariant and missing from the write order in the same file

- **Claim:** `synthesis-directives.md` enumerates the plan's sections in write order and enumerates the lazy ones, and
  `## Cut for Scope` appears in neither list. The same file's invariant 5 requires the section.
- **Location:** `han-planning/skills/plan-implementation/references/synthesis-directives.md:37-49,85-86`;
  `han-planning/skills/plan-implementation/references/feature-implementation-plan-template.md:106-116`.
- **Evidence:**

  The ordered write instruction:

  ```markdown
  order: a plain-language opening paragraph, Outcome, User Stories (when the feature has a describable actor benefit),
  Constraints and Boundaries, Implementation Approach, Work Units and Sequencing, Definition of Done, Testing
  Strategy, the lazy specialist sections, Open Items, Sources and Plan Records, and Recommendation.
  ```

  The invariant in the same file that requires what the order omits:

  ```markdown
  **`## Cut for Scope` carries every scope-gate cut** from Step 7.5's ledger, with what each would have done in plain
  language and the boundary citation, and no entry appears in both that section and `## Deferred (YAGNI)`.
  ```

  `SKILL.md:471-473` says the cut list must be shown to the user because "a cut the user never reads is a cut nobody
  can reverse".

- **Raised by:** `structural-analyst` S-11.
- **Confidence:** Verified against the file. `structural-analyst` labeled part of this `Unverified` because it did not
  read `scope-justification-rule.md` in full; that affects only whether the rule assigns the section a separate owner,
  not whether the two lists in `synthesis-directives.md` disagree, which they do.
- **Bears on:** S-2. [D-18](change-decision-log.md#trivial-decisions)

### C-19: The three sibling decision logs have diverged on field name, ID format, and classification timing

- **Claim:** `plan-implementation`, `plan-a-change`, and `plan-a-feature` each carry a near-parallel decision-log
  template with no shared owner. Four of the five differences are refinements one skill received and the others did
  not.
- **Location:** `han-planning/skills/plan-implementation/references/implementation-decision-log-template.md`;
  `han-planning/skills/plan-a-change/references/change-decision-log-template.md`;
  `han-planning/skills/plan-a-feature/references/decision-log-template.md`.
- **Evidence:**

  | Aspect | `plan-implementation` | `plan-a-change` | `plan-a-feature` |
  | ------ | --------------------- | --------------- | ---------------- |
  | Back-link field | `Referenced in plan:` | `Referenced in plan:` | `Referenced in spec:` |
  | ID format | `D-N` | `D-N` | `D#` / `D1` |
  | Classification timing | before it is recorded | before it is recorded | once, after the review round, during synthesis |
  | Full-decision signal | `at least one rejected alternative;` | `at least one rejected alternative;` | plus `a reasonable engineer would plausibly have chosen` |
  | Third-file link | `Driven by rounds:` / `Decisions produced:` | absent | absent |

  `plan-a-feature`'s deferred-classification rule states a reason the other two never answer: two of the promotion
  signals do not exist at draft time.

- **Raised by:** `structural-analyst` S-13.
- **Confidence:** Verified. I confirmed the `Referenced in plan` / `Referenced in spec` split with a repo-wide grep:
  `Referenced in plan` appears in `plan-implementation` and `plan-a-change` only.
- **Bears on:** No delta entry of its own. Cited as drift evidence by [D-5](change-decision-log.md#d-5-put-the-plan-existence-stop-in-both-file-writing-callers-worded-once) and deferred by [D-20](change-decision-log.md#d-20-do-not-unify-the-three-sibling-decision-log-templates)

## Findings No Agent Could Audit

Two evidence classes nobody in this run could reach.

- **The run behind issue #193.** No transcript, plan folder, decision log, iteration history, or editor report from
  that run exists in this repository. Both specialists named this on their whole report, and it is why every finding
  above is grounded in the files as written rather than in observed behavior. Closing it would take the operator
  supplying the run's artifacts, which the issue does not attach. In practice this matters for exactly one claim: C-5,
  where the structural gap is confirmed but the specific misreading the issue reports is not independently
  reproducible.
- **Whether an instruction change alters a model's behavior.** No test in this repository asserts anything about a
  `SKILL.md` or a template, so a fix written as prose has no mechanical check behind it and no way to be shown to
  work short of running the skill. This is the gap that makes a script-backed gate worth more than a prose invariant
  wherever a fix can take that form. Closing it for a given fix means giving that fix an executable check with Bats
  tests beside it, which the repository already does three times over.
