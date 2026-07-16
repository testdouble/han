# Team Findings: Han Publishing Cleanup

Spec: [../feature-specification.md](../feature-specification.md) · Decisions: [decision-log.md](decision-log.md) ·
Technical notes: [feature-technical-notes.md](feature-technical-notes.md)

Feature size: **Medium** — three subsystems (the release pipeline, the work-items publishers, the documentation set),
touches rollout and pipeline gating, no authentication or personal-data surface, no data migration once annotation
namespacing is scoped out (D2).

Review team (4, at the medium cap):

- `han-core:junior-developer` — hidden assumptions, muddied scope, unstated prerequisites.
- `han-core:devops-engineer` — the release pipeline, the gate, rollout ordering, the check's placement.
- `han-core:edge-case-explorer` — the work-items annotation boundary cases and the check's own edges.
- `han-core:information-architect` — the documentation set's correctness and the tutorial's worked example.

Mechanic-focused specialists (structural, behavioral, concurrency, software-architect, system-architect) were
deliberately excluded per the skill's default spec-stage roster.

Every specialist claim cited below was independently verified against the files before the finding was accepted. Three
were verified and **rejected** (F19, F20, F21).

## Major findings

### F1: The execution order is a partial order, and one unforced adjacency hid a real hole

**Raised by:** `junior-developer` (JD-001, JD-003) and `devops-engineer` (DOR-004), independently and convergently.

**Finding.** The spec presented all seven steps as one non-negotiable chain. The source plan's argument for the order is
entirely about the check ("a check that blocks everything on day one gets disabled"), which supports exactly one
constraint: everything before the check. Presenting six other adjacencies as equally load-bearing made the one adjacency
that genuinely bites invisible.

That adjacency: the version correction (source step 3) fixed channel two's versions, but the release repair (source
step 6) is what teaches the release to *write* channel two. Any release cut between them re-freezes what the correction
just fixed, and the check then lands red — the exact outcome the ordering exists to prevent. The plan's own work is the
trigger: deleting the declarations edits two plugin directories, which forces both to bump at the next release.

**Verified.** The release skill contains zero references to the codex manifests or the channel-two listing, so it
provably writes only channel one. The versioning doc's "a child bumps only when its own directory changed" confirms the
declaration deletion forces a bump.

**Resolved by:** user input. Two options were surfaced: state a precondition that no release is cut in the window
(preserves the source's listing order, relies on a promise), or reorder so the repair precedes the correction (closes
the window structurally). The user chose the reorder, consciously overriding the source's listing order.

**Affected decisions:** D18 (new), D1 (rescoped to the check only), D11 (unchanged — step 1 still first)
**Affected tech-notes:** —
**Changed in spec:** Primary flow (reordered and re-annotated with source positions), Summary

### F2: The release gate had no placement, and the natural reading put it after the tag

**Raised by:** `devops-engineer` (DOR-001, DOR-002).

**Finding.** The spec said the release "stops before publishing anything". In the release skill's own vocabulary,
"publish" names its final step — so the sentence permitted stopping *after* the tag was already pushed, which is the
irreversible act the decision was meant to avoid. Worse, a pre-flight gate cannot check version agreement at all: at
release start the versions agree, and the release itself is what breaks the agreement when it writes the new channel-one
version. A gate that runs before the writes passes trivially and says nothing about the state being released.

**Verified.** The release skill's irreversible actions are the tag push and the release creation; all target writes
happen earlier, and the skill already hard-stops on a dirty working tree with the reasoning "a pushed tag is hard to
reverse".

**Resolved by:** evidence. One gate, placed after all four targets are written and before the commit — late enough to
judge the state actually being released, early enough that everything after it is local and reversible. The
devops-engineer's suggested pre-flight membership check was **not** adopted: it is ergonomics, not correctness, and the
single gate satisfies both halves of the rule.

**Affected decisions:** D24 (new), D12 (evidence corrected — see F15)
**Affected tech-notes:** —
**Changed in spec:** Primary flow (Step 3), Alternate flows and states, Edge cases

### F3: "Share one answer" was a wish with no bearer

**Raised by:** `devops-engineer` (DOR-003) and `junior-developer` (JD-007), convergently.

**Finding.** The spec said the check and the release "must answer it identically". Nothing enforced it and nothing would
detect when it stopped being true. This matters more than ordinary duplication: the root cause being fixed *is* an
unverified prose instruction telling an agent to read the wrong file for twenty releases. Rewriting that prose to read
four files instead of two leaves the same defect class in place, now with more files to forget, and puts the bundle
exception in two places.

The junior-developer added the sharper form: if the rule is shared, it must exist when the release repair lands — one
step before "only now does the check land". So either the rule lands early and the last step is just making it blocking,
or the rule is written twice and the decision is violated by the plan's own sequence.

**Resolved by:** evidence. The release holds no copy of the rule; it runs the check and reports what the check says. The
rule therefore lands with the release repair, and the last step makes it *blocking* rather than bringing it into
existence. The spec now says this explicitly.

**Affected decisions:** D14 (rewritten), D1 (rescoped: "the check lands last" is about enforcement, not existence)
**Affected tech-notes:** —
**Changed in spec:** Primary flow (Steps 3 and 7), Coordinations

### F4: The spec mis-stated the number of version records

**Raised by:** `devops-engineer` (DOR-005) and `information-architect` (F11), convergently.

**Finding.** The spec said the release updates "two version records and two storefront listings". Verified false on
disk: channel one's storefront listing *also* carries a version per plugin, so there are **three** version records, not
two. And channel two's storefront listing carries no version field at all, so the version-agreement rule has no meaning
for it. The four targets do not partition into "two and two"; one target is both a listing and a version record.

The mechanism is worth naming: the spec's channel-neutral vocabulary is correct and disciplined, but the euphemism is
what let a factual miscount survive drafting. The remedy is a more accurate abstraction, not file paths in the spec.

**Resolved by:** evidence. The version-agreement rule now covers every record that publishes a version, and listing
membership covers both storefronts. A "Channels and targets" section grounds the vocabulary once.

**Affected decisions:** D20 (new)
**Affected tech-notes:** —
**Changed in spec:** Channels and targets (new section), Coordinations, Edge cases

### F5: "Plugin" and "belongs in" were undefined, and they are the shared rule

**Raised by:** `junior-developer` (JD-009), `devops-engineer` (DOR-006), and `edge-case-explorer` (Q3), convergently.

**Finding.** The spec committed to deriving the plugin list from the repository without saying what makes a directory a
plugin, and defined "belongs in" only by subtraction from its one exception. Two edge-case rows depended on the missing
definition. If the rule were "has a channel-one manifest", a plugin published only to channel two would be invisible —
today's bug mirrored onto the other channel. An ambiguous question cannot have one answer, which undercuts F3's fix.

The edge-case-explorer added the constraint that settles it: the bundle has a manifest and **no skills at all**,
permanently and legitimately. So "has skills" cannot be part of the rule.

**Resolved by:** evidence. Stated positively: a plugin is a directory the suite ships as an installable unit; every
plugin belongs in all four targets except the bundle, which belongs only in channel one's. Detection is left to the
implementation plan.

**Affected decisions:** D19 (new), D6 (extended to exempt the bundle from version agreement too)
**Affected tech-notes:** —
**Changed in spec:** Channels and targets, Primary flow (Step 3), Edge cases

### F6: The Outcome stated as fact what the technical note flags as unverified

**Raised by:** `junior-developer` (JD-010) and `devops-engineer` (DOR-007), convergently.

**Finding.** The Outcome asserted flatly that channel-two users "are offered updates again", citing T1 — the very note
that labels itself a single-source provided claim, records that no independent confirmation was obtained, and says
verification is "worth doing before the spec's outcome is quoted to anyone". The citation made the Outcome look
supported by the note that undermines it. Worse, T1's named verification action was owned by no step and no open item,
despite being the only unknown in the document with a named cost and a named consequence.

**Resolved by:** evidence, and the evidence improved. A codebase source was found that corroborates the mechanism class:
the versioning doc describes the version field as what a channel uses "to detect that updates are available". That is
about channel one, so it raises T1 from single-source-provided to provided-plus-corroborated-by-analogy, but it does not
confirm channel two. The Outcome is now hedged and points at the open item; T1 carries the corroboration and its
limits; verification is Open item 1 with a named owner.

**Affected decisions:** D10 (unaffected — it stands on its own evidence)
**Affected tech-notes:** T1 (evidence upgraded, limits stated)
**Changed in spec:** Outcome, Primary flow (Step 4), Open items

### F7: Step 2's guarantee was circular, and its protection was at the wrong layer

**Raised by:** `edge-case-explorer` (Q1, Q2), with `junior-developer` (JD-014) reaching the circularity independently.

**Finding.** Three distinct problems:

1. **Circular promise.** "Every work item is accounted for" — but a work item is *defined* as a heading matching a
   recognized pattern. So the promise reduced to "every item we recognize is accounted for", which was already true.
   Malformed headings (a plain hyphen instead of the em-dash separator, a lowercase prefix, a missing ID) still vanish.
   The hyphen case is highly plausible: the em-dash needs a special input method and most copy-paste produces a hyphen.
   The publisher's own skill already lists "Malformed heading" as an expected finding, so this is not hypothetical.
2. **All-or-nothing was ambiguous, and the natural implementation violates it.** The create loop re-scans from the top
   each iteration for the first unannotated heading. The natural extension — detect the foreign shape when the scan
   reaches it — would create every item *before* it and then halt, contradicting "stops before creating anything".
   Real GitHub issues would exist.
3. **The protection was specified one layer too low.** The real user path runs the skill's prose-driven repair pass
   *before* the script. That pass recognizes exactly two valid shapes and would bucket a foreign annotation as a generic
   "Malformed heading", route it to "propose the corrected shape", and potentially strip or reformat it — defeating the
   gate before the script ever sees it. The fix would have protected only direct script invocation, not the documented
   workflow.

**Resolved by:** evidence on all three. The whole file is examined before the first item is published; "accounted for"
is defined so every heading is published, skipped-and-counted, or surfaced; and the foreign-annotation category exists
at every layer that inspects a heading, not only the last.

**Affected decisions:** D3 (strengthened), D17 (rewritten), D30 (new)
**Affected tech-notes:** —
**Changed in spec:** Primary flow (Step 2), Edge cases, User interactions

### F8: The document survey was incomplete, and the charter was drawn in the wrong place

**Raised by:** `information-architect` (F1–F5, F8) and `junior-developer` (JD-005), convergently on the charter.

**Finding, part one — five verified misses.** The survey behind D7 found seven locations. Five more exist, every one
verified verbatim:

- The orientation document new readers are told to read first narrates **both** deleted edges ("Each of these four
  depends on `han-core`"; "Each of these three depends on `han-core` like the other layers"). The survey skipped the
  most-read document in the set.
- The canonical long-form doc for the feedback plugin promises the install "pulls `han-core` along the way" — a claim a
  reader will act on and see contradicted by the install output.
- A second sentence in the choosing guide ("Both pull `han-core` along the same way the other layers do") — the survey
  named only one sentence in that file.
- The line *after* the contributor-guide claim already in scope is independently false and more dangerous: it tells a
  contributor that the feedback plugin "may dispatch any `han-core` agent freely", which it structurally cannot.
- The versioning doc's reasoning that the single suite tag suffices rests partly on the feedback plugin's dependency
  array, which after step 5 does not exist.

**Finding, part two — the charter.** The junior-developer found that the release repair and the check falsify two *more*
documents that step 6's charter never covered: the contributor guide tells someone adding a plugin to update one of four
targets, and the versioning doc instructs syncing to one listing with zero mentions of channel two. The
information-architect located the gap more precisely: it is not step 6's charter that is too narrow, it is the
**Outcome** that has no bullet for the release procedure. Widening step 6 would make it a grab-bag of two unrelated jobs
sequenced against step 5 when half of it depends on the release repair.

**Verified.** All five misses confirmed verbatim. The versioning doc contains zero occurrences of the word "codex".

**Resolved by:** evidence. Step 6's scope is now a **rule** — a document is in scope when this work falsifies it — not a
list. A second Outcome bullet was added for the release procedure, and those documents are owned by the step that
falsifies them (the release repair), not by the document-correction step.

**Affected decisions:** D7 (restated as a rule), D9 (extended and its rationale re-grounded), D21 (new)
**Affected tech-notes:** —
**Changed in spec:** Outcome (new bullet), Primary flow (Steps 3 and 6)

### F9: The tutorial's honesty contract is broken, and repointing alone makes it worse

**Raised by:** `information-architect` (F6, F7).

**Finding.** D8's evidence cited the tutorial's "The versions in this guide are the versions on disk" as proof it is
grounded in the real suite. That sentence is false: every number it names is wrong (it claims four plugins at 1.0.0 and
the bundle at 3.0.0; they are at 2.2.1, 2.2.2, 2.1.1, 2.0.0, and 4.6.0). So D8 used a broken promise as the reason to
keep real plugin names — and the plan would have repointed the *names* in that very paragraph while leaving the
*promise* standing. An untouched lie is a bug; a lie a maintainer edited around and left is a signal the doc is
unmaintained.

It fails a second way: the manifest the tutorial prints for the reporting plugin is *already* wrong in the opposite
direction from step 5, and substituting the coding plugin reproduces the identical falsehood with a new name, because
both really declare two dependencies rather than one.

**Verified.** All five version numbers confirmed wrong. The reporting plugin really declares two dependencies. **But the
sentence carries its own escape hatch** — "If you are reading the manifests and the numbers differ, the manifests are
right; this guide is describing the shape, not pinning the numbers" — which the finding did not quote. That makes the
document self-defusing and downgrades this from the "most-false line" the finding called it. It also settles the fix:
the doc already argues for its own answer.

**Resolved by:** evidence. The version promise is dropped and the existing shape caveat covers the document. The
information-architect's alternative (print the real manifests and sync every release) was rejected as a maintenance
obligation nobody asked for — the finding itself flagged that option as a YAGNI candidate.

D8's *outcome* survives intact: the substitution works. The information-architect verified the Linear plugin is a
structural identity for the feedback plugin's pedagogical role, and set aside its own channel-two concern (the tutorial
never mentions channel two, and step 1 publishes the Linear plugin there before step 6 runs anyway).

**Affected decisions:** D8 (rationale corrected), D27 (new)
**Affected tech-notes:** —
**Changed in spec:** Primary flow (Step 6)

### F10: The obvious fix reproduces the defect being fixed

**Raised by:** `information-architect` (F9).

**Finding.** The contributor-guide claim in scope fails as a **universal quantifier that outlived its truth**. The
obvious fix — swap it for an enumeration — has the same half-life: it is false the day someone adds a plugin, and
nothing in the repository will notice. That is precisely the standing-defect shape diagnosed in the release process,
relocated into prose. Separately, the orientation document carries two hardcoded counts ("these four", "these three") in
the very passages step 6 must edit, and this repository's own convention is that indexes stay complete, not counted.

**Resolved by:** evidence. Corrected documents state the dependency **rule** and point at the manifests as the record,
rather than restating manifest contents in prose. The orientation document's counts go with them.

**Affected decisions:** D26 (new), D9 (rationale re-grounded on "it is false and contributors read it" rather than "the
editor is already open", which would license exactly the sweep the finding warns about)
**Affected tech-notes:** —
**Changed in spec:** Primary flow (Step 6)

### F11: The circular edge case, and the local hooks that are opt-in

**Raised by:** `junior-developer` (JD-006, JD-015) and `devops-engineer` (DOR-011), convergently.

**Finding.** Two related overclaims:

1. The spec said the check "runs both before a commit lands and on every pull request", and that a contributor
   therefore learns while still working. Verified false: the contributor guide says "**If you want** pre-commit hooks,
   run `npx prek install`". Hooks are opt-in and not installed by default, so for everyone else the check is
   pipeline-only — the option D4 explicitly rejected as "the slower loop".
2. The edge-case row answering "a release is cut from a branch where a step has not landed" answered it with "the check
   has already failed on that branch's pull request". Circular: during the whole window the order governs, the check
   does not exist. And the release skill explicitly permits cutting from a non-default branch, while the pipeline only
   runs on pull requests and pushes to the default branch — so a branch with no pull request gets no run at all. This
   was the row that would otherwise have caught F1.

The actors table's promise that the order is "stated and enforced" was the same overclaim: nothing enforces it.

**Resolved by:** evidence. The check blocks on every pull request; the local half is named as a convenience for
contributors who opted in. The edge-case row now says what actually stops that release: the release's own gate. This
also removes the argument that the release-side gate is redundant with the pipeline — it is not. The pipeline protects
the default branch after the fact; the gate protects the pre-tag moment.

**Affected decisions:** D4 (rewritten), D24
**Affected tech-notes:** —
**Changed in spec:** Actors and triggers, Primary flow (Step 7), Alternate flows and states, Coordinations

### F12: Step 2 shares nothing with the other six steps

**Raised by:** `junior-developer` (JD-002).

**Finding.** The Outcome's third bullet uses a different verb than its heading. One is Han-the-product being published
to marketplaces; the other is a user's work-items file being published to an issue tracker. Step 2 shares no actor, no
artifact, no target, no failure mode, and no code with any other step. The check does not check it; the release does not
touch it. No decision argued for its inclusion — and the folder-naming decision argues the other way, naming the folder
for the publishing pipeline "because that is the actual problem". The only justification was provenance: the source plan
listed it. That is inheritance, not evidence.

**Resolved by:** user input. All seven steps are retained by explicit instruction. The spec now records the seam
honestly rather than manufacturing a coupling: step 2 is named as a distinct concern, independently schedulable, kept
here because it was asked for. The finding's third option — argue the coupling is real — was rejected outright as the
kind of reasoning this spec's YAGNI rule exists to catch.

**Affected decisions:** D23 (new)
**Affected tech-notes:** —
**Changed in spec:** Primary flow (Step 2)

### F13: The new version record had no stated value, and it was the one real inter-step coupling

**Raised by:** `junior-developer` (JD-004).

**Finding.** Step 1 creates a channel-two version record for the Linear plugin and the spec never said what version it
gets. The choice determines whether the step-1-to-step-4 dependency exists at all: set it to the plugin's channel-one
version and step 4 never touches it; set it to a "matching the other codex manifests" value and step 1 has deliberately
introduced a defect for step 4 to repair. This was the single most concrete inter-step coupling in the plan, and it was
the one the spec did not mention while asserting six couplings it did not have.

**Resolved by:** evidence. The record is created at the plugin's channel-one version, which follows directly from the
one-version-per-plugin decision and dissolves the coupling.

**Affected decisions:** D22 (new)
**Affected tech-notes:** —
**Changed in spec:** Primary flow (Step 1)

### F14: The spec was unreadable without artifacts a reader does not have

**Raised by:** `junior-developer` (JD-008).

**Finding.** "The first channel", "the second channel", "storefront listing", "package manifest", "target" — none were
ever defined. The spec never named the two products, never said what the four targets were, and its only resolving link
was an artifact URL that resolves for approximately one person. The reviewer had to be told the mapping in its brief; a
reader coming to the file cold could not construct it. "The release updates all four targets rather than two" is
unactionable to anyone who cannot enumerate the four.

**Resolved by:** evidence. A "Channels and targets" section grounds the vocabulary once, at the top, naming the two
products and describing the four targets behaviorally. Everything downstream stays channel-neutral and becomes readable.
No file paths entered the spec; they remain in this log and the decision log where they belong.

**Affected decisions:** —
**Affected tech-notes:** —
**Changed in spec:** Channels and targets (new section), header

## Minor edits

- **F15:** The release-stop "names every gap" behavior cited evidence that steps 1 and 4 retire — by the time the
  behavior exists, the multi-gap state it cited is fixed. Better evidence existed and was not cited: one omitted new
  plugin produces three simultaneous gaps, which is the routine case. — `junior-developer` (JD-012) — D12's evidence
  swapped; behavior unchanged.
- **F16:** The listing-without-a-plugin edge case was the only row in the table with no decision citation, justified
  solely by "the same class of defect" — the symmetry anti-pattern verbatim. The behavior is right and real evidence
  exists (this repository has already renamed every plugin directory in one commit, mechanically identical to
  delete-old-path-add-new; and a listing entry resolving to nothing breaks the install-succeeds promise directly). —
  `junior-developer` (JD-013) and `edge-case-explorer` (Q4) — kept, promoted to D29 with its real evidence.
- **F17:** "Not only the two the source plan named" is provenance about the source artifact, not behavior. A reader
  cannot act on it, and it implicitly certified a survey that F8 proved incomplete. — `information-architect` (F10) —
  removed from the spec; the enumeration lives in D7.
- **F18:** The bundle-support edge case pointed at "an open item" but the entry is correctly in Deferred (YAGNI). —
  `junior-developer` (JD-017) — repointed.
- **F22:** Open item 3 (blast radius of a format change on files in people's repositories) said of itself that it
  "matters to the deferred namespacing work, not to step 2" — by its own admission it belongs to a spec that does not
  exist yet. — `junior-developer` — removed from this spec's open items; it travels with the namespacing work.
- **F23:** The partial-failure behavior across the four targets was unstated, but the fix is one sentence, not rollback
  machinery: every write happens before anything irreversible, which is the same sentence the gate placement needed. —
  `devops-engineer` (DOR-008) — added to Alternate flows; folded into D24, which carries the same sentence.
- **F24:** No kill switch is specified for the check, and none should be. Building one is the "land it disabled"
  alternative already rejected; reverting the single commit is the escape hatch. Recorded so the implementation plan
  does not add one. — `devops-engineer` (DOR-009) — D28 added; recorded in Deferred (YAGNI) as a deliberate
  non-decision.
- **F25:** No speculative operational machinery was proposed and none should be. Recorded so the boundary is not crossed
  during implementation. — `devops-engineer` (DOR-010) — added to Deferred (YAGNI).
- **F26:** "A plugin exists in the repository but in no storefront listing", read literally, means absent from *both* —
  which is not the shape of the bug that motivated the work (present in one channel, absent from the other). —
  `edge-case-explorer` (Q3) — row reworded to "missing from any target it belongs in, including just one of two
  channels", against D19's positive definition.
- **F27:** The spec never said whether manifest descriptions count as documents. The sweep came back clean so it costs
  nothing today, but the next person running the rule needs to know. — `information-architect` (F14) — D25 added.

## Findings verified and rejected

- **F19: "The tutorial's version claim is the most-false line in the document."** — `information-architect` (F6). The
  five version numbers are indeed all wrong, and the finding's *conclusion* was adopted. But the finding did not quote
  the sentence's second half, which explicitly anticipates divergence: "If you are reading the manifests and the numbers
  differ, the manifests are right; this guide is describing the shape, not pinning the numbers." The document defuses
  its own claim. The severity was overstated; the remedy (drop the promise, keep the caveat) was right and is adopted as
  D27.
- **F20: Jira and Linear may create duplicate tickets for work already published to GitHub.** —
  `edge-case-explorer` (Q2), rated High. Verified as real and correctly reasoned: a GitHub-shaped annotation matches
  neither tracker's already-published pattern, and the Linear format doc's "any other form is unannotated and eligible
  for creation" is explicit. Surfaced to the user with the evidence and the mitigation (both skills carry a human
  confirmation gate before creating). **The user ruled it out of scope and directed that it not be recorded as a spec
  commitment.** Noted here for traceability only; it is not an open item and no step addresses it.
- **F21: A pre-flight membership check should run before the release does its work.** — `devops-engineer` (DOR-002,
  offered as P1 and explicitly marked ergonomic rather than correctness-driven). Not adopted: the single gate at D24
  satisfies both halves of the rule, and the finding itself says "do not add it in step 6". Recorded so it is not
  rediscovered.
