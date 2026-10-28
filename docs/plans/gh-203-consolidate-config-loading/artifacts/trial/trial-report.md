# Trial report: does an inline loader that surfaces `.han/config.md` values hold?

**Verdict: GO.** Across 99 same-context trials in 15 arms, every consumer finished all six of its steps,
applied every configured value as the config rule says, and invoked the loader exactly as many times as the arm
expected. Zero early exits. Zero wrong values. The one trigger the harness cannot induce is a real `api_retry`, and
one model (Opus) was tested, so the claim is scoped the same way the OI-3 spike's was.

## What was tested

Issue #203 step 2 asked for an OI-3-shaped trial on the values case: the OI-3 spike showed an inline sub-skill can
surface a whole standard without the caller stopping early; this trial checks the thing the guidance said was untested,
an inline sub-skill that surfaces a lookup's values which the caller must then use.

The harness mirrors the spike. Project skills under `.claude/skills/spike-*` (preserved beside this report under
`harness/`), a heavy six-step incident post-mortem consumer that must carry four facts across the loader call, and a
fresh Opus subagent per trial told only to run the skill. Completion was judged from the artifact on disk by
`check-trials.py`: the completion token as the last line, four facts, five sections, the `cfg:` field against the
arm's expected values, and the `.loads` side-effect file (one appended line per loader run) against the expected count.
The consumer additionally had to apply four settings: write under `output-directory`, report `default-swarm-size`,
read the `writing-voice` file and end its Summary with that file's sentinel word, and keep only the `## Extra Agents`
entries that name an agent in the session.

The loader under test is `spike-loader`, a copy of `han-core/skills/load-han-config/SKILL.md` with a trial-only step
that appends the `.loads` line; `spike-loader-worst` is the same body ending on "The configuration review is complete.
Nothing further is required." with no hand-back instruction.

## Results

| Arm           | What it checks                                                                                              | N   | Completed | Early exits | Values correct | Loads as expected |
| ------------- | ----------------------------------------------------------------------------------------------------------- | --- | --------- | ----------- | -------------- | ----------------- |
| BASE          | Today's probe block, no Skill call (isolates consumer flakiness)                                            | 6   | 6         | 0           | 6              | 6 (0 loads)       |
| INL           | Consumer carries the line, invokes the loader once                                                          | 12  | 12        | 0           | 12             | 12                |
| WORST         | Loader ends on a final-sounding line; consumer has no continuation guardrail                                | 10  | 10        | 0           | 10             | 10                |
| CHAIN         | Consumer loads, then invokes a second inline skill that also carries the line                               | 12  | 12        | 0           | 12             | 12 (1 load)       |
| BLOCK-THEN-LINE | Consumer carries the old block, then invokes a skill carrying the line                                    | 5   | 5         | 0           | 5              | 5 (0 loads)       |
| DEPTH-2       | Consumer has no line; the second skill carries it and the loader runs two deep                              | 6   | 6         | 0           | 6              | 6 (1 load, by the second skill) |
| DIRECT        | A person runs the loader with no caller                                                                     | 6   | 6         | 0           | n/a            | 6 (reported both files and stopped) |
| INL-NOGRANT   | Consumer without `Skill` in `allowed-tools`                                                                 | 4   | 4         | 0           | 4              | 4; no prompt, denial, or error reported |
| A-state wave  | INL 4, WORST 2, CHAIN 1, DIRECT 1 run before the fixtures were reachable (no config present)                | 8   | 8         | 0           | 8 (defaults)   | 8                 |
| CFG-P         | Personal file only                                                                                          | 5   | 5         | 0           | 5              | 5                 |
| CFG-J         | Project file only                                                                                           | 5   | 5         | 0           | 5              | 5                 |
| CFG-C         | Both files set everything; project wins each scalar, agents are the union                                   | 5   | 5         | 0           | 5              | 5                 |
| CFG-M         | Project frontmatter malformed; personal applies; the parse failure is noted                                 | 5   | 5         | 0           | 5              | 5                 |
| CFG-A         | Neither file; every default                                                                                 | 5   | 5         | 0           | 5              | 5                 |
| CFG-P-MISSING | Personal directory does not exist; project applies; no note, no error                                       | 5   | 5 | 0 | 5 | 5     |

Every arm above ran with both fixture files present and disjoint (project: output directory and swarm band; personal:
voice and extra agents) unless its row says otherwise. The checker's per-trial output is in `check-*.log`; the manifests
that fed it are `manifest-*.json`; every artifact and `.loads` file is under `trials/` (and `trials-A-state/` for the
first wave).

## What the trial settles

- **The caller resumes after a values-only inline sub-skill**, including when the sub-skill ends on a stopping
  sentence and the caller carries no guardrail. Several WORST testers wrote, unprompted, that the closing line "ended
  only the loader's own work."
- **"If you have not already this run" works as a content check.** In every CHAIN and BLOCK-THEN-LINE trial the
  second skill's line was read against the context and skipped; in every DEPTH-2 trial the second skill loaded because
  nothing had.
- **Raw content under the old labels is enough.** Callers applied precedence, personal-relative voice paths, the
  malformed-file rule, and the unresolvable-agent rule from the config rule without the loader resolving anything.
- **A missing `Skill` grant did not prompt or fail** in this session's permission mode (4/4). The mode is auto, so a
  prompt may have been auto-approved; the arm shows the call completes, not that no prompt exists in default mode.

## What it does not settle

- `api_retry` was never induced; the harness cannot inject an infrastructure fault.
- Only Opus testers ran, by direction; a smaller-model worst-case arm was planned and dropped.
- Codex was not exercised.
- One harness defect: the CFG-P fixture gave the personal file a relative `output-directory` while the consumer stated
  the personal-relative rule only for `writing-voice`. 3 of 5 testers applied the config rule's reading and 2 the
  working directory; both were accepted for that arm, and the later personal fixtures use an absolute path.

## Reproducibility

`harness/` holds every SKILL.md and the fixture files; `check-trials.py` and the manifests reproduce the verdicts from
`trials/`. The harness skills were removed from `.claude/skills/` after the run.
