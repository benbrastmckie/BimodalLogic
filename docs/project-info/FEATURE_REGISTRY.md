# Feature Registry

**Last Updated**: 2026-05-29
**Status**: Current features of the Bimodal library

This document tracks the implemented features and capabilities of the Bimodal Lean 4 library.
The sorry inventory is mechanical, not documentary: check C3 of
`scripts/check-module-invariants.sh` asserts a hard zero across `FormalSystem/`.
For implementation status by module, see [implementation-status.md](implementation-status.md).

## Core Logic Features

### Bimodal Logic TM

- **Status**: Complete and verified
- **Description**: Full formalization of the bimodal logic TM combining S5 modal logic with
  linear temporal logic, including syntax, proof system, semantics, soundness, and completeness.
- **Key Files**:
  - `FormalSystem/Syntax/Formula.lean` - Formula type with all operators
  - `FormalSystem/ProofSystem/Axioms.lean` - 45 axiom constructors in four layers
    (Base 37 / Dense 2 / ZTime 3 / RTime 3, per `Axiom.minFrameClass`)
  - `FormalSystem/ProofSystem/Derivation.lean` - `DerivationTree`, 7 inference rules
  - `FormalSystem/Metalogic/Soundness.lean` - Soundness theorem (proved)
  - `FormalSystem/Metalogic/BXCanonical/Completeness.lean` - `completeness`,
    `completeness_dense`, `completeness_ztime`
  - `FormalSystem/Metalogic/StrongCompleteness.lean` - `completeness_rtime`

### Perpetuity Principles

- **Status**: Complete (P1-P6 all proven)
- **Description**: Six perpetuity principles connecting modal necessity (□) with eternal
  truth (△) and temporal operators.
- **Key Files**: `FormalSystem/Theorems/Perpetuity.lean` (aggregator) and
  `FormalSystem/Theorems/Perpetuity/` (`Principles.lean`, `Helpers.lean`,
  `MonotonicityDuality.lean`)
- **Principles** (per `FormalSystem/Theorems.lean`):
  `□φ → △φ` (P1), `▽φ → ◇φ` (P2), `□φ → □△φ` (P3), `◇▽φ → ◇φ` (P4),
  `◇▽φ → △◇φ` (P5), `▽□φ → □△φ` (P6)

### Deduction Theorem

- **Status**: Complete
- **Description**: If `φ :: Γ ⊢ ψ` then `Γ ⊢ φ → ψ`.
- **Key File**: `FormalSystem/Metalogic/Core/DeductionTheorem.lean`

### Propositional Theorems

- **Status**: Complete (10 theorems, zero sorry)
- **Description**: Key propositional theorems in Hilbert-style calculus including double
  negation elimination, ex contradictione quodlibet, law of excluded middle, and combinators.
- **Key Files**: `FormalSystem/Theorems/Propositional/` (aggregator) and
  `FormalSystem/Theorems/Propositional/` (`Core.lean`, `Connectives.lean`, `Reasoning.lean`)

## Automation Features

### Custom Tactics

- **Status**: Active
- **Description**: Custom Lean 4 tactics for TM modal-temporal reasoning.
- **Key Files**: `FormalSystem/Automation/Tactics/` (`Commands.lean`, `Deduction.lean`,
  `Meta.lean`, `PropDecide.lean`, `Search.lean`, `UserTactics.lean`)
- **Theory-Specific Registry**: See [docs/project-info/tactic-registry.md](tactic-registry.md)

### Proof Search

- **Status**: Active
- **Description**: Automated proof search with IDDFS, BoundedDFS, and BestFirst strategies,
  plus pattern learning for repeated goals.
- **Key Files**: `FormalSystem/Automation/ProofSearch/` (`Core.lean`, `Strategies.lean`)

### Aesop Integration

- **Status**: Retired
- **Description**: A `TMLogic` Aesop rule set with forward-chaining and safe-apply rules for
  the TM axioms. It was retired on measurement: because the rules lived in a dedicated rule
  set, reaching them required an explicit `aesop (rule_sets := [TMLogic])`, and no such
  invocation existed anywhere in the library or the test suite. Aesop's proof reconstruction
  does not work over `Type`-valued `DerivationTree` goals, which is why the tactic it was
  built for stopped using it in the first place.
- **Key File**: `FormalSystem/Boneyard/RetiredTactics/AesopRules.lean` (archived, not compiled)

## Testing Features

### Property-Based Testing

- **Status**: Complete
- **Description**: Comprehensive property-based testing using the Plausible framework.
  Axiom schemas tested for validity, plus structural derivation properties, semantic
  frame properties, and formula transformation properties.
- **Key Files**: `Tests/BimodalTest/` (property test files)
- **Guide**: [PROPERTY_TESTING_GUIDE.md](../development/PROPERTY_TESTING_GUIDE.md)

## AI Development System Features

For tracking of AI agent system features (task routing, command behavior, etc.), see the
agent-system configuration under `.claude/`. It is deliberately not linked: `.claude/` is a
gitignored, regenerable deploy artifact, so a committed link into it is dead in a fresh clone.
