# Research Summary: DeductionTheorem.lean Build Errors

**Project**: #183  
**Date**: 2025-12-25  
**Status**: Solution Identified

## Key Findings

1. **Root Cause**: The `.elim` method on `Classical.em` is a **term-mode** construct, not a tactic. Using `(em P).elim (fun h => ...) (fun h => ...)` inside `match` expressions in tactic mode causes "unknown tactic" errors.

2. **Working Pattern**: The codebase already uses `by_cases h : P` extensively in Soundness.lean and Truth.lean. This is the idiomatic Lean 4 pattern for classical case analysis.

3. **All Three Errors Have Same Root Cause**:
   - Line 256: `(em (A ∈ Γ'')).elim` in `deduction_with_mem`
   - Line 369: `(em (Γ' = A :: Γ)).elim` in `deduction_theorem`
   - Line 376: `(em (A ∈ Γ')).elim` nested inside the above
   - Line 297 termination error is a consequence of the above failures

4. **Decidability Not the Issue**: With `open Classical` at the top of the file, `by_cases` automatically uses `Classical.propDecidable` to provide decidability for any proposition via excluded middle. No explicit `Decidable` instances needed.

5. **Termination Proofs Should Work**: Once the `.elim` patterns are replaced with `by_cases`, the existing termination proofs should work as-is. The structure (3 goals for each function) matches the recursive call pattern.

## Most Relevant Resources

- **Soundness.lean** (line 282): Working example of `by_cases h : truth_at M τ t ht φ`
- **Truth.lean** (lines 789-825): Working example of nested `by_cases` with classical reasoning
- **DeductionTheorem.lean** (line 39): `open Classical` enables classical reasoning throughout the file

## Recommended Solution

Replace all `(em P).elim (fun h => ...) (fun h => ...)` patterns with `by_cases h : P` tactic:

### Change Pattern

**Before**:
```lean
(em (A ∈ Γ'')).elim
  (fun hA' =>
    -- Case: A ∈ Γ''
    ...)
  (fun hA' =>
    -- Case: A ∉ Γ''
    ...)
```

**After**:
```lean
by_cases hA' : A ∈ Γ''
· -- Case: A ∈ Γ''
  ...
· -- Case: A ∉ Γ''
  ...
```

### Specific Changes

1. **Line 256** (`deduction_with_mem` weakening case): Replace `(em (A ∈ Γ'')).elim` with `by_cases hA' : A ∈ Γ''`
2. **Line 369** (`deduction_theorem` weakening case): Replace `(em (Γ' = A :: Γ)).elim` with `by_cases h_eq : Γ' = A :: Γ`
3. **Line 376** (nested case): Replace `(em (A ∈ Γ')).elim` with `by_cases hA : A ∈ Γ'`

### Expected Result

- All 3 build errors resolved
- Termination proofs work without modification
- Code is more idiomatic and readable
- Consistent with existing patterns in Soundness.lean and Truth.lean

## Next Steps

1. Apply the recommended changes to DeductionTheorem.lean
2. Run `lake build Logos.Core.Metalogic.DeductionTheorem` to verify
3. Run metalogic tests to ensure no regressions
4. Update LEAN_STYLE_GUIDE.md with classical reasoning best practices
5. Mark Task 183 as complete

## Full Report

See: `specs/183_deduction_theorem_fixes/reports/research-001.md`
