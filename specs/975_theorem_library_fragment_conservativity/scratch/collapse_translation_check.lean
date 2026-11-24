import BimodalLib.Conservativity
import Mathlib.Tactic

open FormalSystem.Syntax FormalSystem.ProofSystem BimodalLib

namespace Scratch2

/-- S5 truth on a set of worlds; the temporal operators never occur in a translated formula. -/
def STruth {W : Type} (V : W → Atom → Prop) : Formula → W → Prop
  | .atom a, w => V w a
  | .bot, _ => False
  | .imp φ ψ, w => STruth V φ w → STruth V ψ w
  | .box φ, _ => ∀ w', STruth V φ w'
  | .untl _ _, _ => False
  | .snce _ _, _ => False

/-- Collapse of the temporal operators (dense or discrete reading), keeping or erasing `□`. -/
def tr (dense keep : Bool) : Formula → Formula
  | .atom a => .atom a
  | .bot => .bot
  | .imp φ ψ => .imp (tr dense keep φ) (tr dense keep ψ)
  | .box φ => if keep then .box (tr dense keep φ) else tr dense keep φ
  | .untl g e => if dense then (tr dense keep g).and (tr dense keep e) else tr dense keep e
  | .snce g e => if dense then (tr dense keep g).and (tr dense keep e) else tr dense keep e

variable {W : Type} {V : W → Atom → Prop}

@[simp] theorem s_imp (φ ψ : Formula) (w : W) :
    STruth V (φ.imp ψ) w ↔ (STruth V φ w → STruth V ψ w) := Iff.rfl
@[simp] theorem s_bot (w : W) : STruth V Formula.bot w ↔ False := Iff.rfl
@[simp] theorem s_box (φ : Formula) (w : W) : STruth V φ.box w ↔ ∀ w', STruth V φ w' := Iff.rfl

theorem tr_reflect (dense keep : Bool) (φ : Formula) :
    tr dense keep φ.reflectTime = tr dense keep φ := by
  cases dense <;> cases keep <;> induction φ <;> simp_all [tr, Formula.reflectTime]

theorem tr_fix_modal (dense : Bool) (φ : Formula) (h : profileF φ ≤ { box := true }) :
    tr dense true φ = φ := by
  induction φ <;> simp_all [tr, profileF, Profile.join, LE.le, Profile.le]

theorem tr_fix_bool (dense keep : Bool) (φ : Formula) (h : profileF φ ≤ {}) :
    tr dense keep φ = φ := by
  induction φ <;> simp_all [tr, profileF, Profile.join, LE.le, Profile.le]

/-- Every axiom admissible at `fc` translates to an S5 validity, under the dense reading away
from `.ZTime` and under the discrete reading at `.Base` and `.ZTime`. -/
theorem tr_axiom_valid (dense keep : Bool) (fc : FrameClass)
    (hfc : if dense then fc ≠ .ZTime else (fc = .Base ∨ fc = .ZTime))
    {φ : Formula} (h : Axiom φ) (hmin : h.minFrameClass ≤ fc) (w : W) :
    STruth V (tr dense keep φ) w := by
  cases dense <;> cases keep <;> cases h <;> cases fc <;>
    simp_all [tr, Formula.and, Formula.or, Formula.neg, Formula.top, Formula.diamond,
      Formula.someFuture, Formula.allFuture, Formula.kPlus, Formula.kMinus,
      Axiom.minFrameClass, LE.le] <;> tauto

end Scratch2
#print axioms Scratch2.tr_axiom_valid
