# Project Structure Guide

## Overview
Organization of .opencode/specs/ directory for project-based artifact management. All artifacts must comply with lazy directory creation and the no-emojis standard.

## Directory Structure

```
.opencode/specs/
├── TODO.md                          # User-facing master task list
├── state.json                       # Global state file
├── archive/
│   ├── state.json                   # Archive state tracking
│   └── NNN_project_name/            # Archived project directories
│       ├── reports/
│       ├── plans/
│       ├── summaries/
│       └── state.json
├── maintenance/
│   ├── state.json                   # Maintenance operations tracking
│   └── report-YYYYMMDD.md           # Maintenance reports
└── NNN_project_name/                # Active project directories
    ├── reports/
    │   ├── research-001.md
    │   ├── analysis-001.md
    │   └── verification-001.md
    ├── plans/
    │   ├── implementation-001.md
    │   └── implementation-002.md    # Revised plan
    ├── summaries/
    │   ├── project-summary.md
    │   └── research-summary.md
    └── state.json                   # Project-specific state
```

## Project Numbering

### Format
- **NNN_project_name** where NNN is zero-padded 3-digit number
- Examples: 001_bimodal_proof_system, 002_semantics_layer, 003_metalogic

### Numbering Rules
1. Start at 000
2. Increment sequentially up to 999
3. Wrap around to 000 after 999 (ensure old project is archived)
4. Zero-pad to 3 digits

## Subdirectories

### reports/
Contains all research and analysis reports:
- **research-NNN.md**: Research findings from researcher agent
- **analysis-NNN.md**: Repository analysis from reviewer agent
- **verification-NNN.md**: Verification reports from reviewer agent
- **refactoring-NNN.md**: Refactoring reports from refactorer agent

### plans/
Contains implementation plans with version control:
- **implementation-001.md**: Initial plan
- **implementation-002.md**: First revision
- **implementation-NNN.md**: Subsequent revisions

Version increments when:
- Plan needs significant changes
- User runs /revise command
- Implementation approach changes

**Research reuse for plans:**
- `/plan {task_number}` must harvest research links already attached to the TODO entry and pass them to the planner.
- Generated plans must include a clearly labeled **Research Inputs** section citing each linked research artifact (or explicitly stating none linked when absent).
- If linked research files are missing/dangling, surface a warning and continue; do not create extra directories while resolving links.

**Command contract boundaries:**
- `/plan` may create the project directory and initial `plans/implementation-001.md` if missing. Creation is lazy: create the project root and `plans/` only when emitting the plan; do **not** pre-create `reports/` or `summaries/`.
- `/revise` reuses the existing project directory and plan link from TODO.md; it increments the plan version in the same `plans/` folder and must **not** create new project directories or change numbering.
- If no plan link exists in TODO.md, `/revise` must fail gracefully and instruct the user to run `/plan` first.
- `/implement` reuses the plan path attached in TODO.md when present and updates that plan in place while executing. When no plan link exists on the TODO entry, `/implement` executes the task directly (no failure) while adhering to lazy directory creation (no project roots/subdirs unless an artifact is written) and keeping numbering/state sync intact. When /implement execution writes implementation artifacts, it must also emit an implementation summary in `summaries/implementation-summary-YYYYMMDD.md`; status-only paths do not emit summaries.
- `/implement`, `/task`, `/review`, and `/todo` must update IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, and TACTIC_REGISTRY.md together when their operations change task/plan/implementation status or sorry/tactic counts.
- `/research` and researcher agents: create the project root immediately before writing the first research artifact, and create only `reports/` (no `plans/` or `summaries/`) when emitting that artifact; do **not** pre-create other subdirs or placeholders.

- `/review` and reviewer agents: create the review project root only when writing the first report/summary, and only create the subdir needed for the artifact being written; never pre-create both `reports/` and `summaries/` up front.

### summaries/
Contains brief summaries for quick reference. **All detailed artifacts MUST have corresponding summary artifacts** to protect the orchestrator's context window.

**Summary Requirements** (enforced by validation):
- **Format**: 3-5 sentences for research/plan/implementation summaries, 2-3 sentences for batch summaries
- **Token Limit**: <100 tokens for individual summaries, <75 tokens for batch summaries
- **Creation**: Lazy directory creation - create `summaries/` only when writing first summary
- **Validation**: Summary artifact must exist before task completion when detailed artifact created

**Summary Types**:
- **research-summary.md**: Key research findings (3-5 sentences, <100 tokens)
  - Example: "Research identified 7 complexity indicators for task routing. Token counting methodology uses chars ÷ 3 estimation. Progressive summarization reduces batch returns by 95%. Validation layer enforces format compliance. Recommended clean-break approach for deployment."
  
- **plan-summary.md**: Implementation plan overview (3-5 sentences, <100 tokens)
  - Example: "8-phase implementation plan with clean-break approach. Phase 0 audits all consumers. Phases 1-6 implement return formats, summaries, complexity routing, and validation. Phase 7 tests integration. Phase 8 updates documentation."
  
- **implementation-summary-YYYYMMDD.md**: What was implemented (3-5 sentences, <100 tokens)
  - Example: "Implemented artifact-first return format for task-executor with <500 token limit. Added summary artifact enforcement for all detailed artifacts. Created complexity router with 7-factor scoring. Differentiated git commit patterns for simple vs complex tasks."
  
- **batch-summary-YYYYMMDD.md**: Batch execution summary (2-3 sentences, <75 tokens)
  - Example: "Successfully completed 10 tasks across 3 execution waves. 5 simple tasks executed directly, 5 complex tasks followed full workflow. All validation checks passed."
  
- **project-summary.md**: Overall project summary (3-5 sentences, <100 tokens)
  - Example: "Task 169 implements context window protection for /implement command. Reduces return formats by 95% through artifact-first approach. Enforces summary artifacts for all detailed work. Adds complexity-based routing and validation layer."

## Template Standards
- Plans must follow `.opencode/context/common/standards/plan.md`.
- Reports must follow `.opencode/context/common/standards/report.md`.
- Summaries must follow `.opencode/context/common/standards/summary.md`.
- Status markers must align with `.opencode/context/common/system/status-markers.md`.
- Commands and agents should load these standards in their context when producing corresponding artifacts.

## TODO.md Format

```markdown
# TODO - LEAN 4 ProofChecker

## High Priority

- [ ] Implement soundness proof for bimodal logic [Project #001](001_bimodal_proof_system/plans/implementation-002.md)
- [ ] Complete Kripke model definition [Project #002](002_semantics_layer/plans/implementation-001.md)

## Medium Priority

- [ ] Refactor proof system axioms for readability [Project #001](001_bimodal_proof_system/reports/verification-001.md)
- [ ] Add documentation for modal operators

## Low Priority

- [ ] Explore alternative proof strategies
- [ ] Research decidability procedures

## Completed

- [x] Research bimodal logic foundations [Project #001](001_bimodal_proof_system/reports/research-001.md)
- [x] Create initial implementation plan [Project #001](001_bimodal_proof_system/plans/implementation-001.md)
```

## Artifact Naming Conventions

### Reports
- **research-NNN.md**: Incremental numbering within project
- **analysis-NNN.md**: Incremental numbering within project
- **verification-NNN.md**: Incremental numbering within project

### Plans
- **implementation-NNN.md**: Version number (increments with revisions)

### Summaries
- **{type}-summary.md**: One per type (project, research, plan, implementation)

## Best Practices
1. **Lazy directory creation (roots + subdirs)**: Create the project root **only when writing the first artifact**. Create subdirectories (`reports/`, `plans/`, `summaries/`) **only at the moment you write an artifact into them**. Never pre-create unused subdirs and never add placeholder files (e.g., `.gitkeep`).
2. **Project directory timing and state writes**: `/task` MUST NOT create project directories. `/plan`, `/research`, `/review`, `/implement`, and subagents may create the project root immediately before writing their first artifact, then lazily create only the needed subdir for that artifact. Do not write project `state.json` until an artifact is produced; state updates should accompany artifact creation.
3. **No emojis**: Commands, agents, and artifacts must not include emojis. Use textual markers and status markers for progress instead.
4. **Use descriptive project names** that reflect the task.
5. **Increment versions properly** when revising plans.
6. **Keep summaries brief** (1-2 pages max).
7. **Link TODO items** to relevant reports/plans.
8. **Update state files** after every operation.
9. **Sync TODO.md** with project progress.
10. **Lean routing**: Use the TODO task `Language` field as the primary Lean intent signal (explicit `--lang` flag overrides; plan `lean:` is secondary). For Lean tasks, route `/implement` to the Lean research subagent when research is requested and the Lean implementation subagent when implementation is requested; validate required MCP servers from `.mcp.json` (at minimum `lean-lsp` via `uvx lean-lsp-mcp`) before creating project roots. If validation fails, return remediation steps and avoid filesystem changes.

## Context Protection

All agents create artifacts in these directories and return only:
- File path (reference)
- Brief summary (3-5 sentences)
- Key findings (bullet points)

This protects the orchestrator's context window from artifact content bloat.

## Related Documentation
- [State Schema Reference](state-schema.md) - Detailed state file schemas
- [Status Markers](status-markers.md) - Standardized status markers and timestamps
- [Plan Standard](../standards/plan.md)
- [Report Standard](../standards/report.md)
- [Summary Standard](../standards/summary.md)
- [Documentation Standards](documentation-standards.md) - Documentation conventions
