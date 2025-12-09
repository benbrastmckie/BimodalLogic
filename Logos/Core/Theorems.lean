import Logos.Core.Theorems.Perpetuity

/-!
# Logos.Core.Theorems - Key Theorems

Aggregates theorem modules for the Core TM logic layer.

## Submodules

- `Perpetuity`: Perpetuity principles P1-P6 connecting modal and temporal operators

## Perpetuity Principles Status

- P1: `□φ → △φ` - PROVEN (zero sorry)
- P2: `▽φ → ◇φ` - PROVEN (zero sorry)
- P3: `□φ → □△φ` - PROVEN (zero sorry)
- P4: `◇▽φ → ◇φ` - PROVEN (zero sorry)
- P5: `◇▽φ → △◇φ` - THEOREM (using modal_5, 1 technical sorry)
- P6: `▽□φ → □△φ` - AXIOMATIZED (semantic justification)

## Usage

```lean
import Logos.Core.Theorems

open Logos.Core.Theorems.Perpetuity

#check perpetuity_1  -- □φ → △φ
#check perpetuity_5  -- ◇▽φ → △◇φ
```
-/
