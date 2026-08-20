# Investigation: personal-config probe aborts every skill (issue #178)

Claude Code's skill loader now refuses almost every environment-variable reference in a load-time probe. All 42 Han
skills read the personal config directory through one. I reproduced the abort locally and tested eleven probe forms
across five permission modes to find which ones survive. Exactly one useful form does.

A later round measured a route that keeps the override alive. A probe can run a shell script when the skill grants
that one command, and a script reads the environment in an ordinary shell. That is the chosen fix. Read the Summary,
then approve the Planned Fix or push back.

## Summary

- **Root Cause:** All 42 skills carry the probe `` !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"` ``, and the loader
  refuses it, aborting the skill before its body loads. The refusal is narrower than the issue reports: bare `$HOME` is
  permitted, while `${...}` brace syntax, every other variable name, and `printenv` are all refused (E23).
- **Fix:** Option 3, chosen by the operator. Add one shared script at `scripts/han-config-dir.sh`, symlink it into the
  12 plugins that carry config-consuming skills, and have all 42 skills invoke it from a guarded probe behind a grant
  naming that one command. The script reads `CLAUDE_CONFIG_DIR` in an ordinary shell, so the override keeps working
  where no probe can read it directly (E26 through E30).
- **Why Correct:** I ran each candidate form through a fresh Claude Code session and recorded which loaded. The chosen
  form loaded in all of `default`, `plan`, `acceptEdits`, `auto`, and `bypassPermissions`, from a plugin installed
  through a GitHub-source marketplace, and it injects the same kind of absolute path the current probe does (E27, E29).
  A marker file written by the script proves the probe executed it and recovered the override, with no model in the
  loop (E29).
- **Validation Outcome:** Adversarial validation refuted my first fix. That version deleted the probe and told the run
  to resolve the directory itself. No skill can do that: zero of the 42 have a Bash grant that reads an environment
  variable. The Read tool also expands `~` to the home directory rather than the configured one, so the run would have
  silently applied the wrong profile's config (V8, V9).
- **Remaining Risks:** The fix adds a Bash grant to the 5 skills that carry none today, though the grant names one
  exact command and does not widen what the run may execute (E30). It repeats that command text twice in every skill,
  so a later edit has 84 places to land. It also depends on `${CLAUDE_PLUGIN_ROOT}` being substituted before the
  permission check, which is loader behavior rather than a documented guarantee (E27). See the Confidence Assessment.

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

Add one shared resolver script at the repository root, symlink it into the 12 plugins that carry config-consuming
skills, and have all 42 skills call it from a guarded probe behind a grant naming that one command. The script reads
`CLAUDE_CONFIG_DIR` in an ordinary shell, so the override survives where no probe can read it directly. The
documentation changes follow from what the fix keeps rather than from what it drops.

### The decision this asks you to make

No probe can read `CLAUDE_CONFIG_DIR` directly. Every form that names the variable in probe text aborts, whether
through `echo`, through braces, or through `printenv` (E23). No built-in skill substitution yields the configuration
directory either (E8). This is measured, not assumed.

A probe can still reach the variable indirectly, by running a script that reads it in an ordinary shell. That is
option 3, and it changes the shape of this decision: keeping the override is now possible, at a cost paid in tool
grants and repeated text rather than in lost behavior.

1. **Accept the default location.** The personal config is `~/.claude/.han/config.md`, always. Anyone who has moved
   their configuration directory links the two with one command:
   `ln -s "$CLAUDE_CONFIG_DIR/.han" ~/.claude/.han`. This ships now and needs nothing from anyone who has not moved
   their directory.
2. **Preserve the override with a new tool grant.** Delete the probe and add `Bash(printenv *)` to every skill so a run
   step can read the variable. This keeps the override, but it adds a Bash grant to 42 skills, 5 of which deliberately
   carry none today. It also rests on behavior I could not test, since a probe cannot stand in for a runtime tool call
   (V8, V11).
3. **Run one shared script from the probe, under an explicit grant.** Keep a single script at the repository root,
   symlink it into each plugin that carries config-consuming skills, and have every skill invoke it from its probe
   behind a grant naming that one command. The script reads `CLAUDE_CONFIG_DIR` in a normal shell, so the override
   keeps working. Measured end to end, including installation from a GitHub source (E26 through E30).

The operator chose option 3, and the Changes section below implements it. Options 1 and 2 stay recorded here because
they shaped the measurements, and because option 1 remains the fallback if the loader stops substituting
`${CLAUDE_PLUGIN_ROOT}` ahead of the permission check.

### What option 3 looks like

Three pieces. The shared script stays outside every plugin, so no new base-level plugin dependency appears.

The script at the repository root, `scripts/han-config-dir.sh`:

```bash
#!/usr/bin/env bash
# Prints the Claude Code configuration directory for this run.
set -euo pipefail
printf '%s\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
```

A relative symlink into each plugin that carries config-consuming skills, one per plugin:

```
han-communication/scripts/han-config-dir.sh -> ../../scripts/han-config-dir.sh
```

And in each `SKILL.md`, one grant beside the existing tools and one probe line in place of the failing one:

```yaml
allowed-tools: Read, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
```

```
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
```

Four measured facts hold this together. A script probe aborts without a grant and loads with one, so the grant is what
decides the outcome (E26). The braced `${CLAUDE_PLUGIN_ROOT}` resolves before the permission check runs, but only
inside a real plugin (E27). The `2>/dev/null || echo "$HOME/.claude"` guard is mandatory, because a missing or failing
script aborts the skill without it (E28). Plugin installation copies the symlink target as a regular file, from both a
directory source and a GitHub source, so the shared script ships (E29).

### What option 3 costs

It touches the same 42 skills across 12 plugins as the other options, and adds a Bash grant to the 13 that carry none
today. The grant names one exact command rather than a pattern, and it does not widen what the run may execute: a skill
holding it was still denied `touch` (E30).

The probe line is longer and harder to read than option 1's, and the same command text has to appear twice in every
skill, once in the grant and once in the probe. Any later change to that command has to land in both places across all
42 files.

Each of the 12 plugins needs its own symlink, because `${CLAUDE_PLUGIN_ROOT}` resolves to the plugin holding the skill
and cannot reach a sibling plugin. The 12 links point at one file, so the script itself stays single-sourced.

### Why this approach and not the alternatives

**A shared script behind an explicit grant (chosen).** It loads in every permission mode, from a plugin installed
through a GitHub-source marketplace, and it returns the `CLAUDE_CONFIG_DIR` value rather than the home directory (E27,
E29). It is the only measured option that keeps the override. The guidance already allows this route: its rule on
auto-approvable commands lists two ways a command qualifies, and the second is "matched by an explicit `Bash()` rule in
the skill's `allowed-tools`". The investigation had never verified that second route for a probe. It does now (E26).

**`` !`echo "$HOME/.claude"` `` (option 1, kept as the fallback).** It loads in every permission mode (E23) and injects
an absolute path, exactly what the current probe injects, so the value's meaning and both of its downstream jobs survive
untouched. The diff is one line in 42 files. It drops the `CLAUDE_CONFIG_DIR` override, which is the reason it was not
chosen.

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

No published behavior. The `CLAUDE_CONFIG_DIR` override keeps working, so the contract rule that "If you have moved your
configuration directory, a file left behind in `~/.claude/.han/` does not apply" stays true and `docs/configuration.md`
needs no correction (E15).

The cost is paid in the skill files instead. Five skills that deliberately carry no Bash grant gain one, the probe
line becomes harder to read than a bare `echo`, and the same command text lives in two places in each of 42 files.

One degradation path is new. If the script is missing or fails, the guard falls back to `$HOME/.claude` even for someone
who has set `CLAUDE_CONFIG_DIR` (E28). That is quieter than the old failure, which took the whole skill down, and it
matches the contract's rule that a bad config can never fail a run (E10). It still needs writing down, because it is a
case where the override silently stops applying.

### Changes

The order matters. The script and the symlinks have to exist before any skill points at them, and the spot check has to
pass before the sweep touches the other 41 files.

#### 1. New file: `scripts/han-config-dir.sh`

- **Change:** Add the one shared script, at the repository root and outside every plugin.
- **Evidence:** (E26), (E28), (E29).
- **Standards:** One canonical source per concept. Scripts with shebangs must be executable, which the `prek` hooks
  already check.
- **Details:** The whole file:

```bash
#!/usr/bin/env bash
# Prints the Claude Code configuration directory for this run.
set -euo pipefail
printf '%s\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
```

  It stays outside the plugins on purpose, so no plugin gains a dependency on another plugin to reach it. Verified in a
  bare shell both ways: it prints the variable when set, and `~/.claude` under `env -u CLAUDE_CONFIG_DIR`. That second
  branch is the one E23 could never exercise from a probe.

#### 2. Twelve symlinks, one per plugin carrying config-consuming skills

- **Change:** Add `{plugin}/scripts/han-config-dir.sh` as a relative symlink to the shared script.
- **Evidence:** (E27), (E29).
- **Standards:** Vendored copies stay byte-identical to the canonical file. A symlink satisfies that by construction.
- **Details:** Each link is created from inside the plugin's `scripts/` folder so the stored target stays relative:

```bash
ln -s ../../scripts/han-config-dir.sh {plugin}/scripts/han-config-dir.sh
```

  The 12 plugins are the ones holding the 42 affected skills: `han-atlassian`, `han-coding`, `han-communication`,
  `han-core`, `han-documentation`, `han-feedback`, `han-github`, `han-linear`, `han-planning`, `han-plugin-builder`,
  `han-reporting`, and `han-research`. Every plugin needs its own link, because `${CLAUDE_PLUGIN_ROOT}` resolves to the
  plugin holding the skill and cannot reach a sibling (E27). Installation copies the target as a regular file, so what
  ships is a real script rather than a link (E29). The existing `check-symlinks` and `destroyed-symlinks` hooks already
  guard these against breaking.

#### 3. Spot-verify one skill as an installed plugin before the sweep

- **Change:** Apply the script, the symlink, the grant, and the probe line to a single skill, then install that plugin
  and invoke the skill.
- **Evidence:** (E5), (E19), (E27), (E29).
- **Standards:** The probe-authoring guidance's warning that the allowlist "can shift between Claude Code versions."
- **Details:** Use `han-communication:readability-guidance`, which declares `allowed-tools: Read` and is the strictest
  permission case in the set (V8). Two conditions are not optional. Run it in `default` mode, because
  `bypassPermissions` accepts probes every other mode rejects (E23). Run it as an installed plugin rather than a local
  skill, because `${CLAUDE_PLUGIN_ROOT}` resolves only inside a plugin and the same line aborts outside one (E27).
  Confirm the injected value is the configuration directory and not the home directory. If the check fails, stop and
  fall back to option 1 rather than continuing the sweep.

#### 4. All 42 `*/skills/*/SKILL.md` files

- **Change:** Replace the probe line and add one grant to `allowed-tools`.
- **Evidence:** (E1), (E12), (E26), (E27), (E28).
- **Standards:** Probe-authoring guidance, "Keep every command an auto-approvable read-only form", satisfied through
  its second route: a command matched by an explicit `Bash()` rule in the skill's `allowed-tools`.
- **Details:** All 42 blocks are byte-identical apart from the relative depth of the `config-rule.md` link (E12), so the
  probe line is one substitution applied 42 times:

```
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
```

  The grant is added to each skill's existing `allowed-tools` list:

```yaml
allowed-tools: Read, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
```

  Three details decide whether this works. The braces around `CLAUDE_PLUGIN_ROOT` are required, because the unbraced
  spelling is not a harness substitution and is refused (E27). The `2>/dev/null || echo "$HOME/.claude"` guard is
  required, because a missing or failing script otherwise aborts the skill (E28). The grant needs to name only the
  `bash ...` half, because the `echo` half is separately auto-approvable (E28).

  Five of the 42 carry no Bash grant today and gain their first one: `han-communication` `readability-guidance`,
  `edit-for-readability`, and `explanation-guidance`, plus `han-coding` `investigate` and `han-reporting` `html-summary`.
  The grant names one exact command and does not widen what the run may execute (E30). An earlier count put this at 13
  by reading only the first line of each `allowed-tools` block; the eight skills that spell the value across
  continuation lines already carry Bash grants (V16).

  The surrounding first-action paragraph keeps its current wording, because the label still names a resolved absolute
  directory. The complete file list is in E1. Two repo-maintenance skills under `.claude/skills/` carry their own
  Project Context blocks and never carried this probe, so they are out of scope (V1).

#### 5. `han-core/references/config-rule.md` and its 11 vendored copies

- **Change:** Correct the factual error about tilde handling, record the new degradation path, and confirm the
  same-file case.
- **Evidence:** (E10), (E11), (V6), (V9), (V10), (E28).
- **Standards:** One canonical source per concept; vendored copies stay byte-identical.
- **Details:** All 12 copies share md5 `0c591431ab7ccb0e92cce3fc5335d081` (E11). Edit the canonical `han-core` copy,
  re-sync the other 11, and confirm the checksums match again.

  The bullet at lines 15 to 17 needs no change. It says the directory is "Named by the `CLAUDE_CONFIG_DIR` environment
  variable when that variable is set, and `~/.claude` when it is not", and that is exactly what the script does. This is
  the promise option 1 would have broken.

  Two edits remain, plus one confirmation:
  - Lines 76 to 78 state that "a literal `~` handed to a file-reading tool does not resolve." That is wrong. The Read
    tool resolves it to the home directory, which I confirmed directly (V10). Correct the sentence rather than leave a
    canonical file stating a false fact about tool behavior.
  - Add the new degradation path: if the resolver script is missing or fails, the probe falls back to `$HOME/.claude`
    even when `CLAUDE_CONFIG_DIR` is set, so the override silently stops applying (E28). Nothing detects this, which is
    why it belongs in the contract rather than only in this document.
  - Lines 34 to 36 define what happens when both lookups resolve to the same file, which the run detects by comparing
    the resolved directory against the working directory (V6). The probe still supplies an absolute path, so this rule
    keeps working. Confirm it during the sweep rather than assume it.

#### 6. `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md`

- **Change:** Replace the recommended example carrying the failing probe, record what the loader accepts, and document
  the script-behind-a-grant pattern.
- **Evidence:** (E14), (E23), (E26), (E27), (E28).
- **Standards:** The file's own path-scoped rule header, which applies it to every `SKILL.md` in the repo.
- **Details:** Line 152 offers the failing line under "Prefer (probe resolves the location, a step reads the file)".
  Replace it with the guarded script form.

  The refused-constructs list names four items. Add a fifth covering environment-variable references, and state the
  measured rule: bare `$HOME` is permitted, brace syntax is refused even for `$HOME`, and every other variable name is
  refused. Add `printenv` to the commands the guidance says are not permitted, and add the eleven-row results table from
  this investigation so the next author does not have to rerun it.

  Then add the pattern this fix introduces, because the file currently teaches only the first route to auto-approval:
  - A probe may run a repository script when the skill grants that exact command in `allowed-tools`. Without the grant
    it aborts, even with no variable anywhere in the command (E26).
  - Use the braced `${CLAUDE_PLUGIN_ROOT}`. It is substituted before the permission check, so the check never sees a
    variable reference. The unbraced spelling is refused, and both spellings are refused outside a plugin (E27).
  - Guard the command with `2>/dev/null || echo <fallback>`. A missing or failing script aborts the skill otherwise
    (E28).

#### 7. `han-plugin-builder/skills/guidance/references/skill-building-guidance/troubleshooting.md`

- **Change:** Update the worked "after" example, and add a section for this refusal.
- **Evidence:** (E14), (E23), (E26), (E28).
- **Standards:** Same guidance conventions.
- **Details:** Line 365 carries the failing form as the correct outcome. Replace it with the guarded script form. Add a
  section covering the `Contains expansion` error, following the shape of the sections already there.

  Note the silent non-interactive failure: a `claude -p` run aborts with no error text and an empty result, and
  `--debug` adds nothing, so a skill that appears to do nothing is the symptom to recognize (E23). Add the two
  symptoms this fix introduces as well, since both abort a skill the same silent way: a probe running a script with no
  matching grant, and a script that is missing or exits non-zero without a guard (E26, E28).

#### 8. `test/` coverage for the duplicated command string

- **Change:** Add a Bats check that every affected skill's grant and probe name the same script path.
- **Evidence:** (E17), (E26).
- **Standards:** A script's tests sit beside it; harness-level checks live in `test/`.
- **Details:** Nothing tests the probe today (E17), and this fix puts one command string in two places in each of 42
  files. A grant that stops matching its probe aborts the skill silently, which is the hardest failure in this whole
  investigation to notice. The check walks the skills carrying the probe and asserts three things: the probe line is
  present, `allowed-tools` names the same script path, and the referenced `{plugin}/scripts/han-config-dir.sh` exists.
  The existing `check-symlinks` hook already covers a link whose target has gone, so the test does not need to.

#### 9. `docs/configuration.md`

- **Change:** None required for the override. Add the new degradation path.
- **Evidence:** (E15), (E28).
- **Standards:** Writing voice; YAGNI applies to docs.
- **Details:** Lines 34 to 36 promise that the personal file lives wherever `CLAUDE_CONFIG_DIR` points, and that promise
  survives this fix intact, so leave them alone. The degradation text at lines 183 and 184 needs no change either. The
  one addition is the missing-script fallback, stated once, in the same place the file already describes what happens
  when configuration cannot be read (E28).

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

### E26: A grant, not the probe text, decides whether a script probe loads

- **Source:** Scratch skills invoked through `claude -p "/<skill>" --permission-mode <mode> --model haiku
  --output-format json`, the same harness as E23. Claude Code `2.1.234`.
- **Finding:** A probe running `bash ./scripts/han-config-dir.sh`, containing no `$` anywhere, aborts with
  `allowed-tools: Read`. The identical probe loads once the skill declares
  `allowed-tools: Read, Bash(bash ./scripts/han-config-dir.sh)`. Three grant spellings load: the exact command,
  `Bash(bash:*)`, and bare `Bash`. A grant naming a different command, `Bash(echo:*)`, aborts.
- **Relevance:** Separates two refusals that E23 read as one. A variable reference fails the expansion check on the
  probe's text, and no grant helps. A script invocation fails a permission check, and a grant satisfies it. This is what
  makes option 3 possible.

### E27: `${CLAUDE_PLUGIN_ROOT}` resolves before the permission check, but only inside a plugin

- **Source:** The same harness, run twice: against scratch skills in `.claude/skills/`, and against a throwaway plugin
  loaded with `claude --plugin-dir`.
- **Finding:**
  ```
  CONTEXT           PROBE                                          GRANT        RESULT
  local skill       bash "${CLAUDE_PLUGIN_ROOT}/scripts/x.sh"      matching     ABORTED
  local skill       bash "${CLAUDE_SKILL_DIR}/x.sh"                matching     ABORTED
  plugin            bash "${CLAUDE_PLUGIN_ROOT}/scripts/x.sh"      matching     LOADED
  plugin            bash "${CLAUDE_PLUGIN_ROOT}/scripts/x.sh"      none         ABORTED
  plugin            bash "$CLAUDE_PLUGIN_ROOT/scripts/x.sh"        matching     ABORTED
  plugin            bash "${CLAUDE_SKILL_DIR}/../../scripts/x.sh"  matching     LOADED
  ```
  The loaded rows returned `/Users/riverbailey/.claude-testdouble`, the `CLAUDE_CONFIG_DIR` value, not the home
  directory.
- **Relevance:** The harness substitutes the braced built-in before the permission check, so the check never sees a
  variable reference. Outside a plugin nothing defines it and the text reaches the expansion check, which refuses it.
  The unbraced spelling is not a harness substitution and is refused everywhere, so option 3 depends on the braces.

### E28: An unguarded script probe aborts the skill when the script is missing or fails

- **Source:** The same harness against the throwaway plugin, `default` mode.
- **Finding:**
  ```
  PROBE                                                              RESULT
  bash "${CLAUDE_PLUGIN_ROOT}/scripts/does-not-exist.sh"             ABORTED
  bash "${CLAUDE_PLUGIN_ROOT}/scripts/fails.sh"        (exit 3)      ABORTED
  bash ".../does-not-exist.sh" 2>/dev/null || echo "$HOME/.claude"   LOADED, value /Users/riverbailey/.claude
  bash ".../han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"   LOADED, value /Users/riverbailey/.claude-testdouble
  ```
  A grant naming only the `bash ...` half is enough for the guarded command, because the `echo` half is separately
  auto-approvable.
- **Relevance:** Sets the guard as mandatory rather than stylistic. Without it, a missing or broken script fails the
  skill run, which the configuration contract forbids: "A bad config can never fail a skill run" (E10). With it, the
  probe degrades to the home directory.

### E29: Plugin installation copies the symlink target as a regular file

- **Source:** A throwaway marketplace holding one plugin and a `shared-scripts/` folder outside it, with
  `zzgh/scripts/han-config-dir.sh` committed as a relative symlink (git mode `120000`, target
  `../../shared-scripts/han-config-dir.sh`). Installed twice through `claude plugin install`: once from a local
  directory source, once from `mxriverlynn/zz-symlink-probe` as a GitHub source.
- **Finding:** Both installs produced a regular 153-byte executable file at
  `.../plugins/cache/<market>/<plugin>/0.0.1/scripts/han-config-dir.sh`, not a link, and running it printed
  `/Users/riverbailey/.claude-testdouble`. The GitHub marketplace clone retains the repository root, including the
  `shared-scripts/` folder the link points at. Invoking the installed skill loaded it in `default`, `plan`,
  `acceptEdits`, `auto`, and `bypassPermissions`.
  Independently of any model output, replacing the installed script with one that writes a marker file and invoking the
  skill produced `/tmp/zzgh-probe-marker.txt` containing `/Users/riverbailey/.claude-testdouble`.
- **Relevance:** Closes the distribution question option 3 turns on. A script kept outside the plugins ships correctly
  into each one, so no new base-level plugin dependency is needed. The marker file proves the probe executed the
  installed script and recovered the override, without relying on a model to report the value.
- Unverified: `claude plugin marketplace add --sparse` limits the checkout to named directories. A sparse checkout that
  excludes the repository root would leave the link with no target.

### E30: The narrow grant does not widen what the run may execute

- **Source:** Three skills in the throwaway plugin, `default` mode, reading `permission_denials` from the JSON result.
- **Finding:**
  ```
  SKILL         GRANT                          TASK                            DENIALS  RESULT
  pscope        Bash(bash ".../han-config...") run `whoami`                     0       succeeded
  pscopectl     none (allowed-tools: Read)     run `whoami`                     0       succeeded
  pscopewrite   Bash(bash ".../han-config...") run `touch /tmp/<marker>`        1       denied, no file created
  ```
- **Relevance:** The first row alone reads as the grant handing the run general Bash access. The control shows
  otherwise: a skill with no Bash grant ran `whoami` too, so `whoami` was auto-approved on its own merits. The mutating
  command was denied under the grant. Option 3's grant is therefore narrower in effect than option 2's
  `Bash(printenv *)`, which is shaped to read anything in the environment.

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
- **Investigation:** Read the `allowed-tools` line of all 42 skills. Thirteen appear to carry no Bash pattern, which
  V16 later corrected to five. The other skills carry
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
  not. It requires adding a Bash grant to 42 skills, 5 of which deliberately carry none (V8, corrected by V16). I could not test whether
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

#### V14: Does option 3's Bash grant hand the run general shell access?

- **Hypothesis:** Adding `Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")` to a skill gives the model
  broad Bash power during the run, which would be unacceptable in the 5 skills that carry no Bash grant today.
- **Investigation:** A skill holding the grant ran `whoami` with no permission denial, which supported the hypothesis.
  A control skill declaring only `allowed-tools: Read` ran `whoami` as well, so `whoami` was auto-approved regardless of
  the grant. A third skill holding the grant was denied `touch /tmp/<marker>`, recorded one permission denial, and
  created no file (E30).
- **Result:** Refuted. The grant does not widen what the run may execute.
- **Impact:** Removes the main objection to option 3 and separates it from option 2, whose `Bash(printenv *)` pattern is
  shaped to read anything in the environment. My first reading of this test was wrong and the control corrected it.

#### V15: Does the option 3 measurement rest on model-reported values?

- **Hypothesis:** The probe values recorded for option 3 came from a model repeating text back, so a misreport could
  fake a passing result.
- **Investigation:** Repeat runs of one installed skill returned the correct path, an empty string, and once the word
  `operational`, while every run reported one model turn. Replacing the installed script with one that writes a marker
  file removed the model from the loop.
- **Result:** Partially Confirmed. The readback is unreliable; the load signal and the marker file are not.
- **Impact:** Every option 3 claim now rests on the load signal (`num_turns`), on direct file-system inspection, or on
  the marker file (E29). The value readbacks are corroboration, not the evidence.

#### V16: Is the count of skills carrying no Bash grant correct?

- **Hypothesis:** The figure of 13 skills with no Bash grant, carried from V8 through every later pass, is right.
- **Investigation:** V8 read the first line beginning `allowed-tools:` in each file. Eight of the 42 skills write that
  value as a YAML plain scalar spread over continuation lines, so the first line is the bare key and the tools sit
  underneath. Parsing the full value shows those eight all carry Bash grants already, among them `han-coding` `tdd` and
  `refactor`, `han-documentation` `runbook`, and four `han-atlassian` skills.
- **Result:** Refuted. Five skills carry no Bash grant, not 13: the three `han-communication` skills, `han-coding`
  `investigate`, and `han-reporting` `html-summary`.
- **Impact:** The main cost of options 2 and 3 is smaller than every earlier pass recorded. Corrected everywhere the
  number appears.

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

- **Confidence:** High on the root cause and the mechanism. High on option 3's mechanics, which are measured through a
  GitHub-source install. Medium on the fix as a whole, because the choice between the three options is still open.
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
  - Option 3 is measured end to end but repeats one command string twice in each of 42 files, so a later edit to that
    command has 84 places to land. Nothing tests the two copies agree (E17 still holds: no test covers the probe).
  - Option 3 depends on `${CLAUDE_PLUGIN_ROOT}` being substituted before the permission check (E27). That is loader
    behavior, undocumented as an ordering guarantee, and carries the same version-drift exposure the guidance already
    warns about.
  - Option 3 assumes the installer keeps dereferencing symlinks (E29). A sparse checkout that excludes the repository
    root would break the link, and `claude plugin marketplace add --sparse` makes that reachable.

## Coding Standards Reference

| Standard                                                                      | Source                                                        | Applies To                                            |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------- |
| Keep every probe command an auto-approvable read-only form                     | `han-plugin-builder/.../context-injection-commands.md:44-123`  | Satisfied through the rule's second route, an explicit `Bash()` grant, rather than the built-in allowlist |
| Keep every probe reading inside the project working directory                  | `han-plugin-builder/.../context-injection-commands.md:127-135` | The probe executes a script inside the plugin and opens no file; the script prints an environment value |
| Scripts with a shebang are executable, and symlinks resolve                    | `.pre-commit-config.yaml`, `check-symlinks` and `destroyed-symlinks` | The new resolver script and the 12 plugin symlinks |
| A bad config can never fail a skill run                                        | `han-core/references/config-rule.md:113`                       | The whole fix direction                                |
| Vendored reference files stay byte-identical to the canonical copy             | `CLAUDE.md`, "Configuration"                                   | The 12 `config-rule.md` copies                         |
| One canonical source per concept; other surfaces carry a scent plus a link     | `CLAUDE.md`, "Conventions"                                     | `docs/configuration.md` and the guidance docs          |
| Writing voice: em-dashes only as label-gloss or appositive, direct second person | `han-communication/references/writing-voice.md`               | Every prose edit in the fix                            |
| Conventional Commits                                                           | `~/.claude/references/the-book/git/commits.md`                 | Every commit in the fix                                |
| Never bump a plugin version unprompted                                         | Operator instruction                                           | Excludes `plugin.json` and `CHANGELOG.md` from the fix |
