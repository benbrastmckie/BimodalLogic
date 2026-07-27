/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.FrameConditions.FrameClass
import FormalSystem.FrameConditions.Validity
import FormalSystem.FrameConditions.Soundness
import FormalSystem.FrameConditions.Compatibility


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

## Module Structure

```
FrameConditions/
├── FrameClass.lean       -- Typeclass definitions
├── Validity.lean         -- Parameterized validity
├── Soundness.lean        -- Parameterized soundness
├── Compatibility.lean    -- Axiom compatibility
└── README.md             -- Layering evidence and the FrameClass disambiguation
```

Four modules, 816 lines. There is no `Completeness.lean` here; completeness lives
under `Metalogic/`, and this directory consumes it rather than providing it.

## Position in the Layering

This directory sits strictly ABOVE `Metalogic/`, on measured evidence: zero files
under `Metalogic/` import `FormalSystem.FrameConditions`, while `FrameConditions/`
imports `FormalSystem.Metalogic.Soundness`, `FormalSystem.ProofSystem.Axioms` and
`FormalSystem.Semantics.Validity`. Merging it into `Metalogic/` would invert that
direction and manufacture a new cycle. See `FrameConditions/README.md`.

## Usage

```lean
import FormalSystem.FrameConditions

-- Use parameterized validity
open FormalSystem.FrameConditions

-- Check if a formula is valid over discrete frames
example : valid_over Int φ ↔ ... := ...

-- Get soundness via typeclass
example [DiscreteTemporalFrame D] : soundness_discrete D := ...
```

## References

-/
