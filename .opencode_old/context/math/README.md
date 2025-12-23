# Math Context

**Purpose**: Mathematical domain knowledge for AI agents  
**Last Updated**: December 20, 2025

## Overview

This directory provides mathematical domain knowledge from mathlib4 for AI
agents working on theorem proving. It covers core mathematical structures
including algebra, topology, order theory, and lattice theory, organized to
support agents in understanding and applying mathematical concepts in LEAN 4
formalizations.

The context focuses on structures commonly used in logic formalization
(lattices, orders, algebraic structures) and provides practical guidance for
working with mathlib4 definitions, theorems, and tactics. Agents use this
context to understand mathematical foundations and apply them to proof
development.

## Organization

This directory is organized into:

### algebra/

Algebraic structures and their properties.

**Files**:
- `groups-and-monoids.md` - Group theory, monoids, semigroups, homomorphisms,
  subgroups
- `rings-and-fields.md` - Ring theory, fields, ideals, polynomials, ring
  homomorphisms

### lattice-theory/

Lattice structures and Boolean algebras.

**Files**:
- `lattices.md` - Lattices, semilattices, Boolean algebras, complete lattices,
  Heyting algebras

### order-theory/

Order structures and relations.

**Files**:
- `partial-orders.md` - Preorders, partial orders, linear orders,
  well-founded orders, order embeddings

### topology/

Topological spaces and continuity.

**Files**:
- `topological-spaces.md` - Point-set topology, metric spaces, continuity,
  compactness, connectedness

## Quick Reference

| Concept | File | Subdirectory |
|---------|------|--------------|
| Groups and monoids | groups-and-monoids.md | algebra/ |
| Rings and fields | rings-and-fields.md | algebra/ |
| Lattices | lattices.md | lattice-theory/ |
| Boolean algebras | lattices.md | lattice-theory/ |
| Partial orders | partial-orders.md | order-theory/ |
| Well-founded orders | partial-orders.md | order-theory/ |
| Topological spaces | topological-spaces.md | topology/ |
| Metric spaces | topological-spaces.md | topology/ |

## Usage by Agents

### Primary Users

- **proof-developer**: Uses algebraic and order structures for logic
  formalization
- **researcher**: Uses all subdirectories for mathematical research
- **planner**: Uses complexity information for proof planning
- **dependency-mapper**: Uses import information for dependency analysis

### Context Allocation

- **Level 1**: Single file (e.g., `lattices.md` for lattice-based proofs)
- **Level 2**: 2-3 files (e.g., algebra + order theory for algebraic
  structures)
- **Level 3**: 4 files (comprehensive mathematical context for complex proofs)

### Common Usage Patterns

**Lattice-Based Proofs**:
1. Load `lattice-theory/lattices.md`
2. Apply lattice properties and theorems
3. Use mathlib lattice tactics

**Algebraic Structure Proofs**:
1. Load `algebra/groups-and-monoids.md` or `algebra/rings-and-fields.md`
2. Apply algebraic properties
3. Use mathlib algebra tactics

**Order-Theoretic Proofs**:
1. Load `order-theory/partial-orders.md`
2. Apply order properties and well-foundedness
3. Use mathlib order tactics

## Adding New Context

### When to Add

- New mathematical domain needed (analysis, category theory, linear algebra)
- New mathlib4 structures require documentation
- New proof techniques discovered
- New common patterns identified

### Where to Add

- **Algebraic structures**: Add to `algebra/` subdirectory
- **Order structures**: Add to `order-theory/` subdirectory
- **Lattice structures**: Add to `lattice-theory/` subdirectory
- **Topological structures**: Add to `topology/` subdirectory
- **New domains**: Create new subdirectory (e.g., `analysis/`,
  `category-theory/`)

### Guidelines

- Keep files focused (50-200 lines)
- Include LEAN 4 code examples
- Document mathlib imports
- Provide common tactics
- Include standard examples
- Document common pitfalls
- Follow documentation-standards.md format

### Planned Additions

- `analysis/` - Real and complex analysis
- `category-theory/` - Category theory and functors
- `linear-algebra/` - Vector spaces and linear maps
- `number-theory/` - Number-theoretic structures

## Related Context

- [Parent Context README](../README.md) - Overall context organization
- [LEAN 4 Context](../lean4/README.md) - LEAN 4 language knowledge
- [Logic Context](../logic/README.md) - Logic theory knowledge
- [Core Standards](../core/standards/) - System-wide quality standards

## External Resources

- [Mathlib4 Documentation](https://leanprover-community.github.io/mathlib4_docs/)
- [Mathematics in Lean](https://leanprover-community.github.io/mathematics_in_lean/)
- [Mathlib4 Algebra](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra.html)
- [Mathlib4 Order](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Order.html)
- [Mathlib4 Topology](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Topology.html)
