import FormalSystem.Metalogic.Decidability.RaySummary.Closure

open FormalSystem.Metalogic.Decidability.RaySummary FormalSystem.PlusLanguage

#print axioms plusStab_iff_forall_hitSig
#print axioms plusStab_iff_forall_hit'
#print axioms hitSig_twoLetter
#print axioms hitSig_finite
#print axioms stabTargetSig_determined
#print axioms stabTargetSig_of_trace
#print axioms clTrace_proj
#print axioms clLetter_inj
#print axioms clNow_ne_clLetter

-- Phase 2 verification: the closure alphabet of `p U q` has four letters.
#eval Fintype.card (clSig (.untl (.atom ⟨"p", none⟩) (.atom ⟨"q", none⟩))).preds
