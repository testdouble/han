# Implementation Decision Log: Orwell's Six Rules Applied to han-communication

<!--
This file records every implementation decision committed while planning the Orwell six-rules edits.
Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md).
This file captures the question, rationale, evidence, and rejected alternatives for each decision.
Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).

Source artifact: docs/research/orwell-six-rules-of-writing.md. No feature-specification.md exists; the
research report's O2 and Recommendation served as the "what". No feature-technical-notes.md exists.
-->

## Trivial decisions

<!-- None. Every committed decision below rests on codebase evidence or a rejected alternative, so all are full. -->

## Full decisions

### D-1: Escape-clause placement and scoping

- **Question:** Where does Orwell's rule 6 ("break a rule rather than write something clumsy") belong in the standard, and how far does it reach?
- **Decision:** Add a new H2 section to `readability-rule.md` between "Fidelity wins" (ends line 95) and "The standardized self-check" (line 97): when following a rule would make the prose read worse, break the rule. Scope it to the drafting properties and rewrite moves only. It never licenses a blocklisted word and never licenses a fidelity loss, so it yields to both hard gates. Give the section a descriptive heading.
- **Rationale:** Orwell subordinates the five mechanical rules to clarity, and the standard lacks any general statement of that principle (research gaps section, rule 6). The mature plain-language guides all attach a named, scoped exception rather than an unqualified override, which is the pattern this follows. Scoping the clause to yield to both hard gates keeps it from swallowing the blocklist or the fidelity guard, the ambiguity JD raised as OQ-1.
- **Evidence:**
  - `docs/research/orwell-six-rules-of-writing.md` Recommendation and gaps section (rule 6 confirmed gap, V2); A1 (Orwell rule 6); A9, A10 (scoped-exception pattern in plainlanguage.gov and GOV.UK).
  - `han-communication/references/readability-rule.md:90-95` (Fidelity wins), `:97` (self-check start), `:106` (sentence-length escape "without reason"), `:111-113` (keep-it-small design principle).
  - R1 claim ledger C1 (placement), C8 and OQ-1 resolution (scope boundary against the hard gates).
- **Rejected alternatives:**
  - Add it as a seventh self-check criterion (research option O1), rejected because the self-check is kept small on purpose to avoid compliance decay (`readability-rule.md:111-113`), and break-the-rule judgment is not the yes/no criterion the self-check requires.
  - State it as an unqualified override, rejected because an unscoped clause can excuse a blocklisted word or a fidelity loss, which OQ-1 evidence rules out (self-check criterion 5 and "Fidelity wins" stay absolute).
- **Specialist owner:** `information-architect`
- **Revisit criterion:** A drafted or rewritten deliverable is observed using the escape clause to justify a blocklisted word or a dropped fact.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-4
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Definition of Done, Risks and Assumptions

### D-2: Stale-figures principle placement, dividing line, and carve-out

- **Question:** Where does the general principle against stale figures of speech live, and how does an editor tell a worn cliche from a signature analogy?
- **Decision:** Add a general principle against stale figures of speech and pretentious or archaic diction to the "Avoided words and phrases" section of `writing-voice.md` (lines 98-114), stated principle-first with examples second, beside the existing load-bearing-versus-decorative test (line 110). Point it explicitly at the signature-move carve-out (lines 30-33) so fresh, load-bearing physical-world analogies stay legal.
- **Rationale:** The AI-slop list bans specific worn phrases but no file states a general principle against reaching for a stale metaphor (research gaps section, rule 1, confirmed by V2). The voice profile encourages physical-world analogies as a signature move, so a bare "avoid stale figures" principle would over-flag them (V7). Reusing the line-110 load-bearing-versus-decorative test gives the editor a dividing line, and naming the carve-out at lines 30-33 keeps signature analogies safe.
- **Evidence:**
  - `docs/research/orwell-six-rules-of-writing.md` O2 edit 2, gaps section (rule 1), V7 (dividing line required).
  - `han-communication/references/writing-voice.md:98-114` ("Avoided words and phrases"), `:110` (load-bearing-vs-decorative test), `:30-33` (physical-world-analogy signature move).
  - R1 claim ledger C2 (placement, principle-first), C12 (must point at the carve-out or physical-world analogies get over-flagged).
- **Rejected alternatives:**
  - Land the principle in the "AI slop to avoid" section (lines 220-224), rejected because that section enumerates a specific modern corpus, not a general drafting principle, and C2 places the general principle beside the existing dividing-line test.
  - State a bare "avoid stale figures" principle with no dividing line, rejected because V7 shows it gives the editor no way to separate a signature analogy from a cliche, over-flagging the carve-out at lines 30-33.
- **Specialist owner:** `information-architect`
- **Revisit criterion:** Signature physical-world analogies are flagged as stale figures in a rewrite pass.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-4
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Risks and Assumptions

### D-3: Foreign and archaic diction lands only in the writing-voice blocklist

- **Question:** Where do foreign or Latinate stock phrases and archaic formal words get named, and does `readability-rule.md` need its own copy?
- **Decision:** Add foreign and Latinate stock phrases ("in lieu of," "per se") and archaic formal words ("aforementioned," "herein") to the same "Avoided words and phrases" section of `writing-voice.md`, as examples of the existing replace-first pattern. Do not add them to `readability-rule.md`.
- **Rationale:** The replace-versus-define framework already exists in the rule; the only gap is that the guidance never names this specific category (research V1 rescoped the rule 5 edit from "add a framework" to "name the missing categories"). `readability-rule.md:78-80` designates the writing-voice blocklist authoritative for the words it covers, so adding a word list to the rule would create a competing list (C3, OQ-5).
- **Evidence:**
  - `docs/research/orwell-six-rules-of-writing.md` O2 edit 3 as rescoped by V1; A19, A20 (current word-guidance state).
  - `han-communication/references/readability-rule.md:78-80` (blocklist is authoritative; the rule must not duplicate it).
  - R1 claim ledger C3 and OQ-5 resolution (the single canonical home is the writing-voice blocklist).
- **Rejected alternatives:**
  - Add the words to the "Common words" property in `readability-rule.md`, rejected because `readability-rule.md:78-80` makes the writing-voice blocklist authoritative, and a second list would compete with it (C3).
- **Specialist owner:** `information-architect`
- **Revisit criterion:** A second authoritative word list is proposed for the readability rule.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-4
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing

### D-4: Agent-edit shape keeps the rubric at six

- **Question:** How does the readability-editor agent absorb the new principles without growing its six-criterion rubric?
- **Decision:** In `readability-editor.md`, add the escape clause as a governing principle beside the fidelity principle (lines 29-33), not as a seventh criterion. Weave the stale-figures and foreign/archaic-diction scope into the existing criterion 5. The rubric stays at exactly six criteria and "They are the whole rubric" (line 57) stays literally true.
- **Rationale:** Edits to the reference files alone never reach the rewrite pass, because the agent carries its own hardcoded rubric and reads only the rule and the draft, never `writing-voice.md` (V5, C5). So the principles must be named inline in the agent. Keeping the rubric at six preserves the keep-it-small design and keeps the "six criteria" count true across the seven-plus surfaces that echo it (C6). Placing the escape clause beside the fidelity principle mirrors its home in the rule (D-1), and folding the diction scope into criterion 5 mirrors the blocklist reference already there (line 68).
- **Evidence:**
  - `docs/research/orwell-six-rules-of-writing.md` V5 (reference-file edits miss the rewrite pass; the agent must be touched), Recommendation.
  - `han-communication/agents/readability-editor.md:29-33` (fidelity governing principle), `:57` ("They are the whole rubric"), `:68` (criterion 5 blocklist reference), `:78` (agent reads only the rule and the draft).
  - R1 claim ledger C4 (shape), C5 (inline naming required), C6 (seven-plus count surfaces stay true only if the rubric stays six), OQ-2 resolution.
- **Rejected alternatives:**
  - Add a seventh rubric criterion, rejected because it breaks the keep-it-small design (research O1) and falsifies the "six criteria" count on the seven-plus surfaces that echo it (C6, F10).
  - Rely on reference-file inheritance only, rejected because V5 shows the agent's hardcoded rubric never reads the reference files, so a principle added only there is invisible to the rewrite pass (C5).
- **Specialist owner:** `information-architect`
- **Revisit criterion:** The agent is observed overriding a rubric criterion, or an operator reports confusion about the rubric count.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-5, D-6, D-7
- **Referenced in plan:** Implementation Approach, Work Units and Sequencing, Definition of Done

### D-5: Manual dry-run acceptance check

- **Question:** How is the behavior of the edited editor agent verified when the repo has no automated tests?
- **Decision:** Run the edited editor agent on a sample document that contains a stale metaphor, "in lieu of," an archaic word such as "aforementioned," and one load-bearing signature analogy that must survive unchanged. The edit passes when the first three are corrected and the signature analogy is preserved.
- **Rationale:** The research names the missing dry run as a residual risk, and the repo has no test runner, so a manual dry run is the only behavior-level verification available. The sample is built to exercise both the new flagging behavior (D-2, D-3) and the carve-out that must not fire (D-2's dividing line).
- **Evidence:**
  - `docs/research/orwell-six-rules-of-writing.md` Confidence Assessment (no dry run performed; named residual risk).
  - `docs/plans/orwell-six-rules/artifacts/.discovery-notes.md` (markdown-only suite, no test runner).
  - R1 claim ledger C10 (no acceptance check exists), OQ-3 resolution (manual dry run is in scope).
- **Rejected alternatives:**
  - Ship with no verification, rejected because the research flags the missing dry run as a residual risk and there is no automated coverage to catch a regression.
- **Specialist owner:** `test-engineer`
- **Revisit criterion:** Automated coverage for the readability standard is introduced, at which point the manual dry run can be encoded.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Work Units and Sequencing, Definition of Done, Testing Strategy

### D-6: Guidance-review prerequisite for the agent edit

- **Question:** Does the agent edit need a han-plugin-builder review, and if so, a full interview or a review pass?
- **Decision:** Run a han-plugin-builder guidance review over the edited `readability-editor.md`, as a review pass rather than a full agent-builder interview.
- **Rationale:** CLAUDE.md mandates han-plugin-builder guidance for agent definitions, and the four-edit plan did not name this prerequisite (C11). The guidance skill's stated purpose includes reviewing an existing agent against the guidance, which fits an edit; the full agent-builder interview is for authoring an agent from scratch.
- **Evidence:**
  - `CLAUDE.md` (all agent edits must follow han-plugin-builder guidance).
  - `docs/plans/orwell-six-rules/artifacts/.discovery-notes.md` (governing convention: agent changes reviewed against agent-builder/guidance rules).
  - R1 claim ledger C11 (prerequisite not named in the four-edit plan), OQ-4 resolution (review pass, not full interview).
- **Rejected alternatives:**
  - Run a full agent-builder interview, rejected because that process authors an agent from scratch, while this is a scoped edit to an existing agent, which the guidance skill's review purpose covers.
- **Specialist owner:** `information-architect`
- **Revisit criterion:** The agent edit grows beyond the escape-clause and criterion-5 amendment into a structural rewrite.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Work Units and Sequencing, Definition of Done

### D-7: Scoped doc-consistency check and no consuming-skill edits

- **Question:** After the edits, which downstream surfaces need updating, and which do not?
- **Decision:** Run a scoped doc-consistency check (the `han-update-documentation` skill on this branch) limited to statements the edits make false. The "six criteria" count claims on the seven-plus surfaces stay untouched and true. Make no consuming-skill edits; reference-file changes propagate through readability-guidance's live reads.
- **Rationale:** The C4 agent shape keeps the rubric at six, so the count claims stay true and must not be touched (C6, C9). Criterion-5 paraphrases in the agent's long-form doc are the only statements at risk, so the check is scoped to them. Consuming skills read the reference files live through `readability-guidance` (SKILL.md:32-40), so no consuming-skill edit is needed (C7).
- **Evidence:**
  - `han-communication/skills/readability-guidance/SKILL.md:32-40` (live cross-plugin reads; edits propagate without consumer changes).
  - R1 claim ledger C6 (grep-confirmed count surfaces stay true), C7 (no consuming-skill edits), C9 (criterion-5 paraphrase check still needed).
- **Rejected alternatives:**
  - Run a full-repo documentation sweep, rejected because the edits keep the rubric at six, so only statements the edits make false need review; a broad sweep risks touching count claims that must stay as they are (C6).
  - Edit consuming skills to carry the new principles, rejected because they read the reference files live through readability-guidance, so the edits reach them without consumer changes (C7).
- **Specialist owner:** `information-architect`
- **Revisit criterion:** A consuming skill is found to cache or copy the reference-file text rather than read it live.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None
- **Referenced in plan:** Work Units and Sequencing, Definition of Done
