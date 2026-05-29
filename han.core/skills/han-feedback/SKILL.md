---
name: han-feedback
description: >
  Capture structured feedback on Han skills used in the current session and
  optionally post it as a GitHub issue to testdouble/han. Use at the end of
  any session where one or more han: skills ran — to rate a skill run, log
  what worked and what didn't, or submit observations for maintainers.
  Produces a dated markdown feedback file under ~/.claude/han-feedback/ and
  walks through a sensitive-content review before offering to post. Does not
  review code, investigate bugs, or research options — use code-review,
  investigate, or research for those. Does not provide feedback on skills
  from other plugins.
allowed-tools: Read, Write, Bash(ls *), Bash(mkdir *), Bash(gh *), Bash(date *)
---

## Project Context

- Today's date: !`date +%Y-%m-%d`

# Capture Feedback

## Operating Principles

- **Invocations count, not completions.** A skill is considered used if it appeared in the session, regardless of whether it finished or was cancelled. Feedback on a partial run is still feedback.
- **Conservative defaults on posting.** The feedback directory is user-space. The posting target is a public GitHub repository. Ambiguous confirmation is treated as a stop, not a go.
- **One file per day per skill set.** Do not overwrite existing feedback for today. If a skill is already covered, skip it.
- **Compacted sessions limit visibility.** The skill can only see turns present in the context window. If the session was compacted before running this skill, earlier skill invocations may not be visible.

## Step 1: Identify skills used this session

Look back through the conversation for invocations of `han:` prefixed skills. Look for slash-command invocations (like `/han:plan-a-feature`), messages showing a skill launching (like "Launching skill: han:plan-a-feature"), and any output that identifies a specific `han:` skill ran. A skill counts as used if it was invoked, regardless of whether it completed or was cancelled.

If no `han:` invocations are visible in the current context window, ask the user before stopping: "No han: skill invocations are visible in this context window. If you ran skills earlier but the session was compacted, list the skills you used and I will generate feedback for them." If the user confirms none were used, stop without writing any file.

## Step 2: Create the feedback directory if it does not exist

Check whether `~/.claude/han-feedback/` exists by running `ls ~/.claude/han-feedback/ 2>/dev/null`. If the command fails (directory absent), run `mkdir -p ~/.claude/han-feedback/` before proceeding.

## Step 3: Check for existing feedback today

Run `ls ~/.claude/han-feedback/ 2>/dev/null` and identify any files whose name begins with today's date (from Project Context). A skill that already has a feedback file for today is skipped in this run.

If every qualifying skill already has a feedback file for today, report the existing file paths and stop.

## Step 4: Determine the filename

Compute the filename as `{TODAY}-{skill-short-names}.md`, where:

- Each skill's short name is its `han:` prefix stripped (e.g., `han:plan-a-feature` becomes `plan-a-feature`).
- The short names of skills being processed in this run are joined with hyphens.
- `{TODAY}` is today's date from Project Context.

Example: a session with `han:plan-a-feature` and `han:code-review` on 2026-05-29 produces `2026-05-29-plan-a-feature-code-review.md`.

## Step 5: Read the format reference

Run `ls -t ~/.claude/han-feedback/ 2>/dev/null | grep '\.md$' | head -1` to identify the feedback file with the most recent modification time.

If a file is found, read it to confirm the current output structure before writing. If no `.md` files exist in the directory, skip this step and use the embedded template in Step 7.

## Step 6: Gather feedback

Think through the session for each qualifying skill and assess the following.

**What worked well:** Where did the skill do something noticeably better than doing it manually? Where did specialist agents add value? Which findings or decisions from the skill changed the outcome?

**What didn't work:** Where did the skill ask a question the evidence could have answered? Where was the output disproportionately long for the decision at hand? Where did you redirect or correct the skill mid-run?

**Overall:** One paragraph summarizing the skill's fit for this use case.

**Rating:** Score across the dimensions used in the reference file from Step 5, or adjust dimensions to fit the skill type when no reference file exists.

## Step 7: Write the feedback file

Write the file to `~/.claude/han-feedback/{filename}` using this structure:

```markdown
# Han Feedback — {TODAY}

**Skills used:** `han:{skill-name}`
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
| {dimension} | {N}/5 |
```

Keep it honest and specific. Generic praise or criticism is not useful. Cite concrete moments from the session.

If the write fails, tell the user: "The write failed. The file was being written to `$HOME/.claude/han-feedback/{filename}`. Run `ls ~/.claude/han-feedback/` and delete any file at that path before retrying." Do not proceed to the checklist or posting steps.

## Step 8: Verify the file is non-empty

Check that the written file contains content beyond whitespace. If the file is empty or whitespace-only, notify the user and stop. Do not proceed to the sensitive-content checklist.

## Step 9: Review for sensitive content

Display the full content of the written file. Then present this checklist and ask the user to confirm, in a single response, that the content contains none of the following:

- Personal identifiers (names, emails, personal details)
- Internal operational details (team structure, business processes, or organization-specific internal systems — han skill names are fine, they are publicly documented open-source tools)
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

Extract `{skill-name}` from the `**Skills used:**` field with the `han:` prefix stripped. Extract `{TODAY}` from the feedback filename's date component (not the current clock).

Run:

```
gh issue create --repo testdouble/han --title "Han Feedback: {skill-name} ({TODAY})" --body-file $HOME/.claude/han-feedback/{filename}
```

**If `gh` is not found** (command not found or not installed): Report that the `gh` CLI is not installed. To post manually, visit `https://github.com/testdouble/han/issues/new` and paste the file contents.

**If the command exits with a non-zero code**: Display the error message without modification. Confirm the file is saved at `~/.claude/han-feedback/{filename}`. Provide the posting command above. If the error contains "auth" or "login", add: "Run `gh auth login` and retry."

**If the command exits successfully but no URL is parseable in the output**: Say "The issue was likely created. Check https://github.com/testdouble/han/issues to confirm. Do not retry — running the command again would create a duplicate issue."

**If no:** Confirm the file is saved at `~/.claude/han-feedback/{filename}`. Provide the posting command above for later use.
