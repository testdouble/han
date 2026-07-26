# Bloat and Restatement Classification

Duplication sorts into two sizes.

**Big fish** — duplication whose unit is a _pattern or a section_, not a sentence: the same rule, control structure, or
block in several places, whether sibling items within one section (a roster of role briefs, a set of cases) or patterns
split across steps and files. A big-fish finding names the consolidation: the one place the rule should live, and the
references that replace the copies.

**Small fish** — local restatement in a single place: a rule re-explained a sentence or step later, filler,
negative-space narration. A small fish inside a big fish's span is rolled up into it, not listed again (region-scoped
subsumption); small fish outside any big fish stand.

Severity is driven by what the bloat _does_ — mislead, tax attention, or merely add a line — not by which pass surfaced
it.

## Warranted duplication is not a finding

Some repetition is deliberate and correct. Do not flag it.

- **A pointer that adds local context** — why the rule bites _here_, a scoping nuance the canonical source omits — is
  the authoritative-home pattern working, not duplication.
- **Explicit narrowing** — "apply steps 1 and 2 from X" when X has more steps — narrows X on purpose.
- **Non-co-resident dispatch fragments** — duplication across sub-agent briefs or prompt fragments a skill-local
  assembler routes one-per-agent, with the orchestrator loading only their paths. No runtime context holds two copies,
  so there is no attention tax; do not raise it as an attention-tax big fish. Drift between such fragments is still
  Critical. Fragments authored inline in one `SKILL.md` body do co-load every run, so they stay flagged.

## Consolidate to a reference or a script, not to a sub-skill

When Pass A recommends consolidating a big fish, the target is a `references/` file, a skill-local script, or a single
earlier step whose result the later steps reuse. Within-skill duplication that a reference or script would cleanly
absorb is a real big fish — flag it, unless no runtime context co-loads the copies (see Warranted duplication).

Do **not** recommend factoring shared logic — discovery lines, `!` injections, repeated instructions — out into a
separate sub-skill to satisfy DRY. `skill-composition.md` shows a data-fetch sub-skill is fragile (the `api_retry`
early-exit) and that duplicating a handful of lines _across skills_ is more reliable than sharing them through one. That
cross-skill duplication is the warranted kind, and it is out of scope for reviewing a single artifact; the reliability
argument does not extend to references or skill-local scripts, which have no such failure mode.

## Global (big-fish) findings — Pass A

- **Contradictory restatement (Critical)** — the same rule stated twice with materially different content, so a reader
  following the artifact literally cannot tell which governs.
- **A pattern repeated with drift (Critical)** — the same control structure expressed several times with parameters that
  differ enough that the reader cannot tell deliberate scoping from copy-paste drift. _Example:_ four retry policies
  across four steps, each worded differently for the same "a dispatch did not return" event.
- **A pattern or section duplicated without drift (Warning)** — the same rule, block, or example in several places that
  load into the same runtime context, or a body section that re-states a reference in full. Consolidate to one home and
  reference it. Warning, because co-resident copies tax attention on every run and every copy is a place to forget to
  update. _Example:_ a step's sibling bullets that each restate the same guard, or a body section repeating a
  `references/` rule in full. Copies that never share a runtime context are exempt (see Warranted duplication).

## Local (small-fish) findings — Pass B

- **Re-explaining a rule stated earlier (Warning)** — a step restates a constraint the preceding sentence or step
  already set, adding nothing. _Example:_ "Read the full file, because partial context misleads," immediately followed
  by "Remember: always read the whole file, since incomplete reads produce incomplete answers."
- **Duplication of a linked reference (Warning)** — the body re-states a rule a `references/` file already fully
  specifies, surfacing nothing the linked file omits.
- **Restatement of the obvious (Suggestion)** — a self-evident consequence a competent reader already infers ("since the
  file is now saved, the write is complete").
- **Filler transitions (Suggestion)** — "Now let's move on," "With that done, we can proceed" — connective tissue with
  no instructional content.
- **Back-referential meta-commentary (Suggestion)** — "as mentioned above," "as we discussed in Step 2," when the
  pointer adds no instruction the reader needs to act on.
- **Audience-mismatched reference (Suggestion)** — prose that orients a reader other than the one executing it: a
  dispatched sub-agent's brief describing the orchestrator's own logic, a comparison to a sibling skill, or design
  rationale that belongs in the design docs.
- **Negative-space filling (Suggestion)** — a sentence narrating what a step does _not_ do or what moved elsewhere:
  "this step never verifies X — that happens in step Y." Nothing in the step raised X, so the disclaimer answers a
  question no one asked; delete it.

## The heuristic the pass applies

For each candidate, first ask its **scope**: does the same thing live in several places or across steps (a big fish,
Pass A), or is it a single local line (a small fish, Pass B)? Then ask what it **does**: mislead (Critical), tax
attention or repeat a documented rule (Warning), or add one self-evident, filler, misplaced, or negative-space line
(Suggestion).

The reader-reaction test still applies: if a sentence makes a capable reader think "you just said that," "well, duh,"
"I've never seen that and don't need it," or "nothing raised that," it is bloat and cutting it loses no instruction.
