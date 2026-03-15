import Bimodal.Metalogic.StagedConstruction.StagedExecution
import Bimodal.Syntax.Subformulas
import Bimodal.Syntax.SubformulaClosure
import Mathlib.Data.Finset.Card

/-!
# Density Frame Condition for Reflexive Temporal Semantics

This module proves the canonical model density frame condition under
reflexive semantics using temporal axioms alone: for all MCSs M, M'
with CanonicalR(M, M') and NOT CanonicalR(M', M), there exists W with
CanonicalR(M, W) AND CanonicalR(W, M').

## Strategy: Double-Density Trick + Reflexivity Case Split

The proof uses Case A analysis combined with the "double-density trick":

1. From NOT CanonicalR(M', M), find distinguishing formula delta with
   G(delta) in M' and delta not in M.
2. Case-split on G(delta) in M:
   - Case A (G(delta) not in M): F(neg(delta)) in M.
     Apply density twice: F(F(neg(delta))) in M gives intermediate W
     with CanonicalR(M, W) and F(neg(delta)) in W. Then forward witness
     V from W with CanonicalR(W, V) and neg(delta) in V.
     Temporal linearity on M, V, M' gives three cases:
     * CanonicalR(V, M'): V is intermediate.
     * CanonicalR(M', V): delta in GContent(M') subset V but neg(delta)
       in V. Contradiction.
     * V = M': CanonicalR(W, V) = CanonicalR(W, M'), so W is intermediate.
   - Case B (G(delta) in M): Sub-split on CanonicalR(M', M'):
     * B1 (M' reflexive): Take W = M'. Both CanonicalR(M, M') and
       CanonicalR(M', M') hold.
     * B2 (M' not reflexive): GContent(M') is not a subset of M', so
       there exists gamma with G(gamma) in M' and gamma not in M'.
       If G(gamma) were in M, then gamma would be in GContent(M) subset
       M' (by CanonicalR(M, M')), contradicting gamma not in M'. So
       G(gamma) not in M, and we apply Case A with gamma.

## Note on Strict Density

For STRICT density (where the intermediate W satisfies ¬CanonicalR(W, M) AND
¬CanonicalR(M', W)), see QuotientDensity.lean which proves this at the quotient
level using Mathlib's Antisymmetrization. The MCS-level strict density attempts
are archived in Boneyard/Task956_StrictDensity/.

## References

- Task 957: density_frame_condition (reflexive temporal semantics)
- research-001 through research-004 (density frame condition analysis)
- SeparationLemma.lean: distinguishing_formula_exists, not_G_implies_F_neg
- StagedExecution.lean: canonical_forward_reachable_linear
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

/-!
## Case B Helper Lemmas

When G(delta) in M (Case B), G(neg(delta)) cannot also be in M
(under CanonicalR(M, M')), because this would place both delta and
neg(delta) in M'.

Key property: In Case B, M is NOT reflexive, because:
- G(delta) ∈ M implies delta ∈ GContent(M)
- If M were reflexive, GContent(M) ⊆ M, so delta ∈ M
- But delta ∉ M (distinguishing formula), contradiction
-/

/--
In Case B (G(delta) ∈ M with delta ∉ M), M is NOT reflexive.
This is a key property for strict density proofs.
-/
theorem caseB_M_not_reflexive
    {M : Set Formula} {delta : Formula}
    (h_mcs : SetMaximalConsistent M)
    (h_G_delta_M : Formula.all_future delta ∈ M)
    (h_delta_not_M : delta ∉ M) :
    ¬CanonicalR M M := by
  intro h_refl
  have h_delta_M : delta ∈ M := h_refl h_G_delta_M
  exact h_delta_not_M h_delta_M

/--
In Case B (G(delta) in M with CanonicalR(M, M')), G(neg(delta)) is not in M.

Proof: If G(neg(delta)) in M, then neg(delta) in GContent(M) subset M'.
Also G(delta) in M gives delta in GContent(M) subset M'.
So both delta and neg(delta) in M', contradicting M' consistency.
-/
theorem caseB_G_neg_not_in_M
    {M M' : Set Formula} {delta : Formula}
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_G_delta_M : Formula.all_future delta ∈ M) :
    Formula.all_future (Formula.neg delta) ∉ M := by
  intro h_G_neg
  have h_delta_M' : delta ∈ M' := h_R h_G_delta_M
  have h_neg_delta_M' : Formula.neg delta ∈ M' := h_R h_G_neg
  exact set_consistent_not_both h_mcs'.1 delta h_delta_M' h_neg_delta_M'

/-!
## Double-Density Core Lemma

The key lemma: given F(neg(delta)) in M, construct two layers of witnesses
using density and forward witness construction, then apply temporal linearity.
This handles both sub-case 1 (delta in M') and sub-case 2 (delta not in M').
-/

/--
Core intermediate construction via double density.

Given:
- CanonicalR(M, M'), NOT CanonicalR(M', M)
- G(delta) in M', delta not in M
- F(neg(delta)) in M (Case A condition)

Then there exists W with CanonicalR(M, W) AND CanonicalR(W, M').

Strategy (double-density trick):
1. Density on F(neg(delta)): F(F(neg(delta))) in M. Get W_1 with
   CanonicalR(M, W_1) and F(neg(delta)) in W_1.
2. Forward witness from W_1 for neg(delta): Get V with
   CanonicalR(W_1, V) and neg(delta) in V.
3. CanonicalR(M, V) by transitivity.
4. Temporal linearity on M, V, M':
   - CanonicalR(M', V): delta in GContent(M') subset V, but
     neg(delta) in V. Contradiction.
   - CanonicalR(V, M'): V is intermediate.
   - V = M': CanonicalR(W_1, V) = CanonicalR(W_1, M'), so W_1 is intermediate.
-/
theorem density_frame_condition_caseA
    {M M' : Set Formula} {delta : Formula}
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_G_delta_M' : Formula.all_future delta ∈ M')
    (h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' := by
  -- Step 1: Density on F(neg(delta)) gives F(F(neg(delta))) in M
  -- Then get W_1 with CanonicalR(M, W_1) and F(neg(delta)) in W_1
  obtain ⟨W₁, h_W₁_mcs, h_R_MW₁, h_F_neg_W₁⟩ :=
    density_of_canonicalR M h_mcs (Formula.neg delta) h_F_neg_delta
  -- Step 2: Forward witness from W_1 for neg(delta)
  -- F(neg(delta)) in W_1, so get V with CanonicalR(W_1, V) and neg(delta) in V
  obtain ⟨V, h_V_mcs, h_R_W₁V, h_neg_delta_V⟩ :=
    canonical_forward_F W₁ h_W₁_mcs (Formula.neg delta) h_F_neg_W₁
  -- Step 3: CanonicalR(M, V) by transitivity
  have h_R_MV : CanonicalR M V := canonicalR_transitive M W₁ V h_mcs h_R_MW₁ h_R_W₁V
  -- Step 4: Temporal linearity on M, V, M'
  have h_lin := canonical_forward_reachable_linear M V M' h_mcs h_V_mcs h_mcs' h_R_MV h_R
  rcases h_lin with h_VM' | h_M'V | h_eq
  · -- CanonicalR(V, M'): V is the intermediate
    exact ⟨V, h_V_mcs, h_R_MV, h_VM'⟩
  · -- CanonicalR(M', V): delta in GContent(M') subset V, neg(delta) in V. Contradiction.
    exfalso
    have h_delta_GContent : delta ∈ GContent M' := h_G_delta_M'
    have h_delta_V : delta ∈ V := h_M'V h_delta_GContent
    exact set_consistent_not_both h_V_mcs.1 delta h_delta_V h_neg_delta_V
  · -- V = M': CanonicalR(W_1, V) = CanonicalR(W_1, M'), so W_1 is intermediate
    rw [h_eq] at h_R_W₁V
    exact ⟨W₁, h_W₁_mcs, h_R_MW₁, h_R_W₁V⟩

/-!
## Main Density Frame Condition

Combines Case A and Case B analysis.

- **Case A** (G(delta) not in M): Apply double-density trick directly
  with F(neg(delta)) in M. Fully proven by `density_frame_condition_caseA`.

- **Case B** (G(delta) in M, delta not in M): Two sub-cases:
  - **B1** (CanonicalR(M', M') holds): Take W = M' directly. Both
    CanonicalR(M, M') (given) and CanonicalR(M', M') (sub-case) hold.
  - **B2** (CanonicalR(M', M') fails): Since GContent(M') is not a subset
    of M', there exists gamma with G(gamma) in M' and gamma not in M'.
    Crucially, G(gamma) cannot be in M: if it were, gamma would be in
    GContent(M) subset M' (by CanonicalR(M, M')), contradicting gamma
    not in M'. So G(gamma) not in M, giving F(neg(gamma)) in M. This
    is exactly the Case A setup with gamma, so we apply Case A.
-/

/--
The density frame condition under reflexive temporal semantics.

For all MCSs M, M' with CanonicalR(M, M') and NOT CanonicalR(M', M),
there exists an intermediate MCS W with CanonicalR(M, W) AND CanonicalR(W, M').

The proof does not require the IRR rule -- it uses a purely syntactic argument
that reduces Case B to Case A by finding an alternative distinguishing formula
from GContent(M') that is not in M'.
-/
theorem density_frame_condition
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' := by
  -- Step 1: Get distinguishing formula delta with G(delta) in M' and delta not in M
  obtain ⟨delta, h_G_delta_M', h_delta_not_M⟩ :=
    distinguishing_formula_exists h_mcs h_mcs' h_not_R'
  -- Step 2: Case split on G(delta) in M
  by_cases h_G_delta_M : Formula.all_future delta ∈ M
  · -- Case B: G(delta) in M, delta not in M
    -- Sub-case split on whether M' is reflexive (CanonicalR(M', M')).
    by_cases h_R'_self : CanonicalR M' M'
    · -- Sub-case B1: CanonicalR(M', M') holds.
      -- Take W = M'. Then CanonicalR(M, M') (given) and CanonicalR(M', M') hold.
      exact ⟨M', h_mcs', h_R, h_R'_self⟩
    · -- Sub-case B2: CanonicalR(M', M') does not hold.
      -- ¬(GContent(M') ⊆ M'), so ∃ gamma with G(gamma) ∈ M' and gamma ∉ M'.
      rw [CanonicalR, Set.not_subset] at h_R'_self
      obtain ⟨gamma, h_gamma_GContent, h_gamma_not_M'⟩ := h_R'_self
      -- gamma ∈ GContent(M') means G(gamma) ∈ M'
      have h_G_gamma_M' : Formula.all_future gamma ∈ M' := h_gamma_GContent
      -- Claim: G(gamma) ∉ M.
      -- Proof: If G(gamma) ∈ M, then gamma ∈ GContent(M) ⊆ M' (by CanonicalR(M, M')).
      -- But gamma ∉ M'. Contradiction.
      have h_G_gamma_not_M : Formula.all_future gamma ∉ M := by
        intro h_G_gamma_M
        have h_gamma_M' : gamma ∈ M' := h_R h_G_gamma_M
        exact h_gamma_not_M' h_gamma_M'
      -- G(gamma) ∉ M gives F(neg(gamma)) ∈ M by not_G_implies_F_neg
      have h_F_neg_gamma : Formula.some_future (Formula.neg gamma) ∈ M :=
        not_G_implies_F_neg h_mcs h_G_gamma_not_M
      -- Apply the Case A core lemma with gamma
      exact density_frame_condition_caseA h_mcs h_mcs' h_R h_G_gamma_M' h_F_neg_gamma
  · -- Case A: G(delta) not in M
    -- F(neg(delta)) in M by not_G_implies_F_neg
    have h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M :=
      not_G_implies_F_neg h_mcs h_G_delta_M
    -- Apply the Case A core lemma
    exact density_frame_condition_caseA h_mcs h_mcs' h_R h_G_delta_M' h_F_neg_delta

/-!
## Helper: Irreflexive MCS has Strict Seriality Future

If M is not reflexive (¬CanonicalR M M), then the seriality witness W
satisfies ¬CanonicalR W M (strict future). This is because:
1. If ¬CanonicalR M M, then ∃ phi with G(phi) ∈ M and phi ∉ M
2. The seriality witness W ⊇ GContent(M), so phi ∈ W
3. By Temporal 4, G(phi) ∈ GContent(M) ⊆ W, so G(phi) ∈ W
4. Therefore phi ∈ GContent(W), but phi ∉ M
5. So GContent(W) ⊄ M, hence ¬CanonicalR W M
-/

/--
If M is not reflexive, then its seriality future W is strict: ¬CanonicalR W M.
-/
theorem irreflexive_mcs_has_strict_future
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_not_refl : ¬CanonicalR M M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ ¬CanonicalR W M := by
  -- Get the seriality witness
  obtain ⟨W, h_W_mcs, h_R_MW⟩ := mcs_has_strict_future M h_mcs
  refine ⟨W, h_W_mcs, h_R_MW, ?_⟩
  -- Show ¬CanonicalR W M using the irreflexivity witness
  rw [CanonicalR, Set.not_subset] at h_not_refl ⊢
  obtain ⟨phi, h_phi_GContent, h_phi_not_M⟩ := h_not_refl
  -- phi ∈ GContent(M), so G(phi) ∈ M
  -- By Temporal 4: G(phi) → G(G(phi)), so G(G(phi)) ∈ M
  -- Therefore G(phi) ∈ GContent(M) ⊆ W
  have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 phi)
  have h_GG_phi_M : Formula.all_future (Formula.all_future phi) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_phi_GContent
  -- G(phi) ∈ GContent(M) ⊆ W
  have h_G_phi_W : Formula.all_future phi ∈ W := h_R_MW h_GG_phi_M
  -- phi ∈ GContent(W) because G(phi) ∈ W
  exact ⟨phi, h_G_phi_W, h_phi_not_M⟩

/-!
## Strict Density Lemmas

When the source M is reflexive, density_frame_condition always gives a STRICT
intermediate: one that is not equivalent to the target (¬CanonicalR M' W).

The key insight: M reflexive + G(δ) ∈ M → δ ∈ M. So for any distinguishing
formula δ (where δ ∉ M), we must have G(δ) ∉ M, forcing Case A. The Case A
construction via double-density always produces a strict intermediate.
-/

/-- G(δ) ∈ W and F(¬δ) ∈ W is inconsistent: □δ and ◇¬δ cannot coexist in an MCS.
    This follows from the duality: G(δ) → G(¬¬δ), and F(¬δ) = ¬G(¬¬δ). -/
private theorem G_F_neg_inconsistent
    {W : Set Formula} {delta : Formula}
    (h_W_mcs : SetMaximalConsistent W)
    (h_G_delta : Formula.all_future delta ∈ W)
    (h_F_neg : Formula.some_future (Formula.neg delta) ∈ W) : False := by
  -- Step 1: δ → ¬¬δ is a theorem (double negation introduction)
  have h_dni : [] ⊢ delta.imp (Formula.neg (Formula.neg delta)) := dni_theorem delta
  -- Step 2: G(δ → ¬¬δ) by temporal necessitation
  have h_G_dni : [] ⊢ Formula.all_future (delta.imp (Formula.neg (Formula.neg delta))) :=
    DerivationTree.temporal_necessitation _ h_dni
  -- Step 3: G(δ → ¬¬δ) → (G(δ) → G(¬¬δ)) by temporal K distribution
  have h_K : [] ⊢ (Formula.all_future (delta.imp (Formula.neg (Formula.neg delta)))).imp
      ((Formula.all_future delta).imp (Formula.all_future (Formula.neg (Formula.neg delta)))) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist delta (Formula.neg (Formula.neg delta)))
  -- Step 4: G(δ) → G(¬¬δ)
  have h_imp : [] ⊢ (Formula.all_future delta).imp (Formula.all_future (Formula.neg (Formula.neg delta))) :=
    DerivationTree.modus_ponens [] _ _ h_K h_G_dni
  -- Step 5: G(¬¬δ) ∈ W
  have h_G_nn : Formula.all_future (Formula.neg (Formula.neg delta)) ∈ W :=
    set_mcs_implication_property h_W_mcs (theorem_in_mcs h_W_mcs h_imp) h_G_delta
  -- Step 6: F(¬δ) = ¬G(¬¬δ) definitionally. So ¬G(¬¬δ) ∈ W.
  -- F(¬δ) = some_future(neg δ) = neg(all_future(neg(neg δ))) = neg(G(¬¬δ))
  -- So h_F_neg : neg(all_future(neg(neg delta))) ∈ W
  -- And h_G_nn : all_future(neg(neg delta)) ∈ W
  -- Contradiction by consistency
  exact set_consistent_not_both h_W_mcs.1 (Formula.all_future (Formula.neg (Formula.neg delta))) h_G_nn h_F_neg

/-- Strengthened Case A: when we have F(¬delta) ∈ M and G(delta) ∈ M',
    the density intermediate is STRICT: ¬CanonicalR(M', W).
    The strictness comes from ¬delta in V contradicting delta from GContent(M'),
    and the G/F duality making CanonicalR(M', W₁) impossible. -/
theorem density_frame_condition_caseA_strict
    {M M' : Set Formula} {delta : Formula}
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_G_delta_M' : Formula.all_future delta ∈ M')
    (h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR M' W := by
  -- Step 1: Density gives W₁ with CanonicalR(M, W₁) and F(¬delta) ∈ W₁
  obtain ⟨W₁, h_W₁_mcs, h_R_MW₁, h_F_neg_W₁⟩ :=
    density_of_canonicalR M h_mcs (Formula.neg delta) h_F_neg_delta
  -- Step 2: Forward witness gives V with CanonicalR(W₁, V) and ¬delta ∈ V
  obtain ⟨V, h_V_mcs, h_R_W₁V, h_neg_delta_V⟩ :=
    canonical_forward_F W₁ h_W₁_mcs (Formula.neg delta) h_F_neg_W₁
  -- Step 3: CanonicalR(M, V) by transitivity
  have h_R_MV : CanonicalR M V := canonicalR_transitive M W₁ V h_mcs h_R_MW₁ h_R_W₁V
  -- Key: ¬CanonicalR(M', V) because delta and ¬delta would coexist in V
  have h_not_M'V : ¬CanonicalR M' V := by
    intro h_R'V
    exact set_consistent_not_both h_V_mcs.1 delta (h_R'V h_G_delta_M') h_neg_delta_V
  -- Key: CanonicalR(M', W₁) is impossible by G/F duality
  have h_not_M'W₁ : ¬CanonicalR M' W₁ := by
    intro h_R'W₁
    -- G(delta) ∈ M'. By T4: G(G(delta)) ∈ M'. So G(delta) ∈ GContent(M') ⊆ W₁.
    have h_T4 : [] ⊢ (Formula.all_future delta).imp (Formula.all_future (Formula.all_future delta)) :=
      DerivationTree.axiom [] _ (Axiom.temp_4 delta)
    have h_GG : Formula.all_future (Formula.all_future delta) ∈ M' :=
      set_mcs_implication_property h_mcs' (theorem_in_mcs h_mcs' h_T4) h_G_delta_M'
    have h_G_W₁ : Formula.all_future delta ∈ W₁ := h_R'W₁ h_GG
    -- G(delta) ∈ W₁ and F(¬delta) ∈ W₁: contradiction by duality
    exact G_F_neg_inconsistent h_W₁_mcs h_G_W₁ h_F_neg_W₁
  -- Step 4: Linearity of V and M' from M
  have h_lin := canonical_forward_reachable_linear M V M' h_mcs h_V_mcs h_mcs' h_R_MV h_R
  rcases h_lin with h_VM' | h_M'V | h_eq
  · -- CanonicalR(V, M'): V is the strict intermediate
    exact ⟨V, h_V_mcs, h_R_MV, h_VM', h_not_M'V⟩
  · -- CanonicalR(M', V): impossible
    exact absurd h_M'V h_not_M'V
  · -- V = M': Use W₁ as intermediate instead
    -- W₁ has CanonicalR(M, W₁) and CanonicalR(W₁, M') (from h_eq and CanonicalR(W₁, V))
    rw [h_eq] at h_R_W₁V
    -- CanonicalR(W₁, M') = h_R_W₁V. ¬CanonicalR(M', W₁) = h_not_M'W₁.
    exact ⟨W₁, h_W₁_mcs, h_R_MW₁, h_R_W₁V, h_not_M'W₁⟩

/-- When the source M is reflexive, density always gives a STRICT intermediate. -/
theorem density_frame_condition_reflexive_source
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M)
    (h_M_refl : CanonicalR M M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR M' W := by
  -- Get distinguishing formula delta
  obtain ⟨delta, h_G_delta_M', h_delta_not_M⟩ :=
    distinguishing_formula_exists h_mcs h_mcs' h_not_R'
  -- M reflexive + G(delta) ∈ M → delta ∈ M. But delta ∉ M. So G(delta) ∉ M.
  have h_G_delta_not_M : Formula.all_future delta ∉ M := by
    intro h_G_delta_M
    exact h_delta_not_M (h_M_refl h_G_delta_M)
  -- Case A applies: F(¬delta) ∈ M
  have h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M :=
    not_G_implies_F_neg h_mcs h_G_delta_not_M
  -- Apply the strict Case A lemma
  exact density_frame_condition_caseA_strict h_mcs h_mcs' h_R h_G_delta_M' h_F_neg_delta

end Bimodal.Metalogic.StagedConstruction
