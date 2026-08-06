/-
SCRATCH — Phase 11's mint guard and post-mint witness. NOT part of the library build.
-/
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace Scratch428Guard

open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

theorem not_selfGuarded_of_fresh {r : TableauRule} (h : ruleMintsFreshLabel r = true) :
    ruleSelfGuarded r = false := by
  cases r <;> simp_all [ruleMintsFreshLabel, ruleSelfGuarded]

theorem findApplicableRule_guard_linear {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {fs : List SignedFormula}
    {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, RuleResult.linear fs, o))
    (hfresh : ruleMintsFreshLabel r = true) :
    witnessPresent r sf b ord = false := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  (repeat' split at hr) <;> simp_all

theorem findApplicableRule_guard_branching {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule}
    {bss : List (List SignedFormula)} {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, RuleResult.branching bss, o))
    (hfresh : ruleMintsFreshLabel r = true) :
    witnessPresent r sf b ord = false := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  (repeat' split at hr) <;> simp_all [not_selfGuarded_of_fresh]

end Scratch428Guard
