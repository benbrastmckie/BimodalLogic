/-!
# BONEYARD - ARCHIVED

**WARNING**: This file has been archived to the Boneyard. Do not use in new code.

**Reason**: Legacy FMCS definitions using CanonicalReachable and CanonicalQuotient as domains.
These were preserved for backward compatibility but are no longer referenced by any active
code. The CanonicalReachable backward_P is blocked; the CanonicalQuotient approach is
superseded by the all-MCS approach.

**Archived from**: Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean (lines 287-399)
**Date**: 2026-02-26
**Task**: 933

**Alternative**: Use `canonicalMCSBFMCS` from `Bimodal.Metalogic.Bundle.CanonicalFMCS` instead.
-/

-- Original imports (may not compile from Boneyard location)
-- These definitions required CanonicalQuotient and CanonicalReachable which are now archived.
-- import Bimodal.Metalogic.Bundle.CanonicalQuotient
-- import Bimodal.Metalogic.Bundle.CanonicalReachable
-- import Bimodal.Metalogic.Bundle.CanonicalFrame
-- import Bimodal.Metalogic.Bundle.FMCSDef

/-!
## Legacy CanonicalReachable FMCS (Preserved for Compatibility)

The following constructions use CanonicalReachable as the domain. They are preserved
for backward compatibility with files that reference them, but the primary construction
(canonicalMCSBFMCS) should be preferred because it supports both forward_F AND
backward_P without sorry.

NOTE: The CanonicalReachable backward_P is BLOCKED because past witnesses of future-
reachable MCSes are not necessarily future-reachable. See CanonicalFMCS.lean module docstring.
-/

/-
-- The following definitions are archived (compile errors expected due to missing imports):

def canonicalReachableBFMCS_mcs (w : CanonicalReachable M₀ h_mcs₀) : Set Formula :=
  w.world

theorem canonicalReachableBFMCS_is_mcs (w : CanonicalReachable M₀ h_mcs₀) :
    SetMaximalConsistent (canonicalReachableBFMCS_mcs w) :=
  w.is_mcs

theorem canonicalReachableBFMCS_forward_G
    (w₁ w₂ : CanonicalReachable M₀ h_mcs₀) (phi : Formula)
    (h_le : w₁ ≤ w₂) (h_G : Formula.all_future phi ∈ canonicalReachableBFMCS_mcs w₁) :
    phi ∈ canonicalReachableBFMCS_mcs w₂ :=
  canonical_forward_G w₁.world w₂.world h_le phi h_G

theorem canonicalReachableBFMCS_backward_H
    (w₁ w₂ : CanonicalReachable M₀ h_mcs₀) (phi : Formula)
    (h_le : w₂ ≤ w₁) (h_H : Formula.all_past phi ∈ canonicalReachableBFMCS_mcs w₁) :
    phi ∈ canonicalReachableBFMCS_mcs w₂ := by
  have h_R_past : CanonicalR_past w₁.world w₂.world :=
    GContent_subset_implies_HContent_reverse w₂.world w₁.world w₂.is_mcs w₁.is_mcs h_le
  exact canonical_backward_H w₁.world w₂.world h_R_past phi h_H

noncomputable def canonicalReachableBFMCS : FMCS (CanonicalReachable M₀ h_mcs₀) where
  mcs := canonicalReachableBFMCS_mcs
  is_mcs := canonicalReachableBFMCS_is_mcs
  forward_G := fun w₁ w₂ phi h_le h_G =>
    canonicalReachableBFMCS_forward_G w₁ w₂ phi h_le h_G
  backward_H := fun w₁ w₂ phi h_le h_H =>
    canonicalReachableBFMCS_backward_H w₁ w₂ phi h_le h_H

noncomputable instance CanonicalReachable.instZero : Zero (CanonicalReachable M₀ h_mcs₀) where
  zero := CanonicalReachable.root

theorem canonicalReachableBFMCS_forward_F
    (w : CanonicalReachable M₀ h_mcs₀) (phi : Formula)
    (h_F : Formula.some_future phi ∈ canonicalReachableBFMCS_mcs w) :
    ∃ s : CanonicalReachable M₀ h_mcs₀, w ≤ s ∧ phi ∈ canonicalReachableBFMCS_mcs s := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F w.world w.is_mcs phi h_F
  have h_W_reachable : CanonicalR M₀ W :=
    canonicalR_transitive M₀ w.world W h_mcs₀ w.reachable h_R
  let s : CanonicalReachable M₀ h_mcs₀ := ⟨W, h_W_mcs, h_W_reachable⟩
  exact ⟨s, h_R, h_phi_W⟩

theorem canonicalReachableBFMCS_root_contains (phi : Formula) (h_mem : phi ∈ M₀) :
    phi ∈ canonicalReachableBFMCS.mcs (0 : CanonicalReachable M₀ h_mcs₀) :=
  h_mem

-- Legacy Quotient-Based Definitions

noncomputable def canonicalBFMCS_mcs (q : CanonicalQuotient M₀ h_mcs₀) : Set Formula :=
  q.repr.world

noncomputable instance CanonicalQuotient.instZero : Zero (CanonicalQuotient M₀ h_mcs₀) where
  zero := CanonicalQuotient.root
-/
