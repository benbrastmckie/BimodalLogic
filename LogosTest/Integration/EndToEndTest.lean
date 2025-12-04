import Logos

/-!
# End-to-End Integration Tests

These tests verify the complete workflow from derivation to validity.
-/

namespace LogosTest.Integration

open Logos.Syntax
open Logos.ProofSystem
open Logos.Semantics
open Logos.Metalogic

/--
Integration Test 1: Derive Modal T theorem.

We derive `□p → p` using the Modal T axiom.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
  Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "p"))

/--
Integration Test 2: Apply soundness to get validity.

From the derivation of Modal T, we obtain its semantic validity.
-/
example : [] ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  let deriv := Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  exact soundness [] _ deriv

/--
Integration Test 3: Verify validity directly.

We can also prove Modal T validity directly from semantics.
-/
example : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
  modal_t_valid (Formula.atom "p")

/--
Integration Test 4: End-to-end workflow verification.

This test demonstrates the complete metalogical pathway:
1. Derive a theorem syntactically
2. Apply soundness to get semantic validity
3. Verify the validity matches direct semantic proof
-/
example : True := by
  -- Step 1: Syntactic derivation
  let proof : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "p"))

  -- Step 2: Apply soundness
  let valid_from_soundness : [] ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    soundness [] _ proof

  -- Step 3: Direct semantic validity
  let valid_direct : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    modal_t_valid (Formula.atom "p")

  -- Both paths give the same result (validity)
  trivial

/--
Integration Test 5: Modus ponens with soundness.

Verify that modus ponens derivations are sound.
-/
example (p q : Formula) : [p.imp q, p] ⊨ q := by
  let deriv : [p.imp q, p] ⊢ q :=
    Derivable.modus_ponens [p.imp q, p] p q
      (Derivable.assumption [p.imp q, p] (p.imp q) (List.Mem.head _))
      (Derivable.assumption [p.imp q, p] p (List.Mem.tail _ (List.Mem.head _)))
  exact soundness [p.imp q, p] q deriv

/--
Integration Test 6: Weakening with soundness.

Verify that weakening preserves soundness.
-/
example (p q : Formula) : [p, q] ⊨ p := by
  let deriv : [p] ⊢ p := Derivable.assumption [p] p (List.Mem.head _)
  have h_sub : [p] ⊆ [p, q] := by
    intro x hx
    cases hx with
    | head => exact List.Mem.head _
    | tail _ _ => contradiction
  let deriv' : [p, q] ⊢ p := Derivable.weakening [p] [p, q] p deriv h_sub
  exact soundness [p, q] p deriv'

end LogosTest.Integration
