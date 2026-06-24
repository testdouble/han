# Research: How do people use Claude and other LLMs to accelerate their understanding of unfamiliar code?

A plain-language survey of the practices and evidence behind using LLMs to get up to speed on code you have never seen, gathered to ground the how-to guide [Accelerate your understanding of unfamiliar code](../how-to/accelerate-understanding-of-unfamiliar-code.md). Evidence mode: **strict**.

## Summary

The evidence converges on a four-part pattern. First, LLMs are a first-order onboarding tool: Anthropic's own guidance is to ask Claude "the same sorts of questions you would ask another engineer" and to explore before changing anything (A1, A2). Second, the gain is real but conditional: a controlled study found AI-assisted developers finished brownfield tasks faster with no improvement in comprehension, and the deciding variable was active verification, not the assistance itself (A3). Third, the explanation works best when it mirrors how comprehension builds: developers form a control-flow model first, then layer data flow and goals on top, following information scent through names and call chains (A5, A6, A7), which is exactly what progressive disclosure is built to support (A8). Fourth, the explanation has to be grounded in real source, because the central failure mode is an LLM explaining from training-data patterns rather than the code in front of it (A4, A9, A10).

The strongest practical conclusion is that the value compounds only when the grounded explanation is written down and shared. A durable, source-anchored artifact serves two audiences at once: human teammates who skip redundant onboarding (A11, A12) and future AI sessions that can read it as context rather than re-deriving (and possibly re-confabulating) the same understanding each time (A4, A10).

**Bottom line:** explore actively rather than passively, structure the overview the way comprehension builds, ground every claim in a real file path, and write the result down somewhere both people and the AI can find it. The weakest link in the evidence is the onboarding-time quantification (A12), whose specific numbers come from vendor case studies without primary-source citation; the directional claim those numbers support is corroborated across independent sources.

## Prompt Used

> first, need to do a small amount of /research on using claude and other LLMs to accelerate learning, and then tie the Han skills and custom agents into this, talk about how these skills and agents can help to accelerate your learning and understanding of unfamiliar code.

The `/research` skill comes from the Han plugin, in this repository. The scope was kept deliberately small: a handful of citable findings to ground a documentation how-to, not an exhaustive report.

## Research Results

### LLMs as a first-order onboarding tool (A1, A2)

Anthropic's documentation positions Claude Code as an onboarding mechanism directly: ask it the questions you would ask another engineer (how does logging work, what does this line do, why is this called instead of that), explore in plan mode before changing anything, then plan, then implement (A1). Claude navigates a codebase the way a person does, traversing the file system, reading files, running grep, and following cross-file references (A2). This is first-party guidance describing intended use, not an independent measurement of effectiveness, so treat it as authoritative on the workflow rather than on the size of the payoff.

### The comprehension-versus-speed trade-off (A3)

The most directly relevant controlled study (Qiao et al., 2025) put fifteen graduate students on legacy code with GitHub Copilot. Task completion sped up, but overall comprehension did not improve. The variable that separated high-comprehension participants from low-comprehension ones was verification: the high group checked AI-generated code 4.7 times more often. Passive consumption, not the assistance itself, produced the shallow understanding. The lesson for any LLM-assisted onboarding flow is to build in explicit verification against real source rather than accepting the explanation as it comes. (Single source, small N, arXiv preprint.)

### How developers build a mental model of unfamiliar code (A5, A6)

Pennington (1987) showed that when code is entirely new, the first representation a developer builds is a control-flow "program model," and only then do they layer on a "situation model" that combines data flow and a goal hierarchy (A5). Von Mayrhauser and Vans (1995) extended this into an integrated model: comprehension is a matching process across many abstraction levels at once, from "this is an operating system" down to a single variable, and it continues until the developer believes the model fits the behavior (A6). The practical implication is that an overview is most useful when it follows the same order: purpose and entry points first, then control flow, then data flow and detail.

### Information scent as the mechanism of navigation (A7)

Pirolli and Card's information foraging theory (1999) explains the cues developers follow through unfamiliar code: "information scent," the proximal signals (function names, file names, call chains, module boundaries) that suggest where the relevant thing lives (A7). This is the same navigation path Claude is described as taking (A2). Where the scent is weak (opaque names, missing comments, tangled dependencies), both humans and LLMs are likelier to infer wrong.

### Progressive disclosure as the right structure for an overview (A8)

Nielsen Norman Group defines progressive disclosure as deferring secondary detail so the reader meets only what they need at each stage, grounded in cognitive load theory (A8). Applied to an LLM-generated overview, a single everything-at-once explanation overloads the reader; an effective one leads with purpose and entry points, exposes call flow next, and saves implementation detail for last, matching how comprehension builds (A5, A6).

### Hallucination risk is worse without access to the real source (A4, A9, A10)

The AI-guided codebase exploration paper (Alebachew, 2025) names "lack of grounding," non-deterministic output, and weak access to fine-grained program structure as the central reasons standalone LLMs are hard to trust for comprehension (A4). The standard mitigation is retrieval-augmented generation: index the real source and inject the retrieved context before the model answers, so the explanation is anchored to actual code rather than to training-data patterns (A10). A vendor source illustrates the symptom with a claim that roughly one in five package recommendations point to libraries that do not exist (A9, interested party). Grounding in real file paths is what makes an explanation checkable and correctable.

### Persisting the explanation defends against re-confabulation (A4, A10)

If an LLM re-explains a module from memory in each new session, it can confabulate differently each time, compounding the error. A grounded, written-down explanation is a fixed artifact that both people and future AI sessions can reference, so the understanding is checked and corrected once rather than re-derived on every query (A4, A10). The value of writing it down is not only human memory; the artifact itself becomes reliable retrieval context for later AI interactions.

### Shared documentation lowers bus factor and speeds future onboarding (A11, A12)

Swimm frames bus-factor risk as the direct consequence of knowledge concentration: when the people who hold the mental model leave, the project stalls because the model was never externalized (A11). A vendor case study reports onboarding dropping from twelve weeks to four and daily senior-engineer interruptions falling from fifteen-to-twenty down to three-to-five after documentation improved (A12, interested party, no primary citation). The specific numbers deserve caution; the directional claim, that shared written understanding reduces ramp-up friction and frees senior-engineer time, is consistent across sources (A1, A11, A12).

## Recommendation

Explore actively, not passively (A3). Structure the overview the way comprehension builds, purpose and entry points first, then flow, then detail (A5, A6, A8). Ground every explanation in actual source and real file paths so it can be checked (A4, A9, A10). Then write the understanding down and share it, so the cost of building the mental model is paid once and every later reader (human or AI) pays only the cost of reading and correcting it (A4, A10, A11, A12). The weakest evidence is the onboarding-time quantification (A12); do not quote its numbers as precise, but the practice they motivate is well supported.

## Sources

- **A1.** Anthropic. "Best practices for Claude Code." https://code.claude.com/docs/en/best-practices (retrieved 2026-06-24). Trust: first-party documentation. Use Claude for onboarding by asking the questions you would ask an engineer; explore in plan mode before changing code. Evidence: single source, caveated.
- **A2.** Anthropic. "How Claude Code works in large codebases." https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start (retrieved 2026-06-24). Trust: first-party blog. Claude navigates a codebase like an engineer: file traversal, reading, grep, following references; persistent context via hierarchical CLAUDE.md. Evidence: single source, corroborates A1.
- **A3.** Qiao et al. "Code Comprehension with GitHub Copilot: Performance Gains, Comprehension Trade-offs, and Behavioral Predictors in Brownfield Programming." https://arxiv.org/abs/2511.02922 (retrieved 2026-06-24). Trust: arXiv preprint, not yet peer-reviewed. Faster task completion, no comprehension gain; high-comprehension users verified AI code 4.7x more often. Evidence: single source, small N.
- **A4.** Alebachew. "AI-Guided Exploration of Large-Scale Codebases." https://arxiv.org/abs/2508.05799 (retrieved 2026-06-24). Trust: arXiv preprint. Standalone LLMs limited by lack of grounding, non-determinism, and weak access to fine-grained structure; more trustworthy when grounded in deterministic analysis. Evidence: single source, prototype.
- **A5.** Pennington. "Stimulus Structures and Mental Representations in Expert Comprehension of Computer Programs." *Cognitive Psychology* 19 (1987), 295-341, cited in von Mayrhauser & Vans 1995. https://www.cs.kent.edu/~jmaletic/cs69995-PC/papers/von_mayrhauser95.pdf (retrieved 2026-06-24). Trust: academic primary source. Developers build a control-flow program model first, then a situation model of data flow and goals. Evidence: corroborated by A6.
- **A6.** von Mayrhauser & Vans. "Program Comprehension During Software Maintenance and Evolution." *Computer*, IEEE (1995). https://www.cs.kent.edu/~jmaletic/cs69995-PC/papers/von_mayrhauser95.pdf (retrieved 2026-06-24). Trust: peer-reviewed journal. Comprehension is multi-level matching of existing knowledge against new code, continuing until the model fits. Evidence: corroborated by A5.
- **A7.** Pirolli & Card. "Information Foraging." UIR Technical Report, 1999; *Psychological Review* 106(4). https://act-r.psy.cmu.edu/wordpress/wp-content/uploads/2012/12/280uir-1999-05-pirolli.pdf (retrieved 2026-06-24). Trust: peer-reviewed, foundational. Defines information scent: proximal cues that guide navigation toward relevant information. Evidence: corroborated by A4, A6.
- **A8.** Nielsen Norman Group. "Progressive Disclosure." https://www.nngroup.com/videos/progressive-disclosure/ (retrieved 2026-06-24). Trust: authoritative UX practice. Defer secondary detail to reduce cognitive load and ease learning. Evidence: single source, well-established principle.
- **A9.** diffray.ai. "LLM Hallucinations in AI Code Review." https://diffray.ai/blog/llm-hallucinations-code-review/ (retrieved 2026-06-24). Trust: vendor blog, interested party. Claims ~20% of package recommendations point to nonexistent libraries; RAG grounding reduces hallucination. Evidence: single source, percentages uncited.
- **A10.** Generative AI Association. "Grounding LLMs Responses with Factual Data: Retrieval-Augmented Generation (RAG)." https://generativeaiassociation.org/articles/grounding-llms-responses-with-factual-data-retrieval-augmented-generation-rag/ (retrieved 2026-06-24). Trust: trade association. RAG grounds LLM output in retrieved source so claims are verifiable against it. Evidence: corroborates A9, partially A4.
- **A11.** Swimm. "What Is the Bus Factor, Why It Matters and How to Increase It." https://swimm.io/learn/developer-experience/what-is-the-bus-factor-why-it-matters-and-how-to-increase-it (retrieved 2026-06-24). Trust: vendor blog, interested party. Bus-factor risk follows from knowledge concentration; documentation is the primary mitigation. Evidence: single source, qualitative.
- **A12.** Aubergine.co. "AI Knowledge Transfer: Reduce Developer Onboarding to 48 Hours." https://www.aubergine.co/insights/ai-driven-knowledge-transfer-reducing-developer-onboarding (retrieved 2026-06-24). Trust: vendor blog, interested party. Case study reports onboarding falling from 12 to 4 weeks and senior interruptions from 15-20 to 3-5 per day. Evidence: single source, numbers uncited.
</content>
</invoke>
