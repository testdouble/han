# Research: Enterprise and Org-Level Options for Integrating Shared Context, Skills, and Lifts With AI Tooling

A landscape survey of how organizations integrate shared context, prompts, skills, governance, and other org-level "lifts" with AI coding tooling, intended to inform a Han documentation article that explains what Han deliberately does not provide. Evidence mode: strict (every artifact has a checkable source; single-source claims are labeled inline).

## Summary

Enterprise AI coding tooling in 2025 and 2026 organizes around five distinct kinds of org-level lift: a governance and compliance control plane, shared prompt and instruction registries, retrieval over org knowledge and code, model customization on proprietary code, and a newer pattern of org-hosted context servers that any AI client can consume. A sixth pattern, AI-augmented code review at the pull request layer, sits alongside these as a workflow-level lift rather than a model-level one.

The recommendation for the Han documentation article is to name the governance category first because it is the most universal and the clearest enterprise-versus-consumer line, then shared prompt registries because those are the lowest-friction lift now widely available, then shared knowledge and context because that is the deeper lift most readers will recognize, with model customization, MCP-based context servers, and PR-layer AI review named as additional categories so readers in those spaces also recognize themselves. The recommendation rests on independent corroboration for the category structure, but several individual product claims rest only on vendor product pages and are labeled as such throughout. Confidence is medium; the categorical framing is solid, several individual product details are softer than they first appeared.

## Research Results

Across the products examined, the same shapes of org-level lift recur, and the same shapes are absent from the same places. The categories below are stable across multiple independent vendors. Several individual product claims, however, rest only on vendor self-description and were softened during validation.

**Shared prompt and instruction registries** are the most widely shipped form of org lift today. GitHub Copilot organization custom instructions reached general availability on 2026-04-02, letting org admins write behavioral instructions that automatically apply to Copilot Chat on github.com, Copilot code review, and the Copilot cloud agent (A1). Sourcegraph Cody Enterprise exposes site-admin-configurable prompt pre-instructions that apply org-wide (A6). Anthropic Claude Enterprise distributes policy enforcement including MCP server configurations across all Claude Code users from a central admin panel (A3, A4). One important scope qualifier: the GitHub Copilot org instructions, as of the GA announcement, cover only github.com surfaces, not Copilot in IDEs (A1) [single-source on the IDE-exclusion detail; verified against the linked configuration documentation but not independently corroborated]. A reader whose team uses Copilot primarily in VS Code will not feel this category today.

**Retrieval over org knowledge and code** is the next category. GitHub retired Copilot knowledge bases on or around 2025-11-01 in favor of Copilot Spaces, which let any Copilot user create shareable context units combining code, Markdown, issues, and pull requests, with sharing scopes at org, team, or individual level (A2) [single-source; the GitHub documentation URL originally cited returns 404 and the specific retirement date could not be verified against a living URL during validation]. Sourcegraph Cody Enterprise's multi-repo context surfaces up to ten repositories simultaneously at query time, which produces a similar outcome through query-time retrieval rather than pre-indexing (A6). Augment Code is described as building a vectorized semantic index of the org codebase that functions as institutional memory for large teams (A8) [single-source; the source is a WorkOS-authored profile of Augment Code, vendor-adjacent rather than independent reporting].

**Model customization on proprietary code** is a distinct category. Amazon Q Developer "Customizations" use proprietary org code to tailor inline code suggestions to org naming conventions, internal libraries, APIs, and architectural patterns, and "Profiles" are the access-control layer that assigns customizations to user groups via IAM Identity Center (A5). The Amazon Q FAQ describes the mechanism as adapting suggestion behavior to org-specific code rather than as retrieval, which places this in the customization category rather than the retrieval category above (A5). Tabnine describes a similar org-tailored behavior through what it calls an Enterprise Context Engine, claiming the result requires no retraining and adapts instantly to new repositories and policies (A7) [single-source; vendor blog, no independent corroboration for the no-retraining and instant-adaptation claims]. The broader 2025 and 2026 practitioner trend is a shift toward retrieval over static fine-tuning for codebases that change frequently, since fine-tuned weights are a snapshot while the codebase is not.

**Governance, compliance, and observability** is the category corroborated by the most independent products. Anthropic's Compliance API provides programmatic access to conversation content and activity event logs across Claude Code and Claude Cowork (A3, A4). GitHub's Copilot admin panel ships org-level custom instructions with no developer override path described (A1). Sourcegraph Cody Enterprise analytics track active user adoption, completion acceptance rates, chat volume, and command usage across the org, alongside public-code guardrails and IDE token expiry controls (A6). Amazon Q Developer integrates customization access with IAM Identity Center for group-based access management (A5). The presence of a governance tier is what most cleanly distinguishes an enterprise AI contract from a consumer one across every product examined. Note that the Anthropic-specific evidence rests on Anthropic's own product pages; independent third-party reporting on Claude Enterprise governance specifics was not gathered during the research, so the Claude-specific details should be read as vendor-claimed.

**MCP and context-server infrastructure** is the newest of these categories and the only one not locked to a single vendor. An org can host a single Model Context Protocol server exposing internal documentation, code search, runbooks, and ticketing, and any MCP-compatible AI client, Claude Code, Cursor, GitHub Copilot, and others, can consume it. Enterprise adoption evidence for this pattern is thinner than for the vendor-packaged categories above, but for Han's specific audience the pattern is materially more concrete: MCP is a first-class deployment primitive in the Claude Code plugin system the Han plugin runs on (A9). For a reader in the Han audience, MCP is not experimental.

**AI-augmented pull request review** is a sixth category that the original research framing missed and that validation surfaced. CodeRabbit Enterprise and Graphite operate at the version control workflow layer rather than the IDE or model layer, providing org-level consistency in code review and pattern enforcement at the pull request boundary (A10, A11). For teams whose AI integration story runs through PR review rather than IDE assistance, this is the category that names their setup. The product pages were verified to exist and serve content during validation; specific feature claims would require deeper sourcing before being used in an article.

The line between "every developer uses the same AI product" and "the org has a true lift" comes down to whether one of three things is true: a centrally authored knowledge artifact or instruction set propagates to all users, a model-level customization propagates improved behavior to all users, or governance and audit infrastructure makes AI usage visible and controllable at the org level rather than invisible individual activity. Products provide the plumbing for each; whether any org-level lift actually materializes depends on whether someone at the org invests in curation and configuration.

## Options to Consider

### O1: Shared prompt and instruction registries

- **What it is:** Org admins write behavioral instructions once, and developer sessions inherit them across the surfaces covered by the product. Covers Copilot Chat and code review on github.com (A1), Cody Enterprise queries (A6), and Claude Code policy distribution (A3).
- **Trade-offs:** Lowest-friction org lift available today. Instructions are necessarily general; cannot encode deep codebase-specific knowledge. Scope is product-defined: Copilot org instructions cover github.com but not the IDE today (A1) [single-source on the IDE exclusion]. Poor instructions degrade every developer's experience uniformly.
- **Rests on:** A1, A3, A6.
- **Evidence status:** Corroborated across A1, A3, A6 for the existence of the pattern. Single-source on the Copilot IDE scope exclusion.

### O2: Retrieval over shared knowledge and code

- **What it is:** An indexed or query-time-retrieved corpus of internal documentation, code, runbooks, and architectural artifacts grounds AI responses in org-specific knowledge.
- **Trade-offs:** Updateable without retraining, so docs added today are queryable today. Quality of retrieval depends on quality of the indexed corpus; stale or sparse internal docs produce confidently-wrong outputs. Retrieval misses unwritten conventions and tribal memory. Ongoing curation cost is real and frequently underestimated.
- **Rests on:** A2 (Copilot Spaces), A6 (Cody multi-repo context), A8 (Augment Code).
- **Evidence status:** Pattern is corroborated across A2 and A6. A2's specific 2025-11-01 retirement date is unverified [single-source]. A8 is a single vendor-adjacent source. Original research cited A5 as evidence for this category; validation moved A5 to O3 since Amazon Q customizations are model adaptation, not retrieval.

### O3: Model customization on org code

- **What it is:** Proprietary codebase content tailors model behavior so inline suggestions and completions match org naming, idioms, and internal APIs.
- **Trade-offs:** Tailored suggestions can feel native rather than retrieved, useful for large stable codebases with established idioms. Model weights or customization artifacts are a snapshot; codebases are not, so they go stale without periodic refresh. The 2025 and 2026 trend in practice is toward retrieval over static fine-tuning for fast-changing codebases.
- **Rests on:** A5 (Amazon Q Developer Customizations and Profiles), A7 (Tabnine Enterprise Context Engine).
- **Evidence status:** A5 corroborates the existence of the org-customization pattern with concrete IAM Identity Center integration. A7 is single-source vendor blog and should not be treated as independent corroboration.

### O4: Governance, compliance, and observability

- **What it is:** A centralized control plane for AI usage in the org, including seat management, spend controls, audit logs, policy enforcement, compliance APIs, and SSO and identity integration.
- **Trade-offs:** The capability that most distinguishes enterprise from consumer AI. Prerequisite for regulated industries and serious security postures. Heavy policy enforcement can throttle productivity if misconfigured. Quality and depth of audit logs and policy controls vary across products in ways not always disclosed.
- **Rests on:** A1 (GitHub admin panel and org instructions), A3 and A4 (Anthropic Compliance API and Claude Enterprise), A5 (IAM Identity Center integration for Q Developer Profiles), A6 (Cody Enterprise analytics and guardrails).
- **Evidence status:** Pattern is corroborated across A1, A3, A4, A5, A6. The Anthropic-specific governance details rest on Anthropic-authored product pages, which is the weakest possible independence; no third-party reporting on Claude Enterprise governance was located.

### O5: MCP and context-server infrastructure

- **What it is:** An org hosts a Model Context Protocol server exposing internal docs, code search, runbooks, and ticketing, and any MCP-compatible AI client consumes it. The only pattern that is not vendor-locked.
- **Trade-offs:** Vendor-neutral, so an org's investment is not stranded if AI tooling changes. The org owns the index, access controls, and update cadence. Requires infrastructure and engineering investment that vendor-packaged solutions abstract away. Enterprise MCP governance patterns (authentication, audit, multi-tenant access control) are still emerging. For the Han audience specifically, MCP is a first-class deployment primitive in the Claude Code plugin system Han runs on (A9), so the maturity caveat that applies to the broader market is narrower here.
- **Rests on:** A9 (Han's own plugin entity taxonomy documenting MCP as a recognized plugin component), supplemented by general MCP awareness in the ecosystem.
- **Evidence status:** Single-source on broader enterprise adoption claims. For Han's audience the codebase-trust evidence (A9) is solid.

### O6: AI-augmented code review at the pull request layer

- **What it is:** AI integrates at the version control workflow layer rather than the IDE or model layer, providing cross-repo consistency, pattern enforcement, and review feedback at the pull request boundary. Examples include CodeRabbit Enterprise (A10) and Graphite (A11).
- **Trade-offs:** Operates where shared org conventions are most enforceable (the merge gate) rather than where individual developers work (the editor). Org lift comes from the platform's view across PRs rather than from a shared knowledge base or fine-tuning. Less helpful for the in-IDE coding experience itself.
- **Rests on:** A10 (CodeRabbit Enterprise product surface), A11 (Graphite product surface).
- **Evidence status:** URLs verified during validation to serve content; specific feature claims would need deeper sourcing before being used as load-bearing detail.

## Recommendation

- **Recommendation:** For the documentation article use case, structure the naming around O4 governance first, O1 shared prompt registries second, and O2 retrieval over shared knowledge third, with O3, O5, and O6 named as additional categories so readers in those spaces also recognize themselves. The article should resist priority-ranking O3, O5, and O6 against each other; the audiences that recognize each are non-overlapping.
- **Evidence basis:** The priority of O4 over O1 over O2 rests on independent corroboration across multiple products for each category: O4 across A1, A3, A4, A5, A6; O1 across A1, A3, A6; O2 across A2 (single-source on specific date) and A6, with A8 as a vendor-adjacent supplement. The placement of A5 in O3 rather than O2 rests on the Amazon Q FAQ describing customization as suggestion adaptation rather than retrieval (A5). The inclusion of O6 rests on validator-confirmed product existence (A10, A11) without independent feature corroboration; the article should name the category and the example products without quoting specific feature claims. The Han-audience strength of O5 rests on codebase-trust evidence (A9). No part of this recommendation rests on unevidenced reasoning, which is the strict-mode requirement.

## Validation

### V1: Copilot org custom instructions cover github.com only, not IDEs

- **Strategy:** Challenge the Evidence
- **Investigation:** Fetched A1 changelog directly (HTTP 200). The page explicitly lists scope as "Copilot Chat on github.com, Copilot code review, Copilot cloud agent." Fetched the linked configuration documentation, which states that org custom instructions are "currently only supported for Copilot Chat on GitHub.com, Copilot code review on GitHub.com and Copilot cloud agent on GitHub.com." No IDE coverage is described.
- **Result:** Partially Refuted
- **Impact:** The O1 description carries an explicit scope qualifier. The article cannot claim Copilot org instructions reach Copilot users in editors today.

### V2: A2's corroboration chain is structurally broken

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Confirmed HTTP 404 on the originally cited GitHub documentation URL for knowledge bases. Confirmed Copilot Spaces exist via a 200 response on the Spaces documentation page. The specific 2025-11-01 knowledge base retirement date and the original A1 ↔ A2 cross-corroboration claim do not survive scrutiny: A1 is about org custom instructions, not knowledge base retirement, so the two artifacts do not corroborate each other on A2's primary claim.
- **Result:** Partially Refuted
- **Impact:** A2 is treated as single-source in the report. The retirement date is labeled unverified. The article should not state the date as fact.

### V3: A3 and A4 weakly corroborate each other; both are Anthropic-authored

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Both A3 and A4 are published by Anthropic. No independent third-party reporting on Claude Enterprise governance was located during the research. The governance features described are plausible and consistent with what enterprise SaaS routinely offers, but the corroboration is structurally same-author.
- **Result:** Partially Refuted
- **Impact:** O4 still leads on category corroboration overall (the pattern is supported across vendors), but Claude-specific governance claims are flagged as vendor-claimed throughout.

### V4: Amazon Q Customizations are miscategorized in the original framing

- **Strategy:** Challenge the Assumptions
- **Investigation:** Fetched A5 blog post (HTTP 200, published 2025-07-14) and the Amazon Q Developer FAQ. The FAQ describes customizations as making Q "aware of your internal libraries, APIs, best practices, and architectural patterns" to "generate more relevant inline code recommendations." Mechanism described is suggestion adaptation, not retrieval. No mention of vectors or retrieval architecture.
- **Result:** Partially Refuted (of the original O2 placement)
- **Impact:** A5 moved from O2 (retrieval) to O3 (model customization). O2 lost a corroborating artifact; the report reflects this.

### V5: A8 (WorkOS on Augment Code) is vendor-adjacent, not independent reporting

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** A8 is authored by WorkOS about Augment Code. WorkOS sells enterprise auth infrastructure to companies like Augment, creating a partnership-adjacent incentive even without explicit sponsorship. The article's structured data confirms "author: WorkOS."
- **Result:** Confirmed (the original single-source caveat was right but understated)
- **Impact:** A8's role in O2 is noted as vendor-adjacent. The article should not rely on A8 for load-bearing claims about Augment Code.

### V6: A9 (applied-ai.com) was never fetched and the site is a solo content-marketing presence

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The original A9 URL was located via search but never actually fetched during the research. The site's structured data shows a solo practitioner with a Packt-published 2020 book. The claim it supports (RAG over fine-tuning for dynamic codebases) is plausible but the source provides no independent authority.
- **Result:** Refuted as an independent corroborator
- **Impact:** Original A9 is dropped from the artifact registry. The general RAG-versus-fine-tuning trend is left as background context, not as a sourced claim. The artifact slot is reused for the Han plugin's own MCP documentation (the new A9).

### V7: AI-augmented PR review is missing from the framing

- **Strategy:** Challenge the Assumptions
- **Investigation:** Confirmed CodeRabbit Enterprise and Graphite both serve product surfaces. These operate at the version control workflow layer rather than IDE or model layer, representing a fundamentally different integration point not covered by the original five categories.
- **Result:** Confirmed
- **Impact:** New category O6 added. Two new artifacts (A10, A11) added. The article will name this category so PR-centric teams recognize themselves.

### V8: O5 (MCP) has stronger evidence for the Han audience than the general market caveat suggests

- **Strategy:** Challenge the Assumptions
- **Investigation:** Han's own plugin entity taxonomy explicitly recognizes MCP servers as valid plugin components. For Han's audience, MCP is the deployment primitive of the platform Han runs on, which is codebase-trust evidence rather than web-source.
- **Result:** Partially Refuted (of the original "thin adoption evidence" framing for this audience)
- **Impact:** O5 carries a narrowed caveat. The broader-market thinness still applies; the Han-audience strength is added.

### Adjustments Made

The original recommendation ordering survives, but the evidence chain was rewritten. The artifact registry now reflects: A5 moved from O2 evidence to O3; the original A9 dropped as a phantom citation; new A9 added for Han's own MCP documentation; A10 and A11 added for the new O6 category; A2's retirement date marked unverified; A8 marked vendor-adjacent rather than simply single-source; A1 carries an IDE-scope qualifier; Anthropic-specific governance claims (A3, A4) marked vendor-claimed throughout.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:**
  - The 2025-11-01 Copilot knowledge base retirement date is unverified by any living URL and should not be stated as fact in the article.
  - Copilot org custom instructions scope is github.com only as of GA; readers using Copilot primarily in IDEs are not served by O1 today.
  - Amazon Q customization's specific mechanism (fine-tuning vs. adapter vs. retrieval-with-org-corpus) is not definitively resolved; the FAQ language places it in O3 but the underlying implementation detail is partially gated.
  - All Claude Enterprise governance details rest on Anthropic-authored sources; no independent third-party reporting was located.
  - O6 (PR-layer AI review) is named based on verified product existence, not on independently corroborated feature detail. Article should name the category and example products without quoting specific feature claims.
  - The Sourcegraph Cody Free/Pro shutdown claim (2025-07-23) and the ~$16K platform price in A6 were not independently verified.

## Sources

### A1: GitHub Copilot Organization Custom Instructions GA — GitHub Changelog

- **Link / location:** https://github.blog/changelog/2026-04-02-copilot-organization-custom-instructions-are-generally-available/
- **Retrieved:** 2026-05-28
- **Trust class:** web
- **Summary:** GitHub announced 2026-04-02 that org-wide custom instructions for Copilot are GA, beta since April 2025. Org admins set instructions that apply across Copilot Chat on github.com, code review, and the coding agent. No developer-level override path. Validation confirmed that scope covers github.com surfaces only, not IDEs.
- **Evidence status:** Corroborated by A3 and A6 on the category-level pattern of org-distributed instructions. Single-source on the IDE-exclusion scope detail.

### A2: GitHub Copilot Knowledge Bases / Copilot Spaces

- **Link / location:** https://docs.github.com/en/enterprise-cloud@latest/copilot/concepts/knowledge-bases (returned HTTP 404 during fetch); Copilot Spaces documentation at https://docs.github.com/en/copilot/how-tos/provide-context/use-copilot-spaces verified during validation
- **Retrieved:** 2026-05-28
- **Trust class:** web
- **Summary:** Copilot knowledge bases reported retired on or around 2025-11-01 and replaced by Copilot Spaces. Spaces can be private or shared with org, team, or specific users; any Copilot user can create them. They combine code, Markdown, JSON, images, issues, and pull requests into a named context unit.
- **Evidence status:** Single-source. The originally-cited URL returned 404 and the specific retirement date could not be verified against a living URL during validation. Copilot Spaces themselves are confirmed to exist via a separate documentation URL.

### A3: Claude Code on Team and Enterprise — Anthropic

- **Link / location:** https://www.anthropic.com/news/claude-code-on-team-and-enterprise
- **Retrieved:** 2026-05-28
- **Trust class:** web
- **Summary:** August 2025 announcement bundling Claude Code into Team and Enterprise plans. Seat management, per-user and per-org spending limits, policy enforcement covering tool permissions, file access restrictions, and MCP server configurations across all Claude Code users. Usage analytics including code acceptance rates. Compliance API providing programmatic access to conversation content and activity event logs.
- **Evidence status:** Same-author corroboration with A4 (both are Anthropic). For the broader O4 governance category, corroborated by independent products via A1, A5, A6.

### A4: Claude Enterprise Product Page — Anthropic

- **Link / location:** https://www.anthropic.com/product/enterprise
- **Retrieved:** 2026-05-28
- **Trust class:** web
- **Summary:** Claude Enterprise covers Claude Code and Claude Cowork under one agreement. Workforce-wide deployment, SSO and identity-provider integration, internal knowledge integration without data leaving org control, configurable data retention, audit infrastructure, Trust Center.
- **Evidence status:** Same-author corroboration with A3 (both are Anthropic). Independent corroboration on the broader O4 pattern comes from A1, A5, A6.

### A5: Managing Amazon Q Developer Profiles and Customizations in Large Organizations — AWS Blog

- **Link / location:** https://aws.amazon.com/blogs/devops/managing-amazon-q-developer-profiles-and-customizations-in-large-organizations/
- **Retrieved:** 2026-05-28 (published 2025-07-14 per page metadata)
- **Trust class:** web
- **Summary:** Q Developer "customizations" are derived from an org's proprietary codebase to tailor inline code suggestions to org style, naming conventions, and patterns. "Profiles" combine subscription and customization and are assigned to users and groups via IAM Identity Center. Multi-business-unit orgs can maintain separate customizations per BU. Validation against the Amazon Q FAQ confirmed the mechanism is suggestion adaptation, not retrieval, placing this in O3 (model customization) rather than O2 (retrieval).
- **Evidence status:** Corroborated for the existence of the customization pattern by Q Developer's own FAQ. Single-source vendor blog on specific blast-radius and BU-isolation claims.

### A6: Sourcegraph Cody Enterprise Features

- **Link / location:** https://sourcegraph.com/docs/cody/enterprise/features
- **Retrieved:** 2026-05-28
- **Trust class:** web
- **Summary:** Multi-repo context (up to 10 repositories simultaneously), site-admin-configurable prompt pre-instructions org-wide, role-based access management, IDE token expiry controls, public-code guardrails. Cody Analytics covers user adoption, completion acceptance rates, chat volume, and command usage across the org. Cody Free and Pro reported as shut down 2025-07-23; Sourcegraph Enterprise platform pricing reported starting near ~$16K.
- **Evidence status:** Corroborated on the multi-repo and admin-instructions pattern. The Cody Free/Pro shutdown date and the specific ~$16K pricing figure were not independently verified during validation.

### A7: Introducing the Tabnine Agentic Platform — Tabnine Blog

- **Link / location:** https://www.tabnine.com/blog/introducing-the-tabnine-agentic-platform/
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor blog; interested-party scrutiny applies)
- **Summary:** Tabnine describes an "Enterprise Context Engine" that builds an org-level architectural map over the entire codebase (structure, coding standards, API usage patterns, naming conventions) persisting at the org level. "Org-Native Agents" operate within this context, enforcing policies and standards. The platform claims adaptation to new repositories and policies without retraining.
- **Evidence status:** Single source — caveated. The "no retraining" and "instant adaptation" claims are not independently corroborated.

### A8: Augment Code: Context Is the New Compiler — WorkOS Blog

- **Link / location:** https://workos.com/blog/augment-code-context-is-the-new-compiler
- **Retrieved:** 2026-05-28 (published 2025-10-29)
- **Trust class:** web (vendor-adjacent; WorkOS sells enterprise auth to companies like Augment)
- **Summary:** Describes Augment Code's Context Engine as a vectorized semantic index of the org codebase at team and org level, functioning as institutional memory for large teams, surfacing prior art across team boundaries, and encoding "the organization's idioms, patterns, and scars." Cosmos platform coordinates agents across triage, authoring, review, and verification at org scale.
- **Evidence status:** Single source — caveated. Vendor-adjacent rather than independent. Article use should be illustrative only.

### A9: Han Plugin Entity Taxonomy — MCP as a Recognized Plugin Component

- **Link / location:** han.plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md (this repository)
- **Retrieved:** n/a (codebase)
- **Trust class:** codebase
- **Summary:** Han's own entity taxonomy explicitly recognizes MCP servers and LSP servers as valid plugin components, alongside skills, agents, and hooks. For the Han audience specifically, MCP is the deployment primitive of the platform Han runs on, not an experimental concept. Cross-references the Claude Code plugin documentation.
- **Evidence status:** Codebase (single-citation rule does not apply); replaces the originally-cited applied-ai.com practitioner brief, which was a phantom citation never actually fetched during the research.

### A10: CodeRabbit Enterprise

- **Link / location:** https://coderabbit.ai/enterprise
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor product page)
- **Summary:** AI-augmented pull request review platform operating at the version control workflow layer. Named in the article as an example of O6 (PR-layer AI review) without quoting specific feature claims.
- **Evidence status:** URL existence verified during validation. Specific feature claims not independently corroborated; product surface confirms the category exists.

### A11: Graphite

- **Link / location:** https://graphite.dev
- **Retrieved:** 2026-05-28
- **Trust class:** web (vendor product page)
- **Summary:** Code review and stacked-PR workflow platform with AI-assisted review at the version control layer. Named in the article as an example of O6 (PR-layer AI review) without quoting specific feature claims.
- **Evidence status:** URL existence verified during validation. Specific feature claims not independently corroborated; product surface confirms the category exists.
