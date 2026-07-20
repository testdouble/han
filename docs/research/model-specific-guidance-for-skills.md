# Research: Should Han skills carry model-specific guidance for Sonnet 5, Opus 4.8, and Fable 5?

**The recommendation is to keep Han's shipped skills model-agnostic, exactly as they are today, and add per-model guidance for skill authors in the plugin-building layer instead.** The models genuinely differ, but a skill cannot reliably detect which one is running it, so the right place to act on the differences is when an author writes a skill, not when the skill runs.

The open-ended question this report answers: should Han's authoring skills carry model-specific instructions that change with the model running them (Sonnet 5, Opus 4.8, Fable 5, or a generalized fallback), and is per-model tailoring feasible and worth the cost?

Evidence mode: **strict** (default; no opt-out was requested).

## Summary

The differences between these models are real and documented, but the right place to act on them is when an author writes a skill, not when the skill runs. Anthropic publishes a separate prompting page for each of the three models, and the guidance genuinely diverges. Opus 4.8 and Sonnet 5 follow instructions literally and want every behavior spelled out. Fable 5 wants goals instead of step-by-step checklists, and can even refuse a request that tells it to echo its own reasoning into its answer. So yes, there is enough difference to matter.

The problem is that a skill cannot reliably find out which model is running it. Claude Code does not hand the active model to a skill through any documented, stable channel, and asking a model to name itself is unreliable. Building skills that branch on the current model would rest on a foundation that is not there. It would also double or triple the number of files to maintain, and would break when the suite runs on a non-Claude host.

That recommendation keeps the shipped skills model-agnostic exactly as they are today, which is already the "generalized fallback," and adds per-model guidance for skill authors in the plugin-building layer instead. The one skill with a documented, model-sensitive risk today (`readability-guidance`) is the first concrete candidate for an opt-in per-model note. The core of this recommendation is strongly supported; the case for how much the models differ leans on Anthropic's own documentation more than on independent testing.

- **Confidence:** Medium

## Research Results

**Anthropic documents genuine, sometimes opposite, prompting differences across the three models.** Each model has its own prompting page (A1, A2, A3) on top of a shared page of techniques that apply to every current model (A4). The differences are not cosmetic. The sharpest ones a skill author would care about:

- **Thinking mode differs by model.** Opus 4.8 has thinking off unless you turn it on; Sonnet 5 has it on by default; Fable 5 always has it on and cannot turn it off (A1, A2, A3, A4, A5 all agree).
- **Instruction-following runs in opposite directions.** Opus 4.8 and Sonnet 5 read instructions literally and do not generalize on their own, so they need explicit scope (A1, A2). Fable 5's own page says the opposite is now the risk. Spelling out every step with a checklist degrades its output; a short, goal-based instruction works better (A3, corroborated independently by A8). A skill written to one model's guidance points the other in the wrong direction.
- **Fable 5 can refuse a "show your reasoning" instruction.** Fable 5 carries safety classifiers that can return a refusal for a prompt telling the model to echo or transcribe its own thinking into the visible response (A3) [single-source]. This is the one difference that could cause a functional failure rather than a style mismatch, because "explain your reasoning in the output" is a common instruction pattern in agentic skills.
- **Effort and subagent eagerness differ in degree.** The `effort` knob exists on all three but the same label does not mean the same thing across them, and the three models reach for subagents with different eagerness (A1, A2, A3).

Guidance is not sparse for any of the three named models; each page runs to several detailed sections (A1, A2, A3). The honest gap is the generalized fallback. Anthropic publishes nothing specific for an unnamed or future model beyond the shared "techniques for all current models" section (A4). That section is the best available baseline, but by definition it cannot reflect a specific new model's defaults.

**A skill cannot reliably learn which model is running it.** This is the finding that decides the question. Claude Code exposes no `$CLAUDE_MODEL` environment variable (A10). A skill's `model` frontmatter field sets the model for the turn; it does not report the current one (A11, confirmed in-repo by A28). No skill string-substitution carries model identity the way session id and effort do (A11). The one place Claude Code surfaces a live model id is the statusline feed, which is a one-way channel to the terminal with no path back into the model's context (A12). The active model is not even a stable fact for a session, because `/model` can switch it mid-session (A13).

There is one narrow, deterministic path: a `SessionStart` hook can read an optional `model` field and inject it into context (A15). It comes with three limits, all sourced. The field is not guaranteed present (A10). It goes stale the moment the user switches models (A13). And hooks are a Claude Code extension outside the portable Agent Skills standard, so this path does not carry to Codex or other runtimes (A11, A14).

There is also a channel this research initially missed, which the validation pass surfaced (V1): Claude Code's own system prompt states the model's name in context. That makes reading the current model more reliable on Claude Code than the blind self-identification the research literature measures, because the model is reading an asserted string rather than guessing. It is still the wrong foundation for shipped skills. It is undocumented as a stable contract, harness-specific, and absent on other hosts, which is the same class of weakness as the `SessionStart` field.

**Asking a model to name itself is unreliable.** Two independent studies converge. About 26% of 27 tested models misidentified themselves when asked directly (A16). Only 4 of 10 models could recognize their own output, near chance (A17). These measure blind self-identification, not branching when the model's name is already asserted in context (V1), so they bound the weakest form of self-report rather than every form. Even so, any mechanism that depends on the model correctly reporting itself is standing on a documented failure mode.

**Full per-model skills would be a large, drift-prone maintenance surface that also breaks portability.** Han has 48 skill files and roughly 100 reference files across ten plugins (A27; the exact reference count is 103 to 107 depending on what you include, per V7). Duplicating skills per model multiplies that surface, and keeping variants in sync is the classic place drift creeps in.

Portability is a harder constraint. Prior research on issue #78 (A23) found that Claude Code and Codex have separate model namespaces, and that Claude model names break on Codex. The fix was to remove skill-level model overrides rather than translate them. Codex does not even register Han's agents (A24), and Han's current skills carry no model field at all; they reference everything model-neutrally (A19, A20, A22). Nothing in the plugin-building guidance addresses model-conditional skills today (A25, A26).

**A model-sensitivity risk already exists in the suite.** The project's own spike testing of the foundational `readability-guidance` skill flagged that its results came from Opus 4.8 subagents and might not hold on smaller or faster models (A29). This is not a hypothetical: it is a concrete, already-recorded case where a skill's behavior may depend on the model, which is exactly what an opt-in per-model note is for.

## Options to Consider

### O1: Keep skills model-agnostic (the current state, which is also the fallback)

- **What it is:** Change nothing in how skills are written. Every skill stays one model-neutral definition, authored against Anthropic's shared cross-model techniques (A4). This state already serves as the generalized fallback for any model.
- **Trade-offs:** Simplest to author and maintain, fully portable across Claude Code and Codex (A19, A20, A22, A23, A24), and immune to the self-identification failure mode because it never asks (A16, A17). It forgoes any model-tailored guidance, including the Fable 5 refusal-trap warning (A3), which a purely generic instruction set has no way to surface to an author.
- **Rests on:** (A4, A19, A20, A22, A23, A24); avoided failure mode (A16, A17).
- **Evidence status:** corroborated (codebase + web).

### O2: Runtime model-conditional skills (branch on the active model)

- **What it is:** Make skills adapt at runtime through inline "if running on model X" sections, per-model reference files the skill chooses among, separate per-model skill variants, or a `SessionStart` hook that injects the model name (A15).
- **Trade-offs:** Every shape except the hook needs the skill to know the current model, and no reliable, documented way to know it exists (A10, A11, A12, A13, A18). The shapes that skip the hook fall back to self-report, which fails often (A16, A17). The hook path is the only one on a real signal, but it is not guaranteed present, goes stale on a model switch, and breaks on non-Claude hosts (A10, A13, A11, A14). All variant shapes multiply the maintenance surface (A27) and invite drift, and Anthropic's own skills ship no such pattern (A18).
- **Rests on:** (A10, A11, A12, A13, A14, A15, A16, A17, A18, A27).
- **Evidence status:** corroborated (web + codebase).

### O3: Author-time model guidance, model-agnostic runtime

- **What it is:** Keep shipped skills model-agnostic (O1) as the runtime default and fallback. Add per-model guidance to the plugin-building layer (`han-plugin-builder`) that tells a skill author how each model's documented behavior should shape the instructions they write. Flag the Fable 5 reasoning-echo refusal trap so authors avoid the "show your reasoning in the output" pattern where it matters (A3). Allow a skill to opt into a per-model reference note only where a documented functional divergence justifies it; `readability-guidance` is the first concrete candidate, given its recorded model-sensitivity flag (A29).
- **Trade-offs:** Captures the real, high-impact differences (A1, A2, A3) at the one point where the model is known: the author chooses the target when they write. It adds no runtime detection, no portability risk, and no per-skill duplication, because the guidance lives in the authoring layer that already exists (A25, A26). Its cost is upkeep of one guidance document against Anthropic's release cadence, since the model pages are pinned snapshots that get revised and archived (A5). It does not make a single skill behave differently per model on its own; it improves how skills are written.
- **Rests on:** (A1, A2, A3, A4, A5, A25, A26, A29); model-agnostic default inherits O1's basis.
- **Evidence status:** corroborated (web + codebase), with the per-model behavioral characterization leaning on single-vendor documentation (see Validation V5).

### O4: Force a known-good model per step (control, not detection)

- **What it is:** Use the skill `model` frontmatter as a control (A11, A28) to force a specific model for a step that a weaker model handles badly. This sidesteps detection, because the skill sets the model rather than reading it.
- **Trade-offs:** Available today and needs no detection. But it sends a Claude-specific model name across the host boundary, which is the exact failure issue #78 removed from the planning skills (A23). The plugin-building guidance already tells skills not to override the model at dispatch (A22). It also overrides the user's chosen session model, which contradicts the `inherit` default the suite settled on.
- **Rests on:** (A11, A22, A23, A28).
- **Evidence status:** corroborated (codebase).

## Recommendation

- **Recommendation:** Adopt **O3**. Keep the shipped skills model-agnostic (the O1 state) as the runtime default and the generalized fallback. Add per-model guidance for skill authors in `han-plugin-builder`, starting with the Fable 5 reasoning-echo refusal warning and an opt-in per-model note for `readability-guidance`. Reject **O2** as the suite default. Record the `SessionStart` hook (A15) as the only sound runtime-detection path, reserved for a future Claude-Code-only skill that proves a hard need. Reject **O4** as a general pattern for the same portability reason issue #78 already settled.
- **Evidence basis:** The load-bearing half of this recommendation, that runtime branching is the wrong default, rests on corroborated evidence. Claude Code exposes no reliable model signal to a skill (A10, A11, A12, A13, confirmed in-repo by A28). Self-report is unreliable (A16, A17, two independent studies). And runtime variants break portability and multiply maintenance (A23, A24, A27). A sensitivity check (V8) found this conclusion holds even if any single one of those artifacts is discounted. The other half, that the models differ enough to be worth author-time guidance, rests mainly on Anthropic's own prompting pages (A1, A2, A3). That evidence is corroborated for the goals-versus-checklist difference by one independent source (A8), but is otherwise single-vendor; the Fable 5 refusal category is single-source (A3) [single-source]. That is why the improvement is scoped to author guidance rather than automated behavior, and why overall confidence is Medium rather than High.

## Validation

### V1: The research missed the system-prompt model-identity channel

- **Strategy:** Challenge the Evidence
- **Investigation:** The validator observed that Claude Code's system prompt states the running model's name in context, a channel the mechanism angle never considered.
- **Result:** Partially Refuted (the "only path is the SessionStart hook" claim was overstated).
- **Impact:** The Research Results now name this channel and reject it on the same grounds as the hook: undocumented as a stable contract, harness-specific, and absent on other hosts. It does not change the recommendation, and it narrows how far the self-identification studies (A16, A17) can be stretched.

### V2: The agent model-tier count was wrong

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Direct enumeration of every agent file's `model:` field.
- **Result:** Refuted. The correct distribution is 10 opus, 10 sonnet, 3 haiku across the 23 han-core agents, not the "9 / ~13 / 3" the codebase angle first reported. This matches the count in the prior issue-78 research (A21, A23).
- **Impact:** Corrected in A21. It does not bear on the options, but it prompted a recount of the file-surface claim (V7).

### V3: `readability-guidance` is a concrete per-model candidate, not a hypothetical one

- **Strategy:** Challenge the Options Framing
- **Investigation:** The validator found the project's own spike report flagging that `readability-guidance` was tested only on Opus 4.8 and might behave differently on smaller or faster models (A29).
- **Result:** Confirmed.
- **Impact:** O3's scope was rewritten to name `readability-guidance` as the first opt-in candidate, so the option no longer reads as purely speculative future work.

### V4: The core mechanism claims are independently confirmed in-repo

- **Strategy:** Challenge the Recommendation
- **Investigation:** The validator read `skill-frontmatter-fields.md` (A28) and grepped every SKILL.md for a `model:` line and for the old "run on sonnet" planning-skill language.
- **Result:** Confirmed. The skill `model` field is documented in-repo as a setter, no SKILL.md carries a model field, and the issue-78 fix has landed.
- **Impact:** Strengthens the recommendation's central pillar with a source independent of the cited web docs.

### V5: The behavioral-divergence case is largely single-vendor

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The validator traced the per-model behavioral claims to their origins.
- **Result:** Partially Refuted as a fabrication risk (Fable 5 and Opus 4.8 appear in this repo's records predating this research). But it is confirmed as a single-source concern: the behavioral claims trace to Anthropic's own docs. A7 amplifies rather than independently confirms them, and A8 is the one loosely independent corroboration.
- **Impact:** The recommendation scopes the model-difference case to author guidance rather than automated behavior, and confidence is held at Medium for this reason.

### V6: The options set missed the "force a model" mechanism

- **Strategy:** Challenge the Options Framing
- **Investigation:** The validator noted a skill could force a known-good model with the `model` frontmatter control rather than detect the active one.
- **Result:** Confirmed as a gap in the option set.
- **Impact:** Added as O4 and rejected on the issue-78 portability grounds (A22, A23).

### V7: The file-count framing was imprecise

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Direct counts of reference files across the ten plugins.
- **Result:** Partially Refuted. The real reference-file count is 103 to 107 depending on inclusion rules, not exactly 99, and much of `han-plugin-builder`'s 41 files are authoring guidance that would not need per-model duplication.
- **Impact:** The maintenance-burden claim is softened accordingly (A27). The burden is still real and large; the precise multiplier was dropped.

### V8: Sensitivity test on the reject-O2 conclusion

- **Strategy:** Challenge the Recommendation
- **Investigation:** The validator discounted each load-bearing artifact in turn and re-ran the reject-O2 logic.
- **Result:** Confirmed. The conclusion survives discounting any single one of A15, A16/A17, A23/A24, or A27, because it is over-determined by independent in-repo facts (V4).
- **Impact:** Raises confidence in the core call. It also exposed one condition the recommendation should watch, folded in below.

### Adjustments Made

- Corrected the agent tier count to 10 opus / 10 sonnet / 3 haiku (V2, A21).
- Named and rejected the system-prompt model-identity channel rather than implying the hook is the only path (V1).
- Rewrote O3's scope to name `readability-guidance` as the first concrete opt-in candidate (V3, A29).
- Added O4 (force a model) and rejected it (V6).
- Softened the file-count and maintenance framing (V7, A27).
- Added a revisit condition to the confidence assessment: if a future release makes the active model a documented, stable context field, O2 becomes newly feasible and this recommendation should be revisited (V8).

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** The reject-O2 half of the recommendation is high-confidence and over-determined (V4, V8). The model-difference half rests mainly on single-vendor documentation (A1, A2, A3), with the Fable 5 refusal category carried single-source (A3, V5). If that page is revised or was mischaracterized, the specifics of the author guidance would need updating, though not the structural recommendation. The model pages are pinned snapshots that Anthropic revises and archives (A5), so O3's guidance document carries ongoing upkeep. The recommendation should be revisited if the active model ever becomes a documented, stable context field a skill can read (V8).

## Sources

| ID  | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
| --- | --- | --- | --- | --- | --- | --- |
| A1  | Prompting Claude Opus 4.8 | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-4-8 | 2026-07-20 | web | Opus 4.8 reads prompts literally, needs explicit scope, favors reasoning over tool calls | corroborated in part by A7 |
| A2  | Prompting Claude Sonnet 5 | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5 | 2026-07-20 | web | Sonnet 5 has thinking on by default, more agentic than 4.6, literal instruction following | single source (caveated) |
| A3  | Prompting Claude Fable 5 | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5 | 2026-07-20 | web | Fable 5 wants goals not checklists; can refuse "echo your reasoning" prompts | corroborated by A8 on goals-vs-checklists; single source on refusal category |
| A4  | Claude prompting best practices | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices | 2026-07-20 | web | Shared cross-model techniques; confirms the three-way thinking-mode split | corroborated by A1, A2, A3 |
| A5  | Models overview table | https://platform.claude.com/docs/en/about-claude/models/overview | 2026-07-20 | web | Spec table; model IDs are pinned snapshots; legacy models archived at each release | corroborated by A1, A2, A3 |
| A6  | Fable 5 / Mythos 5 announcement | https://www.anthropic.com/news/claude-fable-5-mythos-5 | 2026-07-20 | web | Fable 5 and Mythos 5 share one model; Mythos 5 limited availability | corroborated by A3, A5 (via search summary, precision caveat) |
| A7  | GitHub discussion: tuning for Opus 4.8 | https://github.com/danielmiessler/LifeOS/discussions/1312 | 2026-07-20 | web | Restates A1 near-verbatim | amplifies A1, not independent |
| A8  | Ken Huang: how to stop prompting Fable 5 like Opus | https://kenhuangus.substack.com/p/claude-fable-5-what-changed-and-how | 2026-07-20 | web | Independent-ish: checklists hurt Fable 5, give the reason instead | corroborates A3 |
| A9  | Simon Willison: initial impressions of Fable 5 | https://simonwillison.net/2026/Jun/9/claude-fable-5/ | 2026-07-20 | web | Fable 5 beats Opus 4.8 on recall; does not discuss prompting technique | single source (tangential) |
| A10 | Claude Code Hooks reference | https://code.claude.com/docs/en/hooks | 2026-07-20 | web | No $CLAUDE_MODEL env var; only SessionStart gets an optional model field | corroborated by A11, A12 |
| A11 | Claude Code Skills reference | https://code.claude.com/docs/en/skills | 2026-07-20 | web | Skill model frontmatter sets the model; no read/conditional-load mechanism | corroborated by A10, A28 |
| A12 | Claude Code Statusline reference | https://code.claude.com/docs/en/statusline | 2026-07-20 | web | Statusline gets model.id but it is a one-way UI sink | single source (caveated) |
| A13 | Claude Code Model config reference | https://code.claude.com/docs/en/model-config | 2026-07-20 | web | /model can switch the active model mid-session | corroborated by A10 |
| A14 | Agent Skills open-standard commentary | https://codex.danielvaughan.com/2026/05/05/agent-skills-open-standard-portable-skills-codex-cli-cross-agent/ | 2026-07-20 | web | Hooks and model selection are Claude Code extensions outside the portable spec | corroborated by A11 |
| A15 | SessionStart additionalContext injection | https://github.com/anthropics/claude-code/issues/16538 | 2026-07-20 | web | A SessionStart hook can inject model identity into context | corroborated by A10, A13 |
| A16 | LLM identity confusion study | https://arxiv.org/abs/2411.10683 | 2026-07-20 | web | ~26% of 27 LLMs misidentify themselves when asked directly | corroborated by A17 |
| A17 | AI self-recognition study | https://arxiv.org/html/2510.03399 | 2026-07-20 | web | Only 4/10 models self-recognize their output, near chance | corroborated by A16 |
| A18 | anthropics/skills official repo | https://github.com/anthropics/skills | 2026-07-20 | web | Negative: no model-conditional pattern in Anthropic's own skills | single source (authoritative negative) |
| A19 | No model field in SKILL.md files | han-core/skills/*/SKILL.md and 47 others | n/a | codebase | None of 48 skills carry a model field; skills are model-neutral process instructions | corroborated by A28 |
| A20 | Model-neutral reference mechanism | han-core/skills/research/SKILL.md:68 | n/a | codebase | Cross-plugin and local references are name-only, no model qualifier | single source (codebase anchor) |
| A21 | Agent model-tier distribution | han-core/agents/*.md | n/a | codebase | 10 opus / 10 sonnet / 3 haiku across 23 han-core agents; 1 sonnet in han-communication | corroborated by A23 |
| A22 | No model override at skill dispatch | han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md:49 | n/a | codebase | Skills pass no model override; "always set model" scoped to agent files only | corroborated by A23 |
| A23 | Issue #78 model-specifier research | docs/research/issue-78-model-specifier-portability.md | n/a | codebase | Claude model names break on Codex; fix removed skill-level overrides | corroborated (codebase + provided + web in the source) |
| A24 | Codex plugin manifest is skills-only | han-core/.codex-plugin/plugin.json:13 | n/a | codebase | Codex manifest exposes only skills capability; no agents path | single source (codebase anchor) |
| A25 | Plugin-builder guidance has no model-conditional language | han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md | n/a | codebase | Guidance covers per-agent model choice, not per-model skill variants | corroborated by A26 |
| A26 | Specialization-and-model-selection rationale | han-plugin-builder/skills/guidance/references/specialization-and-model-selection.md | n/a | codebase | Assumes one skill definition; no model-conditional variant concept | corroborated by A25 |
| A27 | Maintenance surface counts | repo-wide (find over skills and references) | n/a | codebase | 48 SKILL.md and ~103 to 107 reference files across 10 plugins | corrected by V7 |
| A28 | Skill frontmatter fields reference | han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-frontmatter-fields.md:45 | n/a | codebase | Confirms the skill model field overrides for the turn only, a setter not a reader | corroborates A11 |
| A29 | Readability-guidance spike model-sensitivity flag | docs/plans/han-communication-plugin/artifacts/oi-3-spike/OI-3-spike-report.md:59 | n/a | codebase | Spike tested only Opus 4.8 subagents; flagged possible different behavior on smaller/faster models | single source (codebase anchor) |

### A1: Prompting Claude Opus 4.8 (recommendation-bearing)

- **Link / location:** https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-4-8
- **Retrieved:** 2026-07-20
- **Trust class:** web (outside the trust boundary; first-party vendor documentation)
- **Summary:** Opus 4.8's prompting page states the model interprets prompts literally and does not silently generalize instructions, so an author must state scope explicitly. It favors reasoning over tool calls, spawns fewer subagents by default, defaults effort to high (xhigh for coding), and keeps adaptive thinking off unless enabled. These are the behaviors that make Opus 4.8's authoring guidance point the opposite way from Fable 5's.
- **Evidence status:** corroborated in part by A7, which restates it; the underlying behavioral claims are single-vendor beyond that.

### A3: Prompting Claude Fable 5 (recommendation-bearing)

- **Link / location:** https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5
- **Retrieved:** 2026-07-20
- **Trust class:** web (outside the trust boundary; first-party vendor documentation)
- **Summary:** Fable 5's page, framed throughout as differences from Opus 4.8, says instruction-following is good enough that a brief goal-based instruction beats an enumerated checklist, and that over-specifying degrades output. It documents safety classifiers that can return a refusal for prompts telling the model to echo its own reasoning into the response, with configurable fallback to Opus 4.8. This is the source of both the highest-value author guidance and the one functional-failure warning in the report.
- **Evidence status:** corroborated by A8 on the goals-versus-checklist claim; single source on the refusal-category claim.

### A16: LLM identity confusion study (recommendation-bearing)

- **Link / location:** https://arxiv.org/abs/2411.10683
- **Retrieved:** 2026-07-20
- **Trust class:** web (outside the trust boundary; academic preprint)
- **Summary:** Across 27 tested models, 25.93% exhibited self-identification confusion when asked their own identity, often claiming to be a different, more famous model. This bounds how much a skill can trust a model to name itself, which is the fallback any non-hook runtime-branching mechanism would rely on.
- **Evidence status:** corroborated by A17, an independent study reaching the same conclusion.

### A17: AI self-recognition study (recommendation-bearing)

- **Link / location:** https://arxiv.org/html/2510.03399
- **Retrieved:** 2026-07-20
- **Trust class:** web (outside the trust boundary; academic preprint)
- **Summary:** Only 4 of 10 tested models could correctly recognize their own output, near chance, with a systematic bias toward attributing output to established families like GPT and Claude. Reinforces A16 that self-report is not a sound branching signal.
- **Evidence status:** corroborated by A16.

### A19: No model field in SKILL.md files (recommendation-bearing)

- **Link / location:** han-core/skills/research/SKILL.md and the other 47 SKILL.md files
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** None of Han's 48 skill files carry a model field, and skills reference agents and other skills by name with no model qualifier. The current suite is already fully model-agnostic, which is what makes O1 the existing fallback and O3 an authoring-layer change rather than a rewrite of every skill.
- **Evidence status:** corroborated by A28, which documents the frontmatter field set.

### A22: No model override at skill dispatch (recommendation-bearing)

- **Link / location:** han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md:49
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The guidance scopes "always set the model explicitly" to agent definition files only. It tells skills to pass no model override at dispatch, because a hard-coded tier name sends a Claude-specific identifier across the host boundary and supersedes each agent's own tier. This is the rule O4 would violate and the reason to reject it.
- **Evidence status:** corroborated by A23.

### A23: Issue #78 model-specifier research (recommendation-bearing)

- **Link / location:** docs/research/issue-78-model-specifier-portability.md
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor; a prior research report in this repo)
- **Summary:** Prior research found that Claude Code and Codex have separate model namespaces, and that Claude model names fail on Codex. The fix was to remove skill-level model overrides rather than translate them per host. It establishes portability as a hard constraint on any skill-level model handling, which is the backbone of the reject-O2 and reject-O4 calls.
- **Evidence status:** corroborated within its own source across codebase, provided, and web evidence.

### A24: Codex plugin manifest is skills-only (recommendation-bearing)

- **Link / location:** han-core/.codex-plugin/plugin.json:13
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The Codex plugin manifest exposes only a skills capability and no agents path, so Codex does not register Han's agents at all. This confirms that any skill-level model handling has to work without the agent layer on a non-Claude host, reinforcing the portability constraint.
- **Evidence status:** single source (codebase anchor).

### A28: Skill frontmatter fields reference (recommendation-bearing)

- **Link / location:** han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-frontmatter-fields.md:45
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The in-repo frontmatter reference states the skill model field overrides the model for the skill's turn only and is not saved to session settings. This is an independent in-repo confirmation that the field is a control, not a way to read the active model, which is the mechanism pillar of the recommendation.
- **Evidence status:** corroborates A11.

### A29: Readability-guidance spike model-sensitivity flag (recommendation-bearing)

- **Link / location:** docs/plans/han-communication-plugin/artifacts/oi-3-spike/OI-3-spike-report.md:59
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The project's own spike testing of `readability-guidance` recorded that its results came from Opus 4.8 subagents and might not transfer to smaller or faster models an operator might run. This is the concrete, already-recorded model-sensitivity case that makes `readability-guidance` the first opt-in candidate under O3.
- **Evidence status:** single source (codebase anchor).
