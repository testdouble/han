# Research: Orwell's Six Rules of Writing, Applied to the han-communication Guidance

Question: what do George Orwell's six rules of writing actually say, and how should they be applied to the
han-communication readability standard to produce output that is easier for humans to read and understand?
Evidence mode: strict.

## Summary

The current readability standard already follows most of Orwell's six rules, and in a form that modern evidence
supports better than Orwell's own absolute phrasing. Three of his rules are fully or mostly covered today: prefer
short common words, cut needless words, and write in the active voice. Three are gaps: there is no general rule
against stale, worn-out figures of speech; there is no guidance on when to replace jargon outright versus define it;
and the standard never names Orwell's most important rule, the escape clause that says to break any rule rather than
write something clumsy. The recommendation is to close those three gaps with small, targeted additions to the
existing guidance files, while keeping the six-point self-check unchanged, because growing the checklist would
trigger the compliance decay the standard is explicitly designed to avoid. The rule text and the case against
absolute rules are well corroborated; some details of how mature style guides phrase exceptions rest on single
sources.

- **Confidence:** Medium

## Research Results

### What the six rules say, and what they were for

Orwell published the six rules in his 1946 essay "Politics and the English Language." Verbatim, they are: (1) "Never
use a metaphor, simile, or other figure of speech which you are used to seeing in print." (2) "Never use a long word
where a short one will do." (3) "If it is possible to cut a word out, always cut it out." (4) "Never use the passive
where you can use the active." (5) "Never use a foreign phrase, a scientific word, or a jargon word if you can think
of an everyday English equivalent." (6) "Break any of these rules sooner than say anything outright barbarous."
(A1, A2, A7)

The rules answer a diagnosis. Orwell cataloged four habits of bad writing: dying metaphors (stale figures used
without regard to their meaning), verbal false limbs (padded verb phrases that dodge a plain verb), pretentious
diction (Latinate vocabulary that lends a false air of authority), and meaningless words (terms used so loosely they
no longer denote anything checkable) (A1, A2). His framing question for every sentence is "What am I trying to
say?", and rule 6 subordinates the first five mechanical rules to that goal: they are heuristics in service of
clarity, not laws (A1).

### The rules have known failure modes when read as absolutes

Linguists have documented where the rules break as literal commands. Two Language Log authors independently note
that rule 1, read literally, would forbid virtually all fluent prose, and that Orwell breaks rule 4 in his own
essay's opening sentence with the passive "it is generally assumed" (A3, A4; both posts share a venue, so they are
one intellectual lineage rather than two). Pullum separately showed that Strunk and White's parallel anti-passive
rule misidentifies the passive voice in three of its own four worked examples, evidence that absolute grammatical
bans get misapplied by the people enforcing them (A13). Pinker adds that the passive has legitimate uses the active
cannot replicate, such as omitting an agent the reader does not need (A14). A further critique argues plain style is
not itself proof of honesty, since disarming plainness can also be used to obscure (A5) [single-source]. None of
this discredits the rules as directional preferences; it discredits them as bans without exceptions.

### How mature style guides operationalize the same preferences

The guides that inherit Orwell's preferences temper them. The Economist Style Guide opens with Orwell's rules but
treats them as a philosophical frame, not a pass/fail test (A8) [single-source]. The US federal plain-language
guidance prefers active voice and names a specific narrow exception for it (A9; the exception clause is
[single-source]). GOV.UK mandates plain English with a 15-to-25-word sentence guideline and active voice, with
contextual escape valves elsewhere in the guide (A10). One downstream checklist converts the same guidance into
measurable thresholds, such as an average sentence under twenty words and active voice above fifty percent (A11)
[single-source]. The pattern across guides: state the directional preference, then attach either a named exception
or a threshold, rather than an unqualified "never" (A9, A10, A11).

### Prior art on applying these rules to AI-generated text

The clearest direct link between Orwell's tradition and AI output is a published "Stop Slop" skill that names
Orwell's essay as its ancestry and translates it into banned filler phrases, structural tells, and rhythm rules for
machine prose (A15) [single-source]. Its component claims are independently corroborated: three unrelated sources
converge on the same lexical markers of AI prose, including overused words such as "delve" and heavy em-dash use,
and recommend blocklist-style bans as the operational form (A18). One dissenting source rejects rule-based
approaches entirely in favor of cultivating specificity, and reports that automated AI-writing detectors are
unreliable (A16) [single-source]; this is a live disagreement, not a settled question. No widely recognized,
authoritative AI writing style guide that adapts Orwell's rules end to end was found; that absence is a finding,
not an oversight (A15, A16, A17).

### Where the han-communication standard already matches the rules

The codebase evidence shows the standard covers Orwell's rules 2 through 4 today, in the tempered form the
prior art favors (A19, A20, A21):

- **Rule 2 (short common words):** covered. The "Common words" property says to prefer the common word over the
  technical synonym and define an irreplaceable term on first use (A19).
- **Rule 3 (cut needless words):** mostly covered. The blocklist bans specific filler, hedging, and AI-slop phrases
  (A20), and the voice profile forbids performative hedging. There is no single general "cut every needless word"
  statement, but the readability-editor's short-sentence and one-idea-per-paragraph rules do the same work in
  practice (A21).
- **Rule 4 (active voice):** covered, and covered better than Orwell phrased it. The standard says "active by
  default" rather than "never passive" (A19, A21), which matches the documented failure modes of the absolute rule
  (A13, A14).

The standard also already has structural strengths Orwell's list does not address at all: main point first,
one idea per paragraph, descriptive headings, progressive disclosure, and an absolute fidelity guard (A19).

### Where the standard has gaps against the rules

Three of Orwell's rules have no explicit counterpart in the current guidance (A19, A20, A21):

- **Rule 1 (stale figures of speech):** partial gap. The AI-slop list bans specific worn phrases, which is exactly
  rule 1 applied to a modern corpus, but there is no general principle against reaching for a stale metaphor or
  cliche not on the list. The voice profile encourages physical-world analogies as a signature move without
  distinguishing a fresh, load-bearing analogy from a worn one (A20).
- **Rule 5 (jargon and foreign phrases):** partial gap. "Define a term on first use when it cannot be replaced"
  (A19) handles the define case but gives no guidance on when to replace jargon outright, and nothing covers
  Latinate or foreign stock phrases ("in lieu of," "per se") or archaic formal words ("aforementioned," "herein").
- **Rule 6 (the escape clause):** the most important gap. The standard has two specific escape hatches, the
  fidelity-wins override and the soft thirty-word sentence threshold (A19, A21), but never states the general
  principle: when following a rule would make the sentence read worse, break the rule. Orwell made this the rule
  that governs the other five, and the mature guides all carry some form of it (A1, A9, A10).

One conflict to surface rather than resolve silently: Orwell's rules are phrased as absolutes, and the corroborated
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

### O2: Close the gaps with targeted additions to the existing surfaces, self-check unchanged

- **What it is:** Three small edits. First, name the escape clause as a general principle in the readability rule,
  alongside the fidelity guard: when following a rule would make the prose read worse, break the rule. Second,
  extend the blocklist's guidance with a short general statement against stale figures of speech and pretentious or
  archaic diction, so the specific banned phrases are examples of a principle rather than an exhaustive list. Third,
  add a replace-versus-define line to the "Common words" property: replace jargon when an everyday equivalent
  carries the same meaning; define and keep it when the reader needs the precise term.
- **Trade-offs:** Nothing new is machine-checkable; these land as drafting guidance and editor judgment rather than
  self-check gates. That is the same enforcement level the mature guides use for the same rules (A9, A10). Modest
  risk of the reference files growing over time if additions are not kept tight.
- **Rests on:** (A1, A9, A10, A13, A14, A19, A20, A21)
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

- **Recommendation:** O2. Close the three gaps with targeted additions to `readability-rule.md` and
  `writing-voice.md`, and keep the six-point self-check exactly as it is.
- **Evidence basis:** The verbatim rule text and its intent are corroborated across independent mirrors and
  restatements (A1, A2, A7). The current state of the standard, including which rules it already covers and which
  it lacks, is codebase evidence (A19, A20, A21). The case for tempered, exception-bearing phrasing over Orwell's
  absolutes is corroborated from two independent directions (A13, A14) and matches the operational pattern of the
  government plain-language guides (A9, A10). Single-source elements: the Economist's framing of the rules (A8),
  the specific numeric thresholds (A11), and the specific exception clause at plainlanguage.gov (A9); none of these
  is load-bearing for the recommendation, which stands on the corroborated rule text, the corroborated critique of
  absolutes, and the codebase gaps.

## Validation

_Pending adversarial validation._

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
| A15 | "Stop Slop" AI-slop skill | https://gauravtiwari.org/stop-slop-ai-slop/ | 2026-07-21 | web | Rule set for AI prose naming Orwell's essay as its ancestry; banned phrases plus structural tells | single source (caveated) |
| A16 | "The Field Guide to AI Slop" | https://www.ignorance.ai/p/the-field-guide-to-ai-slop | 2026-07-21 | web | Rejects rule-based fixes in favor of cultivated specificity; AI detectors unreliable | single source (caveated); contradicts A15's approach |
| A17 | markup.ai enterprise AI writing rules | https://markup.ai/blog/rules-for-ai-to-write-successful-content/ | 2026-07-21 | web | Enterprise AI-writing governance is compliance-focused, with no Orwell/plain-language lineage | single source (caveated) |
| A18 | Converging AI-slop lexical tells (three sources) | https://aipulsr.com/blog/why-ai-writing-drowns-in-em-dashes-and-how-to-stop-it | 2026-07-21 | web | Three independent pieces converge on the same overused words and em-dash overuse in AI prose | corroborated (three independent sources) |
| A19 | Han readability rule | han-communication/references/readability-rule.md | n/a | codebase | The nine output properties, length guidance, fidelity guard, and six-point self-check | codebase (current-state anchor) |
| A20 | Han writing-voice profile | han-communication/references/writing-voice.md | n/a | codebase | Voice attributes, the vocabulary blocklist, and the AI-slop list | codebase (current-state anchor) |
| A21 | readability-editor agent | han-communication/agents/readability-editor.md | n/a | codebase | The six-criterion rewrite rubric, prose-only scope, and fidelity override | codebase (current-state anchor) |
| A22 | readability-guidance skill | han-communication/skills/readability-guidance/SKILL.md | n/a | codebase | The inline cross-plugin sourcing mechanism for the standard | codebase (current-state anchor) |
| A23 | Cross-plugin readability doc | docs/readability.md | n/a | codebase | Staged application design principle and the consumer-skill table | codebase (current-state anchor) |

### A1: Orwell, "Politics and the English Language" — recommendation-bearing

- **Link / location:** https://americanliterature.com/author/george-orwell/essay/politics-and-the-english-language
- **Retrieved:** 2026-07-21
- **Trust class:** web
- **Summary:** The primary text. Supplies the six rules verbatim, the four-part diagnosis of bad writing that
  motivates them, the "What am I trying to say?" framing, and rule 6's explicit subordination of the mechanical
  rules to clarity. The Orwell Foundation's own hosting failed to fetch, so the text rests on two independent
  mirrors that agree word for word.
- **Evidence status:** corroborated by A2, A7

### A13: Pullum, "50 Years of Stupid Grammar Advice" — recommendation-bearing

- **Link / location:** https://www.chronicle.com/article/whos-afraid-of-strunk-and-white/
- **Retrieved:** 2026-07-21
- **Trust class:** web
- **Summary:** Documents that Strunk and White's own worked examples misidentify the passive voice three times out
  of four. This is the strongest concrete evidence that absolute grammatical bans get misapplied in practice, which
  is why the recommendation keeps the standard's "active by default" phrasing instead of adopting Orwell's "never."
- **Evidence status:** corroborated by A14

### A19: Han readability rule — recommendation-bearing

- **Link / location:** han-communication/references/readability-rule.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** The current-state anchor. Defines the nine output properties (including "Common words" and "Short,
  active sentences"), the soft thirty-word threshold, the fidelity-wins override, and the six-point self-check with
  its explicit keep-it-small design principle. The recommendation's shape (targeted additions, self-check
  unchanged) follows directly from this file's own stated constraint against instruction stacking.
- **Evidence status:** codebase (current-state anchor)

### A20: Han writing-voice profile — recommendation-bearing

- **Link / location:** han-communication/references/writing-voice.md
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Carries the authoritative vocabulary blocklist ("Avoided words and phrases" plus "AI slop to
  avoid") and the physical-world-analogy signature move. The blocklist is where the stale-figure and
  pretentious-diction guidance would land, turning the enumerated bans into examples of a named principle.
- **Evidence status:** codebase (current-state anchor)
