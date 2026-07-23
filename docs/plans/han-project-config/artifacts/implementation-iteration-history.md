# Implementation Iteration History: Project-Local Han Configuration

<!--
This file records how the implementation plan for Project-Local Han Configuration evolved across
discussion rounds. Committed decisions live in [implementation-decision-log.md](implementation-decision-log.md)
and the primary plan lives in [../feature-implementation-plan.md](../feature-implementation-plan.md).

This file ALSO consolidates the per-round aggregation output — no separate facilitation files are written.
The claim ledger, Open Questions, and spec-maturity tags from each round live as fields on that round's entry below.
-->

## R1: Parallel specialist review plus the OI-1 live check

- **Specialists engaged:** junior-developer, structural-analyst, information-architect. In parallel, the OI-1
  live-install check ran via a Claude Code documentation agent (spec Open Items required it during implementation
  planning, before plan approval).
- **New input provided:** Initial feature specification, decision log, team findings, technical notes (T1), and the
  Step 2 discovery notes (`.discovery-notes.md`).
- **Claim ledger:**

  | # | Claim | Raised by | Category | State |
  | - | ----- | --------- | -------- | ----- |
  | C1 | The `!`-probe line must be inline per SKILL.md (probes execute in place; an include cannot run them); only the interpretation prose (D6 precedence, D9 degradation/note rule, D14 containment, D5 pool-join) is a factoring candidate. | structural-analyst (S1), junior-developer (JD-001) | overlap | Evidenced (`han-coding/skills/code-review/SKILL.md:16-20`; T1) |
  | C2 | Sharing the resolution contract via cross-plugin skill invocation (readability pattern) would force new dependency edges onto han-feedback, han-linear, and han-plugin-builder — the plugins deliberately designed to depend on nothing. Vendored per-plugin copies (yagni-rule pattern) need no manifest change. | structural-analyst (S2, S3), junior-developer (JD-001/OQ1), information-architect (IA-003) | assumption-refuted | Evidenced (`CONTRIBUTING.md:202-205`; the three `plugin.json` files carry no `dependencies` key; md5-identical yagni-rule copies across 5 plugins) |
  | C3 | Canonical ownership of the `.han/config.md` schema (exact key names, section heading, agent-name matching) belongs in one han-core reference file; vendored copies must be byte-identical mechanical copies, kept short to keep 12-copy drift manageable. | structural-analyst (S3, S4), junior-developer (JD-005, JD-008), information-architect (IA-002, IA-003) | overlap | Evidenced (`han-core/references/` precedent; T1 defers tokens to implementation planning) |
  | C4 | The 15 skills without a `## Project Context` block need only a minimal config-only block (the probe line), not the full CLAUDE.md/discovery/git probe set. | structural-analyst (S5) | edge-case | Evidenced (those skills have no D6 discovery tiers to consult; YAGNI evidence test) |
  | C5 | The extra-agents pool-join is a bespoke per-skill edit across ~10 dispatching skills with differently shaped roster tables, not a uniform pasted block; do not unify the roster tables. | structural-analyst (S6), junior-developer (JD-002/OQ2) | overlap | Evidenced (`han-research/skills/research/SKILL.md:139-169` vs other roster shapes) |
  | C6 | When a han-atlassian wrapper invokes a wrapped skill "to a temporary file," the wrapped skill honoring the output base could relocate the file the wrapper expects. | junior-developer (JD-003/OQ3) | edge-case | Evidenced (`han-atlassian/skills/investigate-to-confluence/SKILL.md:22-23,55`; resolved in R2 via D6) |
  | C7 | D14's "outside the project" containment needs a concrete prompt-expressible rule, since D15 declined to define a repo root and git is optional. | junior-developer (JD-004/OQ4) | ambiguity | Evidenced (F4; `code-review/SKILL.md:93-94` Mode C) |
  | C8 | With no test harness, the 39-file edit needs a stated definition of done: a grep-based completeness check plus representative spot-runs; no new CI or fixtures. | junior-developer (JD-006/OQ6) | edge-case | Evidenced (discovery notes: no harness; D4 uniform-participation promise) |
  | C9 | OI-1 must gate plan approval; a negative result reopens D1. | junior-developer (JD-007/OQ7), information-architect (sequencing note) | overlap | Evidenced (spec Open Items OI-1); check ran this round — see resolutions |
  | C10 | The consuming-engineer docs are load-bearing (Han cannot seed the file): one canonical operator doc at repo-root `docs/` (proposed `docs/configuration.md`) carrying the only annotated schema example; scent links in `docs/concepts.md` and quickstart Path D; CLAUDE.md registration; project-discovery SKILL.md and long-form doc updated for D10. | information-architect (IA-001, IA-002, IA-004, IA-005, IA-007, IA-008) | edge-case | Evidenced (`docs/sizing.md`/`yagni.md`/`evidence.md`/`readability.md` precedent; `docs/concepts.md:126-201`; `han-core/docs/skills/project-discovery.md` omits D10 behavior) |
  | C11 | Do NOT sweep all ~39 skill long-form docs, and skip `docs/choosing-a-han-plugin.md`, `docs/workflows.md`, and the four mechanic docs. | information-architect (IA-006, IA-009) | YAGNI-candidate | Evidenced (cross-suite mechanics precedent: per-skill docs do not re-document them) |
  | C12 | D4's stated counts (26/15) are stale against the tree (24/15 of 39); the plan must enumerate participating skills at execution time, never hardcode totals. | junior-developer, discovery notes | edge-case | Evidenced (grep of `*/skills/*/SKILL.md`; repo count-free convention) |
  | C13 | D10's pointer offer fits project-discovery as a new step between the existing write step and verification, reusing its consent/dedup pattern; no new abstraction. | structural-analyst (S7) | edge-case | Evidenced (`han-core/skills/project-discovery/SKILL.md:72-106`) |
  | C14 | T1 contradiction check: none found; T1's mechanics match the codebase exactly. | structural-analyst (S8), junior-developer, information-architect | T#-check | Evidenced (independent verification against `code-review/SKILL.md:16-20`) |

- **Open Questions raised:**
  - OQ-1: Where does the canonical config-resolution guidance live, given three plugins depend on nothing? (C2, C3)
  - OQ-2: Are the dispatching-skill edits scoped as a separate bespoke pass? (C5)
  - OQ-3: Does the output base apply to a wrapped skill's temporary files when a wrapper invokes it? (C6)
  - OQ-4: What is the concrete prompt-expressible containment test for the output base? (C7)
  - OQ-5: What are the fixed schema tokens — output-directory key, extra-agents heading, agent-name matching rule? (C3)
  - OQ-6: What is the definition of done and verification method for the suite-wide edit? (C8)
  - OQ-7: Is OI-1 sequenced as the gating step zero, and what did the check find? (C9)
- **Spec-maturity tags:** plan-level: OQ-1 through OQ-7 (all seven). spec-level: none. T#-contradiction: none. The
  spec-maturity gate did not trip; no PM facilitation call was made.
- **Resolution source:** carried into R2.
- **Decisions produced:** D-1, D-2, D-3, D-4, D-5, D-6, D-7, D-8, D-9, D-10, D-11, D-12, D-13 (every implementation decision traces to an R1 finding; D-8, D-10, D-11, D-12 and the R1 halves of the rest were settled by R1 convergent evidence, the seven OQ-linked decisions carried into R2).
- **Changed in plan:** Implementation Approach (all subsections); Work Units and Sequencing; Definition of Done; Testing Strategy; Risks and Assumptions; Deferred (YAGNI).
- **Next-step recommendation (deterministic):** Continue iterating — junior-developer named system-architect (OQ-1)
  and behavioral-analyst (OQ-3) as candidate handoffs, and plan-level Open Questions remained unresolved. R2 first
  attempts evidence resolution per Step 6 before any re-engagement.

## R2: Evidence-resolution pass

- **Specialists engaged:** None re-engaged. Every Open Question resolved by evidence already in hand — the two named
  handoffs (system-architect for OQ-1, behavioral-analyst for OQ-3) were not launched because R1's own convergent
  evidence and the spec's committed decisions settled both questions without new analysis.
- **New input provided:** The OI-1 check result (returned during R1), the convergent R1 findings, the feature spec's
  D6 precedence chain re-read against OQ-3.
- **Claim ledger:** No new claims. C1 through C14 carried forward unchanged; C6's state updated from open to resolved
  (see OQ-3 below).
- **Open Questions raised:** None new. Resolutions of R1's seven:
  - **OQ-1 — resolved by evidence.** Canonical config-resolution rule file in `han-core/references/`, vendored
    byte-identical into every plugin that carries skills, kept deliberately short. The alternative (cross-plugin
    skill invocation) fails on hard evidence: it would force new dependency edges onto han-feedback, han-linear, and
    han-plugin-builder, contradicting their documented depends-on-nothing design (`CONTRIBUTING.md:202-205`, repo
    CLAUDE.md). Structural-analyst and junior-developer reached the same answer independently; the system-architect
    handoff was unnecessary.
  - **OQ-2 — resolved by evidence.** Yes: the plan scopes the dispatching-skill pool-join edits as their own work
    unit, per skill, reusing each skill's own cap vocabulary; roster tables are not unified (YAGNI, S6).
  - **OQ-3 — resolved by evidence.** The spec already answers it: D6 puts explicit input above the config file. A
    wrapper that directs its wrapped skill to write "to a temporary file" is giving explicit output instructions,
    which outrank the configured base. The plan records this reading and has the wrapper skills' briefs pass explicit
    paths; no behavioral change and no behavioral-analyst handoff needed.
  - **OQ-4 — resolved by evidence.** Containment test expressed from D15's working-directory basis: the value must be
    a relative path; reject absolute paths and any path whose normalized form escapes the working directory (a
    leading `/`, a drive prefix, or `..` traversal above the working directory), then resolve relative to the working
    directory. Matches D14's accident-not-adversary intent and needs no repo-root or git concept.
  - **OQ-5 — resolved by evidence.** Tokens pinned from T1's own wording and suite convention: frontmatter key
    `output-directory` (T1 names "an output-directory key"); extra-agents section heading `## Extra Agents`; entries
    are one agent per list line, accepted in qualified `plugin:agent` form (the suite's roster convention, research
    A20) or bare-name form, matched case-insensitively against agents available in the session; anything unresolved
    is skipped with the D5 one-line note.
  - **OQ-6 — resolved by evidence.** Definition of done: a grep-based completeness check (every participating
    SKILL.md carries the probe line; every plugin carries the vendored rule file; vendored copies are byte-identical
    to canonical) plus manual spot-runs of one representative skill per category — a deliverable-writer, a
    dispatcher, a wrapper, and a config-irrelevant skill, each with a present, absent, and broken config. No CI, no
    fixture repo (YAGNI; reopening trigger recorded).
  - **OQ-7 — resolved by evidence.** The OI-1 check ran during R1 via the Claude Code docs agent. Verdict: the
    load-bearing claim holds. Official plugin docs confirm a plugin-root CLAUDE.md is not loaded as project context,
    and plugin user-configuration is user-scoped — project-level `.claude/settings.json` entries for it are
    explicitly ignored. The one nuance found — a plugin can be *enabled* at project scope via `enabledPlugins` in
    `.claude/settings.json` — governs plugin activation, not delivery of per-repo override values, so it does not
    give Han a way to ship or seed the config. D1 stands; OI-1 is closed, and the plan is not blocked on it.
- **Spec-maturity tags:** plan-level: 7 of 7 resolved. spec-level: none. T#-contradiction: none. Gate did not trip.
- **Resolution source:** OQ-1 evidence; OQ-2 evidence; OQ-3 evidence (spec D6); OQ-4 evidence; OQ-5 evidence (T1 plus
  suite convention); OQ-6 evidence; OQ-7 evidence (live documentation check plus local install inspection).
- **Decisions produced:** D-2, D-4, D-5, D-6, D-7, D-9, D-13 (the seven decisions settled by R2's OQ resolutions; each also lists R1 under Driven by rounds).
- **Changed in plan:** Implementation Approach (Where the shared contract lives; The config schema tokens; Keeping the output base inside the project; Extra agents joining the candidate pool; Wrapper skills and wrapped temporary files); Work Units and Sequencing; Definition of Done.
- **Next-step recommendation (deterministic):** Go to synthesis. No open plan-level questions remain, no handoffs are
  outstanding, and the round produced zero new findings.
