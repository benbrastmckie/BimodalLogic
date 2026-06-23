import Bimodal.Metalogic.WeakCanonical.Kamp.EANegation
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
# VecEA2-Level Negation Closure (Rabinovich 2014, Lemma 5.1)

Model-independent negation closure at the VecEA2 level, where alpha_0 is
evaluated at the fixed endpoint z_0 rather than an interior existential
witness.

## Main Result

- `neg_vecEA2_is_vvecEA2`: For any `VecEA2 n`, there exists a `VVecEA2`
  that is model-independently equivalent to its negation on all structures
  with `HasAttainedINF`.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.1 (pp. 7-11)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **Lemma 5.1** (Rabinovich 2014, VecEA2 level): The negation of any
    `VecEA2 n` formula is model-independently equivalent to a `VVecEA2`
    formula on all structures with `HasAttainedINF`. -/
theorem neg_vecEA2_is_vvecEA2 :
    ∀ (n : Nat) (vea : VecEA2 n),
    ∃ (v : VVecEA2),
    ∀ {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
      (atomMap : Formula → sig.preds) (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 →
      (v.holds M atomMap z0 z1 ↔ ¬ vea.holds M atomMap z0 z1) := by
  intro n
  induction n with
  | zero =>
    intro vea
    let seg0 := vea.bracket.segmentTypes ⟨0, by omega⟩
    let d1 : Σ n, VecEA2 n := ⟨0,
      { endpointLeft := vea.endpointLeft.neg
        endpointRight := TemporalPred.top
        bracket := BracketFormula.trivial TemporalPred.top }⟩
    let d2 : Σ n, VecEA2 n := ⟨0,
      { endpointLeft := TemporalPred.top
        endpointRight := vea.endpointRight.neg
        bracket := BracketFormula.trivial TemporalPred.top }⟩
    let d3 : Σ n, VecEA2 n := ⟨1,
      { endpointLeft := vea.endpointLeft
        endpointRight := vea.endpointRight
        bracket := { pointTypes := fun _ => seg0.neg
                     segmentTypes := fun _ => TemporalPred.top } }⟩
    refine ⟨⟨[d1, d2, d3]⟩, fun M atomMap _h_INF z0 z1 h_lt => ?_⟩
    simp only [VecEA2.holds]
    constructor
    · -- Forward: some disjunct holds → ¬(epL ∧ epR ∧ bracket)
      intro ⟨⟨m, vea'⟩, h_mem, h_holds⟩
      simp only [List.mem_cons, List.not_mem_nil, or_false] at h_mem
      rcases h_mem with h_eq | h_eq | h_eq
      · -- d1: ¬epL(z0)
        have hm_eq := congr_arg Sigma.fst h_eq; simp at hm_eq; subst hm_eq
        have hvea_eq : vea' = d1.2 := eq_of_heq (Sigma.mk.inj h_eq).2
        subst hvea_eq
        obtain ⟨hL, _, _⟩ := h_holds
        intro ⟨hL', _, _⟩
        exact (TemporalPred.eval_at_neg' M atomMap vea.endpointLeft z0).mp hL hL'
      · -- d2: ¬epR(z1)
        have hm_eq := congr_arg Sigma.fst h_eq; simp at hm_eq; subst hm_eq
        have hvea_eq : vea' = d2.2 := eq_of_heq (Sigma.mk.inj h_eq).2
        subst hvea_eq
        obtain ⟨_, hR, _⟩ := h_holds
        intro ⟨_, hR', _⟩
        exact (TemporalPred.eval_at_neg' M atomMap vea.endpointRight z1).mp hR hR'
      · -- d3: exists y with ¬seg0(y)
        have hm_eq := congr_arg Sigma.fst h_eq; simp at hm_eq; subst hm_eq
        have hvea_eq : vea' = d3.2 := eq_of_heq (Sigma.mk.inj h_eq).2
        subst hvea_eq
        obtain ⟨_, _, h_bracket⟩ := h_holds
        simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
          IntervalPattern.holds] at h_bracket
        obtain ⟨w, _, hrange, hpoint, _, _, _⟩ := h_bracket
        intro ⟨_, _, h_bf⟩
        simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
          IntervalPattern.holds] at h_bf
        have hy := hpoint ⟨0, by omega⟩
        have h_neg_seg : ¬ seg0.eval_at M atomMap (w ⟨0, by omega⟩) :=
          (TemporalPred.eval_at_neg' M atomMap seg0 (w ⟨0, by omega⟩)).mp hy
        exact h_neg_seg (h_bf (w ⟨0, by omega⟩) (hrange ⟨0, by omega⟩).1
          (hrange ⟨0, by omega⟩).2)
    · -- Backward: ¬(epL ∧ epR ∧ bracket) → some disjunct holds
      intro h_neg
      push_neg at h_neg
      by_cases hL : vea.endpointLeft.eval_at M atomMap z0
      · by_cases hR : vea.endpointRight.eval_at M atomMap z1
        · have h_neg_bracket : ¬ vea.bracket.holds M atomMap z0 z1 := h_neg hL hR
          simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
            IntervalPattern.holds] at h_neg_bracket
          push_neg at h_neg_bracket
          obtain ⟨y, hy0, hy1, h_neg_y⟩ := h_neg_bracket
          refine ⟨d3, List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inr
            (List.mem_singleton.mpr rfl)))), hL, hR, ?_⟩
          simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
            IntervalPattern.holds, d3]
          refine ⟨fun _ => y, ?_, ?_, ?_, ?_, ?_, ?_⟩
          · intro a b hab; exact absurd hab (by omega)
          · intro _; exact ⟨hy0, hy1⟩
          · intro j
            have : j = ⟨0, by omega⟩ := Fin.ext (by omega)
            rw [this]; simp
            exact (TemporalPred.eval_at_neg' M atomMap seg0 y).mpr h_neg_y
          · intro t _ _; exact TemporalPred.eval_at_top M atomMap t
          · intro ⟨j, hj⟩; exact absurd hj (by omega)
          · intro t _ _; exact TemporalPred.eval_at_top M atomMap t
        · refine ⟨d2, List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl rfl))),
            TemporalPred.eval_at_top M atomMap z0,
            (TemporalPred.eval_at_neg' M atomMap vea.endpointRight z1).mpr hR, ?_⟩
          exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
            (fun t _ _ => TemporalPred.eval_at_top M atomMap t)
      · refine ⟨d1, List.mem_cons.mpr (Or.inl rfl),
          (TemporalPred.eval_at_neg' M atomMap vea.endpointLeft z0).mpr hL,
          TemporalPred.eval_at_top M atomMap z1, ?_⟩
        exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
          (fun t _ _ => TemporalPred.eval_at_top M atomMap t)
  | succ n ih =>
    intro vea
    -- Pending: full Rabinovich Case 2/3 decomposition.
    -- See handoff for detailed analysis of the structural challenges.
    sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
