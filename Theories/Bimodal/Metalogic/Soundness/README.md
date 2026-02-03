# Soundness Theorem for TM Bimodal Logic

**Status**: Sorry-free | **Files**: Top-level (not in this directory)

## Important Note

The main soundness files are located at the **top-level of Metalogic/**, not in this directory:

- `Metalogic/Soundness.lean` - Main soundness theorem
- `Metalogic/SoundnessLemmas.lean` - Temporal duality bridge theorems

This directory exists for organizational documentation only.

## Overview

Soundness establishes that the proof system is correct with respect to the semantics:
- **All 15 TM axioms are valid** in every task model
- **All 7 derivation rules preserve validity**
- **Derivability implies semantic consequence**: `Gamma |- phi -> Gamma |= phi`

## Main Results

### Soundness Theorem (`Soundness.lean`)

```lean
theorem soundness (Gamma : Context) (phi : Formula) :
    (Gamma |- phi) -> (Gamma |= phi)
```

If phi is derivable from context Gamma, then phi is a semantic consequence of Gamma.

### Axiom Validity

All 15 TM axioms are proven valid:

**Propositional Axioms (2)**:
- `prop_k_valid`: K distribution `(phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi))`
- `prop_s_valid`: S axiom `phi -> (psi -> phi)`

**Modal Axioms (6)**:
- `modal_t_valid`: T axiom `Box phi -> phi`
- `modal_4_valid`: 4 axiom `Box phi -> Box Box phi`
- `modal_b_valid`: B axiom `phi -> Box Diamond phi`
- `modal_5_collapse_valid`: 5-collapse `Diamond Box phi -> Box phi`
- `modal_k_dist_valid`: K distribution `Box (phi -> psi) -> (Box phi -> Box psi)`
- `modal_future_valid`: MF `Box phi -> Box G phi`

**Temporal Axioms (5)**:
- `temp_k_dist_valid`: TK distribution `G (phi -> psi) -> (G phi -> G psi)`
- `temp_4_valid`: T4 axiom `G phi -> G G phi`
- `temp_a_valid`: TA axiom `phi -> G (P phi)`
- `temp_l_valid`: TL axiom `Always phi -> G (H phi)`
- `temp_future_valid`: TF `Box phi -> G (Box phi)`

**Classical Axioms (2)**:
- `ex_falso_valid`: EFQ `bot -> phi`
- `peirce_valid`: Peirce's law `((phi -> psi) -> phi) -> phi`

### Rule Preservation

All 7 derivation rules preserve validity:

1. **Axiom**: Axioms are valid
2. **Assumption**: Assumptions are valid under themselves
3. **Modus Ponens**: Validity closed under MP
4. **Necessitation**: `|- phi` implies `|- Box phi`
5. **Temporal Necessitation**: `|- phi` implies `|- G phi`
6. **Temporal Duality**: Swap preservation via bridge theorems
7. **Weakening**: Context weakening preserves validity

## Technical Details

### Temporal Duality Soundness (`SoundnessLemmas.lean`)

The temporal duality rule requires bridge theorems connecting:
- `swap_temporal`: Swaps `G <-> H` and `F <-> P`
- `swap_validity`: Shows `|- phi` implies validity of `swap(phi)`

Key lemmas:
```lean
theorem axiom_swap_valid {phi : Formula} : Axiom phi -> is_valid (Formula.swap_temporal phi)

theorem derivable_implies_swap_valid {phi : Formula} :
    (|- phi) -> is_valid (Formula.swap_temporal phi)
```

### Time-Shift Invariance

The MF and TF axioms use time-shift invariance:
```lean
theorem time_shift_preserves_truth (M : TaskModel F) (sigma : WorldHistory F)
    (t s : D) (phi : Formula) :
    truth_at M (WorldHistory.time_shift sigma (s - t)) t phi <-> truth_at M sigma s phi
```

This shows that truth is invariant under simultaneous time shifts of history and evaluation point.

## Design Notes

### Why Separate SoundnessLemmas?

The temporal duality case requires derivation-indexed induction to prove swap validity. This complex induction is isolated in `SoundnessLemmas.lean` to keep the main soundness proof clean.

### Reflexive Semantics

The temporal T axioms (`G phi -> phi` and `H phi -> phi`) hold because we use reflexive temporal semantics where `t <= t` always holds. This matches standard S4-style temporal logic.

## Usage

```lean
import Bimodal.Metalogic.Soundness

-- Main theorem
#check soundness  -- (Gamma |- phi) -> (Gamma |= phi)
```

## Dependencies

- **ProofSystem**: Derivation trees and axioms
- **Semantics**: Truth relation and validity
- **Core**: Deduction theorem (indirectly via other modules)

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Bundle README](../Bundle/README.md) - BMCS completeness (uses soundness)
- [FMP README](../FMP/README.md) - FMP completeness (uses soundness)

## References

- Modal Logic, Blackburn et al., Chapter 4.3 (Soundness)
- Temporal Logic: Mathematical Foundations and Computational Aspects, Vol. 1

---

*Last updated: 2026-02-03*
