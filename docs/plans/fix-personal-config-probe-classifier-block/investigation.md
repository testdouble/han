# Investigation: the personal-config probe can be refused at load, and the refusal kills the skill

The personal-config probe aborts a skill whenever it gets refused at load. Read the Summary below, then approve the
Planned Fix or push back.

## Summary

- **Root Cause:** Every Han skill reads the personal `.han/config.md` through a load-time shell probe that reaches
  outside the project into the Claude Code configuration directory. A load-time probe that gets refused cannot prompt
  and cannot degrade, so it aborts the whole skill (E1, E2, E4).
- **Fix:** Move the personal-config read out of the shell probe and into a Read-tool step, keeping the directory probe.
  Verify on one skill under the conditions that failed, then fan out to the other 39 and update the contract, the
  authoring guidance, and the changelog.
- **Why Correct:** Three things point to it. The refusal named the personal-config probe and nothing else (symptom,
  E4). It is the only probe in the suite that reads a path outside the working directory (E1). And the Read tool
  served the same file with no prompt (E8).
- **Validation Outcome:** Validation confirmed the structural root cause but refuted the first draft's confident claim
  about *why* the classifier objected (V1, V2, V3). It also found the fix under-specified in three places (V4, V6) and
  short one verification step (V5, V8). All five are corrected below.
- **Remaining Risks:** The classifier is closed-source, so no one can prove which property of the command it objected
  to. See Confidence Assessment.

## The failure and the conditions that trigger it

Running `/han-coding:code-overview` in a project aborted before the skill did any work. The error:

```
Error: Shell command permission check failed for pattern
"!`cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.han/config.md" 2>/dev/null || echo ""`":
Permission for this action was denied by the Claude Code auto mode classifier.
Reason: Blocked by classifier.
```

The expected behavior is that a skill with no personal config, or an unreadable one, runs normally on its defaults. The
config rule promises exactly that: a bad config "can never fail a skill run; the worst it can do is be ignored"
(`han-core/references/config-rule.md:108`).

The conditions are a person carrying a personal `.han/config.md` in their Claude Code configuration directory, running
a Han skill in a project, with the permission mode set to auto. The user's file held `output-directory: ".scratch/"`.

The impact reaches all 40 skills in the suite. Every one carries the same probe, byte for byte (E1). When the refusal
happens, the affected skill does not run at all.

## Root Cause Analysis

### Root Cause

The personal-config probe runs at skill load, where a permission refusal has no recovery path. It is also the one
probe in the suite that reads a file outside the project working directory, the kind of read a permission classifier
is built to question.

### Why the refusal happens

Three facts combine into the failure, and only the third is specific to this probe.

The first is structural. Context injection runs when the skill loads, and the loader "never prompts. If a command is not
auto-approvable, the loader hard-rejects it and stops loading the skill" (E4). There is no fallback. A probe that any
permission layer declines takes its skill down with it, which is why a probe's approval has to be certain rather than
likely.

The second is that approval was treated as a property of the command's *name*. Han's own authoring guidance models
approval as a fixed allowlist keyed on the command, and it lists `cat` on that allowlist with no caveat about arguments
or target paths (E4). Under that model the probe is safe. The refusal shows the model is incomplete: something looked at
this `cat` and declined it, and the guidance describes no layer that would (E4).

The third is what makes this probe different from its 39 siblings and from the project probe beside it. It is the only
probe in the suite whose target resolves outside the project working directory, into the directory that also holds the
user's Claude Code credentials and settings. The refusal named that probe and no other (symptom). In file order the
probes before it are `which git`, `which gh`, two `find` calls, and the `echo` that resolves the directory, all of which
were reached without complaint (E2, V1).

The first draft of this analysis went one step further and claimed the classifier objected specifically because the path
lands in `$HOME/.claude`. Validation refused to let that stand (V1, V2, V3), and it was right to. The classifier is
closed-source. Nobody in this repo has read it; the original design plan said so twice (E6). The competing explanations
are alive: the `||` chain, the `${VAR:-default}` expansion, the nested quotes, or a stale allowlist in Claude Code
itself. The fix does not need that question settled. It needs the probe out of a position where any refusal is fatal.

The suite reached this position because the design pass that added the probe verified the wrong property. It checked
four times that the probe *loads*, varying whether `CLAUDE_CONFIG_DIR` was set and whether the file existed (E6). It
never varied permission behavior. Its six-entry risk register has no entry for a runtime refusal, and its central
assumption is still marked open (E6). The check also ran with `CLAUDE_CONFIG_DIR` pointed at a stand-in directory, so
the default-to-`$HOME/.claude` branch the failing user hit was never exercised (V1, V8).

## Planned Fix

### Read the config with the Read tool, not a shell probe

Read the personal config with the Read tool during the run, instead of with a shell probe at load. That way, a
permission decision on that read can no longer abort the skill.

### Verify before fanning out

The 40-file sweep is gated on one live check, which is the same protocol the original feature used and the correction
validation asked for (V5, V8). Patch `han-communication:readability-guidance` alone, because it declares only `Read` and
is the tightest permission case in the suite (E9). Then, from a cold session in a project outside this repo, with
`CLAUDE_CONFIG_DIR` unset, a real `~/.claude/.han/config.md` in place, and auto mode on, confirm both halves:

1. An unpatched skill still fails, so the reproduction is real.
2. The patched skill loads, reads the file, and applies `output-directory`.

If the patched skill's Read call draws its own refusal, stop. The fix is wrong and the alternatives below come back into
play.

### Changes

#### The 40 `SKILL.md` files

- **Change:** Drop the personal `cat` probe. Keep the `echo` directory probe and the project `cat` probe. Replace the
  follow-up paragraph so it directs a Read-tool call for the personal file.
- **Evidence:** (E1), (E2), (E4), (E8), (E9)
- **Standards:** The context-injection rules in
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md`; the
  interpretation contract in `han-core/references/config-rule.md`.
- **Details:** All 40 files carry this block byte for byte, verified by hash, so one substitution covers every file
  (E1). The block becomes:

```markdown
## Project Context

- personal config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. A file that reads but cannot be used degrades
under the config rule's existing note. When that file or the `project .han/config.md` probe supplies content, apply it
per the config rule in [../../references/config-rule.md](../../references/config-rule.md). The project file overrides
the personal one setting by setting, and a relative path in either file resolves against that file's own directory.
When neither supplies content, no config is present and nothing changes.
```

  Two details in that wording come from validation. "As your first action" replaces "before your first step," because
  several skills, including both inline guidance skills, have no numbered steps to sit in front of (V6).

  The split between a read that returns nothing and a file that reads but cannot be used preserves the config rule's
  own distinction. An absent file stays silent; a malformed one earns a one-line note (V6).

  No `allowed-tools` line changes. Every skill that declares one already lists `Read`. The eight that leave the key
  empty declare no auto-approved tools at all, which leaves Read reachable there too (E9, V7).

#### `han-core/references/config-rule.md`, and its 11 vendored copies

- **Change:** Rewrite the "three probes" section as two probes plus a Read step, and add a degradation bullet for a
  personal read that cannot complete.
- **Evidence:** (E5), (V4), (V6)
- **Standards:** The vendoring convention in `CLAUDE.md`: edit the canonical `han-core` copy, then re-sync the other 11
  byte for byte.
- **Details:** The heading at line 11 and the sentence at line 13 both say "three probes" and need to describe the new
  shape. The `personal .han/config.md` bullet at line 18 becomes a Read step rather than a probe. Line 68 refers to
  "the `personal config directory` value the probe supplied", which stays accurate, since that probe survives. The
  degradation list at lines 117-125 gains a bullet: a personal config the run cannot read is treated as no personal
  config, with no note, matching the existing unreachable-directory bullet. All 12 copies currently share one checksum
  (E5), so confirm they share one again afterward.

#### `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md`

- **Change:** Add a rule that a context probe reads only inside the project working directory, and soften the
  allowlist's promise so it no longer reads as approval guaranteed by command name alone.
- **Evidence:** (E4), (V2)
- **Standards:** The guidance's own existing rule shape (named rule, before and after examples, entry in the "What NOT
  to Use" table).
- **Details:** This is the change that stops the suite from walking back into the same hole. Word the rule around the
  consequence rather than around a mechanism nobody has inspected (V2). A probe cannot prompt and cannot degrade, so a
  probe that reads outside the project stakes the whole skill on a permission decision you cannot predict. Gather that
  data in a step instead. The allowlist passage at lines 49-54 currently promises that listed commands "need no
  `allowed-tools` entry"; note there that the list covers the command, not its arguments, and that the observed refusal
  is the evidence.

#### `han-plugin-builder/skills/guidance/references/skill-building-guidance/troubleshooting.md`

- **Change:** Add a symptom entry for a probe refused by the auto-mode classifier.
- **Evidence:** (E4)
- **Standards:** The file's existing Symptom, Cause, Fix structure.
- **Details:** The file documents two probe failure modes today, a nonzero exit and the literal bang-backtick pattern
  appearing in prose (line 353). The refusal is a third, and its error text differs from both. Quote it so the next
  person searching the phrase lands here.

#### `CHANGELOG.md`

- **Change:** Add a fix entry describing the behavior change.
- **Evidence:** (E1)
- **Standards:** The existing changelog format.
- **Details:** Name that personal-config reading moved from a load-time probe to a Read-tool step, and that this
  unblocks skills that previously failed to load.

### What is deliberately not changing

The project probe, `cat .han/config.md`, stays a probe. Its path is relative to the working directory, it reads a file
the run is already working in, and no observed refusal has touched it.

Validation raised one case against that: someone whose working directory *is* their Claude Code configuration directory,
which the config rule explicitly designs for at lines 29-31 (V4). There the project probe reads a file in the same
directory the personal probe was reading. The risk is worth naming and not worth acting on yet. The classifier judges
the command it is given, and the project probe's text names no path outside the project. Confirm this case in the live
check above rather than pre-emptively rewriting the second probe.

## Evidence Summary

### E1: All 40 skills carry the same probe block, byte for byte

- **Source:** `grep -rl` over every `*/skills/*/SKILL.md`; block hashes compared with `md5`
- **Finding:**

  ```
  40 files contain the personal probe string
  40 files contain the project probe string
  40 files hash identically over the 6-line block: 5c449d5af12eecfb3143d1f7aa05786f
  ```

  Spread across han-coding (9), han-atlassian (6), han-planning (5), han-github (3), han-research (3),
  han-documentation (3), han-plugin-builder (3), han-communication (3), han-reporting (2), han-core (1), han-linear (1),
  han-feedback (1).

- **Relevance:** The failure is not specific to `code-overview`. Every skill in the suite carries the same exposure, and
  one substitution fixes all of them.

### E2: The probes sit in the SKILL.md body, and the failing one is sixth of seven

- **Source:** `han-coding/skills/code-overview/SKILL.md:19-27`
- **Finding:**

  ```
  ## Project Context

  - git installed: !`which git 2>/dev/null || echo "not installed"`
  - gh installed: !`which gh 2>/dev/null || echo "not installed"`
  - CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
  - project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
  - personal config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`
  - personal .han/config.md: !`cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.han/config.md" 2>/dev/null || echo ""`
  - project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`
  ```

- **Relevance:** Five probes precede the failing one, including an `echo` carrying the identical `${VAR:-default}`
  expansion. The refusal named only the sixth, which narrows what the classifier objected to and rules the expansion
  itself out.

### E3: No skill declares a `cat` grant

- **Source:** `grep -rn 'Bash(cat' --include='SKILL.md' .` returns zero matches across 56 `allowed-tools` lines
- **Finding:** `han-coding/skills/code-overview/SKILL.md:16` reads
  `allowed-tools: Read, Glob, Grep, Agent, Write, Bash(git *), Bash(gh *), Bash(find *)`, with no `cat` entry. Every
  other file follows the same pattern.
- **Relevance:** The probe depends entirely on the loader's built-in allowlist. Nothing in any skill pre-authorizes it.

### E4: The guidance models approval as a command-name allowlist, and its documented error text differs from the observed one

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md:44-54`,
  `:216`
- **Finding:**

  ```
  Context injection runs at skill load, and it never prompts. If a command is not auto-approvable, the loader
  hard-rejects it and stops loading the skill. ... There is no prompt to fall back on.

  1. A built-in read-only command in an allowed form. The loader ships a fixed allowlist that already covers most
     inspection tools, including `cat`, `ls`, `head`, ... Commands on this list need no `allowed-tools` entry.
  ```

  The documented refusal message is `This command requires approval`. The observed one is
  `Permission for this action was denied by the Claude Code auto mode classifier. Reason: Blocked by classifier.` The
  strings "auto mode classifier" and "Blocked by classifier" appear nowhere in this repo.

- **Relevance:** Two findings in one. The no-prompt, hard-reject behavior is why a refusal is fatal rather than
  degrading. The mismatch between the two error strings shows the allowlist model does not describe whatever declined
  this command.

### E5: All 12 copies of the config rule are identical, and none contemplates a refused probe

- **Source:** `sha1` over all 12 `references/config-rule.md` files; `han-core/references/config-rule.md:106-125`
- **Finding:** All 12 report `a6d47a284c169b32066a6db6a2f3b5bce0a8a052`. The degradation section names malformed
  frontmatter, an unrecognized setting, a blank value, an inapplicable setting, a prose-only file, and "a personal
  configuration directory the run cannot reach". None covers the probe command being declined before it runs.
- **Relevance:** Sets the edit surface for the contract change at 12 files, and shows the gap the new bullet fills.

### E6: The original design verified that the probe loads, never that it would be permitted

- **Source:** `docs/plans/user-level-han-config/artifacts/probe-check-result.md:1-66`;
  `docs/plans/user-level-han-config/feature-implementation-plan.md:236-243`, `:249-257`
- **Finding:** The check varied whether `CLAUDE_CONFIG_DIR` was set and whether the file existed, recording exit codes
  and injected values only. It ran with `CLAUDE_CONFIG_DIR=/Users/riverbailey/.claude-testdouble`, so the
  default-to-`$HOME/.claude` branch was never exercised. The risk register R1-R6 has no runtime-permission entry.
  Assumption A1 is marked `Open`, with the note:

  ```
  Unverified: could not inspect the Claude Code skill loader's command classifier, because it is closed-source and not
  present in this repository.
  ```

- **Relevance:** Explains how the probe shipped, and is the reason this fix gates its fan-out on a live check under the
  conditions that failed.

### E7: The same command succeeded through the Bash tool in this session

- **Source:** live run in this session, `CLAUDE_CONFIG_DIR=/Users/riverbailey/.claude-testdouble`
- **Finding:** `cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.han/config.md" 2>/dev/null || echo ""` exited 0 and was not
  refused.
- **Relevance:** Weaker than it first appears. Validation showed this compares two enforcement surfaces rather than two
  runs of one, so it cannot separate non-determinism from a confounding variable (V3). It is kept because it does show
  the command text is not refused everywhere.

### E8: The Read tool served the same file with no prompt

- **Source:** live run in this session, Read on `/Users/riverbailey/.claude/.han/config.md`
- **Finding:** Returned the file, including `output-directory: ".scratch/"`.
- **Relevance:** The direct support for the fix, and a single-session data point, which is why the fan-out is gated on a
  cold-session repeat (V5).

### E9: Read is reachable in all 40 skills without an `allowed-tools` change

- **Source:** `allowed-tools` line extracted from each of the 40 files
- **Finding:** Every skill declaring `allowed-tools` lists `Read`. Eight leave the key empty: han-atlassian's
  `markdown-to-confluence`, `plan-a-feature-to-confluence`, `project-documentation-to-confluence`, and
  `work-items-to-jira`; han-coding's `refactor` and `tdd`; han-documentation's `runbook`; han-linear's
  `work-items-to-linear`.
- **Relevance:** The fix needs no frontmatter changes. Per the guidance, `allowed-tools` is an auto-approve list rather
  than a hard allowlist, so the eight empty ones reach Read too (V7).

### E10: Nothing tests either probe

- **Source:** `find . -name "*.bats" -not -path "*/node_modules/*"`
- **Finding:** Five Bats files exist. None references `config.md`, `probe`, or `CLAUDE_CONFIG_DIR`.
- **Relevance:** No automated check would have caught this, and none will catch a regression. The live check in the fix
  is the only gate available.

## Validation Results

### Counter-Evidence Investigated

#### V1: The "sensitive directory" mechanism is one hypothesis, not a finding

- **Hypothesis:** The classifier objected specifically because the path lands in `$HOME/.claude`.
- **Investigation:** Compared probe features across `han-coding/skills/code-overview/SKILL.md:19-27`; re-read
  `docs/plans/user-level-han-config/artifacts/probe-check-result.md:13-39`.
- **Result:** Partially Refuted. The `echo` at line 25 carries the same expansion and was reached, which rules that
  feature out. But the design's only live check ran against a stand-in config directory, so no evidence anywhere
  exercises a read of the real `$HOME/.claude`.
- **Impact:** The root cause was rewritten around the structural fact that a load-time probe cannot survive a refusal.
  The directory is now framed as what makes this probe the one most likely to draw a refusal.

#### V2: The guidance's documented error text does not match the observed one

- **Hypothesis:** `context-injection-commands.md` describes the mechanism that blocked the probe.
- **Investigation:** Compared lines 44-54 and 216 of that file against the symptom text.
- **Result:** Confirmed as a genuine gap. The doc's message is `This command requires approval`; the observed one names
  an auto-mode classifier. Either there are two layers, or the doc's allowlist description is stale for this version of
  Claude Code.
- **Impact:** The guidance edit is worded around the consequence rather than a named mechanism, so it stays true under
  either explanation.

#### V3: E7 is not a controlled comparison

- **Hypothesis:** The command succeeding here proves the refusal is non-deterministic.
- **Investigation:** Read `~/.claude/settings.json` and `~/.claude-testdouble/settings.json`; both set
  `"defaultMode": "auto"`. Compared enforcement paths: a Bash tool call is checked per call, a probe is checked at skill
  load with no prompt available.
- **Result:** Refuted as stated. Two surfaces, two working directories, and possibly two values of `CLAUDE_CONFIG_DIR`
  all differ, so nothing is isolated.
- **Impact:** E7's weight was reduced and the "coin flip" framing dropped. The refusal may well be deterministic for the
  conditions that produced it.

#### V4: The project probe is exposed in one designed-for case

- **Hypothesis:** Leaving `cat .han/config.md` as a probe leaves the same failure reachable.
- **Investigation:** Read `han-core/references/config-rule.md:29-31`, which handles a skill running inside the Claude
  Code configuration directory.
- **Result:** Confirmed as a real edge. In that case the project probe reads a file in the same directory.
- **Impact:** Documented under "What is deliberately not changing" and folded into the live check, rather than driving a
  second rewrite on a hypothesis the check will settle.

#### V5: "Read is safe" rested on one session

- **Hypothesis:** E8 generalizes.
- **Investigation:** Confirmed E8 ran on this machine, in auto mode, in this repo, with no cold-session repeat and no
  test under `CLAUDE_CONFIG_DIR` unset.
- **Result:** Partially Refuted. Read is the strongest available option and its safety under the failing conditions is
  unproven.
- **Impact:** Added the verification gate, which patches one skill and checks it from a cold session in another project
  before the other 39 change.

#### V6: The first fix wording broke on inline skills and blurred the degradation contract

- **Hypothesis:** The replacement paragraph drops into all 40 files unchanged.
- **Investigation:** Read `han-communication/skills/readability-guidance/SKILL.md:1-30`, which declares only `Read` and
  has no numbered steps. Compared the draft wording against `han-core/references/config-rule.md:117-118` and `:124-125`.
- **Result:** Confirmed, twice. "Before your first step" has nothing to attach to in a skill with no steps. Also, "a
  read that fails means no personal configuration" collapsed the rule's own split between an absent file, which is
  silent, and a malformed one, which earns a note.
- **Impact:** Both corrected in the replacement block above.

#### V7: "Empty `allowed-tools` means unrestricted" overstated it

- **Hypothesis:** The eight skills with an empty key need no further thought.
- **Investigation:** Read
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md:30`:
  "`allowed-tools` is an auto-approve list, not an allowlist. Tools not listed can still be called."
- **Result:** Partially Refuted. Read stays reachable, so the conclusion holds, but empty means every tool goes through
  the approval path rather than none being restricted.
- **Impact:** E9 and the fix now say "reachable" rather than "unrestricted", and those eight skills are named so the
  live check can cover one.

#### V8: The design's only empirical check used a stand-in directory

- **Hypothesis:** Discount `probe-check-result.md` and see whether the analysis survives.
- **Investigation:** Read that artifact at lines 13-14. It ran with `CLAUDE_CONFIG_DIR` pointed at a stand-in so a decoy
  `~/.claude` would prove variable resolution.
- **Result:** Confirmed. There is no evidence anywhere that the probe was ever safe under the default branch.
- **Impact:** Reinforces the verification gate, and is why step 1 of that gate reproduces the failure before step 2
  tests the fix.

#### V9: A cheaper alternative exists and is not ruled out

- **Hypothesis:** Adding `Bash(cat *)` to `allowed-tools` fixes this at a fraction of the cost.
- **Investigation:** Read `context-injection-commands.md:49-55`, which grants approval either through the built-in
  allowlist or an explicit `Bash()` rule. The error message itself suggests a Bash permission rule.
- **Result:** Not refuted. It might work.
- **Impact:** Recorded as the rejected alternative below, with the reasoning, and named as the fallback if the live
  check shows the Read call draws its own refusal.

### Alternatives evaluated

| Alternative                       | Why not                                                                                                                                                                                                                                                              |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Declare `Bash(cat *)` (V9)        | Untested, and it grants 40 skills the ability to read any file to buy back one line. It also leaves the skill's load dependent on a permission decision, which the guidance already says a grant cannot always rescue (`context-injection-commands.md:67-69`).            |
| Swap `cat` for `head -c` or `wc`  | The error text suggests trying another tool, but the target path is unchanged and so is the load-time fatality. It trades a known refusal for an unknown one.                                                                                                          |
| Move the read into a `scripts/` helper | A script invocation is still a shell command reading the same path, so it faces the same decision with the same no-prompt consequence.                                                                                                                            |
| Drop personal-config support      | Removes a shipped feature to dodge a fixable defect.                                                                                                                                                                                                                   |

### Adjustments Made

- The root cause moved from a claim about the classifier's reasoning to the structural fact that a load-time probe
  cannot survive a refusal, triggered by V1, V2, and V3.
- A verification gate was added before the 40-file fan-out, triggered by V5 and V8.
- The replacement paragraph gained step-free wording and kept the absent-versus-malformed split, triggered by V6.
- The project probe's one exposed case was documented and folded into the live check, triggered by V4.
- E9 and the fix stopped calling an empty `allowed-tools` unrestricted, triggered by V7.
- `Bash(cat *)` was recorded as an evaluated alternative and named as the fallback, triggered by V9.

### Confidence Assessment

- **Confidence:** Medium-High on the fix, Low on the mechanism.
- **Remaining Risks:** Nobody can inspect the classifier, so which property of the command it declined stays unknown
  (V1, V2). Whether the Read tool is exempt under the failing conditions is supported by one session and not yet proven
  cold (V5, V8), which the verification gate exists to settle. The project probe's same-directory case is reasoned
  about rather than tested (V4). No automated test guards any of this, before or after (E10).

## Coding Standards Reference

| Standard                                                              | Source                                                                              | Applies To                                              |
| --------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------- |
| Context probes stay simple, read-only, and auto-approvable            | `han-plugin-builder/.../skill-building-guidance/context-injection-commands.md:42-120` | Every probe edit in the 40 SKILL.md files                |
| `config-rule.md` is vendored byte-identically; edit the canonical copy | `CLAUDE.md`, "Configuration"; `han-core/references/config-rule.md:8-9`               | All 12 copies of the config rule                         |
| One canonical source per concept                                      | `CLAUDE.md`, "Conventions"                                                           | The guidance, troubleshooting, and config-rule edits     |
| Conventional Commits                                                  | `/Users/riverbailey/.claude/references/the-book/git/commits.md`                      | The commits carrying this fix                            |
| Voice profile: em-dash limits, direct second person, no hype          | `han-communication/references/writing-voice.md`                                      | Every prose edit, including this report                  |
