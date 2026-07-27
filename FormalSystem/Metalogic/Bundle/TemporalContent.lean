/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.Metalogic.Core.MCSProperties
import FormalSystem.Theorems.GeneralizedNecessitation

/-!
# Temporal Content Definitions

Shared definitions for GContent, HContent, FContent, PContent, UContent, SContent
used by canonical model constructions.

## Universal Content Extractors
- `GContent(M)` = {φ | Gφ ∈ M} - formulas under universal future (G)
- `HContent(M)` = {φ | Hφ ∈ M} - formulas under universal past (H)

## Existential Content Extractors
- `FContent(M)` = {φ | Fφ ∈ M} - formulas under existential future (F)
- `PContent(M)` = {φ | Pφ ∈ M} - formulas under existential past (P)

## Until/Since Content Extractors
- `UContent(M)` = {(φ,ψ) | φ U ψ ∈ M} - Until pairs
- `SContent(M)` = {(φ,ψ) | φ S ψ ∈ M} - Since pairs

## Duality
The existential operators are defined as duals of the universal operators:
- Fφ = ¬G¬φ (some future = not always not)
- Pφ = ¬H¬φ (some past = not always not)

This induces a relationship between the content extractors via MCS properties:
- φ ∈ FContent(M) ↔ ¬φ ∉ GContent(M)
- φ ∈ PContent(M) ↔ ¬φ ∉ HContent(M)

## Usage
- GContent and HContent: used in `CanonicalFrame.lean`, `WitnessSeed.lean`, and
`SuccExistence.lean`
- FContent: foundation for Succ relation (`SuccRelation.lean`)
- PContent: symmetric past counterpart of FContent
- UContent and SContent: Until/Since step conditions in `UntilSinceCoherence.lean`
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax

/--
GContent of an MCS: the set of all formulas phi where G phi appears in the MCS.

**Important**: GContent strips F-formulas. If F(psi) is in M, psi will NOT
appear in GContent(M) unless G(psi) is also in M. This means F-formulas do NOT
persist through GContent seeds in chain constructions. Resolution of F-obligations
requires separate handling (see SuccRelation.lean's F-step condition and
BXCanonical/CanonicalChain.lean's chain construction).
-/
def GContent (M : Set Formula) : Set Formula :=
  {phi | Formula.allFuture phi ∈ M}

/--
HContent of an MCS: the set of all formulas phi where H phi appears in the MCS.

**Important**: HContent strips P-formulas. If P(psi) is in M, psi will NOT
appear in HContent(M) unless H(psi) is also in M. This means P-formulas do NOT
persist through HContent seeds in chain constructions. Symmetric to GContent.
-/
def HContent (M : Set Formula) : Set Formula :=
  {phi | Formula.allPast phi ∈ M}

/--
FContent of an MCS: the set of all formulas phi where F phi (someFuture phi) appears in the MCS.

This extracts formulas under the existential future operator F.
Used in the Succ relation construction (SuccRelation.lean, SuccExistence.lean)
for discrete temporal frames.

**Duality**: FContent relates to GContent via `Fφ = ¬G¬φ`.
See `f_content_iff_not_neg_in_g_content` for the formal relationship.
-/
def FContent (M : Set Formula) : Set Formula :=
  {phi | Formula.someFuture phi ∈ M}

/--
PContent of an MCS: the set of all formulas phi where P phi (somePast phi) appears in the MCS.

This extracts formulas under the existential past operator P.
Symmetric past counterpart of FContent.

**Duality**: PContent relates to HContent via `Pφ = ¬H¬φ`.
See `p_content_iff_not_neg_in_h_content` for the formal relationship.
-/
def PContent (M : Set Formula) : Set Formula :=
  {phi | Formula.somePast phi ∈ M}

/--
UContent of an MCS: the set of all formula pairs (phi, psi) where `phi U psi` appears in the MCS.

**Usage**: Used in the Succ relation U-step condition (Phase 5) and dovetailed chain
construction (Phase 6). The U-step ensures that for each `(phi U psi) ∈ u`, the
successor v either contains psi (resolved) or contains both phi and `phi U psi` (deferred).
-/
def UContent (M : Set Formula) : Set (Formula × Formula) :=
  { p | Formula.untl p.1 p.2 ∈ M }

/--
SContent of an MCS: the set of all formula pairs (phi, psi) where `phi S psi` appears in the MCS.

**Usage**: Used in the backward Succ relation S-step condition (Phase 5) and dovetailed
chain construction (Phase 6). Symmetric to UContent.
-/
def SContent (M : Set Formula) : Set (Formula × Formula) :=
  { p | Formula.snce p.1 p.2 ∈ M }

/-! ## Membership Lemmas -/

@[simp]
lemma mem_g_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ GContent M ↔ Formula.allFuture phi ∈ M := Iff.rfl

@[simp]
lemma mem_h_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ HContent M ↔ Formula.allPast phi ∈ M := Iff.rfl

@[simp]
lemma mem_f_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ FContent M ↔ Formula.someFuture phi ∈ M := Iff.rfl

@[simp]
lemma mem_p_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ PContent M ↔ Formula.somePast phi ∈ M := Iff.rfl

@[simp]
lemma mem_u_content_iff {M : Set Formula} {p : Formula × Formula} :
    p ∈ UContent M ↔ Formula.untl p.1 p.2 ∈ M := Iff.rfl

@[simp]
lemma mem_s_content_iff {M : Set Formula} {p : Formula × Formula} :
    p ∈ SContent M ↔ Formula.snce p.1 p.2 ∈ M := Iff.rfl

/-! ## Duality Lemmas -/

open FormalSystem.Metalogic.Core FormalSystem.ProofSystem FormalSystem.Theorems in
/--
Duality between FContent and GContent for MCS.

For a set-maximal consistent set M:
  φ ∈ FContent(M) ↔ ¬φ ∉ GContent(M)

This reflects the definitional duality Fφ = ¬G¬φ lifted to content extractors.

**Proof Strategy**:
- Forward: If Fφ ∈ M (i.e., ¬G¬φ ∈ M), then G¬φ ∉ M by MCS consistency
- Backward: If G¬φ ∉ M, then ¬G¬φ ∈ M by negation completeness, so Fφ ∈ M
-/
theorem f_content_iff_not_neg_in_g_content {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FormalSystem.ProofSystem.FrameClass.Base) M) (phi : Formula) :
    phi ∈ FContent M ↔ phi.neg ∉ GContent M := by
  simp only [mem_f_content_iff, mem_g_content_iff]
  -- Goal: someFuture phi ∈ M ↔ allFuture (phi.neg) ∉ M
  -- Key structural fact: allFuture (phi.neg) = (someFuture (phi.neg.neg)).neg
  -- So the duality requires bridging someFuture phi ↔ someFuture (phi.neg.neg) via DNI/DNE + BX3
  have h_af_eq : Formula.allFuture phi.neg = (Formula.someFuture phi.neg.neg).neg := rfl
  constructor
  · intro h_sf_in h_af_in
    rw [h_af_eq] at h_af_in
    -- h_sf_in : someFuture phi ∈ M, h_af_in : (someFuture (phi.neg.neg)).neg ∈ M
    -- Derive ⊢ someFuture phi → someFuture (phi.neg.neg) via DNI + BX3
    have h_dni : [] ⊢ phi.imp phi.neg.neg := Combinators.notNotIntro phi
    have h_G_dni : [] ⊢ (phi.imp phi.neg.neg).allFuture :=
      DerivationTree.temporal_necessitation _ h_dni
    have h_bx3 : [] ⊢ (phi.imp phi.neg.neg).allFuture.imp
        ((Formula.untl phi Formula.top).imp (Formula.untl phi.neg.neg Formula.top)) :=
      DerivationTree.axiom [] _ (Axiom.right_mono_until phi phi.neg.neg Formula.top) trivial
    have h_sf_impl : [] ⊢ (Formula.someFuture phi).imp (Formula.someFuture phi.neg.neg) :=
      DerivationTree.modus_ponens [] _ _ h_bx3 h_G_dni
    have h_sf_nn_in : Formula.someFuture phi.neg.neg ∈ M :=
      SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_sf_impl) h_sf_in
    exact set_consistent_not_both h_mcs.1 (Formula.someFuture phi.neg.neg) h_sf_nn_in h_af_in
  · intro h_af_not_in
    rw [h_af_eq] at h_af_not_in
    -- h_af_not_in : (someFuture (phi.neg.neg)).neg ∉ M
    -- By negation_complete: someFuture (phi.neg.neg) ∈ M
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.someFuture phi.neg.neg) with
    | inl h_in =>
      -- Derive ⊢ someFuture (phi.neg.neg) → someFuture phi via DNE + BX3
      have h_dne : [] ⊢ phi.neg.neg.imp phi := Propositional.doubleNegation phi
      have h_G_dne : [] ⊢ (phi.neg.neg.imp phi).allFuture :=
        DerivationTree.temporal_necessitation _ h_dne
      have h_bx3 : [] ⊢ (phi.neg.neg.imp phi).allFuture.imp
          ((Formula.untl phi.neg.neg Formula.top).imp (Formula.untl phi Formula.top)) :=
        DerivationTree.axiom [] _ (Axiom.right_mono_until phi.neg.neg phi Formula.top) trivial
      have h_sf_impl : [] ⊢ (Formula.someFuture phi.neg.neg).imp (Formula.someFuture phi) :=
        DerivationTree.modus_ponens [] _ _ h_bx3 h_G_dne
      exact SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_sf_impl) h_in
    | inr h_neg_in => exact absurd h_neg_in h_af_not_in

open FormalSystem.Metalogic.Core FormalSystem.ProofSystem FormalSystem.Theorems in
/--
Duality between PContent and HContent for MCS.

For a set-maximal consistent set M:
  φ ∈ PContent(M) ↔ ¬φ ∉ HContent(M)

This reflects the definitional duality Pφ = ¬H¬φ lifted to content extractors.
Symmetric to `f_content_iff_not_neg_in_g_content`.
-/
theorem p_content_iff_not_neg_in_h_content {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FormalSystem.ProofSystem.FrameClass.Base) M) (phi : Formula) :
    phi ∈ PContent M ↔ phi.neg ∉ HContent M := by
  simp only [mem_p_content_iff, mem_h_content_iff]
  -- Goal: somePast phi ∈ M ↔ allPast (phi.neg) ∉ M
  -- Key structural fact: allPast (phi.neg) = (somePast (phi.neg.neg)).neg
  have h_ap_eq : Formula.allPast phi.neg = (Formula.somePast phi.neg.neg).neg := rfl
  constructor
  · intro h_sp_in h_ap_in
    rw [h_ap_eq] at h_ap_in
    -- Derive ⊢ somePast phi → somePast (phi.neg.neg) via DNI + BX3' (right_mono_since)
    have h_dni : [] ⊢ phi.imp phi.neg.neg := Combinators.notNotIntro phi
    have h_H_dni : [] ⊢ (phi.imp phi.neg.neg).allPast :=
      FormalSystem.Theorems.pastNecessitation _ h_dni
    have h_bx3p : [] ⊢ (phi.imp phi.neg.neg).allPast.imp
        ((Formula.snce phi Formula.top).imp (Formula.snce phi.neg.neg Formula.top)) :=
      DerivationTree.axiom [] _ (Axiom.right_mono_since phi phi.neg.neg Formula.top) trivial
    have h_sp_impl : [] ⊢ (Formula.somePast phi).imp (Formula.somePast phi.neg.neg) :=
      DerivationTree.modus_ponens [] _ _ h_bx3p h_H_dni
    have h_sp_nn_in : Formula.somePast phi.neg.neg ∈ M :=
      SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_sp_impl) h_sp_in
    exact set_consistent_not_both h_mcs.1 (Formula.somePast phi.neg.neg) h_sp_nn_in h_ap_in
  · intro h_ap_not_in
    rw [h_ap_eq] at h_ap_not_in
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.somePast phi.neg.neg) with
    | inl h_in =>
      -- Derive ⊢ somePast (phi.neg.neg) → somePast phi via DNE + BX3'
      have h_dne : [] ⊢ phi.neg.neg.imp phi := Propositional.doubleNegation phi
      have h_H_dne : [] ⊢ (phi.neg.neg.imp phi).allPast :=
        FormalSystem.Theorems.pastNecessitation _ h_dne
      have h_bx3p : [] ⊢ (phi.neg.neg.imp phi).allPast.imp
          ((Formula.snce phi.neg.neg Formula.top).imp (Formula.snce phi Formula.top)) :=
        DerivationTree.axiom [] _ (Axiom.right_mono_since phi.neg.neg phi Formula.top) trivial
      have h_sp_impl : [] ⊢ (Formula.somePast phi.neg.neg).imp (Formula.somePast phi) :=
        DerivationTree.modus_ponens [] _ _ h_bx3p h_H_dne
      exact SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_sp_impl) h_in
    | inr h_neg_in => exact absurd h_neg_in h_ap_not_in

end FormalSystem.Metalogic.Bundle
