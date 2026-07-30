# Feature Implementation Plan: Personal Han Configuration

This plan adds a second configuration file for Han skills to read: a personal configuration you keep with your Claude
Code settings, read alongside the project's existing `.han/config.md`. Today, Han skills read only that project file.
With this plan in place, the project file still wins setting by setting, a relative path roots at the file that
declared it, and the guard that refuses an out-of-project output directory is deleted.

This lands as one coordinated change across the whole suite, not a staged rollout, because a half-applied
configuration layer is harder to reason about than none.

The one thing to know before reading further: the riskiest part of this work is a single line of shell in a skill's
context probe. This plan spends its first work unit proving that line loads before anything else is touched.

## Outcome

When this ships, you write one personal configuration file and every project you run a Han skill in picks up your
settings. No copying a file into each repository, and no editing every copy when you change your mind. A project that
wants something different still says so in its own `.han/config.md`, and it wins for the settings it names and only
those.

Two smaller things change with it.

A path you write in your personal file resolves beside that file rather than beside whatever project you happen to be
in, so a writing-voice profile you keep once works everywhere.

And any configured path may now point anywhere, including outside the project. A project file that was refused before
starts being honored.

## User Stories

- **US-1:** As a person running Han skills, I want my settings read from a personal configuration file, so that they
  follow me into every project without me copying a file into each one.
- **US-2:** As a person running Han skills, I want a project's configuration to adjust my personal settings one setting
  at a time, so that a project can differ on one thing without losing the rest of my defaults.
- **US-3:** As a person running Han skills, I want every message about configuration to name which file it came from,
  so that I know which of the two files to go and fix.
- **US-4:** As a person keeping a personal writing-voice profile, I want a path in my personal file to resolve beside
  that file and to be allowed to point anywhere, so that the profile applies in every project.
- **US-5:** As a reader of the operator guide, I want the guide to describe both files and the removed guard, so that
  what I read matches what runs.

## Constraints and Boundaries

- **Driving constraint:** the behavior is specified and settled. Three of the specification's decisions came from
  direct operator answers, so the shape of the feature is not in question. What is in question is whether the mechanism
  the suite uses to read configuration can express it, which is why the plan opens with a check rather than an edit.
- **Recorded boundary:** the operator's typed request, quoted in full in
  [artifacts/scope-boundary.md](artifacts/scope-boundary.md), asks to adjust "the han config file loading" so it reads
  the personal file first and the project file after. No exclusions were stated. Size band: extra small.
- **Out of scope:** no new settings, no upward directory search, no shared team configuration, and no way for Han to
  create your personal file for you. The CLAUDE.md pointer that `project-discovery` maintains keeps naming the project
  file only, and Step 5 of that skill is deliberately left unchanged
  ([D-12](artifacts/implementation-decision-log.md#trivial-decisions)). If a reviewer notices `project-discovery` is
  absent from the fan-out, that absence is the decision, not an omission.
- **Watch after ship:** whether the personal probe resolves on machines other than the one it was checked on,
  and whether anyone's deliverables start landing somewhere unexpected now that the containment guard is gone
  ([D-13](artifacts/implementation-decision-log.md#trivial-decisions)).

## Implementation Approach

The shape of this work is: add a second read to the probe, teach the contract there are now two files, and correct the
handful of places that describe configuration in their own words rather than pointing at the contract.

The suite reads configuration in one place and interprets it in another. Every skill that reads configuration carries a
context probe in its `## Project Context` section, which shells out, reads the project file, and injects its content.
Beneath that probe sits an identical three-line paragraph telling the skill to apply what it found according to the
interpretation contract. The contract itself is one reference file, vendored byte-identical into each skill-carrying
plugin.

- The probe lives in each skill's `## Project Context` section.
- The contract is `han-core/references/config-rule.md`, copied into every plugin's `references/` folder.

### The probe is the whole risk

No probe anywhere in this suite contains a `$`. Every one of them reads a fixed relative path. This feature needs a
probe that resolves an environment variable with a fallback.

The loader that decides which probe commands are allowed to run lives outside this repository. Its own guidance
allowlists specific commands and refuses four constructs, but says nothing either way about parameter expansion. It
also warns, in its own text, that the allowlist can shift between Claude Code versions.

The failure this creates is nastier than the one the suite already survived. When a probe exited nonzero, every skill
aborted loudly in every project without the file, and it was found and fixed. When a probe fails to expand a variable,
it still exits 0, still injects nothing, and the feature simply never works for anyone, forever, with no error. The
specification's own decision to stay silent about an unreachable personal configuration is what makes it undetectable
by anything except a deliberate check.

So the first work unit is a live check on one skill, four cases, before any fan-out
([D-1](artifacts/implementation-decision-log.md#d-1-prove-the-probe-loads-before-anything-fans-out)). Two candidate
probe shapes go into that same pass, a one-line nested expansion and a three-line version that keeps each expansion as
simple as possible, and the simpler one wins if it loads
([D-2](artifacts/implementation-decision-log.md#d-2-two-candidate-probe-shapes-checked-in-the-same-pass)). If neither
loads, the route out is already chosen rather than decided in the middle of a 40-file edit
([D-3](artifacts/implementation-decision-log.md#d-3-the-contingency-is-pre-decided-so-the-fan-out-cannot-stall)).

Unverified: could not inspect the Claude Code skill loader's command classifier, because it is closed-source and not
present in this repository.

Two requirements sit on whichever shape wins, and both are requirements rather than details to discover while building.
The probe has to hand the run the resolved configuration directory as a value, not only the file's content. Rooting a
relative path needs to know which directory the personal file came from, and so does spotting the case where both
lookups land on one file
([D-4](artifacts/implementation-decision-log.md#d-4-the-run-receives-the-resolved-directory-as-a-value-not-only-the-file-content)).

The two reads also need distinct labels, agreed once and applied identically across every file. A message that
says `.han/config.md` when there are two of them tells you nothing
([D-5](artifacts/implementation-decision-log.md#d-5-the-two-configuration-reads-get-distinct-labels-settled-before-the-fan-out)).

### The interpretation contract

The contract is a short file, but this change touches most of it. It touches the title, the opening sentence about a
consuming project carrying one optional file, both schema bullets that root paths at the working directory, and the
working-directory section. It also touches the precedence chain, which grows from five sources to six, and the
output-directory containment section, which goes away entirely along with its fall-back-and-note behavior.

The file keeps its current name even though its title stops saying "project," because renaming it would change every
path that points at it for no behavioral gain
([D-11](artifacts/implementation-decision-log.md#trivial-decisions)).

One line gets added that has no equivalent today: the run expands a leading home-directory shortcut before using a
configured path. Shells do that expansion; tools do not. And 13 of the 40 skills declare no shell access at all, so
leaving it unsaid would make the feature work in 27 skills and silently fail in the other 13
([D-8](artifacts/implementation-decision-log.md#d-8-the-run-expands-a-home-directory-shortcut-before-using-a-configured-path)).

- Canonical file: `han-core/references/config-rule.md`, then eleven byte-identical copies
  ([D-14](artifacts/implementation-decision-log.md#trivial-decisions)).

### The surface this touches is about sixty files, not two

The specification names two categories of change. The measured surface is larger, and the difference matters because
the extra files are the ones a fan-out misses:

- The 40 skill probes, plus the identical paragraph beneath each one, which currently ends by talking about the project
  config alone.
- The 12 vendored copies of the contract.
- The operator guide, `docs/configuration.md`, which states the containment guard in two places and lists an
  out-of-bounds output directory among the things it will complain about.
- Two readability skills that carry their own sentence about resolving the writing-voice path, worded differently from
  each other, so no single search finds both.
- Three han-atlassian skills that describe the output directory as the project's.
- Five size-band announcement texts that name `.han/config.md` as the source of the band they adopted.
- Eight further documents that describe configuration as project-local and become factually wrong the moment this
  ships. They are corrected through the repository's own documentation sweep rather than by hand
  ([D-10](artifacts/implementation-decision-log.md#d-10-the-documents-the-change-makes-wrong-are-corrected-through-the-existing-documentation-sweep)).

### Landing

The contract change, the 40 probe changes, and the guide land together in one change. Split across two commits, either
order is wrong. Contract first tells skills to resolve a personal file that nothing hands them. Probes first delivers
personal content with no precedence rule attached, which a skill may reasonably read as the project configuration
([D-6](artifacts/implementation-decision-log.md#d-6-the-contract-the-probes-and-the-guide-land-together)). These are
content files read at load time, so there is no window in which a half-landed state sits harmlessly.

## Work Units and Sequencing

| #   | Work Unit                                                    | Story         | Delivers                                                                                                                                                | Justification                                                                                                                            | Depends On | Verification                                                                                              |
| --- | ------------------------------------------------------------ | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ---------- | ----------------------------------------------------------------------------------------------------------- |
| 1   | Prove the probe loads                                        | US-1          | A chosen probe shape, proven on one skill, with the injected value for each of four cases written down verbatim ([D-1](artifacts/implementation-decision-log.md#d-1-prove-the-probe-loads-before-anything-fans-out), [D-2](artifacts/implementation-decision-log.md#d-2-two-candidate-probe-shapes-checked-in-the-same-pass)) | Necessity of the asked-for work. The request names `$CLAUDE_CONFIG_DIR`, and no probe in the suite has ever resolved a variable.          | —          | All four cases produce their expected injected value, recorded verbatim rather than as "worked".              |
| 2   | Settle the two labels and the shared paragraph               | US-3          | One agreed label per read and one rewritten paragraph, as text, before any of the 40 files is edited ([D-5](artifacts/implementation-decision-log.md#d-5-the-two-configuration-reads-get-distinct-labels-settled-before-the-fan-out)) | Necessity of the asked-for work. `D7` requires every message to name its file, which two identical labels make impossible.                | 1          | The label pair and paragraph exist in writing and are used unchanged by units 3 and 4.                        |
| 3   | Rewrite the interpretation contract and re-sync the copies   | US-2, US-4    | A contract describing two files, six precedence sources, per-file relative rooting, home-shortcut expansion, and no containment guard ([D-8](artifacts/implementation-decision-log.md#d-8-the-run-expands-a-home-directory-shortcut-before-using-a-configured-path), [D-14](artifacts/implementation-decision-log.md#trivial-decisions)) | Necessity of the asked-for work. The contract is where precedence and path rooting are defined.                                          | 1, 2       | One md5 hash across the 12 copies.                                                                            |
| 4   | Add the personal read to every skill probe                   | US-1          | All 40 skill files reading both configurations, with the labels and paragraph from unit 2                                                                | Asked for directly: read the personal file first, then the project file.                                                                 | 2, 3       | 40 files carry the new form; 0 carry the old form without it.                                                 |
| 5   | Correct the resolution language living outside the contract  | US-3, US-4    | Ten sites whose own wording would otherwise contradict the contract: two readability skills, five size-band announcements, three han-atlassian skills     | Necessity of the asked-for work. Each carries its own copy of resolution language and would disagree with the contract if left alone.     | 3          | All ten hand-checked, one at a time, against the rewritten contract.                                          |
| 6   | Rewrite the operator guide                                   | US-5          | A guide describing both files, the six-source chain, per-file rooting, and the guard removal, with the out-of-bounds entry gone from its degradation list | Asked for by `D11`, which makes the guide part of the work.                                                                              | 3          | Guide read end to end against the contract; no statement in one contradicts the other.                        |
| 7   | Land units 3 through 6 together and run the completeness checks | US-1 – US-5 | One change containing the contract, the probes, the outside-the-contract sites, and the guide ([D-6](artifacts/implementation-decision-log.md#d-6-the-contract-the-probes-and-the-guide-land-together)) | Necessity of the asked-for work. No split across two commits leaves a correct intermediate state.                                        | 3, 4, 5, 6 | The four checks in [D-7](artifacts/implementation-decision-log.md#d-7-completeness-is-checked-with-greps-at-review-time-with-the-expected-counts-written-down) pass, plus the ten hand-checked sites. |
| 8   | Sweep the documents the change makes wrong                   | US-5          | Eight documents that describe configuration as project-local, brought back in line ([D-10](artifacts/implementation-decision-log.md#d-10-the-documents-the-change-makes-wrong-are-corrected-through-the-existing-documentation-sweep)) | Necessity of the asked-for work. The change makes them false; it does not make them optional.                                             | 7          | The documentation sweep reports each of the eight as reviewed, and each names both files.                     |
| 9   | Record the release recommendation                            | US-1          | A written recommendation for `/han-release`: every skill-carrying plugin and the meta-plugin bumped together, at a major bump ([D-9](artifacts/implementation-decision-log.md#d-9-recommend-one-coordinated-release-across-every-skill-carrying-plugin-at-a-major-bump)) | Necessity of the asked-for work. `D11` promises everywhere-or-nowhere, and a partial upgrade breaks that promise in a user's installed set. | 7          | The recommendation is written and no version file or CHANGELOG entry is changed by this work.                 |

## Definition of Done

- [ ] The four probe cases each produce their expected injected value on one skill, recorded verbatim
      ([D-1](artifacts/implementation-decision-log.md#d-1-prove-the-probe-loads-before-anything-fans-out)).
- [ ] A run with a personal file and no project file uses the personal values, and a run with neither behaves exactly as
      it does today and says nothing.
- [ ] A run with both files uses the project's value for the settings the project names and the personal value for
      every other setting.
- [ ] A relative path in the personal file resolves beside that file, and a relative path in the project file resolves
      beside the project as it does today.
- [ ] A configured path that points outside the project is honored, and the directory is created on first write.
- [ ] Every message about configuration names the file it came from, using the labels settled in unit 2
      ([D-5](artifacts/implementation-decision-log.md#d-5-the-two-configuration-reads-get-distinct-labels-settled-before-the-fan-out)).
- [ ] A leading home-directory shortcut in a configured path resolves, including in the 13 skills that declare no shell
      access ([D-8](artifacts/implementation-decision-log.md#d-8-the-run-expands-a-home-directory-shortcut-before-using-a-configured-path)).
- [ ] The four review-time checks pass with the counts stated, and the ten prose sites no grep can reach are hand-checked
      ([D-7](artifacts/implementation-decision-log.md#d-7-completeness-is-checked-with-greps-at-review-time-with-the-expected-counts-written-down)).
- [ ] `docs/configuration.md` and the interpretation contract describe the same behavior, with no containment guard in
      either.
- [ ] The eight further documents no longer describe configuration as project-local
      ([D-10](artifacts/implementation-decision-log.md#d-10-the-documents-the-change-makes-wrong-are-corrected-through-the-existing-documentation-sweep)).
- [ ] `npm run lint` and `npm test` pass, and no version number or CHANGELOG entry was changed by this work
      ([D-9](artifacts/implementation-decision-log.md#d-9-recommend-one-coordinated-release-across-every-skill-carrying-plugin-at-a-major-bump)).

## Testing Strategy

This repository has no application runtime. Its content is Markdown that a skill loader reads, and its only automated
tests are Bats suites covering four skills' shell scripts. Nothing today tests skill content or probe behavior, and this
plan adds no such machinery. So the proof of correctness is the live loader check plus review-time checks, rather than a
test suite.

- **Observable behaviors to test:** the four probe cases from
  [D-1](artifacts/implementation-decision-log.md#d-1-prove-the-probe-loads-before-anything-fans-out), run by hand on one
  skill. Then a run with only a personal file, a run with only a project file, and a run with both where the project
  names one setting.
- **Edge cases requiring coverage:** both lookups resolving to the same file, because you are running inside your own
  configuration directory; a blank recognized setting in the project file falling through to the personal value rather
  than to the default; the same setting broken in each file producing two notes; a name appearing in both extra-agents
  lists counting once; a personal `writing-voice` path pointing at a file that is not there.
- **Test doubles posture and levels:** none. There is no unit level to double at, and the two checks that matter run
  against the real loader and the real filesystem.

## Operational Readiness

- **Rollout:** one change, landing everywhere configuration is read. There is no flag and no staged rollout, because a
  configuration layer that applies in some skills and not others is the outcome `D11` rules out.
- **Release coordination:** the recommendation is that all twelve skill-carrying plugins and the `han` meta-plugin bump
  together, at a major bump. `docs/configuration.md` should say plainly that the personal file needs the whole suite at
  or above that version. The suite currently spans versions 1.0.0 to 5.0.0, so a user upgrading some plugins and not
  others gets exactly the split behavior the specification rejects. This plan records the recommendation and changes no
  version; `/han-release` owns the bump and the CHANGELOG
  ([D-9](artifacts/implementation-decision-log.md#d-9-recommend-one-coordinated-release-across-every-skill-carrying-plugin-at-a-major-bump)).
- **Rollback:** revert the change and bump the version. There is no runtime state to unwind. The one residue is the
  user's personal configuration file, which survives the revert and silently stops applying, which is the same state as
  before the feature existed.
- **Blast radius of the guard removal:** a project carrying an absolute `output-directory` today sees a note and a
  fallback on every run. After the upgrade it starts writing deliverables to that path on the first run, with nobody
  editing a file. The specification already declined a per-run note about this and named the trigger that would reopen
  it, so this plan adds no behavior. It adds one sentence in the release notes and one in the operator guide naming the
  removal. The out-of-bounds output directory also leaves the guide's list of things it will complain about
  ([D-13](artifacts/implementation-decision-log.md#trivial-decisions)).
- **Observability:** none, and none is added. This repository has no runtime, no traffic, and emits no data. See
  Deferred (YAGNI).

## Risks and Assumptions

### Risks

| ID  | Risk                                                                                                       | Impact                                                                                       | Mitigation                                                                                                              | Owner                        |
| --- | ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| R1  | Neither probe shape loads, because the loader declines the variable expansion.                              | The feature cannot be delivered through the mechanism the suite uses everywhere.               | Unit 1 finds out on one file. The route out is pre-decided ([D-3](artifacts/implementation-decision-log.md#d-3-the-contingency-is-pre-decided-so-the-fan-out-cannot-stall)). | `han-core:devops-engineer`   |
| R2  | The probe loads but resolves the wrong directory on a machine where the variable and the default both exist. | The personal file silently never applies, with no error, for everyone who moved their config.  | Case 1 is checked against case 3 rather than on its own; a passing case 1 alone is treated as no evidence.               | `han-core:devops-engineer`   |
| R3  | A user upgrades some Han plugins and not others.                                                            | Settings follow them into some skills and not others, which is the outcome `D11` rejects.      | One coordinated release, plus the version note in the guide ([D-9](artifacts/implementation-decision-log.md#d-9-recommend-one-coordinated-release-across-every-skill-carrying-plugin-at-a-major-bump)). | `han-core:devops-engineer`   |
| R4  | A project already carrying a refused `output-directory` starts writing there on upgrade.                    | Deliverables land outside the repository with no signal at the moment the behavior changes.    | Named in the release notes and the guide, with no run-time behavior added ([D-13](artifacts/implementation-decision-log.md#trivial-decisions)). | `han-core:devops-engineer`   |
| R5  | One file is missed in a roughly sixty-file fan-out.                                                         | One skill reads configuration differently from the rest, which is the split behavior `D11` rejects. | Four review-time checks with their expected counts written down before the work starts ([D-7](artifacts/implementation-decision-log.md#d-7-completeness-is-checked-with-greps-at-review-time-with-the-expected-counts-written-down)). | `han-core:devops-engineer`   |
| R6  | A prose site keeps its own resolution wording and contradicts the contract.                                 | Two documents describe the same behavior differently, and readers follow whichever they meet.  | Unit 5 hand-checks all ten, with the count stated, because a search provably cannot reach them.                          | `han-core:junior-developer`  |

### Assumptions

| ID  | Assumption                                                                                              | What Changes If Wrong                                                                              | Status      |
| --- | --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ----------- |
| A1  | The skill loader will run a probe that resolves an environment variable, in at least one of the two shapes. | The contingency in [D-3](artifacts/implementation-decision-log.md#d-3-the-contingency-is-pre-decided-so-the-fan-out-cannot-stall) becomes the plan, and 13 skills need their tool permissions changed. | Open        |
| A2  | The 12 vendored copies of the contract are byte-identical today.                                          | The checksum check stops being a passing invariant and cannot detect a missed copy.                | Verified    |
| A3  | Exactly 40 skill files carry the configuration probe.                                                     | The expected count in the completeness check is wrong, and a missed file passes review.            | Verified    |
| A4  | Thirteen of the 40 skills declare no shell access.                                                        | The home-shortcut rule and the contingency's permission cost are both mis-sized.                   | Verified    |
| A5  | The documentation sweep skill can reach all eight further documents.                                      | Some of the eight become hand-edits with their own review-time check.                              | Open        |

A1 rests on behavior neither specialist could inspect, which is why unit 1 measures it rather than assuming it.
Unverified: could not inspect the Claude Code skill loader's command classifier, because it is closed-source and not
present in this repository.

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it.

### Fixing the feedback skill's hardcoded configuration path

The `han-feedback` skill writes its files to `~/.claude/han-feedback/`, spelled out by hand in three places rather than
resolved from your Claude Code configuration directory. That is the same hazard this feature exists to fix, one skill
over. In plain language: after this ships, a person who has moved their Claude Code configuration folder will still find
that one skill writing its feedback files to the old place.

- **Why cut:** [artifacts/scope-boundary.md](artifacts/scope-boundary.md) records the whole request as adjusting "the
  han config file loading". This is output-path handling inside one skill, not configuration loading, and that skill
  reads no configuration file.
- **Source:** R1, `han-core:devops-engineer`, raised under an explicit out-of-scope verdict naming no replacement work
  (claim `CL-16`).

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### A Bats check asserting probe-line counts and vendored-copy checksum equality

- **Why deferred:** the evidence test. The one documented incident in this area was a byte-identical probe line that was
  wrong in all 39 files at once, which a text-equality check would have passed cleanly. No incident of a missed file or
  a drifted copy exists. The simpler version satisfies the same need: the four review-time checks in
  [D-7](artifacts/implementation-decision-log.md#d-7-completeness-is-checked-with-greps-at-review-time-with-the-expected-counts-written-down),
  which need no new machinery.
- **Reopen when:** the checksum check returns more than one hash on any branch, or a second suite-wide fan-out misses a
  file.
- **Source:** R1. Proposed by `han-core:junior-developer` (`JD-005`), disputed by `han-core:devops-engineer` (`R8`),
  recorded as claim `CL-15` and resolved in `R8`'s favor. The dissent is recorded in full on
  [D-7](artifacts/implementation-decision-log.md#d-7-completeness-is-checked-with-greps-at-review-time-with-the-expected-counts-written-down).

### A script that re-syncs the twelve vendored copies of the contract

- **Why deferred:** the simpler-version test. A one-line copy loop in the pull request, plus the checksum check,
  satisfies the same need without adding a script the repository then has to maintain and keep tested.
- **Reopen when:** the re-sync has been done by hand a fourth time, or the checksum check catches a miss.
- **Source:** R1, `han-core:devops-engineer` (claim `CL-7`).

### Telemetry, alerting, dashboards, or a runbook for this feature

- **Why deferred:** the evidence test, and the YAGNI rule's named anti-pattern of building operational machinery for
  signals that do not exist. This repository has no runtime, receives no traffic, and emits no data about configuration
  resolution.
- **Reopen when:** Han acquires a runtime that emits data about how configuration was resolved.
- **Source:** R1, `han-core:devops-engineer`.

## Open Items

- **OI-1:** A personal `default-swarm-size` applies to every project you touch, where the decision record that
  introduced the setting weighed its cost at one project. That record now reads narrower than the shipped behavior.
  Carried forward unchanged from the specification.
  - **Resolves when:** someone decides whether to amend `docs/adr/0001-project-configurable-default-swarm-size.md` or
    cover the wider scope in the configuration guide.
  - **Blocks implementation:** No. The behavior is settled; what is open is which document records why.

## Sources and Plan Records

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Specification companions:** [decision log](artifacts/decision-log.md),
  [team findings](artifacts/team-findings.md), [technical notes](artifacts/feature-technical-notes.md),
  [scope boundary](artifacts/scope-boundary.md)
- **Specification decisions inherited / open items to respect:** D1 through D11 / OI-1
- **Decision rationale and rejected alternatives:**
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Team composition and round-by-round history:**
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)

## Recommendation

Ship as planned, with unit 1 as a genuine gate rather than a formality. If the four probe cases do not all pass, take
the pre-decided route in [D-3](artifacts/implementation-decision-log.md#d-3-the-contingency-is-pre-decided-so-the-fan-out-cannot-stall)
rather than proceeding with the fan-out. OI-1 does not block; it decides which document records a behavior that is
already settled.
