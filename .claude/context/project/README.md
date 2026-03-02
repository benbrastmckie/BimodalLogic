# Project Context README

## Purpose

Navigation hub for project-level domain knowledge. Context files in this directory provide standalone domain references that support development across the Logos project. Each subdirectory focuses on a specific domain or toolchain.

## Subdirectories

| Directory | Purpose | README |
|-----------|---------|--------|
| `latex/` | LaTeX documentation patterns, theorem environments, compilation | [latex/README.md](latex/README.md) |
| `lean4/` | Lean 4 and Mathlib patterns, tactics, tooling, style guides | [lean4/README.md](lean4/README.md) |
| `logic/` | Modal logic, temporal logic, semantics, proof theory | [logic/README.md](logic/README.md) |
| `math/` | Mathematical foundations: lattices, topology, category theory | [math/README.md](math/README.md) |
| `meta/` | Agent architecture, system patterns, context revision | [meta/README.md](meta/README.md) |
| `physics/` | Physical domain concepts: dynamical systems, flows | [physics/README.md](physics/README.md) |
| `processes/` | Language-agnostic workflow templates | [processes/README.md](processes/README.md) |
| `repo/` | Repository-specific context: project overview, architecture | [repo/README.md](repo/README.md) |
| `typst/` | Typst documentation patterns, theorem environments, compilation | [typst/README.md](typst/README.md) |

## Guidelines

### Context File Design

Context files should be:
- **Standalone domain references** - Useful independently, without requiring other context
- **Topic-focused** - Each file covers one coherent topic or concept
- **Action-oriented** - Include practical patterns, not just definitions
- **Tool-aware** - Reference relevant Mathlib types, tactics, and tooling where applicable

### Loading Strategy

1. **Start with subdirectory README** - Understand what context is available
2. **Load task-specific files** - Only files relevant to current work
3. **Cross-reference sparingly** - Follow "See Also" links only when needed
4. **Prefer depth over breadth** - Load one topic deeply vs. many topics shallowly

### Boundaries Between Directories

| Domain | math/ | logic/ | lean4/ |
|--------|-------|--------|--------|
| Lattice structures | Abstract theory, Mathlib types | Lattice-based semantics | Tactic patterns |
| Topology | Point-set, metric spaces | Topological semantics | Mathlib integration |
| Category theory | Enriched categories, profunctors | Categorical logic | N/A |
| Proof theory | N/A | Soundness, completeness | Proof conventions |
| Modal logic | N/A | Kripke semantics, frame theory | Implementation patterns |

## Related Context

- `core/` - Cross-project standards, formats, and templates
- `docs/guides/` - Component development guides
- `index.md` - Full context index with loading recommendations
