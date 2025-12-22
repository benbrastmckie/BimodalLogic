# Context Index

**Purpose**: Quick reference for context file loading by AI agents  
**Last Updated**: December 20, 2025

## Quick Map - Core System

**Path**: `.opencode/context/common/{category}/{file}`

```
code        → standards/code.md       [critical] implement, refactor, architecture
docs        → standards/docs.md       [critical] write docs, README, documentation
tests       → standards/tests.md      [critical] write tests, testing, TDD → deps: code
patterns    → standards/patterns.md   [high]     error handling, security, validation
analysis    → standards/analysis.md   [high]     analyze, investigate, debug

delegation  → workflows/delegation.md [high]     delegate, task tool, subagent
review      → workflows/review.md     [high]     review code, audit → deps: code, patterns
breakdown   → workflows/task-breakdown.md [high] break down, 4+ files → deps: delegation
sessions    → workflows/sessions.md   [medium]   session management, cleanup

project     → system/project-overview.md [medium] tech stack, patterns, workflows
artifacts   → system/artifact-management.md [medium] project directory organization
context     → system/context-guide.md [medium]   context management
```

## Quick Map - LEAN 4 Domain

**Path**: `.opencode/context/lean4/{category}/{file}`

```
Domain Knowledge (4 files):
  dependent-types.md, key-mathematical-concepts.md, lean4-syntax.md, mathlib-overview.md

Standards (5 files):
  documentation.md, lean-style.md, lean4-style-guide.md, 
  proof-conventions.md, proof-readability-criteria.md

Processes (3 files):
  end-to-end-proof-workflow.md, maintenance-workflow.md, 
  project-structure-best-practices.md

Templates (4 files):
  definition-template.md, maintenance-report-template.md, 
  new-file-template.md, proof-structure-templates.md

Patterns (1 file):
  tactic-patterns.md

Tools (5 files):
  aesop-integration.md, leansearch-api.md, loogle-api.md, 
  lsp-integration.md, mcp-tools-guide.md
```

## Quick Map - Logic Domain

**Path**: `.opencode/context/logic/{category}/{file}`

```
Domain Knowledge (4 files):
  kripke-semantics-overview.md, metalogic-concepts.md, 
  proof-theory-concepts.md, task-semantics.md

Processes (4 files):
  modal-proof-strategies.md, proof-construction.md, 
  temporal-proof-strategies.md, verification-workflow.md

Standards (3 files):
  naming-conventions.md, notation-standards.md, proof-conventions.md
```

## Quick Map - Math & Physics

**Path**: `.opencode/context/math/{category}/{file}`

```
Algebra: groups-and-monoids.md, rings-and-fields.md
Lattice Theory: lattices.md
Order Theory: partial-orders.md
Topology: topological-spaces.md
```

**Path**: `.opencode/context/physics/{category}/{file}`

```
Dynamical Systems: dynamical-systems.md
```

## Quick Map - Repository & Meta

**Path**: `.opencode/context/repo/{file}`

```
documentation.md, state-schema.md, status-markers.md
```

**Path**: `.opencode/context/templates/{file}`

```
BUILDER-GUIDE.md, README.md, orchestrator-template.md, subagent-template.md
```

## Loading Instructions

**Format**: `id → path [priority] triggers → deps: dependencies`

**For common tasks**: Use quick map above  
**For keyword matching**: Scan triggers in quick map  
**For dependencies**: Load dependent contexts alongside main context

**Context Levels**:
- **Level 1** (80%): 1-2 files - focused, specific knowledge
- **Level 2** (20%): 3-4 files - multiple knowledge areas
- **Level 3** (<5%): 4-6 files - comprehensive domain knowledge

## Directory Organization

```
.opencode/context/
├── core/           # System standards, workflows, guides
├── lean4/          # LEAN 4 language and theorem proving (22 files)
├── logic/          # Logic theory and proof strategies (11 files)
├── math/           # Mathematical domains (5 files)
├── physics/        # Physics domains (1 file)
├── repo/           # Repository conventions (3 files)
└── templates/      # Meta-system templates (4 files)
```

**Total**: 45+ context files organized by domain

## Common Usage Patterns

**LEAN 4 Proof Development**:
- Load: `lean4/domain/lean4-syntax.md`, `lean4/patterns/tactic-patterns.md`
- Optional: `lean4/standards/proof-conventions.md`

**Logic Formalization**:
- Load: `logic/domain/task-semantics.md`, `logic/domain/proof-theory-concepts.md`
- Optional: `logic/processes/modal-proof-strategies.md`

**Code Quality**:
- Load: `core/standards/code.md`, `core/standards/patterns.md`
- Optional: `core/workflows/review.md`

**Documentation**:
- Load: `core/standards/docs.md`, `lean4/standards/documentation.md`

## References

- [Full Context README](README.md) - Complete organization and guidelines
- [LEAN 4 README](lean4/README.md) - LEAN 4 context details
- [Logic README](logic/README.md) - Logic context details
- [Math README](math/README.md) - Math context details
