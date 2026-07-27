/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegation
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure
-- `List.mem_permutations` (membership ↔ `List.Perm`) for the head-coverage helper
import Mathlib.Data.List.Permutation

/-!
# EA Negation Closure (Model-Dependent, Forward-Only)

Proves Lemma 5.1 and Corollary 5.4 of Rabinovich 2014 in model-dependent,
forward-only form. These avoid the structurally unsolvable beta_0(r_0) problem
that blocks the biconditional approach in `EANegation.lean`.

This file provides the **model-dependent foundation** for the model-independent
version in `NegationIndep.lean`. Specifically:
- `neg_interval_formula` is model-dependent Lemma 5.1 (existential output)
- `neg_2var_vec_ea` is model-dependent Prop 4.2 (existential output)
The model-independent versions (`neg_interval_formula_indep`,
`neg_2var_vec_ea_indep`) in `NegationIndep.lean` construct fixed VVecEA2
formulas whose correctness on each model follows from the model-dependent
theorems here.

## Key Theorems

- `neg_interval_formula`: Lemma 5.1 forward -- if not bf.holds z0 z1 on a Prior
  structure, there exists a VBracketFormula that holds on (z0, z1).
- `neg_bounded_exists`: Corollary 5.4 forward -- if not (exists z, bf.holds z0 z) on
  a Prior structure, there exists a VBracketFormula that holds on (z0, z1).
- `neg_2var_vec_ea`: Prop 4.2 -- negation of VVecEA2 produces VVecEA2 (model-dependent).

## Provenance

Ported from Boneyard/KampNegationClosure/NegationClosure5.lean (archived 2026-06-16).
Adapted to use `HasAttainedINF` instead of raw `SemanticPriorUZ`.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.1 (pp.7-11), Corollary 5.4 (p.10)
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Helper: TemporalPred.eval_at_neg -/

/-- `(P.neg).EvalAt` iff `¬(P.EvalAt)`. -/
theorem TemporalPred.eval_at_neg' {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (t : M.carrier) :
    P.neg.EvalAt M atomMap t ↔ ¬P.EvalAt M atomMap t := by
  simp only [TemporalPred.neg, TemporalPred.EvalAt, Formula.neg, TemporalTruth]

/-! ## Helper: HasAttainedINF.first_occ_tp

Wraps `HasAttainedINF.first_occ` to accept a `TemporalPred` directly. -/

/-- First occurrence of a temporal predicate P in (z0, z1) on structures with
    attained infima. Wraps `HasAttainedINF.first_occ` using `P.formula`. -/
theorem HasAttainedINF.first_occ_tp {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.EvalAt M atomMap x) :
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      P.EvalAt M atomMap r0 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → ¬P.EvalAt M atomMap y) := by
  obtain ⟨x, hx0, hx1, hPx⟩ := h_exists
  obtain ⟨r0, hr0_above, hr0_below, h_neg_before, hPr0⟩ :=
    h_INF.first_occ P.formula z0 z1 h_lt ⟨x, hx0, hx1, hPx⟩
  exact ⟨r0, hr0_above, hr0_below, hPr0, fun y hy0 hy1 hPy =>
    h_neg_before y hy0 hy1 hPy⟩

/-! ## BracketFormula.tail

The tail of a bracket formula with n+1 witnesses: the sub-bracket from
position 1 onward. -/

/-- The tail of a bracket formula: point and segment types shifted by 1. -/
def BracketFormula.tail {n : Nat} (bf : BracketFormula (n + 1)) : BracketFormula n :=
  { pointTypes := fun i => bf.pointTypes ⟨i.val + 1, by omega⟩
    segmentTypes := fun i => bf.segmentTypes ⟨i.val + 1, by omega⟩ }

/-! ## bracket_tail_satisfiable

Key helper for Case B1: if the tail bracket formula holds on (r0, z) with
first-witness conditions, then bf holds on (z0, z). -/

/-- If `bf.tail` holds on (r0, z) with `pointTypes(0)(r0)` and `segmentTypes(0)` on (z0, r0),
    then `bf` holds on (z0, z). -/
theorem bracket_tail_satisfiable {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (z0 z r0 : M.carrier)
    (hr0_above : z0 < r0) (hr0_below : r0 < z)
    (hPt : (bf.pointTypes ⟨0, by omega⟩).EvalAt M atomMap r0)
    (hSeg : ∀ y : M.carrier, z0 < y → y < r0 →
      (bf.segmentTypes ⟨0, by omega⟩).EvalAt M atomMap y)
    (h_tail : bf.tail.holds M atomMap r0 z) :
    bf.holds M atomMap z0 z := by
  change bf.toIntervalPattern.holds M atomMap z0 z
  have h_tail' : bf.tail.toIntervalPattern.holds M atomMap r0 z := h_tail
  simp only [BracketFormula.toIntervalPattern, BracketFormula.tail] at h_tail'
  simp only [BracketFormula.toIntervalPattern]
  simp only [IntervalPattern.holds] at h_tail' ⊢
  match n with
  | 0 =>
    refine ⟨fun _ => r0, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j hij
      have h1 : i.val = 0 := Nat.lt_one_iff.mp i.isLt
      have h2 : j.val = 0 := Nat.lt_one_iff.mp j.isLt
      exact absurd (show i = j from Fin.ext (by omega)) (Fin.ne_of_lt hij)
    · intro _; exact ⟨hr0_above, hr0_below⟩
    · intro ⟨i, hi⟩
      have : i = 0 := Nat.lt_one_iff.mp hi
      subst this; exact hPt
    · intro y hy0 hy1; exact hSeg y hy0 hy1
    · intro ⟨i, hi⟩; exact absurd hi (Nat.not_lt_zero i)
    · intro y hy0 hy1; exact h_tail' y hy0 hy1
  | n' + 1 =>
    obtain ⟨w, hm, hbnd, hpt, hseg0, hseg_mid, hseg_last⟩ := h_tail'
    refine ⟨fun ⟨i, hi⟩ => if h : i = 0 then r0 else w ⟨i - 1, by omega⟩,
            ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- Strictly increasing
      intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      simp only [Fin.lt_def] at hij
      by_cases h0 : i = 0
      · subst h0; simp only [dite_true]
        have hj_ne : ¬(j = 0) := by omega
        simp only [hj_ne, dite_false]
        exact lt_of_lt_of_le (hbnd ⟨0, by omega⟩).1
          (by rcases Nat.eq_or_lt_of_le (Nat.one_le_of_lt (by omega : 0 < j)) with rfl | hlt
              · simp
              · exact le_of_lt (hm ⟨0, by omega⟩ ⟨j - 1, by omega⟩
                  (by simp [Fin.lt_def]; omega)))
      · have hj_ne : ¬(j = 0) := by omega
        simp only [show ¬(i = 0) from h0, dite_false, hj_ne, dite_false]
        exact hm ⟨i - 1, by omega⟩ ⟨j - 1, by omega⟩ (by simp [Fin.lt_def]; omega)
    · -- All in (z0, z)
      intro ⟨i, hi⟩
      by_cases h0 : i = 0
      · subst h0; simp only [dite_true]; exact ⟨hr0_above, hr0_below⟩
      · simp only [show ¬(i = 0) from h0, dite_false]
        exact ⟨lt_trans hr0_above (hbnd ⟨i - 1, by omega⟩).1,
               (hbnd ⟨i - 1, by omega⟩).2⟩
    · -- Point types
      intro ⟨i, hi⟩
      by_cases h0 : i = 0
      · subst h0; simp only [dite_true]; exact hPt
      · simp only [show ¬(i = 0) from h0, dite_false]
        have h := hpt ⟨i - 1, by omega⟩
        simp only at h
        convert h using 2
        simp [Fin.ext_iff]; omega
    · -- Segment 0
      intro y hy0 hy1
      simp only [dite_true] at hy1
      exact hSeg y hy0 hy1
    · -- Middle segments
      intro ⟨i, hi⟩ y hy_lo hy_hi
      by_cases h0 : i = 0
      · subst h0
        simp only [dite_true] at hy_lo
        simp only [show ¬((0 : Nat) + 1 = 0) from by omega, dite_false] at hy_hi
        exact hseg0 y hy_lo hy_hi
      · simp only [show ¬(i = 0) from h0, dite_false, show ¬(i + 1 = 0) from by omega,
                    dite_false] at hy_lo hy_hi
        have h := hseg_mid ⟨i - 1, by omega⟩ y hy_lo
          (by convert hy_hi using 2; congr 1; simp; omega)
        convert h using 2; congr 1; simp; omega
    · -- Last segment
      intro y hy_lo hy_hi
      simp only [show ¬(n' + 1 = 0) from by omega, dite_false] at hy_lo
      exact hseg_last y hy_lo hy_hi

/-! ## INF bracket formula

The bracket formula [not P, P, True](z_0, z_1) describing the first occurrence
of P in (z_0, z_1). -/

/-- The INF bracket formula: [not P, P, True](z_0, z_1). -/
def infBracketFormula (P : TemporalPred) : BracketFormula 1 :=
  { pointTypes := fun _ => P
    segmentTypes := fun i => if i.val = 0 then P.neg else TemporalPred.top }

/-- The INF bracket formula holds iff there exists a first-occurrence witness. -/
theorem inf_bracket_formula_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    (infBracketFormula P).holds M atomMap z0 z1 ↔
    ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
      P.EvalAt M atomMap x ∧
      (∀ y : M.carrier, z0 < y → y < x → P.neg.EvalAt M atomMap y) := by
  simp only [infBracketFormula, BracketFormula.holds, BracketFormula.toIntervalPattern,
             IntervalPattern.holds]
  constructor
  · rintro ⟨w, _, hbnd, hpt, hseg0, _, hseg1⟩
    refine ⟨w ⟨0, by omega⟩, (hbnd ⟨0, by omega⟩).1, (hbnd ⟨0, by omega⟩).2,
            hpt ⟨0, by omega⟩, ?_⟩
    intro y hy0 hy1
    have := hseg0 y hy0 hy1
    simp only [↓reduceIte] at this
    exact this
  · rintro ⟨x, hx0, hx1, hPx, h_neg⟩
    refine ⟨fun _ => x, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      simp only [zero_add, Order.lt_one_iff] at hi hj; subst hi; subst hj; exact absurd hij
          (lt_irrefl _)
    · intro _; exact ⟨hx0, hx1⟩
    · intro _; exact hPx
    · intro y hy0 hy1
      have := h_neg y hy0 hy1
      simp only [↓reduceIte]; exact this
    · intro i; exact Fin.elim0 i
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y

/-- On structures with HasAttainedINF, if P occurs in (z_0, z_1), the INF bracket
    formula holds. -/
theorem inf_bracket_formula_hasINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.EvalAt M atomMap x) :
    (infBracketFormula P).holds M atomMap z0 z1 := by
  rw [inf_bracket_formula_holds]
  obtain ⟨r0, hr0_above, hr0_strict, hPr0, h_neg⟩ :=
    h_INF.first_occ_tp P z0 z1 h_lt h_exists
  exact ⟨r0, hr0_above, hr0_strict, hPr0, fun y hy0 hy1 =>
    (TemporalPred.eval_at_neg' M atomMap P y).mpr (h_neg y hy0 hy1)⟩

/-! ## B.2 Bracket Formula: negB2BracketFormula

The 2-witness bracket formula encoding that beta_0 fails before the first
alpha_0 point. Used in Case B.2 of neg_interval_formula_indep (NegationIndep.lean)
to replace infBracketFormula, enabling the backward (disjointness) proof.

The first witness carries both beta_0.neg AND alpha_0.neg (as a conjunction)
to close all cases in the disjointness argument -- this prevents the witness
from coinciding with any alpha_0 point of the original bracket formula. -/

/-- The B.2 bracket formula: encodes that beta_0 fails before the first alpha_0.
    Two witnesses: y (beta_0 failure, alpha_0 non-occurrence) < x (first alpha_0).
    - pointTypes(0) = (beta_0.neg).conj (alpha_0.neg) at y
    - pointTypes(1) = alpha_0 at x
    - segmentTypes(0) = alpha_0.neg on (z_0, y)
    - segmentTypes(1) = alpha_0.neg on (y, x)
    - segmentTypes(2) = top on (x, z_1) -/
def negB2BracketFormula (alpha_0 beta_0 : TemporalPred) : BracketFormula 2 :=
  { pointTypes := fun i => if i.val = 0 then (beta_0.neg).conj (alpha_0.neg) else alpha_0
    segmentTypes := fun i =>
      if i.val ≤ 1 then alpha_0.neg else TemporalPred.top }

/-- If alpha_0 has first occurrence r0 in (z0, z1) and beta_0 fails on (z0, r0),
    then negB2BracketFormula holds on (z0, z1). -/
theorem neg_b2_bracket_formula_hasINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (_h_INF : HasAttainedINF M atomMap)
    (alpha_0 beta_0 : TemporalPred) (z0 z1 : M.carrier) (_h_lt : z0 < z1)
    (r0 : M.carrier) (hr0_above : z0 < r0) (hr0_below : r0 < z1)
    (hPr0 : alpha_0.EvalAt M atomMap r0)
    (h_neg_before : ∀ y : M.carrier, z0 < y → y < r0 → ¬alpha_0.EvalAt M atomMap y)
    (h_seg_fail : ¬∀ y : M.carrier, z0 < y → y < r0 → beta_0.EvalAt M atomMap y) :
    (negB2BracketFormula alpha_0 beta_0).holds M atomMap z0 z1 := by
  push Not at h_seg_fail
  obtain ⟨y0, hy0_above, hy0_below, h_beta_neg⟩ := h_seg_fail
  -- Witnesses: y0 (beta_0 failure, also alpha_0.neg since y0 < r0) and r0 (first alpha_0)
  simp only [negB2BracketFormula, BracketFormula.holds, BracketFormula.toIntervalPattern,
             IntervalPattern.holds]
  refine ⟨fun ⟨i, hi⟩ => if i = 0 then y0 else r0, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Strictly increasing
    intro ⟨i, hi⟩ ⟨j, hj⟩ hij
    simp only [Fin.lt_def] at hij
    have hi0 : i = 0 := by omega
    have hj1 : j = 1 := by omega
    subst hi0; subst hj1
    simp only [↓reduceIte, one_ne_zero, gt_iff_lt]; exact hy0_below
  · -- All in (z0, z1)
    intro ⟨i, hi⟩
    by_cases h : i = 0
    · subst h; simp only [↓reduceIte]; exact ⟨hy0_above, lt_trans hy0_below hr0_below⟩
    · have h1 : i = 1 := by omega
      subst h1; simp only [one_ne_zero, ↓reduceIte]; exact ⟨hr0_above, hr0_below⟩
  · -- Point types
    intro ⟨i, hi⟩
    by_cases h : i = 0
    · subst h; simp only [↓reduceIte]
      exact (TemporalPred.eval_at_conj M atomMap beta_0.neg alpha_0.neg y0).mpr
        ⟨(TemporalPred.eval_at_neg' M atomMap beta_0 y0).mpr h_beta_neg,
         (TemporalPred.eval_at_neg' M atomMap alpha_0 y0).mpr (h_neg_before y0 hy0_above hy0_below)⟩
    · have h1 : i = 1 := by omega
      subst h1; simp only [one_ne_zero, ↓reduceIte]; exact hPr0
  · -- Segment 0: alpha_0.neg on (z0, y0)
    intro y hy0 hy1
    simp only [↓reduceIte] at hy1
    exact (TemporalPred.eval_at_neg' M atomMap alpha_0 y).mpr
      (h_neg_before y hy0 (lt_trans hy1 hy0_below))
  · -- Middle segments: segment 1 is alpha_0.neg on (y0, r0)
    intro ⟨i, hi⟩ y hy_lo hy_hi
    have hi0 : i = 0 := by omega
    subst hi0
    simp only [↓reduceIte, zero_add, show ¬((0 : Nat) + 1 = 0) from by omega] at hy_lo hy_hi
    exact (TemporalPred.eval_at_neg' M atomMap alpha_0 y).mpr
      (h_neg_before y (lt_trans hy0_above hy_lo) hy_hi)
  · -- Last segment: top on (r0, z1)
    intro y _ _
    simp only [Nat.reduceAdd, Nat.not_ofNat_le_one, ↓reduceIte]
    exact TemporalPred.eval_at_top M atomMap y

/-- If negB2BracketFormula(alpha_0, beta_0) holds on (z0, z1) and bf has
    alpha_0 as its first point type and beta_0 as its first segment type,
    then bf cannot hold on (z0, z1).

    Proof: From negB2BracketFormula we get y < x with alpha_0.neg on all
    of (z0, x) (including the point y via the conjunction). From bf we get
    alpha_0(w_0) forcing w_0 >= x. Then y is in (z0, w_0) with beta_0.neg(y),
    contradicting beta_0 on (z0, w_0) from bf. -/
theorem neg_b2_bracket_formula_disjoint {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n : Nat} (bf : BracketFormula (n + 1))
    (alpha_0 beta_0 : TemporalPred)
    (h_pt : bf.pointTypes ⟨0, by omega⟩ = alpha_0)
    (h_seg : bf.segmentTypes ⟨0, by omega⟩ = beta_0)
    (z0 z1 : M.carrier)
    (h_b2 : (negB2BracketFormula alpha_0 beta_0).holds M atomMap z0 z1)
    (h_bf : bf.holds M atomMap z0 z1) : False := by
  -- Extract witnesses from negB2BracketFormula
  simp only [negB2BracketFormula, BracketFormula.holds, BracketFormula.toIntervalPattern,
             IntervalPattern.holds] at h_b2
  obtain ⟨w_b2, hm_b2, hbnd_b2, hpt_b2, hseg0_b2, hseg_mid_b2, _⟩ := h_b2
  -- Extract witnesses from bf.holds
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
             IntervalPattern.holds] at h_bf
  obtain ⟨w_bf, _, hbnd_bf, hpt_bf, hseg0_bf, _, _⟩ := h_bf
  -- Key facts from bf: alpha_0(w_bf(0)) and beta_0 on (z0, w_bf(0))
  have h_alpha_0_at_w0 : alpha_0.EvalAt M atomMap (w_bf ⟨0, by omega⟩) := by
    have := hpt_bf ⟨0, by omega⟩; rw [h_pt] at this; exact this
  have h_beta_0_seg : ∀ y : M.carrier, z0 < y → y < w_bf ⟨0, by omega⟩ →
      beta_0.EvalAt M atomMap y := by
    intro y hy0 hy1
    have := hseg0_bf y hy0 hy1; rw [h_seg] at this; exact this
  -- Key facts from negB2BracketFormula:
  -- w_b2(0) has (beta_0.neg).conj(alpha_0.neg), so both beta_0.neg and alpha_0.neg
  have h_conj := hpt_b2 ⟨0, by omega⟩
  simp only [↓reduceIte, Nat.reduceAdd, Fin.zero_eta, Fin.isValue] at h_conj
  have h_beta_neg_y : ¬beta_0.EvalAt M atomMap (w_b2 ⟨0, by omega⟩) :=
    (TemporalPred.eval_at_neg' M atomMap beta_0 _).mp
      ((TemporalPred.eval_at_conj M atomMap beta_0.neg alpha_0.neg _).mp h_conj).1
  have h_alpha_neg_y : ¬alpha_0.EvalAt M atomMap (w_b2 ⟨0, by omega⟩) :=
    (TemporalPred.eval_at_neg' M atomMap alpha_0 _).mp
      ((TemporalPred.eval_at_conj M atomMap beta_0.neg alpha_0.neg _).mp h_conj).2
  -- Step 1: Show w_bf(0) >= w_b2(1) (i.e., ¬(w_bf(0) < w_b2(1)))
  -- alpha_0.neg on (z0, w_b2(0)) from segment 0, on (w_b2(0), w_b2(1)) from segment 1,
  -- and alpha_0.neg AT w_b2(0) from the conjunction.
  -- So alpha_0.neg on the closed-open set [z0+, w_b2(1)) covers w_bf(0) if w_bf(0) < w_b2(1).
  have h_wbf0_not_lt : ¬(w_bf ⟨0, by omega⟩ < w_b2 ⟨1, by omega⟩) := by
    intro h_lt_x
    -- w_bf(0) is in (z0, w_b2(1)), show alpha_0.neg(w_bf(0))
    have h_wbf0_above : z0 < w_bf ⟨0, by omega⟩ := (hbnd_bf ⟨0, by omega⟩).1
    by_cases h_ord2 : w_bf ⟨0, by omega⟩ < w_b2 ⟨0, by omega⟩
    · -- In segment 0: alpha_0.neg on (z0, w_b2(0))
      have := hseg0_b2 (w_bf ⟨0, by omega⟩) h_wbf0_above h_ord2
      simp only [zero_le, ↓reduceIte, Fin.zero_eta] at this
      exact absurd h_alpha_0_at_w0
        ((TemporalPred.eval_at_neg' M atomMap alpha_0 _).mp this)
    · push Not at h_ord2
      by_cases h_eq : w_bf ⟨0, by omega⟩ = w_b2 ⟨0, by omega⟩
      · -- w_bf(0) = w_b2(0): use alpha_0.neg from the conjunction
        rw [h_eq] at h_alpha_0_at_w0
        exact h_alpha_neg_y h_alpha_0_at_w0
      · -- w_b2(0) < w_bf(0) < w_b2(1): in segment 1, alpha_0.neg
        have h_lo : w_b2 ⟨0, by omega⟩ < w_bf ⟨0, by omega⟩ :=
          lt_of_le_of_ne h_ord2 (Ne.symm h_eq)
        have := hseg_mid_b2 ⟨0, by omega⟩ (w_bf ⟨0, by omega⟩) h_lo h_lt_x
        simp only [zero_add, Std.le_refl, ↓reduceIte, Fin.zero_eta] at this
        exact absurd h_alpha_0_at_w0
          ((TemporalPred.eval_at_neg' M atomMap alpha_0 _).mp this)
  -- Step 2: w_bf(0) >= w_b2(1), so w_b2(0) < w_b2(1) <= w_bf(0)
  push Not at h_wbf0_not_lt
  have h_y_above : z0 < w_b2 ⟨0, by omega⟩ := (hbnd_b2 ⟨0, by omega⟩).1
  have h_y_below : w_b2 ⟨0, by omega⟩ < w_bf ⟨0, by omega⟩ :=
    lt_of_lt_of_le (hm_b2 ⟨0, by omega⟩ ⟨1, by omega⟩ (by simp)) h_wbf0_not_lt
  -- Step 3: beta_0 on (z0, w_bf(0)) from bf, but beta_0.neg at w_b2(0) -- contradiction
  exact h_beta_neg_y (h_beta_0_seg _ h_y_above h_y_below)

/-- The INF formula produces a VBracketFormula witnessing the first occurrence. -/
theorem inf_formula_is_vbracket {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.EvalAt M atomMap x) :
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1 :=
  ⟨⟨[⟨1, infBracketFormula P⟩]⟩,
   ⟨1, infBracketFormula P⟩,
   List.mem_singleton.mpr rfl,
   inf_bracket_formula_hasINF h_INF P z0 z1 h_lt h_exists⟩

/-! ## Lemma 5.1: neg_interval_formula (forward, model-dependent)

The negation of any bracket formula on (z_0, z_1) is a VBracketFormula,
on structures with HasAttainedINF. -/

/-- **Lemma 5.1** (Rabinovich 2014, forward direction, model-dependent):
    The negation of a bracket formula on `(z_0, z_1)` produces a `VBracketFormula`
    that holds on `(z_0, z_1)`, on any structure with `HasAttainedINF`. -/
theorem neg_interval_formula {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap) :
    ∀ (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    z0 < z1 →
    ¬bf.holds M atomMap z0 z1 →
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    intro bf z0 z1 h_lt h_neg
    -- bf.holds = ∀ y ∈ (z0, z1), segmentTypes(0)(y)
    -- Negation: ∃ y ∈ (z0, z1), ¬segmentTypes(0)(y)
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
               IntervalPattern.holds] at h_neg
    push Not at h_neg
    obtain ⟨y, hy0, hy1, h_neg_y⟩ := h_neg
    -- y witnesses purePoint (segmentTypes(0).neg)
    let neg_bf : BracketFormula 1 :=
      { pointTypes := fun _ => (bf.segmentTypes ⟨0, by omega⟩).neg
        segmentTypes := fun _ => TemporalPred.top }
    refine ⟨⟨[⟨1, neg_bf⟩]⟩, ⟨1, neg_bf⟩, List.mem_singleton.mpr rfl, ?_⟩
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
    refine ⟨fun _ => y, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab; exact absurd hab (by omega)
    · intro _; exact ⟨hy0, hy1⟩
    · intro _; exact (TemporalPred.eval_at_neg' M atomMap
        (bf.segmentTypes ⟨0, by omega⟩) y).mpr h_neg_y
    · intro y' _ _; exact TemporalPred.eval_at_top M atomMap y'
    · intro ⟨j, hj⟩; exact absurd hj (by omega)
    · intro y' _ _; exact TemporalPred.eval_at_top M atomMap y'
  | succ n ih =>
    intro bf z0 z1 h_lt h_neg
    -- Case split: does pointTypes(0) occur in (z0, z1)?
    by_cases h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
        (bf.pointTypes ⟨0, by omega⟩).EvalAt M atomMap x
    · -- Case B: pointTypes(0) occurs in (z0, z1)
      obtain ⟨r0, hr0_above, hr0_below, hPr0, h_neg_before⟩ :=
        h_INF.first_occ_tp (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
      -- Check whether segmentTypes(0) holds on (z0, r0)
      by_cases h_seg : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, by omega⟩).EvalAt M atomMap y
      · -- Case B1: segmentTypes(0) holds on (z0, r0)
        -- The tail bracket formula must fail on (r0, z1)
        have h_tail_neg : ¬bf.tail.holds M atomMap r0 z1 := by
          intro h_tail
          exact h_neg (bracket_tail_satisfiable M atomMap bf z0 z1 r0
            hr0_above hr0_below hPr0 h_seg h_tail)
        -- By IH, negation of tail gives V-bracket on (r0, z1)
        obtain ⟨v, hv⟩ := ih bf.tail r0 z1 hr0_below h_tail_neg
        -- Prepend r0 with pointTypes(0).neg on (z0, r0)
        obtain ⟨⟨k, bf_v⟩, h_mem, h_holds⟩ := hv
        have h_holds' := BracketFormula.prepend_holds M atomMap bf_v
          (bf.pointTypes ⟨0, by omega⟩).neg (bf.pointTypes ⟨0, by omega⟩) z0 z1 r0
          hr0_above hr0_below hPr0
          (fun y hy0 hy1 => (TemporalPred.eval_at_neg' M atomMap
            (bf.pointTypes ⟨0, by omega⟩) y).mpr (h_neg_before y hy0 hy1))
          h_holds
        exact ⟨⟨[⟨k + 1, bf_v.prepend (bf.pointTypes ⟨0, by omega⟩).neg
          (bf.pointTypes ⟨0, by omega⟩)⟩]⟩,
          ⟨k + 1, bf_v.prepend (bf.pointTypes ⟨0, by omega⟩).neg
            (bf.pointTypes ⟨0, by omega⟩)⟩,
          List.mem_singleton.mpr rfl, h_holds'⟩
      · -- Case B2: segmentTypes(0) fails on (z0, r0)
        -- INF configuration is V-bracket
        exact inf_formula_is_vbracket h_INF
          (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
    · -- Case A: pointTypes(0) does not occur in (z0, z1)
      push Not at h_exists
      exact ⟨⟨[⟨0, BracketFormula.trivial (bf.pointTypes ⟨0, by omega⟩).neg⟩]⟩,
             ⟨0, BracketFormula.trivial (bf.pointTypes ⟨0, by omega⟩).neg⟩,
             List.mem_singleton.mpr rfl,
             (BracketFormula.trivial_holds M atomMap
               (bf.pointTypes ⟨0, by omega⟩).neg z0 z1).mpr
               (fun y hy0 hy1 => (TemporalPred.eval_at_neg' M atomMap
                 (bf.pointTypes ⟨0, by omega⟩) y).mpr (h_exists y hy0 hy1))⟩

/-! ## Corollary 5.4: neg_bounded_exists (forward, model-dependent)

The negation of "∃ z ∈ (z_0, z_1), bf.holds z_0 z" produces a VBracketFormula
on structures with HasAttainedINF.

For the n=0 base case, we use HasAttainedINF.first_occ with the neg of seg_0:
if ¬seg_0 occurs in (z0, z1), then the first ¬seg_0 point gives us a z where
seg_0 holds on (z0, z), making the bounded existential satisfiable (contradiction).
If ¬seg_0 does NOT occur, seg_0 holds everywhere so any z works (contradiction).
The only escape: (z0, z1) is empty -- then a trivial V-bracket holds vacuously. -/

/-- **Corollary 5.4** (Rabinovich 2014, forward direction, model-dependent):
    The negation of a bounded existential produces a VBracketFormula on any
    structure with `HasAttainedINF`. -/
theorem neg_bounded_exists {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap) :
    ∀ (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    z0 < z1 →
    ¬(∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z) →
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    intro bf z0 z1 h_lt h_neg
    -- For BracketFormula 0, bf.holds z0 z = ∀ y ∈ (z0, z), seg_0(y)
    -- The bounded existential: ∃ z ∈ (z0, z1), ∀ y ∈ (z0, z), seg_0(y)
    -- On HasAttainedINF: if (z0, z1) is non-empty, this always holds:
    --   If seg_0 fails somewhere in (z0, z1): use first failure as z
    --   If seg_0 holds everywhere: use any z in (z0, z1)
    -- So ¬bounded_exists means (z0, z1) must be "empty" for the purpose of
    -- finding an intermediate point that the bracket uses.
    -- Actually: ∃ z ∈ (z0, z1), (∀ y ∈ (z0, z), seg_0(y))
    -- This holds whenever ∃ z ∈ (z0, z1) with (z0, z) satisfying seg_0.
    -- By HasAttainedINF applied to seg_0.neg:
    --   If seg_0.neg occurs in (z0, z1): first occ r gives seg_0 on (z0, r),
    --     and r ∈ (z0, z1), so bf.holds z0 r -- contradiction.
    --   If seg_0.neg does NOT occur: seg_0 holds everywhere in (z0, z1).
    --     Need ANY z ∈ (z0, z1) to make bf.holds z0 z.
    -- Either way, if (z0, z1) has a point, the bounded existential holds.
    -- Escape: (z0, z1) has no point -- but that contradicts h_lt on dense structures.
    -- For discrete structures: (z0, z1) can be empty even with z0 < z1!
    -- In that case, trivial V-bracket holds vacuously.
    by_cases h_nonempty : ∃ z : M.carrier, z0 < z ∧ z < z1
    · -- (z0, z1) is non-empty: show contradiction with h_neg
      exfalso
      obtain ⟨z', hz0', hz1'⟩ := h_nonempty
      apply h_neg
      by_cases h_seg_fail : ∃ y : M.carrier, z0 < y ∧ y < z1 ∧
          ¬(bf.segmentTypes ⟨0, by omega⟩).EvalAt M atomMap y
      · -- seg_0 fails somewhere: find first failure
        obtain ⟨r, hr_above, hr_below, hPr, h_no_before⟩ :=
          h_INF.first_occ_tp (bf.segmentTypes ⟨0, by omega⟩).neg z0 z1 h_lt (by
            obtain ⟨y, hy1, hy2, hy3⟩ := h_seg_fail
            exact ⟨y, hy1, hy2, (TemporalPred.eval_at_neg' M atomMap
              (bf.segmentTypes ⟨0, by omega⟩) y).mpr hy3⟩)
        -- seg_0 holds on (z0, r) since r is first ¬seg_0 point
        refine ⟨r, hr_above, hr_below, ?_⟩
        simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
        intro y hy0 hy1
        by_contra h_neg_y
        exact h_no_before y hy0 hy1
          ((TemporalPred.eval_at_neg' M atomMap
            (bf.segmentTypes ⟨0, by omega⟩) y).mpr h_neg_y)
      · -- seg_0 holds everywhere in (z0, z1)
        push Not at h_seg_fail
        exact ⟨z', hz0', hz1', by
          simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
          intro y hy0 hy1
          exact h_seg_fail y hy0 (lt_trans hy1 hz1')⟩
    · -- (z0, z1) is empty: trivial V-bracket holds vacuously
      push Not at h_nonempty
      exact ⟨⟨[⟨0, BracketFormula.trivial TemporalPred.top⟩]⟩,
             ⟨0, BracketFormula.trivial TemporalPred.top⟩,
             List.mem_singleton.mpr rfl,
             (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
               (fun y hy0 hy1 => absurd hy1 (not_lt.mpr (h_nonempty y hy0)))⟩
  | succ n ih =>
    intro bf z0 z1 h_lt h_neg
    -- Case split: does pointTypes(0) occur in (z0, z1)?
    by_cases h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
        (bf.pointTypes ⟨0, by omega⟩).EvalAt M atomMap x
    · -- Case B: pointTypes(0) occurs in (z0, z1)
      obtain ⟨r0, hr0_above, hr0_below, hPr0, h_neg_before⟩ :=
        h_INF.first_occ_tp (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
      -- Check whether segmentTypes(0) holds on (z0, r0)
      by_cases h_seg : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, by omega⟩).EvalAt M atomMap y
      · -- Case B1: segmentTypes(0) holds on (z0, r0)
        -- The tail bounded existential must fail on (r0, z1)
        have h_tail_neg : ¬∃ z : M.carrier, r0 < z ∧ z < z1 ∧
            bf.tail.holds M atomMap r0 z := by
          intro ⟨z, hz_above, hz_below, h_tail⟩
          apply h_neg
          exact ⟨z, lt_trans hr0_above hz_above, hz_below,
                 bracket_tail_satisfiable M atomMap bf z0 z r0
                   hr0_above hz_above hPr0 h_seg h_tail⟩
        -- By IH, negation of tail bounded existential gives V-bracket on (r0, z1)
        obtain ⟨v, hv⟩ := ih bf.tail r0 z1 hr0_below h_tail_neg
        -- Prepend r0 with pointTypes(0).neg on (z0, r0)
        obtain ⟨⟨k, bf_v⟩, h_mem, h_holds⟩ := hv
        have h_holds' := BracketFormula.prepend_holds M atomMap bf_v
          (bf.pointTypes ⟨0, by omega⟩).neg (bf.pointTypes ⟨0, by omega⟩) z0 z1 r0
          hr0_above hr0_below hPr0
          (fun y hy0 hy1 => (TemporalPred.eval_at_neg' M atomMap
            (bf.pointTypes ⟨0, by omega⟩) y).mpr (h_neg_before y hy0 hy1))
          h_holds
        exact ⟨⟨[⟨k + 1, bf_v.prepend (bf.pointTypes ⟨0, by omega⟩).neg
          (bf.pointTypes ⟨0, by omega⟩)⟩]⟩,
          ⟨k + 1, bf_v.prepend (bf.pointTypes ⟨0, by omega⟩).neg
            (bf.pointTypes ⟨0, by omega⟩)⟩,
          List.mem_singleton.mpr rfl, h_holds'⟩
      · -- Case B2: segmentTypes(0) fails on (z0, r0)
        -- INF configuration is V-bracket
        exact inf_formula_is_vbracket h_INF
          (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
    · -- Case A: pointTypes(0) does not occur in (z0, z1)
      push Not at h_exists
      exact ⟨⟨[⟨0, BracketFormula.trivial (bf.pointTypes ⟨0, by omega⟩).neg⟩]⟩,
             ⟨0, BracketFormula.trivial (bf.pointTypes ⟨0, by omega⟩).neg⟩,
             List.mem_singleton.mpr rfl,
             (BracketFormula.trivial_holds M atomMap
               (bf.pointTypes ⟨0, by omega⟩).neg z0 z1).mpr
               (fun y hy0 hy1 => (TemporalPred.eval_at_neg' M atomMap
                 (bf.pointTypes ⟨0, by omega⟩) y).mpr (h_exists y hy0 hy1))⟩

/-! ## Proposition 4.2: VecEA2 Negation Closure

The negation of a VecEA2 formula (and VVecEA2 formula) produces a VVecEA2 formula
on structures with HasAttainedINF. This is Rabinovich 2014, Proposition 4.2.

### Three-Case Decomposition

A VecEA2 formula has the form: endpointLeft(z_0) AND endpointRight(z_1) AND bracket(z_0, z_1)
Its negation decomposes via de Morgan:
- Case 1a: not endpointLeft(z_0) — trivial VVecEA2
- Case 1b: not endpointRight(z_1) — trivial VVecEA2
- Case 2+3: both endpoints hold, bracket fails — apply neg_interval_formula

### References
- Rabinovich 2014, Proposition 4.2 (p. 6)
-/

/-- Wrap each bracket formula in a VBracketFormula with endpoint predicates to
    form a VVecEA2. -/
def VBracketFormula.toVVecEA2WithEndpoints
    (v : VBracketFormula) (epL epR : TemporalPred) : VVecEA2 :=
  { disjuncts := v.disjuncts.map fun ⟨n, bf⟩ =>
      ⟨n, { endpointLeft := epL, endpointRight := epR, bracket := bf }⟩ }

/-- Semantics of toVVecEA2WithEndpoints: holds iff some bracket disjunct holds
    and both endpoint predicates hold. -/
theorem VBracketFormula.toVVecEA2WithEndpoints_holds
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VBracketFormula) (epL epR : TemporalPred)
    (z0 z1 : M.carrier)
    (hL : epL.EvalAt M atomMap z0)
    (hR : epR.EvalAt M atomMap z1)
    (hv : v.holds M atomMap z0 z1) :
    (v.toVVecEA2WithEndpoints epL epR).holds M atomMap z0 z1 := by
  obtain ⟨⟨n, bf⟩, hmem, hbf⟩ := hv
  refine ⟨⟨n, { endpointLeft := epL, endpointRight := epR, bracket := bf }⟩, ?_, hL, hR, hbf⟩
  simp only [toVVecEA2WithEndpoints]
  exact List.mem_map.mpr ⟨⟨n, bf⟩, hmem, rfl⟩

/-- **Proposition 4.2 (single conjunct)**: The negation of a `VecEA2` formula
    produces a `VVecEA2` formula on structures with `HasAttainedINF`. -/
theorem neg_vecEA2 {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (n : Nat) (vea : VecEA2 n) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_neg : ¬vea.holds M atomMap z0 z1) :
    ∃ v : VVecEA2, v.holds M atomMap z0 z1 := by
  simp only [VecEA2.holds] at h_neg
  push Not at h_neg
  -- Three cases via de Morgan
  by_cases hL : vea.endpointLeft.EvalAt M atomMap z0
  · by_cases hR : vea.endpointRight.EvalAt M atomMap z1
    · -- Case 2+3: both endpoints hold, bracket fails
      have h_neg_bracket : ¬vea.bracket.holds M atomMap z0 z1 := h_neg hL hR
      -- Apply Lemma 5.1 to get V-bracket
      obtain ⟨vbf, hvbf⟩ := neg_interval_formula h_INF n vea.bracket z0 z1 h_lt h_neg_bracket
      -- Wrap with original endpoints
      exact ⟨vbf.toVVecEA2WithEndpoints vea.endpointLeft vea.endpointRight,
             vbf.toVVecEA2WithEndpoints_holds M atomMap
               vea.endpointLeft vea.endpointRight z0 z1 hL hR hvbf⟩
    · -- Case 1b: endpointRight fails
      refine ⟨⟨[⟨0, { endpointLeft := TemporalPred.top,
                       endpointRight := vea.endpointRight.neg,
                       bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩,
              ⟨0, _⟩, List.mem_singleton.mpr rfl,
              TemporalPred.eval_at_top M atomMap z0,
              (TemporalPred.eval_at_neg' M atomMap vea.endpointRight z1).mpr hR,
              ?_⟩
      exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
        (fun y _ _ => TemporalPred.eval_at_top M atomMap y)
  · -- Case 1a: endpointLeft fails
    refine ⟨⟨[⟨0, { endpointLeft := vea.endpointLeft.neg,
                     endpointRight := TemporalPred.top,
                     bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩,
            ⟨0, _⟩, List.mem_singleton.mpr rfl,
            (TemporalPred.eval_at_neg' M atomMap vea.endpointLeft z0).mpr hL,
            TemporalPred.eval_at_top M atomMap z1,
            ?_⟩
    exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y)

/-- Helper: the negation of all disjuncts in a list produces a VVecEA2. -/
private theorem neg_disjunct_list {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (ds : List (Σ n, VecEA2 n))
    (h_neg : ∀ d ∈ ds, ¬d.2.holds M atomMap z0 z1) :
    ∃ v : VVecEA2, v.holds M atomMap z0 z1 := by
  induction ds with
  | nil =>
    -- Empty list: produce a trivially-true VVecEA2
    refine ⟨⟨[⟨0, { endpointLeft := TemporalPred.top,
                     endpointRight := TemporalPred.top,
                     bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩,
            ⟨0, _⟩, List.mem_singleton.mpr rfl,
            TemporalPred.eval_at_top M atomMap z0,
            TemporalPred.eval_at_top M atomMap z1,
            ?_⟩
    exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y)
  | cons d ds ih =>
    have h_neg_d : ¬d.2.holds M atomMap z0 z1 :=
      h_neg d (List.mem_cons_self ..)
    obtain ⟨v_d, hv_d⟩ := neg_vecEA2 h_INF d.1 d.2 z0 z1 h_lt h_neg_d
    have h_neg_rest : ∀ d' ∈ ds, ¬d'.2.holds M atomMap z0 z1 :=
      fun d' hm => h_neg d' (List.mem_cons_of_mem d hm)
    obtain ⟨v_rest, hv_rest⟩ := ih h_neg_rest
    exact VVecEA2.conj_holds_vvecEA2 M atomMap v_d v_rest z0 z1 h_lt hv_d hv_rest

/-- **WARNING — THIS THEOREM'S CONCLUSION IS VACUOUS. IT IS NOT RABINOVICH'S PROP 4.2.**
    Machine refutation:
    `Prop42Vacuity.prop42_conclusion_is_vacuous` (`Kamp/Prop42Vacuity.lean`), which derives the
    conclusion below from **no hypotheses at all**. Read that file before relying on this one.

    The conclusion `∃ v', v'.holds M atomMap z0 z1` asserts **no relation** between `v'` and the
    negated input `v` — `v` does not occur in it. It says only "some `VVecEA2` holds at
    `(z0, z1)`", which is true unconditionally (witness: the all-`⊤` block). `h_INF`, `v`,
    `h_lt`, and `h_neg` are therefore inert: none of them is needed to derive the conclusion,
    so this theorem establishes nothing about negation.

    This theorem is sorry-free, axiom-clean (`[propext, Classical.choice, Quot.sound]`), and
    builds green. **All of that is true and none of it is evidence of content** — a vacuous
    statement is perfectly provable, which is why no build check catches this. Do not cite its
    green status to rebut the paragraph above.

    Rabinovich's actual Proposition 4.2 (Rabinovich 2014, *Proof of Kamp's Theorem*, **PDF
    p.6** — the companion `.md` is corrupt; never cite it) requires the witness to be tied to
    the input, `∃ v', ∀ z0 z1, z0 < z1 → (v'.holds … ↔ ¬v.holds …)` with `v'` a function of `v`
    alone. Compare `neg_2var_vec_ea_indep` (`Boneyard/NegationIndep.lean:315`), which has that
    shape structurally and whose forward direction is contentful and proved.

    **Retained deliberately, not endorsed.** It is consumed live (`neg_disjunct_list` above;
    re-exported by `NfMultiAnchorBridge/NavigatedSpine.lean:178`), so removing it is out of
    scope here — but it must not be presented or consumed as a discharged Prop 4.2.

    Previously recorded, independently, and not acted on: `Prop43.lean:120-129` (names this
    same vacuity explicitly) and `Boneyard/NegationIndep.lean:357-364` (adopts this theorem as
    a "PRE-AUTHORIZED model-DEPENDENT interim" on the grounds that it adds no sorry or axiom —
    the precise inference the guard refutes). -/
theorem neg_2var_vec_ea {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_neg : ¬v.holds M atomMap z0 z1) :
    ∃ v' : VVecEA2, v'.holds M atomMap z0 z1 := by
  simp only [VVecEA2.holds] at h_neg
  push Not at h_neg
  exact neg_disjunct_list h_INF z0 z1 h_lt v.disjuncts h_neg

/-- **List.permutations head-coverage**. Every element of a list heads some
    permutation of that list, in the CONS shape `χ :: rest`: given `χ ∈ l`, there exists `rest`
    with `(χ :: rest) ∈ l.permutations`.

    This is the pure combinatorial helper consumed by Phase 4.2 (`hbelow` assembly in
    `NfMultiAnchorBridge.lean`). The k=2 sub-witness disjunction ranges over
    `S_XU.permutations.flatMap …` (`NfMultiAnchorBridge.lean` `:6943-6945`, `:6985`); to select
    the arrangement whose `lXU` region STARTS with a chosen `zXU`-positive type `χ`, Phase 4.2
    instantiates `l := S_XU`, `χ := ⟨charBase χ⟩` and reads off `lXU := χ :: rest`. The membership
    `(χ :: rest) ∈ S_XU.permutations` is exactly the flatMap key (via `List.mem_permutations`),
    and the CONS head `χ` feeds Phase 3's `bracketFromLists3_fChainPred_head_extract`, whose input
    bracket has the non-empty `zXU` region `χ0 :: lXU'` (`NfMultiAnchorBridge.lean` `:6794`).

    Proof: `List.append_of_mem` splits `l = s ++ χ :: t`; `List.perm_middle` gives
    `(s ++ χ :: t) ~ (χ :: (s ++ t))`, whose symmetric form witnesses membership via
    `List.mem_permutations`. No `DecidableEq` is required (append-split, not `erase`).

    Rabinovich 2014 **Lemma 5.3** (md:137-152) permutation-coverage support (citation optional —
    this is a domain-free `List` fact). -/
theorem exists_permutation_cons_head {α : Type*} {l : List α} {χ : α} (hχ : χ ∈ l) :
    ∃ rest : List α, (χ :: rest) ∈ l.permutations := by
  obtain ⟨s, t, rfl⟩ := List.append_of_mem hχ
  exact ⟨s ++ t, List.mem_permutations.mpr List.perm_middle.symm⟩

/-- **List.permutations head-coverage** (`head?` form). Every element of a list heads
    (`head? = some χ`) some permutation of that list.
    A direct corollary of `exists_permutation_cons_head` — Phase 4.2 may consume either the CONS
    form (to destructure the arrangement as `χ :: rest`) or this `head?` form. -/
theorem exists_permutation_head?_eq {α : Type*} {l : List α} {χ : α} (hχ : χ ∈ l) :
    ∃ p ∈ l.permutations, p.head? = some χ := by
  obtain ⟨rest, hrest⟩ := exists_permutation_cons_head hχ
  exact ⟨χ :: rest, hrest, rfl⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
