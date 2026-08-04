# Implementation Decision Log: Project-Local Han Configuration

<!--
This file records every implementation decision committed while planning Project-Local Han Configuration.
Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md) --
this file captures the question, rationale, evidence, and rejected alternatives for each decision.
Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).

D-N numbers in this file are IMPLEMENTATION decisions. They are distinct from the spec's D1-D15
(kept in ../decision-log.md). Spec decisions are cited here as "spec D5", "spec D14", and so on.
-->

## Trivial decisions

- D-12: Skill and agent edits follow the han-plugin-builder guidance — every SKILL.md and agent change made for this feature is authored against `han-plugin-builder/skills/guidance/references/`, as the repo CLAUDE.md mandates for all skill and agent changes. — Referenced in plan: Constraints and Boundaries; Work Units and Sequencing.
- D-13: The annotated schema example is authored only after the tokens are pinned — `docs/configuration.md` and its single annotated example are written after the schema tokens in D-4 are fixed, so the example cannot show a key name that later changes. — Referenced in plan: Work Units and Sequencing.

## Full decisions

### D-1: Probe line stays inline in every SKILL.md; only the interpretation prose is factored

- **Question:** Can the whole config-resolution feature be factored into one shared file that skills link to, or must something land inside each participating SKILL.md?
- **Decision:** The one-line config read stays inline in each participating SKILL.md, inside a `## Project Context` block, matching the existing `!`-probe convention. Only the interpretation of what is read (precedence, degradation and the one-line-note rule, containment, the extra-agent pool-join) is a candidate for a shared file.
- **Rationale:** Claude Code executes a `!`-backtick probe in place, at prompt-assembly time, from the skill's own working directory. A probe moved into an included reference file would never run. So the read is structurally forced to be inline, one bullet per file, and the plan must land a bullet in every participating SKILL.md rather than zero. The committed mechanics in spec T1 already commit to this same inline pattern (`cat .han/config.md 2>/dev/null`).
- **Evidence:**
  - Codebase: `han-coding/skills/code-review/SKILL.md:16-20` (the inline `!`-probe block).
  - Spec technical note T1 (`../feature-technical-notes.md`), which commits the read to the identical mechanism.
  - Round 1 structural-analyst finding S1 and junior-developer finding JD-001, independently reaching the same conclusion (claim C1).
- **Rejected alternatives:**
  - Factor the entire feature (read and interpretation) into one file skills reference — rejected because a `!`-probe cannot execute from an include; the read must be inline (S1).
- **Specialist owner:** Han contributor editing SKILL.md files.
- **Revisit criterion:** Claude Code gains a mechanism that lets an included reference file execute a probe on behalf of the referencing skill.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-2, D-7
- **Referenced in plan:** Implementation Approach; Work Units and Sequencing

### D-2: One canonical config-resolution rule file in han-core, vendored byte-identical per plugin

- **Question:** Where does the shared interpretation prose (precedence, degradation, note rule, containment, pool-join) live, given three plugins are designed to depend on nothing?
- **Decision:** One canonical rule file, `han-core/references/config-rule.md`, carries the interpretation contract. It is vendored byte-identical into the `references/` folder of every plugin that carries a SKILL.md (the twelve: han-communication, han-core, han-documentation, han-research, han-planning, han-coding, han-github, han-reporting, han-feedback, han-atlassian, han-linear, han-plugin-builder). The file carries the schema tokens (D-4), the spec D6 precedence chain, the spec D9 degradation and one-line-note rule, the spec D14 containment test (D-5), the spec D15 working-directory rule, and the spec D5 pool-join rule.
- **Rationale:** The interpretation is multi-paragraph and must be applied identically by every participating skill, so it needs one canonical home rather than a paraphrase per file. Vendoring copies (the `yagni-rule.md` precedent) needs no manifest change. The alternative, cross-plugin skill invocation (the `readability-rule.md` precedent), would force new dependency edges onto han-feedback, han-linear, and han-plugin-builder, contradicting their documented depends-on-nothing design.
- **Evidence:**
  - Codebase precedent: `han-core/references/yagni-rule.md` and `han-core/references/evidence-rule.md` vendored byte-identical into five plugins (md5-identical copies).
  - `CONTRIBUTING.md:202-205`, which documents the dependency-edge carve-out that keeps han-linear and han-feedback edge-free.
  - The three `plugin.json` files (`han-feedback`, `han-linear`, `han-plugin-builder`) carry no `dependencies` key.
  - Round 1 findings S2, S3, JD-001, IA-003 (claim C2); resolved in Round 2 as OQ-1.
- **Rejected alternatives:**
  - Cross-plugin skill invocation of one canonical file (the readability pattern) — rejected because it forces new dependency edges onto three plugins deliberately designed to depend on nothing (S2; `CONTRIBUTING.md:202-205`).
  - Pure inline duplication of the interpretation in every SKILL.md — rejected because the note-rule boundary (spec D9) and precedence chain must stay byte-identical across files, and the documented SKILL.md churn would drift the copies (JD-008, IA-003).
- **Specialist owner:** Han contributor; structural boundary owned against structural-analyst guidance.
- **Revisit criterion:** A future feature needs a dependency-free plugin to consume the contract through skill invocation rather than a vendored copy, or the vendored copies are observed to drift (see D-3).
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** D-3, D-4, D-5, D-9
- **Referenced in plan:** Implementation Approach; Work Units and Sequencing

### D-3: Keep the vendored rule file short and mechanical; defer sync tooling

- **Question:** With twelve vendored copies and no sync mechanism in the repo, how is drift between copies kept manageable?
- **Decision:** Keep `config-rule.md` short and mechanical (the precedence order, the note format, the containment test, the pool-join sentence, the schema tokens) so an eyeball diff during any future edit is cheap. No automated sync tool or diff checker is built now.
- **Rationale:** Twelve copies is more drift-prone than the existing five-copy `yagni-rule.md` precedent, and the repo has no tool that diffs vendored copies between Han's own plugins. A short, mechanical file keeps twelve copies close to as cheap to keep synced as five were. Sync tooling has no evidence forcing it today and fails the YAGNI evidence test.
- **Evidence:**
  - Codebase: the only vendoring script in the repo, `han-plugin-builder/skills/guidance/scripts/init-guidance.sh`, copies into external consuming repos, not between Han's own plugins; the five `yagni-rule.md` copies stay synced by manual convention.
  - Round 1 structural-analyst finding S3 (claim C2/C3).
- **Rejected alternatives:**
  - Add a diff checker or documentation-sweep step that compares vendored copies — deferred because no drift has been observed and the machinery fails the YAGNI evidence test today (S3).
- **Specialist owner:** Han contributor.
- **Revisit criterion:** Drift is observed between vendored copies after landing.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach; Deferred (YAGNI); Risks and Assumptions

### D-4: Pin the config schema tokens

- **Question:** What are the exact schema tokens spec T1 left open (the output-base key, the extra-agents section heading, and the agent-name matching rule)?
- **Decision:** The frontmatter key for the output base is `output-directory`. The extra-agents section heading is `## Extra Agents`. Entries are one agent per list line, accepted in qualified `plugin:agent` form or bare-name form, matched case-insensitively against the agents available in the session. An entry that does not resolve is skipped with the spec D5 one-line note.
- **Rationale:** The tokens come from T1's own wording and suite convention. T1 names "an output-directory key," so the key is `output-directory`. The roster tables already use qualified names like `han-research:research-analyst`, so the matching rule accepts qualified names; accepting the bare name too keeps hand-authoring forgiving. Case-insensitive matching against session-available agents follows spec D5's session-availability reading. These tokens are fixed once and reused verbatim in every skill and in the canonical rule file, so no two copies disagree on a key name.
- **Evidence:**
  - Spec technical note T1, which names "an output-directory key" and defers exact tokens to implementation planning.
  - Codebase: `han-research/skills/research/SKILL.md:141` uses the qualified `han-research:research-analyst` form.
  - Spec D5, which validates entries against session availability.
  - Round 1 findings JD-005 and F8; resolved in Round 2 as OQ-5 (claim C3).
- **Rejected alternatives:**
  - Leave matching to per-skill interpretation — rejected because 39 skills interpreting name-matching independently would resolve the same config file differently (JD-005, JD-008).
  - Accept only qualified `plugin:agent` names — rejected because hand-authored files will carry bare names; the forgiving reading serves the feature's purpose (spec D5).
- **Specialist owner:** Han contributor.
- **Revisit criterion:** A real config file needs a token the pinned set cannot express (for example a second scalar override), which lands under spec D7's room-to-grow format.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** D-10, D-13
- **Referenced in plan:** Implementation Approach; Work Units and Sequencing

### D-5: Output-directory containment test

- **Question:** What concrete, prompt-expressible rule keeps the output base inside the project, given spec D15 declined to define a repo root and git is optional?
- **Decision:** The output-directory value must be a relative path. Reject absolute paths and any path whose normalized form escapes the working directory: a leading slash, a drive prefix, or `..` traversal above the working directory. Resolve an accepted value relative to the working directory. A rejected value falls back to the skill's default output location with the spec D9 one-line note.
- **Rationale:** The rule is expressible in prompt text with no repo-root or git concept, which matters because spec D15 pins discovery to the working directory and code-review has a git-absent mode. It matches spec D14's accident-not-adversary intent: it guards against a pasted absolute path or a stray leading slash, not an attacker.
- **Evidence:**
  - Spec D14 (containment intent) and spec D15 (working-directory basis).
  - Finding F4, which recorded that "project root was never defined behaviorally"; codebase `han-coding/skills/code-review/SKILL.md:93-94` (git-absent Mode C).
  - Round 1 finding JD-004; resolved in Round 2 as OQ-4 (claim C7).
- **Rejected alternatives:**
  - Derive a repo root from git and test containment against it — rejected because git is optional (code-review Mode C) and spec D15 declined to define a repo root (JD-004).
- **Specialist owner:** Han contributor.
- **Revisit criterion:** A real project needs an output base outside the working directory, which would reopen spec D14's containment intent.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach; Definition of Done

### D-6: Wrapper skills pass explicit output paths, so spec D6 keeps temp files in place

- **Question:** When a han-atlassian wrapper invokes a wrapped skill "to a temporary file," does the wrapped skill's honoring of the output base relocate that file away from where the wrapper expects it?
- **Decision:** No relocation. Spec D6 already answers it: explicit input outranks the config file. A wrapper that directs its wrapped skill to write to a temporary path is giving explicit output instructions, which win over the configured base. The wrapper skills' briefs pass an explicit path when they invoke a wrapped skill.
- **Rationale:** All six han-atlassian skills are wrappers, and all six are in the set gaining a config-only block, so the wrapped skill (for example `investigate`) will participate and honor the base unless told otherwise. Spec D6's precedence chain settles the interaction with no new behavior: the explicit path the wrapper passes is the top tier of the chain.
- **Evidence:**
  - Spec D6 (precedence: explicit input first).
  - Codebase: `han-atlassian/skills/investigate-to-confluence/SKILL.md:22-23,55` (invokes `han-coding:investigate` "to a temporary file").
  - Round 1 finding JD-003; resolved in Round 2 as OQ-3 (claim C6).
- **Rejected alternatives:**
  - Add a wrapper-specific bypass rule so wrapped temp files ignore the base — rejected because spec D6 already covers it through explicit input; a new bypass rule is redundant machinery (OQ-3 resolution).
- **Specialist owner:** Han contributor editing the han-atlassian wrapper skills.
- **Revisit criterion:** A wrapper is found that invokes a wrapped skill without passing an explicit path, so the wrapped file lands under the configured base unexpectedly.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach; Work Units and Sequencing

### D-7: Three work passes; the fifteen no-block skills get a minimal config-only block

- **Question:** How is the suite-wide edit scoped across the participating skills, and what block do the skills without a `## Project Context` block get?
- **Decision:** Three separate passes. First, the skills that already carry a `## Project Context` block get one new probe bullet plus a pointer to the canonical rule file. Second, the skills without a block get a minimal config-only block carrying just the `.han/config.md` probe line and the pointer, not the full git/CLAUDE.md/discovery probe set. Third, the dispatching skills get a bespoke per-skill pool-join edit into their own roster tables, as its own work unit, reusing each skill's own cap vocabulary.
- **Rationale:** The skills without a block mostly do not resolve CLAUDE.md or discovery context today because their work does not need it, so giving them the full probe set would add probes with no spec D6 tier to consult them against, an unjustified addition. The dispatching-skill roster tables are shaped differently per skill, so the pool-join is a bespoke insertion, not a uniform pasted block; unifying the roster tables is unrelated, larger surgery with no evidence behind it.
- **Evidence:**
  - Round 1 structural-analyst findings S5 (minimal block) and S6 (bespoke pool-join); junior-developer JD-002.
  - Codebase: `han-research/skills/research/SKILL.md:139-169` (a roster shape) versus other skills' differing shapes.
  - Resolved in Round 2 as OQ-2 (claims C4, C5).
- **Rejected alternatives:**
  - Give all fifteen no-block skills the full existing `## Project Context` block — rejected because it adds git/CLAUDE.md/discovery probes those skills have no spec D6 tier to use (S5, YAGNI evidence test).
  - Fold the pool-join into the probe-block pass as "add one line to N files" — rejected because each roster table is shaped differently, so the estimate would under-scope the bespoke work (JD-002, S6).
  - Unify the roster tables into one shared format as part of this feature — deferred as unrelated larger surgery with no evidence (S6).
- **Specialist owner:** Han contributor.
- **Revisit criterion:** A future feature needs one canonical roster-table format across dispatching skills.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** D-8, D-9
- **Referenced in plan:** Implementation Approach; Work Units and Sequencing; Deferred (YAGNI)

### D-8: Enumerate participating skills at execution time; never hardcode totals

- **Question:** How does the plan name which skills participate, given spec D4's stated counts are stale?
- **Decision:** Enumerate participating skills at execution time by globbing `*/skills/*/SKILL.md`. Never hardcode a total. Spec D4's stated 26-with and 15-without counts are stale against today's tree (24 with a block and 15 without, of 39), and the counts drift as the suite changes.
- **Rationale:** The repo convention is count-free (indexes stay complete, not counted), and hardcoding a stale 26 would misdirect the edit. Globbing at execution time picks up the current tree whatever it holds when the work runs.
- **Evidence:**
  - Repo CLAUDE.md convention: "indexes stay complete, not counted."
  - Discovery notes and grep: `*/skills/*/SKILL.md` returns 39 (24 with a `## Project Context` block, 15 without); spec D4 states 26/15.
  - Round 1 junior-developer finding and discovery notes (claim C12).
- **Rejected alternatives:**
  - Inherit spec D4's 26/15 counts into the plan — rejected because they are stale against the tree and the repo convention forbids hardcoded totals (C12).
- **Specialist owner:** Han contributor.
- **Revisit criterion:** None; the count-free convention is a standing repo rule.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-9
- **Referenced in plan:** Constraints and Boundaries; Work Units and Sequencing; Definition of Done

### D-9: Definition of done is a grep completeness check plus representative spot-runs

- **Question:** With no test harness, how is a 39-file edit verified as done?
- **Decision:** Two checks. A grep-based completeness check confirms every participating SKILL.md carries the probe line and the pointer, every plugin carries the vendored rule file, and the vendored copies are byte-identical to the canonical file. Then a manual spot-run of one representative skill per category (a deliverable-writer, a dispatcher, a wrapper, and a config-irrelevant skill), each run against a present, an absent, and a broken config. No CI, test runner, or fixture repo is built.
- **Rationale:** The repo has no automated test harness for skills, so verification is grep plus manual runs. The grep check proves structural completeness across all files; the spot-runs prove the behavior in each category actually works against the three config states. New CI or fixtures fail the YAGNI evidence test today.
- **Evidence:**
  - Discovery notes: no CI or test harness runs skills; verification is manual.
  - Spec D4's uniform-participation promise (every skill must carry the read).
  - Round 1 junior-developer finding JD-006; resolved in Round 2 as OQ-6 (claim C8).
- **Rejected alternatives:**
  - Build a CI job, test runner, or fixture repo to verify the edit — deferred because no config-drift regression has been observed and the machinery fails the YAGNI evidence test today (JD-006).
- **Specialist owner:** Han contributor.
- **Revisit criterion:** A config-drift regression is observed after landing.
- **Dissent (if any):** None.
- **Driven by rounds:** R1, R2
- **Dependent decisions:** —
- **Referenced in plan:** Definition of Done; Testing Strategy; Deferred (YAGNI)

### D-10: One canonical operator doc at docs/configuration.md, plus scent links

- **Question:** What documentation does the feature need, given Han cannot seed the config file and an engineer has no correct source to author from?
- **Decision:** Add one canonical operator doc, `docs/configuration.md`, as the single home of the annotated schema example and the plain-language contract (what the file is and who writes it, the two v1 overrides, the precedence chain, the degradation contract, the working-directory and monorepo rule). Add a scent link and a "Where to go next" entry in `docs/concepts.md`, one bullet in quickstart Path D, and register the new doc and the canonical contract home in the repo CLAUDE.md. Update `han-core/skills/project-discovery/SKILL.md` and its long-form doc `han-core/docs/skills/project-discovery.md` for the spec D10 pointer behavior. Do not sweep all ~39 skill long-form docs, and skip `docs/choosing-a-han-plugin.md`, `docs/workflows.md`, and the four mechanic docs.
- **Rationale:** Han cannot seed the file, so an engineer with no canonical doc guesses the frontmatter key and lands in spec D9's silent-degradation path. The four existing cross-suite mechanics each have a repo-root concept doc and a concepts.md entry, so a config convention every skill honors on every run needs the same slot. Per-skill docs do not re-document a cross-suite mechanic, so a blanket sweep of 39 skill docs has no named need and is cut. project-discovery is the one skill whose documented behavior materially changes (it gains the pointer offer).
- **Evidence:**
  - Codebase precedent: `docs/sizing.md`, `docs/yagni.md`, `docs/evidence.md`, `docs/readability.md`, each introduced in `docs/concepts.md`.
  - `han-core/docs/skills/project-discovery.md`, which currently omits the spec D10 pointer behavior.
  - Spec Out of Scope: Han cannot ship or seed the file (`../feature-specification.md`).
  - Round 1 information-architect findings IA-001, IA-002, IA-004, IA-005, IA-006, IA-007, IA-008, IA-009 (claims C10, C11).
- **Rejected alternatives:**
  - Put the schema example in each participating skill's doc — rejected because 39 copies would drift and the repo enforces single-source for shared rules (IA-002).
  - Sweep a config note into all ~39 skill long-form docs — deferred because per-skill docs do not re-document cross-suite mechanics and no named task needs the same sentence in 39 places (IA-006).
  - Update `docs/choosing-a-han-plugin.md` and `docs/workflows.md` — deferred because the config is not a plugin and adds no chain step (IA-009).
- **Specialist owner:** Han contributor; information-architect guidance owns the doc structure.
- **Revisit criterion:** A specific skill's config interaction is genuinely non-obvious (reopens the per-skill doc note); the config becomes install-gated (reopens choosing-a-han-plugin.md); a workflow's documented output path becomes misleading (reopens workflows.md).
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-13
- **Referenced in plan:** Implementation Approach; Work Units and Sequencing; Deferred (YAGNI)

### D-11: project-discovery gains a pointer step reusing its consent and dedup pattern

- **Question:** Where does spec D10's CLAUDE.md pointer offer and stale-cleanup behavior fit in the project-discovery skill?
- **Decision:** Add a new step to `han-core/skills/project-discovery/SKILL.md` between the existing write step and the verification step. It checks for `.han/config.md`, checks for an existing pointer in the target file, and uses the same `AskUserQuestion`-gated consent and dedup baseline the skill already carries. It offers to add a one-line pointer when the file exists and no reference is present, and offers to remove a stale pointer when the file is gone. No new skill or reference file is created.
- **Rationale:** The skill already has the exact shape spec D10 needs: a dedup baseline against the target file and a consent-gated write. The pointer is a distinct concern from the Project Discovery section (it targets a line beside that section and has its own presence lifecycle), so it fits as its own step rather than folded into the write step. No new abstraction is justified; spec D10 is the only evidence needed.
- **Evidence:**
  - Codebase: `han-core/skills/project-discovery/SKILL.md:72-106` (the existing write step with dedup and consent, then verification).
  - Spec D10 (the pointer offer and stale-cleanup behavior).
  - Round 1 structural-analyst finding S7 (claim C13).
- **Rejected alternatives:**
  - Fold the pointer logic into the existing write step — rejected because the pointer targets a different location and has an independent presence lifecycle, making it a distinct concern (S7).
  - Create a new skill or reference file for the pointer — rejected because the existing step sequence already carries the consent and dedup pattern; no new abstraction is justified (S7).
- **Specialist owner:** Han contributor editing project-discovery.
- **Revisit criterion:** The pointer behavior grows beyond a one-line add and remove, needing its own reusable component.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach; Work Units and Sequencing
