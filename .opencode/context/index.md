# Context Index - Lazy-Loading Quick Map

**Version**: 2.0  
**Created**: 2025-12-23  
**Updated**: 2025-12-29 (Task 240 Phase 1)  
**Purpose**: Quick reference map for on-demand context loading following OpenAgents patterns

---

## Usage Pattern

**Routing Stage** (Orchestrator Stages 1-3):
- Load NO context files during routing
- Make routing decisions with command frontmatter only
- Target: <10% context window usage

**Execution Stage** (Agent Stage 4+):
- Load only files needed for specific workflow
- Use index.md to identify required files
- Load context on-demand via @.opencode/context/{category}/{file}

---

## Core Standards (common/standards/)

Load for: Return format, task entry validation, artifact creation

- **subagent-return-format.md** - Standardized return format for all agents (required for all workflows)
- **tasks.md** - Task entry format, required fields, validation rules
- **documentation.md** - Documentation standards, NO EMOJI policy
- **plan.md** - Implementation plan structure and requirements

## Core Workflows (common/workflows/)

Load for: Delegation, lifecycle patterns

- **subagent-delegation-guide.md** - Safe delegation patterns, timeouts, cycle detection
- **command-lifecycle.md** - 8-stage command lifecycle pattern (deprecated after Phase 2, workflows move to agents)

## Core System (common/system/)

Load for: Status updates, artifact management, git commits

- **status-markers.md** - Status transition rules and markers (required for all workflows)
- **artifact-management.md** - Lazy directory creation, artifact naming (required for all workflows)
- **git-commits.md** - Targeted commit patterns
- **state-schema.md** - State file structure

## Core Specs (specs/)

Load selectively: Use grep extraction for specific tasks, avoid loading full 109KB file

- **TODO.md** - Active task list (109KB - load via: `grep -A 50 "^### {task_number}\." TODO.md`)
- **state.json** - Project state tracking (load full file, ~8KB)

---

## Project Context (project/)

Load only when needed for language-specific workflows:

### Lean4 Context (project/lean4/)

Load for: Lean implementation tasks (Language: lean)

- **standards/lean4-style-guide.md** - Lean 4 coding conventions
- **tools/leansearch-api.md** - LeanSearch REST API integration
- **tools/loogle-api.md** - Loogle CLI interface
- **tools/lsp-integration.md** - lean-lsp-mcp integration

### Repo Context (project/repo/)

Load for: General markdown/documentation tasks (Language: markdown)

- **project-overview.md** - Repository structure and organization

### Logic Context (project/logic/)

Load for: Proof theory tasks

- **standards/proof-conventions.md** - Canonical proof principles

---

## Context Loading Examples

**Research Workflow (researcher.md)**:
```
Stage 4 loads:
- @.opencode/context/common/standards/subagent-return-format.md
- @.opencode/context/common/system/status-markers.md
- @.opencode/context/common/system/artifact-management.md
- grep -A 50 "^### {task_number}\." .opencode/specs/TODO.md
- @.opencode/specs/state.json

Language-specific:
- If lean: @.opencode/context/project/lean4/tools/leansearch-api.md
- If markdown: (no additional context)
```

**Planning Workflow (planner.md)**:
```
Stage 4 loads:
- @.opencode/context/common/standards/subagent-return-format.md
- @.opencode/context/common/standards/plan.md
- @.opencode/context/common/system/status-markers.md
- @.opencode/context/common/system/artifact-management.md
- grep -A 50 "^### {task_number}\." .opencode/specs/TODO.md
- @.opencode/specs/state.json
- Research artifacts from task (if exist)
```

**Implementation Workflow (implementer.md, task-executor.md)**:
```
Stage 4 loads:
- @.opencode/context/common/standards/subagent-return-format.md
- @.opencode/context/common/system/status-markers.md
- @.opencode/context/common/system/artifact-management.md
- @.opencode/context/common/system/git-commits.md
- grep -A 50 "^### {task_number}\." .opencode/specs/TODO.md
- @.opencode/specs/state.json
- Plan file (if exists)

Language-specific:
- If lean: @.opencode/context/project/lean4/standards/lean4-style-guide.md
- If lean: @.opencode/context/project/lean4/tools/lsp-integration.md
```

---

## Context Budget Targets (Task 240 Goals)

- **Routing**: <10% context window (Stages 1-3, no context loading)
- **Execution**: 90% context window available (Stage 4+, selective loading)
- **Total context system**: 2,000-2,500 lines (Phase 3 consolidation target)

---

## Migration Notes (Task 240)

**Phase 1 (Current)**: Index pattern established, /research migrated to frontmatter
**Phase 2 (Planned)**: All commands migrate to frontmatter, orchestrator simplified
**Phase 3 (Planned)**: Context consolidation, 70% size reduction
**Phase 4 (Planned)**: Testing and documentation

---

## Legacy Organization (Pre-Task 240)

The sections below preserve the original detailed file listings for reference during migration:

<details>
<summary>Common Context (detailed)</summary>

- Standards: `standards/code.md`, `standards/documentation.md`, `standards/tests.md`, `standards/patterns.md`, `standards/plan.md`, `standards/report.md`, `standards/summary.md`, `standards/tasks.md`, `standards/analysis.md`
- System: `system/artifact-management.md`, `system/status-markers.md`, `system/state-schema.md`, `system/context-guide.md`
- Workflows: `workflows/delegation.md`, `workflows/review.md`, `workflows/task-breakdown.md`, `workflows/sessions.md`
- Templates: `templates/meta-guide.md`, `templates/orchestrator-template.md`, `templates/subagent-template.md`
</details>

<details>
<summary>Lean4 Context (detailed)</summary>

- Standards: `standards/lean4-style-guide.md`, `standards/proof-conventions-lean.md`, `standards/proof-readability-criteria.md`
- Patterns: `patterns/tactic-patterns.md`
- Processes: `processes/end-to-end-proof-workflow.md`, `processes/maintenance-workflow.md`, `processes/project-structure-best-practices.md`
- Templates: `templates/definition-template.md`, `templates/maintenance-report-template.md`, `templates/new-file-template.md`, `templates/proof-structure-templates.md`
- Tools: `tools/aesop-integration.md`, `tools/leansearch-api.md`, `tools/loogle-api.md`, `tools/lsp-integration.md`, `tools/mcp-tools-guide.md`
- Domain: `domain/dependent-types.md`, `domain/key-mathematical-concepts.md`, `domain/lean4-syntax.md`, `domain/mathlib-overview.md`
</details>

<details>
<summary>Logic Context (detailed)</summary>

- Standards: `standards/proof-conventions.md`, `standards/notation-standards.md`, `standards/naming-conventions.md`
- Processes: `processes/modal-proof-strategies.md`, `processes/temporal-proof-strategies.md`, `processes/proof-construction.md`, `processes/verification-workflow.md`
- Domain: `domain/kripke-semantics-overview.md`, `domain/metalogic-concepts.md`, `domain/proof-theory-concepts.md`, `domain/task-semantics.md`
</details>
