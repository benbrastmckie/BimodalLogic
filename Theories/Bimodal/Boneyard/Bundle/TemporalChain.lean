import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Temporal Chain Construction

This module builds an `IndexedMCSFamily Int` with temporal coherence properties,
working toward proving `temporal_coherent_family_exists` as a theorem.

## Construction Overview

Given a consistent context Gamma, we build an `IndexedMCSFamily Int` using two
Nat-indexed chains meeting at a shared base:

1. **Base**: Extend Gamma to MCS M_0 via standard Lindenbaum
2. **Forward chain** (non-negative indices): M_{n+1} extends TemporalContent(M_n)
3. **Backward chain** (negative indices): M_{-(n+1)} extends TemporalContent(M_{-n})

where TemporalContent(M) = GContent(M) ∪ HContent(M). Using the combined
TemporalContent seed ensures that BOTH G and H formulas propagate along each chain
in the direction of construction.

## Proven Properties

- `forward_G` for non-negative pairs: G phi ∈ M_t → phi ∈ M_{t'} for 0 ≤ t < t'
- `backward_H` for non-positive pairs: H phi ∈ M_t → phi ∈ M_{t'} for t' < t ≤ 0
- G and H formulas propagate forward in BOTH chains (via TemporalContent seeds)

## Technical Debt (4 sorries)

- `forward_G` when t < 0: 1 sorry (requires backward propagation through chain)
- `backward_H` when t ≥ 0: 1 sorry (requires backward propagation through chain)
- `forward_F`: 1 sorry (requires dovetailing witness construction)
- `backward_P`: 1 sorry (requires dovetailing witness construction)

### Why Cross-Sign Cases Cannot Be Proven with Two-Chain Construction

The cross-sign cases (forward_G when t < 0, backward_H when t ≥ 0) require formulas
to propagate AGAINST the direction of chain construction. Specifically:
- forward_G at t < 0: G phi in backward chain must yield phi at EARLIER chain indices
  (closer to time 0 or into the forward chain)
- backward_H at t ≥ 0: H phi in forward chain must yield phi at EARLIER chain indices
  (toward time 0 or into the backward chain)

Lindenbaum extension only propagates formulas FROM seed TO extension (increasing chain
index), never in the reverse direction. No choice of seed set (GContent, HContent,
or TemporalContent) can change this fundamental limitation.

Resolution requires either:
1. A dovetailing construction that interleaves forward/backward steps, or
2. A global selection argument (Zorn's lemma) that avoids chain construction entirely

## References

- Task 843 plan: specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-005.md
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## GContent and HContent Consistency
-/

/-- GContent(M) is a subset of M when M is an MCS (by T-axiom: G phi -> phi) -/
lemma GContent_subset_of_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    GContent M ⊆ M := by
  intro phi h_phi
  have h_G : Formula.all_future phi ∈ M := h_phi
  have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G

/-- HContent(M) is a subset of M when M is an MCS (by T-axiom: H phi -> phi) -/
lemma HContent_subset_of_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    HContent M ⊆ M := by
  intro phi h_phi
  have h_H : Formula.all_past phi ∈ M := h_phi
  have h_T := DerivationTree.axiom [] ((Formula.all_past phi).imp phi) (Axiom.temp_t_past phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H

/-- GContent(M) is consistent when M is an MCS -/
lemma GContent_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (GContent M) := by
  intro L hL ⟨d⟩
  have hL_in_M : ∀ x ∈ L, x ∈ M := fun x hx =>
    GContent_subset_of_mcs M h_mcs (hL x hx)
  exact h_mcs.1 L hL_in_M ⟨d⟩

/-- HContent(M) is consistent when M is an MCS -/
lemma HContent_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (HContent M) := by
  intro L hL ⟨d⟩
  have hL_in_M : ∀ x ∈ L, x ∈ M := fun x hx =>
    HContent_subset_of_mcs M h_mcs (hL x hx)
  exact h_mcs.1 L hL_in_M ⟨d⟩

/-!
## TemporalContent: Combined GContent ∪ HContent

Using TemporalContent as seed for both chains ensures that BOTH G and H formulas
propagate along each chain in the direction of construction. This means:
- Forward chain: G phi AND H phi propagate to higher indices (future times)
- Backward chain: G phi AND H phi propagate to higher indices (more negative times)

This is a structural improvement over using separate GContent/HContent seeds, and
provides the foundation for the eventual dovetailing construction.
-/

/-- TemporalContent(M) = GContent(M) ∪ HContent(M): all formulas accessible via G or H. -/
def TemporalContent (M : Set Formula) : Set Formula :=
  GContent M ∪ HContent M

/-- TemporalContent(M) is a subset of M when M is an MCS (by T-axioms). -/
lemma TemporalContent_subset_of_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    TemporalContent M ⊆ M := by
  intro phi h_phi
  rcases h_phi with h_g | h_h
  · exact GContent_subset_of_mcs M h_mcs h_g
  · exact HContent_subset_of_mcs M h_mcs h_h

/-- TemporalContent(M) is consistent when M is an MCS. -/
lemma TemporalContent_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (TemporalContent M) := by
  intro L hL ⟨d⟩
  have hL_in_M : ∀ x ∈ L, x ∈ M := fun x hx =>
    TemporalContent_subset_of_mcs M h_mcs (hL x hx)
  exact h_mcs.1 L hL_in_M ⟨d⟩

/-- GContent is a subset of TemporalContent. -/
lemma GContent_subset_TemporalContent (M : Set Formula) :
    GContent M ⊆ TemporalContent M :=
  Set.subset_union_left

/-- HContent is a subset of TemporalContent. -/
lemma HContent_subset_TemporalContent (M : Set Formula) :
    HContent M ⊆ TemporalContent M :=
  Set.subset_union_right

/-!
## Temporal 4-Axiom Lemmas
-/

/-- G phi ∈ M -> GG phi ∈ M (temporal 4-axiom) -/
lemma G_implies_GG_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    Formula.all_future (Formula.all_future phi) ∈ M := by
  have h_4 := DerivationTree.axiom [] ((Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)))
    (Axiom.temp_4 phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_4) h_G

/-- H phi ∈ M -> HH phi ∈ M (past 4-axiom) -/
lemma H_implies_HH_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_H : Formula.all_past phi ∈ M) :
    Formula.all_past (Formula.all_past phi) ∈ M := by
  have h_4 := temp_4_past phi
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_4) h_H

/-- G phi ∈ M implies G phi ∈ GContent(M) (by 4-axiom) -/
lemma G_in_GContent_of_G_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    Formula.all_future phi ∈ GContent M :=
  G_implies_GG_in_mcs M h_mcs phi h_G

/-- H phi ∈ M implies H phi ∈ HContent(M) (by 4-axiom) -/
lemma H_in_HContent_of_H_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_H : Formula.all_past phi ∈ M) :
    Formula.all_past phi ∈ HContent M :=
  H_implies_HH_in_mcs M h_mcs phi h_H

/-- G phi ∈ M implies G phi ∈ TemporalContent(M) (via GContent ⊆ TemporalContent). -/
lemma G_in_TemporalContent_of_G_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    Formula.all_future phi ∈ TemporalContent M :=
  GContent_subset_TemporalContent M (G_in_GContent_of_G_in_mcs M h_mcs phi h_G)

/-- H phi ∈ M implies H phi ∈ TemporalContent(M) (via HContent ⊆ TemporalContent). -/
lemma H_in_TemporalContent_of_H_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_H : Formula.all_past phi ∈ M) :
    Formula.all_past phi ∈ TemporalContent M :=
  HContent_subset_TemporalContent M (H_in_HContent_of_H_in_mcs M h_mcs phi h_H)

/-!
## Forward Chain Construction

Packaged (set, proof_mcs) pairs. Step 0 extends base, step n+1 extends TemporalContent(M_n).
Using TemporalContent (= GContent ∪ HContent) ensures both G and H formulas propagate.
-/

/-- Build the forward chain: step 0 extends base, step n+1 extends TemporalContent(M_n). -/
noncomputable def forwardChainMCS (base : Set Formula) (h_base_cons : SetConsistent base) :
    Nat → { M : Set Formula // SetMaximalConsistent M }
  | 0 =>
    let h := set_lindenbaum base h_base_cons
    ⟨Classical.choose h, (Classical.choose_spec h).2⟩
  | n + 1 =>
    let ⟨M_n, h_mcs_n⟩ := forwardChainMCS base h_base_cons n
    let h_tc_cons := TemporalContent_consistent M_n h_mcs_n
    let h := set_lindenbaum (TemporalContent M_n) h_tc_cons
    ⟨Classical.choose h, (Classical.choose_spec h).2⟩

/-- Build the backward chain: step 0 extends base, step n+1 extends TemporalContent(M_n). -/
noncomputable def backwardChainMCS (base : Set Formula) (h_base_cons : SetConsistent base) :
    Nat → { M : Set Formula // SetMaximalConsistent M }
  | 0 =>
    let h := set_lindenbaum base h_base_cons
    ⟨Classical.choose h, (Classical.choose_spec h).2⟩
  | n + 1 =>
    let ⟨M_n, h_mcs_n⟩ := backwardChainMCS base h_base_cons n
    let h_tc_cons := TemporalContent_consistent M_n h_mcs_n
    let h := set_lindenbaum (TemporalContent M_n) h_tc_cons
    ⟨Classical.choose h, (Classical.choose_spec h).2⟩

/-- Unified temporal chain: non-negative uses forward, negative uses backward. -/
noncomputable def temporalChainSet (base : Set Formula) (h_base_cons : SetConsistent base)
    (t : Int) : Set Formula :=
  if _ : 0 ≤ t then
    (forwardChainMCS base h_base_cons t.toNat).val
  else
    (backwardChainMCS base h_base_cons ((-t - 1).toNat)).val

/-!
## Basic Chain Properties
-/

lemma forwardChainMCS_is_mcs (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    SetMaximalConsistent (forwardChainMCS base h_base_cons n).val :=
  (forwardChainMCS base h_base_cons n).property

lemma backwardChainMCS_is_mcs (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    SetMaximalConsistent (backwardChainMCS base h_base_cons n).val :=
  (backwardChainMCS base h_base_cons n).property

lemma temporalChainSet_is_mcs (base : Set Formula) (h_base_cons : SetConsistent base) (t : Int) :
    SetMaximalConsistent (temporalChainSet base h_base_cons t) := by
  simp only [temporalChainSet]
  split
  · exact forwardChainMCS_is_mcs base h_base_cons t.toNat
  · exact backwardChainMCS_is_mcs base h_base_cons ((-t - 1).toNat)

lemma forwardChainMCS_zero_extends (base : Set Formula) (h_base_cons : SetConsistent base) :
    base ⊆ (forwardChainMCS base h_base_cons 0).val := by
  simp only [forwardChainMCS]
  exact (Classical.choose_spec (set_lindenbaum base h_base_cons)).1

lemma backwardChainMCS_zero_extends (base : Set Formula) (h_base_cons : SetConsistent base) :
    base ⊆ (backwardChainMCS base h_base_cons 0).val := by
  simp only [backwardChainMCS]
  exact (Classical.choose_spec (set_lindenbaum base h_base_cons)).1

lemma forwardChainMCS_TemporalContent_extends (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    TemporalContent (forwardChainMCS base h_base_cons n).val ⊆
      (forwardChainMCS base h_base_cons (n + 1)).val := by
  simp only [forwardChainMCS]
  let ⟨M_n, h_mcs_n⟩ := forwardChainMCS base h_base_cons n
  let h_tc_cons := TemporalContent_consistent M_n h_mcs_n
  exact (Classical.choose_spec (set_lindenbaum (TemporalContent M_n) h_tc_cons)).1

lemma forwardChainMCS_GContent_extends (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    GContent (forwardChainMCS base h_base_cons n).val ⊆
      (forwardChainMCS base h_base_cons (n + 1)).val := by
  intro phi h_phi
  exact forwardChainMCS_TemporalContent_extends base h_base_cons n
    (GContent_subset_TemporalContent _ h_phi)

lemma forwardChainMCS_HContent_extends (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    HContent (forwardChainMCS base h_base_cons n).val ⊆
      (forwardChainMCS base h_base_cons (n + 1)).val := by
  intro phi h_phi
  exact forwardChainMCS_TemporalContent_extends base h_base_cons n
    (HContent_subset_TemporalContent _ h_phi)

lemma backwardChainMCS_TemporalContent_extends (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    TemporalContent (backwardChainMCS base h_base_cons n).val ⊆
      (backwardChainMCS base h_base_cons (n + 1)).val := by
  simp only [backwardChainMCS]
  let ⟨M_n, h_mcs_n⟩ := backwardChainMCS base h_base_cons n
  let h_tc_cons := TemporalContent_consistent M_n h_mcs_n
  exact (Classical.choose_spec (set_lindenbaum (TemporalContent M_n) h_tc_cons)).1

lemma backwardChainMCS_GContent_extends (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    GContent (backwardChainMCS base h_base_cons n).val ⊆
      (backwardChainMCS base h_base_cons (n + 1)).val := by
  intro phi h_phi
  exact backwardChainMCS_TemporalContent_extends base h_base_cons n
    (GContent_subset_TemporalContent _ h_phi)

lemma backwardChainMCS_HContent_extends (base : Set Formula) (h_base_cons : SetConsistent base) (n : Nat) :
    HContent (backwardChainMCS base h_base_cons n).val ⊆
      (backwardChainMCS base h_base_cons (n + 1)).val := by
  intro phi h_phi
  exact backwardChainMCS_TemporalContent_extends base h_base_cons n
    (HContent_subset_TemporalContent _ h_phi)

/-!
## Forward G Coherence (Nat-indexed forward chain)
-/

lemma forwardChain_G_propagates (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (forwardChainMCS base h_base_cons n).val) :
    Formula.all_future phi ∈ (forwardChainMCS base h_base_cons (n + 1)).val := by
  have h_mcs_n := forwardChainMCS_is_mcs base h_base_cons n
  have h_in_gc := G_in_GContent_of_G_in_mcs _ h_mcs_n phi h_G
  exact forwardChainMCS_GContent_extends base h_base_cons n h_in_gc

lemma forwardChain_G_propagates_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (forwardChainMCS base h_base_cons m).val) :
    Formula.all_future phi ∈ (forwardChainMCS base h_base_cons n).val := by
  induction h_le with
  | refl => exact h_G
  | step _ ih => exact forwardChain_G_propagates base h_base_cons _ phi ih

lemma forwardChain_forward_G (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (forwardChainMCS base h_base_cons m).val) :
    phi ∈ (forwardChainMCS base h_base_cons n).val := by
  have h_G_n := forwardChain_G_propagates_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_G
  have h_mcs_n := forwardChainMCS_is_mcs base h_base_cons n
  have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
  exact set_mcs_implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_T) h_G_n

/-!
## Forward H Coherence (Nat-indexed forward chain)

With TemporalContent seeds, H formulas also propagate through the forward chain.
-/

lemma forwardChain_H_propagates (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (forwardChainMCS base h_base_cons n).val) :
    Formula.all_past phi ∈ (forwardChainMCS base h_base_cons (n + 1)).val := by
  have h_mcs_n := forwardChainMCS_is_mcs base h_base_cons n
  have h_in_hc := H_in_HContent_of_H_in_mcs _ h_mcs_n phi h_H
  exact forwardChainMCS_HContent_extends base h_base_cons n h_in_hc

lemma forwardChain_H_propagates_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (forwardChainMCS base h_base_cons m).val) :
    Formula.all_past phi ∈ (forwardChainMCS base h_base_cons n).val := by
  induction h_le with
  | refl => exact h_H
  | step _ ih => exact forwardChain_H_propagates base h_base_cons _ phi ih

lemma forwardChain_backward_H (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (forwardChainMCS base h_base_cons m).val) :
    phi ∈ (forwardChainMCS base h_base_cons n).val := by
  have h_H_n := forwardChain_H_propagates_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_H
  have h_mcs_n := forwardChainMCS_is_mcs base h_base_cons n
  have h_T := DerivationTree.axiom [] ((Formula.all_past phi).imp phi) (Axiom.temp_t_past phi)
  exact set_mcs_implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_T) h_H_n

/-!
## Backward H Coherence (Nat-indexed backward chain)
-/

lemma backwardChain_H_propagates (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (backwardChainMCS base h_base_cons n).val) :
    Formula.all_past phi ∈ (backwardChainMCS base h_base_cons (n + 1)).val := by
  have h_mcs_n := backwardChainMCS_is_mcs base h_base_cons n
  have h_HH := H_implies_HH_in_mcs _ h_mcs_n phi h_H
  have h_in_hc : Formula.all_past phi ∈ HContent (backwardChainMCS base h_base_cons n).val := h_HH
  exact backwardChainMCS_HContent_extends base h_base_cons n h_in_hc

lemma backwardChain_H_propagates_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (backwardChainMCS base h_base_cons m).val) :
    Formula.all_past phi ∈ (backwardChainMCS base h_base_cons n).val := by
  induction h_le with
  | refl => exact h_H
  | step _ ih => exact backwardChain_H_propagates base h_base_cons _ phi ih

lemma backwardChain_backward_H (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (backwardChainMCS base h_base_cons m).val) :
    phi ∈ (backwardChainMCS base h_base_cons n).val := by
  have h_H_n := backwardChain_H_propagates_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_H
  have h_mcs_n := backwardChainMCS_is_mcs base h_base_cons n
  have h_T := DerivationTree.axiom [] ((Formula.all_past phi).imp phi) (Axiom.temp_t_past phi)
  exact set_mcs_implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_T) h_H_n

/-!
## Backward G Coherence (Nat-indexed backward chain)

With TemporalContent seeds, G formulas also propagate through the backward chain.
-/

lemma backwardChain_G_propagates (base : Set Formula) (h_base_cons : SetConsistent base)
    (n : Nat) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (backwardChainMCS base h_base_cons n).val) :
    Formula.all_future phi ∈ (backwardChainMCS base h_base_cons (n + 1)).val := by
  have h_mcs_n := backwardChainMCS_is_mcs base h_base_cons n
  have h_in_gc := G_in_GContent_of_G_in_mcs _ h_mcs_n phi h_G
  exact backwardChainMCS_GContent_extends base h_base_cons n h_in_gc

lemma backwardChain_G_propagates_le (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (backwardChainMCS base h_base_cons m).val) :
    Formula.all_future phi ∈ (backwardChainMCS base h_base_cons n).val := by
  induction h_le with
  | refl => exact h_G
  | step _ ih => exact backwardChain_G_propagates base h_base_cons _ phi ih

lemma backwardChain_forward_G (base : Set Formula) (h_base_cons : SetConsistent base)
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (backwardChainMCS base h_base_cons m).val) :
    phi ∈ (backwardChainMCS base h_base_cons n).val := by
  have h_G_n := backwardChain_G_propagates_le base h_base_cons m n (Nat.le_of_lt h_lt) phi h_G
  have h_mcs_n := backwardChainMCS_is_mcs base h_base_cons n
  have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
  exact set_mcs_implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_T) h_G_n

/-!
## Int-indexed Coherence Proofs

Connect Nat-indexed proofs to Int-indexed temporalChainSet.
-/

/-- forward_G for non-negative Int indices -/
lemma temporalChainSet_forward_G_nonneg (base : Set Formula) (h_base_cons : SetConsistent base)
    (t t' : Int) (h_t_nn : 0 ≤ t) (h_t'_nn : 0 ≤ t') (h_lt : t < t')
    (phi : Formula) (h_G : Formula.all_future phi ∈ temporalChainSet base h_base_cons t) :
    phi ∈ temporalChainSet base h_base_cons t' := by
  simp only [temporalChainSet, h_t_nn, h_t'_nn, ↓reduceDIte] at h_G ⊢
  have h_lt_nat : t.toNat < t'.toNat := by
    rw [← Int.ofNat_lt]
    rwa [Int.toNat_of_nonneg h_t_nn, Int.toNat_of_nonneg h_t'_nn]
  exact forwardChain_forward_G base h_base_cons t.toNat t'.toNat h_lt_nat phi h_G

/-- backward_H for non-positive Int indices -/
lemma temporalChainSet_backward_H_nonpos (base : Set Formula) (h_base_cons : SetConsistent base)
    (t t' : Int) (h_t_neg : t < 0) (h_t'_neg : t' < 0) (h_lt : t' < t)
    (phi : Formula) (h_H : Formula.all_past phi ∈ temporalChainSet base h_base_cons t) :
    phi ∈ temporalChainSet base h_base_cons t' := by
  have h_t_not_nn : ¬(0 ≤ t) := not_le.mpr h_t_neg
  have h_t'_not_nn : ¬(0 ≤ t') := not_le.mpr h_t'_neg
  simp only [temporalChainSet, h_t_not_nn, h_t'_not_nn, ↓reduceDIte] at h_H ⊢
  have h_idx_lt : (-t - 1).toNat < (-t' - 1).toNat := by
    rw [← Int.ofNat_lt]
    rw [Int.toNat_of_nonneg (by omega), Int.toNat_of_nonneg (by omega)]
    omega
  exact backwardChain_backward_H base h_base_cons (-t - 1).toNat (-t' - 1).toNat h_idx_lt phi h_H

/-!
## Temporal Coherent Family Construction
-/

/--
Build a temporal coherent family from a consistent context.

**Proven cases**:
- forward_G for 0 ≤ t < t' (both non-negative, forward chain)
- backward_H for t' < t < 0 (both negative, backward chain)

**Technical debt** (4 sorries):
- forward_G when t < 0: requires backward chain propagation toward time 0
- backward_H when t ≥ 0: requires forward chain propagation toward time 0
- forward_F and backward_P: require dovetailing witness construction
-/
noncomputable def buildTemporalChainFamily (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    IndexedMCSFamily Int where
  mcs := fun t =>
    let base := contextAsSet Gamma
    let h_base_cons := list_consistent_to_set_consistent h_cons
    temporalChainSet base h_base_cons t
  is_mcs := fun t => by
    exact temporalChainSet_is_mcs (contextAsSet Gamma) (list_consistent_to_set_consistent h_cons) t
  forward_G := fun t t' phi h_lt h_G => by
    let base := contextAsSet Gamma
    let h_base_cons := list_consistent_to_set_consistent h_cons
    show phi ∈ temporalChainSet base h_base_cons t'
    have h_G' : Formula.all_future phi ∈ temporalChainSet base h_base_cons t := h_G
    by_cases h_t : 0 ≤ t
    · -- Both non-negative (t' > t >= 0)
      have h_t' : 0 ≤ t' := le_of_lt (lt_of_le_of_lt h_t h_lt)
      exact temporalChainSet_forward_G_nonneg base h_base_cons t t' h_t h_t' h_lt phi h_G'
    · -- t < 0: G phi in backward chain, need phi at later time.
      -- Requires backward propagation through the chain (from higher to lower
      -- Nat index in backward chain), which Lindenbaum extension does not support.
      -- Resolution requires dovetailing construction or global selection argument.
      push_neg at h_t
      sorry
  backward_H := fun t t' phi h_lt h_H => by
    let base := contextAsSet Gamma
    let h_base_cons := list_consistent_to_set_consistent h_cons
    show phi ∈ temporalChainSet base h_base_cons t'
    have h_H' : Formula.all_past phi ∈ temporalChainSet base h_base_cons t := h_H
    by_cases h_t : t < 0
    · -- Both negative (t' < t < 0)
      have h_t' : t' < 0 := lt_trans h_lt h_t
      exact temporalChainSet_backward_H_nonpos base h_base_cons t t' h_t h_t' h_lt phi h_H'
    · -- t >= 0: H phi in forward chain, need phi at earlier time.
      -- Requires backward propagation through the chain (from higher to lower
      -- Nat index in forward chain), which Lindenbaum extension does not support.
      -- Resolution requires dovetailing construction or global selection argument.
      push_neg at h_t
      sorry

/-- The temporal chain family preserves the context at time 0. -/
lemma buildTemporalChainFamily_preserves_context (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ gamma ∈ Gamma, gamma ∈ (buildTemporalChainFamily Gamma h_cons).mcs 0 := by
  intro gamma h_mem
  simp only [buildTemporalChainFamily, temporalChainSet]
  simp only [show (0 : Int) ≥ 0 from le_refl _, ↓reduceDIte, Int.toNat_zero]
  exact forwardChainMCS_zero_extends (contextAsSet Gamma)
    (list_consistent_to_set_consistent h_cons) h_mem

/-- forward_F (sorry -- requires dovetailing witness construction). -/
lemma buildTemporalChainFamily_forward_F (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ t : Int, ∀ φ : Formula,
      Formula.some_future φ ∈ (buildTemporalChainFamily Gamma h_cons).mcs t →
      ∃ s : Int, t < s ∧ φ ∈ (buildTemporalChainFamily Gamma h_cons).mcs s := by
  sorry

/-- backward_P (sorry -- requires dovetailing witness construction). -/
lemma buildTemporalChainFamily_backward_P (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ t : Int, ∀ φ : Formula,
      Formula.some_past φ ∈ (buildTemporalChainFamily Gamma h_cons).mcs t →
      ∃ s : Int, s < t ∧ φ ∈ (buildTemporalChainFamily Gamma h_cons).mcs s := by
  sorry

/--
Main theorem: temporal_coherent_family_exists for D = Int.

**Sorry inventory** (4 total in this theorem's transitive closure):
- forward_G when t < 0: 1 sorry (backward chain propagation toward zero)
- backward_H when t ≥ 0: 1 sorry (forward chain propagation toward zero)
- forward_F: 1 sorry (dovetailing witness construction)
- backward_P: 1 sorry (dovetailing witness construction)

All 4 sorries require a fundamentally different construction (dovetailing or
global selection) rather than the current two-chain Lindenbaum approach.
-/
theorem temporal_coherent_family_exists_Int
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : IndexedMCSFamily Int),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : Int, t < s ∧ φ ∈ fam.mcs s) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : Int, s < t ∧ φ ∈ fam.mcs s) := by
  use buildTemporalChainFamily Gamma h_cons
  exact ⟨buildTemporalChainFamily_preserves_context Gamma h_cons,
         buildTemporalChainFamily_forward_F Gamma h_cons,
         buildTemporalChainFamily_backward_P Gamma h_cons⟩

end Bimodal.Metalogic.Bundle
