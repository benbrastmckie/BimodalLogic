# Phase 2: Wave 2 Task 6 - Complete Perpetuity Proofs (Expanded)

**⚠️ SUPERSEDED**: This plan has been superseded by a research-based implementation plan that incorporates proof strategies from the original TM logic paper.

**New Plan**: [TM Perpetuity Paper Research Plan](../../020_tm_perpetuity_paper_research/plans/001-tm-perpetuity-paper-research-plan.md)

**Key Improvements in New Plan**:
- Reduced time estimate from 20-30 hours to 13-20 hours (35% reduction)
- Simplified proof strategies using contraposition and transitivity from paper
- Only 2 propositional helpers needed instead of 4 modal-temporal lemmas
- Direct derivations from paper's §3.2 (Bimodal Logic) section
- Semantic backing from Corollary 2.11

---

## Metadata
- **Phase Number**: 2
- **Wave**: 2 (Medium Priority Enhancements)
- **Dependencies**: Phase 1 (Propositional axioms K and S must be implemented)
- **Estimated Duration**: 20-30 hours
- **Complexity**: High
- **Expected Sorry Reduction**: 3 (lines 225, 252, 280 in Perpetuity.lean)
- **Parent Plan**: [TODO Implementation Systematic Plan](../plans/001-research-todo-implementation-plan.md)
- **Status**: SUPERSEDED (2025-12-02)

## Overview

This phase completes the remaining three perpetuity principles (P4, P5, P6) by leveraging the propositional infrastructure established in Phase 1. The perpetuity principles establish deep connections between modal necessity (`□`) and temporal operators (always `△`, sometimes `▽`).

**Current Status**:
- P1 (`□φ → △φ`) - **Partial**: Uses `imp_trans` helper with sorry at line 88
- P2 (`▽φ → ◇φ`) - **Partial**: Uses `contraposition` helper with sorry at line 139
- P3 (`□φ → □△φ`) - **Complete**: Direct axiom application (MF axiom), zero sorry
- P4 (`◇▽φ → ◇φ`) - **Incomplete**: Sorry at line 225, requires contraposition with complex nested formulas
- P5 (`◇▽φ → △◇φ`) - **Incomplete**: Sorry at line 252, requires modal-temporal interaction lemmas
- P6 (`▽□φ → □△φ`) - **Incomplete**: Sorry at line 280, requires modal-temporal interaction lemmas

**Post-Phase 1 Status** (after propositional axioms implemented):
- P1 and P2 will become fully functional (helpers proven)
- P4, P5, P6 can be proven using corrected helpers and new modal-temporal lemmas

**Key Challenges**:
1. **Complex nested formulas**: P4 involves `◇▽φ = ((▽φ).neg).box.neg = (¬φ).future.box.neg`
2. **Modal-temporal interaction**: P5 and P6 require reasoning about how modal and temporal operators interact across time
3. **Type unfolding**: LEAN 4 type checking requires careful unfolding of derived operator definitions

## Technical Background

### Operator Definitions (from Formula.lean)

Understanding the operator definitions is crucial for the proofs:

```lean
-- Basic operators
def box (φ : Formula) : Formula := φ                      -- Placeholder for □φ
def neg (φ : Formula) : Formula := Formula.imp φ bot      -- ¬φ = φ → ⊥
def diamond (φ : Formula) : Formula := (φ.neg.box).neg    -- ◇φ = ¬□¬φ

-- Temporal operators
def future (φ : Formula) : Formula := φ                   -- Fφ (always in future)
def past (φ : Formula) : Formula := φ                     -- Pφ (always in past)
def always (φ : Formula) : Formula := φ.future            -- △φ = Fφ
def sometimes (φ : Formula) : Formula := (φ.neg.always).neg  -- ▽φ = ¬△¬φ
```

### Type Expansions

These expansions guide proof construction:

**P4 Type Expansion**:
```
Goal: ⊢ ◇▽φ → ◇φ
Expand: ◇▽φ = diamond (sometimes φ)
             = ((sometimes φ).neg).box.neg
             = (((φ.neg.always).neg).neg).box.neg
             = (φ.neg.always).box.neg
             = (φ.neg.future).box.neg
Target: ◇φ = (φ.neg.box).neg
```

**P5 Type Expansion**:
```
Goal: ⊢ ◇▽φ → △◇φ
Expand: ◇▽φ = (φ.neg.future).box.neg
        △◇φ = always (diamond φ)
             = future ((φ.neg.box).neg)
             = ((φ.neg.box).neg).future
```

**P6 Type Expansion**:
```
Goal: ⊢ ▽□φ → □△φ
Expand: ▽□φ = sometimes (box φ)
             = ((box φ).neg.always).neg
             = ((box φ).neg.future).neg
        □△φ = box (always φ)
             = box (future φ)
             = (future φ).box
```

### Relevant Axioms

The following TM axioms are key to the proofs:

```lean
-- MF (Modal-Future): What's necessary remains necessary in future
axiom modal_future (φ : Formula) : Axiom (φ.box.imp (φ.future.box))
-- Concrete: ⊢ □φ → □Fφ

-- TF (Temporal-Future): Necessary truths were/will-be necessary
axiom temp_future (φ : Formula) : Axiom (φ.box.imp (φ.box.future))
-- Concrete: ⊢ □φ → F□φ

-- MT (Modal T): What's necessary is true
axiom modal_t (φ : Formula) : Axiom (φ.box.imp φ)
-- Concrete: ⊢ □φ → φ
```

## Implementation Tasks

### Task 2.1: Verify Phase 1 Propositional Helpers Available

**File**: `Logos/Theorems/Perpetuity.lean`

**Objective**: Confirm Phase 1 completion before proceeding with P4-P6 proofs.

**Verification Steps**:

1. **Confirm `imp_trans` proven** (line 88):
```bash
# Check that imp_trans no longer uses sorry
grep -A10 "theorem imp_trans" Logos/Theorems/Perpetuity.lean | grep -c "sorry"
# Expected: 0
```

Expected implementation after Phase 1:
```lean
theorem imp_trans {A B C : Formula}
    (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C := by
  -- Using propositional axioms K and S from Phase 1
  -- K: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
  -- S: φ → (ψ → φ)
  -- Derivation of transitivity from K and S
  have hK : ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B C)
  have h3 : ⊢ (A.imp B).imp (A.imp C) :=
    Derivable.modus_ponens [] (B.imp C) ((A.imp B).imp (A.imp C)) hK h2
  exact Derivable.modus_ponens [] (A.imp B) (A.imp C) h3 h1
```

2. **Confirm `contraposition` proven** (line 139):
```bash
# Check that contraposition no longer uses sorry
grep -A10 "theorem contraposition" Logos/Theorems/Perpetuity.lean | grep -c "sorry"
# Expected: 0
```

Expected implementation after Phase 1:
```lean
theorem contraposition {A B : Formula}
    (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  -- Using propositional axioms and double negation
  -- Contraposition: (A → B) → (¬B → ¬A)
  -- From K axiom instances and modus ponens
  have hContra : ⊢ (A.imp B).imp (B.neg.imp A.neg) :=
    Derivable.axiom [] _ (Axiom.contraposition_schema A B)
  exact Derivable.modus_ponens [] (A.imp B) (B.neg.imp A.neg) hContra h
```

3. **Verify P1 and P2 now fully functional**:
```bash
# Run perpetuity tests
lake test LogosTest.Theorems.PerpetuityTest
```

**Acceptance Criteria**:
- [ ] `imp_trans` theorem has zero sorry placeholders
- [ ] `contraposition` theorem has zero sorry placeholders
- [ ] P1 proof builds successfully
- [ ] P2 proof builds successfully
- [ ] Perpetuity tests pass for P1, P2, P3

**Time Estimate**: 30 minutes (verification only)

---

### Task 2.2: Develop Modal-Temporal Interaction Lemmas

**File**: `Logos/Theorems/Perpetuity.lean`

**Objective**: Create helper lemmas that capture common modal-temporal interaction patterns needed for P4, P5, P6.

**Lemma 1: Box-Future Distribution**

```lean
/--
Box distributes over future for negation: `□(¬Fφ) → ¬F□φ`

This captures a key interaction between modal necessity and temporal operators.
-/
theorem box_future_neg_dist (φ : Formula) :
    ⊢ (φ.neg.future).box.imp (φ.box.future).neg := by
  -- Derivation:
  -- 1. By TF axiom: ⊢ □φ → F□φ (temp_future)
  -- 2. Contraposition: ⊢ ¬F□φ → ¬□φ
  -- 3. From MF axiom: ⊢ □φ → □Fφ (modal_future)
  -- 4. By contraposition: ⊢ ¬□Fφ → ¬□φ
  -- 5. Combining these using modal reasoning...
  have hTF : ⊢ φ.box.imp (φ.box.future) :=
    Derivable.axiom [] _ (Axiom.temp_future φ)
  have hContra : ⊢ (φ.box.future).neg.imp φ.box.neg :=
    contraposition hTF
  -- Further steps involve modal K rule and necessitation
  sorry
```

**Lemma 2: Future-Diamond Interaction**

```lean
/--
Future and diamond interaction: `¬□(Fφ) → F(◇φ)`

If it's not necessary that φ always holds in future,
then at some future time φ is possible.
-/
theorem future_diamond_interaction (φ : Formula) :
    ⊢ (φ.future.box).neg.imp ((φ.diamond).future) := by
  -- This requires showing that lack of necessity in future
  -- implies future possibility
  -- Uses MF and MT axioms
  have hMF : ⊢ φ.box.imp (φ.future.box) :=
    Derivable.axiom [] _ (Axiom.modal_future φ)
  -- By contraposition of MF: ¬□Fφ → ¬□φ
  have hContraMF : ⊢ (φ.future.box).neg.imp φ.box.neg :=
    contraposition hMF
  -- From ¬□φ derive ◇φ (by definition)
  -- Then use temporal reasoning to get F(◇φ)
  sorry
```

**Lemma 3: Diamond-Always Duality**

```lean
/--
Diamond and always duality through future: `◇(▽φ) → ▽(◇φ)`

Possibility of sometime is sometime possible.
-/
theorem diamond_sometimes_duality (φ : Formula) :
    ⊢ (φ.sometimes.diamond).imp (φ.diamond.sometimes) := by
  -- This is a complex duality lemma
  -- Requires showing that modal and temporal operators commute
  -- Uses both MF and TF axioms plus contraposition
  sorry
```

**Lemma 4: Box-Always Composition**

```lean
/--
Box and always composition: `□φ → □(△φ)`

This is actually P3 (perpetuity_3), but explicitly named for clarity.
-/
theorem box_always_composition (φ : Formula) :
    ⊢ φ.box.imp (φ.always.box) :=
  perpetuity_3 φ
```

**Testing Strategy**:

Create test file `LogosTest/Theorems/ModalTemporalInteractionTest.lean`:

```lean
import LogosTest.Testing
import Logos.Theorems.Perpetuity

namespace LogosTest.Theorems.ModalTemporalInteraction

open Logos.Syntax
open Logos.ProofSystem
open Logos.Theorems.Perpetuity

-- Test box_future_neg_dist
example : ⊢ (p.neg.future).box.imp (p.box.future).neg :=
  box_future_neg_dist p

-- Test future_diamond_interaction
example : ⊢ (p.future.box).neg.imp ((p.diamond).future) :=
  future_diamond_interaction p

-- Test diamond_sometimes_duality
example : ⊢ (p.sometimes.diamond).imp (p.diamond.sometimes) :=
  diamond_sometimes_duality p

-- Test box_always_composition (P3)
example : ⊢ p.box.imp (p.always.box) :=
  box_always_composition p

end LogosTest.Theorems.ModalTemporalInteraction
```

**Acceptance Criteria**:
- [ ] 4 modal-temporal interaction lemmas defined with docstrings
- [ ] Each lemma has a clear derivation strategy (even if using sorry initially)
- [ ] Test file created with examples for each lemma
- [ ] Tests build successfully (even if lemmas use sorry)

**Time Estimate**: 4-6 hours (lemma design, documentation, testing)

---

### Task 2.3: Prove P4 (`◇▽φ → ◇φ`) - Possibility of Occurrence

**File**: `Logos/Theorems/Perpetuity.lean` (line 225)

**Objective**: Complete the proof of P4 using corrected contraposition helper and type unfolding.

**Current State**:
```lean
theorem perpetuity_4 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := by
  -- Goal: ⊢ ◇▽φ → ◇φ
  -- where ◇▽φ = (¬φ).future.box.neg and ◇φ = (¬φ).box.neg
  -- This requires: ⊢ (¬φ).future.box.neg → (¬φ).box.neg
  -- Which is contraposition of: □(¬φ) → □((¬φ).future)
  -- That is: contraposition of perpetuity_3 (φ.neg)
  --
  -- However, the type unfolding is subtle. For MVP, using sorry.
  sorry
```

**Proof Strategy**:

The key insight is that P4 is the contraposition of P3 applied to `¬φ`:

1. **Start with P3 for `¬φ`**: `⊢ □(¬φ) → □(△(¬φ))`
2. **Simplify**: Since `△ψ = Fψ`, we have `⊢ □(¬φ) → □(F(¬φ))`
3. **Apply contraposition**: `⊢ ¬□(F(¬φ)) → ¬□(¬φ)`
4. **Recognize operators**:
   - `¬□(F(¬φ)) = (¬φ).future.box.neg = ◇(▽φ)` (by definition expansions)
   - `¬□(¬φ) = (¬φ).box.neg = ◇φ` (by definition of diamond)
5. **Conclude**: `⊢ ◇(▽φ) → ◇φ`

**Detailed Implementation**:

```lean
theorem perpetuity_4 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := by
  -- Goal: ⊢ ◇▽φ → ◇φ

  -- Step 1: Apply P3 to φ.neg
  have hP3_neg : ⊢ φ.neg.box.imp (φ.neg.always.box) := perpetuity_3 φ.neg

  -- Step 2: Unfold always = future in hP3_neg
  -- hP3_neg : ⊢ □(¬φ) → □(F(¬φ))
  -- which is: ⊢ □(¬φ) → □(△(¬φ))

  -- Step 3: Apply contraposition to hP3_neg
  have hContra : ⊢ (φ.neg.always.box).neg.imp φ.neg.box.neg :=
    contraposition hP3_neg

  -- Step 4: Type conversions
  -- hContra : ⊢ ¬□(△(¬φ)) → ¬□(¬φ)
  -- which is: ⊢ ¬□(F(¬φ)) → ◇φ

  -- Step 5: Show that (¬□(F(¬φ))) = ◇▽φ
  -- By definitions:
  -- - ▽φ = sometimes φ = ¬△(¬φ) = ¬F(¬φ) = (¬φ).future.neg
  -- - ◇▽φ = ¬□(▽φ) = ¬□(¬F(¬φ))
  -- Wait, this needs careful unfolding...

  -- Actually, let's use the expanded forms directly:
  -- φ.sometimes.diamond = ((φ.neg.always).neg).diamond
  --                     = (((φ.neg.always).neg).neg.box).neg
  --                     = (φ.neg.always.box).neg
  -- φ.diamond = (φ.neg.box).neg

  -- So hContra exactly matches our goal!
  -- hContra : ⊢ (φ.neg.always.box).neg → (φ.neg.box).neg
  -- Goal    : ⊢ φ.sometimes.diamond    → φ.diamond

  -- Use type conversion lemma (to be proven)
  convert hContra using 1
  · -- Show: φ.sometimes.diamond = (φ.neg.always.box).neg
    simp [Formula.sometimes, Formula.diamond, Formula.always]
  · -- Show: φ.diamond = (φ.neg.box).neg
    simp [Formula.diamond]
```

**Type Conversion Lemmas** (if needed):

If `convert` tactic is insufficient, add explicit conversion lemmas:

```lean
lemma sometimes_diamond_unfold (φ : Formula) :
    φ.sometimes.diamond = (φ.neg.always.box).neg := by
  simp [Formula.sometimes, Formula.diamond, Formula.always]
  rfl

lemma diamond_unfold (φ : Formula) :
    φ.diamond = (φ.neg.box).neg := by
  simp [Formula.diamond]
  rfl
```

**Testing**:

Add to `LogosTest/Theorems/PerpetuityTest.lean`:

```lean
-- Test P4 with various formula instances
def test_p4_atom : TestCase := {
  name := "P4 with atom",
  test := fun () => do
    let φ := atom 1
    let thm := perpetuity_4 φ
    -- ⊢ ◇▽p → ◇p should be derivable
    check_derivable thm
}

def test_p4_compound : TestCase := {
  name := "P4 with compound formula",
  test := fun () => do
    let φ := (atom 1).imp (atom 2)
    let thm := perpetuity_4 φ
    -- ⊢ ◇▽(p → q) → ◇(p → q) should be derivable
    check_derivable thm
}

def test_p4_nested_modal : TestCase := {
  name := "P4 with nested modality",
  test := fun () => do
    let φ := (atom 1).box
    let thm := perpetuity_4 φ
    -- ⊢ ◇▽(□p) → ◇(□p) should be derivable
    check_derivable thm
}
```

**Acceptance Criteria**:
- [ ] `perpetuity_4` theorem has zero sorry placeholders
- [ ] Proof uses `contraposition` helper from Phase 1
- [ ] Type unfolding is explicit and clear
- [ ] All P4 test cases pass
- [ ] Line 225 sorry removed

**Time Estimate**: 4-6 hours (proof development, type conversion, testing)

---

### Task 2.4: Prove P5 (`◇▽φ → △◇φ`) - Persistent Possibility

**File**: `Logos/Theorems/Perpetuity.lean` (line 252)

**Objective**: Complete the proof of P5 using modal-temporal interaction lemmas.

**Current State**:
```lean
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  -- Goal: ⊢ ◇▽φ → △◇φ
  -- This is one of the more complex perpetuity principles
  -- It requires showing that possibility persists into the future
  sorry
```

**Theorem Interpretation**:

P5 states: "If it's possible that φ happens sometime in the future, then at all future times φ is possible."

This is a strong persistence principle connecting:
- `◇▽φ`: Modal possibility of temporal occurrence
- `△◇φ`: Temporal perpetuity of modal possibility

**Proof Strategy**:

The proof requires combining TF (Temporal-Future) axiom with modal reasoning:

1. **TF axiom**: `⊢ □φ → F□φ` (necessity persists into future)
2. **Apply to `¬φ`**: `⊢ □(¬φ) → F□(¬φ)`
3. **Contraposition**: `⊢ ¬F□(¬φ) → ¬□(¬φ)`
4. **Left side**: `¬F□(¬φ)` needs to be related to `◇▽φ`
5. **Right side**: `¬□(¬φ) = ◇φ`, and we need `F(◇φ) = △◇φ`

This is more subtle than P4 and requires modal-temporal interaction lemmas.

**Detailed Implementation**:

```lean
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  -- Goal: ⊢ ◇▽φ → △◇φ
  -- Expand: ◇▽φ = (φ.neg.future).box.neg
  --         △◇φ = ((φ.neg.box).neg).future

  -- Strategy: Use TF axiom and modal-temporal interaction

  -- Step 1: TF axiom for ¬φ: ⊢ □(¬φ) → F□(¬φ)
  have hTF : ⊢ φ.neg.box.imp (φ.neg.box.future) :=
    Derivable.axiom [] _ (Axiom.temp_future φ.neg)

  -- Step 2: Contraposition of TF
  have hContraTF : ⊢ (φ.neg.box.future).neg.imp φ.neg.box.neg :=
    contraposition hTF

  -- Step 3: Use MF axiom: ⊢ □(¬φ) → □F(¬φ)
  have hMF : ⊢ φ.neg.box.imp (φ.neg.future.box) :=
    Derivable.axiom [] _ (Axiom.modal_future φ.neg)

  -- Step 4: We need to show: (φ.neg.future.box).neg → ((φ.neg.box).neg).future
  -- This requires showing that ¬□F(¬φ) implies F(◇φ)

  -- Use modal-temporal interaction lemma
  have hInteraction : ⊢ (φ.neg.future.box).neg.imp ((φ.neg.box.neg).future) :=
    future_diamond_interaction φ.neg

  -- Step 5: Type conversions
  -- hInteraction : ⊢ ¬□F(¬φ) → F(◇φ)
  -- which is     : ⊢ (φ.neg.future.box).neg → φ.diamond.future
  -- which is     : ⊢ (φ.neg.future.box).neg → φ.diamond.always (since always = future)

  -- Now we need to relate (φ.neg.future.box).neg to φ.sometimes.diamond
  -- φ.sometimes.diamond = ((φ.neg.always).neg).diamond
  --                     = (((φ.neg.always).neg).neg.box).neg
  --                     = (φ.neg.always.box).neg
  --                     = (φ.neg.future.box).neg (since always = future)

  -- So hInteraction exactly gives us our goal!
  convert hInteraction using 1
  · -- Show: φ.sometimes.diamond = (φ.neg.future.box).neg
    simp [Formula.sometimes, Formula.diamond, Formula.always]
  · -- Show: φ.diamond.always = (φ.neg.box.neg).future
    simp [Formula.diamond, Formula.always]
```

**Alternative Approach** (if modal_temporal_interaction lemmas insufficient):

```lean
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  -- More direct approach using P4 and temporal reasoning

  -- From P4: ⊢ ◇▽φ → ◇φ
  have hP4 : ⊢ φ.sometimes.diamond.imp φ.diamond := perpetuity_4 φ

  -- Need to strengthen: ⊢ ◇φ → F(◇φ) = ⊢ ◇φ → △◇φ
  -- This requires showing possibility persists

  -- Use TF axiom contrapositive reasoning
  -- TF for ¬φ: ⊢ □(¬φ) → F□(¬φ)
  -- Contrapose: ⊢ ¬F□(¬φ) → ◇φ
  -- We need: ⊢ ◇φ → F(◇φ)

  -- This requires a persistence lemma for possibility
  have hPersist : ⊢ φ.diamond.imp φ.diamond.future :=
    possibility_persists_future φ

  -- Compose: ◇▽φ → ◇φ → F(◇φ)
  exact imp_trans hP4 hPersist
```

This approach requires a new lemma:

```lean
/-- Possibility persists into future: ◇φ → F(◇φ) -/
theorem possibility_persists_future (φ : Formula) :
    ⊢ φ.diamond.imp φ.diamond.future := by
  -- This is a semantic property that may need to be axiomatized
  -- or derived from frame properties
  sorry
```

**Testing**:

Add to `LogosTest/Theorems/PerpetuityTest.lean`:

```lean
-- Test P5 with modal-temporal combinations
def test_p5_simple : TestCase := {
  name := "P5 with atom",
  test := fun () => do
    let φ := atom 1
    let thm := perpetuity_5 φ
    -- ⊢ ◇▽p → △◇p should be derivable
    check_derivable thm
}

def test_p5_modal_formula : TestCase := {
  name := "P5 with modal formula",
  test := fun () => do
    let φ := (atom 1).box.imp (atom 2)
    let thm := perpetuity_5 φ
    -- ⊢ ◇▽(□p → q) → △◇(□p → q) should be derivable
    check_derivable thm
}

def test_p5_temporal_formula : TestCase := {
  name := "P5 with temporal formula",
  test := fun () => do
    let φ := (atom 1).future
    let thm := perpetuity_5 φ
    -- ⊢ ◇▽(Fp) → △◇(Fp) should be derivable
    check_derivable thm
}
```

**Acceptance Criteria**:
- [ ] `perpetuity_5` theorem has zero sorry placeholders
- [ ] Proof uses modal-temporal interaction lemmas from Task 2.2
- [ ] All P5 test cases pass
- [ ] Line 252 sorry removed
- [ ] If additional lemmas needed, they are documented and tested

**Time Estimate**: 6-8 hours (proof development, lemma refinement, testing)

---

### Task 2.5: Prove P6 (`▽□φ → □△φ`) - Occurrent Necessity is Perpetual

**File**: `Logos/Theorems/Perpetuity.lean` (line 280)

**Objective**: Complete the proof of P6 using modal-temporal interaction lemmas.

**Current State**:
```lean
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- Goal: ⊢ ▽□φ → □△φ
  -- Recall: ▽□φ = ¬△¬□φ = ¬F(¬□φ) = ¬F(◇¬φ)
  -- And: □△φ = □Fφ
  --
  -- This is related to TF axiom: □φ → F□φ
  -- Which gives: □φ → △□φ
  --
  -- By contraposition and modal reasoning...
  sorry
```

**Theorem Interpretation**:

P6 states: "If necessity occurs at some future time, then it's necessary that φ is always true."

This is the strongest perpetuity principle, asserting that occurrent necessity implies necessary perpetuity.

**Proof Strategy**:

The key is the TF (Temporal-Future) axiom: `□φ → F□φ`

1. **TF axiom**: `⊢ □φ → F□φ` means necessity implies its own future occurrence
2. **Strengthen**: `⊢ □φ → □Fφ` by necessitation (applying modal K)
3. **Relate to goal**: We need to show that if `▽□φ` (sometime necessary), then `□△φ` (necessarily always)

**Detailed Implementation**:

```lean
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- Goal: ⊢ ▽□φ → □△φ
  -- Expand: ▽□φ = ((□φ).neg.future).neg
  --         □△φ = □Fφ = (Fφ).box

  -- Strategy: Use TF axiom and necessitation

  -- Step 1: TF axiom: ⊢ □φ → F□φ
  have hTF : ⊢ φ.box.imp (φ.box.future) :=
    Derivable.axiom [] _ (Axiom.temp_future φ)

  -- Step 2: From TF, we can derive: ⊢ □φ → □Fφ
  -- This requires showing that F□φ → □Fφ
  -- Actually, we need to use MF axiom: □φ → □Fφ
  have hMF : ⊢ φ.box.imp (φ.future.box) :=
    Derivable.axiom [] _ (Axiom.modal_future φ)

  -- Step 3: The challenge is going from ▽□φ to □φ
  -- ▽□φ means "sometime in future, □φ holds"
  -- This is ¬F(¬□φ) = ¬F(◇¬φ)

  -- Actually, the correct derivation uses contraposition differently
  -- Let's think about the semantic meaning:
  -- If ▽□φ (necessity occurs sometime), we want to show □△φ (necessarily always)

  -- Key insight: By TF, if □φ holds at any time, then F□φ holds at that time
  -- So if ▽□φ, then at that time t where □φ holds, we have F□φ at t
  -- But this requires temporal reasoning about "at time t"

  -- Alternative: Use P3 and temporal reasoning
  -- P3: □φ → □△φ (for any φ)
  -- So: □(□φ) → □△(□φ)
  -- And: □(□φ) = □φ (by M4: □φ → □□φ and converse)

  -- Actually simpler: Use the fact that if ▽□φ, then ◇□φ by P2
  -- Then from ◇□φ, we need □△φ

  -- Most direct: Use MF directly
  -- MF: □φ → □Fφ which is exactly: □φ → □△φ (since △ = F)
  -- So if we can show ▽□φ → □φ, we're done

  -- But that's not valid! ▽□φ doesn't imply □φ
  -- The semantic reading is: "sometime necessary" doesn't mean "necessary"

  -- Correct approach: Show that the *occurrence* of necessity implies perpetual necessity
  -- This may require a frame property or be derivable from TF + modal reasoning

  -- Let's try: If ▽□φ, then by definition ¬△(¬□φ) = ¬F(◇¬φ)
  -- We want □Fφ
  -- By contraposition of P3 for ¬φ: ¬□F(¬φ) → ¬□(¬φ)
  -- Which is: ¬□F(¬φ) → ◇φ

  -- This is getting complex. Use modal-temporal interaction lemma:
  have hInteraction : ⊢ φ.box.sometimes.imp φ.future.box :=
    sometimes_box_implies_box_future φ

  convert hInteraction using 1
  · rfl
  · simp [Formula.always]
```

**Required Modal-Temporal Interaction Lemma**:

```lean
/--
Sometimes-box implies box-future: ▽□φ → □Fφ

If necessity occurs at some future time, then it's necessary that φ holds in future.
This follows from the TF axiom and temporal reasoning.
-/
theorem sometimes_box_implies_box_future (φ : Formula) :
    ⊢ φ.box.sometimes.imp φ.future.box := by
  -- Derivation:
  -- 1. TF axiom: ⊢ □φ → F□φ
  -- 2. By M4: ⊢ □φ → □□φ (necessity of necessity)
  -- 3. Combining with TF: if □φ holds at any time, then F□φ holds there
  -- 4. From MF: ⊢ □φ → □Fφ (this is P3!)
  -- 5. So we need: ▽□φ → □φ? No, that's not valid

  -- Actually: ▽□φ means ¬F(¬□φ)
  -- We want □Fφ
  -- By contraposition of ¬F(¬□φ) and modal reasoning:

  -- Use P3 and temporal persistence
  have hP3 : ⊢ φ.box.imp φ.always.box := perpetuity_3 φ

  -- If ▽□φ, then at some future time t, □φ holds
  -- At that t, by P3, we have □Fφ
  -- Since this □Fφ is at t in the future, and it's a necessity...
  -- By TF for Fφ: □Fφ → F□Fφ
  -- But we want □Fφ now, not F□Fφ

  -- The semantic argument: If necessity occurs at t, then by TF,
  -- necessity persists from t onward. By modal reasoning, this
  -- means □Fφ holds at the present.

  -- This may require an additional axiom or frame property
  sorry
```

**Alternative Simpler Approach**:

If the above is too complex, we can use a more direct argument:

```lean
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- Direct approach: Use TF axiom structure
  -- TF: □φ → F□φ means necessity implies future necessity
  -- Combined with modal reasoning:

  -- Step 1: By TF for any ψ, if □ψ then F□ψ
  -- Step 2: Apply to φ: □φ → F□φ
  -- Step 3: From MF (P3): □φ → □Fφ
  have hP3 : ⊢ φ.box.imp φ.future.box := perpetuity_3 φ

  -- Step 4: Show that ▽□φ strengthens to □φ somehow?
  -- No, that's not valid

  -- Step 5: The semantic reading is that if □φ ever holds (▽□φ),
  -- then by TF, it continues to hold (F□φ), and by necessitation,
  -- we get □Fφ

  -- This requires a temporal necessitation principle:
  -- If ▽ψ and ψ → χ, then ...

  -- For MVP, this is one of the hardest perpetuity proofs
  sorry
```

**Testing**:

Add to `LogosTest/Theorems/PerpetuityTest.lean`:

```lean
-- Test P6 with occurrent necessity cases
def test_p6_simple : TestCase := {
  name := "P6 with atom",
  test := fun () => do
    let φ := atom 1
    let thm := perpetuity_6 φ
    -- ⊢ ▽□p → □△p should be derivable
    check_derivable thm
}

def test_p6_implication : TestCase := {
  name := "P6 with implication",
  test := fun () => do
    let φ := (atom 1).imp (atom 2)
    let thm := perpetuity_6 φ
    -- ⊢ ▽□(p → q) → □△(p → q) should be derivable
    check_derivable thm
}

def test_p6_nested_temporal : TestCase := {
  name := "P6 with nested temporal",
  test := fun () => do
    let φ := (atom 1).future
    let thm := perpetuity_6 φ
    -- ⊢ ▽□(Fp) → □△(Fp) should be derivable
    check_derivable thm
}
```

**Acceptance Criteria**:
- [ ] `perpetuity_6` theorem has zero sorry placeholders
- [ ] Proof uses TF axiom and modal reasoning
- [ ] All P6 test cases pass
- [ ] Line 280 sorry removed
- [ ] If additional lemmas needed, they are documented with semantic justification

**Time Estimate**: 6-10 hours (proof development, potential frame property research, testing)

**Note**: P6 is the most challenging perpetuity principle. If the direct proof remains elusive, consider:
1. Adding P6 as an axiom with semantic justification
2. Proving P6 under restricted frame conditions
3. Documenting P6 as a conjecture with evidence

---

### Task 2.6: Write Comprehensive Tests for P4-P6

**File**: `LogosTest/Theorems/PerpetuityTest.lean`

**Objective**: Ensure P4, P5, P6 are thoroughly tested with various formula types.

**Test Organization**:

```lean
import LogosTest.Testing
import Logos.Theorems.Perpetuity

namespace LogosTest.Theorems.Perpetuity

open Logos.Syntax
open Logos.ProofSystem
open Logos.Theorems.Perpetuity

/-!
## Perpetuity Principles P4-P6 Test Suite

Tests for the complex perpetuity principles involving modal-temporal interaction.
-/

-- ===== P4 Tests: Possibility of Occurrence (◇▽φ → ◇φ) =====

def test_p4_atom : TestCase := {
  name := "P4: Possibility of occurrence with atom",
  test := fun () => do
    let p := atom 1
    let thm := perpetuity_4 p
    assert (is_derivable thm) "P4 should be derivable for atom"
}

def test_p4_negation : TestCase := {
  name := "P4: Possibility of occurrence with negation",
  test := fun () => do
    let p := (atom 1).neg
    let thm := perpetuity_4 p
    assert (is_derivable thm) "P4 should be derivable for negation"
}

def test_p4_implication : TestCase := {
  name := "P4: Possibility of occurrence with implication",
  test := fun () => do
    let φ := (atom 1).imp (atom 2)
    let thm := perpetuity_4 φ
    assert (is_derivable thm) "P4 should be derivable for implication"
}

def test_p4_modal_formula : TestCase := {
  name := "P4: Possibility of occurrence with modal formula",
  test := fun () => do
    let φ := (atom 1).box
    let thm := perpetuity_4 φ
    assert (is_derivable thm) "P4 should be derivable for □p"
}

def test_p4_temporal_formula : TestCase := {
  name := "P4: Possibility of occurrence with temporal formula",
  test := fun () => do
    let φ := (atom 1).future
    let thm := perpetuity_4 φ
    assert (is_derivable thm) "P4 should be derivable for Fp"
}

def test_p4_compound_modal_temporal : TestCase := {
  name := "P4: Possibility of occurrence with compound modal-temporal",
  test := fun () => do
    let φ := ((atom 1).box).future
    let thm := perpetuity_4 φ
    assert (is_derivable thm) "P4 should be derivable for F□p"
}

-- ===== P5 Tests: Persistent Possibility (◇▽φ → △◇φ) =====

def test_p5_atom : TestCase := {
  name := "P5: Persistent possibility with atom",
  test := fun () => do
    let p := atom 1
    let thm := perpetuity_5 p
    assert (is_derivable thm) "P5 should be derivable for atom"
}

def test_p5_negation : TestCase := {
  name := "P5: Persistent possibility with negation",
  test := fun () => do
    let p := (atom 1).neg
    let thm := perpetuity_5 p
    assert (is_derivable thm) "P5 should be derivable for negation"
}

def test_p5_conjunction : TestCase := {
  name := "P5: Persistent possibility with conjunction",
  test := fun () => do
    let φ := (atom 1).and (atom 2)
    let thm := perpetuity_5 φ
    assert (is_derivable thm) "P5 should be derivable for conjunction"
}

def test_p5_modal_formula : TestCase := {
  name := "P5: Persistent possibility with modal formula",
  test := fun () => do
    let φ := (atom 1).diamond
    let thm := perpetuity_5 φ
    assert (is_derivable thm) "P5 should be derivable for ◇p"
}

def test_p5_temporal_formula : TestCase := {
  name := "P5: Persistent possibility with temporal formula",
  test := fun () => do
    let φ := (atom 1).past
    let thm := perpetuity_5 φ
    assert (is_derivable thm) "P5 should be derivable for Pp"
}

def test_p5_nested_modalities : TestCase := {
  name := "P5: Persistent possibility with nested modalities",
  test := fun () => do
    let φ := ((atom 1).box).diamond
    let thm := perpetuity_5 φ
    assert (is_derivable thm) "P5 should be derivable for ◇□p"
}

-- ===== P6 Tests: Occurrent Necessity is Perpetual (▽□φ → □△φ) =====

def test_p6_atom : TestCase := {
  name := "P6: Occurrent necessity with atom",
  test := fun () => do
    let p := atom 1
    let thm := perpetuity_6 p
    assert (is_derivable thm) "P6 should be derivable for atom"
}

def test_p6_negation : TestCase := {
  name := "P6: Occurrent necessity with negation",
  test := fun () => do
    let p := (atom 1).neg
    let thm := perpetuity_6 p
    assert (is_derivable thm) "P6 should be derivable for negation"
}

def test_p6_disjunction : TestCase := {
  name := "P6: Occurrent necessity with disjunction",
  test := fun () => do
    let φ := (atom 1).or (atom 2)
    let thm := perpetuity_6 φ
    assert (is_derivable thm) "P6 should be derivable for disjunction"
}

def test_p6_modal_formula : TestCase := {
  name := "P6: Occurrent necessity with modal formula",
  test := fun () => do
    let φ := (atom 1).box
    let thm := perpetuity_6 φ
    assert (is_derivable thm) "P6 should be derivable for □p"
}

def test_p6_temporal_formula : TestCase := {
  name := "P6: Occurrent necessity with temporal formula",
  test := fun () => do
    let φ := (atom 1).future
    let thm := perpetuity_6 φ
    assert (is_derivable thm) "P6 should be derivable for Fp"
}

def test_p6_complex_formula : TestCase := {
  name := "P6: Occurrent necessity with complex formula",
  test := fun () => do
    let φ := ((atom 1).imp (atom 2)).box
    let thm := perpetuity_6 φ
    assert (is_derivable thm) "P6 should be derivable for □(p → q)"
}

-- ===== Integration Tests: P4-P5-P6 Chains =====

def test_p4_p5_chain : TestCase := {
  name := "Integration: P4 and P5 chaining",
  test := fun () => do
    let p := atom 1
    let p4 := perpetuity_4 p
    let p5 := perpetuity_5 p
    -- From ◇▽p, derive △◇p using both principles
    -- ◇▽p → ◇p (by P4), then separately ◇▽p → △◇p (by P5)
    assert (is_derivable p4) "P4 derivable"
    assert (is_derivable p5) "P5 derivable"
    -- Test transitivity if applicable
}

def test_p5_p6_compatibility : TestCase := {
  name := "Integration: P5 and P6 compatibility",
  test := fun () => do
    let p := atom 1
    let p5 := perpetuity_5 p
    let p6 := perpetuity_6 p
    -- Both principles should be derivable for same formula
    assert (is_derivable p5) "P5 derivable"
    assert (is_derivable p6) "P6 derivable"
}

def test_all_six_perpetuity : TestCase := {
  name := "Integration: All six perpetuity principles",
  test := fun () => do
    let p := atom 1
    -- Verify all six perpetuity principles are derivable
    assert (is_derivable (perpetuity_1 p)) "P1 derivable"
    assert (is_derivable (perpetuity_2 p)) "P2 derivable"
    assert (is_derivable (perpetuity_3 p)) "P3 derivable"
    assert (is_derivable (perpetuity_4 p)) "P4 derivable"
    assert (is_derivable (perpetuity_5 p)) "P5 derivable"
    assert (is_derivable (perpetuity_6 p)) "P6 derivable"
}

-- ===== Test Suite Definition =====

def perpetuity_p4_p6_test_suite : TestSuite := {
  name := "Perpetuity Principles P4-P6",
  tests := [
    -- P4 tests
    test_p4_atom,
    test_p4_negation,
    test_p4_implication,
    test_p4_modal_formula,
    test_p4_temporal_formula,
    test_p4_compound_modal_temporal,
    -- P5 tests
    test_p5_atom,
    test_p5_negation,
    test_p5_conjunction,
    test_p5_modal_formula,
    test_p5_temporal_formula,
    test_p5_nested_modalities,
    -- P6 tests
    test_p6_atom,
    test_p6_negation,
    test_p6_disjunction,
    test_p6_modal_formula,
    test_p6_temporal_formula,
    test_p6_complex_formula,
    -- Integration tests
    test_p4_p5_chain,
    test_p5_p6_compatibility,
    test_all_six_perpetuity
  ]
}

end LogosTest.Theorems.Perpetuity
```

**Testing Commands**:

```bash
# Run full perpetuity test suite
lake test LogosTest.Theorems.PerpetuityTest

# Run specific test subsections
lake test LogosTest.Theorems.Perpetuity.perpetuity_p4_p6_test_suite

# Check for test failures
lake test 2>&1 | grep -i "fail"
```

**Acceptance Criteria**:
- [ ] Test suite covers P4, P5, P6 with 6+ test cases each
- [ ] Integration tests verify P4-P5-P6 compatibility
- [ ] All tests pass (zero failures)
- [ ] Test coverage for atoms, negations, implications, modal, temporal, and compound formulas
- [ ] Test documentation explains what each test verifies

**Time Estimate**: 3-4 hours (test design, implementation, verification)

---

### Task 2.7: Update Documentation for Task 6 Completion

**Files**:
- `TODO.md`
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`

**Objective**: Synchronize all documentation to reflect P4-P6 completion.

**Documentation Updates**:

#### 1. Update TODO.md

**File**: `TODO.md`

**Changes**:

a) **Mark Task 6 complete**:
```markdown
### Medium Priority (4/4 tasks complete - 100%)

- [x] Task 5: Complete Soundness Proofs (High Priority) [COMPLETE: 2025-12-XX]
- [x] Task 6: Complete Perpetuity Proofs (Medium Priority) [COMPLETE: 2025-12-XX]
- [x] Task 7: Implement Core Automation (Medium Priority) [COMPLETE: 2025-12-XX]
- [x] Task 8: Fix WorldHistory Universal Helper (Medium Priority) [COMPLETE: 2025-12-XX]
```

b) **Update Status Summary**:
```markdown
## Status Summary

- **High Priority**: 4/4 tasks complete (100%)
- **Medium Priority**: 4/4 tasks complete (100%)
- **Low Priority**: 0/3 tasks complete (0%)
- **Overall**: 8/11 tasks complete (73%)
```

c) **Update Sorry Placeholder Resolution**:
```markdown
## Sorry Placeholder Resolution

**Current**: 22 sorry placeholders (down from 41 at start)
**Resolved**: 19 sorry placeholders removed

Breakdown of resolved sorry:
- Propositional helpers (Task 2): 2 sorry removed (lines 88, 139 in Perpetuity.lean)
- Perpetuity P4-P6 (Task 6): 3 sorry removed (lines 225, 252, 280 in Perpetuity.lean)
- Soundness proofs (Task 5): 15 sorry removed (Soundness.lean)
- WorldHistory fix (Task 8): 1 sorry removed (WorldHistory.lean line 75)

**Remaining**: 22 sorry placeholders
- ProofSearch.lean: 3 sorry (deferred to post-MVP)
- Completeness.lean: 11 axiom declarations (Task 9 target)
- Tactics.lean: 8 tactic stubs (Task 7 partial completion)
```

d) **Add completion date to Task 6 entry**:
```markdown
### Task 6: Complete Perpetuity Proofs ✓ [COMPLETE: 2025-12-XX]

**Status**: Complete
**Priority**: Medium
**Effort**: 20-30 hours (Actual: XX hours)
**Dependencies**: Task 2 (Add Propositional Axioms K and S)

**Objective**: Complete perpetuity principle proofs P4-P6 using propositional infrastructure from Task 2

**Completed Work**:
- ✓ Modal-temporal interaction lemmas developed
- ✓ P4 (`◇▽φ → ◇φ`) proven using contraposition
- ✓ P5 (`◇▽φ → △◇φ`) proven using modal-temporal interaction
- ✓ P6 (`▽□φ → □△φ`) proven using TF axiom and modal reasoning
- ✓ Comprehensive test suite (21 test cases)
- ✓ Documentation updated

**Sorry Removed**: 3 (Perpetuity.lean lines 225, 252, 280)
```

#### 2. Update IMPLEMENTATION_STATUS.md

**File**: `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`

**Changes**:

a) **Update Theorems Package section**:
```markdown
## Theorems Package

**Status**: `[COMPLETE]` ✓

All theorem modules fully implemented with comprehensive tests.

### Perpetuity.lean
- **Status**: Complete (6/6 principles proven)
- **Lines of Code**: 330
- **Test Coverage**: 100%
- **Sorry Count**: 0 (was 3, now 0)
- **Description**: Perpetuity principles connecting modal and temporal operators
- **Principles**:
  - `P1` (`□φ → △φ`): Necessary implies always - **Complete** (uses imp_trans)
  - `P2` (`▽φ → ◇φ`): Sometimes implies possible - **Complete** (uses contraposition)
  - `P3` (`□φ → □△φ`): Necessity of perpetuity - **Complete** (direct axiom)
  - `P4` (`◇▽φ → ◇φ`): Possibility of occurrence - **Complete** (contraposition of P3)
  - `P5` (`◇▽φ → △◇φ`): Persistent possibility - **Complete** (modal-temporal interaction)
  - `P6` (`▽□φ → □△φ`): Occurrent necessity is perpetual - **Complete** (TF axiom + modal reasoning)
- **Modal-Temporal Interaction Lemmas**: 4 helper lemmas for P4-P6 proofs

**Package Verification**:
```bash
# All Theorems tests pass
lake test LogosTest.Theorems.PerpetuityTest

# Verify zero sorry in Perpetuity.lean
grep -c "sorry" Logos/Theorems/Perpetuity.lean  # Expected: 0
```
```

b) **Update Quick Summary**:
```markdown
## Overview

Logos has completed its MVP phase with a functional implementation of the TM bimodal logic proof system. This document provides module-by-module status tracking with accurate accounting of completed vs. partial vs. planned work.

**Quick Summary**:
- **Completed Modules**: 6/8 (75%) (was 5/8)
- **Partial Modules**: 1/8 (13%) (was 2/8)
- **Infrastructure Only**: 1/8 (13%)
- **Planned Extensions**: Layer 1, 2, 3 (future work)
```

#### 3. Update KNOWN_LIMITATIONS.md

**File**: `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`

**Changes**:

a) **Remove P4-P6 workarounds** from Perpetuity section:

Remove:
```markdown
### Perpetuity Principles (Theorems/Perpetuity.lean)

**Gap**: P4, P5, P6 principles incomplete (3 sorry)

**Lines**: 225 (P4), 252 (P5), 280 (P6)

**Status**: Partial implementation (P1-P3 complete or use propositional helpers with sorry)

**Explanation**:
- P4 (`◇▽φ → ◇φ`): Requires propositional reasoning about complex nested formulas
- P5 (`◇▽φ → △◇φ`): Requires complex modal-temporal interaction lemmas
- P6 (`▽□φ → □△φ`): Requires complex modal-temporal interaction lemmas

**Workarounds**:
1. **Use P1, P2, P3 only**: These principles are complete (P3) or use helpers that will be fixed in Task 2
2. **Manual derivation**: For P4-P6, construct derivations manually using TM axioms
3. **Await Task 6**: Phase 2 of TODO plan addresses P4-P6 completion

**Timeline**: Task 6 estimated 20-30 hours after Task 2 completion
```

Add instead:
```markdown
### Perpetuity Principles (Theorems/Perpetuity.lean)

**Status**: `[COMPLETE]` ✓ - All 6 perpetuity principles fully proven

All perpetuity principles (P1-P6) are now complete with zero sorry placeholders:
- P1 (`□φ → △φ`): Complete (uses proven `imp_trans` helper)
- P2 (`▽φ → ◇φ`): Complete (uses proven `contraposition` helper)
- P3 (`□φ → □△φ`): Complete (direct MF axiom application)
- P4 (`◇▽φ → ◇φ`): Complete (contraposition of P3 for `¬φ`)
- P5 (`◇▽φ → △◇φ`): Complete (modal-temporal interaction lemmas)
- P6 (`▽□φ → □△φ`): Complete (TF axiom with modal reasoning)

**Verification**:
```bash
grep -n "sorry" Logos/Theorems/Perpetuity.lean  # Expected: 0 matches
lake test LogosTest.Theorems.PerpetuityTest    # Expected: all pass
```
```

b) **Update Section 1 summary** to reflect zero gaps in Theorems:
```markdown
## 1. Metalogic Gaps

**Overview**: Metalogic modules (Soundness, Completeness, Decidability) have partial or planned implementations.

**Modules Affected**:
- Soundness.lean: 0 sorry (was 15, now complete)
- Completeness.lean: 11 axiom declarations (planned for Task 9)
- Decidability.lean: Missing file (planned for Task 10)
- **Perpetuity.lean**: 0 sorry (was 3, now complete) ✓
```

#### 4. Verification Commands

**File**: Create `scripts/verify_task6_completion.sh`

```bash
#!/bin/bash
# Verification script for Task 6 completion

echo "=== Task 6 Completion Verification ==="
echo ""

# 1. Verify zero sorry in Perpetuity.lean
echo "1. Checking sorry count in Perpetuity.lean..."
SORRY_COUNT=$(grep -c "sorry" Logos/Theorems/Perpetuity.lean)
if [ "$SORRY_COUNT" -eq 0 ]; then
  echo "   ✓ Zero sorry placeholders (expected: 0, actual: $SORRY_COUNT)"
else
  echo "   ✗ FAIL: Sorry placeholders found (expected: 0, actual: $SORRY_COUNT)"
  exit 1
fi
echo ""

# 2. Verify all 6 perpetuity theorems defined
echo "2. Checking all 6 perpetuity theorems defined..."
for i in 1 2 3 4 5 6; do
  if grep -q "theorem perpetuity_$i" Logos/Theorems/Perpetuity.lean; then
    echo "   ✓ P$i defined"
  else
    echo "   ✗ FAIL: P$i not found"
    exit 1
  fi
done
echo ""

# 3. Run perpetuity tests
echo "3. Running perpetuity test suite..."
if lake test LogosTest.Theorems.PerpetuityTest; then
  echo "   ✓ All perpetuity tests pass"
else
  echo "   ✗ FAIL: Perpetuity tests failed"
  exit 1
fi
echo ""

# 4. Verify documentation updated
echo "4. Checking documentation updates..."
if grep -q "Task 6.*COMPLETE" TODO.md; then
  echo "   ✓ TODO.md updated"
else
  echo "   ✗ FAIL: TODO.md not updated"
  exit 1
fi

if grep -q "Perpetuity.lean.*Complete" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md; then
  echo "   ✓ IMPLEMENTATION_STATUS.md updated"
else
  echo "   ✗ FAIL: IMPLEMENTATION_STATUS.md not updated"
  exit 1
fi
echo ""

# 5. Overall sorry count check
echo "5. Checking overall sorry count..."
TOTAL_SORRY=$(grep -r "sorry" Logos/ --include="*.lean" | wc -l)
echo "   Total sorry count: $TOTAL_SORRY (expected: ≤22)"
if [ "$TOTAL_SORRY" -le 22 ]; then
  echo "   ✓ Sorry count acceptable"
else
  echo "   ⚠ Warning: Sorry count higher than expected"
fi
echo ""

echo "=== Task 6 Verification Complete ==="
exit 0
```

Make executable:
```bash
chmod +x scripts/verify_task6_completion.sh
```

**Acceptance Criteria**:
- [ ] TODO.md updated with Task 6 completion
- [ ] TODO.md Status Summary shows 8/11 complete (73%)
- [ ] TODO.md Sorry Registry shows 22 remaining (19 resolved)
- [ ] IMPLEMENTATION_STATUS.md shows Perpetuity 100% complete
- [ ] KNOWN_LIMITATIONS.md removes P4-P6 workarounds
- [ ] Verification script passes all checks

**Time Estimate**: 1-2 hours (documentation updates, verification script)

---

## Phase Success Criteria

**Before marking Phase 2 complete, verify ALL criteria met**:

### Code Completion
- [ ] Zero sorry in Perpetuity.lean (lines 225, 252, 280 removed)
- [ ] All 6 perpetuity principles proven (P1-P6)
- [ ] 4+ modal-temporal interaction lemmas implemented
- [ ] All proofs use Phase 1 propositional helpers (imp_trans, contraposition)

### Testing
- [ ] Perpetuity test suite passes (21+ test cases)
- [ ] Integration tests verify P4-P5-P6 compatibility
- [ ] `lake test LogosTest.Theorems.PerpetuityTest` returns zero failures
- [ ] `lake build` succeeds with zero errors

### Documentation
- [ ] TODO.md marks Task 6 complete with completion date
- [ ] TODO.md Sorry Registry updated (22 remaining, 19 resolved)
- [ ] IMPLEMENTATION_STATUS.md shows Perpetuity 100% complete
- [ ] KNOWN_LIMITATIONS.md removes P4-P6 workarounds
- [ ] Verification script passes all checks

### Quality Standards
- [ ] All proofs have docstrings explaining derivation strategy
- [ ] Type expansions are explicit and documented
- [ ] Modal-temporal interaction lemmas have semantic justification
- [ ] Code follows LEAN 4 style guide (2-space indent, 100-char lines)
- [ ] Zero #lint warnings in Perpetuity.lean

## Verification Commands

**Run these commands to verify phase completion**:

```bash
# 1. Verify zero sorry in Perpetuity.lean
grep -n "sorry" Logos/Theorems/Perpetuity.lean
# Expected: no output

# 2. Verify all 6 perpetuity theorems proven
grep -n "theorem perpetuity_[1-6]" Logos/Theorems/Perpetuity.lean
# Expected: 6 matches

# 3. Run perpetuity tests
lake test LogosTest.Theorems.PerpetuityTest
# Expected: all tests pass

# 4. Check overall sorry count
grep -r "sorry" Logos/ --include="*.lean" | wc -l
# Expected: 22 (down from 25 before Phase 2)

# 5. Run verification script
bash scripts/verify_task6_completion.sh
# Expected: exit 0 (all checks pass)

# 6. Build project
lake build
# Expected: clean build, zero errors

# 7. Run lint
lake lint Logos/Theorems/Perpetuity.lean
# Expected: zero warnings
```

## Troubleshooting

### Common Issues

**Issue 1: Type unfolding mismatch in P4 proof**
```
Error: type mismatch
  contraposition hP3_neg
has type
  ⊢ (φ.neg.always.box).neg.imp φ.neg.box.neg : Prop
but is expected to have type
  ⊢ φ.sometimes.diamond.imp φ.diamond : Prop
```

**Solution**: Use explicit type conversion lemmas:
```lean
lemma sometimes_diamond_eq (φ : Formula) :
    φ.sometimes.diamond = (φ.neg.always.box).neg := by
  simp [Formula.sometimes, Formula.diamond, Formula.always]
  rfl
```

**Issue 2: Modal-temporal interaction lemmas too complex**
```
Error: Cannot find instance for modal K rule application
```

**Solution**: Break down lemma into smaller steps:
```lean
-- Instead of one complex lemma:
theorem complex_interaction : ⊢ A.imp B := sorry

-- Use intermediate steps:
theorem step1 : ⊢ A.imp C := ...
theorem step2 : ⊢ C.imp B := ...
theorem complex_interaction : ⊢ A.imp B := imp_trans step1 step2
```

**Issue 3: P6 proof requires frame properties**
```
Error: Cannot derive ▽□φ → □△φ without temporal frame constraints
```

**Solution Options**:
1. Add frame property as axiom with semantic justification
2. Prove under restricted frame conditions
3. Document as conjecture with evidence from semantic models

### Getting Help

If stuck during Phase 2 implementation:

1. **Review TM axioms**: Consult `Logos/ProofSystem/Axioms.lean` for MF, TF, MT axioms
2. **Check semantic definitions**: Review `Logos/Semantics/Truth.lean` for operator semantics
3. **Examine P1-P3 proofs**: Use completed principles as templates
4. **Consult ARCHITECTURE.md**: Review TM logic specification
5. **Run verification commands**: Use verification script to identify specific failures

## References

- **Parent Plan**: [TODO Implementation Systematic Plan](../plans/001-research-todo-implementation-plan.md)
- **Phase 1**: [Wave 1 High Priority Foundations](./phase_1_wave1_high_priority_foundations.md)
- **Perpetuity.lean**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Theorems/Perpetuity.lean`
- **Axioms.lean**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Axioms.lean`
- **ARCHITECTURE.md**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide/ARCHITECTURE.md`
- **LEAN Style Guide**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/Development/LEAN_STYLE_GUIDE.md`

---

**Phase 2 Completion Signal**: When all success criteria are met, run:

```bash
bash scripts/verify_task6_completion.sh && echo "PHASE_2_COMPLETE"
```

Expected output: All verification checks pass, followed by `PHASE_2_COMPLETE` signal.
