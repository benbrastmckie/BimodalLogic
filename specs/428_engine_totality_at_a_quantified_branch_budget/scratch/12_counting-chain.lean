/-
SCRATCH — Phase 12's counting chain. NOT part of the library build.
-/
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace Scratch428Count

open FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- The fold every link of the chain uses. -/
theorem fold_le_of_step (f g : Nat → Nat) (n : Nat)
    (hstep : ∀ i < n, f (i + 1) + g i ≤ f i + g (i + 1)) :
    f n + g 0 ≤ f 0 + g n := by
  induction n with
  | zero => exact Nat.le_refl _
  | succ k ih =>
    have hk := hstep k (Nat.lt_succ_self k)
    have hih := ih (fun i hi => hstep i (Nat.lt_succ_of_lt hi))
    omega

/-! ### Link 1 -/

theorem identStep_le {ident kt mints ident' kt' : Nat}
    (hi : ident' = ident + 1) (hk : kt' < kt) :
    (ident' + kt') + mints ≤ (ident + kt) + mints := by omega

theorem mintStep_le {ident kt mints kt' : Nat} (hk : kt' ≤ kt + 1) :
    (ident + kt') + mints ≤ (ident + kt) + (mints + 1) := by omega

theorem plainStep_le {ident kt mints kt' : Nat} (hk : kt' ≤ kt) :
    (ident + kt') + mints ≤ (ident + kt) + mints := by omega

theorem idents_le_knownTimes_add_mints (kt ident mints : Nat → Nat) (n : Nat)
    (h0 : ident 0 = 0) (hm0 : mints 0 = 0)
    (hstep : ∀ i < n, (ident (i + 1) + kt (i + 1)) + mints i
      ≤ (ident i + kt i) + mints (i + 1)) :
    ident n ≤ kt 0 + mints n := by
  have h := fold_le_of_step (fun i => ident i + kt i) mints n hstep
  omega

theorem knownTimes_card_lt_at_arm3 {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) :
    ((b.identifyTime t₂ t₁).knownTimes).toFinset.card < (b.knownTimes).toFinset.card := by
  obtain ⟨h1, h2, hne, -, -⟩ := firstIncomparablePair_spec htrig
  exact knownTimes_card_lt_identifyTime h1 h2 hne

def derivedTmax (kt0 Ucard : Nat) : Nat := kt0 + 8 * Ucard

theorem derivedTmax_spec (b : Branch) (U : Finset SignedFormula) :
    b.knownTimes.toFinset.card + 8 * U.card
      ≤ derivedTmax (b.knownTimes.toFinset.card) U.card := Nat.le_refl _

/-! ### Link 2 -/

theorem shrinkage_le_card {U : Finset SignedFormula} {b : Branch}
    (hU : ∀ x ∈ b, x ∈ U) (t₁ t₂ : TimeIndex) :
    b.toFinset.card - (b.identifyTime t₂ t₁).toFinset.card ≤ U.card :=
  Nat.le_trans (Nat.sub_le _ _) (card_le_of_subset_universe hU)

theorem shrinkage_total_le (shrink ident : Nat → Nat) (Ucard n : Nat)
    (h0 : shrink 0 = 0) (hi0 : ident 0 = 0)
    (hstep : ∀ i < n, shrink (i + 1) + ident i * Ucard
      ≤ shrink i + ident (i + 1) * Ucard) :
    shrink n ≤ ident n * Ucard := by
  have h := fold_le_of_step shrink (fun i => ident i * Ucard) n hstep
  simp only [hi0, h0, Nat.zero_mul] at h
  omega

/-! ### Link 3 -/

theorem extensions_le (ext card shrink : Nat → Nat) (Ucard n : Nat)
    (h0 : ext 0 = 0) (hs0 : shrink 0 = 0) (hU : card n ≤ Ucard)
    (hstep : ∀ i < n, ext (i + 1) + (card i + shrink i)
      ≤ ext i + (card (i + 1) + shrink (i + 1))) :
    ext n ≤ Ucard + shrink n := by
  have h := fold_le_of_step ext (fun i => card i + shrink i) n hstep
  simp only [h0, hs0] at h
  omega

/-! ### Assembly -/

theorem path_le_of_links (ext ident : Nat → Nat) (Ucard Tmax0 mintBudget shrinkN n : Nat)
    (hext : ext n ≤ Ucard + shrinkN)
    (hshrink : shrinkN ≤ ident n * Ucard)
    (hident : ident n ≤ Tmax0 + mintBudget) :
    ext n + ident n ≤ Ucard + (Tmax0 + mintBudget) * Ucard + (Tmax0 + mintBudget) := by
  have h1 : ident n * Ucard ≤ (Tmax0 + mintBudget) * Ucard := Nat.mul_le_mul_right _ hident
  omega

theorem orderedRunBound_ge (Tmax : Nat) : Tmax ≤ orderedRunBound Tmax := by
  have h : Tmax * 1 ≤ Tmax * (Tmax * Tmax + 1) := Nat.mul_le_mul (Nat.le_refl _) (by omega)
  simp only [orderedRunBound]
  omega

theorem path_le_splitPathBound (Ucard Tmax ext ident : Nat)
    (h : ext + ident ≤ Ucard + Tmax * Ucard + Tmax) :
    ext + ident ≤ splitPathBound Ucard Tmax := by
  have hO := orderedRunBound_ge Tmax
  have hmul : Ucard * Tmax ≤ Ucard * orderedRunBound Tmax :=
    Nat.mul_le_mul (Nat.le_refl _) hO
  have hexp : (Ucard + 1) * (orderedRunBound Tmax + 1)
      = Ucard * orderedRunBound Tmax + Ucard + orderedRunBound Tmax + 1 := by ring
  rw [Nat.mul_comm Tmax Ucard] at h
  simp only [splitPathBound, hexp]
  omega

end Scratch428Count
