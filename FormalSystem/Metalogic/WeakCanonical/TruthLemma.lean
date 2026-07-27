/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.ReflexiveCanonical
import FormalSystem.Metalogic.Bundle.WitnessSeed
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.Combinators
import FormalSystem.Syntax.Context

/-!
# MCS Truth Facts for the Reflexive Canonical Model

MCS-membership lemmas for the reflexive canonical model of the Doets/Reynolds
completeness construction: bot exclusion plus G/H forward and backward
transfer along the temporal accessibility relations.

## Architecture

- **tempR_fwd** (based on g_content): temporal future accessibility
- **tempR_bwd** (based on h_content): temporal past accessibility
- Backward proofs use `set_lindenbaum`: show seed consistent, extend to MCS, derive contradiction

## Status

All declarations in this file are sorry-free:
- bot_not_in_mcs
- G forward, G backward (2 lemmas) — uses g_content_closed_derivation
- H forward, H backward (2 lemmas) — uses h_content_closed_derivation

## Archival note

The dead truth-lemma cluster formerly in this file (`reflCanTruth`,
`atom_truth_iff`, `bot_truth_false`, `imp_truth_iff`, `imp_mcs_iff`,
`box_forward_mcs`, `box_backward_mcs`, `until_forward_mcs`,
`until_backward_mcs`, `since_forward_mcs`, `since_backward_mcs`,
`truth_lemma` — 12 declarations, 6 documented sorries, zero external
consumers) was archived to
`Boneyard/SorriedDeclExcisions/WeakTruthLemmaCluster.lean`. The parametric
truth lemma (ParametricTruthLemma.lean) is the live truth-lemma path,
handling Until/Since via BFMCS coherence.
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems

/-! ## Bot exclusion: Proved (sorry-free) -/

theorem bot_not_in_mcs (x : ReflCanDomain) : Formula.bot ∉ x.val := by
  have h_mcs := x.property
  intro h
  have : Consistent [Formula.bot] :=
    h_mcs.1 [Formula.bot] (fun ψ hψ => by simp only
        [List.mem_cons, List.not_mem_nil, or_false] at hψ; subst hψ; exact h)
  exact this ⟨DerivationTree.assumption [Formula.bot] _ (by simp)⟩

/-! ## G (all_future): Fully Proved (sorry-free) -/

/-- G-forward (sorry-free): Gψ ∈ x → ∀y, tempR_fwd x y → ψ ∈ y. -/
theorem G_forward_mcs (x : ReflCanDomain) (ψ : Formula)
    (h_G : Formula.all_future ψ ∈ x.val) (y : ReflCanDomain)
    (h_temp : tempR_fwd x y) : ψ ∈ y.val := by
  have h_ψ_in_g : ψ ∈ g_content x := by
    simp [g_content, Bundle.g_content, h_G]
  exact h_temp h_ψ_in_g

/--
G-backward (sorry-free): If ∀y with tempR_fwd x y, ψ ∈ y.val, then Gψ ∈ x.val.

Follows the bx_G_backward pattern from BXCanonical/Frame.lean:267-316.
Uses g_content_closed_derivation from ReflexiveCanonical.lean.
-/
theorem G_backward_mcs (x : ReflCanDomain) (ψ : Formula)
    (h_truth : ∀ (y : ReflCanDomain), tempR_fwd x y → ψ ∈ y.val) :
    Formula.all_future ψ ∈ x.val := by
  have h_mcs := x.property
  by_contra h_not_G
  -- Seed: {¬ψ} ∪ g_content x. Show it's consistent.
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) ({Formula.neg ψ} ∪ g_content x) := by
    intro L hL ⟨d⟩
    by_cases h_negψ_in : Formula.neg ψ ∈ L
    · -- ¬ψ ∈ L. Remove it, get L' ⊢ ψ, use g_content_closed_derivation to get Gψ ∈ x.
      let L_filt := L.filter (· ≠ Formula.neg ψ)
      have d_reord : DerivationTree FrameClass.Base (Formula.neg ψ :: L_filt) Formula.bot :=
        derivation_exchange d (fun x => (cons_filter_neq_perm h_negψ_in x).symm)
      have d_negneg : DerivationTree FrameClass.Base L_filt (Formula.neg (Formula.neg ψ)) :=
        deduction_theorem L_filt (Formula.neg ψ) Formula.bot d_reord
      have h_filt_in_g : ∀ χ ∈ L_filt, χ ∈ g_content x := by
        intro χ hχ
        have h_and := List.mem_filter.mp hχ
        have h_ne : χ ≠ Formula.neg ψ := by simpa using h_and.2
        have h_mem := hL χ h_and.1
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd rfl h_ne
        · exact h
      have h_dne : [] ⊢ (Formula.neg (Formula.neg ψ)).imp ψ :=
        Bimodal.Theorems.Propositional.double_negation ψ
      have d_psi : DerivationTree FrameClass.Base L_filt ψ := by
        have d_dne_weak : DerivationTree FrameClass.Base L_filt
            ((Formula.neg (Formula.neg ψ)).imp ψ) :=
          DerivationTree.weakening [] L_filt _ h_dne (List.nil_subset _)
        exact DerivationTree.modus_ponens L_filt _ _ d_dne_weak d_negneg
      have h_Gψ := g_content_closed_derivation h_mcs L_filt h_filt_in_g d_psi
      exact h_not_G h_Gψ
    · -- ¬ψ ∉ L, so L ⊆ g_content x. L ⊢ ⊥ contradicts g_content_set_consistent.
      have h_L_in_g : ∀ χ ∈ L, χ ∈ g_content x := by
        intro χ hχ
        have h_mem := hL χ hχ
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd hχ h_negψ_in
        · exact h
      exact g_content_set_consistent x L h_L_in_g ⟨d⟩
  -- Extend to MCS y, derive contradiction
  obtain ⟨y₀, hy_sub, hy_mcs⟩ := set_lindenbaum ({Formula.neg ψ} ∪ g_content x) h_seed_cons
  let y : ReflCanDomain := ⟨y₀, hy_mcs⟩
  have h_g_sub : g_content x ⊆ y₀ := fun χ hχ => hy_sub (Set.mem_union_right _ hχ)
  have h_temp : tempR_fwd x y := h_g_sub
  have h_psi_in_y : ψ ∈ y₀ := h_truth y h_temp
  have h_neg_in_y : Formula.neg ψ ∈ y₀ := hy_sub (by simp)
  exact set_consistent_not_both hy_mcs.1 ψ h_psi_in_y h_neg_in_y

/-! ## H (all_past): Fully Proved (sorry-free) -/

/--
H-forward (sorry-free): Hψ ∈ x.val → ∀y, tempR_bwd y x → ψ ∈ y.val.

Trivial by definition: Hψ ∈ x.val means ψ ∈ h_content x.
tempR_bwd y x means h_content x ⊆ y.val.
So ψ ∈ y.val.
-/
theorem H_forward_mcs (x : ReflCanDomain) (ψ : Formula)
    (h_H : Formula.all_past ψ ∈ x.val) (y : ReflCanDomain)
    (h_yx : tempR_bwd y x) : ψ ∈ y.val := by
  have h_ψ_in_h : ψ ∈ h_content x := by
    simp [h_content, Bundle.h_content, h_H]
  exact h_yx h_ψ_in_h

/--
H-backward: If ∀ y with tempR_bwd y x, ψ ∈ y.val, then Hψ ∈ x.val.

Mirror of G_backward using h_content instead of g_content.
Uses h_content_closed_derivation (already proved in ReflexiveCanonical.lean)
and follows the exact same set_lindenbaum pattern.
-/
theorem H_backward_mcs (x : ReflCanDomain) (ψ : Formula)
    (h_truth : ∀ (y : ReflCanDomain), tempR_bwd y x → ψ ∈ y.val) :
    Formula.all_past ψ ∈ x.val := by
  have h_mcs := x.property
  by_contra h_not_H
  -- Seed: {¬ψ} ∪ h_content x. Show it's consistent.
  have h_seed_cons : SetConsistent (fc := FrameClass.Base) ({Formula.neg ψ} ∪ h_content x) := by
    intro L hL ⟨d⟩
    by_cases h_negψ_in : Formula.neg ψ ∈ L
    · -- ¬ψ ∈ L. Remove it, get L' ⊢ ψ, use h_content_closed_derivation to get Hψ ∈ x.
      let L_filt := L.filter (· ≠ Formula.neg ψ)
      have d_reord : DerivationTree FrameClass.Base (Formula.neg ψ :: L_filt) Formula.bot :=
        derivation_exchange d (fun x => (cons_filter_neq_perm h_negψ_in x).symm)
      have d_negneg : DerivationTree FrameClass.Base L_filt (Formula.neg (Formula.neg ψ)) :=
        deduction_theorem L_filt (Formula.neg ψ) Formula.bot d_reord
      have h_filt_in_h : ∀ χ ∈ L_filt, χ ∈ h_content x := by
        intro χ hχ
        have h_and := List.mem_filter.mp hχ
        have h_ne : χ ≠ Formula.neg ψ := by simpa using h_and.2
        have h_mem := hL χ h_and.1
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd rfl h_ne
        · exact h
      have h_dne : [] ⊢ (Formula.neg (Formula.neg ψ)).imp ψ :=
        Bimodal.Theorems.Propositional.double_negation ψ
      have d_psi : DerivationTree FrameClass.Base L_filt ψ := by
        have d_dne_weak : DerivationTree FrameClass.Base L_filt
            ((Formula.neg (Formula.neg ψ)).imp ψ) :=
          DerivationTree.weakening [] L_filt _ h_dne (List.nil_subset _)
        exact DerivationTree.modus_ponens L_filt _ _ d_dne_weak d_negneg
      have h_Hψ := h_content_closed_derivation h_mcs L_filt h_filt_in_h d_psi
      exact h_not_H h_Hψ
    · -- ¬ψ ∉ L, so L ⊆ h_content x. L ⊢ ⊥ contradicts h_content_set_consistent.
      have h_L_in_h : ∀ χ ∈ L, χ ∈ h_content x := by
        intro χ hχ
        have h_mem := hL χ hχ
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd hχ h_negψ_in
        · exact h
      exact h_content_set_consistent x L h_L_in_h ⟨d⟩
  -- Extend to MCS y, derive contradiction
  obtain ⟨y₀, hy_sub, hy_mcs⟩ := set_lindenbaum ({Formula.neg ψ} ∪ h_content x) h_seed_cons
  let y : ReflCanDomain := ⟨y₀, hy_mcs⟩
  have h_h_sub : h_content x ⊆ y₀ := fun χ hχ => hy_sub (Set.mem_union_right _ hχ)
  have h_temp : tempR_bwd y x := h_h_sub
  have h_psi_in_y : ψ ∈ y₀ := h_truth y h_temp
  have h_neg_in_y : Formula.neg ψ ∈ y₀ := hy_sub (by simp)
  exact set_consistent_not_both hy_mcs.1 ψ h_psi_in_y h_neg_in_y

end Bimodal.Metalogic.WeakCanonical
