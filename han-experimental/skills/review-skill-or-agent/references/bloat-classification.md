# Bloat and Restatement Classification

Run the artifact twice, biggest fish first.

**Pass A — global (big fish).** Read the whole artifact and find duplication whose unit is a *pattern or a section*, not a sentence: the same rule, control structure, or block expressed in several places — whether those places are sibling items within one section (a roster of role briefs, a set of cases) or patterns spread across steps and files. This pass reads the whole artifact **even in a change review** — accumulated structural drift is invisible in a single diff, so the global pass is never scoped to the changed regions, and its change-scope findings are advisory. A big-fish finding names the consolidation: the one place the rule should live, and the references that replace the copies.

**Pass B — local (small fish).** Only in regions no big fish subsumes, find local restatement: a rule re-explained a sentence or step later, filler, negative-space narration. A local instance that falls inside a big fish's span is rolled up into that big fish, not listed again (region-scoped subsumption); local findings outside any big fish still stand.

The two passes differ by the **unit** of duplication, not by how much of the artifact it spans. Pass A's unit is a structural pattern — a template, a control structure, a section, a block; Pass B's is a local sentence. A repeated structural pattern is a Pass A finding whether its copies fill one section or the whole artifact; the span only sets how far its subsumption reaches, so there is no middle tier to add. Severity within either pass is driven by what the bloat *does* — mislead, tax attention, or merely add a line — not by which pass found it.

## Warranted duplication is not a finding

Some repetition is deliberate and correct. Do not flag it.

- **A pointer that adds local context** — why the rule bites *here*, a scoping nuance the canonical source omits — is the authoritative-home pattern working, not duplication.
- **Explicit narrowing** — "apply steps 1 and 2 from X" when X has more steps — narrows X on purpose.

## Consolidate to a reference or a script, not to a sub-skill

When Pass A recommends consolidating a big fish, the target is a `references/` file, a skill-local script, or a single earlier step whose result the later steps reuse. Within-skill duplication that a reference or script would cleanly absorb is a real big fish — flag it.

Do **not** recommend factoring shared logic — discovery lines, `!` injections, repeated instructions — out into a separate sub-skill to satisfy DRY. `skill-composition.md` shows a data-fetch sub-skill is fragile (the `api_retry` early-exit) and that duplicating a handful of lines *across skills* is more reliable than sharing them through one. That cross-skill duplication is the warranted kind, and it is out of scope for reviewing a single artifact; the reliability argument does not extend to references or skill-local scripts, which have no such failure mode.

## Global (big-fish) findings — Pass A

- **Contradictory restatement (Critical)** — the same rule stated twice with materially different content, so a reader following the artifact literally cannot tell which governs.
- **A pattern repeated with drift (Critical)** — the same control structure expressed several times with parameters that differ enough that the reader cannot tell deliberate scoping from copy-paste drift. *Example:* four retry policies across four steps, each worded differently for the same "a dispatch did not return" event.
- **A pattern or section duplicated without drift (Warning)** — the same rule, block, or example expressed in several places, or a body section that re-states a reference in full. Consolidate to one home and reference it. Warning, because it taxes attention on every run and every copy is a place to forget to update. *Example:* a roster of sibling role briefs where the owning ones repeat the same "ground against these files and cite the rule" shape — lift the shape into one shared instruction and let each brief keep only its distinctive scope.

## Local (small-fish) findings — Pass B

- **Re-explaining a rule stated earlier (Warning)** — a step restates a constraint the preceding sentence or step already set, adding nothing. *Example:* "Read the full file, because partial context misleads," immediately followed by "Remember: always read the whole file, since incomplete reads produce incomplete answers."
- **Duplication of a linked reference (Warning)** — the body re-states a rule a `references/` file already fully specifies, surfacing nothing the linked file omits.
- **Restatement of the obvious (Suggestion)** — a self-evident consequence a competent reader already infers ("since the file is now saved, the write is complete").
- **Filler transitions (Suggestion)** — "Now let's move on," "With that done, we can proceed" — connective tissue with no instructional content.
- **Back-referential meta-commentary (Suggestion)** — "as mentioned above," "as we discussed in Step 2," when the pointer adds no instruction the reader needs to act on.
- **Audience-mismatched reference (Suggestion)** — prose that orients a reader other than the one executing it: a dispatched sub-agent's brief describing the orchestrator's own logic, a comparison to a sibling skill, or design rationale that belongs in the design docs.
- **Negative-space filling (Suggestion)** — a sentence narrating what a step does *not* do or what moved elsewhere: "this step never verifies X — that happens in step Y." Nothing in the step raised X, so the disclaimer answers a question no one asked; delete it.

## The heuristic the pass applies

For each candidate, first ask its **scope**: does the same thing live in several places or across steps (a big fish, Pass A), or is it a single local line (a small fish, Pass B)? Then ask what it **does**: mislead (Critical), tax attention or repeat a documented rule (Warning), or add one self-evident, filler, misplaced, or negative-space line (Suggestion). Report big fish first; a small fish inside a big fish's span is rolled up, not repeated.

The reader-reaction test still applies: if a sentence makes a capable reader think "you just said that," "well, duh," "I've never seen that and don't need it," or "nothing raised that," it is bloat and cutting it loses no instruction. But when the same reaction fires in three places, that is one big fish, not three small ones.
