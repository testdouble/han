# Implementation Plan: pairing

How to build the `pairing` collaborative working mode, the shared stopping convention it rests on, and the opt-in flag
five existing skills gain.

The specification is at [feature-specification.md](./feature-specification.md) and settles what the mode does. This plan
settles how it gets built, in what order, and how anyone knows it worked.

## What you are building

Seven things, in three groups.

**The mode itself.** One new skill in `han-core` that sorts the work, proposes where it will stop, builds one piece,
hands it back with things you can check, and waits.

**The shared contract.** One new rule file in `han-core` describing what a stop presents and what returning control
means. The specification settled that it is a canonical rule file rather than inline text repeated in each skill,
because six places need to agree on the answer and five of them live in other plugins
([D22](artifacts/decision-log.md#d22-the-stopping-convention-is-a-canonical-rule-file-owned-by-han-core)).

**The flag.** An opt-in argument on five existing skills, so each returns control at the boundary it already has instead
of continuing, with no backing skill — the existing skill doing the work while the mode watches — naming the mode in its
own text
([D-1](artifacts/implementation-decision-log.md#d-1-the-flag-travels-in-the-invocation-not-as-a-named-caller)).
Three of those skills live in `han-coding` and two in `han-planning`.

Then the tail: seven skill descriptions change, four manifests stop being accurate, and roughly a dozen documentation
surfaces describe a `han-core` that no longer matches what ships.

## The one thing to get right first

Everything else in this plan depends on how a backing skill hands control back, so that is settled before anything is
written.

The suite's authoring guidance documents the general shape, calling it orchestration composition: a calling skill
invokes a sub-skill that owns a whole artifact, and the caller stays thin.

That guidance carries two warnings that shape this design. The first: the moment after a sub-skill call is when the
calling model is most likely to stop and treat the sub-skill's output as the final answer, so continuation has to be
instructed rather than assumed. The second: the more the caller carries across that call, the more likely it loses its
own thread.

The second warning cuts against this mode rather than for it, and that is worth saying plainly. Both working examples
the guidance cites call a sub-skill once, let it run to completion, and carry almost nothing across the call. This mode
carries a plan, a running feedback record, and the person's position in that plan across every stop, which is the
opposite of thin.

What makes that survivable is that the state is written down rather than remembered. The specification already commits
the feedback record to a file
([D8](artifacts/decision-log.md#d8-your-feedback-goes-into-a-readable-written-record-rather-than-being-carried-in-memory)),
so the thread the guidance warns about losing can be re-read rather than recalled.

So the stop is performed by the skill that owns the boundary, not by the mode reaching back in
([D-2](artifacts/implementation-decision-log.md#d-2-the-backing-skill-performs-the-stop-and-the-shared-rule-file-is-why-both-sides-agree-on-its-shape)).
`tdd` knows when it has finished a behavior; the mode does not. What the mode owns is the plan, the record, and the
shape a stop takes. That shape lives in the rule file, which is why the rule file is load-bearing rather than
documentation.

One part of this the guidance does not settle, and nothing in this repository can. Neither working example has a
sub-skill that ends its turn partway through its own run and later resumes with its own instructions still governing.
That is exactly what the flag asks the five skills to do. Unverified: could not inspect whether a skill can end its
turn mid-run and resume under its own instructions, because no running session exists in this repository. Phase 3 is
where that first gets observed, on the lowest-churn of the five.

## User stories

The specification commits to these behaviors. Each work unit below advances one of them.

1. **As someone building a feature test-first, I want to review each behavior as it lands**, so I catch a wrong turn at
   the second behavior instead of the twelfth.
2. **As someone designing an interface, I want to weigh one decision at a time**, so I am not handed a finished design to
   approve or reject whole.
3. **As someone drafting a response, I want to agree the shape before anyone writes sentences**, so the polish is not
   thrown away when the shape changes.
4. **As someone whose feedback was recorded early, I want it still applied late**, so I do not repeat myself at every
   stop.
5. **As someone who installed only the foundation plugin, I want the mode to work anyway**, so a missing sibling plugin
   degrades what I get rather than breaking it.

## Build order

Six phases. The order is driven by one constraint and one risk.

The constraint is mutual reference: the mode's description names the five skills, and each of the five names the mode as
the way to review as it goes. Neither half is accurate alone, so neither ships alone. They can be separate commits
behind one release.

The risk is churn. Over ninety days `plan-implementation` changed twenty-two times and `iterative-plan-review` fifteen,
which makes them the two most likely to collide with an in-flight edit.

They are also the two whose stop contract is least obvious, because a review round produces findings rather than an
artifact. They go last, so the contract is proven on easier skills first
([D-3](artifacts/implementation-decision-log.md#d-3-flag-the-five-skills-lowest-churn-first)).

### Phase 1: The shared rule file

The only phase that can land on its own. It references nothing and makes no existing statement false, because nothing
consumes it yet.

It defines what a stop presents, what returning control means, how the flag is detected, and the test for a piece being
expensive to walk back. Fixing all four here is the point: five separate edits in three plugins would otherwise invent
five slightly different answers, which is the drift the file exists to prevent.

The fourth of those is the one to write carefully, because it has no source. The reversibility framework the
specification rests on says how much scrutiny a choice deserves once you know which kind it is, and says nothing about
how to tell the two kinds apart. That criterion is authored here rather than lifted from anywhere, and it is one of the
two things listed below that nobody can check before real use.

Touch points: a new file in `han-core/references/`, vendored into `han-coding/references/` and
`han-planning/references/` the way the shared YAGNI, evidence, and configuration rules already are
([D-4](artifacts/implementation-decision-log.md#d-4-vendor-the-rule-file-following-the-established-han-core-pattern)).

### Phase 2: The mode

The skill, its detection-free degradation path, and its long-form documentation.

Touch points: `han-core/skills/pairing/SKILL.md` and `han-core/docs/skills/pairing.md`.

The skill declares the `Skill` tool in its allowed tools, because it invokes others. It must **not** declare
`AskUserQuestion`. The authoring guidance bars that tool from every skill's allowed-tools list, and a parent's rules
stack onto the skills it calls, so declaring `AskUserQuestion` here would silence the questions `design-an-api` asks
underneath as well
([D-5](artifacts/implementation-decision-log.md#d-5-the-mode-does-not-declare-askuserquestion)).

Each backing-skill invocation also needs an explicit instruction to return to the loop afterward, because the guidance
names the moment after a sub-skill call as the most common place an orchestration ends early.

Prose work needs one more thing settled here, the round's only question to reach the operator: a fixed three-rung
fidelity ladder does not scale. On a four-sentence reply it means three stops on four sentences; on a long document, the
middle rung alone is the size of the whole job. Short work climbs the ladder once, whole. Longer work agrees the shape
for the whole artifact first, then climbs the remaining rungs section by section, with the plan naming the sections up
front so they can be redirected
([D-11](artifacts/implementation-decision-log.md#d-11-the-prose-ladder-climbs-per-section-once-the-work-is-long-enough)).

The specification left this unanswered rather than answering it differently, and neither the section boundary nor the
length threshold has evidence behind it, so both are provisional.

### Phase 3: The three coding skills

`design-an-api` first, then `refactor`, then `tdd`, in ascending order of churn.

Each gains an argument entry and one short paragraph at its existing close, pointing at the vendored rule file rather
than restating the convention. Two reasons to keep that insertion small and referential. A future edit to the
surrounding loop is less likely to absorb or orphan a short paragraph than a long one. Five near-identical
paragraphs each restating the convention in their own words would drift apart edit by edit. That is the failure the
rule file exists to prevent, reintroduced one file at a time.

`tdd` and `refactor` also gain an `arguments` key, which they lack today. The other three already have one.

### Phase 4: The two planning skills

`iterative-plan-review`, then `plan-implementation`.

The insertion keeps the same shape as Phase 3, short and pointing at the rule file rather than restating it, for the
same anti-drift reason.

These need something the coding skills do not: a stop contract for a round that produces findings and plan edits rather
than a built artifact. The checkable claims at such a stop are the findings themselves, and what changed is the set of
plan edits the round made
([D-6](artifacts/implementation-decision-log.md#d-6-for-a-review-round-the-findings-are-the-checkable-claims)).

Both cap their rounds by size band, at one to three. A person's redirect at a stop does not consume a round, because a
round is a unit of review work and a redirect is not.

### Phase 5: The routing text

Seven descriptions change: the mode's own, the five flagged skills, and `code-walkthrough`.

**`code-walkthrough` has a budget problem.** The authoring standard holds every description to 1024 characters, which is
a hard cap on the surface where a skill is uploaded rather than listed. The current one runs 955, leaving 69. The clause
it needs, saying it paces you through work that already exists while this mode builds work as it paces you, runs about
twice that. Its description has to be tightened elsewhere to make room.

The others have more headroom: 137 characters for `design-an-api`, 169 for `tdd`, 315 for `refactor`, 482 for
`iterative-plan-review`, and 544 for `plan-implementation`
([D-7](artifacts/implementation-decision-log.md#d-7-code-walkthroughs-description-is-tightened-to-fit-its-boundary-clause)).

### Phase 6: The surfaces and the version bump

Four manifests describe `han-core` and stop being accurate. So do the plugin front door, the plugin index (including its
now-false install description), the skills index, the workflow chains, the project map, six existing long-form skill
docs, and the changelog.

The version bump reaches further than those four. Three plugins gain user-visible behavior, and each one's version
appears in more than one file, so every bump is a multi-file edit in that plugin plus its marketplace entry. Whether the
meta-plugin bumps alongside them is settled in
[D-8](artifacts/implementation-decision-log.md#d-8-three-plugins-bump-and-the-meta-plugin-follows-its-existing-rule).

## How anyone knows it worked

Nothing in this repository can execute a skill's instructions or check that a description routes a request correctly.
That is not a gap in this plan; it is the state of the tooling, and pretending otherwise would be worse than naming it.

So verification splits three ways.

**Seven checks a script can run**, all mechanical and all able to genuinely fail
([D-9](artifacts/implementation-decision-log.md#d-9-seven-mechanical-checks-and-no-prose-snapshot)):

- The foundation plugin still declares no dependency on the two plugins whose skills it calls.
- Every changed description stays under its character budget.
- The rule file resolves from all five consumers.
- The vendored copies match the canonical file byte for byte.
- The four manifests mention the mode.
- The standard skill surfaces exist.
- Each colliding pair names the other in both directions.

**Four procedures a person follows**, written down before the work starts rather than improvised at review:

- Run the five routing phrasings verbatim and record which skill answers.
- Run each flagged skill directly and confirm it still finishes unpaused.
- Run the mode with a backing plugin absent.
- Walk one full session on skill-backed work and one on prose, through at least three stops each, checking each stop
  against the primary flow and the edge-case table in the [specification](./feature-specification.md), which are where
  the behaviors to walk against are written down.

No separate checklist artifact exists, and none is needed while the specification carries them.

**Two things nobody can check before someone uses it**, named rather than faked. The first: whether the sorting test
classifies real future requests the way a person would expect. The second: whether the reversibility call lands on the
pieces people find expensive. The specification rates open-ended work, which is where the sorting test falls through, at
Low confidence, and rates the per-kind units at Medium. The reversibility criterion carries no rating at all, because it
has no source and Phase 1 authors it. No test should claim to settle what the research does not.

The routing procedure is the most consequential of the four. It is the only check on the collision the mode exists to
resolve, and every one of the seven descriptions can steal routing from the others.

## Deferred (YAGNI)

### A snapshot test pinning the current wording of each flagged skill's uninterrupted-run sentence

- **Why deferred:** It would catch a deleted sentence, but the four files it would guard are among the highest-churn in
  the repository, at twenty-two, fifteen, twelve, and eight commits in ninety days. It would fire on routine unrelated
  edits far more often than on a real regression, and a check that raises false alarms gets deleted or ignored. Running
  each skill directly, plus ordinary diff review confirming the flag is additive, covers the same concern.
- **Reopen when:** A flagged skill's default behavior regresses and reaches a release.
- **Source:** R1, `structural-analyst` and `junior-developer` (claim I11).

### A script that detects whether a sibling plugin is installed

- **Why deferred:** No precedent exists. Every availability check in the suite probes for an external command-line tool.
  Nothing anywhere detects another Han plugin, and the install path a probe would look at is not referenced anywhere in
  this repository. The manifest format cannot express the relationship either, since a declared dependency is always
  required and auto-installed. The mode does not need one: it names the backing skill it intends to use in the plan, and
  if the invocation does not resolve it reports that and offers the choice. Reacting is simpler than predicting and
  satisfies the same commitment, which is never to substitute silently
  ([D-10](artifacts/implementation-decision-log.md#d-10-no-detection-script-the-mode-reacts-rather-than-predicts)).
- **Reopen when:** The reactive path proves confusing in real use, or a platform surface for querying installed plugins
  appears.
- **Source:** R1, `junior-developer` and `test-engineer`.

### An automated check that the five routing phrasings land correctly

- **Why deferred:** It needs a harness that can drive a live session, which this repository has never had and which no
  other feature needs. The manual procedure satisfies the same evidence at a fraction of the cost.
- **Reopen when:** A routing regression ships more than once, making the infrastructure cheaper than the failures.
- **Source:** R1, `test-engineer`.

### A validator for whether a description covers what, when, boundary, and breadth

- **Why deferred:** Length and name-presence are mechanical and already covered. Judging whether prose satisfies four
  qualitative components needs semantic judgment no tool here performs, and building one is speculative tooling scoped to
  a single feature.
- **Reopen when:** A description-routing bug ships that ordinary review failed to catch twice.
- **Source:** R1, `test-engineer`.

## Open Items

- **OI-1:** Whether a pairing invocation trips the review-first exception `tdd` and `refactor` already carry. Both gate
  on their plan when the request explicitly asks to review before implementation. An invocation from a mode whose whole
  purpose is reviewing before each unit reads like that trigger. If it fires, the test list exists at plan time for
  those two, and the specification's arrangement for surfacing it at the first stop is unnecessary for them.
  - **Resolves when:** Phase 3 drafts the first flag insertion and the behavior is observed in a live session.
  - **Blocks implementation:** No. It is settled by building the first of the three, and the answer changes one paragraph
    in two skills rather than the design.

## Sources and Plan Records

- **Feature specification:** [feature-specification.md](./feature-specification.md)
- **Specification companions:** [decision log](artifacts/decision-log.md),
  [team findings](artifacts/team-findings.md), [scope boundary](artifacts/scope-boundary.md). No technical-notes file
  exists for this feature.
- **Specification decisions inherited:** D2 (every existing skill keeps its default behavior), D5 (a piece ends where
  the kind of feedback changes), D8 (the feedback record is written down), D10 (five skills gain the flag), D12 (the
  skill lives in `han-core` and its backing skills are optional), D13 (three kinds of work plus a fall-through), D21
  (the invalidated surfaces are part of this work), D22 (the stopping convention is a canonical `han-core` rule file),
  D23 (the skill is named `pairing`). The specification closed with no open items to respect.
- **Decision rationale and rejected alternatives:**
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Team composition and round-by-round history:**
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)

## Recommendation

Ship as planned. One round settled every question that evidence could settle. The one it could not settle was escalated
and answered, and the single open item is non-blocking and resolves inside Phase 3. The one thing to watch is the
mechanic named above as unverified: whether a backing skill can end its turn mid-run and resume under its own
instructions. Phase 3 is deliberately sequenced so that is observed on the lowest-churn skill before the contract
reaches the two hardest ones.
