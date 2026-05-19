import Bimodal.Syntax.Formula
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Temporal Content Definitions

Shared definitions for g_content, h_content, f_content, p_content, u_content, s_content
used by canonical model constructions.

## Universal Content Extractors
- `g_content(M)` = {φ | Gφ ∈ M} - formulas under universal future (G)
- `h_content(M)` = {φ | Hφ ∈ M} - formulas under universal past (H)

## Existential Content Extractors
- `f_content(M)` = {φ | Fφ ∈ M} - formulas under existential future (F)
- `p_content(M)` = {φ | Pφ ∈ M} - formulas under existential past (P)

## Until/Since Content Extractors
- `u_content(M)` = {(φ,ψ) | φ U ψ ∈ M} - Until pairs
- `s_content(M)` = {(φ,ψ) | φ S ψ ∈ M} - Since pairs

## Duality
The existential operators are defined as duals of the universal operators:
- Fφ = ¬G¬φ (some future = not always not)
- Pφ = ¬H¬φ (some past = not always not)

This induces a relationship between the content extractors via MCS properties:
- φ ∈ f_content(M) ↔ ¬φ ∉ g_content(M)
- φ ∈ p_content(M) ↔ ¬φ ∉ h_content(M)

## Usage
- g_content and h_content: used in `TemporalCoherentConstruction.lean` and `DovetailingChain.lean`
- f_content: foundation for Succ relation
- p_content: foundation for DenseTask relation
- u_content and s_content: Until/Since step conditions in canonical constructions
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax

/--
g_content of an MCS: the set of all formulas phi where G phi appears in the MCS.

**Important**: g_content strips F-formulas. If F(psi) is in M, psi will NOT
appear in g_content(M) unless G(psi) is also in M. This means F-formulas do NOT
persist through g_content seeds in chain constructions. Resolution of F-obligations
requires a non-linear construction (e.g., omega-squared) rather than relying on
linear g_content propagation. See DovetailingChain.lean for details.
-/
def g_content (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}

/--
h_content of an MCS: the set of all formulas phi where H phi appears in the MCS.

**Important**: h_content strips P-formulas. If P(psi) is in M, psi will NOT
appear in h_content(M) unless H(psi) is also in M. This means P-formulas do NOT
persist through h_content seeds in chain constructions. Symmetric to g_content.
-/
def h_content (M : Set Formula) : Set Formula :=
  {phi | Formula.all_past phi ∈ M}

/--
f_content of an MCS: the set of all formulas phi where F phi (some_future phi) appears in the MCS.

This extracts formulas under the existential future operator F.
Used in the Succ relation construction (tasks 10-15) for discrete temporal frames.

**Duality**: f_content relates to g_content via `Fφ = ¬G¬φ`.
See `f_content_iff_not_neg_in_g_content` for the formal relationship.
-/
def f_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_future phi ∈ M}

/--
p_content of an MCS: the set of all formulas phi where P phi (some_past phi) appears in the MCS.

This extracts formulas under the existential past operator P.
Used in the DenseTask relation construction (tasks 16-18) for dense temporal frames.

**Duality**: p_content relates to h_content via `Pφ = ¬H¬φ`.
See `p_content_iff_not_neg_in_h_content` for the formal relationship.
-/
def p_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_past phi ∈ M}

/--
u_content of an MCS: the set of all formula pairs (phi, psi) where `phi U psi` appears in the MCS.

**Usage**: Used in the Succ relation U-step condition (Phase 5) and dovetailed chain
construction (Phase 6). The U-step ensures that for each `(phi U psi) ∈ u`, the
successor v either contains psi (resolved) or contains both phi and `phi U psi` (deferred).
-/
def u_content (M : Set Formula) : Set (Formula × Formula) :=
  { p | Formula.untl p.1 p.2 ∈ M }

/--
s_content of an MCS: the set of all formula pairs (phi, psi) where `phi S psi` appears in the MCS.

**Usage**: Used in the backward Succ relation S-step condition (Phase 5) and dovetailed
chain construction (Phase 6). Symmetric to u_content.
-/
def s_content (M : Set Formula) : Set (Formula × Formula) :=
  { p | Formula.snce p.1 p.2 ∈ M }

/-! ## Membership Lemmas -/

@[simp]
lemma mem_g_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ g_content M ↔ Formula.all_future phi ∈ M := Iff.rfl

@[simp]
lemma mem_h_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ h_content M ↔ Formula.all_past phi ∈ M := Iff.rfl

@[simp]
lemma mem_f_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ f_content M ↔ Formula.some_future phi ∈ M := Iff.rfl

@[simp]
lemma mem_p_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ p_content M ↔ Formula.some_past phi ∈ M := Iff.rfl

@[simp]
lemma mem_u_content_iff {M : Set Formula} {p : Formula × Formula} :
    p ∈ u_content M ↔ Formula.untl p.1 p.2 ∈ M := Iff.rfl

@[simp]
lemma mem_s_content_iff {M : Set Formula} {p : Formula × Formula} :
    p ∈ s_content M ↔ Formula.snce p.1 p.2 ∈ M := Iff.rfl

/-! ## Duality Lemmas -/

open Bimodal.Metalogic.Core Bimodal.ProofSystem Bimodal.Theorems in
/--
Duality between f_content and g_content for MCS.

For a set-maximal consistent set M:
  φ ∈ f_content(M) ↔ ¬φ ∉ g_content(M)

This reflects the definitional duality Fφ = ¬G¬φ lifted to content extractors.

**Proof Strategy**:
- Forward: If Fφ ∈ M (i.e., ¬G¬φ ∈ M), then G¬φ ∉ M by MCS consistency
- Backward: If G¬φ ∉ M, then ¬G¬φ ∈ M by negation completeness, so Fφ ∈ M
-/
theorem f_content_iff_not_neg_in_g_content {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (phi : Formula) :
    phi ∈ f_content M ↔ phi.neg ∉ g_content M := by
  simp only [mem_f_content_iff, mem_g_content_iff]
  -- Goal: some_future phi ∈ M ↔ all_future (phi.neg) ∉ M
  -- Key structural fact: all_future (phi.neg) = (some_future (phi.neg.neg)).neg
  -- So the duality requires bridging some_future phi ↔ some_future (phi.neg.neg) via DNI/DNE + BX3
  have h_af_eq : Formula.all_future phi.neg = (Formula.some_future phi.neg.neg).neg := rfl
  constructor
  · intro h_sf_in h_af_in
    rw [h_af_eq] at h_af_in
    -- h_sf_in : some_future phi ∈ M, h_af_in : (some_future (phi.neg.neg)).neg ∈ M
    -- Derive ⊢ some_future phi → some_future (phi.neg.neg) via DNI + BX3
    have h_dni : [] ⊢ phi.imp phi.neg.neg := Combinators.dni phi
    have h_G_dni : [] ⊢ (phi.imp phi.neg.neg).all_future :=
      DerivationTree.temporal_necessitation _ h_dni
    have h_bx3 : [] ⊢ (phi.imp phi.neg.neg).all_future.imp
        ((Formula.untl phi Formula.top).imp (Formula.untl phi.neg.neg Formula.top)) :=
      DerivationTree.axiom [] _ (Axiom.right_mono_until phi phi.neg.neg Formula.top)
    have h_sf_impl : [] ⊢ (Formula.some_future phi).imp (Formula.some_future phi.neg.neg) :=
      DerivationTree.modus_ponens [] _ _ h_bx3 h_G_dni
    have h_sf_nn_in : Formula.some_future phi.neg.neg ∈ M :=
      SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_sf_impl) h_sf_in
    exact set_consistent_not_both h_mcs.1 (Formula.some_future phi.neg.neg) h_sf_nn_in h_af_in
  · intro h_af_not_in
    rw [h_af_eq] at h_af_not_in
    -- h_af_not_in : (some_future (phi.neg.neg)).neg ∉ M
    -- By negation_complete: some_future (phi.neg.neg) ∈ M
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.some_future phi.neg.neg) with
    | inl h_in =>
      -- Derive ⊢ some_future (phi.neg.neg) → some_future phi via DNE + BX3
      have h_dne : [] ⊢ phi.neg.neg.imp phi := Propositional.double_negation phi
      have h_G_dne : [] ⊢ (phi.neg.neg.imp phi).all_future :=
        DerivationTree.temporal_necessitation _ h_dne
      have h_bx3 : [] ⊢ (phi.neg.neg.imp phi).all_future.imp
          ((Formula.untl phi.neg.neg Formula.top).imp (Formula.untl phi Formula.top)) :=
        DerivationTree.axiom [] _ (Axiom.right_mono_until phi.neg.neg phi Formula.top)
      have h_sf_impl : [] ⊢ (Formula.some_future phi.neg.neg).imp (Formula.some_future phi) :=
        DerivationTree.modus_ponens [] _ _ h_bx3 h_G_dne
      exact SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_sf_impl) h_in
    | inr h_neg_in => exact absurd h_neg_in h_af_not_in

open Bimodal.Metalogic.Core Bimodal.ProofSystem Bimodal.Theorems in
/--
Duality between p_content and h_content for MCS.

For a set-maximal consistent set M:
  φ ∈ p_content(M) ↔ ¬φ ∉ h_content(M)

This reflects the definitional duality Pφ = ¬H¬φ lifted to content extractors.
Symmetric to `f_content_iff_not_neg_in_g_content`.
-/
theorem p_content_iff_not_neg_in_h_content {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (phi : Formula) :
    phi ∈ p_content M ↔ phi.neg ∉ h_content M := by
  simp only [mem_p_content_iff, mem_h_content_iff]
  -- Goal: some_past phi ∈ M ↔ all_past (phi.neg) ∉ M
  -- Key structural fact: all_past (phi.neg) = (some_past (phi.neg.neg)).neg
  have h_ap_eq : Formula.all_past phi.neg = (Formula.some_past phi.neg.neg).neg := rfl
  constructor
  · intro h_sp_in h_ap_in
    rw [h_ap_eq] at h_ap_in
    -- Derive ⊢ some_past phi → some_past (phi.neg.neg) via DNI + BX3' (right_mono_since)
    have h_dni : [] ⊢ phi.imp phi.neg.neg := Combinators.dni phi
    have h_H_dni : [] ⊢ (phi.imp phi.neg.neg).all_past :=
      Bimodal.Theorems.past_necessitation _ h_dni
    have h_bx3p : [] ⊢ (phi.imp phi.neg.neg).all_past.imp
        ((Formula.snce phi Formula.top).imp (Formula.snce phi.neg.neg Formula.top)) :=
      DerivationTree.axiom [] _ (Axiom.right_mono_since phi phi.neg.neg Formula.top)
    have h_sp_impl : [] ⊢ (Formula.some_past phi).imp (Formula.some_past phi.neg.neg) :=
      DerivationTree.modus_ponens [] _ _ h_bx3p h_H_dni
    have h_sp_nn_in : Formula.some_past phi.neg.neg ∈ M :=
      SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_sp_impl) h_sp_in
    exact set_consistent_not_both h_mcs.1 (Formula.some_past phi.neg.neg) h_sp_nn_in h_ap_in
  · intro h_ap_not_in
    rw [h_ap_eq] at h_ap_not_in
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.some_past phi.neg.neg) with
    | inl h_in =>
      -- Derive ⊢ some_past (phi.neg.neg) → some_past phi via DNE + BX3'
      have h_dne : [] ⊢ phi.neg.neg.imp phi := Propositional.double_negation phi
      have h_H_dne : [] ⊢ (phi.neg.neg.imp phi).all_past :=
        Bimodal.Theorems.past_necessitation _ h_dne
      have h_bx3p : [] ⊢ (phi.neg.neg.imp phi).all_past.imp
          ((Formula.snce phi.neg.neg Formula.top).imp (Formula.snce phi Formula.top)) :=
        DerivationTree.axiom [] _ (Axiom.right_mono_since phi.neg.neg phi Formula.top)
      have h_sp_impl : [] ⊢ (Formula.some_past phi.neg.neg).imp (Formula.some_past phi) :=
        DerivationTree.modus_ponens [] _ _ h_bx3p h_H_dne
      exact SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_sp_impl) h_in
    | inr h_neg_in => exact absurd h_neg_in h_ap_not_in

end Bimodal.Metalogic.Bundle
