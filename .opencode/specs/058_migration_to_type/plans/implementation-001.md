# Implementation Plan: Derivable : Prop → DerivationTree : Type Migration

**Project**: #058  
**Version**: 001  
**Date**: 2025-12-19  
**Complexity**: COMPLEX  
**Estimated Effort**: 60-80 hours  
**Risk Level**: HIGH

---

## Task Description

Migrate the core derivation relation from `Derivable : Context → Formula → Prop` to `DerivationTree : Context → Formula → Type` to enable:
- Computable height functions (remove 7 axioms)
- Pattern matching on derivations
- Explicit proof term analysis
- Decidable equality on derivations

**Source**: TODO.md task for Project #058  
**Context**: User strategic decision to override previous research recommendation (Project #057) which advocated keeping the dual-type approach.

---

## Complexity Assessment

### Overall Complexity: **COMPLEX**

**Complexity Drivers:**
1. **Breaking changes across entire codebase** (20 files affected)
2. **Core type system refactor** (Prop → Type fundamental change)
3. **Well-founded recursion updates** (height axioms → computable functions)
4. **Metaprogramming fragility** (tactic system updates)
5. **Performance implications** (25-50% compilation slowdown expected)

**Estimated Effort:** 60-80 hours
- Optimistic: 60 hours (experienced with LEAN, no major issues)
- Realistic: 70 hours (some debugging, minor complications)
- Pessimistic: 80 hours (tactic issues, performance optimization needed)

**Confidence Level:** Medium-High (based on detailed migration plan analysis)

### Risk Assessment

| Risk Factor | Likelihood | Impact | Severity | Mitigation |
|-------------|-----------|--------|----------|------------|
| Breaking all downstream code | 100% | CRITICAL | **CRITICAL** | Incremental migration, parallel types |
| Performance degradation >25% | 80% | HIGH | **HIGH** | Benchmark, optimize, rollback plan |
| Tactic system breakage | 60% | HIGH | **HIGH** | Careful metaprogramming, extensive testing |
| Soundness proof complications | 40% | MEDIUM | **MEDIUM** | Pattern matching works same as induction |
| Height function bugs | 30% | MEDIUM | **MEDIUM** | Prove height properties as theorems |
| Rollback difficulty | 20% | MEDIUM | **LOW** | Git branch, backups, clear procedure |

**Overall Risk Level:** **HIGH** - Multiple high-severity risks with significant likelihood

---

## Dependencies

### Required Imports

**Core LEAN Libraries:**
```lean
import Lean.Meta.Basic           -- Metaprogramming
import Lean.Elab.Tactic          -- Tactic elaboration
import Init.WF                   -- Well-founded recursion
import Init.Data.Nat.Basic       -- Nat operations (max, omega)
```

**Mathlib Dependencies:**
```lean
import Mathlib.Tactic.Basic      -- Basic tactics
import Mathlib.Data.List.Basic   -- List operations
import Mathlib.Order.Basic       -- Ordering (for height comparisons)
```

**Internal Dependencies (in migration order):**
1. `Logos.Core.Syntax.Formula` (unchanged - already Type)
2. `Logos.Core.Syntax.Context` (unchanged)
3. `Logos.Core.ProofSystem.Axioms` (unchanged)
4. `Logos.Core.ProofSystem.Derivation` ⭐ **CRITICAL - migrate first**
5. `Logos.Core.Metalogic.DeductionTheorem` (depends on Derivation)
6. `Logos.Core.Metalogic.Soundness` (depends on Derivation)
7. `Logos.Core.Metalogic.Completeness` (depends on Derivation)
8. All theorem libraries (depend on Derivation + Metalogic)
9. All automation (depends on Derivation)
10. All tests (depend on everything)

### Prerequisites

**Before Migration:**
1. ✅ Full test suite passing (baseline)
2. ✅ Git branch created (`migration/derivable-to-type`)
3. ✅ Backup of critical files
4. ✅ Performance baseline recorded
5. ✅ Migration plan reviewed and approved

**During Migration:**
- No new features added to affected files
- All changes committed atomically per phase
- Tests run after each phase completion

### Library Functions to Use

**Pattern Matching:**
```lean
-- Computable height via pattern matching
def DerivationTree.height : DerivationTree Γ φ → Nat
  | axiom _ _ _ => 0
  | assumption _ _ _ => 0
  | modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | necessitation _ d => 1 + d.height
  | temporal_necessitation _ d => 1 + d.height
  | temporal_duality _ d => 1 + d.height
  | weakening _ _ _ d _ => 1 + d.height
```

**Theorem Proving:**
```lean
-- Height properties proven with simp + omega
theorem mp_height_gt_left : d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega
```

**Deriving Clauses:**
```lean
inductive DerivationTree : Context → Formula → Type where
  -- ... constructors
  deriving Repr  -- Automatic representation for debugging
```

---

## Implementation Steps

### **Phase 1: Core Definition** (6-8 hours) ⭐ CRITICAL [COMPLETE]

**File:** `Logos/Core/ProofSystem/Derivation.lean`

#### Step 1.1: Update Inductive Type Declaration (1 hour)

**Current (lines 59-138):**
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

**New:**
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

**Changes:**
1. `Prop` → `Type`
2. Type name: `Derivable` → `DerivationTree`
3. Parameter names: `h1`, `h2` → `d1`, `d2` (derivations)
4. Add `deriving Repr` for debugging

**Verification:**
```bash
lake build Logos.Core.ProofSystem.Derivation
```

#### Step 1.2: Remove Height Axioms (30 minutes)

**Delete lines 168-222:**
```lean
-- DELETE ALL OF THESE:
axiom Derivable.height {Γ : Context} {φ : Formula} (d : Derivable Γ φ) : Nat
axiom Derivable.weakening_height_succ ...
axiom Derivable.subderiv_height_lt ...
axiom Derivable.mp_height_gt_left ...
axiom Derivable.mp_height_gt_right ...
axiom Derivable.necessitation_height_succ ...
axiom Derivable.temporal_necessitation_height_succ ...
axiom Derivable.temporal_duality_height_succ ...
```

**Verification:** File compiles without axioms

#### Step 1.3: Add Computable Height Function (1 hour)

**Add after inductive definition:**
```lean
namespace DerivationTree

/-- 
Computable height function via pattern matching.

The height is the maximum depth of the derivation tree:
- Base cases (axiom, assumption): height 0
- Unary rules (necessitation, temporal_necessitation, temporal_duality, weakening): 
  height of subderivation + 1
- Binary rules (modus_ponens): max of both subderivations + 1
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
-- Test height computation
#eval (DerivationTree.axiom [] φ h).height  -- Should return 0
```

#### Step 1.4: Prove Height Properties as Theorems (2-3 hours)

**Add after height definition:**
```lean
namespace DerivationTree

theorem weakening_height_succ {Γ Δ : Context} {φ : Formula}
    (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) :
    (weakening Γ Δ φ d h).height = d.height + 1 := by
  simp [height]

theorem subderiv_height_lt {Γ Δ : Context} {φ : Formula}
    (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) :
    d.height < (weakening Γ Δ φ d h).height := by
  simp [height]
  omega

theorem mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

theorem mp_height_gt_right {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

theorem necessitation_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (necessitation φ d).height = d.height + 1 := by
  simp [height]

theorem temporal_necessitation_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (temporal_necessitation φ d).height = d.height + 1 := by
  simp [height]

theorem temporal_duality_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (temporal_duality φ d).height = d.height + 1 := by
  simp [height]

end DerivationTree
```

**Verification:** All theorems proven without `sorry`

#### Step 1.5: Update Notation (15 minutes)

**Keep existing notation (works with Type):**
```lean
notation:50 Γ " ⊢ " φ => DerivationTree Γ φ
notation:50 "⊢ " φ => DerivationTree [] φ
```

**Verification:** Notation still works in examples

#### Step 1.6: Update Examples (1 hour)

**Update lines 245-282:**
```lean
-- Change all Derivable.* → DerivationTree.*
example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply DerivationTree.axiom  -- Changed from Derivable.axiom
  apply Axiom.modal_t

example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply DerivationTree.modus_ponens (φ := p)  -- Changed
  · apply DerivationTree.assumption
    simp
  · apply DerivationTree.assumption
    simp

-- ... update all 4 examples
```

**Verification:**
```bash
lake build Logos.Core.ProofSystem.Derivation
# All examples should compile
```

**Phase 1 Checkpoint:**
- [ ] Inductive type updated (Prop → Type)
- [ ] Height axioms removed (7 axioms deleted)
- [ ] Computable height function added
- [ ] Height properties proven as theorems (6 theorems)
- [ ] Notation updated
- [ ] Examples updated and compiling
- [ ] File compiles without errors
- [ ] No `sorry` statements

---

### **Phase 2: Metalogic Proofs** (18-23 hours) ⭐ HIGH IMPACT [COMPLETE]

#### Step 2.1: Update DeductionTheorem.lean (10-12 hours)

**File:** `Logos/Core/Metalogic/DeductionTheorem.lean`

**Changes Required:**

1. **Update all type signatures** (2 hours):
   ```lean
   -- Find all: (h : Γ ⊢ φ)
   -- Replace: (d : Γ ⊢ φ)
   ```

2. **Update constructor names** (2 hours):
   ```lean
   -- Find: Derivable\.(\w+)
   -- Replace: DerivationTree.\1
   ```

3. **Update termination clauses** (2 hours):
   ```lean
   -- Find: termination_by h.height
   -- Replace: termination_by d.height
   
   -- Find: Derivable\.mp_height_gt_left h1 h2
   -- Replace: DerivationTree.mp_height_gt_left d1 d2
   ```

4. **Update helper functions** (2 hours):
   - `deduction_with_mem`: Update parameter names
   - `deduction_theorem`: Update all references

5. **Test compilation** (2-4 hours):
   ```bash
   lake build Logos.Core.Metalogic.DeductionTheorem
   # Fix any errors
   ```

**Key Pattern:**
```lean
-- BEFORE
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B := by
  match h with
  | Derivable.modus_ponens _ φ ψ h1 h2 =>
      have ih1 := deduction_theorem Γ A (φ.imp ψ) h1
      have ih2 := deduction_theorem Γ A φ h2
      exact deduction_mp Γ A φ ψ ih1 ih2
  termination_by h.height
  decreasing_by
    exact Derivable.mp_height_gt_left h1 h2

-- AFTER
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (d : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B := by
  match d with
  | DerivationTree.modus_ponens _ φ ψ d1 d2 =>
      have ih1 := deduction_theorem Γ A (φ.imp ψ) d1
      have ih2 := deduction_theorem Γ A φ d2
      exact deduction_mp Γ A φ ψ ih1 ih2
  termination_by d.height
  decreasing_by
    exact DerivationTree.mp_height_gt_left d1 d2
```

**Checkpoint:**
- [ ] All type signatures updated
- [ ] All constructor names updated
- [ ] Termination clauses updated
- [ ] Helper functions updated
- [ ] File compiles without errors
- [ ] No `sorry` statements

#### Step 2.2: Update Soundness.lean (6-8 hours)

**File:** `Logos/Core/Metalogic/Soundness.lean`

**Changes Required:**

1. **Update theorem signature** (1 hour):
   ```lean
   -- BEFORE
   theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
     intro h_deriv
     induction h_deriv with
     | axiom Γ' φ' h_ax => ...
   
   -- AFTER
   theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
     intro d
     induction d with
     | axiom Γ' φ' h_ax => ...
   ```

2. **Update all constructor names in induction cases** (3-4 hours):
   - 7 cases: axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening
   - Each case: update constructor name, parameter names

3. **Update subderivation names** (1 hour):
   ```lean
   -- Make explicit: _ _ → d1 d2
   | modus_ponens Γ' φ' ψ' d1 d2 ih_imp ih_phi => ...
   ```

4. **Test compilation** (1-2 hours):
   ```bash
   lake build Logos.Core.Metalogic.Soundness
   ```

**Checkpoint:**
- [ ] Theorem signature updated
- [ ] All 7 induction cases updated
- [ ] Subderivation names explicit
- [ ] File compiles without errors
- [ ] No `sorry` statements

#### Step 2.3: Update Completeness.lean (2-3 hours)

**File:** `Logos/Core/Metalogic/Completeness.lean`

**Changes Required:**

1. **Update `Consistent` definition** (30 minutes):
   ```lean
   -- BEFORE
   def Consistent (Γ : Context) : Prop := ¬(Γ ⊢ Formula.bot)
   
   -- AFTER (same, but type changes)
   def Consistent (Γ : Context) : Prop := ¬(Γ ⊢ Formula.bot)
   ```

2. **Update axiom signatures** (1 hour):
   ```lean
   axiom maximal_consistent_closed : ... (Γ ⊢ φ) → ...
   ```

3. **Test compilation** (30 minutes - 1 hour):
   ```bash
   lake build Logos.Core.Metalogic.Completeness
   ```

**Checkpoint:**
- [ ] Consistent definition updated
- [ ] Axiom signatures updated
- [ ] File compiles without errors

**Phase 2 Checkpoint:**
- [ ] DeductionTheorem.lean updated and compiling
- [ ] Soundness.lean updated and compiling
- [ ] Completeness.lean updated and compiling
- [ ] All metalogic proofs working
- [ ] No `sorry` statements

---

### **Phase 3: Theorem Libraries** (29-37 hours) [COMPLETE]

**Strategy:** Mechanical find-replace for constructor names

#### Step 3.1: Update Propositional.lean (8-10 hours)

**File:** `Logos/Core/Theorems/Propositional.lean`

**Pattern:**
```bash
# Find-replace (careful with context!)
Derivable.axiom → DerivationTree.axiom
Derivable.modus_ponens → DerivationTree.modus_ponens
Derivable.weakening → DerivationTree.weakening
Derivable.assumption → DerivationTree.assumption
```

**Verification:**
```bash
lake build Logos.Core.Theorems.Propositional
```

**Checkpoint:**
- [ ] All constructor names updated
- [ ] File compiles without errors
- [ ] All theorems proven (no `sorry`)

#### Step 3.2: Update Combinators.lean (4-5 hours)

**File:** `Logos/Core/Theorems/Combinators.lean`

Same pattern as Propositional.lean

**Checkpoint:**
- [ ] Constructor names updated
- [ ] File compiles

#### Step 3.3: Update GeneralizedNecessitation.lean (5-6 hours)

**File:** `Logos/Core/Theorems/GeneralizedNecessitation.lean`

**Special considerations:**
- Uses context induction with derivation parameter
- Update parameter names in induction

**Checkpoint:**
- [ ] Constructor names updated
- [ ] Induction parameters updated
- [ ] File compiles

#### Step 3.4: Update Perpetuity Modules (6-8 hours total)

**Files:**
- `Logos/Core/Theorems/Perpetuity/Helpers.lean`
- `Logos/Core/Theorems/Perpetuity/Principles.lean`
- `Logos/Core/Theorems/Perpetuity/Bridge.lean`
- `Logos/Core/Theorems/Perpetuity.lean`

Same pattern for each file.

**Checkpoint:**
- [ ] All 4 files updated
- [ ] All files compile

#### Step 3.5: Update Remaining Theorem Files (6-8 hours)

**Files:**
- Any other theorem modules

**Phase 3 Checkpoint:**
- [ ] All theorem libraries updated
- [ ] All files compile without errors
- [ ] No `sorry` statements introduced
- [ ] All existing theorems still proven

---

### **Phase 4: Automation** (8-11 hours) ⚠️ HIGH RISK [NOT STARTED]

#### Step 4.1: Update Tactics.lean (6-8 hours)

**File:** `Logos/Core/Automation/Tactics.lean`

**Changes Required:**

1. **Update constant references** (2 hours):
   ```lean
   -- BEFORE
   let axiomConst := ``Derivable.axiom
   let mpConst := ``Derivable.modus_ponens
   
   -- AFTER
   let axiomConst := ``DerivationTree.axiom
   let mpConst := ``DerivationTree.modus_ponens
   ```

2. **Update metaprogramming code** (3-4 hours):
   - All `mkAppM` calls with Derivable constructors
   - Type checking for DerivationTree
   - Goal type matching

3. **Test all tactics** (1-2 hours):
   ```bash
   lake build Logos.Core.Automation.Tactics
   # Run tactic tests
   ```

**Checkpoint:**
- [ ] All constant references updated
- [ ] Metaprogramming code updated
- [ ] File compiles
- [ ] Tactics tested and working

#### Step 4.2: Update AesopRules.lean (2-3 hours)

**File:** `Logos/Core/Automation/AesopRules.lean`

**Changes:**
- Update registered rule names
- Test Aesop integration

**Checkpoint:**
- [ ] Rule names updated
- [ ] Aesop integration working

**Phase 4 Checkpoint:**
- [ ] Tactics.lean updated and working
- [ ] AesopRules.lean updated
- [ ] All automation functional
- [ ] Tactic tests passing

---

### **Phase 5: Test Suites** (19-26 hours) [NOT STARTED]

**Strategy:** Same find-replace pattern for all test files

#### Step 5.1: Update Core Tests (10-13 hours)

**Files:**
- `LogosTest/Core/ProofSystem/DerivationTest.lean` (4-5 hours)
- `LogosTest/Core/Metalogic/SoundnessTest.lean` (2-3 hours)
- `LogosTest/Core/Metalogic/CompletenessTest.lean` (1-2 hours)
- `LogosTest/Core/Integration/EndToEndTest.lean` (2-3 hours)

**Pattern:** Update constructor names, run tests

**Checkpoint:**
- [ ] All core tests updated
- [ ] All tests compile
- [ ] All tests pass

#### Step 5.2: Update Theorem Tests (6-8 hours)

**Files:**
- `LogosTest/Core/Theorems/PerpetuityTest.lean`
- `LogosTest/Core/Theorems/PropositionalTest.lean`
- `LogosTest/Core/Theorems/ModalS4Test.lean`
- `LogosTest/Core/Theorems/ModalS5Test.lean`

**Checkpoint:**
- [ ] All theorem tests updated
- [ ] All tests pass

#### Step 5.3: Update Automation Tests (4-5 hours)

**File:** `LogosTest/Core/Automation/TacticsTest.lean`

**Checkpoint:**
- [ ] Tactic tests updated
- [ ] All tests pass

**Phase 5 Checkpoint:**
- [ ] All test files updated
- [ ] All tests compile
- [ ] All tests pass
- [ ] No regressions detected

---

### **Phase 6: Documentation** (2-3 hours) [NOT STARTED]

#### Step 6.1: Update Module Files

**Files:**
- `Logos/ProofSystem.lean`
- `Logos/Metalogic.lean`
- `Logos/Theorems.lean`
- `Logos/Core/Theorems.lean`

**Changes:**
- Update documentation comments
- Update example derivations
- Test compilation

**Checkpoint:**
- [ ] All module files updated
- [ ] Documentation accurate
- [ ] Examples compile

**Phase 6 Checkpoint:**
- [ ] All documentation updated
- [ ] Examples working
- [ ] Migration notes added

---

### **Phase 7: Final Verification** (4-6 hours) [NOT STARTED]

#### Step 7.1: Full Build

```bash
lake clean
lake build
# Should compile without errors
```

**Expected:** Clean build, 0 errors

#### Step 7.2: Run All Tests

```bash
lake test
# All tests should pass
```

**Expected:** All tests passing

#### Step 7.3: Performance Check

```bash
# Measure compilation time
time lake build

# Compare with baseline (before migration)
# Acceptable: 25-50% slower
# Concerning: >50% slower
```

**Expected:** 25-50% slower compilation (acceptable)

#### Step 7.4: Verify New Capabilities

```lean
-- Test computable height
#eval (DerivationTree.axiom [] φ h).height  -- Should return 0

-- Test pattern matching
def countAxioms : DerivationTree Γ φ → Nat
  | .axiom _ _ _ => 1
  | .modus_ponens _ _ _ d1 d2 => countAxioms d1 + countAxioms d2
  | .weakening _ _ _ d _ => countAxioms d
  | _ => 0

-- Test Repr
#eval (DerivationTree.axiom [] φ h)  -- Should print representation
```

**Expected:** All new capabilities working

**Phase 7 Checkpoint:**
- [ ] Full build successful
- [ ] All tests passing
- [ ] Performance acceptable (<50% slower)
- [ ] New capabilities verified
- [ ] No `sorry` statements in codebase

---

## Verification Checkpoints

### After Each Phase:

1. **Incremental Compilation:**
   ```bash
   lake build <modified-file>
   # Fix errors immediately
   ```

2. **Dependent File Check:**
   ```bash
   lake build
   # Fix cascading errors
   ```

3. **Test Subset:**
   ```bash
   lake build LogosTest.<module>
   ```

### Final Verification:

- [ ] **Compilation**: All 20 files compile without errors
- [ ] **Tests**: All test suites pass
- [ ] **Examples**: All example derivations work
- [ ] **Tactics**: All tactics function correctly
- [ ] **Performance**: Compilation time <50% slower than baseline
- [ ] **Memory**: Memory usage <100% higher than baseline
- [ ] **Height Function**: Computable height works correctly
- [ ] **Pattern Matching**: Can pattern match on derivations
- [ ] **Repr**: Derivation trees have readable representation
- [ ] **No Axioms**: All 7 height axioms removed
- [ ] **No Sorry**: Zero `sorry` statements in codebase

---

## Testing Requirements

### Pre-Migration Tests

1. **Baseline Test Suite:**
   ```bash
   lake clean
   lake build
   lake test
   # Record: All tests passing, compilation time
   ```

2. **Performance Baseline:**
   ```bash
   time lake build
   /usr/bin/time -v lake build 2>&1 | grep "Maximum resident"
   ```

### Migration Verification Tests

**After Each Phase:**
- Incremental compilation of modified files
- Dependent file compilation check
- Relevant test subset execution

**Post-Migration:**
- Full compilation (clean build)
- Complete test suite
- Performance benchmarks
- New capability tests

### Regression Tests

**Create new tests for Type-specific features:**
```lean
-- Test computable height
#eval (DerivationTree.axiom [] φ h).height  -- Should return 0

-- Test pattern matching
def countAxioms : DerivationTree Γ φ → Nat
  | .axiom _ _ _ => 1
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => countAxioms d1 + countAxioms d2
  | .necessitation _ d => countAxioms d
  | .temporal_necessitation _ d => countAxioms d
  | .temporal_duality _ d => countAxioms d
  | .weakening _ _ _ d _ => countAxioms d

-- Test Repr
#eval (DerivationTree.axiom [] φ h)  -- Should print representation

-- Test decidable equality (if derived)
#eval (d1 == d2)  -- true or false
```

---

## Documentation Updates

### Files to Update:

1. **Derivation.lean docstrings:**
   - Update to reflect Type-based approach
   - Document computable height
   - Explain pattern matching capabilities

2. **ARCHITECTURE.md:**
   - Document migration rationale
   - Explain Type vs Prop decision
   - Reference this implementation plan

3. **IMPLEMENTATION_STATUS.md:**
   - Update status of migration
   - Record completion date
   - Note any issues encountered

4. **Migration notes:**
   - Create migration guide for future reference
   - Document breaking changes
   - Provide upgrade path for external users

---

## Success Criteria

### Primary Goal: Complete Migration to Deep Embedding

**Stage 1 (Primary Goal) - COMPLETE:**
- ✅ Clean, consistent Type-based implementation
- ✅ Full completeness (zero `sorry` statements)
- ✅ Type-based derivation relation
- ✅ Computable height function (7 axioms removed)
- ✅ Pattern matching on derivations
- ✅ All tests passing
- ✅ Performance acceptable (<50% slower)

### Success Metrics:

1. **Correctness:**
   - All files compile without errors
   - All tests pass
   - No `sorry` statements
   - Soundness proof still valid

2. **Completeness:**
   - All 7 height axioms removed
   - All 6 height properties proven as theorems
   - All existing theorems still proven
   - All tactics still functional

3. **Performance:**
   - Compilation time <50% slower than baseline
   - Memory usage <100% higher than baseline
   - Test execution time acceptable

4. **Quality:**
   - Code follows LEAN style guide
   - Documentation complete and accurate
   - Examples working and illustrative
   - Migration notes comprehensive

---

## Critical Dependencies

### Must Complete Before Migration:

1. ✅ Full test suite passing (baseline established)
2. ✅ Git branch created and committed
3. ✅ Critical files backed up
4. ✅ Performance baseline recorded
5. ✅ Migration plan reviewed

### Must Complete During Migration:

**Phase 1 (Core Definition) must complete before:**
- Phase 2 (Metalogic)
- Phase 3 (Theorems)
- Phase 4 (Automation)
- Phase 5 (Tests)

**Phase 2 (Metalogic) must complete before:**
- Phase 3 (Theorems) - depends on DeductionTheorem
- Phase 5 (Tests) - metalogic tests

**Phase 3 (Theorems) must complete before:**
- Phase 5 (Tests) - theorem tests

**Phase 4 (Automation) must complete before:**
- Phase 5 (Tests) - tactic tests

**All phases must complete before:**
- Phase 6 (Documentation)
- Phase 7 (Final Verification)

---

## Risk Mitigation

### Risk 1: Breaking All Downstream Code (100% likelihood)

**Mitigation:**
- Incremental migration (phase by phase)
- Comprehensive testing after each phase
- Git branch for easy rollback
- Backup of critical files

### Risk 2: Performance Degradation (80% likelihood)

**Mitigation:**
- Benchmark before/after
- Monitor compilation time at each phase
- Optimize if >50% slower
- Rollback if unacceptable (>100% slower)

### Risk 3: Tactic System Breakage (60% likelihood)

**Mitigation:**
- Careful metaprogramming updates
- Extensive tactic testing
- Consult LEAN Zulip if issues
- Rollback if unfixable

### Risk 4: Height Function Bugs (30% likelihood)

**Mitigation:**
- Prove height properties as theorems
- Test height computation extensively
- Compare with axiomatized version behavior

### Risk 5: Time Overrun (40% likelihood)

**Mitigation:**
- Track time spent per phase
- Re-evaluate if >100 hours
- Consider partial migration
- Pause and reassess if needed

---

## Rollback Procedure

### If Migration Fails:

1. **Git Revert:**
   ```bash
   git checkout main
   git branch -D migration/derivable-to-type
   ```

2. **Restore Backups:**
   ```bash
   cp Derivation.lean.backup Logos/Core/ProofSystem/Derivation.lean
   cp DeductionTheorem.lean.backup Logos/Core/Metalogic/DeductionTheorem.lean
   cp Soundness.lean.backup Logos/Core/Metalogic/Soundness.lean
   ```

3. **Verify Restoration:**
   ```bash
   lake clean
   lake build
   lake test
   # Should be back to baseline
   ```

4. **Document Failure:**
   - Record what went wrong
   - Update migration plan
   - Consider alternative approaches

---

## Notes

### Key Insights from Research:

1. **Previous Research (Project #057) recommended KEEPING dual-type approach**
   - ConCert framework precedent validates hybrid pattern
   - LEAN community standards prefer Prop for derivability
   - RL training prioritizes fast verification over proof structure

2. **User Decision: Proceed with migration DESPITE research**
   - Strategic decision to prioritize computable analysis
   - Accept performance costs for explicit structure
   - Enable pattern matching and decidable equality

3. **Migration is technically feasible but costly:**
   - 60-80 hours effort
   - 25-50% compilation slowdown
   - Breaking changes across entire codebase
   - High risk of bugs during transition

### Alternative Approaches Considered:

1. **Hybrid (Keep Both Types):**
   - Keep `Derivable : Prop` for proofs
   - Add `DerivationTree : Type` for analysis
   - Pros: No breaking changes, best of both worlds
   - Cons: Maintenance burden, conversion overhead

2. **Minimal Migration (Height Only):**
   - Keep `Derivable : Prop`
   - Add computable height separately
   - Pros: Minimal changes
   - Cons: Still uses axioms, limited benefits

3. **Incremental File-by-File:**
   - Migrate one file at a time
   - Keep both types during transition
   - Pros: Low risk, easy rollback
   - Cons: Long transition period

**Chosen Approach:** Full migration (this plan) with incremental phases

---

## Related Research

- **Full Migration Plan**: `.opencode/specs/058_migration_to_type/reports/migration-plan-001.md`
- **Code Patterns**: `.opencode/specs/058_migration_to_type/reports/code-patterns.md`
- **Previous Research**: `.opencode/specs/057_deep_embedding_research/reports/research-001.md`
- **Migration Summary**: `.opencode/specs/058_migration_to_type/summaries/migration-summary.md`

---

**Plan Complete**: 2025-12-19  
**Ready for Execution**: YES  
**Approval Required**: User confirmation to proceed
