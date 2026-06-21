import Bimodal.Metalogic.WeakCanonical.Kamp.EANegation
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
# EA Negation Closure (Model-Dependent, Forward-Only)

Proves Lemma 5.1 and Corollary 5.4 of Rabinovich 2014 in model-dependent,
forward-only form. These avoid the structurally unsolvable beta_0(r_0) problem
that blocks the biconditional approach in `EANegation.lean`.

## Key Theorems

- `neg_interval_formula`: Lemma 5.1 forward — if ¬bf.holds z0 z1 on a Prior
  structure, there exists a VBracketFormula that holds on (z0, z1).
- `neg_bounded_exists`: Corollary 5.4 forward — if ¬(∃z, bf.holds z0 z) on
  a Prior structure, there exists a VBracketFormula that holds on (z0, z1).

## Provenance

Ported from Boneyard/KampNegationClosure/NegationClosure5.lean (archived 2026-06-16).
Adapted to use `HasAttainedINF` instead of raw `semantic_prior_UZ`.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.1 (pp.7-11), Corollary 5.4 (p.10)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Helper: TemporalPred.eval_at_neg -/

/-- `(P.neg).eval_at` iff `¬(P.eval_at)`. -/
theorem TemporalPred.eval_at_neg' {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (t : M.carrier) :
    P.neg.eval_at M atomMap t ↔ ¬P.eval_at M atomMap t := by
  simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]

/-! ## Helper: HasAttainedINF.first_occ_tp

Wraps `HasAttainedINF.first_occ` to accept a `TemporalPred` directly. -/

/-- First occurrence of a temporal predicate P in (z0, z1) on structures with
    attained infima. Wraps `HasAttainedINF.first_occ` using `P.formula`. -/
theorem HasAttainedINF.first_occ_tp {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x) :
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      P.eval_at M atomMap r0 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → ¬P.eval_at M atomMap y) := by
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
    (hPt : (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap r0)
    (hSeg : ∀ y : M.carrier, z0 < y → y < r0 →
      (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y)
    (h_tail : bf.tail.holds M atomMap r0 z) :
    bf.holds M atomMap z0 z := by
  show bf.toIntervalPattern.holds M atomMap z0 z
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
        simp only [BracketFormula.toIntervalPattern, BracketFormula.tail] at h
        convert h using 2
        simp [Fin.ext_iff]; omega
    · -- Segment 0
      intro y hy0 hy1
      simp only [show (0 : Nat) = 0 from rfl, dite_true] at hy1
      exact hSeg y hy0 hy1
    · -- Middle segments
      intro ⟨i, hi⟩ y hy_lo hy_hi
      by_cases h0 : i = 0
      · subst h0
        simp only [show (0 : Nat) = 0 from rfl, dite_true] at hy_lo
        simp only [show ¬((0 : Nat) + 1 = 0) from by omega, dite_false] at hy_hi
        exact hseg0 y hy_lo hy_hi
      · simp only [show ¬(i = 0) from h0, dite_false, show ¬(i + 1 = 0) from by omega,
                    dite_false] at hy_lo hy_hi
        have h := hseg_mid ⟨i - 1, by omega⟩ y hy_lo
          (by convert hy_hi using 2; congr 1; simp [Fin.ext_iff]; omega)
        convert h using 2; congr 1; simp [Fin.ext_iff]; omega
    · -- Last segment
      intro y hy_lo hy_hi
      simp only [show ¬(n' + 1 = 0) from by omega, dite_false] at hy_lo
      exact hseg_last y hy_lo hy_hi

/-! ## INF bracket formula

The bracket formula [not P, P, True](z_0, z_1) describing the first occurrence
of P in (z_0, z_1). -/

/-- The INF bracket formula: [not P, P, True](z_0, z_1). -/
def inf_bracket_formula (P : TemporalPred) : BracketFormula 1 :=
  { pointTypes := fun _ => P
    segmentTypes := fun i => if i.val = 0 then P.neg else TemporalPred.top }

/-- The INF bracket formula holds iff there exists a first-occurrence witness. -/
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

/-- On structures with HasAttainedINF, if P occurs in (z_0, z_1), the INF bracket
    formula holds. -/
theorem inf_bracket_formula_hasINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x) :
    (inf_bracket_formula P).holds M atomMap z0 z1 := by
  rw [inf_bracket_formula_holds]
  obtain ⟨r0, hr0_above, hr0_strict, hPr0, h_neg⟩ :=
    h_INF.first_occ_tp P z0 z1 h_lt h_exists
  exact ⟨r0, hr0_above, hr0_strict, hPr0, fun y hy0 hy1 =>
    (TemporalPred.eval_at_neg' M atomMap P y).mpr (h_neg y hy0 hy1)⟩

/-- The INF formula produces a VBracketFormula witnessing the first occurrence. -/
theorem inf_formula_is_vbracket {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.eval_at M atomMap x) :
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1 :=
  ⟨⟨[⟨1, inf_bracket_formula P⟩]⟩,
   ⟨1, inf_bracket_formula P⟩,
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
    push_neg at h_neg
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
        (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap x
    · -- Case B: pointTypes(0) occurs in (z0, z1)
      obtain ⟨r0, hr0_above, hr0_below, hPr0, h_neg_before⟩ :=
        h_INF.first_occ_tp (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
      -- Check whether segmentTypes(0) holds on (z0, r0)
      by_cases h_seg : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
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
      push_neg at h_exists
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
          ¬(bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
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
        push_neg at h_seg_fail
        exact ⟨z', hz0', hz1', by
          simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
          intro y hy0 hy1
          exact h_seg_fail y hy0 (lt_trans hy1 hz1')⟩
    · -- (z0, z1) is empty: trivial V-bracket holds vacuously
      push_neg at h_nonempty
      exact ⟨⟨[⟨0, BracketFormula.trivial TemporalPred.top⟩]⟩,
             ⟨0, BracketFormula.trivial TemporalPred.top⟩,
             List.mem_singleton.mpr rfl,
             (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
               (fun y hy0 hy1 => absurd hy1 (not_lt.mpr (h_nonempty y hy0)))⟩
  | succ n ih =>
    intro bf z0 z1 h_lt h_neg
    -- Case split: does pointTypes(0) occur in (z0, z1)?
    by_cases h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
        (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap x
    · -- Case B: pointTypes(0) occurs in (z0, z1)
      obtain ⟨r0, hr0_above, hr0_below, hPr0, h_neg_before⟩ :=
        h_INF.first_occ_tp (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
      -- Check whether segmentTypes(0) holds on (z0, r0)
      by_cases h_seg : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
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
      push_neg at h_exists
      exact ⟨⟨[⟨0, BracketFormula.trivial (bf.pointTypes ⟨0, by omega⟩).neg⟩]⟩,
             ⟨0, BracketFormula.trivial (bf.pointTypes ⟨0, by omega⟩).neg⟩,
             List.mem_singleton.mpr rfl,
             (BracketFormula.trivial_holds M atomMap
               (bf.pointTypes ⟨0, by omega⟩).neg z0 z1).mpr
               (fun y hy0 hy1 => (TemporalPred.eval_at_neg' M atomMap
                 (bf.pointTypes ⟨0, by omega⟩) y).mpr (h_exists y hy0 hy1))⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
