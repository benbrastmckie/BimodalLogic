import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
# Model-Independent Negation Closure via Disjunction Construction

Constructs model-independent versions of Lemma 5.1 and Proposition 4.2
from Rabinovich 2014. The model-dependent versions in `EANegationClosure.lean`
use `by_cases` on model-specific predicates, producing existential witnesses
that vary per model. This file builds FIXED syntactic formulas (VBracketFormula
and VVecEA2) whose correctness on each model follows from the model-dependent
theorems.

## Key Insight (Disjunction Construction)

The model-dependent `neg_interval_formula` case-splits on:
- Case A: pointTypes(0) does NOT occur in (z0, z1)
- Case B1: pointTypes(0) occurs AND segmentTypes(0) holds on (z0, r0)
- Case B2: pointTypes(0) occurs AND segmentTypes(0) fails on (z0, r0)

The model-independent version constructs ALL three V-bracket formulas and takes
their disjunction. Each formula is a syntactic object independent of any model.
The disjunction covers all models because the three cases are exhaustive.

## Main Results

- `neg_interval_formula_indep`: Model-independent Lemma 5.1 -- constructs a fixed
  VBracketFormula whose negation-closure correctness holds on all Prior structures.
- `neg_vecEA2_indep`: Model-independent single-conjunct negation.
- `neg_2var_vec_ea_indep`: Model-independent Prop 4.2.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.1 (pp.7-11), Prop 4.2 (p.6)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Model-Independent Lemma 5.1: neg_interval_formula_indep

Constructs a fixed VBracketFormula for the negation of any BracketFormula.
The construction mirrors the three cases of the model-dependent proof but
builds all cases syntactically and takes their disjunction. -/

/-- Model-independent negation of a bracket formula (Lemma 5.1).

    Given a bracket formula `bf` with `n` witnesses, returns a VBracketFormula `v`
    such that for any Prior structure with HasAttainedINF, if `¬bf.holds z0 z1`
    then `v.holds z0 z1`.

    Construction by induction on `n`:
    - `n = 0`: A single 1-witness bracket asserting `segmentTypes(0).neg` at
      some interior point.
    - `n + 1`: Disjunction of three cases:
      - Case A: 0-witness bracket with `pointTypes(0).neg` everywhere
      - Case B1: Prepend `pointTypes(0)` witness to IH result for `bf.tail`
      - Case B2: INF bracket for first occurrence of `pointTypes(0)` -/
def neg_interval_formula_indep : (n : Nat) → BracketFormula n → VBracketFormula
  | 0, bf =>
    -- Negation of ∀ y ∈ (z0,z1), segTypes(0)(y) is:
    -- ∃ y ∈ (z0,z1), ¬segTypes(0)(y)
    -- Represented as a 1-witness bracket [segTypes(0).neg, top, top]
    let neg_seg : BracketFormula 1 :=
      { pointTypes := fun _ => (bf.segmentTypes ⟨0, by omega⟩).neg
        segmentTypes := fun _ => TemporalPred.top }
    ⟨[⟨1, neg_seg⟩]⟩
  | n + 1, bf =>
    -- Case A: pointTypes(0) does not occur in (z0, z1)
    let caseA : VBracketFormula :=
      ⟨[⟨0, BracketFormula.trivial (bf.pointTypes ⟨0, by omega⟩).neg⟩]⟩
    -- Case B1: pointTypes(0) occurs, segTypes(0) holds on prefix, tail negated
    -- Recursively get the IH for bf.tail, then prepend witness
    let ih := neg_interval_formula_indep n bf.tail
    let caseB1 : VBracketFormula :=
      VBracketFormula.prependAll (bf.pointTypes ⟨0, by omega⟩).neg
        (bf.pointTypes ⟨0, by omega⟩) ih
    -- Case B2: pointTypes(0) occurs (INF bracket)
    let caseB2 : VBracketFormula :=
      ⟨[⟨1, inf_bracket_formula (bf.pointTypes ⟨0, by omega⟩)⟩]⟩
    -- Disjunction of all three cases
    ⟨caseA.disjuncts ++ caseB1.disjuncts ++ caseB2.disjuncts⟩

/-- Correctness of `neg_interval_formula_indep` (Lemma 5.1, model-independent):
    For any Prior structure with `HasAttainedINF`, if a bracket formula fails
    on `(z0, z1)`, the constructed VBracketFormula holds on `(z0, z1)`. -/
theorem neg_interval_formula_indep_correct :
    ∀ (n : Nat) (bf : BracketFormula n),
    ∀ {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
      (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 →
      ¬bf.holds M atomMap z0 z1 →
      (neg_interval_formula_indep n bf).holds M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    intro bf sig M atomMap _h_INF z0 z1 _h_lt h_neg
    -- bf.holds = ∀ y ∈ (z0, z1), segmentTypes(0)(y)
    -- Negation: ∃ y ∈ (z0, z1), ¬segmentTypes(0)(y)
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
               IntervalPattern.holds] at h_neg
    push_neg at h_neg
    obtain ⟨y, hy0, hy1, h_neg_y⟩ := h_neg
    -- The 1-witness bracket [segTypes(0).neg, top, top] holds with witness y
    simp only [neg_interval_formula_indep, VBracketFormula.holds]
    refine ⟨⟨1, _⟩, List.mem_singleton.mpr rfl, ?_⟩
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
    intro bf sig M atomMap h_INF z0 z1 h_lt h_neg
    simp only [neg_interval_formula_indep, VBracketFormula.holds]
    -- Case split on whether pointTypes(0) occurs in (z0, z1)
    by_cases h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
        (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap x
    · -- Cases B1 and B2: pointTypes(0) occurs
      obtain ⟨r0, hr0_above, hr0_below, hPr0, h_neg_before⟩ :=
        h_INF.first_occ_tp (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
      by_cases h_seg : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
      · -- Case B1: segmentTypes(0) holds on (z0, r0), tail must fail
        have h_tail_neg : ¬bf.tail.holds M atomMap r0 z1 := by
          intro h_tail
          exact h_neg (bracket_tail_satisfiable M atomMap bf z0 z1 r0
            hr0_above hr0_below hPr0 h_seg h_tail)
        -- By IH, the neg_interval_formula_indep for the tail holds on (r0, z1)
        have h_ih := ih bf.tail M atomMap h_INF r0 z1 hr0_below h_tail_neg
        -- The IH VBracketFormula holds on (r0, z1)
        obtain ⟨⟨k, bf_v⟩, h_mem, h_holds⟩ := h_ih
        -- Prepend r0 with pointTypes(0).neg on (z0, r0) and pointTypes(0) at r0
        have h_holds' := BracketFormula.prepend_holds M atomMap bf_v
          (bf.pointTypes ⟨0, by omega⟩).neg (bf.pointTypes ⟨0, by omega⟩) z0 z1 r0
          hr0_above hr0_below hPr0
          (fun y hy0 hy1 => (TemporalPred.eval_at_neg' M atomMap
            (bf.pointTypes ⟨0, by omega⟩) y).mpr (h_neg_before y hy0 hy1))
          h_holds
        -- The prepended formula is in the caseB1 disjuncts
        refine ⟨⟨k + 1, bf_v.prepend (bf.pointTypes ⟨0, by omega⟩).neg
          (bf.pointTypes ⟨0, by omega⟩)⟩, ?_, h_holds'⟩
        -- Membership: caseA ++ caseB1 ++ caseB2, need caseB1
        -- (A ++ B1) ++ B2: left then right for B1
        simp only [VBracketFormula.prependAll, List.mem_append, List.mem_map]
        left; right
        exact ⟨⟨k, bf_v⟩, h_mem, rfl⟩
      · -- Case B2: segmentTypes(0) fails on (z0, r0) → INF bracket
        have h_inf := inf_bracket_formula_hasINF h_INF
          (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
        refine ⟨⟨1, inf_bracket_formula (bf.pointTypes ⟨0, by omega⟩)⟩, ?_, h_inf⟩
        -- Membership: (A ++ B1) ++ B2, need B2 -- right
        simp only [List.mem_append]
        right
        exact List.mem_singleton.mpr rfl
    · -- Case A: pointTypes(0) does not occur in (z0, z1)
      push_neg at h_exists
      refine ⟨⟨0, BracketFormula.trivial (bf.pointTypes ⟨0, by omega⟩).neg⟩, ?_, ?_⟩
      · -- Membership: (A ++ B1) ++ B2, need A -- left then left
        simp only [List.mem_append]
        left; left
        exact List.mem_singleton.mpr rfl
      · exact (BracketFormula.trivial_holds M atomMap
          (bf.pointTypes ⟨0, by omega⟩).neg z0 z1).mpr
          (fun y hy0 hy1 => (TemporalPred.eval_at_neg' M atomMap
            (bf.pointTypes ⟨0, by omega⟩) y).mpr (h_exists y hy0 hy1))

/-! ## Model-Independent Proposition 4.2: VecEA2 / VVecEA2 Negation

Lift `neg_interval_formula_indep` to VecEA2 and VVecEA2 formulas.
The structure mirrors `neg_vecEA2` and `neg_2var_vec_ea` from
EANegationClosure.lean but produces fixed syntactic objects. -/

/-- Model-independent negation of a single VecEA2 conjunct.

    The negation of `endpointLeft(z0) ∧ endpointRight(z1) ∧ bracket(z0,z1)`
    decomposes via de Morgan into three cases:
    - endpointLeft fails → trivial VVecEA2 with negated left endpoint
    - endpointRight fails → trivial VVecEA2 with negated right endpoint
    - both endpoints hold, bracket fails → apply `neg_interval_formula_indep`
      to get VBracketFormula, wrap with original endpoints -/
def neg_vecEA2_indep {n : Nat} (vea : VecEA2 n) : VVecEA2 :=
  let trivBf := BracketFormula.trivial TemporalPred.top
  -- Case 1a: endpointLeft fails
  let vea1a : VecEA2 0 := VecEA2.mk vea.endpointLeft.neg TemporalPred.top trivBf
  let case1a : VVecEA2 := ⟨[⟨0, vea1a⟩]⟩
  -- Case 1b: endpointRight fails
  let vea1b : VecEA2 0 := VecEA2.mk TemporalPred.top vea.endpointRight.neg trivBf
  let case1b : VVecEA2 := ⟨[⟨0, vea1b⟩]⟩
  -- Case 2+3: both endpoints hold, bracket fails
  let neg_bf := neg_interval_formula_indep n vea.bracket
  let case23 := neg_bf.toVVecEA2WithEndpoints vea.endpointLeft vea.endpointRight
  -- Disjunction of all cases
  ⟨case1a.disjuncts ++ case1b.disjuncts ++ case23.disjuncts⟩

/-- Correctness of `neg_vecEA2_indep`: if a VecEA2 formula fails, the
    constructed VVecEA2 holds. -/
theorem neg_vecEA2_indep_correct {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    {n : Nat} (vea : VecEA2 n) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_neg : ¬vea.holds M atomMap z0 z1) :
    (neg_vecEA2_indep vea).holds M atomMap z0 z1 := by
  simp only [VecEA2.holds] at h_neg
  push_neg at h_neg
  -- The result neg_vecEA2_indep is a disjunction of case1a ++ case1b ++ case23 disjuncts
  -- We unfold one level and work with VVecEA2.holds directly
  unfold neg_vecEA2_indep
  by_cases hL : vea.endpointLeft.eval_at M atomMap z0
  · by_cases hR : vea.endpointRight.eval_at M atomMap z1
    · -- Case 2+3: both endpoints hold, bracket fails
      have h_neg_bracket : ¬vea.bracket.holds M atomMap z0 z1 := h_neg hL hR
      have h_bf := neg_interval_formula_indep_correct n vea.bracket M atomMap h_INF z0 z1
        h_lt h_neg_bracket
      obtain ⟨⟨k, bf_v⟩, h_mem, h_holds⟩ := h_bf
      simp only [VVecEA2.holds]
      let vea_neg : VecEA2 k := VecEA2.mk vea.endpointLeft vea.endpointRight bf_v
      refine ⟨⟨k, vea_neg⟩, ?_, hL, hR, h_holds⟩
      -- Membership: ([1a] ++ [1b]) ++ case23, need case23 -- right
      simp only [VBracketFormula.toVVecEA2WithEndpoints, List.mem_append, List.mem_map]
      right
      exact ⟨⟨k, bf_v⟩, h_mem, rfl⟩
    · -- Case 1b: endpointRight fails
      simp only [VVecEA2.holds]
      let vea1b : VecEA2 0 := VecEA2.mk TemporalPred.top vea.endpointRight.neg
        (BracketFormula.trivial TemporalPred.top)
      refine ⟨⟨0, vea1b⟩, ?_,
              TemporalPred.eval_at_top M atomMap z0,
              (TemporalPred.eval_at_neg' M atomMap vea.endpointRight z1).mpr hR, ?_⟩
      · -- Membership: ([1a] ++ [1b]) ++ case23, need [1b] -- left then right
        rw [List.mem_append]; left
        rw [List.mem_append]; right
        exact List.mem_singleton.mpr rfl
      · exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
          (fun y _ _ => TemporalPred.eval_at_top M atomMap y)
  · -- Case 1a: endpointLeft fails
    simp only [VVecEA2.holds]
    let vea1a : VecEA2 0 := VecEA2.mk vea.endpointLeft.neg TemporalPred.top
      (BracketFormula.trivial TemporalPred.top)
    refine ⟨⟨0, vea1a⟩, ?_,
            (TemporalPred.eval_at_neg' M atomMap vea.endpointLeft z0).mpr hL,
            TemporalPred.eval_at_top M atomMap z1, ?_⟩
    · -- Membership: ([1a] ++ [1b]) ++ case23, need [1a] -- left then left
      rw [List.mem_append]; left
      rw [List.mem_append]; left
      exact List.mem_singleton.mpr rfl
    · exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
        (fun y _ _ => TemporalPred.eval_at_top M atomMap y)

/-- A trivially-true VecEA2: holds on any (z0, z1) with z0 < z1. -/
private def trivialTrueVecEA2 : VecEA2 0 :=
  VecEA2.mk TemporalPred.top TemporalPred.top (BracketFormula.trivial TemporalPred.top)

/-- A trivially-true VVecEA2: holds on any (z0, z1) with z0 < z1. -/
private def VVecEA2.trivialTrue : VVecEA2 :=
  ⟨[⟨0, trivialTrueVecEA2⟩]⟩

private theorem VVecEA2.trivialTrue_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    VVecEA2.trivialTrue.holds M atomMap z0 z1 := by
  refine ⟨⟨0, trivialTrueVecEA2⟩, List.mem_singleton.mpr rfl,
          TemporalPred.eval_at_top M atomMap z0,
          TemporalPred.eval_at_top M atomMap z1, ?_⟩
  exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
    (fun y _ _ => TemporalPred.eval_at_top M atomMap y)

/-- Model-independent negation of a disjunct list: iterate `neg_vecEA2_indep`
    and conjoin the results. -/
private def neg_disjunct_list_indep
    (ds : List (Σ n, VecEA2 n)) : VVecEA2 :=
  match ds with
  | [] => VVecEA2.trivialTrue
  | d :: ds' =>
    VVecEA2.conj_struct (neg_vecEA2_indep d.2) (neg_disjunct_list_indep ds')

/-- Correctness of `neg_disjunct_list_indep`. -/
private theorem neg_disjunct_list_indep_correct {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (ds : List (Σ n, VecEA2 n))
    (h_neg : ∀ d ∈ ds, ¬d.2.holds M atomMap z0 z1) :
    (neg_disjunct_list_indep ds).holds M atomMap z0 z1 := by
  induction ds with
  | nil =>
    simp only [neg_disjunct_list_indep]
    exact VVecEA2.trivialTrue_holds M atomMap z0 z1
  | cons d ds' ih =>
    simp only [neg_disjunct_list_indep]
    have h_neg_d : ¬d.2.holds M atomMap z0 z1 :=
      h_neg d (List.mem_cons_self ..)
    have h_neg_rest : ∀ d' ∈ ds', ¬d'.2.holds M atomMap z0 z1 :=
      fun d' hm => h_neg d' (List.mem_cons_of_mem d hm)
    exact VVecEA2.conj_struct_holds M atomMap _ _ z0 z1
      (neg_vecEA2_indep_correct h_INF d.2 z0 z1 h_lt h_neg_d)
      (ih h_neg_rest)

/-- **Proposition 4.2** (model-independent): The negation of a `VVecEA2` formula
    produces a fixed `VVecEA2` formula that holds on any structure with
    `HasAttainedINF` where the original formula fails.

    This is the model-independent version of `neg_2var_vec_ea` from
    EANegationClosure.lean. -/
def neg_2var_vec_ea_indep (v : VVecEA2) : VVecEA2 :=
  neg_disjunct_list_indep v.disjuncts

/-- Correctness of `neg_2var_vec_ea_indep`. -/
theorem neg_2var_vec_ea_indep_correct {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_neg : ¬v.holds M atomMap z0 z1) :
    (neg_2var_vec_ea_indep v).holds M atomMap z0 z1 := by
  simp only [neg_2var_vec_ea_indep]
  simp only [VVecEA2.holds] at h_neg
  push_neg at h_neg
  exact neg_disjunct_list_indep_correct h_INF z0 z1 h_lt v.disjuncts h_neg

-- NOTE: The backward direction (neg_2var_vec_ea_indep_backward) was attempted
-- but found to be unprovable with the current construction. See plan v31
-- Phase 1 BLOCKER documentation for details. The case B.2 (inf_bracket_formula)
-- in neg_interval_formula_indep is NOT disjoint from the original bracket formula.
-- A concrete counterexample: bf with pt(0)=P, all segments=top on (0,10) with
-- P holding only at 5 makes both bf.holds (witness 5) and
-- inf_bracket_formula(P).holds (witness 5, P.neg on (0,5)) true simultaneously.

end Bimodal.Metalogic.WeakCanonical.Kamp
