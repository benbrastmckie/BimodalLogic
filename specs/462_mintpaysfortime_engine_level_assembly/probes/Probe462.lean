import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- PROBE 1: density exclusion by frame class. -/
theorem probe_findApplicableRule_ne_densityRule {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (hfc : ¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc))
    (h : findApplicableRule sf b ord fc = some (r, res, o)) :
    r ≠ TableauRule.densityRule := by
  intro hr
  subst hr
  have hA := findApplicableRule_isApplicable h
  simp only [isApplicable] at hA
  split at hA <;> simp_all

/-- PROBE 2: the untlNeg ACTIVE guard, inverted from a non-`notApplicable` result. -/
theorem probe_untlNeg_guard {φ : Formula} {l : Label} {b : Branch} {ord : TimeOrdering}
    {e g : Formula} {res : RuleResult} {o : TimeOrdering}
    (hform : asUntil? φ = some (e, g))
    (hA : applyRule TableauRule.untlNeg ⟨Sign.neg, φ, l⟩ b ord = (res, o))
    (hne : res ≠ RuleResult.notApplicable) :
    ((ord.futureOf l.time).isEmpty && decide (0 < ord.timeCount)
      && decide (ord.timeCount < 4)) = true := by
  by_contra hg
  simp only [Bool.not_eq_true] at hg
  rw [show applyRule TableauRule.untlNeg ⟨Sign.neg, φ, l⟩ b ord
      = (RuleResult.notApplicable, ord) by
    simp only [applyRule, hform]
    simp_all] at hA
  exact hne (by simp_all)

/-- PROBE 3: result shape of one of the six. -/
theorem probe_allFutureNeg_shape {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {res : RuleResult} {o : TimeOrdering}
    (hA : applyRule TableauRule.allFutureNeg sf b ord = (res, o))
    (hne : res ≠ RuleResult.notApplicable) :
    ∃ fs, res = RuleResult.linear fs := by
  simp only [applyRule] at hA
  split at hA <;> (try simp_all) <;> exact ⟨_, hA.1.symm⟩

end FormalSystem.Metalogic.Decidability
