import FormalSystem.Metalogic.Decidability.BiLasso.Basic

-- A: computable successor via List.find? over List.finRange
def succOf {N : ℕ} (step : Fin N → Fin N → Bool) (fwd : ∀ w, ∃ u, step w u = true) (w : Fin N) :
    Fin N :=
  match h : (List.finRange N).find? (fun u => step w u) with
  | some u => u
  | none => absurd (fwd w) (by
      intro hex
      obtain ⟨u, hu⟩ := hex
      have := List.find?_eq_none.mp h u (List.mem_finRange u)
      simp [hu] at this)

theorem succOf_spec {N : ℕ} (step : Fin N → Fin N → Bool) (fwd : ∀ w, ∃ u, step w u = true)
    (w : Fin N) : step w (succOf step fwd w) = true := by
  unfold succOf
  split
  · next u h => simpa using List.find?_some h
  · next h => exact absurd (fwd w) (by
      intro hex; obtain ⟨u, hu⟩ := hex
      have := List.find?_eq_none.mp h u (List.mem_finRange u); simp [hu] at this)

#print axioms succOf
#print axioms succOf_spec

-- B: choice-free pigeonhole?  A long list over Fin N has a repeat.  Hand-rolled, no Finset.
theorem orbit_repeat {N : ℕ} (f : Fin N → Fin N) (w : Fin N) :
    ∃ i j : ℕ, i < j ∧ j ≤ N ∧ f^[i] w = f^[j] w := by
  by_contra hcon
  push_neg at hcon
  have hinj : Function.Injective (fun i : Fin (N+1) => f^[(i : ℕ)] w) := by
    intro a b hab
    by_contra hne
    rcases Nat.lt_trichotomy (a : ℕ) (b : ℕ) with h | h | h
    · exact hcon a b h (by have := b.isLt; omega) hab
    · exact hne (Fin.ext h)
    · exact hcon b a h (by have := a.isLt; omega) hab.symm
  have := Fintype.card_le_of_injective _ hinj
  simp at this

#print axioms orbit_repeat

-- C: bisect the BiLasso choice source
theorem length_pos_int' {α : Type} {l : List α} (hl : l ≠ []) : (0:ℤ) < (l.length : ℤ) := by
  have : l.length ≠ 0 := fun h => hl (List.eq_nil_of_length_eq_zero h)
  exact_mod_cast Nat.pos_of_ne_zero this
#print axioms length_pos_int'
#print axioms List.eq_nil_of_length_eq_zero
