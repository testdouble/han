# Why Solo and Small Teams, and Not Large Teams or Enterprise?

*Audience: developers and engineering leaders evaluating Han for any team size. Time to read: about two minutes. Outcome: decide whether Han fits your situation, or stop here.*

> **Short answer.** Han is a Claude Code plugin that gives a single engineer the specialist coverage of a team. It does not give a team the shared lift of an enterprise AI platform. If you need centralized governance, shared prompts across developers, indexed org knowledge, or audited AI usage at org scale, Han is not your tool. Bolting those things on later will cost more than starting with a product that includes them. If you are a solo engineer or a small team that needs specialist coverage you do not have headcount for, Han is built for you.

The rest of this page expands both halves of that answer so you can self-select with confidence.

## What Han gives a small team

Han acts as a full team on its own. On a solo or small team, you do not have:

- a dedicated security engineer down the hall
- a DevOps engineer to argue with about rollout safety
- an on-call engineer to push back on a hot code path
- a data engineer to scrutinize the schema
- a UX designer to flag a confusing flow
- an information architect to question the docs structure
- a junior generalist to ask the dumb-but-important questions
- a project manager to keep the discussion honest

You have you. The work that a larger team would distribute across those roles still needs to get done, and on a small team it lands on whoever has the cycles.

Han's specialist sub-agents are built to fill those role gaps.

When you run [`/code-review`](./skills/han-coding/code-review.md), the skill dispatches [`adversarial-security-analyst`](./agents/han-core/adversarial-security-analyst.md), [`devops-engineer`](./agents/han-core/devops-engineer.md), [`on-call-engineer`](./agents/han-core/on-call-engineer.md), [`data-engineer`](./agents/han-core/data-engineer.md), [`test-engineer`](./agents/han-core/test-engineer.md), and [`edge-case-explorer`](./agents/han-core/edge-case-explorer.md) at the size of your branch. It also dispatches the [`structural-analyst`](./agents/han-core/structural-analyst.md), [`behavioral-analyst`](./agents/han-core/behavioral-analyst.md), and [`concurrency-analyst`](./agents/han-core/concurrency-analyst.md). Each one reads the changes from its own perspective and surfaces findings.

When you run [`/plan-a-feature`](./skills/han-planning/plan-a-feature.md), [`project-manager`](./agents/han-core/project-manager.md) runs the discussion, [`junior-developer`](./agents/han-core/junior-developer.md) stress-tests the assumptions, and three to five specialists chosen by what the feature touches push back on the design.

When you run [`/investigate`](./skills/han-coding/investigate.md), [`evidence-based-investigator`](./agents/han-core/evidence-based-investigator.md) gathers the facts and [`adversarial-validator`](./agents/han-core/adversarial-validator.md) argues that the proposed fix will not fix the bug.

The value lands hardest where there is no one else in the room to push back. A senior engineer at a small startup writing the auth path does not have a security review pipeline waiting. A solo founder shipping a feature does not have a project manager interrupting to ask which decision is being deferred. Han puts those voices into the room.

Read [Concepts](./concepts.md) for the skill-and-agent model, and the [Quickstart](./quickstart.md) or the [how-to guides](./how-to/README.md) for what running these specialists looks like.

## What Han does not give a large team or enterprise

There is intentionally no org-level lift on the output of Han. Han does not ship a server component, a shared knowledge base, a central prompt registry, a governance console, or any enterprise integration for sharing improvements across teams. The output of every skill lands in your working copy and, if you commit, in your repo's git history. That is the whole distribution surface.

This is a deliberate scope choice, not a missing feature. Han is a personal project with best-effort maintenance and no SLA (see the [README](../README.md#maintenance-and-support) for the full posture). Adding a server component, a shared registry, or a governance console would mean building an org-level operations surface that the project is not staffed to run. The value Han targets lands in the engineer's working copy by design, where the engineer remains the decision-maker on what to commit.

### The categories of org-level lift

Enterprise AI tooling in 2025 and 2026 is built around several distinct kinds of org-level lift. The [enterprise AI tooling integration research](./research/enterprise-ai-tooling-integration.md) is the canonical source for this category set. Han provides none of these out of the box:

- **Governance and audit.** A centralized control plane for AI usage: seat management, spend controls, policy enforcement, audit logs, compliance APIs. The clearest enterprise-versus-consumer line.
- **Prompt registries.** An admin writes behavioral instructions once, and developers across the org inherit them automatically in the surfaces the product covers.
- **Org retrieval.** A curated corpus of internal docs, code, and runbooks that AI tools query at the moment of use, so responses ground in what the org knows.
- **Model customization.** Proprietary code tailors model behavior so suggestions match org naming, idioms, and internal APIs.
- **Shared MCP.** An org-hosted Model Context Protocol server exposes internal knowledge to any MCP-compatible AI client. Vendor-neutral, infrastructure-owned by the org.
- **PR-layer review.** AI integrates at the version control workflow rather than the editor, providing cross-repo consistency and pattern enforcement at the merge gate.

### Three examples

Three concrete examples make the shape of org-level lift easier to see. The research report is the canonical source for these; each example here carries the same evidence framing the research applies.

**GitHub Copilot Enterprise organization custom instructions.** As of April 2026, generally available. An org admin writes behavioral instructions once in the GitHub admin panel. Every Copilot Chat conversation on github.com, every Copilot code review, and every Copilot cloud agent run inherits them automatically. As of GA the instructions cover github.com surfaces only (Copilot Chat on github.com, Copilot code review), not Copilot in editors like VS Code. The shape of the lift is one admin writing once, with the result propagating to all developers in the org without any developer action.

**Anthropic Claude Enterprise governance and compliance.** Per Anthropic's own product pages, Claude Enterprise bundles Claude Code and Claude Cowork under a single agreement with workforce-wide deployment, SSO and identity-provider integration, and configurable data retention. That agreement also includes audit infrastructure and policy enforcement covering tool permissions and MCP server configurations across all Claude Code users. It also includes a Compliance API providing programmatic access to conversation content and activity event logs. The shape of the lift is IT and security having a control plane over AI usage that is visible, auditable, and policy-bounded across the org.

**Org-hosted MCP context servers.** An organization can stand up a Model Context Protocol server exposing internal documentation, code search, runbooks, and ticketing. Any MCP-compatible AI client (Claude Code, Cursor, GitHub Copilot, and others) consumes it. This is the only category that is vendor-neutral: an org's investment is not stranded if the AI tooling changes. It is also the category most directly relevant to Han's audience, because MCP is a first-class deployment primitive in the Claude Code plugin system Han runs on. The shape of the lift is the org owning the index, the access controls, and the update cadence rather than delegating those to a vendor.

The research report covers three more categories (prompt registries beyond Copilot, org retrieval, model customization, PR-layer review) with named products for each. If your org's AI lift looks different than these three examples, read the report.

### What this means for your evaluation

Han does not provide any of these capabilities. Han runs in your single Claude Code session, writes to your working copy, and stops there. The improvements you make to a Han skill on your machine do not propagate to anyone else's machine. The agents Han dispatches do not consult a shared knowledge base of your org's prior decisions. There is no audit log of Han runs you can hand to IT. There is no admin panel where someone in your security team approves which Han skills your developers may invoke.

You can integrate Han into something that does that lift. A larger team or an enterprise can wrap Han's output in their own review and distribution pipeline, fork the skills into an internal Claude Code plugin marketplace, or invest in a separate org-level layer that runs alongside Han. None of that comes with Han, and adding it is not on the roadmap.

> **If Han is not your fit.** If you need centralized governance, shared prompts across developers, indexed org knowledge, or audited AI usage across many developers, Han is not that product. Bolting those things on later will cost more than starting with a product that includes them. The [enterprise AI tooling integration research](./research/enterprise-ai-tooling-integration.md) names the categories and example vendors you will want to evaluate.
>
> **If Han is your fit.** Decide what to install with [Choosing a Han plugin](./choosing-a-han-plugin.md), then continue with [Concepts](./concepts.md) or the [Quickstart](./quickstart.md).

## Where to go next

- **Read the model.** [Concepts](./concepts.md) walks through the skill-and-agent architecture that runs through the whole plugin.
- **Pick a starting skill.** [Quickstart](./quickstart.md) lists five common situations and the skill sequence that fits each.
- **Run a full workflow.** [How-to guides](./how-to/README.md) walks planning, bug triage, and research end to end.
- **Concluded Han is not your fit?** The [enterprise AI tooling integration research](./research/enterprise-ai-tooling-integration.md) names the vendors and categories worth evaluating instead.
