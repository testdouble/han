# Trial 2 report: does the shipped single-probe loader hold?

**Verdict: GO.** Across 48 same-context trials in 10 arms, every consumer finished all six of its steps, applied every
configured value as the config rule says, and reported the skill invocation sequence its arm expected. Zero early
exits. Zero wrong values. This trial ran the loader as shipped, `han-core:load-han-config` installed from a local
marketplace, so the one gap the first trial named (cross-plugin name resolution of the shipped skill) is closed. The
same two limits remain: no real `api_retry` was induced, and one model (Opus) was tested.

## Why a second trial

The first trial (`../trial/`) ran a project-skill copy of the loader as it stood then: two context-injection probes
plus a Read-tool step for the personal file. After that trial the loader was reduced to a single probe whose script
resolves both files, prints them between markers with the config rule, or says neither was found and lists the paths
tried. The vendored config-rule copies were retired and the script moved into `han-core`. This trial checks that the
shipped shape, reached by its cross-plugin name, holds under the same composition arms and configuration states.

## What was tested

The harness mirrors the first trial. Project skills under `.claude/skills/spike-*` (preserved beside this report under
`harness/skills/`, with the fixtures under `fixtures/`), a heavy six-step incident post-mortem consumer that must carry
four facts across the loader call and apply four settings, and a fresh Opus subagent per trial told only to run the
skill. Completion was judged from the artifact on disk by `check-trials.py`: the completion token as the last line, the
four facts, the five sections, and the `cfg:` field against the arm's expected values.

Two things differ from the first trial:

- **The loader is the shipped skill.** Every arm but WORST invokes `han-core:load-han-config` from the installed
  plugin, whose single probe runs `han-core/scripts/load-han-config.sh`. WORST invokes `spike-loader-worst`, a copy of
  that script whose output ends on "The configuration review is complete. Nothing further is required." with no
  hand-back sentence.
- **No `.loads` counter.** The shipped loader has no side-effect step to append to, and adding one would have meant
  testing a copy again. The invocation sequence was taken from each tester's final report instead, which was told to
  list every Skill tool call in order. That is the one check this trial could not make from disk.

The fixture state for the composition arms is B: the project file sets `output-directory` (`out-J`, an absolute path)
and `default-swarm-size: large`; the personal file sets `writing-voice` (voice-P, sentinel `VOICE_SENTINEL_P9Z`) and
`## Extra Agents` (`han-core:risk-analyst` and the nonexistent `fake:phantom`). The project skills had to be symlinked
into the main checkout's `.claude/skills/`, because a session registers project skills from the checkout it started
in, not the worktree it works in; three plumbing runs made before that link existed are not counted.

## Results

| Arm    | What it checks                                                                                    | N   | Completed | Early exits | Values correct | Sequence as expected                                |
| ------ | ------------------------------------------------------------------------------------------------- | --- | --------- | ----------- | -------------- | --------------------------------------------------- |
| INL    | Consumer carries the line, invokes the shipped loader once                                        | 8   | 8         | 0           | 8              | 8 (consumer, loader)                                |
| WORST  | Loader copy ends on a final-sounding line; consumer has no continuation guardrail                 | 6   | 6         | 0           | 6              | 6 (consumer, loader copy)                           |
| CHAIN  | Consumer loads, then invokes a second inline skill that also carries the line                     | 6   | 6         | 0           | 6              | 6 (consumer, loader, second skill; no reload)       |
| DEPTH2 | Consumer has no line; the second skill carries it and the loader runs two deep                    | 4   | 4         | 0           | 4              | 4 (consumer, second skill, loader)                  |
| DIRECT | A person runs the shipped loader with no caller                                                   | 4   | 4         | 0           | n/a            | 4 (reported both files and stopped)                 |
| CFG-P  | Personal file only                                                                                | 4   | 4         | 0           | 4              | 4                                                   |
| CFG-J  | Project file only                                                                                 | 4   | 4         | 0           | 4              | 4                                                   |
| CFG-C  | Both files set everything; project wins each scalar, agents are the union                         | 4   | 4         | 0           | 4              | 4                                                   |
| CFG-M  | Project frontmatter malformed; personal applies; the parse failure is noted                       | 4   | 4         | 0           | 4              | 4                                                   |
| CFG-A  | Neither file; the loader prints its not-found branch; every default, no note                      | 4   | 4         | 0           | 4              | 4                                                   |

The composition arms ran in two waves against state B (`manifest-B-wave1.json` for the first 11, `manifest-B.json` for
all 28); the configuration arms ran one state at a time, since the probe reads the filesystem when the skill loads
(`manifest-CFG.json`). The checker's output is in `check-B.log` and `check-CFG.log`. Artifacts sit where each arm's
`output-directory` sent them: `out-J/`, `out-P/`, and `trials/` for CFG-A.

## What the trial settles

- **The shipped loader resolves by its cross-plugin name and hands control back**, including two skills deep and
  behind a worst-case closing line. Several WORST testers wrote, unprompted, that the closing line ended only the
  loader's own work.
- **One probe is enough.** Callers applied precedence, the personal file's absolute paths, the malformed-file rule, the
  union of both agent lists, and the unresolvable-agent note from the printed rule, with the loader resolving nothing.
- **The not-found branch degrades silently.** All four CFG-A consumers used every default and carried no note about
  the missing configuration, as the branch instructs.
- **"If you have not already this run" still works as a content check** in the shipped shape: every CHAIN tester
  skipped the second skill's line, and every DEPTH2 tester loaded through it.

## What it does not settle

- `api_retry` was never induced; the harness cannot inject an infrastructure fault.
- Only Opus testers ran, by direction.
- Codex was not exercised.
- The invocation sequence is self-reported by each tester, not read from a side-effect file.
- An in-session reload (a second run in the same session after a config edit) was not measured; every trial ran in a
  fresh context.

## Reproducibility

`harness/skills/` holds every SKILL.md and the worst-case script; `fixtures/` holds the incident data, the five
configuration files, and the two voice files. `check-trials.py` with the manifests reproduces the verdicts from the
artifact folders. The harness skills, their symlinks in the main checkout, and the fixture configuration files were
removed after the run.
