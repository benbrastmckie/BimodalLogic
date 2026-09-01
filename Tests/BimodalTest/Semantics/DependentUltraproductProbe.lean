/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Ultraproduct.IndexFilter
import FormalSystem.Semantics.Ultraproduct.Los

/-!
# Dependent ultraproduct: axiom-profile regression check

**The carrier construction that used to live here has been promoted.** It now sits in
`FormalSystem/Semantics/Ultraproduct/Carrier.lean` (the eventually-zero quotient `UD` and its
order structure, the section quotient `UOmega`, and the shift `shU`), with
`FormalSystem/Semantics/Ultraproduct/IndexFilter.lean` (imported here directly, since
`Los.lean` does not depend on it),
`FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean`, and
`FormalSystem/Semantics/Ultraproduct/Los.lean` completing it. This file no longer *builds*
anything; it is a **consumer** of those modules, retained for the one job the promotion does not
do on its own.

## What is measured here

Two things, both of which are compiler checks rather than assertions:

1. **The binder-list / universe check.** `uShiftSet φ S` elaborating at type
   `ShiftSet (UT φ T)` is the check that `ShiftSet` accepts the ultraproduct as its duration
   carrier: every instance binder `TemporalOrder.of` demands is synthesized on the quotient, and
   — the part that is easy to assume and expensive to be wrong about — the quotient lands in
   `Type` rather than `Type 1`, which is what `ShiftSet`'s `Carrier` field requires. This is the
   same measurement the old `shiftSetOnUD` made, now stated against the real construction
   instead of against a stand-in that took `sep`, `carrier_nonempty`, and the valuation as
   hypotheses.

2. **The axiom profile.** The `#print axioms` lines below pin `uShiftSet`, `los`, `los_truthAt`,
   and `eventually_mem` to `[propext, Classical.choice, Quot.sound]`. `Classical.choice` enters
   through `toDecidableLE := Classical.decRel _`, the `choose` calls in the `Nontrivial` and
   `DenselyOrdered` instances, and `exists_section` — the same profile
   `ShiftSet.reverse_repr` already carries. `sorryAx` must stay absent. Keeping these under a
   build target is what makes the profile a regression check rather than a one-time observation.

## What is deliberately **not** here

No definition, no theorem, no instance. Anything that constructs is scope that belongs in
`FormalSystem/Semantics/Ultraproduct/`; anything that proves belongs there too. If this file ever
grows a `def` again, the promotion has been undone.
-/

set_option linter.unusedSectionVars false

open FormalSystem.Semantics FormalSystem.Semantics.Ultraproduct

namespace BimodalTest.DependentUltraproductProbe

variable {I : Type} {φ : Ultrafilter I} {T : I → TemporalOrder}

/-! ### The binder-list and universe check -/

/-- `ShiftSet` accepts the ultraproduct temporal order as its duration carrier, with all seven
fields discharged and no hypotheses. Elaborating this is the check; there is nothing to prove. -/
noncomputable example (S : ∀ i, ShiftSet (T i)) : ShiftSet (UT φ T) := uShiftSet φ S

/-! ### The axiom-profile regression check -/

#print axioms FormalSystem.Semantics.Ultraproduct.uShiftSet
#print axioms FormalSystem.Semantics.Ultraproduct.los
#print axioms FormalSystem.Semantics.Ultraproduct.los_truthAt
#print axioms FormalSystem.Semantics.Ultraproduct.eventually_mem

end BimodalTest.DependentUltraproductProbe
