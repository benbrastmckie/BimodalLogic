/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionLabel

/-!
# The `ℤ` placement is contiguous, so its interior gaps are empty

`valid` (`Semantics/Validity.lean`) quantifies over every carrier, so **one** carrier refutes it.
`ℤ` is the cheap one, and this file says why: `finOrderEmbInt` (`Bridge/Embed.lean`) is the
`Nat`-cast, so `finiteOrderEmbInt` places a finite order of `n` elements at exactly
`0, 1, …, n-1` — a **contiguous** block. Between consecutive placed points of a contiguous `ℤ`
placement there are no integers at all, so every interior gap region is *empty* and the only
non-placed points are the two rays.

That is a strictly easier problem than the one `ℚ` and `ℝ` pose, where interior gaps are
genuinely inhabited and a single region state must meet the `G`-content arriving from the left
*and* the `H`-content arriving from the right at once. Treating all four `Decidable` instances as
one milestone is on this task's do-not-re-attempt register precisely because of this asymmetry.

## What is here

* `finiteOrderEmbInt_nonneg` and `finiteOrderEmbInt_lt_card` — the placement lands in
  `[0, n)`.
* `exists_preimage_finiteOrderEmbInt` — and it hits every integer of `[0, n)`, which is the
  contiguity itself.
* `ray_of_gap_finiteOrderEmbInt` — **the dichotomy the induction consumes**: a point whose region
  code is not placed lies on the lower ray or the upper ray. There is no third case.
* `regionCode_fst_eq_empty_of_neg`, `regionCode_fst_eq_univ_of_card_le` — the two rays' codes.
* `cutIndex_eq_zero`, `cutIndex_eq_length` — those codes' region indices, so the two rays are
  region `0` and region `n` of `Bridge/RegionLabel.lean`'s gate, as the gate's indexing intends.

The last two are stated about an arbitrary code rather than about a placement, so they carry no
`LinearOrder` instance on `BranchTime b` and need no `letI` in their statements.

## Scope

Nothing here mentions a branch. The `ℤ` facts are about `finiteOrderEmbInt` at an arbitrary
finite linear order, so they apply to `BranchTime b` under the `BranchOrder` instance without
this file having to carry that instance.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

section IntPlacement

/--
How many points `finiteOrderEmbInt` places: the cardinality taken through the **very** `Fintype`
instance `finiteOrderEmbInt` itself uses.

Written out rather than as `Nat.card T`, which is not in this project's Mathlib import closure
(neither is `Set.ncard` — `Bridge/RegionLabel.lean`'s `cutIndex` works around the same gap). The
explicit instance also removes any question of whether the bound is stated against the same
cardinality the definition computes with.
-/
noncomputable abbrev placedCount (T : Type) [Finite T] : ℕ :=
  @Fintype.card T (Fintype.ofFinite T)

variable (T : Type) [LinearOrder T] [Finite T]

/-- The placement is non-negative: it is a `Nat`-cast. -/
theorem finiteOrderEmbInt_nonneg (t : T) : 0 ≤ finiteOrderEmbInt T t := by
  letI : Fintype T := Fintype.ofFinite T
  show (0 : ℤ) ≤ (((monoEquivOfFin T (k := Fintype.card T) rfl).symm t).val : ℤ)
  exact Int.natCast_nonneg _

/-- The placement stays strictly below the cardinality: `n` points at `0, …, n-1`. -/
theorem finiteOrderEmbInt_lt_card (t : T) : finiteOrderEmbInt T t < (placedCount T : ℤ) := by
  letI : Fintype T := Fintype.ofFinite T
  show ((((monoEquivOfFin T (k := Fintype.card T) rfl).symm t).val : ℤ)) < (placedCount T : ℤ)
  exact_mod_cast ((monoEquivOfFin T (k := Fintype.card T) rfl).symm t).isLt

/--
**Contiguity.** Every integer of `[0, n)` is placed.

This is the whole content of "the `ℤ` placement has no interior gaps": the placed points are an
initial segment of `ℕ` cast into `ℤ`, so nothing sits strictly between two of them.
-/
theorem exists_preimage_finiteOrderEmbInt {x : ℤ} (h0 : 0 ≤ x) (hn : x < (placedCount T : ℤ)) :
    ∃ t : T, finiteOrderEmbInt T t = x := by
  letI : Fintype T := Fintype.ofFinite T
  have hn' : x < (Fintype.card T : ℤ) := hn
  have hlt : x.toNat < Fintype.card T := by omega
  refine ⟨(monoEquivOfFin T (k := Fintype.card T) rfl) ⟨x.toNat, hlt⟩, ?_⟩
  show ((((monoEquivOfFin T (k := Fintype.card T) rfl).symm
    ((monoEquivOfFin T (k := Fintype.card T) rfl) ⟨x.toNat, hlt⟩)).val : ℤ)) = x
  rw [OrderIso.symm_apply_apply]
  exact Int.toNat_of_nonneg h0

/-- A placed integer's region code is a placed code — the region of `f t` is `{f t}`. -/
theorem isPlacedCode_finiteOrderEmbInt {x : ℤ} (h0 : 0 ≤ x) (hn : x < (placedCount T : ℤ)) :
    IsPlacedCode (finiteOrderEmbInt T) (regionCode (finiteOrderEmbInt T) x) := by
  obtain ⟨t, ht⟩ := exists_preimage_finiteOrderEmbInt T h0 hn
  exact ⟨t, by rw [placedCode, ht]⟩

/--
**The dichotomy the `ℤ` induction runs on.** A point of `ℤ` whose region code is *not* placed
lies strictly below every placed point or at-or-above all of them. There is no interior gap.

Contrast `ℚ` and `ℝ`, where a non-placed point may sit between two consecutive placed ones and
the region it inhabits must satisfy demands arriving from both directions at once.
-/
theorem ray_of_gap_finiteOrderEmbInt {x : ℤ}
    (hgap : ¬ IsPlacedCode (finiteOrderEmbInt T) (regionCode (finiteOrderEmbInt T) x)) :
    x < 0 ∨ (placedCount T : ℤ) ≤ x := by
  by_contra hc
  push Not at hc
  exact hgap (isPlacedCode_finiteOrderEmbInt T hc.1 hc.2)

/-- **The lower ray's code.** Nothing is placed below it. -/
theorem regionCode_fst_eq_empty_of_neg {x : ℤ} (hx : x < 0) :
    (regionCode (finiteOrderEmbInt T) x).1 = ∅ := by
  ext t
  simp only [regionCode, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false, not_lt]
  exact le_trans hx.le (finiteOrderEmbInt_nonneg T t)

/-- **The upper ray's code.** Everything is placed below it. -/
theorem regionCode_fst_eq_univ_of_card_le {x : ℤ} (hx : (placedCount T : ℤ) ≤ x) :
    (regionCode (finiteOrderEmbInt T) x).1 = Set.univ := by
  ext t
  simp only [regionCode, Set.mem_setOf_eq, Set.mem_univ, iff_true]
  exact lt_of_lt_of_le (finiteOrderEmbInt_lt_card T t) hx

end IntPlacement

/-! ## The two rays are the gate's first and last regions

Stated about a code rather than about a placement, so no `LinearOrder` on `BranchTime b` appears
in either statement.
-/

open Classical in
/-- A code with nothing below it is region `0` — the lower ray. -/
theorem cutIndex_eq_zero {b : Branch} {c : Set (BranchTime b) × Set (BranchTime b)}
    (h : c.1 = ∅) : cutIndex c = 0 := by
  rw [cutIndex, h]
  simp

open Classical in
/-- A code with everything below it is region `n` — the upper ray. -/
theorem cutIndex_eq_length {b : Branch} {c : Set (BranchTime b) × Set (BranchTime b)}
    (h : c.1 = Set.univ) : cutIndex c = b.knownTimes.length := by
  rw [cutIndex, h]
  simp only [Set.mem_univ, Finset.filter_true_of_mem, implies_true, Finset.card_univ,
    Fintype.card_fin]

/-! ## Sanity checks

The contiguity claim is exercised on a concrete `Fin 4`, so a Mathlib change to `monoEquivOfFin`
that broke the `Nat`-cast reading would fail here rather than inside the induction.
-/

section Checks

-- The `ℤ` placement of `Fin 4` is `0, 1, 2, 3`: contiguous, hence no interior gaps.
/-- info: [0, 1, 2, 3] -/
#guard_msgs in
#eval (List.finRange 4).map (finOrderEmbInt 4)

example (t : Fin 4) : 0 ≤ finiteOrderEmbInt (Fin 4) t := finiteOrderEmbInt_nonneg _ t

example (t : Fin 4) : finiteOrderEmbInt (Fin 4) t < (placedCount (Fin 4) : ℤ) :=
  finiteOrderEmbInt_lt_card _ t

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
