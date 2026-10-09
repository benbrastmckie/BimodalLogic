import FormalSystem.PlusLanguage.PlusTruth

/-! Scratch machine-check for task 747 research: `box` is time-invariant in every `TaskModel`,
by shift closure of the history set (`plusTruthAt_timeShift`). -/

namespace FormalSystem.PlusLanguage

open FormalSystem.Semantics

variable {F : TaskFrame}

/-- `□ψ` has the same truth value at every pair of times, along any history. -/
theorem box_time_invariant (M : TaskModel F) (τ : WorldHistory F) (t s : F.Duration)
    (ψ : PlusFormula) :
    PlusTruthAt M τ t (.box ψ) ↔ PlusTruthAt M τ s (.box ψ) := by
  rw [PlusTruth.box_iff, PlusTruth.box_iff]
  constructor
  · intro h σ
    have h1 := h (σ.timeShift (s - t))
    rw [plusTruthAt_timeShift] at h1
    rwa [add_sub_cancel] at h1
  · intro h σ
    have h1 := h (σ.timeShift (t - s))
    rw [plusTruthAt_timeShift] at h1
    rwa [add_sub_cancel] at h1

/-- `□ψ` depends on the model alone: along any two histories at any two times. -/
theorem box_global (M : TaskModel F) (τ σ : WorldHistory F) (t s : F.Duration)
    (ψ : PlusFormula) :
    PlusTruthAt M τ t (.box ψ) ↔ PlusTruthAt M σ s (.box ψ) := by
  rw [box_time_invariant M τ t s]
  exact Iff.rfl

end FormalSystem.PlusLanguage

#print axioms FormalSystem.PlusLanguage.box_time_invariant
#print axioms FormalSystem.PlusLanguage.box_global
