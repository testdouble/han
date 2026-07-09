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

## Conclusion

Mechanically feasible (precedented, documented same-context composition, no new cross-plugin risk), pending a prototype of the two behavioral unknowns. The efficiency intuition holds for skills that need no rewrite, but the suite's own design says single-pass loading is insufficient for synthesis output. The strongest design is therefore **both**, staged: `readability-guidance` restores in-voice drafting + self-check cross-plugin (for all consumers), and the `readability-editor` rewrite is retained for synthesis skills only. This preserves `docs/readability.md`'s staged model that a single full-delegation rewrite pass would otherwise collapse, and it removes the forced rewrite the earlier full-delegation plan added to the four non-synthesis skills. It also rehabilitates the hybrid rejected earlier (team-findings F3), whose only blocker — sourcing the blocklist cross-plugin — the guidance skill removes.
