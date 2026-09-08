# Implementation Decision Log: The readability standard honors what the reader asked for

Every implementation decision behind [../feature-implementation-plan.md](../feature-implementation-plan.md),
with its evidence and the alternatives rejected. Behavioral decisions live in the specification's own
[decision-log.md](decision-log.md) and are not reopened here.

## Trivial decisions

None. Every decision below carries at least one rejected alternative and evidence beyond what the
specification already committed to, which is what makes it full rather than trivial. Recorded explicitly so a
later reader knows the classification was run rather than skipped.

## Full decisions

### D-1: The exclusion list is a named artifact of the plan

- **Question:** The obvious completeness check is a repository-wide search returning nothing. It never returns
  nothing. What does the check say instead?
- **Decision:** The plan names the classes the search legitimately hits, and the check reads "hits appear in
  exactly these classes and nowhere else." The search is scoped to the phrase, not to the word "six."
- **Rationale:** Three of the legitimate hits sit inside the same plugin as the two canonical files and use
  nearly identical phrasing, so a sweep working plugin-by-plugin would falsify the readability editor's
  statement about its own rubric. A prior plan spent a whole decision avoiding that failure. An exclusion list
  living in a reviewer's head is not checkable; one written into the plan is. Scoping the search to the phrase
  matters as much as the list: an unscoped search for the word "six" returns a dozen matches in this
  repository that have nothing to do with the readability check, so it cannot serve as a completeness gate.
- **Evidence:** Verified by wrap-tolerant search on 2026-08-19. The legitimate hits are `CHANGELOG.md` (twelve
  historical entries), five files under `docs/research/`, many under `docs/plans/`, and three files describing
  the editor's own rubric: `han-communication/agents/readability-editor.md:95` and `:26,27,44,142`,
  `han-communication/docs/agents/readability-editor.md:21,72` plus a third size reference in the same file,
  and `han-communication/skills/edit-for-readability/SKILL.md` ("Do not restate the six rubric criteria
  here"). The editor files are correct as written, per the specification's Out of Scope section and D7 in its
  decision log. Unrelated matches that must also stay include
  `han-coding/skills/coding-standard/SKILL.md`'s six adoption-bias checks,
  `han-core/agents/edge-case-explorer.md`'s six dimensions, `han-core/agents/gap-analyzer.md`'s six steps, and
  the "Six places" sentence in every vendored copy of `collaborative-stop-rule.md`.
  `docs/plans/orwell-six-rules/artifacts/implementation-decision-log.md:78-85` records the prior decision that
  bent around this hazard.
- **Rejected alternatives:**
  - Check that the search returns nothing. Rejected: it can never return nothing, so the criterion would be
    unusable on day one.
  - Restrict the sweep by directory. Rejected: the files that must not change sit in the same directory tree
    as the two that must.
  - Search on the word "six" rather than the phrase. Rejected at synthesis: it returns a dozen unrelated
    matches, so the check would be noise.
- **Driven by rounds:** R1 (JD-001), corrected at synthesis
- **Dependent decisions:** D-7, D-8
- **Referenced in plan:** Constraints and Boundaries; Definition of Done, item 3; Risks, R1
- **Settled by:** evidence

### D-2: Two replacement sentences are drafted once before the sweep

- **Question:** Does each corrected site get wording chosen at the site, or does the plan fix the wording
  first?
- **Decision:** Two sentences are drafted and recorded as the first work unit, before any file is edited.
- **Rationale:** Sixteen files carry a byte-identical block and four more carry a near-identical variant of
  it. Choosing wording sixty-odd times produces sixty-odd slightly different sentences and a diff nobody can
  review as a unit. The two halves are also different in kind, and conflating them hides that: the size fix
  removes one word, while the fidelity fix has to carry a condition and a floor inside one sentence of a
  three-sentence block.
- **Evidence:** Verified by wrap-tolerant search on 2026-08-19: sixteen `SKILL.md` files carry the block
  byte-identically, and four more (`code-overview`, `design-an-api`, `html-summary`,
  `update-pr-description`) carry a variant differing only in the phrase after "never whether."
  `han-coding/skills/architectural-analysis/SKILL.md:291-293` is the representative block, and its own wording
  already names the fidelity criterion with no number, so the size fix there removes one word. The
  specification's D6 claims the target wording "exists and does not have to be invented," citing
  `han-communication/skills/readability-guidance/SKILL.md`. That claim holds for the size class only. That
  file is count-free but says nothing about scoped fidelity, so the second sentence genuinely has to be
  written.
- **Rejected alternatives:**
  - Choose wording per site. Rejected on review cost and on consistency.
  - Reuse one sentence for both classes. Rejected: they say different things.
- **Driven by rounds:** R1 (JD-002), counts corrected at synthesis
- **Dependent decisions:** D-5
- **Referenced in plan:** Implementation Approach; Work Units and Sequencing, unit 1; Risks, R3
- **Settled by:** evidence

### D-3: The sweep lands before the canonical files

- **Question:** Skills read the standard live, so any commit between "standard changed" and "sweep finished"
  leaves the repository disagreeing with itself. Does that set the order, and does it need more than ordering?
- **Decision:** Correct the quoting sites first and change the two canonical files last, within one branch and
  one pull request.
- **Rationale:** Count-free wording is true against the six-criterion rule and the seven-criterion rule alike,
  which makes it the only wording correct in every intermediate state. The reverse order opens a window where
  every skill in the repository contradicts the rule inside its own context. Nobody outside the author's
  machine observes an intermediate commit, so ordering is the whole remedy.
- **Evidence:** `docs/local-development.md:3-4`: "Changes on your branch are immediately available in any Claude
  instance on your machine." The specification's Coordinations table, first row, records that skills read the
  standard when they draft.
- **Rejected alternatives:**
  - Split across pull requests. Rejected: it buys nothing, because users see only the merge.
  - Ignore the ordering. Rejected: the author runs Han skills on this machine while building this.
- **Driven by rounds:** R1 (JD-007)
- **Dependent decisions:** None
- **Referenced in plan:** Implementation Approach
- **Settled by:** evidence

### D-4: The fidelity restatement splits by grammatical subject, not by block

- **Question:** The fidelity restatement appears in more than one role. Which roles get corrected?
- **Decision:** Every restatement whose subject is **the standard** is corrected. Every restatement whose
  subject is **the audience frame** is left exactly as it is.
- **Rationale:** The test is what the sentence claims can never drop a fact. A sentence saying *the standard*
  never decides whether a required fact appears becomes conditionally untrue, because a reader's stated request
  can now drop one. A sentence saying *the frame* never decides that stays true: what can drop a fact is the
  reader's request, not the instruction to write for a named audience. The specification scopes the relaxation
  to a stated request and leaves every unrequested case untouched. The round recorded this as a two-role split
  between a self-check block and an audience-frame paragraph. Synthesis found that the block a sentence sits in
  does not decide the answer: four sentences sit in audience-frame paragraphs and still name the standard as
  the guarantor, so they change too.
- **Evidence:** Verified by wrap-tolerant search on 2026-08-19. Twenty-five sites name the standard: twenty
  self-check restatements in twenty `SKILL.md` files, three audience-frame paragraphs that still say "the
  standard governs" (`han-coding/skills/code-review/SKILL.md`, `han-coding/skills/code-overview/SKILL.md:59`,
  `han-reporting/skills/stakeholder-summary/SKILL.md`), one in
  `han-coding/skills/code-review/references/output-verification.md:97`, and one in `docs/readability.md:155`.
  Nine sites name the frame and stay: `coding-standard`, `automated-test-planning`, `readability-guidance`,
  `architectural-decision-record`, `iterative-plan-review`, `plan-a-feature`, `plan-a-phased-build`,
  `plan-implementation`, `plan-work-items`, plus the canonical sentence in
  `han-communication/references/readability-rule.md`. The specification's D5 states fidelity stays absolute
  whenever the reader asked for nothing; its Coordinations row states the restatement is corrected wherever it
  appears.
- **Rejected alternatives:**
  - Correct every restatement. Rejected. This was one specialist's recommendation and the other specialist
    found the counter-evidence, naming `readability-guidance` as a false positive that must stay unchanged.
    Correcting it would state that the audience frame can drop facts, which is not what this feature does.
    That counter-evidence still holds under the corrected split.
  - Correct the frame sites with a different sentence. Rejected: nothing about them became untrue, and seven
    of the nine carry a skill-specific tail naming that skill's own must-keep facts.
  - Split on the block a sentence sits in rather than on its subject. Rejected at synthesis: four sentences in
    audience-frame paragraphs name the standard, so the block test misroutes them.
- **Driven by rounds:** R1 (TE-T2, JD-003), refined at synthesis
- **Dependent decisions:** D-2, D-7
- **Referenced in plan:** Work Units and Sequencing, unit 3; Definition of Done, item 4; Testing Strategy
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
- **Dependent decisions:** None
- **Referenced in plan:** Work Units and Sequencing, unit 5
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
  Unverified: could not inspect an actual release run or the maintainer's intent behind the versioning
  document, because neither is in the repository.
- **Known tension, not resolved here:** `docs/semantic-versioning.md` reads as though bumps happen on the
  feature branch, while the commit record shows they happen at release. That gap predates this change and is not
  this branch's to close.
- **Rejected alternatives:**
  - Bump every affected plugin here. Rejected against the commit-history precedent and the release skill's
    stated behavior.
- **Driven by rounds:** R1 (JD-005, JD-006)
- **Dependent decisions:** None
- **Referenced in plan:** Constraints and Boundaries
- **Settled by:** evidence

### D-7: The branch-scoped documentation check is kept, the Bats script is not

- **Question:** What verification machinery does this change earn?
- **Decision:** One run of the repository's branch-scoped documentation check, and no checked-in test.
- **Rationale:** The documentation check already exists, scopes itself to what the branch touched, and a prior
  plan ran exactly it for exactly this failure mode. A new checked-in test fails the evidence test: no incident,
  no broken code path, and every script with a test beside it in this repository backs a script a skill invokes
  at runtime rather than a one-time migration. The search patterns also produce false positives that must stay
  unchanged, so a pass-or-fail assertion would misfire on correct text. Synthesis strengthened the case for
  keeping the check: the inventory was found incomplete a second time, so the backstop has now caught this
  class twice.
- **Evidence:** `docs/plans/orwell-six-rules/artifacts/implementation-decision-log.md:133` records the prior
  scoped check. The seven existing Bats files all cover runtime scripts. The false positives include
  `han-communication/skills/readability-guidance/SKILL.md:73-74` (per D-4) and the unrelated "six" matches
  listed in D-1.
- **Rejected alternatives:**
  - Add a Bats test asserting no count reference survives. Deferred under YAGNI with its reopening trigger.
- **Driven by rounds:** R1 (TE-S1, JD YAGNI check)
- **Dependent decisions:** None
- **Referenced in plan:** Work Units and Sequencing, unit 9; Risks, R2; Deferred (YAGNI)
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
- **Dependent decisions:** None
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
- **Evidence:** Churn over ninety days across the six files the discovery notes name, re-measured at synthesis
  with `git log --since="90 days ago"`: twelve commits, ten, seven, six, five, and four, for forty-four in
  total. The three scenarios come from the specification's Primary Flow, its second alternate flow, and its
  collision flow.
- **Rejected alternatives:**
  - A golden-transcript test. Deferred under YAGNI with its reopening trigger.
- **Driven by rounds:** R1 (TE-T4, TE-S2)
- **Dependent decisions:** None
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
  preserved (`printWidth: 120`, `proseWrap: preserve`), so this is a permanent property of the repository
  rather than a formatting accident.
- **Rejected alternatives:**
  - Trust the line-oriented counts. Rejected by direct counter-evidence.
- **Driven by rounds:** R1 (TE-T2, and the planning run's own verification)
- **Dependent decisions:** D-1, D-2, D-4, D-5, D-8, D-11, D-12, D-13
- **Referenced in plan:** Testing Strategy; Risks, R2
- **Settled by:** evidence

### D-11: The sweep covers the non-skill quoting surfaces the first inventory missed

- **Question:** The round's inventory counted skill files. Does anything outside the skill directories quote
  the size reference?
- **Decision:** Yes. Five files outside the skill directories carry six size references, and all six are
  corrected in the same sweep.
- **Rationale:** The specification's Coordinations row already commits to this: it names skills, operator-facing
  documents, and one canonical reference file, and says each stops naming a number. The round's inventory
  recorded only three of the five files, because its search matched the hyphenated forms of the phrase and
  missed the spelled-out one. Leaving two of them behind would ship the exact failure the sweep exists to
  prevent, in the documents a new contributor reads first.
- **Evidence:** Verified by wrap-tolerant search on 2026-08-19. `docs/readability.md` carries two (line 89,
  "six behaviorally-anchored yes/no criteria", and line 105, "six-criterion self-check"); `docs/concepts.md`
  carries one ("its six behaviorally-anchored criteria"); `CONTRIBUTING.md` carries one at line 258 ("the skill
  runs six behaviorally-anchored yes/no criteria"); `han-communication/docs/output-styles/han-readability.md`
  carries one at line 72; `han-communication/references/explanation-rule.md` carries one at line 17. The first
  three were absent from the round's inventory. `docs/readability.md:155` also carries a fidelity restatement,
  routed by D-4.
- **Rejected alternatives:**
  - Leave the contributor-facing and concept documents for a follow-up. Rejected: they are the two documents a
    new contributor reads before touching a skill, and the specification already committed to correcting every
    surface that names the check by a number.
  - Treat the miss as evidence the sweep needs a checked-in test. Rejected: the branch-scoped documentation
    check already covers it (D-7), and the test fails the evidence gate for the reasons recorded there.
- **Driven by rounds:** Synthesis (Step 8 evidence)
- **Dependent decisions:** None
- **Referenced in plan:** Work Units and Sequencing, unit 2
- **Settled by:** evidence

### D-12: Only the positional references that proposal 2 falsifies are replaced

- **Question:** Adding a seventh criterion appends rather than reorders, so no existing criterion moves. Why
  does any positional reference need replacing, and which ones?
- **Decision:** The six references to criterion 6 are replaced with the criterion's name. The one reference to
  criterion 5 is left alone.
- **Rationale:** The round's stated reason was that leaving the numbers would make the count-free claim untrue
  "on the next reordering." That is future flexibility, not evidence, and it fails the YAGNI gate on its own.
  The evidence that does hold is different: each of the six sentences says criterion 6 is the only fidelity
  guard the output has and is therefore not optional, and work-item proposal 2 makes exactly that claim
  conditionally untrue. So those six are corrected as part of the fidelity class, and naming the criterion
  instead of its number is the natural form for the replacement. Nothing about criterion 5 changed, so the one
  reference to it is left as written.
- **Evidence:** Verified by wrap-tolerant search on 2026-08-19. Six `SKILL.md` files name criterion 6:
  `architectural-decision-record`, `runbook`, `html-summary`, `issue-triage`, `plan-work-items`,
  `iterative-plan-review`, each in the form "criterion 6 is not optional" or "criterion 6 is the only
  fact-preservation guard the output has." `han-coding/skills/code-overview/SKILL.md:397` names criterion 5
  ("Criterion 5 of the readability self-check above carries this one"), and criterion 5 keeps both its position
  and its meaning. `han-communication/references/readability-rule.md:112,132` name criteria 5 and 6 in the
  canonical file and are handled by the canonical-file work unit. The specification's Coordinations row commits
  to the positional references stopping.
- **Rejected alternatives:**
  - Replace all seven positional references, including the criterion 5 one. Rejected: the only justification is
    a future reordering, which is not accepted evidence. Deferred with a reopening trigger.
  - Leave all seven. Rejected: six of them assert a guarantee that proposal 2 makes conditionally untrue, so
    they are wrong on substance rather than on numbering.
- **Driven by rounds:** Synthesis (Step 8 evidence)
- **Dependent decisions:** None
- **Referenced in plan:** Work Units and Sequencing, unit 4; Definition of Done, item 5; Deferred (YAGNI)
- **Settled by:** evidence

### D-13: The one hardcoded enumeration of the check gains the seventh criterion

- **Question:** The specification says skills read the standard at draft time, so no skill needs editing to
  receive the new check. Does that hold for every skill?
- **Decision:** No. One skill restates the whole check as its own numbered list of six, and that list gains a
  seventh item.
- **Rationale:** The inbound-coordination assumption holds for skills that invoke the guidance skill and read
  the standard live. It does not hold for a skill that copied the criteria into its own reference file. Left
  as six, that skill would run a six-criterion check against a seven-criterion standard, which is the same
  class of contradiction the sweep exists to remove, in the one place a reader would not think to look for it.
- **Evidence:** `han-coding/skills/code-review/references/output-verification.md:85-97` enumerates criteria 1
  through 6 in its own words under "Step 9.2: Readability self-check" and closes with the fidelity restatement
  routed by D-4. No other file in the repository enumerates the criteria as a numbered self-check; searches for
  the criterion phrasings on 2026-08-19 returned only property lists that name a subset illustratively and are
  already count-free. `han-coding/skills/code-review/SKILL.md:76` confirms this file is where code-review's
  self-check lives.
- **Rejected alternatives:**
  - Replace the enumeration with a pointer to the standard. Rejected: it is a larger change than the evidence
    supports, and the file's per-item wording is skill-specific (task IDs, severity labels, `EXPLOIT:` fields)
    rather than a copy of the rule.
  - Leave it at six. Rejected: it would ship a skill instructing a six-criterion check, which is the failure
    this plan exists to prevent.
- **Driven by rounds:** Synthesis (Step 8 evidence)
- **Dependent decisions:** None
- **Referenced in plan:** Work Units and Sequencing, unit 6; Definition of Done, item 6; Risks and Assumptions
- **Settled by:** evidence

### D-14: The inventory is built by the plan, not inherited from it

- **Question:** How many sites does the sweep correct?
- **Decision:** No count in this plan is the check. The figures it quotes are a planning-time snapshot, already
  known to have been wrong three times. Its first work unit builds the inventory from a documented pattern set
  and records both the inventory and the patterns. Every later unit works from that output, and the completeness
  check re-runs the recorded patterns rather than comparing against a number.
- **Rationale:** Three inventories were built during planning and every one was wrong. Freezing a fourth into
  the plan would be the same mistake with better prose. The failure is not carelessness; it is that this corpus
  states the same commitment in several wordings and wraps its prose mid-sentence, so any single pattern
  undercounts. A recorded pattern set can be re-run and extended. A number in a plan can only go stale, which is
  the exact failure this whole feature exists to remove from the standard.
- **Evidence:** Three corrections, each from a narrower pattern than the corpus:
  1. A line-oriented search found 18 files carrying the fidelity restatement. Joining lines found 20. Prettier
     is configured with prose wrapping preserved, so a sentence spanning two lines is normal here.
  2. Hyphenated patterns ("six-point", "six-criterion") missed the spelled-out form "six behaviorally-anchored
     yes/no criteria" in `CONTRIBUTING.md:258` and `docs/readability.md:89`, and a further variant without
     "yes/no" in `docs/concepts.md:191`.
  3. Patterns written for "never whether a required fact appears" missed "never whether a required **technical**
     fact appears" in `han-coding/skills/code-review/SKILL.md`,
     `han-coding/skills/code-review/references/output-verification.md`,
     `han-documentation/skills/architectural-decision-record/SKILL.md`, and
     `han-github/skills/update-pr-description/SKILL.md`; and missed "Fidelity outranks readability: no required
     fact is dropped to read more simply" in `docs/concepts.md:193` and `docs/readability.md`, which states the
     same guarantee without using the word "appears" at all.
- **The starting pattern set**, to extend rather than to trust:
  - Size reference: `six-point`, `six-criterion`, `six-item`, `six criteria`, `six behaviorally-anchored`
  - Fidelity guarantee: `never whether a required fact appears`, `never whether a required technical fact
    appears`, `Fidelity outranks readability`, `no required fact is dropped`
  - Positional reference: `criterion 6`
  - Every one run with lines joined, because of finding 1 above.
- **The exclusion list**, per [D-1](#d-1-the-exclusion-list-is-a-named-artifact-of-the-plan): the planning
  folder, the research folder, the changelog, and the files describing the readability editor's own rubric.
  Note that "Fidelity outranks readability" is the editor's own principle in several of those files and stays.
- **Rejected alternatives:**
  - Freeze the corrected count in the plan. Rejected by three consecutive counter-examples inside this run.
  - Keep iterating in planning until the count is provably right. Rejected: the round cap closed, and each
    round found a new variant rather than converging, which is evidence the method matters more than one more
    pass.
- **Driven by rounds:** R1, plus the synthesis-stage corrections and one further verification by the planning
  run
- **Dependent decisions:** D-1, D-2, D-4, D-11, D-12
- **Referenced in plan:** Implementation Approach; Work Unit 0; Definition of Done, item 0
- **Settled by:** evidence
