# Investigation: personal-config probe rejected with "Contains expansion" (issue #178)

Every Han skill resolves the personal config directory through a load-time shell probe that reads two environment
variables, and Claude Code 2.1.228 now rejects any probe containing that kind of variable reference. The rejection
aborts the skill before it runs. The fix deletes the probe from all 42 skills and resolves the directory during the run
instead. Read the Summary, then approve the Planned Fix or push back.

## Summary

- **Root Cause:** All 42 Han skills carry the probe `` !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"` `` in their
  `## Project Context` block, and Claude Code 2.1.228 hard-rejects any load-time probe whose text contains shell
  variable expansion, so the skill aborts before its body loads (E1, E2, E9).
- **Fix:** Delete the probe line from all 42 skills and move the directory resolution into the first-action step that
  already reads the file, so the resolution happens during the run where a failure degrades silently instead of at load
  where it cannot (E10, E16).
- **Why Correct:** A skill with no probe has nothing for the loader to reject, and the repo's own probe-authoring rule
  already says a lookup reaching outside the project belongs in a run step rather than a probe (E16). The earlier fix
  moved the file read out for that exact reason and left the directory resolution behind (E4).
- **Validation Outcome:** Pending. Adversarial validation has not run yet.
- **Remaining Risks:** Pending validation. The known open risk is that a person who sets `CLAUDE_CONFIG_DIR` and runs a
  skill with no Bash grant may no longer have their personal config found (E20).

## Problem Statement

Running any Han skill on Claude Code 2.1.228 can fail immediately at skill load with this error:

```
Shell command permission check failed for pattern "!`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`": Contains expansion
```

The reporter confirmed it on `han-planning:plan-implementation`, `han-communication:readability-guidance`,
`han-communication:edit-for-readability`, and `han-feedback:han-feedback`. Because `han-feedback` is itself affected,
they could not use Han's own feedback skill to report the problem and filed the issue through `gh` directly.

The expected behavior is that a personal config problem never fails a run. Han's configuration contract states this
plainly: "A bad config can never fail a skill run; the worst it can do is be ignored" (E10). A load-time probe cannot
honor that promise, because it runs before the skill body exists and has no path to degrade.

The blast radius is every skill in the suite, not a personal-config edge case. All 42 skills carry the identical probe
line (E1), and the abort happens whether or not the person has ever written a `.han/config.md` file. One member has
already worked around it by patching the installed plugin cache by hand, which plugin updates will overwrite.

The failure is not universal across machines running the same reported version. On the machine where this
investigation ran, Claude Code reports version 2.1.228 and the probe still resolves correctly (E18). Section "Why the
same version behaves differently" covers what that means for the fix.

## Root Cause Analysis

### Root Cause

Claude Code 2.1.228 rejects any load-time context-injection probe whose text contains shell variable expansion, and all
42 Han skills resolve the personal config directory through exactly such a probe.

### Detailed Analysis

The failing line is one bullet in a four-bullet block that every affected skill carries. Only the third bullet contains
variable expansion; the other three are literal commands with literal arguments (E2):

```
## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`
```

That third bullet reads two environment variables. `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` uses the shell's default-value
operator: it yields `CLAUDE_CONFIG_DIR` when that variable is set and non-empty, and builds `$HOME/.claude` otherwise.
Both halves are variable expansion, which is what the new check refuses.

A probe cannot recover from a refusal. Claude Code runs probes at skill load, before the body is read, and treats a
failed permission check as a failure of the whole invocation. The official documentation states that injected commands
never prompt, and that a check returning anything other than allow aborts the invocation (E9). This is why the symptom
is a hard abort rather than a skill that runs with one value missing.

Han reached this line by fixing a neighboring bug and stopping one step short. Commit `e483783` removed a sibling probe
that used the same expansion to `cat` the personal config file, after a permission classifier refused it. That commit
deliberately kept the surviving `echo` probe, and its own message explains the reasoning: keep "the echo directory
probe, which touches no file" (E4). Commit `e79299f` then copied the surviving line into every skill in the suite,
which is why it is universal today. The prior investigation behind that fix recorded the same judgment, and its live
check confirmed the `echo` form loading successfully at the time (E5, E19).

The reasoning was sound against the classifier that existed then and wrong against the one that exists now. The old
refusal keyed on what a probe opened, so an `echo` that opened no file passed. The new refusal keys on the probe's
text, so an `echo` carrying expansion fails regardless of what it touches. The two errors are different strings from
different checks: the old one named the auto mode classifier and said "Blocked by classifier," and the new one says
"Contains expansion" (E5).

Han's own authoring guidance still teaches the failing form as the recommended pattern, in two places, under a heading
that presents it as the fix for the earlier failure (E14). Any fix that leaves those examples in place will see the
broken probe reintroduced into the next skill someone writes.

### Why the same version behaves differently

The probe still works on the machine where this investigation ran, which reports the same Claude Code version the issue
names (E18). No settings file on this machine carries an allow rule that would explain it: neither the repository's
`.claude/settings.local.json`, which holds only an output-style setting, nor either personal `settings.json`, whose
allow lists name three unrelated entries (E21).

This investigation could not resolve the difference, because the check lives in Claude Code rather than in this
repository. Two explanations fit the evidence and neither was ruled out: builds differing behind one version string, or
a check that varies per account or session. What matters for the fix is the direction of the risk. A machine where the
probe currently works can start rejecting it at any time, so a fix that depends on predicting which probe text passes
is a fix with an expiry date.

## Planned Fix

### Approach

Delete the expansion-bearing probe from all 42 skills and resolve the configuration directory inside the run step that
already reads the file, so no load-time probe carries the personal-config lookup at all.

### Why this approach and not the alternatives

Three candidate fixes were weighed. The chosen one is the only one that cannot be broken again by a further tightening
of the same check.

**Delete the probe, resolve during the run (chosen).** A skill with no probe gives the loader nothing to reject. The
resolution moves into the first-action step, where a failure is recoverable: the step reads a file, gets nothing, and
continues silently, which is already the documented behavior for an absent personal config (E10). This also finishes a
move the repository already committed to. Han's own probe-authoring rule says a lookup reaching outside the project
belongs in a Read-tool call during the run, and gives this reason: "A probe stakes the whole skill on a permission
decision it cannot recover from" (E16). The earlier fix applied that rule to the file read and left the directory
resolution behind.

**Swap `echo` for `printenv` (rejected).** A probe of `` !`printenv CLAUDE_CONFIG_DIR || echo "~/.claude"` `` contains
no expansion and returns the right value in every state I tested (E20). It fails on a different axis. `printenv` is
absent from the documented list of commands that run without a permission prompt, which names `ls`, `cat`, `echo`,
`pwd`, `head`, `tail`, `grep`, `find`, `wc`, `which`, `diff`, `stat`, `du`, `cd`, and the read-only `git` forms (E7).
Whether an `allowed-tools` grant rescues a probe the expansion check would otherwise touch is undocumented (E9). The
repository already rejected a fix on this exact ground once: the `fix-config-probe-exit-code` plan discarded a `|| true`
guard because `true` was not on the allowlist and the form had never been run against the loader. Proposing an unlisted
command now would repeat that reasoning error. This option also keeps a load-time probe, so the next tightening of the
check can break it again.

**Use a built-in substitution (rejected, not available).** Claude Code substitutes a fixed set of variables in skill
text without any shell involvement: `$ARGUMENTS` and its indexed forms, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`,
`${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, and `${CLAUDE_PLUGIN_DATA}`. None of them
yields the configuration directory or the home directory (E8). The mechanism that would have made this clean does not
exist.

### What the fix gives up

A person who sets `CLAUDE_CONFIG_DIR` and runs a skill that has no Bash grant may no longer have their personal config
found. The run step can name both candidate locations, but a skill with no shell available cannot read an environment
variable to choose between them, and whether the Read tool accepts a `~`-prefixed path is undocumented (E9).

This is a real narrowing of a published promise. `docs/configuration.md` tells operators the personal file lives in
"`~/.claude` unless you have set `CLAUDE_CONFIG_DIR`, in which case it is wherever that points" (E15). The fix must
update that text rather than leave it overstating what the suite does.

The loss degrades the way the contract already specifies: an unreachable personal configuration directory is treated as
no personal configuration, with no note (E10). Nobody's run breaks. The narrowing is a feature reaching fewer people,
traded for a suite that loads at all.

### Changes

#### Spot-verify one skill against the live loader before the sweep

- **Change:** Apply the new Project Context block and first-action paragraph to a single skill, then invoke that skill
  and confirm it loads with no error and finds a personal config that exists.
- **Evidence:** (E5), (E19). Both prior fixes to this probe were reasoned rather than run, and both shipped a form that
  a later check rejected. The `fix-config-probe-exit-code` plan named this gate for the same reason.
- **Standards:** The probe-authoring guidance's warning that the allowlist "can shift between Claude Code versions."
- **Details:** Use `han-communication:readability-guidance`. It has no Bash grant in its `allowed-tools`, which makes it
  the strictest permission case and the one most likely to expose a resolution the run cannot perform.

#### All 42 `*/skills/*/SKILL.md` files

- **Change:** Delete the `- personal config directory:` probe bullet. Rewrite the first-action paragraph so it names
  the configuration directory itself instead of pointing at a probe value.
- **Evidence:** (E1), (E2), (E9), (E12), (E16).
- **Standards:** Probe-authoring guidance, "Keep every probe reading inside the project working directory."
- **Details:** All 42 blocks are byte-identical apart from the relative depth of the `config-rule.md` link (E12), so
  this is one substitution applied 42 times, not 42 separate edits. The block becomes:

```
## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside your Claude Code configuration directory. That
directory is the path in the `CLAUDE_CONFIG_DIR` environment variable when it is set, and `~/.claude` when it is not. A
read that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.
```

The complete file list is in E1. The list of 42 is confirmed by two independent passes.

#### `han-communication/skills/readability-guidance/SKILL.md` and `han-communication/skills/edit-for-readability/SKILL.md`

- **Change:** Reword the second reference to the probe value, deeper in each skill body, where a relative
  `writing-voice` path resolves against the configuration directory.
- **Evidence:** (E13).
- **Standards:** Writing voice; the `config-rule.md` relative-path contract.
- **Details:** Both currently say a relative value resolves against "the `personal config directory` the probe reported
  for the personal file." With no probe, that phrase has no referent. Replace it with "the Claude Code configuration
  directory you resolved for the personal file." No other skill references the value a second time.

#### `han-core/references/config-rule.md` and its 11 vendored copies

- **Change:** Rewrite the bullet that describes the value as a probe output so it describes a value the run resolves.
  Add the empty case to the degradation list.
- **Evidence:** (E10), (E11).
- **Standards:** The one-canonical-source-per-concept convention in `CLAUDE.md`; the vendoring convention requiring
  byte-identical copies.
- **Details:** All 12 copies currently share md5 `0c591431ab7ccb0e92cce3fc5335d081` (E11). Edit the canonical
  `han-core` copy, then re-sync the other 11 and confirm the checksums match again. The bullet keeps its meaning: the
  configuration directory is named by `CLAUDE_CONFIG_DIR` when set and `~/.claude` when not, and it remains the folder a
  relative path in the personal file resolves against. Only its source changes, from a probe to the run. The
  degradation list already covers a directory the run cannot reach, so add only the case where the run cannot determine
  the directory at all, resolving it the same silent way.

#### `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md`

- **Change:** Replace the recommended example that carries the failing probe, and add shell variable expansion to the
  list of constructs the loader refuses.
- **Evidence:** (E14), (E9).
- **Standards:** The guidance file's own path-scoped rule header, which applies it to every `SKILL.md` in the repo.
- **Details:** Line 152 currently offers `` !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"` `` under "Prefer (probe
  resolves the location, a step reads the file)". Both the heading and the example need to go, because resolving a
  location in a probe is no longer safe when the location comes from an environment variable. The refused-constructs
  list names four items (command substitution, process substitution, subshells and background, dangerous sub-forms).
  Add a fifth for parameter expansion, with the verbatim `Contains expansion` error text.

#### `han-plugin-builder/skills/guidance/references/skill-building-guidance/troubleshooting.md`

- **Change:** Update the worked "after" example, and add a section for the new refusal.
- **Evidence:** (E14).
- **Standards:** Same guidance conventions.
- **Details:** Line 365 carries the failing form as the correct outcome of the existing section on a probe refused for
  reading outside the project. Replace it with the run-step form. Add a section covering the "Contains expansion"
  error, its cause, and the resolution, following the shape of the sections already there.

#### `docs/configuration.md`

- **Change:** Keep the description of where the personal file lives, and state plainly when the `CLAUDE_CONFIG_DIR`
  override is honored.
- **Evidence:** (E15).
- **Standards:** Writing voice; the YAGNI-applies-to-docs convention.
- **Details:** Lines 34 to 36 are the only operator-facing text naming the variable. The file is still at `.han/config.md`
  inside the configuration directory, so the location text stands. Add that a skill without a shell available to it
  resolves the default location only. The existing degradation text at lines 183 and 184 already covers the outcome and
  needs no change.

## Evidence Summary

### E1: All 42 skill files carry the identical failing probe line

- **Source:** `grep -rl` across `*/skills/*/SKILL.md`; representative
  `han-planning/skills/plan-implementation/SKILL.md:18`, `han-communication/skills/readability-guidance/SKILL.md:17`,
  `han-communication/skills/edit-for-readability/SKILL.md:19`, `han-feedback/skills/han-feedback/SKILL.md:15`
- **Finding:**
  ```
  - personal config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`
  ```
  The 42 files: `han-atlassian/skills/{code-overview-to-confluence,investigate-to-confluence,markdown-to-confluence,plan-a-feature-to-confluence,project-documentation-to-confluence,work-items-to-jira}`;
  `han-coding/skills/{architectural-analysis,automated-test-planning,code-overview,code-review,code-walkthrough,coding-standard,design-an-api,investigate,manual-test-planning,refactor,tdd}`;
  `han-communication/skills/{edit-for-readability,explanation-guidance,readability-guidance}`;
  `han-core/skills/project-discovery`;
  `han-documentation/skills/{architectural-decision-record,project-documentation,runbook}`;
  `han-feedback/skills/han-feedback`;
  `han-github/skills/{post-code-review-to-pr,update-pr-description,work-items-to-issues}`;
  `han-linear/skills/work-items-to-linear`;
  `han-planning/skills/{iterative-plan-review,plan-a-feature,plan-a-phased-build,plan-implementation,plan-work-items}`;
  `han-plugin-builder/skills/{agent-builder,guidance,skill-builder}`;
  `han-reporting/skills/{html-summary,stakeholder-summary}`;
  `han-research/skills/{gap-analysis,issue-triage,research}`.
- **Relevance:** This is the exact line named in the issue's error text, and all four skills the reporter reproduced on
  are in this set.

### E2: It is the only expansion-bearing probe in the suite

- **Source:** `grep -rn '!`[^`]*\$[^`]*`' --include='SKILL.md' .` across all 314 probe matches in the repo
- **Finding:** Zero results outside the personal-config line. Every sibling probe uses literal arguments only:
  ```
  - CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
  - project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
  - project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`
  ```
- **Relevance:** The fix touches one bullet. The other three bullets in the same block are not implicated and stay as
  they are.

### E3: The shipped form is single-level; the nested form never reached main

- **Source:** `grep -rn 'AGENT_CONFIG_DIR'` over the working tree; `git branch -a --contains 0405583`
- **Finding:** `AGENT_CONFIG_DIR` appears nowhere in the checked-out repository. Commit `0405583`, which the issue
  cites as extending the probe, is contained only by `remotes/origin/kadams54/pi`. Its diff:
  ```
  -- personal config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`
  ++ personal config directory: !`echo "${AGENT_CONFIG_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"`
  ```
- **Relevance:** The issue's evidence chain is right about the commit and wrong about what shipped. The failing form is
  the single-level one. The unmerged branch would add a second expansion layer, so it needs the same fix before merge.

### E4: The earlier fix kept this probe on purpose

- **Source:** `git show e483783`, commit message and diff
- **Finding:** The message reads: "Move the personal read into a Read-tool step during the run, so a permission
  decision on it can no longer abort a skill. Keep the echo directory probe, which touches no file, and the project
  probe, which is relative to the working directory." The diff removed only the `cat` probe. Commit `e79299f` then
  copied the surviving line across the suite.
- **Relevance:** The current bug is the unfixed half of a fix already made once, which is why the fix direction is to
  finish that move rather than invent a new mechanism.

### E5: The prior investigation blessed the surviving probe and shipped

- **Source:** `docs/plans/fix-personal-config-probe-classifier-block/investigation.md:6-16, 84-129`
- **Finding:** Its recorded error was a different check:
  ```
  Error: Shell command permission check failed for pattern
  "!`cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.han/config.md" 2>/dev/null || echo ""`":
  Permission for this action was denied by the Claude Code auto mode classifier.
  Reason: Blocked by classifier.
  ```
  Its fix dropped the `cat` probe, kept the `echo` probe, and moved the read into a step. That fix is `e483783` plus
  the `e79299f` fan-out, and it matches current file content.
- **Relevance:** Establishes that "Contains expansion" is a new, second check with different text, not a recurrence of
  the one already fixed.

### E6: A probe that exits non-zero aborts the skill load

- **Source:** `docs/plans/fix-config-probe-exit-code/investigation.md:1-40`; Claude Code skills documentation,
  "When an injected command fails"
- **Finding:** The documentation states that a failed command "aborts the entire skill invocation, not just its own
  placeholder," and that "With the default `bash` shell, any non-zero exit code counts as a failure." The prior plan
  reproduced this against `cat .han/config.md 2>/dev/null`, which exits 1 on a missing file.
- **Relevance:** Rules out any unguarded replacement probe and explains why the surviving probes all carry a
  `|| echo <sentinel>` guard.

### E7: `printenv` is absent from the documented no-prompt command list

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md:50-56`;
  Claude Code permissions documentation
- **Finding:** The repository's guidance names the allowlist as covering "`cat`, `ls`, `head`, `tail`, `wc`, `grep`,
  `find` (without the dangerous predicates below), `which`, `echo`, `date`, and the read-only `git` and `gh`
  subcommands." The official list names `ls`, `cat`, `echo`, `pwd`, `head`, `tail`, `grep`, `find`, `wc`, `which`,
  `diff`, `stat`, `du`, `cd`, and read-only `git` forms. Neither includes `printenv` or `env`.
- **Relevance:** The single most attractive drop-in replacement is not on the list, which is what pushes the fix toward
  removing the probe rather than rewriting it.

### E8: No built-in substitution yields the configuration directory

- **Source:** Claude Code skills documentation, "Available string substitutions"
- **Finding:** The complete set is `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, named arguments, `${CLAUDE_SESSION_ID}`,
  `${CLAUDE_EFFORT}`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, and
  `${CLAUDE_PLUGIN_DATA}`. There is no `${CLAUDE_CONFIG_DIR}` substitution and nothing yielding the home directory.
- **Relevance:** Closes the option of replacing the shell expansion with a harness substitution, which would otherwise
  have been the cleanest fix.

### E9: The rejection is documented as unrecoverable, and the override is not documented

- **Source:** Claude Code skills documentation, "When an injected command fails"; changelog entry for 2.1.228
- **Finding:** "Injected commands never prompt for permission. When a command's permission check returns anything other
  than allow, Claude Code aborts the invocation." The 2.1.228 changelog records related hardening: "Hardened skills
  synced from claude.ai: they no longer shadow local commands or MCP prompts, their descriptions are sanitized and
  labeled, and on your machine their bodies don't run `!` commands or expand `@` files." Whether an `allowed-tools`
  grant can override the expansion rejection is not stated anywhere in the documentation.
- **Relevance:** Confirms the symptom is a hard abort by design, and confirms that any fix relying on an
  `allowed-tools` grant would rest on undocumented behavior.
- Unverified: the changelog text covers claude.ai-synced skills, a different provenance tier from Han's marketplace
  install, so it is corroborating context for the direction of the hardening rather than proof of the rule that fires
  here.

### E10: The configuration contract the fix must preserve

- **Source:** `han-core/references/config-rule.md:15-17, 71-78, 113, 129-133`
- **Finding:**
  ```
  `personal config directory` (probe): the Claude Code configuration directory, resolved for this run. Named by the
  `CLAUDE_CONFIG_DIR` environment variable when that variable is set, and `~/.claude` when it is not. This value is
  not a setting. It is the folder a relative path in the personal file resolves against.
  ```
  ```
  A bad config can never fail a skill run; the worst it can do is be ignored.
  ```
  ```
  A personal configuration directory the run cannot reach: treat it as no personal configuration, with no note. A run
  cannot tell that apart from a person who never wrote the file, and the second group is far larger.
  ```
  The same file states that the run expands a leading `~` itself "because most skills have no shell available to them."
- **Relevance:** Two things the fix must keep: the value's meaning and its two jobs, and the silent-degradation
  promise. The file also already concedes that most skills have no shell, which is the same constraint that limits what
  the replacement can resolve.

### E11: All 12 config-rule copies are byte-identical

- **Source:** `md5` over `{plugin}/references/config-rule.md` for all 12 plugins
- **Finding:** Every copy reports `0c591431ab7ccb0e92cce3fc5335d081`.
- **Relevance:** No drift to reconcile. The edit is made once in `han-core` and re-synced, and the checksums are the
  verification that the sync is complete.

### E12: The 42 probe blocks are byte-identical

- **Source:** Hash comparison of the probe block across every matching `SKILL.md`, normalized only for the `../../`
  relative-path depth of the `config-rule.md` link
- **Finding:** One hash across all 42 files.
- **Relevance:** The sweep is a single mechanical substitution, which makes a scripted edit plus a completeness grep a
  sufficient method.

### E13: Two skills reference the value a second time

- **Source:** `han-communication/skills/readability-guidance/SKILL.md:46-49`;
  `han-communication/skills/edit-for-readability/SKILL.md:76-79`
- **Finding:** Both carry this sentence, which resolves a relative `writing-voice` path:
  ```
  A relative value resolves against the folder holding the file that declared it: the working directory for the
  project file, and the `personal config directory` the probe reported for the personal file.
  ```
- **Relevance:** Deleting the probe leaves this phrase pointing at nothing, so these two files need an edit beyond the
  common block.

### E14: The authoring guidance teaches the failing form

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md:149-153`;
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/troubleshooting.md:362-368`
- **Finding:** The guidance offers the failing line under the heading "Prefer (probe resolves the location, a step
  reads the file)", and the troubleshooting doc offers it under "After (correct — probe resolves the location only)".
  Neither file's refusal list mentions parameter expansion, and `Contains expansion` appears nowhere in the repository.
- **Relevance:** Without updating these two files, the next skill written from the guidance reintroduces the bug.

### E15: The published promise about `CLAUDE_CONFIG_DIR`

- **Source:** `docs/configuration.md:34-36`
- **Finding:**
  ```
  **Personal:** `.han/config.md` inside your Claude Code configuration directory. That is `~/.claude` unless you have
  set `CLAUDE_CONFIG_DIR`, in which case it is wherever that points. If you have moved your configuration directory, a
  file left behind in `~/.claude/.han/` does not apply.
  ```
- **Relevance:** This is the only operator-facing text naming the variable, so it is the one file that must change if
  the fix narrows when the override is honored.

### E16: The repo's own rule says this lookup belongs in a run step

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md:127-135`
- **Finding:**
  ```
  A probe reads files in the directory the skill runs from. When a step needs the content of a file somewhere else,
  gather it during the run with the Read tool instead.

  The reason is the no-prompt, no-fallback behavior from the rule above. A probe stakes the whole skill on a
  permission decision it cannot recover from...
  ```
- **Relevance:** The chosen fix is this rule applied to the half of the lookup that was left behind, so it needs no new
  convention.

### E17: No test covers the probe

- **Source:** All six `*.bats` files outside `node_modules`, grepped for `CLAUDE_CONFIG_DIR`, `personal config
  directory`, and `Project Context`
- **Finding:** Zero matches. `test/sanity.bats` is an arithmetic check only.
- **Relevance:** No test blocks the change and none guards against regression, which is why the spot-verification gate
  carries the whole verification burden.

### E18: The probe still works on this machine, at the same reported version

- **Source:** `command claude --version`; the Project Context block of this skill's own invocation
- **Finding:** The binary reports `2.1.228 (Claude Code)`. This skill's own `personal config directory` resolved to
  `/Users/riverbailey/.claude-testdouble`, set by a personal shell function outside this repository that exports
  `CLAUDE_CONFIG_DIR` before launching the binary.
- **Relevance:** The failure is not reproducible here, so the fix cannot be verified by reproducing the bug. It can
  only be verified by confirming the replacement loads and resolves correctly.
- Unverified: why one machine rejects the probe and another accepts it at the same reported version. The check is not
  part of this repository and its build identity beyond the self-reported string was not inspectable.

### E19: The original validation recorded the probe working and flagged the unset branch

- **Source:** `docs/plans/user-level-han-config/artifacts/probe-check-result.md:1-6, 57-66`
- **Finding:**
  ```
  Shape A loads. The Claude Code skill loader accepts `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` inside a context probe and
  expands it correctly...
  ```
  ```
  The loader was observed expanding the variable when it is set. It was not observed taking the `:-` default branch,
  because that needs a session started with the variable unset.
  ```
  The artifact records no Claude Code version and never uses the phrase "Contains expansion".
- **Relevance:** Confirms the issue's claim that the probe was validated rather than assumed, and shows the validation
  was against a check that has since changed.

### E20: Measured shell behavior of the rejected `printenv` alternative

- **Source:** Direct shell runs in this repository
- **Finding:**
  ```
  printenv CLAUDE_CONFIG_DIR                                  -> /Users/riverbailey/.claude-testdouble, exit 0
  env -u CLAUDE_CONFIG_DIR sh -c 'printenv CLAUDE_CONFIG_DIR' -> (empty), exit 1
  ... 'printenv CLAUDE_CONFIG_DIR || echo "~/.claude"'        -> ~/.claude, exit 0    (unset)
  ... 'printenv CLAUDE_CONFIG_DIR || echo "~/.claude"'        -> /Users/riverbailey/.claude-testdouble, exit 0 (set)
  CLAUDE_CONFIG_DIR="" sh -c 'printenv ... || echo "~/.claude"' -> (empty), exit 0
  ```
- **Relevance:** The guarded form is correct in the two states that matter and diverges in one: with the variable set
  to an empty string, `printenv` succeeds and the fallback never fires, where the current `:-` operator would fall back.
  Recorded because it is the strongest rejected alternative, and because the divergence would have been easy to miss.

### E21: No settings rule explains the working case

- **Source:** `.claude/settings.local.json`; `~/.claude/settings.json:5-9`; `~/.claude-testdouble/settings.json:5-11`
- **Finding:** The repository file holds only `{"outputStyle": "han-communication:Han Readability"}`, and no
  `.claude/settings.json` exists at the repository root. The active personal allow list names three entries, all MCP
  or Skill rules, none touching Bash, `echo`, or the probe. Both personal files set `"defaultMode": "auto"`.
- **Relevance:** Rules out a local allow rule as the reason the probe works here, which leaves the difference
  unexplained and keeps E18's risk direction intact.

### E22: The branch is clean with no work in progress

- **Source:** `git branch --show-current`, `git log --oneline main..HEAD`, `git status`
- **Finding:** The branch is `han-config-expansion-fix`, level with `main` at `beab327`, working tree clean.
- **Relevance:** The fix starts from the released state with nothing to reconcile.

## Coding Standards Reference

| Standard                                                                   | Source                                                                           | Applies To                                             |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Keep every probe reading inside the project working directory               | `han-plugin-builder/.../context-injection-commands.md:127-135`                     | The 42 SKILL.md edits                                   |
| Keep every probe command an auto-approvable read-only form                  | `han-plugin-builder/.../context-injection-commands.md:44-123`                      | Rejecting the `printenv` alternative                    |
| A bad config can never fail a skill run                                     | `han-core/references/config-rule.md:113`                                          | The whole fix direction                                 |
| Vendored reference files stay byte-identical to the canonical copy          | `CLAUDE.md`, "Configuration"                                                     | The 12 `config-rule.md` copies                          |
| One canonical source per concept; other surfaces carry a scent plus a link  | `CLAUDE.md`, "Conventions"                                                       | `docs/configuration.md` and the guidance docs           |
| Writing voice: no em-dashes outside label-gloss and appositive, second person | `han-communication/references/writing-voice.md`                                  | Every prose edit in the fix                             |
| Conventional Commits                                                        | `~/.claude/references/the-book/git/commits.md`                                    | Every commit in the fix                                 |
| Never bump a plugin version unprompted                                      | Operator instruction                                                             | Excludes `plugin.json` and `CHANGELOG.md` from the fix  |
