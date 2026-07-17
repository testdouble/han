# Implementation iteration history — phase 3

Companion to [../feature-implementation-plan.md](../feature-implementation-plan.md) and
[implementation-decision-log.md](implementation-decision-log.md).

Source spec: [../feature-specification.md](../feature-specification.md). Phase:
[../build-phase-outline.md](../build-phase-outline.md) Phase 3.

Size: **Medium** (two-to-three subsystems: the release skill, a new check with two consumers, the docs it falsifies; no
auth/PII surface). Team cap 5, round cap 2.

---

## R1 — parallel specialist review

**Specialists engaged.** `han-core:junior-developer` (required; generalist stress-test and reframing),
`han-core:devops-engineer` (the release gate, rollout ordering, and recovery are the spine),
`han-core:edge-case-explorer` (the refusal list and the silent-failure commitments),
`han-core:test-engineer` (the check's testability and contract). All four launched in parallel with domain-scoped briefs
plus [.discovery-notes.md](.discovery-notes.md).

**New input provided.** The measured current state (8 drifted plugins, four target paths, the bundle's shape, the plugin
set's clean derivability), the release skill's exact defect sites, and the spec's committed constraints.

### Claim ledger

| # | Claim | Category | State | Raised by | Maturity |
|---|-------|----------|-------|-----------|----------|
| C1 | The writes must be script-borne, not prose-borne, or the bundle exception lands in two places and D14 is violated at the write step | overlap | **Evidenced** (D14's own rationale names this outcome in advance) | devops | plan-level |
| C2 | `repair` must iterate the derived plugin set unconditionally; inheriting Step 4's `target == current` skip repairs nothing | assumption-refuted | **Evidenced** (`SKILL.md:238`; none of the 8 drifted plugins would be bumped by an ordinary release) | devops | plan-level |
| C3 | The gate belongs immediately after the writes (Step 4.5), not at Step 7 | ambiguity | **Evidenced**, independently by two specialists | devops, junior-dev | plan-level |
| C4 | Step 5's changelog augment path is **not idempotent** (it appends), so a stop after it duplicates on re-run — an independent argument for the early gate | edge-case | **Evidenced** (`SKILL.md:249-255`) | devops | plan-level |
| C5 | The gate must read disk state fresh after the writes; the skill's Project Context is a frontmatter block evaluated **once at invocation**, before the plan and the writes exist | edge-case | **Evidenced** (`SKILL.md:31-41`) | edge-case | plan-level |
| C6 | The untracked-created-file hazard has **zero members** — the channel-two listing is tracked and D36 confines creation to an entry inside it. The spec's rationale is a leftover from a draft where creation reached per-plugin records | assumption-refuted | **Evidenced** (verified: `git ls-files --error-unmatch` succeeds) | devops | spec-level (rationale only; behavior unchanged) |
| C7 | Hedging against C6's non-hazard invites `git clean -fd` into the recovery, which deletes a solo maintainer's unrelated untracked work with no undo — a real hazard created by guarding a fake one | edge-case | **Evidenced** | devops | plan-level |
| C8 | The repair manufactures version bumps: `{dir}/.codex-plugin/plugin.json` is inside `{source}/`, so phase 4's hand-corrections make 8 plugins classify as "changed" → 8 meaningless patch bumps. Recurs on every contributor record fix, which is what phase 6 exists to cause | edge-case | **Evidenced** (verified live against `v4.6.0`) | devops | plan-level |
| C9 | The only target a release can create carries **no version field**, so "created at the version it is publishing" is vacuous for it | assumption-refuted | **Evidenced** (measured: `[.plugins[] \| has("version")] \| unique` → `[false]`) | junior-dev, devops | spec-level (D31 vacuous for creation; binds the records) |
| C10 | D36's boundary is **measurable, not just argued**: channel two's listing entry is the only target with no authored field in it | — | **Evidenced** (measured key sets across all four targets) | junior-dev | plan-level |
| C11 | The check needs **no mode flag**: the release repairs before the check runs, so the repair set and the gap set are exact complements. The surfaces differ by *when*, not *what* | YAGNI-candidate | **Evidenced** (junior-dev walked every row of the spec's failure table; devops concurred independently) | junior-dev, devops | plan-level |
| C12 | The repair must **skip what it cannot safely write** and defer to the single gate; aborting at the unreadable file names one gap and breaks D12 | edge-case | **Evidenced** (D12 + D35 both already demand this shape) | junior-dev | plan-level |
| C13 | `jq -r` prints the literal string `null` for both an explicit null and an absent key, so two broken records string-compare **equal** — defeating D35's "two unreadable values never agree" | edge-case | **Evidenced** (verified directly) | edge-case | plan-level |
| C14 | The skill's existing `jq … 2>/dev/null` idiom, if copied to the listing read, turns a parse failure into "zero entries" — routing the whole channel into the create-path and regenerating the storefront | edge-case | **Evidenced** (`SKILL.md:37,39`; D35 names this outcome) | edge-case | plan-level |
| C15 | Plugin derivation needs a **depth bound** (`*/.claude-plugin/plugin.json`, not a recursive find): `han-plugin-builder` teaches authoring these files and its example avoids collision only by two incidental naming accidents | edge-case | **Evidenced** | edge-case | plan-level |
| C16 | An **empty derived plugin set** makes the check find zero gaps and exit green — invisible-by-construction wearing the gate's clothes | edge-case | **Evidenced** | devops | plan-level |
| C17 | Cross-target matching must key on plugin `name`, not the listing's `source` path (the skill already sets this precedent at `SKILL.md:236`) | edge-case | **Evidenced** | edge-case | plan-level |
| C18 | `CONTRIBUTING.md:138` and `:157` are about moving a **skill**, which touches none of the four targets — phase 3 does **not** falsify them. The real gap is that no "Adding a plugin" section exists and no contributor doc mentions channel two at all | assumption-refuted | **Evidenced** (independently re-verified by the skill author) | junior-dev | plan-level |
| C19 | Testing against the live tree is a trap: phase 4 fixes the 8, so any test asserting them flips; and a green-check test goes red on phase 3's own PR and stays red through phase 4, landing phase 6's red signal four phases early | edge-case | **Evidenced**, independently by two specialists | test-eng, devops | plan-level |
| C20 | The testability boundary is exactly D14's line — queries are script-testable, writes are not. Push the five-gap logic into the check; have the release consume its findings | — | **Evidenced** | test-eng | plan-level |
| C21 | The creation step should consume the check's own gap list rather than re-deriving it, making the bundle's third verb (*not created*) correct **by construction** | overlap | **Evidenced** | test-eng | plan-level |
| C22 | Prose cannot be trusted to gate — nothing stops an agent skipping the check and reaching the push. But the observed failure class is prose that was *wrong*, followed faithfully; an enforcement wrapper guards a class with zero members | ambiguity | **Evidenced** (D14's own rationale) | junior-dev, devops | plan-level |
| C23 | `allowed-tools` grants `Write`/`Edit`, so on a stop the agent can author the missing record itself and re-run to green — D36's boundary crossed by the actor the gate exists to stop. Nothing can be built to prevent it | edge-case | **Evidenced** (`SKILL.md:16-18`) | devops | plan-level |
| C24 | Step 8.1's staging list is a hand enumeration — the same defect class D37 found. Stage by class pathspec | overlap | **Evidenced** | devops | plan-level |
| C25 | The bundle's identity: **derive** from the listing's top-level `.name` vs **hardcode** the literal `han` | — | **Disputed** → resolved, see below | devops + edge-case (derive) vs junior-dev (literal) | plan-level |
| C26 | OQ-5 (approved plan vs repair disagreement) is already answered by the spec — Option A, stated as the ordinary path | — | **Evidenced** | junior-dev, devops | plan-level |

### Spec-maturity gate

**Not tripped.** T#-contradictions: **0** (no specialist contradicted T1 or T2). `spec-level` findings: **3** (C6, C9, and
C18's premise), raised by **2** distinct specialists. The gate requires ≥2 T#-contradictions by ≥2 specialists, or ≥5
`spec-level` findings by ≥3 specialists. Neither threshold met, and all three are rationale/wording corrections that
leave every behavioral commitment intact. No PM facilitation pass was made.

### Open Questions and resolutions

| OQ | Question | Resolution source | Answer |
|----|----------|-------------------|--------|
| OQ-A | Does invoking a script from a skill prompt when `allowed-tools` has no matching pattern? | evidence (deferred to the cheap safe action) | Not worth a separate experiment. Both specialists recommend adding the pattern; it is one frontmatter line and costs nothing if unnecessary. Add `Bash(./scripts/publishing-targets.sh:*)`. |
| OQ-B | Where does the check script live? | evidence (convergence) | `scripts/publishing-targets.sh` at the repo root. Both specialists reached this independently: it is repo maintenance, not any plugin's behavior; shipping it inside `han-*/` would send dead weight to installers and make every fix bump a version the check itself polices; three callers live in three trees. Verified free consequences: the ShellCheck hook has no `files` filter so a root script is covered automatically, and the shebang hook requires `chmod +x` in the same commit. |
| OQ-C | Does phase 3 own authoring the check, or assume it exists? | evidence | Phase 3 owns it. D14 ("the check is executable") plus Phase 6 ("the rule itself is not new here") leave no other reading. The outline's phrasing is an omission, not an ambiguity. Phase 3 is roughly twice the size the outline's wording implies. |
| OQ-D | Bundle identity: derive or hardcode? (C25, Disputed) | evidence | **Derive** from `.claude-plugin/marketplace.json`'s top-level `.name`. The junior-developer's objection — that deriving from a file the check exists to distrust is a knot — dissolves on measurement: no release step writes the top-level `.name` (only `.plugins[].version`), and the check needs that listing readable regardless, so an unreadable listing exits 2 either way. Deriving costs nothing and reuses the definition already at `SKILL.md:44-46`. Verified: marketplace `.name` = `han` = the bundle dir's own name. |
| OQ-5 (inherited) | What should a release do when the approved plan and a target's repair disagree? | evidence | **Discharged by the spec — Option A.** `feature-specification.md:497-500` states it as the ordinary path ("proceeds, whether or not it bumped that plugin this release"); the Deferred-YAGNI item at `:743-756` establishes that creation itself gets no sign-off, so a repair (a strictly smaller act) cannot need one. Under a script-borne argument-free `repair` it is structural rather than instructed. Strike from phase 3's preconditions; do not spend a maintainer round-trip. |

### Next-step recommendation

**Go to synthesis.** The gate did not trip. Every Open Question resolved by evidence or convergence; none required user
input. No specialist named an unengaged handoff (the test-engineer's optional `test-engineer` handoff was already on the
team). The two independent reviews converged on the same structural call (C1/C20 — script-borne writes, one bearer) from
opposite directions, which is the strongest signal available that the call is right.

**Decisions produced:** — _(backfilled at synthesis)_
**Changed in plan:** — _(backfilled at synthesis)_
