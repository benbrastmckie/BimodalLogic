import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- No `.box` node anywhere. -/
def boxFree : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp a b => boxFree a && boxFree b
  | .box _ => false
  | .untl a b => boxFree a && boxFree b
  | .snce a b => boxFree a && boxFree b

theorem asDiamond_eq_none_of_boxFree {φ : Formula} (h : boxFree φ = true) :
    asDiamond? φ = none := by
  cases φ <;> simp_all [asDiamond?, boxFree]
  rename_i a b
  cases a <;> simp_all [asDiamond?, boxFree]

theorem isApplicable_boxNeg_false_of_boxFree {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass} (h : boxFree sf.formula = true) :
    isApplicable .boxNeg sf fc = false := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> cases formula <;> simp_all [isApplicable, boxFree]

theorem isApplicable_diamondPos_false_of_boxFree {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass} (h : boxFree sf.formula = true) :
    isApplicable .diamondPos sf fc = false := by
  cases sf with
  | mk sign formula label =>
    cases sign <;>
      simp_all [isApplicable, asDiamond_eq_none_of_boxFree h]

theorem findApplicableRule_not_worldMinting {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (hfree : boxFree sf.formula = true)
    (h : findApplicableRule sf b ord fc = some (r, res, o)) :
    r ≠ .boxNeg ∧ r ≠ .diamondPos := by
  have happ := findApplicableRule_isApplicable h
  constructor
  · rintro rfl
    simp [isApplicable_boxNeg_false_of_boxFree (fc := fc) hfree] at happ
  · rintro rfl
    simp [isApplicable_diamondPos_false_of_boxFree (fc := fc) hfree] at happ
