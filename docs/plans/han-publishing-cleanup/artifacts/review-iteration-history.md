# Review Iteration History: Han Publishing Cleanup

Spec: [../feature-specification.md](../feature-specification.md) · Findings:
[review-findings.md](review-findings.md) · Decisions: [decision-log.md](decision-log.md) · Technical notes:
[feature-technical-notes.md](feature-technical-notes.md)

## R1

**Mode:** team

**Spec-aware mode:** engaged. Detected by filename (`feature-specification.md`) and confirmed by the canonical headings.
Roster excluded the mechanic-level specialists per the spec-stage rules; every agent received the behavioral-level
brief, the YAGNI brief, and the evidence brief.

**Size:** large — the work spans the release process, the pull-request pipeline, both marketplace manifests, three
plugin manifests, the work-items publisher, and six or more documents. Round cap 3, team cap 5.

**Specialists engaged:** `junior-developer`, `adversarial-validator`, `evidence-based-investigator`, `devops-engineer`,
`edge-case-explorer`. All five returned output.

`evidence-based-investigator` was included over the codebase-claims heuristic's literal reading: the spec body contains
no file paths at all, being deliberately channel-neutral, but its entire factual foundation is repository-state claims
expressed in neutral vocabulary. That judgment paid — it refuted two claims the spec asserted as settled.

**Findings raised:** F28, F29, F30, F31, F32, F33, F34, F35, F36, F37, F38, F39, F40, F41 (major); F42, F43 (minor).
Numbering continues from [team-findings.md](team-findings.md), which reached F27.

**Convergence.** Three agents independently reached F28 (the check cannot block) from different angles: the
junior-developer by asking what enforces the guarantee, the devops-engineer by auditing the enforcement surface, and
the evidence-based-investigator by trying to close Open item 3. Convergence from three unrelated starting points on a
claim the prior round had certified is why it is treated as settled rather than plausible.

**Disagreement resolved.** `evidence-based-investigator` and `adversarial-validator` both refuted "roughly twenty
releases" but returned different counts — 11 and 14. Resolved to **11** by direct re-verification rather than by
preferring an agent: the 14 came from counting tags *dated* after the codex records were created, and the three extra
tags (`v3.3.1`, `v3.4.0`, `v3.4.1`) do not contain the creating commit, having been cut from branches without the codex
scaffolding. Ancestry is the defensible test. Recorded on F32.

**Surfaced to the user.** Four findings required judgment only the plan's author could make and were surfaced with
impact, trade-offs, and a recommendation rather than resolved silently:

- F30 — does the repaired release create missing membership, or only detect it? **User chose creation**, over the
  recommendation of detection-only. This is the larger capability and forced a new decision (D31) on what version a
  created record carries.
- F28 — own the enforcement, or state the guarantee honestly per surface? **User chose the honest downgrade** (the
  recommendation). Open item 3 converts from an unknown to an unmade decision.
- F31 — delete the third untrue declaration, reopen the deferred checker, or leave it out of scope? **User chose
  deletion** (the recommendation), without reopening the checker.
- F29 — close the release-freeze window structurally, by precondition, or by weakening the gate? **User chose the
  structural fix** (the recommendation): steps 3 and 4 become one unit.

**Changed in plan:** Channels and targets; Outcome; Actors and triggers; Primary flow (binding constraints, Step 1,
Step 3, Step 4, Step 5, Step 6, Step 7); Alternate flows and states; Edge cases and failure modes; Coordinations; User
interactions; Out of scope; Deferred (YAGNI); Open items; Summary; Review History (new).

**Changed in decision log:** D31, D32, D33, D34, D35 added. Seven existing decisions corrected:

- **D6** — its exemption rationale ("a plugin published on one channel has nothing to disagree with") was factually
  wrong; the bundle publishes a version in two records. Exemption split.
- **D8** — its repoint target was the plugin that turned out to carry the third untrue declaration. Moved to
  `han-atlassian`, verified to be both surviving and true.
- **D13** — two declarations became three. Heading left intact so cross-references stay stable.
- **D22** — "dissolves the coupling" overclaimed; step 1's own file creation obliges a bump.
- **D25** — "the sweep came back clean" was false; it had only checked already-suspected plugins.
- **D26** — scoped to universal claims; its remedy did not survive contact with an irregular graph.
- **D29** — evidence rewritten; the cited rename precedent undercut itself, so the behavior now stands on being free.

**Changed in tech-notes:** T2 added — a pull-request check blocks only where a required status check demands it.
Load-bearing (a spec commitment rested on it) and not discoverable from the code repository, since it lives in the
hosting platform's settings rather than in any file here. That is precisely why the gap survived: the repository shows
the trigger, and the trigger looks like enforcement.

**Stability assessment:** not stable. The round produced 14 major findings, four of which changed behavioral
commitments and two of which falsified foundational claims the prior round had accepted. That is far past the stop rule
(≤2 new findings and zero major). The prior pass was strong — nothing smuggled back into scope, no YAGNI candidate
missed, and its own three rejected findings were correctly rejected — so the volume here reflects that the review
surface moved outward to claims about the world (live platform configuration, release-skill capability, git ancestry)
rather than that the earlier work was weak.

**Next step:** run R2. The concentration of R1's findings is instructive: the errors clustered where the spec asserted
facts about systems outside its own prose — what the release skill can do, what the platform enforces, how many
releases had run. R2 should verify that R1's own resolutions hold, and specifically stress the newly added D31, whose
creation capability is the largest untested commitment in the spec and was chosen against the recommendation.

## R2

**Mode:** team

**Spec-aware mode:** engaged. Roster unchanged from R1 and still excludes the mechanic-level specialists per the
spec-stage rules; every agent received the behavioral-level brief, the YAGNI brief, and the evidence brief, plus R1's
findings so nothing already resolved was re-raised.

**Size:** large — unchanged. Round cap 3, team cap 5. This is round 2.

**Specialists engaged:** `junior-developer`, `adversarial-validator`, `evidence-based-investigator`, `devops-engineer`,
`edge-case-explorer`. All five returned output. Two of them (`devops-engineer`, `adversarial-validator`) additionally
returned a second, independently-run pass, which is treated as corroboration rather than as extra findings — where the
two passes agreed, the finding is recorded as convergent; where they disagreed, the disagreement is recorded and
resolved on evidence (see F66).

**Findings raised:** F44, F45, F46, F47, F48, F49, F50, F51, F52, F54, F55, F56, F58, F59, F61, F63, F64 (major); F53,
F57, F60, F62 (minor); F65, F66 (raised and rejected). Numbering continues from R1, which reached F43.

**Convergence.** The round's findings cluster almost entirely on **D31** — the creation capability the user chose in R1
against the reviewer's recommendation, and the one R1's own next-step note flagged as the largest untested commitment.
Five specialists independently found D31's "there is no plugin for which the phrase is undefined" false for the exact
plugin shape D19 spends a rejected alternative keeping alive (F48). Three found that the bundle's exception is written
in verbs that predate creation (F50). Three found the gate's approval anchor names a prompt that is off by default
(F51). Three found the gate-stop recovery does not account for the release's own writes (F54). Three separate greps for
surviving blocking language found the same two sentences and no others (F61). Convergence at this density on one
decision is the signal that D31 was under-specified rather than wrong.

**The round's central finding is a collision between two R1 resolutions.** F29 (steps 3+4 become one unit) and F30 (the
release creates rather than detects) were decided in the same round and never checked against each other. F30 gave the
release the ability to repair; F29's entire justification was a release freeze that only a non-repairing gate produces.
The junior-developer reached it from the spec's own three enumerations of "gaps creation cannot close", all of which
omit version disagreement while a sentence ten lines away claims the gate is live against nine of them; the
devops-engineer reached it from the gate's placement, observing that every gap the gate can still fire on is
pre-existing repository state rather than anything the release wrote. Recorded as F44.

**Disagreement resolved.** The two `adversarial-validator` passes split on whether `han-atlassian`'s `han-communication`
declaration is a **fourth** untrue dependency. Both established the same facts — `han-atlassian` never names it, and its
wrapped skills invoke it one layer down — and differed on the verdict. Resolved on evidence rather than by preferring an
agent: `README.md:84-85` documents the declaration's purpose outright, and `evidence-based-investigator` (C4, C5)
independently confirmed the pattern is applied consistently across the suite. The declaration is real. What was missing
was the stated test distinguishing it from `han-linear`'s, which is recorded as F62 rather than as a deletion. Step 5
remains three. Recorded as F66 (rejected).

**Surfaced to the user.** Three findings required judgment only the plan's author could make and were surfaced with
impact, trade-offs, and a recommendation:

- F44 — does a release overwrite a stale version record for a plugin it did not bump? **User chose yes**, and to restate
  the unit. Steps 3 and 4 revert to an ordering, which is what D18 always said.
- F46 — what does a created record contain, given that channel two's record carries authored prose and its listing entry
  carries an installation policy? **User chose to narrow D31** (the recommendation): the release creates what it can
  derive and stops at what must be authored.
- F47 — creation is committed on four targets on evidence that exists for two. **User chose to scope creation to the two
  channel-two targets** (the recommendation), which is the YAGNI rule's strictly-simpler-version path.

**Verified and confirmed unchanged.** `evidence-based-investigator` re-verified R1's foundational corrections and all
held: the eight-plus-one drift table is exact (C1); F32's count of eleven releases is exact, re-derived by an
independent `git merge-base --is-ancestor` sweep over every tag and corroborated by a second agent using a different
method (C2); T2's live platform configuration is unchanged (C3); F31's set of exactly three untrue declarations is
closed, checked against every declared edge in every plugin rather than the three suspected (C4). D8's repoint target
holds (C5, V6). This matters: R1's volume raised the question of whether its own resolutions were sound, and the answer
is that its facts were right and its reasoning about the interaction between two of them was not.

**Changed in plan:** Channels and targets; Outcome; Primary flow (binding constraints, Step 1, Step 2, Step 3, Step 4,
Step 6, Step 7); Alternate flows and states; Edge cases and failure modes; Coordinations; User interactions; Deferred
(YAGNI); Summary; Review History.

**Changed in decision log:** D36, D37, D38, D39, D40 added. Corrections and extensions:

- **D6** — its exception was stated in two verbs, both about looking. D31 added a third the exception never acquired, so
  a repairing release would publish the bundle to the channel that cannot install it. Restated against what the rule
  does on that channel rather than against a verb list.
- **D8** — its evidence verified one of four declared edges and called the manifest true on that basis. All four
  verified; the stated test that distinguishes a wrapped-skill dependency from a decorative one is now recorded.
- **D18** — annotated, not edited. It was right: R1's unit claim was never written into it, and F44 restored the spec to
  what it always said.
- **D19** — a stale count ("the ten real plugin directories", now eleven) dropped rather than corrected, per this
  repository's convention that indexes are verified complete rather than counted.
- **D24** — two corrections. Its R1 approval anchor is unmeetable, and its claim to settle what stops a branch-cut
  release no longer holds against a release that repairs.
- **D31** — four corrections: creation scoped to channel two, "membership and nothing more" falsified, the
  undefined-version universal narrowed, and its scoping by D19 and D6 made explicit.
- **D33** — its stated rule (sentence) and its applied rule (proximity) disagreed. Bounded to the paragraph.
- **D34** — completed. The gate stop's recovery never accounted for the release's own writes, and the obvious move
  disarms the release's only mandatory confirmation.
- **D35** — extended to the shared listing shape, and its non-circularity argument softened.

**Changed in tech-notes:** none. No finding this round required a new load-bearing mechanic. T1 remains unverified and
owned by Open item 1; T2 was re-verified and is unchanged.

**YAGNI.** Two new deferrals, both with triggers: distinguishing an empty work-items file from the wrong file (raised by
`edge-case-explorer`, deferred because nobody has done it and the run already reports two zeroes), and confirming a
plugin's first publication before a release makes it installable (raised by three agents, deferred because D39's
reporting is the strictly simpler thing that satisfies the same concern). One first-class YAGNI finding was raised and
resolved by narrowing rather than deferring (F47). The round also declined two tempting additions on YAGNI grounds: a
version-inference rule for a plugin shape with zero members (F48), and an apparent-removal detector that would infer
intent from absence (F58).

**Stability assessment:** not stable, but the trajectory changed. The round produced 17 major findings, three of which
required user judgment and one of which (F44) reversed an R1 resolution. That is still far past the stop rule. But the
character is different from R1: R1 falsified claims about the world (what the platform enforces, what the release can
do, how many releases ran), and R2 falsified almost nothing about the world — every foundational fact it re-checked held
up. What R2 found was that one decision (D31) was granted late in R1 and never propagated into the six neighbouring
decisions it changed. That is a containable defect, and it is now contained.

**Next step:** run R3, and scope it narrowly. R2's own resolutions added five decisions and touched eight, all of them
in the same neighbourhood, and the lesson of F44 is precisely that decisions made in one round and not checked against
each other are where the next round's findings live. R3 should verify that D36 through D40 do not collide with each
other or with what they corrected — particularly D36's authored-presence gate stop against D31's "ordinary path" framing,
and D37's commit commitment against D34's recovery order. The specification's factual foundation is now well-tested and
should not need re-litigating.

## R3

**Mode:** team. **This is the final round — the large-size cap is 3.**

**Spec-aware mode:** engaged. Every agent received the behavioral-level brief, the YAGNI brief, and the evidence brief,
plus R1's and R2's findings.

**Size:** large — unchanged. Round cap 3, team cap 5.

**Specialists engaged:** `junior-developer`, `adversarial-validator`, `devops-engineer`. All three returned output.
`evidence-based-investigator` and `edge-case-explorer` were **dropped for this round** and the reason is worth recording:
R2 used the investigator to re-verify the spec's entire factual foundation — the drift table, the eleven-release count,
the live platform configuration, the closed set of three untrue declarations — and every claim held. Re-running it would
have spent the last round re-confirming settled facts rather than testing R2's own reasoning, which R2's next-step note
correctly identified as the place the findings would be. That judgment paid: R3's findings are all reasoning defects, and
not one of them touches a fact.

**Findings raised:** F67, F68, F69, F70, F71, F72, F73, F74, F75, F76 (major); F79, F80, F81 (minor); F77, F78 (raised
and rejected). Numbering continues from R2, which reached F66.

**Convergence, and it is the whole story.** All three specialists independently found the same root: **D36 contradicts
itself in its own Outcome.** R2 resolved F46 and F47 into one decision in a single pass and never read the halves against
each other — committing creation to two channel-two targets while establishing, in the same decision's rationale, that
one of those targets *is* the authored presence the other half refuses to invent. A record that is the presence cannot be
created from nothing.

That is verbatim the mistake R2 caught R1 making. R2's F44 diagnosed it precisely — "two resolutions from the same round
contradicting each other" — and then R2 did it again, in the very decision it wrote to fix the first one. The
`adversarial-validator` found it by applying R2's own diagnostic test: D40's dependent-decisions list omits D36, which is
the identical tell F50 used on D6/D31.

**Nine of the ten major findings are downstream of that one.** F68 (step 1 became binding and the constraint list did not
say so), F69 ("costs lateness" is false), F72 (D40 says close where D36 says stop), F74 (the gap list is four lists), F81
(the evidence citation names an incident the capability cannot serve) all fall out of F67. F70, F71, F73, F75, F76 are
its siblings: sentences written before the release could create, or before creation was scoped, that nobody re-read.

**Surfaced to the user.** One finding required judgment only the plan's author could make:

- F67 — how does D36's self-contradiction resolve? **User chose "creation reaches the listing entry only"** (the
  recommendation), accepting three consequences stated up front: step 1 becomes a binding constraint, a new plugin merged
  past the check freezes the next release until someone authors its presence, and the surviving capability has no live
  instance and stands on D31's forward-looking argument rather than the Linear incident. The user also chose to apply all
  nine downstream findings in this round rather than defer them to `plan-implementation`.

**Failed falsifications, recorded because they are results.** Two attacks the caller specifically commissioned came back
clean and are logged as rejected findings rather than dropped: D37 does not collide with D34 (F78 — refuted independently
by all three specialists; the two are keyed to mutually exclusive gate outcomes), and there is no case where a release
should decline to overwrite a stale version record (F77 — no evidence at any tier supports one, so raising it would
violate the evidence rule). D38's repair scope was separately verified sound: "the version the release is publishing" is
well-defined on all three unbumped paths.

**Changed in plan:** Outcome; Actors and triggers; Primary flow (binding constraints, Step 3, Step 4); Alternate flows
and states; Edge cases and failure modes; Coordinations; User interactions; Deferred (YAGNI); Summary; Review History.

**Changed in decision log:** D41 added. Corrections:

- **D36** — corrected at the root. Its boundary was real and fell one target to the left of where it put it.
- **D40** — its mechanism corrected to follow D36; its behavioral answer survives, and the corrected version is better
  than what it replaced (a half-removal is named rather than silently undone).
- **D24** — its partial-failure recovery still used pre-creation vocabulary that the spec was rendering verbatim.
- **D39** — reports changes rather than every write, and its "Behavioral" evidence label corrected.
- **D34** — dependent-decisions list completed with D36 and D37.

**Changed in tech-notes:** none. No finding across all three rounds after R1 required a new load-bearing mechanic.

**YAGNI.** No new candidates and no new deferrals. `adversarial-validator` ran the gate over all five of R2's decisions
and both of its deferrals and found no unevidenced scope creep — the round's defects are correctness and consistency
failures in decisions that were appropriately evidenced for inclusion. F81 is the closest call: the surviving creation
capability has no live instance, which by F47's own test would cut it. It is kept because the entry is derivable (close
to D29's "free"), and the spec now says so instead of citing an incident it cannot close.

**Stability assessment:** not stable at the cap, and honest about it. The round produced ten major findings, one of which
required user judgment and reversed part of an R2 decision. That is far past the stop rule (≤2 new findings, zero major).

But the trajectory is clear and worth reading: R1 falsified claims about the world. R2 falsified nothing about the world
and found one decision that had not been propagated. R3 falsified nothing about the world and found one decision that
contradicted itself, plus its blast radius. Each round's defect is narrower than the last, and all of R3's are now
closed. What has never once failed re-verification is the specification's factual foundation.

**The pattern this review should be remembered for:** three rounds running, the defect was a decision made late in a
round and not read against its neighbours. R1 did it with F29/F30. R2 did it with F46/F47 inside D36. The mechanism that
caught it both times was the dependent-decisions list — F50, F72, and F79 are all the same check. If a fourth round were
run, that check is where it should start.

**Next step:** the round cap is reached, so no R4 runs under this skill. The specification is materially stronger than it
was two rounds ago and its remaining risk is concentrated, not diffuse: R3's own resolutions added one decision (D41) and
corrected five, and by this review's own repeated lesson, that is exactly the surface a fresh pass would probe. The
recommendation is not another full review but a targeted check of D36-as-corrected and D41 against D31, D38, D39, and D40
before implementation planning begins — the check this specification has now failed to perform three times in a row, and
which costs one pass rather than one round.
