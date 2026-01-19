import Bimodal.Metalogic_v2.Representation.RepresentationTheorem
import Bimodal.Metalogic_v2.Representation.CanonicalModel
import Bimodal.Metalogic_v2.Representation.TruthLemma

/-!
# Representation Layer Tests for Metalogic_v2

Example-based tests for the Representation layer of Metalogic_v2, including:
- Canonical model construction
- Truth lemma variants
- Representation theorem applications
- Strong representation theorem

## Test Organization

- **Canonical Model Tests**: Test canonical model type definitions
- **Truth Lemma Tests**: Test truth lemma for all formula constructors
- **Representation Theorem Tests**: Test main representation results
- **Completeness Corollary Tests**: Test completeness from representation

## References

* Metalogic_v2/Representation/CanonicalModel.lean - Canonical model construction
* Metalogic_v2/Representation/TruthLemma.lean - Truth lemma variants
* Metalogic_v2/Representation/RepresentationTheorem.lean - Main representation results
-/

namespace BimodalTest.Metalogic_v2.RepresentationTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic_v2.Core
open Bimodal.Metalogic_v2.Representation

/-!
## Canonical World State Tests

Test the CanonicalWorldState type and its properties.
-/

/--
Test: CanonicalWorldState type exists.

Verification: `CanonicalWorldState` is a well-defined type.
-/
example : Type := CanonicalWorldState

/--
Test: CanonicalWorldState has carrier.

Verification: Each canonical world has an associated set of formulas.
-/
example (w : CanonicalWorldState) : Set Formula := w.carrier

/--
Test: Canonical worlds are consistent.

Property: Every canonical world state has a consistent carrier.
-/
example (w : CanonicalWorldState) : SetConsistent w.carrier :=
  canonical_world_consistent w

/--
Test: Canonical worlds are maximal.

Property: Every canonical world cannot be extended while maintaining consistency.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    phi ∉ w.carrier → ¬SetConsistent (insert phi w.carrier) :=
  canonical_world_maximal w phi

/--
Test: Canonical worlds are negation complete.

Property: For any formula, either it or its negation is in the carrier.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    phi ∈ w.carrier ∨ Formula.neg phi ∈ w.carrier :=
  canonical_complete w phi

/-!
## Canonical Model Tests

Test the canonical model construction.
-/

/--
Test: CanonicalFrame type exists.

Verification: `CanonicalFrame` is a well-defined type.
-/
example : Type := CanonicalFrame

/--
Test: canonicalFrame construction.

Verification: `canonicalFrame` produces a valid CanonicalFrame.
-/
example : CanonicalFrame := canonicalFrame

/--
Test: CanonicalModel type exists.

Verification: `CanonicalModel` is a well-defined type.
-/
example : Type := CanonicalModel

/--
Test: canonicalModel construction.

Verification: `canonicalModel` produces a valid CanonicalModel.
-/
example : CanonicalModel := canonicalModel

/-!
## canonicalTruthAt Tests

Test the canonical truth definition.
-/

/--
Test: canonicalTruthAt type signature.

canonicalTruthAt takes a world and formula, returns a proposition.
-/
example (w : CanonicalWorldState) (phi : Formula) : Prop :=
  canonicalTruthAt w phi

/-!
## Truth Lemma Tests

Test truth lemma variants for each formula constructor.
-/

/--
Test: truthLemma_detailed - general truth lemma.

`canonicalTruthAt w phi <-> phi in w.carrier`
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi ↔ phi ∈ w.carrier :=
  truthLemma_detailed w phi

/--
Test: truthLemma_atom - truth lemma for atoms.

`canonicalTruthAt w (atom p) <-> (atom p) in w.carrier`
-/
example (w : CanonicalWorldState) (p : String) :
    canonicalTruthAt w (Formula.atom p) ↔ Formula.atom p ∈ w.carrier :=
  truthLemma_atom w p

/--
Test: truthLemma_bot - truth lemma for bottom.

`not (canonicalTruthAt w bot)` - bottom is never true in canonical worlds.
-/
example (w : CanonicalWorldState) : ¬canonicalTruthAt w Formula.bot :=
  truthLemma_bot w

/--
Test: truthLemma_imp - truth lemma for implication.

`canonicalTruthAt w (phi -> psi) <-> (phi -> psi) in w.carrier`
-/
example (w : CanonicalWorldState) (phi psi : Formula) :
    canonicalTruthAt w (phi.imp psi) ↔ (phi.imp psi) ∈ w.carrier :=
  truthLemma_imp w phi psi

/--
Test: truthLemma_box - truth lemma for box.

`canonicalTruthAt w ([]phi) <-> ([]phi) in w.carrier`
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.box ↔ phi.box ∈ w.carrier :=
  truthLemma_box w phi

/--
Test: truthLemma_all_past - truth lemma for all_past.

`canonicalTruthAt w (Pphi) <-> (Pphi) in w.carrier`
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.all_past ↔ phi.all_past ∈ w.carrier :=
  truthLemma_all_past w phi

/--
Test: truthLemma_all_future - truth lemma for all_future.

`canonicalTruthAt w (Fphi) <-> (Fphi) in w.carrier`
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.all_future ↔ phi.all_future ∈ w.carrier :=
  truthLemma_all_future w phi

/--
Test: contextTruthLemma - truth lemma for contexts.

`(forall phi in Gamma, canonicalTruthAt w phi) <-> (forall phi in Gamma, phi in w.carrier)`
-/
example (w : CanonicalWorldState) (Gamma : Context) :
    (∀ phi ∈ Gamma, canonicalTruthAt w phi) ↔ (∀ phi ∈ Gamma, phi ∈ w.carrier) :=
  contextTruthLemma w

/-!
## Canonical World Property Tests

Test derived properties of canonical worlds.
-/

/--
Test: Modus ponens in canonical worlds.

If (phi -> psi) in w and phi in w, then psi in w.
-/
example (w : CanonicalWorldState) (phi psi : Formula) :
    (phi.imp psi) ∈ w.carrier → phi ∈ w.carrier → psi ∈ w.carrier :=
  canonical_modus_ponens w

/--
Test: Necessitation lemma for canonical worlds.

If [] |- phi (phi is a theorem), then []phi in w for all canonical worlds w.
-/
noncomputable example (w : CanonicalWorldState) (phi : Formula) :
    ContextDerivable [] phi → phi.box ∈ w.carrier :=
  necessitation_lemma w

/-!
## Representation Theorem Tests

Test the main representation theorem and its variants.
-/

/--
Test: representation_theorem type signature.

`Consistent Gamma -> exists w, forall phi in Gamma, canonicalTruthAt w phi`
-/
noncomputable example (Gamma : Context) :
    Consistent Gamma → ∃ w : CanonicalWorldState, ∀ phi ∈ Gamma, canonicalTruthAt w phi :=
  representation_theorem

/--
Test: strong_representation_theorem type signature.

If Gamma does not derive neg phi, then exists w where Gamma is true and phi is true.
-/
noncomputable example (Gamma : Context) (phi : Formula) :
    ¬ContextDerivable Gamma phi.neg →
    ∃ w : CanonicalWorldState, (∀ psi ∈ Gamma, canonicalTruthAt w psi) ∧ canonicalTruthAt w phi :=
  strong_representation_theorem

/--
Test: mcs_extension_truth.

Consistent Gamma with phi in Gamma implies exists w with canonicalTruthAt w phi.
-/
noncomputable example (Gamma : Context) (phi : Formula) :
    Consistent Gamma → phi ∈ Gamma → ∃ w : CanonicalWorldState, canonicalTruthAt w phi :=
  mcs_extension_truth

/-!
## Canonical Satisfiability Tests

Test the canonical satisfiability definitions.
-/

/--
Test: canonicalSatisfiable type signature.

`canonicalSatisfiable phi` means phi is satisfied in some canonical world.
-/
example (phi : Formula) : Prop := canonicalSatisfiable phi

/--
Test: canonicalContextSatisfiable type signature.

`canonicalContextSatisfiable Gamma` means all formulas in Gamma are satisfied in some canonical world.
-/
example (Gamma : Context) : Prop := canonicalContextSatisfiable Gamma

/--
Test: representation_satisfiability equivalence.

`Consistent Gamma <-> canonicalContextSatisfiable Gamma`
-/
noncomputable example (Gamma : Context) :
    Consistent Gamma ↔ canonicalContextSatisfiable Gamma :=
  representation_satisfiability

/-!
## Completeness Corollary Tests

Test the completeness corollary derived from representation.
-/

/--
Test: completeness_corollary type signature.

`|= phi -> [] |- phi`

Note: This relies on the axiom `representation_theorem_backward_empty`.
-/
noncomputable example (phi : Formula) :
    valid phi → ContextDerivable [] phi :=
  completeness_corollary

/-!
## MCS Property Tests

Test maximal consistent set properties used in canonical model.
-/

/--
Test: mcs_contains_or_neg (used in canonical model).

For SetMaximalConsistent S and any phi: phi in S or neg phi in S.
-/
example (S : Set Formula) (h : SetMaximalConsistent S) (phi : Formula) :
    phi ∈ S ∨ Formula.neg phi ∈ S :=
  mcs_contains_or_neg h phi

/--
Test: mcs_modus_ponens (used in canonical model).

For SetMaximalConsistent S: if (phi -> psi) in S and phi in S, then psi in S.
-/
example (S : Set Formula) (h : SetMaximalConsistent S) (phi psi : Formula) :
    (phi.imp psi) ∈ S → phi ∈ S → psi ∈ S :=
  mcs_modus_ponens h

/-!
## Core Re-exports Tests

Test that Representation layer re-exports key Core definitions correctly.
-/

/--
Test: Core re-exports Consistent.
-/
example (Gamma : Context) : Prop := Consistent Gamma

/--
Test: Core re-exports SetConsistent.
-/
example (S : Set Formula) : Prop := SetConsistent S

/--
Test: Core re-exports SetMaximalConsistent.
-/
example (S : Set Formula) : Prop := SetMaximalConsistent S

/--
Test: Core re-exports set_lindenbaum.
-/
noncomputable example (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent M :=
  set_lindenbaum S h

end BimodalTest.Metalogic_v2.RepresentationTest
