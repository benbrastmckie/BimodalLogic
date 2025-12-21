# Logic Context

**Purpose**: Logic theory knowledge for AI agents  
**Last Updated**: December 20, 2025

## Overview

This directory provides formal logic knowledge for AI agents working on
bimodal logic development. It contains comprehensive coverage of proof theory,
semantics, metalogic, and type theory, organized to support agents at all
stages of logic formalization and proof development.

The context covers both syntactic (proof-theoretic) and semantic
(model-theoretic) aspects of logic, with emphasis on modal logic systems,
Kripke semantics, and metatheoretic properties like soundness and
completeness. Agents use this context to understand logical foundations and
apply them to LEAN 4 formalization.

## Organization

This directory is organized into:

### domain/

Core logic concepts and foundational knowledge.

**Files**:
- `metalogic-concepts.md` - Soundness and completeness theorems, metatheory,
  consistency, decidability, model theory fundamentals
- `proof-theory-concepts.md` - Detailed proof theory including axioms,
  inference rules, natural deduction, sequent calculus, Hilbert systems
- `task-semantics.md` - Task-based semantics for Logos (task frames,
  world-histories, temporal durations)
- `kripke-semantics-overview.md` - Standard Kripke semantics overview (for
  comparison with task semantics)

## Quick Reference

| Concept | File | Subdirectory |
|---------|------|--------------|
| Proof theory | proof-theory-concepts.md | domain/ |
| Task semantics | task-semantics.md | domain/ |
| Kripke semantics | kripke-semantics-overview.md | domain/ |
| Soundness/completeness | metalogic-concepts.md | domain/ |
| Metatheory | metalogic-concepts.md | domain/ |
| Dependent types | dependent-types.md | ../lean4/domain/ |
| Type theory | dependent-types.md | ../lean4/domain/ |

## Usage by Agents

### Primary Users

- **proof-developer**: Uses proof theory and semantics for proof
  implementation
- **researcher**: Uses all subdirectories for comprehensive logic research
- **planner**: Uses metalogic for complexity analysis and proof strategies
- **proof-strategy-advisor**: Uses proof theory for strategy recommendations

### Context Allocation

- **Level 1**: Single file (e.g., `kripke-semantics.md` for semantic proofs)
- **Level 2**: 2-3 files (e.g., proof theory + semantics for soundness proofs)
- **Level 3**: 4-5 files (comprehensive logic context for complex
  metatheoretic proofs)

### Common Usage Patterns

**Semantic Proofs**:
1. Load `domain/task-semantics.md`
2. Apply task frame constructions
3. Verify satisfaction relations

**Soundness Proofs**:
1. Load `domain/proof-theory-concepts.md`
2. Load `domain/task-semantics.md`
3. Load `domain/metalogic-concepts.md`
4. Construct soundness argument

**Type-Theoretic Formalization**:
1. Load `../lean4/domain/dependent-types.md`
2. Apply Curry-Howard correspondence
3. Construct inductive type definitions

## Adding New Context

### When to Add

- New logic system requires documentation (temporal logic, epistemic logic)
- New proof technique needs explanation
- New semantic construction discovered
- New metatheoretic result formalized

### Where to Add

- **Domain concepts**: Add to `domain/` subdirectory
- **Proof techniques**: Add to `domain/` subdirectory
- **Semantic constructions**: Add to `domain/` subdirectory
- **Metatheoretic results**: Add to `domain/` subdirectory
- **Type theory**: Add to `../lean4/domain/` subdirectory

### Guidelines

- Keep files focused (50-200 lines)
- Include LEAN 4 code examples
- Provide concrete model constructions
- Link to mathlib imports
- Document common pitfalls
- Follow documentation-standards.md format

### Planned Additions

- `processes/` - Logic-specific proof workflows
- `standards/` - Logic formalization standards
- `templates/` - Logic proof templates
- `patterns/` - Common logic proof patterns

## Related Context

- [Parent Context README](../README.md) - Overall context organization
- [LEAN 4 Context](../lean4/README.md) - LEAN 4 language knowledge
- [Math Context](../math/README.md) - Mathematical foundations
- [Core Standards](../core/standards/) - System-wide quality standards
- [Builder Templates](../templates/README.md) - Meta-system templates

## External Resources

- [Modal Logic (Stanford Encyclopedia)](https://plato.stanford.edu/entries/logic-modal/)
- [Kripke Semantics](https://plato.stanford.edu/entries/logic-modal/#KriSem)
- [Proof Theory](https://plato.stanford.edu/entries/proof-theory/)
- [Type Theory](https://plato.stanford.edu/entries/type-theory/)
