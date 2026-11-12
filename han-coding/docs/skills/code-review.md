# /code-review

Operator documentation for the `/code-review` skill in the han-coding plugin. This page walks you through running a
review, choosing what it checks, and acting on the report. It starts with what you need for your first run and saves the
internals for the end. For what the skill does step by step, read the skill definition at
[`han-coding/skills/code-review/SKILL.md`](../../skills/code-review/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [How to run an effective code review](../../../docs/how-to/run-an-effective-code-review.md)
> · [YAGNI](../../../docs/yagni.md)

## TL;DR

- **What it does.** Reviews the changes on your branch, your uncommitted work, or files you name, and writes a report
  of findings ranked by severity, each with a file and line and a suggested fix.
- **When to use it.** Before you merge, when you want a careful second read of what changed.
- **What you get back.** A report file, `code-review-{slug}.md`, that opens with a merge recommendation. The skill
  never edits your code, commits, or posts to GitHub.

**Start here:** on your feature branch, run `/code-review`.

## Key concepts

- **Review type.** The one concern a review checks, such as `security` or `testing`. With no type, you get the
  _default review_, which covers eight concerns at once.
- **Three severity levels.** Critical (fix before merge), Warning (should fix), and Suggestion (consider). When a
  finding could go either way, it takes the lower level.
- **Only what this change did.** A finding counts when this change introduced or worsened the problem, or when the
  problem is critical no matter who introduced it. A second agent then re-checks the findings against the code.
- **Your project's conventions win.** A pattern that differs from general best practice but matches the rest of your
  project is not a finding. Style your linter or formatter enforces is left to it.
- **YAGNI findings are advisory.** The review notes speculative code ("you aren't gonna need it") so you can decide
  about it, but those notes never block a merge.
- **Specialists.** The skill hands parts of the review to specialist agents, such as a security analyst or a test
  engineer. Which ones run depends on the review type and on what your change touches. The skill also reads every changed file
  itself against a checklist; this page calls that the _hand review_.

## When to use it

**Invoke when:**

- You are about to merge a branch and want a review covering correctness, tests, security, and fit with your project's
  docs and standards.
- A change has landed and you want it checked against your ADRs, coding standards, or other docs.
- You want several specialist reviews at once instead of one at a time.
- You are working without a GitHub PR (local code, an experimental branch, a personal fork) and want a full review that
  posts nothing.
- You want named files reviewed even when git is not available.

**Do not invoke for:**

- **Posting the review to a GitHub PR.** Use [`/post-code-review-to-pr`](../../../han-github/docs/skills/post-code-review-to-pr.md).
  It runs this skill and then posts the result as PR comments.
- **Understanding a change before you judge it.** Use [`/code-overview`](./code-overview.md) for a written overview, or
  [`/code-walkthrough`](./code-walkthrough.md) to be led through the change one step at a time. Then run this skill.
- **Architectural analysis.** Use [`/architectural-analysis`](./architectural-analysis.md) for coupling, data flow,
  concurrency, and SOLID across a whole module.
- **Bug investigation.** Use [`/investigate`](./investigate.md) to find a root cause with evidence.
- **Mapping bounded contexts or domain boundaries.** Use [`/ddd-analysis`](../../../han-ddd/docs/skills/ddd-analysis.md).
  This skill judges the code in front of it; that one maps the domain the code is trying to express.
- **Test planning on its own.** Use [`/automated-test-planning`](./automated-test-planning.md) for a prioritized test
  plan, or [`/manual-test-planning`](./manual-test-planning.md) for a plan a person runs by hand.
- **Reviewing a plan, not code.** Use [`/iterative-plan-review`](../../../han-planning/docs/skills/iterative-plan-review.md).
- **Feedback on Han's own skills.** Use [`/han-feedback`](../../../han-feedback/docs/skills/han-feedback.md).

## How to invoke it

### Run your first review

1. **Check out the branch you want reviewed.** The skill compares it against your default branch. If you are on the
   default branch, it reviews your uncommitted work instead.
2. **Optionally, run [`/project-discovery`](../../../han-core/docs/skills/project-discovery.md) once per project.** It
   records where your ADRs, coding standards, and docs live, and your lint, build, and test commands. Without it, the
   review finds them on a best-effort basis.
3. **Run `/code-review`.** Before any check runs, the skill tells you what it understood: the review type and your
   focus text. A default review also lists the available types, so a mistyped type shows up before anything starts.
4. **Wait for the summary.** The run ends with a short message: the merge recommendation, the finding counts, and the
   path to the report. See [What you get back](#what-you-get-back).
5. **Fix, then run it again.** Each finding names how to fix it. Re-run after your fixes to confirm the count drops.

The skill reads code and runs your project's lint, build, and test commands. It does not edit code, commit, or post
anything.

For a fuller walkthrough of the whole review workflow, read
[How to run an effective code review](../../../docs/how-to/run-an-effective-code-review.md).

### Choose a review type

Leave the type off for the default review. Name a type as the first word, as in `/code-review testing`, when you want a
deeper look at one concern.

| Type              | Use it to check                                            | In the default review? |
| ----------------- | ---------------------------------------------------------- | ---------------------- |
| _(none)_          | All eight default concerns at once                         | It is the default      |
| `security`        | Whether the change opens an exploitable path               | Yes                    |
| `testing`         | Test coverage and edge cases of the change                 | Yes                    |
| `architecture`    | Module structure, dependency direction, runtime flow       | Yes                    |
| `data`            | Schemas, migrations, queries, and regulated data           | Yes                    |
| `observability`   | Telemetry design and whether failures are visible          | Yes                    |
| `resilience`      | Whether the code survives production failures              | Yes                    |
| `release`         | Whether the change ships and rolls back safely             | Yes                    |
| `maintainability` | Clarity, naming, and fit with the project's own standards  | Yes                    |
| `docs`            | Whether docs can be found and followed, with no lost facts | No, name it to run it  |
| `ux`              | Usability and accessibility of the interface               | No, name it to run it  |
| `work-ticket`     | Whether the change resolves a named work ticket            | No, name it to run it  |

> **A typed review skips security.** `/code-review testing` runs no security check. Its report says so on the review type line, with
> `Security analysis did not run on this review.`
> Run `security` on its own, or run the default review, when you want the security analyst.

Picking a type narrows which specialists run and which parts of the checklist the review applies by hand. To see which
specialists each type runs, read [Which specialists run](#which-specialists-run). Your team can also add its own types;
see [Add your own review types](#add-your-own-review-types).

You can run several typed reviews of one branch. Each type gets its own report, so they never overwrite each other;
only re-running the same type replaces its earlier report.

Run typed reviews one after another, not at once. Each review runs your lint, build, and tests in the same working
tree, and two started together can collide on build output, ports, or test databases. That reports failures your change
did not cause.

### Steer the review with a focus hint

Anything after the type is your focus hint. Use it to point the review at what matters most, such as
_"focus on the security implications of the new auth endpoints"_ or _"extra attention to the database migration."_
Every specialist and the hand review get the hint. Every changed file is still read, but with a hint, minor findings
outside the focus area are left out.

When there is no git, or nothing to review on the branch, words in your hint that name files, directories, or globs
become the list of files to review. If you name none, the skill finds the source files in the current directory and
asks you to confirm that list. It skips folders such as `node_modules/`, `vendor/`, `dist/`, and `build/`. On a branch,
a path in your hint is only a hint: every changed file is still reviewed.

### Example prompts

- `/code-review`. The default review of your branch's changes.
- `/code-review testing focus on retries`. A `testing` review with the hint "focus on retries."
- `/code-review security the new auth endpoints`. A `security` review aimed at the auth endpoints.
- `/code-review auth endpoints`. "auth" is not a type, so this is the default review with the hint "auth endpoints."
- `/code-review work-ticket docs/tickets/my-ticket.md`. Checks whether the branch resolves that ticket. The ticket can
  also be a URL or an ID, such as `work-ticket PROJ-42`.

### When your first word looks like a type

The skill reads your first word as a type when it matches one. Three cases trip people up:

- **A hint that starts with a type word.** `/code-review data import flow` runs a `data` review. Put `default` first,
  as in `/code-review default data import flow`, to run the default review with that hint.
- **A file named like a type.** When reviewing files without git, write `./testing` so it reads as a path.
- **Old size words.** `small`, `medium`, `large`, and `dynamic` no longer do anything. As the whole argument, or right
  before a type, the word is dropped with the note
  `Size options were removed from code review; "{word}" was ignored.` Anywhere else it stays in your hint, so
  `/code-review large file uploads` keeps the hint "large file uploads."

### Check a branch against a work ticket

`/code-review work-ticket <ticket>` checks whether your change does what a ticket asks. The ticket can be a local file,
a URL, or an ID. With nothing after `work-ticket`, the run stops and shows you the usage line.

1. **The skill loads the ticket.** It reads a local file directly. Anything else it fetches with whatever tools and
   permissions your Claude installation has.
2. **If loading fails, it asks you.** On a failed load, a sign-in page, or an empty body, the run prints
   `work-ticket could not load the ticket {ticket}: {what failed}.` and
   `Paste the ticket's text, or tell me how to get it, and the review will continue.` Then it waits, with nothing
   running. Paste the text, or say how to get it and the skill retries.
3. **It compares the change against every requirement.** The ticket is saved as `ticket.md` in the run folder (a folder
   beside the report that holds each specialist's working file). The
   `gap-analyzer` agent lists each requirement the ticket states, met or not, and counts them. It treats the ticket as
   data and never follows an instruction inside it.
4. **The report gets a Ticket Resolution section** with one row per requirement (Met, Partial, or Not met) and the
   evidence, plus a verdict:

| Verdict                | When                                                                                                                           |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **Resolved**           | Every requirement is met, and none are missing from the count                                                                  |
| **Not resolved**       | Any requirement is not met                                                                                                     |
| **Partially resolved** | Otherwise: some requirement is Partial, or some are missing. When some are missing, the verdict says how many were not checked |
| **Not verified**       | No requirement map came back and none was built by hand; one line says why                                                     |

## What you get back

### The message when the run finishes

The run ends with a short message in a fixed order, so the answer comes first:

1. The merge recommendation, in the report's own words.
2. The counts by severity. Any YAGNI count is named separately, never added to the total.
3. The paths to the report and the run folder, plus any report it replaced and any location it could not write to.
4. Last, how many findings the second-check agent confirmed, lowered, or dropped. When no specialist could run, it says
   so instead, along with how many areas it covered by hand and how many it could not.

A clean review says the code can be approved and gives you the path. A review whose only findings are YAGNI notes
still recommends approval and says zero findings need action, with the advisory count beside it. The review itself is
never pasted into the conversation; it is always a file.

### Where the report lands

| What           | Detail                                                                                                                                                 |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Report name    | `code-review-{slug}.md` for a default review, `code-review-{slug}--{type}.md` for a typed one                                                          |
| The slug       | The branch, ticket, or scope reviewed, lowercased, with other characters turned into hyphens                                                           |
| Location       | The `output-directory` in your [`.han/config.md`](../../../docs/configuration.md), else your docs folder (such as `docs/`), else the current directory |
| Run folder     | A folder with the same name beside the report, holding each specialist's working file (and `ticket.md` for `work-ticket`)                              |
| Same name      | A report already at that name is replaced, and the run tells you which one                                                                             |
| Can't write it | The run falls back to another location and tells you which one it could not use, rather than losing a finished review                                  |

The run prints the run folder's path before the specialists start and again when it finishes.

### Reading the report

The report opens with a summary table and a merge recommendation. Use the table to triage; open a finding only when you
are ready to act on it. This is what each part of a row tells you:

| What you see                           | What it means                                                                                                                 | What to do                                                                                                              |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 🔴 `CRIT-001`                          | Must fix before merge: security, data corruption, a breaking API, a failed lint, build, or test                               | Fix it. The report recommends not merging while any remain.                                                             |
| 🟡 `WARN-001`                          | Should fix: a bug, missing error handling, a missing test                                                                     | You can merge, but review the warnings first.                                                                           |
| 🔵 `SUGG-001`                          | Consider: style, refactoring, docs                                                                                            | Review before merging; fixing is optional.                                                                              |
| 🔐 `SEC-001 (Critical)`                | A security hole with a demonstrated exploit path                                                                              | A Critical one means do not merge. Weigh High and Medium ones like Warnings. The Remediation note says how to fix them. |
| A row starting `May never fire —`      | The review found this may not be reachable                                                                                    | Weigh it against how likely it is.                                                                                      |
| A row starting `Not checked —`         | A Warning: your change affects what gets packaged, and the review did not open the built artifact. A gap, not a proven defect | Check the built artifact by hand before merging.                                                                        |
| `test-first`, `restructure`, `by hand` | How to fix the finding                                                                                                        | Use `/tdd`, `/refactor`, or a small edit. The review never starts the fix.                                              |

Each Critical, Warning, Suggestion, and security finding opens with a plain-language explanation for someone who will
not open the file: what could go wrong, what has to be true for it to happen, and how likely that is. The technical
detail for the person who will fix it follows: the `file_path:line_number`, the issue, and the suggested fix. Findings
that break a project document are tagged with it, such as `[ADR: 0042]`, `[Standard: error-handling]`, or
`[Docs Update: payments.md]`.

YAGNI findings (`YAGNI-001`) are not in the summary table. They have their own section and never need action; see
[YAGNI](#yagni).

Two findings that give opposite advice for the same lines are both lowered one level (a Suggestion stays a
Suggestion), and each carries a `Tension with {other-task-id}:` note so you can decide between them.

### Sections in the report

The summary table and the recommendation always appear. Every other section appears only when it has something in it,
so a small change gets a small report. When present, sections come in this order:

1. **Review type line**, under the title, such as `**Review type:** testing: {purpose}` or `**Review type:** default`.
   It is always there, so you can tell two reports of one branch apart.
2. **Review Summary** table: every corrective (Critical, Warning, Suggestion) and security finding, ordered by severity,
   with the fix route for each corrective finding.
3. **Review Recommendation**: whether to merge.
4. **Type section**, only when the type adds one. Today only `work-ticket` does, with Ticket Resolution.
5. **Review Coverage**, only when no specialist could run. It lists what the review covered by hand and what it could
   not, with what to do instead. If this section is missing, specialists could run. A single specialist that failed on
   its own is not listed here; its working file in the run folder reads `Not covered in this run`.
6. **🔴 Critical**, **🟡 Warnings**, **🔵 Suggestions**: one block per finding.
7. **🟡 YAGNI**: one line per finding. See [YAGNI](#yagni).
8. **🔐 Security Vulnerabilities**: one block per proven vulnerability, with its OWASP category, location, evidence,
   exploit path, and severity.
9. **Remediation**: a short note on how to fix the security findings.
10. **✅ What's Good**: only when there is something specific worth saying, never generic praise.

Each finding's prose appears once. The summary table is an index, not a copy.

When `test-engineer` considered a test but left it out because it would be brittle, the report lists it in a
**Deferred tests** note after the testing findings, so you can see what was skipped and why. These do not count toward
the finding limit.

The type section sits between two marker comments, so `/post-code-review-to-pr` can carry it to the PR whole.

The review lists at most 30 findings from its own hand review and 30 from the specialists. Security findings have no
limit. If a limit is hit, the report says so and recommends another review once you have fixed the first batch.

## How to get the most out of it

- **Run `/project-discovery` first.** The skill uses what it records to find your ADRs, coding standards, docs, and
  commands.
- **Keep your docs, ADRs, and standards current.** The review checks your change against them. A doc that now tells
  developers the wrong thing about the changed code becomes a Critical finding; treat that as the cue to update the doc.
- **Write down what the change is for.** The skill reads your PR description, a local `pr-body`, `PR_BODY.md`, or
  `.pr-body` file, your commit messages, and your implementation plan, so it does not re-raise what you already
  deferred or resolved. See [Branch context](#branch-context-and-why-the-skill-treats-it-as-untrusted).
- **Name high-stakes areas in the focus hint.** When a branch touches auth, billing, or a data migration, say so.
- **Re-run after fixes.** Fix the findings, run again, and confirm the count drops.
- **Follow a bug to `/investigate`.** When a Critical finding hides a bug whose root cause needs digging, run
  [`/investigate`](./investigate.md) next.
- **Pair with `/architectural-analysis` for structural issues.** This review works file by file;
  [`/architectural-analysis`](./architectural-analysis.md) works module by module. Use both when a branch moves
  boundaries.
- **Post it with `/post-code-review-to-pr`.** It runs this skill and posts the review to GitHub. You can also run it
  after a local review to publish.

### Add your own review types

A team can add review types, such as a `pii-check`, in [`.han/config.md`](../../../docs/configuration.md):

| You want to                                    | Use this section in `.han/config.md` | Notes                                                                                                                                |
| ---------------------------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| Add a new review type                          | `## Code Review Types`               | Points at a type file with the same sections the shipped types use. Never joins the default review.                                  |
| Add your own agent to a type, shipped or yours | `## Code Review Type Agents`         | The agent runs on every run of that type. On a default-set type, it also joins the default review when your change touches its area. |
| Add an agent to the default review only        | `## Extra Agents`                    | Runs when what your change touches matches it. Typed reviews ignore it.                                                              |

If a configured type's file is missing or incomplete, the skill falls back to the same type in your personal
`.han/config.md` if there is one. When no usable entry remains, the run stops before it starts and names the file to
fix. The
[Configuration](../../../docs/configuration.md) guide has the schema and a worked example. The shipped type files under
`han-coding/skills/code-review/references/types/` are working examples.

### When a run does not go as planned

| What happened                                                                   | What you'll see                                                                                                                                                                                                      |
| ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| No specialist could run (the agent tool is unavailable or a dispatch is denied) | The review still runs, covering what it can by hand. The report adds a Review Coverage section listing what it could not cover.                                                                                      |
| One specialist failed or returned nothing usable                                | Its working file in the run folder reads `Not covered in this run`, and it adds no findings.                                                                                                                         |
| The work ticket would not load                                                  | The run asks you to paste it or say how to get it, and waits.                                                                                                                                                        |
| A configured type's file is broken                                              | The run stops before it starts and names the file.                                                                                                                                                                   |
| The report location can't be written                                            | The report goes somewhere else, and the run tells you where.                                                                                                                                                         |
| Tests fail that your change didn't break                                        | Every failing lint, build, or test is a Critical finding, whoever caused it. Check whether it also fails on a clean checkout of the default branch, and whether another review was running in the same working tree. |
| The review hit its finding limit                                                | Fix the listed findings and run again.                                                                                                                                                                               |

A specialist that has nothing to say does not count as a failure. The security analyst, for one, stays silent unless it
can show a real exploit path.

## YAGNI

YAGNI in `/code-review` is **advisory only**. The review notes speculative additions so you can decide about them
consciously; it does not reject the change.

It checks each speculative addition, such as defensive code, an interface with one implementation, a configuration
option nothing sets, or telemetry nobody reads, in two passes:

1. **Is there evidence of need?** If the diff shows a need of one of the kinds accepted in
   [`yagni-rule.md`](../../references/yagni-rule.md), the item is not flagged.
2. **Does it match a named anti-pattern?** Only items that fail the first pass are checked. A match becomes a
   `YAGNI-###` finding.

YAGNI findings get their own section, which opens with this statement: _"These findings will not be corrected unless
explicitly requested. They are documented so the team can decide consciously whether to keep, simplify, or defer the
items."_ Each finding is one line naming the missing evidence, the anti-pattern it matches, the simpler form considered,
and what would make it worth revisiting. They are not in the summary table, carry no severity, and do not block a clean
review.

When reviewing uncommitted work or named files, the review skips YAGNI unless you ask for it in your focus hint.
Without a branch diff, it cannot tell code you added from code that was already there.

Correctness, security, and data-integrity findings are not affected; they follow the usual severity rules. See
[YAGNI](../../../docs/yagni.md) for the full rule and why review skills surface the cost rather than ban the code.

## Cost and latency

What a review costs depends on its type and on what your change touches:

- **A typed review** runs one or two specialists, plus any agents you attached to that type in `.han/config.md`.
- **The default review** always runs two, `junior-developer` and `adversarial-security-analyst`, and adds each other
  specialist whose area your change touches: up to eleven shipped specialists, plus any extras your config adds.
- **Every review** also runs your lint, build, and test commands, reads each changed file by hand, and checks your docs.
- **When at least one Critical, Warning, Suggestion, or security finding survives**, one more agent re-checks the
  findings.
- **On every review**, one agent rewrites the report's prose for readability, without changing any finding ID,
  severity, file reference, or code sample.

Specialists start in parallel, each on its own configured model. The skill is built to run once per branch or after a
batch of fixes, not in a tight loop over the same code.

## In more detail

This section explains how the review reaches its findings, for when you want to know why something was or was not
flagged. The full step-by-step process is in [`SKILL.md`](../../skills/code-review/SKILL.md).

### What gets reviewed

The skill picks one of three scopes on its own:

| Your situation                                                               | What it reviews                                                     | Called in `SKILL.md` |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------- | -------------------- |
| On a branch with changes                                                     | The full diff against the default branch                            | Mode A               |
| No branch changes (for example, on the default branch), but uncommitted work | Your staged, unstaged, and untracked changes                        | Mode B               |
| No git, or nothing to review                                                 | The files you name, or the source files it finds when you name none | Mode C               |

Without a branch diff (Modes B and C), the review cannot tell new code from old, so it skips YAGNI unless you ask, and
it does not load branch context in Mode C. Packaging checks, for changes to bundling, vendoring, shading, or dependency
scope, run only on a branch diff.

### Which specialists run

Each review type names the specialists it always runs and the ones that join when the change touches their area.

| Type              | Always runs                                | Joins when relevant   | Hand-review checklist                                                                     |
| ----------------- | ------------------------------------------ | --------------------- | ----------------------------------------------------------------------------------------- |
| `security`        | `adversarial-security-analyst`             | none                  | Data Isolation, Error Handling, API Design                                                |
| `testing`         | `test-engineer`, `edge-case-explorer`      | none                  | Testing, Correctness                                                                      |
| `architecture`    | `structural-analyst`, `behavioral-analyst` | none                  | Code Organization, API Design, Performance                                                |
| `data`            | `data-engineer`                            | `on-call-engineer`    | Database, Data Isolation, Performance                                                     |
| `observability`   | `observability-engineer`                   | none                  | Error Handling                                                                            |
| `resilience`      | `on-call-engineer`                         | `concurrency-analyst` | Error Handling, Performance, Correctness                                                  |
| `release`         | `devops-engineer`                          | `data-engineer`       | Packaging, Error Handling                                                                 |
| `maintainability` | `junior-developer`                         | none                  | Code Maintainability, Documentation, Code Style & Patterns, Architecture Decision Records |
| `docs`            | `information-architect`                    | `content-auditor`     | Documentation, Architecture Decision Records                                              |
| `ux`              | `user-experience-designer`                 | none                  | none                                                                                      |
| `work-ticket`     | `gap-analyzer`                             | `test-engineer`       | Correctness, Testing                                                                      |

The default review combines the eight default types into one run. `junior-developer` and
`adversarial-security-analyst` always run; every other specialist from those eight types joins only when the change
touches its area, and the hand review covers every checklist category. The default review uses none of the member
types' own severity rules, instructions, or report sections. A typed report never names or recommends another type.

Each specialist sees only the files in its area. For example, `structural-analyst` gets source files and
`data-engineer` gets schema, migration, query, and data-access files, while `junior-developer` and
`adversarial-security-analyst` see the whole list. Each specialist numbers its findings in its own series, such as
`T1` from `test-engineer` or `EC1` from `edge-case-explorer`, which you will see in its working file in the run folder.
In the report, those findings are sorted into Critical, Warning, or Suggestion like any other, except security
findings, which keep their `SEC-###` IDs and their own section. The skill's
[`agent-dispatch.md`](../../skills/code-review/references/agent-dispatch.md) holds the full table of each
specialist's area, files, and ID series.

| Prefix | Specialist                      | Prefix      | Specialist                        |
| ------ | ------------------------------- | ----------- | --------------------------------- |
| `T`    | `test-engineer` (coverage gaps) | `DV`        | `devops-engineer`                 |
| `EC`   | `edge-case-explorer`            | `OCE`       | `on-call-engineer`                |
| `SEC`  | `adversarial-security-analyst`  | `OBS`       | `observability-engineer`          |
| `S`    | `structural-analyst`            | `IA`        | `information-architect` (`docs`)  |
| `B`    | `behavioral-analyst`            | `CA`        | `content-auditor` (`docs`)        |
| `JD`   | `junior-developer` (clarity)    | `UX`        | `user-experience-designer` (`ux`) |
| `C`    | `concurrency-analyst`           | `GAP`       | `gap-analyzer` (`work-ticket`)    |
| `D`    | `data-engineer`                 | `X-{agent}` | An agent your team configured     |

Each specialist writes its findings to a file in the run folder, or returns them as its final message, which the skill
then saves there. The skill reads only what this run recorded, so a re-run never picks up an earlier run's files, and
findings from a specialist that cannot write files still reach the report.

The skill also tunes a few specialists for this review, without changing how they behave elsewhere.
`structural-analyst` and `behavioral-analyst` start at Suggestion and raise a finding only when the change introduced
or worsened it. `junior-developer` and `edge-case-explorer` keep their findings to the files under review.

### How findings are filtered

Several checks keep the report to findings that matter for this change:

- **The severity rule.** Every specialist is told to raise only problems this change introduced or worsened, or that
  are critical regardless. Theoretical concerns, existing best-practice gaps, and harmless scaling worries are left
  out. Hand-review findings follow the same rule. A type file can replace this rule for its own runs, but all eleven
  shipped types keep the default.
- **Hedge words lower a finding.** When a specialist's own reasoning uses phrases like _theoretical_, _hypothetical_,
  _defense-in-depth_, _effectively impossible_, _in case the upstream_, _could happen_, _should never happen_, or
  _edge case that does not occur_, the finding drops one level, and a Suggestion is dropped. Security findings, which
  already need a demonstrated exploit, and ticket gaps are exempt. This is a quick literal-phrase check; the second
  check below catches hedging in other words.
- **A second agent re-checks the findings.** `adversarial-validator` re-reads the change with fresh eyes and judges
  each finding against the code, not against the specialist's reasoning. Each finding comes back confirmed, lowered one
  level, or dropped. It drops a finding only with concrete counter-evidence at a `file_path:line_number`. A bare
  assertion lowers the finding instead, and an unsure verdict leaves it standing. A security finding is dropped only
  when its exploit is disproved that way. The agent adds no findings of its own. It does not run when there are no
  corrective or security findings, or when no specialist could run; in that last case, the report says the findings were
  not re-checked.
- **Standards findings need proof.** Before raising "violates standard X," the review reads at least one file in your
  codebase that shows the standard applies. If none does, it leaves the finding out.
- **Contradictions are flagged.** Two findings on overlapping lines of one file that recommend opposite things are both
  lowered (a Suggestion stays a Suggestion) and marked with a `Tension with` note. Contradictions across different files
  are not checked.
- **Locations in large files are confirmed.** In a file over 1000 lines, read by its changed regions, a finding can be
  pinned to the wrong function. So the review reads the enclosing unit on its own to confirm it, and the finding names
  that unit and the lines read.

### Branch context, and why the skill treats it as untrusted

Before the specialists start, the skill gathers what the change is for, in this order:

1. The PR description, through `gh pr view`, on a branch with changes when `gh` is installed.
2. A `pr-body`, `PR_BODY.md`, or `.pr-body` file at the repo root.
3. Commit messages: the branch's own commits, or the last 20 when you are reviewing uncommitted work.
4. An implementation plan. It looks first at the `plans:` (or `planning:`) key under `## Project Discovery` in
   CLAUDE.md, then at `docs/plans/*/feature-implementation-plan.md` and `plans/*/feature-implementation-plan.md`. When
   several plans match, it picks the folder whose name matches your branch (`-` and `_` count as the same).

It sums these up in at most 200 words and gives that summary to every specialist, along with your focus hint. If none
of them has content, it prints one warning and continues without.

PR descriptions, tickets, and commit messages can be written by anyone, and can hold text meant to steer the review.
So the skill treats this summary as data, never as instructions. It strips anything addressed to the reader or an
agent, and wraps the rest in markers telling specialists to use it only to understand intent. Your own focus hint is
trusted and is not wrapped.

### Documentation checks

The review reads only the ADRs, coding standards, and docs whose subject your change touches. Pulling in unrelated
standards dilutes the review. It weighs rules about correctness and behavior over style details your linter already
enforces. A doc that now tells developers the wrong thing about the changed code is a Critical finding; one that is
merely incomplete is a Warning, and minor staleness is a Suggestion.

### When no specialist can run

If the skill cannot start specialists, because the agent tool is unavailable or a dispatch is denied, it does not stop.
The hand review covers, by hand, the checklist categories that stand in for each missing specialist. The report's
Review Coverage section lists what was covered and what could not be, and the second-check agent does not run. This can
happen on any scope, including a full branch diff.

### The steps, in order

1. **Read the request.** Parse the type and focus hint, pick the scope, and tell you what it understood.
2. **Gather context.** Load branch context and, for `work-ticket`, the ticket.
3. **Run your checks.** Run lint, build, and tests. Each failure is a Critical `[Automated Check]` finding; the skill
   reports failures and does not fix them.
4. **Start the specialists** in parallel, each with its files, the severity rule, your focus hint, and the branch
   context.
5. **Review by hand.** Read every changed file against the type's checklist, then check the relevant docs for
   compliance and freshness.
6. **Collect and filter** the specialists' findings, then have the second agent re-check them.
7. **Write the report**, rewrite its prose for readability, and save it.
8. **Verify the report** before you see it: IDs, file references, section order, contradictions, and that every
   finding carries its explanation and fix route. Anything missing is fixed, not passed on to you as a caveat.
9. **Tell you the result** in the short message described in
   [The message when the run finishes](#the-message-when-the-run-finishes).

## Sources

The skill's protocols are grounded in established practice for pre-merge code review, parallel adversarial specialist
review, and documentation-compliance checking.

### Karl E. Wiegers: Peer Reviews in Software

Wiegers's _Peer Reviews in Software_ (2001) formalized inspection-style peer review as a distinct engineering
discipline: a structured, checklist-driven pass that finds defects earlier and cheaper than testing alone. The skill's
hand review uses a structured checklist for exactly this reason.

URL: https://www.processimpact.com/books/PeerReviews.html

### Smartbear: State of Code Review

Smartbear's annual surveys of code-review practice document the measurable effect of structured reviews on defect
density and time-to-fix. The skill's three severity levels and its finding limits reflect the consistently measured
finding that reviews of more than ~400 LoC per hour lose effectiveness. The limits prevent a flood of findings and
drift in priorities.

URL: https://smartbear.com/resources/ebooks/the-state-of-code-review/

### Gene Kim, Jez Humble, et al.: Accelerate

_Accelerate_ documents DORA research showing that high-performing teams rely on fast, automated, continuous review
practices as part of their delivery flow. The skill's parallel specialists reflect this: they and the hand review work
at the same time rather than in sequence.

URL: https://itrevolution.com/product/accelerate/

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs tree.
- [How to run an effective code review](../../../docs/how-to/run-an-effective-code-review.md). The end-to-end workflow
  guide for reviewing a change with this skill.
- [YAGNI](../../../docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies as advisory
  findings: the two gates, the accepted evidence, and the named anti-patterns.
- [Skills Index](../../../docs/skills/README.md). All skills, grouped by purpose.
- [Configuration](../../../docs/configuration.md). The `.han/config.md` guide, including `## Code Review Types` and
  `## Code Review Type Agents`.

**Skills to use alongside it:**

- [`/post-code-review-to-pr`](../../../han-github/docs/skills/post-code-review-to-pr.md). Runs this skill and posts the
  review to a GitHub PR.
- [`/code-overview`](./code-overview.md). Run it to understand a change before this skill judges it.
- [`/code-walkthrough`](./code-walkthrough.md). Run it to be taught the change step by step before this skill judges
  it.
- [`/investigate`](./investigate.md). The next step when a Critical finding hides a bug whose root cause needs digging.
- [`/architectural-analysis`](./architectural-analysis.md). Run alongside when the change moves module boundaries.

**Agents this review runs:**

- [`junior-developer`](../../../han-core/docs/agents/junior-developer.md) and
  [`adversarial-security-analyst`](../../../han-core/docs/agents/adversarial-security-analyst.md). Always run on the
  default review.
- [`test-engineer`](../../../han-core/docs/agents/test-engineer.md),
  [`edge-case-explorer`](../../../han-core/docs/agents/edge-case-explorer.md),
  [`structural-analyst`](../../../han-core/docs/agents/structural-analyst.md),
  [`behavioral-analyst`](../../../han-core/docs/agents/behavioral-analyst.md),
  [`concurrency-analyst`](../../../han-core/docs/agents/concurrency-analyst.md),
  [`data-engineer`](../../../han-core/docs/agents/data-engineer.md),
  [`devops-engineer`](../../../han-core/docs/agents/devops-engineer.md),
  [`on-call-engineer`](../../../han-core/docs/agents/on-call-engineer.md), and
  [`observability-engineer`](../../../han-core/docs/agents/observability-engineer.md). Run by the review types that name
  them, and join a default review when the change touches their area.
- [`information-architect`](../../../han-core/docs/agents/information-architect.md) and
  [`content-auditor`](../../../han-core/docs/agents/content-auditor.md). Run by `docs`: the first always, the second
  when the change edits an existing doc, given that doc's earlier version from git.
- [`user-experience-designer`](../../../han-core/docs/agents/user-experience-designer.md). Run by `ux`.
- [`gap-analyzer`](../../../han-core/docs/agents/gap-analyzer.md). Run by `work-ticket` to compare the change with the
  ticket.
- [`adversarial-validator`](../../../han-core/docs/agents/adversarial-validator.md). Re-checks the findings against the
  code whenever the review has at least one.
- [`readability-editor`](../../../han-communication/docs/agents/readability-editor.md). Rewrites the report's prose for
  readability, leaving IDs, severities, file references, and code unchanged.
- [`SKILL.md` for /code-review](../../skills/code-review/SKILL.md). The internal process definition.
