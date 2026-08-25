import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- PROBE 5: the untlNeg trigger shape, recovered from `isApplicable`. -/
theorem probe_untlNeg_trigger {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass}
    (hA : isApplicable TableauRule.untlNeg sf fc = true) :
    ∃ e g, sf.sign = Sign.neg ∧ asUntil? sf.formula = some (e, g) := by
  simp only [isApplicable] at hA
  split at hA <;> simp_all
  rename_i heq
  rcases h : asUntil? sf.formula with _ | ⟨e, g⟩
  · rw [h] at hA; simp at hA
  · exact ⟨e, g, heq, rfl⟩

/-- PROBE 6: `untlPos` produces `.branching` or `.notApplicable`, never anything else. -/
theorem probe_untlPos_shape {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {res : RuleResult} {o : TimeOrdering}
    (hA : applyRule TableauRule.untlPos sf b ord = (res, o))
    (hne : res ≠ RuleResult.notApplicable) :
    ∃ bss, res = RuleResult.branching bss := by
  simp only [applyRule] at hA
  repeat' split at hA
  all_goals (try simp_all)
  all_goals exact ⟨_, hA.1.symm⟩

/-- PROBE 7: the six-rule / two-rule / rest census is decidable as a case split. -/
theorem probe_census (r : TableauRule) :
    ruleMintsFreshTime r = false
    ∨ (r ∈ freshLabelRules ∧ ruleMintsFreshTime r = true)
    ∨ r = TableauRule.untlNeg ∨ r = TableauRule.snceNeg
    ∨ r = TableauRule.densityRule := by
  revert r; decide

end FormalSystem.Metalogic.Decidability
