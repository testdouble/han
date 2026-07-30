# Manual Test Plan: Han version 5.0.0 changes

## What this plan checks

This plan checks the changes heading into Han version 5.0.0 by hand. It contains thirty-six tests, organized into nine
groups so you can see how they relate.

Anyone with Claude Code installed can run this plan. Two tests also need a GitHub project where you can create issues.

The final group holds a single test that briefly uninstalls and reinstalls the Han plugins. Because of that, run it
last.

Start at the top. The first two tests confirm the install and the command list that every later test relies on.

## Tests at a Glance

### Installing the plugins

- **Installing the full Han suite**: installing the main plugin brings in all eight bundled plugins, including the three new ones.
- **Finding the new and moved commands**: the command list shows every command under its new home, and the retired names are gone.

### Planning tests by hand

- **Creating a manual test plan**: the new manual test planning command produces a plain-language plan a person can follow.
- **Asking for a manual test plan with nothing to test by hand**: the command says so and asks for more, instead of writing a plan.
- **Getting an organized plan when there are many tests**: a plan holding more than five tests is organized into named groups.

### Working with plans and documents

- **Getting a code overview that lists its sources**: a code overview now lists everything it drew on, right after explaining why the code exists.
- **Breaking a plan into plain-language work items**: each work item leads with a plain summary and ends with its acceptance criteria.
- **Turning work items into GitHub issues**: published issues keep the same plain-first shape.
- **Rewriting a rough document for readability**: the new rewrite command makes a document clearer without losing any fact.
- **Getting a smaller planning team by default**: the implementation planning command now works with a smaller team, and describes it by the number of specialists it picked.
- **Getting a smaller plan review team**: the plan review command now picks fewer specialists at each size, on its own scale.

### Keeping planning inside its boundary

- **Recording what a plan is allowed to cover**: a planning run writes down the boundary it is working inside, and confirms it with you before asking anything else.
- **Being asked one question at a time**: a planning interview asks a single question per turn and waits for your answer.
- **Reusing a boundary an earlier run recorded**: a later planning command reads the recorded boundary instead of asking you again.
- **Seeing why each work item exists**: every work item names what it descends from.
- **Seeing what was set aside as out of scope**: work nobody can trace back to the boundary goes in a visible cut list, in the file and in the closing summary.
- **Setting aside scope that came from the specification**: the implementation planning command cuts commitments the original request never asked for.
- **Justifying each phase of a build**: every phase in a phased build names what it descends from, and scope cuts are kept apart from deferrals.

### Keeping design pictures with the plan

- **Keeping the design pictures you supply**: pictures you hand to a planning run are saved beside the plan under names that say what they show.
- **Supplying design pictures that are not PNG files**: JPG, GIF, WEBP, SVG, and PDF files are accepted alongside PNG.
- **Catching a design picture that has gone missing**: a run whose record lists a picture that is no longer there names it instead of finishing quietly.
- **Publishing issues that show your design pictures**: issues display the pictures, whatever their file type, and link a PDF rather than embedding it.

### Configuring a project

- **Choosing where Han writes its documents**: a project configuration file sends Han's documents to a folder you choose.
- **Ignoring a broken configuration setting**: a bad configuration setting never fails a run; it is set aside with a one-line note.
- **Setting a standing team size**: a configured team size makes the bigger review commands start at that size and credit the configuration.
- **Overriding the standing team size for one run**: a size given on the command itself wins over the configured one.
- **Ignoring a broken team size setting**: a team size Han does not recognize is set aside with a one-line note, and the command sizes the work itself.
- **Writing in your project's own voice**: a voice guide of your own, named in the configuration file, changes the words Han uses when it rewrites a document.
- **Pointing at a voice guide that is missing**: a voice line naming a guide that cannot be found makes the run ask you which way to go, instead of quietly picking for you.
- **Keeping a pointer to the configuration file**: project discovery offers to record a pointer to the configuration file, and to remove it once the file is gone.

### Giving feedback

- **Adding to feedback you already gave today**: a second round of feedback on the same day is added to the same notes rather than skipped.
- **Being told when a publish is blocked**: a publish the environment refuses is named as a refusal, with a command you can paste yourself.

### Reading the documentation

- **Browsing the reorganized documentation**: each plugin now carries its own documentation, and the indexes link into it.
- **Reading the new configuration guide**: the shared documentation now includes a guide to the project configuration file and its four settings.
- **Reading how team sizes are chosen**: the sizing guide now covers the project-wide default and the decision behind it.

### Wrapping up

- **Installing the GitHub plugin on its own**: installing only the GitHub plugin brings along the plugins it needs to work. This test uninstalls and reinstalls the suite, so run it last.

## How to run each test

### Installing the plugins

#### Installing the full Han suite

This test verifies that installing the main Han plugin pulls in all eight bundled plugins, including the three new ones.

**Steps**

1. Open Claude Code.
2. Type `/plugin marketplace add git@github.com:testdouble/han#han-v5.0.0-alpha-1` and press enter. If the marketplace is already added, that is fine; continue.
3. Type `/plugin install han@han` and press enter. Accept any prompts.
4. Type `/plugin` and open the list of installed plugins.

**Expected outcomes**

- The list shows the `han` plugin plus eight bundled plugins: `han-communication`, `han-core`, `han-documentation`, `han-research`, `han-planning`, `han-coding`, `han-github`, and `han-reporting`.
- The three new plugins (`han-communication`, `han-documentation`, `han-research`) are present without you installing them separately.

#### Finding the new and moved commands

This test verifies that every command sits under its new home and that the retired names are gone.

**Steps**

1. Start a new Claude Code session.
2. Type `/han` and pause, so the command suggestion list appears. Scroll through the full list.

**Expected outcomes**

- The documentation commands appear under `han-documentation`: project-documentation, architectural-decision-record, and runbook.
- The research commands appear under `han-research`: research, gap-analysis, and issue-triage.
- `han-core` offers only one command: project-discovery.
- The `han-coding` commands include manual-test-planning and automated-test-planning. There is no command named plain "test-planning".
- `han-communication` offers three commands: edit-for-readability, readability-guidance, and explanation-guidance.
- None of the moved commands still appear under `han-core`.

### Planning tests by hand

#### Creating a manual test plan

This test verifies that the new manual test planning command produces a plain-language plan a person can follow by hand.

**Steps**

1. Open a project that has a recent change a person could check by hand (any project works).
2. Run `/han-coding:manual-test-planning` and describe the change you want a plan for, such as "for the changes on this branch".
3. Wait for it to finish, then open the file it names.

**Expected outcomes**

- A new document exists, and its name contains "manual-test-plan".
- The document opens with a short summary, then a list of named tests, then one section per test with numbered steps and the outcomes to expect.
- The whole document reads in plain language: no file paths, no code, no technical jargon.

#### Asking for a manual test plan with nothing to test by hand

This test verifies that the command refuses to invent tests when nothing can be checked by hand.

**Steps**

1. Start a new session in any project.
2. Run `/han-coding:manual-test-planning` and describe something no person could check by hand, such as "for an internal cleanup that changes nothing anyone can see".

**Expected outcomes**

- The command says clearly that nothing in the context can be manually tested and asks whether there is more context to consider.
- No plan document is written.

#### Getting an organized plan when there are many tests

This test verifies that a plan holding more than five tests is organized into named groups. The document you are reading is an example of the shape to expect.

**Steps**

1. Open a project with changes that mix distinct kinds of work a person could check by hand, such as new screens, settings, and documentation together, enough to fill more than five tests.
2. Run `/han-coding:manual-test-planning` and ask for a plan covering all of those changes.
3. Wait for it to finish, then open the document it writes.

**Expected outcomes**

- The plan holds more than five tests.
- The test list and the detail sections sit under the same short, plain-language group headings, in the same order, with each test under exactly one group.
- Any test that fits none of the groups sits under a final group named "Other tests", placed last. When every test fits a group, that final group does not appear.
- If the tests do not fall into at least two natural groups, the plan keeps a single flat list instead. That means the change was too narrow for groups, not that the test failed; pick a broader change and run it again.

### Working with plans and documents

#### Getting a code overview that lists its sources

This test verifies that a code overview now lists everything it drew on, so a reader can walk the same evidence.

**Steps**

1. In any project, run `/han-coding:code-overview` and name a small feature or area in plain words.
2. Wait for it to finish, then open the overview it writes.

**Expected outcomes**

- The overview explains why the code exists, what it does, how it flows, and where to start reading.
- The overview contains a section named "Context used" that lists every source it drew on, with links for the sources that can be opened.

#### Breaking a plan into plain-language work items

This test verifies that each work item now leads with a plain summary and ends with its acceptance criteria.

**Steps**

1. Open a project that already has an implementation plan the team trusts.
2. Run `/han-planning:plan-work-items` and point it at that plan.
3. Wait for it to finish, then open the work items document it writes.

**Expected outcomes**

- Each work item opens with a summary of three to five short, plain sentences with no technical wording.
- A plain-language list of the work to be done follows the summary; technical hints appear only nested underneath the plain items they belong to.
- The acceptance criteria sit near the bottom of each work item, followed by a short line naming what the item depends on.

#### Turning work items into GitHub issues

This test verifies that issues published from work items keep the same plain-first shape. It needs a GitHub project where you can create issues, and the work items document from the previous test.

**Steps**

1. In that project, run `/han-github:work-items-to-issues` and follow its prompts.
2. When it finishes, open the project's issues page on GitHub.

**Expected outcomes**

- One new issue exists per work item.
- Each issue opens with the plain-language summary, and its acceptance criteria appear near the bottom as a checklist, followed by a line naming what the issue depends on.

#### Rewriting a rough document for readability

This test verifies that the new rewrite command makes a document clearer while keeping every fact.

**Steps**

1. Pick a rough document you have on hand, such as meeting notes or a draft that buries its point. Note two or three specific facts it states.
2. Run `/han-communication:edit-for-readability` and name that document.
3. When it tells you which file it will rewrite and asks for a go-ahead, agree.
4. When it finishes, read the document again.

**Expected outcomes**

- The document now leads with its main point, its headings say what each section covers, and its sentences read shorter and plainer.
- The facts you noted in step 1 are still present with their exact meaning intact.
- The command reports what it changed and confirms the facts were preserved.

#### Getting a smaller planning team by default

This test verifies that the implementation planning command now works with a smaller team, and describes that team by the number of specialists it picked.

**Steps**

1. Open a project that already has a feature specification, or any written description of a feature to build.
2. Run `/han-planning:plan-implementation small` and point it at that description. Watch the messages at the start of the run.
3. Let the run finish.

**Expected outcomes**

- Early in the run, it announces the size it is working at and the team it will use.
- It describes the team as a number of chosen specialists rather than a total number of seats.
- At the small size it picks one specialist. Running it again at `medium` picks two, and at `large` picks three or four.

#### Getting a smaller plan review team

This test verifies that the plan review command picks fewer specialists at each size, on a scale of its own that differs from the implementation planning one.

**Steps**

1. Open a project that already has a written plan you can review.
2. Run `/han-planning:iterative-plan-review medium` and point it at that plan. Watch the messages at the start of the run.
3. Let the run finish, then run it again with `large` in place of `medium`.

**Expected outcomes**

- At medium it picks one specialist. At large it picks two.
- It describes the team as a number of chosen specialists rather than a total number of seats.
- These numbers are lower than the implementation planning command's at the same size, which is expected. The two commands run on separate scales.

### Keeping planning inside its boundary

#### Recording what a plan is allowed to cover

This test verifies that a planning run writes down the boundary it is working inside, and confirms that boundary with you before it asks anything else.

**Steps**

1. Open any project. Have a short written request on hand describing a feature you want, such as a ticket, an issue, or a couple of sentences you type yourself.
2. Run `/han-planning:plan-a-feature`, give it that request, and name the folder you want the documents written into. Naming the folder yourself keeps the run from opening with a question about where to put them.
3. Read the messages it comes back with, before answering anything beyond the folder.
4. When the run finishes, open that folder and look for a file named for the scope boundary.

**Expected outcomes**

- Before it asks any interview questions, the run restates the boundary in your own words and asks whether the things your request named are being retired, replaced, or moved away from.
- A scope boundary file exists in the plan's folder.
- That file has named sections for:
  - the work item
  - the scope it stated
  - anything it ruled out
  - any scope you added yourself
  - the direction-of-travel answer
  - the visual material received
  - where the record came from

#### Being asked one question at a time

This test verifies that a planning interview asks a single question per turn instead of stacking several into one message.

**Steps**

1. Pick a feature request with several genuinely open decisions in it, such as one that leaves the rules, the limits, or the people it serves unstated. A request the run can settle from the code on its own will not produce enough questions to watch.
2. Start a new session and run `/han-planning:plan-a-feature` with that request, naming the output folder as in the previous test.
3. Answer the opening confirmation message.
4. Work through the next five or six exchanges, reading each message before you answer it.

**Expected outcomes**

- After the opening confirmation, each message asks you one question and waits for your answer.
- Each question leads with what it affects in plain words, before any technical detail.
- The opening confirmation message is the one exception: it restates the boundary and asks the direction-of-travel question together.

#### Reusing a boundary an earlier run recorded

This test verifies that a later planning command reads the boundary an earlier run recorded instead of asking you all over again. It uses the plan folder from the previous tests.

**Steps**

1. Start a new session in the same project.
2. Run `/han-planning:plan-implementation` and point it at the specification the earlier run produced.
3. Read its opening messages.

**Expected outcomes**

- The run does not ask you to restate the boundary, and does not repeat the direction-of-travel question you already answered.
- It works from the recorded boundary and says so.

#### Seeing why each work item exists

This test verifies that every work item names what it descends from.

**Steps**

1. Run `/han-planning:plan-work-items` against an implementation plan, as in the earlier work items test.
2. When it finishes, open the work items document and read three or four items in full.

**Expected outcomes**

- Each work item carries a justification of its own, naming what that item descends from.
- The justification sits directly above the item's references, and the plain summary at the top of the item stays free of reference codes.

#### Seeing what was set aside as out of scope

This test verifies that work nobody can trace back to the boundary is cut into a visible list rather than quietly kept.

**Steps**

1. Take an implementation plan and add two or three pieces of work to it that your original request never asked for, such as an unrelated integration or a reporting screen nobody mentioned.
2. Start a new session and run `/han-planning:plan-work-items` against that plan.
3. When it finishes, read the closing message, then open the work items document and scroll to the end.

**Expected outcomes**

- The document has a section holding the work that was cut for scope. That section opens by saying what it is not, so you cannot mistake it for the list of things being put off until later.
- The closing message in the session names the cut work too, not only the file.
- Nothing your original request did ask for was cut.

#### Setting aside scope that came from the specification

This test verifies that the implementation planning command cuts commitments the original request never asked for, even when a specification carries them.

**Steps**

1. Take a feature specification and add a commitment to it that the original request never mentioned, such as an extra service to integrate with or an extra document to produce.
2. Start a new session and run `/han-planning:plan-implementation` against that specification, giving it the same original request as the work item.
3. When it finishes, read the plan it wrote and its closing message.

**Expected outcomes**

- The added commitment appears in the plan's cut list rather than in the work to be done, and the cut names the boundary it fell outside.
- The rest of the specification survives, because the specification still decides what the feature does.

#### Justifying each phase of a build

This test verifies that each phase of a phased build names what it descends from, and that scope cuts are kept apart from work deferred for later.

**Steps**

1. Run `/han-planning:plan-a-phased-build` against a feature description or plan, and state the scope you want when you invoke it.
2. When it finishes, open the phased build document and read the phases and the list of deferred phases.

**Expected outcomes**

- Each phase carries a justification line naming what it descends from.
- Work deferred under a "you are not going to need it" judgment carries the trigger that would bring it back.
- Work cut for being outside the boundary carries no such trigger, because the boundary already settled it.

### Keeping design pictures with the plan

#### Keeping the design pictures you supply

This test verifies that design pictures you hand to a planning run are saved beside the plan under names that say what they show.

**Steps**

1. Have two picture files on hand showing different screens or states of a feature, such as an empty screen and a filled-in one.
2. Run `/han-planning:plan-a-feature` with a short feature request, and supply both pictures when it asks about visual material.
3. When the run finishes, open the plan's folder and look for a folder holding the designs.
4. Open the specification the run wrote.

**Expected outcomes**

- Both pictures are saved in a designs folder beside the plan, under names describing the state each one shows rather than the name your camera or tool gave them.
- The scope boundary file lists both pictures and the state each one shows.
- The specification has a section headed "Visual Reference" listing every picture, and each picture also appears inline beside the prose describing that state.

#### Supplying design pictures that are not PNG files

This test verifies that the accepted picture types now reach past PNG.

**Steps**

1. Gather three files of different types showing parts of a feature: a JPG, an SVG or GIF, and a PDF mockup.
2. Start a new session and run `/han-planning:plan-a-feature` with a short feature request, supplying all three.
3. When the run finishes, open the designs folder beside the plan.

**Expected outcomes**

- All three files are kept, not only the JPG.
- Each one is listed in the scope boundary file with the state it shows.
- No file is refused for its type.

#### Catching a design picture that has gone missing

This test verifies that a run whose record lists a picture no longer on disk names it, rather than finishing quietly. It uses the plan folder from the previous tests.

**Steps**

1. Open the designs folder beside the plan and delete one of the picture files. Leave the scope boundary file alone, so it still lists the picture you deleted.
2. Start a new session and run `/han-planning:plan-work-items` against that plan.
3. Read the run's closing summary.

**Expected outcomes**

- The closing summary names the picture that is missing.
- The run still finishes the rest of its work.
- A note about the missing picture is also written beside the work items, so whoever picks the work up sees it without reading this conversation.

#### Publishing issues that show your design pictures

This test verifies that published issues display your pictures whatever their file type, and link a PDF rather than trying to show it inline. It needs a GitHub project where you can create issues.

**Steps**

1. Restore the picture you deleted in the previous test, so the designs folder is complete again.
2. Run `/han-planning:plan-work-items` so the work items reference the pictures.
3. Run `/han-github:work-items-to-issues` and follow its prompts.
4. Open the project's issues page on GitHub and open an issue that references a picture.

**Expected outcomes**

- The JPG and PNG pictures display in the issue rather than showing as broken images.
- The PDF appears as a link you can click, not as an embedded image.
- No picture is skipped for its file type.

### Configuring a project

#### Choosing where Han writes its documents

This test verifies that a project configuration file sends Han's documents to a folder you choose.

**Steps**

1. Open a real project you can make changes in, one that holds actual code, not an empty folder. At its top level, create a folder named `.han`, and inside it a file named `config.md`.
2. Put these three lines in the file, exactly as shown:

   ```
   ---
   output-directory: docs/han
   ---
   ```

3. Start a new Claude Code session in that project.
4. Run `/han-coding:manual-test-planning` and describe a small change a person could check by hand. Wait for it to finish.

**Expected outcomes**

- The plan document is written inside the `docs/han` folder, which is created if it did not exist.
- The run says nothing about the configuration.

#### Ignoring a broken configuration setting

This test verifies that a bad configuration setting never fails a run. It follows on from the previous test and uses the same project and configuration file.

**Steps**

1. Edit the configuration file and change its folder line to point outside the project: `output-directory: ../elsewhere`.
2. Start a new session and run the same planning command again, with the same description. Wait for it to finish.

**Expected outcomes**

- The run completes normally.
- A one-line note says the folder setting was set aside and why.
- The new plan document lands in the folder you ran the command from, not outside the project.

#### Setting a standing team size

This test verifies that a configured team size makes the bigger review commands start at that size and credit the configuration. It uses the same project and configuration file as the previous tests.

**Steps**

1. Edit the configuration file: change the folder line back to point inside the project, and add a team size line below it, so the file reads:

   ```
   ---
   output-directory: docs/han
   default-swarm-size: small
   ---
   ```

2. Start a new session in that project.
3. Run `/han-coding:code-review` and point it at a recent change. Watch the messages at the start of the run.

**Expected outcomes**

- Early in the run, it announces it is working at the small size and names the project configuration as the source.
- The review completes normally.

#### Overriding the standing team size for one run

This test verifies that a size given on the command itself wins over the configured one. It uses the same project and configuration file as the previous test.

**Steps**

1. In the same project, run `/han-coding:code-review dynamic` and point it at the same change. Watch the messages at the start of the run.

**Expected outcomes**

- The run chooses its own size from the work in front of it and announces that size without crediting the configuration.

#### Ignoring a broken team size setting

This test verifies that a team size Han does not recognize is set aside without failing the run. It uses the same project and configuration file as the previous test.

**Steps**

1. Edit the configuration file and change the team size line to a value Han does not know: `default-swarm-size: enormous`.
2. Start a new session and run `/han-coding:code-review` again, with no size, pointed at the same change.

**Expected outcomes**

- The run completes normally.
- A one-line note says the team size setting was set aside.
- The run chooses its own size from the work in front of it.

#### Writing in your project's own voice

This test verifies that a voice guide of your own, named in the configuration file, changes the words Han uses when it
rewrites a document. It uses the same project and configuration file as the previous tests.

**Steps**

1. In the project, create a short voice guide as a document named `our-voice.md` inside the `docs` folder. Under a
   heading named "Avoided words and phrases", give it two swap rules you can spot on sight. The first: never write
   "document"; write "write-up" instead. The second: never address the reader as "you"; address them as "team"
   instead.
2. Edit the configuration file so it reads:

   ```
   ---
   output-directory: docs/han
   default-swarm-size: small
   writing-voice: docs/our-voice.md
   ---
   ```

3. Write a short rough paragraph that buries its point, addresses the reader as "you" at least once, and uses the
   word "document" at least once. Save it as a document in the project.
4. Start a new session. Run `/han-communication:edit-for-readability` and name the rough document. When it tells you
   which file it will rewrite and asks for a go-ahead, agree.
5. When it finishes, read the rewritten document.

**Expected outcomes**

- The rewritten document follows your swap rules: it says "write-up" where the old text said "document", and it
  addresses the reader as "team" instead of "you".
- The run completes normally, with no note about the configuration's voice line.

#### Pointing at a voice guide that is missing

This test verifies that a voice line naming a guide that cannot be found makes the run ask you which way to go,
instead of quietly picking for you. It uses the same project and configuration file as the previous test.

**Steps**

1. Edit the configuration file and change its voice line to name a guide that does not exist:
   `writing-voice: docs/no-such-voice.md`.
2. Start a new session. Run `/han-communication:edit-for-readability` on the document from the previous test.
3. When the run warns you that the voice guide was not found and asks how to proceed, choose the built-in voice.
4. When it tells you which file it will rewrite and asks for a go-ahead, agree.

**Expected outcomes**

- The run warns you that the configured voice guide was not found, and asks whether to use the built-in voice or skip
  the writing voice for this run.
- After you choose, the rewrite completes normally.

#### Keeping a pointer to the configuration file

This test verifies that project discovery offers to record a pointer to the configuration file, and to remove that pointer once the file is gone. It uses the same project as the previous tests, and it cleans up the configuration file at the end.

**Steps**

1. Run `/han-core:project-discovery` in that project. When it offers to add a pointer to the configuration file in the project's instructions file, accept.
2. Open the project's instructions file (the AGENTS.md or CLAUDE.md file at the top of the project) and look near the project discovery section.
3. Delete the `.han` folder and the configuration file inside it.
4. Run `/han-core:project-discovery` again. When it offers to remove the stale pointer, accept.
5. Open the project's instructions file again.

**Expected outcomes**

- After step 1, the instructions file contains a one-line pointer to the configuration file.
- After step 4, that pointer line is gone.

### Giving feedback

#### Adding to feedback you already gave today

This test verifies that a second round of feedback on the same day is added to the notes you already have, rather than skipped.

**Steps**

1. In any project, run a Han command such as `/han-coding:code-overview` and let it finish.
2. Run `/han-feedback:han-feedback` and give it a short piece of feedback about that command. Note the file it names.
3. In the same session, run another Han command and let it finish.
4. Run `/han-feedback:han-feedback` again and give it feedback about the second command.
5. Open the file from step 2.

**Expected outcomes**

- The second run reports the same file as the first, and says what it added.
- The file holds both pieces of feedback, with the first one still intact.

#### Being told when a publish is blocked

This test verifies that a publish the environment refuses is described as a refusal by the environment, with a command you can run yourself.

**Steps**

1. Start a session in an environment where Han cannot reach GitHub, such as one with no network access or with GitHub commands not permitted.
2. Run `/han-feedback:han-feedback`, give a short piece of feedback, and agree when it offers to publish the feedback as an issue.
3. Read what it reports.

**Expected outcomes**

- It says plainly that the environment refused the publish, rather than that it decided not to publish.
- It gives you the complete command to run yourself, already filled in, with nothing left to substitute.
- It does not retry the same command over and over.

### Reading the documentation

#### Browsing the reorganized documentation

This test verifies that each plugin now carries its own documentation and the shared indexes link into it.

**Steps**

1. Open the Han project page on GitHub in a browser.
2. Open three plugin folders, such as the coding, research, and documentation ones, and open the README inside each.
3. Go to the shared documentation folder, open the skills index and the agents index, and click five entries across them.

**Expected outcomes**

- Each plugin folder has its own README with a one-line description of every skill it carries.
- Every index entry you click opens a full page for that skill or agent, and that page lives inside its plugin's own folder. None of the clicked links is broken.

#### Reading the new configuration guide

This test verifies that the shared documentation now includes a guide to the project configuration file and its four settings.

**Steps**

1. On the Han project page on GitHub, go to the shared documentation folder and open the configuration guide.

**Expected outcomes**

- The guide explains the optional project configuration file. It covers all four settings:
  - where Han writes its documents
  - the standing team size for the bigger review commands
  - the writing voice its documents follow
  - extra agents for Han to consider
- The guide includes a full example of the file you can copy from.

#### Reading how team sizes are chosen

This test verifies that the sizing guide now covers the project-wide default and the decision behind it.

**Steps**

1. On the Han project page on GitHub, go to the shared documentation folder and open the sizing guide.

**Expected outcomes**

- The guide explains that a project can set a standing default team size in the project configuration file. It also explains that a size given on the command itself always wins over that default.
- The guide links to a decision record that explains why the project-wide default was added.

### Wrapping up

#### Installing the GitHub plugin on its own

This test verifies that installing only the GitHub plugin brings along the plugins it needs to work. It briefly removes the Han plugins, so run it last, after every other test in this plan.

**Steps**

1. Type `/plugin`, and uninstall every Han plugin in the list.
2. Type `/plugin install han-github@han` and press enter. Accept any prompts.
3. Type `/plugin` and open the list of installed plugins.
4. When you have checked the list, reinstall the full suite: type `/plugin install han@han` and press enter.

**Expected outcomes**

- After step 3, the list shows `han-github` plus the plugins it needs: `han-communication`, `han-core`, and `han-coding`, none of which you installed separately.
