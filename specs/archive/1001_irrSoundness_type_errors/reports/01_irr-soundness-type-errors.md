# Research Report: IRRSoundness.lean Type Errors

**Task**: 1001 - irrSoundness_type_errors
**Date**: 2026-03-19
**Status**: RESEARCHED

## Executive Summary

The `IRRSoundness.lean` file has two classes of errors blocking compilation:

1. **String vs Atom type mismatch**: The code uses `String` for atom variables where `Atom` is now required (6 locations)
2. **Omega tactic failures**: The `omega` tactic cannot handle generic ordered groups (5 locations)

Both are straightforward to fix with well-defined replacement patterns.

## Error Analysis

### Build Output Summary

```
lake build Bimodal.Metalogic.IRRSoundness
```

Produces 15+ errors:
- 6 type mismatches (`String` vs `Atom`)
- 5 omega failures on generic `[AddCommGroup D] [LinearOrder D]` type
- Secondary errors from simp failures (cascade from above)

### Error Class 1: String vs Atom Type Mismatch

**Root Cause**: The Atom type was refactored from `String` to a structured type with freshness support (Task 964). The `IRRSoundness.lean` file was written before this refactoring and still uses `String` in several places.

**Locations Requiring Changes**:

| Line | Current | Required | Context |
|------|---------|----------|---------|
| 55 | `q : String` | `q : Atom` | `truth_independent_of_valuation_change` hypothesis |
| 56 | `M1.valuation s q` | (already correct once q is Atom) | Same function |
| 179 | `p : String` | `p : Atom` | `prod_model` definition |
| 215 | `p : String` | `p : Atom` | `truth_prod_iff` hypothesis |
| 285 | `p : String` | `p : Atom` | `irr_sound_dense_at_domain` hypothesis |

**Evidence**:
- `TaskModel.valuation` signature is `F.WorldState -> Atom -> Prop` (TaskModel.lean:49)
- `Formula.atoms` returns `Finset Atom` (Formula.lean:491)
- `Formula.atom` constructor takes `Atom` (Formula.lean:68)

**Fix Pattern**:
```lean
-- Before:
(h_agree : forall (s : F.WorldState) (q : String), q ∈ phi.atoms -> ...)

-- After:
(h_agree : forall (s : F.WorldState) (q : Atom), q ∈ phi.atoms -> ...)
```

### Error Class 2: Omega Tactic Failures

**Root Cause**: The `omega` tactic only works on `Nat` and `Int`. The `prod_frame` construction operates on a generic ordered add group `D` with typeclass constraints `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

**Locations Requiring Changes**:

| Line | Goal Context | Required Lemma |
|------|--------------|----------------|
| 128 | `x > 0 -> y >= 0 -> x + y = 0 -> x = 0` | `add_eq_zero_iff_of_nonneg` + contradiction |
| 130 | `x > 0 -> y >= 0 -> y = 0` | follows from above |
| 140 | `-d = 0 -> d = 0` | `neg_eq_zero` |
| 146 | `-d = 0 -> d = 0` | `neg_eq_zero` |
| 162 | `t - s = 0 -> s = t` | `sub_eq_zero.mp` |

**Key Lemmas Found**:

1. **`add_eq_zero_iff_of_nonneg`** (Mathlib.Algebra.Order.Monoid.Unbundled.Basic)
   ```lean
   add_eq_zero_iff_of_nonneg : 0 <= a -> 0 <= b -> (a + b = 0 <-> a = 0 /\ b = 0)
   ```
   Requires: `[AddZeroClass alpha] [PartialOrder alpha] [AddLeftMono alpha] [AddRightMono alpha]`

2. **`add_pos_of_pos_of_nonneg`** (Mathlib.Algebra.Order.Monoid.Unbundled.Basic)
   ```lean
   add_pos_of_pos_of_nonneg : 0 < a -> 0 <= b -> 0 < a + b
   ```
   Used to derive contradiction: if `x > 0` and `y >= 0` and `x + y = 0`, then we have `0 < x + y` and `x + y = 0`, contradiction.

3. **`neg_eq_zero`** (Mathlib.Algebra.Group.Basic)
   ```lean
   neg_eq_zero : -a = 0 <-> a = 0
   ```
   Direct replacement for omega on negation.

4. **`sub_eq_zero`** (Mathlib.Algebra.Group.Basic, via @[to_additive] from div_eq_one)
   ```lean
   sub_eq_zero : a - b = 0 <-> a = b
   ```
   Direct replacement for omega on subtraction.

**Fix Pattern for Lines 128-130**:

```lean
-- Before (line 128-130):
have hx_eq : x = 0 := by
  by_contra h
  have : x > 0 := lt_of_le_of_ne hx (Ne.symm h)
  have : y < 0 := by omega
  exact absurd this (not_lt.mpr hy)
have hy_eq : y = 0 := by omega

-- After:
have hx_eq : x = 0 := by
  by_contra h
  have hx_pos : 0 < x := lt_of_le_of_ne hx (Ne.symm h)
  have h_sum_pos : 0 < x + y := add_pos_of_pos_of_nonneg hx_pos hy
  exact absurd h_sum.symm (ne_of_gt h_sum_pos)
have hy_eq : y = 0 := ((add_eq_zero_iff_of_nonneg hx hy).mp h_sum).2
```

**Fix Pattern for Lines 140, 146**:

```lean
-- Before:
have h_zero : d = 0 := by omega

-- After:
have h_zero : d = 0 := neg_eq_zero.mp h_neg
```

**Fix Pattern for Line 162**:

```lean
-- Before:
omega

-- After:
exact sub_eq_zero.mp h_zero
```

## Import Requirements

The fixes require these Mathlib imports (may already be present via transitive imports):

```lean
import Mathlib.Algebra.Order.Monoid.Unbundled.Basic  -- add_eq_zero_iff_of_nonneg, add_pos_of_pos_of_nonneg
import Mathlib.Algebra.Group.Basic                   -- neg_eq_zero, sub_eq_zero
```

## Typeclass Verification

The `IsOrderedAddMonoid` typeclass (used in the file) provides:
- `AddLeftMono` and `AddRightMono` (needed for `add_eq_zero_iff_of_nonneg`)
- Compatibility with `AddCommGroup` and `LinearOrder`

Confirmed via `lean_hover_info` that these instances are available.

## Implementation Complexity

- **String to Atom**: Simple find-replace in 5 locations
- **Omega replacements**: 5 proof term substitutions, each 1-3 lines

**Estimated effort**: Low (straightforward mechanical changes)

## Verification Plan

After implementing fixes:
1. `lake build Bimodal.Metalogic.IRRSoundness` should succeed
2. No new sorry markers introduced
3. All theorem statements unchanged (only proof terms modified)

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Atom.lean` - Atom type definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean` - Formula.atoms returns Finset Atom
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskModel.lean` - valuation : WorldState -> Atom -> Prop
- Mathlib.Algebra.Order.Monoid.Unbundled.Basic - add_eq_zero_iff_of_nonneg
- Mathlib.Algebra.Group.Basic - neg_eq_zero, sub_eq_zero
