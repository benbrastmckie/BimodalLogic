import Bimodal.Metalogic.Bundle.SuccChainTruth
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Semantics.Validity

/-!
# Succ-Chain Completeness Theorem

This module proves base completeness for TM bimodal logic via the Succ-chain approach.

## Main Result

- `succ_chain_completeness`: If φ is valid, then φ is provable

## Proof Strategy

The proof proceeds by contrapositive:
1. Assume φ is not provable
2. Then {¬φ} is consistent (by `not_derivable_implies_neg_consistent` from Construction.lean)
3. Extend {¬φ} to MCS M₀ via Lindenbaum's lemma
4. Convert M₀ to SerialMCS (F_top and P_top are provable theorems)
5. Build succ_chain_fam from M₀, giving a semantic model
6. By succ_chain_truth_forward: ¬φ ∈ M₀ implies ¬φ is true at time 0
7. Therefore φ is false at time 0, so φ is not valid

The contrapositive gives: valid φ → provable φ

## Axiom Dependency

This completeness theorem depends on `sorryAx` via:
- `succ_chain_truth_forward` depends on Box backward sorry in `succ_chain_truth_lemma`
  (the forward Imp case structurally requires the backward direction)
- Additional axioms from SuccChainFMCS, SuccExistence, CanonicalTaskRelation

**Note**: The Box backward case is unprovable in singleton-Omega without modal saturation.
For sorry-free completeness, use `semantic_weak_completeness` (FMP/SemanticCanonicalModel.lean)
or the algebraic path (Algebraic/ParametricRepresentation.lean).

## References

- SuccChainTruth.lean: Truth lemma for Succ-chain model
- SuccChainFMCS.lean: Succ-chain family construction
- Construction.lean: not_derivable_implies_neg_consistent
- MaximalConsistent.lean: Lindenbaum's lemma (set_lindenbaum)
-/

namespace Bimodal.Metalogic.Completeness

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Semantics
open Bimodal.ProofSystem

/-!
## Consistency of Unprovable Formulas
-/

/-- A formula is provable iff there is a derivation tree from empty context. -/
def formula_provable (φ : Formula) : Prop := Nonempty (DerivationTree [] φ)

/-- If φ is not provable, then {neg(φ)} is set-consistent.

This uses `not_derivable_implies_neg_consistent` from Construction.lean which shows
that if `⊬ φ`, then `[φ.neg]` is context-consistent (no derivation of bot).
We lift this to set-consistency.
-/
theorem not_provable_implies_neg_set_consistent (φ : Formula)
    (h_not_prov : ¬formula_provable φ) : SetConsistent {φ.neg} := by
  -- Use not_derivable_implies_neg_consistent from Construction.lean
  have h_ctx_cons : ContextConsistent [φ.neg] := not_derivable_implies_neg_consistent φ h_not_prov
  -- SetConsistent S means: for all L from S, L is Consistent
  -- Since {φ.neg} = {φ.neg}, any list from it is [φ.neg, φ.neg, ...]
  -- We need to show each such list is consistent.
  intro L h_L_sub
  -- If L is empty, it's consistent
  -- If L is non-empty and all elements are φ.neg, we need to show L is consistent.
  -- The key insight: consistency is closed under adding copies of the same formula.
  -- If [φ.neg] is consistent, then [φ.neg, φ.neg, ...] is also consistent.
  -- This follows because any derivation from [φ.neg, φ.neg, ...] can be replayed
  -- using just [φ.neg] (contraction).
  --
  -- For now, we show this directly:
  -- If L ⊢ bot, then we can derive bot using elements from L.
  -- Since all elements of L are φ.neg, this derivation uses only φ.neg.
  -- So [φ.neg] ⊢ bot, contradicting h_ctx_cons.
  intro ⟨d_bot⟩
  -- We have L ⊢ bot where every element of L is φ.neg
  -- We need to show [φ.neg] ⊢ bot to contradict h_ctx_cons
  -- The derivation d_bot only uses assumptions from L, and all are φ.neg
  -- So by contraction (proved by induction on derivation), [φ.neg] ⊢ bot
  have h_from_singleton : [φ.neg] ⊢ Formula.bot := by
    -- Key: [φ.neg] ⊆ L as a set (every element of [φ.neg] appears in L)
    -- Actually we need L ⊆ [φ.neg] for weakening to work.
    -- L = [φ.neg, φ.neg, ...], so L contains only φ.neg.
    -- Weakening says: Γ ⊆ Δ → Γ ⊢ φ → Δ ⊢ φ (bigger is stronger).
    -- We have L ⊢ bot. We need [φ.neg] ⊢ bot.
    -- Since every element of L is φ.neg, L ⊆ [φ.neg] AS A SET doesn't hold for multiplicity.
    -- But conceptually, derivations don't care about multiplicity.
    --
    -- Alternative: Use the fact that L ⊇ [φ.neg] as a set when L is non-empty.
    -- If L = [], then [] ⊢ bot is a theorem, so bot is provable.
    -- If L ≠ [], then L contains φ.neg, so [φ.neg] ⊆ L.
    -- Then we can use weakening to get L ⊢ bot from [φ.neg] ⊢ bot... no, wrong direction!
    --
    -- The correct structural property: if L ⊢ bot and all elements of L are the same ψ,
    -- then [ψ] ⊢ bot. This follows from weakening since L ⊆ [φ.neg] as sets.
    apply DerivationTree.weakening L [φ.neg] Formula.bot d_bot
    intro x hx
    simp only [List.mem_singleton]
    exact Set.mem_singleton_iff.mp (h_L_sub x hx)
  exact h_ctx_cons ⟨h_from_singleton⟩

/-!
## Succ-Chain Completeness Theorem
-/

/--
Succ-chain base completeness: not provable φ → not valid (in succ-chain model).

The proof:
1. Assume φ is not provable
2. Then {¬φ} is consistent (by not_provable_implies_neg_set_consistent)
3. Extend to MCS M₀ via Lindenbaum
4. Build Succ-chain canonical model from M₀
5. By truth lemma: ¬φ is true at M₀
6. So φ is not true at M₀

**Note**: This proves completeness relative to the Succ-chain model's Omega (singleton).
-/
theorem succ_chain_completeness (φ : Formula) :
    (¬formula_provable φ) →
    ∃ (M0 : SerialMCS),
      ¬truth_at succ_chain_model (succ_chain_omega M0) (succ_chain_history M0) 0 φ := by
  intro h_not_prov
  -- Step 1: {neg(φ)} is consistent
  have h_cons : SetConsistent {φ.neg} := not_provable_implies_neg_set_consistent φ h_not_prov
  -- Step 2: Extend to MCS via Lindenbaum
  obtain ⟨M, h_extends, h_mcs⟩ := set_lindenbaum {φ.neg} h_cons
  -- Step 3: Convert MCS to SerialMCS
  let M0 : SerialMCS := MCS_to_SerialMCS M h_mcs
  use M0
  -- Step 4: neg(φ) ∈ M (from extension)
  have h_neg_in_M : φ.neg ∈ M := by
    have h_in_seed : φ.neg ∈ ({φ.neg} : Set Formula) := Set.mem_singleton _
    exact h_extends h_in_seed
  -- Step 5: neg(φ) ∈ succ_chain_fam M0 0 = M0.world = M
  have h_neg_in_fam : φ.neg ∈ succ_chain_fam M0 0 := by
    -- succ_chain_fam M0 0 = forward_chain M0 0 = M0.world
    simp only [succ_chain_fam, forward_chain]
    exact h_neg_in_M
  -- Step 6: By truth lemma forward, neg(φ) is true at time 0
  have h_neg_true : truth_at succ_chain_model (succ_chain_omega M0) (succ_chain_history M0) 0 φ.neg :=
    succ_chain_truth_forward M0 φ.neg 0 h_neg_in_fam
  -- Step 7: neg(φ) true means (φ -> bot) true, i.e., φ true -> False
  -- So φ is not true
  simp only [Formula.neg] at h_neg_true
  intro h_phi_true
  -- truth_at ... (φ.imp bot) = (truth φ -> truth bot) = (truth φ -> False)
  simp only [truth_at] at h_neg_true
  exact h_neg_true h_phi_true

/--
Completeness in standard form: valid φ → provable φ.

This is the contrapositive of `succ_chain_completeness`.
-/
theorem succ_chain_completeness_standard (φ : Formula)
    (h_valid : ∀ (M0 : SerialMCS),
      truth_at succ_chain_model (succ_chain_omega M0) (succ_chain_history M0) 0 φ) :
    formula_provable φ := by
  by_contra h_not_prov
  obtain ⟨M0, h_not_true⟩ := succ_chain_completeness φ h_not_prov
  exact h_not_true (h_valid M0)

end Bimodal.Metalogic.Completeness
