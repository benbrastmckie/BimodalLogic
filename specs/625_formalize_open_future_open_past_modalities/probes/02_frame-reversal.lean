import FormalSystem.Semantics.PlusLanguage.PlusPasting

/-! Probe B: time reversal of a frame, `rev (rev F) = F` by `rfl`, reversal of world histories,
and the agreement-class swap `AgreeUpTo ↔ AgreeFrom`. -/

namespace Probe625Rev

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame

variable {D : TemporalOrder}

/-- The converse primitive relation: `PosRel' w x u := PosRel u x w`. -/
def rev (F : FrameOver D) : FrameOver D where
  WorldState := F.WorldState
  worldNonempty := F.worldNonempty
  PosRel := fun w x u => F.PosRel u x w
  comp := by
    intro w v x y hx hy
    have h := F.comp v w y x hy hx
    rw [add_comm] at h
    show reflect F.PosRel v (x + y) w ↔ ∃ u, reflect F.PosRel u x w ∧ reflect F.PosRel v y u
    rw [h]
    constructor
    · rintro ⟨u, h1, h2⟩; exact ⟨u, h2, h1⟩
    · rintro ⟨u, h1, h2⟩; exact ⟨u, h2, h1⟩
  serial := by
    intro w x hx
    obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := F.serial w x hx
    exact ⟨⟨v, hv⟩, ⟨u, hu⟩⟩
  limit := by
    intro w u h
    exact (F.limit u w h).symm
  saturation := by
    intro S hdir hmem
    refine F.saturation S hdir ?_
    intro s hs
    obtain ⟨hcls, hne⟩ := hmem s hs
    refine ⟨?_, hne⟩
    rcases hcls with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · left
      refine ⟨w, -x, ?_⟩
      ext u
      change F.TaskRel u x w ↔ F.TaskRel w (-x) u
      exact F.reflection u x w
    · right
      refine ⟨v, w, y, x, hy, hx, ?_⟩
      ext u
      change F.TaskRel u x w ∧ F.TaskRel u (-y) v ↔ F.TaskRel v y u ∧ F.TaskRel w (-x) u
      rw [F.reflection u x w, F.reflection u (-y) v, neg_neg, and_comm]

theorem rev_taskRel (F : FrameOver D) (w : F.WorldState) (d : ↑D) (u : F.WorldState) :
    (rev F).TaskRel w d u ↔ F.TaskRel u d w := Iff.rfl

example (F : FrameOver D) : rev (rev F) = F := rfl

/-- Reversal of a world history: `τ'(t) = τ(-t)`. -/
def revHist {F : FrameOver D} (τ : WorldHistory F.toTaskFrame) : WorldHistory (rev F).toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => τ.state (-t)) (fun s t => by
    change F.TaskRel (τ.state (-t)) (t - s) (τ.state (-s))
    have := τ.respects_task (-t) (-s)
    rwa [show (-s : ↑D) - -t = t - s by abel] at this)

@[simp] theorem revHist_state {F : FrameOver D} (τ : WorldHistory F.toTaskFrame) (t : ↑D) :
    (revHist τ).state t = τ.state (-t) := rfl

theorem revHist_revHist {F : FrameOver D} (τ : WorldHistory F.toTaskFrame) :
    revHist (revHist τ) = τ := by
  apply WorldHistory.ext_state
  intro t
  show τ.state (- -t) = τ.state t
  rw [neg_neg]

theorem agreeUpTo_rev {F : FrameOver D} (τ σ : WorldHistory F.toTaskFrame) (t : ↑D) :
    AgreeUpTo τ σ t ↔ AgreeFrom (revHist τ) (revHist σ) (-t) := by
  constructor
  · intro h s hs
    show τ.state (-s) = σ.state (-s)
    exact h (-s) (neg_le.mp hs)
  · intro h s hs
    have := h (-s) (neg_le_neg hs)
    change τ.state (- -s) = σ.state (- -s) at this
    rwa [neg_neg] at this

end Probe625Rev
