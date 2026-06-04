# Specialization and Model Selection

How specialization in skill and agent definitions interacts with model tier and effort. This is the unifying rationale behind why some agents in this repo run on `haiku` or `sonnet` even when the task looks complex on the surface, and why others stay on `opus` no matter how tightly we write the prompt.

## The mechanism

A well-specified skill or agent definition shifts work from inference-time compute (model tier, thinking budget) to prompt-time design. On the tasks the prompt was built for, this lets a smaller model and lower effort match a larger model and higher effort. **It does not raise the model's capability ceiling. It stops the model from wasting capability on disambiguation and planning.**

The simpler claim *"more specialization = less model needed"* is directionally correct but trades accuracy for slogan. The version above is the one supported by the literature.

## What the evidence says

**1. Prompt specialization closes the model-size gap on narrow tasks.** Multiple research lines show smaller/cheaper models matching larger ones once the prompt encodes the task tightly. Orq.ai cites up to ~4x performance improvement from prompt optimization on classification tasks. The *Specializing Smaller Language Models Toward Multi-Step Reasoning* paper (arXiv 2301.12726) is built around exactly this finding for sub-10B models.

**2. Task decomposition is the formal name for what we're doing.** Amazon Science explicitly frames decomposition as a way to *"use cost-effective, smaller, more-specialized task- or domain-adapted LLMs"* without losing accuracy. The systematic-decomposition paper (arXiv 2510.07772) reports 10–40 percentage-point gains when complexity-guided decomposition is applied. The *same* model performs dramatically better when the task is pre-shaped for it. A specialized skill or agent definition is doing this work upfront.

**3. Anthropic's own design implies the same thing.** Claude's adaptive thinking *"dynamically decides when and how much to think… at lower effort levels, it may skip thinking for simpler problems."* A highly specialized prompt makes the problem *appear simpler* to the model. Fewer branches to consider, narrower output space, pre-resolved ambiguity. Which is precisely what reduces the value of extended thinking.

**4. Few-shot/structured demonstrations substitute for raw reasoning.** Anthropic's chain-of-thought guidance notes that demonstrating the reasoning pattern in the prompt causes Claude to *"mimic that approach… often to great effect."* Embedding the reasoning pattern in a skill or agent definition is a permanent few-shot. It shifts work from inference-time compute to prompt design.

## The honest caveats

- **The inverse correlation is real for narrow, well-specified tasks. It weakens for genuinely novel reasoning.** Specialization can't manufacture capability the model doesn't have. It can only stop the model from squandering capability on figuring out what we want. If a task requires reasoning a smaller model genuinely can't perform, no prompt fixes that.
- **No published study tests *exactly* "Claude Code skill specificity vs. Opus/Sonnet/effort levels."** The mechanism is well-established in the literature. Our specific Claude Code experience is consistent with it but not formally measured in any paper located.
- **Brittleness trade-off.** Specialized prompts perform worse on out-of-distribution inputs. A general Opus + high-effort run is more robust to surprise. A tight skill definition is more efficient on the path it was built for.

## How this shapes our model choices

Three signals to weigh when choosing a model for an agent (and, where supported, effort):

1. **Prompt specificity.** Named heuristics, fixed output shape, narrow domain → lower tier viable.
2. **Reasoning novelty.** Synthesis across unbounded inputs, open-ended design → higher tier required.
3. **Brittleness tolerance.** Agents that anchor downstream work need robustness → bias up one notch.

The pattern that falls out:

- **Drop to `haiku`** where the task is lookup or classification with a fixed output shape (for example, `project-scanner`, `codebase-explorer`, `content-auditor`).
- **Drop `opus` → `sonnet`** where heavy domain-framework loading is already baked into the prompt: named methodologies, named anti-patterns, fixed rubrics. This is where mechanism #1 above is strongest. Examples in the han plugin: `concurrency-analyst`, `risk-analyst`, `gap-analyzer`, `test-engineer`, `edge-case-explorer`, `adversarial-validator`, `evidence-based-investigator`, `behavioral-analyst`, `structural-analyst`.
- **Keep `opus`** where synthesis spans unbounded inputs (`software-architect`, `system-architect`, `data-engineer`, `devops-engineer`, `project-manager`, `junior-developer`, `information-architect`, `user-experience-designer`) or where the task is genuinely novel reasoning (open-ended planning, exploit-path construction in `adversarial-security-analyst`).

## Sources

- [Prompt Optimization: How to Make Smaller Models Punch Above Their Weight (Orq.ai)](https://orq.ai/blog/prompt-optimization-to-improve-model-performance)
- [Specializing Smaller Language Models towards Multi-Step Reasoning (arXiv 2301.12726)](https://arxiv.org/abs/2301.12726)
- [How task decomposition and smaller LLMs can make AI more affordable (Amazon Science)](https://www.amazon.science/blog/how-task-decomposition-and-smaller-llms-can-make-ai-more-affordable)
- [An approach for systematic decomposition of complex LLM tasks (arXiv 2510.07772)](https://arxiv.org/abs/2510.07772)
- [Decomposed Prompting (DecomP)](https://learnprompting.org/docs/advanced/decomposition/decomp)
- [Building with extended thinking (Claude Docs)](https://docs.claude.com/en/docs/build-with-claude/extended-thinking)
- [Let Claude think: chain of thought prompting (Anthropic)](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/chain-of-thought)
- [How Smaller Language Models Outperform LLMs (Deepgram)](https://deepgram.com/learn/the-underdog-revolution-how-smaller-language-models-outperform-llms)

## Cross-References

- [Agent Model Selection](agent-building-guidelines/agent-model-selection.md). Decision criteria for the `model` frontmatter field on agents.
- [Agent Domain Focus](agent-building-guidelines/agent-domain-focus.md). How vocabulary routing, persona length, and named anti-patterns activate expert knowledge.
- [Multi-Agent Economics](agent-building-guidelines/multi-agent-economics.md). When to add agents vs. improve existing ones.
- [Progressive Disclosure](skill-building-guidance/progressive-disclosure.md). How skills layer information so the model isn't loading everything at once.
- [Context Hygiene](skill-building-guidance/context-hygiene.md). Why every token competes for attention.
