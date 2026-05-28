# adversarial-security-analyst

Operator documentation for the `adversarial-security-analyst` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`plugin/agents/adversarial-security-analyst.md`](../../plugin/agents/adversarial-security-analyst.md).

> See also: [Plugin landing page](../../README.md) · [All agents](./README.md) · [All skills](../skills/README.md)

## TL;DR

- **What it does.** Adversarial security analysis of first-party code and dependencies. Proves real vulnerabilities exist with file-level evidence and demonstrated exploit paths. Never reports theoretical risks.
- **When to dispatch it.** A change touches auth, input handling, isolation, crypto, uploads, or SQL/ORM, and you want exploit-path findings rather than CWE checklists. Always dispatched by `/code-review`.
- **What you get back.** A `security-analysis.md` file with `SEC-###` findings, each tagged with OWASP category, file:line location, exact code snippet, and a step-by-step exploit description. Plus an in-channel summary with severity counts.

## Key concepts

- **Default stance: every system is insecure until proven otherwise.** The agent assumes all code is vulnerable, all PII leaks, and the attack surface is wider than it looks. The work is to *prove* exploitability, not catalog the absence of risk.
- **Evidence standard is non-negotiable.** First-party findings require `file_path:line_number` plus a step-by-step exploit path. Dependency findings require a CVE or known-vulnerability reference matched against the exact version in the lock file. If the standard cannot be met, no finding is reported.
- **OWASP Top 10 sweep, then four attack-angle protocols.** The agent walks all ten OWASP categories explicitly (clearing each with a one-line note when no finding applies) then runs four cross-cutting protocols: input-to-sink tracing, auth/authz decision audit, secret and PII pattern search, and dependency vulnerability check.
- **Framework-handled false-positives are excluded.** When the project's framework provides default protection for a vulnerability class (CSRF tokens, parameterized queries via ORM, automatic XSS escaping), the agent verifies the protection is in place rather than flagging the category.
- **Severity bands.** Critical (proven exploit, sensitive data at risk), High (proven exploit, limited blast radius), Medium (proven exploit, low blast radius). No Low severity. If it doesn't rise to Medium, it isn't a security finding.

## When to use it

**Dispatch when:**

- A branch or PR touches authentication, authorization, session management, input handling, file uploads, deserialization, crypto, secrets, or SQL / ORM queries.
- A change introduces new dependencies, especially those handling untrusted input.
- A code review is running and security is in scope (`/code-review` always dispatches this agent).
- You want a second opinion on a security-sensitive change independent of code review.
- A new endpoint or API surface is being added and you want exploit-path coverage of the OWASP Top 10 before merge.
- A dependency bump is in scope and you want a CVE check against the new version.

**Do not dispatch for:**

- General code quality review. Use `/code-review` (which includes this agent) for full correctness, style, and compliance coverage.
- Production readiness or operational security (rotation, scoping, detection, blast radius at runtime). Use `devops-engineer`.
- Data-level governance, schema-level PII handling, encryption at rest. Use `data-engineer`.
- Bug investigation that does not center on a security vulnerability. Use `evidence-based-investigator` or `/investigate`.
- Architectural analysis of authorization design. Use `/architectural-analysis` and `software-architect` for the design; this agent finds exploits in the implementation.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han:adversarial-security-analyst`. Give it:

1. **A list of files to analyze.** The narrower the scope, the sharper the findings. The agent reads the files plus all dependency manifests it can find in the project.
2. **A branch name, optional.** Helps the agent contextualize what changed.
3. **An output path, optional.** Default filename is `security-analysis.md`. The agent writes the full report to disk and returns only a summary.

Example prompts:

- *"Audit the new auth endpoints in `src/auth/` for OWASP Top 10 coverage. The branch adds OAuth state validation and a password-reset flow."*
- *"Review `src/api/uploads.ts` and `src/api/share.ts` for input-to-sink risks. These accept user-supplied files and URLs respectively."*
- *"Check the dependency manifest after the latest `npm install`. We bumped `axios`, `express`, and `jsonwebtoken`."*

## What you get back

- An in-channel summary: a 1–3 sentence security posture, a severity count table (Critical / High / Medium), and the path to the full report.
- A `security-analysis.md` file on disk with:
  - **Scope.** Files and dependency manifests analyzed. Branch name if provided.
  - **Summary.** Identical to what was returned to the caller.
  - **Findings.** For each OWASP category and attack-angle protocol, either a `SEC-NNN` finding or a category-clear line. Each finding includes OWASP category, `file_path:line_number`, exact code snippet, an `EXPLOIT:` field with a step-by-step attack sequence, and a severity band.
  - **Security Improvement Summary.** What was found, how to improve (numbered remediations tied to `SEC-###` findings), and how to prevent this class of issue going forward.

Every finding traces to either a file/line/exploit-path block (first-party) or a CVE reference matched to a version in the lock file (dependency). No exceptions.

## How to get the most out of it

- **Name the surface concretely.** *"The new password-reset flow"* beats *"the auth changes."* Specific scope produces specific exploit paths.
- **Drop in the lock file path** if you want dependency findings prioritized. The agent reads the lock file to pin versions before checking CVEs.
- **Pair with `data-engineer`** on regulated-data changes. The security analyst hunts exploits in the access layer; `data-engineer` audits data-level governance (encryption, retention, row-level security).
- **Pair with `devops-engineer`** when the change touches secrets, rotation, or detection. The security analyst finds the exploit. `devops-engineer` validates the operational posture that catches it.
- **Read the EXPLOIT field on every finding.** It is the test: if the exploit path is convincing, the finding is real. If you can't follow it, push back and ask for clarification.
- **Re-run after fixes.** The agent is designed for fast re-dispatch. Fix the findings, run again, confirm the count drops.

## Cost and latency

The agent runs on `opus` because the synthesis (input-to-sink tracing across a codebase, OWASP-category sweep, dependency CVE matching) is multi-dimensional and judgment-heavy. A single audit of a focused scope runs in a few minutes. Avoid dispatching it in parallel for the same surface or in tight loops over every file in a large repo. Scope tightly to what changed.

## Sources

The agent's principles and vocabulary are grounded in established application-security practice.

### OWASP Top 10 (2021, 2025)

The OWASP Top 10 is the industry-standard taxonomy for the most critical web application security risks. The agent walks all ten categories as a protocol and uses them as the citable principle on every finding (`OWASP: A0X — Category Name`).

URL: https://owasp.org/Top10/

### OWASP Application Security Verification Standard (ASVS)

ASVS is the deeper checklist behind the Top 10, defining specific verification requirements per category. The agent draws on ASVS when calibrating what *adequate* protection looks like for a given category, especially for crypto, session management, and authentication.

URL: https://owasp.org/www-project-application-security-verification-standard/

### CVE / NVD

The National Vulnerability Database and the broader CVE program are the citable source for dependency findings. Every dependency-vulnerability finding cites a specific CVE matched to a specific version pinned in the lock file.

URL: https://www.cve.org/

### MITRE CWE

The Common Weakness Enumeration is the taxonomy for vulnerability classes. The agent uses CWE IDs when an OWASP category is too coarse (for example, distinguishing CWE-89 SQL injection from CWE-78 OS command injection within OWASP A03).

URL: https://cwe.mitre.org/

## Related documentation

- [Plugin landing page](../../README.md). The front door.
- [Agents Index](./README.md). All 23 agents, grouped by role.
- [`/code-review`](../skills/code-review.md). The skill that always dispatches this agent for security coverage.
- [`/test-planning`](../skills/test-planning.md). Dispatches this agent for negative security test planning when the files touch auth, input handling, isolation, crypto, uploads, or SQL/ORM.
- [`devops-engineer`](./devops-engineer.md). Pair on regulated changes. Security analyst covers exploit paths. `devops-engineer` covers operational posture.
- [`data-engineer`](./data-engineer.md). Pair on regulated data. Security analyst covers exploit paths. `data-engineer` covers data-level governance.
- [`adversarial-validator`](./adversarial-validator.md). Pair when you want the security report challenged by another adversarial agent.
- [agent-domain-focus.md](../guidance/agent-building-guidelines/agent-domain-focus.md). Why this agent uses precise vocabulary and named anti-patterns.
- [agent-model-selection.md](../guidance/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier.
