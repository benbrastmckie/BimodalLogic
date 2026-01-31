# Research Report: Migrate efq to efq_neg

**Task**: 786
**Date**: 2026-01-31
**Session ID**: sess_1769895356_4dab83

## Executive Summary

The `efq` function is deprecated (since 2025-12-14) and should be replaced with `efq_neg`. Both functions have identical type signatures and the replacement is a direct drop-in substitution.

## Findings

### 1. Definition Analysis

Both `efq` and `efq_neg` are defined in `Theories/Bimodal/Theorems/Propositional.lean`:

**efq_neg (Primary Definition)** - Lines 359-370:
```lean
def efq_neg (A B : Formula) : ⊢ A.neg.imp (A.imp B) := by
  -- Goal: ¬A → (A → B)
  -- We have RAA: A → (¬A → B)
  -- Apply theorem_flip
  have raa_inst : ⊢ A.imp (A.neg.imp B) := raa A B
  have flip_inst : ⊢ (A.imp (A.neg.imp B)).imp (A.neg.imp (A.imp B)) :=
    @theorem_flip A A.neg B
  exact DerivationTree.modus_ponens [] _ _ flip_inst raa_inst
```

**efq (Deprecated Alias)** - Lines 377-378:
```lean
@[deprecated efq_neg (since := "2025-12-14")]
def efq (A B : Formula) : ⊢ A.neg.imp (A.imp B) := efq_neg A B
```

### 2. Type Signatures

Both functions have **identical type signatures**:
```lean
(A B : Formula) : ⊢ A.neg.imp (A.imp B)
```

This proves "Ex Falso Quodlibet" - from the negation of A, we can derive that A implies B (because if we have ¬A and A, we have a contradiction, from which anything follows).

### 3. Usage Locations

**Line 402** - In `ldi` (Left Disjunction Introduction):
```lean
have efq_inst : ⊢ A.neg.imp (A.imp B) :=
  efq A B
```

**Line 596** - In conjunction elimination proof:
```lean
have efq_helper : ⊢ A.neg.imp (A.imp B.neg) :=
  efq A B.neg
```

### 4. Replacement Pattern

The replacement is straightforward since the types are identical:

| Location | Current | Replacement |
|----------|---------|-------------|
| Line 402 | `efq A B` | `efq_neg A B` |
| Line 596 | `efq A B.neg` | `efq_neg A B.neg` |

## Implementation Recommendation

This is a simple text substitution task:

1. Replace `efq A B` with `efq_neg A B` at line 402
2. Replace `efq A B.neg` with `efq_neg A B.neg` at line 596

No changes to the proof logic are needed - only the function name changes.

## Verification

After making the changes:
1. Run `lake build` to confirm the deprecation warnings are resolved
2. Verify no new errors are introduced

## Risk Assessment

**Risk Level**: Very Low

- Both functions have identical semantics (efq is literally defined as `efq_neg`)
- No type changes or argument order changes
- The deprecation attribute confirms this is the intended migration path

## Conclusion

The migration from `efq` to `efq_neg` is a straightforward renaming. The `efq_neg` name better describes the function's behavior (it involves negation in its logical form: ¬A → (A → B)).
