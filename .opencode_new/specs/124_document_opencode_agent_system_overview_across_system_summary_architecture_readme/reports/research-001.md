# Research Report: Document .opencode agent system overview across SYSTEM_SUMMARY, ARCHITECTURE, README
- **Task**: 124 - Document .opencode agent system overview across SYSTEM_SUMMARY, ARCHITECTURE, README
- **Status**: [COMPLETED]
- **Started**: 2025-12-22T00:00:00Z
- **Completed**: 2025-12-22T00:00:00Z
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**:
  - .opencode/SYSTEM_SUMMARY.md
  - .opencode/ARCHITECTURE.md
  - .opencode/README.md
  - .opencode/specs/README.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/system/state-schema.md
  - .opencode/context/common/standards/report.md
  - .opencode/context/common/standards/summary.md
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/standards/documentation.md
- **Artifacts**: reports/research-001.md (this file)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md, summary.md, plan.md, documentation.md

## Executive Summary
- The three docs lack explicit lazy directory creation rules, status-marker expectations, and command-to-artifact contracts despite standards defining them.
- System counts and terminology are inconsistent (10 vs. 12 primary agents; status markers differ from standards; legacy TODO markers persist in specs/README and verification examples).
- Key standards to reference: artifact-management (lazy creation, command contracts), status-markers (canonical markers/timestamps), tasks/state-schema (plan reuse and status mirroring), report/summary/plan standards (artifact structures), documentation.md (formatting/line length/no emojis).
- Prioritize harmonizing agent/command maps, directory responsibilities, and guardrails in SYSTEM_SUMMARY; add flow + guardrails + state sync in ARCHITECTURE; add newcomer-friendly overview + links to standards in .opencode/README.

## Context & Scope
- Goal: identify gaps and required updates in SYSTEM_SUMMARY.md, ARCHITECTURE.md, and .opencode/README.md to meet acceptance criteria for task 124.
- Focus areas: agent roles, command contracts, numbering and lazy directory creation rules, artifact/state synchronization, status markers, directory responsibilities, and references to authoritative standards.

## Findings

### Cross-cutting gaps
- Lazy directory creation guardrails are missing or diluted across all three target files despite explicit rules in artifact-management.md (roots only when writing first artifact; only needed subdir; no placeholder files; defer state.json until artifact exists).
- Status-marker expectations are not surfaced; SYSTEM_SUMMARY and README use legacy markers ([ ], [x], [~], [!]) in specs/README reference and lack linkage to status-markers.md; ARCHITECTURE omits marker semantics entirely.
- Command contracts around plan/research/task reuse, plan revision, and status mirroring (tasks.md, artifact-management.md, state-schema.md) are absent from the docs.
- No guidance on summary/report standards, plan research inputs, or summary emission triggers when artifacts are produced.
- Directory responsibilities and what each agent/command may create are not spelled out; risk of pre-creating plans/summaries.

### SYSTEM_SUMMARY.md (target gaps)
- Does not map commands to required artifact outputs and directory responsibilities; lacks lazy creation guardrails and state write timing.
- No status-marker expectation section tying TODO/plan/state to status-markers.md.
- Agent/command counts inconsistent (mentions 10 primary agents, later 12 primary agents/32 specialists).
- Lacks quick “artifact/state sync” reminder (state.json timing, TODO links) and research/plan reuse rules.

### ARCHITECTURE.md (target gaps)
- Architecture flow shows artifact storage but omits lazy creation rules (root only on first artifact; subdir on write; defer state.json until artifact exists).
- No section on status-marker propagation between TODO, plans, and state despite status-markers.md and tasks.md requirements.
- Command/agent contracts (plan vs. revise vs. implement vs. task; research/report creation) not described; plan research-input reuse not mentioned.
- Context management section lacks source standards list; some counts outdated (10 primary agents vs. 12 noted elsewhere) and lacks note on single context directory already stated in SYSTEM_SUMMARY.

### .opencode/README.md (target gaps)
- Quick start and verification sections omit lazy directory creation guardrails and marker expectations; verification examples use `find`/`grep` and legacy counts.
- Does not tell newcomers where to find standards (artifact-management.md, status-markers.md, tasks.md, report/plan/summary standards, state-schema.md, documentation.md) or how command contracts apply (plan reuse, research inputs, status mirroring).
- Directory tree lists subdirs but not responsibilities/creation rules; retains legacy status markers from specs/README and no pointer to status-markers.md.

## Decisions
- Use artifact-management.md as the canonical source for lazy directory creation and command contracts; surface concise guardrails in all three docs.
- Use status-markers.md as the canonical marker set; include expectation to mirror markers/timestamps across TODO, plans, and state; remove legacy markers references.
- Provide a consistent agent/command map (counts + roles) and directory responsibility table in SYSTEM_SUMMARY and link to detailed catalogs instead of duplicating.

## Recommendations (prioritized)

### SYSTEM_SUMMARY.md
1) Add "Agent & Command Map" section: brief roles, counts (align to current authoritative counts), and per-command artifact responsibilities (research → reports/, plan/revise → plans/, implement/task → update plan status & summaries when emitted, document → summaries/docs) with lazy creation guardrails.
2) Add "Directory Responsibilities & Guardrails" subsection referencing artifact-management.md: project root only when writing first artifact; only needed subdir; defer state.json until artifact exists; no placeholder dirs; single context directory note.
3) Add "Status Markers & Sync" callout linking status-markers.md: require [NOT STARTED]/[IN PROGRESS]/[BLOCKED]/[ABANDONED]/[COMPLETED] with timestamps mirrored across TODO, plans, and state.
4) Normalize counts and terminology (single orchestrator, 10 primary agents, 19 specialists—verify authoritative counts) and remove conflicting numbers.

### ARCHITECTURE.md
1) Expand artifact storage flow to include lazy creation guardrails and state write timing; note command-specific creation (research/report only creates root+reports; plan/revise root+plans; summaries only when emitted).
2) Add status propagation section: how TODO, plans, and state mirror status markers per status-markers.md/tasks.md; include plan phase marker rules.
3) Document command/agent contracts and inputs: plan must reuse research links; revise increments plan version; task/implement reuse linked plan and sync status; research/report creation constraints; no pre-creation of summaries/plans when not emitting.
4) Add references list pointing to artifact-management.md, status-markers.md, state-schema.md, tasks.md, report/plan/summary standards, documentation.md to avoid duplication.

### .opencode/README.md
1) Upfront newcomer-friendly overview: what the agent system does, how commands map to agents, and where to find standards (link to artifact-management.md, status-markers.md, tasks.md, report/plan/summary standards, state-schema.md, documentation.md).
2) Add concise lazy directory creation and status-marker expectations in Quick Start/Project Structure: root only on first artifact; subdir only on write; no placeholders; markers per status-markers.md.
3) Update verification and counts to match authoritative numbers and remove legacy marker examples; avoid recommending `find`/`grep` if not aligned; keep commands brief.
4) In Project Structure, clarify directory responsibilities (what each subdir stores, when created) and point to specs/README.md for artifact layout.

## Risks & Mitigations
- **Risk**: Conflicting counts remain. **Mitigation**: Use a single authoritative count and cross-link agent catalogs for details.
- **Risk**: Readers miss guardrails. **Mitigation**: Use callouts and link to artifact-management.md and status-markers.md in each doc.
- **Risk**: Duplication bloat. **Mitigation**: Keep details brief and link to standards/context files instead of repeating.

## Appendix
- References: artifact-management.md; status-markers.md; tasks.md; state-schema.md; report.md; summary.md; plan.md; documentation.md; specs/README.md; target docs (SYSTEM_SUMMARY.md, ARCHITECTURE.md, .opencode/README.md).
