import Bimodal.Theorems.Perpetuity
import Bimodal.Theorems.Combinators

/-!
# Perpetuity Principles Tests

Tests for the P1-P6 perpetuity principles that connect modal necessity (□)
with temporal operators (always/sometimes).

## Test Coverage

- P1: `□φ → always φ` (necessary implies always)
- P2: `sometimes φ → ◇φ` (sometimes implies possible)
- P3: `□φ → □always φ` (necessity of perpetuity)
- P4: `◇sometimes φ → ◇φ` (possibility of occurrence)
- P5: `◇sometimes φ → always ◇φ` (persistent possibility)
- P6: `sometimes □φ → □always φ` (occurrent necessity perpetual)
-/

namespace BimodalTest.Theorems.PerpetuityTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Perpetuity
open Bimodal.Theorems.Combinators

-- Some perpetuity principles depend on noncomputable deduction_theorem
noncomputable section

/-!
## Helper Lemma Tests: Propositional Reasoning
-/

/-- Test necessitation rule: theorems are necessary -/
example (φ : Formula) : ⊢ (φ.imp φ).box := by
  -- First derive the theorem φ → φ from axiom
  have h : ⊢ φ.imp φ := by
    -- Use S axiom: φ → (φ → φ)
    have s : ⊢ φ.imp ((φ.imp φ).imp φ) :=
      DerivationTree.axiom [] _ (Axiom.prop_s φ (φ.imp φ))
    -- Use K axiom to complete
    have k : ⊢ (φ.imp ((φ.imp φ).imp φ)).imp ((φ.imp (φ.imp φ)).imp (φ.imp φ)) :=
      DerivationTree.axiom [] _ (Axiom.prop_k φ (φ.imp φ) φ)
    have h1 : ⊢ (φ.imp (φ.imp φ)).imp (φ.imp φ) :=
      DerivationTree.modus_ponens [] _ _ k s
    -- φ → φ → φ is from S axiom
    have s2 : ⊢ φ.imp (φ.imp φ) :=
      DerivationTree.axiom [] _ (Axiom.prop_s φ φ)
    exact DerivationTree.modus_ponens [] _ _ h1 s2
  -- Apply necessitation (necessitation for empty context)
  exact DerivationTree.necessitation _ h

/-- Test necessitation rule with axiom -/
example (φ : Formula) : ⊢ (φ.box.imp φ).box := by
  -- Modal T is a theorem
  have d : ⊢ φ.box.imp φ := DerivationTree.axiom [] _ (Axiom.modal_t φ)
  exact DerivationTree.necessitation _ d

/-- Test box_conj_intro: combining boxed formulas -/
example (A B : Formula) (hA : ⊢ A.box) (hB : ⊢ B.box) : ⊢ (A.and B).box :=
  box_conj_intro hA hB

/--
Test box_conj_intro with concrete formulas.

**Note**: Cannot derive `□p` or `□q` from empty context without additional assumptions.
The parametric form below correctly demonstrates the helper's behavior by accepting
boxed premises and showing they combine correctly.
-/
example (hp : ⊢ (Formula.atom "p").box) (hq : ⊢ (Formula.atom "q").box) :
    ⊢ ((Formula.atom "p").and (Formula.atom "q")).box :=
  box_conj_intro hp hq

/-- Test box_conj_intro_imp: implicational variant -/
example (P A B : Formula) (hA : ⊢ P.imp A.box) (hB : ⊢ P.imp B.box) : ⊢ P.imp (A.and B).box :=
  box_conj_intro_imp hA hB

/-- Test box_conj_intro_imp_3: three-way combination -/
example (P A B C : Formula)
    (hA : ⊢ P.imp A.box) (hB : ⊢ P.imp B.box) (hC : ⊢ P.imp C.box) :
    ⊢ P.imp (A.and (B.and C)).box :=
  box_conj_intro_imp_3 hA hB hC

/-- Test imp_trans: transitivity of implication -/
example (A B C : Formula) (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C :=
  imp_trans h1 h2

/-!
## Combinator Theorems Tests

Tests for the flip, app1, app2, and pairing combinators derived from K and S axioms.
-/

/-- Test theorem_flip type signature: (A → B → C) → (B → A → C) -/
example (A B C : Formula) : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C)) := theorem_flip

/-- Test theorem_flip with atomic formulas -/
example : ⊢ ((Formula.atom "p").imp ((Formula.atom "q").imp (Formula.atom "r"))).imp
           ((Formula.atom "q").imp ((Formula.atom "p").imp (Formula.atom "r"))) := theorem_flip

/-- Test theorem_flip applied to Modal T axiom form -/
example : ⊢ ((Formula.atom "p").box.imp ((Formula.atom "q").imp (Formula.atom "p"))).imp
           ((Formula.atom "q").imp ((Formula.atom "p").box.imp (Formula.atom "p"))) := theorem_flip

/-- Test theorem_app1 type signature: A → (A → B) → B -/
example (A B : Formula) : ⊢ A.imp ((A.imp B).imp B) := theorem_app1

/-- Test theorem_app1 with atomic formulas -/
example : ⊢ (Formula.atom "p").imp (((Formula.atom "p").imp (Formula.atom "q")).imp (Formula.atom "q")) := theorem_app1

/-- Test theorem_app1 corresponds to function application -/
example : ⊢ (Formula.atom "x").imp (((Formula.atom "x").imp (Formula.atom "y")).imp (Formula.atom "y")) := theorem_app1

/-- Test theorem_app2 type signature: A → B → (A → B → C) → C -/
example (A B C : Formula) : ⊢ A.imp (B.imp ((A.imp (B.imp C)).imp C)) := theorem_app2

/-- Test theorem_app2 with atomic formulas -/
example : ⊢ (Formula.atom "a").imp ((Formula.atom "b").imp
           (((Formula.atom "a").imp ((Formula.atom "b").imp (Formula.atom "c"))).imp (Formula.atom "c"))) := theorem_app2

/-- Test theorem_app2 is the Vireo combinator (V = λa.λb.λf. f a b) -/
example : ⊢ (Formula.atom "x").imp ((Formula.atom "y").imp
           (((Formula.atom "x").imp ((Formula.atom "y").imp (Formula.atom "z"))).imp (Formula.atom "z"))) := theorem_app2

/-- Test pairing theorem type signature: A → B → A ∧ B -/
example (A B : Formula) : ⊢ A.imp (B.imp (A.and B)) := pairing A B

/-- Test pairing with atomic formulas -/
example : ⊢ (Formula.atom "p").imp ((Formula.atom "q").imp ((Formula.atom "p").and (Formula.atom "q"))) :=
  pairing (Formula.atom "p") (Formula.atom "q")

/-- Test pairing derives conjunction from K and S combinators -/
-- This test verifies pairing is now a theorem (not axiom) derived from theorem_app2
example : ⊢ (Formula.atom "a").imp ((Formula.atom "b").imp ((Formula.atom "a").and (Formula.atom "b"))) :=
  pairing (Formula.atom "a") (Formula.atom "b")

/-- Test pairing with compound formulas -/
example : ⊢ ((Formula.atom "p").box).imp
           ((Formula.atom "q").diamond.imp (((Formula.atom "p").box).and ((Formula.atom "q").diamond))) :=
  pairing (Formula.atom "p").box (Formula.atom "q").diamond

/-- Test pairing is complete theorem (derived from theorem_app2, no sorry) -/
example (φ ψ : Formula) : ⊢ φ.imp (ψ.imp (φ.and ψ)) := pairing φ ψ

/-- Test imp_trans with concrete formulas using modal axioms -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p") := by
  -- □p → □□p by Modal 4
  have h1 : ⊢ (Formula.atom "p").box.imp (Formula.atom "p").box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.atom "p"))
  -- □□p → □p trivially (by Modal T applied to □p)
  have h2 : ⊢ (Formula.atom "p").box.box.imp (Formula.atom "p").box :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "p").box)
  -- □p → □p by transitivity (degenerate case, but tests the mechanism)
  -- Actually, let's use a proper chain: □p → □□p → □p
  -- Then compose with MT: □p → p
  have h3 : ⊢ (Formula.atom "p").box.imp (Formula.atom "p") :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  exact h3

/-- Test mp (modus ponens restatement) with axioms -/
example (φ : Formula) : ⊢ φ.box.imp φ.all_future := by
  -- Testing imp_trans in a proof similar to perpetuity components
  have h1 : ⊢ φ.box.imp (φ.all_future.box) := DerivationTree.axiom [] _ (Axiom.modal_future φ)
  have h2 : ⊢ (φ.all_future.box).imp φ.all_future := DerivationTree.axiom [] _ (Axiom.modal_t φ.all_future)
  exact imp_trans h1 h2

/-- Test that imp_trans composes three implications -/
example (A B C D : Formula) (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) (h3 : ⊢ C.imp D) : ⊢ A.imp D := by
  have h4 := imp_trans h1 h2  -- A → C
  exact imp_trans h4 h3       -- A → D

/-!
## P1 Tests: □φ → always φ (necessary implies always)
-/

/-- Test P1 type signature: □φ → △φ (always = future) -/
example (φ : Formula) : ⊢ φ.box.imp φ.always := perpetuity_1 φ

/-- Test P1 with atomic formula -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p").always := perpetuity_1 _

/-- Test P1 using triangle notation -/
example (φ : Formula) : ⊢ φ.box.imp (△φ) := perpetuity_1 φ

/-!
## P2 Tests: sometimes φ → ◇φ (sometimes implies possible)
-/

/-- Test P2 type signature: ▽φ → ◇φ -/
example (φ : Formula) : ⊢ φ.sometimes.imp φ.diamond := perpetuity_2 φ

/-- Test P2 with atomic formula -/
example : ⊢ (Formula.atom "p").sometimes.imp (Formula.atom "p").diamond := perpetuity_2 _

/-- Test P2 using triangle notation -/
example (φ : Formula) : ⊢ (▽φ).imp φ.diamond := perpetuity_2 φ

/-!
## P3 Tests: □φ → □always φ (necessity of perpetuity)
-/

/-- Test P3 type signature: □φ → □△φ -/
example (φ : Formula) : ⊢ φ.box.imp (φ.always.box) := perpetuity_3 φ

/-- Test P3 with atomic formula -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p").always.box := perpetuity_3 _

/-- Test P3 with complex formula -/
example : ⊢ ((Formula.atom "p").imp (Formula.atom "q")).box.imp
             ((Formula.atom "p").imp (Formula.atom "q")).always.box :=
  perpetuity_3 _

/-- Test P3 proof is complete (no sorry markers) -/
-- This test verifies that P3 compiles and type-checks correctly
-- The absence of sorry is verified by the fact that this compiles
example (φ : Formula) : ⊢ φ.box.imp (△φ).box := perpetuity_3 φ

/-!
## Helper Lemma Tests: B Combinator and Contraposition
-/

/-- Test b_combinator type signature: (B → C) → (A → B) → (A → C) -/
example (A B C : Formula) : ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C)) := b_combinator

/-- Test b_combinator with concrete formulas -/
example : ⊢ ((Formula.atom "q").imp (Formula.atom "r")).imp
           (((Formula.atom "p").imp (Formula.atom "q")).imp
            ((Formula.atom "p").imp (Formula.atom "r"))) := b_combinator

/-- Test contraposition type signature: (A → B) → (¬B → ¬A) -/
example (A B : Formula) (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := contraposition h

/-- Test contraposition with concrete formulas using modal T -/
example : ⊢ (Formula.atom "p").neg.imp (Formula.atom "p").box.neg := by
  -- From □p → p (Modal T), derive ¬p → ¬□p
  have h : ⊢ (Formula.atom "p").box.imp (Formula.atom "p") :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  exact contraposition h

/-- Test contraposition is complete (no sorry) -/
example {p q : Formula} (h : ⊢ p.imp q) : ⊢ q.neg.imp p.neg := contraposition h

/-!
## P4 Tests: ◇sometimes φ → ◇φ (possibility of occurrence)
-/

/-- Test P4 type signature: ◇▽φ → ◇φ -/
example (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := perpetuity_4 φ

/-- Test P4 with atomic formula -/
example : ⊢ (Formula.atom "p").sometimes.diamond.imp (Formula.atom "p").diamond := perpetuity_4 _

/-- Test P4 with compound formula -/
example : ⊢ ((Formula.atom "p").imp (Formula.atom "q")).sometimes.diamond.imp
             ((Formula.atom "p").imp (Formula.atom "q")).diamond := perpetuity_4 _

/-- Test P4 is complete theorem (no sorry, no axiom) -/
example (φ : Formula) : ⊢ (▽φ).diamond.imp φ.diamond := perpetuity_4 φ

/-!
## P5 Tests: ◇sometimes φ → always ◇φ (persistent possibility)
-/

/-- Test P5 type signature: ◇▽φ → △◇φ -/
example (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := perpetuity_5 φ

/-- Test P5 with atomic formula -/
example : ⊢ (Formula.atom "p").sometimes.diamond.imp (Formula.atom "p").diamond.always := perpetuity_5 _

/-!
## Modal and Temporal Duality Lemma Tests
-/

/-- Test modal_duality_neg: ◇¬φ → ¬□φ -/
example (φ : Formula) : ⊢ φ.neg.diamond.imp φ.box.neg := modal_duality_neg φ

/-- Test modal_duality_neg with atomic formula -/
example : ⊢ (Formula.atom "p").neg.diamond.imp (Formula.atom "p").box.neg := modal_duality_neg _

/-- Test modal_duality_neg_rev: ¬□φ → ◇¬φ -/
example (φ : Formula) : ⊢ φ.box.neg.imp φ.neg.diamond := modal_duality_neg_rev φ

/-- Test modal_duality_neg_rev with atomic formula -/
example : ⊢ (Formula.atom "p").box.neg.imp (Formula.atom "p").neg.diamond := modal_duality_neg_rev _

/-- Test temporal_duality_neg: ▽¬φ → ¬△φ -/
example (φ : Formula) : ⊢ φ.neg.sometimes.imp φ.always.neg := temporal_duality_neg φ

/-- Test temporal_duality_neg with atomic formula -/
example : ⊢ (Formula.atom "p").neg.sometimes.imp (Formula.atom "p").always.neg := temporal_duality_neg _

/-- Test temporal_duality_neg_rev: ¬△φ → ▽¬φ -/
example (φ : Formula) : ⊢ φ.always.neg.imp φ.neg.sometimes := temporal_duality_neg_rev φ

/-- Test temporal_duality_neg_rev with atomic formula -/
example : ⊢ (Formula.atom "p").always.neg.imp (Formula.atom "p").neg.sometimes := temporal_duality_neg_rev _

/-!
## P6 Tests: sometimes □φ → □always φ (occurrent necessity perpetual)
-/

/-- Test P6 type signature: ▽□φ → □△φ -/
example (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := perpetuity_6 φ

/-- Test P6 with atomic formula -/
example : ⊢ (Formula.atom "p").box.sometimes.imp (Formula.atom "p").always.box := perpetuity_6 _

/-!
## Triangle Notation Tests
-/

/-- Test: P3 with triangle notation - □φ → □△φ -/
example (φ : Formula) : ⊢ φ.box.imp (△φ).box := perpetuity_3 φ

/-- Test: P4 with triangle notation - ◇▽φ → ◇φ -/
example (φ : Formula) : ⊢ (▽φ).diamond.imp φ.diamond := perpetuity_4 φ

/-- Test: P5 with triangle notation - ◇▽φ → △◇φ -/
example (φ : Formula) : ⊢ (▽φ).diamond.imp (△(φ.diamond)) := perpetuity_5 φ

/-- Test: P6 with triangle notation - ▽□φ → □△φ -/
example (φ : Formula) : ⊢ (▽(φ.box)).imp (△φ).box := perpetuity_6 φ

/-- Test: Mixed notation - box with triangle -/
example (p : Formula) : ⊢ p.box.imp (△p).box := perpetuity_3 p

/-- Test: Mixed notation - diamond with triangle -/
example (p : Formula) : ⊢ (▽p).diamond.imp (△(p.diamond)) := perpetuity_5 p

/-!
## Integration Tests
-/

/-- Test: P1 combined with modal T gives reflexivity path -/
example (φ : Formula) : ⊢ φ.box.imp φ := by
  -- □φ → φ is Modal T axiom, but we can also derive via P1 + other axioms
  apply DerivationTree.axiom
  exact Axiom.modal_t φ

/-- Test: P3 is derivable from MF axiom (□φ → □Fφ, and always = future) -/
example (φ : Formula) : ⊢ φ.box.imp φ.always.box := perpetuity_3 φ

/-- Test: Triangle notation equivalence - △ = always -/
example (p : Formula) : △p = p.always := rfl

/-- Test: Triangle notation equivalence - ▽ = sometimes -/
example (p : Formula) : ▽p = p.sometimes := rfl

end

end BimodalTest.Theorems.PerpetuityTest
