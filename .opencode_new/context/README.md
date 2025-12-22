# Context Organization - LEAN 4 ProofChecker

## Overview

This directory contains the modular knowledge base for the LEAN 4 ProofChecker system. The context is organized into specialized domains to provide agents with just-in-time, focused knowledge without context window bloat.

## Directory Structure

**Location**: `.opencode/context/` (single unified context directory)

```
.opencode/context/
├── common/
│   ├── system/
│   ├── workflows/
│   ├── templates/
│   ├── repo/
│   ├── standards/
│   └── patterns/
└── project/
    ├── lean4/
    ├── logic/
    ├── math/
    └── physics/
```

## Context Categories

### common/ - Common System Context

This directory contains context that is shared across all projects and agents. It includes system-wide patterns, standards, repository conventions, and templates.

### project/ - Project-Specific Context

This directory contains context that is specific to a particular project. Each subdirectory corresponds to a different project or domain, such as LEAN 4, logic, math, or physics.

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
- **Common context**: `common/` directory
- **Project-specific context**: `project/` directory

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
