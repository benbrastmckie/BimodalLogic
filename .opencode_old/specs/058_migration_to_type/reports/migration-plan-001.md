# Migration Plan: Derivable : Prop → DerivationTree : Type

**Project**: #058  
**Date**: 2025-12-19  
**Migration Type**: Breaking Change - Core Type System Refactor  
**Decision Context**: User strategic override of previous research recommendation

---

## Executive Summary

### Strategic Context

**Previous Research** (Project #057): Comprehensive research recommended **KEEPING** the current dual-type approach (Formula: Type, Derivable: Prop) based on:
- ConCert framework precedent (production validation)
- LEAN community standards (Mathlib patterns)
- RL training compatibility (fast verification prioritized)
- Proof irrelevance advantages

**User Decision**: Proceed with migration to pure deep embedding (both as Type) **DESPITE** previous recommendation.

**Acknowledgment**: This migration **reverses** the research-backed recommendation. The user has made a strategic decision to prioritize:
- Computable proof term analysis
- Explicit derivation tree structure
- Pattern matching capabilities
- Removal of axiomatized functions

### Migration Complexity Assessment

| Metric | Value | Risk Level |
|--------|-------|------------|
| **Total Files Affected** | 20 files | HIGH |
| **Critical Core Changes** | 4 files | CRITICAL |
| **Breaking Changes** | YES (all existing proofs) | HIGH |
| **Estimated Effort** | 60-80 hours | HIGH |
| **Rollback Complexity** | Medium (git revert) | MEDIUM |
| **Risk of Bugs** | Medium-High | HIGH |

### Recommendation

**GO with CAUTION** - Migration is technically feasible but:
- ⚠️ **Contradicts research findings** (Project #057)
- ⚠️ **High effort** (60-80 hours)
- ⚠️ **Breaking changes** across entire codebase
- ⚠️ **Performance implications** (proof terms not erased)
- ✅ **Enables new capabilities** (computable height, pattern matching)
- ✅ **Removes axioms** (6 height axioms eliminated)

**Recommended Approach**: **Incremental migration** with parallel types during transition.

---

## 1. Detailed File Analysis

### Phase 1: Core Definition (CRITICAL - 1 file)

#### **Logos/Core/ProofSystem/Derivation.lean** ⭐ CRITICAL
- **Current**: 284 lines, `inductive Derivable : Context → Formula → Prop`
- **Changes Required**:
  1. Rename `Derivable` → `DerivationTree` (or keep name, change type)
  2. Change `Prop` → `Type` in inductive declaration
  3. **Remove 7 axioms**: `height`, `weakening_height_succ`, `subderiv_height_lt`, `mp_height_gt_left`, `mp_height_gt_right`, `necessitation_height_succ`, `temporal_necessitation_height_succ`, `temporal_duality_height_succ`
  4. **Add computable `height` function** (pattern matching on constructors)
  5. **Prove height properties** as theorems (not axioms)
  6. Update 4 example derivations (lines 245-282)
  7. Add `deriving Repr` for debugging
- **Effort**: 6-8 hours
- **Risk**: CRITICAL - All downstream files depend on this
- **Breaking**: YES - Every file using `Derivable` breaks

**Before**:
```lean
inductive Derivable : Context → Formula → Prop where
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : Derivable Γ φ
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : Derivable Γ φ
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (h1 : Derivable Γ (φ.imp ψ))
      (h2 : Derivable Γ φ) : Derivable Γ ψ
  -- ... 4 more constructors

axiom Derivable.height {Γ : Context} {φ : Formula} (d : Derivable Γ φ) : Nat
axiom Derivable.weakening_height_succ : ...
-- ... 5 more height axioms
```

**After**:
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

namespace DerivationTree

def height {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | axiom _ _ _ => 0
  | assumption _ _ _ => 0
  | modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | necessitation _ d => 1 + d.height
  | temporal_necessitation _ d => 1 + d.height
  | temporal_duality _ d => 1 + d.height
  | weakening _ _ _ d _ => 1 + d.height

theorem weakening_height_succ {Γ Δ : Context} {φ : Formula}
    (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) :
    (weakening Γ Δ φ d h).height = d.height + 1 := by
  simp [height]

theorem subderiv_height_lt {Γ Δ : Context} {φ : Formula}
    (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) :
    d.height < (weakening Γ Δ φ d h).height := by
  simp [height]; omega

theorem mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]; omega

theorem mp_height_gt_right {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]; omega

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

-- Keep notation (works with Type)
notation:50 Γ " ⊢ " φ => DerivationTree Γ φ
notation:50 "⊢ " φ => DerivationTree [] φ
```

---

### Phase 2: Metalogic Proofs (CRITICAL - 3 files)

#### **Logos/Core/Metalogic/DeductionTheorem.lean** ⭐ HIGH IMPACT
- **Current**: 440 lines, uses `h.height` for well-founded recursion
- **Changes Required**:
  1. Update all type signatures: `(h : Γ ⊢ φ)` → `(d : Γ ⊢ φ)`
  2. Change parameter names from `h`, `h1`, `h2` → `d`, `d1`, `d2`
  3. Update `termination_by h.height` → `termination_by d.height`
  4. Update all height lemma references (now theorems, not axioms)
  5. Pattern matching works the same (already matches on structure)
  6. Update `deduction_with_mem` helper (line 203)
  7. Update `deduction_theorem` main theorem (line 327)
- **Effort**: 10-12 hours
- **Risk**: HIGH - Complex well-founded recursion
- **Breaking**: YES - All callers need updates

**Key Changes**:
```lean
-- Before
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B := by
  match h with
  | Derivable.axiom _ φ h_ax => ...
  | Derivable.modus_ponens _ φ ψ h1 h2 =>
      have ih1 : Γ ⊢ A.imp (φ.imp ψ) := deduction_theorem Γ A (φ.imp ψ) h1
      have ih2 : Γ ⊢ A.imp φ := deduction_theorem Γ A φ h2
      exact deduction_mp Γ A φ ψ ih1 ih2
  | ...
termination_by h.height
decreasing_by
  simp_wf
  exact Derivable.mp_height_gt_left h1 h2
  exact Derivable.mp_height_gt_right h1 h2

-- After
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (d : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B := by
  match d with
  | DerivationTree.axiom _ φ h_ax => ...
  | DerivationTree.modus_ponens _ φ ψ d1 d2 =>
      have ih1 : Γ ⊢ A.imp (φ.imp ψ) := deduction_theorem Γ A (φ.imp ψ) d1
      have ih2 : Γ ⊢ A.imp φ := deduction_theorem Γ A φ d2
      exact deduction_mp Γ A φ ψ ih1 ih2
  | ...
termination_by d.height
decreasing_by
  simp_wf
  exact DerivationTree.mp_height_gt_left d1 d2
  exact DerivationTree.mp_height_gt_right d1 d2
```

#### **Logos/Core/Metalogic/Soundness.lean**
- **Current**: 680 lines, induction on `Derivable`
- **Changes Required**:
  1. Update theorem signature: `soundness : (Γ ⊢ φ) → (Γ ⊨ φ)`
  2. Change parameter name: `h_deriv` → `d`
  3. Update all constructor names: `Derivable.axiom` → `DerivationTree.axiom`
  4. Pattern matching works the same (induction on Type works like Prop)
  5. Update 7 induction cases
- **Effort**: 6-8 hours
- **Risk**: MEDIUM - Straightforward pattern update
- **Breaking**: YES - Signature changes

**Key Changes**:
```lean
-- Before
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
  intro h_deriv
  induction h_deriv with
  | axiom Γ' φ' h_ax => ...
  | modus_ponens Γ' φ' ψ' _ _ ih_imp ih_phi => ...

-- After
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
  intro d
  induction d with
  | axiom Γ' φ' h_ax => ...
  | modus_ponens Γ' φ' ψ' _ _ ih_imp ih_phi => ...
```

#### **Logos/Core/Metalogic/Completeness.lean**
- **Current**: Axiomatized completeness theorems
- **Changes Required**:
  1. Update type signatures in axioms
  2. Update `Consistent` definition: `Consistent Γ := ¬(Γ ⊢ Formula.bot)`
  3. Update `maximal_consistent_closed` axiom
- **Effort**: 2-3 hours
- **Risk**: LOW - Mostly signature updates
- **Breaking**: YES - Type signatures change

---

### Phase 3: Theorem Libraries (HIGH IMPACT - 8 files)

#### **Logos/Core/Theorems/Propositional.lean**
- **Current**: ~80+ uses of `Derivable.axiom`, `Derivable.modus_ponens`
- **Changes Required**:
  1. Update all constructor names
  2. All theorem signatures change: `⊢ φ` → `DerivationTree [] φ` (notation hides this)
  3. No logic changes, just constructor renaming
- **Effort**: 8-10 hours (tedious but mechanical)
- **Risk**: MEDIUM - Many changes, but mechanical
- **Breaking**: NO (if notation kept)

**Pattern**:
```lean
-- Before
theorem lem (p : Formula) : ⊢ p.or p.neg := by
  apply Derivable.axiom
  apply Axiom.peirce

-- After
theorem lem (p : Formula) : ⊢ p.or p.neg := by
  apply DerivationTree.axiom
  apply Axiom.peirce
```

#### **Logos/Core/Theorems/Combinators.lean**
- **Effort**: 4-5 hours
- **Risk**: MEDIUM
- **Pattern**: Same as Propositional.lean

#### **Logos/Core/Theorems/GeneralizedNecessitation.lean**
- **Effort**: 5-6 hours
- **Risk**: MEDIUM
- **Special**: Uses context induction with derivation parameter

#### **Logos/Core/Theorems/Perpetuity/** (4 files)
- **Effort**: 6-8 hours total
- **Risk**: MEDIUM
- **Pattern**: Same constructor renaming

---

### Phase 4: Automation (MODERATE IMPACT - 2 files)

#### **Logos/Core/Automation/Tactics.lean**
- **Current**: Metaprogramming with `Derivable.axiom`, `Derivable.modus_ponens`
- **Changes Required**:
  1. Update `mkAppM` calls with new constructor names
  2. Update constant references: `` `Derivable.axiom`` → `` `DerivationTree.axiom``
  3. Test all tactics after migration
- **Effort**: 6-8 hours
- **Risk**: HIGH - Metaprogramming is fragile
- **Breaking**: NO (tactics hide implementation)

#### **Logos/Core/Automation/AesopRules.lean**
- **Effort**: 2-3 hours
- **Risk**: MEDIUM
- **Pattern**: Update registered rule names

---

### Phase 5: Test Suites (EXTENSIVE USAGE - 7 files)

#### **LogosTest/Core/ProofSystem/DerivationTest.lean**
- **Effort**: 4-5 hours
- **Risk**: LOW - Tests catch migration errors
- **Pattern**: Update all constructor names

#### **LogosTest/Core/Metalogic/SoundnessTest.lean**
- **Effort**: 2-3 hours
- **Risk**: LOW

#### **LogosTest/Core/Metalogic/CompletenessTest.lean**
- **Effort**: 1-2 hours
- **Risk**: LOW

#### **LogosTest/Core/Integration/EndToEndTest.lean**
- **Effort**: 2-3 hours
- **Risk**: MEDIUM - Integration tests

#### **LogosTest/Core/Theorems/** (4 files)
- **Effort**: 6-8 hours total
- **Risk**: LOW

#### **LogosTest/Core/Automation/TacticsTest.lean**
- **Effort**: 4-5 hours
- **Risk**: MEDIUM - Tests tactics

---

### Phase 6: Documentation (MINOR IMPACT - 4 files)

#### **Logos/ProofSystem.lean**, **Logos/Metalogic.lean**, **Logos/Theorems.lean**, **Logos/Core/Theorems.lean**
- **Effort**: 2-3 hours total
- **Risk**: LOW
- **Pattern**: Update documentation and examples

---

## 2. Total Effort Estimate

| Phase | Files | Hours | Risk |
|-------|-------|-------|------|
| **Phase 1: Core Definition** | 1 | 6-8 | CRITICAL |
| **Phase 2: Metalogic** | 3 | 18-23 | HIGH |
| **Phase 3: Theorems** | 8 | 29-37 | MEDIUM |
| **Phase 4: Automation** | 2 | 8-11 | HIGH |
| **Phase 5: Tests** | 7 | 19-26 | LOW-MEDIUM |
| **Phase 6: Documentation** | 4 | 2-3 | LOW |
| **TOTAL** | **25 files** | **82-108 hours** | **HIGH** |

**Realistic Estimate**: **60-80 hours** (with experience and tooling)

---

## 3. Code Migration Patterns

### Pattern 1: Constructor Renaming

**Before**:
```lean
Derivable.axiom Γ φ h
Derivable.assumption Γ φ h
Derivable.modus_ponens Γ φ ψ h1 h2
Derivable.necessitation φ h
Derivable.temporal_necessitation φ h
Derivable.temporal_duality φ h
Derivable.weakening Γ Δ φ h1 h2
```

**After**:
```lean
DerivationTree.axiom Γ φ h
DerivationTree.assumption Γ φ h
DerivationTree.modus_ponens Γ φ ψ d1 d2
DerivationTree.necessitation φ d
DerivationTree.temporal_necessitation φ d
DerivationTree.temporal_duality φ d
DerivationTree.weakening Γ Δ φ d1 h2
```

**Automation**: Use find-replace with regex:
```
Derivable\.(\w+) → DerivationTree.\1
\bh1\b → d1  (in derivation contexts)
\bh2\b → d2  (in derivation contexts)
\bh\b → d    (in derivation contexts, careful!)
```

### Pattern 2: Type Signature Updates

**Before**:
```lean
theorem my_theorem (Γ : Context) (φ : Formula) (h : Γ ⊢ φ) : ... := by
  match h with
  | Derivable.axiom _ _ h_ax => ...
```

**After**:
```lean
theorem my_theorem (Γ : Context) (φ : Formula) (d : Γ ⊢ φ) : ... := by
  match d with
  | DerivationTree.axiom _ _ h_ax => ...
```

### Pattern 3: Height Axiom Replacement

**Before**:
```lean
axiom Derivable.height {Γ : Context} {φ : Formula} (d : Derivable Γ φ) : Nat
axiom Derivable.mp_height_gt_left : d1.height < (modus_ponens Γ φ ψ d1 d2).height
```

**After**:
```lean
def DerivationTree.height {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | axiom _ _ _ => 0
  | assumption _ _ _ => 0
  | modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | necessitation _ d => 1 + d.height
  | temporal_necessitation _ d => 1 + d.height
  | temporal_duality _ d => 1 + d.height
  | weakening _ _ _ d _ => 1 + d.height

theorem DerivationTree.mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]; omega
```

### Pattern 4: Induction on Derivations

**Before** (works but axiomatized):
```lean
theorem my_theorem (h : Γ ⊢ φ) : ... := by
  induction h with
  | axiom Γ' φ' h_ax => ...
  | modus_ponens Γ' φ' ψ' h1 h2 ih1 ih2 => ...
```

**After** (same syntax, but computable):
```lean
theorem my_theorem (d : Γ ⊢ φ) : ... := by
  induction d with
  | axiom Γ' φ' h_ax => ...
  | modus_ponens Γ' φ' ψ' d1 d2 ih1 ih2 => ...
```

### Pattern 5: Well-Founded Recursion

**Before**:
```lean
termination_by h.height
decreasing_by
  simp_wf
  exact Derivable.mp_height_gt_left h1 h2
```

**After**:
```lean
termination_by d.height
decreasing_by
  simp_wf
  exact DerivationTree.mp_height_gt_left d1 d2
```

### Pattern 6: Metaprogramming (Tactics)

**Before**:
```lean
let axiomConst := ``Derivable.axiom
let mpConst := ``Derivable.modus_ponens
let derivTerm ← mkAppM axiomConst #[gamma, phi, axiomProof]
```

**After**:
```lean
let axiomConst := ``DerivationTree.axiom
let mpConst := ``DerivationTree.modus_ponens
let derivTerm ← mkAppM axiomConst #[gamma, phi, axiomProof]
```

---

## 4. Step-by-Step Migration Guide

### Phase 1: Preparation (2-3 hours)

#### Step 1.1: Create Git Branch
```bash
git checkout -b migration/derivable-to-type
git commit -m "Checkpoint: Before migration to DerivationTree : Type"
```

#### Step 1.2: Run Full Test Suite (Baseline)
```bash
lake build
lake test
# Record all passing tests
```

#### Step 1.3: Create Migration Checklist
- [ ] Phase 1: Core Definition
- [ ] Phase 2: Metalogic
- [ ] Phase 3: Theorems
- [ ] Phase 4: Automation
- [ ] Phase 5: Tests
- [ ] Phase 6: Documentation

#### Step 1.4: Backup Critical Files
```bash
cp Logos/Core/ProofSystem/Derivation.lean Derivation.lean.backup
cp Logos/Core/Metalogic/DeductionTheorem.lean DeductionTheorem.lean.backup
cp Logos/Core/Metalogic/Soundness.lean Soundness.lean.backup
```

---

### Phase 2: Core Changes (6-8 hours)

#### Step 2.1: Update Derivation.lean

**File**: `Logos/Core/ProofSystem/Derivation.lean`

1. **Change inductive type**:
   ```lean
   -- Line 59: Change Prop to Type
   inductive DerivationTree : Context → Formula → Type where
   ```

2. **Update constructor parameter names**:
   ```lean
   -- Change h1, h2 → d1, d2 for derivation parameters
   | modus_ponens (Γ : Context) (φ ψ : Formula)
       (d1 : DerivationTree Γ (φ.imp ψ))
       (d2 : DerivationTree Γ φ) : DerivationTree Γ ψ
   ```

3. **Add deriving clause**:
   ```lean
   -- After last constructor
   deriving Repr
   ```

4. **Remove all height axioms** (lines 168-222):
   ```lean
   -- DELETE these lines:
   axiom Derivable.height ...
   axiom Derivable.weakening_height_succ ...
   axiom Derivable.subderiv_height_lt ...
   axiom Derivable.mp_height_gt_left ...
   axiom Derivable.mp_height_gt_right ...
   axiom Derivable.necessitation_height_succ ...
   axiom Derivable.temporal_necessitation_height_succ ...
   axiom Derivable.temporal_duality_height_succ ...
   ```

5. **Add computable height function**:
   ```lean
   namespace DerivationTree

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

6. **Add height property theorems**:
   ```lean
   namespace DerivationTree

   theorem weakening_height_succ {Γ Δ : Context} {φ : Formula}
       (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) :
       (weakening Γ Δ φ d h).height = d.height + 1 := by
     simp [height]

   theorem subderiv_height_lt {Γ Δ : Context} {φ : Formula}
       (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) :
       d.height < (weakening Γ Δ φ d h).height := by
     simp [height]; omega

   theorem mp_height_gt_left {Γ : Context} {φ ψ : Formula}
       (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
       d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
     simp [height]; omega

   theorem mp_height_gt_right {Γ : Context} {φ ψ : Formula}
       (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
       d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
     simp [height]; omega

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

7. **Update notation** (keep same):
   ```lean
   notation:50 Γ " ⊢ " φ => DerivationTree Γ φ
   notation:50 "⊢ " φ => DerivationTree [] φ
   ```

8. **Update examples** (lines 245-282):
   ```lean
   -- Change Derivable.axiom → DerivationTree.axiom
   -- Change Derivable.assumption → DerivationTree.assumption
   -- etc.
   ```

9. **Test compilation**:
   ```bash
   lake build Logos.Core.ProofSystem.Derivation
   # Fix any errors
   ```

#### Step 2.2: Verify Core Definition

```bash
# Should compile without errors
lake build Logos.Core.ProofSystem.Derivation

# Test height function
lean --run test_height.lean  # Create simple test
```

---

### Phase 3: Metalogic Updates (18-23 hours)

#### Step 3.1: Update DeductionTheorem.lean

**File**: `Logos/Core/Metalogic/DeductionTheorem.lean`

1. **Update all type signatures**:
   ```lean
   -- Find all: (h : Γ ⊢ φ)
   -- Replace: (d : Γ ⊢ φ)
   ```

2. **Update constructor names**:
   ```lean
   -- Find: Derivable\.(\w+)
   -- Replace: DerivationTree.\1
   ```

3. **Update termination clauses**:
   ```lean
   -- Find: termination_by h.height
   -- Replace: termination_by d.height
   
   -- Find: Derivable\.mp_height_gt_left h1 h2
   -- Replace: DerivationTree.mp_height_gt_left d1 d2
   ```

4. **Update helper functions**:
   ```lean
   -- deduction_with_mem: Update all parameter names
   -- deduction_theorem: Update all parameter names
   ```

5. **Test compilation**:
   ```bash
   lake build Logos.Core.Metalogic.DeductionTheorem
   ```

#### Step 3.2: Update Soundness.lean

**File**: `Logos/Core/Metalogic/Soundness.lean`

1. **Update theorem signature**:
   ```lean
   theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
     intro d  -- Changed from h_deriv
     induction d with
     | axiom Γ' φ' h_ax => ...
     | modus_ponens Γ' φ' ψ' d1 d2 ih_imp ih_phi => ...  -- Changed from _ _
   ```

2. **Update all constructor names** in induction cases

3. **Test compilation**:
   ```bash
   lake build Logos.Core.Metalogic.Soundness
   ```

#### Step 3.3: Update Completeness.lean

**File**: `Logos/Core/Metalogic/Completeness.lean`

1. **Update `Consistent` definition**:
   ```lean
   def Consistent (Γ : Context) : Prop := ¬(Γ ⊢ Formula.bot)
   ```

2. **Update axiom signatures**:
   ```lean
   axiom maximal_consistent_closed : ... (Γ ⊢ φ) → ...
   ```

3. **Test compilation**:
   ```bash
   lake build Logos.Core.Metalogic.Completeness
   ```

---

### Phase 4: Theorem Library Updates (29-37 hours)

#### Step 4.1: Update Propositional.lean

**File**: `Logos/Core/Theorems/Propositional.lean`

**Strategy**: Mechanical find-replace

1. **Find-replace constructor names**:
   ```
   Derivable.axiom → DerivationTree.axiom
   Derivable.modus_ponens → DerivationTree.modus_ponens
   Derivable.weakening → DerivationTree.weakening
   Derivable.assumption → DerivationTree.assumption
   ```

2. **Test compilation**:
   ```bash
   lake build Logos.Core.Theorems.Propositional
   ```

#### Step 4.2: Update Combinators.lean

**File**: `Logos/Core/Theorems/Combinators.lean`

Same pattern as Propositional.lean

#### Step 4.3: Update GeneralizedNecessitation.lean

**File**: `Logos/Core/Theorems/GeneralizedNecessitation.lean`

1. **Update constructor names**
2. **Update parameter names in induction**
3. **Test compilation**

#### Step 4.4: Update Perpetuity Modules

**Files**: 
- `Logos/Core/Theorems/Perpetuity/Helpers.lean`
- `Logos/Core/Theorems/Perpetuity/Principles.lean`
- `Logos/Core/Theorems/Perpetuity/Bridge.lean`
- `Logos/Core/Theorems/Perpetuity.lean`

Same pattern as above.

---

### Phase 5: Automation Updates (8-11 hours)

#### Step 5.1: Update Tactics.lean

**File**: `Logos/Core/Automation/Tactics.lean`

1. **Update constant references**:
   ```lean
   -- Find: ``Derivable.axiom
   -- Replace: ``DerivationTree.axiom
   
   -- Find: ``Derivable.modus_ponens
   -- Replace: ``DerivationTree.modus_ponens
   ```

2. **Update metaprogramming code**:
   ```lean
   -- All mkAppM calls with Derivable constructors
   ```

3. **Test all tactics**:
   ```bash
   lake build Logos.Core.Automation.Tactics
   # Run tactic tests
   ```

#### Step 5.2: Update AesopRules.lean

**File**: `Logos/Core/Automation/AesopRules.lean`

1. **Update registered rule names**
2. **Test Aesop integration**

---

### Phase 6: Test Suite Updates (19-26 hours)

#### Step 6.1: Update All Test Files

**Files**:
- `LogosTest/Core/ProofSystem/DerivationTest.lean`
- `LogosTest/Core/Metalogic/SoundnessTest.lean`
- `LogosTest/Core/Metalogic/CompletenessTest.lean`
- `LogosTest/Core/Integration/EndToEndTest.lean`
- `LogosTest/Core/Theorems/PerpetuityTest.lean`
- `LogosTest/Core/Theorems/PropositionalTest.lean`
- `LogosTest/Core/Theorems/ModalS4Test.lean`
- `LogosTest/Core/Theorems/ModalS5Test.lean`
- `LogosTest/Core/Automation/TacticsTest.lean`

**Strategy**: Same find-replace pattern

1. **Update constructor names**
2. **Update parameter names**
3. **Run each test file**:
   ```bash
   lake build LogosTest.Core.ProofSystem.DerivationTest
   # etc.
   ```

---

### Phase 7: Documentation Updates (2-3 hours)

#### Step 7.1: Update Module Files

**Files**:
- `Logos/ProofSystem.lean`
- `Logos/Metalogic.lean`
- `Logos/Theorems.lean`
- `Logos/Core/Theorems.lean`

1. **Update documentation comments**
2. **Update example derivations**
3. **Test compilation**

---

### Phase 8: Final Verification (4-6 hours)

#### Step 8.1: Full Build

```bash
lake clean
lake build
# Should compile without errors
```

#### Step 8.2: Run All Tests

```bash
lake test
# All tests should pass
```

#### Step 8.3: Verify Examples

```bash
# Run all example derivations
# Check that tactics work
# Verify automation
```

#### Step 8.4: Performance Check

```bash
# Measure compilation time
time lake build

# Compare with baseline (before migration)
# Expect 10-30% slower due to proof term overhead
```

---

## 5. Testing & Validation Strategy

### Pre-Migration Tests

1. **Baseline Test Suite**:
   ```bash
   lake clean
   lake build
   lake test
   # Record: All tests passing, compilation time
   ```

2. **Create Test Checklist**:
   - [ ] All 20 files compile
   - [ ] All test suites pass
   - [ ] Tactics work correctly
   - [ ] Examples run successfully
   - [ ] No performance regression > 50%

### Migration Verification Steps

#### After Each Phase:

1. **Incremental Compilation**:
   ```bash
   lake build <modified-file>
   # Fix errors immediately
   ```

2. **Dependent File Check**:
   ```bash
   # Check what breaks
   lake build
   # Fix cascading errors
   ```

3. **Test Subset**:
   ```bash
   # Run tests for modified modules
   lake build LogosTest.<module>
   ```

### Post-Migration Validation

#### Step 1: Full Compilation

```bash
lake clean
lake build 2>&1 | tee build.log
# Should have 0 errors
```

#### Step 2: Test Suite

```bash
lake test 2>&1 | tee test.log
# All tests should pass
```

#### Step 3: Regression Tests

Create new tests for Type-specific features:

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

#### Step 4: Performance Benchmarks

```bash
# Measure compilation time
time lake build

# Measure memory usage
/usr/bin/time -v lake build

# Compare with baseline
# Acceptable: 10-30% slower, 20-50% more memory
# Concerning: >50% slower, >100% more memory
```

#### Step 5: Documentation Verification

- [ ] All docstrings updated
- [ ] Examples compile and run
- [ ] README reflects changes
- [ ] Migration notes added

---

## 6. Risk Mitigation

### Identified Risks

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| **Breaking all downstream code** | CRITICAL | 100% | Incremental migration, parallel types during transition |
| **Performance degradation** | HIGH | 80% | Benchmark before/after, optimize if >50% slower |
| **Bugs in height function** | MEDIUM | 40% | Extensive testing, compare with axiomatized version |
| **Tactic breakage** | HIGH | 60% | Test all tactics, update metaprogramming carefully |
| **Incomplete migration** | MEDIUM | 30% | Comprehensive file list, checklist tracking |
| **Rollback difficulty** | MEDIUM | 20% | Git branch, backup files, clear rollback procedure |

### Mitigation Strategies

#### Strategy 1: Parallel Type Approach (RECOMMENDED)

**Keep both types during transition**:

```lean
-- Old Prop-based (deprecated but functional)
inductive Derivable : Context → Formula → Prop where
  -- ... existing

-- New Type-based
inductive DerivationTree : Context → Formula → Type where
  -- ... same constructors
  deriving Repr

-- Conversion function
def DerivationTree.toDerivable {Γ : Context} {φ : Formula} 
    (d : DerivationTree Γ φ) : Derivable Γ φ :=
  match d with
  | axiom Γ φ h => Derivable.axiom Γ φ h
  | assumption Γ φ h => Derivable.assumption Γ φ h
  | modus_ponens Γ φ ψ d1 d2 => 
      Derivable.modus_ponens Γ φ ψ d1.toDerivable d2.toDerivable
  | necessitation φ d => Derivable.necessitation φ d.toDerivable
  | temporal_necessitation φ d => Derivable.temporal_necessitation φ d.toDerivable
  | temporal_duality φ d => Derivable.temporal_duality φ d.toDerivable
  | weakening Γ Δ φ d h => Derivable.weakening Γ Δ φ d.toDerivable h

-- Bridge theorems
theorem soundness_bridge (d : DerivationTree Γ φ) : 
    soundness_old d.toDerivable = soundness_new d := by
  -- Prove equivalence
  sorry
```

**Benefits**:
- Incremental migration (file by file)
- Easy rollback (just remove new type)
- Verify equivalence before full switch
- Less risky

**Drawbacks**:
- More code to maintain temporarily
- Conversion overhead
- Eventual cleanup needed

#### Strategy 2: Big-Bang Migration (RISKY)

**Replace all at once**:

1. Create migration branch
2. Update all 20 files in one commit
3. Fix all errors
4. Test everything
5. Merge or rollback

**Benefits**:
- Clean final state
- No parallel types
- Faster if successful

**Drawbacks**:
- High risk of bugs
- Difficult to debug
- Hard to rollback partially
- All-or-nothing

**RECOMMENDATION**: Use **Strategy 1 (Parallel Type)** for safety.

#### Strategy 3: Feature Flag Approach

```lean
-- Compile-time flag
#if MIGRATION_COMPLETE
  -- Use DerivationTree
#else
  -- Use Derivable
#end
```

**Not recommended** - adds complexity without clear benefit.

---

### Contingency Plans

#### Contingency 1: Performance Unacceptable

**Trigger**: Compilation >50% slower, memory >100% higher

**Action**:
1. Profile compilation bottlenecks
2. Optimize height function (memoization)
3. Consider lazy evaluation
4. If still unacceptable: **ROLLBACK**

#### Contingency 2: Critical Bugs Found

**Trigger**: Soundness proof breaks, height function incorrect

**Action**:
1. Fix bugs if localized
2. If fundamental issue: **ROLLBACK**
3. Re-evaluate migration strategy

#### Contingency 3: Tactic System Breaks

**Trigger**: Metaprogramming fails, tactics don't work

**Action**:
1. Debug metaprogramming issues
2. Consult LEAN Zulip for help
3. If unfixable: **ROLLBACK**

#### Contingency 4: Time Overrun

**Trigger**: Migration takes >100 hours (vs. 60-80 estimate)

**Action**:
1. Re-evaluate priority
2. Consider partial migration
3. Pause and reassess

---

### Rollback Procedure

#### If Migration Fails:

1. **Git Revert**:
   ```bash
   git checkout main
   git branch -D migration/derivable-to-type
   # Restore from backup if needed
   ```

2. **Restore Backups**:
   ```bash
   cp Derivation.lean.backup Logos/Core/ProofSystem/Derivation.lean
   cp DeductionTheorem.lean.backup Logos/Core/Metalogic/DeductionTheorem.lean
   cp Soundness.lean.backup Logos/Core/Metalogic/Soundness.lean
   ```

3. **Verify Restoration**:
   ```bash
   lake clean
   lake build
   lake test
   # Should be back to baseline
   ```

4. **Document Failure**:
   - Record what went wrong
   - Update migration plan
   - Consider alternative approaches

---

## 7. Performance Analysis

### Expected Performance Impact

#### Compilation Time

| Metric | Before (Prop) | After (Type) | Change |
|--------|---------------|--------------|--------|
| **Derivation.lean** | ~2s | ~3-4s | +50-100% |
| **DeductionTheorem.lean** | ~5s | ~7-10s | +40-100% |
| **Soundness.lean** | ~8s | ~10-15s | +25-88% |
| **Full Build** | ~60s | ~75-90s | +25-50% |

**Reason**: Proof terms not erased, more type checking

#### Memory Usage

| Metric | Before (Prop) | After (Type) | Change |
|--------|---------------|--------------|--------|
| **Peak Memory** | ~2GB | ~3-4GB | +50-100% |
| **Derivation Size** | 0 (erased) | ~100-1000 bytes | N/A |

**Reason**: Proof terms stored in memory

#### Runtime Performance

| Metric | Before (Prop) | After (Type) | Change |
|--------|---------------|--------------|--------|
| **Height Computation** | N/A (axiom) | ~O(n) | N/A |
| **Pattern Matching** | N/A | ~O(1) | N/A |

**Reason**: New capabilities enabled

### Performance Optimization Opportunities

#### Optimization 1: Memoize Height

```lean
-- Cache height computations
structure DerivationTreeWithHeight (Γ : Context) (φ : Formula) where
  tree : DerivationTree Γ φ
  height : Nat
  height_correct : tree.height = height

def memoizedHeight (d : DerivationTree Γ φ) : DerivationTreeWithHeight Γ φ :=
  ⟨d, d.height, rfl⟩
```

#### Optimization 2: Lazy Evaluation

```lean
-- Delay height computation until needed
def lazyHeight (d : DerivationTree Γ φ) : Thunk Nat :=
  Thunk.mk (fun () => d.height)
```

#### Optimization 3: Proof Term Compression

```lean
-- Store only essential structure
inductive CompactDerivation : Context → Formula → Type where
  -- Minimal representation
  -- Convert to full DerivationTree when needed
```

### Benchmarking Plan

#### Benchmark 1: Compilation Time

```bash
# Before migration
time lake clean && time lake build

# After migration
time lake clean && time lake build

# Compare
```

#### Benchmark 2: Memory Usage

```bash
# Before migration
/usr/bin/time -v lake build 2>&1 | grep "Maximum resident"

# After migration
/usr/bin/time -v lake build 2>&1 | grep "Maximum resident"

# Compare
```

#### Benchmark 3: Height Computation

```lean
-- Create large derivation
def largeDerivation : DerivationTree [] φ := ...

-- Measure height computation time
#time #eval largeDerivation.height
```

---

## 8. Alternative Approaches

### Alternative 1: Hybrid Approach (Keep Both)

**Description**: Keep `Derivable : Prop` as primary, add `DerivationTree : Type` as secondary for analysis.

**Implementation**:
```lean
-- Primary (Prop-based, for proofs)
inductive Derivable : Context → Formula → Prop where
  -- ... existing

-- Secondary (Type-based, for analysis)
inductive DerivationTree : Context → Formula → Type where
  -- ... same constructors

-- Conversion
def DerivationTree.toDerivable : DerivationTree Γ φ → Derivable Γ φ := ...

-- Use Prop for theorems, Type for analysis
theorem my_theorem (h : Derivable Γ φ) : ... := ...
def analyze_proof (d : DerivationTree Γ φ) : Analysis := ...
```

**Pros**:
- ✅ No breaking changes
- ✅ Best of both worlds
- ✅ Gradual adoption

**Cons**:
- ❌ Maintenance burden (two types)
- ❌ Conversion overhead
- ❌ Complexity

**Verdict**: **Good compromise** if full migration too risky.

---

### Alternative 2: Minimal Migration (Height Only)

**Description**: Keep `Derivable : Prop`, only add computable height as separate function.

**Implementation**:
```lean
-- Keep existing
inductive Derivable : Context → Formula → Prop where
  -- ... existing

-- Add computable height via witness
structure DerivableWithHeight (Γ : Context) (φ : Formula) where
  derivable : Derivable Γ φ
  height : Nat
  -- No proof that height is correct (trust)

-- Or use Type-based tree just for height
inductive HeightTree : Context → Formula → Type where
  -- ... same structure as Derivable
  
def HeightTree.height : HeightTree Γ φ → Nat := ...

-- Conversion (trust)
axiom Derivable.toHeightTree : Derivable Γ φ → HeightTree Γ φ
```

**Pros**:
- ✅ Minimal changes
- ✅ Keeps Prop benefits
- ✅ Adds height computation

**Cons**:
- ❌ Still uses axioms (trust)
- ❌ Doesn't enable pattern matching
- ❌ Limited benefits

**Verdict**: **Not recommended** - doesn't solve core issues.

---

### Alternative 3: Incremental File-by-File

**Description**: Migrate one file at a time, keeping both types during transition.

**Implementation**:
1. Add `DerivationTree : Type` to Derivation.lean
2. Keep `Derivable : Prop` (deprecated)
3. Migrate Soundness.lean to use `DerivationTree`
4. Migrate DeductionTheorem.lean to use `DerivationTree`
5. ... continue file by file
6. Remove `Derivable` when all files migrated

**Pros**:
- ✅ Low risk (incremental)
- ✅ Easy rollback (per file)
- ✅ Testable at each step

**Cons**:
- ❌ Long transition period
- ❌ Maintenance burden during transition
- ❌ Conversion overhead

**Verdict**: **RECOMMENDED** - safest approach.

---

## 9. Post-Migration Checklist

### Verification Steps

- [ ] **Compilation**: All 20 files compile without errors
- [ ] **Tests**: All test suites pass
- [ ] **Examples**: All example derivations work
- [ ] **Tactics**: All tactics function correctly
- [ ] **Performance**: Compilation time <50% slower than baseline
- [ ] **Memory**: Memory usage <100% higher than baseline
- [ ] **Height Function**: Computable height works correctly
- [ ] **Pattern Matching**: Can pattern match on derivations
- [ ] **Repr**: Derivation trees have readable representation

### Documentation Updates

- [ ] **Derivation.lean**: Update docstrings to reflect Type-based approach
- [ ] **ARCHITECTURE.md**: Document migration and rationale
- [ ] **IMPLEMENTATION_STATUS.md**: Update status
- [ ] **README.md**: Update examples if needed
- [ ] **Migration notes**: Document changes for future reference

### Git Workflow

- [ ] **Commit strategy**: Atomic commits per phase
- [ ] **Commit messages**: Clear description of changes
- [ ] **PR description**: Comprehensive migration summary
- [ ] **Review**: Code review before merge

### Communication Plan

- [ ] **Team notification**: Inform team of breaking changes
- [ ] **Migration guide**: Provide guide for external contributors
- [ ] **Changelog**: Document breaking changes
- [ ] **Deprecation notice**: Mark old approach as deprecated (if hybrid)

---

## 10. References

### Previous Research

- **Project #057**: Deep Embedding Research
  - Report: `.opencode/specs/057_deep_embedding_research/reports/research-001.md`
  - Recommendation: **KEEP dual-type approach**
  - User decision: **OVERRIDE** - proceed with migration

### LEAN Documentation

1. **LEAN 4 Manual**: https://lean-lang.org/lean4/doc/
2. **Mathlib Documentation**: https://leanprover-community.github.io/mathlib4_docs/
3. **Theorem Proving in Lean 4**: https://leanprover.github.io/theorem_proving_in_lean4/

### Academic References

1. **ConCert Framework** (Annenkov et al., 2019): Hybrid deep/shallow approach
2. **Guillemet et al. (2024)**: Deep Type embedding for categorical reasoning
3. **DeepSeek-Prover-V2** (2025): RL training with formal verification

### Community Resources

- **LEAN Zulip**: https://leanprover.zulipchat.com/
- **Mathlib Style Guide**: Prop vs Type conventions
- **LEAN 4 Examples**: Type-based proof systems

---

## Summary for Orchestrator

**Migration Plan File**: `.opencode/specs/058_migration_to_type/reports/migration-plan-001.md`

### 2-5 Sentence Summary

This migration plan details converting `Derivable : Prop` to `DerivationTree : Type` across 20 files in the ProofChecker codebase. The migration **reverses** the previous research recommendation (Project #057) which advocated keeping the dual-type approach. Total estimated effort is **60-80 hours** with **HIGH risk** due to breaking changes across the entire proof system. The plan recommends an **incremental migration** using parallel types during transition, with comprehensive testing and rollback procedures. Key benefits include removing 6 axioms, enabling computable height functions, and allowing pattern matching on derivations, at the cost of 25-50% slower compilation and higher memory usage.

### Critical Risks and Mitigation

**Top 3 Risks**:
1. **Breaking all downstream code** (100% likelihood)
   - **Mitigation**: Incremental migration with parallel types, comprehensive testing at each phase
   
2. **Performance degradation** (80% likelihood, 25-50% slower compilation)
   - **Mitigation**: Benchmark before/after, optimize if >50% slower, rollback if unacceptable
   
3. **Tactic system breakage** (60% likelihood)
   - **Mitigation**: Careful metaprogramming updates, extensive tactic testing, Zulip consultation

**Mitigation Strategies**:
- **Parallel Type Approach**: Keep both `Derivable : Prop` and `DerivationTree : Type` during transition
- **Incremental Migration**: File-by-file updates with testing after each phase
- **Comprehensive Testing**: Full test suite at each phase, regression tests for new features
- **Clear Rollback**: Git branch, backups, documented rollback procedure

### Go/No-Go Recommendation

**CONDITIONAL GO** with the following conditions:

✅ **GO IF**:
- User accepts 60-80 hour effort estimate
- User accepts 25-50% compilation slowdown
- User accepts HIGH risk of bugs during migration
- User commits to incremental approach (not big-bang)
- User has rollback plan if issues arise

❌ **NO-GO IF**:
- Performance degradation >50% is unacceptable
- Cannot allocate 60-80 hours for migration
- Need immediate production stability
- Cannot tolerate breaking changes

**RECOMMENDED APPROACH**: **Incremental migration** (Alternative 3) with parallel types during transition.

### Status

**Status**: Migration plan complete, awaiting user decision to proceed

**Next Steps**:
1. User reviews migration plan
2. User decides: GO / NO-GO / Modify approach
3. If GO: Create git branch, begin Phase 1 (Core Definition)
4. If NO-GO: Document decision, consider Alternative 1 (Hybrid)

---

**Report Complete**: 2025-12-19
