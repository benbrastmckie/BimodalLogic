import FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Decidability.RaySummary

#print axioms mem_pathTypes_iff
#print axioms mem_pathTypesNow_iff
#print axioms mem_pathTypes_iff_stepPath
#print axioms mem_pathTypesNow_iff_stepPath
#print axioms exists_mem_iterate_of_stepPath
#print axioms realizes_of_mem_iterate
#print axioms closureStep_pathClosure
#print axioms closureIter_eq_iterate
#print axioms iterate_stabilizes
#print axioms stepPath_iff
#print axioms live_iff
#print axioms fwdLive_iff
#print axioms bwdLive_iff

-- Computability witnesses: two-state presentation over `twoLetter`, `now := true`, depth 1.
-- State `true` reads both letters (so it reads `now`); state `false` reads neither; complete
-- step graph.
def labW : Bool → twoLetter.preds → Bool := fun q _ => q
def stepW : Bool → Bool → Bool := fun _ _ => true

#eval (pathClosure labW stepW true 1).card                        -- 5
#eval (pathTypes labW stepW true 1 false false).card              -- 1
#eval (pathTypesNow labW stepW true 1 false false).card           -- 1
#eval (pathTypes labW stepW true 1 false true).card               -- 0 (`true` reads `now`)
#eval (pathTypesNow labW stepW true 1 false true).card            -- 1
#eval fwdLive labW stepW true 1 (kTypeOfFin (listSeg (sig := twoLetter) [labW false]) 1) false  -- true
#eval bwdLive labW stepW true 1 (kTypeOfFin (listSeg (sig := twoLetter) [labW false]) 1) false  -- true
#eval fwdLive labW stepW true 1 (kTypeOfFin (listSeg (sig := twoLetter) [labW false]) 1) true   -- false
#eval fwdLive labW stepW true 1 (kTypeOfFin (listSeg (sig := twoLetter) [labW true]) 1) false   -- false
