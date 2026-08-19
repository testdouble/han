# Implementation Decision Log: The readability standard honors what the reader asked for

Every implementation decision behind [../feature-implementation-plan.md](../feature-implementation-plan.md),
with its evidence and the alternatives rejected. Behavioral decisions live in the specification's own
[decision-log.md](decision-log.md) and are not reopened here.

### D-1: The exclusion list is a named artifact of the plan

- **Question:** The obvious completeness check is a repository-wide search returning nothing. It never returns
  nothing. What does the check say instead?
- **Decision:** The plan names the four places the search legitimately hits, and the check reads "hits appear in
  exactly these four classes and nowhere else."
- **Rationale:** Two of the legitimate hits sit inside the same plugin as the two canonical files and use nearly
  identical phrasing, so a sweep working plugin-by-plugin would falsify the readability editor's statement about
  its own rubric. A prior plan spent a whole decision avoiding that failure. An exclusion list living in a
  reviewer's head is not checkable; one written into the plan is.
- **Evidence:** The search hits `CHANGELOG.md:343`, five files under `docs/research/`, many under `docs/plans/`,
  and `han-communication/agents/readability-editor.md:95` plus
  `han-communication/docs/agents/readability-editor.md:21,72`. The last two are correct as written, per the
  specification's Out of Scope section and D7 in its decision log.
  `docs/plans/orwell-six-rules/artifacts/implementation-decision-log.md:78-85` records the prior decision that
  bent around this hazard.
- **Rejected alternatives:**
  - Check that the search returns nothing. Rejected: it can never return nothing, so the criterion would be
    unusable on day one.
  - Restrict the sweep by directory. Rejected: the two files that must not change sit in the same directory tree
    as the two that must.
- **Driven by rounds:** R1 (JD-001)
- **Referenced in plan:** Constraints and Boundaries; Definition of Done, item 3; Risks, R1
- **Settled by:** evidence

### D-2: Two replacement sentences are drafted once before the sweep

- **Question:** Does each of the twenty-eight sites get wording chosen at the site, or does the plan fix the
  wording first?
- **Decision:** Two sentences are drafted and recorded as the first work unit, before any file is edited.
- **Rationale:** Nineteen of the size-reference sites carry an identical three-sentence block. Choosing wording
  twenty-eight times produces twenty-eight slightly different sentences and a diff nobody can review as a unit.
  The two halves are also different in kind, and conflating them hides that: the size fix deletes a word, while
  the fidelity fix has to carry a condition and a floor inside one sentence of a three-sentence block.
- **Evidence:** `han-coding/skills/architectural-analysis/SKILL.md:291-293` is the representative block, and its
  own wording already says "its fidelity criterion" with no number, so the size fix there is a one-word
  deletion. The specification's D6 claims the target wording "exists and does not have to be invented," citing
  `han-communication/skills/readability-guidance/SKILL.md`. That claim holds for the size class only. That
  file's line 82-84 is count-free but says nothing about scoped fidelity, so the second sentence genuinely has
  to be written.
- **Rejected alternatives:**
  - Choose wording per site. Rejected on review cost and on consistency.
  - Reuse one sentence for both classes. Rejected: they say different things.
- **Driven by rounds:** R1 (JD-002)
- **Referenced in plan:** Implementation Approach; Work Units 1, 2, 3; Risks, R3
- **Settled by:** evidence

### D-3: The sweep lands before the canonical files

- **Question:** Skills read the standard live, so any commit between "standard changed" and "sweep finished"
  leaves the repository disagreeing with itself. Does that set the order, and does it need more than ordering?
- **Decision:** Correct the quoting sites first and change the two canonical files last, within one branch and
  one pull request.
- **Rationale:** Count-free wording is true against the six-criterion rule and the seven-criterion rule alike,
  which makes it the only wording correct in every intermediate state. The reverse order opens a window where
  every skill in the repository contradicts the rule inside its own context. Nobody outside the author's machine
  observes an intermediate commit, so ordering is the whole remedy.
- **Evidence:** `docs/local-development.md:3-4`: "Changes on your branch are immediately available in any Claude
  instance on your machine." The specification's Coordinations table, first row, records that skills read the
  standard when they draft.
- **Rejected alternatives:**
  - Split across pull requests. Rejected: it buys nothing, because users see only the merge.
  - Ignore the ordering. Rejected: the author runs Han skills on this machine while building this.
- **Driven by rounds:** R1 (JD-007)
- **Referenced in plan:** Implementation Approach; Work Units and Sequencing; Assumptions
- **Settled by:** evidence

### D-4: The audience-frame sentence is left unchanged

- **Question:** The fidelity restatement appears in two different roles. Do both get corrected?
- **Decision:** No. The eighteen self-check sites are corrected. The eight audience-frame sites are left exactly
  as they are.
- **Rationale:** The two sentences describe different mechanisms, and only one of them changes. The self-check
  restatement says the standard never decides whether a required fact appears, which this change makes
  conditionally untrue. The audience-frame restatement says the *frame* never decides that, which stays true:
  what can now drop a fact is the reader's stated request, not the instruction to write for a non-expert. The
  specification scopes the relaxation to a stated request and leaves every unrequested case untouched.
- **Evidence:** Verified line-level counts across the twenty affected skill files: eighteen carry
  "standard governs how the content is said," eight carry "frame governs how a fact is said," and six carry
  both. Two files carry only the audience-frame form:
  `han-communication/skills/readability-guidance/SKILL.md` and
  `han-planning/skills/plan-a-feature/SKILL.md`. The specification's D5 states fidelity stays absolute whenever
  the reader asked for nothing.
- **Rejected alternatives:**
  - Correct all twenty-six sites. Rejected. This was one specialist's recommendation and the other specialist
    found the counter-evidence, naming `readability-guidance` as a false positive that must stay unchanged.
    Correcting it would state that the audience frame can drop facts, which is not what this feature does.
  - Correct the audience-frame sites with a different sentence. Rejected: nothing about them became untrue, and
    seven of the eight carry a skill-specific tail naming that skill's own must-keep facts.
- **Driven by rounds:** R1 (TE-T2, JD-003)
- **Referenced in plan:** Work Unit 3; Definition of Done, item 4; Testing Strategy
- **Settled by:** evidence, after the two specialists disagreed

### D-5: One site takes a paragraph rewrite rather than a sentence swap

- **Question:** Does every site take a sentence-level edit?
- **Decision:** All but one. `han-reporting/skills/stakeholder-summary/SKILL.md` takes a paragraph rewrite.
- **Rationale:** That file carries an overlapping pair. Correcting each line in isolation leaves two count-free
  sentences saying the same thing back to back. It is the only site found with this shape, so it is an exception
  rather than evidence the sweep needs bespoke handling throughout.
- **Evidence:** `han-reporting/skills/stakeholder-summary/SKILL.md:243-248` says "Confirm each of the six
  criteria and fix any failure with Edit:" and then repeats the standard block, which also says "Correct every
  failure before presenting."
- **Rejected alternatives:**
  - Treat it like the others. Rejected: it produces a visible duplication.
  - Give every site a paragraph review. Rejected on cost, with no second instance to justify it.
- **Driven by rounds:** R1 (JD-004)
- **Referenced in plan:** Work Unit 5
- **Settled by:** evidence

### D-6: No version bump and no changelog edit on this branch

- **Question:** The change edits shipped files across seven plugins. Does this branch move any version?
- **Decision:** No. No plugin manifest and no changelog entry changes here. The release skill proposes the bump
  at release time.
- **Rationale:** The repository's own practice separates feature work from version work, and the release skill
  is built to propose the bump itself. A feature branch that bumps seven plugins speculatively is guessing at a
  decision the release process makes with better information.
- **Evidence:** Version bumps land in dedicated commits touching only manifests: `50d90cd chore(release):
  v5.3.0`, `beab327 chore(release): v5.2.0`, `d232463 chore(versions): bump every plugin for the han v5.0.0
  suite release`. A feature commit of exactly this shape did not bump: `24ebbfa feat(han-communication): add the
  han-readability output style` added a new component kind and touched no manifest. The release skill's own
  description says it "proposes a semantic-versioning bump and confirms the whole plan before continuing."
- **Known tension, not resolved here:** `docs/semantic-versioning.md` reads as though bumps happen on the
  feature branch, while the commit record shows they happen at release. That gap predates this change and is not
  this branch's to close.
- **Rejected alternatives:**
  - Bump every affected plugin here. Rejected against the commit-history precedent and the release skill's
    stated behavior.
- **Driven by rounds:** R1 (JD-005, JD-006)
- **Referenced in plan:** Constraints and Boundaries
- **Settled by:** evidence

### D-7: The branch-scoped documentation check is kept, the Bats script is not

- **Question:** What verification machinery does this change earn?
- **Decision:** One run of the repository's branch-scoped documentation check, and no checked-in test.
- **Rationale:** The documentation check already exists, scopes itself to what the branch touched, and a prior
  plan ran exactly it for exactly this failure mode. A new checked-in test fails the evidence test: no incident,
  no broken code path, and every script with a test beside it in this repository backs a script a skill invokes
  at runtime rather than a one-time migration. The search pattern also produces a false positive that must stay
  unchanged, so a pass-or-fail assertion would misfire on correct text.
- **Evidence:** `docs/plans/orwell-six-rules/artifacts/implementation-decision-log.md:133` records the prior
  scoped check. The seven existing Bats files all cover runtime scripts. The false positive is
  `han-communication/skills/readability-guidance/SKILL.md:73-74`, per D-4.
- **Rejected alternatives:**
  - Add a Bats test asserting no count reference survives. Deferred under YAGNI with its reopening trigger.
- **Driven by rounds:** R1 (TE-S1, JD YAGNI check)
- **Referenced in plan:** Work Unit 8; Testing Strategy; Deferred (YAGNI)
- **Settled by:** evidence

### D-8: The source files keep their own count, every quoting site drops it

- **Question:** The standard's closure sentence declares the set complete by naming its size. Does the source
  keep a number, or drop one like everything else?
- **Decision:** The two canonical files keep a count in their own closure sentences. Every file that quotes them
  drops it.
- **Rationale:** The reason to go count-free is that a reference goes stale when it sits far from the thing it
  describes. A count sitting immediately above the list it counts cannot go stale unseen, because whoever edits
  the list is reading the sentence beneath it. Stripping the number there would cost clarity in the one place it
  is informative and save nothing. It also makes the completeness check statable: no count survives outside the
  two source files and the exclusion list.
- **Evidence:** The specification's Coordinations row covers "every surface that names the check by a number"
  and describes skills, operator-facing documents, and one canonical reference file quoting the standard. The
  standard defines the check rather than quoting it. D6 in the specification's decision log grounds the
  count-free choice in the stale-reference cost specifically.
- **Rejected alternatives:**
  - Drop the number in the source too. Rejected: it removes a useful signpost above a numbered list and buys no
    protection, since that sentence cannot desynchronise from a list on the same screen.
- **Driven by rounds:** R1 (JD-008, raised as an open question and resolved from the specification's own
  reasoning rather than escalated)
- **Referenced in plan:** Definition of Done, item 3
- **Settled by:** evidence

### D-9: Behavior is checked by a manual smoke pass, not a recorded transcript

- **Question:** How is the feature's actual behavior verified?
- **Decision:** One manual pass before merge, running three scenarios from the specification, read by a person.
- **Rationale:** The behavior lives in prose an assistant reads while drafting, so there is no function to call
  and no automated test that reaches it. A recorded transcript would fail for a different reason: the readability
  area is among the most-edited in the plugin, so a snapshot would break on unrelated wording edits rather than
  on the behavior regressing. Saying plainly that part of this is unverifiable is more useful than machinery
  that appears to verify it.
- **Evidence:** Churn over ninety days in this area: twelve commits, ten, seven, six, five, and four across six
  files. The three scenarios come from the specification's Primary Flow, its second alternate flow, and its
  collision flow.
- **Rejected alternatives:**
  - A golden-transcript test. Deferred under YAGNI with its reopening trigger.
- **Driven by rounds:** R1 (TE-T4, TE-S2)
- **Referenced in plan:** Testing Strategy
- **Settled by:** evidence

### D-10: Every inventory search is wrap-tolerant

- **Question:** Nothing, until the inventory was found to be wrong.
- **Decision:** Every search that builds or checks the inventory joins lines before matching.
- **Rationale:** This repository hand-wraps prose and preserves that wrapping, so a sentence routinely spans two
  lines and a line-oriented search silently misses it. This is not hypothetical: it happened during planning, to
  the planning run and to both specialists independently, on the same two files.
- **Evidence:** A line-oriented search for the fidelity restatement found eighteen skill files. The same search
  with lines joined found twenty. The two missed files are
  `han-coding/skills/design-an-api/SKILL.md` and `han-communication/skills/readability-guidance/SKILL.md`,
  because the sentence breaks between "never" and "whether". Prettier is configured with prose wrapping
  preserved, so this is a permanent property of the repository rather than a formatting accident.
- **Rejected alternatives:**
  - Trust the line-oriented counts. Rejected by direct counter-evidence.
- **Driven by rounds:** R1 (TE-T2, and the planning run's own verification)
- **Referenced in plan:** Risks, R2
- **Settled by:** evidence
