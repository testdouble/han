# Current State Findings: Investigation Types

## Provenance

Produced by this run's own discovery round on 2026-11-12. No prior findings report existed.

- `han-core:structural-analyst` was briefed on `han-coding/skills/investigate/` (SKILL.md and `references/template.md`),
  the `code-review` type mechanism as precedent, and `han-atlassian/skills/investigate-to-confluence/`. Its findings
  are S1 to S6.
- `han-core:behavioral-analyst` was briefed on the same skill plus the agents it dispatches, the evidence and config
  rules, the Confluence wrapper, the evals, and the `research` description. Its findings are B1 to B12.
- `han-core:concurrency-analyst` was not dispatched: the area is Markdown prompt instructions with no shared mutable
  state.
- The run's own sweep covered CLAUDE.md, `docs/adr/`, the long-form doc, the cross-plugin docs, and git history.

## Project Context

- **Stack:** Markdown skill, agent, and doc content, plus Bash scripts with Bats tests. `npm test` runs every `*.bats`
  file; `npm run lint` runs Prettier, ShellCheck, and file-hygiene hooks.
- **Conventions source:** CLAUDE.md (`## Conventions`, `## Project Discovery`), and the authoring guidance under
  `han-plugin-builder/skills/guidance/references/`.
- **ADRs found:** `docs/adr/0001-project-configurable-default-swarm-size.md`, the one ADR. It does not bear on this
  change.
- **Coding standards found:** none as a standalone file. CLAUDE.md conventions govern: one canonical source per
  concept, every long-form doc links up, uniform voice, YAGNI for docs, and indexes stay complete.
- **Recent churn:** in the last 90 days, `investigate/SKILL.md` changed in 3 commits, and
  `investigate-to-confluence/SKILL.md` and `han-coding/docs/skills/investigate.md` in 1 each. All were cross-skill
  sweeps (config probe, readability standard, boundary docs), not investigate-specific redesigns. The most recent
  precedent is `code-review` review types, built from `docs/plans/code-review-types/`.

## Gaps

- No ADR or coding standard covers how a skill declares and parses typed arguments. The only precedent is
  `code-review`'s `## Review Types` section and its `review-types.bats` test.
- `investigate` has no Bats test, so no cross-file agreement in it is machine-checked today.
- No agent in the roster compares implementation options within a codebase. `research-analyst` covers the open web.
- No eval exercises a non-bug investigation, an explicit type, or the boundary with `research`.

## Findings

### C-1: The bug framing runs through every step of SKILL.md, with no seam

- **Claim:** The config read, evidence rule, lazy-create rule, E-series compilation, validator mechanics,
  readability-editor pass, and user review are type-agnostic. Everything else is phrased around a symptom, a root
  cause, and a fix.
- **Location:** `han-coding/skills/investigate/SKILL.md`: Approach bullets L30-34, Step 1 L62, Step 2 L92-104, Step 3
  L106-121, Step 4 L125-132, Step 5 L141-143.
- **Evidence:**
  ```
  - Trace backward from symptoms — don't guess, follow the code.
  Classify the bug from the user's symptom description before launching.
  ## Step 2: Document Root Cause
  ## Step 3: Plan the Fix
  Design a fix that **directly addresses the root cause** from Step 2
  ```
- **Raised by:** structural-analyst S1, behavioral-analyst B4
- **Confidence:** Verified
- **Bears on:** S-3, S-4, S-5

### C-2: The description sends "how something works" and "options" to `research`

- **Claim:** `investigate`'s description excludes both new types by name, and `research`'s description claims them.
- **Location:** `han-coding/skills/investigate/SKILL.md` L8-9; `han-research/skills/research/SKILL.md` L3-6.
- **Evidence:**
  ```
  Does not research open-ended options, prior art, or how something works when nothing is broken — use research for that.
  ```
  ```
  Researches an open-ended question — options, possible solutions, prior art, trade-offs, or how something works
  ```
- **Raised by:** structural-analyst S1, behavioral-analyst B4 and B10
- **Confidence:** Verified
- **Bears on:** S-1, S-10

### C-3: The argument is one free-text blob with no parsing rule

- **Claim:** There is no `arguments:` key and no first-token rule. The output path is separated from the symptom by the
  model's judgment alone.
- **Location:** `han-coding/skills/investigate/SKILL.md` L12.
- **Evidence:**
  ```
  argument-hint: "[symptom or problem description, and optionally an output path]"
  ```
- **Raised by:** behavioral-analyst B1
- **Confidence:** Verified
- **Bears on:** S-2

### C-4: The output file's location and name are never specified, and `Write` is not in `allowed-tools`

- **Claim:** "The plan file" is referenced four times with no antecedent. `allowed-tools` has no `Write`, `Edit`, or
  `Skill`, though the skill writes a file and invokes `readability-guidance`. `code-overview`, a sibling that writes a
  file, lists `Write`.
- **Location:** `han-coding/skills/investigate/SKILL.md` L13, L43, L94, L114, L141.
- **Evidence:**
  ```
  allowed-tools: Read, Glob, Grep, Agent, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
  ```
  ```
  Write to the plan file using the template at [template.md](./references/template.md).
  ```
- **Raised by:** behavioral-analyst B2
- **Confidence:** Verified
- **Bears on:** S-2, S-9

### C-5: One template, with shared carriers and bug-only sections

- **Claim:** The Evidence Summary (E-N), Validation Results (V-N), Adjustments Made, and Confidence Assessment are
  generic, about 70 lines. The title, Summary fields, Problem Statement, Root Cause Analysis, and Planned Fix are
  bug-only. Coding Standards Reference is tied to "the fix".
- **Location:** `han-coding/skills/investigate/references/template.md` L1, L15-19, L21-64 (bug-only), L66-133 (generic),
  L135-141.
- **Evidence:**
  ```
  # Investigation: {Issue Title}
  - **Root Cause:** <!-- What caused the problem -->
  - **Fix:** <!-- What the planned changes will do -->
  - **Why Correct:** <!-- Reference the strongest evidence supporting the fix -->
  ```
- **Raised by:** structural-analyst S2, behavioral-analyst B4
- **Confidence:** Verified
- **Bears on:** S-6, S-7

### C-6: The specialist roster, its triggers, and its prompts are inline and symptom-keyed

- **Claim:** At least two `evidence-based-investigator` agents always run. Three specialists join on symptom triggers,
  each with an inline prompt containing `{symptom}`. `## Extra Agents` joins "under the same symptom-driven selection".
  There is no separate dispatch file.
- **Location:** `han-coding/skills/investigate/SKILL.md` L55-90.
- **Evidence:**
  ```
  Extra agents named in the project config's `## Extra Agents` list join this conditional-specialist pool under the same
  symptom-driven selection ... dispatch one only when the classified bug type matches its stated specialty
  ```
- **Raised by:** structural-analyst S3, behavioral-analyst B5 and B7
- **Confidence:** Verified
- **Bears on:** S-4

### C-7: `evidence-based-investigator` is bug-framed; `codebase-explorer` and `behavioral-analyst` are neutral

- **Claim:** `evidence-based-investigator` describes itself as for "a bug, failure, or unexpected behavior" and runs
  five fixed, symptom-first protocols. `codebase-explorer` is built "for documentation or understanding" but runs on
  haiku with no git access. `behavioral-analyst` takes a focus area, not a symptom.
- **Location:** `han-core/agents/evidence-based-investigator.md` L3-5; `han-core/agents/codebase-explorer.md` L3-7;
  `han-core/agents/behavioral-analyst.md` L3-10.
- **Evidence:**
  ```
  Use when thorough, multi-angle research into a bug, failure, or unexpected behavior is needed.
  ```
  ```
  Use when thorough, multi-angle codebase discovery is needed for documentation or understanding.
  tools: Read, Glob, Grep, Bash(find *)
  model: haiku
  ```
- **Raised by:** behavioral-analyst B5
- **Confidence:** Verified for the descriptions. Unverified for how each agent behaves when briefed off-type; nobody
  ran one.
- **Bears on:** S-4

### C-8: `adversarial-validator` requires a planned fix and mandates challenging it

- **Claim:** The validator expects three inputs and must run strategies 1-3 on every run. Strategy 2 attacks a fix, so
  a how-it-works run gives it nothing to attack. Strategies 1 and 4 apply to any evidence set.
- **Location:** `han-core/agents/adversarial-validator.md` L13, L40-58.
- **Evidence:**
  ```
  You will receive an evidence summary, root cause analysis, and planned fix. Attack all three.
  You MUST attempt strategies 1-3 on every run.
  ### 2. Challenge the Fix
  ```
- **Raised by:** behavioral-analyst B6
- **Confidence:** Verified
- **Bears on:** S-5, S-11

### C-9: The `code-review` type pattern, and what does not transfer

- **Claim:** `code-review` keeps the only list of type tokens in a `## Review Types` table, one data file per type under
  `references/types/` with a fixed section contract, and a Bats test that holds the table, the files, and the
  argument-hints in agreement. Its default run (a union of types), config-declared types, retired size words, and the
  rule that a typed run never names another type do not fit `investigate`, which must resolve to exactly one type and
  must suggest an alternative.
- **Location:** `han-coding/skills/code-review/SKILL.md` L96-153; `han-coding/skills/code-review/scripts/review-types.bats`.
- **Evidence:**
  ```
  A review type names the one concern a run covers. Each shipped type is a data file under `references/types/`, and this
  table is the only list of shipped type tokens:
  ```
- **Raised by:** structural-analyst S4
- **Confidence:** Verified for the contract and test. Unverified for code-review Steps 2-10, which were not read.
- **Bears on:** S-3, S-12

### C-10: The type classification is held only in context, with no announcement or tie-break

- **Claim:** Today's bug classification is held in the model's context and never written out. Nothing covers an
  ambiguous prompt, and there is no ask-the-user step.
- **Location:** `han-coding/skills/investigate/SKILL.md` L62, L85.
- **Evidence:**
  ```
  Classify the bug from the user's symptom description before launching.
  ```
- **Raised by:** behavioral-analyst B11 and B12
- **Confidence:** Verified
- **Bears on:** S-2

### C-11: The stop point says approval triggers implementation, but nothing implements

- **Claim:** Step 5 ends with approval "triggering implementation". The Confluence wrapper has to tell `investigate`
  not to implement. No mechanism in the skill implements anything.
- **Location:** `han-coding/skills/investigate/SKILL.md` L163; `han-atlassian/skills/investigate-to-confluence/SKILL.md`
  L79-81.
- **Evidence:**
  ```
  Present the plan file to the user for approval. The user can approve the plan (triggering implementation) or provide
  feedback for revisions.
  ```
- **Raised by:** behavioral-analyst B3 and B8
- **Confidence:** Verified
- **Bears on:** S-8

### C-12: `investigate-to-confluence` restates the bug-only shape and rejects non-bug requests

- **Claim:** The wrapper forwards the user's text verbatim and captures the path written, but it does not parse
  headings. It restates today's section list, and its Step 1 checks that the request names "a bug, failure, error,
  integration, or unexpected behavior".
- **Location:** `han-atlassian/skills/investigate-to-confluence/SKILL.md` L4-7, L37-39, L57-58, L83.
- **Evidence:**
  ```
  `han-coding:investigate` produces a **single** report file (the investigation plan: problem statement, evidence
  summary, root cause analysis, planned fix, validation results, and summary)
  ```
- **Raised by:** structural-analyst S5, behavioral-analyst B8
- **Confidence:** Verified
- **Bears on:** S-11

### C-13: Evals assert "Root Cause" and cover only bug triggering

- **Claim:** Four evals. One asserts the result contains "Root Cause" on a bug prompt, one asserts its absence on a
  no-op. None covers a non-bug type, an explicit type, a mismatched type, or the `research` boundary.
- **Location:** `evals/investigate/tests.json` L5-42.
- **Evidence:**
  ```
  { "result-contains": "Root Cause" },
  ```
- **Raised by:** structural-analyst S6, behavioral-analyst B9
- **Confidence:** Verified for the assertions. Unverified for the scaffold's contents.
- **Bears on:** S-13

### C-14: Other surfaces describe `investigate` as bug-only

- **Claim:** The long-form doc, the `han-coding` README scent line, the skills index, `docs/workflows.md`, the how-to
  guides, the `research` long-form doc, and the Confluence wrapper's doc all describe `investigate` as bug-only. The
  descriptions of `code-overview` and `code-walkthrough` route "diagnose bugs" to `investigate` and claim explaining
  code for themselves.
- **Location:** `han-coding/docs/skills/investigate.md` L13-17 and L55-56; `han-research/docs/skills/research.md` L24,
  L79, L238; `docs/skills/README.md` L54-56; `han-coding/README.md` L31;
  `docs/how-to/research-a-decision.md` L11; `han-coding/skills/code-overview/SKILL.md` L11.
- **Evidence:**
  ```
  - **Open-ended research.** Use [`/research`](...) when nothing is broken and you want options, prior
    art, or how something works before committing to a direction.
  ```
  ```
  - **Question-shaped, not symptom-shaped.** `/investigate` starts from something broken and ends at a fix.
  ```
- **Raised by:** structural-analyst S6; run's own sweep
- **Confidence:** Verified
- **Bears on:** S-10, S-14

### C-15: Web evidence is referenced but unreachable

- **Claim:** The evidence rule section of SKILL.md talks about web-source context, but neither the skill nor
  `evidence-based-investigator` has a web tool. Web context only arrives if the user pastes it.
- **Location:** `han-coding/skills/investigate/SKILL.md` L13, L38-42.
- **Evidence:**
  ```
  Web-source context (RFCs, vendor docs, Stack Overflow, blog posts) carries the trust-class label "web"
  ```
- **Raised by:** behavioral-analyst B10
- **Confidence:** Verified
- **Bears on:** S-4, S-10

## Findings No Agent Could Audit

- Whether an LLM actually classifies a given prompt into the intended type. Only an eval run closes this; nobody ran the
  evals.
- How `evidence-based-investigator`, `behavioral-analyst`, and `codebase-explorer` behave when briefed on a non-bug
  question. Closing this takes a trial run of each type after the build.
