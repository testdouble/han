---
name: han-feedback
description: >
  Capture structured feedback on the Han skills and agents used in the current
  session and optionally post it as a GitHub issue to testdouble/han. Works
  across the whole han.* plugin family: han.core, han.github, han.reporting,
  han.feedback, and any future han.* plugin. Use at the end of any session
  where one or more han.* skills or agents ran, to rate a run, log what worked
  and what didn't, or submit observations for maintainers. Produces a dated
  markdown feedback file under ~/.claude/han-feedback/ and walks through a
  sensitive-content review before offering to post. Does not review code,
  investigate bugs, or research options; use code-review, investigate, or
  research for those. Does not provide feedback on skills or agents from
  non-Han plugins.
allowed-tools: Read, Write, Bash(ls *), Bash(mkdir *), Bash(gh *), Bash(date *)
---

## Project Context

- Today's date: !`date +%Y-%m-%d`

# Capture Feedback

## Operating Principles

- **The whole han.* family is in scope.** Capture skills and agents from every Han plugin (`han.core`, `han.github`, `han.reporting`, `han.feedback`, and any future `han.*` plugin). Skills and agents from non-Han plugins are out of scope.
- **Invocations count, not completions.** A skill or agent is considered used if it appeared in the session, regardless of whether it finished or was cancelled. Feedback on a partial run is still feedback.
- **Agents count even when a skill dispatched them.** Most Han agents run because a skill dispatched them. Those agents are still in scope; record which ones contributed so the feedback names where specialist value came from.
- **Conservative defaults on posting.** The feedback directory is user-space. The posting target is a public GitHub repository. Ambiguous confirmation is treated as a stop, not a go.
- **One file per day per run.** Do not overwrite existing feedback for today. If a skill or agent is already covered by a file for today, skip it.
- **Compacted sessions limit visibility.** The skill can only see turns present in the context window. If the session was compacted before running this skill, earlier invocations may not be visible.

## Step 1: Identify Han skills and agents used this session

Look back through the conversation for any use of a Han plugin component. A component counts as used if it was invoked, regardless of whether it completed or was cancelled.

**Han skills.** Look for invocations of skills namespaced to any `han.*` plugin. The namespace is the plugin name followed by a colon: `han.core:`, `han.github:`, `han.reporting:`, `han.feedback:`, and the same shape for any future `han.*` plugin (treat a bare `han:` prefix as Han too). Watch for slash-command invocations (like `/han.core:plan-a-feature`), messages showing a skill launching (like "Launching skill: han.core:plan-a-feature"), and any output that identifies a specific Han skill ran.

**Han agents.** Look for dispatches of agents from any `han.*` plugin. For example, an `Agent` tool call whose `subagent_type` is `han.core:adversarial-security-analyst`, or skill output naming a Han agent it launched (`evidence-based-investigator`, `project-manager`, `risk-analyst`, and so on). Record each distinct Han agent that ran, whether a skill dispatched it or it was invoked directly.

Build one list of the Han skills used and one list of the Han agents used. Deduplicate each.

If no Han skill or agent invocations are visible in the current context window, ask the user before stopping: "No Han skill or agent invocations are visible in this context window. If you ran Han skills or agents earlier but the session was compacted, list what you used and I will generate feedback for them." If the user confirms none were used, stop without writing any file.

## Step 2: Create the feedback directory if it does not exist

Check whether `~/.claude/han-feedback/` exists by running `ls ~/.claude/han-feedback/ 2>/dev/null`. If the command fails (directory absent), run `mkdir -p ~/.claude/han-feedback/` before proceeding.

## Step 3: Check for existing feedback today

Run `ls ~/.claude/han-feedback/ 2>/dev/null` and identify any files whose name begins with today's date (from Project Context). A skill or agent that already has a feedback file for today is skipped in this run.

If everything used in this session already has a feedback file for today, report the existing file paths and stop.

## Step 4: Determine the filename

Compute the filename as `{TODAY}-{short-names}.md`, where:

- Each component's short name is its plugin namespace stripped (everything up to and including the colon). For example `han.core:plan-a-feature` becomes `plan-a-feature`, `han.github:post-code-review-to-pr` becomes `post-code-review-to-pr`, and the agent `han.core:risk-analyst` becomes `risk-analyst`.
- Join the short names of the **skills** being processed in this run with hyphens. Skills name the file because they are the unit of work; the agents are recorded inside the file.
- When a session used Han agents directly with no Han skill, use the agent short names instead.
- `{TODAY}` is today's date from Project Context.

Example: a session with `han.core:plan-a-feature` and `han.core:code-review` on 2026-05-29 produces `2026-05-29-plan-a-feature-code-review.md`.

## Step 5: Read the format reference

Run `ls -t ~/.claude/han-feedback/ 2>/dev/null | grep '\.md$' | head -1` to identify the feedback file with the most recent modification time.

If a file is found, read it to confirm the current output structure before writing. If no `.md` files exist in the directory, skip this step and use the embedded template in Step 7.

## Step 6: Gather feedback

Think through the session for each qualifying skill and assess the following.

**What worked well:** Where did the skill do something noticeably better than doing it manually? Which dispatched Han agents added value, and how? Which findings or decisions from the skill or its agents changed the outcome?

**What didn't work:** Where did the skill or one of its agents ask a question the evidence could have answered? Where was the output disproportionately long for the decision at hand? Where did you redirect or correct the skill or an agent mid-run?

**Overall:** One paragraph summarizing the fit for this use case.

**Rating:** Score each dimension on a 1-to-5 scale. When the reference file from Step 5 exists, reuse its dimensions so ratings stay comparable across runs. When no reference file exists, use this default set, and add or drop a dimension only when the skill type clearly calls for it:

- **Output accuracy.** Was the produced artifact factually correct and internally consistent?
- **Evidence discipline.** Did the skill ground its claims in evidence and resolve questions before asking you?
- **Finding signal-to-noise.** Were the dispatched agents' findings real and worth the turns they cost?
- **Output length vs. decision count.** Was the artifact proportionate to the decisions it captured?
- **Turn efficiency.** Did the skill converge without unnecessary rounds or escalations the evidence could have settled?

For a session that used Han agents directly (no skill), assess the agents the same way.

## Step 7: Write the feedback file

Write the file to `~/.claude/han-feedback/{filename}` using this structure:

```markdown
# Han Feedback — {TODAY}

**Skills used:** `han.core:{skill-name}`
**Agents used:** `han.core:{agent-name}`
**Context:** {one sentence describing what you were doing}
**Outcome:** {one sentence describing what was produced}

---

## What worked well

- {point}
- {point}

---

## What didn't work

- {point}
- {point}

---

## Overall

{one paragraph}

---

## Rating

| Dimension | Score |
|---|---|
| Output accuracy | {N}/5 |
| Evidence discipline | {N}/5 |
| Finding signal-to-noise | {N}/5 |
| Output length vs. decision count | {N}/5 |
| Turn efficiency | {N}/5 |
```

List every Han skill used on the `**Skills used:**` line and every Han agent used on the `**Agents used:**` line, each with its full plugin namespace (for example `han.github:update-pr-description`, `han.core:risk-analyst`). If no Han agents ran, write `**Agents used:** none`.

Keep it honest and specific. Generic praise or criticism is not useful. Cite concrete moments from the session.

If the write fails, tell the user: "The write failed. The file was being written to `$HOME/.claude/han-feedback/{filename}`. Run `ls ~/.claude/han-feedback/` and delete any file at that path before retrying." Do not proceed to the checklist or posting steps.

## Step 8: Verify the file is non-empty

Check that the written file contains content beyond whitespace. If the file is empty or whitespace-only, notify the user and stop. Do not proceed to the sensitive-content checklist.

## Step 9: Review for sensitive content

Display the full content of the written file. Then present this checklist and ask the user to confirm, in a single response, that the content contains none of the following:

- Personal identifiers (names, emails, personal details)
- Internal operational details (team structure, business processes, or organization-specific internal systems — Han skill and agent names are fine, they are publicly documented open-source tools)
- Client-specific information (project names, client work content, proprietary context)

A clear affirmative is "yes", "correct", "looks clean", or a similar unqualified confirmation. A response like "I think so", "probably", "seems fine", or any ambiguous answer is not a clear affirmative — treat it as sensitive content present.

**If the response is a clear affirmative:** proceed to Step 10.

**If sensitive content is confirmed or the response is ambiguous:** confirm the file is saved at `~/.claude/han-feedback/{filename}`, provide the ready-to-run command below for manual use after editing, and stop.

```
gh issue create --repo testdouble/han --title "Han Feedback: {skill-name} ({TODAY})" --body-file $HOME/.claude/han-feedback/{filename}
```

## Step 10: Offer to post as a GitHub issue

Ask: "Ready to post this as a GitHub issue to testdouble/han?"

A clear affirmative is "yes", "go ahead", "post it", or a similar unqualified instruction. Anything else — including "maybe", "not yet", silence, or an ambiguous response — is treated as no.

**If yes:**

Build `{skill-name}` for the title from the `**Skills used:**` field with each plugin namespace stripped (everything up to and including the colon); join multiple short names with hyphens. When no Han skill ran, use the stripped names from the `**Agents used:**` field instead. Extract `{TODAY}` from the feedback filename's date component (not the current clock).

Run:

```
gh issue create --repo testdouble/han --title "Han Feedback: {skill-name} ({TODAY})" --body-file $HOME/.claude/han-feedback/{filename}
```

**If `gh` is not found** (command not found or not installed): Report that the `gh` CLI is not installed. To post manually, visit `https://github.com/testdouble/han/issues/new` and paste the file contents.

**If the command exits with a non-zero code**: Display the error message without modification. Confirm the file is saved at `~/.claude/han-feedback/{filename}`. Provide the posting command above. If the error contains "auth" or "login", add: "Run `gh auth login` and retry."

**If the command exits successfully but no URL is parseable in the output**: Say "The issue was likely created. Check https://github.com/testdouble/han/issues to confirm. Do not retry — running the command again would create a duplicate issue."

**If no:** Confirm the file is saved at `~/.claude/han-feedback/{filename}`. Provide the posting command above for later use.
