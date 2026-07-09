# Research: readability-guidance skill vs. full delegation

<!--
Evidence gathered (2026-07-09) to evaluate whether han-communication should expose a
`readability-guidance` skill that surfaces the readability standard into a calling
skill's context for in-voice drafting, instead of (or alongside) the readability-editor
rewrite pass. Two sources: a Claude Code docs review (mechanical feasibility) and an
in-repo evidence pass. Trust classes noted per finding.
-->

## Question

Can `han-communication` expose a `readability-guidance` skill that other skills invoke to get direct, in-context access to the readability rule and writing-voice profile, so they draft readable output in the first place — rather than each consuming skill dispatching the readability-editor for a post-hoc rewrite pass? Is that mechanically possible, and is it a better approach?

## Evidence

### Mechanical feasibility (trust class: Claude Code docs; some inference)

- **Skills invoked via the Skill tool run in the same conversation context.** The rendered `SKILL.md` content enters the conversation and stays for the session — unlike the Agent tool, which spawns an isolated subagent that returns only a summary. So a guidance skill *can* surface its resources into the calling skill's context. (Documented.)
- **Cross-plugin sourcing works only by qualified-name invocation, never by path.** `${CLAUDE_PLUGIN_ROOT}` / `${CLAUDE_SKILL_DIR}` and every relative path resolve within the reading skill's own plugin. A guidance skill reads *its own* plugin's `references/` and is *invoked* cross-plugin by `plugin:skill` name — the same mechanism the plan already relies on for `edit-for-readability`. So the approach adds no new cross-plugin mechanism beyond what the plan already assumes.
- **Two behavioral unknowns remain (flagged "test this").** Whether skill-invokes-skill fires reliably mid-workflow, and whether the agent cleanly resumes the caller's drafting after absorbing the guidance, are not documented. These are reliability questions, not blockers, and warrant a prototype.
- **Context cost.** Guidance content persists in the caller's context (shared ~25k-token re-attach budget after compaction). The trade against the editor is: persistent in-caller context vs. a separate-context subagent dispatch.

### In-repo precedent and current pattern (trust class: codebase)

- **A resource-surfacing skill already exists.** `han-plugin-builder/skills/guidance/SKILL.md:25-57` ("Guidance Mode") reads its own `references/` via `${CLAUDE_SKILL_DIR}` and applies only the doc(s) that fit — the exact pattern proposed, and the sole precedent in the suite.
- **In-voice drafting is already the established pattern.** All 13 consuming skills apply the readability rule *as they draft* and run an inline self-check (13 cited SKILL.md lines; `docs/readability.md`). 9 of the 13 *additionally* dispatch `readability-editor`; 4 explicitly run no rewrite pass.
- **No cross-plugin file read exists anywhere today** (negative evidence across all plugins); shared standards are handled by byte-identical vendoring, which this feature removes.

### Quality rationale for the separate adversarial pass (trust class: codebase / design rationale)

- **The rewrite is reserved for synthesis skills, on a self-evaluation-bias rationale.** The editor's prompt: "assume it opens with throat-clearing… buries its point… prove otherwise or fix it" (`readability-editor.md:12`). `CONTRIBUTING.md:73` scopes the rewrite to "a skill with a synthesis or editor step."
- **`docs/readability.md` states the standard is applied in stages, never as one block**, and warns "Loading is not compliance. Loading the rule does not make output readable" (`docs/readability.md:11,12,42-51`). Self-check-only (no rewrite) is an accepted sufficient tier for non-synthesis skills, not a degraded fallback (`docs/readability.md:79`).

### Cost signal (trust class: web-sourced, illustrative)

- `multi-agent-economics.md` states each agent dispatch adds latency and token cost, with a single-agent-sufficiency heuristic. The exact multipliers are labeled illustrative (web-sourced), so treat the efficiency claim as directional, not measured.

## Correction: the repo's own composition guidance (missed in the first pass)

The initial research above missed `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-composition.md`, which the R4 adversarial review surfaced. That doc distinguishes **orchestration composition** (a caller hands a whole artifact-owning workflow to a sub-skill — supported; what the readability-editor already is) from **data-fetch composition** (calling a sub-skill "only to retrieve a few structured values… for the calling skill to use immediately" — "Do not do this"). A `readability-guidance` skill that surfaces reference content for the caller to apply is the data-fetch shape. The documented failure: a **forked** (`context: fork`) data-fetch sub-skill returns, an `api_retry` event anchors the caller on the sub-skill's output, and the caller bypasses its remaining steps — "not reliably fixed by any frontmatter or instruction tuning." The doc's default for shared values is inline duplication (vendoring). This materially weakens the original "precedented, low-risk" framing, and it corrects a factual error: the readability-editor is dispatched via the **Agent** tool (isolated subagent), not the same-context **Skill** tool the guidance skill would use.

## Prototype spike (in-session, 2026-07-09) — weak positive signal, not a reliability result

Built a minimal **inline (non-forked)** `rg-proto-guidance` skill plus a four-step `rg-proto-consumer` that invokes it mid-workflow, and ran the composition three times. The caller resumed and completed all four steps 3/3 (no early exit). This is a weak signal only:

- The tester (this model) was motivated to complete the run; the documented failure is unconscious anchoring, not reproducible on demand.
- No `api_retry` fired; the failure mode's trigger was never exercised.
- The proto skills were trivial; real consumers carry far more state across the Skill call, which the doc ties directly to a higher loss-of-workflow risk.
- The proto used no `context: fork`; the documented failure is fork-specific, so this tested the safer variant.

**Design lead:** the guidance skill should be inline (no `context: fork`), and framed so it surfaces content into the shared context rather than "returning a value" — a shape distinct from the forked data-fetch the doc warns against. The in-session run does not establish reliability; `skill-composition.md` is not updated on this evidence.

## Rigorous spike (subagent harness, 2026-07-09) — inline validated, forked disqualified, api_retry not exercised

The OI-3 spike replaced the weak in-session proto with a harness that fixes its two correctable flaws: unbiased testers and a heavy consumer. Five real project skills were created in `.claude/skills/` (plumbing verified first: a freshly-created project skill hot-loads and renders into a sub-agent's context via the Skill tool). The consumer was a heavy six-step incident post-mortem builder that reads a telemetry file, extracts four facts it must carry across the guidance call, drafts a five-section report, self-checks, and writes an artifact ending in a machine-checkable `CONSUMER_COMPLETE` token. Each trial ran in a **fresh sub-agent told only to run the skill** — never that early-exit was being measured — which removes the motivated-tester bias. Completion was judged from the artifacts on disk, not from sub-agent self-report.

Four arms, 46 trials:

| Arm | Mechanism | Completed | Early exits |
|-----|-----------|-----------|-------------|
| Inline | same-context Skill call + explicit continuation instruction | 12/12 | 0 |
| Forked | `context: fork` | 12/12 | 0 |
| Baseline | direct file read, no Skill call (isolates consumer flakiness) | 12/12 | 0 |
| Adversarial inline | Skill call, all continuation guardrails stripped, worst-case "you are done" anchor | 10/10 | 0 |

Findings:

- **Zero early exits across all 34 same-context Skill-call invocations.** The baseline's 12/12 confirms the consumer is not flaky, so the Skill call itself introduced no completion loss. The adversarial arm is the strongest signal: it removes the mitigation the composition doc says only *reduces* the failure and adds a maximal stop-anchor, and testers still resumed 10/10 — several explicitly reasoning that the anchor "applies only to the readability step, not my overall task."
- **Forked is disqualified for a different reason than early-exit.** Multiple forked-arm testers reported unprompted that `context: fork` isolated the guidance so its content never reached the caller — only a summary/marker returned. A resource-surfacing skill that never surfaces its content is useless. This independently confirms the design lead: **the skill must be inline.**
- **The api_retry trigger was never fired.** It is an infrastructure-level fault (transient 429/500/overload) that no sub-agent harness can inject, and it is the specific documented trigger of the early-exit failure. So neither arm exercised the exact failure path — which is also why the forked arm did not reproduce the documented forked early-exit. The result reduces the risk by inference (adversarial arm holding without the mitigation), not by measurement, and is specific to the harness model (Opus 4.8). Absence of reproduction is not proof the failure cannot occur.

On this evidence, `skill-composition.md` **is** updated to record the inline resource-surfacing variant as a supported exception — scoped honestly to "reliable under adversarial same-context testing; api_retry not directly exercised," not "the failure is disproven."

## Conclusion

Mechanically feasible (precedented, documented same-context composition, no new cross-plugin risk), pending a prototype of the two behavioral unknowns. The efficiency intuition holds for skills that need no rewrite, but the suite's own design says single-pass loading is insufficient for synthesis output. The strongest design is therefore **both**, staged: `readability-guidance` restores in-voice drafting + self-check cross-plugin (for all consumers), and the `readability-editor` rewrite is retained for synthesis skills only. This preserves `docs/readability.md`'s staged model that a single full-delegation rewrite pass would otherwise collapse, and it removes the forced rewrite the earlier full-delegation plan added to the four non-synthesis skills. It also rehabilitates the hybrid rejected earlier (team-findings F3), whose only blocker — sourcing the blocklist cross-plugin — the guidance skill removes.
