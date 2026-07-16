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
