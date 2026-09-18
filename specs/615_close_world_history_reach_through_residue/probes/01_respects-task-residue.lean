import FormalSystem.Semantics.IntTransfer
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.Extension.Extension

/-! Probe for the reach-through residue close-out. Verifies, in order:
    (a) the axiom gate on the two named theorems;
    (b) the `WorldHistory.respects_task` lemma;
    (c) that the two layer-crossing defect sites admit their `state`-level restatement;
    (d) that the three `rfl` lemmas about `path` survive `path := τ.state`. -/

open FormalSystem FormalSystem.Semantics

-- (a) GATE
#print axioms FormalSystem.Semantics.validZTime_iff_validInt
#print axioms FormalSystem.Semantics.truthAt_map

-- (b) THE LEMMA
namespace FormalSystem.Semantics.WorldHistory
variable {F : TaskFrame}

theorem respects_task (τ : WorldHistory F) (s t : F.Duration) :
    F.TaskRel (τ.state s) (t - s) (τ.state t) :=
  τ.val.respects_task s t (τ.property s) (τ.property t)

end FormalSystem.Semantics.WorldHistory

-- (c1) Extension.lean:219 restated at the `state` layer, same proof term.
theorem occurrence' (F : TaskFrame) (w : F.WorldState) (x : F.Duration) :
    ∃ τ : WorldHistory F, τ.state x = w := by
  obtain ⟨τ, hext⟩ := PartialHistory.extension F (PartialHistory.point F w x)
  exact ⟨τ, hext.agree x rfl⟩

-- (c2) IntNormalForm.lean:282 restated as `τ.state`, and definitionally the same function.
def path' {F : FrameOver intOrder} (τ : WorldHistory F.toTaskFrame) : ℤ → F.WorldState :=
  τ.state

example {F : FrameOver intOrder} (τ : WorldHistory F.toTaskFrame) : path' τ = τ.path := rfl

-- (d) the `rfl` lemmas that ride on `path`, re-checked against `path'`.
example (F : FrameOver intOrder) (f : ℤ → F.WorldState) (h : IsStepPath F f) :
    path' (FrameOver.worldHistoryOfStepPath F f h) = f := rfl

-- and `WorldHistory.isStepPath`'s own reach-through, rewritten through the new lemma.
example {F : FrameOver intOrder} (τ : WorldHistory F.toTaskFrame) : IsStepPath F (path' τ) := by
  intro n
  have := τ.respects_task n (n + 1)
  rwa [show n + 1 - n = (1 : ℤ) by omega] at this

-- Spot-check of a representative rewrite: the PlusPasting `_ _` form and the
-- ForwardDeterministicFrame `rw [states_eq_state]` form.
example {F : TaskFrame} (τ : WorldHistory F) (s t : F.Duration) :
    F.TaskRel (τ.state s) (t - s) (τ.state t) := τ.respects_task s t

example {F : TaskFrame} (hD : F.ForwardDeterministic) {τ σ : WorldHistory F} {x : F.Duration}
    (h : τ.state x = σ.state x) {y : F.Duration} (hxy : x ≤ y) :
    τ.state y = σ.state y := by
  have hτr := τ.respects_task x y
  have hσr := σ.respects_task x y
  rw [h] at hτr
  exact hD (σ.state x) (y - x) (sub_nonneg.mpr hxy) hτr hσr
