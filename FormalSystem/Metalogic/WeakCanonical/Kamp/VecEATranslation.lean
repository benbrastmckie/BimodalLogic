/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.Translation
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAFormula

/-!
# Vec-EA to Temporal Translation (Rabinovich 2014, Proposition 3.5)

Connects the vec-EA formula types (`BracketFormula`, `VecEA2`, `VVecEA2`)
from `VecEAFormula.lean` to the temporal translation machinery in
`Translation.lean` (`translateEF1`, `buildRight`, `buildLeft`).

## Main Results

- `bracketBuildRight_correct`: Semantic correctness of bracket-to-temporal translation.
- `VecEA2.translateLeft_correct`: Correctness for 2-free-variable vec-EA formulas.
- `VVecEA2.translateLeft_correct`: Correctness for disjunctions.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 3.5
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Recursive chain specification and translation -/

/-- Recursive chain-of-existentials specification matching `bracketBuildRight`. -/
def chainHolds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    {n : Nat} → BracketFormula n → TemporalPred → M.carrier → Prop
  | 0, bf, endRight, z0 =>
    ∃ z1 : M.carrier, z0 < z1 ∧
      endRight.eval_at M atomMap z1 ∧
      ∀ y : M.carrier, z0 < y → y < z1 →
        (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
  | n + 1, bf, endRight, z0 =>
    ∃ x : M.carrier, z0 < x ∧
      (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap x ∧
      (∀ r : M.carrier, z0 < r → r < x →
        (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap r) ∧
      chainHolds M atomMap
        (BracketFormula.mk
          (fun i => bf.pointTypes ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩)
          (fun i => bf.segmentTypes ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩))
        endRight x

/-- Recursively translate a bracket formula to a temporal formula. -/
noncomputable def bracketBuildRight :
    {n : Nat} → BracketFormula n → TemporalPred → Formula
  | 0, bf, endRight =>
    buildRight [(endRight, bf.segmentTypes ⟨0, by omega⟩)] TemporalPred.top
  | n + 1, bf, endRight =>
    let shifted : BracketFormula n :=
      { pointTypes := fun i => bf.pointTypes ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩
        segmentTypes := fun i => bf.segmentTypes ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩ }
    Formula.untl
      (Formula.and (bf.pointTypes ⟨0, by omega⟩).formula
        (bracketBuildRight shifted endRight))
      (bf.segmentTypes ⟨0, by omega⟩).formula

/-! ## Helper: prepend witness to bracket holds -/

/-- Prepend a witness x to shifted bracket witnesses to get full bracket holds. -/
private theorem bracket_prepend_witness {sig : MonadicSignature} {m : Nat}
    (bf : BracketFormula (m + 1))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 x : M.carrier) (hx : z0 < x) (hxz1 : x < z1)
    (hpt : (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap x)
    (hseg : ∀ r, z0 < r → r < x → (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap r)
    (hshifted : BracketFormula.holds M atomMap
      (BracketFormula.mk
        (fun i => bf.pointTypes ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩)
        (fun i => bf.segmentTypes ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩))
      x z1) :
    bf.holds M atomMap z0 z1 := by
  -- This is a pure witness-construction lemma: prepend x to the shifted bracket's
  -- witnesses to get witnesses for the full bracket formula. The proof strategy is:
  -- w(0) = x, w(i+1) = w'(i), then verify all IntervalPattern conditions.
  -- The Fin index arithmetic is straightforward but verbose.
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
    at hshifted ⊢
  match m with
  | 0 =>
    -- 0 shifted witnesses → 1 total witness (x)
    -- hshifted has type: match 0, pat ... which reduces to ∀ y, x < y → y < z1 → seg(y)
    exact ⟨fun _ => x, fun i j h => absurd h (by omega), fun i => ⟨hx, hxz1⟩,
           fun i => by
             have : i = ⟨0, by omega⟩ := Fin.ext (by omega)
             rw [this]; exact hpt,
           hseg, fun i => i.elim0, hshifted⟩
  | m' + 1 =>
    -- (m'+1) shifted witnesses → (m'+2) total witnesses
    -- Witness construction: w(0)=x, w(i+1)=w'(i). Conditions follow from
    -- hpt, hseg, hbnd', hinc', hpt', hseg0', hsegmid', hsegn'.
    obtain ⟨w', hinc', hbnd', hpt', hseg0', hsegmid', hsegn'⟩ := hshifted
    exact ⟨fun ⟨i, hi⟩ => if i = 0 then x else w' ⟨i - 1, by omega⟩,
           fun ⟨i, hi⟩ ⟨j, hj⟩ hij => by
             have hij_val : i < j := hij
             simp only at *; split <;> split
             · omega
             · rename_i h1 _; subst h1
               rcases Nat.eq_or_lt_of_le (Nat.one_le_of_lt hij_val) with h1 | h1
               · subst h1; exact (hbnd' ⟨0, by omega⟩).1
               · exact lt_trans (hbnd' ⟨0, by omega⟩).1
                   (hinc' ⟨0, by omega⟩ ⟨j - 1, by omega⟩ (by simp [Fin.lt_def]; omega))
             · omega
             · exact hinc' ⟨i - 1, by omega⟩ ⟨j - 1, by omega⟩ (by simp [Fin.lt_def]; omega),
           fun ⟨i, hi⟩ => by simp only; split
                             · exact ⟨hx, hxz1⟩
                             · rename_i h; exact ⟨lt_trans hx (hbnd' ⟨i-1, by omega⟩).1,
                                 (hbnd' ⟨i-1, by omega⟩).2⟩,
           fun ⟨i, hi⟩ => by simp only; split
                             · rename_i h; subst h; exact hpt
                             · rename_i h; convert hpt' ⟨i-1, by omega⟩ using 2; ext; simp; omega,
           hseg,
           fun ⟨i, hi⟩ y hy1 hy2 => by
             simp only at hy1 hy2; split at hy1 <;> split at hy2
             · omega
             · rename_i h1 _; subst h1; exact hseg0' y hy1 hy2
             · rename_i h1 h2; omega
             · rename_i h1 h2
               have h_eq1 : i + 1 - 1 = (i - 1) + 1 := by omega
               rw [show (⟨i + 1 - 1, by omega⟩ : Fin (m' + 1)) = ⟨(i - 1) + 1, by omega⟩
                   from Fin.ext h_eq1] at hy2
               have := hsegmid' ⟨i - 1, by omega⟩ y hy1 hy2
               simp only at this
               convert this using 2
               simp [Fin.ext_iff]; omega,
           fun y hy hyz1 => by
             simp only at hy; split at hy
             · omega
             · exact hsegn' y hy hyz1⟩

/-! ## Helper: extract first witness from bracket holds -/

/-- Extract the first witness from bracket formula holds. -/
private theorem bracket_extract_first_witness {sig : MonadicSignature} {m : Nat}
    (bf : BracketFormula (m + 1))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier)
    (hbf : bf.holds M atomMap z0 z1) :
    ∃ x : M.carrier, z0 < x ∧
      (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap x ∧
      (∀ r, z0 < r → r < x → (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap r) ∧
      x < z1 ∧
      BracketFormula.holds M atomMap
        (BracketFormula.mk
          (fun i => bf.pointTypes ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩)
          (fun i => bf.segmentTypes ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩))
        x z1 := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
    at hbf ⊢
  match m with
  | 0 =>
    obtain ⟨w, _, hbnd, hpt, hseg0, _, hsegn⟩ := hbf
    exact ⟨w ⟨0, by omega⟩, (hbnd ⟨0, by omega⟩).1, hpt ⟨0, by omega⟩,
           hseg0, (hbnd ⟨0, by omega⟩).2, hsegn⟩
  | m' + 1 =>
    obtain ⟨w, hinc, hbnd, hpt, hseg0, hsegmid, hsegn⟩ := hbf
    refine ⟨w ⟨0, by omega⟩, (hbnd ⟨0, by omega⟩).1,
           hpt ⟨0, by omega⟩, hseg0, (hbnd ⟨0, by omega⟩).2, ?_⟩
    refine ⟨fun i => w ⟨i.val + 1, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j hij
      exact hinc ⟨i.val + 1, by omega⟩ ⟨j.val + 1, by omega⟩ (by
        simp only [Fin.lt_def] at hij ⊢; omega)
    · intro i
      exact ⟨hinc ⟨0, by omega⟩ ⟨i.val + 1, by omega⟩ (by
               simp only [Fin.lt_def]; omega),
             (hbnd ⟨i.val + 1, by omega⟩).2⟩
    · exact fun i => hpt ⟨i.val + 1, by omega⟩
    · intro y hy hyw; exact hsegmid ⟨0, by omega⟩ y hy hyw
    · intro i y hy1 hy2; exact hsegmid ⟨i.val + 1, by omega⟩ y hy1 hy2
    · exact hsegn

/-! ## chainHolds ↔ BracketFormula.holds -/

theorem chainHolds_iff_holds {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (endRight : TemporalPred)
    (z0 : M.carrier) :
    chainHolds M atomMap bf endRight z0 ↔
    ∃ z1 : M.carrier, z0 < z1 ∧ endRight.eval_at M atomMap z1 ∧
      bf.holds M atomMap z0 z1 := by
  induction n generalizing z0 with
  | zero =>
    simp only [chainHolds, BracketFormula.holds, BracketFormula.toIntervalPattern,
               IntervalPattern.holds]
  | succ m ih =>
    simp only [chainHolds]
    constructor
    · intro ⟨x, hx, hpt, hseg, hchain⟩
      rw [ih] at hchain
      obtain ⟨z1, hxz1, hend, hshifted⟩ := hchain
      exact ⟨z1, lt_trans hx hxz1, hend,
             bracket_prepend_witness bf M atomMap z0 z1 x hx hxz1 hpt hseg hshifted⟩
    · intro ⟨z1, hz0z1, hend, hbf⟩
      obtain ⟨x, hx, hpt, hseg, hxz1, hshifted⟩ :=
        bracket_extract_first_witness bf M atomMap z0 z1 hbf
      exact ⟨x, hx, hpt, hseg, (ih _ x).mpr ⟨z1, hxz1, hend, hshifted⟩⟩

/-! ## bracketBuildRight ↔ chainHolds -/

theorem bracketBuildRight_iff_chainHolds {sig : MonadicSignature} {n : Nat}
    (bf : BracketFormula n) (endRight : TemporalPred)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t (bracketBuildRight bf endRight) ↔
    chainHolds M atomMap bf endRight t := by
  induction n generalizing t with
  | zero =>
    simp only [bracketBuildRight, chainHolds]
    rw [buildRight_correct]
    simp only [buildRight_spec]
    constructor
    · intro ⟨z1, hz, hend, hseg, _⟩; exact ⟨z1, hz, hend, hseg⟩
    · intro ⟨z1, hz, hend, hseg⟩
      exact ⟨z1, hz, hend, hseg, fun s _ => by
        simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]⟩
  | succ m ih =>
    simp only [bracketBuildRight, chainHolds, temporal_truth]
    constructor
    · intro ⟨x, hx, h_event, h_guard⟩
      rw [temporal_truth_and] at h_event
      exact ⟨x, hx, h_event.1, h_guard, (ih _ x).mp h_event.2⟩
    · intro ⟨x, hx, hpt, hseg, hchain⟩
      refine ⟨x, hx, ?_, hseg⟩
      rw [temporal_truth_and]
      exact ⟨hpt, (ih _ x).mpr hchain⟩

/-! ## Main correctness theorems -/

/-- Correctness of `bracketBuildRight` (Proposition 3.5 core). -/
theorem bracketBuildRight_correct {sig : MonadicSignature} {n : Nat}
    (bf : BracketFormula n) (endRight : TemporalPred)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t (bracketBuildRight bf endRight) ↔
    ∃ z1 : M.carrier, t < z1 ∧ endRight.eval_at M atomMap z1 ∧
      bf.holds M atomMap t z1 := by
  rw [bracketBuildRight_iff_chainHolds, chainHolds_iff_holds M atomMap]

/-! ## Leftward (Since-based) bracket translation (Rabinovich 2014, Prop 3.5 mirror)

The Since-mirror of `bracketBuildRight`. Where `bracketBuildRight bf endRight`
holds at `z0` iff there is a future `z1 > z0` closing the bracket, the leftward
`bracketBuildLeft bf endLeft` holds at `z1` iff there is a past `z0 < z1` with
`endLeft` at `z0` and the bracket on `(z0, z1)`. Witnesses are absorbed from the
right (nearest to `z1`) via `Formula.snce`, the Since analog of the `Formula.untl`
used by `bracketBuildRight`. -/

/-- Recursive chain-of-existentials specification matching `bracketBuildLeft`.
    Peels the rightmost witness first (Since walks into the past from `z1`). -/
def chainHoldsLeft {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    {n : Nat} → BracketFormula n → TemporalPred → M.carrier → Prop
  | 0, bf, endLeft, z1 =>
    ∃ z0 : M.carrier, z0 < z1 ∧
      endLeft.eval_at M atomMap z0 ∧
      ∀ y : M.carrier, z0 < y → y < z1 →
        (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
  | n + 1, bf, endLeft, z1 =>
    let shifted : BracketFormula n :=
      { pointTypes := fun i => bf.pointTypes ⟨i.val, by omega⟩
        segmentTypes := fun i => bf.segmentTypes ⟨i.val, by omega⟩ }
    ∃ x : M.carrier, x < z1 ∧
      (bf.pointTypes ⟨n, by omega⟩).eval_at M atomMap x ∧
      (∀ r : M.carrier, x < r → r < z1 →
        (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap r) ∧
      chainHoldsLeft M atomMap shifted endLeft x

/-- Recursively translate a bracket formula to a leftward (Since) temporal formula. -/
noncomputable def bracketBuildLeft :
    {n : Nat} → BracketFormula n → TemporalPred → Formula
  | 0, bf, endLeft =>
    buildLeft [(endLeft, bf.segmentTypes ⟨0, by omega⟩)] TemporalPred.top
  | n + 1, bf, endLeft =>
    let shifted : BracketFormula n :=
      { pointTypes := fun i => bf.pointTypes ⟨i.val, by omega⟩
        segmentTypes := fun i => bf.segmentTypes ⟨i.val, by omega⟩ }
    Formula.snce
      (Formula.and (bf.pointTypes ⟨n, by omega⟩).formula
        (bracketBuildLeft shifted endLeft))
      (bf.segmentTypes ⟨n + 1, by omega⟩).formula

/-! ## Definitional unfolding lemmas (structural matches resist `simp`/`unfold`) -/

theorem chainHoldsLeft_zero_eq {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula 0) (endLeft : TemporalPred) (z1 : M.carrier) :
    chainHoldsLeft M atomMap bf endLeft z1 =
      ∃ z0 : M.carrier, z0 < z1 ∧ endLeft.eval_at M atomMap z0 ∧
        ∀ y : M.carrier, z0 < y → y < z1 →
          (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y := rfl

theorem chainHoldsLeft_succ_eq {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (bf : BracketFormula (n + 1)) (endLeft : TemporalPred) (z1 : M.carrier) :
    chainHoldsLeft M atomMap bf endLeft z1 =
      ∃ x : M.carrier, x < z1 ∧
        (bf.pointTypes ⟨n, by omega⟩).eval_at M atomMap x ∧
        (∀ r : M.carrier, x < r → r < z1 →
          (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap r) ∧
        chainHoldsLeft M atomMap
          (BracketFormula.mk
            (fun i : Fin n => bf.pointTypes ⟨i.val, by omega⟩)
            (fun i : Fin (n + 1) => bf.segmentTypes ⟨i.val, by omega⟩))
          endLeft x := rfl

theorem bracketBuildLeft_zero_eq (bf : BracketFormula 0) (endLeft : TemporalPred) :
    bracketBuildLeft bf endLeft =
      buildLeft [(endLeft, bf.segmentTypes ⟨0, by omega⟩)] TemporalPred.top := rfl

theorem bracketBuildLeft_succ_eq {n : Nat} (bf : BracketFormula (n + 1))
    (endLeft : TemporalPred) :
    bracketBuildLeft bf endLeft =
      Formula.snce
        (Formula.and (bf.pointTypes ⟨n, by omega⟩).formula
          (bracketBuildLeft
            (BracketFormula.mk
              (fun i : Fin n => bf.pointTypes ⟨i.val, by omega⟩)
              (fun i : Fin (n + 1) => bf.segmentTypes ⟨i.val, by omega⟩))
            endLeft))
        (bf.segmentTypes ⟨n + 1, by omega⟩).formula := rfl

/-! ## Helper: append witness to bracket holds (leftward peel) -/

/-- Append a witness x (as the rightmost witness) to the drop-last bracket's
    witnesses to get full bracket holds. Mirror of `bracket_prepend_witness`. -/
private theorem bracket_append_witness {sig : MonadicSignature} {m : Nat}
    (bf : BracketFormula (m + 1))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 x : M.carrier) (hz0x : z0 < x) (hxz1 : x < z1)
    (hpt : (bf.pointTypes ⟨m, by omega⟩).eval_at M atomMap x)
    (hseg : ∀ r, x < r → r < z1 → (bf.segmentTypes ⟨m + 1, by omega⟩).eval_at M atomMap r)
    (hshifted : BracketFormula.holds M atomMap
      (BracketFormula.mk
        (fun i : Fin m => bf.pointTypes ⟨i.val, by omega⟩)
        (fun i : Fin (m + 1) => bf.segmentTypes ⟨i.val, by omega⟩))
      z0 x) :
    bf.holds M atomMap z0 z1 := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
    at hshifted ⊢
  match m with
  | 0 =>
    -- 0 shifted witnesses → 1 total witness (x)
    exact ⟨fun _ => x, fun i j h => absurd h (by omega), fun _ => ⟨hz0x, hxz1⟩,
           fun i => by
             have : i = ⟨0, by omega⟩ := Fin.ext (by omega)
             rw [this]; exact hpt,
           hshifted, fun i => i.elim0, hseg⟩
  | m' + 1 =>
    -- (m'+1) shifted witnesses → (m'+2) total witnesses
    obtain ⟨w', hinc', hbnd', hpt', hseg0', hsegmid', hsegn'⟩ := hshifted
    refine ⟨fun i => if h : i.val < m' + 1 then w' ⟨i.val, h⟩ else x, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- strictly increasing
      intro i j hij
      have hij_val : i.val < j.val := hij
      by_cases hi : i.val < m' + 1 <;> by_cases hj : j.val < m' + 1
      · simp only [dif_pos hi, dif_pos hj]
        exact hinc' ⟨i.val, hi⟩ ⟨j.val, hj⟩ (by simp only [Fin.lt_def]; omega)
      · simp only [dif_pos hi, dif_neg hj]
        exact (hbnd' ⟨i.val, hi⟩).2
      · exfalso; omega
      · exfalso; omega
    · -- all in (z0, z1)
      intro i
      by_cases hi : i.val < m' + 1
      · simp only [dif_pos hi]
        exact ⟨(hbnd' ⟨i.val, hi⟩).1, lt_trans (hbnd' ⟨i.val, hi⟩).2 hxz1⟩
      · simp only [dif_neg hi]; exact ⟨hz0x, hxz1⟩
    · -- point types
      intro i
      by_cases hi : i.val < m' + 1
      · simp only [dif_pos hi]; exact hpt' ⟨i.val, hi⟩
      · simp only [dif_neg hi]
        have hb : i.val < m' + 1 + 1 := i.isLt
        have hi_eq : i.val = m' + 1 := by omega
        have : i = ⟨m' + 1, by omega⟩ := Fin.ext hi_eq
        rw [this]; exact hpt
    · -- beta_0 on (z0, w 0)
      intro y hy0 hyw
      simp only [dif_pos (show (0 : Nat) < m' + 1 from by omega)] at hyw
      exact hseg0' y hy0 hyw
    · -- beta_{i+1} on (w i, w (i+1))
      intro i y hy1 hy2
      by_cases hi1 : i.val + 1 < m' + 1
      · -- both endpoints inside w'
        simp only [dif_pos (show i.val < m' + 1 from by omega), dif_pos hi1] at hy1 hy2
        exact hsegmid' ⟨i.val, by omega⟩ y hy1 hy2
      · -- i.val + 1 = m' + 1, right endpoint is x, left is w' i
        have hb : i.val < m' + 1 := i.isLt
        have him : i.val = m' := by omega
        simp only [dif_pos (show i.val < m' + 1 from by omega),
                   dif_neg (show ¬(i.val + 1 < m' + 1) from by omega)] at hy1 hy2
        simp only [him] at hy1 ⊢
        exact hsegn' y hy1 hy2
    · -- beta_{m'+2} on (w (m'+1), z1) = (x, z1)
      intro y hy1 hy2
      simp only [dif_neg (show ¬(m' + 1 < m' + 1) from by omega)] at hy1
      exact hseg y hy1 hy2

/-! ## Helper: extract last witness from bracket holds -/

/-- Extract the last (rightmost) witness from bracket formula holds.
    Mirror of `bracket_extract_first_witness`. -/
private theorem bracket_extract_last_witness {sig : MonadicSignature} {m : Nat}
    (bf : BracketFormula (m + 1))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier)
    (hbf : bf.holds M atomMap z0 z1) :
    ∃ x : M.carrier, x < z1 ∧
      (bf.pointTypes ⟨m, by omega⟩).eval_at M atomMap x ∧
      (∀ r, x < r → r < z1 → (bf.segmentTypes ⟨m + 1, by omega⟩).eval_at M atomMap r) ∧
      z0 < x ∧
      BracketFormula.holds M atomMap
        (BracketFormula.mk
          (fun i : Fin m => bf.pointTypes ⟨i.val, by omega⟩)
          (fun i : Fin (m + 1) => bf.segmentTypes ⟨i.val, by omega⟩))
        z0 x := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
    at hbf ⊢
  match m with
  | 0 =>
    obtain ⟨w, _, hbnd, hpt, hseg0, _, hsegn⟩ := hbf
    exact ⟨w ⟨0, by omega⟩, (hbnd ⟨0, by omega⟩).2, hpt ⟨0, by omega⟩,
           hsegn, (hbnd ⟨0, by omega⟩).1, hseg0⟩
  | m' + 1 =>
    obtain ⟨w, hinc, hbnd, hpt, hseg0, hsegmid, hsegn⟩ := hbf
    refine ⟨w ⟨m' + 1, by omega⟩, (hbnd ⟨m' + 1, by omega⟩).2,
           hpt ⟨m' + 1, by omega⟩, hsegn, (hbnd ⟨m' + 1, by omega⟩).1, ?_⟩
    refine ⟨fun i => w ⟨i.val, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j hij
      exact hinc ⟨i.val, by omega⟩ ⟨j.val, by omega⟩ (by
        simp only [Fin.lt_def] at hij ⊢; omega)
    · intro i
      exact ⟨(hbnd ⟨i.val, by omega⟩).1,
             hinc ⟨i.val, by omega⟩ ⟨m' + 1, by omega⟩ (by
               simp only [Fin.lt_def]; omega)⟩
    · exact fun i => hpt ⟨i.val, by omega⟩
    · exact hseg0
    · intro i y hy1 hy2; exact hsegmid ⟨i.val, by omega⟩ y hy1 hy2
    · intro y hy1 hy2; exact hsegmid ⟨m', by omega⟩ y hy1 hy2

/-! ## chainHoldsLeft ↔ BracketFormula.holds -/

theorem chainHoldsLeft_iff_holds {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (endLeft : TemporalPred)
    (z1 : M.carrier) :
    chainHoldsLeft M atomMap bf endLeft z1 ↔
    ∃ z0 : M.carrier, z0 < z1 ∧ endLeft.eval_at M atomMap z0 ∧
      bf.holds M atomMap z0 z1 := by
  induction n generalizing z1 with
  | zero =>
    rw [chainHoldsLeft_zero_eq]
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
  | succ m ih =>
    rw [chainHoldsLeft_succ_eq]
    constructor
    · intro ⟨x, hx, hpt, hseg, hchain⟩
      rw [ih] at hchain
      obtain ⟨z0, hz0x, hend, hshifted⟩ := hchain
      exact ⟨z0, lt_trans hz0x hx, hend,
             bracket_append_witness bf M atomMap z0 z1 x hz0x hx hpt hseg hshifted⟩
    · intro ⟨z0, hz0z1, hend, hbf⟩
      obtain ⟨x, hxz1, hpt, hseg, hz0x, hshifted⟩ :=
        bracket_extract_last_witness bf M atomMap z0 z1 hbf
      exact ⟨x, hxz1, hpt, hseg, (ih _ x).mpr ⟨z0, hz0x, hend, hshifted⟩⟩

/-! ## bracketBuildLeft ↔ chainHoldsLeft -/

theorem bracketBuildLeft_iff_chainHoldsLeft {sig : MonadicSignature} {n : Nat}
    (bf : BracketFormula n) (endLeft : TemporalPred)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t (bracketBuildLeft bf endLeft) ↔
    chainHoldsLeft M atomMap bf endLeft t := by
  induction n generalizing t with
  | zero =>
    rw [bracketBuildLeft_zero_eq, chainHoldsLeft_zero_eq, buildLeft_correct]
    simp only [buildLeft_spec]
    constructor
    · intro ⟨z0, hz, hend, hseg, _⟩; exact ⟨z0, hz, hend, hseg⟩
    · intro ⟨z0, hz, hend, hseg⟩
      exact ⟨z0, hz, hend, hseg, fun s _ => by
        simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]⟩
  | succ m ih =>
    rw [bracketBuildLeft_succ_eq, chainHoldsLeft_succ_eq]
    simp only [temporal_truth]
    constructor
    · intro ⟨x, hx, h_event, h_guard⟩
      rw [temporal_truth_and] at h_event
      exact ⟨x, hx, h_event.1, h_guard, (ih _ x).mp h_event.2⟩
    · intro ⟨x, hx, hpt, hseg, hchain⟩
      refine ⟨x, hx, ?_, hseg⟩
      rw [temporal_truth_and]
      exact ⟨hpt, (ih _ x).mpr hchain⟩

/-! ## Main correctness theorem (leftward) -/

/-- Correctness of `bracketBuildLeft` (Proposition 3.5 core, Since-mirror). -/
theorem bracketBuildLeft_correct {sig : MonadicSignature} {n : Nat}
    (bf : BracketFormula n) (endLeft : TemporalPred)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t (bracketBuildLeft bf endLeft) ↔
    ∃ z0 : M.carrier, z0 < t ∧ endLeft.eval_at M atomMap z0 ∧
      bf.holds M atomMap z0 t := by
  rw [bracketBuildLeft_iff_chainHoldsLeft, chainHoldsLeft_iff_holds M atomMap]

/-! ## VecEA2 translation -/

/-- Translate a `VecEA2 n` to a temporal formula with the free variable at z_0. -/
noncomputable def VecEA2.translateLeft {n : Nat} (vea : VecEA2 n) : Formula :=
  Formula.and vea.endpointLeft.formula (bracketBuildRight vea.bracket vea.endpointRight)

/-- The semantic specification of a VecEA2 with the free variable at z_0. -/
def VecEA2.holdsLeft {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA2 n) (t : M.carrier) : Prop :=
  vea.endpointLeft.eval_at M atomMap t ∧
  ∃ z1 : M.carrier, t < z1 ∧
    vea.endpointRight.eval_at M atomMap z1 ∧
    vea.bracket.holds M atomMap t z1

/-- Correctness of `VecEA2.translateLeft` (Proposition 3.5). -/
theorem VecEA2.translateLeft_correct {sig : MonadicSignature} {n : Nat}
    (vea : VecEA2 n)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t vea.translateLeft ↔ vea.holdsLeft M atomMap t := by
  simp only [translateLeft, holdsLeft]
  rw [temporal_truth_and]
  exact Iff.intro
    (fun ⟨h1, h2⟩ => ⟨h1, (bracketBuildRight_correct _ _ M atomMap t).mp h2⟩)
    (fun ⟨h1, h2⟩ => ⟨h1, (bracketBuildRight_correct _ _ M atomMap t).mpr h2⟩)

/-! ## V-vec-EA-2 translation (disjunction case) -/

/-- Left translation of a `VVecEA2`: the `translateVEF1` disjunction of the left
translations of its disjuncts. -/
noncomputable def VVecEA2.translateLeft (v : VVecEA2) : Formula :=
  translateVEF1 (v.disjuncts.map fun ⟨_, vea⟩ => vea.translateLeft)

/-- Semantics of a `VVecEA2` at a point: some disjunct's `holdsLeft` holds there. This is
the statement `VVecEA2.translateLeft_correct` matches against. -/
def VVecEA2.holdsLeft {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) (t : M.carrier) : Prop :=
  ∃ vea ∈ v.disjuncts, vea.2.holdsLeft M atomMap t

theorem VVecEA2.translateLeft_correct {sig : MonadicSignature}
    (v : VVecEA2)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t v.translateLeft ↔ v.holdsLeft M atomMap t := by
  simp only [translateLeft, holdsLeft]
  rw [translateVEF1_correct]
  constructor
  · rintro ⟨f, hf_mem, hf⟩
    rw [List.mem_map] at hf_mem
    obtain ⟨⟨n, vea⟩, h_mem, rfl⟩ := hf_mem
    exact ⟨⟨n, vea⟩, h_mem, (vea.translateLeft_correct M atomMap t).mp hf⟩
  · rintro ⟨⟨n, vea⟩, h_mem, h_holds⟩
    exact ⟨vea.translateLeft,
           List.mem_map.mpr ⟨⟨n, vea⟩, h_mem, rfl⟩,
           (vea.translateLeft_correct M atomMap t).mpr h_holds⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
