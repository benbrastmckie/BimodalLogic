# Research Report: Task #369

**Task**: Solve the blocking dependency in the Modal 5 theorem
**Date**: 2026-01-11
**Focus**: Understanding the "Modal 5 theorem blocking dependency" issue

## Summary

The "Modal 5 theorem blocking dependency" refers to `diamond_mono_imp` (`⊢ (φ → ψ) → (◇φ → ◇ψ)`) in `Bimodal/Theorems/ModalS5.lean:91-94` which contains a `sorry`. This is **NOT a bug but a documented theoretical limitation** - the theorem is semantically invalid in modal logic and CANNOT be proven. The working alternative `k_dist_diamond` (`⊢ □(A → B) → (◇A → ◇B)`) is already fully proven.

## Findings

### 1. The "Blocking Dependency" is a Documented Invalid Theorem

The theorem `diamond_mono_imp` at ModalS5.lean:91-94:
```lean
def diamond_mono_imp (φ ψ : Formula) : ⊢ (φ.imp ψ).imp (φ.diamond.imp ψ.diamond) := by
  -- NOT DERIVABLE as object-level theorem - see docstring
  -- This theorem is included with sorry to document the blocking dependency
  sorry
```

**Key insight**: This sorry is **intentional and correct**. The docstring (lines 71-89) explains:
- The theorem `(φ → ψ) → (◇φ → ◇ψ)` is NOT VALID as an object-level implication in modal logic
- A counter-model is provided: S5 with worlds w0, w1 where A is true everywhere but B is true only at w0
- The meta-rule `diamond_mono` (if `⊢ φ → ψ` then `⊢ ◇φ → ◇ψ`) IS valid, but the implication form is not

### 2. Confusion with Other "Modal 5" Definitions

There are multiple things called "Modal 5" in the codebase:
1. **`modal_5`** in Perpetuity/Principles.lean:331 - `◇φ → □◇φ` (S5 characteristic axiom) - **FULLY PROVEN**
2. **`modal_5_collapse`** axiom - `◇□φ → □φ` - **Axiom in the system**
3. **`diamond_mono_imp`** - `(φ → ψ) → (◇φ → ◇ψ)` - **INVALID theorem (cannot be proven)**

### 3. The Alternative Solution Already Exists

`k_dist_diamond` at ModalS5.lean:316-365 provides the valid form:
```lean
def k_dist_diamond (A B : Formula) : ⊢ (A.imp B).box.imp (A.diamond.imp B.diamond)
```

This theorem `□(A → B) → (◇A → ◇B)` is **fully proven** with no sorry. It works because:
- The implication `A → B` must be NECESSARY (boxed)
- This ensures the implication holds at ALL worlds, not just the current one

### 4. Nothing Currently Depends on the Invalid Theorem

Only one definition uses `diamond_mono_imp`:
- `diamond_mono_conditional` at ModalS5.lean:101-104 (also blocked)

Neither is used anywhere else in the codebase. They exist as documentation of the theoretical limitation.

### 5. SORRY_REGISTRY Already Documents This

The sorry is properly documented in `docs/ProjectInfo/SORRY_REGISTRY.md`:
- Lines 107-122 explain the fundamental limitation
- Status is marked as "DOCUMENTED AS INVALID - intentional sorry"
- Alternative guidance points to `k_dist_diamond`

## Recommendations

### Option A: Remove the Invalid Theorems (Recommended)

Since `diamond_mono_imp` and `diamond_mono_conditional` are:
1. Semantically invalid (cannot be proven)
2. Not used anywhere in the codebase
3. Already documented in SORRY_REGISTRY

They should be removed entirely to eliminate the sorry warning and confusion. The documentation in the code can be preserved as a comment or moved to documentation files.

### Option B: Keep as Documentation

If the sorry is kept for educational purposes, it should be:
1. Renamed to clearly indicate it's invalid (e.g., `diamond_mono_imp_INVALID`)
2. Moved to an `Examples/` or `docs/` file
3. Clearly marked with a `#guard_msgs` or similar annotation

### Option C: No Action Needed

If this task was created based on a misunderstanding of the issue, it can be closed as:
- The "blocking dependency" is actually working as intended
- The true Modal 5 theorem (`◇φ → □◇φ`) is fully proven
- The alternative `k_dist_diamond` provides the valid form of diamond monotonicity

## References

- `Bimodal/Theorems/ModalS5.lean:71-105` - Diamond monotonicity discussion with counter-model
- `Bimodal/Theorems/ModalS5.lean:316-365` - `k_dist_diamond` implementation
- `Bimodal/Theorems/Perpetuity/Principles.lean:331-352` - `modal_5` implementation
- `docs/ProjectInfo/SORRY_REGISTRY.md:107-127` - Sorry documentation
- `.claude/specs/reviews/review-20260110-bimodal-mvp.md:65-69` - Review mentioning this issue

## Next Steps

1. **Clarify intent**: Is the goal to:
   a. Remove the invalid theorems and their sorry? (Recommended)
   b. Find an alternative proof approach? (Not possible - theorem is invalid)
   c. Document the limitation more clearly? (Already done)

2. **If removing**: Delete lines 91-104 from ModalS5.lean and update SORRY_REGISTRY

3. **If keeping**: No code changes needed - the current implementation correctly documents the theoretical limitation
