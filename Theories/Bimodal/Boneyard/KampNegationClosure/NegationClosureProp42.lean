-- ARCHIVED from Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean
-- Reason: Dead code — negation closure chain with no live downstream consumers
-- Archived: 2026-06-16 (task 302)

import Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure5

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Proposition 4.2: Negation Closure for 2-Free-Variable Vec-EA Formulas

Proves that the negation of a VecEA2 (and VVecEA2) formula is equivalent to
a VVecEA2 formula over Prior structures. This is Rabinovich 2014, Proposition 4.2.

## Mathematical Content

A `VecEA2 n` formula has the form:
  `endpointLeft(z_0) ∧ endpointRight(z_1) ∧ [bracket](z_0, z_1)`

Its negation decomposes via de Morgan into three cases:
1. `¬endpointLeft(z_0)` — a single-disjunct VVecEA2 with negated left endpoint
2. `¬endpointRight(z_1)` — a single-disjunct VVecEA2 with negated right endpoint
3. `endpointLeft(z_0) ∧ endpointRight(z_1) ∧ ¬bracket(z_0, z_1)` — uses
   `neg_interval_formula` (Lemma 5.1) to express ¬bracket as a V-bracket formula,
   then wraps each disjunct with the original endpoint predicates

For `VVecEA2` (disjunction of VecEA2's), de Morgan gives a conjunction of
negations, handled by induction on the disjunct list using conjunction closure.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 4.2 (p. 6)
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Helper: Lift VBracketFormula to VVecEA2

Given a V-bracket formula (disjunction of BracketFormulas) and endpoint predicates,
construct a VVecEA2 by wrapping each bracket disjunct with the endpoints. -/

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
    (hL : epL.eval_at M atomMap z0)
    (hR : epR.eval_at M atomMap z1)
    (hv : v.holds M atomMap z0 z1) :
    (v.toVVecEA2WithEndpoints epL epR).holds M atomMap z0 z1 := by
  obtain ⟨⟨n, bf⟩, hmem, hbf⟩ := hv
  refine ⟨⟨n, { endpointLeft := epL, endpointRight := epR, bracket := bf }⟩, ?_, hL, hR, hbf⟩
  simp only [toVVecEA2WithEndpoints]
  exact List.mem_map.mpr ⟨⟨n, bf⟩, hmem, rfl⟩

/-! ## Negation of a Single VecEA2 (Prop 4.2, single conjunct)

The negation of `endpointLeft(z_0) ∧ endpointRight(z_1) ∧ bracket(z_0, z_1)`
is handled by three cases via de Morgan. -/

/-- **Proposition 4.2 (single conjunct)**: The negation of a `VecEA2` formula
    is equivalent to a `VVecEA2` formula over Prior structures. -/
theorem neg_vecEA2 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (n : Nat) (vea : VecEA2 n) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_neg : ¬vea.holds M atomMap z0 z1) :
    ∃ v : VVecEA2, v.holds M atomMap z0 z1 := by
  -- vea.holds = endpointLeft(z0) ∧ endpointRight(z1) ∧ bracket.holds z0 z1
  simp only [VecEA2.holds] at h_neg
  push_neg at h_neg
  -- Three cases via de Morgan
  by_cases hL : vea.endpointLeft.eval_at M atomMap z0
  · by_cases hR : vea.endpointRight.eval_at M atomMap z1
    · -- Case 3: endpointLeft and endpointRight hold, bracket fails
      have h_neg_bracket : ¬vea.bracket.holds M atomMap z0 z1 := h_neg hL hR
      -- Apply Lemma 5.1 (neg_interval_formula) to get V-bracket
      obtain ⟨vbf, hvbf⟩ := neg_interval_formula M atomMap h_UZ n vea.bracket z0 z1 h_lt h_neg_bracket
      -- Wrap with original endpoints
      exact ⟨vbf.toVVecEA2WithEndpoints vea.endpointLeft vea.endpointRight,
             vbf.toVVecEA2WithEndpoints_holds M atomMap
               vea.endpointLeft vea.endpointRight z0 z1 hL hR hvbf⟩
    · -- Case 2: endpointRight fails
      -- Construct VVecEA2 with negated right endpoint and trivial bracket
      refine ⟨⟨[⟨0, { endpointLeft := TemporalPred.top,
                       endpointRight := vea.endpointRight.neg,
                       bracket := BracketFormula.pureSeg TemporalPred.top }⟩]⟩,
              ⟨0, _⟩, List.mem_singleton.mpr rfl,
              TemporalPred.eval_at_top M atomMap z0,
              (TemporalPred.eval_at_neg M atomMap vea.endpointRight z1).mpr hR,
              ?_⟩
      exact (BracketFormula.pureSeg_holds M atomMap TemporalPred.top z0 z1).mpr
        (fun y _ _ => TemporalPred.eval_at_top M atomMap y)
  · -- Case 1: endpointLeft fails
    refine ⟨⟨[⟨0, { endpointLeft := vea.endpointLeft.neg,
                     endpointRight := TemporalPred.top,
                     bracket := BracketFormula.pureSeg TemporalPred.top }⟩]⟩,
            ⟨0, _⟩, List.mem_singleton.mpr rfl,
            (TemporalPred.eval_at_neg M atomMap vea.endpointLeft z0).mpr hL,
            TemporalPred.eval_at_top M atomMap z1,
            ?_⟩
    exact (BracketFormula.pureSeg_holds M atomMap TemporalPred.top z0 z1).mpr
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y)

/-! ## Negation of VVecEA2 (Prop 4.2, full statement)

The negation of a `VVecEA2` (disjunction of VecEA2's) uses de Morgan to get
a conjunction of negations, then applies conjunction closure inductively. -/

/-- Helper: the negation of a conjunction of VecEA2 negations (for a list of disjuncts)
    produces a VVecEA2. By induction on the list of disjuncts. -/
private theorem neg_disjunct_list {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (ds : List (Σ n, VecEA2 n))
    (h_neg : ∀ d ∈ ds, ¬d.2.holds M atomMap z0 z1) :
    ∃ v : VVecEA2, v.holds M atomMap z0 z1 := by
  induction ds with
  | nil =>
    -- Empty list: produce a trivially-true VVecEA2
    refine ⟨⟨[⟨0, { endpointLeft := TemporalPred.top,
                     endpointRight := TemporalPred.top,
                     bracket := BracketFormula.pureSeg TemporalPred.top }⟩]⟩,
            ⟨0, _⟩, List.mem_singleton.mpr rfl,
            TemporalPred.eval_at_top M atomMap z0,
            TemporalPred.eval_at_top M atomMap z1,
            ?_⟩
    exact (BracketFormula.pureSeg_holds M atomMap TemporalPred.top z0 z1).mpr
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y)
  | cons d ds ih =>
    have h_neg_d : ¬d.2.holds M atomMap z0 z1 :=
      h_neg d (List.mem_cons_self ..)
    obtain ⟨v_d, hv_d⟩ := neg_vecEA2 M atomMap h_UZ d.1 d.2 z0 z1 h_lt h_neg_d
    -- Handle rest of list
    have h_neg_rest : ∀ d' ∈ ds, ¬d'.2.holds M atomMap z0 z1 :=
      fun d' hm => h_neg d' (List.mem_cons_of_mem d hm)
    obtain ⟨v_rest, hv_rest⟩ := ih h_neg_rest
    -- Combine via conjunction closure
    exact VVecEA2.conj_holds_vvecEA2 M atomMap v_d v_rest z0 z1 h_lt hv_d hv_rest

/-- **Proposition 4.2**: The negation of a `VVecEA2` formula is equivalent to
    a `VVecEA2` formula over Prior structures.

    This is the main negation closure theorem for 2-free-variable vec-EA formulas. -/
theorem neg_2var_vec_ea {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_neg : ¬v.holds M atomMap z0 z1) :
    ∃ v' : VVecEA2, v'.holds M atomMap z0 z1 := by
  -- ¬(∃ d ∈ v.disjuncts, d.2.holds ...) means ∀ d ∈ v.disjuncts, ¬d.2.holds ...
  simp only [VVecEA2.holds] at h_neg
  push_neg at h_neg
  exact neg_disjunct_list M atomMap h_UZ z0 z1 h_lt v.disjuncts h_neg

end Bimodal.Metalogic.WeakCanonical.Kamp
