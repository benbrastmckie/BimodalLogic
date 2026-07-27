/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.TemporalContent
import FormalSystem.Metalogic.Core.MaximalConsistent
import FormalSystem.Metalogic.Core.MCSProperties
import FormalSystem.Syntax.Formula
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Perpetuity
import FormalSystem.Theorems.TemporalDerived

/-!
# Witness Seed Definitions and Consistency

This module contains the temporal witness seed definitions and their consistency
proofs, used by CanonicalFrame.lean for temporal witness construction.

Also contains the GContent/HContent duality theorems (GContent ⊆ implies HContent
reverse, and vice versa).

## Key Definitions

- `ForwardTemporalWitnessSeed M psi`: `{psi} ∪ GContent(M)`
- `PastTemporalWitnessSeed M psi`: `{psi} ∪ HContent(M)`

## Key Theorems

- `forward_temporal_witness_seed_consistent`: If F(psi) ∈ MCS M, then the forward seed is consistent
- `past_temporal_witness_seed_consistent`: If P(psi) ∈ MCS M, then the past seed is consistent
- `g_content_subset_implies_h_content_reverse`: GContent(M) ⊆ M' implies HContent(M') ⊆ M
- `h_content_subset_implies_g_content_reverse`: HContent(M) ⊆ M' implies GContent(M') ⊆ M

## Design Note

These proofs work with irreflexive temporal semantics (G/H use strict `<`).
The seed consistency proofs do NOT use the T-axiom (`G phi → phi`). Instead,
the `psi ∉ L` case uses generalized temporal K to derive G(⊥) from L ⊢ ⊥,
then derives G(¬psi) which contradicts F(psi) ∈ M.
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.Metalogic.Core
open FormalSystem.ProofSystem

/-! ## Duality Helpers

Since `someFuture`/`somePast` are no longer definitionally `neg(allFuture/allPast(neg _))`,
we need helpers that derive contradictions between `someFuture psi ∈ M` and
`allFuture (neg psi) ∈ M` in an MCS. -/

open FormalSystem.ProofSystem FormalSystem.Theorems in
/-- In an MCS, `someFuture psi ∈ M` and `allFuture (neg psi) ∈ M` is contradictory. -/
lemma some_future_all_future_neg_absurd {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) (psi : Formula)
    (h_F : Formula.someFuture psi ∈ M)
    (h_G_neg : Formula.allFuture (Formula.neg psi) ∈ M) : False := by
  -- allFuture (neg psi) = (someFuture psi.neg.neg).neg
  -- From h_F and BX3 + DNI: someFuture psi.neg.neg ∈ M
  -- Contradiction with (someFuture psi.neg.neg).neg = allFuture (neg psi) ∈ M
  have h_dni : [] ⊢ psi.imp psi.neg.neg := Combinators.notNotIntro psi
  have h_G_dni : [] ⊢ (psi.imp psi.neg.neg).allFuture :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_bx3 : [] ⊢ (psi.imp psi.neg.neg).allFuture.imp
      ((Formula.untl psi Formula.top).imp (Formula.untl psi.neg.neg Formula.top)) :=
    DerivationTree.axiom [] _ (Axiom.right_mono_until psi psi.neg.neg Formula.top) trivial
  have h_impl : [] ⊢ (Formula.someFuture psi).imp (Formula.someFuture psi.neg.neg) :=
    DerivationTree.modus_ponens [] _ _ h_bx3 h_G_dni
  have h_sf_nn : Formula.someFuture psi.neg.neg ∈ M :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.lift (fc₁ := .Base) trivial h_impl)) h_F
  exact set_consistent_not_both h_mcs.1 (Formula.someFuture psi.neg.neg) h_sf_nn h_G_neg

open FormalSystem.ProofSystem FormalSystem.Theorems in
/-- In an MCS, `somePast psi ∈ M` and `allPast (neg psi) ∈ M` is contradictory. -/
lemma some_past_all_past_neg_absurd {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) (psi : Formula)
    (h_P : Formula.somePast psi ∈ M)
    (h_H_neg : Formula.allPast (Formula.neg psi) ∈ M) : False := by
  have h_dni : [] ⊢ psi.imp psi.neg.neg := Combinators.notNotIntro psi
  have h_H_dni : [] ⊢ (psi.imp psi.neg.neg).allPast :=
    pastNecessitation _ h_dni
  have h_bx3 : [] ⊢ (psi.imp psi.neg.neg).allPast.imp
      ((Formula.snce psi Formula.top).imp (Formula.snce psi.neg.neg Formula.top)) :=
    DerivationTree.axiom [] _ (Axiom.right_mono_since psi psi.neg.neg Formula.top) trivial
  have h_impl : [] ⊢ (Formula.somePast psi).imp (Formula.somePast psi.neg.neg) :=
    DerivationTree.modus_ponens [] _ _ h_bx3 h_H_dni
  have h_sp_nn : Formula.somePast psi.neg.neg ∈ M :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.lift (fc₁ := .Base) trivial h_impl)) h_P
  exact set_consistent_not_both h_mcs.1 (Formula.somePast psi.neg.neg) h_sp_nn h_H_neg

/-! ## Duality Conversions

These lemmas convert between `¬F(φ)` and `G(¬φ)` (and their past duals) in an MCS.
Since `someFuture`/`somePast` and `allFuture`/`allPast` are no longer structurally
dual, these conversions go through the proof system (BX3/BX3' + DNE/DNI). -/

open FormalSystem.ProofSystem FormalSystem.Theorems in
/-- In an MCS, `¬F(φ) ∈ M` implies `G(¬φ) ∈ M`.
    Proof: `¬P(φ) → ¬P(φ.neg.neg)` via contrapositive of BX3'+DNE, which equals `G(¬φ)`. -/
lemma neg_some_future_to_all_future_neg {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) (phi : Formula)
    (h_neg_F : Formula.neg (Formula.someFuture phi) ∈ M) :
    Formula.allFuture (Formula.neg phi) ∈ M := by
  -- Build derivation chain at Base level, then lift to fc
  have h_dne : [] ⊢ phi.neg.neg.imp phi := Propositional.doubleNegation _
  have h_nec : [] ⊢ (phi.neg.neg.imp phi).allFuture :=
    DerivationTree.temporal_necessitation _ h_dne
  have h_bx3 : [] ⊢ (phi.neg.neg.imp phi).allFuture.imp
      ((Formula.untl phi.neg.neg Formula.top).imp (Formula.untl phi Formula.top)) :=
    DerivationTree.axiom [] _ (Axiom.right_mono_until phi.neg.neg phi Formula.top) trivial
  have h_F_mono : [] ⊢ (Formula.someFuture phi.neg.neg).imp (Formula.someFuture phi) :=
    DerivationTree.modus_ponens [] _ _ h_bx3 h_nec
  have h_contra : [] ⊢ (Formula.someFuture phi).neg.imp (Formula.someFuture phi.neg.neg).neg :=
    Propositional.contraposition h_F_mono
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.lift (fc₁ := .Base) trivial h_contra)) h_neg_F

open FormalSystem.ProofSystem FormalSystem.Theorems in
/-- In an MCS, `¬P(φ) ∈ M` implies `H(¬φ) ∈ M`.
    Past dual of `neg_some_future_to_all_future_neg`. -/
lemma neg_some_past_to_all_past_neg {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) (phi : Formula)
    (h_neg_P : Formula.neg (Formula.somePast phi) ∈ M) :
    Formula.allPast (Formula.neg phi) ∈ M := by
  have h_dne : [] ⊢ phi.neg.neg.imp phi := Propositional.doubleNegation _
  have h_nec : [] ⊢ (phi.neg.neg.imp phi).allPast :=
    pastNecessitation _ h_dne
  have h_bx3 : [] ⊢ (phi.neg.neg.imp phi).allPast.imp
      ((Formula.snce phi.neg.neg Formula.top).imp (Formula.snce phi Formula.top)) :=
    DerivationTree.axiom [] _ (Axiom.right_mono_since phi.neg.neg phi Formula.top) trivial
  have h_P_mono : [] ⊢ (Formula.somePast phi.neg.neg).imp (Formula.somePast phi) :=
    DerivationTree.modus_ponens [] _ _ h_bx3 h_nec
  have h_contra : [] ⊢ (Formula.somePast phi).neg.imp (Formula.somePast phi.neg.neg).neg :=
    Propositional.contraposition h_P_mono
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.lift (fc₁ := .Base) trivial h_contra)) h_neg_P

/-!
## Forward Temporal Witness Seed
-/

/-- Forward witness seed: `{psi} ∪ GContent(M)`. -/
def ForwardTemporalWitnessSeed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ GContent M

/-- psi is in its own ForwardTemporalWitnessSeed. -/
lemma psi_mem_forward_temporal_witness_seed (M : Set Formula) (psi : Formula) :
    psi ∈ ForwardTemporalWitnessSeed M psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/-- GContent is a subset of ForwardTemporalWitnessSeed. -/
lemma g_content_subset_forward_temporal_witness_seed (M : Set Formula) (psi : Formula) :
    GContent M ⊆ ForwardTemporalWitnessSeed M psi :=
  Set.subset_union_right

/--
Forward temporal witness seed consistency: If F(psi) is in an MCS M, then
`{psi} ∪ GContent(M)` is consistent.

**Proof Strategy** (irreflexive-compatible, no T-axiom needed):
Suppose `{psi} ∪ GContent(M)` is inconsistent. Then there exist `L ⊆ {psi} ∪ GContent(M)`
with `L ⊢ ⊥`.

Case 1 (psi ∈ L): By deduction, `L \ {psi} ⊢ ¬psi`. By generalized temporal K,
`G(L \ {psi}) ⊢ G(¬psi)`. Since `G chi ∈ M` for all `chi ∈ L \ {psi}`, by MCS closure
`G(¬psi) ∈ M`. But `F(psi) = ¬G(¬psi) ∈ M`. Contradiction.

Case 2 (psi ∉ L): All of L are in GContent(M), so `G chi ∈ M` for each `chi ∈ L`.
From `L ⊢ ⊥`, by generalized temporal K, `G(L) ⊢ G(⊥)`. Since all of `G(L)` are in M,
`G(⊥) ∈ M`. From `⊢ ⊥ → ¬psi`, by temporal necessitation `⊢ G(⊥ → ¬psi)`, by temporal K
distribution `⊢ G(⊥) → G(¬psi)`, so `G(¬psi) ∈ M`. But `F(psi) = ¬G(¬psi) ∈ M`.
Contradiction.
-/
theorem forward_temporal_witness_seed_consistent {fc : FrameClass} (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M)
    (psi : Formula) (h_F : Formula.someFuture psi ∈ M) :
    SetConsistent (fc := fc) (ForwardTemporalWitnessSeed M psi) := by
  intro L hL_sub ⟨d⟩
  by_cases h_psi_in : psi ∈ L
  · -- Case: psi ∈ L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree fc (psi :: L_filt) Formula.bot :=
      derivationExchange d (fun x => (h_perm x).symm)
    have d_neg : L_filt ⊢[fc] Formula.neg psi :=
      deductionTheorem L_filt psi Formula.bot d_reord
    -- Get G chi ∈ M for each chi ∈ L_filt from GContent
    have h_G_filt_in_M : ∀ chi ∈ L_filt, Formula.allFuture chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [ForwardTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq h_ne
      · exact h_gcontent
    -- Apply generalized temporal K (G distributes over derivation)
    have d_G_neg : (Context.map Formula.allFuture L_filt) ⊢[fc] Formula.allFuture
        (Formula.neg psi) :=
      FormalSystem.Theorems.generalizedTemporalK L_filt (Formula.neg psi) d_neg
    -- All formulas in G(L_filt) are in M
    have h_G_context_in_M : ∀ phi ∈ Context.map Formula.allFuture L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_G_filt_in_M chi h_chi_in
    -- By MCS closure under derivation, G(neg psi) ∈ M
    have h_G_neg_in_M : Formula.allFuture (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.closed_under_derivation h_mcs (Context.map Formula.allFuture L_filt)
        h_G_context_in_M d_G_neg
    -- Contradiction: F(psi) and G(neg psi) cannot both be in MCS
    exact some_future_all_future_neg_absurd h_mcs psi h_F h_G_neg_in_M
  · -- Case: psi ∉ L, so L ⊆ GContent M
    -- All elements of L are in GContent(M), meaning G chi ∈ M for each chi
    have h_G_all_in_M : ∀ chi ∈ L, Formula.allFuture chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [ForwardTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · exact h_gcontent
    -- From L ⊢ ⊥, by generalized temporal K: G(L) ⊢ G(⊥)
    have d_G_bot : (Context.map Formula.allFuture L) ⊢[fc] Formula.allFuture Formula.bot :=
      FormalSystem.Theorems.generalizedTemporalK L Formula.bot d
    -- All formulas in G(L) are in M
    have h_G_L_in_M : ∀ phi ∈ Context.map Formula.allFuture L, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_G_all_in_M chi h_chi_in
    -- So G(⊥) ∈ M
    have h_G_bot_in_M : Formula.allFuture Formula.bot ∈ M :=
      SetMaximalConsistent.closed_under_derivation h_mcs (Context.map Formula.allFuture L)
        h_G_L_in_M d_G_bot
    -- ⊢ ⊥ → ¬psi by prop_s (weakening): ⊢ ⊥ → (psi → ⊥) = ⊢ ⊥ → ¬psi
    have h_bot_imp_neg : ⊢[fc] Formula.bot.imp (Formula.neg psi) :=
      DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot psi) (FrameClass.base_le fc)
    -- By temporal necessitation: ⊢ G(⊥ → ¬psi)
    have h_G_ef : ⊢[fc] Formula.allFuture (Formula.bot.imp (Formula.neg psi)) :=
      DerivationTree.temporal_necessitation _ h_bot_imp_neg
    -- By temporal K distribution: ⊢ G(⊥ → ¬psi) → (G(⊥) → G(¬psi))
    have h_K : ⊢[fc] (Formula.allFuture (Formula.bot.imp (Formula.neg psi))).imp
                     ((Formula.allFuture Formula.bot).imp
                         (Formula.allFuture (Formula.neg psi))) :=
      DerivationTree.lift (FrameClass.base_le fc)
          (FormalSystem.Theorems.TemporalDerived.temporalKDistDerived Formula.bot (Formula.neg psi))
    -- Modus ponens twice: G(¬psi) ∈ M
    have h_G_imp : ⊢[fc] (Formula.allFuture Formula.bot).imp
        (Formula.allFuture (Formula.neg psi)) :=
      DerivationTree.modus_ponens [] _ _ h_K h_G_ef
    have h_G_neg_psi : Formula.allFuture (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_G_imp) h_G_bot_in_M
    -- Contradiction: F(psi) and G(neg psi) cannot both be in MCS
    exact some_future_all_future_neg_absurd h_mcs psi h_F h_G_neg_psi

/-!
## Past Temporal Witness Seed
-/

/-- Past witness seed: `{psi} ∪ HContent(M)`. -/
def PastTemporalWitnessSeed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ HContent M

/-- psi is in its own PastTemporalWitnessSeed. -/
lemma psi_mem_past_temporal_witness_seed (M : Set Formula) (psi : Formula) :
    psi ∈ PastTemporalWitnessSeed M psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/-- HContent is a subset of PastTemporalWitnessSeed. -/
lemma h_content_subset_past_temporal_witness_seed (M : Set Formula) (psi : Formula) :
    HContent M ⊆ PastTemporalWitnessSeed M psi :=
  Set.subset_union_right

/--
Past temporal witness seed consistency: If P(psi) is in an MCS M, then
`{psi} ∪ HContent(M)` is consistent.

Symmetric to `forward_temporal_witness_seed_consistent`, using H and P instead of G and F.
-/
theorem past_temporal_witness_seed_consistent {fc : FrameClass} (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M)
    (psi : Formula) (h_P : Formula.somePast psi ∈ M) :
    SetConsistent (fc := fc) (PastTemporalWitnessSeed M psi) := by
  intro L hL_sub ⟨d⟩
  by_cases h_psi_in : psi ∈ L
  · -- Case: psi ∈ L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree fc (psi :: L_filt) Formula.bot :=
      derivationExchange d (fun x => (h_perm x).symm)
    have d_neg : L_filt ⊢[fc] Formula.neg psi :=
      deductionTheorem L_filt psi Formula.bot d_reord
    -- Get H chi ∈ M for each chi ∈ L_filt from HContent
    have h_H_filt_in_M : ∀ chi ∈ L_filt, Formula.allPast chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [PastTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hcontent
      · exact absurd h_eq h_ne
      · exact h_hcontent
    -- Apply generalized past K (H distributes over derivation)
    have d_H_neg : (Context.map Formula.allPast L_filt) ⊢[fc] Formula.allPast (Formula.neg psi) :=
      FormalSystem.Theorems.generalizedPastK L_filt (Formula.neg psi) d_neg
    -- All formulas in H(L_filt) are in M
    have h_H_context_in_M : ∀ phi ∈ Context.map Formula.allPast L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_H_filt_in_M chi h_chi_in
    -- By MCS closure under derivation, H(neg psi) ∈ M
    have h_H_neg_in_M : Formula.allPast (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.closed_under_derivation h_mcs (Context.map Formula.allPast L_filt)
        h_H_context_in_M d_H_neg
    -- Contradiction: P(psi) and H(neg psi) cannot both be in MCS
    exact some_past_all_past_neg_absurd h_mcs psi h_P h_H_neg_in_M
  · -- Case: psi ∉ L, so L ⊆ HContent M
    have h_H_all_in_M : ∀ chi ∈ L, Formula.allPast chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [PastTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · exact h_hcontent
    -- From L ⊢ ⊥, by generalized past K: H(L) ⊢ H(⊥)
    have d_H_bot : (Context.map Formula.allPast L) ⊢[fc] Formula.allPast Formula.bot :=
      FormalSystem.Theorems.generalizedPastK L Formula.bot d
    -- All formulas in H(L) are in M
    have h_H_L_in_M : ∀ phi ∈ Context.map Formula.allPast L, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_H_all_in_M chi h_chi_in
    -- So H(⊥) ∈ M
    have h_H_bot_in_M : Formula.allPast Formula.bot ∈ M :=
      SetMaximalConsistent.closed_under_derivation h_mcs (Context.map Formula.allPast L)
        h_H_L_in_M d_H_bot
    -- ⊢ ⊥ → ¬psi by prop_s
    have h_bot_imp_neg : ⊢[fc] Formula.bot.imp (Formula.neg psi) :=
      DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot psi) (FrameClass.base_le fc)
    -- By past necessitation: ⊢ H(⊥ → ¬psi)
    have h_H_ef : ⊢[fc] Formula.allPast (Formula.bot.imp (Formula.neg psi)) :=
      FormalSystem.Theorems.pastNecessitation _ h_bot_imp_neg
    -- By past K distribution: ⊢ H(⊥ → ¬psi) → (H(⊥) → H(¬psi))
    have h_K : ⊢[fc] (Formula.allPast (Formula.bot.imp (Formula.neg psi))).imp
                     ((Formula.allPast Formula.bot).imp (Formula.allPast (Formula.neg psi))) :=
      FormalSystem.Theorems.pastKDist Formula.bot (Formula.neg psi)
    -- Modus ponens twice: H(¬psi) ∈ M
    have h_H_imp : ⊢[fc] (Formula.allPast Formula.bot).imp (Formula.allPast (Formula.neg psi)) :=
      DerivationTree.modus_ponens [] _ _ h_K h_H_ef
    have h_H_neg_psi : Formula.allPast (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_H_imp) h_H_bot_in_M
    -- Contradiction: P(psi) and H(neg psi) cannot both be in MCS
    exact some_past_all_past_neg_absurd h_mcs psi h_P h_H_neg_psi

/-!
## Until Temporal Witness Seed

When `φ U ψ ∈ M` (MCS), we need to eventually find a successor where ψ holds.
The until witness seed `{ψ} ∪ GContent(M)` is consistent, proven using the
`until_induction` axiom with `χ = ⊥`.
-/

/-- Until witness seed: `{ψ} ∪ GContent(M)`. -/
def UntilWitnessSeed (M : Set Formula) (ψ : Formula) : Set Formula :=
  {ψ} ∪ GContent M

/-- ψ is in its own UntilWitnessSeed. -/
lemma psi_mem_until_witness_seed (M : Set Formula) (ψ : Formula) :
    ψ ∈ UntilWitnessSeed M ψ :=
  Set.mem_union_left _ (Set.mem_singleton ψ)

/-- GContent is a subset of UntilWitnessSeed. -/
lemma g_content_subset_until_witness_seed (M : Set Formula) (ψ : Formula) :
    GContent M ⊆ UntilWitnessSeed M ψ :=
  Set.subset_union_right

/--
Until witness seed consistency: If `φ U ψ ∈ M` and M is MCS, then
`{ψ} ∪ GContent(M)` is consistent.

**Proof Strategy**:
Suppose `{ψ} ∪ GContent(M)` is inconsistent. Then `G(¬ψ) ∈ M` (by the same
argument as forward_temporal_witness_seed_consistent).

Now apply `until_induction` with `χ = ⊥`:
  `G(ψ → ⊥) ∧ G((φ ∧ ⊥) → G(⊥)) → ((φ U ψ) → ⊥)`

- `G(ψ → ⊥) = G(¬ψ)` — we have this.
- `G((φ ∧ ⊥) → G(⊥))` — provable since `(φ ∧ ⊥) → G(⊥)` is provable (ex falso).

Therefore `(φ U ψ) → ⊥ ∈ M`, i.e., `¬(φ U ψ) ∈ M`, contradicting `φ U ψ ∈ M`.
-/
theorem until_witness_seed_consistent (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula) (h_U : Formula.untl ψ φ ∈ M) :
    SetConsistent (fc := FrameClass.Base) (UntilWitnessSeed M ψ) := by
  intro L hL_sub ⟨d⟩
  -- Extract G(¬ψ) ∈ M from the inconsistency of {ψ} ∪ GContent(M)
  -- (Same argument as forward_temporal_witness_seed_consistent)
  have h_G_neg_psi : Formula.allFuture (Formula.neg ψ) ∈ M := by
    by_cases h_psi_in : ψ ∈ L
    · -- Case: ψ ∈ L — derive G(¬ψ) via generalized temporal K
      let L_filt := L.filter (fun y => decide (y ≠ ψ))
      have h_perm := cons_filter_neq_perm h_psi_in
      have d_reord : DerivationTree FrameClass.Base (ψ :: L_filt) Formula.bot :=
        derivationExchange d (fun x => (h_perm x).symm)
      have d_neg : L_filt ⊢ Formula.neg ψ :=
        deductionTheorem L_filt ψ Formula.bot d_reord
      have h_G_filt_in_M : ∀ chi ∈ L_filt, Formula.allFuture chi ∈ M := by
        intro chi h_mem
        have h_and := List.mem_filter.mp h_mem
        have h_in_L := h_and.1
        have h_ne : chi ≠ ψ := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
        have h_in_seed := hL_sub chi h_in_L
        simp only [UntilWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
        rcases h_in_seed with h_eq | h_gcontent
        · exact absurd h_eq h_ne
        · exact h_gcontent
      have d_G_neg : (Context.map Formula.allFuture L_filt) ⊢ Formula.allFuture (Formula.neg ψ) :=
        FormalSystem.Theorems.generalizedTemporalK L_filt (Formula.neg ψ) d_neg
      have h_G_context_in_M : ∀ f ∈ Context.map Formula.allFuture L_filt, f ∈ M := by
        intro f h_mem
        rw [Context.mem_map_iff] at h_mem
        rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
        rw [← h_eq]
        exact h_G_filt_in_M chi h_chi_in
      exact SetMaximalConsistent.closed_under_derivation h_mcs
        (Context.map Formula.allFuture L_filt) h_G_context_in_M d_G_neg
    · -- Case: ψ ∉ L — all of L ⊆ GContent(M), derive G(⊥) then G(¬ψ)
      have h_G_all_in_M : ∀ chi ∈ L, Formula.allFuture chi ∈ M := by
        intro chi h_mem
        have h_in_seed := hL_sub chi h_mem
        simp only [UntilWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
        rcases h_in_seed with h_eq | h_gcontent
        · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
        · exact h_gcontent
      have d_G_bot : (Context.map Formula.allFuture L) ⊢ Formula.allFuture Formula.bot :=
        FormalSystem.Theorems.generalizedTemporalK L Formula.bot d
      have h_G_L_in_M : ∀ f ∈ Context.map Formula.allFuture L, f ∈ M := by
        intro f h_mem
        rw [Context.mem_map_iff] at h_mem
        rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
        rw [← h_eq]
        exact h_G_all_in_M chi h_chi_in
      have h_G_bot_in_M : Formula.allFuture Formula.bot ∈ M :=
        SetMaximalConsistent.closed_under_derivation h_mcs
          (Context.map Formula.allFuture L) h_G_L_in_M d_G_bot
      have h_bot_imp_neg : [] ⊢ Formula.bot.imp (Formula.neg ψ) :=
        DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot ψ) trivial
      have h_G_ef : [] ⊢ Formula.allFuture (Formula.bot.imp (Formula.neg ψ)) :=
        DerivationTree.temporal_necessitation _ h_bot_imp_neg
      have h_K : [] ⊢ (Formula.allFuture (Formula.bot.imp (Formula.neg ψ))).imp
                       ((Formula.allFuture Formula.bot).imp
                           (Formula.allFuture (Formula.neg ψ))) :=
        FormalSystem.Theorems.TemporalDerived.temporalKDistDerived Formula.bot (Formula.neg ψ)
      have h_G_imp : [] ⊢ (Formula.allFuture Formula.bot).imp
          (Formula.allFuture (Formula.neg ψ)) :=
        DerivationTree.modus_ponens [] _ _ h_K h_G_ef
      exact SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_G_imp) h_G_bot_in_M
  -- BX10 contradiction: (φ U ψ) → F(ψ) by BX10, and F(ψ) = ¬G(¬ψ), contradicting G(¬ψ) ∈ M
  have h_F_psi : ψ.someFuture ∈ M :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (FormalSystem.Theorems.TemporalDerived.untilImpF φ ψ)) h_U
  exact some_future_all_future_neg_absurd h_mcs ψ h_F_psi h_G_neg_psi

/--
Since witness seed consistency: If `φ S ψ ∈ M` and M is MCS, then
`{ψ} ∪ HContent(M)` is consistent.

Symmetric to `until_witness_seed_consistent`, using BX10' (sinceImpP) and H instead of G.
-/
theorem since_witness_seed_consistent (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula) (h_S : Formula.snce ψ φ ∈ M) :
    SetConsistent (fc := FrameClass.Base) (PastTemporalWitnessSeed M ψ) := by
  intro L hL_sub ⟨d⟩
  -- Extract H(¬ψ) ∈ M from the inconsistency of {ψ} ∪ HContent(M)
  have h_H_neg_psi : Formula.allPast (Formula.neg ψ) ∈ M := by
    by_cases h_psi_in : ψ ∈ L
    · let L_filt := L.filter (fun y => decide (y ≠ ψ))
      have h_perm := cons_filter_neq_perm h_psi_in
      have d_reord : DerivationTree FrameClass.Base (ψ :: L_filt) Formula.bot :=
        derivationExchange d (fun x => (h_perm x).symm)
      have d_neg : L_filt ⊢ Formula.neg ψ :=
        deductionTheorem L_filt ψ Formula.bot d_reord
      have h_H_filt_in_M : ∀ chi ∈ L_filt, Formula.allPast chi ∈ M := by
        intro chi h_mem
        have h_and := List.mem_filter.mp h_mem
        have h_in_L := h_and.1
        have h_ne : chi ≠ ψ := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
        have h_in_seed := hL_sub chi h_in_L
        simp only [PastTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
        rcases h_in_seed with h_eq | h_hcontent
        · exact absurd h_eq h_ne
        · exact h_hcontent
      have d_H_neg : (Context.map Formula.allPast L_filt) ⊢ Formula.allPast (Formula.neg ψ) :=
        FormalSystem.Theorems.generalizedPastK L_filt (Formula.neg ψ) d_neg
      have h_H_context_in_M : ∀ f ∈ Context.map Formula.allPast L_filt, f ∈ M := by
        intro f h_mem
        rw [Context.mem_map_iff] at h_mem
        rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
        rw [← h_eq]
        exact h_H_filt_in_M chi h_chi_in
      exact SetMaximalConsistent.closed_under_derivation h_mcs
        (Context.map Formula.allPast L_filt) h_H_context_in_M d_H_neg
    · have h_H_all_in_M : ∀ chi ∈ L, Formula.allPast chi ∈ M := by
        intro chi h_mem
        have h_in_seed := hL_sub chi h_mem
        simp only [PastTemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
        rcases h_in_seed with h_eq | h_hcontent
        · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
        · exact h_hcontent
      have d_H_bot : (Context.map Formula.allPast L) ⊢ Formula.allPast Formula.bot :=
        FormalSystem.Theorems.generalizedPastK L Formula.bot d
      have h_H_L_in_M : ∀ f ∈ Context.map Formula.allPast L, f ∈ M := by
        intro f h_mem
        rw [Context.mem_map_iff] at h_mem
        rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
        rw [← h_eq]
        exact h_H_all_in_M chi h_chi_in
      have h_H_bot_in_M : Formula.allPast Formula.bot ∈ M :=
        SetMaximalConsistent.closed_under_derivation h_mcs
          (Context.map Formula.allPast L) h_H_L_in_M d_H_bot
      have h_bot_imp_neg : [] ⊢ Formula.bot.imp (Formula.neg ψ) :=
        DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot ψ) trivial
      have h_H_ef : [] ⊢ Formula.allPast (Formula.bot.imp (Formula.neg ψ)) :=
        FormalSystem.Theorems.pastNecessitation _ h_bot_imp_neg
      have h_K : [] ⊢ (Formula.allPast (Formula.bot.imp (Formula.neg ψ))).imp
                       ((Formula.allPast Formula.bot).imp (Formula.allPast (Formula.neg ψ))) :=
        FormalSystem.Theorems.pastKDist Formula.bot (Formula.neg ψ)
      have h_H_imp : [] ⊢ (Formula.allPast Formula.bot).imp (Formula.allPast (Formula.neg ψ)) :=
        DerivationTree.modus_ponens [] _ _ h_K h_H_ef
      exact SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_H_imp) h_H_bot_in_M
  -- BX10' contradiction: (φ S ψ) → P(ψ) by BX10', and P(ψ) = ¬H(¬ψ), contradicting H(¬ψ) ∈ M
  have h_P_psi : ψ.somePast ∈ M :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (FormalSystem.Theorems.TemporalDerived.sinceImpP φ ψ)) h_S
  exact some_past_all_past_neg_absurd h_mcs ψ h_P_psi h_H_neg_psi

/-!
## GContent/HContent Duality

These theorems establish that GContent ⊆ implies HContent reverse, and vice versa.
They use the axioms temp_a (φ → G(P(φ))) and its past dual (φ → H(F(φ))),
which are still valid with irreflexive semantics.
-/

/-- Past analog of axiom temp_a: ⊢ φ → H(F(φ)).
Derived from temp_a via temporal duality. -/
noncomputable def pastTempA (psi : Formula) :
    [] ⊢ psi.imp psi.someFuture.allPast :=
  DerivationTree.axiom [] _ (Axiom.connect_past psi) trivial

/-- If GContent(M) ⊆ M', then HContent(M') ⊆ M.
Uses temp_a: φ → G(P(φ)). -/
theorem g_content_subset_implies_h_content_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
        (h_mcs' : SetMaximalConsistent (fc := FrameClass.Base) M')
    (h_GC : GContent M ⊆ M') :
    HContent M' ⊆ M := by
  intro phi h_H_phi_in_M'
  by_contra h_not_phi
  have h_neg_phi : Formula.neg phi ∈ M := by
    rcases SetMaximalConsistent.negation_complete h_mcs phi with h | h
    · exact absurd h h_not_phi
    · exact h
  have h_ta : [] ⊢ (Formula.neg phi).imp (Formula.allFuture (Formula.neg phi).somePast) :=
    DerivationTree.axiom [] _ (Axiom.connect_future (Formula.neg phi)) trivial
  have h_G_P_neg : Formula.allFuture (Formula.neg phi).somePast ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_ta) h_neg_phi
  have h_P_neg_M' : (Formula.neg phi).somePast ∈ M' := h_GC h_G_P_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := FormalSystem.Theorems.Combinators.notNotIntro phi
  have h_H_dni : [] ⊢ (phi.imp phi.neg.neg).allPast :=
    FormalSystem.Theorems.pastNecessitation _ h_dni
  have h_pk : [] ⊢ (phi.imp phi.neg.neg).allPast.imp (phi.allPast.imp phi.neg.neg.allPast) :=
    FormalSystem.Theorems.pastKDist phi phi.neg.neg
  have h_H_imp : [] ⊢ phi.allPast.imp phi.neg.neg.allPast :=
    DerivationTree.modus_ponens [] _ _ h_pk h_H_dni
  have h_H_nn : phi.neg.neg.allPast ∈ M' :=
    SetMaximalConsistent.implication_property h_mcs' (theorem_in_mcs h_mcs' h_H_imp) h_H_phi_in_M'
  exact some_past_all_past_neg_absurd h_mcs' (Formula.neg phi) h_P_neg_M' h_H_nn

/-- If HContent(M) ⊆ M', then GContent(M') ⊆ M.
Uses pastTempA: φ → H(F(φ)). -/
theorem h_content_subset_implies_g_content_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
        (h_mcs' : SetMaximalConsistent (fc := FrameClass.Base) M')
    (h_HC : HContent M ⊆ M') :
    GContent M' ⊆ M := by
  intro phi h_G_phi_in_M'
  have h_G_phi : Formula.allFuture phi ∈ M' := h_G_phi_in_M'
  by_contra h_not_phi
  have h_neg_phi : Formula.neg phi ∈ M := by
    rcases SetMaximalConsistent.negation_complete h_mcs phi with h | h
    · exact absurd h h_not_phi
    · exact h
  have h_pta : [] ⊢ (Formula.neg phi).imp (Formula.neg phi).someFuture.allPast :=
    pastTempA (Formula.neg phi)
  have h_H_F_neg : (Formula.neg phi).someFuture.allPast ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_pta) h_neg_phi
  have h_F_neg_M' : (Formula.neg phi).someFuture ∈ M' := h_HC h_H_F_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := FormalSystem.Theorems.Combinators.notNotIntro phi
  have h_G_dni : [] ⊢ (phi.imp phi.neg.neg).allFuture :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_fk : [] ⊢ (phi.imp phi.neg.neg).allFuture.imp
      (phi.allFuture.imp phi.neg.neg.allFuture) :=
    FormalSystem.Theorems.Perpetuity.futureKDist phi phi.neg.neg
  have h_G_imp : [] ⊢ phi.allFuture.imp phi.neg.neg.allFuture :=
    DerivationTree.modus_ponens [] _ _ h_fk h_G_dni
  have h_G_nn : phi.neg.neg.allFuture ∈ M' :=
    SetMaximalConsistent.implication_property h_mcs' (theorem_in_mcs h_mcs' h_G_imp) h_G_phi
  exact some_future_all_future_neg_absurd h_mcs' (Formula.neg phi) h_F_neg_M' h_G_nn

end FormalSystem.Metalogic.Bundle
