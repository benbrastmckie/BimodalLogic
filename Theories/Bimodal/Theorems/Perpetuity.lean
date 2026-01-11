import Bimodal.Theorems.Perpetuity.Helpers
import Bimodal.Theorems.Perpetuity.Principles
import Bimodal.Theorems.Perpetuity.Bridge

/-!
# Perpetuity Principles (P1-P6)

This module derives the six perpetuity principles that establish deep connections
between modal necessity (□) and temporal operators (always △, sometimes ▽).

## Main Theorems

- `perpetuity_1`: `□φ → △φ` (necessary implies always)
- `perpetuity_2`: `▽φ → ◇φ` (sometimes implies possible)
- `perpetuity_3`: `□φ → □△φ` (necessity of perpetuity)
- `perpetuity_4`: `◇▽φ → ◇φ` (possibility of occurrence)
- `perpetuity_5`: `◇▽φ → △◇φ` (persistent possibility)
- `perpetuity_6`: `▽□φ → □△φ` (occurrent necessity is perpetual)

## Notation

- `△φ` = `always φ` = `Hφ ∧ φ ∧ Gφ` (φ at all times: past, present, future)
- `▽φ` = `sometimes φ` = `¬△¬φ` (φ at some time: past, present, or future)
- `◇φ` = `diamond φ` = `¬□¬φ` (φ is possible)

## Implementation Status

**ALL 6 PRINCIPLES FULLY PROVEN** (100% completion):
- P1-P4: Fully proven in initial implementation
- P5: Fully proven via persistence lemma (uses `modal_5`, temporal K distribution)
- P6: Fully proven via P5(¬φ) + bridge lemmas + double_contrapose
- Persistence lemma: Fully proven using `swap_temporal_diamond` and temporal K distribution

Key P6 derivation components:
- `bridge1`: `¬□△φ → ◇▽¬φ` (modal/temporal duality)
- `bridge2`: `△◇¬φ → ¬▽□φ` (modal duality + DNI)
- `double_contrapose`: From `¬A → ¬B`, derive `B → A` (handles DNE/DNI)

The perpetuity principles follow from the TM axiom system, particularly:
- MF (Modal-Future): `□φ → □Fφ`
- TF (Temporal-Future): `□φ → F□φ`
- MT (Modal T): `□φ → φ`
- MB (Modal B): `φ → □◇φ`
- Modal and temporal K rules

Key helper lemmas:
- `modal_5`: `◇φ → □◇φ` (S5 characteristic, derived from MB + diamond_4)
- `swap_temporal_diamond`: Temporal swap distributes over diamond
- `swap_temporal_involution`: Temporal swap is involutive

Note: `always φ = Hφ ∧ φ ∧ Gφ` (past, present, and future), so `△φ` covers all times.

## Module Organization

This module is split into three submodules for maintainability:

1. **Helpers** (`Perpetuity.Helpers`): Helper lemmas including propositional combinators,
   conjunction introduction, double negation, and temporal component derivations.

2. **Principles** (`Perpetuity.Principles`): Proofs of perpetuity principles P1-P5,
   including supporting lemmas like contraposition, diamond_4, modal_5, and persistence.

3. **Bridge** (`Perpetuity.Bridge`): Bridge lemmas connecting modal/temporal duality,
   monotonicity lemmas, double negation elimination, and the proof of P6.

All definitions and theorems are re-exported from this parent module for backward
compatibility with existing code.

## References

* [ARCHITECTURE.md](../../../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
* [Axioms.lean](../ProofSystem/Axioms.lean) - Axiom schemata
* [Derivation.lean](../ProofSystem/Derivation.lean) - Derivability relation
* [Helpers.lean](Perpetuity/Helpers.lean) - Helper lemmas
* [Principles.lean](Perpetuity/Principles.lean) - P1-P5 proofs
* [Bridge.lean](Perpetuity/Bridge.lean) - Bridge lemmas and P6
-/

-- Re-export all submodules to maintain backward compatibility
namespace Bimodal.Theorems.Perpetuity

-- All definitions from submodules are automatically available
-- through the transitive imports:
-- Helpers is imported by Principles and Bridge
-- Principles is imported by Bridge
-- Bridge imports both

end Bimodal.Theorems.Perpetuity
