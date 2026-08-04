# Agent Model Tier and Frontmatter Audit

Every one of the 24 agents now has its model tier recorded against a named archetype, so a later reader can check the
assignment instead of trusting it. Twenty-two match cleanly. Two are genuine mismatches, left unchanged and raised
instead, because changing which model an agent runs on is a behavior change nobody asked for.

The archetypes come from `agent-model-selection.md` § Evidence from Agent Archetypes. The keep-or-drop reasoning comes
from `specialization-and-model-selection.md` § How this shapes model choices.

## Frontmatter, mechanically checked

All 24 agents carry exactly `name`, `description`, `tools`, and `model`. No agent sets `hooks`, `mcpServers`, or
`permissionMode`, the three fields a plugin agent silently drops. Every `model` value is an alias rather than a pinned
model ID, so each keeps tracking the current model in its tier. No agent carries the `Agent` tool, which is the
documented default.

## Five dead tool grants, removed

Five agents declared a git permission their body never used. A grant nothing exercises is access for nothing, so each
was removed.

| Agent                | Removed                                    | Why it was dead                                                     |
| -------------------- | ------------------------------------------ | -------------------------------------------------------------------- |
| `codebase-explorer`  | `Bash(git *)`                              | Body explores files and structure; never invokes git.               |
| `concurrency-analyst` | `Bash(git *)`                              | Body reads source for races; never invokes git.                     |
| `content-auditor`    | `Bash(git *)`                              | Body compares documentation against source; never invokes git.      |
| `system-architect`   | `Bash(git *)`                              | Body states it does no codebase discovery of its own.               |
| `project-scanner`    | `Bash(git remote *)`, `Bash(git config *)` | Body reads config files and directory structure; never invokes git. |

`project-scanner` needed one extra check before the removal was safe, because repository metadata is plausibly its job.
The skill that dispatches it, `project-discovery`, discovers the default branch through its own probe rather than
through the agent, so nothing downstream loses anything.

## Tier assignments

### Smallest tier: fast lookup and classification

| Agent             | Archetype                                        | Verdict                                                          |
| ----------------- | ------------------------------------------------ | ---------------------------------------------------------------- |
| `project-scanner` | Structure-and-config explorer                    | Exact match. Reads manifests and directory structure, emits a fixed catalog. |
| `content-auditor` | Fact extractor / classifier against a fixed list | Exact match. Classifies each fact as present, correctly removed, or missing. |

### Middle tier: structured protocols against a fixed rubric

| Agent                        | Archetype                        | Verdict                                                              |
| ---------------------------- | -------------------------------- | ---------------------------------------------------------------------- |
| `evidence-based-investigator` | Protocol-following investigator  | Exact match. Walks defined investigation protocols.                  |
| `adversarial-validator`      | Rubric-based validator           | Exact match. Executes structured challenge strategies.               |
| `readability-editor`         | Rubric-based validator           | Walks a fixed six-point standard it does not invent.                 |
| `gap-analyzer`               | Rubric-based validator           | Compares two artifacts against a fixed four-category gap taxonomy.   |
| `risk-analyst`               | Rubric-based validator           | Scores each finding against four named dimensions.                   |
| `edge-case-explorer`         | Open-ended edge-case explorer    | Exact match, and the archetype is named for this shape.              |
| `test-engineer`              | Test planner across many files   | Exact match.                                                         |
| `structural-analyst`         | Protocol-following investigator  | Walks a named anti-pattern list over static structure.               |
| `behavioral-analyst`         | Protocol-following investigator  | Walks a named anti-pattern list over runtime behavior.               |
| `concurrency-analyst`        | Protocol-following investigator  | Walks a named anti-pattern list over concurrency.                    |

### Largest tier: synthesis over unbounded input, and novel reasoning

| Agent                          | Archetype                                     | Verdict                                                              |
| ------------------------------ | --------------------------------------------- | ---------------------------------------------------------------------- |
| `project-manager`              | Facilitator synthesizing many specialists     | Exact match, and the archetype is named for this shape.              |
| `software-architect`           | Architect synthesizing cross-cutting findings | Exact match.                                                         |
| `system-architect`             | Architect synthesizing cross-cutting findings | Exact match, at cross-service altitude.                              |
| `adversarial-security-analyst` | Novel reasoning                               | Adversarial exploit-path construction is named as a keep-opus case.  |
| `junior-developer`             | Facilitator / open-ended questioner           | Generates questions nobody wrote down, over whatever artifact arrives. |

### The five specialist reviewers, kept at the largest tier with the counter-argument recorded

| Agent                      | Kept at largest, because                                                                              |
| -------------------------- | ------------------------------------------------------------------------------------------------------- |
| `data-engineer`            | Weighs competing trade-offs (normalization against access pattern, consistency against availability) over an unbounded schema and query surface. |
| `devops-engineer`          | Judges blast radius and rollout safety across code, pipelines, and infrastructure at once.            |
| `on-call-engineer`         | Judges whether a missing safeguard at one site is actually safe because another site enforces it.     |
| `information-architect`    | Reasons about a reader's task and arrival path, which the prompt cannot pre-shape.                    |
| `user-experience-designer` | Same shape: judges a flow against a user's goal rather than walking a checklist.                      |

**The counter-argument, recorded rather than buried.** All five carry heavy domain frameworks: named methodologies, long
domain vocabularies, and explicit anti-pattern lists. That is precisely the profile
`specialization-and-model-selection.md` names as the strongest case for dropping a tier, since the framework is already
baked into the prompt rather than invented at run time.

They are kept at the largest tier because each also weighs competing factors over input the prompt cannot bound, which is
the stated keep condition. Both readings are defensible. If someone later wants to measure this rather than argue it, the
five above are the population to test, and dropping one tier is the experiment.

## Two genuine mismatches, raised rather than changed

Neither is changed here. Model tier decides how an agent behaves on every future run, and the sweep's own boundary is
correcting conflicts with the guidance, not re-tuning agent behavior on a judgment call.

**`codebase-explorer` runs on the smallest tier and probably should not.** Its own guidance names two signals that point
the other way: "exploring large codebases where judgment calls determine search direction" is listed as a largest-tier
sign, and the smallest tier is described as suiting a bounded input with a predictable output shape. This agent explores
an unbounded codebase and decides where to look next. The middle tier is the likely right answer.

**`research-analyst` runs on the middle tier and may belong higher.** It researches open-ended questions across the open
web, which is unbounded input the prompt cannot pre-shape, and that is the stated keep-at-largest condition. The
counter-argument is that it works from a fixed report structure, which is middle-tier shaped.

## Sources

- `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md`
- `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-external-files.md`
- `han-plugin-builder/skills/guidance/references/specialization-and-model-selection.md`
