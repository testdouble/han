---
name: trial-run-skill
description: "Trial-run a named Claude Code skill by executing it end to end, then write a first-person self-report on the experience of running it — what was clear, what was awkward, where you had to guess, and what could improve. The self-report criteria stay hidden until the run finishes, so the run itself stays unbiased."
argument-hint: "[skill to run] [arguments/context to forward to that skill]"
allowed-tools: Skill, Read
disable-model-invocation: true
---

# Trial-Run a Skill

Run the skill named in the argument through the Skill tool, forwarding everything after its name as that skill's arguments, unchanged. Walk its full workflow and produce its real output exactly as you would on a direct invocation. Do not cut the run short or steer it toward a tidy result, BECAUSE the point is to experience the skill the way its user would. If no skill is named, ask which one to trial-run; if the Skill tool cannot invoke the named skill, report which one failed and stop rather than fabricate a run.

When the skill returns, **do not stop** — its output is not this skill's final answer. Only now, read [references/self-report.md](references/self-report.md) in full and follow it to write your first-person report on the run. Never open that reference before the run is over, BECAUSE reading the reflection prompt first makes you run the skill while grading yourself against it, which changes how you run it. That self-report is the final output.
