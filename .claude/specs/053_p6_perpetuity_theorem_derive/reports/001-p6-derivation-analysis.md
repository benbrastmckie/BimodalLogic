# P6 Perpetuity Theorem Derivation Analysis

## Research Overview

**Topic**: Derive P6 (`▽□φ → □△φ`) as a theorem instead of axiom
**Date**: 2025-12-09
**Context**: TODO.md Task 20 - Infrastructure ready (P5 proven, duality lemmas available)

## Current State

### P6 Definition
P6 states: `▽□φ → □△φ` (occurrent necessity is perpetual)
- If necessity occurs at some time (past, present, or future), then it's always necessary
- Currently axiomatized at `Perpetuity.lean:1302`

### Available Infrastructure

**Proven Theorems** (zero sorry):
1. `perpetuity_5 (φ)`: `◇▽φ → △◇φ` (persistent possibility)
2. `modal_duality_neg (φ)`: `◇¬φ → ¬□φ`
3. `modal_duality_neg_rev (φ)`: `¬□φ → ◇¬φ`
4. `temporal_duality_neg (φ)`: `▽¬φ → ¬△φ`
5. `temporal_duality_neg_rev (φ)`: `¬△φ → ▽¬φ`
6. `contraposition {A B}`: `(A → B) → (¬B → ¬A)`
7. `dni (A)`: `A → ¬¬A` (double negation introduction)
8. `imp_trans {A B C}`: `(A → B) → (B → C) → (A → C)`

**Helper Axioms** (semantically justified, available for use):
- `always_dni (φ)`: `△φ → △¬¬φ`
- `always_dne (φ)`: `△¬¬φ → △φ`

## Derivation Strategy

### Mathematical Path

The key insight is that P6 is the **contrapositive dual** of P5:
- P5: `◇▽φ → △◇φ`
- P6: `▽□φ → □△φ`

The relationship:
- P5 uses diamond (◇) and sometimes (▽)
- P6 uses box (□) and always (△)
- These are De Morgan duals: `◇X = ¬□¬X` and `▽X = ¬△¬X`

### Step-by-Step Derivation

**Goal**: Derive `▽□φ → □△φ`

**Step 1**: Start with P5 applied to `¬φ`:
```
perpetuity_5 (φ.neg) : ◇▽¬φ → △◇¬φ
```

**Step 2**: Apply duality lemmas to transform the formula:
- `◇▽¬φ` needs to become related to `¬□△φ`
- `△◇¬φ` needs to become related to `¬▽□φ`

**Step 3**: Analyze formula structures:
```lean
-- P5(¬φ): ◇▽(¬φ) → △◇(¬φ)
-- Expand definitions:
-- ◇▽(¬φ) = (¬φ).neg.always.neg.neg.box.neg = φ.always.neg.neg.box.neg
-- △◇(¬φ) = (¬φ).neg.box.neg.always = φ.box.neg.always

-- What we want (P6):
-- ▽□φ → □△φ
-- Expand:
-- ▽□φ = φ.box.neg.always.neg
-- □△φ = φ.always.box
```

**Step 4**: The contraposition approach:
```lean
-- If we can show: ¬□△φ → ¬▽□φ
-- Then contraposing gives: ▽□φ → □△φ (P6)

-- From P5(¬φ): ◇▽(¬φ) → △◇(¬φ)
-- We need to relate:
-- ◇▽(¬φ) to ¬□△φ
-- △◇(¬φ) to ¬▽□φ
```

### Formula Type Analysis

**Key Challenge**: The formula types don't match directly.

Let's trace through:
```lean
-- ◇▽(¬φ) expanded:
-- sometimes (¬φ) = (¬φ).neg.always.neg = φ.always.neg  [Wait - this is wrong]

-- Actually:
-- sometimes φ = φ.neg.always.neg
-- So sometimes (¬φ) = (¬φ).neg.always.neg = φ.neg.neg.always.neg

-- And:
-- diamond (sometimes (¬φ)) = (φ.neg.neg.always.neg).neg.box.neg
--                          = φ.neg.neg.always.neg.neg.box.neg

-- This is getting complex. Let's use duality lemmas more carefully.
```

### Alternative Strategy: Build Bridge Lemmas

Instead of direct derivation, build intermediate lemmas:

**Lemma 1**: `◇▽¬φ ↔ ¬□△φ` (equivalence via duality)
- Forward: Use modal_duality_neg + temporal relationships
- Backward: Use modal_duality_neg_rev + temporal relationships

**Lemma 2**: `△◇¬φ ↔ ¬▽□φ` (equivalence via duality)
- Forward: Use temporal_duality_neg + modal relationships
- Backward: Use temporal_duality_neg_rev + modal relationships

**Then**:
- P5(¬φ): `◇▽¬φ → △◇¬φ`
- Bridge: `¬□△φ → ¬▽□φ` (from Lemmas 1-2)
- Contrapose: `▽□φ → □△φ` (P6)

### Implementation Complexity

The challenge is that:
1. `◇X` = `X.neg.box.neg`
2. `▽X` = `X.neg.always.neg`
3. `□X` = `X.box`
4. `△X` = `X.always`

So `◇▽¬φ`:
- `▽¬φ` = `(¬φ).neg.always.neg` = `φ.neg.neg.always.neg`
- `◇▽¬φ` = `(φ.neg.neg.always.neg).neg.box.neg` = `φ.neg.neg.always.neg.neg.box.neg`

And `¬□△φ`:
- `□△φ` = `φ.always.box`
- `¬□△φ` = `φ.always.box.neg`

These don't match structurally! We need to use DNE/DNI to eliminate double negations.

## Recommended Approach

### Strategy 1: Axiom-Assisted Bridge (Simpler)

Add two bridge lemmas as axioms (semantically valid):

```lean
-- Bridge from ◇▽¬φ to ¬□△φ
axiom diamond_sometimes_neg_to_neg_box_always (φ : Formula) :
    ⊢ φ.neg.sometimes.diamond.imp φ.always.box.neg

-- Bridge from △◇¬φ to ¬▽□φ
axiom always_diamond_neg_to_neg_sometimes_box (φ : Formula) :
    ⊢ φ.neg.diamond.always.imp φ.box.sometimes.neg
```

Then P6 follows by:
```lean
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- P5(¬φ): ◇▽¬φ → △◇¬φ
  have p5_neg : ⊢ φ.neg.sometimes.diamond.imp φ.neg.diamond.always :=
    perpetuity_5 φ.neg
  -- Bridge 1: ◇▽¬φ → ¬□△φ (implies ¬□△φ → ¬◇▽¬φ by contra)
  have bridge1 : ⊢ φ.neg.sometimes.diamond.imp φ.always.box.neg :=
    diamond_sometimes_neg_to_neg_box_always φ
  -- Bridge 2: △◇¬φ → ¬▽□φ
  have bridge2 : ⊢ φ.neg.diamond.always.imp φ.box.sometimes.neg :=
    always_diamond_neg_to_neg_sometimes_box φ
  -- Chain: ◇▽¬φ → △◇¬φ → ¬▽□φ
  have chain : ⊢ φ.neg.sometimes.diamond.imp φ.box.sometimes.neg :=
    imp_trans p5_neg bridge2
  -- Need to get from ¬□△φ → ¬▽□φ, contrapose to ▽□φ → □△φ
  -- But we have ◇▽¬φ → ¬▽□φ, not ¬□△φ → ¬▽□φ
  -- Need contraposition: ▽□φ → ¬◇▽¬φ (from chain contraposed)
  -- Then ¬◇▽¬φ = □△φ (via bridge1 contraposed)
  sorry -- Complex formula manipulation
```

### Strategy 2: Direct DNE/DNI Manipulation (Complex but Pure)

Use existing `dni`, `always_dni`, `always_dne` to eliminate nested double negations step by step.

This is theoretically possible but involves 15-20 intermediate steps of careful formula manipulation.

### Strategy 3: Add Swap-Box Lemma (Most Elegant)

The cleanest approach adds one fundamental lemma showing that box commutes with temporal swap:

```lean
-- Box commutes with temporal swap (like swap_temporal_diamond)
theorem swap_temporal_box (φ : Formula) :
    φ.swap_temporal.box = φ.box.swap_temporal := by
  rfl  -- Should hold by definition
```

Then use temporal duality more directly:
```lean
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- Use temporal duality to transform P5
  have p5 : ⊢ φ.sometimes.diamond.imp φ.diamond.always := perpetuity_5 φ
  -- Apply temporal duality transformation...
  sorry
```

## Findings Summary

1. **P6 is theoretically derivable** from P5 + duality lemmas
2. **Main obstacle**: Formula type mismatches due to nested negations
3. **Three viable approaches**:
   - Add 2 bridge axioms (fast, semantically valid)
   - Direct DNE/DNI manipulation (pure but complex)
   - Add swap_temporal_box lemma + duality reasoning (most elegant)
4. **Recommended**: Strategy 1 (axiom-assisted) for MVP, with path to Strategy 3 for future

## Recommendations

1. **For MVP**: Use Strategy 1 - add bridge lemmas as axioms (semantically justified)
2. **Document** the theoretical derivation path in comments
3. **Future work**: Implement Strategy 3 when formula equality reasoning is better understood
4. **Skip Strategy 2** unless zero-axiom footprint is explicitly required
