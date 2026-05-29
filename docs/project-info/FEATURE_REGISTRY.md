# Feature Registry

**Last Updated**: 2026-05-29
**Status**: Current features of the Bimodal library

This document tracks the implemented features and capabilities of the Bimodal Lean 4 library.
For sorry placeholder tracking, see [SORRY_REGISTRY.md](SORRY_REGISTRY.md).
For implementation status by module, see [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md).

## Core Logic Features

### Bimodal Logic TM

- **Status**: Complete and verified
- **Description**: Full formalization of the bimodal logic TM combining S5 modal logic with
  linear temporal logic, including syntax, proof system, semantics, soundness, and completeness.
- **Key Files**:
  - `Theories/Bimodal/Syntax/Formula.lean` - Formula type with all operators
  - `Theories/Bimodal/ProofSystem/Axioms.lean` - 14 axiom schemata
  - `Theories/Bimodal/Metalogic/Soundness.lean` - Soundness theorem (proved)
  - `Theories/Bimodal/Metalogic/Completeness.lean` - Completeness theorem (proved)

### Perpetuity Principles

- **Status**: Complete (P1-P6 all proven)
- **Description**: Six perpetuity principles connecting modal necessity (□) with eternal
  truth (△) and temporal operators.
- **Key File**: `Theories/Bimodal/Theorems/Perpetuity.lean`
- **Principles**: `□φ → △φ` (P1), `▽φ → ◇φ` (P2), `□φ → Gφ` (P3), `Pφ → ◇φ` (P4),
  `□φ → Hφ` (P5), `Fφ → ◇φ` (P6)

### Deduction Theorem

- **Status**: Complete
- **Description**: If `φ :: Γ ⊢ ψ` then `Γ ⊢ φ → ψ`.
- **Key File**: `Theories/Bimodal/Metalogic/DeductionTheorem.lean`

### Propositional Theorems

- **Status**: Complete (10 theorems, zero sorry)
- **Description**: Key propositional theorems in Hilbert-style calculus including double
  negation elimination, ex contradictione quodlibet, law of excluded middle, and combinators.
- **Key File**: `Theories/Bimodal/Theorems/Propositional.lean`

## Automation Features

### Custom Tactics

- **Status**: Active
- **Description**: Custom Lean 4 tactics for TM modal-temporal reasoning.
- **Key File**: `Theories/Bimodal/Automation/Tactics.lean`
- **Theory-Specific Registry**: See [Theories/Bimodal/docs/project-info/TACTIC_REGISTRY.md](../../Theories/Bimodal/docs/project-info/TACTIC_REGISTRY.md)

### Proof Search

- **Status**: Active
- **Description**: Automated proof search with IDDFS, BoundedDFS, and BestFirst strategies,
  plus pattern learning for repeated goals.
- **Key File**: `Theories/Bimodal/Automation/ProofSearch.lean`

### Aesop Integration

- **Status**: Active
- **Description**: Aesop rule registration for TM automation with forward chaining and
  safe apply rules.
- **Key File**: `Theories/Bimodal/Automation/AesopRules.lean`

## Testing Features

### Property-Based Testing

- **Status**: Complete (Task 174)
- **Description**: Comprehensive property-based testing using the Plausible framework.
  All 14 axiom schemas tested for validity, structural derivation properties, semantic
  frame properties, and formula transformation properties.
- **Key Files**: `Tests/BimodalTest/` (property test files)
- **Guide**: [PROPERTY_TESTING_GUIDE.md](../development/PROPERTY_TESTING_GUIDE.md)

## AI Development System Features

For tracking of AI agent system features (task routing, command behavior, etc.),
see the `.claude/` system documentation at [.claude/CLAUDE.md](../../.claude/CLAUDE.md).
