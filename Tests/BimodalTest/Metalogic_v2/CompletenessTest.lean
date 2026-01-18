import Bimodal.Metalogic_v2.Completeness.StrongCompleteness
import Bimodal.Metalogic_v2.Soundness.Soundness

/-!
# Completeness Layer Tests for Metalogic_v2

Example-based tests for the Completeness layer of Metalogic_v2, including:
- Weak completeness theorem
- Strong completeness theorem
- provable_iff_valid equivalence
- context_provable_iff_entails equivalence

## Test Organization

- **Weak Completeness Tests**: Test valid -> provable (empty context)
- **Strong Completeness Tests**: Test semantic_consequence -> derivable (any context)
- **Equivalence Tests**: Test bidirectional provability/validity equivalences
- **Integration Tests**: Test completeness with soundness

## Known Limitations

The completeness theorems rely on the axiom `representation_theorem_backward_empty`
which asserts that if phi is valid, then [neg phi] is inconsistent. This axiom
makes the completeness proofs noncomputable.

## References

* Metalogic_v2/Completeness/WeakCompleteness.lean - Weak completeness
* Metalogic_v2/Completeness/StrongCompleteness.lean - Strong completeness
-/

namespace BimodalTest.Metalogic_v2.CompletenessTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic_v2.Core
open Bimodal.Metalogic_v2.Completeness
open Bimodal.Metalogic_v2.Soundness

/-!
## Weak Completeness Tests

Test weak completeness: valid -> provable from empty context.
-/

/--
Test: weak_completeness type signature.

`|= phi -> [] |- phi`
-/
noncomputable example (phi : Formula) :
    valid phi → ContextDerivable [] phi :=
  weak_completeness phi

/--
Test: Apply weak completeness to Modal T validity.

Since |= []phi -> phi (modal T is valid), we get [] |- []phi -> phi.
-/
noncomputable example (phi : Formula) : ContextDerivable [] (phi.box.imp phi) := by
  apply weak_completeness
  exact modal_t_valid phi

/--
Test: Apply weak completeness to Modal 4 validity.

Since |= []phi -> [][]phi (modal 4 is valid), we get [] |- []phi -> [][]phi.
-/
noncomputable example (phi : Formula) : ContextDerivable [] (phi.box.imp phi.box.box) := by
  apply weak_completeness
  exact modal_4_valid phi

/--
Test: Apply weak completeness to Temporal 4 validity.

Since |= Fphi -> FFphi (temporal 4 is valid), we get [] |- Fphi -> FFphi.
-/
noncomputable example (phi : Formula) :
    ContextDerivable [] (phi.all_future.imp phi.all_future.all_future) := by
  apply weak_completeness
  exact temp_4_valid phi

/-!
## provable_iff_valid Tests

Test the bidirectional equivalence between provability and validity.
-/

/--
Test: provable_iff_valid type signature.

`[] |- phi <-> |= phi`
-/
noncomputable example (phi : Formula) :
    ContextDerivable [] phi ↔ valid phi :=
  provable_iff_valid phi

/--
Test: provable_iff_valid forward direction (provable -> valid).

This is the soundness direction.
-/
example (phi : Formula) (h : ContextDerivable [] phi) : valid phi :=
  (provable_iff_valid phi).mp h

/--
Test: provable_iff_valid backward direction (valid -> provable).

This is the completeness direction.
-/
noncomputable example (phi : Formula) (h : valid phi) : ContextDerivable [] phi :=
  (provable_iff_valid phi).mpr h

/--
Test: provable_iff_valid for Modal T.

[] |- []phi -> phi <-> |= []phi -> phi
-/
noncomputable example (phi : Formula) :
    ContextDerivable [] (phi.box.imp phi) ↔ valid (phi.box.imp phi) :=
  provable_iff_valid (phi.box.imp phi)

/-!
## Strong Completeness Tests

Test strong completeness: semantic_consequence -> derivable (any context).
-/

/--
Test: strong_completeness type signature.

`Gamma |= phi -> Gamma |- phi`
-/
noncomputable example (Gamma : Context) (phi : Formula) :
    Gamma ⊨ phi → ContextDerivable Gamma phi :=
  strong_completeness Gamma phi

/--
Test: strong_completeness applied to assumption.

[phi] |= phi (trivially), so [phi] |- phi by completeness.
-/
noncomputable example (phi : Formula) : ContextDerivable [phi] phi := by
  apply strong_completeness
  intro T _ _ _ F M tau t h_all
  exact h_all phi (List.Mem.head _)

/--
Test: strong_completeness applied to modus ponens consequence.

[phi -> psi, phi] |= psi, so [phi -> psi, phi] |- psi by completeness.
-/
noncomputable example (phi psi : Formula) : ContextDerivable [phi.imp psi, phi] psi := by
  apply strong_completeness
  intro T _ _ _ F M tau t h_all
  have h_imp := h_all (phi.imp psi) (List.Mem.head _)
  have h_phi := h_all phi (List.Mem.tail _ (List.Mem.head _))
  unfold truth_at at h_imp
  exact h_imp h_phi

/-!
## context_provable_iff_entails Tests

Test the bidirectional equivalence between context derivability and entailment.
-/

/--
Test: context_provable_iff_entails type signature.

`Gamma |- phi <-> Gamma |= phi`
-/
noncomputable example (Gamma : Context) (phi : Formula) :
    ContextDerivable Gamma phi ↔ Gamma ⊨ phi :=
  context_provable_iff_entails Gamma phi

/--
Test: context_provable_iff_entails forward direction (derivable -> entails).

This is soundness with ContextDerivable.
-/
example (Gamma : Context) (phi : Formula) (h : ContextDerivable Gamma phi) :
    Gamma ⊨ phi :=
  (context_provable_iff_entails Gamma phi).mp h

/--
Test: context_provable_iff_entails backward direction (entails -> derivable).

This is completeness with ContextDerivable.
-/
noncomputable example (Gamma : Context) (phi : Formula) (h : Gamma ⊨ phi) :
    ContextDerivable Gamma phi :=
  (context_provable_iff_entails Gamma phi).mpr h

/-!
## impChain Helper Tests

Test the implication chain helper used in strong completeness.
-/

/--
Test: impChain type signature.

impChain converts [phi1, phi2, ..., phin] and psi to phi1 -> (phi2 -> ... -> (phin -> psi))
-/
example (Gamma : Context) (phi : Formula) : Formula := impChain Gamma phi

/--
Test: impChain of empty context is identity.

impChain [] phi = phi
-/
example (phi : Formula) : impChain [] phi = phi := rfl

/--
Test: impChain of singleton context.

impChain [psi] phi = psi -> phi
-/
example (phi psi : Formula) : impChain [psi] phi = psi.imp phi := rfl

/--
Test: impChain of two-element context.

impChain [psi1, psi2] phi = psi1 -> (psi2 -> phi)
-/
example (phi psi1 psi2 : Formula) :
    impChain [psi1, psi2] phi = psi1.imp (psi2.imp phi) := rfl

/--
Test: imp_chain_unfold type signature.

Converts derivation of impChain Gamma phi from Delta to derivation of phi from Gamma ++ Delta.
-/
noncomputable example (Gamma Delta : Context) (phi : Formula) :
    DerivationTree Delta (impChain Gamma phi) → DerivationTree (Gamma ++ Delta) phi :=
  imp_chain_unfold Gamma Delta phi

/-!
## Soundness-Completeness Integration Tests

Test that soundness and completeness work together correctly.
-/

/--
Test: Soundness + Completeness round-trip (provable -> valid -> provable).

For any theorem phi: [] |- phi -> |= phi -> [] |- phi
-/
noncomputable example (phi : Formula) (h : ContextDerivable [] phi) :
    ContextDerivable [] phi := by
  have h_valid : valid phi := (provable_iff_valid phi).mp h
  exact (provable_iff_valid phi).mpr h_valid

/--
Test: Soundness + Completeness round-trip (valid -> provable -> valid).

For any valid formula phi: |= phi -> [] |- phi -> |= phi
-/
noncomputable example (phi : Formula) (h : valid phi) : valid phi := by
  have h_prov : ContextDerivable [] phi := weak_completeness phi h
  exact (provable_iff_valid phi).mp h_prov

/--
Test: Context-level round-trip.

For any context Gamma and formula phi: Gamma |- phi <-> Gamma |= phi
-/
noncomputable example (Gamma : Context) (phi : Formula) (h : ContextDerivable Gamma phi) :
    ContextDerivable Gamma phi := by
  have h_sem : Gamma ⊨ phi := (context_provable_iff_entails Gamma phi).mp h
  exact (context_provable_iff_entails Gamma phi).mpr h_sem

/-!
## Documentation: Known Limitations

These tests document that completeness depends on an axiom:

`representation_theorem_backward_empty : |= phi -> Inconsistent [neg phi]`

This axiom asserts that if phi is valid (true in all models), then
[neg phi] is inconsistent (derives bottom). This is the contrapositive
of the representation theorem direction that requires canonical model
construction over an infinite set of worlds.

The axiom makes all completeness results `noncomputable`.
-/

/--
Documentation example: completeness is noncomputable.

weak_completeness returns ContextDerivable which wraps Nonempty DerivationTree.
Since we cannot construct the derivation tree computably from validity,
the result is noncomputable.
-/
noncomputable example (phi : Formula) (h : valid phi) : ContextDerivable [] phi :=
  weak_completeness phi h

end BimodalTest.Metalogic_v2.CompletenessTest
