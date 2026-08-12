# Investigation: personal-config probe aborts every skill (issue #178)

Claude Code's skill loader now refuses almost every environment-variable reference in a load-time probe. All 42 Han
skills read the personal config directory through one. I reproduced the abort locally and tested eleven probe forms
across five permission modes to find which ones survive. Exactly one useful form does.

The fix adopts that form and gives up the `CLAUDE_CONFIG_DIR` override, which is no longer reachable from a probe at
all. Read the Summary, then approve the Planned Fix or push back.

## Summary

- **Root Cause:** All 42 skills carry the probe `` !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"` ``, and the loader
  refuses it, aborting the skill before its body loads. The refusal is narrower than the issue reports: bare `$HOME` is
  permitted, while `${...}` brace syntax, every other variable name, and `printenv` are all refused (E23).
- **Fix:** Replace the probe with `` !`echo "$HOME/.claude"` `` in all 42 skills. I verified this loads in every
  permission mode. The fix also updates the documentation that promises a `CLAUDE_CONFIG_DIR` override the loader can
  no longer deliver (E23, E24).
- **Why Correct:** I ran each candidate form through a fresh Claude Code session and recorded which loaded. The chosen
  form loaded in all of `default`, `plan`, `acceptEdits`, `auto`, and `bypassPermissions`. It injects the same kind of
  absolute path the current probe does, so nothing downstream changes shape (E23, E24).
- **Validation Outcome:** Adversarial validation refuted my first fix. That version deleted the probe and told the run
  to resolve the directory itself. No skill can do that: zero of the 42 have a Bash grant that reads an environment
  variable. The Read tool also expands `~` to the home directory rather than the configured one, so the run would have
  silently applied the wrong profile's config (V8, V9).
- **Remaining Risks:** The `CLAUDE_CONFIG_DIR` override stops working, which changes a published promise and needs an
  operator decision. Anyone who has moved their configuration directory and left a stale file behind will have that
  stale file applied (V9). See the Confidence Assessment.

## Problem Statement

Running a Han skill can abort at load with this error:

```
Shell command permission check failed for pattern "!`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`": Contains expansion
```

The reporter confirmed it on `han-planning:plan-implementation`, `han-communication:readability-guidance`,
`han-communication:edit-for-readability`, and `han-feedback:han-feedback`. Because `han-feedback` is itself affected,
they could not use Han's own feedback skill to report the problem and filed the issue through `gh` directly.

A second member is working around it by rewriting the probe line to a hardcoded path inside the installed plugin cache,
which every plugin update will overwrite (E25).

The expected behavior is that a personal config problem never fails a run. Han's configuration contract says so
directly: "A bad config can never fail a skill run; the worst it can do is be ignored" (E10). A load-time probe cannot
honor that promise, because it runs before the skill body exists and has no way to degrade.

The bug affects every skill in the suite. All 42 carry the identical probe line (E1), and the abort happens whether or
not the person has ever written a `.han/config.md` file.

The abort is silent in non-interactive runs. A `claude -p` session invoking an affected skill exits successfully with
`is_error: false`, an empty result, and zero model turns, printing no error at all (E23).

## Root Cause Analysis

### Root Cause

Claude Code's skill loader permits only a bare `$HOME` reference inside a load-time probe. It refuses every other
environment-variable reference, including the `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` form that all 42 Han skills use to
locate the personal config directory.

### What the loader accepts

I tested eleven probe forms by writing each into a scratch skill and invoking it from a fresh Claude Code session,
recording whether the session reached the model. A skill that loads reports one model turn; a skill that aborts reports
zero turns and an empty result. Every row below is a measured result, not an inference (E23):

| Probe form                                     | Result  |
| ---------------------------------------------- | ------- |
| `` !`echo hello` ``                             | loads   |
| `` !`echo "$HOME"` ``                           | loads   |
| `` !`echo "$HOME/.claude"` ``                   | loads   |
| `` !`echo ~/.claude` ``                         | loads   |
| `` !`echo "${HOME}"` ``                         | aborts  |
| `` !`echo "${HOME:-/tmp}"` ``                   | aborts  |
| `` !`echo "$CLAUDE_CONFIG_DIR"` ``              | aborts  |
| `` !`echo "$FOOBAR_NOT_REAL"` ``                | aborts  |
| `` !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"` `` | aborts  |
| `` !`printenv HOME` ``                          | aborts  |
| `` !`printenv CLAUDE_CONFIG_DIR \|\| echo "~/.claude"` `` | aborts  |

Three rules explain every row. Bare `$HOME` is permitted. Brace syntax is refused even for `$HOME`, so the refusal is
about the form as well as the name. Every variable other than `HOME` is refused, including one that does not exist, so
the loader is not resolving values and reacting to them.

The failing probe breaks two of the three rules at once. It names `CLAUDE_CONFIG_DIR` and it wraps the reference in
braces.

The issue's own diagnosis was close but not exact. "Contains expansion" reads as a blanket ban on expansion, and it is
not: `` !`echo "$HOME/.claude"` `` expands a variable and loads cleanly in every mode I tested.

### Permission mode is not the discriminator

I ran the failing probe in all five permission modes. `default`, `plan`, `acceptEdits`, and `auto` abort identically.
Only `bypassPermissions`, which skips permission checks altogether, lets it through (E23).

That answers the question of whether a mode difference explains why some people see the bug and others do not. Among
the modes anyone would normally work in, it does not. The one mode that permits the probe is the one that permits
everything.

This also resolves why the probe kept resolving correctly during this investigation while the reporter's runs aborted.
The interactive session running this work loads the probe, which matches `bypassPermissions` behavior and no other mode
(E18). Earlier passes treated that as an unexplained version difference. It is a permission-check difference, and the
fix should not depend on it.

### How Han arrived here

Han reached this line by fixing a neighboring bug and stopping one step short. Commit `e483783` removed a sibling probe
that used the same expansion to `cat` the personal config file, after a permission classifier refused it. That commit
deliberately kept the surviving `echo` probe, and its message explains why: keep "the echo directory probe, which
touches no file" (E4). Commit `e79299f` then copied the surviving line into every skill, which is why it is universal
today.

The reasoning was sound against the check that existed then and wrong against the one that exists now. The old refusal
keyed on what a probe opened, so an `echo` that opened no file passed. The new refusal keys on the probe's text, so an
`echo` naming the wrong variable fails no matter what it touches. The two errors are different strings from different
checks (E5).

Han's own authoring guidance still teaches the failing form as the recommended pattern, in two places, under headings
that present it as the fix for the earlier failure (E14). Leaving those in place would put the broken probe into the
next skill someone writes.

## Planned Fix

### Approach

Replace the probe with `` !`echo "$HOME/.claude"` `` in all 42 skills, and correct the documentation that promises a
`CLAUDE_CONFIG_DIR` override the loader can no longer deliver.

### The decision this asks you to make

The `CLAUDE_CONFIG_DIR` override cannot be preserved. Every form that reads that variable aborts, whether through
`echo`, through braces, or through `printenv` (E23). No built-in skill substitution yields the configuration directory
either (E8). This is measured, not assumed.

That leaves a real choice about what the personal config directory means from now on. My recommendation is the first
option, because it is the only one that both loads and needs no new tool grants.

1. **Accept the default location.** The personal config is `~/.claude/.han/config.md`, always. Anyone who has moved
   their configuration directory links the two with one command:
   `ln -s "$CLAUDE_CONFIG_DIR/.han" ~/.claude/.han`. This ships now and needs nothing from anyone who has not moved
   their directory.
2. **Preserve the override with a new tool grant.** Delete the probe and add `Bash(printenv *)` to every skill so a run
   step can read the variable. This keeps the override, but it adds a Bash grant to 42 skills, 13 of which deliberately
   carry none today. It also rests on behavior I could not test, since a probe cannot stand in for a runtime tool call
   (V8, V11).

Option 1 is what the Changes section below implements. Say the word if you want option 2 instead.

### Why this approach and not the alternatives

**`` !`echo "$HOME/.claude"` `` (chosen).** It loads in every permission mode (E23). It injects an absolute path,
exactly what the current probe injects. That means the value's meaning and both of its downstream jobs survive
untouched: the run reads `.han/config.md` inside it, and a relative path in the personal file resolves against it. The
diff is one line in 42 files.

**Delete the probe and resolve during the run (rejected after validation).** This was my first plan, and validation
broke it. No skill can execute it: zero of the 42 declare a Bash grant matching any environment-reading command (V8).

Worse, the fallback is unsafe. The Read tool does expand a leading `~`, but to the home directory, never to the
configured one. I confirmed this on the machine running this investigation, where `~/.claude/.han/config.md` holds a
real 812-byte config while the active configuration directory holds none (V9). A run following that instruction would
silently apply the wrong profile's settings, which is worse than the documented degradation of ignoring the file.

**`printenv` in any position (rejected).** `` !`printenv HOME` `` aborts, so `printenv` is not permitted in a probe at
all, independent of which variable it names (E23). This confirms, by measurement, the allowlist concern that earlier
passes could only reason about.

**A built-in substitution (rejected, not available).** Claude Code substitutes a fixed set of variables in skill text
with no shell involved: `$ARGUMENTS` and its indexed forms, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`,
`${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, and `${CLAUDE_PLUGIN_DATA}`. None yields the
configuration directory or the home directory (E8).

### What the fix gives up

Anyone who sets `CLAUDE_CONFIG_DIR` loses the automatic override, and a stale `~/.claude/.han/config.md` left behind
from before the move will now be applied to every project. That reverses a rule the contract states today: "If you have
moved your configuration directory, a file left behind in `~/.claude/.han/` does not apply" (E15).

The symlink in option 1 restores correct behavior for that group with one command, and it survives plugin updates,
which the current cache-patching workaround does not (E25).

### Changes

#### Spot-verify one skill against the live loader before the sweep

- **Change:** Apply the new probe line to a single skill, then invoke it and confirm it loads and finds a personal
  config that exists.
- **Evidence:** (E5), (E19). Both prior fixes to this probe were reasoned rather than run, and both shipped a form a
  later check rejected.
- **Standards:** The probe-authoring guidance's warning that the allowlist "can shift between Claude Code versions."
- **Details:** Use `han-communication:readability-guidance`, which declares `allowed-tools: Read` and is the strictest
  permission case in the set (V8). Run it in `default` mode, not the mode this session uses, because
  `bypassPermissions` accepts probes every other mode rejects (E23). If the check fails, stop and reopen the choice in
  "The decision this asks you to make" rather than continuing the sweep.

#### All 42 `*/skills/*/SKILL.md` files

- **Change:** Replace the probe line. Nothing else in the block changes.
- **Evidence:** (E1), (E12), (E23).
- **Standards:** Probe-authoring guidance, "Keep every command an auto-approvable read-only form."
- **Details:** All 42 blocks are byte-identical apart from the relative depth of the `config-rule.md` link (E12), so
  this is one substitution applied 42 times. The line becomes:

```
- personal config directory: !`echo "$HOME/.claude"`
```

The surrounding first-action paragraph keeps its current wording, because the label still names a resolved absolute
directory. The complete file list is in E1. Two repo-maintenance skills under `.claude/skills/` carry their own Project
Context blocks and never carried this probe, so they are out of scope (V1).

#### `han-core/references/config-rule.md` and its 11 vendored copies

- **Change:** Rewrite the bullet describing the value so it stops promising a `CLAUDE_CONFIG_DIR` override. Correct the
  factual error about tilde handling. Record the same-file case.
- **Evidence:** (E10), (E11), (V6), (V9), (V10).
- **Standards:** One canonical source per concept; vendored copies stay byte-identical.
- **Details:** All 12 copies share md5 `0c591431ab7ccb0e92cce3fc5335d081` (E11). Edit the canonical `han-core` copy,
  re-sync the other 11, and confirm the checksums match again. Three edits:
  - The bullet at lines 15 to 17 currently says the directory is "Named by the `CLAUDE_CONFIG_DIR` environment variable
    when that variable is set, and `~/.claude` when it is not." It becomes the home-directory location only, with a
    pointer to the symlink for anyone who has moved their directory.
  - Lines 76 to 78 state that "a literal `~` handed to a file-reading tool does not resolve." That is wrong. The Read
    tool resolves it to the home directory, which I confirmed directly (V10). Correct the sentence rather than leave a
    canonical file stating a false fact about tool behavior.
  - Lines 34 to 36 define what happens when both lookups resolve to the same file, which the run detects by comparing
    the resolved directory against the working directory (V6). The probe still supplies an absolute path, so this rule
    keeps working. Confirm it during the sweep rather than assume it.

#### `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md`

- **Change:** Replace the recommended example carrying the failing probe, and record what the loader accepts.
- **Evidence:** (E14), (E23).
- **Standards:** The file's own path-scoped rule header, which applies it to every `SKILL.md` in the repo.
- **Details:** Line 152 offers the failing line under "Prefer (probe resolves the location, a step reads the file)".
  Replace it with the `$HOME` form. The refused-constructs list names four items. Add a fifth covering
  environment-variable references, and state the measured rule: bare `$HOME` is permitted, brace syntax is refused even
  for `$HOME`, and every other variable name is refused. Add `printenv` to the commands the guidance says are not
  permitted, and add the eleven-row results table from this investigation so the next author does not have to rerun it.

#### `han-plugin-builder/skills/guidance/references/skill-building-guidance/troubleshooting.md`

- **Change:** Update the worked "after" example, and add a section for this refusal.
- **Evidence:** (E14), (E23).
- **Standards:** Same guidance conventions.
- **Details:** Line 365 carries the failing form as the correct outcome. Replace it with the `$HOME` form. Add a section
  covering the `Contains expansion` error, following the shape of the sections already there. Note the silent
  non-interactive failure: a `claude -p` run aborts with no error text and an empty result, so a skill that appears to
  do nothing is the symptom to recognize (E23).

#### `docs/configuration.md`

- **Change:** Correct where the personal file lives, and document the symlink for anyone who has moved their
  configuration directory.
- **Evidence:** (E15), (E23).
- **Standards:** Writing voice; YAGNI applies to docs.
- **Details:** Lines 34 to 36 are the only operator-facing text naming the variable, and they currently promise the
  override. Replace with the home-directory location plus the symlink command. The degradation text at lines 183 and
  184 needs no change.

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
- **Relevance:** The line named in the issue's error text, and all four skills the reporter reproduced on are in this
  set.

### E2: It is the only expansion-bearing probe in the suite

- **Source:** `grep -rn '!`[^`]*\$[^`]*`'` across all file types, covering all 314 probe matches
- **Finding:** No live probe outside this line carries a variable reference. The only other match is a documented bad
  example under an "Avoid" heading in the authoring guidance. No `@`-file reference syntax exists anywhere in the
  suite, so the changelog's `@`-expansion hardening adds nothing to the scope.
- **Relevance:** The fix touches one bullet. The three sibling probes in the same block are literal commands and stay
  as they are.

### E3: The shipped form is single-level; the nested form never reached main

- **Source:** `grep -rn 'AGENT_CONFIG_DIR'`; `git branch -a --contains 0405583`
- **Finding:** `AGENT_CONFIG_DIR` appears nowhere in the working tree. Commit `0405583` is contained only by
  `remotes/origin/kadams54/pi`. Its diff changes the probe to
  `` !`echo "${AGENT_CONFIG_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"` ``.
- **Relevance:** The issue is right about the commit and wrong about what shipped. That unmerged branch needs the same
  fix before it merges, since its form breaks all three of the rules in E23.

### E4: The earlier fix kept this probe on purpose

- **Source:** `git show e483783`, message and diff
- **Finding:** "Move the personal read into a Read-tool step during the run, so a permission decision on it can no
  longer abort a skill. Keep the echo directory probe, which touches no file, and the project probe, which is relative
  to the working directory." The diff removed only the `cat` probe. Commit `e79299f` copied the survivor across the
  suite.
- **Relevance:** The current bug is the unfixed half of a fix already made once.

### E5: The prior investigation blessed the surviving probe and shipped

- **Source:** `docs/plans/fix-personal-config-probe-classifier-block/investigation.md:6-16, 84-129`
- **Finding:** Its recorded error named a different check:
  ```
  Error: Shell command permission check failed for pattern
  "!`cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.han/config.md" 2>/dev/null || echo ""`":
  Permission for this action was denied by the Claude Code auto mode classifier.
  Reason: Blocked by classifier.
  ```
- **Relevance:** Establishes that "Contains expansion" is a second, later check with different text.

### E6: A probe that exits non-zero aborts the skill load

- **Source:** `docs/plans/fix-config-probe-exit-code/investigation.md:1-40`; Claude Code skills documentation
- **Finding:** A failed command "aborts the entire skill invocation, not just its own placeholder," and "any non-zero
  exit code counts as a failure."
- **Relevance:** Rules out any unguarded replacement. The chosen `` !`echo "$HOME/.claude"` `` exits 0 unconditionally,
  so it needs no guard.

### E7: `printenv` is not permitted in a probe

- **Source:** Direct experiment (E23); `han-plugin-builder/.../context-injection-commands.md:50-56`
- **Finding:** `` !`printenv HOME` `` aborts. The repo's guidance lists the permitted commands as "`cat`, `ls`, `head`,
  `tail`, `wc`, `grep`, `find` (without the dangerous predicates below), `which`, `echo`, `date`, and the read-only
  `git` and `gh` subcommands," which omits `printenv`.
- **Relevance:** Earlier passes inferred this from the documented list. It is now measured, which closes the
  corroboration gap validation raised (V12).

### E8: No built-in substitution yields the configuration directory

- **Source:** Claude Code skills documentation, "Available string substitutions"
- **Finding:** The complete set is `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, named arguments, `${CLAUDE_SESSION_ID}`,
  `${CLAUDE_EFFORT}`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, and
  `${CLAUDE_PLUGIN_DATA}`. None yields the configuration directory or the home directory.
- **Relevance:** Closes the option of replacing the shell expansion with a harness substitution.

### E9: The rejection is documented as unrecoverable

- **Source:** Claude Code skills documentation, "When an injected command fails"; 2.1.228 changelog
- **Finding:** "Injected commands never prompt for permission. When a command's permission check returns anything other
  than allow, Claude Code aborts the invocation." The 2.1.228 changelog records related hardening: "Hardened skills
  synced from claude.ai: they no longer shadow local commands or MCP prompts, their descriptions are sanitized and
  labeled, and on your machine their bodies don't run `!` commands or expand `@` files."
- **Relevance:** Confirms the abort is by design.
- Unverified: the changelog text covers claude.ai-synced skills, a different provenance tier from Han's marketplace
  install. That makes it context for the direction of the hardening, not proof of the rule measured in E23.

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
  A personal configuration directory the run cannot reach: treat it as no personal configuration, with no note.
  ```
- **Relevance:** The chosen probe keeps the value's meaning and both of its jobs. Only the sentence naming
  `CLAUDE_CONFIG_DIR` becomes false and needs rewriting.

### E11: All 12 config-rule copies are byte-identical

- **Source:** `md5` over `{plugin}/references/config-rule.md` for all 12 plugins
- **Finding:** Every copy reports `0c591431ab7ccb0e92cce3fc5335d081`.
- **Relevance:** No drift to reconcile. Edit once, re-sync, and verify by checksum.

### E12: The 42 probe blocks are byte-identical

- **Source:** Hash comparison of the probe block across every matching `SKILL.md`, normalized only for the `../../`
  depth of the `config-rule.md` link
- **Finding:** One hash across all 42 files.
- **Relevance:** The sweep is a single mechanical substitution.

### E13: Two skills reference the value a second time

- **Source:** `han-communication/skills/readability-guidance/SKILL.md:46-49`;
  `han-communication/skills/edit-for-readability/SKILL.md:76-79`
- **Finding:** Both say a relative `writing-voice` value resolves against "the `personal config directory` the probe
  reported for the personal file."
- **Relevance:** Under the chosen fix a probe still reports the value, so both sentences stay true and neither file
  needs an edit. This was a required change under the rejected first plan.

### E14: The authoring guidance teaches the failing form

- **Source:** `han-plugin-builder/.../context-injection-commands.md:149-153`;
  `han-plugin-builder/.../troubleshooting.md:362-368`
- **Finding:** The guidance offers the failing line under "Prefer (probe resolves the location, a step reads the
  file)", and the troubleshooting doc under "After (correct — probe resolves the location only)". Neither refusal list
  mentions variable references, and `Contains expansion` appears nowhere in the repository.
- **Relevance:** Without updating both, the next skill written from the guidance reintroduces the bug.

### E15: The published promise about `CLAUDE_CONFIG_DIR`

- **Source:** `docs/configuration.md:34-36`
- **Finding:**
  ```
  **Personal:** `.han/config.md` inside your Claude Code configuration directory. That is `~/.claude` unless you have
  set `CLAUDE_CONFIG_DIR`, in which case it is wherever that points. If you have moved your configuration directory, a
  file left behind in `~/.claude/.han/` does not apply.
  ```
- **Relevance:** The only operator-facing text naming the variable, and the sentence the fix reverses.

### E16: The repo's own rule on probes reaching outside the project

- **Source:** `han-plugin-builder/.../context-injection-commands.md:127-135`
- **Finding:** "A probe reads files in the directory the skill runs from. When a step needs the content of a file
  somewhere else, gather it during the run with the Read tool instead... A probe stakes the whole skill on a permission
  decision it cannot recover from."
- **Relevance:** The chosen probe opens no file, so it stays inside this rule. The rule drove the rejected first plan,
  and validation showed the run cannot carry the resolution this rule would hand it (V8).

### E17: No test covers the probe

- **Source:** All six `*.bats` files outside `node_modules`, grepped for `CLAUDE_CONFIG_DIR`, `personal config
  directory`, and `Project Context`
- **Finding:** Zero matches.
- **Relevance:** Nothing blocks the change and nothing guards against regression, so the spot-verification gate carries
  the verification burden.

### E18: The probe loads in this investigation's own session

- **Source:** `command claude --version`; this skill's own Project Context block; a scratch skill carrying the failing
  probe, invoked in this session
- **Finding:** The binary reports `2.1.228 (Claude Code)`. This skill's `personal config directory` resolved to
  `/Users/riverbailey/.claude-testdouble`, and a scratch skill carrying the identical failing probe also loaded and
  resolved.
- **Relevance:** Earlier passes could not explain this. E23 explains it: this session behaves like `bypassPermissions`,
  the one mode that accepts the probe.

### E19: The original validation recorded the probe working

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
- **Relevance:** Confirms the probe was validated rather than assumed, against a check that has since changed. E23
  also closes its open question: the set-versus-unset distinction is irrelevant, because the loader refuses the pattern
  text without resolving it.

### E20: Measured shell behavior of the rejected `printenv` form

- **Source:** Direct shell runs
- **Finding:**
  ```
  printenv CLAUDE_CONFIG_DIR                                    -> /Users/riverbailey/.claude-testdouble, exit 0
  env -u CLAUDE_CONFIG_DIR sh -c 'printenv CLAUDE_CONFIG_DIR'   -> (empty), exit 1
  ... 'printenv CLAUDE_CONFIG_DIR || echo "~/.claude"'          -> ~/.claude, exit 0    (unset)
  CLAUDE_CONFIG_DIR="" sh -c 'printenv ... || echo "~/.claude"' -> (empty), exit 0
  ```
- **Relevance:** The form is correct in a bare shell and still aborts at skill load (E23), which is why shell
  correctness was never sufficient evidence for a probe.

### E21: No settings rule explains the working case

- **Source:** `.claude/settings.local.json`; `~/.claude/settings.json:5-9`;
  `~/.claude-testdouble/settings.json:5-11`
- **Finding:** The repository file holds only `{"outputStyle": "han-communication:Han Readability"}`, and no
  `.claude/settings.json` exists at the repository root. The personal allow lists name three entries, all MCP or Skill
  rules, none touching Bash or `echo`. Both personal files set `"defaultMode": "auto"`.
- **Relevance:** Rules out a local allow rule. E23 shows `auto` aborts the probe, so the settings file is not what
  makes this session permissive.

### E22: The branch is clean

- **Source:** `git branch --show-current`, `git log --oneline main..HEAD`, `git status`
- **Finding:** Branch `han-config-expansion-fix`, level with `main` at `beab327`, working tree clean at the start of
  this work.
- **Relevance:** The fix starts from the released state.

### E23: Measured loader behavior across eleven probe forms and five permission modes

- **Source:** Scratch skills written to `.claude/skills/`, each invoked through a fresh
  `claude -p "/<skill>" --permission-mode <mode> --model haiku --output-format json` session. A loaded skill reports
  `num_turns: 1` with real token usage; an aborted skill reports `num_turns: 0`, `input_tokens: 0`, and an empty
  result. All runs used `CLAUDE_CONFIG_DIR=/Users/riverbailey/.claude-testdouble`.
- **Finding:** Form results are in the table under "What the loader accepts". Mode results for the failing
  probe and for `` !`printenv CLAUDE_CONFIG_DIR || echo "~/.claude"` ``:
  ```
  PROBE     MODE                 TURNS    VERDICT
  probe-a   default              0        ABORTED
  probe-a   plan                 0        ABORTED
  probe-a   acceptEdits          0        ABORTED
  probe-a   bypassPermissions    1        LOADED
  probe-a   auto                 0        ABORTED
  probe-b   default              0        ABORTED
  probe-b   bypassPermissions    1        LOADED
  probe-c   default              1        LOADED     (echo "$HOME")
  probe-d   default              1        LOADED     (echo hello)
  ```
  The chosen replacement, verified separately:
  ```
  probe-m   !`echo "$HOME/.claude"`    default   LOADED    PROBEVALUE=/Users/riverbailey/.claude
  probe-m   !`echo "$HOME/.claude"`    plan      LOADED    PROBEVALUE=/Users/riverbailey/.claude
  probe-m   !`echo "$HOME/.claude"`    auto      LOADED    PROBEVALUE=/Users/riverbailey/.claude
  ```
  A non-interactive abort is silent: the JSON result carries `"is_error":false`, `"subtype":"success"`, and
  `"result":""`.
- **Relevance:** This is the direct reproduction the investigation previously lacked, and it is what turned a
  single-sourced claim into a measured rule. It selects the fix, rules out `printenv`, rules out permission mode as the
  explanation, and explains E18.
- Unverified: I could not test with `CLAUDE_CONFIG_DIR` unset. The home configuration directory on this machine is not
  logged in for the command-line binary, and every such run failed before loading a skill. The set-versus-unset
  distinction does not affect the result, since the loader refuses the pattern text without resolving it.

### E24: The chosen probe supplies the same shape of value as the current one

- **Source:** E23's `probe-m` rows
- **Finding:** The probe injects `/Users/riverbailey/.claude`, an absolute path with no tilde and no trailing slash,
  matching the shape the current probe injects when it works.
- **Relevance:** Nothing downstream changes. The first-action paragraph, the relative-path resolution rule, and the two
  writing-voice passages all keep working against the same kind of value.

### E25: The reported workaround confirms a probe-free bullet loads

- **Source:** Issue #178, comment by VikiAnn, 2026-08-12
- **Finding:** The workaround rewrites the line inside the installed plugin cache:
  ```
  OLD = '- personal config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`'
  NEW = '- personal config directory: /Users/viki/.claude'
  ```
  The comment adds: "That seems to be working fine, but obviously it'll get clobbered with plugin updates etc."
- **Relevance:** Independent confirmation that the abort is caused by this one line and that the rest of the block is
  unaffected. It also shows the value's consumers accept a plain absolute path, which is what the chosen probe injects.

## Validation Results

### Counter-Evidence Investigated

#### V1: Is the 42-file scope complete and correctly bounded?

- **Hypothesis:** The count or the boundary is wrong.
- **Investigation:** Independent `grep -rl` and a full `find` for every `SKILL.md` in the repo, which returns 44.
- **Result:** Partially Refuted. The 42 count is right for the shipped plugins. Two more skills exist under
  `.claude/skills/`, `han-release` and `han-update-documentation`, which carry their own Project Context blocks and
  never carried this probe.
- **Impact:** The Changes section now names those two as out of scope, so a later completeness check does not read the
  sweep as incomplete.

#### V2: Are there other expansion-bearing probes, or `@`-file references, that the scope misses?

- **Hypothesis:** The SKILL.md-only search was too narrow.
- **Investigation:** Searched every file type for `!`...$...`` and for `@`-file syntax.
- **Result:** Refuted. The only other match is a documented bad example under an "Avoid" heading. No `@`-file syntax
  exists in the suite.
- **Impact:** None. Scope confirmed.

#### V3: Is the reporter running code that differs from HEAD?

- **Hypothesis:** The installed ref carries a different probe, so the analysis targets the wrong code.
- **Investigation:** `git show han-v5.0.0-alpha-1:han-planning/skills/plan-implementation/SKILL.md`, plus ancestry
  checks on `5fac8e8`, `e483783`, and `e79299f`.
- **Result:** Confirmed. The ref carries the identical single-level probe.
- **Impact:** None.

#### V4: Is the root cause single-sourced to the reporter?

- **Hypothesis:** The mechanism rests on the reporter's own binary decompilation and no Anthropic-published source
  corroborates it.
- **Investigation:** Fetched the public changelog and the skills and permissions documentation. None contains the
  string "Contains expansion". The permissions doc names only command and process substitution.
- **Result:** Confirmed, and then superseded. The criticism was correct against the earlier draft.
- **Impact:** I reproduced the abort directly and mapped the rule by experiment (E23), which replaced the borrowed
  mechanism with a measured one. The measured rule is narrower than the issue's description, which changed the fix.

#### V5: Does the rejection depend on whether `CLAUDE_CONFIG_DIR` is set?

- **Hypothesis:** The check fires only on the `:-` default branch, which would explain both observations.
- **Investigation:** The error names the raw, un-interpolated pattern text, so the check reads the string rather than a
  resolved value. E23 then confirmed it directly: `` !`echo "$FOOBAR_NOT_REAL"` `` aborts for a variable that does not
  exist anywhere.
- **Result:** Refuted.
- **Impact:** Removed this hypothesis. E23 supplies the real explanation, which is permission mode.

#### V6: Does the fix break the same-file rule in `config-rule.md`?

- **Hypothesis:** Lines 34 to 36 define behavior when both lookups resolve to the same file, and the fix ignores it.
- **Investigation:** Read the rule in full against the planned change.
- **Result:** Partially Refuted. The rule was genuinely unaddressed. It survives the chosen fix, because a probe still
  supplies an absolute path to compare against the working directory.
- **Impact:** Added to the `config-rule.md` change as an item to confirm during the sweep.

#### V7: Does anything parse the Project Context block positionally?

- **Hypothesis:** Changing a bullet shifts something that reads the block by position.
- **Investigation:** Searched every `*.sh`, both repo-maintenance skills and their scripts, and all `*.bats` files.
- **Result:** Refuted. Nothing parses the block positionally.
- **Impact:** None. No extra files change.

#### V8: Can any skill resolve the directory during the run?

- **Hypothesis:** The first plan's replacement is executable, at least for skills holding a Bash grant.
- **Investigation:** Read the `allowed-tools` line of all 42 skills. Thirteen carry no Bash pattern. The other 29 carry
  only scoped patterns such as `Bash(find *)`, `Bash(git *)`, `Bash(gh *)`, `Bash(jq *)`, and `Bash(ls *)`. A grep for
  any `printenv`, `env`, or bare `echo` grant returns zero across the repo.
- **Result:** Confirmed, and worse than the draft stated. Zero of 42, not 13 of 42, can read an environment variable at
  run time.
- **Impact:** This killed the first plan. The fix changed from deleting the probe to replacing it.

#### V9: What does the Read tool do with a `~` path?

- **Hypothesis:** The first plan's fallback is safe.
- **Investigation:** Called Read on `~/.claude/.han/config.md` and compared both directories on this machine.
- **Result:** Confirmed as a correctness regression. Read resolves `~` to the home directory, never to the configured
  one. Here `~/.claude/.han/config.md` exists with 812 bytes of real settings while
  `/Users/riverbailey/.claude-testdouble/.han/` does not exist at all.
- **Impact:** The first plan would have silently applied one profile's config inside another profile's session, which
  breaks "the worst it can do is be ignored" (E10). The chosen fix inherits a narrower form of this risk, disclosed
  under "What the fix gives up" and answered by the symlink.

#### V10: Is `config-rule.md` accurate about tilde handling?

- **Hypothesis:** The canonical file's statement about tilde resolution is correct.
- **Investigation:** Lines 76 to 78 say "a literal `~` handed to a file-reading tool does not resolve." V9 shows it
  does.
- **Result:** Confirmed as a factual error in a canonical file.
- **Impact:** Added as a correction to the `config-rule.md` change.

#### V11: Is `printenv` as a runtime step a better option than any probe?

- **Hypothesis:** Moving `printenv` out of the probe and into a run step, behind an explicit `Bash(printenv *)` grant,
  would preserve the override and dodge the load-time check.
- **Investigation:** The mechanism is sound in principle, since a run step's failure is recoverable where a probe's is
  not. It requires adding a Bash grant to 42 skills, 13 of which deliberately carry none (V8). I could not test whether
  such a grant auto-approves, because a probe test cannot stand in for a runtime tool call.
- **Result:** Partially Refuted as an immediate fix, and retained as the alternative.
- **Impact:** Recorded as option 2 under "The decision this asks you to make", so the choice is yours rather than
  silently made.

#### V12: Is the `printenv` rejection properly evidenced?

- **Hypothesis:** The draft rejected `printenv` by citing documentation it had not fully corroborated.
- **Investigation:** The validator could not locate the published allowlist to re-verify it.
- **Result:** Confirmed as an evidence gap in the draft, now closed. `` !`printenv HOME` `` aborts (E23), which
  settles the question by measurement.
- **Impact:** E7 now rests on an experiment rather than on a documentation claim.

#### V13: Does permission mode explain who sees the bug?

- **Hypothesis:** Different modes handle the probe differently, which would explain the reporter's failure and this
  session's success.
- **Investigation:** Ran the failing probe in `default`, `plan`, `acceptEdits`, `auto`, and `bypassPermissions`.
- **Result:** Partially Confirmed. Mode does decide the outcome, but not in a way that separates ordinary working
  modes. Four of the five abort identically, and only `bypassPermissions` permits the probe.
- **Impact:** The spot-verification gate now specifies `default` mode, because verifying in this session's permissive
  mode would prove nothing.

### Adjustments Made

- **The fix changed entirely.** V8 and V9 refuted the first plan, which deleted the probe and asked the run to resolve
  the directory. The plan now replaces the probe with a form measured to load.
- **The root cause was rewritten.** V4 showed the mechanism was borrowed from the issue and uncorroborated. E23
  replaced it with a measured rule, which is narrower: bare `$HOME` is permitted, brace syntax is refused even for
  `$HOME`, and every other variable name is refused.
- **The mode question was answered and folded in.** V13 supplied the explanation for E18 that earlier passes left open.
- **Two files left the change list.** E13's two skills need no edit under the chosen fix, because a probe still reports
  the value their prose refers to.
- **Three items joined the `config-rule.md` change.** The same-file rule (V6), the tilde correction (V10), and the
  rewritten `CLAUDE_CONFIG_DIR` sentence.
- **The scope boundary is now explicit.** V1 added the two repo-maintenance skills as named exclusions.
- **The verification gate got a mode.** V13 made `default` mode a requirement of the spot check.

### Confidence Assessment

- **Confidence:** High on the root cause and the mechanism, Medium on the fix as a whole.
- **Remaining Risks:**
  - The `CLAUDE_CONFIG_DIR` override stops working. This is a deliberate, disclosed narrowing of a published promise
    and needs your decision, not only your approval (see "The decision this asks you to make").
  - Anyone who moved their configuration directory and left a stale `~/.claude/.han/config.md` behind will have that
    stale file applied. The symlink fixes it, and nothing detects the situation automatically (V9).
  - I could not test with `CLAUDE_CONFIG_DIR` unset, because the home configuration directory is not logged in for the
    command-line binary. The measured rule makes the distinction irrelevant, since the loader refuses pattern text
    without resolving it, but the unset path itself is untested end to end.
  - The measured rule describes today's loader. The guidance's own warning that the allowlist "can shift between
    Claude Code versions" applies to the replacement exactly as it applied to the original, and no test guards it
    (E17).
  - Option 2 in the decision section is untested. If you choose it, it needs its own verification before the sweep,
    because a probe test cannot stand in for a runtime tool call (V11).

## Coding Standards Reference

| Standard                                                                      | Source                                                        | Applies To                                            |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------- |
| Keep every probe command an auto-approvable read-only form                     | `han-plugin-builder/.../context-injection-commands.md:44-123`  | The replacement probe, and rejecting `printenv`        |
| Keep every probe reading inside the project working directory                  | `han-plugin-builder/.../context-injection-commands.md:127-135` | Keeping the probe to a path, opening no file           |
| A bad config can never fail a skill run                                        | `han-core/references/config-rule.md:113`                       | The whole fix direction                                |
| Vendored reference files stay byte-identical to the canonical copy             | `CLAUDE.md`, "Configuration"                                   | The 12 `config-rule.md` copies                         |
| One canonical source per concept; other surfaces carry a scent plus a link     | `CLAUDE.md`, "Conventions"                                     | `docs/configuration.md` and the guidance docs          |
| Writing voice: em-dashes only as label-gloss or appositive, direct second person | `han-communication/references/writing-voice.md`               | Every prose edit in the fix                            |
| Conventional Commits                                                           | `~/.claude/references/the-book/git/commits.md`                 | Every commit in the fix                                |
| Never bump a plugin version unprompted                                         | Operator instruction                                           | Excludes `plugin.json` and `CHANGELOG.md` from the fix |
