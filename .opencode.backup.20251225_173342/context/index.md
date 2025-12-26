# Context Index

**Purpose**: Quick reference for loading context files by domain and priority.  
**Last Updated**: 2025-12-23

## Common (shared standards/system)
**Path**: `.opencode/context/common/{category}/{file}`

- Standards: `standards/code.md`, `standards/documentation.md`, `standards/tests.md`, `standards/patterns.md`, `standards/plan.md`, `standards/report.md`, `standards/summary.md`, `standards/tasks.md`, `standards/analysis.md`
- System: `system/artifact-management.md`, `system/status-markers.md`, `system/state-schema.md`, `system/context-guide.md`
- Workflows: `workflows/delegation.md`, `workflows/review.md`, `workflows/task-breakdown.md`, `workflows/sessions.md`
- Templates: `templates/meta-guide.md`, `templates/orchestrator-template.md`, `templates/subagent-template.md`

## Project Domains

### Logic (canonical proof principles)
**Path**: `.opencode/context/project/logic/{category}/{file}`
- Standards: `standards/proof-conventions.md`, `standards/notation-standards.md`, `standards/naming-conventions.md`
- Processes: `processes/modal-proof-strategies.md`, `processes/temporal-proof-strategies.md`, `processes/proof-construction.md`, `processes/verification-workflow.md`
- Domain: `domain/kripke-semantics-overview.md`, `domain/metalogic-concepts.md`, `domain/proof-theory-concepts.md`, `domain/task-semantics.md`
- README: `logic/README.md`

### Lean4 (overlay for syntax/tooling/readability)
**Path**: `.opencode/context/project/lean4/{category}/{file}`
- Standards: `standards/lean4-style-guide.md`, `standards/proof-conventions-lean.md`, `standards/proof-readability-criteria.md`
- Patterns: `patterns/tactic-patterns.md`
- Processes: `processes/end-to-end-proof-workflow.md`, `processes/maintenance-workflow.md`, `processes/project-structure-best-practices.md`
- Templates: `templates/definition-template.md`, `templates/maintenance-report-template.md`, `templates/new-file-template.md`, `templates/proof-structure-templates.md`
- Tools: `tools/aesop-integration.md`, `tools/leansearch-api.md`, `tools/loogle-api.md`, `tools/lsp-integration.md`, `tools/mcp-tools-guide.md`
- Domain: `domain/dependent-types.md`, `domain/key-mathematical-concepts.md`, `domain/lean4-syntax.md`, `domain/mathlib-overview.md`
- README: `lean4/README.md`

### Math
**Path**: `.opencode/context/project/math/{subdir}/{file}`
- Algebra: `algebra/groups-and-monoids.md`, `algebra/rings-and-fields.md`
- Lattice Theory: `lattice-theory/lattices.md`
- Order Theory: `order-theory/partial-orders.md`
- Topology: `topology/topological-spaces.md`

### Physics
**Path**: `.opencode/context/project/physics/{subdir}/{file}`
- Dynamical Systems: `dynamical-systems/dynamical-systems.md`

### Repo
**Path**: `.opencode/context/project/repo/{file}`
- `project-overview.md`

## Loading Guidance
- Use canonical Logic standards for proof principles/notation; add Lean4 overlay only when writing Lean code.
- Always reference common/system for artifact and status standards (do not duplicate in domain files).
- Prefer Level 1 loads (1–2 files); expand only as task complexity demands.

## References
- Context README: `README.md`
- Lean4 README: `project/lean4/README.md`
- Logic README: `project/logic/README.md`
