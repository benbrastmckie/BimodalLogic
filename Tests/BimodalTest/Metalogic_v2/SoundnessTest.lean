import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.ProofSystem.Derivation

/-!
# Soundness Tests for Metalogic_v2

Example-based tests for the Soundness layer of Metalogic_v2, including:
- All 15 axiom validity lemmas
- Soundness theorem applications
- Inference rule soundness

## Test Organization

- **Axiom Validity Tests**: Test each of the 15 TM axiom validity lemmas
- **Axiom Derivability Tests**: Test axiom rule creates valid derivations
- **Soundness Application Tests**: Test soundness theorem applications
- **Inference Rule Tests**: Test soundness with modus ponens and necessitation

## References

* Metalogic_v2/Soundness/Soundness.lean - Soundness theorem and axiom validity
* Metalogic_v2/Soundness/SoundnessLemmas.lean - Temporal duality lemmas
-/

namespace BimodalTest.Metalogic_v2.SoundnessTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic_v2.Soundness

/-!
## Propositional Axiom Validity Tests

Test the two propositional axiom validity lemmas.
-/

/--
Test: Propositional K axiom is valid.

`|= (phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi))`
-/
example (phi psi chi : Formula) :
    valid ((phi.imp (psi.imp chi)).imp ((phi.imp psi).imp (phi.imp chi))) :=
  prop_k_valid phi psi chi

/--
Test: Propositional S axiom is valid.

`|= phi -> (psi -> phi)`
-/
example (phi psi : Formula) : valid (phi.imp (psi.imp phi)) :=
  prop_s_valid phi psi

/-!
## Modal Axiom Validity Tests

Test the modal axiom validity lemmas (T, 4, B, 5 Collapse, K Distribution).
-/

/--
Test: Modal T axiom is valid.

`|= []phi -> phi` (box phi implies phi)
-/
example (phi : Formula) : valid (phi.box.imp phi) :=
  modal_t_valid phi

/--
Test: Modal 4 axiom is valid.

`|= []phi -> [][]phi` (box phi implies box box phi)
-/
example (phi : Formula) : valid (phi.box.imp phi.box.box) :=
  modal_4_valid phi

/--
Test: Modal B axiom is valid.

`|= phi -> []<>phi` (phi implies box diamond phi)
-/
example (phi : Formula) : valid (phi.imp phi.diamond.box) :=
  modal_b_valid phi

/--
Test: Modal 5 Collapse axiom is valid.

`|= <>[]phi -> []phi` (diamond box phi implies box phi)
-/
example (phi : Formula) : valid (phi.box.diamond.imp phi.box) :=
  modal_5_collapse_valid phi

/--
Test: Modal K Distribution axiom is valid.

`|= [](phi -> psi) -> ([]phi -> []psi)`
-/
example (phi psi : Formula) : valid ((phi.imp psi).box.imp (phi.box.imp psi.box)) :=
  modal_k_dist_valid phi psi

/-!
## Classical Logic Axiom Validity Tests

Test EFQ and Peirce's law validity.
-/

/--
Test: Ex Falso Quodlibet is valid.

`|= bot -> phi`
-/
example (phi : Formula) : valid (Formula.bot.imp phi) :=
  ex_falso_valid phi

/--
Test: Peirce's Law is valid.

`|= ((phi -> psi) -> phi) -> phi`
-/
example (phi psi : Formula) : valid (((phi.imp psi).imp phi).imp phi) :=
  peirce_valid phi psi

/-!
## Temporal Axiom Validity Tests

Test the temporal axiom validity lemmas (K Dist, 4, A, L).
-/

/--
Test: Temporal K Distribution axiom is valid.

`|= F(phi -> psi) -> (Fphi -> Fpsi)` (all_future distributes over implication)
-/
example (phi psi : Formula) :
    valid ((phi.imp psi).all_future.imp (phi.all_future.imp psi.all_future)) :=
  temp_k_dist_valid phi psi

/--
Test: Temporal 4 axiom is valid.

`|= Fphi -> FFphi` (all_future phi implies all_future all_future phi)
-/
example (phi : Formula) : valid (phi.all_future.imp phi.all_future.all_future) :=
  temp_4_valid phi

/--
Test: Temporal A axiom is valid.

`|= phi -> F(sometime_past phi)`
-/
example (phi : Formula) : valid (phi.imp (Formula.all_future phi.sometime_past)) :=
  temp_a_valid phi

/--
Test: Temporal L axiom is valid.

`|= always phi -> F(all_past phi)`
-/
example (phi : Formula) : valid (phi.always.imp (Formula.all_future (Formula.all_past phi))) :=
  temp_l_valid phi

/-!
## Cross-Modal Axiom Validity Tests

Test the modal-temporal interaction axioms (MF, TF).
-/

/--
Test: Modal-Future axiom is valid.

`|= []phi -> [](Fphi)` (box phi implies box all_future phi)
-/
example (phi : Formula) : valid (phi.box.imp phi.all_future.box) :=
  modal_future_valid phi

/--
Test: Temporal-Future axiom is valid.

`|= []phi -> F([]phi)` (box phi implies all_future box phi)
-/
example (phi : Formula) : valid (phi.box.imp phi.box.all_future) :=
  temp_future_valid phi

/-!
## Unified Axiom Validity Test

Test that axiom_valid handles all axiom cases.
-/

/--
Test: axiom_valid works for Modal T.
-/
example (phi : Formula) : valid (phi.box.imp phi) :=
  axiom_valid (Axiom.modal_t phi)

/--
Test: axiom_valid works for Modal 4.
-/
example (phi : Formula) : valid (phi.box.imp phi.box.box) :=
  axiom_valid (Axiom.modal_4 phi)

/--
Test: axiom_valid works for Modal B.
-/
example (phi : Formula) : valid (phi.imp phi.diamond.box) :=
  axiom_valid (Axiom.modal_b phi)

/--
Test: axiom_valid works for Temporal 4.
-/
example (phi : Formula) : valid (phi.all_future.imp phi.all_future.all_future) :=
  axiom_valid (Axiom.temp_4 phi)

/-!
## Axiom Derivability Tests

Test that axioms are derivable from any context.
-/

/--
Test: Modal T axiom is derivable from empty context.
-/
example (phi : Formula) : [] ⊢ (phi.box.imp phi) :=
  DerivationTree.axiom [] _ (Axiom.modal_t phi)

/--
Test: Modal 4 axiom is derivable from empty context.
-/
example (phi : Formula) : [] ⊢ (phi.box.imp phi.box.box) :=
  DerivationTree.axiom [] _ (Axiom.modal_4 phi)

/--
Test: Modal B axiom is derivable from empty context.
-/
example (phi : Formula) : [] ⊢ (phi.imp phi.diamond.box) :=
  DerivationTree.axiom [] _ (Axiom.modal_b phi)

/--
Test: Temporal 4 axiom is derivable from empty context.
-/
example (phi : Formula) : [] ⊢ (phi.all_future.imp phi.all_future.all_future) :=
  DerivationTree.axiom [] _ (Axiom.temp_4 phi)

/--
Test: Temporal A axiom is derivable from empty context.
-/
example (phi : Formula) : [] ⊢ (phi.imp (Formula.all_future phi.sometime_past)) :=
  DerivationTree.axiom [] _ (Axiom.temp_a phi)

/-!
## Soundness Application Tests

Test the main soundness theorem.
-/

/--
Test: Soundness theorem type signature.

`Gamma |- phi -> Gamma |= phi`
-/
example (Gamma : Context) (phi : Formula) :
    (Gamma ⊢ phi) → (Gamma ⊨ phi) :=
  soundness Gamma phi

/--
Test: Soundness applies to Modal T derivation.
-/
example (phi : Formula) : [] ⊨ (phi.box.imp phi) := by
  let deriv : [] ⊢ (phi.box.imp phi) := DerivationTree.axiom [] _ (Axiom.modal_t phi)
  exact soundness [] (phi.box.imp phi) deriv

/--
Test: Soundness applies to Modal 4 derivation.
-/
example (phi : Formula) : [] ⊨ (phi.box.imp phi.box.box) := by
  let deriv : [] ⊢ (phi.box.imp phi.box.box) := DerivationTree.axiom [] _ (Axiom.modal_4 phi)
  exact soundness [] (phi.box.imp phi.box.box) deriv

/--
Test: Soundness applies to Temporal 4 derivation.
-/
example (phi : Formula) : [] ⊨ (phi.all_future.imp phi.all_future.all_future) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.temp_4 phi)
  exact soundness [] (phi.all_future.imp phi.all_future.all_future) deriv

/--
Test: Soundness applies to Modal-Future derivation.
-/
example (phi : Formula) : [] ⊨ (phi.box.imp phi.all_future.box) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.modal_future phi)
  exact soundness [] (phi.box.imp phi.all_future.box) deriv

/-!
## Soundness with Assumptions Tests

Test soundness with non-empty contexts.
-/

/--
Test: Soundness preserves assumption.

If phi in Gamma, then Gamma |= phi.
-/
example (phi : Formula) : [phi] ⊨ phi := by
  let deriv : [phi] ⊢ phi := DerivationTree.assumption [phi] phi (List.Mem.head _)
  exact soundness [phi] phi deriv

/--
Test: Soundness preserves modus ponens.

From [phi -> psi, phi] we can derive psi, and soundness gives [phi -> psi, phi] |= psi.
-/
example (phi psi : Formula) : [phi.imp psi, phi] ⊨ psi := by
  let deriv : [phi.imp psi, phi] ⊢ psi :=
    DerivationTree.modus_ponens [phi.imp psi, phi] phi psi
      (DerivationTree.assumption [phi.imp psi, phi] (phi.imp psi) (List.Mem.head _))
      (DerivationTree.assumption [phi.imp psi, phi] phi (List.Mem.tail _ (List.Mem.head _)))
  exact soundness [phi.imp psi, phi] psi deriv

/-!
## Inference Rule Soundness Tests

Test soundness of necessitation rules.
-/

/--
Test: Necessitation preserves soundness.

If [] |- phi, then [] |- []phi, and soundness gives [] |= []phi.
-/
example (phi : Formula) (h : [] ⊢ phi) : [] ⊨ phi.box := by
  let deriv := DerivationTree.necessitation phi h
  exact soundness [] phi.box deriv

/--
Test: Temporal necessitation preserves soundness.

If [] |- phi, then [] |- Fphi, and soundness gives [] |= Fphi.
-/
example (phi : Formula) (h : [] ⊢ phi) : [] ⊨ phi.all_future := by
  let deriv := DerivationTree.temporal_necessitation phi h
  exact soundness [] phi.all_future deriv

/-!
## Validity and Semantic Consequence Connection

Test the connection between validity and empty context consequence.
-/

/--
Test: Validity implies empty context semantic consequence.

If |= phi, then [] |= phi (Validity.valid_iff_empty_consequence).
-/
example (phi : Formula) (h : valid phi) : [] ⊨ phi :=
  Validity.valid_iff_empty_consequence phi |>.mp h

/--
Test: Empty context semantic consequence implies validity.

If [] |= phi, then |= phi.
-/
example (phi : Formula) (h : [] ⊨ phi) : valid phi :=
  Validity.valid_iff_empty_consequence phi |>.mpr h

end BimodalTest.Metalogic_v2.SoundnessTest
