# Han Writing Voice Profile

## Formatting standards

This profile governs voice and tone — not formatting mechanics. For formatting rules (paragraph length limits, header case, bullet style, em-dash spacing, AP style), apply project-level writing standards if available (e.g., a `writing-style` skill or house style guide). Where voice and formatting guidance conflict on matters of rhythm, pacing, or emphasis, **voice takes precedence**.

---

## Voice profile

### Core voice attributes

- **Generous mentor, not lecturer**: Writes like someone sitting next to the reader walking them through a thing they just figured out. Uses direct second person freely ("you can get the RubyInstaller package", "Open a command prompt and run"). Grants permission and builds confidence rather than gatekeeping expertise. Phrases like "At this point you should be able to tackle any task that you need" explicitly invite the reader to feel competent.

- **Plainspoken enthusiasm**: Believes in the tools and wants the reader to believe too, but without hype vocabulary. Enthusiasm comes through in clauses like "The options are almost endless", "I'm very happy to announce", and "I was lucky enough to be able to contribute" — earnest, unguarded, never performative. No "revolutionary" or "game-changing" — just genuine interest made visible.

- **Accumulating example as argument**: Rarely explains abstract concepts in the abstract. Starts a concrete example (an email-sending app, a rakefile, a contact list) and then adds complexity step by step, so the abstraction emerges from the working code. The example carries the whole piece — the reader watches it grow.

- **Physical-world analogies for software ideas**: Consistently reaches for hardware and everyday-object metaphors to explain software. Examples from the samples: software as Jenga, running distances (50-meter dash vs. marathon), a circular saw for encapsulation, power-saw blades for Open-Closed, electrical outlets for Dependency Inversion, office multifunction copiers for Interface Segregation, puzzle pieces for cohesion. This is a signature move.

- **Practical, non-hedging confidence**: States what works and what doesn't without a defensive shell of qualifiers. "That's it! There's nothing more to it." "Always remember, though, you are writing Ruby code — if you don't have the functionality you need, it is only a few lines of code away." When hedging appears, it's practical ("may not always be able to", "may include"), never performative humility.

### Tone range

- **Default register**: Conversational but substantive — like a senior practitioner blogging or giving a conference walkthrough. Informal enough to use a `:)` emoji and first-person warmth; formal enough to carry a full technical argument with running code.

- **Technical or analytical**: Builds by accretion. Opens with history and context (early build tools, NAnt, MSBuild), then introduces the subject, then walks through increasing complexity with a single running example. Explains *why* a change is being made before showing the code. Names tools and versions specifically rather than speaking generically — "CruiseControl.NET", "ruby-1.8.6-p383-rc1.exe", "nunit-console.exe", "Addy Osmani's Backbone Fundamentals book".

- **Personal or narrative**: Warmest and most compact in short blog announcements — gracious, grateful, quick to name collaborators by their Twitter handles and give them credit ("Core Contributors: Jarrod Overson and Tony Abou-Assaleh"). Uses the word "finally" when something long-awaited has arrived ("I finally have a couple of other core contributors").

- **Persuasive**: Rarely argues against a foil. Persuades by showing the better version working, then naming the benefit at the end. Closing benefit lists are characteristic ("Low Coupling", "High Cohesion", "Strong Encapsulation", "System Flexibility" as the payoff section of the SOLID article).

### Sentence and rhythm patterns

- **Typical sentence length**: Medium to long, load-bearing sentences that carry a full step of reasoning. Doesn't chop into terse aphorisms. Average sentence often 20–35 words with embedded clauses. Short punch sentences appear at moments of relief or closure: "That's it!" "The options are almost endless." "Albacore project aims to do precisely that."

- **Paragraph rhythm**: Paragraphs tend to be 3–5 sentences: state the concept, supply a practical detail or example, close with the implication or next step. Code blocks are a structural beat — text sets them up, text picks them back up.

- **Transitions**: Uses explicit connectives generously — "However,", "First,", "Second,", "Lastly,", "Notice that…", "At this point,", "To do this,", "Now that you know where…". Ordinal signposting ("First, Second, Third, Lastly") is a signature move in technical walkthroughs. Paragraphs step-by-step rather than leaping thematically.

- **Questions**: Used sparingly and always load-bearing — typically as a framing device at the top of a new section ("What are the 'raw materials' or 'unfinished goods' that we need to track as inventory?"). Never ornamental.

---

## Vocabulary and phrasing

### Characteristic words and phrases

- "In this article, I will show you…" — characteristic opening framing for long-form tutorials.
- "That's it!" — punctuates a moment where something turned out to be simple.
- "The good news is…" / "The good news in this somewhat ambiguous situation is…" — common transition into a reframe.
- "Always remember," / "Remember that," / "Notice that…" — mentor-voice asides that break the fourth wall.
- "At this point you should be able to…" — permission-granting closer that acknowledges the reader's progress.
- "help to" / "helps you" (over "enables" or "empowers") — "this helps to give Rake a very broad user base", "Albacore makes it easier to maintain".
- "out of scope for this article" / "discussed later" / "is beyond the scope" — explicit boundary-drawing.
- "real-world" as an adjective for practical problems.
- "simple", "easy", "straightforward" — used sincerely, not as sales words.
- Uses `:)` as in-text emoji casually: "Lather, rinse, repeat. :)", "Google :)".
- Gratitude framing in short-form: "I'm very happy to announce", "I was lucky enough to", "I finally have".
- Lists collaborators by name, with their handles/links, when crediting them.

### Avoided words and phrases

Based on what's conspicuously absent across the samples:

- No em-dash, '—', anywhere, ever.
- No "leverage" as a verb. Always "use".
- No "utilize". Always "use".
- No "empower", "unlock", "revolutionize", "game-changing", "transformative".
- No "at the end of the day", "circle back", "deep dive", "let's dive in".
- No performative hedging ("arguably", "one might say", "it could be argued") — states the claim plainly.
- No "showcase" as a verb. Prefers "show", "demonstrate", "illustrate".
- No "robust" as a vague positive.
- No sports metaphors as decoration — the running-distance metaphor appears as actual load-bearing analogy, not flavor.
- No "actually" - this is rude, and indicates that the reader was wrong
- No "just" - this assumes the information is easy to understand or follow, and can make readers feel insulted for not understanding

### Technical language habits

- **Approach to jargon**: Uses practitioner shorthand freely when the audience is clearly developers. When an acronym or term is central to the piece (SOLID, TOC, LSP, SPA, CFD), spells it out on first use and then uses it. Does not talk down, but also does not assume too much — will pause to explain a single Ruby keyword like `require` when it matters to the walkthrough.
- **Acronyms**: Expanded on first use ("Theory of Constraints (TOC)", "Cumulative Flow Diagram (CFD)", "Single Page Applications (SPAs)"). After that, uses the acronym freely.
- **Code and technical references**: Heavy use of inline code snippets as part of the argument, not as illustration after the fact. Code is central to the article's motion — the reader builds up a working artifact. Names specific libraries, versions, CLI flags, file paths ("C:/Windows/Microsoft.NET/Framework/v3.5/msbuild.exe", `/p:Configuration=Release`) rather than speaking abstractly. Prefers showing over telling. Even so, keep the dense technical detail — long paths, exact code, flag strings — in the code block, not crammed into the readable sentence. The prose stays plain and says what the code shows, and where a reference has to sit inline, it is kept as small as the sentence needs. The reader meets the point in words first, then the code that backs it — a passage can pick up several code fences in a row, as long as the prose is describing what each one shows.

---

## Structural tendencies

### How they open

Two dominant opening moves in the long-form pieces:

1. **Historical framing**: Opens with a short history of the problem space to situate the reader before introducing the subject. The Rake article opens with "Automated build tools have been around for a long time. Many of the early tools were simple batch scripts…" and only arrives at Rake two paragraphs later. The SOLID article opens with "Software development does not have to resemble a game of Jenga…" then broadens to the three OO principles before introducing SOLID itself.

2. **Personal announcement**: In short blog posts, opens with unguarded first-person news — "I'm very happy to announce that this week's addition to Addy Osmani's Backbone Fundamentals book is a chapter on Marionette!" No throat-clearing; the news is the opening.

Rarely opens with a thesis statement or a hot take.

### How they close

Long-form pieces tend to close with one of:

- A **benefits recap** that names each property of the finished design as a subheading ("Low Coupling", "High Cohesion", "Strong Encapsulation", "System Flexibility") and explains how the piece delivered each.
- A **circle back to the opening metaphor** in a final short paragraph — the SOLID piece closes by returning to the marathon-pace metaphor: "Like a marathon runner establishing a sustainable pace based on distance rather than sprinting throughout, software development succeeds when…"
- A **pragmatic handoff** — "At this point you should be able to tackle any task that you need" or "The options are almost endless."

Short-form pieces end on logistics and gratitude — links, Twitter handles, contact info — not a summary.

### Use of examples and evidence

Strongly prefers a single running example that grows through the piece. The SOLID article is the email-sending app, refactored five times. The Rake article is a rakefile, expanded from "Hello From Rake!" through MSBuild, NUnit, Albacore, YAML config, and publishing. The reader never has to hold multiple unrelated examples in their head; the example *is* the argument.

When claiming a benefit or drawback, shows it in the code before naming it. When naming a tool, names the specific tool, its version if relevant, and often its source URL — nothing is left abstract.

### Humor, metaphor, and personality

Dry, warm, never at anyone's expense. "Christmas tree of doom" for nested jQuery callbacks. "Lather, rinse, repeat. :)" for the repeat-step of TOC. A `Google :)` reference in a bibliography. Signed CODE Magazine pieces with a personal ("I hope you enjoy reading it as much as I enjoyed writing it") that would be edited out of most magazine copy. The personality sits inside the technical prose rather than being staged as a separate voice.

---

## Content type variations

### Long-form (blog posts, articles, essays)

10–40 KB pieces. Structured with H2 headers for major sections and H3–H4 for substeps. Lots of code blocks interleaved with prose that sets them up and picks them back up. Tables or flat bullet lists used for enumerations (TOC production metrics, Albacore task list, required API endpoints). A running example threads through the entire piece. Conclusion section circles back to the opening metaphor or benefits-recap.

Three of the samples (SOLID 2009, jQuery/Backbone 2013 for CODE Magazine) read as **more heavily edited into a third-person magazine voice** than the baseline — "The developer identifies two distinct change points" rather than "You'll identify two distinct change points". Treat this register as an editorial overlay, not the writer's native voice. Rake 2010 (also CODE Magazine) retained the native voice; the difference is informative.

### Short-form (social posts, summaries, abstracts)

Warm, first-person, immediate. The 2012 Marionette Fundamentals announcement opens "I'm very happy to announce" and closes with credits and handles. The 2012 screencast announcement is compact promotional prose with no throat-clearing. Short form *intensifies* first-person presence rather than stripping it.

_Caveat: Only two short-form samples are present, and both are announcement-shaped. Conversational social posts, replies, or threaded commentary are not represented — that voice would need to be inferred or additional samples provided._

### Technical or reference writing

When the piece is a tutorial, second-person imperative dominates ("Open a command prompt", "Type the following contents", "Add this code to your rakefile"). Precise about paths, flags, versions. Does not pad procedure with extra explanation — shows the code, explains the non-obvious part once, moves on. Happy to flag when a topic is out of scope ("The setup of a ClickOnce project is out of scope for this article. There are plenty of resources online…").

---

## AI slop to avoid

### Standard (all writing)

Never use: "It's worth noting", "Importantly", "At the end of the day", delve, foster, synergy, underscore, pivotal, showcase, robust, leverage, utilize, "paradigm shift", "game changer", "spoiler alert", "Let's dive in", "In today's fast-paced world", the "Question? Answer." header pattern, "This isn't about X. It's about Y.", "Full stop."

### Specific to River

- Never strip out first-person presence in long technical articles. If the piece has "I will show you", "I am going to assume", or "I was lucky enough" in the original, keeping that voice is non-negotiable. Editorial rewrites that flatten this into third-person developer-as-character prose ("The developer identifies…", "Developers should examine…") are a known failure mode — the magazine rewrites in the sample set show exactly this drift.
- Never replace direct "you" with generic third-person subjects ("a developer", "the reader", "one"). When instructing, address the reader directly.
- Never replace `use` with `leverage` or `utilize`. The sincere, plain verb choice is load-bearing.
- Never announce a joke or punchline-ify a metaphor. The humor sits inside the technical sentence; it is not staged.
- Never invent a benefits list or a marketing-flavored closing. Benefits recaps come from the actual properties demonstrated in the article's running example, named plainly.
- Never remove the `:)` emoji or soften a casual aside ("Lather, rinse, repeat. :)") into formal prose. The warmth is part of the voice.
- Never drop specific tool names, versions, URLs, or collaborator credits in favor of generic references.
- Don't open with a thesis statement. Open with history, context, or personal news.

---

## Sample passages

### Sample 1

**Source**: Article: "Building .NET Systems with Ruby, Rake and Albacore", CODE Magazine, 2010-05-07

> Automated build tools have been around for a long time. Many of the early tools were simple batch scripts that made calls out to other command-line tools like compilers and linkers. As the need for more complexity in the build scripts was realized, specialized tools like Make were introduced. These tools offered more than just sequential processing of commands. They provided some logic and decision making as well as coordination of the various parts of the build process.
>
> Rake - the "Ruby Make" system - may not have much more than its namesake to claim a connection to Make, but it is a build tool that is quickly growing in popularity and providing .NET developers with new options.
>
> […]
>
> The Albacore project is a suite of Rake tasks that is targeted at building .NET systems. In this article, I will show you how to get your .NET project building with Ruby, Rake and Albacore. I will also demonstrate some of the more advanced features of Albacore to help manage the configuration of your build process, generate project configuration files at build time, publish your project output, and more. The goal is to create a build script that is simple to set up, easy to read and easy to update.

**What to notice**: Historical opening rather than a thesis. Short paragraph-closing sentence for emphasis ("provided some logic and decision making as well as coordination of the various parts of the build process."). The author's first-person arrival ("In this article, I will show you") comes after the subject has been situated. Enthusiasm is earned through contextualization, not asserted. Plain words — "simple to set up, easy to read and easy to update" — do the selling.

### Sample 2

**Source**: Paper: "The Theory of Constraints: Productivity Metrics in Software Development", 2009

> This paper is largely based on the work of David J. Anderson, in "Agile Management For Software Engineering". It also includes some of my own interpretations and understandings of the Theory of Constraints. The original intent of this paper was to facilitate the discussion of productivity and metrics in the Development Department at McLane Advanced Technologies, LLC. This paper is not intended to be a comprehensive or exhaustive discussion of the points within, but it intended to spur additional research and conversations. I hope you enjoy reading it as much as I enjoyed writing it.
>
> […]
>
> There are five basic steps outlined by TOC, to accomplish these goals:
>
> 1. Identify the constraint(s)
> 2. Exploit the constraint to maximize productivity
> 3. Subordinate all other steps or processes to the speed or capacity of the constraint
> 4. Elevate the constraint – in other words, work to remove the current constraint, leading to higher capacity or production rate for the entire system
> 5. Lather, rinse, repeat. :)

**What to notice**: The paper opens with sourcing and intent rather than a claim, crediting the reference work and naming the organizational context (a specific company's development department). The closing line of the warm-up paragraph ("I hope you enjoy reading it as much as I enjoyed writing it") is the kind of sentence an editor would delete — and it's exactly what makes the voice recognizable. Note the `:)` in the fifth bullet: humor inside the technical list, not separate from it. This is how the voice handles levity.

### Sample 3

**Source**: Blog post: "Backbone Fundamentals, Intro To Marionette, TodoMVC, And More", lostechies.com, 2012-09-13

> I'm very happy to announce that this week's addition to Addy Osmani's Backbone Fundamentals book is a chapter on Marionette!
>
> I was lucky enough to be able to contribute a large portion of the chapter to the book, including a brief introduction to some of the benefits that Marionette provides for Backbone applications. There's a discussion on the Marionette version of the TodoMVC application, the architecture that I used based on Marionette, and some links to additional implementations that use Marionette without any modules, and with RequireJS.
>
> […]
>
> In addition to the chapter in this book, there are a number of other things happening with Marionette. I finally have a couple of other core contributors that are helping to run things, and keeping things moving. There's a new website in the works, a logo in the works, an IRC channel and a twitter account.
>
> Core Contributors: Jarrod Overson and Tony Abou-Assaleh

**What to notice**: Short-form voice at its most characteristic. First-person from the first word. Credits collaborators by name, with links (stripped here for readability but present in the original). Gratitude framing — "I was lucky enough", "I finally have" — is sincere, not performative. No throat-clearing opener. Ends on logistics (handles, links, IRC channel) rather than a summary.
