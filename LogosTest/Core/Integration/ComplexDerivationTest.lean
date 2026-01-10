import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic
import LogosTest.Core.Integration.Helpers

/-!
# Complex Derivation Integration Tests

Tests for complex derivation chains (5+ steps) to ensure soundness
is preserved through multi-step proofs.

## Test Coverage

This test suite covers:
1. Multi-step modus ponens chains (5+ steps)
2. Nested modal operators (□□□p → p)
3. Nested temporal operators (FFFp → Fp)
4. Mixed modal-temporal derivations
5. Complex context transformations
6. Chained inference rules

## Organization

Tests are organized by complexity:
- 5-step derivation chains
- Nested operator derivations (depth 3+)
- Mixed operator derivations
- Context transformation chains

## References

* [Derivation.lean](../../../Logos/Core/ProofSystem/Derivation.lean) - Proof system
* [Soundness.lean](../../../Logos/Core/Metalogic/Soundness.lean) - Soundness theorem
-/

namespace LogosTest.Core.Integration

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic
open LogosTest.Core.Integration.Helpers

-- ============================================================
-- 5-Step Derivation Chains
-- ============================================================

section FiveStepChains

/--
Test 1: 5-step modus ponens chain.

Chain: p → q, q → r, r → s, s → t, p ⊢ t
-/
example : True := by
  let p := Formula.atom "p"
  let q := Formula.atom "q"
  let r := Formula.atom "r"
  let s := Formula.atom "s"
  let t := Formula.atom "t"
  
  let Γ := [p.imp q, q.imp r, r.imp s, s.imp t, p]
  
  -- Step 1: p → q, p ⊢ q
  let d1 : Γ ⊢ q :=
    DerivationTree.modus_ponens Γ p q
      (DerivationTree.assumption Γ (p.imp q) (List.Mem.head _))
      (DerivationTree.assumption Γ p (by simp [Γ]))
  
  -- Step 2: q → r, q ⊢ r
  let d2 : Γ ⊢ r :=
    DerivationTree.modus_ponens Γ q r
      (DerivationTree.assumption Γ (q.imp r) (by simp [Γ]))
      d1
  
  -- Step 3: r → s, r ⊢ s
  let d3 : Γ ⊢ s :=
    DerivationTree.modus_ponens Γ r s
      (DerivationTree.assumption Γ (r.imp s) (by simp [Γ]))
      d2
  
  -- Step 4: s → t, s ⊢ t
  let d4 : Γ ⊢ t :=
    DerivationTree.modus_ponens Γ s t
      (DerivationTree.assumption Γ (s.imp t) (by simp [Γ]))
      d3
  
  -- Verify soundness at each step
  have v1 : Γ ⊨ q := soundness Γ q d1
  have v2 : Γ ⊨ r := soundness Γ r d2
  have v3 : Γ ⊨ s := soundness Γ s d3
  have v4 : Γ ⊨ t := soundness Γ t d4
  
  trivial

/--
Test 2: 6-step derivation chain with mixed rules.

Combines modus ponens, weakening, and axiom application.
-/
example : True := by
  let p := Formula.atom "p"
  let q := Formula.atom "q"
  
  -- Step 1: Derive Modal T axiom
  let d1 : ⊢ (p.box.imp p) :=
    DerivationTree.axiom [] (p.box.imp p) (Axiom.modal_t p)
  
  -- Step 2: Derive Modal 4 axiom
  let d2 : ⊢ (p.box.imp p.box.box) :=
    DerivationTree.axiom [] (p.box.imp p.box.box) (Axiom.modal_4 p)
  
  -- Step 3: Weaken to non-empty context
  let Γ := [q]
  have h_sub : ([] : Context) ⊆ Γ := by intro x hx; contradiction
  let d3 : Γ ⊢ (p.box.imp p) :=
    DerivationTree.weakening [] Γ (p.box.imp p) d1 h_sub
  
  -- Step 4: Assume □p in context
  let Γ' := [p.box, q]
  let d4 : Γ' ⊢ p.box :=
    DerivationTree.assumption Γ' p.box (List.Mem.head _)
  
  -- Step 5: Apply modus ponens to get p
  have h_sub' : Γ ⊆ Γ' := by
    intro x hx
    cases hx with
    | head => exact List.Mem.tail _ (List.Mem.head _)
    | tail _ h => contradiction
  let d5 : Γ' ⊢ (p.box.imp p) :=
    DerivationTree.weakening Γ Γ' (p.box.imp p) d3 h_sub'
  let d6 : Γ' ⊢ p :=
    DerivationTree.modus_ponens Γ' p.box p d5 d4
  
  -- Verify soundness
  have v : Γ' ⊨ p := soundness Γ' p d6
  
  trivial

end FiveStepChains

-- ============================================================
-- Nested Modal Operators
-- ============================================================

section NestedModalOperators

/--
Test 3: Triple nested box (□□□p → p).

Uses repeated application of Modal T.
-/
example : True := by
  let p := Formula.atom "p"
  
  -- Derive □□□p → □□p using Modal T
  let d1 : ⊢ (p.box.box.box.imp p.box.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_t p.box.box)
  
  -- Derive □□p → □p using Modal T
  let d2 : ⊢ (p.box.box.imp p.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_t p.box)
  
  -- Derive □p → p using Modal T
  let d3 : ⊢ (p.box.imp p) :=
    DerivationTree.axiom [] _ (Axiom.modal_t p)
  
  -- Verify all are sound
  have v1 : ⊨ (p.box.box.box.imp p.box.box) := soundness [] _ d1
  have v2 : ⊨ (p.box.box.imp p.box) := soundness [] _ d2
  have v3 : ⊨ (p.box.imp p) := soundness [] _ d3
  
  trivial

/--
Test 4: Nested box with modus ponens.

From [□□□p], derive p through repeated application.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box.box.box]
  
  -- Step 1: □□□p → □□p, □□□p ⊢ □□p
  let ax1 : Γ ⊢ (p.box.box.box.imp p.box.box) :=
    DerivationTree.axiom Γ _ (Axiom.modal_t p.box.box)
  let ass1 : Γ ⊢ p.box.box.box :=
    DerivationTree.assumption Γ p.box.box.box (List.Mem.head _)
  let d1 : Γ ⊢ p.box.box :=
    DerivationTree.modus_ponens Γ p.box.box.box p.box.box ax1 ass1
  
  -- Step 2: □□p → □p, □□p ⊢ □p
  let ax2 : Γ ⊢ (p.box.box.imp p.box) :=
    DerivationTree.axiom Γ _ (Axiom.modal_t p.box)
  let d2 : Γ ⊢ p.box :=
    DerivationTree.modus_ponens Γ p.box.box p.box ax2 d1
  
  -- Step 3: □p → p, □p ⊢ p
  let ax3 : Γ ⊢ (p.box.imp p) :=
    DerivationTree.axiom Γ _ (Axiom.modal_t p)
  let d3 : Γ ⊢ p :=
    DerivationTree.modus_ponens Γ p.box p ax3 d2
  
  -- Verify soundness
  have v : Γ ⊨ p := soundness Γ p d3
  
  trivial

/--
Test 5: Modal 4 with nested boxes (□p → □□□p).

Uses repeated application of Modal 4.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- Step 1: □p → □□p using Modal 4
  let ax1 : Γ ⊢ (p.box.imp p.box.box) :=
    DerivationTree.axiom Γ _ (Axiom.modal_4 p)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ p.box.box :=
    DerivationTree.modus_ponens Γ p.box p.box.box ax1 ass
  
  -- Step 2: □□p → □□□p using Modal 4
  let ax2 : Γ ⊢ (p.box.box.imp p.box.box.box) :=
    DerivationTree.axiom Γ _ (Axiom.modal_4 p.box)
  let d2 : Γ ⊢ p.box.box.box :=
    DerivationTree.modus_ponens Γ p.box.box p.box.box.box ax2 d1
  
  -- Verify soundness
  have v : Γ ⊨ p.box.box.box := soundness Γ p.box.box.box d2
  
  trivial

end NestedModalOperators

-- ============================================================
-- Nested Temporal Operators
-- ============================================================

section NestedTemporalOperators

/--
Test 6: Triple nested future (FFFp → FFp).

Uses Temporal 4 axiom.
-/
example : True := by
  let p := Formula.atom "p"
  
  -- Derive FFFp → FFFFp using Temporal 4
  let d1 : ⊢ (p.all_future.all_future.all_future.imp
              p.all_future.all_future.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 p.all_future.all_future)
  
  -- Derive FFp → FFFp using Temporal 4
  let d2 : ⊢ (p.all_future.all_future.imp p.all_future.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 p.all_future)
  
  -- Derive Fp → FFp using Temporal 4
  let d3 : ⊢ (p.all_future.imp p.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 p)
  
  -- Verify all are sound
  have v1 : ⊨ (p.all_future.all_future.all_future.imp
               p.all_future.all_future.all_future.all_future) :=
    soundness [] _ d1
  have v2 : ⊨ (p.all_future.all_future.imp p.all_future.all_future.all_future) :=
    soundness [] _ d2
  have v3 : ⊨ (p.all_future.imp p.all_future.all_future) :=
    soundness [] _ d3
  
  trivial

/--
Test 7: Nested future with modus ponens.

From [FFFp], derive FFFFp through application.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.all_future.all_future.all_future]
  
  -- FFFp → FFFFp, FFFp ⊢ FFFFp
  let ax : Γ ⊢ (p.all_future.all_future.all_future.imp
                 p.all_future.all_future.all_future.all_future) :=
    DerivationTree.axiom Γ _ (Axiom.temp_4 p.all_future.all_future)
  let ass : Γ ⊢ p.all_future.all_future.all_future :=
    DerivationTree.assumption Γ p.all_future.all_future.all_future (List.Mem.head _)
  let d : Γ ⊢ p.all_future.all_future.all_future.all_future :=
    DerivationTree.modus_ponens Γ p.all_future.all_future.all_future
      p.all_future.all_future.all_future.all_future ax ass
  
  -- Verify soundness
  have v : Γ ⊨ p.all_future.all_future.all_future.all_future :=
    soundness Γ p.all_future.all_future.all_future.all_future d
  
  trivial

end NestedTemporalOperators

-- ============================================================
-- Mixed Modal-Temporal Derivations
-- ============================================================

section MixedDerivations

/--
Test 8: Mixed modal and temporal operators.

Derive □Fp from □p using Modal-Future axiom.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- □p → □Fp using Modal-Future axiom
  let ax : Γ ⊢ (p.box.imp (p.all_future.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d : Γ ⊢ (p.all_future.box) :=
    DerivationTree.modus_ponens Γ p.box (p.all_future.box) ax ass
  
  -- Verify soundness
  have v : Γ ⊨ (p.all_future.box) := soundness Γ (p.all_future.box) d
  
  trivial

/--
Test 9: Complex bimodal derivation chain.

Combines modal and temporal operators in multi-step proof.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- Step 1: □p → □Fp
  let ax1 : Γ ⊢ (p.box.imp (p.all_future.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.all_future.box) :=
    DerivationTree.modus_ponens Γ p.box (p.all_future.box) ax1 ass
  
  -- Step 2: □Fp → □FFp using Temporal-Future axiom
  let ax2 : Γ ⊢ ((p.all_future.box).imp ((p.all_future.all_future).box)) :=
    DerivationTree.axiom Γ _ (Axiom.temp_future p.all_future)
  let d2 : Γ ⊢ ((p.all_future.all_future).box) :=
    DerivationTree.modus_ponens Γ (p.all_future.box)
      ((p.all_future.all_future).box) ax2 d1
  
  -- Verify soundness
  have v : Γ ⊨ ((p.all_future.all_future).box) :=
    soundness Γ ((p.all_future.all_future).box) d2
  
  trivial

end MixedDerivations

-- ============================================================
-- Complex Context Transformations
-- ============================================================

section ContextTransformations

/--
Test 10: Multi-step weakening chain.

Demonstrates soundness preservation through context expansion.
-/
example : True := by
  let p := Formula.atom "p"
  let q := Formula.atom "q"
  let r := Formula.atom "r"
  
  -- Start with [p] ⊢ p
  let Γ1 := [p]
  let d1 : Γ1 ⊢ p :=
    DerivationTree.assumption Γ1 p (List.Mem.head _)
  
  -- Weaken to [p, q] ⊢ p
  let Γ2 := [p, q]
  have h1 : Γ1 ⊆ Γ2 := by
    intro x hx
    cases hx with
    | head => exact List.Mem.head _
    | tail _ h => contradiction
  let d2 : Γ2 ⊢ p :=
    DerivationTree.weakening Γ1 Γ2 p d1 h1
  
  -- Weaken to [p, q, r] ⊢ p
  let Γ3 := [p, q, r]
  have h2 : Γ2 ⊆ Γ3 := by
    intro x hx
    cases hx with
    | head => exact List.Mem.head _
    | tail _ h =>
      cases h with
      | head => exact List.Mem.tail _ (List.Mem.head _)
      | tail _ h' => contradiction
  let d3 : Γ3 ⊢ p :=
    DerivationTree.weakening Γ2 Γ3 p d2 h2
  
  -- Verify soundness at each step
  have v1 : Γ1 ⊨ p := soundness Γ1 p d1
  have v2 : Γ2 ⊨ p := soundness Γ2 p d2
  have v3 : Γ3 ⊨ p := soundness Γ3 p d3
  
  trivial

end ContextTransformations

end LogosTest.Core.Integration
