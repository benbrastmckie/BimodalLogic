# Project Structure Research: Remove Derivable Axioms from Perpetuity.lean

## Research Summary

This report documents the project structure and file dependencies relevant to removing derivable axioms from Perpetuity.lean.

## 1. Affected Files

### 1.1 Primary Target

**File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
- **Lines**: 662
- **Axioms to remove**: `pairing` (146), `perpetuity_4` (501), `perpetuity_5` (541), `perpetuity_6` (582)
- **Sorry to complete**: `contraposition` (306)

### 1.2 Supporting Files (Reference Only)

| File | Purpose | Modification Required |
|------|---------|----------------------|
| `Logos/Core/ProofSystem/Axioms.lean` | Axiom definitions | No |
| `Logos/Core/ProofSystem/Derivation.lean` | Derivation rules | No |
| `Logos/Core/Syntax/Formula.lean` | Formula definitions | No |
| `Logos/Core/Metalogic/Soundness.lean` | Soundness proofs | No (axiom soundness already proven) |

### 1.3 Documentation Files to Update

| File | Update Required |
|------|-----------------|
| `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` | Update axiom/sorry counts |
| `Documentation/ProjectInfo/SORRY_REGISTRY.md` | Remove entries for resolved sorries |
| `TODO.md` | Mark Task 18 complete |
| `CLAUDE.md` | Update perpetuity status |

### 1.4 Test Files

| File | New Tests Needed |
|------|------------------|
| `LogosTest/Core/Theorems/PerpetuityTest.lean` | Tests for derived P4-P6 |

## 2. Module Dependencies

### 2.1 Import Graph

```
Formula.lean
    ↓
Context.lean
    ↓
Axioms.lean
    ↓
Derivation.lean
    ↓
Perpetuity.lean  ← TARGET
    ↓
PerpetuityTest.lean
```

### 2.2 Key Dependencies in Perpetuity.lean

```lean
import Logos.Core.ProofSystem.Derivation  -- Derivable, ⊢ notation
import Logos.Core.Syntax.Formula          -- Formula, operators

-- Used axioms (from Axioms.lean):
-- - Axiom.prop_k (K axiom)
-- - Axiom.prop_s (S axiom)
-- - Axiom.modal_t (MT)
-- - Axiom.modal_4 (M4)
-- - Axiom.modal_b (MB)
-- - Axiom.modal_k_dist (MK distribution)
-- - Axiom.double_negation (DNE)
-- - Axiom.modal_future (MF)
-- - Axiom.temp_future (TF)
-- - Axiom.temp_4 (T4)
-- - Axiom.temp_a (TA)

-- Used rules (from Derivation.lean):
-- - Derivable.axiom
-- - Derivable.modus_ponens
-- - Derivable.temporal_duality
-- - Derivable.necessitation
```

## 3. Current Axiom/Sorry Counts

### 3.1 In Perpetuity.lean

| Type | Count | Details |
|------|-------|---------|
| Axioms | 4 | `pairing`, `perpetuity_4`, `perpetuity_5`, `perpetuity_6` |
| Sorry | 1 | `contraposition` (line 306) |
| Theorems | 20+ | `imp_trans`, `mp`, `identity`, `perpetuity_1`, `perpetuity_2`, `perpetuity_3`, etc. |

### 3.2 After Task 18 Completion

| Scenario | Axioms | Sorry |
|----------|--------|-------|
| Full completion | 0 | 0 |
| Keep pairing | 1 | 0 |
| P4-P6 only | 1 | 0 |

## 4. Existing Helper Lemmas

### 4.1 Propositional Helpers

```lean
-- Line 85-93
theorem imp_trans {A B C : Formula}
    (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C

-- Line 98-99
theorem mp {A B : Formula} (h1 : ⊢ A) (h2 : ⊢ A.imp B) : ⊢ B

-- Line 109-115
theorem identity (A : Formula) : ⊢ A.imp A
```

### 4.2 Conjunction Helpers

```lean
-- Line 159-167
theorem combine_imp_conj {P A B : Formula}
    (hA : ⊢ P.imp A) (hB : ⊢ P.imp B) : ⊢ P.imp (A.and B)

-- Line 176-179
theorem combine_imp_conj_3 {P A B C : Formula}
    (hA : ⊢ P.imp A) (hB : ⊢ P.imp B) (hC : ⊢ P.imp C) : ⊢ P.imp (A.and (B.and C))
```

### 4.3 Temporal Helpers

```lean
-- Line 198-201
theorem box_to_future (φ : Formula) : ⊢ φ.box.imp φ.all_future

-- Line 214-219
theorem box_to_past (φ : Formula) : ⊢ φ.box.imp φ.all_past

-- Line 224
theorem box_to_present (φ : Formula) : ⊢ φ.box.imp φ

-- Line 344-350
theorem box_to_box_past (φ : Formula) : ⊢ φ.box.imp (φ.all_past.box)
```

### 4.4 Box Conjunction Helpers

```lean
-- Line 366-390
theorem box_conj_intro {A B : Formula}
    (hA : ⊢ A.box) (hB : ⊢ B.box) : ⊢ (A.and B).box

-- Line 400-426
theorem box_conj_intro_imp {P A B : Formula}
    (hA : ⊢ P.imp A.box) (hB : ⊢ P.imp B.box) : ⊢ P.imp (A.and B).box

-- Line 432-436
theorem box_conj_intro_imp_3 {P A B C : Formula}
    (hA : ⊢ P.imp A.box) (hB : ⊢ P.imp B.box) (hC : ⊢ P.imp C.box) :
    ⊢ P.imp (A.and (B.and C)).box
```

## 5. New Helpers Needed

### 5.1 For contraposition

```lean
-- B combinator (composition)
theorem b_combinator {A B C : Formula} : ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C))
```

### 5.2 For P4

```lean
-- DNE for boxed formulas
theorem dne_box_bridge {A : Formula} : ⊢ A.neg.neg.box.neg.imp A.box.neg

-- Or formula identity lemmas
lemma sometimes_diamond_eq_neg_always_box_neg (φ : Formula) :
  φ.sometimes.diamond = φ.neg.always.box.neg := rfl  -- Check if definitionally equal
```

### 5.3 For P5

```lean
-- Persistence lemma
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always

-- Or diamond-box interaction lemmas
theorem diamond_to_box_diamond (φ : Formula) : ⊢ φ.imp φ.diamond.box  -- MB
```

### 5.4 For P6

```lean
-- Operator duality lemmas
theorem sometimes_neg_eq_neg_always (φ : Formula) :
  φ.neg.sometimes = φ.always.neg := rfl  -- Check

theorem diamond_neg_eq_neg_box (φ : Formula) :
  φ.neg.diamond = φ.box.neg := rfl  -- Check
```

## 6. Build and Test Commands

### 6.1 Development Commands

```bash
# Type-check Perpetuity.lean only
lake env lean Logos/Core/Theorems/Perpetuity.lean

# Build full project
lake build

# Run tests
lake test

# Check specific test file
lake env lean LogosTest/Core/Theorems/PerpetuityTest.lean
```

### 6.2 Verification Commands

```bash
# Count remaining sorry markers
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean

# Count remaining axioms
grep -c "^axiom " Logos/Core/Theorems/Perpetuity.lean

# Verify build
lake build 2>&1 | grep -i error
```

## 7. Code Patterns

### 7.1 Axiom to Theorem Conversion

```lean
-- Before (axiom):
axiom perpetuity_4 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond

-- After (theorem):
theorem perpetuity_4 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := by
  -- proof here
```

### 7.2 Sorry Completion Pattern

```lean
-- Before (sorry):
theorem contraposition {A B : Formula}
    (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  sorry

-- After (complete):
theorem contraposition {A B : Formula}
    (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  have b_comb : ⊢ B.neg.imp ((A.imp B).imp A.neg) := by
    -- B combinator derivation
  exact Derivable.modus_ponens [] _ _ (imp_trans b_comb (identity _)) h
```

### 7.3 Test Pattern

```lean
-- In PerpetuityTest.lean
/-- Test P4 derivation with specific formula -/
example : ⊢ (Formula.atom "p").sometimes.diamond.imp (Formula.atom "p").diamond := by
  exact perpetuity_4 (Formula.atom "p")
```

## 8. Documentation Update Checklist

### 8.1 IMPLEMENTATION_STATUS.md

- [ ] Update Perpetuity module status
- [ ] Update axiom count (4 → 0 or 4 → 1)
- [ ] Update sorry count (1 → 0)
- [ ] Update Known Limitations section

### 8.2 SORRY_REGISTRY.md

- [ ] Remove `contraposition` entry
- [ ] Add resolution notes

### 8.3 TODO.md

- [ ] Mark Task 18 complete
- [ ] Add completion date
- [ ] Reference summary file

### 8.4 CLAUDE.md

- [ ] Update perpetuity status in Theorems Package section
- [ ] Update "Helper Lemmas Proven" list
- [ ] Update "Axioms Used" section
- [ ] Update "Sorry Count" field

## 9. Risk Assessment

### 9.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Formula equality issues | High | Medium | Add simp lemmas if needed |
| Complex modal lifting | High | High | May need additional helper lemmas |
| Build time increase | Low | Low | Proofs are static, minimal runtime impact |
| Breaking existing tests | Low | Medium | Regression testing |

### 9.2 Scope Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| P5/P6 too complex | Medium | Medium | Keep axiomatized as fallback |
| Pairing derivation scope creep | Low | Low | Explicitly out of scope |

## 10. Recommendations

1. **Incremental implementation**: Complete contraposition first, then P4, then P5/P6
2. **Helper lemmas**: Create reusable combinators (B combinator) and DNE bridges
3. **Formula inspection**: Verify definitional equalities before complex proofs
4. **Test coverage**: Add tests for each derived theorem
5. **Documentation**: Update all docs in final phase
