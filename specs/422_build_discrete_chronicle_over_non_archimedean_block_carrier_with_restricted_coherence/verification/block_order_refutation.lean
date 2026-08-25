import FormalSystem.Metalogic.BXCanonical.DiscreteCarrierProbe

abbrev T := Bool ×ₗ ℤ

theorem lex_lt (a b : Bool) (m n : ℤ) :
    (toLex (a, m) : T) < toLex (b, n) ↔ (a < b ∨ (a = b ∧ m < n)) :=
  Prod.Lex.toLex_lt_toLex

def P {α : Type} [Preorder α] (x : α) : Prop :=
  ∃ f : ℕ → α, (∀ n, x < f n) ∧ StrictAnti f

theorem P_iso {α β : Type} [Preorder α] [Preorder β] (e : α ≃o β) (x : α) (h : P x) : P (e x) := by
  obtain ⟨f, hf, hmono⟩ := h
  exact ⟨fun n => e (f n), fun n => e.lt_iff_lt.mpr (hf n),
    fun m n hmn => e.lt_iff_lt.mpr (hmono hmn)⟩

theorem P_bot : P (toLex (false, 0) : T) := by
  refine ⟨fun n => toLex (true, -(n : ℤ)), fun n => ?_, ?_⟩
  · rw [lex_lt]; exact Or.inl (by decide)
  · intro m n hmn
    rw [lex_lt]
    exact Or.inr ⟨rfl, by omega⟩

theorem lex_lt' (x y : T) :
    x < y ↔ ((ofLex x).1 < (ofLex y).1 ∨ ((ofLex x).1 = (ofLex y).1 ∧ (ofLex x).2 < (ofLex y).2)) :=
  Prod.Lex.lt_iff

theorem not_true_lt : ∀ b : Bool, ¬ (true < b) := by decide

theorem not_P_top : ¬ P (toLex (true, 0) : T) := by
  rintro ⟨f, hf, hmono⟩
  set g : ℕ → ℤ := fun n => (ofLex (f n)).2 with hg
  have hpos : ∀ n, 0 < g n := by
    intro n
    have h := hf n
    rw [lex_lt'] at h
    rcases h with h | ⟨_, h⟩
    · exact absurd h (not_true_lt _)
    · simpa [hg] using h
  have hanti : ∀ n, g (n + 1) < g n := by
    intro n
    have h := hmono (Nat.lt_succ_self n)
    rw [lex_lt'] at h
    rcases h with h | ⟨_, h⟩
    · -- first coordinates: both must be `true`
      have h1 : (ofLex (f (n+1))).1 = true := by
        have := hf (n+1); rw [lex_lt'] at this
        rcases this with h' | ⟨h', _⟩
        · exact absurd h' (not_true_lt _)
        · simpa using h'.symm
      have h2 : (ofLex (f n)).1 = true := by
        have := hf n; rw [lex_lt'] at this
        rcases this with h' | ⟨h', _⟩
        · exact absurd h' (not_true_lt _)
        · simpa using h'.symm
      rw [h1, h2] at h; simp at h
    · simpa [hg] using h
  have hbound : ∀ n : ℕ, g n ≤ g 0 - n := by
    intro n
    induction n with
    | zero => simp
    | succ k ih =>
      have := hanti k
      push_cast
      omega
  have := hbound (g 0).toNat
  have h0 := hpos (g 0).toNat
  have h00 := hpos 0
  omega

/-- Homogeneity: in a linearly ordered abelian group, translation is an order automorphism. -/
theorem group_homogeneous {G : Type} [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G]
    (a b : G) : ∃ t : G ≃o G, t a = b :=
  ⟨OrderIso.addRight (b - a), by simp⟩

/-- **The refutation.** No linearly ordered abelian group has order type `ℤ + ℤ`. -/
theorem no_ordered_group_carrier {G : Type} [AddCommGroup G] [LinearOrder G]
    [IsOrderedAddMonoid G] (e : G ≃o T) : False := by
  obtain ⟨t, ht⟩ := group_homogeneous (e.symm (toLex (false, 0))) (e.symm (toLex (true, 0)))
  have hE : ((e.symm.trans t).trans e) (toLex (false, 0)) = toLex (true, 0) := by
    simp [ht]
  have hP := P_iso ((e.symm.trans t).trans e) _ P_bot
  rw [hE] at hP
  exact not_P_top hP

#print axioms no_ordered_group_carrier
