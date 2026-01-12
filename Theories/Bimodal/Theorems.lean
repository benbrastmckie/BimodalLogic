import Bimodal.Theorems.Combinators
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.ModalS5
import Bimodal.Theorems.ModalS4
import Bimodal.Theorems.Perpetuity
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Bimodal.Theorems - Key Theorems

Aggregates all theorem modules for the TM bimodal logic system. Provides derived
theorems ranging from fundamental propositional combinators through modal S4/S5
properties to perpetuity principles connecting modal and temporal operators.

## Submodules

- `Combinators`: Propositional reasoning combinators (SKI basis, imp_trans, identity, b_combinator, pairing, dni)
- `Propositional`: Propositional theorems (ECQ, RAA, EFQ, LCE, RCE, LDI, RDI, RCP)
- `ModalS5`: S5 modal theorems (t_box_to_diamond, box_disj_intro, box_contrapose, t_box_consistency)
- `ModalS4`: S4 nested modality theorems (diamond_box_conj, box_diamond_box distributions)
- `Perpetuity`: Perpetuity principles P1-P6 connecting modal and temporal operators
- `GeneralizedNecessitation`: Generalized modal and temporal K rules (derived theorems)

## Status

### Propositional & Combinators
- Combinators: COMPLETE (15+ combinators, zero sorry)
- Propositional Phase 1: COMPLETE (8 theorems, zero sorry)

### Modal S5/S4
- Modal S5 Phase 2: PARTIAL (4/6 proven, biconditionals pending)
- Modal S4 Phase 4: NOT STARTED (0/4 theorems)

### Perpetuity Principles
- P1: `□φ → △φ` - PROVEN (zero sorry)
- P2: `▽φ → ◇φ` - PROVEN (zero sorry)
- P3: `□φ → □△φ` - PROVEN (zero sorry)
- P4: `◇▽φ → ◇φ` - PROVEN (zero sorry)
- P5: `◇▽φ → △◇φ` - THEOREM (using modal_5, 1 technical sorry)
- P6: `▽□φ → □△φ` - AXIOMATIZED (semantic justification)

## Usage

```lean
import Bimodal.Theorems

-- Propositional combinators and theorems
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Propositional

#check imp_trans    -- Transitivity of implication
#check ecq          -- Ex Contradictione Quodlibet

-- Modal S5 theorems
open Bimodal.Theorems.ModalS5

#check t_box_to_diamond  -- □A → ◇A
#check box_contrapose    -- □(A → B) → □(¬B → ¬A)

-- Perpetuity principles
open Bimodal.Theorems.Perpetuity

#check perpetuity_1  -- □φ → △φ
#check perpetuity_5  -- ◇▽φ → △◇φ
```

## References

* [Combinators.lean](Theorems/Combinators.lean) - SKI combinator basis
* [Propositional.lean](Theorems/Propositional.lean) - Classical propositional theorems
* [ModalS5.lean](Theorems/ModalS5.lean) - S5 modal logic theorems
* [ModalS4.lean](Theorems/ModalS4.lean) - S4 nested modality theorems
* [Perpetuity.lean](Theorems/Perpetuity.lean) - Modal-temporal perpetuity principles
-/
