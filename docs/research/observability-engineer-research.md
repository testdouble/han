# Research: What observability engineering involves, and what an `observability-engineer` agent should own

Open-ended question: what work does observability engineering involve (its practices, the role, and the lens an expert
applies when reviewing code, designs, and plans), so that Han can define an `observability-engineer` agent?

Evidence mode: **strict** (default). Every claim that bears on the recommendation is corroborated by an independent
source or by codebase evidence, or is marked `[single-source]` and does not stand alone.

## Summary

Build a narrow `observability-engineer` that owns the telemetry design layer only, and leave service levels and alerting
with the DevOps reviewer (`devops-engineer`) and debuggability with the on-call reviewer (`on-call-engineer`). A broader
agent that takes over all of observability was considered and rejected, because it would rewrite a working agent and
repeat the over-scoping Han's last specialist research had to walk back. Your request to build the agent is the evidence
that it is needed now. Whether it finds problems the existing two would miss is untested, so the first few reviews
should check that.

Observability engineering is the work of making a running system answer questions about itself. That means deciding
what the software records, how those records connect across services, what gets kept or thrown away to control cost,
how "working well enough" is defined for users, and which signals should wake a person up. As employers describe the
role, it builds and runs that tooling, sets the standards other teams follow, and hunts for blind spots after incidents.

Han already covers more of this than it first appears. The DevOps reviewer checks service levels, alerting, the standard
service dashboards, tracing, and logging. The on-call reviewer checks that new code can be debugged in production, and
it already carries the field's alerting math and core vocabulary. What nobody owns is the telemetry design layer
underneath: how telemetry is named, how many distinct values a recorded field may take before cost explodes, which
requests get kept when only some can be, and how the pipeline that carries telemetry is configured. Those problems show
up in application code and in configuration alike, and today neither reviewer is pointed at them.

The practice areas are well-corroborated. The case for a separate agent rests on a gap in Han's own agents, which is
narrower than the field as a whole.

- **Confidence:** Medium
- **Web search:** used

## Research Results

### Observability means answering new questions, not only watching known ones

The neutral definition, from the OpenTelemetry project, is understanding a system from the outside by asking it
questions, including ones nobody predicted (A1). Monitoring, as the Google SRE book describes it, watches known
conditions and pages a person when users feel pain (A4). Charity Majors, a founder of the vendor Honeycomb, draws the
line more sharply: monitoring handles the problems you anticipated, and observability lets you investigate the ones you
did not, without shipping new code (A2).

The two framings agree on the goal and disagree on what it takes. Majors argues that real observability needs one
detailed, structured record per request (a "wide event") with many high-variety fields, combined at query time (A2,
A3). The OpenTelemetry definition does not demand that design (A1). The sharper position comes from a vendor that sells
wide events, and a practitioner talk on Grafana's site calls them "more of a North Star than a silver bullet" (A24)
[single-source]. The research does not settle which framing is canonical, so an agent should know both.

### The work splits into eight practice areas

The two research angles converged on the same body of work. Each area below is something an observability engineer
designs, reviews, or maintains.

- **Choosing signals.** Systems emit traces (the path of one request across services), metrics (cheap numeric
  aggregates), and logs, with profiles still emerging (A1, A10). Each fits different questions. Averages hide slow
  outliers, so latency needs histograms and high percentiles (A4, A6).
- **Instrumenting code consistently.** OpenTelemetry, the open standard most of the industry instruments with, supplies
  libraries plus shared naming rules called semantic conventions, so telemetry from your code, libraries, and platforms
  lines up (A12) [single-source; the project's own specification].
- **Connecting signals across services.** Trace context (a trace ID and span ID) must travel with every request between
  services, by default in the W3C `traceparent` header, and request IDs should run end to end (A10, A18). OpenTelemetry
  also warns that baggage, its side channel for key-value data, must not carry secrets, and that inbound context is
  untrusted (A10) [single-source].
- **Controlling cardinality.** Cardinality is the number of distinct values a field can take. Every distinct label value
  on a metric creates a new time series, so a per-user label multiplies cost (A14, A15). Prometheus advises keeping label
  values under about ten and treating more than a hundred as a reason to rethink (A14) [single-source on the numbers].
- **Sampling.** Head sampling decides at the start of a request whether to keep it. It is cheap but cannot promise to keep
  the errors. Tail sampling decides after the request finishes, so it can keep errors and slow requests, but it holds
  state, costs more to run, and can itself fail under load (A9). Teams often combine the two (A9).
- **Running the telemetry pipeline.** The OpenTelemetry Collector is a service that receives, processes, and forwards
  telemetry. It batches, retries, filters sensitive data, and can send to several backends (A11) [single-source]. Sending
  straight to a backend is fine for small setups (A11).
- **Keeping sensitive data out.** OpenTelemetry cannot know what is sensitive, so the team owns it. Collect only what you
  need, review what instrumentation libraries add on their own, and scrub in the pipeline (A13, A18). Do not trust
  hashing to hide IDs drawn from a small set of possible values (A13) [single-source].
- **Defining service levels and alerting on them.** A service level indicator (SLI) measures what users feel, a service
  level objective (SLO) sets the target, and the error budget is how much failure the target allows (A6). Alerts should
  fire on symptoms users feel, and every page should be urgent, actionable, and new (A4). The SRE workbook recommends
  alerting on how fast the error budget is burning, over two time windows at once (A5). For a 99.9% target, its example
  pages at 14.4 times the normal burn rate over one hour and 6 times over six hours, and opens a ticket at 1 times over
  three days (A5) [single-source on the thresholds]. The workbook names the costs: many parameters, poor fit for
  low-traffic services, and trouble with extreme targets like 99.999% (A5).

Three standard checklists frame service dashboards. The Four Golden Signals are latency, traffic, errors, and saturation
(A4). RED (rate, errors, duration) applies per service, and USE (utilization, saturation, errors) applies per resource;
the RED method's author recommends using the two together (A7, A8).

### The weakest-evidenced areas come from vendors

Four practice areas have only vendor or secondary support, and an agent should carry them as vocabulary with that caveat.

- **Cost management.** Named levers are cardinality control, dropping or hashing labels in the pipeline, tiered
  retention, and trimming debug and duplicate logs (A15, A16), plus sampling (A3). Every cost source found sells tooling
  in this space, the cost guides were read as search summaries only, and no independent benchmark surfaced.
- **Observability-driven development.** The practice is to instrument while writing the code, ask "how will I know when
  this isn't working?", and check production after each deploy (A25). Two vendors agree on the practice; nobody
  published independent evidence of outcomes.
- **Maturity models.** Honeycomb's model scores five capabilities: incident resilience, code quality, release cadence,
  complexity and technical debt, and understanding user behavior (A26) [single-source]. The level definitions could not
  be retrieved.
- **"Three pillars are not enough."** Cindy Sridharan's book argues that having logs, metrics, and traces does not make a
  system observable (A23) [single-source, secondary report only; the primary text was paywalled or blocked].

### The role builds the platform and sets the standards

Job postings describe the observability engineer as a platform-and-standards role. The recurring duties are:

- Design, roll out, and improve the monitoring, logging, and tracing stack (A19, A20).
- Set instrumentation standards and drive adoption across teams (A19, A20).
- Build dashboards and alerts tied to SLOs, and cut alert noise (A19, A20).
- Lead root cause analysis and post-incident reviews to find visibility gaps (A19, A20).
- Wire observability into CI/CD and work alongside development, SRE, and platform teams (A19, A20).
- Monitor the observability system itself, write runbooks, and train engineers to read the data (A20).

This evidence is thinner than two sources suggest. One posting was read in full and has since been removed (A19); the
rest were seen only as search-result summaries (A20). The posting asks for five or more years in SRE, DevOps, or
observability work (A19). The boundary with neighboring roles is soft: search results treat observability as a duty
inside SRE rather than a separate title (A22), and a Honeycomb podcast frames the role as speaking for the user across
product, support, and engineering (A21) [single-source, vendor]. No authoritative source draws a hard line between the
observability engineer and the SRE.

Several of these duties do not translate to a Han agent. Running the stack, choosing vendors, and training people are
things a person does over time. A review agent can judge designs and code against standards, which is the
standards-setting half of the role.

### An expert reviewer looks for twelve recurring problems

Across both angles, these are the concerns an observability expert raises against a code change, a design, or a plan.

1. Alerts on causes (CPU, disk) instead of symptoms users feel, or pages nobody can act on (A4).
2. Naive SLO alerting: one short window, a fixed delay before firing, or a single burn rate (A5).
3. No instrumentation for user-visible failures, the golden signals, or the SLO's own measurements (A4, A17).
4. Trace context or request IDs dropped at a service boundary, so logs, traces, and metrics cannot be joined (A10,
   A18).
5. Unbounded identifiers such as user IDs used as metric labels (A14, A15). This one is contested: the wide-events camp
   says those same fields belong on events (A3).
6. Wrong metric types, values baked into metric names, or heavy instrumentation on hot paths (A14) [single-source].
7. Sampling that throws away the interesting requests, or a tail sampler nobody monitors (A9).
8. Personal or regulated data in telemetry, including attributes that libraries add on their own (A13, A18).
9. Dashboards that need someone watching them, or that do not show the SLO measurements (A4, A17).
10. Alerts with no runbook link or routing, and alert paths nobody has tested (A18) [single-source on testing].
11. Telemetry cost blowups from unbounded labels, histograms, and duplicate metrics (A14, A15).
12. Treating "we have logs, metrics, and traces" as proof of observability (A23) [single-source].

Google's production readiness review asks whether every user-visible failure is instrumented and alerted, and whether
dashboards cover the SLO measurements (A17). Third-party readiness checklists add structured logs, request IDs, scrubbed
sensitive data, and alerts routed with runbook links (A18).

### Practitioners disagree about metrics versus events

The main live disagreement is where detailed, high-variety data should live. Majors argues metrics handle it poorly and
that wide events should be the single source of truth (A2, A3). Prometheus keeps metrics at the center and bounds their
labels tightly (A14). The SRE books are metrics- and SLO-oriented (A4, A6). Sampling is the one point both camps
share as a cost lever (A3). An agent that picks a side will give advice wrong for half its users, so it should name the
trade-off rather than rule on it.

### Han covers service levels and debuggability, but not telemetry design

Observability today is split between two agents by altitude, meaning the level at which each reviews: the on-call
reviewer at the source line of application code, the DevOps reviewer at configuration and infrastructure. Between them
they cover most of the eight practice areas.

- **The DevOps reviewer covers service levels, alerting, and dashboards.** Its observability sweep is a ten-bullet
  checklist: the golden signals, SLIs and SLOs with multi-window burn-rate alerts, traces with correlation IDs,
  structured logs without personal data, OpenTelemetry with vendor SDKs isolated at the collector, and business
  metrics (A27). Its vocabulary lists RED, USE, and "high-cardinality dimension", and its cost protocol names
  observability ingestion as a cost axis (A27).
- **The DevOps reviewer is thin on telemetry design.** Sampling gets one clause ("sample rate useful on low-frequency
  endpoints"), the pipeline gets one ("vendor SDKs isolated at the collector"), and cardinality appears only as a
  vocabulary term (A27). Semantic conventions, head-versus-tail sampling trade-offs, pipeline processors, and the
  metrics-versus-events trade-off do not appear at all (A27).
- **The on-call reviewer covers debuggability at the source line, and already carries the field's vocabulary.** It
  checks that a change emits enough to debug, propagates correlation IDs, uses structured fields, and keeps personal
  data out of logs, metric labels, and trace attributes (A28). Its vocabulary already includes the SRE workbook's
  burn-rate thresholds, the "how will I know when this isn't working?" gate from observability-driven development, wide
  structured events, and the USE method, citing Google SRE, Majors, Sridharan, and Gregg (A28). It does not check
  cardinality, sampling, or naming (A28).
- **The on-call reviewer cannot stretch to configuration.** It reviews application source only, and hands the
  observability platform, alert rules, and dashboards to the DevOps reviewer (A28).
- **Skills route observability to both agents, by altitude.** Code review sends observability configuration to the
  DevOps reviewer and new production code paths to the on-call reviewer (A29). Plan review, feature planning, change
  planning, and gap analysis follow the same split (A30).

The gap that follows from this is specific. A metric label holding a user ID, written in application code, reaches the
on-call reviewer, which checks it for personal data but not for cardinality (A28). The same problem in a pipeline config
reaches the DevOps reviewer, which names cardinality but carries no protocol for it (A27). Telemetry design problems
fall between the two reviewers at both altitudes.

Han has narrowed a specialist like this before. The research behind the on-call reviewer found the DevOps reviewer
already covered much of the territory, and adversarial validation narrowed the new agent to the slice nobody owned
(A31).

### Building the agent passes Han's YAGNI gate, and the gate favors the narrow version

Han's YAGNI rule admits an item when there is evidence it is needed now, and a need the user describes in conversation
counts (A35). Your request to build an `observability-engineer` is that evidence. The rule's second gate then asks
whether a strictly simpler version meets the same need, and replaces the larger version if so (A35). That gate is what
separates the options below.

Adding any specialist touches many files. The on-call reviewer, the closest precedent, is referenced in 38 files outside
the research and plan folders, including six agent definitions, sixteen skill files, and the indexes (A36). A new agent
also needs a long-form doc, a plugin README line, and an agents-index entry in the same change (A34).

## Options to Consider

### O1: Deepen the DevOps reviewer's observability sweep

- **What it is:** Add telemetry-design checks (naming, cardinality, sampling, pipeline) to the DevOps reviewer's
  existing sweep and build no new agent.
- **Trade-offs:** This is the simplest version under the YAGNI rule's second gate (A35). It adds no new boundary and no
  dispatch-table rows, since skills already route observability configuration there (A29, A30). Its weakness is
  altitude. Skills dispatch the DevOps reviewer for configuration and infrastructure changes, not for application code
  (A29), so a cardinality problem written in application code would still reach only the on-call reviewer, which does
  not check for it (A28).
- **Rests on:** (A27), (A28), (A29), (A30), (A35)
- **Evidence status:** corroborated (codebase)

### O2: Build a narrow telemetry-design reviewer

- **What it is:** A new read-only `observability-engineer` that owns the unowned slice, at both the code and
  configuration altitudes: semantic conventions and naming, cardinality and telemetry cost, sampling design, telemetry
  pipeline configuration, and the choice between metrics, events, traces, and logs. The DevOps reviewer keeps service
  levels, alerting, dashboards, and the golden signals, unchanged. The on-call reviewer keeps debuggability, correlation
  IDs, and personal data at the source line, unchanged.
- **Trade-offs:** It closes the gap that falls between the two existing reviewers at both altitudes (A27, A28). It
  leaves both existing agents' observability protocols intact, so no current review loses coverage. The cost is a third
  routing slot: the dispatch tables in code review, plan review, feature planning, change planning, and gap analysis
  each need a row (A29, A30). Han's guidance says boundaries should run both ways, so both existing agents' descriptions
  and bodies need a pointer back (A32). The DevOps reviewer's description is about 930 characters against a 1024-character
  budget (A32), leaving room for one short clause. The new agent also needs a long-form doc and index entries (A34).
- **Rests on:** (A9), (A12), (A14), (A15), (A27), (A28), (A29), (A30), (A32), (A34)
- **Evidence status:** corroborated (practice areas by independent web sources; current gap by codebase)

### O3: Build a broad observability owner

- **What it is:** A new agent that owns all eight practice areas, with observability depth moved out of the DevOps
  reviewer and the on-call reviewer.
- **Trade-offs:** It would give the whole discipline one owner. But it rewrites the observability protocols of two
  working agents that the dispatch tables treat as their observability anchors (A27, A28, A29, A30). Reviews that rely
  on the DevOps reviewer for service levels would regress until every table is updated. It also repeats the over-scoping
  that validation had to narrow in the on-call research (A31), and fails the YAGNI rule's second gate because O2 meets
  the same need with less change (A35).
- **Rests on:** (A27), (A28), (A29), (A30), (A31), (A35)
- **Evidence status:** corroborated (codebase)

### O4: Extend the on-call reviewer

- **What it is:** Add cardinality, sampling, and naming checks to the on-call reviewer, which already carries the
  observability vocabulary.
- **Trade-offs:** It reuses vocabulary the on-call reviewer already holds (A28). But that agent reviews application
  source only and hands configuration to the DevOps reviewer (A28), so sampling rules and pipeline processors, which live
  in configuration, would stay unowned. It would also widen an agent whose scope was deliberately narrowed (A31).
- **Rests on:** (A28), (A31)
- **Evidence status:** corroborated (codebase)

### O5: A reference checklist instead of an agent

- **What it is:** Capture the telemetry-design checks as a shared reference file that the existing reviewers load.
- **Trade-offs:** Some checks are mechanical, such as the label-count guidance (A14). Han's taxonomy reserves agents for
  contextual judgment and skills or references for fixed processes (A37). The central questions here are judgment
  calls: whether to sample by head or tail depends on volume and what must be kept (A9), and metrics versus events is a
  contested trade-off with no single right answer (A2, A14, A24). A checklist would also still need a reviewer to load it
  at the code altitude, which brings back the O1 routing problem (A29).
- **Rests on:** (A2), (A9), (A14), (A24), (A29), (A37)
- **Evidence status:** corroborated; the metrics-versus-events disagreement rests partly on a single source (A24)

## Recommendation

- **Recommendation:** O2. Build a narrow `observability-engineer` that owns telemetry design (naming and semantic
  conventions, cardinality and telemetry cost, sampling design, pipeline configuration, and signal choice) at both the
  code and configuration altitudes. Leave the DevOps reviewer's and on-call reviewer's observability protocols in place,
  and add a one-clause pointer to the new agent in each. Give the agent the practice areas above as protocols and review
  concerns 5, 6, 7, and 11 as its core anti-patterns. Carry the vendor-sourced ideas (cost levers, wide events) as
  vocabulary with their caveat, name the metrics-versus-events trade-off rather than ruling on it, and inherit the DevOps
  reviewer's YAGNI guard so it does not ask a solo engineer for tail sampling on a service with no traffic.
- **Reopen trigger:** if its first few real reviews find nothing the DevOps and on-call reviewers would not have found,
  fold its checks into the DevOps reviewer instead (O1).
- **Evidence basis:** The need rests on your request, which the YAGNI rule accepts (A35). The gap rests on codebase
  evidence that the DevOps reviewer is thin on telemetry design and the on-call reviewer does not check it (A27, A28),
  and that skills route the two reviewers by altitude so the gap appears at both (A29, A30). That codebase evidence is
  the trusted anchor for what Han does today. The practice areas the agent would own rest on corroborated primary
  sources for sampling (A9) and cardinality cost (A14, A15). Semantic conventions (A12) and pipeline details (A11) are
  single-source, from the OpenTelemetry project's own documentation, and should appear as examples rather than rules.
  The role's separateness from SRE is soft (A21, A22), so the case does not rest on the job title. Whether the agent adds
  value over a deepened DevOps reviewer is untested.

## Validation

Adversarial validation ran over the first draft, which recommended a broader agent. It confirmed the codebase citations
and the practice-area research, and found the recommendation over-scoped. The report above is the revised version.

### V1: The draft overstated the DevOps reviewer's gap

- **Strategy:** Challenge the Evidence
- **Investigation:** Searched the DevOps reviewer's definition for sampling, semantic conventions, processors,
  cardinality, collector, and cost.
- **Result:** Partially Refuted
- **Impact:** Sampling, the collector, and cardinality each appear thinly, and observability ingestion is a named cost
  axis. Only semantic conventions are wholly absent. The codebase section now says "thin", names what is present, and
  no longer claims cardinality and cost are missing.

### V2: The on-call reviewer already carries the field's vocabulary

- **Strategy:** Challenge the Evidence
- **Investigation:** Read the on-call reviewer's vocabulary section.
- **Result:** Refuted
- **Impact:** It already carries the burn-rate thresholds, the observability-driven development gate, wide events, and
  USE. The report now says so, and the recommendation no longer frames those ideas as new vocabulary to import.

### V3: The broad scope repeated the over-scoping the on-call precedent warned against

- **Strategy:** Challenge the Assumptions
- **Investigation:** Compared the draft's scope with both existing agents' protocols and the on-call research.
- **Result:** Partially Refuted
- **Impact:** The precedent supports narrowing to the unowned slice, not moving depth out of the DevOps reviewer. The
  draft's recommendation became O3 and was rejected; the narrow version became O2.

### V4: The option set was incomplete and one option was a strawman

- **Strategy:** Challenge the Options Framing
- **Investigation:** Compared the options against the YAGNI rule and Han's skill-versus-agent taxonomy.
- **Result:** Partially Refuted
- **Impact:** The draft's "model the whole job description" option was dropped as a strawman; its point now sits in the
  role section. Options for the narrow agent, extending the on-call reviewer, and a reference checklist were added. The
  claim that the investigate and runbook skills have nobody to ask was removed, because it showed absence rather than
  need and counted against one option only. The description-budget claim was corrected: the budget limits only the
  boundary clause.

### V5: Demand was asserted, not evidenced

- **Strategy:** Challenge the Assumptions
- **Investigation:** Read the YAGNI rule, the solo-and-small-teams rationale, and searched for any prior request.
- **Result:** Partially Refuted
- **Impact:** Job-posting taxonomy is not demand. The report now cites your request as the YAGNI evidence, applies the
  second gate to favor the narrow version, and adds a reopen trigger in case the agent adds nothing.

### V6: Twelve citations did not support their claims

- **Strategy:** Challenge the Evidence
- **Investigation:** Checked every cited ID against the registry summary it resolves to.
- **Result:** Partially Refuted
- **Impact:** Each failing citation was trimmed to the sources that support it: semantic conventions, hashing, cost
  levers, label thresholds, Google's readiness review, runbook and training duties, and years of experience. "Must" was
  corrected to "should" for bidirectional boundaries. Claims that rested on removed citations were rewritten.

### V7: The routing claim hid the on-call reviewer's share

- **Strategy:** Challenge the Evidence
- **Investigation:** Read the cited dispatch-table lines.
- **Result:** Partially Refuted
- **Impact:** The tables route observability to both reviewers by altitude. The report now says so, which is also what
  exposes the gap at both altitudes.

### V8: Several web sources were never opened

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Reviewed which sources were fetched and tested whether discounting any one changes the outcome.
- **Result:** Partially Refuted
- **Impact:** Seven sources were seen only as search summaries, and the job-posting pair is weaker than "two sources"
  suggests. The registry now marks these. No injected directives were found in the registry text. Discounting any single
  web source does not change the recommendation, which rests on the codebase gap.

### V9: The change list was undercounted

- **Strategy:** Challenge the Fix
- **Investigation:** Measured the DevOps reviewer's description and checked the files that reference a comparable agent.
- **Result:** Partially Refuted
- **Impact:** The report now counts the precedent's footprint (A36) and names the description budget. O2's choice to
  leave both existing protocols intact removes the regression risk the validator raised for moving depth out of the
  DevOps reviewer.

### Adjustments Made

The recommendation changed from a broad observability owner to a narrow telemetry-design reviewer. The gap statement
was corrected to "thin" rather than "absent". The on-call reviewer's existing vocabulary was acknowledged. Three options
were added, one was dropped, and the old recommendation became the rejected O3. The YAGNI evidence and a reopen trigger
were added. Twelve citations were trimmed, and unopened sources were marked in the registry.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:**
  - No sample review has been run, so whether the narrow agent finds problems the existing two would miss is
    untested.
  - The web pages were not re-fetched during validation. A19 is a removed listing, and A8, A15, A16, A18, A20, A22, and
    A24 were read only as search summaries.
  - Semantic conventions and pipeline details rest on the OpenTelemetry project's own documentation alone.
  - The cost-management practice area rests entirely on vendor sources.

## Sources

| ID  | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
| --- | ------ | --------------- | --------- | ----------- | ------------------ | --------------- |
| A1 | OpenTelemetry, Observability primer | https://opentelemetry.io/docs/concepts/observability-primer/ | 2026-10-14 | web | Defines observability as asking a system new questions from outside; defines traces, metrics, logs, and instrumentation. | corroborated by A2 |
| A2 | Majors, "Build observable systems" (Honeycomb, 2017) | https://honeycomb.io/blog/2017/06/build-observable-systems/ | 2026-10-14 | web (vendor) | Monitoring covers known problems, observability unknown ones; argues for wide per-request events, high cardinality, read-time aggregation, and sampling that keeps errors. | definition corroborated by A1; wide-events thesis contested by A14, A24 |
| A3 | Majors, "It's time to version observability" (Honeycomb) | https://www.honeycomb.io/blog/time-to-version-observability-signs-point-to-yes | 2026-10-14 | web (vendor) | Calls three pillars "1.0" and wide events "2.0"; says metrics handle high cardinality poorly; names sampling as the cost lever. | contested by A14, A24; same vendor camp as A2 |
| A4 | Google SRE book, "Monitoring Distributed Systems" | https://sre.google/sre-book/monitoring-distributed-systems/ | 2026-10-14 | web | Four Golden Signals; alert on symptoms; every page urgent, actionable, and new; averages hide the tail; dashboards answer basic questions. | corroborated by A5, A7, A17 |
| A5 | Google SRE workbook, "Alerting on SLOs" | https://sre.google/workbook/alerting-on-slos/ | 2026-10-14 | web | Recommends multiwindow, multi-burn-rate alerts; for 99.9% pages at 14.4x/1h and 6x/6h, tickets at 1x/3d; names weaknesses of simpler alerts and costs of this one. | approach corroborated by A4, A6; thresholds single source (caveated) |
| A6 | Google SRE book, "Service Level Objectives" | https://sre.google/sre-book/service-level-objectives/ | 2026-10-14 | web | Defines SLI, SLO, SLA, and error budget; pick few user-centric indicators; prefer percentiles; set targets from user needs. | corroborated by A4, A5 |
| A7 | Wilkie, "The RED Method" (Grafana) | https://grafana.com/blog/the-red-method-how-to-instrument-your-services/ | 2026-10-14 | web (vendor; method's author) | RED is rate, errors, duration per service; USE is utilization, saturation, errors per resource; use both together. | corroborated by A4, A8 |
| A8 | RED and USE search digest (FOSDEM 2018, Gregg slides) | https://archive.fosdem.org/2018/schedule/event/the_red_method/ ; https://www.brendangregg.com/Slides/EuroBSDcon2017_SystemMethodology.pdf | 2026-10-14 | web (search summaries; not opened) | Gregg created USE and Wilkie created RED; the two are complementary. | corroborates A7 |
| A9 | OpenTelemetry, "Sampling" | https://opentelemetry.io/docs/concepts/sampling/ | 2026-10-14 | web | Head sampling is cheap but can drop errors; tail sampling keeps errors and slow traces but is stateful and can degrade under load; combine them. | corroborated by A2, A3 |
| A10 | OpenTelemetry, "Context propagation" and "Signals" | https://opentelemetry.io/docs/concepts/context-propagation/ ; https://opentelemetry.io/docs/concepts/signals/ | 2026-10-14 | web | Trace context crosses services via W3C traceparent; logs can carry trace IDs; baggage must not hold secrets; profiles listed as emerging. | propagation corroborated by A18; baggage and profiles single source (caveated) |
| A11 | OpenTelemetry Collector | https://opentelemetry.io/docs/collector/ | 2026-10-14 | web | Vendor-neutral service that receives, processes, and exports telemetry; batches, retries, filters sensitive data; direct export fine for small setups. | single source (caveated) |
| A12 | OpenTelemetry, "Semantic conventions" | https://opentelemetry.io/docs/concepts/semantic-conventions/ | 2026-10-14 | web | Shared naming vocabulary that makes telemetry consistent and correlatable across code, libraries, and platforms. | single source (caveated); project's own specification |
| A13 | OpenTelemetry, "Handling sensitive data" | https://opentelemetry.io/docs/security/handling-sensitive-data/ | 2026-10-14 | web | Team owns what is sensitive; minimize collection; review library-emitted attributes; scrub in the Collector; hashing small ID spaces may be reversible. | scrubbing corroborated by A18; hashing point single source (caveated) |
| A14 | Prometheus, "Instrumentation practices" | https://prometheus.io/docs/practices/instrumentation/ | 2026-10-14 | web | Each label set is a new series; keep cardinality under ~10, rethink over 100; per-user labels, values in names, type misuse, and hot-path overhead are anti-patterns. | cardinality cost corroborated by A15; numeric thresholds and other anti-patterns single source (caveated) |
| A15 | Third-party Datadog cost guides (SigNoz, Finout) | https://signoz.io/guides/how-to-reduce-datadog-costs/ ; https://www.finout.io/blog/datadog-cost-optimization | 2026-10-14 | web (competing vendors; search summaries, not opened) | Custom metrics billed per unique tag combination, so a user_id tag multiplies cost; histograms and duplicates add cost. | cardinality corroborated by A14 |
| A16 | Observability cost vendor digest (Coralogix, Last9, OpenObserve) | https://coralogix.com/guides/observability-cost-optimization/ ; https://last9.io/guides/high-cardinality/cost-optimization-and-emergency-response-surviving-cardinality-spikes-without-breaking-the-budget/ | 2026-10-14 | web (vendors; search summaries, not opened) | Cost levers: cardinality control, dropping or hashing labels, sampling, retention tiers, trimming debug and duplicate logs. | agrees with A15; all vendors, weak |
| A17 | Google SRE book, "Evolving SRE Engagement Model" (PRR) | https://sre.google/sre-book/evolving-sre-engagement-model/ | 2026-10-14 | web | Production readiness review asks whether user-visible failures are instrumented and alerted and whether dashboards cover SLO metrics. | corroborated by A18 |
| A18 | Production readiness checklist roundup | https://getdx.com/blog/production-readiness-checklist/ (and search results page) | 2026-10-14 | web (secondary, mixed; search summaries, not opened) | Checklists include structured logs, request IDs end to end, tracing, SLOs, scrubbed sensitive data, routed alerts with runbook links, tested alert paths. | core items corroborated by A17; alert-path testing single source (caveated) |
| A19 | Observability Engineer posting, Transaction Network Services (Built In) | https://builtin.com/job/observability-engineer/6430381 | 2026-10-14 | web (listing since removed) | Duties: monitoring/logging/tracing stack, instrumentation standards, dashboards and alerts, CI/CD, RCA, tooling, coaching; asks 5+ years SRE/DevOps and SLO design. | corroborated by A20 (search summaries only) |
| A20 | Observability engineer postings digest | https://builtin.com/job/observability-engineer/3400943 ; https://jobs.lever.co/weekdayworks/ac6aae20-e79f-40e0-bd08-1b9ad4fedd5d ; https://www.dice.com/job-detail/664f6a54-4dd2-4276-a038-7f7e8660786e | 2026-10-14 | web (search summaries of postings; not opened) | Common duties: build the stack, set instrumentation standards, SLO dashboards, alert noise reduction, RCA, CI/CD, self-monitoring, runbooks, training. | corroborated by A19 |
| A21 | O11ycast ep. 83, "Observability isn't just SRE on steroids" (Honeycomb) | https://www.honeycomb.io/resources/podcasts/ep-83-observability-isn-t-just-sre-on-steroids-with-dan-ravenstone | 2026-10-14 | web (vendor) | Frames the observability engineer as cross-functional and speaking for the user, beyond SRE. | single source (caveated) |
| A22 | SRE vs platform engineering search digest (Tigera and others) | https://www.tigera.io/learn/guides/devsecops/platform-engineering-vs-sre/ | 2026-10-14 | web (secondary; search summaries, not opened) | Observability appears as a duty inside SRE, not a separate title; responsibilities blur across SRE, DevOps, and infrastructure. | blurry boundary consistent with A21; otherwise single source (caveated) |
| A23 | Sridharan, "Distributed Systems Observability" (secondary reports) | https://www.oreilly.com/library/view/distributed-systemsobservability/9781492033431/ ; https://www.infoq.com/news/2019/02/rethinking-observability | 2026-10-14 | web (secondary) | Reported as arguing that having logs, metrics, and traces does not by itself make a system observable. | single source (caveated); primary text not read |
| A24 | "Observability 2.0" pushback (SimpliSafe talk on Grafana's site) | https://grafana.com/events/obsessions/2025/boston/are-we-ready-for-observability-2-0-pragmatic-observability-at-simplisafe/ | 2026-10-14 | web (secondary; search summary, not opened) | Calls wide events "more of a North Star than a silver bullet"; trade-offs against lightweight metrics. | single source (caveated) |
| A25 | Honeycomb, "A next step beyond test-driven development" | https://dev.to/honeycombio/a-next-step-beyond-test-driven-development-h05 | 2026-10-14 | web (vendor) | Observability-driven development: instrument while coding, ask how you will know it broke, check production after deploy. | agrees with a CNCF post seen in search only; no outcome evidence |
| A26 | Honeycomb observability maturity model webinar | https://www.honeycomb.io/resources/webinars/honeycomb-presents-a-new-framework-for-an-observability-maturity-model | 2026-10-14 | web (vendor) | Model scores five capabilities: incident resilience, code quality, release cadence, complexity and tech debt, user behavior understanding. | single source (caveated); levels not retrieved |
| A27 | `devops-engineer` agent definition | `han-core/agents/devops-engineer.md:4-10`, `:73-76`, `:124-129`, `:254-258`, `:284-299` | n/a | codebase | Observability sweep covers golden signals, SLOs, burn-rate alerts, traces, logs, OTel; sampling, collector, and cardinality appear thinly; semantic conventions absent; ingestion named as a cost axis; YAGNI defers dashboards and SLOs without traffic. | codebase anchor |
| A28 | `on-call-engineer` agent definition | `han-core/agents/on-call-engineer.md:22-26`, `:116-122`, `:347-366`, `:517-521` | n/a | codebase | Reviews application source only; checks debuggability, correlation IDs, structured fields, and PII in logs, labels, and attributes; vocabulary already holds burn-rate thresholds, the ODD gate, wide events, and USE; no cardinality, sampling, or naming checks; hands config to devops-engineer. | codebase anchor |
| A29 | Code review agent dispatch table | `han-coding/skills/code-review/references/agent-dispatch.md:32-33`, `:111-112`, `:261` | n/a | codebase | Routes observability config and infra to devops-engineer and new production application source to on-call-engineer. | codebase anchor |
| A30 | Planning and gap-analysis dispatch tables | `han-planning/skills/iterative-plan-review/SKILL.md:267-268`; `han-planning/skills/plan-a-feature/references/review-team-briefs.md:22-23`; `han-planning/skills/plan-a-change/references/team-selection.md:64`; `han-research/skills/gap-analysis/SKILL.md:177-181` | n/a | codebase | Each routes observability to devops-engineer and source-level failure-path observability to on-call-engineer. | codebase anchor |
| A31 | Prior on-call-engineer research | `docs/research/on-call-engineer-research.md:11`, `:119-124` | n/a | codebase | Found devops-engineer already covered observability and SLOs; validation narrowed the new agent to the unowned slice. | codebase anchor |
| A32 | Agent description guidance | `han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-description-length.md:33`, `:75-78`, `:87` | n/a | codebase | Descriptions fit 1024 characters; "Does not X — use Y" names the sibling; boundaries should be bidirectional. | codebase anchor; devops-engineer description measured at about 930 characters |
| A33 | Investigate and runbook skills | `han-coding/skills/investigate/SKILL.md`; `han-documentation/skills/runbook/SKILL.md` | n/a | codebase | Neither dispatches devops-engineer or on-call-engineer; runbook dispatches no agent. | codebase anchor; not cited in the revised report, kept because validation discussed it |
| A34 | Long-form doc coverage rule and index convention | `docs/templates/coverage-rule.md:1-12`; `CLAUDE.md` ("Indexes stay complete") | n/a | codebase | Every new agent needs a long-form doc, a plugin README scent line, and an agents-index entry in the same PR. | codebase anchor |
| A35 | YAGNI rule, Gate 1 and Gate 2 | `han-core/references/yagni-rule.md:27-60` | n/a | codebase | An item needs evidence it is needed now, and a user-described need in conversation counts; a strictly simpler version that meets the same evidence replaces the larger one. | codebase anchor |
| A36 | Footprint of the on-call-engineer precedent | `grep -rl "on-call-engineer"` over the repo, excluding `docs/research/`, `docs/plans/`, `node_modules`, `.git` | n/a | codebase | 38 files reference the on-call-engineer, including six agent definitions, sixteen skill files, and the indexes. | codebase anchor |
| A37 | Plugin entity taxonomy | `han-plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md` ("Skills: Process Engine", "Agents: Thinking Layer") | n/a | codebase | Skills run fixed, flowchartable processes; agents apply contextual judgment and taste. | codebase anchor |

### A9: OpenTelemetry, "Sampling" — recommendation-bearing

- **Link / location:** https://opentelemetry.io/docs/concepts/sampling/
- **Retrieved:** 2026-10-14
- **Trust class:** web (outside the trust boundary; project's own docs)
- **Summary:** Head sampling decides early, for example by trace-ID probability, and cannot guarantee keeping error
  traces. Tail sampling decides after seeing the whole trace, so it can keep errors and slow requests, but it holds state,
  uses more resources, is harder to maintain, and can degrade under load. The two are often combined. The page also lists
  cases where sampling is not appropriate, such as low volume and regulatory limits.
- **Evidence status:** corroborated by A2 and A3

### A14: Prometheus, "Instrumentation practices" — recommendation-bearing

- **Link / location:** https://prometheus.io/docs/practices/instrumentation/
- **Retrieved:** 2026-10-14
- **Trust class:** web (outside the trust boundary; project's own docs)
- **Summary:** Every distinct set of label values creates a new time series. Keep label cardinality under about ten where
  possible and look for alternatives above a hundred. Per-user labels, values encoded in metric names, misused counter
  and gauge types, and heavy instrumentation in hot paths are named anti-patterns.
- **Evidence status:** cardinality cost corroborated by A15; numeric thresholds and the other anti-patterns single source
  (caveated)

### A27: `devops-engineer` agent definition — recommendation-bearing

- **Link / location:** `han-core/agents/devops-engineer.md:4-10`, `:73-76`, `:124-129`, `:254-258`, `:284-299`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The description lists the Four Golden Signals and SLO discipline among a dozen readiness concerns. The
  observability sweep is ten bullets covering latency, traffic, errors, saturation, SLIs and SLOs with multi-window
  burn-rate alerts, traces with correlation IDs, structured logs without personal data, OpenTelemetry with vendor SDKs
  isolated at the collector, and business metrics. Sampling appears as one clause ("sample rate useful on low-frequency
  endpoints"), cardinality only as a vocabulary term, and observability ingestion as one cost axis. Semantic conventions,
  head-versus-tail sampling trade-offs, pipeline processors, and the metrics-versus-events trade-off do not appear. Its
  YAGNI section defers dashboards, log fields, trace spans, SLOs, and error budgets when telemetry is not flowing or
  traffic does not exist.
- **Evidence status:** codebase anchor

### A28: `on-call-engineer` agent definition — recommendation-bearing

- **Link / location:** `han-core/agents/on-call-engineer.md:22-26`, `:116-122`, `:347-366`, `:517-521`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Reviews application source only, at the line-of-code altitude. Its observability protocol checks whether a
  change emits enough to be debugged, propagates correlation IDs, uses structured fields, and keeps personal data,
  tokens, and credentials out of log statements, metric labels, and trace attributes. Its vocabulary already includes
  the SRE workbook's burn-rate thresholds, the observability-driven development gate, wide structured events, and USE,
  citing Google SRE, Majors, Sridharan, and Gregg. It has no cardinality, sampling, or naming checks, and it states that
  the observability platform, alert rules, and dashboard configuration belong to `devops-engineer`.
- **Evidence status:** codebase anchor

### A35: YAGNI rule, Gate 1 and Gate 2 — recommendation-bearing

- **Link / location:** `han-core/references/yagni-rule.md:27-60`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Gate 1 admits a committed item only with evidence it is needed now; the first acceptable kind is a
  user-described need, including a conversation with the user. Gate 2 then asks whether a strictly simpler version
  satisfies the same evidence, and if so the simpler version replaces the larger one until it demonstrably falls short.
- **Evidence status:** codebase anchor
