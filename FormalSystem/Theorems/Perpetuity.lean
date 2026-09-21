/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Perpetuity.Helpers
import FormalSystem.Theorems.Perpetuity.Principles
import FormalSystem.Theorems.Perpetuity.MonotonicityDuality

/-!
# Perpetuity Principles (P1-P6)

This module derives the six perpetuity principles that establish deep connections
between modal necessity (□) and temporal operators (always △, sometimes ▽).

## Main Theorems

- `perpetuity1`: `□φ → △φ` (necessary implies always)
- `perpetuity2`: `▽φ → ◇φ` (sometimes implies possible)
- `perpetuity3`: `□φ → □△φ` (necessity of perpetuity)
- `perpetuity4`: `◇▽φ → ◇φ` (possibility of occurrence)
- `perpetuity5`: `◇▽φ → △◇φ` (persistent possibility)
- `perpetuity6`: `▽□φ → □△φ` (occurrent necessity is perpetual)

## Notation

- `△φ` = `always φ` = `Hφ ∧ φ ∧ Gφ` (φ at all times: past, present, future)
- `▽φ` = `sometimes φ` = `¬△¬φ` (φ at some time: past, present, or future)
- `◇φ` = `diamond φ` = `¬□¬φ` (φ is possible)

## How each principle is derived

- P1-P4: directly, from the axioms below
- P5: via the persistence lemma, which uses `modal5` and temporal K distribution
- P6: via P5(¬φ), the bridge lemmas, and `doubleContrapose`
- the persistence lemma itself: from `reflect_time_diamond` and temporal K distribution

Key P6 derivation components:
- `bridge1`: `¬□△φ → ◇▽¬φ` (modal/temporal duality)
- `bridge2`: `△◇¬φ → ¬▽□φ` (modal duality + DNI)
- `doubleContrapose`: From `¬A → ¬B`, derive `B → A` (handles DNE/DNI)

The perpetuity principles follow from the TM axiom system, particularly:
- MF (Modal-Future): `□φ → □Fφ`
- TF (Temporal-Future): `□φ → F□φ`
- MT (Modal T): `□φ → φ`
- MB (Modal B): `φ → □◇φ`
- Modal and temporal K rules

Key helper lemmas:
- `modal5`: `◇φ → □◇φ` (S5 characteristic, derived from MB + diamond4)
- `reflect_time_diamond`: Time reflection distributes over diamond
- `reflect_time_involution`: Time reflection is involutive

Note: `always φ = Hφ ∧ φ ∧ Gφ` (past, present, and future), so `△φ` covers all times.

## Module Organization

This module is split into three submodules for maintainability:

1. **Helpers** (`Perpetuity.Helpers`): Helper lemmas including propositional combinators,
   conjunction introduction, double negation, and temporal component derivations.

2. **Principles** (`Perpetuity.Principles`): Proofs of perpetuity principles P1-P5,
   including supporting lemmas like contraposition, diamond4, modal5, and persistence.

3. **MonotonicityDuality** (`Perpetuity.MonotonicityDuality`): duality and monotonicity lemmas,
   monotonicity lemmas, double negation elimination, and the proof of P6.

All definitions and theorems are re-exported from this parent module for backward
compatibility with existing code.

## References

* `docs/user-guide/architecture.md` — TM logic specification
* `FormalSystem/ProofSystem/Axioms.lean` — Axiom schemata
* `FormalSystem/ProofSystem/Derivation.lean` — Derivability relation
* `FormalSystem/Theorems/Perpetuity/Helpers.lean` — Helper lemmas
* `FormalSystem/Theorems/Perpetuity/Principles.lean` — P1-P5 proofs
* `FormalSystem/Theorems/Perpetuity/MonotonicityDuality.lean` — duality/monotonicity lemmas and
P6
-/

-- Re-export all submodules to maintain backward compatibility
namespace FormalSystem.Theorems.Perpetuity

-- All definitions from submodules are automatically available
-- through the transitive imports:
-- Helpers is imported by Principles and Bridge
-- Principles is imported by Bridge
-- Bridge imports both

end FormalSystem.Theorems.Perpetuity
