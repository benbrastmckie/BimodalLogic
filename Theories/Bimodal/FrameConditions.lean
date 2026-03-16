import Bimodal.FrameConditions.FrameClass
import Bimodal.FrameConditions.Validity
import Bimodal.FrameConditions.Soundness
import Bimodal.FrameConditions.Compatibility
import Bimodal.FrameConditions.Completeness

/-!
# Frame Conditions Module

This module provides a typeclass-based architecture for temporal frame conditions
in the TM proof system.

## Overview

The frame conditions module provides:
1. **Typeclass hierarchy**: `LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`,
   `DiscreteTemporalFrame` - marker typeclasses bundling the Mathlib constraints
   required for temporal frame validity
2. **Parameterized validity**: `valid_over` that works with any temporal frame
3. **Parameterized soundness**: Soundness theorems using typeclass constraints
4. **Axiom compatibility**: `AxiomCompatible` typeclass relating axioms to frame classes
5. **Completeness wiring**: Completeness theorems through the typeclass API

## Module Structure

```
FrameConditions/
├── FrameClass.lean       -- Typeclass definitions
├── Validity.lean         -- Parameterized validity (Phase 2)
├── Soundness.lean        -- Parameterized soundness (Phase 3)
├── Compatibility.lean    -- Axiom compatibility (Phase 4)
└── Completeness.lean     -- Completeness wiring (Phase 5)
```

## Usage

```lean
import Bimodal.FrameConditions

-- Use parameterized validity
open Bimodal.FrameConditions

-- Check if a formula is valid over discrete frames
example : valid_over Int φ ↔ ... := ...

-- Get soundness via typeclass
example [DiscreteTemporalFrame D] : soundness_discrete D := ...
```

## References

- Task 977: FrameClass enum introduction
- Task 978: Typeclass-based frame condition architecture
-/
