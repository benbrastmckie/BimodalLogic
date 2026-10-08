import FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Decidability.RaySummary

#print axioms mem_hitOf_iff
#print axioms mem_hitOf_iff_live
#print axioms exists_run_of_live
#print axioms live_of_run
#print axioms fwdLiveSep_iff
#print axioms bwdLiveSep_iff
#print axioms exists_concat
#print axioms isRun_concat
#print axioms kTypeOf_segZ_concat
#print axioms kTypeOf_runSeg
#print axioms countP_eq_one_iff
#print axioms eval_iff_of_kTypeOf_eq
#print axioms nonempty_iff_of_kTypeOf_eq
#print axioms exists_interp_iff_of_kTypeOf_eq

-- Computability witness: the Phase 6 two-state presentation over `twoLetter`, `now := true`,
-- depth 1. State `true` reads both letters (so it reads `now`); state `false` reads neither;
-- complete step graph.
def labW : Bool → twoLetter.preds → Bool := fun q _ => q
def stepW : Bool → Bool → Bool := fun _ _ => true

#eval (allPathTypes labW stepW true 1).card
#eval (hitOf labW stepW true 1).card

-- Discriminator: the alternating presentation `step x y := (x ≠ y)`, state `false` reading the
-- letter `false` only (never `now := true`), state `true` reading nothing. At the depth-1 type
-- of `[labAlt false]`, Phase 6's `fwdLive` (shared-endpoint chains) is `true` at `false` via
-- the one-state self-loop, while `fwdLiveSep` (disjoint segments joined by a step) is `false`:
-- no run of this presentation factors into disjoint segments of that type. (`hitOf` of this
-- presentation is empty for a different reason: no state reads `now`, so it has no run.)
def labAlt : Bool → twoLetter.preds → Bool := fun q p => !q && !p
def stepAlt : Bool → Bool → Bool := fun x y => x != y

#eval fwdLive labAlt stepAlt true 1 (kTypeOfFin (listSeg (sig := twoLetter) [labAlt false]) 1) false
#eval fwdLiveSep labAlt stepAlt true 1 (kTypeOfFin (listSeg (sig := twoLetter) [labAlt false]) 1) false
#eval bwdLive labAlt stepAlt true 1 (kTypeOfFin (listSeg (sig := twoLetter) [labAlt false]) 1) false
#eval bwdLiveSep labAlt stepAlt true 1 (kTypeOfFin (listSeg (sig := twoLetter) [labAlt false]) 1) false
#eval (hitOf labAlt stepAlt true 1).card
