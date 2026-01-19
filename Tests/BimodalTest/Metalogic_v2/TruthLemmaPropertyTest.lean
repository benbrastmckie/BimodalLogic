import Bimodal.Metalogic_v2.Representation.TruthLemma
import Bimodal.Metalogic_v2.Representation.CanonicalModel
import Bimodal.Metalogic_v2.Core.MaximalConsistent

/-!
# Truth Lemma Property Tests for Metalogic_v2

Property-based tests for the truth lemma variants in TruthLemma.lean of Metalogic_v2, including:
- canonicalTruthAt definition and properties
- Truth lemma for all formula constructors
- contextTruthLemma for context-relative truth
- canonical_modus_ponens property
- necessitation_lemma property
- Edge cases: deeply nested formulas, mixed modal/temporal

## Test Organization

- **canonicalTruthAt Tests**: Test basic definition
- **Truth Lemma Variant Tests**: Test each formula constructor
- **Context Truth Tests**: Test contextTruthLemma
- **Derived Property Tests**: Test canonical_modus_ponens, necessitation_lemma
- **Completeness Tests**: Test canonical_complete (phi or neg phi)
- **Edge Case Tests**: Deeply nested formulas, mixed operators

## References

* Metalogic_v2/Representation/TruthLemma.lean - Truth lemma variants
* Metalogic_v2/Representation/CanonicalModel.lean - Canonical model construction
-/

namespace BimodalTest.Metalogic_v2.TruthLemmaPropertyTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic_v2.Core
open Bimodal.Metalogic_v2.Representation

/-!
## canonicalTruthAt Definition Tests

Test the canonicalTruthAt definition and its properties.
-/

/--
Test: canonicalTruthAt type signature.

canonicalTruthAt takes a world and formula, returns Prop.
-/
example (w : CanonicalWorldState) (phi : Formula) : Prop := canonicalTruthAt w phi

/--
Test: canonicalTruthAt is definitionally equal to carrier membership.

canonicalTruthAt w phi = phi in w.carrier
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi = (phi ∈ w.carrier) := rfl

/--
Test: canonicalTruthAt respects iff relation with truthLemma_detailed.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi ↔ phi ∈ w.carrier :=
  truthLemma_detailed w phi

/-!
## Truth Lemma for Atomic Formulas

Test truthLemma_atom.
-/

/--
Test: truthLemma_atom type signature.
-/
example (w : CanonicalWorldState) (p : String) :
    canonicalTruthAt w (Formula.atom p) ↔ Formula.atom p ∈ w.carrier :=
  truthLemma_atom w p

/--
Test: truthLemma_atom with concrete atom name.
-/
example (w : CanonicalWorldState) :
    canonicalTruthAt w (Formula.atom "p") ↔ Formula.atom "p" ∈ w.carrier :=
  truthLemma_atom w "p"

/--
Test: truthLemma_atom with different atom names.
-/
example (w : CanonicalWorldState) :
    canonicalTruthAt w (Formula.atom "q") ↔ Formula.atom "q" ∈ w.carrier :=
  truthLemma_atom w "q"

/--
Test: truthLemma_atom forward direction.

If atom p is true at w, then atom p is in w.carrier.
-/
example (w : CanonicalWorldState) (p : String) (h : canonicalTruthAt w (Formula.atom p)) :
    Formula.atom p ∈ w.carrier :=
  (truthLemma_atom w p).mp h

/--
Test: truthLemma_atom backward direction.

If atom p is in w.carrier, then atom p is true at w.
-/
example (w : CanonicalWorldState) (p : String) (h : Formula.atom p ∈ w.carrier) :
    canonicalTruthAt w (Formula.atom p) :=
  (truthLemma_atom w p).mpr h

/-!
## Truth Lemma for Bottom (False)

Test truthLemma_bot - bottom is never true.
-/

/--
Test: truthLemma_bot type signature.

Bottom is never true at any canonical world.
-/
example (w : CanonicalWorldState) : ¬canonicalTruthAt w Formula.bot :=
  truthLemma_bot w

/--
Test: truthLemma_bot implies bot not in carrier.

Since bot is not true, bot is not in w.carrier.
-/
example (w : CanonicalWorldState) (h : canonicalTruthAt w Formula.bot) : False :=
  truthLemma_bot w h

/--
Test: Consistency - bot not in MCS carrier.

This is a consequence of truthLemma_bot and the definition of canonicalTruthAt.
-/
example (w : CanonicalWorldState) : Formula.bot ∉ w.carrier := by
  intro h
  have h_truth : canonicalTruthAt w Formula.bot := h
  exact truthLemma_bot w h_truth

/-!
## Truth Lemma for Implication

Test truthLemma_imp.
-/

/--
Test: truthLemma_imp type signature.
-/
example (w : CanonicalWorldState) (phi psi : Formula) :
    canonicalTruthAt w (phi.imp psi) ↔ (phi.imp psi) ∈ w.carrier :=
  truthLemma_imp w phi psi

/--
Test: truthLemma_imp with concrete formulas.
-/
example (w : CanonicalWorldState) :
    canonicalTruthAt w (Formula.atom "p" |>.imp (Formula.atom "q")) ↔
    (Formula.atom "p" |>.imp (Formula.atom "q")) ∈ w.carrier :=
  truthLemma_imp w (Formula.atom "p") (Formula.atom "q")

/--
Test: truthLemma_imp forward direction.
-/
example (w : CanonicalWorldState) (phi psi : Formula)
    (h : canonicalTruthAt w (phi.imp psi)) : (phi.imp psi) ∈ w.carrier :=
  (truthLemma_imp w phi psi).mp h

/--
Test: truthLemma_imp backward direction.
-/
example (w : CanonicalWorldState) (phi psi : Formula)
    (h : (phi.imp psi) ∈ w.carrier) : canonicalTruthAt w (phi.imp psi) :=
  (truthLemma_imp w phi psi).mpr h

/-!
## Truth Lemma for Box (Necessity)

Test truthLemma_box.
-/

/--
Test: truthLemma_box type signature.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.box ↔ phi.box ∈ w.carrier :=
  truthLemma_box w phi

/--
Test: truthLemma_box with concrete formula.
-/
example (w : CanonicalWorldState) :
    canonicalTruthAt w (Formula.atom "p").box ↔ (Formula.atom "p").box ∈ w.carrier :=
  truthLemma_box w (Formula.atom "p")

/--
Test: truthLemma_box forward direction.
-/
example (w : CanonicalWorldState) (phi : Formula)
    (h : canonicalTruthAt w phi.box) : phi.box ∈ w.carrier :=
  (truthLemma_box w phi).mp h

/--
Test: truthLemma_box backward direction.
-/
example (w : CanonicalWorldState) (phi : Formula)
    (h : phi.box ∈ w.carrier) : canonicalTruthAt w phi.box :=
  (truthLemma_box w phi).mpr h

/-!
## Truth Lemma for Temporal Operators

Test truthLemma_all_past and truthLemma_all_future.
-/

/--
Test: truthLemma_all_past type signature.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.all_past ↔ phi.all_past ∈ w.carrier :=
  truthLemma_all_past w phi

/--
Test: truthLemma_all_future type signature.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.all_future ↔ phi.all_future ∈ w.carrier :=
  truthLemma_all_future w phi

/--
Test: truthLemma_all_past with concrete formula.
-/
example (w : CanonicalWorldState) :
    canonicalTruthAt w (Formula.atom "p").all_past ↔
    (Formula.atom "p").all_past ∈ w.carrier :=
  truthLemma_all_past w (Formula.atom "p")

/--
Test: truthLemma_all_future with concrete formula.
-/
example (w : CanonicalWorldState) :
    canonicalTruthAt w (Formula.atom "p").all_future ↔
    (Formula.atom "p").all_future ∈ w.carrier :=
  truthLemma_all_future w (Formula.atom "p")

/-!
## Context Truth Lemma Tests

Test contextTruthLemma for contexts.
-/

/--
Test: contextTruthLemma type signature.

Truth of all formulas in a context corresponds to membership in carrier.
-/
example (w : CanonicalWorldState) (Gamma : Context) :
    (∀ phi ∈ Gamma, canonicalTruthAt w phi) ↔ (∀ phi ∈ Gamma, phi ∈ w.carrier) :=
  contextTruthLemma w

/--
Test: contextTruthLemma for empty context.

Trivially true for empty context.
-/
example (w : CanonicalWorldState) :
    (∀ phi ∈ ([] : Context), canonicalTruthAt w phi) ↔
    (∀ phi ∈ ([] : Context), phi ∈ w.carrier) :=
  contextTruthLemma w

/--
Test: contextTruthLemma forward direction.
-/
example (w : CanonicalWorldState) (Gamma : Context)
    (h : ∀ phi ∈ Gamma, canonicalTruthAt w phi) : ∀ phi ∈ Gamma, phi ∈ w.carrier :=
  (contextTruthLemma w).mp h

/--
Test: contextTruthLemma backward direction.
-/
example (w : CanonicalWorldState) (Gamma : Context)
    (h : ∀ phi ∈ Gamma, phi ∈ w.carrier) : ∀ phi ∈ Gamma, canonicalTruthAt w phi :=
  (contextTruthLemma w).mpr h

/-!
## canonical_modus_ponens Tests

Test the modus ponens property in canonical worlds.
-/

/--
Test: canonical_modus_ponens type signature.

If (phi -> psi) in w and phi in w, then psi in w.
-/
example (w : CanonicalWorldState) (phi psi : Formula) :
    (phi.imp psi) ∈ w.carrier → phi ∈ w.carrier → psi ∈ w.carrier :=
  canonical_modus_ponens w

/--
Test: canonical_modus_ponens with concrete formulas.
-/
example (w : CanonicalWorldState) (h_imp : (Formula.atom "p" |>.imp (Formula.atom "q")) ∈ w.carrier)
    (h_ant : Formula.atom "p" ∈ w.carrier) : Formula.atom "q" ∈ w.carrier :=
  canonical_modus_ponens w h_imp h_ant

/--
Test: canonical_modus_ponens corresponds to truth preservation.

If phi -> psi is true and phi is true, then psi is true.
-/
example (w : CanonicalWorldState) (phi psi : Formula)
    (h_imp : canonicalTruthAt w (phi.imp psi))
    (h_ant : canonicalTruthAt w phi) : canonicalTruthAt w psi := by
  have h_imp_mem := (truthLemma_imp w phi psi).mp h_imp
  have h_ant_mem := (truthLemma_detailed w phi).mp h_ant
  have h_cons_mem := canonical_modus_ponens w h_imp_mem h_ant_mem
  exact (truthLemma_detailed w psi).mpr h_cons_mem

/-!
## necessitation_lemma Tests

Test the necessitation lemma.
-/

/--
Test: necessitation_lemma type signature.

If phi is derivable from empty context, then box phi is in every canonical world.
-/
noncomputable example (w : CanonicalWorldState) (phi : Formula) :
    ContextDerivable [] phi → phi.box ∈ w.carrier :=
  necessitation_lemma w

/--
Test: necessitation_lemma with concrete derivation.

Modal T: box phi -> phi is derivable, so box (box phi -> phi) is in w.
-/
noncomputable example (w : CanonicalWorldState) (phi : Formula) :
    (phi.box.imp phi).box ∈ w.carrier := by
  apply necessitation_lemma w
  exact ⟨DerivationTree.axiom [] _ (Axiom.modal_t phi)⟩

/--
Test: necessitation_lemma for propositional axiom.

[] |- p -> (q -> p), so box (p -> (q -> p)) is in w.
-/
noncomputable example (w : CanonicalWorldState) (phi psi : Formula) :
    (phi.imp (psi.imp phi)).box ∈ w.carrier := by
  apply necessitation_lemma w
  exact ⟨DerivationTree.axiom [] _ (Axiom.prop_s phi psi)⟩

/-!
## canonical_complete Tests

Test the completeness property of canonical worlds.
-/

/--
Test: canonical_complete type signature.

Every canonical world contains either phi or neg phi.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    phi ∈ w.carrier ∨ phi.neg ∈ w.carrier :=
  canonical_complete w phi

/--
Test: canonical_complete for atom.
-/
example (w : CanonicalWorldState) :
    Formula.atom "p" ∈ w.carrier ∨ (Formula.atom "p").neg ∈ w.carrier :=
  canonical_complete w (Formula.atom "p")

/--
Test: canonical_complete for box.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    phi.box ∈ w.carrier ∨ phi.box.neg ∈ w.carrier :=
  canonical_complete w phi.box

/--
Test: canonical_complete for implication.
-/
example (w : CanonicalWorldState) (phi psi : Formula) :
    (phi.imp psi) ∈ w.carrier ∨ (phi.imp psi).neg ∈ w.carrier :=
  canonical_complete w (phi.imp psi)

/-!
## canonical_world_consistent Tests

Test the consistency of canonical worlds.
-/

/--
Test: canonical_world_consistent type signature.
-/
example (w : CanonicalWorldState) : SetConsistent w.carrier :=
  canonical_world_consistent w

/--
Test: Canonical world consistency implies cannot have phi and neg phi.
-/
example (w : CanonicalWorldState) (phi : Formula)
    (h_phi : phi ∈ w.carrier) : phi.neg ∉ w.carrier := by
  intro h_neg
  exact set_consistent_not_both (canonical_world_consistent w) phi h_phi h_neg

/-!
## canonical_world_maximal Tests

Test the maximality of canonical worlds.
-/

/--
Test: canonical_world_maximal type signature.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    phi ∉ w.carrier → ¬SetConsistent (insert phi w.carrier) :=
  canonical_world_maximal w phi

/--
Test: Maximality - cannot add formula not in carrier without losing consistency.
-/
example (w : CanonicalWorldState) (phi : Formula) (h : phi ∉ w.carrier) :
    ¬SetConsistent (insert phi w.carrier) :=
  canonical_world_maximal w phi h

/-!
## Edge Case Tests: Deeply Nested Formulas

Test truth lemma with deeply nested formulas.
-/

/--
Test: truthLemma for box box phi.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.box.box ↔ phi.box.box ∈ w.carrier :=
  truthLemma_box w phi.box

/--
Test: truthLemma for box box box phi.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.box.box.box ↔ phi.box.box.box ∈ w.carrier :=
  truthLemma_box w phi.box.box

/--
Test: truthLemma for imp (box phi) (box psi).
-/
example (w : CanonicalWorldState) (phi psi : Formula) :
    canonicalTruthAt w (phi.box.imp psi.box) ↔ (phi.box.imp psi.box) ∈ w.carrier :=
  truthLemma_imp w phi.box psi.box

/--
Test: truthLemma for box (imp phi psi).
-/
example (w : CanonicalWorldState) (phi psi : Formula) :
    canonicalTruthAt w (phi.imp psi).box ↔ (phi.imp psi).box ∈ w.carrier :=
  truthLemma_box w (phi.imp psi)

/-!
## Edge Case Tests: Mixed Modal/Temporal Formulas

Test truth lemma with mixed modal and temporal operators.
-/

/--
Test: truthLemma for box (all_future phi).
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.all_future.box ↔ phi.all_future.box ∈ w.carrier :=
  truthLemma_box w phi.all_future

/--
Test: truthLemma for all_future (box phi).
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.box.all_future ↔ phi.box.all_future ∈ w.carrier :=
  truthLemma_all_future w phi.box

/--
Test: truthLemma for all_past (all_future phi).
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.all_future.all_past ↔ phi.all_future.all_past ∈ w.carrier :=
  truthLemma_all_past w phi.all_future

/--
Test: truthLemma for box (all_past (all_future phi)).
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.all_future.all_past.box ↔
    phi.all_future.all_past.box ∈ w.carrier :=
  truthLemma_box w phi.all_future.all_past

/-!
## Edge Case Tests: Trivially True/False Implications

Test truth lemma edge cases for implications.
-/

/--
Test: truthLemma for bot -> phi (ex falso).

bot -> phi should be in any consistent MCS.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w (Formula.bot.imp phi) ↔ (Formula.bot.imp phi) ∈ w.carrier :=
  truthLemma_imp w Formula.bot phi

/--
Test: truthLemma for phi -> phi (identity).

phi -> phi should be in any MCS.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w (phi.imp phi) ↔ (phi.imp phi) ∈ w.carrier :=
  truthLemma_imp w phi phi

/-!
## Compositional Property Tests

Test compositional behavior of truth lemma.
-/

/--
Property: Truth at world is closed under modus ponens.

If phi -> psi is true and phi is true, then psi is true.
-/
theorem truth_closed_mp (w : CanonicalWorldState) (phi psi : Formula)
    (h1 : canonicalTruthAt w (phi.imp psi)) (h2 : canonicalTruthAt w phi) :
    canonicalTruthAt w psi := by
  rw [truthLemma_detailed] at h1 h2 ⊢
  exact canonical_modus_ponens w h1 h2

/--
Property: Truth at world respects negation completeness.

Either phi is true or neg phi is true, but not both.
-/
theorem truth_negation_complete (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi ∨ canonicalTruthAt w phi.neg := by
  rw [truthLemma_detailed, truthLemma_detailed]
  exact canonical_complete w phi

/--
Property: Truth at world is consistent.

Cannot have both phi and neg phi true.
-/
theorem truth_consistent (w : CanonicalWorldState) (phi : Formula)
    (h1 : canonicalTruthAt w phi) : ¬canonicalTruthAt w phi.neg := by
  rw [truthLemma_detailed] at h1
  rw [truthLemma_detailed]
  intro h2
  exact set_consistent_not_both (canonical_world_consistent w) phi h1 h2

end BimodalTest.Metalogic_v2.TruthLemmaPropertyTest
