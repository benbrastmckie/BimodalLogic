/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
# Full Conjunction Closure for Bracket / VecEA2 Formulas (Phase 7)

Rabinovich 2014, Lemma 3.2(1) and Lemma 3.4, in full **iff** form and
order-generic (no model hypotheses): the conjunction of two bracket formulas
is *equivalent* to a disjunction of bracket formulas, and V-vec-EA-2 formulas
are closed under conjunction with an exact semantic characterization.

This strengthens the forward-only `BracketFormula.conjStruct` /
`VVecEA2.conj_struct` (VecEAClosure.lean) to a two-directional
equivalence, which the fixed-formula negation stack (Lemma 5.1 / Cor 5.4,
Phases 8-11) and the `aggPop1` conjunction fold (Phase 16) require.

## Contents

1. `TemporalPred.eval_at_glue` — segment gluing across an interior point.
2. `witness_position_trichotomy` — every point is a witness, lies before the
   first witness, after the last, or strictly between two consecutive ones.
3. `BracketFormula.front` + `BracketFormula.holds_succ_iff` — last-witness
   decomposition of `holds` (the Lemma 3.2(1) recursion engine), built on the
   delivered `leftPart_holds` / `splitAt_combine` splitting kit.
4. `BracketFormula.snoc` + `snoc_holds_iff` — append a last witness; exact
   decomposition (the report-recommended "Probe 1").
5. `VBracketFormula.snocAll` + `snocAll_holds_iff` — disjunct-wise snoc.
6. `BracketFormula.conjEverywhere` + iff — conjoin a 0-bracket's segment type
   into ALL point types and ALL segment types (exactly where the iff-form
   diverges from the forward-only `conjStruct`, which conjoins only into
   segment types).
7. `BracketFormula.conjFull` + `conjFull_iff` — the Lemma 3.2(1) recursion on
   the last-witness trichotomy (coincide / bf1-last greater / bf2-last
   greater); merged points take the conjoined point type PLUS the other
   bracket's ambient segment type.
8. `VVecEA2.conjFull` + `conjFull_iff` — the Lemma 3.4 lift: Cartesian product
   of disjunct lists, endpoint conjunction via `TemporalPred.eval_at_conj`,
   per-pair bracket lists flattened.
9. `VVecEA2.trivialTrue` — neutral element for the Phase-16 conjunction fold.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 3.2(1) (pp. 3-4),
  Lemma 3.4 (p. 4).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Segment gluing -/

/-- Segment gluing: if `s` holds on `(a, x)`, at `x`, and on `(x, b)`, then it
    holds on `(a, b)`. Trichotomy on `y` vs `x`. -/
theorem TemporalPred.eval_at_glue {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s : TemporalPred) (a x b : M.carrier)
    (h1 : ∀ y, a < y → y < x → s.eval_at M atomMap y)
    (hx : s.eval_at M atomMap x)
    (h2 : ∀ y, x < y → y < b → s.eval_at M atomMap y) :
    ∀ y, a < y → y < b → s.eval_at M atomMap y := by
  intro y hay hyb
  rcases lt_trichotomy y x with h | h | h
  · exact h1 y hay h
  · exact h ▸ hx
  · exact h2 y h hyb

/-! ## Witness position trichotomy -/

/-- Every point `y` either coincides with a witness, lies strictly before the
    first witness, strictly after the last witness, or strictly between two
    consecutive witnesses. (No monotonicity of `w` is needed: the statement is
    proved by scanning from the last witness down.) -/
theorem witness_position_trichotomy {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {n : Nat}
    (w : Fin (n + 1) → M.carrier) (y : M.carrier) :
    (∃ i, y = w i) ∨
    y < w ⟨0, by omega⟩ ∨
    w ⟨n, by omega⟩ < y ∨
    (∃ i : Fin n, w ⟨i.val, by omega⟩ < y ∧ y < w ⟨i.val + 1, by omega⟩) := by
  induction n with
  | zero =>
    rcases lt_trichotomy y (w ⟨0, by omega⟩) with h | h | h
    · exact Or.inr (Or.inl h)
    · exact Or.inl ⟨⟨0, by omega⟩, h⟩
    · exact Or.inr (Or.inr (Or.inl h))
  | succ k ih =>
    rcases lt_trichotomy y (w ⟨k + 1, by omega⟩) with hlt | heq | hgt
    · rcases ih (fun i => w ⟨i.val, by omega⟩) with ⟨i, hi⟩ | h0 | hk | ⟨i, h1, h2⟩
      · exact Or.inl ⟨⟨i.val, by omega⟩, hi⟩
      · exact Or.inr (Or.inl h0)
      · exact Or.inr (Or.inr (Or.inr ⟨⟨k, by omega⟩, hk, hlt⟩))
      · exact Or.inr (Or.inr (Or.inr ⟨⟨i.val, by omega⟩, h1, h2⟩))
    · exact Or.inl ⟨⟨k + 1, by omega⟩, heq⟩
    · exact Or.inr (Or.inr (Or.inl hgt))

/-! ## Last-witness decomposition (`front` / `holds_succ_iff`) -/

/-- The initial part of a bracket formula with `n + 1` witnesses: drop the
    last witness (point type) and the last segment type. Definitionally the
    `leftPart` at the last index. -/
def BracketFormula.front {n : Nat} (bf : BracketFormula (n + 1)) :
    BracketFormula n :=
  { pointTypes := fun j => bf.pointTypes ⟨j.val, by omega⟩
    segmentTypes := fun j => bf.segmentTypes ⟨j.val, by omega⟩ }

/-- `front` coincides with `leftPart` at the last index. -/
theorem BracketFormula.front_eq_leftPart {n : Nat} (bf : BracketFormula (n + 1)) :
    bf.front = bf.leftPart ⟨n, Nat.lt_succ_self n⟩ :=
  rfl

/-- Last-witness decomposition of `holds` (the Lemma 3.2(1) recursion engine):
    a bracket formula with `n + 1` witnesses holds on `(z0, z1)` iff there is
    a last witness `x` such that the front holds on `(z0, x)`, the last point
    type holds at `x`, and the last segment type holds on `(x, z1)`. -/
theorem BracketFormula.holds_succ_iff {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (z0 z1 : M.carrier) :
    bf.holds M atomMap z0 z1 ↔
    ∃ x, z0 < x ∧ x < z1 ∧ bf.front.holds M atomMap z0 x ∧
      (bf.pointTypes ⟨n, by omega⟩).eval_at M atomMap x ∧
      ∀ y, x < y → y < z1 →
        (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap y := by
  constructor
  · intro h
    simp only [holds, toIntervalPattern, IntervalPattern.holds] at h
    obtain ⟨w, hm, hr, hp, hs0, hsm, hsl⟩ := h
    refine ⟨w ⟨n, by omega⟩, (hr ⟨n, by omega⟩).1, (hr ⟨n, by omega⟩).2, ?_,
      hp ⟨n, by omega⟩, hsl⟩
    rw [front_eq_leftPart]
    exact leftPart_holds M atomMap bf z0 z1 ⟨n, Nat.lt_succ_self n⟩ w
      hm hr hp hs0 hsm hsl
  · rintro ⟨x, hz0x, hxz1, hfront, hpt, hseg⟩
    refine splitAt_combine M atomMap bf z0 z1 x ⟨n, Nat.lt_succ_self n⟩
      hz0x hxz1 hpt ?_ ?_
    · rw [← front_eq_leftPart]; exact hfront
    · simp only [holds, toIntervalPattern, rightPart]
      rw [IntervalPattern.holds_eq_zero (h := Nat.sub_self n)]
      intro y hy_lo hy_hi
      convert hseg y hy_lo hy_hi using 3
      simp

/-! ## Snoc (append a last witness) -/

/-- Append a witness with point type `p` and a new final segment type `s` to a
    bracket formula. -/
def BracketFormula.snoc {n : Nat} (bf : BracketFormula n) (p s : TemporalPred) :
    BracketFormula (n + 1) :=
  { pointTypes := fun i => if h : i.val < n then bf.pointTypes ⟨i.val, h⟩ else p
    segmentTypes := fun i =>
      if h : i.val < n + 1 then bf.segmentTypes ⟨i.val, h⟩ else s }

/-- The front of a snocced bracket formula is the original. -/
theorem BracketFormula.snoc_front {n : Nat} (bf : BracketFormula n)
    (p s : TemporalPred) : (bf.snoc p s).front = bf := by
  cases bf with
  | mk pt st =>
    simp only [snoc, front]
    congr 1
    · funext j
      rw [dif_pos j.isLt]
    · funext j
      rw [dif_pos j.isLt]

/-- The last point type of a snocced bracket formula is `p`. -/
theorem BracketFormula.snoc_pointTypes_last {n : Nat} (bf : BracketFormula n)
    (p s : TemporalPred) : (bf.snoc p s).pointTypes ⟨n, by omega⟩ = p := by
  simp [snoc]

/-- The last segment type of a snocced bracket formula is `s`. -/
theorem BracketFormula.snoc_segmentTypes_last {n : Nat} (bf : BracketFormula n)
    (p s : TemporalPred) : (bf.snoc p s).segmentTypes ⟨n + 1, by omega⟩ = s := by
  simp [snoc]

/-- Snoc decomposition (report "Probe 1"): the snocced bracket formula holds
    on `(z0, z1)` iff there is a witness `x` with `bf` before it, `p` at it,
    and `s` after it. -/
theorem BracketFormula.snoc_holds_iff {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (p s : TemporalPred) (z0 z1 : M.carrier) :
    (bf.snoc p s).holds M atomMap z0 z1 ↔
    ∃ x, z0 < x ∧ x < z1 ∧ bf.holds M atomMap z0 x ∧
      p.eval_at M atomMap x ∧
      ∀ y, x < y → y < z1 → s.eval_at M atomMap y := by
  rw [holds_succ_iff]
  simp only [snoc_front, snoc_pointTypes_last, snoc_segmentTypes_last]

/-! ## Disjunct-wise snoc for V-bracket formulas -/

/-- Snoc every disjunct of a V-bracket formula with the same point type `p`
    and final segment type `s`. -/
def VBracketFormula.snocAll (v : VBracketFormula) (p s : TemporalPred) :
    VBracketFormula :=
  { disjuncts := v.disjuncts.map fun d => ⟨d.1 + 1, d.2.snoc p s⟩ }

/-- Semantic characterization of `snocAll`: some snocced disjunct holds iff
    there is a witness `x` with the V-bracket formula before it, `p` at it,
    and `s` after it. -/
theorem VBracketFormula.snocAll_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VBracketFormula) (p s : TemporalPred) (z0 z1 : M.carrier) :
    (v.snocAll p s).holds M atomMap z0 z1 ↔
    ∃ x, z0 < x ∧ x < z1 ∧ v.holds M atomMap z0 x ∧
      p.eval_at M atomMap x ∧
      ∀ y, x < y → y < z1 → s.eval_at M atomMap y := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [snocAll, List.mem_map] at hmem
    obtain ⟨⟨k, bf⟩, hmem', rfl⟩ := hmem
    rw [BracketFormula.snoc_holds_iff] at hh
    obtain ⟨x, h1, h2, h3, h4, h5⟩ := hh
    exact ⟨x, h1, h2, ⟨⟨k, bf⟩, hmem', h3⟩, h4, h5⟩
  · rintro ⟨x, h1, h2, ⟨⟨k, bf⟩, hmem, h3⟩, h4, h5⟩
    refine ⟨⟨k + 1, bf.snoc p s⟩, ?_, ?_⟩
    · simp only [snocAll, List.mem_map]
      exact ⟨⟨k, bf⟩, hmem, rfl⟩
    · rw [BracketFormula.snoc_holds_iff]
      exact ⟨x, h1, h2, h3, h4, h5⟩

/-! ## Conjoining a segment type everywhere (base cases of `conjFull`) -/

/-- Conjoin a segment type `s` into every point type AND every segment type of
    a bracket formula. Used for the `conjFull` base cases where one side has 0
    witnesses: its single segment type must hold at every interior point of
    `(z0, z1)` — including the other bracket's witnesses. (This is exactly
    where the iff-form diverges from the forward-only `conjStruct`, which
    conjoins only into segment types.) -/
def BracketFormula.conjEverywhere {n : Nat} (bf : BracketFormula n)
    (s : TemporalPred) : BracketFormula n :=
  { pointTypes := fun i => (bf.pointTypes i).conj s
    segmentTypes := fun i => (bf.segmentTypes i).conj s }

/-- Semantic characterization of `conjEverywhere`: it holds iff the original
    bracket formula holds and `s` holds everywhere in the open interval.
    The forward direction uses the witness position trichotomy. -/
theorem BracketFormula.conjEverywhere_holds_iff {sig : MonadicSignature}
    {n : Nat} (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (s : TemporalPred) (z0 z1 : M.carrier) :
    (bf.conjEverywhere s).holds M atomMap z0 z1 ↔
    bf.holds M atomMap z0 z1 ∧
      ∀ y, z0 < y → y < z1 → s.eval_at M atomMap y := by
  match n, bf with
  | 0, bf =>
    simp only [holds, toIntervalPattern, IntervalPattern.holds, conjEverywhere]
    constructor
    · intro h
      refine ⟨fun y hy0 hy1 => ?_, fun y hy0 hy1 => ?_⟩
      · exact ((TemporalPred.eval_at_conj M atomMap _ _ y).mp (h y hy0 hy1)).1
      · exact ((TemporalPred.eval_at_conj M atomMap _ _ y).mp (h y hy0 hy1)).2
    · intro h y hy0 hy1
      exact (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨h.1 y hy0 hy1, h.2 y hy0 hy1⟩
  | m + 1, bf =>
    simp only [holds, toIntervalPattern, IntervalPattern.holds, conjEverywhere]
    constructor
    · rintro ⟨w, hm, hr, hp, hs0, hsm, hsl⟩
      have hs_all : ∀ y, z0 < y → y < z1 → s.eval_at M atomMap y := by
        intro y hy0 hy1
        rcases witness_position_trichotomy M w y with
          ⟨i, rfl⟩ | h0 | hlast | ⟨i, h1, h2⟩
        · exact ((TemporalPred.eval_at_conj M atomMap _ _ _).mp (hp i)).2
        · exact ((TemporalPred.eval_at_conj M atomMap _ _ y).mp
            (hs0 y hy0 h0)).2
        · exact ((TemporalPred.eval_at_conj M atomMap _ _ y).mp
            (hsl y hlast hy1)).2
        · exact ((TemporalPred.eval_at_conj M atomMap _ _ y).mp
            (hsm i y h1 h2)).2
      refine ⟨⟨w, hm, hr, ?_, ?_, ?_, ?_⟩, hs_all⟩
      · intro i
        exact ((TemporalPred.eval_at_conj M atomMap _ _ _).mp (hp i)).1
      · intro y hy0 hy1
        exact ((TemporalPred.eval_at_conj M atomMap _ _ y).mp
          (hs0 y hy0 hy1)).1
      · intro i y h1 h2
        exact ((TemporalPred.eval_at_conj M atomMap _ _ y).mp
          (hsm i y h1 h2)).1
      · intro y h1 h2
        exact ((TemporalPred.eval_at_conj M atomMap _ _ y).mp
          (hsl y h1 h2)).1
    · rintro ⟨⟨w, hm, hr, hp, hs0, hsm, hsl⟩, hs⟩
      refine ⟨w, hm, hr, ?_, ?_, ?_, ?_⟩
      · intro i
        exact (TemporalPred.eval_at_conj M atomMap _ _ _).mpr
          ⟨hp i, hs _ (hr i).1 (hr i).2⟩
      · intro y hy0 hy1
        exact (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
          ⟨hs0 y hy0 hy1, hs y hy0 (lt_trans hy1 (hr ⟨0, by omega⟩).2)⟩
      · intro i y h1 h2
        exact (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
          ⟨hsm i y h1 h2,
           hs y (lt_trans (hr ⟨i.val, by omega⟩).1 h1)
             (lt_trans h2 (hr ⟨i.val + 1, by omega⟩).2)⟩
      · intro y h1 h2
        exact (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
          ⟨hsl y h1 h2, hs y (lt_trans (hr ⟨m, by omega⟩).1 h1) h2⟩

/-! ## Singleton V-bracket helper -/

/-- A singleton V-bracket formula holds iff its unique disjunct holds. -/
theorem VBracketFormula.singleton_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (d : Σ n, BracketFormula n) (z0 z1 : M.carrier) :
    (VBracketFormula.mk [d]).holds M atomMap z0 z1 ↔
    d.2.holds M atomMap z0 z1 := by
  simp only [holds, List.mem_singleton]
  constructor
  · rintro ⟨d', rfl, h⟩
    exact h
  · intro h
    exact ⟨d, rfl, h⟩

/-! ## Full conjunction of bracket formulas (Lemma 3.2(1)) -/

/-- Full conjunction of two bracket formulas (Rabinovich Lemma 3.2(1)): a
    V-bracket formula *equivalent* to the conjunction. Recursion on the last
    witnesses with 3-way trichotomy:
    - **coincide**: merged point takes the conjoined point type
      `p1.conj p2`, final segment `s1.conj s2`, recurse on both fronts;
    - **bf1-last greater**: merged point takes `p1.conj s2` — the other
      bracket's ambient segment type on the merged point, THE Lemma 3.2(1)
      ingredient — final segment `s1.conj s2`, recurse `conjFull bf1.front
      bf2` on `(z0, x)`;
    - **bf2-last greater**: mirror.
    Base cases (one side has 0 witnesses): conjoin the 0-bracket's segment
    type into ALL point types and ALL segment types via `conjEverywhere`. -/
def BracketFormula.conjFull : {n1 n2 : Nat} → BracketFormula n1 →
    BracketFormula n2 → VBracketFormula
  | 0, n2, bf1, bf2 =>
    ⟨[⟨n2, bf2.conjEverywhere (bf1.segmentTypes ⟨0, by omega⟩)⟩]⟩
  | _ + 1, 0, bf1, bf2 =>
    ⟨[⟨_ + 1, bf1.conjEverywhere (bf2.segmentTypes ⟨0, by omega⟩)⟩]⟩
  | n1 + 1, n2 + 1, bf1, bf2 =>
    ((bf1.front.conjFull bf2.front).snocAll
        ((bf1.pointTypes ⟨n1, by omega⟩).conj (bf2.pointTypes ⟨n2, by omega⟩))
        ((bf1.segmentTypes ⟨n1 + 1, by omega⟩).conj
          (bf2.segmentTypes ⟨n2 + 1, by omega⟩))).disj
      (((bf1.front.conjFull bf2).snocAll
          ((bf1.pointTypes ⟨n1, by omega⟩).conj
            (bf2.segmentTypes ⟨n2 + 1, by omega⟩))
          ((bf1.segmentTypes ⟨n1 + 1, by omega⟩).conj
            (bf2.segmentTypes ⟨n2 + 1, by omega⟩))).disj
        ((bf1.conjFull bf2.front).snocAll
          ((bf1.segmentTypes ⟨n1 + 1, by omega⟩).conj
            (bf2.pointTypes ⟨n2, by omega⟩))
          ((bf1.segmentTypes ⟨n1 + 1, by omega⟩).conj
            (bf2.segmentTypes ⟨n2 + 1, by omega⟩))))
  termination_by n1 n2 _ _ => n1 + n2
  decreasing_by all_goals omega

/-- Full semantic correctness of `conjFull` (Rabinovich Lemma 3.2(1), iff
    form, order-generic): the conjunction of two bracket formulas holds iff
    their full conjunction holds. -/
theorem BracketFormula.conjFull_iff {sig : MonadicSignature} {n1 n2 : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf1 : BracketFormula n1) (bf2 : BracketFormula n2) (z0 z1 : M.carrier) :
    (bf1.conjFull bf2).holds M atomMap z0 z1 ↔
    bf1.holds M atomMap z0 z1 ∧ bf2.holds M atomMap z0 z1 := by
  match n1, n2, bf1, bf2 with
  | 0, n2, bf1, bf2 =>
    rw [show bf1.conjFull bf2 =
        ⟨[⟨n2, bf2.conjEverywhere (bf1.segmentTypes ⟨0, by omega⟩)⟩]⟩ from by
      simp [conjFull]]
    rw [VBracketFormula.singleton_holds, conjEverywhere_holds_iff]
    have hbf1 : bf1.holds M atomMap z0 z1 ↔
        ∀ y, z0 < y → y < z1 →
          (bf1.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y := by
      simp only [holds, toIntervalPattern, IntervalPattern.holds]
    rw [hbf1]
    tauto
  | m1 + 1, 0, bf1, bf2 =>
    rw [show bf1.conjFull bf2 =
        ⟨[⟨m1 + 1, bf1.conjEverywhere (bf2.segmentTypes ⟨0, by omega⟩)⟩]⟩ from by
      simp [conjFull]]
    rw [VBracketFormula.singleton_holds, conjEverywhere_holds_iff]
    have hbf2 : bf2.holds M atomMap z0 z1 ↔
        ∀ y, z0 < y → y < z1 →
          (bf2.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y := by
      simp only [holds, toIntervalPattern, IntervalPattern.holds]
    rw [hbf2]
  | m1 + 1, m2 + 1, bf1, bf2 =>
    rw [show bf1.conjFull bf2 = _ from by rw [conjFull]]
    rw [VBracketFormula.disj_holds, VBracketFormula.disj_holds,
        VBracketFormula.snocAll_holds_iff, VBracketFormula.snocAll_holds_iff,
        VBracketFormula.snocAll_holds_iff]
    constructor
    · rintro (⟨x, hx0, hx1, hcf, hpt, hseg⟩ | ⟨x, hx0, hx1, hcf, hpt, hseg⟩ |
        ⟨x, hx0, hx1, hcf, hpt, hseg⟩)
      · -- last witnesses coincide
        rw [conjFull_iff M atomMap bf1.front bf2.front z0 x] at hcf
        rw [TemporalPred.eval_at_conj] at hpt
        have hseg1 : ∀ y, x < y → y < z1 →
            (bf1.segmentTypes ⟨m1 + 1, by omega⟩).eval_at M atomMap y :=
          fun y h1 h2 =>
            ((TemporalPred.eval_at_conj M atomMap _ _ y).mp (hseg y h1 h2)).1
        have hseg2 : ∀ y, x < y → y < z1 →
            (bf2.segmentTypes ⟨m2 + 1, by omega⟩).eval_at M atomMap y :=
          fun y h1 h2 =>
            ((TemporalPred.eval_at_conj M atomMap _ _ y).mp (hseg y h1 h2)).2
        constructor
        · rw [holds_succ_iff]
          exact ⟨x, hx0, hx1, hcf.1, hpt.1, hseg1⟩
        · rw [holds_succ_iff]
          exact ⟨x, hx0, hx1, hcf.2, hpt.2, hseg2⟩
      · -- bf1's last witness strictly greater
        rw [conjFull_iff M atomMap bf1.front bf2 z0 x] at hcf
        rw [TemporalPred.eval_at_conj] at hpt
        have hseg1 : ∀ y, x < y → y < z1 →
            (bf1.segmentTypes ⟨m1 + 1, by omega⟩).eval_at M atomMap y :=
          fun y h1 h2 =>
            ((TemporalPred.eval_at_conj M atomMap _ _ y).mp (hseg y h1 h2)).1
        have hseg2 : ∀ y, x < y → y < z1 →
            (bf2.segmentTypes ⟨m2 + 1, by omega⟩).eval_at M atomMap y :=
          fun y h1 h2 =>
            ((TemporalPred.eval_at_conj M atomMap _ _ y).mp (hseg y h1 h2)).2
        constructor
        · rw [holds_succ_iff]
          exact ⟨x, hx0, hx1, hcf.1, hpt.1, hseg1⟩
        · -- glue bf2's last segment across x
          have h2 := hcf.2
          rw [holds_succ_iff] at h2 ⊢
          obtain ⟨x2, hx20, hx2x, hf2, hp2, hs2⟩ := h2
          exact ⟨x2, hx20, lt_trans hx2x hx1, hf2, hp2,
            TemporalPred.eval_at_glue M atomMap _ x2 x z1 hs2 hpt.2 hseg2⟩
      · -- bf2's last witness strictly greater (mirror)
        rw [conjFull_iff M atomMap bf1 bf2.front z0 x] at hcf
        rw [TemporalPred.eval_at_conj] at hpt
        have hseg1 : ∀ y, x < y → y < z1 →
            (bf1.segmentTypes ⟨m1 + 1, by omega⟩).eval_at M atomMap y :=
          fun y h1 h2 =>
            ((TemporalPred.eval_at_conj M atomMap _ _ y).mp (hseg y h1 h2)).1
        have hseg2 : ∀ y, x < y → y < z1 →
            (bf2.segmentTypes ⟨m2 + 1, by omega⟩).eval_at M atomMap y :=
          fun y h1 h2 =>
            ((TemporalPred.eval_at_conj M atomMap _ _ y).mp (hseg y h1 h2)).2
        constructor
        · -- glue bf1's last segment across x
          have h1 := hcf.1
          rw [holds_succ_iff] at h1 ⊢
          obtain ⟨x1, hx10, hx1x, hf1, hp1, hs1⟩ := h1
          exact ⟨x1, hx10, lt_trans hx1x hx1, hf1, hp1,
            TemporalPred.eval_at_glue M atomMap _ x1 x z1 hs1 hpt.1 hseg1⟩
        · rw [holds_succ_iff]
          exact ⟨x, hx0, hx1, hcf.2, hpt.2, hseg2⟩
    · rintro ⟨h1, h2⟩
      rw [holds_succ_iff] at h1 h2
      obtain ⟨x1, hx10, hx11, hf1, hp1, hs1⟩ := h1
      obtain ⟨x2, hx20, hx21, hf2, hp2, hs2⟩ := h2
      rcases lt_trichotomy x1 x2 with hlt | heq | hgt
      · -- x1 < x2: bf2's last witness is the global last
        refine Or.inr (Or.inr ⟨x2, hx20, hx21, ?_, ?_, ?_⟩)
        · rw [conjFull_iff M atomMap bf1 bf2.front z0 x2]
          refine ⟨?_, hf2⟩
          rw [holds_succ_iff]
          exact ⟨x1, hx10, hlt, hf1, hp1,
            fun y hy1 hy2 => hs1 y hy1 (lt_trans hy2 hx21)⟩
        · rw [TemporalPred.eval_at_conj]
          exact ⟨hs1 x2 hlt hx21, hp2⟩
        · intro y hy1 hy2
          rw [TemporalPred.eval_at_conj]
          exact ⟨hs1 y (lt_trans hlt hy1) hy2, hs2 y hy1 hy2⟩
      · -- x1 = x2: last witnesses coincide
        subst heq
        refine Or.inl ⟨x1, hx10, hx11, ?_, ?_, ?_⟩
        · rw [conjFull_iff M atomMap bf1.front bf2.front z0 x1]
          exact ⟨hf1, hf2⟩
        · rw [TemporalPred.eval_at_conj]
          exact ⟨hp1, hp2⟩
        · intro y hy1 hy2
          rw [TemporalPred.eval_at_conj]
          exact ⟨hs1 y hy1 hy2, hs2 y hy1 hy2⟩
      · -- x2 < x1: bf1's last witness is the global last
        refine Or.inr (Or.inl ⟨x1, hx10, hx11, ?_, ?_, ?_⟩)
        · rw [conjFull_iff M atomMap bf1.front bf2 z0 x1]
          refine ⟨hf1, ?_⟩
          rw [holds_succ_iff]
          exact ⟨x2, hx20, hgt, hf2, hp2,
            fun y hy1 hy2 => hs2 y hy1 (lt_trans hy2 hx11)⟩
        · rw [TemporalPred.eval_at_conj]
          exact ⟨hp1, hs2 x1 hgt hx11⟩
        · intro y hy1 hy2
          rw [TemporalPred.eval_at_conj]
          exact ⟨hs1 y hy1 hy2, hs2 y (lt_trans hgt hy1) hy2⟩
  termination_by n1 + n2
  decreasing_by all_goals omega

/-! ## Full conjunction of V-vec-EA-2 formulas (Lemma 3.4) -/

/-- Full conjunction on V-vec-EA-2 formulas (Rabinovich Lemma 3.4, conjunction
    case): Cartesian product of disjunct lists, endpoint predicates conjoined
    pairwise, per-pair bracket conjunction via `BracketFormula.conjFull` with
    the resulting bracket lists flattened. -/
def VVecEA2.conjFull (v1 v2 : VVecEA2) : VVecEA2 :=
  { disjuncts := v1.disjuncts.flatMap fun d1 =>
      v2.disjuncts.flatMap fun d2 =>
        (d1.2.bracket.conjFull d2.2.bracket).disjuncts.map fun db =>
          ⟨db.1,
            { endpointLeft := d1.2.endpointLeft.conj d2.2.endpointLeft
              endpointRight := d1.2.endpointRight.conj d2.2.endpointRight
              bracket := db.2 }⟩ }

/-- Full semantic correctness of `VVecEA2.conjFull` (Lemma 3.4, iff form):
    the conjunction of two V-vec-EA-2 formulas holds iff their full
    conjunction holds. -/
theorem VVecEA2.conjFull_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VVecEA2) (z0 z1 : M.carrier) :
    (v1.conjFull v2).holds M atomMap z0 z1 ↔
    v1.holds M atomMap z0 z1 ∧ v2.holds M atomMap z0 z1 := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [conjFull, List.mem_flatMap, List.mem_map] at hmem
    obtain ⟨⟨k1, vea1⟩, hm1, ⟨k2, vea2⟩, hm2, ⟨m, bf⟩, hmbf, rfl⟩ := hmem
    simp only [VecEA2.holds] at hh
    obtain ⟨hel, her, hbr⟩ := hh
    rw [TemporalPred.eval_at_conj] at hel her
    have hbf2 : (vea1.bracket.conjFull vea2.bracket).holds M atomMap z0 z1 :=
      ⟨⟨m, bf⟩, hmbf, hbr⟩
    rw [BracketFormula.conjFull_iff] at hbf2
    exact ⟨⟨⟨k1, vea1⟩, hm1, hel.1, her.1, hbf2.1⟩,
           ⟨⟨k2, vea2⟩, hm2, hel.2, her.2, hbf2.2⟩⟩
  · rintro ⟨⟨⟨k1, vea1⟩, hm1, hh1⟩, ⟨⟨k2, vea2⟩, hm2, hh2⟩⟩
    simp only [VecEA2.holds] at hh1 hh2
    obtain ⟨hel1, her1, hbr1⟩ := hh1
    obtain ⟨hel2, her2, hbr2⟩ := hh2
    have hbf : (vea1.bracket.conjFull vea2.bracket).holds M atomMap z0 z1 := by
      rw [BracketFormula.conjFull_iff]
      exact ⟨hbr1, hbr2⟩
    obtain ⟨⟨m, bf⟩, hmbf, hbfh⟩ := hbf
    refine ⟨⟨m, { endpointLeft := vea1.endpointLeft.conj vea2.endpointLeft
                  endpointRight := vea1.endpointRight.conj vea2.endpointRight
                  bracket := bf }⟩, ?_, ?_, ?_, ?_⟩
    · simp only [conjFull, List.mem_flatMap, List.mem_map]
      exact ⟨⟨k1, vea1⟩, hm1, ⟨k2, vea2⟩, hm2, ⟨m, bf⟩, hmbf, rfl⟩
    · exact (TemporalPred.eval_at_conj M atomMap _ _ z0).mpr ⟨hel1, hel2⟩
    · exact (TemporalPred.eval_at_conj M atomMap _ _ z1).mpr ⟨her1, her2⟩
    · exact hbfh

/-! ## Neutral element for the conjunction fold (Phase 16) -/

/-- The always-true V-vec-EA-2 formula: a single disjunct with `top` endpoint
    predicates and the trivial `top` bracket. Neutral element for `conjFull`
    folds. -/
def VVecEA2.trivialTrue : VVecEA2 :=
  ⟨[⟨0, { endpointLeft := TemporalPred.top
          endpointRight := TemporalPred.top
          bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩

/-- `trivialTrue` holds on every interval. -/
theorem VVecEA2.trivialTrue_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    VVecEA2.trivialTrue.holds M atomMap z0 z1 := by
  refine ⟨⟨0, _⟩, List.mem_singleton.mpr rfl, ?_, ?_, ?_⟩
  · exact TemporalPred.eval_at_top M atomMap z0
  · exact TemporalPred.eval_at_top M atomMap z1
  · rw [BracketFormula.trivial_holds]
    intro y _ _
    exact TemporalPred.eval_at_top M atomMap y

/-- `trivialTrue` is a right neutral element for `conjFull`. -/
theorem VVecEA2.conjFull_trivialTrue_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) (z0 z1 : M.carrier) :
    (v.conjFull VVecEA2.trivialTrue).holds M atomMap z0 z1 ↔
    v.holds M atomMap z0 z1 := by
  rw [VVecEA2.conjFull_iff]
  exact and_iff_left (trivialTrue_holds M atomMap z0 z1)

/-- `trivialTrue` is a left neutral element for `conjFull`. -/
theorem VVecEA2.trivialTrue_conjFull_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) (z0 z1 : M.carrier) :
    (VVecEA2.trivialTrue.conjFull v).holds M atomMap z0 z1 ↔
    v.holds M atomMap z0 z1 := by
  rw [VVecEA2.conjFull_iff]
  exact and_iff_right (trivialTrue_holds M atomMap z0 z1)

end Bimodal.Metalogic.WeakCanonical.Kamp
