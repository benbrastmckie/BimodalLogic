/-
SCRATCH — Phase 11's post-mint witness fact. NOT part of the library build.
-/
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace Scratch428Post

open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

set_option maxHeartbeats 4000000 in
theorem applyRule_fresh_witness_nonbranching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hfresh : ruleMintsFreshLabel rule = true) :
    ∀ nb ∈ nonBranchingResultBranch b (applyRule rule sf b ord).1,
      witnessPresent rule sf nb (applyRule rule sf b ord).2 = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             simp only [nonBranchingResultBranch, Option.mem_def, Option.some.injEq] at hnb
             first
               | (subst hnb
                  simp_all only [witnessPresent, TimeOrdering.addFuture, TimeOrdering.addPast,
                    List.cons_append, List.any_eq_true]
                  first
                    | exact ⟨_, mem_knownWorlds_of_mem List.mem_cons_self,
                        contains_of_mem List.mem_cons_self⟩
                    | exact ⟨_, mem_futureOf_of_mem_constraints _ _ _ List.mem_cons_self,
                        contains_of_mem List.mem_cons_self⟩
                    | exact ⟨_, mem_pastOf_of_mem_constraints _ _ _ List.mem_cons_self,
                        contains_of_mem List.mem_cons_self⟩)
               | exact absurd hnb (by simp)))

end Scratch428Post

#print axioms Scratch428Post.applyRule_fresh_witness_nonbranching
