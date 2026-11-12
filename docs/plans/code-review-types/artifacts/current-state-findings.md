# Current State Findings: Code Review Types

## Provenance

Produced by this run's own discovery round on 2026-10-14. `han-core:structural-analyst` (S-series) and
`han-core:behavioral-analyst` (B-series) were dispatched over `han-coding/skills/code-review/`,
`han-github/skills/post-code-review-to-pr/SKILL.md`, the `default-swarm-size` contract in
`han-core/references/config-rule.md`, and the code-review sizing docs. `han-core:concurrency-analyst` was not dispatched:
the area is Markdown instructions and one Bash script with no shared mutable state of its own (the parallel-run
collision in C-13 is a file-naming fact, recorded from the behavioral round). Both agents' originating IDs are carried on
each merged finding. The run's own sweep added C-20 to C-22; C-23 and C-24 were added after the review round and the operator's scope addition.

Abbreviations: `SK` = `han-coding/skills/code-review/SKILL.md`; `AD` =
`han-coding/skills/code-review/references/agent-dispatch.md`.

## Project Context

- **Stack:** Markdown skill, agent, and doc content; Bash for skill `scripts/`. Dev tooling via npm (prek, Prettier,
  ShellCheck, Bats). `npm test` runs Bats; `npm run lint` runs prek.
- **Conventions source:** `CLAUDE.md` (`## Project Discovery`, `## Conventions`). New skill assets must follow
  `han-plugin-builder/skills/guidance/` (CLAUDE.md, "Creating skills, agents, or other plugin aspects").
- **ADRs found:** `docs/adr/0001-project-configurable-default-swarm-size.md`: adopts `default-swarm-size` for "the eight
  sizing-aware skills", code-review among them.
- **Coding standards found:** none (`docs/coding-standards/` does not exist).
- **Recent churn:** 28 commits touched `han-coding/skills/code-review/` in the last 90 days; `SKILL.md` changed in 21 of
  them, `post-code-review-to-pr/SKILL.md` in 9. Most recent: `36db3f9 code-review: dispatch observability-engineer for
  telemetry design changes`, which added an eleventh roster agent across five per-agent tables (see C-9). The skill is
  under active, frequent change.

## Gaps

- No coding standard governs skill-reference layout or argument grammar.
- No ADR records the code-review roster design or the size-to-roster relationship.
- No Bats or harness test covers the `$size` binding, argument parsing, or the report contract post-code-review-to-pr
  reads (S-16, B-14).
- No existing agent is named for "verify implementation resolves a ticket"; `han-core:gap-analyzer` exists and fits (C-20).

## Findings

### C-1: Size has three producers resolved in prose, and one declared authority

- **Claim:** `{size}` comes from the `$size` positional, then `default-swarm-size`, then file-count signals defaulting to
  small; Step 3.1 declares itself the single authoritative source.
- **Location:** `SK:11-12`, `SK:200-227`
- **Evidence:**
  ```
  arguments: size
  argument-hint: "[size: small | medium | large | dynamic] [optional context about changes or areas to focus on]"
  ```
  ```
  **This step is the authoritative source for `{size}`.** Every later consumer reads `{size}` from here: the Review
  Constraints rule above, the Step 3.3 calibration directive, the Step 3.5 agent prompts, the Step 7.2 demotion gate, and
  the rubric in `references/agent-finding-classification.md`. Do not re-derive size at any of those sites.
  ```
- **Raised by:** S-1, B-1
- **Confidence:** Verified
- **Bears on:** —

### C-2: Size does not change which agents run; it only changes severity calibration

- **Claim:** Agent selection in Step 3.2 is purely signal-based with a fixed always-dispatched pair "across all sizes".
  Size's only effect is which severities survive (Small omits Suggestions, Medium conditionally, Large all). The docs'
  claim that "Larger sizes raise the upper bound on the roster" is not implemented.
- **Location:** `AD:14-48`, `AD:79-85`; `han-coding/docs/skills/code-review.md:48-49`
- **Evidence:**
  ```
  **Always dispatch — minimum roster across all sizes:**
  ```
  ```
  > - **Small change**: only Critical findings escalate. Raise Warnings only when the finding is directly introduced by
  >   this change. Omit Suggestions entirely.
  > - **Medium change**: Critical and Warning findings escalate. Raise Suggestions only when directly introduced by this
  >   change.
  > - **Large change**: all severities are in scope.
  ```
- **Raised by:** B-2, S-3
- **Confidence:** Verified
- **Bears on:** —

### C-3: The severity ladder is restated in three places, and manual vs. agent rules disagree at Large

- **Claim:** The band rule appears in the Review Constraints preamble, the Step 3.3 directive, and by pointer in the
  rubric. For Large, manual findings "prefer the higher severity when in doubt" while agent findings "prefer the
  **lower** severity".
- **Location:** `SK:44-48`, `AD:57-59`, `AD:87-88`, `references/agent-finding-classification.md:15-18`
- **Evidence:**
  ```
  Small changes escalate only Critical findings and default uncertain ones to the lower severity, Medium changes escalate
  Critical and Warning, Large changes prefer the higher severity when in doubt. Read `{size}` from Step 3.1.
  ```
  ```
  > When uncertain about severity, prefer the **lower** severity.
  ```
- **Raised by:** B-3, S-2, S-6
- **Confidence:** Verified
- **Bears on:** —

### C-4: The size-independent half of the calibration directive is reusable shared flow

- **Claim:** The "raise a finding only when" rule, the "do not raise" list (benign-outcome exclusions), "prefer the
  lower severity", and the YAGNI carve-out in Step 3.3 do not read size.
- **Location:** `AD:63-77`, `AD:87-96`
- **Evidence:**
  ```
  > Raise a finding only when **at least one** of these holds:
  >
  > 1. The change actively introduces or worsens the issue.
  > 2. The issue is critical irrespective of who introduced it — proven security exploit, data corruption, data isolation
  >    break, or data loss with no recovery.
  ```
- **Raised by:** S-3, B-16
- **Confidence:** Verified
- **Bears on:** —

### C-5: Full fan-out of size consumers

- **Claim:** Size is read at: Review Constraints (`SK:44-48`); YAGNI "regardless of size" phrasing (`SK:58-65`,
  `AD:93-94`, `references/review-checklist.md:22-24`); Mode B/C "treat the change as Small unless the user passed
  `$size`" (`SK:271`); Step 3.3 directive (`AD:60`, `AD:79-85`); placeholder note (`AD:155`); Step 7.3 "size-aware
  rubric" (`SK:370-375`, `references/finding-filters.md:4,32`); validator brief (`references/finding-filters.md:62`);
  manual-only sweep "at the `{size}` band" nine times (`AD:259-270`); Step 10 item 4 and closing note (`SK:483`,
  `SK:498`). `template.md` and `output-verification.md` carry no size reference. The Step 7.2 gate does not read size,
  so the Step 3.1 consumer list is stale on that point.
- **Location:** as listed
- **Evidence:**
  ```
  - The size-based demotion in Step 3.3 still applies, but treat the change as Small unless the user passed `$size`.
  ```
  ```
  4. **The run's own facts, last:** the size band and why, and the validator reconciliation line.
  ```
- **Raised by:** S-2 through S-10, B-2
- **Confidence:** Verified
- **Bears on:** —

### C-6: Size appears only in the closing chat message, never in the report file

- **Claim:** The report template has no size field; the band is named only in Step 10's message.
- **Location:** `SK:483`; `references/template.md`
- **Evidence:** (negative result: grep for size/band/Small/Medium/Large in `template.md` matched only severity labels)
- **Raised by:** B-2, S-10, B-14
- **Confidence:** Verified
- **Bears on:** —

### C-7: The first argument has no disambiguation rule

- **Claim:** One positional token is bound as `$size`; `$focus_areas` is "everything after the optional `$size`
  positional"; Mode C also reads arguments as file paths. What happens to a first token that is not a size is
  undefined. A type plus a ticket path adds a second positional with no binding.
- **Location:** `SK:11-12`, `SK:130-131`, `SK:137-139`, `SK:213-214`; `han-core/references/config-rule.md:62-63`
- **Evidence:**
  ```
  **Bind `$focus_areas`.** Read the user's free-form argument string from the invocation (everything after the optional
  `$size` positional). If non-empty, bind `$focus_areas` to that string verbatim.
  ```
  ```
  - If the user provided file paths, glob patterns, or directories as arguments, use those to build the file list (expand
    with Glob)
  ```
- **Raised by:** B-4, B-5, S-13
- **Confidence:** Unverified for the harness's exact binding of `arguments:` (host behavior, not in the repo); the
  skill's own prose was read.
- **Bears on:** —

### C-8: Step 1.5 is the only work-document intake today, and it does not fit a ticket to verify against

- **Claim:** Step 1.5 loads PR body, a local pr-body file, commit messages, and a branch-matched implementation plan,
  summarized into at most 200 words of `$branch_context`, extracting only "scope and intent". It is skipped in Mode C and
  fails open with a warning. A ticket is never read by name. Step 8.6 already names the report after a ticket
  identifier, though no step extracts one.
- **Location:** `SK:141-177`, `SK:447-450`
- **Evidence:**
  ```
  **Summarize loaded content into a Branch Context block of at most 200 words** covering: scope of the change, deferred
  items the team named, premises the team has already locked in, focus areas the author called out.
  ```
  ```
  - **The ticket**, when Step 1.5's branch context surfaced a ticket identifier the branch name does not already carry.
  ```
- **Raised by:** B-9, B-11, S-14
- **Confidence:** Verified
- **Bears on:** —

### C-9: Untrusted-content handling is explicit and reusable

- **Claim:** Loaded third-party content is treated as data, directives are dropped and noted, and agents receive it
  between fixed `BEGIN/END BRANCH CONTEXT (UNTRUSTED)` markers, substituted literally. The markers are not neutralized if
  the content contains the end-marker string.
- **Location:** `SK:163-169`, `AD:121-136`
- **Evidence:**
  ```
  > ----- BEGIN BRANCH CONTEXT (UNTRUSTED) ----- $branch_context ----- END BRANCH CONTEXT (UNTRUSTED) -----
  ```
- **Raised by:** B-9, S-14
- **Confidence:** Verified
- **Bears on:** —

### C-10: code-review cannot fetch a ticket URL today

- **Claim:** `allowed-tools` has `Read` and `Bash(gh *)` but no `WebFetch` and no MCP tool. Local ticket paths work;
  GitHub issue URLs work through `gh issue view`; Jira, Linear, and other trackers are unreachable from code-review
  itself.
- **Location:** `SK:13-15`
- **Evidence:**
  ```
  allowed-tools:
    Bash(git *), Bash(gh *), Bash(make *), Bash(npm *), Read, Write, Grep, Glob, Agent,
    Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
  ```
- **Raised by:** B-10, S-14
- **Confidence:** Verified
- **Bears on:** —

### C-11: Per-agent data is spread across nine parallel tables keyed by agent name

- **Claim:** Each roster agent appears in: the always-dispatch list (`AD:16-20`), the signal table (`AD:24-34`), the
  domain slice table (`AD:102-114`), the per-agent directives (`AD:138-153`), the per-agent prompt with its output
  filename (`AD:158-222`), the Step 7.1 output-file list (`SK:350-360`), the manual-only sweep mapping (`AD:263-275`),
  the classification rubric sections (`references/agent-finding-classification.md`), and an agent list in
  `references/output-verification.md:40-42`. Prompt filenames and the 7.1 list agree by convention only. The
  output-verification list is already stale: it names 8 agent families and omits security, on-call, and observability.
- **Location:** as listed
- **Evidence:**
  ```
  2. Agent findings from every dispatched agent (testing, edge-case, structural, behavioral, concurrency, data, devops,
     han-core:junior-developer) have valid task IDs
  ```
- **Raised by:** S-11, B-17, S-10
- **Confidence:** Verified
- **Bears on:** —

### C-12: Today's no-argument behavior is effectively an unnamed general review

- **Claim:** With no argument: junior-developer and adversarial-security-analyst always run, the other nine are
  signal-selected, Extra Agents compete under the same signals, the validator runs, YAGNI is advisory at every size, and
  severity defaults to the Small ladder (Suggestions omitted). None of the operator's named types covers this.
- **Location:** `AD:14-48`, `SK:202-204`, `SK:271`
- **Evidence:**
  ```
  **Default to small.** Start the classification at **small** and only escalate to medium or large when the signals below
  clearly require it.
  ```
- **Raised by:** S-12, B-16
- **Confidence:** Verified
- **Bears on:** —

### C-13: Agent output files have fixed names, so parallel reviews collide and stale files can be read

- **Claim:** Every agent writes to `{output_directory}/{fixed-name}.md` (for example `security-analysis.md`), with no
  run, branch, or type in the name. Two concurrent reviews overwrite each other's agent files, and Step 7.1 can read
  another run's file or a stale file from a previous run when an agent fails to write.
- **Location:** `SK:197-198`, `SK:350-360`, `AD:158-222`
- **Evidence:**
  ```
  - `{output_directory}/security-analysis.md` — han-core:adversarial-security-analyst findings (SEC-series)
  ```
- **Raised by:** B-12
- **Confidence:** Verified
- **Bears on:** —

### C-14: The report name is per-branch and a second run replaces the first

- **Claim:** The report is `code-review-{slug}.md`, slug = ticket, else branch, else what was reviewed. A report at the
  same name is replaced on purpose. Two typed reviews of one branch would replace each other. The report honors a
  configured `output-directory`; the agent files do not.
- **Location:** `SK:439-462`
- **Evidence:**
  ```
  **When a report already exists at that name, replace it** and record that you did, plus the name you replaced, for Step
  10's message. Keeping both would leave two reports for one branch with nothing in their names to say which is current.
  ```
- **Raised by:** B-13
- **Confidence:** Verified
- **Bears on:** —

### C-15: One finding list, one ID sequence, one report per run

- **Claim:** Task IDs are sequential per category across manual and agent findings; caps (30 manual, 30 agent, security
  uncapped), the Step 7.4 validator, the Step 8.5 readability editor, and the report all assume one consolidated list
  per run.
- **Location:** `SK:50-53`, `SK:82-90`, `SK:238-241`, `SK:385-390`
- **Evidence:**
  ```
  IDs are sequential within each category, starting at 001. Assign IDs in the order files are reviewed (alphabetically).
  ```
- **Raised by:** B-18, B-19
- **Confidence:** Verified
- **Bears on:** —

### C-16: Manual-only mode builds its absent-coverage list from whatever Step 3.2 selected

- **Claim:** Detection fires only on the Agent tool being unavailable or a dispatch being denied. The absent-coverage
  list is the selected roster plus the validator; each agent has a hand-sweep row mapping it to checklist categories, at
  "the `{size}` band". An agent with no row has no sweep defined. A partial dispatch failure is not a trigger.
- **Location:** `AD:224-279`
- **Evidence:**
  ```
  **What selection produces in this mode.** Step 3.2 has already run by the time detection fires, so the roster it
  selected is a fact, not a counterfactual.
  ```
- **Raised by:** S-8, B-8
- **Confidence:** Verified
- **Bears on:** —

### C-17: Steps 2, 4, 5, and 6 run on every review regardless of roster

- **Claim:** Automated checks (test/lint/build, failures as CRIT), the manual file-by-file checklist review, docs
  compliance, and docs freshness run on every review; none depends on size or roster.
- **Location:** `SK:179-188`, `SK:243-333`
- **Evidence:**
  ```
  Run each command **one at a time, sequentially**, scoped to changed areas when possible. Record each failure (command +
  relevant error output) as a **CRIT** item with category **[Automated Check]**
  ```
- **Raised by:** B-19
- **Confidence:** Verified
- **Bears on:** —

### C-18: post-code-review-to-pr passes free text through and parses the report by section name

- **Claim:** The wrapper takes only free-form context and forwards it to `/code-review`, so it cannot pass a type and a
  first word matching a type name would be read as one. It captures the report path from code-review's closing message,
  carries named sections (Review Summary, Review Recommendation, findings by severity, optional Review Coverage, What's
  Good, Security Vulnerabilities, Remediation), and picks the PR event from CRIT/WARN presence. A new section a type adds
  would be dropped unless named. Its docs describe "size-aware roster" at three sites.
- **Location:** `han-github/skills/post-code-review-to-pr/SKILL.md:8`, `:44-48`, `:60-66`, `:96`;
  `han-github/docs/skills/post-code-review-to-pr.md:39,107,119`
- **Evidence:**
  ```
  Invoke the `/code-review` skill to perform the full code review. Pass along any user-provided focus areas or context
  from the original arguments.
  ```
- **Raised by:** B-14, S-18
- **Confidence:** Verified for lines 40-105 of the wrapper.
- **Bears on:** —

### C-19: `default-swarm-size` contract tolerates a skill that stops reading it

- **Claim:** The canonical config rule lists no consuming skills and says "A skill that dispatches no agent swarm ignores
  the setting silently", so code-review can stop reading it with no edit to the 13 vendored copies. Three docs name
  code-review as a consumer: `docs/configuration.md:98-113` ("eight sizing-aware skills", plus the "large code review"
  cost example), `docs/sizing.md:6,24,87-88,116,157`, and the long-form doc. ADR 0001 records "the eight sizing-aware
  skills". A user with `default-swarm-size: large` today gets every code review at Large.
- **Location:** `han-core/references/config-rule.md:55-64`; `docs/configuration.md:96-118`; `docs/adr/0001-*.md`
- **Evidence:**
  ```
  The eight sizing-aware skills ([`/architectural-analysis`](../han-coding/docs/skills/architectural-analysis.md),
  [`/code-overview`](../han-coding/docs/skills/code-overview.md),
  [`/code-review`](../han-coding/docs/skills/code-review.md),
  ```
- **Raised by:** S-17, B-6, run sweep
- **Confidence:** Verified
- **Bears on:** —

### C-20: `han-core:gap-analyzer` already does spec-vs-implementation comparison and can fetch URLs

- **Claim:** The gap-analyzer compares a current state against a desired state (specs, requirements, PRDs), writes its
  analysis to a file, and has `WebFetch` in its tools. No code-review file references it today.
- **Location:** `han-core/agents/gap-analyzer.md:1-12`
- **Evidence:**
  ```
  Delegate whenever the user wants to check, compare, or verify code,
  features, or implementations against specs, specifications, PRDs, requirements, or design documents.
  ...
  tools: Read, Glob, Grep, Bash(git *), Bash(find *), WebFetch, Write
  ```
- **Raised by:** run sweep
- **Confidence:** Verified
- **Bears on:** —

### C-21: Step numbers and the Step 3 title are a cited surface

- **Claim:** "Step 3.2" through "Step 3.5" and the Step 3 title "Classify Change Size and Dispatch Review Agents" are
  cited across SKILL.md, agent-dispatch.md, finding-filters.md, and `han-coding/docs/skills/code-review.md:330-333`.
  Files placed in a new `references/types/` directory sit one level deeper, so a link to the plugin's shared
  `references/` becomes `../../../references/`.
- **Location:** `SK:190`, `SK:229-234`; `AD:11-12`, `AD:41`, `AD:92`; `references/finding-filters.md:4`
- **Evidence:**
  ```
  ## Step 3: Classify Change Size and Dispatch Review Agents
  ```
- **Raised by:** S-15
- **Confidence:** Verified
- **Bears on:** —

### C-22: Documentation sites that describe code-review sizing

- **Claim:** Size is described at `han-coding/docs/skills/code-review.md:18-28,45-54,149-169,258-300,330-333`
  (including the bands table and cost-by-size), `docs/sizing.md:6,24,87-88,116,157`, `docs/configuration.md:96-118`,
  `han-coding/README.md:19` ("size-scaled roster"), and `han-github/docs/skills/post-code-review-to-pr.md:39,107,119`.
  Per CLAUDE.md, the README and skills-index scent lines reuse the long-form doc's summary line.
- **Location:** as listed
- **Evidence:**
  ```
  - `/code-review medium`. Override the size to medium.
  - `/code-review large "focus on the new auth endpoints"`. Override to large with a focus hint.
  ```
- **Raised by:** S-19, run sweep
- **Confidence:** Verified
- **Bears on:** —

### C-23: Extra agents and specialists without a Write tool have nowhere reliable to put their findings

- **Claim:** Step 7.1 reads a fixed list of eleven output files and nothing else, so an agent added through `## Extra
  Agents` is dispatched but its output file is never read. Separately, every per-agent prompt ends "Write your output
  to {output_directory}/…", but `han-core:structural-analyst`, `han-core:behavioral-analyst`, and
  `han-core:concurrency-analyst` have no Write tool in their definitions, so they cannot do what the prompt asks.
  Whether their findings reach today's report depends on the orchestrator falling back to the returned message, which
  no step says to do.
- **Location:** `han-coding/skills/code-review/SKILL.md` Step 7.1; `han-coding/skills/code-review/references/agent-dispatch.md:159-213`;
  `han-core/agents/structural-analyst.md`, `behavioral-analyst.md`, `concurrency-analyst.md` frontmatter `tools:`
- **Evidence:**
  ```
  Read only the output files for agents that were actually dispatched in Step 3. Skip the read for any agent that was not
  selected:
  - `{output_directory}/test-plan.md` — han-core:test-engineer findings (T-series)
  ...
  - `{output_directory}/observability-analysis.md` — han-core:observability-engineer findings (OBS-series)
  ```
  ```
  hazards, and integration-boundary assumptions that these changes introduce or break. Write your output to
  ```
- **Raised by:** risk-analyst review (R1), run sweep
- **Confidence:** Verified for the file list and the tool lists; what happens to the findings in a live run is
  Unverified, since nothing was executed.
- **Bears on:** D-1, D-22

### C-24: The config rule is one canonical file with twelve byte-identical copies, and a bad config never fails a run

- **Claim:** `han-core/references/config-rule.md` defines the schema (three frontmatter keys and one `## Extra Agents`
  section), path resolution, per-setting precedence, the extra-agents pool rule, and degradation. Thirteen copies exist
  across the plugins, each byte-identical to the canonical one. The degradation rule says a bad config "can never fail a
  skill run", with one stated exception: a missing `writing-voice` file asks the user instead. Five other skills read
  `## Extra Agents` (automated-test-planning, architectural-analysis, design-an-api, investigate, research).
- **Location:** `han-core/references/config-rule.md` (Schema, Precedence, Extra agents joining the pool, Degradation);
  `*/references/config-rule.md` (13 files); `docs/configuration.md:75,138-167`
- **Evidence:**
  ```
  A bad config can never fail a skill run; the worst it can do is be ignored. Show a one-line note only when content that
  attempts a recognized override cannot be used; pass over everything else silently. A `writing-voice` value naming a
  file that does not exist is the one exception
  ```
- **Raised by:** run sweep
- **Confidence:** Verified
- **Bears on:** D-20, D-21

## Findings No Agent Could Audit

- **How the Claude Code harness binds `arguments:` frontmatter** (single token vs. rest of string). Closing it takes the
  Claude Code skills reference or a probe run. It bears on C-7 and on the argument grammar the plan pins.
- **What specialist agents actually write in practice** under a type-scoped brief. Nothing was executed; closing it
  takes a trial run of a typed review after the build.
