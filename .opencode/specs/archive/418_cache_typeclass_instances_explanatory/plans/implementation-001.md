# Implementation Plan: Task #418

**Task**: Cache typeclass instances in Explanatory
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

This plan implements `CompleteLattice` instance caching to reduce typeclass inference overhead in the Explanatory module. The approach uses Lean 4's `letI` construct to cache the `CompleteLattice M.frame.State` instance at the top level of `truthAt` and related functions, preventing repeated inference during recursive calls.

Per research-002.md, the `LinearOrderedAddCommGroup T` hierarchy was already addressed by task 420. This plan focuses exclusively on `CompleteLattice State` caching.

## Phases

### Phase 1: Cache CompleteLattice in truthAt

**Status**: [COMPLETED]

**Objectives**:
1. Add `letI` caching for `CompleteLattice` inside `truthAt` definition
2. Verify the module still compiles
3. Verify no regressions in dependent code

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Truth.lean` - add `letI` inside `truthAt`

**Steps**:
1. Read current `truthAt` definition (line 102-186)
2. Add `letI := M.frame.toConstitutiveFrame.lattice` at the start of the function body, before the `match`
3. The modified structure should be:
   ```lean
   @[irreducible]
   def truthAt (M : CoreModel T) (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
       (σ : VarAssignment M.frame.toConstitutiveFrame) (idx : TemporalIndex T)
       : Formula → Prop :=
     letI := M.frame.toConstitutiveFrame.lattice
     fun φ => match φ with
     | Formula.cfml c => ...
   ```
4. Run `lake build Theories.Logos.SubTheories.Explanatory.Truth` to verify

**Verification**:
- `lake build` succeeds without errors
- No new warnings introduced
- `lean_diagnostic_messages` returns empty

---

### Phase 2: Cache in validInModel and entailsInModel

**Status**: [COMPLETED]

**Objectives**:
1. Add `letI` caching in `validInModel` before the quantifier
2. Add `letI` caching in `entailsInModel` before the quantifier
3. Verify compilation

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Truth.lean` - modify `validInModel` (line 203) and `entailsInModel` (line 211)

**Steps**:
1. Modify `validInModel` to cache before quantifier:
   ```lean
   def validInModel (M : CoreModel T) (φ : Formula) : Prop :=
     letI := M.frame.toConstitutiveFrame.lattice
     ∀ (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
       (σ : VarAssignment M.frame.toConstitutiveFrame),
       truthAt M τ t ht σ TemporalIndex.empty φ
   ```
2. Modify `entailsInModel` similarly:
   ```lean
   def entailsInModel (M : CoreModel T) (Γ : List Formula) (φ : Formula) : Prop :=
     letI := M.frame.toConstitutiveFrame.lattice
     ∀ (τ : WorldHistory M.frame) ...
   ```
3. Run `lake build` to verify

**Verification**:
- Build succeeds
- No regressions in any dependent files

---

### Phase 3: Verify and Benchmark

**Status**: [COMPLETED]

**Objectives**:
1. Run full project build to ensure no regressions
2. Compare build times before/after (optional benchmarking)
3. Document results

**Files to modify**:
- None (verification only)

**Steps**:
1. Run `lake clean` to clear cache
2. Run `time lake build` and record build time
3. Compare with baseline (if available from task 420)
4. Optionally enable `set_option trace.Meta.synthInstance true` on a test file to verify reduced inference
5. Document findings in implementation summary

**Verification**:
- Full project build succeeds
- No new errors or warnings
- Build time comparable or improved

---

## Dependencies

- Task 416 (quick performance fixes) - COMPLETED
- Task 420 (Mathlib upgrade with unbundling) - COMPLETED
- Current Mathlib version: v4.27.0-rc1

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `letI` causes elaboration issues | Medium | Low | Revert to explicit parameter approach |
| Breaks downstream proofs | Medium | Low | Run full build, check all files |
| Performance improvement negligible | Low | Medium | Document findings anyway |

## Success Criteria

- [ ] `truthAt` has `letI` caching for `CompleteLattice`
- [ ] `validInModel` has `letI` caching
- [ ] `entailsInModel` has `letI` caching
- [ ] Full project builds without errors
- [ ] No regressions in dependent modules

## Rollback Plan

If caching causes issues:
1. Revert the `letI` additions
2. Consider alternative: explicit instance parameter with default value
3. Document why the approach didn't work
