# Research: Orwell's Six Rules of Writing, Applied to the han-communication Guidance

Question: what do George Orwell's six rules of writing say, and how should they be applied to the
han-communication readability standard to produce output that is easier for humans to read and understand?
Evidence mode: strict.

## Summary

The current readability standard already follows most of Orwell's six rules, and does so in a form that modern
evidence supports better than Orwell's own absolute phrasing. Four of his rules are fully or mostly covered today:
prefer short common words, cut needless words, write in the active voice, and replace jargon before defining it.

Two real gaps remain. First, there is no general rule against stale, worn-out figures of speech. Second, the
standard never names Orwell's most important rule: the escape clause that says to break any rule rather than write
something clumsy. A third, narrower gap also exists: the word guidance never names foreign, Latinate, or archaic
stock phrases.

The recommendation closes these gaps with small, targeted additions to the existing guidance files and the editor
agent's instructions. The six-point self-check stays unchanged, because growing the checklist would trigger the
compliance decay the standard is explicitly designed to avoid.

Adversarial validation confirmed the two main gaps against the files directly, corrected one citation, and narrowed
the scope of the third gap. The rule text and the case against absolute rules are well corroborated. Some details of
how mature style guides phrase exceptions rest on single sources.

- **Confidence:** Medium

## Research Results

### What the six rules say, and what they were for

Orwell published the six rules in his 1946 essay "Politics and the English Language." Verbatim, they are: (1) "Never
use a metaphor, simile, or other figure of speech which you are used to seeing in print." (2) "Never use a long word
where a short one will do." (3) "If it is possible to cut a word out, always cut it out." (4) "Never use the passive
where you can use the active." (5) "Never use a foreign phrase, a scientific word, or a jargon word if you can think
of an everyday English equivalent." (6) "Break any of these rules sooner than say anything outright barbarous."
(A1, A2, A7)

The rules answer a diagnosis. Orwell cataloged four habits of bad writing. Dying metaphors are stale figures used
without regard to their meaning. Verbal false limbs are padded verb phrases that dodge a plain verb. Pretentious
diction is Latinate vocabulary that lends a false air of authority. Meaningless words are terms used so loosely they
no longer denote anything checkable (A1, A2). His framing question for every sentence is "What am I trying to
say?" Rule 6 subordinates the first five mechanical rules to that goal: they are heuristics in service of
clarity, not laws (A1).

### The rules have known failure modes when read as absolutes

Linguists have documented where the rules break as literal commands. None of this discredits the rules as
directional preferences; it discredits them only as bans without exceptions.

Two Language Log authors independently make two points. Read literally, rule 1 would forbid virtually all fluent
prose. Orwell also breaks rule 4 in his own essay's opening sentence, using the passive phrase "it is generally
assumed" (A3, A4; both posts share a venue, so they are one intellectual lineage rather than two). Pullum separately
showed that Strunk and White's parallel anti-passive rule misidentifies the passive voice in three of its own four
worked examples, which is evidence that absolute grammatical bans get misapplied by the people enforcing them (A13).
Pinker adds that the passive has legitimate uses the active cannot replicate, such as omitting an agent the reader
does not need (A14). A further critique argues plain style is not itself proof of honesty, since disarming plainness
can also be used to obscure (A5) [single-source].

### How mature style guides apply the same preferences

The guides that inherit Orwell's preferences temper them. The Economist Style Guide opens with Orwell's rules but
treats them as a philosophical frame, not a pass/fail test (A8) [single-source]. The US federal plain-language
guidance prefers active voice and names a specific narrow exception for it (A9; the exception clause is
[single-source]). GOV.UK mandates plain English with a 15-to-25-word sentence guideline and active voice, with
contextual escape valves elsewhere in the guide (A10). One downstream checklist converts the same guidance into
measurable thresholds, such as an average sentence under twenty words and active voice above fifty percent (A11)
[single-source]. The pattern across guides: state the directional preference, then attach either a named exception
or a threshold, rather than an unqualified "never" (A9, A10, A11).

### Earlier work on applying these rules to AI-generated text

The clearest direct link between Orwell's tradition and AI output comes from a pair of published AI-prose skills.
"Stop Slop" bans filler phrases, structural tells, and rhythm patterns in machine prose. Its companion, "red-pen"
(by Rich Tabor), enforces principles the Stop Slop author traces to Orwell's "Politics and the English Language" and
Butterick's "Practical Typography" (A15) [single-source; validation confirmed the Orwell lineage belongs to
red-pen, not Stop Slop itself]. The component claims about AI prose are independently corroborated. Three unrelated
sources converge on the same lexical markers of AI prose, including overused words such as "delve" and heavy
em-dash use. They recommend blocklist-style bans as the operational form (A18). One dissenting source rejects
rule-based approaches entirely in favor of cultivating specificity, and reports that automated AI-writing detectors
are unreliable (A16) [single-source]. This is a live disagreement, not a settled question. No widely recognized,
authoritative AI writing style guide adapts Orwell's rules end to end. That absence is itself a finding, not an
oversight (A15, A16, A17).

### Where the han-communication standard already matches the rules

The codebase evidence shows the standard covers Orwell's rules 2 through 4 today, in the tempered form the
earlier work favors (A19, A20, A21):

- **Rule 2 (short common words):** covered. The "Common words" property says to prefer the common word over the
  technical synonym and define an irreplaceable term on first use (A19).
- **Rule 3 (cut needless words):** mostly covered. The blocklist bans specific filler, hedging, and AI-slop phrases
  (A20). The voice profile also forbids performative hedging. There is no single general "cut every needless word"
  statement, but the readability-editor's short-sentence and one-idea-per-paragraph rules do the same work in
  practice (A21).
- **Rule 4 (active voice):** covered, and covered better than Orwell phrased it. The standard says "active by
  default" rather than "never passive" (A19, A21), which matches the documented failure modes of the absolute rule
  (A13, A14).
- **Rule 5, replace-versus-define:** mostly covered, contrary to the initial finding. Validation showed the rule
  already states a replace-first, define-as-fallback framework in one sentence: "Prefer the common word over the
  technical synonym. Define a term on first use when it cannot be replaced" (A19), duplicated nearly verbatim in
  the editor agent (A21). What remains missing is narrower: see the rule 5 gap below.

The standard also already has structural strengths Orwell's list does not address at all: main point first,
one idea per paragraph, descriptive headings, progressive disclosure, and an absolute fidelity guard (A19).

### Where the standard has gaps against the rules

Validation confirmed two real gaps and one narrower one against direct reads of the files (A19, A20, A21):

- **Rule 1 (stale figures of speech):** confirmed gap. The AI-slop list bans specific worn phrases. That is exactly
  rule 1 applied to a modern corpus. But a search of all three canonical files found no general principle against
  reaching for a stale metaphor or cliche not on the list. The voice profile encourages physical-world analogies as
  a signature move without distinguishing a fresh, load-bearing analogy from a worn one (A20). Any fix needs a
  dividing line. The voice profile already has one to reuse: its sports-metaphor rule allows a load-bearing analogy
  and bans a decorative one (A20).
- **Rule 5 (foreign, Latinate, and archaic diction):** narrower gap than first found. The replace-versus-define
  framework already exists (see above). What the guidance never names is the specific category of foreign or
  Latinate stock phrases ("in lieu of," "per se") and archaic formal words ("aforementioned," "herein").
- **Rule 6 (the escape clause):** the most important gap, confirmed by search. The standard has two specific
  escape hatches: the fidelity-wins override and the soft thirty-word sentence threshold (A19, A21). But it never
  states the general principle: when following a rule would make the sentence read worse, break the rule. Orwell
  made this the rule that governs the other five, and the mature guides all carry some form of it (A1, A9, A10).

Validation also surfaced a delivery constraint the gaps analysis alone missed: the readability-editor agent
carries its own hardcoded six-criterion rubric and states "they are the whole rubric" (A21). Edits to the
reference files alone would therefore never reach the rewrite pass, which is the standard's most effective
enforcement path. Any fix has to touch the agent's instructions as well.

One conflict to surface rather than resolve silently: Orwell's rules are phrased as absolutes. The corroborated
evidence (A13, A14) says absolutes misfire. Applying Orwell to this standard therefore means adopting what his
rules protect, in the tempered exception-bearing form the standard already uses, not adopting his "never" phrasing.

## Options to Consider

### O1: Add the missing rules as new self-check criteria

- **What it is:** Extend the standardized six-point self-check with new criteria for stale metaphors, jargon
  substitution, and the escape clause, making them enforced checks on every deliverable.
- **Trade-offs:** Directly contradicts the standard's own design principle that the check "is kept small on purpose
  so it applies as one focused pass rather than decaying under its own weight" (A19). Stale-metaphor detection is
  also a judgment call, not the yes/no criterion the self-check requires. Highest enforcement, highest decay risk.
- **Rests on:** (A19, A1)
- **Evidence status:** corroborated (the rule text and the standard's design constraint are both well evidenced)

### O2: Close the gaps with targeted additions to the existing surfaces, self-check unchanged (as adjusted by validation)

- **What it is:** Three small edits, plus one delivery fix. First, name the escape clause as a general principle in
  the readability rule, alongside the fidelity guard: when following a rule would make the prose read worse, break
  the rule. Second, extend the blocklist's guidance with a short general statement against stale figures of speech
  and pretentious or archaic diction. Use the voice profile's existing load-bearing-versus-decorative test as the
  dividing line, so the signature analogies stay legal. Third, add foreign and Latinate stock phrases and archaic
  formal words to the categories the word guidance names, as examples of the existing replace-first rule rather
  than a new framework. Finally, update the readability-editor agent's instructions so the rewrite pass weighs the
  new principles instead of stopping at its hardcoded six-criterion rubric.
- **Trade-offs:** Nothing new here is machine-checkable. These land as drafting guidance and editor judgment rather
  than self-check gates. That is the same enforcement level the mature guides use for the same rules (A9, A10).
  Edits to the readability rule reach every reader-facing skill in the suite (A23). That means the blast radius is
  wide, so the additions must stay tight. A narrower variant would scope the new principles to the voice profile or
  the agent only. That would shrink the blast radius, but it would not reach skills that self-check without a
  rewrite pass.
- **Rests on:** (A1, A9, A10, A13, A14, A19, A20, A21, A23)
- **Evidence status:** corroborated (rule text, absolute-rule failure modes, and current codebase state are all
  corroborated; the specific phrasing patterns of exceptions in individual guides carry single-source caveats)

### O3: Change nothing; document the lineage only

- **What it is:** Treat the current standard as already Orwell-compliant in substance and record the mapping in a
  doc, without editing the guidance.
- **Trade-offs:** Cheapest and zero decay risk, but leaves the three real gaps open. The escape-clause gap in
  particular means an editor following the rules mechanically has no license to break one when the result reads
  badly, which is the exact failure Orwell's rule 6 exists to prevent (A1).
- **Rests on:** (A19, A20, A21, A1)
- **Evidence status:** corroborated

## Recommendation

- **Recommendation:** O2 as adjusted by validation: close the gaps with targeted additions to `readability-rule.md`
  and `writing-voice.md`. Extend the readability-editor agent's instructions so the rewrite pass sees the new
  principles. Scope the jargon edit down to naming foreign, Latinate, and archaic diction. Keep the six-point
  self-check exactly as it is.
- **Evidence basis:** The verbatim rule text and its intent are corroborated across independent mirrors and
  restatements (A1, A2, A7). The current state of the standard, including which rules it already covers and which
  it lacks, is codebase evidence verified twice, once by exploration and once adversarially (A19, A20, A21). The
  case for tempered, exception-bearing phrasing over Orwell's absolutes is corroborated from two independent
  directions (A13, A14). It also matches the operational pattern of the government plain-language guides (A9, A10).
  Single-source elements include the Economist's framing of the rules (A8), the specific numeric thresholds (A11),
  and the specific exception clause at plainlanguage.gov (A9). None of these is load-bearing for the
  recommendation, which stands on the corroborated rule text, the corroborated critique of absolutes, and the
  codebase gaps.

## Validation

### V1: The replace-versus-define jargon gap was overstated

- **Strategy:** Challenge the Evidence
- **Investigation:** Direct read of the readability rule and the editor agent's rubric.
- **Result:** Partially Refuted. The rule already states a replace-first, define-as-fallback framework ("Prefer the
  common word over the technical synonym. Define a term on first use when it cannot be replaced"), duplicated in
  the agent. The real gap is narrower: foreign, Latinate, and archaic diction is never named.
- **Impact:** The rule 5 finding and O2's third edit were rescoped from "add a framework" to "name the missing
  categories as examples of the existing rule."

### V2: The escape-clause and stale-figures gaps are real

- **Strategy:** Challenge the Evidence
- **Investigation:** Searched all three canonical files for any general break-the-rule principle or any stale-figure
  or cliche guidance. Both searches returned nothing beyond the two narrow escape hatches already cited.
- **Result:** Confirmed.
- **Impact:** The two load-bearing gaps in the recommendation stand.

### V3: The Stop Slop citation misattributed the Orwell lineage

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Fetched the Stop Slop page directly. The Orwell and Butterick lineage is stated for a sibling
  skill, "red-pen" by Rich Tabor, which the Stop Slop author lists as a companion, not for Stop Slop itself.
- **Result:** Refuted as originally cited.
- **Impact:** The earlier-work paragraph was corrected. The claim was not load-bearing for the recommendation.

### V4: The Language Log critiques are fairly represented

- **Strategy:** Challenge the Evidence
- **Investigation:** Fetched both posts and compared their content against the report's claims.
- **Result:** Confirmed, including the report's own shared-venue caveat.
- **Impact:** The "absolutes misfire" evidence chain holds.

### V5: The fix as first scoped would never reach the rewrite pass

- **Strategy:** Challenge the Recommendation
- **Investigation:** Read the readability-editor agent. Its rubric is a separately authored copy of the six
  criteria and closes with "they are the whole rubric." Principles added only to the reference files would
  therefore be invisible to the synthesis-skill rewrite pass.
- **Result:** Confirmed.
- **Impact:** O2 now includes updating the agent's instructions as a required part of the fix.

### V6: A lower-blast-radius option was missing from the framing

- **Strategy:** Challenge the Options Framing
- **Investigation:** Traced the sourcing path: the readability rule is read in full by every reader-facing skill in
  the suite, so editing it has suite-wide reach. Scoping the new principles to the voice profile or the agent alone
  was never framed as its own option.
- **Result:** Partially Refuted (framing gap).
- **Impact:** O2's trade-offs now name the blast radius and the narrower variant, so the implementer can choose the
  surface deliberately.

### V7: The stale-figures principle needs a dividing line

- **Strategy:** Challenge the Recommendation
- **Investigation:** The voice profile names specific analogies as a signature move and reuses them as closing
  devices. A bare "avoid stale figures" principle gives an editor no way to tell a signature analogy from a cliche.
- **Result:** Confirmed as an open ambiguity.
- **Impact:** O2 now specifies reusing the voice profile's existing load-bearing-versus-decorative test as the
  dividing line.

### V8: The primary Orwell text could not be re-fetched during validation

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The mirror hosting the essay returned an access error during validation, so the verbatim rule
  text rests on the research pass's fetch plus cross-mirror agreement, not an independent re-fetch.
- **Result:** Partially Refuted (low-severity provenance gap). The essay is public-domain, widely reproduced, and
  its wording is not in dispute.
- **Impact:** No change to the recommendation; noted as a residual risk.

### Adjustments Made

Validation changed the report in four ways. First, the rule 5 gap was narrowed and the matching O2 edit rescoped
(V1). Second, the Stop Slop citation was corrected to attribute the Orwell lineage to red-pen (V3). Third, updating
the readability-editor agent's instructions became a required part of O2 (V5). Fourth, O2's trade-offs now name the
blast radius of editing the shared rule file and the narrower alternative surface (V6), plus the dividing line for
the stale-figures principle (V7). The recommendation survived in adjusted form.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** Several single-source artifacts were spot-checked for reachability only, not full-text
  accuracy (A8, A9's exception clause, A11, A16). The critique side of the Orwell literature is better evidenced
  than the defence side, because two candidate defence sources were paywalled or blocked during research. This
  asymmetry did not drive the recommendation, which keeps rather than abandons Orwell's substance. Still, it is
  unresolved. Whether the agent-instruction edit should extend the rubric itself or sit beside it is a design call
  for implementation, not settled here. No dry run of the self-check or rewrite behavior against a document with a
  stale metaphor or unresolved jargon was performed.

## Sources

| ID  | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
| --- | ------ | --------------- | --------- | ----------- | ------------------ | --------------- |
| A1  | Orwell, "Politics and the English Language" (full text mirror) | https://americanliterature.com/author/george-orwell/essay/politics-and-the-english-language | 2026-07-21 | web | Verbatim six rules, the four bad-writing habits, and the "What am I trying to say?" framing | corroborated by A2, A7 |
| A2  | Wikipedia: Politics and the English Language | https://en.wikipedia.org/wiki/Politics_and_the_English_Language | 2026-07-21 | web | Essay summary; notes the Pullum critique and the essay's pedagogical longevity | corroborated by A1, A3 |
| A3  | Language Log: Pullum on Orwell | https://languagelog.ldc.upenn.edu/nll/?p=551 | 2026-07-21 | web | Pullum: rule 1 is unfollowable literally; the essay conflates style with honesty | corroborated by A4 (shared venue) |
| A4  | Language Log: "Orwell's Liar" (Beaver) | https://languagelog.ldc.upenn.edu/nll/?p=992 | 2026-07-21 | web | Orwell breaks rule 4 in his own opening sentence; the decline premise is unsupported | corroborated by A3 (shared venue) |
| A5  | New Statesman: "Don't be beguiled by Orwell" | https://www.newstatesman.com/culture/2013/02/don%E2%80%99t-be-beguiled-orwell-using-plain-and-clear-language-not-always-moral-virtue | 2026-07-21 | web | Plain style can obscure as well as reveal; plainness is not proof of honesty | single source (caveated) |
| A6  | Pullum on prescriptive advice as "sacred scripture" | https://www.npr.org/2009/04/16/103171738/a-half-century-of-stupid-grammar-advice | 2026-07-21 | web | Reported framing of Orwell/Strunk fetishization in composition teaching | single source (caveated, not verified against primary) |
| A7  | Open Culture and Duke restatements of the six rules | https://sites.duke.edu/scientificwriting/orwells-6-rules/ | 2026-07-21 | web | Independent restatements confirming the rule wording; the rules travel into technical-writing pedagogy | corroborated by A1 |
| A8  | The Economist Style Guide's use of Orwell | https://writingcooperative.com/5-tips-on-writing-from-the-economist-style-guide-28a7ff736ade | 2026-07-21 | web | The Economist opens its guide with Orwell's rules as a philosophical frame | single source (caveated) |
| A9  | plainlanguage.gov active-voice guidance | https://github.com/GSA/plainlanguage.gov/blob/main/_pages/guidelines/conversational/use-active-voice.md | 2026-07-21 | web | Active-voice preference with a named narrow exception (law as actor) | preference corroborated by A10; exception clause single source |
| A10 | GOV.UK content style guide | https://guidance.publishing.service.gov.uk/writing-to-gov-uk-standards/style-guides/a-to-z-style-guide/ | 2026-07-21 | web | Plain English mandatory; 15-25 word sentences; active voice; contextual escape valves | corroborated by A9 |
| A11 | AuditBuffet plain-language checklist | https://auditbuffet.com/patterns/ab-001617 | 2026-07-21 | web | Converts plain-language rules into numeric thresholds (sentence length, percent active) | single source (caveated) |
| A12 | Strunk & White, "omit needless words" | https://faculty.washington.edu/heagerty/Courses/b572/public/StrunkWhite.pdf | 2026-07-21 | web | The canonical absolute cut-words imperative, parallel to Orwell's rule 3 | corroborated by A1 |
| A13 | Pullum, "50 Years of Stupid Grammar Advice" | https://www.chronicle.com/article/whos-afraid-of-strunk-and-white/ | 2026-07-21 | web | Strunk & White misidentify the passive in three of four of their own examples | corroborated by A14 |
| A14 | Pinker on the passive voice | https://www.unz.com/isteve/pinker-on-the-passive-voice/ | 2026-07-21 | web | The passive has legitimate uses (agent unimportant or distracting) an absolute ban forecloses | corroborated by A13 |
| A15 | "Stop Slop" AI-slop skill (and companion "red-pen") | https://gauravtiwari.org/stop-slop-ai-slop/ | 2026-07-21 | web | Rule sets for AI prose; the companion red-pen skill carries the stated Orwell lineage (corrected per V3) | single source (caveated) |
| A16 | "The Field Guide to AI Slop" | https://www.ignorance.ai/p/the-field-guide-to-ai-slop | 2026-07-21 | web | Rejects rule-based fixes in favor of cultivated specificity; AI detectors unreliable | single source (caveated); contradicts A15's approach |
| A17 | markup.ai enterprise AI writing rules | https://markup.ai/blog/rules-for-ai-to-write-successful-content/ | 2026-07-21 | web | Enterprise AI-writing governance is compliance-focused, with no Orwell/plain-language lineage | single source (caveated) |
| A18 | Converging AI-slop lexical tells (three sources) | https://aipulsr.com/blog/why-ai-writing-drowns-in-em-dashes-and-how-to-stop-it | 2026-07-21 | web | Three independent pieces converge on the same overused words and em-dash overuse in AI prose | corroborated (three independent sources) |
| A19 | Han readability rule | han-communication/references/readability-rule.md | n/a | codebase | The nine output properties, length guidance, fidelity guard, and six-point self-check | codebase (current-state anchor) |
| A20 | Han writing-voice profile | han-communication/references/writing-voice.md | n/a | codebase | Voice attributes, the vocabulary blocklist, and the AI-slop list | codebase (current-state anchor) |
| A21 | readability-editor agent | han-communication/agents/readability-editor.md | n/a | codebase | The six-criterion rewrite rubric, prose-only scope, and fidelity override | codebase (current-state anchor) |
| A22 | readability-guidance skill | han-communication/skills/readability-guidance/SKILL.md | n/a | codebase | The inline cross-plugin sourcing mechanism for the standard | codebase (current-state anchor) |
| A23 | Cross-plugin readability doc | docs/readability.md | n/a | codebase | Staged application design principle and the consumer-skill table | codebase (current-state anchor) |

### A1: Orwell, "Politics and the English Language" (recommendation-bearing)

- **Link / location:** https://americanliterature.com/author/george-orwell/essay/politics-and-the-english-language
- **Retrieved:** 2026-07-21
- **Trust class:** web
- **Summary:** The primary text. Supplies the six rules verbatim, the four-part diagnosis of bad writing that
  motivates them, the "What am I trying to say?" framing, and rule 6's explicit subordination of the mechanical
  rules to clarity. The Orwell Foundation's own hosting failed to fetch, so the text rests on two independent
  mirrors that agree word for word.
- **Evidence status:** corroborated by A2, A7

### A13: Pullum, "50 Years of Stupid Grammar Advice" (recommendation-bearing)

- **Link / location:** https://www.chronicle.com/article/whos-afraid-of-strunk-and-white/
- **Retrieved:** 2026-07-21
- **Trust class:** web
- **Summary:** Documents that Strunk and White's own worked examples misidentify the passive voice three times out
  of four. This is the strongest concrete evidence that absolute grammatical bans get misapplied in practice, which
  is why the recommendation keeps the standard's "active by default" phrasing instead of adopting Orwell's "never."
- **Evidence status:** corroborated by A14

### A19: Han readability rule (recommendation-bearing)

- **Link / location:** han-communication/references/readability-rule.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** The current-state anchor. Defines the nine output properties (including "Common words" and "Short,
  active sentences"), the soft thirty-word threshold, the fidelity-wins override, and the six-point self-check with
  its explicit keep-it-small design principle. The recommendation's shape (targeted additions, self-check
  unchanged) follows directly from this file's own stated constraint against instruction stacking.
- **Evidence status:** codebase (current-state anchor)

### A20: Han writing-voice profile (recommendation-bearing)

- **Link / location:** han-communication/references/writing-voice.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Carries the authoritative vocabulary blocklist ("Avoided words and phrases" plus "AI slop to
  avoid") and the physical-world-analogy signature move. The blocklist is where the stale-figure and
  pretentious-diction guidance would land, turning the enumerated bans into examples of a named principle.
- **Evidence status:** codebase (current-state anchor)
