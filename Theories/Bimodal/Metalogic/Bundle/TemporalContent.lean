import Bimodal.Syntax.Formula
import Bimodal.Metalogic.Core.MCSProperties

/-!
# Temporal Content Definitions

Shared definitions for g_content, h_content, f_content, and p_content used by
canonical model constructions.

## Universal Content Extractors
- `g_content(M)` = {φ | Gφ ∈ M} - formulas under universal future (G)
- `h_content(M)` = {φ | Hφ ∈ M} - formulas under universal past (H)

## Existential Content Extractors
- `f_content(M)` = {φ | Fφ ∈ M} - formulas under existential future (F)
- `p_content(M)` = {φ | Pφ ∈ M} - formulas under existential past (P)

## Duality
The existential operators are defined as duals of the universal operators:
- Fφ = ¬G¬φ (some future = not always not)
- Pφ = ¬H¬φ (some past = not always not)

This induces a relationship between the content extractors via MCS properties:
- φ ∈ f_content(M) ↔ ¬φ ∉ g_content(M)
- φ ∈ p_content(M) ↔ ¬φ ∉ h_content(M)

## Usage
- g_content and h_content: used in `TemporalCoherentConstruction.lean` and `DovetailingChain.lean`
- f_content: foundation for Succ relation (discrete track, tasks 10-15)
- p_content: foundation for DenseTask relation (dense track, tasks 16-18)
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax

/--
g_content of an MCS: the set of all formulas phi where G phi appears in the MCS.

**Important**: g_content strips F-formulas. If F(psi) is in M, psi will NOT
appear in g_content(M) unless G(psi) is also in M. This means F-formulas do NOT
persist through g_content seeds in chain constructions. Resolution of F-obligations
requires a non-linear construction (e.g., omega-squared) rather than relying on
linear g_content propagation. See DovetailingChain.lean and Task 916 research for details.
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

/-! ## Duality Lemmas -/

open Bimodal.Metalogic.Core in
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
  -- Unfold definitions: f_content uses some_future, g_content uses all_future
  -- some_future phi = phi.neg.all_future.neg by definition
  simp only [mem_f_content_iff, mem_g_content_iff]
  -- Goal: phi.some_future ∈ M ↔ phi.neg.all_future ∉ M
  -- Rewrite some_future to its definition
  unfold Formula.some_future
  -- Goal: phi.neg.all_future.neg ∈ M ↔ phi.neg.all_future ∉ M
  constructor
  · -- Forward: If ¬G¬φ ∈ M, then G¬φ ∉ M
    intro h_neg_G_neg_in
    intro h_G_neg_in
    -- Both G¬φ and ¬G¬φ in M contradicts consistency
    exact set_consistent_not_both h_mcs.1 (phi.neg.all_future) h_G_neg_in h_neg_G_neg_in
  · -- Backward: If G¬φ ∉ M, then ¬G¬φ ∈ M by negation completeness
    intro h_G_neg_not_in
    -- By negation completeness: G¬φ ∈ M ∨ ¬G¬φ ∈ M
    cases SetMaximalConsistent.negation_complete h_mcs (phi.neg.all_future) with
    | inl h_in => exact absurd h_in h_G_neg_not_in
    | inr h_neg_in => exact h_neg_in

open Bimodal.Metalogic.Core in
/--
Duality between p_content and h_content for MCS.

For a set-maximal consistent set M:
  φ ∈ p_content(M) ↔ ¬φ ∉ h_content(M)

This reflects the definitional duality Pφ = ¬H¬φ lifted to content extractors.
Symmetric to `f_content_iff_not_neg_in_g_content`.

**Proof Strategy**:
- Forward: If Pφ ∈ M (i.e., ¬H¬φ ∈ M), then H¬φ ∉ M by MCS consistency
- Backward: If H¬φ ∉ M, then ¬H¬φ ∈ M by negation completeness, so Pφ ∈ M
-/
theorem p_content_iff_not_neg_in_h_content {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (phi : Formula) :
    phi ∈ p_content M ↔ phi.neg ∉ h_content M := by
  -- Unfold definitions: p_content uses some_past, h_content uses all_past
  -- some_past phi = phi.neg.all_past.neg by definition
  simp only [mem_p_content_iff, mem_h_content_iff]
  -- Goal: phi.some_past ∈ M ↔ phi.neg.all_past ∉ M
  -- Rewrite some_past to its definition
  unfold Formula.some_past
  -- Goal: phi.neg.all_past.neg ∈ M ↔ phi.neg.all_past ∉ M
  constructor
  · -- Forward: If ¬H¬φ ∈ M, then H¬φ ∉ M
    intro h_neg_H_neg_in h_H_neg_in
    -- Both H¬φ and ¬H¬φ in M contradicts consistency
    exact set_consistent_not_both h_mcs.1 (phi.neg.all_past) h_H_neg_in h_neg_H_neg_in
  · -- Backward: If H¬φ ∉ M, then ¬H¬φ ∈ M by negation completeness
    intro h_H_neg_not_in
    -- By negation completeness: H¬φ ∈ M ∨ ¬H¬φ ∈ M
    cases SetMaximalConsistent.negation_complete h_mcs (phi.neg.all_past) with
    | inl h_in => exact absurd h_in h_H_neg_not_in
    | inr h_neg_in => exact h_neg_in

end Bimodal.Metalogic.Bundle
