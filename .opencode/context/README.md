# Context Organization

**Version**: 2.0  
**Updated**: 2025-12-29  
**Purpose**: Organize context files for efficient loading and clear separation of concerns

---

## Directory Structure

```
.opencode/context/
├── core/                           # General/reusable context
│   ├── standards/                  # Quality standards, formats
│   │   └── subagent-return-format.md
│   ├── workflows/                  # Common workflow patterns
│   │   ├── delegation-guide.md
│   │   └── status-transitions.md
│   ├── system/                     # System-level guides
│   │   ├── routing-guide.md
│   │   ├── orchestrator-guide.md
│   │   ├── context-loading-strategy.md
│   │   └── validation-strategy.md
│   └── templates/                  # Reusable templates
│       ├── command-template.md
│       └── agent-template.md
│
├── project/                        # ProofChecker-specific context
│   ├── lean4/                      # Lean 4 domain knowledge
│   │   ├── domain/
│   │   ├── patterns/
│   │   ├── processes/
│   │   ├── standards/
│   │   ├── templates/
│   │   └── tools/
│   ├── logic/                      # Logic domain knowledge
│   │   ├── domain/
│   │   ├── processes/
│   │   └── standards/
│   ├── math/                       # Math domain knowledge
│   │   ├── algebra/
│   │   ├── lattice-theory/
│   │   ├── order-theory/
│   │   └── topology/
│   ├── physics/                    # Physics domain knowledge
│   │   └── dynamical-systems/
│   └── repo/                       # Repository-specific
│       ├── project-overview.md
│       └── self-healing-implementation-details.md
│
└── README.md                       # This file
```

---

## Core vs Project

### core/
**Purpose**: General, reusable context applicable to any project

**Contents**:
- Standards (return formats, templates)
- Workflows (delegation, status transitions)
- System guides (routing, orchestrator, validation)
- Templates (for creating new components)

**When to use**: Context that doesn't depend on ProofChecker specifics

### project/
**Purpose**: ProofChecker-specific domain knowledge

**Contents**:
- Lean 4 theorem proving knowledge
- Logic domain knowledge (modal, temporal)
- Math domain knowledge (algebra, topology, etc.)
- Physics domain knowledge
- Repository-specific information

**When to use**: Context specific to ProofChecker's domains

---

## Context Loading Strategy

### Three-Tier Loading

**Tier 1: Orchestrator (Minimal)**
- Budget: <5% context window (~10KB)
- Files: routing-guide.md, delegation-guide.md
- Purpose: Routing and delegation safety

**Tier 2: Commands (Targeted)**
- Budget: 10-20% context window (~20-40KB)
- Files: subagent-return-format.md, status-transitions.md, command-specific
- Purpose: Command validation and formatting

**Tier 3: Agents (Domain-Specific)**
- Budget: 60-80% context window (~120-160KB)
- Files: project/lean4/*, project/logic/*, etc.
- Purpose: Domain-specific work with full context

See `core/system/context-loading-strategy.md` for details.

---

## File Naming Conventions

- Use kebab-case: `subagent-return-format.md`
- Be descriptive: `context-loading-strategy.md` not `loading.md`
- Group by purpose: `delegation-guide.md` in workflows/, not system/

---

## Adding New Context Files

### For General/Reusable Context
Add to `core/`:
- Standards → `core/standards/`
- Workflows → `core/workflows/`
- System guides → `core/system/`
- Templates → `core/templates/`

### For ProofChecker-Specific Context
Add to `project/`:
- Lean 4 → `project/lean4/`
- Logic → `project/logic/`
- Math → `project/math/`
- Physics → `project/physics/`
- Repo-specific → `project/repo/`

---

## Migration from Old Structure

**Old** → **New**:
- `system/routing-guide.md` → `core/system/routing-guide.md`
- `system/orchestrator-guide.md` → `core/system/orchestrator-guide.md`
- All project-specific files remain in `project/`

**Removed**:
- `system/` directory (merged into `core/system/`)

**Added**:
- `core/standards/`
- `core/workflows/`
- `core/templates/`
- `core/system/context-loading-strategy.md`
- `core/system/validation-strategy.md`
