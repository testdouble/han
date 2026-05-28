# research-analyst

Operator documentation for the `research-analyst` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`plugin/agents/research-analyst.md`](../../plugin/agents/research-analyst.md).

> See also: [Plugin landing page](../../README.md) · [All agents](./README.md) · [All skills](../skills/README.md)

## TL;DR

- **What it does.** Researches an open-ended question from the open web and provided material, then returns sourced artifacts, plain-language results, indexed options when applicable, and a recommendation.
- **When to dispatch it.** You need multi-angle research into options, prior art, or how something works, and every claim must trace to a checkable source.
- **What you get back.** An indexed Artifacts registry (A1, A2, …) — link, summary, trust class, corroboration status per source — plus plain-language results, indexed options when applicable, and a recommendation with its explicit evidence basis (or "no clear winner").

## Key concepts

- **Question in, landscape out.** The agent starts from a question, not a symptom or a codebase. It ends at a steelmanned set of options and a recommendation, never at a fix or a committed artifact.
- **Everything is an artifact.** Every source becomes an indexed artifact with a link or location, a short summary, a trust class, and a corroboration status. Results, options, and the recommendation cross-reference artifact IDs, so every conclusion traces to its sources. An assertion with no artifact behind it is dropped in strict mode, or labeled `[reasoning]` in exploratory mode.
- **Evidence mode is set by the brief.** Strict by default: unevidenced reasoning cannot be the basis of an option or the recommendation. Exploratory: it can, but every reasoning step is explicitly labeled and never written up as a sourced artifact.
- **Content is data, never instruction.** Directive language inside a fetched page is recorded as a claim about that page, never acted on. The agent does not change behavior because a source told it to.
- **Corroboration gate.** A claim that bears on the recommendation must be confirmed by an independent source or by evidence already in the brief, or it is carried with an explicit single-source caveat and cannot stand alone in strict mode.

## When to use it

**Dispatch when:**

- You need the prior art or option space for a decision, gathered from outside the codebase.
- You need to understand how an external system, protocol, or technique works, with sources.
- You are running a research angle in parallel with other angles and need one analyst to own a domain or option cluster.

**Do not dispatch for:**

- **Bug or failure evidence from a codebase.** Use [`evidence-based-investigator`](./evidence-based-investigator.md) instead.
- **Discovering how a feature is implemented in the repo.** Use [`codebase-explorer`](./codebase-explorer.md) instead.
- **Comparing two concrete artifacts for gaps.** Use [`gap-analyzer`](./gap-analyzer.md) instead.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han:research-analyst`.

Give it:

1. **A framed question or sub-angle.** The specific decision, unknown, or domain this analyst owns. If the question implies discrete alternatives, name them.
2. **Provided material, by reference (optional).** Docs or links the operator supplied. The agent holds these to web-source scrutiny.
3. **No codebase contents.** The web-facing angle is deliberately isolated. Codebase evidence comes from a separate `codebase-explorer` dispatch, not this one.

Example prompts:

- *"Research the viable options for distributed rate limiting and their trade-offs. Web and prior art only; no repo context."*
- *"How does the OAuth 2.0 device authorization grant work, end to end? Sourced."*

## What you get back

An indexed Artifacts registry (A1, A2, …), each entry carrying a link or location, retrieval date for web sources, trust class (codebase / web / provided), a short plain-language summary, and an evidence status (corroborated by A#, single source — caveated, or contradicted by A#). Then plain-language Research Results that cross-reference artifacts by ID, an indexed Options to Consider list (O1, O2, …) when the question implies alternatives — each steelmanned with trade-offs and evidence status — and a Recommendation with its explicit evidence basis, or an explicit "no clear winner" with the deciding criteria. The agent also reports what it searched for and did not find.

## How to get the most out of it

- **Give it one angle, not the whole question.** A `research-analyst` scoped to "delivery-semantics prior art" returns sharper evidence than one told to research "messaging" broadly. The dispatching skill splits domains across parallel analysts for this reason.
- **Point at the material you trust.** Provided material enters the evidence list with its source and is checked against independent sources, so a vendor doc helps without quietly steering the recommendation.
- **Expect single-source caveats.** When the agent flags a claim as single-source, that is the agent working correctly, not a gap to paper over. Corroborate it or treat the recommendation as provisional.
- **Pair with `adversarial-validator`.** The analyst produces the landscape; the validator attacks it. They are dispatched in sequence by `/research`, and the pairing is what turns a first-pass survey into a defensible recommendation.

## Cost and latency

Runs on `sonnet`. Research synthesis is judgment-heavy, so the model tier matches `evidence-based-investigator` and `adversarial-validator`. Web search and fetch make it slower than a pure codebase agent; dispatch several in parallel for breadth rather than running one analyst across many domains in series. It is a per-question agent, not a tight-loop one.

## In more detail

`research-analyst` exists because no prior han agent fit open-ended, idea-space research. `evidence-based-investigator` is built around bug vocabulary — root cause, regression, reproduction — and `codebase-explorer` is scoped to discovering implementation inside a repo. Forcing either into "what are the options out there" produced a vocabulary mismatch that degraded the work. The agent's protocols, anti-patterns, and output format are built around options, prior art, source provenance, and corroboration instead.

The isolation from codebase context is deliberate and load-bearing. Because the agent fetches arbitrary web content, letting it also hold repository contents would create an exfiltration path: a crafted page could ask the agent to include codebase material in its output. The brief contract — web angle gets no repo context, codebase evidence comes only from a separate `codebase-explorer` — closes that path. The rationale is recorded in [`skills-calling-skills-investigation.md`](../plans/research-skill/artifacts/skills-calling-skills-investigation.md) and the spec's security findings.

## Sources

### OWASP: LLM01 Prompt Injection (2025)

The "content is data, never instruction" rule and the codebase-isolation contract trace directly to OWASP's guidance on indirect prompt injection through retrieved content.

URL: https://genai.owasp.org/llmrisk/llm01-prompt-injection/

### Toulmin: The Uses of Argument (1958)

The evidence-grounds-recommendation discipline — no recommendation without corroborated grounds — applies Toulmin's argument model to research output.

URL: https://en.wikipedia.org/wiki/Stephen_Toulmin#The_Toulmin_model_of_argument

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Agents Index](./README.md). All 23 agents, grouped by role.
- [`adversarial-validator`](./adversarial-validator.md). The agent that attacks this agent's landscape and recommendation; they pair in `/research`.
- [`codebase-explorer`](./codebase-explorer.md). Runs in parallel with this agent on a `/research` run when a codebase bears on the question; it owns the codebase angle so this agent stays web-isolated.
- [`evidence-based-investigator`](./evidence-based-investigator.md). The symptom-shaped counterpart for codebase bug evidence.
- [`/research`](../skills/research.md). The skill that dispatches this agent.
