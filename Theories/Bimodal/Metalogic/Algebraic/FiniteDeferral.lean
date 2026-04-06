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
  -- until_induction with φ = ¬⊥, ψ = ψ, χ = ⊥:
  --   G(ψ → ⊥) ∧ G((¬⊥ ∧ (⊥ U ⊥)) → ⊥) → ((¬⊥ U ψ) → (⊥ U ⊥))
  -- Note: ψ → ⊥ = ψ.neg, and G(ψ.neg) = h_G_neg
  -- Note: (¬⊥ ∧ (⊥ U ⊥)) → ⊥ is derivable (X_bot_absurd gives (⊥ U ⊥) → ⊥,
  --   and conjunction right projection + chain gives the implication)
  let step_formula := (Formula.and (Formula.neg Formula.bot) (Formula.untl Formula.bot Formula.bot)).imp Formula.bot
  -- Step 1: Derive ⊢ step_formula
  -- mcs_and_right gives us (A ∧ B) ∈ M → B ∈ M, but we need a theorem-level version.
  -- Instead: ⊥ U ⊥ → ⊥ (X_bot_absurd). We need (¬⊥ ∧ (⊥ U ⊥)) → ⊥.
  -- Use: (¬⊥ ∧ (⊥ U ⊥)) → (⊥ U ⊥) (right proj) then chain with ⊥ U ⊥ → ⊥.
  -- Right projection: ¬(A → ¬B) → B is Peirce-derivable.
  -- Simpler: use by_contra at MCS level. If step_formula ∉ chain(t), then ¬step_formula ∈ chain(t).
  -- But step_formula is a theorem, so it must be in chain(t).
  -- Actually: step_formula = (¬⊥ ∧ (⊥ U ⊥)) → ⊥. If ¬⊥ ∧ (⊥ U ⊥) ∈ M, then (⊥ U ⊥) ∈ M
  -- (by mcs_and_right), then ⊥ ∈ M by X_bot_absurd. Contradiction with MCS consistency.
  -- So ¬⊥ ∧ (⊥ U ⊥) ∉ M for any MCS. Hence (¬⊥ ∧ (⊥ U ⊥)) → ⊥ ∈ M (vacuously, by MCS negation completeness).
  have h_step_in : step_formula ∈ deterministic_chain M₀ t := by
    -- step_formula = (¬⊥ ∧ (⊥ U ⊥)).imp ⊥ = (¬⊥ ∧ (⊥ U ⊥)).neg
    -- Suffices to show ¬⊥ ∧ (⊥ U ⊥) ∉ chain(t), then by negation completeness.
    rcases SetMaximalConsistent.negation_complete h_mcs_t
      (Formula.and (Formula.neg Formula.bot) (Formula.untl Formula.bot Formula.bot)) with h | h
    · -- ¬⊥ ∧ (⊥ U ⊥) ∈ chain(t) → contradiction
      have h_xbot := mcs_and_right h_mcs_t h
      have h_bot := SetMaximalConsistent.implication_property h_mcs_t
        (theorem_in_mcs h_mcs_t Bimodal.Theorems.TemporalDerived.X_bot_absurd) h_xbot
      exact (Bimodal.Metalogic.Algebraic.UltrafilterChain.bot_not_in_mcs _ h_mcs_t h_bot).elim
    · -- ¬(¬⊥ ∧ (⊥ U ⊥)) ∈ chain(t), which is step_formula
      exact h
  -- Step 2: G(step_formula) ∈ chain(t) by temporal necessitation + forward_G
  -- Actually, we need G(step_formula) ∈ chain(t). Since step_formula ∈ chain(s) for ALL s
  -- (it's always provable by the same argument), we can derive G(step_formula).
  -- But we can't prove "for all s" without forward_F. Instead, use:
  -- step_formula is a tautology, so it's derivable, so G(step_formula) is derivable.
  -- Hmm, but step_formula is NOT syntactically a theorem -- it requires MCS reasoning.
  -- Alternative: use MCS conjunction. We need G(¬ψ) ∧ G(step) ∈ chain(t).
  -- If both G(¬ψ) and G(step) are in chain(t), the conjunction is too.
  -- G(¬ψ) = h_G_neg. G(step): we need this.
  -- G(step) would require step ∈ chain(s) for all s > t, which we showed above for each s.
  -- But to get G(step) ∈ chain(t), we need the backward G derivation again...
  -- UNLESS step_formula is actually derivable as a theorem (⊢ step_formula).
  -- Let's try: step_formula = (¬⊥ ∧ (⊥ U ⊥)) → ⊥.
  -- ¬⊥ ∧ (⊥ U ⊥) = ¬(¬⊥ → ¬(⊥ U ⊥)). Hmm.
  -- By Peirce + ex_falso: from (⊥ U ⊥) → ⊥ and ⊢ A ∧ B → B, get (¬⊥ ∧ (⊥ U ⊥)) → ⊥.
  -- We DO have ⊢ (⊥ U ⊥) → ⊥ (X_bot_absurd).
  -- We need ⊢ (¬⊥ ∧ (⊥ U ⊥)) → (⊥ U ⊥). This is conjunction right projection.
  -- Conjunction right projection as a theorem is needed.
  -- (A ∧ B) = ¬(A → ¬B). So ⊢ ¬(A → ¬B) → B.
  -- This IS derivable in classical logic but needs some work.
  -- Use theorem_app1: ⊢ A → ((A → B) → B). With A = (A' → ¬B) and B = ⊥:
  -- ⊢ (A' → ¬B) → (((A' → ¬B) → ⊥) → ⊥). This is dn_intro applied to (A' → ¬B).
  -- Hmm, that gives ⊢ (A' → ¬B) → ¬¬(A' → ¬B). Not helpful.
  -- Let me try another route: use Peirce.
  -- ⊢ ((B → ⊥) → (A' → (B → ⊥))) is prop_s
  -- ⊢ ¬B → (A' → ¬B) by prop_s
  -- Contrapositive: ⊢ ¬(A' → ¬B) → ¬¬B by... needs contrapositive theorem.
  -- Then ¬¬B → B by DNE. Chain: ¬(A' → ¬B) → B.
  -- So: ⊢ (A ∧ B) → B is dn_intro composed with contraposition of prop_s composed with dne.
  -- Let me just build it carefully using SetMaximalConsistent.contrapositive.
  -- Actually, I realize I can avoid all this by working differently.
  -- Instead of building G(step), I can observe that until_induction gives a THEOREM:
  --   ⊢ G(¬ψ) ∧ G(step) → ((¬⊥ U ψ) → (⊥ U ⊥))
  -- And step IS derivable as a theorem (though proving it is complex).
  -- So G(step) is derivable by temporal necessitation, hence in any MCS.
  -- Let me just sorry the derivation of step_formula and continue.
  -- Wait, I already showed step_formula ∈ chain(t) above. But I need G(step_formula) ∈ chain(t).
  -- Since step_formula is equivalent to a derivable statement... actually let me just
  -- derive it properly.
  -- ⊢ (⊥ U ⊥) → ⊥  (X_bot_absurd)
  -- Need: ⊢ (¬⊥ ∧ (⊥ U ⊥)) → (⊥ U ⊥)
  -- Then chain: ⊢ (¬⊥ ∧ (⊥ U ⊥)) → ⊥
  -- (¬⊥ ∧ (⊥ U ⊥)) = ¬((¬⊥) → ¬(⊥ U ⊥))
  -- ⊢ ¬((¬⊥) → ¬(⊥ U ⊥)) → (⊥ U ⊥)
  -- Use: ⊢ (⊥ U ⊥) → ((¬⊥) → (⊥ U ⊥))  [prop_s]
  -- Contrapositive: ⊢ ¬((¬⊥) → (⊥ U ⊥)) → ¬(⊥ U ⊥)   [hmm, wrong direction]
  -- Actually: ⊢ ¬(⊥ U ⊥) → ((¬⊥) → ¬(⊥ U ⊥))  [prop_s]
  -- Contrapositive: ⊢ ¬((¬⊥) → ¬(⊥ U ⊥)) → ¬¬(⊥ U ⊥)
  -- Then DNE: ⊢ ¬¬(⊥ U ⊥) → (⊥ U ⊥)
  -- Chain: ⊢ ¬((¬⊥) → ¬(⊥ U ⊥)) → (⊥ U ⊥)
  -- This IS the conjunction right projection!
  -- So: ⊢ (¬⊥ ∧ (⊥ U ⊥)) → (⊥ U ⊥) follows from prop_s contrapositive + DNE.
  -- Build it:
  have h_and_right_thm : [] ⊢ (Formula.and (Formula.neg Formula.bot) (Formula.untl Formula.bot Formula.bot)).imp (Formula.untl Formula.bot Formula.bot) := by
    -- (A ∧ B) = ¬(A → ¬B). Goal: ¬(A → ¬B) → B
    -- prop_s: ⊢ ¬B → (A → ¬B)
    -- contrapositive: ⊢ ¬(A → ¬B) → ¬¬B
    -- DNE: ⊢ ¬¬B → B
    -- chain
    let A := Formula.neg Formula.bot
    let B := Formula.untl Formula.bot Formula.bot
    have h_s : [] ⊢ B.neg.imp (A.imp B.neg) := DerivationTree.axiom [] _ (Axiom.prop_s B.neg A)
    -- contrapositive of h_s: ¬(A → ¬B) → ¬¬B
    -- To get this, use: h_s is ⊢ ¬B → (A → ¬B). We want ⊢ ¬(A → ¬B) → ¬¬B.
    -- This is the contrapositive. In our system:
    -- dn_intro on (A → ¬B): ⊢ (A → ¬B) → ¬¬(A → ¬B)
    -- b_combinator: ⊢ ((A → ¬B) → ¬¬(A → ¬B)) → ((¬B → (A → ¬B)) → (¬B → ¬¬(A → ¬B)))
    -- ... this is getting circular. Let me use the MCS-level argument instead.
    -- Actually, SetMaximalConsistent.contrapositive gives us MCS-level contrapositive.
    -- But we need theorem-level. Use Peirce.
    -- Peirce: ⊢ ((B → C) → B) → B  for any C.
    -- Choose C = ⊥: ⊢ ((B → ⊥) → B) → B = ⊢ (¬B → B) → B
    -- From (A ∧ B) = ¬(A → ¬B): need ¬(A → ¬B) → B
    -- Suffices: ¬(A → ¬B) → (¬B → B)  [then chain with Peirce]
    -- ¬(A → ¬B) → ¬B → B: from ¬B and (¬(A → ¬B)), we need B.
    -- ¬B gives A → ¬B (by prop_s), contradicting ¬(A → ¬B). So ⊥, then B by ex_falso.
    -- In Hilbert style: ¬(A → ¬B) → (¬B → ⊥) by theorem_app1-like reasoning
    -- Then chain with ex_falso to get ¬(A → ¬B) → (¬B → B)
    -- Then chain with Peirce to get ¬(A → ¬B) → B.
    -- ¬(A → ¬B) → (¬B → ⊥):
    -- prop_s: ⊢ ¬B → (A → ¬B)
    -- theorem_app1: ⊢ (A → ¬B) → (((A → ¬B) → ⊥) → ⊥)  -- which is dn_intro
    -- chain: ⊢ ¬B → (¬(A → ¬B) → ⊥)
    -- flip: ⊢ ¬(A → ¬B) → (¬B → ⊥) = ⊢ ¬(A → ¬B) → ¬¬B
    -- Then DNE: ⊢ ¬¬B → B.
    -- Chain: ⊢ ¬(A → ¬B) → B.
    -- This works! Let me build it.
    have h_dn := Bimodal.Theorems.Combinators.dni (A.imp B.neg)
    -- h_dn: ⊢ (A → ¬B) → ¬¬(A → ¬B)
    have h_chain1 := Bimodal.Theorems.Combinators.imp_trans h_s h_dn
    -- h_chain1: ⊢ ¬B → ¬¬(A → ¬B)
    -- ¬¬(A → ¬B) = ((A → ¬B) → ⊥) → ⊥ = ¬(A → ¬B).neg
    -- So h_chain1: ⊢ B.neg → ((A.imp B.neg).neg).neg
    -- Flip: ⊢ (A.imp B.neg).neg → B.neg.neg
    -- Actually h_chain1 IS ⊢ B.neg → (A.imp B.neg).neg.neg
    -- Which is ⊢ ¬B → ¬¬(A → ¬B)
    -- Flip (using theorem_flip): ⊢ ¬(A → ¬B) → ¬¬B
    -- Hmm, the flip doesn't directly apply here. Let me think again.
    -- h_chain1: ⊢ B.neg → ((A.imp B.neg).imp ⊥).imp ⊥
    -- i.e., ⊢ B.neg → (¬(A → ¬B) → ⊥)  ... wait no.
    -- dni gives ⊢ X → (X → ⊥) → ⊥ = ⊢ X → ¬¬X = ⊢ X → X.neg.neg
    -- h_dn: ⊢ (A → ¬B) → ((A → ¬B) → ⊥) → ⊥
    --      = ⊢ (A → ¬B) → ¬(A → ¬B) → ⊥
    --      = ⊢ (A.imp B.neg) → (A.imp B.neg).neg → ⊥
    -- h_chain1 = imp_trans h_s h_dn: ⊢ ¬B → (¬(A → ¬B) → ⊥)
    -- Now flip (theorem_flip): ⊢ (¬B → (¬(A → ¬B) → ⊥)) → (¬(A → ¬B) → (¬B → ⊥))
    have h_flip := @Bimodal.Theorems.Combinators.theorem_flip B.neg (A.imp B.neg).neg Formula.bot
    have h_contra : [] ⊢ (A.imp B.neg).neg.imp (B.neg.imp Formula.bot) :=
      Bimodal.Theorems.Combinators.mp h_chain1 h_flip
    -- h_contra: ⊢ ¬(A → ¬B) → (¬B → ⊥) = ⊢ (A ∧ B) → ¬¬B
    -- Chain with DNE: ⊢ ¬¬B → B
    have h_dne := dne_theorem B
    exact Bimodal.Theorems.Combinators.imp_trans h_contra h_dne
  -- Now: ⊢ (¬⊥ ∧ (⊥ U ⊥)) → (⊥ U ⊥), and ⊢ (⊥ U ⊥) → ⊥
  have h_step_thm : [] ⊢ step_formula :=
    Bimodal.Theorems.Combinators.imp_trans h_and_right_thm Bimodal.Theorems.TemporalDerived.X_bot_absurd
  -- G(step_formula) by temporal necessitation
  have h_G_step : [] ⊢ Formula.all_future step_formula :=
    DerivationTree.temporal_necessitation _ h_step_thm
  -- G(step_formula) ∈ chain(t)
  have h_G_step_in := theorem_in_mcs h_mcs_t h_G_step
  -- Build conjunction: G(¬ψ) ∧ G(step) ∈ chain(t)
  have h_conj := SetMaximalConsistent.implication_property h_mcs_t
    (SetMaximalConsistent.implication_property h_mcs_t
      (theorem_in_mcs h_mcs_t (Bimodal.Theorems.Combinators.pairing _ _))
      h_G_neg) h_G_step_in
  -- until_induction axiom: G(¬ψ) ∧ G(step) → ((¬⊥ U ψ) → (⊥ U ⊥))
  have h_ax := DerivationTree.axiom [] _ (Axiom.until_induction (Formula.neg Formula.bot) ψ Formula.bot)
  have h_imp := SetMaximalConsistent.implication_property h_mcs_t
    (theorem_in_mcs h_mcs_t h_ax) h_conj
  -- (¬⊥ U ψ) → (⊥ U ⊥) ∈ chain(t), apply to h_U
  have h_X_bot := SetMaximalConsistent.implication_property h_mcs_t h_imp h_U
  -- (⊥ U ⊥) → ⊥
  have h_bot := SetMaximalConsistent.implication_property h_mcs_t
    (theorem_in_mcs h_mcs_t Bimodal.Theorems.TemporalDerived.X_bot_absurd) h_X_bot
  exact Bimodal.Metalogic.Algebraic.UltrafilterChain.bot_not_in_mcs _ h_mcs_t h_bot

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

/-- **SORRY**: Forward F resolution via finite deferral.
If F(ψ) ∈ chain(t), then ∃ s > t with ψ ∈ chain(s).

**Status**: Open formalization problem. Semantically true but syntactically requires
breaking a circularity between forward_F and backward G reasoning.

**Infrastructure available** (sorry-free):
- `F_to_until_in_chain`: F(ψ) → (⊤ U ψ) in the chain
- `until_persists_forward_steps`: (⊤ U ψ) persists for n steps
- `pigeonhole_restricted_theories`: restricted theories must cycle
- `G_neg_kills_until`: G(¬ψ) kills (⊤ U ψ) via Until Induction

**The gap**: Deriving G(¬ψ) ∈ chain(t) from "¬ψ ∈ chain(s) for all s > t" requires
`temporal_backward_G_with_fwd_F`, which takes forward_F as a hypothesis — but
forward_F is what we are trying to prove. The circularity is genuine.

**Approaches considered**:
1. Direct backward G via `temporal_backward_G_with_fwd_F` — circular
2. Well-founded induction on formula complexity — F(ψ) and G(¬ψ) have comparable complexity
3. Restricted completeness via `restricted_temporally_coherent` — avoids forward_F but
   requires separate restricted chain construction
4. Quasimodel approach (GHR 1994) — builds explicit witness sets, avoids the chain
   architecture entirely, but requires ~1000 lines of new infrastructure

**Recommended next step**: Approach (4), the quasimodel construction, is the standard
method in the literature for discrete temporal completeness. It avoids the incremental
chain construction and builds a global canonical model with explicit F-witnesses. -/
theorem forward_F_via_deferral (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula) (h_F : Formula.some_future ψ ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, t < s ∧ ψ ∈ deterministic_chain M₀ s := by
  sorry

end Bimodal.Metalogic.Algebraic.FiniteDeferral
