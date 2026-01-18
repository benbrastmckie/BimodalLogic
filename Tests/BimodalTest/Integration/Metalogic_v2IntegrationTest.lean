import Bimodal.Metalogic_v2.FMP
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.Metalogic_v2.Completeness.StrongCompleteness

/-!
# Metalogic_v2 Integration Tests

End-to-end integration tests that verify the complete metalogic pathway
from syntax through soundness and completeness.

## Test Organization

- **Layer Integration Tests**: Test Core -> Soundness -> Representation -> Completeness flow
- **Soundness-Completeness Pathway Tests**: Test the complete metalogic loop
- **Workflow Tests**: Test typical usage patterns

## Architecture Overview

The Metalogic_v2 follows a layered architecture:

```
                    ┌─────────────────┐
                    │      FMP.lean   │  (central hub)
                    │    (exports)    │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Completeness   │ │  Decidability   │ │   Compactness   │
│  (valid→⊢)      │ │  (finite search)│ │  (fin→∞)        │
└─────────────────┘ └─────────────────┘ └─────────────────┘
         ▲                   ▲                   ▲
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
                    ┌────────┴────────┐
                    │ Representation  │
                    │ (canonical mdl) │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │   Soundness     │
                    │ (⊢→valid)       │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │      Core       │
                    │ (MCS, deduct)   │
                    └─────────────────┘
```

## References

* Metalogic_v2/FMP.lean - Central hub
* Metalogic_v2/Core/ - Foundation layer
* Metalogic_v2/Soundness/ - Soundness theorem
* Metalogic_v2/Representation/ - Canonical model
* Metalogic_v2/Completeness/ - Completeness theorems
-/

namespace BimodalTest.Metalogic_v2.IntegrationTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic_v2
open Bimodal.Metalogic_v2.Core
open Bimodal.Metalogic_v2.Soundness
open Bimodal.Metalogic_v2.Representation
open Bimodal.Metalogic_v2.Completeness

/-!
## Layer Integration: Core -> Soundness

Test the flow from proof system through soundness.
-/

/--
Integration Test: Derive axiom, apply soundness.

1. Derive Modal T axiom from empty context
2. Apply soundness to get semantic validity
-/
example (phi : Formula) : [] ⊨ (phi.box.imp phi) := by
  -- Step 1: Derive axiom
  let deriv : [] ⊢ (phi.box.imp phi) := DerivationTree.axiom [] _ (Axiom.modal_t phi)
  -- Step 2: Apply soundness
  exact soundness [] (phi.box.imp phi) deriv

/--
Integration Test: Derive theorem with modus ponens, apply soundness.

1. Build derivation using modus ponens
2. Apply soundness
-/
example (phi psi : Formula) : [phi.imp psi, phi] ⊨ psi := by
  -- Step 1: Build derivation
  let h_imp : [phi.imp psi, phi] ⊢ (phi.imp psi) :=
    DerivationTree.assumption _ _ (List.Mem.head _)
  let h_phi : [phi.imp psi, phi] ⊢ phi :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  let deriv := DerivationTree.modus_ponens _ _ _ h_imp h_phi
  -- Step 2: Apply soundness
  exact soundness _ _ deriv

/-!
## Layer Integration: Soundness <-> Completeness

Test the bidirectional flow between soundness and completeness.
-/

/--
Integration Test: Soundness -> Completeness round-trip.

1. Start with derivation
2. Apply soundness to get validity
3. Apply completeness to get back derivation
-/
noncomputable example (phi : Formula) (h : [] ⊢ phi) : ContextDerivable [] phi := by
  -- Step 1: We have a derivation h : [] ⊢ phi
  -- Step 2: Apply soundness to get validity
  have h_valid : valid phi := by
    have h_sem := soundness [] phi h
    exact Validity.valid_iff_empty_consequence phi |>.mpr h_sem
  -- Step 3: Apply completeness to get back derivation
  exact weak_completeness phi h_valid

/--
Integration Test: Completeness -> Soundness round-trip.

1. Start with validity
2. Apply completeness to get derivation
3. Apply soundness to verify validity
-/
noncomputable example (phi : Formula) (h : valid phi) : valid phi := by
  -- Step 1: We have validity h : valid phi
  -- Step 2: Apply completeness to get derivation
  have h_deriv : ContextDerivable [] phi := weak_completeness phi h
  -- Step 3: Apply soundness to verify (though we already have h)
  have ⟨d⟩ := h_deriv
  have h_sem := soundness [] phi d
  exact Validity.valid_iff_empty_consequence phi |>.mpr h_sem

/-!
## Layer Integration: Core -> Representation

Test the flow from consistency through canonical model.
-/

/--
Integration Test: Consistent context -> Canonical satisfiability.

1. Have a consistent context
2. Apply representation theorem
3. Get satisfaction in canonical model
-/
noncomputable example (Gamma : Context) (h : Consistent Gamma) :
    ∃ w : CanonicalWorldState, ∀ phi ∈ Gamma, canonicalTruthAt w phi :=
  representation_theorem h

/--
Integration Test: Consistent singleton -> Formula satisfiable.

1. Assume [phi] is consistent
2. Apply representation theorem
3. Get world where phi is true
-/
noncomputable example (phi : Formula) (h : Consistent [phi]) :
    ∃ w : CanonicalWorldState, canonicalTruthAt w phi := by
  obtain ⟨w, hw⟩ := representation_theorem h
  exact ⟨w, hw phi (List.Mem.head _)⟩

/-!
## Full Metalogic Workflow Tests

Test complete workflows through all layers.
-/

/--
Integration Test: Complete workflow - derive theorem and verify.

Workflow:
1. Construct derivation of Modal T axiom
2. Apply soundness to get semantic validity
3. Apply completeness to get back provability
4. Verify equivalence holds
-/
noncomputable example (phi : Formula) : True := by
  -- Step 1: Derive Modal T
  let deriv : [] ⊢ (phi.box.imp phi) := DerivationTree.axiom [] _ (Axiom.modal_t phi)

  -- Step 2: Soundness
  have h_sem : [] ⊨ (phi.box.imp phi) := soundness [] _ deriv
  have h_valid : valid (phi.box.imp phi) :=
    Validity.valid_iff_empty_consequence _ |>.mpr h_sem

  -- Step 3: Completeness
  have h_back : ContextDerivable [] (phi.box.imp phi) :=
    weak_completeness _ h_valid

  -- Step 4: Verify equivalence
  have h_equiv : ContextDerivable [] (phi.box.imp phi) ↔ valid (phi.box.imp phi) :=
    provable_iff_valid _

  trivial

/--
Integration Test: Context-level workflow.

Workflow:
1. Build semantic consequence [phi -> psi, phi] |= psi directly
2. Apply strong completeness to get derivation
3. Apply soundness to verify
-/
noncomputable example (phi psi : Formula) : True := by
  -- Step 1: Build semantic consequence directly
  have h_sem : [phi.imp psi, phi] ⊨ psi := by
    intro T _ _ _ F M tau t h_all
    have h_imp := h_all (phi.imp psi) (List.Mem.head _)
    have h_phi := h_all phi (List.Mem.tail _ (List.Mem.head _))
    unfold truth_at at h_imp
    exact h_imp h_phi

  -- Step 2: Strong completeness
  have h_deriv : ContextDerivable [phi.imp psi, phi] psi :=
    strong_completeness _ _ h_sem

  -- Step 3: Soundness verification
  have h_back : [phi.imp psi, phi] ⊨ psi := by
    obtain ⟨d⟩ := h_deriv
    exact soundness _ _ d

  trivial

/-!
## FMP Hub Export Verification

Verify that FMP.lean correctly re-exports all needed definitions.
-/

/--
Integration Test: FMP re-exports Core definitions.
-/
example (Gamma : Context) : Prop := Consistent Gamma
example (S : Set Formula) : Prop := SetConsistent S
example (S : Set Formula) : Prop := SetMaximalConsistent S

/--
Integration Test: FMP re-exports Soundness definitions.
-/
example (Gamma : Context) (phi : Formula) (h : Gamma ⊢ phi) : Gamma ⊨ phi :=
  soundness Gamma phi h

/--
Integration Test: FMP re-exports Representation definitions.
-/
example : Type := CanonicalWorldState
example : CanonicalModel := canonicalModel
example (w : CanonicalWorldState) (phi : Formula) : Prop := canonicalTruthAt w phi

/--
Integration Test: FMP convenience theorem - empty_soundness.
-/
example (phi : Formula) (h : ContextDerivable [] phi) : valid phi :=
  empty_soundness h

/--
Integration Test: FMP convenience theorem - consistency_satisfiability_bridge.
-/
noncomputable example (phi : Formula) (h : Consistent [phi]) :
    canonicalContextSatisfiable [phi] :=
  consistency_satisfiability_bridge h

/-!
## Edge Case Integration Tests

Test edge cases and boundary conditions.
-/

/--
Integration Test: Empty context handling.

The empty context is trivially consistent (no formulas to contradict).
-/
example : ∀ L : List Formula, (∀ phi ∈ L, phi ∈ (∅ : Set Formula)) → L = [] := by
  intro L hL
  cases L with
  | nil => rfl
  | cons phi _ =>
    exfalso
    have := hL phi (List.Mem.head _)
    exact this

/--
Integration Test: Singleton context completeness.

[phi] |= phi should give [phi] |- phi.
-/
noncomputable example (phi : Formula) : ContextDerivable [phi] phi := by
  apply strong_completeness
  intro T _ _ _ F M tau t h_all
  exact h_all phi (List.Mem.head _)

/--
Integration Test: Axiom is both derivable and valid.

Any axiom instance is both syntactically derivable and semantically valid.
-/
example (phi : Formula) : ContextDerivable [] (phi.box.imp phi) ∧ valid (phi.box.imp phi) := by
  constructor
  · exact ⟨DerivationTree.axiom [] _ (Axiom.modal_t phi)⟩
  · exact modal_t_valid phi

end BimodalTest.Metalogic_v2.IntegrationTest
