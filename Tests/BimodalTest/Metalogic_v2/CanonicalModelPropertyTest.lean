import Bimodal.Metalogic_v2.Representation.CanonicalModel
import Bimodal.Metalogic_v2.Representation.RepresentationTheorem
import Bimodal.Metalogic_v2.Representation.SemanticCanonicalModel
import Bimodal.Metalogic_v2.Core.MaximalConsistent
import Bimodal.Metalogic_v2.Soundness.Soundness

/-!
# Canonical Model Property Tests for Metalogic_v2

Property-based tests for canonical model construction and coherence in Metalogic_v2, including:
- CanonicalWorldState type construction
- CanonicalFrame and CanonicalModel definitions
- canonicalFrame accessibility relation properties
- MCS properties via CanonicalModel API
- SemanticCanonicalModel tests
- main_provable_iff_valid_v2 round-trip property

## Test Organization

- **CanonicalWorldState Tests**: Test type construction and carrier access
- **CanonicalFrame Tests**: Test frame construction and accessibility
- **CanonicalModel Tests**: Test model construction and valuation
- **MCS Property Tests**: Test mcs_contains_or_neg, mcs_modus_ponens via model API
- **SemanticCanonicalModel Tests**: Test SemanticWorldState, SemanticCanonicalFrame
- **Provability-Validity Tests**: Test main_provable_iff_valid_v2

## References

* Metalogic_v2/Representation/CanonicalModel.lean - Canonical model construction
* Metalogic_v2/Representation/SemanticCanonicalModel.lean - Semantic canonical model
* Metalogic_v2/Representation/RepresentationTheorem.lean - Representation theorems
-/

namespace BimodalTest.Metalogic_v2.CanonicalModelPropertyTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic_v2.Core
open Bimodal.Metalogic_v2.Representation
open Bimodal.Metalogic_v2.Soundness

/-!
## CanonicalWorldState Type Tests

Test the CanonicalWorldState type construction.
-/

/--
Test: CanonicalWorldState type exists.
-/
example : Type := CanonicalWorldState

/--
Test: CanonicalWorldState is a subtype of sets.

Each CanonicalWorldState is a set of formulas that is SetMaximalConsistent.
-/
example (w : CanonicalWorldState) : {S : Set Formula // SetMaximalConsistent S} := w

/--
Test: CanonicalWorldState has carrier function.

The carrier extracts the underlying set of formulas.
-/
example (w : CanonicalWorldState) : Set Formula := w.carrier

/--
Test: CanonicalWorldState carrier equals underlying value.
-/
example (w : CanonicalWorldState) : w.carrier = w.val := rfl

/-!
## CanonicalWorldState Property Tests

Test the key properties of canonical world states.
-/

/--
Test: Canonical world states are consistent.
-/
example (w : CanonicalWorldState) : SetConsistent w.carrier :=
  w.is_consistent

/--
Test: Canonical world states are maximal.

For any formula phi not in w, adding phi makes the set inconsistent.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    phi ∉ w.carrier → ¬SetConsistent (insert phi w.carrier) :=
  w.is_maximal phi

/--
Test: Canonical worlds have the full SetMaximalConsistent property.
-/
example (w : CanonicalWorldState) : SetMaximalConsistent w.carrier :=
  w.property

/-!
## CanonicalFrame Tests

Test the CanonicalFrame structure.
-/

/--
Test: CanonicalFrame type exists.
-/
example : Type := CanonicalFrame

/--
Test: canonicalFrame construction.
-/
example : CanonicalFrame := canonicalFrame

/--
Test: canonicalFrame has worlds field.
-/
example : Set CanonicalWorldState := canonicalFrame.worlds

/--
Test: canonicalFrame has box_accessibility field.
-/
example : CanonicalWorldState → Set CanonicalWorldState := canonicalFrame.box_accessibility

/--
Test: canonicalFrame has past_accessibility field.
-/
example : CanonicalWorldState → Set CanonicalWorldState := canonicalFrame.past_accessibility

/--
Test: canonicalFrame has future_accessibility field.
-/
example : CanonicalWorldState → Set CanonicalWorldState := canonicalFrame.future_accessibility

/--
Test: canonicalFrame.worlds contains all canonical world states.

The worlds field is the set of all CanonicalWorldState (i.e., {w | True}).
-/
example (w : CanonicalWorldState) : w ∈ canonicalFrame.worlds := trivial

/-!
## Box Accessibility Tests

Test the box accessibility relation.
-/

/--
Test: Box accessibility is defined by box formula membership.

w' is box-accessible from w iff for all phi, box phi in w implies phi in w'.
-/
example (w w' : CanonicalWorldState) :
    w' ∈ canonicalFrame.box_accessibility w ↔
    (∀ phi, Formula.box phi ∈ w.carrier → phi ∈ w'.carrier) := by
  rfl

/--
Test: mcs_box_accessibility type signature.
-/
example (S T : Set Formula)
    (_h_mcs_S : SetMaximalConsistent S) (_h_mcs_T : SetMaximalConsistent T)
    (h_rel : ∀ phi, Formula.box phi ∈ S → phi ∈ T) (phi : Formula) :
    Formula.box phi ∈ S → phi ∈ T :=
  mcs_box_accessibility _h_mcs_S _h_mcs_T h_rel phi

/-!
## Past Accessibility Tests

Test the past accessibility relation.
-/

/--
Test: Past accessibility is defined by all_past formula membership.

w' is past-accessible from w iff for all phi, all_past phi in w implies phi in w'.
-/
example (w w' : CanonicalWorldState) :
    w' ∈ canonicalFrame.past_accessibility w ↔
    (∀ phi, Formula.all_past phi ∈ w.carrier → phi ∈ w'.carrier) := by
  rfl

/-!
## Future Accessibility Tests

Test the future accessibility relation.
-/

/--
Test: Future accessibility is defined by all_future formula membership.

w' is future-accessible from w iff for all phi, all_future phi in w implies phi in w'.
-/
example (w w' : CanonicalWorldState) :
    w' ∈ canonicalFrame.future_accessibility w ↔
    (∀ phi, Formula.all_future phi ∈ w.carrier → phi ∈ w'.carrier) := by
  rfl

/-!
## CanonicalModel Tests

Test the CanonicalModel structure.
-/

/--
Test: CanonicalModel type exists.
-/
example : Type := CanonicalModel

/--
Test: canonicalModel construction.
-/
example : CanonicalModel := canonicalModel

/--
Test: canonicalModel has frame field.
-/
example : CanonicalFrame := canonicalModel.frame

/--
Test: canonicalModel has valuation field.
-/
example : Formula → Set CanonicalWorldState := canonicalModel.valuation

/--
Test: canonicalModel valuation is correct.

phi is in valuation iff phi is in the world's carrier.
-/
example (phi : Formula) (w : CanonicalWorldState) :
    w ∈ canonicalModel.valuation phi ↔ phi ∈ w.carrier :=
  canonicalModel.valuation_correct phi w

/-!
## MCS Property Tests via Canonical Model

Test MCS properties accessed through the canonical model API.
-/

/--
Test: mcs_contains_or_neg via canonical_complete.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    phi ∈ w.carrier ∨ phi.neg ∈ w.carrier :=
  mcs_contains_or_neg w.property phi

/--
Test: mcs_modus_ponens via canonical_modus_ponens.
-/
example (w : CanonicalWorldState) (phi psi : Formula)
    (h_imp : (phi.imp psi) ∈ w.carrier) (h_ant : phi ∈ w.carrier) :
    psi ∈ w.carrier :=
  mcs_modus_ponens w.property h_imp h_ant

/--
Test: set_consistent_not_both via canonical world consistency.

A canonical world cannot contain both phi and neg phi.
-/
example (w : CanonicalWorldState) (phi : Formula)
    (h_phi : phi ∈ w.carrier) (h_neg : phi.neg ∈ w.carrier) : False :=
  set_consistent_not_both w.is_consistent phi h_phi h_neg

/--
Test: set_mcs_neg_excludes via canonical world maximality.

If neg phi is in w, then phi is not in w.
-/
example (w : CanonicalWorldState) (phi : Formula)
    (h_neg : phi.neg ∈ w.carrier) : phi ∉ w.carrier :=
  set_mcs_neg_excludes w.property phi h_neg

/-!
## SemanticWorldState Tests

Test the SemanticWorldState construction.
-/

/--
Test: SemanticWorldState type exists.
-/
example (phi : Formula) : Type := SemanticWorldState phi

/--
Test: SemanticWorldState is a quotient type.

SemanticWorldState phi = Quotient (htSetoid phi)
-/
example (phi : Formula) : SemanticWorldState phi = Quotient (htSetoid phi) := rfl

/--
Test: SemanticWorldState.mk construction.
-/
example (phi : Formula) (p : HistoryTimePair phi) : SemanticWorldState phi :=
  SemanticWorldState.mk p

/--
Test: SemanticWorldState.ofHistoryTime construction.
-/
example (phi : Formula) (h : FiniteHistory phi) (t : FiniteTime (temporalBound phi)) :
    SemanticWorldState phi :=
  SemanticWorldState.ofHistoryTime h t

/--
Test: SemanticWorldState.toFiniteWorldState function.
-/
example (phi : Formula) (w : SemanticWorldState phi) : FiniteWorldState phi :=
  SemanticWorldState.toFiniteWorldState w

/--
Test: SemanticWorldState equality iff toFiniteWorldState equal.
-/
example (phi : Formula) (w1 w2 : SemanticWorldState phi) :
    w1 = w2 ↔ SemanticWorldState.toFiniteWorldState w1 = SemanticWorldState.toFiniteWorldState w2 :=
  SemanticWorldState.eq_iff_toFiniteWorldState_eq w1 w2

/-!
## htEquiv Tests

Test the history-time equivalence relation.
-/

/--
Test: htEquiv is reflexive.
-/
example (phi : Formula) (p : HistoryTimePair phi) : htEquiv phi p p :=
  htEquiv_refl phi p

/--
Test: htEquiv is symmetric.
-/
example (phi : Formula) (p1 p2 : HistoryTimePair phi) (h : htEquiv phi p1 p2) :
    htEquiv phi p2 p1 :=
  htEquiv_symm phi h

/--
Test: htEquiv is transitive.
-/
example (phi : Formula) (p1 p2 p3 : HistoryTimePair phi)
    (h12 : htEquiv phi p1 p2) (h23 : htEquiv phi p2 p3) : htEquiv phi p1 p3 :=
  htEquiv_trans phi h12 h23

/-!
## SemanticCanonicalFrame Tests

Test the SemanticCanonicalFrame construction.
-/

/--
Test: SemanticCanonicalFrame type exists.
-/
noncomputable example (phi : Formula) : TaskFrame Int := SemanticCanonicalFrame phi

/--
Test: SemanticCanonicalFrame WorldState is SemanticWorldState.
-/
example (phi : Formula) : (SemanticCanonicalFrame phi).WorldState = SemanticWorldState phi := rfl

/--
Test: SemanticCanonicalFrame task relation exists.
-/
noncomputable example (phi : Formula) (w : SemanticWorldState phi) (d : Int) (v : SemanticWorldState phi) :
    Prop :=
  (SemanticCanonicalFrame phi).task_rel w d v

/-!
## SemanticCanonicalModel Tests

Test the SemanticCanonicalModel construction.
-/

/--
Test: SemanticCanonicalModel type exists.
-/
noncomputable example (phi : Formula) : TaskModel (SemanticCanonicalFrame phi) :=
  SemanticCanonicalModel phi

/--
Test: SemanticCanonicalModel has valuation.
-/
noncomputable example (phi : Formula) : SemanticWorldState phi → String → Prop :=
  (SemanticCanonicalModel phi).valuation

/-!
## semantic_task_rel Tests

Test the semantic task relation.
-/

/--
Test: semantic_task_rel definition.
-/
example (phi : Formula) (w v : SemanticWorldState phi) (d : Int) :
    semantic_task_rel phi w d v =
    (∃ (h : FiniteHistory phi) (t1 t2 : FiniteTime (temporalBound phi)),
      SemanticWorldState.ofHistoryTime h t1 = w ∧
      SemanticWorldState.ofHistoryTime h t2 = v ∧
      FiniteTime.toInt (temporalBound phi) t2 - FiniteTime.toInt (temporalBound phi) t1 = d) := rfl

/--
Test: semantic_task_rel_nullity.

Every world relates to itself with duration 0.
-/
example (phi : Formula) (w : SemanticWorldState phi) : semantic_task_rel phi w 0 w :=
  semantic_task_rel_nullity phi w

/-!
## main_provable_iff_valid_v2 Tests

Test the main provability-validity equivalence.
-/

/--
Test: main_provable_iff_valid_v2 type signature.
-/
example (phi : Formula) : Nonempty (⊢ phi) ↔ valid phi :=
  main_provable_iff_valid_v2 phi

/--
Test: main_provable_iff_valid_v2 forward direction (soundness).
-/
example (phi : Formula) (h : Nonempty (⊢ phi)) : valid phi :=
  (main_provable_iff_valid_v2 phi).mp h

/--
Test: main_provable_iff_valid_v2 backward direction (completeness).
-/
example (phi : Formula) (h : valid phi) : Nonempty (⊢ phi) :=
  (main_provable_iff_valid_v2 phi).mpr h

/--
Test: main_provable_iff_valid_v2 for Modal T.

Modal T (box phi -> phi) is both provable and valid.
-/
example (phi : Formula) : Nonempty (⊢ (phi.box.imp phi)) ↔ valid (phi.box.imp phi) :=
  main_provable_iff_valid_v2 (phi.box.imp phi)

/--
Test: main_provable_iff_valid_v2 round-trip (provable -> valid -> provable).
-/
example (phi : Formula) (h : Nonempty (⊢ phi)) : Nonempty (⊢ phi) := by
  have h_valid : valid phi := (main_provable_iff_valid_v2 phi).mp h
  exact (main_provable_iff_valid_v2 phi).mpr h_valid

/--
Test: main_provable_iff_valid_v2 round-trip (valid -> provable -> valid).
-/
example (phi : Formula) (h : valid phi) : valid phi := by
  have h_prov : Nonempty (⊢ phi) := (main_provable_iff_valid_v2 phi).mpr h
  exact (main_provable_iff_valid_v2 phi).mp h_prov

/-!
## Representation Theorem Tests

Test the representation theorems via canonical model.
-/

/--
Test: representation_theorem type signature.
-/
noncomputable example (Gamma : Context) :
    Consistent Gamma → ∃ w : CanonicalWorldState, ∀ phi ∈ Gamma, canonicalTruthAt w phi :=
  representation_theorem

/--
Test: representation_satisfiability equivalence.
-/
noncomputable example (Gamma : Context) :
    Consistent Gamma ↔ canonicalContextSatisfiable Gamma :=
  representation_satisfiability

/--
Test: strong_representation_theorem type signature.
-/
noncomputable example (Gamma : Context) (phi : Formula) :
    ¬ContextDerivable Gamma phi.neg →
    ∃ w : CanonicalWorldState, (∀ psi ∈ Gamma, canonicalTruthAt w psi) ∧ canonicalTruthAt w phi :=
  strong_representation_theorem

/-!
## Canonical Satisfiability Tests

Test canonical satisfiability definitions.
-/

/--
Test: canonicalSatisfiable definition.
-/
example (phi : Formula) : canonicalSatisfiable phi = ∃ w : CanonicalWorldState, canonicalTruthAt w phi :=
  rfl

/--
Test: canonicalContextSatisfiable definition.
-/
example (Gamma : Context) :
    canonicalContextSatisfiable Gamma = ∃ w : CanonicalWorldState, ∀ phi ∈ Gamma, canonicalTruthAt w phi :=
  rfl

/-!
## Model Coherence Tests

Test that the canonical model satisfies expected properties.
-/

/--
Test: Canonical model valuation is consistent with carrier.

For any world w and formula phi: phi in valuation at w iff phi in w.carrier.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    w ∈ canonicalModel.valuation phi ↔ phi ∈ w.carrier :=
  canonicalModel.valuation_correct phi w

/--
Test: Canonical model frame uses correct accessibility.

The canonical model uses canonicalFrame as its frame.
-/
example : canonicalModel.frame = canonicalFrame := rfl

/-!
## Completeness Corollary Tests

Test completeness derived from canonical model construction.
-/

/--
Test: completeness_corollary type signature.
-/
noncomputable example (phi : Formula) : valid phi → ContextDerivable [] phi :=
  completeness_corollary

/--
Test: completeness_corollary for valid formula.
-/
noncomputable example (phi : Formula) (h : valid phi) : ContextDerivable [] phi :=
  completeness_corollary h

end BimodalTest.Metalogic_v2.CanonicalModelPropertyTest
