# Research Report: Temporal Operator Convention Refactoring and Repository Cleanup

**Date**: 2025-12-04
**Task Reference**: TODO.md Task 14 (expanded scope)
**Research Complexity**: 3 (Medium-High)

---

## Executive Summary

This research analyzes the comprehensive refactoring needed to:
1. **Clean repository cruft**: Remove unused `BackwardPersistence` and `ModalTemporalPersistence` definitions from Soundness.lean
2. **Standardize temporal operator naming**: Migrate from current naming (`past`/`future`/`sometime_past`/`sometime_future`) to standard temporal logic notation (`H`/`G`/`P`/`F`)
3. **Update all documentation**: Ensure consistent terminology across code, docstrings, and markdown files

**Scope**: 38+ files across Lean source code, tests, archive examples, and documentation.

---

## Part 1: Cruft Removal Analysis (Task 14 Original Scope)

### 1.1 Unused Frame Constraint Definitions

After aligning the `always` operator with the JPL paper definition (`Pφ ∧ φ ∧ Fφ`), the TL, MF, and TF axiom proofs no longer require frame constraints. Two definitions in Soundness.lean are now completely unused:

#### BackwardPersistence (Lines 99-123)

```lean
def BackwardPersistence (F : TaskFrame) : Prop :=
  ∀ (M : TaskModel F) (τ : WorldHistory F) (t₁ t₂ : Int) (φ : Formula),
    t₁ < t₂ →
    (∀ (s : Int) (hs : τ.domain s), s ≥ t₂ → truth_at M τ s hs φ) →
    (∀ (r : Int) (hr : τ.domain r), t₁ ≤ r → r < t₂ → truth_at M τ r hr φ)
```

**Status**: UNUSED - The TL axiom proof uses the `always` definition directly without this frame property.

#### ModalTemporalPersistence (Lines 125-149)

```lean
def ModalTemporalPersistence (F : TaskFrame) : Prop :=
  ∀ (M : TaskModel F) (t s : Int) (φ : Formula),
    t < s →
    (∀ (σ : WorldHistory F) (hσ : σ.domain t), truth_at M σ t hσ φ) →
    (∀ (σ : WorldHistory F) (hσ : σ.domain s), truth_at M σ s hσ φ)
```

**Status**: UNUSED - MF and TF axiom proofs use time-shift infrastructure instead.

### 1.2 Misleading Documentation in Soundness.lean

The module docstring and individual theorem docstrings contain outdated claims about conditional validity:

| Line | Outdated Content | Correct Information |
|------|------------------|---------------------|
| 19-20 | "specific frame properties... not guaranteed" | Frame properties are not needed |
| 33 | "TL axiom (conditional on BackwardPersistence)" | TL axiom is unconditionally valid |
| 34-35 | "MF/TF axiom (conditional on ModalTemporalPersistence)" | MF/TF use time-shift, not frame constraints |
| 45-47 | "Requires X frame property" | Obsolete comments |
| 399 | "Frame Constraint Required (MVP): ModalTemporalPersistence" | Not required |
| 452 | "Frame Constraint (MVP Alternative): ModalTemporalPersistence" | Not required |

### 1.3 External Documentation Cruft

Files containing outdated frame constraint references:
- `CLAUDE.md`: Line 191 mentions "require frame constraints" for incomplete axioms
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`: Frame constraint references
- `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`: May have outdated limitation sections

---

## Part 2: Temporal Operator Convention Refactoring

### 2.1 Current vs. Standard Naming

| Current Name | Standard Name | Meaning | Type |
|--------------|---------------|---------|------|
| `past` | `H` | Universal past ("historically") | Constructor |
| `future` | `G` | Universal future ("globally") | Constructor |
| `sometime_past` | `P` | Existential past ("once") | Derived |
| `sometime_future` | `F` | Existential future ("eventually") | Derived |
| `always` | Keep or rename to `A` | All times (H ∧ φ ∧ G) | Derived |
| `sometimes` | Keep or rename to `E` | Some time | Derived |

**Note**: The GLOSSARY.md already correctly maps `H`/`G`/`P`/`F` to the operators, confirming this is the intended standard.

### 2.2 Current Definition Structure

From `Logos/Core/Syntax/Formula.lean`:

```lean
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | past : Formula → Formula      -- ← Rename to H
  | future : Formula → Formula    -- ← Rename to G
```

Derived operators:
```lean
def sometime_past (φ : Formula) : Formula := φ.neg.past.neg   -- P = ¬H¬
def sometime_future (φ : Formula) : Formula := φ.sometimes    -- F = ¬G¬
def always (φ : Formula) : Formula := φ.past.and (φ.and φ.future)  -- A = H ∧ φ ∧ G
def sometimes (φ : Formula) : Formula := φ.neg.always.neg     -- E = ¬A¬
```

### 2.3 Impact Analysis by File Category

#### Core Lean Source Files (Critical - 10 files)

| File | Occurrences | Impact |
|------|-------------|--------|
| `Logos/Core/Syntax/Formula.lean` | 25+ | Constructor definitions, derived operators |
| `Logos/Core/ProofSystem/Axioms.lean` | 12+ | Axiom definitions with temporal operators |
| `Logos/Core/ProofSystem/Derivation.lean` | 8+ | Temporal K rule comments |
| `Logos/Core/Semantics/Truth.lean` | 15+ | Truth evaluation for past/future |
| `Logos/Core/Semantics/WorldHistory.lean` | 10+ | Temporal domain structure |
| `Logos/Core/Metalogic/Soundness.lean` | 20+ | Axiom validity proofs |
| `Logos/Core/Theorems/Perpetuity.lean` | 15+ | Perpetuity principles |
| `Logos/Core/Automation/Tactics.lean` | 5+ | Temporal tactic helpers |
| `Logos/Core/Automation/ProofSearch.lean` | 5+ | Proof search patterns |
| `Logos/Core/Semantics/TaskModel.lean` | 3+ | Model structure |

#### Test Files (High Priority - 8 files)

| File | Impact |
|------|--------|
| `LogosTest/Core/Syntax/FormulaTest.lean` | Tests for all temporal operators |
| `LogosTest/Core/ProofSystem/AxiomsTest.lean` | Temporal axiom tests |
| `LogosTest/Core/ProofSystem/DerivationTest.lean` | Temporal K and duality tests |
| `LogosTest/Core/Metalogic/SoundnessTest.lean` | Soundness tests |
| `LogosTest/Core/Automation/TacticsTest.lean` | Tactic tests |
| `LogosTest/Core/Theorems/PerpetuityTest.lean` | Perpetuity principle tests |

#### Archive Examples (3 files)

| File | Impact |
|------|--------|
| `Archive/TemporalProofs.lean` | Temporal proof examples |
| `Archive/BimodalProofs.lean` | Combined modal-temporal examples |
| `Archive/TemporalStructures.lean` | Temporal structure definitions |

#### Documentation Files (12+ files)

| File | Priority | Impact |
|------|----------|--------|
| `Documentation/Reference/OPERATORS.md` | Critical | Master reference, 50+ occurrences |
| `Documentation/Reference/GLOSSARY.md` | High | Already uses H/G/P/F (verify consistency) |
| `Documentation/UserGuide/ARCHITECTURE.md` | Very High | 40+ occurrences |
| `Documentation/UserGuide/TUTORIAL.md` | High | 15+ occurrences |
| `Documentation/UserGuide/EXAMPLES.md` | High | 25+ occurrences |
| `Documentation/Development/LEAN_STYLE_GUIDE.md` | Moderate | 5+ occurrences |
| `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` | Moderate | 5+ occurrences |
| `CLAUDE.md` | High | 10+ occurrences |
| `README.md` | High | 8+ occurrences |
| `TODO.md` | Moderate | Task 14 references |

### 2.4 Rename Strategy

#### Phase 1: Constructor Renaming (Breaking Change)

```lean
-- Before
| past : Formula → Formula
| future : Formula → Formula

-- After
| H : Formula → Formula    -- "historically" / universal past
| G : Formula → Formula    -- "globally" / universal future
```

#### Phase 2: Derived Operator Renaming

```lean
-- Before
def sometime_past (φ : Formula) : Formula := φ.neg.past.neg
def sometime_future (φ : Formula) : Formula := φ.sometimes

-- After
def P (φ : Formula) : Formula := φ.neg.H.neg  -- existential past
def F (φ : Formula) : Formula := φ.neg.G.neg  -- existential future
```

#### Phase 3: Update swap function

```lean
-- Before
def swap_past_future : Formula → Formula

-- After
def swap_H_G : Formula → Formula  -- or keep as swap_past_future with updated implementation
```

### 2.5 Search/Replace Patterns

**Constructor References**:
```
Formula.past    → Formula.H
Formula.future  → Formula.G
.past           → .H         (when preceded by Formula type)
.future         → .G         (when preceded by Formula type)
| past φ        → | H φ      (pattern matching)
| future φ      → | G φ      (pattern matching)
```

**Derived Operator References**:
```
sometime_past   → P
sometime_future → F
.sometime_past  → .P
.sometime_future → .F
```

**Function References**:
```
swap_past_future → swap_H_G  (optional - could keep for clarity)
```

**Documentation References**:
```
Past φ / Past(φ) → H φ / H(φ)
Future φ / Future(φ) → G φ / G(φ)
"universal past" → "H operator (universal past)"
"universal future" → "G operator (universal future)"
"sometime past" → "P operator (existential past)"
"sometime future" → "F operator (existential future)"
```

---

## Part 3: Risk Analysis

### 3.1 Breaking Changes

1. **Constructor Renaming**: All pattern matches on `past`/`future` will break
2. **Function Renaming**: All calls to `sometime_past`/`sometime_future` will break
3. **Import Dependencies**: No external dependencies (Logos is self-contained)

### 3.2 Mitigation Strategies

1. **Deprecation Aliases**: Temporarily provide aliases for old names
   ```lean
   @[deprecated "Use Formula.H instead"]
   abbrev past := H
   ```

2. **Atomic Commit**: Make all changes in a single commit to maintain consistency

3. **Test-First Verification**: Run `lake test` after each phase to catch issues

### 3.3 Complexity Assessment

- **Code Changes**: ~150-200 occurrences across Lean files
- **Documentation Changes**: ~300-400 occurrences
- **Estimated Effort**: 4-6 hours total (expanded from Task 14's 3-5 hours)

---

## Part 4: Verification Commands

```bash
# Verify cruft removal
grep -rn "BackwardPersistence\|ModalTemporalPersistence" Logos/

# Verify temporal renaming completeness
grep -rn "\.past\|\.future" Logos/
grep -rn "sometime_past\|sometime_future" Logos/
grep -rn "swap_past_future" Logos/

# Verify documentation consistency
grep -rn "Past φ\|Future φ" Documentation/
grep -rn "universal past\|universal future" Documentation/

# Build verification
lake build && lake test && lake lint
```

---

## Part 5: Recommendations

### 5.1 Phased Approach

**Phase 0**: Remove unused cruft (BackwardPersistence, ModalTemporalPersistence)
**Phase 1**: Rename constructors (`past` → `H`, `future` → `G`)
**Phase 2**: Rename derived operators (`sometime_past` → `P`, `sometime_future` → `F`)
**Phase 3**: Update swap function and related utilities
**Phase 4**: Update all tests
**Phase 5**: Update archive examples
**Phase 6**: Update documentation
**Phase 7**: Final verification and cleanup

### 5.2 Decision Points

1. **Keep `always`/`sometimes` or rename to `A`/`E`?**
   - Recommendation: Keep `always`/`sometimes` - they are more readable and `△`/`▽` notation is already established

2. **Rename `swap_past_future` to `swap_H_G`?**
   - Recommendation: Keep as `swap_past_future` for clarity, just update internal references

3. **Provide backward-compatibility aliases?**
   - Recommendation: No - clean break is preferred for codebase hygiene

### 5.3 Documentation Strategy

After code changes, update documentation in this order:
1. `Documentation/Reference/OPERATORS.md` (master reference)
2. `Documentation/Reference/GLOSSARY.md` (verify consistency)
3. `Documentation/UserGuide/ARCHITECTURE.md` (formal specification)
4. `CLAUDE.md` (development reference)
5. `README.md` (public-facing)
6. Other documentation files

---

## Appendix A: Complete File List

### Files Requiring Code Changes (18 files)

1. `Logos/Core/Syntax/Formula.lean`
2. `Logos/Core/Syntax/Context.lean`
3. `Logos/Core/ProofSystem/Axioms.lean`
4. `Logos/Core/ProofSystem/Derivation.lean`
5. `Logos/Core/Semantics/Truth.lean`
6. `Logos/Core/Semantics/WorldHistory.lean`
7. `Logos/Core/Semantics/TaskModel.lean`
8. `Logos/Core/Semantics/Validity.lean`
9. `Logos/Core/Metalogic/Soundness.lean`
10. `Logos/Core/Metalogic/Completeness.lean`
11. `Logos/Core/Theorems/Perpetuity.lean`
12. `Logos/Core/Automation/Tactics.lean`
13. `Logos/Core/Automation/ProofSearch.lean`
14. `LogosTest/Core/Syntax/FormulaTest.lean`
15. `LogosTest/Core/ProofSystem/AxiomsTest.lean`
16. `LogosTest/Core/ProofSystem/DerivationTest.lean`
17. `LogosTest/Core/Metalogic/SoundnessTest.lean`
18. `LogosTest/Core/Automation/TacticsTest.lean`

### Files Requiring Documentation Updates (12+ files)

1. `Documentation/Reference/OPERATORS.md`
2. `Documentation/Reference/GLOSSARY.md`
3. `Documentation/UserGuide/ARCHITECTURE.md`
4. `Documentation/UserGuide/TUTORIAL.md`
5. `Documentation/UserGuide/EXAMPLES.md`
6. `Documentation/Development/LEAN_STYLE_GUIDE.md`
7. `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
8. `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`
9. `CLAUDE.md`
10. `README.md`
11. `TODO.md`
12. Archive examples (3 files)

---

**Research Complete**: Ready for implementation plan creation.
