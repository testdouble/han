# Feature Technical Notes: han-communication Plugin

<!--
This file captures implementation mechanics that are load-bearing for the
behavioral specification of the han-communication plugin — where naming a
specific mechanic was the only way to correctly specify a feature-level
behavior, and the mechanic is NOT discoverable from the code repo alone.
Behavioral statements live in [../feature-specification.md](../feature-specification.md);
this file is a secondary reference artifact consumed by plan-implementation.

Created lazily in review round R5, once the OI-3 spike settled the one
load-bearing mechanic (same-context composition) that earlier rounds had
tracked as a contested open item rather than a settled note.
-->

## T1: Same-context composition; the guidance skill is inline (not forked)

- **Context:** The Primary Flow and the "Sourcing the standard cross-plugin, in stages" alternate flow specify that invoking `readability-guidance` makes the shared standard available inside the calling skill's own context, so the caller drafts in voice and then finishes its own workflow. Specifying that behavior correctly requires naming the same-context invocation mechanic and the inline (non-forked) constraint that the behavior depends on.
- **Technical detail:** A skill invoked through the skill-invocation tool renders into, and runs in, the caller's conversation context, so content it surfaces persists there for the caller to use and the caller resumes its own workflow after the invocation returns. `readability-guidance` must be **inline**: it must not set the `context: fork` frontmatter field. A forked invocation runs in an isolated context and returns only a summary, so the surfaced standard never reaches the caller. The OI-3 spike validated the inline variant (34/34 same-context runs across a heavy consumer and unbiased testers, zero early exits, worst-case adversarial arm included) and disqualified the forked variant (its content did not reach the caller). The one condition the spike could not meet was inducing a real `api_retry`, the specific documented trigger of the early-exit failure, so the residual early-exit risk is reduced by inference, not measured, and is specific to the harness model. Evidence: [readability-guidance-research.md](readability-guidance-research.md) and the preserved [oi-3-spike/](oi-3-spike/).
- **Supports decisions:** D3, D11
- **Driven by findings:** F46 (see [review-findings.md](review-findings.md))
- **Referenced in spec:** Primary Flow
