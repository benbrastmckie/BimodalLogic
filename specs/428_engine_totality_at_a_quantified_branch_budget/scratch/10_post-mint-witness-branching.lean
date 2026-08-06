/-
SCRATCH — Phase 11's post-mint witness, branching shape. NOT part of the library build.
-/
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace Scratch428PostB

open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

set_option maxHeartbeats 4000000 in
theorem applyRule_fresh_witness_branching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hfresh : ruleMintsFreshLabel rule = true) :
    ∀ nb ∈ branchingResultBranches b (applyRule rule sf b ord).1,
      witnessPresent rule sf nb (applyRule rule sf b ord).2 = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             simp only [branchingResultBranches, List.mem_map, List.mem_cons, List.not_mem_nil,
               or_false] at hnb
             all_goals first
               | (obtain ⟨fs, hfs, rfl⟩ := hnb
                  rcases hfs with rfl | rfl <;>
                    (simp_all only [witnessPresent, TimeOrdering.addFuture, TimeOrdering.addPast,
                       List.cons_append, List.any_eq_true, Bool.or_eq_true, Bool.and_eq_true]
                     all_goals first
                       | exact ⟨_, mem_futureOf_of_mem_constraints _ _ _ List.mem_cons_self,
                           Or.inl (contains_of_mem List.mem_cons_self)⟩
                       | exact ⟨_, mem_futureOf_of_mem_constraints _ _ _ List.mem_cons_self,
                           Or.inr ⟨contains_of_mem List.mem_cons_self,
                             contains_of_mem (List.mem_cons_of_mem _ List.mem_cons_self)⟩⟩
                       | exact ⟨_, mem_pastOf_of_mem_constraints _ _ _ List.mem_cons_self,
                           Or.inl (contains_of_mem List.mem_cons_self)⟩
                       | exact ⟨_, mem_pastOf_of_mem_constraints _ _ _ List.mem_cons_self,
                           Or.inr ⟨contains_of_mem List.mem_cons_self,
                             contains_of_mem (List.mem_cons_of_mem _ List.mem_cons_self)⟩⟩))
               | exact absurd hnb (by simp)))

end Scratch428PostB

#print axioms Scratch428PostB.applyRule_fresh_witness_branching
