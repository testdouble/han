# Investigation: Which Agent Definitions Should Split Into Producer and Reviewer Forms

Investigation report. Read the Summary, then approve the Planned Fix or push back.

## Summary

- **Root Cause:** One agent, `project-manager`, asks a single definition to both produce an artifact and judge one. That breaks the repo's own authoring rule that an agent holds a single role, generate or evaluate, never both (E1, E3).
- **Fix:** Split `project-manager` into `plan-synthesizer` (producer) and `discussion-facilitator` (reviewer), both staying in `han-core`, and repoint five call sites plus their documentation surfaces.
- **Why Correct:** `project-manager` names the two roles itself, writes a different file for each, and gets dispatched twice in one run of `plan-implementation` for opposite purposes (E3, E5). No other agent in the roster does this (V2).
- **Validation Outcome:** Validation refuted three parts of the first draft. It found a fifth call site the plan had missed (V3). It showed that narrowing `readability-editor` would strip the only quality check two skills have (V5, V8). And it killed a manifest edit that would have broken a repo-wide convention (V7).
- **Remaining Risks:** The placement of `discussion-facilitator` is a close judgment call rather than a rule application, and the documentation migration is larger than the agent work. See Confidence Assessment.

## Problem Statement

Han's agent roster asks one definition to hold two opposite jobs: producing an artifact and reviewing one. The suite ships 24 agents across three plugins. Most hold a single clean role. One does not.

**What you see today.** `project-manager` carries two named operating modes with different output contracts and different output filenames. One run of `plan-implementation` dispatches it twice, once to audit a gate trip mid-run and once to write the plan of record at the end.

**What should happen instead.** Every agent holds one role. When an agent produces something, a different agent with a fresh perspective evaluates it. That is the rule the repo already applies to every new agent (E1).

**When it bites.** The risk shows up when an agent's own reasoning produced the blind spot it is then asked to catch. A synthesized plan that overreached passes its own evidence gate, because the reasoning that made the mistake also grades it.

**Who is affected.** Four skills dispatch `project-manager` across two plugins, at five call sites: `plan-implementation` twice, plus `plan-a-feature`, `plan-work-items`, and `gap-analysis` (E4, E5, E17). Two of those skills also perform the facilitation half in-house rather than dispatching for it (E6, E7).

## Root Cause Analysis

### Root Cause

Han's agent-authoring guidance forbids one agent from both generating and evaluating (E1). But that rule was written after the roster was built and has never been applied backward, so `project-manager` still carries both roles.

### Which agents violate the rule, and which don't

The rule is unambiguous and lives in the plugin-building guidance the repo treats as authoritative: "An agent should have a single role: generate **or** evaluate, not both" (E1). The same file names the mechanism, self-evaluation bias: the reasoning that created a blind spot also grades it as correct.

**`project-manager` is the one clear violation.** Its own description names two modes (E3): facilitation and synthesis.

Facilitation mode enforces an evidence standard, tracks inconsistencies, logs undocumented assumptions, and is told not to decide. That is evaluation.

Synthesis mode reads every specialist's input, reconciles the recommendations, and writes the final plan. That is generation. The two modes write to different files.

The call sites confirm both halves are live. Three skills dispatch synthesis mode by name (E4), and a fourth dispatches the agent to draft work items with no mode named at all (E17).

`plan-implementation` dispatches facilitation mode mid-run to confirm a gate trip, then dispatches synthesis mode at the end to produce the plan of record (E5). One agent, one run, two opposite jobs.

Two skills go further and perform the facilitation role themselves. `plan-implementation` states that consolidating findings and classifying spec maturity is done "deterministically by this skill itself" (E6), and `gap-analysis` consolidates without the agent at small swarm sizes (E7). The skills already separated the halves informally, by keeping the review work in-house.

**Four agents look like candidates and are not.** `junior-developer` has two named modes, but both evaluate (E9). It critiques artifacts other people made and never authors one, so its modes differ in delivery format, not role.

`software-architect` and `system-architect` hold an adversarial posture toward existing structure and then produce a design sketch (E10). But what they critique is upstream findings from other agents, and what they produce is the recommendation. That is generation with a skeptical prior, which the rule permits.

**`readability-editor` is a genuine candidate that should be left alone.** It rewrites a draft and returns a verdict on its own rewrite (E8), which is self-evaluation on the letter of the rule.

The first draft of this plan proposed removing that verdict. Validation showed the removal is a regression (V5, V8).

Two of its callers, `plan-a-feature` and `plan-implementation`, explicitly forbid running a self-check over the editor's output. They call a same-model pass over fresh output "the ungrounded kind of self-review that corrupts a correct answer about as often as it fixes a wrong one" (E18). A third caller, `edit-for-readability`, runs no self-check at all and surfaces the verdict to the user as its deliverable (E19).

Removing the verdict leaves those three callers with nothing. Adding a reviewer agent beside the editor would also double the cost of every prose pass in the suite, which fails the escalation gate that requires a measured reliability problem first (E2). The verdict stays.

**The placement question resolves to: nothing moves.** The rule is that new agents go in `han-core` by default, and an agent leaves only when a single skill family in a plugin above `han-core` dispatches it exclusively (E11). `plan-synthesizer` clears that easily, with callers in both `han-planning` and `han-research`.

`discussion-facilitator` is the close call, and the first draft got its reasoning wrong. Every live facilitation call sits in `han-planning` (V4), so the single-caller exception that put `research-analyst` in `han-research` does apply on its face.

Two things argue for keeping it in `han-core` anyway. Moving it would make `han-planning` the fourth agent-owning plugin, where the coverage rule names three today (E14). It also buys no dependency hygiene: `han-planning` dispatches twenty other `han-core` agents and keeps that dependency regardless (V4). Keeping it in `han-core` also matches what `han-core` already advertises: a facilitator in the shared roster.

Both halves stay in `han-core`.

One manifest problem surfaced along the way. `CONTRIBUTING.md` states that `han-core` depends on `han-communication`, but `han-core/.claude-plugin/plugin.json` carries no `dependencies` key (E13).

## Planned Fix

### What the fix covers

Split `project-manager` into two independently named agents in `han-core`, repoint all five call sites, migrate the documentation surfaces, declare `han-core`'s missing dependency, and record the splitting procedure the guidance does not yet cover. Leave `readability-editor` unchanged.

### File-by-file changes

#### `han-core/agents/plan-synthesizer.md` (new)

- **Change:** New producer agent carrying the synthesis half of today's `project-manager`.
- **Evidence:** (E1), (E2), (E3), (E4), (E17)
- **Standards:** One role per agent; default placement in `han-core`.
- **Details:** Move the synthesis-mode body verbatim: read every specialist's input, reconcile the recommendations, apply the evidence standard to each, and produce the plan with decisions, rejected alternatives with reasons, evidence, specialists consulted, and remaining open items. Keep the `synthesized-plan.md` default filename and the `Read, Glob, Grep, Bash(git *), Bash(find *), Write` tool list. Remove the `## Operating Modes` heading and the mode selector. State that writing to disk is caller-controlled: `plan-work-items` dispatches this same drafting work with "Do not write any files" and takes the output verbatim (E17), so the agent drafts either way and writes only when the caller asks. Add a hard-boundary paragraph naming `discussion-facilitator` as the agent that audits a live discussion.

#### `han-core/agents/discussion-facilitator.md` (new)

- **Change:** New reviewer agent carrying the facilitation half of today's `project-manager`.
- **Evidence:** (E1), (E3), (E5), (E6), (E7)
- **Standards:** One role per agent; placement decided against `CONTRIBUTING.md:184-189` and the coverage rule, as set out in "Which agents violate the rule, and which don't" above.
- **Details:** Move the facilitation-mode body verbatim: run the round-robin, enforce the evidence standard, log open questions and undocumented assumptions, track inconsistencies, and return the facilitation summary with the round-robin record, evidence audit, open-item log, specialists to bring in or send home, and next step. Keep "do not decide yet" as a standing rule rather than a mode qualifier. Drop `Write` from the tool list, because the one live call site already forbids writing a file (E5), leaving `Read, Glob, Grep, Bash(git *), Bash(find *)`.

#### `han-core/agents/project-manager.md` (delete)

- **Change:** Remove the file once both halves land.
- **Evidence:** (E3)
- **Standards:** Semantic versioning. The suite is on the `han-v5.0.0-alpha-1` branch, so a breaking agent rename lands in the right release.
- **Details:** Deleting rather than aliasing keeps one canonical name per role.

#### `han-planning/skills/plan-implementation/SKILL.md`

- **Change:** Repoint the synthesis dispatch and rewrite the paragraph explaining which agent runs when.
- **Evidence:** (E5), (E6)
- **Standards:** Namespace-qualified dispatch, `{plugin}:{agent-name}`.
- **Details:** At line 365, change `han-core:project-manager` in synthesis mode to `han-core:plan-synthesizer` and drop the mode phrase, keeping the note that this call runs on the agent's default model with no `model` override. At lines 231-234, rewrite the paragraph that says `project-manager` is not called per-round. Name `discussion-facilitator` as the agent reserved for the gate-trip pass and `plan-synthesizer` as the Step 8 call, and keep the statement that per-round consolidation is deterministic skill logic. Leave the post-editor block at lines 382-389 alone (E18).

#### `han-planning/skills/plan-implementation/references/round-aggregation.md`

- **Change:** Repoint the gate-trip dispatch at lines 59-64.
- **Evidence:** (E5)
- **Standards:** Namespace-qualified dispatch.
- **Details:** Change `han-core:project-manager` in facilitation mode to `han-core:discussion-facilitator` and drop the mode phrase. Keep the directive not to write a file and the verbatim-return requirement. Rename the round-entry field from `Project-manager review (gate-trip pass):` to `Facilitator review (gate-trip pass):`.

#### `han-planning/skills/plan-a-feature/SKILL.md`

- **Change:** Repoint the synthesis dispatch at line 406.
- **Evidence:** (E4)
- **Standards:** Namespace-qualified dispatch.
- **Details:** Change `han-core:project-manager` in synthesis mode to `han-core:plan-synthesizer` and drop the mode phrase. Leave the post-editor block at lines 434-441 alone (E18).

#### `han-planning/skills/plan-work-items/SKILL.md`

- **Change:** Repoint the drafting dispatch at lines 214 and 247.
- **Evidence:** (E17)
- **Standards:** Namespace-qualified dispatch.
- **Details:** This call site names no mode and asks the agent to draft the work-item breakdown while writing nothing (E17). It is generation, so it becomes `plan-synthesizer`. Update both the `subagent_type` string at line 214 and the prose reference at line 247. Keep the "Do not write any files" directive, which the new agent honors as a caller override.

#### `han-research/skills/gap-analysis/SKILL.md`

- **Change:** Repoint the synthesis dispatch at line 307 and update the operating principle near line 55.
- **Evidence:** (E4), (E7)
- **Standards:** Namespace-qualified dispatch.
- **Details:** Change `han-core:project-manager` in synthesis mode to `han-core:plan-synthesizer` in both places. Keep the swarm-size threshold that skips the agent at two or three agents.

#### `han-core/.claude-plugin/plugin.json`

- **Change:** Add the missing `dependencies` key and update the description.
- **Evidence:** (E13), (E20)
- **Standards:** The dependency-direction rule in `CONTRIBUTING.md:145-154`.
- **Details:** Add `"dependencies": ["han-communication"]` to match what `CONTRIBUTING.md` and `CLAUDE.md` already state. Update the description, which names "the project-manager facilitator" today. Do not mirror the dependency into `han-core/.codex-plugin/plugin.json`: no Codex manifest in this repo carries a `dependencies` key, including plugins whose Claude manifest declares one (E20).

#### Documentation surfaces

- **Change:** Migrate every surface that names `project-manager`, itemized rather than swept.
- **Evidence:** (E14), (E21)
- **Standards:** `docs/templates/coverage-rule.md`; the plugin-README scent convention.
- **Details:** The migration is larger than the agent work and splits into four groups.
  1. **Agent docs.** Add `han-core/docs/agents/plan-synthesizer.md` and `han-core/docs/agents/discussion-facilitator.md` from the agent template. Delete `han-core/docs/agents/project-manager.md`.
  2. **Scent and index.** Replace the `project-manager` scent line in `han-core/README.md:23` with one line per new agent, and the entry in `docs/agents/README.md:49` with two alphabetized entries, each reusing its long-form doc's summary line.
  3. **Dead links.** Three files link to the deleted doc and break unless repointed: `docs/evidence.md:152`, `docs/yagni.md:118`, and `docs/why-solo-and-small-teams.md:43`. All three describe the YAGNI evidence gate during facilitation, so all three point at `discussion-facilitator`.
  4. **Prose mentions.** Rewrite the scattered references in `docs/concepts.md` (7 mentions, including the call-flow diagram at line 80). Also rewrite the references in the four skill long-form docs: `han-planning/docs/skills/plan-implementation.md` (28), `han-planning/docs/skills/plan-a-feature.md` (11), `han-planning/docs/skills/plan-work-items.md` (6), and `han-research/docs/skills/gap-analysis.md` (6). Leave `docs/research/adhd-application-to-han.with-disambiguation.md:415` alone, because it is a dated research record of a former file layout, not a live reference.

#### `CONTRIBUTING.md`

- **Change:** Add a procedure for splitting an existing agent.
- **Evidence:** (E15)
- **Standards:** The existing "Adding an agent" section it sits beside.
- **Details:** The guidance covers when scope is too broad and where a new agent goes, but never the mechanics of turning one definition into two (E15). Add four steps:
  1. Apply the generate-or-evaluate test to decide whether a split is warranted.
  2. Place each half by its own callers, not the combined agent's, and default to `han-core`.
  3. Grep the whole repo for the old name and repoint every call site, dead link, and prose mention.
  4. Run the four-surface coverage rule for each resulting agent.

## Evidence Summary

### E1: The repo's authoring guidance forbids one agent from both generating and evaluating

- **Source:** `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md:36-42, 160-172`
- **Finding:**
  ```
  ### Self-Evaluation Bias

  Agents cannot reliably evaluate their own work. Generator biases replicate in evaluation, creating systematic blind
  spots. This means a single agent should not both generate output and evaluate it. Separate agents with fresh
  perspectives catch what originators miss.

  An agent should have a single role: generate **or** evaluate, not both.

  ### 6. One Role per Agent: Generate or Evaluate

  Do not ask a single agent to both produce output and judge its quality. Self-evaluation bias means the same reasoning
  patterns that created a blind spot will also evaluate it as correct.

  **Instead:**

  - Use one agent to generate (investigate, explore, draft)
  - Use a separate agent to evaluate (validate, audit, challenge)
  ```
- **Relevance:** The rule that makes this a conformance fix rather than a preference. It supplies both the test for selecting candidates and the justification for acting.

### E2: Adding a second agent requires a measured reliability gap

- **Source:** `han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md:47-63`
- **Finding:**
  ```
  ### Level 0: Single Agent
  A single well-prompted agent with access to the right tools handles roughly 70% of tasks. Before designing a
  multi-agent system, verify that one agent with good instructions, domain vocabulary, and tool access cannot achieve
  acceptable quality.

  ### Level 1: Worker + Specialist Reviewer
  Add a second agent when a single agent cannot reliably self-validate. The worker generates output. The reviewer
  evaluates it from a different perspective.
  ```
- **Relevance:** The bar that keeps this fix narrow. It is why the plan splits one agent rather than every agent with an adversarial posture, and why `readability-editor` gets no companion reviewer.

### E3: `project-manager` names two modes with different output contracts

- **Source:** `han-core/agents/project-manager.md:23-38`, description at `:4-6`, filenames at `:339`
- **Finding:**
  ```
  ## Operating Modes

  **Facilitation mode.** When the team is in a live discussion ... enforce the evidence standard, log open questions
  and undocumented assumptions as they surface, track inconsistencies ... Do not decide yet.

  **Synthesis mode.** When the discussion has run its course and the team needs a final plan committed to disk,
  synthesize. Read the inputs from every specialist who contributed, reconcile their recommendations, apply the
  evidence standard to each, and write the final plan ...

  Default filenames: facilitation-summary.md (facilitation mode) or synthesized-plan.md (synthesis mode)
  ```
- **Relevance:** The definition already draws the producer and reviewer line. Facilitation evaluates and decides nothing; synthesis produces the plan of record.

### E4: Three skills dispatch `project-manager` in synthesis mode by name

- **Source:** `han-research/skills/gap-analysis/SKILL.md:307`; `han-planning/skills/plan-implementation/SKILL.md:365`; `han-planning/skills/plan-a-feature/SKILL.md:406`
- **Finding:**
  ```
  gap-analysis:307:      Launch `han-core:project-manager` in synthesis mode with:
  plan-implementation:365: Launch `han-core:project-manager` in **synthesis mode** — this is the one call in this skill that runs on the
  plan-a-feature:406:     Launch the `han-core:project-manager` agent in **synthesis mode**. Provide it with:
  ```
- **Relevance:** Establishes the producer half's call sites and shows two plugins depend on it, which is why `plan-synthesizer` stays in `han-core`.

### E5: One skill run dispatches `project-manager` twice, once to review and once to produce

- **Source:** `han-planning/skills/plan-implementation/references/round-aggregation.md:59-64`
- **Finding:**
  ```
  **If the spec-maturity gate tripped**, this skill makes the one and only PM facilitation call in the round: launch
  `han-core:project-manager` in **facilitation mode** with the verbatim specialist outputs, the deterministic
  aggregation, and a directive to confirm or refine the gate-trip assessment ... Pass the directive: **do NOT write a
  facilitation-summary file to disk.** Return the facilitation output verbatim. Append PM's verbatim output to the
  round entry under a `Project-manager review (gate-trip pass):` field.
  ```
- **Relevance:** The strongest single piece of evidence. The same agent audits a gate trip mid-run and produces the final plan at the end of the same run, and the field the skill writes calls the first one a "review".

### E6: `plan-implementation` performs the facilitation role itself instead of dispatching for it

- **Source:** `han-planning/skills/plan-implementation/SKILL.md:231-234`
- **Finding:**
  ```
  `han-core:project-manager` is **NOT** called per-round in facilitation mode. The mechanical work of consolidating
  specialist findings into a claim ledger, classifying spec-maturity, and choosing a next-step recommendation is
  performed deterministically by this skill itself. PM is reserved for two specific calls only: the final synthesis in
  Step 8, and a single facilitation pass when the spec-maturity gate trips (see below).
  ```
- **Relevance:** Shows the halves are already separated in practice. The skill kept the review work in-house and reserved the agent for two narrow calls.

### E7: `gap-analysis` skips the agent for the same role below a size threshold

- **Source:** `han-research/skills/gap-analysis/SKILL.md:55-58`
- **Finding:**
  ```
  `han-core:project-manager` coordinates Section 4 synthesis at medium and large only. When the swarm reaches four
  or more agents, PM consolidates the swarm's confirmations, contradictions, augmentations, and per-gap confidence
  values for the skill to render. At small swarm size (two or three agents), the skill consolidates deterministically
  without PM.
  ```
- **Relevance:** A second, independent instance of the pattern in E6. Two skills in two plugins arrived at the same workaround.

### E8: `readability-editor` audits and rewrites in one undivided pass

- **Source:** `han-communication/agents/readability-editor.md:4, 13, 90-93, 113-120, 125`
- **Finding:**
  ```
  Line 4:   Audits and rewrites a finished draft against the shared Human-Readable Output Standard, preserving every fact.
  Line 13:  tools: Read, Glob, Grep, Edit, Write
  Line 90:  ## The rubric
            Audit and rewrite against these six criteria. They are the whole rubric.
  Line 113: ## How you work
            2. Rewrite the prose in place against the rubric ...
            3. After rewriting, re-read your result against the original and confirm every fact survived.
  Line 125: Rubric verdict — one line per criterion: pass, or what you changed to make it pass
  ```
- **Relevance:** The only agent with `Edit`, and the only one whose description verb pair is "audits and rewrites". It grades its own rewrite, which is the letter of the E1 violation. E18 and E19 are why the plan leaves it alone anyway.

### E9: `junior-developer` has two modes, but both are evaluation

- **Source:** `han-core/agents/junior-developer.md:23-40`; call sites at `han-coding/skills/coding-standard/SKILL.md:389`, `han-github/skills/post-code-review-to-pr/SKILL.md:72`, `han-documentation/skills/architectural-decision-record/SKILL.md:136`, `han-planning/skills/plan-implementation/SKILL.md:281-284`
- **Finding:**
  ```
  **Artifact-review mode.** When handed a completed artifact ... execute all eight analysis protocols, build the full
  question log, write the complete review to a file, and return only the summary to the caller.

  **Conversational mode.** When invoked _during_ a live discussion ... listen, reframe the topic in plain language, and
  push back with the two to five clarifying questions that would most change the decision. Do not write a file.
  ```
- **Relevance:** Rules out the most obvious-looking second candidate. Both modes critique work someone else did, so the difference is delivery format, not role.

### E10: The two architect agents pair an adversarial posture with a design sketch

- **Source:** `han-core/agents/software-architect.md:16-17, 125-133, 184`; `han-core/agents/system-architect.md:15-17, 185-192, 219-231`
- **Finding:**
  ```
  software-architect:16: You are an adversarial software architect. Your default posture: the current intra-codebase
                         structure is wrong until evidence says otherwise.
  software-architect:125: - **Recommended change:** What to change and how, with pseudocode sketches where they clarify intent
  software-architect:184: Does not produce action plans, prioritized task lists, or implementation timelines — produces
                          architectural recommendations only
  system-architect:15:   You are an adversarial system architect. Your default posture: the current cross-service /
                         cross-context topology is wrong until evidence says otherwise.
  ```
- **Relevance:** Rules out two more candidates. What they critique is upstream findings from other agents, and what they produce is the recommendation.

### E11: New agents default to `han-core`; exceptions sit beside the skill that dispatches them

- **Source:** `CONTRIBUTING.md:99-101, 184-189`
- **Finding:**
  ```
  "han-core" carries the shared specialist agent roster — every agent in the suite except the readability-editor
  (which lives in han-communication) and the research-analyst (which lives in han-research) ... New agents go here by
  default.

  1. Create han-core/agents/{name}.md with frontmatter (name, description, tools, model) and the agent body. New
     agents live in han-core by default; the exceptions are the readability-editor, living in han-communication with
     the readability skills it serves, and the research-analyst, living in han-research with the research skill that
     dispatches it.
  ```
- **Relevance:** The placement rule, and the single-caller precedent that makes `discussion-facilitator` a close call rather than an automatic `han-core` placement.

### E12: Dependency direction pins `readability-editor` to `han-communication`

- **Source:** `CONTRIBUTING.md:145-154`
- **Finding:**
  ```
  ... the exceptions are the readability-editor, which lives in the foundational han-communication plugin alongside
  the readability skills and which every prose-producing plugin reaches by declaring a direct dependency on
  han-communication ... han-reporting, han-feedback, and han-linear dispatch no shared agents and so carry no
  han-core dependency.

  han-core depends only on han-communication. It reaches nothing in the plugins above it ...
  ```
- **Relevance:** Confirms no readability-side change could move an agent into `han-core`, because `han-reporting` depends on `han-communication` alone.

### E13: `han-core`'s manifest declares no dependencies, contradicting the docs

- **Source:** `han-core/.claude-plugin/plugin.json`
- **Finding:**
  ```json
  {
    "name": "han-core",
    "description": "The shared foundation of the Han suite: the specialist agent roster the other plugins dispatch (adversarial reviewers, analysts, architects, investigators, and the project-manager facilitator), the project-discovery skill with its project-scanner agent, and the canonical evidence and YAGNI rule files. ...",
    "version": "3.0.0"
  }
  ```
- **Relevance:** `CONTRIBUTING.md:153-154` states "han-core depends only on han-communication", but the manifest carries no `dependencies` key. The description also names "the project-manager facilitator", so it needs updating when the split lands.

### E14: Each agent owes four documentation surfaces

- **Source:** `CONTRIBUTING.md:182-193`; `docs/templates/coverage-rule.md:10-13`; `docs/agents/README.md:73-77`
- **Finding:**
  ```
  2. Copy the agent template into {plugin}/docs/agents/{name}.md (usually han-core) and fill it in. Every agent gets a
     long-form doc.
  3. Add a scent line to the plugin's README.md and one alphabetized entry to the agents index (./docs/agents/README.md),
     both reusing the long-form doc's own summary line as the canonical scent.

  When you add a new agent, you create a long-form doc in {plugin}/docs/agents/{name}.md (today that plugin is
  han-core, han-communication, or han-research, the only agent-owning plugins) using the agent template.
  ```
- **Relevance:** Sizes the per-agent documentation work, and names the three agent-owning plugins, which is one reason `discussion-facilitator` stays in `han-core` rather than making `han-planning` a fourth.

### E15: No documented procedure covers splitting an existing agent

- **Source:** Searched `CONTRIBUTING.md`, `docs/templates/coverage-rule.md`, and every file under `han-plugin-builder/skills/guidance/references/agent-building-guidelines/` for "split"
- **Finding:** No file describes turning one existing agent definition into two. The guidance supplies the criteria for when scope is too broad, and `CONTRIBUTING.md` covers adding a brand-new agent, but neither covers the migration mechanics.
- **Relevance:** A gap this plan closes, so the next split does not rediscover the placement and call-site rules. Validation showed the gap has teeth: the first draft of this plan got the placement reasoning wrong and missed a call site.

### E16: `code-review` runs an independent readability check after the editor

- **Source:** `han-coding/skills/code-review/SKILL.md:473-478`; `han-coding/skills/code-review/references/output-verification.md:68-74`
- **Finding:**
  ```
  ## Step 8.5: Rewrite the Finding Prose for Readability
  Dispatch `han-communication:readability-editor` over the assembled review to rewrite its prose against the shared
  readability standard ...

  ### Step 9.2: Readability self-check
  Run the standardized readability self-check (the shared standard is in your context from
  `han-communication:readability-guidance`) over the report's prose regions only ...
  ```
- **Relevance:** One caller does have an outside evaluator for the editor's rewrite. E18 and E19 show it is the exception, not the pattern, which is why the plan no longer relies on it.

### E17: A fifth call site dispatches `project-manager` with no mode named

- **Source:** `han-planning/skills/plan-work-items/SKILL.md:214, 247`
- **Finding:**
  ```
  214: Launch `han-core:project-manager` (`subagent_type: "han-core:project-manager"`) with:
       - The full plan or context content from Step 1.
       - The boundary record from Step 0 ...
       - The artifact inventory from Step 4.
       - The Rules section of this skill verbatim.
  247: Return the han-core:project-manager's output verbatim. Proceed to Step 6.
  ```
- **Relevance:** Found by validation, not the first investigation pass. The call asks the agent to draft the work-item breakdown and write nothing, which is generation, so it maps to `plan-synthesizer`. It also shows that writing to disk is a caller directive rather than an intrinsic property of the synthesis role.

### E18: Two skills explicitly forbid a self-check over the editor's output

- **Source:** `han-planning/skills/plan-a-feature/SKILL.md:434-441`; `han-planning/skills/plan-implementation/SKILL.md:382-389`
- **Finding:**
  ```
  Then read the editor's fact-preservation report. **Do not walk the six-point checklist over the text the editor
  produced.** The canonical readability rule says the dedicated editor replaces a skill's own readability pass rather
  than stacking a second one on top, and a same-model pass over the editor's own fresh output is the ungrounded kind
  of self-review that corrupts a correct answer about as often as it fixes a wrong one.
  ```
- **Relevance:** Refutes the first draft's plan to remove the editor's rubric verdict. These two callers have no post-editor check by design, so the verdict is the only signal they get.

### E19: `edit-for-readability` runs no self-check and surfaces the verdict as its deliverable

- **Source:** `han-communication/skills/edit-for-readability/SKILL.md:123`; searched the file for "self-check" and found none
- **Finding:**
  ```
  123: scratch file path, and include the same rubric verdict and fact-preservation ledger.
  ```
- **Relevance:** The skill exists to run the editor over a target no other skill checked. Removing the verdict would delete its only quality signal and break its Step 4 instructions, which name the field directly.

### E20: No Codex manifest in the repo carries a `dependencies` key

- **Source:** `grep -l "dependencies" */.codex-plugin/plugin.json` returned zero matches
- **Finding:** Every `.codex-plugin/plugin.json` omits `dependencies`, including `han-research` and `han-planning`, whose `.claude-plugin/plugin.json` counterparts both declare `["han-communication", "han-core"]`.
- **Relevance:** Refutes the first draft's instruction to mirror the `han-core` dependency fix into the Codex manifest. Doing so would make it the only Codex manifest carrying the key.

### E21: The documentation migration spans seven files beyond the four coverage surfaces

- **Source:** `grep -c project-manager` across the repo, excluding `docs/plans/`
- **Finding:**
  ```
  han-planning/docs/skills/plan-implementation.md   28
  han-planning/docs/skills/plan-a-feature.md        11
  han-planning/docs/skills/plan-work-items.md        6
  han-research/docs/skills/gap-analysis.md           6
  docs/concepts.md                                   7   (includes the call-flow diagram at line 80)
  docs/evidence.md:152          links to han-core/docs/agents/project-manager.md
  docs/yagni.md:118             links to han-core/docs/agents/project-manager.md
  docs/why-solo-and-small-teams.md:43   links to han-core/docs/agents/project-manager.md
  docs/workflows.md                                  0
  ```
- **Relevance:** Sizes the real migration. Three of these files carry live relative links to the doc the plan deletes, so they break unless repointed. `docs/workflows.md` needs no change.

## Validation Results

### Counter-Evidence Investigated

#### V1: The evidence citations are stale or paraphrased

- **Hypothesis:** The quoted text and line numbers in the evidence summary do not match the files on disk.
- **Investigation:** The validator opened every cited file at every cited line across E1 through E14 and compared the quotes character by character.
- **Result:** Confirmed
- **Impact:** Every quote is verbatim and every line number is exact, with one range off by a line (E14's `10-12` is `10-13`, since corrected). The fact-gathering layer held; the failures were in the reasoning built on top of it.

#### V2: Other agents in the roster also generate and judge

- **Hypothesis:** The plan missed agents that both produce an artifact and grade it, particularly the ten agents that hold `Write` alongside an adversarial posture.
- **Investigation:** Read every definition in the three agent directories. Grepped all 24 for `Edit`, and for "rewrite", "verdict", "grade", and "self-evaluat", then inspected each hit.
- **Result:** Confirmed
- **Impact:** Only `readability-editor` holds `Edit`. No other agent returns a verdict on output it generated; writing a findings report about someone else's work is evaluation output, not generation. The candidate set is complete. `information-architect:401` reinforces this by stating "Do not rewrite the documentation."

#### V3: The call-site list is incomplete

- **Hypothesis:** The first draft's four call sites are all of them.
- **Investigation:** Grepped the whole repo for `project-manager`, then read the surrounding block at each hit. I re-ran the grep on `plan-work-items` myself and read lines 209-247.
- **Result:** Refuted
- **Impact:** `han-planning/skills/plan-work-items/SKILL.md:214, 247` is a fifth, live call site the first draft missed. It names no mode. The plan now carries it as E17 and routes it to `plan-synthesizer`, since it asks for drafting. The validator argued this might be a third undocumented role. I disagree: it is generation. The only difference from the other synthesis calls is that this caller forbids writing a file, and the other call sites vary on that point too, since E5 forbids it as well.

#### V4: The placement conclusion was reasoned from the wrong caller set

- **Hypothesis:** The claim that both halves stay in `han-core` because two plugins dispatch `project-manager` tested the combined agent, not each half.
- **Investigation:** Grepped for "facilitation mode" across the repo and checked which plugin each live call site sits in. Listed every `han-core` agent `han-planning` dispatches.
- **Result:** Refuted
- **Impact:** The original justification was wrong. Every live facilitation call sits in `han-planning`, so `discussion-facilitator` has one caller in one plugin, and the single-caller exception that placed `research-analyst` in `han-research` applies on its face. The conclusion survives on different reasoning, now stated in "Which agents violate the rule, and which don't" above: `han-planning` dispatches twenty other `han-core` agents and keeps that dependency either way, so moving buys no dependency hygiene. It would also make `han-planning` the fourth agent-owning plugin, where the coverage rule names three today. This is a judgment call, not a rule application, and it is the weakest load-bearing decision in the plan.

#### V5: Removing the editor's rubric verdict is safe

- **Hypothesis:** Every skill dispatching `readability-editor` runs its own readability self-check afterward, so the verdict is redundant.
- **Investigation:** Enumerated every dispatcher, then grepped each for a following self-check. I confirmed the `edit-for-readability` result myself.
- **Result:** Refuted
- **Impact:** `edit-for-readability` runs no self-check at all and surfaces the verdict to the user as part of its deliverable (E19). Removing the verdict would strip that skill's only quality signal and leave its Step 4 instructions naming a field that no longer exists. `han-reporting/skills/stakeholder-summary/SKILL.md:170` also hard-codes a reference to the verdict. The `readability-editor` change is dropped from the plan.

#### V6: The documentation section covers the real blast radius

- **Hypothesis:** A general instruction to check `docs/workflows.md` and `docs/concepts.md` is enough.
- **Investigation:** Counted `project-manager` mentions per file across the repo and searched for relative links to the doc the plan deletes. I re-ran both myself.
- **Result:** Refuted
- **Impact:** The first draft understated the work by roughly an order of magnitude and missed three files holding live links that would break: `docs/evidence.md:152`, `docs/yagni.md:118`, and `docs/why-solo-and-small-teams.md:43`. It also missed four skill long-form docs carrying 51 mentions between them. The Documentation surfaces section is now itemized as E21. `docs/workflows.md`, which the first draft named, has zero mentions.

#### V7: Mirroring the dependency into the Codex manifest follows convention

- **Hypothesis:** Adding `dependencies` to `han-core/.codex-plugin/plugin.json` matches the other Codex manifests.
- **Investigation:** Grepped all Codex manifests for `dependencies`. I re-ran this myself and got zero matches.
- **Result:** Refuted
- **Impact:** No Codex manifest in the repo carries the key, including plugins whose Claude manifest declares one (E20). The mirroring instruction is removed. The `.claude-plugin` fix stands on its own.

#### V8: E16 generalizes from a single source

- **Hypothesis:** The claim that "the calling skills already run an independent self-check" holds across the caller set.
- **Investigation:** Read the post-editor block in `plan-a-feature` and `plan-implementation`. I read `plan-a-feature:430-442` myself.
- **Result:** Refuted
- **Impact:** Both skills explicitly forbid the self-check in bold, citing the canonical readability rule and calling a same-model pass over fresh output "the ungrounded kind of self-review". E16 was true of `code-review` and generalized without checking. It is now scoped to `code-review` alone, and the argument it supported is withdrawn.

### Adjustments Made

1. **Dropped the `readability-editor` change entirely** (V5, V8). The first draft removed its rubric verdict. Three callers would have lost their only quality signal, and adding a companion reviewer fails the escalation gate in E2. The agent is unchanged, and "Which agents violate the rule, and which don't" above now explains why a real rule violation is being left in place.
2. **Added the fifth call site** (V3). `plan-work-items` joins the fix as its own change entry, with E17 as new evidence.
3. **Rewrote the placement justification** (V4). The original reason was factually wrong about the facilitator's callers. The conclusion is the same, the reasoning is new, and the decision is now flagged as a judgment call.
4. **Itemized the documentation migration** (V6). Four groups replace the catch-all, including three dead links and four long-form docs, recorded as E21.
5. **Removed the Codex manifest mirroring** (V7), with E20 as new evidence.
6. **Scoped E16 to `code-review`** (V8) and added E18 and E19 as the counter-evidence.
7. **Corrected E14's line range** from `10-12` to `10-13` (V1).

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:**
  - The `discussion-facilitator` placement is the weakest decision here. The repo's own single-caller exception points at `han-planning`, and the plan keeps it in `han-core` on two secondary considerations (E11, E14, V4). A reasonable reviewer could decide the other way, and the cost of changing course later is one file move plus four documentation surfaces.
  - Routing `plan-work-items` to `plan-synthesizer` (E17) rests on reading its ask as generation. The call names no mode, so no author's intent is recorded. If it turns out to need behavior neither half provides, the split needs a third look.
  - The documentation migration touches 51 prose mentions across four long-form docs (E21). Nobody line-checked all of them, so the count is a lower bound on the work and mentions may remain after a first pass.
  - The plan knowingly leaves a rule violation in place. `readability-editor` still grades its own rewrite (E8). That is the right call today given E18 and E19, but it means the roster will not be fully conformant after this work lands.

## Coding Standards Reference

| Standard                                                                   | Source                                                                                             | Applies To                                                       |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| One role per agent: generate or evaluate, never both                       | `han-plugin-builder/.../agent-building-guidelines/agent-domain-focus.md:36-42, 160-172`             | Both new agent definitions                                       |
| Escalate to a second agent only on a measured self-validation gap          | `han-plugin-builder/.../agent-building-guidelines/multi-agent-economics.md:47-63`                   | The decision to leave `readability-editor` alone                  |
| New agents live in `han-core` by default, with a single-caller exception   | `CONTRIBUTING.md:99-101, 184-189`                                                                   | Placement of both halves                                          |
| `han-core` depends only on `han-communication` and reaches nothing above it | `CONTRIBUTING.md:145-154`                                                                           | The `han-core` manifest fix and every placement decision          |
| Namespace-qualified dispatch, `{plugin}:{agent-name}`                      | `docs/agents/README.md:14-16`; `docs/concepts.md:225-226`                                           | All five call-site edits                                          |
| Every agent gets a long-form doc, a README scent line, and an index entry  | `docs/templates/coverage-rule.md:10-13`; `CONTRIBUTING.md:182-193`                                  | The documentation surfaces for both new agents                    |
| Codex manifests carry no `dependencies` key                                | Inferred from every `*/.codex-plugin/plugin.json` in the repo                                       | The `han-core` manifest fix                                       |
| Conventional Commits                                                       | `/Users/riverbailey/.claude/references/the-book/git/commits.md`                                     | Commits implementing this plan                                    |
| Han writing voice and readability standard                                 | `han-communication/references/writing-voice.md`; `han-communication/references/readability-rule.md` | Prose in every new or edited agent definition and doc             |
