# Proof Strategies Research Report: Soundness Type Mismatch Fix

## Overview

This report analyzes the proof strategies needed to fix the type mismatch errors in Soundness.lean while preserving the existing proof structure.

## Current Proof Structure

### Axiom Validity Proofs (Lines 84-450)

Each axiom validity proof follows this pattern:

```lean
theorem axiom_name_valid (φ : Formula) : ⊨ (axiom_form φ) := by
  intro F M τ t ht    -- BROKEN: Should be "intro T _ F M τ t ht"
  unfold truth_at
  intro h_premise
  -- proof body using h_premise
  exact proof_term
```

### Soundness Theorem (Lines 466-604)

The main soundness theorem uses induction on derivations:

```lean
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
  intro h_deriv
  induction h_deriv with
  | «axiom» Γ' φ' h_ax =>
    intro F M τ t ht _    -- BROKEN
    exact axiom_valid h_ax F M τ t ht    -- BROKEN: wrong args
  | @assumption Γ' φ' h_mem =>
    intro F M τ t ht h_all    -- BROKEN
    exact h_all φ' h_mem
  -- ... other cases
```

## Proof Strategy Analysis

### Strategy 1: Fix Intro Patterns

**Problem**: The `intro` patterns don't match the quantifier structure of `semantic_consequence`.

**Solution**: Add `T _` to capture the type parameter and its instance:

```lean
-- From Validity.lean:
def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    (∀ ψ ∈ Γ, truth_at M τ t ht ψ) →
    truth_at M τ t ht φ
```

**Fixed Pattern**:
```lean
intro T _ F M τ t ht h_all
--    ^-^ new: captures type and instance
```

### Strategy 2: Fix Axiom Validity Applications

**Problem**: When calling `axiom_valid h_ax F M τ t ht`, the arguments don't match the fixed signature.

After fixing axiom_valid intro patterns, the signature becomes:
```lean
axiom_valid h_ax : ∀ T [inst] F M τ t ht, truth_at M τ t ht φ
```

**Solution**: Update calls to include `T`:
```lean
exact axiom_valid h_ax T F M τ t ht
```

Or use underscore to let Lean infer:
```lean
exact axiom_valid h_ax _ F M τ t ht
```

### Strategy 3: Fix Induction Hypothesis Applications

**Problem**: The IH from derivation induction has the wrong application pattern.

Example from modal_k case:
```lean
| @modal_k Γ' φ' _ ih =>
    intro T _ F M τ t ht h_all_box_gamma
    ...
    apply ih F M σ t hs    -- BROKEN: ih needs T argument
```

**Solution**: Add `T` or `_` to IH applications:
```lean
    apply ih T F M σ t hs    -- Add T
    -- OR
    apply ih _ F M σ t hs    -- Let Lean infer
```

### Strategy 4: Preserve Proof Body Logic

**Key Insight**: The proof bodies themselves are correct - they just have incorrectly named variables. After fixing the intro patterns:

- What was `F` (bound to type) becomes correctly bound to TaskFrame
- What was `M` (bound to instance) becomes correctly bound to TaskModel
- All downstream usages like `h_box σ hs` remain valid

## Case-by-Case Fix Strategy

### Axiom Validity Lemmas (12 lemmas)

| Lemma | Line | Current Intro | Fixed Intro |
|-------|------|--------------|-------------|
| prop_k_valid | 84-89 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| prop_s_valid | 99-103 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| modal_t_valid | 114-120 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| modal_4_valid | 133-142 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| modal_b_valid | 156-178 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| modal_k_dist_valid | 191-201 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| double_negation_valid | 211-217 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| temp_4_valid | 229-239 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| temp_a_valid | 254-289 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| temp_l_valid | 311-347 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| modal_future_valid | 363-386 | `intro F M τ t ht` | `intro T _ F M τ t ht` |
| temp_future_valid | 406-429 | `intro F M τ t ht` | `intro T _ F M τ t ht` |

### Axiom_valid Helper (Line 436-450)

```lean
theorem axiom_valid {φ : Formula} : Axiom φ → ⊨ φ := by
  -- No intro needed here - pattern matching on axiom
```

This helper is correct because it delegates to individual validity lemmas.

### Soundness Theorem Cases (8 cases)

| Case | Line | Current | Fixed |
|------|------|---------|-------|
| axiom | 469-473 | `intro F M τ t ht _` | `intro T _ F M τ t ht _` + fix `axiom_valid` call |
| assumption | 475-479 | `intro F M τ t ht h_all` | `intro T _ F M τ t ht h_all` |
| modus_ponens | 481-489 | `intro F M τ t ht h_all` | `intro T _ F M τ t ht h_all` + fix IH calls |
| necessitation | 491-502 | `intro F M τ t ht _` | `intro T _ F M τ t ht _` + fix IH call |
| modal_k | 504-534 | `intro F M τ t ht h_all_box_gamma` | `intro T _ F M τ t ht h_all_box_gamma` + fix IH call |
| temporal_k | 536-566 | `intro F M τ t ht h_all_future_gamma` | `intro T _ F M τ t ht h_all_future_gamma` + fix IH call |
| temporal_duality | 568-594 | `intro F M τ t ht _` | `intro T _ F M τ t ht _` |
| weakening | 596-603 | `intro F M τ t ht h_all` | `intro T _ F M τ t ht h_all` + fix IH call |

## Findings

### Finding 1: Mechanical Fix

All fixes are mechanical - they follow the same pattern:
1. Add `T _` to intro pattern
2. Update any function applications that expect type parameter

### Finding 2: No Logic Changes Required

The proof bodies don't need logic changes - only parameter binding changes.

### Finding 3: IH Calls Need Updating

When calling induction hypotheses like `ih F M σ t hs`, add `T` or `_`:
- `ih T F M σ t hs` (explicit)
- `ih _ F M σ t hs` (inferred)

### Finding 4: WorldHistory.time_shift Calls

The time_shift related proofs (modal_future_valid, temp_future_valid) have more complex argument structures but should work once the type variable is properly bound.

## Recommendations

### Recommendation 1: Use Underscore for Instance

```lean
intro T _ F M τ t ht h_all
--      ^ underscore for LinearOrderedAddCommGroup T
```

This is cleaner than naming the instance since it's rarely used directly.

### Recommendation 2: Apply Fixes Top-to-Bottom

Fix in order:
1. Axiom validity lemmas (prop_k_valid through temp_future_valid)
2. axiom_valid helper
3. soundness theorem cases

This ensures each fix can be tested incrementally.

### Recommendation 3: Run `lake env lean` After Each Major Section

Test after:
1. First 4 axiom lemmas
2. Remaining 8 axiom lemmas
3. soundness axiom+assumption cases
4. soundness modus_ponens+necessitation cases
5. soundness modal_k+temporal_k cases
6. soundness temporal_duality+weakening cases

## Conclusion

The proof strategy is straightforward: mechanically add `T _` to all intro patterns matching `semantic_consequence` or `valid` definitions, and update function/IH applications accordingly.

Total estimated fixes:
- 12 axiom validity lemmas
- 8 soundness theorem cases
- ~20 IH/function call sites

Complexity: Low (mechanical, no logic changes)
Risk: Low (changes are localized, don't affect proof structure)
