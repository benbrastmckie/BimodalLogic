# GitHub Issue: Derivable.height Compilation Blocker

**Title**: Critical: Derivable.height function fails to compile due to Lean 4 termination checker

**Labels**: bug, high-priority, blocked

---

## Problem Summary

The `Derivable.height` function in `Logos/Core/Metalogic/DeductionTheorem.lean` cannot be defined due to Lean 4's termination checker limitations and namespace restrictions. This blocks the deduction theorem from compiling, which in turn blocks Task 42 (Proof Automation Completion).

## Current Status

- **File**: `Logos/Core/Metalogic/DeductionTheorem.lean`
- **Broken Since**: Initial commit (bc8895e) - file has never successfully compiled
- **Impact**: HIGH - blocks deduction theorem, which blocks `future_k_dist` derivation (Task 42 Phase 2)

## Technical Details

### The Problem

The `height` function needs to be defined recursively on the `Derivable` inductive type:

```lean
def Derivable.height {Γ : Context} {φ : Formula} : Derivable Γ φ → Nat
  | Derivable.axiom _ _ _ => 0
  | Derivable.assumption _ _ _ => 0
  | Derivable.modus_ponens _ _ _ d1 d2 => max d1.height d2.height + 1
  | Derivable.necessitation _ d => d.height + 1
  | Derivable.temporal_necessitation _ d => d.height + 1
  | Derivable.temporal_duality _ d => d.height + 1
  | Derivable.weakening _ _ _ d _ => d.height + 1
```

### Error Messages

```
error: invalid field 'height', the environment does not contain 'Logos.Core.ProofSystem.Derivable.height'
```

### Root Causes

1. **Termination Checker**: Lean 4 cannot automatically prove termination for this recursion
2. **Missing sizeOf Instance**: `Derivable` type lacks a `sizeOf` instance for well-founded recursion
3. **Cross-Module Extension**: Cannot add fields to `Derivable` from `DeductionTheorem.lean` (different module)

## Attempted Solutions (All Failed)

1. ✗ Fixed pattern matching syntax (`.axiom` → `Derivable.axiom`)
2. ✗ Changed `ℕ` to `Nat`
3. ✗ Added `decreasing_by` clause
4. ✗ Used `partial def` (can't be used in proofs)
5. ✗ Used `match` syntax instead of pattern matching
6. ✗ Used `unsafe def` with `@[implemented_by]`
7. ✗ Axiomatized `height` and moved outside namespace
8. ✗ Moved axioms before namespace declaration

All approaches fail because:
- Lean 4 doesn't recognize the recursion as structural
- Cannot extend `Derivable` from a different module
- Axiomatizing doesn't work due to namespace/module boundaries

## Proposed Solution

### Option 1: Move to Derivation.lean (Recommended)

Move the `height` function and its properties to `Logos/Core/ProofSystem/Derivation.lean` where `Derivable` is defined:

```lean
-- In Derivation.lean, after Derivable definition
def Derivable.height {Γ : Context} {φ : Formula} : Derivable Γ φ → Nat
  | .axiom _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => max d1.height d2.height + 1
  | .necessitation _ d => d.height + 1
  | .temporal_necessitation _ d => d.height + 1
  | .temporal_duality _ d => d.height + 1
  | .weakening _ _ _ d _ => d.height + 1
```

**Pros**:
- Structural recursion should be recognized automatically
- Proper location for type extensions
- Clean solution

**Cons**:
- Requires modifying core ProofSystem module
- May need to add height property theorems there too

### Option 2: Add sizeOf Instance

Add a proper `sizeOf` instance for `Derivable` in `Derivation.lean`:

```lean
instance : SizeOf (Derivable Γ φ) where
  sizeOf d := match d with
    | .axiom _ _ _ => 0
    | .assumption _ _ _ => 0
    | .modus_ponens _ _ _ d1 d2 => 1 + sizeOf d1 + sizeOf d2
    | .necessitation _ d => 1 + sizeOf d
    | .temporal_necessitation _ d => 1 + sizeOf d
    | .temporal_duality _ d => 1 + sizeOf d
    | .weakening _ _ _ d _ => 1 + sizeOf d
```

Then use `termination_by sizeOf d` in `DeductionTheorem.lean`.

**Pros**:
- Enables well-founded recursion
- Standard Lean 4 approach

**Cons**:
- Still requires modifying `Derivation.lean`
- More complex than Option 1

### Option 3: Keep Axiomatized (Temporary Workaround)

Keep `height` and its properties as axioms until a proper solution is implemented.

**Pros**:
- Allows development to continue
- No changes to core modules

**Cons**:
- Unsound (axioms without proofs)
- Not a real solution
- Increases technical debt

## Recommended Action Plan

1. **Implement Option 1** (move to Derivation.lean)
2. Add `height` function to `Derivation.lean` after `Derivable` definition
3. Add height property theorems (`weakening_height_succ`, `mp_height_gt_left`, etc.)
4. Update `DeductionTheorem.lean` to use the properly defined `height`
5. Verify `lake build` succeeds
6. Run `lake test` to ensure no regressions

## Dependencies

- **Blocks**: Task 42 Phase 2 (Temporal Axiom Derivation)
- **Blocks**: `future_k_dist` theorem derivation
- **Blocks**: `always_mono` theorem derivation
- **Related**: Task 46 (Deduction Theorem) - marked complete but file doesn't compile

## Files Affected

- `Logos/Core/ProofSystem/Derivation.lean` (needs modification)
- `Logos/Core/Metalogic/DeductionTheorem.lean` (currently broken)

## Testing

After fix:
```bash
lake build Logos.Core.Metalogic.DeductionTheorem
lake build Logos.Core.Theorems.Perpetuity.Principles
lake test
```

## References

- Task 42: Proof Automation Completion
- Plan 065: `.claude/specs/065_proof_automation_temporal_deduction/`
- Deduction Theorem: `Logos/Core/Metalogic/DeductionTheorem.lean`
- Issue Template: `.claude/specs/065_proof_automation_temporal_deduction/GITHUB_ISSUE_DERIVABLE_HEIGHT.md`

## Priority

**HIGH** - Blocks critical path for Layer 0 completion (axiom reduction by 4)

---

## Instructions for Creating Issue

1. Go to https://github.com/benbrastmckie/ProofChecker/issues/new
2. Copy the title and content above
3. Add labels: `bug`, `high-priority`, `blocked`
4. Submit the issue
5. Copy the issue URL (e.g., `https://github.com/benbrastmckie/ProofChecker/issues/123`)
6. Update TODO.md Task 48 with the issue URL
