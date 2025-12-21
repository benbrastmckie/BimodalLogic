# Phase 1 Implementation Plan: Core Definition Migration (Derivation.lean) [COMPLETE]

**Project**: #072  
**Parent Project**: #058 (Full Migration Plan)  
**Version**: 001  
**Date**: 2025-12-19  
**Phase**: 1 of 7 [COMPLETE]
**Complexity**: COMPLEX  
**Estimated Effort**: 6-8 hours (Actual: 2 hours)
**Risk Level**: CRITICAL

---

## Task Description

**Phase 1 Goal**: Migrate `Logos/Core/ProofSystem/Derivation.lean` from `Derivable : Prop` to `DerivationTree : Type`.

This is the **critical first phase** that enables all subsequent migration work (Phases 2-7). All downstream files depend on this core definition.

**Parent Migration Context**: This phase is part of the comprehensive migration plan documented in `.opencode/specs/058_migration_to_type/plans/implementation-001.md`. See that plan for full context, dependencies, and subsequent phases.

---

## Complexity Assessment

### Phase 1 Complexity: **COMPLEX** (within CRITICAL overall migration)

**Complexity Drivers:**
1. **Core type system change** (Prop → Type fundamental change)
2. **Axiom removal** (7 height axioms → computable function + theorems)
3. **Breaking change** (all downstream files will need updates in later phases)
4. **Well-founded recursion** (height function must support termination proofs)
5. **Proof correctness** (height properties must be proven, not axiomatized)

**Estimated Effort:** 6-8 hours
- Optimistic: 6 hours (straightforward implementation, proofs work first try)
- Realistic: 7 hours (minor debugging, proof adjustments)
- Pessimistic: 8 hours (proof complications, need to refine approach)

**Confidence Level:** High (clear implementation path, well-documented in parent plan)

### Risk Assessment

| Risk Factor | Likelihood | Impact | Severity | Mitigation |
|-------------|-----------|--------|----------|------------|
| Height function bugs | 30% | MEDIUM | **MEDIUM** | Prove properties as theorems, test extensively |
| Proof failures (height theorems) | 40% | MEDIUM | **MEDIUM** | Use simp + omega as documented |
| Breaking downstream compilation | 100% | CRITICAL | **EXPECTED** | Phases 2-7 will fix downstream files |
| Performance degradation | 20% | LOW | **LOW** | Single file, minimal impact at this phase |
| Rollback difficulty | 10% | LOW | **LOW** | Git branch, single file change |

**Overall Risk Level:** **MEDIUM** - Well-understood changes, but critical file

---

## Dependencies

### Required Imports (No Changes)

Current imports in Derivation.lean:
```lean
import Logos.Core.Syntax.Formula
import Logos.Core.Syntax.Context
import Logos.Core.ProofSystem.Axioms
```

**No import changes needed** - Formula and Context are already Type.

### Prerequisites

**Before Starting Phase 1:**
1. ✅ Git branch created (`migration/derivable-to-type` or similar)
2. ✅ Backup of Derivation.lean
3. ✅ Current file compiles (baseline)
4. ✅ Parent migration plan reviewed (`.opencode/specs/058_migration_to_type/plans/implementation-001.md`)

**Expected After Phase 1:**
- ✅ Derivation.lean compiles without errors
- ✅ Zero sorry statements
- ✅ All 7 height axioms removed
- ✅ Computable height function implemented
- ✅ All 6 height properties proven as theorems
- ⚠️ **Downstream files WILL NOT compile** (expected - fixed in Phases 2-7)

### Library Functions to Use

**Pattern Matching for Height:**
```lean
def DerivationTree.height : DerivationTree Γ φ → Nat
  | axiom _ _ _ => 0
  | assumption _ _ _ => 0
  | modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | necessitation _ d => 1 + d.height
  | temporal_necessitation _ d => 1 + d.height
  | temporal_duality _ d => 1 + d.height
  | weakening _ _ _ d _ => 1 + d.height
```

**Theorem Proving (simp + omega):**
```lean
theorem mp_height_gt_left : d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega
```

---

## Implementation Steps

### **Step 1: Update Inductive Type Declaration** (1 hour)

**File**: `Logos/Core/ProofSystem/Derivation.lean`  
**Lines**: 59-138

#### Current Code (lines 59-138):
```lean
inductive Derivable : Context → Formula → Prop where
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : Derivable Γ φ
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : Derivable Γ φ
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (h1 : Derivable Γ (φ.imp ψ))
      (h2 : Derivable Γ φ) : Derivable Γ ψ
  | necessitation (φ : Formula)
      (h : Derivable [] φ) : Derivable [] (Formula.box φ)
  | temporal_necessitation (φ : Formula)
      (h : Derivable [] φ) : Derivable [] (Formula.all_future φ)
  | temporal_duality (φ : Formula)
      (h : Derivable [] φ) : Derivable [] φ.swap_past_future
  | weakening (Γ Δ : Context) (φ : Formula)
      (h1 : Derivable Γ φ)
      (h2 : Γ ⊆ Δ) : Derivable Δ φ
```

#### New Code:
```lean
inductive DerivationTree : Context → Formula → Type where
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : DerivationTree Γ φ
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : DerivationTree Γ φ
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (d1 : DerivationTree Γ (φ.imp ψ))
      (d2 : DerivationTree Γ φ) : DerivationTree Γ ψ
  | necessitation (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] (Formula.box φ)
  | temporal_necessitation (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] (Formula.all_future φ)
  | temporal_duality (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] φ.swap_past_future
  | weakening (Γ Δ : Context) (φ : Formula)
      (d : DerivationTree Γ φ)
      (h : Γ ⊆ Δ) : DerivationTree Δ φ
  deriving Repr
```

#### Changes Made:
1. **Type name**: `Derivable` → `DerivationTree`
2. **Universe**: `Prop` → `Type`
3. **Parameter names**: `h1`, `h2` → `d1`, `d2` (for derivation parameters)
4. **Weakening**: `h1` → `d` (derivation), keep `h2` → `h` (subset proof)
5. **Add deriving**: `deriving Repr` for debugging

#### Verification:
```bash
lake build Logos.Core.ProofSystem.Derivation
# Expected: Compilation errors in downstream files (OK for Phase 1)
# This file should compile if no other changes made yet
```

**Checkpoint:**
- [x] Inductive type updated (Prop → Type)
- [x] Type renamed (Derivable → DerivationTree)
- [x] Parameter names updated (h → d for derivations)
- [x] `deriving Repr` added

---

### **Step 2: Remove Height Axioms** (30 minutes)

**File**: `Logos/Core/ProofSystem/Derivation.lean`  
**Lines**: 168-222

#### Delete These Lines (168-222):
```lean
axiom Derivable.height {Γ : Context} {φ : Formula} (d : Derivable Γ φ) : Nat

axiom Derivable.weakening_height_succ {Γ' Δ : Context} {φ : Formula}
    (d : Derivable Γ' φ) (h : Γ' ⊆ Δ) :
    (Derivable.weakening Γ' Δ φ d h).height = d.height + 1

axiom Derivable.subderiv_height_lt {Γ' Δ : Context} {φ : Formula}
    (d : Derivable Γ' φ) (h : Γ' ⊆ Δ) :
    d.height < (Derivable.weakening Γ' Δ φ d h).height

axiom Derivable.mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : Derivable Γ (φ.imp ψ)) (d2 : Derivable Γ φ) :
    d1.height < (Derivable.modus_ponens Γ φ ψ d1 d2).height

axiom Derivable.mp_height_gt_right {Γ : Context} {φ ψ : Formula}
    (d1 : Derivable Γ (φ.imp ψ)) (d2 : Derivable Γ φ) :
    d2.height < (Derivable.modus_ponens Γ φ ψ d1 d2).height

axiom Derivable.necessitation_height_succ {φ : Formula}
    (d : Derivable [] φ) :
    (Derivable.necessitation φ d).height = d.height + 1

axiom Derivable.temporal_necessitation_height_succ {φ : Formula}
    (d : Derivable [] φ) :
    (Derivable.temporal_necessitation φ d).height = d.height + 1

axiom Derivable.temporal_duality_height_succ {φ : Formula}
    (d : Derivable [] φ) :
    (Derivable.temporal_duality φ d).height = d.height + 1
```

**Action**: Delete all 7 axiom declarations (lines 168-222)

**Verification**: File compiles without axioms (may have errors in examples - fix in Step 5)

**Checkpoint:**
- [x] All 7 height axioms removed
- [x] Lines 168-222 deleted
- [x] File compiles (ignoring downstream errors)

---

### **Step 3: Add Computable Height Function** (1 hour)

**File**: `Logos/Core/ProofSystem/Derivation.lean`  
**Location**: After inductive definition (around line 140)

#### Add This Code:
```lean
namespace DerivationTree

/-- 
Computable height function via pattern matching.

The height is defined as the maximum depth of the derivation tree:
- Base cases (axiom, assumption): height 0
- Unary rules (necessitation, temporal_necessitation, temporal_duality, weakening): 
  height of subderivation + 1
- Binary rules (modus_ponens): max of both subderivations + 1

This measure is used for well-founded recursion in the deduction theorem proof.

## Implementation Notes

Since `DerivationTree` is a `Type` (not a `Prop`), we can pattern match on it
to produce data. The height function is computable and can be evaluated.

## Usage

The height measure is primarily used in `Logos.Core.Metalogic.DeductionTheorem`
for proving termination of the deduction theorem via well-founded recursion.
-/
def height {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | axiom _ _ _ => 0
  | assumption _ _ _ => 0
  | modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | necessitation _ d => 1 + d.height
  | temporal_necessitation _ d => 1 + d.height
  | temporal_duality _ d => 1 + d.height
  | weakening _ _ _ d _ => 1 + d.height

end DerivationTree
```

**Verification:**
```lean
-- Test height computation (add as comment or #check)
-- #eval (DerivationTree.axiom [] φ h).height  -- Should return 0
```

**Checkpoint:**
- [x] Computable height function added
- [x] Pattern matching on all 7 constructors
- [x] Docstring complete
- [x] Function compiles

---

### **Step 4: Prove Height Properties as Theorems** (2-3 hours)

**File**: `Logos/Core/ProofSystem/Derivation.lean`  
**Location**: After height definition (inside `namespace DerivationTree`)

#### Add These Theorems:

```lean
namespace DerivationTree

/-! ## Height Properties -/

/--
Weakening increases height by exactly 1.
-/
theorem weakening_height_succ {Γ' Δ : Context} {φ : Formula}
    (d : DerivationTree Γ' φ) (h : Γ' ⊆ Δ) :
    (weakening Γ' Δ φ d h).height = d.height + 1 := by
  simp [height]

/--
Subderivations in weakening have strictly smaller height.

This is the key lemma for proving termination of well-founded recursion
in the deduction theorem.
-/
theorem subderiv_height_lt {Γ' Δ : Context} {φ : Formula}
    (d : DerivationTree Γ' φ) (h : Γ' ⊆ Δ) :
    d.height < (weakening Γ' Δ φ d h).height := by
  simp [height]
  omega

/--
Modus ponens height is strictly greater than the left subderivation.
-/
theorem mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/--
Modus ponens height is strictly greater than the right subderivation.
-/
theorem mp_height_gt_right {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/--
Necessitation increases height by exactly 1.
-/
theorem necessitation_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (necessitation φ d).height = d.height + 1 := by
  simp [height]

/--
Temporal necessitation increases height by exactly 1.
-/
theorem temporal_necessitation_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (temporal_necessitation φ d).height = d.height + 1 := by
  simp [height]

/--
Temporal duality increases height by exactly 1.
-/
theorem temporal_duality_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (temporal_duality φ d).height = d.height + 1 := by
  simp [height]

end DerivationTree
```

**Proof Strategy:**
- All proofs use `simp [height]` to unfold the height definition
- Inequality proofs use `omega` to solve arithmetic goals
- These should work immediately given the height definition

**Verification:**
```bash
lake build Logos.Core.ProofSystem.Derivation
# All theorems should be proven without sorry
```

**Checkpoint:**
- [x] All 6 height properties proven as theorems
- [x] No `sorry` statements
- [x] All proofs use `simp [height]` and `omega`
- [x] Docstrings complete

---

### **Step 5: Update Notation** (15 minutes)

**File**: `Logos/Core/ProofSystem/Derivation.lean`  
**Lines**: 224-232

#### Current Code:
```lean
notation:50 Γ " ⊢ " φ => Derivable Γ φ
notation:50 "⊢ " φ => Derivable [] φ
```

#### New Code:
```lean
notation:50 Γ " ⊢ " φ => DerivationTree Γ φ
notation:50 "⊢ " φ => DerivationTree [] φ
```

**Changes**: Replace `Derivable` with `DerivationTree`

**Verification**: Notation still works in examples

**Checkpoint:**
- [x] Notation updated to use DerivationTree
- [x] Both notations compile

---

### **Step 6: Update Examples** (1 hour)

**File**: `Logos/Core/ProofSystem/Derivation.lean`  
**Lines**: 234-282 (4 examples)

#### Pattern for All Examples:

**Find**: `Derivable.` (constructor references)  
**Replace**: `DerivationTree.`

#### Example 1 (lines 245-247):
```lean
-- BEFORE
example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- AFTER
example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply DerivationTree.axiom
  apply Axiom.modal_t
```

#### Example 2 (lines 254-259):
```lean
-- BEFORE
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply Derivable.modus_ponens (φ := p)
  · apply Derivable.assumption
    simp
  · apply Derivable.assumption
    simp

-- AFTER
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply DerivationTree.modus_ponens (φ := p)
  · apply DerivationTree.assumption
    simp
  · apply DerivationTree.assumption
    simp
```

#### Example 3 (lines 266-268):
```lean
-- BEFORE
example (φ : Formula) : ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) := by
  apply Derivable.axiom
  apply Axiom.modal_4

-- AFTER
example (φ : Formula) : ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) := by
  apply DerivationTree.axiom
  apply Axiom.modal_4
```

#### Example 4 (lines 276-281):
```lean
-- BEFORE
example (p : String) (ψ : Formula) : [ψ] ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply Derivable.weakening (Γ := [])
  · apply Derivable.axiom
    apply Axiom.modal_t
  · intro _ h
    exact False.elim (List.not_mem_nil _ h)

-- AFTER
example (p : String) (ψ : Formula) : [ψ] ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply DerivationTree.weakening (Γ := [])
  · apply DerivationTree.axiom
    apply Axiom.modal_t
  · intro _ h
    exact False.elim (List.not_mem_nil _ h)
```

**Verification:**
```bash
lake build Logos.Core.ProofSystem.Derivation
# All 4 examples should compile and work
```

**Checkpoint:**
- [x] All 4 examples updated
- [x] All constructor references changed (Derivable.* → DerivationTree.*)
- [x] All examples compile
- [x] All examples work correctly

---

### **Step 7: Final Verification** (30 minutes)

#### Verification Checklist:

**File Compilation:**
```bash
lake build Logos.Core.ProofSystem.Derivation
# Should compile without errors
```

**Expected Output:**
- ✅ Derivation.lean compiles successfully
- ⚠️ Downstream files will have errors (expected - fixed in Phases 2-7)

**Code Quality Checks:**
1. **No sorry statements**:
   ```bash
   grep -n "sorry" Logos/Core/ProofSystem/Derivation.lean
   # Should return no results
   ```

2. **All axioms removed**:
   ```bash
   grep -n "axiom" Logos/Core/ProofSystem/Derivation.lean
   # Should only find axiom constructor, not axiom declarations
   ```

3. **Height function computable**:
   - Pattern matching on all 7 constructors
   - Returns Nat for all cases

4. **Height properties proven**:
   - 6 theorems proven (not axiomatized)
   - All use `simp [height]` and `omega`

**Checkpoint:**
- [x] File compiles without errors
- [x] Zero sorry statements
- [x] All 7 height axioms removed
- [x] Computable height function implemented
- [x] All 6 height properties proven as theorems
- [x] All 4 examples working
- [x] Notation updated
- [x] `deriving Repr` added

---

## Verification Checkpoints

### After Each Step:

1. **Incremental Compilation:**
   ```bash
   lake build Logos.Core.ProofSystem.Derivation
   # Fix errors immediately
   ```

2. **Check for Sorry:**
   ```bash
   grep -n "sorry" Logos/Core/ProofSystem/Derivation.lean
   ```

3. **Verify Changes:**
   - Review diff before committing
   - Ensure all changes are intentional

### Final Phase 1 Verification:

- [x] **Compilation**: Derivation.lean compiles without errors
- [x] **Examples**: All 4 example derivations work
- [x] **Height Function**: Computable height works correctly
- [x] **Height Properties**: All 6 properties proven (no axioms)
- [x] **No Axioms**: All 7 height axioms removed
- [x] **No Sorry**: Zero `sorry` statements
- [x] **Notation**: Both notations work with DerivationTree
- [x] **Repr**: `deriving Repr` added for debugging

**Expected Downstream Impact:**
- ⚠️ **Metalogic files will not compile** (DeductionTheorem, Soundness, Completeness)
- ⚠️ **Theorem files will not compile** (Propositional, Combinators, etc.)
- ⚠️ **Automation files will not compile** (Tactics, AesopRules)
- ⚠️ **Test files will not compile** (all test modules)

**This is EXPECTED and CORRECT** - Phases 2-7 will fix these files.

---

## Testing Requirements

### Phase 1 Testing (This File Only)

**Pre-Migration Baseline:**
```bash
# Verify current file compiles
lake build Logos.Core.ProofSystem.Derivation
# Record: File compiles successfully
```

**Post-Migration Verification:**
```bash
# Verify migrated file compiles
lake build Logos.Core.ProofSystem.Derivation
# Expected: File compiles successfully
```

**Height Function Tests:**
```lean
-- Add these as comments or #check statements in file

-- Test base cases
-- #eval (DerivationTree.axiom [] φ h).height  -- Should be 0
-- #eval (DerivationTree.assumption [φ] φ mem).height  -- Should be 0

-- Test recursive cases
-- #eval (DerivationTree.necessitation φ d).height  -- Should be d.height + 1
-- #eval (DerivationTree.modus_ponens Γ φ ψ d1 d2).height  -- Should be 1 + max d1.height d2.height
```

**Height Property Tests:**
```lean
-- Verify theorems are proven (not axiomatized)
#check DerivationTree.weakening_height_succ
#check DerivationTree.subderiv_height_lt
#check DerivationTree.mp_height_gt_left
#check DerivationTree.mp_height_gt_right
#check DerivationTree.necessitation_height_succ
#check DerivationTree.temporal_necessitation_height_succ
#check DerivationTree.temporal_duality_height_succ
```

### Regression Tests

**No regression tests needed for Phase 1** - this is a breaking change by design.

Phases 2-7 will update all dependent files to work with the new DerivationTree type.

---

## Documentation Updates

### Files to Update in Phase 1:

**Derivation.lean docstrings:**
- ✅ Update module docstring to reflect Type-based approach
- ✅ Update `DerivationTree` docstring (was `Derivable`)
- ✅ Update height function docstring (computable, not axiomatized)
- ✅ Update height property docstrings (theorems, not axioms)

**No other documentation updates in Phase 1** - Phase 6 will handle:
- ARCHITECTURE.md
- IMPLEMENTATION_STATUS.md
- Module files (Logos/ProofSystem.lean, etc.)

---

## Success Criteria

### Phase 1 Success Criteria: ✅ **COMPLETE**

**Primary Goal: Derivation.lean Migrated to Type** ✅

1. **Correctness:** ✅
   - ✅ File compiles without errors
   - ✅ No `sorry` statements
   - ✅ All examples work correctly
   - ✅ Height function computable

2. **Completeness:** ✅
   - ✅ All 7 height axioms removed
   - ✅ All 6 height properties proven as theorems
   - ✅ Inductive type updated (Prop → Type)
   - ✅ Type renamed (Derivable → DerivationTree)

3. **Quality:** ✅
   - ✅ Code follows LEAN style guide
   - ✅ Docstrings complete and accurate
   - ✅ Examples illustrative and working
   - ✅ `deriving Repr` added

4. **Expected Breaking Changes:** ✅
   - ✅ Downstream files will not compile (EXPECTED - 91 errors in Combinators.lean)
   - ⚠️ Phases 2-7 required to fix downstream files

**Implementation Date**: 2025-12-19
**Git Commit**: dfefea6 - "feat(derivation): migrate from Derivable (Prop) to DerivationTree (Type)"
**Summary**: `.opencode/specs/072_phase1_migration/summaries/implementation-summary-001.md`

---

## Critical Dependencies

### Must Complete Before Phase 1:

1. ✅ Git branch created (not required - direct commit to main)
2. ✅ Backup of Derivation.lean (via git)
3. ✅ Current file compiles (baseline)
4. ✅ Parent migration plan reviewed

### Must Complete During Phase 1:

**All steps must complete in order:**
1. Update inductive type declaration
2. Remove height axioms
3. Add computable height function
4. Prove height properties as theorems
5. Update notation
6. Update examples
7. Final verification

### Must Complete After Phase 1:

**Phase 2 (Metalogic) depends on Phase 1:**
- DeductionTheorem.lean needs DerivationTree type
- Soundness.lean needs DerivationTree type
- Completeness.lean needs DerivationTree type

**All subsequent phases depend on Phase 1 completion.**

---

## Risk Mitigation

### Risk 1: Height Function Bugs (30% likelihood)

**Mitigation:**
- Prove height properties as theorems (validates correctness)
- Test height computation on examples
- Compare behavior with axiomatized version (if available)

### Risk 2: Proof Failures (40% likelihood)

**Mitigation:**
- Use documented proof strategy (simp + omega)
- If proofs fail, check height definition
- Consult parent plan for alternative approaches

### Risk 3: Breaking Downstream Compilation (100% likelihood - EXPECTED)

**Mitigation:**
- This is expected and correct
- Phases 2-7 will fix downstream files
- Do not attempt to fix downstream files in Phase 1
- Commit Phase 1 changes before proceeding to Phase 2

### Risk 4: Rollback Needed (10% likelihood)

**Mitigation:**
- Git branch allows easy rollback
- Single file change (low rollback complexity)
- Backup file available

---

## Rollback Procedure

### If Phase 1 Fails:

1. **Git Revert:**
   ```bash
   git checkout Logos/Core/ProofSystem/Derivation.lean
   # Reverts to pre-migration state
   ```

2. **Restore Backup:**
   ```bash
   cp Derivation.lean.backup Logos/Core/ProofSystem/Derivation.lean
   ```

3. **Verify Restoration:**
   ```bash
   lake build Logos.Core.ProofSystem.Derivation
   # Should compile successfully (baseline)
   ```

4. **Document Failure:**
   - Record what went wrong
   - Update migration plan
   - Consider alternative approaches

---

## Notes

### Key Insights:

1. **Phase 1 is CRITICAL** - All downstream files depend on this
2. **Breaking changes are EXPECTED** - Phases 2-7 will fix them
3. **Height function is computable** - Pattern matching on Type
4. **Height properties are proven** - Not axiomatized
5. **Single file change** - Low rollback risk

### Implementation Notes:

1. **Parameter naming convention**:
   - `h` for hypothesis/proof parameters (Axiom φ, φ ∈ Γ, Γ ⊆ Δ)
   - `d` for derivation parameters (DerivationTree Γ φ)
   - `d1`, `d2` for multiple derivations

2. **Height function**:
   - Base cases (axiom, assumption): 0
   - Unary rules: subderivation height + 1
   - Binary rules: max of subderivations + 1

3. **Proof strategy**:
   - `simp [height]` unfolds definition
   - `omega` solves arithmetic goals
   - Should work immediately for all 6 theorems

### Next Steps After Phase 1:

**Phase 2: Metalogic Proofs Migration** (18-23 hours)
- Update DeductionTheorem.lean
- Update Soundness.lean
- Update Completeness.lean

See `.opencode/specs/058_migration_to_type/plans/implementation-001.md` for full Phase 2 details.

---

## Related Documentation

- **Parent Migration Plan**: `.opencode/specs/058_migration_to_type/plans/implementation-001.md`
- **Migration Summary**: `.opencode/specs/058_migration_to_type/summaries/migration-summary.md`
- **Code Patterns**: `.opencode/specs/058_migration_to_type/reports/code-patterns.md`
- **Previous Research**: `.opencode/specs/057_deep_embedding_research/reports/research-001.md`

---

**Plan Complete**: 2025-12-19  
**Ready for Execution**: YES  
**Recommended Command**: `/lean .opencode/specs/072_phase1_migration/plans/phase1-implementation-001.md`
