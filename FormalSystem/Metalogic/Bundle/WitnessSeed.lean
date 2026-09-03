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
import FormalSystem.Theorems.ModalDerived

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

- `allFuture_neg_of_gseed_inconsistent`: shared future-side core -- if F(psi) ∈ MCS M, then
  `ForwardTemporalWitnessSeed M psi` is consistent
- `forward_temporal_witness_seed_consistent` / `until_witness_seed_consistent`: both direct
  applications of the future-side core (`UntilWitnessSeed` was a byte-identical duplicate of
  `ForwardTemporalWitnessSeed` and has been removed)
- `allPast_neg_of_hseed_inconsistent`: past-side core, mirroring the future core; its
  `bot`-derivation branch is obtained from the future core's by `Formula.swapTemporal` +
  `DerivationTree.temporal_duality` + `Formula.swap_temporal_involution`
  (`allPast_bot_imp_neg_deriv`) rather than a second hand derivation
- `past_temporal_witness_seed_consistent`: application of the past-side core
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
  have h_sf_nn : Formula.someFuture psi.neg.neg ∈ M :=
    SetMaximalConsistent.mp_of_theorem h_mcs
      (FormalSystem.Theorems.TemporalDerived.someFuture_mono (Combinators.notNotIntro psi)) h_F
  exact set_consistent_not_both h_mcs.1 (Formula.someFuture psi.neg.neg) h_sf_nn h_G_neg

open FormalSystem.ProofSystem FormalSystem.Theorems in
/-- In an MCS, `somePast psi ∈ M` and `allPast (neg psi) ∈ M` is contradictory. -/
lemma some_past_all_past_neg_absurd {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) (psi : Formula)
    (h_P : Formula.somePast psi ∈ M)
    (h_H_neg : Formula.allPast (Formula.neg psi) ∈ M) : False := by
  have h_sp_nn : Formula.somePast psi.neg.neg ∈ M :=
    SetMaximalConsistent.mp_of_theorem h_mcs
      (FormalSystem.Theorems.TemporalDerived.somePast_mono (Combinators.notNotIntro psi)) h_P
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
  have h_F_mono : [] ⊢ (Formula.someFuture phi.neg.neg).imp (Formula.someFuture phi) :=
    FormalSystem.Theorems.TemporalDerived.someFuture_mono (Propositional.doubleNegation _)
  have h_contra : [] ⊢ (Formula.someFuture phi).neg.imp (Formula.someFuture phi.neg.neg).neg :=
    Propositional.contraposition h_F_mono
  exact SetMaximalConsistent.mp_of_theorem h_mcs
    (DerivationTree.lift (fc₁ := .Base) trivial h_contra) h_neg_F

open FormalSystem.ProofSystem FormalSystem.Theorems in
/-- In an MCS, `¬P(φ) ∈ M` implies `H(¬φ) ∈ M`.
    Past dual of `neg_some_future_to_all_future_neg`. -/
lemma neg_some_past_to_all_past_neg {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) (phi : Formula)
    (h_neg_P : Formula.neg (Formula.somePast phi) ∈ M) :
    Formula.allPast (Formula.neg phi) ∈ M := by
  have h_P_mono : [] ⊢ (Formula.somePast phi.neg.neg).imp (Formula.somePast phi) :=
    FormalSystem.Theorems.TemporalDerived.somePast_mono (Propositional.doubleNegation _)
  have h_contra : [] ⊢ (Formula.somePast phi).neg.imp (Formula.somePast phi.neg.neg).neg :=
    Propositional.contraposition h_P_mono
  exact SetMaximalConsistent.mp_of_theorem h_mcs
    (DerivationTree.lift (fc₁ := .Base) trivial h_contra) h_neg_P

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
Shared syntactic core: `⊢ G(⊥) → G(¬chi)` for arbitrary `chi`, via `prop_s` + temporal
necessitation + temporal K distribution + modus ponens. This is the one genuinely
future-specific, purely syntactic (context-free) step inside the forward witness-seed
consistency argument below; its past dual (`allPast_bot_imp_neg_deriv`) is obtained by
duality rather than a second hand derivation through `pastNecessitation`/`pastKDist`.
-/
private noncomputable def allFuture_bot_imp_neg_deriv {fc : FrameClass} (chi : Formula) :
    DerivationTree fc []
      ((Formula.allFuture Formula.bot).imp (Formula.allFuture (Formula.neg chi))) :=
  let h_bot_imp_neg : ⊢[fc] Formula.bot.imp (Formula.neg chi) :=
    DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot chi) (FrameClass.base_le fc)
  let h_G_ef : ⊢[fc] Formula.allFuture (Formula.bot.imp (Formula.neg chi)) :=
    DerivationTree.temporal_necessitation _ h_bot_imp_neg
  let h_K : ⊢[fc] (Formula.allFuture (Formula.bot.imp (Formula.neg chi))).imp
                   ((Formula.allFuture Formula.bot).imp (Formula.allFuture (Formula.neg chi))) :=
    DerivationTree.lift (FrameClass.base_le fc)
        (FormalSystem.Theorems.TemporalDerived.temporalKDistDerived Formula.bot (Formula.neg chi))
  DerivationTree.modus_ponens [] _ _ h_K h_G_ef

/--
Past dual of `allFuture_bot_imp_neg_deriv`: `⊢ H(⊥) → H(¬psi)`, obtained by
`Formula.swapTemporal` + `DerivationTree.temporal_duality` + `Formula.swap_temporal_involution`
-- the `past_tf_deriv` technique (`Algebraic/FlowFrame.lean`) -- applied to the future core
above at the swapped formula `psi.swapTemporal`, then unswapped back to `psi` by involution.
-/
private noncomputable def allPast_bot_imp_neg_deriv {fc : FrameClass} (psi : Formula) :
    DerivationTree fc []
      ((Formula.allPast Formula.bot).imp (Formula.allPast (Formula.neg psi))) := by
  have h_fut := allFuture_bot_imp_neg_deriv (fc := fc) (Formula.swapTemporal psi)
  have h_dual := DerivationTree.temporal_duality _ h_fut
  have h_eq : Formula.swapTemporal ((Formula.allFuture Formula.bot).imp
      (Formula.allFuture (Formula.neg (Formula.swapTemporal psi)))) =
      (Formula.allPast Formula.bot).imp (Formula.allPast (Formula.neg psi)) := by
    simp [Formula.swapTemporal, Formula.swap_temporal_involution, Formula.swap_temporal_neg]
  rw [h_eq] at h_dual
  exact h_dual

/--
Shared future-side core: `SetConsistent (fc := fc) (ForwardTemporalWitnessSeed M psi)`.
`forward_temporal_witness_seed_consistent` and `until_witness_seed_consistent` both reduce to
applications of this core (the latter because `UntilWitnessSeed` is byte-identical to
`ForwardTemporalWitnessSeed`).

**Proof Strategy** (irreflexive-compatible, no T-axiom needed):
Suppose `{psi} ∪ GContent(M)` is inconsistent. Then there exist `L ⊆ {psi} ∪ GContent(M)`
with `L ⊢ ⊥`.

Case 1 (psi ∈ L): By deduction, `L \ {psi} ⊢ ¬psi`. By generalized temporal K,
`G(L \ {psi}) ⊢ G(¬psi)`. Since `G chi ∈ M` for all `chi ∈ L \ {psi}`, by MCS closure
`G(¬psi) ∈ M`. But `F(psi) = ¬G(¬psi) ∈ M`. Contradiction.

Case 2 (psi ∉ L): All of L are in GContent(M), so `G chi ∈ M` for each `chi ∈ L`.
From `L ⊢ ⊥`, by generalized temporal K, `G(L) ⊢ G(⊥)`. Since all of `G(L)` are in M,
`G(⊥) ∈ M`. By `allFuture_bot_imp_neg_deriv`, `G(⊥) → G(¬psi)`, so `G(¬psi) ∈ M`. But
`F(psi) = ¬G(¬psi) ∈ M`. Contradiction.
-/
theorem allFuture_neg_of_gseed_inconsistent {fc : FrameClass} (M : Set Formula)
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
    -- G(⊥) → G(¬psi) by the shared syntactic core
    have h_G_imp : ⊢[fc] (Formula.allFuture Formula.bot).imp
        (Formula.allFuture (Formula.neg psi)) :=
      allFuture_bot_imp_neg_deriv (fc := fc) psi
    have h_G_neg_psi : Formula.allFuture (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.mp_of_theorem h_mcs h_G_imp h_G_bot_in_M
    -- Contradiction: F(psi) and G(neg psi) cannot both be in MCS
    exact some_future_all_future_neg_absurd h_mcs psi h_F h_G_neg_psi

/--
Forward temporal witness seed consistency: If F(psi) is in an MCS M, then
`{psi} ∪ GContent(M)` is consistent.

Application of the shared core `allFuture_neg_of_gseed_inconsistent`.
-/
theorem forward_temporal_witness_seed_consistent {fc : FrameClass} (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M)
    (psi : Formula) (h_F : Formula.someFuture psi ∈ M) :
    SetConsistent (fc := fc) (ForwardTemporalWitnessSeed M psi) :=
  allFuture_neg_of_gseed_inconsistent M h_mcs psi h_F

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
Past-side core, mirroring `allFuture_neg_of_gseed_inconsistent`: uses `generalizedPastK` for
the direction-native branch (Case 1) and the duality-derived `allPast_bot_imp_neg_deriv` for
the `bot`-derivation branch (Case 2), in place of a second hand derivation through
`pastNecessitation`/`pastKDist`.
-/
theorem allPast_neg_of_hseed_inconsistent {fc : FrameClass} (M : Set Formula)
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
    -- H(⊥) → H(¬psi) by the duality-derived core
    have h_H_imp : ⊢[fc] (Formula.allPast Formula.bot).imp (Formula.allPast (Formula.neg psi)) :=
      allPast_bot_imp_neg_deriv (fc := fc) psi
    have h_H_neg_psi : Formula.allPast (Formula.neg psi) ∈ M :=
      SetMaximalConsistent.mp_of_theorem h_mcs h_H_imp h_H_bot_in_M
    -- Contradiction: P(psi) and H(neg psi) cannot both be in MCS
    exact some_past_all_past_neg_absurd h_mcs psi h_P h_H_neg_psi

/--
Past temporal witness seed consistency: If P(psi) is in an MCS M, then
`{psi} ∪ HContent(M)` is consistent.

Application of the shared core `allPast_neg_of_hseed_inconsistent`, whose past-only
`bot`-derivation branch is itself obtained from the future core by
`Formula.swapTemporal` + `DerivationTree.temporal_duality` + `Formula.swap_temporal_involution`
(see `allPast_bot_imp_neg_deriv` above) rather than a second hand proof.
-/
theorem past_temporal_witness_seed_consistent {fc : FrameClass} (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M)
    (psi : Formula) (h_P : Formula.somePast psi ∈ M) :
    SetConsistent (fc := fc) (PastTemporalWitnessSeed M psi) :=
  allPast_neg_of_hseed_inconsistent M h_mcs psi h_P

/-!
## Until Temporal Witness Seed

When `φ U ψ ∈ M` (MCS), we need to eventually find a successor where ψ holds. The witness
seed used is `ForwardTemporalWitnessSeed M ψ` -- `UntilWitnessSeed` was a byte-identical
duplicate (`{ψ} ∪ GContent M`) and has been removed; `until_witness_seed_consistent` is now
a direct application of `allFuture_neg_of_gseed_inconsistent`.
-/

/--
Until witness seed consistency: If `φ U ψ ∈ M` and M is MCS, then
`ForwardTemporalWitnessSeed M ψ` (`= {ψ} ∪ GContent(M)`) is consistent.

By BX10 (`untilImpF`), `φ U ψ ∈ M` gives `F(ψ) ∈ M`; the rest is
`allFuture_neg_of_gseed_inconsistent`.
-/
theorem until_witness_seed_consistent (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula) (h_U : Formula.untl φ ψ ∈ M) :
    SetConsistent (fc := FrameClass.Base) (ForwardTemporalWitnessSeed M ψ) := by
  have h_F_psi : Formula.someFuture ψ ∈ M :=
    SetMaximalConsistent.mp_of_theorem h_mcs
      (FormalSystem.Theorems.TemporalDerived.untilImpF φ ψ) h_U
  exact allFuture_neg_of_gseed_inconsistent M h_mcs ψ h_F_psi

/-!
## GContent/HContent Duality

These theorems establish that GContent ⊆ implies HContent reverse, and vice versa.
They use the axioms `connect_future` (φ → G(P(φ))) and `connect_past` (φ → H(F(φ))),
which are still valid with irreflexive semantics.
-/

/-- If GContent(M) ⊆ M', then HContent(M') ⊆ M.
Uses `Axiom.connect_future`: φ → G(P(φ)). -/
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
    SetMaximalConsistent.mp_of_theorem h_mcs h_ta h_neg_phi
  have h_P_neg_M' : (Formula.neg phi).somePast ∈ M' := h_GC h_G_P_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := FormalSystem.Theorems.Combinators.notNotIntro phi
  have h_H_dni : [] ⊢ (phi.imp phi.neg.neg).allPast :=
    FormalSystem.Theorems.pastNecessitation _ h_dni
  have h_pk : [] ⊢ (phi.imp phi.neg.neg).allPast.imp (phi.allPast.imp phi.neg.neg.allPast) :=
    FormalSystem.Theorems.pastKDist phi phi.neg.neg
  have h_H_imp : [] ⊢ phi.allPast.imp phi.neg.neg.allPast :=
    DerivationTree.modus_ponens [] _ _ h_pk h_H_dni
  have h_H_nn : phi.neg.neg.allPast ∈ M' :=
    SetMaximalConsistent.mp_of_theorem h_mcs' h_H_imp h_H_phi_in_M'
  exact some_past_all_past_neg_absurd h_mcs' (Formula.neg phi) h_P_neg_M' h_H_nn

/-- If HContent(M) ⊆ M', then GContent(M') ⊆ M.
Uses `ModalDerived.pastTempA` (the `Axiom.connect_past` instance): φ → H(F(φ)). -/
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
    FormalSystem.Theorems.ModalDerived.pastTempA (Formula.neg phi)
  have h_H_F_neg : (Formula.neg phi).someFuture.allPast ∈ M :=
    SetMaximalConsistent.mp_of_theorem h_mcs h_pta h_neg_phi
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
    SetMaximalConsistent.mp_of_theorem h_mcs' h_G_imp h_G_phi
  exact some_future_all_future_neg_absurd h_mcs' (Formula.neg phi) h_F_neg_M' h_G_nn

end FormalSystem.Metalogic.Bundle
