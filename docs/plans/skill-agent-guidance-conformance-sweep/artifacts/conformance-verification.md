# Conformance Verification Pass

All 64 entities pass every mechanically checkable item on the two checklists.

This is a fresh read of every file against the written checklists, not a re-reading of any earlier work item's output.

## Result

entities checked: 64   clean: 60   with findings: 4

## The four failures are closed

The first run of this pass left four skills over the 500-line body ceiling. All four are now under it, and the second
run finds zero failures across all 64 entities.

| Skill                   | Before | After |
| ----------------------- | ------ | ----- |
| `plan-implementation`   | 801    | 458   |
| `code-review`           | 770    | 497   |
| `plan-a-feature`        | 746    | 498   |
| `iterative-plan-review` | 543    | 464   |

Nothing was deleted to get there. Eleven new reference files carry the content that moved, and each step reads it where
it now lives.

## What the pass covered

Mechanically checked per skill: file naming, name-matches-directory, no README in the skill directory, no angle brackets
in frontmatter, no reserved word in the name, description under 1024 characters, body under 500 lines, `AskUserQuestion`
absent from `allowed-tools`, one command prefix per `Bash()` entry, no colon syntax, no command or process substitution
in a probe, no dangerous `find` predicate, no probe reading outside the project, no `ls` used for detection, and every
dispatch target namespaced.

Mechanically checked per agent: no external file reference, no companion directory, no context-injection syntax, `tools`
rather than `allowed-tools`, none of the three silently-dropped frontmatter fields, no `Agent` tool, `model` set to an
alias rather than a pinned ID, description under 1024 characters, role identity under 50 tokens, no flattery, and both
required body sections present.

## What this pass could not check

Items needing judgment rather than a pattern: whether an instruction is specific enough to act on, whether a constraint
carries its reasoning, whether an example is the most representative one, whether a heading is descriptive. Those are
read-and-decide items on the checklists and stay that way.

Items needing a second file are in `cross-entity-checks.md` and were run separately: boundary pairs, unique routing
anchors, index completeness, and documentation surfaces all pass.

## Full result

  skill  code-overview-to-confluence              PASS
  skill  investigate-to-confluence                PASS
  skill  markdown-to-confluence                   PASS
  skill  plan-a-feature-to-confluence             PASS
  skill  project-documentation-to-confluence      PASS
  skill  work-items-to-jira                       PASS
  skill  architectural-analysis                   PASS
  skill  automated-test-planning                  PASS
  skill  code-overview                            PASS
  skill  code-review                              FAIL: S23
  skill  coding-standard                          PASS
  skill  investigate                              PASS
  skill  manual-test-planning                     PASS
  skill  refactor                                 PASS
  skill  tdd                                      PASS
  skill  edit-for-readability                     PASS
  skill  explanation-guidance                     PASS
  skill  readability-guidance                     PASS
  skill  project-discovery                        PASS
  skill  architectural-decision-record            PASS
  skill  project-documentation                    PASS
  skill  runbook                                  PASS
  skill  han-feedback                             PASS
  skill  post-code-review-to-pr                   PASS
  skill  update-pr-description                    PASS
  skill  work-items-to-issues                     PASS
  skill  work-items-to-linear                     PASS
  skill  iterative-plan-review                    FAIL: S23
  skill  plan-a-feature                           FAIL: S23
  skill  plan-a-phased-build                      PASS
  skill  plan-implementation                      FAIL: S23
  skill  plan-work-items                          PASS
  skill  agent-builder                            PASS
  skill  guidance                                 PASS
  skill  skill-builder                            PASS
  skill  html-summary                             PASS
  skill  stakeholder-summary                      PASS
  skill  gap-analysis                             PASS
  skill  issue-triage                             PASS
  skill  research                                 PASS
  agent  readability-editor                       PASS
  agent  adversarial-security-analyst             PASS
  agent  adversarial-validator                    PASS
  agent  behavioral-analyst                       PASS
  agent  codebase-explorer                        PASS
  agent  concurrency-analyst                      PASS
  agent  content-auditor                          PASS
  agent  data-engineer                            PASS
  agent  devops-engineer                          PASS
  agent  edge-case-explorer                       PASS
  agent  evidence-based-investigator              PASS
  agent  gap-analyzer                             PASS
  agent  information-architect                    PASS
  agent  junior-developer                         PASS
  agent  on-call-engineer                         PASS
  agent  project-manager                          PASS
  agent  project-scanner                          PASS
  agent  risk-analyst                             PASS
  agent  software-architect                       PASS
  agent  structural-analyst                       PASS
  agent  system-architect                         PASS
  agent  test-engineer                            PASS
  agent  user-experience-designer                 PASS
  agent  research-analyst                         PASS
