# Team Findings: Per-Plugin Release Tags

Findings from the review round, and how each was resolved. Behavioral outcomes live in
[../feature-specification.md](../feature-specification.md), the decisions they affected live in
[decision-log.md](decision-log.md), and the load-bearing mechanics live in
[feature-technical-notes.md](feature-technical-notes.md).

Feature size: **small** (a single skill and its two reference files, no cross-service integration, no data migration, no
auth or PII surface). Team cap: 2.

Reviewers: `han-core:junior-developer` (identifiers `JD-###`) and `han-core:devops-engineer` (identifiers `DOR-#`).

Both reviewers converged on the same structural problem from different directions: the draft treated tagging as an
isolated step, when in fact the previous tag feeds the version plan, and thirteen sequential pushes create states no
single failure row described. Four findings were raised by both.

## Major findings

### F1: The release commit's push is unplaced, and the tags can outrun it

- **Agent:** junior-developer, devops-engineer
- **Reviewer identifiers:** JD-003, DOR-1
- **Finding:** The draft's flow committed the version bumps and then pushed thirteen tags, never saying when the branch
  itself reaches GitHub. Today that push is one line ahead of the tag push. Pushing a tag transfers the commit it
  reaches, so GitHub can hold thirteen permanent tags pointing at a commit no branch contains. `han-v5.0.0-alpha-1` is
  a non-default branch, which the skill treats as a non-blocking note written when a bad release cost one tag.
- **Resolution:** The specification now places the branch push before the first tag push and stops the run when the
  branch push fails. The approval stop names the branch and the commit the tags will point at. The non-default-branch
  note stays non-blocking, because refusing would block the release this change ships in, but the stop now states
  plainly that the tags will point at a commit on that branch.
- **Resolved by:** evidence
- **Affected decisions:** D6, D9, D14
- **Affected tech-notes:** T4
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes, User Interactions, Coordinations, Deferred (YAGNI)

### F2: Re-running after a failed push reports success while tags are missing from GitHub

- **Agent:** devops-engineer
- **Reviewer identifiers:** DOR-2
- **Finding:** The skip path was defined by a local condition. After a push fails, the local tag exists. Re-running the
  release, which is the likelier operator response than hand-pushing, sees every remaining tag as "already tagged",
  reaches the end clean, and publishes. The closing report claims tags are present that exist only on the maintainer's
  machine. This produces exactly the state D9's rationale exists to prevent.
- **Verification:** Confirmed by mechanism. `claude plugin tag --push` against a remote that already holds the tag
  leaves the local tag in place and exits 1 (observed message: `Tag created locally but push failed`). A re-run then
  meets the local already-exists refusal instead of retrying the push.
- **Resolution:** The specification now separates two states the draft merged: a tag confirmed on GitHub at the release
  commit (skip, benign) and a tag present only locally (must reach GitHub before the run may publish). The run does not
  publish while any plugin is in the second state.
- **Resolved by:** evidence
- **Affected decisions:** D5, D9
- **Affected tech-notes:** T2, T4
- **Changed in spec:** Alternate Flows and States, Edge Cases and Failure Modes, Primary Flow

### F3: Every stop condition fired after the run had already made permanent changes

- **Agent:** junior-developer, devops-engineer
- **Reviewer identifiers:** JD-005, DOR-3
- **Finding:** The version-disagreement check and the clean-tree check both live inside the per-plugin tagging step, so
  they fire mid-walk. `han` is first in the marketplace list, so a disagreement found at the ninth plugin stops a run
  that has already committed the bumps and pushed eight permanent tags including the parent's. The fix for a
  disagreement needs a new commit, and the pushed tags cannot follow it. The recovery D9 promised does not apply, since
  nothing is waiting to be pushed. A disagreement is reachable without any bug: an unchanged plugin can carry drift from
  an earlier merge, and the version-application step only touches plugins whose target differs from current.
- **Verification:** The check's non-mutating form was run during the interview, and again during synthesis at Claude
  Code 2.1.221 in an isolated clone, where it refused both a dirty plugin folder and a version disagreement without
  creating a tag. Validating the whole set ahead of the commit is feasible.
- **Resolution:** The specification now validates every plugin before the release commit exists. A disagreement stops
  the run while nothing has been written and nothing pushed. The mid-walk refusals remain specified, reclassified as
  unexpected rather than routine.
- **Resolved by:** evidence
- **Affected decisions:** D6, D14
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F4: The previous tag supplies the parent's baseline version, not only the commit range

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-001
- **Finding:** The draft treated the previous tag as a range endpoint. It is also the parent's version baseline, derived
  by stripping a leading `v` from the tag. Once the previous tag is `han--v5.0.0`, that derivation yields the whole tag
  string unchanged, and the version comparison that chooses between using the manifest version as-is and computing a
  bump becomes meaningless. The parent's proposed bump, that branch choice, and the under-bump advisory all read the
  corrupted value. This corrupts the version plan silently on the **second** release under the new naming, not the
  first.
- **Verification:** Confirmed in the skill: the previous tag is defined as "the number without the leading `v`", and the
  parent's baseline is set to that value.
- **Resolution:** The specification now states that the previous tag supplies the parent's baseline version as well as
  the range, and commits to reading the version out of a tag under either naming. D7 was rewritten and T3 extended.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** T3
- **Changed in spec:** What Changes and What Does Not, Primary Flow, Alternate Flows and States, Edge Cases and Failure
  Modes, Out of Scope

### F5: "Everything before the tagging part stays as it is" was untrue

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-002
- **Finding:** The Primary Flow's opening paragraph claimed a narrow blast radius that its own numbered steps
  contradicted two lines later. At least six steps change: the prerequisite check, the previous-release lookup, the
  version baseline (F4), the changelog's pinned link, the tag push, and the release keying. The omitted ones are where
  the release silently produces a dead link rather than failing loudly.
- **Resolution:** The paragraph was replaced with a plain statement of what changes and what does not.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, What Changes and What Does Not

### F6: The tag-approval affordance rests on a gate that will not fire on this release

- **Agent:** junior-developer, devops-engineer
- **Reviewer identifiers:** JD-004, DOR-6
- **Finding:** The draft hung tag approval on the existing version-plan confirmation, which prompts only when a plugin's
  version still needs computing. Every plugin is currently ahead of its baseline or new, so zero need confirmation and
  the gate does not fire. The unconditional preview is a print, and its pause is opt-in and defaults off. On the default
  invocation this release pushes thirteen permanent tags having asked nothing. That was defensible when a bad run cost
  one deletable tag.
- **Verification:** Confirmed against `v4.6.0`: every plugin is strictly ahead (`han` 4.6.0 to 5.0.0, `han-core` 2.2.1
  to 3.0.0, and so on) or newly introduced. Zero need confirmation.
- **Resolution:** Escalated to the operator as E1. See the escalation register.
- **Resolved by:** user input
- **Affected decisions:** D15
- **Affected tech-notes:** —
- **Changed in spec:** What Changes and What Does Not, Primary Flow, Edge Cases and Failure Modes, User Interactions

### F7: A tag on GitHub but not locally is undetected, and the committed recovery is wrong for it

- **Agent:** devops-engineer
- **Reviewer identifiers:** DOR-4
- **Finding:** The artifacts contradicted each other. D5 claimed the tagging command checks remote state the local tag
  list does not know about; T2 observed that its refusal message says "already exists locally" and warned it does not
  confirm anything about GitHub. Whichever is right decides whether this state has a behavior at all.
- **Verification:** T2 was right and D5 was wrong. In an isolated clone with the tag present on the remote and absent
  locally, the command planned the tag with no objection. Pushing it against a remote tag at a different commit failed
  with `! [rejected] ... (already exists)` and left a divergent local tag behind, after which a re-run meets the local
  already-exists refusal and never retries. The run can be permanently stuck. D5's claim was an unevidenced assertion
  written during the interview and has been corrected.
- **Resolution:** D5's false evidence line was removed. The specification gained a failure row for a tag already on
  GitHub at a different commit, stating that the run stops, names both commits, and says plainly that pushing is not the
  recovery. The run now refreshes its view of GitHub's tags before the walk.
- **Resolved by:** evidence
- **Affected decisions:** D5, D7, D10
- **Affected tech-notes:** T2, T4
- **Changed in spec:** Edge Cases and Failure Modes, Primary Flow

### F8: Two links name a git ref, not one, and the transition release's comparison link spans both schemes

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-006
- **Finding:** The Out of Scope section said only the pinned changelog link changes; D8 said two links change. The
  comparison link between releases also embeds a ref, and on the transition release its left side is `v4.6.0` and its
  right side is `han--v5.0.0`. A mixed-scheme comparison link is correct and works, but nobody had said so, and an
  implementer reading the spec alone would leave it pointing at a ref that never gets created.
- **Resolution:** The specification now names both links as changing, in the change list and in Out of Scope. The
  transition-release form the links take is stated in D8, where the refs belong.
- **Resolved by:** evidence
- **Affected decisions:** D8
- **Affected tech-notes:** —
- **Changed in spec:** What Changes and What Does Not, Out of Scope

### F9: Both reference files assert things that become false, and the release title's behavior appeared only in the decision log

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-007
- **Finding:** One reference file states that the tag and the body title are both the plain version; the other calls that
  version "the version the git tag tracks". Both become untrue. Separately, D2 decided the release title stays `v5.0.0`
  while the tag becomes `han--v5.0.0`, and the spec body never stated that split, though it is what a person sees on the
  releases page.
- **Resolution:** The release title's behavior moved into the Outcome. The Out of Scope bullet was narrowed so it no
  longer reads as shielding the two false statements, which are now named as changing.
- **Resolved by:** evidence
- **Affected decisions:** D2, D8
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, Out of Scope

### F10: The versioning guide correction was promised a flag it never got

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-008
- **Finding:** D12 commits to correcting the repository's versioning guide, whose note currently says Han does not need
  per-plugin tags and that the single suite tag is sufficient. D12's own rejected alternative promised the operator a
  flag in the closing summary so they could cut it. The spec's Summary carried no such flag, and the spec stated no
  behavior for the edit at all, so the promise lived only in the artifact the operator is least likely to open.
- **Resolution:** The correction is named in the specification rather than only in the decision log, and the judgment
  call is surfaced in the closing summary as D12 promised. The guide is inside the operator's narrowing, because the
  release skill reads it to classify each plugin's bump level.
- **Resolved by:** evidence
- **Affected decisions:** D12
- **Affected tech-notes:** —
- **Changed in spec:** Out of Scope, Summary

### F11: The claim of a single interruption may not survive the run's permission surface

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-009
- **Unverified:** The finding rests on how Claude Code matches a command invocation against a skill's permitted tool
  patterns, including the resolved-binary-path form T1 recommends. That matching is not observable from this repository
  and was not inspected. The finding is real as a risk and is not treated as build-blocking.
- **Finding:** The spec claims the maintainer is interrupted exactly once. The skill's permitted tool list covers the
  git, GitHub, and JSON commands and nothing that matches the tagging command. If the invocation falls outside the
  permitted set, the maintainer gets one approval prompt per plugin, thirteen times, mid-release.
- **Resolution:** The specification now states the commitment with its condition attached: one interruption, provided
  the tagging invocation is covered by what the run is permitted to execute without asking. Confirming that coverage is
  an implementation concern and is named as such.
- **Resolved by:** evidence
- **Affected decisions:** D11
- **Affected tech-notes:** T1
- **Changed in spec:** User Interactions

### F12: The success report carried too little signal to tell a clean release from a broken one

- **Agent:** devops-engineer
- **Reviewer identifiers:** DOR-5
- **Finding:** The closing report promised created tags, skipped tags, and the release URL. It carried no per-tag push
  confirmation, and per F2 the "skipped" line was a claim about the maintainer's machine presented as a claim about
  GitHub. A maintainer reading a green report had no way to tell a clean release from the F2 state without opening a
  terminal.
- **Resolution:** The report now commits to the commit every tag points at, that commit's relationship to the default
  branch, and a per-plugin state distinguishing newly pushed, already on GitHub, and present locally only.
- **Resolved by:** evidence
- **Affected decisions:** D9
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, User Interactions

### F13: Draft mode still pushes every permanent tag

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-011
- **Finding:** The release accepts a draft flag. Under the new flow the tags are created and pushed before publishing,
  so "draft" now means thirteen irreversible public tags plus an unpublished release page. Today it means one such tag.
  A maintainer reaching for draft is signalling uncertainty, and the irreversible footprint of that gesture grows.
- **Resolution:** Stated plainly in the specification rather than changed. Holding the tags back would mean a draft
  release with nothing to attach to, and the tags are the deliverable the work item asks for. The approval stop and the
  User Interactions section now say what draft mode does and does not defer.
- **Resolved by:** evidence
- **Affected decisions:** —
- **Affected tech-notes:** —
- **Changed in spec:** User Interactions

### F14: A release with no new commits stops before it can tag an untagged plugin

- **Agent:** junior-developer
- **Reviewer identifiers:** JD-010
- **Finding:** The release stops when no commits have landed since the previous release. D4's rationale is that walking
  every plugin means no separate backfill step, but the existing stop recouples tagging to changing: a maintainer
  running the release specifically to give an untagged plugin its tag never reaches the walk.
- **Resolution:** The existing stop is kept and the consequence is now stated. Every plugin is tagged on the transition
  release, so the only way to reach this state is to add a plugin and then want its tag before the next release, which
  no evidence supports needing.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F15: The old-naming fallback is a permanent branch serving a single use

- **Agent:** devops-engineer
- **Reviewer identifiers:** DOR-7
- **Finding:** The fallback passes the evidence test for existing, since without it the transition release's changelog
  covers the entire repository history. What it fails is disposal. The alternate flow's own exit condition says the
  fallback is unreachable forever after, and the draft recorded no trigger for removing it.
- **Resolution:** The simpler version the reviewer recommended was taken. The specification states the fallback's expiry
  in the same sentence that commits to it: the arm is removed once a parent-plugin tag exists on GitHub.
- **Resolved by:** evidence
- **Affected decisions:** D7
- **Affected tech-notes:** T3
- **Changed in spec:** Alternate Flows and States

## Minor edits

- F16: The walk's "in order" implied ordering was load-bearing without saying why; the specification now states that the
  parent is tagged first and why — junior-developer (JD-012) — Primary Flow, `D9` in decision-log.md.
- F17: The decision log carried hardcoded plugin counts, against the repository's count-free convention; replaced with
  "every plugin in the marketplace" — junior-developer (JD-013) — `D4`, `D9` in decision-log.md.
- F18: The "no tag of either naming exists" row describes a condition unreachable in a repository holding 27 tags; folded
  into the previous-release lookup row as its terminating case — junior-developer, devops-engineer (JD-014, DOR-7) —
  Edge Cases and Failure Modes.
- F19: The "newly added plugin" row restated D4 without adding behavior; rewritten to state the one thing that was
  implicit, that a brand-new plugin is not bumped by the release introducing it, so its first tag carries its
  introduction version — junior-developer (JD-015) — Edge Cases and Failure Modes.
- F20: The Summary claimed zero open items before the review round had run — junior-developer (JD-016) — Summary.
- F21: The cut list and D13 said twenty existing tags; the repository holds 27, from `v2.1.0` through `v4.6.0` —
  devops-engineer — Cut for Scope, `D13` in decision-log.md.
- F22: D5's evidence claimed the tagging command checks remote state the local tag list does not know about. That was an
  unevidenced assertion and testing disproved it; the line was removed — resolved during verification of F7 —
  `D5` in decision-log.md.

## Unaudited evidence classes

None. Both reviewers had access to every artifact, the skill under change, and the repository. No visual material was
supplied, so no reviewer is missing any.

## Escalation register

### E1: Should the release stop and ask before it creates the tags?

The question as asked: `/han-release` can currently run start to finish without asking anything, which is the state this
repository is in today, because every plugin's version was already bumped during development. After this change that
same silent run creates a tag for every plugin and pushes it, and the plan says never to move a tag once pushed. Three
candidates were named: always stop once immediately before the first tag push; stop only when at least one tag name is
new for that plugin; or print the tag list and keep running, leaving the existing opt-in pause. The first was
recommended.

- **Answer:** "agreed" — the operator accepted the recommendation. The release always stops once, immediately before the
  first tag push.
- **Landed in:** `D15` in [decision-log.md](decision-log.md), and the specification's Primary Flow (step 6), User
  Interactions, and Edge Cases and Failure Modes.
