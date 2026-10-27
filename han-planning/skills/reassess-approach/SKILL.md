---
name: "reassess-approach"
description: >
  Asks whether the approach a plan or a piece of code commits to is still the right one, in a fresh context, and returns
  structurally different alternatives, always including stopping the work and continuing as is, each with evidence and
  one recommendation. Use when a plan or a piece of code has absorbed round after round of review findings without
  converging, when you want to step back and question the approach, the tool, or the shape before spending another
  round, or when you wonder whether the work is worth doing at all. iterative-plan-review and plan-implementation invoke
  it when a multi-round run reaches its cap without converging. Produces an options report and changes nothing. Does
  not review a plan round by round — use iterative-plan-review. Does not plan the restructure an accepted alternative
  calls for — use plan-a-change. Does not survey options from the open web — use research. Does not assess a module's
  architecture and stop at findings — use architectural-analysis.
argument-hint: "[plan file or code path] [optional: findings file path] [optional: why you are asking]"
allowed-tools:
  Read, Write, Glob, Grep, Agent, Bash(find *), Bash(mkdir *),
  Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

## Operating Principles

- **A fresh context is the mechanism, not a nicety.** The critic receives the subject, the recorded findings, the reason
  it is being asked, and the project's conventions, and nothing else. Never pass it the calling run's own assessment,
  the conversation's defense of the current approach, or a preferred answer, BECAUSE the context that built an artifact
  is anchored on it, and an anchored reviewer polishes where it should question.
- **Options are structurally different, or they are not options.** A different mechanism, a different shape, a smaller
  slice, or none at all. Two candidates that differ only in parameters, naming, or ordering are one option, and a list of
  nearby variants is the failure this skill exists to interrupt.
- **"Stop doing this" and "continue as is" are always on the list.** The question is whether the work still earns its
  cost, so both standing options carry the same fields as every other option, BECAUSE a list without them is a list of
  ways to keep going.
- **The recorded findings are the evidence.** Each option says which recorded findings it would make moot and which it
  leaves open, and what it adds or removes in owned code paths or plan items. Repeated rework on one mechanism is the
  "existing structure demonstrably impedes the change" case the YAGNI rule names as evidence, so apply
  [../../references/yagni-rule.md](../../references/yagni-rule.md) to each option on that footing: a library or a
  different shape that removes more owned code paths than it adds is the simpler version.
- **This skill proposes and changes nothing.** It writes one report and edits no plan, no code, and no companion file.
  The choice belongs to the person, and a loop that invoked this skill resumes only on their answer.
- **One agent.** One critic dispatch produces the options. Do not add a reviewer of the critic, and do not dispatch an
  investigator to pre-digest the subject: the critic reads it directly. A second dispatch is allowed only as the single
  relaunch Step 3 describes.

# Reassess the Approach

## Step 1: Establish the Subject, the Findings, and the Reason

Determine how the skill was reached and what it is looking at.

1. **Mode.** When a calling skill passed a plan path, a findings path, a reason, and an output location, you are in
   **hand-off mode**: take those inputs as given and ask nothing. Otherwise you are in **hand-invoked mode** and resolve
   each input below from the argument and the conversation.
2. **Subject.** A plan file, or a code path (a file or a directory). Read the plan in full, or list the code path and
   read its entry points, so the next steps can name what the current approach commits to. If no subject can be
   resolved, ask for one in a single question and end the turn.
3. **Findings.** Use the findings file passed in, or look for one beside a plan subject: `artifacts/review-findings.md`,
   `artifacts/implementation-iteration-history.md`, or their legacy root-level counterparts. Beside a code subject, look
   for a `code-review-*.md` report in the documentation root. When nothing is on disk, take the findings the
   conversation already holds. When there are none at all, record that and continue: the critic then works from the
   subject alone, and the report says so.
4. **Reason.** One line stating why the question is being asked now: the cap a loop reached and what its last round
   produced, or the person's own words. In hand-invoked mode with no stated reason, record "asked by hand, no stall
   recorded".
5. **Output location.** For a plan subject, the report lands in that plan's `artifacts/` folder as
   `approach-reassessment-{n}.md`, with `{n}` continuing from any existing reassessment files there. For a code subject,
   resolve the folder per [config-rule.md](../../references/config-rule.md): a folder the user named wins; otherwise the
   `output-directory` setting; otherwise a three-to-five-word kebab-case folder under the documentation root discovered
   from CLAUDE.md's `## Project Discovery` section, `project-discovery.md`, or a Glob fallback (`docs/plans/`, `docs/`).
   In hand-invoked mode on a code subject, confirm the folder name before writing.

## Step 2: Resolve Project Conventions

Read CLAUDE.md's `## Project Discovery` section for the coding-standards and ADR directories, fall back to
`project-discovery.md`, then to a Glob over `docs/adr/` and `docs/coding-standards/`. Collect the paths of the standards
and decisions that bear on the subject, so the critic's options respect what the project has already decided rather
than rediscovering it.

## Step 3: Dispatch the Critic

Launch `han-core:software-architect` with one `Agent` call. Pass it only:

- The subject: the plan file path, or the code path, with the instruction to read it directly.
- The findings file path (or the findings gathered in Step 1, verbatim), labelled as the record the options must
  account for.
- The reason line from Step 1.
- The convention paths from Step 2 and the YAGNI rule at `${CLAUDE_PLUGIN_ROOT}/references/yagni-rule.md`.
- The report template at [references/approach-reassessment-template.md](./references/approach-reassessment-template.md),
  as the shape of its answer.

Its brief must say:

1. **Assume the current approach is the wrong one** until the evidence says otherwise. Restate in one paragraph what the
   subject commits to today and which recorded findings it has absorbed, by ID.
2. **Produce one to three alternatives**, each structurally different from the current approach and from each other: a
   different mechanism, a different shape, or a smaller slice. Each one is a thing someone could build, not a strawman.
3. **Always add two standing options**, "stop doing this" and "continue as is", carrying the same fields as the rest.
4. **For every option**, give the evidence for it, the recorded findings it would make moot and the ones it leaves open,
   the owned code paths or plan items it adds and removes, the recorded decisions or standards it would reopen, and what
   to run next if it is chosen (`plan-a-change` for a restructure, `plan-a-feature` to re-specify, `refactor` for a
   behavior-preserving substitution, `tdd` for a behavior change, or nothing).
5. **End with one recommendation** and the reasoning that selects it, plus a `Deferred (YAGNI)` list for anything
   considered and set aside with its reopening trigger.

Do not pass the calling skill's own reading of the findings, any earlier recommendation, or the conversation's reasons
for the current approach.

**Check what comes back before using it.** An option that differs from the current approach only in parameters, naming,
or ordering is not an alternative, and a return without both standing options is incomplete. In either case relaunch the
critic once with the missing requirement restated. If the second return still carries no structurally different
alternative, do not invent one: the report records that none was produced, with the critic's stated reason, and presents
the two standing options alone. If the agent fails or returns nothing usable twice, stop and tell the person the critic
could not be run, naming what was passed to it.

## Step 4: Write the Report

Invoke `han-communication:readability-guidance` to source the shared readability standard, then write the report at the
Step 1 location from [references/approach-reassessment-template.md](./references/approach-reassessment-template.md).
Hold the named audience: the person who decides, who may not have read the plan or the code. Lead with the
recommendation, keep one option per section, and put the technical detail under each option's prose rather than in it.
Preserve every finding ID and every path the critic cited. Run the standard's self-check over the prose before moving on.

The report is the only file this skill writes. Create the `artifacts/` folder when it is missing and never edit the
subject, the findings file, or any other companion file.

## Step 5: Hand the Decision Back

**In hand-off mode**, return the report path and the recommendation line to the calling skill and stop. The caller
presents the options through its own question channel and resumes only on the person's answer.

**In hand-invoked mode**, present the decision per
[../../references/operator-escalation-rule.md](../../references/operator-escalation-rule.md): one question, opening with
the consequence of staying on the current approach in plain language, then the options as named candidates with the
recommendation marked, then the report path and the technical references below. End the turn. A reply of "keep going"
or "continue as is" is a complete answer. Do not implement, plan, or re-run anything on the person's behalf; when they
pick an option, name the skill the report says to run next and let them run it.
