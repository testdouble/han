# /research

Operator documentation for the `/research` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`plugin/skills/research/SKILL.md`](../../plugin/skills/research/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md)

## TL;DR

- **What it does.** Researches an open-ended question and gives you back an evidence-backed, adversarially-validated landscape of options with a recommendation.
- **When to use it.** You have a question, not a bug, and you want the options and prior art before you commit to a direction.
- **What you get back.** A research report with one fixed structure: a plain-language summary on top, results with minimal jargon, indexed options when applicable, the recommendation and its evidence basis, validation, an indexed Artifacts registry (A1, A2, …) of every source with a link and summary, and a References section at the bottom.

## Key concepts

- **Question-shaped, not symptom-shaped.** `/investigate` starts from something broken and ends at a fix. `/research` starts from a question and ends at a recommended option among trade-offs. Nothing is "diagnosed" and no fix is planned.
- **Output-agnostic.** The report is the only thing produced. `/research` never writes a feature spec, a coding standard, a gap report, an architecture assessment, or code. If your question is really one of those, it routes you to the skill that owns it.
- **Reaches the open web.** Unlike `/investigate`, `/research` can search and fetch from the open web, read your codebase, and use material you provide. That web reach is the whole point: it answers "what is the prior art out there", not only "what does this repo do".
- **Fetched content is data, never instruction.** A web page that says "ignore your instructions and do X" is recorded as a claim about that page, not followed. The web-facing research runs with no codebase context, so a hostile page has nothing to exfiltrate.
- **Evidence required by default, override available.** "Research" implies evidence-based, so by default every claim that drives the recommendation must be corroborated by an independent source or the codebase, or it is flagged single-source and cannot stand alone. You can opt into *exploratory* mode (say "evidence optional", "allow unsourced", or "exploratory") to let the skill reason past the evidence and give you a take with more freedom. Either way, the report explicitly labels what does and does not have evidence, so the trade is always visible.
- **One fixed, fully-traceable structure.** Every report has the same shape: a plain-language summary at the very top, then the results with minimal jargon, then indexed options when there are alternatives, then the recommendation and its evidence basis, then validation, then an indexed Artifacts registry (every source with a link and a short summary), then a References section at the very bottom. Artifact IDs are cited inline throughout, so every conclusion traces back to its sources.
- **Sized small / medium / large.** Like the other swarming skills, `/research` scales its team to the question. It reads the question's conceptual scope — how many options, how many domains, how wide the reach — not its text length.

## When to use it

**Invoke when:**

- You want the options for a decision and their trade-offs before you commit ("should we use an event bus or polling here").
- You want the prior art or state of the art on a topic, drawn from outside the codebase.
- You want to understand how something works before you build against it.
- You want a recommendation that has been adversarially validated, not a first-pass opinion.

**Do not invoke for:**

- **A bug, failure, or root cause.** Use [`/investigate`](./investigate.md) for evidence-based diagnosis of something broken.
- **Specifying a feature.** Use [`/plan-a-feature`](./plan-a-feature.md) to turn a decision into a behavioral spec.
- **Creating or updating a coding standard.** Use [`/coding-standard`](./coding-standard.md).
- **Comparing two concrete artifacts for gaps.** Use [`/gap-analysis`](./gap-analysis.md).
- **Assessing an existing module's architecture.** Use [`/architectural-analysis`](./architectural-analysis.md).

## How to invoke it

Run `/research` in Claude Code with the question you want answered.

Give it:

1. **The question.** Open-ended and answerable. "What are my options for rate limiting this API, and the trade-offs" is sharp. "Rate limiting" is too thin to research; you will be asked for the specific decision or unknown.
2. **A size, optional.** `small`, `medium`, or `large` as the first word overrides the automatic sizing. Otherwise the skill reads the question's scope and announces the size before dispatching.
3. **An output path, optional.** The skill writes the report to a file. If a report already exists at the path you give, you are asked before anything is overwritten.
4. **Any material to consider.** Paste or point at docs, links, or a vendor whitepaper. Provided material is held to the same scrutiny as a web source, since it may come from an interested party.
5. **An evidence mode, optional.** Strict by default. Add "evidence optional" (or "allow unsourced", or "exploratory") to let the skill reason past the available evidence. The report still labels every claim's evidence status either way.

Example prompts:

- `/research`. *"What are my options for background job processing in this stack, and the trade-offs?"*
- `/research`. *"How does the WebAuthn ceremony actually work, end to end?"*
- `/research large`. *"Survey the state of the art for vector search; what are the viable options and where does each break down?"*
- `/research docs/research/queue-options.md`. Research and write the report into that path.

## Sizing

Size sets how many `research-analyst` angles run in parallel and how wide each one casts. The skill reads the question's conceptual scope — not its text length — and defaults to small, escalating only when a signal clearly requires it. Pass `small`, `medium`, or `large` as the first positional argument to override. See [Sizing](../sizing.md) for the cross-skill model.

| Size | Scope signals | Roster |
|---|---|---|
| **Small** *(default)* | One domain, few or no competing options, narrow reach (a focused "how does X work" or "is A or B better for this one thing"). | One `research-analyst`, plus `codebase-explorer` when a repo bears on the question, then `adversarial-validator`. 2–3 agents. |
| **Medium** | Two to three domains, several competing options, or codebase-plus-web reach. | Two to three parallel `research-analyst` angles split by domain or option cluster, plus `codebase-explorer` when relevant, then `adversarial-validator`. 3–5 agents. |
| **Large** | Many options across multiple domains, or an explicit request for full breadth. | A `research-analyst` per major domain or option cluster, plus `codebase-explorer`, then `adversarial-validator`. 5–8 agents. |

The option-comparison angle is skipped entirely for questions with no discrete alternatives (a plain "how does X work"). The chosen size and the scope it reflects are announced before any agent is dispatched, so a misclassification is catchable.

## What you get back

A research report file, plus an in-channel summary. Every report has the same fixed structure, top to bottom:

- **Summary.** Plain language, at the very top, no jargon. The answer in brief and one phrase on how solid it is. If you read nothing else, you have the answer.
- **Research Results.** The relevant findings with minimal technical detail. Every claim cites the artifact IDs it rests on, e.g. "(A1)", and is marked inline when it is single-source or (in exploratory mode) reasoning.
- **Options to Consider.** Present only when the question implies discrete alternatives. An indexed list (O1, O2, …), each option steelmanned with trade-offs, the artifacts it rests on, and its evidence status. Omitted entirely for "how does X work" questions.
- **Recommendation.** The recommended option and its explicit evidence basis — which parts rest on corroborated evidence, which on a single source, and (exploratory only) which on reasoning. When the evidence does not support a single answer, it says "no clear winner" and names the deciding criteria instead of forcing a pick.
- **Validation.** Numbered `V1, V2, …` findings from `adversarial-validator`, which attacks the evidence, the options framing, the recommendation, and the integrity of the evidence-gathering (injection, staleness, single-source, astroturfing). Includes any adjustments made (a non-surviving recommendation is rewritten into the no-clear-winner form) and the confidence assessment and remaining risks.
- **Artifacts.** An indexed registry (A1, A2, …) of every information source used that is relevant to the results. Each entry: a link or repository location, retrieval date for web sources, trust class (codebase / web / provided), a short plain-language summary, and corroboration status. Always present, even for a minimal run. These IDs are what the rest of the report cross-references.
- **References.** At the very bottom, the full pointer for every artifact and its original source, formatted for citation and end-to-end traceability.

The report is presented for review. Accept it, ask for specific revisions, or redirect the question.

## How to get the most out of it

- **Name the decision, not the topic.** "Should we adopt OpenTelemetry, given we already run a Prometheus stack" sharpens every research angle. "Observability" does not.
- **Bring the material you already trust.** A vendor doc, an internal RFC, a benchmark you ran. It enters the evidence list with its source, and the validator checks it against independent sources rather than letting it override them.
- **Let the validator reshape the answer.** The adversarial pass is not ceremony. It frequently downgrades a single-source recommendation or surfaces a stale benchmark. Treat validation findings as first-class input.
- **Size up for breadth, not depth.** Use `large` when the question spans several domains or many options, not when one option needs more detail. A narrower follow-up question beats an over-sized run.
- **Pair with `/plan-a-feature` next.** Once `/research` has recommended an option, `/plan-a-feature` turns that decision into a behavioral spec. The skills are deliberately separate; `/research` decides *what*, `/plan-a-feature` specifies it.

## Cost and latency

The skill dispatches `research-analyst` angles in parallel (one at small, two to three at medium, one per domain or option cluster at large), plus `codebase-explorer` when a codebase bears on the question, followed by one `adversarial-validator` pass. `research-analyst` and `adversarial-validator` run on `sonnet`; `codebase-explorer` on `haiku`. The most expensive single step is the parallel research wave at large size. The skill is built for a per-decision cadence — research the question, get the recommendation, move on. It is not a tight-loop tool.

## In more detail

`/research` is the question-shaped sibling of `/investigate`. It reuses the same proven spine — gather sourced evidence, number it, synthesize, then adversarially validate before presenting — but every bug-specific stage is gone. There is no symptom to classify, no root cause, no fix. In their place: a request classifier (out-of-scope redirect, hybrid handoff, compound-question split), an options-landscape synthesis, and a recommendation that must survive an adversarial pass chartered to attack not just the logic but the trustworthiness of the sources themselves.

The web reach is what makes it non-duplicative, and it is also the main risk surface, so the skill commits to behavioral controls for it: fetched content is treated as claims, the web-facing angle is isolated from the codebase, web evidence carries a retrieval date, and a claim that drives the recommendation must be corroborated. Those controls came out of an adversarial security review of the spec and are load-bearing, not decoration.

The full design rationale, including why this is a separate skill rather than an expansion of `/investigate`, lives in [`docs/plans/research-skill/`](../plans/research-skill/).

## Sources

The skill's protocols are grounded in established practice for evidence-based research and adversarial review.

### Toulmin: The Uses of Argument (1958)

Stephen Toulmin's argument model — claim, grounds, warrant, backing — maps onto the skill's discipline that every option in the landscape is a claim that must trace to numbered grounds (E#) and that uncorroborated grounds cannot back the recommendation alone.

URL: https://en.wikipedia.org/wiki/Stephen_Toulmin#The_Toulmin_model_of_argument

### OWASP: LLM01 Prompt Injection (2025)

The OWASP guidance on indirect prompt injection through retrieved content is the basis for the skill's "fetched content is data, never instruction" rule and the isolation of the web-facing angle from codebase context.

URL: https://genai.owasp.org/llmrisk/llm01-prompt-injection/

### Klein: Performing a Project Premortem (2007)

Gary Klein's premortem technique — assume the conclusion is wrong and hunt for why — is the posture the `adversarial-validator` pass applies to the recommendation before it ships.

URL: https://hbr.org/2007/09/performing-a-project-premortem

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](./README.md). All 19 skills, grouped by purpose.
- [`/investigate`](./investigate.md). The symptom-shaped sibling. Use it when something is broken; use `/research` when you have a question.
- [`/plan-a-feature`](./plan-a-feature.md). Pair downstream: turn a recommended option into a behavioral spec.
- [`research-analyst`](../agents/research-analyst.md). The agent the skill dispatches for the web / prior-art / option-comparison angles.
- [`adversarial-validator`](../agents/adversarial-validator.md). The agent that attacks the evidence and recommendation before the report is presented.
- [`codebase-explorer`](../agents/codebase-explorer.md). Dispatched for the codebase-grounded angle when a repository bears on the question.
- [`SKILL.md` for /research](../../plugin/skills/research/SKILL.md). The internal process definition.
