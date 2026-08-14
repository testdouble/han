---
name: pairing
description: >
  Build work collaboratively in reviewable pieces, handing each piece back for review before starting the next, so the
  person stays in the lead and steers while the work happens instead of reviewing a finished result. Use when someone
  says to pair with them on something, asks to collaborate rather than direct, wants to review as it goes, or wants to
  guide the work piece by piece — on code, on a design decision, or on writing. For a test-first build it runs tdd, for
  restructuring it runs refactor, for an interface contract it runs design-an-api, and for plan work it runs
  iterative-plan-review or plan-implementation, each collaboratively; invoke any of those directly instead to run it
  straight through without pausing. Does not pace someone through code that already exists and builds nothing — use
  code-walkthrough. Does not explain, summarize, or research something instead of producing it — use code-overview or
  research.
allowed-tools: Read, Write, Edit, Glob, Grep, Skill, Bash(find *)
argument-hint: "[what to pair on]"
---

## Project Context

- personal config directory: !`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

## The contract this skill runs on

Read [collaborative-stop-rule.md](../../references/collaborative-stop-rule.md) before Step 3. It defines what a stop
presents, when the pre-build ask fires, what makes a choice expensive to walk back, and what to do with the answer. The
skills this one hands work to follow the same file, which is what makes a stop feel the same whoever performed it.

Two constraints from that file govern every step below and are repeated here because they are the ones most easily lost:

- **The pacing is the deliverable.** Ending the turn at each stop is the product, not an interruption in it. Never
  continue past a stop to be helpful.
- **A stop hands over something to check, never a case for the work.** Lead with what the person can verify. The
  reasoning goes last or goes unsaid until asked, BECAUSE a fluent explanation raises agreement without raising
  scrutiny, which is the failure this whole loop exists to prevent.

# Pairing

## Step 1: Resolve the Record Location

Resolve where the running feedback record will be written, using the output base directory from the configuration
probed above. Absent any configuration, write it beside the work under `.han/pairing/`.

Name the file for this run so a second run in the same repository does not overwrite the first. State the path to the
person in Step 3's plan, in one clause, BECAUSE a record they cannot find is not a record.

Read the file first if it already exists. A run resuming after an interrupted session inherits the record rather than
starting a new one.

## Step 2: Sort the Work

Apply this test to the request in order, and stop at the first match:

1. Does a skill carrying the collaborative flag cover this work? Then it is **skill-backed**. The flagged skills are
   `tdd` for a test-first build, `refactor` for restructuring, `design-an-api` for an interface contract,
   `iterative-plan-review` for sharpening a plan, and `plan-implementation` for planning a build.
2. Does the work produce a choice among options that commits the person to something? Then it is **decision work**.
3. Does the work produce prose someone will read? Then it is **prose work**.
4. Otherwise it is **open-ended**, and Step 3's plan supplies the boundaries with no rule behind them.

The order is the tie-break. A request matching more than one kind sorts as the earliest match, so drafting a decision
record sorts as decision work rather than prose work.

**Never guess the discipline for skill-backed work.** A request to build something that does not say whether to drive
it from tests, restructure what is there, or sketch a shape first is answered by proposing an approach in Step 3, never
by picking one silently. A single request may span more than one approach.

**When the request is too vague to sort**, ask once. Name what was ambiguous and offer candidate readings. If the answer
still does not settle it, propose a plan against the most likely reading and say that is what you did. Never sort a
request you could not read.

**When the request asks to understand something rather than produce something**, this skill is the wrong one. Say so and
name where it goes: `code-walkthrough` for paced explanation of existing code, `code-overview` for a written overview,
`research` for an open question. Do not sort it as open-ended and propose a plan to build things.

## Step 3: Propose the Plan

Before any work starts, present a short plan. It names:

- Which kind the work sorted into. **Always state this** BECAUSE the sort determines every boundary downstream, and it
  is the one part of the plan the person cannot correct if they cannot see it.
- The pieces to be built, and the reason for each boundary.
- Which pieces carry a choice that is expensive to walk back, applying the test in the stop rule. Naming them here is
  what makes that call contestable while contesting it is still cheap.
- Where the feedback record lives.

What counts as one piece depends on the kind of work:

| Kind of work | One piece is                                                                           |
| ------------ | -------------------------------------------------------------------------------------- |
| Skill-backed | Whatever that skill already treats as one unit                                         |
| Decision     | One decision, with its context, the options weighed, and what it commits the person to |
| Prose        | One rung of a fidelity ladder: the shape, then a rough draft, then the language        |
| Open-ended   | Whatever this plan names                                                               |

**For prose, scale the ladder to the size of the work.** Short work climbs the ladder once, whole. For longer work,
agree the shape for the whole artifact first, then climb the remaining rungs section by section, naming the sections in
this plan so they can be redirected. Sectioning only the later rungs keeps structural feedback ahead of surface
feedback, which is the ordering the ladder exists for.

**For skill-backed work the plan names the backing skill, the unit it stops at, and the reason — not the list of units.**
That skill builds its own list partway through its own run, so the list does not exist yet. Surface it at the first stop,
where it can still be redirected.

**When the plan sequences more than one backing skill**, order them so each skill's own preconditions hold when its turn
arrives. `refactor` will not run alongside an unfinished test-driven loop, so a plan that sequences both closes the first
before starting the second.

Then wait. The person accepts the plan, changes it, or replaces it.

## Step 4: Run the Loop

Repeat until the plan is finished or the person ends it.

1. **If the plan marked this piece expensive to walk back, ask first.** Follow the ask protocol in the stop rule: name
   the dimension the choice turns on, offer no candidate answers, and accept a declined answer as a complete one. The ask
   comes before the build, never after.

2. **Build one piece.**

   For skill-backed work, invoke the backing skill with the collaborative argument set, and forward the person's request
   and any constraints through unchanged. That skill runs its own job and stops at the boundary it already has.
   **After the invocation returns, continue this loop explicitly** BECAUSE the moment after a sub-skill call is where an
   orchestration most often stops and treats the sub-skill's output as its final answer.

   When a backing skill is not available, name it and offer the choice between the open-ended path and installing the
   plugin that carries it. **Never substitute silently** — hand-rolling a refactoring skips the passing-test gate that
   skill exists to enforce.

   For every other kind, build the piece yourself.

3. **Present the stop**, in the shape the stop rule specifies: position in the plan, what was built, what can be
   checked, what changed, and one line saying the reasoning is available for the asking.

4. **End the turn.** Nothing further is built until the person responds.

## Step 5: Act on the Response

Write the response into the record before acting on it. When a recorded entry shapes this piece, name which entry it
was.

Then route by what the feedback touches, per the stop rule:

- **The piece in hand.** Fix it within that piece and show it again, naming the correction and what it touched. That
  re-show is a stop, so return to Step 4's fourth instruction and wait. Do not return to the pre-build ask; this piece is
  already built.
- **What comes next.** Carry it into the next piece and return to the top of Step 4.
- **Work outside the piece in hand.** Name that reading before acting on it, then offer three ways out: accept a revised
  plan, change it, or decline the reopening so the feedback is recorded as scoped to later work and the agreed plan
  continues.

**A question holds the person's place; it never advances the work.** Answer it and stop again at the same place.

**When the person asks for more than one piece at a time**, honor it as asked, present the pieces together, and return
to the normal pace at the following stop without being asked to.

**When the person says to finish without stopping**, acknowledge it in the same turn and name what will now go
unreviewed, then continue from the current plan and report at the end.

## Step 6: Close

Report what was built, what the person's feedback changed, anything the plan named but did not reach, the state of any
work a backing skill left mid-cycle, and where the feedback record was written.

Ending is the person's call throughout. Nothing here computes a stopping point, BECAUSE work being built produces no
countable signal to compute over.
