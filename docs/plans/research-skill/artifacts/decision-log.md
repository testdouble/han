# Decision Log: `/research` skill

This file records every decision settled while specifying the `/research`
skill. Behavioral statements live in
[../feature-specification.md](../feature-specification.md). The investigation
that decided `/research` should exist at all is
[../recommendation.md](../recommendation.md), backed by
[01](./01-investigate-skill-analysis.md), [02](./02-skill-taxonomy-guidance.md),
[03](./03-precedent-and-cost.md), and [04](./04-adversarial-validation.md).
Review findings that reshaped decisions are in [team-findings.md](team-findings.md).

No `feature-technical-notes.md` was created: every load-bearing mechanic is
either stated behaviorally in the spec or discoverable from the repo (the
`/investigate` analog, `docs/sizing.md`, and existing agent definitions).

## Trivial decisions

- D12: Slash command name — the skill is invoked as `/research`, per the user's request. — Referenced in spec: title, Actors and Triggers, User Interactions.
- D13: Durable report output — `/research` writes a report file, matching the `/investigate` analog where the investigation is written to a plan file rather than only answered in channel. — Referenced in spec: Outcome, Primary Flow.

### D14: Invocation surface

`/research <question> [output path]`, mirroring `/investigate`'s invocation shape. — Referenced in spec: User Interactions, Primary Flow.

## Full decisions

### D1: Skill purpose and output shape

- **Question:** What is `/research`, and what does it produce?
- **Decision:** A skill that takes an open-ended question (options, prior art, trade-offs, "how does X work") and produces a research report: framed question, numbered evidence, an options landscape with trade-offs, a recommended option, and adversarial-validation findings.
- **Rationale:** The source investigation established that research is a structurally distinct process from investigation — it starts from a question and ends at a recommended option among trade-offs, not from a symptom ending at a fix.
- **Evidence:** [../recommendation.md](../recommendation.md) Plain-language summary and Final recommendation; [01](./01-investigate-skill-analysis.md) E2–E5.
- **Rejected alternatives:**
  - Expand `/investigate` to cover research — rejected because it violates Han's single-responsibility rule ([../recommendation.md](../recommendation.md) Option B).
  - Two-mode "deep-dive" skill — rejected for the same reason ([../recommendation.md](../recommendation.md) Option C).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D2, D6, D10, D24
- **Referenced in spec:** Actors and Triggers

### D2: Scope boundary and bidirectional routing

- **Question:** What does `/research` explicitly not do, and how does it disambiguate from its neighbors?
- **Decision:** `/research` is scoped to open-ended, output-agnostic research only. It explicitly does not specify features, set standards, compare two concrete artifacts, assess module architecture, or diagnose bugs, and its description names each of those siblings; the siblings name `/research` back.
- **Rationale:** The single largest risk the investigation surfaced is trigger collision with adjacent skills; the only mechanism Han has for it is bidirectional "Does not X — use Y" routing, used by all existing skills.
- **Evidence:** [../recommendation.md](../recommendation.md) Final recommendation constraint 2; [02](./02-skill-taxonomy-guidance.md) E11; `docs/guidance/skill-building-guidance/skill-description-frontmatter.md` ("Disambiguation must work in both directions").
- **Rejected alternatives:**
  - Broad research description with no sibling routing — rejected because it collides with `plan-a-feature`, `coding-standard`, `gap-analysis`, and `architectural-analysis` ([../recommendation.md](../recommendation.md) Option A row 6; [04](./04-adversarial-validation.md) V7).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D8, D9, D10, D18
- **Referenced in spec:** Actors and Triggers, Primary Flow, Out of Scope

### D3: Research reach

- **Question:** How far should `/research` reach for information — codebase only, codebase plus provided material, or also the open web?
- **Decision:** `/research` reaches the codebase, the open web, and any operator-provided material. A codebase is optional; pure external idea research works outside a repository.
- **Rationale:** The user explicitly framed `/research` as covering "ideas, possible solutions, and other info that sits outside" `/investigate`'s codebase-only focus; web reach is the differentiator that makes the skill non-duplicative.
- **Evidence:** User input (research-reach question, this conversation); `/investigate` is deliberately codebase-only (`plugin/skills/investigate/SKILL.md` allowed-tools); [../recommendation.md](../recommendation.md) Final recommendation constraint 1.
- **Rejected alternatives:**
  - Codebase only — rejected because it largely duplicates `/investigate`'s reach and undercuts the skill's purpose (user input).
  - Codebase plus provided material, no live web — rejected because it cannot answer "what is the prior art out there" (user input).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D4, D16
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes, Coordinations

### D4: Agent roster

- **Question:** Should `/research` add a new agent for open-ended research, reuse existing agents with reframed briefs, or defer the choice to implementation? And which existing agents fit?
- **Decision:** Add one new dedicated research agent that owns the open-ended / idea-space research angle and the option-comparison angle. Reuse `codebase-explorer` for the codebase-grounded angle and `adversarial-validator` to challenge the recommendation. `gap-analyzer` is not used by `/research`.
- **Rationale:** No existing agent is scoped to idea-space research; `evidence-based-investigator` is bug-vocabulary and `codebase-explorer` is documentation-oriented, so reuse-only accepts a quality-degrading vocabulary mismatch. `adversarial-validator` already works on recommendations, proven by the source investigation itself. Review found `gap-analyzer` is fundamentally a two-artifact current-vs-desired comparator (it requires two inputs and declares a comparison direction); "weigh options A/B/C on multiple criteria" is not that shape, so `gap-analyzer` was dropped and option-comparison folded into the new research agent.
- **Evidence:** User input (agent-roster question and the follow-up gap-analyzer question, this conversation); [03](./03-precedent-and-cost.md) E13; [../recommendation.md](../recommendation.md) Final recommendation constraint 4; [04](./04-adversarial-validation.md) V9 (validator works on non-bug recommendations); `plugin/agents/gap-analyzer.md` lines 1–27 (two-input current/desired contract).
- **Rejected alternatives:**
  - Reuse existing agents with reframed briefs only — rejected because it accepts the bug-vocabulary mismatch flagged as a quality risk (user input).
  - Defer the agent decision to `plan-implementation` — rejected because the roster materially shapes the skill's behavior and the user chose to settle it now (user input).
  - Keep `gap-analyzer` with a research-framed brief — rejected because it accepts exactly the vocabulary-mismatch risk a new agent was added to avoid (F3; user input).
  - Keep `gap-analyzer` only for true A-vs-B questions — rejected by the user in favor of a cleaner, smaller roster (F3; user input).
- **Linked technical notes:** —
- **Driven by findings:** F3
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Coordinations

### D5: Team-size model

- **Question:** Should `/research` use a fixed roster like `/investigate`, or scale its team with Han's small/medium/large sizing model?
- **Decision:** `/research` scales its research team with Han's small/medium/large sizing model, becoming Han's 7th sized skill.
- **Rationale:** The user chose research breadth that scales with question scope over a fixed roster.
- **Evidence:** User input (team-sizing question, this conversation); Han's sizing model is documented at `docs/sizing.md` and used by the six existing swarming skills.
- **Rejected alternatives:**
  - Fixed roster like `/investigate` (parallel researchers + one validation pass, no tiers) — rejected by the user in favor of scope-scaled breadth, despite being the simpler YAGNI default.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D15
- **Referenced in spec:** Primary Flow, User Interactions, Open Items

### D6: Workflow spine

- **Question:** What is the ordered workflow of `/research`?
- **Decision:** Research → consolidated numbered evidence (E#) → options landscape with trade-offs → recommended option (or explicit "no clear winner" with deciding criteria) → adversarial-validation pass (V#) → re-evaluate recommendation against validation → write report → present for review. No bug classification, no root-cause step, no fix-planning step. The option-comparison angle runs only when the question implies discrete alternatives; it is skipped for "how does X work" questions.
- **Rationale:** The spine mirrors `/investigate`'s proven evidence→numbering→validation scaffold but is question-shaped, not symptom-shaped; every bug-specific stage is removed because research has a different terminus. Review found the option-comparison angle had no defined behavior for non-comparative questions; the simplest evidence-satisfying rule is to skip it when no alternatives exist (the same conditional pattern already used for the codebase angle in pure external research).
- **Evidence:** [../recommendation.md](../recommendation.md) Plain-language summary; [01](./01-investigate-skill-analysis.md) E2–E5, E10; `plugin/skills/investigate/SKILL.md` (analog spine); F2 (option-comparison undefined for non-comparative questions).
- **Rejected alternatives:**
  - Reuse `/investigate`'s bug-shaped steps verbatim — rejected because "classify the bug", "root cause", and "plan the fix" have no analog in research ([01](./01-investigate-skill-analysis.md) E3–E5).
  - Dispatch the option-comparison angle unconditionally — rejected as a symmetry/completeness anti-pattern; it has nothing to compare for "how does X work" questions (F2).
- **Linked technical notes:** —
- **Driven by findings:** F2, F11
- **Dependent decisions:** D7
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States

### D7: Adversarial-validation target

- **Question:** What does the adversarial-validation pass attack in a research run, and what happens to the recommendation afterward?
- **Decision:** It attacks the evidence, the way the options were framed, the recommendation itself, and the integrity of the evidence-gathering — whether any evidence item could have been introduced or shaped by external content designed to influence the output, whether discounting any single external item changes the recommendation, and whether external sources are stale, adversarially constructed, or implausibly convenient. After the pass, the skill re-evaluates the recommendation; if it no longer survives, the recommendation section is rewritten into the "no clear winner" form rather than left standing above a contradicting validation section.
- **Rationale:** Research has no fix to break; `adversarial-validator` already operates on evidence-plus-recommendation structures, demonstrated by the source investigation. Web reach (D3) makes untrusted content a first-class input, so the validator must be chartered to attack evidence-gathering integrity, not just the recommendation's logic. Review found "reshaped" was ambiguous and could leave a contradicted recommendation standing.
- **Evidence:** [04](./04-adversarial-validation.md) V9; [../recommendation.md](../recommendation.md) Validation outcome section; F8 (validator charter omitted evidence-gathering integrity); F11 (post-validation rewrite ambiguity); F15 (stale-source detection needs validator briefing).
- **Rejected alternatives:**
  - Skip adversarial validation for research — rejected because it is the quality differentiator carried over from `/investigate`.
  - Validate only the recommendation's logic, not the evidence-gathering — rejected because D3's web reach introduces injection and astroturfing the recommendation logic cannot catch (F8).
  - Annotate an overturned recommendation in place — rejected because it sends the operator a confidently wrong top-line signal (F11).
- **Linked technical notes:** —
- **Driven by findings:** F8, F11, F15
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D8: Out-of-scope redirect behavior

- **Question:** What does `/research` do when the request is actually a sibling skill's concern?
- **Decision:** It names the correct sibling skill, explains in one sentence why that skill fits better, and produces no research report. Hybrid requests are handled under D18.
- **Rationale:** Han's house style routes between skills explicitly; proceeding on an out-of-scope request would produce the wrong artifact and erode triggering trust.
- **Evidence:** [../recommendation.md](../recommendation.md) Final recommendation constraints 1–2; [02](./02-skill-taxonomy-guidance.md) E11.
- **Rejected alternatives:**
  - Attempt the research anyway and append a "you may also want skill X" note — rejected because it still produces a partial wrong-shaped result.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D18
- **Referenced in spec:** Primary Flow, Alternate Flows and States, User Interactions

### D9: Reciprocal-routing coordination

- **Question:** What must be true of the neighbor skills for `/research` to route correctly, and what happens if clean disambiguation is not achievable?
- **Decision:** Releasing `/research` requires `investigate`, `plan-a-feature`, `coding-standard`, `gap-analysis`, and `architectural-analysis` to each carry a reciprocal boundary statement pointing research-shaped requests back to `/research`. If clean bidirectional disambiguation cannot fit the description budget for all five, the source recommendation requires revisiting before implementation proceeds rather than forcing it through. The exact file list is implementation detail.
- **Rationale:** One-way disambiguation leaves a gap requests fall through; the frontmatter guidance requires both directions. The recommendation made poor disambiguation a stop-and-revisit condition, not merely an ordering constraint.
- **Evidence:** `docs/guidance/skill-building-guidance/skill-description-frontmatter.md` ("Disambiguation must work in both directions"); [../recommendation.md](../recommendation.md) Final recommendation constraint 2 ("revisit this recommendation before building"); F16 (abort gate was missing).
- **Rejected alternatives:**
  - Only describe `/research`'s outward boundaries — rejected because siblings would still over-trigger on research requests ([04](./04-adversarial-validation.md) V7).
  - Treat disambiguation as an ordering constraint only — rejected because the recommendation framed it as an abort condition (F16).
- **Linked technical notes:** —
- **Driven by findings:** F16
- **Dependent decisions:** —
- **Referenced in spec:** Coordinations, Out of Scope

### D10: Output-agnostic guarantee

- **Question:** May `/research` ever produce a sibling's artifact (a spec, a standard, a gap report, an architecture assessment)?
- **Decision:** No. `/research` produces a research report and only a research report. A request that mixes research with a sibling concern gets the research portion plus an explicit handoff naming the sibling (D18).
- **Rationale:** Output-agnosticism is the anti-collision guarantee that keeps `/research` from duplicating four existing skills; the investigation narrowed the open slot specifically to output-agnostic research.
- **Evidence:** [../recommendation.md](../recommendation.md) Final recommendation constraint 1; [04](./04-adversarial-validation.md) V6.
- **Rejected alternatives:**
  - Let `/research` optionally emit a starter spec/standard — rejected because it recreates the trigger-collision and single-responsibility problems the investigation rejected.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D18
- **Referenced in spec:** Outcome, Edge Cases and Failure Modes, Out of Scope

### D11: Verifiable evidence sourcing

- **Question:** What integrity requirement applies to evidence items, given web reach?
- **Decision:** Every numbered evidence item carries a source the reader can independently check — a repository location for codebase evidence, an external source reference plus its retrieval date for web evidence. An external claim that bears on the recommendation must be corroborated by an independent source or by codebase evidence; an uncorroborated external claim is caveated and cannot be the sole basis for the recommendation. Operator-provided material is held to the same scrutiny as open-web sources (it may come from an interested party). When codebase evidence and web evidence conflict, the conflict is surfaced and "continue with the current approach" appears as a named option.
- **Rationale:** The skill's value is evidence-based, like `/investigate` whose E# items are file-anchored; web reach introduces unverifiable, stale, and astroturfed claims, so a bare "has a URL" test is trivially satisfied by an attacker. Corroboration, retrieval date, and equal scrutiny of provided material are the behavioral controls that keep the report trustworthy. Source-format wording is kept behavioral ("a source the reader can independently check") rather than naming file-path-vs-URL mechanics.
- **Evidence:** `/investigate` analog (E# items keyed to file paths and line numbers, `plugin/skills/investigate/SKILL.md`); [../recommendation.md](../recommendation.md) emphasis on evidence-based output; F5 (URL-only test too weak / report laundering); F12 (codebase-vs-web conflict unhandled); F13 (interested-party provided material); F15 (stale source needs retrieval date); F22 (mechanics phrasing).
- **Rejected alternatives:**
  - Allow unsourced synthesized claims by default — rejected because it makes the report unfalsifiable and defeats the adversarial-validation step. ([D23](#d23-evidence-requirement-override-and-explicit-evidence-labeling) later added a controlled exception: unsourced reasoning is permitted only when the operator explicitly opts into exploratory mode, only when explicitly labeled as unevidenced, and never as the basis of the recommendation in the default strict mode.)
  - Treat "carries a source URL" as sufficient verification — rejected because a crafted page satisfies it trivially and launders a false claim into an authoritative recommendation (F5).
  - Trust operator-provided material above independent sources — rejected because it turns the report into a laundered version of what the operator already believed (F13).
- **Linked technical notes:** —
- **Driven by findings:** F5, F12, F13, F15, F22
- **Dependent decisions:** D16, D23
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes, Coordinations

### D15: Research sizing signals

- **Question:** What signals classify a research question as small, medium, or large? Han's code-change sizing signals (file count, subsystems) do not translate to "how does X work".
- **Decision:** Scope is read from the question's conceptual shape, not its text length: the number of distinct viable approaches in play, the number of separate technical domains the question spans, and the breadth of reach required (codebase only, vs. codebase plus open web plus provided material). Small ≈ one domain, few or no competing options, narrow reach; medium ≈ two-to-three domains or several competing options or codebase-plus-web reach; large ≈ many options across multiple domains or an explicit operator request for full breadth. The assigned size and a one-line scope statement are shown before dispatch so a misread is catchable.
- **Rationale:** Primary Flow commits to a sizing step; without research-specific signals the SKILL.md author would invent them and diverge from Han's sizing philosophy. The signals are stated behaviorally, leaving calculation to implementation.
- **Evidence:** `docs/sizing.md` (existing band model); F1 (sizing signals undefined — flagged the single highest-priority gap); F8/edge-case (auto-misclassification of large-as-small).
- **Rejected alternatives:**
  - Reuse the code-change signals verbatim — rejected because file/subsystem counts do not map to open-ended questions (F1).
  - Leave the signals to `plan-implementation` — rejected because the SKILL.md author inventing them risks inconsistent runs (F1).
- **Linked technical notes:** —
- **Driven by findings:** F1
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes

### D16: Untrusted source handling

- **Question:** What behavioral controls contain untrusted web content, which D3 makes a first-class input?
- **Decision:** Three controls. (1) Content fetched from the open web is treated as claims to evaluate, never as instructions to follow; directive-style language inside fetched material is recorded as a claim, not acted on. (2) Agents working the open-web angle do not receive codebase contents or operator context in their briefs; findings are aggregated by source so external content cannot pull repository material into its reach. (3) Web-sourced and operator-provided third-party evidence is structurally distinguished in the report as carrying a different trust level than codebase-anchored evidence.
- **Rationale:** D3's web reach widens a trust boundary the spec previously did not acknowledge: arbitrary third-party content becomes an input. Without these controls a crafted page can inject instructions into sub-agents, exfiltrate repository contents via a research run, or launder a claim into an authoritative recommendation. The controls are behavioral policy commitments, not sanitizer/library choices.
- **Evidence:** [../recommendation.md](../recommendation.md) Final recommendation constraint 1 (web reach); F4 (indirect prompt injection); F6 (context exfiltration); F7 (web evidence is a distinct trust class); D3.
- **Rejected alternatives:**
  - Rely on D11's "unverifiable claim cannot be sole basis" alone — rejected because it addresses evidential weight, not instruction/data confusion or context isolation (F4, F6).
  - Share one combined context across the web and codebase angles — rejected because it lets fetched content reach repository material (F6).
- **Linked technical notes:** —
- **Driven by findings:** F4, F6, F7
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes, Coordinations

### D17: Compound question handling

- **Question:** What does `/research` do when one invocation bundles several independent research threads?
- **Decision:** When the question contains more than one independent research thread (threads that would each produce their own options landscape), the skill names the threads, asks the operator which to run first, and defers the rest rather than merging them into one report.
- **Rationale:** Merging independent threads silently conflates evidence and recommendations across them — each recommendation appears supported by another thread's evidence, a confidently wrong report with no signal to the operator. Naming-and-deferring is simpler than a multi-question mode.
- **Evidence:** F9 (compound question unhandled — systemic severity).
- **Rejected alternatives:**
  - Merge all threads into one landscape — rejected because it conflates evidence-to-recommendation alignment (F9).
  - Build a multi-question mode — rejected as more than the evidence requires; the simpler name-and-defer rule satisfies it (F9).
- **Linked technical notes:** —
- **Driven by findings:** F9
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### D18: Hybrid request classification

- **Question:** How does `/research` classify a request that is part research, part a sibling's output?
- **Decision:** If an answerable open-ended research question remains once the sibling-output request is set aside, the skill runs the research portion to a full report and names the sibling for the rest. If nothing research-shaped remains, it redirects entirely without running the pipeline.
- **Rationale:** The output rule (D8/D10) said what to produce but not how to classify the boundary; without a stated rule the same hybrid question routes differently on re-runs, eroding trust. The strip-the-sibling-request test is a deterministic, behavioral rule.
- **Evidence:** F10 (hybrid classification rule missing); [../recommendation.md](../recommendation.md) Option A row 4 / V6 (boundary-collision risk).
- **Rejected alternatives:**
  - Leave the classification implicit in D8/D10 — rejected because it produces nondeterministic routing across runs (F10).
- **Linked technical notes:** —
- **Driven by findings:** F10
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

### D19: Re-run and output collision guard

- **Question:** What happens when `/research` is re-run, or when the output path already holds a report?
- **Decision:** If an output path is given and a report already exists there, the skill asks whether to overwrite it or write elsewhere before doing any work. The default no-path location does not collide with a prior run. No diff-the-prior-report capability is built (deferred under YAGNI).
- **Rationale:** Re-running the same question over time is the exact use case the "recommend without committing" framing anticipates; silent overwrite of a previously accepted report is data loss. A collision guard is the strictly simpler version that satisfies the same evidence as change-tracking.
- **Evidence:** F14 (re-run / output overwrite — data-corruption severity); `/investigate` writes to a plan path (analog).
- **Rejected alternatives:**
  - Silently overwrite the existing path — rejected because it destroys a previously accepted recommendation with no warning (F14).
  - Build prior-report diffing — deferred under YAGNI; the guard satisfies the same evidence (F14; see spec Deferred section).
- **Linked technical notes:** —
- **Driven by findings:** F14
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes

### D20: Rollout plan

- **Question:** How is the cross-skill rollout (counts, sizing docs, reciprocal routing) handled, given the corrected ~14+ file cost?
- **Decision:** The rollout is accepted as owned by `plan-implementation`, which will turn it into an explicit file-by-file checklist. The known cost is ~14+ file changes: reciprocal "Does not — use `/research`" routing in each of the five neighbors' SKILL.md *and* long-form docs (kept in sync), plus the count/sizing surfaces — the skill count and "Counts to verify" line in `CLAUDE.md`, the count in `README.md`, the skill count and "sizing-aware skills" count in `docs/concepts.md`, the named sizing-skill list and table in `docs/sizing.md`, and the grouping in `docs/skills/README.md`. This is a rollout task, not a behavioral unknown, so it does not block.
- **Rationale:** The user accepted the recommended approach: keep the file-by-file work in `plan-implementation` while recording the corrected cost and the enumerated surfaces here so it is not rediscovered. Resolves former OI-1.
- **Evidence:** User input (this conversation, "use your recommendation for OI-1"); [../recommendation.md](../recommendation.md) Final recommendation constraint 3 and V8 (~14+ corrected figure); F17, F18.
- **Rejected alternatives:**
  - Enumerate the full file-by-file checklist in the spec now — rejected because it is implementation detail that belongs to `plan-implementation`, not a behavior of the skill.
- **Linked technical notes:** —
- **Driven by findings:** F17, F18
- **Dependent decisions:** —
- **Referenced in spec:** Out of Scope, Open Items, Summary

### D21: Skills-index grouping

- **Question:** Which skills-index category does `/research` belong to, given none of the existing groupings fits cleanly?
- **Decision:** Group `/research` next to `/investigate` under a relabeled "Investigation & research" grouping in `docs/skills/README.md`. Both are evidence-plus-adversarial-validation deep dives; `/investigate` runs symptom→fix, `/research` runs question→options.
- **Rationale:** The user accepted the recommended grouping. It places the two structurally-parallel deep-dive skills together and gives operators one obvious place to look for either. Resolves former OI-2.
- **Evidence:** User input (this conversation, "use your recommendation for OI-2"); `docs/skills/README.md` existing groupings; F19.
- **Rejected alternatives:**
  - Place `/research` under "Discovery & context" — rejected because that grouping holds repository-scan skills, not open-ended research.
  - Add a standalone single-skill category — rejected because it fragments the index and obscures the `/investigate` ↔ `/research` parallel.
- **Linked technical notes:** —
- **Driven by findings:** F19
- **Dependent decisions:** —
- **Referenced in spec:** Open Items, Summary

### D22: Skills calling skills

- **Question:** Does the skills-calling-skills guidance contradiction affect `/research`, and what is the recommended pattern (OI-3 / recommendation V3)?
- **Decision:** `/research` invokes no skills: it dispatches agents via the Agent tool and "routes to a sibling skill" by naming the sibling in its output, not by calling it via the Skill tool. It therefore already complies with the recommended consistent pattern (Agent-tool dispatch + inline discovery, never Skill-tool sub-calls), and OI-3 poses essentially zero risk to this skill. The eventual SKILL.md `allowed-tools` must not include `Skill` — the single build-time check. The broader six-file guidance contradiction is real and unresolved but is a separate Han maintenance item (ADR-worthy, evidence-led: keep the well-evidenced data-fetch ban; orchestration is underdetermined, not proven broken), and does not block this build.
- **Rationale:** A full `/investigate` run with adversarial validation found the data-fetch sub-skill failure well-evidenced, the orchestration ban unsupported, and — decisively for this spec — that `/research`'s routing is naming, not invoking (validation V8). The safe pattern is recommended for the positive reason that 17/18 skills already use Agent dispatch with no open reliability question, not because orchestration is proven to fail.
- **Evidence:** [skills-calling-skills-investigation.md](skills-calling-skills-investigation.md) (E1–E9, V1–V8); user request (resolve OI-3 via `/investigate`, this conversation); [../recommendation.md](../recommendation.md) V3 housekeeping note.
- **Rejected alternatives:**
  - Treat `skill-composition.md`'s blanket ban as authoritative as-is — rejected: adversarial validation showed the orchestration half is an unsupported assertion contradicted by three same-commit statements (V1, V4).
  - Recommend migrating `gh-pr-review` off the Skill tool as a known-broken pattern — rejected: no documented failure exists; the keep-vs-migrate call is handed to maintainers (V5).
  - Leave OI-3 open as a blocker — rejected: the `/research`-relevant answer is robust (V8); the residual contradiction is a separate, non-blocking maintenance item.
- **Linked technical notes:** —
- **Driven by findings:** F20
- **Dependent decisions:** —
- **Referenced in spec:** Open Items, Summary

### D23: Evidence requirement, override, and explicit evidence labeling

- **Question:** "Research" implies evidence-based. Should evidence be a hard requirement, and can the operator trade rigor for freedom?
- **Decision:** Evidence is required by default ("strict" mode): the [D11](#d11-verifiable-evidence-sourcing) corroboration rule governs, and unevidenced reasoning may not be the basis of the recommendation. The operator may explicitly opt into an "exploratory" mode (evidence-optional) that lets the skill include reasoned or speculative analysis not tied to a source, giving it more freedom in its research. In **both** modes the report must explicitly state what does and does not have evidence: every claim is labeled as corroborated evidence, single-source (caveated), or unevidenced reasoning; and the recommendation explicitly states its evidence basis — which parts rest on corroborated evidence, which on single sources, and which (exploratory mode only) on reasoning. The default is strict; the operator opts out per invocation with an explicit phrase such as "evidence optional", "allow unsourced", or "exploratory".
- **Rationale:** The word "research" carries an evidence-based expectation, so evidence is the default requirement, not an option. But an operator may consciously want broader, more speculative exploration and can trade rigor for freedom — provided the report never blurs which conclusions are evidenced and which are reasoned. The labeling requirement is unconditional precisely so the trade is always visible.
- **Evidence:** User input (this conversation, evidence-requirement-and-override directive); builds on [D11](#d11-verifiable-evidence-sourcing) (verifiable sourcing) and [D7](#d7-adversarial-validation-target) (validation attacks evidence integrity).
- **Rejected alternatives:**
  - Evidence always mandatory with no override — rejected by the user, who wants the option of more research freedom when consciously chosen.
  - Evidence always optional (no default requirement) — rejected: "research" implies evidence-based; rigor is the default, not an opt-in.
  - Allow exploratory mode without explicit labeling — rejected: the report must never blur evidenced vs. reasoned conclusions, regardless of mode.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes, User Interactions, Summary

### D24: Report output structure

- **Question:** What is the fixed output structure of a research report, so every run is consistent and the evidence is fully traceable?
- **Decision:** Every research report follows one fixed structure, top to bottom: (1) a plain-language **Summary** at the very top — the answer in brief, no jargon; (2) **Research Results** — the relevant findings with minimal technical detail, every claim cross-referencing the artifacts it rests on by ID; (3) **Options to Consider** — present only when the question implies discrete alternatives, an indexed list (`O1, O2, …`) with each option's trade-offs, evidence-status label, and artifact cross-references; (4) **Recommendation** — the recommended option (or "no clear winner" with deciding criteria) and its explicit evidence basis per [D23](#d23-evidence-requirement-override-and-explicit-evidence-labeling); (5) **Validation** — the `V#` adversarial findings; (6) **Artifacts** — an indexed registry (`A1, A2, …`) of every information source used that is relevant to the results, each entry carrying a link or repository location, retrieval date for web sources, a short plain-language summary, its trust class per [D16](#d16-untrusted-source-handling), and its corroboration/evidence status per [D11](#d11-verifiable-evidence-sourcing)/[D23](#d23-evidence-requirement-override-and-explicit-evidence-labeling); (7) a **References** section at the very bottom that points to every artifact and its original source for full traceability. Artifact IDs (`A#`) are cross-referenced inline throughout Results, Options, and Recommendation so every conclusion traces to its sources. All research includes the Artifacts and References sections — they are never omitted, even for a minimal run.
- **Rationale:** "Research" output is only trustworthy if a reader can see the conclusion in plain language first, then trace every claim back to a summarized, linked source and finally to the original. A single fixed structure makes every run consistent and the evidence auditable end to end. This mirrors the progressive-disclosure information architecture already proven in `/gap-analysis` (plain-language summary first, indexed stable IDs, technical fidelity quarantined lower down).
- **Evidence:** User input (this conversation, output-format directive); `/gap-analysis` report IA precedent (`plugin/skills/gap-analysis/references/gap-analysis-report-template.md`, four-section progressive disclosure with stable `G-NNN` IDs); builds on [D11](#d11-verifiable-evidence-sourcing), [D16](#d16-untrusted-source-handling), [D23](#d23-evidence-requirement-override-and-explicit-evidence-labeling).
- **Rejected alternatives:**
  - Free-form report shape per run — rejected: the user requires a consistent output format with guaranteed traceability.
  - Sources listed only once at the bottom — rejected: the user requires both an inline-cross-referenced Artifacts registry with summaries and a formal References section at the very bottom.
  - Omit Artifacts/References for small runs — rejected: all research must include artifacts and references, regardless of size.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, User Interactions, Summary
