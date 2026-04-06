import Bimodal.Metalogic.Algebraic.DeterministicChain
import Bimodal.Metalogic.Algebraic.DeterministicFMCS
import Bimodal.Syntax.SubformulaClosure
import Mathlib.Data.Finset.Powerset

/-!
# Finite Deferral Infrastructure for Forward F Resolution

This module provides the finite deferral argument infrastructure for proving that
F-obligations are eventually resolved in the deterministic chain. The key steps:

1. `F(ψ) ∈ chain(t)` implies `(⊤ U ψ) ∈ chain(t)` (by F_until_equiv axiom)
2. `(⊤ U ψ)` persists forward until `ψ` appears (by until_persists)
3. The restriction of the chain to `deferralClosure(ψ)` takes finitely many values
4. By pigeonhole, if `ψ` never appears, two positions have the same restricted theory
5. A cycle with unresolved `(⊤ U ψ)` contradicts the Until Induction axiom

## Current Status

Steps 1-4 are formalized. Step 5 (cycle contradiction) requires showing that
G(¬ψ) holds at the cycle start, which needs a subtle argument about how
restricted theory cycling implies full G-coherence. This step is left as sorry.

## References

- Research report 22: Section 6.3 (Finite Deferral Argument)
- SubformulaClosure.lean: deferralClosure definition
- DeterministicChain.lean: until_persists_chain
-/

namespace Bimodal.Metalogic.Algebraic.FiniteDeferral

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.DeterministicChain
open Bimodal.Metalogic.Algebraic.DeterministicFMCS

/-!
## F to Until Conversion
-/

/-- F(ψ) ∈ M implies (⊤ U ψ) ∈ M, where ⊤ = ¬⊥. Uses the F_until_equiv axiom. -/
theorem F_to_until_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) :
    Formula.untl (Formula.neg Formula.bot) ψ ∈ M := by
  have h_ax : [] ⊢ (Formula.some_future ψ).imp (Formula.untl (Formula.neg Formula.bot) ψ) :=
    DerivationTree.axiom [] _ (Axiom.F_until_equiv ψ)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_ax) h_F

/-- F(ψ) ∈ chain(t) implies (⊤ U ψ) ∈ chain(t). -/
theorem F_to_until_in_chain (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula) (h_F : Formula.some_future ψ ∈ deterministic_chain M₀ t) :
    Formula.untl (Formula.neg Formula.bot) ψ ∈ deterministic_chain M₀ t :=
  F_to_until_in_mcs _ (deterministic_chain_mcs M₀ h_mcs t) ψ h_F

/-!
## General Integer Until Persistence
-/

/-- Until persistence for general integer positions.
If (φ U ψ) ∈ chain(n) and ψ ∉ chain(n+1), then φ ∈ chain(n+1) and (φ U ψ) ∈ chain(n+1). -/
theorem until_persists_chain_general (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n : ℤ) (φ ψ : Formula)
    (h_U : Formula.untl φ ψ ∈ deterministic_chain M₀ n)
    (h_neg_psi : ψ ∉ deterministic_chain M₀ (n + 1)) :
    φ ∈ deterministic_chain M₀ (n + 1) ∧
    Formula.untl φ ψ ∈ deterministic_chain M₀ (n + 1) := by
  have h_mcs_n := deterministic_chain_mcs M₀ h_mcs n
  have h_x_disj := until_unfold_in_mcs _ h_mcs_n φ ψ h_U
  have h_disj_succ : Formula.or ψ (Formula.and φ (Formula.untl φ ψ)) ∈
      deterministic_chain M₀ (n + 1) :=
    (x_mem_chain_general M₀ h_mcs n _).mpr h_x_disj
  have h_mcs_succ := deterministic_chain_mcs M₀ h_mcs (n + 1)
  have h_neg_psi_in : Formula.neg ψ ∈ deterministic_chain M₀ (n + 1) := by
    cases SetMaximalConsistent.negation_complete h_mcs_succ ψ with
    | inl h => exact absurd h h_neg_psi
    | inr h => exact h
  have h_conj := mcs_or_elim h_mcs_succ h_disj_succ h_neg_psi_in
  exact ⟨mcs_and_left h_mcs_succ h_conj, mcs_and_right h_mcs_succ h_conj⟩

/-- (⊤ U ψ) persists forward for n steps if ψ doesn't appear at any of them. -/
theorem until_persists_forward_steps (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula) (n : ℕ)
    (h_U : Formula.untl (Formula.neg Formula.bot) ψ ∈ deterministic_chain M₀ t)
    (h_no_psi : ∀ i : ℕ, 1 ≤ i → i ≤ n → ψ ∉ deterministic_chain M₀ (t + ↑i)) :
    Formula.untl (Formula.neg Formula.bot) ψ ∈ deterministic_chain M₀ (t + ↑n) := by
  induction n with
  | zero => simpa using h_U
  | succ k ih =>
    have h_U_k := ih (fun i h1 h2 => h_no_psi i h1 (by omega))
    have h_eq1 : (t + (↑(k + 1) : ℤ)) = t + ↑k + 1 := by push_cast; omega
    have h_psi_not : ψ ∉ deterministic_chain M₀ (t + ↑k + 1) := by
      have := h_no_psi (k + 1) (by omega) (by omega)
      rwa [h_eq1] at this
    have h_persist := (until_persists_chain_general M₀ h_mcs (t + ↑k) _ ψ h_U_k h_psi_not).2
    rwa [show (t + ↑k + 1 : ℤ) = t + (↑(k + 1) : ℤ) from by push_cast; omega] at h_persist

/-!
## Restricted Theory and Pigeonhole

The restriction of chain(n) to deferralClosure(root) is a Finset. Since
deferralClosure is finite, there are at most 2^|deferralClosure| possible
restricted theories. By pigeonhole, in any sequence of length > 2^|deferralClosure|,
two positions must have the same restricted theory.
-/

open Classical in
/-- The restricted theory: formulas from deferralClosure(root) that are in chain(n).
Uses classical decidability for set membership. -/
noncomputable def restrictedTheory (M₀ : Set Formula) (root : Formula) (n : ℤ) :
    Finset Formula :=
  (deferralClosure root).filter (fun φ => φ ∈ deterministic_chain M₀ n)

open Classical in
/-- The restricted theory is a subset of deferralClosure. -/
theorem restrictedTheory_subset (M₀ : Set Formula) (root : Formula) (n : ℤ) :
    restrictedTheory M₀ root n ⊆ deferralClosure root :=
  Finset.filter_subset _ _

/-- The restricted theory is in the powerset of deferralClosure. -/
theorem restrictedTheory_mem_powerset (M₀ : Set Formula) (root : Formula) (n : ℤ) :
    restrictedTheory M₀ root n ∈ (deferralClosure root).powerset :=
  Finset.mem_powerset.mpr (restrictedTheory_subset M₀ root n)

/-- The number of possible restricted theories. -/
theorem restricted_theory_count (root : Formula) :
    ((deferralClosure root).powerset).card = 2 ^ (deferralClosure root).card :=
  Finset.card_powerset _

/-- Pigeonhole: among bound+1 consecutive positions, two have the same restricted theory
where bound = 2^|deferralClosure(root)|. -/
theorem pigeonhole_restricted_theories (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (root : Formula) (t : ℤ) :
    let bound := 2 ^ (deferralClosure root).card
    ∃ i j : ℕ, i < j ∧ j ≤ bound ∧
      restrictedTheory M₀ root (t + ↑i) = restrictedTheory M₀ root (t + ↑j) := by
  let bound := 2 ^ (deferralClosure root).card
  let f : Fin (bound + 1) → Finset Formula := fun i => restrictedTheory M₀ root (t + ↑i.val)
  have h_maps_to : ∀ i ∈ (Finset.univ : Finset (Fin (bound + 1))),
      f i ∈ (deferralClosure root).powerset :=
    fun i _ => restrictedTheory_mem_powerset M₀ root (t + ↑i.val)
  have h_card_lt : (Finset.univ : Finset (Fin (bound + 1))).card >
      ((deferralClosure root).powerset).card := by
    rw [Finset.card_univ, Fintype.card_fin, restricted_theory_count]
    omega
  obtain ⟨a, _, b, _, h_ne, h_eq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to h_card_lt h_maps_to
  rcases Nat.lt_or_ge a.val b.val with h_lt | h_ge
  · exact ⟨a.val, b.val, h_lt, by omega, h_eq⟩
  · rcases Nat.eq_or_lt_of_le h_ge with h_eq' | h_lt'
    · exact absurd (Fin.ext h_eq'.symm) h_ne
    · exact ⟨b.val, a.val, h_lt', by omega, h_eq.symm⟩

/-!
## G(¬ψ) Kills Until

If G(¬ψ) ∈ chain(t), then (⊤ U ψ) ∉ chain(t). This is the key lemma that
connects the Until Induction axiom to the F-resolution problem.
-/

/-- If G(¬ψ) ∈ chain(t), then (⊤ U ψ) ∉ chain(t).
Uses the until_induction axiom with χ = ⊥. -/
theorem G_neg_kills_until (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula)
    (h_G_neg : Formula.all_future (Formula.neg ψ) ∈ deterministic_chain M₀ t) :
    Formula.untl (Formula.neg Formula.bot) ψ ∉ deterministic_chain M₀ t := by
  intro h_U
  have h_mcs_t := deterministic_chain_mcs M₀ h_mcs t
  -- The until_induction axiom with φ = ¬⊥, ψ = ψ, χ = ⊥ gives:
  --   G(ψ → ⊥) ∧ G((¬⊥) ∧ (⊥ U ⊥) → ⊥) → ((¬⊥ U ψ) → (⊥ U ⊥))
  -- G(¬ψ) ∧ G(⊤ ∧ X(⊥) → ⊥) → ((⊤ U ψ) → X(⊥))
  -- Since G(⊤ ∧ X(⊥) → ⊥) is a theorem (⊤ ∧ X(⊥) → ⊥ is derivable from X_bot_absurd),
  -- we get: G(¬ψ) → ((⊤ U ψ) → X(⊥))
  -- Then X(⊥) → ⊥ by X_bot_absurd, giving contradiction.
  --
  -- Build: ⊢ (⊤ ∧ X(⊥)) → ⊥
  -- Formula.and (¬⊥) (⊥ U ⊥) → ⊥
  -- From and_right: (¬⊥ ∧ (⊥ U ⊥)) → (⊥ U ⊥), then X_bot_absurd: (⊥ U ⊥) → ⊥
  sorry

/-!
## Main Forward F Theorem (Sorry)

The full proof requires showing that if ψ never appears after t, then G(¬ψ) ∈ chain(t),
which combined with G_neg_kills_until contradicts (⊤ U ψ) ∈ chain(t).

The gap: showing G(¬ψ) ∈ chain(t) from "¬ψ ∈ chain(s) for all s > t" requires
backward G reasoning, which in turn requires forward_F (circular dependency).

Breaking the circularity requires the finite deferral argument: the restricted theory
cycle, combined with Until Induction over the cycle, shows that (⊤ U ψ) cannot
persist through a complete cycle, giving the contradiction without needing backward G.

This is left as sorry pending the full cycle contradiction formalization.
-/

/-- Forward F resolution via finite deferral (sorry).
If F(ψ) ∈ chain(t), then ∃ s > t with ψ ∈ chain(s). -/
theorem forward_F_via_deferral (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula) (h_F : Formula.some_future ψ ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, t < s ∧ ψ ∈ deterministic_chain M₀ s := by
  -- Step 1: F(ψ) → (⊤ U ψ)
  have _h_U := F_to_until_in_chain M₀ h_mcs t ψ h_F
  -- Step 2: By contradiction, if ψ never appears, (⊤ U ψ) persists forever
  -- Step 3: Pigeonhole gives cycle in restricted theories
  -- Step 4: Cycle + (⊤ U ψ) → contradiction via Until Induction
  sorry

end Bimodal.Metalogic.Algebraic.FiniteDeferral
