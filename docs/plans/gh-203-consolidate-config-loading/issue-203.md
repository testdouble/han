# Issue #203: Consolidate config loading; the inline half of the data-fetch prohibition is unevidenced

Source: https://github.com/testdouble/han/issues/203 (opened by @taminomara, state: open). Body copied verbatim as the specification for this plan.

## Summary

Every skill resolves `.han/config.md` for itself. When one skill invokes another, the caller's context ends up holding
several copies of the same config content and several copies of the same 65-word instruction to go read it. The obvious
fix is a shared config-loading skill, which `skill-composition.md` forbids.

The evidence behind that prohibition is about `context: fork`. The inline case was measured 34 times and held. I would
like to correct the guidance, then consolidate.

## The duplication

44 of 47 skills carry the `project .han/config.md` probe, and 45 carry the instruction block after it. That block is 65
words, so the suite carries about 2,900 words of identical instruction.

Suite-wide duplication is not the problem, since a skill invoked on its own loads the block once. Chains are. A
`plan-a-feature` run that invokes `readability-guidance` and then `explanation-guidance` puts **three copies of the
config content and three of the instruction into one context window**, and copies two and three tell a model that has
already resolved the config to resolve it again.

`context-hygiene.md:104`:

> ### Rule: The attention cost is per-context, not per-file
>
> Copies compete for attention only when they load into the same context.

That rule's carve-out is for content partitioned across sub-agent contexts that never co-reside. These co-reside.

Only `readability-guidance` (24 callers), `explanation-guidance` (8), and the Atlassian orchestration targets are ever
invoked by another skill, so this is a five-skill problem rather than a 44-skill one.

## The cost is already visible

Per-skill config resolution has been rewritten three times: the original inline probe, #184's move to
`scripts/han-config-dir.sh` after the loader began refusing that probe, and #172, still open, adding `AGENT_CONFIG_DIR`
for Pi. Each pass edits 40-odd files to change one lookup.

#172 shows the cost. Its central change:

```diff
-- personal config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`
+- personal config directory: !`echo "${AGENT_CONFIG_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"`
```

That edits the probe form #184 deleted twelve days later because the loader refuses it (#178), and replaces it with a
nested expansion, which is more of what the loader rejects.
`skill-building-guidance/context-injection-commands.md` now says to reach an environment variable through a script
rather than probe text. The PR is not wrong about anything; it predates the fix and has not been rebased. That is the
shape of the problem: one lookup, spread across 40-odd files, goes stale before it can land.

Under a consolidated loader, #172's config half becomes one line inside `han-config-dir.sh`. Its Pi marketplace entries
and compat checks are unaffected.

## Why the obvious fix is forbidden

`skill-composition.md` classifies "a skill calls another skill just to retrieve a few values (config paths, a command, a
setting)" as data-fetch composition and says to avoid it. `troubleshooting.md:473` extends that to both forms:

> ### Cause 1: Data-fetch sub-skill (forked or inline)
>
> This is unreliable in both forms. Inline, the model has no structured return mechanism and must manually
> context-switch back to the parent workflow.

A shared config-reading sub-skill is the guidance's own example of the anti-pattern, so `/load-han-config` is exactly
what it says not to build.

## What the evidence shows

**The primary account is fork-only.** `writing-effective-instructions.md:145` is titled "Prefer inline discovery over
**forked** data-fetch sub-skills":

> after a **forked** config-reading sub-skill returns "Not found: ...", an `api_retry` event can fire and the calling
> model treats the sub-skill's output as its final answer

The failing pair was `code-review → read-project-config` across 7 skills, and the mechanism is `api_retry` anchoring
after `context: fork`. Every example in that section is a forked call.

**The inline case was measured and held.** The OI-3 spike (`8c96157`):

> Rigorous subagent-harness spike (46 trials, 4 arms): 34/34 same-context Skill-call invocations completed with zero
> early exits, including a worst-case adversarial arm. Forked `context:fork` disqualified because it isolates the
> guidance so its content never reaches the caller.

Fork failed for the opposite reason to the one the prohibition describes: its content never reaches the caller at all.

**So "unreliable in both forms" is assertion.** "Inline, the model has no structured return mechanism" does not describe
the mechanism. An inline sub-skill renders into the shared context, and whatever it resolved is simply there. That is
how `readability-guidance` already works.

`skill-composition.md:121`'s exception requires "a whole standard, not a few values." That boundary looks drawn around
the case the spike happened to run rather than around a failure mode; the property carrying the evidence is inline
rather than forked.

I am not claiming the values case is proven. The spike surfaced a standard, and nobody has run the same trial on
resolved values. That gap is untested, not known-broken.

## Proposal

1. Correct `troubleshooting.md:473` to match the evidence, or attach evidence I did not find.
2. Run an OI-3-shaped trial on the values case, with a worst-case arm.
3. If it holds, add `load-han-config` to `han-core`, beside `project-discovery`, already the precedent for
   machine-written, skill-consumed project context.
4. Cut each consuming skill's block to one line: "Resolve configuration with `han-core:load-han-config` if you have not
   already this run." The idempotence hint keeps a chain resolving once.
5. Widen property 2 of the exception to match the trial.

Step 1 stands regardless, since the guidance currently contradicts its own spike.

## Open questions

- **Is there inline-failure evidence I missed?** I searched the guidance, the OI-3 artifacts, and the commit history
  and found only the forked account. If "both forms" came from an unrecorded observation, that changes the answer and
  is worth writing down.
- **Does the personal-config Read survive consolidation?** The personal file is read with the Read tool rather than a
  probe, deliberately, because a probe cannot prompt or degrade. A consolidating skill would own that read, which seems
  fine, but it moves a decision `config-rule.md` currently pins per skill.
- **Is one line enough when a skill is invoked directly?** `load-han-config` has to be discoverable from that line
  alone.
- **How should this sequence with #172?** It needs rebasing onto #184 either way. Consolidating first makes its config
  half a one-line change; not consolidating means it rebases and lands on its own. Either order works, but they should
  not run in parallel against the same 40-odd files.

## Before I start

@mxriverlynn happy to do this, including the trial, if you have no objections. Flagging rather than starting because it
touches every skill, and because step 1 corrects guidance you wrote, so you may have context on the "both forms"
wording that is not in the repo.

@kadams54 flagging you for #172. Nothing here blocks it and the Pi work stands on its own; the note is only that its
config half sits on a probe form #184 removed, so it needs a rebase regardless.


## Comments

**@mxriverlynn** (2026-09-11T16:36:50Z):

@taminomara would love to have you digging into this! the original report of skills failing because of the config loading, came from a coworker. the current version that copies the same load command everywhere "works" and was a good enough solution. for long term maintenance, i definitely want a better solution. i don't like having everything trying to load the config file when it's already loaded, but had not been able to dig further into this. 

are there any specific questions you want me to dig into or answer? 

