import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Syntax.Formula
import Bimodal.ProofSystem.Axioms
import Bimodal.ProofSystem.Derivation

/-!
# Deterministic Chain Construction

This module defines the deterministic chain construction for discrete completeness.
Given an MCS M_0, the chain assigns an MCS to every integer:
- `chain(0) = M_0`
- `chain(n+1) = x_content(chain(n))` (forward via Next operator X)
- `chain(-(n+1)) = y_content(chain(-n))` (backward via Yesterday operator Y)

The X-K and X-Det axioms ensure x_content(M) is MCS when M is MCS (and
symmetrically Y-K/Y-Det for y_content). This eliminates the need for
Lindenbaum extension at each step, giving a deterministic construction.

## Key Properties

- Every chain element is MCS
- x_content linkage: `chain(n+1) = x_content(chain(n))`
- Until persistence: if `(φ U ψ) ∈ chain(n)` and `ψ ∉ chain(n+1)`,
  then `φ ∈ chain(n+1)` and `(φ U ψ) ∈ chain(n+1)`
- Since persistence: symmetric for backward direction

## Dependencies

Assumes `x_content_mcs` and `y_content_mcs` from Phase 2 (TemporalContent).
These are currently axiomatized here; Phase 2 will provide the actual proofs.
-/

namespace Bimodal.Metalogic.Algebraic.DeterministicChain

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/-!
## Deterministic Chain Definition
-/

/-- Iterate x_content n times starting from M. -/
noncomputable def iterate_x_content (M : Set Formula) : ℕ → Set Formula
  | 0 => M
  | n + 1 => x_content (iterate_x_content M n)

/-- Iterate y_content n times starting from M. -/
noncomputable def iterate_y_content (M : Set Formula) : ℕ → Set Formula
  | 0 => M
  | n + 1 => y_content (iterate_y_content M n)

/-- Deterministic chain: maps every integer to an MCS.
- Non-negative n: iterate x_content n times from M_0
- Negative -(n+1): iterate y_content (n+1) times from M_0 -/
noncomputable def deterministic_chain (M₀ : Set Formula) : ℤ → Set Formula
  | (n : ℕ) => iterate_x_content M₀ n
  | Int.negSucc n => iterate_y_content M₀ (n + 1)

/-!
## Basic Properties
-/

@[simp]
theorem deterministic_chain_zero (M₀ : Set Formula) :
    deterministic_chain M₀ 0 = M₀ := rfl

theorem deterministic_chain_nat_succ (M₀ : Set Formula) (n : ℕ) :
    deterministic_chain M₀ (↑(n + 1)) = x_content (deterministic_chain M₀ ↑n) := rfl

theorem deterministic_chain_negSucc_zero (M₀ : Set Formula) :
    deterministic_chain M₀ (Int.negSucc 0) = y_content M₀ := rfl

theorem deterministic_chain_negSucc_succ (M₀ : Set Formula) (n : ℕ) :
    deterministic_chain M₀ (Int.negSucc (n + 1)) =
      y_content (deterministic_chain M₀ (Int.negSucc n)) := rfl

/-!
## x_content Linkage

The fundamental property: chain(n+1) = x_content(chain(n)) for all integers n.
For non-negative n this is definitional. For negative n, we need to show
the y_content chain interleaves correctly.
-/

/-- For natural numbers, chain(n+1) = x_content(chain(n)) by definition. -/
theorem chain_succ_eq_x_content_nat (M₀ : Set Formula) (n : ℕ) :
    deterministic_chain M₀ (↑n + 1) = x_content (deterministic_chain M₀ ↑n) := by
  simp only [deterministic_chain]
  -- ↑n + 1 = ↑(n + 1) as integers
  norm_cast

/-!
## MCS Property

Every element of the deterministic chain is MCS.
-/

/-- iterate_x_content preserves MCS. -/
theorem iterate_x_content_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ n : ℕ, SetMaximalConsistent (iterate_x_content M n) := by
  intro n
  induction n with
  | zero => exact h_mcs
  | succ n ih => exact x_content_mcs ih

/-- iterate_y_content preserves MCS. -/
theorem iterate_y_content_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ n : ℕ, SetMaximalConsistent (iterate_y_content M n) := by
  intro n
  induction n with
  | zero => exact h_mcs
  | succ n ih => exact y_content_mcs ih

/-- Every element of the deterministic chain is MCS. -/
theorem deterministic_chain_mcs (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    ∀ n : ℤ, SetMaximalConsistent (deterministic_chain M₀ n) := by
  intro n
  cases n with
  | ofNat n => exact iterate_x_content_mcs M₀ h_mcs n
  | negSucc n => exact iterate_y_content_mcs M₀ h_mcs (n + 1)

/-!
## x_content Membership Characterization

φ ∈ chain(n+1) ↔ X(φ) ∈ chain(n), where X(φ) = ⊥ U φ.
-/

/-- Forward x_content membership for natural chain positions. -/
theorem mem_chain_succ_iff_x_mem_chain (M₀ : Set Formula) (n : ℕ) (φ : Formula) :
    φ ∈ deterministic_chain M₀ (↑(n + 1)) ↔
      Formula.untl Formula.bot φ ∈ deterministic_chain M₀ ↑n := by
  simp only [deterministic_chain, iterate_x_content, mem_x_content_iff]

/-!
## Until Persistence

If (φ U ψ) ∈ chain(n), then by until_unfold:
  X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(n)
So (ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(n+1) = x_content(chain(n)).

If ψ ∉ chain(n+1), then (φ ∧ (φ U ψ)) ∈ chain(n+1), giving both
φ ∈ chain(n+1) and (φ U ψ) ∈ chain(n+1).
-/

/-- Until unfold gives X(ψ ∨ (φ ∧ (φ U ψ))) ∈ M when (φ U ψ) ∈ M. -/
theorem until_unfold_x_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_U : Formula.untl φ ψ ∈ M) :
    Formula.untl Formula.bot (Formula.or ψ (Formula.and φ (Formula.untl φ ψ))) ∈ M :=
  until_unfold_in_mcs M h_mcs φ ψ h_U

/-- Since unfold gives Y(ψ ∨ (φ ∧ (φ S ψ))) ∈ M when (φ S ψ) ∈ M. -/
theorem since_unfold_y_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_S : Formula.snce φ ψ ∈ M) :
    Formula.snce Formula.bot (Formula.or ψ (Formula.and φ (Formula.snce φ ψ))) ∈ M :=
  since_unfold_in_mcs M h_mcs φ ψ h_S

/-- Disjunction elimination in MCS: if (a ∨ b) ∈ M and ¬a ∈ M, then b ∈ M.
    Note: a ∨ b = ¬a → b, so this is just implication_property. -/
theorem mcs_or_elim {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    {a b : Formula} (h_or : Formula.or a b ∈ M) (h_neg_a : Formula.neg a ∈ M) :
    b ∈ M := by
  -- Formula.or a b = a.neg.imp b
  exact SetMaximalConsistent.implication_property h_mcs h_or h_neg_a

/-- Conjunction left elimination in MCS: if (a ∧ b) ∈ M then a ∈ M.
    Note: a ∧ b = ¬(a → ¬b), i.e., (a.imp b.neg).neg. -/
theorem mcs_and_left {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    {a b : Formula} (h_and : Formula.and a b ∈ M) :
    a ∈ M := by
  -- Formula.and a b = (a.imp b.neg).neg
  -- If a ∉ M, then ¬a ∈ M (negation completeness).
  -- From ¬a, derive (a → ¬b) via ex_falso chain, so (a → ¬b) ∈ M.
  -- But ¬(a → ¬b) ∈ M, contradiction.
  by_contra h_not_a
  have h_neg_a : Formula.neg a ∈ M := by
    cases SetMaximalConsistent.negation_complete h_mcs a with
    | inl h => exact absurd h h_not_a
    | inr h => exact h
  -- Derive: [¬a] ⊢ a → ¬b
  -- ¬a = a.imp ⊥, so [a → ⊥] ⊢ a → (b → ⊥)
  -- Proof: assume a, then MP with (a → ⊥) to get ⊥, then ex_falso to get b → ⊥
  -- But this requires working in context [a, ¬a], which needs deduction theorem.
  -- Use closed_under_derivation with a derivation from [¬a] ⊢ (a → ¬b)
  have h_imp_deriv : DerivationTree [Formula.neg a] (a.imp b.neg) := by
    -- ¬a = a.imp ⊥. We need [a.imp ⊥] ⊢ a.imp (b.imp ⊥)
    -- Use prop_k: ⊢ (a.imp ⊥).imp (a.imp (b.imp ⊥)) ... no that's not right.
    -- Actually: [a → ⊥] ⊢ a → b → ⊥
    -- Deduction theorem: need [a → ⊥, a] ⊢ b → ⊥
    -- From [a → ⊥, a]: MP gives ⊥. Then ex_falso gives b → ⊥.
    -- So we need: [a → ⊥, a] ⊢ ⊥, then deduction theorem twice.
    -- [a.neg] ⊢ a → b.neg via deduction theorem from [a, a.neg] ⊢ b.neg
    apply deduction_theorem [a.neg] a b.neg
    -- [a, a.neg] ⊢ b.neg = [a, a → ⊥] ⊢ b → ⊥
    -- From [a, a→⊥], MP gives ⊥. Then ex_falso gives b → ⊥.
    have h1 : DerivationTree [a, a.neg] a := DerivationTree.assumption _ _ (by simp)
    have h2 : DerivationTree [a, a.neg] a.neg := DerivationTree.assumption _ _ (by simp)
    have h3 : DerivationTree [a, a.neg] Formula.bot :=
      DerivationTree.modus_ponens _ _ _ h2 h1
    have h4 : DerivationTree [a, a.neg] (Formula.bot.imp b.neg) :=
      DerivationTree.axiom _ _ (Axiom.ex_falso b.neg)
    exact DerivationTree.modus_ponens _ _ _ h4 h3
  -- From (a → ¬b) ∈ M and ¬(a → ¬b) ∈ M, contradiction
  have h_imp_in_M := SetMaximalConsistent.closed_under_derivation h_mcs
    [Formula.neg a] (by intro χ hχ; simp at hχ; exact hχ ▸ h_neg_a) h_imp_deriv
  exact set_consistent_not_both h_mcs.1 (a.imp b.neg) h_imp_in_M h_and

/-- Conjunction right elimination in MCS: if (a ∧ b) ∈ M then b ∈ M. -/
theorem mcs_and_right {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    {a b : Formula} (h_and : Formula.and a b ∈ M) :
    b ∈ M := by
  -- a ∧ b = ¬(a → ¬b). If b ∉ M then ¬b ∈ M.
  -- From a ∈ M (by mcs_and_left) and ¬b ∈ M, derive (a → ¬b) ∈ M via MP.
  -- But ¬(a → ¬b) ∈ M, contradiction.
  by_contra h_not_b
  have h_neg_b : Formula.neg b ∈ M := by
    cases SetMaximalConsistent.negation_complete h_mcs b with
    | inl h => exact absurd h h_not_b
    | inr h => exact h
  have h_a := mcs_and_left h_mcs h_and
  -- Derive [a, ¬b] ⊢ (a → ¬b), which is trivially ⊢ a → (a → ¬b) → ¬b... no.
  -- We need (a → ¬b) ∈ M. Derive: [¬b] ⊢ a → ¬b using prop axioms.
  -- ¬b = b.imp ⊥. We need [b → ⊥] ⊢ a → (b → ⊥).
  -- This is ⊢ (b → ⊥) → (a → (b → ⊥)) which is prop_k b.neg a.
  -- prop_s gives ⊢ ¬b → (a → ¬b)
  have h_k : DerivationTree [] (b.neg.imp (a.imp b.neg)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s b.neg a)
  have h_imp_in_M := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_k) h_neg_b
  -- Now (a → ¬b) ∈ M, but ¬(a → ¬b) ∈ M (= a ∧ b), contradiction
  exact set_consistent_not_both h_mcs.1 (a.imp b.neg) h_imp_in_M h_and

/--
Until persistence through the deterministic chain (natural number positions).

If (φ U ψ) ∈ chain(n) and ψ ∉ chain(n+1), then both φ ∈ chain(n+1)
and (φ U ψ) ∈ chain(n+1).
-/
theorem until_persists_chain (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n : ℕ) (φ ψ : Formula)
    (h_U : Formula.untl φ ψ ∈ deterministic_chain M₀ ↑n)
    (h_neg_psi : ψ ∉ deterministic_chain M₀ (↑n + 1)) :
    φ ∈ deterministic_chain M₀ (↑n + 1) ∧
    Formula.untl φ ψ ∈ deterministic_chain M₀ (↑n + 1) := by
  -- Get the chain(n) MCS hypothesis
  have h_mcs_n := deterministic_chain_mcs M₀ h_mcs ↑n
  -- By until_unfold: X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(n)
  have h_x_disj := until_unfold_x_in_mcs _ h_mcs_n φ ψ h_U
  -- So (ψ ∨ (φ ∧ (φ U ψ))) ∈ x_content(chain(n)) = chain(n+1)
  have h_mcs_succ := deterministic_chain_mcs M₀ h_mcs (↑n + 1)
  -- The X-formula is: ⊥ U (ψ ∨ (φ ∧ (φ U ψ)))
  -- So (ψ ∨ (φ ∧ (φ U ψ))) ∈ x_content(chain(n))
  have h_disj_in_succ : Formula.or ψ (Formula.and φ (Formula.untl φ ψ)) ∈
      deterministic_chain M₀ (↑n + 1) := by
    show Formula.or ψ (Formula.and φ (Formula.untl φ ψ)) ∈
      deterministic_chain M₀ (↑(n + 1))
    rw [mem_chain_succ_iff_x_mem_chain]
    exact h_x_disj
  -- Since ψ ∉ chain(n+1), ¬ψ ∈ chain(n+1)
  have h_neg_psi_in : Formula.neg ψ ∈ deterministic_chain M₀ (↑n + 1) := by
    cases SetMaximalConsistent.negation_complete h_mcs_succ ψ with
    | inl h => exact absurd h h_neg_psi
    | inr h => exact h
  -- From (ψ ∨ (φ ∧ (φ U ψ))) and ¬ψ, get (φ ∧ (φ U ψ))
  have h_conj : Formula.and φ (Formula.untl φ ψ) ∈ deterministic_chain M₀ (↑n + 1) :=
    mcs_or_elim h_mcs_succ h_disj_in_succ h_neg_psi_in
  -- Extract both conjuncts
  exact ⟨mcs_and_left h_mcs_succ h_conj, mcs_and_right h_mcs_succ h_conj⟩

/--
Since persistence through the deterministic chain (negative positions).

If (φ S ψ) ∈ chain(n) and ψ ∉ chain(n-1), then both φ ∈ chain(n-1)
and (φ S ψ) ∈ chain(n-1).
-/
theorem since_persists_chain (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n : ℕ) (φ ψ : Formula)
    (h_S : Formula.snce φ ψ ∈ deterministic_chain M₀ (Int.negSucc n))
    (h_neg_psi : ψ ∉ deterministic_chain M₀ (Int.negSucc (n + 1))) :
    φ ∈ deterministic_chain M₀ (Int.negSucc (n + 1)) ∧
    Formula.snce φ ψ ∈ deterministic_chain M₀ (Int.negSucc (n + 1)) := by
  -- Symmetric to until_persists_chain
  have h_mcs_n := deterministic_chain_mcs M₀ h_mcs (Int.negSucc n)
  have h_y_disj := since_unfold_y_in_mcs _ h_mcs_n φ ψ h_S
  have h_mcs_pred := deterministic_chain_mcs M₀ h_mcs (Int.negSucc (n + 1))
  -- Y(ψ ∨ (φ ∧ (φ S ψ))) ∈ chain(-n-1) means the disjunction is in y_content(chain(-n-1))
  -- chain(-(n+2)) = y_content(chain(-(n+1)))
  -- So the disjunction is in chain(-(n+2)) iff Y(disj) ∈ chain(-(n+1))
  have h_disj_in_pred : Formula.or ψ (Formula.and φ (Formula.snce φ ψ)) ∈
      deterministic_chain M₀ (Int.negSucc (n + 1)) := by
    simp only [deterministic_chain, iterate_y_content, mem_y_content_iff]
    exact h_y_disj
  have h_neg_psi_in : Formula.neg ψ ∈ deterministic_chain M₀ (Int.negSucc (n + 1)) := by
    cases SetMaximalConsistent.negation_complete h_mcs_pred ψ with
    | inl h => exact absurd h h_neg_psi
    | inr h => exact h
  have h_conj : Formula.and φ (Formula.snce φ ψ) ∈
      deterministic_chain M₀ (Int.negSucc (n + 1)) :=
    mcs_or_elim h_mcs_pred h_disj_in_pred h_neg_psi_in
  exact ⟨mcs_and_left h_mcs_pred h_conj, mcs_and_right h_mcs_pred h_conj⟩

/-!
## G-content Coherence

G(φ) ∈ chain(n) implies φ ∈ g_content(chain(m)) for all m ≥ n,
and in particular φ ∈ chain(n+1).

The key derivation: G(φ) → X(φ). Under discrete strict semantics,
G(φ) at t means φ at all s > t, so φ at t+1, which is X(φ) at t.

For the formal derivation, we need: G(φ) → X(φ) = ⊥ U φ.
This is proven using seriality_future + F_until_equiv + until properties.
-/

/-- G-content propagates forward through x_content:
    if G(φ) ∈ M then φ ∈ x_content(M) (i.e., X(φ) ∈ M).
    This encodes G(a) → X(a) within an MCS. -/
theorem g_content_propagates_to_x_content (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) (φ : Formula)
    (h_G : Formula.all_future φ ∈ M) :
    φ ∈ x_content M := by
  -- G_implies_X gives ⊢ G(φ) → X(φ). Apply in MCS.
  simp only [mem_x_content_iff]
  have h_GX := Bimodal.Theorems.TemporalDerived.G_implies_X φ
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_GX) h_G

/-- H-content propagates backward through y_content:
    if H(φ) ∈ M then φ ∈ y_content(M) (i.e., Y(φ) ∈ M).
    Symmetric dual of g_content_propagates_to_x_content. -/
theorem h_content_propagates_to_y_content (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) (φ : Formula)
    (h_H : Formula.all_past φ ∈ M) :
    φ ∈ y_content M := by
  -- H_implies_Y gives ⊢ H(φ) → Y(φ). Apply in MCS.
  simp only [mem_y_content_iff]
  have h_HY := Bimodal.Theorems.TemporalDerived.H_implies_Y φ
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_HY) h_H

/-!
## Box-Class Agreement

All chain elements belong to the same box class as M_0.
Since x_content and y_content only strip temporal operators (X/Y),
modal formulas (□φ) are preserved: □φ ∈ M iff □φ ∈ x_content(M).
-/

/-- Box formulas propagate forward: □φ ∈ M → □φ ∈ x_content(M).
    Uses temp_future (□φ → G(□φ)) and G_implies_X (G(□φ) → X(□φ)). -/
theorem box_in_x_content (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_box : Formula.box φ ∈ M) :
    Formula.box φ ∈ x_content M := by
  -- temp_future: □φ → G(□φ)
  have h_tf : DerivationTree [] (Formula.box φ |>.imp (Formula.box φ).all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_future φ)
  have h_G_box : (Formula.box φ).all_future ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_tf) h_box
  -- G(□φ) → X(□φ) via G_implies_X
  exact g_content_propagates_to_x_content M h_mcs (Formula.box φ) h_G_box

/-- Box formulas propagate backward: □φ ∈ M → □φ ∈ y_content(M).
    Derives □φ → H(□φ) via temporal_duality of temp_future. -/
theorem box_in_y_content (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_box : Formula.box φ ∈ M) :
    Formula.box φ ∈ y_content M := by
  -- Step 1: temp_future (φ.swap_temporal) gives:
  --   ⊢ □(swap φ) → G(□(swap φ))
  -- Step 2: temporal_duality gives:
  --   ⊢ swap(□(swap φ) → G(□(swap φ)))
  --   = ⊢ □(swap(swap φ)) → H(□(swap(swap φ)))
  --   = ⊢ □φ → H(□φ)  (by swap_temporal_involution)
  have h_tf_swap := DerivationTree.axiom [] _
    (Axiom.temp_future φ.swap_temporal)
  -- h_tf_swap : ⊢ □(swap φ) → G(□(swap φ))
  have h_dual := DerivationTree.temporal_duality _ h_tf_swap
  -- h_dual : ⊢ swap(□(swap φ) → G(□(swap φ)))
  -- = ⊢ □(swap(swap φ)).imp (H(□(swap(swap φ))))
  -- Rewrite using swap_temporal_involution
  have h_rewrite : (Formula.box φ.swap_temporal |>.imp
      (Formula.box φ.swap_temporal).all_future).swap_temporal =
      (Formula.box φ).imp (Formula.box φ).all_past := by
    simp [Formula.swap_temporal, Formula.swap_temporal_involution]
  rw [h_rewrite] at h_dual
  -- Now h_dual : ⊢ □φ → H(□φ)
  have h_H_box : (Formula.box φ).all_past ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_dual) h_box
  exact h_content_propagates_to_y_content M h_mcs (Formula.box φ) h_H_box

/-!
## G-persistence Through the Chain (Multi-Step)

G(φ) ∈ chain(n) implies G(φ) ∈ chain(n+1) via temp_4 + G→X.
By induction, G(φ) persists to all chain positions ≥ n.
Then φ ∈ chain(m) for all m > n (via G→X giving φ at next step).
-/

/-- G(φ) persists forward one step in the chain.
    Uses temp_4 (G(φ) → G(G(φ))) and G→X (G(G(φ)) → X(G(φ))). -/
theorem G_persists_forward_one_step (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n : ℕ) (φ : Formula)
    (h_G : Formula.all_future φ ∈ deterministic_chain M₀ ↑n) :
    Formula.all_future φ ∈ deterministic_chain M₀ (↑n + 1) := by
  have h_mcs_n := deterministic_chain_mcs M₀ h_mcs ↑n
  -- temp_4: G(φ) → G(G(φ))
  have h_t4 : DerivationTree [] (φ.all_future.imp φ.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ)
  have h_GG : φ.all_future.all_future ∈ deterministic_chain M₀ ↑n :=
    SetMaximalConsistent.implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_t4) h_G
  -- G(G(φ)) → X(G(φ)) via g_content_propagates_to_x_content
  have h_Gx := g_content_propagates_to_x_content _ h_mcs_n φ.all_future h_GG
  -- x_content(chain(n)) = chain(n+1)
  show φ.all_future ∈ deterministic_chain M₀ (↑(n + 1))
  rw [deterministic_chain_nat_succ]
  exact h_Gx

/-- G(φ) persists forward through the Nat-indexed chain.
    If G(φ) ∈ chain(n) then G(φ) ∈ chain(n + k) for all k. -/
theorem G_persists_forward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n k : ℕ) (φ : Formula)
    (h_G : Formula.all_future φ ∈ deterministic_chain M₀ ↑n) :
    Formula.all_future φ ∈ deterministic_chain M₀ ↑(n + k) := by
  induction k with
  | zero => exact h_G
  | succ k ih =>
    have : ↑(n + k) + 1 = (↑(n + (k + 1)) : ℤ) := by omega
    rw [← this]
    exact G_persists_forward_one_step M₀ h_mcs (n + k) φ ih

/-- Forward G coherence for Nat chain: G(φ) ∈ chain(n), n < m → φ ∈ chain(m).
    Uses G persistence + G→X (φ ∈ x_content(chain(m-1)) = chain(m)). -/
theorem forward_G_nat (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_lt : n < m) (φ : Formula)
    (h_G : Formula.all_future φ ∈ deterministic_chain M₀ ↑n) :
    φ ∈ deterministic_chain M₀ ↑m := by
  -- m = n + (m - n), and m - n ≥ 1
  obtain ⟨k, rfl⟩ : ∃ k, m = n + k + 1 := ⟨m - n - 1, by omega⟩
  -- G(φ) persists to chain(n + k)
  have h_G_at := G_persists_forward M₀ h_mcs n k φ h_G
  -- φ ∈ x_content(chain(n + k)) = chain(n + k + 1)
  have h_mcs_nk := deterministic_chain_mcs M₀ h_mcs ↑(n + k)
  have h_phi_x := g_content_propagates_to_x_content _ h_mcs_nk φ h_G_at
  show φ ∈ deterministic_chain M₀ ↑(n + k + 1)
  rw [deterministic_chain_nat_succ]
  exact h_phi_x

/-!
## H-persistence Through the Chain (Multi-Step)

Symmetric to G-persistence, using y_content and the backward direction.
H(φ) ∈ chain(-n) implies φ ∈ chain(-m) for all m > n.
-/

/-- H(φ) persists backward one step in the chain.
    Uses temp_4_past (H(φ) → H(H(φ))) and H→Y. -/
theorem H_persists_backward_one_step (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n : ℕ) (φ : Formula)
    (h_H : Formula.all_past φ ∈ deterministic_chain M₀ (Int.negSucc n)) :
    Formula.all_past φ ∈ deterministic_chain M₀ (Int.negSucc (n + 1)) := by
  have h_mcs_n := deterministic_chain_mcs M₀ h_mcs (Int.negSucc n)
  -- temp_4_past: H(φ) → H(H(φ)) (from temporal duality of temp_4)
  have h_t4p := Bimodal.Metalogic.Core.temp_4_past φ
  have h_HH : φ.all_past.all_past ∈ deterministic_chain M₀ (Int.negSucc n) :=
    SetMaximalConsistent.implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_t4p) h_H
  -- H(H(φ)) → Y(H(φ)) via h_content_propagates_to_y_content
  have h_Hy := h_content_propagates_to_y_content _ h_mcs_n φ.all_past h_HH
  -- y_content(chain(-(n+1))) = chain(-(n+2))
  show φ.all_past ∈ deterministic_chain M₀ (Int.negSucc (n + 1))
  rw [deterministic_chain_negSucc_succ]
  exact h_Hy

/-- H(φ) persists backward through the negative chain.
    If H(φ) ∈ chain(-(n+1)) then H(φ) ∈ chain(-(n+1+k)) for all k. -/
theorem H_persists_backward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n k : ℕ) (φ : Formula)
    (h_H : Formula.all_past φ ∈ deterministic_chain M₀ (Int.negSucc n)) :
    Formula.all_past φ ∈ deterministic_chain M₀ (Int.negSucc (n + k)) := by
  induction k with
  | zero => simp; exact h_H
  | succ k ih =>
    have : n + (k + 1) = (n + k) + 1 := by omega
    rw [this]
    exact H_persists_backward_one_step M₀ h_mcs (n + k) φ ih

/-- Backward H coherence for Nat chain: H(φ) ∈ chain(-(n+1)), n < m → φ ∈ chain(-(m+1)).
    Uses H persistence + H→Y. -/
theorem backward_H_negSucc (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_lt : n < m) (φ : Formula)
    (h_H : Formula.all_past φ ∈ deterministic_chain M₀ (Int.negSucc n)) :
    φ ∈ deterministic_chain M₀ (Int.negSucc m) := by
  obtain ⟨k, rfl⟩ : ∃ k, m = n + k + 1 := ⟨m - n - 1, by omega⟩
  have h_H_at := H_persists_backward M₀ h_mcs n k φ h_H
  have h_mcs_nk := deterministic_chain_mcs M₀ h_mcs (Int.negSucc (n + k))
  have h_phi_y := h_content_propagates_to_y_content _ h_mcs_nk φ h_H_at
  show φ ∈ deterministic_chain M₀ (Int.negSucc (n + k + 1))
  rw [deterministic_chain_negSucc_succ]
  exact h_phi_y

end Bimodal.Metalogic.Algebraic.DeterministicChain
