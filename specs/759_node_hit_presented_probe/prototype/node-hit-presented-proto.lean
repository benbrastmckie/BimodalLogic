import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth
open FormalSystem.Metalogic.Decidability.RaySummary
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness

namespace Proto759

-- closure cardinalities, re-derived
#eval (plusSubformulaClosure Φ).card
#eval (plusSubformulaClosure D).card
#eval (plusSubformulaClosure (PlusFormula.stab Xp)).card

/-- the canonical history `histOf m (t + 1)` sits at `pre m` at time `t` -/
theorem seam_state (m : ℕ) (t : ℤ) : (histOf m (t + 1)).state t = .pre m := by
  rw [histOf_state, canon_of_lt (by omega : t < t + 1)]
  congr 1
  omega

/-- every history through `(z, pre m)` is `histOf (m - i) (z + 1 + i)` for some `i ≤ m` -/
theorem through_pre {σ : WorldHistory F} {m : ℕ} {z : ℤ} (h : σ.state z = .pre m) :
    ∃ i : ℕ, i ≤ m ∧ ∀ s, σ.state s = canon (m - i) (z + 1 + i) s := by
  obtain ⟨k₀, t, hσ⟩ := hist_canon σ
  rw [hσ z] at h
  rcases lt_trichotomy z t with hlt | heq | hgt
  · rw [canon_of_lt hlt] at h
    cases h
    refine ⟨(t - 1 - z).toNat, by omega, ?_⟩
    have e1 : k₀ + (t - 1 - z).toNat - (t - 1 - z).toNat = k₀ := by omega
    have e2 : z + 1 + (((t - 1 - z).toNat : ℕ) : ℤ) = t := by omega
    rw [e1, e2]
    exact hσ
  · subst heq
    rw [canon_self] at h
    cases h
  · rw [canon_of_gt hgt] at h
    cases h

/-- conversely each `histOf (m - i) (t + 1 + i)`, `i ≤ m`, passes through `(t, pre m)` -/
theorem canon_through (m i : ℕ) (hi : i ≤ m) (t : ℤ) :
    (histOf (m - i) (t + 1 + i)).state t = .pre m := by
  rw [histOf_state, canon_of_lt (by omega)]
  congr 1
  omega

/-- a splice passes through the seam -/
theorem spliced_state (τ : WorldHistory F) (t : ℤ) (bf : SeqPair F (τ.state t)) :
    (spliced τ t bf).state t = τ.state t :=
  ((seamOmegaEquiv t (τ.state t)).symm bf).2

/-- every history through the seam is a splice -/
theorem exists_splice_eq (τ : WorldHistory F) (t : ℤ) (σ : WorldHistory F)
    (h : σ.state t = τ.state t) : ∃ bf : SeqPair F (τ.state t), spliced τ t bf = σ := by
  refine ⟨seamOmegaEquiv t (τ.state t) ⟨σ, h⟩, ?_⟩
  exact congrArg Subtype.val ((seamOmegaEquiv t (τ.state t)).symm_apply_apply ⟨σ, h⟩)

/-- `HitCl` at the pre-seam is the finite union over the `m + 1` histories through it -/
theorem hitCl_pre (m : ℕ) (t : ℤ) (k : ℕ) :
    HitCl M (histOf m (t + 1)) t Φ k
      = ⋃ i ∈ Finset.range (m + 1),
          familyTriples (clSig Φ) k (clTrace M Φ t (histOf (m - i) (t + 1 + i))) := by
  ext x
  rw [hitCl_eq_iUnion]
  simp only [Set.mem_iUnion, Finset.mem_range]
  constructor
  · rintro ⟨bf, hx⟩
    have hs : (spliced (histOf m (t + 1)) t bf).state t = .pre m := by
      rw [spliced_state, seam_state]
    obtain ⟨i, hi, hσ⟩ := through_pre hs
    refine ⟨i, by omega, ?_⟩
    have heq : spliced (histOf m (t + 1)) t bf = histOf (m - i) (t + 1 + i) :=
      WorldHistory.ext_state fun s => by rw [hσ s, histOf_state]
    rw [heq] at hx
    exact hx
  · rintro ⟨i, hi, hx⟩
    obtain ⟨bf, hbf⟩ := exists_splice_eq (histOf m (t + 1)) t (histOf (m - i) (t + 1 + i))
      (by rw [canon_through m i (by omega), seam_state])
    exact ⟨bf, by rw [hbf]; exact hx⟩

-- the headline's shape typechecks on the fixture with an arbitrary presentation
example (t : ℤ) (m k : ℕ) {Q : Type} [Fintype Q] [DecidableEq Q]
    (lab : Q → (clSig Φ).preds → Bool) (step : Q → Q → Bool) : Prop :=
  HitPresented M (histOf m (t + 1)) t Φ lab step k

-- the count the design names, as a well-formed term
noncomputable example (k : ℕ) : ℕ := Nat.card (KType (clSig Φ) k)

#print axioms hitCl_pre
#print axioms through_pre


-- a computable letter table over the closure alphabet, by pattern matching as `clTrace` does
def ℓtest : (clSig Φ).preds → Bool
  | .inl ψ => decide (ψ.1 ∈ [Fp, p, A'])
  | .inr () => false

#eval ℓtest (clNow Φ)
#eval ℓtest (clLetter Φ (self_mem_plusSubformulaClosure Φ))

-- the exact library signatures the route composes
#check @mem_hitOf_iff
#check @familyTriples_subset_deleteRun
#check @kTypeOf_listSeg_replicate_eventually_periodic_bounded
#check @segZ_const_of_kTypeOf_eq_replicate
#check @hitPresented_of_presented
#check @Presented
#check @hitCl_eq_iUnion

-- the closure members, if `Repr` is available
#eval (PlusFormula.subformulas Φ).eraseDups.length

end Proto759
