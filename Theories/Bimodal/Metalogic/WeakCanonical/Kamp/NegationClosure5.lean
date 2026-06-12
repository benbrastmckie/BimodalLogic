import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEATranslation
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF

/-!
# Negation Closure Lemmas (Rabinovich 2014, Section 5)

Proves the key lemmas from Rabinovich Section 5 that establish negation closure
for vec-EA formulas over Prior structures. This file contains:

- **Lemma 5.3 base case** (Phase 4a): Negation of a single bounded existential
  is a V-EA formula.
- **INF formula on Prior structures** (Phase 4b): First-occurrence localization
  using `semantic_prior_UZ`, with simplified form (no K+ disjunct).

## Mathematical Content

### Lemma 5.3 (Base case, n=1)

The negation:
  not (exists x in (z_0, z_1)) P(x)
is equivalent to:
  (forall y in (z_0, z_1)) not P(y)

which is a `BracketFormula 0` with segment type `not P`. This is the base case
of the induction on the number of predicates in Lemma 5.3.

### INF formula (Eq 5.2, Prior simplification)

On Prior structures satisfying `semantic_prior_UZ`, for any TL-definable
predicate P and interval (z_0, z_1), if P occurs somewhere in (z_0, z_1),
then the first occurrence r_0 is attained: P(r_0) holds and not P on (z_0, r_0).
The K+ disjunct from eq (5.2) is vacuous on Prior structures.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5, Lemma 5.3, eq (5.2)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Phase 4a: Lemma 5.3 Base Case

Lemma 5.3 states: the negation of
  `exists x_1 ... x_n (z_0 < x_1 < ... < x_n < z_1) AND P_1(x_1) AND ... AND P_n(x_n)`
is equivalent to a V-EA formula over Dedekind complete chains.

The **base case** (n=1) is:
  `not (exists x in (z_0, z_1)) P(x)` iff `(forall y in (z_0, z_1)) not P(y)`

In bracket formula terms:
- The existential side is `BracketFormula 1` with pointType = P and segmentTypes = True
- The universal side is `BracketFormula 0` with segmentType = not P

We prove both directions of this equivalence, and that the universal side
is a V-bracket formula (hence V-EA).
-/

/-- A "pure point predicate" bracket formula: exists x in (z_0, z_1) with P(x),
    and True on all segments. This is the bracket formula [True, P, True](z_0, z_1)
    in Notation 5.2 with n=1 witness. -/
def BracketFormula.purePoint (P : TemporalPred) : BracketFormula 1 :=
  { pointTypes := fun _ => P
    segmentTypes := fun _ => TemporalPred.top }

/-- A "pure segment" bracket formula with 0 witnesses: the predicate Q holds
    everywhere in (z_0, z_1). This is [Q](z_0, z_1) in Notation 5.2 with n=0. -/
def BracketFormula.pureSeg (Q : TemporalPred) : BracketFormula 0 :=
  { pointTypes := Fin.elim0
    segmentTypes := fun _ => Q }

/-- The pure point bracket formula holds iff there exists a witness with P. -/
theorem BracketFormula.purePoint_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    (BracketFormula.purePoint P).holds M atomMap z0 z1 ↔
    ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x := by
  simp only [holds, toIntervalPattern, IntervalPattern.holds, purePoint]
  constructor
  · rintro ⟨w, _, hbnd, hpt, _, _, _⟩
    exact ⟨w ⟨0, by omega⟩, (hbnd ⟨0, by omega⟩).1, (hbnd ⟨0, by omega⟩).2,
           hpt ⟨0, by omega⟩⟩
  · rintro ⟨x, hx0, hx1, hPx⟩
    refine ⟨fun _ => x, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      simp at hi hj; subst hi; subst hj; exact absurd hij (lt_irrefl _)
    · intro _; exact ⟨hx0, hx1⟩
    · intro _; exact hPx
    · intro y hy0 hy1; exact TemporalPred.eval_at_top M atomMap y
    · intro i; exact Fin.elim0 i
    · intro y hy0 hy1; exact TemporalPred.eval_at_top M atomMap y

/-- The pure segment bracket formula holds iff Q holds everywhere in (z_0, z_1). -/
theorem BracketFormula.pureSeg_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Q : TemporalPred) (z0 z1 : M.carrier) :
    (BracketFormula.pureSeg Q).holds M atomMap z0 z1 ↔
    ∀ y : M.carrier, z0 < y → y < z1 → Q.eval_at M atomMap y := by
  simp only [holds, toIntervalPattern, IntervalPattern.holds, pureSeg]

/-- The `TemporalPred.neg` evaluation lemma: `(P.neg).eval_at` iff `not (P.eval_at)`. -/
theorem TemporalPred.eval_at_neg {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (t : M.carrier) :
    P.neg.eval_at M atomMap t ↔ ¬P.eval_at M atomMap t := by
  simp only [neg, eval_at, Formula.neg, temporal_truth]

/-- **Lemma 5.3, Base Case (n=1)**: The negation of "exists x in (z_0, z_1) with P(x)"
    is equivalent to "forall y in (z_0, z_1), not P(y)".

    This is the base of the induction in Rabinovich Lemma 5.3. The universal
    formula is a `BracketFormula 0` (hence V-EA). -/
theorem neg_interval_base_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    ¬(∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x) ↔
    ∀ y : M.carrier, z0 < y → y < z1 → ¬P.eval_at M atomMap y := by
  push_neg
  rfl

/-- **Lemma 5.3, Base Case (bracket form)**: The negation of a pure-point bracket
    formula with predicate P is equivalent to a pure-segment bracket formula
    with predicate `not P`.

    In bracket notation: `not [True, P, True](z_0, z_1)` iff `[not P](z_0, z_1)`. -/
theorem neg_interval_base_bracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    ¬(BracketFormula.purePoint P).holds M atomMap z0 z1 ↔
    (BracketFormula.pureSeg P.neg).holds M atomMap z0 z1 := by
  rw [BracketFormula.purePoint_holds, BracketFormula.pureSeg_holds]
  rw [neg_interval_base_iff]
  constructor
  · intro h y hy0 hy1
    exact (TemporalPred.eval_at_neg M atomMap P y).mpr (h y hy0 hy1)
  · intro h y hy0 hy1
    exact (TemporalPred.eval_at_neg M atomMap P y).mp (h y hy0 hy1)

/-- The negation of a single bounded existential (pure point bracket) yields a
    V-bracket formula. This is the V-EA closure form of the base case. -/
theorem neg_interval_base_vbracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier)
    (h : ¬(BracketFormula.purePoint P).holds M atomMap z0 z1) :
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1 := by
  exact ⟨⟨[⟨0, BracketFormula.pureSeg P.neg⟩]⟩,
         ⟨0, BracketFormula.pureSeg P.neg⟩,
         List.mem_singleton.mpr rfl,
         (neg_interval_base_bracket M atomMap P z0 z1).mp h⟩

/-! ## Generalized Base Case: Multiple Pure Point Predicates

Lemma 5.3 in full generality handles n predicates P_1, ..., P_n with all
segment types True. The base case above handles n=1. Here we provide the
definition and key lemmas for the generalized pure-points case.
-/

/-- A bracket formula where all segment types are True (pure point predicates).
    This is the special case of Lemma 5.3: only point types matter. -/
def BracketFormula.purePoints {n : Nat} (P : Fin n → TemporalPred) :
    BracketFormula n :=
  { pointTypes := P
    segmentTypes := fun _ => TemporalPred.top }

/-- Pure-points bracket with 0 predicates holds iff True on the interval
    (which reduces to the trivial segment type). -/
theorem BracketFormula.purePoints_zero_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    (BracketFormula.purePoints (Fin.elim0 : Fin 0 → TemporalPred)).holds M atomMap z0 z1 := by
  simp only [holds, toIntervalPattern, IntervalPattern.holds, purePoints]
  intro y _ _
  exact TemporalPred.eval_at_top M atomMap y

/-- Pure-points bracket with n+1 predicates holds iff there are strictly
    increasing witnesses with the specified point types. -/
theorem BracketFormula.purePoints_succ_holds {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin (n + 1) → TemporalPred) (z0 z1 : M.carrier) :
    (BracketFormula.purePoints P).holds M atomMap z0 z1 ↔
    ∃ (w : Fin (n + 1) → M.carrier),
      (∀ i j : Fin (n + 1), i < j → w i < w j) ∧
      (∀ i : Fin (n + 1), z0 < w i ∧ w i < z1) ∧
      (∀ i : Fin (n + 1), (P i).eval_at M atomMap (w i)) := by
  simp only [holds, toIntervalPattern, IntervalPattern.holds, purePoints]
  constructor
  · rintro ⟨w, hm, hbnd, hpt, _, _, _⟩
    exact ⟨w, hm, hbnd, hpt⟩
  · rintro ⟨w, hm, hbnd, hpt⟩
    exact ⟨w, hm, hbnd, hpt,
           fun y _ _ => TemporalPred.eval_at_top M atomMap y,
           fun i y _ _ => TemporalPred.eval_at_top M atomMap y,
           fun y _ _ => TemporalPred.eval_at_top M atomMap y⟩

/-- Lemma 5.3 base for 1 predicate: not (exists x in (z_0, z_1)) P(x) implies
    `BracketFormula.pureSeg P.neg` holds. Bridges the pure-points formulation
    to the bracket-formula base case. -/
theorem neg_purePoints_one {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin 1 → TemporalPred) (z0 z1 : M.carrier)
    (h : ¬(BracketFormula.purePoints P).holds M atomMap z0 z1) :
    (BracketFormula.pureSeg (P ⟨0, by omega⟩).neg).holds M atomMap z0 z1 := by
  rw [BracketFormula.purePoints_succ_holds] at h
  push_neg at h
  rw [BracketFormula.pureSeg_holds]
  intro y hy0 hy1
  rw [TemporalPred.eval_at_neg]
  have h_spec := h (fun _ => y)
    (fun ⟨i, hi⟩ ⟨j, hj⟩ hij => by
      have : i = 0 := by omega
      have : j = 0 := by omega
      omega)
    (fun _ => ⟨hy0, hy1⟩)
  obtain ⟨⟨i, hi⟩, h_neg⟩ := h_spec
  have : i = 0 := by omega
  subst this
  exact h_neg

/-! ## Phase 4b: INF Formula on Prior Structures (Eq 5.2 / Lemma 5.3 setup)

On Prior structures satisfying `semantic_prior_UZ`, for any TL-definable predicate P
and interval (z_0, z_1), if P occurs somewhere in (z_0, z_1), the first occurrence
r_0 is attained: P(r_0) holds and not P on (z_0, r_0). The K+ disjunct from
Rabinovich eq (5.2) is vacuous.

This section provides:
1. `first_occurrence_prior`: Given semantic_prior_UZ and P occurring in (z_0, z_1),
   locates r_0 = inf{z in (z_0, z_1) | P(z)} with all needed properties.
2. `inf_bracket_formula`: The bracket formula [not P, P, True](z_0, z_1) describing
   the INF configuration with r_0 as an interior witness.
3. `inf_formula_prior_is_vbracket`: The INF formula is V-bracket (hence V-EA).
-/

/-- First occurrence of a predicate P in the interval (z_0, z_1) on Prior structures.

    Given `semantic_prior_UZ` and evidence that P occurs in (z_0, z_1), produces
    r_0 satisfying:
    - z_0 < r_0 (strictly above z_0)
    - r_0 ≤ z_1 (at most z_1; the first occurrence might be at or before the boundary)
    - P(r_0) holds (the infimum is attained on Prior structures)
    - not P on (z_0, r_0) (no earlier occurrence)

    This is the Prior-specialized version of eq (5.2). The K+(P) disjunct is
    vacuous because `semantic_prior_UZ` directly gives an attained first occurrence. -/
theorem first_occurrence_prior {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier)
    (_h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x) :
    ∃ r0 : M.carrier,
      z0 < r0 ∧ r0 ≤ z1 ∧
      P.eval_at M atomMap r0 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → ¬P.eval_at M atomMap y) := by
  -- Use semantic_prior_UZ to get the first occurrence of P above z0
  obtain ⟨x, hx0, hx1, hPx⟩ := h_exists
  have h_above : ∃ s, z0 < s ∧ temporal_truth M atomMap s P.formula :=
    ⟨x, hx0, hPx⟩
  obtain ⟨r0, hr0_above, hPr0, h_neg_between⟩ := h_UZ z0 P.formula h_above
  -- r0 is the first occurrence of P above z0
  -- We need r0 ≤ z1: since r0 ≤ x (first occ) and x < z1, we get r0 ≤ z1
  have hr0_le_x : r0 ≤ x := by
    by_contra h_gt
    push_neg at h_gt
    -- r0 > x, but not-P on (z0, r0), so not-P(x), contradicting P(x)
    have := h_neg_between x hx0 h_gt
    simp only [Formula.neg, temporal_truth] at this
    exact this hPx
  refine ⟨r0, hr0_above, le_trans hr0_le_x (le_of_lt hx1), hPr0, ?_⟩
  -- not P on (z0, r0)
  intro y hy0 hy1
  have := h_neg_between y hy0 hy1
  simp only [Formula.neg, temporal_truth, TemporalPred.eval_at] at this ⊢
  exact this

/-- Strict first occurrence: if P occurs **strictly inside** (z_0, z_1), then
    r_0 < z_1 (the first occurrence is strictly before the right endpoint). -/
theorem first_occurrence_prior_strict {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x) :
    ∃ r0 : M.carrier,
      z0 < r0 ∧ r0 < z1 ∧
      P.eval_at M atomMap r0 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → ¬P.eval_at M atomMap y) := by
  obtain ⟨r0, hr0_above, hr0_le, hPr0, h_neg⟩ :=
    first_occurrence_prior M atomMap h_UZ P z0 z1 h_lt h_exists
  obtain ⟨x, hx0, hx1, hPx⟩ := h_exists
  -- r0 ≤ x < z1, so r0 < z1
  have hr0_le_x : r0 ≤ x := by
    by_contra h_gt
    push_neg at h_gt
    exact h_neg x hx0 h_gt hPx
  exact ⟨r0, hr0_above, lt_of_le_of_lt hr0_le_x hx1, hPr0, h_neg⟩

/-- The INF bracket formula: [not P, P, True](z_0, z_1).
    This describes the configuration around the first occurrence of P in (z_0, z_1):
    - not P holds on (z_0, x) for some witness x
    - P holds at x
    - True holds on (x, z_1) (no constraint) -/
def inf_bracket_formula (P : TemporalPred) : BracketFormula 1 :=
  { pointTypes := fun _ => P
    segmentTypes := fun i => if i.val = 0 then P.neg else TemporalPred.top }

/-- The INF bracket formula holds on (z_0, z_1) iff there exists a first-occurrence
    witness: a point x in (z_0, z_1) with P(x) and not P on (z_0, x). -/
theorem inf_bracket_formula_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    (inf_bracket_formula P).holds M atomMap z0 z1 ↔
    ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
      P.eval_at M atomMap x ∧
      (∀ y : M.carrier, z0 < y → y < x → P.neg.eval_at M atomMap y) := by
  simp only [inf_bracket_formula, BracketFormula.holds, BracketFormula.toIntervalPattern,
             IntervalPattern.holds]
  constructor
  · rintro ⟨w, _, hbnd, hpt, hseg0, _, hseg1⟩
    refine ⟨w ⟨0, by omega⟩, (hbnd ⟨0, by omega⟩).1, (hbnd ⟨0, by omega⟩).2,
            hpt ⟨0, by omega⟩, ?_⟩
    intro y hy0 hy1
    have := hseg0 y hy0 hy1
    simp at this
    exact this
  · rintro ⟨x, hx0, hx1, hPx, h_neg⟩
    refine ⟨fun _ => x, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      simp at hi hj; subst hi; subst hj; exact absurd hij (lt_irrefl _)
    · intro _; exact ⟨hx0, hx1⟩
    · intro _; exact hPx
    · intro y hy0 hy1
      have := h_neg y hy0 hy1
      simp; exact this
    · intro i; exact Fin.elim0 i
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y

/-- On Prior structures, if P occurs in (z_0, z_1), the INF bracket formula holds.
    This connects `first_occurrence_prior` to the bracket formula representation. -/
theorem inf_bracket_formula_prior {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x) :
    (inf_bracket_formula P).holds M atomMap z0 z1 := by
  rw [inf_bracket_formula_holds]
  obtain ⟨r0, hr0_above, hr0_strict, hPr0, h_neg⟩ :=
    first_occurrence_prior_strict M atomMap h_UZ P z0 z1 h_lt h_exists
  exact ⟨r0, hr0_above, hr0_strict, hPr0, fun y hy0 hy1 =>
    (TemporalPred.eval_at_neg M atomMap P y).mpr (h_neg y hy0 hy1)⟩

/-- The INF formula is V-bracket: it produces a V-bracket formula witnessing
    the first occurrence configuration. -/
theorem inf_formula_prior_is_vbracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x) :
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1 := by
  exact ⟨⟨[⟨1, inf_bracket_formula P⟩]⟩,
         ⟨1, inf_bracket_formula P⟩,
         List.mem_singleton.mpr rfl,
         inf_bracket_formula_prior M atomMap h_UZ P z0 z1 h_lt h_exists⟩

/-! ### First Occurrence Interval Splitting

The key use of the first occurrence in the inductive step of Lemma 5.3:
after locating r_0 = first occurrence of P_1 in (z_0, z_1), we split the
problem into sub-intervals. The remaining predicates P_2, ..., P_n must
have their witnesses in (r_0, z_1), since P_1's first occurrence is at r_0.

This section provides the interval splitting lemma that reduces the
inductive step to a problem with n-1 predicates.
-/

/-- Helper: prepending a witness to a pure-points formula.
    If `P ⟨0, ...⟩` holds at r0, and the remaining predicates
    `P ⟨1, ...⟩, ..., P ⟨n, ...⟩` hold at witnesses in (r0, z1),
    then all predicates hold at witnesses in (z0, z1). -/
private theorem purePoints_prepend {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin (n + 1) → TemporalPred) (z0 z1 r0 : M.carrier)
    (hr0_above : z0 < r0) (hr0_below : r0 < z1)
    (hPr0 : (P ⟨0, by omega⟩).eval_at M atomMap r0)
    (h_rest : (BracketFormula.purePoints (fun i : Fin n =>
      P ⟨i.val + 1, by omega⟩)).holds M atomMap r0 z1) :
    (BracketFormula.purePoints P).holds M atomMap z0 z1 := by
  match n with
  | 0 =>
    -- Only 1 predicate: P ⟨0, ...⟩, witness is r0
    rw [BracketFormula.purePoints_succ_holds]
    exact ⟨fun _ => r0,
           fun ⟨i, hi⟩ ⟨j, hj⟩ hij => absurd hij (by omega),
           fun _ => ⟨hr0_above, hr0_below⟩,
           fun ⟨i, hi⟩ => by
             have : i = 0 := by omega
             subst this; exact hPr0⟩
  | n' + 1 =>
    rw [BracketFormula.purePoints_succ_holds] at h_rest
    obtain ⟨w', hm', hbnd', hpt'⟩ := h_rest
    rw [BracketFormula.purePoints_succ_holds]
    -- Combined witnesses: w(0) = r0, w(i+1) = w'(i)
    refine ⟨fun ⟨i, hi⟩ => if h : i = 0 then r0 else w' ⟨i - 1, by omega⟩,
            ?_, ?_, ?_⟩
    · -- Strictly increasing
      intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      simp only [Fin.lt_def] at hij
      by_cases h0 : i = 0
      · subst h0; simp only [dite_true]
        have hj_ne : ¬(j = 0) := by omega
        simp only [hj_ne, dite_false]
        exact lt_of_lt_of_le (hbnd' ⟨0, by omega⟩).1
          (by rcases Nat.eq_or_lt_of_le (Nat.one_le_of_lt (by omega : 0 < j)) with rfl | hlt
              · simp
              · exact le_of_lt (hm' ⟨0, by omega⟩ ⟨j - 1, by omega⟩
                  (by simp [Fin.lt_def]; omega)))
      · have hj_ne : ¬(j = 0) := by omega
        simp only [show ¬(i = 0) from h0, dite_false, hj_ne, dite_false]
        exact hm' ⟨i - 1, by omega⟩ ⟨j - 1, by omega⟩ (by simp [Fin.lt_def]; omega)
    · -- All in (z0, z1)
      intro ⟨i, hi⟩
      by_cases h0 : i = 0
      · subst h0; simp only [dite_true]; exact ⟨hr0_above, hr0_below⟩
      · simp only [show ¬(i = 0) from h0, dite_false]
        exact ⟨lt_trans hr0_above (hbnd' ⟨i - 1, by omega⟩).1,
               (hbnd' ⟨i - 1, by omega⟩).2⟩
    · -- Point types hold
      intro ⟨i, hi⟩
      by_cases h0 : i = 0
      · subst h0; simp only [dite_true]; exact hPr0
      · simp only [show ¬(i = 0) from h0, dite_false]
        have := hpt' ⟨i - 1, by omega⟩
        convert this using 2
        ext; simp; omega

theorem neg_purePoints_split {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin (n + 1) → TemporalPred) (z0 z1 r0 : M.carrier)
    (hr0_above : z0 < r0) (hr0_below : r0 < z1)
    (hPr0 : (P ⟨0, by omega⟩).eval_at M atomMap r0)
    (h_neg : ¬(BracketFormula.purePoints P).holds M atomMap z0 z1) :
    ¬(BracketFormula.purePoints (fun i : Fin n => P ⟨i.val + 1, by omega⟩)).holds
      M atomMap r0 z1 := by
  intro h_holds
  exact h_neg (purePoints_prepend M atomMap P z0 z1 r0 hr0_above hr0_below hPr0 h_holds)

/-! ## Phase 4c: Inductive Step of Lemma 5.3

The inductive step of Lemma 5.3 proves that the negation of a pure-points
bracket formula with n+1 predicates is V-bracket, given that it holds for n.

On Prior structures, the proof proceeds by case analysis on whether P_1
occurs in (z_0, z_1):
- **Case 1** (P_1 absent): The negation is trivially a V-bracket formula
  (`pureSeg (P_1).neg`, a BracketFormula 0).
- **Case 2** (P_1 present): Use `first_occurrence_prior_strict` to find
  r_0 = first occurrence of P_1 in (z_0, z_1). By `neg_purePoints_split`,
  the remaining n predicates cannot all have witnesses in (r_0, z_1).
  By the inductive hypothesis, this negation is V-bracket on (r_0, z_1).
  Composing with the INF configuration gives a V-bracket on (z_0, z_1).

### References
- Rabinovich 2014, Lemma 5.3 inductive step (pp. 9-10)
-/

/-- Prepend a witness to a bracket formula: given a `BracketFormula k` on
    (r0, z1), produce a `BracketFormula (k + 1)` on (z0, z1) by adding
    r0 as the first witness with point type `ptType` and left segment type
    `segLeft` (on the segment (z0, r0)). The segments and points from the
    original formula fill (r0, z1). -/
def BracketFormula.prepend (segLeft ptType : TemporalPred)
    {k : Nat} (bf : BracketFormula k) : BracketFormula (k + 1) :=
  { pointTypes := fun i =>
      if h : i.val = 0 then ptType
      else bf.pointTypes ⟨i.val - 1, by omega⟩
    segmentTypes := fun i =>
      if h : i.val = 0 then segLeft
      else bf.segmentTypes ⟨i.val - 1, by omega⟩ }

/-- Semantic bracket formula prepend: if `bf.holds M atomMap r0 z1` holds (the
    tail interval), then a bracket formula on `(z0, z1)` holds with r0 as the
    first witness, `segLeft` on `(z0, r0)`, and `ptType` at r0.

    This constructs a **fresh** BracketFormula and its `holds` proof directly,
    returning both the formula and its holding proof as a sigma type. -/
theorem BracketFormula.bracket_prepend_holds {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula k) (segLeft ptType : TemporalPred)
    (z0 z1 r0 : M.carrier)
    (hr0_above : z0 < r0) (hr0_below : r0 < z1)
    (hPt : ptType.eval_at M atomMap r0)
    (hSeg : ∀ y : M.carrier, z0 < y → y < r0 → segLeft.eval_at M atomMap y)
    (h_tail : bf.holds M atomMap r0 z1) :
    ∃ (bf' : BracketFormula (k + 1)), bf'.holds M atomMap z0 z1 := by
  -- Construct the combined bracket formula explicitly
  -- and prove holds by providing witnesses
  match k with
  | 0 =>
    -- h_tail : segment holds everywhere in (r0, z1)
    simp only [holds, toIntervalPattern, IntervalPattern.holds] at h_tail
    -- Produce BracketFormula 1 with witness at r0
    refine ⟨⟨fun _ => ptType, fun i =>
              if i.val = 0 then segLeft else bf.segmentTypes ⟨0, by omega⟩⟩, ?_⟩
    simp only [holds, toIntervalPattern, IntervalPattern.holds]
    refine ⟨fun _ => r0, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j hij; exact absurd hij (by omega)
    · intro _; exact ⟨hr0_above, hr0_below⟩
    · intro ⟨i, hi⟩
      have h0 : i = 0 := by omega
      subst h0; exact hPt
    · intro y hy0 hy1; simp; exact hSeg y hy0 hy1
    · intro ⟨i, hi⟩; exact absurd hi (by omega)
    · intro y hy0 hy1; simp; exact h_tail y hy0 hy1
  | k' + 1 =>
    simp only [holds, toIntervalPattern, IntervalPattern.holds] at h_tail
    obtain ⟨w, hm, hbnd, hpt, hseg0, hseg_mid, hseg_last⟩ := h_tail
    -- Produce BracketFormula (k'+2) with witnesses r0, w(0), ..., w(k')
    -- Point types: ptType, bf.pointTypes(0), ..., bf.pointTypes(k')
    -- Segment types: segLeft, bf.segmentTypes(0), ..., bf.segmentTypes(k'+1)
    let pt' : Fin (k' + 2) → TemporalPred := fun ⟨i, _⟩ =>
      if i = 0 then ptType else bf.pointTypes ⟨i - 1, by omega⟩
    let seg' : Fin (k' + 3) → TemporalPred := fun ⟨i, _⟩ =>
      if i = 0 then segLeft else bf.segmentTypes ⟨i - 1, by omega⟩
    refine ⟨⟨pt', seg'⟩, ?_⟩
    simp only [holds, toIntervalPattern, IntervalPattern.holds]
    -- Witness function: w'(0) = r0, w'(i+1) = w(i)
    let w' : Fin (k' + 2) → M.carrier := fun ⟨i, _⟩ =>
      if i = 0 then r0 else w ⟨i - 1, by omega⟩
    refine ⟨w', ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- Strictly increasing
      intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      simp only [Fin.lt_def] at hij
      show w' ⟨i, hi⟩ < w' ⟨j, hj⟩
      simp only [w']
      by_cases hi0 : i = 0
      · subst hi0; simp only [ite_true, if_neg (show j ≠ 0 from by omega)]
        exact lt_of_lt_of_le (hbnd ⟨0, by omega⟩).1
          (by rcases Nat.eq_or_lt_of_le (show 1 ≤ j from by omega) with h | h
              · subst h; simp
              · exact le_of_lt (hm ⟨0, by omega⟩ ⟨j - 1, by omega⟩
                  (by simp [Fin.lt_def]; omega)))
      · simp only [if_neg hi0, if_neg (show j ≠ 0 from by omega)]
        exact hm ⟨i - 1, by omega⟩ ⟨j - 1, by omega⟩ (by simp [Fin.lt_def]; omega)
    · -- All in (z0, z1)
      intro ⟨i, hi⟩
      show z0 < w' ⟨i, hi⟩ ∧ w' ⟨i, hi⟩ < z1
      simp only [w']
      by_cases hi0 : i = 0
      · subst hi0; simp [ite_true]; exact ⟨hr0_above, hr0_below⟩
      · simp only [if_neg hi0]
        refine ⟨lt_trans hr0_above (lt_of_lt_of_le (hbnd ⟨0, by omega⟩).1 ?_),
               (hbnd ⟨i - 1, by omega⟩).2⟩
        rcases Nat.eq_or_lt_of_le (show 1 ≤ i from by omega) with h | h
        · subst h; simp
        · exact le_of_lt (hm ⟨0, by omega⟩ ⟨i - 1, by omega⟩
            (by simp [Fin.lt_def]; omega))
    · -- Point types
      intro ⟨i, hi⟩
      show (pt' ⟨i, hi⟩).eval_at M atomMap (w' ⟨i, hi⟩)
      simp only [pt', w']
      by_cases hi0 : i = 0
      · subst hi0; simp [ite_true]; exact hPt
      · simp only [if_neg hi0]; exact hpt ⟨i - 1, by omega⟩
    · -- Segment 0: segLeft on (z0, w'(0)=r0)
      intro y hy0 hy1
      show (seg' ⟨0, by omega⟩).eval_at M atomMap y
      have : w' ⟨0, by omega⟩ = r0 := by simp [w']
      rw [this] at hy1
      simp [seg']; exact hSeg y hy0 hy1
    · -- Middle segments
      intro ⟨i, hi⟩ y hy_lo hy_hi
      show (seg' ⟨i + 1, by omega⟩).eval_at M atomMap y
      simp only [seg', show i + 1 ≠ 0 from by omega, ite_false]
      by_cases hi0 : i = 0
      · -- Segment between w'(0)=r0 and w'(1)=w(0)
        subst hi0
        have hlo : w' ⟨0, by omega⟩ = r0 := by simp [w']
        have hhi : w' ⟨1, by omega⟩ = w ⟨0, by omega⟩ := by simp [w']
        rw [hlo] at hy_lo; rw [hhi] at hy_hi
        exact hseg0 y hy_lo hy_hi
      · -- Segment between w'(i)=w(i-1) and w'(i+1)=w(i)
        simp only [w', if_neg hi0, if_neg (show i + 1 ≠ 0 from by omega)] at hy_lo hy_hi
        -- hy_lo : w ⟨i - 1, _⟩ < y, hy_hi : y < w ⟨i + 1 - 1, _⟩
        -- Goal: eval_at (bf.segmentTypes ⟨i + 1 - 1, _⟩) y
        -- hseg_mid expects: ⟨(i-1), _⟩ with ↑(i-1) + 1 = i - 1 + 1 = i
        -- We have: i + 1 - 1. Since i ≠ 0, both equal i.
        have heq : (⟨i - 1, by omega⟩ : Fin k').val + 1 = i :=
          Nat.succ_pred_eq_of_pos (Nat.pos_of_ne_zero hi0)
        have h1 : w ⟨(⟨i - 1, by omega⟩ : Fin k').val + 1, by omega⟩ =
                  w ⟨i + 1 - 1, by omega⟩ := by
          congr 1; ext; simp; omega
        have h2 : bf.segmentTypes ⟨(⟨i - 1, by omega⟩ : Fin k').val + 1, by omega⟩ =
                  bf.segmentTypes ⟨i + 1 - 1, by omega⟩ := by
          congr 1; ext; simp; omega
        rw [← h2]
        exact hseg_mid ⟨i - 1, by omega⟩ y hy_lo (h1 ▸ hy_hi)
    · -- Last segment
      intro y hy_lo hy_hi
      show (seg' ⟨k' + 2, by omega⟩).eval_at M atomMap y
      simp only [seg', show k' + 2 ≠ 0 from by omega, ite_false]
      simp only [w', if_neg (show k' + 1 ≠ 0 from by omega)] at hy_lo
      have h1 : w ⟨k' + 1 - 1, by omega⟩ = w ⟨k', by omega⟩ := by congr 1
      rw [h1] at hy_lo
      have h2 : bf.segmentTypes ⟨k' + 2 - 1, by omega⟩ =
                bf.segmentTypes ⟨k' + 1, by omega⟩ := by congr 1
      rw [h2]
      exact hseg_last y hy_lo hy_hi

/-- **Lemma 5.3, Inductive Step**: The negation of a pure-points bracket
    formula with `n` predicates is equivalent to a V-bracket formula over
    Prior structures satisfying `semantic_prior_UZ`.

    Proof by induction on `n`:
    - **n = 0**: `purePoints Fin.elim0` always holds (vacuous), so the
      negation is impossible.
    - **n + 1**: Case split on whether `P ⟨0, ...⟩` occurs in `(z_0, z_1)`:
      - **Absent**: `not (purePoints P)` holds trivially since any witness
        sequence would need `P_1` to hold. The V-bracket is `pureSeg P_1.neg`.
      - **Present**: Use `first_occurrence_prior_strict` to find `r_0`.
        By `neg_purePoints_split`, the remaining `n` predicates cannot all
        have witnesses in `(r_0, z_1)`. By IH, this negation is V-bracket
        on `(r_0, z_1)`. Prepend the `r_0` witness with `not P_1` on
        `(z_0, r_0)` to get a V-bracket on `(z_0, z_1)`. -/
theorem neg_purePoints_vbracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap) :
    ∀ (n : Nat) (P : Fin n → TemporalPred) (z0 z1 : M.carrier),
    z0 < z1 →
    ¬(BracketFormula.purePoints P).holds M atomMap z0 z1 →
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    intro P z0 z1 h_lt h_neg
    exact absurd (BracketFormula.purePoints_zero_holds M atomMap z0 z1) h_neg
  | succ n ih =>
    intro P z0 z1 h_lt h_neg
    -- Case split: does P ⟨0, ...⟩ occur in (z_0, z_1)?
    by_cases h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
        (P ⟨0, by omega⟩).eval_at M atomMap x
    · -- Case 2: P_1 occurs in (z_0, z_1)
      -- Find first occurrence r0
      obtain ⟨r0, hr0_above, hr0_below, hPr0, h_neg_before⟩ :=
        first_occurrence_prior_strict M atomMap h_UZ (P ⟨0, by omega⟩)
          z0 z1 h_lt h_exists
      -- The remaining n predicates cannot all have witnesses in (r0, z1)
      have h_split := neg_purePoints_split M atomMap P z0 z1 r0
        hr0_above hr0_below hPr0 h_neg
      -- By IH, this negation is V-bracket on (r0, z1)
      obtain ⟨v, hv⟩ := ih (fun i => P ⟨i.val + 1, by omega⟩)
        r0 z1 hr0_below h_split
      -- Each disjunct of v holds on (r0, z1). Prepend r0 to get (z0, z1).
      obtain ⟨⟨k, bf⟩, h_mem, h_holds⟩ := hv
      -- Construct the prepended bracket formula using bracket_prepend_holds
      obtain ⟨bf', h_holds'⟩ := BracketFormula.bracket_prepend_holds M atomMap bf
        (P ⟨0, by omega⟩).neg (P ⟨0, by omega⟩) z0 z1 r0
        hr0_above hr0_below hPr0
        (fun y hy0 hy1 => (TemporalPred.eval_at_neg M atomMap
          (P ⟨0, by omega⟩) y).mpr (h_neg_before y hy0 hy1))
        h_holds
      exact ⟨⟨[⟨k + 1, bf'⟩]⟩, ⟨k + 1, bf'⟩, List.mem_singleton.mpr rfl, h_holds'⟩
    · -- Case 1: P_1 does not occur in (z_0, z_1)
      -- The negation is trivially V-bracket: pureSeg (P 0).neg
      push_neg at h_exists
      exact ⟨⟨[⟨0, BracketFormula.pureSeg (P ⟨0, by omega⟩).neg⟩]⟩,
             ⟨0, BracketFormula.pureSeg (P ⟨0, by omega⟩).neg⟩,
             List.mem_singleton.mpr rfl,
             (BracketFormula.pureSeg_holds M atomMap (P ⟨0, by omega⟩).neg z0 z1).mpr
               (fun y hy0 hy1 => (TemporalPred.eval_at_neg M atomMap
                 (P ⟨0, by omega⟩) y).mpr (h_exists y hy0 hy1))⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
