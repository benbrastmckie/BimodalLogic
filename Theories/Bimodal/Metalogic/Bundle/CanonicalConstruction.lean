import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.TruthLemma
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.Truth
import Bimodal.Syntax.Formula

/-!
# Canonical Construction: Direct TruthLemma at TaskFrame Level

This module defines the canonical TaskFrame, TaskModel, world-histories, and Omega
for the direct TruthLemma connecting MCS membership to standard `truth_at` evaluation.

## Key Insight (research-006)

The intermediate `bmcs_truth_at` is structurally redundant -- it is definitionally
identical to `truth_at` when canonical definitions are chosen correctly. Therefore
we prove the TruthLemma directly at the `truth_at` level, eliminating the intermediate.

## Definitions

- `CanonicalWorldState`: Subtype of MCS (maximal consistent sets)
- `CanonicalTaskFrame`: TaskFrame Int with WorldState = CanonicalWorldState
- `CanonicalTaskModel`: TaskModel with valuation = MCS membership
- `to_history`: Convert FMCS to WorldHistory
- `CanonicalOmega`: Set of world-histories from bundle families

## Main Result

```
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

## References

- Task 945: Design canonical model construction for TruthLemma
- research-005.md: Step-by-step construction, D=Z
- research-006.md: Direct TruthLemma, bmcs_truth_at redundancy
-/

namespace Bimodal.Metalogic.Bundle.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Semantics

/-!
## Phase 1: Canonical Structures
-/

/--
Canonical world state: a maximal consistent set packaged as a subtype.

This is the WorldState of the canonical TaskFrame.
-/
def CanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }

/--
Canonical task relation between world states.

`canonical_task_rel M d N` holds iff:
- GContent(M.val) ⊆ N.val (forward coherence)
- HContent(N.val) ⊆ M.val (backward coherence)

Both conditions are required unconditionally (regardless of the sign of d).
This strengthened definition enables compositionality via uniform transitivity
arguments using `canonicalR_transitive` and `HContent_chain_transitive`.

The duration parameter `d` is present for TaskFrame compatibility but does not
affect the relation -- temporal content inclusion is sufficient.
-/
def canonical_task_rel (M : CanonicalWorldState) (_d : Int) (N : CanonicalWorldState) : Prop :=
  GContent M.val ⊆ N.val ∧ HContent N.val ⊆ M.val

/--
Nullity: canonical_task_rel M 0 M holds for any MCS M.

Both conditions hold by T-axioms:
- GContent(M) ⊆ M: by T-axiom G(phi) -> phi (canonicalR_reflexive)
- HContent(M) ⊆ M: by T-axiom H(phi) -> phi (canonicalR_past_reflexive)
-/
theorem canonical_task_rel_nullity (M : CanonicalWorldState) :
    canonical_task_rel M 0 M := by
  exact ⟨canonicalR_reflexive M.val M.property, canonicalR_past_reflexive M.val M.property⟩

/--
Compositionality: if canonical_task_rel M x N and canonical_task_rel N y V,
then canonical_task_rel M (x + y) V.

With the unconditional definition, this is a uniform two-line transitivity argument:
- Forward (GContent): `canonicalR_transitive` via Temporal 4 (G phi -> GG phi)
- Backward (HContent): `HContent_chain_transitive` via Temporal 4 past (H phi -> HH phi)

Note: task_rel does NOT appear in truth_at, so this proof is orthogonal
to the TruthLemma. It is needed only for well-typedness of the TaskFrame.
-/
theorem canonical_task_rel_compositionality
    (M N V : CanonicalWorldState) (x y : Int)
    (hMN : canonical_task_rel M x N) (hNV : canonical_task_rel N y V) :
    canonical_task_rel M (x + y) V := by
  obtain ⟨hMN_fwd, hMN_bwd⟩ := hMN
  obtain ⟨hNV_fwd, hNV_bwd⟩ := hNV
  constructor
  · -- GContent(M) ⊆ V via canonicalR_transitive
    exact canonicalR_transitive M.val N.val V.val M.property hMN_fwd hNV_fwd
  · -- HContent(V) ⊆ M via HContent_chain_transitive
    exact HContent_chain_transitive M.val N.val V.val V.property hNV_bwd hMN_bwd

/--
The canonical task frame for the direct TruthLemma.

WorldState = CanonicalWorldState (subtype of MCS)
task_rel = canonical_task_rel (GContent/HContent coherence, unconditional)
D = Int

Nullity via T-axioms (reflexivity), compositionality via Temporal 4 (transitivity).
-/
def CanonicalTaskFrame : TaskFrame Int where
  WorldState := CanonicalWorldState
  task_rel := canonical_task_rel
  nullity := canonical_task_rel_nullity
  compositionality := fun M N V x y hMN hNV =>
    canonical_task_rel_compositionality M N V x y hMN hNV

/--
The canonical task model: valuation is MCS membership.

An atom p is true at world-state M iff `atom p in M.val`.
-/
def CanonicalTaskModel : TaskModel CanonicalTaskFrame where
  valuation := fun M p => Formula.atom p ∈ M.val

/--
Convert an FMCS to a WorldHistory in the canonical TaskFrame.

- domain: full (every integer time is in the domain)
- states: the MCS at time t IS the world-state
- respects_task: follows from forward_G coherence + reflexivity

Key property: domain = fun _ => True eliminates all domain-related complexity.
-/
def to_history (fam : FMCS Int) : WorldHistory CanonicalTaskFrame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
  respects_task := by
    intro s t hs ht hst
    -- Need: canonical_task_rel (fam.mcs s, is_mcs s) (t - s) (fam.mcs t, is_mcs t)
    -- i.e., GContent(fam.mcs s) ⊆ fam.mcs t ∧ HContent(fam.mcs t) ⊆ fam.mcs s
    constructor
    · -- GContent(fam.mcs s) ⊆ fam.mcs t via forward_G with s ≤ t
      intro phi h_G_phi
      exact fam.forward_G s t phi hst h_G_phi
    · -- HContent(fam.mcs t) ⊆ fam.mcs s via backward_H with s ≤ t
      intro phi h_H_phi
      exact fam.backward_H t s phi hst h_H_phi

/--
The canonical Omega: the set of world-histories from bundle families.

CanonicalOmega B = { tau | exists fam in B.families, tau = to_history fam }

This set is NOT necessarily ShiftClosed. ShiftClosed is not needed for
the TruthLemma (only for the connection to standard validity).
-/
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | ∃ fam ∈ B.families, tau = to_history fam }

/-!
## Phase 2-5: The Direct TruthLemma
-/

/--
The direct canonical truth lemma: MCS membership corresponds to truth_at evaluation.

This is THE KEY THEOREM connecting the BFMCS construction to standard TaskFrame semantics.
It eliminates the bmcs_truth_at intermediate entirely.

The proof proceeds by structural induction on phi, with cases:
- atom: domain is full (True.intro), valuation = MCS membership
- bot: MCS consistency vs False
- imp: MCS modus ponens + negation completeness (uses IH in both directions)
- box: modal_forward/backward + IH
- all_future (G): forward_G + temporal_backward_G via h_tc
- all_past (H): backward_H + temporal_backward_H via h_tc
-/
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi := by
  induction phi generalizing fam t with
  | atom p =>
    -- atom case: phi in fam.mcs t <-> exists ht, M.valuation (tau.states t ht) p
    -- Since domain = True, ht = True.intro
    -- valuation (fam.mcs t, is_mcs t) p = (atom p in fam.mcs t)
    simp only [truth_at, CanonicalTaskModel, to_history]
    constructor
    · intro h_atom
      exact ⟨True.intro, h_atom⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    -- bot case: bot in fam.mcs t <-> False
    simp only [truth_at]
    constructor
    · intro h_bot
      -- bot in MCS contradicts consistency
      have h_cons := (fam.is_mcs t).1
      have h_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_bot) ⟨h_deriv⟩
    · intro h_false
      exact False.elim h_false
  | imp psi chi ih_psi ih_chi =>
    -- imp case: (psi -> chi) in MCS <-> (truth psi -> truth chi)
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · -- Forward: (psi -> chi) in MCS and truth psi -> truth chi
      intro h_imp h_psi_true
      -- By IH backward: psi in MCS
      have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true
      -- By MCS modus ponens: chi in MCS
      have h_chi_mcs : chi ∈ fam.mcs t := set_mcs_implication_property h_mcs h_imp h_psi_mcs
      -- By IH forward: truth chi
      exact (ih_chi fam hfam t).mp h_chi_mcs
    · -- Backward: (truth psi -> truth chi) -> (psi -> chi) in MCS
      intro h_truth_imp
      rcases set_mcs_negation_complete h_mcs (psi.imp chi) with h_imp | h_neg_imp
      · exact h_imp
      · -- neg(psi -> chi) in MCS - derive contradiction
        exfalso
        -- From neg(psi -> chi), we get psi in MCS and neg(chi) in MCS
        have h_psi_mcs : psi ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent psi chi
          exact set_mcs_closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_chi_mcs : chi.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent psi chi
          exact set_mcs_closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        -- By IH: psi is true
        have h_psi_true : truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t psi :=
          (ih_psi fam hfam t).mp h_psi_mcs
        -- By hypothesis: chi is true
        have h_chi_true : truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t chi :=
          h_truth_imp h_psi_true
        -- By IH: chi in MCS
        have h_chi_mcs : chi ∈ fam.mcs t := (ih_chi fam hfam t).mpr h_chi_true
        -- Contradiction: chi and neg(chi) in consistent MCS
        exact set_consistent_not_both (fam.is_mcs t).1 chi h_chi_mcs h_neg_chi_mcs
  | box psi ih =>
    -- box case: box psi in MCS <-> forall sigma in Omega, truth sigma t psi
    simp only [truth_at]
    constructor
    · -- Forward: box psi in MCS -> forall sigma in Omega, truth sigma t psi
      intro h_box sigma h_sigma_mem
      -- sigma in CanonicalOmega B means sigma = to_history fam' for some fam' in B.families
      obtain ⟨fam', hfam', h_eq⟩ := h_sigma_mem
      subst h_eq
      -- By modal_forward: psi in fam'.mcs t
      have h_psi_mcs : psi ∈ fam'.mcs t := B.modal_forward fam hfam psi t h_box fam' hfam'
      -- By IH: truth at fam'
      exact (ih fam' hfam' t).mp h_psi_mcs
    · -- Backward: forall sigma in Omega, truth sigma t psi -> box psi in MCS
      intro h_all
      -- For each fam' in B.families, to_history fam' is in CanonicalOmega
      -- By IH backward: psi in fam'.mcs t
      have h_psi_all_mcs : ∀ fam' ∈ B.families, psi ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_in_omega : to_history fam' ∈ CanonicalOmega B := ⟨fam', hfam', rfl⟩
        have h_truth := h_all (to_history fam') h_in_omega
        exact (ih fam' hfam' t).mpr h_truth
      -- By modal_backward: box psi in MCS
      exact B.modal_backward fam hfam psi t h_psi_all_mcs
  | all_future psi ih =>
    -- G case: G psi in MCS <-> forall s >= t, truth tau s psi
    simp only [truth_at]
    constructor
    · -- Forward: G psi in MCS -> forall s >= t, truth tau s psi
      intro h_G s hts
      -- By forward_G: psi in fam.mcs s
      have h_psi_mcs : psi ∈ fam.mcs s := fam.forward_G t s psi hts h_G
      -- By IH: truth at s
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: forall s >= t, truth tau s psi -> G psi in MCS
      intro h_all
      -- Extract forward_F and backward_P for this family from h_tc
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      -- Build a TemporalCoherentFamily
      let tcf : TemporalCoherentFamily Int := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      -- By IH backward: psi in fam.mcs s for all s >= t
      have h_all_mcs : ∀ s : Int, t ≤ s → psi ∈ fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s hts)
      -- Apply temporal_backward_G
      exact temporal_backward_G tcf t psi h_all_mcs
  | all_past psi ih =>
    -- H case: H psi in MCS <-> forall s <= t, truth tau s psi
    simp only [truth_at]
    constructor
    · -- Forward: H psi in MCS -> forall s <= t, truth tau s psi
      intro h_H s hst
      -- By backward_H: psi in fam.mcs s
      have h_psi_mcs : psi ∈ fam.mcs s := fam.backward_H t s psi hst h_H
      -- By IH: truth at s
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: forall s <= t, truth tau s psi -> H psi in MCS
      intro h_all
      -- Extract forward_F and backward_P for this family from h_tc
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      -- Build a TemporalCoherentFamily
      let tcf : TemporalCoherentFamily Int := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      -- By IH backward: psi in fam.mcs s for all s <= t
      have h_all_mcs : ∀ s : Int, s ≤ t → psi ∈ fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s hst)
      -- Apply temporal_backward_H
      exact temporal_backward_H tcf t psi h_all_mcs

end Bimodal.Metalogic.Bundle.Canonical
