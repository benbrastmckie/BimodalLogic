import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.Combinators

/-!
# Witness Seed Definitions and Consistency

This module contains the temporal witness seed definitions and their consistency
proofs, extracted from DovetailingChain.lean for use by CanonicalFrame.lean.

Also contains the g_content/h_content duality theorems (g_content ⊆ implies h_content
reverse, and vice versa).

## Key Definitions

- `forward_temporal_witness_seed M psi`: `{psi} ∪ g_content(M)`
- `past_temporal_witness_seed M psi`: `{psi} ∪ h_content(M)`

## Key Theorems

- `forward_temporal_witness_seed_consistent`: If F(psi) ∈ MCS M, then the forward seed is consistent
- `past_temporal_witness_seed_consistent`: If P(psi) ∈ MCS M, then the past seed is consistent
- `g_content_subset_implies_h_content_reverse`: g_content(M) ⊆ M' implies h_content(M') ⊆ M
- `h_content_subset_implies_g_content_reverse`: h_content(M) ⊆ M' implies g_content(M') ⊆ M

## Design Note

These proofs work with irreflexive temporal semantics (G/H use strict `<`).
The seed consistency proofs do NOT use the T-axiom (`G phi → phi`). Instead,
the `psi ∉ L` case uses generalized temporal K to derive G(⊥) from L ⊢ ⊥,
then derives G(¬psi) which contradicts F(psi) ∈ M.
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Forward Temporal Witness Seed
-/

/-- Forward witness seed: `{psi} ∪ g_content(M)`. -/
def forward_temporal_witness_seed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ g_content M

/-- psi is in its own forward_temporal_witness_seed. -/
lemma psi_mem_forward_temporal_witness_seed (M : Set Formula) (psi : Formula) :
    psi ∈ forward_temporal_witness_seed M psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/-- g_content is a subset of forward_temporal_witness_seed. -/
lemma g_content_subset_forward_temporal_witness_seed (M : Set Formula) (psi : Formula) :
    g_content M ⊆ forward_temporal_witness_seed M psi :=
  Set.subset_union_right

/--
Forward temporal witness seed consistency: If F(psi) is in an MCS M, then
`{psi} ∪ g_content(M)` is consistent.

**Proof Strategy** (irreflexive-compatible, no T-axiom needed):
Suppose `{psi} ∪ g_content(M)` is inconsistent. Then there exist `L ⊆ {psi} ∪ g_content(M)`
with `L ⊢ ⊥`.

Case 1 (psi ∈ L): By deduction, `L \ {psi} ⊢ ¬psi`. By generalized temporal K,
`G(L \ {psi}) ⊢ G(¬psi)`. Since `G chi ∈ M` for all `chi ∈ L \ {psi}`, by MCS closure
`G(¬psi) ∈ M`. But `F(psi) = ¬G(¬psi) ∈ M`. Contradiction.

Case 2 (psi ∉ L): All of L are in g_content(M), so `G chi ∈ M` for each `chi ∈ L`.
From `L ⊢ ⊥`, by generalized temporal K, `G(L) ⊢ G(⊥)`. Since all of `G(L)` are in M,
`G(⊥) ∈ M`. From `⊢ ⊥ → ¬psi`, by temporal necessitation `⊢ G(⊥ → ¬psi)`, by temporal K
distribution `⊢ G(⊥) → G(¬psi)`, so `G(¬psi) ∈ M`. But `F(psi) = ¬G(¬psi) ∈ M`.
Contradiction.
-/
theorem forward_temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent (forward_temporal_witness_seed M psi) := by
  intro L hL_sub ⟨d⟩

  by_cases h_psi_in : psi ∈ L
  · -- Case: psi ∈ L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)

    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord

    -- Get G chi ∈ M for each chi ∈ L_filt from g_content
    have h_G_filt_in_M : ∀ chi ∈ L_filt, Formula.all_future chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [forward_temporal_witness_seed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq h_ne
      · exact h_gcontent

    -- Apply generalized temporal K (G distributes over derivation)
    have d_G_neg : (Context.map Formula.all_future L_filt) ⊢ Formula.all_future (Formula.neg psi) :=
      Bimodal.Theorems.generalized_temporal_k L_filt (Formula.neg psi) d_neg

    -- All formulas in G(L_filt) are in M
    have h_G_context_in_M : ∀ phi ∈ Context.map Formula.all_future L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_G_filt_in_M chi h_chi_in

    -- By MCS closure under derivation, G(neg psi) ∈ M
    have h_G_neg_in_M : Formula.all_future (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.closed_under_derivation h_mcs (Context.map Formula.all_future L_filt)
        h_G_context_in_M d_G_neg

    -- Contradiction - F psi = neg(G(neg psi)) is also in M
    have h_F_eq : Formula.some_future psi = Formula.neg (Formula.all_future (Formula.neg psi)) := rfl
    rw [h_F_eq] at h_F
    exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg psi)) h_G_neg_in_M h_F

  · -- Case: psi ∉ L, so L ⊆ g_content M
    -- All elements of L are in g_content(M), meaning G chi ∈ M for each chi
    have h_G_all_in_M : ∀ chi ∈ L, Formula.all_future chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [forward_temporal_witness_seed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · exact h_gcontent

    -- From L ⊢ ⊥, by generalized temporal K: G(L) ⊢ G(⊥)
    have d_G_bot : (Context.map Formula.all_future L) ⊢ Formula.all_future Formula.bot :=
      Bimodal.Theorems.generalized_temporal_k L Formula.bot d

    -- All formulas in G(L) are in M
    have h_G_L_in_M : ∀ phi ∈ Context.map Formula.all_future L, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_G_all_in_M chi h_chi_in

    -- So G(⊥) ∈ M
    have h_G_bot_in_M : Formula.all_future Formula.bot ∈ M :=
      SetMaximalConsistent.closed_under_derivation h_mcs (Context.map Formula.all_future L)
        h_G_L_in_M d_G_bot

    -- ⊢ ⊥ → ¬psi by prop_s (weakening): ⊢ ⊥ → (psi → ⊥) = ⊢ ⊥ → ¬psi
    have h_bot_imp_neg : [] ⊢ Formula.bot.imp (Formula.neg psi) :=
      DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot psi)

    -- By temporal necessitation: ⊢ G(⊥ → ¬psi)
    have h_G_ef : [] ⊢ Formula.all_future (Formula.bot.imp (Formula.neg psi)) :=
      DerivationTree.temporal_necessitation _ h_bot_imp_neg

    -- By temporal K distribution: ⊢ G(⊥ → ¬psi) → (G(⊥) → G(¬psi))
    have h_K : [] ⊢ (Formula.all_future (Formula.bot.imp (Formula.neg psi))).imp
                     ((Formula.all_future Formula.bot).imp (Formula.all_future (Formula.neg psi))) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist Formula.bot (Formula.neg psi))

    -- Modus ponens twice: G(¬psi) ∈ M
    have h_G_imp : [] ⊢ (Formula.all_future Formula.bot).imp (Formula.all_future (Formula.neg psi)) :=
      DerivationTree.modus_ponens [] _ _ h_K h_G_ef
    have h_G_neg_psi : Formula.all_future (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_G_imp) h_G_bot_in_M

    -- Contradiction: F(psi) = ¬G(¬psi) ∈ M
    have h_F_eq : Formula.some_future psi = Formula.neg (Formula.all_future (Formula.neg psi)) := rfl
    rw [h_F_eq] at h_F
    exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg psi)) h_G_neg_psi h_F

/-!
## Past Temporal Witness Seed
-/

/-- Past witness seed: `{psi} ∪ h_content(M)`. -/
def past_temporal_witness_seed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ h_content M

/-- psi is in its own past_temporal_witness_seed. -/
lemma psi_mem_past_temporal_witness_seed (M : Set Formula) (psi : Formula) :
    psi ∈ past_temporal_witness_seed M psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/-- h_content is a subset of past_temporal_witness_seed. -/
lemma h_content_subset_past_temporal_witness_seed (M : Set Formula) (psi : Formula) :
    h_content M ⊆ past_temporal_witness_seed M psi :=
  Set.subset_union_right

/--
Past temporal witness seed consistency: If P(psi) is in an MCS M, then
`{psi} ∪ h_content(M)` is consistent.

Symmetric to `forward_temporal_witness_seed_consistent`, using H and P instead of G and F.
-/
theorem past_temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    SetConsistent (past_temporal_witness_seed M psi) := by
  intro L hL_sub ⟨d⟩

  by_cases h_psi_in : psi ∈ L
  · -- Case: psi ∈ L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)

    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord

    -- Get H chi ∈ M for each chi ∈ L_filt from h_content
    have h_H_filt_in_M : ∀ chi ∈ L_filt, Formula.all_past chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [past_temporal_witness_seed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hcontent
      · exact absurd h_eq h_ne
      · exact h_hcontent

    -- Apply generalized past K (H distributes over derivation)
    have d_H_neg : (Context.map Formula.all_past L_filt) ⊢ Formula.all_past (Formula.neg psi) :=
      Bimodal.Theorems.generalized_past_k L_filt (Formula.neg psi) d_neg

    -- All formulas in H(L_filt) are in M
    have h_H_context_in_M : ∀ phi ∈ Context.map Formula.all_past L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_H_filt_in_M chi h_chi_in

    -- By MCS closure under derivation, H(neg psi) ∈ M
    have h_H_neg_in_M : Formula.all_past (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.closed_under_derivation h_mcs (Context.map Formula.all_past L_filt)
        h_H_context_in_M d_H_neg

    -- Contradiction - P psi = neg(H(neg psi)) is also in M
    have h_P_eq : Formula.some_past psi = Formula.neg (Formula.all_past (Formula.neg psi)) := rfl
    rw [h_P_eq] at h_P
    exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg psi)) h_H_neg_in_M h_P

  · -- Case: psi ∉ L, so L ⊆ h_content M
    have h_H_all_in_M : ∀ chi ∈ L, Formula.all_past chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [past_temporal_witness_seed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · exact h_hcontent

    -- From L ⊢ ⊥, by generalized past K: H(L) ⊢ H(⊥)
    have d_H_bot : (Context.map Formula.all_past L) ⊢ Formula.all_past Formula.bot :=
      Bimodal.Theorems.generalized_past_k L Formula.bot d

    -- All formulas in H(L) are in M
    have h_H_L_in_M : ∀ phi ∈ Context.map Formula.all_past L, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_H_all_in_M chi h_chi_in

    -- So H(⊥) ∈ M
    have h_H_bot_in_M : Formula.all_past Formula.bot ∈ M :=
      SetMaximalConsistent.closed_under_derivation h_mcs (Context.map Formula.all_past L)
        h_H_L_in_M d_H_bot

    -- ⊢ ⊥ → ¬psi by prop_s (weakening): ⊢ ⊥ → (psi → ⊥) = ⊢ ⊥ → ¬psi
    have h_bot_imp_neg : [] ⊢ Formula.bot.imp (Formula.neg psi) :=
      DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot psi)

    -- By past necessitation: ⊢ H(⊥ → ¬psi)
    have h_H_ef : [] ⊢ Formula.all_past (Formula.bot.imp (Formula.neg psi)) :=
      Bimodal.Theorems.past_necessitation _ h_bot_imp_neg

    -- By past K distribution: ⊢ H(⊥ → ¬psi) → (H(⊥) → H(¬psi))
    have h_K : [] ⊢ (Formula.all_past (Formula.bot.imp (Formula.neg psi))).imp
                     ((Formula.all_past Formula.bot).imp (Formula.all_past (Formula.neg psi))) :=
      Bimodal.Theorems.past_k_dist Formula.bot (Formula.neg psi)

    -- Modus ponens twice: H(¬psi) ∈ M
    have h_H_imp : [] ⊢ (Formula.all_past Formula.bot).imp (Formula.all_past (Formula.neg psi)) :=
      DerivationTree.modus_ponens [] _ _ h_K h_H_ef
    have h_H_neg_psi : Formula.all_past (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_H_imp) h_H_bot_in_M

    -- Contradiction: P(psi) = ¬H(¬psi) ∈ M
    have h_P_eq : Formula.some_past psi = Formula.neg (Formula.all_past (Formula.neg psi)) := rfl
    rw [h_P_eq] at h_P
    exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg psi)) h_H_neg_psi h_P

/-!
## Until Temporal Witness Seed

When `φ U ψ ∈ M` (MCS), we need to eventually find a successor where ψ holds.
The until witness seed `{ψ} ∪ g_content(M)` is consistent, proven using the
`until_induction` axiom with `χ = ⊥`.
-/

/-- Until witness seed: `{ψ} ∪ g_content(M)`. -/
def until_witness_seed (M : Set Formula) (ψ : Formula) : Set Formula :=
  {ψ} ∪ g_content M

/-- ψ is in its own until_witness_seed. -/
lemma psi_mem_until_witness_seed (M : Set Formula) (ψ : Formula) :
    ψ ∈ until_witness_seed M ψ :=
  Set.mem_union_left _ (Set.mem_singleton ψ)

/-- g_content is a subset of until_witness_seed. -/
lemma g_content_subset_until_witness_seed (M : Set Formula) (ψ : Formula) :
    g_content M ⊆ until_witness_seed M ψ :=
  Set.subset_union_right

/--
Until witness seed consistency: If `φ U ψ ∈ M` and M is MCS, then
`{ψ} ∪ g_content(M)` is consistent.

**Proof Strategy**:
Suppose `{ψ} ∪ g_content(M)` is inconsistent. Then `G(¬ψ) ∈ M` (by the same
argument as forward_temporal_witness_seed_consistent).

Now apply `until_induction` with `χ = ⊥`:
  `G(ψ → ⊥) ∧ G((φ ∧ ⊥) → G(⊥)) → ((φ U ψ) → ⊥)`

- `G(ψ → ⊥) = G(¬ψ)` — we have this.
- `G((φ ∧ ⊥) → G(⊥))` — provable since `(φ ∧ ⊥) → G(⊥)` is provable (ex falso).

Therefore `(φ U ψ) → ⊥ ∈ M`, i.e., `¬(φ U ψ) ∈ M`, contradicting `φ U ψ ∈ M`.
-/
theorem until_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_U : Formula.untl φ ψ ∈ M) :
    SetConsistent (until_witness_seed M ψ) := by
  intro L hL_sub ⟨d⟩

  -- Extract G(¬ψ) ∈ M from the inconsistency of {ψ} ∪ g_content(M)
  -- (Same argument as forward_temporal_witness_seed_consistent)
  have h_G_neg_psi : Formula.all_future (Formula.neg ψ) ∈ M := by
    by_cases h_psi_in : ψ ∈ L
    · -- Case: ψ ∈ L — derive G(¬ψ) via generalized temporal K
      let L_filt := L.filter (fun y => decide (y ≠ ψ))
      have h_perm := cons_filter_neq_perm h_psi_in
      have d_reord : DerivationTree (ψ :: L_filt) Formula.bot :=
        derivation_exchange d (fun x => (h_perm x).symm)
      have d_neg : L_filt ⊢ Formula.neg ψ :=
        deduction_theorem L_filt ψ Formula.bot d_reord
      have h_G_filt_in_M : ∀ chi ∈ L_filt, Formula.all_future chi ∈ M := by
        intro chi h_mem
        have h_and := List.mem_filter.mp h_mem
        have h_in_L := h_and.1
        have h_ne : chi ≠ ψ := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
        have h_in_seed := hL_sub chi h_in_L
        simp only [until_witness_seed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
        rcases h_in_seed with h_eq | h_gcontent
        · exact absurd h_eq h_ne
        · exact h_gcontent
      have d_G_neg : (Context.map Formula.all_future L_filt) ⊢ Formula.all_future (Formula.neg ψ) :=
        Bimodal.Theorems.generalized_temporal_k L_filt (Formula.neg ψ) d_neg
      have h_G_context_in_M : ∀ f ∈ Context.map Formula.all_future L_filt, f ∈ M := by
        intro f h_mem
        rw [Context.mem_map_iff] at h_mem
        rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
        rw [← h_eq]
        exact h_G_filt_in_M chi h_chi_in
      exact SetMaximalConsistent.closed_under_derivation h_mcs
        (Context.map Formula.all_future L_filt) h_G_context_in_M d_G_neg
    · -- Case: ψ ∉ L — all of L ⊆ g_content(M), derive G(⊥) then G(¬ψ)
      have h_G_all_in_M : ∀ chi ∈ L, Formula.all_future chi ∈ M := by
        intro chi h_mem
        have h_in_seed := hL_sub chi h_mem
        simp only [until_witness_seed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
        rcases h_in_seed with h_eq | h_gcontent
        · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
        · exact h_gcontent
      have d_G_bot : (Context.map Formula.all_future L) ⊢ Formula.all_future Formula.bot :=
        Bimodal.Theorems.generalized_temporal_k L Formula.bot d
      have h_G_L_in_M : ∀ f ∈ Context.map Formula.all_future L, f ∈ M := by
        intro f h_mem
        rw [Context.mem_map_iff] at h_mem
        rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
        rw [← h_eq]
        exact h_G_all_in_M chi h_chi_in
      have h_G_bot_in_M : Formula.all_future Formula.bot ∈ M :=
        SetMaximalConsistent.closed_under_derivation h_mcs
          (Context.map Formula.all_future L) h_G_L_in_M d_G_bot
      have h_bot_imp_neg : [] ⊢ Formula.bot.imp (Formula.neg ψ) :=
        DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot ψ)
      have h_G_ef : [] ⊢ Formula.all_future (Formula.bot.imp (Formula.neg ψ)) :=
        DerivationTree.temporal_necessitation _ h_bot_imp_neg
      have h_K : [] ⊢ (Formula.all_future (Formula.bot.imp (Formula.neg ψ))).imp
                       ((Formula.all_future Formula.bot).imp (Formula.all_future (Formula.neg ψ))) :=
        DerivationTree.axiom [] _ (Axiom.temp_k_dist Formula.bot (Formula.neg ψ))
      have h_G_imp : [] ⊢ (Formula.all_future Formula.bot).imp (Formula.all_future (Formula.neg ψ)) :=
        DerivationTree.modus_ponens [] _ _ h_K h_G_ef
      exact SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_G_imp) h_G_bot_in_M

  -- Now apply until_induction with χ = ⊥ to derive ¬(φ U ψ) ∈ M
  -- until_induction: G(ψ → χ) ∧ G((φ ∧ χ) → G(χ)) → ((φ U ψ) → χ)
  -- With χ = ⊥:
  --   G(ψ → ⊥) ∧ G((φ ∧ ⊥) → G(⊥)) → ((φ U ψ) → ⊥)
  --
  -- G(ψ → ⊥) = G(¬ψ) — we have this (h_G_neg_psi)
  -- G((φ ∧ ⊥) → G(⊥)) — provable (ex falso)

  -- Step 1: Prove ⊢ (φ ∧ ⊥) → G(⊥) (ex falso)
  -- (φ ∧ ⊥) → ⊥ by rce_imp (conjunction elimination right)
  -- then ⊥ → G(⊥) by ex falso (prop_s)
  -- Chain via prop_k: (A→B) → (B→C) → (A→C)
  have h_and_bot_imp_G_bot : [] ⊢ (Formula.and φ Formula.bot).imp (Formula.all_future Formula.bot) := by
    -- (φ ∧ ⊥) → ⊥ by rce_imp (conjunction elimination right)
    have h_rce : [] ⊢ (Formula.and φ Formula.bot).imp Formula.bot :=
      Bimodal.Theorems.Propositional.rce_imp φ Formula.bot
    -- ⊥ → G(⊥) by ex falso
    have h_efq : [] ⊢ Formula.bot.imp (Formula.all_future Formula.bot) :=
      Bimodal.Theorems.Propositional.efq_axiom (Formula.all_future Formula.bot)
    -- Build [φ ∧ ⊥] ⊢ G(⊥) by chaining
    have h_rce_w : [Formula.and φ Formula.bot] ⊢ (Formula.and φ Formula.bot).imp Formula.bot :=
      DerivationTree.weakening [] [Formula.and φ Formula.bot] _ h_rce (fun _ h => absurd h (List.not_mem_nil))
    have h_efq_w : [Formula.and φ Formula.bot] ⊢ Formula.bot.imp (Formula.all_future Formula.bot) :=
      DerivationTree.weakening [] [Formula.and φ Formula.bot] _ h_efq (fun _ h => absurd h (List.not_mem_nil))
    have h_assume : [Formula.and φ Formula.bot] ⊢ (Formula.and φ Formula.bot) :=
      DerivationTree.assumption _ _ (by simp)
    have d1 : [Formula.and φ Formula.bot] ⊢ Formula.bot :=
      DerivationTree.modus_ponens _ _ _ h_rce_w h_assume
    have d2 : [Formula.and φ Formula.bot] ⊢ Formula.all_future Formula.bot :=
      DerivationTree.modus_ponens _ _ _ h_efq_w d1
    exact deduction_theorem [] _ _ d2

  -- Step 2: G((φ ∧ ⊥) → G(⊥)) by necessitation
  have h_G_and_bot : [] ⊢ Formula.all_future ((Formula.and φ Formula.bot).imp (Formula.all_future Formula.bot)) :=
    DerivationTree.temporal_necessitation _ h_and_bot_imp_G_bot

  -- Step 3: Both G(¬ψ) and G((φ ∧ ⊥) → G(⊥)) are in M.
  -- Form their conjunction in M.
  have h_G_and_bot_in_M : Formula.all_future ((Formula.and φ Formula.bot).imp (Formula.all_future Formula.bot)) ∈ M :=
    theorem_in_mcs h_mcs h_G_and_bot

  -- Conjunction: a ∈ M ∧ b ∈ M → a.and b ∈ M (inline conjunction_intro)
  have h_conj_in_M : Formula.and
      (Formula.all_future (ψ.imp Formula.bot))
      (Formula.all_future ((Formula.and φ Formula.bot).imp (Formula.all_future Formula.bot))) ∈ M := by
    -- By negation completeness, either (a → ¬b) ∈ M or (a → ¬b).neg ∈ M
    -- where a.and b = (a.imp b.neg).neg
    let a := Formula.all_future (ψ.imp Formula.bot)
    let b := Formula.all_future ((Formula.and φ Formula.bot).imp (Formula.all_future Formula.bot))
    rcases SetMaximalConsistent.negation_complete h_mcs (a.imp b.neg) with h_imp | h_neg
    · -- (a → ¬b) ∈ M and a ∈ M gives ¬b ∈ M, contradicting b ∈ M
      have h_neg_b := SetMaximalConsistent.implication_property h_mcs h_imp h_G_neg_psi
      exact absurd h_G_and_bot_in_M (SetMaximalConsistent.neg_excludes h_mcs b h_neg_b)
    · exact h_neg

  -- Step 4: Apply until_induction axiom instance
  have h_uind : [] ⊢ (Formula.and
      (Formula.all_future (ψ.imp Formula.bot))
      (Formula.all_future ((Formula.and φ Formula.bot).imp (Formula.all_future Formula.bot)))
      |>.imp ((Formula.untl φ ψ).imp Formula.bot)) :=
    DerivationTree.axiom [] _ (Axiom.until_induction φ ψ Formula.bot)

  -- Step 5: Modus ponens: (φ U ψ) → ⊥ ∈ M
  have h_neg_U : (Formula.untl φ ψ).imp Formula.bot ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_uind) h_conj_in_M

  -- Step 6: (φ U ψ).imp ⊥ = ¬(φ U ψ) and (φ U ψ) ∈ M, contradiction
  exact set_consistent_not_both h_mcs.1 (Formula.untl φ ψ) h_U h_neg_U

/--
Since witness seed consistency: If `φ S ψ ∈ M` and M is MCS, then
`{ψ} ∪ h_content(M)` is consistent.

Symmetric to `until_witness_seed_consistent`, using `since_induction` and H instead of G.
-/
theorem since_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_S : Formula.snce φ ψ ∈ M) :
    SetConsistent (past_temporal_witness_seed M ψ) := by
  intro L hL_sub ⟨d⟩

  -- Extract H(¬ψ) ∈ M from the inconsistency of {ψ} ∪ h_content(M)
  have h_H_neg_psi : Formula.all_past (Formula.neg ψ) ∈ M := by
    by_cases h_psi_in : ψ ∈ L
    · let L_filt := L.filter (fun y => decide (y ≠ ψ))
      have h_perm := cons_filter_neq_perm h_psi_in
      have d_reord : DerivationTree (ψ :: L_filt) Formula.bot :=
        derivation_exchange d (fun x => (h_perm x).symm)
      have d_neg : L_filt ⊢ Formula.neg ψ :=
        deduction_theorem L_filt ψ Formula.bot d_reord
      have h_H_filt_in_M : ∀ chi ∈ L_filt, Formula.all_past chi ∈ M := by
        intro chi h_mem
        have h_and := List.mem_filter.mp h_mem
        have h_in_L := h_and.1
        have h_ne : chi ≠ ψ := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
        have h_in_seed := hL_sub chi h_in_L
        simp only [past_temporal_witness_seed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
        rcases h_in_seed with h_eq | h_hcontent
        · exact absurd h_eq h_ne
        · exact h_hcontent
      have d_H_neg : (Context.map Formula.all_past L_filt) ⊢ Formula.all_past (Formula.neg ψ) :=
        Bimodal.Theorems.generalized_past_k L_filt (Formula.neg ψ) d_neg
      have h_H_context_in_M : ∀ f ∈ Context.map Formula.all_past L_filt, f ∈ M := by
        intro f h_mem
        rw [Context.mem_map_iff] at h_mem
        rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
        rw [← h_eq]
        exact h_H_filt_in_M chi h_chi_in
      exact SetMaximalConsistent.closed_under_derivation h_mcs
        (Context.map Formula.all_past L_filt) h_H_context_in_M d_H_neg
    · have h_H_all_in_M : ∀ chi ∈ L, Formula.all_past chi ∈ M := by
        intro chi h_mem
        have h_in_seed := hL_sub chi h_mem
        simp only [past_temporal_witness_seed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
        rcases h_in_seed with h_eq | h_hcontent
        · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
        · exact h_hcontent
      have d_H_bot : (Context.map Formula.all_past L) ⊢ Formula.all_past Formula.bot :=
        Bimodal.Theorems.generalized_past_k L Formula.bot d
      have h_H_L_in_M : ∀ f ∈ Context.map Formula.all_past L, f ∈ M := by
        intro f h_mem
        rw [Context.mem_map_iff] at h_mem
        rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
        rw [← h_eq]
        exact h_H_all_in_M chi h_chi_in
      have h_H_bot_in_M : Formula.all_past Formula.bot ∈ M :=
        SetMaximalConsistent.closed_under_derivation h_mcs
          (Context.map Formula.all_past L) h_H_L_in_M d_H_bot
      have h_bot_imp_neg : [] ⊢ Formula.bot.imp (Formula.neg ψ) :=
        DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot ψ)
      have h_H_ef : [] ⊢ Formula.all_past (Formula.bot.imp (Formula.neg ψ)) :=
        Bimodal.Theorems.past_necessitation _ h_bot_imp_neg
      have h_K : [] ⊢ (Formula.all_past (Formula.bot.imp (Formula.neg ψ))).imp
                       ((Formula.all_past Formula.bot).imp (Formula.all_past (Formula.neg ψ))) :=
        Bimodal.Theorems.past_k_dist Formula.bot (Formula.neg ψ)
      have h_H_imp : [] ⊢ (Formula.all_past Formula.bot).imp (Formula.all_past (Formula.neg ψ)) :=
        DerivationTree.modus_ponens [] _ _ h_K h_H_ef
      exact SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_H_imp) h_H_bot_in_M

  -- Apply since_induction with χ = ⊥
  have h_and_bot_imp_H_bot : [] ⊢ (Formula.and φ Formula.bot).imp (Formula.all_past Formula.bot) := by
    have h_rce : [] ⊢ (Formula.and φ Formula.bot).imp Formula.bot :=
      Bimodal.Theorems.Propositional.rce_imp φ Formula.bot
    have h_efq : [] ⊢ Formula.bot.imp (Formula.all_past Formula.bot) :=
      Bimodal.Theorems.Propositional.efq_axiom (Formula.all_past Formula.bot)
    have h_rce_w : [Formula.and φ Formula.bot] ⊢ (Formula.and φ Formula.bot).imp Formula.bot :=
      DerivationTree.weakening [] [Formula.and φ Formula.bot] _ h_rce (fun _ h => absurd h (List.not_mem_nil))
    have h_efq_w : [Formula.and φ Formula.bot] ⊢ Formula.bot.imp (Formula.all_past Formula.bot) :=
      DerivationTree.weakening [] [Formula.and φ Formula.bot] _ h_efq (fun _ h => absurd h (List.not_mem_nil))
    have h_assume : [Formula.and φ Formula.bot] ⊢ (Formula.and φ Formula.bot) :=
      DerivationTree.assumption _ _ (by simp)
    have d1 : [Formula.and φ Formula.bot] ⊢ Formula.bot :=
      DerivationTree.modus_ponens _ _ _ h_rce_w h_assume
    have d2 : [Formula.and φ Formula.bot] ⊢ Formula.all_past Formula.bot :=
      DerivationTree.modus_ponens _ _ _ h_efq_w d1
    exact deduction_theorem [] _ _ d2

  have h_H_and_bot : [] ⊢ Formula.all_past ((Formula.and φ Formula.bot).imp (Formula.all_past Formula.bot)) :=
    Bimodal.Theorems.past_necessitation _ h_and_bot_imp_H_bot

  have h_H_and_bot_in_M : Formula.all_past ((Formula.and φ Formula.bot).imp (Formula.all_past Formula.bot)) ∈ M :=
    theorem_in_mcs h_mcs h_H_and_bot

  have h_conj_in_M : Formula.and
      (Formula.all_past (ψ.imp Formula.bot))
      (Formula.all_past ((Formula.and φ Formula.bot).imp (Formula.all_past Formula.bot))) ∈ M := by
    let a := Formula.all_past (ψ.imp Formula.bot)
    let b := Formula.all_past ((Formula.and φ Formula.bot).imp (Formula.all_past Formula.bot))
    rcases SetMaximalConsistent.negation_complete h_mcs (a.imp b.neg) with h_imp | h_neg
    · have h_neg_b := SetMaximalConsistent.implication_property h_mcs h_imp h_H_neg_psi
      exact absurd h_H_and_bot_in_M (SetMaximalConsistent.neg_excludes h_mcs b h_neg_b)
    · exact h_neg

  have h_sind : [] ⊢ (Formula.and
      (Formula.all_past (ψ.imp Formula.bot))
      (Formula.all_past ((Formula.and φ Formula.bot).imp (Formula.all_past Formula.bot)))
      |>.imp ((Formula.snce φ ψ).imp Formula.bot)) :=
    DerivationTree.axiom [] _ (Axiom.since_induction φ ψ Formula.bot)

  have h_neg_S : (Formula.snce φ ψ).imp Formula.bot ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_sind) h_conj_in_M

  -- (φ S ψ).imp ⊥ = ¬(φ S ψ) and (φ S ψ) ∈ M, contradiction
  exact set_consistent_not_both h_mcs.1 (Formula.snce φ ψ) h_S h_neg_S

/-!
## g_content/h_content Duality

These theorems establish that g_content ⊆ implies h_content reverse, and vice versa.
They use the axioms temp_a (φ → G(P(φ))) and its past dual (φ → H(F(φ))),
which are still valid with irreflexive semantics.
-/

/-- Past analog of axiom temp_a: ⊢ φ → H(F(φ)).
Derived from temp_a via temporal duality. -/
noncomputable def past_temp_a (psi : Formula) :
    [] ⊢ psi.imp psi.some_future.all_past := by
  have h_ta := DerivationTree.axiom [] _ (Axiom.temp_a psi.swap_temporal)
  have h_dual := DerivationTree.temporal_duality _ h_ta
  have h_eq : (psi.swap_temporal.imp psi.swap_temporal.some_past.all_future).swap_temporal
    = psi.imp psi.some_future.all_past := by
    simp [Formula.swap_temporal, Formula.neg, Formula.some_past, Formula.some_past,
          Formula.some_future, Formula.swap_temporal, Formula.swap_temporal_involution]
  rw [h_eq] at h_dual; exact h_dual

/-- If g_content(M) ⊆ M', then h_content(M') ⊆ M.
Uses temp_a: φ → G(P(φ)). -/
theorem g_content_subset_implies_h_content_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_GC : g_content M ⊆ M') :
    h_content M' ⊆ M := by
  intro phi h_H_phi_in_M'
  by_contra h_not_phi
  have h_neg_phi : Formula.neg phi ∈ M := by
    rcases SetMaximalConsistent.negation_complete h_mcs phi with h | h
    · exact absurd h h_not_phi
    · exact h
  have h_ta : [] ⊢ (Formula.neg phi).imp (Formula.all_future (Formula.neg phi).some_past) :=
    DerivationTree.axiom [] _ (Axiom.temp_a (Formula.neg phi))
  have h_G_P_neg : Formula.all_future (Formula.neg phi).some_past ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_ta) h_neg_phi
  have h_P_neg_M' : (Formula.neg phi).some_past ∈ M' := h_GC h_G_P_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := Bimodal.Theorems.Combinators.dni phi
  have h_H_dni : [] ⊢ (phi.imp phi.neg.neg).all_past :=
    Bimodal.Theorems.past_necessitation _ h_dni
  have h_pk : [] ⊢ (phi.imp phi.neg.neg).all_past.imp (phi.all_past.imp phi.neg.neg.all_past) :=
    Bimodal.Theorems.past_k_dist phi phi.neg.neg
  have h_H_imp : [] ⊢ phi.all_past.imp phi.neg.neg.all_past :=
    DerivationTree.modus_ponens [] _ _ h_pk h_H_dni
  have h_H_nn : phi.neg.neg.all_past ∈ M' :=
    SetMaximalConsistent.implication_property h_mcs' (theorem_in_mcs h_mcs' h_H_imp) h_H_phi_in_M'
  have h_eq : (Formula.neg phi).some_past = Formula.neg (phi.neg.neg.all_past) := rfl
  rw [h_eq] at h_P_neg_M'
  exact set_consistent_not_both h_mcs'.1 (phi.neg.neg.all_past) h_H_nn h_P_neg_M'

/-- If h_content(M) ⊆ M', then g_content(M') ⊆ M.
Uses past_temp_a: φ → H(F(φ)). -/
theorem h_content_subset_implies_g_content_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_HC : h_content M ⊆ M') :
    g_content M' ⊆ M := by
  intro phi h_G_phi_in_M'
  have h_G_phi : Formula.all_future phi ∈ M' := h_G_phi_in_M'
  by_contra h_not_phi
  have h_neg_phi : Formula.neg phi ∈ M := by
    rcases SetMaximalConsistent.negation_complete h_mcs phi with h | h
    · exact absurd h h_not_phi
    · exact h
  have h_pta : [] ⊢ (Formula.neg phi).imp (Formula.neg phi).some_future.all_past :=
    past_temp_a (Formula.neg phi)
  have h_H_F_neg : (Formula.neg phi).some_future.all_past ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_pta) h_neg_phi
  have h_F_neg_M' : (Formula.neg phi).some_future ∈ M' := h_HC h_H_F_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := Bimodal.Theorems.Combinators.dni phi
  have h_G_dni : [] ⊢ (phi.imp phi.neg.neg).all_future :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_fk : [] ⊢ (phi.imp phi.neg.neg).all_future.imp (phi.all_future.imp phi.neg.neg.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist phi phi.neg.neg)
  have h_G_imp : [] ⊢ phi.all_future.imp phi.neg.neg.all_future :=
    DerivationTree.modus_ponens [] _ _ h_fk h_G_dni
  have h_G_nn : phi.neg.neg.all_future ∈ M' :=
    SetMaximalConsistent.implication_property h_mcs' (theorem_in_mcs h_mcs' h_G_imp) h_G_phi
  have h_eq : (Formula.neg phi).some_future = Formula.neg (phi.neg.neg.all_future) := rfl
  rw [h_eq] at h_F_neg_M'
  exact set_consistent_not_both h_mcs'.1 (phi.neg.neg.all_future) h_G_nn h_F_neg_M'

end Bimodal.Metalogic.Bundle
