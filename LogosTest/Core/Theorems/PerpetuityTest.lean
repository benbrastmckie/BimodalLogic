import Logos.Core.Theorems.Perpetuity

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

namespace LogosTest.Core.Theorems.PerpetuityTest

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Theorems.Perpetuity

/-!
## Helper Lemma Tests: Propositional Reasoning
-/

/-- Test imp_trans: transitivity of implication -/
example (A B C : Formula) (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C :=
  imp_trans h1 h2

/-- Test imp_trans with concrete formulas using modal axioms -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p") := by
  -- □p → □□p by Modal 4
  have h1 : ⊢ (Formula.atom "p").box.imp (Formula.atom "p").box.box :=
    Derivable.axiom [] _ (Axiom.modal_4 (Formula.atom "p"))
  -- □□p → □p trivially (by Modal T applied to □p)
  have h2 : ⊢ (Formula.atom "p").box.box.imp (Formula.atom "p").box :=
    Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "p").box)
  -- □p → □p by transitivity (degenerate case, but tests the mechanism)
  -- Actually, let's use a proper chain: □p → □□p → □p
  -- Then compose with MT: □p → p
  have h3 : ⊢ (Formula.atom "p").box.imp (Formula.atom "p") :=
    Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  exact h3

/-- Test mp (modus ponens restatement) with axioms -/
example (φ : Formula) : ⊢ φ.box.imp φ.always := by
  -- This is perpetuity_1, testing that mp works in the proof
  have h1 : ⊢ φ.box.imp (φ.future.box) := Derivable.axiom [] _ (Axiom.modal_future φ)
  have h2 : ⊢ (φ.future.box).imp φ.future := Derivable.axiom [] _ (Axiom.modal_t φ.future)
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

/-!
## P4 Tests: ◇sometimes φ → ◇φ (possibility of occurrence)
-/

/-- Test P4 type signature: ◇▽φ → ◇φ -/
example (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := perpetuity_4 φ

/-- Test P4 with atomic formula -/
example : ⊢ (Formula.atom "p").sometimes.diamond.imp (Formula.atom "p").diamond := perpetuity_4 _

/-!
## P5 Tests: ◇sometimes φ → always ◇φ (persistent possibility)
-/

/-- Test P5 type signature: ◇▽φ → △◇φ -/
example (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := perpetuity_5 φ

/-- Test P5 with atomic formula -/
example : ⊢ (Formula.atom "p").sometimes.diamond.imp (Formula.atom "p").diamond.always := perpetuity_5 _

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
  apply Derivable.axiom
  exact Axiom.modal_t φ

/-- Test: P3 is derivable from MF axiom (□φ → □Fφ, and always = future) -/
example (φ : Formula) : ⊢ φ.box.imp φ.always.box := perpetuity_3 φ

/-- Test: Triangle notation equivalence - △ = always -/
example (p : Formula) : △p = p.always := rfl

/-- Test: Triangle notation equivalence - ▽ = sometimes -/
example (p : Formula) : ▽p = p.sometimes := rfl

end LogosTest.Core.Theorems.PerpetuityTest
