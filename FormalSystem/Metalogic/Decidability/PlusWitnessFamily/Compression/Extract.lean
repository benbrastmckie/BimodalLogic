/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Compression.Fulfil
import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Extract

/-!
# L⁺ Readout and the Segment Bound

The L⁺ twin of `WitnessFamily/Compression/Extract.lean`'s readout layer: the lemmas that turn
three finite segments into a bi-infinite function and back, plus the segment-length bound the
compression theorem states.

## Eight readout lemmas are reused, not transcribed

The `Formula`-side module's readout layer is generic by construction. `getD_mapC`,
`getD_range_mapC`, `periodic_rel_of_windowC`, `readout_backC`, `readout_midC` and `readout_fwdC`
are all declared over `{α : Type*} [Inhabited α]`, and `reduce_emodC` and `emod_succ_congrC` are
pure `Int.emod` facts over bare integers. None of the eight mentions `Formula`, `Context`,
`closureOf` or `TypeState`, so all eight are **reused by import** rather than re-proved. This
module imports the `Formula`-side `Compression/Extract.lean` for exactly those eight, alongside
the pigeonhole pair `Compression/Cycle.lean` already supplies.

What is *not* generic is the decoding lemma `typeOfT_unrollOf`, which is stated at
`TypeState C = {S : Finset Formula // S ∈ C.powerset}` and cannot be re-indexed at
`PlusFormula` — `Formula` and `PlusFormula` are separate inductives with no supertype. It is
transcribed below as `plusTypeOfT_unrollOf`.

## The two bounds

`plusMidBoundC` and `plusCompressionBound` are the `Formula`-side `midBoundC` and
`compressionBound` at the L⁺ closure. Their *shape* is unchanged for the reason Phase 4's
`plusCycleBoundC` records: the L⁺ closure carries a `stab` tier, which enlarges `C.card`, but
`⊡` contributes no event and so no excursion, so no accounting term is added.

`plusCompressionBound` takes the maximum of the two derived bounds unconditionally, exactly as
the `Formula` side does, so that no closure-cardinality lemma is needed here and the definition
stays correct with no side condition.

## Main Definitions

- `plusMidBoundC` — the mid-segment bound, twice one full residue system
- `plusCompressionBound` — the segment-length bound the L⁺ compression theorem states

## Main Results

- `plusTypeOfT_unrollOf` — the type component of a decoded L⁺ datum is the decoded label
- `plusCycleBoundC_le_plusCompressionBound` / `plusMidBoundC_le_plusCompressionBound`

Argument order is **guard first**: `PlusFormula.untl g e`, `PlusFormula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics

variable {C : Finset PlusFormula}

/-! ## The L⁺ decoding lemma -/

/--
**The type component of a decoded L⁺ datum is the decoded label.**

The one member of the readout layer that is not generic: it is stated at `PlusTypeState C`, whose
`Formula`-side counterpart `TypeState C` cannot be re-indexed. The proof is the `Formula`-side
one with `typeOfT` replaced by `plusTypeOfT`, and it consumes the *generic* `getD_mapC`, which is
reused by import rather than transcribed.
-/
theorem plusTypeOfT_unrollOf (bD mD fD : List (PlusTypeState C)) (t : ℤ) :
    plusTypeOfT (Periodic.unrollOf bD mD fD t)
      = Periodic.unrollOf (bD.map plusTypeOfT) (mD.map plusTypeOfT) (fD.map plusTypeOfT) t := by
  have hd : plusTypeOfT (default : PlusTypeState C) = (default : Finset PlusFormula) := rfl
  have hcyc : ∀ (l : List (PlusTypeState C)) (i : ℤ),
      plusTypeOfT (Periodic.cyc l i) = Periodic.cyc (l.map plusTypeOfT) i := by
    intro l i
    simp only [Periodic.cyc, List.length_map]
    exact (getD_mapC plusTypeOfT hd l _).symm
  simp only [Periodic.unrollOf, List.length_map]
  split_ifs with h1 h2
  · exact hcyc bD t
  · exact (getD_mapC plusTypeOfT hd mD _).symm
  · exact hcyc fD _

/-! ## The bounds -/

/--
The L⁺ mid-segment bound: twice one full residue system.

The mid walk is shortened in two legs, each to fewer than `Nat.card (PlusTypeState C)` steps, and
the recorded segment is one shorter than their sum.
-/
def plusMidBoundC (C : Finset PlusFormula) : ℕ := 2 * 2 ^ C.card

theorem plusMidBoundC_eq (C : Finset PlusFormula) :
    plusMidBoundC C = 2 * Nat.card (PlusTypeState C) := by
  rw [plusMidBoundC, natCard_plusTypeState]

/--
**The L⁺ segment-length bound**: the length every extracted lasso segment is bounded by.

The maximum of the two derived bounds, taken unconditionally exactly as the `Formula`-side
`compressionBound` is, so that no closure-cardinality lemma is needed here and the definition
stays correct with no side condition.

This is the quantity the compression theorem states for `back`, `mid` and `fwd` alike, and it is
also the common padded cycle length Phase 7's Invariant A drives every extracted lasso to. Those
two roles are deliberately the same number: `SharingWindow` requires the backward and forward
periods to be common multiples of every listed cycle length, and leaving the segments at
differing lengths would make that a least common multiple over as many lengths as there are
lassos.
-/
def plusCompressionBound (Γ Del : PlusContext) : ℕ :=
  max (plusCycleBoundC (plusClosureOf (Γ ++ Del))) (plusMidBoundC (plusClosureOf (Γ ++ Del)))

theorem plusCycleBoundC_le_plusCompressionBound (Γ Del : PlusContext) :
    plusCycleBoundC (plusClosureOf (Γ ++ Del)) ≤ plusCompressionBound Γ Del := le_max_left _ _

theorem plusMidBoundC_le_plusCompressionBound (Γ Del : PlusContext) :
    plusMidBoundC (plusClosureOf (Γ ++ Del)) ≤ plusCompressionBound Γ Del := le_max_right _ _

/-- The L⁺ segment bound is positive, so a padded segment is never the empty list. Phase 7's
Invariant A and the `PlusLabelledLasso` non-emptiness fields both need this. -/
theorem plusCompressionBound_pos (Γ Del : PlusContext) : 0 < plusCompressionBound Γ Del := by
  refine lt_of_lt_of_le ?_ (plusMidBoundC_le_plusCompressionBound Γ Del)
  rw [plusMidBoundC]
  positivity

end FormalSystem.Metalogic.Decidability
