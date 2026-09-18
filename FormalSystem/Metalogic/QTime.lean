/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Completeness
import FormalSystem.Metalogic.Soundness

/-!
# ℚ-time validity equals dense validity

`TaskFrame.IsQTime` (`Semantics/FrameProperty.lean`) picks out the frames whose duration group is
divisible and pairwise commensurable, which up to order-and-group isomorphism is `ℚ`. It is a class
strictly inside the dense frames, and no `FrameClass` tag denotes it. This module shows that the
narrowing changes nothing at the level of validity: `ValidQTime φ ↔ ValidDense φ`.

## Main Results

- `validQTime_iff_validDense` — ℚ-time validity and dense validity coincide.

## Proof

- **Dense to ℚ-time** is the inclusion of classes: every ℚ-time frame is dense
  (`TaskFrame.isDense_of_isQTime`), so `Validity.validQTime_of_validDense` is `ValidOnFrames.mono`.
- **ℚ-time to dense** goes through the proof system: `derivable_of_validQTime` (weak completeness
  over ℚ-time, whose countermodels are built over `ℚ`) followed by `soundness_dense_valid`.

The second direction needs both soundness and completeness, which is why this result lives here
rather than beside either of them.

## What does not transfer

Only weak completeness is stated. Finite-context consequence completeness over ℚ-time would follow
the same way once a consequence layer indexed by frame predicates exists. *Set-based* strong
completeness (compactness) over ℚ-time is open: the ultraproduct route that gives it over the dense
class leaves ℚ-time, since an ultrapower of `ℚ` is non-Archimedean and fails commensurability.

## Tags

qtime · dense · completeness · soundness · frame-properties
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics

/-- **ℚ-time validity equals dense validity.** The ℚ-time class is strictly smaller than the dense
class, but the two validate exactly the same formulas. -/
theorem validQTime_iff_validDense (φ : Formula) : ValidQTime φ ↔ ValidDense φ := by
  constructor
  · intro h
    obtain ⟨d⟩ := BXCanonical.derivable_of_validQTime φ h
    exact soundness_dense_valid d
  · exact Validity.validQTime_of_validDense

end FormalSystem.Metalogic
