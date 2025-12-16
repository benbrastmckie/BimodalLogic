# Project Structure Analysis for P5 Implementation

## Executive Summary

This report analyzes the Logos project structure to identify the exact files, locations, and dependencies for implementing the P5 perpetuity theorem derivation.

## File Inventory

### Primary Implementation File

**Logos/Core/Theorems/Perpetuity.lean**
- **Current Size**: ~1035 lines
- **Contains**: P1-P6 perpetuity principles and helper lemmas
- **Status**: P1-P4 fully proven, P5-P6 axiomatized
- **Sorry Count**: 1 (persistence lemma at line 827)
- **Axiom Count**: 4 (pairing, dni, perpetuity_5, perpetuity_6)

### Supporting Files

**Logos/Core/ProofSystem/Axioms.lean**
- **Size**: ~201 lines
- **Contains**: 12 TM axiom schemata
- **Relevant Axioms**: modal_4, modal_b, modal_k_dist
- **No changes needed**: All required axioms already present

**Logos/Core/ProofSystem/Derivation.lean**
- **Contains**: Derivable inductive type, inference rules
- **Relevant**: necessitation, modus_ponens, temporal_duality
- **No changes needed**: All required rules already present

**Logos/Core/Syntax/Formula.lean**
- **Contains**: Formula type definition, derived operators
- **Relevant Definitions**: diamond, always, sometimes
- **Relevant Function**: swap_temporal for temporal duality

### Test Files

**LogosTest/Core/Theorems/PerpetuityTest.lean**
- **Contains**: Tests for perpetuity principles
- **Will Need**: Updates for P5, P6 as theorems instead of axioms

## Current Code Analysis

### Existing Helper Theorems (Perpetuity.lean)

**Propositional Helpers** (lines 85-174):
- `imp_trans`: Transitivity of implication ✓
- `mp`: Modus ponens wrapper ✓
- `identity`: SKK identity combinator ✓
- `b_combinator`: Composition (B → C) → (A → B) → (A → C) ✓
- `contraposition`: Classical contraposition from B combinator ✓

**Conjunction Helpers** (lines 175-236):
- `pairing` (axiom): A → B → A ∧ B
- `combine_imp_conj`: P → A and P → B implies P → A ∧ B ✓
- `combine_imp_conj_3`: Three-way version ✓

**Temporal Helpers** (lines 239-282):
- `box_to_future`: □φ → Gφ ✓
- `box_to_past`: □φ → Hφ ✓
- `box_to_present`: □φ → φ ✓

**Box Conjunction Helpers** (lines 486-609):
- `box_to_box_past`: □φ → □Hφ ✓
- `box_conj_intro`: From □A and □B derive □(A ∧ B) ✓
- `box_conj_intro_imp`: P → □A and P → □B implies P → □(A ∧ B) ✓
- `box_conj_intro_imp_3`: Three-way version ✓

**Diamond/Persistence Helpers** (lines 732-827):
- `mb_diamond`: φ → □◇φ (MB axiom instantiation) ✓
- `box_diamond_to_future_box_diamond`: □◇φ → F□◇φ ✓
- `box_diamond_to_past_box_diamond`: □◇φ → H□◇φ ✓
- `persistence`: ◇φ → △◇φ **SORRY** (blocked at ◇φ → □◇φ)

### Current Axioms in Perpetuity.lean

1. **pairing** (line 174): `⊢ A → B → A ∧ B`
   - Status: Keep as axiom (derivation from K+S would be ~50+ lines, low value)

2. **dni** (line 203): `⊢ A → ¬¬A` (double negation introduction)
   - Status: Keep as axiom (needed for P4 derivation, already used)

3. **perpetuity_5** (line 859): `⊢ ◇▽φ → △◇φ`
   - Status: **CONVERT TO THEOREM** (target of this implementation)

4. **perpetuity_6** (line 926): `⊢ ▽□φ → □△φ`
   - Status: **CONVERT TO THEOREM** (secondary target)

## Insertion Points

### New Helper Theorems Location

Insert new helpers after `contraposition` (line 453) and before the P2 theorem section:

```lean
-- Line ~453: After contraposition theorem
-- Insert: diamond_4, modal_5

/-!
## Helper Lemmas: S5 Diamond Properties
-/

/-- Diamond 4: ◇◇φ → ◇φ (derived from M4 via contraposition) -/
theorem diamond_4 (φ : Formula) : ⊢ φ.diamond.diamond.imp φ.diamond := ...

/-- Modal 5: ◇φ → □◇φ (S5 characteristic for diamond, derived from MB + diamond_4 + MK) -/
theorem modal_5 (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.box := ...
```

### Temporal Distribution Helpers Location

Insert after the box_diamond helpers (line ~762) and before persistence:

```lean
-- Line ~762: After box_diamond_to_past_box_diamond
-- Insert: temporal_k_dist helpers

/-!
## Helper Lemmas: Temporal K Distribution
-/

/-- Temporal K distribution for past: H(A → B) → (HA → HB) -/
theorem temp_k_dist_past (A B : Formula) :
    ⊢ (A.imp B).all_past.imp (A.all_past.imp B.all_past) := ...

/-- Temporal K distribution for future: G(A → B) → (GA → GB) -/
theorem temp_k_dist_future (A B : Formula) :
    ⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future) := ...
```

### Persistence Theorem Fix Location

Replace the sorry at line 827:

```lean
-- Line 827: Replace sorry with complete proof using modal_5
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always := by
  -- Use modal_5 to bridge from ◇φ to □◇φ
  have m5 : ⊢ φ.diamond.imp φ.diamond.box := modal_5 φ
  -- ... complete derivation
```

### P5 Axiom → Theorem Conversion

Replace lines 859 (axiom perpetuity_5) with:

```lean
/-- P5: ◇▽φ → △◇φ (persistent possibility) - DERIVED from P4 + persistence -/
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  have p4 : ⊢ φ.sometimes.diamond.imp φ.diamond := perpetuity_4 φ
  have pers : ⊢ φ.diamond.imp φ.diamond.always := persistence φ
  exact imp_trans p4 pers
```

### P6 Axiom → Theorem Conversion

Replace lines 926 (axiom perpetuity_6) with derived theorem.

## Dependency Analysis

### Import Dependencies

Perpetuity.lean imports:
- `Logos.Core.ProofSystem.Derivation` (for Derivable, inference rules)
- `Logos.Core.Syntax.Formula` (for Formula type)

No new imports needed.

### Theorem Dependencies (Partial Order)

```
contraposition (existing)
    |
    v
diamond_4 (new)
    |
    v
mb_diamond (existing) ---+
                         |
modal_k_dist (axiom) ----+
                         |
                         v
                    modal_5 (new)
                         |
                         v
box_diamond_to_future_box_diamond (existing) -+
                                              |
box_diamond_to_past_box_diamond (existing) ---+
                                              |
temp_k_dist_future (new) ---------------------+
                                              |
temp_k_dist_past (new) -----------------------+
                                              |
                                              v
                                    persistence (fix sorry)
                                              |
perpetuity_4 (existing) ----------------------+
                                              |
                                              v
                                    perpetuity_5 (convert from axiom)
                                              |
                                              v
                                    perpetuity_6 (convert from axiom)
```

## Test Impact Analysis

### Existing Tests in PerpetuityTest.lean

Tests reference:
- `perpetuity_1` through `perpetuity_6`

Converting P5 and P6 from axioms to theorems should not break tests since:
- The type signature remains the same: `⊢ Formula → Prop`
- Tests use the theorems, not the axiom constructors

### New Tests Needed

1. Test `diamond_4` with example formulas
2. Test `modal_5` with example formulas
3. Verify P5 and P6 still work after conversion
4. Add tests for `temp_k_dist_past` and `temp_k_dist_future`

## Documentation Updates

### Files Requiring Updates

1. **Perpetuity.lean** (docstrings):
   - Update module docstring (lines 5-60) to reflect P5, P6 as theorems
   - Update Summary section (lines 929-1011)
   - Update Implementation Status section

2. **Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md**:
   - Update perpetuity theorem status
   - Update sorry count

3. **Documentation/ProjectInfo/SORRY_REGISTRY.md**:
   - Remove persistence lemma from sorry list
   - Update counts

4. **TODO.md**:
   - Update Task 18 and Task 19 status

5. **CLAUDE.md**:
   - Update Theorems Package description

## Build Verification Steps

1. `lake clean` - Clean build artifacts
2. `lake build` - Full rebuild
3. `lake test` - Run test suite
4. `lake lint` - Check for lint warnings

## Summary

### Files to Modify

| File | Changes |
|------|---------|
| Logos/Core/Theorems/Perpetuity.lean | Add diamond_4, modal_5, temp_k_dist_*, fix persistence, convert P5/P6 |
| LogosTest/Core/Theorems/PerpetuityTest.lean | Add tests for new theorems |
| Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md | Update status |
| Documentation/ProjectInfo/SORRY_REGISTRY.md | Remove persistence sorry |
| TODO.md | Update Task 18, 19 status |

### Estimated Lines of Change

- New code in Perpetuity.lean: ~150-200 lines
- Test additions: ~30-50 lines
- Documentation updates: ~50 lines
- **Total**: ~230-300 lines
