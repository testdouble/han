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

### F44: The release repairs disagreements, so the freeze the 3+4 unit closes never happens

**Agent:** `junior-developer` (JD-101), with `devops-engineer` (DOR-R2-03) reaching the same conclusion from the gate's
side and (DOR-022) from the branch-cut flow's side.

**Category:** two resolutions from the same round contradicting each other

**Finding.** R1 produced F29 (steps 3 and 4 become one unit) and F30 (the release creates rather than only detects) in
the same round, and never checked them against each other. F29's argument: the release runs the rule, so the gate is live
from step 3; every plugin but one has disagreeing version records until step 4 corrects them; a release cut in the window
therefore hard-stops, freezing releases until the versions are fixed.

F30 falsifies the premise. A repaired release **corrects a stale version rather than refusing over it** — the spec's own
Coordinations says "creating what is missing, updating what is stale". The gate runs after the writes (D24), so by the
time it looks, the eight disagreements are gone: the release closed them. Shipping step 3 without step 4 repairs the
drift rather than freezing anything. The window F29 structurally closed was never open.

The spec had the contradiction on the page. Step 3 enumerated the gaps a release cannot close three times — a listing
naming a plugin that does not exist, a record it cannot read, a version it cannot parse — omitting version disagreement
from all three, while ten lines below claiming "a gate that is live against nine gaps stops every release until they are
closed."

Writing the publishing version onto a disagreeing record and writing it onto a missing one are the same act. If the
release does the second, there is no principled reason it does not do the first.

**Evidence considered.** codebase — `.claude/skills/han-release/SKILL.md:230` acts only "For every plugin whose `target`
differs from its `current`" and `:237-238` skips the rest; that skip is exactly what step 3 removes when it commits the
release to bringing every target up to date. codebase — eight plugins disagree today, `han-communication` agrees, and
`han-linear` has no channel-two record. Verified independently by `evidence-based-investigator` (C1) and by direct read.

**Resolution.** The user confirmed that a release overwrites a stale version record for a plugin it did not bump, and
chose to restate the unit rather than narrow the repair. Steps 3 and 4 revert to an **ordering**, which is what D18 has
said all along — "the release repair precedes the version correction". D18 needed no edit; the spec's R1 change was the
error, and it cited D18 for a claim D18 never made (F53). Step 4 keeps its place on a smaller and true claim: it makes
the numbers right on merge rather than at the next release. Recorded as D38, which also states the consequence that the
two surfaces now answer differently — a pull request reports drift a release would have repaired, because a pull request
has nothing that repairs.

**Resolved by:** user input (option: yes, the release overwrites; restate the unit), on evidence.

**Raised in round:** R2

**Changed in plan:** Primary flow (binding constraints, Step 1, Step 3, Step 4, Step 7), Alternate flows and states,
Edge cases and failure modes, Coordinations, User interactions, Summary

**Changed in decision log:** D38 added; D18 annotated (vindicated, no edit); D24 corrected

**Changed in tech-notes:** —

### F45: The release commits two of the four targets, so the gate certifies a state that is never released

**Agent:** `devops-engineer`, twice independently (DOR-018 and DOR-R2-01, from two separate passes).

**Category:** behavioral commitment the step does not deliver

**Finding.** The spec commits the release to writing four targets and to a gate that judges the written state. It never
says what becomes of the writes. The release's commit stages an enumerated list of file classes, all on channel one, so
the real sequence is: write four targets, gate passes on the four-target state, commit two of them, tag, push.

Four consequences, each silent:

- **The tag does not contain the fix.** Under Open item 2's adverse branch (clients resolve from the tag), the entire
  repair reaches nobody while the gate reports green.
- **The default branch goes red and stays red.** After one release, channel one is bumped and channel two is untouched —
  which is D1's restated failure mode arriving via the repair rather than the ordering.
- **The next release hard-stops.** The uncommitted channel-two writes leave the tree dirty, surfacing one release removed
  from the cause.
- **A creation-only release commits nothing at all.** The `han-linear` shape — the motivating case — stages nothing and
  skips its own commit, tagging an unchanged tree.

The gate cannot catch any of it by construction: it runs before the commit, so it inspects a tree the release then
declines to publish. This is the original defect (the release cannot see the targets it does not touch) relocated from
the write step to the commit step, shipping inside the fix.

**Evidence considered.** codebase — `.claude/skills/han-release/SKILL.md:326-328` stages `CHANGELOG.md`,
`.claude-plugin/marketplace.json`, and every `{source}/.claude-plugin/plugin.json` the version step changed; both
channel-two targets absent. Verified directly during consolidation rather than taken from the agents. `:328` skips the
commit "if nothing is staged (… **unlikely**)", a parenthetical creation retires. `:72-74` hard-stops on a dirty tree.
`:333-335` tags the release commit.

**Resolution.** One behavioral sentence: every target the release writes travels into the commit it tags, so the state
the gate approved is the state that ships. The staging list is the implementation plan's business. Recorded as D37.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Outcome, Primary flow (Step 3), Coordinations

**Changed in decision log:** D37 added

**Changed in tech-notes:** —

### F46: A created record carries content D31 says it does not, and "membership and nothing more" is false

**Agent:** `adversarial-validator` (V1) and `junior-developer` (JD-103), convergent.

**Category:** behavioral commitment resting on a false premise about the artifact

**Finding.** D31 describes creation as writing a version, and describes creating a channel-two listing entry as "adding
the plugin's membership **and nothing more**". Both undersell the artifacts, and the second is false.

- A channel-two per-plugin record carries `keywords` and an `interface` block — `displayName`, `shortDescription`,
  `longDescription`, `developerName`, `category`, `capabilities`, `websiteURL`, and a `defaultPrompt` array of example
  prompts. None derives from anything the repository holds: channel one carries a single `description` string, never
  decomposed into short and long forms or prompts.
- A channel-two listing entry carries `"policy": {"installation": "AVAILABLE", "authentication": "ON_INSTALL"}` — the
  field deciding whether the plugin is installable at all, which is the Outcome's headline promise sitting in the field
  D31 called empty of everything but membership.
- A channel-one listing entry carries an authored `description`, which **D25 already classifies as a document**. So D31
  had an unattended release authoring user-facing prose mid-run.

This is F33's error class — a decision exempting or committing something on a false premise about what the record
carries — reintroduced by R1 in a new location. It also breaks the spec's own parallel: step 1 creates the Linear
plugin's channel-two record **by hand**, where a person writes that prose. D31 gave the same act to a release with no
person.

**Evidence considered.** codebase — verified directly during consolidation: `han-core/.codex-plugin/plugin.json` carries
the full interface block; `han-core/.claude-plugin/plugin.json` carries only `name`, `description`, `version`,
`dependencies`; every entry in `.agents/plugins/marketplace.json` carries the installation and authentication policy;
every entry in `.claude-plugin/marketplace.json` carries a description.

**Resolution.** The release creates what it can derive and refuses what must be authored. A plugin with no authored
storefront presence is a gap creation cannot close — a gate stop, joining D29's dangling entry as "a person decides".
Step 1 still authors the Linear plugin's record by hand, which the spec now names as the same boundary met by the one
actor who can cross it. Recorded as D36. The Channels-and-targets glossary gains a bullet naming what a target carries
besides a version, since the glossary's "a place that states a plugin's published version" is what made the error easy.

**Resolved by:** user input (option: narrow D31 — unauthored presence is a gate stop), on evidence.

**Raised in round:** R2

**Changed in plan:** Channels and targets, Outcome, Primary flow (Step 1, Step 3), Alternate flows and states, Edge cases
and failure modes, Coordinations

**Changed in decision log:** D36 added; D31 corrected

**Changed in tech-notes:** —

### F47: Creation is committed on all four targets on evidence that exists for two

**Agent:** `junior-developer` (JD-110)

**Category:** YAGNI candidate

**Finding.** D31's evidence is the `han-linear` incident, which is a **channel-two** membership gap. D31 commits the
release to creation on all four targets. Per target:

| Target | Evidence for creation | Verdict |
| --- | --- | --- |
| Channel-two version record | `han-linear` — documented, live | Passes |
| Channel-two listing membership | `han-linear` — same incident | Passes |
| Channel-one version record | none — D19 defines a plugin *by having* this file, so it cannot be missing | Fails |
| Channel-one listing entry | none — every entry present and resolving; D29 records the same | Fails |

Channel-one-listing creation is the **most expensive** of the four — it is the one that must author a description
(F46) — and the **least likely to be needed**: per D21, the contributor guide tells contributors about channel one's
listing and no other target, so the target a forgetful contributor is most likely to have filled in is precisely the one
this capability creates. D29's "the behavior is free, it's the same comparison read the other way" covers *detection*,
not creation.

**Evidence considered.** codebase — all eleven plugin directories carry a channel-one record; all twenty listing entries
across both channels resolve to a real directory (verified by `evidence-based-investigator` and re-checked directly). The
only live membership gap is `han-linear` on channel two.

**Resolution.** Creation is scoped to the two channel-two targets, where the incident lives. A plugin missing from a
channel-one target is a gap creation cannot close. This is the YAGNI rule's "strictly simpler version satisfying the same
evidence": D31's headline promise still fires for the case it exists to serve, and the half with no evidence and the
highest content cost is removed. Keeping all four would have been the symmetry-and-completeness anti-pattern this spec
invokes to reject other items. Recorded as D36.

**Resolved by:** user input (option: scope to the two channel-two targets), on evidence.

**Raised in round:** R2

**Changed in plan:** Outcome, Primary flow (Step 3), Alternate flows and states, Edge cases and failure modes,
Coordinations

**Changed in decision log:** D36 added; D31 corrected

**Changed in tech-notes:** —

### F48: D31's "no plugin for which the phrase is undefined" is false for the shape D19 deliberately admits

**Agent:** `devops-engineer` (DOR-023 and DOR-R2-05), `junior-developer` (JD-108), `adversarial-validator` (V7),
`evidence-based-investigator` (F44 in its own numbering). Five independent arrivals from four specialists.

**Category:** universal claim contradicted by a case the spec designed for

**Finding.** D31 asserts: "'The version the release is publishing' is defined for every plugin… **There is no plugin for
which the phrase is undefined, so creation never has to guess.**" That holds only because the release reads the current
version from the plugin's channel-one record. **D19 explicitly rejected defining a plugin that way**, and kept the
contrary case alive on purpose: "Define a plugin as a directory with a channel-one manifest. Rejected: makes a
channel-two-only plugin invisible, which is the current bug mirrored."

So the spec insists a channel-two-only plugin is a plugin the rule must see, and for that plugin the release has nothing
to read, no target version, and creation would have to guess exactly where D31 says it never does. Two decisions cannot
both be unqualified.

**Evidence considered.** codebase — `.claude/skills/han-release/SKILL.md:157` reads `current` from
`{source}/.claude-plugin/plugin.json`; `:159-164` derives `baseline` from the same path. codebase — no such plugin exists
today; all eleven directories carry a channel-one record. So this is a false universal, not a live break.

**Resolution.** D31's claim is narrowed to every plugin carrying a channel-one record, which is every plugin today, and a
plugin whose publishing version cannot be determined joins the gaps creation cannot close. Every agent that raised this
independently recommended against building a version-inference rule for a shape with zero members, and that
recommendation is taken: the gate already has the right verb, so the fix costs a clause and no machinery. Recorded on
D36 and as a correction to D31.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Primary flow (Step 3), Alternate flows and states, Edge cases and failure modes

**Changed in decision log:** D36 added; D31 corrected

**Changed in tech-notes:** —

### F49: Creation is the headline capability and nothing tells anyone it happened

**Agent:** `devops-engineer` (DOR-R2-06), with `adversarial-validator` (V3) and `edge-case-explorer` (F-R2-2) arriving at
the same silence from the confirmation-gate side.

**Category:** silent write reproducing the defect the work exists to close

**Finding.** The spec is scrupulous that refusals are loud: the gate names every gap rather than the first, check
failures name the plugin and every target, and D30 exists so "malformed" is a category rather than a residue. Creation —
the capability F30 added and the Outcome now advertises — has no such commitment. The spec calls it "the ordinary path,
not the failure path", and the ordinary path is silent.

It is silent in the release too: the version plan's vocabulary is bumped / unchanged / new, with no term for a created
record, and a release whose plan needs no confirmation prints nothing at all. So a release can create a plugin's
channel-two membership and version record, publish it, and never mention it.

A process that writes to what Han publishes without saying so is a smaller instance of the defect being repaired. The
whole diagnosis is that something quietly stopped happening and nothing asked; a repair that quietly starts happening is
the same shape.

The adjacent and larger worry, raised independently: creation makes a directory publicly installable with **no
sign-off**, a bigger act than the version bump that does get a mandatory confirmation.

**Evidence considered.** codebase — `.claude/skills/han-release/SKILL.md:306-315` and `:220-226` print one line per
plugin in the bumped/unchanged/new vocabulary; `:219-221` prompts for nothing when no plugin needs confirmation.
Behavioral — D12 already establishes that naming the full set at once is what the release owes a maintainer.

**Resolution.** A release reports what it created and corrected — which plugin, which targets, at what version — in the
report it already prints. Recorded as D39. The confirmation gate is deferred rather than rejected: reporting is the
strictly simpler thing that satisfies the same concern, and the case a confirmation guards against (a half-built plugin
merged and released before anyone noticed) has never happened. Recorded in Deferred (YAGNI) with a trigger.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Primary flow (Step 3), Alternate flows and states, Edge cases and failure modes, User interactions,
Deferred (YAGNI)

**Changed in decision log:** D39 added

**Changed in tech-notes:** —

### F50: The bundle's exception is stated in verbs that predate the release's ability to create

**Agent:** `devops-engineer` (DOR-017) and `junior-developer` (JD-107), convergent.

**Category:** unstated coordination between two decisions that never met

**Finding.** D6 states the exception in exactly two verbs, both about looking: the bundle's absence from channel two is
never **flagged**, and it is never **asked to agree**. D31 gave the release a third verb — **create** — and carries no
bundle qualifier at all. Step 3 then repeated both verbs and added "**The exception stops there**", a sentence that
actively instructs a narrow reading, immediately before widening the rule back onto the bundle.

The tell that the two decisions never met: D6's dependent-decisions list did not include D31, and D31's did not
include D6.

An implementer applying D31 literally creates a channel-two listing entry and version record for the bundle. The gate
cannot catch it, because the exception told the rule not to look at the bundle on that channel — so the one plugin the
rule was instructed to ignore is the one the release would wrongly publish, silently and on every subsequent release.

**Evidence considered.** codebase — `.agents/plugins/marketplace.json` contains no `han` entry and there is no
`han/.codex-plugin/`, so the bundle is permanently and correctly missing from two targets. codebase — `README.md:72-73`:
"Codex does not yet support meta-plugins like `han@han` (see openai/codex#23531,) and it resolves no dependencies". A
safe reading existed via D19's "belongs in" and one Edge-cases row, which is why this is a "say it" finding rather than a
"this is broken" one — but the cost of the implementer reading Step 3's unqualified sentence instead of that row is a
release publishing a meta-plugin to a channel that cannot install it.

**Resolution.** The exception is restated against what the rule does on channel two rather than against an enumerated
verb list, so the next verb inherits it: never flagged, never asked to agree, **never created**. The Edge-cases row
carries the third verb too. D6 and D31 are added to each other's dependent-decision lists.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Primary flow (Step 3), Edge cases and failure modes

**Changed in decision log:** D6 extended; D31 corrected

**Changed in tech-notes:** —

### F51: The gate's approval anchor names a prompt that is off by default and misses the one that is not

**Agent:** `devops-engineer` (DOR-020 and DOR-R2-02) and `junior-developer` (JD-105), convergent.

**Category:** R1 resolution resting on a mis-read of the release

**Finding.** F39's resolution anchored the gate to two boundaries: irreversibility, and "before it asks anyone to approve
publishing", on the rationale that "a gate that refuses after approval teaches people to distrust it". Both halves fail.

**The prompt it names is opt-in and off by default.** So on the ordinary path nobody is asked to approve publishing at
all, and the boundary is vacuous — the late edge is unbounded again, which is the state F39 objected to.

**The approval that always happens is earlier and on the wrong side of the writes.** The release's confirmation of its
version plan is its single mandatory gate, and it runs *before* the target writes. D24 forbids the gate from running
before those writes. So the gate is **structurally** after an operator authorization: F39 did not close the window, it
named the wrong door. The rationale is not merely unmet, it is unmeetable given D24's own early boundary.

**Evidence considered.** codebase — `.claude/skills/han-release/SKILL.md:317-320` fires the publish prompt only "If
`pause_before_publish` is true"; `:65-67` defaults it to **false**. codebase — `:214-226` is titled "Confirm the plan
(**single mandatory gate**)" and runs at Step 3, before Step 4's writes.

**Resolution.** The unmeetable clause is dropped. The gate keeps the two boundaries it can honor — it runs on the state
being released, after the writes, before anything irreversible — and the spec states the consequence honestly rather than
denying it: a release can refuse after the operator has confirmed a version plan, and what the gate owes them is that
nothing was published and every gap is named at once. The reviewer's alternative (split the gate so its membership half
answers before the plan confirmation) was not taken: it is a real change to D24's one-gate decision, and D24 rejected two
gates for reasons that still hold.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Primary flow (Step 3), Alternate flows and states, User interactions

**Changed in decision log:** D24 corrected

**Changed in tech-notes:** —

### F52: The branch-cut flow's backstop claim does not survive a release that repairs

**Agent:** `devops-engineer` (DOR-022, with DOR-R2-07 scoping the same sentence from the step-3 side).

**Category:** stated safety net that catches nothing

**Finding.** The flow claimed: "A release is cut from a branch where a step has not landed. What stops it is the
release's own gate… the release gate is the only surface a missing step is caught on." Enumerate the instantiations
after D31 and nothing is left:

- Step 3 not landed → the branch carries the old release, which has no gate at all.
- Step 4 not landed → the release now **repairs** the drift rather than stopping.
- Step 1 not landed → the release creates the missing records; the spec's own flow calls this "the ordinary path".
- Steps 5, 6, 7 → the gate does not inspect dependency declarations, documents, or its own existence.

The sentence was true before F30, when the gate stopped on any version disagreement — precisely what a branch missing
step 4 has. D31 replaced the stop with a repair and the claim was not revisited. If a maintainer relies on it — cutting
from a feature branch believing the gate will refuse if something is missing — the release proceeds and publishes a state
nobody intended.

**Evidence considered.** codebase — `.claude/skills/han-release/SKILL.md:76-78` explicitly permits cutting from a
non-default branch ("do not stop… surface the fact, do not block"), and `.github/workflows/ci.yml` triggers on
`pull_request`, so a branch with no pull request gets no pipeline run. There is no second surface.

**Resolution.** The flow is restated to what is true: a release cut from a branch missing a step is mostly not caught,
and the gate's job is the gaps a release cannot close rather than the steps of this plan. The restatement also names the
gain the old claim obscured — after D31, cutting from a branch missing step 1 or step 4 is *safe* rather than merely
caught, because the release repairs it. Same honest-downgrade shape D32 already applied to the check.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Alternate flows and states

**Changed in decision log:** D24 corrected

**Changed in tech-notes:** —

### F54: The gate-stop recovery does not account for the release's own writes, and the naive move skips the mandatory confirmation

**Agent:** `devops-engineer` (DOR-019 and DOR-R2-04) and `junior-developer` (JD-104), convergent.

**Category:** recovery path that does not survive F30's resolution

**Finding.** F38's resolution gave the gate stop its own recovery: "Recovery is **not** discarding local changes — the
gap is in the repository and not in the release's uncommitted work. The gap must be corrected and committed."

The first clause is right about the gap and wrong about the tree. At gate-stop time the tree always holds the release's
own work, because D24 places the gate after all four target writes. The two stated recoveries therefore overlap rather
than compose, and the spec never says what becomes of those writes — though they must go somewhere, since the release
refuses to start dirty.

Both available moves are bad and the spec picks neither:

- **Commit everything.** The gap fix lands together with the release's half-applied version bumps. On the re-run the
  release sees those versions as already ahead of their baseline, takes the ahead path, needs no confirmation, and its
  **single mandatory gate is silently skipped**. Recovering from a gate stop converts a confirmed release into an
  unprompted one — a step of the release deciding something a person was supposed to decide, which is the class of defect
  this work exists to end.
- **Discard, then fix.** Actually correct, but the spec's sentence reads as prohibiting it. And a careless discard is not
  enough: creation writes **untracked** files, which survive a discard aimed at modified ones and keep the tree dirty —
  a second loop, this one caused by creation.

**Evidence considered.** codebase — `.claude/skills/han-release/SKILL.md:72-74` hard-stops on a dirty tree and counts
untracked files (`git status --porcelain` at `:37`). `:203-213` takes the ahead path when `current` is strictly ahead of
`baseline` ("**No confirmation for this plugin**"); `:219-221` "If no plugin needs confirmation… **Do not prompt**".

**Resolution.** The recovery is stated as two acts in order: the release's own local work is discarded first, including
what it created, then the gap is corrected and committed on its own, then the release re-runs and plans from scratch.
The spec states the reason rather than only the sequence, because the reason is the load-bearing part. This does not
reopen D28. A separate point from `edge-case-explorer` (F-R2-5) is folded in: the correction must reach the branch
releases are cut from, since a gap fixed only on a throwaway release branch is still there for everyone else.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Alternate flows and states

**Changed in decision log:** D34 completed

**Changed in tech-notes:** —

### F55: D33 states a sentence rule and applies a proximity rule

**Agent:** `adversarial-validator` (V3)

**Category:** scoping rule contradicting its own worked example

**Finding.** D33 claims its test is "whether the sentence is being rewritten regardless", explicitly not proximity. Its
one worked example applies proximity. The orientation document's three relevant paragraphs are separate: the paragraph
naming the four plugins that depend on the core plugin (falsified by step 5), the paragraph describing the bundle's own
dependencies (already false, **not** falsified), and a third paragraph about the opt-in plugins (falsified). The
already-false claim sits in its own paragraph, about a different subject, between two that are genuinely being rewritten
— and the spec justified pulling it in with "the surrounding sentences are being rewritten", which is adjacency, the
"sits nearby" reasoning D7 and the Out-of-scope section name and reject.

Left unbounded, a future implementer could extend "passage" to "anything in a document step 6 touches", which is the
open-ended audit D33's own rejected alternatives say it refuses to become.

**Evidence considered.** codebase — verified directly during consolidation: the three paragraphs are distinct, and the
bundle paragraph's dependency list omits `han-communication` while the real manifest includes it.

**Resolution.** The boundary is stated: **a passage is the paragraph** — narrower than the document-wide audit, wider
than a sentence, and the unit a person actually rewrites. Under that rule the worked example does **not** qualify, and
saying so is the point. It is corrected anyway by a route it does qualify under: that paragraph is one of the document's
dependency enumerations, and step 6 is already rewriting those to drop their counts and name the manifests as the record
(D26). Applying that remedy means checking the enumeration against the manifests, and one that disagrees is corrected by
the act of applying it — not by being nearby.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Primary flow (Step 6)

**Changed in decision log:** D33 bounded

**Changed in tech-notes:** —

### F56: "The window does not exist" was stated as fact and nothing operationalized "one unit"

**Agent:** `adversarial-validator` (V5)

**Category:** unstated assumption inside a structural claim

**Finding.** D18 rejected "add a precondition that no release is cut in the window" because "it relies on a maintainer
honoring a promise with nothing enforcing it", and F29 claimed the structural fix instead: "The two steps land together,
and the window does not exist." Nothing in the spec or the decision log said what "land together" means. If it is not
atomic — one commit, one change — the fix is still a promise, which is the thing D18 says it rejected. Nothing in this
repository enforces atomicity: T2 already established nothing blocks anything here.

**Evidence considered.** provided/codebase — no statement of single-commit or single-pull-request delivery exists
anywhere in the spec or decision log. T2's live configuration confirms nothing enforces it.

**Resolution.** Largely absorbed: F44 removed the 3+4 unit entirely, so the claim it was attached to is gone. What
survives applies to steps 5 and 6, which remain a genuine unit. The Coordinations bullet now says they ship in a single
change rather than in two that follow each other closely, and states plainly that this is a commitment about how the work
is shipped rather than a property of the work — because nothing here enforces it.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Primary flow (binding constraints), Coordinations

**Changed in decision log:** D38 added

**Changed in tech-notes:** —

### F58: A half-finished removal would be silently undone by a repairing release

**Agent:** `edge-case-explorer` (F-R2-1)

**Category:** silent write reproducing the defect the work exists to close

**Finding.** The spec never addresses plugin **removal**, and D31 makes its absence consequential. D19 defines a plugin
inclusively — a directory the suite ships as an installable unit — deliberately rejecting "has a channel-one manifest"
so a channel-two-only plugin stays visible. So a directory that survives a half-finished removal is still a plugin, and
per D31 its now-missing channel-two records are simply "missing from a target" and get **created back** — silently
republishing what a maintainer was retiring. D29 covers only the mirror case (a listing entry pointing at nothing).

Removal is not hypothetical: the release process already versions "a child was removed from the suite" as a major bump.

**Evidence considered.** codebase — the release skill's removal rule confirms removal is an anticipated event.
Behavioral — D19's inclusive definition plus D31's create-path compose into the resurrection without either decision
saying so.

**Resolution.** The rule refuses the ambiguity rather than guessing at intent. "Never published here" and "published
here until yesterday" are the same state on disk, and inferring the difference would mean consulting history to guess a
person's intention on a case with no live instance. So: a plugin the repository still carries is a plugin the rule
expects in every target it belongs in — a directory that remains is a plugin, and removing a plugin means removing the
directory. That gives the maintainer one thing to get right instead of four, which is the simplification the rest of the
work is built on. Recorded as D40.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Alternate flows and states, Edge cases and failure modes

**Changed in decision log:** D40 added

**Changed in tech-notes:** —

### F59: A corrupt storefront listing would route a whole channel into the create-path

**Agent:** `edge-case-explorer` (F-R2-3)

**Category:** boundary of a rule written for a different artifact shape

**Finding.** D35's rule ("a record that cannot be read is surfaced and blocking, never a plugin quietly dropped") is
written and evidenced entirely in terms of a **per-plugin record**. The spec's own glossary distinguishes the two shapes:
a storefront listing is "one per channel", a single shared file covering every plugin. If that file fails to parse — a
trigger D35 itself names, a hand-editing slip during steps 1 or 4 — every plugin in the channel would appear
simultaneously missing from that target, which post-D31 means "missing → create". A corrupted listing could therefore
trigger a mass-creation pass that regenerates the file rather than surfacing one blocking failure. D35's own rejected
alternative ("treat an unreadable record as a missing one — rejected: it produces the right stop for the wrong reason")
was never stated for the shared shape.

**Evidence considered.** codebase — D35's own cited evidence (`.claude/skills/han-release/SKILL.md:37,39`) reads the
whole listing in one call covering every plugin, so the mismatch between the rule's wording and its evidence is in the
decision itself.

**Resolution.** An unreadable storefront listing is surfaced and blocking for that whole channel, never read as mass
absence. Added to Edge cases and recorded as an extension to D35. This is not a symmetry argument — the failure is silent
and would regenerate a published file, which is the loudest possible version of the defect the work exists to end.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Edge cases and failure modes

**Changed in decision log:** D35 extended

**Changed in tech-notes:** —

### F61: "Stays green" and "not blocked by the check" outlive F28's correction

**Agent:** `devops-engineer` (DOR-021), `junior-developer` (JD-109), `adversarial-validator` (V6). Three independent
greps for surviving blocking language found exactly these two.

**Category:** overclaim outliving its correction

**Finding.** Two sentences still carry the pre-F28 assumption that a pull-request check blocks:

- Step 7: "the check is green on the day it arrives **and stays green**." Only true of a check that blocks. The spec
  contradicts it directly two sections away ("If they merge past it — **which they can** — the next release creates the
  missing records itself"), and it is cited to D1, whose corrected rationale is precisely that on an advisory surface the
  failure mode is a red check people scroll past. It sits two paragraphs below the sentence F28 deleted for the same
  reason.
- Outcome: "so a contributor following the contributor guide is **not blocked by the check**" — implies a blocking
  capability that merely fails to trigger here, when T2 established the check cannot block anyone in any case.

**Evidence considered.** T2 (live platform configuration, re-verified in R2 by `evidence-based-investigator` C3: the
default branch returns not-protected, zero rules apply, the sole ruleset is disabled with no required-status-check rule).

**Resolution.** "Stays green" is replaced with what is actually true and makes D1's restated rationale visible where the
check lands: green on arrival, red on the pull request that introduces a gap, mergeable past, and the default branch then
carries a red check until the next release repairs it. "Not blocked by" becomes "not flagged by".

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Outcome, Primary flow (Step 7)

**Changed in tech-notes:** —

### F63: The examine-first guarantee is stated absolutely and evidenced only for foreign annotations

**Agent:** `edge-case-explorer` (F-R2-4)

**Category:** boundary between adjacent categories

**Finding.** Step 2 states generally: "A work item whose annotation the publisher does not recognize is surfaced as a
format error, and **the run stops before creating anything at all**". D3, its citation, is scoped and evidenced
specifically for the **foreign-annotation** case — its rationale is about avoiding duplicate publication to another
tracker. D30 separately broadens "accounted for" to every malformed heading and names the plain case as "the most likely
malformation in practice". The spec never says whether the examine-first guarantee — justified only for foreign
annotations — extends to the plain malformed case, though its own wording ("at all", "before the first item is
published") reads as uniform.

**Evidence considered.** codebase — the publisher's repair pass carries "Malformed heading" as a distinct category,
separate from the foreign-annotation gate, so the two are already different things in the code. D30's own text names the
hyphen-versus-dash case as the likely one.

**Resolution.** Stated explicitly, with the reason rather than by symmetry: the publisher cannot tell the two apart until
it has looked — a heading it fails to parse might be another tracker's annotation in a shape it does not know, or a
hand-edited line with the wrong dash. They need the same answer because the cheaper answer (publish what you understood,
then complain) is the one that creates issues in a file that may already have been published elsewhere.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Primary flow (Step 2)

**Changed in tech-notes:** —

### F64: "Nine gaps" is stated as flat fact three times and is conditional

**Agent:** `junior-developer` (JD-106)

**Category:** unverified count driving spec prose (the class F32 established)

**Finding.** Step 1 creates the Linear plugin's record at its channel-one version (D22), so **it arrives agreeing**. At
the moment step 3 lands the count is **eight** disagreements, not nine, and two plugins agree rather than one. Yet Step 3
said "every plugin but **one** has version records that disagree" and "a gate that is live against **nine** gaps", and
Step 4 said "This step closes **nine** gaps, not eight". The ninth exists only if a release is cut between step 1 and
step 3 — Step 1's own F34 caveat says so — so the spec asserted as certain, in three places, something its own Step 1
paragraph makes conditional.

**Evidence considered.** codebase — verified independently by `evidence-based-investigator` (C1) and by direct read of
every manifest on both channels: eight plugins disagree, `han-communication` agrees, `han-linear` has no channel-two
record, the bundle has none by design.

**Resolution.** Stated as eight, with the ninth named as a contingency rather than a count. The point the number served —
the gate is live against a red repository — is itself removed by F44, so what remains is Step 4's scope. Same reasoning
F32 used: the qualitative point does not depend on the number, so the number should be right.

**Resolved by:** evidence.

**Raised in round:** R2

**Changed in plan:** Primary flow (Step 3, Step 4)

**Changed in tech-notes:** —

## Rejected findings

- **F65 (rejected): D18's execution-order numeral list is not inconsistent with its gloss.** `edge-case-explorer` read
  "The steps execute as 1, 2, 6, 3, 4, 5, 7" as spec numbering and concluded the following gloss described 1–7 in order.
  The list is stated in **the source plan's** numbering, as the sentence says, and the steps' own `_Source position:_`
  annotations confirm it: spec steps 1–7 carry source positions 1, 2, 6, 3, 4, 5, 7 respectively. The gloss matches the
  list exactly. No change.
- **F66 (rejected): `han-atlassian`'s `han-communication` declaration is not a fourth untrue dependency.** Raised by one
  `adversarial-validator` pass as a possible fourth deletion by the same grep test that condemned the other three, and
  refuted by a second `adversarial-validator` pass and by `evidence-based-investigator` (C4, C5) independently. All three
  agree on the facts — `han-atlassian` never names `han-communication`, and its wrapped skills invoke it one layer down —
  and the disagreement was on the verdict. Resolved by evidence rather than by preferring an agent: `README.md:84-85`
  documents the declaration's purpose directly ("Because Codex resolves no dependencies, install `han-communication`
  alongside `han-atlassian` (its wrapped prose-producing skills source the shared readability standard from it)"), and
  `docs/concepts.md:225-227` documents the identical transitive-necessity pattern for the `han-planning` and `han-coding`
  edges. The declaration is real and deliberate. The gap was that D8 and D25 never stated the test that distinguishes it
  from `han-linear`'s — recorded as F62 rather than as a deletion. Step 5 remains three.

## Minor edits

- F42: Open item 4 is parked with no dependent step, which is the same shape F22 used to remove the old open item 3 —
  the spec applies one test in two directions. — `junior-developer` (JD-007) — Open items (item 4 restated as homeless
  and kept deliberately, with F22's rule restated rather than contradicted)
- F43: D29's evidence leans on the `d94daa2` atomic-rename precedent, which undercuts itself — that commit updated the
  listings in the same commit, so the dangling-entry state has never existed here. The behavior is free (it is the
  mirror of the comparison D19 already requires) and is kept; the evidence wording is corrected to say so rather than
  lean on a precedent that demonstrates the opposite. — `adversarial-validator` (V4) — Edge cases (D29 evidence
  wording; behavior unchanged)
- F53: F29's resolution named four spec sections and no decision, so the steps-3+4 unit was written into the spec while
  D18 continued to say "precedes" — the spec cited D18 for a claim D18 never made. F44 vindicated D18, so the fix is a
  note recording that the decision was right and the citing document was wrong, rather than an edit. — `junior-developer`
  (JD-102) — D18 (annotated; no outcome change)
- F57: Creation writes untracked files, which survive a discard aimed at modified files and keep the tree dirty — a
  second recovery loop caused by creation rather than by the gap. — `junior-developer` (JD-104) — Alternate flows
  (folded into F54's resolution and D34)
- F60: D35's non-circularity argument asserts that plugin identity survives an unreadable manifest because "D19 defines a
  plugin by the manifest's presence, not its contents" — a filesystem-based identity, while the release's existing
  convention matches records by the name **inside** them, and D19 explicitly defers detection to the implementation plan.
  The behavioral commitment survives either way (the failure can be named by the directory it was found in), so the
  argument is softened rather than the outcome changed. — `adversarial-validator` (V4) — D35 (rationale; behavior
  unchanged)
- F62: D8 verifies `han-atlassian`'s `han-core` edge "by use, not by self-description" and calls the manifest true on the
  strength of it, while three other declared edges went uncited — and one of them (`han-communication`) would fail the
  very test D8 states it is applying. All four were verified in R2 and all four are real, but the distinction that makes
  the fourth real was never written down: a declaration whose *wrapped* skills exercise it is genuine; a declaration
  whose plugin is not granted the means to call anything is not. — `evidence-based-investigator` (F46),
  `adversarial-validator` (V1) — D8 (evidence extended; conclusion unchanged)
