/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix.BoundedFix

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! # The pinned-concatenation builder

Case 3 of the fixed-formula negation recursion glues IH outputs across the
attained first-`¬β₀` pin `r0`: the negation of a bracket on `(z0, z1)` is
assembled from V-brackets on `(z0, r0)` and `(r0, z1)` joined at a pinned
point type (Rabinovich chunk_0017, the A_i/B_i split; Phase 10a handoff,
design note 2). The builder concatenates every pair of disjuncts around the
pin; the `∃ r` and the fixed pin distribute over both disjunction lists. -/

/-- Splitting a list-form bracket at a distinguished pin pair: the bracket
    `[s, …ps…, pin, b, …qs…]` holds iff some `r ∈ (z0, z1)` splits it into
    the `ps`-bracket on `(z0, r)`, the pin at `r`, and the `qs`-bracket on
    `(r, z1)`. -/
theorem bracketOf_append_pin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (ps : List (TemporalPred × TemporalPred)) (s a b : TemporalPred)
      (qs : List (TemporalPred × TemporalPred)) (z0 z1 : M.carrier),
    (bracketOf s (ps ++ (a, b) :: qs)).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      (bracketOf s ps).holds M atomMap z0 r ∧
      a.eval_at M atomMap r ∧
      (bracketOf b qs).holds M atomMap r z1 := by
  intro ps
  induction ps with
  | nil =>
    intro s a b qs z0 z1
    rw [List.nil_append, bracketOf_cons_holds_iff]
    constructor
    · rintro ⟨r, h1, h2, h3, h4, h5⟩
      exact ⟨r, h1, h2, (bracketOf_nil_holds_iff M atomMap s z0 r).mpr h3, h4, h5⟩
    · rintro ⟨r, h1, h2, h3, h4, h5⟩
      exact ⟨r, h1, h2, (bracketOf_nil_holds_iff M atomMap s z0 r).mp h3, h4, h5⟩
  | cons ab' rest ih =>
    obtain ⟨a', b'⟩ := ab'
    intro s a b qs z0 z1
    rw [List.cons_append, bracketOf_cons_holds_iff]
    constructor
    · rintro ⟨r', h1, h2, h3, h4, h5⟩
      obtain ⟨r, hr1, hr2, hr3, hr4, hr5⟩ := (ih b' a b qs r' z1).mp h5
      exact ⟨r, lt_trans h1 hr1, hr2,
        (bracketOf_cons_holds_iff M atomMap s a' b' rest z0 r).mpr
          ⟨r', h1, hr1, h3, h4, hr3⟩, hr4, hr5⟩
    · rintro ⟨r, hr1, hr2, hr3, hr4, hr5⟩
      obtain ⟨r', h1, h2, h3, h4, h5⟩ :=
        (bracketOf_cons_holds_iff M atomMap s a' b' rest z0 r).mp hr3
      exact ⟨r', h1, lt_trans h2 hr2, h3, h4,
        (ih b' a b qs r' z1).mpr ⟨r, h2, hr2, h5, hr4, hr5⟩⟩

/-- Pinned concatenation of two brackets: `[bfL…, pin, bfR…]`. The witness
    count is the list length of the combined fold pairs (definitionally
    `nL + 1 + nR`, kept in list form to avoid `Fin` casts — the V-level
    consumer stores it under a `Σ`). -/
def BracketFormula.concatPin {nL nR : Nat} (bfL : BracketFormula nL)
    (pin : TemporalPred) (bfR : BracketFormula nR) :
    BracketFormula (bfL.foldPairs ++
      (pin, bfR.segmentTypes ⟨0, Nat.succ_pos nR⟩) :: bfR.foldPairs).length :=
  bracketOf (bfL.segmentTypes ⟨0, Nat.succ_pos nL⟩)
    (bfL.foldPairs ++ (pin, bfR.segmentTypes ⟨0, Nat.succ_pos nR⟩) :: bfR.foldPairs)

/-- Semantics of the pinned concatenation: some `r ∈ (z0, z1)` carries the
    pin, with `bfL` on `(z0, r)` and `bfR` on `(r, z1)`. -/
theorem BracketFormula.concatPin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {nL nR : Nat} (bfL : BracketFormula nL) (pin : TemporalPred)
    (bfR : BracketFormula nR) (z0 z1 : M.carrier) :
    (bfL.concatPin pin bfR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      bfL.holds M atomMap z0 r ∧ pin.eval_at M atomMap r ∧
      bfR.holds M atomMap r z1 := by
  unfold concatPin
  rw [bracketOf_append_pin_holds_iff]
  constructor
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    exact ⟨r, h1, h2,
      (BracketFormula.holds_iff_bracketOf M atomMap nL bfL z0 r).mpr h3, h4,
      (BracketFormula.holds_iff_bracketOf M atomMap nR bfR r z1).mpr h5⟩
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    exact ⟨r, h1, h2,
      (BracketFormula.holds_iff_bracketOf M atomMap nL bfL z0 r).mp h3, h4,
      (BracketFormula.holds_iff_bracketOf M atomMap nR bfR r z1).mp h5⟩

/-- Pinned concatenation of two V-brackets: every pair of disjuncts joined
    around the pin. -/
def VBracketFormula.concatPin (VL : VBracketFormula) (pin : TemporalPred)
    (VR : VBracketFormula) : VBracketFormula :=
  ⟨VL.disjuncts.flatMap fun dL =>
    VR.disjuncts.map fun dR => ⟨_, dL.2.concatPin pin dR.2⟩⟩

/-- Semantics of the V-level pinned concatenation: the `∃ r` and the fixed
    pin distribute over both disjunction lists. -/
theorem VBracketFormula.concatPin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (VL : VBracketFormula) (pin : TemporalPred) (VR : VBracketFormula)
    (z0 z1 : M.carrier) :
    (VL.concatPin pin VR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      VL.holds M atomMap z0 r ∧ pin.eval_at M atomMap r ∧
      VR.holds M atomMap r z1 := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [concatPin, List.mem_flatMap, List.mem_map] at hmem
    obtain ⟨dL, hdL, dR, hdR, rfl⟩ := hmem
    obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
      (BracketFormula.concatPin_holds_iff M atomMap dL.2 pin dR.2 z0 z1).mp hh
    exact ⟨r, h1, h2, ⟨dL, hdL, h3⟩, h4, ⟨dR, hdR, h5⟩⟩
  · rintro ⟨r, h1, h2, ⟨dL, hdL, h3⟩, h4, ⟨dR, hdR, h5⟩⟩
    refine ⟨⟨_, dL.2.concatPin pin dR.2⟩, ?_, ?_⟩
    · simp only [concatPin, List.mem_flatMap, List.mem_map]
      exact ⟨dL, hdL, dR, hdR, rfl⟩
    · exact (BracketFormula.concatPin_holds_iff M atomMap dL.2 pin dR.2 z0 z1).mpr
        ⟨r, h1, h2, h3, h4, h5⟩


end FormalSystem.Metalogic.WeakCanonical.Kamp
