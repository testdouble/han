# Feature Implementation Plan: Han Publishing Cleanup — Phase 3

Phase 3 ("Make a release bring every publishing target up to date") is implemented by moving the four-target repair,
creation, gap, and gate logic out of the release skill's prose and into one executable script the skill invokes
([D-1](artifacts/implementation-decision-log.md#d-1-the-publishing-writes-are-script-borne)), then editing the
`han-release` skill at the specific sites that today take their plugin list from a target they also write, commit two of
four targets, and place no gate. It ships the script and its bats tests; it does **not** turn the check on at the
pull-request surface (that is phase 6).

## Source Specification

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Specification decision log:** [artifacts/decision-log.md](artifacts/decision-log.md)
- **Specification team findings:** [artifacts/team-findings.md](artifacts/team-findings.md)
- **Specification technical notes:** [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
- **Build phase outline:** [build-phase-outline.md](build-phase-outline.md) (Phase 3)
- **Specification decisions this plan inherits:** D1, D5, D6, D12, D14, D19, D24, D31, D34, D35, D36, D37, D38, D39, D41.
- **Specification open items this plan must respect or resolve:** OQ-5 (resolved — see
  [D-20](artifacts/implementation-decision-log.md#d-20-oq-5-is-discharged-by-the-spec-as-option-a)); spec Open items 1–4
  shape phases 4 and 6 and do not touch phase 3.

## Outcome

After this phase, a Han release derives its plugin set from what is actually in the repository, brings all four
publishing targets up to date (correcting a drifted version, creating a missing channel-two listing entry), and refuses
to proceed when it meets a gap only a person can close — naming every gap at once, before anything is committed, tagged,
or pushed. The write logic lives in one executable bearer, `scripts/publishing-targets.sh`
([D-1](artifacts/implementation-decision-log.md#d-1-the-publishing-writes-are-script-borne)), which phase 6 will reuse
unchanged. The release skill runs the check and reports its answer verbatim rather than restating the rule.

## Context

- **Driving constraint:** Channel two drifted silently across eleven releases because the release takes its plugin list
  from a file it also writes and commits only two of four targets. Phase 3 is the hinge of the cleanup: phase 4's hand
  correction is durable only if the repair lands first, and phase 6's pull-request check reuses this phase's bearer.
- **Stakeholders:** the Han maintainer (a release that repairs all four targets and refuses real gaps rather than
  shipping around them); contributors (phase 3's `CONTRIBUTING.md` addition makes phase 6's signal fair); channel-two
  installers (reached by phase 4, made durable by this phase).
- **Future-state concern:** the check and the release must keep exactly one bearer as the suite grows
  ([D-1](artifacts/implementation-decision-log.md#d-1-the-publishing-writes-are-script-borne)); a second copy of the rule
  would reintroduce the drift by a different route. The plugin-set derivation must stay depth-bounded as
  `han-plugin-builder` continues to teach authoring `plugin.json` files
  ([D-13](artifacts/implementation-decision-log.md#d-13-derive-the-plugin-set-with-a-depth-bounded-jq-glob)).
- **Out-of-scope boundary:** the pull-request CI step and prek hook (phase 6); the hand version correction (phase 4);
  the frontmatter description's stale plugin list, which this work does not falsify
  ([D-22](artifacts/implementation-decision-log.md#d-22-leave-the-frontmatter-descriptions-stale-list-alone)); any
  enforcement mechanism that would try to stop an agent skipping the check
  ([D-17](artifacts/implementation-decision-log.md#d-17-state-the-enforcement-limit-and-print-findings-verbatim)).

## Team Composition and Participation

Medium plan (the release skill, a new check with two consumers, the docs it falsifies; no auth or PII surface). One
round; converged. Full round-by-round detail lives in
[artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md).

| Specialist            | Status      | Key Input                                                                                                                               |
| --------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `project-manager`     | Coordinator | Facilitated R1 and synthesized this plan.                                                                                               |
| `junior-developer`    | Active      | Reframed OQ-5 (Option A), the created-entry field set, and the CONTRIBUTING correction; corrected the discovery-notes error on lines 138/157. |
| `devops-engineer`     | Active      | The gate placement, unconditional repair, recovery sequence, change-detection exclusion, bundle-identity derivation, staging pathspec.  |
| `edge-case-explorer`  | Active      | The disk-fresh gate read, the jq null/parse traps, the depth-bounded derivation, the empty-plugin-set exit.                             |
| `test-engineer`       | Active      | The check contract (no mode flag, exit 0/1/2), synthetic-fixture testing, creation consuming the check's gap list.                      |

## Implementation Approach

The change has two parts: a new executable bearer at the repository root, and a set of targeted edits to the existing
`han-release` skill. Two independent reviews converged on the script-borne shape from opposite directions — the write
logic is what carries the bundle exception and the five-gap rule, and prose cannot be tested or trusted to gate
([D-1](artifacts/implementation-decision-log.md#d-1-the-publishing-writes-are-script-borne),
[D-17](artifacts/implementation-decision-log.md#d-17-state-the-enforcement-limit-and-print-findings-verbatim)).

### Architecture and Integration Points

**The bearer.** One new script, `scripts/publishing-targets.sh`, at the **repository root** (not inside any `han-*/`
plugin), with two argument-free verbs — `check` and `repair`
([D-1](artifacts/implementation-decision-log.md#d-1-the-publishing-writes-are-script-borne)). Root placement is repo
maintenance rather than any plugin's shipped behavior; a copy inside `han-*/` would ship dead weight to installers and
make every fix bump a version the check polices; and three callers (this skill, phase 6's CI step, the optional prek
hook) live in three trees. The ShellCheck hook covers a root script automatically (no `files` filter), and the
shebang-executable hook is satisfied by `chmod +x` in the same commit. It follows Betterment "The Book" Bash conventions
(`#!/usr/bin/env bash`, `set -euo pipefail`, ShellCheck clean, `mktemp` + traps, BSD/GNU portability) and the shape of
the `check-annotations.sh` precedent (multi-input, names every finding at once, one bearer with two callers).

**The check contract.** No arguments; cwd is the repository root; exit `0` clean / `1` gaps found (all named at once) /
`2` cannot answer — an unreadable target, or an empty derived plugin set
([D-6](artifacts/implementation-decision-log.md#d-6-the-check-takes-no-mode-flag)). No mode flag: the release repairs
before the check runs, so the repair set and the gap set are exact complements, and the two surfaces differ by **when**
the check is called, not what it asks.

**Plugin-set derivation.** Both verbs derive the plugin set from the repository by matching `*/.claude-plugin/plugin.json`
— a depth-bounded glob read with `jq`, not a recursive `find`, because `han-plugin-builder` teaches authoring
`plugin.json` files and a recursive walk would pick up authored examples
([D-13](artifacts/implementation-decision-log.md#d-13-derive-the-plugin-set-with-a-depth-bounded-jq-glob)). `jq` is
already granted in the skill's `allowed-tools`; `ls`/`find` are not, so a `jq`-driven glob keeps the permission surface
unchanged. The bundle (the permanent channel-two exception) is identified by deriving from
`.claude-plugin/marketplace.json`'s top-level `.name`, reusing the definition already at `SKILL.md:44-46`
([D-11](artifacts/implementation-decision-log.md#d-11-bundle-identity-is-derived-from-the-listing-name)).

**Skill integration.** Add `Bash(./scripts/publishing-targets.sh:*)` to the `han-release` frontmatter `allowed-tools`
([D-19](artifacts/implementation-decision-log.md#trivial-decisions)). The skill edits touch these sites:

| SKILL.md site | Today | Change | Decision |
| --- | --- | --- | --- |
| `:37-39` Project Context | Enumerates plugins via `jq -r '.plugins[] \| …' marketplace.json` (the defect verbatim) | Replace with the repo-derived, depth-bounded enumeration | [D-13](artifacts/implementation-decision-log.md#d-13-derive-the-plugin-set-with-a-depth-bounded-jq-glob) |
| `:48` Vocabulary | "children — every other entry in marketplace.json.plugins[]" | Rewrite (falsified by spec D5) | [D-22](artifacts/implementation-decision-log.md#d-22-leave-the-frontmatter-descriptions-stale-list-alone) |
| `:3-14` frontmatter `description` | Same stale plugin list as Vocabulary | **Leave alone** — not falsified by this work | [D-22](artifacts/implementation-decision-log.md#d-22-leave-the-frontmatter-descriptions-stale-list-alone) |
| `:142-146` Step 3 | "Enumerate the plugins from `plugins` in Project Context" | Enumerate from the repo-derived set | [D-13](artifacts/implementation-decision-log.md#d-13-derive-the-plugin-set-with-a-depth-bounded-jq-glob) |
| `:171-172` Step 3a | Change detection counts `{source}/.codex-plugin/plugin.json` | Exclude the channel-two record | [D-9](artifacts/implementation-decision-log.md#d-9-exclude-the-channel-two-record-from-change-detection) |
| `:237` Step 4 | Skips any plugin whose `target == current` | Skip stays for the record write; the repair (new) does not inherit it | [D-2](artifacts/implementation-decision-log.md#d-2-repair-iterates-the-derived-plugin-set-unconditionally) |
| new Step 4.5 | (no gate) | Invoke `check`; stop on non-zero, printing findings verbatim | [D-3](artifacts/implementation-decision-log.md#d-3-the-gate-is-a-new-step-45), [D-17](artifacts/implementation-decision-log.md#d-17-state-the-enforcement-limit-and-print-findings-verbatim) |
| `:326-328` Step 8.1 | Hand enumeration commits two of four targets | Stage by class pathspec | [D-18](artifacts/implementation-decision-log.md#d-18-stage-by-class-pathspec) |
| `:302-320` Step 7, `:350-356` Step 10 | Report the version plan only | Also report created and changed targets (spec D39) | [D-21](artifacts/implementation-decision-log.md#trivial-decisions) |

### Data Model and Persistence

The four targets are JSON files (two storefront listings, two per-plugin records). The only **created** artifact is a
channel-two storefront listing entry, and it is created inside the already-tracked `.agents/plugins/marketplace.json`.
Its exact field set carries no version
([D-7](artifacts/implementation-decision-log.md#d-7-the-created-channel-two-entry-carries-no-version)):

```json
{
  "name": "{name}",
  "source": { "source": "local", "path": "./{dir}" },
  "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
  "category": "Developer Tools" }
```

`policy` and `category` are the shared literals every existing entry already carries (measured 100% uniform). This is
the measurable form of spec D36's boundary: channel two's listing entry is the **only** target of the four with no
authored field in it, which is the one-line, checkable justification for the whole create-path
([D-7](artifacts/implementation-decision-log.md#d-7-the-created-channel-two-entry-carries-no-version)). Every other
target contains prose a person wrote, so a release stops rather than creating it.

### Runtime Behavior

`repair` iterates the derived plugin set **unconditionally**, writing the publishing version onto every writable record
and creating any missing channel-two listing entry — it does not inherit Step 4's `target == current` skip, because that
skip is the drift mechanism ([D-2](artifacts/implementation-decision-log.md#d-2-repair-iterates-the-derived-plugin-set-unconditionally)).
It **skips what it cannot safely write** and defers to the single gate, so the gate names the complete residue rather
than the repair aborting on the first gap
([D-5](artifacts/implementation-decision-log.md#d-5-repair-skips-what-it-cannot-safely-write)). Creation **consumes the
check's own gap list** rather than re-deriving it, making the bundle's *not-created* verb correct by construction
([D-10](artifacts/implementation-decision-log.md#d-10-creation-consumes-the-checks-gap-list)). Every cross-target join
keys on the plugin `name`, never the listing's `source` path
([D-14](artifacts/implementation-decision-log.md#trivial-decisions)).

The gate is a **new Step 4.5**, immediately after the writes and before the non-idempotent changelog augment
([D-3](artifacts/implementation-decision-log.md#d-3-the-gate-is-a-new-step-45)). It **reads disk fresh** rather than the
skill's once-evaluated Project Context frontmatter, or it would check pre-repair state and always pass
([D-4](artifacts/implementation-decision-log.md#d-4-the-gate-reads-disk-state-fresh)). Reads guard the jq traps: `jq -r`
prints the literal `null` for both an explicit null and an absent key (so two broken values must not string-compare
equal), and a parse failure must not be masked as an empty array and route the whole channel into the create-path
([D-12](artifacts/implementation-decision-log.md#d-12-guard-the-jq-parse-and-null-traps)).

On a gate stop, recovery is a **scoped `git restore` of the four tracked target paths**, never `git clean` — the
untracked-file hazard has zero members because creation only modifies an entry inside a tracked file
([D-8](artifacts/implementation-decision-log.md#d-8-recovery-is-a-scoped-git-restore-never-git-clean)). Spec D34's
separate-commit behavior stands on its other reason (a combined commit makes half-applied version writes look like
deliberate bumps).

The skill prints the check's findings **verbatim** and includes the check's output in the always-printed Step 7 summary,
so the contributor's message equals the maintainer's and an agent that skipped the check has nothing to paste
([D-17](artifacts/implementation-decision-log.md#d-17-state-the-enforcement-limit-and-print-findings-verbatim)). Steps 7
and 10 report what the release created and what it changed, alongside the version plan; a created listing entry names no
version ([D-21](artifacts/implementation-decision-log.md#trivial-decisions)).

## Decomposition and Sequencing

| #   | Work Unit                                                        | Delivers                                                                                   | Depends On | Verification                                                        |
| --- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ---------- | ------------------------------------------------------------------- |
| 1   | `scripts/publishing-targets.sh` `check` verb + `chmod +x`        | Depth-bounded derivation, five-gap detection, exit 0/1/2, bundle exception, jq-trap guards | Phase 1    | bats against synthetic fixtures; ShellCheck clean                   |
| 2   | `repair` verb                                                    | Unconditional writable-target repair + channel-two entry creation, skip-unsafe             | 1          | bats against synthetic fixtures                                     |
| 3   | Skill edits: Project Context, Step 3/3a, Step 4.5 gate           | Repo-derived enumeration; codex-record change-detection exclusion; the gate call           | 1, 2       | 7-step Phase 3 demo (Definition of Done)                            |
| 4   | Skill edits: Step 8.1 staging, Step 7/10 reporting, Vocabulary   | Class-pathspec staging; created/changed reporting; falsified Vocabulary bullet rewrite      | 3          | 7-step demo; diff review against edit-site table                    |
| 5   | `CONTRIBUTING.md` "Adding a plugin" section                      | Names the four targets so phase 6's signal is fair                                          | —          | Section present and names all four targets                          |
| 6   | `allowed-tools` frontmatter line                                 | `Bash(./scripts/publishing-targets.sh:*)`                                                   | 1          | Skill invokes the script without a permission prompt                |

Work units 1–2 are the bearer; 3–4 are the skill wiring; 5–6 are the doc and permission edits. Phase 3's tests ship and
run under `npm test` with **no `ci.yml` change** — the check does not become visible on the pull-request surface here
([D-16](artifacts/implementation-decision-log.md#d-16-tests-use-synthetic-fixtures-phase-3-ships-script-and-bats-only)).
Phase 1 must have landed on the branch this work builds from, or the first release after phase 3 stops on the Linear
plugin's unwritten presence rather than repairing (spec D41). OQ-5 is discharged by the spec as Option A and struck from
the preconditions ([D-20](artifacts/implementation-decision-log.md#d-20-oq-5-is-discharged-by-the-spec-as-option-a)).

## RAID Log

### Risks

| ID  | Risk                                                                                                   | Likelihood | Severity | Blast Radius              | Reversibility | Owner            | Mitigation                                                                                                                                                             |
| --- | ------------------------------------------------------------------------------------------------------ | ---------- | -------- | ------------------------- | ------------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| R1  | An agent skips the check, or authors the missing record itself (Write/Edit granted) and re-runs green   | Low        | Medium   | One release               | High          | devops-engineer  | Cannot be prevented in principle; state the limit; print findings verbatim; include check output in the Step 7 summary ([D-17](artifacts/implementation-decision-log.md#d-17-state-the-enforcement-limit-and-print-findings-verbatim)) |
| R2  | An empty derived plugin set makes the check find zero gaps and exit green (invisible-by-construction)    | Low        | High     | Every target, every plugin| High          | edge-case-explorer | Empty plugin set exits `2` (cannot answer), not `0` ([D-6](artifacts/implementation-decision-log.md#d-6-the-check-takes-no-mode-flag))                               |
| R3  | A listing parse failure is masked as "zero entries" and regenerates the whole storefront                | Low        | High     | One channel's whole listing| High         | edge-case-explorer | Distinguish parse failure from a parsed empty array; do not copy the skill's `2>/dev/null` idiom ([D-12](artifacts/implementation-decision-log.md#d-12-guard-the-jq-parse-and-null-traps)) |

### Assumptions

| ID  | Assumption                                                                                     | What Changes If Wrong                                                             | Verifier          | Status   |
| --- | ---------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ----------------- | -------- |
| A1  | Phase 1 has landed on the build branch                                                          | The first release after phase 3 stops on the Linear plugin rather than repairing | maintainer        | Open     |
| A2  | Channel-two `policy` and `category` are uniform across all entries (creation constants)         | The created entry needs per-plugin derivation                                    | discovery JD-001  | Verified |
| A3  | All 11 plugin versions are plain `x.y.z` today (no prerelease/build metadata)                   | Version comparison needs semver prerelease handling                              | discovery notes   | Verified |
| A4  | Exactly 11 directories match `*/.claude-plugin/plugin.json`, all real plugins                   | The depth bound admits a false positive or misses a real plugin                  | discovery notes   | Verified |

### Dependencies

| ID   | Dependency                                                              | Owner      | Status |
| ---- | ---------------------------------------------------------------------- | ---------- | ------ |
| Dep1 | Phase 1 (Linear plugin's channel-two presence) landed on the build branch | maintainer | Open   |

## Testing Strategy

Sourced from `test-engineer` and `edge-case-explorer`. Tests are bats, run via `npm test` (`bats --recursive test/`),
against **synthetic `mktemp -d` fixtures** — never the live repository tree, because a test asserting the 8 drifted
plugins flips green when phase 4 lands, and a green-check assertion against the real repo goes red on phase 3's own PR
and stays red through phase 4 ([D-16](artifacts/implementation-decision-log.md#d-16-tests-use-synthetic-fixtures-phase-3-ships-script-and-bats-only)).
Precedent: `test/check-annotations.bats` builds files under `mktemp -d`.

- **Observable behaviors to test:**
  - `check` exits `0` on a synthetic tree where all four targets agree.
  - `check` exits `1` and names every gap at once on a tree with a missing listing entry, a missing record, a dangling
    listing entry, an unreadable/indeterminate version, and a plugin with no derivable publishing version (the five-gap
    list, spec D12/D36).
  - `check` exits `2` on an unreadable target and on an empty derived plugin set
    ([D-6](artifacts/implementation-decision-log.md#d-6-the-check-takes-no-mode-flag)).
  - `repair` writes the publishing version onto every writable record and creates a missing channel-two entry with the
    exact field set, no version ([D-7](artifacts/implementation-decision-log.md#d-7-the-created-channel-two-entry-carries-no-version)).
  - `repair` leaves an unsafe-to-write target untouched and lets `check` name it
    ([D-5](artifacts/implementation-decision-log.md#d-5-repair-skips-what-it-cannot-safely-write)).
  - The bundle is neither flagged, asked to agree on channel two, nor created there
    ([D-11](artifacts/implementation-decision-log.md#d-11-bundle-identity-is-derived-from-the-listing-name)).
- **Edge cases requiring coverage:** two broken (`null`) version values must not compare equal
  ([D-12](artifacts/implementation-decision-log.md#d-12-guard-the-jq-parse-and-null-traps)); a listing parse failure
  must exit `2`, not regenerate the storefront; the depth bound must not admit an authored `plugin.json` example
  ([D-13](artifacts/implementation-decision-log.md#d-13-derive-the-plugin-set-with-a-depth-bounded-jq-glob)).
- **Test doubles posture:** no external CLI to stub for the script itself (it reads local JSON with `jq`); fixtures are
  built on disk under `mktemp -d`.
- **Test levels:** unit/behavioral bats for the script; the release skill's prose-borne behavior is verified by the
  7-step Phase 3 demo (below), which cannot be unit-tested
  ([D-17](artifacts/implementation-decision-log.md#d-17-state-the-enforcement-limit-and-print-findings-verbatim)).

## Operational Readiness

`devops-engineer` contributed. The change adds no runtime service, no telemetry, no traffic — it is a repo-maintenance
skill plus a check script. The operational surface is the release gate and its recovery.

- **Rollout:** phase 1 precedes phase 3 (spec D41); phase 3 ships the script and bats tests under the existing
  `npm test` with no `ci.yml` change; the CI step and prek hook are deferred to phase 6
  ([D-16](artifacts/implementation-decision-log.md#d-16-tests-use-synthetic-fixtures-phase-3-ships-script-and-bats-only)).
  Forward note for phase 6: inherit `ci.yml`'s existing `push: main` trigger rather than narrowing to `pull_request`,
  for free post-hoc detection of a skipped release gate
  ([D-17](artifacts/implementation-decision-log.md#d-17-state-the-enforcement-limit-and-print-findings-verbatim)).
- **Gate signal:** the release gate at Step 4.5 is the operational signal; there is no external monitoring, deliberately
  (deferred under YAGNI — the drift persisted because nothing asked the question, not because nobody watched a graph).
- **Recovery / rollback:** the whole phase reverts by reverting its commit (the script lands with the skill edits). A
  gate stop recovers via a scoped `git restore` of the four tracked target paths, then the gap is corrected and
  committed on its own, then the release is planned from scratch — never `git clean`
  ([D-8](artifacts/implementation-decision-log.md#d-8-recovery-is-a-scoped-git-restore-never-git-clean)).

## Definition of Done

The bats and ShellCheck gates verify the script; the 7-step demo from build-phase-outline Phase 3 is the acceptance test
for the release skill's prose-borne behavior that cannot be unit-tested.

- [ ] `scripts/publishing-targets.sh` exists at the repository root, is `chmod +x`, passes ShellCheck, and exposes
      argument-free `check` and `repair` verbs ([D-1](artifacts/implementation-decision-log.md#d-1-the-publishing-writes-are-script-borne)).
- [ ] bats tests for the check contract (exit 0/1/2), the repair, the bundle exception, and the jq-trap edge cases pass
      under `npm test` against synthetic fixtures ([D-16](artifacts/implementation-decision-log.md#d-16-tests-use-synthetic-fixtures-phase-3-ships-script-and-bats-only)).
- [ ] `CONTRIBUTING.md` has an "Adding a plugin" section naming all four targets; lines 138 and 157 are unchanged
      ([D-15](artifacts/implementation-decision-log.md#d-15-add-an-adding-a-plugin-section-to-contributing)).
- [ ] The skill's Project Context and Step 3 enumerate from the repo-derived set; the frontmatter description's stale
      list is left alone ([D-13](artifacts/implementation-decision-log.md#d-13-derive-the-plugin-set-with-a-depth-bounded-jq-glob), [D-22](artifacts/implementation-decision-log.md#d-22-leave-the-frontmatter-descriptions-stale-list-alone)).
- [ ] **7-step Phase 3 demo passes:**
  1. Point at a plugin whose channel-two version has fallen behind; note the number channel two publishes.
  2. Delete that plugin's channel-two listing entry (the shape a contributor leaves when they forget a target).
  3. Cut a release; watch it read the plugin list from the repository, name its version plan, and ask for confirmation.
  4. Watch it report what it changed and what it created — the stale version corrected, the missing entry recreated,
     both named explicitly.
  5. See all four targets agree, and all four inside the commit the release tagged.
  6. Delete a plugin's channel-two **record** and cut a release; it stops before committing, names that gap and every
     other gap in the same run, and publishes nothing.
  7. Add a fake listing entry for a plugin not in the repository and cut a release; it stops for that too rather than
     deciding on its own.
- [ ] Post-ship owner: the Han maintainer.

## Specialist Handoffs for Implementation

- **`test-engineer`** — dispatch when writing the bats suite; needs the check contract
  ([D-6](artifacts/implementation-decision-log.md#d-6-the-check-takes-no-mode-flag)) and the synthetic-fixture posture
  ([D-16](artifacts/implementation-decision-log.md#d-16-tests-use-synthetic-fixtures-phase-3-ships-script-and-bats-only)).
- **`devops-engineer`** — dispatch when wiring the Step 4.5 gate and Step 8.1 staging; needs the recovery sequence
  ([D-8](artifacts/implementation-decision-log.md#d-8-recovery-is-a-scoped-git-restore-never-git-clean)) and the staging
  pathspec ([D-18](artifacts/implementation-decision-log.md#d-18-stage-by-class-pathspec)).

## Deferred (YAGNI)

### Enforcement wrapper (a script gating commit/push behind the check's exit code)

- **Why deferred:** Evidence-test failure. Guards a class with zero observed members — the observed failure was prose
  that was wrong, followed faithfully for eleven releases, not an agent skipping a step; and with Write/Edit granted it
  cannot in principle stop the actor it targets.
- **Reopen when:** A release is cut where the gate was skipped, or the check's output is absent from the Step 7 summary.
- **Source:** R1, junior-developer.

### Pre-flight check at Step 1 (so the operator is not stopped after approving a plan)

- **Why deferred:** Evidence-test failure. The stop classes have zero live members; spec D24 commits to one gate; at
  4.5 a stop costs one scoped `git restore`.
- **Reopen when:** The gate stops a real release twice.
- **Source:** R1, devops-engineer.

### Mode flag / `--json` / `--dry-run` / `--fix` / severity taxonomy on the check

- **Why deferred:** Evidence-test failure (both callers need the same answer) and simpler-version test (an exit code
  beats a taxonomy).
- **Reopen when:** A third caller needs a different answer.
- **Source:** R1, junior-developer and devops-engineer.

### A version plan enumerating every target the release will touch (OQ-5 Option B)

- **Why deferred:** Evidence-test failure. D39's report covers the notice; approving a derivable drifted-version
  correction is approving arithmetic.
- **Reopen when:** A maintainer is surprised by a version the release wrote.
- **Source:** R1, junior-developer.

### Tests of the SKILL.md prose

- **Why deferred:** Evidence-test failure. There is no way to test that an agent follows an instruction, and a test that
  cannot fail is worse than none.
- **Reopen when:** The enforcement-wrapper trigger fires.
- **Source:** R1, junior-developer and test-engineer.

### Structured logging / metrics / monitoring on gate stops

- **Why deferred:** Evidence-test failure. Nothing consumes them; solo maintainer, no telemetry, no runtime. The spec
  already deferred external monitoring.
- **Reopen when:** Drift recurs despite the gate.
- **Source:** R1, devops-engineer.

### A derivation path for a non-"Developer Tools" category or non-default policy on created entries

- **Why deferred:** Evidence-test failure. All existing entries are 100% uniform; keep the constants and note the
  assumption (A2).
- **Reopen when:** A plugin needs a different category or policy.
- **Source:** R1, edge-case-explorer.

### Semver prerelease / build-metadata handling

- **Why deferred:** Evidence-test failure. All 11 versions are plain `x.y.z` today (A3).
- **Reopen when:** A plugin adopts a prerelease scheme.
- **Source:** R1, edge-case-explorer.

### Symmetric change-detection exclusion for `{source}/.claude-plugin/plugin.json`

- **Why deferred:** Beyond phase 3's remit. It would also stop a description-only edit from bumping — a behavior change
  with no measured instance.
- **Reopen when:** A description-only edit to `.claude-plugin/plugin.json` causes an unwanted bump.
- **Source:** R1, devops-engineer.

## Open Items

- **OI-1 (spec OQ-5):** What should a release do when the approved plan and a target's repair disagree?
  - **Resolves when:** Resolved — Option A, discharged by the spec
    ([D-20](artifacts/implementation-decision-log.md#d-20-oq-5-is-discharged-by-the-spec-as-option-a)).
  - **Blocks implementation:** No — struck from the preconditions.
- **OI-2 (Dep1):** Phase 1 landed on the build branch (A1).
  - **Resolves when:** The maintainer confirms phase 1 is present on the branch this work builds from.
  - **Blocks implementation:** No — phase 3's code lands regardless; the first *release* after phase 3 stops on the
    Linear plugin if phase 1 is absent, which is the spec's intended behavior (D41), not a defect.

## Summary

- **Outcome delivered:** a release derives its plugin set from the repository, repairs all four targets, and refuses
  every gap only a person can close, via one executable bearer the pull-request check will reuse unchanged.
- **Team size:** 5 specialists (project-manager plus four) — see
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Rounds of facilitation:** 1 — see
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)
- **Decisions committed:** 22 — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by evidence:** 22 — see
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by junior-developer reframing:** 0 (reframing fed evidence; all 22 resolved by evidence or
  convergence) — see [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Decisions settled by user input:** 0 — see
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Rejected alternatives recorded:** 25 — see
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Open items remaining:** 2 (both non-blocking)
- **Recommendation:** Ship as planned. One round; converged. No blocking open item; OI-2 is a dependency the maintainer
  confirms before the first post-phase-3 release, not a code blocker.
