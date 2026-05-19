# Investigation: Does skills-calling-skills work, and how should it be done?

**Status:** Resolved — closes OI-3 of
[`../feature-specification.md`](../feature-specification.md) and the V3
housekeeping note of [`../recommendation.md`](../recommendation.md).
**Date:** 2026-05-19
**Method:** `/investigate` — 3 parallel `evidence-based-investigator` agents +
`claude-code-guide` (authoritative), then an `adversarial-validator` pass.

## Problem Statement

- **Symptom:** Han's own authoring guidance contradicts itself on whether a
  skill may call another skill via the Skill tool.
  `skill-composition.md` states a blanket prohibition; `skill-decomposition.md`
  prescribes the Skill tool for orchestration and cites `gh-pr-review →
  code-review` as the model; `gh-pr-review` ships using it.
- **Question:** Does skills-calling-skills work as expected? What are the
  caveats and failure modes? What is the pattern that works consistently?
- **Why it matters:** Flagged as V3 in the `/research` recommendation and as
  OI-3 in the `/research` spec — neither contradicting doc can be cited as
  authoritative for new skill design until this is resolved.
- **Impact:** Every future skill that might compose with another faces an
  ambiguous authoritative source.

## Evidence Summary

- **E1** — `docs/guidance/skill-building-guidance/skill-composition.md:1-23`:
  blanket prohibition, "Skills should not call other skills via the Skill
  tool... (both data-fetch and orchestration patterns)... too inconsistent and
  unreliable." Recommends inline discovery / duplication.
- **E2** — `skill-decomposition.md:59-82`: the opposite — "Use the `Skill` tool
  to compose skills together"; orchestration (`gh-pr-review → code-review`)
  "Works inline"; includes a code + `allowed-tools` example; checklist item 3
  affirmative. Points readers to `skill-composition.md` "for the full pattern"
  (which says the opposite).
- **E3** — `writing-effective-instructions.md:99-124`: scopes the early-exit
  failure to **data-fetch only** and states explicitly: "Orchestration
  sub-skills (where the called skill drives the remaining output) are
  unaffected." Names the mechanism (`api_retry` anchoring after `context:
  fork`), the failing pair (`code-review → read-project-config`, 7 skills), and
  two failed fix commits; concludes `context: fork` + continuation wording is
  "necessary but not sufficient."
- **E4** — git history: all the guidance was authored in the **same** initial
  extraction commit `8c721d1` (2026-05-11); later commits were voice/format
  only; no commit message or ADR records a reconciliation; neither doc is
  literally "newer."
- **E5** — `plugin/skills/gh-pr-review/SKILL.md:11,35`: the **only** one of 18
  skills with `Skill` in `allowed-tools`; invokes `/code-review` with prose
  only ("proceed immediately to Step 3 — do not stop here"), no
  retry/verify/fallback; Steps 3–5 depend on `/code-review`'s in-context
  output.
- **E6** — `plugin/skills/code-review/SKILL.md:6,195`: no `Skill` in
  `allowed-tools`; dispatches only via `Agent`; output lives in conversation
  context, not a file the caller re-reads.
- **E7** — `docs/guidance/plugin-entity-taxonomy.md:41` ("skills... may invoke
  other skills for fixed sub-steps") and `troubleshooting.md:333-366` (still
  recommends `context: fork` as the fix for "Sub-Skill Output Lost") are a
  third and fourth contradicting statement; `graceful-degradation.md:86`
  cross-references `skill-composition.md` with misleading anchor text — a
  fifth.
- **E8** — no RFC/ADR/CHANGELOG records whether `gh-pr-review`'s sub-skill call
  is intentional, grandfathered, or pending migration. The
  `code-review-guardrails` plan treats `gh-pr-review` as a **working**
  downstream consumer that "inherits transitively, no edits required."
- **E9 (authoritative — claude-code-guide)** — sub-skill runs in the same
  context/turn; control does not reliably return to the parent; forked
  data-fetch → early exit via `api_retry`; the recommended consistent patterns
  are **inline discovery** (config/data), **Agent-tool dispatch** (heavy
  reusable work), and **duplication** (minimal reuse); "do not invoke a skill
  that is already running" is a loop guard, not an early-exit fix; `Skill` must
  be in `allowed-tools` to call a skill.

## Root Cause Analysis

**The contradiction is real and originates from a single un-reconciled
extraction commit; the evidence is asymmetric — the data-fetch failure is
well-evidenced, the orchestration failure is an unsupported assertion — and the
question that triggered this (does `/research` need to worry about it) has a
robust answer independent of that unresolved debate.**

All six contradicting statements were authored in commit `8c721d1` and never
reconciled (E4). The data-fetch sub-skill failure is concrete and corroborated
by the authoritative source (E3, E9): forked data-fetch sub-skills cause the
parent to early-exit. The orchestration ban, by contrast, is one unsupported
sentence in `skill-composition.md` (E1) that is directly contradicted by an
equally-unsupported sentence in `writing-effective-instructions.md` (E3,
"unaffected") and by `skill-decomposition.md` (E2, "works inline"), with no
named incident anywhere in the repo and a production skill (`gh-pr-review`)
using the pattern with no documented failure (E5, E8). The de-facto pattern
across 17 of 18 skills is Agent-tool dispatch and inline discovery (E6, E9) —
the pattern with no reliability question hanging over it.

## Resolution

### What the evidence actually supports

1. **Data-fetch sub-skills (one skill calling another to fetch a value):
   unreliable. Do not use them.** Well-evidenced (E3, E9). The consistent
   replacement is **inline discovery** — context injection + `Read` +
   conventional defaults.

2. **Orchestration sub-skills (one skill delegating a whole task to another,
   e.g. `gh-pr-review → code-review`): genuinely underdetermined.** No evidence
   it fails; no evidence it is reliable; the docs contradict themselves and the
   one production instance has no recorded failure (E5, E8). It is **not**
   established that orchestration is broken.

3. **The recommended consistent pattern for new skills is Agent-tool dispatch
   + inline discovery, never Skill-tool sub-calls.** Not because orchestration
   is proven broken, but because Agent dispatch is the pattern 17/18 skills
   already use, it has no open reliability question, and it sidesteps the
   contradiction entirely (E6, E9). When a skill needs another skill's heavy
   logic, extract that logic into an Agent and dispatch via the `Agent` tool;
   for config/data, discover inline; for minimal reuse, duplicate the small
   logic.

### Answer to OI-3 (the reason this was investigated)

`/research`, as specified, **invokes no skills**. It dispatches agents (the new
research agent, `codebase-explorer`, `adversarial-validator`) via the `Agent`
tool, and "routing to a sibling skill" means *naming* the sibling in its
output, not *calling* it via the Skill tool (validation V8, confirmed against
the spec's Alternate Flows and Coordinations). The `/investigate` analog is
likewise Agent-only. **OI-3 therefore poses essentially zero risk to
`/research`: the spec already complies with the safe, recommended pattern.**
The single enforcement point at build time is the eventual SKILL.md
`allowed-tools` list — it must not include `Skill`.

### The broader guidance contradiction (separate Han housekeeping, not part of this build)

The repo-wide contradiction across `skill-composition.md`,
`skill-decomposition.md`, `writing-effective-instructions.md`,
`troubleshooting.md`, `plugin-entity-taxonomy.md`, and
`graceful-degradation.md` is real and unresolved. Until it is reconciled, **no
single one of these may be cited as authoritative for new skill design.** The
recommended reconciliation is evidence-led and should be recorded as an ADR:

- Keep and strengthen the **data-fetch** ban (well-evidenced).
- For **orchestration**, the maintainers must either produce a named
  reproducible incident to sustain the ban, or scope the docs to "orchestration
  sub-skill calls are discouraged in favor of Agent-tool dispatch but are not
  demonstrated to fail" — rather than asserting a blanket ban the evidence does
  not support.
- Correct the contradicting statements in all six files, and decide explicitly
  whether `gh-pr-review` is a sanctioned exception or a migration target
  (record the decision; the absence of a recorded decision is itself a finding,
  E8).

This reconciliation is tracked as a Han maintenance item; it does **not** block
the `/research` build.

## Validation Findings

An `adversarial-validator` attacked the evidence, the root cause, and the
resolution. It returned **Low confidence in the original naive framing** ("the
blanket ban is authoritative") and forced the adjustments below.

- **V1 (sustained):** The orchestration-failure claim in `skill-composition.md`
  has no named incident/mechanism/fix-attempt; the data-fetch claim has all
  three. The two are not equally evidenced. → Resolution adjusted: orchestration
  is "underdetermined," not "banned."
- **V2 (sustained):** The cited fix commits (`bdd68fe`, `69c416b`) and other
  cited commits do not exist in this repo (history dropped at extraction
  `8c721d1`). The corroboration chain is documentation-self-referential. →
  Recorded as a Remaining Risk; the data-fetch mechanism still stands on the
  authoritative source (E9), not the unverifiable commits.
- **V3 (sustained, worse than stated):** `troubleshooting.md` actively
  recommends `context: fork` — the fix `writing-effective-instructions.md` says
  is insufficient. Active hazard, added to the repair list.
- **V4 (sustained):** The "data-fetch banned / orchestration fine" reading is
  internally coherent and was not ruled out. The original resolution had
  "imported the data-fetch evidence to launder the orchestration claim." →
  Resolution no longer asserts orchestration is broken.
- **V5 (sustained):** `gh-pr-review`'s "deprecated pattern" label was an
  inference, not a finding; the guardrails plan treats it as working. →
  Resolution no longer recommends migrating it as if it has a known bug; the
  keep-vs-migrate call is handed to maintainers.
- **V6 (addressed):** The target artifact did not exist — it is this file.
- **V7 (sustained):** Repair scope was incomplete; `graceful-degradation.md:86`
  added to the list of files to reconcile.
- **V8 (confirms resolution):** `/research` uses named routing, not Skill-tool
  calls; the OI-3 "~zero risk to /research" conclusion holds. Caveat recorded:
  verify against the final SKILL.md `allowed-tools` at implementation.

### Adjustments Made

- Dropped the "blanket ban is authoritative" framing (V1, V4).
- Split the conclusion: data-fetch = evidenced ban; orchestration =
  underdetermined; recommended pattern = Agent dispatch for *positive* reasons,
  not because orchestration is proven broken (V1, V4, V5).
- Reframed the `gh-pr-review` recommendation from "migrate the deprecated
  pattern" to "maintainers decide and record" (V5).
- Expanded the repair list to six files including `troubleshooting.md` and
  `graceful-degradation.md` (V3, V7).
- Recorded the unverifiable-commit-history weakness as a standing risk (V2).
- Kept the OI-3 / `/research` answer, now explicitly backed by V8.

## Confidence Assessment and Remaining Risks

- **Confidence:** **High** on the part that closes OI-3 (the `/research`
  spec already uses the safe pattern; it calls no skills — V8). **Medium** on
  the data-fetch ban (mechanism corroborated by the authoritative source, but
  the in-repo commit evidence is unverifiable — V2). **Low** on any claim that
  orchestration sub-skills are broken — the evidence does not support it (V1,
  V4, V5).
- **Remaining risks:**
  1. The orchestration evidence gap is unresolved; the safe recommendation
     stands on "Agent dispatch is the established, question-free pattern," not
     on proof that orchestration fails.
  2. All commit-hash evidence in the guidance docs is from a pre-extraction
     repository and cannot be inspected here.
  3. The six-file guidance contradiction remains live until the maintainers
     reconcile it via ADR; it is a known trap for *other* new skills (not
     `/research`) in the meantime.
  4. OI-3 closure for `/research` must still be re-verified against the final
     SKILL.md `allowed-tools` when the skill is implemented (must not contain
     `Skill`).

## Final Summary

- **Root cause:** Six guidance statements authored in one un-reconciled
  extraction commit contradict each other; the data-fetch failure is
  well-evidenced while the orchestration ban is an unsupported assertion.
- **Resolution:** Data-fetch sub-skills are unreliable (use inline discovery);
  orchestration is underdetermined; the recommended consistent pattern for new
  skills is Agent-tool dispatch + inline discovery, never Skill-tool sub-calls.
- **Why correct:** 17/18 skills already use Agent dispatch with no reliability
  question (E6, E9); the authoritative source confirms the data-fetch failure
  and the recommended alternatives (E9).
- **Validation outcome:** Adversarial validation overturned the naive
  "blanket-ban" framing (V1, V4, V5) but confirmed the OI-3 answer (V8): the
  recommendation was narrowed to what the evidence supports.
- **Remaining risks:** The orchestration question and the six-file guidance
  contradiction stay open as a Han maintenance item (ADR-worthy); they do not
  block `/research`, which complies with the safe pattern.
