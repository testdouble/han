# Feature Specification: Project-Local Han Configuration

A project that uses Han can add one configuration file that adjusts how Han skills behave in that project: where skills
write their markdown outputs, and which extra agents skills consider when choosing whom to dispatch. Every Han skill
reads the file reliably on every run, so the overrides take effect without depending on the model remembering to look.

## Outcome

An engineer on a consuming project writes their Han overrides once, in one file, and every Han skill honors them from
then on. The two overrides this feature delivers: a project-chosen base directory under which skills write their
markdown deliverables ([D14](artifacts/decision-log.md#d14-the-output-directory-is-a-base-skills-keep-their-structure-beneath-it)),
and a project-supplied list of extra agents for dispatching skills to consider
([D7](artifacts/decision-log.md#d7-v1-override-set-output-directory-and-extra-agents-only)). A project without the file
sees no change of any kind ([D11](artifacts/decision-log.md#trivial-decisions)).

## Actors and Triggers

- **Actors** — Engineers on a consuming project write and maintain the configuration file. Han skills read it. The
  project-discovery skill can make it discoverable by offering to add a pointer to the project's CLAUDE.md
  ([D10](artifacts/decision-log.md#d10-project-discovery-offers-a-claudemd-pointer)).
- **Triggers** — Any Han skill run in the project reads the configuration as part of resolving project context, before
  the skill's own work begins ([D3](artifacts/decision-log.md#d3-skills-read-the-file-deterministically-not-ambiently)).
- **Preconditions** — None. The file is optional, and the feature imposes no setup step on projects that do not use it.

## Primary Flow

1. An engineer creates a `.han/config.md` file — a single file inside a `.han/` folder at the project root
   ([D1](artifacts/decision-log.md#d1-one-dedicated-markdown-file-carried-by-the-consuming-project)). The file holds a
   small structured header block for simple settings, such as the output directory, and named sections for list-shaped
   overrides, such as extra agents
   ([D2](artifacts/decision-log.md#d2-markdown-with-a-structured-header-block-not-json),
   [T1](artifacts/feature-technical-notes.md#t1-config-file-schema-shape)).
2. When any Han skill starts, it looks for the file from the directory the skill runs in — the same place it already
   looks for the project's CLAUDE.md and discovery file — so in a monorepo each package can carry its own configuration
   ([D15](artifacts/decision-log.md#d15-the-config-is-discovered-from-the-skills-working-directory)). The read is built
   into the skill itself, so the configuration reaches the model on every run rather than depending on ambient
   instructions the model may or may not follow
   ([D3](artifacts/decision-log.md#d3-skills-read-the-file-deterministically-not-ambiently)). Every Han skill
   participates ([D4](artifacts/decision-log.md#d4-every-han-skill-participates)).
3. The skill resolves each single-value setting through a fixed precedence chain: explicit user input first, then the
   configuration file, then the CLAUDE.md Project Discovery section, then the project-discovery file, then the skill's
   built-in defaults
   ([D6](artifacts/decision-log.md#d6-precedence-explicit-input-config-file-discovery-sources-defaults)). For the
   list-shaped extra-agents setting, precedence works by addition rather than replacement: agents the user names
   explicitly are always considered, and the configuration's entries join them as candidates ([D6](artifacts/decision-log.md#d6-precedence-explicit-input-config-file-discovery-sources-defaults)).
4. Steps that write markdown deliverables write them under the configured base directory, keeping each skill's own
   folder and file structure beneath it, and creating the directory on first write if it does not exist
   ([D14](artifacts/decision-log.md#d14-the-output-directory-is-a-base-skills-keep-their-structure-beneath-it)).
5. Skills that dispatch specialist agents add the configuration's extra agents to their candidate pool. The extra
   agents compete under the same signal-based selection and the same size-band caps as the skill's own roster, which
   means a selected extra agent can take a slot a default specialist would otherwise have filled — that displacement is
   intended and happens without comment
   ([D5](artifacts/decision-log.md#d5-extra-agents-join-the-candidate-pool-under-existing-caps)). An entry that
   duplicates an agent already in the pool has no effect, and an entry that does not resolve to a dispatchable agent is
   skipped with a one-line note.
6. Settings that do not apply to the running skill are ignored without comment
   ([D12](artifacts/decision-log.md#trivial-decisions)). A skill that produces no markdown output ignores the output
   directory; a skill that dispatches no agents ignores the extra-agents list.

## Alternate Flows and States

### No configuration file present

- **Entry condition:** The skill's working directory has no `.han/config.md`, or the file is empty.
- **Sequence:** The skill resolves project context exactly as it does today, from the remaining sources in the
  precedence chain.
- **Exit:** Skill behavior is byte-for-byte the behavior the suite has now. No note is shown
  ([D11](artifacts/decision-log.md#trivial-decisions)).

### Discovery keeps the pointer honest

- **Entry condition:** The project-discovery skill runs in a project.
- **Sequence:** When a `.han/config.md` exists, the skill offers to add a one-line pointer to it in the project's
  CLAUDE.md, beside the Project Discovery section it already maintains, so the file is visible in the document every
  contributor already reads. It never adds a second pointer when any reference to the file is already present. When
  the file is gone but a pointer remains, the skill offers to remove the stale pointer
  ([D10](artifacts/decision-log.md#d10-project-discovery-offers-a-claudemd-pointer)).
- **Exit:** The pointer is written or removed only with the user's consent, and CLAUDE.md never accumulates duplicate
  or dangling references.

## Edge Cases and Failure Modes

A bad configuration file can never fail a skill run; the worst it can do is be ignored
([D9](artifacts/decision-log.md#d9-graceful-degradation-a-bad-config-can-never-break-a-skill)). The rule for when the
user hears about it: a one-line note appears only when content that attempts a recognized override cannot be used.
Content the suite has no use for is passed over silently.

| Condition                                                                | Required Behavior                                                                                                                                                       |
| ------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Header block is malformed, or the file is unreadable as text             | The skill ignores the unusable portion, resolves those settings from the rest of the precedence chain, and shows a one-line note naming what was ignored ([D9](artifacts/decision-log.md#d9-graceful-degradation-a-bad-config-can-never-break-a-skill)). |
| A setting name is not one the suite recognizes                           | The setting is ignored with a one-line note; recognized settings in the same file still apply.                                                                           |
| A recognized setting has a blank or unusable value                       | Treated the same as unrecognized content: ignored with a one-line note, and the setting falls through the precedence chain.                                              |
| The output-directory value points outside the project, or cannot be written | The value is refused with a one-line note and the skill falls back to its default output location; deliverables are never written outside the project ([D14](artifacts/decision-log.md#d14-the-output-directory-is-a-base-skills-keep-their-structure-beneath-it)). |
| The configured output directory does not exist                           | The skill creates it when it first writes a deliverable there ([D14](artifacts/decision-log.md#d14-the-output-directory-is-a-base-skills-keep-their-structure-beneath-it)). |
| An extra-agents entry does not resolve to a dispatchable agent           | The entry — a misspelling, a skill name, the running skill itself, or anything else that is not a dispatchable agent — is skipped with a one-line note naming it; dispatch proceeds with the remaining candidates ([D5](artifacts/decision-log.md#d5-extra-agents-join-the-candidate-pool-under-existing-caps)). |
| An extra-agents entry duplicates an agent already in the candidate pool  | The duplicate has no effect: the agent is one candidate, counted once against the caps.                                                                                  |
| The config file and CLAUDE.md disagree on a setting                      | The config file wins, silently, per the precedence chain ([D6](artifacts/decision-log.md#d6-precedence-explicit-input-config-file-discovery-sources-defaults)). The CLAUDE.md pointer ([D10](artifacts/decision-log.md#d10-project-discovery-offers-a-claudemd-pointer)) exists to keep that override visible. |
| The skill runs from a directory with no config, in a repo that has one elsewhere | The skill behaves as if the file were absent; discovery is from the working directory only ([D15](artifacts/decision-log.md#d15-the-config-is-discovered-from-the-skills-working-directory)). |
| The file exists but contains only prose the suite has no use for         | Nothing applies; the skill behaves as if the file were absent, with no note.                                                                                             |

## User Interactions

The configuration file itself is the feature's user surface; no new commands or prompts are added.

- **Affordances:** One markdown file the engineer edits by hand: a structured header block for simple values and a
  named section listing extra agents ([T1](artifacts/feature-technical-notes.md#t1-config-file-schema-shape)). The file
  is meant to stay small — everything in it is read on every skill run — and it travels through version control like
  any other file ([D13](artifacts/decision-log.md#trivial-decisions)).
- **Feedback:** When a skill refuses part of the file — malformed content, an unrecognized setting, an unusable value,
  an unresolvable agent name — it tells the user in one line what it ignored and why, on each run where the problem is
  present ([D9](artifacts/decision-log.md#d9-graceful-degradation-a-bad-config-can-never-break-a-skill)). When
  everything applies cleanly, the skill says nothing about the config.
- **Error states:** None that stop work. Configuration problems degrade to defaults; they never block or fail the
  skill run ([D9](artifacts/decision-log.md#d9-graceful-degradation-a-bad-config-can-never-break-a-skill)).

## Coordinations

| Coordinating System         | Direction | Interaction                                                                 | Ordering / Consistency Requirement                                                              |
| --------------------------- | --------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Every Han skill             | inbound   | Reads `.han/config.md` during project-context resolution                     | The read completes before the skill's own work begins, on every run, without model discretion.   |
| project-discovery skill     | outbound  | Offers to write, and to remove when stale, a pointer line in the project's CLAUDE.md | Written or removed only with user consent; never duplicated, never left dangling without an offer to clean it. |
| Consuming project's repo    | inbound   | Carries the file; Han cannot ship or seed it from the plugin side            | The project owns the file's contents and history ([D1](artifacts/decision-log.md#d1-one-dedicated-markdown-file-carried-by-the-consuming-project)). |

## Out of Scope

- **Enforcement beyond skill behavior.** The configuration shapes what skills do; it does not gate tools, block
  actions, or act as a security boundary. The output-directory containment rule
  ([D14](artifacts/decision-log.md#d14-the-output-directory-is-a-base-skills-keep-their-structure-beneath-it)) protects
  against accidents, not adversaries.
- **Shipping or seeding the file from the plugin.** Han cannot bundle a project-level configuration that activates on
  install; the consuming project creates and owns the file
  ([D1](artifacts/decision-log.md#d1-one-dedicated-markdown-file-carried-by-the-consuming-project)).
- **Defining new agents.** The extra-agents override selects among agents that already exist in the session (from any
  installed plugin or the project's own agent definitions); it does not create agents.
- **Changing any skill's selection logic or caps.** Extra agents enter the existing selection process; the process
  itself is untouched ([D5](artifacts/decision-log.md#d5-extra-agents-join-the-candidate-pool-under-existing-caps)).

## Deferred (YAGNI)

### A folder of per-concern configuration files

- **Why deferred:** Simpler-version test. One file inside `.han/` satisfies both named needs today; a folder of
  per-skill or per-concern files is structure with no current content to fill it. The research is explicit that this
  is a v1 simplification, not a claim that one file is superior on the merits, and that splitting later carries a
  migration cost: existing projects' config files would need to be split and moved
  ([D8](artifacts/decision-log.md#d8-one-file-in-v1-not-a-folder)).
- **Reopen when:** The single file grows enough sections that editing or reviewing it becomes a reported pain, or a
  third override class lands that is naturally file-shaped.
- **Source:** Research report validation finding V8.

### Per-skill grouping of extra agents

- **Why deferred:** Simpler-version test. A single global list satisfies the described need — the project's agents get
  considered — because signal-based selection already filters out agents irrelevant to a given skill's domain. Grouping
  entries per skill adds schema surface with no named need behind it ([F2](artifacts/team-findings.md#f2-spec-and-tech-notes-disagreed-on-global-versus-per-skill-extra-agents)).
- **Reopen when:** A project reports an extra agent being selected by a skill where it does not belong, or asks to
  scope an agent to specific skills.
- **Source:** Review finding F2 (junior-developer).

### Free-form prose instruction overrides per skill

- **Why deferred:** Evidence test. The two user-described needs are the output directory and extra agents; a general
  "any instructions you like, per skill" section has no named need behind it and would reopen the soft-compliance
  problem the deterministic read exists to avoid.
- **Reopen when:** A user describes a concrete third override that is instruction-shaped rather than value-shaped or
  list-shaped.
- **Source:** YAGNI evidence test during the interview, against the research report's stated needs.

### A size limit or truncation rule for the config file

- **Why deferred:** Evidence test. The file's whole content is read on every skill run, so an oversized file carries a
  recurring cost — but no measured incident supports a hard limit today, and the keep-it-small guidance in User
  Interactions is the strictly simpler version ([F9](artifacts/team-findings.md#f9-an-oversized-config-file-is-read-on-every-run)).
- **Reopen when:** A real project's config measurably bloats skill context or degrades skill behavior.
- **Source:** Review finding F9 (edge-case-explorer).

## Open Items

- **OI-1:** The constraint that forces the configuration into the consuming project rests on a single documentation
  page that was never tested against a live plugin install (research source A13). The check is cheap — install a
  plugin carrying a project-scoped user-configuration entry and see whether it is honored — and it must run during
  implementation planning, before the implementation plan is approved. A negative result does not merely simplify: it
  reopens the feature's foundational decision
  ([D1](artifacts/decision-log.md#d1-one-dedicated-markdown-file-carried-by-the-consuming-project)) about where the
  configuration lives.
  - **Resolves when:** The live-install check is performed during implementation planning.
  - **Blocks implementation:** No — it does not block starting the implementation plan, but the plan must not be
    approved until the check has run.
- **OI-2:** The precedence order ([D6](artifacts/decision-log.md#d6-precedence-explicit-input-config-file-discovery-sources-defaults))
  is a design proposal the research explicitly says to validate in use, not a derived fact. After the feature ships,
  the first few real projects using the file should confirm the config-beats-CLAUDE.md direction matches what engineers
  expect.
  - **Resolves when:** Feedback from real use confirms the order, or a surprised-user report triggers revisiting D6.
  - **Blocks implementation:** No — the order is settled for v1; this item tracks post-ship validation.

## Summary

- **Outcome delivered:** One optional project-carried configuration file that reliably adjusts every Han skill's output
  location and agent candidate pool in that project, and changes nothing when absent.
- **Primary actors:** Engineers on consuming projects (write it), Han skills (read it), project-discovery (points to it).
- **Decisions settled by evidence:** 12 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 3 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, edge-case-explorer, gap-analyzer — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** The output directory became a base that preserves each skill's structure with a
  containment rule; extra agents became a single global list with duplicate and non-agent entries handled; config
  discovery was pinned to the skill's working directory; and the CLAUDE.md pointer gained a stale-cleanup offer.
- **Remaining open items:** 2
- **Technical notes:** 1 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
