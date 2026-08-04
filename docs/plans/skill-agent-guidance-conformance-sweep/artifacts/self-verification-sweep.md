# Self-Verification Sweep

The repository was already close to clean. A sweep of all 40 skills and 24 agents for the three patterns the current
per-model guidance says to cut found two sites to fix, one site correctly left alone, and no instances at all of two of
the three patterns.

## What the guidance asks for

Three patterns come out:

1. A step that re-checks output the same run produced.
2. A dispatch whose stated purpose is verifying the dispatching skill's own work.
3. A rule telling the model not to think or reason.

Genuine review by a second perspective stays. That is a different mechanism, and the guidance keeps it.

## Pattern 2 and pattern 3: zero instances

No skill dispatches an agent to verify its own work. Every review dispatch in the repository sends a different
perspective at the artifact: `code-review` fans out to domain specialists, `coding-standard` sends
`junior-developer` and `information-architect` at its draft, `project-documentation` sends `information-architect`,
and the planning skills dispatch specialist review teams. Each is Level 1 or Level 2 in the escalation cascade, not a
self-check.

No skill or agent carries a rule forbidding thinking or reasoning.

## Pattern 1: two sites fixed

**`on-call-engineer` ran a tone sweep over its own findings.** It carried a section headed "auto-check against your own
findings before emitting them", an instruction to "run a sweep of your full findings list against these four tone
anti-patterns before writing your output", and a matching rule in its Rules section.

All four named tone anti-patterns survive. What changed is when they apply: they were a review pass over finished
findings and are now guidance applied while each finding is written. The section is headed "Tone anti-patterns to avoid
while writing findings", and the instruction reads "Write each finding clear of all four from the start." Nothing was
deleted, and the agent still catches the same four failures.

**`code-review` passed the same sweep down in its brief to that agent.** Its `on-call-engineer` dispatch told the agent
to "run the four named tone anti-pattern sweeps against your own findings before emitting". That brief now says to write
every finding clear of the four anti-patterns, matching the agent's own definition.

## One site correctly left alone

**`readability-editor` re-reads its rewrite against the original and confirms every fact survived.** This looks like the
pattern and is not cut, for two reasons.

The rule is scoped. Its source section is titled "Instructions to leave out on Opus 5", and its stated rationale is that
Opus 5 verifies its own work unprompted. `readability-editor` is pinned to `sonnet`, so the premise does not hold for it.

The check is also load-bearing. A rewrite that silently drops a quantity or a qualifier is the exact failure the
readability standard names as a fidelity loss, and this step is the only guard against it. Removing it would trade a
conformance point for a real regression.

## A tension worth recording

The per-model guidance says to cut steps that re-check the model's own work. The readability rule mandates a six-point
self-check and states that on a skill running no separate rewrite pass, its fidelity criterion "is the only
fact-preservation guard the output has, so it is not optional."

Both are Han rules and they point different directions. The repository has already navigated this once: `plan-a-feature`
drops its own checklist when the dedicated editor runs and keeps it when no usable editor report comes back. That is the
right shape, and the readability self-checks across the other skills were left in place on the same reasoning.

The distinction that resolves it: the per-model rule targets a correctness re-check the model performs anyway, while the
readability self-check targets fact preservation across a rewrite, which is not something a model reliably does
unprompted.

## Sources

- `han-plugin-builder/skills/guidance/references/per-model-authoring.md` § Instructions to leave out on Opus 5
- `han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md`
- `han-communication/references/readability-rule.md` § The standardized self-check
