# Review Findings: Han Publishing Cleanup

Spec: [../feature-specification.md](../feature-specification.md) · Iterations:
[review-iteration-history.md](review-iteration-history.md) · Decisions: [decision-log.md](decision-log.md) ·
Technical notes: [feature-technical-notes.md](feature-technical-notes.md)

Findings from `iterative-plan-review`. Numbering continues from
[team-findings.md](team-findings.md), which reached F27 during `plan-a-feature`, so cross-references
stay unique across both artifacts.

## Major findings

### F28: The check cannot block a merge, so the Outcome's enforcement guarantee has no bearer

**Agent:** `junior-developer` (JD-001), `devops-engineer` (DOR-013), and `evidence-based-investigator` (claim 10b) —
independently and convergently, from three different angles.

**Category:** unsupported behavioral commitment

**Finding.** The Outcome claimed "a check makes it impossible to quietly stop being so" and Step 7 claimed "Every
problem above becomes impossible to reintroduce." Nothing in this repository makes a pull-request check blocking.
Adding the check to the lint path makes it run and paint a red X; it does not make it block. No step created the
enforcement and no step owned it.

**Evidence considered.** Live GitHub configuration, re-verified directly rather than taken from the agents:

- `gh api repos/testdouble/han/branches/main/protection` → `404 Branch not protected`.
- `gh api repos/testdouble/han/rules/branches/main` → `[]`. Zero rules apply to `main`.
- `gh api repos/testdouble/han/rulesets` → one ruleset, named `main`, `"enforcement": "disabled"`.
- `gh api repos/testdouble/han/rulesets/16237928` → its rules are `deletion`, `non_fast_forward`, and `pull_request`
  (1 approving review). **No `required_status_checks` rule exists**, so enabling the ruleset would still not make the
  check block.
- `.github/workflows/ci.yml:8-11` triggers `lint` on `pull_request`. That proves the job runs. It was never evidence
  that a pull request can be blocked.

This is a trust-class correction as much as a factual one: F11 certified the pull-request half as "the real guarantee"
on evidence that only established the job runs. The larger overclaim was promoted while the smaller one was fixed.

Two consequences beyond the bare fact:

- **The only bearer of the guarantee is Step 3's gate, not Step 7.** The spec had the two backwards.
- **D1's stated rationale is not load-bearing on this repository.** D1 argues "a check that blocks everything on day
  one gets disabled," and it is the spec's one hard ordering constraint. A check that blocks nothing cannot be disabled
  that way; it gets ignored, which is a different failure with a different remedy. The ordering is still correct — the
  release gate is genuinely blocking from Step 3 — but the reason had to be restated.

**Resolution.** Downgraded honestly. The Outcome and Step 7 now state the guarantee per surface: blocking in the
release, advisory on pull requests. "Impossible to reintroduce" is deleted rather than left unearned. Open item 3 is
closed with the verified answer rather than left open, because the answer is known and it is the adverse one. D4's
rejection of "inside the release process only" is noted as resting on a premise the repository does not support.

**Resolved by:** user input (option: downgrade the claim honestly), on evidence.

**Raised in round:** R1

**Changed in plan:** Outcome, Primary flow (Step 7), Alternate flows and states, Coordinations, Open items, Summary

**Changed in tech-notes:** T2

### F29: The gate goes blocking at Step 3, four steps before the drift it checks is fixed

**Agent:** `junior-developer` (JD-002), with `devops-engineer` (DOR-013) reaching the same window independently.

**Category:** unhandled failure mode in a primary flow path

**Finding.** D14 gives the check and the release one bearer, so the rule is live from Step 3 — "the rule itself has
existed since step 3, because the release runs it." Step 3's gate refuses to proceed when a plugin's version records
disagree. Step 4 is what fixes the disagreement, and the reorder put it after. Every release cut between Step 3 and
Step 4 therefore hard-stops, with no disable switch by deliberate design (D28).

This is D1's own failure mode, shipped by the spec's own reorder. The spec applied D1's reasoning only to Step 7
("Because steps 1 through 6 have already landed, the check is green on the day it arrives"). The rule became blocking
four steps earlier, against a demonstrably red repository. The "check lands before the problems are fixed" alternate
flow was written as a rejected hypothetical; it was actually shipped, on the release surface.

**Evidence considered.** Eight plugins have disagreeing version records at the moment Step 3 lands, verified by direct
read of every manifest (`evidence-based-investigator` claim 4): `han-core` 2.2.1/1.2.0, `han-planning` 2.0.4/1.0.0,
`han-coding` 2.6.0/1.0.0, `han-github` 2.2.2/1.2.0, `han-reporting` 2.1.1/1.0.1, `han-feedback` 2.0.0/1.1.1,
`han-atlassian` 2.2.0/1.1.0, `han-plugin-builder` 2.0.5/1.1.0. Only `han-communication` agrees. The gate checks every
plugin (D5 derives the list from the repository), not only the ones being bumped. `han-linear` adds a ninth gap of a
different shape — no channel-two record at all — which Step 1 both creates and, per F34, re-drifts.

**Resolution.** Steps 3 and 4 are named as one unit, exactly as Steps 5 and 6 already are, and the unit is added to the
binding-constraints list. This is the structural fix rather than the promise-based one: at D18 the alternative "state a
precondition that no release is cut in the window" was offered and rejected in favor of a structural fix, and leaving a
window at 3→4 would have quietly reinstated the option already thrown out.

**Resolved by:** user input (option: make Steps 3+4 one unit), on evidence.

**Raised in round:** R1

**Changed in plan:** Primary flow (binding constraints, Step 3, Step 4), Alternate flows and states, Coordinations,
Summary

**Changed in tech-notes:** —

### F30: The repaired release can detect a missing target but cannot create one

**Agent:** `devops-engineer` (DOR-012)

**Category:** behavioral commitment the step does not deliver

**Finding.** The spec treated "updates all four targets" as one capability. The release has two, and only one existed.
D5 changes what the release can see; it did not give it the ability to create membership. For a brand-new plugin —
precisely the `han-linear` shape that motivated this work — the repaired release would write nothing to any target, and
the gate would simply stop. The spec sold a tripwire as a repair, and the headline promise would never fire for the one
case the work exists to fix.

**Evidence considered.** `.claude/skills/han-release/SKILL.md`:

- `:230` — the version-write step acts only "For **every** plugin whose `target` differs from its `current`".
- `:237-238` — "Skip any plugin whose `target == current` (ahead-path or new plugins — their files are already
  correct). When the entire plan is ahead-path/new… this step is a **no-op**."
- `:160-161` — a new child gets "`baseline = current`, `target = current`, **no bump**", so a new plugin always hits
  the skip.
- `:235-236` — the only listing write "set[s] the `version` of the `plugins[]` element whose `name` equals the plugin
  name". It sets a version on an existing element and never creates one. No behavior is defined when no element exists.

**Resolution.** Step 3 commits to creation as well as detection. A release creates a missing listing entry or version
record rather than only refusing to proceed. This required a new decision the spec had not made: what version a target
gets when the release did not bump that plugin. Recorded as D31 — a created record is written at the version the
release is publishing for that plugin, which for an unbumped plugin is its current version, so creation and agreement
resolve in one pass. The gate keeps its meaning: it still fires on gaps creation cannot close (a listing entry with no
plugin behind it, an unparseable manifest, a broken version value).

**Resolved by:** user input (option: create missing membership too).

**Raised in round:** R1

**Changed in plan:** Outcome, Primary flow (Step 3), Alternate flows and states, Edge cases and failure modes,
Coordinations

**Changed in tech-notes:** —

### F31: `han-linear` is a third untrue dependency declaration, and the spec's own deferral trigger has already fired

**Agent:** `adversarial-validator` (V1), with supporting scope from V5.

**Category:** counter-evidence to a foundational claim

**Finding.** Step 5 rested on "Two plugins declare that they need the core plugin and never touch it." The count is
three. `han-linear` declares `han-core`, narrates the dependency in its own description, and grants neither the `Agent`
nor the `Skill` tool — the identical structural signature D13 used to condemn `han-feedback`'s declaration ("it is not
permitted to call other plugins at all, so its claim cannot possibly be true").

The error cascades further than the count:

- The **Outcome** ("Every dependency a plugin declares is one it actually uses") stayed false after Step 5 shipped as
  scoped, because `han-linear`'s declaration survived untouched.
- **D8** repoints the tutorial's worked example specifically at `han-linear`'s `han-core` dependency, citing it as "a
  structural identity for `han-feedback`'s role". If that dependency is itself decorative, D8 replaces one false claim
  in the tutorial with another — the exact defect D8 and D27 exist to eliminate.
- **D25** claims "The sweep came back clean" over manifest descriptions, citing only `han-reporting`'s and
  `han-feedback`'s manifests. It never checked `han-linear`'s description, which narrates the same false claim its
  `dependencies` array does. The sweep was not clean.
- The **Deferred (YAGNI)** entry names its own reopening trigger as "a third decorative dependency is found." That
  trigger is met today, before the spec ships.

**Evidence considered.** `han-linear/.claude-plugin/plugin.json:5` declares `"dependencies": ["han-core"]`; `:3`
states "Depends on han-core." `grep -rn "han-core" han-linear/` returns only the manifest — zero hits in
`skills/work-items-to-linear/SKILL.md` or its `references/`. That SKILL.md's `allowed-tools` lists
`Read, Write, Edit, Glob, Grep, Bash(find *)` plus nine Linear MCP tools, with no `Agent` and no `Skill`.
`git log -p --follow` shows the declaration present since the plugin's introduction (`d94daa2`) — not a recent
regression. Corroborated by `evidence-based-investigator` claim 2's method, which confirmed the same signature for
`han-reporting` (zero `han-core` references outside its manifest) and `han-feedback` (no `Agent`/`Skill` grant).

**Resolution.** Step 5 deletes three declarations, not two. Step 6's document scope grows to every location narrating
`han-linear`'s dependency (`CLAUDE.md`, `docs/choosing-a-han-plugin.md`, `CONTRIBUTING.md`), which D7's rule already
reaches definitionally — the gap was that the survey ran against a two-plugin premise.

Three decisions were corrected downstream, because the error had propagated further than the count:

- **D13** grows from two declarations to three, with the `han-linear` evidence recorded. Its heading keeps the word
  "both" so existing cross-references stay stable, with the correction stated beneath it.
- **D8** repoints the tutorial's opt-in-leaf example from `han-linear` to `han-atlassian`. This was the sharpest edge of
  the finding: D8 had chosen `han-linear` as the example of a dependency that is *real*, and it is the opposite.
  `han-atlassian` was verified to pass both tests the replacement must pass — it survives this work, and its dependency
  is genuinely exercised (`han-atlassian/.claude-plugin/plugin.json:3`: "its wrapper skills run skills from each").
  `han-plugin-builder` was considered and rejected: opt-in and unbundled, but it depends on nothing, so it cannot
  illustrate an edge.
- **D25** loses its "the sweep came back clean" claim, which was false. The sweep checked only the manifests of plugins
  already suspected, which is precisely how the third declaration stayed hidden. The re-run covers every plugin's
  description.

The deferred dependency-usage check stays deferred: its trigger fired, but the YAGNI rule asks what evidence supports
building the mechanism now, and three instances being deleted by hand is still not a case for a general checker. The
trigger is restated so it cannot fire on the instances this work removes.

**Resolved by:** user input (option: delete it — Step 5 becomes three), on evidence.

**Raised in round:** R1

**Changed in plan:** Outcome, Primary flow (Step 5, Step 6), Deferred (YAGNI)

**Changed in decision log:** D13, D8, D25 corrected

**Changed in tech-notes:** —

### F32: "Roughly twenty releases" is false; the verified count is 11

**Agent:** `evidence-based-investigator` (claim 5) and `adversarial-validator` (V2), convergent on the refutation and
**in conflict on the number** — resolved below.

**Category:** unverified factual claim driving spec prose

**Finding.** The spec states the drift "went unnoticed across roughly twenty releases" (Step 3) and "persisted for
twenty releases" (Deferred (YAGNI)). Both are false. The claim traces to D12's rationale, which states it with no
`Evidence:` citation for the number itself, and it survived into the spec without ever being verified against a
repository fully capable of answering it.

**Evidence considered.** The codex records were created at `fabde07` ("feat: add Codex plugin scaffolding",
2026-06-10) and the version content has been frozen since; the only later touch (`d94daa2`) is a pure rename that
leaves the `version` line untouched.

The two agents disagreed: `evidence-based-investigator` said 11, `adversarial-validator` said 14. Resolved by direct
re-verification in favor of 11, the ancestry-based count:

- `git merge-base --is-ancestor fabde07 <tag>` over all tags → 11 tags: `v4.0.0, v4.1.0, v4.2.0, v4.3.0, v4.3.1,
  v4.3.2, v4.3.3, v4.4.0, v4.5.0, v4.5.1, v4.6.0`.
- `adversarial-validator` counted tags *dated* after 2026-06-10, which adds `v3.3.1`, `v3.4.0`, and `v3.4.1`. Direct
  check: none of those three contain `fabde07`. They were cut from branches without the codex scaffolding, so those
  releases could not have updated records that did not exist in their tree.

Ancestry is the defensible test, so the count is 11. The qualitative point the number was serving — nothing asked the
question, at any count — survives at 11 and does not depend on the number.

**Resolution.** Replaced with the verified count in both locations, cited as codebase evidence.

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Primary flow (Step 3), Deferred (YAGNI)

**Changed in tech-notes:** —

### F33: D6 exempts the bundle from version agreement on a rationale that is factually wrong

**Agent:** `devops-engineer` (DOR-014)

**Category:** edge-case rule resting on a false premise

**Finding.** D6's stated reason for exempting the bundle from the version-agreement rule is "a plugin published on one
channel has nothing to disagree with." That is false on disk. The bundle publishes a version in **two** records —
channel one's storefront listing and its own manifest — and D20 deliberately brought that exact pair into the rule
("channel one's listing-versus-manifest version pair is hand-synced by the release today and nothing verifies it").
D6 and D20 collide, and the Edge-cases row stated the exemption unqualified.

The bundle is the worst possible plugin to exempt. `docs/semantic-versioning.md:160-172` and
`.claude/skills/han-release/SKILL.md:148-149`: "The parent always bumps on **every** release," so its listing-vs-manifest
hand-sync runs more often than any child's. `SKILL.md:54`: "The release tag is `v{parent target}`" — the bundle's
version names the release. If one release's hand-sync misses the parent, the tag says one version, the manifest says
that version, and the storefront advertises the previous one, silently and permanently, because the rule was told not
to look. That is the D10 drift class, on the one plugin the whole suite is tagged by, introduced by the fix.

**Evidence considered.** `.claude-plugin/marketplace.json` → `han` 4.6.0; `han/.claude-plugin/plugin.json` → 4.6.0.
Two records, both publishing a version, currently agreeing.

**Resolution.** The exemption is split. The bundle is exempt from the **cross-channel** comparison, because it has no
channel-two record to compare against, and is **not** exempt from channel one's internal listing-versus-manifest
agreement. D6's rationale sentence is replaced; the Channels-and-targets bullet and the Edge-cases row both carry the
qualifier.

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Channels and targets, Edge cases and failure modes

**Changed in tech-notes:** —

### F34: Step 1 manufactures the drift Step 4 repairs, and D22's "dissolves the coupling" overclaims

**Agent:** `junior-developer` (JD-003), with `adversarial-validator` (V3) tracing the same mechanism to Step 1's own
durability.

**Category:** ordering hazard

**Finding.** Step 1 claims its new version record "is correct on arrival rather than created wrong for a later step to
repair," and D22 claims it "dissolves the coupling rather than managing it." Step 1 must create
`han-linear/.codex-plugin/plugin.json` — a file inside `han-linear/`. `docs/semantic-versioning.md:118` reads "A child
bumps only when its own directory changed," and `:166` lists "new files" as a minor bump. So Step 1's own work forces
`han-linear` to bump at the next release, and a release cut before the repair writes only channel one — moving channel
one's version while the record Step 1 just created stays put. Step 1 manufactures the drift for Step 4 to repair.

This is F1's argument applied to the step F1 did not examine. F1 spotted that Step 4 writes channel-two versions ahead
of the repair and reordered; it did not notice Step 1 also writes a channel-two version record, and Step 1 is still
ahead of the repair. D22's "dissolved" holds only if no release is cut between Step 1 and Step 3 — the promise-based
fix already rejected at D18.

**Evidence considered.** `find han-linear -iname "*.codex*"` returns nothing, confirming Step 1 must create the
directory and file. `docs/semantic-versioning.md:118,166` supply the bump rule.

**Resolution.** Largely absorbed by F29's structural fix: with Steps 3 and 4 as one unit, the repair lands before the
version correction, and Step 1's manufactured drift is one more gap that unit clears. What does not absorb is D22's
claim, which is corrected — the coupling is not dissolved, it is small and healed by the Step 3+4 unit. Step 1 carries
the caveat that its record is durable only once that unit lands.

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Primary flow (Step 1)

**Changed in tech-notes:** —

### F35: Step 1's install-succeeds promise is unhedged against Open item 2, while the parallel claim is hedged

**Agent:** `junior-developer` (JD-004)

**Category:** behavioral commitment resting on a recorded unknown

**Finding.** Step 1 states "the documented install command succeeds" and Outcome bullet 1 states "Following the
documented install instructions produces a working install, not an error." Both are flat. Open item 2 records that
which revision each channel's client resolves from — branch or release tag — is unknown, and that if it is the tag,
"steps 1 and 4 reach users at the next release rather than on merge."

The spec treats one class of unknown two ways. Outcome bullet 2 (update prompts) **is** hedged, with a pointer to T1
and Open item 1. Bullet 1 gets no hedge, for the same reason, from the same kind of external-client unknown. Open item
2 names Step 1 explicitly, and Step 1's text ignores it.

This compounds with F29: if clients resolve from tags, Step 1's fix reaches users only at the next successful release,
and no release succeeds until the Step 3+4 unit lands. That weakens D11's rationale, which rejected "fix the release
process first" because it "makes the live user-facing error wait on the largest step in the plan" — under tag
resolution the error waits for the repair regardless of Step 1's position.

**Resolution.** Step 1 and Outcome bullet 1 are hedged against Open item 2 the same way bullet 2 is hedged against
Open item 1. D11's rationale is noted as contingent on Open item 2 resolving to "branch."

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Outcome, Primary flow (Step 1), Open items

**Changed in tech-notes:** —

### F36: D26's remedy is unimplementable for the two documents it most affects

**Agent:** `junior-developer` (JD-005)

**Category:** resolution that does not survive contact with its targets

**Finding.** D26 requires corrected documents to "state the dependency rule and point at the manifests as the record,
rather than restating the manifests' contents in prose," and rejects enumeration outright. D26 was reasoned entirely
from one sentence shape — `CONTRIBUTING.md:128`'s universal "Every plugin depends on `han-core`" — where "each plugin
declares its own dependencies; read the manifest" genuinely replaces it. F10 then extended it to "corrected documents"
plural, including the orientation document.

It does not survive. There is no rule that generates the real dependency graph; it is irregular by design
(`han-planning` depends on `han-core` but not `han-communication`; `han-coding` depends on both; `han-communication` and
`han-plugin-builder` depend on nothing). `docs/concepts.md` and `CLAUDE.md`'s project map exist precisely to narrate
that irregular graph to a new reader or an agent. The only D26-compliant edit is to delete the narration and say "go
read the manifests," which guts the document whose job is orientation — and for `CLAUDE.md`, defeats the point of an
agent-facing map, since agents read it instead of eleven manifests. The natural fix (drop the count, keep the
enumeration) is the one D26 forbids.

A second, milder problem: Step 6 asserts "hardcoded counts are already a violation of this repository's own
convention." The convention in `CLAUDE.md` § Conventions is scoped to *indexes* ("Verify the indexes list every entity
when editing them, rather than tracking a running total"). Stretching it to prose topology narration is defensible in
spirit but was asserted as settled fact.

**Resolution.** D26 is scoped to the document shape it was reasoned from — universal claims about the dependency graph.
For documents that legitimately enumerate an irregular graph, Step 6 drops the count, keeps the enumeration, and points
at the manifests as the record. The convention claim is softened to what the convention actually says.

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Primary flow (Step 6)

**Changed in tech-notes:** —

### F37: The already-false-neighbor rule is undefined, and there is a live instance inside a passage Step 6 must edit

**Agent:** `junior-developer` (JD-006)

**Category:** ambiguity in a scoping rule

**Finding.** The spec resolves the already-false-document case three incompatible ways. D7 and Out of scope keep such
documents **out** ("the editor is already open" is convenience, not evidence). D9 pulls `CONTRIBUTING.md:128` **in**,
already-false, because "the claim is false, and contributors read it." D27 pulls the tutorial's version promise **in**,
already-false, because "D8 rewrites this exact paragraph." Two inclusion rules, neither generalized, both contradicting
the exclusion rule.

There is a live instance. `docs/concepts.md:222-223` states the `han` meta-plugin "depends on `han-core`,
`han-planning`, `han-coding`, `han-github`, and `han-reporting`" — the real manifest is
`["han-communication", "han-core", "han-planning", "han-coding", "han-github", "han-reporting"]`, omitting
`han-communication`. Already false, not falsified by this work, and sitting directly between two lines Step 6 must
edit. The implementer corrects line 221, stares at line 222, and the spec does not say which rule applies.

**Resolution.** The rule is stated once, generalizing what D9 and D27 already did: a false statement inside a passage
this work is already rewriting is corrected; a false statement elsewhere is not. This keeps D7's exclusion intact for
distant staleness and gives Step 6 an answer.

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Primary flow (Step 6)

**Changed in tech-notes:** —

### F38: The gate's stated recovery loops against the release's own clean-tree precondition

**Agent:** `devops-engineer` (DOR-015)

**Category:** unverified recovery path

**Finding.** The spec gives two different failure cases the same recovery: "Recovery is discarding local changes" (gate
stop) and "Recovery is discarding local changes and re-running" (partial write). The release hard-stops on a dirty tree
— `.claude/skills/han-release/SKILL.md:72-74`: "**Working tree must be clean.**… This is a hard stop, not a pause
gate." So for a gate stop the loop is: gate stops → discard local changes → the gap is still there → re-run → identical
stop. The stated recovery is a no-op for the case it names.

With no bypass (D28, correctly), the available move under release pressure is to hand-edit the targets and force
through — shipping around the gap, which is the behavior the entire feature exists to end, performed by the person the
gate was built to protect.

**Resolution.** Severity drops given F30's answer: once the release creates missing membership, the gate's firing cases
shrink to gaps creation cannot close, so the loop is rare rather than routine. It does not vanish, so Alternate flows
now carries two recoveries instead of one: a partial write is discarded and re-run; a gate stop requires the gap to be
corrected and committed before the release can re-run, because the release refuses to start dirty. This does not reopen
D28.

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Alternate flows and states

**Changed in tech-notes:** —

### F39: The gate's window contains a human authorization prompt, and "forced from both sides" overclaims

**Agent:** `devops-engineer` (DOR-016)

**Category:** gate ordering

**Finding.** D24 claims the gate's placement is "forced from both sides." It is forced on the early side and merely
bounded on the late side. The window between the target writes and the commit contains three steps, including
`.claude/skills/han-release/SKILL.md:317-318`, which uses `AskUserQuestion` to ask the operator "publish now?". The
spec's sentence permits the gate anywhere in that window, including after that prompt — meaning the release could show
the maintainer a fully prepared release, ask for approval, receive it, and then refuse. The spec names one boundary
(irreversibility); the release has a second (operator authorization) the spec did not name.

The cost is bounded — nothing irreversible — but it teaches distrust of the gate, which is D1's failure mode arriving by
a different road.

**Resolution.** The gate is anchored to both boundaries: it runs on the state being released, before the release asks
the operator to approve publishing, and before anything irreversible. D24's "forced from both sides" is corrected to
name the second boundary rather than assert a symmetry that does not hold.

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Primary flow (Step 3), Coordinations

**Changed in tech-notes:** —

### F40: A manifest that fails to parse silently vanishes from the derived plugin list

**Agent:** `edge-case-explorer` (EC1)

**Category:** silent failure reproducing the defect the work exists to close

**Finding.** Neither D5's derivation nor D24's gate states what happens when a manifest is structurally broken rather
than absent or disagreeing. A plugin whose manifest is unparseable would be silently dropped from the derived list, so
the check would answer "does every plugin appear everywhere it should?" for a plugin set that has already quietly
excluded the broken one. That is invisible by construction — the same shape as the original bug D5 was built to end.

The spec defines "malformed" as a first-class, detectable, surfaced category for work-items headings (D30, D17) and
never once for plugin manifests.

**Evidence considered.** `.claude/skills/han-release/SKILL.md:37,39` — both `jq` reads swallow parse failures via
`2>/dev/null`, producing empty output rather than an error. This is the established idiom in the very skill D5 extends,
so the failure is not hypothetical: it is the default behavior of the code the derivation grows out of. The trigger is
ordinary — a hand-editing slip during Steps 1 or 4, or an interrupted write from the release's own target-writing step.

**Resolution.** Symmetry with the work-items domain is not the argument (that would be the reasoning this spec
rejects); the argument is that the failure is silent and reproduces the motivating defect. An unparseable manifest is a
surfaced, blocking failure, named like any other gap, never a plugin the derivation quietly drops. Added to Edge cases.

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Edge cases and failure modes

**Changed in tech-notes:** —

### F41: Version agreement has no defined behavior for a present-but-broken version value

**Agent:** `edge-case-explorer` (EC2)

**Category:** boundary of a defined rule

**Finding.** D20's rule covers three records, and the Edge-cases table has rows for "missing from any target" and
"version records disagree." Neither states which bucket a present record with a broken value falls into — a missing
`version` key, an empty string, or a non-version value. A naive equality comparison would treat two empty or missing
values as **agreeing**, which is a false negative on exactly the class D20 was written to catch.

**Evidence considered.** D20's own evidence establishes the class is not hypothetical: the release hand-syncs channel
one's manifest version into its listing entry, unverified, which D20 names as "a hand-sync of exactly the class that
drifted on channel two." The same manual edit that drifted channel two can produce a broken value rather than a
different one.

**Resolution.** A record that publishes a version but whose value is empty, missing, or unreadable as a version fails
the check by name, exactly as a genuine disagreement does. It is never treated as vacuously agreeing. Added to Edge
cases.

**Resolved by:** evidence.

**Raised in round:** R1

**Changed in plan:** Edge cases and failure modes

**Changed in tech-notes:** —

## Minor edits

- F42: Open item 4 is parked with no dependent step, which is the same shape F22 used to remove the old open item 3 —
  the spec applies one test in two directions. — `junior-developer` (JD-007) — Open items (item 4 restated as homeless
  and kept deliberately, with F22's rule restated rather than contradicted)
- F43: D29's evidence leans on the `d94daa2` atomic-rename precedent, which undercuts itself — that commit updated the
  listings in the same commit, so the dangling-entry state has never existed here. The behavior is free (it is the
  mirror of the comparison D19 already requires) and is kept; the evidence wording is corrected to say so rather than
  lean on a precedent that demonstrates the opposite. — `adversarial-validator` (V4) — Edge cases (D29 evidence
  wording; behavior unchanged)
