/-
Probe 02 for the agreement lemma over all walks.

Question: is the branching frame `SharingWitnessFamily.frame` RECURRENCE-FREE -- no world
history visits a world state twice?

This matters for two reasons.

1. It is what makes the stability quantifier's collapse (probe 01) a quantifier over ONE time.
   `share_of_cls_eq` forces two equal classes to sit at the same time, so "every history through
   the present world state" cannot drag in another time.

2. `FormalSystem.Semantics.plusValidIn_iff_recurrenceFree` says L-plus validity over a frame
   class equals validity over that class's recurrence-free members. A recurrence-free witness
   frame therefore loses NO refuting power for the larger language: whatever the branching
   device cannot refute for lack of recurrence, no frame refutes.
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Histories
import FormalSystem.Semantics.HistoryMorphism

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace SharingWitnessFamily

variable {Γ Del : Context}

/--
**The branching frame is recurrence-free.**

Immediate from `total_eq_thread` and `share_of_cls_eq`: a history is a thread's trace, whose
state at `t` is the class of a pair whose time coordinate is `s + t`, and two equal classes have
equal time coordinates.
-/
theorem frame_recurrenceFree (S : SharingWitnessFamily Γ Del) :
    S.frame.toTaskFrame.RecurrenceFree := by
  intro τ a b hab
  obtain ⟨θ, s, hθ⟩ := S.total_eq_thread τ
  rw [hθ a, hθ b] at hab
  obtain ⟨htime, _⟩ := share_of_cls_eq hab
  have h : (s + a : ℤ) = (s + b : ℤ) := htime
  exact add_left_cancel h

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
