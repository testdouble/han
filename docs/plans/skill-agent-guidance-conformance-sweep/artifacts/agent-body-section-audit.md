# Agent Body Section Audit

Every one of the 24 agents now carries a role identity under the 50-token budget, no flattery, a `## Domain Vocabulary`
section, and an `## Anti-Patterns` section. Five agents exceed the guidance's 5-to-10 anti-pattern range, and those are
recorded here rather than cut.

## What changed

**Fifteen role identities were over the 50-token budget, and all fifteen are now under it.** Nothing was deleted. Each
over-length opening paragraph was split at its natural sentence boundary, leaving the "You are a…" statement as the role
identity and moving the qualifying sentences into the paragraph below it. The guidance is explicit that detail following
the role identity does not count against the budget, so a split is the whole fix. Whole-file word counts confirm the
content survived.

**Two flattery hits removed.** `project-manager` opened "You are a seasoned project manager" and now opens "You are a
project manager." `junior-developer` carried the word "expert" inside its role paragraph, in a sentence that has moved
below the budget line.

**Three agents had no `## Domain Vocabulary` section.** `project-manager`, `junior-developer`, and `readability-editor`
now carry one. Each list was drawn from terms already used in that agent's own body, not invented, because a fabricated
vocabulary routes the model at nothing.

**One agent had no `## Anti-Patterns` section.** `readability-editor` now carries six, each with a detection signal,
drawn from the failure modes its own rubric and rules already describe.

## Five agents exceed the anti-pattern range, deliberately

The guidance asks for 5 to 10 named anti-patterns. These five carry more:

| Agent                      | Named anti-patterns |
| -------------------------- | ------------------- |
| `data-engineer`            | 32                  |
| `on-call-engineer`         | 18                  |
| `devops-engineer`          | 17                  |
| `user-experience-designer` | 13                  |
| `information-architect`    | 12                  |

**They were not cut, and the reason is the user's own instruction.** The sweep's secondary goal is to reduce what can be
reduced "without affecting the quality of the skill or agent in question." Each named anti-pattern is a distinct
detection capability with its own signal. Cutting `data-engineer` from 32 to 10 would delete 22 things it currently
knows how to find. That is a capability loss wearing a conformance costume.

The three largest cover unusually wide domains. `data-engineer` spans relational, document, columnar, and streaming
storage; `on-call-engineer` spans every code-level resilience failure mode; `devops-engineer` spans delivery,
observability, rollout, secrets, and supply chain. A 5-to-10 range fits an agent with one domain, and these carry
several.

**What would change this.** If a later pass finds two anti-patterns in one of these lists that fire on the same
signal, merging them is a real simplification rather than a deletion. That is a different job from cutting to hit a
number, and it is worth doing when someone reads these lists closely.

## One-role rule

The guidance says an agent should generate or evaluate, never both, because generator bias replicates in evaluation.
`readability-editor` is the one agent in the roster that does both: it rewrites a draft and then reports on whether its
own rewrite preserved every fact.

It is recorded here and left alone. Splitting it into a rewriter and a separate fact-checker creates a new agent, which
changes the entity count that the recorded boundary rules out. The candidate carries forward to the consolidation
register instead.

## Sources

- `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md`
- `docs/plans/skill-agent-guidance-conformance-sweep/artifacts/scope-boundary.md`
