import FormalSystem.Semantics.IntTransfer
import FormalSystem.Semantics.Extension.Extension

/-! Spike for the task-569 gate and for the flat-structure alternative. -/

open FormalSystem FormalSystem.Semantics FormalSystem.Syntax

-- GATE (obligation class (ii)): does the Z-transfer machinery survive the total index?
-- It is ALREADY stated at the total index (`WorldHistory`), so this is a direct check.
#print axioms FormalSystem.Semantics.validZTime_iff_validInt
#print axioms FormalSystem.Semantics.truthAt_map
#check @FormalSystem.Semantics.ValidInt

-- The current index type and its shape.
#check @FormalSystem.Semantics.WorldHistory
#check @FormalSystem.Semantics.WorldHistory.state
#check @FormalSystem.Semantics.WorldHistory.ofTotal

-- TruthAt's index and clauses.
#check @FormalSystem.Semantics.TruthAt

-- The task's TARGET type, written as a flat structure.
structure PossibleWorld (F : TaskFrame) where
  states : F.Duration → F.WorldState
  respects_task : ∀ s t, F.TaskRel (states s) (t - s) (states t)

namespace PossibleWorld
variable {F : TaskFrame}

/-- Flat -> subtype. -/
def toWorldHistory (w : PossibleWorld F) : WorldHistory F :=
  WorldHistory.ofTotal F w.states w.respects_task

/-- Subtype -> flat. Needs `respects_task` at the *state* level, which the subtype
    does not expose as a field; it must be reconstructed from the dependent field. -/
def ofWorldHistory (τ : WorldHistory F) : PossibleWorld F where
  states := τ.state
  respects_task := fun s t => by
    simpa using τ.val.respects_task s t (τ.property s) (τ.property t)

theorem round_trip_states (w : PossibleWorld F) (t : F.Duration) :
    (ofWorldHistory w.toWorldHistory).states t = w.states t := rfl

theorem round_trip' (τ : WorldHistory F) : (ofWorldHistory τ).toWorldHistory = τ :=
  WorldHistory.ext_state (fun _ => rfl)

/-- THE BRIDGE QUESTION: the Extension Theorem's conclusion is stated at the PARTIAL layer
    (`Extends σ.val τ`). A flat structure has no `.val`, so it needs this bridge. -/
def toPartialHistory (w : PossibleWorld F) : PartialHistory F :=
  PartialHistory.ofTotal F w.states w.respects_task

example (F : TaskFrame) (τ : PartialHistory F) :
    ∃ w : PossibleWorld F, PartialHistory.Extends w.toPartialHistory τ := by
  obtain ⟨σ, hσ⟩ := PartialHistory.extension F τ
  refine ⟨ofWorldHistory σ, ?_⟩
  -- `Extends` is a PartialHistory-layer relation; a flat index must be pushed back
  -- across `toPartialHistory` to state it at all.
  obtain ⟨hdom, hst⟩ := hσ
  refine ⟨fun t _ => trivial, ?_⟩
  intro t ht
  show σ.state t = τ.states t ht
  exact hst t ht

end PossibleWorld

/-! ## The one missing API lemma

22 of the 27 residual subtype-plumbing lines in the live tree spell out
`τ.val.respects_task s t (τ.property s) (τ.property t)` by hand. This is the
`respects_task` field of the TARGET structure, stated at `WorldHistory`. It closes
the entire representation gap without changing the index type. -/

namespace FormalSystem.Semantics.WorldHistory
variable {F : TaskFrame}

theorem respects_task' (τ : WorldHistory F) (s t : F.Duration) :
    F.TaskRel (τ.state s) (t - s) (τ.state t) :=
  τ.val.respects_task s t (τ.property s) (τ.property t)

/-- With it, the flat structure is a one-liner in each direction. -/
example (τ : WorldHistory F) : _root_.PossibleWorld F :=
  ⟨τ.state, τ.respects_task'⟩

/-- And the two types are equivalent. -/
noncomputable def equivPossibleWorld : WorldHistory F ≃ _root_.PossibleWorld F where
  toFun τ := ⟨τ.state, τ.respects_task'⟩
  invFun w := WorldHistory.ofTotal F w.states w.respects_task
  left_inv _ := WorldHistory.ext_state (fun _ => rfl)
  right_inv _ := rfl

end FormalSystem.Semantics.WorldHistory
