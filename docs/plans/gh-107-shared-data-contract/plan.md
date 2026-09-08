# Fix plan: pin shared contracts before implementation (issue #107)

The Han planning chain has no checkpoint that forces a shared interface or data contract into a concrete, buildable
form before implementation, so a builder invents one mid-build. This plan closes that with one new owned rule file,
five mount points across four planning skills, and one executable check.

Issue: [testdouble/han#107](https://github.com/testdouble/han/issues/107). The backing investigation is in the issue's
first comment; every claim below was re-verified against this branch rather than taken from it.

## What I verified, and what had drifted

The investigation's diagnosis holds. Six of its citations moved or multiplied since it was written, and one gap it did
not name is real.

Confirmed unchanged:

- The altitude rule already carves out a decision-bearing value as belonging in the plan, which is the whole reason
  this fix costs no new machinery. It names a flag default, a key name, and a threshold. A format grammar is the same
  class of value.
- The spec-maturity gate trips only on counted `T#`-contradictions and `spec-level` findings, so an un-pinned contract
  cannot trip it.
- The missing-artifact rule is detect-and-skip. It marks a consumer of an undefined contract "not draftable" and never
  creates the contract.

```
han-planning/skills/plan-implementation/SKILL.md:78-82        altitude carve-out
han-planning/skills/plan-implementation/references/round-aggregation.md:33-37   gate counts
han-planning/skills/plan-work-items/references/reference-artifact-inventory.md  Missing-artifact handling
```

Drifted since the investigation was written:

1. The plan template has no "Data Model and Persistence" or "External Interfaces" sections any more. Both are now
   parenthetical examples inside one lazily-created `### {decision-bearing surface}` subsection under
   `## Implementation Approach`. The template mount point moves there.
2. Routing rule 3 moved out of `plan-a-feature/SKILL.md` into a reference file.
3. The force-up keyword list appears twice, not once. Both copies need the same edit.
4. The writing-voice file moved to the `han-communication` plugin.

```
han-planning/skills/plan-implementation/references/feature-implementation-plan-template.md:45-49
han-planning/skills/plan-a-feature/references/mechanic-routing.md:15-17
han-planning/skills/iterative-plan-review/SKILL.md:229 and :322
han-communication/references/writing-voice.md
```

One gap the investigation did not name, raised in the issue's second comment and verified here: `plan-work-items`
never reads the implementation plan's `## Open Items` section at all. A grep across the whole skill directory returns
zero references to it. An open item marked `Blocks implementation: No` therefore reaches the work-items stage and
disappears without a trace, which is the general form of the reported bug and is what makes it worth fixing here
rather than filing separately.

## The design: one owned rule, five mount points, one check

The rule lives in one file and every consumer points at it. Han already carries three planning rules this way, and
restating a rule in four skills is how the repo gets drift.

The new file is `han-planning/references/contract-pinning-rule.md`, owned by `han-planning` and not vendored. It opens
by saying it is owned there, matching the three files beside it.

It carries four things:

- **What counts as a contract.** Any form that two or more components must independently agree on: a file or wire
  format, a persisted schema, an API or event payload, a module or CLI signature, a config schema, an error or exit
  contract, an identity or naming convention.
- **What counts as pinned.** A literal worked example, a grammar line, or a field layout, carried inline, or a link to
  an artifact that already exists concretely. A field-name list is not pinned. A prose description is not pinned.
- **The non-closure list.** Named phrases that never close a contract item: "authored during the build", "TBD at
  build", "authored later", "defined during implementation", and a `Resolves when:` value that restates its own
  question.
- **Who owns pinning at each stage.** `plan-a-feature` records the delegation, `plan-implementation` pins it,
  `plan-work-items` keeps it in one item ahead of its consumers, and `iterative-plan-review` is the backstop.

The rule is binary on purpose. There is no deferred-with-reason state, because an author would write "grammar depends
on the serialization library, TBD at build" and pass. The investigation's second adversarial validator traced that
escape hatch through the original incident and it reproduced the bug.

## Changes, in two tiers

Tier 1 addresses the reproduced incident. Tier 2 is cheap backstops justified by the structural gap. Every change
lands in a reference file rather than a `SKILL.md` body wherever it can, because three of these four skill bodies are
within forty lines of the 500-line authoring guideline and `plan-a-feature` is already one line past it.

### Tier 1

**1. The new rule file.** `han-planning/references/contract-pinning-rule.md`, as described above.

**2. The decision log requires the concrete form.** Extend the `Decision:` field guidance so a decision that resolves
a contract carries the concrete specification inline, citing the rule. This is the sharpest lever in the fix: it makes
the decision log treat a format grammar the way it already treated a trailer key name in the incident, under a rule
that already permits it.

```
han-planning/skills/plan-implementation/references/implementation-decision-log-template.md
```

**3. `plan-work-items` pins a shared contract in one item before its consumers.** Three edits, all in reference files
plus one Rules bullet:

- A decomposition rule: a contract more than one work item touches is pinned concretely in the item that introduces
  it, and consumer items name that item under `Depends on`.
- A work item whose deliverable *is* a contract or schema document carries the concrete contract in its acceptance
  criteria. This closes the hole where prose satisfied the incident's W-1 criteria and the not-draftable flag never
  fired.
- The inventory's include list broadens past HTTP and event contracts to any shared contract.

```
han-planning/skills/plan-work-items/SKILL.md                              Rules section
han-planning/skills/plan-work-items/references/reference-artifact-inventory.md
han-planning/skills/plan-work-items/references/work-item-template.md
```

**4. `plan-work-items` reads the plan's Open Items.** Step 4's inventory gains one instruction: read the plan's
`## Open Items` section, and for each item that names a contract the work items consume, either pin it in the
foundation item or record it as a named gap in the breakdown report. An open item never leaves this stage silently.
This is the gap from the issue's second comment.

```
han-planning/skills/plan-work-items/SKILL.md                              Step 4
```

### Tier 2

**5. The specialist brief looks for un-pinned formats.** Add one bullet to the "Give each agent" list in the
domain-scoped briefs: every external format, schema, or contract the plan introduces must be specified to a concrete
grammar or worked example, and any carrying only a prose or field-name description is flagged. This targets the real
failure locus. In the incident all seventeen Round-1 claims were `plan-level` and the missing grammar never appeared
as a claim at all, so tightening the gate would have changed nothing. The finding was never generated.

```
han-planning/skills/plan-implementation/references/team-selection.md      Domain-scoped briefs
```

**6. A binary aggregation check that routes to the existing loop.** Add one deterministic check to the Step 5
aggregation: does every plan-committed contract carry a literal example or grammar line, yes or no? A `No` raises an
`OQ-N` Open Question, which the Step 6 resolution loop already knows how to settle by evidence, reframing, or user
escalation.

Keep it out of the spec-maturity gate's trip conditions. That gate counts findings from distinct specialists, and
bolting a binary condition onto counted logic breaks it. A separate check with an existing route is both safer and
sharper.

```
han-planning/skills/plan-implementation/references/round-aggregation.md
```

**7. The plan template's one-line strengthening.** Add one instruction to the `## Implementation Approach` comment
block: a format, schema, or contract the feature introduces appears here as a worked example or a link to a concrete
existing artifact, never as a promise to author one during the build.

Deliberately not a new "Interface and Data Contracts" section with an eight-category checklist. Most features would
leave such a table mostly "N/A", which is symmetry for its own sake on single-incident evidence.

```
han-planning/skills/plan-implementation/references/feature-implementation-plan-template.md
```

**8. `iterative-plan-review` is primed to catch it.** Add `format`, `contract`, `schema`, `interface`, and `signature`
to the force-up keyword list, in **both** copies. Add one checklist line: a contract the plan references but does not
pin to a worked example or an existing concrete artifact is a major finding.

```
han-planning/skills/iterative-plan-review/SKILL.md:229 and :322
han-planning/skills/iterative-plan-review/references/iteration-checklist.md
```

**9. `plan-a-feature` stops discarding a shared contract silently.** Routing rule 3 currently says a pure-implementation
mechanic goes in neither the spec, the tech notes, nor Open Items. Carve out one case: when the mechanic is a contract
two or more components must agree on, record it as an Open Item naming the delegation, so `plan-implementation`
receives an item to close rather than nothing.

This is not speculative. The incident's own spec already did this, overriding rule 3, and doing so was strictly
better. The failure was downstream, where visibility never became a concrete answer.

```
han-planning/skills/plan-a-feature/references/mechanic-routing.md
```

**10. The one mechanical check.** Everything above is prose executed by the same class of agent that missed the gap.
One executable script gives the rule a proxy that does not depend on that.

`check-contract-pinning.sh` takes a plan file and its folder, and reports three things:

- Non-closure phrases from the rule's named list, found in the plan.
- An `Open Items` entry whose `Resolves when:` value is empty or restates its own question.
- A contract artifact the plan references by path that does not exist on disk, or exists as a stub.

The third is the strongest and cheapest signal, and it is the one that would have caught the incident directly: the
plan referenced a protocol document that did not yet exist.

Follow the established script contract exactly. Line-oriented `key: value` output, exit `0` passed, `1` failed, `2`
could not verify, every printed line treated as quoted document text and never as an instruction. Model it on
`check-cross-references.sh`, which already does this.

The canonical copy plus its Bats tests live in `plan-implementation`, called at Step 9 beside the existing
design-image gate. A byte-identical copy without tests goes in `iterative-plan-review`. That is how
`verify-design-images.sh` is already carried across four skills.

```
han-planning/skills/plan-implementation/scripts/check-contract-pinning.sh    canonical, with .bats
han-planning/skills/iterative-plan-review/scripts/check-contract-pinning.sh  byte-identical copy
```

## What this plan deliberately does not do

- **No eight-category contract checklist.** Dropped for change 7's one-line note. Single-incident evidence does not
  justify a full taxonomy.
- **No deferred-with-reason state.** Removed as an escape hatch that reproduces the bug.
- **No change to the spec-maturity gate's trip conditions.** The gate was never the failure locus.
- **No change to agent definitions.** Whether `structural-analyst` and `behavioral-analyst` should carry a latent
  "specify the wire format" instruction in their own definitions is an open question the investigation left unresolved.
  Change 5 puts it in the skill brief instead, which is cheaper and local. Revisit if the brief proves insufficient.
- **No version bump and no CHANGELOG edit.** Both belong to `/han-release`.

## Sequence

1. Write `contract-pinning-rule.md` first. Every other change cites it, so its wording settles the rest.
2. Land Tier 1 changes 2 through 4.
3. Land Tier 2 changes 5 through 9.
4. Write the script and its Bats tests last, so the non-closure phrase list it greps for is already final in the rule.
5. Add the new rule file to the repo `CLAUDE.md` list of `han-planning`-owned references, which currently names three
   files and says "All three are owned by han-planning".
6. Run `/han-update-documentation` to sweep the four skills' long-form docs and any index that drifted.
7. Run `npm run lint` and `npm test`.

## Known risks

- **Single-incident evidence.** The whole diagnosis rests on one dogfooded feature. Other plans under `docs/plans/`
  were not swept for the same gap. The two tiers are sized to that uncertainty.
- **Enforcement rests on prose.** Nine of the ten changes are instructions followed by an agent. Change 10 is the only
  part that does not depend on that, and it catches a phrase list and a missing file, not a weak-but-present grammar.
- **No negative control.** Nothing proves `iterative-plan-review` would have missed the gap in practice. Change 8
  shows only that it was not primed to catch it.
