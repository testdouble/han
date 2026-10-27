# Approach reassessment: {subject name}

Reassessment report. Read the Recommendation, then pick an option or ask for more on any of them. Nothing has been
changed.

## Recommendation

- **Pick:** {option ID and name}
- **Because:** {one or two sentences a person who has not read the plan or the code can follow}
- **What it costs to walk back:** {what has to be redone if this choice turns out wrong}

## Why this was asked

- **Subject:** `{plan file path or code path}`
- **Asked by:** {calling skill name, or "hand invocation"}
- **Reason:** {the cap reached and what the last round produced, or the person's words}
- **Findings read:** `{findings file path}`, or "none on disk; findings taken from the conversation", or "none"

## The approach as it stands

{One paragraph: what the subject commits to today, in plain words. Then the recorded findings it has absorbed, by ID,
and the ones still open.}

## Options

<!-- One to three alternatives, then the two standing options. Every option carries the same fields. -->

### O1: {name}

{One or two sentences on what changes, for a reader who has not seen the artifact.}

- **Findings it makes moot:** {IDs}
- **Findings it leaves open:** {IDs}
- **Adds and removes:** {owned code paths or plan items added; owned code paths or plan items removed}
- **Reopens:** {recorded decisions, pinned contracts, or standards this option would reopen, or "nothing"}
- **Evidence:** {file:line citations, finding IDs, or the label "inferred"}
- **Run next if chosen:** {`plan-a-change` | `plan-a-feature` | `refactor` | `tdd` | nothing}

### O2: {name}

{Same fields.}

### Stop doing this

{What is lost and what is saved if the work stops here.}

- **Findings it makes moot:** {IDs, usually all of them}
- **Findings it leaves open:** {IDs}
- **Adds and removes:** {what is removed or left unbuilt}
- **Reopens:** {the commitment or work item that asked for this}
- **Evidence:** {…}
- **Run next if chosen:** {nothing, or the skill that records the decision}

### Continue as is

{What another round costs and what it would have to produce to be worth it.}

- **Findings it makes moot:** none
- **Findings it leaves open:** {IDs}
- **Adds and removes:** nothing
- **Reopens:** nothing
- **Evidence:** {…}
- **Run next if chosen:** {the calling skill, or the next step the person was about to take}

## Deferred (YAGNI)

<!-- Options considered and set aside, each with the trigger that would reopen it. Omit the section when empty. -->

- **{Option}.** {Why it was set aside.} Reopen when {trigger}.

## Evidence

<!-- Every citation the options rely on, so a reader can check a claim without re-running the critic. -->

- **{E1}:** `{file:line}` — {what it shows}
