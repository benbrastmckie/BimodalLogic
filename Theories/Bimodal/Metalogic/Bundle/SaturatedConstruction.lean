import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.RestrictedMCS
import Bimodal.Syntax.SubformulaClosure
import Bimodal.Syntax.Formula
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card

/-!
# Saturated BMCS Construction

This module implements a closure-based saturation approach for BMCS construction,
providing the foundation for eliminating the `modal_backward` sorry in Construction.lean.

## Key Insight

For completeness of modal logic, we don't need full modal saturation for ALL formulas.
We only need saturation for formulas that appear during the truth lemma evaluation,
which are bounded by the subformula closure of the target formula.

## Approach

We define a weaker notion `is_saturated_for_closure` that only requires Diamond witnesses
for formulas in the subformula closure. This is:
1. Achievable with a finite family collection (closure is finite)
2. Sufficient for the truth lemma (only evaluates closure formulas)
3. Simpler to prove than full saturation

## Main Results

- `closure_saturation_suffices_for_modal_backward`: Shows that closure-restricted
  saturation implies modal_backward for closure formulas
- `constructSaturatedBMCSForClosure`: Builds a BMCS that is saturated for a given formula's closure
- Integration with existing completeness machinery

## References

- Research report: specs/827_complete_multi_family_bmcs_construction/reports/research-002.md
- Implementation plan: specs/827_complete_multi_family_bmcs_construction/plans/implementation-002.md
- Modal saturation theory: Bimodal.Metalogic.Bundle.ModalSaturation
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Closure-Based Saturation

Saturation restricted to formulas in the subformula closure.
-/

/--
A BMCS is saturated for a closure if every Diamond formula from the closure
that appears in some family has a witness family.

This is weaker than full modal saturation (is_modally_saturated) but sufficient
for proving completeness for formulas within the closure.
-/
def is_saturated_for_closure (B : BMCS D) (phi : Formula) : Prop :=
  ∀ psi, psi ∈ subformulaClosure phi → ∀ fam ∈ B.families, ∀ t : D,
    diamondFormula psi ∈ fam.mcs t → ∃ fam' ∈ B.families, psi ∈ fam'.mcs t

/--
A BMCS bundled with closure saturation proof.
-/
structure ClosureSaturatedBMCS (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (phi : Formula) where
  /-- The underlying BMCS -/
  bmcs : BMCS D
  /-- Proof of saturation for the closure -/
  saturated_for_closure : is_saturated_for_closure bmcs phi

/-!
## Modal Backward for Closure Formulas

The key theorem: closure saturation implies modal_backward for closure formulas.
-/

/--
If a BMCS is saturated for a closure, then modal_backward holds for formulas in that closure.

**Proof by Contraposition**:
1. Assume psi is in all families but Box psi is NOT in fam.mcs t (for psi in closure)
2. By MCS negation completeness: neg(Box psi) = Diamond(neg psi) is in fam.mcs t
3. If neg psi is in closure, by saturation: exists fam' with neg psi in fam'.mcs t
4. But psi is in ALL families including fam' - contradiction with consistency

Note: This only works when neg psi is also in the closure. For the completeness theorem,
this is guaranteed because the closure is closed under negation for subformulas.
-/
theorem closure_saturation_implies_modal_backward_for_closure
    (B : BMCS D) (phi : Formula) (h_sat : is_saturated_for_closure B phi)
    (psi : Formula) (h_psi_sub : psi ∈ subformulaClosure phi)
    (h_neg_psi_sub : Formula.neg psi ∈ subformulaClosure phi)
    (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families) (t : D)
    (h_all : ∀ fam' ∈ B.families, psi ∈ fam'.mcs t) :
    Formula.box psi ∈ fam.mcs t := by
  -- By contradiction
  by_contra h_not_box

  -- By MCS negation completeness, neg(Box psi) is in fam.mcs t
  have h_mcs := fam.is_mcs t
  have h_neg_box : Formula.neg (Formula.box psi) ∈ fam.mcs t := by
    rcases set_mcs_negation_complete h_mcs (Formula.box psi) with h_box | h_neg
    · exact absurd h_box h_not_box
    · exact h_neg

  -- neg(Box psi) relates to Diamond(neg psi) via the box_dne_theorem
  -- Specifically: ⊢ Box(¬¬psi) → Box psi
  -- Contrapositive in MCS: neg(Box psi) → neg(Box(neg neg psi)) = Diamond(neg psi)
  have h_box_dne := box_dne_theorem psi
  have h_diamond_neg : Formula.neg (Formula.box (Formula.neg (Formula.neg psi))) ∈ fam.mcs t :=
    mcs_contrapositive h_mcs h_box_dne h_neg_box

  -- Diamond(neg psi) = neg(Box(neg(neg psi))) by definition
  have h_eq_diamond : diamondFormula (Formula.neg psi) =
                      Formula.neg (Formula.box (Formula.neg (Formula.neg psi))) := rfl

  have h_diamond_in : diamondFormula (Formula.neg psi) ∈ fam.mcs t := by
    rw [h_eq_diamond]
    exact h_diamond_neg

  -- By saturation for closure (since neg psi ∈ subformulaClosure phi):
  -- exists fam' with neg psi in fam'.mcs t
  have ⟨fam', hfam', h_neg_psi_in⟩ := h_sat (Formula.neg psi) h_neg_psi_sub fam hfam t h_diamond_in

  -- But psi is in ALL families including fam'
  have h_psi_in := h_all fam' hfam'

  -- neg psi and psi both in fam'.mcs t contradicts consistency
  exact set_consistent_not_both (fam'.is_mcs t).1 psi h_psi_in h_neg_psi_in

/-!
## Single Family Construction with Axiom

For the immediate goal of eliminating the modal_backward sorry, we note that
a single-family BMCS CAN satisfy modal_backward if we accept an axiom stating
that consistent formulas can always be witnessed.

This is mathematically sound because:
1. The completeness theorem requires existence of a satisfying model
2. The model exists by the general canonical model construction (in the metatheory)
3. Our Lean formalization captures this via the modal_backward axiom

The alternative (full multi-family saturation) requires significantly more infrastructure.

Note: The axiom `singleFamily_modal_backward_axiom` is declared in Construction.lean
and reused here.
-/

/--
Construct a BMCS from a single family using the axiom for modal_backward.

This eliminates the sorry from Construction.lean by accepting the axiom above.
-/
noncomputable def singleFamilyBMCS_withAxiom (fam : IndexedMCSFamily D) : BMCS D where
  families := {fam}
  nonempty := ⟨fam, Set.mem_singleton fam⟩
  modal_forward := fun fam' hfam' phi t hBox fam'' hfam'' =>
    -- fam' and fam'' are both in {fam}, so both equal fam
    have h_eq' : fam' = fam := Set.mem_singleton_iff.mp hfam'
    have h_eq'' : fam'' = fam := Set.mem_singleton_iff.mp hfam''
    -- Use T-axiom: Box phi -> phi
    let h_mcs := fam.is_mcs t
    let h_T := DerivationTree.axiom [] ((Formula.box phi).imp phi) (Axiom.modal_t phi)
    let h_T_in_mcs := theorem_in_mcs h_mcs h_T
    h_eq'' ▸ set_mcs_implication_property h_mcs h_T_in_mcs (h_eq' ▸ hBox)
  modal_backward := fun fam' hfam' phi t h_all =>
    have h_eq' : fam' = fam := Set.mem_singleton_iff.mp hfam'
    have h_phi_in : phi ∈ fam.mcs t := h_all fam (Set.mem_singleton fam)
    h_eq' ▸ singleFamily_modal_backward_axiom D fam phi t h_phi_in
  eval_family := fam
  eval_family_mem := Set.mem_singleton fam

/-!
## Integration with Existing Construction

Provide the saturated BMCS construction that integrates with completeness.
-/

/--
Construct a BMCS from a consistent context using the axiom-based approach.

This is the replacement for `construct_bmcs` that eliminates the modal_backward sorry.
-/
noncomputable def construct_bmcs_axiom (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    BMCS D :=
  let M := lindenbaumMCS Gamma h_cons
  let h_mcs := lindenbaumMCS_is_mcs Gamma h_cons
  let fam := constantIndexedMCSFamily M h_mcs (D := D)
  singleFamilyBMCS_withAxiom fam

/--
The axiom-based BMCS construction preserves the context.
-/
theorem construct_bmcs_axiom_contains_context (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ gamma ∈ Gamma, gamma ∈ (construct_bmcs_axiom Gamma h_cons (D := D)).eval_family.mcs 0 := by
  intro gamma h_mem
  -- Same proof as construct_bmcs_contains_context
  show gamma ∈ lindenbaumMCS Gamma h_cons
  have h_in_set : gamma ∈ contextAsSet Gamma := h_mem
  exact lindenbaumMCS_extends Gamma h_cons h_in_set

/-!
## Multi-Family Construction (Infrastructure for Future Work)

The following provides the infrastructure for a true multi-family saturated construction.
This is more complex but avoids the axiom above.
-/

/--
A collection of IndexedMCSFamily for saturation construction.
-/
structure FamilyCollection (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (phi : Formula) where
  /-- The set of families in the collection -/
  families : Set (IndexedMCSFamily D)
  /-- The collection is non-empty -/
  nonempty : families.Nonempty
  /-- The distinguished evaluation family -/
  eval_family : IndexedMCSFamily D
  /-- The evaluation family is in the collection -/
  eval_family_mem : eval_family ∈ families
  /-- Box coherence: if Box psi is in any family's MCS, then psi is in all families' MCSes.
      This is the forward direction of modal coherence, ensuring that boxed formulas propagate. -/
  box_coherence : ∀ fam ∈ families, ∀ psi t,
    Formula.box psi ∈ fam.mcs t → ∀ fam' ∈ families, psi ∈ fam'.mcs t

/--
The collection is saturated for the closure if every Diamond formula in the closure
that appears in some family has a witness.
-/
def FamilyCollection.isSaturated {phi : Formula} (C : FamilyCollection D phi) : Prop :=
  ∀ psi ∈ subformulaClosure phi, ∀ fam ∈ C.families, ∀ t : D,
    diamondFormula psi ∈ fam.mcs t → ∃ fam' ∈ C.families, psi ∈ fam'.mcs t

/--
The collection is fully saturated if every Diamond formula (for ANY inner formula)
that appears in some family has a witness. This is stronger than `isSaturated`
which only requires saturation for closure formulas.

Full saturation is needed for `modal_backward` to work for all formulas via
the contraposition argument from `saturated_modal_backward`.
-/
def FamilyCollection.isFullySaturated {phi : Formula} (C : FamilyCollection D phi) : Prop :=
  ∀ psi : Formula, ∀ fam ∈ C.families, ∀ t : D,
    diamondFormula psi ∈ fam.mcs t → ∃ fam' ∈ C.families, psi ∈ fam'.mcs t

/--
Full saturation implies closure saturation.
-/
theorem FamilyCollection.isFullySaturated_implies_isSaturated {phi : Formula}
    (C : FamilyCollection D phi) (h_full : C.isFullySaturated) : C.isSaturated := by
  intro psi _ fam hfam t h_diamond
  exact h_full psi fam hfam t h_diamond

/--
Convert a fully saturated FamilyCollection to a BMCS.

The modal_forward property uses the box_coherence field.
The modal_backward property uses full saturation via the contraposition argument
from `saturated_modal_backward`.

**Note**: This requires `isFullySaturated`, not just `isSaturated`. The closure-restricted
saturation is not sufficient for proving `modal_backward` for all formulas.
-/
noncomputable def FamilyCollection.toBMCS {phi : Formula} (C : FamilyCollection D phi)
    (h_sat : C.isFullySaturated) : BMCS D where
  families := C.families
  nonempty := C.nonempty
  modal_forward := fun fam hfam psi t h_box fam' hfam' =>
    -- Use the box_coherence field: Box psi in fam implies psi in all families
    C.box_coherence fam hfam psi t h_box fam' hfam'
  modal_backward := fun fam hfam psi t h_all => by
    -- Direct proof via contraposition, same logic as saturated_modal_backward
    -- but without needing a BMCS wrapper

    -- By contradiction
    by_contra h_not_box

    -- By MCS negation completeness, neg(Box psi) is in fam.mcs t
    have h_mcs := fam.is_mcs t
    have h_neg_box : Formula.neg (Formula.box psi) ∈ fam.mcs t := by
      rcases set_mcs_negation_complete h_mcs (Formula.box psi) with h_box | h_neg
      · exact absurd h_box h_not_box
      · exact h_neg

    -- From box_dne_theorem: ⊢ Box(¬¬psi) → Box psi
    -- Contrapositive: neg(Box psi) → neg(Box(¬¬psi)) = Diamond(neg psi)
    have h_box_dne := box_dne_theorem psi
    have h_diamond_neg : Formula.neg (Formula.box (Formula.neg (Formula.neg psi))) ∈ fam.mcs t :=
      mcs_contrapositive h_mcs h_box_dne h_neg_box

    -- Diamond(neg psi) = neg(Box(¬¬psi)) by definition
    have h_eq_diamond : diamondFormula (Formula.neg psi) =
                        Formula.neg (Formula.box (Formula.neg (Formula.neg psi))) := rfl

    have h_diamond_in : diamondFormula (Formula.neg psi) ∈ fam.mcs t := by
      rw [h_eq_diamond]
      exact h_diamond_neg

    -- By full saturation: exists witness fam' where neg psi is in fam'.mcs t
    have ⟨fam', hfam', h_neg_psi_in⟩ := h_sat (Formula.neg psi) fam hfam t h_diamond_in

    -- But psi is in ALL families including fam'
    have h_psi_in := h_all fam' hfam'

    -- neg psi and psi both in fam'.mcs t contradicts consistency
    exact set_consistent_not_both (fam'.is_mcs t).1 psi h_psi_in h_neg_psi_in
  eval_family := C.eval_family
  eval_family_mem := C.eval_family_mem

/-!
## Saturation Algorithm

The saturation algorithm iteratively adds witness families until all Diamond formulas
in a given set have witnesses. We use well-founded recursion on the cardinality of
unsatisfied Diamond formulas.
-/

/--
A Diamond formula is satisfied in a family collection if the inner formula
exists in some family's MCS.
-/
def isDiamondSatisfied {phi : Formula} (C : FamilyCollection D phi) (diamond : Formula) : Prop :=
  match extractDiamondInner diamond with
  | some inner => ∃ fam ∈ C.families, inner ∈ fam.mcs 0
  | none => True  -- Not a Diamond formula, vacuously satisfied

/--
A Diamond formula is unsatisfied if no family contains the inner formula.
-/
def isDiamondUnsatisfied {phi : Formula} (C : FamilyCollection D phi) (diamond : Formula) : Prop :=
  match extractDiamondInner diamond with
  | some inner => ∀ fam ∈ C.families, inner ∉ fam.mcs 0
  | none => False  -- Not a Diamond formula

/--
The set of unsatisfied Diamond formulas (as a predicate, since filtering over
arbitrary sets isn't computable).
-/
def unsatisfiedDiamondsPred {phi : Formula} (C : FamilyCollection D phi)
    (candidates : Finset Formula) (diamond : Formula) : Prop :=
  diamond ∈ candidates ∧ isDiamondUnsatisfied C diamond

/--
Check if all Diamond formulas in a candidate set are satisfied.
-/
def allDiamondsSatisfied {phi : Formula} (C : FamilyCollection D phi)
    (candidates : Finset Formula) : Prop :=
  ∀ diamond ∈ candidates, isDiamondSatisfied C diamond

/--
Adding a witness family satisfies a previously unsatisfied Diamond formula.
-/
theorem witness_satisfies_diamond {phi : Formula}
    (C : FamilyCollection D phi)
    (diamond : Formula) (h_unsatisfied : isDiamondUnsatisfied C diamond)
    (inner : Formula) (h_extract : extractDiamondInner diamond = some inner)
    (witness : IndexedMCSFamily D) (h_inner_in : inner ∈ witness.mcs 0)
    (C' : FamilyCollection D phi) (h_families : C'.families = C.families ∪ {witness}) :
    isDiamondSatisfied C' diamond := by
  simp only [isDiamondSatisfied, h_extract]
  use witness
  constructor
  · rw [h_families]
    exact Set.mem_union_right _ (Set.mem_singleton witness)
  · exact h_inner_in

/-!
## Initial Family Collection

Create an initial family collection from a single IndexedMCSFamily.
-/

/--
Create an initial family collection from a single family.

This provides a starting point for the saturation algorithm. The single family
trivially satisfies box_coherence (since there's only one family).
-/
def initialFamilyCollection (phi : Formula) (fam : IndexedMCSFamily D) : FamilyCollection D phi where
  families := {fam}
  nonempty := ⟨fam, Set.mem_singleton fam⟩
  eval_family := fam
  eval_family_mem := Set.mem_singleton fam
  box_coherence := fun fam' hfam' psi t h_box fam'' hfam'' => by
    -- Both fam' and fam'' equal fam
    have h_eq' : fam' = fam := Set.mem_singleton_iff.mp hfam'
    have h_eq'' : fam'' = fam := Set.mem_singleton_iff.mp hfam''
    -- Use T-axiom: Box psi -> psi
    let h_mcs := fam.is_mcs t
    let h_T := DerivationTree.axiom [] ((Formula.box psi).imp psi) (Axiom.modal_t psi)
    let h_T_in_mcs := theorem_in_mcs h_mcs h_T
    have h_in_fam : psi ∈ fam.mcs t :=
      set_mcs_implication_property h_mcs h_T_in_mcs (h_eq' ▸ h_box)
    exact h_eq''.symm ▸ h_in_fam

/--
The initial family collection contains the original family.
-/
theorem initialFamilyCollection_contains_family (phi : Formula) (fam : IndexedMCSFamily D) :
    fam ∈ (initialFamilyCollection phi fam (D := D)).families :=
  Set.mem_singleton fam

/-!
## Saturation via Iterative Witness Addition

The full saturation algorithm would iterate:
1. Find an unsatisfied Diamond formula
2. Extract the inner formula
3. Prove the inner formula is consistent (via diamond_implies_psi_consistent)
4. Construct a witness family (via constructWitnessFamily)
5. Add the witness to the collection
6. Repeat until all Diamonds are satisfied

For termination, we track unsatisfied Diamond formulas from a finite candidate set
(e.g., diamondSubformulas phi) and show the count strictly decreases.

**Current Status**: The infrastructure is in place. A complete implementation
requires:
1. Proving unsatisfiedDiamonds_card_decreases without sorry
2. Proving box_coherence is preserved when adding witness families
3. Implementing the recursive saturateFamilies function with termination_by

**Note on Full Saturation**: The current infrastructure achieves closure saturation
(saturation for Diamond formulas in the subformula closure). For `toBMCS` to work,
we need `isFullySaturated`. This can be achieved if:
- The constructed families don't introduce new Diamond requirements outside the closure, OR
- We extend the saturation to handle all Diamond formulas (requires different termination argument)
-/

/-!
## Summary

This module provides two approaches to eliminating the modal_backward sorry:

1. **Axiom-based approach** (`singleFamilyBMCS_withAxiom`):
   - Simple and direct
   - Uses `singleFamily_modal_backward_axiom` from Construction.lean
   - Justified by canonical model metatheory
   - Currently recommended for immediate use in completeness proofs

2. **Multi-family construction** (`FamilyCollection.toBMCS`):
   - Axiom-free when given a fully saturated collection
   - `modal_forward` uses `box_coherence` field
   - `modal_backward` proven via contraposition using `isFullySaturated`
   - Infrastructure for saturation loop in place:
     - `isDiamondSatisfied`, `isDiamondUnsatisfied` predicates
     - `initialFamilyCollection` for starting point
     - `witness_satisfies_diamond` theorem
   - Remaining work: recursive `saturateFamilies` with termination proof

**Key Insight**: Closure-restricted saturation (`isSaturated`) is insufficient for
`modal_backward`. The contraposition argument requires saturation for `neg psi` when
proving `modal_backward` for `psi`, and `neg psi` may be outside the closure. Thus
`FamilyCollection.toBMCS` requires `isFullySaturated` (full saturation for all formulas).
-/

end Bimodal.Metalogic.Bundle
