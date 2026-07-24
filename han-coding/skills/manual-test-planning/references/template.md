# Manual Test Plan: {what is being tested, in a short plain-language phrase}

## Summary

<!-- The executive summary. Write 2-4 short sentences for the person who will run the tests: -->
<!-- what this plan covers, who can run it, how many tests it contains, and where to start. -->
<!-- Plain language only. No file paths, no code, no jargon. -->

{Executive summary paragraph.}

## Tests at a Glance

<!-- The high-level list of named tests, in the order to run them. One line per test: the -->
<!-- test name in bold, then one short sentence on what it verifies. Each name must match -->
<!-- its heading in Test Details exactly, so the reader can jump between them. -->

<!-- Flat layout (the plan has no categories): -->

- **{Test name}** — {one short sentence on what this test verifies}
- **{Test name}** — {...}

<!-- Categorized layout (the plan has categories): replace the flat list with one heading -->
<!-- per category, its tests listed beneath it. Category names and their order must match -->
<!-- Test Details exactly. -->

### {Category name}

- **{Test name}** — {one short sentence on what this test verifies}
- **{Test name}** — {...}

### {Category name}

- **{Test name}** — {...}

## Test Details

<!-- One section per named test, in the same order as Tests at a Glance. Each section has: -->
<!-- one sentence on what the test verifies, a numbered list of steps a person follows by -->
<!-- hand, and the expected outcome or outcomes they should observe. A test verifies one -->
<!-- outcome, or a group of related outcomes only when the exact same steps produce every -->
<!-- outcome in the group. Every step is an action the person takes through the product's -->
<!-- own surfaces. Every expected outcome is something the person can see and check. -->

<!-- Flat layout: each test is a level-three heading, as shown below. Categorized layout: -->
<!-- each category is a level-three heading and each of its tests is a level-four heading -->
<!-- beneath it, with the same one-sentence, Steps, and Expected outcomes structure. -->

### {Test name}

{One short sentence on what this test verifies.}

**Steps**

1. {An action the person takes.}
2. {The next action.}
3. {...}

**Expected outcomes**

- {What the person should see when the behavior is working.}
- {A second outcome, only when the same steps above produce it too.}
