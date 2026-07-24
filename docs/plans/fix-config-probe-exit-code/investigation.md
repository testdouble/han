# Investigation: `.han/config.md` probe fails skill invocation when the file is absent

A probe command shipped without an exit-0 guard, so it aborts every Han skill run in a project that has no `.han/config.md` file. The fix guards that command in all 39 SKILL.md files. Read the summary below, then approve the Planned Fix or push back.

## What's broken and how to fix it

- **Root Cause:** The probe command `cat .han/config.md 2>/dev/null` exits with status 1 when the file does not exist, and Claude Code's skill loader fails any `!`-backtick pattern whose command exits nonzero, so every skill run in a project without the config file aborts before the skill body loads (E1, E2, E10).
- **Fix:** Replace the probe line in all 39 SKILL.md files with `cat .han/config.md 2>/dev/null || echo ""`, the loader's own recommended guard idiom. This makes the command always exit 0 and still produce empty output when the file is absent, exactly the "probe returns nothing, no config present" state the config rule already defines (E6, E10).
- **Why Correct:** Both halves of the fixed command are on the loader's documented auto-approve allowlist, and the `2>/dev/null || echo` shape is the guard already proven by fifteen-plus working probes across the suite (E4, E10). Validation rejected the originally proposed `|| true` form, because `true` appears nowhere on that allowlist and the form is untested against the loader (V1).
- **Validation Outcome:** The adversarial validator confirmed the root cause, the 39-file scope, and the byte-identical claim (V3, V4). It refuted the first-draft `|| true` fix form (V1), which was replaced with the allowlisted `|| echo ""` form, and it confirmed the pre-commit hooks leave the line untouched (V6).
- **Remaining Risks:** An unreadable-but-present config degrades silently instead of with the contract's one-line note (V2); the fix should get one live spot-run in a config-less project before release; the repo-internal `han-release` skill carries two same-class unguarded `jq` probes worth a follow-up (V8). See the Confidence Assessment.

## Problem Statement

Running any Han skill in a project that has no `.han/config.md` throws an error and the skill does not execute. The reported reproduction ran `/han-planning:plan-a-feature` in a consuming project and got:

```
Error: Shell command failed for pattern "!`cat .han/config.md 2>/dev/null`":
```

The expected behavior is the opposite, and it is written into the feature's own contract: a missing config file means "no config present," the skill behaves exactly as it does without the feature, and nothing is said about it (E6). The config file is optional by design, so the absent-file state is the normal state for most projects.

Every one of the 39 Han skills carries this probe line (E3), so the bug blocks the entire suite in any project that has not created the optional file. That makes it a release blocker for the `han-config` branch.

## Why the probe fails

### Root Cause

`cat` on a missing file exits with status 1, even when stderr is redirected. Claude Code's skill loader treats a nonzero exit from a `!`-backtick context probe as a hard failure of the skill invocation. The probe line shipped without the exit-0 guard that the loader's guidance recommends and that every other probe in the suite carries.

### The three-link failure chain

Each link in the chain is backed by evidence.

First, the command itself. `2>/dev/null` suppresses the "No such file or directory" message but does not change the exit status. Reproduced directly in this repo, where no `.han/config.md` exists: the bare command exits 1 (E1).

Second, the loader. Claude Code runs `!`-backtick probes at skill load, before the skill body is read, and fails the load when a probe's command exits nonzero. The error text in the reproduction matches this failure mode exactly, naming the probe pattern verbatim (E2).

The repo's own probe-authoring guidance separates this from the loader's other failure mode. A command that is not auto-approvable is rejected with a different message (`Shell command permission check failed ... requires approval`), so the reported error belongs to the execution-failure family, not the permission family (E10). The permission explanation is independently ruled out: `readability-guidance` carries the same probe with no Bash grant at all in its allowed-tools, and its probe succeeds whenever the file exists (V3).

Third, the convention gap. Every other probe across all 39 SKILL.md files is exit-0-safe by construction: `find` exits 0 whether or not it matches, tool checks use `which ... || echo "not installed"`, git-state probes use `... || echo unknown`, and one probe pipes through `head`, which always exits 0 (E4). The loader guidance names this exact guard (`2>/dev/null || echo <sentinel>`) as the recommended compound for "any command that exits non-zero when its subject is absent" (E10).

The `.han/config.md` probe is the only one with no guard. It was added across the suite in commits `172ce8d` and `5ca6f3b` on the `han-config` branch (E5). The prose written next to it in those same commits ("When it returns nothing, no project config is present and nothing changes") states the intended silent behavior, but the chosen command cannot deliver it: the run dies in the loader before that prose is ever read.

The bug never surfaced during the branch's own verification because the completeness check was a structural grep, and the manual spot-runs against an absent config had not been run yet.

## Planned Fix

### Chosen fix and rejected alternatives

The fix changes the probe line in all 39 SKILL.md files to `cat .han/config.md 2>/dev/null || echo ""`. It also spot-verifies one skill against the live loader before sweeping the rest, and refreshes the one live doc that quotes the old command text.

The team weighed three candidate forms, and validation changed the choice.

- **`|| echo ""` (chosen).** Both parts (`cat`, `echo`) are on the loader's documented auto-approve allowlist. The `2>/dev/null || echo` compound is the guidance's recommended guard, already proven by fifteen-plus shipped probes (E4, E10). The fallback output is a blank line, so on absence the probe still "returns nothing": the exact absence signal the config rule and all 39 pointer paragraphs already describe (E6). No other file changes.
- **`|| true` (first draft, rejected).** Correct in a bare shell (E1), but `true` appears nowhere on the loader's enumerated allowlist, no live SKILL.md uses it, and the form was never tested against the loader itself. It risked trading the exit-status failure for an untested permission rejection (V1).
- **`|| echo "none"` and `test -f ... && cat ...` (rejected).** A visible sentinel lands in a slot the skills treat as file content, breaking the "probe returns nothing" absence contract and colliding with legitimate content (E8). The `test -f` form adds a check no other probe uses, does not help the unreadable-file case (`test -f` passes on a permission-denied file), and `test` is likewise not on the enumerated allowlist (E8, V7).

### Files to change

#### Spot verification first: one SKILL.md against the live loader

- **Change:** Apply the new probe line to a single skill. Then invoke that skill in a project (or scratch directory) with no `.han/config.md` and confirm the skill loads with no error and an empty probe value. Also invoke it with the file present and confirm the content is injected.
- **Evidence:** (V1): the first-draft fix failed validation precisely because the form was never run against the loader. This gate keeps the same mistake from shipping twice.
- **Details:** Any cheap skill works; `han-communication:readability-guidance` is a good candidate because its allowed-tools has no Bash grant, making it the strictest permission case (V3).

#### All 39 `*/skills/*/SKILL.md` files (complete list in E3)

- **Change:** Replace the probe line, identically in every file:

  ```markdown
  - .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`
  ```

- **Evidence:** (E1) the guard forces exit 0; (E10) both parts and the compound shape are loader-approved; (E3) enumerates the full fix surface; (E4) shows the guard matches the suite's proven convention.
- **Standards:** The probe-hardening convention and the loader guidance's recommended guard (Coding Standards Reference below); the config-rule contract that absence means empty output (E6).
- **Details:** Apply this as a mechanical, byte-identical replacement across the 39 files (a scripted, `grep`-verified pass, mirroring how the line was introduced), so no file diverges. No pointer paragraphs, `config-rule.md` copies, or allowed-tools lists change. None of the 12 vendored rule copies, `docs/configuration.md`, `CLAUDE.md`, or any README quotes the command text (E7, V5), and the pointer paragraphs' "when the probe returns nothing" phrasing already matches the fixed behavior (V9). Verify completion with the same greps used on the branch: 39 files matching the new probe text, 0 matching the old.

#### `docs/research/han-config-extensibility.md`

- **Change:** Update the one inline example at line 105 that quotes the old command, so the report's illustration matches the shipped probe.
- **Evidence:** (E8, V5): this is the only file outside the frozen `docs/plans/` history that quotes the command verbatim.
- **Details:** Replace the quoted `` !`cat .han/config.md 2>/dev/null` `` with `` !`cat .han/config.md 2>/dev/null || echo ""` ``. One-line edit.

## Evidence Summary

### E1: The bare probe exits 1 on absence, a guarded probe exits 0

- **Source:** Shell reproduction in this repo (no `.han/` present) and in an empty scratch directory.
- **Finding:**
  ```
  cat .han/config.md 2>/dev/null; echo "exit=$?"
  exit=1
  (cat .han/config.md 2>/dev/null || true); echo "exit-with-fallback=$?"
  exit-with-fallback=0
  ```
- **Relevance:** Direct mechanical cause: `2>/dev/null` redirects only the error text, not the exit status, and an `||` fallback forces exit 0. (This shell-level check motivated the first-draft `|| true` form; the shipped form swaps the fallback to the allowlisted `echo ""` for the loader-approval reasons in E10/V1, with identical exit behavior.)

### E2: Claude Code fails a `!`-pattern on nonzero exit, matching the reported error verbatim

- **Source:** Reported error screenshot from a consuming-project run of `/han-planning:plan-a-feature`.
- **Finding:**
  ```
  Error: Shell command failed for pattern "!`cat .han/config.md 2>/dev/null`":
  ```
- **Relevance:** The loader names the exact probe pattern and fails the skill invocation before the skill body runs, tying the symptom to the probe's exit status rather than to anything in the skill's own steps. The wording also distinguishes it from the loader's permission-rejection message (E10).

### E3: All 39 SKILL.md files carry the identical probe line, the complete fix surface

- **Source:** `grep -rln "cat .han/config.md" --include="SKILL.md"` → 39 matches; line-level uniqueness check found exactly one variant (V4).
- **Finding:** `han-coding` (9): `coding-standard:19`, `architectural-analysis:21`, `investigate:19`, `code-review:21`, `automated-test-planning:41`, `code-overview:25`, `tdd:24`, `manual-test-planning:17`, `refactor:24`. `han-atlassian` (6): `work-items-to-jira:24`, `markdown-to-confluence:21`, `project-documentation-to-confluence:20`, `plan-a-feature-to-confluence:21`, `investigate-to-confluence:19`, `code-overview-to-confluence:20`. `han-planning` (5): `plan-implementation:17`, `plan-work-items:19`, `iterative-plan-review:18`, `plan-a-phased-build:18`, `plan-a-feature:19`. `han-github` (3): `update-pr-description:27`, `post-code-review-to-pr:27`, `work-items-to-issues:16`. `han-research` (3): `research:24`, `issue-triage:17`, `gap-analysis:19`. `han-documentation` (3): `architectural-decision-record:41`, `runbook:50`, `project-documentation:20`. `han-plugin-builder` (3): `guidance:16`, `skill-builder:15`, `agent-builder:15`. `han-communication` (2): `readability-guidance:15`, `edit-for-readability:19`. `han-reporting` (2): `stakeholder-summary:17`, `html-summary:15`. `han-core` (1): `project-discovery:18`. `han-linear` (1): `work-items-to-linear:24`. `han-feedback` (1): `han-feedback:15`.
- **Relevance:** The line is byte-identical everywhere, so the fix is one mechanical replacement across 39 files, and any file left behind diverges in behavior.

### E4: Every other probe in the suite guarantees exit 0; this is the sole unguarded one

- **Source:** Exhaustive sweep of all `!`-backtick probes across `*/skills/*/SKILL.md` (68 probe lines examined), e.g. `han-coding/skills/tdd/SKILL.md:20-21`, `han-core/skills/project-discovery/SKILL.md:14-17`, `han-coding/skills/refactor/SKILL.md:21`, `han-github/skills/post-code-review-to-pr/SKILL.md:16-26`.
- **Finding:**
  ```
  - git installed: !`which git 2>/dev/null || echo "not installed"`
  - current branch: !`git branch --show-current 2>/dev/null || echo unknown`
  - CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
  - working tree: !`git status --porcelain 2>/dev/null | head -5`
  ```
- **Relevance:** The repo already has a load-bearing hardening convention: 15+ `|| echo` guards, `find` for every file-presence check, and pipeline-through-`head`. The failing probe is the one place the convention was not applied. The suite never uses bare `cat` for optional files anywhere else.

### E5: The probe was introduced by commits `172ce8d` and `5ca6f3b` on branch `han-config`

- **Source:** `git log -S 'cat .han/config.md 2>/dev/null' --all`; `git show 172ce8d`.
- **Finding:** `172ce8d feat(config): read .han/config.md from every skill with a Project Context block` added the line to the 24 skills with existing blocks. `5ca6f3b feat(config): add a minimal config-only Project Context block to skills that had none` extended it to the other 15. The commits' own adjacent prose states "When it returns nothing, no project config is present and nothing changes."
- **Relevance:** Pinpoints the regression's origin and shows the intent (silent absence) was documented at the moment the command that contradicts it shipped.

### E6: The canonical config rule requires exactly the behavior the fix restores

- **Source:** `han-core/references/config-rule.md:34-35` and its 11 md5-identical vendored copies.
- **Finding:**
  ```
  When the probe returns nothing, no config is present: behave exactly as the skill does without this rule, with no note.
  ...
  A bad config can never fail a skill run; the worst it can do is be ignored.
  ```
- **Relevance:** The contract defines absence as empty probe output and forbids config-related failures outright. The current probe violates the second line at a level above the skill: the invocation aborts. The `|| echo ""` fix satisfies both lines with no contract change.

### E7: No live doc outside the SKILL.md files quotes the command, except one research report

- **Source:** Verbatim-text search across `CLAUDE.md`, `README.md`, every `*/README.md`, `docs/configuration.md`, all 12 `config-rule.md` copies, and the `han-plugin-builder` guidance tree; re-verified during validation (V5).
- **Finding:** Zero matches in all of those surfaces; the rule files describe the probe's behavior ("the inline probe in its `## Project Context` block") without quoting its command text. The one live exception is `docs/research/han-config-extensibility.md:105`.
- **Relevance:** The fix surface stays small: 39 probe lines plus the one research-report example. Nothing else goes stale.

### E8: Candidate-fix comparison across the four forms

- **Source:** Analysis against E4's convention, E6's contract, and E10's loader allowlist; refined by validation findings V1 and V7.
- **Finding:** (a) `|| echo ""`: exit 0, blank-line output on absence; both parts allowlisted; matches the documented guard idiom; contract-compliant. (b) `|| true`: exit 0 and empty output in a shell, but `true` is absent from the loader's enumerated allowlist and no live probe uses it, so it is untested against the mechanism that produces the bug. (c) `|| echo "none"`: exit 0 but the probe then never returns nothing; the sentinel lands in a slot the skills treat as file content, so absence detection breaks and `none` becomes indistinguishable from a one-word config. (d) `test -f ... && cat ... || true`: correct output but a shape no other probe uses; `test -f` still passes on a permission-denied file so it does not help the unreadable case; `test` is also not on the enumerated allowlist.
- **Relevance:** Grounds the "Chosen fix and rejected alternatives" choice: (a) is the only form that is loader-documented, convention-proven, and contract-compliant at once.

### E9: One same-class latent probe exists outside the shipped plugins

- **Source:** `.claude/skills/han-release/SKILL.md:37,39`: `jq -r ... 2>/dev/null` probes.
- **Finding:** `jq` exits nonzero on missing or invalid input even with stderr suppressed, the same failure class. `jq` is not on the loader allowlist, but the skill declares `Bash(jq *)`, so only the exit-status half of the failure class applies.
- **Relevance:** Out of scope for this fix: the file is repo-internal maintenance tooling, not shipped to consuming projects. The validator flagged its inputs as fragile: `marketplace.json` is hand-edited during every release, exactly when a transiently malformed file would fail the probe (V8). A follow-up fix (adding the same guard) is recommended rather than leaving this as a footnote.

### E10: The loader's documented allowlist and recommended guard idiom

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md:49-59` and `:106-111`; `troubleshooting.md:353`.
- **Finding:**
  ```
  The loader ships a fixed allowlist that already covers most inspection tools, including `cat`, `ls`, `head`,
  `tail`, `wc`, `grep`, `find` (without the dangerous predicates below), `which`, `echo`, `date`, and the
  read-only `git` and `gh` subcommands ...
  Pipes and `&&` / `;` / `||` chains are not forbidden. The loader splits them and checks each part ...
  One compound form is not only allowed but recommended: the trailing `2>/dev/null || echo <sentinel>` guard.
  ```
  The troubleshooting guidance documents a distinct error string for permission rejections (`Shell command permission check failed ... requires approval`) versus the execution failure reported here (`Shell command failed for pattern`).
- **Relevance:** Confirms the two-part mechanism: each chain part is classified, and nonzero exit fails the load. It confirms the reported error is the execution family and names the exact guard the fix adopts. `true` is absent from every enumeration in the file, which is what disqualified the first-draft fix (V1).

## Validation Results

An adversarial-validator pass attacked the evidence, the root cause, and the first-draft fix. It confirmed the diagnosis and the scope, and it refuted the first-draft fix form, which was replaced before this plan was finalized.

### Counter-Evidence Investigated

#### V1: The first-draft `|| true` form was never tested against the actual loader

- **Hypothesis:** `|| true` might not be a construct the context-injection loader auto-approves, trading the exit-status failure for an untested permission rejection.
- **Investigation:** Read the loader guidance (`context-injection-commands.md:49-54,106-111`): its fixed allowlist enumerates `cat`, `echo`, and friends but never `true`, and its only recommended guard is `2>/dev/null || echo <sentinel>`. Grepped every live SKILL.md: zero uses of `|| true` (it appears only in `.sh` scripts that run through the Bash tool, a different permission layer). E1's reproduction proves shell exit semantics only, not loader classification.
- **Result:** Partially Refuted: the root cause stands, but the first-draft fix form rested on an untested assumption.
- **Impact:** The fix form changed to `|| echo ""` (both parts allowlisted, idiom documented and production-proven), and a one-skill live spot-verification step was added ahead of the 39-file sweep. See Adjustments Made.

#### V2: The guard collapses "config absent" and "config unreadable" into the same silent path

- **Hypothesis:** Forcing exit 0 hides genuinely broken states (a permission-denied file, or `.han/config.md` existing as a directory) which the contract says should get a one-line note.
- **Investigation:** Read the degradation section of `config-rule.md`: "a file unreadable as text: ignore the unusable portion ... and note what was ignored" is a distinct promise from the silent absent-file path. `cat` exits nonzero identically for missing, permission-denied, and directory targets, so the probe cannot distinguish them.
- **Result:** Confirmed as a real, accepted gap: an unreadable-but-present file behaves as absent, without the promised note. Failing the run (the only alternative available at probe level) is worse under the contract's top line ("a bad config can never fail a skill run").
- **Impact:** No code change; the summary at the top and the Confidence Assessment section state the risk plainly instead of calling the risk list empty.

#### V3: Permission denial as an alternate root cause

- **Hypothesis:** The error might come from the probe command lacking an allowed-tools grant, in which case no `||` guard would help.
- **Investigation:** `cat` is explicitly on the loader's fixed allowlist and needs no grant (E10). The strongest counter-example: `readability-guidance`'s allowed-tools is `Read` alone (no Bash entry of any kind), yet it carries the same probe, which succeeds whenever the file exists. Permission rejections also produce a different documented error string than the one reported.
- **Result:** Refuted as an alternative cause; exit status stands as the mechanism.
- **Impact:** Confirms the fix needs no allowed-tools changes in any of the 39 files.

#### V4: The 39-file count and byte-identical claim

- **Hypothesis:** The file list might be incomplete or the line might vary (whitespace, CRLF, quoting) across files, breaking a mechanical replacement.
- **Investigation:** Re-ran the count independently (39) and reduced all matching lines to unique variants: exactly one. Spot-checked five cited line numbers against the live files; all matched.
- **Result:** Confirmed.
- **Impact:** None; the mechanical single-pattern replacement is safe.

#### V5: Other files quoting the command text

- **Hypothesis:** More live files than the one research report might quote the command and go stale.
- **Investigation:** Repo-wide verbatim search excluding SKILL.md files: one live hit (`docs/research/han-config-extensibility.md:105`) plus hits only inside `docs/plans/`, which the repo's own `docs/plans/CLAUDE.md` freezes. Confirmed `docs/research/` is excluded from Prettier and pre-commit hooks but not from manual editing, so it is correctly in scope.
- **Result:** Confirmed.
- **Impact:** None; the two-target fix surface stands.

#### V6: Pre-commit or Prettier hooks mangling the fixed line

- **Hypothesis:** The repo's formatting hooks might rewrite the probe line and break it after the fix lands.
- **Investigation:** `.prettierignore` excludes all `*.md` (with a comment explaining markdown is the product), and every whitespace/EOL hook in `.pre-commit-config.yaml` excludes `.md`. Reproduced directly: ran Prettier over a scratch file carrying the guarded probe line; output unchanged.
- **Result:** Confirmed safe (a failure mode the first draft never checked).
- **Impact:** None.

#### V7: The `test -f` alternate as a better fix

- **Hypothesis:** `test -f .han/config.md && cat .han/config.md || true` might handle the unreadable-file gap the chosen form accepts.
- **Investigation:** Traced the semantics: `test -f` passes on a permission-denied file (it checks existence and type, not readability), so the unreadable case degrades identically; on a missing file the behavior is identical to the simpler form; `test` is also not on the enumerated allowlist.
- **Result:** Confirmed: no functional advantage, extra nonconventional shape, same loader-approval risk.
- **Impact:** None; the rejection in E8(d) stands.

#### V8: The `han-release` jq probes as a recurrence of the same bug class

- **Hypothesis:** Scoping the `.claude/skills/han-release/SKILL.md:37,39` jq probes out understates their risk.
- **Investigation:** Confirmed the probes are unguarded and that their input, `marketplace.json`, is hand-edited during every release, exactly the moment a transient syntax error would fail the probe. The file is repo-internal, so consuming projects are unaffected.
- **Result:** Partially Refuted on risk framing (the facts stood): same regression class, likely to recur.
- **Impact:** Recorded as a recommended follow-up (add the same guard to those two probes) rather than a footnote; still outside this fix's scope.

#### V9: Pointer-paragraph prose conflicting with empty-output absence

- **Hypothesis:** Some of the 39 files' pointer paragraphs might describe absence in a way a blank-line probe output contradicts.
- **Investigation:** Inspected the pointer text in all 39 files: every one uses "When the `.han/config.md` probe returns content ... When it returns nothing, no project config is present" (or project-discovery's consistent variant). No file expects an error, a sentinel, or any non-empty absence signal.
- **Result:** Confirmed.
- **Impact:** None; no pointer paragraph changes.

### Adjustments Made

- **Fix form replaced (V1):** `|| true` → `|| echo ""` throughout the plan, and the E8 comparison was reworked around the loader allowlist evidence (new E10).
- **Spot-verification gate added (V1):** one SKILL.md is verified against the live loader in a config-less project before the 39-file sweep.
- **Risk reporting corrected (V2):** the summary at the top now names the unreadable-file silent degradation instead of claiming no material risks.
- **Evidence strengthened (V3):** the zero-Bash-grant `readability-guidance` counter-example and the distinct permission-error string were added to the root-cause analysis.
- **Follow-up elevated (V8):** the `han-release` jq probes moved from a footnote to a named recommended follow-up in E9 and Remaining Risks.

### Confidence Assessment

- **Confidence:** High
- **Remaining Risks:**
  - The chosen form still awaits its one live loader spot-run (the verification gate under Files to change). Its components and shape are documented as auto-approvable and proven by 15+ shipped probes, so the residual risk is small.
  - An unreadable-but-present config file degrades silently instead of with the contract's one-line note (V2), accepted since the only probe-level alternative is failing the run.
  - The `han-release` jq probes (E9, V8) share the failure class and should get the same guard in a follow-up.
  - A `.han/config.md` that is a directory or symlink loop behaves as absent, consistent with V2's accepted trade.

## Coding Standards Reference

| Standard                                                                                        | Source                                                                                              | Applies To                             |
| ----------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | -------------------------------------- |
| Context probes must be auto-approvable and exit-0-safe; the recommended guard is `2>/dev/null \|\| echo <sentinel>` | `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md:49-59,106-111` | The replacement probe line             |
| Absence is signaled by empty probe output, never a visible sentinel string                       | `han-core/references/config-rule.md:34-35` (and 11 vendored copies)                                  | Choice of `\|\| echo ""` over a sentinel |
| Suite-wide lines stay byte-identical across files; verify with a grep completeness check         | Branch precedent: commits `172ce8d`/`5ca6f3b` and the branch's completeness check                    | The 39-file replacement pass           |
