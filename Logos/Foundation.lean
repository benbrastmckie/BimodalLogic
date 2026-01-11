import Logos.Foundation.Frame
import Logos.Foundation.Basic

/-!
# Logos Foundation - Constitutive Semantics Layer

This module exports the Constitutive Foundation for Logos, providing
the hyperintensional base layer for exact truthmaker semantics.

## Overview

The Constitutive Foundation provides:
- Mereological state space as a complete lattice
- Bilateral propositions (verifier/falsifier pairs)
- Hyperintensional evaluation (verification/falsification)
- Propositional identity and constitutive relations

## Submodules

- `Foundation.Frame`: Constitutive frame (complete lattice state space)
- `Foundation.Basic`: Basic mereological lemmas
- `Foundation.Proposition`: Bilateral propositions (Phase 2)
- `Foundation.Interpretation`: Interpretation functions (Phase 2)
- `Foundation.Semantics`: Verification/falsification (Phase 3)

## Usage

```lean
import Logos.Foundation

open Logos.Foundation

-- Create a frame instance
def myFrame : ConstitutiveFrame := ConstitutiveFrame.powerSet Nat

-- Use mereological operations
#check myFrame.null      -- Bottom element
#check myFrame.full      -- Top element
#check myFrame.fusion    -- Least upper bound
#check myFrame.parthood  -- Partial order
```

## References

- Logos/Documentation/Research/RECURSIVE_SEMANTICS.md - Full specification
- Logos/Documentation/Research/LAYER_EXTENSIONS.md - Extension architecture
-/
