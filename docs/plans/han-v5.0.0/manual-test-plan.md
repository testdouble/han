# Manual Test Plan: Han version 5.0.0 changes

## Summary

This plan checks the changes heading into Han version 5.0.0 by hand. Anyone with Claude Code installed can run it; one test also needs a GitHub project where you can create issues. It contains nine tests. Start at the top: the first two confirm the install and the command list that every later test relies on.

## Tests at a Glance

- **Installing the full Han suite**: installing the main plugin brings in all eight bundled plugins, including the three new ones.
- **Finding the new and moved commands**: the command list shows every command under its new home, and the retired names are gone.
- **Creating a manual test plan**: the new manual test planning command produces a plain-language plan a person can follow.
- **Asking for a manual test plan with nothing to test by hand**: the command says so and asks for more, instead of writing a plan.
- **Getting a code overview that lists its sources**: a code overview now lists everything it drew on, right after explaining why the code exists.
- **Breaking a plan into plain-language work items**: each work item leads with a plain summary and ends with its acceptance criteria.
- **Turning work items into GitHub issues**: published issues keep the same plain-first shape.
- **Rewriting a rough document for readability**: the new rewrite command makes a document clearer without losing any fact.
- **Browsing the reorganized documentation**: each plugin now carries its own documentation, and the indexes link into it.

## Test Details

### Installing the full Han suite

This test verifies that installing the main Han plugin pulls in all eight bundled plugins, including the three new ones.

**Steps**

1. Open Claude Code.
2. Type `/plugin marketplace add testdouble/han` and press enter. If the marketplace is already added, that is fine; continue.
3. Type `/plugin install han@han` and press enter. Accept any prompts.
4. Type `/plugin` and open the list of installed plugins.

**Expected outcomes**

- The list shows the `han` plugin plus eight bundled plugins: `han-communication`, `han-core`, `han-documentation`, `han-research`, `han-planning`, `han-coding`, `han-github`, and `han-reporting`.
- The three new plugins (`han-communication`, `han-documentation`, `han-research`) are present without you installing them separately.

### Finding the new and moved commands

This test verifies that every command sits under its new home and that the retired names are gone.

**Steps**

1. Start a new Claude Code session.
2. Type `/han` and pause, so the command suggestion list appears. Scroll through the full list.

**Expected outcomes**

- The documentation commands appear under `han-documentation`: project-documentation, architectural-decision-record, and runbook.
- The research commands appear under `han-research`: research, gap-analysis, and issue-triage.
- `han-core` offers only one command: project-discovery.
- The `han-coding` commands include manual-test-planning and automated-test-planning. There is no command named plain "test-planning".
- `han-communication` offers two commands: edit-for-readability and readability-guidance.
- None of the moved commands still appear under `han-core`.

### Creating a manual test plan

This test verifies that the new manual test planning command produces a plain-language plan a person can follow by hand.

**Steps**

1. Open a project that has a recent change a person could check by hand (any project works).
2. Run `/han-coding:manual-test-planning` and describe the change you want a plan for, such as "for the changes on this branch".
3. Wait for it to finish, then open the file it names.

**Expected outcomes**

- A new document exists, and its name contains "manual-test-plan".
- The document opens with a short summary, then a list of named tests, then one section per test with numbered steps and the outcomes to expect.
- The whole document reads in plain language: no file paths, no code, no technical jargon.

### Asking for a manual test plan with nothing to test by hand

This test verifies that the command refuses to invent tests when nothing can be checked by hand.

**Steps**

1. Start a new session in any project.
2. Run `/han-coding:manual-test-planning` and describe something no person could check by hand, such as "for an internal cleanup that changes nothing anyone can see".

**Expected outcomes**

- The command says clearly that nothing in the context can be manually tested and asks whether there is more context to consider.
- No plan document is written.

### Getting a code overview that lists its sources

This test verifies that a code overview now lists everything it drew on, so a reader can walk the same evidence.

**Steps**

1. In any project, run `/han-coding:code-overview` and name a small feature or area in plain words.
2. Wait for it to finish, then open the overview it writes.

**Expected outcomes**

- The overview explains why the code exists, what it does, how it flows, and where to start reading.
- The overview contains a section named "Context used" that lists every source it drew on, with links for the sources that can be opened.

### Breaking a plan into plain-language work items

This test verifies that each work item now leads with a plain summary and ends with its acceptance criteria.

**Steps**

1. Open a project that already has an implementation plan the team trusts.
2. Run `/han-planning:plan-work-items` and point it at that plan.
3. Wait for it to finish, then open the work items document it writes.

**Expected outcomes**

- Each work item opens with a summary of three to five short, plain sentences with no technical wording.
- A plain-language list of the work to be done follows the summary; technical hints appear only nested underneath the plain items they belong to.
- The acceptance criteria sit at the bottom of each work item, immediately before a short line naming what the item depends on.

### Turning work items into GitHub issues

This test verifies that issues published from work items keep the same plain-first shape. It needs a GitHub project where you can create issues, and the work items document from the previous test.

**Steps**

1. In that project, run `/han-github:work-items-to-issues` and follow its prompts.
2. When it finishes, open the project's issues page on GitHub.

**Expected outcomes**

- One new issue exists per work item.
- Each issue opens with the plain-language summary, and its acceptance criteria appear near the bottom as a checklist, followed by a line naming what the issue depends on.

### Rewriting a rough document for readability

This test verifies that the new rewrite command makes a document clearer while keeping every fact.

**Steps**

1. Pick a rough document you have on hand, such as meeting notes or a draft that buries its point. Note two or three specific facts it states.
2. Run `/han-communication:edit-for-readability` and name that document.
3. When it finishes, read the document again.

**Expected outcomes**

- The document now leads with its main point, its headings say what each section covers, and its sentences read shorter and plainer.
- The facts you noted in step 1 are still present with their exact meaning intact.
- The command reports what it changed and confirms the facts were preserved.

### Browsing the reorganized documentation

This test verifies that each plugin now carries its own documentation and the shared indexes link into it.

**Steps**

1. Open the Han project page on GitHub in a browser.
2. Open three plugin folders, such as the coding, research, and documentation ones, and open the README inside each.
3. Go to the shared documentation folder, open the skills index and the agents index, and click five entries across them.

**Expected outcomes**

- Each plugin folder has its own README with a one-line description of every skill it carries.
- Every index entry you click opens a full page for that skill or agent that lives inside its plugin's own folder, and none of the clicked links is broken.
