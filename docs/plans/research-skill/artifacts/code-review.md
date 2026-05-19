# Code Review: `/research` skill

**Scope:** the new `/research` skill and its supporting files, reviewed against
this repo's own authoring guidance and the canonical spec
(`docs/plans/research-skill/feature-specification.md`, decisions D1–D24).
**Size:** large (user override). **Branch:** `research-and-swarm`.
**Roster:** manual review (Steps 4–6) + `junior-developer` + `adversarial-security-analyst`.

> Spec and decision-log artifacts under `docs/plans/` are planning records and
> were not held to source-style standards.

## Review Summary

| ID | Severity | Category | Location | Finding |
|----|----------|----------|----------|---------|
| CRIT-001 | Critical | [Security] | `plugin/agents/adversarial-validator.md:24-52` | D7's evidence-gathering-integrity validation is chartered in the `/research` SKILL.md and report template but the shared `adversarial-validator` agent has a closed 3-strategy protocol that does not include it — the web-reach threat model's last line of defense depends on brief text overriding the agent's hardcoded contract |
| WARN-001 | Warning | [Security] | `plugin/skills/research/SKILL.md:100` | Step 5 (the brief enforcement point) bars only "codebase contents or repository paths"; the Operating Principles (line 24) also bar operator context. The CLAUDE.md content read in Step 1 is operator context an implementer could leak into the web-facing brief |
| WARN-002 | Warning | [Standard: sizing.md] | `docs/skills/research.md` | `/research` is sizing-aware (D5) but its long-form doc has no `## Sizing` section; `docs/sizing.md` (lines 35, 99) and its cross-skill table direct readers to that section in every sizing-aware skill's doc |
| WARN-003 | Warning | [Docs Update] | `CLAUDE.md:54`, `docs/sizing.md` Related reading | Two stale enumerations still list only the original six sizing/swarming skills, omitting `/research`; D20 named these as rollout updates |
| WARN-004 | Warning | [Standard: writing-voice.md] | all 5 research files | Em-dashes appear throughout; `writing-voice.md` bans them unconditionally. **Project-pattern deference applies** — every existing plugin file uses em-dashes (`investigate` 19, `architectural-analysis` 30), so this is not corrective for `/research` in isolation. The written standard and universal practice contradict each other repo-wide; the team should reconcile one of them. Not auto-fixed (see note below). |
| SUGG-001 | Suggestion | [Consistency] | `plugin/skills/research/references/research-report-template.md:88` | Artifacts comment says IDs cross-reference "from the Summary's solidity phrase" but the Summary section says "no IDs" — internal contradiction |
| SUGG-002 | Suggestion | [Docs] | `docs/agents/research-analyst.md:85+` | Related documentation omits `codebase-explorer`, which runs in parallel with `research-analyst` on every codebase-bearing run |
| SUGG-003 | Suggestion | [Standard: agent-building] | `plugin/agents/research-analyst.md:8` | Role-identity paragraph runs ~67 tokens against the ~50-token budget in the agent-building guidance |
| SUGG-004 | Suggestion | [Docs] | `docs/agents/research-analyst.md:69` | Link resolves to the `artifacts/` directory rather than the specific `skills-calling-skills-investigation.md` file |
| SUGG-005 | Suggestion | [Consistency] | `plugin/skills/research/SKILL.md:5` | `argument-hint` omits the D23 evidence-mode opt-in, though Step 1 detects it and the long-form doc documents it |

## Conformance confirmed

- **D22** — `allowed-tools` omits `Skill`; tool set is least-privilege for the stated behavior.
- **D9** — bidirectional routing complete (all 5 neighbors point back; verified in prior pass).
- **D16** — data-not-instruction and trust-class controls are written into both the SKILL.md and the agent with real force (`SKILL.md:23,98`, `research-analyst.md:36,87`).
- **D23 / D24** — evidence-mode behavior and the fixed report structure are implemented and match the template.
- Frontmatter, long-form template structure, README-backlink convention, the CONTRIBUTING "Adding a skill / agent" checklist, and the `19 skills / 22 agents / 7 sizing-aware` counts are all consistent.

## 🔴 Critical

### CRIT-001 — D7 evidence-gathering-integrity validation is not enforced by the agent it relies on

- **Category:** [Security]
- **Location:** `plugin/agents/adversarial-validator.md:24-52`; chartered at `plugin/skills/research/SKILL.md:124` and `references/research-report-template.md:62`
- **Finding:** `/research`'s web-reach threat model (D16) names the `adversarial-validator` pass as the last line of defense: D7 charters it to attack "the integrity of the evidence-gathering — whether any artifact could have been introduced or shaped by external content designed to influence the output." But the shared `adversarial-validator` agent definition has a *closed* protocol: three strategies (Challenge the Evidence / the Fix / the Assumptions), "You MUST attempt all three strategies. Never skip one," "Minimum 5 items across the three strategies," and a domain vocabulary with no terms for indirect prompt injection, astroturfing, source staleness, or single-source laundering. The fourth strategy exists only in `/research`'s runtime brief text, which must override the agent's hardcoded contract.
- **Exploit path (agent-supplied):** an attacker publishes a page with directive text and a fabricated benchmark; `research-analyst` records it as an artifact; `adversarial-validator` runs its three codebase-investigation strategies (none meaningful for a research report), satisfies "minimum 5 items" with empty checks, and returns without performing the injection-integrity check — the false artifact survives into the recommendation.
- **Fix:** add a fourth, generally-applicable strategy ("Challenge the Evidence-Gathering Integrity") to the `adversarial-validator` agent, with matching vocabulary and an anti-pattern, applicable whenever the inputs include gathered or external evidence (always for `/research`; valuable for `/investigate` too — planted/stale/flaky evidence). Update the "all three"/"minimum 5 across the three" wording and the long-form agent doc. Additive and low-risk for existing consumers.

## 🟠 Warning

### WARN-001 — Step 5 brief exclusion is narrower than the Operating Principle

- **Category:** [Security]
- **Location:** `plugin/skills/research/SKILL.md:100` vs `:24`
- **Finding:** the Operating Principles bar "codebase contents or operator context" from the web-facing brief; Step 5 — the point an implementer actually constructs the brief — bars only "No codebase contents or repository paths." Step 1 reads CLAUDE.md (operator context); an implementer following only Step 5 could pass it into the web-facing brief, the precondition for context exfiltration the D16 isolation control exists to prevent.
- **Fix:** make Step 5's exclusion match the principle: bar codebase contents, repository paths, and operator/CLAUDE context.

### WARN-002 — Missing `## Sizing` section in the long-form doc

- **Category:** [Standard: sizing.md]
- **Location:** `docs/skills/research.md`
- **Finding:** `/research` is the 7th sizing-aware skill (D5). `docs/sizing.md:35` and `:99` and the cross-skill table tell readers every sizing-aware skill's long-form doc carries a `## Sizing` section with the per-skill signals and caps. All six existing sizing-aware skill docs have one; `research.md` does not.
- **Fix:** add a `## Sizing` section mirroring the peer docs, with the research-specific signals from D15 and the band caps from the SKILL.md.

### WARN-003 — Stale six-skill enumerations

- **Category:** [Docs Update]
- **Location:** `CLAUDE.md:54`; `docs/sizing.md` Related reading
- **Finding:** `CLAUDE.md:54` still says "the six swarming skills (`/architectural-analysis` … `/plan-implementation`)"; `docs/sizing.md`'s Related-reading bullet lists the same six. Both omit `/research`. D20 enumerated these as rollout updates; they are now inaccurate.
- **Fix:** add `/research` to both enumerations and update "six" to "seven".

### WARN-004 — Em-dashes violate writing-voice.md (project-deference applies; not auto-fixed)

- **Category:** [Standard: writing-voice.md]
- **Location:** all five research files (33 in `SKILL.md` alone)
- **Finding:** `writing-voice.md` and `CONTRIBUTING.md` state "No em-dash, '—', anywhere, ever." The research files use them heavily.
- **Why not corrected:** the review's project-pattern-deference rule states a pattern consistent within the project is not a review finding. Em-dash use is universal across the plugin (every SKILL.md, every agent, every long-form doc). De-em-dashing only `/research` would make it the lone outlier and is out of scope for a review of one skill. This is a repo-wide standard-versus-practice contradiction that predates `/research`. **Recommendation:** the team decides repo-wide — either amend `writing-voice.md`/`CONTRIBUTING.md` to match practice, or schedule a global pass. Surfaced for a conscious decision, not corrected here.

## 🔵 Suggestion

### SUGG-001 — Template Summary/cross-ref contradiction

- **Location:** `references/research-report-template.md:88` vs `:6`
- **Fix:** the Artifacts comment lists "the Summary's solidity phrase" as a cross-reference source, but the Summary is specified as ID-free. Drop that clause; cross-references live in Research Results, Options, and Recommendation.

### SUGG-002 — `codebase-explorer` missing from research-analyst Related docs

- **Location:** `docs/agents/research-analyst.md` Related documentation
- **Fix:** add `codebase-explorer`; it runs in parallel with `research-analyst` on every codebase-bearing `/research` run.

### SUGG-003 — Role-identity paragraph over token budget

- **Location:** `plugin/agents/research-analyst.md:8`
- **Fix:** tighten the opening identity to ~50 tokens per the agent-building guidance.

### SUGG-004 — Directory link should target the file

- **Location:** `docs/agents/research-analyst.md:69`
- **Fix:** point the link at `../plans/research-skill/artifacts/skills-calling-skills-investigation.md`, not the `artifacts/` directory.

### SUGG-005 — `argument-hint` omits the evidence-mode opt-in

- **Location:** `plugin/skills/research/SKILL.md:5`
- **Fix:** add the D23 evidence-mode opt-in to the hint so the affordance is discoverable, consistent with Step 1 and the long-form doc.

## Disposition

CRIT-001, WARN-001, WARN-002, WARN-003, and all five suggestions are corrected
in the same change as this review. WARN-004 (em-dashes) is surfaced for a
repo-wide decision and deliberately not corrected in isolation.
