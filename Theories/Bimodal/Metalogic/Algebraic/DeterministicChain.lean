import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Syntax.Formula
import Bimodal.ProofSystem.Axioms
import Bimodal.ProofSystem.Derivation
import Bimodal.Theorems.TemporalDerived

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

/-!
## Boundary-Crossing Coherence

The deterministic chain has separate forward (Nat) and backward (negSucc) halves.
For the full Int-indexed FMCS, we need G-coherence and H-coherence across the boundary
(from negative to positive indices and vice versa).

The key derived theorems are:
- `YG_implies_self`: Y(G(φ)) → φ  (from yx_identity axiom)
- `XH_implies_self`: X(H(φ)) → φ  (from xy_identity axiom)

These allow us to "cross the boundary" at index 0.
-/

/-- G(φ) persists backward toward chain(-1) from any negSucc position. -/
private theorem G_persists_backward_toward_zero (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (k : ℕ) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc k)) :
    φ.all_future ∈ deterministic_chain M₀ (Int.negSucc 0) := by
  induction k with
  | zero => exact h_G
  | succ k ih =>
    have h_mcs_succ := deterministic_chain_mcs M₀ h_mcs (Int.negSucc (k + 1))
    have h_t4 : DerivationTree [] (φ.all_future.imp φ.all_future.all_future) :=
      DerivationTree.axiom [] _ (Axiom.temp_4 φ)
    have h_GG : φ.all_future.all_future ∈ deterministic_chain M₀ (Int.negSucc (k + 1)) :=
      SetMaximalConsistent.implication_property h_mcs_succ
        (theorem_in_mcs h_mcs_succ h_t4) h_G
    have h_Y_GG_in : (Formula.snce Formula.bot φ.all_future.all_future) ∈
        deterministic_chain M₀ (Int.negSucc k) := by
      simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_GG ⊢
      exact h_GG
    have h_YGG_to_G := Bimodal.Theorems.TemporalDerived.YG_implies_self φ.all_future
    have h_mcs_k := deterministic_chain_mcs M₀ h_mcs (Int.negSucc k)
    have h_G_at_k : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc k) :=
      SetMaximalConsistent.implication_property h_mcs_k
        (theorem_in_mcs h_mcs_k h_YGG_to_G) h_Y_GG_in
    exact ih h_G_at_k

/-- G(φ) persists forward through the backward chain from negSucc n to negSucc m (m ≤ n). -/
private theorem G_persists_forward_in_backward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_le : m ≤ n) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc n)) :
    φ.all_future ∈ deterministic_chain M₀ (Int.negSucc m) := by
  obtain ⟨d, rfl⟩ : ∃ d, n = m + d := ⟨n - m, by omega⟩
  clear h_le
  induction d with
  | zero => exact h_G
  | succ d ih =>
    have h_eq : m + (d + 1) = (m + d) + 1 := by omega
    rw [h_eq] at h_G
    have h_mcs_succ := deterministic_chain_mcs M₀ h_mcs (Int.negSucc ((m + d) + 1))
    have h_t4 : DerivationTree [] (φ.all_future.imp φ.all_future.all_future) :=
      DerivationTree.axiom [] _ (Axiom.temp_4 φ)
    have h_GG : φ.all_future.all_future ∈ deterministic_chain M₀ (Int.negSucc ((m + d) + 1)) :=
      SetMaximalConsistent.implication_property h_mcs_succ
        (theorem_in_mcs h_mcs_succ h_t4) h_G
    have h_Y_GG_in : (Formula.snce Formula.bot φ.all_future.all_future) ∈
        deterministic_chain M₀ (Int.negSucc (m + d)) := by
      simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_GG ⊢
      exact h_GG
    have h_mcs_md := deterministic_chain_mcs M₀ h_mcs (Int.negSucc (m + d))
    have h_G_at_md : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc (m + d)) :=
      SetMaximalConsistent.implication_property h_mcs_md
        (theorem_in_mcs h_mcs_md (Bimodal.Theorems.TemporalDerived.YG_implies_self φ.all_future))
        h_Y_GG_in
    exact ih h_G_at_md

/-- Forward G within the backward chain: G(φ) ∈ chain(negSucc n) → φ ∈ chain(negSucc m) (m < n). -/
theorem forward_G_within_backward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_lt : m < n) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc n)) :
    φ ∈ deterministic_chain M₀ (Int.negSucc m) := by
  have h_persist := G_persists_forward_in_backward M₀ h_mcs n (m + 1) (by omega) φ h_G
  have h_YG : (Formula.snce Formula.bot φ.all_future) ∈
      deterministic_chain M₀ (Int.negSucc m) := by
    simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_persist ⊢
    exact h_persist
  have h_mcs_m := deterministic_chain_mcs M₀ h_mcs (Int.negSucc m)
  exact SetMaximalConsistent.implication_property h_mcs_m
    (theorem_in_mcs h_mcs_m (Bimodal.Theorems.TemporalDerived.YG_implies_self φ)) h_YG

/-- Forward G coherence across the boundary: G(φ) ∈ chain(-(k+1)) implies φ ∈ chain(m)
for any m ≥ 0 (non-negative). -/
theorem forward_G_boundary (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (k m : ℕ) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc k)) :
    φ ∈ deterministic_chain M₀ ↑m := by
  have h_G_at_neg1 := G_persists_backward_toward_zero M₀ h_mcs k φ h_G
  have h_YG_in_M0 : (Formula.snce Formula.bot φ.all_future) ∈ M₀ := by
    simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_G_at_neg1
    exact h_G_at_neg1
  have h_YG_to_phi := Bimodal.Theorems.TemporalDerived.YG_implies_self φ
  have h_phi_in_M0 : φ ∈ M₀ :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_YG_to_phi) h_YG_in_M0
  have h_t4 : DerivationTree [] (φ.all_future.imp φ.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ)
  have h_mcs_neg1 := deterministic_chain_mcs M₀ h_mcs (Int.negSucc 0)
  have h_GG_neg1 : φ.all_future.all_future ∈ deterministic_chain M₀ (Int.negSucc 0) :=
    SetMaximalConsistent.implication_property h_mcs_neg1
      (theorem_in_mcs h_mcs_neg1 h_t4) h_G_at_neg1
  have h_YGG_in_M0 : (Formula.snce Formula.bot φ.all_future.all_future) ∈ M₀ := by
    simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_GG_neg1
    exact h_GG_neg1
  have h_YGG_to_G := Bimodal.Theorems.TemporalDerived.YG_implies_self φ.all_future
  have h_G_in_M0 : φ.all_future ∈ M₀ :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_YGG_to_G) h_YGG_in_M0
  match m with
  | 0 => exact h_phi_in_M0
  | m' + 1 =>
    show φ ∈ deterministic_chain M₀ ↑(m' + 1)
    exact forward_G_nat M₀ h_mcs 0 (m' + 1) (by omega) φ h_G_in_M0

/-- Full forward G coherence for the deterministic chain over Int.
G(φ) ∈ chain(n) and n < m implies φ ∈ chain(m).
Uses forward_G_nat for Nat sub-chain, boundary crossing via YG_implies_self,
and backward sub-chain persistence. -/
theorem forward_G_int (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℤ) (h_le : n ≤ m) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ n) :
    φ ∈ deterministic_chain M₀ m := by
  rcases eq_or_lt_of_le h_le with h_eq | h_lt
  · -- Reflexive case: n = m, use T-axiom G(φ) → φ
    subst h_eq
    exact SetMaximalConsistent.implication_property (deterministic_chain_mcs M₀ h_mcs n)
      (theorem_in_mcs (deterministic_chain_mcs M₀ h_mcs n)
        ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future φ)⟩) h_G
  · -- Strict case: n < m
    cases n with
    | ofNat n' =>
      cases m with
      | ofNat m' =>
        exact forward_G_nat M₀ h_mcs n' m' (Int.ofNat_lt.mp h_lt) φ h_G
      | negSucc _ =>
        exact absurd h_lt (not_lt_of_ge (le_trans (Int.negSucc_lt_zero _).le (Int.natCast_nonneg n')))
    | negSucc n' =>
      cases m with
      | ofNat m' =>
        exact forward_G_boundary M₀ h_mcs n' m' φ h_G
      | negSucc m' =>
        exact forward_G_within_backward M₀ h_mcs n' m' (by omega) φ h_G

/-- H(φ) persists one step backward in the forward chain. -/
private theorem H_persists_backward_in_forward_one_step
    (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n : ℕ) (φ : Formula)
    (h_H : φ.all_past ∈ deterministic_chain M₀ ↑(n + 2)) :
    φ.all_past ∈ deterministic_chain M₀ ↑(n + 1) := by
  have h_mcs_succ := deterministic_chain_mcs M₀ h_mcs ↑(n + 2)
  have h_t4p := Bimodal.Metalogic.Core.temp_4_past φ
  have h_HH : φ.all_past.all_past ∈ deterministic_chain M₀ ↑(n + 2) :=
    SetMaximalConsistent.implication_property h_mcs_succ
      (theorem_in_mcs h_mcs_succ h_t4p) h_H
  have h_X_HH_in : (Formula.untl Formula.bot φ.all_past.all_past) ∈
      deterministic_chain M₀ ↑(n + 1) := by
    rw [show (↑(n + 2) : ℤ) = ↑(n + 1) + 1 from by omega] at h_HH
    rw [show ↑(n + 1) + 1 = (↑((n + 1) + 1) : ℤ) from by omega] at h_HH
    rw [mem_chain_succ_iff_x_mem_chain] at h_HH
    exact h_HH
  have h_mcs_n := deterministic_chain_mcs M₀ h_mcs ↑(n + 1)
  exact SetMaximalConsistent.implication_property h_mcs_n
    (theorem_in_mcs h_mcs_n (Bimodal.Theorems.TemporalDerived.XH_implies_self φ.all_past))
    h_X_HH_in

/-- H(φ) persists backward through the forward chain from position n to position m (m ≤ n). -/
private theorem H_persists_backward_in_forward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_le : m ≤ n) (φ : Formula)
    (h_H : φ.all_past ∈ deterministic_chain M₀ ↑(n + 1)) :
    φ.all_past ∈ deterministic_chain M₀ ↑(m + 1) := by
  obtain ⟨d, rfl⟩ : ∃ d, n = m + d := ⟨n - m, by omega⟩
  clear h_le
  induction d with
  | zero => exact h_H
  | succ d ih =>
    rw [show (↑(m + (d + 1) + 1) : ℤ) = ↑((m + d + 1) + 1) from by push_cast; omega] at h_H
    have h_step := H_persists_backward_in_forward_one_step M₀ h_mcs (m + d) φ
      (by rw [show m + d + 2 = (m + d + 1) + 1 from by omega]; exact h_H)
    exact ih h_step

/-- Backward H within the forward chain: H(φ) ∈ chain(n+1) → φ ∈ chain(m+1) (m < n). -/
theorem backward_H_within_forward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_lt : m < n) (φ : Formula)
    (h_H : φ.all_past ∈ deterministic_chain M₀ ↑(n + 1)) :
    φ ∈ deterministic_chain M₀ ↑(m + 1) := by
  have h_persist := H_persists_backward_in_forward M₀ h_mcs n (m + 1) (by omega) φ h_H
  have h_XH : (Formula.untl Formula.bot φ.all_past) ∈ deterministic_chain M₀ ↑(m + 1) := by
    rw [show (↑(m + 1 + 1) : ℤ) = ↑((m + 1) + 1) from by push_cast; omega] at h_persist
    rw [show (↑((m + 1) + 1) : ℤ) = ↑(m + 1) + 1 from by push_cast; omega] at h_persist
    rw [show ↑(m + 1) + 1 = (↑((m + 1) + 1) : ℤ) from by push_cast; omega] at h_persist
    rw [mem_chain_succ_iff_x_mem_chain] at h_persist
    exact h_persist
  have h_mcs_m := deterministic_chain_mcs M₀ h_mcs ↑(m + 1)
  exact SetMaximalConsistent.implication_property h_mcs_m
    (theorem_in_mcs h_mcs_m (Bimodal.Theorems.TemporalDerived.XH_implies_self φ)) h_XH

/-- Full backward H coherence for the deterministic chain over Int.
H(φ) ∈ chain(n) and m < n implies φ ∈ chain(m). -/
theorem backward_H_int (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℤ) (h_le : m ≤ n) (φ : Formula)
    (h_H : φ.all_past ∈ deterministic_chain M₀ n) :
    φ ∈ deterministic_chain M₀ m := by
  rcases eq_or_lt_of_le h_le with h_eq | h_lt
  · -- Reflexive case: m = n, use T-axiom H(φ) → φ
    subst h_eq
    exact SetMaximalConsistent.implication_property (deterministic_chain_mcs M₀ h_mcs n)
      (theorem_in_mcs (deterministic_chain_mcs M₀ h_mcs n)
        ⟨DerivationTree.axiom [] _ (Axiom.temp_t_past φ)⟩) h_H
  · -- Strict case: m < n
    -- Helper: get H(φ) into M₀ from any positive chain position
    -- Then propagate to y_content for negative positions
    cases n with
    | ofNat n' =>
      -- Get H(φ) ∈ M₀ from H(φ) ∈ chain(n') via backward persistence
      have h_H_M0 : φ.all_past ∈ M₀ := by
        match n' with
        | 0 => exact h_H
        | n'' + 1 =>
          have h_H_1 := H_persists_backward_in_forward M₀ h_mcs n'' 0
            (Nat.zero_le n'') φ h_H
          -- H(φ) ∈ chain(↑(0+1)) = x_content(M₀), so X(H(φ)) ∈ M₀
          have h_XH_M0 : (Formula.untl Formula.bot φ.all_past) ∈ M₀ := by
            simp only [deterministic_chain, iterate_x_content, mem_x_content_iff] at h_H_1
            exact h_H_1
          have h_XH_self := Bimodal.Theorems.TemporalDerived.XH_implies_self φ.all_past
          -- X(H(H(φ))) → H(φ)
          have h_t4p := Bimodal.Metalogic.Core.temp_4_past φ
          have h_mcs_1 := deterministic_chain_mcs M₀ h_mcs (↑(0 + 1) : ℤ)
          have h_HH_1 := SetMaximalConsistent.implication_property h_mcs_1
            (theorem_in_mcs h_mcs_1 h_t4p) h_H_1
          have h_XHH_M0 : (Formula.untl Formula.bot φ.all_past.all_past) ∈ M₀ := by
            simp only [deterministic_chain] at h_HH_1
            exact h_HH_1
          exact SetMaximalConsistent.implication_property h_mcs
            (theorem_in_mcs h_mcs h_XH_self) h_XHH_M0
      cases m with
      | ofNat m' =>
        match n', h_H with
        | 0, _ => exact absurd (Int.ofNat_lt.mp h_lt) (Nat.not_lt_zero m')
        | n'' + 1, h_H =>
          match m' with
          | 0 =>
            -- φ ∈ M₀ from XH_implies_self
            have h_XH_M0 : (Formula.untl Formula.bot φ.all_past) ∈ M₀ := by
              have h_H_1 := H_persists_backward_in_forward M₀ h_mcs n'' 0
                (Int.ofNat_lt.mp h_lt |> fun h => by omega) φ h_H
              simp only [deterministic_chain, iterate_x_content, mem_x_content_iff] at h_H_1
              exact h_H_1
            show φ ∈ M₀
            exact SetMaximalConsistent.implication_property h_mcs
              (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.XH_implies_self φ))
              h_XH_M0
          | m'' + 1 =>
            exact backward_H_within_forward M₀ h_mcs n'' m''
              (Int.ofNat_lt.mp h_lt |> fun h => by omega) φ h_H
      | negSucc m' =>
        -- Need φ ∈ chain(negSucc m'). We have H(φ) ∈ M₀.
        -- Get H(H(φ)) ∈ M₀, then H(φ) ∈ y_content(M₀) = chain(-1).
        have h_t4p := Bimodal.Metalogic.Core.temp_4_past φ
        have h_HH_M0 := SetMaximalConsistent.implication_property h_mcs
          (theorem_in_mcs h_mcs h_t4p) h_H_M0
        have h_H_neg1 : φ.all_past ∈ deterministic_chain M₀ (Int.negSucc 0) := by
          simp only [deterministic_chain, iterate_y_content]
          exact h_content_propagates_to_y_content _ h_mcs φ.all_past h_HH_M0
        match m' with
        | 0 =>
          -- φ ∈ chain(-1) = y_content(M₀). Use H(φ) ∈ M₀ directly.
          simp only [deterministic_chain, iterate_y_content]
          exact h_content_propagates_to_y_content _ h_mcs φ h_H_M0
        | m'' + 1 =>
          exact backward_H_negSucc M₀ h_mcs 0 (m'' + 1) (by omega) φ h_H_neg1
    | negSucc n' =>
      cases m with
      | ofNat _ => exact absurd h_lt (not_lt_of_ge (le_trans (Int.negSucc_lt_zero n').le (Int.natCast_nonneg _)))
      | negSucc m' =>
        exact backward_H_negSucc M₀ h_mcs n' m' (by omega) φ h_H

end Bimodal.Metalogic.Algebraic.DeterministicChain

/-
OLD CODE BELOW - replaced by sorry-based stubs above.
The original code had Int arithmetic issues (omega failures with Int.ofNat/negSucc).
The boundary-crossing proofs are mathematically correct but need careful cast handling.
-/

#exit -- Stop compilation here; old code kept for reference only

private theorem G_persists_backward_toward_zero_OLD (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (k : ℕ) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc k)) :
    φ.all_future ∈ deterministic_chain M₀ (Int.negSucc 0) := by
  induction k with
  | zero => exact h_G
  | succ k ih =>
    -- G(φ) ∈ chain(-(k+2)) = y_content(chain(-(k+1)))
    -- So Y(G(φ)) ∈ chain(-(k+1))
    -- temp_4: G(φ) → G(G(φ)), so G(G(φ)) ∈ chain(-(k+2))
    -- Y(G(G(φ))) ∈ chain(-(k+1))
    -- YG_implies_self: Y(G(G(φ))) → G(φ), so G(φ) ∈ chain(-(k+1))
    have h_mcs_succ := deterministic_chain_mcs M₀ h_mcs (Int.negSucc (k + 1))
    -- G(φ) → G(G(φ)) by temp_4
    have h_t4 : DerivationTree [] (φ.all_future.imp φ.all_future.all_future) :=
      DerivationTree.axiom [] _ (Axiom.temp_4 φ)
    have h_GG : φ.all_future.all_future ∈ deterministic_chain M₀ (Int.negSucc (k + 1)) :=
      SetMaximalConsistent.implication_property h_mcs_succ
        (theorem_in_mcs h_mcs_succ h_t4) h_G
    -- G(G(φ)) ∈ chain(-(k+2)) = y_content(chain(-(k+1)))
    -- means Y(G(G(φ))) ∈ chain(-(k+1))
    -- chain(-(k+2)) = deterministic_chain M₀ (Int.negSucc (k+1))
    -- chain(-(k+1)) = deterministic_chain M₀ (Int.negSucc k)
    -- Y(G(G(φ))) ∈ deterministic_chain M₀ (Int.negSucc k)
    have h_Y_GG_in : (Formula.snce Formula.bot φ.all_future.all_future) ∈
        deterministic_chain M₀ (Int.negSucc k) := by
      -- G(G(φ)) ∈ y_content(chain(-(k+1))) means Y(G(G(φ))) ∈ chain(-(k+1))
      show (Formula.snce Formula.bot φ.all_future.all_future) ∈
        deterministic_chain M₀ (Int.negSucc k)
      simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_GG ⊢
      exact h_GG
    -- YG_implies_self for G(φ): ⊢ Y(G(G(φ))) → G(φ)
    have h_YGG_to_G := Bimodal.Theorems.TemporalDerived.YG_implies_self φ.all_future
    have h_mcs_k := deterministic_chain_mcs M₀ h_mcs (Int.negSucc k)
    have h_G_at_k : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc k) :=
      SetMaximalConsistent.implication_property h_mcs_k
        (theorem_in_mcs h_mcs_k h_YGG_to_G) h_Y_GG_in
    exact ih h_G_at_k

/-- G(φ) persists forward through the backward chain from negSucc n to negSucc m (m ≤ n). -/
private theorem G_persists_forward_in_backward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_le : m ≤ n) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc n)) :
    φ.all_future ∈ deterministic_chain M₀ (Int.negSucc m) := by
  obtain ⟨d, rfl⟩ : ∃ d, n = m + d := ⟨n - m, by omega⟩
  clear h_le
  induction d with
  | zero => exact h_G
  | succ d ih =>
    -- h_G : G(φ) ∈ chain(negSucc (m + d + 1)) = chain(negSucc ((m + d) + 1))
    have h_eq : m + (d + 1) = (m + d) + 1 := by omega
    rw [h_eq] at h_G
    -- Apply one-step persistence to get G(φ) ∈ chain(negSucc (m + d))
    have h_mcs_succ := deterministic_chain_mcs M₀ h_mcs (Int.negSucc ((m + d) + 1))
    have h_t4 : DerivationTree [] (φ.all_future.imp φ.all_future.all_future) :=
      DerivationTree.axiom [] _ (Axiom.temp_4 φ)
    have h_GG : φ.all_future.all_future ∈ deterministic_chain M₀ (Int.negSucc ((m + d) + 1)) :=
      SetMaximalConsistent.implication_property h_mcs_succ
        (theorem_in_mcs h_mcs_succ h_t4) h_G
    have h_Y_GG_in : (Formula.snce Formula.bot φ.all_future.all_future) ∈
        deterministic_chain M₀ (Int.negSucc (m + d)) := by
      simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_GG ⊢
      exact h_GG
    have h_mcs_md := deterministic_chain_mcs M₀ h_mcs (Int.negSucc (m + d))
    have h_G_at_md : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc (m + d)) :=
      SetMaximalConsistent.implication_property h_mcs_md
        (theorem_in_mcs h_mcs_md (Bimodal.Theorems.TemporalDerived.YG_implies_self φ.all_future))
        h_Y_GG_in
    exact ih h_G_at_md

/-- Forward G within the backward chain: G(φ) ∈ chain(negSucc n) → φ ∈ chain(negSucc m) (m < n).
Persists G(φ) to negSucc (m+1), then applies YG_implies_self. -/
theorem forward_G_within_backward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_lt : m < n) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc n)) :
    φ ∈ deterministic_chain M₀ (Int.negSucc m) := by
  have h_persist := G_persists_forward_in_backward M₀ h_mcs n (m + 1) (by omega) φ h_G
  -- G(φ) ∈ chain(negSucc (m+1)) = y_content(chain(negSucc m))
  -- So Y(G(φ)) ∈ chain(negSucc m)
  have h_YG : (Formula.snce Formula.bot φ.all_future) ∈
      deterministic_chain M₀ (Int.negSucc m) := by
    simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_persist ⊢
    exact h_persist
  have h_mcs_m := deterministic_chain_mcs M₀ h_mcs (Int.negSucc m)
  exact SetMaximalConsistent.implication_property h_mcs_m
    (theorem_in_mcs h_mcs_m (Bimodal.Theorems.TemporalDerived.YG_implies_self φ)) h_YG

/-- Forward G coherence across the boundary: G(φ) ∈ chain(-(k+1)) implies φ ∈ chain(m)
for any m ≥ 0 (non-negative). -/
theorem forward_G_boundary (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (k m : ℕ) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ (Int.negSucc k)) :
    φ ∈ deterministic_chain M₀ ↑m := by
  -- Step 1: G(φ) persists to chain(-1) = y_content(M₀)
  have h_G_at_neg1 := G_persists_backward_toward_zero M₀ h_mcs k φ h_G
  -- Step 2: G(φ) ∈ y_content(M₀) means Y(G(φ)) ∈ M₀
  have h_YG_in_M0 : (Formula.snce Formula.bot φ.all_future) ∈ M₀ := by
    simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_G_at_neg1
    exact h_G_at_neg1
  -- Step 3: YG_implies_self: Y(G(φ)) → φ, so φ ∈ M₀
  have h_YG_to_phi := Bimodal.Theorems.TemporalDerived.YG_implies_self φ
  have h_phi_in_M0 : φ ∈ M₀ :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_YG_to_phi) h_YG_in_M0
  -- Step 4: Also G(φ) ∈ M₀ from Y(G(φ)) ∈ M₀ ... no, we need G(φ) ∈ M₀ for forward propagation
  -- Actually: G(φ) ∈ chain(-1), Y(G(φ)) ∈ M₀. We need G(φ) ∈ M₀.
  -- Y(G(G(φ))) → G(φ) by YG_implies_self for G(φ).
  -- G(φ) → G(G(φ)) by temp_4. So G(G(φ)) ∈ chain(-1).
  -- Y(G(G(φ))) ∈ M₀. Then G(φ) ∈ M₀.
  have h_t4 : DerivationTree [] (φ.all_future.imp φ.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ)
  have h_mcs_neg1 := deterministic_chain_mcs M₀ h_mcs (Int.negSucc 0)
  have h_GG_neg1 : φ.all_future.all_future ∈ deterministic_chain M₀ (Int.negSucc 0) :=
    SetMaximalConsistent.implication_property h_mcs_neg1
      (theorem_in_mcs h_mcs_neg1 h_t4) h_G_at_neg1
  have h_YGG_in_M0 : (Formula.snce Formula.bot φ.all_future.all_future) ∈ M₀ := by
    simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_GG_neg1
    exact h_GG_neg1
  have h_YGG_to_G := Bimodal.Theorems.TemporalDerived.YG_implies_self φ.all_future
  have h_G_in_M0 : φ.all_future ∈ M₀ :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_YGG_to_G) h_YGG_in_M0
  -- Step 5: G(φ) ∈ M₀ = chain(0). Use forward_G_nat for m > 0.
  match m with
  | 0 => exact h_phi_in_M0
  | m' + 1 =>
    show φ ∈ deterministic_chain M₀ ↑(m' + 1)
    exact forward_G_nat M₀ h_mcs 0 (m' + 1) (by omega) φ h_G_in_M0

/-- Full forward G coherence for the deterministic chain over Int.
G(φ) ∈ chain(n) and n < m implies φ ∈ chain(m). -/
theorem forward_G_int (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℤ) (h_lt : n < m) (φ : Formula)
    (h_G : φ.all_future ∈ deterministic_chain M₀ n) :
    φ ∈ deterministic_chain M₀ m := by
  cases n with
  | ofNat n' =>
    cases m with
    | ofNat m' =>
      exact forward_G_nat M₀ h_mcs n' m' (Int.ofNat_lt.mp h_lt) φ h_G
    | negSucc m' =>
      -- n ≥ 0 and m < 0, but n < m is impossible
      exact absurd h_lt (by omega)
  | negSucc n' =>
    cases m with
    | ofNat m' =>
      exact forward_G_boundary M₀ h_mcs n' m' φ h_G
    | negSucc m' =>
      exact forward_G_within_backward M₀ h_mcs n' m' (by omega) φ h_G

/-- H(φ) persists one step backward in the forward chain:
H(φ) ∈ chain(n+2) implies H(φ) ∈ chain(n+1).
Uses temp_4_past and XH_implies_self. -/
private theorem H_persists_backward_in_forward_one_step
    (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n : ℕ) (φ : Formula)
    (h_H : φ.all_past ∈ deterministic_chain M₀ ↑(n + 2)) :
    φ.all_past ∈ deterministic_chain M₀ ↑(n + 1) := by
  have h_mcs_succ := deterministic_chain_mcs M₀ h_mcs ↑(n + 2)
  have h_t4p := Bimodal.Metalogic.Core.temp_4_past φ
  have h_HH : φ.all_past.all_past ∈ deterministic_chain M₀ ↑(n + 2) :=
    SetMaximalConsistent.implication_property h_mcs_succ
      (theorem_in_mcs h_mcs_succ h_t4p) h_H
  -- H(H(φ)) ∈ chain(n+2) = x_content(chain(n+1)), so X(H(H(φ))) ∈ chain(n+1)
  have h_X_HH_in : (Formula.untl Formula.bot φ.all_past.all_past) ∈
      deterministic_chain M₀ ↑(n + 1) := by
    rw [show (↑(n + 2) : ℤ) = ↑(n + 1) + 1 from by omega] at h_HH
    rw [show ↑(n + 1) + 1 = (↑((n + 1) + 1) : ℤ) from by omega] at h_HH
    rw [mem_chain_succ_iff_x_mem_chain] at h_HH
    exact h_HH
  have h_mcs_n := deterministic_chain_mcs M₀ h_mcs ↑(n + 1)
  exact SetMaximalConsistent.implication_property h_mcs_n
    (theorem_in_mcs h_mcs_n (Bimodal.Theorems.TemporalDerived.XH_implies_self φ.all_past))
    h_X_HH_in

/-- H(φ) persists backward through the forward chain from position n to position m (m ≤ n). -/
private theorem H_persists_backward_in_forward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_le : m ≤ n) (φ : Formula)
    (h_H : φ.all_past ∈ deterministic_chain M₀ ↑(n + 1)) :
    φ.all_past ∈ deterministic_chain M₀ ↑(m + 1) := by
  obtain ⟨d, rfl⟩ : ∃ d, n = m + d := ⟨n - m, by omega⟩
  clear h_le
  induction d with
  | zero => exact h_H
  | succ d ih =>
    have h_eq : m + (d + 1) + 1 = (m + d + 1) + 1 := by omega
    rw [show (↑(m + (d + 1) + 1) : ℤ) = ↑((m + d + 1) + 1) from by push_cast; omega] at h_H
    have h_step := H_persists_backward_in_forward_one_step M₀ h_mcs (m + d) φ
      (by rw [show m + d + 2 = (m + d + 1) + 1 from by omega]; exact h_H)
    exact ih h_step

/-- Backward H within the forward chain: H(φ) ∈ chain(n+1) → φ ∈ chain(m+1) (m < n). -/
theorem backward_H_within_forward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℕ) (h_lt : m < n) (φ : Formula)
    (h_H : φ.all_past ∈ deterministic_chain M₀ ↑(n + 1)) :
    φ ∈ deterministic_chain M₀ ↑(m + 1) := by
  have h_persist := H_persists_backward_in_forward M₀ h_mcs n (m + 1) (by omega) φ h_H
  -- H(φ) ∈ chain(m+2) = x_content(chain(m+1)), so X(H(φ)) ∈ chain(m+1)
  have h_XH : (Formula.untl Formula.bot φ.all_past) ∈ deterministic_chain M₀ ↑(m + 1) := by
    rw [show (↑(m + 1 + 1) : ℤ) = ↑((m + 1) + 1) from by push_cast; omega] at h_persist
    rw [show (↑((m + 1) + 1) : ℤ) = ↑(m + 1) + 1 from by push_cast; omega] at h_persist
    rw [show ↑(m + 1) + 1 = (↑((m + 1) + 1) : ℤ) from by push_cast; omega] at h_persist
    rw [mem_chain_succ_iff_x_mem_chain] at h_persist
    exact h_persist
  have h_mcs_m := deterministic_chain_mcs M₀ h_mcs ↑(m + 1)
  exact SetMaximalConsistent.implication_property h_mcs_m
    (theorem_in_mcs h_mcs_m (Bimodal.Theorems.TemporalDerived.XH_implies_self φ)) h_XH

/-- Full backward H coherence for the deterministic chain over Int.
H(φ) ∈ chain(n) and m < n implies φ ∈ chain(m). -/
theorem backward_H_int (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n m : ℤ) (h_lt : m < n) (φ : Formula)
    (h_H : φ.all_past ∈ deterministic_chain M₀ n) :
    φ ∈ deterministic_chain M₀ m := by
  cases n with
  | ofNat n' =>
    cases m with
    | ofNat m' =>
      match n' with
      | 0 => exact absurd h_lt (by omega)
      | n'' + 1 =>
        match m' with
        | 0 =>
          -- H(φ) ∈ chain(n''+1), need φ ∈ chain(0) = M₀
          have h_H_1 := H_persists_backward_in_forward M₀ h_mcs n'' 0 (by omega) φ h_H
          -- H(φ) ∈ chain(1) = x_content(M₀), so X(H(φ)) ∈ M₀
          have h_XH_M0 : (Formula.untl Formula.bot φ.all_past) ∈ M₀ := by
            rw [show (↑(0 + 1) : ℤ) = ↑(0 + 1) from rfl] at h_H_1
            rw [mem_chain_succ_iff_x_mem_chain] at h_H_1; exact h_H_1
          exact SetMaximalConsistent.implication_property h_mcs
            (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.XH_implies_self φ))
            h_XH_M0
        | m'' + 1 =>
          exact backward_H_within_forward M₀ h_mcs n'' m'' (by omega) φ h_H
    | negSucc m' =>
      match n' with
      | 0 => exact absurd h_lt (by omega)
      | n'' + 1 =>
        -- H(φ) ∈ chain(n''+1) (positive), need φ ∈ chain(negSucc m') (negative)
        -- First get H(φ) ∈ M₀ via backward persistence
        have h_H_1 := H_persists_backward_in_forward M₀ h_mcs n'' 0 (by omega) φ h_H
        have h_XH_M0 : (Formula.untl Formula.bot φ.all_past) ∈ M₀ := by
          rw [show (↑(0 + 1) : ℤ) = ↑(0 + 1) from rfl] at h_H_1
          rw [mem_chain_succ_iff_x_mem_chain] at h_H_1; exact h_H_1
        have h_phi_M0 : φ ∈ M₀ :=
          SetMaximalConsistent.implication_property h_mcs
            (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.XH_implies_self φ))
            h_XH_M0
        -- Get H(φ) ∈ M₀
        have h_t4p := Bimodal.Metalogic.Core.temp_4_past φ
        have h_mcs_1 := deterministic_chain_mcs M₀ h_mcs ↑(0 + 1)
        have h_HH := SetMaximalConsistent.implication_property h_mcs_1
          (theorem_in_mcs h_mcs_1 h_t4p) h_H_1
        have h_XHH_M0 : (Formula.untl Formula.bot φ.all_past.all_past) ∈ M₀ := by
          rw [show (↑(0 + 1) : ℤ) = ↑(0 + 1) from rfl] at h_HH
          rw [mem_chain_succ_iff_x_mem_chain] at h_HH; exact h_HH
        have h_H_M0 : φ.all_past ∈ M₀ :=
          SetMaximalConsistent.implication_property h_mcs
            (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.XH_implies_self φ.all_past))
            h_XHH_M0
        -- H(φ) ∈ M₀. Now use backward_H_negSucc to get φ ∈ chain(negSucc m').
        have h_H_neg1 : φ.all_past ∈ deterministic_chain M₀ (Int.negSucc 0) := by
          simp only [deterministic_chain, iterate_y_content]
          exact h_content_propagates_to_y_content _ h_mcs φ h_H_M0
        exact backward_H_negSucc M₀ h_mcs 0 m' (by omega) φ h_H_neg1
  | negSucc n' =>
    cases m with
    | ofNat _ => exact absurd h_lt (by omega)
    | negSucc m' =>
      -- Both negative: m' > n' (since negSucc m' < negSucc n')
      exact backward_H_negSucc M₀ h_mcs n' m' (by omega) φ h_H

end Bimodal.Metalogic.Algebraic.DeterministicChain
