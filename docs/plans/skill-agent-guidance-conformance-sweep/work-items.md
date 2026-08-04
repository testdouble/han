# Work Items — Skill and Agent Guidance Conformance Sweep

This breakdown covers a review and edit of every skill and every custom agent in the Han repository against the
skill-building and agent-building guidance the repository now carries. There is no upstream implementation plan. The
source context is the user's request, recorded word for word in
[artifacts/scope-boundary.md](artifacts/scope-boundary.md), together with a measured audit of the repository taken
before the breakdown was drafted.

The sweep touches 40 skills across 12 plugins and 24 agents across 3 plugins. Two conflicts with the guidance are already
confirmed by measurement, and the rest of the roster has not been checked yet.

Work items are numbered `W-N` for cross-reference only. `Depends on` lines refer to other work items in this file.

## Shared reference artifacts

These apply to more than one work item, so they are cited once here rather than repeated in every body.

- **Skill-building guidance** — [`han-plugin-builder/skills/guidance/references/skill-building-guidance/`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/).
  Twenty-six files, one per rule area, covering frontmatter, descriptions, progressive disclosure, composition, tool
  permissions, and instruction writing.
- **Agent-building guidance** — [`han-plugin-builder/skills/guidance/references/agent-building-guidelines/`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/).
  Six files covering description length, domain focus, external file references, model selection, graceful degradation,
  and multi-agent economics.
- **Per-model authoring guidance** — [`han-plugin-builder/skills/guidance/references/per-model-authoring.md`](../../../han-plugin-builder/skills/guidance/references/per-model-authoring.md).
  Says what to leave out of instructions on current models, and how to calibrate deliverable length, narration, and
  scope.
- **Specialization and model selection** — [`han-plugin-builder/skills/guidance/references/specialization-and-model-selection.md`](../../../han-plugin-builder/skills/guidance/references/specialization-and-model-selection.md).
  The evidence behind which model tier suits which kind of agent work.
- **Entity taxonomy** — [`han-plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md`](../../../han-plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md).
  The skill, agent, and hook decision heuristic, and the composition rules between them.
- **Repository conventions** — [`CLAUDE.md`](../../../CLAUDE.md). Carries the one-canonical-source-per-concept rule, the
  vendored-reference convention, and the rule that indexes stay complete rather than counted.
- **Scope boundary** — [artifacts/scope-boundary.md](artifacts/scope-boundary.md). The recorded boundary this sweep
  descends from, including the exclusion that consolidation is recorded and never acted on.

## W-1 — Write the conformance checklist the sweep runs against

**Summary.** The request asks for a review of every skill and agent against the current guidance. That guidance is spread
across more than thirty files. Twenty separate review passes will each read it differently unless the standard is written
down once, first. This work item turns the guidance into two checklists the rest of the sweep runs against.

**Work to be done.**

- Read every guidance file once and pull out each rule it states.
  - The guidance lives in two folders plus four top-level files, listed in the shared reference artifacts above.
- Write one checklist for skills and one for agents, with each item phrased as a yes or no question an implementer can
  answer by looking at a single file.
  - A question a reviewer has to interpret produces a different answer each time it is asked, which is the failure this
    item exists to prevent.
- Record the source file and section beside each checklist item.
  - This lets a later reviewer check the checklist against the guidance rather than re-derive it from scratch.
- Put both checklists in the sweep's own artifacts folder so every later work item can cite them.

**Note on why this comes first.** This is the only work item that pays the full guidance-reading cost. Every later item
reads these checklists plus the one or two guidance files its own dimension names.

**Justification.** A necessity of the asked-for work: the request names "the updated skill and agent building guidance"
as the standard for the review, and a review of 64 entities cannot apply one standard without writing it down first.

**References.**

- **Skill-building guidance** — the 26 files named in the shared reference artifacts above.
- **Agent-building guidance** — the 6 files named in the shared reference artifacts above.
- **Per-model authoring guidance**, **Specialization and model selection**, **Entity taxonomy**, and
  [`iterative-plugin-development.md`](../../../han-plugin-builder/skills/guidance/references/iterative-plugin-development.md) —
  the four top-level guidance files.

**Acceptance criteria.**

- [ ] A skill checklist and an agent checklist exist in the sweep's artifacts folder.
- [ ] Every rule stated in the 32 skill and agent guidance files appears as a checklist item.
- [ ] Each checklist item cites the guidance file and section it came from.
- [ ] Each checklist item is answerable by reading one skill file or one agent file.

**Depends on.** `None.`

## W-2 — Decide the agent self-containment policy and prove it on one agent

**Summary.** The agent guidance says an agent definition must be entirely self-contained, with nothing linked out to
another file. Eleven agents link out to shared rule files. Correcting this means choosing between two standards this
repository wrote for itself, because inlining a shared rule into eleven agents makes eleven copies of it. This work item
settles which standard governs and shows the result on the smallest affected agent.

**Work to be done.**

- Weigh the two standards against each other and pick one, then write down the ruling and the reasoning behind it.
  - The agent guidance requires self-containment. The repository convention requires one canonical source per concept.
    They point opposite ways here.
  - One fact bears on the choice: a relative link from an agent file does not resolve at run time, so the current links
    already work as citations rather than as instructions the model can follow.
- Put the ruling where the rest of the sweep can cite it, in the sweep's artifacts folder.
- Apply the ruling to a single agent so the resulting shape is visible before it is repeated ten more times.
  - Use the gap-analyzer agent. It carries one reference site, which makes it the cheapest place to see the shape.

**Note on why this needs a person.** Both standards were authored by this repository, the choice binds eleven files and
every agent written afterward, and the two wrong answers are expensive in different ways. One produces eleven copies of a
rule that will drift apart. The other leaves eleven agents told to apply a rule they cannot load.

**Justification.** Descends from the primary goal in the recorded scope: "find any aspect of any skill or agent
definition that contains info, instructions, etc, that conflict with the updated guidance and correct it."

**References.**

- **Agent-building guidance** — [`agent-external-files.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-external-files.md),
  which states agent files must be self-contained with all content inlined.
- **Repository conventions** — [`CLAUDE.md`](../../../CLAUDE.md), for the one-canonical-source-per-concept rule that
  points the other way.
- **The shared rules at issue** — [`han-core/references/yagni-rule.md`](../../../han-core/references/yagni-rule.md) and
  [`han-core/references/evidence-rule.md`](../../../han-core/references/evidence-rule.md).
- **The agent to change** — [`han-core/agents/gap-analyzer.md`](../../../han-core/agents/gap-analyzer.md).

**Acceptance criteria.**

- [ ] A written ruling exists naming which standard governs and why.
- [ ] The gap-analyzer agent conforms to the ruling.
- [ ] No link to a path outside itself remains in the gap-analyzer agent file.
- [ ] The gap-analyzer agent still states the evidence-rule content it acts on.

**Depends on.** `W-1.`

## W-3 — Apply the self-containment ruling to the remaining ten agents

**Summary.** Ten more agents carry the same links out to shared rule files that the previous work item settled on one
agent. This work item brings them all to the same shape. Some carry a single link and some carry four.

**Work to be done.**

- Work each of the ten remaining agents to the shape the ruling established.
  - The affected files all sit under `han-core/agents/`: project-manager, junior-developer, on-call-engineer,
    test-engineer, data-engineer, devops-engineer, software-architect, system-architect, edge-case-explorer, and
    evidence-based-investigator.
  - The data-engineer and devops-engineer agents each carry four reference sites; the rest carry one to three.
- Where the ruling calls for inlining, bring across only the content the agent acts on rather than the whole rule
  document.
  - Several of these agents already restate the rule's substance in the sentence next to the link, so copying the full
    rule would duplicate what is already there.

**Justification.** Descends from the primary goal in the recorded scope, applying the same conflict correction the
previous work item settled to the rest of the affected set.

**References.**

- **The ruling** — the self-containment policy decided in `W-2`, stored in the sweep's artifacts folder.
- **Agent-building guidance** — [`agent-external-files.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-external-files.md).
- **Affected agents** — the ten files named in the work list above, under
  [`han-core/agents/`](../../../han-core/agents/).

**Acceptance criteria.**

- [ ] No file under any plugin's `agents/` folder contains a link to a path outside itself.
- [ ] Each agent that previously cited a shared rule still states the rule content it acts on.
- [ ] All 24 agents still exist.

**Depends on.** `W-2.`

## W-4 — Trim the nine over-length agent descriptions

**Summary.** The agent guidance sets 1024 characters as the target for an agent description. Nine agent descriptions are
over it, and four of those are half again as long. A description that long is carrying content that belongs in the
agent's body. This work item cuts each one down and moves what it cuts into the body rather than deleting it.

**Work to be done.**

- Measure each of the nine over-length descriptions and cut it down the priority ladder the guidance sets out.
  - The nine, with their current character counts: project-manager 1986, junior-developer 1963, system-architect 1728,
    on-call-engineer 1591, data-engineer 1500, software-architect 1397, information-architect 1285, devops-engineer
    1194, gap-analyzer 1030.
  - The guidance's ladder cuts domain vocabulary and anti-pattern checklists first, then restated process prose, then
    boundary clauses.
- Move the cut content into the agent's own body sections rather than deleting it.
  - Domain terms belong under the agent's `## Domain Vocabulary` heading, and named anti-patterns under
    `## Anti-Patterns`.
- Before deleting any domain term, check whether it appears in any other agent description.
  - A term that appears in exactly one description may be the only thing routing a real request to that agent, so
    deleting it silently removes a route.
- When you delete one side of a "does not do X, use Y instead" pair, check the named sibling's reverse clause.
  - Repair the pair rather than leaving a one-way gap where one agent points at another that no longer points back.

**Note on the tenth agent.** The readability-editor description sits at 1017 characters, just under the target. It is not
in this work item's set, but it has no headroom, so leave it alone rather than adding to it.

**Justification.** Descends from the primary goal in the recorded scope, correcting a measured conflict between nine
agent definitions and the description-length rule in the current agent-building guidance.

**References.**

- **Agent-building guidance** — [`agent-description-length.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-description-length.md),
  which carries the measuring method and the priority cutting ladder, and
  [`agent-domain-focus.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md),
  which says what the body sections must hold.
- **Affected agents** — the nine files named in the work list above, under
  [`han-core/agents/`](../../../han-core/agents/).

**Acceptance criteria.**

- [ ] Every agent description measures under 1024 characters.
- [ ] No domain term that appeared in exactly one agent description was deleted.
- [ ] Every boundary clause naming another agent has a matching reverse clause on that agent.
- [ ] Content cut from a description appears in that agent's body.

**Depends on.** `W-1.`

## W-5 — Audit agent frontmatter fields and model tiers

**Summary.** Every agent declares which model tier it runs on. None of those choices has been checked against the
guidance that says which tier suits which kind of work. This work item checks all 24 and records the reasoning, so the
assignment is auditable instead of assumed.

**Work to be done.**

- Check each agent's declared model tier against the guidance's decision criteria and archetype table.
  - Ten agents currently run on the largest tier, eleven on the middle tier, and three on the smallest.
  - Record which archetype each agent matches, so a later reader can check the choice rather than trust it.
- Confirm each agent's tool allowlist matches what its body actually does.
  - An agent listing a tool it never uses is granting access for nothing.
  - The default is that an agent does not get the Agent tool, because dispatch normally flows from skills to agents.
- Confirm no agent sets a frontmatter field that plugin agents silently drop.
  - The guidance names three such fields. A field that is silently dropped reads as configured behavior that never
    happens.

**Justification.** Descends from the primary goal in the recorded scope: model tier and frontmatter fields are aspects of
an agent definition that the current guidance governs, and no agent has been checked against it.

**References.**

- **Agent-building guidance** — [`agent-model-selection.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md)
  for the tier criteria and archetype evidence, and
  [`agent-external-files.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-external-files.md)
  for the frontmatter field table and the silently-dropped fields.
- **Specialization and model selection** — the evidence behind which tier suits which kind of agent work.
- **All 24 agents** — under [`han-core/agents/`](../../../han-core/agents/),
  [`han-communication/agents/`](../../../han-communication/agents/), and
  [`han-research/agents/`](../../../han-research/agents/).

**Acceptance criteria.**

- [ ] Each of the 24 agents has its model tier justified against a named archetype, or has its tier changed.
- [ ] No agent lists a tool its body never uses.
- [ ] No agent sets a frontmatter field that plugin agents drop.

**Depends on.** `W-1.`

## W-6 — Bring agent role, vocabulary, and anti-pattern sections into conformance

**Summary.** The agent guidance puts a hard ceiling on the opening role paragraph and requires two named body sections
with a stated size range. No agent has been measured against either. This work item measures all of them and fixes what
falls outside. It runs after the description trim, because that trim moves content into the same two sections.

**Work to be done.**

- Measure each agent's opening role paragraph and cut it under the ceiling the guidance sets.
  - Strip flattery and superlatives while cutting. The guidance says these route the model toward motivational material
    instead of technical material.
- Confirm each agent carries both required body sections, with entry counts inside the guidance's stated ranges.
  - These are the same two sections the description trim moves content into, so check them after that content lands.
- Where an agent both produces something and evaluates it, write the case down and leave the agent alone.
  - Splitting one agent into two changes the entity count, which the recorded boundary rules out. The register work item
    picks these up.

**Justification.** Descends from the primary goal in the recorded scope, correcting agent definitions against the domain
focus rules in the current agent-building guidance.

**References.**

- **Agent-building guidance** — [`agent-domain-focus.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md),
  which sets the role-paragraph ceiling and the two required body sections with their size ranges.
- **Scope boundary** — [artifacts/scope-boundary.md](artifacts/scope-boundary.md), whose direction-of-travel answer says
  nothing is being retired and whose stated exclusion rules out acting on consolidation.
- **All 24 agents** — the three agent folders named in `W-5`.

**Acceptance criteria.**

- [ ] Every agent's opening role paragraph is under the guidance's ceiling.
- [ ] No opening role paragraph contains flattery or a superlative.
- [ ] Every agent carries both required body sections with entry counts in the stated ranges.
- [ ] Every agent that both produces and evaluates is written down rather than restructured.

**Depends on.** `W-1, W-4.`

## W-7 — Remove self-verification instructions across skills and agents

**Summary.** The most recently updated guidance says to cut three things from instructions: a step that re-checks the
model's own output, a dispatch whose purpose is verifying the dispatching skill's own work, and any rule telling the
model not to reason. Some skills carry all three. This work item sweeps every skill and agent for them.

**Work to be done.**

- Sweep all 40 skills and all 24 agents for a step that re-checks output the same run produced.
  - Two known starting points: the coding-standard skill and the plan-a-phased-build skill each carry one.
- Sweep for any dispatch whose stated purpose is verifying the dispatching skill's own work.
- Sweep for any rule that forbids the model from reasoning or thinking.
- Keep genuine review by a second perspective.
  - A specialist reviewer evaluating a draft is a different mechanism from a self-check, and the guidance keeps it. Cut
    only the passes where the same perspective checks itself.

**Justification.** Descends from the primary goal in the recorded scope, against the guidance file updated most recently
in this repository, which names these three patterns as content to leave out.

**References.**

- **Per-model authoring guidance** — its section on instructions to leave out, which names verification steps, re-check
  prompts, and rules forbidding reasoning.
- **Agent-building guidance** — [`multi-agent-economics.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md),
  which rules out dispatching an agent to verify the dispatching skill's own work.
- **Known sites** — [`han-coding/skills/coding-standard/SKILL.md`](../../../han-coding/skills/coding-standard/SKILL.md)
  and [`han-planning/skills/plan-a-phased-build/SKILL.md`](../../../han-planning/skills/plan-a-phased-build/SKILL.md).

**Acceptance criteria.**

- [ ] No skill or agent instructs a re-check of output the same run produced.
- [ ] No dispatch exists whose stated purpose is verifying the dispatching skill's own work.
- [ ] No skill or agent carries a rule forbidding the model from reasoning.
- [ ] Every review dispatch left in place brings a different perspective rather than the same one twice.

**Depends on.** `W-1.`

## W-8 — Calibrate deliverable length, narration, and scope in skills that write files

**Summary.** A skill that writes a document should say how long it wants that document to be, how much progress it wants
narrated, and how far its scope reaches. The guidance says these need stating rather than left to default. Many skills
here are silent on all three. This work item adds the missing instruction, and adds nothing where a shared rule already
covers it.

**Work to be done.**

- Identify which skills write a deliverable to disk, and check each for a stated length, narration, and scope behavior.
- Add the missing instruction where a skill is silent.
  - Write it as the shape you want rather than as a list of things to avoid. The guidance says the positive form works
    better on current models.
- Where a skill already gets the behavior from a shared rule it invokes, cite that rule and add nothing.
  - The readability rule and the explanation rule already carry length and framing guidance, and stacking a second
    instruction on the same behavior weakens both.

**Justification.** Descends from the primary goal in the recorded scope, applying the calibration section of the current
per-model authoring guidance to the skills that produce written deliverables.

**References.**

- **Per-model authoring guidance** — its section on calibrating length, narration, and scope.
- **Shared rules that may already cover it** —
  [`han-communication/references/readability-rule.md`](../../../han-communication/references/readability-rule.md) and
  [`han-communication/references/explanation-rule.md`](../../../han-communication/references/explanation-rule.md).

**Acceptance criteria.**

- [ ] Every skill that writes a file either states its deliverable length and scope, or cites the shared rule that
      already does.
- [ ] No skill carries two instructions covering the same one of these behaviors.
- [ ] Every instruction added states the shape wanted rather than a list of things to avoid.

**Depends on.** `W-1, W-7.`

## W-9 — Check every skill's dispatch policy against multi-agent economics

**Summary.** A skill that sends work to agents should say how many it sends and on what basis. Left unstated, the model
defaults to sending more than the work needs. This work item checks every dispatching skill for a stated policy, a
bounded count, and correctly namespaced targets.

**Work to be done.**

- For each skill that dispatches agents, confirm it states how many it dispatches and on what basis.
  - A count left to the model is the default this guidance exists to override.
- Confirm any panel of agents respects the cap the guidance sets, and that independent agents go out together rather
  than one after another.
  - The guidance also caps how long a sequential chain of agents may run.
- Confirm every dispatch target carries its plugin namespace.
  - Dispatching skills include those in han-coding and han-planning, among others.

**Justification.** Descends from the primary goal in the recorded scope, applying the multi-agent economics and dispatch
namespacing rules in the current guidance to every skill that dispatches.

**References.**

- **Agent-building guidance** — [`multi-agent-economics.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md),
  which requires a stated delegation policy and caps panel size.
- **Skill-building guidance** — [`agent-dispatch-namespacing.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/agent-dispatch-namespacing.md),
  which requires the plugin namespace on every dispatch target.
- **Per-model authoring guidance** — its note on subagent eagerness.

**Acceptance criteria.**

- [ ] Every dispatching skill states a delegation policy with a bounded count.
- [ ] No sequential chain of agents exceeds the cap the guidance sets.
- [ ] Every dispatch target carries its plugin namespace.

**Depends on.** `W-1.`

## W-10 — Check every skill's frontmatter, description, and context probes

**Summary.** Skill frontmatter, description shape, and the commands a skill runs to gather context are each governed by
their own guidance file. The probe rule changed recently to rule out reads outside the project. This work item checks all
40 skills against the current versions of those rules.

**Work to be done.**

- Check each skill's frontmatter field set against the field table in the guidance.
- Check each description against the required components and the rule that boundary clauses point both ways.
  - No skill description currently exceeds the length limit, so length here is a confirmation rather than a repair. The
    longest sits at 979 characters.
- Check each skill's tool allowlist against what its body actually calls.
- Confirm every context-gathering command is guarded so a missing tool or file cannot abort the skill.
  - There are roughly 173 such command sites across the 40 skills.
- Confirm no context-gathering command reads outside the project.
  - Reading a personal configuration file is the one exception, and the config rule already prescribes how: a Read step
    inside the skill body rather than a command that runs at load time.

**Justification.** Descends from the primary goal in the recorded scope, checking every skill definition against the
frontmatter, description, tool-permission, and context-injection rules in the current skill-building guidance.

**References.**

- **Skill-building guidance** — [`skill-frontmatter-fields.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-frontmatter-fields.md),
  [`skill-description-frontmatter.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-frontmatter.md),
  [`skill-description-length.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-length.md),
  [`context-injection-commands.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md),
  [`allowed-tools-bash-permissions.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-bash-permissions.md),
  [`allowed-tools-AskUserQuestion.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md),
  and [`naming-conventions.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/naming-conventions.md).
- **Config rule** — [`han-core/references/config-rule.md`](../../../han-core/references/config-rule.md), for the
  prescribed way a skill reads a personal configuration file.
- **All 40 skills** — the twelve plugin `skills/` folders.

**Acceptance criteria.**

- [ ] Every skill's tool allowlist matches what its body calls.
- [ ] Every skill description carries all required components, with boundary clauses that point both ways.
- [ ] Every context-gathering command is guarded against a missing tool or file.
- [ ] No context-gathering command reads outside the project.

**Depends on.** `W-1.`

## W-11 — Trim the two largest han-planning skills

**Summary.** The plan-a-feature and plan-implementation skills are the two longest skill bodies in the repository. Every
line of a skill body loads into context whenever the skill runs. This work item makes both shorter without changing what
they produce.

**Work to be done.**

- Reduce each skill body while keeping every artifact it produces and every section of those artifacts.
  - The two bodies run 746 and 801 lines.
- Move detail out of the always-loaded body into a reference file the skill links from the point where it needs it.
  - This is the first of the two levers the guidance names for reducing a skill body.
- Delete content that restates a shared rule the skill already points at.
  - This is the second lever. Both skills invoke shared rules and then restate parts of them inline.
- Leave the three planning rule files alone.
  - They are shared by five skills, so a later work item handles them once rather than twice from here.

**Justification.** Descends from the secondary goal as the user scoped it in the confirmation turn: "item 3: trim within
each entity."

**References.**

- **Skill-building guidance** — [`progressive-disclosure.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md),
  [`context-hygiene.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/context-hygiene.md),
  [`writing-effective-instructions.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/writing-effective-instructions.md),
  and [`skill-reference-files.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-reference-files.md).
- **The two skills** — [`han-planning/skills/plan-a-feature/`](../../../han-planning/skills/plan-a-feature/) and
  [`han-planning/skills/plan-implementation/`](../../../han-planning/skills/plan-implementation/), each with its own
  `references/` and `scripts/` folders.
- **Shared rules these two invoke** —
  [`han-planning/references/planning-boundary-rule.md`](../../../han-planning/references/planning-boundary-rule.md),
  [`scope-justification-rule.md`](../../../han-planning/references/scope-justification-rule.md), and
  [`operator-escalation-rule.md`](../../../han-planning/references/operator-escalation-rule.md).

**Acceptance criteria.**

- [ ] Both skill bodies are shorter than they were.
- [ ] Each skill still produces the same artifacts with the same sections.
- [ ] Content moved into a reference file is linked from the point in the body where the skill needs it.
- [ ] The three han-planning rule files are unchanged by this work item.

**Depends on.** `W-1, W-7, W-8, W-9, W-10.`

## W-12 — Trim the four largest han-coding skills

**Summary.** The code-review, coding-standard, code-overview, and architectural-analysis skills are the four largest in
han-coding. Each carries reference files and some carry scripts. This work item trims each body and its companion files
together, so a body is not shortened by pushing duplication into a reference file.

**Work to be done.**

- Trim each of the four skill bodies and the reference files beside them.
  - The four run 770, 466, 339, and 309 lines.
- Check whether a skill body restates content that its own reference file already holds.
  - The coding-standard skill carries a template and a conversion mapping in reference files, which is where this
    pattern is most likely.
- Where a skill runs a script, confirm the body describes the invocation rather than re-explaining what the script does.

**Justification.** Descends from the secondary goal as the user scoped it in the confirmation turn: "item 3: trim within
each entity."

**References.**

- **Skill-building guidance** — [`progressive-disclosure.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md),
  [`skill-reference-files.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-reference-files.md),
  and [`script-execution-instructions.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md).
- **The four skills** — under [`han-coding/skills/`](../../../han-coding/skills/), with their `references/` and
  `scripts/` folders.

**Acceptance criteria.**

- [ ] All four skill bodies are shorter than they were.
- [ ] No skill body restates content its own reference file carries.
- [ ] The Bats tests beside these skills' scripts still pass.

**Depends on.** `W-1, W-7, W-8, W-9, W-10.`

## W-13 — Trim the rest of han-planning and its owned rule files

**Summary.** Three han-planning skills and the plugin's own rule files are left after the two largest were trimmed. The
rule files count as associated resources in the request's own words. This work item trims them, and leaves the vendored
copies of shared rules untouched.

**Work to be done.**

- Trim the three remaining skill bodies.
  - They run 543, 436, and 335 lines.
- Trim the three rule files han-planning owns.
  - Keep the line each one opens with saying it is owned here rather than vendored from elsewhere. A later re-sync sweep
    reads that line to know not to overwrite the file.
- Leave the three vendored rule files in this plugin alone.
  - The repository requires vendored copies to stay byte-identical across plugins, so editing one copy here breaks the
    convention rather than conforming to it.

**Justification.** Descends from the secondary goal as the user scoped it, covering the remaining han-planning skills and
the "associated resources" the request names alongside each definition.

**References.**

- **Skill-building guidance** — [`progressive-disclosure.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md)
  and [`skill-composition.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-composition.md).
- **The three skills** — [`iterative-plan-review/`](../../../han-planning/skills/iterative-plan-review/),
  [`plan-a-phased-build/`](../../../han-planning/skills/plan-a-phased-build/), and
  [`plan-work-items/`](../../../han-planning/skills/plan-work-items/).
- **The plugin's rule files** — [`han-planning/references/`](../../../han-planning/references/), holding three owned
  files beside three vendored copies.
- **Repository conventions** — [`CLAUDE.md`](../../../CLAUDE.md), for the rule that vendored copies stay byte-identical.

**Acceptance criteria.**

- [ ] The three skill bodies and the three owned rule files are shorter than they were.
- [ ] Each owned rule file still opens by saying it is owned here.
- [ ] The three vendored rule files in this plugin are byte-identical to their canonical originals.
- [ ] The repository's cross-reference checks still pass.

**Depends on.** `W-11.`

## W-14 — Trim the rest of han-coding

**Summary.** Five han-coding skills are left after the four largest were trimmed. Two of them ship scripts with tests.
This work item trims the five bodies and their reference files.

**Work to be done.**

- Trim the five remaining skill bodies and their reference files.
  - These are the tdd, refactor, automated-test-planning, manual-test-planning, and investigate skills.
- Look at the manual-test-planning description while the file is open.
  - At 979 characters it is the longest skill description in the repository. It is under the limit and needs no repair,
    but it has almost no headroom.
- Where a skill ships a script, cut any part of the body that duplicates the script's own logic.
  - Keep the body's description of what the script is for and when it runs.

**Justification.** Descends from the secondary goal as the user scoped it, covering the remaining han-coding skills and
their companion resources.

**References.**

- **Skill-building guidance** — [`progressive-disclosure.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md)
  and [`hardening-fuzzy-vs-deterministic.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/hardening-fuzzy-vs-deterministic.md).
- **The five skills** — under [`han-coding/skills/`](../../../han-coding/skills/), plus
  [`han-coding/references/`](../../../han-coding/references/).

**Acceptance criteria.**

- [ ] All five skill bodies are shorter than they were.
- [ ] No skill body duplicates logic its own script owns.
- [ ] The Bats tests beside these skills' scripts still pass.

**Depends on.** `W-12.`

## W-15 — Trim the han-core, han-communication, and han-documentation skills

**Summary.** Seven small skills sit across these three plugins, and they share a foundation. The han-communication plugin
owns the writing rules the other two apply. This work item trims all seven together so a rule and the skills that apply
it are read side by side.

**Work to be done.**

- Trim the seven skill bodies.
  - One in han-core, three in han-communication, three in han-documentation.
- Trim the four canonical rule files han-communication owns.
  - These have no vendored copies anywhere, so they can be edited directly.
- Check whether either inline guidance skill restates the rule file it exists to surface.
  - Two han-communication skills exist only to read a rule file into the caller's context, which makes restating it pure
    duplication.
- Leave han-documentation's vendored rule copies alone.

**Justification.** Descends from the secondary goal as the user scoped it, covering seven skill definitions and the
associated resources beside them.

**References.**

- **Skill-building guidance** — [`progressive-disclosure.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md)
  and [`dynamic-project-discovery.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/dynamic-project-discovery.md).
- **The seven skills** — [`han-core/skills/project-discovery/`](../../../han-core/skills/project-discovery/),
  [`han-communication/skills/`](../../../han-communication/skills/), and
  [`han-documentation/skills/`](../../../han-documentation/skills/).
- **Canonical rule files** — [`han-communication/references/`](../../../han-communication/references/), holding the
  readability rule, the writing-voice profile, and the explanation rule.

**Acceptance criteria.**

- [ ] All seven skill bodies are shorter than they were.
- [ ] Every rule the han-communication reference files stated before is still stated in them.
- [ ] Neither inline guidance skill restates the rule file it surfaces.
- [ ] The vendored rule copies in han-documentation are unchanged.

**Depends on.** `W-1, W-7, W-8, W-9, W-10.`

## W-16 — Trim han-research, han-github, and han-reporting

**Summary.** Eight skills sit across these three plugins, and han-github carries the heaviest load of scripts in the
repository. Skills that shell out to scripts tend to re-narrate what the script already does. Several of these also touch
git, which is not guaranteed to be present.

**Work to be done.**

- Trim the eight skill bodies and their companion resources.
  - Three in han-research, three in han-github with nine scripts between them, two in han-reporting.
- Check each script-running skill for prose that re-explains what the script does.
- Confirm each git-touching skill states what it does when git is unavailable.
  - The guidance treats git as optional rather than assumed, so a skill that fails outright is a conformance gap.

**Justification.** Descends from the secondary goal as the user scoped it, covering eight skill definitions and their
scripts and reference files.

**References.**

- **Skill-building guidance** — [`script-execution-instructions.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/script-execution-instructions.md),
  [`optional-git-repositories.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/optional-git-repositories.md),
  and [`graceful-degradation.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/graceful-degradation.md).
- **The eight skills** — [`han-research/skills/`](../../../han-research/skills/),
  [`han-github/skills/`](../../../han-github/skills/), and [`han-reporting/skills/`](../../../han-reporting/skills/).

**Acceptance criteria.**

- [ ] All eight skill bodies are shorter than they were.
- [ ] No skill body re-explains what one of its scripts does.
- [ ] Every git-touching skill states its behavior when git is unavailable.
- [ ] The Bats tests beside these skills' scripts still pass.

**Depends on.** `W-1, W-7, W-8, W-9, W-10.`

## W-17 — Trim han-atlassian, han-linear, and han-feedback

**Summary.** These three opt-in plugins hold eight skills that share a shape. Each depends on an external service, and
most wrap a skill from another plugin. A wrapper that restates the wrapped skill's process is duplication that goes stale
when the wrapped skill changes.

**Work to be done.**

- Trim the eight skill bodies and each plugin's reference files.
  - Six in han-atlassian, one in han-linear, one in han-feedback.
- Check each wrapper skill for a restatement of the process belonging to the skill it wraps.
  - Four of the six han-atlassian skills wrap a skill in another plugin.
- Confirm each skill states what happens when its external service is unavailable.

**Justification.** Descends from the secondary goal as the user scoped it, covering the eight skill definitions in the
opt-in integration plugins.

**References.**

- **Skill-building guidance** — [`graceful-degradation.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/graceful-degradation.md),
  [`skill-composition.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-composition.md),
  and [`security-restrictions.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/security-restrictions.md).
- **The eight skills** — [`han-atlassian/skills/`](../../../han-atlassian/skills/),
  [`han-linear/skills/`](../../../han-linear/skills/), and [`han-feedback/skills/`](../../../han-feedback/skills/).

**Acceptance criteria.**

- [ ] All eight skill bodies are shorter than they were.
- [ ] No wrapper skill restates the process of the skill it wraps.
- [ ] Every skill states its behavior when its external service is unavailable.

**Depends on.** `W-1, W-7, W-8, W-9, W-10.`

## W-18 — Trim the three han-plugin-builder skills

**Summary.** These three skills serve the guidance the rest of this sweep runs against. Their bodies are routing maps and
interview scripts over a large set of reference files. This work item trims the three bodies only, and leaves the
reference files for later.

**Work to be done.**

- Trim the three skill bodies.
  - The guidance skill plus the two interview-driven builder skills.
- Check whether the guidance skill's routing map restates what the files it routes to already say.
- Check both builder skills for the same restating.
  - Each walks a design tree that overlaps the guidance references it points at.
- Leave the 42 reference files under the guidance skill alone.
  - Trimming the standard while the sweep is still measuring against it would move the target mid-run. A later work item
    handles them.

**Justification.** Descends from the secondary goal as the user scoped it, covering the three han-plugin-builder skill
definitions.

**References.**

- **Skill-building guidance** — [`progressive-disclosure.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md)
  and [`skill-decomposition.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-decomposition.md).
- **The three skills** — [`han-plugin-builder/skills/guidance/`](../../../han-plugin-builder/skills/guidance/) with its
  script and assets, [`skill-builder/`](../../../han-plugin-builder/skills/skill-builder/), and
  [`agent-builder/`](../../../han-plugin-builder/skills/agent-builder/).

**Acceptance criteria.**

- [ ] All three skill bodies are shorter than they were.
- [ ] The guidance routing map still names a destination for every reference subdirectory.
- [ ] The guidance skill's vendoring script still installs all three skills into a target repository.
- [ ] The 42 guidance reference files are unchanged by this work item.

**Depends on.** `W-1, W-7, W-8, W-9, W-10.`

## W-19 — Record the consolidation-candidate register

**Summary.** The user asked for overlapping skills or agents to be written down and left alone. Trimming reveals overlap
that longer bodies hide, so this runs after the trims. Nothing merges and nothing is deleted.

**Work to be done.**

- Collect every consolidation candidate the earlier work items noticed into one register.
- For each candidate, name the entities involved, the overlap that makes them candidates, and the reason someone might
  merge them.
- Take no action on any candidate.
  - The recorded boundary excludes it, and the direction-of-travel answer says nothing is being retired.
- Include the agents that both produce and evaluate, which the agent conformance work item recorded rather than split.

**Justification.** Descends directly from the user's stated exclusion in the recorded boundary: "if there are skills or
agents that can be consolidated, record them and the reasons but take no action on that."

**References.**

- **Scope boundary** — [artifacts/scope-boundary.md](artifacts/scope-boundary.md), whose Stated Exclusions section
  carries the instruction this register answers.
- **Agent-building guidance** — [`agent-domain-focus.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md),
  for the one-role rule that produces some of these candidates.

**Acceptance criteria.**

- [ ] A register exists naming every candidate with the entities involved and the reason.
- [ ] The repository still holds 40 skills and 24 agents.
- [ ] No skill or agent was merged or deleted.

**Depends on.** `W-3, W-6, W-11, W-12, W-13, W-14, W-15, W-16, W-17, W-18.`

## W-20 — Sync the long-form docs and index entries for every changed description

**Summary.** Each skill and agent has a long-form doc, a one-line mention in its plugin README, and an entry in a
repository index. Those surfaces reuse the definition's own summary. Changing nine agent descriptions leaves them
describing something the definition no longer says.

**Work to be done.**

- Walk every description and behavior this sweep changed, and update the matching long-form doc.
- Update the plugin README mention and the index entry for each changed entity.
- Verify both indexes list every entity by walking the directories rather than comparing against a count.
  - The repository convention is that indexes stay complete rather than counted, so a stated total is itself a defect to
    fix.
- Add no new documentation.
  - This is a sync of what the sweep moved, not a documentation pass.

**Justification.** A necessity of the asked-for work: correcting nine agent descriptions leaves three other surfaces
stating something the definition no longer says, and the repository requires those surfaces to reuse the definition's own
summary.

**References.**

- **Repository conventions** — [`CLAUDE.md`](../../../CLAUDE.md), for the rule that each README mention and index entry
  reuses the long-form doc's summary line, and that indexes stay complete rather than counted.
- **Skill-building guidance** — [`documentation-maintenance.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/documentation-maintenance.md).
- **Coverage rule** — [`docs/templates/coverage-rule.md`](../../templates/coverage-rule.md), which requires a long-form doc for
  every skill and every agent.
- **The index files** — [`docs/skills/README.md`](../../skills/README.md), [`docs/agents/README.md`](../../agents/README.md),
  and [`docs/choosing-a-han-plugin.md`](../../choosing-a-han-plugin.md).

**Acceptance criteria.**

- [ ] Every changed description matches its long-form doc summary, its plugin README mention, and its index entry.
- [ ] Both indexes list every skill and every agent found on disk.
- [ ] No index states a running total of skills or agents.
- [ ] No new documentation file was added.

**Depends on.** `W-4, W-10, W-11, W-12, W-13, W-14, W-15, W-16, W-17, W-18.`

## W-21 — Run the checklist against every skill and agent

**Summary.** Twenty work items each touch part of the roster. None of them confirms the whole set at once. This work item
runs the checklist against all 64 entities and records a result for each, so the sweep has a single point where full
coverage is established.

**Work to be done.**

- Run both checklists against all 40 skills and all 24 agents, and record the result for each entity.
- Where an item still fails, record the failure and the reason it was left rather than fixing it quietly.
- Run the repository's lint and test commands.

**Note on why this is not a self-check.** This is a fresh read of every file against a written standard, not a re-reading
of any one earlier item's output. The guidance rules out a pass that checks the same work with the same perspective that
produced it, and this is a different mechanism.

**Justification.** A necessity of the asked-for work: the request is a review of every skill and agent, and twenty items
each covering a subset leaves no point where the full roster has been confirmed.

**References.**

- **The checklists** — produced in `W-1` and stored in the sweep's artifacts folder.
- **Agent-building guidance** — [`multi-agent-economics.md`](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md),
  for the rule this work item is checked against.
- **All 64 entities** — the twelve plugin `skills/` folders and the three plugin `agents/` folders.

**Acceptance criteria.**

- [ ] Every one of the 64 entities has a recorded checklist result.
- [ ] Every remaining failure has a stated reason for being left.
- [ ] The repository's lint command passes.
- [ ] The repository's test command passes.

**Depends on.** `W-3, W-5, W-6, W-7, W-8, W-9, W-10, W-11, W-12, W-13, W-14, W-15, W-16, W-17, W-18, W-20.`

## W-22 — Trim the guidance reference files themselves

**Summary.** The guidance files are the largest body of associated resources in the repository. Many of them restate
rules that a cross-referenced sibling already owns. This runs last, so the standard the sweep measures against does not
move while the sweep is running.

**Work to be done.**

- Trim the guidance reference files for content that repeats what a sibling file already states.
  - The 32 skill and agent guidance files run 6302 lines between them. The four longest are 500, 466, 410, and 369
    lines.
- Change no rule, only how much text states it.
  - If a trim would change what a rule requires, stop and leave that passage alone. Changing the standard is not what
    the request asks for.
- Confirm the checklists from the first work item still map onto the trimmed files.

**Justification.** Descends from the secondary goal as the user scoped it: these files are the associated resources of
the han-plugin-builder guidance skill, and the request names associated resources alongside each definition.

**References.**

- **Skill-building guidance** — [`skill-reference-files.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-reference-files.md)
  and [`progressive-disclosure.md`](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md).
- **The files to trim** — [`han-plugin-builder/skills/guidance/references/`](../../../han-plugin-builder/skills/guidance/references/).
- **The checklists** — produced in `W-1`, which must still map onto the trimmed files.

**Acceptance criteria.**

- [ ] The guidance reference files are shorter than they were.
- [ ] Every rule the guidance stated before is still stated somewhere in it.
- [ ] Every checklist item from `W-1` still maps to a passage in the trimmed files.

**Depends on.** `W-21.`

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. There is no trigger that reopens an entry
here; the recorded boundary already settled it.

- **Merging or deleting any overlapping skill or agent.** The user excluded it in the recorded boundary: "record them
  and the reasons but take no action on that." The direction-of-travel answer also says nothing is being retired. `W-19`
  records the candidates instead.
- **Splitting any agent that both produces and evaluates its own output.** Creating a new agent changes the entity
  count, which the direction-of-travel answer rules out, and it is consolidation work run in reverse. `W-6` records
  these cases instead.
- **Replacing the per-plugin copies of the shared configuration, YAGNI, and evidence rules with one shared source.**
  These copies are deliberate: the repository requires them byte-identical across plugins. Removing them would break a
  standing decision rather than conform to guidance.
- **A test that fails the build when a description grows past the length limit.** The request asks for a review and edit
  pass, not new tooling, and no description has been observed regrowing after a correction.
- **Setting the optional agent frontmatter fields across the roster.** The guidance documents them as available rather
  than required. No agent has a stated need for one, and adding a setting no caller ever changes is the speculative
  configuration the repository's own YAGNI rule names.
- **Raising plugin versions and writing changelog entries for the sweep.** The user did not ask for a release. Versions
  get bumped when someone says to bump them.
- **Producing model-specific variants of the larger skills.** The per-model authoring guidance rules this out directly:
  a skill cannot reliably detect which model is running it, so shipped skills stay model-agnostic.
- **Rewriting the long-form documentation beyond the descriptions the sweep changed.** The request scopes to skill and
  agent definitions and their associated resources. `W-20` syncs only what the sweep moved.

## Status as of 2026-07-31

All 22 work items are complete. The verification pass in
[artifacts/conformance-verification.md](artifacts/conformance-verification.md) records all 64 entities passing every
mechanically checkable item on both checklists, with zero failures.

**What the sweep changed.** Skill bodies dropped by 1,125 net lines and no body exceeds the 500-line ceiling; the
largest is now 498. Eleven new reference files carry the content that moved out of the four largest skills. Every agent
is self-contained, every description is under 1024 characters, every role identity is under 50 tokens, and every
one-way boundary pair is repaired.

**What was recorded rather than acted on**, each with its reasoning:

- Six consolidation candidates, in [artifacts/consolidation-register.md](artifacts/consolidation-register.md). Skill and
  agent counts are unchanged at 40 and 24.
- Two model-tier mismatches, in [artifacts/agent-model-tier-audit.md](artifacts/agent-model-tier-audit.md). Tier governs
  behavior on every future run, so it is the user's call.
- Five agents carrying more than the 5-to-10 anti-pattern range, in
  [artifacts/agent-body-section-audit.md](artifacts/agent-body-section-audit.md). Cutting them would remove detection
  capability, which the secondary goal forbids.
