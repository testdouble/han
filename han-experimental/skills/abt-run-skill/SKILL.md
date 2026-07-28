---
name: abt-run-skill
description: "Run a skill test agains a given target."
argument-hint: "[skill to run] [arguments/context to forward to that skill]"
allowed-tools: Agent, Read, Glob, Grep, Bash(git *), Bash(mkdir *), Bash(mv *)
disable-model-invocation: true
---

# Protocol for AB tests

1. Resolve from prompt:

   - which skill(s) to test (`skill-under-review`),
   - which prompt to pass as skill argument (`skill-parameter`),
   - how many parallel test runs to spawn (default: 2),
   - any additional prompt or context to pass to sub-agent (`prompt-extra`).

2. To avoid cross-contamination, stash results of previous runs and all research.

3. Spawn sub-agents with the following prompt, pass it verbatim. Give each a scratchpad directory and output path (an .md file) within that scratchpad (so that it doesn't see other agent's findings):

   > As your first action, load skill `{{skill-under-review}}` using the Skill tool. If Skill tool errors or is not available, stop and surface its error, don't read the skill on your own. Skill's parameter is "{{skill-parameter}}".
   >
   > Write your final report to {{report-path}} and return a short summary.
   >
   > Your scratchpad directory is {{scratchpad}} — do all temporary work there, and put the RESULT files referenced below inside it. Your final deliverable is the report file at the absolute path above plus a short returned summary.
   >
   > When you need a sub-agent's result:
   >
   > 1. Spawn it with `Agent(run_in_background: true)`. Its task MUST end by writing its result atomically: `<produce output> > RESULT.tmp && mv RESULT.tmp RESULT`.
   > 2. Do NOT end your turn to wait. Immediately run ONE foreground Bash command that blocks: `for i in $(seq 1 60); do [ -f RESULT ] && break; sleep 10; done; cat RESULT`
   > 3. If it times out (file still absent), checkpoint and continue WITHOUT the worker — it may never deliver and you cannot stop it.
   > 4. Never rely on a completion notification or a second turn.
   >
   > When you dispatch several sub-agents in parallel (the skill's review roster does this), give each its own RESULT file and block in one loop until all of them exist before proceeding; apply the same atomic-write + poll pattern to each.
   >
   > {{prompt-extra}}

   While sub-agents are running, you might receive notifications about their sub-sub-agents finishing. This is due to a bug in claude code harness. Ignore those notifications. Your own dispatching tools are unaffected, so you can just spawn sub-agents and yield, awaiting system notification about their return.

4. Unstash everything stashed in step 2.

5. Move reports from individual agents' scratchpad directories to `.ab-results`:

   ```
   mkdir -p .ab-results
   echo '*' > .ab-results/.gitignore
   mv ...
   ```
