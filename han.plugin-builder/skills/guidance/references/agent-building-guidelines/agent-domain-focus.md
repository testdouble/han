---
paths:
  - "**/agents/**/*.md"
---

# Domain Focus in Agent Definitions

Agents perform better when they target a narrow domain with precise vocabulary. A focused agent activates deep expertise in the model. A broad generalist activates shallow, averaged knowledge across competing domains.

## Why Domain Focus Matters

### Vocabulary Routing

LLMs organize knowledge in embedding clusters activated by specific terminology. When an agent definition uses precise domain vocabulary (the terms a 15-year practitioner would use with peers) the model routes to expert-level training data. Generic language (*"review this code for issues"*) routes to introductory material and blog posts.

This is the **15-year practitioner test**: for every key term in the agent definition, ask whether a senior domain expert would use that exact term in conversation with another expert. If not, the term is too generic and the model will activate shallow knowledge.

### Persona Length and Attention

Research indicates that accuracy degrades with elaborate persona descriptions. The optimal range for the Role Identity (the "You are a..." opening paragraph in the agent body) is **under 50 tokens**. This is enough context to route to the right domain without wasting attention on self-description rather than task performance.

The frontmatter `description` field is separate from the Role Identity. It is triggering metadata that tells Claude when to spawn the agent, and is not subject to the 50-token budget. It has its own length budget, because it is always-loaded for routing: see [Agent Description Length](./agent-description-length.md).

Detailed protocols, checklists, anti-patterns, and procedures that follow the Role Identity do not count toward this budget. They provide operational depth, not identity framing.

### Self-Evaluation Bias

Agents cannot reliably evaluate their own work. Generator biases replicate in evaluation, creating systematic blind spots. This means a single agent should not both generate output and evaluate it. Separate agents with fresh perspectives catch what originators miss.

An agent should have a single role: generate **or** evaluate, not both.

## Implementation

### 1. Write a Clear Frontmatter Description

The `description` field in frontmatter is triggering metadata. It tells Claude when to spawn the agent. It is **not** the agent's persona and is **not** subject to the 50-token budget. It does, however, have its own length budget, because every agent description is loaded into context in every session for routing: target 1024 characters and keep domain vocabulary and anti-pattern lists in the body, not the description. See [Agent Description Length](./agent-description-length.md). The description should clearly state what the agent does and when to invoke it.

**Example:**
```yaml
description: "Research analyst for gathering, evaluating, and synthesizing
  information from multiple sources into evidence-based research briefs.
  Invoke when a task requires systematic information gathering, source
  credibility assessment, or triangulation of findings."
```

This description is well over 50 tokens, and that is fine. Its job is to help Claude decide when to use the agent, not to set the model's persona. It is still bound by the description length budget, though: keep it near 1024 characters and push domain vocabulary and anti-pattern detail into the body sections below. See [Agent Description Length](./agent-description-length.md).

### 2. Write a Concise Role Identity (Under 50 Tokens)

The Role Identity is the opening "You are a..." paragraph in the agent body. This is the persona statement that routes the model to expert-level knowledge. Keep it **under 50 tokens**. State the domain, the task, and the perspective, nothing more.

Some agents use a formal `## Role Identity` heading for this section. Others place it as the opening paragraph of the body. Both patterns work.

**Before (78 tokens):**
```markdown
You are an incredibly talented and experienced senior security engineer
who has spent decades reviewing code for vulnerabilities. You have deep
expertise in OWASP, penetration testing, and secure coding practices.
Your reviews are thorough, precise, and always actionable.
```

**After (22 tokens):**
```markdown
You are a senior application security engineer. Your job is to identify
exploitable vulnerabilities in code changes.
```

The "after" version uses precise domain vocabulary ("application security engineer," "exploitable vulnerabilities") that routes to expert knowledge, without flattery or filler.

### 3. Include a Domain Vocabulary Section

Agent definitions should include an explicit section listing 15-30 domain-specific terms. These terms activate expert-level embedding clusters and make the agent's domain scope explicit and auditable.

**Example for a security review agent:**
```markdown
## Domain Vocabulary

injection (SQL, XSS, command), authentication bypass, authorization
escalation, CSRF, SSRF, insecure deserialization, path traversal,
secrets exposure, timing side-channel, input validation boundary,
trust boundary crossing, defense in depth, least privilege violation,
cryptographic misuse, session fixation, open redirect, IDOR
```

**Example for a performance analysis agent:**
```markdown
## Domain Vocabulary

hot path, allocation pressure, cache miss ratio, flame graph,
tail latency (p99/p999), throughput saturation, lock contention,
GC pause, memory leak, connection pool exhaustion, query plan
regression, N+1 query, index scan vs. sequential scan, event loop
blocking, thread starvation, backpressure, circuit breaker
```

Apply the 15-year practitioner test to each term: would a senior expert use this exact term with peers?

### 4. List Named Anti-Patterns with Detection Signals

Each specialist agent should list 5-10 named anti-patterns relevant to its domain. Each anti-pattern needs a name and detection signals: what to look for in the code or output.

**Example for a test engineering agent:**
```markdown
## Anti-Patterns

- **Test-the-mock**: Tests that verify mock behavior instead of real system behavior. Detection: assertions on mock call counts with no integration path.
- **Assertion-free test**: Test runs code but never asserts outcomes. Detection: test functions with no `expect`, `assert`, or equivalent.
- **Flaky time dependency**: Tests that depend on wall-clock time. Detection: `Date.now()`, `setTimeout`, or sleep-based synchronization in test code.
- **Shotgun coverage**: Many low-value tests on trivial paths, none on complex paths. Detection: high line coverage but untested error branches.
```

Anti-patterns make the agent's expertise concrete and auditable. They also prime the model to look for specific failure modes rather than generic "issues."

### 5. Avoid Flattery and Motivational Framing

Flattery and superlatives (*"you are the world's best," "your expertise is unmatched"*) activate motivational and inspirational content in the model's embeddings rather than technical expertise. They consume tokens without improving (and often degrading) output quality.

**Avoid:**
- *"You are an expert..."* / *"You are the best..."*
- *"Your analysis is always thorough and insightful"*
- *"You take pride in finding every issue"*

**Instead:** Let domain vocabulary and precise task framing do the routing work. A concise role statement with the right terminology outperforms an elaborate motivational preamble.

### 6. One Role per Agent: Generate or Evaluate

Do not ask a single agent to both produce output and judge its quality. Self-evaluation bias means the same reasoning patterns that created a blind spot will also evaluate it as correct.

**Instead:**
- Use one agent to generate (investigate, explore, draft)
- Use a separate agent to evaluate (validate, audit, challenge)

Pair a generator with a separate evaluator. For example, a generator agent that gathers evidence produces the findings, and a separate evaluator agent that challenges those findings audits them. They are separate agents with separate perspectives.

## Summary Checklist

1. Write a clear frontmatter `description` that states what the agent does and when to invoke it.
2. Keep the Role Identity under 50 tokens. State domain, task, and perspective only.
3. Include a domain vocabulary section with 15-30 precise terms that pass the 15-year practitioner test.
4. List 5-10 named anti-patterns with detection signals relevant to the agent's domain.
5. No flattery, superlatives, or motivational framing. Let vocabulary do the routing.
6. Assign a single role per agent. Generate or evaluate, not both.
7. Inline all vocabulary, anti-patterns, and protocols in the agent file (see [External File References](./agent-external-files.md)).

## Cross-References

- [Agent Description Length](./agent-description-length.md). The 1024-character budget for the always-loaded `description`, and which content has to move into the body to hit it.
- [External File References](./agent-external-files.md). All content must be inlined in the agent file. Vocabulary and anti-pattern sections are no exception.
- [Model Selection](./agent-model-selection.md). A well-specialized agent with precise vocabulary may perform well with a faster model, because domain terms activate expert knowledge even in smaller models.
- [Specialization and Model Selection](../specialization-and-model-selection.md). Evidence base for why specialization shifts work from inference-time compute to prompt-time design.
- Source: [The Specialized Review Principle](https://jdforsythe.github.io/10-principles/principles/specialized-review/). Research-backed principle on vocabulary routing, persona length, and self-evaluation bias.
