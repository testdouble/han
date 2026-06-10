# How To: Provide Feedback on Han

A walkthrough for getting feedback to the Han maintainers in a shape they can act on. There are two kinds of feedback and two paths. When you have an idea, a feature request, or a rough "this felt off" observation, you sharpen it with [`/issue-triage`](../skills/han.core/issue-triage.md) before you post it. When you have just finished a working session and want to report how the skills performed, you install the opt-in `han.feedback` plugin and let [`/han-feedback`](../skills/han.feedback/han-feedback.md) summarize the session and post it for you.

> See also: [How-to index](./README.md) · [Choosing a Han plugin](../choosing-a-han-plugin.md) · [Skills](../skills/README.md)

Both paths end in the same place: a GitHub issue on [testdouble/han](https://github.com/testdouble/han/issues) that a maintainer can read and act on. The difference is what you are starting from.

## Before you begin

- You have something specific to say. "Han is great" and "Han is bad" are not actionable. A concrete moment ("the planning skill asked me about the database schema when the schema was right there in the code") is.
- You can post to GitHub. Both paths finish by opening an issue on testdouble/han. The `/han-feedback` path uses the `gh` CLI, so install and authenticate it (`gh auth login`) if you want the skill to post for you. If you do not have `gh`, both paths still produce text you can paste into the issue form by hand.
- You know which path you are on. If you are reporting on skills you just ran in this session, you want Path B. If you have an idea or a complaint that is not tied to a single session, you want Path A. The two paths are independent; you do not need both.

## What you'll end up with

- **From Path A:** a triage document that classifies your idea or complaint, names what is missing before anyone can act on it, and a GitHub issue carrying that structure.
- **From Path B:** a dated markdown feedback file at `~/.claude/han-feedback/`, and (if you confirm) a GitHub issue summarizing what worked, what didn't, and a rating, drawn from the session you just ran.

Either way the maintainers receive feedback that is specific enough to act on rather than a one-line reaction they have to chase down.

## Path A: An idea, a request, or a vague observation

Use this path when the feedback is not tied to a single session: a feature you wish Han had, a skill that behaved in a way that surprised you, a rough idea you want to float. The problem with raw ideas is that they are usually missing the context a maintainer needs to act, and you cannot always see what is missing from the inside. `/issue-triage` is built for exactly that gap. It classifies the input, then lists what is absent for that type of input before anyone tries to act on it.

1. **Run [`/issue-triage`](../skills/han.core/issue-triage.md) with your idea or observation, in your own words.** Do not polish it first. The skill is designed to work on messy, incomplete input, and cleaning it up changes what counts as missing information. A template that works well:

    > `/issue-triage` *"{the idea or complaint, exactly as it occurs to you}"*

    A filled-in example:

    > `/issue-triage` *"It would be nice if the code review skill could skip files I have not touched. Right now it reviews everything on the branch and that is slow on big branches."*

    The skill classifies the input (here, a feature request), records the reported behavior and the expected behavior, and produces a **Missing Information** list: the things a maintainer would need before they could act. For a feature request that is usually the use case and the success criteria; for a complaint it is usually reproduction details and scope.

2. **Fill the gaps the triage names.** Read the **Missing Information** section and the **Recommended Next Step**. When the recommendation is "Clarify before proceeding," that is the signal that your feedback is still too thin to act on. Answer the questions it raised, in the text, before you post. This is the whole point of the path: you are closing the gaps now so a maintainer does not have to ask later.

3. **Post the triaged feedback as a GitHub issue.** Once the triage document names the idea clearly and the gaps are filled, open an issue on testdouble/han with that content. The triage document is the issue body. If you have the `gh` CLI:

    > `gh issue create --repo testdouble/han --title "{short summary}" --body-file {path to the triage file}`

    Without `gh`, paste the triage content into the issue form at [github.com/testdouble/han/issues/new](https://github.com/testdouble/han/issues/new).

## Path B: Feedback on a session you just ran

Use this path right after a working session where one or more Han skills ran and you have observations about how they performed. The `han-feedback` skill reads the session, synthesizes structured feedback, and offers to post it for you. It ships in a separate plugin you install once.

1. **Install the `han.feedback` plugin.** The skill lives in an opt-in plugin that the `han` meta-plugin does not bundle, so installing the full suite does not give it to you. Install it on its own:

    > `/plugin install han.feedback@han`

    It depends on `han.core`, so Claude Code pulls core along if you do not already have it. You only do this once; after that the skill is available in every session. See [Choosing a Han plugin](../choosing-a-han-plugin.md) for where it sits in the suite.

2. **Run [`/han-feedback`](../skills/han.feedback/han-feedback.md) at the end of the session, before you compact.** No arguments are required.

    > `/han-feedback`

    The skill looks back through the conversation for invocations of any `han.*` plugin's skills and agents (`han.core`, `han.github`, `han.reporting`, `han.feedback`, and any future `han.*` plugin), then writes a dated feedback file to `~/.claude/han-feedback/` recording the skills and agents used and covering what worked, what didn't, an overall summary, and a rating. It reads only what is visible in the current context window, so run it while the full session is still in context. If the session was already compacted, the skill asks you to list what you used.

    You can prime it with a concrete observation before it writes anything: *"I just finished a session with `/investigate` and it found the root cause faster than I expected"* gives the skill a specific moment to build on. The more specific you are, the more useful the result.

3. **Review the feedback file when the skill displays it.** The skill shows you the full file and walks a sensitive-content checklist before it offers to post. Feedback files capture session context, which can include internal team details or client project names, so read what was written before you confirm it is clean. An ambiguous answer is treated as "stop," not "go": the skill will save the file and hand you the manual posting command rather than posting on an unclear confirmation.

4. **Confirm the post, or post it yourself later.** On a clear "yes," the skill runs `gh issue create` against testdouble/han and returns the issue URL. If you decline, or `gh` is not installed, the file is saved and the skill gives you the command to post it yourself once you are ready:

    > `gh issue create --repo testdouble/han --body-file ~/.claude/han-feedback/{filename}`

## Variations

- **Your session feedback is really a feature idea.** If, while reviewing the `/han-feedback` file, you realize the most useful thing is a concrete feature request rather than a session rating, switch to Path A: run `/issue-triage` on the idea to sharpen it, and post that instead. The two paths are not exclusive; pick the one that fits what you actually want to say.

- **You do not have the `gh` CLI.** Both paths still work. Each produces text (a triage document or a feedback file) that you paste into the issue form at [github.com/testdouble/han/issues/new](https://github.com/testdouble/han/issues/new). The `gh` CLI only saves you the copy-and-paste.

- **The triage says "Clarify before proceeding" and you cannot fill the gap.** That usually means the idea is not yet ready to be an issue. Sit with it until you can name the use case or reproduce the behavior, or post it anyway with the open questions stated explicitly so a maintainer knows what is unresolved. An honest "here is the gap" beats a confident issue built on a guess.

- **You ran several Han skills across more than one session.** `/han-feedback` reads one session at a time and writes one file per day per skill set. Run it at the end of each session rather than trying to reconstruct several at once from memory.

## What you should expect at each step

- **The feedback file is yours until you post it.** `/han-feedback` writes to `~/.claude/han-feedback/`, which is user-space on your machine. Nothing leaves your machine until you give a clear affirmative to the posting step. You can edit the file before posting.
- **The sensitive-content gate is conservative by design.** The posting target is a public GitHub repository, so the skill treats any ambiguous confirmation as a stop. If you want it posted, say so plainly.
- **`/issue-triage` does not read your codebase for root cause.** On Path A it classifies the input and names gaps; it does not investigate. That is the right amount of work for shaping feedback into an issue.
- **Invocations count, not completions.** `/han-feedback` treats a skill as used if it appeared in the session, even if you cancelled it partway. Feedback on a partial run is still feedback worth sending.

## Where to go next

- [`/issue-triage`](../skills/han.core/issue-triage.md) is the skill behind Path A, and its long-form doc covers the full output contract.
- [`/han-feedback`](../skills/han.feedback/han-feedback.md) is the skill behind Path B, with the details of the file format, the sensitive-content review, and the posting flow.
- [Choosing a Han plugin](../choosing-a-han-plugin.md) explains why `han.feedback` is installed separately and where it sits relative to the bundled suite.
- [How-to index](./README.md) lists the rest of the end-to-end guides.

## Related Documentation

- [Plugin landing page](../../README.md). Where the Han suite starts, and where the install commands live.
- [How-to index](./README.md). The rest of the end-to-end guides.
- [Choosing a Han plugin](../choosing-a-han-plugin.md). The end-user view of the plugins, including the opt-in `han.feedback`.
- [`/issue-triage`](../skills/han.core/issue-triage.md). The skill that shapes an idea or complaint into a structured, postable issue.
- [`/han-feedback`](../skills/han.feedback/han-feedback.md). The skill that summarizes a session and posts the feedback for you.
