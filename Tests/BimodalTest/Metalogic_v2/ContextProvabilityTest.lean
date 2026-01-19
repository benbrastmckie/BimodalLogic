import Bimodal.Metalogic_v2.Representation.ContextProvability
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.Metalogic_v2.Core.MaximalConsistent

/-!
# Context Provability Tests for Metalogic_v2

Comprehensive tests for the context-based provability and bridge lemmas in
ContextProvability.lean of Metalogic_v2, including:
- Context soundness theorem
- Representation theorem directions (forward and backward)
- Valid/derivable equivalences
- Empty context handling
- Bridge lemmas (not_derivable_implies_neg_consistent)

## Test Organization

- **Context Soundness Tests**: Test context_soundness theorem
- **Representation Forward Tests**: Test ContextDerivable → semantic_consequence
- **Representation Backward Tests**: Test semantic_consequence → ContextDerivable
- **Equivalence Tests**: Test representation_theorem_empty and representation_validity
- **Bridge Lemma Tests**: Test key bridge lemmas for completeness
- **Edge Case Tests**: Test empty context handling

## References

* Metalogic_v2/Representation/ContextProvability.lean - Context provability
* Metalogic_v2/Soundness/Soundness.lean - Soundness theorem
-/

namespace BimodalTest.Metalogic_v2.ContextProvabilityTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic_v2.Core
open Bimodal.Metalogic_v2.Representation
open Bimodal.Metalogic_v2.Soundness

/-!
## Context Soundness Tests

Test the context soundness theorem: ContextDerivable Gamma phi implies semantic_consequence Gamma phi.
-/

/--
Test: context_soundness type signature.

If Gamma |- phi via ContextDerivable, then Gamma |= phi semantically.
-/
example (Gamma : Context) (phi : Formula) :
    ContextDerivable Gamma phi → semantic_consequence Gamma phi :=
  context_soundness Gamma phi

/--
Test: context_soundness for assumption.

If phi in Gamma, then Gamma |= phi (trivially true).
-/
example (phi : Formula) : semantic_consequence [phi] phi := by
  apply context_soundness
  exact ⟨DerivationTree.assumption [phi] phi (List.Mem.head _)⟩

/--
Test: context_soundness for modus ponens.

[phi -> psi, phi] |= psi
-/
example (phi psi : Formula) : semantic_consequence [phi.imp psi, phi] psi := by
  apply context_soundness
  have h_imp : [phi.imp psi, phi] ⊢ (phi.imp psi) :=
    DerivationTree.assumption _ _ (by simp)
  have h_phi : [phi.imp psi, phi] ⊢ phi :=
    DerivationTree.assumption _ _ (by simp)
  exact ⟨DerivationTree.modus_ponens _ _ _ h_imp h_phi⟩

/--
Test: context_soundness for axiom.

Gamma |= modal_t phi (box phi -> phi is valid)
-/
example (Gamma : Context) (phi : Formula) : semantic_consequence Gamma (phi.box.imp phi) := by
  apply context_soundness
  exact ⟨DerivationTree.axiom Gamma _ (Axiom.modal_t phi)⟩

/-!
## Representation Theorem Forward Tests

Test the forward direction: ContextDerivable [] phi → semantic_consequence [] phi.
-/

/--
Test: representation_theorem_forward type signature.

If [] |- phi, then [] |= phi by soundness.
-/
example (phi : Formula) :
    ContextDerivable [] phi → semantic_consequence [] phi :=
  @representation_theorem_forward phi

/--
Test: representation_theorem_forward for Modal T.

[] |- (box phi -> phi) implies [] |= (box phi -> phi)
-/
example (phi : Formula) : semantic_consequence [] (phi.box.imp phi) := by
  apply representation_theorem_forward
  exact ⟨DerivationTree.axiom [] _ (Axiom.modal_t phi)⟩

/--
Test: representation_theorem_forward for Modal 4.

[] |- (box phi -> box box phi) implies [] |= (box phi -> box box phi)
-/
example (phi : Formula) : semantic_consequence [] (phi.box.imp phi.box.box) := by
  apply representation_theorem_forward
  exact ⟨DerivationTree.axiom [] _ (Axiom.modal_4 phi)⟩

/--
Test: representation_theorem_forward for Modal B.

[] |- (phi -> box diamond phi) implies [] |= (phi -> box diamond phi)
-/
example (phi : Formula) : semantic_consequence [] (phi.imp phi.diamond.box) := by
  apply representation_theorem_forward
  exact ⟨DerivationTree.axiom [] _ (Axiom.modal_b phi)⟩

/-!
## Bridge Lemma Tests

Test key bridge lemmas used in completeness proof.
-/

/--
Test: not_derivable_implies_neg_consistent type signature.

If phi is not derivable from empty context, then [neg phi] is consistent.
This is the key contrapositive lemma for completeness.
-/
example (phi : Formula) :
    ¬ContextDerivable [] phi → Consistent [phi.neg] :=
  @not_derivable_implies_neg_consistent phi

/--
Test: not_derivable_implies_neg_consistent structure.

Verify the logical structure: if we can't prove phi, then neg phi doesn't lead to contradiction.
-/
example (phi : Formula) (h_not_deriv : ¬ContextDerivable [] phi) :
    ¬Nonempty (DerivationTree [phi.neg] Formula.bot) :=
  @not_derivable_implies_neg_consistent phi h_not_deriv

/-!
## Representation Theorem Backward Tests

Test the backward direction: semantic_consequence [] phi → ContextDerivable [] phi.
This is the completeness direction (noncomputable).
-/

/--
Test: representation_theorem_backward_empty type signature.

[] |= phi → [] |- phi (completeness for empty context)
-/
noncomputable example (phi : Formula) :
    semantic_consequence [] phi → ContextDerivable [] phi :=
  @representation_theorem_backward_empty phi

/--
Test: representation_theorem_backward_empty for valid formula.

If phi is valid, then [] |= phi, hence [] |- phi by completeness.
-/
noncomputable example (phi : Formula) (h_valid : valid phi) : ContextDerivable [] phi := by
  apply representation_theorem_backward_empty
  intro D _ _ _ F M tau t _
  exact h_valid D F M tau t

/-!
## Representation Theorem Equivalence Tests

Test the full equivalence: ContextDerivable [] phi ↔ semantic_consequence [] phi.
-/

/--
Test: representation_theorem_empty type signature.

[] |- phi ↔ [] |= phi
-/
noncomputable example (phi : Formula) :
    ContextDerivable [] phi ↔ semantic_consequence [] phi :=
  @representation_theorem_empty phi

/--
Test: representation_theorem_empty forward.

[] |- phi → [] |= phi
-/
example (phi : Formula) (h : ContextDerivable [] phi) : semantic_consequence [] phi :=
  (@representation_theorem_empty phi).mp h

/--
Test: representation_theorem_empty backward.

[] |= phi → [] |- phi
-/
noncomputable example (phi : Formula) (h : semantic_consequence [] phi) :
    ContextDerivable [] phi :=
  (@representation_theorem_empty phi).mpr h

/-!
## Valid/Derivable Equivalence Tests

Test the equivalences between validity and derivability.
-/

/--
Test: valid_implies_derivable type signature.

If phi is valid (true in all models), then [] |- phi.
-/
noncomputable example (phi : Formula) :
    valid phi → ContextDerivable [] phi :=
  @valid_implies_derivable phi

/--
Test: derivable_implies_valid type signature.

If [] |- phi, then phi is valid.
-/
example (phi : Formula) :
    ContextDerivable [] phi → valid phi :=
  @derivable_implies_valid phi

/--
Test: representation_validity type signature.

[] |- phi ↔ |= phi
-/
noncomputable example (phi : Formula) :
    ContextDerivable [] phi ↔ valid phi :=
  @representation_validity phi

/--
Test: representation_validity forward (soundness direction).

[] |- phi → |= phi
-/
example (phi : Formula) (h : ContextDerivable [] phi) : valid phi :=
  (@representation_validity phi).mp h

/--
Test: representation_validity backward (completeness direction).

|= phi → [] |- phi
-/
noncomputable example (phi : Formula) (h : valid phi) : ContextDerivable [] phi :=
  (@representation_validity phi).mpr h

/-!
## Valid Implies Derivable Concrete Tests

Test valid_implies_derivable with specific valid formulas.
-/

/--
Test: valid_implies_derivable for Modal T axiom.

Modal T (box phi -> phi) is valid, hence derivable.
-/
noncomputable example (phi : Formula) : ContextDerivable [] (phi.box.imp phi) := by
  apply valid_implies_derivable
  exact modal_t_valid phi

/--
Test: valid_implies_derivable for Modal 4 axiom.

Modal 4 (box phi -> box box phi) is valid, hence derivable.
-/
noncomputable example (phi : Formula) : ContextDerivable [] (phi.box.imp phi.box.box) := by
  apply valid_implies_derivable
  exact modal_4_valid phi

/--
Test: valid_implies_derivable for Modal K distribution.

K distribution (box (phi -> psi) -> (box phi -> box psi)) is valid, hence derivable.
-/
noncomputable example (phi psi : Formula) :
    ContextDerivable [] ((phi.imp psi).box.imp (phi.box.imp psi.box)) := by
  apply valid_implies_derivable
  exact modal_k_dist_valid phi psi

/--
Test: valid_implies_derivable for Temporal 4 axiom.

Temporal 4 (Fphi -> FFphi) is valid, hence derivable.
-/
noncomputable example (phi : Formula) :
    ContextDerivable [] (phi.all_future.imp phi.all_future.all_future) := by
  apply valid_implies_derivable
  exact temp_4_valid phi

/-!
## Derivable Implies Valid Concrete Tests

Test derivable_implies_valid with specific derivations.
-/

/--
Test: derivable_implies_valid for Modal T.

[] |- (box phi -> phi) implies |= (box phi -> phi).
-/
example (phi : Formula) : valid (phi.box.imp phi) := by
  apply derivable_implies_valid
  exact ⟨DerivationTree.axiom [] _ (Axiom.modal_t phi)⟩

/--
Test: derivable_implies_valid for Modal 4.

[] |- (box phi -> box box phi) implies |= (box phi -> box box phi).
-/
example (phi : Formula) : valid (phi.box.imp phi.box.box) := by
  apply derivable_implies_valid
  exact ⟨DerivationTree.axiom [] _ (Axiom.modal_4 phi)⟩

/--
Test: derivable_implies_valid for Ex Falso.

[] |- (bot -> phi) implies |= (bot -> phi).
-/
example (phi : Formula) : valid (Formula.bot.imp phi) := by
  apply derivable_implies_valid
  exact ⟨DerivationTree.axiom [] _ (Axiom.ex_falso phi)⟩

/-!
## Empty Context Handling Tests

Test correct handling of empty context.
-/

/--
Test: Empty context semantic consequence is equivalent to validity.

[] |= phi ↔ |= phi (via Validity.valid_iff_empty_consequence)
-/
example (phi : Formula) (h : valid phi) : semantic_consequence [] phi := by
  intro D _ _ _ F M tau t _
  exact h D F M tau t

/--
Test: Empty context derivation is sound.

[] |- phi → [] |= phi
-/
example (phi : Formula) (h : ContextDerivable [] phi) : semantic_consequence [] phi := by
  obtain ⟨d⟩ := h
  exact context_soundness [] phi ⟨d⟩

/--
Test: Empty context has no members.

[] has no assumptions, so derivations must use axioms or rules.
-/
example : ([] : Context) = [] := rfl

/-!
## Round-Trip Tests

Test round-trip through soundness and completeness.
-/

/--
Test: Soundness-Completeness round-trip (derivable -> valid -> derivable).
-/
noncomputable example (phi : Formula) (h : ContextDerivable [] phi) :
    ContextDerivable [] phi := by
  have h_valid : valid phi := derivable_implies_valid h
  exact valid_implies_derivable h_valid

/--
Test: Soundness-Completeness round-trip (valid -> derivable -> valid).
-/
noncomputable example (phi : Formula) (h : valid phi) : valid phi := by
  have h_deriv : ContextDerivable [] phi := valid_implies_derivable h
  exact derivable_implies_valid h_deriv

/--
Test: semantic_consequence round-trip.
-/
noncomputable example (phi : Formula) (h : ContextDerivable [] phi) :
    ContextDerivable [] phi := by
  have h_sem : semantic_consequence [] phi := representation_theorem_forward h
  exact representation_theorem_backward_empty h_sem

/-!
## Concrete Formula Tests

Test with specific concrete formulas.
-/

/--
Test: Propositional K axiom is derivable.

[] |- (phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi))
-/
example (phi psi chi : Formula) :
    ContextDerivable [] ((phi.imp (psi.imp chi)).imp ((phi.imp psi).imp (phi.imp chi))) :=
  ⟨DerivationTree.axiom [] _ (Axiom.prop_k phi psi chi)⟩

/--
Test: Propositional S axiom is derivable.

[] |- phi -> (psi -> phi)
-/
example (phi psi : Formula) : ContextDerivable [] (phi.imp (psi.imp phi)) :=
  ⟨DerivationTree.axiom [] _ (Axiom.prop_s phi psi)⟩

/--
Test: Modal-Future interaction axiom is derivable.

[] |- box phi -> box (all_future phi)
-/
example (phi : Formula) : ContextDerivable [] (phi.box.imp phi.all_future.box) :=
  ⟨DerivationTree.axiom [] _ (Axiom.modal_future phi)⟩

/--
Test: Temporal-Future interaction axiom is derivable.

[] |- box phi -> all_future (box phi)
-/
example (phi : Formula) : ContextDerivable [] (phi.box.imp phi.box.all_future) :=
  ⟨DerivationTree.axiom [] _ (Axiom.temp_future phi)⟩

/-!
## Integration with Soundness Tests

Verify context_soundness agrees with main soundness theorem.
-/

/--
Test: context_soundness agrees with soundness on empty context.

Both should give semantic_consequence [] phi.
-/
example (phi : Formula) (d : [] ⊢ phi) :
    (context_soundness [] phi ⟨d⟩ = soundness [] phi d) := by
  -- Both produce semantic_consequence, which is definitionally equal
  rfl

/--
Test: context_soundness agrees with soundness on non-empty context.
-/
example (phi psi : Formula) (d : [phi] ⊢ psi) :
    (context_soundness [phi] psi ⟨d⟩ = soundness [phi] psi d) := by
  rfl

end BimodalTest.Metalogic_v2.ContextProvabilityTest
