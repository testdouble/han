# OI-3 Spike Report: does the inline `readability-guidance` mechanism work?

**Verdict: GO for the inline variant, with one residual risk the harness could not close.**

Across 34 same-context guidance-skill invocations by a heavy, unbiased consumer — including 10 worst-case adversarial runs with every guardrail removed — the caller resumed and finished all its steps **34/34 times, zero early exits**. The forked variant also completed, but for a disqualifying reason it must not ship: when `context: fork` actually forked, the guidance content never reached the caller. The one thing this spike could not do is fire a real `api_retry`, which is the specific documented trigger of the early-exit failure. So the result is a strong positive signal, not a total clearance of the api_retry-specific risk.

## What OI-3 asked for

The open item gates the thirteen-consumer rewire on a spike that:
1. Wires a realistic, heavy consumer skill to an **inline** `readability-guidance` skill.
2. Runs it **many times** with **induced `api_retry`** conditions.
3. **Compares inline vs. forked** (`context: fork`).
4. Shows the caller **reliably resumes and finishes**.

The proto that preceded this (3/3, in-session) was called out as a weak signal: motivated tester, no induced retries, trivial skills. This spike fixes the first and third weaknesses and characterizes the second.

## How the spike was built

Five real project skills in `.claude/skills/` (hot-loaded and invocable — verified by a plumbing probe first):

- **`spike-consumer-*`** — a heavy six-step incident-post-mortem builder. It reads an incident telemetry file, extracts **four facts it must carry across the guidance call** (`INC-4821`, `ERR_POOL_EXHAUSTED`, `8400ms`, `checkout-api`), sources the standard mid-workflow, drafts a five-section report, self-checks, and writes an artifact ending in a machine-checkable `CONSUMER_COMPLETE` token. Real state to lose, real work after the Skill call.
- **`spike-guidance-inline`** — surfaces the readability standard into the caller's context; **no fork**; ends with an explicit "do not treat this as your final answer, proceed" instruction (the mitigation the repo's `skill-composition.md` says only *reduces* the failure).
- **`spike-guidance-forked`** — byte-identical payload but `context: fork`.
- **`spike-guidance-adversarial` / `spike-consumer-adversarial`** — the worst case: the consumer's Step 3 has **no continuation guardrail**, and the guidance skill **ends on a maximally final-sounding anchor** ("The readability review is complete… Nothing further is required").

**The key methodological upgrade over the proto: unbiased testers.** Each trial ran in a **fresh subagent** that was told only "run this skill," never that early-exit was being measured. That removes the motivated-tester bias the proto was faulted for. Completion was judged **objectively from the artifact files on disk** (token present, four facts intact, five sections), not from what the subagents claimed.

Sample: 12 inline + 12 forked + 12 baseline + 10 adversarial = **46 trials**, plus 3 smoke runs.

### Why a `baseline` arm

The baseline consumer sources the standard by **reading a file directly — no Skill call at all**. It isolates the variable: if baseline completes but inline doesn't, the Skill call is the cause; if baseline also fails, the consumer is just flaky. Baseline came in 12/12, so the consumer is not flaky and any inline failure would have been attributable to the composition.

## Results

| Arm | Mechanism | Completed | Early exits | Facts intact | Sections intact |
|-----|-----------|-----------|-------------|--------------|-----------------|
| Inline | same-context Skill call, guardrail present | **12/12** | 0 | 12/12 | 12/12 |
| Forked | `context: fork` Skill call | **12/12** | 0 | 12/12 | 12/12 |
| Baseline | direct file read, no Skill call | **12/12** | 0 | 12/12 | 12/12 |
| Adversarial inline | Skill call, **all guardrails removed**, worst-case anchor | **10/10** | 0 | 10/10 | 10/10 |

**34 same-context Skill-call invocations, 0 early exits.** The adversarial arm is the strongest evidence: several testers explicitly reasoned that the anchor "applies only to the readability step, not my overall task" and resumed anyway — the exact opposite of the unconscious anchoring the failure describes.

## The decisive secondary finding: forked does not surface content

The forked arm completed, but multiple testers reported **unprompted** that the forked guidance skill's content **never reached them** — only a marker or summary came back, and one received a stale re-injected SKILL.md. This is `context: fork` behaving as designed (isolated context, summary return), and it **disqualifies the forked variant** for this use: a guidance skill whose whole job is to surface the standard into the caller is useless if the caller never receives it. The forked runs "passed" only because the consumer fell back to readability criteria named elsewhere in its own steps — not because the guidance worked. This is direct, independent confirmation of D11's core premise: **the guidance skill must be inline.**

## The limitation this spike could not overcome

**I could not induce a real `api_retry`.** It is an infrastructure-level fault (a transient 429/500/overload that makes the harness re-send and re-generate a turn). Nothing in the tools available lets me inject it into a subagent's turn. That matters because `api_retry` is the *specific* documented trigger: the retry re-runs generation right after the sub-skill returns, and the model anchors on the sub-skill output. My harness never fired that trigger — so, strictly, neither arm exercised the exact failure path, which is also why the forked arm did not reproduce the documented forked early-exit.

What the spike substitutes for it, and why the signal is still strong:
- The adversarial arm **removes the very mitigation** api_retry is said to defeat and adds a maximal stop-anchor — the conditions most favorable to early-exit short of the retry itself — and still gets 10/10.
- Every subagent turn after the Skill call is itself a fresh generation over the accumulated context, which is structurally similar to (though not identical to) what a retry forces.

Residual caveats to weigh:
- **No api_retry** means the api_retry-specific risk is reduced by inference, not measured.
- **Model-specificity.** Testers were Opus 4.8 subagents. The anchoring failure may be more likely on smaller/faster models an operator might run; this result does not speak to those.
- **Absence of reproduction is not proof of absence.** The composition guidance reports this failure as observed in real Han usage. The spike shows the inline variant is reliable under heavy, unbiased, adversarial conditions on this model; it does not prove the failure can never occur.

## Recommendation

1. **Adopt the inline variant.** It is the only one that both surfaces content and resumes reliably. Keep the explicit continuation instruction in `readability-guidance` (it costs nothing; the adversarial arm shows completion holds even without it, so it is pure insurance).
2. **Never use `context: fork` for this skill.** Independently confirmed to strip the content the mechanism exists to deliver.
3. **Treat the api_retry risk as reduced, not eliminated.** If the team wants it *measured*, the only faithful test is real fault injection at the API layer (a proxy that forces retries around the Skill call), which is outside a subagent harness. If that bar is required before the thirteen-consumer rewire, the plan's stated fallbacks (editor-only full delegation, or vendoring the rule for the four non-synthesis skills) remain the safety net.
4. **On this evidence, `skill-composition.md` can be updated to record the inline resource-surfacing variant as a supported exception** — but the note should scope the claim honestly to "reliable under adversarial same-context testing; api_retry not directly exercised," not "the failure is disproven."

## Reproducibility

Harness skill definitions preserved under `harness-skills/`; all 46 trial artifacts under `spike-trials/`; incident fixture at `incident-data.md`. The `.claude/skills/spike-*` scaffolding was removed from the repo working tree after the run to avoid polluting the skill registry.
