# Feature Specification: Project-Local Han Configuration

A project that uses Han can add one configuration file at its root that adjusts how Han skills behave in that project:
where skills write their markdown outputs, and which extra agents skills consider when choosing whom to dispatch. Every
Han skill reads the file reliably on every run, so the overrides take effect without depending on the model remembering
to look.

## Outcome

An engineer on a consuming project writes their Han overrides once, in one file, and every Han skill honors them from
then on. The two overrides this feature delivers: a project-chosen output directory for skill-written markdown
deliverables, and a project-supplied list of extra agents for dispatching skills to consider
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

1. An engineer creates a `.han/config.md` file at the project root
   ([D1](artifacts/decision-log.md#d1-one-dedicated-markdown-file-at-the-project-root)). The file holds a small
   structured header block for simple settings, such as the output directory, and named sections for list-shaped
   overrides, such as extra agents
   ([D2](artifacts/decision-log.md#d2-markdown-with-a-structured-header-block-not-json),
   [T1](artifacts/feature-technical-notes.md#t1-config-file-schema-shape)).
2. When any Han skill starts, it reads the file during project-context resolution. The read is built into the skill
   itself, so the configuration reaches the model on every run rather than depending on ambient instructions the model
   may or may not follow ([D3](artifacts/decision-log.md#d3-skills-read-the-file-deterministically-not-ambiently)).
   Every Han skill participates ([D4](artifacts/decision-log.md#d4-every-han-skill-participates)).
3. The skill resolves each setting through a fixed precedence chain: explicit user input first, then the configuration
   file, then the CLAUDE.md Project Discovery section, then the project-discovery file, then the skill's built-in
   defaults ([D6](artifacts/decision-log.md#d6-precedence-explicit-input-config-file-discovery-sources-defaults)).
4. Steps that write markdown deliverables write them under the configured output directory, creating it if it does not
   exist yet.
5. Skills that dispatch specialist agents add the configuration's extra agents to their candidate pool. The extra
   agents compete under the same signal-based selection and the same size-band caps as the skill's own roster
   ([D5](artifacts/decision-log.md#d5-extra-agents-join-the-candidate-pool-under-existing-caps)). A named agent that
   does not resolve to an agent available in the session is skipped with a one-line note.
6. Settings that do not apply to the running skill are ignored without comment
   ([D12](artifacts/decision-log.md#trivial-decisions)). A skill that produces no markdown output ignores the output
   directory; a skill that dispatches no agents ignores the extra-agents list.

## Alternate Flows and States

### No configuration file present

- **Entry condition:** The project has no `.han/config.md`, or the file is empty.
- **Sequence:** The skill resolves project context exactly as it does today, from the remaining sources in the
  precedence chain.
- **Exit:** Skill behavior is byte-for-byte the behavior the suite has now. No note is shown
  ([D11](artifacts/decision-log.md#trivial-decisions)).

### Discovery offers to make the file findable

- **Entry condition:** The project-discovery skill runs in a project that has a `.han/config.md`.
- **Sequence:** The skill offers to add a one-line pointer to the configuration file in the project's CLAUDE.md, beside
  the Project Discovery section it already maintains, so the file is visible in the document every contributor already
  reads ([D10](artifacts/decision-log.md#d10-project-discovery-offers-a-claudemd-pointer)).
- **Exit:** The pointer is written only with the user's consent, and never duplicated on later runs.

## Edge Cases and Failure Modes

A bad configuration file can never fail a skill run; the worst it can do is be ignored
([D9](artifacts/decision-log.md#d9-graceful-degradation-a-bad-config-can-never-break-a-skill)).

| Condition                                                          | Required Behavior                                                                                                                                                       |
| ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Header block is malformed or the file is unparseable               | The skill ignores the unusable portion, resolves those settings from the rest of the precedence chain, and shows the user a one-line note naming what was ignored.       |
| A setting name is not one the suite recognizes                     | The setting is ignored with a one-line note; recognized settings in the same file still apply.                                                                           |
| An extra-agents entry names an agent the session cannot resolve    | That entry is skipped with a one-line note naming it; dispatch proceeds with the remaining candidates ([D5](artifacts/decision-log.md#d5-extra-agents-join-the-candidate-pool-under-existing-caps)). |
| The configured output directory does not exist                     | The skill creates it when it first writes a deliverable there.                                                                                                           |
| The config file and CLAUDE.md disagree on a setting                | The config file wins, silently, per the precedence chain ([D6](artifacts/decision-log.md#d6-precedence-explicit-input-config-file-discovery-sources-defaults)). The CLAUDE.md pointer ([D10](artifacts/decision-log.md#d10-project-discovery-offers-a-claudemd-pointer)) exists to keep that override visible. |
| The file exists but contains only prose the suite has no use for   | Nothing applies; the skill behaves as if the file were absent, with no note.                                                                                             |

## User Interactions

The configuration file itself is the feature's user surface; no new commands or prompts are added.

- **Affordances:** One markdown file the engineer edits by hand: a structured header block for simple values and named
  sections for extra agents ([T1](artifacts/feature-technical-notes.md#t1-config-file-schema-shape)). The file lives in
  the project and travels through version control like any other file ([D13](artifacts/decision-log.md#trivial-decisions)).
- **Feedback:** When a skill ignores part of the file — malformed content, an unrecognized setting, an unresolvable
  agent name — it tells the user in one line what it ignored and why. When everything applies cleanly, the skill says
  nothing about the config.
- **Error states:** None that stop work. Configuration problems degrade to defaults; they never block or fail the
  skill run ([D9](artifacts/decision-log.md#d9-graceful-degradation-a-bad-config-can-never-break-a-skill)).

## Coordinations

| Coordinating System         | Direction | Interaction                                                                 | Ordering / Consistency Requirement                                                              |
| --------------------------- | --------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Every Han skill             | inbound   | Reads `.han/config.md` during project-context resolution                     | The read completes before the skill's own work begins, on every run, without model discretion.   |
| project-discovery skill     | outbound  | Offers to write a pointer line into the project's CLAUDE.md                  | Written only with user consent; deduplicated so repeat runs never add a second pointer.          |
| Consuming project's repo    | inbound   | Carries the file; Han cannot ship or seed it from the plugin side            | The project owns the file's contents and history ([D1](artifacts/decision-log.md#d1-one-dedicated-markdown-file-at-the-project-root)). |

## Out of Scope

- **Enforcement beyond skill behavior.** The configuration shapes what skills do; it does not gate tools, block
  actions, or act as a security boundary.
- **Shipping or seeding the file from the plugin.** Han cannot bundle a project-level configuration that activates on
  install; the consuming project creates and owns the file
  ([D1](artifacts/decision-log.md#d1-one-dedicated-markdown-file-at-the-project-root)).
- **Defining new agents.** The extra-agents override selects among agents that already exist in the session (from any
  installed plugin or the project's own agent definitions); it does not create agents.
- **Changing any skill's selection logic or caps.** Extra agents enter the existing selection process; the process
  itself is untouched ([D5](artifacts/decision-log.md#d5-extra-agents-join-the-candidate-pool-under-existing-caps)).

## Deferred (YAGNI)

### A folder of per-concern configuration files

- **Why deferred:** Simpler-version test. One file satisfies both named needs today; a `.han/` folder of per-skill or
  per-concern files is structure with no current content to fill it, and the research flagged the single file as the
  deliberate v1 simplification ([D8](artifacts/decision-log.md#d8-one-file-in-v1-not-a-folder)).
- **Reopen when:** The single file grows enough per-skill sections that editing or reviewing it becomes a reported
  pain, or a third override class lands that is naturally file-shaped.
- **Source:** Research report validation finding V8.

### Free-form prose instruction overrides per skill

- **Why deferred:** Evidence test. The two user-described needs are the output directory and extra agents; a general
  "any instructions you like, per skill" section has no named need behind it and would reopen the soft-compliance
  problem the deterministic read exists to avoid.
- **Reopen when:** A user describes a concrete third override that is instruction-shaped rather than value-shaped or
  list-shaped.
- **Source:** YAGNI evidence test during the interview, against the research report's stated needs.

## Open Items

- **OI-1:** The constraint that forces the configuration into the consuming project rests on a single documentation
  page that was never tested against a live plugin install (research source A13). A cheap empirical check — install a
  plugin carrying a project-scoped user-configuration entry and see whether it is honored — should run before
  implementation locks in. If the constraint turns out to be wrong, simpler plugin-carried options reopen.
  - **Resolves when:** The live-install check is performed during implementation planning.
  - **Blocks implementation:** No — the check is cheap and the current design remains valid either way; a positive
    result would simplify, not invalidate.

## Summary

- **Outcome delivered:** One optional project-root configuration file that reliably adjusts every Han skill's output
  location and agent candidate pool in that project, and changes nothing when absent.
- **Primary actors:** Engineers on consuming projects (write it), Han skills (read it), project-discovery (points to it).
- **Decisions settled by evidence:** 7 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 6 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1
- **Technical notes:** 1 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)
