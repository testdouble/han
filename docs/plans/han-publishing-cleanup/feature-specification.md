# Feature Specification: Han Publishing Cleanup

Source: the "What I would do, in order" section of a cleanup plan for this repository. The seven steps are all retained.
Their execution order differs from the source's listing order, deliberately and with the reason recorded
([D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).

Companion artifacts:

- [Decision log](artifacts/decision-log.md)
- [Team findings](artifacts/team-findings.md) — from planning
- [Review findings](artifacts/review-findings.md) and
  [review iteration history](artifacts/review-iteration-history.md) — from review
- [Technical notes](artifacts/feature-technical-notes.md)

## Channels and targets

The spec stays channel-neutral throughout. This section is the one place the vocabulary is grounded, so the rest of the
document is readable without it.

- **Channel one** — the Claude Code marketplace. Healthy. Nothing here changes what it publishes.
- **Channel two** — the Codex marketplace. The one that has been rotting.
- **A storefront listing** — the per-channel catalogue that says which plugins exist. One per channel, two total.
- **A version record** — a place that states a plugin's published version. There are **three**, not two: each channel
  carries a per-plugin version record, and channel one's storefront listing also carries a version per plugin. Channel
  two's storefront listing carries no version at all
  ([D20](artifacts/decision-log.md#d20-version-agreement-covers-every-record-that-publishes-a-version)).
- **A target** — any of the four files a release must keep current: two storefront listings and two per-plugin version
  records. Channel one's listing is both a listing and a version record, which is why the four targets do not partition
  evenly into "two and two".
- **A plugin** — a directory the suite ships as an installable unit
  ([D19](artifacts/decision-log.md#d19-a-plugin-and-the-targets-it-belongs-in-are-defined-positively)).
- **The bundle** — the meta-plugin that installs the suite in one command. It exists on channel one only. It is
  therefore exempt from the comparison **between** channels, having no channel-two record to disagree with — but it
  publishes a version in **both** of channel one's records, so it is not exempt from their agreement with each other.
  It bumps on every release and its version names the release tag, which makes it the most frequently hand-synced pair
  in the suite rather than the least
  ([D6](artifacts/decision-log.md#d6-the-bundle-is-a-permanently-named-exception-on-the-second-channel)).

## Outcome

Han is published completely and honestly to both of the places it ships to, and no release can quietly stop it being
so.

Concretely, when this work is done:

- Every Han plugin advertised as installable on a channel is actually installable on that channel. Following the
  documented install instructions produces a working install, not an error — reaching people either on merge or at the
  next release, depending on what each channel's client resolves from ([Open item 2](#open-items)).
- People who installed Han on channel two are offered updates again, once the mechanism this rests on is confirmed
  ([T1](artifacts/feature-technical-notes.md#t1-update-availability-on-channel-two-is-decided-by-the-published-version-number),
  [Open item 1](#open-items)).
- Publishing work items to a tracker never loses a work item without saying so.
- Every dependency a plugin declares is one it actually uses, so the declarations can be trusted to answer "what breaks
  if I change this?"
- Every document that describes Han's plugin topology describes the topology that exists.
- **Every document that describes Han's release procedure describes the procedure that exists**, so a contributor
  following the contributor guide is not blocked by the check for doing what the guide told them
  ([D21](artifacts/decision-log.md#d21-the-release-procedure-documents-are-owned-by-the-step-that-falsifies-them)).
- The release process starts from what is really in the repository, brings every target up to date — creating the
  records a plugin is missing, not only reporting them — and stops rather than shipping around a gap it cannot close
  ([D5](artifacts/decision-log.md#d5-the-check-derives-the-plugin-list-from-the-repository),
  [D31](artifacts/decision-log.md#d31-the-release-creates-a-missing-target-at-the-version-it-is-publishing)).
- The rule is enforced where it can be enforced, and the spec says where that is rather than implying it is everywhere.
  A release **refuses to proceed**; a pull request gets a **visible failure a person can still merge past**, because
  nothing in this repository makes a check blocking
  ([T2](artifacts/feature-technical-notes.md#t2-a-pull-request-check-blocks-a-merge-only-where-a-required-status-check-demands-it),
  [D32](artifacts/decision-log.md#d32-the-guarantee-is-stated-per-surface-because-only-the-release-can-refuse)). The
  check is green from the day it lands
  ([D1](artifacts/decision-log.md#d1-the-check-lands-last-because-a-check-that-blocks-everything-gets-disabled)).

## Actors and triggers

| Actor                     | Trigger                                                          | What they need from this feature                                            |
| ------------------------- | ---------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Han maintainer            | Works through the seven steps once                               | Each step lands without breaking the next; the real ordering constraints are stated |
| Han maintainer            | Cuts any future release                                          | The release brings every target up to date, creating what is missing, and refuses to ship around a gap it cannot close |
| Contributor               | Opens a pull request that adds or renames a plugin               | The check tells them what is missing, and the contributor guide already told them the four targets |
| Channel-two installer     | Runs the documented install command for any advertised plugin    | The install succeeds                                                        |
| Channel-two installer     | Has Han installed and expects updates                            | Updates are offered when releases happen                                    |
| Work-items publisher user | Publishes a work-items file to a tracker after using another one | Nothing is dropped without an explicit, loud signal                         |

## Primary flow

Seven steps, executed in the order below. Only some adjacencies are forced; the forced ones are named and the rest are
free ([D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).

The binding constraints are: **the check is last**; **the release repair and the version correction are one unit**;
**the declaration deletion and the document correction are one unit**; and the work-items fix is independent of all of
it.

The first unit is not merely an ordering. The release gate begins refusing releases the moment the release runs the
rule, which is step 3 — not step 7, where the rule merely becomes visible on pull requests
([D14](artifacts/decision-log.md#d14-the-release-runs-the-check-rather-than-restating-it)). Every plugin whose version
records disagree is a gap the gate names, and every plugin but one disagrees until step 4 corrects them. Shipping step 3
without step 4 therefore stops every release in between, which is the same "a blocking rule arrives before the problems
are fixed" failure the check is sequenced last to avoid
([D1](artifacts/decision-log.md#d1-the-check-lands-last-because-a-check-that-blocks-everything-gets-disabled)). The two
steps land together, and the window does not exist
([D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).

### Step 1: Publish the Linear plugin to channel two

_Source position: 1._

The Linear plugin is advertised in channel two's setup instructions and was never published there. Someone following
those instructions gets an error today.

After this step, the Linear plugin appears in channel two's storefront listing and carries its own version record, so
the documented install command succeeds — for users, either on merge or at the next release, depending on what that
channel's client resolves from ([Open item 2](#open-items)). Its new version record is created at the version channel
one already publishes for it, so it is correct on arrival
([D22](artifacts/decision-log.md#d22-the-new-version-record-is-created-at-the-plugins-channel-one-version)).

Correct on arrival is not the same as durable. This step adds a file inside the Linear plugin's own directory, which is
exactly what obliges that plugin to bump at the next release — and until step 3 lands, a release moves the plugin's
channel-one version without touching the channel-two record this step just created. Step 1 manufactures one instance of
the very drift step 4 repairs. The coupling is not dissolved; it is small, and the step 3 and 4 unit heals it along
with the other eight.

This goes first because it is the only step where a person following the project's own instructions hits an error right
now ([D11](artifacts/decision-log.md#d11-step-1-goes-first-because-it-is-a-live-broken-promise)). That reasoning holds
on the assumption that channel two's client resolves from the default branch. If it resolves from the release tag, this
step reaches nobody until the next successful release, which the step 3 and 4 unit gates anyway — and going first buys
ordering clarity rather than a faster fix ([Open item 2](#open-items)).

### Step 2: Close the GitHub publisher's silent hole

_Source position: 2. Independent of every other step._

When the GitHub work-items publisher meets a work item already annotated by a different tracker, that work item is
neither published nor reported as skipped. It disappears from the run with no error and no signal.

After this step, every work item in the file is accounted for in every run: every heading is published,
skipped-and-counted, or surfaced
([D30](artifacts/decision-log.md#d30-accounted-for-is-defined-so-the-promise-is-not-circular)). A work item whose
annotation the publisher does not recognize is surfaced as a format error, and **the run stops before creating anything
at all** — the whole file is examined before the first item is published, so a foreign annotation late in the file cannot
be preceded by items already created
([D3](artifacts/decision-log.md#d3-a-foreign-annotation-stops-the-run-before-anything-is-created)).

The protection lives at every layer that inspects a heading, not only the last one. The publisher's own repair pass
recognizes a foreign annotation as a distinct category that it must not silently repair, so the annotation reaches the
gate rather than being tidied away before it
([D17](artifacts/decision-log.md#d17-the-foreign-annotation-category-exists-at-every-layer-that-inspects-a-heading)).

This step does not change the annotation format and requires no migration
([D2](artifacts/decision-log.md#d2-step-2-closes-the-silent-hole-only-annotation-namespacing-is-separate)). It shares no
actor, artifact, or failure mode with the other six steps and is retained here by explicit instruction rather than by a
dependency ([D23](artifacts/decision-log.md#d23-step-2-is-a-distinct-concern-retained-by-instruction)).

### Step 3: Teach the release process about every target

_Source position: 6. Moved ahead of the version correction, and shipped together with it — see
[D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)._

The release process updates two of the four targets, and takes its list of plugins from one of the targets it also
writes. It therefore cannot detect that the other two have fallen behind, which is why the drift went unnoticed across
eleven releases.

After this step, a release derives the set of plugins from what is actually in the repository
([D5](artifacts/decision-log.md#d5-the-check-derives-the-plugin-list-from-the-repository)) and brings all four targets
up to date.

Bringing a target up to date includes **creating a record that does not exist yet**, not only updating one that has
fallen behind. This distinction is the difference between a release that repairs and a release that merely complains:
today's process can only write a version onto a record already present, so a plugin absent from a target stays absent
no matter how many releases run. A record created this way is written at the version the release is publishing for that
plugin, which for a plugin the release did not bump is the version it already has — so the record arrives correct and
agreeing rather than arriving and then needing a second pass
([D31](artifacts/decision-log.md#d31-the-release-creates-a-missing-target-at-the-version-it-is-publishing)).

A release refuses to proceed when it finds a gap it cannot close: a listing naming a plugin that does not exist, a
record it cannot read, or a version it cannot make sense of. **The gate runs on the state being released — after the
release has brought all four targets up to date, before it asks anyone to approve publishing, and before it commits,
tags, pushes, or publishes anything.** Early enough that every action after it is still local and reversible; late
enough to judge what is actually being released rather than what preceded it; and before the person is asked to
authorize, because a gate that refuses after approval teaches people to distrust it
([D24](artifacts/decision-log.md#d24-the-gate-runs-after-all-targets-are-written-and-before-anything-irreversible)).
When it stops, it names every gap it found rather than the first
([D12](artifacts/decision-log.md#d12-a-missing-plugin-stops-the-release-and-every-gap-is-named)).

This is where the rule starts refusing things. That is why this step and step 4 are one unit: every plugin but one has
version records that disagree until step 4 corrects them, and a gate that is live against nine gaps stops every release
until they are closed.

The release holds no copy of the rule. It runs the check and reports what the check says
([D14](artifacts/decision-log.md#d14-the-release-runs-the-check-rather-than-restating-it)).

This step also corrects the documents that describe the release procedure, because this step is what makes them wrong
([D21](artifacts/decision-log.md#d21-the-release-procedure-documents-are-owned-by-the-step-that-falsifies-them)).

One exception is permanent and named: the bundle cannot be published to channel two, because that channel does not
support bundles. The rule knows this about that one plugin specifically and does not flag its absence, nor ask it to
agree with a channel-two record it does not have. The exception stops there. The bundle publishes a version in both of
channel one's records, so those two are held to agreement like any other plugin's — and more carefully than most, since
the bundle bumps on every release and the release tag is named after its version
([D6](artifacts/decision-log.md#d6-the-bundle-is-a-permanently-named-exception-on-the-second-channel),
[D20](artifacts/decision-log.md#d20-version-agreement-covers-every-record-that-publishes-a-version)).

### Step 4: Correct the frozen version numbers

_Source position: 3. Moved after the release repair, and shipped together with it as one unit._

Channel two's published version numbers have not moved since the day they were created, so that channel never offers
anyone an update
([T1](artifacts/feature-technical-notes.md#t1-update-availability-on-channel-two-is-decided-by-the-published-version-number)).

After this step, each plugin's channel-two version matches the version channel one publishes for that same plugin
([D10](artifacts/decision-log.md#d10-the-two-channels-publish-one-version-per-plugin)).

Because the release process is repaired first, this correction is durable: the very next release keeps it correct
rather than re-freezing it. Had this step come first, any release cut before the repair would have undone it. And
because the repair ships together with this step rather than merely ahead of it, the reverse window does not open
either — the gate never spends a release refusing the disagreements this step is on its way to fix
([D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).

This step closes nine gaps, not eight. Eight plugins carry a channel-two version that has fallen behind; the ninth is
the Linear plugin, whose record step 1 created and whose own arrival obliged it to bump.

### Step 5: Delete the three untrue dependency declarations

_Source position: 4. One unit with step 6._

Three plugins declare that they need the core plugin and never touch it. The reporting plugin's use moved elsewhere and
the declaration was left behind. The feedback plugin and the Linear plugin are not permitted to invoke other plugins at
all, so their declarations cannot be true — neither is granted the means to call one.

The source plan named two. The third was found during review, and it matters beyond arithmetic: the Linear plugin was
the example the tutorial's rewrite planned to point at as a dependency that is real
([D8](artifacts/decision-log.md#d8-the-tutorials-worked-example-repoints-to-surviving-real-edges)). Repointing a lesson
about true dependencies at a false one would have reproduced the defect the rewrite exists to remove.

After this step, the reporting plugin declares only what it uses, and the feedback and Linear plugins declare nothing.
Installing any of them no longer drags in a large plugin the installer will never use, and every remaining declaration
in the suite is one the declaring plugin actually uses
([D13](artifacts/decision-log.md#d13-both-untrue-declarations-are-deleted-rather-than-made-true)).

### Step 6: Correct every document the declaration deletion falsifies

_Source position: 5. Ships together with step 5 — a merged state where the declarations are gone and the documents still
narrate them is the state this step exists to prevent._

The test for inclusion is a rule, not a list: **a document is in scope when this work falsifies it**, and the step that
falsifies it owns it. Not "mentions a plugin", not "narrates topology", not "sits nearby"
([D7](artifacts/decision-log.md#d7-a-document-is-in-scope-when-this-work-falsifies-it)). This step owns the documents the
declaration deletion falsifies. Step 3 already owns the ones the release repair falsifies
([D21](artifacts/decision-log.md#d21-the-release-procedure-documents-are-owned-by-the-step-that-falsifies-them)).

After this step, no document describes a dependency the suite does not have. That includes the contributor guide, the
orientation document new readers are told to read first, the canonical long-form docs for the affected plugins, the
plugin-selection guide, the agent-facing project map, and the tutorial that teaches plugin dependencies. It also
includes one document that already described a topology the suite never had, found while surveying the others
([D9](artifacts/decision-log.md#d9-the-already-false-contributor-claim-is-in-scope)).

The survey behind this step originally ran against a two-plugin premise and must be re-run against the third
declaration step 5 deletes ([F31](artifacts/review-findings.md#f31-han-linear-is-a-third-untrue-dependency-declaration-and-the-specs-own-deferral-trigger-has-already-fired)).
That is not a change to the rule — the rule already reaches those locations — it is the same rule applied to the
corrected set.

**Already-false statements sitting inside passages this work rewrites are corrected; already-false statements elsewhere
are not.** This is the rule the spec was applying without stating: it is why the contributor guide's untrue universal
claim is in scope and why the tutorial's untrue version promise is in scope, while the stale enumerations elsewhere in
the repository stay out
([D33](artifacts/decision-log.md#d33-an-already-false-statement-inside-a-rewritten-passage-is-corrected)). One live
instance is known: the orientation document's description of the bundle's own dependencies omits one of them, is not
falsified by this work, and sits between two lines this step must edit. It is corrected, because the editor is not
merely open — the surrounding sentences are being rewritten.

Manifest descriptions are documents and are in scope. Manifest dependency declarations are the record itself, not a
description of it, and are step 5's business
([D25](artifacts/decision-log.md#d25-manifest-descriptions-are-documents-the-declarations-are-the-record)).

A document making a **universal claim** about the dependency graph states the rule instead and points at the manifests
as the record. Swapping a stale universal claim for a stale enumeration reproduces the same defect with a longer
half-life.

That remedy applies to universal claims and stops there, because there is no rule that generates this suite's
dependency graph. The graph is irregular on purpose: some plugins depend on the core plugin and not the communication
plugin, some on both, some on nothing. A document whose job is to orient a reader — or an agent that reads one map
instead of eleven manifests — legitimately enumerates it, and "go read the manifests" would delete the document's
reason to exist. Those documents **keep the enumeration, drop any hardcoded count, and name the manifests as the
record**. The distinction is between a claim that is wrong because reality is irregular and a listing that is merely
long ([D26](artifacts/decision-log.md#d26-corrected-documents-state-the-rule-and-point-at-the-record)). Dropping the
count follows this repository's convention that indexes are verified complete rather than counted, applied here by
extension rather than by letter.

The tutorial that teaches plugin dependencies by walking through the deleted edges has its worked example repointed at
edges that remain real, keeping its teaching shape
([D8](artifacts/decision-log.md#d8-the-tutorials-worked-example-repoints-to-surviving-real-edges)). The replacement
edge must be one this work leaves standing **and** one that is actually true — the plugin the rewrite originally
planned to point at turned out to carry the third untrue declaration, so repointing there would have taught the lesson
using a counter-example to itself. Its claim to print the real on-disk version numbers is dropped rather than repaired,
because that claim is already false and keeping it would create a maintenance obligation nobody asked for
([D27](artifacts/decision-log.md#d27-the-tutorial-teaches-shape-and-stops-promising-real-version-numbers)).

### Step 7: Turn on the automated check

_Source position: 7. Last, and this is the one hard ordering constraint the source plan argued for._

Only now does the rule become **visible on a pull request**. The rule itself has existed since step 3, because the
release runs it, and it has been refusing releases since then
([D14](artifacts/decision-log.md#d14-the-release-runs-the-check-rather-than-restating-it)). This step puts the same
answer in front of a contributor before a maintainer meets it at release time. It verifies that every plugin in the
repository appears in every target it belongs in, and that a plugin's version records agree.

It runs on every pull request, and additionally on the machines of contributors who have installed the optional local
hooks ([D4](artifacts/decision-log.md#d4-the-check-blocks-on-every-pull-request-and-runs-locally-where-hooks-are-installed)).

**What this step does not do is make the rule blocking, and the spec no longer claims it does.** A pull-request check
prevents a merge only where the hosting platform is configured to require it, and this repository has no such
configuration — the default branch is unprotected and the one ruleset that exists is disabled and carries no
required-check rule, so enabling it would not change the answer either
([T2](artifacts/feature-technical-notes.md#t2-a-pull-request-check-blocks-a-merge-only-where-a-required-status-check-demands-it)).
A red check here is a signal a person can merge past. The surface that actually refuses is the release
([D32](artifacts/decision-log.md#d32-the-guarantee-is-stated-per-surface-because-only-the-release-can-refuse)).

That is worth having on its own terms: it moves the discovery of a gap from release day to the pull request that
introduced it, which is where it is cheapest to fix and where the person who caused it is still holding the context.
Making it genuinely blocking is a change to repository settings that no step here owns, and the spec names that gap
rather than assuming it away ([Open item 3](#open-items)).

Because steps 1 through 6 have already landed, the check is green on the day it arrives and stays green
([D1](artifacts/decision-log.md#d1-the-check-lands-last-because-a-check-that-blocks-everything-gets-disabled)).

There is no disable switch, deliberately
([D28](artifacts/decision-log.md#d28-the-check-ships-with-no-disable-switch)).

## Alternate flows and states

**The rule lands before the problems are fixed.** This is the failure the ordering exists to prevent, and it has two
faces. On the release surface it is real and immediate: the rule starts refusing releases at step 3, so shipping step 3
without step 4 stops every release until the versions are corrected. That is why the two are one unit. On the
pull-request surface the classic version — a correct check that blocks everything on day one until someone disables it
— cannot occur here, because nothing on that surface blocks
([T2](artifacts/feature-technical-notes.md#t2-a-pull-request-check-blocks-a-merge-only-where-a-required-status-check-demands-it)).
The failure mode there is quieter and no less real: a check that is permanently red is a check people learn to scroll
past, and a signal nobody reads protects nothing
([D1](artifacts/decision-log.md#d1-the-check-lands-last-because-a-check-that-blocks-everything-gets-disabled)).

**A release runs while a plugin is missing from a target.** The release creates the missing record at the version it is
publishing for that plugin and proceeds
([D31](artifacts/decision-log.md#d31-the-release-creates-a-missing-target-at-the-version-it-is-publishing)). This is
the ordinary path, not the failure path: the whole point of the repair is that a release closes this gap rather than
reporting it.

**A release meets a gap it cannot close.** A listing naming a plugin that is not in the repository, a record it cannot
read, or a version value it cannot make sense of. The release stops after bringing the targets up to date, before
asking anyone to approve, and before committing
([D24](artifacts/decision-log.md#d24-the-gate-runs-after-all-targets-are-written-and-before-anything-irreversible)),
naming every gap it found rather than the first
([D12](artifacts/decision-log.md#d12-a-missing-plugin-stops-the-release-and-every-gap-is-named)). Nothing is tagged,
pushed, or published. **Recovery is not discarding local changes** — that reproduces the same stop, because the gap is
in the repository and not in the release's uncommitted work. The gap must be corrected and committed, and only then can
the release run again, because a release refuses to start from a dirty tree at all
([D34](artifacts/decision-log.md#d34-a-gate-stop-costs-a-separate-commit-because-the-release-refuses-a-dirty-tree)).

**A release fails partway through writing the four targets.** Every write happens before anything irreversible, so the
repository is left with local modifications and nothing published. Recovery here *is* discarding local changes and
re-running, because nothing in the repository is wrong — only the incomplete local work. No compensation or rollback
machinery is specified because none is needed
([D24](artifacts/decision-log.md#d24-the-gate-runs-after-all-targets-are-written-and-before-anything-irreversible)).

**A work-items run meets a file annotated by a different tracker.** The run stops before creating anything and names the
work items whose annotations it does not recognize, so a person decides whether the file was already published elsewhere
([D3](artifacts/decision-log.md#d3-a-foreign-annotation-stops-the-run-before-anything-is-created)).

**A work-items run meets a file this same tracker already annotated.** Unchanged from today: those items are recognized
as already published, skipped, and reported in the skipped count. A partial run resumes cleanly.

**A new plugin is added after this work.** The check fails visibly on the pull request that adds it, telling the
contributor which targets it is missing from. If they act on it, the plugin arrives complete. If they merge past it —
which they can — the next release creates the missing records itself
([D31](artifacts/decision-log.md#d31-the-release-creates-a-missing-target-at-the-version-it-is-publishing)), so the
signal being advisory costs lateness rather than correctness. The signal is only fair because step 3 corrected the
contributor guide to name all four targets rather than one
([D21](artifacts/decision-log.md#d21-the-release-procedure-documents-are-owned-by-the-step-that-falsifies-them)).

**A release is cut from a branch where a step has not landed.** What stops it is the release's own gate, not a
pull-request check that may never have run — the release process permits cutting from a non-default branch, and a branch
with no pull request gets no pipeline run. This is the general case rather than a corner: the release gate is the only
surface that refuses anything, so it is the only surface a missing step is caught on
([D32](artifacts/decision-log.md#d32-the-guarantee-is-stated-per-surface-because-only-the-release-can-refuse)).

## Edge cases and failure modes

| Case                                                                           | Behavior                                                                                                                                     |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| The bundle is absent from channel two                                          | Not flagged, and the cross-channel comparison does not apply to it ([D6](artifacts/decision-log.md#d6-the-bundle-is-a-permanently-named-exception-on-the-second-channel)) |
| The bundle's two channel-one records disagree with each other                  | Check fails, like any other plugin. The bundle's exemption is from the comparison between channels, not from agreement within one. It bumps every release and its version names the release tag, so this is the most-exercised pair in the suite ([D6](artifacts/decision-log.md#d6-the-bundle-is-a-permanently-named-exception-on-the-second-channel), [D20](artifacts/decision-log.md#d20-version-agreement-covers-every-record-that-publishes-a-version)) |
| A plugin is missing from any target it belongs in, including just one of two channels | A release creates the missing record and proceeds ([D31](artifacts/decision-log.md#d31-the-release-creates-a-missing-target-at-the-version-it-is-publishing)). On a pull request the check reports it, naming the plugin and every target it is missing from. This is the shape of the defect that motivated the work ([D19](artifacts/decision-log.md#d19-a-plugin-and-the-targets-it-belongs-in-are-defined-positively)) |
| A plugin is in a storefront listing but not in the repository                  | Check fails. A listing entry resolving to nothing breaks the install-succeeds promise directly, and it is the one membership gap a release must not "fix" by itself, since the remedy is a person deciding whether the plugin or the entry is the mistake ([D29](artifacts/decision-log.md#d29-a-listing-entry-with-no-plugin-behind-it-fails-the-check)) |
| A plugin's version records disagree                                            | Check fails, naming the plugin and every disagreeing record ([D20](artifacts/decision-log.md#d20-version-agreement-covers-every-record-that-publishes-a-version)) |
| A record cannot be read at all                                                 | Surfaced and blocking, never skipped. A record that fails to parse must not silently drop its plugin from the set being checked — a rule applied to a set that quietly excludes the broken member is the same invisible-by-construction defect this work exists to end ([D35](artifacts/decision-log.md#d35-an-unreadable-record-or-version-is-surfaced-not-skipped)) |
| A record publishes a version, but the value is absent, empty, or not a version | Check fails, naming it, exactly as a disagreement does. Two unreadable values are never treated as agreeing with each other ([D35](artifacts/decision-log.md#d35-an-unreadable-record-or-version-is-surfaced-not-skipped)) |
| A plugin has a manifest and no skills                                          | Valid. The bundle is permanently in this state, so "has skills" is not part of what makes a directory a plugin ([D19](artifacts/decision-log.md#d19-a-plugin-and-the-targets-it-belongs-in-are-defined-positively)) |
| A work item's heading is malformed in any way the publisher does not recognize | Surfaced, never silently passed over. "Accounted for" means every heading is either published, skipped-and-counted, or surfaced ([D30](artifacts/decision-log.md#d30-accounted-for-is-defined-so-the-promise-is-not-circular)) |
| A work-items file mixes annotated and unannotated items for the same tracker   | Unchanged: annotated items skipped and counted, unannotated items published                                                                   |
| Two trackers' annotations are indistinguishable from each other                | Out of scope here; the trap remains and is specified separately ([D2](artifacts/decision-log.md#d2-step-2-closes-the-silent-hole-only-annotation-namespacing-is-separate)) |
| Channel two adds bundle support later                                          | The named exception becomes removable. See [Deferred (YAGNI)](#deferred-yagni)                                                                |

## Coordinations

- **The release process and the repository.** The release reads the set of plugins from the repository rather than from
  a target it also writes, so a stale listing can no longer hide a plugin from it
  ([D5](artifacts/decision-log.md#d5-the-check-derives-the-plugin-list-from-the-repository)).
- **The release process and both storefronts.** The release brings all four targets up to date — creating what is
  missing, updating what is stale — before it does anything irreversible, and before it asks anyone to approve
  ([D24](artifacts/decision-log.md#d24-the-gate-runs-after-all-targets-are-written-and-before-anything-irreversible),
  [D31](artifacts/decision-log.md#d31-the-release-creates-a-missing-target-at-the-version-it-is-publishing)).
- **The check and the release process.** One rule, one bearer. The release runs the check and reports its answer rather
  than restating the rule in its own words, so the two cannot drift
  ([D14](artifacts/decision-log.md#d14-the-release-runs-the-check-rather-than-restating-it)). One consequence is easy
  to miss: because the release runs the rule, the rule is refusing releases from step 3 onward, four steps before it
  appears on a pull request.
- **The check and the pull-request pipeline.** The check runs on every pull request and reports a failure a person can
  merge past, because nothing here makes a check required
  ([T2](artifacts/feature-technical-notes.md#t2-a-pull-request-check-blocks-a-merge-only-where-a-required-status-check-demands-it)).
  Local hooks are optional in this repository, so the local half is a convenience for contributors who opted in. Neither
  surface is a guarantee the feature rests on; the release gate is
  ([D4](artifacts/decision-log.md#d4-the-check-blocks-on-every-pull-request-and-runs-locally-where-hooks-are-installed),
  [D32](artifacts/decision-log.md#d32-the-guarantee-is-stated-per-surface-because-only-the-release-can-refuse)).
- **The three work-items publishers and the shared work-items file.** All three read and annotate the same file. Step 2
  changes only how one of them responds to annotations it does not recognize; it does not change what any of them
  writes.
- **Step 5 and step 6.** They ship together
  ([D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).
  The intermediate state — declarations deleted, documents still narrating them — is exactly what step 6 exists to
  prevent.

## User interactions

The people who experience this feature are maintainers and contributors at a terminal, plus installers on channel two.

- **Check failure.** Names the plugin and every target it is missing from. This is the same commitment as the release
  stop below rather than a second one: the check and the release share one bearer
  ([D14](artifacts/decision-log.md#d14-the-release-runs-the-check-rather-than-restating-it)), so the message a
  contributor sees on a pull request is the message a maintainer sees on a release
  ([D12](artifacts/decision-log.md#d12-a-missing-plugin-stops-the-release-and-every-gap-is-named)). Naming the target is
  possible because "belongs in" is defined rather than left to the exception
  ([D19](artifacts/decision-log.md#d19-a-plugin-and-the-targets-it-belongs-in-are-defined-positively)). The message is
  the same; the consequence is not. On a pull request it informs, and the contributor may proceed anyway. On a release
  it refuses.
- **Release stop.** Names every gap it found before stopping, not just the first one, so a maintainer learns the full set
  in one run ([D12](artifacts/decision-log.md#d12-a-missing-plugin-stops-the-release-and-every-gap-is-named)).
- **Work-items format error.** Names the specific work items whose annotations were not recognized and what they appear
  to be annotated by, so the person can tell "already published to another tracker" from "file is malformed". This
  requires "malformed" to be a detectable category rather than a residue
  ([D30](artifacts/decision-log.md#d30-accounted-for-is-defined-so-the-promise-is-not-circular)).
- **Channel-two installer.** Experiences no interface. They get a working install command and, thereafter, update
  prompts. The absence of an error is the whole user-facing outcome.

## Out of scope

- **Namespacing every tracker's annotations so none can be mistaken for another's.** A real trap with real evidence, but
  the strictly simpler step 2 satisfies the evidence that drove it here
  ([D2](artifacts/decision-log.md#d2-step-2-closes-the-silent-hole-only-annotation-namespacing-is-separate)). It carries
  a format change and a migration for files already in people's repositories, which is a specification of its own.
- **Connecting the planning plugin to the shared writing standard.** Considered, reasoned about, recorded as out of
  scope, challenged in review, and confirmed. Reopening it is a fresh decision made on purpose, not a gap to patch.
- **Declaring the relationship between the planning plugin and the three ticket publishers as a dependency.** Declaring
  a dependency forces an install rather than annotating a relationship, so this would compel every GitHub user to
  install the whole planning plugin to document a connection no code follows. The relationship belongs in the
  documentation.
- **Consolidating the duplicated rule files.** The case for it is stronger than earlier analysis suggested, since a rule
  has already been edited by hand in three places. It is not one of the seven steps and is not blocked by any of them.
- **Changing what channel one publishes.** Channel one is healthy. This work brings channel two up to it.
- **Documents already stale for reasons this work does not touch.** Several enumerations elsewhere in the repository are
  out of date but are not falsified by this work, and no evidence suggests anyone has been misled by them. Fixing them
  because the editor is already open is the symmetry reasoning this spec's own rules reject
  ([D7](artifacts/decision-log.md#d7-a-document-is-in-scope-when-this-work-falsifies-it)). The one exception is narrow
  and stated in step 6: an already-false sentence **inside a passage this work is rewriting anyway** is corrected rather
  than stepped around, because leaving a known-false line in a paragraph you are editing is its own kind of dishonesty
  ([D33](artifacts/decision-log.md#d33-an-already-false-statement-inside-a-rewritten-passage-is-corrected)). Proximity
  to an open editor is not the test; being inside the rewrite is.
- **Agreement between a plugin's own name as recorded on each channel.** Plausible by analogy to the version drift, but
  no instance exists and nothing depends on it today.

## Deferred (YAGNI)

- **A check that every declared dependency is actually used by the declaring plugin.** This would have caught step 5's
  untrue declarations automatically, which makes it tempting — and the temptation grew during review, when a third
  instance was found that the hand survey had missed. That is worth being honest about: the trigger this item originally
  named ("a third decorative dependency is found") **has fired**, and the item is still deferred, because the trigger
  was the wrong test. Finding a third instance by hand is evidence the survey was incomplete, not evidence that a
  standing mechanism is needed. All three are being deleted in step 5, after which the count is zero and the checker
  would guard against a class with no current members. Nobody has asked for it and no incident is attributed to it.
  **Reopening trigger, restated:** a decorative dependency appears *after* step 5 lands — meaning the suite regrows them
  and the deletion did not hold — or a decorative dependency causes a real install or breakage problem. The instances
  this work removes cannot fire it.
- **Designing for channel two gaining bundle support.** The exception is named and permanent today
  ([D6](artifacts/decision-log.md#d6-the-bundle-is-a-permanently-named-exception-on-the-second-channel)). Building a
  configurable exception mechanism for one known exception is speculative. **Reopening trigger:** channel two ships
  bundle support, or a second permanent exception appears.
- **A disable switch for the check.** Deferred deliberately, not overlooked. A disable mechanism is the "land it
  disabled" alternative already rejected, and reversibility already exists: the check lands in one commit, so reverting
  that commit is the escape hatch. **Reopening trigger:** the rule produces its first false positive that stops a
  release which is actually correct. The trigger is worded around the release rather than the pull request because the
  release is the only surface where a false positive costs anything — on a pull request it can be merged past
  ([D28](artifacts/decision-log.md#d28-the-check-ships-with-no-disable-switch)).
- **Monitoring channel two's published state from outside the repository.** No dashboard, no version polling, no alert on
  release deviation. The release gate is the signal, and the drift persisted for eleven releases precisely because
  nothing asked the question at all — not because nobody was watching a graph.
  **Reopening trigger:** drift recurs despite the gate, meaning the gate is asking the wrong question.

## Open items

1. **Whether channel two gates update availability on the published version number is unconfirmed**, and the Outcome's
   update-prompt claim rests on it. This is the one open item with a named cost and a named consequence: verifying costs
   one installed client and one release, and if it is wrong then step 4 is still worth doing but its user-facing claim
   must come out of the Outcome. **Owner: the maintainer, before the Outcome is quoted to anyone.** See
   [T1](artifacts/feature-technical-notes.md#t1-update-availability-on-channel-two-is-decided-by-the-published-version-number).
2. **Which revision each channel's client resolves from** — the default branch or the latest release tag — is unknown
   from inside this repository. If it is the tag, then steps 1 and 4 reach users at the next release rather than on
   merge. Both steps and the Outcome are now worded to hold either way, so this changes when the fix arrives rather than
   whether it works. It also weakens step 1's rationale for going first, without changing the answer. This is the same
   class of unknown as item 1: external client behavior not visible from here.
3. **Nothing makes the pull-request check blocking, and no step in this specification changes that.** This was carried
   as an unknown and is now answered: the default branch is unprotected, no rules apply to it, and the sole ruleset is
   disabled and contains no required-check rule, so enabling it as written would not help
   ([T2](artifacts/feature-technical-notes.md#t2-a-pull-request-check-blocks-a-merge-only-where-a-required-status-check-demands-it)).
   The specification absorbed the answer rather than the question: the guarantee is now stated per surface
   ([D32](artifacts/decision-log.md#d32-the-guarantee-is-stated-per-surface-because-only-the-release-can-refuse)). What
   remains open is a **decision, not a fact** — whether to make the check required, which is a repository-settings
   change no step owns. Worth knowing before deciding: the existing disabled ruleset also demands an approving review,
   which on a solo-maintained repository would block the maintainer from merging their own work, and is the likeliest
   reason it is switched off. Requiring the check alone is the smaller move. **Owner: the maintainer.** Does not block
   any step.
4. **Version compatibility between plugins is an open question this specification does not close.** Plugins are
   installed and updated one at a time, so someone can run a months-old coding plugin against a core plugin updated
   today, and nothing would notice. Earlier analysis argued this could not happen because everything ships from a single
   snapshot; that argument holds only for a fresh install of everything at once, which is not how the suite is used over
   time. The right fix is not obvious. Flagged as a decision the team still owes itself, not as work this specification
   schedules. It is kept here rather than removed for having no dependent step, because unlike the item removed earlier
   in planning it has nowhere else to live: there is no follow-up specification to carry it. An open question with no
   home stays with the document that found it.

## Summary

- **Outcome.** Han publishes completely and honestly to both channels, and no release can quietly stop it being so.
- **Actors.** Han maintainers, contributors, and channel-two installers.
- **Scope.** Seven steps. The check is last; the release repair and the version correction are one unit; the
  declaration deletion and document correction are one unit; the work-items fix is independent.
- **Decisions.** See [decision-log.md](artifacts/decision-log.md).
- **Technical notes.** See [feature-technical-notes.md](artifacts/feature-technical-notes.md).
- **Sub-agents.** Planning: junior-developer, devops-engineer, edge-case-explorer, information-architect — see
  [team-findings.md](artifacts/team-findings.md). Review: junior-developer, adversarial-validator,
  evidence-based-investigator, devops-engineer, edge-case-explorer — see
  [review-findings.md](artifacts/review-findings.md).
- **Key adjustments from planning.** The execution order was changed to close a window that would have undone step 4;
  the gate was given a placement; the check and release were given one bearer instead of two; the document survey was
  restated as a rule and grew by five locations; and a factual error about the number of version records was corrected.
- **Key adjustments from review.** The headline enforcement claim was found to have no bearer and was restated per
  surface — only the release refuses, a pull request merely reports. Steps 3 and 4 became one unit, closing a release
  freeze the reorder had opened. The release gained the ability to create a missing record rather than only report it.
  A third untrue dependency declaration was found. The bundle's version exemption was split, and the release count was
  corrected from "roughly twenty" to eleven.
- **Deferred under YAGNI.** 4.
- **Open items.** 4, of which two are unverified external behaviors, one is a settled fact carrying an unmade decision,
  and one is a real question the team owes itself.

## Review History

- **Review mode:** team.
- **Spec-aware mode:** engaged.
- **Rounds completed:** 1 of a 3-round cap — see
  [artifacts/review-iteration-history.md](artifacts/review-iteration-history.md). **Not stable; another round is
  recommended.**
- **Team composition:**
  - `junior-developer` — required; reframes the spec in plain terms and surfaces hidden assumptions and standards
    conflicts.
  - `adversarial-validator` — required; attacks the evidence, the resolutions the planning pass produced, and the
    ordering argument.
  - `evidence-based-investigator` — included because the spec's foundation is repository-state claims, even though its
    channel-neutral prose contains no file paths.
  - `devops-engineer` — the release gate, the enforcement surface, and the rollout ordering are the spec's spine.
  - `edge-case-explorer` — the failure-mode table and the stop-before-create gate carry the spec's silent-failure
    commitments.
- **Findings raised:** 16 — see [artifacts/review-findings.md](artifacts/review-findings.md). 14 major, 2 minor. By
  resolution source: 4 by user input on surfaced trade-offs, 12 by evidence.
- **YAGNI candidates:** 0 new items raised as `Category: YAGNI candidate`. The planning pass's YAGNI work held up under
  challenge — nothing smuggled back into scope, and all four deferrals carry live triggers. One deferral's trigger was
  found to have already fired and was restated rather than silently left standing ([F31](artifacts/review-findings.md#f31-han-linear-is-a-third-untrue-dependency-declaration-and-the-specs-own-deferral-trigger-has-already-fired)),
  and one kept behavior had its justification replaced after the original evidence was withdrawn
  ([F43](artifacts/review-findings.md#minor-edits)).
- **Assumptions challenged across all passes:** that a red pull-request check blocks a merge (false — nothing here makes
  it blocking); that the rule only starts refusing at step 7 (false — it refuses from step 3, because the release runs
  it); that the repaired release could fix what it found (false — it could only report); that two plugins carried untrue
  dependency declarations (false — three do); that the bundle has nothing to disagree with (false — it publishes a
  version in two records); and that the drift spanned roughly twenty releases (false — eleven).
- **Consolidations made:** steps 3 and 4 became one unit, joining steps 5 and 6, so the binding constraints now name two
  units rather than one unit and one ordering. The check and the release keep one bearer; what changed is that the spec
  now states what that bearer can enforce on each surface.
- **Ambiguities resolved, and how:** what version a created record carries (D31, by extension from what a release
  already writes); which documents state the rule versus keep their enumeration (D26, scoped to the sentence shape it
  was reasoned from); whether an already-false neighbor is corrected (D33, stated once as a rule that generalizes what
  D9 and D27 were already doing); and what happens to a record that cannot be read at all (D35, previously undefined).
- **Technical notes added/edited:** 1 added — see
  [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md).
- **Open items remaining:** 4. None blocks implementation. Items 1 and 2 are external client behaviors that shape how
  outcomes are worded rather than whether steps work ([F35](artifacts/review-findings.md#f35-step-1s-install-succeeds-promise-is-unhedged-against-open-item-2-while-the-parallel-claim-is-hedged)).
  Item 3 is now a settled fact carrying an unmade decision, not an unknown
  ([F28](artifacts/review-findings.md#f28-the-check-cannot-block-a-merge-so-the-outcomes-enforcement-guarantee-has-no-bearer)).
  Item 4 is a question the team owes itself, kept here because it has nowhere else to live
  ([F42](artifacts/review-findings.md#minor-edits)).
