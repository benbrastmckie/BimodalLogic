# Context Organization - LEAN 4 ProofChecker

## Overview

This directory contains the modular knowledge base for the LEAN 4 ProofChecker system. The context is organized into specialized domains to provide agents with just-in-time, focused knowledge without context window bloat.

## Directory Structure

**Location**: `.opencode/context/` (single unified context directory)

```
.opencode/context/
├── lean4/              # LEAN 4 language and theorem proving
├── logic/              # Logic theory (proof theory, semantics, metalogic)
├── math/               # Mathematical domains
│   ├── algebra/        # Algebraic structures
│   ├── topology/       # Topological spaces
│   ├── order-theory/   # Partial orders and lattices
│   └── lattice-theory/ # Lattice structures
├── physics/            # Physics domains
│   └── dynamical-systems/ # Dynamical systems theory
├── core/               # Core system patterns, standards, repo, templates
│   ├── patterns/       # Core patterns
│   ├── repo/           # Repository conventions
│   ├── standards/      # System standards
│   ├── system/         # System architecture
│   ├── templates/      # Meta-system templates
│   └── workflows/      # Development workflows
└── project/            # Project-specific context
```

## Context Categories

### lean4/ - LEAN 4 Knowledge
Core knowledge about the LEAN 4 language, mathlib, and theorem proving.

See [lean4/README.md](lean4/README.md) for complete organization and file
listings.

**Current structure**:
- `domain/` - Core concepts (key-mathematical-concepts.md, lean4-syntax.md, mathlib-overview.md)
- `patterns/` - Common patterns (tactic-patterns.md)
- `processes/` - Workflows (end-to-end-proof-workflow.md, maintenance-workflow.md, project-structure-best-practices.md)
- `standards/` - Quality guidelines (documentation-standards.md, lean4-style-guide.md, lean-style.md, proof-conventions.md, proof-readability-criteria.md)
- `templates/` - Boilerplate (definition-template.md, maintenance-report-template.md, new-file-template.md, proof-structure-templates.md)
- `tools/` - Tool integration (aesop-integration.md, leansearch-api.md, loogle-api.md, lsp-integration.md, mcp-tools-guide.md)
- `style-guide.md` - LEAN 4 style guide
- `theorem-proving-guidelines.md` - Theorem proving best practices
- `translation-conventions.md` - Translation conventions

### logic/ - Logic Theory
Formal logic knowledge for bimodal logic development.

See [logic/README.md](logic/README.md) for complete organization and file
listings.

**Current structure**:
- `domain/` - Core concepts (metalogic-concepts.md, proof-theory-concepts.md, task-semantics.md, kripke-semantics-overview.md)
- `processes/` - Logic workflows (modal-proof-strategies.md, proof-construction.md, temporal-proof-strategies.md, verification-workflow.md)
- `standards/` - Logic quality standards (naming-conventions.md, notation-standards.md, proof-conventions.md)

### math/ - Mathematical Domains
Comprehensive mathematical knowledge from mathlib4.

See [math/README.md](math/README.md) for complete organization and file
listings.

**Current structure**:
- `algebra/` - Algebraic structures (groups, monoids, rings, fields)
- `lattice-theory/` - Lattice structures (lattices.md)
- `order-theory/` - Order structures (partial-orders.md)
- `topology/` - Topological spaces (topological-spaces.md)

### physics/ - Physics Domains
Physics and applied mathematics knowledge.

**dynamical-systems/** - Dynamical systems theory
- `dynamical-systems.md` - Discrete/continuous systems, chaos, ergodic theory

### core/ - Core System Patterns
System-wide patterns, standards, repository conventions, and templates.

**patterns/** - Core patterns
- `essential-patterns.md` - Core patterns

**repo/** - Repository Conventions
- `state-schema.md` - State file schemas and formats
- `status-markers.md` - Status marker specification for tasks and plans
- `documentation-standards.md` - Documentation conventions for AI system

**standards/** - Quality standards
- `analysis.md` - Analysis standards
- `code.md` - Code standards
- `docs.md` - Documentation standards
- `patterns.md` - Pattern standards
- `tests.md` - Testing standards

**system/** - System guides
- `context-guide.md` - Context management
- `project-overview.md` - Technology stack, patterns, workflows
- `artifact-management.md` - Project directory organization

**templates/** - Meta-System Templates
- `BUILDER-GUIDE.md` - Guide to building agents
- `orchestrator-template.md` - Orchestrator template
- `subagent-template.md` - Subagent template
- `README.md` - Template overview

**workflows/** - System workflows
- `delegation.md` - Delegation patterns
- `review.md` - Review workflows
- `sessions.md` - Session management
- `task-breakdown.md` - Task decomposition



## Usage Guidelines

### Context Allocation Levels

**Level 1: Complete Isolation (80% of tasks)**
- 1-2 context files
- Focused, specific knowledge
- Minimal overhead

**Level 2: Filtered Context (20% of tasks)**
- 3-4 context files
- Multiple knowledge areas
- Balanced context vs. performance

**Level 3: Comprehensive Context (<5% of tasks)**
- 4-6 context files
- Broad domain knowledge
- Maximum context for complex tasks

### File Size Guidelines

- **Target**: 50-200 lines per file
- **Rationale**: Focused, modular knowledge
- **Benefit**: Easy to load, understand, and maintain

### Naming Conventions

- **Lowercase with hyphens**: `proof-theory-concepts.md`
- **Descriptive names**: Clearly indicate content
- **Consistent structure**: Similar files in similar locations

## How Agents Use Context

### Orchestrator
- Determines which context files are relevant
- Allocates appropriate context level
- Passes context references to agents

### Primary Agents
- Receive context file references
- Load only necessary context
- Pass filtered context to subagents

### Specialist Subagents
- Receive minimal, focused context
- Create detailed artifacts
- Return only references and summaries

## Context Protection Pattern

All agents follow this pattern:
1. **Receive**: Context file references (not full content)
2. **Load**: Only necessary context files
3. **Process**: Create detailed artifacts in `.opencode/specs/`
4. **Return**: File references + brief summaries (not full artifacts)

This protects context windows from bloat while preserving all detailed work.

## Adding New Context

### When to Add
- New domain knowledge needed
- New workflow or process
- New standards or conventions
- New templates or patterns

### Where to Add
- **Domain knowledge**: Appropriate domain directory (lean4/, logic/, math/, physics/)
- **Processes**: processes/ subdirectory
- **Standards**: standards/ subdirectory
- **Templates**: templates/ subdirectory
- **Patterns**: patterns/ subdirectory

### How to Add
1. Choose appropriate directory
2. Create file with descriptive name
3. Follow 50-200 line guideline
4. Use consistent structure (Overview, Definitions, Theorems, Examples, etc.)
5. Include mathlib imports and references
6. Add business rules and common pitfalls

## Context File Structure

Standard structure for context files:

```markdown
# Title

## Overview
Brief description of the topic

## Core Definitions
Key definitions with LEAN 4 code

## Key Theorems
Important theorems and properties

## Common Patterns
Usage patterns and examples

## Mathlib Imports
Relevant mathlib imports

## Common Tactics
Tactics for this domain

## Standard Examples
Concrete examples

## Business Rules
Guidelines and best practices

## Common Pitfalls
Things to avoid

## Relationships
Related topics and dependencies

## References
External references and documentation
```

## Maintenance

### Regular Updates
- Keep synchronized with mathlib4 updates
- Add new patterns as discovered
- Remove outdated information
- Refine based on usage

### Quality Checks
- Verify file sizes (50-200 lines)
- Check for duplication
- Ensure clear separation of concerns
- Validate LEAN 4 code examples

### Documentation
- Keep this README current
- Document new directories
- Explain organizational decisions

## Future Additions

Planned context additions:
- **logic/processes/** - Logic-specific workflows
- **logic/standards/** - Logic quality standards
- **logic/templates/** - Logic proof templates
- **logic/patterns/** - Common logic patterns
- **math/analysis/** - Real and complex analysis
- **math/category-theory/** - Category theory
- **math/linear-algebra/** - Linear algebra and vector spaces
- **physics/mechanics/** - Classical mechanics
- **physics/quantum/** - Quantum mechanics

## Performance Characteristics

### Context Efficiency
- **80%** of tasks use Level 1 (1-2 files)
- **20%** of tasks use Level 2 (3-4 files)
- **<5%** of tasks use Level 3 (4-6 files)

### Benefits
- **Reduced overhead**: Only load necessary knowledge
- **Faster routing**: Clear context allocation decisions
- **Better focus**: Agents get exactly what they need
- **Maintainability**: Modular, focused files

## References

- LEAN 4 documentation: https://leanprover.github.io/lean4/doc/
- Mathlib4 documentation: https://leanprover-community.github.io/mathlib4_docs/
- Mathematics in Lean: https://leanprover-community.github.io/mathematics_in_lean/
- Theorem Proving in Lean 4: https://leanprover.github.io/theorem_proving_in_lean4/

---

**This context organization provides a robust, scalable foundation for LEAN 4 theorem proving with intelligent knowledge management.**
