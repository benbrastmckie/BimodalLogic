import FormalSystem.Metalogic.Decidability.RaySummary.Compose

open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Decidability.RaySummary

#print axioms kTypeOf_listSeg_append_congr
#print axioms kTypeOf_segZ_eq_listSeg
#print axioms listSeg_append_kEquiv
#print axioms kTypeOfFin_listSeg

-- Computability witnesses (depth 1, two letters), run via lean_run_code after the scoped build.
def f : twoLetter.preds → Bool := fun b => b
def g : twoLetter.preds → Bool := fun b => !b

#eval decide (kTypeOfFin (listSeg (sig := twoLetter) [f, g, f]) 1 =
  kTypeOfFin (listSeg (sig := twoLetter) [f, g, f, g, f]) 1)
#eval decide (kTypeOfFin (listSeg (sig := twoLetter) [f, g]) 1 =
  kTypeOfFin (listSeg (sig := twoLetter) [g, f]) 1)
#eval (labels (sig := twoLetter) (fun p t => p = true ∧ 0 ≤ t) (-1) 2).length
#eval decide (kTypeOfFin (listSeg (sig := twoLetter) [f, g, f]) 1 =
  kTypeOfFin (listSeg (sig := twoLetter) [f]) 1)
