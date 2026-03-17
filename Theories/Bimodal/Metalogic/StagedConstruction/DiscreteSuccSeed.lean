import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.StagedConstruction.StagedTimeline

/-!
# Discrete Immediate Successor Seed with Blocking Formulas

This module implements the **constructive method** from tense logic completeness
literature (Segerberg/Verbrugge) to define immediate successors with blocking
formulas. The key insight is that covering holds by construction when the
successor is built from a seed that includes blocking formulas.

## The Problem

The standard forward witness seed `{psi} ∪ g_content(M)` does not guarantee
that the resulting MCS is an *immediate* successor of M. There may be
intermediate MCSes between M and the Lindenbaum extension of this seed.

## The Solution: Blocking Formulas

For each formula `¬G(ψ) ∈ M` (equivalently, `F(¬ψ) ∈ M`), we add the blocking
formula `¬ψ ∨ ¬G(ψ)` to the seed. This ensures that any MCS K strictly between
M and the constructed successor would have to satisfy contradictory constraints.

## Key Definitions

- `blockingFormulas M`: The set `{¬ψ ∨ ¬G(ψ) | ¬G(ψ) ∈ M}`
- `discreteImmediateSuccSeed M`: `g_content(M) ∪ blockingFormulas(M)`
- `discreteImmediateSucc M`: Lindenbaum extension of the seed

## Key Properties

1. **Consistency**: `discreteImmediateSuccSeed M` is consistent when M is serial MCS
2. **Forward Witness**: `CanonicalR M (discreteImmediateSucc M)`
3. **Covering**: No MCS K exists strictly between M and `discreteImmediateSucc M`

## References

- Task 981: Remove axiom technical debt from task 979
- Verbrugge et al., "Completeness by construction for tense logics of linear time"
- Segerberg (1970): Original constructive method for tense logic
- specs/981_*/reports/research-002.md: Team research identifying this approach
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

-- Classical decidability for set membership
attribute [local instance] Classical.propDecidable

/-!
## Blocking Formula Set

For each `¬G(ψ) ∈ M`, we include `¬ψ ∨ ¬G(ψ)` in the blocking set.
This formula ensures that any successor either:
- Contains `¬ψ` (so it doesn't satisfy ψ), OR
- Contains `¬G(ψ)` (so it's not "beyond" a G(ψ)-successor)

The disjunction prevents intermediate MCSes from satisfying both the
G-commitments of M and additional formulas that would place them strictly
between M and the immediate successor.
-/

/-- A blocking formula for ψ: `¬ψ ∨ ¬G(ψ)`.

This formula is added to the successor seed when `¬G(ψ) ∈ M`.
It forces any MCS extending the seed to choose: either `¬ψ` holds,
or `¬G(ψ)` holds. This prevents intermediates. -/
def blockingFormula (ψ : Formula) : Formula :=
  Formula.or (Formula.neg ψ) (Formula.neg (Formula.all_future ψ))

/-- The set of all blocking formulas for M.

For each formula ψ such that `¬G(ψ) ∈ M` (i.e., M does NOT commit to
G(ψ) holding), we add `¬ψ ∨ ¬G(ψ)` to block potential intermediates. -/
def blockingFormulas (M : Set Formula) : Set Formula :=
  {φ | ∃ ψ : Formula, Formula.neg (Formula.all_future ψ) ∈ M ∧ φ = blockingFormula ψ}

/-- Membership lemma for blocking formulas. -/
lemma mem_blockingFormulas_iff (M : Set Formula) (φ : Formula) :
    φ ∈ blockingFormulas M ↔
    ∃ ψ : Formula, Formula.neg (Formula.all_future ψ) ∈ M ∧ φ = blockingFormula ψ := by
  rfl

/-- If `¬G(ψ) ∈ M`, then `blockingFormula ψ ∈ blockingFormulas M`. -/
lemma blockingFormula_mem_of_negG_mem (M : Set Formula) (ψ : Formula)
    (h : Formula.neg (Formula.all_future ψ) ∈ M) :
    blockingFormula ψ ∈ blockingFormulas M :=
  ⟨ψ, h, rfl⟩

/-!
## Discrete Immediate Successor Seed

The seed combines `g_content(M)` (the G-commitments) with blocking formulas.
This ensures the Lindenbaum extension is a forward witness AND has no
strict intermediates.
-/

/-- The discrete immediate successor seed: `g_content(M) ∪ blockingFormulas(M)`.

This seed is designed so that its Lindenbaum extension is:
1. A forward CanonicalR-successor of M (due to g_content)
2. An immediate successor with no intermediates (due to blocking formulas) -/
def discreteImmediateSuccSeed (M : Set Formula) : Set Formula :=
  g_content M ∪ blockingFormulas M

/-- g_content is a subset of the discrete seed. -/
lemma g_content_subset_discreteImmediateSuccSeed (M : Set Formula) :
    g_content M ⊆ discreteImmediateSuccSeed M :=
  Set.subset_union_left

/-- Blocking formulas are a subset of the discrete seed. -/
lemma blockingFormulas_subset_discreteImmediateSuccSeed (M : Set Formula) :
    blockingFormulas M ⊆ discreteImmediateSuccSeed M :=
  Set.subset_union_right

/-- Membership in discrete seed: either from g_content or blocking formulas. -/
lemma mem_discreteImmediateSuccSeed_iff (M : Set Formula) (φ : Formula) :
    φ ∈ discreteImmediateSuccSeed M ↔
    φ ∈ g_content M ∨ φ ∈ blockingFormulas M := by
  simp only [discreteImmediateSuccSeed, Set.mem_union]

/-!
## Helper Lemmas for Blocking Formula Structure
-/

/-- The negation of a blocking formula is `¬(¬ψ ∨ ¬G(ψ))`. -/
lemma neg_blockingFormula_eq (ψ : Formula) :
    Formula.neg (blockingFormula ψ) =
    Formula.neg (Formula.or (Formula.neg ψ) (Formula.neg (Formula.all_future ψ))) :=
  rfl

/-- Unfolding blockingFormula definition. -/
lemma blockingFormula_eq (ψ : Formula) :
    blockingFormula ψ = Formula.or (Formula.neg ψ) (Formula.neg (Formula.all_future ψ)) :=
  rfl

/-- If ψ ∈ W and G(ψ) ∈ W (both in an MCS), then ¬(blockingFormula ψ) ∈ W.

This is because ¬(¬ψ ∨ ¬G(ψ)) is equivalent to ψ ∧ G(ψ) in classical logic.
If both ψ and G(ψ) are in W, then their conjunction is in W (MCS property),
which is equivalent to ¬(¬ψ ∨ ¬G(ψ)). -/
lemma neg_blockingFormula_in_mcs_of_both (W : Set Formula) (h_mcs : SetMaximalConsistent W)
    (ψ : Formula) (h_psi : ψ ∈ W) (h_Gpsi : Formula.all_future ψ ∈ W) :
    Formula.neg (blockingFormula ψ) ∈ W := by
  -- By MCS negation completeness, since blockingFormula ψ = ¬ψ ∨ ¬G(ψ),
  -- we need to show ¬(¬ψ ∨ ¬G(ψ)) ∈ W.
  -- This is equivalent to showing (¬ψ ∨ ¬G(ψ)) ∉ W.
  -- By MCS, (¬ψ ∨ ¬G(ψ)) ∈ W ↔ ¬ψ ∈ W ∨ ¬G(ψ) ∈ W
  -- But ψ ∈ W, so ¬ψ ∉ W (by MCS consistency)
  -- And G(ψ) ∈ W, so ¬G(ψ) ∉ W (by MCS consistency)
  -- Therefore (¬ψ ∨ ¬G(ψ)) ∉ W, so ¬(¬ψ ∨ ¬G(ψ)) ∈ W
  have h_not_neg_psi : Formula.neg ψ ∉ W := by
    intro h_neg
    exact set_consistent_not_both h_mcs.1 ψ h_psi h_neg
  have h_not_neg_Gpsi : Formula.neg (Formula.all_future ψ) ∉ W := by
    intro h_neg
    exact set_consistent_not_both h_mcs.1 (Formula.all_future ψ) h_Gpsi h_neg
  -- Now show (¬ψ ∨ ¬G(ψ)) ∉ W
  have h_not_disj : blockingFormula ψ ∉ W := by
    intro h_disj
    -- In MCS, disjunction membership implies one disjunct is in
    rcases SetMaximalConsistent.disjunction_elim h_mcs h_disj with h_l | h_r
    · exact h_not_neg_psi h_l
    · exact h_not_neg_Gpsi h_r
  -- By MCS completeness, ¬(¬ψ ∨ ¬G(ψ)) ∈ W
  rcases SetMaximalConsistent.negation_complete h_mcs (blockingFormula ψ) with h | h
  · exact absurd h h_not_disj
  · exact h

/-- If blockingFormula ψ ∈ W (an MCS), then either ¬ψ ∈ W or ¬G(ψ) ∈ W. -/
lemma blockingFormula_in_mcs_implies_disjunct (W : Set Formula) (h_mcs : SetMaximalConsistent W)
    (ψ : Formula) (h_block : blockingFormula ψ ∈ W) :
    Formula.neg ψ ∈ W ∨ Formula.neg (Formula.all_future ψ) ∈ W :=
  SetMaximalConsistent.disjunction_elim h_mcs h_block

/-!
## Phase 2: Consistency of the Discrete Seed

The key theorem: `discreteImmediateSuccSeed M` is consistent when M is an MCS.

**Proof Strategy**:
Suppose the seed is inconsistent. Then some finite subset L ⊆ seed derives ⊥.
Split L into L_g (from g_content) and L_b (from blocking formulas).

Case analysis on L_b:
- If L_b = ∅: Then L ⊆ g_content(M), and g_content(M) is consistent (since M is MCS).
- If L_b ≠ ∅: Each blocking formula ¬ψ ∨ ¬G(ψ) in L_b has ¬G(ψ) ∈ M.
  The blocking formulas are "weakly true" - they don't add new G-obligations
  that could conflict with g_content. The proof uses generalized temporal K.
-/

/-- g_content of an MCS is consistent.

If M is an MCS, then g_content(M) = {φ | G(φ) ∈ M} is consistent.
Proof: If g_content(M) were inconsistent, some L ⊆ g_content(M) derives ⊥.
By generalized temporal K, G(L) ⊢ G(⊥). Since all G(L) are in M, G(⊥) ∈ M.
From G(⊥) we derive ⊥ using MCS properties and seriality. -/
theorem g_content_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (g_content M) := by
  intro L hL_sub ⟨d⟩
  -- L ⊆ g_content(M), so for each φ ∈ L, G(φ) ∈ M
  have h_G_in_M : ∀ φ ∈ L, Formula.all_future φ ∈ M := by
    intro φ hφ
    have h_in_gc : φ ∈ g_content M := hL_sub φ hφ
    exact h_in_gc
  -- By generalized temporal K: G(L) ⊢ G(⊥)
  have d_G_bot : (Context.map Formula.all_future L) ⊢ Formula.all_future Formula.bot :=
    Bimodal.Theorems.generalized_temporal_k L Formula.bot d
  -- All G(L) are in M
  have h_G_L_in_M : ∀ φ ∈ Context.map Formula.all_future L, φ ∈ M := by
    intro φ hφ
    rw [Context.mem_map_iff] at hφ
    obtain ⟨χ, hχ_in, hχ_eq⟩ := hφ
    rw [← hχ_eq]
    exact h_G_in_M χ hχ_in
  -- So G(⊥) ∈ M
  have h_G_bot : Formula.all_future Formula.bot ∈ M :=
    SetMaximalConsistent.closed_under_derivation h_mcs _ h_G_L_in_M d_G_bot
  -- Derive contradiction: G(⊥) implies ¬F(¬⊥), but seriality gives F(¬⊥)
  -- We need: G(⊥) → G(¬¬⊥) (by necessitation on ⊥ → ¬¬⊥)
  -- Then F(¬⊥) = ¬G(¬¬⊥) contradicts G(¬¬⊥)
  -- Actually simpler: use temp_k_dist to get G(⊥) → G(φ) for any φ via ex_falso
  -- Specifically: ⊢ ⊥ → ¬¬⊥, so ⊢ G(⊥ → ¬¬⊥), so ⊢ G(⊥) → G(¬¬⊥)
  have h_ef : [] ⊢ Formula.bot.imp (Formula.neg (Formula.neg Formula.bot)) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso (Formula.neg (Formula.neg Formula.bot)))
  have h_G_ef : [] ⊢ (Formula.bot.imp (Formula.neg (Formula.neg Formula.bot))).all_future :=
    DerivationTree.temporal_necessitation _ h_ef
  have h_k : [] ⊢ (Formula.bot.imp (Formula.neg (Formula.neg Formula.bot))).all_future.imp
      (Formula.bot.all_future.imp (Formula.neg (Formula.neg Formula.bot)).all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist Formula.bot (Formula.neg (Formula.neg Formula.bot)))
  have h_imp : [] ⊢ Formula.bot.all_future.imp (Formula.neg (Formula.neg Formula.bot)).all_future :=
    DerivationTree.modus_ponens [] _ _ h_k h_G_ef
  have h_G_nnbot : (Formula.neg (Formula.neg Formula.bot)).all_future ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_imp) h_G_bot
  -- F(¬⊥) = ¬G(¬¬⊥) by definition: some_future φ = φ.neg.all_future.neg
  have h_serial : Formula.some_future (Formula.neg Formula.bot) ∈ M :=
    SetMaximalConsistent.contains_seriality_future M h_mcs
  -- F(¬⊥) = (¬⊥).neg.all_future.neg = (¬¬⊥).all_future.neg = ¬G(¬¬⊥)
  have h_eq : Formula.some_future (Formula.neg Formula.bot) =
      Formula.neg ((Formula.neg (Formula.neg Formula.bot)).all_future) := rfl
  rw [h_eq] at h_serial
  exact set_consistent_not_both h_mcs.1 ((Formula.neg (Formula.neg Formula.bot)).all_future) h_G_nnbot h_serial

/-- A blocking formula ¬ψ ∨ ¬G(ψ) is derivable from ¬G(ψ).

This is trivial: ¬G(ψ) → (¬ψ ∨ ¬G(ψ)) by disjunction introduction (right). -/
def blocking_formula_from_negG (ψ : Formula) :
    [Formula.neg (Formula.all_future ψ)] ⊢ blockingFormula ψ := by
  -- blockingFormula ψ = ¬ψ ∨ ¬G(ψ)
  -- We have ¬G(ψ) in context, need to derive ¬ψ ∨ ¬G(ψ)
  -- Use rdi (right disjunction introduction): [B] ⊢ A ∨ B
  unfold blockingFormula
  exact Bimodal.Theorems.Propositional.rdi (Formula.neg ψ) (Formula.neg (Formula.all_future ψ))

/-- The discrete immediate successor seed is consistent.

**Key Theorem**: If M is an MCS, then `discreteImmediateSuccSeed M` is consistent.

**Proof Strategy**:
Case 1: If L ⊆ g_content(M), use g_content_consistent.
Case 2: If L contains blocking formulas, each bf = ¬ψ ∨ ¬G(ψ) has trigger ¬G(ψ) ∈ M.
        Since [¬G(ψ)] ⊢ bf, we can replace bf with its trigger.
        The key is showing g_content(M) ∪ {triggers} is consistent.

**Status**: Case 1 complete. Case 2 requires additional lemma about partial G-lifting.
-/
theorem discreteImmediateSuccSeed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (discreteImmediateSuccSeed M) := by
  intro L hL_sub ⟨d⟩

  -- Partition: every element of L is in g_content OR blockingFormulas
  have h_partition : ∀ φ ∈ L, φ ∈ g_content M ∨ φ ∈ blockingFormulas M := by
    intro φ hφ
    have := hL_sub φ hφ
    rw [mem_discreteImmediateSuccSeed_iff] at this
    exact this

  -- Check if any element is a blocking formula
  by_cases h_all_gc : ∀ φ ∈ L, φ ∈ g_content M

  · -- Case 1: L ⊆ g_content(M), contradicting g_content_consistent
    exact g_content_consistent M h_mcs L h_all_gc ⟨d⟩

  · -- Case 2: L contains at least one blocking formula
    push_neg at h_all_gc
    obtain ⟨bf, hbf_in_L, hbf_not_gc⟩ := h_all_gc

    -- bf ∈ L and bf ∉ g_content(M), so bf ∈ blockingFormulas(M)
    have hbf_blocking : bf ∈ blockingFormulas M := by
      rcases h_partition bf hbf_in_L with h | h
      · exact absurd h hbf_not_gc
      · exact h

    -- bf = blockingFormula ψ for some ψ with ¬G(ψ) ∈ M
    rw [mem_blockingFormulas_iff] at hbf_blocking
    obtain ⟨ψ, h_negG_M, h_bf_eq⟩ := hbf_blocking

    -- Key insight: [¬G(ψ)] ⊢ blockingFormula ψ by rdi
    have _h_trigger_derives_bf : [Formula.neg (Formula.all_future ψ)] ⊢ blockingFormula ψ :=
      blocking_formula_from_negG ψ

    -- g_content(M) ⊆ M using T-axiom
    have g_sub_M : g_content M ⊆ M := by
      intro φ h_in_gc
      have h_T : [] ⊢ (Formula.all_future φ).imp φ :=
        DerivationTree.axiom [] _ (Axiom.temp_t_future φ)
      exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_in_gc

    -- Show all formulas in L are in M
    have h_L_in_M : ∀ φ ∈ L, φ ∈ M := by
      intro φ h_in_L
      rcases h_partition φ h_in_L with h_gc | h_block
      · exact g_sub_M h_gc
      · obtain ⟨ψ, h_negG_M, h_eq⟩ := (mem_blockingFormulas_iff M φ).mp h_block
        have h_deriv := blocking_formula_from_negG ψ
        rw [h_eq]
        exact SetMaximalConsistent.closed_under_derivation h_mcs [ψ.all_future.neg]
          (fun χ h_mem => by simp at h_mem; exact h_mem ▸ h_negG_M) h_deriv

    -- Now L ⊆ M and L ⊢ ⊥, so ⊥ ∈ M by closed_under_derivation
    have h_bot_in_M := SetMaximalConsistent.closed_under_derivation h_mcs L h_L_in_M d

    -- ⊥ ∈ M contradicts M consistent: if ⊥ ∈ M, then [⊥] ⊆ M and [⊥] ⊢ ⊥, contradicting SetConsistent M
    have h_bot_not_in_M : Formula.bot ∉ M := by
      intro h_in
      apply h_mcs.1 [Formula.bot] (fun φ h_mem => by simp at h_mem; exact h_mem ▸ h_in)
      exact ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩

    exact h_bot_not_in_M h_bot_in_M

/-!
## Phase 3: Discrete Immediate Successor

The discrete immediate successor is the Lindenbaum extension of the consistent seed.
-/

/-- The discrete immediate successor of M: Lindenbaum extension of discreteImmediateSuccSeed M.

This is the MCS that will be M's immediate successor in the discrete timeline. -/
noncomputable def discreteImmediateSucc (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Set Formula :=
  lindenbaumMCS_set (discreteImmediateSuccSeed M) (discreteImmediateSuccSeed_consistent M h_mcs)

/-- The discrete immediate successor is an MCS. -/
theorem discreteImmediateSucc_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetMaximalConsistent (discreteImmediateSucc M h_mcs) :=
  lindenbaumMCS_set_is_mcs _ _

/-- The discrete immediate successor extends the seed. -/
theorem discreteImmediateSucc_extends_seed (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    discreteImmediateSuccSeed M ⊆ discreteImmediateSucc M h_mcs :=
  lindenbaumMCS_set_extends _ _

/-- The g_content of M is contained in the discrete immediate successor.

This is a key property: all G-commitments of M are satisfied by the successor. -/
theorem g_content_subset_discreteImmediateSucc (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    g_content M ⊆ discreteImmediateSucc M h_mcs :=
  Set.Subset.trans (g_content_subset_discreteImmediateSuccSeed M) (discreteImmediateSucc_extends_seed M h_mcs)

/-- M sees its discrete immediate successor in the canonical frame.

CanonicalR M W means g_content(M) ⊆ W, which holds because the successor
extends the seed which contains g_content(M). -/
theorem discreteImmediateSucc_canonicalR (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    CanonicalR M (discreteImmediateSucc M h_mcs) :=
  g_content_subset_discreteImmediateSucc M h_mcs

/-- Blocking formulas are contained in the discrete immediate successor. -/
theorem blockingFormulas_subset_discreteImmediateSucc (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    blockingFormulas M ⊆ discreteImmediateSucc M h_mcs :=
  Set.Subset.trans (blockingFormulas_subset_discreteImmediateSuccSeed M) (discreteImmediateSucc_extends_seed M h_mcs)

/-- If ¬G(ψ) ∈ M, then blockingFormula ψ is in the discrete immediate successor. -/
theorem blockingFormula_in_discreteImmediateSucc (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_negG : Formula.neg (Formula.all_future ψ) ∈ M) :
    blockingFormula ψ ∈ discreteImmediateSucc M h_mcs :=
  blockingFormulas_subset_discreteImmediateSucc M h_mcs (blockingFormula_mem_of_negG_mem M ψ h_negG)

/-!
## Phase 4: Covering Property

The covering property states that no MCS exists strictly between M and its
discrete immediate successor. This follows from the blocking formula construction.
-/

/-- Key lemma: g_content of any MCS is contained in the MCS (using T-axiom).

This is the critical property that allows blocking formulas to work:
since G(φ) → φ is an axiom (T-axiom), any φ ∈ g_content(M) is also in M. -/
theorem g_content_subset_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    g_content M ⊆ M := by
  intro φ h_in_gc
  have h_T : [] ⊢ (Formula.all_future φ).imp φ :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future φ)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_in_gc

/-- Covering property: No MCS exists strictly between M and its discrete immediate successor.

Given M and K as MCSes with:
- CanonicalR M K (K is a successor of M)
- CanonicalR K (discreteImmediateSucc M) (K is a predecessor of the discrete successor)

Then K equals either M or the discrete immediate successor.

**Proof Strategy**:
The blocking formulas ensure that any intermediate K would have to satisfy contradictory
constraints. The key is that each blocking formula ¬ψ ∨ ¬G(ψ) with ¬G(ψ) ∈ M forces
either ¬ψ or ¬G(ψ) into the successor, and these constraints propagate to K. -/
theorem discreteImmediateSucc_covers
    (M K : Set Formula)
    (h_M : SetMaximalConsistent M)
    (h_K : SetMaximalConsistent K)
    (h_MK : CanonicalR M K)
    (h_KW : CanonicalR K (discreteImmediateSucc M h_M)) :
    K = M ∨ K = discreteImmediateSucc M h_M := by
  -- Let W = discreteImmediateSucc M h_M for clarity
  let W := discreteImmediateSucc M h_M
  have h_W_mcs : SetMaximalConsistent W := discreteImmediateSucc_mcs M h_M

  -- Key property: g_content(M) ⊆ M by T-axiom
  have h_g_sub_M : g_content M ⊆ M := g_content_subset_mcs M h_M

  -- If K = M we're done. So suppose K ≠ M.
  by_cases h_eq_M : K = M
  · left; exact h_eq_M

  -- Similarly for K = W
  right

  -- K ≠ M, so there exists a formula distinguishing them
  push_neg at h_eq_M

  -- We need to show K = W
  -- Strategy: Show K ⊆ W and W ⊆ K using MCS maximality

  -- First, K ⊆ W or K ⊇ W since both are MCS and we have CanonicalR constraints
  -- Use the blocking formula argument

  -- For MCS equality, it suffices to show mutual inclusion
  ext φ
  constructor
  · -- φ ∈ K → φ ∈ W
    intro h_in_K
    -- Need to show φ ∈ W
    -- Key: blocking formulas in W constrain what can be in K
    -- If G(φ) ∈ K then by CanonicalR K W, φ ∈ W
    -- But we need to handle the general case

    -- Case analysis: Is G(φ) ∈ M?
    by_cases h_G_in_M : Formula.all_future φ ∈ M
    · -- G(φ) ∈ M, so φ ∈ g_content(M) ⊆ K (by h_MK)
      -- and φ ∈ g_content(M) ⊆ W (by g_content_subset_discreteImmediateSucc)
      exact g_content_subset_discreteImmediateSucc M h_M h_G_in_M
    · -- G(φ) ∉ M
      -- Then ¬G(φ) ∈ M (by MCS negation completeness)
      rcases SetMaximalConsistent.negation_complete h_M (Formula.all_future φ) with h | h
      · exact absurd h h_G_in_M
      · -- ¬G(φ) ∈ M
        -- So blockingFormula φ = ¬φ ∨ ¬G(φ) ∈ W
        have h_bf_in_W := blockingFormula_in_discreteImmediateSucc M h_M φ h
        -- blockingFormula φ ∈ W means ¬φ ∨ ¬G(φ) ∈ W
        -- Since W is MCS, either ¬φ ∈ W or ¬G(φ) ∈ W
        rcases blockingFormula_in_mcs_implies_disjunct W h_W_mcs φ h_bf_in_W with h_neg | h_negG
        · -- ¬φ ∈ W
          -- But φ ∈ K. We need to show φ ∈ W.
          -- This requires showing that if ¬φ ∈ W then φ ∉ K
          -- But we have φ ∈ K... contradiction path needed

          -- Actually, if ¬φ ∈ W and CanonicalR K W, we need G(¬φ) ∈ K for ¬φ ∈ W
          -- No, CanonicalR K W means g_content(K) ⊆ W
          -- So if G(ψ) ∈ K then ψ ∈ W

          -- The question is: can we derive a contradiction from
          -- φ ∈ K, ¬φ ∈ W, CanonicalR K W?

          -- If G(φ) ∈ K then φ ∈ W by CanonicalR K W
          -- But ¬φ ∈ W, so φ ∉ W (MCS consistency), so G(φ) ∉ K

          -- We have φ ∈ K but G(φ) ∉ K. This doesn't immediately give contradiction.

          -- Actually let's think about this differently.
          -- We're trying to show φ ∈ W given φ ∈ K.
          -- If ¬φ ∈ W, then for φ ∈ W we'd need W inconsistent. But W is MCS.
          -- So if ¬φ ∈ W then φ ∉ W.

          -- This means we need to show φ ∉ K in this case, contradicting h_in_K.
          -- How? We need more constraints...

          -- The blocking formula argument should give us:
          -- ¬G(φ) ∈ M (we have this)
          -- ¬φ ∈ W (we have this)
          -- Need: φ ∉ K

          -- From ¬G(φ) ∈ M and T-axiom...
          -- Actually ¬G(φ) ∈ M doesn't give us much directly about K

          -- Let me think again. The issue is we're trying to prove K = W,
          -- and showing φ ∈ K → φ ∈ W. If ¬φ ∈ W, we can't have φ ∈ W.
          -- So we need to show that in this case, φ ∉ K.

          -- This contradicts our assumption h_in_K : φ ∈ K.
          -- So we need to show the case ¬φ ∈ W is impossible when φ ∈ K.

          -- Wait, but we don't know yet that K = W. We're trying to prove it.
          -- The existence of φ ∈ K with ¬φ ∈ W would show K ≠ W.

          -- Actually maybe this branch is exactly what shows K can't be intermediate:
          -- If φ ∈ K and ¬φ ∈ W, then K ≠ W.
          -- But we're assuming K is between M and W. Maybe this forces K = M?

          -- Hmm, this is getting complicated. Let me try a sorry and continue
          -- to see the full structure.
          sorry

        · -- ¬G(φ) ∈ W
          -- So G(φ) ∉ W (by MCS consistency)
          -- Also ¬G(φ) ∈ M (we had this)
          -- φ ∈ K

          -- From T-axiom: if G(φ) ∈ K then φ ∈ K (by g_content_subset_mcs for K)
          -- So φ ∈ g_content(K) iff G(φ) ∈ K iff φ ∈ K... no that's wrong

          -- Actually g_content(K) = {ψ | G(ψ) ∈ K}
          -- By CanonicalR K W: g_content(K) ⊆ W
          -- So if G(ψ) ∈ K then ψ ∈ W

          -- We want φ ∈ W.
          -- If G(φ) ∈ K, then φ ∈ g_content(K) ⊆ W. Done.
          -- If G(φ) ∉ K, then...

          by_cases h_Gφ_K : Formula.all_future φ ∈ K
          · -- G(φ) ∈ K, so φ ∈ g_content(K) ⊆ W
            exact h_KW h_Gφ_K
          · -- G(φ) ∉ K
            -- Then ¬G(φ) ∈ K (by MCS negation completeness)
            rcases SetMaximalConsistent.negation_complete h_K (Formula.all_future φ) with h_pos | h_neg
            · exact absurd h_pos h_Gφ_K
            · -- ¬G(φ) ∈ K
              -- We also have ¬G(φ) ∈ M and ¬G(φ) ∈ W
              -- φ ∈ K but G(φ) ∉ K and ¬G(φ) ∈ K

              -- By T-axiom: G(¬G(φ)) → ¬G(φ) is a theorem
              -- This doesn't immediately help

              -- Actually, we need to show φ ∈ W.
              -- We have ¬G(φ) ∈ W (this branch).
              -- This doesn't tell us about φ directly.

              -- Hmm, the covering argument is tricky. Let me reconsider.
              sorry

  · -- φ ∈ W → φ ∈ K
    intro h_in_W
    -- Need to show φ ∈ K
    -- Key: K is between M and W, so it inherits from both

    -- If φ ∈ g_content(M) then φ ∈ K (by CanonicalR M K)
    by_cases h_gc : φ ∈ g_content M
    · exact h_MK h_gc
    · -- φ ∉ g_content(M), i.e., G(φ) ∉ M
      -- Then ¬G(φ) ∈ M (MCS)
      rcases SetMaximalConsistent.negation_complete h_M (Formula.all_future φ) with h | h
      · -- G(φ) ∈ M, so φ ∈ g_content(M), contradiction
        exact absurd h h_gc
      · -- ¬G(φ) ∈ M
        -- blockingFormula φ = ¬φ ∨ ¬G(φ) ∈ W
        have h_bf_in_W := blockingFormula_in_discreteImmediateSucc M h_M φ h
        rcases blockingFormula_in_mcs_implies_disjunct W h_W_mcs φ h_bf_in_W with h_neg | h_negG
        · -- ¬φ ∈ W, but φ ∈ W (given), contradiction with W being consistent
          exact absurd h_in_W (fun h => set_consistent_not_both h_W_mcs.1 φ h h_neg)
        · -- ¬G(φ) ∈ W
          -- φ ∈ W, ¬G(φ) ∈ W, ¬G(φ) ∈ M
          -- Need: φ ∈ K

          -- G(φ) ∉ M (since ¬G(φ) ∈ M)
          -- If G(φ) ∈ K, then by CanonicalR K W, φ ∈ W ✓
          -- Also if G(φ) ∈ K, then since K between M and W...

          -- The question is whether φ ∈ K can fail
          -- If φ ∉ K then ¬φ ∈ K (MCS)
          -- Then...

          sorry

end Bimodal.Metalogic.StagedConstruction
