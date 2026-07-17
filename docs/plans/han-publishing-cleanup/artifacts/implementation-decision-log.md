# Implementation Decision Log: Han Publishing Cleanup — Phase 3

<!--
This file records every implementation decision committed while planning phase 3
("Make a release bring every publishing target up to date"). Behavioral and
implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md) —
this file captures the question, rationale, evidence, and rejected alternatives for
each decision. Round-by-round history lives in
[implementation-iteration-history.md](implementation-iteration-history.md).

The D-N counter is shared across the trivial and full sections. Cross-referencing
invariants (Driven by rounds / Dependent decisions / Referenced in plan) are kept in
sync with the plan and the iteration history.
-->

## Trivial decisions

- D-14: Match cross-target on plugin `name`, never the listing's `source` path — every cross-target join (record to listing entry, gap to plugin) keys on the plugin `name`, following the precedent the release skill already sets at `SKILL.md:236`. — Referenced in plan: Implementation Approach (Runtime Behavior).
- D-19: Add the script to `allowed-tools` — add `Bash(./scripts/publishing-targets.sh:*)` to the `han-release` frontmatter so the skill can invoke the check without a permission prompt; one line, costs nothing if it turns out unnecessary ([OQ-A](implementation-iteration-history.md#r1--parallel-specialist-review)). — Referenced in plan: Implementation Approach (Architecture and Integration Points).
- D-21: Report both created and changed targets — Steps 7 and 10 report what the release created and what it changed per plugin and target, alongside the version plan, implementing spec D39; a created channel-two listing entry names no version (see D-7). — Referenced in plan: Implementation Approach (Runtime Behavior), Definition of Done.

## Full decisions

### D-1: The publishing writes are script-borne

- **Question:** Should the four-target repair, creation, and gap logic live in the release skill's prose, or in an executable script?
- **Decision:** Create one script, `scripts/publishing-targets.sh`, at the **repository root**, exposing two argument-free verbs: `check` (report gaps) and `repair` (bring the writable targets up to date). The release skill invokes it rather than restating its rule.
- **Rationale:** Spec D14 ("the release runs the check rather than restating it") already commits to one rule with one bearer shared with phase 6. Two independent specialist reviews converged on the same call from opposite directions (C1 from the DevOps side, C20 from the testability side): the testable boundary is exactly D14's line — queries and writes are script-testable, prose is not. Root placement (not inside a `han-*/` plugin) is forced by three facts: it is repo maintenance, not any plugin's shipped behavior; a copy inside `han-*/` ships dead weight to installers and makes every fix bump a version the check itself polices; and three callers (the release skill, phase 6's CI step, the optional prek hook) live in three trees. Root placement has verified-free consequences: the ShellCheck hook has no `files` filter so a root script is covered automatically, and the shebang hook is satisfied by `chmod +x` in the same commit.
- **Evidence:** Spec D14 (`feature-specification.md:274-275`); `check-annotations.sh` precedent (multi-input, names every finding at once, one bearer with two callers); iteration-history C1, C20, OQ-B; `.pre-commit-config.yaml:24-27,49-50` (ShellCheck has no `files` filter; shebang-executable hook).
- **Rejected alternatives:**
  - Rule restated in SKILL.md prose — rejected because it puts the bundle exception in two places and violates D14 at the write step (C1); and prose cannot be tested (C20).
  - Script inside a `han-*/` plugin directory — rejected because it ships to installers as dead weight and every fix bumps a version the check polices (OQ-B).
- **Specialist owner:** devops-engineer.
- **Revisit criterion:** A fourth caller appears whose needs the two argument-free verbs cannot serve, or the root script is found to conflict with a lint/hook path filter.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-2, D-3, D-5, D-6, D-10, D-11, D-12, D-13, D-16, D-17, D-19.
- **Referenced in plan:** Outcome, Implementation Approach (Architecture and Integration Points), Decomposition and Sequencing.

### D-2: Repair iterates the derived plugin set unconditionally

- **Question:** Should `repair` inherit Step 4's `target == current` skip, or write every writable target for every derived plugin regardless?
- **Decision:** `repair` iterates the derived plugin set **unconditionally**, writing the publishing version onto every writable version record and creating any missing channel-two listing entry. It does not carry Step 4's "skip any plugin whose `target == current`" guard.
- **Rationale:** Step 4's skip is correct for the channel-one record write (an unchanged plugin's record is already right), but that skip **is** the drift mechanism: none of the eight drifted channel-two records would be touched by an ordinary release, because those plugins are not being bumped. Inheriting the skip repairs nothing.
- **Evidence:** `SKILL.md:237` (the skip); discovery notes (8 drifted plugins, none of which an ordinary release bumps); iteration-history C2.
- **Rejected alternatives:**
  - Reuse Step 4's skip for the repair — rejected because it leaves every drifted record drifted no matter how many releases run (C2), which is the exact defect phase 3 exists to end.
- **Specialist owner:** devops-engineer.
- **Revisit criterion:** The repair is measured writing a record that was already correct in a way that produces a spurious change (it should be idempotent; a spurious diff would signal a bug).
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-9.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

### D-3: The gate is a new Step 4.5

- **Question:** Where in the release flow does the gate (the `check` call that can stop the release) run?
- **Decision:** The gate is a **new Step 4.5**, immediately after the writes (Step 4) and before the changelog augment (Step 5).
- **Rationale:** Three arguments converge on this placement. It keeps spec D34's discard set to exactly the four target paths (nothing downstream has been written yet). Step 5's changelog augment path is **not idempotent** — it appends — so a stop after it duplicates content on re-run (C4). And a stop at 4.5 costs zero `general-purpose` agent dispatches (the changelog narrative agent runs in Step 5). Spec D24 requires the gate after all targets are written and before anything irreversible; 4.5 is the earliest point that satisfies it.
- **Evidence:** Spec D24 (`feature-specification.md:250-261`), D34 (`:511-513`); `SKILL.md:249-255` (Step 5 augment appends, not idempotent); iteration-history C3 (raised independently by two specialists), C4.
- **Rejected alternatives:**
  - Gate at Step 7 (show the prepared release) — rejected because Step 5's augment would already have run and duplicates on re-run (C4), and the discard set would widen beyond the four targets (C3).
- **Specialist owner:** devops-engineer.
- **Revisit criterion:** A future step is inserted between Step 4 and Step 5 that itself writes a non-idempotent artifact, forcing the gate earlier.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-4, D-8.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

### D-4: The gate reads disk state fresh

- **Question:** Does the gate evaluate the plugin/target state captured in the skill's Project Context frontmatter, or read disk fresh at invocation time?
- **Decision:** The gate (and the `check`/`repair` script generally) **reads disk fresh**. It does not consume the skill's Project Context values.
- **Rationale:** The skill's Project Context is a frontmatter block of `!`-prefixed commands evaluated **once at invocation**, before the plan is confirmed and before Step 4's writes exist. Wiring the gate to those captured values builds a gate that checks the pre-repair state and always passes. The bug is invisible in review because the wiring looks correct. Because the script runs as a subprocess at Step 4.5, reading disk fresh is structural rather than a discipline the prose must remember.
- **Evidence:** `SKILL.md:31-41` (Project Context is a one-time frontmatter block); iteration-history C5.
- **Rejected alternatives:**
  - Pass the Project Context plugin list / versions into the gate — rejected because those values predate the writes, so the gate would check pre-repair state and pass regardless (C5).
- **Specialist owner:** edge-case-explorer.
- **Revisit criterion:** None foreseeable; a change that makes the check read cached state would reintroduce the defect.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Runtime Behavior).

### D-5: Repair skips what it cannot safely write

- **Question:** When `repair` reaches a target it cannot safely write (for example an unreadable record), does it abort, or skip and continue?
- **Decision:** `repair` **skips what it cannot safely write** and continues, leaving the unsafe target for the single gate at Step 4.5 to name as a gap.
- **Rationale:** Aborting at the first unreadable file names one gap and stops, which breaks spec D12 ("name every gap at once, not the first"). The repair's job is to close what it can; the gate's job is to name what remains. Splitting those responsibilities is what lets D12 and D35 both hold: the repair writes the writable, the gate reports the complete residue in one run.
- **Evidence:** Spec D12 (`feature-specification.md:254-255`), D35 (`:606-608`); iteration-history C12.
- **Rejected alternatives:**
  - Abort the repair at the first target it cannot write — rejected because it surfaces one gap instead of the full set and breaks D12 (C12).
- **Specialist owner:** junior-developer.
- **Revisit criterion:** A class of unsafe write is found where continuing corrupts a later target rather than merely leaving it unrepaired.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-6.
- **Referenced in plan:** Implementation Approach (Runtime Behavior).

### D-6: The check takes no mode flag

- **Question:** Does the check need a mode flag (release vs. pull-request) so the two callers get different behavior?
- **Decision:** **No mode flag.** The check's contract is: no arguments, cwd is the repository root, exit `0` clean / exit `1` gaps found (all named at once, per D12) / exit `2` cannot answer (an unreadable target per D35, or an empty derived plugin set per C16). The two surfaces differ by **when** the check is called, not by **what** it asks.
- **Rationale:** On a release the repair runs first, so the repair set and the gap set are exact complements — by the time the check runs, everything the check would otherwise have caught the release doing has already been repaired. On a pull request nothing repairs, so the same question surfaces the drift directly. One question, two moments, one answer shape. Exit `2` for an empty plugin set closes the "invisible-by-construction" hole where a derivation that finds no plugins finds no gaps and exits green (C16).
- **Evidence:** Spec D12, D14, D35, D38 (`feature-specification.md:604-608,634-636`); iteration-history C11 (junior-dev walked every row of the spec's failure table; devops concurred independently), C16.
- **Rejected alternatives:**
  - A `--release` / `--pr` mode flag (or `--json`, `--fix`, `--dry-run`, severity taxonomy) — rejected because both callers need the same answer and an exit code beats a taxonomy; deferred under YAGNI with a reopen trigger (a third caller needing a different answer).
- **Specialist owner:** test-engineer.
- **Revisit criterion:** A third caller needs a different answer from the same check.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-10, D-12, D-13, D-16, D-17.
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points, Runtime Behavior), Testing Strategy.

### D-7: The created channel-two entry carries no version

- **Question:** What exact fields does a release write when it creates a channel-two storefront listing entry, and does D31's "at the version it is publishing" apply?
- **Decision:** The created entry carries no `version` field. Its exact field set is:

  ```json
  {
    "name": "{name}",
    "source": { "source": "local", "path": "./{dir}" },
    "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
    "category": "Developer Tools"
  }
  ```

  D31's "created at the version it is publishing" binds the version **records** and is vacuous for this created entry; D39's report line for a creation names no version.
- **Rationale:** Measured this session: channel-two listing entry keys are exactly `[category, name, policy, source]` — `[.plugins[] | has("version")] | unique` returns `[false]`. `policy` and `category` are 100% uniform across all existing entries. So creation is fully derivable and carries no version. This is also the **measurable** form of D36's boundary (C10): channel two's listing entry is the only target of the four with no authored field in it — the one-line, checkable justification for the whole create-path, which the plan states outright rather than arguing.
- **Evidence:** Discovery notes JD-001 (measured key sets and uniformity); spec D31 (`feature-specification.md:231-235`), D36, D39; iteration-history C9, C10.
- **Rejected alternatives:**
  - Write a `version` onto the created entry (a literal read of D31) — rejected because the entry has no version field and never has; D31 is vacuous here (C9).
  - Derive `category`/`policy` per-plugin — rejected because all existing entries are uniform; the constants are correct and the per-plugin derivation guards a case with no members (deferred under YAGNI).
- **Specialist owner:** junior-developer.
- **Revisit criterion:** A plugin needs a non-"Developer Tools" category or a non-default policy, or channel two's schema adds a version to listing entries.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-10.
- **Referenced in plan:** Implementation Approach (Data Model and Persistence, Runtime Behavior).

### D-8: Recovery is a scoped git restore, never git clean

- **Question:** How does the operator recover from a gate stop at Step 4.5 — and does recovery need to delete untracked files?
- **Decision:** Recovery discards the release's local work with a **scoped `git restore` of the four tracked target paths**, never `git clean`. The untracked-file hazard the spec hedged against has zero members, so no untracked-deletion step is specified.
- **Rationale:** The channel-two listing is a tracked file and creation only modifies an entry inside it, so `git ls-files --error-unmatch` succeeds for every target creation touches — the "created file is untracked" hazard has no members (C6). Hedging against a non-hazard invites `git clean -fd` into the recovery, which deletes a solo maintainer's unrelated untracked work with no undo — a real hazard manufactured to guard a fake one (C7). Spec D34's behavior (a gate stop costs a separate commit) stands on its **other** reason: committing the gap fix together with half-applied version writes makes those writes look like deliberate bumps, so the next run takes the ahead path and publishes versions nobody approved. This corrects a spec **rationale** (C6 is spec-level) without changing D34's behavior. If creation is ever widened to write a **new** file, the hazard regains members and the recovery must be revisited.
- **Evidence:** Spec D34 (`feature-specification.md:508-534`); verified `git ls-files --error-unmatch` succeeds for the channel-two listing; iteration-history C6, C7.
- **Rejected alternatives:**
  - `git clean -fd` (or any untracked-deletion) in the recovery — rejected because it deletes unrelated untracked work to guard a hazard with zero members (C6, C7).
- **Specialist owner:** devops-engineer.
- **Revisit criterion:** Creation is widened to write a new file rather than an entry inside a tracked file; then untracked artifacts exist and the recovery needs an untracked-aware step.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Operational Readiness, RAID Log.

### D-9: Exclude the channel-two record from change detection

- **Question:** Does the release's change-detection (Step 3a) count `{source}/.codex-plugin/plugin.json` edits as a plugin "change"?
- **Decision:** **Exclude** `{source}/.codex-plugin/plugin.json` from Step 3a's change detection. Do **not** add the symmetric exclusion for `{source}/.claude-plugin/plugin.json`.
- **Rationale:** `{dir}/.codex-plugin/plugin.json` lives inside `{source}/`, so phase 4's hand-corrections make all 8 plugins classify as "changed", and the next release proposes 8 meaningless patch bumps — recurring on every contributor record fix, which is exactly the kind of fix phase 6 exists to cause. Verified live against `v4.6.0`. The symmetric exclusion for `.claude-plugin/plugin.json` is beyond phase 3's remit: it would also stop a description-only edit from bumping, a behavior change with no measured instance.
- **Evidence:** `SKILL.md:168,171-172` (Step 3a change detection); verified live against `v4.6.0`; iteration-history C8.
- **Rejected alternatives:**
  - Leave change detection unchanged — rejected because phase 4 and every later record fix then manufacture spurious patch bumps (C8).
  - Add the symmetric `.claude-plugin/plugin.json` exclusion too — rejected because there is no measured instance and it changes behavior beyond phase 3's remit (deferred under YAGNI).
- **Specialist owner:** devops-engineer.
- **Revisit criterion:** A description-only edit to `.claude-plugin/plugin.json` is observed causing an unwanted bump.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

### D-10: Creation consumes the check's gap list

- **Question:** Does the creation step re-derive which channel-two listing entries are missing, or consume the check's own gap output?
- **Decision:** Creation **consumes the check's own gap list** rather than re-deriving it.
- **Rationale:** Consuming the check's output makes the bundle's third verb (*not created*) correct **by construction** rather than by a second rule that must independently reproduce the bundle exception. One derivation of "what is missing", one place the exception lives.
- **Evidence:** Spec D6 (`feature-specification.md:280-286`), D14; iteration-history C21.
- **Rejected alternatives:**
  - Re-derive the missing set inside the creation step — rejected because it duplicates the bundle exception into a second rule that can drift from the check (C21).
- **Specialist owner:** test-engineer.
- **Revisit criterion:** The check's output format changes such that creation can no longer consume it directly.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Runtime Behavior).

### D-11: Bundle identity is derived from the listing name

- **Question:** Does the check identify the bundle (the permanent channel-two exception) by deriving it from a file, or by hardcoding the literal `han`?
- **Decision:** **Derive** the bundle identity from `.claude-plugin/marketplace.json`'s top-level `.name`.
- **Rationale:** The junior-developer's objection — deriving from a file the check exists to distrust is a knot — dissolves on measurement: no release step writes the top-level `.name` (only `.plugins[].version`), and the check needs that listing readable regardless (an unreadable listing exits 2 either way). Deriving costs nothing and reuses the definition already at `SKILL.md:44-46`. Verified: marketplace `.name` = `han` = the bundle directory's own name.
- **Evidence:** `SKILL.md:44-46` (existing parent definition); measured marketplace `.name` = `han`; no release step writes top-level `.name`; iteration-history C25 (Disputed → resolved), OQ-D.
- **Rejected alternatives:**
  - Hardcode the literal `han` — rejected because it duplicates a definition that already exists at `SKILL.md:44-46` and would need hand-editing if the bundle is ever renamed (OQ-D).
- **Specialist owner:** devops-engineer.
- **Revisit criterion:** A release step begins writing the top-level `.name`, or a second permanent exception appears that the single-name derivation cannot express.
- **Dissent (if any):** junior-developer argued for hardcoding the literal `han` (deriving from a distrusted file is a knot); resolved by measurement — no release step writes `.name` and the listing must be readable anyway. Recorded under disagree-and-commit.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points).

### D-12: Guard the jq parse and null traps

- **Question:** How does the check read JSON without two silent failure modes: `jq -r` printing `null`, and the skill's `2>/dev/null` idiom masking a parse failure as empty?
- **Decision:** The check **guards both traps.** It never lets `jq -r`'s literal `null` output stand in for a real value, and it distinguishes a parse failure from a successfully-parsed empty array rather than copying the skill's `jq … 2>/dev/null` idiom to the listing read.
- **Rationale:** `jq -r` prints the literal string `null` for both an explicit null and an absent key, so two broken records string-compare **equal** — defeating D35's "two unreadable values never agree" (C13). Separately, the skill's existing `jq … 2>/dev/null` idiom, copied to a listing read, turns a parse failure into "zero entries", routing the whole channel into the create-path and regenerating the storefront — the loudest possible version of the silent defect this work exists to end (C14). Parse failure must exit 2; a parsed empty array is a different, answerable state.
- **Evidence:** `SKILL.md:37,39` (the `2>/dev/null` idiom); spec D35 (`feature-specification.md:606-608`); verified `jq -r` prints `null` for both cases; iteration-history C13, C14.
- **Rejected alternatives:**
  - Copy the skill's `jq … 2>/dev/null` idiom to the check's reads — rejected because it converts a parse failure into a false "empty" and regenerates the storefront (C14).
  - Compare `jq -r` outputs directly — rejected because two `null` strings compare equal and defeat D35 (C13).
- **Specialist owner:** edge-case-explorer.
- **Revisit criterion:** jq's null-output behavior changes, or a read path is added that bypasses the guard.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Testing Strategy.

### D-13: Derive the plugin set with a depth-bounded jq glob

- **Question:** How does the check derive the plugin set, and how does the release skill's Project Context enumeration (`SKILL.md:37-39`) change?
- **Decision:** Derive the plugin set by matching `*/.claude-plugin/plugin.json` (a **depth-bounded glob**, not a recursive `find`), reading identity with `jq`. Replace the Project Context enumeration at `SKILL.md:37-39` — which reads `jq -r '.plugins[] | …' .claude-plugin/marketplace.json`, the defect verbatim — with this repo-derived, depth-bounded enumeration.
- **Rationale:** The current enumeration takes its plugin list from a target it also writes (spec D5's whole subject). Deriving from the repository fixes it. The depth bound matters: `han-plugin-builder` teaches authoring `plugin.json` files, and its example avoids collision only by two incidental naming accidents — a recursive find would pick up authored examples. Measured: exactly 11 directories match `*/.claude-plugin/plugin.json` and all 11 are plugins, no false positives. `jq` is already granted in `allowed-tools`; `ls`/`find` are not, so a `jq`-driven glob keeps the permission surface unchanged.
- **Evidence:** Spec D5 (`feature-specification.md:196-197`); `SKILL.md:37-39` (the defect); discovery notes (11 dirs match, no false positives); `SKILL.md:17` (allowed-tools grants `jq`, not `ls`/`find`); iteration-history C15.
- **Rejected alternatives:**
  - Recursive `find … -name plugin.json` — rejected because it picks up `han-plugin-builder`'s authored example files (C15).
  - Keep deriving from `marketplace.json.plugins[]` — rejected because that is the "list from a target it also writes" defect spec D5 exists to remove.
- **Specialist owner:** edge-case-explorer.
- **Revisit criterion:** A real plugin is nested deeper than one directory below the root, or an authored `plugin.json` example is placed exactly one level down.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points, Runtime Behavior).

### D-15: Add an "Adding a plugin" section to CONTRIBUTING

- **Question:** Which contributor-doc passages does phase 3 falsify and must correct?
- **Decision:** **Add** a short "Adding a plugin" section to `CONTRIBUTING.md` naming the four publishing targets. **Leave `CONTRIBUTING.md:138` and `:157` alone.** This corrects an error in an earlier draft of the discovery notes.
- **Rationale:** Lines 138 and 157 are about moving a **skill** between plugins, which touches none of the four targets, so spec D7 ("a document is in scope when this work falsifies it") excludes them. No contributor doc mentions channel two at all today — verified by grepping `CONTRIBUTING.md`, `README.md`, `docs/quickstart.md` for `agents/plugins` or `codex-plugin`. So this is an **addition**, not a correction: a contributor adding a plugin currently has no instructions at all. Phase 6's fairness argument rests on the addition — a contributor cannot be told they missed a target no document ever named.
- **Evidence:** Discovery notes JD-006 correction (re-verified live); spec D7 (`feature-specification.md:355-359`), D21; `feature-specification.md:558`; iteration-history C18.
- **Rejected alternatives:**
  - Rewrite `CONTRIBUTING.md:138`/`:157` to list four targets (the earlier discovery-notes instruction) — rejected because those lines are about moving a skill and phase 3 does not falsify them; acting on it would make the guide wrong in a new way (C18).
- **Specialist owner:** junior-developer.
- **Revisit criterion:** A contributor-doc passage is found that does narrate the plugin-adding publishing flow and is falsified by this work.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points), Decomposition and Sequencing.

### D-16: Tests use synthetic fixtures; phase 3 ships script and bats only

- **Question:** Do the check's tests run against the live repository tree, and does phase 3 ship the CI workflow step and prek hook?
- **Decision:** Tests use **synthetic `mktemp -d` fixtures**, never the live tree. Phase 3 ships the script **and** its bats tests (they run via `npm test` with no `ci.yml` change). Phase 6 ships the CI workflow step and the prek hook.
- **Rationale:** A test asserting the 8 drifted plugins flips to green when phase 4 lands; a test asserting check-exits-0 against the real repo goes red on phase 3's own PR and stays red through phase 4 — landing phase 6's red signal four phases early and destroying spec D1's sequencing rationale (a signal red from birth is one people scroll past). Synthetic fixtures are stable across phases. Phase 3's bats run under the existing `npm test` (Bats, `--recursive test/`) with no CI change, so shipping the tests now does not turn the check on at the PR surface — that is phase 6's job. Precedent: phase 2's `check-annotations.bats` builds files under `mktemp -d`.
- **Evidence:** Spec D1 (`feature-specification.md:319-324`); discovery notes (Bats runner, `test/*.bats` precedent, phase 3 does not touch `ci.yml`); `check-annotations.bats:11-13` (`mktemp -d` fixtures); iteration-history C19.
- **Rejected alternatives:**
  - Test against the live repository tree — rejected because assertions on the 8 drifted plugins flip when phase 4 lands, and a green-check assertion goes red on phase 3's own PR through phase 4 (C19).
  - Ship the CI step / prek hook in phase 3 — rejected because it makes the check visible on the PR surface four phases before phase 6, which owns that surface, and lands a red signal early (C19).
- **Specialist owner:** test-engineer.
- **Revisit criterion:** A behavior can only be exercised against real repo state; then a read-only, phase-stable assertion must be designed rather than reusing the live tree.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Decomposition and Sequencing, Testing Strategy, Definition of Done.

### D-17: State the enforcement limit and print findings verbatim

- **Question:** Can the release be built to prevent an agent skipping the check or authoring a missing record itself, and if not, what does phase 3 commit to?
- **Decision:** **State the enforcement limit out loud** in the plan, and adopt two cheap mitigations: the skill prints the check's findings **verbatim** (not paraphrased), and Step 7's always-printed summary **includes the check's output**. No mechanism is built to prevent an agent skipping the check or authoring the missing record.
- **Rationale:** Prose cannot be trusted to gate — nothing stops an agent skipping the check, and `allowed-tools` grants `Write`/`Edit`, so on a stop the agent could author the missing record itself and re-run to green (C22, C23). Nothing can be built to prevent that. But the **observed** failure class is prose that was **wrong**, followed faithfully, for eleven releases — an executable check fixes that class completely, and an enforcement wrapper would guard a class with zero observed members. The release already rests on this same trust at Step 1.2's hard stop. Printing verbatim satisfies D14 plus the spec's "the message a contributor sees is the message a maintainer sees"; including the check's output in the always-printed Step 7 summary means an agent that skipped the check has nothing to paste. A forward note for phase 6: inherit `ci.yml`'s existing `push: main` trigger rather than narrowing to `pull_request`, for free post-hoc detection of a skipped release gate.
- **Evidence:** Spec D14 (`feature-specification.md:274-275`); `SKILL.md:16-18` (allowed-tools grants Write/Edit), `SKILL.md:72-74` (Step 1.2 hard stop rests on the same trust); `.github/workflows/ci.yml:8-11` (existing `push: main` trigger); iteration-history C22, C23.
- **Rejected alternatives:**
  - Build an enforcement wrapper that gates commit/push behind the check's exit code — rejected because it guards a class with zero observed members and cannot in principle stop an agent that has Write/Edit (C22, C23); deferred under YAGNI.
- **Specialist owner:** devops-engineer.
- **Revisit criterion:** A release is cut where the gate was skipped, or the check's output is absent from the Step 7 summary.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Runtime Behavior), RAID Log, Operational Readiness.

### D-18: Stage by class pathspec

- **Question:** How does Step 8.1 stage the release's writes — by a hand enumeration of paths, or by a class pathspec?
- **Decision:** **Stage by class pathspec** at Step 8.1, not by a hand enumeration of the target paths.
- **Rationale:** The current Step 8.1 staging list is a hand enumeration that commits two of the four targets — the same defect class spec D37 found (the release wrote four targets and committed two). A class pathspec captures every target the release writes, satisfying D37's "every target the release writes travels into the commit it tags". It is safe because Step 1.2 guarantees a clean tree at the start of the release, so the pathspec stages only the release's own writes.
- **Evidence:** Spec D37 (`feature-specification.md:263-267`); `SKILL.md:326-328` (the hand enumeration), `SKILL.md:72-74` (Step 1.2 clean-tree guarantee); iteration-history C24.
- **Rejected alternatives:**
  - Extend the hand enumeration to list all four targets — rejected because a hand list is the exact defect class D37 found; the next added target reintroduces the omission (C24).
- **Specialist owner:** devops-engineer.
- **Revisit criterion:** The clean-tree guarantee at Step 1.2 is removed, so a class pathspec would stage unrelated pre-existing changes.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

### D-20: OQ-5 is discharged by the spec as Option A

- **Question:** What should a release do when the operator's approved version plan and a target's repair disagree (OQ-5)?
- **Decision:** **Option A — the repair is silent within the approved plan.** OQ-5 is discharged by the spec, not by a maintainer round-trip. Strike it from phase 3's preconditions.
- **Rationale:** `feature-specification.md:497-500` states the repair-and-proceed path as the ordinary path ("proceeds, whether or not it bumped that plugin this release"). The Deferred-YAGNI item at `:743-756` establishes that creation itself gets no sign-off, so a repair — a strictly smaller act — cannot need one. Under a script-borne, argument-free `repair` the behavior is structural rather than instructed: a bump decides a new version, a repair publishes one already decided, and a drifted version is derivable.
- **Evidence:** `feature-specification.md:497-500`, `:743-756`; iteration-history C26, OQ-5.
- **Rejected alternatives:**
  - Option B — the plan names every target the release will touch before approval — rejected because it asks the operator to approve arithmetic (correcting a derivable drifted version is not a new decision), and D39's report already provides the notice; deferred under YAGNI.
- **Specialist owner:** junior-developer.
- **Revisit criterion:** A maintainer is surprised by a version the release wrote and reports the silent repair as unwanted.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-21.
- **Referenced in plan:** Decomposition and Sequencing, Open Items.

### D-22: Leave the frontmatter description's stale list alone

- **Question:** The frontmatter `description` at `SKILL.md:3-14` carries the same stale plugin enumeration as the Vocabulary bullet. The Vocabulary bullet is being rewritten — should the description be corrected too, since the editor is already in the file?
- **Decision:** **Leave the frontmatter description alone.** Rewrite **only** the Vocabulary bullet at `SKILL.md:48` (and the Project Context enumeration per D-13). State this boundary explicitly in the plan.
- **Rationale:** The Vocabulary bullet's "children — every other entry in marketplace.json.plugins[]" is **falsified** by spec D5 (the release no longer derives children from the listing), so spec D33 (an already-false statement inside a rewritten passage is corrected) applies and D5 forces the rewrite. The frontmatter description is **not** being rewritten and nothing in it is falsified by this work, so spec D7 leaves it alone — even though it carries the same stale list two paragraphs up. "I'm already in the file and that list is wrong two paragraphs up" is exactly the symmetry reasoning the spec rejects (D7, and the Out-of-scope boundary at `feature-specification.md:701-708`), and an implementer will hit this within ten minutes, so the plan says it out loud.
- **Evidence:** `SKILL.md:3-14` (description), `SKILL.md:48` (Vocabulary bullet); spec D5, D7 (`feature-specification.md:355-359`), D33 (`:372-382`); Out-of-scope boundary (`:701-708`); iteration-history edit-site notes.
- **Rejected alternatives:**
  - Correct the frontmatter description's stale list while editing the Vocabulary — rejected because the description is not falsified by this work; correcting it because the editor is open is the symmetry reasoning spec D7 and D33 explicitly refuse.
- **Specialist owner:** junior-developer.
- **Revisit criterion:** A later step falsifies the frontmatter description directly (for example a plugin rename this work performs), bringing it into scope under D7.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points), Decomposition and Sequencing.
