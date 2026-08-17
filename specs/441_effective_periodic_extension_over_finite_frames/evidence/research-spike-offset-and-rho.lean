import FormalSystem.Metalogic.Decidability.BiLasso.Basic

open FormalSystem.Semantics FormalSystem.Metalogic.Decidability

variable {P : IntPresentation}

/-! ### (A) Time-offset placement: `BiLasso`'s `mid` is pinned to `[0,|mid|)`, so a window at
negative times needs a shift.  Shift-invariance of `IsStepPath` is free. -/

theorem isStepPath_shift {F : TaskFrame ℤ} {f : ℤ → F.WorldState} (h : IsStepPath F f) (k : ℤ) :
    IsStepPath F (fun t => f (t - k)) := by
  intro n
  have := h (n - k)
  simpa [show n + 1 - k = (n - k) + 1 by omega] using this

/-- The shifted decoding of a bi-lasso: `mid` now occupies `[origin, origin+|mid|)`. -/
def placedUnroll (L : BiLasso P) (origin : ℤ) : ℤ → Fin P.card := fun t => L.unroll (t - origin)

theorem placedUnroll_isStepPath (L : BiLasso P) (origin : ℤ) :
    IsStepPath P.toTaskFrame (placedUnroll L origin) :=
  isStepPath_shift L.unroll_isStepPath origin

/-- The placed decoding as an element of `H_F`. -/
def placedToHF (L : BiLasso P) (origin : ℤ) : P.toTaskFrame.HF :=
  TaskFrame.HFofStepPath P.toTaskFrame _ (placedUnroll_isStepPath L origin)

#print axioms isStepPath_shift
#print axioms placedUnroll_isStepPath

/-! ### (B) The rho decomposition of a deterministic orbit. -/

def succOf (P : IntPresentation) (w : Fin P.card) : Fin P.card :=
  match h : (List.finRange P.card).find? (fun u => P.step w u) with
  | some u => u
  | none => absurd (P.fwd w) (by
      intro hex; obtain ⟨u, hu⟩ := hex
      have := List.find?_eq_none.mp h u (List.mem_finRange u); simp [hu] at this)

theorem succOf_step (P : IntPresentation) (w : Fin P.card) : P.step w (succOf P w) = true := by
  unfold succOf
  split
  · next u h => simpa using List.find?_some h
  · next h => exact absurd (P.fwd w) (by
      intro hex; obtain ⟨u, hu⟩ := hex
      have := List.find?_eq_none.mp h u (List.mem_finRange u); simp [hu] at this)

/-- Pigeonhole on the deterministic forward orbit: a repeat within `card` steps. -/
theorem orbit_repeat (P : IntPresentation) (w : Fin P.card) :
    ∃ i j : ℕ, i < j ∧ j ≤ P.card ∧ (succOf P)^[i] w = (succOf P)^[j] w := by
  by_contra hcon
  push_neg at hcon
  have hinj : Function.Injective (fun i : Fin (P.card + 1) => (succOf P)^[(i : ℕ)] w) := by
    intro a b hab
    by_contra hne
    rcases Nat.lt_trichotomy (a : ℕ) (b : ℕ) with h | h | h
    · exact hcon a b h (by have := b.isLt; omega) hab
    · exact hne (Fin.ext h)
    · exact hcon b a h (by have := a.isLt; omega) hab.symm
  have := Fintype.card_le_of_injective _ hinj
  simp at this

#print axioms succOf
#print axioms succOf_step
#print axioms orbit_repeat
