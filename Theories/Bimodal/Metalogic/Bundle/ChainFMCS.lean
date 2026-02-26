import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.FMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.Perpetuity.Helpers
import Bimodal.Theorems.Perpetuity.Principles
import Mathlib.Order.Zorn

/-!
# BoxContent Infrastructure and Modal Witness Seeds (Task 925)

This module provides foundational lemmas for constructing modally saturated BFMCS
with temporal coherence. The key results are:

1. **BoxContent definitions and properties** (MCSBoxContent, BoxGContent)
2. **Modal witness seed consistency**: {psi} ∪ BoxContent(M) is consistent when
   Diamond(psi) ∈ M (essential for witness family construction)
3. **Diamond persistence through CanonicalR**: Diamond(psi) propagates through
   the temporal ordering (using S5 axiom 5 + MF axiom)
4. **BoxContent propagation**: BoxContent(M) ⊆ BoxContent(M') when CanonicalR M M'

These results are prerequisites for any approach to constructing a fully saturated
BFMCS (chain-based, embedding-based, or direct CanonicalMCS-based).

## Key Theorem: modal_witness_seed_consistent

If Diamond(psi) ∈ M for an MCS M, then {psi} ∪ BoxContent(M) is consistent.
This follows the same pattern as `temporal_witness_seed_consistent` in
TemporalCoherentConstruction.lean, using `generalized_modal_k` instead of
`generalized_temporal_k`.

## References

- Task 925 research-004.md: BoxGContent analysis and seed consistency
- ModalSaturation.lean: saturated_modal_backward, axiom 5
- CanonicalBFMCS.lean: Sorry-free temporal coherence
- TemporalCoherentConstruction.lean: temporal_witness_seed_consistent (analogous proof)
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## BoxContent Definitions and Basic Properties

BoxContent(M) = {phi | Box(phi) ∈ M} captures the modal content of an MCS.
In S5, BoxContent determines all Box-formula membership via axioms 4 and 5.
-/

/--
BoxContent of an MCS: formulas phi such that Box phi is in the MCS.

BoxContent(M) = {phi | Box(phi) ∈ M}
-/
def MCSBoxContent (M : Set Formula) : Set Formula :=
  {phi | Formula.box phi ∈ M}

/--
BoxContent is a subset of the MCS (by T-axiom: Box phi => phi).
-/
lemma MCSBoxContent_subset_self (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    MCSBoxContent M ⊆ M := by
  intro phi h_box
  simp only [MCSBoxContent, Set.mem_setOf_eq] at h_box
  have h_T : [] ⊢ (Formula.box phi).imp phi :=
    DerivationTree.axiom [] _ (Axiom.modal_t phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_box

/--
BoxContent propagation via S5 axiom 4: Box phi => Box(Box phi).

If phi ∈ BoxContent(M), then Box phi ∈ M, so Box(Box phi) ∈ M (by axiom 4),
hence Box phi ∈ BoxContent(M). This means BoxContent is closed under Box.
-/
lemma MCSBoxContent_closed_box (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_box : phi ∈ MCSBoxContent M) :
    Formula.box phi ∈ MCSBoxContent M := by
  simp only [MCSBoxContent, Set.mem_setOf_eq] at h_box ⊢
  -- Box phi ∈ M, need Box(Box phi) ∈ M
  -- By modal 4: ⊢ Box phi → Box(Box phi)
  have h_4 : [] ⊢ (Formula.box phi).imp (Formula.box (Formula.box phi)) :=
    DerivationTree.axiom [] _ (Axiom.modal_4 phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_4) h_box

/--
Negative introspection: neg(Box phi) ∈ M implies neg(Box phi) ∈ BoxContent(M).

By S5 axiom 5: neg(Box phi) → Box(neg(Box phi)), so Box(neg(Box phi)) ∈ M,
hence neg(Box phi) ∈ BoxContent(M).
-/
lemma neg_box_in_boxcontent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_box : (Formula.box phi).neg ∈ M) :
    (Formula.box phi).neg ∈ MCSBoxContent M := by
  simp only [MCSBoxContent, Set.mem_setOf_eq]
  exact mcs_neg_box_implies_box_neg_box h_mcs phi h_neg_box

/--
BoxContent propagates through CanonicalR: if CanonicalR M M', then
BoxContent(M) ⊆ BoxContent(M').

**Proof**: If Box phi ∈ M, by `temp_future` (Box phi → G(Box phi)),
G(Box phi) ∈ M. So Box phi ∈ GContent(M). Since CanonicalR M M'
means GContent(M) ⊆ M', we get Box phi ∈ M'. Hence phi ∈ BoxContent(M').
-/
theorem MCSBoxContent_subset_of_CanonicalR (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') :
    MCSBoxContent M ⊆ MCSBoxContent M' := by
  intro phi h_box
  simp only [MCSBoxContent, Set.mem_setOf_eq] at h_box ⊢
  -- Box phi ∈ M, need Box phi ∈ M'
  -- By temp_future axiom: Box phi → G(Box phi)
  have h_tf : [] ⊢ (Formula.box phi).imp (Formula.all_future (Formula.box phi)) :=
    DerivationTree.axiom [] _ (Axiom.temp_future phi)
  have h_G_box : Formula.all_future (Formula.box phi) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_tf) h_box
  -- G(Box phi) ∈ M means Box phi ∈ GContent(M)
  -- CanonicalR M M' means GContent(M) ⊆ M'
  -- So Box phi ∈ M'
  exact h_R h_G_box

/-!
## BoxGContent: Inter-History Step Relation

BoxGContent(M) = {phi | Box(G phi) ∈ M}

This sits between BoxContent and GContent in the inclusion hierarchy:
  MCSBoxContent(M) ⊆ BoxGContent(M) ⊆ GContent(M)

BoxGContent represents formulas that necessarily hold at all future times
in ALL histories, not just the current one. It is the semantically correct
seed for inter-history propagation.
-/

/--
BoxGContent of an MCS: formulas phi such that Box(G phi) is in the MCS.

BoxGContent(M) = {phi | Box(G phi) ∈ M}

This captures formulas that are necessarily always true in the future,
across all accessible worlds/histories.
-/
def BoxGContent (M : Set Formula) : Set Formula :=
  {phi | Formula.box (Formula.all_future phi) ∈ M}

/--
MCSBoxContent ⊆ BoxGContent: If Box phi ∈ M, then Box(G phi) ∈ M.

This follows from the MF axiom: Box phi → Box(G phi).
-/
lemma MCSBoxContent_subset_BoxGContent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    MCSBoxContent M ⊆ BoxGContent M := by
  intro phi h_box
  simp only [MCSBoxContent, Set.mem_setOf_eq] at h_box
  simp only [BoxGContent, Set.mem_setOf_eq]
  -- By MF axiom: Box phi → Box(G phi)
  have h_MF : [] ⊢ (Formula.box phi).imp (Formula.box (Formula.all_future phi)) :=
    DerivationTree.axiom [] _ (Axiom.modal_future phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_MF) h_box

/--
BoxGContent ⊆ GContent: If Box(G phi) ∈ M, then G phi ∈ M (hence phi ∈ GContent(M)).

This follows from the T-axiom: Box(G phi) → G phi.
-/
lemma BoxGContent_subset_GContent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    BoxGContent M ⊆ GContent M := by
  intro phi h_boxg
  simp only [BoxGContent, Set.mem_setOf_eq] at h_boxg
  simp only [GContent, Set.mem_setOf_eq]
  -- By T-axiom: Box(G phi) → G phi
  have h_T : [] ⊢ (Formula.box (Formula.all_future phi)).imp (Formula.all_future phi) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.all_future phi))
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_boxg

/--
The full hierarchy: MCSBoxContent(M) ⊆ BoxGContent(M) ⊆ GContent(M) ⊆ M.

Combining the individual inclusion lemmas.
-/
theorem boxcontent_hierarchy (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    MCSBoxContent M ⊆ BoxGContent M ∧
    BoxGContent M ⊆ GContent M ∧
    GContent M ⊆ M := by
  exact ⟨MCSBoxContent_subset_BoxGContent M h_mcs,
         BoxGContent_subset_GContent M h_mcs,
         fun phi h => by
           simp only [GContent, Set.mem_setOf_eq] at h
           have h_T : [] ⊢ (Formula.all_future phi).imp phi :=
             DerivationTree.axiom [] _ (Axiom.temp_t_future phi)
           exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h⟩

/-!
## BoxHContent: Past Analogue of BoxGContent

BoxHContent(M) = {phi | Box(H phi) ∈ M}

This sits between MCSBoxContent and HContent:
  MCSBoxContent(M) ⊆ BoxHContent(M) ⊆ HContent(M)
-/

/--
BoxHContent of an MCS: formulas phi such that Box(H phi) is in the MCS.

BoxHContent(M) = {phi | Box(H phi) ∈ M}

This is the past analogue of BoxGContent, capturing formulas that are
necessarily always true in the past across all accessible worlds.
-/
def BoxHContent (M : Set Formula) : Set Formula :=
  {phi | Formula.box (Formula.all_past phi) ∈ M}

/--
MCSBoxContent ⊆ BoxHContent: If Box phi ∈ M, then Box(H phi) ∈ M.

This follows from `box_to_box_past`: Box phi → Box(H phi), which is the
past analogue of the MF axiom.
-/
lemma MCSBoxContent_subset_BoxHContent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    MCSBoxContent M ⊆ BoxHContent M := by
  intro phi h_box
  simp only [MCSBoxContent, Set.mem_setOf_eq] at h_box
  simp only [BoxHContent, Set.mem_setOf_eq]
  -- By box_to_box_past: Box phi → Box(H phi)
  have h_MH : [] ⊢ (Formula.box phi).imp (Formula.box (Formula.all_past phi)) :=
    Bimodal.Theorems.Perpetuity.box_to_box_past phi
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_MH) h_box

/--
BoxHContent ⊆ HContent: If Box(H phi) ∈ M, then H phi ∈ M.

This follows from the T-axiom: Box(H phi) → H phi.
-/
lemma BoxHContent_subset_HContent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    BoxHContent M ⊆ HContent M := by
  intro phi h_boxh
  simp only [BoxHContent, Set.mem_setOf_eq] at h_boxh
  simp only [HContent, Set.mem_setOf_eq]
  have h_T : [] ⊢ (Formula.box (Formula.all_past phi)).imp (Formula.all_past phi) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.all_past phi))
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_boxh

/-!
## BoxGRelation: Inter-History Step Relation

BoxGRelation defines one-step modal-temporal accessibility:
  BoxGRelation M N := BoxGContent M ⊆ N

This is weaker than CanonicalR (which requires GContent M ⊆ N), since
BoxGContent ⊆ GContent. CanonicalR implies BoxGRelation but not vice versa.
-/

/--
BoxGRelation: the one-step inter-history accessibility relation.

M sees N via BoxGRelation when all formulas phi such that Box(G phi) ∈ M
are also in N.
-/
def BoxGRelation (M N : Set Formula) : Prop :=
  BoxGContent M ⊆ N

/--
CanonicalR implies BoxGRelation: the temporal accessibility is stronger
than the modal-temporal accessibility.

Since BoxGContent(M) ⊆ GContent(M), if GContent(M) ⊆ N (CanonicalR),
then BoxGContent(M) ⊆ N (BoxGRelation).
-/
theorem CanonicalR_implies_BoxGRelation (M N : Set Formula) (h_mcs : SetMaximalConsistent M) :
    CanonicalR M N → BoxGRelation M N := by
  intro h_R
  exact Set.Subset.trans (BoxGContent_subset_GContent M h_mcs) h_R

/-!
## Modal Witness Seed Consistency

The key theorem: if Diamond(psi) is in an MCS M, then {psi} ∪ BoxContent(M)
is consistent. This enables constructing witness MCSs for Diamond formulas
that preserve the modal content of the original MCS.

The proof follows the same pattern as `temporal_witness_seed_consistent` in
TemporalCoherentConstruction.lean, using `generalized_modal_k` (modal K
distribution) instead of `generalized_temporal_k` (temporal K distribution).
-/

/--
Modal witness seed: {psi} ∪ BoxContent(M).

When Diamond(psi) is in M, this set is consistent and can be extended to an MCS
via Lindenbaum's lemma.
-/
def ModalWitnessSeed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ MCSBoxContent M

/--
psi is in its own ModalWitnessSeed.
-/
lemma psi_mem_ModalWitnessSeed (M : Set Formula) (psi : Formula) :
    psi ∈ ModalWitnessSeed M psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/--
BoxContent is a subset of ModalWitnessSeed.
-/
lemma MCSBoxContent_subset_ModalWitnessSeed (M : Set Formula) (psi : Formula) :
    MCSBoxContent M ⊆ ModalWitnessSeed M psi :=
  Set.subset_union_right

/--
**Key Theorem**: Modal witness seed consistency.

If Diamond(psi) ∈ M for an MCS M, then {psi} ∪ BoxContent(M) is consistent.

**Proof**: Suppose {psi} ∪ BoxContent(M) is inconsistent. Then there exist
chi_1, ..., chi_n in BoxContent(M) such that {psi, chi_1, ..., chi_n} ⊢ bot.
By deduction theorem: {chi_1, ..., chi_n} ⊢ neg(psi).
By generalized_modal_k: {Box chi_1, ..., Box chi_n} ⊢ Box(neg(psi)).
Since Box chi_i ∈ M for all i (definition of BoxContent), Box(neg psi) ∈ M.
But Diamond(psi) = neg(Box(neg psi)) is also in M, contradicting consistency.
-/
theorem modal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ M) :
    SetConsistent (ModalWitnessSeed M psi) := by
  intro L hL_sub ⟨d⟩

  by_cases h_psi_in : psi ∈ L
  · -- Case: psi ∈ L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)

    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord

    -- Get Box chi ∈ M for each chi ∈ L_filt from BoxContent
    have h_Box_filt_in_M : ∀ chi ∈ L_filt, Formula.box chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [ModalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_boxcontent
      · exact absurd h_eq h_ne
      · exact h_boxcontent

    -- Apply generalized modal K (Box distributes over derivation)
    have d_Box_neg : (Context.map Formula.box L_filt) ⊢ Formula.box (Formula.neg psi) :=
      Bimodal.Theorems.generalized_modal_k L_filt (Formula.neg psi) d_neg

    -- All formulas in Box(L_filt) are in M
    have h_Box_context_in_M : ∀ phi ∈ Context.map Formula.box L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_Box_filt_in_M chi h_chi_in

    -- By MCS closure under derivation, Box(neg psi) ∈ M
    have h_Box_neg_in_M : Formula.box (Formula.neg psi) ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.box L_filt)
        h_Box_context_in_M d_Box_neg

    -- Contradiction: Diamond(psi) = neg(Box(neg psi)) is also in M
    have h_diamond_eq : diamondFormula psi = Formula.neg (Formula.box (Formula.neg psi)) := rfl
    rw [h_diamond_eq] at h_diamond
    exact set_consistent_not_both h_mcs.1 (Formula.box (Formula.neg psi)) h_Box_neg_in_M h_diamond

  · -- Case: psi ∉ L, so L ⊆ BoxContent(M), hence L ⊆ M
    have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [ModalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_boxcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · -- chi ∈ BoxContent(M) means Box chi ∈ M, and by T-axiom chi ∈ M
        have h_Box_chi : Formula.box chi ∈ M := h_boxcontent
        have h_T := DerivationTree.axiom [] ((Formula.box chi).imp chi) (Axiom.modal_t chi)
        exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_Box_chi

    exact h_mcs.1 L h_L_in_M ⟨d⟩

/-!
## Diamond Persistence Through CanonicalR

In S5 + temporal logic, Diamond(psi) membership is preserved by CanonicalR
in both directions. This is because:
- Axiom 5 (negative introspection): neg(Box phi) → Box(neg(Box phi))
- MF axiom (temp_future): Box phi → G(Box phi)

These combine to show that neg(Box(neg psi)) → G(neg(Box(neg psi))) ∈ M,
so Diamond(psi) propagates to all CanonicalR-successors.
-/

/--
Diamond(psi) in M implies Diamond(psi) in GContent(M).

If neg(Box(neg psi)) ∈ M, then G(neg(Box(neg psi))) ∈ M.
This uses axiom 5 (neg(Box X) → Box(neg(Box X))) and MF axiom (Box X → G(Box X)):
  neg(Box(neg psi)) → Box(neg(Box(neg psi))) → G(Box(neg(Box(neg psi)))) → ...

Actually the direct path is via temp_a: phi → G(P(phi)), so
  neg(Box(neg psi)) → G(P(neg(Box(neg psi)))) ∈ M

But we need G(neg(Box(neg psi))), not G(P(neg(Box(neg psi)))).

The correct path uses axiom 5 + temp_future:
  neg(Box(neg psi)) → Box(neg(Box(neg psi))) → G(Box(neg(Box(neg psi))))

Then by T-axiom on the inner Box:
  G(Box(neg(Box(neg psi)))) → G(neg(Box(neg psi))) via G distributing over T.

Actually, more directly:
  neg(Box(neg psi)) ∈ M
  → Box(neg(Box(neg psi))) ∈ M (axiom 5)
  → G(Box(neg(Box(neg psi)))) ∈ M (temp_future on Box(neg(Box(neg psi))))

Hmm, temp_future is: Box phi → G(Box phi), applied to phi = neg(Box(neg psi)):
  Box(neg(Box(neg psi))) → G(Box(neg(Box(neg psi)))) ∈ M

So G(Box(neg(Box(neg psi)))) ∈ M. By T on the inner Box:
  ⊢ Box(neg(Box(neg psi))) → neg(Box(neg psi))
  ⊢ G(Box(neg(Box(neg psi)))) → G(neg(Box(neg psi)))  (by temporal K)

So G(neg(Box(neg psi))) ∈ M, i.e., G(Diamond(psi)) ∈ M.
Hence Diamond(psi) ∈ GContent(M).
-/
theorem diamond_in_GContent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ M) :
    diamondFormula psi ∈ GContent M := by
  simp only [GContent, Set.mem_setOf_eq]
  -- Diamond(psi) = neg(Box(neg psi))
  have h_eq : diamondFormula psi = Formula.neg (Formula.box (Formula.neg psi)) := rfl
  rw [h_eq] at h_diamond ⊢
  -- Step 1: By axiom 5, neg(Box(neg psi)) → Box(neg(Box(neg psi)))
  have h_ax5 := neg_box_to_box_neg_box (Formula.neg psi)
  have h_box_diamond : Formula.box (Formula.neg (Formula.box (Formula.neg psi))) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_ax5) h_diamond
  -- Step 2: By temp_future, Box(neg(Box(neg psi))) → G(Box(neg(Box(neg psi))))
  have h_tf : [] ⊢ (Formula.box (Formula.neg (Formula.box (Formula.neg psi)))).imp
    (Formula.all_future (Formula.box (Formula.neg (Formula.box (Formula.neg psi))))) :=
    DerivationTree.axiom [] _ (Axiom.temp_future (Formula.neg (Formula.box (Formula.neg psi))))
  have h_G_box_diamond : Formula.all_future (Formula.box (Formula.neg (Formula.box (Formula.neg psi)))) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_tf) h_box_diamond
  -- Step 3: G distributes over T-axiom: G(Box X) → G(X)
  -- T-axiom: Box(neg(Box(neg psi))) → neg(Box(neg psi))
  -- Temporal K: G(Box(neg(Box(neg psi))) → neg(Box(neg psi))) → (G(Box(...)) → G(neg(Box(neg psi))))
  have h_T : [] ⊢ (Formula.box (Formula.neg (Formula.box (Formula.neg psi)))).imp
    (Formula.neg (Formula.box (Formula.neg psi))) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.neg (Formula.box (Formula.neg psi))))
  have h_G_T : [] ⊢ Formula.all_future ((Formula.box (Formula.neg (Formula.box (Formula.neg psi)))).imp
    (Formula.neg (Formula.box (Formula.neg psi)))) :=
    DerivationTree.temporal_necessitation _ h_T
  have h_temp_K : [] ⊢ (Formula.all_future ((Formula.box (Formula.neg (Formula.box (Formula.neg psi)))).imp
    (Formula.neg (Formula.box (Formula.neg psi))))).imp
    ((Formula.all_future (Formula.box (Formula.neg (Formula.box (Formula.neg psi))))).imp
     (Formula.all_future (Formula.neg (Formula.box (Formula.neg psi))))) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist _ _)
  have h_G_impl : [] ⊢ (Formula.all_future (Formula.box (Formula.neg (Formula.box (Formula.neg psi))))).imp
    (Formula.all_future (Formula.neg (Formula.box (Formula.neg psi)))) :=
    DerivationTree.modus_ponens [] _ _ h_temp_K h_G_T
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_G_impl) h_G_box_diamond

/--
Diamond(psi) persists through CanonicalR: if Diamond(psi) ∈ M and CanonicalR M M',
then Diamond(psi) ∈ M'.

This follows from `diamond_in_GContent`: Diamond(psi) ∈ GContent(M), and
CanonicalR M M' means GContent(M) ⊆ M'.
-/
theorem diamond_persistent_forward (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (psi : Formula) (h_diamond : diamondFormula psi ∈ M) :
    diamondFormula psi ∈ M' :=
  h_R (diamond_in_GContent M h_mcs psi h_diamond)

/--
Diamond(psi) persists backward through CanonicalR: if Diamond(psi) ∈ M and
CanonicalR M' M (i.e., M' ≤ M in the preorder), then Diamond(psi) ∈ M'.

This uses the HContent duality: CanonicalR M' M means GContent(M') ⊆ M,
which by duality implies HContent(M) ⊆ M'. We show Diamond(psi) ∈ HContent(M)
by proving H(Diamond(psi)) ∈ M, using the derived lemma `box_to_past`
(⊢ Box phi → H phi) applied after axiom 5.

**Proof path**:
1. Diamond(psi) ∈ M (hypothesis)
2. By axiom 5: Box(Diamond(psi)) ∈ M
3. By box_to_past: H(Diamond(psi)) ∈ M
4. Hence Diamond(psi) ∈ HContent(M) ⊆ M'
-/
theorem diamond_persistent_backward (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M' M) (psi : Formula) (h_diamond : diamondFormula psi ∈ M) :
    diamondFormula psi ∈ M' := by
  -- Diamond(psi) = neg(Box(neg psi))
  have h_eq : diamondFormula psi = Formula.neg (Formula.box (Formula.neg psi)) := rfl
  rw [h_eq] at h_diamond ⊢
  -- Step 1: By axiom 5, neg(Box(neg psi)) → Box(neg(Box(neg psi)))
  have h_ax5 := neg_box_to_box_neg_box (Formula.neg psi)
  have h_box_diamond : Formula.box (Formula.neg (Formula.box (Formula.neg psi))) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_ax5) h_diamond
  -- Step 2: By box_to_past (⊢ Box phi → H phi), get H(neg(Box(neg psi))) ∈ M
  have h_bp : [] ⊢ (Formula.box (Formula.neg (Formula.box (Formula.neg psi)))).imp
    (Formula.all_past (Formula.neg (Formula.box (Formula.neg psi)))) :=
    Bimodal.Theorems.Perpetuity.box_to_past (Formula.neg (Formula.box (Formula.neg psi)))
  have h_H_diamond : Formula.all_past (Formula.neg (Formula.box (Formula.neg psi))) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_bp) h_box_diamond
  -- Step 3: neg(Box(neg psi)) ∈ HContent(M), so by duality it's in M'
  have h_R_past : CanonicalR_past M M' :=
    GContent_subset_implies_HContent_reverse M' M h_mcs' h_mcs h_R
  exact h_R_past h_H_diamond

/-!
## Chain-Based FMCS Infrastructure

A chain-based FMCS uses a maximal chain (Flag) in the CanonicalMCS preorder
as the time domain. Within a Flag, any two elements are comparable, providing
a total order and natural temporal structure.

### Key Properties

- **Pairwise comparability**: Any two elements in a Flag satisfy `a ≤ b ∨ b ≤ a`
- **Forward G**: From `CanonicalR` definition (GContent subset)
- **Backward H**: From GContent/HContent duality
- **Existence**: Every CanonicalMCS is in some Flag (Zorn's lemma via `Flag.exists_mem`)

### Design

The domain of a chain-based FMCS is `{ w : CanonicalMCS // w ∈ flag }` for
a given Flag. This inherits the Preorder from CanonicalMCS via `Subtype.preorder`.
-/

/--
The domain of a chain-based FMCS: elements of a maximal chain (Flag)
in the CanonicalMCS preorder.

This type inherits `Preorder` from CanonicalMCS via `Subtype.preorder`.
-/
abbrev ChainFMCSDomain (flag : Flag CanonicalMCS) :=
  { w : CanonicalMCS // w ∈ flag }

/--
Any two elements in a chain-based FMCS domain are comparable.

This follows directly from the Flag (maximal chain) property.
-/
theorem chainFMCS_pairwise_comparable (flag : Flag CanonicalMCS)
    (a b : ChainFMCSDomain flag) : a ≤ b ∨ b ≤ a := by
  exact flag.Chain'.total a.property b.property

/--
MCS assignment for a chain-based FMCS: each element maps to its underlying MCS.
-/
def chainFMCS_mcs (flag : Flag CanonicalMCS) (w : ChainFMCSDomain flag) : Set Formula :=
  w.val.world

/--
Each assigned set is maximal consistent.
-/
theorem chainFMCS_is_mcs (flag : Flag CanonicalMCS) (w : ChainFMCSDomain flag) :
    SetMaximalConsistent (chainFMCS_mcs flag w) :=
  w.val.is_mcs

/--
Forward G coherence for chain-based FMCS.

If `w₁ ≤ w₂` in the chain and `G phi ∈ mcs(w₁)`, then `phi ∈ mcs(w₂)`.

Proof: `w₁ ≤ w₂` means `CanonicalR w₁.val.world w₂.val.world` (by Preorder definition),
and `G phi ∈ mcs(w₁)` means `phi ∈ GContent(w₁.val.world)`. Since
`CanonicalR = GContent(·) ⊆ ·`, we get `phi ∈ w₂.val.world = mcs(w₂)`.
-/
theorem chainFMCS_forward_G (flag : Flag CanonicalMCS)
    (w₁ w₂ : ChainFMCSDomain flag) (phi : Formula)
    (h_le : w₁ ≤ w₂) (h_G : Formula.all_future phi ∈ chainFMCS_mcs flag w₁) :
    phi ∈ chainFMCS_mcs flag w₂ :=
  canonical_forward_G w₁.val.world w₂.val.world h_le phi h_G

/--
Backward H coherence for chain-based FMCS.

If `w₂ ≤ w₁` in the chain and `H phi ∈ mcs(w₁)`, then `phi ∈ mcs(w₂)`.

Proof: By GContent/HContent duality, `CanonicalR w₂.val.world w₁.val.world`
implies `HContent(w₁.val.world) ⊆ w₂.val.world`. Since `H phi ∈ mcs(w₁)`
means `phi ∈ HContent(w₁.val.world)`, we get `phi ∈ w₂.val.world = mcs(w₂)`.
-/
theorem chainFMCS_backward_H (flag : Flag CanonicalMCS)
    (w₁ w₂ : ChainFMCSDomain flag) (phi : Formula)
    (h_le : w₂ ≤ w₁) (h_H : Formula.all_past phi ∈ chainFMCS_mcs flag w₁) :
    phi ∈ chainFMCS_mcs flag w₂ := by
  have h_R_past : CanonicalR_past w₁.val.world w₂.val.world :=
    GContent_subset_implies_HContent_reverse w₂.val.world w₁.val.world
      w₂.val.is_mcs w₁.val.is_mcs h_le
  exact canonical_backward_H w₁.val.world w₂.val.world h_R_past phi h_H

/--
The chain-based FMCS construction: an FMCS (= FMCS) over the domain of a
maximal chain (Flag) in CanonicalMCS.

This family satisfies all FMCS requirements:
- Each element maps to its own MCS (identity mapping)
- Forward G coherence via CanonicalR
- Backward H coherence via GContent/HContent duality

Within this chain, any two elements are comparable (`chainFMCS_pairwise_comparable`),
so the temporal order is total.
-/
noncomputable def chainFMCS (flag : Flag CanonicalMCS) : FMCS (ChainFMCSDomain flag) where
  mcs := chainFMCS_mcs flag
  is_mcs := chainFMCS_is_mcs flag
  forward_G := fun w₁ w₂ phi h_le h_G =>
    chainFMCS_forward_G flag w₁ w₂ phi h_le h_G
  backward_H := fun w₁ w₂ phi h_le h_H =>
    chainFMCS_backward_H flag w₁ w₂ phi h_le h_H

/-!
## Existence: Every CanonicalMCS Element is in Some Flag

By Zorn's lemma (via Mathlib's `Flag.exists_mem`), every element of CanonicalMCS
is contained in some maximal chain (Flag). This means that for every MCS, there
exists a chain-based FMCS whose domain contains that MCS.
-/

/--
Every CanonicalMCS element is in some Flag (maximal chain).

This is a direct application of `Flag.exists_mem` from Mathlib, which uses Zorn's lemma.
-/
theorem canonicalMCS_in_some_flag (w : CanonicalMCS) :
    ∃ flag : Flag CanonicalMCS, w ∈ flag :=
  Flag.exists_mem w

/--
For any CanonicalMCS element, there exists a chain-based FMCS and a domain element
such that the element's MCS is assigned to that domain element.

This combines `Flag.exists_mem` (Zorn) with the `chainFMCS` construction.
-/
theorem chainFMCS_exists_for_mcs (w : CanonicalMCS) :
    ∃ (flag : Flag CanonicalMCS) (d : ChainFMCSDomain flag),
      (chainFMCS flag).mcs d = w.world := by
  obtain ⟨flag, h_mem⟩ := canonicalMCS_in_some_flag w
  exact ⟨flag, ⟨w, h_mem⟩, rfl⟩

/--
Within a chain-based FMCS, forward F witnesses exist in CanonicalMCS
(but not necessarily in the same chain).

If `F phi ∈ mcs(w)` for some element `w` of the chain, then there exists a
CanonicalMCS element `s` with `w.val ≤ s` and `phi ∈ s.world`.

The witness `s` may NOT be in the same flag/chain -- this is expected and handled
at the BFMCS bundle level (Phase 7).
-/
theorem chainFMCS_forward_F_in_CanonicalMCS (flag : Flag CanonicalMCS)
    (w : ChainFMCSDomain flag) (phi : Formula)
    (h_F : Formula.some_future phi ∈ chainFMCS_mcs flag w) :
    ∃ s : CanonicalMCS, w.val ≤ s ∧ phi ∈ s.world :=
  canonicalMCS_forward_F w.val phi h_F

/--
Within a chain-based FMCS, backward P witnesses exist in CanonicalMCS
(but not necessarily in the same chain).

If `P phi ∈ mcs(w)` for some element `w` of the chain, then there exists a
CanonicalMCS element `s` with `s ≤ w.val` and `phi ∈ s.world`.

The witness `s` may NOT be in the same flag/chain -- this is expected and handled
at the BFMCS bundle level (Phase 7).
-/
theorem chainFMCS_backward_P_in_CanonicalMCS (flag : Flag CanonicalMCS)
    (w : ChainFMCSDomain flag) (phi : Formula)
    (h_P : Formula.some_past phi ∈ chainFMCS_mcs flag w) :
    ∃ s : CanonicalMCS, s ≤ w.val ∧ phi ∈ s.world :=
  canonicalMCS_backward_P w.val phi h_P

/--
BoxContent propagation within a chain: if `w₁ ≤ w₂` in the chain,
then `MCSBoxContent(mcs(w₁)) ⊆ MCSBoxContent(mcs(w₂))`.

This follows from `MCSBoxContent_subset_of_CanonicalR`.
-/
theorem chainFMCS_boxcontent_propagation (flag : Flag CanonicalMCS)
    (w₁ w₂ : ChainFMCSDomain flag)
    (h_le : w₁ ≤ w₂) :
    MCSBoxContent (chainFMCS_mcs flag w₁) ⊆ MCSBoxContent (chainFMCS_mcs flag w₂) :=
  MCSBoxContent_subset_of_CanonicalR w₁.val.world w₂.val.world
    w₁.val.is_mcs w₂.val.is_mcs h_le

/--
Diamond persistence within a chain: Diamond(psi) is preserved along the chain
in both directions.

Forward: if `Diamond(psi) ∈ mcs(w₁)` and `w₁ ≤ w₂`, then `Diamond(psi) ∈ mcs(w₂)`.
Backward: if `Diamond(psi) ∈ mcs(w₂)` and `w₁ ≤ w₂`, then `Diamond(psi) ∈ mcs(w₁)`.
-/
theorem chainFMCS_diamond_persistent_forward (flag : Flag CanonicalMCS)
    (w₁ w₂ : ChainFMCSDomain flag)
    (h_le : w₁ ≤ w₂) (psi : Formula)
    (h_diamond : diamondFormula psi ∈ chainFMCS_mcs flag w₁) :
    diamondFormula psi ∈ chainFMCS_mcs flag w₂ :=
  diamond_persistent_forward w₁.val.world w₂.val.world
    w₁.val.is_mcs w₂.val.is_mcs h_le psi h_diamond

theorem chainFMCS_diamond_persistent_backward (flag : Flag CanonicalMCS)
    (w₁ w₂ : ChainFMCSDomain flag)
    (h_le : w₁ ≤ w₂) (psi : Formula)
    (h_diamond : diamondFormula psi ∈ chainFMCS_mcs flag w₂) :
    diamondFormula psi ∈ chainFMCS_mcs flag w₁ :=
  diamond_persistent_backward w₂.val.world w₁.val.world
    w₂.val.is_mcs w₁.val.is_mcs h_le psi h_diamond

/--
Modal witness seed consistency within a chain: if Diamond(psi) is in the MCS
of some chain element, then {psi} ∪ BoxContent(mcs(w)) is consistent.
-/
theorem chainFMCS_modal_witness_seed_consistent (flag : Flag CanonicalMCS)
    (w : ChainFMCSDomain flag) (psi : Formula)
    (h_diamond : diamondFormula psi ∈ chainFMCS_mcs flag w) :
    SetConsistent (ModalWitnessSeed (chainFMCS_mcs flag w) psi) :=
  modal_witness_seed_consistent w.val.world w.val.is_mcs psi h_diamond

end Bimodal.Metalogic.Bundle