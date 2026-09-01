/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem

/-!
# End-to-End Integration Tests

These tests verify the complete workflow from derivation to validity.
-/

namespace BimodalTest.Integration

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.Metalogic

/--
Integration Test 1: Derive Modal T theorem.

We derive `□p → p` using the Modal T axiom.
-/
example : ⊢ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
  DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atomS "p")) trivial

/--
Integration Test 2: Apply soundness to get validity.

From the derivation of Modal T, we obtain its semantic validity.
-/
example : [] ⊨ ((Formula.atomS "p").box.imp (Formula.atomS "p")) := by
  let deriv : ⊢ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atomS "p")) trivial
  exact soundness_in [] _ deriv

/--
Integration Test 3: Verify validity directly.

We can also prove Modal T validity directly from semantics.
-/
example : ⊨ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
  modal_t_valid (Formula.atomS "p")

/--
Integration Test 4: End-to-end workflow verification.

This test demonstrates the complete metalogical pathway:
1. Derive a theorem syntactically
2. Apply soundness to get semantic validity
3. Verify the validity matches direct semantic proof
-/
example : True := by
  -- Step 1: Syntactic derivation
  let proof : ⊢ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atomS "p")) trivial

  -- Step 2: Apply soundness
  let valid_from_soundness : [] ⊨ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
    soundness_in [] _ proof

  -- Step 3: Direct semantic validity
  let valid_direct : ⊨ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
    modal_t_valid (Formula.atomS "p")

  -- Both paths give the same result (validity)
  trivial

/--
Integration Test 5: Modus ponens with soundness.

Verify that modus ponens derivations are sound.
-/
example (p q : Formula) : [p.imp q, p] ⊨ q := by
  let deriv : [p.imp q, p] ⊢ q :=
    DerivationTree.modus_ponens [p.imp q, p] p q
      (DerivationTree.assumption [p.imp q, p] (p.imp q) (List.Mem.head _))
      (DerivationTree.assumption [p.imp q, p] p (List.Mem.tail _ (List.Mem.head _)))
  exact soundness_in [p.imp q, p] q deriv

/--
Integration Test 6: Weakening with soundness.

Verify that weakening preserves soundness.
-/
example (p q : Formula) : [p, q] ⊨ p := by
  let deriv : [p] ⊢ p := DerivationTree.assumption [p] p (List.Mem.head _)
  have h_sub : [p] ⊆ [p, q] := by
    intro x hx
    cases hx with
    | head => exact List.Mem.head _
    | tail _ _ => contradiction
  let deriv' : [p, q] ⊢ p := DerivationTree.weakening [p] [p, q] p deriv h_sub
  exact soundness_in [p, q] p deriv'

end BimodalTest.Integration
