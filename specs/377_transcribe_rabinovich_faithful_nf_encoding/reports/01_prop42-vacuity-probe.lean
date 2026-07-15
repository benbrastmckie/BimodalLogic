import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula

/-
PLAN-TIME PROBE (task 377): is Prop 4.2 (`neg_2var_vec_ea`) vacuous?

`neg_2var_vec_ea`'s conclusion is `∃ v' : VVecEA2, v'.holds M atomMap z0 z1`,
with NO link asserted between `v'` and the negated input `v`.

If that conclusion is provable with NO hypotheses at all -- no `v`, no `h_neg`,
no `h_UZ`, no `h_lt` -- then the theorem is vacuous: sorry-free and axiom-clean,
but carrying no content about negation.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- The conclusion of `neg_2var_vec_ea`, proved from NOTHING. -/
theorem prop42_conclusion_is_vacuous {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    ∃ v' : VVecEA2, v'.holds M atomMap z0 z1 := by
  refine ⟨⟨[⟨0, { endpointLeft := TemporalPred.top,
                   endpointRight := TemporalPred.top,
                   bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩,
          ⟨0, _⟩, List.mem_singleton.mpr rfl, ?_, ?_, ?_⟩
  · simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]
  · simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]
  · exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
      (fun y _ _ => by
        simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth])

end Bimodal.Metalogic.WeakCanonical.Kamp
