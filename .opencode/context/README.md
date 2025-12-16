# Context Organization - LEAN 4 ProofChecker

## Overview

This directory contains the modular knowledge base for the LEAN 4 ProofChecker system. The context is organized into specialized domains to provide agents with just-in-time, focused knowledge without context window bloat.

## Directory Structure

```
context/
├── lean4/              # LEAN 4 language and theorem proving
├── logic/              # Logic theory (proof theory, semantics, metalogic)
├── math/               # Mathematical domains
│   ├── algebra/        # Algebraic structures
│   ├── topology/       # Topological spaces
│   ├── order-theory/   # Partial orders and lattices
│   └── lattice-theory/ # Lattice structures
├── physics/            # Physics domains
│   └── dynamical-systems/ # Dynamical systems theory
├── specs/              # Project management and artifact organization
├── core/               # Core system patterns and standards
├── builder-templates/  # Meta-system templates
└── project/            # Project-specific context
```

## Context Categories

### lean4/ - LEAN 4 Knowledge
Core knowledge about the LEAN 4 language, mathlib, and theorem proving.

**domain/** - Core concepts
- `lean4-syntax.md` - LEAN 4 syntax and metaprogramming
- `mathlib-overview.md` - Mathlib structure and organization
- `key-mathematical-concepts.md` - Type theory and foundations

**processes/** - Workflows
- `end-to-end-proof-workflow.md` - Complete proof development process
- `project-structure-best-practices.md` - Project organization

**standards/** - Quality guidelines
- `lean4-style-guide.md` - LEAN 4 coding style
- `proof-conventions.md` - Proof writing conventions
- `documentation-standards.md` - Documentation requirements
- `proof-readability-criteria.md` - Readability standards

**templates/** - Boilerplate
- `definition-template.md` - Definition structure
- `proof-structure-templates.md` - Proof templates
- `new-file-template.md` - File templates

**patterns/** - Reusable patterns
- `tactic-patterns.md` - Common tactic patterns

**tools/** - Tool guides
- `mcp-tools-guide.md` - MCP server usage

### logic/ - Logic Theory
Formal logic knowledge for bimodal logic development.

**proof-theory/** - Syntactic proof systems
- `proof-theory-concepts.md` - Axioms, inference rules, proof systems, sequent calculus

**semantics/** - Model-theoretic semantics
- `kripke-semantics.md` - Kripke models, satisfaction, bisimulation, filtration

**metalogic/** - Metatheoretic properties
- `soundness-completeness.md` - Soundness, completeness, decidability, consistency

**type-theory/** - Type-theoretic foundations
- `dependent-types.md` - Dependent types, universes, Curry-Howard, inductive types

**processes/** - Logic workflows (to be added)
- Logic-specific proof workflows
- Semantic construction processes

**standards/** - Logic standards (to be added)
- Proof theory standards
- Semantic standards

**templates/** - Logic templates (to be added)
- Proof theory templates
- Semantic templates

**patterns/** - Logic patterns (to be added)
- Common proof patterns
- Semantic patterns

**tools/** - Logic tools (to be added)
- Logic-specific tools

### math/ - Mathematical Domains
Comprehensive mathematical knowledge from mathlib4.

**algebra/** - Algebraic structures
- `groups-and-monoids.md` - Group theory, monoids, homomorphisms
- `rings-and-fields.md` - Ring theory, fields, ideals, polynomials

**topology/** - Topological spaces
- `topological-spaces.md` - Point-set topology, metric spaces, continuity

**order-theory/** - Order structures
- `partial-orders.md` - Preorders, partial orders, linear orders, well-founded orders

**lattice-theory/** - Lattice structures
- `lattices.md` - Lattices, Boolean algebras, complete lattices

### physics/ - Physics Domains
Physics and applied mathematics knowledge.

**dynamical-systems/** - Dynamical systems theory
- `dynamical-systems.md` - Discrete/continuous systems, chaos, ergodic theory

### specs/ - Project Management
Project and artifact organization.

- `project-structure.md` - Project directory organization
- `artifact-organization.md` - Artifact naming and structure (to be added)
- `state-management.md` - State file formats (to be added)

### core/ - Core System Patterns
System-wide patterns and standards.

**standards/** - Quality standards
- `analysis.md` - Analysis standards
- `code.md` - Code standards
- `docs.md` - Documentation standards
- `patterns.md` - Pattern standards
- `tests.md` - Testing standards

**workflows/** - System workflows
- `delegation.md` - Delegation patterns
- `review.md` - Review workflows
- `sessions.md` - Session management
- `task-breakdown.md` - Task decomposition

**system/** - System guides
- `context-guide.md` - Context management

- `essential-patterns.md` - Core patterns

### builder-templates/ - Meta-System
Templates for creating agents and commands.

- `BUILDER-GUIDE.md` - Guide to building agents
- `orchestrator-template.md` - Orchestrator template
- `subagent-template.md` - Subagent template
- `README.md` - Template overview

### project/ - Project Context
Project-specific information.

- `project-context.md` - Technology stack, patterns, workflows

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
