-- Re-export Theorems submodules
import Logos.Theorems.Perpetuity

/-!
# Theorems Module Root

This module re-exports all theorem submodules for the ProofChecker library.

## Submodules

- `ProofChecker.Theorems.Perpetuity`: P1-P6 perpetuity principles connecting
  modal necessity (□) with temporal always (△/always/future)

## Overview

The Theorems module contains key derived theorems of bimodal logic TM.
These theorems demonstrate deep connections between modal and temporal operators.

### Perpetuity Principles (P1-P6)

The perpetuity principles express fundamental relationships:
- P1: `□φ → △φ` - necessary implies always
- P2: `▽φ → ◇φ` - sometimes implies possible
- P3: `□φ → □△φ` - necessity of perpetuity
- P4: `◇▽φ → ◇φ` - possibility of occurrence
- P5: `◇▽φ → △◇φ` - persistent possibility
- P6: `▽□φ → □△φ` - occurrent necessity is perpetual

## References

* [ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - TM logic specification
* [Perpetuity.lean](./Theorems/Perpetuity.lean) - Full implementations
-/

namespace Logos.Theorems

-- Re-exported from submodules

end Logos.Theorems
