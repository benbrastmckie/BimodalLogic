import Bimodal.Metalogic_v2.Representation.RepresentationTheorem
import Bimodal.Metalogic_v2.Representation.CanonicalModel
import Bimodal.Metalogic_v2.Representation.TruthLemma
import Bimodal.Metalogic_v2.Representation.ContextProvability
import Bimodal.Metalogic_v2.Core.MaximalConsistent
import Bimodal.Metalogic_v2.Core.DeductionTheorem
import Bimodal.Metalogic_v2.Soundness.Soundness

/-!
# Finite Model Property Tests for Metalogic_v2

Comprehensive tests for the FMP-related infrastructure in Metalogic_v2, including:
- Formula complexity and subformula properties
- Core consistency definitions re-exported via FMP hub
- Lindenbaum extension properties
- Canonical model construction
- Representation theorem applications

## Note on FMP Coverage

This test file covers the FMP-related infrastructure that builds successfully.
The FiniteModelProperty.lean module has a pending type mismatch issue between
old Metalogic and new Metalogic_v2 SemanticWorldState types. The following tests
verify all the supporting infrastructure that FMP depends on.

## Test Organization

- **Formula Complexity Tests**: Test complexity function for all constructors
- **Core Definitions Tests**: Test Consistent, SetConsistent, SetMaximalConsistent
- **Lindenbaum Tests**: Test set_lindenbaum theorem
- **Canonical Model Tests**: Test canonical world state and model construction
- **Representation Tests**: Test representation theorem applications

## References

* Metalogic_v2/Core/MaximalConsistent.lean - MCS theory
* Metalogic_v2/Representation/CanonicalModel.lean - Canonical model
* Metalogic_v2/Representation/TruthLemma.lean - Truth lemma
* Metalogic_v2/Representation/RepresentationTheorem.lean - Main representation
-/

namespace BimodalTest.Metalogic_v2.FMPTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic_v2.Core
open Bimodal.Metalogic_v2.Representation
open Bimodal.Metalogic_v2.Soundness

/-!
## Formula Complexity Tests

Test the formula complexity function for all formula constructors.
Formula complexity is used in FMP proofs to bound subformula list size.
-/

/--
Test: Atom has complexity 1.
-/
example (p : String) : (Formula.atom p).complexity = 1 := rfl

/--
Test: Bot has complexity 1.
-/
example : Formula.bot.complexity = 1 := rfl

/--
Test: Box complexity is 1 plus inner complexity.
-/
example (phi : Formula) : (Formula.box phi).complexity = 1 + phi.complexity := rfl

/--
Test: Imp complexity is 1 plus sum of inner complexities.
-/
example (phi psi : Formula) :
    (Formula.imp phi psi).complexity = 1 + phi.complexity + psi.complexity := rfl

/--
Test: all_future complexity is 1 plus inner complexity.
-/
example (phi : Formula) : (Formula.all_future phi).complexity = 1 + phi.complexity := rfl

/--
Test: all_past complexity is 1 plus inner complexity.
-/
example (phi : Formula) : (Formula.all_past phi).complexity = 1 + phi.complexity := rfl

/--
Test: Complexity is always positive (at least 1).
-/
example (phi : Formula) : 1 ≤ phi.complexity := by
  cases phi with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ => simp only [Formula.complexity]; omega
  | box _ => simp only [Formula.complexity]; omega
  | all_future _ => simp only [Formula.complexity]; omega
  | all_past _ => simp only [Formula.complexity]; omega

/-!
## Consistency Definitions Tests

Test the core consistency definitions used in FMP and completeness proofs.
-/

/--
Test: Consistent definition.

A context Gamma is consistent iff we cannot derive bottom from it.
-/
example (Gamma : Context) :
    Consistent Gamma = ¬Nonempty (DerivationTree Gamma Formula.bot) := rfl

/--
Test: SetConsistent definition.

A set S is consistent iff every finite list from S is consistent.
-/
example (S : Set Formula) :
    SetConsistent S = (∀ L : List Formula, (∀ phi ∈ L, phi ∈ S) → Consistent L) := rfl

/--
Test: SetMaximalConsistent definition.

A set is maximally consistent if it's consistent and cannot be extended.
-/
example (S : Set Formula) :
    SetMaximalConsistent S =
    (SetConsistent S ∧ ∀ phi : Formula, phi ∉ S → ¬SetConsistent (insert phi S)) := rfl

/--
Test: Empty list is consistent.
-/
example : Consistent [] := by
  intro ⟨d⟩
  have h_sem := soundness [] Formula.bot d
  have h_valid := h_sem Int TaskFrame.trivial_frame TaskModel.all_false
      WorldHistory.trivial 0 (fun _ h => (List.not_mem_nil h).elim)
  simp only [truth_at] at h_valid

/--
Test: Contradiction is inconsistent.
-/
example (phi : Formula) : ¬Consistent [phi, phi.neg] := by
  intro h
  apply h
  have h_phi : [phi, phi.neg] ⊢ phi := DerivationTree.assumption _ _ (by simp)
  have h_neg : [phi, phi.neg] ⊢ phi.neg := DerivationTree.assumption _ _ (by simp)
  exact ⟨DerivationTree.modus_ponens _ _ _ h_neg h_phi⟩

/-!
## Lindenbaum Extension Tests

Test Lindenbaum's lemma which extends consistent sets to maximal consistent sets.
-/

/--
Test: set_lindenbaum type signature.

Every consistent set extends to a maximal consistent set.
-/
example (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent M :=
  set_lindenbaum S h

/--
Test: Lindenbaum extension contains original set.
-/
example (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M := by
  obtain ⟨M, hSM, _⟩ := set_lindenbaum S h
  exact ⟨M, hSM⟩

/--
Test: Lindenbaum extension is maximal.
-/
example (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, SetMaximalConsistent M := by
  obtain ⟨M, _, hmax⟩ := set_lindenbaum S h
  exact ⟨M, hmax⟩

/--
Test: Lindenbaum preserves consistency.

The extension is still consistent.
-/
example (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, SetConsistent M := by
  obtain ⟨M, _, hmax⟩ := set_lindenbaum S h
  exact ⟨M, hmax.1⟩

/-!
## MCS Properties Tests

Test key properties of maximal consistent sets.
-/

/--
Test: MCS negation completeness.

Every MCS contains phi or neg phi for any phi.
-/
example (S : Set Formula) (h : SetMaximalConsistent S) (phi : Formula) :
    phi ∈ S ∨ phi.neg ∈ S :=
  mcs_contains_or_neg h phi

/--
Test: MCS modus ponens closure.

If (phi -> psi) in S and phi in S, then psi in S.
-/
example (S : Set Formula) (h : SetMaximalConsistent S) (phi psi : Formula) :
    (phi.imp psi) ∈ S → phi ∈ S → psi ∈ S :=
  mcs_modus_ponens h

/--
Test: MCS consistency - cannot contain both phi and neg phi.
-/
example (S : Set Formula) (h : SetConsistent S) (phi : Formula)
    (h_phi : phi ∈ S) (h_neg : phi.neg ∈ S) : False :=
  set_consistent_not_both h phi h_phi h_neg

/--
Test: MCS excludes phi if neg phi is present.
-/
example (S : Set Formula) (h : SetMaximalConsistent S) (phi : Formula)
    (h_neg : phi.neg ∈ S) : phi ∉ S :=
  set_mcs_neg_excludes h phi h_neg

/-!
## Canonical World State Tests

Test the canonical world state construction.
-/

/--
Test: CanonicalWorldState type exists.
-/
example : Type := CanonicalWorldState

/--
Test: CanonicalWorldState has carrier set.
-/
example (w : CanonicalWorldState) : Set Formula := w.carrier

/--
Test: Canonical worlds are consistent.
-/
example (w : CanonicalWorldState) : SetConsistent w.carrier :=
  canonical_world_consistent w

/--
Test: Canonical worlds are maximal.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    phi ∉ w.carrier → ¬SetConsistent (insert phi w.carrier) :=
  canonical_world_maximal w phi

/--
Test: Canonical worlds are negation complete.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    phi ∈ w.carrier ∨ phi.neg ∈ w.carrier :=
  canonical_complete w phi

/-!
## Canonical Frame and Model Tests

Test the canonical frame and model construction.
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
Test: CanonicalModel type exists.
-/
example : Type := CanonicalModel

/--
Test: canonicalModel construction.
-/
example : CanonicalModel := canonicalModel

/-!
## Truth Lemma Tests

Test the truth lemma for canonical models.
-/

/--
Test: canonicalTruthAt type signature.
-/
example (w : CanonicalWorldState) (phi : Formula) : Prop :=
  canonicalTruthAt w phi

/--
Test: truthLemma_detailed - general truth lemma.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi ↔ phi ∈ w.carrier :=
  truthLemma_detailed w phi

/--
Test: truthLemma_atom - truth lemma for atoms.
-/
example (w : CanonicalWorldState) (p : String) :
    canonicalTruthAt w (Formula.atom p) ↔ Formula.atom p ∈ w.carrier :=
  truthLemma_atom w p

/--
Test: truthLemma_bot - bottom is never true.
-/
example (w : CanonicalWorldState) : ¬canonicalTruthAt w Formula.bot :=
  truthLemma_bot w

/--
Test: truthLemma_imp - truth lemma for implication.
-/
example (w : CanonicalWorldState) (phi psi : Formula) :
    canonicalTruthAt w (phi.imp psi) ↔ (phi.imp psi) ∈ w.carrier :=
  truthLemma_imp w phi psi

/--
Test: truthLemma_box - truth lemma for box.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.box ↔ phi.box ∈ w.carrier :=
  truthLemma_box w phi

/--
Test: truthLemma_all_past - truth lemma for all_past.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.all_past ↔ phi.all_past ∈ w.carrier :=
  truthLemma_all_past w phi

/--
Test: truthLemma_all_future - truth lemma for all_future.
-/
example (w : CanonicalWorldState) (phi : Formula) :
    canonicalTruthAt w phi.all_future ↔ phi.all_future ∈ w.carrier :=
  truthLemma_all_future w phi

/--
Test: contextTruthLemma - truth lemma for contexts.
-/
example (w : CanonicalWorldState) (Gamma : Context) :
    (∀ phi ∈ Gamma, canonicalTruthAt w phi) ↔ (∀ phi ∈ Gamma, phi ∈ w.carrier) :=
  contextTruthLemma w

/-!
## Canonical World Properties Tests

Test derived properties of canonical worlds.
-/

/--
Test: canonical_modus_ponens.

If (phi -> psi) in w and phi in w, then psi in w.
-/
example (w : CanonicalWorldState) (phi psi : Formula) :
    (phi.imp psi) ∈ w.carrier → phi ∈ w.carrier → psi ∈ w.carrier :=
  canonical_modus_ponens w

/--
Test: necessitation_lemma.

If phi is derivable from empty context, then box phi is in every canonical world.
-/
noncomputable example (w : CanonicalWorldState) (phi : Formula) :
    ContextDerivable [] phi → phi.box ∈ w.carrier :=
  necessitation_lemma w

/-!
## Representation Theorem Tests

Test the main representation theorem.
-/

/--
Test: representation_theorem type signature.
-/
noncomputable example (Gamma : Context) :
    Consistent Gamma → ∃ w : CanonicalWorldState, ∀ phi ∈ Gamma, canonicalTruthAt w phi :=
  representation_theorem

/--
Test: strong_representation_theorem type signature.
-/
noncomputable example (Gamma : Context) (phi : Formula) :
    ¬ContextDerivable Gamma phi.neg →
    ∃ w : CanonicalWorldState, (∀ psi ∈ Gamma, canonicalTruthAt w psi) ∧ canonicalTruthAt w phi :=
  strong_representation_theorem

/--
Test: mcs_extension_truth.
-/
noncomputable example (Gamma : Context) (phi : Formula) :
    Consistent Gamma → phi ∈ Gamma → ∃ w : CanonicalWorldState, canonicalTruthAt w phi :=
  mcs_extension_truth

/-!
## Canonical Satisfiability Tests

Test canonical satisfiability definitions.
-/

/--
Test: canonicalSatisfiable type signature.
-/
example (phi : Formula) : Prop := canonicalSatisfiable phi

/--
Test: canonicalContextSatisfiable type signature.
-/
example (Gamma : Context) : Prop := canonicalContextSatisfiable Gamma

/--
Test: representation_satisfiability equivalence.
-/
noncomputable example (Gamma : Context) :
    Consistent Gamma ↔ canonicalContextSatisfiable Gamma :=
  representation_satisfiability

/-!
## Context Provability Tests

Test context-based provability and soundness.
-/

/--
Test: context_soundness type signature.
-/
example (Gamma : Context) (phi : Formula) :
    ContextDerivable Gamma phi → semantic_consequence Gamma phi :=
  context_soundness Gamma phi

/--
Test: representation_theorem_forward type signature.
-/
example (phi : Formula) :
    ContextDerivable [] phi → semantic_consequence [] phi :=
  @representation_theorem_forward phi

/--
Test: not_derivable_implies_neg_consistent type signature.
-/
example (phi : Formula) :
    ¬ContextDerivable [] phi → Consistent [phi.neg] :=
  @not_derivable_implies_neg_consistent phi

/--
Test: representation_theorem_backward_empty type signature.
-/
noncomputable example (phi : Formula) :
    semantic_consequence [] phi → ContextDerivable [] phi :=
  @representation_theorem_backward_empty phi

/--
Test: representation_theorem_empty equivalence.
-/
noncomputable example (phi : Formula) :
    ContextDerivable [] phi ↔ semantic_consequence [] phi :=
  @representation_theorem_empty phi

/--
Test: valid_implies_derivable.
-/
noncomputable example (phi : Formula) :
    valid phi → ContextDerivable [] phi :=
  @valid_implies_derivable phi

/--
Test: derivable_implies_valid.
-/
example (phi : Formula) :
    ContextDerivable [] phi → valid phi :=
  @derivable_implies_valid phi

/--
Test: representation_validity equivalence.
-/
noncomputable example (phi : Formula) :
    ContextDerivable [] phi ↔ valid phi :=
  @representation_validity phi

/-!
## Deduction Theorem Tests

Test the deduction theorem used in completeness proofs.
-/

/--
Test: deduction_theorem type signature.
-/
noncomputable example (Gamma : Context) (phi psi : Formula) :
    DerivationTree (phi :: Gamma) psi → DerivationTree Gamma (phi.imp psi) :=
  deduction_theorem Gamma phi psi

/--
Test: Deduction theorem application - identity.
-/
noncomputable example (phi : Formula) : [] ⊢ (phi.imp phi) := by
  have h : [phi] ⊢ phi := DerivationTree.assumption [phi] phi (List.Mem.head _)
  exact deduction_theorem [] phi phi h

/-!
## Completeness Corollary Tests

Test completeness derived from representation.
-/

/--
Test: completeness_corollary type signature.
-/
noncomputable example (phi : Formula) :
    valid phi → ContextDerivable [] phi :=
  completeness_corollary

/-!
## Soundness Tests (FMP prerequisite)

Test soundness which is used in FMP proofs.
-/

/--
Test: soundness type signature.
-/
example (Gamma : Context) (phi : Formula) :
    (Gamma ⊢ phi) → (Gamma ⊨ phi) :=
  soundness Gamma phi

/--
Test: Soundness for Modal T.
-/
example (phi : Formula) : [] ⊨ (phi.box.imp phi) := by
  let deriv : [] ⊢ (phi.box.imp phi) := DerivationTree.axiom [] _ (Axiom.modal_t phi)
  exact soundness [] (phi.box.imp phi) deriv

/--
Test: Soundness for Modal 4.
-/
example (phi : Formula) : [] ⊨ (phi.box.imp phi.box.box) := by
  let deriv : [] ⊢ (phi.box.imp phi.box.box) := DerivationTree.axiom [] _ (Axiom.modal_4 phi)
  exact soundness [] (phi.box.imp phi.box.box) deriv

/-!
## Chain Consistency Tests

Test chain consistency properties used in Lindenbaum proof.
-/

/--
Test: consistent_chain_union type signature.

Union of a chain of consistent sets is consistent.
-/
example (C : Set (Set Formula)) (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, SetConsistent S) : SetConsistent (⋃₀ C) :=
  consistent_chain_union hchain hCne hcons

/--
Test: finite_list_in_chain_member type signature.

Any finite list from a chain union comes from some single member.
-/
example (C : Set (Set Formula)) (hchain : IsChain (· ⊆ ·) C) (L : List Formula)
    (hL : ∀ phi ∈ L, phi ∈ ⋃₀ C) (hCne : C.Nonempty) :
    ∃ S ∈ C, ∀ phi ∈ L, phi ∈ S :=
  finite_list_in_chain_member hchain L hL hCne

/-!
## Concrete Formula Examples

Test with specific concrete formulas.
-/

/--
Test: Concrete atom formula.
-/
example : Formula.atom "p" ≠ Formula.bot := by
  intro h
  cases h

/--
Test: Nested box formula complexity.
-/
example : (Formula.box (Formula.box (Formula.atom "p"))).complexity = 3 := rfl

/--
Test: Implication complexity.
-/
example : (Formula.imp (Formula.atom "p") (Formula.atom "q")).complexity = 3 := rfl

/--
Test: Complex formula complexity (box (imp p q)).
-/
example : (Formula.box (Formula.imp (Formula.atom "p") (Formula.atom "q"))).complexity = 4 := rfl

/--
Test: Temporal formula complexity (all_future (all_past p)).
-/
example : (Formula.all_future (Formula.all_past (Formula.atom "p"))).complexity = 3 := rfl

end BimodalTest.Metalogic_v2.FMPTest
