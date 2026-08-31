import FormalSystem.Semantics.Truth
import Mathlib.Algebra.Order.Group.Int
namespace OProbe2
open FormalSystem.Semantics
variable {G : TaskFrame} {F : ParamTaskFrame ℤ}

-- hypothesis at the BUNDLED frame's own order instance
example (t s : (TaskFrame.ofParam F).Duration) (h : t < s) : (t:ℤ) + 1 ≤ s := by omega

example (t s : (TaskFrame.ofParam F).Duration) (h : t < s) : (t:ℤ) + 1 ≤ s := by
  have h' : (t : ℤ) < s := h
  omega

-- from an actual TruthAt destructuring
example (M : TaskModel F) (τ : WorldHistory F) (t : ℤ) (g e : Formula)
    (H : TruthAt M τ t (Formula.untl g e)) : True := by
  obtain ⟨s, hts, hse, hguard⟩ := H
  have : t + 1 ≤ s := by omega
  trivial
end OProbe2
