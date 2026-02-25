import Bimodal.Metalogic.Bundle.CanonicalBFMCS
import Bimodal.Metalogic.Bundle.FMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Theorems.GeneralizedNecessitation
import Mathlib.Order.Zorn

/-!
# BoxContent Infrastructure and Modal Witness Seeds (Task 925)

This module provides foundational lemmas for constructing modally saturated BMCS
with temporal coherence. The key results are:

1. **BoxContent definitions and properties** (BoxContentAt, BoxGContent)
2. **Modal witness seed consistency**: {psi} ∪ BoxContent(M) is consistent when
   Diamond(psi) ∈ M (essential for witness family construction)
3. **Diamond persistence through CanonicalR**: Diamond(psi) propagates through
   the temporal ordering (using S5 axiom 5 + MF axiom)
4. **BoxContent propagation**: BoxContent(M) ⊆ BoxContent(M') when CanonicalR M M'

These results are prerequisites for any approach to constructing a fully saturated
BMCS (chain-based, embedding-based, or direct CanonicalMCS-based).

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
def BoxContentAt (M : Set Formula) : Set Formula :=
  {phi | Formula.box phi ∈ M}

/--
BoxContent is a subset of the MCS (by T-axiom: Box phi => phi).
-/
lemma BoxContentAt_subset_self (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    BoxContentAt M ⊆ M := by
  intro phi h_box
  simp only [BoxContentAt, Set.mem_setOf_eq] at h_box
  have h_T : [] ⊢ (Formula.box phi).imp phi :=
    DerivationTree.axiom [] _ (Axiom.modal_t phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_box

/--
BoxContent propagation via S5 axiom 4: Box phi => Box(Box phi).

If phi ∈ BoxContent(M), then Box phi ∈ M, so Box(Box phi) ∈ M (by axiom 4),
hence Box phi ∈ BoxContent(M). This means BoxContent is closed under Box.
-/
lemma BoxContentAt_closed_box (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_box : phi ∈ BoxContentAt M) :
    Formula.box phi ∈ BoxContentAt M := by
  simp only [BoxContentAt, Set.mem_setOf_eq] at h_box ⊢
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
    (Formula.box phi).neg ∈ BoxContentAt M := by
  simp only [BoxContentAt, Set.mem_setOf_eq]
  exact mcs_neg_box_implies_box_neg_box h_mcs phi h_neg_box

/--
BoxContent propagates through CanonicalR: if CanonicalR M M', then
BoxContent(M) ⊆ BoxContent(M').

**Proof**: If Box phi ∈ M, by `temp_future` (Box phi → G(Box phi)),
G(Box phi) ∈ M. So Box phi ∈ GContent(M). Since CanonicalR M M'
means GContent(M) ⊆ M', we get Box phi ∈ M'. Hence phi ∈ BoxContent(M').
-/
theorem BoxContentAt_subset_of_CanonicalR (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') :
    BoxContentAt M ⊆ BoxContentAt M' := by
  intro phi h_box
  simp only [BoxContentAt, Set.mem_setOf_eq] at h_box ⊢
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
  BoxContentAt(M) ⊆ BoxGContent(M) ⊆ GContent(M)

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
BoxContentAt ⊆ BoxGContent: If Box phi ∈ M, then Box(G phi) ∈ M.

This follows from the MF axiom: Box phi → Box(G phi).
-/
lemma BoxContentAt_subset_BoxGContent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    BoxContentAt M ⊆ BoxGContent M := by
  intro phi h_box
  simp only [BoxContentAt, Set.mem_setOf_eq] at h_box
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
The full hierarchy: BoxContentAt(M) ⊆ BoxGContent(M) ⊆ GContent(M) ⊆ M.

Combining the individual inclusion lemmas.
-/
theorem boxcontent_hierarchy (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    BoxContentAt M ⊆ BoxGContent M ∧
    BoxGContent M ⊆ GContent M ∧
    GContent M ⊆ M := by
  exact ⟨BoxContentAt_subset_BoxGContent M h_mcs,
         BoxGContent_subset_GContent M h_mcs,
         fun _ h => by
           simp only [GContent, Set.mem_setOf_eq] at h
           have h_T : [] ⊢ (Formula.all_future _).imp _ :=
             DerivationTree.axiom [] _ (Axiom.temp_t_future _)
           exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h⟩

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
  {psi} ∪ BoxContentAt M

/--
psi is in its own ModalWitnessSeed.
-/
lemma psi_mem_ModalWitnessSeed (M : Set Formula) (psi : Formula) :
    psi ∈ ModalWitnessSeed M psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/--
BoxContent is a subset of ModalWitnessSeed.
-/
lemma BoxContentAt_subset_ModalWitnessSeed (M : Set Formula) (psi : Formula) :
    BoxContentAt M ⊆ ModalWitnessSeed M psi :=
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
which by duality implies HContent(M) ⊆ M'. We need to show
Diamond(psi) ∈ HContent(M), which requires H(Diamond(psi)) ∈ M.

The proof follows the same pattern as diamond_in_GContent but using
H and past operators.
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
  -- Step 2: BoxContent propagates backward via CanonicalR duality
  -- CanonicalR M' M means GContent(M') ⊆ M
  -- By duality (GContent_subset_implies_HContent_reverse): HContent(M) ⊆ M'
  have h_R_past : CanonicalR_past M M' :=
    GContent_subset_implies_HContent_reverse M' M h_mcs' h_mcs h_R
  -- Step 3: Show neg(Box(neg psi)) ∈ HContent(M)
  -- Need H(neg(Box(neg psi))) ∈ M
  -- By BoxContent(M) propagation: Box(neg(Box(neg psi))) ∈ M (from step 1)
  -- By temp_a: phi → H(F(phi)), but we need phi → H(P(phi)) which is different
  -- Actually we need: Box phi → H(Box phi)
  -- This should follow from a suitable axiom. Let's use:
  -- Box phi → Box(G phi) (MF axiom) → G(Box(G phi)) (temp_future)
  -- Hmm, we need H direction.
  -- Alternative: use BoxContent ⊆ HContent direction
  -- Box(neg(Box(neg psi))) ∈ M, need H(neg(Box(neg psi))) ∈ M
  -- By the T-axiom for H: H(phi) → phi, so phi ∈ M does not imply H(phi) ∈ M
  -- But by axiom 4 + 5 for Box: Box X ∈ M → Box(Box X) ∈ M → ...
  -- We need temp_past or past version of temp_future
  -- Actually, we can use the HContent duality more directly
  -- h_R_past : HContent(M) ⊆ M'
  -- We need neg(Box(neg psi)) ∈ HContent(M)
  -- HContent(M) = {phi | H(phi) ∈ M}
  -- So we need H(neg(Box(neg psi))) ∈ M
  -- By axiom 5: neg(Box(neg psi)) → Box(neg(Box(neg psi)))
  -- We already have Box(neg(Box(neg psi))) ∈ M
  -- temp_a: phi → G(P(phi)) gives neg(Box(neg psi)) → G(P(neg(Box(neg psi))))
  -- But we need H version: phi → H(F(phi))?
  -- Actually we should check what axioms give us H propagation
  -- temp_a is: phi → G(P(phi)). The past dual would be: phi → H(F(phi))
  -- But we have neither directly. Let's use a different path.
  -- We can use: Box phi ∈ M → by T-axiom, phi ∈ M
  -- and then: phi → G(P(phi)) by temp_a
  -- Hmm, this doesn't help with H.
  --
  -- Actually, we have the HContent duality path:
  -- CanonicalR_past M M' means HContent(M) ⊆ M'
  -- And we want neg(Box(neg psi)) ∈ M'
  -- So we need neg(Box(neg psi)) ∈ HContent(M), i.e., H(neg(Box(neg psi))) ∈ M
  --
  -- To get H(neg(Box(neg psi))) ∈ M:
  -- By axiom 5: neg(Box(neg psi)) ∈ M → Box(neg(Box(neg psi))) ∈ M
  -- We need Box → H direction. The "temp_past" axiom would be Box phi → H(Box phi).
  -- Checking if this exists...
  -- We don't have a direct temp_past axiom, but we have:
  --   Box phi → Box(G phi) (modal_future/MF)
  --   Box phi → G(Box phi) (temp_future)
  -- For the past direction, we would need something symmetric.
  --
  -- Alternative approach: use BoxContent(M) ⊆ BoxContent(M')
  -- Wait, that goes forward (M ≤ M'). We have M' ≤ M.
  -- BoxContent propagates forward: if M' ≤ M (CanonicalR M' M), then
  -- BoxContent(M') ⊆ BoxContent(M). But we want to go from M to M'.
  --
  -- Actually, BoxContent propagation goes: if CanonicalR M M', then BoxContent(M) ⊆ BoxContent(M').
  -- We have CanonicalR M' M, which gives BoxContent(M') ⊆ BoxContent(M).
  -- This is the wrong direction.
  --
  -- Let's try: in S5, BoxContent is EQUAL for related MCSs.
  -- If CanonicalR M M' (GContent(M) ⊆ M'), does BoxContent(M) = BoxContent(M')?
  --
  -- BoxContent(M) ⊆ BoxContent(M') follows from CanonicalR M M' (proven above).
  -- BoxContent(M') ⊆ BoxContent(M): if Box phi ∈ M', need Box phi ∈ M.
  --   We have CanonicalR M' M: GContent(M') ⊆ M.
  --   Box phi ∈ M'. By temp_future: G(Box phi) ∈ M'. So Box phi ∈ GContent(M').
  --   By CanonicalR M' M: Box phi ∈ M.
  --
  -- So BoxContent(M) = BoxContent(M') when both CanonicalR M M' and CanonicalR M' M!
  -- But we only have CanonicalR M' M, not both directions.
  --
  -- With just CanonicalR M' M: BoxContent(M') ⊆ BoxContent(M) (by the proof above,
  -- swapping M and M' in BoxContentAt_subset_of_CanonicalR).
  --
  -- Hmm, that gives the wrong direction for our needs.
  --
  -- Let me reconsider. We want neg(Box(neg psi)) ∈ M'. We know it's in M.
  -- We have CanonicalR M' M, so GContent(M') ⊆ M and HContent(M) ⊆ M'.
  --
  -- We need neg(Box(neg psi)) ∈ HContent(M), i.e., H(neg(Box(neg psi))) ∈ M.
  --
  -- Actually, let's use the symmetric version of the forward proof.
  -- In the forward case, we used: axiom 5 → Box(Diamond(psi)) → temp_future → G(Box(Diamond)) → T → G(Diamond)
  -- For the backward case: axiom 5 → Box(Diamond(psi)) → ??? → H(Diamond)
  --
  -- We need Box(X) → H(X) for some path. If we have Box(X) → H(Box(X)):
  --   This doesn't exist as a direct axiom. But temp_a gives: X → G(P(X)).
  --   So X → G(P(X)), instantiated at X = Box(Diamond(psi)):
  --   Box(Diamond(psi)) → G(P(Box(Diamond(psi))))
  --   This doesn't directly help.
  --
  -- Let me try using the fact that Diamond(psi) = neg(Box(neg psi)),
  -- and in MCS M, both neg(Box(neg psi)) AND Box(neg(Box(neg psi))) are true.
  -- We have Box(neg(Box(neg psi))) ∈ M. By T-axiom for past:
  -- There is no "past T-axiom" Box phi → H(phi). The T-axiom is Box phi → phi.
  -- And temp_t_past is: H phi → phi.
  --
  -- So we can't directly get H(neg(Box(neg psi))) from Box(neg(Box(neg psi))).
  --
  -- Final attempt: Use BoxContent(M') ⊆ BoxContent(M) (from CanonicalR M' M).
  -- neg(Box(neg psi)) ∈ M. Is neg(Box(neg psi)) in BoxContent(M)?
  -- neg(Box(neg psi)) ∈ BoxContent(M) iff Box(neg(Box(neg psi))) ∈ M.
  -- Yes! We proved this in step 1 (h_box_diamond).
  --
  -- So neg(Box(neg psi)) ∈ BoxContent(M).
  -- And BoxContent(M') ⊆ BoxContent(M)... wait, that says things in BoxContent(M')
  -- are also in BoxContent(M). But we want things in BoxContent(M) to be in M'.
  --
  -- BoxContent(M) → M': Box(X) ∈ M → X ∈ M' ??
  -- Not directly. BoxContent(M) ⊆ M (by T-axiom), and BoxContent(M) → BoxContent(M')
  -- only if CanonicalR M M' (forward).
  --
  -- With CanonicalR M' M (backward), we have BoxContent(M') ⊆ BoxContent(M).
  -- This means: if Box phi ∈ M', then Box phi ∈ M. Not helpful for our direction.
  --
  -- I think the backward direction requires a different axiom or a more involved argument.
  -- Let me just use the temp_a axiom path:
  --   neg(Box(neg psi)) ∈ M → G(P(neg(Box(neg psi)))) ∈ M (by temp_a)
  -- Then P(neg(Box(neg psi))) ∈ GContent(M). And since CanonicalR M' M means
  -- GContent(M') ⊆ M, we need P(neg(Box(neg psi))) ∈ M'.
  -- But GContent(M') ⊆ M gives us information about GContent(M'), not GContent(M).
  --
  -- Wait. h_R_past : CanonicalR_past M M' means HContent(M) ⊆ M'.
  -- HContent(M) = {phi | H(phi) ∈ M}.
  -- If H(neg(Box(neg psi))) ∈ M, then neg(Box(neg psi)) ∈ HContent(M) ⊆ M'.
  --
  -- The question is: can we get H(neg(Box(neg psi))) ∈ M?
  -- By temp_a: phi → G(P(phi)), instantiated with neg(Box(neg psi)):
  --   neg(Box(neg psi)) → G(P(neg(Box(neg psi)))) ∈ M
  -- This gives P(neg(Box(neg psi))) ∈ GContent(M) ⊆ M (by T-axiom on G).
  -- So P(neg(Box(neg psi))) ∈ M.
  -- P(X) = neg(H(neg X)). So neg(H(neg(neg(Box(neg psi))))) ∈ M.
  -- Hmm, this involves nested negations.
  --
  -- Alternative: by the past analogue of temp_a (if it exists).
  -- There is no direct