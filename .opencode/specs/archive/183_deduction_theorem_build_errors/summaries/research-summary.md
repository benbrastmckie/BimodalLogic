# Research Summary: DeductionTheorem.lean Build Errors

**Project**: #183  
**Date**: 2025-12-25  
**Status**: Research Complete

## Key Findings

1. **Root Cause Identified**: All 3 build errors stem from using `(em P).elim` pattern inside `match` expressions in tactic mode. The `.elim` method is a term-mode construct, not a tactic, causing "unknown tactic" errors.

2. **Solution Pattern**: Replace `(em P).elim (fun h => ...) (fun h => ...)` with `by_cases h : P` tactic. This is the idiomatic Lean 4 pattern proven in Soundness.lean and Truth.lean.

3. **Classical Reasoning**: With `open Classical` at the top of the file, `by_cases` automatically uses `Classical.propDecidable` to provide decidability for any proposition via excluded middle.

4. **Termination Proofs**: The existing termination proofs are correct and will work once the tactic errors are fixed. No changes needed to `decreasing_by` clauses.

5. **Mathlib4 Patterns**: Research of mathlib4 confirms `by_cases` and `rcases Classical.em` are the standard patterns for classical case analysis in tactic mode.

## Most Relevant Resources

- **Soundness.lean** (line 282): Working `by_cases` pattern in Logos codebase
- **Truth.lean** (lines 789-825): Nested `by_cases` pattern in Logos codebase
- **mathlib4 CategoryTheory/Limits/Shapes/Biproducts.lean**: `rcases Classical.em` pattern
- **Lean 4 Documentation**: Classical module and `by_cases` tactic

## Recommendations

**Primary Solution**: Use `by_cases h : P` tactic
- Replace line 256: `(em (A ∈ Γ'')).elim` → `by_cases hA' : A ∈ Γ''`
- Replace line 369: `(em (Γ' = A :: Γ)).elim` → `by_cases h_eq : Γ' = A :: Γ`
- Replace line 376: `(em (A ∈ Γ')).elim` → `by_cases hA : A ∈ Γ'`
- Use `·` bullet points for case branches
- Add comments explaining classical reasoning

**Expected Outcome**: All 3 errors resolved with minimal code changes

## Full Report

See: `.opencode/specs/183_deduction_theorem_build_errors/reports/research-001.md`

## Implementation Estimate

- **Complexity**: Low (simple find-replace pattern)
- **Time**: 15-30 minutes
- **Risk**: Very low (proven pattern, no logic changes)
