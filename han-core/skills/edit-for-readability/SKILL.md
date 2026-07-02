---
name: edit-for-readability
description: >
  Applies Han's shared Human-Readable Output Standard to a target you already have — a file on
  disk, text pasted into the prompt, or a draft already produced in the conversation — by
  dispatching the readability-editor to rewrite its prose so the main point comes first, headings
  are descriptive, each paragraph carries one idea, and sentences stay short and active, while
  preserving every fact. Use when you want to make a document or draft readable, edit or polish
  prose for readability, clean up writing, tighten wording, or re-apply the readability standard to
  something already written. Rewrites prose only, leaving code, diagrams, and citation identifiers
  unchanged. Does not write new feature or system documentation — use project-documentation. Does
  not restructure code or review it — use refactor to restructure code and code-review to audit it.
  Does not judge the underlying work or raise findings; it only rewrites the writing.
argument-hint: "[path to a file, pasted text, or 'the draft above']"
allowed-tools: Read, Write, Glob, Grep, Agent
---

# Edit for Readability

Take a target the user already has and rewrite its prose against the shared readability standard, preserving every fact. The judgment-heavy rewrite belongs to the `han-core:readability-editor` agent; this skill's job is to resolve what the target is, dispatch the editor over it, and deliver the result.

## Operating principles

- **This is the standalone readability pass.** The readability standard applies at generation time, so synthesis skills (research, project-documentation, investigate, code-review, and the rest) already bake it into their own output. This skill exists for the gap the standard names explicitly: a file or draft that was written or hand-edited *outside* one of those skills, and so was never checked against the standard. Reach for it on an existing target, not as a step inside another skill.
- **Fidelity outranks readability on every conflict.** Every claim, quantity, named entity, and stated condition or qualifier in the target survives the rewrite with its precision intact. The editor enforces this and returns a fact-preservation ledger; the skill's job is to pass the whole target through and surface that ledger, never to let a fact be dropped for the sake of a smoother sentence.
- **Prose only.** The editor rewrites prose regions and leaves code fences, diagram bodies, rendered markup, and citation identifiers (`A1`, `[F5]`, and the like) byte-for-byte unchanged. Do not ask it to touch anything else.
- **The editor holds the standard.** Do not restate the six rubric criteria here or inline the rule text into the dispatch. Point the editor at the rule file and let it apply the current standard, so this skill never drifts from `readability-rule.md`.

## Step 1: Resolve the target and the reader

Determine which kind of target the request names, because the rest of the workflow depends on it. Read the user's request and the conversation, and classify the target into exactly one of:

| Target kind | How you know | What the target is |
|---|---|---|
| A file on disk | The user named a path, or the context points at one obvious file | That file, edited in place |
| Pasted text | The user included the text to edit directly in the prompt | Verbatim copy of that text |
| A draft in the conversation | The user says "the draft above," "what you just wrote," or similar | Verbatim copy of that draft |

If more than one candidate fits, or you cannot tell which file the user means, **stop and ask the user which target to edit** before doing anything else. Never guess at a file to overwrite.

For a file target, confirm the file exists and read it. Use `Glob`/`Grep` to resolve a partial name to a concrete path. If the named file does not exist or is empty, stop and tell the user rather than editing the wrong file.

For a pasted-text or conversation-draft target, write the content **verbatim** to a new scratch file (for example `readability-target.md` in the session scratch directory or the working directory) so the editor has a file to rewrite in place. Copy it exactly — do not clean it up first, because pre-editing would rob the editor of the original and break the fact-preservation check.

Also settle the reader frame: default to a capable reader who did not do this work and lacks the author's context. If the user names a specific reader (an engineer implementing a fix, a PR reviewer, a non-technical stakeholder), carry that reader to the editor instead so the technical specifics that reader needs are kept.

## Step 2: Confirm before rewriting a file in place

If the target is a file on disk (not a scratch copy of pasted text or a conversation draft), tell the user which file will be rewritten in place and that every fact is preserved, then get a go-ahead before dispatching. Always confirm before overwriting a user's file BECAUSE the in-place rewrite is the one action here that changes a file the user owns, and an unwanted rewrite is tedious to unpick even under version control.

Skip the confirmation when the target is a scratch copy (pasted text or a conversation draft), because the original is untouched, or when the user has already said to proceed without stopping.

## Step 3: Dispatch the readability-editor

Dispatch `han-core:readability-editor` with one `Agent` call (`subagent_type: "han-core:readability-editor"`). In the prompt, give it:

- The path to the target file — the real file for a file target, or the scratch file for pasted text or a conversation draft.
- The readability rule path: `../../references/readability-rule.md`.
- The reader frame from Step 1: the default capable-reader frame, or the specific reader the user named.
- The instruction to operate on prose regions only — never inside code fences, diagram bodies, rendered markup, or citation identifiers, which survive unchanged — and to apply its rewrite to the file in place, preserving every fact.

Do not paraphrase the standard into the prompt or list its criteria yourself; the editor reads the rule and owns the rubric. If the dispatch fails or the editor is unavailable, tell the user the readability pass could not run rather than hand-editing the target yourself, so the fact-preservation guarantee is never bypassed.

## Step 4: Deliver the result

Return the outcome to the user, drawn from what the editor reports:

- For a **file target**, state that the file was rewritten in place at its path, then surface the editor's rubric verdict, its fact-preservation ledger, and the regions it left untouched (code, diagrams, citation identifiers).
- For a **pasted-text or conversation-draft target**, present the rewritten prose back to the user inline, note the scratch file path, and include the same rubric verdict and fact-preservation ledger.

If the editor reports that any fact could not be preserved while satisfying a readability criterion, relay that verbatim and confirm the fact was kept over the readability change. Do not present the result as clean if the ledger flags an unresolved tension.
