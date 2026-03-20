import Bimodal.Metalogic.Bundle.FlagBFMCS
import Bimodal.Metalogic.Bundle.FMCSTransfer
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Perpetuity.Bridge

/-!
# Truth Lemma for FlagBFMCS (Task 1003 Phase 3-4)

This module proves the truth lemma for FlagBFMCS, connecting MCS membership
to semantic truth in the Flag-indexed canonical model.

## Overview

The truth lemma states:

  phi in mcs(F, x) <-> satisfies_at B F x phi

where `satisfies_at` is the satisfaction relation for FlagBFMCS. This establishes
that MCS membership at a (Flag, element) position corresponds exactly to semantic
truth at that position in the FlagBFMCS model.

## Main Results

- `satisfies_at`: Satisfaction relation for FlagBFMCS
- `satisfies_at_iff_mem`: The main truth lemma (forward and backward)

## References

- FlagBFMCS.lean: FlagBFMCS structure and canonicalFlagBFMCS
- CanonicalConstruction.lean: Pattern for truth lemma proof
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Temporal Completeness Property (Task 1005)

For the truth lemma to work with cross-Flag temporal quantification,
we need B.flags to contain "enough" Flags so that every CanonicalMCS
is in some Flag in B.flags. This is trivially true when B.flags = Set.univ.
-/

/--
A FlagBFMCS is temporally complete if every CanonicalMCS is in some Flag in B.flags.

This property is required for the truth lemma's temporal cases (G and H),
where we need to find temporal witnesses (from canonical_forward_F/backward_P)
within B.flags.

Note: This is automatically satisfied when B.flags = Set.univ (all Flags).
-/
def FlagBFMCS.temporally_complete (B : FlagBFMCS) : Prop :=
  ∀ M : CanonicalMCS, ∃ F ∈ B.flags, M ∈ F

/--
Using all Flags (Set.univ) gives temporal completeness trivially.
-/
theorem allFlags_temporally_complete :
    ∀ M : CanonicalMCS, ∃ F ∈ (@Set.univ (Flag CanonicalMCS)), M ∈ F := by
  intro M
  obtain ⟨F, hM⟩ := canonicalMCS_in_some_flag M
  exact ⟨F, Set.mem_univ F, hM⟩

/--
The allFlagsBFMCS is temporally complete: every CanonicalMCS is in some Flag in B.flags.

This is trivially true since B.flags = Set.univ and canonicalMCS_in_some_flag
proves every CanonicalMCS is in some Flag.
-/
theorem allFlagsBFMCS_temporally_complete (M0 : CanonicalMCS) :
    (allFlagsBFMCS M0).temporally_complete := by
  intro M
  obtain ⟨F, hM⟩ := canonicalMCS_in_some_flag M
  exact ⟨F, Set.mem_univ F, hM⟩

/-!
## Cross-Flag Temporal Content Propagation (Task 1005)

These lemmas establish that G(phi) / H(phi) membership propagates across
the CanonicalMCS ordering, enabling cross-Flag temporal satisfaction.
-/

/--
G-content propagates through CanonicalMCS ordering:
If G(phi) is in M.world and M < M', then phi is in M'.world.

This follows from: M < M' implies CanonicalR M.world M'.world,
which means g_content(M.world) ⊆ M'.world. Since G(phi) ∈ M.world
means phi ∈ g_content(M.world), we get phi ∈ M'.world.
-/
theorem g_content_propagation (M M' : CanonicalMCS) (φ : Formula)
    (h_G : φ.all_future ∈ M.world) (h_lt : M < M') : φ ∈ M'.world := by
  have h_R : CanonicalR M.world M'.world := CanonicalMCS.canonicalR_of_lt M M' h_lt
  exact canonical_forward_G M.world M'.world h_R φ h_G

/--
H-content propagates through CanonicalMCS ordering (backwards):
If H(phi) is in M.world and M' < M, then phi is in M'.world.

This follows from: M' < M implies CanonicalR M'.world M.world,
and by g_content/h_content duality, h_content(M.world) ⊆ M'.world.
Since H(phi) ∈ M.world means phi ∈ h_content(M.world), we get phi ∈ M'.world.
-/
theorem h_content_propagation (M M' : CanonicalMCS) (φ : Formula)
    (h_H : φ.all_past ∈ M.world) (h_lt : M' < M) : φ ∈ M'.world := by
  have h_R : CanonicalR M'.world M.world := CanonicalMCS.canonicalR_of_lt M' M h_lt
  have h_R_past : CanonicalR_past M.world M'.world :=
    g_content_subset_implies_h_content_reverse M'.world M.world M'.is_mcs M.is_mcs h_R
  exact canonical_backward_H M.world M'.world h_R_past φ h_H

/-!
## Satisfaction Relation for FlagBFMCS

We define satisfaction at a position (F, x) in a FlagBFMCS.
-/

/--
Satisfaction at a position (F, x) in a FlagBFMCS.

This is defined by induction on formulas:
- Atoms: true iff the atom formula is in the MCS
- Bot: always false
- Implication: psi.imp chi satisfied iff psi not satisfied or chi satisfied
- Box: phi.box satisfied iff phi satisfied at all modally accessible positions
- G (all_future): phi.all_future satisfied iff phi satisfied at all strictly future positions
  **Cross-Flag**: Quantifies over ALL Flags in B.flags (Task 1005 fix)
- H (all_past): phi.all_past satisfied iff phi satisfied at all strictly past positions
  **Cross-Flag**: Quantifies over ALL Flags in B.flags (Task 1005 fix)
-/
def satisfies_at (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) : Formula → Prop
  | .atom p => Formula.atom p ∈ (chainFMCS F).mcs x
  | .bot => False
  | .imp ψ χ => satisfies_at B F hF x ψ → satisfies_at B F hF x χ
  | .box φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      MCSBoxContent x.val.world ⊆ MCSBoxContent x'.val.world →
      satisfies_at B F' hF' x' φ
  | .all_future φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      x.val < x'.val → satisfies_at B F' hF' x' φ
  | .all_past φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      x'.val < x.val → satisfies_at B F' hF' x' φ

/-!
## Truth Lemma: Base Cases

We prove the truth lemma case by case. The base cases (atom, bot) are immediate.
-/

/--
Truth lemma for atoms: atom(p) in MCS iff satisfied.
-/
theorem satisfies_at_atom_iff (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (p : Atom) :
    satisfies_at B F hF x (Formula.atom p) ↔ Formula.atom p ∈ (chainFMCS F).mcs x := by
  simp only [satisfies_at]

/--
Truth lemma for bot: bot is never in MCS (consistency) and never satisfied.
-/
theorem satisfies_at_bot_iff (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) :
    satisfies_at B F hF x Formula.bot ↔ Formula.bot ∈ (chainFMCS F).mcs x := by
  simp only [satisfies_at]
  constructor
  · intro h; exact False.elim h
  · intro h
    have h_mcs := chainFMCS_is_mcs F x
    -- Bot cannot be in a consistent set
    have h_cons := h_mcs.1
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    have h_sub : ∀ φ ∈ [Formula.bot], φ ∈ (chainFMCS F).mcs x := by simp [h]
    exact h_cons [Formula.bot] h_sub ⟨h_bot_deriv⟩

/-!
## Truth Lemma: Propositional Cases

The implication case requires showing both directions of the iff.
-/

/--
Truth lemma for implication (backward direction):
If psi.imp chi in MCS, then satisfied.
-/
theorem satisfies_at_imp_of_mem (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (ψ χ : Formula)
    (ih_psi : satisfies_at B F hF x ψ ↔ ψ ∈ (chainFMCS F).mcs x)
    (ih_chi : satisfies_at B F hF x χ ↔ χ ∈ (chainFMCS F).mcs x)
    (h_mem : ψ.imp χ ∈ (chainFMCS F).mcs x) :
    satisfies_at B F hF x (ψ.imp χ) := by
  simp only [satisfies_at]
  intro h_sat_psi
  rw [ih_chi]
  rw [ih_psi] at h_sat_psi
  have h_mcs := chainFMCS_is_mcs F x
  exact SetMaximalConsistent.implication_property h_mcs h_mem h_sat_psi

/--
Classical tautology: neg(psi -> chi) -> psi.
-/
private noncomputable def neg_imp_to_left (ψ χ : Formula) : [] ⊢ (ψ.imp χ).neg.imp ψ := by
  -- neg(psi -> chi) = (psi -> chi) -> bot
  -- We need: ((psi -> chi) -> bot) -> psi
  -- Proof: Assume neg(psi -> chi). Assume neg(psi).
  -- Then psi -> chi holds vacuously.
  -- But neg(psi -> chi), contradiction.
  -- So neg(neg psi), hence psi by DNE.

  -- Using classical logic from Peirce's law
  have h_peirce := Bimodal.Theorems.Propositional.peirce_axiom ψ χ
  -- Peirce: ((psi -> chi) -> psi) -> psi
  -- We need: neg(psi -> chi) -> psi

  -- Actually simpler: neg(psi -> chi) = psi /\ neg(chi) classically
  -- So neg(psi -> chi) -> psi is valid

  -- Approach: use efq_neg and contraposition
  -- If neg(psi), then psi -> chi (by efq_neg)
  -- Contrapositive: neg(psi -> chi) -> neg(neg(psi)) = psi (by DNE)

  -- From efq_neg: neg(A) -> (A -> B)
  have h_efq : [] ⊢ ψ.neg.imp (ψ.imp χ) :=
    Bimodal.Theorems.Propositional.efq_neg ψ χ

  -- Contrapositive: neg(psi -> chi) -> neg(neg psi)
  have h_contra : [] ⊢ (ψ.imp χ).neg.imp ψ.neg.neg :=
    Bimodal.Theorems.Propositional.contraposition h_efq

  -- DNE: neg(neg psi) -> psi
  have h_dne : [] ⊢ ψ.neg.neg.imp ψ :=
    Bimodal.Theorems.Propositional.double_negation ψ

  -- Compose: neg(psi -> chi) -> psi
  exact Bimodal.Theorems.Combinators.imp_trans h_contra h_dne

/--
Classical tautology: neg(psi -> chi) -> neg(chi).
-/
private noncomputable def neg_imp_to_right (ψ χ : Formula) : [] ⊢ (ψ.imp χ).neg.imp χ.neg := by
  -- neg(psi -> chi) = (psi -> chi) -> bot
  -- We need: ((psi -> chi) -> bot) -> (chi -> bot)

  -- Approach: chi -> (psi -> chi), so neg(psi -> chi) -> neg(chi)

  -- prop_s: chi -> (psi -> chi)
  have h_prop_s : [] ⊢ χ.imp (ψ.imp χ) :=
    DerivationTree.axiom [] _ (Axiom.prop_s χ ψ)

  -- Contrapositive: neg(psi -> chi) -> neg(chi)
  exact Bimodal.Theorems.Propositional.contraposition h_prop_s

/--
Truth lemma for implication (forward direction):
If satisfied, then psi.imp chi in MCS.
-/
theorem mem_of_satisfies_at_imp (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (ψ χ : Formula)
    (ih_psi : satisfies_at B F hF x ψ ↔ ψ ∈ (chainFMCS F).mcs x)
    (ih_chi : satisfies_at B F hF x χ ↔ χ ∈ (chainFMCS F).mcs x)
    (h_sat : satisfies_at B F hF x (ψ.imp χ)) :
    ψ.imp χ ∈ (chainFMCS F).mcs x := by
  have h_mcs := chainFMCS_is_mcs F x
  rcases SetMaximalConsistent.negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
  · exact h_imp
  · -- Assume neg(psi.imp chi) in MCS, derive contradiction
    have h_deriv_psi : [] ⊢ (ψ.imp χ).neg.imp ψ := neg_imp_to_left ψ χ
    have h_thm_psi := theorem_in_mcs h_mcs h_deriv_psi
    have h_psi_mem : ψ ∈ (chainFMCS F).mcs x :=
      SetMaximalConsistent.implication_property h_mcs h_thm_psi h_neg_imp

    have h_deriv_neg_chi : [] ⊢ (ψ.imp χ).neg.imp χ.neg := neg_imp_to_right ψ χ
    have h_thm_neg_chi := theorem_in_mcs h_mcs h_deriv_neg_chi
    have h_neg_chi_mem : χ.neg ∈ (chainFMCS F).mcs x :=
      SetMaximalConsistent.implication_property h_mcs h_thm_neg_chi h_neg_imp

    simp only [satisfies_at] at h_sat
    have h_sat_psi : satisfies_at B F hF x ψ := ih_psi.mpr h_psi_mem
    have h_sat_chi : satisfies_at B F hF x χ := h_sat h_sat_psi
    have h_chi_mem : χ ∈ (chainFMCS F).mcs x := ih_chi.mp h_sat_chi

    exact False.elim (set_consistent_not_both h_mcs.1 χ h_chi_mem h_neg_chi_mem)

/-!
## Truth Lemma: Temporal Cases

The temporal cases use the chainFMCS forward_G and backward_H properties.
-/

/--
Truth lemma for G (all_future) backward: G phi in MCS implies satisfied.

**Cross-Flag version (Task 1005)**: Now quantifies over all Flags in B.flags.
Uses g_content_propagation to bridge from G(phi) in x.val.world to phi in x'.val.world.
-/
theorem satisfies_at_all_future_of_mem (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (φ : Formula)
    (ih : ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      satisfies_at B F' hF' x' φ ↔ φ ∈ (chainFMCS F').mcs x')
    (h_mem : φ.all_future ∈ (chainFMCS F).mcs x) :
    satisfies_at B F hF x φ.all_future := by
  simp only [satisfies_at]
  intro F' hF' x' h_lt
  rw [ih F' hF' x']
  -- G(φ) ∈ x.val.world and x.val < x'.val, so φ ∈ x'.val.world
  simp only [chainFMCS, chainFMCS_mcs]
  simp only [chainFMCS, chainFMCS_mcs] at h_mem
  exact g_content_propagation x.val x'.val φ h_mem h_lt

/--
Truth lemma for G (all_future) forward: satisfied implies G phi in MCS.

**Cross-Flag version (Task 1005)**: Now uses cross-Flag IH and quantification.

The contrapositive argument:
1. Assume neg(G phi) in MCS at x, i.e., F(neg phi) in x.val.world
2. By canonical_forward_F, get witness s : CanonicalMCS with x.val < s and neg(phi) in s.world
3. By Zorn (canonicalMCS_in_some_flag), s is in some Flag F'
4. Since h_sat quantifies over ALL Flags, we need F' ∈ B.flags

For this proof to work, we require B.flags to contain a Flag containing s.
This is guaranteed when B.flags = Set.univ (all Flags).
-/
theorem mem_of_satisfies_at_all_future (B : FlagBFMCS) (h_complete : B.temporally_complete)
    (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (φ : Formula)
    (ih : ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      satisfies_at B F' hF' x' φ ↔ φ ∈ (chainFMCS F').mcs x')
    (h_sat : satisfies_at B F hF x φ.all_future) :
    φ.all_future ∈ (chainFMCS F).mcs x := by
  have h_mcs := chainFMCS_is_mcs F x
  rcases SetMaximalConsistent.negation_complete h_mcs φ.all_future with h_G | h_neg_G
  · exact h_G
  · -- Contrapositive: neg(G phi) in MCS, derive contradiction
    -- Step 1: neg(G phi) implies F(neg phi) by temporal duality
    simp only [chainFMCS_mcs] at h_neg_G
    have h_F : (φ.neg).some_future ∈ x.val.world :=
      neg_all_future_to_some_future_neg x.val.world x.val.is_mcs φ h_neg_G

    -- Step 2: Get witness s in CanonicalMCS with neg(phi) in s.world
    obtain ⟨W, h_W_mcs, h_R, h_neg_phi⟩ := canonical_forward_F x.val.world x.val.is_mcs φ.neg h_F
    let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
    have h_lt : x.val < s := CanonicalMCS.lt_of_canonicalR x.val s h_R

    -- Step 3: s is in some Flag F' in B.flags (by temporal completeness)
    obtain ⟨F', hF', h_s_in_F'⟩ := h_complete s

    -- Step 4: Construct position x' in F' corresponding to s
    let x' : ChainFMCSDomain F' := ⟨s, h_s_in_F'⟩

    -- Step 5: By h_sat (cross-Flag), phi must be satisfied at x'
    simp only [satisfies_at] at h_sat
    have h_sat_x' : satisfies_at B F' hF' x' φ := h_sat F' hF' x' h_lt

    -- Step 6: By IH, phi ∈ s.world
    have h_phi : φ ∈ s.world := by
      rw [ih F' hF' x'] at h_sat_x'
      simp only [chainFMCS, chainFMCS_mcs] at h_sat_x'
      exact h_sat_x'

    -- Step 7: Contradiction: both phi and neg(phi) in s.world
    exact absurd h_phi (set_consistent_not_both s.is_mcs.1 φ · h_neg_phi)

/--
Truth lemma for H (all_past) backward: H phi in MCS implies satisfied.

**Cross-Flag version (Task 1005)**: Now quantifies over all Flags in B.flags.
Uses h_content_propagation to bridge from H(phi) in x.val.world to phi in x'.val.world.
-/
theorem satisfies_at_all_past_of_mem (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (φ : Formula)
    (ih : ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      satisfies_at B F' hF' x' φ ↔ φ ∈ (chainFMCS F').mcs x')
    (h_mem : φ.all_past ∈ (chainFMCS F).mcs x) :
    satisfies_at B F hF x φ.all_past := by
  simp only [satisfies_at]
  intro F' hF' x' h_lt
  rw [ih F' hF' x']
  -- H(φ) ∈ x.val.world and x'.val < x.val, so φ ∈ x'.val.world
  simp only [chainFMCS, chainFMCS_mcs]
  simp only [chainFMCS, chainFMCS_mcs] at h_mem
  exact h_content_propagation x.val x'.val φ h_mem h_lt

/--
Truth lemma for H (all_past) forward: satisfied implies H phi in MCS.

**Cross-Flag version (Task 1005)**: Symmetric to mem_of_satisfies_at_all_future.

The contrapositive argument:
1. Assume neg(H phi) in MCS at x, i.e., P(neg phi) in x.val.world
2. By canonical_backward_P, get witness s : CanonicalMCS with s < x.val and neg(phi) in s.world
3. By Zorn (canonicalMCS_in_some_flag), s is in some Flag F'
4. Since h_sat quantifies over ALL Flags, we need F' ∈ B.flags
-/
theorem mem_of_satisfies_at_all_past (B : FlagBFMCS) (h_complete : B.temporally_complete)
    (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (φ : Formula)
    (ih : ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      satisfies_at B F' hF' x' φ ↔ φ ∈ (chainFMCS F').mcs x')
    (h_sat : satisfies_at B F hF x φ.all_past) :
    φ.all_past ∈ (chainFMCS F).mcs x := by
  have h_mcs := chainFMCS_is_mcs F x
  rcases SetMaximalConsistent.negation_complete h_mcs φ.all_past with h_H | h_neg_H
  · exact h_H
  · -- Contrapositive: neg(H phi) in MCS, derive contradiction
    -- Step 1: neg(H phi) implies P(neg phi) by temporal duality
    simp only [chainFMCS_mcs] at h_neg_H
    have h_P : (φ.neg).some_past ∈ x.val.world :=
      neg_all_past_to_some_past_neg x.val.world x.val.is_mcs φ h_neg_H

    -- Step 2: Get witness s in CanonicalMCS with neg(phi) in s.world
    obtain ⟨W, h_W_mcs, h_R_past, h_neg_phi⟩ := canonical_backward_P x.val.world x.val.is_mcs φ.neg h_P
    let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
    have h_lt : s < x.val := CanonicalMCS.lt_of_canonicalR_past x.val s h_R_past

    -- Step 3: s is in some Flag F' in B.flags (by temporal completeness)
    obtain ⟨F', hF', h_s_in_F'⟩ := h_complete s

    -- Step 4: Construct position x' in F' corresponding to s
    let x' : ChainFMCSDomain F' := ⟨s, h_s_in_F'⟩

    -- Step 5: By h_sat (cross-Flag), phi must be satisfied at x'
    simp only [satisfies_at] at h_sat
    have h_sat_x' : satisfies_at B F' hF' x' φ := h_sat F' hF' x' h_lt

    -- Step 6: By IH, phi ∈ s.world
    have h_phi : φ ∈ s.world := by
      rw [ih F' hF' x'] at h_sat_x'
      simp only [chainFMCS, chainFMCS_mcs] at h_sat_x'
      exact h_sat_x'

    -- Step 7: Contradiction: both phi and neg(phi) in s.world
    exact absurd h_phi (set_consistent_not_both s.is_mcs.1 φ · h_neg_phi)

/-!
## Truth Lemma: Modal Cases

The Box case is the most complex, requiring modal coherence.
-/

/--
Truth lemma for Box backward: Box phi in MCS implies satisfied.
-/
theorem satisfies_at_box_of_mem (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (φ : Formula)
    (ih : ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      satisfies_at B F' hF' x' φ ↔ φ ∈ (chainFMCS F').mcs x')
    (h_mem : φ.box ∈ (chainFMCS F).mcs x) :
    satisfies_at B F hF x φ.box := by
  simp only [satisfies_at]
  intro F' hF' x' h_acc
  rw [ih F' hF' x']
  -- Box phi in x.mcs means phi in MCSBoxContent(x.world)
  have h_phi_in_boxcontent : φ ∈ MCSBoxContent x.val.world := by
    simp only [MCSBoxContent, Set.mem_setOf_eq]
    simp only [chainFMCS, chainFMCS_mcs] at h_mem
    exact h_mem

  -- By accessibility, phi in MCSBoxContent(x'.world)
  have h_phi_in_boxcontent' : φ ∈ MCSBoxContent x'.val.world := h_acc h_phi_in_boxcontent

  -- phi in BoxContent means Box phi in world
  simp only [MCSBoxContent, Set.mem_setOf_eq] at h_phi_in_boxcontent'

  -- Use T-axiom: Box phi -> phi
  have h_mcs' := chainFMCS_is_mcs F' x'
  have h_T : [] ⊢ φ.box.imp φ := DerivationTree.axiom [] _ (Axiom.modal_t φ)
  have h_T_in := theorem_in_mcs h_mcs' h_T
  simp only [chainFMCS, chainFMCS_mcs]
  exact SetMaximalConsistent.implication_property h_mcs' h_T_in h_phi_in_boxcontent'

/--
Truth lemma for Box forward: satisfied implies Box phi in MCS.

This uses modal saturation for the contrapositive argument.
-/
theorem mem_of_satisfies_at_box (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (φ : Formula)
    (ih : ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      satisfies_at B F' hF' x' φ ↔ φ ∈ (chainFMCS F').mcs x')
    (h_sat : satisfies_at B F hF x φ.box) :
    φ.box ∈ (chainFMCS F).mcs x := by
  have h_mcs := chainFMCS_is_mcs F x
  rcases SetMaximalConsistent.negation_complete h_mcs φ.box with h_box | h_neg_box
  · exact h_box
  · -- neg(Box phi) in MCS, derive contradiction
    -- Step 1: By modal duality, neg(Box phi) implies Diamond(neg phi)
    simp only [chainFMCS_mcs] at h_neg_box
    have h_duality : [] ⊢ φ.box.neg.imp φ.neg.diamond :=
      Bimodal.Theorems.Perpetuity.modal_duality_neg_rev φ
    have h_diamond : φ.neg.diamond ∈ x.val.world :=
      SetMaximalConsistent.implication_property x.val.is_mcs (theorem_in_mcs x.val.is_mcs h_duality) h_neg_box

    -- Step 2: By modally_saturated, get witness W with neg(phi) in W and BoxContent preserved
    obtain ⟨F', hF', W, hW_in_F', h_neg_phi, h_box_preserved⟩ :=
      B.modally_saturated F hF x.val (x.property) φ.neg h_diamond

    -- Step 3: Construct element x' in F' corresponding to W
    let x' : ChainFMCSDomain F' := ⟨W, hW_in_F'⟩

    -- Step 4: Show W is accessible from x
    -- We have: MCSBoxContent x.val.world ⊆ W.world
    -- We need: MCSBoxContent x.val.world ⊆ MCSBoxContent W.world
    -- This follows because if Box(psi) ∈ x.val.world, then psi ∈ MCSBoxContent x.val.world
    -- and by MCSBoxContent_closed_box, Box(psi) ∈ MCSBoxContent x.val.world
    -- so Box(psi) ∈ W.world, hence psi ∈ MCSBoxContent W.world
    have h_accessible : MCSBoxContent x.val.world ⊆ MCSBoxContent W.world := by
      intro psi h_psi_boxcontent
      simp only [MCSBoxContent, Set.mem_setOf_eq] at h_psi_boxcontent ⊢
      -- Box(psi) ∈ x.val.world, need Box(psi) ∈ W.world
      have h_box_psi_in_boxcontent : Formula.box psi ∈ MCSBoxContent x.val.world :=
        MCSBoxContent_closed_box x.val.world x.val.is_mcs psi h_psi_boxcontent
      exact h_box_preserved h_box_psi_in_boxcontent

    -- Step 5: By IH, satisfies_at ... x' phi <-> phi in W.world
    have h_ih_phi := ih F' hF' x'

    -- Step 6: phi not in W.world (since neg(phi) is in W.world and W is MCS)
    have h_phi_not_in_W : φ ∉ W.world := by
      intro h_phi
      exact set_consistent_not_both W.is_mcs.1 φ h_phi h_neg_phi

    -- Step 7: By IH, neg(satisfies_at)
    have h_not_sat : ¬satisfies_at B F' hF' x' φ := by
      intro h_sat'
      rw [h_ih_phi] at h_sat'
      simp only [chainFMCS, chainFMCS_mcs] at h_sat'
      exact h_phi_not_in_W h_sat'

    -- Step 8: But by h_sat and accessibility, satisfies_at holds
    simp only [satisfies_at] at h_sat
    have h_sat_at_x' : satisfies_at B F' hF' x' φ := h_sat F' hF' x' h_accessible

    -- Contradiction
    exact absurd h_sat_at_x' h_not_sat

/-!
## Main Truth Lemma (Combined)

The full truth lemma by induction on formula structure.
-/

/--
The main truth lemma for FlagBFMCS.

For any position (F, x) in a FlagBFMCS and any formula phi:
  phi in (chainFMCS F).mcs x ↔ satisfies_at B F hF x phi

This is proven by induction on the formula structure.

**Note (Task 1005)**: Requires `h_complete : B.temporally_complete` to ensure that
temporal witnesses (from F/P operators) can be found within B.flags.
-/
theorem satisfies_at_iff_mem (B : FlagBFMCS) (h_complete : B.temporally_complete)
    (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) (φ : Formula) :
    satisfies_at B F hF x φ ↔ φ ∈ (chainFMCS F).mcs x := by
  induction φ generalizing F x with
  | atom p =>
    exact satisfies_at_atom_iff B F hF x p
  | bot =>
    exact satisfies_at_bot_iff B F hF x
  | imp ψ χ ih_psi ih_chi =>
    constructor
    · exact mem_of_satisfies_at_imp B F hF x ψ χ (ih_psi F hF x) (ih_chi F hF x)
    · exact satisfies_at_imp_of_mem B F hF x ψ χ (ih_psi F hF x) (ih_chi F hF x)
  | box ψ ih =>
    constructor
    · exact mem_of_satisfies_at_box B F hF x ψ (fun F' hF' x' => ih F' hF' x')
    · exact satisfies_at_box_of_mem B F hF x ψ (fun F' hF' x' => ih F' hF' x')
  | all_future ψ ih =>
    constructor
    · exact mem_of_satisfies_at_all_future B h_complete F hF x ψ (fun F' hF' x' => ih F' hF' x')
    · exact satisfies_at_all_future_of_mem B F hF x ψ (fun F' hF' x' => ih F' hF' x')
  | all_past ψ ih =>
    constructor
    · exact mem_of_satisfies_at_all_past B h_complete F hF x ψ (fun F' hF' x' => ih F' hF' x')
    · exact satisfies_at_all_past_of_mem B F hF x ψ (fun F' hF' x' => ih F' hF' x')

end Bimodal.Metalogic.Bundle
