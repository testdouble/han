# Technical Notes: Han Publishing Cleanup

Spec: [../feature-specification.md](../feature-specification.md) · Decisions: [decision-log.md](decision-log.md) ·
Findings: [team-findings.md](team-findings.md)

Load-bearing mechanics captured because a behavioral commitment in the spec is only correct because of them. Mechanics
discoverable from this repository are cited as `Evidence:` on their decision instead and do not appear here.

## T1: Update availability on channel two is decided by the published version number

**Context.** The spec commits to a user-visible behavior in its Outcome and in step 4: people on channel two are offered
updates again. That claim is only correct because of the mechanic below. Without it, frozen version numbers would be a
cosmetic labelling problem — the plugin contents on that channel would still refresh, and step 4 would be tidying rather
than repairing.

**Technical detail.** Channel two's client decides whether an update is available for an installed plugin by comparing
the version the channel publishes for that plugin against the version the user has installed. It does not compare file
contents. Because the published versions have not moved since the day they were written, the comparison always reports
"no update available", so the client never offers one. Users are running old skills with no signal that newer ones exist.
This is why the defect is silent from the user's side as well as from the release's side, and why correcting the numbers
is sufficient to restore update prompts without any other change to that channel.

**Why this is not discoverable from the repository.** The comparison happens inside channel two's client, which is not
part of this codebase. The repository shows only the published version records, from which the frozen-ness is visible but
the consequence is not.

**Evidence quality.** provided, single-source, with codebase corroboration by analogy — upgraded during review.

- **provided (single-source).** The source artifact asserts it: "That channel decides whether an update is available by
  reading a version number that has not moved since the day it was written. So it never offers anyone an update."
- **codebase (corroborates the mechanism class, not this channel).** `docs/semantic-versioning.md:4` describes the
  version field as what a channel uses "to detect that updates are available". That establishes version-comparison as
  how update detection works in this suite's publishing model — but it is written about channel one, so it does not
  confirm channel two behaves the same way.
- **codebase (corroborates that the two clients differ).** `README.md:74` records that channel two "resolves no
  dependencies", establishing that its client has materially different resolution behavior from channel one's. That cuts
  both ways: it proves the clients are not interchangeable, which is exactly why the channel-one evidence above cannot
  simply be transferred.

The net position: the mechanism is the obvious one and is documented for the sibling channel, but **no source confirms it
for channel two specifically**. This remains a claim driving a user-facing commitment on weaker evidence than the
commitment implies, and it is flagged as such per
[evidence-rule.md](../../../../han-planning/references/evidence-rule.md).

**If this note is wrong.** Step 4 is still worth doing — the numbers are wrong and D10 wants one version per plugin — but
its stated user outcome is overclaimed, and the spec's Outcome must lose the update-prompt sentence. The blast radius is
narrow and entirely confined to that one claim; no other decision depends on this note.

**Verification.** One installed client on channel two, one release, one look at whether an update is offered. This is
[Open item 1](../feature-specification.md#open-items), owned by the maintainer, and it is the only open item in the spec
with a named cost and a named consequence. It is worth doing before the spec's Outcome is quoted to anyone.

Note that [Open item 2](../feature-specification.md#open-items) compounds this: if channel two's client resolves from
the latest release tag rather than the default branch, then the verification itself must wait for a release, and step 4's
outcome reaches users then rather than on merge.

**Supports decisions:** D10
**Driven by findings:** F6
**Referenced in spec:** Outcome, Primary flow (Step 4), Open items

## T2: A pull-request check blocks a merge only where a required status check demands it

**Context.** The spec committed to a user-visible behavior in its Outcome and in step 7: the check makes the problems
impossible to reintroduce, on every change. That claim is only correct because of the mechanic below, and the mechanic
does not hold here. Without it, the check on a pull request is a signal a person may merge past, not a gate.

**Technical detail.** A check that runs on a pull request reports a status. Reporting a status and preventing a merge
are separate mechanisms: the merge is blocked only when the hosting platform is configured to require that specific
status before merging. Absent that configuration, a red check is advisory — visible, and mergeable. This repository has
no such configuration: the default branch is unprotected, no rules apply to it, and the one ruleset that exists is
disabled and does not contain a required-status-check rule at all, so enabling it would not change the answer. The
release-side gate is therefore the only surface in this feature that actually refuses to proceed.

**Why this is not discoverable from the repository.** The pipeline definition lives in the repository and proves the
check runs. Whether a status is *required* lives in the hosting platform's repository settings, which are not files in
this codebase and are not visible to anyone reading it. This is why the gap survived: the repository shows the trigger,
and the trigger looks like enforcement.

**Evidence quality.** live platform configuration, first-party, directly queried and independently re-verified during
review. This is a stronger tier than T1's: the fact was read from the authoritative system rather than inferred.

- **live configuration (direct).** The default branch returns "not protected"; the rules applying to it are an empty
  set; the sole ruleset is disabled and its rules are deletion, non-fast-forward, and a pull-request review-count rule,
  with no required-status-check rule present. Queried by `evidence-based-investigator` and `junior-developer`
  independently, and re-run during consolidation.
- **codebase (corroborates that the check runs, and only that).** `.github/workflows/ci.yml:8-11` triggers the lint job
  on every pull request. This is what F11 read as evidence of enforcement; it establishes execution, not blocking.

The net position: the fact is settled and adverse. Unlike T1, nothing here is unverified — the mechanic is confirmed,
and it confirms the spec's claim was wrong rather than unproven.

**If this note is wrong.** It is not wrong in the sense T1 might be; it was read from the live system. It can, however,
become *stale*: enabling a required status check would restore the spec's original claim. That is a settings change no
step in this spec owns, and the spec now says so rather than assuming it.

**Verification.** Already performed. Re-verify only if the repository's branch-protection configuration changes.

**Supports decisions:** D4, D14, D32
**Driven by findings:** F28
**Referenced in spec:** Outcome, Primary flow (Step 7), Coordinations, Open items
