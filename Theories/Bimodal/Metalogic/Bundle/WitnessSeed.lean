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

## Design Note (Task 956)

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
## g_content/h_content Duality

These theorems establish that g_content ⊆ implies h_content reverse, and vice versa.
They use the axioms temp_a (φ → G(P(φ))) and its past dual (φ → H(F(φ))),
which are still valid with irreflexive semantics.
-/

/-- Past analog of axiom temp_a: ⊢ φ → H(F(φ)).
Derived from temp_a via temporal duality. -/
noncomputable def past_temp_a (psi : Formula) :
    [] ⊢ psi.imp psi.some_future.all_past := by
  have h_ta := DerivationTree.axiom [] _ (Axiom.temp_a psi.swap_past_future)
  have h_dual := DerivationTree.temporal_duality _ h_ta
  have h_eq : (psi.swap_past_future.imp psi.swap_past_future.sometime_past.all_future).swap_past_future
    = psi.imp psi.some_future.all_past := by
    simp [Formula.swap_temporal, Formula.neg, Formula.sometime_past, Formula.some_past,
          Formula.some_future, Formula.swap_past_future, Formula.swap_past_future_involution]
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
  have h_ta : [] ⊢ (Formula.neg phi).imp (Formula.all_future (Formula.neg phi).sometime_past) :=
    DerivationTree.axiom [] _ (Axiom.temp_a (Formula.neg phi))
  have h_G_P_neg : Formula.all_future (Formula.neg phi).sometime_past ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_ta) h_neg_phi
  have h_P_neg_M' : (Formula.neg phi).sometime_past ∈ M' := h_GC h_G_P_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := Bimodal.Theorems.Combinators.dni phi
  have h_H_dni : [] ⊢ (phi.imp phi.neg.neg).all_past :=
    Bimodal.Theorems.past_necessitation _ h_dni
  have h_pk : [] ⊢ (phi.imp phi.neg.neg).all_past.imp (phi.all_past.imp phi.neg.neg.all_past) :=
    Bimodal.Theorems.past_k_dist phi phi.neg.neg
  have h_H_imp : [] ⊢ phi.all_past.imp phi.neg.neg.all_past :=
    DerivationTree.modus_ponens [] _ _ h_pk h_H_dni
  have h_H_nn : phi.neg.neg.all_past ∈ M' :=
    SetMaximalConsistent.implication_property h_mcs' (theorem_in_mcs h_mcs' h_H_imp) h_H_phi_in_M'
  have h_eq : (Formula.neg phi).sometime_past = Formula.neg (phi.neg.neg.all_past) := rfl
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
