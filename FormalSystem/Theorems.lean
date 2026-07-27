/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Theorems.Propositional.Reasoning
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.ModalS4
import FormalSystem.Theorems.Perpetuity
import FormalSystem.Theorems.GeneralizedNecessitation
/-!
# FormalSystem.Theorems - Key Theorems

Aggregates all theorem modules for the TM bimodal logic system. Provides derived
theorems ranging from fundamental propositional combinators through modal S4/S5
properties to perpetuity principles connecting modal and temporal operators.

## Submodules

- `Combinators`: Propositional reasoning combinators (SKI basis, imp_trans, identity, b_combinator,
pairing, dni)
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
- Modal S5 Phase 2: COMPLETE (11 derivations + `iff` connective, zero sorry)
- Modal S4 Phase 4: COMPLETE (4/4 theorems, zero sorry)

### Perpetuity Principles
- P1: `□φ → △φ` - PROVEN (zero sorry)
- P2: `▽φ → ◇φ` - PROVEN (zero sorry)
- P3: `□φ → □△φ` - PROVEN (zero sorry)
- P4: `◇▽φ → ◇φ` - PROVEN (zero sorry)
- P5: `◇▽φ → △◇φ` - PROVEN (zero sorry)
- P6: `▽□φ → □△φ` - PROVEN (zero sorry)

## Usage

```lean
import FormalSystem.Theorems

-- Propositional combinators and theorems
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional

#check imp_trans    -- Transitivity of implication
#check ecq          -- Ex Contradictione Quodlibet

-- Modal S5 theorems
open FormalSystem.Theorems.ModalS5

#check t_box_to_diamond  -- □A → ◇A
#check box_contrapose    -- □(A → B) → □(¬B → ¬A)

-- Perpetuity principles
open FormalSystem.Theorems.Perpetuity

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
