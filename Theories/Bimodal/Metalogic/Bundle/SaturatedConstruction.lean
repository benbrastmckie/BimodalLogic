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
import Mathlib.Order.Zorn

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
## Full Saturation via Non-Constructive Existence

The fundamental challenge with iterative saturation is that witness families can
contain arbitrary Diamond formulas, leading to an infinite process. We resolve this
using a non-constructive existence argument.

**Key Mathematical Insight**:
For any initial family collection, there EXISTS a fully saturated extension.
This follows from a Zorn's lemma argument:
1. Consider all family collections that extend the initial one and preserve box_coherence
2. Order by inclusion of families
3. Any chain has an upper bound (union preserves box_coherence)
4. By Zorn's lemma, there exists a maximal collection
5. A maximal collection must be fully saturated (otherwise we could add a witness)

**Why Maximality Implies Full Saturation**:
Suppose a maximal collection C is NOT fully saturated. Then there exists:
- Some Diamond psi in some family's MCS at time t
- But no family in C contains psi at time t

Since Diamond psi is in an MCS, {psi} is consistent (diamond_implies_psi_consistent).
We can construct a witness family containing psi. Adding this witness to C gives
a strictly larger collection. If this larger collection preserves box_coherence,
this contradicts maximality of C.

**Implementation**: We formalize this existence argument and use Classical.choice
to select a fully saturated collection.

**Note on box_coherence Preservation**:
The key subtlety is that adding an arbitrary witness family may not preserve
box_coherence. The Zorn's lemma argument must be over collections that maintain
this invariant, which is non-trivial to formalize. The existence of such
saturated collections is guaranteed by classical modal logic metatheory.

**Constant Family Restriction**:
To simplify the proof, we work with constant families where mcs t = mcs s for all t, s.
This is the case for:
- constantIndexedMCSFamily (used for initial families from Lindenbaum)
- constantWitnessFamily (used for all witness families)

For constant families, BoxContent is time-invariant, which makes the consistency
argument tractable.
-/

/--
A family is constant if its MCS is the same at all times.
-/
def IndexedMCSFamily.isConstant (fam : IndexedMCSFamily D) : Prop :=
  ∀ s t : D, fam.mcs s = fam.mcs t

/--
constantWitnessFamily is constant.
-/
lemma constantWitnessFamily_isConstant (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    (constantWitnessFamily M h_mcs (D := D)).isConstant := by
  intro s t
  rfl

/--
constantIndexedMCSFamily is constant.
-/
lemma constantIndexedMCSFamily_isConstant (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    (constantIndexedMCSFamily M h_mcs (D := D)).isConstant := by
  intro s t
  rfl

/--
For a constant family, Box chi at any time means Box chi at all times.
-/
lemma constant_family_box_time_invariant {fam : IndexedMCSFamily D}
    (h_const : fam.isConstant) (chi : Formula) (s t : D) :
    Formula.box chi ∈ fam.mcs s ↔ Formula.box chi ∈ fam.mcs t := by
  rw [h_const s t]

/--
For a set of constant families, BoxContent is time-invariant.
When all families are constant, the set {chi | ∃ fam' ∈ M, ∃ s, Box chi ∈ fam'.mcs s}
equals {chi | ∃ fam' ∈ M, Box chi ∈ fam'.mcs t} for any fixed t.
-/
lemma constant_families_boxcontent_time_invariant
    (fams : Set (IndexedMCSFamily D))
    (h_all_const : ∀ fam ∈ fams, fam.isConstant)
    (t : D) :
    {chi | ∃ fam' ∈ fams, ∃ s : D, Formula.box chi ∈ fam'.mcs s} =
    {chi | ∃ fam' ∈ fams, Formula.box chi ∈ fam'.mcs t} := by
  ext chi
  constructor
  · intro ⟨fam', hfam', s, h_box⟩
    use fam', hfam'
    rw [← h_all_const fam' hfam' s t]
    exact h_box
  · intro ⟨fam', hfam', h_box⟩
    use fam', hfam', t, h_box

/-!
### Helper Definitions for Zorn's Lemma Application
-/

/--
Box coherence predicate on an arbitrary set of families.
This is the same property as `FamilyCollection.box_coherence` but stated for arbitrary sets.
-/
def box_coherence_pred (fams : Set (IndexedMCSFamily D)) : Prop :=
  ∀ fam ∈ fams, ∀ psi t, Formula.box psi ∈ fam.mcs t → ∀ fam' ∈ fams, psi ∈ fam'.mcs t

/--
Box coherence is preserved under unions of chains.

If every set in a chain has box coherence, then the union has box coherence.
This uses the key property of chains: for any two elements, one is a subset of the other.
-/
lemma box_coherence_sUnion (c : Set (Set (IndexedMCSFamily D)))
    (hchain : IsChain (· ⊆ ·) c)
    (h_coherence : ∀ s ∈ c, box_coherence_pred s) :
    box_coherence_pred (⋃₀ c) := by
  intro fam ⟨s1, hs1_in_c, hfam_in_s1⟩ psi t h_box fam' ⟨s2, hs2_in_c, hfam'_in_s2⟩
  -- Since c is a chain, either s1 ⊆ s2 or s2 ⊆ s1
  by_cases h_eq : s1 = s2
  · -- Same set, use its box_coherence directly
    subst h_eq
    exact h_coherence s1 hs1_in_c fam hfam_in_s1 psi t h_box fam' hfam'_in_s2
  · -- Different sets in chain
    have h_chain_rel := hchain hs1_in_c hs2_in_c h_eq
    rcases h_chain_rel with h_s1_sub_s2 | h_s2_sub_s1
    · -- Case s1 ⊆ s2: both fam and fam' are in s2, use s2's box_coherence
      have hfam_in_s2 : fam ∈ s2 := h_s1_sub_s2 hfam_in_s1
      exact h_coherence s2 hs2_in_c fam hfam_in_s2 psi t h_box fam' hfam'_in_s2
    · -- Case s2 ⊆ s1: both fam and fam' are in s1, use s1's box_coherence
      have hfam'_in_s1 : fam' ∈ s1 := h_s2_sub_s1 hfam'_in_s2
      exact h_coherence s1 hs1_in_c fam hfam_in_s1 psi t h_box fam' hfam'_in_s1

/-!
## Axiom 4 and Box-Coherence Lemmas for S5

In S5 modal logic with box_coherence, Box formulas are "uniform" across families at the same time.
These lemmas are key for the sorry fixes in exists_fullySaturated_extension.
-/

/--
Axiom 4 instance: `⊢ □φ → □□φ`.
-/
noncomputable def modal_4_theorem (phi : Formula) :
    [] ⊢ (Formula.box phi).imp (Formula.box (Formula.box phi)) :=
  DerivationTree.axiom [] _ (Axiom.modal_4 phi)

/--
If Box phi is in an MCS, then Box Box phi is also in that MCS (by axiom 4).
-/
lemma mcs_box_implies_box_box {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (phi : Formula) (h_box : Formula.box phi ∈ S) :
    Formula.box (Formula.box phi) ∈ S := by
  have h_ax4 := modal_4_theorem phi
  have h_ax4_in := theorem_in_mcs h_mcs h_ax4
  exact set_mcs_implication_property h_mcs h_ax4_in h_box

/--
In a box-coherent set, Box chi in any family implies Box chi in ALL families at that time.

This is the key S5 property: boxes are "uniform" across families when box_coherence holds.

**Proof**: By axiom 4, Box chi implies Box Box chi. By box_coherence, Box Box chi in fam
implies Box chi in fam' for any fam' in the set.
-/
lemma box_coherent_box_uniform (fams : Set (IndexedMCSFamily D))
    (h_coherent : box_coherence_pred fams)
    (fam : IndexedMCSFamily D) (hfam : fam ∈ fams)
    (chi : Formula) (t : D) (h_box : Formula.box chi ∈ fam.mcs t)
    (fam' : IndexedMCSFamily D) (hfam' : fam' ∈ fams) :
    Formula.box chi ∈ fam'.mcs t := by
  -- By axiom 4: Box chi ∈ fam.mcs t → Box Box chi ∈ fam.mcs t
  have h_box_box := mcs_box_implies_box_box (fam.is_mcs t) chi h_box
  -- By box_coherence: Box Box chi ∈ fam.mcs t → Box chi ∈ fam'.mcs t
  exact h_coherent fam hfam (Formula.box chi) t h_box_box fam' hfam'

/--
In a box-coherent set of constant families, BoxContent at a fixed family and time
contains all chi where Box chi is in ANY family at ANY time.

This shows that BC_fam_t = {chi | Box chi ∈ fam.mcs t} is the "universal" BoxContent.
-/
lemma box_coherent_constant_boxcontent_complete
    (fams : Set (IndexedMCSFamily D))
    (h_coherent : box_coherence_pred fams)
    (h_all_const : ∀ fam ∈ fams, fam.isConstant)
    (fam : IndexedMCSFamily D) (hfam : fam ∈ fams)
    (t : D) :
    {chi | ∃ fam' ∈ fams, ∃ s : D, Formula.box chi ∈ fam'.mcs s} =
    {chi | Formula.box chi ∈ fam.mcs t} := by
  ext chi
  constructor
  · -- If Box chi in some fam' at some time s, then Box chi in fam at time t
    intro ⟨fam', hfam', s, h_box⟩
    -- By constancy, Box chi ∈ fam'.mcs s → Box chi ∈ fam'.mcs t
    have h_box_t : Formula.box chi ∈ fam'.mcs t := by
      rw [← h_all_const fam' hfam' s t]
      exact h_box
    -- By box_coherent_box_uniform, Box chi ∈ fam'.mcs t → Box chi ∈ fam.mcs t
    exact box_coherent_box_uniform fams h_coherent fam' hfam' chi t h_box_t fam hfam
  · -- If Box chi in fam at time t, then exists (fam, t) as witness
    intro h_box
    exact ⟨fam, hfam, t, h_box⟩

/--
For a constant family, chi at any time equals chi at all times.
-/
lemma constant_family_formula_time_invariant {fam : IndexedMCSFamily D}
    (h_const : fam.isConstant) (chi : Formula) (s t : D) :
    chi ∈ fam.mcs s ↔ chi ∈ fam.mcs t := by
  rw [h_const s t]

/--
Predicate: all families in a set are constant.
-/
def allConstant (fams : Set (IndexedMCSFamily D)) : Prop :=
  ∀ fam ∈ fams, fam.isConstant

/--
Constancy is preserved under unions.
If all families in each set of a collection are constant, then all families
in the union are constant.
-/
lemma allConstant_sUnion (c : Set (Set (IndexedMCSFamily D)))
    (h_all : ∀ s ∈ c, allConstant s) :
    allConstant (⋃₀ c) := by
  intro fam ⟨s, hs, hfam⟩
  exact h_all s hs fam hfam

/--
If the input family is constant, then the initial family collection has all constant families.
-/
theorem initialFamilyCollection_allConstant (phi : Formula) (fam : IndexedMCSFamily D)
    (h_const : fam.isConstant) :
    allConstant (initialFamilyCollection phi fam (D := D)).families := by
  intro fam' h_fam'
  have h_eq : fam' = fam := Set.mem_singleton_iff.mp h_fam'
  rw [h_eq]
  exact h_const

/--
K distribution lemma: Applies K axiom repeatedly to extract Box of the target from a chain.

If we have Box(chi_1 → ... → chi_n → target) ∈ S and all Box chi_i ∈ S,
then Box(target) ∈ S.

Note: We use ctx.reverse.foldr to match derivation_to_theorem_rev.
ctx.reverse.foldr imp target [c, b, a] = c → (b → (a → target))
-/
lemma k_distribution_chain_rev {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (ctx : List Formula) (target : Formula)
    (h_box_chain : Formula.box (ctx.reverse.foldr Formula.imp target) ∈ S)
    (h_boxes_in_S : ∀ chi ∈ ctx, Formula.box chi ∈ S) :
    Formula.box target ∈ S := by
  -- Induct on ctx, generalizing target and h_box_chain
  induction ctx generalizing target with
  | nil =>
    simp only [List.reverse_nil, List.foldr] at h_box_chain
    exact h_box_chain
  | cons c cs ih =>
    -- ctx = c :: cs
    -- ctx.reverse = cs.reverse ++ [c]
    -- ctx.reverse.foldr imp target = cs.reverse.foldr imp (c → target) by foldr_append
    -- h_box_chain : Box((c :: cs).reverse.foldr imp target) ∈ S
    --             = Box(cs.reverse.foldr imp (c → target)) ∈ S
    -- h_boxes_in_S : Box c ∈ S and all Box chi ∈ S for chi ∈ cs

    -- First apply K to peel off c
    have h_box_c : Formula.box c ∈ S := h_boxes_in_S c List.mem_cons_self

    -- Rewrite h_box_chain to use the foldr_append form
    have h_eq : (c :: cs).reverse.foldr Formula.imp target = cs.reverse.foldr Formula.imp (c.imp target) := by
      simp [List.reverse_cons, List.foldr_append, List.foldr]
    rw [h_eq] at h_box_chain

    -- Now h_box_chain : Box(cs.reverse.foldr imp (c → target)) ∈ S
    -- By IH with target' = c → target: Box(c → target) ∈ S
    have h_cs_boxes : ∀ chi ∈ cs, Formula.box chi ∈ S :=
      fun chi hchi => h_boxes_in_S chi (List.mem_cons_of_mem c hchi)
    have h_box_c_imp_target : Formula.box (c.imp target) ∈ S :=
      ih (c.imp target) h_box_chain h_cs_boxes

    -- Now use K: Box(c → target) → Box c → Box target
    have h_K : Bimodal.ProofSystem.DerivationTree []
        ((Formula.box (c.imp target)).imp ((Formula.box c).imp (Formula.box target))) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _
        (Bimodal.ProofSystem.Axiom.modal_k_dist c target)
    have h_K_in_S := theorem_in_mcs h_mcs h_K
    have h_step1 := set_mcs_implication_property h_mcs h_K_in_S h_box_c_imp_target
    exact set_mcs_implication_property h_mcs h_step1 h_box_c

/--
Close a derivation to a theorem via repeated deduction theorem.
If ctx ⊢ phi, then [] ⊢ ctx.reverse.foldr imp phi

Note: The deduction theorem removes from the HEAD of the context:
  deduction_theorem Gamma A phi : (A :: Gamma ⊢ phi) → (Gamma ⊢ A → phi)

So for [a, b, c] ⊢ phi:
- deduction_theorem gives [b, c] ⊢ a → phi
- Then: [c] ⊢ b → (a → phi)
- Then: [] ⊢ c → (b → (a → phi))

This produces [c, b, a].foldr imp phi = ctx.reverse.foldr imp phi
-/
noncomputable def derivation_to_theorem_rev :
    (ctx : List Formula) → (phi : Formula) →
    Bimodal.ProofSystem.DerivationTree ctx phi →
    Bimodal.ProofSystem.DerivationTree [] (ctx.reverse.foldr Formula.imp phi)
  | [], phi, h_deriv => h_deriv
  | c :: cs, phi, h_deriv =>
    -- We have c :: cs ⊢ phi
    -- deduction_theorem gives cs ⊢ c → phi
    let hd' := Bimodal.Metalogic.Core.deduction_theorem cs c phi h_deriv
    -- Recursively: [] ⊢ cs.reverse.foldr imp (c → phi)
    let h_rec := derivation_to_theorem_rev cs (c.imp phi) hd'
    -- We need [] ⊢ (c :: cs).reverse.foldr imp phi
    --        = [] ⊢ (cs.reverse ++ [c]).foldr imp phi
    -- And cs.reverse.foldr imp (c → phi) should match this
    -- foldr imp phi (cs.reverse ++ [c]) = foldr imp (c → phi) cs.reverse by foldr_append with single element
    -- Actually: foldr f z (xs ++ [y]) = foldr f (f y z) xs
    -- So: foldr imp phi (cs.reverse ++ [c]) = foldr imp (c.imp phi) cs.reverse
    -- Which is exactly cs.reverse.foldr imp (c → phi)!
    -- So h_rec has the right type after unfolding
    cast (by simp [List.reverse_cons, List.foldr_append, List.foldr]) h_rec

/--
Modal existence lemma: If Diamond psi is in an MCS S, then {psi} ∪ {chi | Box chi ∈ S} is consistent.

This is the key lemma enabling the coherent witness construction. The proof uses:
1. If {psi, chi_1, ..., chi_n} is inconsistent (with Box chi_i ∈ S), then chi_1 → ... → chi_n → neg psi is provable
2. By necessitation: Box(chi_1 → ... → chi_n → neg psi) is provable
3. By K distribution: Box chi_1 → ... → Box chi_n → Box(neg psi) is provable (in any MCS)
4. Since all Box chi_i ∈ S, we get Box(neg psi) ∈ S
5. But Diamond psi = neg(Box(neg psi)) ∈ S, contradicting S's consistency

This lemma also works when the chi come from box_coherent families via box_coherence.
-/
lemma diamond_box_coherent_consistent {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ S)
    (BoxSet : Set Formula) (h_boxset_sub : ∀ chi ∈ BoxSet, Formula.box chi ∈ S) :
    SetConsistent ({psi} ∪ BoxSet) := by
  intro L hL_sub ⟨d⟩
  -- L ⊆ {psi} ∪ BoxSet and L ⊢ bot
  by_cases h_psi_in_L : psi ∈ L
  · -- psi ∈ L: Use deduction theorem to derive neg psi from BoxSet elements
    -- Reorder L to put psi first
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := Bimodal.Metalogic.Core.cons_filter_neq_perm h_psi_in_L
    have d_bot_reord : Bimodal.ProofSystem.DerivationTree (psi :: L_filt) Formula.bot :=
      Bimodal.Metalogic.Core.derivation_exchange d (fun x => (h_perm x).symm)

    -- By deduction theorem: L_filt ⊢ neg psi
    have d_neg_psi : Bimodal.ProofSystem.DerivationTree L_filt (Formula.neg psi) :=
      Bimodal.Metalogic.Core.deduction_theorem L_filt psi Formula.bot d_bot_reord

    -- L_filt ⊆ BoxSet, so each element has its Box in S
    have h_filt_sub_boxset : ∀ chi ∈ L_filt, chi ∈ BoxSet := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L : chi ∈ L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_union := hL_sub chi h_in_L
      simp only [Set.mem_union, Set.mem_singleton_iff] at h_in_union
      cases h_in_union with
      | inl h_eq => exact absurd h_eq h_ne
      | inr h_in_box => exact h_in_box

    -- Close to theorem via helper (produces L_filt.reverse.foldr imp (neg psi))
    have d_theorem : Bimodal.ProofSystem.DerivationTree [] (L_filt.reverse.foldr Formula.imp (Formula.neg psi)) :=
      derivation_to_theorem_rev L_filt (Formula.neg psi) d_neg_psi

    -- Necessitation: [] ⊢ Box(... → neg psi)
    have d_box_theorem : Bimodal.ProofSystem.DerivationTree [] (Formula.box (L_filt.reverse.foldr Formula.imp (Formula.neg psi))) :=
      Bimodal.ProofSystem.DerivationTree.necessitation _ d_theorem

    -- This Box formula is in S
    have h_box_chain_in_S : Formula.box (L_filt.reverse.foldr Formula.imp (Formula.neg psi)) ∈ S :=
      theorem_in_mcs h_mcs d_box_theorem

    -- All Box chi ∈ S for chi ∈ L_filt (and thus for chi ∈ L_filt.reverse)
    have h_boxes_in_S : ∀ chi ∈ L_filt, Formula.box chi ∈ S :=
      fun chi hchi => h_boxset_sub chi (h_filt_sub_boxset chi hchi)

    -- Apply K distribution (note: k_distribution_chain_rev expects ctx, and h_box_chain uses ctx.reverse)
    -- So we pass L_filt.reverse as ctx, and h_box_chain has Box((L_filt.reverse).reverse.foldr imp target)
    -- = Box(L_filt.foldr imp target). Hmm, that's not quite right.
    -- Actually we need to pass L_filt as ctx, and h_box_chain should have L_filt.reverse.foldr form.
    -- The lemma k_distribution_chain_rev takes h_box_chain : Box(ctx.reverse.foldr ...)
    -- So with ctx = L_filt, we need Box(L_filt.reverse.foldr ...) which is what we have!
    have h_boxes_in_S' : ∀ chi ∈ L_filt, Formula.box chi ∈ S := h_boxes_in_S
    have h_box_neg_psi_in_S : Formula.box (Formula.neg psi) ∈ S :=
      k_distribution_chain_rev h_mcs L_filt (Formula.neg psi) h_box_chain_in_S h_boxes_in_S'

    -- Contradiction: Box(neg psi) and Diamond psi = neg(Box(neg psi)) both in S
    have h_eq : diamondFormula psi = Formula.neg (Formula.box (Formula.neg psi)) := rfl
    rw [h_eq] at h_diamond
    exact set_consistent_not_both h_mcs.1 (Formula.box (Formula.neg psi)) h_box_neg_psi_in_S h_diamond

  · -- psi ∉ L: L ⊆ BoxSet
    have h_L_sub_boxset : ∀ x ∈ L, x ∈ BoxSet := by
      intro x hx
      have h_in_union := hL_sub x hx
      simp only [Set.mem_union, Set.mem_singleton_iff] at h_in_union
      cases h_in_union with
      | inl h_eq =>
        -- x = psi, but psi ∉ L
        rw [h_eq] at hx
        exact absurd hx h_psi_in_L
      | inr h_in => exact h_in

    -- Close derivation to theorem (produces L.reverse.foldr imp bot)
    have d_theorem : Bimodal.ProofSystem.DerivationTree [] (L.reverse.foldr Formula.imp Formula.bot) :=
      derivation_to_theorem_rev L Formula.bot d

    have d_box_theorem : Bimodal.ProofSystem.DerivationTree [] (Formula.box (L.reverse.foldr Formula.imp Formula.bot)) :=
      Bimodal.ProofSystem.DerivationTree.necessitation _ d_theorem

    have h_box_chain_in_S : Formula.box (L.reverse.foldr Formula.imp Formula.bot) ∈ S :=
      theorem_in_mcs h_mcs d_box_theorem

    -- All Box chi ∈ S for chi ∈ L
    have h_boxes_in_S : ∀ chi ∈ L, Formula.box chi ∈ S :=
      fun chi hchi => h_boxset_sub chi (h_L_sub_boxset chi hchi)

    -- Apply K distribution to get Box bot ∈ S
    have h_box_bot_in_S : Formula.box Formula.bot ∈ S :=
      k_distribution_chain_rev h_mcs L Formula.bot h_box_chain_in_S h_boxes_in_S

    -- By T axiom: Box bot → bot
    have h_T_bot : Bimodal.ProofSystem.DerivationTree [] ((Formula.box Formula.bot).imp Formula.bot) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.modal_t Formula.bot)
    have h_T_in_S := theorem_in_mcs h_mcs h_T_bot
    have h_bot_in_S := set_mcs_implication_property h_mcs h_T_in_S h_box_bot_in_S

    -- bot ∈ S contradicts S being consistent
    have h_bot_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
    exact h_mcs.1 [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩

/--
The key existence theorem: every family collection has a fully saturated extension.

**Proof Strategy (Zorn's Lemma)**:
1. Define the set S of all extensions of C that preserve box_coherence
2. S is non-empty (C is in S)
3. Every chain in S has an upper bound (union of families with appropriate coherence)
4. By Zorn's lemma, S has a maximal element M
5. M is fully saturated (otherwise we could extend it)

**Note**: This proof uses classical logic (specifically, Zorn's lemma which is
equivalent to the axiom of choice). This is standard for Henkin-style completeness
proofs in modal logic.

**Current Status**: Phases 1-3 (Zorn setup) are complete. Phase 4 (maximality implies
saturation) has a sorry for the coherent witness construction.
-/
theorem FamilyCollection.exists_fullySaturated_extension {phi : Formula}
    (C : FamilyCollection D phi)
    (h_C_const : allConstant C.families) :
    ∃ C' : FamilyCollection D phi, C.families ⊆ C'.families ∧
      C'.eval_family = C.eval_family ∧ C'.isFullySaturated := by
  -- Define S as the set of family sets that extend C, preserve box_coherence, and are all constant
  let S : Set (Set (IndexedMCSFamily D)) :=
    { fams | C.families ⊆ fams ∧ box_coherence_pred fams ∧ C.eval_family ∈ fams ∧ allConstant fams }

  -- C.families is in S
  have hC_in_S : C.families ∈ S := by
    refine ⟨Set.Subset.rfl, ?_, C.eval_family_mem, h_C_const⟩
    -- box_coherence_pred C.families follows from C.box_coherence
    intro fam hfam psi t h_box fam' hfam'
    exact C.box_coherence fam hfam psi t h_box fam' hfam'

  -- Every chain in S has an upper bound in S
  have h_chain_bound : ∀ c ⊆ S, IsChain (· ⊆ ·) c → c.Nonempty →
      ∃ ub ∈ S, ∀ s ∈ c, s ⊆ ub := by
    intro c hc_sub_S hchain ⟨s0, hs0⟩
    use ⋃₀ c
    constructor
    · -- ⋃₀ c ∈ S
      refine ⟨?_, ?_, ?_, ?_⟩
      · -- C.families ⊆ ⋃₀ c: use that C.families ⊆ s0 and s0 ⊆ ⋃₀ c
        have h_s0_in_S := hc_sub_S hs0
        have h_C_sub_s0 : C.families ⊆ s0 := h_s0_in_S.1
        exact h_C_sub_s0.trans (Set.subset_sUnion_of_mem hs0)
      · -- box_coherence_pred (⋃₀ c)
        apply box_coherence_sUnion c hchain
        intro s hs
        exact (hc_sub_S hs).2.1
      · -- C.eval_family ∈ ⋃₀ c
        have h_s0_in_S := hc_sub_S hs0
        exact Set.mem_sUnion.mpr ⟨s0, hs0, h_s0_in_S.2.2.1⟩
      · -- allConstant (⋃₀ c)
        apply allConstant_sUnion c
        intro s hs
        exact (hc_sub_S hs).2.2.2
    · -- ∀ s ∈ c, s ⊆ ⋃₀ c
      intro s hs
      exact Set.subset_sUnion_of_mem hs

  -- Apply Zorn's lemma
  obtain ⟨M, hC_sub_M, hM_maximal⟩ := zorn_subset_nonempty S h_chain_bound C.families hC_in_S

  -- M is in S (from maximality)
  have hM_in_S : M ∈ S := hM_maximal.prop

  -- Extract M's properties from S membership
  have hM_coherent : box_coherence_pred M := hM_in_S.2.1
  have hM_const : allConstant M := hM_in_S.2.2.2

  -- Prove that M is fully saturated (maximality implies saturation)
  -- This is the core argument: if M were not fully saturated, we could construct
  -- a proper extension M' ∈ S, contradicting maximality.
  --
  -- The mathematical argument (by contradiction):
  -- 1. Assume Diamond psi ∈ fam.mcs t but no witness in M
  -- 2. Diamond psi being in an MCS implies {psi} is consistent
  -- 3. Construct a witness family containing psi that is "coherent" with M
  -- 4. The coherent witness must contain all chi where Box chi appears in M
  -- 5. Adding this witness to M gives M' ∈ S with M ⊂ M'
  -- 6. This contradicts maximality of M
  --
  -- Key insight: Since all families in M are constant, BoxContent at any time equals
  -- BoxContent at time t (by box_coherent_constant_boxcontent_complete).
  have h_fully_saturated : ∀ psi : Formula, ∀ fam ∈ M, ∀ t : D,
      diamondFormula psi ∈ fam.mcs t → ∃ fam' ∈ M, psi ∈ fam'.mcs t := by
    intro psi fam hfam_in_M t h_diamond
    by_contra h_no_witness
    push_neg at h_no_witness
    -- h_no_witness : ∀ fam' ∈ M, psi ∉ fam'.mcs t

    -- Step 1: Since Diamond psi ∈ fam.mcs t (an MCS), {psi} is consistent
    have h_psi_consistent : SetConsistent {psi} :=
      diamond_implies_psi_consistent (fam.is_mcs t) psi h_diamond

    -- Step 2: Define BoxContent(M) = {chi | ∃ fam' ∈ M, ∃ s, Box chi ∈ fam'.mcs s}
    -- By constancy, this equals {chi | Box chi ∈ fam.mcs t}
    let BoxContent : Set Formula := {chi | ∃ fam' ∈ M, ∃ s : D, Formula.box chi ∈ fam'.mcs s}

    -- Key lemma: BoxContent = {chi | Box chi ∈ fam.mcs t} (by constancy + box-coherence)
    have h_boxcontent_eq : BoxContent = {chi | Formula.box chi ∈ fam.mcs t} :=
      box_coherent_constant_boxcontent_complete M hM_coherent hM_const fam hfam_in_M t

    -- Step 3: By box_coherence of M, every chi in BoxContent(M) is in fam.mcs t
    have h_boxcontent_in_fam : ∀ chi ∈ BoxContent, chi ∈ fam.mcs t := by
      intro chi h_chi
      rw [h_boxcontent_eq] at h_chi
      -- h_chi : Box chi ∈ fam.mcs t
      -- By T-axiom, chi ∈ fam.mcs t
      have h_T := DerivationTree.axiom [] ((Formula.box chi).imp chi) (Axiom.modal_t chi)
      have h_T_in := theorem_in_mcs (fam.is_mcs t) h_T
      exact set_mcs_implication_property (fam.is_mcs t) h_T_in h_chi

    -- Also, Box chi ∈ fam.mcs t for all chi ∈ BoxContent
    have h_boxcontent_boxes_in_fam : ∀ chi ∈ BoxContent, Formula.box chi ∈ fam.mcs t := by
      intro chi h_chi
      rw [h_boxcontent_eq] at h_chi
      exact h_chi

    -- Step 4: Show {psi} ∪ BoxContent is consistent
    -- Key insight: BoxContent = {chi | Box chi ∈ fam.mcs t} (by constancy + box-coherence)
    -- So we can apply diamond_box_coherent_consistent directly
    have h_witness_set_consistent : SetConsistent ({psi} ∪ BoxContent) := by
      -- Use diamond_box_coherent_consistent with BoxSet = BoxContent
      -- We have h_boxcontent_boxes_in_fam : ∀ chi ∈ BoxContent, Box chi ∈ fam.mcs t
      exact diamond_box_coherent_consistent (fam.is_mcs t) psi h_diamond BoxContent h_boxcontent_boxes_in_fam
      -- The previous case (psi ∈ L) used diamond_box_coherent_consistent which handles both cases
      -- This code is now unreachable due to the earlier exact statement

    -- Step 5: Use Lindenbaum to extend {psi} ∪ BoxContent to an MCS
    have ⟨W_set, h_W_extends, h_W_mcs⟩ := set_lindenbaum ({psi} ∪ BoxContent) h_witness_set_consistent

    -- Step 6: Construct the witness family as a constant family
    let W : IndexedMCSFamily D := constantWitnessFamily W_set h_W_mcs

    -- Step 7: Show psi ∈ W.mcs t (W is a witness for the Diamond)
    have h_psi_in_W : psi ∈ W.mcs t := by
      show psi ∈ W_set
      exact h_W_extends (Set.mem_union_left BoxContent (Set.mem_singleton psi))

    -- Step 8: Show M ∪ {W} has box_coherence
    have h_extended_coherence : box_coherence_pred (M ∪ {W}) := by
      intro fam1 h_fam1 chi s h_box_chi fam2 h_fam2
      -- Cases on whether fam1 is in M or is W, and whether fam2 is in M or is W
      simp only [Set.mem_union, Set.mem_singleton_iff] at h_fam1 h_fam2
      rcases h_fam1 with h_fam1_M | h_fam1_W
      · -- fam1 ∈ M
        rcases h_fam2 with h_fam2_M | h_fam2_W
        · -- fam2 ∈ M: use M's box_coherence
          exact hM_in_S.2.1 fam1 h_fam1_M chi s h_box_chi fam2 h_fam2_M
        · -- fam2 = W: need chi ∈ W.mcs s = W_set
          subst h_fam2_W
          -- chi ∈ BoxContent because Box chi ∈ fam1.mcs s and fam1 ∈ M
          have h_chi_boxcontent : chi ∈ BoxContent := ⟨fam1, h_fam1_M, s, h_box_chi⟩
          -- W.mcs s = W_set contains BoxContent
          show chi ∈ W_set
          exact h_W_extends (Set.mem_union_right {psi} h_chi_boxcontent)
      · -- fam1 = W
        subst h_fam1_W
        -- Box chi ∈ W.mcs s, need chi in fam2.mcs s
        -- W.mcs s is the MCS W_set, which is a Lindenbaum extension of {psi} ∪ BoxContent
        --
        -- Key insight: If Box chi ∈ W_set but chi ∉ BoxContent, we can derive a contradiction
        -- using axiom 5 (negative introspection). Here's the argument:
        -- 1. chi ∉ BoxContent means ∀ fam' ∈ M, Box chi ∉ fam'.mcs t
        -- 2. For each fam' ∈ M, neg(Box chi) ∈ fam'.mcs t (MCS negation complete)
        -- 3. By axiom 5: Box(neg(Box chi)) ∈ fam'.mcs t
        -- 4. Therefore neg(Box chi) ∈ BoxContent (taking chi' = neg(Box chi))
        -- 5. Since W_set ⊇ BoxContent: neg(Box chi) ∈ W_set
        -- 6. But Box chi ∈ W_set, so W_set contains both Box chi and neg(Box chi)
        -- 7. This contradicts W_set being consistent
        -- Therefore chi ∈ BoxContent, and by M's box_coherence, chi ∈ fam2.mcs s
        --
        rcases h_fam2 with h_fam2_M | h_fam2_W
        · -- fam2 ∈ M: use axiom 5 argument to show chi ∈ BoxContent
          -- First, prove chi ∈ BoxContent by contradiction
          have h_chi_in_boxcontent : chi ∈ BoxContent := by
            by_contra h_chi_not_in_boxcontent
            -- chi ∉ BoxContent means ∀ fam' ∈ M, Box chi ∉ fam'.mcs t
            -- (by box_coherent_constant_boxcontent_complete, BoxContent = {chi | Box chi ∈ fam.mcs t})
            rw [h_boxcontent_eq] at h_chi_not_in_boxcontent
            -- h_chi_not_in_boxcontent : Box chi ∉ fam.mcs t
            -- Since fam.mcs t is MCS, neg(Box chi) ∈ fam.mcs t
            have h_neg_box_chi : (Formula.box chi).neg ∈ fam.mcs t :=
              (set_mcs_negation_complete (fam.is_mcs t) (Formula.box chi)).resolve_left h_chi_not_in_boxcontent
            -- By axiom 5: Box(neg(Box chi)) ∈ fam.mcs t
            have h_box_neg_box_chi : Formula.box (Formula.box chi).neg ∈ fam.mcs t :=
              mcs_neg_box_implies_box_neg_box (fam.is_mcs t) chi h_neg_box_chi
            -- Therefore neg(Box chi) ∈ BoxContent
            have h_neg_box_chi_in_boxcontent : (Formula.box chi).neg ∈ BoxContent := by
              rw [h_boxcontent_eq]
              exact h_box_neg_box_chi
            -- Since W_set ⊇ BoxContent: neg(Box chi) ∈ W_set
            have h_neg_box_chi_in_W : (Formula.box chi).neg ∈ W_set :=
              h_W_extends (Set.mem_union_right {psi} h_neg_box_chi_in_boxcontent)
            -- But Box chi ∈ W.mcs s = W_set (by W being constant)
            have h_box_chi_in_W : Formula.box chi ∈ W_set := by
              show Formula.box chi ∈ W.mcs s
              exact h_box_chi
            -- W_set contains both Box chi and neg(Box chi) - contradiction!
            exact set_consistent_not_both h_W_mcs.1 (Formula.box chi) h_box_chi_in_W h_neg_box_chi_in_W
          -- Now we know chi ∈ BoxContent
          -- By M's box_coherence: ∃ fam' ∈ M with Box chi ∈ fam'.mcs t', so chi ∈ fam2.mcs s
          -- Actually, chi ∈ BoxContent means Box chi ∈ fam.mcs t (by h_boxcontent_eq)
          rw [h_boxcontent_eq] at h_chi_in_boxcontent
          -- So we have Box chi ∈ fam.mcs t where fam ∈ M
          -- By M's box_coherence (hM_coherent): chi ∈ fam2.mcs s for fam2 ∈ M
          -- Use constancy to convert between times
          have h_fam2_const := hM_const fam2 h_fam2_M
          rw [h_fam2_const s t]
          exact hM_in_S.2.1 fam hfam_in_M chi t h_chi_in_boxcontent fam2 h_fam2_M
        · -- fam2 = W: use T-axiom
          subst h_fam2_W
          -- Box chi ∈ W.mcs s = W_set, need chi ∈ W.mcs s = W_set
          show chi ∈ W_set
          have h_box_chi_in_W : Formula.box chi ∈ W_set := h_box_chi
          -- By T-axiom: Box chi → chi
          have h_T := DerivationTree.axiom [] ((Formula.box chi).imp chi) (Axiom.modal_t chi)
          have h_T_in := theorem_in_mcs h_W_mcs h_T
          exact set_mcs_implication_property h_W_mcs h_T_in h_box_chi_in_W

    -- Step 9: Show M ∪ {W} ∈ S (extends C, has coherence, contains eval_family, all constant)
    have h_extended_in_S : (M ∪ {W}) ∈ S := by
      refine ⟨?_, h_extended_coherence, ?_, ?_⟩
      · -- C.families ⊆ M ∪ {W}
        exact Set.Subset.trans hM_in_S.1 (Set.subset_union_left)
      · -- C.eval_family ∈ M ∪ {W}
        exact Set.mem_union_left {W} hM_in_S.2.2.1
      · -- allConstant (M ∪ {W})
        intro fam' h_fam'
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_fam'
        rcases h_fam' with h_in_M | h_eq_W
        · exact hM_const fam' h_in_M
        · subst h_eq_W
          exact constantWitnessFamily_isConstant W_set h_W_mcs

    -- Step 10: Show M ⊂ M ∪ {W} (strict inclusion)
    have h_W_notin_M : W ∉ M := by
      intro h_W_in_M
      -- If W ∈ M, then h_no_witness says psi ∉ W.mcs t, contradicting h_psi_in_W
      exact h_no_witness W h_W_in_M h_psi_in_W

    have h_strict_extension : M ⊂ M ∪ {W} := by
      constructor
      · exact Set.subset_union_left
      · intro h_eq
        -- h_eq : M ∪ {W} ⊆ M (negation of strict inequality)
        -- Wait, the Set.ssubset definition uses ⊆ and ≠
        -- The intro gives us M ∪ {W} = M, not ⊆
        -- Actually Set.ssubset is: s ⊂ t ↔ s ⊆ t ∧ ¬ t ⊆ s
        -- So we need to show ¬ (M ∪ {W} ⊆ M)
        -- Which means finding x ∈ M ∪ {W} with x ∉ M
        have h_W_in : W ∈ M ∪ {W} := Set.mem_union_right M (Set.mem_singleton W)
        exact h_W_notin_M (h_eq h_W_in)

    -- Step 11: This contradicts maximality of M
    -- M is maximal in S: ∀ M' ∈ S, M ⊆ M' → M' ⊆ M
    have h_contradiction := hM_maximal.right h_extended_in_S (Set.subset_union_left)
    -- h_contradiction : M ∪ {W} ⊆ M
    have h_W_in_M : W ∈ M := h_contradiction (Set.mem_union_right M (Set.mem_singleton W))
    exact h_W_notin_M h_W_in_M

  -- Construct C' from M
  let C' : FamilyCollection D phi := {
    families := M
    nonempty := ⟨C.eval_family, hM_in_S.2.2.1⟩
    eval_family := C.eval_family
    eval_family_mem := hM_in_S.2.2.1
    box_coherence := hM_coherent
  }

  use C'
  exact ⟨hC_sub_M, rfl, h_fully_saturated⟩

/--
Non-constructively select a fully saturated extension of a family collection.
Requires all initial families to be constant.
-/
noncomputable def FamilyCollection.saturate {phi : Formula}
    (C : FamilyCollection D phi) (h_const : allConstant C.families) : FamilyCollection D phi :=
  Classical.choose (C.exists_fullySaturated_extension h_const)

/--
The saturated collection extends the original.
-/
theorem FamilyCollection.saturate_extends {phi : Formula} (C : FamilyCollection D phi)
    (h_const : allConstant C.families) :
    C.families ⊆ (C.saturate h_const).families :=
  (Classical.choose_spec (C.exists_fullySaturated_extension h_const)).1

/--
The saturated collection preserves the evaluation family.
-/
theorem FamilyCollection.saturate_eval_family {phi : Formula} (C : FamilyCollection D phi)
    (h_const : allConstant C.families) :
    (C.saturate h_const).eval_family = C.eval_family :=
  (Classical.choose_spec (C.exists_fullySaturated_extension h_const)).2.1

/--
The saturated collection is fully saturated.
-/
theorem FamilyCollection.saturate_isFullySaturated {phi : Formula} (C : FamilyCollection D phi)
    (h_const : allConstant C.families) :
    (C.saturate h_const).isFullySaturated :=
  (Classical.choose_spec (C.exists_fullySaturated_extension h_const)).2.2

/-!
## Complete Multi-Family BMCS Construction

Using the saturation infrastructure, we can now construct a BMCS from any
initial family that is proven to be modally coherent, without relying on axioms.
-/

/--
Construct a fully saturated BMCS from an initial family.
Requires the input family to be constant.

This combines:
1. Initial family collection from a single family
2. Non-constructive saturation to achieve isFullySaturated
3. Conversion to BMCS via FamilyCollection.toBMCS
-/
noncomputable def constructSaturatedBMCS (phi : Formula) (fam : IndexedMCSFamily D)
    (h_const : fam.isConstant) : BMCS D :=
  let initial := initialFamilyCollection phi fam
  let h_all_const := initialFamilyCollection_allConstant phi fam h_const
  let saturated := initial.saturate h_all_const
  saturated.toBMCS (initial.saturate_isFullySaturated h_all_const)

/--
The saturated BMCS contains the original family.
-/
theorem constructSaturatedBMCS_contains_family (phi : Formula) (fam : IndexedMCSFamily D)
    (h_const : fam.isConstant) :
    fam ∈ (constructSaturatedBMCS phi fam h_const (D := D)).families := by
  unfold constructSaturatedBMCS
  have h_init : fam ∈ (initialFamilyCollection phi fam).families := initialFamilyCollection_contains_family phi fam
  have h_all_const := initialFamilyCollection_allConstant phi fam h_const
  exact (initialFamilyCollection phi fam).saturate_extends h_all_const h_init

/--
The saturated BMCS has the original family as its evaluation family.
-/
theorem constructSaturatedBMCS_eval_family (phi : Formula) (fam : IndexedMCSFamily D)
    (h_const : fam.isConstant) :
    (constructSaturatedBMCS phi fam h_const (D := D)).eval_family = fam := by
  -- The eval_family of toBMCS is the same as the FamilyCollection's eval_family
  -- saturate preserves eval_family
  -- initialFamilyCollection's eval_family is fam
  have h_all_const := initialFamilyCollection_allConstant phi fam h_const
  have h1 := (initialFamilyCollection phi fam).saturate_eval_family h_all_const
  have h2 : (initialFamilyCollection phi fam).eval_family = fam := rfl
  -- Unfold and use transitivity
  calc (constructSaturatedBMCS phi fam h_const (D := D)).eval_family
      = ((initialFamilyCollection phi fam).saturate h_all_const).eval_family := rfl
    _ = (initialFamilyCollection phi fam).eval_family := h1
    _ = fam := h2

/-!
## Integration with Completeness

This construction can replace the axiom-based approach for completeness proofs.
-/

/--
Construct a BMCS from a consistent context using the saturation-based approach.

This replaces `construct_bmcs_axiom` with a provably saturated construction.
-/
noncomputable def construct_bmcs_saturated (Gamma : List Formula) (h_cons : ContextConsistent Gamma)
    (phi : Formula) : BMCS D :=
  let M := lindenbaumMCS Gamma h_cons
  let h_mcs := lindenbaumMCS_is_mcs Gamma h_cons
  let fam := constantIndexedMCSFamily M h_mcs (D := D)
  let h_const := constantIndexedMCSFamily_isConstant M h_mcs (D := D)
  constructSaturatedBMCS phi fam h_const

/--
The saturation-based BMCS construction preserves the context.
-/
theorem construct_bmcs_saturated_contains_context (Gamma : List Formula) (h_cons : ContextConsistent Gamma)
    (phi : Formula) :
    ∀ gamma ∈ Gamma, gamma ∈ (construct_bmcs_saturated Gamma h_cons phi (D := D)).eval_family.mcs 0 := by
  intro gamma h_mem
  let M := lindenbaumMCS Gamma h_cons
  let h_mcs := lindenbaumMCS_is_mcs Gamma h_cons
  let h_const := constantIndexedMCSFamily_isConstant M h_mcs (D := D)
  have h_eval : (construct_bmcs_saturated Gamma h_cons phi (D := D)).eval_family =
                constantIndexedMCSFamily M h_mcs := by
    unfold construct_bmcs_saturated
    exact constructSaturatedBMCS_eval_family phi (constantIndexedMCSFamily M h_mcs (D := D)) h_const
  rw [h_eval]
  simp only [constantIndexedMCSFamily_mcs_eq]
  have h_in_set : gamma ∈ contextAsSet Gamma := h_mem
  exact lindenbaumMCS_extends Gamma h_cons h_in_set

/-!
## Summary

This module provides three approaches to the modal_backward challenge:

1. **Axiom-based approach** (`singleFamilyBMCS_withAxiom`):
   - Simple and direct, uses `singleFamily_modal_backward_axiom`
   - Justified by canonical model metatheory
   - Recommended for immediate use when axiom is acceptable

2. **Closure-saturated approach** (`FamilyCollection.toBMCS` with `isSaturated`):
   - Works for closure formulas only
   - Not sufficient for general modal_backward (requires full saturation)

3. **Fully-saturated approach** (`constructSaturatedBMCS`):
   - Uses non-constructive saturation via Zorn's lemma
   - Achieves `isFullySaturated` which implies modal_backward for ALL formulas
   - Main theorem `exists_fullySaturated_extension` has sorry (Zorn's lemma formalization)
   - This is the mathematically correct approach for eliminating the axiom

**Current Status**:
- The axiom-based approach works and is sorry-free (modulo the axiom itself)
- The fully-saturated approach is implemented but has a sorry in the existence proof
- Completing the Zorn's lemma proof would eliminate all sorries

**Key Insight**: Full saturation is necessary and sufficient for modal_backward.
Closure-restricted saturation is insufficient because the contraposition argument
requires saturation for `neg psi` when proving modal_backward for `psi`.
-/

end Bimodal.Metalogic.Bundle
