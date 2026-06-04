---
paths:
  - "**/skills/**/*.md"
---

# Writing Effective Instructions

The SKILL.md body — everything below the YAML frontmatter — is where you tell Claude *how* to execute the skill. These instructions load when the skill triggers (Level 2 in the progressive disclosure model) and guide Claude through the workflow step by step.

Poorly written instructions produce inconsistent results: Claude skips steps, misinterprets intent, or improvises when it should follow a specific process. Well-written instructions are specific, actionable, and structured so Claude can follow them reliably across sessions.

## The Rules

### Rule: Be specific and actionable

Every instruction should tell Claude exactly what to do, not vaguely gesture at an outcome. Specific instructions produce consistent results; vague instructions produce different results each time.

**Before (vague):**
```markdown
## Step 3: Validate the Data

Validate the data before proceeding.
```
Claude doesn't know *what* to validate, *how* to validate, or *what to do* if validation fails.

**After (specific):**
```markdown
## Step 3: Validate the Data

Run `python scripts/validate.py --input {filename}` to check data format.
If validation fails, common issues include:
- Missing required fields (add them to the CSV)
- Invalid date formats (use YYYY-MM-DD)
- Duplicate entries (remove or merge)
```

**Before (abstract):**
```markdown
## Step 2: Analyze Changes

Look at the changes and provide feedback.
```

**After (concrete):**
```markdown
## Step 2: Analyze Changes

For each changed file in the diff:
1. Read the full file (not just the diff) for context
2. Check against `references/review-checklist.md`
3. Classify each finding by severity: critical, warning, or suggestion
4. Include the file path and line number for each finding
```

### Rule: Write constraints with embedded reasoning

When a skill instruction prohibits or requires something, include the reason. A bare directive — "Never use X" — covers only the literal case described. A directive with reasoning — "Never use X BECAUSE Y" — lets the model generalize to analogous situations where the same reasoning applies.

Format: `Always/Never [action] BECAUSE [reason]`

**Before (bare directive):**
```markdown
## Constraints

- Never use `Array<T>` syntax
- Always use named exports
```
The model follows these literally but can't generalize. It avoids `Array<T>` but doesn't know why, so it can't apply similar reasoning to other style decisions.

**After (directive with reasoning):**
```markdown
## Constraints

- Never use `Array<T>` syntax BECAUSE the project ESLint config enforces `T[]` via the `array-type` rule — `Array<T>` triggers lint failures
- Always use named exports BECAUSE the project relies on tree-shaking, which works reliably only with named exports
```
The model understands the underlying reasons and generalizes: if lint enforcement is the concern, it checks for similar patterns; if tree-shaking is the concern, it avoids other constructs that break it.

### Rule: Include error handling in instructions

Tell Claude what to do when things go wrong. Without error handling instructions, Claude either ignores failures or invents its own recovery strategy — neither is reliable.

**Before (no error handling):**
```markdown
## Step 1: Fetch PR Metadata

Run `scripts/pr-metadata.sh` to gather PR information.
```

**After (with error handling):**
```markdown
## Step 1: Fetch PR Metadata

Run `scripts/pr-metadata.sh` to gather PR information.

If the script fails:
- Exit code 1 (no PR found): Inform the user that no PR exists for the current branch and stop
- Exit code 2 (gh CLI not authenticated): Ask the user to run `gh auth login` and stop
- Any other error: Show the error output to the user and stop
```

Error handling is especially important for steps that depend on external tools (gh CLI, APIs, MCP servers) or user-provided input.

### Rule: Prefer inline discovery over forked data-fetch sub-skills

Data-fetch sub-skills using `context: fork` can cause the calling skill to exit early. This has been observed in practice: after a forked config-reading sub-skill returns "Not found: ...", an `api_retry` event can fire and the calling model treats the sub-skill's output as its final answer, bypassing all subsequent workflow steps. Adding explicit "proceed immediately... do not stop here" wording and conventional defaults does not reliably prevent it. The `context: fork` mechanism plus explicit continuation instructions is necessary but not sufficient.

The solution is to replace forked data-fetch sub-skill calls with inline discovery: use context injection to detect config files, then read and extract values directly in the skill's own step logic. This eliminates the forked sub-skill entirely, avoiding the early-exit failure mode.

**Before (forked sub-skill — causes early exit):**
```markdown
## Step 1: Identify Changes

Call `read-project-config` via the `Skill` tool with arguments "docs directory, ADR directory, coding standards directory, test command, lint command, build command". After the Skill tool returns, proceed immediately to **Detect review context** below — do not stop here.
```

**After (inline discovery — no sub-skill call):**
```markdown
## Project Context
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Step 1: Identify Changes

Resolve project config: read CLAUDE.md's `## Project Discovery` section for docs, ADR, and coding-standards directories plus test, lint, and build commands; fall back to project-discovery.md; fall back to Glob defaults (`docs/`, `docs/adr/`, `docs/coding-standards/`). Continue without any keys that remain unfound.
```
The skill reads config files directly using Read — no forked sub-skill, no `api_retry` interaction, no early-exit risk.

This rule applies to data-fetch sub-skills that return structured values. Orchestration sub-skills (where the called skill drives the remaining output) are unaffected.

### Rule: Reference bundled resources clearly

When a step uses content from `references/` or `scripts/`, reference it by exact path and explain what the resource contains and how to use it. Don't assume Claude will discover the file's purpose on its own.

**Before (unclear reference):**
```markdown
## Step 3: Apply Standards

Check the references for the coding standard.
```

**After (clear reference):**
```markdown
## Step 3: Apply Standards

Consult `references/coding-standard.md` for:
- Naming conventions (Section 1)
- Error handling patterns (Section 2)
- Test structure requirements (Section 3)

Apply each applicable section to the code under review. Cite the section name when reporting a finding.
```

### Rule: Use progressive disclosure for instruction length

Keep the SKILL.md body focused on process steps. Move domain knowledge — templates, checklists, rate tables, decision matrices — to `references/`. This keeps the Level 2 content manageable and lets Claude load detailed knowledge only when a step needs it.

**Before (everything in SKILL.md):**
```markdown
## Step 4: Score the Proposal

Use the following scoring matrix:

| Criterion | Weight | 1 (Poor) | 2 (Fair) | 3 (Good) | 4 (Excellent) |
|-----------|--------|----------|----------|----------|----------------|
| Feasibility | 30% | No path to implementation | Major obstacles | Minor obstacles | Clear path |
| Impact | 25% | No measurable impact | Low impact | Moderate impact | High impact |
| Cost | 25% | Over budget | Near budget | Under budget | Significant savings |
| Timeline | 20% | >12 months | 6-12 months | 3-6 months | <3 months |

Calculate the weighted score for each criterion...
[40 more lines of scoring formulas and examples]
```

**After (extracted to references/):**

`references/scoring-matrix.md`:
```markdown
# Proposal Scoring Matrix
[Full matrix, formulas, and examples]
```

`SKILL.md`:
```markdown
## Step 4: Score the Proposal

Apply the scoring matrix from `references/scoring-matrix.md` to evaluate the proposal. Calculate weighted scores for each criterion and produce a final recommendation.
```

### Rule: Avoid verbose, buried, or ambiguous instructions

Three anti-patterns cause Claude to ignore or misinterpret instructions:

| Anti-pattern | Problem | Fix |
|--------------|---------|-----|
| **Too verbose** | Claude loses focus in long, repetitive prose. Key instructions drown in filler. | Use numbered lists and bullet points. Cut filler words. Say it once. |
| **Buried critical instructions** | Important rules appear mid-paragraph on step 7. Claude may not weight them appropriately. | Put critical instructions at the top of the step or in a dedicated `## Important` section. |
| **Ambiguous language** | Phrases like "validate things properly" or "make sure it's good" give Claude no actionable criteria. | Replace with specific checks: "Verify project name is non-empty and start date is not in the past." |

**Before (verbose and buried):**
```markdown
## Step 2: Review the Code

You should carefully look through all of the code changes that have been made
and try to find any issues or problems that might exist. It's really important
to be thorough and make sure you don't miss anything. You should pay special
attention to security issues. Also, don't forget to check for performance
problems too. And make sure the code follows the project's style guidelines.
One more thing — verify that all the tests pass.
```

**After (structured and direct):**
```markdown
## Step 2: Review the Code

For each changed file:
1. Check for security issues (see `references/owasp-top10.md`)
2. Check for performance problems (unnecessary loops, missing indexes, N+1 queries)
3. Verify adherence to project style guidelines
4. Confirm existing tests still pass
```

### Rule: Structure conventions as heading + one-line rule + example

When a skill's instructions define conventions the model must follow — coding standards, review criteria, documentation formats — each convention should follow a specific formula: markdown heading, one-line rule statement, 2-3 code examples. Structured formats have exactly one interpretation. Prose paragraphs that list multiple conventions require the model to infer where one instruction ends and the next begins.

**Before (conventions as prose paragraph):**
```markdown
## Step 3: Apply Review Standards

When reviewing code, make sure that error handling follows the project pattern where
all async functions use try/catch and errors are logged with context before being
re-thrown. Also check that public API functions validate their inputs at the boundary
and return typed errors rather than throwing. Finally, ensure that side effects like
network calls and file writes are explicit in function names so callers know what to expect.
```
Three conventions are buried in a single paragraph. The model must parse sentence boundaries to separate them.

**After (each convention as its own block):**
```markdown
## Step 3: Apply Review Standards

### Error handling
Async functions must use try/catch, log errors with context, and re-throw.

```typescript
// do this
async function fetchUser(id: string) {
  try {
    return await db.users.find(id);
  } catch (err) {
    logger.error('fetchUser failed', { id, err });
    throw err;
  }
}
```

### Input validation at boundaries
Public API functions must validate inputs and return typed errors, not throw.

```typescript
// do this
function createProject(name: string): Result<Project, ValidationError> {
  if (!name.trim()) return err(new ValidationError('name is required'));
  return ok(new Project(name));
}
```

### Side effects in function names
Functions with network calls or file writes must name the side effect.

```typescript
// do this:  fetchPricing(), writeSummaryToFile()
// not this: getPricing(), generateSummary()
```
```
Each convention is independently parseable: heading, rule, example.

### Rule: Include canonical examples for conventions the skill enforces

When a skill teaches or enforces patterns, include 2-3 representative "do this / not this" examples. The model pattern-matches examples more reliably than it follows abstract rules — research shows 3 well-chosen examples match 9 in effectiveness. Place the most representative example last — the model weights it more heavily. Put examples in `references/` if they are substantial (following the progressive disclosure model), or inline in SKILL.md if they are brief (1-3 lines each).

**Before (rule stated without examples):**
```markdown
## Step 4: Check Naming Conventions

Verify that all new functions follow the project's naming conventions:
- Use camelCase for functions and variables
- Use PascalCase for classes and types
- Prefix boolean variables with is/has/should
- Prefix event handlers with handle
```
The model knows the *rules* but has no demonstrations to pattern-match against.

**After (rule with canonical examples):**
```markdown
## Step 4: Check Naming Conventions

Verify that all new functions follow the project's naming conventions:

**camelCase for functions and variables:**
- `getUserById`, `totalCount`, `isValid`

**PascalCase for classes and types:**
- `UserService`, `ApiResponse`, `ValidationError`

**Prefix boolean variables with is/has/should:**
- not this: `active`, `loaded`, `visible`
- do this: `isActive`, `hasLoaded`, `isVisible`

**Prefix event handlers with handle:**
- not this: `clickSubmit`, `changeInput`
- do this: `handleSubmitClick`, `handleInputChange`
```

### Rule: Use scripts for deterministic validation

When a step requires deterministic validation — checking file formats, verifying data integrity, running calculations — use a shell script instead of asking Claude to interpret natural language instructions about what to check. Code produces consistent results; language interpretation varies.

**Before (language-based validation):**
```markdown
## Step 4: Validate the Output

Check that the generated file:
- Has valid JSON syntax
- Contains all required fields
- Has no duplicate keys
- File size is under 1MB
```

**After (script-based validation):**
```markdown
## Step 4: Validate the Output

Run `scripts/validate-output.sh {output_file}` to verify JSON syntax, required fields, duplicate keys, and file size.

If validation fails, the script prints which checks failed. Fix each issue before proceeding.
```

## Summary Checklist

1. Every instruction tells Claude exactly what to do — no vague directives
2. Error handling instructions cover what to do when steps fail
3. Reference bundled resources by exact path with explanation of contents and usage
4. Keep SKILL.md focused on process steps — extract domain knowledge to `references/`
5. Use numbered lists and bullet points — avoid long prose paragraphs
6. Put critical instructions at the top, not buried mid-step
7. Replace ambiguous language with specific, testable criteria
8. Use scripts for deterministic validation instead of language instructions
9. After Skill tool calls mid-workflow, explicitly instruct Claude to proceed immediately — never rely on implicit continuation
10. Can an agent extract every convention from this SKILL.md without ambiguity? If a section requires inference about where one instruction ends and the next begins, restructure it

Cross-references:
- [Progressive Disclosure](./progressive-disclosure.md) — The three-level architecture that determines where content belongs
- [Skill Reference Files](./skill-reference-files.md) — How to structure and place reference documents
- [Context Injection Commands](./context-injection-commands.md) — How to inject runtime data into instructions
- [Skill Composition](./skill-composition.md) — `context: fork` for data-fetch sub-skills; necessary but not sufficient for continuation
- [Context Hygiene](./context-hygiene.md) — Why conciseness is a performance concern, not just a style preference
