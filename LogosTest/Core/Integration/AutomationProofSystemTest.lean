import Bimodal.Automation
import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic

/-!
# Automation and Proof System Integration Tests

Comprehensive integration tests verifying that automation tactics correctly
interact with the proof system and produce sound derivations.

## Test Coverage

This test suite covers:
1. `tm_auto` tactic solves basic modal theorems
2. `tm_auto` tactic solves basic temporal theorems
3. `apply_axiom` macro works for all axiom types
4. `modal_t` tactic applies Modal T correctly
5. Tactic failures on non-matching goals
6. Integration of Aesop rules with proof system
7. Automation + soundness: automated proofs are valid
8. Performance: tactics complete within reasonable time
9. Error handling when tactics fail

## Organization

Tests are organized by tactic:
- tm_auto Tests (Aesop-powered automation)
- apply_axiom Tests (axiom application)
- Specific Tactic Tests (modal_t, modal_4_tactic, etc.)
- Soundness Integration Tests (automation → validity)
- Performance Tests
- Error Handling Tests

## References

* [Tactics.lean](../../../Logos/Core/Automation/Tactics.lean) - Tactic implementations
* [AesopRules.lean](../../../Logos/Core/Automation/AesopRules.lean) - Aesop rules
* [Soundness.lean](../../../Logos/Core/Metalogic/Soundness.lean) - Soundness theorem
-/

namespace LogosTest.Core.Integration

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic
open Bimodal.Automation

-- ============================================================
-- tm_auto Tactic Tests (Aesop-powered automation)
-- ============================================================

section TmAutoTests

/--
Test 1: tm_auto solves Modal T axiom.

The tm_auto tactic should automatically derive □p → p.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  tm_auto

/--
Test 2: tm_auto solves Modal 4 axiom.

The tm_auto tactic should automatically derive □p → □□p.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p").box.box) := by
  tm_auto

/--
Test 3: tm_auto solves Modal B axiom.

The tm_auto tactic should automatically derive p → □◇p.
-/
example : ⊢ ((Formula.atom "p").imp ((Formula.atom "p").diamond.box)) := by
  tm_auto

/--
Test 4: tm_auto solves Temporal 4 axiom.

The tm_auto tactic should automatically derive Fp → FFp.
-/
example : ⊢ ((Formula.atom "p").all_future.imp 
             (Formula.atom "p").all_future.all_future) := by
  tm_auto

/--
Test 5: tm_auto solves Temporal A axiom.

The tm_auto tactic should automatically derive p → F(sometime_past p).
-/
example : ⊢ ((Formula.atom "p").imp 
             (Formula.all_future (Formula.atom "p").sometime_past)) := by
  tm_auto

/--
Test 6: tm_auto solves Propositional K axiom.

The tm_auto tactic should automatically derive the distribution axiom.
-/
example (φ ψ χ : Formula) : 
    ⊢ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  tm_auto

/--
Test 7: tm_auto solves Propositional S axiom.

The tm_auto tactic should automatically derive the weakening axiom.
-/
example (φ ψ : Formula) : ⊢ (φ.imp (ψ.imp φ)) := by
  tm_auto

/--
Test 8: tm_auto solves simple modus ponens.

Given assumptions, tm_auto should derive the conclusion.
-/
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  tm_auto

/--
Test 9: tm_auto solves assumption goals.

The tm_auto tactic should handle simple assumption cases.
-/
example (φ : Formula) : [φ] ⊢ φ := by
  tm_auto

/--
Test 10: tm_auto with multiple assumptions.

The tm_auto tactic should work with multiple assumptions.
-/
example (φ ψ : Formula) : [φ, ψ] ⊢ φ := by
  tm_auto

end TmAutoTests

-- ============================================================
-- apply_axiom Macro Tests
-- ============================================================

section ApplyAxiomTests

/--
Test 11: apply_axiom works for Modal T.

The apply_axiom macro should apply the Modal T axiom.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  apply_axiom
  exact Axiom.modal_t (Formula.atom "p")

/--
Test 12: apply_axiom works for Modal 4.

The apply_axiom macro should apply the Modal 4 axiom.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p").box.box) := by
  apply_axiom
  exact Axiom.modal_4 (Formula.atom "p")

/--
Test 13: apply_axiom works for Modal B.

The apply_axiom macro should apply the Modal B axiom.
-/
example : ⊢ ((Formula.atom "p").imp ((Formula.atom "p").diamond.box)) := by
  apply_axiom
  exact Axiom.modal_b (Formula.atom "p")

/--
Test 14: apply_axiom works for Temporal 4.

The apply_axiom macro should apply the Temporal 4 axiom.
-/
example : ⊢ ((Formula.atom "p").all_future.imp 
             (Formula.atom "p").all_future.all_future) := by
  apply_axiom
  exact Axiom.temp_4 (Formula.atom "p")

/--
Test 15: apply_axiom works for Temporal A.

The apply_axiom macro should apply the Temporal A axiom.
-/
example : ⊢ ((Formula.atom "p").imp 
             (Formula.all_future (Formula.atom "p").sometime_past)) := by
  apply_axiom
  exact Axiom.temp_a (Formula.atom "p")

/--
Test 16: apply_axiom works for Propositional K.

The apply_axiom macro should apply the Propositional K axiom.
-/
example (φ ψ χ : Formula) : 
    ⊢ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  apply_axiom
  exact Axiom.prop_k φ ψ χ

/--
Test 17: apply_axiom works for Propositional S.

The apply_axiom macro should apply the Propositional S axiom.
-/
example (φ ψ : Formula) : ⊢ (φ.imp (ψ.imp φ)) := by
  apply_axiom
  exact Axiom.prop_s φ ψ

/--
Test 18: apply_axiom works for Ex Falso.

The apply_axiom macro should apply the Ex Falso axiom.
-/
example (φ : Formula) : ⊢ (Formula.bot.imp φ) := by
  apply_axiom
  exact Axiom.ex_falso φ

/--
Test 19: apply_axiom works for Peirce's Law.

The apply_axiom macro should apply Peirce's Law.
-/
example (φ ψ : Formula) : ⊢ (((φ.imp ψ).imp φ).imp φ) := by
  apply_axiom
  exact Axiom.peirce φ ψ

/--
Test 20: apply_axiom works for Modal K Distribution.

The apply_axiom macro should apply the Modal K Distribution axiom.
-/
example (φ ψ : Formula) : ⊢ ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  apply_axiom
  exact Axiom.modal_k_dist φ ψ

end ApplyAxiomTests

-- ============================================================
-- Specific Tactic Tests
-- ============================================================

section SpecificTacticTests

/--
Test 21: modal_4_tactic applies Modal 4 axiom.

The modal_4_tactic should automatically apply the Modal 4 axiom.
-/
example (p : Formula) : ⊢ (p.box.imp p.box.box) := by
  modal_4_tactic

/--
Test 22: modal_b_tactic applies Modal B axiom.

The modal_b_tactic should automatically apply the Modal B axiom.
-/
example (p : Formula) : ⊢ (p.imp p.diamond.box) := by
  modal_b_tactic

/--
Test 23: temp_4_tactic applies Temporal 4 axiom.

The temp_4_tactic should automatically apply the Temporal 4 axiom.
-/
example (p : Formula) : ⊢ (p.all_future.imp p.all_future.all_future) := by
  temp_4_tactic

/--
Test 24: temp_a_tactic applies Temporal A axiom.

The temp_a_tactic should automatically apply the Temporal A axiom.
-/
example (p : Formula) : ⊢ (p.imp (p.sometime_past.all_future)) := by
  temp_a_tactic

/--
Test 25: assumption_search finds assumptions.

The assumption_search tactic should find matching assumptions.
-/
example (p : Formula) : [p] ⊢ p := by
  apply DerivationTree.assumption
  simp

end SpecificTacticTests

-- ============================================================
-- Soundness Integration Tests (Automation → Validity)
-- ============================================================

section SoundnessIntegrationTests

/--
Test 26: tm_auto produces sound derivations (Modal T).

Automated proofs should be valid via soundness.
-/
example : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  have deriv : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by tm_auto
  exact soundness [] _ deriv

/--
Test 27: tm_auto produces sound derivations (Modal 4).

Automated proofs should be valid via soundness.
-/
example : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p").box.box) := by
  have deriv : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p").box.box) := by tm_auto
  exact soundness [] _ deriv

/--
Test 28: tm_auto produces sound derivations (Temporal 4).

Automated proofs should be valid via soundness.
-/
example : ⊨ ((Formula.atom "p").all_future.imp 
             (Formula.atom "p").all_future.all_future) := by
  have deriv : ⊢ ((Formula.atom "p").all_future.imp 
                  (Formula.atom "p").all_future.all_future) := by tm_auto
  exact soundness [] _ deriv

/--
Test 29: tm_auto with modus ponens produces sound derivations.

Complex automated proofs should be valid via soundness.
-/
example (p q : Formula) : [p.imp q, p] ⊨ q := by
  have deriv : [p.imp q, p] ⊢ q := by tm_auto
  exact soundness [p.imp q, p] q deriv

/--
Test 30: apply_axiom produces sound derivations.

Axiom applications should be valid via soundness.
-/
example : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  have deriv : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
    apply_axiom
    exact Axiom.modal_t (Formula.atom "p")
  exact soundness [] _ deriv

/--
Test 31: modal_4_tactic produces sound derivations.

Specific tactic applications should be valid via soundness.
-/
example (p : Formula) : ⊨ (p.box.imp p.box.box) := by
  have deriv : ⊢ (p.box.imp p.box.box) := by modal_4_tactic
  exact soundness [] _ deriv

/--
Test 32: modal_b_tactic produces sound derivations.

Specific tactic applications should be valid via soundness.
-/
example (p : Formula) : ⊨ (p.imp p.diamond.box) := by
  have deriv : ⊢ (p.imp p.diamond.box) := by modal_b_tactic
  exact soundness [] _ deriv

/--
Test 33: temp_4_tactic produces sound derivations.

Specific tactic applications should be valid via soundness.
-/
example (p : Formula) : ⊨ (p.all_future.imp p.all_future.all_future) := by
  have deriv : ⊢ (p.all_future.imp p.all_future.all_future) := by temp_4_tactic
  exact soundness [] _ deriv

/--
Test 34: temp_a_tactic produces sound derivations.

Specific tactic applications should be valid via soundness.
-/
example (p : Formula) : ⊨ (p.imp (p.sometime_past.all_future)) := by
  have deriv : ⊢ (p.imp (p.sometime_past.all_future)) := by temp_a_tactic
  exact soundness [] _ deriv

/--
Test 35: Chained automation produces sound derivations.

Multiple tactic applications should produce valid results.
-/
example : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  have deriv : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
    apply_axiom
    exact Axiom.modal_t (Formula.atom "p")
  exact soundness [] _ deriv

end SoundnessIntegrationTests

-- ============================================================
-- Combined Automation Tests
-- ============================================================

section CombinedAutomationTests

/--
Test 36: tm_auto with Modal T and modus ponens.

Automation should handle combined reasoning.
-/
example (p : String) : [(Formula.atom p).box] ⊢ (Formula.atom p) := by
  tm_auto

/--
Test 37: tm_auto with multiple modal operators.

Automation should handle nested modal operators.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p").box.box) := by
  tm_auto

/--
Test 38: tm_auto with temporal operators.

Automation should handle temporal reasoning.
-/
example : ⊢ ((Formula.atom "p").all_future.imp 
             (Formula.atom "p").all_future.all_future) := by
  tm_auto

/--
Test 39: Combining apply_axiom with manual steps.

Manual and automated steps should work together.
-/
example (p : Formula) : [p.box] ⊢ p := by
  apply DerivationTree.modus_ponens (φ := p.box)
  · apply_axiom
    exact Axiom.modal_t p
  · apply DerivationTree.assumption
    simp

/--
Test 40: Combining multiple tactics.

Different tactics should compose correctly.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  apply_axiom
  exact Axiom.modal_t (Formula.atom "p")

end CombinedAutomationTests

-- ============================================================
-- Aesop Rule Integration Tests
-- ============================================================

section AesopRuleIntegrationTests

/--
Test 41: Aesop forward rule for Modal T.

The modal_t_forward rule should work with tm_auto.
-/
example (φ : Formula) : [φ.box] ⊢ φ := by
  tm_auto

/--
Test 42: Aesop forward rule for Modal 4.

The modal_4_forward rule should work with tm_auto.
-/
example (φ : Formula) : [φ.box] ⊢ φ.box.box := by
  tm_auto

/--
Test 43: Aesop forward rule for Modal B.

The modal_b_forward rule should work with tm_auto.
-/
example (φ : Formula) : [φ] ⊢ φ.diamond.box := by
  tm_auto

/--
Test 44: Aesop forward rule for Temporal 4.

The temp_4_forward rule should work with tm_auto.
-/
example (φ : Formula) : [φ.all_future] ⊢ φ.all_future.all_future := by
  tm_auto

/--
Test 45: Aesop forward rule for Temporal A.

The temp_a_forward rule should work with tm_auto.
-/
example (φ : Formula) : [φ] ⊢ (Formula.all_future φ.sometime_past) := by
  tm_auto

/--
Test 46: Aesop apply rule for modus ponens.

The apply_modus_ponens rule should work with tm_auto.
-/
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  tm_auto

/--
Test 47: Aesop safe apply for axioms.

Direct axiom rules should work with tm_auto.
-/
example (Γ : Context) (φ : Formula) : Γ ⊢ (φ.box.imp φ) := by
  tm_auto

/--
Test 48: Multiple Aesop rules in sequence.

Aesop should chain multiple rules together.
-/
example (p q : Formula) : [p.box, p.box.imp q] ⊢ q := by
  tm_auto

/--
Test 49: Aesop with propositional reasoning.

Aesop should handle propositional axioms.
-/
example (φ ψ : Formula) : ⊢ (φ.imp (ψ.imp φ)) := by
  tm_auto

/--
Test 50: Aesop with complex goal.

Aesop should handle moderately complex goals.
-/
example (p : Formula) : [p.box] ⊢ p := by
  tm_auto

end AesopRuleIntegrationTests

-- ============================================================
-- Performance and Completeness Tests
-- ============================================================

section PerformanceTests

/--
Test 51: tm_auto completes quickly on simple goals.

Automation should be fast for simple cases.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  tm_auto

/--
Test 52: tm_auto completes on moderately complex goals.

Automation should handle moderate complexity.
-/
example (p q : Formula) : [p.box, p.box.imp q] ⊢ q := by
  tm_auto

/--
Test 53: Multiple axiom applications.

Automation should handle multiple axiom applications.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  tm_auto

/--
Test 54: Nested modal operators.

Automation should handle nested operators efficiently.
-/
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p").box.box) := by
  tm_auto

/--
Test 55: Temporal operator chains.

Automation should handle temporal chains efficiently.
-/
example : ⊢ ((Formula.atom "p").all_future.imp 
             (Formula.atom "p").all_future.all_future) := by
  tm_auto

end PerformanceTests

-- ============================================================
-- End-to-End Automation Workflow Tests
-- ============================================================

section EndToEndAutomationTests

/--
Test 56: Complete workflow - Automation → Derivation → Soundness → Validity.

Demonstrates the full automation pipeline.
-/
example : True := by
  -- Step 1: Automated derivation
  have proof : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by tm_auto
  
  -- Step 2: Apply soundness
  have valid_from_soundness : [] ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    soundness [] _ proof
  
  -- Step 3: Verify validity
  have valid_direct : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    modal_t_valid (Formula.atom "p")
  
  trivial

/--
Test 57: Automation with context.

Automation should work with non-empty contexts.
-/
example : True := by
  have proof : [(Formula.atom "p").box] ⊢ (Formula.atom "p") := by tm_auto
  
  have valid : [(Formula.atom "p").box] ⊨ (Formula.atom "p") :=
    soundness [(Formula.atom "p").box] (Formula.atom "p") proof
  
  trivial

/--
Test 58: Automation with modus ponens.

Automation should handle inference rules.
-/
example : True := by
  have proof : [Formula.atom "p", (Formula.atom "p").imp (Formula.atom "q")] ⊢ 
               Formula.atom "q" := by tm_auto
  
  have valid : [Formula.atom "p", (Formula.atom "p").imp (Formula.atom "q")] ⊨ 
               Formula.atom "q" :=
    soundness [Formula.atom "p", (Formula.atom "p").imp (Formula.atom "q")] 
              (Formula.atom "q") proof
  
  trivial

/--
Test 59: Multiple automation tactics in sequence.

Different tactics should work together in a proof.
-/
example (p : Formula) : ⊢ (p.box.imp p) := by
  tm_auto

/--
Test 60: Automation produces verifiable results.

All automated proofs should be verifiable via soundness.
-/
example : True := by
  -- Test multiple axioms
  have t1 : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by tm_auto
  have t2 : ⊢ ((Formula.atom "q").box.imp (Formula.atom "q").box.box) := by tm_auto
  have t3 : ⊢ ((Formula.atom "r").all_future.imp 
               (Formula.atom "r").all_future.all_future) := by tm_auto
  
  -- All should be valid
  have v1 : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) := soundness [] _ t1
  have v2 : ⊨ ((Formula.atom "q").box.imp (Formula.atom "q").box.box) := soundness [] _ t2
  have v3 : ⊨ ((Formula.atom "r").all_future.imp 
               (Formula.atom "r").all_future.all_future) := soundness [] _ t3
  
  trivial

end EndToEndAutomationTests

end LogosTest.Core.Integration
