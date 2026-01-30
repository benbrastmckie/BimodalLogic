# Soundness Theorem for TM Bimodal Logic

**Status**: Self-Contained (No Boneyard Dependencies)

This directory contains the soundness theorem proving that all derivable formulas are semantically valid.

## Overview

Soundness establishes that the proof system is correct with respect to the semantics:
- **All 15 TM axioms are valid** in every task model
- **All 7 derivation rules preserve validity**
- **Derivability implies semantic consequence**: `Gamma ⊢ φ → Gamma ⊨ φ`

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Soundness.lean` | Main soundness theorem and axiom validity | **Sorry-free** |
| `SoundnessLemmas.lean` | Temporal duality bridge theorems | **Sorry-free** |

## Dependency Flowchart

```
        SoundnessLemmas.lean
               │
               │ (temporal duality helpers)
               v
         Soundness.lean
               │
               │ (exports)
               v
    Completeness/WeakCompleteness.lean
```

## Main Results

### Soundness Theorem (`Soundness.lean`)

```lean
theorem soundness (Gamma : Context) (φ : Formula) :
    (Gamma ⊢ φ) → (Gamma ⊨ φ)
```

If φ is derivable from context Gamma, then φ is a semantic consequence of Gamma.

### Axiom Validity

All 15 TM axioms are proven valid:

**Propositional Axioms (2)**:
- `prop_k_valid`: K distribution `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
- `prop_s_valid`: S axiom `φ → (ψ → φ)`

**Modal Axioms (6)**:
- `modal_t_valid`: T axiom `□φ → φ`
- `modal_4_valid`: 4 axiom `□φ → □□φ`
- `modal_b_valid`: B axiom `φ → □◇φ`
- `modal_5_collapse_valid`: 5-collapse `◇□φ → □φ`
- `modal_k_dist_valid`: K distribution `□(φ → ψ) → (□φ → □ψ)`
- `modal_future_valid`: MF `□φ → □Gφ`

**Temporal Axioms (5)**:
- `temp_k_dist_valid`: TK distribution `G(φ → ψ) → (Gφ → Gψ)`
- `temp_4_valid`: T4 axiom `Gφ → GGφ`
- `temp_a_valid`: TA axiom `φ → G(Pφ)`
- `temp_l_valid`: TL axiom `Always φ → G(Hφ)`
- `temp_future_valid`: TF `□φ → G(□φ)`

**Classical Axioms (2)**:
- `ex_falso_valid`: EFQ `⊥ → φ`
- `peirce_valid`: Peirce's law `((φ → ψ) → φ) → φ`

### Rule Preservation

All 7 derivation rules preserve validity:

1. **Axiom**: Axioms are valid
2. **Assumption**: Assumptions are valid under themselves
3. **Modus Ponens**: Validity closed under MP
4. **Necessitation**: `⊢ φ` implies `⊢ □φ`
5. **Temporal Necessitation**: `⊢ φ` implies `⊢ Gφ`
6. **Temporal Duality**: Swap preservation via bridge theorems
7. **Weakening**: Context weakening preserves validity

## Technical Details

### Temporal Duality Soundness (`SoundnessLemmas.lean`)

The temporal duality rule requires bridge theorems connecting:
- `swap_temporal`: Swaps `G ↔ H` and `F ↔ P`
- `swap_validity`: Shows `⊢ φ` implies validity of `swap(φ)`

Key lemmas:
```lean
theorem axiom_swap_valid {φ : Formula} : Axiom φ → is_valid (Formula.swap_temporal φ)

theorem derivable_implies_swap_valid {φ : Formula} :
    (⊢ φ) → is_valid (Formula.swap_temporal φ)
```

### Time-Shift Invariance

The MF and TF axioms use time-shift invariance:
```lean
theorem time_shift_preserves_truth (M : TaskModel F) (σ : WorldHistory F)
    (t s : D) (φ : Formula) :
    truth_at M (WorldHistory.time_shift σ (s - t)) t φ ↔ truth_at M σ s φ
```

This shows that truth is invariant under simultaneous time shifts of history and evaluation point.

## Design Notes

### Why Separate SoundnessLemmas?

The temporal duality case requires derivation-indexed induction to prove swap validity. This complex induction is isolated in `SoundnessLemmas.lean` to keep the main soundness proof clean.

### Reflexive Semantics

The temporal T axioms (`Gφ → φ` and `Hφ → φ`) hold because we use reflexive temporal semantics where `t ≤ t` always holds. This matches standard S4-style temporal logic.

## Dependencies

- **ProofSystem**: Derivation trees and axioms
- **Semantics**: Truth relation and validity
- **Core**: Deduction theorem (indirectly via other modules)

## Related Files

- `../Core/README.md` - Foundational definitions
- `../Completeness/README.md` - Uses soundness for soundness-completeness equivalence
- `../README.md` - Overall metalogic architecture

## References

- Modal Logic, Blackburn et al., Chapter 4.3 (Soundness)
- Temporal Logic: Mathematical Foundations and Computational Aspects, Vol. 1

---

*Last updated: 2026-01-30*
